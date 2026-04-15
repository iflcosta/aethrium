-- VIP System migration
ALTER TABLE `players`
  ADD COLUMN `vip_tier`    TINYINT UNSIGNED NOT NULL DEFAULT 0,
  ADD COLUMN `vip_expires` BIGINT           NOT NULL DEFAULT 0;
