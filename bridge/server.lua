--[[
    dps-lootpeds Server Bridge
    Framework & Inventory Abstraction
]]

local QBCore, ESX = nil, nil

-- Initialize framework objects
CreateThread(function()
    if Bridge.Framework == 'qb' or Bridge.Framework == 'qbx' then
        QBCore = exports['qb-core']:GetCoreObject()
    elseif Bridge.Framework == 'esx' then
        ESX = exports['es_extended']:getSharedObject()
    end
end)

-- ═══════════════════════════════════════════════════════
-- PLAYER FUNCTIONS
-- ═══════════════════════════════════════════════════════

function Bridge.GetPlayer(source)
    if Bridge.Framework == 'qb' or Bridge.Framework == 'qbx' then
        return QBCore and QBCore.Functions.GetPlayer(source)
    elseif Bridge.Framework == 'esx' then
        return ESX and ESX.GetPlayerFromId(source)
    end
    return nil
end

function Bridge.GetPlayerIdentifier(source)
    local player = Bridge.GetPlayer(source)
    if not player then return nil end

    if Bridge.Framework == 'qb' or Bridge.Framework == 'qbx' then
        return player.PlayerData.citizenid
    elseif Bridge.Framework == 'esx' then
        return player.identifier
    end
    return nil
end

function Bridge.GetPlayerName(source)
    local player = Bridge.GetPlayer(source)
    if not player then return 'Unknown' end

    if Bridge.Framework == 'qb' or Bridge.Framework == 'qbx' then
        local charinfo = player.PlayerData.charinfo
        return charinfo.firstname .. ' ' .. charinfo.lastname
    elseif Bridge.Framework == 'esx' then
        return player.getName()
    end
    return 'Unknown'
end

-- ═══════════════════════════════════════════════════════
-- MONEY FUNCTIONS
-- ═══════════════════════════════════════════════════════

function Bridge.AddMoney(source, moneyType, amount, reason)
    local player = Bridge.GetPlayer(source)
    if not player then return false end

    if Bridge.Framework == 'qb' or Bridge.Framework == 'qbx' then
        return player.Functions.AddMoney(moneyType, amount, reason or 'ped-looting')
    elseif Bridge.Framework == 'esx' then
        if moneyType == 'cash' then
            player.addMoney(amount, reason or 'ped-looting')
        else
            player.addAccountMoney(moneyType, amount, reason or 'ped-looting')
        end
        return true
    end
    return false
end

function Bridge.RemoveMoney(source, moneyType, amount, reason)
    local player = Bridge.GetPlayer(source)
    if not player then return false end

    if Bridge.Framework == 'qb' or Bridge.Framework == 'qbx' then
        return player.Functions.RemoveMoney(moneyType, amount, reason or 'ped-looting')
    elseif Bridge.Framework == 'esx' then
        if moneyType == 'cash' then
            player.removeMoney(amount, reason or 'ped-looting')
        else
            player.removeAccountMoney(moneyType, amount, reason or 'ped-looting')
        end
        return true
    end
    return false
end

function Bridge.GetMoney(source, moneyType)
    local player = Bridge.GetPlayer(source)
    if not player then return 0 end

    if Bridge.Framework == 'qb' or Bridge.Framework == 'qbx' then
        return player.PlayerData.money[moneyType] or 0
    elseif Bridge.Framework == 'esx' then
        if moneyType == 'cash' then
            return player.getMoney()
        else
            return player.getAccount(moneyType).money or 0
        end
    end
    return 0
end

-- ═══════════════════════════════════════════════════════
-- INVENTORY FUNCTIONS
-- ═══════════════════════════════════════════════════════

