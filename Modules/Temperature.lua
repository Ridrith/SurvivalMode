local addonName, ns = ...
local SurvivalMode = ns.SurvivalMode

-- Zone temperatures in Fahrenheit (base system) - SIGNIFICANTLY EXPANDED
SurvivalMode.ZONE_TEMPERATURES = {
    -- Alliance Starting Zones
    ["Elwynn Forest"] = 65,
    ["Westfall"] = 72,
    ["Redridge Mountains"] = 64,
    ["Duskwood"] = 58,
    ["Wetlands"] = 55,
    ["Loch Modan"] = 60,
    ["Dun Morogh"] = 20,
    ["Ironforge"] = 64,
    ["Stormwind City"] = 68,
    ["Teldrassil"] = 62,
    ["Darkshore"] = 59,
    ["Ashenvale"] = 63,
    ["The Exodar"] = 64,
    
    -- Horde Starting Zones
    ["Durotar"] = 90,
    ["The Barrens"] = 86,
    ["Mulgore"] = 75,
    ["Thunder Bluff"] = 70,
    ["Orgrimmar"] = 85,
    ["Tirisfal Glades"] = 54,
    ["Silverpine Forest"] = 57,
    ["Undercity"] = 56,
    ["Silvermoon City"] = 70,
    
    -- Contested Zones
    ["Hillsbrad Foothills"] = 63,
    ["Arathi Highlands"] = 66,
    ["Stranglethorn Vale"] = 82,
    ["Badlands"] = 78,
    ["Swamp of Sorrows"] = 76,
    ["Blasted Lands"] = 97,
    ["Eastern Plaguelands"] = 52,
    ["Western Plaguelands"] = 50,
    
    -- Kalimdor Zones
    ["Feralas"] = 75,
    ["Azshara"] = 68,
    ["Felwood"] = 61,
    ["Moonglade"] = 64,
    ["Silithus"] = 93,
    ["Dustwallow Marsh"] = 79,
    ["Thousand Needles"] = 90,
    ["Desolace"] = 82,
    ["Stonetalon Mountains"] = 68,
    ["Tanaris"] = 100,
    ["Un'Goro Crater"] = 95,
    
    -- Cold Zones
    ["Winterspring"] = 14,
    ["Alterac Mountains"] = 36,
    ["Icecrown"] = -4,
    ["Storm Peaks"] = 0,
    ["Dragonblight"] = 10,
    ["Borean Tundra"] = 5,
    ["Howling Fjord"] = 23,
    ["Crystalsong Forest"] = 18,
    ["Zul'Drak"] = 14,
    ["The Azure Span"] = 23,
    
    -- Hot Zones
    ["Searing Gorge"] = 108,
    ["Burning Steppes"] = 104,
    ["Hellfire Peninsula"] = 113,
    ["Shadowmoon Valley"] = 77,
    ["Blade's Edge Mountains"] = 46,
    ["Netherstorm"] = 68,
    ["Nagrand"] = 72,
    ["Zangarmarsh"] = 75,
    ["Terokkar Forest"] = 79,
    
    -- Neutral/City Zones
    ["Dalaran"] = 59,
    ["Shattrath City"] = 77,
    
    -- Dragon Isles
    ["Valdrakken"] = 59,
    ["The Waking Shores"] = 77,
    ["Ohn'ahran Plains"] = 64,
    ["Thaldraszus"] = 68,
    ["The Forbidden Reach"] = 54,
    ["Zaralek Cavern"] = 86,
    ["Emerald Dream"] = 68,
    
    -- Cataclysm Zones
    ["Mount Hyjal"] = 73,
    ["Vashj'ir"] = 59, -- Underwater
    ["Deepholm"] = 65, -- Elemental plane
    ["Uldum"] = 101,
    ["Twilight Highlands"] = 62,
    ["Tol Barad"] = 58,
    ["Tol Barad Peninsula"] = 61,
    
    -- Mists of Pandaria
    ["The Jade Forest"] = 74,
    ["Valley of the Four Winds"] = 76,
    ["Krasarang Wilds"] = 78,
    ["Kun-Lai Summit"] = 18,
    ["Townlong Steppes"] = 64,
    ["Dread Wastes"] = 71,
    ["Vale of Eternal Blossoms"] = 72,
    ["Isle of Thunder"] = 69,
    ["Timeless Isle"] = 73,
    
    -- Warlords of Draenor
    ["Frostfire Ridge"] = 25,
    ["Shadowmoon Valley"] = 67, -- Draenor version
    ["Gorgrond"] = 79,
    ["Talador"] = 71,
    ["Spires of Arak"] = 68,
    ["Nagrand"] = 74, -- Draenor version
    ["Tanaan Jungle"] = 89,
    ["Ashran"] = 66,
    
    -- Legion Zones
    ["The Broken Isles"] = 67,
    ["Dalaran"] = 59, -- Legion Dalaran
    ["Azsuna"] = 69,
    ["Val'sharah"] = 65,
    ["Highmountain"] = 52,
    ["Stormheim"] = 41,
    ["Suramar"] = 70,
    ["Broken Shore"] = 74,
    ["Argus"] = 82,
    ["Krokuun"] = 95,
    ["Antoran Wastes"] = 108,
    ["Mac'Aree"] = 76,
    
    -- Battle for Azeroth
    ["Tiragarde Sound"] = 64,
    ["Drustvar"] = 58,
    ["Stormsong Valley"] = 66,
    ["Zuldazar"] = 84,
    ["Nazmir"] = 81,
    ["Vol'dun"] = 97,
    ["Mechagon"] = 72,
    ["Nazjatar"] = 67,
    
    -- Shadowlands
    ["The Maw"] = 45, -- Desolate, not hot or cold
    ["Oribos"] = 66,
    ["Bastion"] = 69,
    ["Maldraxxus"] = 61,
    ["Ardenweald"] = 64,
    ["Revendreth"] = 72,
    ["Korthia"] = 58,
    ["Zereth Mortis"] = 71,
    
    -- Additional Classic Zones
    ["Alterac Valley"] = 28,
    ["Warsong Gulch"] = 75,
    ["Arathi Basin"] = 67,
    ["Deadwind Pass"] = 63,
    ["Isle of Quel'Danas"] = 73,
    ["Ghostlands"] = 66,
    ["Eversong Woods"] = 71,
    ["Bloodmyst Isle"] = 62,
    ["Azuremyst Isle"] = 64,
    ["Northern Stranglethorn"] = 84,
    ["The Cape of Stranglethorn"] = 86,
    ["Loch Modan"] = 58,
    ["Sholazar Basin"] = 76,
    ["Grizzly Hills"] = 48,
    
    -- Dungeon Zones
    ["Blackrock Depths"] = 95,
    ["Blackrock Spire"] = 88,
    ["Molten Core"] = 125,
    ["Blackwing Lair"] = 91,
    ["Stratholme"] = 55,
    ["Scholomance"] = 52,
    ["Dire Maul"] = 67,
    ["Maraudon"] = 73,
    ["Zul'Farrak"] = 102,
    ["Uldaman"] = 69,
    ["Razorfen Kraul"] = 78,
    ["Razorfen Downs"] = 74,
    ["The Deadmines"] = 66,
    ["Shadowfang Keep"] = 51,
    ["The Stockade"] = 62,
    ["Ragefire Chasm"] = 96,
    ["Wailing Caverns"] = 82,
    ["Gnomeregan"] = 58,
    ["Blackfathom Deeps"] = 59,
    ["Sunken Temple"] = 79,
    
    -- Default for unknown zones
    ["*"] = 68,
}

