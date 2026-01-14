--[[
    dps-lootpeds Configuration
    Model-Specific Loot Tables with State Bag Support
]]

Config = {}

-- ═══════════════════════════════════════════════════════
-- GENERAL SETTINGS
-- ═══════════════════════════════════════════════════════

Config.Debug = false
Config.Locale = 'en'

-- System Behavior
Config.EnableOnStart = true
Config.UseTarget = true                  -- Use ox_target for interaction
Config.InteractionDistance = 2.5         -- Distance to interact with corpses

-- Body Handling (IMPORTANT: State Bags prevent re-looting WITHOUT deletion)
Config.DeletePedsWhenLooted = false      -- FALSE = Keep body, use State Bags
Config.UseStateBags = true               -- Sync looted status across all clients
Config.BodyDespawnTime = 300000          -- 5 minutes before marking for cleanup (if not deleted)

-- Admin Settings
Config.AdminOnly = false
Config.Commands = {
    toggle = 'lootpeds',                 -- /lootpeds on/off
    reload = 'reloadloot'                -- /reloadloot (admin: reload loot tables)
}

-- ═══════════════════════════════════════════════════════
-- LOOTING ANIMATION
-- ═══════════════════════════════════════════════════════

Config.Animation = {
    duration = 3000,                     -- Search time in ms
    dict = 'amb@medic@standing@kneel@base',
    clip = 'base',
    canCancel = true,
    disable = {
        move = true,
        car = true,
        combat = true
    }
}

-- ═══════════════════════════════════════════════════════
-- LOOT CATEGORIES
-- Assign peds to categories based on their model prefix
-- ═══════════════════════════════════════════════════════

Config.PedCategories = {
    -- Police/Security
    police = {
        patterns = { 's_m_y_cop', 's_f_y_cop', 's_m_y_sheriff', 's_f_y_sheriff', 's_m_y_hwaycop',
                     's_m_m_security', 's_m_y_swat', 's_m_m_prisguard', 's_m_m_fiboffice',
                     's_m_m_ciasec', 's_m_m_chemsec', 's_m_y_devinsec', 'csb_cop' },
        cash = { min = 50, max = 150, chance = 40 },
        loot = {
            { item = 'radio', chance = 60 },
            { item = 'handcuffs', chance = 40 },
            { item = 'weapon_flashlight', chance = 50 },
            { item = 'weapon_nightstick', chance = 30 },
            { item = 'weapon_stungun', chance = 15 },
            { item = 'armor', chance = 25 },
            { item = 'pistol_ammo', chance = 70, amount = { 1, 3 } },
            { item = 'weapon_pistol', chance = 10 },
            { item = 'weapon_combatpistol', chance = 5 },
        }
    },

    -- Gang Members
    gang = {
        patterns = { 'g_m_', 'g_f_', 'csb_ballasog', 'csb_vagspeak' },
        cash = { min = 100, max = 500, chance = 70 },
        loot = {
            { item = 'weed_brick', chance = 25 },
            { item = 'coke_brick', chance = 10 },
            { item = 'meth_bag', chance = 15 },
            { item = 'joint', chance = 40 },
            { item = 'lockpick', chance = 35 },
            { item = 'weapon_knife', chance = 50 },
            { item = 'weapon_switchblade', chance = 40 },
            { item = 'weapon_bat', chance = 20 },
            { item = 'weapon_pistol', chance = 25 },
            { item = 'weapon_microsmg', chance = 8 },
            { item = 'pistol_ammo', chance = 60, amount = { 1, 5 } },
            { item = 'smg_ammo', chance = 30, amount = { 1, 3 } },
            { item = 'markedbills', chance = 15 },
            { item = 'goldchain', chance = 10 },
        }
    },

    -- Medical/EMS
    medical = {
        patterns = { 's_m_m_paramedic', 's_f_y_scrubs', 's_m_y_autopsy', 'csb_trafficwarden' },
        cash = { min = 30, max = 100, chance = 50 },
        loot = {
            { item = 'bandage', chance = 80 },
            { item = 'firstaid', chance = 40 },
            { item = 'painkillers', chance = 60 },
            { item = 'ifak', chance = 20 },
            { item = 'medkit', chance = 10 },
            { item = 'phone', chance = 50 },
        }
    },

    -- Construction/Industrial Workers
    worker = {
        patterns = { 's_m_y_construct', 's_m_y_dockwork', 's_m_m_gardener', 's_m_m_trucker',
                     's_m_y_garbage', 's_m_m_ups', 's_m_y_xmech', 's_m_m_autoshop' },
        cash = { min = 20, max = 80, chance = 60 },
        loot = {
            { item = 'weapon_wrench', chance = 50 },
            { item = 'weapon_hammer', chance = 40 },
            { item = 'screwdriverset', chance = 35 },
            { item = 'repairkit', chance = 20 },
            { item = 'duct_tape', chance = 45 },
            { item = 'metalscrap', chance = 60 },
            { item = 'plastic', chance = 40 },
            { item = 'sandwich', chance = 70 },
            { item = 'coffee', chance = 65 },
        }
    },

    -- Beach/Tourist
    beach = {
        patterns = { 'a_m_y_beach', 'a_f_y_beach', 'a_m_y_surfer', 'a_f_y_topless',
                     'a_m_y_sunbathe', 's_m_y_baywatch', 's_f_y_baywatch', 'a_m_y_jetski' },
        cash = { min = 10, max = 50, chance = 40 },
        loot = {
            { item = 'water', chance = 80 },
            { item = 'sunscreen', chance = 50 },
            { item = 'phone', chance = 60 },
            { item = 'sandwich', chance = 40 },
            { item = 'joint', chance = 15 },
        }
    },

    -- Business/Rich
    business = {
        patterns = { 'a_m_y_business', 'a_f_y_business', 'a_m_m_business', 'a_f_m_business',
                     'a_m_y_bevhills', 'a_f_y_bevhills', 'a_m_m_bevhills', 'a_f_m_bevhills',
                     'a_m_y_vinewood', 'a_f_y_vinewood', 'u_m_m_bankman', 'ig_bankman' },
        cash = { min = 200, max = 800, chance = 80 },
        loot = {
            { item = 'phone', chance = 90 },
            { item = 'rolex', chance = 15 },
            { item = 'goldchain', chance = 10 },
            { item = 'diamond_ring', chance = 5 },
            { item = 'creditcard', chance = 40 },
            { item = 'wallet', chance = 70 },
            { item = 'cigar', chance = 25 },
        }
    },

    -- Homeless/Vagrant
    homeless = {
        patterns = { 'a_m_m_tramp', 'a_f_m_tramp', 'a_m_o_tramp', 'a_m_m_skidrow',
                     'a_f_m_skidrow', 'u_m_o_tramp', 'a_m_y_methhead' },
        cash = { min = 1, max = 15, chance = 20 },
        loot = {
            { item = 'water', chance = 30 },
            { item = 'burger', chance = 25 },
            { item = 'weapon_bottle', chance = 60 },
            { item = 'lighter', chance = 70 },
            { item = 'joint', chance = 35 },
            { item = 'meth_bag', chance = 20 },
            { item = 'crackpipe', chance = 25 },
        }
    },

    -- Military
    military = {
        patterns = { 's_m_m_marine', 's_m_y_marine', 's_m_y_armymech', 's_m_y_blackops',
                     's_m_m_pilot_01', 's_m_m_pilot_02' },
        cash = { min = 50, max = 200, chance = 30 },
        loot = {
            { item = 'armor', chance = 50 },
            { item = 'weapon_combatpistol', chance = 30 },
            { item = 'weapon_carbinerifle', chance = 10 },
            { item = 'rifle_ammo', chance = 60, amount = { 2, 5 } },
            { item = 'pistol_ammo', chance = 70, amount = { 2, 4 } },
            { item = 'radio', chance = 50 },
            { item = 'mre', chance = 40 },
            { item = 'bandage', chance = 60 },
        }
    },

    -- Default (regular civilians)
    default = {
        patterns = {}, -- Fallback for unmatched peds
        cash = { min = 10, max = 75, chance = 50 },
        loot = {
            { item = 'phone', chance = 60 },
            { item = 'wallet', chance = 50 },
            { item = 'water', chance = 40 },
            { item = 'sandwich', chance = 35 },
            { item = 'cigarette', chance = 30 },
            { item = 'lighter', chance = 35 },
            { item = 'bandage', chance = 15 },
            { item = 'lockpick', chance = 5 },
            { item = 'weapon_knife', chance = 8 },
        }
    }
}

