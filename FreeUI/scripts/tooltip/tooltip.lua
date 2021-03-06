local F, C, L = unpack(select(2, ...))
if not C.tooltip.enable then return end
local module = F:RegisterModule('Tooltip')

function module:OnLogin()
	self:ExtraInfo()
	self:AzeriteTrait()
end

local strfind, format, strupper, strsplit = string.find, string.format, string.upper, string.split
local strlen, pairs = string.len, pairs
local PVP, FACTION_HORDE, FACTION_ALLIANCE, LEVEL, YOU, TARGET = PVP, FACTION_HORDE, FACTION_ALLIANCE, LEVEL, YOU, TARGET
local LE_REALM_RELATION_COALESCED, LE_REALM_RELATION_VIRTUAL = LE_REALM_RELATION_COALESCED, LE_REALM_RELATION_VIRTUAL
local FOREIGN_SERVER_LABEL, INTERACTIVE_SERVER_LABEL = FOREIGN_SERVER_LABEL, INTERACTIVE_SERVER_LABEL

local classification = {
	elite = ' |cffcc8800'..ELITE..'|r',
	rare = ' |cffff99cc'..L['RARE']..'|r',
	rareelite = ' |cffff99cc'..L['RARE']..'|r '..'|cffcc8800'..ELITE..'|r',
	worldboss = ' |cffff0000'..BOSS..'|r',
}

local function getUnit(self)
	local _, unit = self and self:GetUnit()
	if not unit then
		local mFocus = GetMouseFocus()
		if mFocus then
			unit = mFocus.unit or (mFocus.GetAttribute and mFocus:GetAttribute('unit'))
		end
	end
	return (unit or 'mouseover')
end

local function hideLines(self)
    for i = 3, self:NumLines() do
        local tiptext = _G['GameTooltipTextLeft'..i]
		local linetext = tiptext:GetText()
		if linetext then
			if C.tooltip.hidePVP and linetext == PVP_ENABLED then
				tiptext:SetText(nil)
				tiptext:Hide()
			elseif linetext == FACTION_HORDE then
				if C.tooltip.hideFaction then
					tiptext:SetText(nil)
					tiptext:Hide()
				else
					tiptext:SetText('|cffff5040'..linetext..'|r')
				end
			elseif linetext == FACTION_ALLIANCE then
				if C.tooltip.hideFaction then
					tiptext:SetText(nil)
					tiptext:Hide()
				else
					tiptext:SetText('|cff4080ff'..linetext..'|r')
				end
			end
		end
    end
end

local function getTarget(unit)
	if UnitIsUnit(unit, 'player') then
		return format('|cffff0000%s|r', '>'..strupper(YOU)..'<')
	else
		return F.HexRGB(F.UnitColor(unit))..UnitName(unit)..'|r'
	end
end

