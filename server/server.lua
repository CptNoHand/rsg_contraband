local sharedItems = exports['qbr-core']:GetItems()

exports['qbr-core']:CreateCallback('rsg_contraband:server:contrabandselling:getAvailableContraband', function(source, cb)
    local AvailableContraband = {}
    local src = source
    local Player = exports['qbr-core']:GetPlayer(src)
    if Player then
        for i = 1, #Config.ContrabandList, 1 do
            local item = Player.Functions.GetItemByName(Config.ContrabandList[i])

            if item ~= nil then
                AvailableContraband[#AvailableContraband+1] = {
                    item = item.name,
                    amount = item.amount,
                    label = sharedItems[item.name]["label"]
                }
            end
        end
        if next(AvailableContraband) ~= nil then
            cb(AvailableContraband)
        else
            cb(nil)
        end
    end
end)

RegisterNetEvent('rsg_contraband:server:sellContraband', function(item, amount, price)
    local src = source
    local Player = exports['qbr-core']:GetPlayer(src)
    if Player then
        local hasItem = Player.Functions.GetItemByName(item)
        local AvailableContraband = {}
        if hasItem.amount >= amount then
			TriggerClientEvent('rsg_notify:client:notifiy', src, 'offer accepted', 5000)
            Player.Functions.RemoveItem(item, amount)
            Player.Functions.AddMoney('cash', price, "sold-contraband")
            TriggerClientEvent('inventory:client:ItemBox', src, sharedItems[item], "remove")
            for i = 1, #Config.ContrabandList, 1 do
                item = Player.Functions.GetItemByName(Config.ContrabandList[i])

                if item ~= nil then
                    AvailableContraband[#AvailableContraband+1] = {
                        item = item.name,
                        amount = item.amount,
                        label = sharedItems[item.name]["label"]
                    }
                end
            end
            TriggerClientEvent('rsg_contraband:client:refreshAvailableContraband', src, AvailableContraband)
        else
            TriggerClientEvent('rsg_contraband:client:contrabandselling', src)
        end
    end
end)

RegisterNetEvent('rsg_contraband:server:robContraband', function(item, amount)
    local src = source
    local Player = exports['qbr-core']:GetPlayer(src)
    if Player then
        local AvailableContraband = {}
        Player.Functions.RemoveItem(item, amount)
        TriggerClientEvent('inventory:client:ItemBox', src, sharedItems[item], "remove")
        for i = 1, #Config.ContrabandList, 1 do
            item = Player.Functions.GetItemByName(Config.ContrabandList[i])
            if item then
                AvailableContraband[#AvailableContraband+1] = {
                    item = item.name,
                    amount = item.amount,
                    label = sharedItems[item.name]["label"]
                }
            end
        end
        TriggerClientEvent('rsg_contraband:client:refreshAvailableContraband', src, AvailableContraband)
    end
end)

RegisterNetEvent('rsg_contraband:server:UpdateCurrentCops', function()
    local amount = 0
    local players = exports['qbr-core']:GetQBPlayers()
    for k, v in pairs(players) do
        if v.PlayerData.job.name == "lawman" and v.PlayerData.job.onduty then
            amount = amount + 1
        end
    end
    TriggerClientEvent("rsg_contraband:client:SetCopCount", -1, amount)
end)