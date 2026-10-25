--//=============================================================
--//  CHILLI HUB  •  Player Settings / ESP / Steal   (v10 + V3)
--//=============================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

local Theme = {
	Bg = Color3.fromRGB(13,14,19), Panel = Color3.fromRGB(18,20,27),
	Row = Color3.fromRGB(26,29,38), RowHover = Color3.fromRGB(34,38,50),
	Stroke = Color3.fromRGB(48,53,68), Text = Color3.fromRGB(238,241,250),
	Sub = Color3.fromRGB(136,143,165),
	AccentA = Color3.fromRGB(255,62,62), AccentB = Color3.fromRGB(255,145,40),
	Red = Color3.fromRGB(255,70,70), Green = Color3.fromRGB(90, 220, 130),
	Blue = Color3.fromRGB(90, 160, 255),
}

local CONFIG = {
	FakeEgg = {ScanInterval = 1.0, MinStableTicks = 3, MinSettleTime = 3.0},
	Noclip  = {TeleportBlockDist = 12, TeleportRevert = 10},
	SpeedBoost = {BaseSpeed = 16, MaxSpeed = 100},
	Mini = {W = 240, H = 36},
	EggESP = {Folder = "NestEggs", ScanInterval = 1.5},
	Carry  = {Name = "carried", ScanInterval = 0.3},
}

local function new(class, props, parent)
	local inst = Instance.new(class)
	for k, v in next, props or {} do inst[k] = v end
	if parent then inst.Parent = parent end
	return inst
end
local function playTw(obj, time, props, style, dir)
	local t = TweenService:Create(obj,
		TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
		props)
	t:Play()
	return t
end
local function clickSound() end

local function isPrivateServerActive()
	return #Players:GetPlayers() <= 1
end

for _, v in ipairs(PG:GetChildren()) do
	if v.Name == "ChilliHub" or v.Name == "ChilliESP" or v.Name == "ChilliToast" then v:Destroy() end
end
for _, v in ipairs(PG:GetChildren()) do
	if v:IsA("Highlight") and (v.Name == "ChilliESPHighlight"
		or v.Name == "ChilliEggESPHighlight"
		or v.Name == "ChilliCollectHighlight") then v:Destroy() end
end

