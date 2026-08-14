-- Desktop monitors and workspaces
hl.monitor({
    output = "DP-2",
    mode = "2560x1440@144",
    position = "0x0",
    scale = 1,
})

hl.monitor({
    output = "DP-1",
    mode = "2560x1440@74.97",
    position = "-2560x0",
    scale = 1,
})

for workspace = 1, 5 do
    hl.workspace_rule({ workspace = tostring(workspace), monitor = "DP-2" })
end

for workspace = 6, 10 do
    hl.workspace_rule({ workspace = tostring(workspace), monitor = "DP-1" })
end
