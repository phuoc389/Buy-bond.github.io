     local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

_G.ESPPlayerEnabled = true
local UseTeamColor = true
local FriendColor = Color3.fromRGB(0, 255, 255)
local EnemyColor = Color3.fromRGB(255, 0, 0)

-- 🔘 Toggle GUI (gắn vào TabPlayer trong Rayfield GUI)
Callback = function(Value)
	_G.ESPPlayerEnabled = Value
	warn("ESP Player: " .. (Value and "ON ✅" or "OFF ❌"))

	-- Khi TẮT thì xóa Highlight còn lại
	if not Value then
		for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
			if plr.Character and plr.Character:FindFirstChild("Highlight") then
				plr.Character.Highlight:Destroy()
			end
		end
	end
end
		_G.ESPPlayerEnabled = Value
		warn("ESP Player: " .. (Value and "ON ✅" or "OFF ❌"))
	end,
})

-- ⚙️ Hàm vẽ ESP cho từng player
local function ApplyESP(player)
	if player == LocalPlayer then return end

	-- Highlight
	local function CreateHighlight(char)
		if char:FindFirstChild("Highlight") then return end
		local hl = Instance.new("Highlight", char)
		hl.Name = "Highlight"
		hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		hl.FillTransparency = 0.5
		hl.OutlineTransparency = 0
		hl.Adornee = char

		if UseTeamColor and player.Team ~= nil then
			hl.FillColor = player.TeamColor.Color
		else
			hl.FillColor = EnemyColor
		end
	end

	-- Drawing
	local box = Drawing.new("Square")
	box.Thickness = 1
	box.Filled = false
	box.Color = Color3.fromRGB(255,255,255)

	local nameText = Drawing.new("Text")
	nameText.Size = 13
	nameText.Center = true
	nameText.Outline = true
	nameText.Color = Color3.fromRGB(255,255,255)

	local distanceText = Drawing.new("Text")
	distanceText.Size = 12
	distanceText.Center = true
	distanceText.Outline = true
	distanceText.Color = Color3.fromRGB(0,255,255)

	local healthBar = Drawing.new("Square")
	healthBar.Filled = true
	healthBar.Color = Color3.fromRGB(0,255,0)

	local healthText = Drawing.new("Text")
	healthText.Size = 12
	healthText.Center = true
	healthText.Outline = true
	healthText.Color = Color3.fromRGB(0,255,0)

	RunService.RenderStepped:Connect(function()
		if not _G.ESPPlayerEnabled then
			box.Visible = false
			nameText.Visible = false
			distanceText.Visible = false
			healthBar.Visible = false
			healthText.Visible = false
			return
		end

		if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not player.Character:FindFirstChild("Humanoid") then
			box.Visible = false
			nameText.Visible = false
			distanceText.Visible = false
			healthBar.Visible = false
			healthText.Visible = false
			return
		end

		CreateHighlight(player.Character)

		local hrp = player.Character:FindFirstChild("HumanoidRootPart")
		local hum = player.Character:FindFirstChild("Humanoid")
		local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

		if onScreen then
			local size = (Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 2.6, 0)).Y) / 2
			local boxSize = Vector2.new(math.floor(size * 1.5), math.floor(size * 2.5))
			local boxPos = Vector2.new(math.floor(pos.X - boxSize.X / 2), math.floor(pos.Y - boxSize.Y / 2))

			box.Size = boxSize
			box.Position = boxPos
			box.Visible = true

			nameText.Text = player.Name
			nameText.Position = Vector2.new(pos.X, boxPos.Y - 14)
			nameText.Visible = true

			local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)
			distanceText.Text = dist .. " studs"
			distanceText.Position = Vector2.new(pos.X, boxPos.Y + boxSize.Y + 2)
			distanceText.Visible = true

			local hp = hum.Health
			local maxhp = hum.MaxHealth
			local percent = math.clamp(hp / maxhp, 0, 1)
			local barH = boxSize.Y * percent

			healthBar.Size = Vector2.new(3, barH)
			healthBar.Position = Vector2.new(boxPos.X - 6, boxPos.Y + (boxSize.Y - barH))
			healthBar.Color = Color3.fromRGB(255 - percent*255, percent*255, 0)
			healthBar.Visible = true

			healthText.Text = math.floor(percent * 100) .. "%"
			healthText.Position = Vector2.new(boxPos.X - 20, boxPos.Y + boxSize.Y / 2)
			healthText.Visible = true
		else
			box.Visible = false
			nameText.Visible = false
			distanceText.Visible = false
			healthBar.Visible = false
			healthText.Visible = false
		end
	end)
end

-- Tạo ESP cho người chơi hiện tại
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(function()
		ApplyESP(player)
	end)
end

-- Tạo ESP cho người chơi mới vào
Players.PlayerAdded:Connect(function(player)
	task.spawn(function()
		ApplyESP(player)
	end)
end)