--//=================== TOAST ================================
local toastGui = new("ScreenGui", {
	Name = "ChilliToast", ResetOnSpawn = false, IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 10000,
}, PG)
local toastHolder = new("Frame", {
	Size = UDim2.fromOffset(340, 0),
	Position = UDim2.new(0.5, -170, 0, 18),
	BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y,
	ClipsDescendants = false,
}, toastGui)
new("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, toastHolder)

local toastOrder = 0
local function showToast(title, message, accentColor)
	accentColor = accentColor or Theme.Red
	toastOrder = toastOrder + 1
	local item = new("CanvasGroup", {
		Size = UDim2.new(1, 0, 0, 74), BackgroundColor3 = Theme.Bg,
		BorderSizePixel = 0, LayoutOrder = toastOrder, GroupTransparency = 1,
	}, toastHolder)
	new("UICorner", {CornerRadius = UDim.new(0, 12)}, item)
	new("UIStroke", {Color = accentColor, Thickness = 1.5, Transparency = 0.2}, item)

	local strip = new("Frame", {
		Size = UDim2.new(0, 4, 1, -16), Position = UDim2.new(0, 0, 0, 8),
		BackgroundColor3 = accentColor, BorderSizePixel = 0,
	}, item)
	new("UICorner", {CornerRadius = UDim.new(1, 0)}, strip)

	local iconBg = new("Frame", {
		Size = UDim2.fromOffset(34, 34), Position = UDim2.fromOffset(16, 20),
		BackgroundColor3 = accentColor, BorderSizePixel = 0,
	}, item)
	new("UICorner", {CornerRadius = UDim.new(0, 8)}, iconBg)
	new("UIGradient", {Color = ColorSequence.new(Theme.AccentA, Theme.AccentB)}, iconBg)
	new("TextLabel", {
		Text = "!", Font = Enum.Font.GothamBlack, TextSize = 18,
		TextColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
	}, iconBg)

	new("TextLabel", {
		Text = title, Font = Enum.Font.GothamBold, TextSize = 13,
		TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1, Position = UDim2.fromOffset(60, 14),
		Size = UDim2.new(1, -76, 0, 16),
	}, item)
	new("TextLabel", {
		Text = message, Font = Enum.Font.Gotham, TextSize = 11,
		TextColor3 = Theme.Sub, TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true, BackgroundTransparency = 1,
		Position = UDim2.fromOffset(60, 32), Size = UDim2.new(1, -76, 0, 34),
	}, item)

	local barBg = new("Frame", {
		Size = UDim2.new(1, -24, 0, 3), Position = UDim2.new(0, 12, 1, -8),
		BackgroundColor3 = Color3.fromRGB(38, 41, 52), BorderSizePixel = 0,
	}, item)
	new("UICorner", {CornerRadius = UDim.new(1, 0)}, barBg)
	local barFill = new("Frame", {
		Size = UDim2.fromScale(1, 1), BackgroundColor3 = accentColor, BorderSizePixel = 0,
	}, barBg)
	new("UICorner", {CornerRadius = UDim.new(1, 0)}, barFill)

	playTw(item, 0.25, {GroupTransparency = 0}, Enum.EasingStyle.Quart)
	task.delay(0.1, function()
		if barFill.Parent then playTw(barFill, 3.1, {Size = UDim2.fromScale(0, 1)}, Enum.EasingStyle.Linear) end
	end)
	task.delay(3.2, function()
		if not item.Parent then return end
		local t = playTw(item, 0.32, {GroupTransparency = 1}, Enum.EasingStyle.Quart)
		t.Completed:Once(function() if item.Parent then item:Destroy() end end)
	end)
	return item
end

--//==================== SWITCH ==============================
local function createSwitch(parent, w, h)
	w, h = w or 46, h or 24
	local ks = h - 6
	local track = new("Frame", {Size = UDim2.fromOffset(w, h), BackgroundColor3 = Color3.fromRGB(38,41,52), BorderSizePixel = 0}, parent)
	new("UICorner", {CornerRadius = UDim.new(1, 0)}, track)
	local stroke = new("UIStroke", {Color = Theme.Stroke, Thickness = 1, Transparency = 0.35}, track)
	local fill = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0}, track)
	new("UICorner", {CornerRadius = UDim.new(1, 0)}, fill)
	new("UIGradient", {Color = ColorSequence.new(Theme.AccentA, Theme.AccentB)}, fill)
	local knob = new("Frame", {Size = UDim2.fromOffset(ks, ks), Position = UDim2.new(0, 3, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = Color3.fromRGB(140,146,162), BorderSizePixel = 0}, track)
	new("UICorner", {CornerRadius = UDim.new(1, 0)}, knob)

	local sw = {value = false, track = track, stroke = stroke, fill = fill, knob = knob}
	function sw:Set(v, animate)
		self.value = v and true or false
		local dur = (animate == false) and 0 or 0.25
		playTw(knob, dur, {
			Position = self.value and UDim2.new(1, -(ks + 3), 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
			BackgroundColor3 = self.value and Color3.new(1,1,1) or Color3.fromRGB(140,146,162),
		}, Enum.EasingStyle.Back)
		playTw(fill, dur, {BackgroundTransparency = self.value and 0 or 1})
		playTw(stroke, dur, {
			Color = self.value and Theme.AccentA or Theme.Stroke,
			Transparency = self.value and 0.15 or 0.35,
		})
	end
	function sw:SetDisabled(v)
		track.BackgroundTransparency = v and 0.55 or 0
		track.BackgroundColor3 = v and Color3.fromRGB(25, 27, 34) or Color3.fromRGB(38, 41, 52)
	end
	return sw
end

--//================= TOGGLE ROW =============================
local function createToggleRow(parent, opts)
	opts = opts or {}
	local wrap = new("Frame", {Size = UDim2.new(1, 0, 0, 50), BackgroundTransparency = 1, ClipsDescendants = true}, parent)
	local body = new("Frame", {Size = UDim2.new(1, 0, 0, 42), BackgroundColor3 = Theme.Row, BorderSizePixel = 0}, wrap)
	new("UICorner", {CornerRadius = UDim.new(0, 9)}, body)
	local stroke = new("UIStroke", {Color = Theme.Stroke, Thickness = 1, Transparency = 0.45}, body)

	local hasSub = opts.SubText ~= nil
	local titleLbl = new("TextLabel", {
		Text = opts.Text or "Toggle", Font = Enum.Font.GothamMedium, TextSize = 14,
		TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1,
		Position = UDim2.fromOffset(14, hasSub and 5 or 0),
		Size = UDim2.new(1, -90, 0, hasSub and 18 or 42),
	}, body)
	local subLbl
	if hasSub then
		subLbl = new("TextLabel", {
			Text = opts.SubText, Font = Enum.Font.Gotham, TextSize = 11,
			TextColor3 = Theme.Sub, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1,
			Position = UDim2.fromOffset(14, 22), Size = UDim2.new(1, -90, 0, 15),
			TextTruncate = Enum.TextTruncate.AtEnd,
		}, body)
	end

	local switch = createSwitch(body)
	switch.track.AnchorPoint = Vector2.new(1, 0.5)
	switch.track.Position = UDim2.new(1, -12, 0.5, 0)

	local btn = new("TextButton", {Text = "", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1)}, body)
	local row = {
		value = false, wrap = wrap, body = body, switch = switch,
		titleLbl = titleLbl, subLbl = subLbl,
		onChange = nil, locked = false, lockedReason = nil,
	}
	local hideToken = 0

	function row:Set(v, silent)
		self.value = v and true or false
		switch:Set(self.value)
		if not silent and self.onChange then self.onChange(self.value) end
	end
	function row:SetLocked(locked, reason)
		self.locked = locked and true or false
		self.lockedReason = reason
		if self.locked then
			titleLbl.TextColor3 = Color3.fromRGB(105, 110, 125)
			if subLbl then subLbl.TextColor3 = Color3.fromRGB(80, 85, 100) end
			body.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
			switch:SetDisabled(true)
		else
			titleLbl.TextColor3 = Theme.Text
			if subLbl then subLbl.TextColor3 = Theme.Sub end
			body.BackgroundColor3 = Theme.Row
			switch:SetDisabled(false)
		end
	end
	function row:Show()
		hideToken = hideToken + 1
		wrap.Visible = true
		playTw(wrap, 0.3, {Size = UDim2.new(1, 0, 0, 50)}, Enum.EasingStyle.Quart)
	end
	function row:Hide()
		hideToken = hideToken + 1
		local token = hideToken
		local t = playTw(wrap, 0.25, {Size = UDim2.new(1, 0, 0, 0)}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
		t.Completed:Once(function() if token == hideToken then wrap.Visible = false end end)
	end

	btn.MouseButton1Click:Connect(function()
		if row.locked then
			showToast("Locked", row.lockedReason or "This feature is unavailable", Theme.Red)
			return
		end
		row:Set(not row.value); clickSound()
	end)
	body.MouseEnter:Connect(function()
		if row.locked then return end
		playTw(body, 0.15, {BackgroundColor3 = Theme.RowHover})
		playTw(stroke, 0.15, {Transparency = 0.15})
	end)
	body.MouseLeave:Connect(function()
		if row.locked then return end
		playTw(body, 0.2, {BackgroundColor3 = Theme.Row})
		playTw(stroke, 0.2, {Transparency = 0.45})
	end)
	return row
end

--//=================== ACTION BUTTON =========================
local function createActionButton(parent, opts)
	opts = opts or {}
	local wrap = new("Frame", {Size = UDim2.new(1, 0, 0, 50), BackgroundTransparency = 1}, parent)
	local body = new("Frame", {Size = UDim2.new(1, 0, 0, 42), BackgroundColor3 = Theme.Row, BorderSizePixel = 0}, wrap)
	new("UICorner", {CornerRadius = UDim.new(0, 9)}, body)
	local stroke = new("UIStroke", {Color = Theme.Stroke, Thickness = 1, Transparency = 0.45}, body)

	local hasSub = opts.SubText ~= nil
	new("TextLabel", {
		Text = opts.Text or "Action", Font = Enum.Font.GothamMedium, TextSize = 14,
		TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1,
		Position = UDim2.fromOffset(14, hasSub and 5 or 0),
		Size = UDim2.new(1, -90, 0, hasSub and 18 or 42),
	}, body)
	if hasSub then
		new("TextLabel", {
			Text = opts.SubText, Font = Enum.Font.Gotham, TextSize = 11,
			TextColor3 = Theme.Sub, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1,
			Position = UDim2.fromOffset(14, 22), Size = UDim2.new(1, -90, 0, 15),
		}, body)
	end

	local statusLbl = new("TextLabel", {
		Text = opts.Status or "SCAN", Font = Enum.Font.GothamBlack, TextSize = 12,
		TextColor3 = Theme.Blue, BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0),
		Size = UDim2.new(0, 70, 0, 22), TextXAlignment = Enum.TextXAlignment.Right,
	}, body)

	local btn = new("TextButton", {Text = "", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1)}, body)
	local row = {wrap = wrap, body = body, statusLbl = statusLbl, enabled = true, onClick = opts.onClick}

	function row:SetEnabled(v, keepStatus)
		self.enabled = v and true or false
		if not keepStatus then
			self.statusLbl.Text = v and (opts.Status or "SCAN") or "LOCKED"
			self.statusLbl.TextColor3 = v and Theme.Blue or Theme.Sub
		end
		btn.Active = self.enabled
	end
	function row:SetStatus(txt, color)
		self.statusLbl.Text = txt
		self.statusLbl.TextColor3 = color or Theme.Blue
	end
	function row:Show()
		wrap.Visible = true
		playTw(wrap, 0.3, {Size = UDim2.new(1, 0, 0, 50)}, Enum.EasingStyle.Quart)
	end

	btn.MouseButton1Click:Connect(function()
		if not row.enabled then return end
		if row.onClick then row.onClick() end
		clickSound()
	end)
	body.MouseEnter:Connect(function()
		if row.enabled then
			playTw(body, 0.15, {BackgroundColor3 = Theme.RowHover})
			playTw(stroke, 0.15, {Transparency = 0.15})
		end
	end)
	body.MouseLeave:Connect(function()
		playTw(body, 0.2, {BackgroundColor3 = Theme.Row})
		playTw(stroke, 0.2, {Transparency = 0.45})
	end)
	return row
