local addonName, ns = ...
local SurvivalMode = ns.SurvivalMode

-- Track recently used items to avoid double-processing
local recentlyUsed = {}

function SurvivalMode:InitializeConsumptionHooks()
    -- Wait for next frame to ensure WoW API is ready
    C_Timer.After(0, function()
        -- Hook into item usage
        hooksecurefunc("UseItemByName", function(itemName)
            self:OnItemUsed(itemName)
        end)
        
        hooksecurefunc(C_Container, "UseContainerItem", function(bag, slot)
            self:OnContainerItemUsed(bag, slot)
        end)
    end)
end

function SurvivalMode:OnCampfireCreated()
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
end

function SurvivalMode:OnItemUsed(itemNameOrLink)
    local itemID = GetItemInfoInstant(itemNameOrLink)
    if itemID then
        -- Prevent double-processing
        local key = itemID .. "_" .. GetTime()
        if recentlyUsed[key] then return end
        recentlyUsed[key] = true
        
        C_Timer.After(0.1, function()
            self:CheckConsumableByID(itemID, itemNameOrLink)
        end)
        
        -- Clean up old entries
        C_Timer.After(1, function()
            recentlyUsed[key] = nil
        end)
    end
end

function SurvivalMode:OnContainerItemUsed(bag, slot)
    local itemInfo = C_Container.GetContainerItemInfo(bag, slot)
    if itemInfo and itemInfo.itemID then
        -- Prevent double-processing
        local key = itemInfo.itemID .. "_" .. GetTime()
        if recentlyUsed[key] then return end
        recentlyUsed[key] = true
        
        C_Timer.After(0.1, function()
            self:CheckConsumableByID(itemInfo.itemID, itemInfo.hyperlink)
        end)
        
        -- Clean up old entries
        C_Timer.After(1, function()
            recentlyUsed[key] = nil
        end)
    end
end

function SurvivalMode:CheckConsumableByID(itemID, itemLink)
    if not self.ConsumableDB then return end
    
    -- Check if it's in our database
    local thirstValue = self.ConsumableDB.drinks[itemID]
    local hungerValue = self.ConsumableDB.food[itemID]
    
    if thirstValue then
        self:ConsumeItem("thirst", thirstValue, itemLink or itemID)
        return
    elseif hungerValue then
        self:ConsumeItem("hunger", hungerValue, itemLink or itemID)
        return
    end
    
    -- Not in database - check if it's a generic consumable
    self:CheckGenericConsumable(itemID, itemLink)
end

function SurvivalMode:CheckGenericConsumable(itemID, itemLink)
    -- Get item info
    local itemName, _, _, _, _, itemType, itemSubType = GetItemInfo(itemID)
    
    if not itemName then
        -- Item info not cached yet, try again
        C_Timer.After(0.5, function()
            self:CheckGenericConsumable(itemID, itemLink)
        end)
        return
    end
    
    -- Check if it's a consumable
    if itemType == "Consumable" or itemType == "Consumables" then
        -- Default 5% restoration for unrecognized items
        local restored = false
        
        -- Check subtype and name patterns
        local nameLower = itemName:lower()
        
        -- Water/Drink patterns
        if itemSubType == "Food & Drink" then
            -- Special case: items that restore both
            if string.find(nameLower, "cherry pie") or string.find(nameLower, "meal") then
                -- These restore hunger primarily
                self:ConsumeItem("hunger", 5, itemLink or itemName)
                restored = true
            elseif string.find(nameLower, "water") or string.find(nameLower, "juice") or 
                   string.find(nameLower, "milk") or string.find(nameLower, "drink") or
                   string.find(nameLower, "tea") or string.find(nameLower, "coffee") or
                   string.find(nameLower, "ale") or string.find(nameLower, "wine") or
                   string.find(nameLower, "mead") then
                self:ConsumeItem("thirst", 5, itemLink or itemName)
                restored = true
            else
                -- Default food & drink items restore hunger
                self:ConsumeItem("hunger", 5, itemLink or itemName)
                restored = true
            end
        elseif string.find(nameLower, "water") or string.find(nameLower, "juice") or 
               string.find(nameLower, "milk") or string.find(nameLower, "drink") or
               string.find(nameLower, "tea") or string.find(nameLower, "coffee") or
               string.find(nameLower, "refreshing") or string.find(nameLower, "conjured") then
            self:ConsumeItem("thirst", 5, itemLink or itemName)
            restored = true
        elseif string.find(nameLower, "bread") or string.find(nameLower, "meat") or
               string.find(nameLower, "fish") or string.find(nameLower, "food") or
               string.find(nameLower, "jerky") or string.find(nameLower, "cheese") or
               string.find(nameLower, "fruit") or string.find(nameLower, "apple") or
               string.find(nameLower, "banana") or string.find(nameLower, "berr") or
               string.find(nameLower, "cake") or string.find(nameLower, "pie") or
               string.find(nameLower, "stew") or string.find(nameLower, "soup") then
            self:ConsumeItem("hunger", 5, itemLink or itemName)
            restored = true
        end
        
        -- Debug info for unrecognized consumables
        if self.db.profile.debug and not restored then
            self:DebugPrint(string.format("Unrecognized consumable: %s (ID: %d, Type: %s, SubType: %s)", 
                itemLink or itemName, itemID, itemType or "nil", itemSubType or "nil"))
        end
    end
