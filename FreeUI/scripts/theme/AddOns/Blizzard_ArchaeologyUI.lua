local F, C = unpack(select(2, ...))

C.themes["Blizzard_ArchaeologyUI"] = function()
	F.ReskinPortraitFrame(ArchaeologyFrame)
	ArchaeologyFrame:DisableDrawLayer("BACKGROUND")
	F.Reskin(ArchaeologyFrameArtifactPageSolveFrameSolveButton)
	F.Reskin(ArchaeologyFrameArtifactPageBackButton)

	ArchaeologyFrameSummaryPageTitle:SetTextColor(1, 1, 1)
	ArchaeologyFrameArtifactPageHistoryTitle:SetTextColor(1, 1, 1)
	ArchaeologyFrameArtifactPageHistoryScrollChildText:SetTextColor(1, 1, 1)
	ArchaeologyFrameHelpPageTitle:SetTextColor(1, 1, 1)
	ArchaeologyFrameHelpPageDigTitle:SetTextColor(1, 1, 1)
	ArchaeologyFrameHelpPageHelpScrollHelpText:SetTextColor(1, 1, 1)
	ArchaeologyFrameCompletedPage:GetRegions():SetTextColor(1, 1, 1)
	ArchaeologyFrameCompletedPageTitle:SetTextColor(1, 1, 1)
	ArchaeologyFrameCompletedPageTitleTop:SetTextColor(1, 1, 1)
	ArchaeologyFrameCompletedPageTitleMid:SetTextColor(1, 1, 1)
	ArchaeologyFrameCompletedPagePageText:SetTextColor(1, 1, 1)
	ArchaeologyFrameSummaryPagePageText:SetTextColor(1, 1, 1)

	for i = 1, ARCHAEOLOGY_MAX_RACES do
		_G["ArchaeologyFrameSummaryPageRace"..i]:GetRegions():SetTextColor(1, 1, 1)
	end

	for i = 1, ARCHAEOLOGY_MAX_COMPLETED_SHOWN do
		local bu = _G["ArchaeologyFrameCompletedPageArtifact"..i]
		bu:GetRegions():Hide()
		select(2, bu:GetRegions()):Hide()
		select(3, bu:GetRegions()):SetTexCoord(unpack(C.TexCoord))
		select(4, bu:GetRegions()):SetTextColor(1, 1, 1)
		select(5, bu:GetRegions()):SetTextColor(1, 1, 1)
		F.CreateBDFrame(bu, .25)
		local vline = CreateFrame("Frame", nil, bu)
		vline:SetPoint("LEFT", 44, 0)
		vline:SetSize(1, 44)
		F.CreateBD(vline)
	end

	ArchaeologyFrameInfoButton:SetPoint("TOPLEFT", 3, -3)

	ArchaeologyFrameSummarytButton:SetPoint("TOPLEFT", ArchaeologyFrame, "TOPRIGHT", 1, -50)
	ArchaeologyFrameSummarytButton:SetFrameLevel(ArchaeologyFrame:GetFrameLevel() - 1)
	ArchaeologyFrameCompletedButton:SetPoint("TOPLEFT", ArchaeologyFrame, "TOPRIGHT", 1, -120)
	ArchaeologyFrameCompletedButton:SetFrameLevel(ArchaeologyFrame:GetFrameLevel() - 1)

	F.ReskinDropDown(ArchaeologyFrameRaceFilter)
	F.ReskinScroll(ArchaeologyFrameArtifactPageHistoryScrollScrollBar)
	F.ReskinArrow(ArchaeologyFrameCompletedPagePrevPageButton, "left")
	F.ReskinArrow(ArchaeologyFrameCompletedPageNextPageButton, "right")
	ArchaeologyFrameCompletedPagePrevPageButtonIcon:Hide()
	ArchaeologyFrameCompletedPageNextPageButtonIcon:Hide()
	F.ReskinArrow(ArchaeologyFrameSummaryPagePrevPageButton, "left")
	F.ReskinArrow(ArchaeologyFrameSummaryPageNextPageButton, "right")
	ArchaeologyFrameSummaryPagePrevPageButtonIcon:Hide()
	ArchaeologyFrameSummaryPageNextPageButtonIcon:Hide()

	ArchaeologyFrameRankBarBorder:Hide()
	ArchaeologyFrameRankBarBackground:Hide()
	ArchaeologyFrameRankBarBar:SetTexture(C.media.backdrop)
	ArchaeologyFrameRankBarBar:SetGradient("VERTICAL", 0, .65, 0, 0, .75, 0)
	ArchaeologyFrameRankBar:SetHeight(14)
	F.CreateBD(ArchaeologyFrameRankBar, .25)

	ArchaeologyFrameArtifactPageSolveFrameStatusBarBarBG:Hide()
	local bar = select(3, ArchaeologyFrameArtifactPageSolveFrameStatusBar:GetRegions())
	bar:SetTexture(C.media.backdrop)
	bar:SetGradient("VERTICAL", .65, .25, 0, .75, .35, .1)
	F.CreateBDFrame(ArchaeologyFrameArtifactPageSolveFrameStatusBar, .25)

	ArchaeologyFrameArtifactPageIcon:SetTexCoord(unpack(C.TexCoord))
	F.CreateBG(ArchaeologyFrameArtifactPageIcon)
end