-- Sub-zone temperature modifiers (added to base zone temperature)
SurvivalMode.SUBZONE_MODIFIERS = {
    -- === STORMWIND CITY ===
    ["The Cathedral of Light"] = 5,
    ["The Canals"] = -2,
    ["Old Town"] = 2,
    ["Stormwind Keep"] = 3,
    ["The Mage Quarter"] = -1,
    ["Stormwind Harbor"] = -3,
    ["The Trade District"] = 1,
    ["The Park"] = 0,
    ["The Stockade"] = -5, -- Underground prison
    
    -- === ORGRIMMAR ===
    ["Valley of Strength"] = 3,
    ["Valley of Honor"] = 2,
    ["Valley of Wisdom"] = 1,
    ["Valley of Spirits"] = 2,
    ["The Cleft of Shadow"] = -8,
    ["The Drag"] = 4,
    ["Grommash Hold"] = 1,
    
    -- === IRONFORGE ===
    ["The Great Forge"] = 15, -- Central forge area
    ["The Commons"] = 3,
    ["The Military Ward"] = 1,
    ["The Mystic Ward"] = -2,
    ["Tinker Town"] = 5,
    ["Deeprun Tram"] = -3,
    
    -- === THUNDER BLUFF ===
    ["Elder Rise"] = 2,
    ["Spirit Rise"] = 1,
    ["Hunter Rise"] = 0,
    ["The High Rise"] = 3,
    ["Middle Rise"] = 1,
    
    -- === UNDERCITY ===
    ["The Trade Quarter"] = -3, -- Underground
    ["The Apothecarium"] = -1,
    ["The Magic Quarter"] = -2,
    ["The War Quarter"] = -1,
    ["The Rogues' Quarter"] = -4,
    ["Royal Quarter"] = 0,
    
    -- === SILVERMOON CITY ===
    ["Sunfury Spire"] = 3,
    ["Court of the Sun"] = 2,
    ["Royal Exchange"] = 1,
    ["The Bazaar"] = 1,
    ["Farstriders' Square"] = 0,
    ["Murder Row"] = -2,
    
    -- === DARNASSUS ===
    ["The Temple of the Moon"] = 2,
    ["Tradesman's Terrace"] = 1,
    ["The Warrior's Terrace"] = 0,
    ["Cenarion Enclave"] = 1,
    ["Craftsmen's Terrace"] = 0,
    
    -- === THE EXODAR ===
    ["The Seat of the Naaru"] = 2,
    ["The Crystal Hall"] = 1,
    ["The Vault of Lights"] = 1,
    ["Trader's Tier"] = 0,
    
    -- === SHATTRATH CITY ===
    ["The Terrace of Light"] = 3,
    ["Aldor Rise"] = 1,
    ["Scryer's Tier"] = 1,
    ["Lower City"] = -2,
    ["The Sha'tar Terrace"] = 2,
    
    -- === DALARAN ===
    ["The Violet Hold"] = -5,
    ["The Violet Citadel"] = 2,
    ["Krasus' Landing"] = -3, -- Open air platform
    ["The Underbelly"] = -4, -- Sewers
    ["Runeweaver Square"] = 0,
    ["The Magus Commerce Exchange"] = 1,
    ["Sunreaver's Sanctuary"] = 2,
    ["The Silver Enclave"] = 2,
    ["Antonidas Memorial"] = 1,
    
    -- === VALDRAKKEN ===
    ["The Seat of the Aspects"] = 3,
    ["Tyr's Rest"] = 1,
    ["The Roasted Ram"] = 4, -- Tavern
    ["Algeth'ar Academy"] = 1,
    ["The Artisan's Market"] = 0,
    ["Temporal Conflux"] = -1,
    
    -- === INNS AND TAVERNS ===
    ["The Prancing Pony"] = 8, -- Bree-land Inn
    ["The Lion's Pride Inn"] = 7, -- Goldshire
    ["The Slaughtered Lamb"] = 5, -- Stormwind
    ["Goldshire Inn"] = 6,
    ["The Pig and Whistle Tavern"] = 6, -- Stormwind
    ["Deeprun Tram"] = -3,
    ["The Grim Guzzler"] = 12, -- Blackrock Depths tavern
    ["Razor Hill Inn"] = 5,
    ["The Crossroads Inn"] = 4,
    ["Bloodhoof Village Inn"] = 6,
    ["Brill Inn"] = 4,
    ["The Sepulcher Inn"] = 3,
    ["Tarren Mill Inn"] = 5,
    ["Kharanos Inn"] = 8, -- Dun Morogh
    ["Thelsamar Inn"] = 6, -- Loch Modan
    ["Lakeshire Inn"] = 5, -- Redridge
    ["Scarlet Raven Tavern"] = 4, -- Duskwood
    ["Westfall Inn"] = 5,
    ["Sentinel Hill Inn"] = 5,
    ["Auberdine Inn"] = 4,
    ["Astranaar Inn"] = 5,
    ["Everlook Inn"] = 12, -- Winterspring
    ["Marshal's Refuge"] = 6, -- Un'Goro
    ["Gadgetzan Inn"] = 8, -- Tanaris (cooled)
    ["Ratchet Inn"] = 4, -- The Barrens
    ["Booty Bay Inn"] = 6, -- Stranglethorn
    ["Menethil Harbor Inn"] = 7, -- Wetlands
    ["Ironforge Inn"] = 10,
    ["Thunder Bluff Inn"] = 8,
    ["Orgrimmar Inn"] = 6,
    ["Undercity Inn"] = 5,
    ["Silvermoon Inn"] = 7,
    
    -- === VILLAGES AND SETTLEMENTS ===
    ["Goldshire"] = 2,
    ["Northshire"] = 1,
    ["Ridgepoint Tower"] = -1,
    ["Tower of Azora"] = 0,
    ["Lakeshire"] = 1,
    ["Darkshire"] = -1,
    ["Raven Hill"] = -3,
    ["Sentinel Hill"] = 2,
    ["Moonbrook"] = 1,
    ["Kharanos"] = 5, -- Has fires and forges
    ["Gol'Bolar Quarry"] = -2,
    ["Thelsamar"] = 2,
    ["Menethil Harbor"] = 0,
    ["Auberdine"] = 1,
    ["Astranaar"] = 2,
    ["Splintertree Post"] = 1,
    ["Zoram'gar Outpost"] = 0,
    ["Bloodhoof Village"] = 3,
    ["Camp Narache"] = 2,
    ["Razor Hill"] = 2,
    ["Sen'jin Village"] = 3,
    ["The Crossroads"] = 1,
    ["Camp Taurajo"] = 2,
    ["Ratchet"] = 0,
    ["Brill"] = 1,
    ["The Sepulcher"] = -1,
    ["Tarren Mill"] = 2,
    ["Southshore"] = 1,
    ["Refuge Pointe"] = 2,
    ["Hammerfall"] = 1,
    ["Booty Bay"] = 2,
    ["Grom'gol Base Camp"] = 1,
    ["Rebel Camp"] = 0,
    ["Nesingwary's Expedition"] = 1,
    ["Gadgetzan"] = -3, -- Desert town with shade
    ["Steamwheedle Port"] = 1,
    ["Marshal's Refuge"] = 4, -- Shaded crater
    ["Cenarion Hold"] = -2,
    ["Everlook"] = 15, -- Goblin heating tech
    ["Timbermaw Hold"] = 8,
    ["Nighthaven"] = 3,
    
    -- === CAVES AND UNDERGROUND ===
    ["Shadowfang Keep"] = -3,
    ["The Deadmines"] = 0,
    ["Blackfathom Deeps"] = -2,
    ["Wailing Caverns"] = 5, -- Geothermal
    ["Ragefire Chasm"] = 15, -- Volcanic
    ["Blackrock Depths"] = 20, -- Near lava
    ["Blackrock Spire"] = 12,
    ["Stratholme"] = -2, -- Undead city
    ["Scholomance"] = -4, -- Necromantic magic
    ["Dire Maul"] = -1,
    ["Maraudon"] = 2,
    ["Zul'Farrak"] = 8, -- Desert pyramid
    ["Uldaman"] = 1, -- Ancient dwarven
    ["Gnomeregan"] = -3, -- Irradiated
    ["Razorfen Kraul"] = 3,
    ["Razorfen Downs"] = 1,
    ["Sunken Temple"] = 4, -- Jungle swamp
    
    -- === SPECIAL LOCATIONS ===
    ["Light's Hope Chapel"] = 3, -- Sacred warmth
    ["Uther's Tomb"] = -5,
    ["Andorhal"] = -6, -- Plagued
    ["Caer Darrow"] = -8,
    ["Darrowmere Lake"] = -5,
    ["The Scarlet Monastery"] = 1,
    ["Hearthglen"] = 0,
    ["Tyr's Hand"] = 1,
    ["Crown Guard Tower"] = -1,
    ["Nethergarde Keep"] = 2,
    ["The Dark Portal"] = 8, -- Fel energy
    ["Stonard"] = 2,
    ["The Temple of Atal'Hakkar"] = 4,
    ["Onyxia's Lair"] = 12, -- Dragon lair
    ["Blackwing Lair"] = 15,
    ["Molten Core"] = 30, -- Volcanic
    ["Shadowfang Keep"] = -3,
    
    -- === BATTLEGROUNDS ===
    ["Dun Baldar"] = 5, -- Alliance base with fires
    ["Frostwolf Keep"] = 8, -- Horde base with fires
    ["Field of Strife"] = -5, -- Open battlefield
    ["Icewing Bunker"] = 3,
    ["Stonehearth Bunker"] = 3,
    ["Iceblood Tower"] = 2,
    ["Tower Point"] = 2,
    ["Lumber Mill"] = 3, -- Arathi Basin
    ["Blacksmith"] = 8, -- Forges
    ["Gold Mine"] = 0,
    ["Stables"] = 4, -- Animal warmth
    ["Farm"] = 2,
}

