local addonName, ns = ...

-- Database will be initialized after Core.lua loads
C_Timer.After(0, function()
    local SurvivalMode = ns.SurvivalMode
    
    if not SurvivalMode then
        print("SurvivalMode: Database initialization failed - addon not loaded")
        return
    end
    
    -- Food and Drink Database with realistic restoration values
    SurvivalMode.ConsumableDB = {
        -- Drinks (itemID = thirst restoration %)
        drinks = {
            -- === BASIC DRINKS (5-10%) ===
            [159] = 5,       -- Refreshing Spring Water
            [1179] = 7,      -- Ice Cold Milk
            [1205] = 8,      -- Melon Juice
            [1708] = 10,     -- Sweet Nectar
            [19997] = 5,     -- Harvest Nectar
            [2593] = 6,      -- Flask of Port
            [2594] = 7,      -- Flask of Stormwind Tawny
            [2595] = 8,      -- Jug of Badlands Bourbon
            [2596] = 9,      -- Skin of Dwarven Stout
            [1004] = 5,      -- Cheap Beer
            [1006] = 6,      -- Orc Draught
            [1942] = 7,      -- Bottle of Moonshine
            [4595] = 8,      -- Junglevine Wine
            [4600] = 9,      -- Cherry Grog
            [5350] = 6,      -- Conjured Water (Rank 1)
            [18300] = 10,    -- Hyjal Nectar
            [20031] = 9,     -- Essence Mango
            [20516] = 8,     -- Bobbing Apple
            [58274] = 7,     -- Fresh Water
            [62675] = 9,     -- Coconut Water
            
            -- === MEDIUM DRINKS (10-15%) ===
            [2288] = 12,     -- Conjured Fresh Water
            [2136] = 12,     -- Conjured Purified Water
            [3772] = 12,     -- Conjured Spring Water
            [8077] = 12,     -- Conjured Crystal Water
            [8078] = 13,     -- Conjured Sparkling Water
            [8079] = 14,     -- Conjured Mineral Water
            [4791] = 12,     -- Enchanted Water
            [1645] = 11,     -- Moonberry Juice
            [8766] = 13,     -- Morning Glory Dew
            [19221] = 14,    -- Darkmoon Special Reserve
            [21030] = 13,    -- Moonberry Juice
            [21151] = 15,    -- Rumsey Rum Black Label
            [21721] = 14,    -- Moonglow
            [22018] = 15,    -- Conjured Glacier Water
            [27860] = 12,    -- Purified Draenei Water
            [28399] = 13,    -- Filtered Draenei Water
            [29395] = 14,    -- Ethermead
            [29401] = 15,    -- Sparkling Southshore Cider
            [33042] = 13,    -- Black Coffee
            [33043] = 14,    -- Iced Berry Slush
            [34411] = 15,    -- Hot Apple Cider
            [43086] = 14,    -- Fresh Apple Juice
            [62674] = 13,    -- Lemonade
            [81922] = 15,    -- Yak's Milk
            
            -- === GOOD DRINKS (15-20%) ===
            [19299] = 16,    -- Fizzy Faire Drink
            [19300] = 17,    -- Bottled Winterspring Water
            [33444] = 18,    -- Pungent Seal Whey
            [33445] = 18,    -- Honeymint Tea
            [38430] = 19,    -- Blackrock Mineral Water
            [38431] = 19,    -- Blackrock Spring Water
            [40357] = 20,    -- Grizzleberry Juice
            [58256] = 18,    -- Sparkling Oasis Water
            [58257] = 19,    -- Highland Spring Water
            [58258] = 20,    -- Volcanic Spring Water
            [30703] = 18,    -- Conjured Mountain Spring Water
            [43523] = 19,    -- Conjured Glacier Water (TBC)
            [65499] = 20,    -- Conjured Mana Strudel
            [74822] = 18,    -- Prickly Pear Juice
            [42779] = 17,    -- Steaming Chicken Soup
            [37253] = 16,    -- Icecrown Bottled Water
            [33448] = 18,    -- Runn Tum Tuber Surprise
            [35954] = 19,    -- Sweetened Goat's Milk
            [42431] = 17,    -- Soft Banana Bread
            [58278] = 20,    -- Tropical Sunfruit
            [74833] = 19,    -- Jade Witch Brew
            
            -- === EXCELLENT DRINKS (20-25%) ===
            [81923] = 20,    -- Cobo Cola
            [74636] = 22,    -- Golden Carp Consomme
            [81406] = 22,    -- Roasted Barley Tea
            [105711] = 23,   -- Funky Monkey Brew
            [113509] = 24,   -- Conjured Mana Fritter
            [140272] = 25,   -- Nightborne Delicacy Platter
            [133563] = 25,   -- Faronaar Fizz
            [138292] = 25,   -- Ley-Enriched Water
            [80610] = 21,    -- Conjured Mana Cake
            [80618] = 22,    -- Conjured Mana Fritter
            [86026] = 20,    -- Refreshing Red Apple
            [81055] = 21,    -- Darkmoon Fizzy Drink
            [87216] = 23,    -- Golden Carp Consommé
            [81405] = 24,    -- Boiled Silkworm Pupa
            [111431] = 25,   -- Hearty Elekk Steak
            [124099] = 23,   -- Blackwater Whiptail
            [124106] = 24,   -- Felmouth Frenzy
            [133680] = 25,   -- Lean Shank
            [154881] = 25,   -- Bountiful Captain's Feast
            [156526] = 24,   -- Sailor's Pie
            [168313] = 25,   -- Battle-Scarred Augment Rune
            [172045] = 25,   -- Tenebrous Crown Roast Aspic
            [186704] = 25,   -- Fried Bonefish
            [197794] = 25,   -- Riverside Picnic
            
            -- === SPECIAL EVENT DRINKS ===
            [21151] = 15,    -- Rumsey Rum Black Label
            [20031] = 12,    -- Essence Mango (Lunar Festival)
            [21030] = 13,    -- Moonberry Juice (Lunar Festival)
            [19299] = 16,    -- Fizzy Faire Drink (Darkmoon Faire)
            [33443] = 18,    -- Soothing Turtle Bisque (Love is in the Air)
            [34411] = 15,    -- Hot Apple Cider (Harvest Festival)
            [37253] = 16,    -- Icecrown Bottled Water (Northrend)
            [81055] = 21,    -- Darkmoon Fizzy Drink (Darkmoon Faire)
        },
        
        -- Food (itemID = hunger restoration %)
        food = {
            -- === BASIC FOODS (5-10%) ===
            [117] = 5,       -- Tough Jerky
            [2070] = 5,      -- Darnassian Bleu
            [4540] = 6,      -- Tough Hunk of Bread
            [4541] = 6,      -- Freshly Baked Bread
            [4542] = 7,      -- Moist Cornbread
            [4536] = 7,      -- Shiny Red Apple
            [4537] = 8,      -- Tel'Abim Banana
            [4538] = 8,      -- Snapvine Watermelon
            [4539] = 9,      -- Goldenbark Apple
            [4604] = 8,      -- Forest Mushroom Cap
            [4605] = 9,      -- Red-speckled Mushroom
            [4606] = 10,     -- Spongy Morel
            [4607] = 10,     -- Delicious Cave Mold
            [4602] = 10,     -- Moon Harvest Pumpkin
            [8950] = 12,     -- Homemade Cherry Pie
            [2679] = 6,      -- Charred Wolf Meat
            [2680] = 7,      -- Spiced Wolf Meat
            [2681] = 8,      -- Roasted Boar Meat
            [2684] = 9,      -- Coyote Steak
            [2685] = 10,     -- Succulent Pork Ribs
            [118] = 5,       -- Minor Healing Potion
            [414] = 6,       -- Dalaran Sharp
            [422] = 7,       -- Dwarven Mild
            [1082] = 9,      -- Westfall Stew
            [1113] = 8,      -- Conjured Bread
            [2287] = 10,     -- Haunch of Meat
            [3927] = 9,      -- Fine Aged Cheddar
            [5057] = 8,      -- Ripe Watermelon
            [16166] = 10,    -- Bean Soup
            [17197] = 9,     -- Gingerbread Cookie
            [17222] = 8,     -- Spider Sausage
            
            -- === MEDIUM FOODS (10-15%) ===
            [733] = 11,      -- Westfall Stew
            [1017] = 12,     -- Seasoned Wolf Kabob
            [2287] = 11,     -- Haunch of Meat
            [3770] = 12,     -- Mutton Chop
            [3771] = 12,     -- Wild Hog Shank
            [5095] = 13,     -- Rainbow Fin Albacore
            [5472] = 13,     -- Kaldorei Spider Kabob
            [5473] = 14,     -- Scorpid Surprise
            [5474] = 14,     -- Roasted Kodo Meat
            [5476] = 14,     -- Fillet of Frenzy
            [5477] = 15,     -- Strider Stew
            [5478] = 15,     -- Dig Rat Stew
            [8364] = 15,     -- Mithril Head Trout
            [2683] = 12,     -- Crab Cake
            [2686] = 13,     -- Thunder Ale
            [2687] = 14,     -- Dry Pork Ribs
            [3220] = 15,     -- Blood Sausage
            [3662] = 14,     -- Crocolisk Steak
            [3665] = 13,     -- Curiously Tasty Omelet
            [3726] = 12,     -- Big Bear Steak
            [3727] = 13,     -- Hot Lion Chops
            [4457] = 15,     -- Barbecued Buzzard Wing
            [4599] = 14,     -- Cured Ham Steak
            [5525] = 13,     -- Boiled Clams
            [6038] = 12,     -- Giant Clam Meat
            [6316] = 14,     -- Loch Frenzy Delight
            [6887] = 15,     -- Spotted Yellowtail
            [6890] = 14,     -- Smoked Bear Meat
            [8932] = 13,     -- Alterac Swiss
            [12224] = 15,    -- Crispy Bat Wing
            [16169] = 14,    -- Wild Thornroot
            [17119] = 13,    -- Deeprun Rat Kabob
            [21023] = 15,    -- Dirge's Kickin' Chimaerok Chops
            
            -- === GOOD FOODS (15-20%) ===
            [13927] = 16,    -- Cooked Glossy Mightfish
            [13928] = 17,    -- Grilled Squid
            [13929] = 17,    -- Hot Smoked Bass
            [13930] = 18,    -- Filet of Redgill
            [13931] = 18,    -- Nightfin Soup
            [13932] = 19,    -- Poached Sunscale Salmon
            [13933] = 19,    -- Lobster Stew
            [13934] = 20,    -- Mightfish Steak
            [13935] = 20,    -- Baked Salmon
            [20074] = 18,    -- Heavy Crocolisk Stew
            [21217] = 19,    -- Sagefish Delight
            [21552] = 20,    -- Striped Yellowtail
            [6807] = 16,     -- Frog Leg Stew
            [7808] = 17,     -- Chocolate Cake
            [12218] = 18,    -- Monster Omelet
            [17196] = 16,    -- Holiday Cheesewheel
            [18269] = 17,    -- Gordok Green Grog
            [20452] = 19,    -- Smoked Desert Dumplings
            [27635] = 18,    -- Lynx Steak
            [27636] = 19,    -- Bat Bites
            [27651] = 20,    -- Buzzard Bites
            [27655] = 18,    -- Ravager Dog
            [27657] = 19,    -- Blackened Basilisk
            [27658] = 17,    -- Roasted Clefthoof
            [27660] = 16,    -- Talbuk Steak
            [27661] = 20,    -- Blackened Trout
            [27662] = 18,    -- Feltail Delight
            [27663] = 19,    -- Blackened Sporefish
            [27664] = 17,    -- Grilled Mudfish
            [27665] = 16,    -- Poached Bluefish
            [27666] = 18,    -- Golden Fish Sticks
            [27667] = 20,    -- Spicy Crawdad
            [33872] = 19,    -- Spicy Hot Talbuk
            [33873] = 18,    -- Crunchy Serpent
            [33874] = 17,    -- Mok'Nathal Shortribs
            
            -- === EXCELLENT FOODS (20-25%) ===
            [33004] = 21,    -- Clamlette Magnifique
            [33048] = 21,    -- Stewed Trout
            [33052] = 22,    -- Fisherman's Feast
            [33053] = 22,    -- Hot Buttered Trout
            [34747] = 23,    -- Northern Stew
            [34748] = 23,    -- Mammoth Meal
            [34749] = 23,    -- Shoveltusk Steak
            [34750] = 24,    -- Worm Delight
            [34751] = 24,    -- Roasted Worg
            [34752] = 24,    -- Rhino Dogs
            [34753] = 25,    -- Great Feast
            [42942] = 22,    -- Baked Manta Ray
            [42993] = 23,    -- Spicy Fried Herring
            [42994] = 23,    -- Rhinolicious Wormsteak
            [42995] = 24,    -- Hearty Rhino
            [42996] = 24,    -- Snapper Extreme
            [42997] = 25,    -- Blackened Worg Steak
            [43015] = 25,    -- Fish Feast
            [62290] = 25,    -- Seafood Magnifique Feast
            [126936] = 25,   -- Sugar-Crusted Fish Feast
            [133557] = 25,   -- Salt & Pepper Shank
            [3728] = 21,     -- Tasty Lion Steak
            [3729] = 22,     -- Soothing Turtle Bisque
            [43268] = 23,    -- Dalaran Clam Chowder
            [43478] = 24,    -- Gigantic Feast
            [43480] = 25,    -- Small Feast
            [57102] = 21,    -- Chocolate Celebration Cake
            [62289] = 22,    -- Broiled Dragon Feast
            [62290] = 23,    -- Seafood Magnifique Feast
            [74919] = 24,    -- Pandaren Banquet
            [87915] = 25,    -- Pandaren Treasure Noodle Cart
            [104354] = 21,   -- Silkworm Pupa
            [104357] = 22,   -- Valley Stir Fry
            [104358] = 23,   -- Shrimp Dumplings
            [111431] = 24,   -- Hearty Elekk Steak
            [126934] = 25,   -- Fancy Darkmoon Feast
            [133680] = 22,   -- Lean Shank
            [133681] = 23,   -- Leybeque Ribs
            [142334] = 24,   -- Spiced Falcosaur Omelet
            [154881] = 25,   -- Bountiful Captain's Feast
            [156526] = 21,   -- Sailor's Pie
            [156525] = 22,   -- Boralus Blood Sausage
            [166240] = 23,   -- Sanguinated Feast
            [168315] = 24,   -- Surprisingly Palatable Feast
            [172045] = 25,   -- Tenebrous Crown Roast Aspic
            [186704] = 21,   -- Fried Bonefish
            [186725] = 22,   -- Porous Rock Candy
            [197794] = 25,   -- Riverside Picnic
            [197795] = 24,   -- Grand Banquet of the Kalu'ak
            
            -- === SPECIAL COOKING ITEMS WITH BONUS RESTORATION ===
            [2683] = 18,     -- Crab Cake (Cooking)
            [2684] = 19,     -- Coyote Steak (Cooking)
            [2687] = 20,     -- Dry Pork Ribs (Cooking)
            [3220] = 20,     -- Blood Sausage (Cooking)
            [3662] = 21,     -- Crocolisk Steak (Cooking)
            [3726] = 22,     -- Big Bear Steak (Cooking)
            [3727] = 22,     -- Hot Lion Chops (Cooking)
            [3728] = 23,     -- Tasty Lion Steak (Cooking)
            [3729] = 24,     -- Soothing Turtle Bisque (Cooking)
            [4457] = 25,     -- Barbecued Buzzard Wing (Cooking)
            [6316] = 21,     -- Loch Frenzy Delight (Cooking)
            [6887] = 22,     -- Spotted Yellowtail (Cooking)
            [8364] = 20,     -- Mithril Head Trout (Cooking)
            [12218] = 23,    -- Monster Omelet (Cooking)
            [12224] = 24,    -- Crispy Bat Wing (Cooking)
            [17119] = 21,    -- Deeprun Rat Kabob (Cooking)
            [20452] = 25,    -- Smoked Desert Dumplings (Cooking)
            
            -- === PANDARIA EXPANSION FOODS ===
            [74919] = 24,    -- Pandaren Banquet
            [81406] = 16,    -- Valley Stir Fry
            [81407] = 17,    -- Shrimp Dumplings
            [81408] = 18,    -- Swirling Mist Soup
            [81409] = 19,    -- Fire Spirit Salmon
            [81410] = 20,    -- Steamed Crab Surprise
            [87915] = 25,    -- Pandaren Treasure Noodle Cart
            [104354] = 15,   -- Silkworm Pupa
            [104357] = 16,   -- Valley Stir Fry
            [104358] = 17,   -- Shrimp Dumplings
            [104359] = 18,   -- Red Bean Bun
            [104360] = 19,   -- Tangy Yogurt
            [104361] = 20,   -- Skewered Peanut Chicken
            [111431] = 24,   -- Hearty Elekk Steak
            [126934] = 25,   -- Fancy Darkmoon Feast
            
            -- === LEGION EXPANSION FOODS ===
            [133557] = 25,   -- Salt & Pepper Shank
            [133563] = 23,   -- Faronaar Fizz
            [133680] = 22,   -- Lean Shank
            [133681] = 23,   -- Leybeque Ribs
            [138292] = 21,   -- Ley-Enriched Water
            [140272] = 25,   -- Nightborne Delicacy Platter
            [142334] = 24,   -- Spiced Falcosaur Omelet
            
            -- === BATTLE FOR AZEROTH FOODS ===
            [154881] = 25,   -- Bountiful Captain's Feast
            [156526] = 21,   -- Sailor's Pie
            [156525] = 22,   -- Boralus Blood Sausage
            [166240] = 23,   -- Sanguinated Feast
            [168315] = 24,   -- Surprisingly Palatable Feast
            
            -- === SHADOWLANDS FOODS ===
            [172045] = 25,   -- Tenebrous Crown Roast Aspic
            [172041] = 24,   -- Spinefin Souffle and Fries
            [172042] = 23,   -- Steak a la Mode
            [172043] = 22,   -- Cakeless Carrot Cake
            [172044] = 21,   -- Candied Amberjack Cakes
            
            -- === DRAGONFLIGHT FOODS ===
            [186704] = 21,   -- Fried Bonefish
            [186725] = 22,   -- Porous Rock Candy
            [197794] = 25,   -- Riverside Picnic
            [197795] = 24,   -- Grand Banquet of the Kalu'ak
            [197796] = 23,   -- Yusa's Hearty Stew
            [197797] = 22,   -- Aromatic Seafood Platter
            [197798] = 21,   -- Feisty Fish Sticks
        },
    }

    -- Shelter items
    SurvivalMode.ShelterItems = {
        [64632] = {name = "Gnoll Tent", quality = 0.6},
        [198087] = {name = "Dragon Expeditioner's Tent", quality = 0.8},
        [200095] = {name = "Market Tent", quality = 0.7},
    }
end)