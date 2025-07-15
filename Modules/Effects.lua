-- Modules/Effects.lua

local addonName, ns = ...
local SurvivalMode = ns.SurvivalMode
local LSM = LibStub("LibSharedMedia-3.0")

-- Initialize effects system
function SurvivalMode:InitializeEffects()
    -- Ensure profile and media subtables exist
    if not (self.db and self.db.profile) then return end
    local m = self.db.profile.media
    m = m or {}
    -- Use solid backgrounds for better reliability
    m.hungerBackground  = m.hungerBackground  or "Blizzard Dialog Background"
    m.thirstBackground  = m.thirstBackground  or "Blizzard Dialog Background"
    m.fatigueBackground = m.fatigueBackground or "Blizzard Dialog Background"
    self.db.profile.media = m

    -- Initialize tables
    self.activeEffects   = self.activeEffects   or {}
    self.soundCooldowns  = self.soundCooldowns  or {}
    self.effectFrames    = self.effectFrames    or {}

    -- Build overlays
    self:CreateOverlayFrames()

    -- Start the update timer
    if not self.effectUpdateTimer then
        self.effectUpdateTimer = self:ScheduleRepeatingTimer("UpdatePlayerEffects", 0.5)
    end

    self:Print("|cff00ff00Effects system initialized (v4)|r")
end

-- Build all three effect frames with consistent overlay approach
function SurvivalMode:CreateOverlayFrames()
    ----------------------------------------------------------------
    -- HUNGER EFFECTS (Red overlay + border effect)
    ----------------------------------------------------------------
    if not self.hungerEffect then
        local f = CreateFrame("Frame", "SurvivalModeHungerEffect", UIParent)
        f:SetAllPoints(UIParent)
        f:SetFrameStrata("TOOLTIP")
        f:SetFrameLevel(9998)

        -- Main overlay
        local bgTex = LSM:Fetch("background", self.db.profile.media.hungerBackground) or "Interface\\Tooltips\\UI-Tooltip-Background"
        local overlay = f:CreateTexture(nil, "OVERLAY")
        overlay:SetTexture(bgTex)
        overlay:SetAllPoints()
        overlay:SetVertexColor(1, 0.2, 0.2, 0) -- Red, start invisible
        f.overlay = overlay

        -- Border effect - simple edge highlighting
        local borderSize = 8
        for _, side in ipairs({"top", "bottom", "left", "right"}) do
            local border = f:CreateTexture(nil, "OVERLAY")
            border:SetTexture(bgTex)
            border:SetVertexColor(1, 0, 0, 0) -- Bright red borders, start invisible
            
            if side == "top" then
                border:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
                border:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)
                border:SetHeight(borderSize)
            elseif side == "bottom" then
                border:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, 0)
                border:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0)
                border:SetHeight(borderSize)
            elseif side == "left" then
                border:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
                border:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, 0)
                border:SetWidth(borderSize)
            else -- right
                border:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)
                border:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0)
                border:SetWidth(borderSize)
            end
            
            f[side.."Border"] = border
        end

        -- Pulse animation
        local ag = f:CreateAnimationGroup()
        ag:SetLooping("BOUNCE")
        local alpha = ag:CreateAnimation("Alpha")
        alpha:SetFromAlpha(0.3)
        alpha:SetToAlpha(1.0)
        alpha:SetDuration(1.5)
        f.pulseAnim = ag

        f:Hide()
        self.hungerEffect = f
    end

    ----------------------------------------------------------------
    -- THIRST EFFECTS (Blue overlay)
    ----------------------------------------------------------------
    if not self.thirstEffect then
        local f = CreateFrame("Frame", "SurvivalModeThirstEffect", UIParent)
        f:SetAllPoints(UIParent)
        f:SetFrameStrata("TOOLTIP")
        f:SetFrameLevel(9997)

        local bgTex = LSM:Fetch("background", self.db.profile.media.thirstBackground) or "Interface\\Tooltips\\UI-Tooltip-Background"
        local overlay = f:CreateTexture(nil, "OVERLAY")
        overlay:SetTexture(bgTex)
        overlay:SetAllPoints()
        overlay:SetVertexColor(0.1, 0.3, 0.8, 0) -- Blue, start invisible
        f.overlay = overlay

        -- Pulse animation
        local ag = f:CreateAnimationGroup()
        ag:SetLooping("BOUNCE")
        local alpha = ag:CreateAnimation("Alpha")
        alpha:SetFromAlpha(0.3)
        alpha:SetToAlpha(1.0)
        alpha:SetDuration(1.2)
        f.pulseAnim = ag

        f:Hide()
        self.thirstEffect = f
    end

    ----------------------------------------------------------------
    -- FATIGUE EFFECTS (Dark overlay)
    ----------------------------------------------------------------
    if not self.fatigueEffect then
        local f = CreateFrame("Frame", "SurvivalModeFatigueEffect", UIParent)
        f:SetAllPoints(UIParent)
        f:SetFrameStrata("TOOLTIP")
        f:SetFrameLevel(9996)

        local bgTex = LSM:Fetch("background", self.db.profile.media.fatigueBackground) or "Interface\\Tooltips\\UI-Tooltip-Background"
        local overlay = f:CreateTexture(nil, "OVERLAY")
        overlay:SetTexture(bgTex)
        overlay:SetAllPoints()
        overlay:SetVertexColor(0.1, 0.1, 0.1, 0) -- Dark gray, start invisible
        f.overlay = overlay

        -- Pulse animation (slower for fatigue)
        local ag = f:CreateAnimationGroup()
        ag:SetLooping("BOUNCE")
        local alpha = ag:CreateAnimation("Alpha")
        alpha:SetFromAlpha(0.3)
        alpha:SetToAlpha(0.8)
        alpha:SetDuration(2.0)
        f.pulseAnim = ag

        f:Hide()
        self.fatigueEffect = f
    end

    self:Print("|cff00ff00Visual effect frames created (v4)|r")
