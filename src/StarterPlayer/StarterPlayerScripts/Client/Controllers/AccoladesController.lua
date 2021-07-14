local playerObject: Player = game.Players.LocalPlayer

local PlayerGui = playerObject:WaitForChild("PlayerGui")

local UIElements = PlayerGui:WaitForChild("UIElements")
local AccoladeTemplate = UIElements:WaitForChild("AccoladeTemplate")

local Main = PlayerGui:WaitForChild("Main")
local MainFrame = Main:WaitForChild("MainFrame")
local PlayerProfile = MainFrame:WaitForChild("PlayerProfile")
local Container = PlayerProfile:WaitForChild("Container")
local AccoladesFrame = Container:WaitForChild("Accolades")
local AccoladesList = AccoladesFrame:WaitForChild("List")

local Knit = require(game.ReplicatedStorage.Knit)

local Promise = require(game.ReplicatedStorage.Knit.Util.Promise)

local AccoladesController = Knit.CreateController {Name = "AccoladesController"}

local ProfileController

local PlayerService = Knit.GetService("PlayerService")
local AccoladesService = Knit.GetService("AccoladesService")
local AdministrationService = Knit.GetService("AdministrationService")

Knit.selectedPlayerId = playerObject.UserId
Knit.selectedPlayerData = nil

local playerIsAdmin = AdministrationService:PlayerIsAdmin(playerObject)

function AccoladesController:AddAccolade(accoladeName: string)
    Knit.selectedPlayerData.Accolades[accoladeName] += 1
    self:UpdateOneAccolade(accoladeName)
    AccoladesService:AddAccolade(Knit.selectedPlayerId, accoladeName)
end

function AccoladesController:SubtractAccolade(accoladeName: string)
    if Knit.selectedPlayerData.Accolades[accoladeName] <= 0 then return end
    Knit.selectedPlayerData.Accolades[accoladeName] -= 1
    self:UpdateOneAccolade(accoladeName)
    AccoladesService:SubtractAccolade(Knit.selectedPlayerId, accoladeName)
end

--Only used when the client is loaded. MEant to load all accolades then update them to the player's data.
function AccoladesController:InitAccolades()
    for accoladeName, accoladeValue in next, Knit.selectedPlayerData.Accolades do
        local AccoladeFrame = AccoladeTemplate:Clone()
        local AccoladeNameLabel = AccoladeFrame:WaitForChild("AccoladeName")
        AccoladeNameLabel.Text = accoladeName
        AccoladeFrame.Name = accoladeName
        AccoladeFrame.Parent = AccoladesList
        
        local Add = AccoladeFrame:WaitForChild("Add")
        local Subtract = AccoladeFrame:WaitForChild("Subtract")

        if playerIsAdmin then 
            Add.MouseButton1Click:Connect(function()
                self:AddAccolade(accoladeName)
            end)

            Subtract.MouseButton1Click:Connect(function()
                self:SubtractAccolade(accoladeName)
            end)
        else
            Add.Visible = false
            Subtract.Visible = false
        end
        self:UpdateOneAccolade(accoladeName)
    end
    AccoladesList.CanvasSize = UDim2.new(0, 0, 0, AccoladesList.UIGridLayout.AbsoluteContentSize.Y)
end

function AccoladesController:UpdateOneAccolade(accoladeName: string)
    if not Knit.selectedPlayerData then 
        print("Player is not in prime legion!")
        return
    end

    Promise.new(function(resolve, reject)
        local success, result = pcall(function()
            local AccoladeFrame = AccoladesList:FindFirstChild(accoladeName)
            local Emblem = AccoladeFrame:WaitForChild("Emblem")
            local NumberOfAccolades = Emblem:WaitForChild("Number")
            NumberOfAccolades.Text = Knit.selectedPlayerData.Accolades[accoladeName]
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
end

--Update all the accolades. Typically used when a new player is searched in the search bar to update it to his/her corresponding data.
function AccoladesController:UpdateAllAccolades()
        if not Knit.selectedPlayerData then 
        return
    end
    for accoladeName, accoladeValue in next, Knit.selectedPlayerData.Accolades do 
        local AccoladeFrame = AccoladesList:FindFirstChild(accoladeName)
        if not AccoladeFrame then continue end
        AccoladeFrame.Emblem.Number.Text = accoladeValue
    end
end

function AccoladesController:SelectedPlayerChanged(newPlayerId)
    Knit.selectedPlayerId = newPlayerId
    Knit.selectedPlayerData = PlayerService:GetPlayerData(newPlayerId)
    self:UpdateAllAccolades()
end

function AccoladesController:KnitInit()
    ProfileController = Knit.GetController("ProfileController")
    Knit.selectedPlayerData = PlayerService:GetPlayerData(Knit.selectedPlayerId)
    self:InitAccolades()  
end

return AccoladesController