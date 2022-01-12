local Color, colors, Group, groups, styles = require("colorbuddy").setup()

-- vim.g.seoul256_background = 236
-- vim.cmd [[colo seoul256]]
vim.cmd [[colorscheme gruvbox-flat]]

--[[ -- new popup menu style
Color.new("pBg", "#5e5e5e")
Color.new("pText", "#b1cfb1")
Color.new("pThumb", "#f1f1ff")

Group.new("mypmenu", colors.pText, colors.pBg)
Group.new("mypmenuSel", colors.pBg:dark(), colors.pText, styles.bold)
Group.new("mypmenuSbar", nil, colors.pThumb)

Group.new("pmenu", groups.mypmenu, groups.mypmenu)
Group.new("pmenuSel", groups.mypmenuSel, groups.mypmenuSel, groups.mypmenuSel)
Group.new("pmenuThumb", nil, groups.mypmenuSbar)

-- comment style
Color.new("comment", "#888888")

Group.new("mycomment", colors.comment, nil, styles.italic)
Group.new("comment", groups.mycomment, groups.mycomment, groups.mycomment)

-- incSearch: highlight when a line gets copied
Color.new("hlonyank", "#5bccf5")

Group.new("myhlonyank", nil, colors.hlonyank, nil)
Group.new("incSearch", groups.myhlonyank, groups.myhlonyank, groups.myhlonyank) ]]
