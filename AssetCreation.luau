local Selection = game:GetService("Selection")
local InsertService = game:GetService("InsertService")
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local toolbar = plugin:CreateToolbar("Forbidden Creation Tool")

local OPEN_ICON = "rbxassetid://121875636925290"
local CLOSE_ICON = "rbxassetid://137150013017997"

local PLUGIN_VERSION = 1
local PLUGIN_ASSET_ID = 0

local connections: { RBXScriptConnection } = {}
local function track(connection: RBXScriptConnection): RBXScriptConnection
	table.insert(connections, connection)
	return connection
end

plugin.Unloading:Connect(function()
	for _, connection in ipairs(connections) do
		connection:Disconnect()
	end
	table.clear(connections)
end)

local ACCESSORY_TYPES = {
	{ label = "Hat", attachment = "HatAttachment", enumName = "Hat" },
	{ label = "Hair", attachment = "HairAttachment", enumName = "Hair" },
	{ label = "Face", attachment = "FaceFrontAttachment", enumName = "Face" },
	{ label = "Eyebrow", attachment = "FaceFrontAttachment", enumName = "Eyebrow" },
	{ label = "Eyelash", attachment = "FaceFrontAttachment", enumName = "Eyelash" },
	{ label = "Neck", attachment = "NeckAttachment", enumName = "Neck" },
	{ label = "Front", attachment = "BodyFrontAttachment", enumName = "Front" },
	{ label = "Back", attachment = "BodyBackAttachment", enumName = "Back" },
	{ label = "Waist", attachment = "WaistCenterAttachment", enumName = "Waist" },
	{ label = "L Shoulder", attachment = "LeftShoulderAttachment", enumName = "Shoulder" },
	{ label = "R Shoulder", attachment = "RightShoulderAttachment", enumName = "Shoulder" },
	{ label = "L Collar", attachment = "LeftCollarAttachment", enumName = "Shoulder" },
	{ label = "R Collar", attachment = "RightCollarAttachment", enumName = "Shoulder" },
}

local SCALE_TYPES = {
	{ label = "Classic", value = "Classic" },
	{ label = "Normal", value = "ProportionsNormal" },
	{ label = "Slender", value = "ProportionsSlender" },
}

local pluginButton = toolbar:CreateButton(
	"AssetCreation",
	"Open or close the Forbidden Creation Tool menu",
	OPEN_ICON,
	"Forbidden Creation Tool"
)
pluginButton.ClickableWhenViewportHidden = true

local widget: DockWidgetPluginGui

local function updatePluginButtonState(isMenuOpen: boolean)
	pluginButton.Icon = if isMenuOpen then CLOSE_ICON else OPEN_ICON
	pluginButton:SetActive(isMenuOpen)
end

local widgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Float,
	false,
	false,
	320,
	460,
	300,
	360
)

widget = plugin:CreateDockWidgetPluginGuiAsync("AccessoryCreator", widgetInfo)
widget.Title = "Forbidden Creation Tool"

local TOPBAR_HEIGHT = 46

local topbar = Instance.new("Frame")
topbar.Name = "Topbar"
topbar.Size = UDim2.new(1, 0, 0, TOPBAR_HEIGHT)
topbar.BackgroundColor3 = Color3.fromRGB(33, 34, 39)
topbar.BorderSizePixel = 0
topbar.ZIndex = 2
topbar.Parent = widget

local topbarDivider = Instance.new("Frame")
topbarDivider.Size = UDim2.new(1, 0, 0, 1)
topbarDivider.Position = UDim2.new(0, 0, 1, -1)
topbarDivider.BackgroundColor3 = Color3.fromRGB(39, 40, 46)
topbarDivider.BorderSizePixel = 0
topbarDivider.ZIndex = 2
topbarDivider.Parent = topbar

local topbarIcon = Instance.new("ImageLabel")
topbarIcon.Size = UDim2.fromOffset(26, 26)
topbarIcon.Position = UDim2.new(0, 10, 0.5, -13)
topbarIcon.BackgroundTransparency = 1
topbarIcon.Image = OPEN_ICON
topbarIcon.ZIndex = 2
topbarIcon.Parent = topbar

local topbarTitle = Instance.new("TextLabel")
topbarTitle.BackgroundTransparency = 1
topbarTitle.Position = UDim2.new(0, 46, 0, 6)
topbarTitle.Size = UDim2.new(1, -56, 0, 18)
topbarTitle.Font = Enum.Font.GothamBold
topbarTitle.TextSize = 15
topbarTitle.TextXAlignment = Enum.TextXAlignment.Left
topbarTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
topbarTitle.Text = "Forbidden Creation Tool"
topbarTitle.ZIndex = 2
topbarTitle.Parent = topbar

local topbarStatus = Instance.new("TextLabel")
topbarStatus.BackgroundTransparency = 1
topbarStatus.Position = UDim2.new(0, 46, 0, 24)
topbarStatus.Size = UDim2.new(1, -56, 0, 16)
topbarStatus.Font = Enum.Font.Gotham
topbarStatus.TextSize = 11
topbarStatus.TextXAlignment = Enum.TextXAlignment.Left
topbarStatus.TextTruncate = Enum.TextTruncate.AtEnd
topbarStatus.TextColor3 = Color3.fromRGB(150, 150, 150)
topbarStatus.Text = "Step 1 of 3"
topbarStatus.ZIndex = 2
topbarStatus.Parent = topbar

