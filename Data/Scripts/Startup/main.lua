---
--- Entry point for the project
--- Created by Benjamin Foo
--- DateTime: 03.03.2020 01:01
---

-- load mathematical operations for lua
Script.ReloadScript("Scripts/Math/linmath.lua")

-- load utility methods for development
Script.ReloadScript("Scripts/Util/Utils.lua")

-- load the console-commands
Script.ReloadScript("Scripts/Manager/CCommandManager.lua")

-- define the constructable buildings of the player
Script.ReloadScript("Scripts/Manager/BuildingsManager.lua")

-- add event-handlers for common in-game events
Script.ReloadScript("Scripts/Manager/EventManager.lua")

-- load the core api of the project
Script.ReloadScript("Scripts/Manager/BuildController.lua")

-- if this gets printed the mod should work :)
System.LogAlways("kcd architect 0.3b - initialized!")
