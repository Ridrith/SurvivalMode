local addonName, ns = ...
local SurvivalMode = ns.SurvivalMode
local LSM = ns.LSM or LibStub("LibSharedMedia-3.0", true)

-- Color palette for dark fantasy theme
local COLORS = {
    -- Primary colors
    darkGold = {0.75, 0.61, 0.42, 1},      -- #BF9B6B
    bloodRed = {0.54, 0.16, 0.16, 1},      -- #8A2929
    deepPurple = {0.29, 0.18, 0.36, 1},    -- #4A2E5C
    shadowGrey = {0.15, 0.15, 0.17, 1},    -- #262628
    
    -- Accent colors
    etherealBlue = {0.42, 0.67, 0.84, 1},  -- #6BABD6
    venomGreen = {0.31, 0.62, 0.47, 1},    -- #4F9E78
    ashWhite = {0.87, 0.86, 0.84, 1},      -- #DDDBD6
    boneWhite = {0.93, 0.91, 0.87, 1},     -- #EDE8DE
    
    -- Status colors
    hunger = {0.82, 0.52, 0.25, 1},        -- Warm orange-brown
    thirst = {0.31, 0.62, 0.78, 1},        -- Deep water blue
    fatigue = {0.58, 0.42, 0.68, 1},       -- Mystical purple
}

function SurvivalMode:CreateUI()
    -- Check if frame already exists
    if self.mainFrame then return end
    
    -- Main Frame
    local frame = CreateFrame("Frame", "SurvivalModeFrame", UIParent, "BackdropTemplate")
    frame:SetSize(280, 140)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    frame:SetBackdropColor(0, 0, 0, 0.8)
    frame:SetMovable(not self.db.profile.ui.locked)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, _, x, y = self:GetPoint()
        SurvivalMode.db.profile.ui.position.point = point
        SurvivalMode.db.profile.ui.position.x = x
        SurvivalMode.db.profile.ui.position.y = y
    end)
    
    -- Title
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", frame, "TOP", 0, -15)
    title:SetText("SURVIVAL MODE")
    title:SetTextColor(COLORS.darkGold[1], COLORS.darkGold[2], COLORS.darkGold[3])
    
    -- Create status bars with proper positioning
    self:CreateStatusBar(frame, "Hunger", COLORS.hunger, 35)
    self:CreateStatusBar(frame, "Thirst", COLORS.thirst, 60)
    self:CreateStatusBar(frame, "Fatigue", COLORS.fatigue, 85)
    
    -- Temperature display - properly positioned at bottom
    local tempText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    tempText:SetPoint("BOTTOM", frame, "BOTTOM", 0, 15)
    frame.temperatureText = tempText
    
    -- Close button
    local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
    closeButton:SetScript("OnClick", function() frame:Hide() end)
    
    self.mainFrame = frame
    
    -- Apply saved position
    local pos = self.db.profile.ui.position
    frame:SetPoint(pos.point, UIParent, pos.point, pos.x, pos.y)
    
    -- Apply UI settings
    self:UpdateUISettings()
end

function SurvivalMode:CreateStatusBar(parent, statType, color, yOffset)
    local barName = statType:lower()
    
    -- Container frame
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(240, 20)
    container:SetPoint("TOP", parent, "TOP", 0, -yOffset)
    
    -- Background
    local bg = container:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.1, 0.1, 0.1, 0.8)
    
    -- Status bar
    local bar = CreateFrame("StatusBar", nil, container)
    bar:SetAllPoints()
    bar:SetStatusBarTexture(LSM and LSM:Fetch("statusbar", self.db.profile.ui.barTexture) or "Interface\\TargetingFrame\\UI-StatusBar")
    bar:SetStatusBarColor(color[1], color[2], color[3])
    bar:SetMinMaxValues(0, 100)
    bar:SetValue(self.db.profile.stats[barName] or 100)
    
    -- Border
    local border = CreateFrame("Frame", nil, container, "BackdropTemplate")
    border:SetAllPoints()
    border:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    border:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
    
    -- Icon on the left side
    local icon = container:CreateTexture(nil, "ARTWORK")
    icon:SetSize(16, 16)
    icon:SetPoint("LEFT", container, "LEFT", 4, 0)
    
    if statType == "Hunger" then
        icon:SetTexture("Interface\\Icons\\inv_misc_food_15")
    elseif statType == "Thirst" then
        icon:SetTexture("Interface\\Icons\\inv_drink_10")
    elseif statType == "Fatigue" then
        icon:SetTexture("Interface\\Icons\\spell_shadow_escapedarkness")
    end
    
    -- Label (after icon)
    if self.db.profile.ui.showLabels then
        local label = bar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        label:SetPoint("LEFT", icon, "RIGHT", 4, 0)
        label:SetText(statType:upper())
        label:SetTextColor(COLORS.ashWhite[1], COLORS.ashWhite[2], COLORS.ashWhite[3])
        bar.label = label
    end
    
    -- Value text (on the right)
    local valueText = bar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    valueText:SetPoint("RIGHT", bar, "RIGHT", -5, 0)
    valueText:SetText(string.format("%.0f%%", self.db.profile.stats[barName] or 100))
    valueText:SetTextColor(COLORS.ashWhite[1], COLORS.ashWhite[2], COLORS.ashWhite[3])
    bar.valueText = valueText
    
    -- Pulse animation for low values
    local ag = bar:CreateAnimationGroup()
    local pulse = ag:CreateAnimation("Alpha")
    pulse:SetFromAlpha(1)
    pulse:SetToAlpha(0.5)
    pulse:SetDuration(0.5)
    pulse:SetSmoothing("IN_OUT")
    ag:SetLooping("BOUNCE")
    bar.pulseAnim = ag
    
    -- Store references
    parent[barName .. "Bar"] = bar
    parent[barName .. "Container"] = container
    parent[barName .. "Icon"] = icon