-- Cooking fire spell IDs that provide warmth
SurvivalMode.COOKING_FIRE_SPELLS = {
    [818] = true,      -- Basic Campfire
    [135805] = true,   -- Mage's Conjure Refreshment Table
}

function SurvivalMode:FahrenheitToCelsius(fahrenheit)
    return (fahrenheit - 32) * 5/9
end

function SurvivalMode:CelsiusToFahrenheit(celsius)
    return (celsius * 9/5) + 32
end

function SurvivalMode:GetTemperatureString(fahrenheit)
    local useFahrenheit = self.db.profile.ui.useFahrenheit
    if useFahrenheit then
        return string.format("%.1f°F", fahrenheit)
    else
        local celsius = self:FahrenheitToCelsius(fahrenheit)
        return string.format("%.1f°C", celsius)
    end
end

-- Enhanced visual effects system
function SurvivalMode:GetTemperatureEffects(fahrenheit)
    local effects = {}
    
    if fahrenheit <= -10 then
        effects.severity = "extreme_cold"
        effects.message = "|cff00ccffExtreme Cold!|r Your character is at risk of frostbite."
        effects.screen_effect = "FREEZE_EXTREME"
    elseif fahrenheit <= 10 then
        effects.severity = "severe_cold"
        effects.message = "|cff66ccffSevere Cold!|r You need shelter immediately."
        effects.screen_effect = "FREEZE_SEVERE"
    elseif fahrenheit <= 32 then
        effects.severity = "freezing"
        effects.message = "|cff99ccffFreezing|r - Find warmth soon."
        effects.screen_effect = "FREEZE_MILD"
    elseif fahrenheit >= 120 then
        effects.severity = "extreme_heat"
        effects.message = "|cffff0000Extreme Heat!|r Your character is suffering from heat stroke."
        effects.screen_effect = "HEAT_EXTREME"
    elseif fahrenheit >= 105 then
        effects.severity = "severe_heat"
        effects.message = "|cffff3300Severe Heat!|r Seek shade immediately."
        effects.screen_effect = "HEAT_SEVERE"
    elseif fahrenheit >= 95 then
        effects.severity = "very_hot"
        effects.message = "|cffff6600Very Hot|r - Stay hydrated."
        effects.screen_effect = "HEAT_MILD"
    end
    
    return effects
