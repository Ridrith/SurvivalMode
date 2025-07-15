local addonName, ns = ...

-- Create the addon using AceAddon
ns.SurvivalMode = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceBucket-3.0")
local SurvivalMode = ns.SurvivalMode

-- Make sure LibSharedMedia is available
ns.LSM = LibStub("LibSharedMedia-3.0")

-- Store locale
ns.L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

-- Define defaults BEFORE OnInitialize
local defaults = {
    profile = {
        enabled = true,
        debug = false,
        minimap = {
            hide = false,
        },
        stats = {
            hunger = 100,
            thirst = 100,
            fatigue = 100,
            temperature = 68, -- FIXED: Initialize in Fahrenheit to match Temperature.lua
        },
        ui = {
            locked = false,
            scale = 1.0,
            alpha = 1.0,
            showLabels = true,
            position = {
                point = "CENTER",
                x = 0,
                y = 0,
            },
            barTexture = "Blizzard",
            font = "Arial Narrow",
            fontSize = 12,
            useFahrenheit = true, -- FIXED: Default to Fahrenheit since Temperature.lua uses it internally
        },
        difficulty = {
            decayMultiplier = 1.0,
            sleepQualityMultiplier = 1.0,
            temperatureEffects = true,
        },
        effects = {
            visualEffects = true,
            soundEffects = true,
            debuffs = true,
            temperatureVisualEffects = true, -- NEW: Separate toggle for temperature visuals
        },
        perks = {
            selected = {},
            points = 0,
            experience = 0,
            totalPointsEarned = 0,
        },
    },
}

-- Addon initialization
function SurvivalMode:OnInitialize()
    -- Initialize database
    self.db = LibStub("AceDB-3.0"):New("SurvivalModeDB", defaults, true)
    
    -- Register chat commands
    self:RegisterChatCommand("survivalmode", "ChatCommand")
    self:RegisterChatCommand("sm", "ChatCommand")
    
    -- Initialize systems
    self:InitializePerkSystem()
    self:InitializeShelterSystem()
    self:InitializeConsumptionHooks()
    self:InitializeEffects() -- FIXED: Initialize effects system
    
    -- Setup minimap icon
    self:SetupMinimapIcon()
    
    -- Setup options (moved to after DB is initialized)
    C_Timer.After(0, function()
        self:SetupOptions()
    end)
end

function SurvivalMode:OnEnable()
    if not self.db.profile.enabled then 
        self:Print("Survival Mode is disabled in settings")
        return 
    end
    
    self:Print(ns.L["Addon Enabled"])
    
    -- Register events
    self:RegisterBucketEvent({"UNIT_AURA", "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED"}, 0.5, "UpdatePlayerEffects")
    
    -- Create UI
    self:CreateUI()
    
    -- Start update timer
    self.updateTimer = self:ScheduleRepeatingTimer("UpdateSurvivalStats", 1)
    
    -- Debug: Confirm timer started
    if self.db.profile.debug then
        self:DebugPrint("Update timer started: " .. tostring(self.updateTimer))
    end
    
    -- Initial update
    self:UpdateSurvivalStats()
    self:UpdatePlayerEffects()
    
    -- Force an immediate test update
    C_Timer.After(2, function()
        if self.db.profile.debug then
            self:DebugPrint("Test update after 2 seconds")
            self:UpdateSurvivalStats()
        end
    end)
end

function SurvivalMode:OnDisable()
    self:Print(ns.L["Addon Disabled"])
    
    -- Cancel timers
    if self.updateTimer then
        self:CancelTimer(self.updateTimer)
        self.updateTimer = nil
    end
    
    -- Hide UI
    if self.mainFrame then
        self.mainFrame:Hide()
    end
    
    -- Remove effects
    self:RemoveAllVisualEffects()
    self:RemoveAllDebuffs()
end

