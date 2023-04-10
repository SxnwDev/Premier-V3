-- Game variables
local Players = game:GetService('Players')
local CoreGui = game:GetService('CoreGui')
local UserInputService = game:GetService('UserInputService')
local VirtualUser = game:service('VirtualUser')
local RunService = game:GetService('RunService')
local ContextActionService = game:GetService('ContextActionService')
local HttpService = game:GetService('HttpService')
local TextService = game:GetService('TextService')
local Workspace = game:GetService('Workspace')
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
-- Library
local Library = {
	Page = {},
	Section = {},

    Settings = {
        Notifications = true,
        Public = true,

        Lang = 'en', -- es
        DarkMode = false,
        SmallVersion = false,
        Prefix = Enum.KeyCode.Home,

        Parent = CoreGui,
        Name = 'Snxw',

        HWID = game:GetService('RbxAnalyticsService'):GetClientId()
    },
    User = {
        IsPremium = true,
        IsDeveloper = true
    }
}

if not isfolder(Library.Settings.Name) then
    makefolder(Library.Settings.Name)
end
-- Theme colors
local Theme = {
    Dark = {
        Background = Color3.fromRGB(18, 25, 33),
        Contrast = Color3.fromRGB(22, 30, 40),
        Accent = Color3.fromRGB(0, 105, 250),
        TextColor = Color3.fromRGB(255, 255, 255),
        Grey = Color3.fromRGB(102, 110, 120)
    },
    Light = {
        Background = Color3.fromRGB(249, 249, 249),
        Contrast = Color3.fromRGB(230, 230, 230),
        Accent = Color3.fromRGB(0, 105, 250),
        TextColor = Color3.new(0, 0, 0),
        Grey = Color3.fromRGB(100, 100, 100)
    }
}
local instancesColor3 = {}

--#region Functions
function findByValue(t, value, Case_Sensitive)
    for i, v in pairs(t) do
        if Case_Sensitive and v == value and ((typeof(v) == 'string' and v:lower()) == (typeof(value) == 'string' and value:lower())) then
            return i
        end
    end
end
function findByIndex(t, value, Case_Sensitive)
    for i, v in pairs(t) do
        if Case_Sensitive and i == value or ((typeof(i) == 'string' and i:lower()) == (typeof(value) == 'string' and value:lower()))then
            return v
        end
    end
end
function WaitForAttribute(Object, AttributeName, MaxTime)
    MaxTime = MaxTime or 0.1
    Time = 0
    while Time < MaxTime do Time += task.wait()
        if Object:GetAttribute(AttributeName) then
            break
        end
    end
    return Object:GetAttribute(AttributeName)
end
function create(className, properties, childrens)
    local object = Instance.new(className)
    if pcall(function()
        return object.Image
    end) then
        create('Frame', {
            Parent = object,
            BackgroundColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].Accent,
            Visible = not object.IsLoaded,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 10, 0, 10),
            CornerRadius = UDim.new(0, 3),
            Function = function(frame)
                pcall(function()
                    local tween = Tween(frame, { BackgroundTransparency = 1 }, 0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, true, 0)
                    repeat task.wait() until frame.Parent and frame.Parent.IsLoaded
                    frame.Visible = false
                    tween:Cancel()
                end)
            end
        })
    end
    for i, v in pairs(properties or {}) do
        if typeof(v) == 'Color3' then
            instancesColor3[i] = instancesColor3[i] or {}
            table.insert(instancesColor3[i], object)
        end

        if i == 'Function' then
            task.spawn(function()
                if properties and properties.Parent then
                    repeat task.wait() until object.Parent
                end
                v(object)
            end)
        elseif i == 'CornerRadius' and className ~= 'UICorner' then
            create('UICorner', {
                Parent = object,
                CornerRadius = v
            })
        elseif i == 'Padding' and string.sub(className, 1, 2) ~= 'UI' then
            if typeof(v) ~= 'table' then
                local a = {
                    Top = v,
                    Bottom = v,
                    Left = v,
                    Right = v,
                }
                v = a
            end
            create('UIPadding', {
                Parent = object,
                PaddingTop = v.Top,
                PaddingBottom = v.Bottom,
                PaddingLeft = v.Left,
                PaddingRight = v.Right,
            })
        elseif i == 'Stroke' and pcall(function()
            local a = object.Text
        end) then
            local stroke = create('UIStroke', {
                Parent = object,
                Color = object.TextColor3,
                Thickness = v
            })
            object:GetPropertyChangedSignal('TextColor3'):Connect(function()
                stroke.Color = object.TextColor3
            end)
        else
            local success, _ = pcall(function()
                object[i] = v
            end)
            if not success then
                if typeof(v) == 'function' then
                    _G[tostring(v)] = v
                end
                object:SetAttribute(i, typeof(v) == 'function' and tostring(v) or v)
            end
        end
    end
    for _, module in pairs(childrens or {}) do
        pcall(function()
            if module:IsA('Instance') then
                module.Parent = object
            end
        end)
    end
    return object
end
function clone(instance, properties, childrens)
    local object = instance:Clone()
    for i, v in pairs(properties or {}) do
        if typeof(v) == 'Color3' then
            instancesColor3[i] = instancesColor3[i] or {}
            table.insert(instancesColor3[i], object)
        end

        if i == 'Function' then
            task.spawn(function()
                if properties and properties.Parent then
                    repeat task.wait() until object.Parent
                end
                v(object)
            end)
        elseif i == 'CornerRadius' and className ~= 'UICorner' then
            create('UICorner', {
                Parent = object,
                CornerRadius = v
            })
        elseif i == 'Padding' and string.sub(className, 1, 2) ~= 'UI' then
            if typeof(v) ~= 'table' then
                local a = {
                    Top = v,
                    Bottom = v,
                    Left = v,
                    Right = v,
                }
                v = a
            end
            create('UIPadding', {
                Parent = object,
                PaddingTop = v.Top,
                PaddingBottom = v.Bottom,
                PaddingLeft = v.Left,
                PaddingRight = v.Right,
            })
        elseif i == 'Stroke' and pcall(function()
            local a = object.Text
        end) then
            local stroke = create('UIStroke', {
                Parent = object,
                Color = object.TextColor3,
                Thickness = v
            })
            object:GetPropertyChangedSignal('TextColor3'):Connect(function()
                stroke.Color = object.TextColor3
            end)
        else
            local success, _ = pcall(function()
                object[i] = v
            end)
            if not success then
                if typeof(v) == 'function' then
                    _G[tostring(v)] = v
                end
                object:SetAttribute(i, typeof(v) == 'function' and tostring(v) or v)
            end
        end
    end
    for _, module in pairs(childrens or {}) do
        pcall(function()
            if module:IsA('Instance') then
                module.Parent = object
            end
        end)
    end
    return object
end
function getTextSize(Text, Size, Font, XSize)
    return create('TextLabel', {
        Parent = CoreGui:GetChildren()[1],
        Size = UDim2.new(XSize and 0 or 1, XSize, 1, 0),
        FontFace = Font,
        TextSize = Size,
        TextWrapped = true,
        RichText = true,
        Text = Text,
        Visible = false,
        Function = function(TextLabel)
            pcall(function()
                TextLabel:Destroy()
            end)
        end
    }).TextBounds
end
function getBoldText(Text)
    return string.find(Text, '<b>') and string.split(string.split(Text, '<b>')[2], '</b>')[1] or ''
end
function Tween(instance, properties, duration, ...)
    local Tween = game:GetService('TweenService'):create(instance, TweenInfo.new(duration, ...), properties)
    Tween:Play()
    return Tween
end
function rippleEffect(instance, duration)
    instance.ClipsDescendants = true
    local Ripple = create('Frame', {
        Parent = instance,
        BackgroundColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].TextColor,
        BackgroundTransparency = 0.6,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 10,
        CornerRadius = UDim.new(1, 0),
    })
    local tween = Tween(Ripple, {
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(instance.AbsoluteSize.X, instance.AbsoluteSize.X),
    }, duration or 0)
    tween.Completed:Connect(function()
        Ripple:Destroy()
    end)
    return tween
end

function GetThemeColor()
    return Library.Settings.DarkMode and 'Dark' or 'Light'
end
function GetBThemeColor()
    return Library.Settings.DarkMode and 'Light' or 'Dark'
end
function ChangeTheme()
    Library.Settings.DarkMode = not Library.Settings.DarkMode
    local function IsBThemeColor(color)
        for a, b in pairs(Theme[GetBThemeColor()]) do
            if b == color then
                return a
            end
        end
    end
    for property, tbl in pairs(instancesColor3) do
        for i, instance in pairs(tbl) do
            local color = IsBThemeColor(instance[property])
            if color then
                instance[property] = Theme[GetThemeColor()][color]
            end
        end
    end
end

function BindToKey(key, callback)
    local connection
    connection = UserInputService.InputBegan:Connect(function(input, proc)
        if not Library.Settings.Enabled then
            connection:Disconnect()
        end
        if input.KeyCode.Name == key.Name and not proc then
            callback()
        end
    end)

    return {
        UnBind = function()
            connection:Disconnect()
        end,
    }
end
function KeyPressed()
    local key = UserInputService.InputBegan:Wait()
    while key.UserInputType ~= Enum.UserInputType.Keyboard do
        key = UserInputService.InputBegan:Wait()
    end

    return key
end
function Dragging(Instance)
    local Dragging = false
    Instance.InputBegan:Connect(function(input, processed)
        if not processed and input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true

            local mousePos, framePos = input.Position, Instance.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
            repeat task.wait()
                local delta = Vector2.new(Mouse.X - mousePos.X, Mouse.Y - mousePos.Y)
                spawn(function()
                    Tween(Instance, { Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y) }, 0.05)
                end)
            until not Dragging
        end
    end)
end

function httpRequest(config)
    local req = (syn and syn.request) or (http and http.request) or http_request
    local res = req(config)

    return function(callback)
        return callback(typeof(res) == 'table' and res or game:GetService('HttpService'):JSONDecode(res))
    end
end
--#endregion