end

function SurvivalMode:CreateTemperatureEffectFrame()
    if self.temperatureEffectFrame then return end
    
    -- Create temperature-specific effect frame
    self.temperatureEffectFrame = CreateFrame("Frame", "SurvivalModeTemperatureEffectFrame", UIParent)
    self.temperatureEffectFrame:SetFrameStrata("FULLSCREEN")
    self.temperatureEffectFrame:SetFrameLevel(15) -- Higher than regular effects
    self.temperatureEffectFrame:SetAllPoints(UIParent)
    self.temperatureEffectFrame:Hide()
    
    -- Create cold effect (blue border)
    self.temperatureEffectFrame.coldBorders = {}
    local borderWidth = 25
    local borders = {"TOP", "BOTTOM", "LEFT", "RIGHT"}
    
    for _, side in ipairs(borders) do
        local border = self.temperatureEffectFrame:CreateTexture(nil, "OVERLAY", nil, 6)
        border:SetColorTexture(0.1, 0.3, 0.8, 0) -- Blue, initially invisible
        
        if side == "TOP" then
            border:SetPoint("TOPLEFT")
            border:SetPoint("TOPRIGHT") 
            border:SetHeight(borderWidth)
        elseif side == "BOTTOM" then
            border:SetPoint("BOTTOMLEFT")
            border:SetPoint("BOTTOMRIGHT")
            border:SetHeight(borderWidth)
        elseif side == "LEFT" then
            border:SetPoint("TOPLEFT")
            border:SetPoint("BOTTOMLEFT")
            border:SetWidth(borderWidth)
        else -- RIGHT
            border:SetPoint("TOPRIGHT")
            border:SetPoint("BOTTOMRIGHT")
            border:SetWidth(borderWidth)
        end
        
        self.temperatureEffectFrame.coldBorders[side] = border
    end
    
    -- Create heat effect (red/orange overlay)
    self.temperatureEffectFrame.heatOverlay = self.temperatureEffectFrame:CreateTexture(nil, "OVERLAY", nil, 4)
    self.temperatureEffectFrame.heatOverlay:SetAllPoints()
    self.temperatureEffectFrame.heatOverlay:SetColorTexture(1, 0.3, 0, 0) -- Orange tint
    
    -- Create extreme cold effect (screen frost)
    self.temperatureEffectFrame.frostOverlay = self.temperatureEffectFrame:CreateTexture(nil, "OVERLAY", nil, 5)
    self.temperatureEffectFrame.frostOverlay:SetAllPoints()
    self.temperatureEffectFrame.frostOverlay:SetColorTexture(0.7, 0.9, 1, 0) -- Icy blue-white
    
    -- Create pulsing animations
    self.temperatureEffectFrame.coldPulse = self.temperatureEffectFrame:CreateAnimationGroup()
    for _, border in pairs(self.temperatureEffectFrame.coldBorders) do
        local fadeOut = self.temperatureEffectFrame.coldPulse:CreateAnimation("Alpha")
        fadeOut:SetTarget(border)
        fadeOut:SetFromAlpha(0.8)
        fadeOut:SetToAlpha(0.3)
        fadeOut:SetDuration(1.5)
        fadeOut:SetOrder(1)
        
        local fadeIn = self.temperatureEffectFrame.coldPulse:CreateAnimation("Alpha")
        fadeIn:SetTarget(border)
        fadeIn:SetFromAlpha(0.3)
        fadeIn:SetToAlpha(0.8)
        fadeIn:SetDuration(1.5)
        fadeIn:SetOrder(2)
    end
    self.temperatureEffectFrame.coldPulse:SetLooping("REPEAT")
    
    self.temperatureEffectFrame.heatPulse = self.temperatureEffectFrame:CreateAnimationGroup()
    local heatFadeOut = self.temperatureEffectFrame.heatPulse:CreateAnimation("Alpha")
    heatFadeOut:SetTarget(self.temperatureEffectFrame.heatOverlay)
    heatFadeOut:SetFromAlpha(0.6)
    heatFadeOut:SetToAlpha(0.2)
    heatFadeOut:SetDuration(2.0)
    heatFadeOut:SetOrder(1)
    
    local heatFadeIn = self.temperatureEffectFrame.heatPulse:CreateAnimation("Alpha")
    heatFadeIn:SetTarget(self.temperatureEffectFrame.heatOverlay)
    heatFadeIn:SetFromAlpha(0.2)
    heatFadeIn:SetToAlpha(0.6)
    heatFadeIn:SetDuration(2.0)
    heatFadeIn:SetOrder(2)
    self.temperatureEffectFrame.heatPulse:SetLooping("REPEAT")
