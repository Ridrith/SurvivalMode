local addonName, ns = ...
local SurvivalMode = ns.SurvivalMode

-- Color palette matching the main UI
local COLORS = {
    silver = {0.75, 0.75, 0.75, 1},          -- Silver instead of gold
    darkSilver = {0.5, 0.5, 0.5, 1},         -- Dark silver for borders
    deepPurple = {0.29, 0.18, 0.36, 1},
    moonBlue = {0.42, 0.67, 0.84, 1},
    dreamPurple = {0.58, 0.42, 0.68, 1},
    shadowGrey = {0.15, 0.15, 0.17, 1},
    ashWhite = {0.87, 0.86, 0.84, 1},
}

-- Sleep states
SurvivalMode.sleepState = {
    isSleeping = false,
    sleepStartTime = nil,
    sleepLocation = nil,
    qualityModifier = 1.0
}

-- Base sleep quality values
local SLEEP_QUALITY = {
    MAJOR_CITY = 2.5,       -- 250% - Best quality sleep in major cities
    TAVERN = 1.5,           -- 150% - Excellent quality in taverns/inns
    CITY = 1.2,             -- 120% - Good quality in smaller towns
    INDOORS = 0.8,          -- 80% - Decent quality
    SHELTER = 0.7,          -- 70% - Basic shelter
    OUTSIDE = 0.55,         -- 55% - Poor quality
    EXTREME_TEMP = 0.1,     -- 10% - Terrible quality
}

-- Major cities list
local MAJOR_CITIES = {
    -- Alliance
    ["Stormwind City"] = true,
    ["Ironforge"] = true,
    ["Darnassus"] = true,
    ["The Exodar"] = true,
    ["Gilneas City"] = true,
    ["Boralus"] = true,
    
    -- Horde
    ["Orgrimmar"] = true,
    ["Thunder Bluff"] = true,
    ["Undercity"] = true,
    ["Silvermoon City"] = true,
    ["Dazar'alor"] = true,
    
    -- Neutral
    ["Shattrath City"] = true,
    ["Dalaran"] = true,
    ["Valdrakken"] = true,
    ["Oribos"] = true,
}

