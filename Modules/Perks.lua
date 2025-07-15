local addonName, ns = ...
local SurvivalMode = ns.SurvivalMode

-- Enhanced Perk Icon Mappings - Only for perks that actually work
local PERK_ICONS = {
    -- Tier 1 - Basic Survival
    iron_stomach = 134062,        -- Meat icon
    hydration_expert = 134797,    -- Water droplet
    efficient_sleeper = 134339,   -- Bed/Sleep icon
    temperature_resilience = 135865, -- Fire resistance
    hardy_constitution = 136116,  -- Constitution/resilience icon
    
    -- Tier 2 - Intermediate Skills
    survival_instinct = 136094,   -- Survival icon
    cold_adaptation = 135840,     -- Frost resistance
    heat_tolerance = 135817,      -- Fire protection
    combat_endurance = 132347,    -- Stamina/endurance icon
    master_survivor = 236215,     -- Achievement star
    
    -- Tier 3 - Advanced Techniques
    wilderness_expert = 136025,   -- Nature mastery
    arctic_survivor = 135843,     -- Ice mastery
    desert_nomad = 135818,        -- Fire mastery
    metabolic_efficiency = 136048, -- Efficiency icon
    shelter_master = 135934,      -- Construction icon
    
    -- Tier 4 - Master Level
    apex_survivor = 132484,       -- Dragon aspect
    temperature_master = 136116,  -- Elemental mastery
    survivalist_legend = 236218,  -- Legendary achievement
}

-- Enhanced experience thresholds for more progression
local PERK_POINT_THRESHOLDS = {
    2000,    -- 1st point (easier start)
    4500,    -- 2nd point
    7500,    -- 3rd point
    11000,   -- 4th point
    15000,   -- 5th point (end tier 1)
    20000,   -- 6th point (start tier 2)
    26000,   -- 7th point
    33000,   -- 8th point
    41000,   -- 9th point
    50000,   -- 10th point (end tier 2)
    60000,   -- 11th point (start tier 3)
    72000,   -- 12th point
    86000,   -- 13th point
    102000,  -- 14th point
    120000,  -- 15th point (end tier 3)
    140000,  -- 16th point (start tier 4)
    165000,  -- 17th point
    195000,  -- 18th point (master level)
}