end

function SurvivalMode:ApplyTemperatureEffects(fahrenheit)
    local effects = self:GetTemperatureEffects(fahrenheit)
    
    if not effects.severity then
        self:ClearTemperatureEffects()
        return
    end
    
    -- Create frame if it doesn't exist
    self:CreateTemperatureEffectFrame()
    
    -- Apply visual screen effects
    if effects.screen_effect then
        self:ApplyScreenEffect(effects.screen_effect, fahrenheit)
    end
    
    -- Show warning message (throttled to every 5 minutes)
    if not self.lastEffectMessage or (GetTime() - self.lastEffectMessage) > 300 then
        self:Print(effects.message)
        self.lastEffectMessage = GetTime()
        
        -- Play warning sound
        if self.db.profile.effects.soundEffects then
            PlaySound(8959, "Master") -- Raid warning sound
        end
    end
end

function SurvivalMode:ApplyScreenEffect(effectType, fahrenheit)
    if not self.temperatureEffectFrame then return end
    
    -- Clear all effects first
    self:ClearTemperatureEffects()
    
    if string.find(effectType, "FREEZE") then
        -- Cold effects
        local intensity = 0.3
        if effectType == "FREEZE_EXTREME" then
            intensity = 0.9
        elseif effectType == "FREEZE_SEVERE" then
            intensity = 0.7
        elseif effectType == "FREEZE_MILD" then
            intensity = 0.4
        end
        
        -- Show blue borders
        for _, border in pairs(self.temperatureEffectFrame.coldBorders) do
            border:SetVertexColor(0.2, 0.5, 1, intensity)
        end
        
        -- Show frost overlay for extreme cold
        if effectType == "FREEZE_EXTREME" then
            self.temperatureEffectFrame.frostOverlay:SetVertexColor(0.7, 0.9, 1, 0.3)
        end
        
        -- Start pulsing for severe cold
        if effectType == "FREEZE_EXTREME" or effectType == "FREEZE_SEVERE" then
            if not self.temperatureEffectFrame.coldPulse:IsPlaying() then
                self.temperatureEffectFrame.coldPulse:Play()
            end
        end
        
        self.temperatureEffectFrame:Show()
        
    elseif string.find(effectType, "HEAT") then
        -- Heat effects
        local intensity = 0.3
        if effectType == "HEAT_EXTREME" then
            intensity = 0.8
        elseif effectType == "HEAT_SEVERE" then
            intensity = 0.6
        elseif effectType == "HEAT_MILD" then
            intensity = 0.3
        end
        
        -- Show heat overlay
        self.temperatureEffectFrame.heatOverlay:SetVertexColor(1, 0.4, 0.1, intensity)
        
        -- Start pulsing for extreme heat
        if effectType == "HEAT_EXTREME" then
            if not self.temperatureEffectFrame.heatPulse:IsPlaying() then
                self.temperatureEffectFrame.heatPulse:Play()
            end
        end
        
        self.temperatureEffectFrame:Show()
    end
    
    -- Debug info for visual effects
    if self.db.profile.debug then
        self:DebugPrint(string.format("Applied temperature effect: %s (%.1f°F)", effectType, fahrenheit))
    end
