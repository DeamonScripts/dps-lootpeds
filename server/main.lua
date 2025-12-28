--[[ ===================================================== ]]--
--[[       DSRP Loot Peds - QBCore/qs-inventory Compatible        ]]--
--[[         Original by MaDHouSe - Adapted for DSRP      ]]--
--[[ ===================================================== ]]--

local systemEnabled = Config.EnableOnStart

-- ═══════════════════════════════════════════════════════
-- HELPER FUNCTIONS
-- ═══════════════════════════════════════════════════════

---Get random item from table
---@param tbl table
---@return any
local function getRandomItem(tbl)
    if not tbl or #tbl == 0 then return nil end
    return tbl[math.random(1, #tbl)]
end

---Check if percentage chance succeeds
---@param chance number
---@return boolean
local function rollChance(chance)
    return math.random(1, 100) <= chance
end

---Give item to player using qs-inventory
---@param source number
---@param item string
---@param amount number
---@return boolean
local function giveItem(source, item, amount)
    local success = exports['qs-inventory']:AddItem(source, item, amount or 1)
    if success then
        lib.notify(source, {
            title = 'Found Item',
            description = locale('notifications.received_item', { item = item }),
            type = 'success'
        })
    end
    return success
end

---Give money to player
---@param source number
---@param amount number
---@return boolean
local function giveMoney(source, amount)
    local Player = exports['qb-core']:GetPlayer(source)
    if not Player then return false end

    Player.Functions.AddMoney(Config.Cash.Type, amount, 'ped-looting')
    lib.notify(source, {
        title = 'Found Cash',
        description = locale('notifications.received_cash', { amount = amount }),
        type = 'success'
    })
    return true
end

-- ═══════════════════════════════════════════════════════
-- LOOT GENERATION SYSTEM
-- ═══════════════════════════════════════════════════════

---Generate and give loot to player
---@param source number
---@param netId number
local function generateLoot(source, netId)
    local Player = exports['qb-core']:GetPlayer(source)
    if not Player then return end

    local lootGiven = false

    -- Delete ped for all clients
    TriggerClientEvent('dsrp-lootpeds:client:deletePed', -1, netId)

    -- CASH LOOT
    if Config.UseCash and rollChance(Config.Chances.Cash) then
        local cashAmount = math.random(Config.Cash.Min, Config.Cash.Max)
        giveMoney(source, cashAmount)
        lootGiven = true
    end

    -- BASIC ITEMS
    if Config.UseBasicItems and rollChance(Config.Chances.BasicItem) then
        local item = getRandomItem(Config.Items.Basic)
        if item then
            giveItem(source, item, 1)
            lootGiven = true
        end
    end

    -- AMMO
    if Config.UseAmmo and rollChance(Config.Chances.Ammo) then
        local ammo = getRandomItem(Config.Items.Ammo)
        if ammo then
            giveItem(source, ammo, math.random(1, 3))
            lootGiven = true
        end
    end

    -- NORMAL WEAPONS
    if Config.UseNormalWeapons and rollChance(Config.Chances.NormalWeapon) then
        local weapon = getRandomItem(Config.Items.NormalWeapons)
        if weapon then
            giveItem(source, weapon, 1)
            lootGiven = true
        end
    end

    -- HEAVY WEAPONS
    if Config.UseHeavyWeapons and rollChance(Config.Chances.HeavyWeapon) then
        local weapon = getRandomItem(Config.Items.HeavyWeapons)
        if weapon then
            giveItem(source, weapon, 1)
            lootGiven = true
        end
    end

    -- No loot found notification
    if not lootGiven then
        lib.notify(source, {
            title = 'No Loot',
            description = locale('notifications.no_loot'),
            type = 'inform'
        })
    end
end

-- ═══════════════════════════════════════════════════════
-- EVENTS
-- ═══════════════════════════════════════════════════════

---Handle loot request from client
RegisterNetEvent('dsrp-lootpeds:server:loot', function(netId)
    local source = source
    if not systemEnabled then return end

    generateLoot(source, netId)
end)

---Enable looting system
RegisterNetEvent('dsrp-lootpeds:server:enable', function()
    systemEnabled = true
    TriggerClientEvent('dsrp-lootpeds:client:enable', -1)
end)

---Disable looting system
RegisterNetEvent('dsrp-lootpeds:server:disable', function()
    systemEnabled = false
    TriggerClientEvent('dsrp-lootpeds:client:disable', -1)
end)

-- ═══════════════════════════════════════════════════════
-- COMMANDS
-- ═══════════════════════════════════════════════════════

---Toggle looting system on/off
lib.addCommand(Config.Commands.toggle, {
    help = locale('command.toggle_description'),
    params = {
        {
            name = 'state',
            type = 'string',
            help = 'On or Off'
        }
    },
    restricted = Config.AdminOnly and 'group.admin' or false
}, function(source, args)
    local state = args.state and string.lower(args.state) or nil

    if state == 'on' then
        systemEnabled = true
        TriggerClientEvent('dsrp-lootpeds:client:enable', -1)
        lib.notify(source, {
            title = 'Looting System',
            description = 'Ped looting has been ENABLED',
            type = 'success'
        })
    elseif state == 'off' then
        systemEnabled = false
        TriggerClientEvent('dsrp-lootpeds:client:disable', -1)
        lib.notify(source, {
            title = 'Looting System',
            description = 'Ped looting has been DISABLED',
            type = 'inform'
        })
    else
        lib.notify(source, {
            title = 'Invalid Argument',
            description = 'Usage: /' .. Config.Commands.toggle .. ' [On/Off]',
            type = 'error'
        })
    end
end)

-- ═══════════════════════════════════════════════════════
-- INITIALIZATION
-- ═══════════════════════════════════════════════════════

---Resource start handler
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    -- Sync system state with all clients
    if systemEnabled then
        TriggerClientEvent('dsrp-lootpeds:client:enable', -1)
    else
        TriggerClientEvent('dsrp-lootpeds:client:disable', -1)
    end

    print('^2[DSRP Loot Peds]^7 v2.0.0 started successfully')
    print('^2[DSRP Loot Peds]^7 System is ' .. (systemEnabled and '^2ENABLED^7' or '^1DISABLED^7'))
end)

---Resource stop handler
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    print('^2[DSRP Loot Peds]^7 Resource stopped')
end)