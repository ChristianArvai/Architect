---
# index markdown file - lua coding guide
layout: default
---
# Coding guide
This unofficial coding guide is focused on how to interact with the different systems of the engine in order to implement custom features using the lua programming language.

There is no sdk or editor needed for basic lua coding in KCD, however, in order to use advanced features, which'll ease your developers life, 
its recommended to get the latest modding tools / SDK for KCD.

Get the SDK / modding-tools at: \
https://www.nexusmods.com/kingdomcomedeliverance/mods/864

## Basics
In order to execute lua code, open the console (with the ^ or ~ key) and type ```#System.Log("Hello World!")``` \
This command should print ```Hello World``` to the ingame-console.

The API of KCD features lua as a programming language for logic / modding / ...

**Note**\
In order to run lua code from the ingame-console, you need to add an # before the actual code, \
otherwise you're executing ingame commands.


### Enabling dev mode
In order to use the developer mode, you have to create a shortcut and append or launch the application with -devmode:

-- release binary
\common\KingdomComeDeliverance\Bin\Win64\KingdomCome.exe -devmode

In order to use the full development profile, and features of the engine, its recommended to use the kingdomcome binary provided by the sdk. 

-- editor binary
\common\KingdomComeDeliverance\Bin\win64releasedll\kingdomcome.exe


wh_lua_better_print = 1
-- Enable advanced debug output in release mode (Like System.LogAlways("..."))


## Lua basics
The source files of your mod have to be get compressed, with a tool like zip or 7zip. 
The resulting archive has to be renamed from name_of_mod.zip to name_of_mod.pak in order to get initialized by the engine.

**Example**\
 dir = { _main.lua, debug.lua, test.lua_ } => _dir.zip_ => _dir.pak_
 
So for example, after all features or changes have been implemented and finished, you just have to create a new *.pak-file from the current sources 
in order to simply compress it, having it all in a single file, or in order to be able to share your mods.

A *pak-file is a simple *.zip file, renamed to pak - so its a straightforward task to create / edit / update the archives, luckily for the modding community :).

### Source paths
When using the editor-binary the following source paths get loaded on startup    
<div class="preformat_code">
- \common\KingdomComeDeliverance\Data\
- \common\KingdomComeDeliverance\Mods\*
</div>

first *.pak-files, than *.lua-files


This allows to edit and reload source files at runtime, outside of the *.pak files.

In order to reload a specific scripts or all scripts  at runtime
<div class="preformat_code">
#Script.UnloadScript("Scripts/Utils/Utils.lua")
#Script.ReloadScript("Scripts/Utils/Utils.lua")
#Script.ReloadScripts()
</div>
To use advanced console features use the following cvar

### Comments
<div class="preformat_code">
-- This is a single-line comment 

--[[ This is a multi-
line comment ]]

</div>

### Common Commands
This list is a short overview of helpful commands provided by the engine.

Logs the given string to the ingame-console
```
System.LogAlways("Hello World!")

userName = "Heinrich"
System.LogAlways("Hallo " .. userName .. "!")
```

Clear the console output
```
System.ClearConsole();
```


change map to <mapname>
```
map <mapname>
```

show all available maps
```
dump_maps
```

Bind a _input-key_ to an _action_
```
bind mouse4 cl_fov 70
bind mouse3 cl_fov 35
```

Log every property of an entity:
```
dump(System.GetEntityByName("dude"))
```

### Related to development 
The following list contains elements related to development use cases.


Reload all lua scripts or by filename (must be inside of pak-archive or source-paths) 
```
Script.ReloadScripts()
Script.ReloadScript(filename)
```


An already loaded lua-file has to get unloaded first in order to reload it at runtime:  
```
Script.UnloadScript(filename)
```


Load and evaluate lua code from string and map it to function 'helloWorld()'
```
helloWorld = loadstring("System.LogAlways('Hello World')")
```


Returns a random value between 0 and 1 (inclusive)
```
randomValue = math.random()
```

Get a reference of the current player entity by name:
```
System.GetEntityByName("dude")
System.GetEntityByName("dude").class = Player
```


Get a reference of the current player entity by class:
```
System.GetEntitiesByClass("Player")
System.GetEntitiesByClass("Player").class = Player

Player = dude ?
```


Get a set of entities within the radius from the center, filtered by entity-class:
```
System.GetEntitiesInSphereByClass( center, radius, EntityClass)
```


