# DPS LootPeds

A modern, State Bag synced ped looting system for FiveM with model-specific loot tables.

![Version](https://img.shields.io/badge/version-3.0.0-blue)
![Framework](https://img.shields.io/badge/framework-QB%20%7C%20QBX%20%7C%20ESX-green)
![License](https://img.shields.io/badge/license-GPL--3.0-orange)

## What Makes This Different?

| Feature | Old Scripts | DPS LootPeds |
|---------|-------------|--------------|
| Anti-Re-Loot | Delete body OR local table | **State Bags** (synced) |
| Body Handling | Delete = immersion break | Keep body, mark as searched |
| Loot Tables | Same for all peds | **Model-specific** (8 categories) |
| Framework | Single framework | **QB/QBX/ESX** bridge |
| Inventory | Single inventory | **ox/qs/qb** bridge |

## Features

### Core
- **State Bag Sync** - Looted status synced across ALL clients
- **Keep Bodies** - No more vanishing corpses (configurable)
- **Visual Indicator** - "[SEARCHED]" text above looted bodies

### Model-Specific Loot
Different peds drop different items:

| Category | Examples | Loot |
|----------|----------|------|
| **Police** | Cops, Security, SWAT | Radio, handcuffs, armor, pistol ammo |
| **Gang** | Ballas, Vagos, Lost MC | Drugs, dirty money, knives, guns |
| **Medical** | Paramedics, Nurses | Bandages, medkits, painkillers |
| **Worker** | Construction, Truckers | Tools, scraps, sandwiches |
| **Beach** | Surfers, Lifeguards | Water, sunscreen, phone |
| **Business** | Suits, Beverly Hills | Cash, jewelry, wallet, creditcard |
| **Homeless** | Tramps, Methheads | Bottles, lighters, drugs |
| **Military** | Marines, Pilots | Armor, rifles, MREs |

### Optional Integrations
- **Police Alerts** - Alert cops when someone loots a body
- **Evidence System** - Leave fingerprints (ps-evidence)
- **qs-dispatch** - Full dispatch integration

## Installation

1. **Download** and extract to your resources folder
2. **Configure** `shared/config.lua`
3. **Add to server.cfg**:
```cfg
ensure ox_lib
ensure ox_target
ensure dps-lootpeds
```

## Dependencies

### Required
- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_target](https://github.com/overextended/ox_target)

### Supported Frameworks
- QBCore
- QBX (Qbox)
- ESX

### Supported Inventories
- ox_inventory
- qs-inventory
- qb-inventory
- codem-inventory

## Configuration

### Basic Settings
```lua
Config.EnableOnStart = true          -- Enable on server start
Config.UseStateBags = true           -- Use State Bags (recommended)
Config.DeletePedsWhenLooted = false  -- Keep bodies (recommended)
Config.UseAllPeds = true             -- Loot any dead NPC
```

### Model-Specific Loot Tables
```lua
Config.PedCategories = {
    gang = {
        patterns = { 'g_m_', 'g_f_' },  -- Matches all gang peds
        cash = { min = 100, max = 500, chance = 70 },
        loot = {
            { item = 'weed_brick', chance = 25 },
            { item = 'weapon_pistol', chance = 25 },
            { item = 'lockpick', chance = 35 },
        }
    },
    -- Add more categories...
}
```

### Restrictions
```lua
Config.Restrictions = {
    requireItem = false,           -- Need an item to loot
    requiredItem = 'lockpick',     -- Which item
    consumeItem = false,           -- Consume it on use
    jobRestricted = false,         -- Restrict to certain jobs
    blacklistedPeds = { 'player_zero' }  -- Can't loot these
}
```

## Commands

| Command | Description |
|---------|-------------|
| `/lootpeds on` | Enable looting system |
| `/lootpeds off` | Disable looting system |

## How State Bags Work

```
Player A loots body → Server sets Entity(ped).state.isLooted = true
                         ↓
                    State Bag syncs to ALL clients
                         ↓
Player B approaches → Checks Entity(ped).state.isLooted
                         ↓
                    Shows "[SEARCHED]" text, can't re-loot
```

**Benefits:**
- No body deletion required
- Synced across all players
- Survives player disconnects
- No performance overhead

## Exports

### Client
```lua
-- Check if system is enabled
exports['dps-lootpeds']:IsSystemEnabled()

-- Check if a specific ped is looted
exports['dps-lootpeds']:IsPedLooted(pedEntity)

-- Manually trigger looting
exports['dps-lootpeds']:LootPed(pedEntity)
```

## Police Integration

Enable police alerts when players loot bodies:

```lua
Config.PoliceIntegration = {
    enabled = true,
    alertOnLoot = true,
    policeJobs = { 'police', 'bcso' },
    minPoliceOnline = 2,
    alertChance = 25,  -- 25% chance
}
```

## Evidence Integration

Leave evidence when looting (requires ps-evidence):

```lua
Config.Evidence = {
    enabled = true,
    fingerprints = true,
    dna = false,
}
```

## Upgrading from mh-lootpeds

1. Remove `mh-lootpeds` from your resources
2. Add `dps-lootpeds`
3. The `provides` in fxmanifest ensures backwards compatibility

## Changelog

### v3.0.0 (Complete Rewrite)
- Added State Bag sync for looted status
- Added model-specific loot tables (8 categories)
- Added framework bridge (QB/QBX/ESX)
- Added inventory bridge (ox/qs/qb)
- Added police alert integration
- Added evidence system integration
- Added visual "[SEARCHED]" indicator
- Removed body deletion requirement
- Improved ox_target integration

### v2.1.0 (Original Fork)
- QBox compatibility
- qs-inventory support

## Credits

- **Original**: [mh-lootpeds](https://github.com/MaDHouSe79/mh-lootpeds) by MaDHouSe
- **Rewrite**: @daemonAlex / DPS Development

## License

GPL-3.0 License
