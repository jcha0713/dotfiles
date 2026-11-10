rex.mode("rex", { exclusive = true })
rex.bind("ctrl+a", "client.mode.enter", {
	name = "rex",
})

rex.mode("scroll", { exclusive = true })
rex.bind("rex/s", "client.mode.enter", {
	name = "scroll",
})

rex.bind("scroll/u", "client.scroll.page_up")
rex.bind("scroll/d", "client.scroll.page_down")

rex.bind("scroll/esc", "client.mode.exit")
