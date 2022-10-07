if not game:IsLoaded() then
	game.Loaded:Wait()
end
-- game variables
local player = game:GetService('Players').LocalPlayer
local mouse = player:GetMouse()
-- Library variables
local library = {
	Version = '1',
	Parent = player.PlayerGui,
	Settings = {
		NewUser = true,
		Prefix = Enum.KeyCode.LeftAlt,
		Elements_Font = Enum.Font.SourceSans,
		Notifications_Max = 4,
		theme = {
			Background = Color3.fromRGB(10,10,15),
			DarkContrast = Color3.fromRGB(14,17,24),
			LightContrast = Color3.fromRGB(105, 105, 105),
			TextColor = Color3.fromRGB(254, 254, 254),
			PlaceHolderColor = Color3.fromRGB(190, 190, 190),

			Inactive = Color3.fromRGB(130, 130, 130),
			Error = Color3.fromRGB(252, 90, 90),
			Warning = Color3.fromRGB(255, 198, 66),
			Info = Color3.fromRGB(30, 116, 255),
			Success = Color3.fromRGB(0,204,153),
		},
	},
	functions = {},
	page = {},
	section = {},
	notifications = {},

	binds = {},
	connections = {},
	end_funcs = {},
	objects = {},
}

table.insert(library.end_funcs, function()
	for i, v in pairs(library.connections) do
		pcall(function()
			v:Disconnect()
		end)
		library.connections[i] = nil
	end
    for i, v in pairs(library.binds) do
        pcall(function()
            v:UnBind()
        end)
        library.binds[i] = nil
    end
end)

-- encode/decode - save/load function
do
	local types = {
		['nil'] = '0',
		['boolean'] = '1',
		['number'] = '2',
		['string'] = '3',
		['table'] = '4',

		['Vector3'] = '5',
		['CFrame'] = '6',
		['EnumItem'] = '7',
		['Color3'] = '8',

		-- ['function'] = '10',
	}
	local typeof = typeof or type
	function library.encode(data)
		if data == nil then
			return
		end
		local function encode(t, ...)
			local type = typeof(t)
			local type_num = types[type]
			local response = ''

			if type == 'nil' then
				response = type_num .. '=' .. '0'
			elseif type == 'boolean' then
				response = type_num .. '=' .. ((t == true and '1') or '0')
			elseif type == 'number' then
				response = type_num .. '=' .. tostring(t)
			elseif type == 'string' then
				response = type_num .. '=' .. tostring(t)
			elseif type == 'table' then
				local new = {}
				for i, v in pairs(t) do
					local value = encode(v)
					if typeof(value) == 'table' then
						new[i] = game:GetService('HttpService'):JSONEncode(value)
					else
						new[i] = value
					end
				end
				return new
			elseif type == 'Vector3' then
				response = type_num .. '=' .. table.concat({tostring(t.X), tostring(t.Y), tostring(t.Z)}, ',')
			elseif type == 'CFrame' then
				response = type_num .. '=' .. table.concat({t:GetComponents()}, ',')
			elseif type == 'EnumItem' then
				response = type_num .. '=' .. tostring(table.find(Enum:GetEnums(), t.EnumType)) .. '-' .. t.Name
			elseif type == 'Color3' then
				response = type_num .. '=' .. table.concat({tostring(t.R), tostring(t.G), tostring(t.B)}, ',')
			end
			return response
		end

		return game:GetService('HttpService'):JSONEncode(encode(data))
	end
	function library.decode(data)
		if data == nil then
			return
		end
		local rtypes = {}
		for i, v in pairs(types) do
			rtypes[v] = i
		end
		local function decode(t, ...)
			local function getType()
				local encode_value = t
				pcall(function ()
					encode_value = game:GetService('HttpService'):JSONDecode(encode_value)
				end)
				if typeof(encode_value) == 'table' then
					return 'table'
				else
					return rtypes[string.sub(encode_value, 1, (string.find(encode_value, '=') or 1) - 1)]
				end
			end
			local function getValue()
				local encode_value = t
				pcall(function ()
					encode_value = game:GetService('HttpService'):JSONDecode(encode_value)
				end)
				return string.sub(encode_value, string.find(encode_value, '=') + 1, #encode_value)
			end
			local function get_after(str, value)
				return string.sub(str, string.find(str, value) + 1, #str)
			end
			local function get_before(str, value)
				return string.sub(str, 1, string.find(str, value) - 1)
			end

			local response
			if getType() == 'nil' then
				response = nil
			elseif getType() == 'boolean' then
				response = getValue() == '1' and true or false
			elseif getType() == 'number' then
				response = getValue()
			elseif getType() == 'string' then
				response = getValue()
			elseif getType() == 'table' then
				local function stringToTable(value)
					pcall(function ()
						value = game:GetService('HttpService'):JSONDecode(value)
					end)
					local new_table = {}
					for i, v in pairs(value) do
						local new_value
						pcall(function ()
							new_value = game:GetService('HttpService'):JSONDecode(v)
						end)
						if typeof(new_value) == 'table' then
							new_table[i] = stringToTable(v)
						else
							new_table[i] = decode(v)
						end
					end
					return new_table
				end
				response = stringToTable(t)
			elseif getType() == 'Vector3' then
				response = Vector3.new(table.unpack(string.split(getValue(), ',')))
			elseif getType() == 'CFrame' then
				response = CFrame.new(table.unpack(string.split(getValue(), ',')))
			elseif getType() == 'EnumItem' then
				local value = getValue()
				response = Enum:GetEnums()[tonumber(get_before(value, '-'))][get_after(value, '-')]
			elseif getType() == 'Color3' then
				response = Color3.new(table.unpack(string.split(getValue(), ',')))
			end

			return response
		end

		return decode(data)
	end

	function library.Save(config)
		if writefile then
			writefile('Premier UI/Settings.lua', library.encode(config))
		end
	end
	function library.Load()
		if isfile and readfile then
			if isfile('Premier UI/Settings.lua') then
				local function loadSettings(tbl, loadIn)
					for i, v in pairs(tbl) do
						if typeof(v) ~= 'table' then
							loadIn[i] = v
						else
							loadSettings(v, loadIn[i])
						end
					end
				end
				loadSettings(library.decode(readfile('Premier UI/Settings.lua')), library)
			end
		end
	end
end

local AssetToLoad = {}
do
	function newInstance(className, properties, children, radius)
		local object = Instance.new(className)
		for i, v in pairs(properties or {}) do
			object[i] = v
			if typeof(v) == 'Color3' then
				for p, k in pairs(library.Settings.theme) do
					if k == v then
						library.objects[p] = library.objects[p] or {}
						library.objects[p][i] = library.objects[p][i] or setmetatable({}, { _mode = 'k' })
						table.insert(library.objects[p][i], object)
						local lastTheme = library.objects[p][i]
						object:GetPropertyChangedSignal(i):Connect(function()
							if lastTheme then
								if table.find(lastTheme, object) then
									table.remove(lastTheme, table.find(lastTheme, object))
									lastTheme = nil
								end
							end
							for j, h in pairs(library.Settings.theme) do
								if h == object[i] then
									library.objects[j] = library.objects[j] or {}
									library.objects[j][i] = library.objects[j][i] or setmetatable({}, { _mode = 'k' })
									table.insert(library.objects[j][i], object)
									lastTheme = library.objects[j][i]
								end
							end
						end)
					end
				end
			elseif typeof(v) == "string" then
				if v:match('rbxassetid://') or v:match('https://www.roblox.com/asset/?id=') then
					table.insert(AssetToLoad, v)
				end
			end
		end
		for i, module in pairs(children or {}) do
			pcall(function()
				module.Parent = object
			end)
		end
		if radius then
			local uicorner = Instance.new('UICorner', object)
			uicorner.CornerRadius = radius
		end
		return object
	end
	function draggingInstance(instance, parent)
		parent = parent or instance
		local Dragging = false
		instance.InputBegan:Connect(function(input, processed)
			if not processed and input.UserInputType == Enum.UserInputType.MouseButton1 or library.IsMobile and Enum.UserInputType.Touch then
				local tweens = {}
				local mousePos, framePos = input.Position, parent.Position
				Dragging = true
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						Dragging = false
					end
				end)
				repeat
					task.wait()
					local delta = Vector2.new(mouse.X - mousePos.X, mouse.Y - mousePos.Y)
					spawn(function()
						local tween = Tween(parent, { Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y) }, 0.1)
						table.insert(tweens, tween)
					end)
				until not Dragging
				for i, v in ipairs(tweens) do
					if v then
						v:Cancel()
					end
				end
			end
		end)
	end
	function Resizable(instance, button)
        local InitialSize = instance.Size
        local Pressing = false

        local RecordedLastX = nil
        local RecordedLastY = nil
        local NowPositionX = nil
        local NowPositionY = nil

        button.InputBegan:connect(function(key)
            if key.UserInputType == Enum.UserInputType.MouseButton1 then
                Pressing = true
                RecordedLastX = mouse.X
                RecordedLastY = mouse.Y
                button.InputEnded:connect(function(key2)
                    if key == key2 then
                        Pressing =  false
                    end
                end)
            end
        end)

        button.MouseEnter:connect(function()
            button.MouseLeave:connect(function()
                RecordedLastX = mouse.X
                RecordedLastY = mouse.Y
            end)
        end)

        mouse.Move:connect(function()
            if Pressing == true then
                NowPositionX = mouse.x
                NowPositionY = mouse.y

                local ChangeX = NowPositionX - RecordedLastX
                local ChangeY = NowPositionY - RecordedLastY

                RecordedLastX = mouse.X
                RecordedLastY = mouse.Y

                instance.Size = UDim2.new(instance.Size.X.Scale, instance.Size.X.Offset + ChangeX, instance.Size.Y.Scale, instance.Size.Y.Offset + ChangeY)
            end
        end)

        instance.Changed:connect(function()
            if instance.Size.X.Offset < InitialSize.X.Offset and instance.Size.Y.Offset < InitialSize.Y.Offset then
                instance.Size = UDim2.new(InitialSize.X.Scale, InitialSize.X.Offset, InitialSize.Y.Scale, InitialSize.Y.Offset)
            elseif instance.Size.X.Offset < InitialSize.X.Offset then
                instance.Size = UDim2.new(InitialSize.X.Scale, InitialSize.X.Offset, InitialSize.Y.Scale, instance.Size.Y.Offset)
            elseif instance.Size.Y.Offset < InitialSize.Y.Offset then
                instance.Size = UDim2.new(InitialSize.X.Scale, instance.Size.X.Offset, InitialSize.Y.Scale, InitialSize.Y.Offset)
            end
        end)
	end
    -- Functions
	function betterFindIndex(t, value)
		for i, v in pairs(t) do
			if tostring(i):lower() == value:lower() then
				return v
			end
		end
	end
	function getTextSize(Text, TextSize, Font)
		return game:GetService('TextService'):GetTextSize(Text:gsub('<[^<>]->', ''), TextSize, Font, Vector2.new(math.huge, TextSize))
	end
	function Tween(instance, properties, duration, ...)
		local Tween = game:GetService('TweenService'):Create(instance, TweenInfo.new(duration, ...), properties)
		Tween:Play()
		return Tween
	end
	function draggingEnded(callback)
		table.insert(library.functions.ended, callback)
	end
    -- Keys functions
	function initializeKeybind()
		library.functions.keybinds = {}
		library.functions.ended = {}
		game:GetService('UserInputService').InputBegan:Connect(function(key, proc)
			if library.functions.keybinds[key.KeyCode] and not proc then
				for i, bind in pairs(library.functions.keybinds[key.KeyCode]) do
					bind()
				end
			end
		end)
		game:GetService('UserInputService').InputEnded:Connect(function(key)
			if key.UserInputType == Enum.UserInputType.MouseButton1 then
				for i, callback in pairs(library.functions.ended) do
					callback()
				end
			end
		end)
	end
	function bindToKey(key, callback)
		library.functions.keybinds[key] = library.functions.keybinds[key] or {}
		table.insert(library.functions.keybinds[key], callback)
		return {
			UnBind = function()
				for i, bind in pairs(library.functions.keybinds[key]) do
					if bind == callback then
						table.remove(library.functions.keybinds[key], i)
					end
				end
			end,
		}
	end
	function keyPressed()
		local key = game:GetService('UserInputService').InputBegan:Wait()
		while key.UserInputType ~= Enum.UserInputType.Keyboard do
			key = game:GetService('UserInputService').InputBegan:Wait()
		end
		task.wait()
		return key
	end
    -- Effects
	function rippleEffect(instance, duration, extra)
		extra =  extra or 0
		local Ripple = newInstance('Frame', {
			Parent = instance,
			BackgroundColor3 = library.Settings.theme.TextColor,
			BackgroundTransparency = 0.6,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			ZIndex = 10,
		}, {}, UDim.new(1, 0))
		local tween = Tween(Ripple, {
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(instance.AbsoluteSize.X + extra, instance.AbsoluteSize.X + extra),
		}, duration or 0)
		tween.Completed:Connect(function()
			Ripple:Destroy()
		end)
		return tween
	end
	function writeEffect(TextLabel, delay)
		local displayText = TextLabel.Text
		displayText = displayText:gsub('<br%s*/>', '\n')
		displayText:gsub('<[^<>]->', '')
		for i, v in utf8.graphemes(displayText) do
			TextLabel.MaxVisibleGraphemes = i
			task.wait(delay)
		end
		TextLabel.MaxVisibleGraphemes = -1
	end
	function alphabetEffect(TextLabel, Text)
		local alphabet_upper = {}
		for i = 65, 90 do
			table.insert(alphabet_upper, string.char(i))
		end
		local alphabet_lower = {}
		for i = 97, 122 do
			table.insert(alphabet_lower, string.char(i))
		end
		TextLabel.Text = ''
		-- TextLabel.TextXAlignment = Enum.TextXAlignment.Left
		for _, v in pairs(string.split(Text, '')) do task.wait()
			local txt = TextLabel.Text
			if (string.gsub(v, '%a', '')) ~= '' then
				TextLabel.Text = txt .. v
			else
				if v == string.lower(v) then
					for i, k in pairs(alphabet_lower) do task.wait()
						TextLabel.Text = txt .. k
						if k == v then
							break
						elseif i == #alphabet_lower then
							TextLabel.Text = txt .. v
						end
					end
				else
					for i, k in pairs(alphabet_upper) do task.wait()
						TextLabel.Text = txt .. k
						if k == v then
							break
						elseif i == #alphabet_upper then
							TextLabel.Text = txt .. v
						end
					end
				end
			end
		end
	end