local DEFAULT_STATUS_COLOR = Color3.fromRGB(150, 150, 150)
local statusToken = 0
local statusTween: Tween? = nil

local function cancelStatusTween()
	if statusTween then
		statusTween:Cancel()
		statusTween = nil
	end
end

local function setStatus(text: string, color: Color3?)
	statusToken += 1
	cancelStatusTween()
	topbarStatus.TextTransparency = 0
	topbarStatus.Text = text
	topbarStatus.TextColor3 = color or DEFAULT_STATUS_COLOR
end

local FOOTER_HEIGHT = 24

local footer = Instance.new("Frame")
footer.Name = "Footer"
footer.Size = UDim2.new(1, 0, 0, FOOTER_HEIGHT)
footer.Position = UDim2.new(0, 0, 1, -FOOTER_HEIGHT)
footer.BackgroundColor3 = Color3.fromRGB(25, 26, 31)
footer.BorderSizePixel = 0
footer.ZIndex = 2
footer.Parent = widget

local footerDivider = Instance.new("Frame")
footerDivider.Size = UDim2.new(1, 0, 0, 1)
footerDivider.Position = UDim2.new(0, 0, 0, 0)
footerDivider.BackgroundColor3 = Color3.fromRGB(39, 40, 46)
footerDivider.BorderSizePixel = 0
footerDivider.ZIndex = 2
footerDivider.Parent = footer

local versionLabel = Instance.new("TextLabel")
versionLabel.BackgroundTransparency = 1
versionLabel.Size = UDim2.new(1, -20, 1, 0)
versionLabel.Position = UDim2.new(0, 10, 0, 0)
versionLabel.Font = Enum.Font.Gotham
versionLabel.TextSize = 12
versionLabel.TextXAlignment = Enum.TextXAlignment.Left
versionLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
versionLabel.RichText = true
versionLabel.Text = "Version " .. PLUGIN_VERSION
versionLabel.ZIndex = 2
versionLabel.Parent = footer

local latestVersion: number? = nil
local updateButton: PluginToolbarButton? = nil
local versionChecked = false

local function applyVersionUI()
	local outdated = latestVersion ~= nil and latestVersion > PLUGIN_VERSION
	if outdated then
		versionLabel.Text = string.format(
			'Version %d  <font color="rgb(255,80,80)">OUTDATED</font>',
			PLUGIN_VERSION
		)
		if not updateButton then
			updateButton = toolbar:CreateButton(
				"AssetCreationUpdate",
				"Update to version " .. tostring(latestVersion),
				OPEN_ICON,
				"Update Plugin"
			)
			updateButton.ClickableWhenViewportHidden = true
			track(updateButton.Click:Connect(function()
				widget.Enabled = true
				setStatus(
					"Update available (v" .. tostring(latestVersion) .. "). Open Plugins \u{25B8} Manage Plugins to update.",
					Color3.fromRGB(255, 120, 120)
				)
			end))
		end
	else
		versionLabel.Text = "Version " .. PLUGIN_VERSION
	end
end

local function checkVersionOnce()
	if versionChecked then
		return
	end
	versionChecked = true

	if PLUGIN_ASSET_ID <= 0 then
		applyVersionUI()
		return
	end

	task.spawn(function()
		local ok, info = pcall(function()
			return MarketplaceService:GetProductInfoAsync(PLUGIN_ASSET_ID, Enum.InfoType.Asset)
		end)
		if ok and typeof(info) == "table" and info.Description then
			local found = tostring(info.Description):match("Version:%s*(%d+)")
			if found then
				latestVersion = tonumber(found)
			end
		end
		applyVersionUI()
	end)
end

local selectedMesh: BasePart? = nil
local selectedSpecialMesh: SpecialMesh? = nil
local selectedRig: Model? = nil
local rigType: string? = nil
local selectedType: { label: string, attachment: string, enumName: string }? = nil
local selectedScaleType = "ProportionsNormal"
local currentStep = 1
local showStep: (step: number) -> ()

local suppressSelectionReset = false
local function setSelectionSuppressed(objects: { Instance })
	suppressSelectionReset = true
	Selection:Set(objects)
	task.defer(function()
		suppressSelectionReset = false
	end)
end

local function isInSelection(obj: Instance): boolean
	for _, sel in ipairs(Selection:Get()) do
		if sel == obj then
			return true
		end
	end
	return false
end

local function stepStatusText(): string
	if currentStep == 1 then
		return "Step 1 of 3 — MeshPart"
	elseif currentStep == 2 then
		return "Step 2 of 3 — Rig Selection"
	end
	return "Step 3 of 3 — Review and Create"
end

local function showTransientStatus(message: string, color: Color3?)
	setStatus(message, color)
	local myToken = statusToken
	task.delay(5, function()
		if myToken ~= statusToken then
			return
		end
		cancelStatusTween()
		local fadeOut = TweenService:Create(topbarStatus, TweenInfo.new(0.4), { TextTransparency = 1 })
		statusTween = fadeOut
		fadeOut:Play()
		fadeOut.Completed:Wait()
		if myToken ~= statusToken then
			return
		end
		statusTween = nil
		topbarStatus.Text = stepStatusText()
		topbarStatus.TextColor3 = DEFAULT_STATUS_COLOR
		local fadeIn = TweenService:Create(topbarStatus, TweenInfo.new(0.4), { TextTransparency = 0 })
		statusTween = fadeIn
		fadeIn:Play()
	end)
end

