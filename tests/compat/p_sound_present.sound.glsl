// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: pass - p_sound_present
vec2 mainSound(int samp, float time) { return vec2(sin(6.2831853 * 440.0 * time) * 0.5); }
