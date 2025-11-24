/*
 * This file contains patch control flags.
 *
 * In principle you should be able to mix and match any patches
 * you may want. In cases where patches are logically incompatible
 * one patch may take precedence over the other as noted in the
 * relevant descriptions.
 *
 * Although layouts typically come as patches they are differentiated
 * here for grouping purposes.
 */

/**
 * Bar modules
 */


/* Show layout symbol in bar */
#define BAR_LTSYMBOL_PATCH 1

/* Show status in bar */
#define BAR_STATUS_PATCH 1

/* Addition to the status2d patch that allows the use of terminal colors (color0 through color15)
 * from xrdb in the status, allowing programs like pywal to change statusbar colors.
 * This adds the C and B codes to use terminal foreground and background colors respectively.
 * E.g. ^B5^ would use color5 as the background color.
 * https://dwm.suckless.org/patches/status2d/
 */
#define BAR_STATUS2D_XRDB_TERMCOLORS_PATCH 0

/* The systray patch adds systray for the status bar.
 * https://dwm.suckless.org/patches/systray/
 */
#define BAR_SYSTRAY_PATCH 1

/* Show tag symbols in the bar. */
#define BAR_TAGS_PATCH 1

/* This patch underlines the selected tag, or optionally all tags.
 * https://dwm.suckless.org/patches/underlinetags/
 */
#define BAR_UNDERLINETAGS_PATCH 1

/* This patch adds the window icon next to the window title in the bar.
 *
 * The patch depends on Imlib2 for icon scaling.
 * You need to uncomment the corresponding line in config.mk to use the -lImlib2 library
 *
 * Arch Linux:
 *     sudo pacman -S imlib2
 * Debian:
 *     sudo apt install libimlib2-dev
 *
 * The author recommends adding the compiler flags of -O3 and -march=native to enable auto loop
 * vectorize for better performance.
 *
 * https://github.com/AdamYuan/dwm-winicon
 * https://dwm.suckless.org/patches/winicon
 */
#define BAR_WINICON_PATCH 1

/* Show window title in bar */
#define BAR_WINTITLE_PATCH 1

/* The alpha patch adds transparency for the status bar.
 * You need to uncomment the corresponding line in config.mk to use the -lXrender library
 * when including this patch.
 * https://dwm.suckless.org/patches/alpha/
 */
#define BAR_ALPHA_PATCH 1

/* This patch prevents dwm from drawing tags with no clients (i.e. vacant) on the bar.
 * https://dwm.suckless.org/patches/hide_vacant_tags/
 */
#define BAR_HIDEVACANTTAGS_PATCH 1

/* Same as barpadding patch but specifically tailored for the vanitygaps patch in that the outer
 * bar padding is derived from the vanitygaps settings. In addition to this the bar padding is
 * toggled in unison when vanitygaps are toggled. Increasing or decreasing gaps during runtime
 * will not affect the bar padding.
 */
#define BAR_PADDING_VANITYGAPS_PATCH 0

/***
 * Other patches
 */

/* All floating windows are centered, like the center patch, but without a rule.
 * The center patch takes precedence over this patch.
 * This patch interferes with the center transient windows patches.
 * https://dwm.suckless.org/patches/alwayscenter/
 */
#define ALWAYSCENTER_PATCH 1

/* Adds a keyboard shortcut to restart dwm or alternatively by using kill -HUP dwmpid.
 * Additionally dwm can quit cleanly by using kill -TERM dwmpid.
 * https://dwm.suckless.org/patches/restartsig/
 */
#define RESTARTSIG_PATCH 1

/* This patch adds rounded corners to client windows in dwm.
 * You need to uncomment the corresponding line in config.mk to use the -lXext library
 * when including this patch. You will also want to set "borderpx = 0;" in your config.h.
 * https://github.com/mitchweaver/suckless/blob/master/dwm/patches/mitch-06-rounded_corners-f04cac6d6e39cd9e3fc4fae526e3d1e8df5e34b2.patch
 */
#define ROUNDED_CORNERS_PATCH 0

/* This patch persists some settings across window manager restarts. These include but are not
 * limited to:
 *    - client's assigned tag(s) on which monitor
 *    - the order of clients
 *    - nmaster
 *    - selected layout
 *    - plus various additions depending on what other patches are used
 *
 * The above is not persisted across reboots, however.
 */
#define SEAMLESS_RESTART_PATCH 1

/* Steam, and steam windows (games), trigger a ConfigureNotify request every time the window
 * gets focus. More so, the configure event passed along from Steam tends to have the wrong
 * x and y co-ordinates which can make the window, if floating, jump around the screen.
 *
 * This patch works around this age-old issue by ignoring the x and y co-ordinates for
 * ConfigureNotify requests relating to Steam windows.
 *
 * https://github.com/bakkeby/patches/wiki/steam
 */
#define STEAM_PATCH 1

/* Adds toggleable keyboard shortcut to make a client 'sticky', i.e. visible on all tags.
 * https://dwm.suckless.org/patches/sticky/
 */
#define STICKY_PATCH 1

/* This patch adds "window swallowing" to dwm as known from Plan 9's windowing system rio.
 * Clients marked with isterminal in config.h swallow a window opened by any child process,
 * e.g. running xclock in a terminal. Closing the xclock window restores the terminal window
 * in the current position.
 *
 * This patch depends on the following additional libraries:
 *    - libxcb
 *    - Xlib-libxcb
 *    - xcb-res
 *
 * You need to uncomment the corresponding line in config.mk to use the above libraries when
 * including this patch.
 *
 * https://dwm.suckless.org/patches/swallow/
 */
#define SWALLOW_PATCH 1

/* This patch adds configurable gaps between windows differentiating between outer, inner,
 * horizontal and vertical gaps.
 * https://github.com/bakkeby/patches/blob/master/dwm/dwm-vanitygaps-6.2.diff
 * https://github.com/bakkeby/patches/blob/master/dwm/dwm-cfacts-vanitygaps-6.2.diff
 */
#define VANITYGAPS_PATCH 1

/* This patch adds outer gaps for the monocle layout.
 * Most gaps patches tries to avoid gaps on the monocle layout, as it is often
 * used as a fullscreen mode, hence this is enabled separately from the main
 * vanitygaps patch.
 */
#define VANITYGAPS_MONOCLE_PATCH 1

/* Allows dwm to read colors from xrdb (.Xresources) during runtime. Compatible with
 * the float border color, awesomebar, urgentborder and titlecolor patches.
 * https://dwm.suckless.org/patches/xrdb/
 */
#define XRDB_PATCH 1

/* This patch allows for integer, float and string settings to be loaded from Xresources.
 * Xresources takes precedence over xrdb.
 * https://dwm.suckless.org/patches/xresources/
 */
#define XRESOURCES_PATCH 1

/**
 * Layouts
 */

/* The default tile layout.
 * This can be optionally disabled in favour of other layouts.
 */
#define TILE_LAYOUT 1

/* Monocle layout (default).
 * This can be optionally disabled in favour of other layouts.
 */
#define MONOCLE_LAYOUT 1

/* Thinkpad Keys (brightness)
 */
#define THINKPAD_KEYS 0

/* Volume keys
 */
#define VOLUME_KEYS 1
