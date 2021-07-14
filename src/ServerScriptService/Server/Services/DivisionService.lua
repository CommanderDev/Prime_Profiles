local GroupService = game:GetService("GroupService")

local Knit = require(game.ReplicatedStorage.Knit)

local DivisionService = Knit.CreateService {Name = "DivisionService", Client = {} }

local divisionsGroupId: number = 3731611

local divisions = GroupService:GetAlliesAsync(divisionsGroupId)
local divisionsData = table.create(#divisions:GetCurrentPage())
local divisionIds = table.create(#divisions:GetCurrentPage())

local divisionsBlacklist = {5799206, Knit.PrimeLegion} --What should not be included in the allies list.

function DivisionService.Client:GetPlayerDivisions(playerObject: Player, playerId: number)
    return self.Server:GetPlayerDivisions(playerId)
end
function DivisionService.Client:GetAllDivisions()
    return self.Server.GetAllDivisions()
end

function DivisionService:GetAllDivisions()
    return divisionsData
end

function DivisionService:GetPlayerDivisions(playerId: number): table
    local playerGroups = GroupService:GetGroupsAsync(playerId)
    local playerDivisions = table.create(#divisions:GetCurrentPage())
    local amountOfDivisionsPlayerIsIn = 0

    for index, group in next, playerGroups do
        if table.find(divisionIds, group.Id) and not table.find(divisionsBlacklist,group.Id) then 
            amountOfDivisionsPlayerIsIn += 1
            playerDivisions[amountOfDivisionsPlayerIsIn] = group
        end
    end
    return playerDivisions
end

function DivisionService:KnitInit()
    for index, groupData in next, divisions:GetCurrentPage() do 
        if table.find(divisionsBlacklist, groupData.Id) then continue end
        divisionsData[index] = groupData
        divisionIds[index] = groupData.Id
    end
end

return DivisionService