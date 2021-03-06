local F, C = unpack(select(2, ...))
local module = F:RegisterModule("Actionbar")


function module:OnLogin()
	local cfg = C.actionbar
	if not cfg.enable then return end

	local buttonSize = cfg.buttonSizeNormal*C.Mult
	local padding = cfg.padding*C.Mult
	local margin = cfg.margin*C.Mult

	local num = NUM_ACTIONBAR_BUTTONS
	local buttonList = {}

	--create the frame to hold the buttons
	local frame = CreateFrame("Frame", "FreeUI_ActionBar1", UIParent, "SecureHandlerStateTemplate")
	frame:SetWidth(num*buttonSize + (num-1)*margin + 2*padding)
	frame:SetHeight(buttonSize + 2*padding)

	frame:SetPoint(unpack(cfg.bar1Pos))
	frame:SetScale(1)

	for i = 1, num do
		local button = _G["ActionButton"..i]
		table.insert(buttonList, button) --add the button object to the list
		button:SetParent(frame)
		button:SetSize(buttonSize, buttonSize)
		button:ClearAllPoints()

		if i == 1 then
			button:SetPoint("BOTTOMLEFT", frame, padding, padding)
		else
			local previous = _G["ActionButton"..i-1]
			button:SetPoint("LEFT", previous, "RIGHT", margin, 0)
		end
	end

	--show/hide the frame on a given state driver
	if cfg.layoutStyle == 3 then
		frame.frameVisibility = "[mod:shift][@vehicle,exists][overridebar][shapeshift][vehicleui][possessbar,@vehicle,exists] show; hide"
		F.CreateButtonFrameFader(frame, buttonList, cfg.faderOnShow)
	else
		frame.frameVisibility = "[petbattle] hide; show"
	end
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	--_onstate-page state driver
	local actionPage = "[bar:6]6;[bar:5]5;[bar:4]4;[bar:3]3;[bar:2]2;[overridebar]14;[shapeshift]13;[vehicleui]12;[possessbar]12;[bonusbar:5]11;[bonusbar:4]10;[bonusbar:3]9;[bonusbar:2]8;[bonusbar:1]7;1"
	local buttonName = "ActionButton"
	for i, button in next, buttonList do
		frame:SetFrameRef(buttonName..i, button)
	end

	frame:Execute(([[
		buttons = table.new()
		for i = 1, %d do
			table.insert(buttons, self:GetFrameRef("%s"..i))
		end
	]]):format(num, buttonName))

	frame:SetAttribute("_onstate-page", [[
		for _, button in next, buttons do
			button:SetAttribute("actionpage", newstate)
		end
	]])
	RegisterStateDriver(frame, "page", actionPage)

	--[[local function vehicleFix()
		if InCombatLockdown() then return end
		if HasVehicleActionBar() or HasOverrideActionBar() then
			for _, button in next, buttonList do
				ActionButton_Update(button)
			end
		end
	end
	F:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR", vehicleFix)
	F:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR", vehicleFix)]]

	self:CreateBar2()
	self:CreateBar3()
	self:CreateBar4()
	self:CreateBar5()
	self:CreatePetbar()
	self:CreateStancebar()
	self:CreateExtrabar()
	self:CreateLeaveVehicle()
	self:HideBlizz()

	--vehicle fix
	local function getActionTexture(button)
		return GetActionTexture(button.action)
	end

	F:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR", function()
		for _, button in next, buttonList do
			local icon = button.icon
			local texture = getActionTexture(button)
			if texture then
				icon:SetTexture(texture)
				icon:Show()
			else
				icon:Hide()
			end
		end
	end)
end