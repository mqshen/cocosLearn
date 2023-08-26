-- gameSpriteMgr.lua
-- 游戏精灵的数据
module("GameSpriteMgr", package.seeall)
local spriteTag = nil
local questionData = nil
local lastSendQuesTime = nil
local URL_REQUEST = "http://stzb.chatbot.nie.163.com/cgi-bin/bot.cgi?ques=%s&user=%s&encode=utf8"

local function setUserInfo( )
	local _,_,_,_,hostnum = loginData.getCacheUserInfo()
	return string.format("game_uid=%s,urs=%s,hostnum=%s,birthday=%s,game_server=%s,citylevel=%s,logintime=%s", userData.getUserId(),configBeforeLoad.getSdkData().uid,sdkMgr:sharedSkdMgr():getUserInfo("USERINFO_HOSTNAME"),userData.getRegTime(),hostnum,politics.getBuildLevel(userData.getMainPos(), 10),userData.getLoginTime())
end

function setGameSpriteTag(index )
	spriteTag = index
end

function getWidthSpace( )
	return 20
end

function getHeightSpace( )
	return 5
end

function getGameSpriteTag(  )
	return spriteTag
end

function remove( )
	spriteTag = nil
	questionData = nil
	lastSendQuesTime = nil
end

function spliteRichText( str, isself )
	local _richText = RichText:create()
    _richText:setVerticalSpace(2)
    _richText:setAnchorPoint(cc.p(0,1))
    _richText:ignoreContentAdaptWithSize(false)
    if isself then
    	_richText:setSize(CCSizeMake(890, 100))
    else
    	_richText:setSize(CCSizeMake(825, 100))
    end
    -- layer:addChild(_richText)
    -- _richText:setPosition(cc.p(1087/2-1005/2, 100))
    -- local re = nil
    -- local count = 0
    local re1 = nil
    local askHeight = 0
    local first = true
    local askLabel = nil
    local askWidth = 0
    local labelStr = ""
    for i, v in ipairs(str) do
    	if v[1] ~= "mbutton" then
	        if v[1] == "r" then
			    re1 = RichElementText:create(i, ccc3(255,255,255), 255, "\n",config.getFontName(), 20)
			    _richText:pushBackElement(re1)
			    re1 = RichElementText:create(i, ccc3(255,255,255), 255, v[2],config.getFontName(), 20)
			else
			    re1 = RichElementText:create(i, ccc3(255,213,110), 255, v[2],config.getFontName(), 20)
			end
			_richText:pushBackElement(re1)
		else
			if not isself then
				askLabel = Label:create()
				askLabel:setFontSize(20)
				local pos =string.find(v[2],"%$")
				if pos then
					labelStr = string.sub(v[2], 1, pos-1)
				else
					labelStr = v[2]
				end
				askLabel:setText(labelStr)
				if first then
					re1 = ImageView:create()
					re1:loadTexture(ResDefineUtil.under_line,UI_TEX_TYPE_PLIST)
					askHeight = askHeight + askLabel:getSize().height + getHeightSpace()+re1:getSize().height+2*getHeightSpace()
					first = false
				end
				askWidth = askWidth + askLabel:getSize().width+getWidthSpace()

				if askWidth > 825 then
					askWidth = 0
					askHeight = askHeight + askLabel:getSize().height + getHeightSpace()
				end

				if pos then
					askWidth = 0
					askHeight = askHeight + askLabel:getSize().height + getHeightSpace()
				end

			end
		end
    end
    _richText:formatText()
    return _richText:getRealHeight()+askHeight
end

function init( )
	questionData = {}
	gameSprite:sharedGameSprite():registerScriptHandler(function (str )
		loadingLayer.remove()
		if not questionData then
			return
		end

		print(">>>>>>>>>>>>>>>>>>str="..str)
        local temp,isFinish= config.gameSpriteSplite(str)
        if not temp then
        	return
        end

		if spriteTag == 1 then
			GameSpriteHotPoint.hotPointCallback(temp)
		end

		if spriteTag == 3 then
			local height = spliteRichText( temp )
			if height < 54 then
				height = 49
			end

			local quest = ""
			if #questionData > 0 then
				for i=#questionData, 1 do
					if questionData[i][1] == 1 then
						quest = questionData[i][5]
						break
					end
				end
			end
			table.insert(questionData,{0,temp,5+height,str, quest})
			if isFinish then
				-- -1 表示评价  99 表示已解决评价 -99表示未解决评价
				table.insert(questionData,{-1,"",93,str, quest})
			end
			GameSpriteQuestion.reloadData()
		end
    end)
end

function getQuestionData(index )
	return questionData[index]
end

function getAllQuestionData(  )
	return questionData
end

function sendQuestion(str )
-- 【system】热点问题
	lastSendQuesTime = os.time()
	loadingLayer.create()
	local quest = config.encodeURL(str)
	local url = string.format(URL_REQUEST,quest, setUserInfo())
    gameSprite:sharedGameSprite():sendHttp(url)
end

function sendHotPoint(str )
    lastSendQuesTime = os.time()
    loadingLayer.create()
    local channel = ""
    if sdkMgr:sharedSkdMgr():getPlatform() == "ios" then
    	channel = "APS"
    else
    	channel = "CHL"
    end

    local quest = config.encodeURL(str..",channel="..channel..",citylevel="..politics.getBuildLevel(userData.getMainPos(), 10)..",vip="..userData.getVipLevelByPay())
    local url = string.format(URL_REQUEST,quest, setUserInfo())
	gameSprite:sharedGameSprite():sendHttp(url)
end

function sendJudge(isSol,index )
	if questionData[index] then
		local quest = config.encodeURL(questionData[index][5])
		local answer = config.encodeURL(string.sub(questionData[index][4],3))
		if isSol == 1 then
			questionData[index][1] = 99
		else
			questionData[index][1] = -99
		end

		local setjudeUrl = function ( )
			return string.format("http://chatbot.nie.163.com:8080/cgi-bin/save_evaluate.py?gameid=87&question=%s&answer=%s&evaluate=%s&encode=utf8&remarks=%s",quest,answer,tostring(isSol),setUserInfo())
		end

		gameSprite:sharedGameSprite():sendHttp(setjudeUrl())
	end
end

function writeQuestion(str )
	local temp = config.gameSpriteSplite("A:"..str)
    if not temp then
    	return
    end
	if spriteTag == 3 then
		if not questionData then
			questionData = {}
		end

		local height = spliteRichText( temp,true )
		table.insert(questionData,{1,temp,5+height,str, str})
		GameSpriteQuestion.reloadData()
	end
end

function getLastQuesTime( )
	return lastSendQuesTime
end
