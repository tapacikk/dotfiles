# dwm version
VERSION = 6.5

# paths
PREFIX = /usr/local
MANPREFIX = ${PREFIX}/share/man
SCRIPTPREFIX := /home/taras/.local/bin/

X11INC = /usr/X11R6/include
X11LIB = /usr/X11R6/lib

XINERAMALIBS  = -lXinerama
XINERAMAFLAGS = -DXINERAMA

FREETYPELIBS = -lfontconfig -lXft
FREETYPEINC = /usr/include/freetype2

# alpha patch
XRENDER = -lXrender

# swallow patch
XCBLIBS = -lX11-xcb -lxcb -lxcb-res

# winicon
IMLIB2LIBS = -lImlib2

# includes and libs
INCS = -I${X11INC} -I${FREETYPEINC} ${YAJLINC} ${PANGOINC} ${BDINC}
LIBS = -L${X11LIB} -lX11 ${XINERAMALIBS} ${FREETYPELIBS}  ${XRENDER} ${MPDCLIENT} ${XEXTLIB} ${XCBLIBS} ${KVMLIB} ${PANGOLIB} ${YAJLLIBS} ${IMLIB2LIBS} $(BDLIBS)

# flags
CPPFLAGS = -DSCRIPTPREFIX=\"$(SCRIPTPREFIX)\" -D_DEFAULT_SOURCE -D_BSD_SOURCE -D_XOPEN_SOURCE=700L -DVERSION=\"${VERSION}\" ${XINERAMAFLAGS}
HOSTNAME := $(shell hostname)
ifeq ($(HOSTNAME), yoshipad)
    CPPFLAGS += -DVOLUME_KEYS
    CPPFLAGS += -DTHINKPAD_KEYS
endif
#CFLAGS   = -g -std=c99 -pedantic -Wall -O0 ${INCS} ${CPPFLAGS}
CFLAGS   = -std=c99 -pedantic -Wall -Wno-unused-function -Wno-deprecated-declarations -Os ${INCS} ${CPPFLAGS}
LDFLAGS  = ${LIBS}

# compiler and linker
CC = cc
