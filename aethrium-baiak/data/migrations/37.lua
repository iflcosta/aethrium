function onUpdateDatabase()
	logMigration("> Updating database to version 38 (game shop history)")

	db.query([[
		CREATE TABLE IF NOT EXISTS `shop_history` (
			`id`         INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
			`account`    INT NOT NULL,
			`player_id`  INT NOT NULL,
			`date`       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
			`title`      VARCHAR(255) NOT NULL,
			`price`      INT NOT NULL,
			`costSecond` TINYINT(1) NOT NULL DEFAULT 0,
			`count`      INT NOT NULL DEFAULT 0,
			`extra`      VARCHAR(255) NULL
		) ENGINE=InnoDB DEFAULT CHARSET=utf8
	]])

	return true
end
