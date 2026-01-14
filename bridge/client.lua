--[[
    dps-lootpeds Client Bridge
    Framework Abstraction
]]

local QBCore, ESX = nil, nil
local PlayerData = {}

-- Initialize framework objects
CreateThread(function()
    if Bridge.Framework == 'qb' or Bridge.Framework == 'qbx' then
        QBCore = exports['qb-core']:GetCoreObject()
    elseif Bridge.Framework == 'esx' then
        ESX = exports['es_extended']:getSharedObject()
    end
end)

-- ═══════════════════════════════════════════════════════
-- PLAYER DATA
-- ═══════════════════════════════════════════════════════

function Bridge.GetPlayerData()
    if Bridge.Framework == 'qb' or Bridge.Framework == 'qbx' then
        return QBCore and QBCore.Functions.GetPlayerData() or {}
    elseif Bridge.Framework == 'esx' then
        return ESX and ESX.GetPlayerData() or {}
    end
    return {}
end

function Bridge.GetJob()
    local data = Bridge.GetPlayerData()
    if Bridge.Framework == 'qb' or Bridge.Framework == 'qbx' then
        return data.job and data.job.name or nil
    elseif Bridge.Framework == 'esx' then
        return data.job and data.job.name or nil
    end
    return nil
end

function Bridge.HasJob(jobName)
    local job = Bridge.GetJob()
    if type(jobName) == 'table' then
        for _, j in ipairs(jobName) do
            if job == j then return true end
        end
        return false
    end
    return job == jobName
end

-- ═══════════════════════════════════════════════════════
-- NOTIFICATION FUNCTION
-- ═══════════════════════════════════════════════════════

function Bridge.Notify(title, message, notifyType, duration)
    notifyType = notifyType or 'inform'
    duration = duration or 5000

    lib.notify({
        title = title,
        description = message,
        type = notifyType,
        duration = duration
    })
end

-- ═══════════════════════════════════════════════════════
-- PLAYER LOADED EVENT HANDLERS
-- ═══════════════════════════════════════════════════════

-- QB/QBX
if Bridge.Framework == 'qb' or Bridge.Framework == 'qbx' then
    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
        TriggerEvent('dps-lootpeds:client:playerLoaded')
    end)

    RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
        TriggerEvent('dps-lootpeds:client:playerUnloaded')
    end)
end

-- ESX
if Bridge.Framework == 'esx' then
    RegisterNetEvent('esx:playerLoaded', function(xPlayer)
        PlayerData = xPlayer
        TriggerEvent('dps-lootpeds:client:playerLoaded')
    end)

    RegisterNetEvent('esx:onPlayerLogout', function()
        PlayerData = {}
        TriggerEvent('dps-lootpeds:client:playerUnloaded')
    end)
end