end

--//================== SLIDER ROW ============================
local function createSliderRow(parent, min, max, initial, callback)
	local wrap = new("Frame", {Size = UDim2.new(1, 0, 0, 64), BackgroundTransparency = 1}, parent)
	local body = new("Frame", {Size = UDim2.new(1, 0, 0, 56), BackgroundColor3 = Theme.Row, BorderSizePixel = 0}, wrap)
	new("UICorner", {CornerRadius = UDim.new(0, 9)}, body)
	new("UIStroke", {Color = Theme.Stroke, Thickness = 1, Transparency = 0.45}, body)

	new("TextLabel", {
		Text = "Speed Level", Font = Enum.Font.GothamMedium, TextSize = 13,
		TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 6),
		Size = UDim2.new(1, -80, 0, 18),
	}, body)

	local valueLabel = new("TextLabel", {
		Text = tostring(initial), Font = Enum.Font.GothamBold, TextSize = 13,
		TextColor3 = Theme.AccentB, TextXAlignment = Enum.TextXAlignment.Right,
		BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -14, 6), Size = UDim2.new(0, 44, 0, 18),
	}, body)

	local trackBg = new("Frame", {
		Size = UDim2.new(1, -28, 0, 6), Position = UDim2.fromOffset(14, 38),
		BackgroundColor3 = Color3.fromRGB(38, 41, 52), BorderSizePixel = 0,
	}, body)
	new("UICorner", {CornerRadius = UDim.new(1, 0)}, trackBg)

	local fill = new("Frame", {
		Size = UDim2.fromScale((initial - min) / (max - min), 1),
		BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
	}, trackBg)
	new("UICorner", {CornerRadius = UDim.new(1, 0)}, fill)
	new("UIGradient", {Color = ColorSequence.new(Theme.AccentA, Theme.AccentB)}, fill)

	local knob = new("Frame", {
		Size = UDim2.fromOffset(14, 14), AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new((initial - min) / (max - min), 0, 0.5, 0),
		BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 2,
	}, trackBg)
	new("UICorner", {CornerRadius = UDim.new(1, 0)}, knob)
	new("UIStroke", {Color = Theme.AccentA, Thickness = 2}, knob)

	local hitArea = new("TextButton", {
		Text = "", BackgroundTransparency = 1,
		Size = UDim2.new(1, 20, 0, 26),
		AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, -10, 0.5, 0),
	}, trackBg)

	local slider = {value = initial, min = min, max = max, wrap = wrap, body = body, onChange = callback}
	local dragging = false

	local function setFromX(x)
		local absX = trackBg.AbsolutePosition.X
		local w = trackBg.AbsoluteSize.X
		if w <= 0 then return end
		local rel = math.clamp((x - absX) / w, 0, 1)
		local v = math.floor(min + rel * (max - min) + 0.5)
		slider.value = v
		fill.Size = UDim2.fromScale(rel, 1)
		knob.Position = UDim2.new(rel, 0, 0.5, 0)
		valueLabel.Text = tostring(v)
		if slider.onChange then slider.onChange(v) end
	end

	hitArea.MouseButton1Down:Connect(function(x) dragging = true; setFromX(x) end)
	UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then
			setFromX(input.Position.X)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
	end)

	function slider:Show()
		wrap.Visible = true
		wrap.Size = UDim2.new(1, 0, 0, 0)
		playTw(wrap, 0.3, {Size = UDim2.new(1, 0, 0, 64)}, Enum.EasingStyle.Quart)
	end
	function slider:Hide()
		local t = playTw(wrap, 0.25, {Size = UDim2.new(1, 0, 0, 0)}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
		t.Completed:Once(function() wrap.Visible = false end)
	end
	return slider
end

--//=================== BUILD GUI ============================
local gui = new("ScreenGui", {
	Name = "ChilliHub", ResetOnSpawn = false, IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 9999,
}, PG)

local FULL_W, FULL_H = 500, 340
local MINI_W, MINI_H = CONFIG.Mini.W, CONFIG.Mini.H

local main = new("Frame", {
	Name = "Main", Size = UDim2.fromOffset(FULL_W, FULL_H),
	Position = UDim2.new(0.5, -FULL_W/2, 0.5, -FULL_H/2),
	BackgroundColor3 = Theme.Bg, BorderSizePixel = 0,
}, gui)
new("UICorner", {CornerRadius = UDim.new(0, 14)}, main)
local mainStroke = new("UIStroke", {Thickness = 1.6, Transparency = 0.55}, main)
new("UIGradient", {Color = ColorSequence.new(Theme.AccentA, Theme.AccentB)}, mainStroke)

local accentLine = new("Frame", {Size = UDim2.new(1, -28, 0, 2), Position = UDim2.fromOffset(14, 1),
	BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0, ZIndex = 2}, main)
new("UICorner", {CornerRadius = UDim.new(1, 0)}, accentLine)
local accentGrad = new("UIGradient", {Color = ColorSequence.new(Theme.AccentA, Theme.AccentB)}, accentLine)

local topBar = new("Frame", {Size = UDim2.new(1, 0, 0, 52), BackgroundTransparency = 1}, main)
local title = new("TextLabel", {
	Text = "CHILLI HUB", Font = Enum.Font.GothamBlack, TextSize = 21,
	TextColor3 = Color3.new(1,1,1), TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1,
	Position = UDim2.fromOffset(20, 8), Size = UDim2.new(0, 220, 0, 24),
}, topBar)
local titleGrad = new("UIGradient", {Color = ColorSequence.new(Theme.AccentA, Theme.AccentB)}, title)

local subtitle = new("TextLabel", {
	Text = "player settings  •  esp  •  steal", Font = Enum.Font.Gotham, TextSize = 11,
	TextColor3 = Theme.Sub, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1,
	Position = UDim2.fromOffset(21, 31), Size = UDim2.new(0, 220, 0, 14),
}, topBar)

local powerBox = new("Frame", {Size = UDim2.fromOffset(96, 26), AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -70, 0.5, 0), BackgroundTransparency = 1}, topBar)
local powerLabel = new("TextLabel", {
	Text = "POWER", Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = Theme.Sub,
	TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Size = UDim2.new(0, 44, 1, 0),
}, powerBox)
local powerSwitch = createSwitch(powerBox, 46, 24)
powerSwitch.track.AnchorPoint = Vector2.new(1, 0.5)
powerSwitch.track.Position = UDim2.new(1, 0, 0.5, 0)

local minimizeBtn = new("TextButton", {
	Text = "-", Font = Enum.Font.GothamBold, TextSize = 18, TextColor3 = Theme.Sub,
	BackgroundColor3 = Theme.Row, AutoButtonColor = false,
	AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -42, 0.5, 0),
	Size = UDim2.fromOffset(22, 22), BorderSizePixel = 0,
}, topBar)
new("UICorner", {CornerRadius = UDim.new(0, 6)}, minimizeBtn)

local closeBtn = new("TextButton", {
	Text = "X", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Theme.Sub,
	BackgroundColor3 = Theme.Row, AutoButtonColor = false,
	AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0),
	Size = UDim2.fromOffset(22, 22), BorderSizePixel = 0,
}, topBar)
new("UICorner", {CornerRadius = UDim.new(0, 6)}, closeBtn)

