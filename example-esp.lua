--[[
    Example code for the external esp. Updated to V1.2, added colors (red, green, blue, yellow, cyan, magenta, white, black, orange, purple, pink, gray)
]]

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local MainFolder = workspace

local camera = workspace.CurrentCamera
local lastWrite = 0

local function isFriendly(model)
    local plr = Players:GetPlayerFromCharacter(model)
    if plr.Team == localPlayer.Team then
        return "default"
    else
        return "red"
    end
end

RunService.Heartbeat:Connect(function()
    local now = tick()
    if now - lastWrite < 0.016 then return end
    lastWrite = now

    local data = {}

    local localModel = localPlayer.Character
    if not localModel then return end

    local localRoot = localModel:FindFirstChild("HumanoidRootPart")
    if not localRoot then return end

    for _, model in pairs(MainFolder:GetChildren()) do
        if model.Name ~= localPlayer.Name then
            local root = model:FindFirstChild("HumanoidRootPart")
            if root then
                local humanoid = model:FindFirstChildOfClass("Humanoid")
                if not humanoid then continue end

                local pos = root.Position
                local dist = (pos - camera.CFrame.Position).Magnitude
                local friendly = isFriendly(model)

                local R6_bones = {
                    head = "Head",
                    root = "HumanoidRootPart",
                    leftarm = "Left Arm",
                    rightarm = "Right Arm",
                    lefthand = "Left Arm",
                    righthand = "Right Arm",
                    leftleg = "Left Leg",
                    rightleg = "Right Leg",
                    leftfoot = "Left Leg",
                    rightfoot = "Right Leg"
                }

                local R15_bones = {
                    head = "Head",
                    root = "HumanoidRootPart",
                    leftarm = "LeftUpperArm",
                    rightarm = "RightUpperArm",
                    lefthand = "LeftHand",
                    righthand = "RightHand",
                    leftleg = "LeftUpperLeg",
                    rightleg = "RightUpperLeg",
                    leftfoot = "LeftFoot",
                    rightfoot = "RightFoot"
                }

                local rigMap = humanoid.RigType == Enum.HumanoidRigType.R15 and R15_bones or R6_bones

                local boneData = {}
                for boneName, partName in pairs(rigMap) do
                    local bone = model:FindFirstChild(partName)
                    if bone then
                        local screenPos, onScreen = camera:WorldToViewportPoint(bone.Position)
                        if onScreen then
                            boneData[boneName] = { x = screenPos.X, y = screenPos.Y, z = screenPos.Z }
                        end
                    end
                end

                if next(boneData) then
                    table.insert(data, {
                        name = model.Name,
                        bones = boneData,
                        distance = dist,
                        team = friendly or "green",
                        health = humanoid.Health,
						maxHealth = humanoid.MaxHealth
                    })
                end
            end
        end
    end

    pcall(function()
        request({
            Url = "http://127.0.0.1:5000/update",
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(data)
        })
    end)
end)
