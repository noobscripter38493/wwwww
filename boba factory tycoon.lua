local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/noobscripter38493/orion/main/orionnnn.lua"))()
local window = lib:MakeWindow("Boba Factory Tycoon")

local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local character = plr.Character
local hrp = character:WaitForChild("HumanoidRootPart")

for i, v in getconnections(plr.Idled) do
    v:Disable()
end

local GameObjects = workspace.GameObjects
local Map = GameObjects.Map
local tycoons = GameObjects.Tycoons

local tycoon
local tycoon_name
for _, v in tycoons:GetChildren() do
	for _, v2 in v:GetDescendants() do
		if v2.Name == "Label" and v2:FindFirstAncestor("OwnerGui") then
			if v2.Text:find(plr.Name) then
				tycoon = v
                tycoon_name = v.Name
				break
			end
		end
	end

	if tycoon then
		break
	end
end

if not tycoon then
    for i, v in tycoons:GetChildren() do
        local touch = v.Gate.Touch
        if touch:FindFirstChild("TouchInterest") then
            tycoon = v
            tycoon_name = v.Name
            hrp.CFrame = touch.CFrame
            break
        end
    end
end

local prompts = {}
local doorbutton
local loadbutton
for i, v in tycoon:GetDescendants() do
    if v:IsA("ProximityPrompt") then
        local isdoorbutton = v:FindFirstAncestor("DoorButton")
        local isloadbutton = v:FindFirstAncestor("LoadButton")
        if isdoorbutton then
            doorbutton = isdoorbutton.Detail.Button.Top
            prompts["DoorButton"] = v

        elseif isloadbutton then
            loadbutton = isloadbutton.Detail.Button.Top
            prompts["LoadButton"] = v
        end
    end
end

local t
local data
for i, v in getgc() do
	if typeof(v) == "function" and islclosure(v) and not (isfluxusclosure or iskrnlclosure)(v) then
		if table.find(getconstants(v), "You don't have enough cash to rebirth!") then
			t = getupvalue(v, 1)
            data = t.data
            break
		end
	end
end

local dropperbuttons = tycoon.Buttons.DropperButtons
local rebirths = plr:WaitForChild("leaderstats").Rebirths
local needscrates = true
if data:GetKey("Cash") >= 100000 then
    needscrates = false
end

local upgraders = tycoon.Upgraders

local puttheseupgraders
local replace
local old
local function SetupUpgraders()
    puttheseupgraders = {
        ["1"] = 'Upgrader4',
        ["2"] = 'Upgrader4',
        ["3"] = 'ToiletUpgrader',
        ["4"] = 'CloudUpgrader',
        ["5"] = 'RubixCubeUpgrader',
        ["6"] = 'CeilingLightUpgrader',
        ["7"] = 'SugarUpgrader2',
        ["8"] = 'ForestUpgrader',
        ["9"] = 'VolleyballUpgrader'
    }
    
    replace = {
        ["1"] = "FridgeUpgrader",
        ["2"] = "LollipopUpgrader",
        ["7"] = "LavaCrystalUpgrader"
    }
    
    old = {}
    for i, v in replace do
        old[i] = puttheseupgraders[i]
    end
end

SetupUpgraders()

local network = require(game.ReplicatedStorage.Modules.util.network)

tycoons.ChildAdded:Connect(function(c)
    if c.Name == tycoon_name then
        tycoon = c
        upgraders = tycoon:WaitForChild("Upgraders")
        dropperbuttons = tycoon:WaitForChild("Buttons").DropperButtons
    
        SetupUpgraders()
    
        for i, v in tycoon:GetDescendants() do
            if v:IsA("ProximityPrompt") then
                local isdoorbutton = v:FindFirstAncestor("DoorButton")
                local isloadbutton = v:FindFirstAncestor("LoadButton")
                if isdoorbutton then
                    doorbutton = isdoorbutton.Detail.Button.Top
                    prompts["DoorButton"] = v
        
                elseif isloadbutton then
                    loadbutton = isloadbutton.Detail.Button.Top
                    prompts["LoadButton"] = v
                end
            end
        end
    
        needscrates = true
    end
end)

