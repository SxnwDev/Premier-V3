# Premier UI
### To create your own whitelist system you will need the following:
1. Database in [MongoDB](https://www.mongodb.com)
3. [Discord bot](https://discord.com/developers/applications) (you need access to the bot code)
4. Discord server (the bot has to be inside the server)
#### Script Code (Roblox):
```lua
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/SxnwDev/Premier-V3/main/UI.lua"))()

library.Discord.Token = '' -- Discord bot Token
library.Discord.Server = '' -- Discord server ID
library.MongoDB.API_TOKEN = '' -- MongoDB Token

local window = library.new()

-- script content

window.finish = true -- THIS MUST ALWAYS GO AT THE END OF THE SCRIPT
```
#### [Bot Code](https://github.com/SxnwDev/Premier-V3/blob/main/WhiteList%20Bot.rar)
