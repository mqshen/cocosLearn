--config file
--include scale
--当前场景
module("config", package.seeall)
local gWinSize = cc.Director:getInstance():getWinSize()
--放大倍数
local winSizeArray = {800,960, 1024, 1088, 1136,1216,1280,1344,1408,1472,1536,1600,1664,1728,1792,1856,
						1920,1984,2048}
local visibleWidth = {}
visibleWidth[800]=1
visibleWidth[960] =1 
visibleWidth[1024]=1.3
visibleWidth[1088]=1.3
visibleWidth[1136]=1.3
visibleWidth[1216]=1.3
visibleWidth[1280]=1.3
visibleWidth[1344]=1.4
visibleWidth[1408]=1.6
visibleWidth[1472]=1.6
visibleWidth[1536]=1.6
visibleWidth[1600]=1.7
visibleWidth[1664]=1.7
visibleWidth[1728]=1.8
visibleWidth[1792]=1.8
visibleWidth[1856]=1.9
visibleWidth[1920]=2.1
visibleWidth[1984]=2.1
visibleWidth[2048]=2.1
local mScaleNormal = 1
if visibleWidth[gWinSize.width] then
	mScaleNormal = visibleWidth[gWinSize.width]
else
	local smallWinSize = false
	for i,v in ipairs(winSizeArray) do
		if v >= gWinSize.width then
			if winSizeArray[i-1] then
				mScaleNormal = visibleWidth[winSizeArray[i-1]]
			else
				mScaleNormal = visibleWidth[v]
			end
			smallWinSize = true
			break
		end
	end
	if not smallWinSize then
		mScaleNormal = math.ceil((gWinSize.width/7-200)/20)/10+1 
	end
end

local mScaleSmall = mScaleNormal*0.75

local addMapTimesY = math.ceil((gWinSize.width+2*gWinSize.height)/((mScaleSmall-0.1)*200))
local addMapTimesX = math.ceil((gWinSize.height+0.5*gWinSize.width)/((mScaleSmall-0.1)*100))

mScaleSmall = mScaleNormal*1.25

addMapTimesX = math.ceil(addMapTimesX/2)+1  --每次扩大范围的层数
addMapTimesY = math.ceil(addMapTimesY/2)+1

local gScaleX = gWinSize.width/1136
local gScaleY = gWinSize.height/640
local gSacle = (gScaleX>gScaleY and gScaleY) or gScaleX

local card_draw_table = {}
local clientOpenstr = nil

-- local gScheduler = cc.Director:getInstance():getScheduler()
function setDrawCardData ( )
	-- local _str = ""
	-- for k,v in pairs(Tb_cfg_hero) do
	-- 	_str = CCUserDefault:sharedUserDefault():getStringForKey("card_"..k)
	-- 	if _str ~= "" then
	-- 		card_draw_table[k] = 1
	-- 	end 
	-- end
end


function setCardToUserDefault(id )
	card_draw_table[id] = 1
	CCUserDefault:sharedUserDefault():setStringForKey("card_"..id, 1)
end

function getCardDrawById( id )
	return card_draw_table[id]
end

--音乐
-- local pMusic = CCMusic:sharedSound()
-- pMusic:setBackgroundSoundPlay(true)
-- pMusic:setEffectSoundPlay(true)
-- pMusic:createBackgroundSound("gameSound/battle_buff.wav")
-- pMusic:createEffectSound("gameSound/battle_rock.wav")

--设置全局缩放系数
function setgScale(value )
	-- gSacle = value
end

--获取全局缩放系数
function getgScale( )
	return gSacle
end

function getWinSize( )
	return cc.Director:getInstance():getWinSize()
end

--定时器
-- function getScheduler()
-- 	return gScheduler
-- end

--获取每次扩大层数
function getAddMapTimes( )
	return addMapTimesX, addMapTimesY
end

--获取网络范围层数
function getAddNetMapTimes( )
	return addMapTimesX, addMapTimesY
end

--获取正常和缩小的倍数
function getDisplayeScale( )
	return mScaleNormal, mScaleSmall
end

function setAngel(angle )
	m_iAngle = angle
end