Defines a 3d-vector 
```
{x=0, y=0, z=0}

u1 = {x=1, y=0, z=0}
u2 = {x=0, y=1, z=0}
u3 = {x=0, y=0, z=1}
```

Returns 3d-vector for player position within the world 
```
player:GetWorldPos()
```

Execute a raycast and do something with the hit entity
```
local from = player:GetPos();
from.z = from.z + 1.615;

local dir = System.GetViewCameraDir();
dir = vecScale(dir, 50);

local skip = player.id;

local hitData = {};
local hitCount = Physics.RayWorldIntersection(from, dir, 10, ent_all, skip, nil, hitData);

if hitCount > 0 then
    local entity = hitData[1]
    System.LogAlways("Hit entity: " .. tostring(entity))
    -- dome something
end
```

### User Interface
Show ingame view with ui-elements for n seconds: \
```
Game.SendInfoText("Hello world ", false, nil, n)
```

Show a dialog at the top right corner with a title, and detail-section for 5 seconds:\ 
```
Game.ShowTutorial("$h;Title$h_end;This is a simple introduction!",5,false,true)
```

Adds the command with the name 'eval' to the set of commands the console-input 'eval' gets mapped to the lua function 'eval' with a optional parameter %line. 

The help message could be shown with 'eval ?' \
``` 
System.AddCCommand( 'eval', 'eval(%line)', "Help message of eval")
```

shows string in the top right corner
```
wh_ui_CopyrightMsgRight = string
```

shows string in the top left corner 
```
wh_ui_CopyrightMsgLeft = string
```



### Functions
This is a simple definition of a function with parameters:
```
function <function_name>(<parameter>)
    <function body>
end
```

Example: add two variables and return result
```
function add(a,b)
	return a + b
end
```

#### Function references
Functions could be assigned to variables and reused, for example:
```
l = System.LogAlways()
t = tostring()
n = tonumber()

l("Hello World") -- returns Hello World
l(t(42)) -- returns 42
l(t(n(42))) - returns 42
```

### Constrol structures 
This is a simple definition of an if-then-else condition in lua
```
if condition then
    -- if block
  else
    -- optional else block
end
```

Example: If variable a is greater than b, log always ha!
```
a = 1
b = 0
if a > b then
	System.LogAlways("ha!")
end
```

**Ternary operator**\
The ternary operator is a shortcut for the if-else structure
```
visitCount = 0
firstVisit = (visitCount > 0) ? "Welcome new user!" : "Hello again!";
```

### loops 

For every member in the player object, print the name of it
```
for key,value in pairs(player) do System.LogAlways(key) end
```

For every entity within the radius of 100, log their keys to the console
```
local ents = System.GetEntities({x=2000,y=2000,z=100}, 100)
for i,e in pairs(ents) do
	System.LogAlways(tostring(i))
end
```
For every entity within the radius of 100, log their values to the console
```
local ents = System.GetEntities({x=2000,y=2000,z=100}, 100)
for i,e in pairs(ents) do
	System.LogAlways(tostring(e))
end
```

Delete every instance of "BasicEntity"
```
function deleteall ()
    local ents =  System.GetEntitiesByClass("BasicEntity")
    for i,e in pairs(ents) do
        System.RemoveEntity(e.id)
    end
end
```

### CVars 
In order to get the height and width provided by the rendering properties
```
screenHeight = tonumber(System.GetCVar("r_height"))
screenWidth = tonumber(System.GetCVar("r_width"))
```

In order to set a variable from lua use:
```
System.SetCVar("r_Fullscreen", 0)
```


## Mocking KCD-API
see main.lua header

## Using the built-in function
The built-in functions like System.LogAlways, Script.ReloadScript(...), Script.UnloadScript(...) are c++ functions exposed to LUA. 
There is a documentation for all of them in <editor>/tools/luadoc.

## Entities
An entity is an object within the scene (the player, a single plant, the horse - everything is an entity).

The built-in entities are stored at:
- KingdomComeDeliverance\Data\Scripts.pak\Entities\
- KingdomComeDeliverance\Data\Scripts.pak\Scripts\Entities\

### Create a new entity
Two define an entity two things are needed:
- a *.ent file, which maps the entity name with a lua script
- a *.lua file, which contains the executing logic of that entity
 
 
Create *.ent file in KingdomComeDeliverance\Mods\<yourModFolder>\Entities\
```
<Entity
    Name="TestEntity"
    Script="Scripts/Entities/TestEntity.lua"
/>
```

