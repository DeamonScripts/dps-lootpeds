# DSRP Loot Peds

**QBox/ox_lib Compatible Dead Ped Looting System**

Original script by [MaDHouSe](https://github.com/MaDHouSe79/mh-lootpeds)
Adapted for DelPerro Sands RP

---

## Description

A feature-rich dead ped looting system built specifically for QBox framework with ox_lib and ox_inventory integration. Players can interact with dead NPCs using ox_target to search for loot including cash, items, ammo, and weapons.

## Features

- ✅ **QBox Framework Integration** - Fully compatible with QBox (qbx_core)
- ✅ **ox_lib Integration** - Uses ox_lib for notifications, progress bars, and commands
- ✅ **ox_target Support** - Interact with corpses using ox_target
- ✅ **ox_inventory Compatible** - Seamless integration with ox_inventory
- ✅ **Configurable Loot Tables** - Customize items, weapons, and cash rewards
- ✅ **Chance-Based System** - Realistic loot probability system
- ✅ **Admin Controls** - Toggle system on/off with `/pedloot` command
- ✅ **467 Ped Models** - Supports all civilian, gang, and service worker peds
- ✅ **Performance Optimized** - Clean, efficient code with memory management
- ✅ **Progress Animations** - Smooth looting animation with ox_lib progress bars

## Dependencies

**Required:**
- [ox_lib](https://github.com/overextended/ox_lib)
- [qbx_core](https://github.com/Qbox-project/qbx_core)
- [ox_target](https://github.com/overextended/ox_target)
- [ox_inventory](https://github.com/overextended/ox_inventory)
- [oxmysql](https://github.com/overextended/oxmysql)

## Installation

1. Place the `dsrp-lootpeds` folder into your `resources` directory
2. Add to your `server.cfg`: `ensure dsrp-lootpeds`
3. Configure `shared/config.lua` to your preference
4. Restart your server

## Configuration

### Basic Settings (`shared/config.lua`)

```lua
-- General Settings
Config.EnableOnStart = true         -- Enable when server starts
Config.DeletePedsWhenLooted = true  -- Remove corpses after looting
Config.InteractionDistance = 2.5    -- Distance to interact

-- Loot Chances (0-100%)
Config.Chances = {
    Cash = 50,              -- 50% chance to find cash
    BasicItem = 75,         -- 75% chance to find items
    Ammo = 40,              -- 40% chance to find ammo
    NormalWeapon = 15,      -- 15% chance to find weapons
    HeavyWeapon = 2         -- 2% chance to find rare weapons
}

-- Cash Configuration
Config.Cash = {
    Min = 25,               -- Minimum: $25
    Max = 100,              -- Maximum: $100
    Type = 'cash'           -- 'cash' or 'bank'
}
```

## Commands

```
/pedloot [On/Off]
```

Toggle the looting system on or off server-wide (admin only if configured).

## Usage

1. Find a dead ped (NPC)
2. Approach the corpse
3. Look at the body - ox_target icon appears
4. Press [E] to select "Loot Dead Ped"
5. Wait for progress bar (2.5 seconds)
6. Receive loot notifications

## Version History

**v2.0.0** (DSRP Adaptation)
- Complete QBox/ox_lib integration
- Improved code structure
- Enhanced loot system
- Better performance

**v1.0.0** (Original by MaDHouSe)
- Original QBCore implementation

## Credits

**Original:** [MaDHouSe](https://github.com/MaDHouSe79)
**Adapted for DSRP**

---

Made for DelPerro Sands RP
