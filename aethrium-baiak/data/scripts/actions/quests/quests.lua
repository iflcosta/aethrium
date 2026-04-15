local action = Action()

local annihilatorReward = {2856, 3288, 3319, 3388}
function action.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if item.uid <= 1669 or item.uid >= 27344 then return false end

	local itemType = ItemType(item.uid)
	if itemType:getId() == 0 then return false end

	local itemWeight = itemType:getWeight()
	local playerCap = player:getFreeCapacity()
	if table.contains(annihilatorReward, item.uid) then
		if player:getStorageValue(PlayerStorageKeys.annihilatorReward) == -1 then
			if playerCap >= itemWeight then
				if item.uid == 2856 then
					player:addItem(2856, 1):addItem(3213, 1)
				else
					player:addItem(item.uid, 1)
				end
				player:sendTextMessage(MESSAGE_EVENT_ADVANCE,
				                       'You have found a ' .. itemType:getName() .. '.')
				player:setStorageValue(PlayerStorageKeys.annihilatorReward, 1)
				player:addAchievement("Annihilator")
			else
				player:sendTextMessage(MESSAGE_EVENT_ADVANCE,
				                       'You have found a ' .. itemType:getName() ..
					                       ' weighing ' .. itemWeight .. ' oz it\'s too heavy.')
			end
		else
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "It is empty.")
		end
	elseif player:getStorageValue(item.uid) == -1 then
		if playerCap >= itemWeight then
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE,
			                       'You have found a ' .. itemType:getName() .. '.')
			player:addItem(item.uid, 1)
			player:setStorageValue(item.uid, 1)
		else
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE,
			                       'You have found a ' .. itemType:getName() ..
				                       ' weighing ' .. itemWeight .. ' oz it\'s too heavy.')
		end
	else
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "It is empty.")
	end
	return true
end

action:id(2472, 2480, 2481, 2482)
action:register()
