--- The ConstructionController class defines basic and advanced operations
---

-- the set of already created constructions
-- this set will be empty onload of a game, only is used during runtime
builtEntities = {}

-- the current index of the building-selection
bIndex = 1

-- the set of elements which are allowed to delete by the user
classesWhiteList = {
    "BasicBuildingEntity",
    "BedEntity",
    "ChairEntity",
    "CookingSpotEntity",
    "DynamicBuildingEntity",
    "GeneratorEntity",
    "UIManager"
}

-- TODO: this is just a placeholder variable
-- in order to execute crafting
availableResources = 999


-- check if the user can see something in front of him
-- (By shooting a raycast from the players camera to a point in front of him,
-- if something intersects, there is some kind of entity)
function rayCastHit()
    System.LogAlways("# rayCastHit start")

    local from = player:GetPos();
    from.z = from.z + 1.615;

    local dir = System.GetViewCameraDir();
    dir = vecScale(dir, 250);

    local skip = player.id;

    local hitData = {};
    local hits = Physics.RayWorldIntersection(from, dir, 10, ent_all, skip, nil, hitData);

    if hits > 0 then
        dump(hitData[1])
        return hitData[1];
    end

    System.LogAlways("# rayCastHit end")

end


-- remove an item by its class and by an amount
-- class = example - bread, 86e4ff24-88db-4024-abe6-46545fa0fbd1
-- deleteAmount = how often an item gets removed
function removeItem(itemRemovedByClass, deleteAmount)
    local removed = 0
    for i, userdata in pairs(player.inventory:GetInventoryTable()) do
        local item = ItemManager.GetItem(userdata)
        for i = 1, item.amount do
            if (item.class == itemRemovedByClass) then
                if (removed < deleteAmount) then
                    removed = removed + 1
                    player.inventory:RemoveItem(item.id, 1)
                end
            end
        end
    end
end


-- spawn the currently selected entity with the current selection as modelpath
function SpawnBuildingInstance(line)
    System.LogAlways("# SpawnBuildingInstance start")

    if (bIndex == "#") then
        bIndex = 1
    end

    -- check if the construction can be built first
    hitData = rayCastHit()

    -- check if the prerequisites have been met


    if (hitData ~= nil) then

        local entity = hitData

        -- System.LogAlways("Hit entity: " .. tostring(entity))

        -- construct the entity and setup its parameters
        local spawnParams = {}

        -- use arc_BasicBuildingEntity.lua as type for static constructions
        spawnParams.class = "BasicBuildingEntity"

        -- use arc_DynamicBuildingEntity.lua as type for constructions with any kind of functionality
        -- spawnParams.class = "DynamicBuildingEntity"

        -- setup the position from the raycast hit
        spawnParams.position = entity.pos
        spawnParams.orientation = { x = 0, y = 0, z = 1 }

        -- setup naming and serialization
        spawnParams.properties = {}
        spawnParams.properties.bSaved_by_game = 1
        spawnParams.properties.bSerialize = 1

        -- use the input of %line if provided, else use the current building index for the selection of the building
        -- if(line ~= nil) then modelPath = line else  modelPath = parameterizedConstructions[bIndex] end

        -- get the path of the model for the construction
        construction = parameterizedConstructions[bIndex]
        spawnParams.properties.object_Model = construction.modelPath

        -- generate a unique name for the entity
        -- spawnParams.name = construction.modelPath .. "_" .. uuid()
        spawnParams.name = construction.name
        spawnParams.uuid = uuid()

        if (construction.sitable) then
            spawnParams.class = "ChairEntity"
        end

        if (construction.sleepable) then
            spawnParams.class = "BedEntity"
        end

        if (construction.cookable) then
            spawnParams.class = "CookingSpotEntity"
        end

        if (construction.useable) then
            -- spawnParams.class = "GeneratorEntity"
            -- spawnParams.class = "ShootingTarget"
            -- spawnParams.class = "RigidBody"
            -- spawnParams.properties.objModel = "Objects/buildings/houses/budin_mill/barrel_01.cgf"
            -- TODO MAKE spawnParams.class = "RigidBody" useful somewhere!
        end

        add = ""

        if (construction.generator) then
            spawnParams.class = "GeneratorEntity"
            spawnParams.properties.generator = construction.generator
            spawnParams.properties.generatorItem = construction.generatorItem
            spawnParams.properties.generatorItemAmount = construction.generatorItemAmount
            spawnParams.properties.generatorCooldown = construction.generatorCooldown
            spawnParams.properties.generatorOnUse = construction.generatorOnUse
            spawnParams.properties.generatorItemCosts = construction.generatorItemCosts

            --[[
                log("Generator item: " .. construction.generatorItem)
                log("Generator generatorCooldown: " .. construction.generatorCooldown)
                log("Generator generatorItemAmount: " .. construction.generatorItemAmount)
                log("=> Produces " .. construction.generatorItem .. " x" .. construction.generatorItemAmount .. " every " .. construction.generatorCooldown .. " seconds ")
            ]]

        end


        if (construction.generatorOnUse) then
            spawnParams.class = "GeneratorEntity"
            spawnParams.properties.generator = construction.generator
            spawnParams.properties.generatorItem = construction.generatorItem
            spawnParams.properties.generatorItemAmount = construction.generatorItemAmount
            spawnParams.properties.generatorCooldown = construction.generatorCooldown
            spawnParams.properties.generatorOnUse = construction.generatorOnUse
            spawnParams.properties.generatorItemCosts = construction.generatorItemCosts

        end


        -- finish any work _before_ the entity gets initialized and spawned

        -- spawn the new entity
        local ent = System.SpawnEntity(spawnParams)

        -- setup the entity within the world _after_ it has been spawned
        if construction.sitable then
        end

        if construction.sleepable then
        end

        if (construction.useable) then
        end

        if (construction.cookable) then
        end

        if (construction.generator) then

        end

        -- setup the rotation of the spawned entity align the y-axis
        local up = player:GetAngles()
        up = { up.x, up.y, up.z }
        ent:SetAngles(up)

        Game.SendInfoText(
                "Constructing " .. tostring(ent:GetName())
        , true, nil, 2)

        -- undo / redo control, build history
        table.insert(builtEntities, ent)

    end

    System.LogAlways("# SpawnBuildingInstance end")
