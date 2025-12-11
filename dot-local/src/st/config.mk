# st version
VERSION = 0.9.3

# Customize below to fit your system

# paths
PREFIX = /usr/local
MANPREFIX = $(PREFIX)/share/man
ICONPREFIX = $(PREFIX)/share/pixmaps
ICONNAME = st.png

X11INC = /usr/X11R6/include
X11LIB = /usr/X11R6/lib

PKG_CONFIG = pkg-config

# Uncomment this for the alpha patch / ALPHA_PATCH
XRENDER = `$(PKG_CONFIG) --libs xrender`


# includes and libs, uncomment harfbuzz for the ligatures patch
INCS = -I$(X11INC) \
       `$(PKG_CONFIG) --cflags fontconfig` \
       `$(PKG_CONFIG) --cflags freetype2` \
       $(LIGATURES_INC)
LIBS = -L$(X11LIB) -lm -lX11 -lutil -lXft ${SIXEL_LIBS} ${XRENDER} ${XCURSOR}\
       `$(PKG_CONFIG) --libs fontconfig` \
       `$(PKG_CONFIG) --libs freetype2` \
       $(LIGATURES_LIBS) \
       $(NETWMICON_LIBS)

# flags
STCPPFLAGS = -DVERSION=\"$(VERSION)\" -DICON=\"$(ICONPREFIX)/$(ICONNAME)\" -D_XOPEN_SOURCE=600
STCFLAGS = $(INCS) $(STCPPFLAGS) $(CPPFLAGS) $(CFLAGS)
STLDFLAGS = $(LIBS) $(LDFLAGS)

