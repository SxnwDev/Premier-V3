# Premier UI
### To create your own whitelist system you will need the following:
1. Database in [MongoDB](https://www.mongodb.com)
3. [Discord bot](https://discord.com/developers/applications) (you need access to the bot code)
4. Discord server (the bot has to be inside the server)
#### Script Code (Roblox):
```lua
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/SxnwDev/Premier-V3/main/UI.lua"))()

UI.Discord.Token = '' -- Discord bot Token
UI.Discord.Server = '' -- Discord server ID
UI.MongoDB.API_TOKEN = '' -- MongoDB Token
UI.MongoDB.URL_ENDPOINT = '' -- MongoDB URL EndPoint

local window = UI.Library.new()

-- script content

window:finish() -- THIS MUST ALWAYS GO AT THE END OF THE SCRIPT
```
#### [Bot Code](https://github.com/SxnwDev/Premier-V3/blob/main/WhiteList%20Bot.rar)
