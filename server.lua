ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('scoreboard:getData', function(source, cb)
    local players = {}
    local xPlayers = ESX.GetPlayers() or {}

    local policeCount = 0
    local emsCount = 0

    for _, id in ipairs(xPlayers) do
        local xPlayer = ESX.GetPlayerFromId(id)
        if xPlayer then
            -- nome (fallback se getName non esiste)
            local name = nil
            if xPlayer.getName then
                name = xPlayer.getName()
            elseif xPlayer.getIdentifier then
                name = xPlayer.getIdentifier()
            else
                name = "Player"..id
            end

            -- job checking (fallback per nomi comuni)
            local jobName = nil
            if xPlayer.job and xPlayer.job.name then
                jobName = xPlayer.job.name:lower()
            elseif xPlayer.getJob and type(xPlayer.getJob) == "function" then
                local jb = xPlayer.getJob()
                if jb and jb.name then jobName = jb.name:lower() end
            end

            if jobName then
                if jobName == 'police' or jobName == 'polizia' then
                    policeCount = policeCount + 1
                elseif jobName == 'ambulance' or jobName == 'ems' or jobName == 'doctor' then
                    emsCount = emsCount + 1
                end
            end

            -- ping (server side native)
            local ping = GetPlayerPing(id) or 0

            table.insert(players, {
                id = id,
                name = name,
                ping = ping,
                job = jobName or "none"
            })
        end
    end

    -- Debug (commenta se vuoi)
    -- print(('[scoreboard] players=%s police=%s ems=%s'):format(#players, policeCount, emsCount))

    cb({
        count = #players,
        police = policeCount,
        ems = emsCount,
        players = players
    })
end)