closeBtn.MouseEnter:Connect(function() playTw(closeBtn, 0.15, {BackgroundColor3 = Theme.AccentA, TextColor3 = Color3.new(1,1,1)}) end)
closeBtn.MouseLeave:Connect(function() playTw(closeBtn, 0.15, {BackgroundColor3 = Theme.Row, TextColor3 = Theme.Sub}) end)
minimizeBtn.MouseEnter:Connect(function() playTw(minimizeBtn, 0.15, {BackgroundColor3 = Theme.RowHover, TextColor3 = Theme.Text}) end)
minimizeBtn.MouseLeave:Connect(function() playTw(minimizeBtn, 0.15, {BackgroundColor3 = Theme.Row, TextColor3 = Theme.Sub}) end)

local tabBar = new("Frame", {Size = UDim2.new(1, 0, 0, 42), Position = UDim2.fromOffset(0, 52), BackgroundTransparency = 1}, main)
local TABS = {"Player Settings", "ESP", "Steal"}
local TAB_W, TAB_GAP, TAB_PAD = 118, 6, 14
local tabButtons, pages = {}, {}

local indicator = new("Frame", {Size = UDim2.fromOffset(TAB_W, 2), Position = UDim2.fromOffset(TAB_PAD, 36),
	BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0}, tabBar)
new("UICorner", {CornerRadius = UDim.new(1, 0)}, indicator)
new("UIGradient", {Color = ColorSequence.new(Theme.AccentA, Theme.AccentB)}, indicator)

local content = new("Frame", {Size = UDim2.new(1, -24, 1, -106), Position = UDim2.fromOffset(12, 94),
	BackgroundColor3 = Theme.Panel, BorderSizePixel = 0, ClipsDescendants = true}, main)
new("UICorner", {CornerRadius = UDim.new(0, 10)}, content)
new("UIStroke", {Color = Theme.Stroke, Thickness = 1, Transparency = 0.5}, content)

local function createPage()
	local page = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false}, content)
	new("UIListLayout", {Padding = UDim.new(0, 0), SortOrder = Enum.SortOrder.LayoutOrder}, page)
	new("UIPadding", {PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)}, page)
	return page
end
local settingsPage = createPage()
local espPage      = createPage()
local stealPage    = createPage()

local stealScroll = new("ScrollingFrame", {
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1, BorderSizePixel = 0,
	ScrollBarThickness = 4, ScrollBarImageColor3 = Theme.AccentA,
	CanvasSize = UDim2.new(0, 0, 0, 0),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, stealPage)
new("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, stealScroll)

local currentTab = 0
local function selectTab(i)
	if currentTab == i then return end
	currentTab = i
	for j, btn in ipairs(tabButtons) do
		playTw(btn, 0.18, {TextColor3 = (j == i) and Theme.Text or Theme.Sub})
	end
	playTw(indicator, 0.25, {Position = UDim2.fromOffset(TAB_PAD + (i - 1) * (TAB_W + TAB_GAP), 36)}, Enum.EasingStyle.Quart)
	for j, page in ipairs(pages) do
		if j == i then
			page.Visible = true
			page.Position = UDim2.fromOffset(14, 0)
			playTw(page, 0.22, {Position = UDim2.fromOffset(0, 0)}, Enum.EasingStyle.Quart)
		else page.Visible = false end
	end
end
for i, name in ipairs(TABS) do
	local btn = new("TextButton", {
		Text = name, Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Theme.Sub,
		BackgroundTransparency = 1, AutoButtonColor = false,
		Position = UDim2.fromOffset(TAB_PAD + (i - 1) * (TAB_W + TAB_GAP), 4),
		Size = UDim2.fromOffset(TAB_W, 28),
	}, tabBar)
	btn.MouseEnter:Connect(function() if currentTab ~= i then playTw(btn, 0.15, {TextColor3 = Theme.Text}) end end)
	btn.MouseLeave:Connect(function() if currentTab ~= i then playTw(btn, 0.15, {TextColor3 = Theme.Sub}) end end)
	btn.MouseButton1Click:Connect(function() selectTab(i); clickSound() end)
	tabButtons[i] = btn
	pages[i] = (i == 1) and settingsPage or (i == 2) and espPage or stealPage
end

local overlay = new("TextButton", {Text = "", AutoButtonColor = false, BackgroundColor3 = Theme.Bg,
	BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Visible = false, ZIndex = 50}, content)
new("UICorner", {CornerRadius = UDim.new(0, 10)}, overlay)

-- Player Settings rows
local noclipRow = createToggleRow(settingsPage, {Text = "Noclip", SubText = "Walk through walls and objects"})
local speedBoostRow = createToggleRow(settingsPage, {Text = "Speed Boost", SubText = "Boosts player movement speed"})
local speedSlider = createSliderRow(settingsPage, 0, 100, 50, function() end)
speedSlider.wrap.Size = UDim2.new(1, 0, 0, 0)
speedSlider.wrap.Visible = false

-- ESP rows
local espRow = createToggleRow(espPage, {Text = "Player ESP", SubText = "Highlight every player through walls"})
local fakeRow = createToggleRow(espPage, {
	Text = "Fake Egg Identifier",
	SubText = "Flag players whose outfit no longer matches what they spawned with",
})
fakeRow.wrap.Size = UDim2.new(1, 0, 0, 0)
fakeRow.wrap.Visible = false

-- Steal page (no beta text)
local promptRow = createToggleRow(stealScroll, {
	Text = "Instant Steal", SubText = "Sets every ProximityPrompt hold duration to 0 seconds",
})
promptRow.wrap.LayoutOrder = 1

local eggEspRow = createToggleRow(stealScroll, {
	Text = "Egg ESP (Private Server only)",
	SubText = "Shows the name of every egg in Workspace/NestEggs",
})
eggEspRow.wrap.LayoutOrder = 2

local scanRow = createActionButton(stealScroll, {
	Text = "Scan Spawn", SubText = "Finds the collect part in your spawn model",
	Status = "SCAN", onClick = function() end,
})
scanRow.wrap.LayoutOrder = 3

local collectEspRow = createToggleRow(stealScroll, {
	Text = "ESP Collect Zone", SubText = "Highlights the collect part through walls",
})
collectEspRow.wrap.Size = UDim2.new(1, 0, 0, 0)
collectEspRow.wrap.Visible = false
collectEspRow.wrap.LayoutOrder = 4

local autoTpRow = createToggleRow(stealScroll, {
	Text = "Auto Teleport (Private Server only)",
	SubText = "V3 searcher — detects new child in carried",
})
autoTpRow.wrap.Size = UDim2.new(1, 0, 0, 0)
autoTpRow.wrap.Visible = false
autoTpRow.wrap.LayoutOrder = 5

local state = {
	power = true, noclip = false, esp = false, fake = false,
	speedBoost = false, promptInstant = false, eggEsp = false,
	autoTp = false, collectEsp = false,
}

--//=================== PRIVATE SERVER LOCKS =================
local PRIVATE_MSG = "This feature is Private Server only — join alone to use"
local function updatePrivateServerLocks()
	local priv = isPrivateServerActive()
	eggEspRow:SetLocked(not priv, PRIVATE_MSG)
	autoTpRow:SetLocked(not priv, PRIVATE_MSG)
	if not priv then
		if state.eggEsp then eggEspRow:Set(false) end
		if state.autoTp then autoTpRow:Set(false) end
	end
end
Players.PlayerAdded:Connect(function() task.wait(0.2); updatePrivateServerLocks() end)
Players.PlayerRemoving:Connect(function() task.wait(0.2); updatePrivateServerLocks() end)

--//=================== NOCLIP STATE =========================
local noclip = {
	saved = {}, char = nil, hrp = nil,
	lastCF = nil, lastVel = nil,
	hooked = false, bypassTeleport = false,
}

local function restoreNoclip()
	for part, info in pairs(noclip.saved) do
		if part and part.Parent then
			if info.collide then part.CanCollide = true end
			if info.touch   then part.CanTouch   = true end
		end
	end
	noclip.saved = {}; noclip.char = nil; noclip.hrp = nil
	noclip.lastCF = nil; noclip.lastVel = nil
end

local function ensureTeleportHook()
	if noclip.hooked then return end
	local ok = pcall(function()
		if not hookmetamethod then error("no hookmetamethod") end
		local old
		old = hookmetamethod(game, "__newindex", function(self, key, value)
			if noclip.bypassTeleport then
				return old(self, key, value)
			end
			if state.noclip and state.power and noclip.hrp and self == noclip.hrp then
				if key == "CFrame" or key == "Position" then
					local target
					if typeof(value) == "CFrame" then target = value.Position
					elseif typeof(value) == "Vector3" then target = value end
					if target and (target - noclip.hrp.Position).Magnitude > CONFIG.Noclip.TeleportBlockDist then
						return
					end
				end
			end
			return old(self, key, value)
		end)
	end)
	noclip.hooked = ok
end

--//=================== SPEED BOOST ==========================
local speedBoostValue = 50

local function applySpeedBoost()
	local char = LP.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	local target = CONFIG.SpeedBoost.BaseSpeed
	if state.power and state.speedBoost then
		target = CONFIG.SpeedBoost.BaseSpeed
			+ (speedBoostValue / 100) * (CONFIG.SpeedBoost.MaxSpeed - CONFIG.SpeedBoost.BaseSpeed)
	end
	if math.abs(hum.WalkSpeed - target) > 0.01 then
		hum.WalkSpeed = target
	end
end
RunService.Heartbeat:Connect(applySpeedBoost)
speedSlider.onChange = function(v) speedBoostValue = v; applySpeedBoost() end
LP.CharacterAdded:Connect(function() task.wait(0.5); applySpeedBoost() end)

--//=================== INSTANT STEAL ========================
local promptSaved = {}
local function enablePromptInstant()
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("ProximityPrompt") then
			if promptSaved[obj] == nil then promptSaved[obj] = obj.HoldDuration end
			obj.HoldDuration = 0
		end
	end
end
local function disablePromptInstant()
	for obj, orig in pairs(promptSaved) do
		if obj and obj.Parent then obj.HoldDuration = orig end
	end
	promptSaved = {}
end
workspace.DescendantAdded:Connect(function(obj)
	if state.power and state.promptInstant and obj:IsA("ProximityPrompt") then
		if promptSaved[obj] == nil then promptSaved[obj] = obj.HoldDuration end
		obj.HoldDuration = 0
	end
end)

--//=================== EGG ESP ==============================
local eggData = {}
local function eggNameOf(model)
	local n = model.Name
	if n == "" or n:lower() == "model" or n:lower():match("^model%d*$") then
		for _, c in ipairs(model:GetChildren()) do
			if c:IsA("BasePart") and c.Name ~= "Handle" then return c.Name end
		end
	end
	return n
end
local function createEggBillboard(part, name)
	local bb = new("BillboardGui", {
		Name = "ChilliEggESP", Size = UDim2.fromOffset(180, 26),
		AlwaysOnTop = true, LightInfluence = 0, MaxDistance = 2000,
		ResetOnSpawn = false, StudsOffsetWorldSpace = Vector3.new(0, 2, 0),
		Adornee = part,
	}, PG)
	local lbl = new("TextLabel", {
		Text = name, Font = Enum.Font.GothamBlack, TextSize = 14, TextColor3 = Color3.new(1,1,1),
		TextStrokeTransparency = 0.25, TextStrokeColor3 = Color3.new(0,0,0),
		BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16),
	}, bb)
	new("UIGradient", {Color = ColorSequence.new(Theme.Green, Theme.AccentB)}, lbl)
	new("TextLabel", {
		Text = "EGG", Font = Enum.Font.GothamBold, TextSize = 9, TextColor3 = Theme.Green,
		TextStrokeTransparency = 0.5, TextStrokeColor3 = Color3.new(0,0,0),
		BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 10),
		Position = UDim2.fromOffset(0, 16),
	}, bb)
	local hl = new("Highlight", {
		Name = "ChilliEggESPHighlight", FillColor = Theme.Green, FillTransparency = 0.75,
		OutlineColor = Theme.Green, OutlineTransparency = 0,
		DepthMode = Enum.HighlightDepthMode.AlwaysOnTop, Adornee = part,
	}, PG)
	return {gui = bb, highlight = hl}