GameTooltip:HookScript('OnTooltipSetUnit', function(self)
	if self:IsForbidden() then return end
	if(C.tooltip.combatHide and InCombatLockdown()) then
		return self:Hide()
	end

	
	hideLines(self)

	local unit = getUnit(self)
	local isShiftKeyDown = IsShiftKeyDown()
	
	if UnitExists(unit) then
		self.ttUnit = unit
		local hexColor = F.HexRGB(F.UnitColor(unit))
		local ricon = GetRaidTargetIndex(unit)
		if ricon and ricon > 8 then ricon = nil end
		if ricon then
			local text = GameTooltipTextLeft1:GetText()
			GameTooltipTextLeft1:SetFormattedText(('%s %s'), ICON_LIST[ricon]..'18|t', text)
		end

		local isPlayer = UnitIsPlayer(unit)
		if isPlayer then
			local name, realm = UnitName(unit)
			local pvpName = UnitPVPName(unit)
			local relationship = UnitRealmRelationship(unit)
			if not C.tooltip.hideTitle and pvpName then
				name = pvpName
			end
			if realm and realm ~= '' then
				if isShiftKeyDown or not C.tooltip.hideRealm then
					name = name..'-'..realm
				elseif relationship == LE_REALM_RELATION_COALESCED then
					name = name..FOREIGN_SERVER_LABEL
				elseif relationship == LE_REALM_RELATION_VIRTUAL then
					name = name..INTERACTIVE_SERVER_LABEL
				end
			end

			local status = (UnitIsAFK(unit) and AFK) or (UnitIsDND(unit) and DND) or (not UnitIsConnected(unit) and PLAYER_OFFLINE)
			if status then
				status = format(' |cffffcc00[%s]|r', status)
			end
			GameTooltipTextLeft1:SetFormattedText('%s', hexColor..name..(status or ''))

			local guildName, rank, rankIndex, guildRealm = GetGuildInfo(unit)
			local hasText = GameTooltipTextLeft2:GetText()
			if guildName and hasText then
				rankIndex = rankIndex + 1
				if C.tooltip.hideRank then rank = '' end
				if guildRealm and isShiftKeyDown then
					guildName = guildName..'-'..guildRealm
				end
				--GameTooltipTextLeft2:SetText('<'..guildName..'> '..rank..'('..rankIndex..')')
				GameTooltipTextLeft2:SetText('<'..guildName..'> '..rank)

				local myGuild, _, _, myGuildRealm = GetGuildInfo('player')
				if IsInGuild() and guildName == myGuild and guildRealm == myGuildRealm then
					GameTooltipTextLeft2:SetTextColor(.25, 1, .25)
				else
					GameTooltipTextLeft2:SetTextColor(.6, .8, 1)
				end
			end
		end

		local alive = not UnitIsDeadOrGhost(unit)
		local level
		if UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit) then
			level = UnitBattlePetLevel(unit)
		else
			level = UnitLevel(unit)
		end

		if level then
			local boss
			if level == -1 then boss = '|cffff0000??|r' end

			local diff = GetCreatureDifficultyColor(level)
			local classify = UnitClassification(unit)
			local textLevel = format('%s%s%s|r', F.HexRGB(diff), boss or format('%d', level), classification[classify] or '')
			local tiptextLevel
			for i = 2, self:NumLines() do
				local tiptext = _G['GameTooltipTextLeft'..i]
				local linetext = tiptext:GetText()
				if linetext and strfind(linetext, LEVEL) then
					tiptextLevel = tiptext
				end
			end

			local pvpFlag = UnitIsPVP(unit) and format(' |cffff0000%s|r', PVP) or ''
			local unitClass = isPlayer and format('%s %s', UnitRace(unit) or '', hexColor..(UnitClass(unit) or '')..'|r') or UnitCreatureType(unit) or ''
			if tiptextLevel then
				tiptextLevel:SetFormattedText(('%s%s %s %s'), textLevel, pvpFlag, unitClass, (not alive and '|cffCCCCCC'..DEAD..'|r' or ''))
			end
		end

		if UnitExists(unit..'target') then
			local tarRicon = GetRaidTargetIndex(unit..'target')
			if tarRicon and tarRicon > 8 then tarRicon = nil end
			local tar = format('%s%s', (tarRicon and ICON_LIST[tarRicon]..'10|t') or '', getTarget(unit..'target'))
			self:AddLine(TARGET..': '..tar)
		end

		if alive then
			GameTooltipStatusBar:SetStatusBarColor(F.UnitColor(unit))
		else
			GameTooltipStatusBar:Hide()
		end
	else
		GameTooltipStatusBar:SetStatusBarColor(0, .9, 0)
	end

	if GameTooltipStatusBar:IsShown() then
		GameTooltipStatusBar:ClearAllPoints()
		GameTooltipStatusBar:SetPoint('BOTTOMLEFT', self, 'TOPLEFT', 1, -3)
		GameTooltipStatusBar:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT', -1, -3)
		if C.Mult and not GameTooltipStatusBar.bg then
			GameTooltipStatusBar:SetStatusBarTexture(C.media.sbTex)
			GameTooltipStatusBar:SetHeight(2)
			local bg = F.CreateBDFrame(GameTooltipStatusBar)
			F.CreateSD(bg)
			GameTooltipStatusBar.bg = bg
		end
	end
end)

hooksecurefunc('GameTooltip_ShowStatusBar', function(self)
	if self.statusBarPool then
		local bar = self.statusBarPool:Acquire()
		if bar and not bar.styled then
			local _, bd, tex = bar:GetRegions()
			tex:SetTexture(C.media.sbTex)
			bd:Hide()
			local bg = F.CreateBDFrame(bd, 0)
	
			bar.styled = true
		end
	end
end)


GameTooltip:HookScript('OnTooltipCleared', function(self)
	self.ttUpdate = 1
	self.ttNumLines = 0
	self.ttUnit = nil
end)

GameTooltip:HookScript('OnUpdate', function(self, elapsed)
	self.ttUpdate = (self.ttUpdate or 0) + elapsed
	if(self.ttUpdate < .1) then return end
	if(self.ttUnit and not UnitExists(self.ttUnit)) then self:Hide() return end
	self:SetBackdropColor(0, 0, 0, .65)
	self.ttUpdate = 0
end)

GameTooltip.FadeOut = function(self)
	self:Hide()
end


hooksecurefunc('GameTooltip_ShowProgressBar', function(self)
	if self.progressBarPool then
		local bar = self.progressBarPool:Acquire()
		if bar and not bar.styled then
			F.StripTextures(bar.Bar)
			bar.Bar:SetStatusBarTexture(C.media.sbTex)
			F.CreateBD(bar, .25)
			bar:SetSize(216, 18)
			F.SetFS(bar.Bar.Label)

			bar.styled = true
		end
	end
end)


