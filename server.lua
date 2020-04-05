ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


RegisterNetEvent('chopshop:givemoney')
AddEventHandler('chopshop:givemoney', function(money)
    local playerId = source
    local xPlayer = ESX.GetPlayerFromId(playerId) 
    xPlayer.addMoney(money)
end)


RegisterNetEvent('chopshop:cooldown')
AddEventHandler('chopshop:cooldown', function()
    local playerId = source
    local xPlayer = ESX.GetPlayerFromId(playerId) 

    MySQL.Async.fetchScalar('SELECT time FROM cooldowns WHERE id = @id AND typeofcooldown = @typeofcooldown', {
        ['@id'] = xPlayer.getIdentifier(),
        ['@typeofcooldown'] = 'chopshop'
    },
    function(result)
        if result ~= nil then
            cooldown = os.time() - result
            if cooldown >= Config.ChopShopcooldown then
                MySQL.Sync.execute("UPDATE cooldowns SET time=@time WHERE id=@id AND typeofcooldown = @typeofcooldown", {
                    ['@id'] = xPlayer.getIdentifier(), 
                    ['@typeofcooldown'] = 'chopshop', 
                    ['@time'] =  os.time()
                })
                TriggerClientEvent('chopshop:getVehicle', playerId)
            else
                TriggerClientEvent('chat:addMessage', playerId, { args = { '^1[ChopShop] ', 'Tyvärr mannen. Jag köper inte in några bilar just nu' } })
            end
        else
            MySQL.Async.fetchAll("INSERT INTO cooldowns (id, typeofcooldown, time) VALUES(@id, @typeofcooldown, @time)",     
            {["@id"] = xPlayer.getIdentifier(), ["@typeofcooldown"] = 'chopshop', ["@time"] = os.time()})
            TriggerClientEvent('chopshop:getVehicle', playerId)
        end
    end)

end)