end
local function clearEggESP()
	for _, data in pairs(eggData) do
		if data.gui then data.gui:Destroy() end
		if data.highlight then data.highlight:Destroy() end
	end
	eggData = {}
end
local function scanEggs()
	if not isPrivateServerActive() then return end
	local folder = workspace:FindFirstChild(CONFIG.EggESP.Folder)
	if not folder then return end
	for _, model in ipairs(folder:GetChildren()) do
		if model:IsA("Model") then
			local parts = {}
			for _, c in ipairs(model:GetDescendants()) do
				if c:IsA("BasePart") then table.insert(parts, c) end
			end
			if #parts > 0 then
				local anchor = parts[1]
				if not eggData[anchor] then
					eggData[anchor] = createEggBillboard(anchor, eggNameOf(model))
				end
			end
		elseif model:IsA("BasePart") then
			if not eggData[model] then
				eggData[model] = createEggBillboard(model, model.Name)
			end
		end
	end
end
local function refreshEggESP()
	if state.power and state.eggEsp and isPrivateServerActive() then scanEggs()
	else clearEggESP() end
end
task.spawn(function()
	while gui.Parent do
		task.wait(CONFIG.EggESP.ScanInterval)
		if state.power and state.eggEsp and isPrivateServerActive() then scanEggs() end
	end
end)
workspace.DescendantAdded:Connect(function()
	if state.power and state.eggEsp and isPrivateServerActive() then task.defer(scanEggs) end
end)

--//=================== SCAN SPAWN ===========================
local spawnScan = {found = false, collectPart = nil, spawnPart = nil, model = nil, initialPos = nil}

local function captureSpawnPos(char)
	local hrp = char:WaitForChild("HumanoidRootPart", 5)
	if hrp then spawnScan.initialPos = hrp.Position; return end
	local ok, pivot = pcall(function() return char:GetPivot().Position end)
	if ok then spawnScan.initialPos = pivot end
end

