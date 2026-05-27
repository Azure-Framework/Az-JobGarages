Config = Config or {}


Config.DrawDistance = 25.0
Config.MarkerType   = 36
Config.MarkerScale  = vec3(0.9, 0.9, 0.9)
Config.MarkerZOff   = -0.9
Config.InteractKey  = 38 
Config.CooldownSeconds = 30 * 60 



Config.BlockIfActiveVehicleExists = true


Config.GetPlayerJob = Config.GetPlayerJob or function(source)
    local job = exports['Az-Framework']:getPlayerJob(source)
    return job and string.lower(job) or 'civ'
end


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


Config.GetPrimaryIdentifier = Config.GetPrimaryIdentifier or function(source)
    local license = GetPlayerIdentifierByType(source, 'license')
    if license and license ~= '' then
        return license
    end

    local ids = GetPlayerIdentifiers(source)
    return ids[1] or ("src:" .. tostring(source))
end










Config.EMSLocations = {
  JobID = { 'ems', 'ems', 'doctor' },

  Locations = {
    
    {
      Label = "Pillbox Hill Medical Center (Ambulance Bay)",
      XYZH  = vector4(294.7, -1447.6, 29.97, 320.0)
    },
    {
      Label = "Pillbox Hill Medical Center (Helipad)",
      XYZH  = vector4(338.9, -1416.9, 76.2, 135.0)
    },

    
    {
      Label = "Davis Medical (Ambulance Bay)",
      XYZH  = vector4(393.54, -1438.81, 29.46, 311.30)
    },

    
    {
      Label = "Mount Zonah Medical Center (Ambulance Bay)",
      XYZH  = vector4(-447.0, -340.6, 34.5, 80.0)
    },
    {
      Label = "Mount Zonah Medical Center (Helipad)",
      XYZH  = vector4(-449.3, -341.0, 78.3, 170.0)
    },

    
    {
      Label = "Sandy Shores Medical Center (Ambulance Bay)",
      XYZH  = vector4(1811.935, 3685.089, 34.224, 299.249)
    },
    {
      Label = "Paleto Bay Medical Center (Ambulance Bay)",
      XYZH  = vector4(-254.6, 6339.6, 32.4, 45.0)
    },
  },

  Vehicles = {
    { model = 'ambulance',  label = 'Ambulance' },
    { model = 'emsnspeedo', label = 'EMS Speedo' },
  }
}


Config.FireLocations = {
    JobID = { 'fire', 'safd' }, 
    Locations = {
        
        {
            Label = "Fire Station",
            XYZH  = vector4(1703.133, 3596.905, 35.435, 228.946)
        },
        {
          Label = "Strawberry Fire Station",
          XYZH = vector4(194.96, -1671.42, 29.80, 231.79)
        }
    },
    Vehicles = {
        { model = 'firetruk', label = 'Fire Truck' },
    }
}

Config.PoliceLocations = {
    JobID = { 'police', 'leo', 'sheriff' }, 
    Locations = {
        
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
