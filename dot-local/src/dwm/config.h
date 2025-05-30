/* See LICENSE file for copyright and license details. */
#include <X11/XF86keysym.h>

/* appearance */
static const unsigned int borderpx  = 5;        /* border pixel of windows */
static const unsigned int gappx     = 18;        /* gaps between windows */
static const unsigned int snap      = 32;       /* snap pixel */
static const int swallowfloating    = 0;        /* 1 means swallow floating windows by default */
static const int showbar            = 1;        /* 0 means no bar */
static const int topbar             = 0;        /* 0 means bottom bar */
static const char *fonts[]          = { "JetBrains Mono:size=14", "JetBrains Regular:pixelsize=14:antialias=true:autohint=true"};
static const char dmenufont[]       = "JetBrains Mono:size=14";
static char normbgcolor[]           = "#222222";
static char normbordercolor[]       = "#444444"; static char normfgcolor[]           = "#bbbbbb";
static char selfgcolor[]            = "#eeeeee";
static char selbordercolor[]        = "#005577";
static char selbgcolor[]            = "#005577";
static char *colors[][3] = {
       /*               fg           bg           border   */
       [SchemeNorm] = { normfgcolor, normbgcolor, normbordercolor },
       [SchemeSel]  = { selfgcolor,  selbgcolor,  selbordercolor  },
};

/* tagging */
static const char *tags[] = { "1:>_", "2:web", "3:chem", "4:mutt", "5:office", "6", "7:ff", "8", "9:top" };

static const Rule rules[] = {
	/* xprop(1):
	 *	WM_CLASS(STRING) = instance, class
	 *	WM_NAME(STRING) = title
	 */
	/* class                instance  title           tags mask  isfloating  isterminal  noswallow  monitor */
	{ "St",                 NULL,     NULL,           0,         0,          1,           0,        -1 },
	{ "St",                 NULL,     "float_term",   0,         1,          1,           0,        -1 },
	{ NULL,                 NULL,     "Event Tester", 0,         0,          0,           1,        -1 }, /* xev */
	{ NULL,                 NULL,     "[] - Chemcraft trial", 0,         1,          0,           1,        -1 }, /* xev */
};

/* layout(s) */
static const float mfact     = 0.65; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 1;    /* 1 means respect size hints in tiled resizals */
static const int attachbelow = 1;    /* 1 means attach after the currently active window */

static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "[]=",      tile },    /* first entry is default */
	{ "><>",      NULL },    /* no layout function means floating behavior */
	{ "[M]",      monocle },
	{ "|M|",      centeredmaster },
	{ ">M>",      centeredfloatingmaster },
};

/* key definitions */
#define MODKEY Mod1Mask
#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static char dmenumon[2] = "0"; /* component of dmenucmd, manipulated in spawn() */
static const char *dmenucmd[] = { "dmenu_run", "-m", dmenumon, "-fn", dmenufont};
static const char *termcmd[]  = { "st", NULL };
static const char *floattermcmd[]  = { "st", "-t", "float_term", NULL };
static const char *notescmd[]  = { "st", "-t", "float_term", "-e", "notetaker", NULL };
static const char *readmescmd[]  = { "st", "-t", "float_term", "-e", "note-readmes", NULL };
static const char *calccmd[]  = { "st", "-t", "float_term", "-e", "notetaker", NULL };
static const char *brupcmd[]  = { "brightnessctl", "set", "5%+", NULL };
static const char *brdowncmd[]  = { "brightnessctl", "s", "5%-", NULL };
static const char *voldowncmd[]  = { "pactl", "set-sink-volume", "@DEFAULT_SINK@", "-5%", NULL };
static const char *volupcmd[]  = { "pactl", "set-sink-volume", "@DEFAULT_SINK@", "+5%", NULL };
static const char *mutecmd[]  = { "pactl", "set-sink-mute", "@DEFAULT_SINK@", "toggle", NULL };
static const char *scrot[]  = { "flameshot", "gui", NULL };
static const char *scrotclip[]  = { "scrot", "-s", "-e", "'xclip -selection clipboard -t image/png 0-i $f'" , NULL };


