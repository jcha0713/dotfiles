local Color, colors, Group, groups, styles = require("colorbuddy").setup()

-- new popup menu style
Color.new("pBg", "#5e5e5e")
Color.new("pText", "#b1cfb1")
Color.new("pThumb", "#f1f1ff")

Group.new("mypmenu", colors.pText, colors.pBg)
Group.new("mypmenuSel", colors.pBg:dark(), colors.pText, styles.bold)
Group.new("mypmenuSbar", nil, colors.pThumb)

Group.new("pmenu", groups.mypmenu, groups.mypmenu)
Group.new("pmenuSel", groups.mypmenuSel, groups.mypmenuSel, groups.mypmenuSel)
Group.new("pmenuThumb", nil, groups.mypmenuSbar)
