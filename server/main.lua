--[[
    dps-lootpeds Server
    State Bag Synced Looting with Model-Specific Loot Tables
]]

local systemEnabled = Config.EnableOnStart

-- ═══════════════════════════════════════════════════════
-- HELPER FUNCTIONS
-- ═══════════════════════════════════════════════════════

---Roll a percentage chance
---@param chance number 0-100
---@return boolean
local function rollChance(chance)
    return math.random(1, 100) <= chance
end

---Get random value between min and max
---@param min number
---@param max number
---@return number
local function getRandomAmount(min, max)
    if min == max then return min end
    return math.random(min, max)
end

---Determine ped category from model name
---@param modelName string
---@return string category name
local function getPedCategory(modelName)
    if not modelName then return 'default' end

    modelName = string.lower(modelName)

    for categoryName, categoryData in pairs(Config.PedCategories) do
        if categoryData.patterns then
            for _, pattern in ipairs(categoryData.patterns) do
                if string.find(modelName, pattern, 1, true) then
                    Bridge.Debug('Ped', modelName, 'matched category:', categoryName)
                    return categoryName
                end
            end
        end
    end

    return 'default'
end

---Get loot table for a category
---@param category string
---@return table
local function getLootTable(category)
    return Config.PedCategories[category] or Config.PedCategories.default
end

-- ═══════════════════════════════════════════════════════
-- LOOT GENERATION
-- ═══════════════════════════════════════════════════════

---Generate and give loot to player
---@param source number
---@param pedModel string
---@param netId number
local function generateLoot(source, pedModel, netId)
    local player = Bridge.GetPlayer(source)
    if not player then return end

    local lootGiven = false
    local category = getPedCategory(pedModel)
    local lootTable = getLootTable(category)

    Bridge.Debug('Generating loot for category:', category)

    -- Mark ped as looted via State Bag (synced to all clients)
    if Config.UseStateBags and netId and netId > 0 then
        local ped = NetworkGetEntityFromNetworkId(netId)
        if DoesEntityExist(ped) then
            Entity(ped).state:set('isLooted', true, true)
            Entity(ped).state:set('lootedBy', Bridge.GetPlayerIdentifier(source), true)
            Entity(ped).state:set('lootedAt', os.time(), true)
        end
    end

    -- Delete ped if configured
    if Config.DeletePedsWhenLooted then
        TriggerClientEvent('dps-lootpeds:client:deletePed', -1, netId)
    end

    -- CASH LOOT
    if lootTable.cash and rollChance(lootTable.cash.chance) then
        local cashAmount = getRandomAmount(lootTable.cash.min, lootTable.cash.max)

        if Config.Cash.Dirty then
            -- Give dirty money as item
            if Bridge.AddItem(source, Config.Cash.DirtyItem, cashAmount) then
                Bridge.Notify(source, 'Found Cash', 'Found $' .. cashAmount .. ' (dirty)', 'success')
                lootGiven = true
            end
        else
            -- Give clean money
            if Bridge.AddMoney(source, Config.Cash.Type, cashAmount, 'ped-looting') then
                Bridge.Notify(source, 'Found Cash', 'Found $' .. cashAmount, 'success')
                lootGiven = true
            end
        end
    end

    -- ITEM LOOT
    if lootTable.loot then
        for _, lootEntry in ipairs(lootTable.loot) do
            if rollChance(lootEntry.chance) then
                local amount = 1
                if lootEntry.amount then
                    amount = getRandomAmount(lootEntry.amount[1], lootEntry.amount[2])
                end

                if Bridge.AddItem(source, lootEntry.item, amount) then
                    Bridge.Notify(source, 'Found Item', 'Found ' .. lootEntry.item .. ' x' .. amount, 'success')
                    lootGiven = true
                end
            end
        end
    end

    -- No loot found
    if not lootGiven then
        Bridge.Notify(source, 'No Loot', 'Found nothing valuable', 'inform')
    end

    -- Police alert (if configured)
    if Config.PoliceIntegration.enabled and Config.PoliceIntegration.alertOnLoot then
        TriggerPoliceAlert(source, netId)
    end

    -- Evidence system (if configured)
    if Config.Evidence.enabled then
        LeaveEvidence(source, netId)
    end

    Bridge.Debug('Loot generated for player:', source, 'Category:', category, 'Items given:', lootGiven)
end

-- ═══════════════════════════════════════════════════════
-- POLICE INTEGRATION
-- ═══════════════════════════════════════════════════════

---Count online police
---@return number
local function getOnlinePolice()
    local count = 0
    for _, playerId in ipairs(GetPlayers()) do
        local src = tonumber(playerId)
        if Bridge.HasJob(src, Config.PoliceIntegration.policeJobs) then
            count = count + 1
        end
    end
    return count
end

---Trigger police alert for looting
---@param source number
---@param netId number
function TriggerPoliceAlert(source, netId)
    if not Config.PoliceIntegration.enabled then return end

    -- Check minimum police online
    if getOnlinePolice() < Config.PoliceIntegration.minPoliceOnline then return end

    -- Roll for alert chance
    if not rollChance(Config.PoliceIntegration.alertChance) then return end

    -- Get player coords via client callback
    lib.callback('dps-lootpeds:client:getCoords', source, function(coords)
        if not coords then return end

        -- Try qs-dispatch
        if Bridge.Resources.dispatch then
            TriggerEvent('qs-dispatch:server:CreateDispatchCall', {
                job = 'police',
                callLocation = coords,
                callCode = { code = '10-31', flash = false },
                message = 'Body Looting',
                description = 'Suspicious activity - someone is looting a dead body',
                units = {},
                time = 10,
                blip = {
                    sprite = 161,
                    scale = 1.0,
                    colour = 1,
                    flashes = false,
                    text = 'Body Looting',
                    time = 120
                }
            })
        else
            -- Fallback: notify police directly
            for _, playerId in ipairs(GetPlayers()) do
                local src = tonumber(playerId)
                if Bridge.HasJob(src, Config.PoliceIntegration.policeJobs) then
                    Bridge.Notify(src, '10-31 Report', 'Suspicious activity reported - possible body looting', 'inform', 10000)
                end
            end
        end
    end)