local COLOR_PRIMARY = Color3.fromRGB(0, 120, 215)
local COLOR_PRIMARY_OFF = Color3.fromRGB(70, 70, 70)

local function makePage(): Frame
	local page = Instance.new("Frame")
	page.Size = UDim2.new(1, 0, 1, -(TOPBAR_HEIGHT + FOOTER_HEIGHT))
	page.Position = UDim2.new(0, 0, 0, TOPBAR_HEIGHT)
	page.BackgroundColor3 = Color3.fromRGB(25, 26, 31)
	page.BorderSizePixel = 0
	page.Visible = false
	page.Parent = widget

	local scroller = Instance.new("ScrollingFrame")
	scroller.Name = "Content"
	scroller.Size = UDim2.fromScale(1, 1)
	scroller.BackgroundTransparency = 1
	scroller.BorderSizePixel = 0
	scroller.ScrollBarThickness = 4
	scroller.ScrollBarImageTransparency = 0
	scroller.ScrollBarImageColor3 = Color3.fromRGB(108, 111, 128)
	scroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroller.CanvasSize = UDim2.fromScale(0, 0)
	scroller.Parent = page

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 12)
	padding.PaddingBottom = UDim.new(0, 12)
	padding.PaddingLeft = UDim.new(0, 12)
	padding.PaddingRight = UDim.new(0, 12)
	padding.Parent = scroller

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 10)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Parent = scroller

	return scroller
end

local function createLabel(parent: Instance, text: string, order: number, bold: boolean?): TextLabel
	local label = Instance.new("TextLabel")
	label.LayoutOrder = order
	label.AutomaticSize = Enum.AutomaticSize.Y
	label.Size = UDim2.new(1, 0, 0, bold and 22 or 18)
	label.BackgroundTransparency = 1
	label.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
	label.TextSize = bold and 16 or 14
	label.TextColor3 = bold and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextWrapped = true
	label.Text = text
	label.Parent = parent
	return label
end

local function createHeading(parent: Instance, text: string): TextLabel
	local heading = Instance.new("TextLabel")
	heading.LayoutOrder = 0
	heading.AutomaticSize = Enum.AutomaticSize.Y
	heading.Size = UDim2.new(1, 0, 0, 30)
	heading.BackgroundTransparency = 1
	heading.Font = Enum.Font.GothamBold
	heading.TextSize = 22
	heading.TextColor3 = Color3.fromRGB(255, 255, 255)
	heading.TextXAlignment = Enum.TextXAlignment.Left
	heading.TextWrapped = true
	heading.Text = text
	heading.Parent = parent
	return heading
end

local function createButton(parent: Instance, text: string, order: number, primary: boolean): TextButton
	local button = Instance.new("TextButton")
	button.LayoutOrder = order
	button.Size = UDim2.new(1, 0, 0, 36)
	button.BackgroundColor3 = if primary then COLOR_PRIMARY else Color3.fromRGB(60, 60, 60)
	button.BorderSizePixel = 0
	button.Font = Enum.Font.GothamBold
	button.TextSize = 15
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Text = text
	button.AutoButtonColor = true
	button.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = button

	local sizeConstraint = Instance.new("UISizeConstraint")
	sizeConstraint.MaxSize = Vector2.new(240, math.huge)
	sizeConstraint.Parent = button

	return button
end

local function createDivider(parent: Instance, order: number): Frame
	local divider = Instance.new("Frame")
	divider.LayoutOrder = order
	divider.Size = UDim2.new(1, 0, 0, 1)
	divider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	divider.BorderSizePixel = 0
	divider.Parent = parent
	return divider
end

local function setButtonEnabled(button: TextButton, enabled: boolean, primary: boolean)
	button.Active = enabled
	button.AutoButtonColor = enabled
	button.TextTransparency = if enabled then 0 else 0.4
	if primary then
		button.BackgroundColor3 = if enabled then COLOR_PRIMARY else COLOR_PRIMARY_OFF
	end
end

local page1 = makePage()
createHeading(page1, "Choose Mesh")
createLabel(
	page1,
	"Click a MeshPart, or a Part with a SpecialMesh, in the workspace. It must not be inside a Model.",
	2,
	false
)
createDivider(page1, 3)
local meshStatusLabel = createLabel(page1, "Selection: None", 4, false)
meshStatusLabel.TextColor3 = Color3.fromRGB(170, 220, 255)
meshStatusLabel.Font = Enum.Font.GothamMedium
meshStatusLabel.TextXAlignment = Enum.TextXAlignment.Center
local nextButton1 = createButton(page1, "Next", 5, true)

local function getMeshSelection(): (BasePart?, SpecialMesh?, boolean, string)
	local selected = Selection:Get()
	if #selected == 0 then
		return nil, nil, false, "Selection Part: None"
	end
	if #selected > 1 then
		return nil, nil, false, "Selection Part: Select only one object"
	end

	local obj = selected[1]
	if not obj:IsA("BasePart") then
		return nil, nil, false, "Selection Part: Not a part"
	end
	if obj:FindFirstAncestorOfClass("Model") then
		return nil, nil, false, "Selection Part: '" .. obj.Name .. "' cannot be inside a model."
	end

	if obj:IsA("MeshPart") then
		return obj, nil, true, "Selected Part: " .. obj.Name .. "  (MeshPart)"
	end

	local specialMesh = obj:FindFirstChildWhichIsA("SpecialMesh")
	if specialMesh and specialMesh.MeshType == Enum.MeshType.FileMesh and specialMesh.MeshId ~= "" then
		return obj, specialMesh, true, "Selected Part: " .. obj.Name .. "  (Part + SpecialMesh)"
	end

	return nil, nil, false, "Selection Part: '" .. obj.Name .. "' is a part with no SpecialMesh."
