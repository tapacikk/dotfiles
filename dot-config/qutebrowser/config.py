from socket import gethostname
per_computer_settings = {
    'yoshipad':       ['20pt', '150%'],
    'wputer':      ['14pt', '100%'],
    'number-machine': ['12pt', '100%'],
}
c.fonts.default_size = per_computer_settings[gethostname()][0]
c.fonts.default_family = "FiraMono Nerd Font"
config.load_autoconfig(False)
config.set('content.cookies.accept', 'never', 'chrome-devtools://*')
config.set('content.headers.accept_language', '', 'https://matchmaker.krunker.io/*')
config.set('scrolling.smooth', True)
config.set('downloads.remove_finished', 1000)
config.set('tabs.show', 'always')
config.set('tabs.position', 'top')
config.set('tabs.title.alignment', 'left')
config.set('content.images', True, 'chrome-devtools://*')
config.set('content.javascript.enabled', True, 'qute://*/*')
c.downloads.location.directory = '/tmp'
c.editor.command = ['st', '-e', 'vim', '{file}']
# Bindings for normal mode
config.bind('s', 'cmd-set-text -s :open -t https://scholar.google.com/scholar?q=')
config.bind('t', 'cmd-set-text -s :open -t')
config.bind('T', 'cmd-set-text -s :open -w')
config.bind(';n', 'hint links spawn --detach mpv {hint-url}')
config.unbind('<ctrl+n>')
config.bind('<ctrl+n>', 'config-cycle tabs.show never always')
config.bind('<Ctrl-c>', 'mode-leave', mode='insert')
config.set('zoom.default', per_computer_settings[gethostname()][1])

c.tabs.padding = {'top': 5, 'bottom': 5, 'right': 9, 'left': 5}
c.tabs.indicator.width = 0 
import os
from urllib.request import urlopen
if not os.path.exists(config.configdir / "theme.py"):
    theme = "https://raw.githubusercontent.com/catppuccin/qutebrowser/main/setup.py"
    with urlopen(theme) as themehtml:
        with open(config.configdir / "theme.py", "a") as file:
            file.writelines(themehtml.read().decode("utf-8"))

if os.path.exists(config.configdir / "theme.py"):
    import theme
    theme.setup(c, 'mocha', True)
