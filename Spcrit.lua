-- [[ SCRIPT BAY CÓ NÚT BẤM TRÊN MÀN HÌNH CHO ĐIỆN THOẠI ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local IsFlying = false
local FlySpeed = 60 -- Tốc độ bay

local function getCharacter() return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() end
local function getRoot() local char = getCharacter() return char:WaitForChild("HumanoidRootPart") end

-- THIẾT KẾ NÚT BẤM (GUI) TRÊN MÀN HÌNH ĐIỆN THOẠI
local ScreenGui = Instance.new("ScreenGui")
local FlyButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

-- Đưa giao diện vào nơi không bị mất khi chết (CoreGui hoặc PlayerGui)
ScreenGui.Parent = CoreGui:FindFirstChild("RobloxGui") or LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Cấu hình nút bấm
FlyButton.Name = "FlyButton"
FlyButton.Parent = ScreenGui
FlyButton.Size = UDim2.new(0, 100, 0, 45) -- Kích thước nút
FlyButton.Position = UDim2.new(0.1, 0, 0.4, 0) -- Vị trí góc bên trái màn hình
FlyButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Màu đỏ (Đang tắt)
FlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyButton.TextSize = 16
FlyButton.Font = Enum.Font.SourceSansBold
FlyButton.Text = "BAY: TẮT"
FlyButton.Active = true
FlyButton.Draggable = true -- Bạn có thể lấy ngón tay kéo nút này đi chỗ khác nếu vướng

UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = FlyButton

-- CƠ CHẾ BAY CHUYỂN ĐỘNG THEO CAMERA ĐIỆN THOẠI
local function toggleFly()
    IsFlying = not IsFlying
    
    if IsFlying then
        FlyButton.Text = "BAY: BẬT"
        FlyButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Đổi sang màu xanh lá
    else
        FlyButton.Text = "BAY: TẮT"
        FlyButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Đổi về màu đỏ
        return
    end

    local hrp = getRoot()
    
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = hrp
    
    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.CFrame = hrp.CFrame
    bg.Parent = hrp

    task.spawn(function()
        while IsFlying and hrp and hrp.Parent do
            -- Trên điện thoại, bạn cứ hướng Camera (quay góc nhìn) về đâu và bấm nút di chuyển của game, nhân vật sẽ bay theo hướng đó
            local moveDirection = Vector3.new(0, 0, 0)
            local humanoid = getCharacter():FindFirstChildOfClass("Humanoid")
            
            if humanoid and humanoid.MoveDirection.Magnitude > 0 then
                moveDirection = humanoid.MoveDirection
            end
            
            if moveDirection.Magnitude > 0 then
                bv.Velocity = moveDirection * FlySpeed
            else
                bv.Velocity = Vector3.new(0, 0, 0)
            end
            
            bg.CFrame = Camera.CFrame
            RunService.Heartbeat:Wait()
        end
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
    end)
end

-- Chạm tay vào nút để bật/tắt bay
FlyButton.MouseButton1Click:Connect(toggleFly)
