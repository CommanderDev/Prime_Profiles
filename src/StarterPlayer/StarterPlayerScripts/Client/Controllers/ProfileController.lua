local playerObject: Player = game.Players.LocalPlayer

local PlayerGui = playerObject:WaitForChild("PlayerGui")

local Main = PlayerGui:WaitForChild("Main")
local MainFrame = Main:WaitForChild("MainFrame")
local LoadScreen = Main:WaitForChild("LoadScreen")

local PlayerProfile = MainFrame:WaitForChild("PlayerProfile")

local Container = PlayerProfile:WaitForChild("Container")
local PlayerDisplay = Container:WaitForChild("PlayerDisplay")
local ImageContainer = PlayerDisplay:WaitForChild("Container")
local PlayerImage = ImageContainer:WaitForChild("PlayerImage")
local Portrait = PlayerImage:WaitForChild("Portrait")
local PlayerName = PlayerImage:WaitForChild("PlayerName")

local ProfileSearch = PlayerProfile:WaitForChild("ProfileSearch")
local SearchBox = ProfileSearch:WaitForChild("Box")
local Knit = require(game.ReplicatedStorage.Knit)

local ProfileController = Knit.CreateController {Name = "ProfileController"}

local PlayerService

local AccoladesController
local DivisionsController

function ProfileController:UpdatePlayerPortrait()
    Portrait.Image = game.Players:GetUserThumbnailAsync(Knit.selectedPlayerId, Enum.ThumbnailType.AvatarThumbnail,  Enum.ThumbnailSize.Size352x352)
    PlayerName.Text = game.Players:GetNameFromUserIdAsync(Knit.selectedPlayerId)
end

function ProfileController:KnitInit()
    
    local connection
    connection = SearchBox.Focused:Connect(function()
        SearchBox.ClearTextOnFocus = false
        connection:Disconnect()
    end)
    SearchBox.FocusLost:Connect(function()
        self:EnableLoadScreen()
        local playerId = game.Players:GetUserIdFromNameAsync(SearchBox.Text)
        if not playerId then return end
        local isInPL = PlayerService:PlayerIsInPL(playerId)
        if not isInPL then 
            self:DisableLoadScreen() 
            return 
        end
        
        AccoladesController:SelectedPlayerChanged(playerId)
        DivisionsController:UpdateDivisions()
        self:UpdatePlayerPortrait()
        self:DisableLoadScreen()
    end)
end

function ProfileController:KnitStart()
    PlayerService = Knit.GetService("PlayerService")
    AccoladesController = Knit.GetController("AccoladesController")
    DivisionsController = Knit.GetController("DivisionsController")
    
    self:UpdatePlayerPortrait()
    ProfileController:DisableLoadScreen()
end

function ProfileController:EnableLoadScreen()
    MainFrame.Visible = false 
    LoadScreen.Visible = true
end
function ProfileController:DisableLoadScreen()
    MainFrame.Visible = true 
    LoadScreen.Visible = false
end

return ProfileController