function SurvivalMode:CalculateSleepQuality()
    local baseQuality = SLEEP_QUALITY.OUTSIDE -- Default to outside
    local qualityName = "Outside"
    local bonuses = {}
    
    -- Check temperature first (overrides other factors if extreme)
    local temp = self.db.profile.stats.temperature
    local tempF = temp  -- Already in Fahrenheit
    
    if tempF < 32 or tempF > 100 then
        -- Extreme temperatures make sleep nearly impossible
        baseQuality = SLEEP_QUALITY.EXTREME_TEMP
        if tempF < 32 then
            qualityName = "Freezing Cold"
        else
            qualityName = "Extreme Heat"
        end
    else
        -- Check location-based quality
        local zone = GetZoneText()
        local subZone = GetSubZoneText()
        
        -- Check if in a major city first
        if MAJOR_CITIES[zone] then
            baseQuality = SLEEP_QUALITY.MAJOR_CITY
            qualityName = "Major City"
        elseif IsResting() then
            -- Check if in a tavern/inn
            if subZone and (string.find(subZone:lower(), "inn") or 
                          string.find(subZone:lower(), "tavern") or
                          string.find(subZone:lower(), "rest") or
                          string.find(subZone:lower(), "hotel") or
                          string.find(subZone:lower(), "lodge")) then
                baseQuality = SLEEP_QUALITY.TAVERN
                qualityName = "Tavern/Inn"
            else
                baseQuality = SLEEP_QUALITY.CITY
                qualityName = "Town"
            end
        elseif IsIndoors() then
            baseQuality = SLEEP_QUALITY.INDOORS
            qualityName = "Indoors"
        elseif self:IsInShelter() then
            baseQuality = SLEEP_QUALITY.SHELTER
            qualityName = "Shelter"
        end
    end
    
    -- Apply modifiers
    local totalModifier = baseQuality
    
    -- Temperature comfort bonus (if not extreme)
    if tempF >= 60 and tempF <= 75 then
        totalModifier = totalModifier * 1.1
        table.insert(bonuses, "Comfortable Temperature (+10%)")
    elseif tempF >= 50 and tempF <= 85 then
        totalModifier = totalModifier * 1.05
        table.insert(bonuses, "Mild Temperature (+5%)")
    end
    
    -- Campfire bonus (less effective in cities)
    if self:IsNearCampfire() and baseQuality < SLEEP_QUALITY.CITY then
        totalModifier = totalModifier * 1.15
        table.insert(bonuses, "Campfire Warmth (+15%)")
    end
    
    -- Weather effects (would need weather API)
    -- For now, simulate with zone checks
    if zone and (string.find(zone:lower(), "rain") or string.find(zone:lower(), "storm")) then
        if baseQuality == SLEEP_QUALITY.OUTSIDE then
            totalModifier = totalModifier * 0.7
            table.insert(bonuses, "Rain/Storm (-30%)")
        end
    end
    
    -- Efficient Sleeper perk
    local sleepPerk = self:GetPerkRank("efficient_sleeper")
    if sleepPerk > 0 then
        local perkBonus = 0.05 * sleepPerk -- 5% per rank
        totalModifier = totalModifier * (1 + perkBonus)
        table.insert(bonuses, string.format("Efficient Sleeper (+%d%%)", math.floor(perkBonus * 100)))
        
        if self.db.profile.debug then
            self:DebugPrint(string.format("Efficient Sleeper rank %d: +%d%% sleep quality", 
                sleepPerk, math.floor(perkBonus * 100)))
        end
    end
    
    -- Apply general sleep quality multiplier from difficulty settings
    totalModifier = totalModifier * self.db.profile.difficulty.sleepQualityMultiplier
    
    -- Special zone bonuses
    if zone == "Moonglade" then
        totalModifier = totalModifier * 1.2
        table.insert(bonuses, "Druid Sanctuary (+20%)")
    elseif zone == "The Emerald Dream" then
        totalModifier = totalModifier * 1.3
        table.insert(bonuses, "Dream Realm (+30%)")
    end
    
    return totalModifier, qualityName, bonuses
end

function SurvivalMode:StartSleeping()
    if self.sleepState.isSleeping then
        self:Print("|cffffff00You are already sleeping!|r")
        return
    end
    
    if InCombatLockdown() then
        self:Print("|cffff0000You cannot sleep while in combat!|r")
        return
    end
    
    -- Check if player is moving
    if GetUnitSpeed("player") > 0 then
        self:Print("|cffff0000You must be standing still to sleep!|r")
        return
    end
    
    -- Calculate sleep quality
    local qualityModifier, locationName, bonuses = self:CalculateSleepQuality()
    
    -- Start sleeping
    self.sleepState.isSleeping = true
    self.sleepState.sleepStartTime = GetTime()
    self.sleepState.qualityModifier = qualityModifier
    self.sleepState.sleepLocation = GetZoneText()
    
    -- Apply sleep animation
    DoEmote("SLEEP")
    
    -- Apply visual effect
    self:ApplySleepEffect()
    
    -- Show sleep UI
    self:ShowSleepUI()
    
    self:Print(string.format("|cff00ff00You lie down to sleep... (%s)|r", locationName))
    if #bonuses > 0 then
        self:Print("Sleep modifiers: " .. table.concat(bonuses, ", "))
    end
    self:Print(string.format("Total sleep quality: %d%%", qualityModifier * 100))
    
    -- Special messages for high quality sleep
    if qualityModifier >= 2.0 then
        self:Print("|cff00ccffThe safety and comfort of the city provides excellent rest.|r")
    elseif qualityModifier >= 1.5 then
        self:Print("|cff00ff00The cozy atmosphere helps you relax deeply.|r")
    elseif qualityModifier < 0.5 then
        self:Print("|cffff0000WARNING: Extremely poor sleeping conditions!|r")
    elseif qualityModifier < 0.7 then
        self:Print("|cffffff00Poor sleeping conditions will reduce rest effectiveness.|r")
    end
    
    -- Start sleep timer
    self.sleepTimer = self:ScheduleRepeatingTimer("UpdateSleep", 1)