do -- UI
	Library.__index = Library
	Library.Page.__index = Library.Page
	Library.Section.__index = Library.Section

    function Library.new()
        if Library.Settings.Parent:FindFirstChild(Library.Settings.Name .. ' UI') then
            local Response
            create('StringValue', {
                Parent =  Library.Settings.Parent:FindFirstChild(Library.Settings.Name .. ' UI').Notifications.List,
                Name = 'Close ' .. Library.Settings.Name .. ' Hub?',
                Value = 'Trying to run this script again, do you want to close and reopen ' .. Library.Settings.Name .. ' Hub?',
                Type = 4,
                CallBack = function(value)
                    if value then
                        Library.Settings.Parent:FindFirstChild(Library.Settings.Name .. ' UI'):Destroy()
                    end
                    Response = value
                end
            })
            repeat task.wait() until Response ~= nil
            if not Response then return end
        end
        Library.Settings.Enabled = true

        local UI = create('ScreenGui', {
			Name = Library.Settings.Name .. ' UI',
			Parent = Library.Settings.Parent,
            IgnoreGuiInset = true
		}, {
            create('Folder', {
                Name = 'SoundEffects'
            }),
            create('Frame', {
                Name = 'Notifications',
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
            }, {
                create('Folder', {
                    Name = 'List',
                    Function = function(List)
                        local CenterPriorityList = {}
                        List.ChildAdded:Connect(function(child)
                            if not Library.Settings.Notifications and not WaitForAttribute(child, 'Bypass') then
                                child:Destroy()
                                return
                            end
                            if child.ClassName ~= 'StringValue' then
                                child:Destroy()
                                return
                            end

                            local Type = WaitForAttribute(child, 'Type') or 1
                            local Color = WaitForAttribute(child, 'Color')
                            local title = child.Name ~= '' and child.Name ~= 'Value' and child.Name or 'Notification Title'
                            local text = child.Value ~= '' and child.Value or (Type <= 3 and 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.' or 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.')

                            local notification = create('Frame', {
                                Name = 'Notification',
                                Size = UDim2.new(1, 0, 0, 100),
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                Position = UDim2.new(0.5, 0, 0.5, 0),
                                BackgroundTransparency = 1,
                                ZIndex = Type > 3 and 3 or 1
                            }, {
                                create('Frame', {
                                    BackgroundColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].Background,
                                    BackgroundTransparency = Type <= 3 and .3 or 0,
                                    Size = UDim2.new(1, 0, 1, 0),
                                    CornerRadius = UDim.new(0, 8),
                                    Padding = UDim.new(0, 15),
                                    ZIndex = Type > 3 and 3 or 1
                                }, {
                                    Type == 1 and create('TextLabel', {
                                        Name = 'Time',
                                        BackgroundTransparency = 1,
                                        Size = UDim2.new(0, getTextSize(os.date('%X %p'), 16, Font.fromName('Jura', Enum.FontWeight.Regular)).X, 0, 16),
                                        FontFace = Font.fromName('Jura', Enum.FontWeight.Regular),
                                        Text = os.date('%X %p'),
                                        TextColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].TextColor,
                                        TextSize = 16,
                                        Position = UDim2.new(1, 0, 0, 0),
                                        AnchorPoint = Vector2.new(1, 0)
                                    }) or Type == 2 and create('Frame', {
                                        Name = 'Bar',
                                        BackgroundColor3 = Color or Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].Accent,
                                        BorderSizePixel = 0,
                                        Size = UDim2.new(1, 0, 0, 3),
                                        Position = UDim2.new(1, 0, 1, 0),
                                        AnchorPoint = Vector2.new(1, 1),
                                        CornerRadius = UDim.new(1, 0)
                                    }) or (Type == 3 or Type == 4) and create('Frame', {
                                        Name = 'Buttons',
                                        BackgroundTransparency = 1,
                                        Size = UDim2.new(1, 0, 0, 30),
                                        Position = UDim2.new(1, 0, 1, 0),
                                        AnchorPoint = Vector2.new(1, 1),
                                        ZIndex = Type > 3 and 3 or 1
                                    }, {
                                        create('TextButton', {
                                            Name = 'Continue',
                                            BackgroundColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].Accent,
                                            Size = UDim2.new(0, 100, 1, 0),
                                            AutoButtonColor = false,
                                            Text = 'CONTINUE',
                                            FontFace = Font.fromName('Jura', Enum.FontWeight.Bold),
                                            TextColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].TextColor,
                                            TextSize = 14,
                                            CornerRadius = UDim.new(0, 8),
                                            Stroke = 0,
                                            ZIndex = Type > 3 and 3 or 1,
                                            Function = function(Button)
                                                Button.MouseButton1Click:Connect(function()
                                                    rippleEffect(Button, 0.5)
                                                end)
                                            end
                                        }),
                                        create('TextButton', {
                                            Name = 'Cancel',
                                            BackgroundTransparency = 1,
                                            Size = UDim2.new(0, 100, 1, 0),
                                            Position = UDim2.new(1, 0, 0, 0),
                                            AnchorPoint = Vector2.new(1, 0),
                                            AutoButtonColor = false,
                                            Text = 'CANCEL',
                                            FontFace = Font.fromName('Jura', Enum.FontWeight.Bold),
                                            TextColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].TextColor,
                                            TextSize = 14,
                                            ZIndex = Type > 3 and 3 or 1,
                                            Function = function(Button)
                                                Button.MouseButton1Click:Connect(function()
                                                    rippleEffect(Button, 0.5)
                                                end)
                                            end
                                        })
                                    }),
                                    create('TextLabel', {
                                        Name = 'Title',
                                        BackgroundTransparency = 1,
                                        Size = UDim2.new(1, Type == 1 and -getTextSize(os.date('%X %p'), 16, Font.fromName('Jura', Enum.FontWeight.Regular)).X -5 or 0, 0, 16),
                                        -- ClipsDescendants = true,
                                        FontFace = Font.fromName('Jura', Enum.FontWeight.Bold),
                                        TextColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].TextColor,
                                        TextSize = 16,
                                        TextXAlignment = Type <= 3 and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center,
                                        Text = title,
                                        ZIndex = Type > 3 and 3 or 1
                                    }),
                                    create('TextLabel', {
                                        Name = 'Text',
                                        BackgroundTransparency = 1,
                                        Position = UDim2.new(0, 0, 0, 16 + 5),
                                        Size = UDim2.new(1, 0, 0, getTextSize(text, 14, Font.fromName('Jura', Enum.FontWeight.Regular), Type <= 3 and (List.Parent.Left.AbsoluteSize.X - 20 - 15 - 15) or (List.Parent.Center.Container.AbsoluteSize.X - 15 - 15)).Y),
                                        FontFace = Font.fromName('Jura', Enum.FontWeight.Regular),
                                        TextColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].TextColor,
                                        TextSize = 14,
                                        TextXAlignment = Enum.TextXAlignment.Left,
                                        TextWrapped = true,
                                        Text = text,
                                        ZIndex = Type > 3 and 3 or 1
                                    })
                                })
                            })

                            local size = 15 + notification.Frame.Title.AbsoluteSize.Y + 5 + notification.Frame['Text'].AbsoluteSize.Y + 15
                            if Type == 2 then
                                size += 10 + notification.Frame.Bar.AbsoluteSize.Y

                                task.spawn(function()
                                    local Time = WaitForAttribute(child, 'Time') or 5
                                    Tween(notification.Frame.Bar, { Size = UDim2.new(0, 0, 0, 3) }, Time).Completed:Connect(function()
                                        pcall(function()
                                            Tween(notification.Frame, {
                                                Position = UDim2.new(1, 0, 0, 0),
                                            }, notification.Frame.Position.X.Offset > 0 and (0.4 / List.Parent.Left.AbsoluteSize.X) * notification.Frame.Position.X.Offset or 0.4).Completed:Connect(function()
                                                notification:Destroy()
                                            end)
                                        end)
                                    end)
                                end)
                            elseif Type == 3 or Type == 4 then
                                size += 10 + notification.Frame.Buttons.AbsoluteSize.Y

                                task.spawn(function()
                                    local CallBack = WaitForAttribute(child, 'CallBack')
                                    notification.Frame.Buttons.Continue.MouseButton1Click:Connect(function()
                                        if CallBack then
                                            _G[CallBack](true)
                                            _G[CallBack] = nil
                                        end
                                        pcall(function()
                                            if Type == 3 then
                                                Tween(notification.Frame, {
                                                    Position = UDim2.new(1, 0, 0, 0),
                                                }, 0.4).Completed:Connect(function()
                                                    notification:Destroy()
                                                end)
                                            else
                                                if #CenterPriorityList > 1 then
                                                    table.remove(CenterPriorityList, table.find(CenterPriorityList, notification))
                                                else
                                                    Tween(List.Parent.Center, { BackgroundTransparency = 1 }, 0.1).Completed:Connect(function()
                                                        pcall(function()
                                                            table.remove(CenterPriorityList, table.find(CenterPriorityList, notification))
                                                        end)
                                                    end)
                                                end
                                                notification:Destroy()
                                            end
                                        end)
                                    end)
                                    notification.Frame.Buttons.Cancel.MouseButton1Click:Connect(function()
                                        if CallBack then
                                            _G[CallBack](false)
                                            _G[CallBack] = nil
                                        end
                                        pcall(function()
                                            if Type == 3 then
                                                Tween(notification.Frame, {
                                                    Position = UDim2.new(1, 0, 0, 0),
                                                }, 0.4).Completed:Connect(function()
                                                    notification:Destroy()
                                                end)
                                            else
                                                if #CenterPriorityList > 1 then
                                                    table.remove(CenterPriorityList, table.find(CenterPriorityList, notification))
                                                else
                                                    Tween(List.Parent.Center, { BackgroundTransparency = 1 }, 0.1).Completed:Connect(function()
                                                        pcall(function()
                                                            table.remove(CenterPriorityList, table.find(CenterPriorityList, notification))
                                                        end)
                                                    end)
                                                end
                                                notification:Destroy()
                                            end
                                        end)
                                    end)
                                end)
                            end
                            notification.Size = UDim2.new(1, 0, 0, size)

                            if Type < 3 then
                                notification.Frame.InputBegan:Connect(function(input, processed)
                                    if not processed and input.UserInputType == Enum.UserInputType.MouseButton1 then
                                        local mousePos, framePos = input.Position, notification.Frame.Position
                                        local tween
                                        local success = true
                                        repeat task.wait()
                                            local err
                                            success, err = pcall(function()
                                                local delta = Vector2.new(Mouse.X - mousePos.X, Mouse.Y - mousePos.Y)
                                                tween = Tween(notification.Frame, {
                                                    Position = UDim2.new(
                                                        framePos.X.Scale, math.max(0, framePos.X.Offset + delta.X),
                                                        framePos.Y.Scale, framePos.Y.Offset
                                                    ),
                                                }, 0.1)
                                            end)
                                        until not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or not success
                                        pcall(function()
                                            tween.Completed:Wait()
                                            if notification.Frame.Position.X.Offset >= (List.Parent.Left.AbsoluteSize.X * 0.65) then
                                                Tween(notification.Frame, {
                                                    Position = UDim2.new(1, 0, 0, 0),
                                                }, (0.4 / List.Parent.Left.AbsoluteSize.X) * notification.Frame.Position.X.Offset).Completed:Connect(function()
                                                    notification:Destroy()
                                                end)
                                            else
                                                Tween(notification.Frame, {
                                                    Position = UDim2.new(0, 0, 0, 0),
                                                }, 0.1)
                                            end
                                        end)
                                    end
                                end)
                            end

                            if Type <= 3 then
                                notification.Parent = List.Parent.Left
                            else
                                table.insert(CenterPriorityList, notification)
                                repeat task.wait() until CenterPriorityList[1] == notification
                                Tween(List.Parent.Center, { BackgroundTransparency = 0.5 }, 0.1).Completed:Connect(function()
                                    notification.Parent = List.Parent.Center.Container
                                end)
                            end

                            if not List:FindFirstAncestorWhichIsA('ScreenGui').SoundEffects:FindFirstChild('Notification') then
                                local effect = create('Sound', {
                                    Name = 'Notification',
                                    Parent = List:FindFirstAncestorWhichIsA('ScreenGui').SoundEffects,
                                    SoundId = 'rbxassetid://3023237993',
                                    Volume = 0.25
                                })
                                effect:Play()
                                effect.Ended:Connect(function()
                                    effect:Destroy()
                                end)
                            end

                            child:Destroy()
                        end)
                    end
                }),
                create('Frame', {
                    Name = 'Left',
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, 0, 0, 0),
                    Size = UDim2.new(0, 350, 1, 0),
                    Padding = {
                        Bottom = UDim.new(0, 20),
                        Right = UDim.new(0, 20)
                    }
                }, {
                    create('UIListLayout', {
                        Padding = UDim.new(0, 5),
                        VerticalAlignment = Enum.VerticalAlignment.Bottom
                    })
                }),
                create('Frame', {
                    Name = 'Center',
                    BackgroundTransparency = 1,
                    BackgroundColor3 = Color3.new(0),
                    Size = UDim2.new(1, 0, 1, 0),
                    ZIndex = 3
                }, {
                    create('Frame', {
                        Name = 'Container',
                        BackgroundTransparency = 1,
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.new(0.5, 0, 0.5, 0),
                        Size = UDim2.new(0, 350, 1, 0),
                    })
                })
            }),
            create('Frame', {
                Name = 'Tooltip',
                BackgroundColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].Grey,
                Size = UDim2.new(0, 300 + 2, 0, 28 + 10 + 2),
                Visible = false,
                ZIndex = 3,
                CornerRadius = UDim.new(0, 8),

                -- Position = UDim2.new(1, 0, 0.5, 0),
                -- AnchorPoint = Vector2.new(1, 0.5),
            }, {
                create('Frame', {
                    BackgroundColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].Grey,
                    Size = UDim2.new(0, 16 + 2, 0, 16 + 2),
                    Position = UDim2.new(0, 6, 0, 3),
                    AnchorPoint = Vector2.new(0.5, 0),
                    Rotation = 45,
                    ZIndex = 3,
                    CornerRadius = UDim.new(0, 3)
                }, {
                    create('Frame', {
                        BackgroundColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].Background,
                        Size = UDim2.new(1, -2, 1, -2),
                        Position = UDim2.new(0.5, 0, 0.5, 0),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        ZIndex = 3,
                        CornerRadius = UDim.new(0, 3)
                    })
                }),
                create('Frame', {
                    Name = 'Content',
                    BackgroundColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].Background,
                    Size = UDim2.new(1, -2, 1, -2),
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    ZIndex = 3,
                    CornerRadius = UDim.new(0, 8),
                }, {
                    create('TextLabel', {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0.5, 0, 0.5, 0),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Size = UDim2.new(1, -10, 1, -10),
                        FontFace = Font.fromName('Jura', Enum.FontWeight.Regular),
                        TextColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].TextColor,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextWrapped = true,
                        RichText = true,
                        Text = 'Tooltip Text',
                        ZIndex = 3,
                        Function = function(TextLabel)
                            repeat task.wait() until TextLabel.Parent and TextLabel.Parent.Parent

                            TextLabel:GetPropertyChangedSignal('Text'):Connect(function()
                                local TextSize = getTextSize(TextLabel.Text, 14, TextLabel.FontFace, 300 - 10)

                                TextLabel.Parent.Parent.Size = UDim2.new(0, (TextSize.Y > 14 and 300 or TextSize.X + 10) + 2, 0, TextSize.Y + 10 + 2)
                            end)
                        end
                    })
                })
            })
        })

		UI.Destroying:Connect(function()
			Library.Settings.Enabled = false
		end)
        local ToggleUI
        if Library.Settings.Prefix then
            ToggleUI = BindToKey(Library.Settings.Prefix, function()
                pcall(function()
                    UI.Enabled = not UI.Enabled
                end)
            end)
        end

        local function ToolTip(Button, Text)
            Button.MouseEnter:Connect(function()
                UI.Tooltip.Content.TextLabel.Text = Text
                UI.Tooltip.Position = UDim2.new(0, Button.AbsolutePosition.X + Button.AbsoluteSize.X + 10, 0, Button.AbsolutePosition.Y + math.abs(UI.AbsolutePosition.Y) + (Button.AbsoluteSize.Y / 2) - 12)
                UI.Tooltip.Visible = true
            end)
            Button.MouseLeave:Connect(function()
                UI.Tooltip.Visible = false
            end)
        end
        local function Setting_Element(order, icon, title, info, extra)
            local Element = create('Frame', {
                Name = 'Element',
                BackgroundTransparency = 1,
                LayoutOrder = order,
                Size = UDim2.new(1, 0, 0, 30),
            }, {
                create('ImageLabel', {
                    Name = 'Icon',
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(0, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    ImageColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].TextColor,
                    Image = string.find(icon, 'rbxassetid://') and icon or 'rbxassetid://' .. icon,
                }),
                create('TextLabel', {
                    Name = 'Title',
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -26 -(extra and math.min(60, extra.AbsoluteSize.X) + 5 or 0) -(info and 16 + 5 or 0), 1, 0),
                    Position = UDim2.new(0, 26, 0, 0),
                    FontFace = Font.fromName('Jura', Enum.FontWeight.Bold),
                    TextColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].TextColor,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    TextSize = 16,
                    Text = title,
                }),
                info and create('ImageButton', {
                    Name = 'Info',
                    AutoButtonColor = false,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(1, extra and -math.min(60, extra.AbsoluteSize.X) -5, 0.5, 0),
                    AnchorPoint = Vector2.new(1, 0.5),
                    ImageColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].TextColor,
                    ImageTransparency = 0.3,
                    Image = 'rbxassetid://7733964719',
                    Function = function(Button)
                        ToolTip(Button, info)
                        -- Button.MouseEnter:Connect(function()
                        --     UI.Tooltip.Content.TextLabel.Text = info
                        --     UI.Tooltip.Position = UDim2.new(0, Button.AbsolutePosition.X + Button.AbsoluteSize.X + 10, 0, Button.AbsolutePosition.Y - UI.AbsolutePosition.Y - 4)
                        --     UI.Tooltip.Visible = true
                        -- end)
                        -- Button.MouseLeave:Connect(function()
                        --     UI.Tooltip.Visible = false
                        -- end)
                    end
                })
            })
            extra.Parent = Element
            extra.Position = UDim2.new(1, 0, 0.5, 0)
            extra.AnchorPoint = Vector2.new(1, 0.5)
            extra.Size = UDim2.new(0, math.min(60, extra.AbsoluteSize.X), 0, extra.AbsoluteSize.Y)
            return Element
        end

        --#region User Settings
        create('Frame', {
            Name = 'Settings',
            BackgroundColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].Background,
            Size = UDim2.new(0, 270, 0, 177),
            Position = UDim2.new(0, 0, 0.5, 0),
            AnchorPoint = Vector2.new(1, 0.5),
            CornerRadius = UDim.new(0, 8),
            Function = function(Settings)
                task.spawn(function()
                    task.wait()
                    local Tsize = 177
                    for _, v in pairs(Settings.Container.Options:GetChildren()) do
                        pcall(function()
                            Tsize += v.AbsoluteSize.Y + 5
                        end)
                    end
                    Settings.Size = UDim2.new(0, Settings.AbsoluteSize.X, 0, Tsize - 5)
                    Settings.Parent = UI
                end)
            end
        }, {
            create('Frame', {
                Name = '',
                BackgroundColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].Background,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 8, 1, 0)
            }),
            create('Frame', {
                Name = 'Button',
                Size = UDim2.new(0, 60, 0, 45),
                BackgroundColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].Background,
                Position = UDim2.new(1, 0, 0, 0),
                AnchorPoint = Vector2.new(0.5, 0),
                CornerRadius = UDim.new(1, 0),
            }, {
                create('ImageButton', {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(0.75, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0.75, 0.5),
                    ImageColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].TextColor,
                    Image = 'rbxassetid://7072706745',
                    Function = function(ImageButton)
                        local cd = false
                        ImageButton.MouseButton1Click:Connect(function()
                            if cd then return end
                            cd = true
                            if ImageButton.Rotation == 0 then
                                Tween(ImageButton.Parent, { AnchorPoint = Vector2.new(1, 0) }, 0.1)
                                Tween(ImageButton, { Rotation = 180 }, 0.3)
                                Tween(ImageButton.Parent.Parent, { AnchorPoint = Vector2.new(0, 0.5) }, 0.3).Completed:Wait()
                            else
                                Tween(ImageButton.Parent, { AnchorPoint = Vector2.new(0.5, 0) }, 0.3)
                                Tween(ImageButton, { Rotation = 0 }, 0.3)
                                Tween(ImageButton.Parent.Parent, { AnchorPoint = Vector2.new(1, 0.5) }, 0.3).Completed:Wait()
                            end
                            cd = false
                        end)
                    end
                })
            }),
            create('Frame', {
                Name = 'Container',
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Padding = UDim.new(0, 20)
            }, {
                create('ImageLabel', {
                    Name = 'ProfileImage',
                    BackgroundColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].Contrast,
                    Size = UDim2.new(0, 85, 0, 85),
                    Position = UDim2.new(0.5, 0, 0, 0),
                    AnchorPoint = Vector2.new(0.5, 0),
                    Image = 'rbxthumb://type=AvatarHeadShot&id='  .. Player.UserId .. '&w=420&h=420',
                    CornerRadius = UDim.new(1, 0),
                }, {
                    (Library.User.IsPremium or Library.User.IsDeveloper) and create('Frame', {
                        Name = 'Rank',
                        Size = UDim2.new(0, 20, 0, 20),
                        Position = UDim2.new(1, 0, 1, 0),
                        AnchorPoint = Vector2.new(1, 1),
                        BackgroundColor3 = Library.User.IsDeveloper and Color3.fromRGB(202,81,100) or Library.User.IsPremium and Color3.fromRGB(219, 135, 46),
                        CornerRadius = UDim.new(1, 0),
                    }, {
                        create('ImageLabel', {
                            Name = 'Icon',
                            BackgroundTransparency = 1,
                            Size = UDim2.new(0, 16, 0, 16),
                            Position = UDim2.new(0.5, 0, 0.5, 0),
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            ImageColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].TextColor,
                            Image = Library.User.IsDeveloper and 'rbxassetid://7733920644' or Library.User.IsPremium and 'rbxassetid://7733942651',
                        }),
                    })
                }),
                create('Frame', {
                    Name = 'UserInfo',
                    Size = UDim2.new(1, 0, 0, 32),
                    Position = UDim2.new(0, 0, 0, 90),
                    BackgroundTransparency = 1,
                }, {
                    create('TextLabel', {
                        Name = 'UserName',
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, -100, 0, 16),
                        Position = UDim2.new(0.5, 0, 0, 0),
                        AnchorPoint = Vector2.new(0.5, 0),
                        ClipsDescendants = true,
                        FontFace = Font.fromName('Jura', Enum.FontWeight.Bold),
                        TextColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].TextColor,
                        TextSize = 16,
                        TextXAlignment = Enum.TextXAlignment.Center,
                        Text = Player.DisplayName,
                    }),
                    create('TextLabel', {
                        Name = 'UserID',
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, -100, 0, 16),
                        Position = UDim2.new(0.5, 0, 1, 0),
                        AnchorPoint = Vector2.new(0.5, 1),
                        ClipsDescendants = true,
                        FontFace = Font.fromName('Jura', Enum.FontWeight.Regular),
                        TextColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].TextColor,
                        TextSize = 16,
                        TextXAlignment = Enum.TextXAlignment.Center,
                        Text = Player.UserId,
                    }),
                    create('TextButton', {
                        Name = 'Copy',
                        AutoButtonColor = false,
                        BackgroundColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].Contrast,
                        Size = UDim2.new(0, 30, 0, 30),
                        Position = UDim2.new(1, -10, 0.5, 0),
                        AnchorPoint = Vector2.new(1, 0.5),
                        Text = '',
                        CornerRadius = UDim.new(0, 8),
                        Function = function(Button)
                            Button.MouseButton1Click:Connect(function()
                                rippleEffect(Button, 0.5)
                            end)
                        end
                    }, {
                        create('ImageLabel', {
                            Name = 'Icon',
                            BackgroundTransparency = 1,
                            Size = UDim2.new(0, 16, 0, 16),
                            Position = UDim2.new(0.5, 0, 0.5, 0),
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            ImageColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].TextColor,
                            Image = 'rbxassetid://7733764083',
                        })
                    })
                }),
                create('Frame', {
                    Name = 'Options',
                    Size = UDim2.new(1, 0, 1, -137),
                    Position = UDim2.new(0, 0, 1, 0),
                    AnchorPoint = Vector2.new(0, 1),
                    BackgroundTransparency = 1,
                }, {
                    create('UIListLayout', {
                        Padding = UDim.new(0, 5),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    }),
                    create('Frame', {
                        Name = 'Section',
                        LayoutOrder = 0,
                        Size = UDim2.new(1, 0, 0, 25),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].Contrast,
                    }, {
                        create('TextLabel', {
                            Name = 'Title',
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 1, 0),
                            FontFace = Font.fromName('Jura', Enum.FontWeight.Bold),
                            TextColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].TextColor,
                            TextSize = 16,
                            TextXAlignment = Enum.TextXAlignment.Center,
                            Text = string.upper('Content'),
                        })
                    }),
                    Setting_Element(1, 'rbxassetid://7734021595', 'Colors', nil, create('ImageButton', {
                        Name = 'Icon',
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0, 16, 0, 16),
                        ImageColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].TextColor,
                        Image = 'rbxassetid://7072706745',
                    })),
                    Setting_Element(2, 'rbxassetid://7733993311', 'Notifications', nil, create('TextButton', {
                        Name = 'Toggle',
                        BackgroundColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].Contrast,
                        Size = UDim2.new(0, 50, 0, 22),
                        AutoButtonColor = false,
                        Text = '',
                        CornerRadius = UDim.new(1, 0),
                        Padding = UDim.new(0, 2),
                        Function = function(Toggle)
                            local cd = false

                            Toggle:WaitForChild('Status')
                            Toggle:WaitForChild('Circle')
                            if Library.Settings.Notifications then
                                Toggle.Status.TextXAlignment = Enum.TextXAlignment.Left
                                Toggle.Status.Text = 'on'

                                Toggle.Circle.Position = UDim2.new(1, 0, 0.5, 0)
                                Toggle.Circle.AnchorPoint = Vector2.new(1, 0.5)
                                Toggle.Circle.ImageColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].Accent
                            end
                            Toggle.MouseButton1Click:Connect(function()
                                if cd then return end
                                cd = true

                                if Library.Settings.Notifications == false then
                                    Toggle.Status.TextXAlignment = Enum.TextXAlignment.Left
                                    Toggle.Status.Text = 'on'

                                    Library.Settings.Notifications = true
                                    Tween(Toggle.Circle, {
                                        Position = UDim2.new(1, 0, 0.5, 0),
                                        AnchorPoint = Vector2.new(1, 0.5),
                                        ImageColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].Accent
                                    }, 0.2).Completed:Wait()
                                else
                                    Toggle.Status.TextXAlignment = Enum.TextXAlignment.Right
                                    Toggle.Status.Text = 'off'

                                    Library.Settings.Notifications = false
                                    Tween(Toggle.Circle, {
                                        Position = UDim2.new(0, 0, 0.5, 0),
                                        AnchorPoint = Vector2.new(0, 0.5),
                                        ImageColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].TextColor
                                    }, 0.2).Completed:Wait()
                                end

                                cd = false
                            end)
                        end
                    }, {
                        create('TextLabel', {
                            Name = 'Status',
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, -10, 1, 0),
                            Position = UDim2.new(0.5, 0, 0, 0),
                            AnchorPoint = Vector2.new(0.5, 0),
                            FontFace = Font.fromName('Jura', Enum.FontWeight.Regular),
                            TextColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].TextColor,
                            TextSize = 14,
                            TextXAlignment = Enum.TextXAlignment.Right,
                            Text = 'off',
                        }),
                        create('ImageLabel', {
                            Name = 'Circle',
                            BackgroundTransparency = 1,
                            Size = UDim2.new(0, 18, 0, 18),
                            Position = UDim2.new(0, 0, 0.5, 0),
                            AnchorPoint = Vector2.new(0, 0.5),
                            ImageColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].TextColor,
                            Image = 'rbxassetid://6031625146',
                        })
                    })),
                    Setting_Element(3, 'rbxassetid://7733954760', 'Public', 'Allow other <b>' .. Library.Settings.Name .. ' Hub</b> users to join you.', create('TextButton', {
                        Name = 'Toggle',
                        BackgroundColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].Contrast,
                        Size = UDim2.new(0, 50, 0, 22),
                        AutoButtonColor = false,
                        Text = '',
                        CornerRadius = UDim.new(1, 0),
                        Padding = UDim.new(0, 2),
                        Function = function(Toggle)
                            local cd = false

                            Toggle:WaitForChild('Status')
                            Toggle:WaitForChild('Circle')
                            if Library.Settings.Public then
                                Toggle.Status.TextXAlignment = Enum.TextXAlignment.Left
                                Toggle.Status.Text = 'on'

                                Toggle.Circle.Position = UDim2.new(1, 0, 0.5, 0)
                                Toggle.Circle.AnchorPoint = Vector2.new(1, 0.5)
                                Toggle.Circle.ImageColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].Accent
                            end
                            Toggle.MouseButton1Click:Connect(function()
                                if cd then return end
                                cd = true

                                if Library.Settings.Public == false then
                                    Toggle.Status.TextXAlignment = Enum.TextXAlignment.Left
                                    Toggle.Status.Text = 'on'

                                    Library.Settings.Public = true
                                    Tween(Toggle.Circle, {
                                        Position = UDim2.new(1, 0, 0.5, 0),
                                        AnchorPoint = Vector2.new(1, 0.5),
                                        ImageColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].Accent
                                    }, 0.2).Completed:Wait()
                                else
                                    Toggle.Status.TextXAlignment = Enum.TextXAlignment.Right
                                    Toggle.Status.Text = 'off'

                                    Library.Settings.Public = false
                                    Tween(Toggle.Circle, {
                                        Position = UDim2.new(0, 0, 0.5, 0),
                                        AnchorPoint = Vector2.new(0, 0.5),
                                        ImageColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].TextColor
                                    }, 0.2).Completed:Wait()
                                end

                                cd = false
                            end)
                        end
                    }, {
                        create('TextLabel', {
                            Name = 'Status',
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, -10, 1, 0),
                            Position = UDim2.new(0.5, 0, 0, 0),
                            AnchorPoint = Vector2.new(0.5, 0),
                            FontFace = Font.fromName('Jura', Enum.FontWeight.Regular),
                            TextColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].TextColor,
                            TextSize = 14,
                            TextXAlignment = Enum.TextXAlignment.Right,
                            Text = 'off',
                        }),
                        create('ImageLabel', {
                            Name = 'Circle',
                            BackgroundTransparency = 1,
                            Size = UDim2.new(0, 18, 0, 18),
                            Position = UDim2.new(0, 0, 0.5, 0),
                            AnchorPoint = Vector2.new(0, 0.5),
                            ImageColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].TextColor,
                            Image = 'rbxassetid://6031625146',
                        })
                    })),

                    create('Frame', {
                        Name = 'Section',
                        LayoutOrder = 4,
                        Size = UDim2.new(1, 0, 0, 25),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].Contrast,
                    }, {
                        create('TextLabel', {
                            Name = 'Title',
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 1, 0),
                            FontFace = Font.fromName('Jura', Enum.FontWeight.Bold),
                            TextColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].TextColor,
                            TextSize = 16,
                            TextXAlignment = Enum.TextXAlignment.Center,
                            Text = string.upper('Preferences'),
                        })
                    }),
                    Setting_Element(5, 'rbxassetid://7733965249', 'Language', nil, create('ImageButton', {
                        Name = 'Icon',
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0, 16, 0, 16),
                        ImageColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].TextColor,
                        Image = 'rbxassetid://7072706745',
                    })),
                    Setting_Element(6, 'rbxassetid://7743870134', 'Dark Mode', nil, create('TextButton', {
                        Name = 'Toggle',
                        BackgroundColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].Contrast,
                        Size = UDim2.new(0, 50, 0, 22),
                        AutoButtonColor = false,
                        Text = '',
                        CornerRadius = UDim.new(1, 0),
                        Padding = UDim.new(0, 2),
                        Function = function(Toggle)
                            local cd = false

                            Toggle:WaitForChild('Status')
                            Toggle:WaitForChild('Circle')
                            if Library.Settings.DarkMode then
                                Toggle.Status.TextXAlignment = Enum.TextXAlignment.Left
                                Toggle.Status.Text = 'on'

                                Toggle.Circle.Position = UDim2.new(1, 0, 0.5, 0)
                                Toggle.Circle.AnchorPoint = Vector2.new(1, 0.5)
                                Toggle.Circle.ImageColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].Accent
                            end

                            Toggle.MouseButton1Click:Connect(function()
                                if cd then return end
                                cd = true

                                if not Library.Settings.DarkMode then
                                    ChangeTheme()

                                    Toggle.Status.TextXAlignment = Enum.TextXAlignment.Left
                                    Toggle.Status.Text = 'on'

                                    Tween(Toggle.Circle, {
                                        Position = UDim2.new(1, 0, 0.5, 0),
                                        AnchorPoint = Vector2.new(1, 0.5),
                                        ImageColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].Accent
                                    }, 0.2).Completed:Wait()
                                else
                                    ChangeTheme()

                                    Toggle.Status.TextXAlignment = Enum.TextXAlignment.Right
                                    Toggle.Status.Text = 'off'

                                    Tween(Toggle.Circle, {
                                        Position = UDim2.new(0, 0, 0.5, 0),
                                        AnchorPoint = Vector2.new(0, 0.5),
                                        ImageColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].TextColor
                                    }, 0.2).Completed:Wait()
                                end

                                cd = false
                            end)
                        end
                    }, {
                        create('TextLabel', {
                            Name = 'Status',
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, -10, 1, 0),
                            Position = UDim2.new(0.5, 0, 0, 0),
                            AnchorPoint = Vector2.new(0.5, 0),
                            FontFace = Font.fromName('Jura', Enum.FontWeight.Regular),
                            TextColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].TextColor,
                            TextSize = 14,
                            TextXAlignment = Enum.TextXAlignment.Right,
                            Text = 'off',
                        }),
                        create('ImageLabel', {
                            Name = 'Circle',
                            BackgroundTransparency = 1,
                            Size = UDim2.new(0, 18, 0, 18),
                            Position = UDim2.new(0, 0, 0.5, 0),
                            AnchorPoint = Vector2.new(0, 0.5),
                            ImageColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].TextColor,
                            Image = 'rbxassetid://6031625146',
                        })
                    })),
                    Setting_Element(7, 'rbxassetid://7733997870', 'Small Version', nil, create('TextButton', {
                        Name = 'Toggle',
                        BackgroundColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].Contrast,
                        Size = UDim2.new(0, 50, 0, 22),
                        AutoButtonColor = false,
                        Text = '',
                        CornerRadius = UDim.new(1, 0),
                        Padding = UDim.new(0, 2),
                        Function = function(Toggle)
                            local cd = false

                            Toggle:WaitForChild('Status')
                            Toggle:WaitForChild('Circle')
                            if Library.Settings.SmallVersion then
                                Toggle.Status.TextXAlignment = Enum.TextXAlignment.Left
                                Toggle.Status.Text = 'on'

                                local GUI = Library.Settings.Parent:FindFirstChild(Library.Settings.Name .. ' UI'):FindFirstChild('GUI')
                                if GUI then
                                    GUI.Size = UDim2.new(0, 480, 0, 300)
                                end

                                Toggle.Circle.Position = UDim2.new(1, 0, 0.5, 0)
                                Toggle.Circle.AnchorPoint = Vector2.new(1, 0.5)
                                Toggle.Circle.ImageColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].Accent
                            end
                            Toggle.MouseButton1Click:Connect(function()
                                if cd then return end
                                cd = true

                                if Library.Settings.SmallVersion == false then
                                    Toggle.Status.TextXAlignment = Enum.TextXAlignment.Left
                                    Toggle.Status.Text = 'on'

                                    Library.Settings.SmallVersion = true

                                    local GUI = Library.Settings.Parent:FindFirstChild(Library.Settings.Name .. ' UI'):FindFirstChild('GUI')
                                    if GUI then
                                        GUI.Loading.Visible = true
                                        Tween(GUI, { Size = UDim2.new(0, 480, 0, 300) }, 0.2).Completed:Connect(function()
                                            task.wait(0.2)
                                            GUI.Loading.Visible = false
                                        end)
                                    end

                                    Tween(Toggle.Circle, {
                                        Position = UDim2.new(1, 0, 0.5, 0),
                                        AnchorPoint = Vector2.new(1, 0.5),
                                        ImageColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].Accent
                                    }, 0.2).Completed:Wait()
                                else
                                    Toggle.Status.TextXAlignment = Enum.TextXAlignment.Right
                                    Toggle.Status.Text = 'off'

                                    Library.Settings.SmallVersion = false

                                    local GUI = Library.Settings.Parent:FindFirstChild(Library.Settings.Name .. ' UI'):FindFirstChild('GUI')
                                    if GUI then
                                        GUI.Loading.Visible = true
                                        Tween(GUI, { Size = UDim2.new(0, 650, 0, 350) }, 0.2).Completed:Connect(function()
                                            task.wait(0.2)
                                            GUI.Loading.Visible = false
                                        end)
                                    end

                                    Tween(Toggle.Circle, {
                                        Position = UDim2.new(0, 0, 0.5, 0),
                                        AnchorPoint = Vector2.new(0, 0.5),
                                        ImageColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].TextColor
                                    }, 0.2).Completed:Wait()
                                end

                                cd = false
                            end)
                        end
                    }, {
                        create('TextLabel', {
                            Name = 'Status',
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, -10, 1, 0),
                            Position = UDim2.new(0.5, 0, 0, 0),
                            AnchorPoint = Vector2.new(0.5, 0),
                            FontFace = Font.fromName('Jura', Enum.FontWeight.Regular),
                            TextColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].TextColor,
                            TextSize = 14,
                            TextXAlignment = Enum.TextXAlignment.Right,
                            Text = 'off',
                        }),
                        create('ImageLabel', {
                            Name = 'Circle',
                            BackgroundTransparency = 1,
                            Size = UDim2.new(0, 18, 0, 18),
                            Position = UDim2.new(0, 0, 0.5, 0),
                            AnchorPoint = Vector2.new(0, 0.5),
                            ImageColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].TextColor,
                            Image = 'rbxassetid://6031625146',
                        })
                    })),
                    Setting_Element(8, 'rbxassetid://7733774602', 'Prefix', nil, create('TextButton', {
                        Name = 'KeyBind',
                        BackgroundColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].Contrast,
                        Size = UDim2.new(0, 60, 0, 22),
                        AutoButtonColor = false,
                        Text = '',
                        CornerRadius = UDim.new(0, 8),
                        Padding = UDim.new(0, 2),
                        Function = function(KeyBind)
                            KeyBind:WaitForChild('Key')

                            KeyBind.MouseButton1Click:Connect(function()
                                rippleEffect(KeyBind, 0.5)

                                if ToggleUI then
                                    ToggleUI.UnBind()
                                end

                                KeyBind.Key.Text = ''
                                Library.Settings.Prefix = KeyPressed().KeyCode
                                KeyBind.Key.Text = Library.Settings.Prefix.Name

                                task.wait()
                                ToggleUI = BindToKey(Library.Settings.Prefix, function()
                                    pcall(function()
                                        Library.Settings.Parent:FindFirstChild(Library.Settings.Name .. ' UI').Enabled = not Library.Settings.Parent:FindFirstChild(Library.Settings.Name .. ' UI').Enabled
                                    end)
                                end)
                            end)
                        end
                    }, {
                        create('TextLabel', {
                            Name = 'Key',
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 1, 0),
                            FontFace = Font.fromName('Jura', Enum.FontWeight.Regular),
                            TextColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].TextColor,
                            TextSize = 14,
                            TextXAlignment = Enum.TextXAlignment.Center,
                            TextTruncate = Enum.TextTruncate.AtEnd,
                            Text = Library.Settings.Prefix and Library.Settings.Prefix.Name or '',
                        }),
                    })),
                })
            })
        })
        --#endregion
        --#region GUI
        local Page_section_size = 180
        local GUI = create('Frame', {
            Name = 'GUI',
            Parent = UI,
            BackgroundColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].Background,
            Size = UDim2.new(0, 650, 0, 350),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            CornerRadius = UDim.new(0, 8),
            Function = function(Frame)
                Dragging(Frame)

                Frame:GetPropertyChangedSignal('Size'):Connect(function()
                    local Pages = Frame:WaitForChild('Pages')
                    local Container = Frame:WaitForChild('Container')

                    Pages.Size = UDim2.new(Library.Settings.SmallVersion and 1 or 0, Library.Settings.SmallVersion and 0 or Page_section_size, 1, 0)
                    Frame.Separator.Visible = not Library.Settings.SmallVersion
                    Container.Size = UDim2.new(1, Library.Settings.SmallVersion and 0 or -Page_section_size - 1, 1, 0)
                    Container.Visible = not Library.Settings.SmallVersion

                    Pages.Normal.Visible = not Library.Settings.SmallVersion
                    Pages.Small.Visible = Library.Settings.SmallVersion
                end)
            end
        }, {
            create('Frame', {
                Name = 'Loading',
                Visible = false,
                BackgroundColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].Background,
                Size = UDim2.new(1, 0, 1, 0),
                CornerRadius = UDim.new(0, 8),
                ZIndex = 2,
            }, {
                create('Frame', {
                    BackgroundColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].Accent,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    Size = UDim2.new(0, 10, 0, 10),
                    CornerRadius = UDim.new(0, 3),
                    ZIndex = 2,
                    Function = function(frame)
                        pcall(function()
                            Tween(frame, { BackgroundTransparency = 1 }, 0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, true, 0)
                        end)
                    end
                })
            }),

            create('Frame', {
                Name = 'Pages',
                BackgroundColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].Contrast,
                Size = UDim2.new(Library.Settings.SmallVersion and 1 or 0, Library.Settings.SmallVersion and 0 or Page_section_size, 1, 0),
                CornerRadius = UDim.new(0, 8),
            }, {
                create('Frame', {
                    Name = 'Normal',
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Visible = not Library.Settings.SmallVersion
                }, {
                    create('Frame', {
                        Name = '',
                        BackgroundColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].Contrast,
                        BorderSizePixel = 0,
                        Size = UDim2.new(0, 10, 0, 10),
                        Position = UDim2.new(1, 0, 0, 0),
                        AnchorPoint = Vector2.new(1, 0),
                    }),
                    create('Frame', {
                        Name = '',
                        BackgroundColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].Contrast,
                        BorderSizePixel = 0,
                        Size = UDim2.new(0, 10, 0, 10),
                        Position = UDim2.new(1, 0, 1, 0),
                        AnchorPoint = Vector2.new(1, 1),
                    }),
                    create('Frame', {
                        Name = 'Clock',
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 47),
                        Padding = {
                            Top = UDim.new(0, 10),
                            Right = UDim.new(0, 10),
                            Left = UDim.new(0, 10),
                            Bottom = UDim.new(0, 5)
                        }
                    }, {
                        create('TextLabel', {
                            Name = 'Time',
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 0, 16),
                            FontFace = Font.fromName('Jura', Enum.FontWeight.Bold),
                            TextColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].TextColor,
                            TextSize = 16,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            Text = os.date('%X %p'),
                            Function = function(TextLabel)
                                repeat task.wait() until TextLabel.Parent
                                local Date = TextLabel.Parent:WaitForChild('Date')
                                while task.wait(0.1) and Library.Settings.Enabled do
                                    TextLabel.Text = os.date('%X %p')
                                    if Date.Text ~= os.date('%A, %d %b') then
                                        Date.Text = os.date('%A, %d %b')
                                    end
                                end
                            end
                        }),
                        create('TextLabel', {
                            Name = 'Date',
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 0, 16),
                            Position = UDim2.new(0, 0, 1, 0),
                            AnchorPoint = Vector2.new(0, 1),
                            FontFace = Font.fromName('Jura', Enum.FontWeight.Regular),
                            TextColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].TextColor,
                            TextSize = 16,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            Text = os.date('%A, %d %b')
                        }),
                    }),
                    create('Frame', {
                        Name = 'Container',
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, -47),
                        Position = UDim2.new(0, 0, 0, 47),
                        Padding = {
                            Top = UDim.new(0, 10),
                            Bottom = UDim.new(0, 10),
                            Left = UDim.new(0, 15),
                            Right = UDim.new(0, 10)
                        }
                    }, {
                        create('UIListLayout', {
                            Padding = UDim.new(0, 5),
                            SortOrder = Enum.SortOrder.LayoutOrder,
                        }),
                        -- Normal Pages
                    }),
                }),
                create('Frame', {
                    Name = 'Small',
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Visible = Library.Settings.SmallVersion
                }, {})
            }),
            create('Frame', {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, Library.Settings.SmallVersion and 0 or -Page_section_size, 1, 0),
                Position = UDim2.new(1, 0, 0, 0),
                AnchorPoint = Vector2.new(1, 0),
                Visible = not Library.Settings.SmallVersion,
            }, {
                create('ScrollingFrame', {
                    Name = 'Container',
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 1, 0),
                    ClipsDescendants = true,
                    ScrollingEnabled = false,
                    ScrollBarThickness = 0,
                    ScrollingDirection = Enum.ScrollingDirection.X,
                    CanvasSize = UDim2.new(0, 0, 0, 0)
                }, {
                    create('UIListLayout', {
                        Padding = UDim.new(0, 0),
                        FillDirection = Enum.FillDirection.Vertical,
                        VerticalAlignment = Enum.VerticalAlignment.Top,
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })
                })
            }),
        })
        GUI.Frame.Container.ChildAdded:Connect(function()
            GUI.Frame.Container.CanvasSize = UDim2.new(0, 0, #GUI.Frame.Container:GetChildren() - 1, 0)
        end)
        --#endregion

        return setmetatable({
			Container = UI,
            PageContainer = {
                Normal = GUI.Pages.Normal.Container,
                Small = GUI.Pages.Small
            },
            SectionContainer = GUI.Frame.Container,
			Pages = {},
		}, Library)
    end
    function Library.Page.new(config) config = config or {}
        local Title = findByIndex(config, 'Title')
        local Icon = findByIndex(config, 'Icon')
        local Page = create('Frame', {
            Name = Title or 'Page',
            Parent = config.Library.PageContainer.Normal,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 30),
        })
        local Button = create('TextButton', {
            Name = 'Button',
            Parent = Page,
            BackgroundTransparency = 1,
            TextTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Padding = UDim.new(0, 0)
        }, {
            create('UIListLayout', {
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 5)
            }),
            create('ImageLabel', {
                Name = 'Icon',
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 16, 0, 16),
                ImageColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].TextColor,
                Image = Icon and (string.find(Icon, 'rbxassetid://') and Icon or 'rbxassetid://' .. Icon) or 'rbxassetid://7743868527',
                ImageTransparency = 0.4,
            }),
            create('TextLabel', {
                Name = 'Title',
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -16 - 5, 1, 0),
                FontFace = Font.fromName('Jura', Enum.FontWeight.Bold),
                TextColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].TextColor,
                TextTransparency = 0.4,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextSize = 16,
                Text = Title or 'Page Title',
            }),
        })
		local Container = create('ScrollingFrame', {
			Name = Title or 'Container',
			Parent = config.Library.SectionContainer,
            LayoutOrder = #config.Library.SectionContainer:GetChildren() - 1,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, config.Library.SectionContainer.AbsoluteSize.Y),
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ScrollBarThickness = 0,
            Padding = UDim.new(0, 10)
		}, {
			create('UIListLayout', {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 5),
			}),
		})
        Container.UIListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
            Container.CanvasSize = UDim2.new(0, 0, 0, 10 + Container.UIListLayout.AbsoluteContentSize.Y + 10)
            -- Tween(Container, { CanvasSize = UDim2.new(0, 0, 0, 10 + Container.UIListLayout.AbsoluteContentSize.Y + 10) }, 0.2)
        end)

        return setmetatable({
			Library = config.Library,
			Button = Button,
			Container = Container,
            Resize = function()
                Container.UIListLayout.Parent.CanvasSize = UDim2.new(0, 0, 0, 10 + Container.UIListLayout.AbsoluteContentSize.Y + 10)
            end,
			Sections = {},
		}, Library.Page)
    end
	function Library.Section.new(config) config = config or {}
        local Sections = findByIndex(config, 'Sections') or 1

		local Container = create('Frame', {
			Parent = config.Page.Container,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 20),
		}, {
			create('UIListLayout', {
				Padding = UDim.new(0, 5),
				FillDirection = Enum.FillDirection.Horizontal,
                Function = function(UIListLayout)
                    repeat task.wait() until UIListLayout.Parent
                end
			}),
		})
        Container.UIListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
            Container.UIListLayout.Parent.Size = UDim2.new(1, 0, 0, Container.UIListLayout.AbsoluteContentSize.Y)
            -- Tween(Container.UIListLayout.Parent, { Size = UDim2.new(1, 0, 0, Container.UIListLayout.AbsoluteContentSize.Y) }, 0.2)
        end)
        -- config.Page.Container.CanvasSize = UDim2.new(0, 0, 0, 10 + config.Page.Container.UIListLayout.AbsoluteContentSize.Y + 10)

        local tbl_sections = {}
		for i = 1, Sections do
			local Section = create('Frame', {
                Name = i,
				Parent = Container,
				BackgroundColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].Contrast,
				Size = UDim2.new(1 / Sections, -(((5 * (Sections - 1)) / Sections) + 1), 0, 20),
                CornerRadius = UDim.new(0, 8),
                Padding = UDim.new(0, 10)
			}, {
				create('UIListLayout', {
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 5)
				}),
			})
            table.insert(tbl_sections, Section)
            Section.UIListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
                Section.UIListLayout.Parent.Size = UDim2.new(1 / Sections, -(((5 * (Sections - 1)) / Sections) + 1), 0, 10 + Section.UIListLayout.AbsoluteContentSize.Y + 10)
                -- Tween(Section.UIListLayout.Parent, { Size = UDim2.new(1 / Sections, -(((5 * (Sections - 1)) / Sections) + 1), 0, 10 + Section.UIListLayout.AbsoluteContentSize.Y + 10) }, 0.2)
            end)
		end

		return setmetatable({
			Page = config.Page,
			Container = Container,
            Resize = function()
                for i, v in pairs(tbl_sections) do
                    v.UIListLayout.Parent.Size = UDim2.new(1 / Sections, -(((5 * (Sections - 1)) / Sections) + 1), 0, 10 + v.UIListLayout.AbsoluteContentSize.Y + 10)
                    Container.UIListLayout.Parent.Size = UDim2.new(1, 0, 0, Container.UIListLayout.AbsoluteContentSize.Y)
                end
            end,
		}, Library.Section)
	end

	function Library:addPage(config) config = config or {}
		config.Library = self
		local Page = Library.Page.new(config)

		table.insert(self.Pages, Page)

        Page.Button.MouseButton1Click:Connect(function()
            if self.focusedPage == Page then return end

            self:SelectPage(Page, true)
            rippleEffect(Page.Button.Parent, 0.5)
        end)

        function Page:Select()
            Page.Library:SelectPage(self, true)
            return self
        end

		return Page
	end
	function Library:SelectPage(Page, Select)
		if Select and self.focusedPage == Page then return end

		if not Page and #self.Pages > 0 then
			return self:SelectPage(self.Pages[1], true)
		end

		if Select then
			Tween(Page.Button.Icon, { ImageTransparency = 0 }, 0.2)
			Tween(Page.Button.Title, { TextTransparency = 0 }, 0.2)

			Tween(Page.Button.UIPadding, { PaddingLeft = UDim.new(0, 10) }, 0.2)

			local focusedPage = self.focusedPage
			self.focusedPage = Page

			if focusedPage then
				self:SelectPage(focusedPage)
			end

            Tween(Page.Container.Parent, { CanvasPosition = Vector2.new(0, Page.Container.AbsoluteSize.Y * Page.Container.LayoutOrder) }, 0.2)
		else
			Tween(Page.Button.Icon, { ImageTransparency = 0.4 }, 0.2)
			Tween(Page.Button.Title, { TextTransparency = 0.4 }, 0.2)

			Tween(Page.Button.UIPadding, { PaddingLeft = UDim.new(0, 0) }, 0.2)

			if Page == self.focusedPage then
				self.focusedPage = nil
			end
		end
	end

	function Library.Page:addSection(config) config = config or {}
		config.Page = self

		local Section = Library.Section.new(config)
		table.insert(self.Sections, Section)

		return Section
	end

    --#region Modules
    function Library.Section:addButton(config) config = config or {}
        local Title = findByIndex(config, 'Title') or 'Button'
        local Section = findByIndex(config, 'Section') and tostring(findByIndex(config, 'Section')) or '1'
        local Disabled = findByIndex(config, 'Disabled') or false

		local Button = create('TextButton', {
			Name = 'Button',
			Parent = self.Container:FindFirstChild(Section) or self.Container['1'],
			Size = UDim2.new(1, 0, 0, 30),
			BackgroundColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].Background,
            TextColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].TextColor,
            FontFace = Font.fromName('Jura', Enum.FontWeight.Bold),
			Text = Title,
			RichText = true,
			TextSize = 14,
			AutoButtonColor = false,
            CornerRadius = UDim.new(0, 8)
		}, {
			create('Frame', {
				Name = 'Disabled',
				BackgroundColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].TextColor,
				BackgroundTransparency = 0.3,
				Size = UDim2.new(1, 0, 1, 0),
				Visible = Disabled,
				ZIndex = 2,
                CornerRadius = UDim.new(0, 8)
			}, {
				create('ImageLabel', {
					Image = 'rbxassetid://7733992528',
					ImageColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].TextColor,
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 16, 0, 16),
					Position = UDim2.new(0.5, 0, 0.5, 0),
					AnchorPoint = Vector2.new(0.5, 0.5),
					ZIndex = 2
				}),
			}),
		})

		local tbl = {
            Instance = Button,
        }
        function tbl:Update(config) config = config or {}
            local Title = findByIndex(config, 'Title')
            local Section = findByIndex(config, 'Section') and tostring(findByIndex(config, 'Section'))
            local Disabled = findByIndex(config, 'Disabled')

            if Title then
                self.Instance.Text = Title
            end
            if Section then
                self.Instance.Parent = self.Instance.Parent.Parent:FindFirstChild(Section) or self.Instance.Parent.Parent['1']
            end
            if Disabled ~= nil then
                self.Instance.Disabled.Visible = Disabled
            end
        end

		local Toggling
		Button.MouseButton1Click:Connect(function()
			if Toggling or Button.Disabled.Visible then
				return
			end

			Toggling = true

			rippleEffect(Button, 0.5)
			if findByIndex(config, 'CallBack') then
				findByIndex(config, 'CallBack')()
			end

			Toggling = false
		end)

        return tbl
    end
    function Library.Section:addDropdown(config) config = config or {}
        local Title = findByIndex(config, 'Title') or 'Dropdown'
        local Section = findByIndex(config, 'Section') and tostring(findByIndex(config, 'Section')) or '1'
		local List = findByIndex(config, 'List') or {}
        local Multi = findByIndex(config, 'Multi')

		local Dropdown = create('Frame', {
			Name = 'Dropdown',
			Parent = self.Container:FindFirstChild(Section) or self.Container['1'],
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 30),
			ClipsDescendants = true,
		}, {
            create('Frame', {
                Name = 'Search',
                BackgroundColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].Background,
                Size = UDim2.new(1, -16 -5, 0, 30),
                CornerRadius = UDim.new(0, 8),
            }, {
                create('TextBox', {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    ClearTextOnFocus = false,
                    Text = '',
                    TextSize = 16,
                    TextColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].TextColor,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    FontFace = Font.fromName('Jura', Enum.FontWeight.Regular),
					PlaceholderText = Title,
					PlaceholderColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].Grey,
                    CornerRadius = UDim.new(0, 8),
                    Padding = {
                        Left = UDim.new(0, 10)
                    },
                    Function = function(TextBox)
                        repeat task.wait() until TextBox.Parent
                        local Delete_btn = TextBox.Parent:WaitForChild('Delete')
                        TextBox:GetPropertyChangedSignal('Text'):Connect(function()
                            Delete_btn.Visible = TextBox.Text ~= ''
                            TextBox.Size = UDim2.new(1, TextBox.Text ~= '' and -26 or 0, 1, 0)
                        end)
                    end
                }),
                create('ImageButton', {
                    Name = 'Delete',
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(1, -5, 0.5, 0),
                    AnchorPoint = Vector2.new(1, 0.5),
                    ImageColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].TextColor,
                    Image = 'rbxassetid://7072725342',
                    Visible = false,
                    Function = function(ImageButton)
                        repeat task.wait() until ImageButton.Parent
                        local TextBox = ImageButton.Parent:WaitForChild('TextBox')
                        ImageButton.MouseButton1Click:Connect(function()
                            TextBox.Text = ''
                        end)
                    end
                }),
            }),
            create('ImageButton', {
                Name = 'Button',
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(1, 0, 0, 8),
                AnchorPoint = Vector2.new(1, 0),
                ImageColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].TextColor,
                Image = 'rbxassetid://7072706663',
            }),
            create('Frame', {
                BackgroundColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].Background,
				Size = UDim2.new(1, 0, 1, -30 -5),
                Position = UDim2.new(0, 0, 1, 0),
                AnchorPoint = Vector2.new(0, 1),
                CornerRadius = UDim.new(0, 8),
                Padding = {
                    Left = UDim.new(0, 10),
                    Right = UDim.new(0, 5),
                    Top = UDim.new(0, 5),
                    Bottom = UDim.new(0, 5),
                },
            }, {
                create('ScrollingFrame', {
                    Name = 'List',
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    ScrollBarThickness = 0,
                    Size = UDim2.new(1, 0, 1, 0),
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    ScrollingEnabled = false,
                }, {
                    create('UIListLayout', {
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0, 0),
                    }),
                }),
            }),
		})

		local tbl = {
            Instance = Dropdown,
        }
        function tbl:Update(config) config = config or {}
            local Title = findByIndex(config, 'Title')
            local Section = findByIndex(config, 'Section') and tostring(findByIndex(config, 'Section'))
            local List = findByIndex(config, 'List')
            local Multi = findByIndex(config, 'Multi')

			if Title then
				self.Instance.Search.TextBox.PlaceholderText = Title
			end
            if Section then
                self.Instance.Parent = self.Instance.Parent.Parent:FindFirstChild(Section) or self.Instance.Parent.Parent['1']
            end

			if List and typeof(List) == 'table' then
                for i, Button in pairs(self.Instance.Frame.List:GetChildren()) do
                    if Button:IsA('TextButton') then
                        Button:Destroy()
                    end
                end
                local selectedItems = {}
                for i, v in pairs(List) do
                    local Item = create('TextButton', {
                        BackgroundTransparency = 1,
                        Parent = self.Instance.Frame.List,
                        Size = UDim2.new(1, 0, 0, 30),
                        Text = '',
                        AutoButtonColor = false,
                    }, {
                        create('UIListLayout', {
                            Padding = UDim.new(0, 10),
                            VerticalAlignment = Enum.VerticalAlignment.Center,
                            FillDirection = Enum.FillDirection.Horizontal,
                            SortOrder = Enum.SortOrder.LayoutOrder,
                        }),
                        create('TextLabel', {
                            BackgroundTransparency = 1,
                            LayoutOrder = 1,
                            Size = UDim2.new(1, -10 -30, 1, 0),
                            FontFace = Font.fromName('Jura', Enum.FontWeight.Regular),
                            RichText = true,
                            Text = tostring(i),
                            TextColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].TextColor,
                            TextSize = 14,
                            TextXAlignment = Enum.TextXAlignment.Left,
                        }),
                        create('Frame', {
                            Name = 'Toggle',
                            LayoutOrder = 2,
                            BackgroundColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].Contrast,
                            Size = UDim2.new(0, 22, 0, 22),
                            CornerRadius = UDim.new(0, 8)
                        }, {
                            create('ImageLabel', {
                                Name = 'Icon',
                                BackgroundTransparency = 1,
                                Visible = false,
                                Size = UDim2.new(0, 16, 0, 16),
                                Position = UDim2.new(0.5, 0, 0.5, 0),
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                Image = 'rbxassetid://7072706620',
                                ImageColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].TextColor,
                            }),
                        }),
                    })

                    Item.MouseButton1Click:Connect(function()
                        if Item.Toggle.Icon.Visible then
                            Item.Toggle.Icon.Visible = false
                            Tween(Item.Toggle, { BackgroundColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].Contrast }, 0.2)

                            selectedItems[i] = nil
                        else
                            Item.Toggle.Icon.Visible = true
                            Tween(Item.Toggle, { BackgroundColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].Accent }, 0.2)

                            if not Multi then
                                for i_, v_ in pairs(selectedItems) do
                                    v_[1].Toggle.Icon.Visible = false
                                    Tween(v_[1].Toggle, { BackgroundColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].Contrast }, 0.2)

                                    selectedItems[i_] = nil
                                end
                            end

                            selectedItems[i] = {
                                Item,
                                v
                            }
                        end
                        local tbl = {}
                        for i, v in pairs(selectedItems) do
                            table.insert(tbl, v[2])
                        end

                        if findByIndex(config, 'CallBack') then
                            findByIndex(config, 'CallBack')(Multi and #tbl > 0 and tbl or Item.Toggle.Icon.Visible and v)
                        end
                    end)
                end
			end
        end

		tbl:Update({
			List = List,
            Multi = Multi,
			CallBack = findByIndex(config, 'CallBack'),
		})

        local Toggling
		Dropdown.Button.MouseButton1Click:Connect(function()
            if Toggling then return end
            Toggling = true

            if Dropdown.Button.Rotation == 0 then
                Tween(Dropdown, { Size = UDim2.new(1, 0, 0, 30 + 5 + 10 + math.min(Dropdown.Frame.List.UIListLayout.AbsoluteContentSize.Y, 90)) }, 0.2)
                Dropdown.Frame.List.CanvasSize = UDim2.new(0, 0, 0, Dropdown.Frame.List.UIListLayout.AbsoluteContentSize.Y)

                Tween(Dropdown.Button, { Rotation = 180 }, 0.2).Completed:Wait()
            else
				Tween(Dropdown, { Size = UDim2.new(1, 0, 0, 30) }, 0.2)
                Tween(Dropdown.Button, { Rotation = 0 }, 0.2).Completed:Wait()
            end

            Toggling = false
		end)

		Dropdown.Search.TextBox.Focused:Connect(function()
			if Dropdown.Button.Rotation == 0 then
                Tween(Dropdown, { Size = UDim2.new(1, 0, 0, 30 + 5 + 10 + math.min(Dropdown.Frame.List.UIListLayout.AbsoluteContentSize.Y, 90)) }, 0.2)
                Dropdown.Frame.List.CanvasSize = UDim2.new(0, 0, 0, Dropdown.Frame.List.UIListLayout.AbsoluteContentSize.Y)

                Tween(Dropdown.Button, { Rotation = 180 }, 0.2).Completed:Wait()
			end
		end)

		Dropdown.Search.TextBox:GetPropertyChangedSignal('Text'):Connect(function()
			for i, v in pairs(Dropdown.Frame.List:GetChildren()) do
				if v:IsA('TextButton') then
					if v.TextLabel.Text:lower():find(Dropdown.Search.TextBox.Text:lower()) then
						v.Visible = true
					else
						v.Visible = false
					end
				end
			end
            Tween(Dropdown, { Size = UDim2.new(1, 0, 0, 30 + 5 + 10 + math.min(Dropdown.Frame.List.UIListLayout.AbsoluteContentSize.Y, 90)) }, 0.2)
            Dropdown.Frame.List.CanvasSize = UDim2.new(0, 0, 0, Dropdown.Frame.List.UIListLayout.AbsoluteContentSize.Y)
		end)

        local List_pos = 0
        Dropdown.Frame.InputChanged:Connect(function(input, processed)
            if not processed and input.UserInputType == Enum.UserInputType.MouseWheel then
                if input.Position.Z > 0 then
                    List_pos = math.max(List_pos - 60, 0)
                else
                    List_pos = math.min(List_pos + 60, Dropdown.Frame.List.UIListLayout.AbsoluteContentSize.Y - Dropdown.Frame.List.AbsoluteSize.Y)
                end
                if List_pos ~= Dropdown.Frame.List.CanvasPosition.Y then
                    Tween(Dropdown.Frame.List, { CanvasPosition = Vector2.new(0, List_pos) }, 0.2)
                end
            end
        end)
        return tbl
	end
	function Library.Section:addToggle(config) config = config or {}
        local Title = findByIndex(config, 'Title') or 'Toggle'
        local Section = findByIndex(config, 'Section') and tostring(findByIndex(config, 'Section')) or '1'
		local Default = findByIndex(config, 'Default') or false

		local Toggle = create('TextButton', {
			Name = 'Toggle',
			Parent = self.Container:FindFirstChild(Section) or self.Container['1'],
			Size = UDim2.new(1, 0, 0, 30),
            BackgroundTransparency = 1,
			Text = '',
			AutoButtonColor = false,
		}, {
			create('TextLabel', {
				Name = 'Title',
				Size = UDim2.new(1, -55, 1, 0),
				BackgroundTransparency = 1,
                FontFace = Font.fromName('Jura', Enum.FontWeight.Bold),
				RichText = true,
				ClipsDescendants = true,
				Text = Title,
                TextColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].TextColor,
                TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
			}),
            create('Frame', {
                Name = 'Button',
                BackgroundColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].Background,
                Size = UDim2.new(0, 50, 0, 22),
                Position = UDim2.new(1, 0, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                CornerRadius = UDim.new(1, 0),
                Padding = UDim.new(0, 2),
            }, {
                create('TextLabel', {
                    Name = 'Status',
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -10, 1, 0),
                    Position = UDim2.new(0.5, 0, 0, 0),
                    AnchorPoint = Vector2.new(0.5, 0),
                    FontFace = Font.fromName('Jura', Enum.FontWeight.Regular),
                    TextColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].TextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Text = 'off',
                }),
                create('ImageLabel', {
                    Name = 'Circle',
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 18, 0, 18),
                    Position = UDim2.new(0, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    ImageColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].TextColor,
                    Image = 'rbxassetid://6031625146',
                })
            })
		})

		local tbl = {
            Instance = Toggle,
        }
        function tbl:Update(config) config = config or {}
            local Title = findByIndex(config, 'Title')
            local Section = findByIndex(config, 'Section') and tostring(findByIndex(config, 'Section'))
            local Value = findByIndex(config, 'Value')

            if Title then
                self.Instance.Title.Text = Title
            end
            if Section then
                self.Instance.Parent = self.Instance.Parent.Parent:FindFirstChild(Section) or self.Instance.Parent.Parent['1']
            end
            if Value then
                self.Instance.Button.Status.TextXAlignment = Enum.TextXAlignment.Left
                self.Instance.Button.Status.Text = 'on'

                Tween(self.Instance.Button.Circle, {
                    Position = UDim2.new(1, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(1, 0.5),
                    ImageColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].Accent
                }, 0.2).Completed:Wait()
            else
                self.Instance.Button.Status.TextXAlignment = Enum.TextXAlignment.Right
                self.Instance.Button.Status.Text = 'off'

                Tween(self.Instance.Button.Circle, {
                    Position = UDim2.new(0, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    ImageColor3 = Theme[Library.Settings.DarkMode and 'Dark' or 'Light'].TextColor
                }, 0.2).Completed:Wait()
            end
        end

		tbl:Update({ Value = Default })

        local Toggling = false
        Toggle.MouseButton1Click:Connect(function()
            if Toggling then return end
            Toggling = true

            if Toggle.Button.Status.Text == 'off' then
                tbl:Update({ Value = true })
                if findByIndex(config, 'CallBack') then
                    findByIndex(config, 'CallBack')(true)
                end
            else
                tbl:Update({ Value = false })
                if findByIndex(config, 'CallBack') then
                    findByIndex(config, 'CallBack')(false)
                end
            end

            Toggling = false
        end)

        return tbl
	end
    --#endregion
end

local GUI = Library.new()
if not GUI then return end

-- Clover Kingdom Grimshot
if game:GetService("ReplicatedStorage"):FindFirstChild("Remotes") and game:GetService("ReplicatedStorage"):FindFirstChild("Remotes"):FindFirstChild("JustStopHackingBruh") then
    Player.Idled:connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)

    local gt = getrawmetatable(game)
    local old = gt.__newindex
    setreadonly(gt, false)
    gt.__newindex = function(self ,key, value)
        if key == 'CFrame' and self.Name == 'HumanoidRootPart' and self.Parent.Name == Player.Name and not checkcaller() then
            return old(self ,key, self.CFrame)
        end
        old(self, key, value)
    end

    function SetMagic(Magic)
        Player.Character:WaitForChild('Humanoid'):UnequipTools()

        if Player.Backpack:FindFirstChild('Fake Magic') then Player.Backpack:FindFirstChild('Fake Magic'):Destroy() end
        if not Magic then return end

        local Equipped = false
        local MagicBook = create('Tool', {
            Name = 'Fake Magic',
            Parent = Player.Backpack,
            ToolTip = 'You can remove this item by equipping it and using the RightShift key',
            RequiresHandle = false,
            CanBeDropped = false,
            Function = function(MagicBook)
                MagicBook.Equipped:Connect(function()
                    Equipped = true
                    -- Player.Character.Punch.offCombat:Fire(true)
                    Player.PlayerGui[Magic .. ' SkillUI'].Enabled = true
                end)
                MagicBook.Unequipped:Connect(function()
                    Equipped = false
                    -- Player.Character.Punch.offCombat:Fire(false)
                    Player.PlayerGui[Magic .. ' SkillUI'].Enabled = false
                end)
            end
        }, {
            create('BoolValue', {
                Name = 'hasTransformation',
                Value = game:GetService('ReplicatedStorage').Remotes.GUIRemotes.checkSkillDesc2:InvokeServer(Magic).SkillsTransformation.SkillName ~= ''
            }),
            create('BoolValue', {
                Name = 'Awakening',
                Value = false
            })
        })
        clone(game:GetService('ReplicatedStorage').GUIs.SkillUI, {
            Name = Magic .. ' SkillUI',
            Enabled = false,
            Function = function(SkillUI)
                SkillUI.Magic.Value = Magic

                SkillUI.Skills1.MouseButton1Click:Connect(function()
                    game:GetService('ReplicatedStorage').Remotes.SkillRemote.castSpell:FireServer(Mouse.Hit.LookVector, Mouse.Hit, Magic .. ' 1', Magic, 3)
                end)
                SkillUI.Skills2.MouseButton1Click:Connect(function()
                    game:GetService('ReplicatedStorage').Remotes.SkillRemote.castSpell:FireServer(Mouse.Hit.LookVector, Mouse.Hit, Magic .. ' 2', Magic, 3)
                end)
                SkillUI.Skills3.MouseButton1Click:Connect(function()
                    game:GetService('ReplicatedStorage').Remotes.SkillRemote.castSpell:FireServer(Mouse.Hit.LookVector, Mouse.Hit, Magic .. ' 3', Magic, 3)
                end)
                SkillUI.Skills4.MouseButton1Click:Connect(function()
                    game:GetService('ReplicatedStorage').Remotes.SkillRemote.castSpell:FireServer(Mouse.Hit.LookVector, Mouse.Hit, Magic .. ' 4', Magic, 3)
                end)
                SkillUI.Skills5.MouseButton1Click:Connect(function()
                    game:GetService('ReplicatedStorage').Remotes.SkillRemote.castSpell:FireServer(Mouse.Hit.LookVector, Mouse.Hit, Magic .. ' 5', Magic, 3)
                end)
                SkillUI.Skills6.MouseButton1Click:Connect(function()
                    game:GetService('ReplicatedStorage').Remotes.SkillRemote.castSpell:FireServer(Mouse.Hit.LookVector, Mouse.Hit, Magic .. ' 6', Magic, 3)
                end)
                SkillUI.Skills7.MouseButton1Click:Connect(function()
                    game:GetService('ReplicatedStorage').Remotes.SkillRemote.castSpell:FireServer(Mouse.Hit.LookVector, Mouse.Hit, Magic .. ' 7', Magic, 3)
                end)
                SkillUI.Skills8.MouseButton1Click:Connect(function()
                    game:GetService('ReplicatedStorage').Remotes.SkillRemote.castSpell:FireServer(Mouse.Hit.LookVector, Mouse.Hit, Magic .. ' 8', Magic, 3)
                end)
                SkillUI.Skills9.MouseButton1Click:Connect(function()
                    game:GetService('ReplicatedStorage').Remotes.SkillRemote.castSpell:FireServer(Mouse.Hit.LookVector, Mouse.Hit, Magic .. ' 9', Magic, 3)
                end)
                SkillUI.Skills10.MouseButton1Click:Connect(function()
                    game:GetService('ReplicatedStorage').Remotes.SkillRemote.castSpell:FireServer(Mouse.Hit.LookVector, Mouse.Hit, Magic .. ' 10', Magic, 3)
                end)

                local function onAwakening(value)
                    if value then
                        for i = 1, 5, 1 do
                            pcall(function()
                                SkillUI['Skills' .. 5 + i].Visible = true
                                SkillUI['Skills' .. i].Visible = false
                            end)
                        end
                    else
                        for i = 1, 5, 1 do
                            pcall(function()
                                SkillUI['Skills' .. 5 + i].Visible = false
                                SkillUI['Skills' .. i].Visible = true
                            end)
                        end
                    end
                end
                MagicBook.Awakening.Changed:Connect(function(value)
                    onAwakening(value)
                end)

                SkillUI.Parent = Player.PlayerGui
            end
        })

        local Magic_Input = game:GetService('UserInputService').InputBegan:connect(function(input, processed)
            if not processed and Equipped then
                if input.KeyCode == Enum.KeyCode.RightShift then
                    MagicBook:Destroy()
                end
                if input.KeyCode == Enum.KeyCode.E then
                    game:GetService('ReplicatedStorage').Remotes.SkillRemote.castSpell:FireServer(Mouse.Hit.LookVector, Mouse.Hit, Magic .. ' ' .. (MagicBook.Awakening.Value and 6 or 1), Magic, 3)
                end
                if input.KeyCode == Enum.KeyCode.R then
                    game:GetService('ReplicatedStorage').Remotes.SkillRemote.castSpell:FireServer(Mouse.Hit.LookVector, Mouse.Hit, Magic .. ' ' .. (MagicBook.Awakening.Value and 7 or 2), Magic, 3)
                end
                if input.KeyCode == Enum.KeyCode.F then
                    game:GetService('ReplicatedStorage').Remotes.SkillRemote.castSpell:FireServer(Mouse.Hit.LookVector, Mouse.Hit, Magic .. ' ' .. (MagicBook.Awakening.Value and 8 or 3), Magic, 3)
                end
                if input.KeyCode == Enum.KeyCode.G then
                    game:GetService('ReplicatedStorage').Remotes.SkillRemote.castSpell:FireServer(Mouse.Hit.LookVector, Mouse.Hit, Magic .. ' ' .. (MagicBook.Awakening.Value and 9 or 4), Magic, 3)
                end
                if input.KeyCode == Enum.KeyCode.V then
                    game:GetService('ReplicatedStorage').Remotes.SkillRemote.castSpell:FireServer(Mouse.Hit.LookVector, Mouse.Hit, Magic .. ' ' .. (MagicBook.Awakening.Value and 10 or 5), Magic, 3)
                end
                if input.KeyCode == Enum.KeyCode.T then
                    if MagicBook.hasTransformation.Value then
                        MagicBook.Awakening.Value = not MagicBook.Awakening.Value
                        local a = game:GetService('ReplicatedStorage').Remotes.SkillRemote.ToggleTransformations:FireServer(Magic)
                        print(a)
                    else
                        game:GetService('ReplicatedStorage').Remotes.SkillRemote.castSpell:FireServer(Mouse.Hit.LookVector, Mouse.Hit, Magic .. ' 6', Magic, 3)
                    end
                end
            end
        end)

        local Died_Connection = Player.Character:WaitForChild('Humanoid').Died:Connect(function()
            SetMagic(Magic)
        end)
        MagicBook.Destroying:Connect(function()
            Died_Connection:Disconnect()
            Magic_Input:Disconnect()
        end)
    end

    local Farm_Boss
    local Inf_Quests
    local Magics = {}
    for i, _ in pairs(require(Workspace.ModuleFolder.SkillsCooldown)) do
        Magics[i] = i
    end

    local page = GUI:addPage()
    do
        local section = page:addSection({ Sections = 2 })
        section:addDropdown({ Title = 'Magic', List = Magics, CallBack = function(value)
            SetMagic(value)
        end })
        section:addToggle({ Title = 'Farm Boss: Zagred', CallBack = function(value)
            Farm_Boss = value
        end })
        section:addButton( { Title = 'Delete Book Holders', Section = 2, CallBack = function()
            if Player.Character and Player.Character:FindFirstChild('BookHolders') then
                Player.Character:FindFirstChild('BookHolders'):Destroy()
            end
        end })
        section:addToggle({ Title = 'Inf Quests', Section = 2, CallBack = function(value)
            Inf_Quests = value
            if Player.PlayerGui:FindFirstChild('QuestUI') and Player.PlayerGui.QuestUI:FindFirstChild('QuestList') then
                for i, v in pairs(Player.PlayerGui.QuestUI.QuestList:GetChildren()) do
                    pcall(function()
                        v.Visible = true
                    end)
                end
            end
        end })
        local connection_Inf_Quests
        connection_Inf_Quests = Player.PlayerGui.ChildAdded:Connect(function(child)
            if not GUI.Settings.Enabled then return connection_Inf_Quests:Disconnect() end

            if Inf_Quests and child.Name == 'QuestUI' then
                if child:FindFirstChild('QuestList') then
                    for i, v in pairs(child.QuestList:GetChildren()) do
                        pcall(function()
                            v.Visible = true
                        end)
                    end
                end
            end
        end)
        local weapon
        local weapons = {}
        for i, v in pairs(require(Workspace.ModuleFolder.ItemsRequirement).ItemsDescription) do
            if Player.Backpack:FindFirstChild(i) or Player.Character:FindFirstChild(i) then
                weapon = i
            end
            table.insert(weapons, i)
        end
        task.spawn(function()
            while GUI.Settings.Enabled do task.wait()
                if Farm_Boss then
                    pcall(function()
                        Player.Character.Humanoid:EquipTool(Player.Backpack[weapon])
                    end)
                    pcall(function()
                        Player.Character.HumanoidRootPart.CFrame = Workspace.Zagred.HumanoidRootPart.CFrame
                    end)
                    if Player.Character and Player.Character:FindFirstChild('Humanoid') and Player.Character.Humanoid.Health <= 0 then
                        task.wait(0.1)
                        pcall(function()
                            for i, v in pairs(Player.Character[weapon].SkillsRemote:GetChildren()) do
                                v:FireServer()
                            end
                        end)
                    elseif Player.Character and Player.Character:FindFirstChild('HumanoidRootPart') and (Player.Character.HumanoidRootPart.Position - Workspace.Zagred.HumanoidRootPart.Position).Magnitude < 5 then
                        pcall(function()
                            wait(0.1)
                            Player.Character.Humanoid.Health = 0
                        end)
                    end
                end
            end
        end)
    end
    do
        local section = page:addSection()
        section:addDropdown({ Title = 'Teleport', List = require(Workspace.ModuleFolder.Places).PlacesLocation, CallBack = function(value)
            Player:Kick("\nTeleporting...")
            game:GetService('TeleportService'):Teleport(value, Player)
        end })
    end
end
