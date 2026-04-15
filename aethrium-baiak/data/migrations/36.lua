function onUpdateDatabase()
	logMigration("> Updating database to version 37 (battle pass system)")

	-- Tabela principal: progresso do jogador no battle pass
	db.query([[
		CREATE TABLE IF NOT EXISTS `player_battlepass` (
			`player_id`     INT NOT NULL PRIMARY KEY,
			`xp`            INT UNSIGNED NOT NULL DEFAULT 0,
			`level`         TINYINT UNSIGNED NOT NULL DEFAULT 1,
			`elite`         TINYINT(1) NOT NULL DEFAULT 0,
			`claimed_free`  BIGINT UNSIGNED NOT NULL DEFAULT 0,
			`claimed_elite` BIGINT UNSIGNED NOT NULL DEFAULT 0,
			`season`        SMALLINT UNSIGNED NOT NULL DEFAULT 1,
			FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE
		) ENGINE=InnoDB DEFAULT CHARSET=utf8
	]])

	-- Tabela de tarefas diarias (Daily Pass)
	-- claimed_free / claimed_elite sao bitmasks: bit N = tier N+1 coletado (50 bits cabem em BIGINT UNSIGNED)
	db.query([[
		CREATE TABLE IF NOT EXISTS `player_battlepass_daily` (
			`player_id`  INT NOT NULL,
			`task_id`    TINYINT UNSIGNED NOT NULL,
			`type`       VARCHAR(32) NOT NULL,
			`target`     INT NOT NULL,
			`current`    INT NOT NULL DEFAULT 0,
			`completed`  TINYINT(1) NOT NULL DEFAULT 0,
			`date`       DATE NOT NULL,
			PRIMARY KEY (`player_id`, `date`, `task_id`),
			FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE
		) ENGINE=InnoDB DEFAULT CHARSET=utf8
	]])

	return true
end
