-- icons by game-icons.net

triangle = '(1")'
circle = '(2")'
square = '(3")'
pentagon = '(6")'

pickModelForId = nil

panelToggles = {}

teamApiUrl = [[https://datateamapp.azurewebsites.net/api/toTTS/]]
teamApiCode = ""

versionUrl = [[https://datateamapp.azurewebsites.net/api/Scripts/Version]]
scriptUrl = [[https://datateamapp.azurewebsites.net/api/Scripts/]]

--anything from special profiles with these typenames will be added to the names of operatives
specialNames = {
	"Boon of Tzeentch",
}

specialSelections = {
	"Tzeentch",
	"Khorne",
	"Nurgle",
	"Slaanesh",
	"Undivided",
}

state = {
	teamkey = nil,
	name = "New Team",
	playerid = nil,
	models = nil,
	modelOrder = nil,
	positions = {},
	catalogues = {},
	step = nil,
	version = {
		model = 1,
		node = 1,
	},
	-- modelscript = [[]],
	modelscript = [[
state = {}

self.max_typed_number = 99

ranges = {
	triangle = {
		color = Color(0.10, 0.10, 0.09),
		range = 1,
	},
	circle = {
		color = Color(1, 1, 1),
		range = 2,
	},
	square = {
		color = Color(0, 0.36, 0.62),
		range = 3,
	},
	pentagon = {
		color = Color(0.80, 0.08, 0.09),
		range = 6,
	},
}

triangle = '(1")'
circle = '(2")'
square = '(3")'
pentagon = '(6")'

function textColorXml(color, text)
	return string.format('<textcolor color="#%s">%s</textcolor>', color, text)
end

function textColorMd(color, text)
	return string.format("[%s]%s[-]", color, text)
end

secrets = {
	"ktcnid-status-hiddenRole",
}

text_subs = {
	["1&&"] = textColorXml("000000", triangle),
	["2&&"] = textColorXml("ffffff", circle),
	["3&&"] = textColorXml("1E87FF", square),
	["6&&"] = textColorXml("DA1A18", pentagon),
	["%(R%)"] = textColorXml("1E87FF", "R"),
	["%(M%)"] = textColorXml("F4641D", "M"),
}

md_subs = {
	["1&&"] = textColorMd("000000", triangle),
	["2&&"] = textColorMd("ffffff", circle),
	["3&&"] = textColorMd("1E87FF", square),
	["6&&"] = textColorMd("DA1A18", pentagon),
	["%(R%)"] = textColorMd("1E87FF", "R"),
	["%(M%)"] = textColorMd("F4641D", "M"),
}

function subsymbol(s, tbl)
	local st = s
	for o, sub in pairs(tbl) do
		st = string.gsub(st, o, sub)
	end
	return st
end

function xt(tag, attributes, children, value)
	return {
		tag = tag,
		attributes = attributes,
		children = children,
		value = value,
	}
end

function secretVisibility()
	local p = getOwningPlayer()
	if p == nil then
		return ""
	end
	return table.concat({ "Jokers", p.color }, "|")
end

function hideSecrets()
	local sv = secretVisibility()
	for i, v in ipairs(secrets) do
		self.UI.setAttribute(v, "visibility", sv)
	end
end

modelMeasureLineRadius = 0.05
base = {}
baseLineRadius = 0.0125
baseLineHeight = 0.2

rangeShown = false
measureColor = nil
measureRange = 0

function onNumberTyped(pc, n)
	rangeShown = n > 0
	measureColor = Color.fromString(pc)
	measureRange = n
	refreshVectors()
	Player[pc].broadcast(string.format('%d"', measureRange))
end

function saveState()
	self.script_state = JSON.encode(state)
end

function loadState()
	state = JSON.decode(self.script_state)
end

function savePosition(p, r)
	local savePos = {
		position = p or self.getPosition(),
		rotation = r or self.getRotation(),
	}
	state.savePos = savePos
	saveState()
	self.highlightOn(Color(0.19, 0.63, 0.87), 0.5)
end

function loadPosition()
	local sp = state.savePos
	if sp then
		self.setPositionSmooth(sp.position, false, true)
		self.setRotationSmooth(sp.rotation, false, true)
		self.highlightOn(Color(0.87, 0.43, 0.19), 0.5)
	end
end

function refreshWounds()
	local w = state.wounds
	local m = state.stats.Wounds

	local uiwstring = function()
		if w == 0 then
			return textColorXml("DA1A18", "DEAD")
		end
		return string.format("%d/%d", w, m)
	end

	local namewstring = function()
		if w == 0 then
			return "{[DA1A18]DEAD[-]}"
		elseif w < m / 2 then
			return string.format("{[9A1111]*[-]%d/%d[9A1111]*[-]}", w, m)
		end
		return string.format("{%d/%d}", w, m)
	end

	self.UI.setValue("ktcnid-status-wounds", uiwstring())

	local nname = self.getName()
	if string.find(nname, "%b{}") == nil then
		nname = "{} " .. nname
	end

	self.setName(string.gsub(nname, "%b{}", namewstring()))
end

function callback_role(player, value, id)
	player.broadcast(table.concat(state.roles, ", "))
end

function callback_hiddenRole(player, value, id)
	player.broadcast(table.concat(state.hiddenRoles, ", "))
end

function callback_item(player, value, id)
	player.broadcast(table.concat(state.items, ", "))
end

function refreshUI()
	local sc = self.getScale()
	local scaleFactorX = 1 / sc.x
	local scaleFactorY = 1 / sc.y
	local scaleFactorZ = 1 / sc.z

	local circOffset = function(d, a)
		local ra = math.rad(a)
		return string.format("%d %d", math.cos(ra) * d, math.sin(ra) * d)
	end

	local uid = 50

	local sv = secretVisibility()

	self.UI.setXmlTable({
		xt("Defaults", {}, {
			xt("Image", {
				class = "statusDisplay",
				hideAnimation = "Shrink",
				showAnimation = "Grow",
			}),
		}),
		xt("Panel", {
			position = "0 0 -" .. tostring(state.uiHeight * 100 * scaleFactorZ),
			width = 100,
			height = 100,
			rotation = "0 0 " .. (state.uiAngle or 0),
			scale = string.format("%f %f %f", scaleFactorX, scaleFactorY, scaleFactorZ),
		}, {
			xt("Panel", {
				id = "ktcnid-status-display-ring",
			}, {
				xt("Image", {
					class = "statusDisplay",
					image = "role",
					color = "#F3961C",
					width = 30,
					height = 30,
					offsetXY = circOffset(uid, 90),
					id = "ktcnid-status-role",
					onClick = "callback_role",
					active = next(state.roles) ~= nil,
				}),
				xt("Image", {
					class = "statusDisplay",
					image = "role",
					color = "#2C20CA",
					width = 30,
					height = 30,
					offsetXY = circOffset(uid, 45),
					id = "ktcnid-status-hiddenRole",
					onClick = "callback_hiddenRole",
					active = next(state.hiddenRoles) ~= nil,
					visibility = sv,
				}),
				xt("Image", {
					class = "statusDisplay",
					image = "item",
					color = "#F3961C",
					width = 30,
					height = 30,
					offsetXY = circOffset(uid, 135),
					id = "ktcnid-status-holding",
					active = state.holding,
				}),
			}),
			xt("Image", {
				class = "statusDisplay",
				image = "engage",
				width = 75,
				height = 75,
				color = "#FF5500",
				active = false,
				id = "ktcnid-status-order",
			}),
			xt("Panel", {
				color = "#808080",
				outline = "#FF5500",
				outlineSize = "2 2",
				width = 50,
				height = 25,
				offsetXY = circOffset(40, 270),
			}, {
				xt("Image", {
					image = "wound",
					class = "statusDisplay",
					color = "#921110",
					width = 30,
					height = 30,
					rectAlignment = "MiddleLeft",
					offsetXY = "-35 0",
					id = "ktcnid-status-injured",
					active = state.stats.Wounds and state.wounds < state.stats.Wounds / 2 or false,
				}),
				xt("Image", {
					image = "item",
					class = "statusDisplay",
					color = "#713B17",
					width = 30,
					height = 30,
					rectAlignment = "MiddleRight",
					offsetXY = "35 0",
					id = "ktcnid-status-item",
					active = next(state.items) ~= nil,
					onClick = "callback_item",
				}),
				xt("Text", {
					text = string.format("%d/%d", state.wounds or 0, state.stats.Wounds or 0),
					resizeTextForBestFit = true,
					color = "#ffffff",
					id = "ktcnid-status-wounds",
				}),
			}),
		}),
	})
end

function createUI()
	self.UI.setCustomAssets({
		-- {name="conceal", url=[=[https://steamusercontent-a.akamaihd.net/ugc/1613967569139373439/322556886BB52F6618257B7670C16DFCF234491C/]=]},
		-- {name="engage",  url=[=[https://steamusercontent-a.akamaihd.net/ugc/1613967569139373385/10EBAC6E2A9A0226C23790B4D6C3FAF0222CFBD2/]=]},
		-- {name="item",    url=[=[https://steamusercontent-a.akamaihd.net/ugc/1613967569139373338/32A408D41A6CF96B31F8E41032664CAD756665A4/]=]},
		-- {name="role",    url=[=[https://steamusercontent-a.akamaihd.net/ugc/1613967569139373274/67450F5CD734514E71F9A6B0C61E52D0A0D48358/]=]},
		{
			name = "wound",
			url = [=[https://steamusercontent-a.akamaihd.net/ugc/1613967569139373232/CA1024D61CAE8AA810E3D70D58BE0823D6F63FCF/]=],
		},
		-- {name="dead",    url=[=[https://steamusercontent-a.akamaihd.net/ugc/1613967569139373167/775C3F30A3EB854CB0FC7B5454EAFDA59A701E9F/]=]},
		-- {name="roster",  url=[=[https://steamusercontent-a.akamaihd.net/ugc/1613967569139450440/D4CAF07C20088B4611666FAEFD5C3E22DEB9FF78/]=]}
	})

	refreshUI()
end

function isInjured()
	return state.stats.Wounds and (state.wounds < state.stats.Wounds / 2) or false
end

function notify(pc, message)
	local owner = getOwningPlayer()
	if pc == owner.color then
		owner.broadcast(message)
	else
		owner.broadcast(string.format("%s: %s", Player[pc].name, message))
		Player[pc].broadcast(message)
	end
end

function damage(pc)
	local si = isInjured()
	state.wounds = math.max(0, (state.wounds or 0) - 1)
	if not si and isInjured() then
		self.UI.show("ktcnid-status-injured")
	end
	saveState()
	refreshWounds()
	notify(pc, string.format("%s took damage", self.getName()))
end

function heal(pc)
	local si = isInjured()
	state.wounds = math.min((state.stats.Wounds or 0), (state.wounds or 0) + 1)
	if si and not isInjured() then
		self.UI.hide("ktcnid-status-injured")
	end
	saveState()
	refreshWounds()
	notify(pc, string.format("%s recovered", self.getName()))
end

function kill(pc)
	state.wounds = 0
	saveState()
	refreshWounds()
	notify(pc, string.format("%s KO", self.getName()))
end

function updateStats(pc)
	if getOwningPlayer().color ~= pc then
		notify(pc, "Only the model's owner can update stats")
		return
	end
	notify(pc, "Updating stats from values in description")
	local statsub = {}
	local prevW = state.stats.Wounds or 0
	local wounds = state.wounds or 0
	local desc = self.getDescription() or ""
	local innerUpdate = function(stat)
		local statNames = {
			["WOUNDS"] = "Wounds",
			["APL"] = "APL",
			["MOVE"] = "Move",
			["SAVE"] = "Save",
		}
		local innerStat = statNames[stat]
		local sstring = "%[84E680%]" .. stat .. "%[%-%]%s*%[ffffff%]%s*(%d+).*%[%-%]"
		for match in string.gmatch(desc, "%b[]") do
			local s = match:match(sstring)
			if s then
				local ss = state.stats[innerStat]
				table.insert(statsub, string.format("%s = %s", stat, s))
				if ss and ss == tonumber(s) then
					return false
				end
				state.stats[innerStat] = tonumber(s)

				-- notify(pc, string.format("%s set to %s", stat, s))
				return true
			end
		end
		table.insert(statsub, string.format("%s = [ff0000]X[-]", stat))
		return false
	end
	innerUpdate("APL")
	innerUpdate("MOVE")
	innerUpdate("SAVE")
	if innerUpdate("WOUNDS") then
		if wounds == prevW then
			state.wounds = state.stats.Wounds or 0
		else
			state.wounds = min(state.stats.Wounds or 0)
		end
		refreshWounds()
	end
	saveState()
	notify(pc, table.concat(statsub, ", "))
end

function onLoad(ls)
	loadState()

	self.addContextMenuItem("Take damage", damage, true)
	self.addContextMenuItem("Restore wounds", heal, true)
	self.addContextMenuItem("Kill", kill)
	self.addContextMenuItem("Save place", function(pc)
		savePosition()
	end)
	self.addContextMenuItem("Load place", function(pc)
		loadPosition()
	end)
	self.addContextMenuItem("Update stats", updateStats)

	local taglist = { state.modelid, "Operative" }
	for _, category in pairs(state.info.categories) do
		table.insert(taglist, category)
	end
	self.setTags(taglist)
	createUI()

	refreshVectors()
end

function onPickUp(pc)
	if rangeShown then
		refreshVectors(true)
	end
end

function tryRandomize(pc)
	rangeShown = not rangeShown
	measureColor = nil
	measureRange = 0
	refreshVectors()

	return false
end

function getOwningPlayer()
	for _, player in ipairs(Player.getPlayers()) do
		if player.steam_id == state.owner then
			return player
		end
	end
	return nil
end

function onPlayerChangeColor(color)
	if color ~= "Grey" then
		local p = Player[color]
		if p.steam_id == state.owner then
			refreshVectors()
			hideSecrets()
		end
	end
end

function refreshVectors(norotate)
	local op = getOwningPlayer()
	local circ = {}
	local scaleFactor = 1 / self.getScale().x

	local rotation = self.getRotation()

	local newLines = {
		{
			points = getCircleVectorPoints(0 - baseLineRadius, baseLineHeight),
			color = op and Color.fromString(op.color) or { 0.5, 0.5, 0.5 },
			thickness = baseLineRadius * 2 * scaleFactor,
		},
	}

	if rangeShown then
		if measureRange > 0 then
			table.insert(newLines, {
				points = getCircleVectorPoints(measureRange - modelMeasureLineRadius + 0.05, 0.125),
				color = measureColor,
				thickness = modelMeasureLineRadius * 2 * scaleFactor,
				rotation = (norotate and { 0, 0, 0 } or { -rotation.x, 0, -rotation.z }),
			})
		else
			for _, r in pairs(ranges) do
				local range = r.range
				table.insert(newLines, {
					points = getCircleVectorPoints(range - modelMeasureLineRadius + 0.05, 0.125),
					color = r.color,
					thickness = modelMeasureLineRadius * 2 * scaleFactor,
					rotation = (norotate and { 0, 0, 0 } or { -rotation.x, 0, -rotation.z }),
				})
			end
		end
	end

	self.setVectorLines(newLines)
end

function getCircleVectorPoints(radius, height, segments)
	local bounds = self.getBoundsNormalized()
	local result = {}
	local scaleFactorX = 1 / self.getScale().x
	local scaleFactorY = 1 / self.getScale().y
	local scaleFactorZ = 1 / self.getScale().z
	local steps = segments or 64
	local degrees, sin, cos, toRads = 360 / steps, math.sin, math.cos, math.rad
	local modelBase = state.base

	local mtoi = 0.0393701
	local baseX = modelBase.x * 0.5 * mtoi
	local baseZ = modelBase.z * 0.5 * mtoi

	for i = 0, steps do
		table.insert(result, {
			x = cos(toRads(degrees * i)) * ((radius + baseX) * scaleFactorX),
			z = sin(toRads(degrees * i)) * ((radius + baseZ) * scaleFactorZ),
			y = height * scaleFactorY,
		})
	end

	return result
end

function doAutoSize()
	local nx = state.base.x
	local nz = state.base.z
	local bounds = self.getBoundsNormalized()
	if bounds.size.x == 0 or bounds.size.y == 0 then
		local r = self.getRotation()
		self.setRotation(Vector(0, 0, 0))
		bounds = self.getBounds()
		self.setRotation(r)
	end
	local scale = self.getScale()
	local xi = nx / 25.4
	local zi = nz / 25.4
	local xs = (xi / bounds.size.x) * scale.x
	local zs = (zi / bounds.size.z) * scale.z

	self.setScale(Vector(xs, (xs + zs) / 2, zs))
	refreshVectors()
end

function setBaseSize(x, z)
	state.base = { x = x, z = z }
	-- state.uiHeight=((x + z)/25)
	saveState()
	refreshVectors()
	refreshUI()
end

function addRole(role, hidden)
	local rg = hidden and state.hiddenRoles or state.roles
	local empty = next(rg) == nil
	table.insert(rg, role)
	if empty then
		self.UI.show(hidden and "ktcnid-status-hiddenRole" or "ktcnid-status-role")
	end
	saveState()
end

function removeRole(role)
	local rri = function(rg, id)
		local nr = {}
		for i, v in ipairs(rg) do
			if v ~= role then
				table.insert(nr, v)
			end
		end
		rg = nr
		if next(rg) == nil then
			self.UI.hide(id)
		end
	end
	rri(state.roles, "ktcnid-status-role")
	rri(state.hiddenRoles, "ktcnid-status-hiddenRole")
end

function revealRole(role)
	removeRole(role)
	addRole(role, false)
end

function comCheckOwner(t)
	return t[1] == state.owner
end

function comBaseSize()
	return state.base
end

function comSetBase(t)
	setBaseSize(t.x, t.z)
end

function comAutoSize()
	doAutoSize()
	refreshUI()
end

function comSavePosition(t)
	savePosition(t.position, t.rotation)
end

function comLoadPosition()
	loadPosition()
end

function comAddRole(t)
	addRole(t.role, t.hidden)
end

function comRemoveRole(t)
	removeRole(t.role)
end

function comRevealRole(t)
	revealRole(t.role)
end

function comSetUIAngle(t)
	state.uiAngle = t.uiAngle
	saveState()
	refreshUI()
end
	]]
}

baseDimensions = {
	{ x = 25, z = 25 },
	{ x = 28.5, z = 28.5 },
	{ x = 32, z = 32 },
	{ x = 40, z = 40 },
	{ x = 50, z = 50 },
	{ x = 55, z = 55 },
	{ x = 60, z = 35 },
	{ x = 35, z = 60 },
	{ x = 60, z = 60 },
	{ x = 100, z = 100 },
	{ x = 25, z = 75 },
	{ x = 75, z = 25 },
	{ x = 120, z = 92 },
	{ x = 92, z = 120 },
	{ x = 170, z = 105 },
	{ x = 105, z = 170 },
}

function panelToggleCallback(player, value, id)
	-- print(id.." toggle buton pressed")
	local pid = panelToggles[id]
	if pid then
		-- print("toggling "..pid[1])
		if pid[2] then
			pid[2] = false
			-- print("OFF")
			self.UI.hide(pid[1])
		else
			pid[2] = true
			-- print("ON")
			self.UI.show(pid[1])
		end
	end
end

function panelToggle(btnid, panelid, df)
	panelToggles[btnid] = { panelid, df }
	-- print(string.format("toggle button: %s => %s", btnid, panelid))
	return "panelToggleCallback"
end

function makeGuiid(tbl)
	return "ktcnid-" .. table.concat(tbl, "-")
end

function fieldGuiid(t, name)
	return makeGuiid({ name, "field" })
end

function readGuiid(guiid)
	return splitString(guiid, "%-")
end

function textColorXml(color, text)
	return string.format('<textcolor color="#%s">%s</textcolor>', color, text)
end

function textColorMd(color, text)
	return string.format("[%s]%s[-]", color, text)
end

function textAttr(text, attr)
	return {
		tag = "Text",
		attributes = attr,
		value = text,
	}
end

function xt(tag, attributes, children, value)
	return {
		tag = tag,
		attributes = attributes,
		children = children,
		value = value,
	}
end

function rcall(target, fname, args)
	if target.getVar(fname) then
		target.call(fname, args)
	end
end

text_subs = {
	["1&&"] = textColorXml("000000", triangle),
	["2&&"] = textColorXml("ffffff", circle),
	["3&&"] = textColorXml("1E87FF", square),
	["6&&"] = textColorXml("DA1A18", pentagon),
	["%(R%)"] = textColorXml("1E87FF", "R"),
	["%(M%)"] = textColorXml("F4641D", "M"),
}

md_subs = {
	["1&&"] = textColorMd("000000", triangle),
	["2&&"] = textColorMd("ffffff", circle),
	["3&&"] = textColorMd("1E87FF", square),
	["6&&"] = textColorMd("DA1A18", pentagon),
	["%(R%)"] = textColorMd("1E87FF", "R"),
	["%(M%)"] = textColorMd("F4641D", "M"),
}

function subsymbol(s, tbl)
	local st = s
	for o, sub in pairs(tbl) do
		st = string.gsub(st, o, sub)
	end
	return st
end

function startsWith(st, match)
	return string.sub(st, 1, string.len(match)) == match
end

function checkOwner(p)
	if p.steam_id == state.playerid then
		return true
	else
		p.broadcast("Only the command node's owner can do that")
		return false
	end
end

function checkHost(p)
	if p.host then
		return true
	else
		p.broadcast("Only the host can do that")
	end
end

updateButtonId = makeGuiid({ "update", "script", "button" })

remoteVersion = {
	model = 0,
	node = 0,
}

function findBase(obj)
	local base = obj.getTable("modelBase")

	if base == nil then
		local bounds = obj.getBoundsNormalized()
		local baseX = 0
		local baseZ = 0

		if bounds.size.x == 0 then
			bounds = obj.getBounds()
		end

		if bounds.size.x > 0 then
			local boundsX = bounds.size.x * 25.4
			local boundsZ = bounds.size.z * 25.4
			local baseError = 999999
			for i, dim in pairs(baseDimensions) do
				local difx = (dim.x - boundsX)
				local difz = (dim.z - boundsZ)
				local dimError = difx * difx + difz * difz
				if dimError < baseError then
					baseError = dimError
					baseX = dim.x
					baseZ = dim.z
				end
			end
		else
			printToOwner("Could not detect base size for this model. You will need to set it manually.")
			baseX = 32
			baseZ = 32
		end
		base = { x = baseX, z = baseZ }
	end
	return base
end

function needsUpdate()
	return remoteVersion.model > state.version.model or remoteVersion.node > state.version.node
end

function getVersions()
	WebRequest.get(versionUrl, function(req)
		if req.is_error then
			log(req.error)
		else
			remoteVersion = JSON.decode(req.text)
			if needsUpdate() then
				self.UI.show(updateButtonId)
				broadcastToOwner(
					"A new version of the Command Node is available!\nRight click the node and select [b]Update Scripts[/b] to update"
				)
				-- self.addContextMenuItem("Update Scripts", tryUpdate)
			end
		end
	end)
end

function broadcastToOwner(s)
	if state.playerid == nil then
		broadcastToAll(s)
		return
	end
	for _, player in pairs(Player.getPlayers()) do
		if player.steam_id == state.playerid then
			player.broadcast(s)
			return
		end
	end
end

function onPlayerChangeColor(pc)
	if pc ~= "Grey" and state.playerid and Player[pc].steam_id == state.playerid then -- error when player leaves server
		self.setColorTint(Color.fromString(pc))
	end
end

function callback_claimNode(player, value, id)
	log(state, "token_state")
	state.playerid = player.steam_id
	self.setColorTint(Color.fromString(player.color))
	player.broadcast(string.format("Welcome, %s.\nSelect your roster to get started.", player.steam_name))
	saveState()
	generateGui()
end

function generateUIDefaults()
	return xt("Defaults", {}, {
		xt("Text", {
			class = "mainTitle",
			fontSize = "30",
			fontStyle = "BoldAndItalic",
		}),
		xt("Text", {
			class = "inputTitle",
			fontSize = "20",
			fontStyle = "Bold",
		}),
		xt("Panel", {
			class = "helpPanel",
			color = "#8B8B8B",
			showAnimation = "FadeIn",
			hideAnimation = "FadeOut",
			active = false,
		}),
		xt("Button", {
			class = "helpButton",
			width = 30,
			height = 30,
			resizeTextForBestFit = true,
			text = "?",
		}),
	})
end

function generateClaimUI(active, id)
	return xt("Panel", {
		active = active,
		id = id,
		width = 150,
		height = 60,
		position = "0 120 -10",
		rotation = "0 0 180",
	}, {
		xt("Button", {
			resizeTextForBestFit = true,
			onClick = "callback_claimNode",
			text = "New team",
		}),
	})
end

function callback_teamCode(player, value, id)
	teamApiCode = value
end

loadTeamButtonId = makeGuiid({ "team", "load", "button" })
function loadTeamRequest(request)
	if request.is_error then
		log(request.error)
		broadcastToAll("Failed to load team - check the system log")
		self.UI.setXmlTable({ generateUIDefaults(), generateTeamSelectUI(true, false) })
	else
		local status, dc = pcall(JSON.decode, request.text)
		if status then
			state.name = dc["roster"]["@name"]
			self.setName(state.name)
			local force = dc["roster"]["forces"]["force"]
			local models = {}
			local unpackModels = function(l)
				for _, v in pairs(l) do
					local vt = v.categories.category["@name"]
					if vt == nil or (vt ~= "Configuration" and vt ~= "Reference") then
						models[v["@id"]] = v
					end
				end
			end
			if force["@id"] then
				--roster mode
				unpackModels(force.selections.selection)
			else
				--fire team mode
				for _, v in pairs(force) do
					unpackModels(v.selections.selection)
				end
			end
			state.models = models
			saveState()
			-- log(generateModelScriptUI(true, models))
			self.UI.setXmlTable({
				generateUIDefaults(),
				generateModelScriptUI(true, models),
				generateTeamSelectUI(true, true),
			})
		else
			broadcastToOwner(
				"That code is not valid. Please copy your roster code from [b]datateamapp.azurewebsites.net/Encode[/b]."
			)
			self.UI.setXmlTable({ generateUIDefaults(), generateTeamSelectUI(true, false) })
		end
	end
end

function callback_loadTeam(player, value, id)
	if state.teamkey and state.teamkey == teamApiCode then
		player.broadcast("That team is already loaded")
		return
	end
	self.UI.setAttribute(id, "interactable", false)
	self.UI.setAttribute(id, "text", "LOADING...")
	state.teamkey = teamApiCode
	saveState()
	WebRequest.get(teamApiUrl .. teamApiCode, loadTeamRequest)
end

function modelSelections(model)
	local snames = {}
	log(model.selections)
	if model.selections ~= nil then
		sfloop(model.selections.selection, function(v)
			table.insert(snames, v["@name"])
		end)
	end
	return table.concat(snames, ", ")
end

function callback_pickModel(player, value, id)
	if player.steam_id == state.playerid then
		pickModelForId = id
		local model = state.models[id]
		player.broadcast(string.format("Choose a model for [b]%s[/b] with %s", model["@name"], modelSelections(model)))
	else
		player.broadcast("Only the team's owner can pick models.")
	end
end

function callback_tweakBase(player, value, id)
	local idi = readGuiid(id)
	local base = baseDimensions[tonumber(idi[4])]
	local so = player.getSelectedObjects()
	if next(so) ~= nil then
		for k, v in pairs(so) do
			rcall(v, "comSetBase", base)
		end
	else
		player.broadcast("Select some operatives first")
	end
end

function callback_autoScale(player, value, id)
	local so = player.getSelectedObjects()
	if next(so) ~= nil then
		for k, v in pairs(so) do
			rcall(v, "comAutoSize")
		end
	else
		player.broadcast("Select some operatives first")
	end
end

function callback_finishLayout(player, value, id)
	if checkOwner(player) then
		local np = {}
		for k, v in pairs(state.positions) do
			local m = getObjectsWithTag(k)
			if next(m) ~= nil then
				local o = m[1]
				local vr = o.getRotation().y - self.getRotation().y
				np[k] = {
					position = self.positionToLocal(o.getPosition()),
					rotation = vr,
				}
				o.call("comSetUIAngle", { uiAngle = vr })
			end
		end
		state.positions = np
		saveState()
		generateGui()
	end
end

function generateTeamLayoutUI(active, id)
	local tweakPanel = function()
		local bh = 25
		local sep = 4
		local border = 6
		local width = 150
		local height = border - sep

		local baseButton = function(t, h, k, v)
			local btext = (v.x == v.z) and string.format("%d", v.x) or string.format("%d by %d", v.x, v.z)
			table.insert(
				t,
				xt("Button", {
					text = btext,
					width = width - border * 2,
					height = bh,
					rectAlignment = "UpperCenter",
					id = makeGuiid({ "tweak", "base", tostring(k) }),
					onClick = "callback_tweakBase",
					offsetXY = string.format("0 %d", -h),
				})
			)
			return h + bh
		end

		local pchildren = {}

		table.insert(
			pchildren,
			xt("Text", {
				class = "inputTitle",
				resizeTextForBestFit = true,
				text = "Adjust base size",
				width = width - border * 2,
				height = 30,
				rectAlignment = "UpperCenter",
				offsetXY = "0 " .. -border,
			})
		)
		height = height + 30

		for k, v in pairs(baseDimensions) do
			height = baseButton(pchildren, height + sep, k, v)
		end

		height = height + 50 + border

		table.insert(
			pchildren,
			xt("Button", {
				text = "AUTO SCALE",
				resizeTextForBestFit = true,
				width = width - border * 2,
				height = 35,
				rectAlignment = "LowerCenter",
				offsetXY = "0 " .. border,
				onClick = "callback_autoScale",
			})
		)

		return xt("Panel", {
			color = "#ffffff",
			width = width,
			height = height,
			position = string.format("%d %d -50", -(width * 0.5 + 200), -(height * 0.5)),
			rotation = "0 0 180",
		}, pchildren)
	end

	local layoutArea = function(w, h, t, o)
		return xt("Panel", {
			width = w,
			height = h,
			position = string.format("0 %d -10", h * 0.5 + o),
			rotation = "0 0 180",
		}, {
			xt("Panel", {
				color = "#F4641D",
				height = t,
				rectAlignment = "UpperCenter",
			}),
			xt("Panel", {
				color = "#F4641D",
				height = t,
				rectAlignment = "LowerCenter",
			}),
			xt("Panel", {
				color = "#F4641D",
				height = (h - t * 2),
				width = t,
				rectAlignment = "MiddleLeft",
			}),
			xt("Panel", {
				color = "#F4641D",
				height = (h - t * 2),
				width = t,
				rectAlignment = "MiddleRight",
			}),
			xt("Text", {
				color = "#F4641D",
				text = "Arrange your team here",
				fontSize = 40,
			}),
		})
	end

	return xt("Panel", {}, {
		tweakPanel(),
		layoutArea(1600, 900, 15, 75),
		xt("Panel", {
			active = active,
			id = id,
			width = 310,
			height = 225,
			position = "0 -100 -200",
			color = "#FFFFFF",
			rotation = "45 0 180",
		}, {
			xt("VerticalLayout", {
				width = 300,
				height = 120,
				offsetXY = "0 -5",
				rectAlignment = "UpperCenter",
			}, {
				xt("Text", { class = "inputTitle", text = "Finish Your Team" }),
				xt("Text", {
					text = "Make sure all your operatives are on the right bases (see the <b>Adjust base size</b> panel)",
				}),
				xt("Text", {
					text = "When you're done, arrange your team in the orange area. When you're happy with the team's layout, click the FINISH button.",
				}),
			}),
			xt("Button", {
				width = 300,
				height = 40,
				resizeTextForBestFit = true,
				rectAlignment = "UpperCenter",
				text = "FINISH",
				offsetXY = "0 -180",
				onClick = "callback_finishLayout",
			}),
		}),
	})
end

function generateModelScriptUI(active, models, id)
	local mpw = 250
	local mph = 200
	local th = 50
	local bh = 50
	local mps = 25

	local mcw = mpw + mps
	local mch = mph + mps
	local hmps = mps * 0.5

	local vofs = 200

	local mids = {}
	for k, m in pairs(models) do
		table.insert(mids, { guid = k, sel = modelSelections(m), name = m["@name"] })
	end
	table.sort(mids, function(A, B)
		if A.name ~= B.name then
			return A.name < B.name
		end
		if A.sel ~= B.sel then
			return A.sel < B.sel
		end
		return A.guid < B.guid
	end)
	local mcount = #mids
	local mcs = math.floor(math.sqrt(mcount))
	local mw = math.ceil(mcount / mcs)

	local tcx = 0
	local tcy = 0

	local modelPanel = function(tbl, x, y, mid)
		local guid = mids[mid].guid
		local em = getObjectsWithTag(guid)
		local mod = models[guid]
		local lx = x * (mpw + mps) + hmps
		local ly = -y * (mph + mps) - hmps

		if next(em) ~= nil then
			makeOperative(em[1], guid)
		end

		table.insert(
			tbl,
			xt("Panel", {
				class = "modelPanel",
				color = (#em > 0) and "#808080" or "#8F5757",
				rectAlignment = "UpperLeft",
				width = mpw,
				height = mph,
				offsetXY = string.format("%d %d", lx, ly),
				id = guid .. "_panel",
			}, {
				xt("Text", {
					height = th,
					alignment = "MiddleCenter",
					rectAlignment = "UpperCenter",
					resizeTextForBestFit = true,
					text = mod["@customName"] or mod["@name"],
				}),
				xt("Text", {
					height = mph - th - bh,
					rectAlignment = "UpperCenter",
					offsetXY = string.format("0 %d", -th),
					text = mids[mid].sel,
				}),
				xt("Button", {
					height = bh,
					rectAlignment = "LowerCenter",
					text = "Choose Model",
					onClick = "callback_pickModel",
					id = guid,
				}),
			})
		)
	end

	state.positions = {}
	local mpanels = {}
	local panelw = (mpw + mps) * mw
	local panelh = (mph + mps) * mcs

	local i = 1
	local mi = 0
	while i <= mcount do
		local mx = math.floor(mi % mw)
		local my = math.floor(mi / mw)
		while not pcall(modelPanel, mpanels, mx, my, i) do
			i = i + 1
		end
		if i <= mcount then
			state.positions[mids[i].guid] = {
				position = Vector(
					(panelw * 0.5 - mx * mcw - mcw * 0.5) * 0.01,
					1,
					(vofs + my * mch + th + mps * 0.5) * 0.01
				),
				rotation = 0,
			}
		end
		i = i + 1
		mi = mi + 1
	end
	state.models = models
	saveState()

	return xt("Panel", {
		active = active,
		id = id,
		-- color="#ffffff",
		width = panelw,
		height = panelh,
		position = string.format("0 %d -10", panelh / 2 + vofs),
		rotation = "0 0 180",
	}, mpanels)
end

function callback_doTeamLayout(player, value, id)
	if checkOwner(player) then
		self.UI.setXmlTable({ generateUIDefaults(), generateTeamLayoutUI(true) })
		resetOperativePositions()
	end
end

function callback_doLoadNewRoster(player, value, id)
	if checkOwner(player) then
		self.UI.setXmlTable({
			generateUIDefaults(),
			generateTeamSelectUI(true, true),
			generateModelScriptUI(true, state.models),
		})
		resetOperativePositions()
	end
end

function generateTeamSelectUI(active, allowFinish, id)
	local selectHelpButton = makeGuiid({ "team", "select", "help", "button" })
	local selectHelpPanel = makeGuiid({ "team", "select", "help", "panel" })
	return xt("Panel", {
		active = active,
		id = id,
		width = 310,
		height = 225,
		position = "0 0 -100",
		color = "#FFFFFF",
		rotation = "0 0 180",
	}, {
		xt("VerticalLayout", {
			width = 300,
			height = 120,
			offsetXY = "0 -5",
			rectAlignment = "UpperCenter",
		}, {
			xt("Text", { class = "inputTitle", text = "Enter Team Code" }),
			xt("InputField", {
				placeholder = "Team Code",
				alignment = "MiddleCenter",
				fontSize = 20,
				onValueChanged = "callback_teamCode",
				characterLimit = 16,
				text = teamApiCode,
			}),
		}),
		xt("Button", {
			width = 300,
			height = 40,
			resizeTextForBestFit = true,
			rectAlignment = "UpperCenter",
			text = "LOAD TEAM",
			offsetXY = "0 -135",
			id = loadTeamButtonId,
			onClick = "callback_loadTeam",
		}),
		xt("Button", {
			width = 300,
			height = 40,
			resizeTextForBestFit = true,
			rectAlignment = "UpperCenter",
			text = "FINISH",
			offsetXY = "0 -180",
			interactable = allowFinish,
			onClick = "callback_doTeamLayout",
		}),
		xt("Panel", {
			class = "helpPanel",
			id = selectHelpPanel,
			width = 350,
			height = 400,
			rectAlignment = "LowerRight",
			offsetXY = "355 5",
		}, {
			xt(
				"Text",
				{
					alignment = "UpperLeft",
					width = 344,
					height = 394,
				},
				{},
				[[<textsize size="18"><b>How To Make a Team</b></textsize>\n
      <b>STEP 1)</b> Create your roster in New Recruit!\n
      <b>STEP 2)</b> Go to https://datateamapp.azurewebsites.net/Encode\n
      <b>STEP 3)</b> Upload your team's ".rosz" file"\n
      <b>STEP 4)</b> Copy your team code\n
      <b>STEP 5)</b> Paste your team code into the Command Node and press the <b>LOAD TEAM</b> button\n
      <b>STEP 6)</b> Select models for your operatives\n
      <b>STEP 7)</b> Press the <b>FINISH</b> button\n
      <b>STEP 8)</b> Your team is ready to play!]]
			),
		}),
		xt("Button", {
			width = 50,
			height = 50,
			rectAlignment = "UpperRight",
			offsetXY = "-5 -5",
			class = "helpButton",
			id = selectHelpButton,
			onClick = panelToggle(selectHelpButton, selectHelpPanel, false),
		}),
	})
end

function splitString(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t = {}
	for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
		table.insert(t, str)
	end
	return t
end

function getKeys(tbl)
	local r = {}
	local n = 1
	for k, v in pairs(tbl) do
		r[n] = k
		n = n + 1
	end
	return r, n - 1
end

function callback_saveAll(player, value, id)
	if checkOwner(player) then
		allOperatives(function(op)
			for _, v in ipairs(op) do
				v.call("comSavePosition", {})
			end
		end)
	end
end

function callback_loadAll(player, value, id)
	if checkOwner(player) then
		allOperatives(function(op)
			for i, v in ipairs(op) do
				v.call("comLoadPosition")
			end
		end)
	end
end

function callback_backToMain(player, value, id)
	if checkOwner(player) then
		generateGui()
	end
end

function generatePlayUI(active)
	local width = 350
	local border = 6
	local cw = width - border * 2
	local sep = 15
	local bh = 40
	local h = border
	local pc = {}

	local button = function(text, callback, id)
		table.insert(
			pc,
			xt("Button", {
				width = cw,
				height = bh,
				onClick = callback,
				text = text,
				fontSize = 12,
				id = id,
				rectAlignment = "UpperCenter",
				offsetXY = "0 " .. -h,
			})
		)
		h = h + bh + sep
	end

	button("Save all positions", "callback_saveAll")
	button("Load all positions", "callback_loadAll")
	button("Back to main menu", "callback_backToMain")

	return xt("Panel", {
		color = "#ffffff",
		height = h + border - sep,
		width = width,
		position = string.format("0 %d -100", -h / 2),
		rotation = "0 0 180",
	}, pc)
end

function callback_resetModelPositions(player, value, id)
	if checkOwner(player) then
		resetOperativePositions()
	end
end

--[[ function callback_updateScripts(player, value, id)
	if checkOwner(player) then
		tryUpdate(player.color)
	end
end --]]

function callback_play(player, value, id)
	if checkOwner(player) then
		self.UI.setXmlTable({ generateUIDefaults(), generatePlayUI(true) })
	end
end

function generateMainMenuUI(active)
	local width = 350
	local border = 6
	local cw = width - border * 2
	local sep = 15
	local bh = 40
	local h = border
	local pc = {}

	local button = function(text, callback, id)
		table.insert(
			pc,
			xt("Button", {
				width = cw,
				height = bh,
				onClick = callback,
				text = text,
				fontSize = 12,
				id = id,
				rectAlignment = "UpperCenter",
				offsetXY = "0 " .. -h,
			})
		)
		h = h + bh + sep
	end

	table.insert(
		pc,
		xt("Text", {
			class = "mainTitle",
			resizeTextForBestFit = true,
			text = state.name,
			width = cw,
			height = 30,
			rectAlignment = "UpperCenter",
			offsetXY = "0 " .. -h,
		})
	)
	h = h + 30 + sep

	button("Play", "callback_play")
	button("Recall models", "callback_resetModelPositions")
	button("Adjust Team", "callback_doTeamLayout")
	button("Load new roster", "callback_doLoadNewRoster")

--[[ 	table.insert(
		pc,
		xt("Button", {
			resizeTextForBestFit = true,
			text = "Update Scripts",
			width = 200,
			height = 80,
			rectAlignment = "UpperCenter",
			offsetXY = "0 90",
			color = "#F4641D",
			id = updateButtonId,
			showAnimation = "Grow",
			onClick = "callback_updateScripts",
			active = needsUpdate(),
		})
	) --]]

	return xt("Panel", {
		color = "#ffffff",
		height = h + border - sep,
		width = width,
		position = string.format("0 %d -100", -h / 2),
		rotation = "0 0 180",
	}, pc)
end

function generateGui()
	local defaults = generateUIDefaults()
	if state.playerid then
		if state.models then
			self.UI.setXmlTable({ defaults, generateMainMenuUI(true) })
		else
			self.UI.setXmlTable({ defaults, generateTeamSelectUI(true, false) })
		end
	else
		-- self.UI.setXmlTable({defaults, generateClaimUI(true)})
		self.UI.setXmlTable({ defaults, generateClaimUI(true) })
	end
end

function saveState()
	self.script_state = JSON.encode(state)
end

function loadState()
	local ds = JSON.decode(self.script_state)
	if ds then
		state = ds
	end
end

function tryUpdate(pc)
	if needsUpdate() then
		local req = scriptUrl
		local updateModel = remoteVersion.model > state.version.model
		local updateNode = remoteVersion.node > state.version.node
		if updateModel then
			req = req .. "Model"
		end
		if updateNode then
			req = req .. "Node"
		end

		WebRequest.get(req, function(resp)
			if resp.is_error then
				log(resp.error)
				broadcastToOwner("Failed to update scripts. Check the log.")
			else
				state.version = remoteVersion
				local data = JSON.decode(resp.text)
				self.clearContextMenu()

				if updateModel then
					broadcastToOwner("Updating models...")
					state.modelscript = data.model
					allOperatives(function(ops)
						for i = 2, #ops do
							ops[i].destruct()
						end
						ops[1].setLuaScript(data.model)
						ops[1].reload()
					end)
				end
				saveState()
				if updateNode then
					broadcastToOwner("Updating node...")
					self.setLuaScript(data.node)
				end
				resetOperativePositions()
				self.reload()
				broadcastToOwner("Finished update. You should save your team again.")
			end
		end)
	end
end

function sfloop(cat, func)
	if cat then
		if cat["@id"] then
			func(cat)
		else
			for i, v in ipairs(cat) do
				func(v)
			end
		end
	end
end

function loopSelections(res, bso)
	if (bso and bso.selections and bso.selections.selection) == nil then
		return
	end
	local profileFuncs = {
		["Weapons"] = function(p)
			local wstats = {}

			sfloop(p.characteristics.characteristic, function(c)
				wstats[c["@name"]] = c["#text"]
			end)

			table.insert(res.weapons, {
				name = p["@name"],
				stats = wstats,
			})
		end,
		["Psychic Power"] = function(p)
			table.insert(res.psychic, {
				name = p["@name"],
				text = p.characteristics.characteristic["#text"],
			})
		end,
	}
	sfloop(bso.selections.selection, function(v)
		local t = v["@type"]
		local n = v["@name"]
		if t == "upgrade" then
			table.insert(res.upgrades, n)

			if v.rules then
				sfloop(v.rules.rule, function(r)
					res.rules[r["@name"]] = r.description
				end)
			end

			if v.profiles then
				sfloop(v.profiles.profile, function(p)
					local pf = profileFuncs[p["@typeName"]]
					if pf then
						pf(p)
					else
						local tb = res.special[p["@typeName"]] or {}
						table.insert(tb, {
							name = p["@name"],
							text = p.characteristics.characteristic["#text"],
						})
						res.special[p["@typeName"]] = tb
					end
				end)
			end
		end
		loopSelections(res, v)
	end)
end

function modelToInfo(m)
	local res = {
		name = m["@customName"] or m["@name"],
		id = m["@id"],
		stats = {},
		weapons = {},
		actions = {},
		abilities = {},
		psychic = {},
		upgrades = {},
		special = {},
		rules = {},
		categories = {},
	}

	sfloop(m.profiles.profile, function(v)
		local tn = v["@typeName"]
		local n = v["@name"]
		if tn == "Operative" then
			res.modelType = n
			sfloop(v.characteristics.characteristic, function(c)
				res.stats[c["@name"]] = c["#text"]
			end)
		elseif tn == "Unique Actions" then
			table.insert(res.actions, {
				name = n,
				text = v.characteristics.characteristic["#text"],
			})
		elseif tn == "Abilities" then
			table.insert(res.abilities, {
				name = n,
				text = v.characteristics.characteristic["#text"],
			})
		end
	end)

	loopSelections(res, m)

	sfloop(m.categories.category, function(v)
		table.insert(res.categories, v["@name"])
	end)
	return res
end

function makeOperative(target, id)
	if state.models[id] then
		for _, m in pairs(getObjectsWithTag(id)) do
			m.destruct()
		end

		local getDescription = function(inf)
			local desc = {}

			local catex = function(cat, title, func, sep)
				if next(cat) ~= nil then
					table.insert(desc, title)
					local ot = {}
					for k, v in pairs(cat) do
						table.insert(ot, func(k, v))
					end
					table.insert(desc, table.concat(ot, sep or "\n"))
				end
			end
			-- log(inf.stats)
			if inf.modelType then
				table.insert(desc, inf.modelType)
			end
			table.insert(
				desc,
				string.format(
					"[D36B3E][[84E680]APL[-] [ffffff]%s[-]] [[84E680]MOVE[-] [ffffff]%s[-]]\n[[84E680]SAVE[-] [ffffff]%s[-]] [[84E680]WOUNDS[-] [ffffff]%s[-]][-]",
					inf.stats.APL or "X",
					inf.stats.Move or "X",
					inf.stats.Save or "X",
					inf.stats.Wounds or "X"
				)
			)
			table.insert(desc, "[C5C5C5]" .. table.concat(inf.categories, ", ") .. "[-]")

			if #inf.weapons ~= 0 then
				catex(inf.weapons, "[31B32B]Weapons[-]", function(k, v)
					-- log(v)
					local vs = v.stats
					local ATK = vs["ATK"] or "-"
					local HIT = vs["HIT"] or "-"
					local DMG = vs["DMG"] or "-/-"
					local WR = vs["WR"]

					local ostr = string.format(
						"%s\n[84E680]ATK[-] %s [84E680]HIT[-] %s [84E680]DMG[-] %s",
						v.name or "X",
						ATK or "X",
						HIT or "X",
						DMG or "X"
					)

					if WR and WR ~= "-" then
						ostr = ostr .. string.format("\n[84E680]WR[-]: %s", WR)
					end

					return ostr
				end, "\n\n")
			end

			table.insert(desc, "---")

			for k, sc in pairs(inf.special) do
				catex(sc, "[31B32B]" .. k .. "[-]", function(k, v)
					return string.format("- [EF8450]%s[-]", v.name)
				end)
			end

			catex(inf.psychic, "[31B32B]Psychic Powers[-]", function(k, v)
				return string.format("- [EF8450]%s[-]", v.name)
				-- return string.format("[EF8450]%s[-]\n%s\n", v.name, v.text)
			end)

			catex(inf.abilities, "[31B32B]Abilities[-]", function(k, v)
				return string.format("- [EF8450]%s[-]", v.name)
				-- return string.format("[EF8450]%s[-]\n%s\n", v.name, v.text)
			end)

			catex(inf.actions, "[31B32B]Actions[-]", function(k, v)
				return string.format("- [D46D6C]%s[-]", v.name)
				-- return string.format("[D46D6C]%s[-]\n%s\n", v.name, v.text)
			end)

			return (subsymbol(table.concat(desc, "\n"), md_subs))
		end

		local getNickname = function(inf)
			local nameSpecials = {}
			for i, v in ipairs(specialNames) do
				local sc = inf.special[v]
				if sc and next(sc) ~= nil then
					for _, f in ipairs(inf.special[v]) do
						table.insert(nameSpecials, f.name)
					end
				end
			end
			for _, sel in ipairs(specialSelections) do
				for _, upgrade in ipairs(inf.upgrades) do
					if upgrade == sel then
						table.insert(nameSpecials, sel)
					end
				end
			end
			if next(nameSpecials) ~= nil then
				return string.format(
					"{%d/%d} %s (%s)",
					inf.stats.Wounds or 0,
					inf.stats.Wounds or 0,
					inf.name,
					table.concat(nameSpecials, ", ")
				)
			end
			return string.format("{%d/%d} %s", inf.stats.Wounds or 0, inf.stats.Wounds or 0, inf.name)
		end

		self.UI.setAttribute(id .. "_panel", "color", "#808080")
		target.highlightOn(Color.Green, 0.5)
		local tdata = target.getData()

		local base = findBase(target)

		local model = state.models[id]
		local inf = modelToInfo(model)

		local stats = {}
		for k, v in pairs(inf.stats) do
			stats[k] = tonumber(string.match(v, "%d+"))
		end

		tdata.LuaScriptState = JSON.encode({
			base = base,
			owner = state.playerid,
			node = self.getGUID(),
			modelid = id,
			name = model["@name"],
			wounds = stats.Wounds or 0,
			stats = stats,
			uiHeight = 2,
			info = inf,
			roles = {},
			hiddenRoles = {},
			items = {},
			holding = false,
			uiAngle = 0,
		})

		--[[ local modelscript = string.format('%q', require('command-node/src/command_node'))
		log(modelscript, 'require_modelscript')
		tdata.LuaScript = modelscript --]]
		tdata.LuaScript = state.modelscript
		tdata.Description = getDescription(inf)
		tdata.Nickname = getNickname(inf)
		tdata.Autoraise = true
		tdata.Tooltip = true
		if tdata.CustomMesh then
			tdata.CustomMesh.TypeIndex = 1
		elseif tdata.CustomAssetbundle then
			tdata.CustomAssetbundle.TypeIndex = 1
		end

		local position = state.positions[id]
		spawnObjectData({
			data = tdata,
			position = self.positionToWorld(position.position),
			rotation = Vector(0, self.getRotation().y + position.rotation, 0),
			callback_function = function(o)
				o.setVelocity(Vector(0, 10, 0))
			end,
		})
	end
end

function onPlayerAction(player, action, targets)
	if pickModelForId and player.steam_id == state.playerid then
		local target = targets[1]
		if target.name == "Custom_Assetbundle" or target.name == "Custom_Model" or target.name == "Figurine_Custom" then
			makeOperative(target, pickModelForId)
			-- pickedModels[pickModelForId] = tdata
			pickModelForId = nil
			return false
		end
	end
	return true
end

function onLoad()
	self.setTags({ "Command Node" })
	-- getVersions()
	if state.modelscript == "" then
	    loadState()
	end
	teamApiCode = state.teamkey or teamApiCode
	generateGui()
	if state.playerid then
		for _, v in ipairs(Player.getPlayers()) do
			if v.steam_id == state.playerid then
				self.setColorTint(Color.fromString(v.color))
				break
			end
		end
	end
end

function allOperatives(f)
	for k, _ in pairs(state.positions) do
		local ops = getObjectsWithTag(k)
		if next(ops) ~= nil then
			f(ops)
		end
	end
end

function resetOperativePositions()
	for k, _ in pairs(state.positions) do
		local ops = getObjectsWithTag(k)
		if next(ops) ~= nil then
			for i = 2, #ops do
				ops[i].destruct()
			end
			resetPosition(k, ops[1])
		end
	end
end

function resetPosition(id, op)
	local p = state.positions[id]
	if p then
		local lp = self.positionToWorld(p.position) + Vector(0, 0.5, 0)
		local lr = Vector(0, self.getRotation().y + p.rotation, 0)
		op.setPositionSmooth(lp, false, true)
		op.setRotationSmooth(lr, false, true)
	end
end

function comResetPosition(t)
	local id = t.id
	local op = t.operative
	if id and op then
		resetPosition(id, op)
	end
end