local function scanSpawnOnce()
	if not spawnScan.initialPos then
		local char = LP.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hrp then spawnScan.initialPos = hrp.Position end
	end
	local origin = spawnScan.initialPos
	if not origin then return false end

	local candidates = {}
	for _, d in ipairs(workspace:GetDescendants()) do
		if d:IsA("BasePart") and d.Name:lower() == "spawn" then
			table.insert(candidates, d)
		end
	end
	if #candidates == 0 then return false end

	local spawnPart, bestDist = nil, math.huge
	for _, p in ipairs(candidates) do
		local dist = (p.Position - origin).Magnitude
		if dist < bestDist then bestDist = dist; spawnPart = p end
	end
	if not spawnPart then return false end

	local parent = spawnPart.Parent
	if not parent then return false end

	local collectPart
	for _, d in ipairs(parent:GetDescendants()) do
		if d:IsA("BasePart") and d.Name:lower() == "collect" then
			collectPart = d; break
		end
	end
	if not collectPart then
		for _, d in ipairs(parent:GetDescendants()) do
			if d:IsA("BasePart") and d.Name:lower():find("collect") then
				collectPart = d; break
			end
		end
	end
	if not collectPart then return false end

	spawnScan.found = true
	spawnScan.collectPart = collectPart
	spawnScan.spawnPart = spawnPart
	spawnScan.model = parent
	return true
end

--//=================== ESP COLLECT ZONE =====================
local collectEspData = {gui = nil, highlight = nil}

local function destroyCollectESP()
	if collectEspData.gui then collectEspData.gui:Destroy() end
	if collectEspData.highlight then collectEspData.highlight:Destroy() end
	collectEspData.gui = nil
	collectEspData.highlight = nil
end

local function createCollectESP(part)
	destroyCollectESP()
	if not part or not part.Parent then return end

	local bb = new("BillboardGui", {
		Name = "ChilliCollectESP", Size = UDim2.fromOffset(200, 30),
		AlwaysOnTop = true, LightInfluence = 0, MaxDistance = 2000,
		ResetOnSpawn = false, StudsOffsetWorldSpace = Vector3.new(0, 4, 0),
		Adornee = part,
	}, PG)
	local lbl = new("TextLabel", {
		Text = "COLLECT ZONE", Font = Enum.Font.GothamBlack, TextSize = 15,
		TextColor3 = Color3.new(1, 1, 1),
		TextStrokeTransparency = 0.2, TextStrokeColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18),
	}, bb)
	new("UIGradient", {Color = ColorSequence.new(Theme.Blue, Theme.AccentB)}, lbl)
	new("TextLabel", {
		Text = part.Name, Font = Enum.Font.Gotham, TextSize = 10,
		TextColor3 = Theme.Sub, TextStrokeTransparency = 0.6, TextStrokeColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 18),
		Size = UDim2.new(1, 0, 0, 12),
	}, bb)
	local hl = new("Highlight", {
		Name = "ChilliCollectHighlight", FillColor = Theme.Blue, FillTransparency = 0.65,
		OutlineColor = Theme.Blue, OutlineTransparency = 0,
		DepthMode = Enum.HighlightDepthMode.AlwaysOnTop, Adornee = part,
	}, PG)

	collectEspData.gui = bb
	collectEspData.highlight = hl
end

local function refreshCollectESP()
	if state.power and state.collectEsp and spawnScan.found and spawnScan.collectPart then
		if spawnScan.collectPart.Parent then
			if not collectEspData.gui or not collectEspData.gui.Parent
				or collectEspData.gui.Adornee ~= spawnScan.collectPart then
				createCollectESP(spawnScan.collectPart)
			end
		else
			destroyCollectESP()
		end
	else
		destroyCollectESP()
	end
end

scanRow.onClick = function()
	if spawnScan.found then return end
	scanRow:SetStatus("SCANNING", Theme.AccentB)
	scanRow:SetEnabled(false, true)
	task.spawn(function()
		if not spawnScan.initialPos then
			local char = LP.Character
			if char then captureSpawnPos(char) end
		end
		local ok = scanSpawnOnce()
		if ok then
			scanRow:SetEnabled(false)
			scanRow:SetStatus("FOUND", Theme.Green)
			collectEspRow:Show()
			autoTpRow:Show()
			updatePrivateServerLocks()
			showToast("Scan Spawn", "Collect zone found: " .. spawnScan.collectPart.Name, Theme.Green)
			refreshCollectESP()
		else
			scanRow:SetStatus("SCAN", Theme.Blue)
			scanRow:SetEnabled(true)
			showToast("Scan Spawn Failed", "Collect zone not found — please try again", Theme.Red)
		end
	end)
end

if LP.Character then task.spawn(captureSpawnPos, LP.Character) end
LP.CharacterAdded:Connect(function(char) task.spawn(captureSpawnPos, char) end)

RunService.Heartbeat:Connect(function()
	if state.collectEsp and spawnScan.found then
		if not spawnScan.collectPart or not spawnScan.collectPart.Parent then
			destroyCollectESP()
		end
	end
end)

--//=================== AUTO TELEPORT (V3 SEARCHER) ==========
-- V3 searcher: exact → case-insensitive direct → recursive → recursive CI
-- Flow: find carried → if child count increased (new child appeared) → teleport to collect part
local carryState = {
	container = nil,
	method = nil,
	known = {},
}

local function findCarriedV3()
	local target = CONFIG.Carry.Name:lower()

	-- 1. Exact (case-sensitive) direct child of workspace
	local exact = workspace:FindFirstChild(CONFIG.Carry.Name)
	if exact then return exact, "exact" end

	-- 2. Case-insensitive direct children of workspace
	for _, child in ipairs(workspace:GetChildren()) do
		if child.Name:lower() == target then
			return child, "case-insensitive"
		end
	end

	-- 3. Recursive case-sensitive anywhere in workspace
	local recursive = workspace:FindFirstChild(CONFIG.Carry.Name, true)
	if recursive then return recursive, "recursive" end

	-- 4. Recursive case-insensitive anywhere in workspace
	for _, d in ipairs(workspace:GetDescendants()) do
		if d.Name:lower() == target then
			return d, "recursive-ci"
		end
	end

	return nil, "none"
end

local function detachCarry()
	carryState.container = nil
	carryState.method = nil
	carryState.known = {}
end

local function attachCarry(container, method)
	carryState.container = container
	carryState.method = method
	carryState.known = {}

	-- Snapshot existing children so they don't trigger a teleport
	for _, child in ipairs(container:GetChildren()) do
		carryState.known[child] = true
	end

	print("[AutoTp V3] Attached to " .. container:GetFullName() .. " via " .. method)
	if autoTpRow.subLbl then
		autoTpRow.subLbl.Text = "Active via " .. method .. " — watching"
	end
end

local function doTeleport()
	local char = LP.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local target = spawnScan.collectPart
	if not hrp or not target or not target.Parent then return false end

	if (hrp.Position - target.Position).Magnitude <= 4 then
		return false
	end

	noclip.bypassTeleport = true
	pcall(function()
		hrp.CFrame = target.CFrame + Vector3.new(0, 3, 0)
		hrp.AssemblyLinearVelocity = Vector3.zero
	end)
	noclip.lastCF = hrp.CFrame
	noclip.lastVel = hrp.AssemblyLinearVelocity
	task.delay(0.5, function() noclip.bypassTeleport = false end)
	return true
end