end

local function refreshMeshStep()
	local part, special, valid, message = getMeshSelection()
	meshStatusLabel.Text = message
	meshStatusLabel.TextColor3 = if valid
		then Color3.fromRGB(150, 230, 150)
		else Color3.fromRGB(170, 220, 255)
	if valid then
		selectedMesh = part
		selectedSpecialMesh = special
	end
	setButtonEnabled(nextButton1, valid, true)
end

local page2 = makePage()
createHeading(page2, "Choose your Rig")
createLabel(
	page2,
	"Click a character rig (Model with a Humanoid) from the workspace. Your mesh from step 1 is remembered, so you don't need to hold Shift.",
	2,
	false
)
createDivider(page2, 3)
local rigStatusLabel = createLabel(page2, "Rig: None", 4, false)
rigStatusLabel.TextColor3 = Color3.fromRGB(170, 220, 255)
rigStatusLabel.Font = Enum.Font.GothamMedium
rigStatusLabel.TextXAlignment = Enum.TextXAlignment.Center
local nextButton2 = createButton(page2, "Next", 5, true)
local backButton2 = createButton(page2, "Back", 6, false)

local function getRigSelection(): (Model?, string?, boolean, string)
	local selected = Selection:Get()
	if #selected == 0 then
		return nil, nil, false, "Rig: None"
	end
	if #selected > 1 then
		return nil, nil, false, "Rig: Select only one model."
	end

	local obj = selected[1]
	local model = if obj:IsA("Model") then obj else obj:FindFirstAncestorOfClass("Model")
	if not model then
		return nil, nil, false, "Rig: Selection is not a Model."
	end

	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return nil, nil, false, "Rig: '" .. model.Name .. "' has no Humanoid"
	end

	local detected = if humanoid.RigType == Enum.HumanoidRigType.R15 then "R15" else "R6"
	return model, detected, true, "Selected Rig: " .. model.Name .. "  (" .. detected .. ")"
end

local function refreshRigStep()
	local model, detected, valid, message = getRigSelection()
	rigStatusLabel.Text = message
	rigStatusLabel.TextColor3 = if valid
		then Color3.fromRGB(150, 230, 150)
		else Color3.fromRGB(170, 220, 255)
	if valid then
		selectedRig = model
		rigType = detected
	end
	setButtonEnabled(nextButton2, valid, true)
end

local page3 = makePage()
createHeading(page3, "Accessory Review")

local VP_SIZE = 150

local reviewRow = Instance.new("Frame")
reviewRow.LayoutOrder = 1
reviewRow.BackgroundTransparency = 1
reviewRow.Size = UDim2.new(1, 0, 0, VP_SIZE)
reviewRow.Parent = page3

local viewport = Instance.new("ViewportFrame")
viewport.Position = UDim2.new(0, 0, 0, 0)
viewport.Size = UDim2.fromOffset(VP_SIZE, VP_SIZE)
viewport.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
viewport.BorderSizePixel = 0
viewport.Parent = reviewRow
local vpstroke = Instance.new("UIStroke")
vpstroke.Color = Color3.fromRGB(52, 55, 64)
vpstroke.Thickness = 1
vpstroke.Parent = viewport
local vpCorner = Instance.new("UICorner")
vpCorner.CornerRadius = UDim.new(0, 6)
vpCorner.Parent = viewport

local infoColumn = Instance.new("Frame")
infoColumn.BackgroundTransparency = 1
infoColumn.Position = UDim2.new(0, VP_SIZE + 10, 0, 0)
infoColumn.Size = UDim2.new(1, -(VP_SIZE + 10), 1, 0)
infoColumn.Parent = reviewRow
local infoLayout = Instance.new("UIListLayout")
infoLayout.SortOrder = Enum.SortOrder.LayoutOrder
infoLayout.Padding = UDim.new(0, 4)
infoLayout.Parent = infoColumn

createLabel(infoColumn, "Mesh", 1, true)
local summaryMeshLabel = createLabel(infoColumn, "—", 2, false)
createLabel(infoColumn, "Rig", 3, true)
local summaryRigLabel = createLabel(infoColumn, "—", 4, false)
createLabel(infoColumn, "Camera Orientation", 5, true)
local orientLabel = createLabel(infoColumn, "X: 0.000  Y: 0.000  Z: 0.000", 6, false)
orientLabel.RichText = true

viewport.Active = true

local viewYaw = math.rad(45)
local viewPitch = math.rad(25)
local viewDistance = 10
local targetYaw = viewYaw
local targetPitch = viewPitch
local targetDistance = viewDistance
local viewTargetSize = 4
local viewCamera: Camera? = nil
local currentViewCFrame: CFrame = CFrame.lookAt(Vector3.new(6, 4, 6), Vector3.zero)
local orbiting = false

local viewportHint = Instance.new("TextLabel")
viewportHint.Name = "Hint"
viewportHint.AnchorPoint = Vector2.new(0.5, 1)
viewportHint.Position = UDim2.new(0.5, 0, 1, -8)
viewportHint.Size = UDim2.new(1, -32, 0, 16)
viewportHint.BackgroundTransparency = 1
viewportHint.Font = Enum.Font.GothamMedium
viewportHint.TextSize = 12
viewportHint.TextColor3 = Color3.fromRGB(225, 225, 225)
viewportHint.TextStrokeTransparency = 0.5
viewportHint.Text = "Hold Right-Mouse and Drag"
viewportHint.ZIndex = 3
viewportHint.Parent = viewport