function SurvivalMode:InitializePerkSystem()
    -- Initialize perks data with all required fields
    if not self.db.profile.perks then
        self.db.profile.perks = {
            selected = {},
            points = 0,
            experience = 0,
            totalPointsEarned = 0,
        }
    else
        -- Ensure all fields exist for existing saves
        self.db.profile.perks.selected = self.db.profile.perks.selected or {}
        self.db.profile.perks.points = self.db.profile.perks.points or 0
        self.db.profile.perks.experience = self.db.profile.perks.experience or 0
        self.db.profile.perks.totalPointsEarned = self.db.profile.perks.totalPointsEarned or 0
    end
    
    -- FORCE OVERRIDE the PerksDB with enhanced version (even if it exists from Core.lua)
    self.PerksDB = {
        -- === TIER 1 - BASIC SURVIVAL (5 perks) ===
        {
            id = "iron_stomach",
            name = "Iron Stomach",
            description = "Food items restore 5% more hunger per rank.",
            tier = 1,
            maxRank = 5,
            effectValue = 5,
            effect = function(rank) return 1 + (0.05 * rank) end
        },
        {
            id = "hydration_expert", 
            name = "Hydration Expert",
            description = "Drinks restore 5% more thirst per rank.",
            tier = 1,
            maxRank = 5,
            effectValue = 5,
            effect = function(rank) return 1 + (0.05 * rank) end
        },
        {
            id = "efficient_sleeper",
            name = "Efficient Sleeper",
            description = "Sleep restores 10% more fatigue per rank.",
            tier = 1,
            maxRank = 5,
            effectValue = 10,
            effect = function(rank) return 1 + (0.10 * rank) end
        },
        {
            id = "temperature_resilience",
            name = "Temperature Resilience", 
            description = "Comfortable temperature range expanded by 3°F per rank (delays temperature warnings).",
            tier = 1,
            maxRank = 5,
            effectValue = 3,
            effect = function(rank) return rank * 3 end
        },
        {
            id = "hardy_constitution",
            name = "Hardy Constitution",
            description = "All survival stats decay 2% slower per rank when not moving.",
            tier = 1,
            maxRank = 5,
            effectValue = 2,
            effect = function(rank) return 1 - (0.02 * rank) end
        },
        
        -- === TIER 2 - INTERMEDIATE SKILLS (5 perks) ===
        {
            id = "survival_instinct",
            name = "Survival Instinct",
            description = "All survival stats decay 3% slower per rank.",
            tier = 2,
            maxRank = 5,
            effectValue = 3,
            effect = function(rank) return 1 - (0.03 * rank) end
        },
        {
            id = "cold_adaptation",
            name = "Cold Adaptation",
            description = "Freezing temperature threshold lowered by 5°F per rank (can tolerate colder temperatures).",
            tier = 2,
            maxRank = 4,
            effectValue = 5,
            effect = function(rank) return rank * 5 end
        },
        {
            id = "heat_tolerance",
            name = "Heat Tolerance", 
            description = "Overheating temperature threshold raised by 5°F per rank (can tolerate hotter temperatures).",
            tier = 2,
            maxRank = 4,
            effectValue = 5,
            effect = function(rank) return rank * 5 end
        },
        {
            id = "combat_endurance",
            name = "Combat Endurance",
            description = "Survival stats decay 10% slower per rank during combat.",
            tier = 2,
            maxRank = 3,
            effectValue = 10,
            effect = function(rank) return 1 - (0.10 * rank) end
        },
        {
            id = "master_survivor",
            name = "Master Survivor",
            description = "Fatigue decays 15% slower per rank while moving.",
            tier = 2,
            maxRank = 3,
            effectValue = 15,
            effect = function(rank) return 1 - (rank * 0.15) end
        },
        
        -- === TIER 3 - ADVANCED TECHNIQUES (5 perks) ===
        {
            id = "wilderness_expert",
            name = "Wilderness Expert",
            description = "Gain 25% more survival experience per rank.",
            tier = 3,
            maxRank = 4,
            effectValue = 25,
            effect = function(rank) return 1 + (0.25 * rank) end
        },
        {
            id = "arctic_survivor",
            name = "Arctic Survivor",
            description = "No freezing visual effects below 0°F at rank 1, below -20°F at rank 2, immune at rank 3.",
            tier = 3,
            maxRank = 3,
            effectValue = 0,
            effect = function(rank) return rank end
        },
        {
            id = "desert_nomad",
            name = "Desert Nomad", 
            description = "No overheating visual effects above 100°F at rank 1, above 120°F at rank 2, immune at rank 3.",
            tier = 3,
            maxRank = 3,
            effectValue = 0,
            effect = function(rank) return rank end
        },
        {
            id = "metabolic_efficiency",
            name = "Metabolic Efficiency",
            description = "All hunger and thirst restoration improved by 8% per rank.",
            tier = 3,
            maxRank = 3,
            effectValue = 8,
            effect = function(rank) return 1 + (0.08 * rank) end
        },
        {
            id = "shelter_master",
            name = "Shelter Master",
            description = "Shelters and indoor areas provide +3°F warmth bonus per rank.",
            tier = 3,
            maxRank = 3,
            effectValue = 3,
            effect = function(rank) return rank * 3 end
        },
        
        -- === TIER 4 - MASTER LEVEL (3 perks) ===
        {
            id = "apex_survivor",
            name = "Apex Survivor",
            description = "All survival stats decay 25% slower. The ultimate survival mastery.",
            tier = 4,
            maxRank = 1,
            effectValue = 25,
            effect = function(rank) return rank > 0 and 0.75 or 1 end
        },
        {
            id = "temperature_master",
            name = "Temperature Master",
            description = "Complete immunity to all temperature visual effects and warnings.",
            tier = 4,
            maxRank = 1,
            effectValue = 0,
            effect = function(rank) return rank end
        },
        {
            id = "survivalist_legend",
            name = "Survivalist Legend",
            description = "Double all survival experience gain. Legendary status among survivors.",
            tier = 4,
            maxRank = 1,
            effectValue = 100,
            effect = function(rank) return rank > 0 and 2 or 1 end
        },
    }
    
    -- Add icons to perk database
    for _, perk in ipairs(self.PerksDB) do
        perk.icon = PERK_ICONS[perk.id] or 134400 -- Default icon
    end
    
    -- Debug: Print perk count
    if self.db.profile.debug then
        self:DebugPrint("Loaded " .. #self.PerksDB .. " perks")
    end
end

function SurvivalMode:AddSurvivalExperience(amount, reason)
    local perks = self.db.profile.perks
    
    -- Ensure perks data is initialized
    if not perks then
        self:InitializePerkSystem()
        perks = self.db.profile.perks
    end
    
    -- Safety check for required fields
    perks.experience = perks.experience or 0
    perks.totalPointsEarned = perks.totalPointsEarned or 0
    
    -- Apply Survivalist Legend bonus
    local legendRank = self:GetPerkRank("survivalist_legend")
    if legendRank > 0 then
        amount = amount * 2
    end
    
    -- Add experience
    perks.experience = perks.experience + amount
    
    -- Check for new perk points
    local newPoints = 0
    for i, threshold in ipairs(PERK_POINT_THRESHOLDS) do
        if perks.experience >= threshold and perks.totalPointsEarned < i then
            newPoints = newPoints + 1
            perks.totalPointsEarned = i
        end
    end
    
    if newPoints > 0 then
        self:GrantPerkPoints(newPoints)
        self:Print(string.format("|cff00ff00You've earned %d perk point%s!|r", 
            newPoints, newPoints > 1 and "s" or ""))
        
        -- Play sound
        PlaySound(888) -- Level up sound
    end
    
    -- Show experience gain in debug mode
    if self.db.profile.debug then
        self:DebugPrint(string.format("Gained %d survival exp (%s). Total: %d", 
            amount, reason, perks.experience))
        
        -- Show progress to next point
        local nextThreshold = PERK_POINT_THRESHOLDS[perks.totalPointsEarned + 1]
        if nextThreshold then
            local remaining = nextThreshold - perks.experience
            self:DebugPrint(string.format("Progress to next point: %d/%d (%d remaining)", 
                perks.experience, nextThreshold, remaining))
        end
    end
end

function SurvivalMode:GrantPerkPoint()
    self:GrantPerkPoints(1)
end

function SurvivalMode:GrantPerkPoints(amount)
    -- Ensure perks data exists
    if not self.db.profile.perks then
        self:InitializePerkSystem()
    end
    
    self.db.profile.perks.points = (self.db.profile.perks.points or 0) + amount
    self:Print(string.format("Granted %d perk point%s. Total: %d", 
        amount, amount > 1 and "s" or "", self.db.profile.perks.points))
    
    -- Update perk UI if open
    if self.perkFrame and self.perkFrame:IsShown() then
        self:UpdatePerkUI()
    end
end

function SurvivalMode:GetPerkRank(perkId)
    if not self.db.profile.perks or not self.db.profile.perks.selected then
        return 0
    end
    return self.db.profile.perks.selected[perkId] or 0
end

function SurvivalMode:CanLearnPerk(perkData)
    local currentRank = self:GetPerkRank(perkData.id)
    
    -- Check if at max rank
    if currentRank >= perkData.maxRank then
        return false, "Already at maximum rank"
    end
    
    -- Check if have points
    if not self.db.profile.perks or self.db.profile.perks.points <= 0 then
        return false, "No perk points available"
    end
    
    -- Check tier requirements
    if perkData.tier > 1 then
        local previousTierPoints = 0
        for _, perk in ipairs(self.PerksDB) do
            if perk.tier < perkData.tier then
                previousTierPoints = previousTierPoints + self:GetPerkRank(perk.id)
            end
        end
        
        local requiredPoints = (perkData.tier - 1) * 3 -- 3 points per previous tier
        if previousTierPoints < requiredPoints then
            return false, string.format("Requires %d points in previous tiers", requiredPoints)
        end
    end
    
    return true, ""
end

function SurvivalMode:LearnPerk(perkId)
    -- Find perk data
    local perkData
    for _, perk in ipairs(self.PerksDB) do
        if perk.id == perkId then
            perkData = perk
            break
        end
    end
    
    if not perkData then return false end
    
    local canLearn, reason = self:CanLearnPerk(perkData)
    if not canLearn then
        self:Print("|cffff0000" .. reason .. "|r")
        return false
    end
    
    -- Ensure perks data exists
    if not self.db.profile.perks then
        self:InitializePerkSystem()
    end
    
    -- Learn the perk
    self.db.profile.perks.selected[perkId] = (self.db.profile.perks.selected[perkId] or 0) + 1
    self.db.profile.perks.points = self.db.profile.perks.points - 1
    
    local newRank = self.db.profile.perks.selected[perkId]
    self:Print(string.format("|cff00ff00Learned %s (Rank %d/%d)|r", 
        perkData.name, newRank, perkData.maxRank))
    
    -- Update UI
    if self.perkFrame and self.perkFrame:IsShown() then
        self:UpdatePerkUI()
    end
    
    return true
end

function SurvivalMode:ResetPerks()
    if not self.db.profile.perks then
        self:InitializePerkSystem()
    end
    
    self.db.profile.perks.selected = {}
    self.db.profile.perks.points = self.db.profile.perks.totalPointsEarned or 0
    
    self:Print("|cff00ff00All perks have been reset!|r")
    
    if self.perkFrame and self.perkFrame:IsShown() then
        self:UpdatePerkUI()
    end
end

function SurvivalMode:CreatePerkUI()
    if self.perkFrame then return end
    
    -- Professional main frame with dark background
    local frame = CreateFrame("Frame", "SurvivalModePerkFrame", UIParent, "BackdropTemplate")
    frame:SetSize(720, 640) -- Increased height to fit all tiers
    frame:SetPoint("CENTER")
    frame:SetBackdrop({
        bgFile = "Interface\\FrameGeneral\\UI-Background-Rock", -- Dark stone texture that tiles perfectly
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 128,
        edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })
    frame:SetBackdropColor(0.15, 0.15, 0.15, 0.98) -- Dark with minimal transparency
    frame:SetBackdropBorderColor(0.4, 0.4, 0.4, 1) -- Gray border
    frame:SetMovable(true)
    frame:SetResizable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()
    
    -- Subtle overlay for additional texture depth
    local textureOverlay = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
    textureOverlay:SetAllPoints()
    textureOverlay:SetTexture("Interface\\FrameGeneral\\UI-Background-Marble")
    textureOverlay:SetVertexColor(0.1, 0.1, 0.1, 0.3) -- Very subtle dark overlay
    textureOverlay:SetBlendMode("BLEND")
    
    -- Professional header with dark theme
    local header = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    header:SetPoint("TOPLEFT", 12, -12)
    header:SetPoint("TOPRIGHT", -12, -12)
    header:SetHeight(48)
    header:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        tile = false,
    })
    header:SetBackdropColor(0.05, 0.08, 0.12, 0.9) -- Dark blue-gray header
    
    -- Professional title with dark theme styling
    local titleIcon = header:CreateTexture(nil, "ARTWORK")
    titleIcon:SetSize(32, 32)
    titleIcon:SetPoint("LEFT", 16, 0)
    titleIcon:SetTexture("Interface\\Icons\\INV_Misc_Book_11") -- Classic book icon
    
    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("LEFT", titleIcon, "RIGHT", 12, 2)
    title:SetText("Survival Perks")
    title:SetTextColor(0.9, 0.9, 0.7, 1) -- Light text for dark background
    
    -- Points display (dark theme styling)
    local pointsFrame = CreateFrame("Frame", nil, header, "BackdropTemplate")
    pointsFrame:SetSize(120, 28)
    pointsFrame:SetPoint("RIGHT", -16, 0)
    pointsFrame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = false,
        edgeSize = 12,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    pointsFrame:SetBackdropColor(0.1, 0.15, 0.1, 0.9) -- Dark green
    pointsFrame:SetBackdropBorderColor(0.3, 0.5, 0.3, 0.8) -- Green border
    
    local pointsText = pointsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    pointsText:SetPoint("CENTER")
    pointsText:SetTextColor(0.4, 0.9, 0.4, 1) -- Bright green text
    frame.pointsText = pointsText
    
    -- Professional experience bar section with dark theme
    local expSection = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    expSection:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -8)
    expSection:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", 0, -8)
    expSection:SetHeight(32)
    expSection:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        tile = false,
    })
    expSection:SetBackdropColor(0.08, 0.12, 0.08, 0.8) -- Dark green section
    
    local expLabel = expSection:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    expLabel:SetPoint("LEFT", 16, 8)
    expLabel:SetText("Experience Progress")
    expLabel:SetTextColor(0.7, 0.7, 0.5, 1) -- Light text
    
    local expBarContainer = CreateFrame("Frame", nil, expSection, "BackdropTemplate")
    expBarContainer:SetSize(400, 16)
    expBarContainer:SetPoint("LEFT", 16, -6)
    expBarContainer:SetBackdrop({
        bgFile = "Interface\\TargetingFrame\\UI-StatusBar",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = false,
        edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    expBarContainer:SetBackdropColor(0.1, 0.1, 0.05, 1) -- Dark background
    expBarContainer:SetBackdropBorderColor(0.3, 0.3, 0.2, 0.8) -- Dark border
    
    local expBar = CreateFrame("StatusBar", nil, expBarContainer)
    expBar:SetPoint("TOPLEFT", 2, -2)
    expBar:SetPoint("BOTTOMRIGHT", -2, 2)
    expBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    expBar:SetStatusBarColor(0.3, 0.7, 0.3, 0.8) -- Green progress bar
    expBar:SetMinMaxValues(0, 100)
    
    local expText = expBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    expText:SetPoint("CENTER")
    expText:SetTextColor(1, 1, 1, 1) -- White text for contrast
    expBar.text = expText
    
    frame.expBar = expBar
    
    -- Main content area with proper padding to fit all tiers
    local content = CreateFrame("Frame", nil, frame)
    content:SetPoint("TOPLEFT", expSection, "BOTTOMLEFT", 16, -16)
    content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -16, 50) -- Extra bottom space for Tier 4 and reset button
    
    -- Create professional perk buttons
    local perkButtons = {}
    for _, perkData in ipairs(self.PerksDB) do
        local button = self:CreateProfessionalPerkButton(content, perkData)
        perkButtons[perkData.id] = button
    end
    
    -- Professional tier-based layout with parchment theme
    local tierData = {
        {y = 0, label = "Basic Survival", color = {0.2, 0.6, 0.2}},
        {y = -130, label = "Intermediate Skills", color = {0.2, 0.4, 0.8}},
        {y = -260, label = "Advanced Techniques", color = {0.6, 0.2, 0.6}},
        {y = -390, label = "Master Level", color = {0.8, 0.5, 0.1}}
    }
    
    -- Position perks in professional grid
    for tier = 1, 4 do
        -- Professional tier header with parchment styling
        local tierHeader = CreateFrame("Frame", nil, content, "BackdropTemplate")
        tierHeader:SetSize(200, 24)
        tierHeader:SetPoint("TOPLEFT", 0, tierData[tier].y)
        tierHeader:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            tile = false,
        })
        tierHeader:SetBackdropColor(tierData[tier].color[1], tierData[tier].color[2], tierData[tier].color[3], 0.4)
        
        local tierLine = tierHeader:CreateTexture(nil, "BACKGROUND")
        tierLine:SetHeight(1)
        tierLine:SetPoint("LEFT", tierHeader, "RIGHT", 8, 0)
        tierLine:SetPoint("RIGHT", content, "RIGHT", 0, 0)
        tierLine:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
        tierLine:SetVertexColor(tierData[tier].color[1], tierData[tier].color[2], tierData[tier].color[3], 0.6)
        
        local tierLabel = tierHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        tierLabel:SetPoint("LEFT", 8, 0)
        tierLabel:SetText("TIER " .. tier .. " - " .. tierData[tier].label)
        tierLabel:SetTextColor(tierData[tier].color[1], tierData[tier].color[2], tierData[tier].color[3], 1)
        
        -- Position perks for this tier
        local tierPerks = {}
        for _, perkData in ipairs(self.PerksDB) do
            if perkData.tier == tier then
                table.insert(tierPerks, perkData)
            end
        end
        
        for i, perkData in ipairs(tierPerks) do
            local button = perkButtons[perkData.id]
            local x = (i - 1) * 130
            local y = tierData[tier].y - 40
            button:SetPoint("TOPLEFT", content, "TOPLEFT", x, y)
        end
    end
    
    -- Professional close button
    local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", -12, -12)
    closeButton:SetSize(24, 24)
    
    -- Professional reset button with parchment theme
    local resetButton = CreateFrame("Button", nil, frame, "BackdropTemplate")
    resetButton:SetSize(100, 28)
    resetButton:SetPoint("BOTTOMRIGHT", -20, 16)
    resetButton:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = false,
        edgeSize = 12,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    resetButton:SetBackdropColor(0.7, 0.4, 0.3, 0.8) -- Reddish brown for parchment
    resetButton:SetBackdropBorderColor(0.8, 0.5, 0.4, 0.9) -- Lighter brown border
    
    local resetText = resetButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    resetText:SetPoint("CENTER")
    resetText:SetText("Reset Perks")
    resetText:SetTextColor(0.9, 0.8, 0.7, 1) -- Light parchment text
    
    resetButton:SetScript("OnClick", function()
        StaticPopup_Show("SURVIVALMODE_RESET_PERKS")
    end)
    resetButton:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.8, 0.5, 0.4, 1) -- Lighter on hover
    end)
    resetButton:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0.7, 0.4, 0.3, 0.8) -- Back to normal
    end)
    
    self.perkFrame = frame
    self.perkButtons = perkButtons
    
    -- Professional confirmation dialog
    StaticPopupDialogs["SURVIVALMODE_RESET_PERKS"] = {
        text = "Are you sure you want to reset all perks?\n\nThis will refund all spent points.",
        button1 = "Reset",
        button2 = "Cancel",
        OnAccept = function()
            SurvivalMode:ResetPerks()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
end

function SurvivalMode:CreateProfessionalPerkButton(parent, perkData)
    -- Professional perk button with parchment theme
    local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
    button:SetSize(120, 90) -- Professional sizing
    button:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = false,
        edgeSize = 12,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    button:SetBackdropColor(0.85, 0.8, 0.65, 0.9) -- Parchment button color
    button:SetBackdropBorderColor(0.5, 0.4, 0.3, 0.8) -- Brown border
    
    -- Professional icon frame with parchment styling
    local iconFrame = CreateFrame("Frame", nil, button, "BackdropTemplate")
    iconFrame:SetSize(48, 48)
    iconFrame:SetPoint("TOP", 0, -8)
    iconFrame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = false,
        edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    iconFrame:SetBackdropColor(0.9, 0.85, 0.7, 1) -- Light parchment
    iconFrame:SetBackdropBorderColor(0.6, 0.5, 0.4, 1) -- Bronze border
    
    local icon = iconFrame:CreateTexture(nil, "ARTWORK")
    icon:SetPoint("TOPLEFT", 2, -2)
    icon:SetPoint("BOTTOMRIGHT", -2, 2)
    icon:SetTexture(perkData.icon)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- Crop icon edges for cleaner look
    button.icon = icon
    button.iconFrame = iconFrame
    
    -- Professional name label with parchment styling
    local name = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    name:SetPoint("TOP", iconFrame, "BOTTOM", 0, -4)
    name:SetText(perkData.name)
    name:SetWidth(112)
    name:SetJustifyH("CENTER")
    name:SetTextColor(0.3, 0.25, 0.15, 1) -- Dark brown text on parchment
    button.name = name
    
    -- Professional rank display with parchment theme
    local rankFrame = CreateFrame("Frame", nil, button, "BackdropTemplate")
    rankFrame:SetSize(32, 16)
    rankFrame:SetPoint("BOTTOM", 0, 4)
    rankFrame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        tile = false,
    })
    rankFrame:SetBackdropColor(0.4, 0.3, 0.2, 0.8) -- Dark brown
    
    local rank = rankFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    rank:SetPoint("CENTER")
    rank:SetTextColor(0.9, 0.8, 0.6, 1) -- Light parchment text
    button.rank = rank
    
    -- Professional click handling
    button:SetScript("OnClick", function(self)
        SurvivalMode:LearnPerk(perkData.id)
        -- Professional click feedback
        local flash = self:CreateTexture(nil, "OVERLAY")
        flash:SetAllPoints(iconFrame)
        flash:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
        flash:SetVertexColor(1, 1, 0.5, 0.5) -- Gold flash for parchment theme
        C_Timer.After(0.1, function()
            if flash then
                flash:SetVertexColor(1, 1, 0.5, 0)
                C_Timer.After(0.1, function()
                    if flash then flash:Hide() end
                end)
            end
        end)
    end)
    
    -- Professional tooltip system
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        
        -- Professional tooltip header
        GameTooltip:AddLine(perkData.name, 1, 0.82, 0.1, 1) -- Gold title
        GameTooltip:AddLine("Tier " .. perkData.tier .. " Survival Perk", 0.6, 0.6, 0.6, 1) -- Gray subtitle
        GameTooltip:AddLine(" ") -- Spacer
        
        -- Description with word wrapping
        GameTooltip:AddLine(perkData.description, 1, 1, 1, 1, true)
        GameTooltip:AddLine(" ") -- Spacer
        
        local currentRank = SurvivalMode:GetPerkRank(perkData.id)
        
        -- Current rank info
        if currentRank > 0 then
            GameTooltip:AddLine("Current Rank: " .. currentRank .. "/" .. perkData.maxRank, 0.4, 0.8, 1, 1)
            if perkData.effectValue > 0 then
                local currentEffect = perkData.effectValue * currentRank
                GameTooltip:AddLine("Current Effect: +" .. currentEffect .. "%", 0.4, 1, 0.4, 1)
            else
                GameTooltip:AddLine("Special ability is active", 0.4, 1, 0.4, 1)
            end
        else
            GameTooltip:AddLine("Current Rank: 0/" .. perkData.maxRank, 0.6, 0.6, 0.6, 1)
        end
        
        -- Next rank preview
        if currentRank < perkData.maxRank then
            local nextRank = currentRank + 1
            if perkData.effectValue > 0 then
                local nextEffect = perkData.effectValue * nextRank
                GameTooltip:AddLine("Next Rank (" .. nextRank .. "): +" .. nextEffect .. "%", 1, 1, 0.4, 1)
            else
                GameTooltip:AddLine("Next Rank (" .. nextRank .. "): Enhanced ability", 1, 1, 0.4, 1)
            end
        end
        
        -- Requirements/restrictions
        local canLearn, reason = SurvivalMode:CanLearnPerk(perkData)
        if not canLearn then
            GameTooltip:AddLine(" ") -- Spacer
            GameTooltip:AddLine(reason, 1, 0.4, 0.4, 1)
        elseif currentRank < perkData.maxRank then
            GameTooltip:AddLine(" ") -- Spacer
            GameTooltip:AddLine("Click to learn this perk", 0.4, 1, 0.4, 1)
        end
        
        GameTooltip:Show()
        
        -- Professional hover effect for parchment theme
        self:SetBackdropBorderColor(0.8, 0.6, 0.4, 1) -- Lighter brown on hover
        iconFrame:SetBackdropBorderColor(0.9, 0.7, 0.5, 1)
    end)
    
    button:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
        -- Reset to appropriate state colors
        SurvivalMode:UpdatePerkButtonState(self, perkData)
    end)
    
    button.perkData = perkData
    return button
