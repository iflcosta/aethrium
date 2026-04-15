local currencyConfig = {}

local changeGold = Action()

function changeGold.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local config = currencyConfig[item:getId()]
	if not config then
		return false
	end

	local count = item:getCount()

	-- Upgrade: 100 cheap coins -> 1 expensive coin
	if count == 100 and config.upgradeTo then
		item:remove()
		player:addItem(config.upgradeTo, 1)
		fromPosition:sendMagicEffect(CONST_ME_GIFT_WRAPS)
		return true
	end

	-- Downgrade: 1 expensive coin -> 100 cheap coins
	if config.downgradeTo then
		item:remove(1)
		player:addItem(config.downgradeTo, 100)
		fromPosition:sendMagicEffect(CONST_ME_GIFT_WRAPS)
		return true
	end

	return false
end

-- Dynamic initialization based on 'worth' attributes from items.xml
-- Game.getCurrencyItems() returns items sorted by worth ASCENDING (Low to High)
-- Index 1: Gold, Index 2: Platinum, Index 3: Crystal
local currencyItems = Game.getCurrencyItems()
if #currencyItems > 0 then
	for i = 1, #currencyItems do
		local current = currencyItems[i]
		local currentId = current:getId()
		
		-- Next item in list (i+1) has HIGHER worth (e.g., Platinum after Gold)
		local superior = currencyItems[i + 1]
		-- Previous item in list (i-1) has LOWER worth (e.g., Gold before Platinum)
		local inferior = currencyItems[i - 1]

		currencyConfig[currentId] = {
			upgradeTo = superior and superior:getId() or nil,
			downgradeTo = inferior and inferior:getId() or nil
		}
		
		changeGold:id(currentId)
	end
	changeGold:register()
end
