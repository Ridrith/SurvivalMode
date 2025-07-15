local addonName, ns = ...
local SurvivalMode = ns.SurvivalMode

-- Toy/Spell IDs for shelter items - Updated with correct IDs
SurvivalMode.SHELTER_TOYS = {
    [198087] = {name = "Dragonscale Expedition's Expedition Tent", quality = 0.9, spellId = 385063},
    [200095] = {name = "Market Tent", quality = 0.7, spellId = 389278},
    [64631] = {name = "Gnoll Tent", quality = 0.6, spellId = 89614},  -- Fixed ID
}

function SurvivalMode:InitializeShelterSystem()
    self.shelters = self.shelters or {}
    self.currentShelter = nil
    self.awaitingShelter = false
    
    -- Only register event once
    if not self.shelterSystemInitialized then
        self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
        self.shelterSystemInitialized = true
    end
    
    -- Force load toy box
    C_ToyBox.SetIsFavorite(1, false) -- This forces toy box to load
    
    -- Debug: Check toy loading after a delay
    C_Timer.After(2, function()
        if self.db.profile.debug then
            self:DebugCheckToys()
        end
    end)
end

function SurvivalMode:DebugCheckToys()
    self:Print("|cff00ff00[DEBUG] Checking toy collection:|r")
    
    -- Method 1: Direct check
    for toyId, shelterData in pairs(self.SHELTER_TOYS) do
        local hasToy = PlayerHasToy(toyId)
        local isUsable = C_ToyBox.IsToyUsable(toyId)
        local toyInfo = C_ToyBox.GetToyInfo(toyId)
        self:Print(string.format("Toy %d (%s): Has=%s, Usable=%s, Name=%s", 
            toyId, 
            shelterData.name, 
            tostring(hasToy), 
            tostring(isUsable),
            tostring(toyInfo)))
    end
    
    -- Method 2: Search through all toys
    self:Print("|cff00ff00Searching for tent toys in collection:|r")
    local numToys = C_ToyBox.GetNumTotalDisplayedToys()
    for i = 1, numToys do
        local toyID = C_ToyBox.GetToyFromIndex(i)
        if toyID then
            local _, toyName = C_ToyBox.GetToyInfo(toyID)
            if toyName and (string.find(toyName:lower(), "tent") or string.find(toyName:lower(), "expedition")) then
                self:Print(string.format("Found: %s (ID: %d)", toyName, toyID))
            end
        end
    end
end

function SurvivalMode:UNIT_SPELLCAST_SUCCEEDED(event, unit, castGUID, spellID)
    if unit ~= "player" then return end
    
    -- Prevent double processing of same cast
    if self.lastProcessedCast == castGUID then return end
    self.lastProcessedCast = castGUID
    
    -- Debug spell casts
    if self.db.profile.debug then
        -- Get spell name using C_Spell API
        local spellInfo = C_Spell.GetSpellInfo(spellID)
        local spellName = spellInfo and spellInfo.name or "Unknown"
        
        if string.find(spellName:lower(), "tent") or string.find(spellName:lower(), "campfire") or spellID == 818 then
            self:DebugPrint(string.format("Cast detected: %s (ID: %d)", spellName, spellID))
        end
    end
    
    -- Check for campfire FIRST (before tent checks)
    if spellID == 818 then -- Basic Campfire
        self:OnCampfireCreated()
        return
    end
    
    -- Check if it's a shelter spell
    for toyId, shelterData in pairs(self.SHELTER_TOYS) do
        if spellID == shelterData.spellId then
            self:BuildShelterFromToy(toyId, shelterData)
            return
        end
    end
    
    -- Alternative: Check by spell name for any tent
    local spellInfo = C_Spell.GetSpellInfo(spellID)
    local spellName = spellInfo and spellInfo.name
    
    if spellName and (string.find(spellName:lower(), "tent") or string.find(spellName:lower(), "expedition")) then
        -- Generic tent detected
        self:BuildGenericShelter(spellID, spellName)
        return
    end
    
    -- Special case: The spell ID 233594 seems to be a tent spell
    if spellID == 233594 then
        self:BuildGenericShelter(spellID, "Tent")
        return
    end