end

function SurvivalMode:ClearTemperatureEffects()
    if not self.temperatureEffectFrame then return end
    
    -- Hide all temperature effects
    for _, border in pairs(self.temperatureEffectFrame.coldBorders or {}) do
        border:SetVertexColor(0.1, 0.3, 0.8, 0)
    end
    
    if self.temperatureEffectFrame.heatOverlay then
        self.temperatureEffectFrame.heatOverlay:SetVertexColor(1, 0.3, 0, 0)
    end
    
    if self.temperatureEffectFrame.frostOverlay then
        self.temperatureEffectFrame.frostOverlay:SetVertexColor(0.7, 0.9, 1, 0)
    end
    
    -- Stop animations
    if self.temperatureEffectFrame.coldPulse and self.temperatureEffectFrame.coldPulse:IsPlaying() then
        self.temperatureEffectFrame.coldPulse:Stop()
    end
    
    if self.temperatureEffectFrame.heatPulse and self.temperatureEffectFrame.heatPulse:IsPlaying() then
        self.temperatureEffectFrame.heatPulse:Stop()
    end
    
    self.temperatureEffectFrame:Hide()
end

function SurvivalMode:UpdateTemperature()
    local stats = self.db.profile.stats
    local currentZone = GetZoneText()
    local subZone = GetSubZoneText()
    
    -- Base temperature for zone (in Fahrenheit)
    local baseTemp = self.ZONE_TEMPERATURES[currentZone] or self.ZONE_TEMPERATURES["*"] or 68
    
    -- Sub-zone modifier
    local subZoneModifier = 0
    if subZone and subZone ~= "" and self.SUBZONE_MODIFIERS[subZone] then
        subZoneModifier = self.SUBZONE_MODIFIERS[subZone]
        if self.db.profile.debug then
            self:DebugPrint(string.format("Sub-zone %s: %+.1f°F modifier", subZone, subZoneModifier))
        end
    end
    
    -- Time of day modifier
    local timeModifier = 0
    local hour, minute = GetGameTime()
    
    -- Check if GetGameTime returned valid values
    if hour and minute then
        if hour >= 0 and hour < 6 then
            timeModifier = -9 -- Night cold (5°C = 9°F)
        elseif hour >= 11 and hour < 15 then
            timeModifier = 9 -- Midday heat (5°C = 9°F)
        end
    end
    
    -- Weather effects (would need WeatherAPI in real implementation)
    local weatherModifier = 0
    
    -- Altitude effects (lose ~1°F per 100 yards altitude)
    local _, _, z = UnitPosition("player")
    local altitudeModifier = 0
    if z then
        altitudeModifier = -(z / 100) * 0.9 -- Lose 0.9°F per 100 yards altitude
    end
    
