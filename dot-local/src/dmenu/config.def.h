/* See LICENSE file for copyright and license details. */
/* Default settings; can be overriden by command line. */

static int topbar = 1;                      /* -b  option; if 0, dmenu appears at bottom */
static int fuzzy = 1;                       /* -F  option; if 0, dmenu doesn't use fuzzy matching */
static int center = 1;                      /* -c  option; if 0, dmenu won't be centered on the screen */
static int min_width = 400;                 /* minimum width when centered */
/* -fn option overrides fonts[0]; default X11 font or font set */
static const char *fonts[] =
{
    "FiraMono Nerd Font:pixelsize=20:antialias=true:autohint=true:style=Medium"
};
static const char *prompt      = NULL;      /* -p  option; prompt to the left of input field */
static const char *symbol_1 = "<";
static const char *symbol_2 = ">";

static char dmenufg[]              = "#d3c6aa"; //everforest fg
static char dmenubg[]              = "#232A2E"; //everforest bg5
static char dmenuselbg[]           = "#56635F"; //everforest fg

static
const
char *colors[][2] = {
	/*               fg         bg       */
   	[SchemeNorm] = { dmenufg, dmenubg },
	[SchemeSel]  = { "#eeeeee", dmenuselbg },
	[SchemeOut]  = { "#000000", "#00ffff" },
	[SchemeBorder] = { "#000000", dmenuselbg },
	[SchemeSelHighlight]  = { dmenufg, dmenuselbg },
	[SchemeNormHighlight] = { dmenufg, dmenuselbg },
	[SchemeCursor] = { "#222222", "#bbbbbb" },
};
/* -l option; if nonzero, dmenu uses vertical list with given number of lines */
static unsigned int lines      = 10;
/* -g option; if nonzero, dmenu uses a grid comprised of columns and lines */
static unsigned int columns    = 2;

/*
 * Characters not considered part of a word while deleting words
 * for example: " /?\"&[]"
 */
static const char worddelimiters[] = " ";

/*
 * -vi option; if nonzero, vi mode is always enabled and can be
 * accessed with the global_esc keysym + mod mask
 */
static unsigned int vi_mode = 0;
static unsigned int start_mode = 1;			/* mode to use when -vi is passed. 0 = insert mode, 1 = normal mode */
static Key global_esc = { XK_n, Mod1Mask };	/* escape key when vi mode is not enabled explicitly */
static Key quit_keys[] = {
	/* keysym	modifier */
	{ XK_q,		0 },
	{ XK_Escape,		0 }
};

/* Size of the window border */
static unsigned int border_width = 3;

