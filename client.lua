


local function prettyTime(seconds)
    seconds = tonumber(seconds) or 0
    if seconds <= 0 then return "0s" end
    local m = math.floor(seconds / 60)
    local s = math.floor(seconds % 60)
    if m > 0 then
        return string.format("%dm %ds", m, s)
    end
    return string.format("%ds", s)
end

local function notify(kind, text)
    TriggerEvent('chat:addMessage', { args = { '^3Job Vehicles', text or '' } })
end

RegisterNetEvent('az_jobveh:notify', function(kind, text)
    notify(kind, text or '')
end)

RegisterNetEvent('az_jobveh:cooldown', function(rem)
    local msg = "Cooldown: %s"
    if Config.Text and Config.Text.Cooldown then
        msg = Config.Text.Cooldown
    end
    notify('error', msg:format(prettyTime(rem)))
end)

local function getGroupList()
    return {
        { name = 'EMS',    cfg = Config.EMSLocations,    text = (Config.Text and Config.Text.EMS) or "Press ~INPUT_CONTEXT~ to spawn an EMS vehicle" },
        { name = 'Fire',   cfg = Config.FireLocations,   text = (Config.Text and Config.Text.Fire) or "Press ~INPUT_CONTEXT~ to spawn a Fire vehicle" },
        { name = 'Police', cfg = Config.PoliceLocations, text = (Config.Text and Config.Text.Police) or "Press ~INPUT_CONTEXT~ to spawn a Police vehicle" },
    }
end

local function drawMarkerAt(x, y, z)
    DrawMarker(
        Config.MarkerType or 36,
        x, y, z + (Config.MarkerZOff or -0.9),
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        (Config.MarkerScale and Config.MarkerScale.x) or 0.9,
        (Config.MarkerScale and Config.MarkerScale.y) or 0.9,
        (Config.MarkerScale and Config.MarkerScale.z) or 0.9,
        255, 80, 80, 180,
        false, true, 2, nil, nil, false
    )
end

local function helpText(msg)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(msg or '')
    EndTextCommandDisplayHelp(0, false, false, -1)
end

RegisterNetEvent('az_jobveh:spawnApproved', function(groupName, xyzh, modelName, label)
    local ped = PlayerPedId()
    if not ped or ped == 0 then return end

    local model = joaat(modelName)
    if not IsModelInCdimage(model) then
        notify('error', (Config.Text and Config.Text.InvalidModel) or "Vehicle model invalid.")
        return
    end

    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    local x, y, z, h = xyzh.x, xyzh.y, xyzh.z, xyzh.w
    local veh = CreateVehicle(model, x, y, z, h or 0.0, true, true)
    SetModelAsNoLongerNeeded(model)

    if veh and veh ~= 0 then
        SetVehicleOnGroundProperly(veh)

        local netId = NetworkGetNetworkIdFromEntity(veh)
        SetNetworkIdCanMigrate(netId, true)

        TriggerServerEvent('az_jobveh:registerSpawned', groupName, netId)

        notify('success',
            ((Config.Text and Config.Text.Spawned) or "Vehicle spawned.")
            .. (label and (" (" .. label .. ")") or "")
        )
    else
        notify('error', "Failed to spawn vehicle.")
    end
end)

CreateThread(function()
    while true do
        local waitMs = 1000

        local ped = PlayerPedId()
        if ped and ped ~= 0 then
            local coords = GetEntityCoords(ped)

            for _, g in ipairs(getGroupList()) do
                local cfg = g.cfg
                if cfg and cfg.Locations then
                    for i, loc in ipairs(cfg.Locations) do
                        local v = loc.XYZH
                        if v then
                            local dist = #(coords - vec3(v.x, v.y, v.z))

                            if dist <= (Config.DrawDistance or 25.0) then
                                waitMs = 0
                                drawMarkerAt(v.x, v.y, v.z)

                                if dist <= 2.0 then
                                    local msg = loc.Label
                                        and (loc.Label .. "\n" .. (g.text or "Press E to spawn"))
                                        or (g.text or "Press E to spawn")

                                    helpText(msg)

                                    if IsControlJustPressed(0, Config.InteractKey or 38) then
                                        
                                        TriggerServerEvent('az_jobveh:requestSpawn', g.name, i, 1)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        Wait(waitMs)
    end
end)