-- Check for warmth sources
local warmthBonus = 0
local hasSpecificIndoorBonus = false

-- Check for campfire
if self:IsNearCampfire() then
    warmthBonus = warmthBonus + 10
    if self.db.profile.debug then
        self:DebugPrint("Near campfire: +10°F warmth bonus")
    end
end

-- Check for specific indoor locations first (inns, taverns, etc.)
if subZone and subZone ~= "" and self.SUBZONE_MODIFIERS[subZone] then
    local subZoneTemp = self.SUBZONE_MODIFIERS[subZone]
    
    -- Check if this is an inn/tavern (positive bonus >= 3)
    if subZoneTemp >= 3 then
        hasSpecificIndoorBonus = true
        if self.db.profile.debug then
            self:DebugPrint("Specific indoor location: " .. subZone .. " (+:" .. subZoneTemp .. "°F)")
        end
    end
end

-- Apply generic indoor bonus only if no specific indoor bonus exists
if IsIndoors() and not hasSpecificIndoorBonus then
    warmthBonus = warmthBonus + 3  -- Reduced from 10°F
    if self.db.profile.debug then
        self:DebugPrint("Generic indoors: +3°F warmth bonus")
    end
elseif IsIndoors() and hasSpecificIndoorBonus then
    warmthBonus = warmthBonus + 3  -- Small additional bonus for being indoors
    if self.db.profile.debug then
        self:DebugPrint("Indoor bonus (with specific location): +3°F warmth bonus")
    end
