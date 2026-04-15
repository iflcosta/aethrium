local CHANNEL_LOOT = 10

local function sendLootMessage(player, text)
	player:sendChannelMessage("", text, TALKTYPE_CHANNEL_O, CHANNEL_LOOT)
end

local event = Event()
event.onDropLoot = function(self, corpse)
	if configManager.getNumber(configKeys.RATE_LOOT) == 0 then return end

	local player = Player(corpse:getCorpseOwner())
	local mType = self:getType()

	local staminaOk = true
	if player and configManager.getBoolean(configKeys.STAMINA_SYSTEM) then
		staminaOk = player:getStamina() > 840
	end

	if not player or staminaOk then
		local monsterLoot = mType:getLoot()
		local rolls = 1
		
		local boostedCreature = Game.getBoostedCreature()
		if boostedCreature and boostedCreature:lower() == mType:getName():lower() then
			rolls = math.max(1, math.floor(configManager.getFloat(configKeys.BOOSTED_LOOT_MULTIPLIER)))
		end

		for roll = 1, rolls do
			for i = 1, #monsterLoot do
				local lootBlock = monsterLoot[i]
				local chance = lootBlock.chance
				if player then
					local lootBonus = player:getVipLootBonus()
					if lootBonus > 0 then
						chance = math.floor(chance * (1 + lootBonus / 100))
					end
				end

				local item = corpse:createLootItem({
					itemId = lootBlock.itemId,
					chance = chance,
					subType = lootBlock.subType,
					minCount = lootBlock.minCount,
					maxCount = lootBlock.maxCount,
					actionId = lootBlock.actionId,
					uniqueId = lootBlock.uniqueId,
					text = lootBlock.text,
					childLoot = lootBlock.childLoot
				})
				if not item then
					print("[Warning] DropLoot:", "Could not add loot item to corpse.")
				end
			end
		end

		if player then
			local text = ("Loot of %s: %s"):format(mType:getNameDescription(),
			                                       corpse:getContentDescription())
			local party = player:getParty()
			if party then
				party:broadcastPartyLoot(text)
			else
				sendLootMessage(player, text)
			end
		end
	else
		local text = ("Loot of %s: nothing (due to low stamina)"):format(
			             mType:getNameDescription())
		local party = player:getParty()
		if party then
			party:broadcastPartyLoot(text)
		else
			sendLootMessage(player, text)
		end
	end
end
event:register()
