/* user and group to drop privileges to */
static const char *user  = "nobody";
static const char *group = "nogroup"; // use "nobody" for arch

static const char *colorname[NUMCOLS] = {
	[INIT] =   "#232A2E",     /* after initialization */
	[INPUT] =  "#D3C6AA",   /* during input */
	[FAILED] = "#E67E80",   /* wrong password */
};

/* default message */
static const char * message = "Taras Khvorost computer. macroperson@pm.me";

/* text color */
static const char * text_color = "#d3c6aa";

/* text size (must be a valid size) */
static const char * font_name = "-adobe-times-medium-i-normal--34-240-100-100-p-168-iso8859-1";

/* insert grid pattern with scale 1:1, the size can be changed with logosize */
static const int logosize = 75;
static const int logow = 12;   /* grid width and height for right center alignment*/
static const int logoh = 6;

static XRectangle rectangles[] = {
   /* x    y   w   h */
   { 0,    3,  1,  3 },
   { 1,    3,  2,  1 },
   { 0,    5,  8,  1 },
   { 3,    1,  1,  0 },
   { 5,    3,  1,  2 },
   { 7,    3,  1,  2 },
   { 8,    3,  4,  1 },
   { 9,    4,  1,  2 },
   { 11,   4,  1,  2 },
};

/* treat a cleared input like a wrong password (color) */
static const int failonclear = 1;

/* Enable blur */
#define BLUR
/* Set blur radius */
static const int blurRadius = 10;
/* Enable Pixelation */
//#define PIXELATION
/* Set pixelation radius */
static const int pixelSize = 10;

/* time in seconds before the monitor shuts down */
static const int monitortime = 10;

