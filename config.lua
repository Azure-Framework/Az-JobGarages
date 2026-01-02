Config = Config or {}

-- Core settings
Config.DrawDistance = 25.0
Config.MarkerType   = 36
Config.MarkerScale  = vec3(0.9, 0.9, 0.9)
Config.MarkerZOff   = -0.9
Config.InteractKey  = 38 -- E
Config.CooldownSeconds = 30 * 60 -- 30 minutes

-- If true: player cannot spawn a new job vehicle while their previous spawned
-- one (from this spawner) still exists.
Config.BlockIfActiveVehicleExists = true

-- Job getter (Az-Framework)
Config.GetPlayerJob = Config.GetPlayerJob or function(source)
    local job = exports['Az-Framework']:getPlayerJob(source)
    return job and string.lower(job) or 'civ'
end

-- Character identity (Az-CharacterUI)
Config.GetPlayerCharId = Config.GetPlayerCharId or function(source)
    local ui = exports['Az-CharacterUI']
    if not ui then return nil end

    local ok, charId = pcall(function()
        return ui:getActiveCharacter(source)
    end)

    if ok and charId then
        return tostring(charId)
    end

    return nil
end

-- Fallback identity (license)
Config.GetPrimaryIdentifier = Config.GetPrimaryIdentifier or function(source)
    local license = GetPlayerIdentifierByType(source, 'license')
    if license and license ~= '' then
        return license
    end

    local ids = GetPlayerIdentifiers(source)
    return ids[1] or ("src:" .. tostring(source))
end

-- =========================================================
-- Your requested config style:
-- EMSLocations / FireLocations / PoliceLocations
-- Each has:
--   JobID
--   Locations = { { XYZH = vector4(...) , Label = "..." } }
--   Vehicles = { { model="...", label="..." }, ... }
-- =========================================================

Config.EMSLocations = {
    JobID = { 'ems', 'ems', 'doctor' }, -- you can change this list
    Locations = {
        {
            Label = "Sandy EMS Bay",
            XYZH  = vector4(1811.935, 3685.089, 34.224, 299.249)
        }
    },
    Vehicles = {
        { model = 'ambulance', label = 'Ambulance' },
        { model = 'emsnspeedo', label = 'EMS Speedo' }, -- if you have one
    }
}

Config.FireLocations = {
    JobID = { 'fire', 'safd' }, -- change to your job names
    Locations = {
        -- Example placeholder, change these:
        {
            Label = "Fire Station",
            XYZH  = vector4(1703.133, 3596.905, 35.435, 228.946)
        }
    },
    Vehicles = {
        { model = 'firetruk', label = 'Fire Truck' },
    }
}

Config.PoliceLocations = {
    JobID = { 'police', 'leo', 'sheriff' }, -- change to your job names
    Locations = {
        -- Example placeholder, change these:
        {
            Label = "Mission Row Motorpool",
            XYZH  = vector4(451.0, -1018.0, 28.5, 90.0)
        }
    },
    Vehicles = {
        { model = 'police', label = 'Police Cruiser' },
        { model = 'police2', label = 'Police Buffalo' },
    }
}

-- Optional UI text
Config.Text = {
    EMS   = "Press ~INPUT_CONTEXT~ to spawn an EMS vehicle",
    Fire  = "Press ~INPUT_CONTEXT~ to spawn a Fire vehicle",
    Police= "Press ~INPUT_CONTEXT~ to spawn a Police vehicle",

    NotAuthorized = "You are not authorized to use this spawner.",
    Cooldown      = "You must wait %s before spawning another job vehicle.",
    ActiveBlock   = "You already have a spawned job vehicle out.",
    Spawned       = "Vehicle spawned.",
    InvalidModel  = "Vehicle model is invalid.",
}