local hintTween: Tween? = nil
local hintDismissed = false

local function resetHint()
	hintDismissed = false
	if hintTween then
		hintTween:Cancel()
		hintTween = nil
	end
	viewportHint.TextTransparency = 0
	viewportHint.TextStrokeTransparency = 0.5
end

local function dismissHint()
	if hintDismissed then
		return
	end
	hintDismissed = true
	if hintTween then
		hintTween:Cancel()
	end
	hintTween = TweenService:Create(viewportHint, TweenInfo.new(0.4), {
		TextTransparency = 1,
		TextStrokeTransparency = 1,
	})
	hintTween:Play()
end

local function updateViewportCamera()
	local cosPitch = math.cos(viewPitch)
	local offset = Vector3.new(
		math.sin(viewYaw) * cosPitch,
		math.sin(viewPitch),
		math.cos(viewYaw) * cosPitch
	) * viewDistance
	local cf = CFrame.lookAt(offset, Vector3.zero)
	currentViewCFrame = cf
	if viewCamera then
		viewCamera.CFrame = cf
	end
	local rx, ry, rz = cf:ToOrientation()
	orientLabel.Text = string.format(
		'<font weight="medium" color="rgb(190,0,0)">X:</font> %.3f  <font weight="medium" color="rgb(0,190,0)">Y:</font> %.3f  <font weight="medium" color="rgb(0,0,190)">Z:</font> %.3f',
		math.deg(rx),
		math.deg(ry),
		math.deg(rz)
	)
end

local cameraAnimating = false

local function zoom(factor: number)
	targetDistance = math.clamp(targetDistance * factor, viewTargetSize * 0.6, viewTargetSize * 12)
	cameraAnimating = true
end

local SMOOTH_SPEED = 14
track(RunService.RenderStepped:Connect(function(dt)
	if not cameraAnimating or not viewCamera then
		return
	end
	local dYaw = targetYaw - viewYaw
	local dPitch = targetPitch - viewPitch
	local dDist = targetDistance - viewDistance
	if math.abs(dYaw) < 1e-4 and math.abs(dPitch) < 1e-4 and math.abs(dDist) < 1e-3 then
		viewYaw, viewPitch, viewDistance = targetYaw, targetPitch, targetDistance
		updateViewportCamera()
		cameraAnimating = false
		return
	end
	local alpha = math.min(dt * SMOOTH_SPEED, 1)
	viewYaw += dYaw * alpha
	viewPitch += dPitch * alpha
	viewDistance += dDist * alpha
	updateViewportCamera()
end))

local function makeZoomButton(symbol: string, offsetX: number): TextButton
	local b = Instance.new("TextButton")
	b.Size = UDim2.fromOffset(24, 24)
	b.AnchorPoint = Vector2.new(1, 0)
	b.Position = UDim2.new(1, offsetX, 0, 6)
	b.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	b.BackgroundTransparency = 0.35
	b.AutoButtonColor = true
	b.Font = Enum.Font.GothamBold
	b.TextSize = 18
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.Text = symbol
	b.ZIndex = 3
	b.Parent = viewport
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 4)
	c.Parent = b
	return b
end

local zoomInButton = makeZoomButton("+", -6)
local zoomOutButton = makeZoomButton("\u{2212}", -34)

track(zoomInButton.MouseButton1Click:Connect(function()
	zoom(0.85)
end))
track(zoomOutButton.MouseButton1Click:Connect(function()
	zoom(1.15)
end))

local lastMousePos: Vector2? = nil

local function stopOrbit()
	orbiting = false
	lastMousePos = nil
end

track(viewport.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		orbiting = true
		lastMousePos = Vector2.new(input.Position.X, input.Position.Y)
		dismissHint()
	end
end))

track(viewport.InputChanged:Connect(function(input)
	if orbiting and input.UserInputType == Enum.UserInputType.MouseMovement then
		local pos = Vector2.new(input.Position.X, input.Position.Y)
		if lastMousePos then
			local delta = pos - lastMousePos
			targetYaw -= delta.X * 0.01
			targetPitch = math.clamp(targetPitch + delta.Y * 0.01, math.rad(-85), math.rad(85))
			if input:IsModifierKeyDown(Enum.ModifierKey.Shift) then
				local grid = 0.5
				targetYaw = math.rad(math.round(math.deg(targetYaw) / grid) * grid)
				targetPitch = math.rad(math.round(math.deg(targetPitch) / grid) * grid)
			end
			cameraAnimating = true
		end
		lastMousePos = pos
	end
end))

track(viewport.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		stopOrbit()
	end
end))

track(UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		stopOrbit()
	end
end))
createLabel(page3, "Accessory Type", 3, true)