--从世界坐标转到3d场景坐标
function countNodeSpace(x,y,angle )
	local winSize = config.getWinSize()
	local W = winSize.width
	local H = winSize.height
	--local x = 255-- 相对于屏幕左下角
	--local y = 592-- 相对于屏幕左下角
	local deltaX = 0-- sprite左下角相对于屏幕左下角
	local deltaY = 0-- sprite左下角相对于屏幕左下角
	-- local angle = m_iAngle

	x = x/W
	y = y/H
	deltaX = deltaX/W
	deltaY = deltaY/H

	local a = 0.5
	local b = 0.5
	local c = math.sqrt(3) / 2

	local y0 = c* (y - deltaY)/ (c * math.cos(angle * math.pi / 180) - (y - b)* math.sin(angle * math.pi / 180))

	local m = c / (c + y0 * math.sin(angle * math.pi / 180))
	local x0 = (x - a) / m - deltaX + a

	return x0*W, y0*H 
end

--从3d场景坐标转换到屏幕坐标
function countWorldSpace( x0,y0,angle )
	local W = gWinSize.width
	local H = gWinSize.height
	--local x0 = 0--//相对于显示对象左下角原点
	--local y0 = 700--//相对于显示对象左下角原点
	local deltaX = 0--//相对于屏幕左下角
	local deltaY = 0--//相对于屏幕左下角
	-- local angle = m_iAngle
		
	x0 = x0/W
	y0 = y0/H
	deltaX = deltaX/W
	deltaY = deltaY/H
		
	local a = 0.5
	local b = 0.5
	local c = math.sqrt(3) / 2

	local m = c / (c + y0 * math.sin(angle * math.pi / 180))
	local x = a + m * (x0 + deltaX - a)
	local y = b + m * (y0 * math.cos(angle * math.pi / 180) + deltaY - b)
	return x*W, y*H
end

--3d场景的缩放
function scaleIn3D( x,y,angle, width, height )
	local dX = width or 200
	local dY = height or 100

	local arr0 = {}
	local arr1 = {} 
	local arr2 = {}
	local arr3 = {}
	arr0[1],arr0[2] = countWorldSpace(x, y, angle)
	arr1[1],arr1[2] = countWorldSpace(x+dX, y,angle)
	arr2[1],arr2[2] = countWorldSpace(x, y+dY,angle)
	arr3[1],arr3[2] = countWorldSpace(x+dX, y+dY,angle)
	return math.sqrt(((arr1[1]-arr0[1]) + (arr3[1]-arr2[1])) * (arr2[2]-arr0[2]) / 2 / (dX * dY))
end

--计算位移差
function countOffset(layer )
	if layer then
		local rootPoint = map.getInstance():convertToWorldSpace(cc.p(0,0))
		local tempX,tempY = config.countWorldSpace(rootPoint.x,rootPoint.y,20)
		return layer:getPositionX()-tempX, layer:getPositionY()-tempY
	end
	return nil,nil
end

function loadRestWarAnimation( )
	CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/chumo_1.ExportJson")
end

function loadSmokeAnimationFile( )
	CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/smoke.ExportJson")
end

function removeSmokeAnimationFile( )
	CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("Export/smoke.ExportJson")
	-- CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("Export/component_99_effect.ExportJson")
	-- CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("Export/component_100_effect.ExportJson")
	-- CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("Export/component_101_effect.ExportJson")
	CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("Export/flag_big.ExportJson")
	CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("Export/flag_small.ExportJson")
end

function loadBirdAnimationFile( )
	CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/bird/bird.ExportJson")
end

function removeBirdAnimationFile( )
	CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("Export/bird/bird.ExportJson")
end

local tExportJson = {
"02_jinengzhunbei",
"03_jinengshiyong",
"11_beishuixijinenggongji",
"12_beiluoshijinenggongji",
"14_jianxuexiaoguo",
"21_xixuexiaoguo",
"26_kapaitexie",
"beitishen",
"blue_26_kapaitexie",
"bubingmingzhong",
"bubing_attack",
"dianran1",
"dianran2",
"dongyao1",
"dongyao2",
"dot1",
"dot2",
"gongbinggongji",
"gongbingshouji",
"huosheng",
"huoyan1",
"huoyan2",
"jinengmingblue",
"jinengmingred",
"kaishi",
"kuibai",
"leidian1",
"leidian2",
"normal_attack_1",
"normal_attack_2",
"pingju",
"qibingmingzhong",
"qibing_attack",
"qusan",
"shanghaiguibi",
"tiaoxin1",
"tiaoxin2",
"yaoshu1",
"yaoshu2",
"zhanbai",
"zhiliao",
}

