--Programmed entirely by serverOptimist. Used the framework known as Knit, programmed by Sleitnick
local Knit = require(game.ReplicatedStorage.Knit)

Knit.AddControllers(script.Parent.Controllers)

local ProfileController = Knit.GetController("ProfileController")
ProfileController:EnableLoadScreen()
Knit.Start():Catch(warn)
