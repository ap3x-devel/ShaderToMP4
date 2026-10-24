// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

#define WIN32_LEAN_AND_MEAN
#include <winsock2.h>
#include <ws2tcpip.h>
#include "localserver.h"
#include <atomic>
#include <thread>

#pragma comment(lib, "ws2_32.lib")

namespace platform {

struct LocalServer::Impl {
    SOCKET listener = INVALID_SOCKET;
    std::thread worker;
    std::atomic<bool> stopping{false};
    std::function<LocalReply(const std::string&)> handler;
};

static const char* reason(int status) {
    switch (status) {
        case 200: return "OK";
        case 404: return "Not Found";
        case 500: return "Internal Server Error";
        default: return "Status";
    }
}

LocalServer::LocalServer() {}
LocalServer::~LocalServer() { stop(); }

int LocalServer::start(const std::function<LocalReply(const std::string&)>& handler) {
    stop();
    WSADATA wsa;
    if (WSAStartup(MAKEWORD(2, 2), &wsa) != 0) return 0;
    impl_ = new Impl();
    impl_->handler = handler;
    impl_->listener = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    sockaddr_in addr{};
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
    addr.sin_port = 0;
    int len = sizeof(addr);
    if (impl_->listener == INVALID_SOCKET || bind(impl_->listener, (sockaddr*)&addr, sizeof(addr)) != 0 || listen(impl_->listener, 4) != 0 ||
        getsockname(impl_->listener, (sockaddr*)&addr, &len) != 0) {
        stop();
        return 0;
    }
    const int port = ntohs(addr.sin_port);
    Impl* im = impl_;
    im->worker = std::thread([im] {
        while (!im->stopping) {
            fd_set set;
            FD_ZERO(&set);
            FD_SET(im->listener, &set);
            timeval tv{0, 100000};
            if (select(0, &set, nullptr, nullptr, &tv) <= 0) continue;
            SOCKET c = accept(im->listener, nullptr, nullptr);
            if (c == INVALID_SOCKET) continue;
            std::string req;
            char buf[2048];
            while (req.find("\r\n\r\n") == std::string::npos && req.size() < 16384) {
                const int n = recv(c, buf, sizeof(buf), 0);
                if (n <= 0) break;
                req.append(buf, (size_t)n);
            }
            std::string target;
            const size_t a = req.find(' '), b = req.find(' ', a == std::string::npos ? 0 : a + 1);
            if (a != std::string::npos && b != std::string::npos) target = req.substr(a + 1, b - a - 1);
            const LocalReply r = im->handler(target);
            std::string head = "HTTP/1.1 " + std::to_string(r.status) + " " + reason(r.status) + "\r\nContent-Type: application/json\r\nContent-Length: " +
                               std::to_string(r.body.size()) + "\r\nConnection: close\r\n\r\n";
            const std::string out = head + (r.truncate ? r.body.substr(0, r.body.size() / 2) : r.body);
            size_t sent = 0;
            while (sent < out.size()) {
                const int n = send(c, out.data() + sent, (int)(out.size() - sent), 0);
                if (n <= 0) break;
                sent += (size_t)n;
            }
            shutdown(c, SD_BOTH);
            closesocket(c);
        }
    });
    return port;
}

void LocalServer::stop() {
    if (!impl_) return;
    impl_->stopping = true;
    if (impl_->worker.joinable()) impl_->worker.join();
    if (impl_->listener != INVALID_SOCKET) closesocket(impl_->listener);
    delete impl_;
    impl_ = nullptr;
    WSACleanup();
}

}  // namespace platform
