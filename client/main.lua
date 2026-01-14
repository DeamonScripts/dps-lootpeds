--[[
    dps-lootpeds Client
    State Bag Synced Looting with ox_target
]]

local systemEnabled = Config.EnableOnStart
local isLooting = false

-- ═══════════════════════════════════════════════════════
-- HELPER FUNCTIONS
-- ═══════════════════════════════════════════════════════

---Check if a ped is looted via State Bag
---@param entity number
---@return boolean
local function isPedLooted(entity)
    if not DoesEntityExist(entity) then return true end

    if Config.UseStateBags then
        local state = Entity(entity).state
        return state.isLooted == true
    end

    return false
end

---Get ped model name from entity
---@param entity number
---@return string|nil
local function getPedModelName(entity)
    if not DoesEntityExist(entity) then return nil end

    local model = GetEntityModel(entity)
    -- Convert hash to string model name (approximate - for category matching)
    -- This is a simplified approach; actual model names come from the hash

    -- For better accuracy, we'll let the server determine category
    return tostring(model)
end

---Check if ped is blacklisted
---@param entity number
---@return boolean
local function isBlacklisted(entity)
    if not Config.Restrictions.blacklistedPeds then return false end

    local model = GetEntityModel(entity)
    for _, blacklisted in ipairs(Config.Restrictions.blacklistedPeds) do
        if GetHashKey(blacklisted) == model then
            return true
        end
    end
    return false
end

---Can player loot this ped?
---@param entity number
---@return boolean
local function canLootPed(entity)
    -- Must exist
    if not DoesEntityExist(entity) then return false end

    -- Must not be player ped
    if IsPedAPlayer(entity) then return false end

    -- Must be dead
    if not IsEntityDead(entity) then return false end

    -- Must not be looted (State Bag)
    if isPedLooted(entity) then return false end

    -- System must be enabled
    if not systemEnabled then return false end

    -- Must not be blacklisted
    if isBlacklisted(entity) then return false end

    return true
end

-- ═══════════════════════════════════════════════════════
-- LOOTING LOGIC
-- ═══════════════════════════════════════════════════════

---Attempt to loot a dead ped
---@param entity number
local function lootPed(entity)
    if isLooting then return end
    if not canLootPed(entity) then
        if isPedLooted(entity) then
            Bridge.Notify('Already Looted', 'This body has already been searched', 'warning')
        end
        return
    end

    -- Check restrictions via server
    local canLoot, reason = lib.callback.await('dps-lootpeds:server:canLoot', false)
    if not canLoot then
        if reason == 'job_restricted' then
            Bridge.Notify('Restricted', 'You cannot loot bodies', 'error')
        elseif reason == 'need_item' then
            Bridge.Notify('Missing Item', 'You need a ' .. Config.Restrictions.requiredItem, 'error')
        end
        return
    end

    isLooting = true

    -- Progress bar
    local success = lib.progressCircle({
        duration = Config.Animation.duration,
        position = 'bottom',
        label = 'Searching body...',
        useWhileDead = false,
        canCancel = Config.Animation.canCancel,
        disable = Config.Animation.disable,
        anim = {
            dict = Config.Animation.dict,
            clip = Config.Animation.clip
        }
    })

    isLooting = false

    if success then
        -- Get ped network ID and model for server
        local netId = PedToNet(entity)
        local modelHash = GetEntityModel(entity)

        -- Send to server with model info
        TriggerServerEvent('dps-lootpeds:server:loot', netId, tostring(modelHash))
    else
        Bridge.Notify('Cancelled', 'You stopped searching', 'inform')
    end
end

-- ═══════════════════════════════════════════════════════
-- TARGET SYSTEM
-- ═══════════════════════════════════════════════════════

local function loadTargetSystem()
    if not Config.UseTarget then return end

    if Config.UseAllPeds then
        -- Use global ped interaction (any dead NPC)
        exports.ox_target:addGlobalPed({
            {
                name = 'dps_loot_ped',
                icon = 'fas fa-hand-holding',
                label = 'Search Body',
                distance = Config.InteractionDistance,
                onSelect = function(data)
                    lootPed(data.entity)
                end,
                canInteract = function(entity, distance, coords, name, bone)
                    return canLootPed(entity)
                end
            }
        })
    else
        -- Use specific ped models
        if Config.PedModels and #Config.PedModels > 0 then
            exports.ox_target:addModel(Config.PedModels, {
                {
                    name = 'dps_loot_ped_model',
                    icon = 'fas fa-hand-holding',
                    label = 'Search Body',
                    distance = Config.InteractionDistance,
                    onSelect = function(data)
                        lootPed(data.entity)
                    end,
                    canInteract = function(entity)
                        return canLootPed(entity)
                    end
                }
            })
        end
    end

    Bridge.Debug('Target system loaded')
