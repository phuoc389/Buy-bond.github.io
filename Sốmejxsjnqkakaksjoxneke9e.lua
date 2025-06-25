        --esp npc
        local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Tạo Toggle ESP NPC
local Toggle = TabPlayer:CreateToggle({
	Name = "ESP NPC",
	CurrentValue = false,
	Flag = "Toggle_ESPNPC",
	Callback = function(Value)
		_G.ESPNPCEnabled = Value

		local NPCColor = Color3.fromRGB(255, 200, 0)

		local function ApplyESPNPC(npc)
			if not npc:IsA("Model") or Players:GetPlayerFromCharacter(npc) then return end
			if not npc:FindFirstChild("Humanoid") or not npc:FindFirstChild("HumanoidRootPart") then return end

			local box = Drawing.new("Square")
			box.Thickness = 1
			box.Filled = false
			box.Color = NPCColor

			local nameText = Drawing.new("Text")
			nameText.Size = 13
			nameText.Center = true
			nameText.Outline = true
			nameText.Color = NPCColor
			nameText.Text = npc.Name

			local healthBar = Drawing.new("Square")
			healthBar.Filled = true
			healthBar.Color = Color3.fromRGB(0,255,0)

			local healthText = Drawing.new("Text")
			healthText.Size = 12
			healthText.Center = true
			healthText.Outline = true
			healthText.Color = Color3.fromRGB(0,255,0)

			RunService.RenderStepped:Connect(function()
				if not _G.ESPNPCEnabled or not npc or not npc.Parent or not npc:FindFirstChild("HumanoidRootPart") then
					box.Visible = false
					nameText.Visible = false
					healthBar.Visible = false
					healthText.Visible = false
					return
				end

				local hrp = npc.HumanoidRootPart
				local hum = npc.Humanoid
				local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

				if onScreen then
					local size = (Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 2.6, 0)).Y) / 2
					local boxSize = Vector2.new(math.floor(size * 1.5), math.floor(size * 2.5))
					local boxPos = Vector2.new(math.floor(pos.X - boxSize.X / 2), math.floor(pos.Y - boxSize.Y / 2))

					box.Size = boxSize
					box.Position = boxPos
					box.Visible = true

					nameText.Position = Vector2.new(pos.X, boxPos.Y - 14)
					nameText.Visible = true

					local hp = hum.Health
					local maxhp = hum.MaxHealth
					local percent = math.clamp(hp / maxhp, 0, 1)
					local barH = boxSize.Y * percent

					healthBar.Size = Vector2.new(3, barH)
					healthBar.Position = Vector2.new(boxPos.X - 6, boxPos.Y + (boxSize.Y - barH))
					healthBar.Color = Color3.fromRGB(255 - percent * 255, percent * 255, 0)
					healthBar.Visible = true

					healthText.Text = math.floor(percent * 100) .. "%"
					healthText.Position = Vector2.new(boxPos.X - 20, boxPos.Y + boxSize.Y / 2)
					healthText.Visible = true
				else
					box.Visible = false
					nameText.Visible = false
					healthBar.Visible = false
					healthText.Visible = false
				end
			end)
		end

		if Value then
			for _, model in ipairs(workspace:GetDescendants()) do
				if model:IsA("Model") and model:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(model) then
					task.spawn(function()
						ApplyESPNPC(model)
					end)
				end
			end

			workspace.DescendantAdded:Connect(function(obj)
				if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(obj) then
					task.spawn(function()
						ApplyESPNPC(obj)
					end)
				end
				if obj:IsA("HumanoidRootPart") and obj.Parent:IsA("Model") then
					local model = obj.Parent
					if model:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(model) then
						task.spawn(function()
							ApplyESPNPC(model)
						end)
					end
				end
			end)
		end
	end,
})