end

function SurvivalMode:UpdatePerkButtonState(button, perkData)
    local currentRank = self:GetPerkRank(perkData.id)
    local canLearn = self:CanLearnPerk(perkData)
    
    if currentRank >= perkData.maxRank then
        -- Maxed out - gold theme for parchment
        button:SetBackdropColor(0.95, 0.9, 0.7, 0.95)
        button:SetBackdropBorderColor(0.8, 0.6, 0.2, 1)
        button.iconFrame:SetBackdropColor(1, 0.95, 0.8, 1)
        button.iconFrame:SetBackdropBorderColor(0.9, 0.7, 0.3, 1)
        button.icon:SetDesaturated(false)
        button.name:SetTextColor(0.6, 0.4, 0.1, 1) -- Dark gold text
        button.rank:SetTextColor(1, 0.8, 0.4, 1)
    elseif canLearn then
        -- Available to learn - green theme for parchment
        button:SetBackdropColor(0.8, 0.9, 0.75, 0.95)
        button:SetBackdropBorderColor(0.3, 0.7, 0.3, 1)
        button.iconFrame:SetBackdropColor(0.85, 0.95, 0.8, 1)
        button.iconFrame:SetBackdropBorderColor(0.4, 0.8, 0.4, 1)
        button.icon:SetDesaturated(false)
        button.name:SetTextColor(0.1, 0.4, 0.1, 1) -- Dark green text
        button.rank:SetTextColor(0.6, 1, 0.6, 1)
    elseif currentRank > 0 then
        -- Partially learned - blue theme for parchment
        button:SetBackdropColor(0.75, 0.8, 0.9, 0.95)
        button:SetBackdropBorderColor(0.3, 0.5, 0.8, 1)
        button.iconFrame:SetBackdropColor(0.8, 0.85, 0.95, 1)
        button.iconFrame:SetBackdropBorderColor(0.4, 0.6, 0.9, 1)
        button.icon:SetDesaturated(false)
        button.name:SetTextColor(0.1, 0.2, 0.5, 1) -- Dark blue text
        button.rank:SetTextColor(0.6, 0.8, 1, 1)
    else
        -- Locked - muted theme for parchment
        button:SetBackdropColor(0.7, 0.65, 0.55, 0.8)
        button:SetBackdropBorderColor(0.5, 0.4, 0.3, 0.6)
        button.iconFrame:SetBackdropColor(0.75, 0.7, 0.6, 0.8)
        button.iconFrame:SetBackdropBorderColor(0.6, 0.5, 0.4, 0.6)
        button.icon:SetDesaturated(true)
        button.name:SetTextColor(0.4, 0.35, 0.25, 0.8) -- Muted brown text
        button.rank:SetTextColor(0.5, 0.45, 0.35, 0.8)
    end