end

local Discord = {}
do
	function Discord.FindUser(userID, guildID)
		local req = (syn and syn.request) or (http and http.request) or http_request
		if not req then return end
		if typeof(userID) ~= "string" then return end

		local response
		if guildID and typeof(guildID) == "string" then
			response =  req({
				Url = 'https://discord.com/api/v9/guilds/' .. guildID .. '/members/' .. userID,
				Method = "GET",
				Headers = {
					["Authorization"] = 'Bot ' .. Discord.Token,
				}
			}).Body
		else
			response =  req({
				Url = 'https://discord.com/api/v9/users/' .. userID,
				Method = "GET",
				Headers = {
					["Authorization"] = 'Bot ' .. Discord.Token,
				}
			}).Body
		end
		if typeof(response) ~= "table" then
			return game:GetService('HttpService'):JSONDecode(response)
		end
		return response
	end
	function Discord.FindGuild(guildID)
		local req = (syn and syn.request) or (http and http.request) or http_request
		if not req then return end
		if typeof(guildID) ~= "string" then return end
		local response =  req({
			Url = 'https://discord.com/api/v9/guilds/' .. guildID .. '?with_counts=true',
			Method = "GET",
			Headers = {
				["Authorization"] = 'Bot ' .. Discord.Token,
			},
			Body = {
				["with_counts?"] = true
			}
		}).Body

		if typeof(response) ~= "table" then
			pcall(function()
				response = game:GetService('HttpService'):JSONDecode(response)
			end)
		end
		return response
	end
	function Discord.GetInvites(guildID)
		local req = (syn and syn.request) or (http and http.request) or http_request
		if not req then return end
		if typeof(guildID) ~= "string" then return end
		local response =  req({
			Url = 'https://discord.com/api/v9/guilds/' .. guildID .. '/invites',
			Method = "GET",
			Headers = {
				["Authorization"] = 'Bot ' .. Discord.Token,
			}
		}).Body

		if typeof(response) ~= "table" then
			return game:GetService('HttpService'):JSONDecode(response)
		end
		return response
	end
end

local MongoDB = {}
do
	function MongoDB:HTTPPost(action, body)
		local req = (syn and syn.request) or (http and http.request) or http_request
		local Request = req({
			Url = self.URL_ENDPOINT .. '/action/' .. action,
			Method = 'POST',
			Headers = {
				["Content-Type"] = "application/json",
				['api-key'] = self.API_TOKEN
			},
			Body = game:GetService('HttpService'):JSONEncode(body)
		}).Body
		return game:GetService('HttpService').JSONDecode(game:GetService('HttpService'), Request)
	end
	function MongoDB:Find(Collection, Filter)
		local Body = {
			collection = Collection,
			database = 'WhiteList',
			dataSource = 'Cluster0',
			filter = Filter,
		}
		return MongoDB:HTTPPost(
			'findOne',
			Body
		).document
	end
	function MongoDB:Insert(Collection, DocumentData)
		local Body = {
			collection = Collection or self.StaticCollection,
			database = 'WhiteList',
			dataSource = 'Cluster0',
			document = DocumentData,
		}
		return MongoDB:HTTPPost(
			'insertOne',
			Body
		).insertedId
	end
	function MongoDB:Update(Collection, Filter, UpdatedDocumentData, Upsert)
		local Body = {
			collection = Collection or self.StaticCollection,
			database = 'WhiteList',
			dataSource = 'Cluster0',
			upsert = Upsert or false,
			filter = Filter,
			update = UpdatedDocumentData,
		}
		return MongoDB:HTTPPost(
			'updateOne',
			Body
		)
	end
end

