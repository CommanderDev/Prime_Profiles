local Knit = require(game.ReplicatedStorage.Knit)

local AccoladesService = Knit.CreateService {Name = "AccoladesService", Client = {} }
local AdministrationService
local DataStoreService = game:GetService("DataStoreService")
local PlayerStore = DataStoreService:GetDataStore("PlayerStore")

local AccoladesData: table = {
    "Laurel of Recruitment";
    "Laurel of Incursion";
    "Laurel of Fortitude";
    "Laurel of the Order";
    "Laurel of the Royal Guard";
    "Laurel of the Dragoons";
    "Laurel of Activity";
    "Laurel of Architvity";
    "Laurel of Communication";
    "Mark of the Legion";
}

local defaultAccoladeData = {}

function AccoladesService:GetDefaultAccoladeData()
    return defaultAccoladeData
end

function AccoladesService:GetAccoladesData()
    return AccoladesData
end

function AccoladesService.Client:AddAccolade(playerObject: Player, playerId: string, accoladeName: string)
    self.Server:AddAccolade(playerObject, playerId, accoladeName)
end

function AccoladesService.Client:SubtractAccolade(playerObject: Player, playerId: string, accoladeName: string)
    self.Server:SubtractAccolade(playerObject, playerId, accoladeName)
end

function AccoladesService:AddAccolade(playerObject, playerId: number, accoladeName: string)
    if not AdministrationService:PlayerIsAdmin(playerObject) then return end
    Knit.playerDataCache[tostring(playerId)].Accolades[accoladeName] += 1
end

function AccoladesService:SubtractAccolade(playerObject, playerId, accoladeName)
    if not AdministrationService:PlayerIsAdmin(playerObject) then return end
    if Knit.playerDataCache[tostring(playerId)].Accolades[accoladeName] <= 0 then return end
    Knit.playerDataCache[tostring(playerId)].Accolades[accoladeName] -= 1
end

function AccoladesService:KnitInit()
    for index, accolade in next, AccoladesData do 
        defaultAccoladeData[accolade] = 0;
    end
    AdministrationService = Knit.GetService("AdministrationService")
end

return AccoladesService

