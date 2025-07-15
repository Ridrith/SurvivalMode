local addonName, ns = ...
local SurvivalMode = ns.SurvivalMode

-- Sound IDs for various events
SurvivalMode.SOUNDS = {
    WARNING = 8959,  -- RaidWarning
    CRITICAL = 8960, -- PVPWarningHorde
    EAT = 1022,      -- Eating sound
    DRINK = 2426,    -- Drinking sound
    SLEEP = 25477,   -- Sleeping sound
    LEVELUP = 888,   -- Level up sound
    CRAFT = 3336,    -- Crafting sound
}

function SurvivalMode:InitializeNotifications()
    -- Create notification frame
    self:CreateNotificationFrame()
end

function SurvivalMode:CreateNotificationFrame()
    local frame = CreateFrame("Frame", "SurvivalModeNotifications", UIParent)
    frame:SetSize(400, 100)
    frame:SetPoint("TOP", 0, -200)
    frame:SetFrameStrata("HIGH")
    frame:Hide()
    
    -- Background
    frame.bg = frame:CreateTexture(nil, "BACKGROUND")
    frame.bg:SetAllPoints()
    frame.bg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    frame.bg:SetVertexColor(0, 0, 0, 0.8)
    
    -- Icon
    frame.icon = frame:CreateTexture(nil, "ARTWORK")
    frame.icon:SetSize(64, 64)
    frame.icon:SetPoint("LEFT", 20, 0)
    
    -- Title
    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.title:SetPoint("TOPLEFT", frame.icon, "TOPRIGHT", 10, -10)
    
    -- Text
    frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.text:SetPoint("TOPLEFT", frame.title, "BOTTOMLEFT", 0, -5)
    frame.text:SetWidth(300)
    frame.text:SetJustifyH("LEFT")
    
    self.notificationFrame = frame
end

function SurvivalMode:ShowNotification(title, text, icon, duration, soundID)
    if not self.notificationFrame then
        self:CreateNotificationFrame()
    end
    
    local frame = self.notificationFrame
    
    -- Update content
    frame.title:SetText(title)
    frame.text:SetText(text)
    frame.icon:SetTexture(icon)
    
    -- Play sound
    if soundID and self.db.profile.effects.soundEffects then
        PlaySound(soundID, "Master")
    end
    
    -- Show with fade in
    frame:Show()
    frame:SetAlpha(0)
    
    local fadeIn = frame:CreateAnimationGroup()
    local alpha1 = fadeIn:CreateAnimation("Alpha")
    alpha1:SetFromAlpha(0)
    alpha1:SetToAlpha(1)
    alpha1:SetDuration(0.5)
    
    -- Auto hide after duration
    fadeIn:SetScript("OnFinished", function()
        C_Timer.After(duration or 3, function()
            local fadeOut = frame:CreateAnimationGroup()
            local alpha2 = fadeOut:CreateAnimation("Alpha")
            alpha2:SetFromAlpha(1)
            alpha2:SetToAlpha(0)
            alpha2:SetDuration(0.5)
            
            fadeOut:SetScript("OnFinished", function()
                frame:Hide()
            end)
            
            fadeOut:Play()
        end)
    end)
    
    fadeIn:Play()
end

-- Stat warnings
function SurvivalMode:CheckWarnings()
    local stats = self.db.profile.stats
    local warnings = {}
    
    -- Hunger warnings
    if stats.hunger <= 10 then
        table.insert(warnings, {
            stat = "hunger",
            level = "critical",
            title = "STARVING!",
            text = "Find food immediately or you will die!",
            icon = "Interface\\Icons\\INV_Misc_Food_15",
            sound = self.SOUNDS.CRITICAL
        })
    elseif stats.hunger <= 25 then
        table.insert(warnings, {
            stat = "hunger",
            level = "warning",
            title = "Very Hungry",
            text = "You need to eat soon.",
            icon = "Interface\\Icons\\INV_Misc_Food_15",
            sound = self.SOUNDS.WARNING
        })
    end
    
    -- Thirst warnings
    if stats.thirst <= 10 then
        table.insert(warnings, {
            stat = "thirst",
            level = "critical",
            title = "DEHYDRATED!",
            text = "Find water immediately or you will die!",
            icon = "Interface\\Icons\\INV_Drink_10",
            sound = self.SOUNDS.CRITICAL
        })
    elseif stats.thirst <= 25 then
        table.insert(warnings, {
            stat = "thirst",
            level = "warning",
            title = "Very Thirsty",
            text = "You need to drink soon.",
            icon = "Interface\\Icons\\INV_Drink_10",
            sound = self.SOUNDS.WARNING
        })
    end
    
    -- Fatigue warnings
    if stats.fatigue <= 10 then
        table.insert(warnings, {
            stat = "fatigue",
            level = "critical",
            title = "EXHAUSTED!",
            text = "Rest immediately or you will collapse!",
            icon = "Interface\\Icons\\Spell_Nature_Sleep",
            sound = self.SOUNDS.CRITICAL
        })
    elseif stats.fatigue <= 25 then
        table.insert(warnings, {
            stat = "fatigue",
            level = "warning",
            title = "Very Tired",
            text = "You need to rest soon.",
            icon = "Interface\\Icons\\Spell_Nature_Sleep",
            sound = self.SOUNDS.WARNING
        })
    end
    
    -- Show most critical warning
    local mostCritical = nil
    for _, warning in ipairs(warnings) do
        if warning.level == "critical" then
            mostCritical = warning
            break
        elseif not mostCritical then
            mostCritical = warning
        end
    end
    
    -- Throttle warnings (don't spam)
    if mostCritical and (not self.lastWarningTime or GetTime() - self.lastWarningTime > 30) then
        self:ShowNotification(mostCritical.title, mostCritical.text, mostCritical.icon, 5, mostCritical.sound)
        self.lastWarningTime = GetTime()
    end
end