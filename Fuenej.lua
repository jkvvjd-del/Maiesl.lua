local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- ТОТАЛЬНАЯ ЖЕСТКАЯ ОЧИСТКА ВСЕГО МУСОРА ОТ ПРОШЛЫХ ЗАПУСКОВ
local function clearAllOldHatsGlobal()
    if player.Character then
        for _, obj in pairs(player.Character:GetDescendants()) do
            if obj.Name == "RainbowChinaHatPart" or obj.Name == "ComplexRainbowHat" or obj.Name == "HatBasePart" or obj:IsA("ConeHandleAdornment") then
                obj:Destroy()
            end
        end
    end
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "ComplexRainbowHat" or obj.Name == "RainbowChinaHatPart" then
            obj:Destroy()
        end
    end
end

-- Сносим старое сразу при старте
clearAllOldHatsGlobal()

-- Сборка одного идеального конуса по векторной математике
local function buildMathConeHat(character)
    clearAllOldHatsGlobal()
    
    local head = character:WaitForChild("Head", 5)
    if not head then return end

    -- НАСТРОЙКИ НАШЕГО ИДЕАЛЬНОГО КОНУСА
    local R = 1.35             -- Радиус основания
    local H = 0.55             -- Высота конуса
    local N = 450              -- 450 сегментов для идеальной гладкости
    local apexOverlap = 0.08   -- Нахлёст в самой верхней точке (чтобы не было дыры)
    local baseOverlap = 0.05   -- Нахлёст внизу
    local thickness = 0.02     -- Толщина стенок
    local heightOffset = 0.45  -- Посадка на голове

    -- Центр основания конуса
    local localCenterCFrame = CFrame.new(0, heightOffset, 0)

    -- Векторы вершины и нормали
    local A = Vector3.new(0, H, 0)
    local n = Vector3.new(0, 1, 0)

    -- Генерируем точки основания по кругу
    local B = {}
    for i = 0, N - 1 do
        local angle = (i / N) * math.pi * 2
        table.insert(B, Vector3.new(math.cos(angle) * R, 0, math.sin(angle) * R))
    end

    local hatParts = {}
    local relativeCFrames = {}

    -- МАТЕМАТИЧЕСКОЕ ПОСТРОЕНИЕ ЕДИНСТВЕННОГО ИДЕАЛЬНОГО СЛОЯ
    for i = 1, N do
        local b1 = B[i]
        local b2 = B[(i % N) + 1]

        local mBase = (b1 + b2) / 2
        local top = A + n * apexOverlap
        local bottom = mBase - n * baseOverlap
        local mid = (top + bottom) / 2

        local look = (top - mid).Unit
        local right = n:Cross(look).Unit
        local up = look:Cross(right).Unit

        local rotationMatrix = CFrame.fromMatrix(mid, right, up, look)

        local length = (top - bottom).Magnitude
        local width = (b2 - b1).Magnitude * 1.02

        local part = Instance.new("Part")
        part.Name = "ComplexRainbowHat"
        part.Material = Enum.Material.SmoothPlastic
        part.CanCollide = false
        part.Massless = true
        part.CastShadow = false
        part.Anchored = true
        part.Size = Vector3.new(width, thickness, length)

        part.Parent = character
        table.insert(hatParts, part)
        table.insert(relativeCFrames, rotationMatrix)
    end

    -- УЛЬТРА-ОПТИМИЗИРОВАННЫЙ ЦИКЛ РАДУГИ И ПРИВЯЗКИ К ГОЛОВЕ
    local speed = 0.5 -- Скорость радуги
    local loopConnection
    
    loopConnection = RunService.RenderStepped:Connect(function()
        if character and character.Parent and head and head.Parent then
            local hue = (tick() * speed) % 1
            local currentColor = Color3.fromHSV(hue, 1, 1)
            local headCFrame = head.CFrame

            -- Двигаем только наш один идеальный конус
            for index, part in pairs(hatParts) do
                if part and part.Parent then
                    part.CFrame = headCFrame * localCenterCFrame * relativeCFrames[index]
                    part.Color = currentColor
                end
            end
        else
            loopConnection:Disconnect()
        end
    end)
end

-- Моментальный запуск
if player.Character then
    buildMathConeHat(player.Character)
end

-- Пересборка при респавне
player.CharacterAdded:Connect(function(newCharacter)
    task.wait(0.3)
    buildMathConeHat(newCharacter)
end)
and
-- ============================================================================
-- АВТОНОМНЫЙ БЛОК ЭФФЕКТОВ: ВСТАВИТЬ В САМЫЙ КОНЕЦ СКРИПТА
-- ============================================================================
local effRunService = game:GetService("RunService")
local effRadius = 1.35        -- Ширина полей шляпы (расстояние между краями трейла)
local effTrueHatY = 1.75    -- Высота полей над центром торса (чтобы не из горла!)
local effConeHeight = 0.55  -- Высота конуса (для макушки)
local effSpeed = 0.5         -- Скорость радуги

