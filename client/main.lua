--[[ ===================================================== ]]--
--[[       DSRP Loot Peds - QBox/ox_lib Compatible        ]]--
--[[         Original by MaDHouSe - Adapted for DSRP      ]]--
--[[ ===================================================== ]]--

local lootedPeds = {}
local systemEnabled = Config.EnableOnStart

-- ═══════════════════════════════════════════════════════
-- HELPER FUNCTIONS
-- ═══════════════════════════════════════════════════════

---Check if a ped has already been looted
---@param entity number
---@return boolean
local function isPedLooted(entity)
    for _, v in pairs(lootedPeds) do
        if v.ped == entity then
            return true
        end
    end
    return false
end

---Mark a ped as looted
---@param entity number
local function markPedLooted(entity)
    if isPedLooted(entity) then return end
    lootedPeds[#lootedPeds + 1] = { ped = entity, time = GetGameTimer() }
end

---Clean up old looted peds from memory (if not deleted)
local function cleanupLootedPeds()
    local currentTime = GetGameTimer()
    for i = #lootedPeds, 1, -1 do
        if (currentTime - lootedPeds[i].time) > Config.LootCooldown then
            table.remove(lootedPeds, i)
        end
    end
end

-- Run cleanup every 30 seconds
CreateThread(function()
    while true do
        Wait(30000)
        cleanupLootedPeds()
    end
end)

-- ═══════════════════════════════════════════════════════
-- LOOT INTERACTION
-- ═══════════════════════════════════════════════════════

---Attempt to loot a dead ped
---@param entity number
local function lootPed(entity)
    if not systemEnabled then
        lib.notify({
            title = 'Looting Disabled',
            description = 'The looting system is currently disabled',
            type = 'error'
        })
        return
    end

    if isPedLooted(entity) then
        lib.notify({
            title = 'Already Looted',
            description = locale('notifications.already_looted'),
            type = 'warning'
        })
        return
    end

    -- Progress bar while looting
    if lib.progressCircle({
        duration = 2500,
        position = 'bottom',
        label = 'Searching corpse...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            car = true,
            combat = true
        },
        anim = {
            dict = 'amb@medic@standing@kneel@base',
            clip = 'base'
        }
    }) then
        -- Successfully completed progress
        TriggerServerEvent('dsrp-lootpeds:server:loot', PedToNet(entity))
        markPedLooted(entity)
    else
        -- Cancelled
        lib.notify({
            title = 'Cancelled',
            description = 'You stopped searching the corpse',
            type = 'inform'
        })
    end
end

-- ═══════════════════════════════════════════════════════
-- TARGET SYSTEM SETUP
-- ═══════════════════════════════════════════════════════

---Load ox_target interactions for ped models
local function loadTargetSystem()
    if not Config.UseTarget then return end

    exports.ox_target:addModel(Config.PedModels, {
        {
            name = 'loot_dead_ped',
            icon = 'fas fa-skull-crossbones',
            label = locale('target.label'),
            onSelect = function(data)
                lootPed(data.entity)
            end,
            canInteract = function(entity, distance, coords, name, bone)
                -- Must be a ped (not player)
                if IsPedAPlayer(entity) then return false end

                -- Must be dead
                if not IsEntityDead(entity) then return false end

                -- Must not be already looted
                if isPedLooted(entity) then return false end

                -- System must be enabled
                if not systemEnabled then return false end

                return true
            end,
            distance = Config.InteractionDistance
        }
    })
end

-- ═══════════════════════════════════════════════════════
-- EVENTS
-- ═══════════════════════════════════════════════════════

---Delete ped from game world
RegisterNetEvent('dsrp-lootpeds:client:deletePed', function(netId)
    if not Config.DeletePedsWhenLooted then return end

    local entity = NetToPed(netId)
    if DoesEntityExist(entity) and not IsPedAPlayer(entity) then
        DeletePed(entity)
        DeleteEntity(entity)
    end
end)

---Enable looting system
RegisterNetEvent('dsrp-lootpeds:client:enable', function()
    systemEnabled = true
    lib.notify({
        title = 'Looting System',
        description = locale('system.enable'),
        type = 'success'
    })
end)

---Disable looting system
RegisterNetEvent('dsrp-lootpeds:client:disable', function()
    systemEnabled = false
    lib.notify({
        title = 'Looting System',
        description = locale('system.disable'),
        type = 'inform'
    })
end)

-- ═══════════════════════════════════════════════════════
-- INITIALIZATION
-- ═══════════════════════════════════════════════════════

---Initialize resource on player load
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    loadTargetSystem()
    if systemEnabled then
        lib.notify({
            title = 'Looting System',
            description = 'Ped looting is enabled',
            type = 'inform',
            duration = 3000
        })
    end
end)

---Initialize resource on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    loadTargetSystem()
end)

---Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    lootedPeds = {}
    systemEnabled = false

    -- Remove target interactions
    if Config.UseTarget then
        exports.ox_target:removeModel(Config.PedModels, 'loot_dead_ped')
    end
end)