do
	library.__index = library
	library.page.__index = library.page
	library.section.__index = library.section

	function library.new()
		local function check()
			if not library.Parent:FindFirstChild('Premier System') then
				return true
			end
		end
		while not check() and task.wait() do
			pcall(function()
				library.Parent:FindFirstChild('Premier System'):Destroy()
			end)
		end

		if not game:GetService('UserInputService').MouseIconEnabled then
			game:GetService('UserInputService').MouseIconEnabled = true
		end

		table.insert(library.connections, player.Idled:Connect(function()
			pcall(function()
				game:service('VirtualUser'):ClickButton2(Vector2.new())
			end)
		end))

		local discord_server = Discord.FindGuild(Discord.Server)
		local invite = {
			uses = 0
		}
		task.spawn(function()
			for i, v in pairs(Discord.GetInvites(Discord.Server)) do
				if v.uses > invite.uses then
					invite.code = v.vanity_url_code or v.code
					invite.uses = v.uses
				end
			end
			if invite.code then
				invite = invite.code
			end
		end)
		local UI = newInstance('ScreenGui', {
			Name = 'Premier System',
			Parent = library.Parent
		}, {
			newInstance('Frame', {
				BackgroundColor3 = library.Settings.theme.Background,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(0, 350, 0, 500),
				Visible = false
			}, {
				newInstance('Frame', {
					Name = 'Loader',
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),
				}, {
					newInstance('ImageLabel', {
						Name = 'Icon',
						BackgroundTransparency = 1,
						AnchorPoint = Vector2.new(0.5, 0.4),
						Position = UDim2.new(0.5, 0, 0.4, 0),
						Size = UDim2.new(0, 150, 0, 150),
						Image = 'rbxassetid://7733678388',
						ImageColor3 = Color3.new(1, 1, 1),
						ScaleType = Enum.ScaleType.Crop
					}, {
						newInstance('UIGradient', {
							Color = ColorSequence.new{
								ColorSequenceKeypoint.new(0, Color3.fromRGB(254, 116, 13)),
								ColorSequenceKeypoint.new(1, Color3.fromRGB(234, 12, 50))
							}
						})
					}),
					newInstance('Frame', {
						Name = 'Bar',
						AnchorPoint = Vector2.new(0.5, 0.63),
						Position = UDim2.new(0.5, 0, 0.63, 0),
						Size = UDim2.new(0, 200, 0, 4),
						BackgroundColor3 = library.Settings.theme.LightContrast,
						BorderSizePixel = 0,
					}, {
						newInstance('Frame', {
							Name = 'Fill',
							Size = UDim2.new(0, 0, 1, 0),
							BorderSizePixel = 0,
							BackgroundColor3 = Color3.new(1, 1, 1),
						}, {
							newInstance('UIGradient', {
								Color = ColorSequence.new{
									ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 53, 221)),
									ColorSequenceKeypoint.new(1, Color3.fromRGB(3, 156, 251))
								}
							})
						}, UDim.new(1, 0))
					}, UDim.new(1, 0)),
					newInstance('TextLabel', {
						BackgroundTransparency = 1,
						AnchorPoint = Vector2.new(0.5, 0.9),
						Position = UDim2.new(0.5, 0, 0.9, 0),
						Size = UDim2.new(1, 0, 0, 14),
						RichText = true,
						Text = '<b>© Premier System</b>',
						TextColor3 = library.Settings.theme.LightContrast,
						TextSize = 14,
						Font = library.Settings.Elements_Font
					}),
				}),
				newInstance('Frame', {
					Name = 'Login',
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),
					Visible = false
				}, {
                    newInstance('UIListLayout', {
                        VerticalAlignment = Enum.VerticalAlignment.Top,
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        Padding = UDim.new(0, 15),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    }),
					newInstance('ImageLabel', {
                        LayoutOrder = 0,
						BackgroundTransparency = 1,
						ClipsDescendants = true,
						Size = UDim2.new(1, 0, 0, 100),
						Position = UDim2.new(0, 0, 0, -1),
						Image = 'rbxassetid://10641225315',
						ScaleType = Enum.ScaleType.Crop
					}, {
						newInstance('ImageLabel', {
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 1, 0),
							Position = UDim2.new(0, 0, 0, 0),
							ImageTransparency = 1,
							Image = 'rbxassetid://10638334576',
							ScaleType = Enum.ScaleType.Crop
						}, {}, UDim.new(0, 8)),
						newInstance('Frame', {
							BackgroundColor3 = library.Settings.theme.Background,
							Size = UDim2.new(0, 350, 0, 40),
							Position = UDim2.new(1, 330, 0.5, 0),
							AnchorPoint = Vector2.new(1, 0.5),
							BorderSizePixel = 0,
						}, {
							newInstance('Frame', {
								Name = 'Circle',
								BackgroundColor3 = library.Settings.theme.Background,
								Size = UDim2.new(0, 40, 0, 40),
								Position = UDim2.new(0, -20, 0, 0),
							}, {
								newInstance('ImageButton', {
									Name = 'Switch_Button',
									AutoButtonColor = false,
									BackgroundTransparency = 1,
									Size = UDim2.new(0, 20, 0, 20),
									Position = UDim2.new(0.5, 0, 0.5, 0),
									AnchorPoint = Vector2.new(0.5, 0.5),
									Image = 'rbxassetid://7733717651',
									ImageColor3 = library.Settings.theme.TextColor
								})
							}, UDim.new(1, 0)),
							newInstance('Frame', {
								Name = 'Container',
								BackgroundTransparency = 1,
								Size = UDim2.new(1, -20, 1, 0),
								Position = UDim2.new(1, 0, 0, 0),
								AnchorPoint = Vector2.new(1, 0),
							}, {
								newInstance('ImageLabel', {
									Name = 'Partner_Icon',
									BackgroundTransparency = 1,
									Size = UDim2.new(0, 16, 0, 16),
									Position = UDim2.new(0, 0, 0, 5),
									Image = 'rbxassetid://10649657261',
									ImageColor3 = Color3.new(1, 1, 1),
									ScaleType = Enum.ScaleType.Crop
								}),
								newInstance('TextLabel', {
									Name = 'Title',
									BackgroundTransparency = 1,
									Size = UDim2.new(0, getTextSize(discord_server.name or '', 18 + 2, library.Settings.Elements_Font).X, 0, 18),
									Position = UDim2.new(0, 18, 0, 4),
									AnchorPoint = Vector2.new(0, 0),
									RichText = true,
									Text = '<b>' .. discord_server.name or '' .. '</b>',
									TextSize = 18,
									TextColor3 = library.Settings.theme.TextColor,
									TextTransparency = 0.1,
									TextXAlignment = Enum.TextXAlignment.Left,
									Font = library.Settings.Elements_Font
								}),
								newInstance('ImageLabel', {
									Name = 'Users_Icon',
									BackgroundTransparency = 1,
									Size = UDim2.new(0, 14, 0, 14),
									Position = UDim2.new(0, 18, 0, 23),
									Image = 'rbxassetid://7743876054',
									ImageColor3 = library.Settings.theme.TextColor,
									ScaleType = Enum.ScaleType.Crop
								}),
								newInstance('TextLabel', {
									Name = 'Users_Counter',
									BackgroundTransparency = 1,
									Size = UDim2.new(0, getTextSize(tostring(discord_server.approximate_member_count or 0), 14, library.Settings.Elements_Font).X, 0, 14),
									Position = UDim2.new(0, 37, 0, 24),
									AnchorPoint = Vector2.new(0, 0),
									RichText = true,
									Text = tostring(discord_server.approximate_member_count or 0),
									TextSize = 14,
									TextColor3 = library.Settings.theme.TextColor,
									TextTransparency = 0.1,
									TextXAlignment = Enum.TextXAlignment.Left,
									Font = library.Settings.Elements_Font
								}),
								newInstance('ImageLabel', {
									Name = 'Users_Online_Icon',
									BackgroundTransparency = 1,
									Size = UDim2.new(0, 16, 0, 16),
									Position = UDim2.new(0, 37 + getTextSize(tostring(discord_server.approximate_member_count or 0), 14, library.Settings.Elements_Font).X + 10, 0, 23),
									Image = 'rbxassetid://6034287594',
									ImageColor3 = Color3.fromRGB(3, 146, 118),
									ScaleType = Enum.ScaleType.Crop
								}),
								newInstance('TextLabel', {
									Name = 'Users_Online_Counter',
									BackgroundTransparency = 1,
									Size = UDim2.new(0, getTextSize(tostring(discord_server.approximate_presence_count or 0), 14, library.Settings.Elements_Font).X, 0, 14),
									Position = UDim2.new(0, 37 + getTextSize(tostring(discord_server.approximate_member_count or 0), 14, library.Settings.Elements_Font).X + 10 + 18, 0, 24),
									AnchorPoint = Vector2.new(0, 0),
									RichText = true,
									Text = '<b>' .. tostring(discord_server.approximate_presence_count or 0) .. '</b>',
									TextSize = 14,
									TextColor3 = Color3.fromRGB(3, 146, 118),
									TextTransparency = 0.1,
									TextXAlignment = Enum.TextXAlignment.Left,
									Font = library.Settings.Elements_Font
								}),
								newInstance('TextButton', {
									AutoButtonColor = false,
									BackgroundColor3 = Color3.new(1, 1, 1),
									Size = UDim2.new(0, 100, 0, 26),
									Position = UDim2.new(1, -20, 0.5, 0),
									AnchorPoint = Vector2.new(1, 0.5),
									Text = '',
									ClipsDescendants = true
								}, {
									newInstance('UIGradient', {
										Color = ColorSequence.new{
											ColorSequenceKeypoint.new(0, Color3.fromRGB(8,57,74)),
											ColorSequenceKeypoint.new(1, Color3.fromRGB(159,220,176))
										},
									}),
									newInstance('TextLabel', {
										Name = 'Title',
										BackgroundTransparency = 1,
										Size = UDim2.new(1, 0, 1, 0),
										Text = '<b>JOIN</b>',
										RichText = true,
										TextColor3 = library.Settings.theme.TextColor,
										TextSize = 14,
										Font = library.Settings.Elements_Font
									}),
								}, UDim.new(0, 8))
							})
						})
					}, UDim.new(0, 8)),
                    newInstance('Frame', {
						Name = '',
                        LayoutOrder = 1,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0, 0, 0, 0),
                    }),
					newInstance('TextBox', {
						Name = 'Discord_ID',
						LayoutOrder = 2,
						BackgroundTransparency = 1,
						MaxVisibleGraphemes = 18,
						Size = UDim2.new(0, 210, 0, 14),
						ClearTextOnFocus = false,
						Text = '',
						TextSize = 14,
						TextColor3 = library.Settings.theme.TextColor,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextTruncate = Enum.TextTruncate.AtEnd,
						Font = library.Settings.Elements_Font
					}, {
						newInstance('TextLabel', {
							Name = 'Title',
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 1, 0),
							TextColor3 = library.Settings.theme.LightContrast,
							RichText = true,
							Text = '<b>DISCORD ID</b>',
							TextSize = 14,
							Font = library.Settings.Elements_Font,
							TextXAlignment = Enum.TextXAlignment.Left
						}),
						newInstance('Frame', {
							Name = 'Bar',
							BackgroundColor3 = library.Settings.theme.LightContrast,
							AnchorPoint = Vector2.new(0, 1),
							Position = UDim2.new(0, 0, 1, 3),
							Size = UDim2.new(1, 0, 0, 2),
						}, {}, UDim.new(1, 0)),
					}),
					newInstance('ImageButton', {
						Name = 'CheckBox_Frame',
                        LayoutOrder = 3,
						AutoButtonColor = false,
						BackgroundTransparency = 1,
						Size = UDim2.new(0, 210, 0, 20),
					}, {
						newInstance('Frame', {
							Name = 'CheckBox',
							BackgroundColor3 = library.Settings.theme.DarkContrast,
							Rotation = 45,
							Size = UDim2.new(0, 20, 0, 20),
							Position = UDim2.new(0, 0, 0.5, 0),
							AnchorPoint = Vector2.new(0, 0.5),
						}, {
							newInstance('Frame', {
								Name = 'Check',
								BackgroundColor3 = Color3.new(1, 1, 1),
								BackgroundTransparency = 1,
								Size = UDim2.new(1, 0, 1, 0),
							}, {
								newInstance('UIGradient', {
									Color = ColorSequence.new{
										ColorSequenceKeypoint.new(0, Color3.fromRGB(66, 3, 240)),
										ColorSequenceKeypoint.new(1, Color3.fromRGB(138, 42, 227))
									},
									Rotation = -45
								})
							}, UDim.new(0, 8))
						}, UDim.new(0, 8)),
						newInstance('TextLabel', {
							BackgroundTransparency = 1,
							Size = UDim2.new(0, getTextSize('Remember me', 14, library.Settings.Elements_Font).X + 5, 0, 14),
							Position = UDim2.new(0, 30, 0.5, 0),
							AnchorPoint = Vector2.new(0, 0.5),
							RichText = true,
							Text = '<b>Remember me</b>',
							TextSize = 14,
							TextColor3 = library.Settings.theme.PlaceHolderColor,
							TextTransparency = 0.1,
							TextXAlignment = Enum.TextXAlignment.Left,
							Font = library.Settings.Elements_Font
						}),
					}),
					newInstance('TextButton', {
                        LayoutOrder = 4,
						AutoButtonColor = false,
						BackgroundColor3 = Color3.new(1, 1, 1),
						Size = UDim2.new(0, 100, 0, 26),
						Text = '',
						ClipsDescendants = true
					}, {
						newInstance('UIGradient', {
							Color = ColorSequence.new{
								ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 53, 221)),
								ColorSequenceKeypoint.new(1, Color3.fromRGB(3, 156, 251))
							},
						}),
						newInstance('TextLabel', {
							Name = 'Title',
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 1, 0),
							Text = '<b>LOGIN</b>',
							RichText = true,
							TextColor3 = library.Settings.theme.TextColor,
							TextSize = 14,
							Font = library.Settings.Elements_Font
						}),
					}, UDim.new(0, 8)),
				}),
				newInstance('Frame', {
					Name = 'Container',
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),
					Visible = false
				}, {
					newInstance('Frame', {
						Name = 'Top_Frame',
						Size = UDim2.new(1, 0, 0, 35),
						BackgroundTransparency = 1,
					}, {
						newInstance("UIPadding", {
							PaddingLeft = UDim.new(0, 15)
						}),
						newInstance('UIListLayout', {
							VerticalAlignment = Enum.VerticalAlignment.Center,
							HorizontalAlignment = Enum.HorizontalAlignment.Left,
							FillDirection = Enum.FillDirection.Horizontal,
							Padding = UDim.new(0, 10),
							SortOrder = Enum.SortOrder.LayoutOrder
						}),
						newInstance('Frame', {
							Name = 'Title_Frame',
							Size = UDim2.new(0, 150, 1, 0),
							BackgroundTransparency = 1,
							LayoutOrder = 0,
						}, {
							newInstance('UIListLayout', {
								VerticalAlignment = Enum.VerticalAlignment.Center,
								HorizontalAlignment = Enum.HorizontalAlignment.Left,
								FillDirection = Enum.FillDirection.Horizontal,
								Padding = UDim.new(0, 10),
								SortOrder = Enum.SortOrder.LayoutOrder
							}),
							newInstance('ImageButton', {
								Name = 'Logo',
								Size = UDim2.new(0, 25, 0, 25),
								AutoButtonColor = false,
								BackgroundTransparency = 1,
								Image = 'rbxassetid://7733678388',
								ImageColor3 = Color3.new(1, 1, 1),
							}, {
								newInstance('UIGradient', {
									Color = ColorSequence.new{
										ColorSequenceKeypoint.new(0, Color3.fromRGB(254, 116, 13)),
										ColorSequenceKeypoint.new(1, Color3.fromRGB(234, 12, 50))
									}
								})
							}),
							newInstance('TextLabel', {
								Name = 'Title',
								LayoutOrder = 1,
								BackgroundTransparency = 1,
								Size = UDim2.new(0, 110, 1, 0),
								Text = '<b>' .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name .. '</b>',
								RichText = true,
								TextColor3 = library.Settings.theme.TextColor,
								TextXAlignment = Enum.TextXAlignment.Left,
								TextTruncate = Enum.TextTruncate.AtEnd,
								TextSize = 18,
								Font = library.Settings.Elements_Font
							}),
						}),
						newInstance('Frame', {
							Name = 'Search_Frame',
							Size = UDim2.new(0, 300, 0, 25),
							BackgroundTransparency = 1,
							Visible = not library.IsMobile,
							LayoutOrder = 1,
						}, {
							newInstance('UIPadding', {
								PaddingLeft = UDim.new(0, 15)
							}),
							newInstance('TextBox', {
								BackgroundTransparency = 1,
								ClearTextOnFocus = true,
								Size = UDim2.new(1, 0, 1, 0),
								Text = '',
								TextSize = 14,
								TextColor3 = library.Settings.theme.TextColor,
								PlaceholderColor3 = library.Settings.theme.PlaceHolderColor,
								PlaceholderText = 'Search...',
								TextXAlignment = Enum.TextXAlignment.Left,
								TextTruncate = Enum.TextTruncate.AtEnd,
								Font = library.Settings.Elements_Font
							}, {
								newInstance('Frame', {
									Name = 'Bar',
									BackgroundColor3 = library.Settings.theme.LightContrast,
									Size = UDim2.new(1, 0, 0, 2),
									AnchorPoint = Vector2.new(0, 1),
									Position = UDim2.new(0, 0, 1, -2),
								}, {}, UDim.new(1, 0)),
							}),
						}),
						newInstance('ImageButton', {
							Name = 'Search_Button',
							AutoButtonColor = false,
							Size = UDim2.new(0, 25, 0, 25),
							BackgroundColor3 = library.Settings.theme.DarkContrast,
							LayoutOrder = 2,
						}, {
							newInstance('ImageLabel', {
								Size = UDim2.new(0, 15, 0, 15),
								BackgroundTransparency = 1,
								Position = UDim2.new(0.5, 0, 0.5, 0),
								AnchorPoint = Vector2.new(0.5, 0.5),
								Image = 'rbxassetid://7072721559',
								ImageColor3 = library.Settings.theme.TextColor,
							})
						}, UDim.new(0, 5)),
					}),
					newInstance('Frame', {
						Name = 'Left_Frame',
						Size = UDim2.new(0, 55, 1, -35),
						Position = UDim2.new(0, 0, 1, 0),
						AnchorPoint = Vector2.new(0, 1),
						BackgroundTransparency = 1,
					}, {
						newInstance("UIPadding", {
							PaddingTop = UDim.new(0, 10),
							PaddingLeft = UDim.new(0, 10),
							PaddingRight = UDim.new(0, 10)
						}),
						newInstance('UIListLayout', {
							VerticalAlignment = Enum.VerticalAlignment.Top,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							FillDirection = Enum.FillDirection.Vertical,
							Padding = UDim.new(0, 10),
							SortOrder = Enum.SortOrder.LayoutOrder
						}),
					}),
					newInstance('Frame', {
						Name = 'Center_Frame',
						Size = UDim2.new(1, -55, 1, -35),
						Position = UDim2.new(1, 0, 1, 0),
						AnchorPoint = Vector2.new(1, 1),
						BackgroundColor3 = library.Settings.theme.DarkContrast,
					}, {
						newInstance('Frame', {
							Name = '',
							Size = UDim2.new(0, 30, 0, 30),
							Position = UDim2.new(1, 0, 0, 0),
							AnchorPoint = Vector2.new(1, 0),
							BorderSizePixel = 0,
							BackgroundColor3 = library.Settings.theme.DarkContrast,
						}),
						newInstance('Frame', {
							Name = '',
							Size = UDim2.new(0, 30, 0, 30),
							Position = UDim2.new(0, 0, 1, 0),
							AnchorPoint = Vector2.new(0, 1),
							BorderSizePixel = 0,
							BackgroundColor3 = library.Settings.theme.DarkContrast,
						}),
						newInstance('ImageButton', {
							Name = 'Resize_Button',
							AutoButtonColor = false,
							BackgroundTransparency = 1,
							Size = UDim2.new(0, 15, 0, 15),
							Position = UDim2.new(1, -5, 1, -5),
							AnchorPoint = Vector2.new(1, 1),
							Image = 'rbxassetid://7734013178',
							ImageColor3 = library.Settings.theme.Inactive,
							ZIndex = 2,
						}),
						newInstance('ScrollingFrame', {
							Name = 'Section_Container',
							ClipsDescendants = true,
							ScrollingEnabled = false,
							Size = UDim2.new(1, -15, 1, -15),
							Position = UDim2.new(0.5, 0, 0.5, 0),
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							ScrollBarThickness = 0,
							ScrollingDirection = Enum.ScrollingDirection.X,
							CanvasSize = UDim2.new(0, 0, 0, 0),
						}, {
							newInstance('UIGridLayout', {
								CellPadding = UDim2.new(0, 0, 0, 10),
								FillDirection = Enum.FillDirection.Horizontal,
								FillDirectionMaxCells = 1,
								HorizontalAlignment = Enum.HorizontalAlignment.Center,
								VerticalAlignment = Enum.VerticalAlignment.Top
							}),
						}),
					}, UDim.new(0, 8)),
				})
			}, UDim.new(0, 15)),
			newInstance('Frame', {
				Name = 'Notifications_Container',
				ClipsDescendants = true,
				Size = UDim2.new(0, 350, 1, 0),
				Position = UDim2.new(0, 0, 1, 0),
				AnchorPoint = Vector2.new(0, 1),
				BackgroundTransparency = 1,
			}, {
				newInstance("UIPadding", {
					PaddingBottom = UDim.new(0, 10),
					PaddingRight = UDim.new(0, 10),
					PaddingLeft = UDim.new(0, 10),
				}),
			})
		})

		local Notification_Types = {
			"Success",
			"Error",
			"Warning",
			"Info",
		}
		local function Notification(type, title, message, time)
			local frame = newInstance('Frame', {
				Name = 'Notification',
				Parent = UI.Notifications_Container,
				BackgroundColor3 = library.Settings.theme.Background,
				Position = UDim2.new(0, 0, 1, 0),
				AnchorPoint = Vector2.new(0, 1),
				Size = UDim2.new(1, 0, 0, 42),
				Visible = false
			}, {
				newInstance('Frame', {
					Name = 'Content',
					Size = UDim2.new(1, 0, 1, -4),
					BackgroundTransparency = 1
				}, {
					newInstance('UIPadding', {
						PaddingLeft = UDim.new(0, 5),
						PaddingRight = UDim.new(0, 5),
						PaddingTop = UDim.new(0, 5),
					}),
					newInstance('UIListLayout', {
						Padding = UDim.new(0, 0),
						FillDirection = Enum.FillDirection.Vertical,
						VerticalAlignment = Enum.VerticalAlignment.Top,
						SortOrder = Enum.SortOrder.LayoutOrder
					}),
					newInstance('TextLabel', {
						Name = 'Title',
						Size = UDim2.new(1, 0, 0, 14),
						BackgroundTransparency = 1,
						Text = '<b><u>' .. (title and string.len(title) > 0 and title or 'Notification Title') .. '</u></b>',
						Font = library.Settings.Elements_Font,
						RichText = true,
						TextSize = 14,
						TextColor3 = library.Settings.theme.TextColor,
						TextXAlignment = Enum.TextXAlignment.Left,
						LayoutOrder = 0
					}),
					newInstance('TextLabel', {
						Name = 'Description',
						Size = UDim2.new(1, 0, 0, 14),
						BackgroundTransparency = 1,
						Font = library.Settings.Elements_Font,
						LineHeight = 0.8,
						RichText = true,
						TextWrapped = true,
						TextSize = 14,
						TextColor3 = library.Settings.theme.PlaceHolderColor,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
						LayoutOrder = 1
					}),
				}),
				newInstance('Frame', {
					Name = 'Bar',
					Size = UDim2.new(1, 0, 0, 4),
					Position = UDim2.new(0, 0, 1, 0),
					AnchorPoint = Vector2.new(0, 1),
					BackgroundColor3 = library.Settings.theme[typeof(type) == "string" and type or Notification_Types[type]],
					BorderSizePixel = 0
				}, {}, UDim.new(0, 5))
			}, UDim.new(0, 5))

			local text = (message and string.len(message) > 0 and message or 'Description')
			for i = 1, text:len() do
				frame.Content.Description.Text = text:sub(1, i)
				frame.Content.Description.Size = UDim2.new(1, 0, 0, frame.Content.Description.TextBounds.Y)
			end
			frame.Size = UDim2.new(1, 0, 0, 28 + frame.Content.Description.AbsoluteSize.Y)

			table.insert(library.notifications, frame)

			table.insert(library.connections, frame.Destroying:connect(function()
				for i, v in pairs(library.notifications) do
					pcall(function()
						if i == 1 then
							v.Position = UDim2.new(0, 0, 1, 0)
						else
							v.Position = library.notifications[i - 1].Position - UDim2.new(0, 0, 0, library.notifications[i - 1].AbsoluteSize.Y + 10)
						end
					end)
				end
			end))
			if #library.notifications == 1 then
				frame.Visible = true
				local tween = Tween(frame.Bar, { Size = UDim2.new(0, 0, 0, 4) }, time or 5)
				tween.Completed:Connect(function()
					Tween(frame, { Position = frame.Position + UDim2.new(0, 0, 0, frame.AbsoluteSize.Y) }, 0.2).Completed:Connect(function()
						table.remove(library.notifications, table.find(library.notifications, frame))
						frame:Destroy()
					end)
				end)
				return tween
			else
				if table.find(library.notifications, frame) > library.Settings.Notifications_Max then
					repeat
						task.wait()
					until table.find(library.notifications, frame) <= library.Settings.Notifications_Max
				end
				local notification_pos = table.find(library.notifications, frame)

				if notification_pos == 1 then
					frame.Position = UDim2.new(0, 0, 1, 0)
				else
					frame.Position = library.notifications[notification_pos - 1].Position - UDim2.new(0, 0, 0, library.notifications[notification_pos - 1].AbsoluteSize.Y + 10)
				end

				frame.Visible = true
				local tween = Tween(frame.Bar, { Size = UDim2.new(0, 0, 0, 4) }, time or 5)
				tween.Completed:Connect(function()
					Tween(frame, { Position = frame.Position + UDim2.new(0, 0, 0, frame.AbsoluteSize.Y) }, 0.2).Completed:Connect(function()
						table.remove(library.notifications, table.find(library.notifications, frame))
						frame:Destroy()
					end)
				end)
				return tween
			end
		end

		local lib = setmetatable({
			Enabled = true,
			container = UI,
			pageContainer = UI.Frame.Container.Left_Frame,
			sectionContainer = UI.Frame.Container.Center_Frame.Section_Container,
			pages = {},
			Notification = Notification
		}, library)

		table.insert(library.connections, UI.Destroying:Connect(function()
			lib:close()
		end))

		if typeof(Discord.Token) ~= 'string' or #string.split(Discord.Token, '.') < 3 then
			Notification(2, 'Discord', 'Bot token is invalid.').Completed:Connect(function()
				task.wait(0.5)
				UI:Destroy()
			end)
			return
		elseif typeof(Discord.Server) ~= 'string' or string.len(Discord.Server) < 17 then
			Notification(2, 'Discord', 'The server id is invalid.').Completed:Connect(function()
				task.wait(0.5)
				UI:Destroy()
			end)
			return
		elseif typeof(MongoDB.API_TOKEN) ~= 'string' or string.len(MongoDB.API_TOKEN) < 64 then
			Notification(2, 'DataBase', 'MongoDB API token is invalid.').Completed:Connect(function()
				task.wait(0.5)
				UI:Destroy()
			end)
			return
		elseif typeof(MongoDB.URL_ENDPOINT) ~= 'string' or not string.find(MongoDB.URL_ENDPOINT, 'mongodb') or not string.find(MongoDB.URL_ENDPOINT, 'endpoint/') then
			Notification(2, 'DataBase', 'MongoDB Endpoint URL is invalid.').Completed:Connect(function()
				task.wait(0.5)
				UI:Destroy()
			end)
			return
		end
		UI.Frame.Visible = true

		local discord_toggling = false
		UI.Frame.Login.ImageLabel.Frame.Circle.Switch_Button.MouseButton1Click:Connect(function()
			if discord_toggling then return end
			discord_toggling = true

			Tween(UI.Frame.Login.ImageLabel.Frame.Circle.Switch_Button, { Rotation = (UI.Frame.Login.ImageLabel.Frame.Circle.Switch_Button.Rotation == 180 and 0) or 180 }, 0.2)
			Tween(UI.Frame.Login.ImageLabel.ImageLabel, { ImageTransparency = (UI.Frame.Login.ImageLabel.ImageLabel.ImageTransparency == 0 and 1) or 0 }, 0.2)
			Tween(UI.Frame.Login.ImageLabel.Frame, { Position = (UI.Frame.Login.ImageLabel.Frame.Position == UDim2.new(1, 330, 0.5, 0) and UDim2.new(1, 0, 0.5, 0)) or UDim2.new(1, 330, 0.5, 0) }, 0.2).Completed:Wait()

			discord_toggling = false
		end)
		local Join_toggling = false
		UI.Frame.Login.ImageLabel.Frame.Container.TextButton.MouseButton1Click:Connect(function()
			if Join_toggling then return end
			Join_toggling = true

			rippleEffect(UI.Frame.Login.ImageLabel.Frame.Container.TextButton, 0.5)
			Tween(UI.Frame.Login.ImageLabel.Frame.Container.TextButton, { BackgroundColor3 = library.Settings.theme.LightContrast }, 0.2)

			if typeof(invite) ~= 'string' then
				Notification(2, 'Discord', 'This server does not have an invitation link.')
			else
				local req = (syn and syn.request) or (http and http.request) or http_request
				for i = 6453, 6464 do wait()
					spawn(function()
						local success, _ = pcall(function()
							req({
								Url = "http://127.0.0.1:" .. tostring(i) .. "/rpc?v=1",
								Method = "POST",
								Headers = {
									["Content-Type"] = "application/json",
									["Origin"] = "https://discord.com"
								},
								Body = game:GetService("HttpService"):JSONEncode({
									["cmd"] = "INVITE_BROWSER",
									["nonce"] = game:GetService("HttpService"):GenerateGUID(false),
									["args"] = {
										["invite"] = {
											["code"] = invite
										},
										["code"] = invite
									}
								})
							})
						end)
						if not success then
							Notification(4, 'Discord', 'The invitation link has been copied to your clipboard.')
							setclipboard('https://discord.gg/' .. invite)
						end
					end)
				end
			end

			Tween(UI.Frame.Login.ImageLabel.Frame.Container.TextButton, { BackgroundColor3 = Color3.new(1, 1, 1) }, 0.2)
			Join_toggling = false
		end)

		UI.Frame.Login.Discord_ID.Focused:Connect(function()
			Tween(UI.Frame.Login.Discord_ID.Bar, { BackgroundColor3 = library.Settings.theme.TextColor }, 0.2)
			Tween(UI.Frame.Login.Discord_ID.Title, { TextColor3 = library.Settings.theme.TextColor }, 0.2)
			Tween(UI.Frame.Login.Discord_ID.Title, { Position = UDim2.new(0, 0, -1, -2), AnchorPoint = Vector2.new(0, -1) }, 0.2)
		end)
		UI.Frame.Login.Discord_ID.FocusLost:Connect(function()
			Tween(UI.Frame.Login.Discord_ID.Bar, { BackgroundColor3 = library.Settings.theme.LightContrast }, 0.2)
			Tween(UI.Frame.Login.Discord_ID.Title, { TextColor3 = library.Settings.theme.LightContrast }, 0.2)
			if UI.Frame.Login.Discord_ID.Text == "" then
				Tween(UI.Frame.Login.Discord_ID.Title, { Position = UDim2.new(0, 0, 0, 0), AnchorPoint = Vector2.new(0, 0) }, 0.2)
			end
		end)
        UI.Frame.Login.Discord_ID:GetPropertyChangedSignal("Text"):Connect(function()
            UI.Frame.Login.Discord_ID.Text = UI.Frame.Login.Discord_ID.Text:gsub('%D+', ''):sub(0, 18)
        end)

		local CheckBox_Toggling = false
		local CheckBox_Enabled = false
		UI.Frame.Login.CheckBox_Frame.MouseButton1Click:Connect(function()
			if CheckBox_Toggling then return end
			CheckBox_Toggling = true

			if CheckBox_Enabled then
				Tween(UI.Frame.Login.CheckBox_Frame.CheckBox.Check, { BackgroundTransparency = 1 }, 0.3).Completed:Wait()
			else
				Tween(UI.Frame.Login.CheckBox_Frame.CheckBox.Check, { BackgroundTransparency = 0 }, 0.2).Completed:Wait()
			end

			CheckBox_Enabled = not CheckBox_Enabled
			CheckBox_Toggling = false
		end)

		local Login_Toggling = false
		UI.Frame.Login.TextButton.MouseButton1Click:Connect(function()
			if Login_Toggling then return end
			Login_Toggling = true

			rippleEffect(UI.Frame.Login.TextButton, 0.5)
			Tween(UI.Frame.Login.TextButton, { BackgroundColor3 = library.Settings.theme.LightContrast }, 0.2)

			if #UI.Frame.Login.Discord_ID.Text < 17 then
				Tween(UI.Frame.Login.Discord_ID.Bar, { BackgroundColor3 = Color3.fromRGB(211, 86, 98) }, 0.2)
				Notification(2, 'Login System', 'The discord id entered is invalid.')
				task.wait(0.1)
				Tween(UI.Frame.Login.TextButton, { BackgroundColor3 = Color3.new(1, 1, 1) }, 0.2)
				Login_Toggling = false
			else
				local user = Discord.FindUser(UI.Frame.Login.Discord_ID.Text, Discord.Server)

				local function login()
					Tween(UI.Frame.Login.TextButton, { BackgroundColor3 = Color3.new(1, 1, 1) }, 0.2)
					Login_Toggling = false

					local effect_time = 0.4
					for _, v in pairs(UI.Frame.Login:GetDescendants()) do
						local a, _ = pcall(function()
							return v.BackgroundTransparency
						end)
						local a2, _ = pcall(function()
							return v.ImageTransparency
						end)
						local a3, _ = pcall(function()
							return v.TextTransparency
						end)
						if a then
							local tween = Tween(v, { BackgroundTransparency = 1 }, effect_time)
							task.spawn(function()
								tween.Completed:Wait()
								pcall(function()
									v:Destroy()
								end)
							end)
						end
						if a2 then
							local tween = Tween(v, { ImageTransparency = 1 }, effect_time)
							task.spawn(function()
								tween.Completed:Wait()
								pcall(function()
									v:Destroy()
								end)
							end)
						end
						if a3 then
							local tween = Tween(v, { TextTransparency = 1 }, effect_time)
							task.spawn(function()
								tween.Completed:Wait()
								pcall(function()
									v:Destroy()
								end)
							end)
						end
					end
					task.wait(effect_time/2)
					Tween(UI.Frame, { Size = UDim2.new(0, 650, 0, 380) }, effect_time/2).Completed:Wait()
					lib.User = user

					UI.Frame.Login:Destroy()

					UI.Frame.Container.Visible = true

					draggingInstance(UI.Frame)
					Resizable(UI.Frame, UI.Frame.Container.Center_Frame.Resize_Button)
				end

				if user then
					if CheckBox_Enabled then
						writefile('Premier UI/discord_id.lua', UI.Frame.Login.Discord_ID.Text)
					else
						if isfile('Premier UI/discord_id.lua') then
							delfile('Premier UI/discord_id.lua')
						end
					end
					local account = MongoDB:Find('accounts', {
						discord_id = UI.Frame.Login.Discord_ID.Text,
						hwid = game:GetService("RbxAnalyticsService"):GetClientId()
					})
					if account then
						login()
						if user.nick then
							local new_nick = ''
							for _, v in pairs(string.split(user.nick, '')) do
								if string.byte(v) >= 32 or string.byte(v) <= 136 then
									new_nick = new_nick .. v
								end
							end
							user.nick = new_nick
						end
						local new_username = ''
						for _, v in pairs(string.split(user.user.username, '')) do
							if string.byte(v) >= 32 or string.byte(v) <= 136 then
								new_username = new_username .. v
							end
						end
						user.user.username = new_username
						Notification(1, 'Login System', 'Welcome back ' .. (user.nick and (user.nick .. ' - ') or '') .. user.user.username .. '#' .. user.user.discriminator)
						return
					end

					local count = MongoDB:Find('attempts', {
						discord_id = UI.Frame.Login.Discord_ID.Text,
						hwid = game:GetService("RbxAnalyticsService"):GetClientId()
					})

					if count and count.attempts >= 3 then
						Notification(2, 'Login System', 'You have exceeded the number of attempts to try to link the account with id <font color="#' .. library.Settings.theme.Error:ToHex() .. '">' .. UI.Frame.Login.Discord_ID.Text .. '</font> and have been blocked.')
						Tween(UI.Frame.Login.TextButton, { BackgroundColor3 = Color3.new(1, 1, 1) }, 0.2)
						Login_Toggling = false
						return
					end

					if MongoDB:Find('accounts', {
						discord_id = UI.Frame.Login.Discord_ID.Text,
						cooldown = true
					}) then
						Notification(3, 'Login System', 'This user has recently linked an account and has cooldown, please try again later. If you think this is an error, contact Premier administration.')
						Tween(UI.Frame.Login.TextButton, { BackgroundColor3 = Color3.new(1, 1, 1) }, 0.2)
						Login_Toggling = false
						return
					end

					if MongoDB:Find('notifications', {
						discord_id = UI.Frame.Login.Discord_ID.Text,
						hwid = game:GetService("RbxAnalyticsService"):GetClientId(),
					}) then
						Notification(4, 'Login System', 'A verification message has already been sent, check dm.')
					else
						MongoDB:Insert('notifications', {
							discord_id = UI.Frame.Login.Discord_ID.Text,
							hwid = game:GetService("RbxAnalyticsService"):GetClientId(),
							username = game.Players.LocalPlayer.Name,
							notified = false
						})
						Notification(4, 'Login System', 'A verification message has been sent, check dm.')
					end

					task.spawn(function()
						local seconds = 0
						while seconds <= 120 do task.wait(1)
							local account = MongoDB:Find('accounts', {
								discord_id = UI.Frame.Login.Discord_ID.Text,
								hwid = game:GetService("RbxAnalyticsService"):GetClientId()
							})
							if account then
								login()
								Notification(1, 'Login System', 'The account has been successfully verified.')
								break
							end
							seconds += 1
						end
					end)
				else
					Tween(UI.Frame.Login.Discord_ID.Bar, { BackgroundColor3 = Color3.fromRGB(211, 86, 98) }, 0.2)
				end
			end
		end)

		local SideBar_Toggle = false
		local Logo_Toggling = false
		UI.Frame.Container.Top_Frame.Title_Frame.Logo.MouseButton1Click:Connect(function()
			if Logo_Toggling then return end
			Logo_Toggling = true

			rippleEffect(UI.Frame.Container.Top_Frame.Title_Frame.Logo, 0.5)

			Tween(UI.Frame.Container.Center_Frame, { Size = (SideBar_Toggle and UDim2.new(1, -55, 1, -35)) or UDim2.new(1, -185, 1, -35) }, 0.2)
			Tween(UI.Frame.Container.Left_Frame, { Size = (SideBar_Toggle and UDim2.new(0, 55, 1, -35)) or UDim2.new(0, 185, 1, -35) }, 0.2).Completed:Wait()

			SideBar_Toggle = not SideBar_Toggle
			Logo_Toggling = false
		end)
		UI.Frame.Container.Center_Frame:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
			task.spawn(function()
				pcall(function()
					lib.sectionContainer.CanvasSize = UDim2.new(0, 0, 0, (#lib.pages * lib.sectionContainer.AbsoluteSize.Y) + (#lib.pages * lib.sectionContainer.UIGridLayout.CellPadding.Y.Offset))
					lib.sectionContainer.UIGridLayout.CellSize = UDim2.new(0, lib.sectionContainer.AbsoluteSize.X, 0, lib.sectionContainer.AbsoluteSize.Y)
				end)
			end)
			task.spawn(function()
				pcall(function()
					lib.focusedPage:Resize()
				end)
			end)
			task.spawn(function()
				pcall(function()
					lib.sectionContainer.CanvasPosition = Vector2.new(0, ((table.find(lib.pages, lib.focusedPage) - 1) * lib.sectionContainer.AbsoluteSize.Y) + ((table.find(lib.pages, lib.focusedPage) - 1) * lib.sectionContainer.UIGridLayout.CellPadding.Y.Offset))
				end)
			end)
		end)

		UI.Frame.Container.Top_Frame.Search_Frame.TextBox.Focused:connect(function()
			Tween(UI.Frame.Container.Top_Frame.Search_Frame.TextBox.Bar, { BackgroundColor3 = library.Settings.theme.TextColor }, 0.2)
		end)
		UI.Frame.Container.Top_Frame.Search_Frame.TextBox.FocusLost:Connect(function()
			Tween(UI.Frame.Container.Top_Frame.Search_Frame.TextBox.Bar, { BackgroundColor3 = library.Settings.theme.LightContrast }, 0.2)
		end)
		UI.Frame.Container.Top_Frame.Search_Button.MouseButton1Click:Connect(function()
			rippleEffect(UI.Frame.Container.Top_Frame.Search_Button, 0.5)
		end)

		local Resize_Button_Pressing = false
		UI.Frame.Container.Center_Frame.Resize_Button.MouseEnter:Connect(function()
			Tween(UI.Frame.Container.Center_Frame.Resize_Button, { ImageColor3 = library.Settings.theme.TextColor }, 0.2)
		end)
		UI.Frame.Container.Center_Frame.Resize_Button.MouseLeave:Connect(function()
			if Resize_Button_Pressing then return end
			Tween(UI.Frame.Container.Center_Frame.Resize_Button, { ImageColor3 = library.Settings.theme.Inactive }, 0.2)
		end)
        UI.Frame.Container.Center_Frame.Resize_Button.InputBegan:connect(function(key)
            if key.UserInputType == Enum.UserInputType.MouseButton1 then
                Resize_Button_Pressing = true
                UI.Frame.Container.Center_Frame.Resize_Button.InputEnded:connect(function(key2)
                    if key == key2 then
                        Resize_Button_Pressing =  false
						Tween(UI.Frame.Container.Center_Frame.Resize_Button, { ImageColor3 = library.Settings.theme.Inactive }, 0.2)
                    end
                end)
            end
        end)

		if isfile('Premier UI/discord_id.lua') then
			CheckBox_Enabled = true
			UI.Frame.Login.CheckBox_Frame.CheckBox.Check.BackgroundTransparency = 0

			UI.Frame.Login.Discord_ID.Title.Position = UDim2.new(0, 0, -1, -2)
			UI.Frame.Login.Discord_ID.Title.AnchorPoint = Vector2.new(0, -1)

			UI.Frame.Login.Discord_ID.Text = readfile('Premier UI/discord_id.lua')
		end

		task.spawn(function()
			while true do task.wait(5)
				local a, _ = pcall(function()
					discord_server = Discord.FindGuild(Discord.Server)

					UI.Frame.Login.ImageLabel.Frame.Container.Users_Counter.Size = UDim2.new(0, getTextSize(tostring(discord_server.approximate_member_count), 14, library.Settings.Elements_Font).X, 0, 14)
					UI.Frame.Login.ImageLabel.Frame.Container.Users_Counter.Text = tostring(discord_server.approximate_member_count)
					UI.Frame.Login.ImageLabel.Frame.Container.Users_Online_Icon.Position = UDim2.new(0, 37 + getTextSize(tostring(discord_server.approximate_member_count), 14, library.Settings.Elements_Font).X + 10, 0, 23)
					UI.Frame.Login.ImageLabel.Frame.Container.Users_Online_Counter.Position = UDim2.new(0, 37 + getTextSize(tostring(discord_server.approximate_member_count), 14, library.Settings.Elements_Font).X + 10 + 18, 0, 24)
					UI.Frame.Login.ImageLabel.Frame.Container.Users_Online_Counter.Text = '<b>' .. tostring(discord_server.approximate_presence_count) .. '</b>'
				end)
				if not a then
					break
				end
			end
		end)

		for i = 1, #AssetToLoad do
			local Completed = false
			game:GetService("ContentProvider"):PreloadAsync({ AssetToLoad[i] }, function()
				Tween(UI.Frame.Loader.Bar.Fill, { Size = UDim2.new(i/#AssetToLoad, 0, 1, 0) }, 0.2)
				Completed = true
			end)
			repeat task.wait() until Completed
		end
		repeat task.wait() until UI.Frame.Loader.Bar.Fill.Size == UDim2.new(1, 0, 1, 0)

		local effect_time = 0.4
		task.wait(effect_time)
		for _, v in pairs(UI.Frame.Loader:GetDescendants()) do
			local a, _ = pcall(function()
				return v.BackgroundTransparency
			end)
			local a2, _ = pcall(function()
				return v.ImageTransparency
			end)
			local a3, _ = pcall(function()
				return v.TextTransparency
			end)
			if a then
				local tween = Tween(v, { BackgroundTransparency = 1 }, effect_time)
				task.spawn(function()
					tween.Completed:Wait()
					pcall(function()
						v:Destroy()
					end)
				end)
			end
			if a2 then
				local tween = Tween(v, { ImageTransparency = 1 }, effect_time)
				task.spawn(function()
					tween.Completed:Wait()
					pcall(function()
						v:Destroy()
					end)
				end)
			end
			if a3 then
				local tween = Tween(v, { TextTransparency = 1 }, effect_time)
				task.spawn(function()
					tween.Completed:Wait()
					pcall(function()
						v:Destroy()
					end)
				end)
			end
		end
		task.wait(effect_time/2)

		Tween(UI.Frame.UICorner, { CornerRadius = UDim.new(0, 8) }, effect_time/2)
		Tween(UI.Frame, { Size = UDim2.new(0, 400, 0, 235) }, effect_time/2).Completed:Wait()
		UI.Frame.Loader:Destroy()
		UI.Frame.Login.Visible = true

		repeat task.wait() until lib.User

		return lib
	end
	function library.page.new(config)
		config = config or {}
		local button = newInstance('ImageButton', {
			Name = betterFindIndex(config, 'title') or 'Page',
			Parent = betterFindIndex(config, 'library').pageContainer,
			Size = UDim2.new(1, 0, 0, 30),
            AutoButtonColor = false,
			BackgroundColor3 = library.Settings.theme.DarkContrast,
            BackgroundTransparency = 1,
		}, {
			newInstance('Frame', {
				Size = UDim2.new(0, 2, 0, 20),
				Position = UDim2.new(0, -1, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BackgroundTransparency = 1,
			}, {
				newInstance('UIGradient', {
					Color = ColorSequence.new{
						ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 53, 221)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(3, 156, 251))
					},
					Rotation = 90
				})
			}, UDim.new(1, 0)),
			newInstance('ImageLabel', {
				Name = 'Icon',
				Size = UDim2.new(0, 20, 0, 20),
				Position = UDim2.new(0, 7.5, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				ImageColor3 = library.Settings.theme.LightContrast,
				Image = betterFindIndex(config, 'icon') or 'rbxassetid://6034767621'
			}),
			newInstance('TextLabel', {
				Name = 'Title',
				Size = UDim2.new(1, -35, 1, 0),
				Position = UDim2.new(0, 35, 0, 0),
				ClipsDescendants = true,
				BackgroundTransparency = 1,
				Text = '<b>' .. (betterFindIndex(config, 'title') or 'Page Title') .. '</b>',
				Font = library.Settings.Elements_Font,
				RichText = true,
				TextSize = 14,
				TextColor3 = library.Settings.theme.LightContrast,
				TextXAlignment = Enum.TextXAlignment.Left,
			}),
		}, UDim.new(0, 5))

		local container = newInstance('ScrollingFrame', {
			Name = betterFindIndex(config, 'title') or 'Container',
			Parent = betterFindIndex(config, 'library').sectionContainer,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 0,
			CanvasSize = UDim2.new(0, 0, 0, 0),
		}, {
			newInstance('UIListLayout', {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 10),
			}),
			newInstance('UIPadding', {
				PaddingTop = UDim.new(0, 5),
				PaddingLeft = UDim.new(0, 5),
				PaddingRight = UDim.new(0, 5),
				PaddingBottom = UDim.new(0, 5),
			})
		})

		return setmetatable({
			library = betterFindIndex(config, 'library'),
			button = button,
			container = container,
			sections = {},
		}, library.page)
	end
	function library.section.new(config)
		config = config or {}

		local divisions = library.IsMobile and 1 or betterFindIndex(config, 'Divisions') or 1

		local container = newInstance('Frame', {
			Parent = betterFindIndex(config, 'page').container,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 30),
		}, {
			newInstance('UIListLayout', {
				Padding = UDim.new(0, 5),
				FillDirection = Enum.FillDirection.Horizontal,
			}),
		})

		local sections = {}
		for i = 1, divisions do
			local section = newInstance('Frame', {
				Parent = container,
				BackgroundColor3 = library.Settings.theme.Background,
				Size = UDim2.new(1 / divisions, -(((5 * (divisions - 1)) / divisions) + 1), 0, 16),
				ClipsDescendants = true
			}, {
				newInstance('UIPadding', {
					PaddingTop = UDim.new(0, 10),
					PaddingLeft = UDim.new(0, 10),
					PaddingRight = UDim.new(0, 10),
					PaddingBottom = UDim.new(0, 10),
				}),
				newInstance('UIListLayout', {
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 4),
				}),
				newInstance('NumberValue', {
					Name = 'Section',
					Value = divisions,
				}),
			}, UDim.new(0, 8))
			table.insert(sections, i, section)
		end

		return setmetatable({
			page = betterFindIndex(config, 'page'),
			parent = container,
			container = sections,
			colorpickers = {},
			modules = {},
			binds = {},
			lists = {},
		}, library.section)
	end

	function library:close()
		self.Enabled = false
		task.spawn(function()
			for _, func in pairs(library.end_funcs) do
				func()
			end
		end)
	end
	function library:finish()
		if not self.focusedPage then
			self:SelectPage(self.pages[1], true)
		end
	end

	function library:addPage(config)
		config = config or {}
		config.library = self
		local page = self.page.new(config)

		table.insert(self.pages, page)
		self.sectionContainer.CanvasSize = UDim2.new(0, 0, 0, (#self.pages * self.sectionContainer.AbsoluteSize.Y) + (#self.pages * self.sectionContainer.UIGridLayout.CellPadding.Y.Offset))
		self.sectionContainer.UIGridLayout.CellSize = UDim2.new(0, self.sectionContainer.AbsoluteSize.X, 0, self.sectionContainer.AbsoluteSize.Y)

		page.button.MouseButton1Click:Connect(function()
			self:SelectPage(page, true)
		end)
		return page
	end
	function library.page:addSection(config)
		config = config or {}
		config.page = self
		local section = library.section.new(config)

		table.insert(self.sections, section)

		return section
	end
	function library.page:Resize()
		local size = (#self.sections - 1) * self.library.sectionContainer.UIGridLayout.CellPadding.Y.Offset
		self.library.sectionContainer.UIGridLayout.CellSize = UDim2.new(0, self.library.sectionContainer.AbsoluteSize.X, 0, self.library.sectionContainer.AbsoluteSize.Y)

		for i, section in pairs(self.sections) do
			section:Resize()
			size += section.parent.UIListLayout.AbsoluteContentSize.Y
		end
		for i, section in pairs(self.sections) do
			section:Resize()
		end
		self.container.CanvasSize = UDim2.new(0, 0, 0, size)
	end

	function library.section:Resize(smoth)
		local allSizes = {}

		local containerI = 0
		for i, v in pairs(self.container) do
			if v.ClassName == 'Frame' then
				if v.Visible then
					containerI += 1
				end
			end
		end
		for i, v in pairs(self.container) do
			if v.ClassName == 'Frame' then
				if v:FindFirstChild('Title_Element') and v:FindFirstChild('Title_Element').Toggle.Value then
					if smoth then
						Tween(v, { Size = UDim2.new(1 / containerI, -(((5 * (containerI - 1)) / containerI) + 1), 0, 34) }, 0.2)
					else
						v.Size = UDim2.new(1 / containerI, -(((5 * (containerI - 1)) / containerI) + 1), 0, 34)
					end
					table.insert(allSizes, i, 34)
				else
					local a = 16
					for _, k in pairs(v:GetChildren()) do
						if k.Name:match('_Element') or k.Name:match('_Module') then
							if k.Visible then
								a += k.AbsoluteSize.Y + 4
							end
						end
					end
					if smoth then
						Tween(v, { Size = UDim2.new(1 / containerI, -(((5 * (containerI - 1)) / containerI) + 1), 0, a) }, 0.2)
					else
						v.Size = UDim2.new(1 / containerI, -(((5 * (containerI - 1)) / containerI) + 1), 0, a)
					end
					table.insert(allSizes, i, a)
				end
			end
		end
		if containerI == 0 then
			self.parent.Visible = false
			return
		else
			self.parent.Visible = true
		end

		local size = 0
		for i = 1, #allSizes do
			local a = allSizes[i]
			size = math.max(size, a)
		end

		Tween(self.parent, { Size = UDim2.new(1, 0, 0, size) }, 0)
	end

	function library:SelectPage(page, toggle)
		if toggle and self.focusedPage == page then
			return
		end

		if toggle then
			Tween(page.button, { BackgroundTransparency = 0 }, 0.2)
			Tween(page.button.Frame, { BackgroundTransparency = 0 }, 0.2)
			Tween(page.button.Icon, { ImageColor3 = library.Settings.theme.PlaceHolderColor }, 0.2)
			Tween(page.button.Title, { TextColor3 = library.Settings.theme.PlaceHolderColor }, 0.2)
            Tween(self.sectionContainer, { CanvasPosition = Vector2.new(0, ((table.find(self.pages, page) - 1) * self.sectionContainer.AbsoluteSize.Y) + ((table.find(self.pages, page) - 1) * self.sectionContainer.UIGridLayout.CellPadding.Y.Offset) ) }, 0.2)

			local focusedPage = self.focusedPage
			self.focusedPage = page

			if focusedPage then
				self:SelectPage(focusedPage)
			end
			task.spawn(function()
				page:Resize()
			end)
		else
			Tween(page.button.Frame, { BackgroundTransparency = 1 }, 0.2)
			Tween(page.button, { BackgroundTransparency = 1 }, 0.2)
			Tween(page.button.Icon, { ImageColor3 = library.Settings.theme.LightContrast }, 0.2)
			Tween(page.button.Title, { TextColor3 = library.Settings.theme.LightContrast }, 0.2)
			if page == self.focusedPage then
				self.focusedPage = nil
			end
		end
	end

	function library.section:addTitle(config)
		config = config or {}

		local parent = (betterFindIndex(config, 'section') or 1) > #self.container and self.container[#self.container] or self.container[betterFindIndex(config, 'section') or 1]
		if parent:FindFirstChild('Title_Element') then return end
		local title = betterFindIndex(config, 'title') or ''

		local Title = newInstance('Frame', {
			Name = 'Title_Element',
			Parent = parent,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 20),
			LayoutOrder = 0,
		}, {
			newInstance('TextLabel', {
				BackgroundTransparency = 1,
				Size = UDim2.new(0, getTextSize(title, 14, library.Settings.Elements_Font).X, 0, 14),
				Position = UDim2.new(0, 0, 0, 0),
				AnchorPoint = Vector2.new(0, 0),
				RichText = true,
				Text = '<b>' .. title .. '</b>',
				TextSize = 14,
				TextColor3 = library.Settings.theme.TextColor,
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = library.Settings.Elements_Font
			}),
			newInstance('ImageButton', {
				AutoButtonColor = false,
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 14, 0, 14),
				Position = UDim2.new(1, 0, 0, 0),
				AnchorPoint = Vector2.new(1, 0),
				Image = 'rbxassetid://7733717447',
				ImageColor3 = library.Settings.theme.TextColor
			}),
			newInstance('BoolValue', {
				Name = 'Toggle',
				Value = false
			})
		})

		local debounce = false
		Title.ImageButton.MouseButton1Click:Connect(function()
			if debounce then return end
			Title.Toggle.Value = not Title.Toggle.Value
			debounce = true
			self:Resize(true)
			rippleEffect(Title.ImageButton, 0.5, 6)
			Tween(Title.ImageButton, { Rotation = Title.Toggle.Value and 180 or 0 }, 0.2).Completed:Wait()
			debounce = false
		end)
	end
	function library.section:addButton(config)
		config = config or {}
		local text = betterFindIndex(config, 'Text')
		local disabled = betterFindIndex(config, 'Disabled') or false
		local button = newInstance('ImageButton', {
			Name = 'Button_Module',
			Parent = (betterFindIndex(config, 'section') or 1) > #self.container and self.container[#self.container] or self.container[betterFindIndex(config, 'section') or 1],
			BackgroundColor3 = library.Settings.theme.DarkContrast,
			AutoButtonColor = false,
			ClipsDescendants = true,
			Size = UDim2.new(1, 0, 0, 25),
		}, {
            newInstance('TextLabel', {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = (text and text ~= '' and text) or 'Button',
                Font = library.Settings.Elements_Font,
				TextSize = 14,
                RichText = true,
                TextColor3 = library.Settings.theme.TextColor,
            }),
			newInstance('ImageLabel', {
				Image = 'rbxassetid://7072718362',
				ImageColor3 = library.Settings.theme.Error,
				ImageTransparency = 1,
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 15, 0, 15),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				ZIndex = 2
			}),
			newInstance('StringValue', {
				Name = 'SearchValue',
				Value = ((text and text ~= '' and text) or 'Button'):gsub('<[^<>]->', ''),
			}),
		}, UDim.new(0, betterFindIndex(config, 'Corner') or 5))

		table.insert(self.modules, button)
		self.page:Resize()

		local function Disabled()
			disabled = true

			Tween(button, { BackgroundTransparency = 0.5 }, 0.2)
			Tween(button.TextLabel, { TextTransparency = 0.5 }, 0.2)
			Tween(button.ImageLabel, { ImageTransparency = 0 }, 0.2)
		end
		local function Enabled()
			disabled = false

			Tween(button, { BackgroundTransparency = 0 }, 0.2)
			Tween(button.TextLabel, { TextTransparency = 0 }, 0.2)
			Tween(button.ImageLabel, { ImageTransparency = 1 }, 0.2)
		end
		local function Update(new_config)
			new_config = new_config or {}
			for i,v in pairs(new_config) do
				config[i] = v
				if string.lower(tostring(i)) == 'text' then
					button.TextLabel.Text = v
				elseif  string.lower(tostring(i)) == 'disabled' then
					if v then
						Disabled()
					else
						Enabled()
					end
				end
			end
		end

		if disabled then
			Disabled()
		end

		local debounce
		button.MouseButton1Click:Connect(function()
			if debounce or disabled then return end

			rippleEffect(button, 0.5)

			debounce = true

			Tween(button, { BackgroundTransparency = 0.5 }, 0.2)
			if betterFindIndex(config, 'CallBack') then
				betterFindIndex(config, 'CallBack')()
			end
			Tween(button, { BackgroundTransparency = 0 }, 0.2)

			debounce = false
		end)

		return { Disabled = Disabled, Enabled = Enabled, Update = Update }
	end
	function library.section:addToggle(config)
		config = config or {}
		local title = betterFindIndex(config, "Title") or 'Toggle'
		local disabled = betterFindIndex(config, 'Disabled') or false
		local toggle = newInstance("ImageButton", {
			Name = "Toggle_Module",
			Parent = (betterFindIndex(config, "section") or 1) > #self.container and self.container[#self.container] or self.container[betterFindIndex(config, "section") or 1],
			AutoButtonColor = false,
			BackgroundColor3 = library.Settings.theme.DarkContrast,
			Size = UDim2.new(1, 0, 0, 25),
		}, {
			newInstance('UIPadding', {
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
			}),
			newInstance("TextLabel", {
				Size = UDim2.new(1, -40, 1, 0),
				BackgroundTransparency = 1,
				Font = library.Settings.Elements_Font,
				TextColor3 = library.Settings.theme.TextColor,
				-- RichText = true,
				Text = title,
				TextSize = 14,
				ClipsDescendants = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
			}),
			newInstance("Frame", {
				BackgroundColor3 = library.Settings.theme.Background,
				BorderSizePixel = 0,
				Size = UDim2.new(0, 35, 0, 12),
				Position = UDim2.new(1, 0, 0.5, 0),
				AnchorPoint = Vector2.new(1, 0.5),
			}, {
				newInstance("Frame", {
					Name = "Button",
					BackgroundColor3 = library.Settings.theme.LightContrast,
					Position = UDim2.new(0, 0, 0.5, 0),
					AnchorPoint = Vector2.new(0, 0.5),
					Size = UDim2.new(0, 14, 0, 14),
				}, {
					newInstance('UIGradient', {
						Color = ColorSequence.new{
							ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 53, 221)),
							ColorSequenceKeypoint.new(1, Color3.fromRGB(3, 156, 251))
						},
						Enabled = false
					}),
				}, UDim.new(1, 0)),
			}, UDim.new(1, 0)),
			newInstance('ImageLabel', {
				Image = 'rbxassetid://7072718362',
				ImageColor3 = library.Settings.theme.Error,
				ImageTransparency = 1,
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 15, 0, 15),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				ZIndex = 2
			}),
			newInstance("StringValue", {
				Name = "SearchValue",
				Value = title,
			}),
		}, UDim.new(0, betterFindIndex(config, "Corner") or 5))

		table.insert(self.modules, toggle)
		self.page:Resize()

		local function Disabled()
			disabled = true

			Tween(toggle, { BackgroundTransparency = 0.5 }, 0.2)
			Tween(toggle.Frame, { BackgroundTransparency = 0.5 }, 0.2)
			Tween(toggle.Frame.Button, { BackgroundTransparency = 0.5 }, 0.2)
			Tween(toggle.TextLabel, { TextTransparency = 0.5 }, 0.2)
			Tween(toggle.ImageLabel, { ImageTransparency = 0 }, 0.2)
		end
		local function Enabled()
			disabled = false

			Tween(toggle, { BackgroundTransparency = 0 }, 0.2)
			Tween(toggle.Frame, { BackgroundTransparency = 0 }, 0.2)
			Tween(toggle.Frame.Button, { BackgroundTransparency = 0 }, 0.2)
			Tween(toggle.TextLabel, { TextTransparency = 0 }, 0.2)
			Tween(toggle.ImageLabel, { ImageTransparency = 1 }, 0.2)
		end
		local function Update(new_config)
			new_config = new_config or {}

			local new_value
			for i,v in pairs(new_config) do
				config[i] = v
				if string.lower(tostring(i)) == 'title' then
					title = betterFindIndex(config, "Title") or title
					toggle.TextLabel.Text = title
					toggle.SearchValue.Value = title
				elseif string.lower(tostring(i)) == 'value' then
					new_value = v
				elseif string.lower(tostring(i)) == 'disabled' then
					if v then
						Disabled()
					else
						Enabled()
					end
				end
			end

			if new_value ~= nil then
				if new_value then
					toggle.Frame.Button.UIGradient.Enabled = true
					toggle.Frame.Button.BackgroundColor3 = Color3.new(1, 1, 1)
					Tween(toggle.Frame.Button, { Position = UDim2.new(1, 0, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5) }, 0.3)

					if betterFindIndex(config, "CallBack") then
						betterFindIndex(config, "CallBack")(true)
					end
				else
					toggle.Frame.Button.UIGradient.Enabled = false
					toggle.Frame.Button.BackgroundColor3 = library.Settings.theme.LightContrast
					Tween(toggle.Frame.Button, { Position = UDim2.new(0, 0, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5) }, 0.3)

					if betterFindIndex(config, "CallBack") then
						betterFindIndex(config, "CallBack")(false)
					end
				end
				task.wait(0.2)
			end
		end

		if disabled then
			Disabled()
		end

		local active = betterFindIndex(config, "Value") or false
		if active then
			Update({ value = active })
		end

		local debounce
		toggle.MouseButton1Click:Connect(function()
			if debounce or disabled then return end

			debounce = true

			active = not active
			Update({ value = active })

			debounce = false
		end)

		return { Disabled = Disabled, Enabled = Enabled, Update = Update }
	end
end

return { Library = library, Discord = Discord, MongoDB = MongoDB }
