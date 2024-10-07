local function formatPlaytime(minutes)
    local days = math.floor(minutes / 1440)
    local hours = math.floor((minutes % 1440) / 60)
    local mins = minutes % 60
    return string.format("%d days, %d hours, %d minutes", days, hours, mins)
end

function RequestPlaytime()
    TriggerServerEvent('pt:getPlayerPlaytime')
end

RegisterNetEvent('pt:receivePlayerPlaytime')
AddEventHandler('pt:receivePlayerPlaytime', function(playtime)
    if playtime then
        local formattedPlaytime = formatPlaytime(playtime)
        TriggerEvent('txcl:showDirectMessage', "Your playtime is: " .. formattedPlaytime, '')
    else
        TriggerEvent('txcl:showDirectMessage', "No playtime found.", '')
    end
end)

RegisterCommand("myplaytime", function()
    RequestPlaytime()
end, false)