local battle_plist = {
"02_jinengzhunbei0",
"03_jinengshiyong0",
"11_beishuixijinenggongji0",
"12_beiluoshijinenggongji0",
"14_jianxuexiaoguo0",
"21_xixuexiaoguo0",
"26_kapaitexie0",
"beitishen0",
"blue_26_kapaitexie0",
"bubingmingzhong0",
"bubing_attack0",
"dianran10",
"dianran20",
"dongyao10",
"dongyao20",
"dot10",
"dot20",
"gongbinggongji0",
"gongbingshouji0",
"huosheng0",
"huoyan10",
"huoyan20",
"jinengmingblue0",
"jinengmingred0",
"kaishi0",
"kuibai0",
"leidian10",
"leidian20",
"normal_attack_10",
"normal_attack_20",
"pingju0",
"qibingmingzhong0",
"qibing_attack0",
"qusan0",
"shanghaiguibi0",
"tiaoxin10",
"tiaoxin20",
"yaoshu10",
"yaoshu20",
"zhanbai0",
"zhiliao0",
}
function loadAnimationFile(  )
	for i, v in ipairs(tExportJson) do
		CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/battle/"..v..".ExportJson")
	end
end

function removeAnimationFile( )
	local cache = CCSpriteFrameCache:sharedSpriteFrameCache()	
	local textureCache = CCTextureCache:sharedTextureCache()
	for i, v in pairs(tExportJson) do
		CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("Export/battle/"..v..".ExportJson")
	end

	local count = 1
	local removeAnimationHandler = nil
	removeAnimationHandler = scheduler.create(function ( )
		textureCache:removeTextureForKey("Export/battle/"..battle_plist[count]..".png")
		cache:removeSpriteFramesFromFile("Export/battle/"..battle_plist[count]..".plist")
		count = count + 1
		if count > #battle_plist then
			scheduler.remove(removeAnimationHandler)
			removeAnimationHandler = nil
		end
	end,0.05)
	collectgarbage("collect")

	-- cc.Director:getInstance():getRunningScene():runAction(animation.sequence({cc.DelayTime:create(0.1),cc.CallFunc:create(function (  )
		-- for i, v in pairs(battle_plist) do
			
		-- end
	-- end)}))

	textureCache:removeTextureForKey(ResDefineUtil.guide_res[3])
	textureCache:removeTextureForKey("test/res/Login.png")
	cache:removeSpriteFramesFromFile("test/res/Login.plist")

	cardTextureManager.remove_cache()
end

function getPlatFormInfo( )
	return configBeforeLoad.getPlatFormInfo()
end

function getFontName( )
	return configBeforeLoad.getFontName()
end

