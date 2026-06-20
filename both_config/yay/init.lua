-- Exclude packages modified in the last 3 days
yay.create_autocmd("UpgradeSelect", {
	desc = "skip recently modified AUR upgrades",
	callback = function(event)
		local exclude = {}
		local recent_cutoff = os.time() - (3 * 24 * 60 * 60)
		for _, pkg in ipairs(event.data.upgrades) do
			if pkg.repository == "aur" and pkg.last_modified >= recent_cutoff then
				yay.log.warn("pre-excluding recently modified AUR package:", pkg.name)
				table.insert(exclude, pkg.name)
			end
		end

		return { exclude = exclude, skip_menu = false }
	end,
})

-- Inspect PKGBUILDs for maintainer changes
yay.create_autocmd("AURPreInstall", {
	desc = "flag maintainer changes in AUR packages",
	callback = function(event)
		local pkgname = event.match

		-- Extract the Maintainer line from the downloaded PKGBUILD
		local current_maintainer = event.data.pkgbuild:match("# Maintainer: ([^\n]+)") or "Unknown/None"

		-- Setup local cache directory
		local cache_dir = os.getenv("HOME") .. "/.cache/yay/maintainer_cache/"
		os.execute("mkdir -p " .. cache_dir)
		local cache_file = cache_dir .. pkgname

		-- Check against known maintainer
		local f = io.open(cache_file, "r")
		if f then
			local known_maintainer = f:read("*l")
			f:close()

			if known_maintainer ~= current_maintainer then
				yay.log.warn(
					pkgname
						.. ": MAINTAINER CHANGED! Previous: ["
						.. known_maintainer
						.. "] -> New: ["
						.. current_maintainer
						.. "]"
				)
			end
		end

		-- Update the cache for the next run
		local fw = io.open(cache_file, "w")
		if fw then
			fw:write(current_maintainer .. "\n")
			fw:close()
		end
	end,
})
