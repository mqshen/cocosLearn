local card_loaded_png_list = nil
local clear_timer = nil

local function remove()
	if clear_timer then
		scheduler.remove(clear_timer)
		clear_timer = nil
	end
	
	if card_loaded_png_list then
		card_loaded_png_list = nil
	end
end

local function add_new_card_file(new_file)
	if not card_loaded_png_list then
		card_loaded_png_list = {}
	end

	card_loaded_png_list[new_file] = 1
end

local function deal_with_clear_cache()
	for k,v in pairs(card_loaded_png_list) do
		if v == 1 then
			local temp_texture = CCTextureCache:sharedTextureCache():textureForKey(k)
			if temp_texture and temp_texture:retainCount() == 1 then
				CCTextureCache:sharedTextureCache():removeTextureForKey(k)
				card_loaded_png_list[k] = 0
			end
		end
	end

	scheduler.remove(clear_timer)
	clear_timer = nil
end

local function remove_cache()
	if not card_loaded_png_list then
		return
	end

	if clear_timer then
		scheduler.remove(clear_timer)
		clear_timer = nil
	end

	clear_timer = scheduler.create(deal_with_clear_cache, 0.1)
end

cardTextureManager = {
						add_new_card_file = add_new_card_file,
						remove_cache = remove_cache,
						remove = remove
}