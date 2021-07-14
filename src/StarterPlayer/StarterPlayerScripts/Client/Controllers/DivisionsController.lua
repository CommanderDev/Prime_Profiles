local playerObject: Player = game.Players.LocalPlayer

local PlayerGui = playerObject:WaitForChild("PlayerGui")

local Main = PlayerGui:WaitForChild("Main")
local MainFrame = Main:WaitForChild("MainFrame")
local PlayerProfile = MainFrame:WaitForChild("PlayerProfile")

local Container = PlayerProfile:WaitForChild("Container")
local Divisions = Container:WaitForChild("Divisions")
local DivisionsList = Divisions:WaitForChild("List")

local UIElements = PlayerGui:WaitForChild("UIElements")
local DivisionTemplate = UIElements:WaitForChild("DivisionTemplate")

local Knit = require(game.ReplicatedStorage.Knit)

local DivisionsController = Knit.CreateController {Name = "DivisionsController"}

local DivisionService = Knit.GetService("DivisionService")

local allDivisions 

function DivisionsController:UpdateDivisions()
    local playerDivisions = DivisionService:GetPlayerDivisions(Knit.selectedPlayerId)
    for index, groupData in next, allDivisions do 
        local DivisionFrame = DivisionsList:FindFirstChild(groupData.Id)
        DivisionFrame.Visible = false
    end
    
    for index, groupData in next, playerDivisions do 
        local DivisionFrame = DivisionsList:FindFirstChild(groupData.Id)
        DivisionFrame.RoleLabel.Text = groupData.Role
        DivisionFrame.Visible = true
    end
    DivisionsList.CanvasSize = UDim2.new(0,0,0,DivisionsList.UIGridLayout.AbsoluteContentSize.Y)
end 

function DivisionsController:InitDivisions()
    allDivisions = DivisionService:GetAllDivisions(Knit.selectedPlayerId)
    for index, groupData in next, allDivisions do 
        local DivisionFrame = DivisionTemplate:Clone()
        local DivisionLabel = DivisionFrame:WaitForChild("DivisionLabel")
        local Emblem = DivisionFrame:WaitForChild("Emblem")
        local Icon = Emblem:WaitForChild("Icon")
        DivisionLabel.Text = groupData.Name
        Icon.Image = groupData.EmblemUrl
        DivisionFrame.Name = groupData.Id
        DivisionFrame.Visible = false
        DivisionFrame.Parent = DivisionsList
    end
    DivisionsController:UpdateDivisions()
end

function DivisionsController:KnitInit()
    self:InitDivisions()
end

return DivisionsController