end

-- Core update loop: hunger, thirst, fatigue, then temperature
function SurvivalMode:UpdatePlayerEffects()
    if not (self.db and self.db.profile and self.db.profile.stats and self.db.profile.effects) then return end
    if not self.db.profile.effects.visualEffects then
        self:RemoveAllVisualEffects()
        return
    end

    local stats = self.db.profile.stats

    -- Hunger (≤20%)
    if stats.hunger <= 20 then
        self:ApplyHungerEffect(stats.hunger)
        if self.db.profile.effects.soundEffects then
            self:PlayEffectSound("hunger", 192382, 20)
        end
    else
        self:RemoveHungerEffect()
    end

    -- Thirst (≤20%)
    if stats.thirst <= 20 then
        self:ApplyThirstEffect(stats.thirst)
        if self.db.profile.effects.soundEffects then
            self:PlayEffectSound("thirst", 192382, 20)
        end
    else
        self:RemoveThirstEffect()
    end

    -- Fatigue (≤20%)
    if stats.fatigue <= 20 then
        self:ApplyFatigueEffect(stats.fatigue)
        if self.db.profile.effects.soundEffects then
            self:PlayEffectSound("fatigue", 192382, 20)
        end
    else
        self:RemoveFatigueEffect()
    end

    if self.db.profile.effects.debuffs then
        self:UpdateDebuffs(stats)
    end

    -- Temperature overlays
    if self.db.profile.difficulty.temperatureEffects and self.db.profile.effects.visualEffects then
        self:UpdateTemperature()
    end
end

-- Apply hunger effect with red overlay and bright red borders
function SurvivalMode:ApplyHungerEffect(hungerLevel)
    local f = self.hungerEffect
    if not f then return end
    
    -- Calculate intensity (lower hunger = higher intensity)
    local intensity = math.max(0, (20 - hungerLevel) / 20)
    local overlayAlpha = 0.1 + (intensity * 0.3) -- Subtle red overlay
    local borderAlpha = 0.3 + (intensity * 0.7)  -- More intense borders
    
    -- Set overlay alpha
    f.overlay:SetVertexColor(1, 0.2, 0.2, overlayAlpha)
    
    -- Set border alpha
    for _, side in ipairs({"top", "bottom", "left", "right"}) do
        if f[side.."Border"] then
            f[side.."Border"]:SetVertexColor(1, 0, 0, borderAlpha)
        end
    end
    
    -- Show and start pulsing
    f:Show()
    if not f.pulseAnim:IsPlaying() then 
        f.pulseAnim:Play() 
    end
    
    if self.db.profile.debug then
        self:DebugPrint(("Hunger: %.1f%% → intensity=%.2f, overlay α=%.2f, border α=%.2f"):format(hungerLevel, intensity, overlayAlpha, borderAlpha))
    end