task.spawn(function()
	while gui.Parent do
		task.wait(CONFIG.Carry.ScanInterval)

		if state.power and state.autoTp and isPrivateServerActive()
			and spawnScan.found and spawnScan.collectPart
			and spawnScan.collectPart.Parent
		then
			local container, method = findCarriedV3()

			if not container then
				if carryState.container then
					detachCarry()
					if autoTpRow.subLbl then
						autoTpRow.subLbl.Text = "Searching for carried..."
					end
				end
			else
				-- Attach if new container, or re-attach if different
				if carryState.container ~= container then
					attachCarry(container, method)
				end

				-- Detect new children
				local current = {}
				local newChild = nil
				for _, child in ipairs(container:GetChildren()) do
					current[child] = true
					if not carryState.known[child] and not newChild then
						newChild = child
					end
				end
				carryState.known = current

				if newChild then
					print("[AutoTp V3] New child in carried: " .. newChild.Name .. " → teleporting")
					if doTeleport() then
						showToast("Auto Teleport", "New egg — teleported to collect zone", Theme.Green)
					end
				end
			end
		else
			if carryState.container then
				detachCarry()
				if autoTpRow.subLbl then
					autoTpRow.subLbl.Text = "V3 searcher — detects new child in carried"
				end
			end
		end
	end
end)

--//=================== NOCLIP RUNTIME =======================
RunService.Stepped:Connect(function()
	if not (state.power and state.noclip) then return end
	local char = LP.Character
	if not char then return end
	if char ~= noclip.char then
		noclip.saved = {}; noclip.char = char
		noclip.hrp = char:FindFirstChild("HumanoidRootPart")
		noclip.lastCF = nil; noclip.lastVel = nil
		ensureTeleportHook()
	end
	for _, p in ipairs(char:GetDescendants()) do
		if p:IsA("BasePart") then
			if p.CanCollide then
				noclip.saved[p] = noclip.saved[p] or {}
				noclip.saved[p].collide = true
				p.CanCollide = false
			end
			if p.CanTouch then
				noclip.saved[p] = noclip.saved[p] or {}
				noclip.saved[p].touch = true
				p.CanTouch = false
			end
		end
	end
end)

RunService.Heartbeat:Connect(function(dt)
	if not (state.power and state.noclip) then return end
	local hrp = noclip.hrp
	if not hrp or not hrp.Parent then return end
	if not noclip.bypassTeleport then
		if noclip.lastCF and noclip.lastVel then
			local expected = noclip.lastCF.Position + noclip.lastVel * dt
			if (hrp.Position - expected).Magnitude > CONFIG.Noclip.TeleportRevert then
				local rot = noclip.lastCF - noclip.lastCF.Position
				hrp.CFrame = CFrame.new(expected) * rot
				hrp.AssemblyLinearVelocity = noclip.lastVel
			end
		end
	end
	noclip.lastCF = hrp.CFrame
	noclip.lastVel = hrp.AssemblyLinearVelocity
end)

--//=================== FAKE EGG =============================
local function accessoryList(char)
	local list = {}
	for _, c in ipairs(char:GetChildren()) do
		if c:IsA("Accessory") or c:IsA("Hat") then
			local t = c:IsA("Accessory") and tostring(c.AccessoryType) or "Hat"
			table.insert(list, t .. "|" .. c.Name)
		end
	end
	table.sort(list)
	return list
end

local function clothingSig(char)
	local shirt = char:FindFirstChildOfClass("Shirt")
	local pants = char:FindFirstChildOfClass("Pants")
	local head  = char:FindFirstChild("Head")
	local face  = head and head:FindFirstChild("face")
	return {
		shirt = shirt and shirt.ShirtTemplate or "",
		pants = pants and pants.PantsTemplate or "",
		face  = (face and face:IsA("Decal")) and face.Texture or "",
		accessories = accessoryList(char),
	}
end
local function sigEq(a, b)
	if not a or not b then return false end
	if a.shirt ~= b.shirt or a.pants ~= b.pants or a.face ~= b.face then return false end
	if #a.accessories ~= #b.accessories then return false end
	for i = 1, #a.accessories do
		if a.accessories[i] ~= b.accessories[i] then return false end
	end
	return true
end

local function analyzeCharacter(plr, d)
	local flags = {}
	pcall(function()
		local char = plr.Character
		if not char then return end
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hum or hum.Health <= 0 then return end
		local cur = clothingSig(char)
		if d.baselineChar ~= char then
			d.baselineChar = char; d.baseline = nil; d.lastSig = nil
			d.stableCount = 0; d.baselineTime = os.clock()
		end
		if not d.baseline then
			if d.lastSig and sigEq(d.lastSig, cur) then
				d.stableCount = d.stableCount + 1
			else d.stableCount = 0 end
			d.lastSig = cur
			if d.stableCount >= CONFIG.FakeEgg.MinStableTicks
				and os.clock() - d.baselineTime >= CONFIG.FakeEgg.MinSettleTime then
				d.baseline = cur
			end
		else
			if cur.shirt ~= d.baseline.shirt then table.insert(flags, "Shirt changed") end
			if cur.pants ~= d.baseline.pants then table.insert(flags, "Pants changed") end
			if cur.face  ~= d.baseline.face  then table.insert(flags, "Face changed")  end
			local baseSet, curSet = {}, {}
			for _, k in ipairs(d.baseline.accessories) do baseSet[k] = true end
			for _, k in ipairs(cur.accessories)        do curSet[k]  = true end
			for _, k in ipairs(cur.accessories) do
				if not baseSet[k] then table.insert(flags, "New: " .. (k:match("|(.+)$") or k)); break end
			end
			for _, k in ipairs(d.baseline.accessories) do
				if not curSet[k] then table.insert(flags, "Removed: " .. (k:match("|(.+)$") or k)); break end
			end
		end
	end)
	return flags
end

--//=================== ESP PLAYERS ==========================
local espData = {}
local function getRoot(char)
	if not char then return nil end
	return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
		or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
end

local function createESP(plr)
	local bb = new("BillboardGui", {
		Name = "ChilliESP", Size = UDim2.fromOffset(240, 66), AlwaysOnTop = true,
		LightInfluence = 0, MaxDistance = 1000, ResetOnSpawn = false,
		StudsOffsetWorldSpace = Vector3.new(0, 2.4, 0),
	}, PG)
	local nameLbl = new("TextLabel", {
		Text = plr.Name, Font = Enum.Font.GothamBold, TextSize = 14,
		TextColor3 = Color3.new(1,1,1), TextStrokeTransparency = 0.35, TextStrokeColor3 = Color3.new(0,0,0),
		BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18),
	}, bb)
	new("UIGradient", {Color = ColorSequence.new(Color3.new(1,1,1), Theme.AccentB)}, nameLbl)

	local fakeLbl = new("TextLabel", {
		Text = "FAKE EGG", Font = Enum.Font.GothamBlack, TextSize = 16, TextColor3 = Theme.Red,
		TextStrokeTransparency = 0.2, TextStrokeColor3 = Color3.new(0,0,0), BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 18),
		Size = UDim2.new(1, 0, 0, 20), Visible = false,
	}, bb)
	local fakeScale = new("UIScale", {Scale = 1}, fakeLbl)

	local detailLbl = new("TextLabel", {
		Text = "", Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = Color3.fromRGB(255,165,165),
		TextStrokeTransparency = 0.6, TextStrokeColor3 = Color3.new(0,0,0), BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 14), Position = UDim2.fromOffset(0, 40), Visible = false,
	}, bb)

	local highlight = new("Highlight", {
		Name = "ChilliESPHighlight", FillColor = Theme.Red, FillTransparency = 0.72,
		OutlineColor = Theme.Red, OutlineTransparency = 0,
		DepthMode = Enum.HighlightDepthMode.AlwaysOnTop, Enabled = false,
	}, PG)

	return {
		plr = plr, gui = bb, nameLbl = nameLbl, fakeLbl = fakeLbl, fakeScale = fakeScale,
		detailLbl = detailLbl, highlight = highlight, flags = {},
		baseline = nil, baselineChar = nil, lastSig = nil,
		stableCount = 0, baselineTime = 0,
	}