end


-- locks every entity which is a member of a whitelist element
function lockAll()

    log("")
    log("# Locking all entities")
    log("")

    for i = 1, #classesWhiteList do
        whiteListElement = classesWhiteList[i]

        System.LogAlways("Locking all user constructions by class: " .. whiteListElement)

        local userConstructions = System.GetEntitiesByClass(whiteListElement)

        lockedEntities = 0
        for jii, e in pairs(userConstructions) do
            -- .. do something with locking!
            toggleEntityLock_WithoutRaycast(e, true)

            if (e.Properties.deletion_lock == true) then
                lockedEntities = lockedEntities + 1
            end
        end

        log(whiteListElement .. " - locked " .. lockedEntities .. " entities")
        log("")
    end

end


-- unlocks every entity which is a member of a whitelist element
function unlockAll()
    log("")
    log("# Locking all entities")
    log("")

    for i = 1, #classesWhiteList do
        whiteListElement = classesWhiteList[i]

        System.LogAlways("Unlocking all user constructions by class: " .. whiteListElement)

        local userConstructions = System.GetEntitiesByClass(whiteListElement)

        unlockedEntities = 0
        for jii, e in pairs(userConstructions) do
            -- .. do something with locking!
            toggleEntityLock_WithoutRaycast(e, false)

            if (e.Properties.deletion_lock == false) then
                unlockedEntities = unlockedEntities + 1
            end
        end

        log(whiteListElement .. " - unlocked " .. unlockedEntities .. " entities")
        log("")
    end
end

function toggleEntityLock_WithoutRaycast(entityRef, newValue)
    -- System.LogAlways("# toggleEntityLock_WithoutRaycast start")


    -- entityRef
    if entityRef ~= nil then

        -- toggle the current state (true => false, false => true)
        entityRef.Properties.deletion_lock = newValue

        if (entityRef.Properties.deletion_lock) then
            -- visRes = "Locked entity: " .. tostring(entityRef:GetName()) .. "\n" .. "ID: " .. tostring(hitData.entity:GetRawId())
        else
            -- visRes = "Unlocked entity: " .. tostring(entityRef:GetName()) .. "\n" .. "ID: " .. tostring(hitData.entity:GetRawId())
        end

        -- output state message
        -- System.LogAlways(visRes)

    end

    -- System.LogAlways("# toggleEntityLock_WithoutRaycast end")
end


