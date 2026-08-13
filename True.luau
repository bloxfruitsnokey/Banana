--[[ 
    Blox Fruits Auto Farm Script
    - Fixed truncated World 3 Quest Table
    - Cleared duplicate Fast Attack loops & junk variables
    - Fixed HumanoidRootPart loss on player respawn
--]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Disable Damage Highlight VFX
pcall(function()
	local Modules = ReplicatedStorage:WaitForChild("Modules", 10)
	if Modules then
		local CombatUtil = Modules:WaitForChild("CombatUtil", 10)
		if CombatUtil then
			local CU = require(CombatUtil)
			if type(CU) == "table" then
				CU.ApplyDamageHighlight = function() end
			end
		end
	end
end)

-- Character & HRP Reference Management
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart", 20)

LocalPlayer.CharacterAdded:Connect(function(char)
	Character = char
	HRP = char:WaitForChild("HumanoidRootPart", 20)
end)

-- World Identification
local PlaceId = game.PlaceId
local World1, World2, World3 = false, false, false

if PlaceId == 2753915549 or PlaceId == 85211729168715 then
	World1 = true
elseif PlaceId == 4442272183 or PlaceId == 79091703265657 then
	World2 = true
elseif PlaceId == 7449423635 or PlaceId == 100117331123089 then
	World3 = true
end

-- Loading Screen Check
repeat task.wait() until LocalPlayer.PlayerGui:WaitForChild("Main"):FindFirstChild("Loading") == nil or game:IsLoaded()

-- Global Configurations
getgenv().AutoFarm = getgenv().AutoFarm or false
getgenv().FastAttack = true

local SelectWeapon = "Melee"

-- Equip Weapon Utility
local function EquipWeapon(weaponType)
	local backpack = LocalPlayer:FindFirstChild("Backpack")
	local char = LocalPlayer.Character
	if not backpack or not char then return end
	
	for _, tool in ipairs(backpack:GetChildren()) do
		if tool:IsA("Tool") then
			if weaponType == "Sword" and tool.ToolTip == "Sword" then
				char.Humanoid:EquipTool(tool)
			elseif weaponType == "Melee" and tool.ToolTip == "Melee" then
				char.Humanoid:EquipTool(tool)
			elseif weaponType == "Blox Fruit" and tool.ToolTip == "Blox Fruit" then
				char.Humanoid:EquipTool(tool)
			elseif weaponType == "Gun" and tool.ToolTip == "Gun" then
				char.Humanoid:EquipTool(tool)
			end
		end
	end
end

-- Noclip & Anchor Part Setup
local AnchorPart = Instance.new("Part")
AnchorPart.Size = Vector3.new(1, 1, 1)
AnchorPart.Name = "Farm_AnchorPart"
AnchorPart.Anchored = true
AnchorPart.CanCollide = false
AnchorPart.Transparency = 1
AnchorPart.Parent = Workspace

task.spawn(function()
	while task.wait() do
		pcall(function()
			if getgenv().OnFarm and Character and HRP then
				AnchorPart.CFrame = HRP.CFrame
				for _, part in ipairs(Character:GetChildren()) do
					if part:IsA("BasePart") then
						part.CanCollide = false
					end
				end
			end
		end)
	end
end)

-- Fast Attack Module
local function FastAttackEngine()
	if not getgenv().FastAttack then return end
	local tool = Character and Character:FindFirstChildOfClass("Tool")
	if not tool then return end

	local netModule = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Net")
	if not netModule then return end

	local registerAttack = netModule:FindFirstChild("RE/RegisterAttack")
	local registerHit = netModule:FindFirstChild("RE/RegisterHit")

	if registerAttack and registerHit then
		local enemies = Workspace:FindFirstChild("Enemies")
		if enemies then
			for _, enemy in ipairs(enemies:GetChildren()) do
				local hum = enemy:FindFirstChild("Humanoid")
				local head = enemy:FindFirstChild("Head") or enemy:FindFirstChild("HumanoidRootPart")
				if hum and hum.Health > 0 and head then
					local dist = (head.Position - HRP.Position).Magnitude
					if dist <= 60 then
						registerAttack:FireServer()
						registerHit:FireServer(head, {{enemy, head}})
						break
					end
				end
			end
		end
	end
end

RunService.Heartbeat:Connect(function()
	if getgenv().OnFarm then
		pcall(FastAttackEngine)
	end
end)

-- Comprehensive Quest Database & Selector
function CheckQuest()
	local MyLevel = LocalPlayer.Data.Level.Value
	local QuestData = {}

	if World1 then
		if MyLevel >= 1 and MyLevel <= 9 then
			QuestData = {Mon = "Bandit", LevelQuest = 1, NameQuest = "BanditQuest1", NameMon = "Bandit", CFrameQuest = CFrame.new(1059.37, 15.44, 1550.42), CFrameMon = CFrame.new(1045.96, 27.00, 1560.82)}
		elseif MyLevel >= 10 and MyLevel <= 14 then
			QuestData = {Mon = "Monkey", LevelQuest = 1, NameQuest = "JungleQuest", NameMon = "Monkey", CFrameQuest = CFrame.new(-1598.08, 35.55, 153.37), CFrameMon = CFrame.new(-1448.51, 67.85, 11.46)}
		elseif MyLevel >= 15 and MyLevel <= 29 then
			QuestData = {Mon = "Gorilla", LevelQuest = 2, NameQuest = "JungleQuest", NameMon = "Gorilla", CFrameQuest = CFrame.new(-1598.08, 35.55, 153.37), CFrameMon = CFrame.new(-1129.88, 40.46, -525.42)}
		elseif MyLevel >= 30 and MyLevel <= 39 then
			QuestData = {Mon = "Pirate", LevelQuest = 1, NameQuest = "BuggyQuest1", NameMon = "Pirate", CFrameQuest = CFrame.new(-1141.07, 4.10, 3831.54), CFrameMon = CFrame.new(-1103.51, 13.75, 3896.09)}
		elseif MyLevel >= 40 and MyLevel <= 59 then
			QuestData = {Mon = "Brute", LevelQuest = 2, NameQuest = "BuggyQuest1", NameMon = "Brute", CFrameQuest = CFrame.new(-1141.07, 4.10, 3831.54), CFrameMon = CFrame.new(-1140.08, 14.80, 4322.92)}
		elseif MyLevel >= 60 and MyLevel <= 74 then
			QuestData = {Mon = "Desert Bandit", LevelQuest = 1, NameQuest = "DesertQuest", NameMon = "Desert Bandit", CFrameQuest = CFrame.new(894.48, 5.14, 4392.43), CFrameMon = CFrame.new(924.79, 6.44, 4481.58)}
		elseif MyLevel >= 75 and MyLevel <= 89 then
			QuestData = {Mon = "Desert Officer", LevelQuest = 2, NameQuest = "DesertQuest", NameMon = "Desert Officer", CFrameQuest = CFrame.new(894.48, 5.14, 4392.43), CFrameMon = CFrame.new(1608.28, 8.61, 4371.00)}
		elseif MyLevel >= 90 and MyLevel <= 99 then
			QuestData = {Mon = "Snow Bandit", LevelQuest = 1, NameQuest = "SnowQuest", NameMon = "Snow Bandit", CFrameQuest = CFrame.new(1389.74, 88.15, -1298.90), CFrameMon = CFrame.new(1354.34, 87.27, -1393.94)}
		elseif MyLevel >= 100 and MyLevel <= 119 then
			QuestData = {Mon = "Snowman", LevelQuest = 2, NameQuest = "SnowQuest", NameMon = "Snowman", CFrameQuest = CFrame.new(1389.74, 88.15, -1298.90), CFrameMon = CFrame.new(1201.64, 144.57, -1550.06)}
		elseif MyLevel >= 120 and MyLevel <= 149 then
			QuestData = {Mon = "Chief Petty Officer", LevelQuest = 1, NameQuest = "MarineQuest2", NameMon = "Chief Petty Officer", CFrameQuest = CFrame.new(-5039.58, 27.35, 4324.68), CFrameMon = CFrame.new(-4881.23, 22.65, 4273.75)}
		elseif MyLevel >= 150 and MyLevel <= 174 then
			QuestData = {Mon = "Sky Bandit", LevelQuest = 1, NameQuest = "SkyQuest", NameMon = "Sky Bandit", CFrameQuest = CFrame.new(-4839.53, 716.36, -2619.44), CFrameMon = CFrame.new(-4953.20, 295.74, -2899.22)}
		elseif MyLevel >= 175 and MyLevel <= 189 then
			QuestData = {Mon = "Dark Master", LevelQuest = 2, NameQuest = "SkyQuest", NameMon = "Dark Master", CFrameQuest = CFrame.new(-4839.53, 716.36, -2619.44), CFrameMon = CFrame.new(-5259.84, 391.39, -2229.03)}
		elseif MyLevel >= 190 and MyLevel <= 209 then
			QuestData = {Mon = "Prisoner", LevelQuest = 1, NameQuest = "PrisonerQuest", NameMon = "Prisoner", CFrameQuest = CFrame.new(5308.93, 1.65, 475.12), CFrameMon = CFrame.new(5098.97, -0.32, 474.23)}
		elseif MyLevel >= 210 and MyLevel <= 249 then
			QuestData = {Mon = "Dangerous Prisoner", LevelQuest = 2, NameQuest = "PrisonerQuest", NameMon = "Dangerous Prisoner", CFrameQuest = CFrame.new(5308.93, 1.65, 475.12), CFrameMon = CFrame.new(5654.56, 15.63, 866.29)}
		elseif MyLevel >= 250 and MyLevel <= 274 then
			QuestData = {Mon = "Toga Warrior", LevelQuest = 1, NameQuest = "ColosseumQuest", NameMon = "Toga Warrior", CFrameQuest = CFrame.new(-1580.04, 6.35, -2986.47), CFrameMon = CFrame.new(-1820.21, 51.68, -2740.66)}
		elseif MyLevel >= 275 and MyLevel <= 299 then
			QuestData = {Mon = "Gladiator", LevelQuest = 2, NameQuest = "ColosseumQuest", NameMon = "Gladiator", CFrameQuest = CFrame.new(-1580.04, 6.35, -2986.47), CFrameMon = CFrame.new(-1292.83, 56.38, -3339.03)}
		elseif MyLevel >= 300 and MyLevel <= 324 then
			QuestData = {Mon = "Military Soldier", LevelQuest = 1, NameQuest = "MagmaQuest", NameMon = "Military Soldier", CFrameQuest = CFrame.new(-5313.37, 10.95, 8515.29), CFrameMon = CFrame.new(-5411.16, 11.08, 8454.29)}
		elseif MyLevel >= 325 and MyLevel <= 374 then
			QuestData = {Mon = "Military Spy", LevelQuest = 2, NameQuest = "MagmaQuest", NameMon = "Military Spy", CFrameQuest = CFrame.new(-5313.37, 10.95, 8515.29), CFrameMon = CFrame.new(-5802.86, 86.26, 8828.85)}
		elseif MyLevel >= 375 and MyLevel <= 399 then
			QuestData = {Mon = "Fishman Warrior", LevelQuest = 1, NameQuest = "FishmanQuest", NameMon = "Fishman Warrior", CFrameQuest = CFrame.new(61122.65, 18.49, 1569.39), CFrameMon = CFrame.new(60878.30, 18.48, 1543.75)}
		elseif MyLevel >= 400 and MyLevel <= 449 then
			QuestData = {Mon = "Fishman Commando", LevelQuest = 2, NameQuest = "FishmanQuest", NameMon = "Fishman Commando", CFrameQuest = CFrame.new(61122.65, 18.49, 1569.39), CFrameMon = CFrame.new(61922.63, 18.48, 1493.93)}
		elseif MyLevel >= 450 and MyLevel <= 474 then
			QuestData = {Mon = "God's Guard", LevelQuest = 1, NameQuest = "SkyExp1Quest", NameMon = "God's Guard", CFrameQuest = CFrame.new(-4721.88, 843.87, -1949.96), CFrameMon = CFrame.new(-4710.04, 845.27, -1927.30)}
		elseif MyLevel >= 475 and MyLevel <= 524 then
			QuestData = {Mon = "Shanda", LevelQuest = 2, NameQuest = "SkyExp1Quest", NameMon = "Shanda", CFrameQuest = CFrame.new(-7859.09, 5544.19, -381.47), CFrameMon = CFrame.new(-7678.48, 5566.40, -497.21)}
		elseif MyLevel >= 525 and MyLevel <= 549 then
			QuestData = {Mon = "Royal Squad", LevelQuest = 1, NameQuest = "SkyExp2Quest", NameMon = "Royal Squad", CFrameQuest = CFrame.new(-7906.81, 5634.66, -1411.99), CFrameMon = CFrame.new(-7624.25, 5658.13, -1467.35)}
		elseif MyLevel >= 550 and MyLevel <= 624 then
			QuestData = {Mon = "Royal Soldier", LevelQuest = 2, NameQuest = "SkyExp2Quest", NameMon = "Royal Soldier", CFrameQuest = CFrame.new(-7906.81, 5634.66, -1411.99), CFrameMon = CFrame.new(-7836.75, 5645.66, -1790.62)}
		elseif MyLevel >= 625 and MyLevel <= 649 then
			QuestData = {Mon = "Galley Pirate", LevelQuest = 1, NameQuest = "FountainQuest", NameMon = "Galley Pirate", CFrameQuest = CFrame.new(5259.81, 37.35, 4050.02), CFrameMon = CFrame.new(5551.02, 78.90, 3930.41)}
		elseif MyLevel >= 650 then
			QuestData = {Mon = "Galley Captain", LevelQuest = 2, NameQuest = "FountainQuest", NameMon = "Galley Captain", CFrameQuest = CFrame.new(5259.81, 37.35, 4050.02), CFrameMon = CFrame.new(5441.95, 42.50, 4950.09)}
		end

	elseif World2 then
		if MyLevel >= 700 and MyLevel <= 724 then
			QuestData = {Mon = "Raider", LevelQuest = 1, NameQuest = "Area1Quest", NameMon = "Raider", CFrameQuest = CFrame.new(-429.54, 71.76, 1836.18), CFrameMon = CFrame.new(-728.32, 52.77, 2345.77)}
		elseif MyLevel >= 725 and MyLevel <= 774 then
			QuestData = {Mon = "Mercenary", LevelQuest = 2, NameQuest = "Area1Quest", NameMon = "Mercenary", CFrameQuest = CFrame.new(-429.54, 71.76, 1836.18), CFrameMon = CFrame.new(-1004.32, 80.15, 1424.61)}
		elseif MyLevel >= 775 and MyLevel <= 799 then
			QuestData = {Mon = "Swan Pirate", LevelQuest = 1, NameQuest = "Area2Quest", NameMon = "Swan Pirate", CFrameQuest = CFrame.new(638.43, 71.76, 918.28), CFrameMon = CFrame.new(1068.66, 137.61, 1322.10)}
		elseif MyLevel >= 800 and MyLevel <= 874 then
			QuestData = {Mon = "Factory Staff", LevelQuest = 2, NameQuest = "Area2Quest", NameMon = "Factory Staff", CFrameQuest = CFrame.new(632.69, 73.10, 918.66), CFrameMon = CFrame.new(73.07, 81.86, -27.47)}
		elseif MyLevel >= 875 and MyLevel <= 899 then
			QuestData = {Mon = "Marine Lieutenant", LevelQuest = 1, NameQuest = "MarineQuest3", NameMon = "Marine Lieutenant", CFrameQuest = CFrame.new(-2440.79, 71.71, -3216.06), CFrameMon = CFrame.new(-2821.37, 75.89, -3070.08)}
		elseif MyLevel >= 900 and MyLevel <= 949 then
			QuestData = {Mon = "Marine Captain", LevelQuest = 2, NameQuest = "MarineQuest3", NameMon = "Marine Captain", CFrameQuest = CFrame.new(-2440.79, 71.71, -3216.06), CFrameMon = CFrame.new(-1861.23, 80.17, -3254.69)}
		elseif MyLevel >= 950 and MyLevel <= 974 then
			QuestData = {Mon = "Zombie", LevelQuest = 1, NameQuest = "ZombieQuest", NameMon = "Zombie", CFrameQuest = CFrame.new(-5497.06, 47.59, -795.23), CFrameMon = CFrame.new(-5657.77, 78.96, -928.68)}
		elseif MyLevel >= 975 and MyLevel <= 999 then
			QuestData = {Mon = "Vampire", LevelQuest = 2, NameQuest = "ZombieQuest", NameMon = "Vampire", CFrameQuest = CFrame.new(-5497.06, 47.59, -795.23), CFrameMon = CFrame.new(-6037.66, 32.18, -1340.65)}
		elseif MyLevel >= 1000 and MyLevel <= 1049 then
			QuestData = {Mon = "Snow Trooper", LevelQuest = 1, NameQuest = "SnowMountainQuest", NameMon = "Snow Trooper", CFrameQuest = CFrame.new(609.85, 400.11, -5372.25), CFrameMon = CFrame.new(549.14, 427.38, -5563.69)}
		elseif MyLevel >= 1050 and MyLevel <= 1099 then
			QuestData = {Mon = "Winter Warrior", LevelQuest = 2, NameQuest = "SnowMountainQuest", NameMon = "Winter Warrior", CFrameQuest = CFrame.new(609.85, 400.11, -5372.25), CFrameMon = CFrame.new(1142.74, 475.63, -5199.41)}
		elseif MyLevel >= 1100 and MyLevel <= 1124 then
			QuestData = {Mon = "Lab Subordinate", LevelQuest = 1, NameQuest = "IceSideQuest", NameMon = "Lab Subordinate", CFrameQuest = CFrame.new(-6064.06, 15.24, -4902.97), CFrameMon = CFrame.new(-5707.47, 15.95, -4513.39)}
		elseif MyLevel >= 1125 and MyLevel <= 1174 then
			QuestData = {Mon = "Horned Warrior", LevelQuest = 2, NameQuest = "IceSideQuest", NameMon = "Horned Warrior", CFrameQuest = CFrame.new(-6064.06, 15.24, -4902.97), CFrameMon = CFrame.new(-6341.36, 15.95, -5723.16)}
		elseif MyLevel >= 1175 and MyLevel <= 1199 then
			QuestData = {Mon = "Magma Ninja", LevelQuest = 1, NameQuest = "FireSideQuest", NameMon = "Magma Ninja", CFrameQuest = CFrame.new(-5428.03, 15.06, -5299.43), CFrameMon = CFrame.new(-5449.67, 76.65, -5808.20)}
		elseif MyLevel >= 1200 and MyLevel <= 1249 then
			QuestData = {Mon = "Lava Pirate", LevelQuest = 2, NameQuest = "FireSideQuest", NameMon = "Lava Pirate", CFrameQuest = CFrame.new(-5428.03, 15.06, -5299.43), CFrameMon = CFrame.new(-5213.33, 49.73, -4701.45)}
		elseif MyLevel >= 1250 and MyLevel <= 1274 then
			QuestData = {Mon = "Ship Deckhand", LevelQuest = 1, NameQuest = "ShipQuest1", NameMon = "Ship Deckhand", CFrameQuest = CFrame.new(1037.80, 125.09, 32911.60), CFrameMon = CFrame.new(1212.01, 150.79, 33059.24)}
		elseif MyLevel >= 1275 and MyLevel <= 1299 then
			QuestData = {Mon = "Ship Engineer", LevelQuest = 2, NameQuest = "ShipQuest1", NameMon = "Ship Engineer", CFrameQuest = CFrame.new(1037.80, 125.09, 32911.60), CFrameMon = CFrame.new(919.47, 43.54, 32779.96)}
		elseif MyLevel >= 1300 and MyLevel <= 1324 then
			QuestData = {Mon = "Ship Steward", LevelQuest = 1, NameQuest = "ShipQuest2", NameMon = "Ship Steward", CFrameQuest = CFrame.new(968.80, 125.09, 33244.12), CFrameMon = CFrame.new(919.43, 129.55, 33436.03)}
		elseif MyLevel >= 1325 and MyLevel <= 1349 then
			QuestData = {Mon = "Ship Officer", LevelQuest = 2, NameQuest = "ShipQuest2", NameMon = "Ship Officer", CFrameQuest = CFrame.new(968.80, 125.09, 33244.12), CFrameMon = CFrame.new(1036.01, 181.43, 33315.72)}
		elseif MyLevel >= 1350 and MyLevel <= 1374 then
			QuestData = {Mon = "Arctic Warrior", LevelQuest = 1, NameQuest = "FrostQuest", NameMon = "Arctic Warrior", CFrameQuest = CFrame.new(5667.65, 26.79, -6486.08), CFrameMon = CFrame.new(5966.24, 62.97, -6179.38)}
		elseif MyLevel >= 1375 and MyLevel <= 1424 then
			QuestData = {Mon = "Snow Lurker", LevelQuest = 2, NameQuest = "FrostQuest", NameMon = "Snow Lurker", CFrameQuest = CFrame.new(5667.65, 26.79, -6486.08), CFrameMon = CFrame.new(5407.07, 69.19, -6880.88)}
		elseif MyLevel >= 1425 and MyLevel <= 1449 then
			QuestData = {Mon = "Sea Soldier", LevelQuest = 1, NameQuest = "ForgottenQuest", NameMon = "Sea Soldier", CFrameQuest = CFrame.new(-3054.44, 235.54, -10142.81), CFrameMon = CFrame.new(-3028.22, 64.67, -9775.42)}
		elseif MyLevel >= 1450 then
			QuestData = {Mon = "Water Fighter", LevelQuest = 2, NameQuest = "ForgottenQuest", NameMon = "Water Fighter", CFrameQuest = CFrame.new(-3054.00, 240.00, -10146.00), CFrameMon = CFrame.new(-3291.00, 252.00, -10501.00)}
		end

	elseif World3 then
		if MyLevel >= 1500 and MyLevel <= 1524 then
			QuestData = {Mon = "Pirate Millionaire", LevelQuest = 1, NameQuest = "PiratePortQuest", NameMon = "Pirate Millionaire", CFrameQuest = CFrame.new(-290.07, 42.90, 5581.58), CFrameMon = CFrame.new(-245.99, 47.30, 5584.10)}
		elseif MyLevel >= 1525 and MyLevel <= 1574 then
			QuestData = {Mon = "Pistol Billionaire", LevelQuest = 2, NameQuest = "PiratePortQuest", NameMon = "Pistol Billionaire", CFrameQuest = CFrame.new(-290.07, 42.90, 5581.58), CFrameMon = CFrame.new(-723.43, 147.42, 5931.99)}
		elseif MyLevel >= 1575 and MyLevel <= 1599 then
			QuestData = {Mon = "Dragon Crew Warrior", LevelQuest = 1, NameQuest = "AmazonQuest", NameMon = "Dragon Crew Warrior", CFrameQuest = CFrame.new(5832.83, 51.68, -1101.51), CFrameMon = CFrame.new(6594.00, 383.00, 139.00)}
		elseif MyLevel >= 1600 and MyLevel <= 1624 then
			QuestData = {Mon = "Dragon Crew Archer", LevelQuest = 2, NameQuest = "AmazonQuest", NameMon = "Dragon Crew Archer", CFrameQuest = CFrame.new(5832.83, 51.68, -1101.51), CFrameMon = CFrame.new(6625.00, 378.00, 244.00)}
		elseif MyLevel >= 1625 and MyLevel <= 1649 then
			QuestData = {Mon = "Female Islander", LevelQuest = 1, NameQuest = "AmazonQuest2", NameMon = "Female Islander", CFrameQuest = CFrame.new(5446.87, 601.62, 749.45), CFrameMon = CFrame.new(4692.79, 797.97, 858.84)}
		elseif MyLevel >= 1650 and MyLevel <= 1699 then
			QuestData = {Mon = "Giant Islander", LevelQuest = 2, NameQuest = "AmazonQuest2", NameMon = "Giant Islander", CFrameQuest = CFrame.new(5446.87, 601.62, 749.45), CFrameMon = CFrame.new(4902.00, 670.00, 39.00)}
		elseif MyLevel >= 1700 and MyLevel <= 1724 then
			QuestData = {Mon = "Marine Commodore", LevelQuest = 1, NameQuest = "MarineTreeIsland", NameMon = "Marine Commodore", CFrameQuest = CFrame.new(2180.54, 27.81, -6741.51), CFrameMon = CFrame.new(2401.00, 123.00, -7589.00)}
		elseif MyLevel >= 1725 and MyLevel <= 1774 then
			QuestData = {Mon = "Marine Rear Admiral", LevelQuest = 2, NameQuest = "MarineTreeIsland", NameMon = "Marine Rear Admiral", CFrameQuest = CFrame.new(2180.54, 27.81, -6741.51), CFrameMon = CFrame.new(3588.00, 229.00, -7085.00)}
		elseif MyLevel >= 1775 and MyLevel <= 1799 then
			QuestData = {Mon = "Fishman Raider", LevelQuest = 1, NameQuest = "DeepForestIsland1", NameMon = "Fishman Raider", CFrameQuest = CFrame.new(-10581.65, 331.78, -8758.21), CFrameMon = CFrame.new(-10941.00, 332.00, -8760.00)}
		elseif MyLevel >= 1800 and MyLevel <= 1824 then
			QuestData = {Mon = "Fishman Captain", LevelQuest = 2, NameQuest = "DeepForestIsland1", NameMon = "Fishman Captain", CFrameQuest = CFrame.new(-10581.65, 331.78, -8758.21), CFrameMon = CFrame.new(-11035.00, 332.00, -9087.00)}
		elseif MyLevel >= 1825 and MyLevel <= 1849 then
			QuestData = {Mon = "Forest Pirate", LevelQuest = 1, NameQuest = "DeepForestIsland2", NameMon = "Forest Pirate", CFrameQuest = CFrame.new(-13234.04, 331.78, -7625.40), CFrameMon = CFrame.new(-13446.00, 413.00, -7760.00)}
		elseif MyLevel >= 1850 and MyLevel <= 1899 then
			QuestData = {Mon = "Mythological Pirate", LevelQuest = 2, NameQuest = "DeepForestIsland2", NameMon = "Mythological Pirate", CFrameQuest = CFrame.new(-13234.04, 331.78, -7625.40), CFrameMon = CFrame.new(-13510.00, 584.00, -6987.00)}
		elseif MyLevel >= 1900 and MyLevel <= 1924 then
			QuestData = {Mon = "Jungle Pirate", LevelQuest = 1, NameQuest = "DeepForestIsland3", NameMon = "Jungle Pirate", CFrameQuest = CFrame.new(-12680.38, 389.97, -9902.01), CFrameMon = CFrame.new(-11778.00, 426.00, -10592.00)}
		elseif MyLevel >= 1925 and MyLevel <= 1974 then
			QuestData = {Mon = "Musketeer Pirate", LevelQuest = 2, NameQuest = "DeepForestIsland3", NameMon = "Musketeer Pirate", CFrameQuest = CFrame.new(-12680.38, 389.97, -9902.01), CFrameMon = CFrame.new(-13282.00, 496.00, -9565.00)}
		elseif MyLevel >= 1975 and MyLevel <= 1999 then
			QuestData = {Mon = "Reborn Skeleton", LevelQuest = 1, NameQuest = "HauntedQuest1", NameMon = "Reborn Skeleton", CFrameQuest = CFrame.new(-9479.21, 141.21, 5566.09), CFrameMon = CFrame.new(-8764.00, 142.00, 5963.00)}
		elseif MyLevel >= 2000 and MyLevel <= 2024 then
			QuestData = {Mon = "Living Zombie", LevelQuest = 2, NameQuest = "HauntedQuest1", NameMon = "Living Zombie", CFrameQuest = CFrame.new(-9479.21, 141.21, 5566.09), CFrameMon = CFrame.new(-10227.00, 421.00, 6161.00)}
		elseif MyLevel >= 2025 and MyLevel <= 2049 then
			QuestData = {Mon = "Demonic Soul", LevelQuest = 1, NameQuest = "HauntedQuest2", NameMon = "Demonic Soul", CFrameQuest = CFrame.new(-9516.99, 172.01, 6078.46), CFrameMon = CFrame.new(-9579.00, 6.00, 6194.00)}
		elseif MyLevel >= 2050 and MyLevel <= 2074 then
			QuestData = {Mon = "Posessed Mummy", LevelQuest = 2, NameQuest = "HauntedQuest2", NameMon = "Posessed Mummy", CFrameQuest = CFrame.new(-9516.99, 172.01, 6078.46), CFrameMon = CFrame.new(-9579.00, 6.00, 6194.00)}
		elseif MyLevel >= 2075 and MyLevel <= 2099 then
			QuestData = {Mon = "Peanut Scout", LevelQuest = 1, NameQuest = "NutsIslandQuest", NameMon = "Peanut Scout", CFrameQuest = CFrame.new(-2104.39, 38.10, -10192.56), CFrameMon = CFrame.new(-1993.00, 187.00, -10103.00)}
		elseif MyLevel >= 2100 and MyLevel <= 2124 then
			QuestData = {Mon = "Peanut President", LevelQuest = 2, NameQuest = "NutsIslandQuest", NameMon = "Peanut President", CFrameQuest = CFrame.new(-2104.39, 38.10, -10192.56), CFrameMon = CFrame.new(-2215.00, 159.00, -10474.00)}
		elseif MyLevel >= 2125 and MyLevel <= 2149 then
			QuestData = {Mon = "Ice Cream Chef", LevelQuest = 1, NameQuest = "IceCreamIslandQuest", NameMon = "Ice Cream Chef", CFrameQuest = CFrame.new(-820.64, 65.81, -10965.79), CFrameMon = CFrame.new(-877.00, 118.00, -11032.00)}
		elseif MyLevel >= 2150 and MyLevel <= 2199 then
			QuestData = {Mon = "Ice Cream Commander", LevelQuest = 2, NameQuest = "IceCreamIslandQuest", NameMon = "Ice Cream Commander", CFrameQuest = CFrame.new(-820.64, 65.81, -10965.79), CFrameMon = CFrame.new(-877.00, 118.00, -11032.00)}
		elseif MyLevel >= 2200 and MyLevel <= 2224 then
			QuestData = {Mon = "Cookie Crafter", LevelQuest = 1, NameQuest = "CakeQuest1", NameMon = "Cookie Crafter", CFrameQuest = CFrame.new(-2023.77, 37.79, -12025.22), CFrameMon = CFrame.new(-2021.00, 38.00, -12028.00)}
		elseif MyLevel >= 2225 and MyLevel <= 2249 then
			QuestData = {Mon = "Cake Guard", LevelQuest = 2, NameQuest = "CakeQuest1", NameMon = "Cake Guard", CFrameQuest = CFrame.new(-2023.77, 37.79, -12025.22), CFrameMon = CFrame.new(-2024.00, 38.00, -12026.00)}
		elseif MyLevel >= 2250 and MyLevel <= 2299 then
			QuestData = {Mon = "Baking Staff", LevelQuest = 1, NameQuest = "CakeQuest2", NameMon = "Baking Staff", CFrameQuest = CFrame.new(-1927.41, 37.79, -12842.83), CFrameMon = CFrame.new(-1932.00, 38.00, -12848.00)}
		elseif MyLevel >= 2300 and MyLevel <= 2324 then
			QuestData = {Mon = "Head Baker", LevelQuest = 2, NameQuest = "CakeQuest2", NameMon = "Head Baker", CFrameQuest = CFrame.new(-1927.41, 37.79, -12842.83), CFrameMon = CFrame.new(-1932.00, 38.00, -12848.00)}
		elseif MyLevel >= 2325 and MyLevel <= 2374 then
			QuestData = {Mon = "Cocoa Warrior", LevelQuest = 1, NameQuest = "ChocQuest1", NameMon = "Cocoa Warrior", CFrameQuest = CFrame.new(231.75, 23.83, -12199.85), CFrameMon = CFrame.new(95.00, 73.00, -12309.00)}
		elseif MyLevel >= 2375 and MyLevel <= 2399 then
			QuestData = {Mon = "Chocolate Bar Battler", LevelQuest = 2, NameQuest = "ChocQuest1", NameMon = "Chocolate Bar Battler", CFrameQuest = CFrame.new(231.75, 23.83, -12199.85), CFrameMon = CFrame.new(647.00, 42.00, -12401.00)}
		elseif MyLevel >= 2400 and MyLevel <= 2424 then
			QuestData = {Mon = "Sweet Thief", LevelQuest = 1, NameQuest = "ChocQuest2", NameMon = "Sweet Thief", CFrameQuest = CFrame.new(151.29, 23.83, -12774.65), CFrameMon = CFrame.new(116.00, 36.00, -12478.00)}
		elseif MyLevel >= 2425 then
			QuestData = {Mon = "Candy Rebel", LevelQuest = 2, NameQuest = "ChocQuest2", NameMon = "Candy Rebel", CFrameQuest = CFrame.new(151.29, 23.83, -12774.65), CFrameMon = CFrame.new(47.00, 61.00, -12889.00)}
		end
	end

	return QuestData
end

print("[Blox Fruits Script] Successfully loaded and execution completed!")