end

function SurvivalMode:UpdateUISettings()
    if not self.mainFrame then return end
    
    local settings = self.db.profile.ui
    self.mainFrame:SetScale(settings.scale)
    self.mainFrame:SetAlpha(settings.alpha)
    self.mainFrame:SetMovable(not settings.locked)
    
    -- Update bar textures
    for _, statType in ipairs({"hunger", "thirst", "fatigue"}) do
        local bar = self.mainFrame[statType .. "Bar"]
        if bar then
            bar:SetStatusBarTexture(LSM and LSM:Fetch("statusbar", settings.barTexture) or "Interface\\TargetingFrame\\UI-StatusBar")
            
            -- Update font
            if bar.label then
                local font = LSM and LSM:Fetch("font", settings.font) or "Fonts\\FRIZQT__.TTF"
                bar.label:SetFont(font, settings.fontSize)
                bar.label:SetShown(settings.showLabels)
            end
            if bar.valueText then
                local font = LSM and LSM:Fetch("font", settings.font) or "Fonts\\FRIZQT__.TTF"
                bar.valueText:SetFont(font, settings.fontSize)
            end
        end
    end
end

function SurvivalMode:UpdateStatusBars()
    if not self.mainFrame or not self.mainFrame:IsShown() then return end
    
    local stats = self.db.profile.stats
    
    -- Update each bar
    for statType, value in pairs(stats) do
        local bar = self.mainFrame[statType .. "Bar"]
        local icon = self.mainFrame[statType .. "Icon"]
        
        if bar and statType ~= "temperature" then
            bar:SetValue(value)
            bar.valueText:SetText(string.format("%.0f%%", value))
            
            -- Pulse animation and color changes for low values
            if value < 20 then
                if not bar.pulseAnim:IsPlaying() then
                    bar.pulseAnim:Play()
                end
                bar:SetStatusBarColor(1, 0, 0) -- Red for critical
                if icon then
                    icon:SetVertexColor(1, 0.3, 0.3)
                end
            elseif value < 40 then
                if bar.pulseAnim:IsPlaying() then
                    bar.pulseAnim:Stop()
                end
                bar:SetAlpha(1)
                bar:SetStatusBarColor(1, 0.5, 0) -- Orange for warning
                if icon then
                    icon:SetVertexColor(1, 0.7, 0.3)
                end
            else
                if bar.pulseAnim:IsPlaying() then
                    bar.pulseAnim:Stop()
                end
                bar:SetAlpha(1)
                -- Reset to original color
                local color = COLORS[statType]
                if color then
                    bar:SetStatusBarColor(color[1], color[2], color[3])
                end
                if icon then
                    icon:SetVertexColor(1, 1, 1)
                end
            end
        end
    end
    
    -- Update temperature with proper formatting and color
    if self.mainFrame.temperatureText then
        local temp = stats.temperature
        local category, colorCode = self:GetTemperatureCategory(temp)
        local tempString = self:GetTemperatureString(temp)
        
        self.mainFrame.temperatureText:SetText(string.format("%sTemperature: %s|r", colorCode, tempString))
        
        -- Add warning for extreme temperatures
        if category == "freezing" then
            self.mainFrame.temperatureText:SetText(self.mainFrame.temperatureText:GetText() .. " |cff00ccff[FREEZING]|r")
        elseif category == "extreme_heat" then
            self.mainFrame.temperatureText:SetText(self.mainFrame.temperatureText:GetText() .. " |cffff0000[EXTREME HEAT]|r")
        end
    end
end

function SurvivalMode:ToggleUI()
    if self.mainFrame then
        if self.mainFrame:IsShown() then
            self.mainFrame:Hide()
        else
            self.mainFrame:Show()
            self:UpdateStatusBars()
        end
    else
        -- Create UI if it doesn't exist
        self:CreateUI()
        if self.mainFrame then
            self.mainFrame:Show()
            self:UpdateStatusBars()
        end
    end
end

function SurvivalMode:ResetStats()
    self.db.profile.stats.hunger = 100
    self.db.profile.stats.thirst = 100
    self.db.profile.stats.fatigue = 100
    self:UpdateStatusBars()
    self:Print("All survival stats have been reset to 100%")
end