-- Toggles the currently "seen" deletion_lock state
-- If the entity's deletion_lock property's value equals to zero, it wont be deleted
-- Also dumps information about the current entity to the console
function toggleEntityLock()
    System.LogAlways("# toggleEntityLock start")

    -- execute a raycast within the players fov
    hitData = rayCastHit()

    -- if our ray collided with something ...
    if (hitData ~= nil) then

        -- get the entity from the collision
        result = hitData.entity;

        -- if there was an entity related to this collision ...
        if result ~= nil then

            -- toggle the current state (true => false, false => true)
            result.Properties.deletion_lock = not result.Properties.deletion_lock

            if (result.Properties.deletion_lock) then
                visRes = "Locked entity: " .. tostring(result:GetName()) .. "\n" .. "ID: " .. tostring(hitData.entity:GetRawId())
            else
                visRes = "Unlocked entity: " .. tostring(result:GetName()) .. "\n" .. "ID: " .. tostring(hitData.entity:GetRawId())
            end

            -- output state message
            Game.SendInfoText(visRes, true, nil, 1)

        end

    end

    System.LogAlways("# toggleEntityLock end")
end


-- delete the current entity (the entity which collides with the raycast)
function deleteRayCastEntityHit()
    System.LogAlways("# deleteRayCastEntityHit start")

    hitData = rayCastHit()

    if (hitData ~= nil and hitData.entity ~= nil and hitData.entity.class ~= nil) then

        result = hitData.entity;

        -- We only want to delete our constructions,
        -- so we keep a whitelist of everything - if the hit entity is within the list, the entity will get deleted
        if (contains(classesWhiteList, result.class)) then

            -- if there is something to delete, log its name to the player first

            if (result.Properties.deletion_lock == false) then

                visRes = "Removing construction: " .. tostring(result:GetName())

                -- remove the entity by its id
                System.RemoveEntity(result.id)
            else
                visRes = "Cant remove entity because its locked: \n" .. tostring(result:GetName())

            end

            Game.SendInfoText(visRes, true, nil, 1)


        end

    end

    System.LogAlways("# deleteRayCastEntityHit end")
end


-- list all elements of the whitelist
function show_whitelist()
    System.LogAlways("Elements of the whitelist:")
    for i = 1, #classesWhiteList do
        System.LogAlways(tostring(i) .. ".) " .. classesWhiteList[i])
    end
end


-- lists all whitelisted categories and their related entities to the console
function showall()
    for i = 1, #classesWhiteList do

        whiteListElement = classesWhiteList[i]
        amountOfEntities = 0

        local ents = System.GetEntitiesByClass(whiteListElement)
        for i, e in pairs(ents) do
            -- remove the entity from the game
            -- System.RemoveEntity(e.id)
            -- .. do something with locking!
            amountOfEntities = amountOfEntities + 1
        end

        System.LogAlways("- " .. whiteListElement .. " x" .. amountOfEntities)
    end
end


-- Delete an existing construction by its build-index
function deleteAt(index)
    if (index) then

        deletionEntity = builtEntities[index]

        if (deletionEntity ~= nil and e.Properties.deletion_lock == false) then
            System.RemoveEntity(deletionEntity.id)
        end

        log("Deleting " .. tostring(deletionEntity))
        builtEntities[index] = nil


    end
end

bIndex = 1

--[[ Increments the index of the currently selected building when the player uses the mousewheel (up) ]]
function bIndexInc()

    if (bIndex == "#") then
        bIndex = 1
    end

    if bIndex < #parameterizedConstructions then
        bIndex = bIndex + 1
    end

    -- update the current building for the ui-controller
    updateSelection()

end


--[[ Decrements the index of the currently selected building when the player uses the mousewheel (up)  ]]
function bIndexDec()

    if bIndex > 1 then

        bIndex = bIndex - 1

        if bIndex == 0 then
            return
        end

    end

    -- update the current building for the ui-controller
    updateSelection()

end


