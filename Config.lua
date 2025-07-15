local addonName, ns = ...

-- Config will be set up by Core.lua when it calls SetupOptions
function ns.SurvivalMode:SetupOptions()
    local self = ns.SurvivalMode
    local L = ns.L
    local LSM = ns.LSM
    local AceConfig = LibStub("AceConfig-3.0")
    local AceConfigDialog = LibStub("AceConfigDialog-3.0")
    
    local options = {
        name = "Survival Mode",
        handler = self,
        type = "group",
        args = {
            general = {
                type = "group",
                name = L["General"],
                order = 1,
                args = {
                    enabled = {
                        type = "toggle",
                        name = L["Enable Survival Mode"],
                        desc = L["Toggle the survival mechanics on/off"],
                        order = 1,
                        get = function() return self.db.profile.enabled end,
                        set = function(_, value)
                            self.db.profile.enabled = value
                            if value then
                                self:OnEnable()
                            else
                                self:OnDisable()
                            end
                        end,
                        width = "full",
                    },
                    minimap = {
                        type = "toggle",
                        name = L["Show Minimap Icon"],
                        desc = L["Toggle the minimap icon"],
                        order = 2,
                        get = function() return not self.db.profile.minimap.hide end,
                        set = function(_, value)
                            self.db.profile.minimap.hide = not value
                            local LDBIcon = LibStub("LibDBIcon-1.0", true)
                            if LDBIcon then
                                if value then
                                    LDBIcon:Show("SurvivalMode")
                                else
                                    LDBIcon:Hide("SurvivalMode")
                                end
                            end
                        end,
                    },
                    resetStats = {
                        type = "execute",
                        name = L["Reset Stats"],
                        desc = L["Reset all survival stats to 100%"],
                        order = 3,
                        func = function() self:ResetStats() end,
                        confirm = true,
                        confirmText = L["Are you sure you want to reset all survival stats?"],
                    },
                },
            },
            ui = {
                type = "group",
                name = L["UI Settings"],
                order = 2,
                args = {
                    locked = {
                        type = "toggle",
                        name = L["Lock Frame"],
                        desc = L["Lock the main frame in place"],
                        order = 1,
                        get = function() return self.db.profile.ui.locked end,
                        set = function(_, value)
                            self.db.profile.ui.locked = value
                            if self.mainFrame then
                                self.mainFrame:SetMovable(not value)
                            end
                        end,
                    },
                    scale = {
                        type = "range",
                        name = L["UI Scale"],
                        desc = L["Adjust the scale of the UI"],
                        order = 2,
                        min = 0.5,
                        max = 2.0,
                        step = 0.1,
                        get = function() return self.db.profile.ui.scale end,
                        set = function(_, value)
                            self.db.profile.ui.scale = value
                            self:UpdateUISettings()
                        end,
                    },
                    alpha = {
                        type = "range",
                        name = L["UI Alpha"],
                        desc = L["Adjust the transparency of the UI"],
                        order = 3,
                        min = 0.1,
                        max = 1.0,
                        step = 0.1,
                        get = function() return self.db.profile.ui.alpha end,
                        set = function(_, value)
                            self.db.profile.ui.alpha = value
                            self:UpdateUISettings()
                        end,
                    },
                    showLabels = {
                        type = "toggle",
                        name = L["Show Bar Labels"],
                        desc = L["Show labels on the status bars"],
                        order = 4,
                        get = function() return self.db.profile.ui.showLabels end,
                        set = function(_, value)
                            self.db.profile.ui.showLabels = value
                            self:UpdateUISettings()
                        end,
                    },
                    useFahrenheit = {
                        type = "toggle",
                        name = L["Use Fahrenheit"],
                        desc = L["Display temperature in Fahrenheit instead of Celsius"],
                        order = 5,
                        get = function() return self.db.profile.ui.useFahrenheit end,
                        set = function(_, value)
                            self.db.profile.ui.useFahrenheit = value
                            self:UpdateStatusBars()
                        end,
                    },
                    barTexture = {
                        type = "select",
                        name = L["Bar Texture"],
                        desc = L["Select the status bar texture"],
                        order = 6,
                        dialogControl = "LSM30_Statusbar",
                        values = LSM:HashTable("statusbar"),
                        get = function() return self.db.profile.ui.barTexture end,
                        set = function(_, value)
                            self.db.profile.ui.barTexture = value
                            self:UpdateUISettings()
                        end,
                    },
                    font = {
                        type = "select",
                        name = L["Font"],
                        desc = L["Select the font"],
                        order = 7,
                        dialogControl = "LSM30_Font",
                        values = LSM:HashTable("font"),
                        get = function() return self.db.profile.ui.font end,
                        set = function(_, value)
                            self.db.profile.ui.font = value
                            self:UpdateUISettings()
                        end,
                    },
                    fontSize = {
                        type = "range",
                        name = L["Font Size"],
                        desc = L["Adjust the font size"],
                        order = 8,
                        min = 8,
                        max = 20,
                        step = 1,
                        get = function() return self.db.profile.ui.fontSize end,
                        set = function(_, value)
                            self.db.profile.ui.fontSize = value
                            self:UpdateUISettings()
                        end,
                    },
                },
            },
            difficulty = {
                type = "group",
                name = L["Difficulty"],
                order = 3,
                args = {
                    decayMultiplier = {
                        type = "range",
                        name = L["Decay Rate Multiplier"],
                        desc = L["Adjust how quickly stats decay"],
                        order = 1,
                        min = 0.1,
                        max = 3.0,
                        step = 0.1,
                        get = function() return self.db.profile.difficulty.decayMultiplier end,
                        set = function(_, value)
                            self.db.profile.difficulty.decayMultiplier = value
                        end,
                    },
                    sleepQualityMultiplier = {
                        type = "range",
                        name = L["Sleep Quality Multiplier"],
                        desc = L["Adjust sleep effectiveness"],
                        order = 2,
                        min = 0.5,
                        max = 2.0,
                        step = 0.1,
                        get = function() return self.db.profile.difficulty.sleepQualityMultiplier end,
                        set = function(_, value)
                            self.db.profile.difficulty.sleepQualityMultiplier = value
                        end,
                    },
                    temperatureEffects = {
                        type = "toggle",
                        name = L["Temperature Effects"],
                        desc = L["Enable temperature system"],
                        order = 3,
                        get = function() return self.db.profile.difficulty.temperatureEffects end,
                        set = function(_, value)
                            self.db.profile.difficulty.temperatureEffects = value
                        end,
                    },
                },
            },
            effects = {
                type = "group",
                name = L["Effects"],
                order = 4,
                args = {
                    visualEffects = {
                        type = "toggle",
                        name = L["Visual Effects"],
                        desc = L["Enable visual effects for status conditions"],
                        order = 1,
                        get = function() return self.db.profile.effects.visualEffects end,
                        set = function(_, value)
                            self.db.profile.effects.visualEffects = value
                            if not value then
                                self:RemoveAllVisualEffects()
                            end
                        end,
                    },
                    soundEffects = {
                        type = "toggle",
                        name = L["Sound Effects"],
                        desc = L["Enable sound effects"],
                        order = 2,
                        get = function() return self.db.profile.effects.soundEffects end,
                        set = function(_, value)
                            self.db.profile.effects.soundEffects = value
                        end,
                    },
                    debuffs = {
                        type = "toggle",
                        name = L["Apply Debuffs"],
                        desc = L["Apply stat debuffs for survival conditions"],
                        order = 3,
                        get = function() return self.db.profile.effects.debuffs end,
                        set = function(_, value)
                            self.db.profile.effects.debuffs = value
                            if not value then
                                self:RemoveAllDebuffs()
                            end
                        end,
                    },
                },
            },
            perks = {
                type = "group",
                name = L["Perks"],
                order = 5,
                args = {
                    openPerks = {
                        type = "execute",
                        name = L["Open Perk Window"],
                        desc = L["Open the survival perks interface"],
                        order = 1,
                        func = function() self:TogglePerkUI() end,
                    },
                    resetPerks = {
                        type = "execute",
                        name = L["Reset Perks"],
                        desc = L["Reset all perks and refund points"],
                        order = 2,
                        func = function() self:ResetPerks() end,
                        confirm = true,
                        confirmText = L["Are you sure you want to reset all perks?"],
                    },
                    grantPoint = {
                        type = "execute",
                        name = L["Grant Perk Point (Debug)"],
                        desc = L["Grant yourself a perk point for testing"],
                        order = 3,
                        func = function() self:GrantPerkPoint() end,
                        hidden = function() return not self.db.profile.debug end,
                    },
                },
            },
        },
    }
    
    -- Register options
    AceConfig:RegisterOptionsTable("SurvivalMode", options)
    
    -- Create the config frame
    self.optionsFrame = AceConfigDialog:AddToBlizOptions("SurvivalMode", "Survival Mode")
    
    -- Register profiles
    options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
    options.args.profiles.order = 999
end

function ns.SurvivalMode:OpenConfig()
    local AceConfigDialog = LibStub("AceConfigDialog-3.0")
    
    -- Try the modern way first (10.0+)
    if Settings and Settings.OpenToCategory then
        Settings.OpenToCategory("Survival Mode")
    else
        -- Fallback to opening the dialog directly
        AceConfigDialog:Open("SurvivalMode")
    end
end

-- Alternative: Create a standalone config window
function ns.SurvivalMode:CreateConfigWindow()
    local AceConfigDialog = LibStub("AceConfigDialog-3.0")
    
    if not self.configWindow then
        local frame = AceConfigDialog:Open("SurvivalMode")
        self.configWindow = frame
    else
        if self.configWindow:IsShown() then
            self.configWindow:Hide()
        else
            self.configWindow:Show()
        end
    end
end