end

function SurvivalMode:RemoveHungerEffect()
    if self.hungerEffect then
        self.hungerEffect:Hide()
        self.hungerEffect.pulseAnim:Stop()
    end
end

-- Apply thirst effect with blue overlay
function SurvivalMode:ApplyThirstEffect(thirstLevel)
    local f = self.thirstEffect
    if not f then return end
    
    -- Calculate intensity (lower thirst = higher intensity)
    local intensity = math.max(0, (20 - thirstLevel) / 20)
    local alpha = 0.15 + (intensity * 0.4)
    
    f.overlay:SetVertexColor(0.1, 0.3, 0.8, alpha)
    f:Show()
    if not f.pulseAnim:IsPlaying() then 
        f.pulseAnim:Play() 
    end
    
    if self.db.profile.debug then
        self:DebugPrint(("Thirst: %.1f%% → intensity=%.2f, α=%.2f"):format(thirstLevel, intensity, alpha))
    end
end

function SurvivalMode:RemoveThirstEffect()
    if self.thirstEffect then
        self.thirstEffect:Hide()
        self.thirstEffect.pulseAnim:Stop()
    end
end

-- Apply fatigue effect with dark overlay
function SurvivalMode:ApplyFatigueEffect(fatigueLevel)
    local f = self.fatigueEffect
    if not f then return end
    
    -- Calculate intensity (lower fatigue = higher intensity)
    local intensity = math.max(0, (20 - fatigueLevel) / 20)
    local alpha = 0.15 + (intensity * 0.5)
    
    f.overlay:SetVertexColor(0.1, 0.1, 0.1, alpha)
    f:Show()
    if not f.pulseAnim:IsPlaying() then 
        f.pulseAnim:Play() 
    end
    
    if self.db.profile.debug then
        self:DebugPrint(("Fatigue: %.1f%% → intensity=%.2f, α=%.2f"):format(fatigueLevel, intensity, alpha))
    end
end

function SurvivalMode:RemoveFatigueEffect()
    if self.fatigueEffect then
        self.fatigueEffect:Hide()
        self.fatigueEffect.pulseAnim:Stop()
    end
end

-- Sound helper
function SurvivalMode:PlayEffectSound(effectType, soundID, cooldown)
    self.soundCooldowns = self.soundCooldowns or {}
    local now = GetTime()
    if now - (self.soundCooldowns[effectType] or 0) >= cooldown then
        PlaySound(soundID, "SFX")
        self.soundCooldowns[effectType] = now
    end
end

-- Debug debuffs
function SurvivalMode:UpdateDebuffs(stats)
    if not self.db.profile.debug then return end
    local count = 0
    if stats.hunger <= 20 then count = count + 1 end
    if stats.thirst <= 20 then count = count + 1 end
    if stats.fatigue <= 20 then count = count + 1 end
    if count > 0 then 
        self:DebugPrint(("Active survival debuffs: %d"):format(count)) 
    end
end

-- Cleanup functions
function SurvivalMode:RemoveAllVisualEffects()
    self:RemoveHungerEffect()
    self:RemoveThirstEffect()
    self:RemoveFatigueEffect()
    if self.db.profile.debug then 
        self:DebugPrint("All visual effects removed") 
    end
end

function SurvivalMode:RemoveAllDebuffs() 
    -- Placeholder for debuff removal if needed
end

function SurvivalMode:CleanupEffects()
    if self.effectUpdateTimer then
        self:CancelTimer(self.effectUpdateTimer)
        self.effectUpdateTimer = nil
    end
    self:RemoveAllVisualEffects()
    self:RemoveAllDebuffs()
    if self.db.profile.debug then
        self:DebugPrint("Effects system cleaned up")
    end
end