end

function SurvivalMode:StopSleeping()
    if not self.sleepState.isSleeping then
        self:Print("|cffffff00You are not sleeping!|r")
        return
    end
    
    -- Calculate fatigue restoration
    local sleepDuration = GetTime() - self.sleepState.sleepStartTime
    local minutesSlept = sleepDuration / 10
    
    -- Base restoration: 1% per minute, modified by quality
    local restoration = minutesSlept * self.sleepState.qualityModifier
    
    -- Apply restoration
    local stats = self.db.profile.stats
    local oldFatigue = stats.fatigue
    stats.fatigue = math.min(100, stats.fatigue + restoration)
    local actualRestoration = stats.fatigue - oldFatigue
    
    -- Stop sleeping
    self.sleepState.isSleeping = false
    
    -- Cancel timer
    if self.sleepTimer then
        self:CancelTimer(self.sleepTimer)
        self.sleepTimer = nil
    end
    
    -- Stand up
    DoEmote("STAND")
    
    -- Remove effects
    self:RemoveSleepEffect()
    self:HideSleepUI()
    
    -- Feedback
    self:Print(string.format("|cff00ff00You wake up after sleeping for %.1f minutes.|r", minutesSlept))
    self:Print(string.format("Restored %.1f%% fatigue (Sleep quality: %d%%)", 
        actualRestoration, self.sleepState.qualityModifier * 100))
    
    -- Special message for excellent sleep
    if self.sleepState.qualityModifier >= 2.0 then
        self:Print("|cff00ccffYou feel completely refreshed!|r")
    elseif self.sleepState.qualityModifier >= 1.5 then
        self:Print("|cff00ff00You had a very restful sleep.|r")
    end
    
    -- Update UI
    self:UpdateStatusBars()
end

function SurvivalMode:UpdateSleep()
    if not self.sleepState.isSleeping then return end
    
    -- Check if player moved
    if GetUnitSpeed("player") > 0 then
        self:Print("|cffffff00Your sleep was interrupted by movement!|r")
        self:StopSleeping()
        return
    end
    
    -- Check if in combat
    if InCombatLockdown() then
        self:Print("|cffff0000Your sleep was interrupted by combat!|r")
        self:StopSleeping()
        return
    end
    
    -- Restore fatigue gradually
    local stats = self.db.profile.stats
    local restoration = (1/60) * self.sleepState.qualityModifier -- 1% per minute * quality
    stats.fatigue = math.min(100, stats.fatigue + restoration)
    
    -- Update sleep UI
    self:UpdateSleepUI()
    
    -- Update status bars
    self:UpdateStatusBars()
    
    -- Check if fully rested
    if stats.fatigue >= 100 then
        self:Print("|cff00ff00You are fully rested!|r")
        self:StopSleeping()
    end
end

function SurvivalMode:ApplySleepEffect()
    -- Create a sleep animation/effect with dark fantasy theme
    if not self.sleepFrame then
        self.sleepFrame = CreateFrame("Frame", nil, UIParent)
        self.sleepFrame:SetAllPoints()
        self.sleepFrame:SetFrameStrata("HIGH")
        
        -- Dark overlay (not pure black, semi-transparent)
        local tex = self.sleepFrame:CreateTexture(nil, "BACKGROUND")
        tex:SetAllPoints()
        tex:SetColorTexture(0, 0, 0, 0)
        self.sleepFrame.texture = tex
        
        -- Fade in animation
        self.sleepFrame.fadeIn = self.sleepFrame:CreateAnimationGroup()
        local fadeIn = self.sleepFrame.fadeIn:CreateAnimation("Alpha")
        fadeIn:SetTarget(tex)
        fadeIn:SetFromAlpha(0)
        fadeIn:SetToAlpha(0.5)  -- Only 50% opacity, not fully black
        fadeIn:SetDuration(3)
        
        -- Fade out animation
        self.sleepFrame.fadeOut = self.sleepFrame:CreateAnimationGroup()
        local fadeOut = self.sleepFrame.fadeOut:CreateAnimation("Alpha")
        fadeOut:SetTarget(tex)
        fadeOut:SetFromAlpha(0.5)
        fadeOut:SetToAlpha(0)
        fadeOut:SetDuration(1.5)
    end
    
    self.sleepFrame:Show()
    self.sleepFrame.fadeIn:Play()
