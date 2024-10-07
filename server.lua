local Config = {
    txDataPath = nil,  -- set this to your custom path if needed (keep as nil/false for auto detect), e.g. "/path/to/txData"
    debug = false
}

function pluhPrint(...)
    if Config.debug then print((...)) end
end

local PLAYERS_DBPATH = nil
local cachedPlayersData = nil

local function isDirectory(path)
    local success, blah, code = os.rename(path, path)
    return success or code == 13
end

local function findTxDataFolder()
    if Config.txDataPath then
        if isDirectory(Config.txDataPath) then
            return Config.txDataPath
        else
            print("txData path is not a valid directory")
            return nil
        end
    end

    local currentPath = GetResourcePath("monitor")
    local maxAttempts = 6  
    
    for _ = 1, maxAttempts do
        local txDataPath = currentPath .. "/txData"
        if isDirectory(txDataPath) then
            return txDataPath
        end
        
        currentPath = string.match(currentPath, "(.+)[/\\]")
        if not currentPath then
            return nil
        end
    end
    return nil
end

local function getPlayersData()
    if not PLAYERS_DBPATH then
        print("PLAYERS_DBPATH is not set.")
        return nil
    end

    local file = io.open(PLAYERS_DBPATH, "r")
    if not file then
        print("can't open playersDB.json")
        return nil
    end

    local content = file:read("*all")
    file:close()

    local decoded = json.decode(content)
    cachedPlayersData = decoded.players 
    return cachedPlayersData
end

local function getPlayerPlaytime(playerId)
    local licenseId = GetPlayerIdentifierByType(playerId, 'license')
    if not licenseId then
        pluhPrint("failed to get license for player " .. playerId)
        return nil
    end

    local playersData = getPlayersData()
    if not playersData then
        return nil
    end
    
    for blah, playerData in ipairs(playersData) do
        if playerData.license == licenseId:sub(9) then
            return playerData.playTime or 0
        end
    end
    
    return nil 
end

RegisterNetEvent('pt:getPlayerPlaytime')
AddEventHandler('pt:getPlayerPlaytime', function()
    local source = source
    local playtimeMinutes = getPlayerPlaytime(source)
    if playtimeMinutes then
        TriggerClientEvent('pt:receivePlayerPlaytime', source, playtimeMinutes)
    else
        TriggerClientEvent('pt:receivePlayerPlaytime', source, nil)
    end
end)

Citizen.CreateThread(function()
    local txDataPath = findTxDataFolder()
    if txDataPath then
        PLAYERS_DBPATH = txDataPath .. "/default/data/playersDB.json"
        pluhPrint("PLAYERS_DBPATH set: " .. PLAYERS_DBPATH)
        local initialData = getPlayersData()
        if initialData then
            pluhPrint("players data loaded successfully.")
        else
            pluhPrint('something went wrong with player data.')
        end
    else
        print("failed to locate txData folder try setting it manually at line 2 server.lua")
    end
end)