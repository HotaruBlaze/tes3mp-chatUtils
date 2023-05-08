local chatUtils = {}
local colorBlacklist = { "black", "navy", "midnightblue", "darkblue" }
chatUtils.availableColorsList = {}

chatUtils.isColorBlackListed = function(colorToCheck)
	for _, col in pairs(colorBlacklist) do
		if string.lower(colorToCheck) == string.lower(col) then
			return true
		end
	end
	
	return false
end

-- Generate the colors listing from colors.lua
chatUtils.gatherColors = function()
	for thisColor, _ in pairs(color) do
		if chatUtils.isColorBlackListed(thisColor) == false then
			table.insert(chatUtils.availableColorsList, thisColor)
		end
	end
	
	table.sort(chatUtils.availableColorsList)
end

customCommandHooks.registerCommand("settitle", function(pid, cmd)
	playerName = Players[tonumber(pid)].name
	if cmd[2] then
		Players[pid].data.customVariables.customTitle = tableHelper.concatenateFromIndex(cmd, 2)
		tes3mp.SendMessage(pid, "Title set for " .. playerName .. "!\n")
	else
		tes3mp.SendMessage(pid, "Usage: /settitle text\n")
	end
end)

customCommandHooks.registerCommand("cleartitle", function(pid, cmd)
	Players[pid].data.customVariables.customTitle = nil
end)

customCommandHooks.registerCommand("setcolor", function(pid, cmd)
	local list = ""
	local playername = Players[pid].data.login.name
	local title = color.DodgerBlue .. "\nList of available colors"

	local divider = "\n"

	for i = 1, #chatUtils.availableColorsList do
		local currentColor = chatUtils.availableColorsList[i]

		if i == #chatUtils.availableColorsList then
			divider = ""
		end

		list = list .. "> " .. color[currentColor] .. playername .. color.Default .. " | " .. color[currentColor] .. currentColor .. divider
	end

	tes3mp.ListBox(pid, 32965, title, list)
end)

customEventHooks.registerValidator("OnPlayerSendMessage", function(eventStatus, pid, message)
	--if its a command then return cus we want the command handler to run that
	if message:sub(1, 1) == "/" then
		return
	end
	local playerColor

	if Players[pid].data.customVariables.chatColor then
		playerColor = color[Players[pid].data.customVariables.chatColor]
	else
		playerColor = color.Default
	end

	local msg = playerColor .. logicHandler.GetChatName(pid) .. color.Default .. ": "
	msg = msg .. message

	--if player title isn't nil then add it to the start of the message
	if Players[pid].data.customVariables.customTitle ~= nil then
		msg = color.Orange .. "[" .. Players[pid].data.customVariables.customTitle .. "] " .. color.Default .. msg
	end

	tes3mp.SendMessage(pid, msg .. "\n", true)

	eventStatus.validDefaultHandler = false
	return eventStatus
end)

local function OnServerPostInit(eventStatus)
	chatUtils.gatherColors()
end

local function OnGUIAction(EventStatus, pid, idGui, data)
	if idGui == 32965 then
		if tonumber(data) == 0 or tonumber(data) == 18446744073709551615 then
			return
		else
			Players[pid].data.customVariables.chatColor = chatUtils.availableColorsList[tonumber(data) + 1]
			tes3mp.SendMessage(
				pid,
				"You have set your color to: " .. color[Players[pid].data.customVariables.chatColor] .. chatUtils.availableColorsList[tonumber(data) + 1] .. color.Default .. "\n"
			)
		end
	end
end

customEventHooks.registerHandler("OnServerPostInit", OnServerPostInit)
customEventHooks.registerHandler("OnGUIAction", OnGUIAction)