-- ═══════════════════════════════════════════════════════
-- CASH SETTINGS
-- ═══════════════════════════════════════════════════════

Config.Cash = {
    Type = 'cash',      -- 'cash' or 'bank'
    Dirty = false,      -- Use dirty money instead (if your server has it)
    DirtyItem = 'markedbills'  -- Item name for dirty money
}

-- ═══════════════════════════════════════════════════════
-- POLICE INTEGRATION (Optional)
-- ═══════════════════════════════════════════════════════

Config.PoliceIntegration = {
    enabled = false,                     -- Enable police alerts
    alertOnLoot = true,                  -- Alert police when someone loots a body
    policeJobs = { 'police', 'bcso', 'sasp', 'sahp', 'lspd' },
    minPoliceOnline = 2,                 -- Minimum police needed for alerts
    alertChance = 25,                    -- % chance to trigger alert
}

-- ═══════════════════════════════════════════════════════
-- EVIDENCE SYSTEM (Optional - for ps-evidence/qb-evidence)
-- ═══════════════════════════════════════════════════════

Config.Evidence = {
    enabled = false,                     -- Leave evidence when looting
    fingerprints = true,                 -- Leave fingerprints on body
    dna = false,                         -- Leave DNA (requires gloves check)
}

-- ═══════════════════════════════════════════════════════
-- RESTRICT LOOTING
-- ═══════════════════════════════════════════════════════

Config.Restrictions = {
    requireItem = false,                 -- Require an item to loot
    requiredItem = 'lockpick',           -- Item needed
    consumeItem = false,                 -- Consume the item when looting

    -- Ped model blacklist (cannot loot these)
    blacklistedPeds = {
        -- Main story characters
        'player_zero',      -- Michael
        'player_one',       -- Franklin
        'player_two',       -- Trevor
        -- Add any other peds you don't want looted
    },

    -- Only allow looting if player has certain jobs
    jobRestricted = false,
    allowedJobs = { 'unemployed' },      -- If restricted, only these jobs can loot
}

-- ═══════════════════════════════════════════════════════
-- PED MODELS - Full list for ox_target
-- These are all peds that CAN be looted
-- ═══════════════════════════════════════════════════════

Config.UseAllPeds = true                 -- If true, allows looting any dead NPC ped

-- If UseAllPeds is false, only these specific models can be looted
Config.PedModels = {
    -- Add specific models here if UseAllPeds = false
    -- Example: "a_m_y_hipster_01", "g_m_y_ballasout_01"
}
