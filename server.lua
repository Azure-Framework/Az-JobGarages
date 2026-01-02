-- az_jobveh_spawner / server.lua

local lastSpawnByIdentity = {}   -- [identityKey][groupName] = os.time()
local activeVehByIdentity = {}   -- [identityKey][groupName] = netId

-- Debug toggle
Config.Debug = (Config.Debug == true)

local function sdebug(msg)
    if not Config.Debug then return end
    print(('[az_jobveh][S] %s'):format(msg))
end

local function jobListToString(jobList)
    if type(jobList) == 'string' then
        return tostring(jobList)
    end
    if type(jobList) == 'table' then
        local out = {}
        for i, v in ipairs(jobList) do
            out[#out+1] = tostring(v)
        end
        return table.concat(out, ', ')
    end
    return 'nil'
end

local function getIdentity(src)
    local charId = Config.GetPlayerCharId(src)
    if charId and charId ~= '' then
        return ("char:%s"):format(charId)
    end
    local lic = Config.GetPrimaryIdentifier(src)
    return ("license:%s"):format(lic)
end

local function isJobAllowed(job, jobList)
    if type(jobList) == 'string' then
        return string.lower(job) == string.lower(jobList)
    end
    if type(jobList) == 'table' then
        local j = string.lower(job)
        for _, allowed in ipairs(jobList) do
            if j == string.lower(tostring(allowed)) then
                return true
            end
        end
    end
    return false
end

local function getGroupConfig(groupName)
    if groupName == 'EMS' then return Config.EMSLocations end
    if groupName == 'Fire' then return Config.FireLocations end
    if groupName == 'Police' then return Config.PoliceLocations end
    return nil
end

local function remainingCooldown(identity, groupName)
    lastSpawnByIdentity[identity] = lastSpawnByIdentity[identity] or {}
    local last = lastSpawnByIdentity[identity][groupName] or 0
    local now  = os.time()
    local cd   = Config.CooldownSeconds or 1800
    local rem  = cd - (now - last)
    if rem < 0 then rem = 0 end
    return rem
end

-- Optional debug command
RegisterCommand('az_jobdebug', function(src)
    if src == 0 then
        print('[az_jobveh] Use in-game: /az_jobdebug')
        return
    end

    local job = Config.GetPlayerJob(src)
    local identity = getIdentity(src)

    sdebug(('az_jobdebug -> src=%d job=%s identity=%s')
        :format(src, tostring(job), tostring(identity)))

    TriggerClientEvent('az_jobveh:notify', src, 'info',
        ('Debug: job=%s | identity=%s'):format(tostring(job), tostring(identity))
    )
end, false)

RegisterNetEvent('az_jobveh:requestSpawn', function(groupName, locationIndex, vehicleIndex)
    local src = source
    groupName = tostring(groupName or '')

    local group = getGroupConfig(groupName)
    if not group then
        sdebug(('requestSpawn -> invalid groupName=%s'):format(groupName))
        return
    end

    local job = Config.GetPlayerJob(src) or 'civ'
    local allowed = isJobAllowed(job, group.JobID)

    sdebug(('requestSpawn -> src=%d group=%s job=%s allowedJobs=[%s] allowed=%s')
        :format(
            src,
            groupName,
            tostring(job),
            jobListToString(group.JobID),
            tostring(allowed)
        )
    )

    if not allowed then
        TriggerClientEvent('az_jobveh:notify', src, 'error',
            (Config.Text and Config.Text.NotAuthorized) or "You are not authorized to use this spawner."
        )
        return
    end

    local identity = getIdentity(src)
    sdebug(('requestSpawn -> identity resolved as %s'):format(identity))

    -- Block if active vehicle exists
    if Config.BlockIfActiveVehicleExists then
        activeVehByIdentity[identity] = activeVehByIdentity[identity] or {}
        local netId = activeVehByIdentity[identity][groupName]
        if netId then
            local ent = NetworkGetEntityFromNetworkId(netId)
            if ent and ent ~= 0 and DoesEntityExist(ent) then
                sdebug(('requestSpawn -> blocked: active vehicle exists netId=%s'):format(tostring(netId)))
                TriggerClientEvent('az_jobveh:notify', src, 'error',
                    (Config.Text and Config.Text.ActiveBlock) or "You already have a spawned job vehicle out."
                )
                return
            else
                activeVehByIdentity[identity][groupName] = nil
            end
        end
    end

    -- Cooldown check
    local rem = remainingCooldown(identity, groupName)
    if rem > 0 then
        sdebug(('requestSpawn -> cooldown remaining=%d sec'):format(rem))
        TriggerClientEvent('az_jobveh:cooldown', src, rem)
        return
    end

    local loc = group.Locations and group.Locations[tonumber(locationIndex or 1)]
    if not loc or not loc.XYZH then
        sdebug(('requestSpawn -> bad location index=%s'):format(tostring(locationIndex)))
        return
    end

    local vehEntry = group.Vehicles and group.Vehicles[tonumber(vehicleIndex or 1)]
    if not vehEntry or not vehEntry.model then
        sdebug(('requestSpawn -> bad vehicle index=%s'):format(tostring(vehicleIndex)))
        return
    end

    -- Approve spawn
    lastSpawnByIdentity[identity] = lastSpawnByIdentity[identity] or {}
    lastSpawnByIdentity[identity][groupName] = os.time()

    sdebug(('requestSpawn -> APPROVED src=%d model=%s locLabel=%s')
        :format(src, tostring(vehEntry.model), tostring(loc.Label or 'unknown')))

    TriggerClientEvent(
        'az_jobveh:spawnApproved',
        src,
        groupName,
        loc.XYZH,
        vehEntry.model,
        vehEntry.label or vehEntry.model
    )
end)

RegisterNetEvent('az_jobveh:registerSpawned', function(groupName, netId)
    local src = source
    groupName = tostring(groupName or '')
    if not netId then return end

    local identity = getIdentity(src)
    activeVehByIdentity[identity] = activeVehByIdentity[identity] or {}
    activeVehByIdentity[identity][groupName] = netId

    sdebug(('registerSpawned -> src=%d group=%s identity=%s netId=%s')
        :format(src, groupName, identity, tostring(netId)))
end)

AddEventHandler('playerDropped', function()
    local src = source
    local identity = getIdentity(src)
    activeVehByIdentity[identity] = nil
    sdebug(('playerDropped -> cleared active tracking for identity=%s'):format(identity))
end)