end

function SurvivalMode:BuildGenericShelter(spellID, spellName)
    -- Generic shelter for unrecognized tents
    if self.currentShelter then
        self:Print("You already have a shelter built! Pack it up first.")
        return false
    end
    
    local mapID = C_Map.GetBestMapForUnit("player")
    local position = C_Map.GetPlayerMapPosition(mapID, "player")
    
    if not position then
        self:Print("Cannot determine location!")
        return false
    end
    
    local shelter = {
        id = spellID,
        name = spellName or "Tent",
        quality = 0.7, -- Default quality
        position = {
            mapID = mapID,
            x = position.x,
            y = position.y,
        },
        buildTime = GetTime(),
    }
    
    self.currentShelter = shelter
    self.awaitingShelter = false
    table.insert(self.shelters, shelter)
    
    -- Calculate temperature bonus based on quality (base 10°F, quality affects it)
    local tempBonus = 10 * shelter.quality
    
    self:Print(string.format("|cff00ff00You've set up a %s!|r (Quality: %d%%, Temperature Bonus: +%.1f°F)", 
        shelter.name, shelter.quality * 100, tempBonus))
    
    if self.shelterTimer then
        self:CancelTimer(self.shelterTimer)
    end
    self.shelterTimer = self:ScheduleTimer("AutoPackUpShelter", 300)
    
    return true
end

function SurvivalMode:BuildShelterFromToy(toyId, shelterData)
    -- Check if already in shelter
    if self.currentShelter then
        self:Print("You already have a shelter built! Pack it up first.")
        return false
    end
    
    -- Get player position
    local mapID = C_Map.GetBestMapForUnit("player")
    local position = C_Map.GetPlayerMapPosition(mapID, "player")
    
    if not position then
        self:Print("Cannot determine location!")
        return false
    end
    
    -- Create shelter
    local shelter = {
        id = toyId,
        name = shelterData.name,
        quality = shelterData.quality,
        position = {
            mapID = mapID,
            x = position.x,
            y = position.y,
        },
        buildTime = GetTime(),
    }
    
    self.currentShelter = shelter
    self.awaitingShelter = false
    table.insert(self.shelters, shelter)
    
    -- Calculate temperature bonus based on quality (base 10°F, quality affects it)
    local tempBonus = 10 * shelterData.quality
    
    self:Print(string.format("|cff00ff00You've set up a %s!|r (Quality: %d%%, Temperature Bonus: +%.1f°F)", 
        shelterData.name, shelterData.quality * 100, tempBonus))
    
    -- Schedule automatic pack up after 5 minutes (tent duration)
    if self.shelterTimer then
        self:CancelTimer(self.shelterTimer)
    end
    self.shelterTimer = self:ScheduleTimer("AutoPackUpShelter", 300)
    
    return true
end

function SurvivalMode:AutoPackUpShelter()
    if self.currentShelter then
        self:Print("Your shelter has expired.")
        self:PackUpShelter()
    end
end

function SurvivalMode:GetShelterTemperatureBonus()
    if not self.currentShelter or not self:IsInShelter() then
        return 0
    end
    
    -- Base shelter provides 10°F warmth, modified by quality
    return 10 * self.currentShelter.quality
end

