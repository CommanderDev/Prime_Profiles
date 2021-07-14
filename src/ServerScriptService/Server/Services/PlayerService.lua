
local GroupService = game:GetService("GroupService")
local DataStoreService = game:GetService("DataStoreService")

local Knit = require(game.ReplicatedStorage.Knit)

local PlayerService = Knit.CreateService {Name = "PlayerService", Client = {} }

local AccoladesService = Knit.GetService("AccoladesService")

local Promise = require(game.ReplicatedStorage.Knit.Util.Promise)
local RemoteSignal = require(game.ReplicatedStorage.Knit.Util.Signal)

local PlayerStore = DataStoreService:GetDataStore("PlayerStore")

Knit.playerDataCache = {}

function PlayerService:GetNewPlayerData(): table
    return {
        Accolades = AccoladesService:GetDefaultAccoladeData()
    }
end

function PlayerService:SoftMigrateData(playerData: table): table
    for index, value in next, self:GetNewPlayerData() do 
        if not playerData[index] then 
            playerData[index] = value
        end
    end
    return playerData
end

function PlayerService:GetPlayerData(playerId: number)
    if Knit.playerDataCache[tostring(playerId)] then
        return Knit.playerDataCache[tostring(playerId)]
    end
    
    local playerGroups = GroupService:GetGroupsAsync(playerId)
    local isInPrimeLegion = false

    for index, groupData in next, playerGroups do 
        if groupData.Id == Knit.PrimeLegion then 
            isInPrimeLegion = true 
            break
        end
    end

    if not isInPrimeLegion then 
        return
    end

    Promise.new(function(resolve, reject)
        local success, result = pcall(function()
            local playerData = PlayerStore:GetAsync(tostring(playerId))
            if playerData then 
                playerData = self:SoftMigrateData(playerData)
                return playerData
            else 
                return self:GetNewPlayerData()
            end
        end)
        if success then 
            resolve(result)
        else 
            reject(result)
        end 
    end)

    :Catch(function(err)
       warn(err) 
    end)

    :andThen(function(result)
        Knit.playerDataCache[tostring(playerId)] = result
    end)

    repeat wait() until Knit.playerDataCache[tostring(playerId)]
    return Knit.playerDataCache[tostring(playerId)]
end

function PlayerService:GetPlayerDataFromCache(playerId)
    return Knit.playerDataCache[tostring(playerId)]
end

function PlayerService.Client:GetPlayerData(playerObject: Player, selectedId: number): table
    if self.Server:GetPlayerDataFromCache() then 
        return self.Server:GetPlayerDataFromCache()
    end
    return self.Server:GetPlayerData(selectedId)
end

function PlayerService.Client:PlayerIsInPL(playerObject: Player, playerId: number): boolean
    return self.Server:PlayerIsInPL(playerId)
end

function PlayerService:PlayerIsInPL(playerId: number): boolean
    local playerGroups = GroupService:GetGroupsAsync(playerId)
    local isInPL = false
    for index, groupData in next, playerGroups do
        if groupData.Id == Knit.PrimeLegion then 
            isInPL = true
        end
    end
    return isInPL
end

function PlayerService:KnitInit()
    game.Players.PlayerAdded:Connect(function(playerObject: Player)
        self:GetPlayerData(playerObject.UserId)
    end)
end

game:BindToClose(function()
    for index, data in next, Knit.playerDataCache do 
        PlayerStore:SetAsync(index, data)
        wait(0.5)
    end
end)

return PlayerService