end

function SurvivalMode:RemoveSleepEffect()
    if self.sleepFrame then
        self.sleepFrame.fadeOut:Play()
        C_Timer.After(1.5, function()
            self.sleepFrame:Hide()
        end)
    end
end

function SurvivalMode:ShowSleepUI()
    if not self.sleepUIFrame then
        local frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
        frame:SetSize(280, 200)  -- Increased height to accommodate button
        frame:SetPoint("CENTER", 0, 150)
        
        -- Dark backdrop matching main UI
        frame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 32,
            edgeSize = 32,
            insets = { left = 11, right = 12, top = 12, bottom = 11 }
        })
        frame:SetBackdropColor(0, 0, 0, 0.8)  -- Match main UI darkness
        frame:SetBackdropBorderColor(COLORS.darkSilver[1], COLORS.darkSilver[2], COLORS.darkSilver[3], 1)
        
        -- Sleep icon frame (simple, no border)
        local iconFrame = CreateFrame("Frame", nil, frame, "BackdropTemplate")
        iconFrame:SetSize(48, 48)
        iconFrame:SetPoint("TOP", frame, "TOP", 0, -20)
        iconFrame:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = false,
            edgeSize = 8,
            insets = { left = 2, right = 2, top = 2, bottom = 2 }
        })
        iconFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
        iconFrame:SetBackdropBorderColor(COLORS.darkSilver[1], COLORS.darkSilver[2], COLORS.darkSilver[3], 0.5)
        
        -- Sleep icon
        local sleepIcon = iconFrame:CreateTexture(nil, "ARTWORK")
        sleepIcon:SetSize(40, 40)
        sleepIcon:SetPoint("CENTER")
        sleepIcon:SetTexture("Interface\\Icons\\Sha_ability_rogue_bloodyeye")  -- Using a bed/pillow-like icon
        sleepIcon:SetDesaturated(true)
        sleepIcon:SetVertexColor(COLORS.moonBlue[1], COLORS.moonBlue[2], COLORS.moonBlue[3])
        
        -- Title
        local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        title:SetPoint("TOP", iconFrame, "BOTTOM", 0, -5)
        title:SetText("RESTING")
        title:SetTextColor(COLORS.silver[1], COLORS.silver[2], COLORS.silver[3])
        
        -- Create dreamy Zzz particles
        for i = 1, 3 do
            local zzz = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            zzz:SetPoint("LEFT", title, "RIGHT", 5 + (i * 12), 0)
            zzz:SetText("z")
            zzz:SetTextColor(COLORS.dreamPurple[1], COLORS.dreamPurple[2], COLORS.dreamPurple[3], 0.8)
            
            local zzzAnim = zzz:CreateAnimationGroup()
            local zzzMove = zzzAnim:CreateAnimation("Translation")
            zzzMove:SetOffset(8, 25)
            zzzMove:SetDuration(3 + i*0.5)
            local zzzAlpha = zzzAnim:CreateAnimation("Alpha")
            zzzAlpha:SetFromAlpha(0.8)
            zzzAlpha:SetToAlpha(0)
            zzzAlpha:SetDuration(3 + i*0.5)
            zzzAlpha:SetStartDelay(0.5 * i)
            zzzAnim:SetLooping("REPEAT")
            zzzAnim:Play()
        end
        
        -- Progress bar container matching main UI style
        local progressContainer = CreateFrame("Frame", nil, frame, "BackdropTemplate")
        progressContainer:SetSize(240, 20)
        progressContainer:SetPoint("TOP", title, "BOTTOM", 0, -15)
        progressContainer:SetBackdrop({
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 12,
            insets = { left = 2, right = 2, top = 2, bottom = 2 }
        })
        progressContainer:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
        
        -- Progress bar background
        local progressBg = progressContainer:CreateTexture(nil, "BACKGROUND")
        progressBg:SetAllPoints()
        progressBg:SetColorTexture(0.1, 0.1, 0.1, 0.8)
        
        -- Progress bar
        local progressBar = CreateFrame("StatusBar", nil, progressContainer)
        progressBar:SetAllPoints()
        progressBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
        progressBar:SetMinMaxValues(0, 100)
        progressBar:SetStatusBarColor(COLORS.dreamPurple[1], COLORS.dreamPurple[2], COLORS.dreamPurple[3])
        
        frame.progressBar = progressBar
        
        -- Status text
        local status = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        status:SetPoint("TOP", progressContainer, "BOTTOM", 0, -5)
        status:SetTextColor(COLORS.ashWhite[1], COLORS.ashWhite[2], COLORS.ashWhite[3])
        status:SetWidth(240)
        frame.status = status
        
        -- Quality text
        local qualityText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        qualityText:SetPoint("TOP", status, "BOTTOM", 0, -8)
        frame.qualityText = qualityText
        
        -- Wake up button - positioned at the very bottom with more space
        local wakeButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        wakeButton:SetSize(100, 25)
        wakeButton:SetPoint("BOTTOM", frame, "BOTTOM", 0, 15)
        wakeButton:SetText("Wake Up")
        
        -- Button styling
        wakeButton:GetFontString():SetTextColor(COLORS.ashWhite[1], COLORS.ashWhite[2], COLORS.ashWhite[3])
        
        -- Button hover effect
        wakeButton:SetScript("OnEnter", function(self)
            self:GetFontString():SetTextColor(1, 1, 1)
        end)
        wakeButton:SetScript("OnLeave", function(self)
            self:GetFontString():SetTextColor(COLORS.ashWhite[1], COLORS.ashWhite[2], COLORS.ashWhite[3])
        end)
        
        wakeButton:SetScript("OnClick", function()
            SurvivalMode:StopSleeping()
        end)
        
        self.sleepUIFrame = frame
    end
    
    self.sleepUIFrame:Show()
    self:UpdateSleepUI()