end

-- Check for shelter (only if not already indoors)
if not IsIndoors() and self:IsInShelter() then
    warmthBonus = warmthBonus + self:GetShelterTemperatureBonus()
    if self.db.profile.debug then
        self:DebugPrint("In shelter: +" .. self:GetShelterTemperatureBonus() .. "°F warmth bonus")
    end
end
    
    -- Calculate final temperature
    local targetTemp = baseTemp + subZoneModifier + timeModifier + weatherModifier + altitudeModifier + warmthBonus
    
    -- Smooth temperature transitions
    local currentTemp = stats.temperature or 68
    local diff = targetTemp - currentTemp
    stats.temperature = currentTemp + (diff * 0.1) -- 10% change per update
    
    -- Clamp temperature (-58°F to 140°F)
    stats.temperature = math.max(-58, math.min(140, stats.temperature))
    
    -- Apply visual effects only if enabled
    if self.db.profile.difficulty.temperatureEffects and self.db.profile.effects.visualEffects then
        self:ApplyTemperatureEffects(stats.temperature)
    end
    
    -- Debug info
    if self.db.profile.debug then
        local debugInfo = string.format("Temp: %s (Zone: %s, Base: %.1f°F", 
            self:GetTemperatureString(stats.temperature), currentZone, baseTemp)
        
        if subZoneModifier ~= 0 then
            debugInfo = debugInfo .. string.format(", Sub-zone: %+.1f°F", subZoneModifier)
        end
        if warmthBonus > 0 then
            debugInfo = debugInfo .. string.format(", Warmth: +%.1f°F", warmthBonus)
        end
        if altitudeModifier ~= 0 then
            debugInfo = debugInfo .. string.format(", Altitude: %+.1f°F", altitudeModifier)
        end
        
        debugInfo = debugInfo .. ")"
        self:DebugPrint(debugInfo)
    end
end

function SurvivalMode:IsNearCampfire()
    -- Check if we recently created a campfire (within 5 minutes)
    if self.recentCampfire and (GetTime() - self.recentCampfire) < 300 then
        return true
    end
    
    return false
end

function SurvivalMode:GetTemperatureCategory(fahrenheit)
    if fahrenheit < 32 then
        return "freezing", "|cff00ccff" -- Blue
    elseif fahrenheit < 50 then
        return "cold", "|cff66ccff" -- Light blue
    elseif fahrenheit < 60 then
        return "cool", "|cffccffff" -- Very light blue
    elseif fahrenheit <= 75 then
        return "comfortable", "|cffffffff" -- White
    elseif fahrenheit <= 85 then
        return "warm", "|cffffff66" -- Light yellow
    elseif fahrenheit <= 98 then
        return "hot", "|cffffcc00" -- Orange
    elseif fahrenheit <= 110 then
        return "very_hot", "|cffff6600" -- Dark orange
    else
        return "extreme_heat", "|cffff0000" -- Red
    end
end

-- Add campfire tracking to UNIT_SPELLCAST_SUCCEEDED
function SurvivalMode:OnCampfireCreated()
    -- Prevent duplicate messages
    if self.recentCampfireMessage and (GetTime() - self.recentCampfireMessage) < 1 then
        return
    end
    self.recentCampfireMessage = GetTime()
    
    self.recentCampfire = GetTime()
    self:Print("|cff00ff00You build a warming campfire! (+10°F warmth for 5 minutes)|r")
    
    -- Schedule warning
    if self.campfireTimer then
        self:CancelTimer(self.campfireTimer)
    end
    
    self.campfireTimer = self:ScheduleTimer(function()
        if self.recentCampfire and (GetTime() - self.recentCampfire) >= 295 then
            self:Print("|cffffff00Your campfire is about to burn out...|r")
        end
    end, 295) -- Warning at 4:55
    
    -- Schedule expiration
    self:ScheduleTimer(function()
        if self.recentCampfire and (GetTime() - self.recentCampfire) >= 300 then
            self.recentCampfire = nil
            self:Print("|cffffff00Your campfire has burned out.|r")
        end
    end, 300)
end