local function applyFlatEffects(char)
    local root = char:WaitForChild("HumanoidRootPart")
    
    -- Полная очистка старых эффектов при респавне
    for _, obj in pairs(root:GetChildren()) do
        if obj.Name == "HatTop" or obj.Name == "HatLeft_Trail" or obj.Name == "HatRight_Trail" then
            obj:Destroy()
        end
	end
	
    -- Создаем точки крепления ровно на уровне полей шляпы
    local HatLeftAttachment = Instance.new("Attachment")
    HatLeftAttachment.Name = "HatLeft_Trail"
    HatLeftAttachment.Position = Vector3.new(-effRadius, effTrueHatY, 0)
    HatLeftAttachment.Parent = root

    local HatRightAttachment = Instance.new("Attachment")
    HatRightAttachment.Name = "HatRight_Trail"
    HatRightAttachment.Position = Vector3.new(effRadius, effTrueHatY, 0)
    HatRightAttachment.Parent = root

    local HatTopAttachment = Instance.new("Attachment")
    HatTopAttachment.Name = "HatTop"
    HatTopAttachment.Position = Vector3.new(0, effTrueHatY + effConeHeight, 0) 
    HatTopAttachment.Parent = root

    -- Настройка плоского горизонтального шлейфа (Trail)
    local RainbowTrail = Instance.new("Trail")
    RainbowTrail.Name = "RainbowTrail"
    RainbowTrail.Enabled = false
    RainbowTrail.Attachment0 = HatLeftAttachment  
    RainbowTrail.Attachment1 = HatRightAttachment 
    RainbowTrail.Lifetime = 0.4 
    RainbowTrail.LightEmission = 1
    RainbowTrail.WidthScale = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1.0), 
        NumberSequenceKeypoint.new(1, 0.0)  
    })
    RainbowTrail.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.05),
        NumberSequenceKeypoint.new(1, 1.0)
    })
    RainbowTrail.Parent = HatLeftAttachment

    -- Настройка радужных сфер (ParticleEmitter) из макушки
    local RainbowEmitter = Instance.new("ParticleEmitter")
    RainbowEmitter.Name = "RainbowEmitter"
    RainbowEmitter.Enabled = false 
    RainbowEmitter.Texture = "rbxassetid://243660364"
    RainbowEmitter.Speed = NumberRange.new(3, 7)
    RainbowEmitter.Lifetime = NumberRange.new(0.6, 1.0)
    RainbowEmitter.SpreadAngle = Vector2.new(360, 360)
    RainbowEmitter.Acceleration = Vector3.new(0, 4, 0) 
    RainbowEmitter.Drag = 2
    RainbowEmitter.RotSpeed = NumberRange.new(-180, 180)
    RainbowEmitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1.2), 
        NumberSequenceKeypoint.new(1, 0.0)
    })
    RainbowEmitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(1, 1.0)
    })
    RainbowEmitter.LightEmission = 1
    RainbowEmitter.Brightness = 2.5
    RainbowEmitter.Parent = HatTopAttachment

    -- Цикл обновления эффектов от ходьбы
    local effConnection
    effConnection = effRunService.RenderStepped:Connect(function()
        if not char or not char.Parent or not root.Parent then
            effConnection:Disconnect()
            return
        end
        
        -- Считаем радугу для эффектов независимо
        local effHue = (tick() * effSpeed) % 1
        local effColor = Color3.fromHSV(effHue, 1, 1)
        
        local cSeq = ColorSequence.new({
            ColorSequenceKeypoint.new(0.00, effColor),
            ColorSequenceKeypoint.new(0.33, Color3.fromHSV((effHue + 0.33) % 1, 1, 1)),
            ColorSequenceKeypoint.new(0.66, Color3.fromHSV((effHue + 0.66) % 1, 1, 1)),
            ColorSequenceKeypoint.new(1.00, effColor)
        })
        
        RainbowEmitter.Color = cSeq
        RainbowTrail.Color = cSeq
        
        -- Проверка движения
        if root.Velocity.Magnitude > 0.2 then
            RainbowEmitter.Enabled = true
            RainbowEmitter.Rate = math.clamp(root.Velocity.Magnitude * 35, 0, 400)
            RainbowTrail.Enabled = true
        else
            RainbowEmitter.Enabled = false
            RainbowEmitter.Rate = 0
            RainbowTrail.Enabled = false
        end
    end)
end

-- Автозапуск эффектов при старте скрипта и респавне (подвязываемся к твоей логике)
if player.Character then applyFlatEffects(player.Character) end
player.CharacterAdded:Connect(function(newChar)
    task.wait(0.4) -- Ждем чуть дольше, чтобы шляпа успела построиться
    applyFlatEffects(newChar)
end)
-- =============================================================================
-- ВАРИАНТ 1: ЭНЕРГЕТИЧЕСКИЕ КРЫЛЬЯ (Beam, слоями для объёма)
-- =========================================================================----
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local torsoName = character:FindFirstChild("UpperTorso") and "UpperTorso" or "Torso"
local torso = character:WaitForChild(torsoName)