end

function SurvivalMode:HideSleepUI()
    if self.sleepUIFrame then
        self.sleepUIFrame:Hide()
    end
end

function SurvivalMode:UpdateSleepUI()
    if not self.sleepUIFrame or not self.sleepUIFrame:IsShown() then return end
    
    local sleepDuration = GetTime() - self.sleepState.sleepStartTime
    local minutesSlept = sleepDuration / 60
    local stats = self.db.profile.stats
    
    -- Update progress bar
    self.sleepUIFrame.progressBar:SetValue(stats.fatigue)
    
    -- Update status text
    self.sleepUIFrame.status:SetText(string.format(
        "Time: %d:%02d | Fatigue: %.1f%%",
        math.floor(minutesSlept),
        math.floor((minutesSlept % 1) * 60),
        stats.fatigue
    ))
    
    -- Update quality text with color
    local quality = self.sleepState.qualityModifier * 100
    local r, g, b = 1, 1, 1
    if quality >= 200 then
        r, g, b = COLORS.moonBlue[1], COLORS.moonBlue[2], COLORS.moonBlue[3]
    elseif quality >= 150 then
        r, g, b = 0.3, 0.9, 0.3
    elseif quality >= 100 then
        r, g, b = 0.7, 0.9, 0.3
    elseif quality >= 60 then
        r, g, b = 1, 0.9, 0.3
    elseif quality >= 40 then
        r, g, b = 1, 0.5, 0
    else
        r, g, b = 0.8, 0.2, 0.2
    end
    
    self.sleepUIFrame.qualityText:SetText(string.format("Sleep Quality: %d%%", quality))
    self.sleepUIFrame.qualityText:SetTextColor(r, g, b)
end

function SurvivalMode:RestoreFatigue(amount)
    local stats = self.db.profile.stats
    stats.fatigue = math.min(100, stats.fatigue + amount)
    self:UpdateStatusBars()
end