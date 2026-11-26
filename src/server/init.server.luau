--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Loader = require(Shared.Loader)
local Remotes = require(Shared.Remotes)

Remotes.CreateAll()
Loader.LoadFolder(script.Services)
