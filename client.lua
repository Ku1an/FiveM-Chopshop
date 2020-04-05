ESX              = nil
local PlayerData = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer   
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)

local npc = {
  {473.04,-1310.34, 28.22,200.02,'a_m_y_soucent_02'},

}

local giveVehicle = {
  {model = "ADDER", label = "Adder", price = math.random(1700,2500)},
  --{model = "CAR", label = "car", price = math.random(1700,2500)},
  -- add the cars here. 
}

local hasVehicle = false
local vehicletodeliver = nil

AddEventHandler('onClientResourceStart', function (resourceName)
  if(GetCurrentResourceName() ~= resourceName) then
    return
  end
  for _,v in pairs(npc) do

    RequestModel(GetHashKey(v[5]))
    while not HasModelLoaded(GetHashKey(v[5])) do
      Citizen.Wait(1)
    end

  local Ped =  CreatePed(1, v[5], v[1], v[2], v[3], 3374176, false, true)
  SetEntityInvincible(Ped, true)
  SetBlockingOfNonTemporaryEvents(Ped,true)
  SetEntityHeading(Ped, v[4])
  FreezeEntityPosition(Ped, true)
  TaskStartScenarioInPlace(Ped, "WORLD_HUMAN_AA_SMOKE", 0, true)

  end

end)

Citizen.CreateThread(function()
	local place = AddBlipForCoord(Config.ChopShopPlace)
    SetBlipSprite (place, 273)
    SetBlipScale  (place, 0.8)
    SetBlipColour (place, 1)
    SetBlipAsShortRange(place, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('Chop Shop')
    EndTextCommandSetBlipName(place)

end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    local ped = PlayerPedId()

    dist = #(vector3(GetEntityCoords(ped)) - vector3(473.04, -1310.32, 28.22))
    if hasVehicle then
      if dist <= 30.0 and IsPedSittingInAnyVehicle(GetPlayerPed(-1), false) then
        Marker(480.89, -1317.31, 28.20)
        distance = #(vector3(GetEntityCoords(ped)) - Config.ChopShopPlace)
        if distance <= 5.0 then
          ESX.ShowHelpNotification('Tryck ~INPUT_CONTEXT~ för att lämna in den ~r~Stulna~s~ bilen') 
          if IsControlJustPressed(0, 38) then 
            deliverVehicle()
          end
        end
      end
    else
      if dist <= 2.5 then
        ESX.ShowHelpNotification('Tryck ~INPUT_CONTEXT~ för att ~y~prata~s~ med Tyler')
          if IsControlJustPressed(0, 38) then
              TriggerServerEvent('chopshop:cooldown')
          end
      end
    end
  end
end)

RegisterNetEvent('chopshop:getVehicle')
AddEventHandler('chopshop:getVehicle', function()
  
  vehicletodeliver = giveVehicle[math.random(1, #giveVehicle)]
  TriggerEvent('chat:addMessage', { args = { '^1[ChopShop] ', 'Hitta en   ^3' .. vehicletodeliver.label .. '^0 till mig' } })
  hasVehicle = true

end)

function deliverVehicle()
  local pedsVehicle = GetDisplayNameFromVehicleModel(GetEntityModel(GetVehiclePedIsUsing(PlayerPedId())))
  if pedsVehicle == vehicletodeliver.model then
    sellVehicle()
  else
    TriggerEvent('chat:addMessage', { args = { '^1[ChopShop] ', 'Detta är inte riktigt rätt bil. Jag bad om en ^1' .. vehicletodeliver.label .. '' } })
  end
end

function Marker(x, y, z)
  DrawMarker(1, x, y, z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 4.5, 4.5, 1.0, 255, 0, 0, 255, true, false, 2, true, false, false, false) 
end

function sellVehicle()

  conditionVehicle = GetVehicleBodyHealth(GetVehiclePedIsIn(PlayerPedId()))
  if conditionVehicle == 1000 then
    deliverymoney = vehicletodeliver.price * 2
    TriggerEvent('chat:addMessage', { args = { '^1[ChopShop] ', 'Grattis! Du tjänade hela ^2' .. deliverymoney .. ' kr' } })
    TriggerServerEvent('chopshop:givemoney', deliverymoney)
    hasVehicle = false
    DeleteVehicle()
  elseif conditionVehicle <= 950 then
    TriggerEvent('chat:addMessage', { args = { '^1[ChopShop] ', 'Rätt bil men jag bad inte om en kvaddad '.. vehicletodeliver.label .. '!' } })
  elseif conditionVehicle <= 990 then
    deliverymoney = vehicletodeliver.price * 1
    TriggerEvent('chat:addMessage', { args = { '^1[ChopShop] ', 'Grattis! Du tjänade hela ^2' .. deliverymoney .. ' kr' } })
    TriggerServerEvent('chopshop:givemoney', deliverymoney)
    hasVehicle = false
    DeleteVehicle()
  elseif conditionVehicle < 1000 then
    deliverymoney = vehicletodeliver.price * 1.5
    TriggerEvent('chat:addMessage', { args = { '^1[ChopShop] ', 'Grattis! Du tjänade hela ^2' .. deliverymoney .. ' kr' } })
    TriggerServerEvent('chopshop:givemoney', deliverymoney)
    hasVehicle = false
    DeleteVehicle()
  end
end

function DeleteVehicle()
  Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(GetVehiclePedIsIn(PlayerPedId())))
end