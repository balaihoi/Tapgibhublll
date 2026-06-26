-- [[ ĐOẠN CODE BAY VÀ TỰ ĐỘNG TÁT CHO MỌI GAME TÁT ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Trạng thái bật/tắt (Mặc định mới vào game là TẮT)
local IsFlying = false
local IsAutoSlapping = false

local FlySpeed = 50 -- Bạn có thể đổi số 50 này thành số cao hơn để bay nhanh hơn

-- Hàm tìm nhân vật của bạn
local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getRoot()
    local char = getCharacter()
    return char:WaitForChild("HumanoidRootPart")
end

---------------------------------------------------------
-- TÍNH NĂNG 1: BAY (FLY) - BẤM PHÍM 'E' ĐỂ BẬT/TẮT
---------------------------------------------------------
local function toggleFly()
    IsFlying = not IsFlying
    if not IsFlying then return end

    local hrp = getRoot()
    
    -- Giữ nhân vật không bị rơi xuống đất
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = hrp
    
    -- Giữ nhân vật thăng bằng, không bị xoay tròn
    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.CFrame = hrp.CFrame
    bodyGyro.Parent = hrp

    -- Vòng lặp xử lý di chuyển khi đang bay theo hướng Camera nhìn
    task.spawn(function()
        while IsFlying and hrp and hrp.Parent do
            local moveDirection = Vector3.new(0, 0, 0)
            
            -- Điều khiển hướng bay bằng các phím W, A, S, D thông thường
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + Camera.CFrame.RightVector end
            
            if moveDirection.Magnitude > 0 then
                bodyVelocity.Velocity = moveDirection.Unit * FlySpeed
            else
                bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            end
            
            bodyGyro.CFrame = Camera.CFrame
            RunService.Heartbeat:Wait()
        end
        
        -- Xóa bỏ hiệu ứng bay khi tắt tính năng
        bodyVelocity:Destroy()
        bodyGyro:Destroy()
    end)
end

-- Lắng nghe phím bấm E để Bay
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.E then
        toggleFly()
    end
end)

---------------------------------------------------------
-- TÍNH NĂNG 2: TỰ ĐỘNG TÁT (AUTO SLAP) - BẤM PHÍM 'R' ĐỂ BẬT/TẮT
---------------------------------------------------------
-- Hàm tự động tìm vũ khí (Găng tay hoặc công cụ tát) trong túi đồ
local function getSlapTool()
    local char = getCharacter()
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then return tool end
    
    for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if item:IsA("Tool") then
            return item
        end
    end
    return nil
end

local function toggleAutoSlap()
    IsAutoSlapping = not IsAutoSlapping
    if not IsAutoSlapping then return end

    task.spawn(function()
        while IsAutoSlapping do
            pcall(function()
                local tool = getSlapTool()
                if tool then
                    -- Nếu chưa cầm trên tay, script tự động lôi vũ khí ra cầm
                    if tool.Parent == LocalPlayer.Backpack then
                        tool.Parent = getCharacter()
                    end
                    -- Kích hoạt hành động tát (Vung tay liên tục)
                    tool:Activate()
                end
            end)
            task.wait(0.01) -- Cứ mỗi 0.01 giây sẽ tát một lần (cực nhanh)
        end
    end)
end

-- Lắng nghe phím bấm R để Tự động tát
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.R then
        toggleAutoSlap()
    end
end)

-- Thông báo cho bạn biết script đã chạy thành công
print("--- SCRIPT ĐÃ KÍCH HOẠT THÀNH CÔNG ---")
print("Bấm phím E trên bàn phím để BAY / HẠ CÁNH")
print("Bấm phím R trên bàn phím để BẬT / TẮT TỰ ĐỘNG TÁT")