function SurvivalMode:SetupMinimapIcon()
    local LDB = LibStub("LibDataBroker-1.1", true)
    local LDBIcon = LibStub("LibDBIcon-1.0", true)
    
    if not LDB then
        -- Create our own simple LDB implementation
        self:CreateSimpleLDB()
        LDB = LibStub("LibDataBroker-1.1")
    end
    
    if LDB then
        self.ldb = LDB:NewDataObject(addonName, {
            type = "launcher",
            icon = "Interface\\Icons\\INV_Misc_Food_15",
            OnClick = function(_, button)
                if button == "LeftButton" then
                    self:ToggleUI()
                elseif button == "RightButton" then
                    self:OpenConfig()
                end
            end,
            OnTooltipShow = function(tooltip)
                tooltip:AddLine("Survival Mode")
                tooltip:AddLine(ns.L["Left-click to toggle UI"], 0.8, 0.8, 0.8)
                tooltip:AddLine(ns.L["Right-click for options"], 0.8, 0.8, 0.8)
                tooltip:AddLine(" ")
                tooltip:AddLine(string.format(ns.L["Hunger: %.1f%%"], self.db.profile.stats.hunger), 0.8, 0.4, 0)
                tooltip:AddLine(string.format(ns.L["Thirst: %.1f%%"], self.db.profile.stats.thirst), 0.2, 0.6, 1)
                tooltip:AddLine(string.format(ns.L["Fatigue: %.1f%%"], self.db.profile.stats.fatigue), 0.8, 0.8, 0.2)
                tooltip:AddLine(string.format(ns.L["Temperature: %.1f°C"], self.db.profile.stats.temperature), 1, 1, 1)
            end,
        })
        
        if LDBIcon then
            LDBIcon:Register(addonName, self.ldb, self.db.profile.minimap)
        end
    end
end

function SurvivalMode:CreateSimpleLDB()
    -- Load the simple LDB implementation
    if not LibStub:GetLibrary("LibDataBroker-1.1", true) then
        -- The LibDataBroker.lua file should handle this
    end
end