static Key keys[] = {
	/* modifier                     key        function        argument */
	{ 0,     XF86XK_MonBrightnessUp,      spawn,          {.v = brupcmd } },
	{ 0,     XF86XK_MonBrightnessDown,    spawn,          {.v = brdowncmd } },
	{ 0,     XF86XK_AudioMute,            spawn,          {.v = mutecmd } },
	{ 0,     XF86XK_AudioLowerVolume,    spawn,          {.v = voldowncmd } },
	{ 0,     XF86XK_AudioRaiseVolume,    spawn,          {.v = volupcmd } },
	{ MODKEY,                       XK_l,      setmfact,       {.f = +0.05} },
	{ MODKEY,                       XK_k,      focusstack,     {.i = -1 } },
	{ MODKEY,                       XK_j,      focusstack,     {.i = +1 } },
	{ MODKEY,                       XK_h,      setmfact,       {.f = -0.05} },
	{ MODKEY,                       XK_g,      togglebar,      {0} },
	{ MODKEY,                       XK_f,	   zoom,           {0} },
	{ MODKEY,	                XK_w,      killclient,     {0} },
	{ MODKEY|ShiftMask,             XK_q,      quit,           {0} },
	{ MODKEY,                       XK_t,      setlayout,      {.v = &layouts[0]} },
	{ MODKEY,                       XK_e,      setlayout,      {.v = &layouts[1]} },
	{ MODKEY,                       XK_r,      setlayout,      {.v = &layouts[2]} },
	{ MODKEY,                       XK_y,      setlayout,      {.v = &layouts[3]} },
	{ MODKEY,                       XK_u,      setlayout,      {.v = &layouts[4]} },
	{ MODKEY|ShiftMask,             XK_r,  	   togglefloating, {0} },
	{ MODKEY,                       XK_s,  	   spawn,          {.v = scrot} },
	{ MODKEY|ShiftMask,             XK_s,  	   spawn,          {.v = scrotclip} },
	{ MODKEY,                       XK_d,      spawn,          {.v = dmenucmd } },
	{ MODKEY,                       XK_Return, spawn,          {.v = termcmd } },
	{ MODKEY|ShiftMask,             XK_Return, spawn,          {.v = floattermcmd } },
	{ MODKEY,                       XK_Tab,    view,           {0} },
	{ MODKEY,                       XK_0,      view,           {.ui = ~0 } },
    { MODKEY|ShiftMask,             XK_0,      tag,            {.ui = ~0 } },
	{ MODKEY,                       XK_equal,  setgaps,	   {.i = -1 } },
	{ MODKEY,			            XK_minus,  setgaps,	   {.i = +1 } },
	{ MODKEY|ShiftMask,		        XK_equal,  setgaps,	   {.i =  0 } },
	{ MODKEY,                       XK_F5,     xrdb,           {.v = NULL } },
	{ MODKEY,                       XK_n,      spawn,          {.v = notescmd } },
	{ MODKEY|ShiftMask,             XK_n,      spawn,          {.v = readmescmd } },
	TAGKEYS(                        XK_1,                      0)
	TAGKEYS(                        XK_2,                      1)
	TAGKEYS(                        XK_3,                      2)
	TAGKEYS(                        XK_4,                      3)
	TAGKEYS(                        XK_5,                      4)
	TAGKEYS(                        XK_6,                      5)
	TAGKEYS(                        XK_7,                      6)
	TAGKEYS(                        XK_8,                      7)
	TAGKEYS(                        XK_9,                      8)
	{ MODKEY|ShiftMask,		        XK_q,      quit,           {0} },
};

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static Button buttons[] = {
	/* click                event mask      button          function        argument */
	{ ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
	{ ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[2]} },
	{ ClkWinTitle,          0,              Button2,        zoom,           {0} },
	{ ClkStatusText,        0,              Button2,        spawn,          {.v = termcmd } },
	{ ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
	{ ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
	{ ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
	{ ClkTagBar,            0,              Button1,        view,           {0} },
	{ ClkTagBar,            0,              Button3,        toggleview,     {0} },
	{ ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
	{ ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
};

