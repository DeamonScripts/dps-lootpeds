--[[
    dps-lootpeds Bridge Initialization
    Framework & Inventory Detection
]]

Bridge = Bridge or {}

-- Framework Detection
local function DetectFramework()
    if GetResourceState('qbx_core') == 'started' then
        return 'qbx'
    elseif GetResourceState('qb-core') == 'started' then
        return 'qb'
    elseif GetResourceState('es_extended') == 'started' then
        return 'esx'
    end
    return 'standalone'
end

-- Inventory Detection
local function DetectInventory()
    if GetResourceState('ox_inventory') == 'started' then
        return 'ox'
    elseif GetResourceState('qs-inventory') == 'started' then
        return 'qs'
    elseif GetResourceState('qb-inventory') == 'started' then
        return 'qb'
    elseif GetResourceState('codem-inventory') == 'started' then
        return 'codem'
    end
    return 'none'
end

-- Initialize Bridge
Bridge.Framework = DetectFramework()
Bridge.Inventory = DetectInventory()

-- Resource detection for optional integrations
Bridge.Resources = {
    target = GetResourceState('ox_target') == 'started' or GetResourceState('qb-target') == 'started',
    dispatch = GetResourceState('qs-dispatch') == 'started' or GetResourceState('ps-dispatch') == 'started',
    evidence = GetResourceState('ps-evidence') == 'started' or GetResourceState('qb-evidence') == 'started',
}

-- Debug helper
function Bridge.Debug(...)
    if Config.Debug then
        print('^3[dps-lootpeds]^7', ...)
    end
end

-- Print startup info
if IsDuplicityVersion() then
    print('^2[dps-lootpeds]^7 Bridge initialized')
    print('^2[dps-lootpeds]^7 Framework: ^3' .. Bridge.Framework .. '^7')
    print('^2[dps-lootpeds]^7 Inventory: ^3' .. Bridge.Inventory .. '^7')
end
