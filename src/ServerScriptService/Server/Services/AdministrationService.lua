local Knit = require(game.ReplicatedStorage.Knit)

local AdministrationService = Knit.CreateService {Name = "AdministrationService", Client = {} }

Knit.PrimeLegion = 364831
Knit.MinimumAdministrationRank = 19
Knit.AdministrationWhitelist = {"serverOptimist"}

function AdministrationService.Client:PlayerIsAdmin(playerObject: Player)
    return self.Server:PlayerIsAdmin(playerObject)
end

function AdministrationService:PlayerIsAdmin(playerObject: Player): boolean
    if playerObject:GetRankInGroup(Knit.PrimeLegion) >= Knit.MinimumAdministrationRank or table.find(Knit.AdministrationWhitelist, playerObject.Name) then
        return true
    else
        return false
    end
end

function AdministrationService:KnitInit()

end

return AdministrationService