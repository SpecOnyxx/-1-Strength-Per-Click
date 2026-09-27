local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- Posición de destino
local targetPosition = Vector3.new(
	1853,
	26.364013671875,
	-274.40594482421875
)

local enabled = false
local minimized = false

--------------------------------------------------
-- GUI
--------------------------------------------------

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

--------------------------------------------------
-- CONTENEDOR PRINCIPAL
--------------------------------------------------

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 50)

-- CENTRAR EN LA PANTALLA
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)

mainFrame.BackgroundTransparency = 1
mainFrame.Parent = screenGui

--------------------------------------------------
-- BOTÓN TELEPORT
--------------------------------------------------

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 170, 0, 50)
button.Position = UDim2.new(0, 0, 0, 0)
button.Text = "TELEPORT: OFF"
button.TextSize = 18
button.Font = Enum.Font.SourceSansBold
button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Parent = mainFrame

--------------------------------------------------
-- BOTÓN MINIMIZAR
--------------------------------------------------

local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 35, 0, 50)
minimizeButton.Position = UDim2.new(0, 175, 0, 0)
minimizeButton.Text = "−"
minimizeButton.TextSize = 22
minimizeButton.Font = Enum.Font.SourceSansBold
minimizeButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.Parent = mainFrame

--------------------------------------------------
-- BOTÓN CERRAR
--------------------------------------------------

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 35, 0, 50)
closeButton.Position = UDim2.new(0, 215, 0, 0)
closeButton.Text = "X"
closeButton.TextSize = 20
closeButton.Font = Enum.Font.SourceSansBold
closeButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Parent = mainFrame

--------------------------------------------------
-- BOTÓN MAXIMIZAR
--------------------------------------------------

local maximizeButton = Instance.new("TextButton")
maximizeButton.Size = UDim2.new(0, 50, 0, 50)

-- CENTRADO INICIAL
maximizeButton.AnchorPoint = Vector2.new(0.5, 0.5)
maximizeButton.Position = mainFrame.Position

maximizeButton.Text = "+"
maximizeButton.TextSize = 25
maximizeButton.Font = Enum.Font.SourceSansBold
maximizeButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
maximizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
maximizeButton.Visible = false
maximizeButton.Parent = screenGui

--------------------------------------------------
-- ON / OFF
--------------------------------------------------

button.MouseButton1Click:Connect(function()

	enabled = not enabled

	if enabled then
		button.Text = "TELEPORT: ON"
		button.BackgroundColor3 = Color3.fromRGB(70, 170, 70)
	else
		button.Text = "TELEPORT: OFF"
		button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	end

end)

--------------------------------------------------
-- MINIMIZAR
--------------------------------------------------

minimizeButton.MouseButton1Click:Connect(function()

	minimized = true

	-- Guardar posición actual
	maximizeButton.Position = mainFrame.Position

	mainFrame.Visible = false
	maximizeButton.Visible = true

end)

--------------------------------------------------
-- MAXIMIZAR
--------------------------------------------------

maximizeButton.MouseButton1Click:Connect(function()

	minimized = false

	-- Recuperar posición donde estaba
	mainFrame.Position = maximizeButton.Position

	maximizeButton.Visible = false
	mainFrame.Visible = true

end)

--------------------------------------------------
-- CERRAR GUI
--------------------------------------------------

closeButton.MouseButton1Click:Connect(function()

	-- Detener teletransporte
	enabled = false

	-- Eliminar GUI
	screenGui:Destroy()

end)

--------------------------------------------------
-- ARRASTRAR TODA LA UI
--------------------------------------------------

local function makeDraggable(object)

	local dragging = false
	local dragStart
	local startPosition

	object.InputBegan:Connect(function(input)

		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			dragging = true
			dragStart = input.Position

			-- Guardar posición del contenedor
			startPosition = mainFrame.Position

			input.Changed:Connect(function()

				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end

			end)

		end

	end)

	UserInputService.InputChanged:Connect(function(input)

		if dragging then

			if input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch then

				local delta = input.Position - dragStart

				mainFrame.Position = UDim2.new(
					startPosition.X.Scale,
					startPosition.X.Offset + delta.X,

					startPosition.Y.Scale,
					startPosition.Y.Offset + delta.Y
				)

			end

		end

	end)

end

makeDraggable(button)
makeDraggable(minimizeButton)
makeDraggable(closeButton)

--------------------------------------------------
-- ARRASTRAR BOTÓN MAXIMIZADO
--------------------------------------------------

local draggingMax = false
local dragStartMax
local startPositionMax

maximizeButton.InputBegan:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		draggingMax = true
		dragStartMax = input.Position
		startPositionMax = maximizeButton.Position

		input.Changed:Connect(function()

			if input.UserInputState == Enum.UserInputState.End then
				draggingMax = false
			end

		end)

	end

end)

UserInputService.InputChanged:Connect(function(input)

	if draggingMax then

		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then

			local delta = input.Position - dragStartMax

			maximizeButton.Position = UDim2.new(
				startPositionMax.X.Scale,
				startPositionMax.X.Offset + delta.X,

				startPositionMax.Y.Scale,
				startPositionMax.Y.Offset + delta.Y
			)

		end

	end

end)

--------------------------------------------------
-- LOOP DE TELETRANSPORTE
--------------------------------------------------

task.spawn(function()

	while true do

		task.wait(2)

		if enabled then

			local character = player.Character
			local rootPart = character and character:FindFirstChild("HumanoidRootPart")

			if rootPart then
				rootPart.CFrame = CFrame.new(targetPosition)
			end

		end

	end

end)
