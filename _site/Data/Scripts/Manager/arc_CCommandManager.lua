--- The CCommandManager contains code related to the ingame-console and the management of key-bindings
---


function architect_clear()
    System.ClearConsole();
end


function architect_gamble()
    System.LogAlways("Gambling started ..");

    rand = math.random()
    winThreshold = 0.5
    betAmount = 5

    if rand > winThreshold then
        betAmount = 5
    else
        betAmount = -5
    end

    Game.SendInfoText("Gamble: " .. tostring(betAmount) .. " groschen!", false, nil, 1)

    AddMoneyToInventory(player, betAmount)

    System.LogAlways(".. Gambling finished!")

end


function architect_eval(line)
    System.LogAlways("Begin eval [%s].", tostring(line))
    --Defining a function from the string and run it
    local func = loadstring(line)
    System.LogAlways(tostring(func()))
    System.LogAlways("End eval [%s].", tostring(line))
    return true
end

function log(line)
    architect_log(tostring(line));
end

function architect_log(line)
    System.LogAlways(tostring(line));
end

---- shortcuts
l = System.LogAlways
t = tostring

function architect_help()
    l("")
    l("== architect modification " .. architect_version .. " - initialized and loaded ==");
    l("")
    l("= Commands")
    l("")
    l("architect_help            - Prints this message")
    l("architect_clear           - Clears the console")
    l("architect_gamble          - Gamble in order to win or loose five groschen")
    l("architect_eval            - Eval lua strings")
    l("architect_log             - Log a message to the console")
    l("architect_reload          - Recompile the mod during runtime")
    l("")
    l("= Lua functions - remember to use an # before any lua input, like #showAll()")
    l("")
    l("search('')                 - Logs every name of a construction to the console")
    l("search(\"string\")         - Logs every name which partly matches 'string' to the console")
    l("")
    l("select(\"string\")         - Select the first construction")
    l("select(search(\"string\")) - Select the first construction")
    l("select(nr)               - Select the construction at Number nr")
    l("selectFirst()            - Select the first construction")
    l("selectLast()             - Select the last construction")
    l("")
    l("lockAll()                - Locks all constructions of the user")
    l("unlockAll()              - Unlocks all constructions of the user")
    l("")
    l("deleteall()              - Deletes ALL constructions you've build")
    l("deleteAt(index)()        - Delete the construction with the number <index> (use #showall())")
    l("")
    l("reloadAll()              - Reloads the source files of the modification at runtime")
    l("rayCastHit()             - Use a raycast to determine entities in front of the player")
    l("")
    l("setHomeName('name')      - Sets the town's name")
    l("setHome()                - Sets the current player-location as home / town")
    l("getHome()                - Returns the player to his home / town")
    l("makeSunhine()            - Changes the current weather to sunshine")
    l("")
    l("showStats()              - Display statistics about your town")
    l("")
    l("... any other lua command kcd supports :)")
end


-- key bindings
System.AddCCommand('architect_help', 'architect_help()', "Shows the help overview")
System.AddCCommand('architect_clear', 'architect_clear()', "Clears the console")
System.AddCCommand('architect_gamble', 'architect_gamble()', "Gamble in order to win or loose five groschen")
System.AddCCommand('architect_eval', 'architect_eval(%line)', "Evaluate lua-input")
System.AddCCommand('architect_log', 'architect_log(%line)', "Log %line to the console")
System.AddCCommand('architect_reload', 'reloadAll()', "Log %line to the console")