end

function SurvivalMode:UpdatePerkUI()
    if not self.perkFrame then return end
    
    -- Ensure perks data exists
    if not self.db.profile.perks then
        self:InitializePerkSystem()
    end
    
    local perks = self.db.profile.perks
    
    -- Update points display
    self.perkFrame.pointsText:SetText("Points: " .. (perks.points or 0))
    
    -- Update experience bar
    local currentExp = perks.experience or 0
    local totalPointsEarned = perks.totalPointsEarned or 0
    local nextThreshold = PERK_POINT_THRESHOLDS[totalPointsEarned + 1] or 999999
    local prevThreshold = PERK_POINT_THRESHOLDS[totalPointsEarned] or 0
    
    local progress = 0
    if nextThreshold > prevThreshold then
        progress = (currentExp - prevThreshold) / (nextThreshold - prevThreshold) * 100
    end
    
    self.perkFrame.expBar:SetValue(progress)
    if nextThreshold < 999999 then
        self.perkFrame.expBar.text:SetText(currentExp .. " / " .. nextThreshold .. " XP")
    else
        self.perkFrame.expBar.text:SetText(currentExp .. " XP (Maximum Level)")
    end
    
    -- Update all buttons with professional states
    for perkId, button in pairs(self.perkButtons) do
        local currentRank = self:GetPerkRank(perkId)
        local perkData = button.perkData
        
        button.rank:SetText(currentRank .. "/" .. perkData.maxRank)
        self:UpdatePerkButtonState(button, perkData)
    end
end

function SurvivalMode:TogglePerkUI()
    if not self.perkFrame then
        self:CreatePerkUI()
    end
    
    if self.perkFrame:IsShown() then
        self.perkFrame:Hide()
    else
        self.perkFrame:Show()
        self:UpdatePerkUI()
    end
end