----------------------------------------------------------------
-- 1. Снос старого мусора
----------------------------------------------------------------
local function cleanupOld()
	local old = character:FindFirstChild("EnergyWings")
	if old then old:Destroy() end
	for _, obj in ipairs(torso:GetChildren()) do
		if obj.Name:find("ShoulderAttach") or obj.Name:find("WingEndAttach") then
			obj:Destroy()
		end
	end
end
cleanupOld()

local wingsModel = Instance.new("Model")
wingsModel.Name = "EnergyWings"
wingsModel.Parent = character

----------------------------------------------------------------
-- 2. Параметры
----------------------------------------------------------------
local FEATHER_COUNT = 6
local BASE_LENGTH = 5.0
local FAN_SPREAD = 55

local activeBeams = {}      -- тонкие яркие "стержни"
local glowBeams = {}        -- широкие полупрозрачные "подсветы"
local wingEmitters = {}

----------------------------------------------------------------
-- 3. Сборка крыла
----------------------------------------------------------------
local function buildWing(side) -- 1 = правое, -1 = левое
	local shoulderAttach = Instance.new("Attachment")
	shoulderAttach.Name = "ShoulderAttach_" .. (side == 1 and "R" or "L")
	shoulderAttach.Position = Vector3.new(side * 0.45, 0.45, 0.55)
	shoulderAttach.Parent = torso

	local angleStep = FAN_SPREAD / (FEATHER_COUNT - 1)

	for i = 1, FEATHER_COUNT do
		local currentAngleDeg = -20 + (i - 1) * angleStep
		local rad = math.rad(currentAngleDeg)

		local length = BASE_LENGTH * (0.85 + math.sin(math.rad((i / FEATHER_COUNT) * 180)) * 0.25)
		if i == FEATHER_COUNT then length = BASE_LENGTH * 0.65 end

		local endX = side * (math.cos(rad) * length)
		local endY = math.sin(rad) * length + 0.5

		local endAttach = Instance.new("Attachment")
		endAttach.Name = "WingEndAttach_" .. (side == 1 and "R" or "L") .. "_" .. i
		endAttach.Position = shoulderAttach.Position + Vector3.new(endX, endY, -0.1 * i)
		endAttach.Parent = torso

		-- ШИРОКИЙ ПОДСВЕТ (создаёт объём, "мясо" крыла)
		local glow = Instance.new("Beam")
		glow.Attachment0 = shoulderAttach
		glow.Attachment1 = endAttach
		glow.Texture = ""
		glow.Segments = 10
		glow.Width0 = 2.2 * (1 - (i - 1) * 0.06)
		glow.Width1 = 0.6
		glow.LightEmission = 0.4
		glow.LightInfluence = 0
		glow.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.75),
			NumberSequenceKeypoint.new(1, 0.9),
		})
		glow.Parent = wingsModel
		table.insert(glowBeams, glow)

		-- ТОНКИЙ ЯРКИЙ СТЕРЖЕНЬ (даёт чёткость пера)
		local core = Instance.new("Beam")
		core.Attachment0 = shoulderAttach
		core.Attachment1 = endAttach
		core.Texture = ""
		core.Segments = 10
		core.Width0 = 0.5 * (1 - (i - 1) * 0.06)
		core.Width1 = 0.05
		core.LightEmission = 1
		core.LightInfluence = 0
		core.Transparency = NumberSequence.new(0.05)
		core.Parent = wingsModel
		table.insert(activeBeams, core)

		local sparkle = Instance.new("ParticleEmitter")
		sparkle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		sparkle.Rate = 5
		sparkle.Lifetime = NumberRange.new(0.3, 0.6)
		sparkle.Speed = NumberRange.new(0.2, 0.5)
		sparkle.Brightness = 8.0
		sparkle.LightEmission = 0.85
		sparkle.LightInfluence = 0
		sparkle.Size = NumberSequence.new(0.22)
		sparkle.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.2),
			NumberSequenceKeypoint.new(1, 1),
		})
		sparkle.Parent = endAttach
		table.insert(wingEmitters, sparkle)
	end
end

buildWing(1)
buildWing(-1)

----------------------------------------------------------------
-- 4. Радужная HSV-синхронизация
----------------------------------------------------------------
local hueTimer = 0

RunService.Heartbeat:Connect(function(dt)
	if not torso or not torso.Parent then return end

	hueTimer = (hueTimer + dt * 0.45) % 1
	local wingColor = Color3.fromHSV(hueTimer, 1, 1)

	for _, beam in ipairs(activeBeams) do
		if beam and beam.Parent then beam.Color = ColorSequence.new(wingColor) end
	end
	for _, glow in ipairs(glowBeams) do
		if glow and glow.Parent then glow.Color = ColorSequence.new(wingColor) end
	end
	for _, sparkle in ipairs(wingEmitters) do
		if sparkle and sparkle.Parent then sparkle.Color = ColorSequence.new(wingColor) end
	end
end)
-- Моментальный запуск эффектов при старте скрипта
if player.Character then
    task.spawn(applyFlatEffects, player.Character)
end

-- Пересборка эффектов при каждом респавне
player.CharacterAdded:Connect(function(newCharacter)
    task.wait(0.3)
    applyFlatEffects(newCharacter)
end)