-- fix compare tooltips margin
hooksecurefunc('GameTooltip_ShowCompareItem', function(self, shift)
	if not self then
		self = GameTooltip
	end

	-- Find correct side
	local shoppingTooltip1, shoppingTooltip2 = unpack(self.shoppingTooltips)
	local primaryItemShown, secondaryItemShown = shoppingTooltip1:SetCompareItem(shoppingTooltip2, self)
	local side = 'left'
	local rightDist = 0
	local leftPos = self:GetLeft()
	local rightPos = self:GetRight()

	if not rightPos then
		rightPos = 0
	end
	if not leftPos then
		leftPos = 0
	end

	rightDist = GetScreenWidth() - rightPos

	if leftPos and (rightDist < leftPos) then
		side = 'left'
	else
		side = 'right'
	end

	-- See if we should slide the tooltip
	if self:GetAnchorType() and self:GetAnchorType() ~= 'ANCHOR_PRESERVE' then
		local totalWidth = 0
		if primaryItemShown then
			totalWidth = totalWidth + shoppingTooltip1:GetWidth()
		end
		if secondaryItemShown then
			totalWidth = totalWidth + shoppingTooltip2:GetWidth()
		end

		if side == 'left' and totalWidth > leftPos then
			self:SetAnchorType(self:GetAnchorType(), totalWidth - leftPos, 0)
		elseif side == 'right' and (rightPos + totalWidth) > GetScreenWidth() then
			self:SetAnchorType(self:GetAnchorType(), -((rightPos + totalWidth) - GetScreenWidth()), 0)
		end
	end

	-- Anchor the compare tooltips
	if secondaryItemShown then
		shoppingTooltip2:SetOwner(self, 'ANCHOR_NONE')
		shoppingTooltip2:ClearAllPoints()
		if side and side == 'left' then
			shoppingTooltip2:SetPoint('TOPRIGHT', self, 'TOPLEFT', -8, -10)
		else
			shoppingTooltip2:SetPoint('TOPLEFT', self, 'TOPRIGHT', 8, -10)
		end

		shoppingTooltip1:SetOwner(self, 'ANCHOR_NONE')
		shoppingTooltip1:ClearAllPoints()

		if side and side == 'left' then
			shoppingTooltip1:SetPoint('TOPRIGHT', shoppingTooltip2, 'TOPLEFT', -8, 0)
		else
			shoppingTooltip1:SetPoint('TOPLEFT', shoppingTooltip2, 'TOPRIGHT', 8, 0)
		end
	else
		shoppingTooltip1:SetOwner(self, 'ANCHOR_NONE')
		shoppingTooltip1:ClearAllPoints()

		if side and side == 'left' then
			shoppingTooltip1:SetPoint('TOPRIGHT', self, 'TOPLEFT', -8, -10)
		else
			shoppingTooltip1:SetPoint('TOPLEFT', self, 'TOPRIGHT', 8, -10)
		end

		shoppingTooltip2:Hide()
	end

	shoppingTooltip1:SetCompareItem(shoppingTooltip2, self)
	shoppingTooltip1:Show()
end)

-- reskin tooltips
local function getBackdrop(self) return self.bg:GetBackdrop() end
local function getBackdropColor() return 0, 0, 0, .75 end
local function getBackdropBorderColor() return 0, 0, 0 end

function F:ReskinTooltip()
	if not self then
		if C.general.isDeveloper then print("Unknown tooltip spotted.") end
		return
	end
	if self:IsForbidden() then return end
	self:SetScale(1)

	if not self.tipStyled then
		self:SetBackdrop(nil)
		self:DisableDrawLayer("BACKGROUND")
		self.bg = F.CreateBDFrame(self)
		self.glow = F.CreateSD(self.bg, .5, 4, 4)

		self.GetBackdrop = getBackdrop
		self.GetBackdropColor = getBackdropColor
		self.GetBackdropBorderColor = getBackdropBorderColor
		
		self.tipStyled = true
	end

	if self.glow then
		self.glow:SetBackdropBorderColor(0, 0, 0, .5)
	end
	self.bg:SetBackdropBorderColor(0, 0, 0)

	if C.tooltip.enable and C.tooltip.borderColor and self.GetItem then
		local _, item = self:GetItem()
		if item then
			local quality = select(3, GetItemInfo(item))
			local color = BAG_ITEM_QUALITY_COLORS[quality or 1]
			if color then
				if self.glow then
					self.glow:SetBackdropBorderColor(color.r, color.g, color.b, .5)
				else
					self.bg:SetBackdropBorderColor(color.r, color.g, color.b)
				end
			end
		end
	end
end

hooksecurefunc("GameTooltip_SetBackdropStyle", function(self)
	if not self.tipStyled then return end
	self:SetBackdrop(nil)
end)


-- position
local mover
hooksecurefunc('GameTooltip_SetDefaultAnchor', function(tooltip, parent)
	if C.tooltip.cursor then
		tooltip:SetOwner(parent, 'ANCHOR_CURSOR_RIGHT')
	else
		if not mover then
			mover = F.Mover(tooltip, L['MOVER_TOOLTIP'], 'GameTooltip', C.tooltip.position, 240, 120)
		end
		tooltip:SetOwner(parent, 'ANCHOR_NONE')
		tooltip:ClearAllPoints()
		tooltip:SetPoint('BOTTOMRIGHT', mover)
	end
end)



