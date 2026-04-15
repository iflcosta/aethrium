-- Battle Pass — Reset diario de tarefas a meia-noite
-- Remove registros de dias anteriores da tabela player_battlepass_daily

local globalevent = GlobalEvent("battlepass_daily_reset")

function globalevent.onTime(interval)
    -- Deletar apenas registros de datas anteriores ao dia de hoje
    db.asyncQuery("DELETE FROM `player_battlepass_daily` WHERE `date` < CURDATE()")
    logInfo("[Battle Pass] Daily tasks resetadas para o novo dia.")
    return true
end

globalevent:time("00:00:00")
globalevent:register()