-- This method updates the current modelPath using the building-index
-- Also shows the current three buildings from the building set
function updateSelection()

    bDisableCurrentMessage = true
    fDisplayTimeInSeconds = 10

    currentConstruction = parameterizedConstructions[bIndex]

    if (currentConstruction == nil) then
        System.LogAlways("No valid construction provided, skipping")
        return
    end

    desc = "Decoration"
    generatorDesc = ""

    if currentConstruction.generator ~= nil then
        -- currentConstruction.generatorItem
        -- currentConstruction.generatorItemAmount
        -- currentConstruction.generatorCooldown
        -- currentConstruction.generatorOnUse
        generatorDesc = "Generates x" .. currentConstruction.generatorItemAmount .. " "
                .. currentConstruction.generatorItem .. " every "
                .. currentConstruction.generatorCooldown .. " seconds"
    end

    if (currentConstruction.description ~= nil) then
        desc = currentConstruction.description
    end

    priceDesc = ""
    if (currentConstruction.groschenPrice ~= nil) then
        priceDesc = "Costs " .. currentConstruction.groschenPrice .. " Groschen"
    end

    message = tostring(currentConstruction.name) .. " (" .. bIndex .. "/" .. #parameterizedConstructions .. ") \n"
            .. desc .. "\n"
            .. generatorDesc .. "\n"
            .. priceDesc

    -- TODO: only render the selection information if there isnt any other ui currently shown
    Game.SendInfoText(
            message,
            bDisableCurrentMessage,
            nil,
            fDisplayTimeInSeconds
    )
end


--[[

    Helper methods

--]]


-- removes all whitelisted entities by their classes
function deleteall ()

    --[[
    -- local ents = System.GetEntitiesByClass("BasicBuildingEntity")
        for i, e in pairs(ents) do
            -- remove the entity from the game
            System.RemoveEntity(e.id)
        end
    --]]

    for i = 1, #classesWhiteList do

        whitelistElem = classesWhiteList[i]

        local ents = System.GetEntitiesByClass(whitelistElem)

        -- TODO: update the stats, exclude the entities with deletion_lock = true
        removedEntities = 0

        for i, e in pairs(ents) do
            if (e.Properties.deletion_lock == false) then
                -- remove the entity from the game by its id
                System.RemoveEntity(e.id)
                removedEntities = removedEntities + 1
            end
        end

        System.LogAlways("Removing " .. removedEntities .. " entities with class " .. whitelistElem)

    end

end


-- reloads all scripts but is shorter to type into console
function reloadall ()

    -- backup everything that needs to survive the reload
    local townName = config.primary_town_name
    local townPos = config.primary_town_position

    -- unload all controller first
    Script.UnloadScript("Scripts/Manager/arc_UIController.lua")
    Script.UnloadScript("Scripts/Manager/arc_ConstructionController.lua")
    Script.UnloadScript("Scripts/Manager/arc_BuildingsManager.lua")
    Script.UnloadScript("Scripts/Manager/arc_CCommandManager.lua")

    Script.UnloadScript("Scripts/Util/arc_constants.lua")
    Script.UnloadScript("Scripts/Util/arc_utils.lua")
    Script.UnloadScript("Scripts/Util/arc_runtime.lua")

    -- reload every script, including /Data and /Mods
    Script.ReloadScripts()

    Script.ReloadScript("Scripts/Manager/arc_BuildingsManager.lua")

    Script.ReloadScript("Scripts/Util/arc_constants.lua")
    Script.ReloadScript("Scripts/Util/arc_utils.lua")
    Script.ReloadScript("Scripts/Util/arc_runtime.lua")

    -- reload every value we have stored before
    config.primary_town_name = townName
    config.primary_town_position = townPos

end


--[[
    Add & bind user commands to the ingame-console
]]

-- Increment the current building index, mouse wheel up
System.AddCCommand('bIndexInc', 'bIndexInc()', "bIndexInc!")
--System.ExecuteCommand("bind mwheel_up bIndexInc")

-- Decrement the current building index, mouse wheel down
System.AddCCommand('bIndexDec', 'bIndexDec()', "bIndexDec!")
--System.ExecuteCommand("bind mwheel_down bIndexDec")

-- Spawn the currently selected building
System.AddCCommand('architect_spawn', 'SpawnBuildingInstance()', "architect_spawn!")
--System.ExecuteCommand("bind mouse3 architect_spawn ")

-- Delete the current "seen" entity
System.AddCCommand('deleteRayCastEntityHit', 'deleteRayCastEntityHit()', "deleteRayCastEntityHit!")
--System.ExecuteCommand("bind mouse4 deleteRayCastEntityHit ")

-- Detect / dump information about the current "seen" entity
System.AddCCommand('toggleEntityLock', 'toggleEntityLock()', "toggleEntityLock!")
--System.ExecuteCommand("bind mouse5 toggleEntityLock ")


-- helper methods and commands
function SelectFirst()
    bIndex = 1
    updateSelection()
end

function SelectLast()
    bIndex = #parameterizedConstructions - 1
    updateSelection()
end

function Select(newIndex)
    bIndex = newIndex;
    updateSelection()
end