function Bridge.AddItem(source, item, amount, metadata)
    amount = amount or 1

    if Bridge.Inventory == 'ox' then
        return exports.ox_inventory:AddItem(source, item, amount, metadata)
    elseif Bridge.Inventory == 'qs' then
        return exports['qs-inventory']:AddItem(source, item, amount, nil, metadata)
    elseif Bridge.Inventory == 'qb' then
        local player = Bridge.GetPlayer(source)
        if player then
            return player.Functions.AddItem(item, amount, nil, metadata)
        end
    elseif Bridge.Inventory == 'codem' then
        return exports['codem-inventory']:AddItem(source, item, amount, metadata)
    end

    -- Fallback to framework inventory
    if Bridge.Framework == 'qb' or Bridge.Framework == 'qbx' then
        local player = Bridge.GetPlayer(source)
        if player then
            return player.Functions.AddItem(item, amount, nil, metadata)
        end
    elseif Bridge.Framework == 'esx' then
        local player = Bridge.GetPlayer(source)
        if player then
            player.addInventoryItem(item, amount)
            return true
        end
    end

    return false
end

function Bridge.RemoveItem(source, item, amount, metadata)
    amount = amount or 1

    if Bridge.Inventory == 'ox' then
        return exports.ox_inventory:RemoveItem(source, item, amount, metadata)
    elseif Bridge.Inventory == 'qs' then
        return exports['qs-inventory']:RemoveItem(source, item, amount)
    elseif Bridge.Inventory == 'qb' then
        local player = Bridge.GetPlayer(source)
        if player then
            return player.Functions.RemoveItem(item, amount)
        end
    elseif Bridge.Inventory == 'codem' then
        return exports['codem-inventory']:RemoveItem(source, item, amount)
    end

    -- Fallback
    if Bridge.Framework == 'qb' or Bridge.Framework == 'qbx' then
        local player = Bridge.GetPlayer(source)
        if player then
            return player.Functions.RemoveItem(item, amount)
        end
    elseif Bridge.Framework == 'esx' then
        local player = Bridge.GetPlayer(source)
        if player then
            player.removeInventoryItem(item, amount)
            return true
        end
    end

    return false
end

function Bridge.HasItem(source, item, amount)
    amount = amount or 1

    if Bridge.Inventory == 'ox' then
        local count = exports.ox_inventory:GetItemCount(source, item)
        return count >= amount
    elseif Bridge.Inventory == 'qs' then
        local hasItem = exports['qs-inventory']:GetItemByName(source, item)
        return hasItem and hasItem.amount >= amount
    elseif Bridge.Inventory == 'qb' then
        local player = Bridge.GetPlayer(source)
        if player then
            local hasItem = player.Functions.GetItemByName(item)
            return hasItem and hasItem.amount >= amount
        end
    end

    -- Fallback
    if Bridge.Framework == 'qb' or Bridge.Framework == 'qbx' then
        local player = Bridge.GetPlayer(source)
        if player then
            local hasItem = player.Functions.GetItemByName(item)
            return hasItem and hasItem.amount >= amount
        end
    elseif Bridge.Framework == 'esx' then
        local player = Bridge.GetPlayer(source)
        if player then
            local item = player.getInventoryItem(item)
            return item and item.count >= amount
        end
    end

    return false
end

-- ═══════════════════════════════════════════════════════
-- NOTIFICATION FUNCTION
-- ═══════════════════════════════════════════════════════

function Bridge.Notify(source, title, message, notifyType, duration)
    notifyType = notifyType or 'inform'
    duration = duration or 5000

    -- Always prefer ox_lib
    lib.notify(source, {
        title = title,
        description = message,
        type = notifyType,
        duration = duration
    })
end

-- ═══════════════════════════════════════════════════════
-- JOB FUNCTIONS
-- ═══════════════════════════════════════════════════════

function Bridge.GetPlayerJob(source)
    local player = Bridge.GetPlayer(source)
    if not player then return nil end

    if Bridge.Framework == 'qb' or Bridge.Framework == 'qbx' then
        return player.PlayerData.job.name
    elseif Bridge.Framework == 'esx' then
        return player.job.name
    end
    return nil
end

function Bridge.HasJob(source, job)
    local playerJob = Bridge.GetPlayerJob(source)
    if type(job) == 'table' then
        for _, j in ipairs(job) do
            if playerJob == j then return true end
        end
        return false
    end
    return playerJob == job
end