function SurvivalMode:ChatCommand(input)
    if not input or input:trim() == "" then
        self:Print(ns.L["Available commands:"])
        self:Print("|cffffff00/sm ui|r - " .. ns.L["Toggle UI"])
        self:Print("|cffffff00/sm config|r - " .. ns.L["Open configuration"])
        self:Print("|cffffff00/sm reset|r - " .. ns.L["Reset survival stats"])
        self:Print("|cffffff00/sm status|r - Show current status")
        self:Print("|cffffff00/sm sleep|r - Start sleeping")
        self:Print("|cffffff00/sm shelter|r - Shelter commands")
        self:Print("|cffffff00/sm campfire|r - Build a campfire")
        self:Print("|cffffff00/sm perks|r - Open perk window")
        self:Print("|cffffff00/sm debug|r - Toggle debug mode")
        self:Print("|cffffff00/sm testperks|r - Test perk effects")
        self:Print("|cffffff00/sm testeffects|r - Test visual effects") -- NEW: Test effects
        self:Print("|cffffff00/sm directtest|r - Direct visual test") -- NEW: Direct test
        self:Print("|cffffff00/sm debugeffects|r - Debug effects system") -- NEW: Debug
        self:Print("|cffffff00/sm forceshow|r - Force show all effects") -- NEW: Force
        return
    end
    
    local command, args = input:match("^(%S*)%s*(.-)$")
    
    if command == "ui" then
        self:ToggleUI()
    elseif command == "config" then
        self:OpenConfig()
    elseif command == "reset" then
        self:ResetStats()
    elseif command == "testeffects" then -- NEW: Test visual effects
        self:TestVisualEffects()
    elseif command == "directtest" then -- NEW: Direct test
        self:TestDirectEffects()
    elseif command == "cleartest" then -- NEW: Clear direct test
        self:ClearTestEffects()
    elseif command == "debugeffects" then -- NEW: Debug effects
        self:DebugEffectsSystem()
    elseif command == "forceshow" then -- NEW: Force show effects
        self:ForceShowEffects()
    elseif command == "clearforced" then -- NEW: Clear forced effects
        self:ClearForcedEffects()
    elseif command == "status" then
        self:Print("|cff00ff00=== Survival Mode Status ===|r")
        self:Print("Addon enabled: " .. tostring(self.db.profile.enabled))
        self:Print("Update timer: " .. tostring(self.updateTimer))
        self:Print(string.format("Hunger: %.1f%%", self.db.profile.stats.hunger))
        self:Print(string.format("Thirst: %.1f%%", self.db.profile.stats.thirst))
        self:Print(string.format("Fatigue: %.1f%%", self.db.profile.stats.fatigue))
        self:Print(string.format("Temperature: %s", self:GetTemperatureString(self.db.profile.stats.temperature)))
        self:Print("Zone: " .. GetZoneText())
        self:Print("Decay multiplier: " .. self.db.profile.difficulty.decayMultiplier)
        self:Print("Temperature effects: " .. tostring(self.db.profile.difficulty.temperatureEffects))
        
        -- Test a manual update
        self:Print("|cffffff00Running manual update...|r")
        self:UpdateSurvivalStats()
    elseif command == "sleep" then
        self:StartSleeping()
    elseif command == "shelter" then
        -- Handle shelter subcommands directly here
        if args == "build" then
            self:BuildShelter()
        elseif args == "pack" then
            self:PackUpShelter()
        elseif args == "status" then
            if self.currentShelter then
                self:Print(string.format("Current shelter: %s (Quality: %d%%, Temperature Bonus: +10°F)", 
                    self.currentShelter.name, 
                    self.currentShelter.quality * 100))
                    
                if self:IsInShelter() then
                    self:Print("|cff00ff00You are inside your shelter.|r")
                else
                    self:Print("|cffffff00You are too far from your shelter.|r")
                end
            else
                self:Print("No shelter built.")
            end
        elseif args == "list" then
            self:CanBuildShelter() -- Force load
            
            -- List by searching collection
            self:Print("Searching for tent toys in your collection...")
            local found = false
            local numToys = C_ToyBox.GetNumTotalDisplayedToys()
            
            for i = 1, numToys do
                local toyID = C_ToyBox.GetToyFromIndex(i)
                if toyID then
                    local _, toyName = C_ToyBox.GetToyInfo(toyID)
                    if toyName and (string.find(toyName:lower(), "tent")) then
                        self:Print(string.format("- %s (ID: %d)", toyName, toyID))
                        found = true
                    end
                end
            end
            
            if not found then
                self:Print("|cffff0000No tent toys found in collection.|r")
                self:Print("Get a Gnoll Tent, Market Tent, or Dragonscale Expedition's Expedition Tent!")
            end
        elseif args == "debug" then
            self:DebugCheckToys()
        else
            self:Print("Shelter commands:")
            self:Print("/sm shelter build - Start building a shelter")
            self:Print("/sm shelter pack - Pack up current shelter")
            self:Print("/sm shelter status - Check shelter status")
            self:Print("/sm shelter list - Search for tent toys in collection")
            self:Print("/sm shelter debug - Debug toy detection")
        end
    elseif command == "campfire" then
        self:BuildCampfire()
    elseif command == "perks" then
        self:TogglePerkUI()
    elseif command == "debug" then
        self:ToggleDebug()
    elseif command == "testperks" then
        self:Print("|cff00ff00=== Perk Test ===|r")
        
        -- Test Iron Stomach
        local ironStomach = self:GetPerkRank("iron_stomach")
        self:Print(string.format("Iron Stomach rank: %d (Food +%d%%)", ironStomach, ironStomach * 2))
        
        -- Test Hydration Expert
        local hydration = self:GetPerkRank("hydration_expert")
        self:Print(string.format("Hydration Expert rank: %d (Drinks +%d%%)", hydration, hydration * 2))
        
        -- Test Efficient Sleeper
        local sleeper = self:GetPerkRank("efficient_sleeper")
        self:Print(string.format("Efficient Sleeper rank: %d (Sleep +%d%%)", sleeper, sleeper * 5))
        
        -- Test Survival Instinct
        local survival = self:GetPerkRank("survival_instinct")
        self:Print(string.format("Survival Instinct rank: %d (Decay -%d%%)", survival, survival))
        
        -- Test Master Survivor
        local master = self:GetPerkRank("master_survivor")
        self:Print(string.format("Master Survivor rank: %d (Movement fatigue %s)", 
            master, master > 0 and "reduced" or "normal"))
    else
        self:ChatCommand("")
    end
end

-- NEW: Test visual effects function
function SurvivalMode:TestVisualEffects()
    self:Print("|cff00ff00Testing visual effects...|r")
    
    -- Temporarily lower stats to trigger effects
    local oldStats = {
        hunger = self.db.profile.stats.hunger,
        thirst = self.db.profile.stats.thirst,
        fatigue = self.db.profile.stats.fatigue,
    }
    
    self.db.profile.stats.hunger = 15
    self.db.profile.stats.thirst = 15
    self.db.profile.stats.fatigue = 15
    
    -- Force update effects
    self:UpdatePlayerEffects()
    
    self:Print("Effects should now be visible! Stats temporarily set to 15%.")
    self:Print("Type '/sm reset' to restore your stats to 100%.")
end

