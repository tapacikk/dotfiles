from socket import gethostname
per_computer_settings = {
    'yoshipad':       ['20pt', '150%'],
    'wputer':         ['14pt', '100%'],
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
# Everforest Colorscheme
pallet = {
    'fg': '#d3c6aa',
    'red': '#e67e80',
    'orange': '#e69875',
    'yellow': '#dbbc7f',
    'green': '#a7c080',
    'aqua': '#83c092',
    'blue': '#7fbbb3',
    'purple': '#d699b6',
    'grey0': '#7a8478',
    'grey1': '#859289',
    'grey2': '#9da9a0',
    'statusline1': '#a7c080',
    'statusline2': '#d3c6aa',
    'statusline3': '#e67e80',
}
pallet.update({
        'bg_dim': '#232a2e',
        'bg0': '#2d353b',
        'bg1': '#343f44',
        'bg2': '#3d484d',
        'bg3': '#475258',
        'bg4': '#4f585e',
        'bg5': '#56635f',
        'bg_visual': '#543a48',
        'bg_red': '#514045',
        'bg_green': '#425047',
        'bg_blue': '#3a515d',
        'bg_yellow': '#4d4c43',
})
c.colors.webpage.bg = pallet['bg0']
c.colors.keyhint.fg = pallet['fg']
c.colors.keyhint.suffix.fg = pallet['red']
c.colors.messages.error.bg = pallet['bg_red']
c.colors.messages.error.fg = pallet['fg']
c.colors.messages.info.bg = pallet['bg_blue']
c.colors.messages.info.fg = pallet['fg']
c.colors.messages.warning.bg = pallet['bg_yellow']
c.colors.messages.warning.fg = pallet['fg']
c.colors.prompts.bg = pallet['bg0']
c.colors.prompts.fg = pallet['fg']
c.colors.completion.category.bg = pallet['bg0']
c.colors.completion.category.fg = pallet['fg']
c.colors.completion.fg = pallet['fg']
c.colors.completion.even.bg = pallet['bg0']
c.colors.completion.odd.bg = pallet['bg1']
c.colors.completion.match.fg = pallet['red']
c.colors.completion.item.selected.fg = pallet['fg']
c.colors.completion.item.selected.bg = pallet['bg_yellow']
c.colors.completion.item.selected.border.top = pallet['bg_yellow']
c.colors.completion.item.selected.border.bottom = pallet['bg_yellow']
c.colors.completion.scrollbar.bg = pallet['bg_dim']
c.colors.completion.scrollbar.fg = pallet['fg']
c.colors.hints.bg = pallet['bg0']
c.colors.hints.fg = pallet['fg']
c.colors.hints.match.fg = pallet['red']
c.hints.border = '0px solid black'
c.colors.statusbar.normal.fg = pallet['fg']
c.colors.statusbar.normal.bg = pallet['bg3']
c.colors.statusbar.insert.fg = pallet['bg0']
c.colors.statusbar.insert.bg = pallet['statusline1']
c.colors.statusbar.command.fg = pallet['fg']
c.colors.statusbar.command.bg = pallet['bg0']
c.colors.statusbar.url.error.fg = pallet['orange']
c.colors.statusbar.url.fg = pallet['fg']
c.colors.statusbar.url.hover.fg = pallet['blue']
c.colors.statusbar.url.success.http.fg = pallet['green']
c.colors.statusbar.url.success.https.fg = pallet['green']
c.colors.tabs.bar.bg = pallet['bg_dim']
c.colors.tabs.even.bg = pallet['bg0']
c.colors.tabs.odd.bg = pallet['bg0']
c.colors.tabs.even.fg = pallet['fg']
c.colors.tabs.odd.fg = pallet['fg']
c.colors.tabs.selected.even.bg = pallet['bg2']
c.colors.tabs.selected.odd.bg = pallet['bg2']
c.colors.tabs.selected.even.fg = pallet['fg']
c.colors.tabs.selected.odd.fg = pallet['fg']
c.colors.tabs.indicator.start = pallet['blue']
c.colors.tabs.indicator.stop = pallet['green']
c.colors.tabs.indicator.error = pallet['red']