--富文本字符串解析
function richText_split(tempStr, arg )
    local pos = 1
    local repos = nil
    local s = nil
    local index = 1
    local tempArg = {}
    if not arg then
    	tempArg["#"] = 1
    	tempArg["@"] = 2
    else
    	for i, v in ipairs(arg) do
    		-- if v ~= "#" then
    			tempArg[v] = i
    		-- end
    	end
    end

    local count = string.len(tempStr)
	local sub_str_tab = {}
	local str = ""
    -- while(true) do
    -- 	s = string.sub(tempStr,pos,pos )
    -- 	if tempArg[s] and pos <=count then
    -- 		if not repos then
    -- 			repos = pos+1
    -- 		else
    -- 			table.insert(sub_str_tab, {tempArg[s],string.sub(tempStr, repos, pos-1)})
    -- 			repos = nil
    -- 			if pos + 1 > count then
    -- 				break
    -- 			else
    -- 				tempStr = string.sub(tempStr, pos+1, count)
    -- 				pos = 0
    -- 			end
    -- 		end
    -- 	end
    -- 	pos = pos + 1
    -- 	if pos >count then
    -- 		break
    -- 	end
    -- end

    local isFirst = false
    while(true) do
    	if pos > count then
    		break
    	end
    	s = string.sub(tempStr,pos,pos )
    	if not tempArg[s] then
    		str = str..s
    	end

    	-- if pos <=count then
    	if tempArg[s] and s ~= "#" then
    		if not isFirst then
    			table.insert(sub_str_tab, {1,str})
    			isFirst = true
    		else
    			table.insert(sub_str_tab, {tempArg[s],str})
    			isFirst = false
    		end
    		str = ""
   --  	elseif s == "#" then
			-- table.insert(sub_str_tab, {1,str})
			-- str = ""
		else
			if pos == count then
				table.insert(sub_str_tab, {1,str})
			end
    	end

    	-- end
    	pos = pos + 1
    end
    if #sub_str_tab == 0 then
   		table.insert(sub_str_tab,{1, tempStr})
   	end
   	return sub_str_tab
end

--两条线段是否相交
local function mult ( a,  b,  c)  
    return (a.x-c.x)*(b.y-c.y)-(b.x-c.x)*(a.y-c.y)
end

--两相交线段的交点
function cross(p1,p2,p3,p4 )
	local v1 = {x = p2.x - p1.x, y = p2.y - p1.y}
	local v2 = {x = p4.x - p3.x, y = p4.y - p3.y}
	local cross_K = (v1.x*v2.y - v1.y*v2.x)--p1.x * p2.y - p1.y * p2.x
	local ConA = p1.x * v1.y - p1.y * v1.x
	local ConB = p3.x * v2.y - p3.y * v2.x


	return (ConB * v1.x - ConA * v2.x) / cross_K, (ConB * v1.y - ConA * v2.y) / cross_K
end 
  
--aa, bb为一条线段两端点 cc, dd为另一条线段的两端点 相交返回true, 不相交返回false  
function intersect(aa, bb, cc, dd)  
    if math.max(aa.x, bb.x)<math.min(cc.x, dd.x) then  
        return false  
	end

    if math.max(aa.y, bb.y)<math.min(cc.y, dd.y) then 
        return false
    end
    
    if math.max(cc.x, dd.x)<math.min(aa.x, bb.x) then
        return false  
    end

    if math.max(cc.y, dd.y)<math.min(aa.y, bb.y) then
        return false 
	end

    if mult(cc, bb, aa)*mult(bb, dd, aa)<0 then 
        return false
    end  
    
    if mult(aa, dd, cc)*mult(dd, bb, cc)<0 then 
        return false 
    end
    return true 
end

-- 计算多边形重心
-- p是个数组， 每组用x, y分别表示坐标
-- p = {[1] = {x =1, y= 1}, [2] = {x=1, y=1},...}
function getGravityPoint(p )
	local area = 0
	local center = {x = 0, y = 0}
	local n =#p

	for i ,v in ipairs(p) do
		area =area+ (p[i].x*p[i+1].y - p[i+1].x*p[i].y)/2
		center.x =center.x+ (p[i].x*p[i+1].y - p[i+1].x*p[i].y) * (p[i].x + p[i+1].x)
		center.y =center.y+ (p[i].x*p[i+1].y - p[i+1].x*p[i].y) * (p[i].y + p[i+1].y)
	end

	area = area+ (p[n].x*p[1].y - p[1].x*p[n].y)/2
	center.x =center.x+ (p[n].x*p[1].y - p[1].x*p[n].y) * (p[n].x + p[1].x)
	center.y =center.y+ (p[n].x*p[1].y - p[1].x*p[n].y) * (p[n].y + p[1].y)

	center.x =center.x/ 6*area
	center.y =center.y/ 6*area
	return center
end

-- posX,posY 参考点的实际坐标x,y
-- coorX,coorY 参考点的行列坐标
-- i,j 想要获取的点的行列坐标
function getMapSpritePos(posX,posY, coorX,coorY, i,j, offsetX, offsetY  )
	local x,y = offsetX or 200, offsetY or 100
	return posX+ ((i- coorX)+(j - coorY))*0.5*x,
		   posY+ 0.5*y*((j-coorY)-(i-coorX))