-- PerksDB definition
SurvivalMode.PerksDB = {
    -- Tier 1 perks
    {
        id = "iron_stomach",
        name = "Iron Stomach",
        description = "Food items restore 2% more hunger per rank.",
        tier = 1,
        maxRank = 5,
        effectValue = 2,  -- 2% per rank
        effect = function(rank) return 1 + (0.02 * rank) end
    },
    {
        id = "hydration_expert", 
        name = "Hydration Expert",
        description = "Drinks restore 2% more thirst per rank.",
        tier = 1,
        maxRank = 5,
        effectValue = 2,  -- 2% per rank
        effect = function(rank) return 1 + (0.02 * rank) end
    },
    {
        id = "efficient_sleeper",
        name = "Efficient Sleeper",
        description = "Sleep quality improved by 5% per rank.",
        tier = 1,
        maxRank = 5,
        effectValue = 5,  -- 5% per rank
        effect = function(rank) return 1 + (0.05 * rank) end
    },
    
    -- Tier 2 perks
    {
        id = "survival_instinct",
        name = "Survival Instinct",
        description = "All survival stats decay 1% slower per rank.",
        tier = 2,
        maxRank = 5,
        effectValue = 1,  -- 1% per rank
        effect = function(rank) return 1 - (0.01 * rank) end
    },
    {
        id = "master_survivor",
        name = "Master Survivor",
        description = "Fatigue decays 50% slower while moving.",
        tier = 2,
        maxRank = 1,
        effectValue = 50,
        effect = function(rank) return rank > 0 and 0.5 or 1 end
    }
}

-- REMOVED: Stub functions that were overriding real implementations
-- These functions are now properly implemented in their respective modules

function SurvivalMode:GetPerkRank(perkId) 
    if not self.db.profile.perks or not self.db.profile.perks.selected then
        return 0
    end
    return self.db.profile.perks.selected[perkId] or 0
end

function SurvivalMode:DebugPrint(...) 
    if self.db.profile.debug then 
        self:Print("|cff00ff00[DEBUG]|r", ...) 
    end 
end

-- Debug functionality
function SurvivalMode:ToggleDebug()
    self.db.profile.debug = not self.db.profile.debug
    self:Print("Debug mode: " .. (self.db.profile.debug and "|cff00ff00ON|r" or "|cffff0000OFF|r"))
end

-- Simple, direct test that should definitely work
function SurvivalMode:TestDirectEffects()
    self:Print("|cff00ff00Creating direct test effects...|r")
    
    -- Remove any existing test frame
    if self.testFrame then
        self.testFrame:Hide()
        self.testFrame = nil
    end
    
    -- Create a simple test frame
    self.testFrame = CreateFrame("Frame", "SurvivalModeTest", UIParent)
    self.testFrame:SetAllPoints(UIParent)
    self.testFrame:SetFrameStrata("TOOLTIP") -- Very high strata
    self.testFrame:SetFrameLevel(9999) -- Maximum level
    
    -- Create a bright red overlay that should be impossible to miss
    local redOverlay = self.testFrame:CreateTexture(nil, "OVERLAY")
    redOverlay:SetAllPoints()
    redOverlay:SetColorTexture(1, 0, 0, 0.5) -- 50% red overlay
    
    -- Create bright borders
    local topBorder = self.testFrame:CreateTexture(nil, "OVERLAY")
    topBorder:SetPoint("TOPLEFT")
    topBorder:SetPoint("TOPRIGHT")
    topBorder:SetHeight(50)
    topBorder:SetColorTexture(0, 1, 0, 0.8) -- Bright green top border
    
    local bottomBorder = self.testFrame:CreateTexture(nil, "OVERLAY")
    bottomBorder:SetPoint("BOTTOMLEFT")
    bottomBorder:SetPoint("BOTTOMRIGHT")
    bottomBorder:SetHeight(50)
    bottomBorder:SetColorTexture(0, 0, 1, 0.8) -- Bright blue bottom border
    
    -- Create text indicator
    local text = self.testFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    text:SetPoint("CENTER")
    text:SetText("SURVIVAL MODE TEST EFFECTS")
    text:SetTextColor(1, 1, 0, 1) -- Yellow text
    
    -- Show the frame
    self.testFrame:Show()
    
    self:Print("|cff00ff00Test frame created and shown!|r")
    self:Print("You should see: RED screen overlay, GREEN top border, BLUE bottom border, YELLOW text")
    self:Print("Type '/sm cleartest' to remove test effects")
    
    -- Auto-clear after 10 seconds
    C_Timer.After(10, function()
        if self.testFrame then
            self:Print("|cffffff00Test effects auto-cleared after 10 seconds|r")
            self.testFrame:Hide()
        end
    end)
end

function SurvivalMode:ClearTestEffects()
    if self.testFrame then
        self.testFrame:Hide()
        self.testFrame = nil
        self:Print("|cffffff00Test effects cleared|r")
    else
        self:Print("|cffffff00No test effects to clear|r")
    end