local typeScroller = Instance.new("ScrollingFrame")
typeScroller.LayoutOrder = 4
typeScroller.Size = UDim2.new(1, 0, 0, 62)
typeScroller.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
typeScroller.BorderSizePixel = 0
typeScroller.ScrollingDirection = Enum.ScrollingDirection.X
typeScroller.ScrollBarThickness = 6
typeScroller.ScrollBarImageTransparency = 0
typeScroller.ScrollBarImageColor3 = Color3.fromRGB(108, 111, 128)
typeScroller.AutomaticCanvasSize = Enum.AutomaticSize.X
typeScroller.CanvasSize = UDim2.fromScale(0, 0)
typeScroller.Parent = page3
local tsCorner = Instance.new("UICorner")
tsCorner.CornerRadius = UDim.new(0, 6)
tsCorner.Parent = typeScroller
local tsPadding = Instance.new("UIPadding")
tsPadding.PaddingTop = UDim.new(0, 6)
tsPadding.PaddingBottom = UDim.new(0, 6)
tsPadding.PaddingLeft = UDim.new(0, 6)
tsPadding.PaddingRight = UDim.new(0, 6)
tsPadding.Parent = typeScroller
local tsLayout = Instance.new("UIListLayout")
tsLayout.FillDirection = Enum.FillDirection.Horizontal
tsLayout.SortOrder = Enum.SortOrder.LayoutOrder
tsLayout.Padding = UDim.new(0, 6)
tsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tsLayout.Parent = typeScroller

track(typeScroller.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseWheel then
		typeScroller.CanvasPosition = Vector2.new(
			typeScroller.CanvasPosition.X - input.Position.Z * 48,
			typeScroller.CanvasPosition.Y
		)
	end
end))

local selectedTypeLabel = createLabel(page3, "Attachment: (none selected)", 5, true)
selectedTypeLabel.TextColor3 = Color3.fromRGB(170, 220, 255)

createLabel(page3, "Body Proportions", 6, true)

local scaleScroller = Instance.new("ScrollingFrame")
scaleScroller.LayoutOrder = 7
scaleScroller.Size = UDim2.new(1, 0, 0, 44)
scaleScroller.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
scaleScroller.BorderSizePixel = 0
scaleScroller.ScrollingDirection = Enum.ScrollingDirection.X
scaleScroller.ScrollBarThickness = 6
scaleScroller.ScrollBarImageTransparency = 0
scaleScroller.ScrollBarImageColor3 = Color3.fromRGB(108, 111, 128)
scaleScroller.AutomaticCanvasSize = Enum.AutomaticSize.X
scaleScroller.CanvasSize = UDim2.fromScale(0, 0)
scaleScroller.Parent = page3
local ssCorner = Instance.new("UICorner")
ssCorner.CornerRadius = UDim.new(0, 6)
ssCorner.Parent = scaleScroller
local ssPadding = Instance.new("UIPadding")
ssPadding.PaddingTop = UDim.new(0, 6)
ssPadding.PaddingBottom = UDim.new(0, 6)
ssPadding.PaddingLeft = UDim.new(0, 6)
ssPadding.PaddingRight = UDim.new(0, 6)
ssPadding.Parent = scaleScroller
local ssLayout = Instance.new("UIListLayout")
ssLayout.FillDirection = Enum.FillDirection.Horizontal
ssLayout.SortOrder = Enum.SortOrder.LayoutOrder
ssLayout.Padding = UDim.new(0, 6)
ssLayout.VerticalAlignment = Enum.VerticalAlignment.Center
ssLayout.Parent = scaleScroller

track(scaleScroller.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseWheel then
		scaleScroller.CanvasPosition = Vector2.new(
			scaleScroller.CanvasPosition.X - input.Position.Z * 48,
			scaleScroller.CanvasPosition.Y
		)
	end
end))

createDivider(page3, 8)
local locationLabel = createLabel(page3, "", 9, false)
locationLabel.RichText = true
locationLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
locationLabel.TextXAlignment = Enum.TextXAlignment.Center

local function formatPlacementText(x: number, y: number, z: number): string
	return string.format(
		'The newly created accessory will be placed in <font weight="medium" color="rgb(190,0,0)">X:</font> %.1f <font weight="medium" color="rgb(0,190,0)">Y:</font> %.1f <font weight="medium" color="rgb(0,0,190)">Z:</font> %.1f',
		x,
		y,
		z
	)
end

locationLabel.Text = formatPlacementText(0, 0, 0)

local createButton3 = createButton(page3, "Create Accessory", 10, true)
local backButton3 = createButton(page3, "Back", 11, false)
local resultLabel = createLabel(page3, "", 12, false)
resultLabel.TextColor3 = Color3.fromRGB(150, 230, 150)

local cancelButton3 = createButton(page3, "Cancel", 13, false)
cancelButton3.BackgroundColor3 = Color3.fromRGB(120, 55, 55)

local typeButtons: { TextButton } = {}

local function refreshTypeButtons()
	for index, button in ipairs(typeButtons) do
		local option = ACCESSORY_TYPES[index]
		local isSelected = selectedType ~= nil and selectedType.label == option.label
		button.BackgroundColor3 = if isSelected then COLOR_PRIMARY else Color3.fromRGB(55, 55, 55)
	end
end

for index, option in ipairs(ACCESSORY_TYPES) do
	local button = Instance.new("TextButton")
	button.LayoutOrder = index
	button.Size = UDim2.new(0, 84, 1, 0)
	button.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
	button.BorderSizePixel = 0
	button.Font = Enum.Font.Gotham
	button.TextSize = 13
	button.TextColor3 = Color3.fromRGB(235, 235, 235)
	button.Text = option.label
	button.Parent = typeScroller

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = button

	track(button.MouseButton1Click:Connect(function()
		selectedType = option
		selectedTypeLabel.Text = "Attachment: " .. option.attachment
		setButtonEnabled(createButton3, true, true)
		refreshTypeButtons()
	end))

	typeButtons[index] = button
end