do
    local af = window:MakeTab("Autofarm")

    local doingobby
    local gettingcrates
    local automoney

    af:AddToggle({
        Name = "Auto Press Boba Buttons",
        Default = false,
        Callback = function(bool)
            automoney = bool

            while automoney do
                for i, v in prompts do
                    fireproximityprompt(v)
                end

                task.wait()
            end
        end
    })

    local autotp
    af:AddToggle({
        Name = "TP boba Buttons",
        Default = false,
        Callback = function(bool)
            autotp = bool
            
            while autotp do task.wait(1/3)
                pcall(function()
                    if not doorbutton.Parent.GuiPart.InfoGui.Frame.Time.Visible then
                        hrp.CFrame = doorbutton.CFrame
                    else
                        hrp.CFrame = loadbutton.CFrame
                    end
                end)
            end
        end
    })

    local autofood
    af:AddToggle({
        Name = "Auto Buy Foods",
        Default = false,
        Callback = function(bool)
            autofood = bool

            while autofood do
                for i, v in dropperbuttons:GetChildren() do
                    firetouchinterest(hrp, v.Top, 1)
                    firetouchinterest(hrp, v.Top, 0)
                end

                local unlocked = data:Get({"UnlockedItems", "Droppers"})
                for i, v in t.items.Droppers do
                    if not unlocked[i] and v.Cost >= 15000000 and data:GetKey("Cash") >= v.Cost then
                        network:FireServer("AttemptBuyDropper", i)
                        task.wait(1/2)
                    end
                end
        
                task.wait()
            end
        end
    })

    local autorebirth

    af:AddToggle({
        Name = "Auto Rebirth",
        Default = false,
        Callback = function(bool)
            autorebirth = bool

            while autorebirth do
                if data:GetKey("Cash") >= t.rebirthUtil.GetRebirthCost(data:GetKey("Rebirths")) then
                    network:FireServer("AttemptRebirth")
                end

                task.wait(1)
            end
        end
    })

    local autoupgrade
    af:AddToggle({
        Name = "Auto Upgrade",
        Default = false,
        Callback = function(bool)
            autoupgrade = bool

            while autoupgrade do task.wait()
                pcall(function()
                    local alreadygot = {}
                    for _, v in upgraders.Positions:GetChildren() do
                        for _, v2 in upgraders.Models:GetChildren() do
                            for i3, v3 in replace do
                                if v.Name == i3 and old[i3] == v2.Name then
                                    puttheseupgraders[i3] = v3
                                end
                            end

                            if replace[v.Name] then
                                continue
                            end

                            local p = v2:FindFirstChildWhichIsA("Part")
                            if not p then
                                continue
                            end

                            if (p.Position - v.Position).Magnitude <= 5 then
                                table.insert(alreadygot, v.Name)
                            end
                        end
                    end
                    
                    for i, v in puttheseupgraders do
                        if not table.find(alreadygot, i) then
                            network:FireServer("AttemptPlaceUpgrader", v, i)
                            task.wait(.5)
                        end
                    end
                end)
            end
        end
    })

    local autocrate
    local crates = GameObjects.Crates

    af:AddToggle({
        Name = "Auto Crate",
        Default = false,
        Callback = function(bool)
            autocrate = bool

            while autocrate do task.wait()
                if doingobby or not needscrates then
                    continue
                end

                if data:GetKey("Cash") > 100000 then
                    needscrates = false
                    continue
                end

                local oldcf = hrp.CFrame
                for i, v in crates:GetChildren() do
                    gettingcrates = true
                    local center = v:WaitForChild("Center", 3)
                    if not center then 
                        continue 
                    end

                    hrp.CFrame = center.CFrame
                    task.wait(1)
                end

                if gettingcrates then
                    hrp.CFrame = oldcf

                    task.wait(1)

                    gettingcrates = false
                end
            end
        end
    })

    local autoobby
    local obbies = Map.Obbies
    af:AddToggle({
        Name = "Auto Obby",
        Default = false,
        Callback = function(bool)
            autoobby = bool

            while autoobby do task.wait()
                if gettingcrates then
                    continue
                end

                local oldcf = hrp.CFrame
                for i, v in obbies:GetChildren() do
                    if not v.Sign.Block.CanCollide then
                        doingobby = true
                        hrp.CFrame = v.End.CFrame
                        task.wait(1)
                    end
                end

                if doingobby then
                    hrp.CFrame = oldcf
                    task.wait(1)
                    doingobby = false
                end
            end
        end
    })

    af:AddButton({
        Name = "Start Speedrun Mode",
        Callback = function()
            network:FireServer("AttemptActivateSpeedrun")
        end
    })
end