end

-- Detailed debugging for the actual effects system
function SurvivalMode:DebugEffectsSystem()
    self:Print("|cff00ff00=== Effects System Debug (v2) ===|r")
    
    -- Check individual effect frames (simplified structure)
    if self.hungerEffect then
        self:Print("✓ Hunger effect exists, shown: " .. tostring(self.hungerEffect:IsShown()))
        self:Print("  Strata: " .. tostring(self.hungerEffect:GetFrameStrata()))
        self:Print("  Level: " .. tostring(self.hungerEffect:GetFrameLevel()))
    else
        self:Print("✗ Hunger effect does NOT exist")
    end
    
    if self.thirstEffect then
        self:Print("✓ Thirst effect exists, shown: " .. tostring(self.thirstEffect:IsShown()))
        self:Print("  Strata: " .. tostring(self.thirstEffect:GetFrameStrata()))
        self:Print("  Level: " .. tostring(self.thirstEffect:GetFrameLevel()))
    else
        self:Print("✗ Thirst effect does NOT exist")
    end
    
    if self.fatigueEffect then
        self:Print("✓ Fatigue effect exists, shown: " .. tostring(self.fatigueEffect:IsShown()))
        self:Print("  Strata: " .. tostring(self.fatigueEffect:GetFrameStrata()))
        self:Print("  Level: " .. tostring(self.fatigueEffect:GetFrameLevel()))
    else
        self:Print("✗ Fatigue effect does NOT exist")
    end
    
    -- Check current stats
    if self.db and self.db.profile and self.db.profile.stats then
        local stats = self.db.profile.stats
        self:Print(string.format("Current stats - H:%.1f T:%.1f F:%.1f", 
            stats.hunger or 0, stats.thirst or 0, stats.fatigue or 0))
        
        -- Check if effects should be active
        local shouldShowHunger = stats.hunger < 40
        local shouldShowThirst = stats.thirst < 40
        local shouldShowFatigue = stats.fatigue < 40
        
        self:Print(string.format("Should show effects - H:%s T:%s F:%s", 
            tostring(shouldShowHunger), tostring(shouldShowThirst), tostring(shouldShowFatigue)))
    else
        self:Print("✗ Stats database not available")
    end
    
    -- Check settings
    if self.db and self.db.profile and self.db.profile.effects then
        self:Print("Visual effects enabled: " .. tostring(self.db.profile.effects.visualEffects))
    else
        self:Print("✗ Effects settings not available")
    end
end

-- Force create and show effects regardless of stats
function SurvivalMode:ForceShowEffects()
    self:Print("|cff00ff00Forcing effects to show (v2)...|r")
    
    -- Make sure effects system is initialized
    if not self.hungerEffect then
        self:InitializeEffects()
    end
    
    -- Force show using the SAME method as the working direct test
    if self.hungerEffect then
        -- Use bright, obvious colors like the working test
        self.hungerEffect.topBorder:SetColorTexture(1, 0, 0, 0.8) -- Bright red
        self.hungerEffect.bottomBorder:SetColorTexture(1, 0, 0, 0.8)
        self.hungerEffect.leftBorder:SetColorTexture(1, 0, 0, 0.8)
        self.hungerEffect.rightBorder:SetColorTexture(1, 0, 0, 0.8)
        self.hungerEffect:Show()
        self:Print("✓ Hunger borders forced to show (bright red)")
    else
        self:Print("✗ Hunger effect frame missing")
    end
    
    if self.thirstEffect then
        self.thirstEffect.overlay:SetColorTexture(0, 0, 1, 0.4) -- Bright blue
        self.thirstEffect:Show()
        self:Print("✓ Thirst overlay forced to show (bright blue)")
    else
        self:Print("✗ Thirst effect frame missing")
    end
    
    if self.fatigueEffect then
        self.fatigueEffect.overlay:SetColorTexture(0, 0, 0, 0.6) -- Dark overlay
        self.fatigueEffect:Show()
        self:Print("✓ Fatigue overlay forced to show (dark)")
    else
        self:Print("✗ Fatigue effect frame missing")
    end
    
    self:Print("Effects forced with high alpha values. Type '/sm clearforced' to clear.")
end

function SurvivalMode:ClearForcedEffects()
    if self.hungerEffect then
        self.hungerEffect:Hide()
    end
    if self.thirstEffect then
        self.thirstEffect:Hide()
    end
    if self.fatigueEffect then
        self.fatigueEffect:Hide()
    end
    self:Print("Forced effects cleared")
end