local scaleButtons: { TextButton } = {}

local function refreshScaleButtons()
	for index, button in ipairs(scaleButtons) do
		local option = SCALE_TYPES[index]
		local isSelected = selectedScaleType == option.value
		button.BackgroundColor3 = if isSelected then COLOR_PRIMARY else Color3.fromRGB(55, 55, 55)
	end
end

for index, option in ipairs(SCALE_TYPES) do
	local button = Instance.new("TextButton")
	button.LayoutOrder = index
	button.Size = UDim2.new(0, 84, 1, 0)
	button.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
	button.BorderSizePixel = 0
	button.Font = Enum.Font.Gotham
	button.TextSize = 13
	button.TextColor3 = Color3.fromRGB(235, 235, 235)
	button.Text = option.label
	button.Parent = scaleScroller

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = button

	track(button.MouseButton1Click:Connect(function()
		selectedScaleType = option.value
		refreshScaleButtons()
	end))

	scaleButtons[index] = button
end

local function clearViewport()
	for _, child in ipairs(viewport:GetChildren()) do
		if child:IsA("BasePart") or child:IsA("Camera") or child:IsA("Model") then
			child:Destroy()
		end
	end
	viewCamera = nil
end

local function populateViewport()
	clearViewport()
	if not selectedMesh then
		return
	end

	local clone = selectedMesh:Clone()
	clone.Anchored = true
	clone.CFrame = CFrame.new()
	clone.Parent = viewport

	local camera = Instance.new("Camera")
	camera.Parent = viewport
	viewport.CurrentCamera = camera
	viewCamera = camera

	local extent = math.max(clone.Size.X, clone.Size.Y, clone.Size.Z, 1)
	viewTargetSize = extent
	viewYaw = math.rad(45)
	viewPitch = math.rad(25)
	viewDistance = extent * 2.2
	targetYaw = viewYaw
	targetPitch = viewPitch
	targetDistance = viewDistance
	updateViewportCamera()

	resetHint()
end

local function detectRigScaleType(rig: Model): string?
	for _, descendant in ipairs(rig:GetDescendants()) do
		if descendant:IsA("StringValue") and descendant.Name == "AvatarPartScaleType" then
			local value = descendant.Value
			if value == "Classic" or value == "ProportionsNormal" or value == "ProportionsSlender" then
				return value
			end
		end
	end
	return nil
end

local function buildSummary()
	resultLabel.Text = ""
	if selectedMesh then
		local kind = if selectedSpecialMesh then "Part + SpecialMesh" else "MeshPart"
		summaryMeshLabel.Text = selectedMesh.Name .. "  (" .. kind .. ")"
	else
		summaryMeshLabel.Text = "—"
	end
	summaryRigLabel.Text = if selectedRig
		then selectedRig.Name .. "  (" .. tostring(rigType) .. ")"
		else "—"
	if selectedMesh then
		local p = selectedMesh.Position
		locationLabel.Text = formatPlacementText(p.X, p.Y, p.Z)
	else
		locationLabel.Text = formatPlacementText(0, 0, 0)
	end
	if selectedRig then
		local detected = detectRigScaleType(selectedRig)
		if detected then
			selectedScaleType = detected
		end
	end
	refreshScaleButtons()
	setButtonEnabled(createButton3, selectedType ~= nil, true)
	refreshTypeButtons()
	populateViewport()
end

local function buildHandle(): MeshPart
	if selectedSpecialMesh and selectedMesh then
		local handle = InsertService:CreateMeshPartAsync(
			selectedSpecialMesh.MeshId,
			Enum.CollisionFidelity.Default,
			Enum.RenderFidelity.Automatic
		)
		handle.Size = handle.Size * selectedSpecialMesh.Scale
		handle.Color = selectedMesh.Color
		handle.Material = selectedMesh.Material
		handle.Transparency = selectedMesh.Transparency
		if selectedSpecialMesh.TextureId ~= "" then
			handle.TextureID = selectedSpecialMesh.TextureId
		end
		local surface = selectedMesh:FindFirstChildWhichIsA("SurfaceAppearance")
		if surface then
			surface:Clone().Parent = handle
		end
		return handle
	end

	local handle = (selectedMesh :: MeshPart):Clone()
	for _, child in ipairs(handle:GetChildren()) do
		if not child:IsA("SurfaceAppearance") then
			child:Destroy()
		end
	end
	return handle
end

local function findRigAttachment(rig: Model, name: string): Attachment?
	for _, descendant in ipairs(rig:GetDescendants()) do
		if descendant:IsA("Attachment") and descendant.Name == name then
			return descendant
		end
	end
	return nil
end

local function createThumbnail(accessory: Accessory, sourceHandle: BasePart)
	local config = Instance.new("Configuration")
	config.Name = "ThumbnailConfiguration"

	local cameraTarget = Instance.new("ObjectValue")
	cameraTarget.Name = "ThumbnailCameraTarget"
	cameraTarget.Value = sourceHandle
	cameraTarget.Parent = config

	local cameraValue = Instance.new("CFrameValue")
	cameraValue.Name = "ThumbnailCameraValue"
	cameraValue.Value = currentViewCFrame
	cameraValue.Parent = config

	config.Parent = accessory
end