end
local function destroyESP(plr)
	local d = espData[plr]
	if d then
		if d.gui then d.gui:Destroy() end
		if d.highlight then d.highlight:Destroy() end
		espData[plr] = nil
	end
end
local function refreshESP()
	if state.power and state.esp then
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LP and not espData[plr] then espData[plr] = createESP(plr) end
		end
	else
		for plr in pairs(espData) do destroyESP(plr) end
	end
end

Players.PlayerAdded:Connect(function(plr)
	if state.power and state.esp and plr ~= LP and not espData[plr] then
		espData[plr] = createESP(plr)
	end
end)
Players.PlayerRemoving:Connect(destroyESP)

RunService.RenderStepped:Connect(function()
	if not (state.power and state.esp) then return end
	for plr, d in pairs(espData) do
		local root = getRoot(plr.Character)
		if root then d.gui.Adornee = root; d.gui.Enabled = true else d.gui.Enabled = false end
	end
end)

task.spawn(function()
	while gui.Parent do
		task.wait(CONFIG.FakeEgg.ScanInterval)
		if state.power and state.esp and state.fake then
			for plr, d in pairs(espData) do
				local flags = analyzeCharacter(plr, d)
				d.flags = flags
				local isFake = #flags > 0
				d.fakeLbl.Visible   = isFake
				d.detailLbl.Visible = isFake
				d.detailLbl.Text    = isFake and table.concat(flags, " • ") or ""
				d.highlight.Enabled = isFake
				if isFake then d.highlight.Adornee = plr.Character end
			end
		else
			for _, d in pairs(espData) do
				d.fakeLbl.Visible = false
				d.detailLbl.Visible = false
				d.highlight.Enabled = false
			end
		end
	end
end)

task.spawn(function()
	while gui.Parent do
		local s = 1 + math.sin(os.clock() * 5) * 0.07
		for _, d in pairs(espData) do
			if d.fakeLbl.Visible then d.fakeScale.Scale = s end
		end
		task.wait(0.03)
	end
end)

--//=================== POWER ================================
local function setPower(on)
	state.power = on
	powerSwitch:Set(on)
	playTw(powerLabel, 0.2, {TextColor3 = on and Theme.AccentB or Theme.Sub})
	if on then
		playTw(overlay, 0.2, {BackgroundTransparency = 1})
		task.delay(0.22, function() if state.power then overlay.Visible = false end end)
		applySpeedBoost()
		if state.promptInstant then enablePromptInstant() end
		if state.eggEsp then refreshEggESP() end
		refreshCollectESP()
	else
		restoreNoclip()
		disablePromptInstant()
		applySpeedBoost()
		clearEggESP()
		destroyCollectESP()
		detachCarry()
		overlay.Visible = true
		playTw(overlay, 0.2, {BackgroundTransparency = 0.45})
	end
	refreshESP()
end

powerSwitch.track.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		setPower(not state.power); clickSound()
	end
end)

--//=================== ROW WIRING ===========================
noclipRow:Set(false, true)
espRow:Set(false, true)
fakeRow:Set(false, true)
speedBoostRow:Set(false, true)
promptRow:Set(false, true)
eggEspRow:Set(false, true)
autoTpRow:Set(false, true)
collectEspRow:Set(false, true)

noclipRow.onChange = function(v)
	state.noclip = v
	if v then ensureTeleportHook() else restoreNoclip() end
end
speedBoostRow.onChange = function(v)
	state.speedBoost = v
	if v then speedSlider:Show() else speedSlider:Hide() end
	applySpeedBoost()
end
promptRow.onChange = function(v)
	state.promptInstant = v
	if v and state.power then enablePromptInstant() else disablePromptInstant() end
end
eggEspRow.onChange = function(v) state.eggEsp = v; refreshEggESP() end
autoTpRow.onChange = function(v)
	state.autoTp = v
	if not v then detachCarry() end
end
collectEspRow.onChange = function(v)
	state.collectEsp = v
	refreshCollectESP()
end
fakeRow.onChange = function(v) state.fake = v end
espRow.onChange = function(v)
	state.esp = v
	if v then fakeRow:Show()
	else fakeRow:Hide(); fakeRow:Set(false, true); state.fake = false end
	refreshESP()
end

--//=================== MINIMIZE =============================
local minimized = false
local savedPos = nil

local function setMinimized(m)
	if m == minimized then return end
	minimized = m
	if m then
		savedPos = main.Position
		subtitle.Visible = false
		powerBox.Visible = false
		tabBar.Visible = false
		content.Visible = false
		minimizeBtn.Text = "+"
		playTw(title, 0.2, {
			TextSize = 15, Position = UDim2.fromOffset(12, 7), Size = UDim2.new(0, 130, 0, 22),
		}, Enum.EasingStyle.Quart)
		playTw(main, 0.28, {
			Size = UDim2.fromOffset(MINI_W, MINI_H),
			Position = UDim2.new(0.5, -MINI_W/2, 0, 8),
		}, Enum.EasingStyle.Quart)
	else
		playTw(title, 0.2, {
			TextSize = 21, Position = UDim2.fromOffset(20, 8), Size = UDim2.new(0, 220, 0, 24),
		}, Enum.EasingStyle.Quart)
		playTw(main, 0.28, {
			Size = UDim2.fromOffset(FULL_W, FULL_H),
			Position = savedPos or UDim2.new(0.5, -FULL_W/2, 0.5, -FULL_H/2),
		}, Enum.EasingStyle.Quart)
		task.delay(0.28, function()
			if not minimized then
				subtitle.Visible = true
				powerBox.Visible = true
				tabBar.Visible = true
				content.Visible = true
			end
		end)
		minimizeBtn.Text = "-"
	end
end
minimizeBtn.MouseButton1Click:Connect(function() setMinimized(not minimized); clickSound() end)

--//=================== DRAG =================================
do
	local dragging, dragStart, startPos
	topBar.InputBegan:Connect(function(input)
		if minimized then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true; dragStart = input.Position; startPos = main.Position
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if not dragging or minimized then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then
			local d = input.Position - dragStart
			main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
				startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
end

closeBtn.MouseButton1Click:Connect(function() gui.Enabled = false end)
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.RightShift then
		gui.Enabled = not gui.Enabled
	elseif input.KeyCode == Enum.KeyCode.RightControl then
		setMinimized(not minimized)
	end
end)

--//=================== INIT =================================
selectTab(1)
setPower(true)
powerSwitch:Set(true, false)
updatePrivateServerLocks()

task.spawn(function()
	local t = 0
	while gui.Parent do
		t = t + task.wait(0.03)
		accentGrad.Offset = Vector2.new(math.sin(t * 1.4) * 0.35, 0)
		titleGrad.Offset  = Vector2.new(math.sin(t * 0.9) * 0.25, 0)
	end
end)

print("[Chilli Hub] v10 + V3 loaded")