end

-- ═══════════════════════════════════════════════════════
-- EVIDENCE SYSTEM
-- ═══════════════════════════════════════════════════════

---Leave evidence when looting
---@param source number
---@param netId number
function LeaveEvidence(source, netId)
    if not Config.Evidence.enabled then return end
    if not Bridge.Resources.evidence then return end

    lib.callback('dps-lootpeds:client:getCoords', source, function(coords)
        if not coords then return end

        -- Try ps-evidence
        if Config.Evidence.fingerprints then
            TriggerEvent('ps-evidence:server:CreateFingerprint', source, coords)
        end
    end)
end

-- ═══════════════════════════════════════════════════════
-- SERVER CALLBACKS
-- ═══════════════════════════════════════════════════════

-- Check if ped is looted (State Bag verification)
lib.callback.register('dps-lootpeds:server:isPedLooted', function(source, netId)
    if not netId or netId <= 0 then return true end

    local ped = NetworkGetEntityFromNetworkId(netId)
    if not DoesEntityExist(ped) then return true end

    local state = Entity(ped).state
    return state.isLooted == true
end)

-- Check restrictions before looting
lib.callback.register('dps-lootpeds:server:canLoot', function(source)
    -- Check job restriction
    if Config.Restrictions.jobRestricted then
        if not Bridge.HasJob(source, Config.Restrictions.allowedJobs) then
            return false, 'job_restricted'
        end
    end

    -- Check required item
    if Config.Restrictions.requireItem then
        if not Bridge.HasItem(source, Config.Restrictions.requiredItem) then
            return false, 'need_item'
        end

        -- Consume item if configured
        if Config.Restrictions.consumeItem then
            Bridge.RemoveItem(source, Config.Restrictions.requiredItem, 1)
        end
    end

    return true, nil
end)

-- ═══════════════════════════════════════════════════════
-- EVENTS
-- ═══════════════════════════════════════════════════════

---Handle loot request from client
RegisterNetEvent('dps-lootpeds:server:loot', function(netId, pedModel)
    local source = source
    if not systemEnabled then return end

    -- Validate netId
    if not netId or netId <= 0 then
        Bridge.Debug('Invalid netId from source:', source)
        return
    end

    -- Check if already looted (State Bag)
    if Config.UseStateBags then
        local ped = NetworkGetEntityFromNetworkId(netId)
        if DoesEntityExist(ped) then
            local state = Entity(ped).state
            if state.isLooted then
                Bridge.Notify(source, 'Already Looted', 'This body has already been searched', 'warning')
                return
            end
        end
    end

    generateLoot(source, pedModel, netId)
end)

---Enable looting system
RegisterNetEvent('dps-lootpeds:server:enable', function()
    local source = source

    -- Permission check
    if Config.AdminOnly then
        local player = Bridge.GetPlayer(source)
        -- Add your admin check here
    end

    systemEnabled = true
    TriggerClientEvent('dps-lootpeds:client:enable', -1)
    Bridge.Debug('System enabled by:', source)
end)

---Disable looting system
RegisterNetEvent('dps-lootpeds:server:disable', function()
    local source = source

    -- Permission check
    if Config.AdminOnly then
        local player = Bridge.GetPlayer(source)
        -- Add your admin check here
    end

    systemEnabled = false
    TriggerClientEvent('dps-lootpeds:client:disable', -1)
    Bridge.Debug('System disabled by:', source)
end)

-- ═══════════════════════════════════════════════════════
-- COMMANDS
-- ═══════════════════════════════════════════════════════

lib.addCommand(Config.Commands.toggle, {
    help = 'Toggle ped looting system (on/off)',
    params = {
        { name = 'state', type = 'string', help = 'on or off' }
    },
    restricted = Config.AdminOnly and 'group.admin' or false
}, function(source, args)
    local state = args.state and string.lower(args.state)

    if state == 'on' then
        systemEnabled = true
        TriggerClientEvent('dps-lootpeds:client:enable', -1)
        Bridge.Notify(source, 'Loot System', 'Ped looting ENABLED', 'success')
    elseif state == 'off' then
        systemEnabled = false
        TriggerClientEvent('dps-lootpeds:client:disable', -1)
        Bridge.Notify(source, 'Loot System', 'Ped looting DISABLED', 'inform')
    else
        Bridge.Notify(source, 'Usage', '/' .. Config.Commands.toggle .. ' [on/off]', 'error')
    end
end)

-- ═══════════════════════════════════════════════════════
-- INITIALIZATION
-- ═══════════════════════════════════════════════════════

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    -- Sync state
    if systemEnabled then
        TriggerClientEvent('dps-lootpeds:client:enable', -1)
    else
        TriggerClientEvent('dps-lootpeds:client:disable', -1)
    end

    print('^2[dps-lootpeds]^7 v3.0.0 started')
    print('^2[dps-lootpeds]^7 State Bags: ' .. (Config.UseStateBags and '^2ENABLED' or '^1DISABLED') .. '^7')
    print('^2[dps-lootpeds]^7 System: ' .. (systemEnabled and '^2ENABLED' or '^1DISABLED') .. '^7')
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    print('^2[dps-lootpeds]^7 Resource stopped')
end)
