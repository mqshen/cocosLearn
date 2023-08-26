local ColorUtil = {}

function ccc3( _r,_g,_b )
    return { r = _r, g = _g, b = _b }
end

ColorUtil.CCC_RED 	= ccc3(255,0,0)
ColorUtil.CCC_GREN 	= ccc3(0,255,0)
ColorUtil.CCC_BLUE 	= ccc3(0,0,255)

--文本常用颜色码
ColorUtil.CCC_TEXT_RED		=	ccc3(255,0,0)
ColorUtil.CCC_TEXT_DEEP_RED = 	ccc3(168,76,78)

ColorUtil.CCC_TEXT_WHITE	=	ccc3(255,255,255)
ColorUtil.CCC_TEXT_GREEN	=	ccc3(0,255,0)
ColorUtil.CCC_TEXT_YELLOW	= 	ccc3(235,191,107)
ColorUtil.CCC_TEXT_GRAY		=	ccc3(166,166,166) --文本灰色

--卡牌星级显示颜色
ColorUtil.CCC_STAR_YELLOW = ccc3(249,228,128)
ColorUtil.CCC_STAR_GREEN = ccc3(163,215,82)
ColorUtil.CCC_STAR_BLUE = ccc3(97,208,244) 					--蓝色
ColorUtil.CCC_STAR_PURPLE = ccc3(224,124,209)   			--紫色

-- 卡牌名字根据质量显示颜色
ColorUtil.CCC_BLACK = ccc3(255,228,182)
ColorUtil.CCC_WHITE = ccc3(163,163,163)                 --二星
ColorUtil.CCC_GREEN = ccc3(91,143,117)
ColorUtil.CCC_BLUE = ccc3(91,96,143)
ColorUtil.CCC_PURPLE = ccc3(143,91,134)   			--五星色


--富文本 关键字颜色码
ColorUtil.CCC_RICH_TEXT_NORMAL 		= 	ccc3(255,255,255)
ColorUtil.CCC_RICH_TEXT_KEY_WORD 	= 	ccc3(125,187,137)

------
ColorUtil.CCC_TEXT_MAIN_TITLE			=	ccc3(211,166,96)	--主标题
ColorUtil.CCC_TEXT_SUB_TITLE			=   ccc3(236,234,157)	--副标题
ColorUtil.CCC_TEXT_MAIN_CONTENT			=   ccc3(255,255,255)	--正文
ColorUtil.CCC_TEXT_TIPS					=   ccc3(125,187,137)	--注释（tips）
ColorUtil.CCC_TEXT_CONDITION			=   ccc3(213,97,94)		--条件文字

function ColorUtil.getHeroColor(quality)
	if quality == 0 then
		return ColorUtil.CCC_BLACK
	elseif quality == 1 then
		return ColorUtil.CCC_STAR_YELLOW
	elseif quality == 2 then
		return ColorUtil.CCC_STAR_GREEN
	elseif quality == 3 then
		return ColorUtil.CCC_STAR_BLUE
	elseif quality == 4 then
		return ColorUtil.CCC_STAR_PURPLE
	else
		return ccc3(255,255,255)
	end
end


function ColorUtil.getHeroNameWrite(id )
	if Tb_cfg_hero[id] then
		return "【"..Tb_cfg_hero[id].name.."】"
	else
		return ""
	end
end

function ColorUtil.getHeroNameWriteByResIdU(iResIdU )
	local iResId = iResIdU%100
	if iResId == dropType.RES_ID_HERO then
		return "【"..Tb_cfg_hero[math.floor(iResIdU/100)].name.."】"
	end
	return ""
end



return ColorUtil