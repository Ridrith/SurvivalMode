local addonName, ns = ...
local SurvivalMode = ns.SurvivalMode

function SurvivalMode:InitializeTutorial()
    -- Check if first time user
    if self.db.profile.tutorialCompleted then
        return
    end
    
    -- Start tutorial after a short delay
    C_Timer.After(3, function()
        self:StartTutorial()
    end)
end

function SurvivalMode:StartTutorial()
    local steps = {
        {
            title = "Welcome to Survival Mode!",
            text = "This addon adds survival mechanics to World of Warcraft. You'll need to manage hunger, thirst, fatigue, and temperature to stay alive.",
            anchor = self.mainFrame,
            position = "RIGHT",
        },
        {
            title = "Your Survival Stats",
            text = "These bars show your hunger (orange), thirst (blue), and fatigue (yellow). Keep them above 20% to avoid penalties!",
            anchor = self.bars.hunger.frame,
            position = "RIGHT",
        },
        {
            title = "Eating and Drinking",
            text = "Consume food to restore hunger and drinks to restore thirst. Different quality items restore different amounts.",
            anchor = self.bars.thirst.frame,
            position = "RIGHT",
        },
        {
            title = "Resting",
            text = "Use /sm sleep to rest and restore fatigue. Sleeping in inns or cities provides better recovery!",
            anchor = self.bars.fatigue.frame,
            position = "RIGHT",
        },
        {
            title = "Temperature",
            text = "Your body temperature affects your survival. Use campfires, shelter, or find indoor areas to regulate temperature.",
            anchor = self.tempText,
            position = "BOTTOM",
        },
        {
            title = "Commands",
            text = "Type /sm to see all available commands. Use /sm config to customize your experience. Good luck surviving!",
            anchor = self.mainFrame,
            position = "RIGHT",
        },
    }
    
    self.tutorialStep = 1
    self.tutorialSteps = steps
    
    -- Create tutorial frame
    self:CreateTutorialFrame()
    self:ShowTutorialStep()
end

function SurvivalMode:CreateTutorialFrame()
    local frame = CreateFrame("Frame", "SurvivalModeTutorial", UIParent, "BackdropTemplate")
    frame:SetSize(300, 150)
    frame:SetFrameStrata("DIALOG")
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    
    -- Glow effect
    frame.glow = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.glow:SetPoint("TOPLEFT", -10, 10)
    frame.glow:SetPoint("BOTTOMRIGHT", 10, -10)
    frame.glow:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
    })
    frame.glow:SetBackdropBorderColor(1, 0.8, 0, 1)
    
    -- Title
    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.title:SetPoint("TOP", 0, -20)
    frame.title:SetTextColor(1, 0.8, 0)
    
    -- Text
    frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.text:SetPoint("LEFT", 20, 0)
    frame.text:SetPoint("RIGHT", -20, 0)
    frame.text:SetJustifyH("CENTER")
    frame.text:SetJustifyV("MIDDLE")
    
    -- Next button
    frame.nextButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.nextButton:SetSize(80, 25)
    frame.nextButton:SetPoint("BOTTOMRIGHT", -20, 20)
    frame.nextButton:SetText("Next")
    frame.nextButton:SetScript("OnClick", function()
        self:NextTutorialStep()
    end)
    
    -- Skip button
    frame.skipButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.skipButton:SetSize(80, 25)
    frame.skipButton:SetPoint("BOTTOMLEFT", 20, 20)
    frame.skipButton:SetText("Skip Tutorial")
    frame.skipButton:SetScript("OnClick", function()
        self:EndTutorial()
    end)
    
    self.tutorialFrame = frame
end

function SurvivalMode:ShowTutorialStep()
    local step = self.tutorialSteps[self.tutorialStep]
    if not step then
        self:EndTutorial()
        return
    end
    
    local frame = self.tutorialFrame
    frame.title:SetText(step.title)
    frame.text:SetText(step.text)
    
    -- Position relative to anchor
    frame:ClearAllPoints()
    if step.anchor and step.anchor:IsVisible() then
        if step.position == "RIGHT" then
            frame:SetPoint("LEFT", step.anchor, "RIGHT", 20, 0)
        elseif step.position == "LEFT" then
            frame:SetPoint("RIGHT", step.anchor, "LEFT", -20, 0)
        elseif step.position == "TOP" then
            frame:SetPoint("BOTTOM", step.anchor, "TOP", 0, 20)
        elseif step.position == "BOTTOM" then
            frame:SetPoint("TOP", step.anchor, "BOTTOM", 0, -20)
        end
    else
        frame:SetPoint("CENTER", 0, 0)
    end
    
    -- Update button text
    if self.tutorialStep >= #self.tutorialSteps then
        frame.nextButton:SetText("Finish")
    else
        frame.nextButton:SetText("Next")
    end
    
    frame:Show()
end

function SurvivalMode:NextTutorialStep()
    self.tutorialStep = self.tutorialStep + 1
    
    if self.tutorialStep > #self.tutorialSteps then
        self:EndTutorial()
    else
        self:ShowTutorialStep()
    end
end

function SurvivalMode:EndTutorial()
    self.db.profile.tutorialCompleted = true
    if self.tutorialFrame then
        self.tutorialFrame:Hide()
    end
    self:Print("|cff00ff00Tutorial Complete!|r You're ready to survive in Azeroth. Good luck!")
end