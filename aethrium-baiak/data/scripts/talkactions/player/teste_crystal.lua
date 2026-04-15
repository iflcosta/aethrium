local talkaction = TalkAction("!teste")

local crystalCoinItemId = 2160
local crystalCoinAmount = 100

local directionOffsets = {
	[NORTH] = { x = 0, y = -1 },
	[EAST] = { x = 1, y = 0 },
	[SOUTH] = { x = 0, y = 1 },
	[WEST] = { x = -1, y = 0 }
}

function talkaction.onSay(player, words, param)
	local playerPosition = player:getPosition()
	local direction = player:getDirection()
	local offset = directionOffsets[direction]

	if not offset then
		player:sendCancelMessage("Direção inválida para criar o item.")
		return false
	end

	local targetPosition = Position(playerPosition.x + offset.x, playerPosition.y + offset.y, playerPosition.z)
	local tile = Tile(targetPosition)

	if not tile then
		player:sendCancelMessage("Não foi possível criar no sqm à frente.")
		playerPosition:sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local createdItem = Game.createItem(crystalCoinItemId, crystalCoinAmount, targetPosition)
	if not createdItem then
		player:sendCancelMessage("Falha ao criar Crystal Coins.")
		playerPosition:sendMagicEffect(CONST_ME_POFF)
		return false
	end

	targetPosition:sendMagicEffect(CONST_ME_MAGIC_GREEN)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Foram criadas 100 Crystal Coins no sqm à sua frente.")
	return false
end

talkaction:register()
