-- // SERVICES
local Players = game:GetService("Players")
-- // OBJECTS
local Player = Players.LocalPlayer
local Character = Player.Character
-- // VARIABLES
local HatsProp = {
    ["Head"] = {
        ["Position"] = Vector3.new(0, .25, 0),
        ["Orientation"] = Vector3.new()
    },
    ["Torso"] = {
        ["Position"] = Vector3.new(0, 1000, 0),
        ["Orientation"] = Vector3.new()
    },
    ["Left Arm"] = {
        ["Position"] = Vector3.new(1.5, 0.55, 0),
        ["Orientation"] = Vector3.new()
    },
    ["Right Arm"] = {
        ["Position"] = Vector3.new(-1.5, -1.25, 0),
        ["Orientation"] = Vector3.new()
    },
    ["Left Leg"] = {
        ["Position"] = Vector3.new(0, -0.5, 0),
        ["Orientation"] = Vector3.new(0, 0, 90)
    },
    ["Right Leg"] = {
        ["Position"] = Vector3.new(0, -0.5, 0),
        ["Orientation"] = Vector3.new(0, 0, 90)
    },
}
-- // MAIN
for _, object in ipairs(Character:GetChildren()) do
    if object:IsA("BasePart") then
        object.Joint.Position = HatsProp[object.Name].Position
        object.Joint.Orientation = HatsProp[object.Name].Orientation
    end
end