function SurvivalMode:CanBuildShelter()
    -- Force toy box to load
    C_ToyBox.SetIsFavorite(1, false)
    
    -- Check if player has any shelter toys
    local availableToys = {}
    
    for toyId, shelterData in pairs(self.SHELTER_TOYS) do
        if PlayerHasToy(toyId) then
            availableToys[toyId] = shelterData
        end
    end
    
    -- Also check by searching toy collection
    local numToys = C_ToyBox.GetNumTotalDisplayedToys()
    for i = 1, numToys do
        local toyID = C_ToyBox.GetToyFromIndex(i)
        if toyID then
            local _, toyName = C_ToyBox.GetToyInfo(toyID)
            if toyName and (string.find(toyName:lower(), "tent") or 
                          string.find(toyName:lower(), "expedition tent") or
                          string.find(toyName:lower(), "market tent") or
                          string.find(toyName:lower(), "gnoll tent")) then
                -- Found a tent toy
                if not availableToys[toyID] then
                    availableToys[toyID] = {
                        name = toyName,
                        quality = 0.7,
                        spellId = 0 -- We'll detect by name
                    }
                end
            end
        end
    end
    
    local count = 0
    for _ in pairs(availableToys) do count = count + 1 end
    
    return count > 0, availableToys
end

function SurvivalMode:BuildShelter()
    local canBuild, availableToys = self:CanBuildShelter()
    
    if not canBuild then
        self:Print("|cffff0000You need a tent toy to build a shelter!|r")
        self:Print("Available tents: Gnoll Tent, Market Tent, or Dragonscale Expedition's Expedition Tent")
        
        -- Debug mode: search for tents
        if self.db.profile.debug then
            self:DebugCheckToys()
        end
        
        return false
    end
    
    -- Check if in combat
    if InCombatLockdown() then
        self:Print("|cffff0000You cannot build a shelter while in combat!|r")
        return false
    end
    
    -- Check if already in shelter
    if self.currentShelter then
        self:Print("|cffffff00You already have a shelter built!|r")
        return false
    end
    
    -- List available tents
    self:Print("|cff00ff00Available shelter toys:|r")
    for toyId, shelterData in pairs(availableToys) do
        local _, toyName = C_ToyBox.GetToyInfo(toyId)
        local tempBonus = 10 * shelterData.quality
        self:Print(string.format("- %s (ID: %d, Quality: %d%%, Warmth: +%.1f°F)", 
            toyName or shelterData.name, 
            toyId,
            shelterData.quality * 100,
            tempBonus))
    end
    
    self:Print("|cffffff00Use one of your tent toys now to build a shelter!|r")
    self.awaitingShelter = true
    
    -- Cancel waiting after 30 seconds
    C_Timer.After(30, function()
        if self.awaitingShelter then
            self.awaitingShelter = false
            self:Print("|cffffff00Shelter building cancelled.|r")
        end
    end)
    
    return true
end

function SurvivalMode:PackUpShelter()
    if not self.currentShelter then
        self:Print("|cffffff00You don't have a shelter to pack up!|r")
        return false
    end
    
    if InCombatLockdown() then
        self:Print("|cffff0000You cannot pack up your shelter while in combat!|r")
        return false
    end
    
    -- Cancel timer if exists
    if self.shelterTimer then
        self:CancelTimer(self.shelterTimer)
        self.shelterTimer = nil
    end
    
    -- Remove shelter
    for i, shelter in ipairs(self.shelters) do
        if shelter == self.currentShelter then
            table.remove(self.shelters, i)
            break
        end
    end
    
    self:Print(string.format("|cffffff00You pack up your %s.|r", self.currentShelter.name))
    
    self.currentShelter = nil
    
    return true
end

function SurvivalMode:IsInShelter()
    if not self.currentShelter then return false end
    
    -- Check distance from shelter
    local mapID = C_Map.GetBestMapForUnit("player")
    local position = C_Map.GetPlayerMapPosition(mapID, "player")
    
    if not position or mapID ~= self.currentShelter.position.mapID then
        return false
    end
    
    -- Calculate distance (simplified)
    local dx = math.abs(position.x - self.currentShelter.position.x)
    local dy = math.abs(position.y - self.currentShelter.position.y)
    local distance = math.sqrt(dx * dx + dy * dy)
    
    -- If within reasonable distance (about 10 yards), consider in shelter
    return distance < 0.005
end

function SurvivalMode:GetCurrentShelter()
    if self:IsInShelter() then
        return self.currentShelter
    end
    return nil
end