end

function SurvivalMode:ConsumeItem(statType, baseValue, itemInfo)
    local stats = self.db.profile.stats
    local value = baseValue
    
    -- Apply perks
    if statType == "hunger" then
        local perk = self:GetPerkRank("iron_stomach")
        if perk > 0 then
            local bonus = baseValue * (0.02 * perk) -- 2% per rank
            value = baseValue + bonus
            if self.db.profile.debug then
                self:DebugPrint(string.format("Iron Stomach: +%.1f%% hunger (%.1f%% base + %.1f%% bonus)", 
                    value, baseValue, bonus))
            end
        end
    elseif statType == "thirst" then
        local perk = self:GetPerkRank("hydration_expert")
        if perk > 0 then
            local bonus = baseValue * (0.02 * perk) -- 2% per rank
            value = baseValue + bonus
            if self.db.profile.debug then
                self:DebugPrint(string.format("Hydration Expert: +%.1f%% thirst (%.1f%% base + %.1f%% bonus)", 
                    value, baseValue, bonus))
            end
        end
    end
    
    -- Check for Forager perk (currently doesn't exist in the perks DB, but keeping for future)
    local foragerPerk = self:GetPerkRank("forager")
    if foragerPerk > 0 and math.random() < 0.3 then
        self:Print("|cff00ff00Your foraging skills prevented the item from being consumed!|r")
        -- Note: We can't actually prevent consumption in WoW, this is just flavor
    end
    
    -- Update stat
    local oldValue = stats[statType]
    stats[statType] = math.min(100, stats[statType] + value)
    local actualGain = stats[statType] - oldValue
    
    -- Skip if no actual gain
    if actualGain <= 0 then
        if self.db.profile.debug then
            self:DebugPrint(string.format("%s already at maximum", statType))
        end
        return
    end
    
    -- Get item name for feedback
    local itemName = ""
    if type(itemInfo) == "string" then
        itemName = GetItemInfo(itemInfo) or itemInfo
    else
        itemName = GetItemInfo(itemInfo) or ("Item " .. itemInfo)
    end
    
    -- Feedback with color coding
    local color = "|cff00ff00"  -- Green for good restoration
    if value < 10 then
        color = "|cffffff00"  -- Yellow for low restoration
    elseif value >= 20 then
        color = "|cff00ccff"  -- Blue for excellent restoration
    end
    
    self:Print(string.format("%sConsumed %s: Restored %.1f%% %s|r", 
        color, itemName, actualGain, statType))
    
    -- Update UI
    self:UpdateStatusBars()
end

-- Cooking Fire helper - Updated to not directly cast spells
function SurvivalMode:BuildCampfire()
    -- Check if player knows Basic Campfire spell
    local campfireSpellId = 818
    local isKnown = IsSpellKnown(campfireSpellId)
    
    if not isKnown then
        -- Check if player has Cooking profession
        local prof1, prof2 = GetProfessions()
        local hasCooking = false
        
        if prof1 then
            local name, _, _, _, _, _, skillLine = GetProfessionInfo(prof1)
            if skillLine == 185 then -- Cooking skill line ID
                hasCooking = true
            end
        end
        
        if prof2 and not hasCooking then
            local name, _, _, _, _, _, skillLine = GetProfessionInfo(prof2)
            if skillLine == 185 then
                hasCooking = true
            end
        end
        
        if not hasCooking then
            self:Print("|cffff0000You need the Cooking skill to build a campfire!|r")
            self:Print("Learn Cooking from a trainer in any major city.")
            return false
        end
    end
    
    if InCombatLockdown() then
        self:Print("|cffff0000You cannot build a campfire in combat!|r")
        return false
    end
    
    -- Instead of casting directly, guide the player
    self:Print("|cff00ff00To build a campfire:|r")
    self:Print("1. Open your spell book (default key: P)")
    self:Print("2. Click the 'Professions' tab")
    self:Print("3. Click on Cooking")
    self:Print("4. Click on 'Basic Campfire' or drag it to your action bar")
    self:Print("|cffffff00The campfire will provide warmth for 5 minutes once placed.|r")
    
    -- Create a macro for the player if they want
    if not GetMacroInfo("Campfire") then
        CreateMacro("Campfire", "INV_Misc_Food_11", "/cast Basic Campfire", nil)
        self:Print("|cff00ff00A 'Campfire' macro has been created in your macro list!|r")
    end
    
    return true
end

-- Manual test commands
function SurvivalMode:TestConsumable(itemLink)
    if not itemLink then 
        self:Print("Usage: /sm test [item link]")
        return 
    end
    
    local itemID = GetItemInfoInstant(itemLink)
    if itemID then
        self:CheckConsumableByID(itemID, itemLink)
    else
        self:Print("Invalid item link")
    end
end