local function createAccessory()
	if not selectedMesh or not selectedType then
		resultLabel.TextColor3 = Color3.fromRGB(230, 150, 150)
		resultLabel.Text = "Pick a mesh and an accessory type first."
		return
	end

	local recording = ChangeHistoryService:TryBeginRecording("Create Accessory")

	local ok, handleOrError = pcall(buildHandle)
	if not ok then
		if recording then
			ChangeHistoryService:FinishRecording(recording, Enum.FinishRecordingOperation.Cancel)
		end
		resultLabel.TextColor3 = Color3.fromRGB(230, 150, 150)
		resultLabel.Text = "Failed: " .. tostring(handleOrError)
		return
	end

	local handle = handleOrError :: MeshPart
	handle.Name = "Handle"
	handle.Anchored = false
	handle.CFrame = selectedMesh.CFrame

	local existingScaleType = handle:FindFirstChild("AvatarPartScaleType")
	if existingScaleType then
		existingScaleType:Destroy()
	end
	local scaleTypeValue = Instance.new("StringValue")
	scaleTypeValue.Name = "AvatarPartScaleType"
	scaleTypeValue.Value = selectedScaleType
	scaleTypeValue.Parent = handle

	local rigAttachment: Attachment? = nil
	if selectedRig then
		rigAttachment = findRigAttachment(selectedRig, selectedType.attachment)
	end

	local attachment = Instance.new("Attachment")
	attachment.Name = selectedType.attachment
	if rigAttachment then
		attachment.CFrame = selectedMesh.CFrame:Inverse() * rigAttachment.WorldCFrame
	end
	attachment.Parent = handle

	local accessory = Instance.new("Accessory")
	accessory.Name = selectedMesh.Name .. "_Accessory"
	pcall(function()
		accessory.AccessoryType = (Enum.AccessoryType :: any)[selectedType.enumName]
	end)
	handle.Parent = accessory

	local placementFolder = workspace:FindFirstChild("ForbiddenAccessories") or Instance.new("Folder")
	placementFolder.Name = "ForbiddenAccessories"
	placementFolder.Parent = workspace

	accessory.Parent = placementFolder
	handle.CFrame = selectedMesh.CFrame

	createThumbnail(accessory, handle)

	selectedMesh.Parent = nil
	selectedMesh = nil
	selectedSpecialMesh = nil

	setSelectionSuppressed({ accessory })

	if recording then
		ChangeHistoryService:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
	end

	local message: string
	local color: Color3
	if not selectedRig then
		color = Color3.fromRGB(235, 200, 120)
		message = "Created " .. accessory.Name .. " (no rig selected to orient against)."
	elseif not rigAttachment then
		color = Color3.fromRGB(235, 200, 120)
		message = "Created, but " .. (selectedRig :: Model).Name .. " has no " .. selectedType.attachment .. "."
	else
		color = Color3.fromRGB(150, 230, 150)
		message = "Created "
			.. accessory.Name
			.. " on "
			.. (selectedRig :: Model).Name
			.. " (" .. tostring(rigType) .. ")."
	end

	resultLabel.Text = ""
	selectedType = nil
	selectedRig = nil
	rigType = nil
	showStep(1)
	showTransientStatus(message, color)
end

function showStep(step: number)
	currentStep = step
	page1.Parent.Visible = step == 1
	page2.Parent.Visible = step == 2
	page3.Parent.Visible = step == 3

	if step == 1 then
		if selectedMesh then
			Selection:Set({ selectedMesh })
		end
		refreshMeshStep()
	elseif step == 2 then
		if selectedRig then
			Selection:Set({ selectedRig })
		end
		refreshRigStep()
	else
		buildSummary()
	end

	setStatus(stepStatusText())
end

track(nextButton1.MouseButton1Click:Connect(function()
	if nextButton1.Active then
		showStep(2)
	end
end))

track(nextButton2.MouseButton1Click:Connect(function()
	if nextButton2.Active then
		showStep(3)
	end
end))

track(backButton2.MouseButton1Click:Connect(function()
	showStep(1)
end))

track(backButton3.MouseButton1Click:Connect(function()
	showStep(2)
end))

track(createButton3.MouseButton1Click:Connect(function()
	if createButton3.Active then
		createAccessory()
	end
end))

track(cancelButton3.MouseButton1Click:Connect(function()
	selectedMesh = nil
	selectedSpecialMesh = nil
	selectedRig = nil
	rigType = nil
	selectedType = nil
	setSelectionSuppressed({})
	showStep(1)
	showTransientStatus("Accessory creation cancelled.", Color3.fromRGB(235, 200, 120))
end))

track(Selection.SelectionChanged:Connect(function()
	if not widget.Enabled or suppressSelectionReset then
		return
	end
	if currentStep == 1 then
		refreshMeshStep()
	elseif currentStep == 2 then
		local _, _, valid = getRigSelection()
		if not valid and selectedRig then
			selectedRig = nil
			rigType = nil
			showStep(1)
			return
		end
		refreshRigStep()
	elseif currentStep == 3 then
		if selectedRig and not isInSelection(selectedRig) then
			selectedRig = nil
			rigType = nil
			showStep(1)
		end
	end
end))

track(pluginButton.Click:Connect(function()
	widget.Enabled = not widget.Enabled
end))

track(widget:GetPropertyChangedSignal("Enabled"):Connect(function()
	updatePluginButtonState(widget.Enabled)
	if widget.Enabled then
		selectedMesh = nil
		selectedSpecialMesh = nil
		selectedRig = nil
		rigType = nil
		selectedType = nil
		Selection:Set({})
		showStep(1)
		checkVersionOnce()
	end
end))

updatePluginButtonState(false)
applyVersionUI()
showStep(1)