-- bonusUI.lua
-- 月卡领取界面
module("BonusUI", package.seeall)
local main_layer = nil
local m_last_time = nil
local function yuekaChange( )
  if m_last_time ~= userData.getYuekaLastTime() then
    commonPopupManager.gainAwardItem(taskAwardType.TYPE_GOLD,PAY_YUE_KA_YUAN_BAO[2])
	  setBonusBtn()
	end
end

local function do_remove_self(  )
    if main_layer then
        main_layer:removeFromParentAndCleanup(true)
        main_layer = nil
        m_last_time = nil
        UIUpdateManager.remove_prop_update(dbTableDesList.user.name, dataChangeType.update, yuekaChange)
        UIUpdateManager.remove_prop_update(dbTableDesList.user.name, dataChangeType.add, yuekaChange)
        UIUpdateManager.remove_prop_update(dbTableDesList.user.name, dataChangeType.remove, yuekaChange)
        uiManager.remove_self_panel(uiIndexDefine.UI_BONUS_UI)
    end
end

function remove_self( )
    uiManager.hideConfigEffect(uiIndexDefine.UI_BONUS_UI,main_layer,do_remove_self)
end

function dealwithTouchEvent(x,y)
	if not main_layer then
		return false
	end

	local temp_widget = main_layer:getWidgetByTag(999)

	if temp_widget and temp_widget:hitTest(cc.p(x,y)) then
		return false
	else
		remove_self()
		return true
	end
end

function setBonusBtn( )
	local temp_widget = main_layer:getWidgetByTag(999)
	-- 上次领取时间
   	m_last_time = userData.getYuekaLastTime()

   	-- 领取按钮
   	local BonusBtn = tolua.cast(temp_widget:getChildByName("btn_lingqu"),"Button") 
   	BonusBtn:addTouchEventListener(function ( sender, eventType )
   		if eventType == TOUCH_EVENT_ENDED then
   			Net.send(PAY_GET_YUE_KA_BONUS,{})
        end
   	end)

   	if userData.isHasYueka() and not commonFunc.is_in_today(m_last_time) then
   		BonusBtn:setTouchEnabled(true)
   		BonusBtn:setTitleText(languagePack['getBonus'])
   		BonusBtn:setBright(true)
   	else
   		if userData.isHasYueka() then
   			local time = 24*3600
   			local nowTime = commonFunc.get_time_by_timestamp()
   			main_layer:runAction(animation.sequence({cc.DelayTime:create(time - (nowTime.hour*3600+nowTime.min*60+nowTime.sec)), cc.CallFunc:create(function (  )
   				setBonusBtn()
   			end)}))
   		end
   		BonusBtn:setTouchEnabled(false)
   		BonusBtn:setTitleText(languagePack['alreadygetBonus'])
   		BonusBtn:setBright(false)
   	end
end

function create( )
	if main_layer then 
		remove_self()
	end

	UIUpdateManager.add_prop_update(dbTableDesList.user.name, dataChangeType.update, yuekaChange)
	UIUpdateManager.add_prop_update(dbTableDesList.user.name, dataChangeType.add, yuekaChange)
	UIUpdateManager.add_prop_update(dbTableDesList.user.name, dataChangeType.remove, yuekaChange)

	main_layer = TouchGroup:create()
	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/gongpinlibao.json")
  temp_widget:setTag(999)
  temp_widget:setAnchorPoint(cc.p(0.5,0.5))
  temp_widget:setScale(config.getgScale())
  temp_widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))
  main_layer:addWidget(temp_widget)
	uiManager.add_panel_to_layer(main_layer, uiIndexDefine.UI_BONUS_UI)
   	
  local Label_money = tolua.cast(temp_widget:getChildByName("Label_money"),"Label") 
  Label_money:setText(PAY_YUE_KA_YUAN_BAO[2])

  local left_day = tolua.cast(temp_widget:getChildByName("Label_day"),"Label")

  local left_time = userData.getYuekaLeftTime()
  if left_time > 0 then
  	left_day:setText(math.floor(left_time/3600/24))
  else
  	left_day:setText(0)
  end

  local left_mon = tolua.cast(temp_widget:getChildByName("Label_mon"),"Label")
  left_mon:setPositionX(left_day:getPositionX()+left_day:getSize().width)

  setBonusBtn( )

  --关闭按钮
  local btn_close = tolua.cast(temp_widget:getChildByName("btn_close"),"Button")
  btn_close:addTouchEventListener(function (sender, eventType  )
      if eventType == TOUCH_EVENT_ENDED then
          remove_self()
      end
  end)
    
  uiManager.showConfigEffect(uiIndexDefine.UI_BONUS_UI, main_layer)
end