Create *.lua file: Scripts/Entities/TestEntity.lua  
A minimal example of an entity which recieves callbacks from the different systems and the engine could look like this:
```

TestEntity = {
    Client = {},
    Server = {},
    Properties = {},
    States = {},
}

function UIManager:OnPropertyChange()
    self:OnReset();
end;

function UIManager:OnSave(tbl) end;

function UIManager:OnLoad(tbl) end;

function UIManager:OnReset() end;

function UIManager.Server:OnInit() end;

function UIManager.Client:OnInit() end;

function UIManager:OnAction(action, activation, value) end

function UIManager.Client:OnUpdate() end;

function UIManager.Server:OnUpdate() end;

UIManager.FlowEvents = {
    Inputs = { },
    Outputs = { },
}

/>
```

The entity is now able to recieve engine and entity callbacks. Read further information on the crytek documentation:
- [ScriptBind Entity](https://docs.cryengine.com/display/CEPROG/ScriptBind_Entity)
- [ScriptBind Script](https://docs.cryengine.com/display/CEPROG/ScriptBind_Script)
- [ScriptBind System](https://docs.cryengine.com/display/CEPROG/ScriptBind_System)


**Note** \
Delegate the functionality of the entity into a controller class - \
this allows the use usage of ```#Script.ReloadScript("Scripts/Entities/<nameOfLuaFile.lua>")``` 

### Spawning entities
The following code shows how to spawn an entity at a given position entity.pos and some kind of input (line) for the path of the model / *.cgf file:

```
local spawnParams = {}
spawnParams.class = "BasicEntity"
spawnParams.position = entity.pos -- or = { x = 0, y = 0, z = 0 }
spawnParams.orientation = { x = 0, y = 0, z = 1 }
spawnParams.name = "BasicEntityInstance"
spawnParams.properties = {}
spawnParams.properties.bSaved_by_game = 0

-- use the parameter of this method as the models actual file path (will be loaded at runtime)
--[[ 
    for example
    line = "objects/nature/stones/dry_stone_a.cgf"
    line "objects/nature/stones/dry_stone_a.cgf"
]]
spawnParams.properties.object_Model = line

local ent = System.SpawnEntity(spawnParams)
-- do something with the entity
```

### Deleting entities
The following code shows how to delete a given entity by its id
```
entity = <someKindOfEntity>
System.RemoveEntity(entity.id)
```


### Persist entities and its values to scene (savefile)
TODO

### Load entities and its values on scene startup (savefile)
TODO

### Using OnUpdate or deltaTime
TODO

### Disable near distance fade-out
By default, entities, or subclasses of entities, are setup for near distance fade-outs, this means, 
if you move away from the entity in a short distance, the entity gets hidden from the rendering system.

This is more useable for high density scenes or scenes with lot of vegetation or detail.

Use the following snippet for enabling unlimited view distance of an entity.
```
self:SetViewDistUnlimited()
```  

### Event processing 
In order to execute logic at some specific point in the application execution (after the scene has been loaded, onExit, on...)
```
function object:myActionListener(actionName, eventName, eventArgs)

    System.LogAlways("actionName: " .. actionName)
    System.LogAlways("eventName: " .. eventName)

    if eventArgs then
        System.LogAlways("eventArgs: " .. tostring(eventName))
    end
    
end

UIAction.RegisterActionListener(object, "", "", "myActionListener")
```

### SmartObjects
SmartObjects contain some kind of logic or interaction with the player.
This objects are defined in KingdomComeDeliverance\Data\GameData.pak\prefabs\SmartObjects.xml



## Misc.
Get the total income of pribyslawitz
```
NewHomesLuaAPI.GetTotalIncome()
```

## Links / Resources
Lua-Coding\
https://www.lua.org/manual/5.0/

Mod - More Functions for Mouse Right Button\
https://www.nexusmods.com/kingdomcomedeliverance/mods/386

Mod - Cheat\
https://github.com/pryans/KCD-cheat

Cryengine documentation (very helpful)\
- https://docs.cryengine.com/
- https://docs.cryengine.com/display/CEPROG/ScriptBind_System
- https://docs.cryengine.com/display/CEPROG/ScriptBind_Script
- https://docs.cryengine.com/display/CEPROG/Script+Usage
- https://docs.cryengine.com/display/SDKDOC4/Common+Lua
- https://docs.cryengine.com/display/SDKDOC4/Structure+of+a+Script+Entity
- https://docs.cryengine.com/display/SDKDOC4/Common+Lua#CommonLua-Vec2Str

Linear algebra - intersection of a line with plane\
https://rosettacode.org/wiki/Find_the_intersection_of_a_line_with_a_plane#Lua

Modding guide\
https://wiki.nexusmods.com/index.php/Modding_guide_for_KCD

Get the sdk / modding tools\
https://www.nexusmods.com/kingdomcomedeliverance/mods/864




##### TODO / NEW

-- Shows an exclamation mark with the given message in an orange colored font 
Game.ShowNotification("Message")

-- Shows an Message with an icon given by its id
--[[
    0 = none
    1 = weapons
    2 = speech
    3 = crown
    4 = coin stack, money
    5 = star
    6 = pickpocket
    7 = none
    8 = Check mark
    9 = money bag
    10 = none
    11 = horse
    12 = none
    13 = armor 
    14 = swords
    15 = scissors
    ...
]]--
Game.ShowStatCheckResult(0, true);


-- Shows the given text on the upper right corner of the screen
-- Warning - This can be used to display strings even in release mod, I guess, but could lead to error messages.
Game.LogGameEvent(text) 

-- Shows the message surrounded by banneric glyphs 
-- Syntax: Game.SendInfoText(text, [force_clear_current_queue], [category], [time]) 
-- 
-- message - the message you want to display 
-- forceClearCurrentInfoTextQueue -  clears currently displayed infotexts; default is false 
-- category see BlockInfoText - use nil or any other non-numeric value to not set any category 
-- time time in seconds /integer value/; use nil, non-numeric or negative value to use default time 
Game.SendInfoText(message);



-- Displays UI message informing about item transfered into/from players inventory 
-- Syntax: Game.ShowItemsTransfer() 
Game.ShowItemsTransfer(string classId, int amount)

##### Event cycle
server_onInit -> onReset -> onInit -> onLoaded

## Misc.

-- Convert vector with 3 components to human readable string / pretty print \
System.LogAlways("Located at: " .. Vec2Str(player:GetPos()}))

-- Make the player fall \
player.actor:Fall({1,1,1})

-- Makes the actor grab on a ladder \
Human.GrabOnLadder(ScriptHandle ladderId);

-- Get current amount of money by player \
player.inventory:GetMoney()

-- Add or remove money to the players inventory, works with negative value and includes and ui \
AddMoneyToInventory(player,amount)

-- Save the game \
Game.SaveGameViaResting() 

-- Activate frost overlay \
System.SetScreenFx("ScreenFrost_Amount", 1);

-- Show information about the player \
dump(player) \
dump(player.actor) \
dump(player.soul) \
dump(player == System.GetEntityByName("dude") => entity?) \

Take a look into the following files for player manipulation:
- KingdomComeDeliverance/Tools/luadoc/luadoc/C_ScriptBindSoul.html
- KingdomComeDeliverance/Tools/luadoc/luadoc/C_ScriptBindGameRules__AddMinimapEntity@IFunctionHandler__@ScriptHandle@int@float.html
- KingdomComeDeliverance/Tools/luadoc/luadoc/C_ScriptBindGameRules__AddObjective@IFunctionHandler__@int@char__@int@ScriptHandle.html

Enables the black bars used for movie sequences  \
wh_ui_ShowRatioStrips = 0 / 1

Enables / disables the hud \
wh_ui_ShowHud = 0 / 1

Toggles fullscreen-mode \
r_Fullscreen = 0 / 1

### Key-Handling
See the crytek documentation for [Setting up controls and action maps](https://docs.cryengine.com/display/CEPROG/Setting+Up+Controls+and+Action+Maps)

1.) Create a function  \
function testEcho() System.LogAlways("Hello World!") end

2.) Add a command to the console  \
System.AddCCommand('testEcho', 'testEcho()', "testEcho!")

3.) Bind the key (page down) to method testEcho  \
System.ExecuteCommand("bind 'pgdn' testEcho")

### Play Sounds

Utils.ExecuteAudioTrigger('a_l_poi_birdnest')
Utils.ExecuteAudioTrigger('b_sheep_baa')
Utils.ExecuteAudioTrigger('mon_alarm_bell')
Utils.ExecuteAudioTrigger('q_cemetery_flowers_incanation')
Utils.ExecuteAudioTrigger('special_indulgence')
Utils.ExecuteAudioTrigger('lightning')

### Debug
These functionality is only available in debug mode, using the debug exe from the editor

#System.ShowDebugger() - opens the debugger, this can be used to do step by step debugging 

Show a debug string 
wh_dbg_DrawString Teleport the player around the map
