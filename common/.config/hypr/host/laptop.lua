-- Laptop screen
hl.monitor({
    output = "eDP-1",
    mode = "1920x1080@60",
    position = "0x0",
    scale = 1,
})

-- Disable the touchscreen.
hl.device({
    name = "g2touch-multi-touch-by-g2tsp",
    enabled = false,
})

-- External monitors
hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1,
})