end

local dump_str = nil
local function dump_value(value,prefix,default_prefix)
    if not prefix then 
        prefix = "" 
    end
    if not default_prefix then 
        default_prefix = ""
    end
    if type(value) == "number" then 
        dump_str = prefix .. dump_str .. tostring(value) .. ","
    elseif type(value) == "string" then 
        dump_str = prefix .. dump_str .. "\"" .. value .. "\"" .. ","
    elseif type(value) == "table" then 
        local prefix_next = prefix .. default_prefix
        dump_str = dump_str .. "\n" .. prefix_next .. "{\n"
        
        for k,v in pairs(value) do
            local key = ""
            if type(k) == "string" then 
                key = "\"" .. k .. "\"" 
            else
                key = tostring(k)
            end
            
            dump_str = dump_str .. prefix_next ..  "\t[" .. key .. "]="
            
            dump_value(v,prefix_next,"\t")
            dump_str = dump_str .. "\n"
            
        end
        dump_str = dump_str .. prefix_next  .. "}\n"
    else
        --nothing
        dump_str = prefix .. dump_str .. tostring(value) .. ","
    end
    
end


function dump(value)
	if not configBeforeLoad.getDebugEnvironment() then
		return
	end
    dump_str = ""
    dump_value(value)
    CCLuaLog(dump_str)
    dump_str = nil
end

function setClientFuncOpen( str )
	clientOpenstr = str
	-- local str = config.getClientFuncOpen()
    local cfg_str = {}
    local temp_str = {}
    if clientOpenstr then
        temp_str = stringFunc.anlayerMsg(clientOpenstr)
        for i, v in pairs(temp_str) do
            cfg_str[tonumber(v[1])] =tonumber( v[2])
        end
    end
    clientOpenstr = cfg_str
end

function getClientFuncOpen(  )
	return clientOpenstr
end

-- public static final int ID_SERVER_OPEN_TIME = 1;
	-- public static final int ID_SERVER_ID_ACCEPTABLE = 3;
	-- public static final int ID_CLIENT_FUNC_OPEN = 4;
	-- public static final int ID_CLIENT_VERSION_MIN = 5;
function ClientFuncisVisible ( eventtype )
 	local str = nil
 	for k,v in pairs(allTableData[dbTableDesList.sys_param.name]) do
		if v.param_id == 4 then 
			str = v.value
		end
	end

	if str then
		local temp_str = stringFunc.anlayerMsg(str)
		local cfg_str = {}
	    for i, v in pairs(temp_str) do
	        cfg_str[tonumber(v[1])] =tonumber( v[2])
	    end

	    if cfg_str[eventtype] then
	        if cfg_str[eventtype] == 1 then
	            return true
	        else
	            return false
	        end
	    end
	end
	
    if configBeforeLoad.getPlatFormInfo() == kTargetWindows then
        return true
    end

    if eventtype == CLIENT_FUNC_CUSTOMER_SERVICE or eventtype == CLIENT_FUNC_GAME_SPRITE then
    	return true
    end

    if eventtype == CLIENT_FUNC_IOS_COMMENT then
    	if sdkMgr:sharedSkdMgr():getPlatform() == "ios" then
    		return true
    	else
    		return false
    	end
    end

    if sdkMgr:sharedSkdMgr():getChannel() == "netease" and sdkMgr:sharedSkdMgr():getPlatform() ~= "ios" then
        return true
    end
    return false
end

