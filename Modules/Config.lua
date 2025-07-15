local addonName, ns = ...
local SurvivalMode = ns.SurvivalMode
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

function SurvivalMode:SetupOptions()
    local options = {
        name = "Survival Mode",
        handler = SurvivalMode,
        type = "group",
        args = {
            general = {
                name = "General",
                type = "group",
                order = 1,
                args = {
                    enabled = {
                        name = "Enable Survival Mode",
                        desc = "Toggle the addon on/off",
                        type = "toggle",
                        order = 1,
                        set = function(info, val)
                            self.db.profile.enabled = val
                            if val then
                                self:Enable()
                            else
                                self:Disable()
                            end
                        end,
                        get = function(info) return self.db.profile.enabled end,
                    },
                    minimap = {
                        name = "Show Minimap Icon",
                        desc = "Toggle the minimap icon",
                        type = "toggle",
                        order = 2,
                        set = function(info, val)
                            self.db.profile.minimap.hide = not val
                            if LibStub("LibDBIcon-1.0", true) then
                                if val then
                                    LibStub("LibDBIcon-1.0"):Show("SurvivalMode")
                                else
                                    LibStub("LibDBIcon-1.0"):Hide("SurvivalMode")
                                end
                            end
                        end,
                        get = function(info) return not self.db.profile.minimap.hide end,
                    },
                    debug = {
                        name = "Debug Mode",
                        desc = "Enable debug messages",
                        type = "toggle",
                        order = 3,
                        set = function(info, val) self.db.profile.debug = val end,
                        get = function(info) return self.db.profile.debug end,
                    },
                },
            },
            ui = {
                name = "Interface",
                type = "group",
                order = 2,
                args = {
                    scale = {
                        name = "UI Scale",
                        desc = "Scale of the survival UI",
                        type = "range",
                        order = 1,
                        min = 0.5,
                        max = 2.0,
                        step = 0.1,
                        set = function(info, val)
                            self.db.profile.ui.scale = val
                            self:UpdateUISettings()
                        end,
                        get = function(info) return self.db.profile.ui.scale end,
                    },
                    alpha = {
                        name = "UI Transparency",
                        desc = "Transparency of the survival UI",
                        type = "range",
                        order = 2,
                        min = 0.1,
                        max = 1.0,
                        step = 0.1,
                        set = function(info, val)
                            self.db.profile.ui.alpha = val
                            self:UpdateUISettings()
                        end,
                        get = function(info) return self.db.profile.ui.alpha end,
                    },
                    locked = {
                        name = "Lock UI",
                        desc = "Lock the UI in place",
                        type = "toggle",
                        order = 3,
                        set = function(info, val)
                            self.db.profile.ui.locked = val
                            self:UpdateUISettings()
                        end,
                        get = function(info) return self.db.profile.ui.locked end,
                    },
                    showLabels = {
                        name = "Show Labels",
                        desc = "Show stat names on bars",
                        type = "toggle",
                        order = 4,
                        set = function(info, val)
                            self.db.profile.ui.showLabels = val
                            self:UpdateStatusBars()
                        end,
                        get = function(info) return self.db.profile.ui.showLabels end,
                    },
                    barTexture = {
                        name = "Bar Texture",
                        desc = "Texture for the status bars",
                        type = "select",
                        order = 5,
                        dialogControl = "LSM30_Statusbar",
                        values = AceGUIWidgetLSMlists.statusbar,
                        set = function(info, val)
                            self.db.profile.ui.barTexture = val
                            self:UpdateUISettings()
                        end,
                        get = function(info) return self.db.profile.ui.barTexture end,
                    },
                    font = {
                        name = "Font",
                        desc = "Font for text",
                        type = "select",
                        order = 6,
                        dialogControl = "LSM30_Font",
                        values = AceGUIWidgetLSMlists.font,
                        set = function(info, val)
                            self.db.profile.ui.font = val
                            self:UpdateUISettings()
                        end,
                        get = function(info) return self.db.profile.ui.font end,
                    },
                    fontSize = {
                        name = "Font Size",
                        desc = "Size of the font",
                        type = "range",
                        order = 7,
                        min = 8,
                        max = 20,
                        step = 1,
                        set = function(info, val)
                            self.db.profile.ui.fontSize = val
                            self:UpdateUISettings()
                        end,
                        get = function(info) return self.db.profile.ui.fontSize end,
                    },
                    useFahrenheit = {
                        name = "Use Fahrenheit",
                        desc = "Display temperature in Fahrenheit instead of Celsius",
                        type = "toggle",
                        order = 8,
                        set = function(info, val)
                            self.db.profile.ui.useFahrenheit = val
                            self:UpdateStatusBars()
                        end,
                        get = function(info) return self.db.profile.ui.useFahrenheit end,
                    },
                },
            },
            difficulty = {
                name = "Difficulty",
                type = "group",
                order = 3,
                args = {
                    decayMultiplier = {
                        name = "Stat Decay Rate",
                        desc = "How fast survival stats decrease (1.0 = normal, 0.5 = half speed, 2.0 = double speed)",
                        type = "range",
                        order = 1,
                        min = 0.1,
                        max = 3.0,
                        step = 0.1,
                        set = function(info, val) self.db.profile.difficulty.decayMultiplier = val end,
                        get = function(info) return self.db.profile.difficulty.decayMultiplier end,
                    },
                    sleepQualityMultiplier = {
                        name = "Sleep Recovery Rate",
                        desc = "How effective sleeping is (1.0 = normal, 2.0 = double effectiveness)",
                        type = "range",
                        order = 2,
                        min = 0.5,
                        max = 3.0,
                        step = 0.1,
                        set = function(info, val) self.db.profile.difficulty.sleepQualityMultiplier = val end,
                        get = function(info) return self.db.profile.difficulty.sleepQualityMultiplier end,
                    },
                    temperatureEffects = {
                        name = "Temperature Effects",
                        desc = "Enable temperature-based effects on stats",
                        type = "toggle",
                        order = 3,
                        set = function(info, val) self.db.profile.difficulty.temperatureEffects = val end,
                        get = function(info) return self.db.profile.difficulty.temperatureEffects end,
                    },
                },
            },
            effects = {
                name = "Effects",
                type = "group",
                order = 4,
                args = {
                    visualEffects = {
                        name = "Visual Effects",
                        desc = "Enable visual effects like screen darkening",
                        type = "toggle",
                        order = 1,
                        set = function(info, val) self.db.profile.effects.visualEffects = val end,
                        get = function(info) return self.db.profile.effects.visualEffects end,
                    },
                    soundEffects = {
                        name = "Sound Effects",
                        desc = "Enable sound effects for warnings",
                        type = "toggle",
                        order = 2,
                        set = function(info, val) self.db.profile.effects.soundEffects = val end,
                        get = function(info) return self.db.profile.effects.soundEffects end,
                    },
                    debuffs = {
                        name = "Debuffs",
                        desc = "Enable movement speed and other debuffs",
                        type = "toggle",
                        order = 3,
                        set = function(info, val) self.db.profile.effects.debuffs = val end,
                        get = function(info) return self.db.profile.effects.debuffs end,
                    },
                },
            },
            commands = {
                name = "Commands",
                type = "group",
                order = 5,
                args = {
                    help = {
                        name = "Command List",
                        type = "description",
                        order = 1,
                        fontSize = "medium",
                        desc = [[
|cff00ff00Survival Mode Commands:|r

|cffffff00/sm ui|r - Toggle the survival UI
|cffffff00/sm config|r - Open this configuration panel
|cffffff00/sm reset|r - Reset all stats to 100%
|cffffff00/sm status|r - Show current status
|cffffff00/sm sleep|r - Start sleeping
|cffffff00/sm shelter build|r - Build a shelter
|cffffff00/sm shelter pack|r - Pack up shelter
|cffffff00/sm campfire|r - Campfire instructions
|cffffff00/sm perks|r - Open perk window
|cffffff00/sm tutorial|r - Restart tutorial
]],
                    },
                },
            },
        },
    }
    
    AceConfig:RegisterOptionsTable("SurvivalMode", options)
    
    -- Check if we're using the new Settings API (10.0+) or the old InterfaceOptions
    if Settings and Settings.RegisterAddOnCategory then
        -- New Settings API (Dragonflight+)
        local category = Settings.RegisterCanvasLayoutCategory(AceConfigDialog:AddToBlizOptions("SurvivalMode", "Survival Mode"), "Survival Mode")
        category.ID = "SurvivalMode"
        Settings.RegisterAddOnCategory(category)
        self.settingsCategory = category
    else
        -- Old InterfaceOptions API
        self.optionsFrame = AceConfigDialog:AddToBlizOptions("SurvivalMode", "Survival Mode")
    end
end

function SurvivalMode:OpenConfig()
    -- Try the new Settings API first
    if Settings and Settings.OpenToCategory and self.settingsCategory then
        Settings.OpenToCategory(self.settingsCategory.ID)
    elseif InterfaceOptionsFrame_OpenToCategory then
        -- Fallback to old API
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame) -- Call twice due to Blizzard bug
    else
        -- Ultimate fallback - open AceConfig dialog directly
        AceConfigDialog:Open("SurvivalMode")
    end
end