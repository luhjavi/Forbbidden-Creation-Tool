local StudioService = game:GetService("StudioService")
local Selection = game:GetService("Selection")
local UserService = game:GetService("UserService")
local Players = game:GetService("Players")
local toolbar = plugin:CreateToolbar("Forbbiden Asset Creator")

local OPEN_ICON = "rbxassetid://121875636925290"
local CLOSE_ICON = "rbxassetid://137150013017997"

local pluginButton = toolbar:CreateButton(
	"AssetCreation",
	"Open or close the AssetCreation menu",
	OPEN_ICON,
	"AssetCreation Tool"
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
	420,
	280,
	320
)

widget = plugin:CreateDockWidgetPluginGuiAsync("StudioUserInfo", widgetInfo)
widget.Title = "Studio User Info"

local root = Instance.new("ScrollingFrame")
root.Name = "Root"
root.Size = UDim2.fromScale(1, 1)
root.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
root.BorderSizePixel = 0
root.Parent = widget
root.ElasticBehavior = Enum.ElasticBehavior.Always
root.ScrollBarThickness = 4
root.ScrollingEnabled = true
root.ScrollBarImageTransparency = 0.8

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 12)
padding.PaddingBottom = UDim.new(0, 12)
padding.PaddingLeft = UDim.new(0, 12)
padding.PaddingRight = UDim.new(0, 12)
padding.Parent = root

local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 10)
layout.Parent = root

local function createLabel(text: string, layoutOrder: number, bold: boolean?): TextLabel
	local label = Instance.new("TextLabel")
	label.LayoutOrder = layoutOrder
	label.Size = UDim2.new(1, 0, 0, bold and 22 or 18)
	label.BackgroundTransparency = 1
	label.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
	label.TextSize = bold and 16 or 14
	label.TextColor3 = bold and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextWrapped = true
	label.Text = text
	label.Parent = root
	return label
end

local avatarFrame = Instance.new("Frame")
avatarFrame.LayoutOrder = 1
avatarFrame.Size = UDim2.new(1, 0, 0, 96)
avatarFrame.BackgroundTransparency = 1
avatarFrame.Parent = root

local avatar = Instance.new("ImageLabel")
avatar.Name = "Avatar"
avatar.Size = UDim2.fromOffset(96, 96)
avatar.Position = UDim2.new(0.5, -48, 0, 0)
avatar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
avatar.BorderSizePixel = 0
avatar.Parent = avatarFrame

local avatarCorner = Instance.new("UICorner")
avatarCorner.CornerRadius = UDim.new(0.5, 0)
avatarCorner.Parent = avatar

local displayNameLabel = createLabel("Loading...", 2, true)
local usernameLabel = createLabel("@...", 3, false)
local userIdLabel = createLabel("User ID: ...", 4, false)

local divider = Instance.new("Frame")
divider.LayoutOrder = 6
divider.Size = UDim2.new(1, 0, 0, 1)
divider.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
divider.BorderSizePixel = 0
divider.Parent = root

local selectionHeader = createLabel("Workspace Selection", 7, true)
local selectionLabel = createLabel("None", 8, false)
selectionLabel.TextColor3 = Color3.fromRGB(170, 220, 255)

local function getWorkspaceSelectionNames(): { string }
	local names = {}
	for _, instance in ipairs(Selection:Get()) do
		if instance:IsDescendantOf(workspace) then
			table.insert(names, instance.Name)
		end
	end
	return names
end

local function updateSelectionLabel()
	local names = getWorkspaceSelectionNames()
	if #names == 0 then
		selectionLabel.Text = "None"
	else
		selectionLabel.Text = table.concat(names, ", ")
	end
end

local function loadUserInfo()
	local userId = StudioService:GetUserId()
	if userId <= 0 then
		displayNameLabel.Text = "Not signed in"
		usernameLabel.Text = ""
		userIdLabel.Text = ""
		avatar.Image = ""
		return
	end

	userIdLabel.Text = "User ID: " .. tostring(userId)
	avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. userId .. "&w=150&h=150"

	task.spawn(function()
		local infoOk, userInfos = pcall(function()
			return UserService:GetUserInfosByUserIdsAsync({ userId })
		end)

		if infoOk and userInfos and userInfos[1] then
			local info = userInfos[1]
			displayNameLabel.Text = info.DisplayName
			usernameLabel.Text = "@" .. info.Username
		else
			local nameOk, username = pcall(function()
				return Players:GetNameFromUserIdAsync(userId)
			end)
			if nameOk and username then
				displayNameLabel.Text = username
				usernameLabel.Text = "@" .. username
			else
				displayNameLabel.Text = "User " .. tostring(userId)
				usernameLabel.Text = ""
			end
		end
	end)
end

pluginButton.Click:Connect(function()
	widget.Enabled = not widget.Enabled
end)

widget:GetPropertyChangedSignal("Enabled"):Connect(function()
	updatePluginButtonState(widget.Enabled)
	if widget.Enabled then
		loadUserInfo()
		updateSelectionLabel()
	end
end)

updatePluginButtonState(false)

Selection.SelectionChanged:Connect(function()
	if widget.Enabled then
		updateSelectionLabel()
	end
end)

loadUserInfo()
updateSelectionLabel()
