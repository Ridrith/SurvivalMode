local addonName, ns = ...
local SurvivalMode = ns.SurvivalMode

function SurvivalMode:UpdateSurvivalStats()
    if not self.db.profile.enabled then return end
    
    local stats = self.db.profile.stats
    local decayMult = self.db.profile.difficulty.decayMultiplier
    
    -- Base decay rates per second
    local hungerDecay = 0.0055 * decayMult
    local thirstDecay = 0.0058 * decayMult
    local fatigueDecay = 0.0052 * decayMult
    
    -- Apply Survival Instinct perk (reduces all decay rates)
    local survivalPerk = self:GetPerkRank("survival_instinct")
    if survivalPerk > 0 then
        local modifier = 1 - (0.01 * survivalPerk) -- 1% reduction per rank
        hungerDecay = hungerDecay * modifier
        thirstDecay = thirstDecay * modifier
        fatigueDecay = fatigueDecay * modifier
        
        if self.db.profile.debug then
            self:DebugPrint(string.format("Survival Instinct reducing decay by %d%%", survivalPerk))
        end
    end
    
    -- Movement increases fatigue
    if GetUnitSpeed("player") > 0 then
        local masterPerk = self:GetPerkRank("master_survivor")
        local moveFatigueMult = 1.5  -- Fatigue drains in ~2.5 hours if moving constantly
        moveFatigueMult = moveFatigueMult - (0.1 * masterPerk)  -- 10% better per rank

        fatigueDecay = fatigueDecay * moveFatigueMult

        if self.db.profile.debug then
            self:DebugPrint(string.format("Moving: Fatigue decay x%.2f (Master Survivor Rank: %d)", moveFatigueMult, masterPerk))
        end
    end

    -- Combat increases all decay rates
    if InCombatLockdown() then
        local combatDecayMult = 2.0  -- Drain faster during combat (2.5 hour lifespan)
        hungerDecay = hungerDecay * combatDecayMult
        thirstDecay = thirstDecay * combatDecayMult
        fatigueDecay = fatigueDecay * combatDecayMult

        if self.db.profile.debug then
            self:DebugPrint("Combat: Decay rates increased (x2)")
        end
    end

    -- Debug: Show final decay values
    if self.db.profile.debug then
        self:DebugPrint(string.format("Decay Rates | Hunger: %.4f | Thirst: %.4f | Fatigue: %.4f", hungerDecay, thirstDecay, fatigueDecay))
    end

    -- Update stats
    stats.hunger = math.max(0, stats.hunger - hungerDecay)
    stats.thirst = math.max(0, stats.thirst - thirstDecay)
    stats.fatigue = math.max(0, stats.fatigue - fatigueDecay)
        
    -- Update temperature (handled by Temperature.lua module)
    if self.db.profile.difficulty.temperatureEffects then
        self:UpdateTemperature()
    end
    
    -- Update UI
    self:UpdateStatusBars()
    
    -- Check for critical states (hunger, thirst, fatigue only - temperature handled by Temperature.lua)
    self:CheckCriticalStates()
    
    -- Award experience for survival
    local currentTime = GetTime()
    if not self.lastExpTime or (currentTime - self.lastExpTime) >= 60 then
        self:AddSurvivalExperience(10, "survival")
        self.lastExpTime = currentTime
    end
    
    -- Debug output
    if self.db.profile.debug then
        self:DebugPrint(string.format("Stats - H: %.1f%% T: %.1f%% F: %.1f%% Temp: %s", 
            stats.hunger, stats.thirst, stats.fatigue, self:GetTemperatureString(stats.temperature)))
    end
end

function SurvivalMode:CheckCriticalStates()
    local stats = self.db.profile.stats
    
    -- Check hunger, thirst, and fatigue only
    -- Temperature warnings are now handled by Temperature.lua module
    if stats.hunger <= 0 then
        self:HandleDeath("starvation")
    elseif stats.thirst <= 0 then
        self:HandleDeath("dehydration")
    elseif stats.fatigue <= 0 then
        self:HandleDeath("exhaustion")
    end
    
    -- REMOVED: Old temperature warning system
    -- Temperature effects are now handled by the enhanced Temperature.lua module
    -- which provides proper zone-based temperatures, visual effects, and appropriate warnings
end

function SurvivalMode:HandleDeath(cause)
    -- In WoW we can't actually kill the player, so apply severe debuffs
    self:Print(string.format("|cffff0000CRITICAL: You are dying from %s!|r", cause))
    
    -- Apply a severe debuff (would need custom debuff implementation)
    -- For now, just reset the stat to 5% to give player a chance
    local stats = self.db.profile.stats
    if cause == "starvation" then
        stats.hunger = 5
        self:Print("|cffff0000You need food immediately!|r")
    elseif cause == "dehydration" then
        stats.thirst = 5
        self:Print("|cffff0000You need water immediately!|r")
    elseif cause == "exhaustion" then
        stats.fatigue = 5
        self:Print("|cffff0000You need to rest immediately!|r")
    end
    
    -- Play warning sound
    PlaySound(8959) -- RaidWarning sound
end