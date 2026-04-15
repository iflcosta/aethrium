-- Reset System v2 Migration
-- Run this on the aethrium database before starting the updated server.

ALTER TABLE `players`
  ADD COLUMN IF NOT EXISTS `reset_bonus_hp`   INT NOT NULL DEFAULT 0 AFTER `reset`,
  ADD COLUMN IF NOT EXISTS `reset_bonus_mana` INT NOT NULL DEFAULT 0 AFTER `reset_bonus_hp`,
  ADD COLUMN IF NOT EXISTS `reset_bonus_cap`  INT NOT NULL DEFAULT 0 AFTER `reset_bonus_mana`,
  ADD COLUMN IF NOT EXISTS `sealed_skills`    INT UNSIGNED NOT NULL DEFAULT 0 AFTER `reset_bonus_cap`;