function gameSpriteSplite( str )
	-- A:【张飞】#r    #R张飞·五星#n：#r    五星蜀将，骑兵，攻击距离2，COST值3.5
	-- #r    #G初始技能#n：长坂之吼->2回合准备时间，对敌军群体发动1次无视兵种相克的猛烈攻击（伤害率#R225%#n）
	-- #r    #R张飞·四星#n：#r    四星蜀将，步兵，攻击距离1，COST值3#r    #G初始技能
	-- #n：锐矛贯体->对敌军群体发动一次攻击（伤害率#R90%#n），并有#R40%#n的机率使其陷入犹豫或怯战状态，无法进行普通攻击或发动技能，持续一定回合
	-- #r    #R武将组合#n：<ask>[桃园结义]</ask>    <ask>[五虎上将]</ask>
	local fiststr = string.sub(str,1,1)
	if fiststr == "1" or fiststr == "0" then
		return false, false
	end

	if fiststr == "E" and string.sub(str,2,2) == ":" then
		return false
	end

	local default_ = false
	local tempStr_ = string.gsub(str, "<默认回复>", function (n)
		if n then
			default_ = true
			return ""
		end
    end)

	local temp_str = {}

	-- if default_ then
	-- 	table.insert(temp_str, {"n", string.sub(tempStr,3)})
	-- 	return temp_str, false
	-- end

	local len = string.len(str)
	local index = 2
	if default_ then
		str = tempStr_
	end

	local string = "" 
	local signal = nil
	local nowStr = nil
	local ifInsertString = function ( temp_string)
		if string.len(string) > 0 and #temp_str>0 then
			temp_str[#temp_str][2] = temp_string
			string = ""
		end
	end

	local ifchangeLineOrColor = function ( temp_index )
		if index+1<len then
			table.insert(temp_str,{string.sub(str,temp_index+1,temp_index+1),""})
			index = index + 2
		end
	end

	local isAsk = function (  )
		table.insert(temp_str,{"ask",""})
		index = index + 5
	end

	local isAskEnd = function ( )
		table.insert(temp_str,{"n",""})
		index = index + 6
	end

	local isButton = function (  )
		table.insert(temp_str,{"button",""})
		index = index + 8
	end

	local isButtonEnd = function ( )
		table.insert(temp_str,{"n",""})
		index = index + 9
	end

	local isMButton = function ( )
		table.insert(temp_str,{"mbutton",""})
		index = index + 9
	end

	local isMButtonEnd = function ( )
		table.insert(temp_str,{"n",""})
		index = index + 10
	end

	local splitText = nil
	splitText = function ( )
		local flag = false
		if string.sub(str,index,index) == "#" then
			flag = true
			ifInsertString(string)
			ifchangeLineOrColor(index)
		elseif string.sub(str,index,index) == "<" then
			if index+4 <= len and string.sub(str,index,index+4) == "<ask>" then
				flag = true
				ifInsertString(string)
				isAsk()
			elseif index+5 <= len and string.sub(str,index,index+5) == "</ask>" then
				flag = true
				ifInsertString(string)
				isAskEnd()
			elseif index+7 <= len and string.sub(str,index,index+7) == "<button>" then
				flag = true
				ifInsertString(string)
				isButton()
			elseif index+8 <= len and string.sub(str,index,index+8) == "</button>" then
				flag = true
				ifInsertString(string)
				isButtonEnd()
			elseif index+8 <= len and string.sub(str,index,index+8) == "<mbutton>" then
				flag = true
				ifInsertString(string)
				isMButton()
			elseif index+9 <= len and string.sub(str,index,index+9) == "</mbutton>" then
				flag = true
				ifInsertString(string)
				isMButtonEnd()
			end
		end

		if index < len and flag then
			nowStr = string.sub(str,index,index)
			if nowStr == "#" or nowStr == "<" then
				splitText()
			end
		end
	end

	table.insert(temp_str,{"n",""})
	while true do
		index = index + 1
		if index > len then
			if string.len(string) > 0 then
				ifInsertString(string)
			end
			break
		end

		splitText()	
		if index <= len then
			nowStr = string.sub(str,index,index)
			-- if nowStr == "#" or nowStr == "<" then
			-- 	splitText()
			-- 	nowStr = string.sub(str,index,index)
			-- 	if nowStr ~= "#" and nowStr ~= "<" then
			-- 		index = index - 1
			-- 	else
			-- 		print(">>>>>>>>>>>>>>>>>format error!!")
			-- 	end
			-- else
				string = string..nowStr
			-- end
		end
	end

	if default_ then
		return temp_str,false
	else
		return temp_str,true
	end
end


function encodeURL(s)
    s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(s, " ", "+")
end

function decodeURL(s)
    s = string.gsub(s, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
    return s
end
