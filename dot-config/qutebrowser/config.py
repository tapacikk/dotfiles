c.fonts.default_size = '12pt'
c.fonts.default_family = "FiraMono Nerd Font"
config.load_autoconfig(True)
config.set('content.cookies.accept', 'never', 'chrome-devtools://*')
config.set('content.headers.accept_language', '', 'https://matchmaker.krunker.io/*')
config.set('scrolling.smooth', True)
config.set('downloads.remove_finished', 1000)
config.set('tabs.show', 'always')
config.set('tabs.position', 'right')
config.set('tabs.title.alignment', 'right')

# Load images automatically in web pages.
config.set('content.images', True, 'chrome-devtools://*')

# Enable JavaScript.
# Type: Bool
config.set('content.javascript.enabled', True, 'qute://*/*')

c.downloads.location.directory = '/tmp'

# Editor (and arguments) to use for the `edit-*` commands. The following
# placeholders are defined:  * `{file}`: Filename of the file to be
# edited. * `{line}`: Line in which the caret is found in the text. *
# `{column}`: Column in which the caret is found in the text. *
# `{line0}`: Same as `{line}`, but starting from index 0. * `{column0}`:
# Same as `{column}`, but starting from index 0.
# Type: ShellCommand
c.editor.command = ['st', '-e', 'vim', '{file}']
c.statusbar.show = 'always'
c.tabs.favicons.show = 'always'

# Position of the tab bar.
# Type: Position
# Valid values:
#   - top
#   - bottom
#   - left
#   - right
c.tabs.width = '5%'

# Default zoom level.
# Type: Perc
c.zoom.default = '125%'

# Default font size to use. Whenever "default_size" is used in a font
# setting, it's replaced with the size listed here. Valid values are
# either a float value with a "pt" suffix, or an integer value with a
# "px" suffix.
# Type: String

# Bindings for normal mode
config.bind('s', 'cmd-set-text -s :open -t https://scholar.google.com/scholar?q=')
config.bind('t', 'cmd-set-text -s :open -t')
config.bind(';n', 'hint links spawn --detach mpv {hint-url}')
config.unbind('<ctrl+n>')
config.bind('<ctrl+n>', 'config-cycle tabs.show never always')
config.bind('<z><l>', 'spawn --userscript qute-pass --username-target secret --username-pattern "username: (.+)"')

config.source('qutewal.py')