end

local function unloadTargetSystem()
    if not Config.UseTarget then return end

    if Config.UseAllPeds then
        exports.ox_target:removeGlobalPed('dps_loot_ped')
    else
        if Config.PedModels and #Config.PedModels > 0 then
            exports.ox_target:removeModel(Config.PedModels, 'dps_loot_ped_model')
        end
    end
end

-- ═══════════════════════════════════════════════════════
-- VISUAL INDICATOR FOR LOOTED BODIES
-- ═══════════════════════════════════════════════════════

-- Optional: Show visual indicator on looted bodies
local function drawLootedIndicator()
    if not Config.UseStateBags then return end

    CreateThread(function()
        while true do
            local sleep = 1000
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)

            -- Find nearby peds
            local closestPed, closestDist = nil, 10.0

            for ped in EnumeratePeds() do
                if DoesEntityExist(ped) and not IsPedAPlayer(ped) and IsEntityDead(ped) then
                    local pedCoords = GetEntityCoords(ped)
                    local dist = #(playerCoords - pedCoords)

                    if dist < closestDist then
                        local state = Entity(ped).state
                        if state.isLooted then
                            sleep = 0
                            -- Draw "LOOTED" text above body
                            local onScreen, x, y = World3dToScreen2d(pedCoords.x, pedCoords.y, pedCoords.z + 0.5)
                            if onScreen then
                                SetTextScale(0.3, 0.3)
                                SetTextFont(4)
                                SetTextColour(200, 200, 200, 180)
                                SetTextOutline()
                                SetTextCentre(true)
                                SetTextEntry('STRING')
                                AddTextComponentString('~c~[SEARCHED]')
                                DrawText(x, y)
                            end
                        end
                    end
                end
            end

            Wait(sleep)
        end
    end)
end

-- Ped enumeration helper (for visual indicator)
function EnumeratePeds()
    return coroutine.wrap(function()
        local handle, ped = FindFirstPed()
        local success

        repeat
            coroutine.yield(ped)
            success, ped = FindNextPed(handle)
        until not success

        EndFindPed(handle)
    end)
end

-- ═══════════════════════════════════════════════════════
-- SERVER CALLBACKS (Client-side)
-- ═══════════════════════════════════════════════════════

lib.callback.register('dps-lootpeds:client:getCoords', function()
    return GetEntityCoords(PlayerPedId())
end)

-- ═══════════════════════════════════════════════════════
-- EVENTS
-- ═══════════════════════════════════════════════════════

---Delete ped from game
RegisterNetEvent('dps-lootpeds:client:deletePed', function(netId)
    if not Config.DeletePedsWhenLooted then return end
    if not netId or netId <= 0 then return end

    local entity = NetToPed(netId)
    if DoesEntityExist(entity) and not IsPedAPlayer(entity) then
        -- Request network control
        local timeout = 0
        while not NetworkHasControlOfEntity(entity) and timeout < 20 do
            NetworkRequestControlOfEntity(entity)
            Wait(100)
            timeout = timeout + 1
        end

        if NetworkHasControlOfEntity(entity) then
            DeletePed(entity)
            DeleteEntity(entity)
        end
    end
end)

---Enable system
RegisterNetEvent('dps-lootpeds:client:enable', function()
    systemEnabled = true
    Bridge.Debug('System enabled')
end)

---Disable system
RegisterNetEvent('dps-lootpeds:client:disable', function()
    systemEnabled = false
    Bridge.Debug('System disabled')
end)

-- ═══════════════════════════════════════════════════════
-- INITIALIZATION
-- ═══════════════════════════════════════════════════════

-- Player loaded
RegisterNetEvent('dps-lootpeds:client:playerLoaded', function()
    loadTargetSystem()
    drawLootedIndicator()
end)

-- QB/QBX event
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    TriggerEvent('dps-lootpeds:client:playerLoaded')
end)

-- ESX event
AddEventHandler('esx:playerLoaded', function()
    TriggerEvent('dps-lootpeds:client:playerLoaded')
end)

-- Resource start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    -- Delay to ensure bridge is loaded
    Wait(1000)
    loadTargetSystem()
    drawLootedIndicator()
end)

-- Resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    unloadTargetSystem()
end)

-- ═══════════════════════════════════════════════════════
-- EXPORTS
-- ═══════════════════════════════════════════════════════

exports('IsSystemEnabled', function()
    return systemEnabled
end)

exports('IsPedLooted', function(entity)
    return isPedLooted(entity)
end)

exports('LootPed', function(entity)
    lootPed(entity)
end)
