ESX = nil
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(100)
    end
end)

local display = false

local function toggleScoreboard(state)
    display = state
    SendNUIMessage({
        type = "toggle",
        show = state
    })
end

local function refreshData()
    ESX.TriggerServerCallback("scoreboard:getData", function(data)
        SendNUIMessage({
            type = "update",
            count = data.count,
            police = data.police,
            ems = data.ems,
            players = data.players
        })
    end)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        -- F11 -> apri/chiudi
        if IsControlJustReleased(0, 344) then
            toggleScoreboard(not display)
            if not display then
                -- chiuso -> niente
            else
                -- aperto -> carica dati subito
                refreshData()
            end
        end

        -- Se è aperta, aggiorna ping ogni 5s (side effect: puoi anche chiamare refreshData con tempo)
        if display then
            -- ESC (322) o BACKSPACE (177) chiudono
            if IsControlJustReleased(0, 322) or IsControlJustReleased(0, 177) then
                toggleScoreboard(false)
            end
        end
    end
end)

-- Aggiornamento automatico ping ogni 5 secondi se è aperta
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        if display then
            refreshData()
        end
    end
end)
