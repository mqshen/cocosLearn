-- module("VoiceSendUI", package.seeall)
VoiceSendUI=class()

function VoiceSendUI:ctor()
	self.widget_tag = 1923
end

function VoiceSendUI:init(parent, recordBtn,uploadCallback, translateCallback, lengthCallback)
	local flag = nil
	local touch_layer = CCLayer:create()
	touch_layer:setTouchEnabled(true)
	touch_layer:registerScriptTouchHandler(function (eventType, x, y )
		if parent:getChildByTag(self.widget_tag) then
			if self.Label_finger_in and self.Label_finger_out then
				flag = recordBtn:hitTest(cc.p(x,y))
				self.Label_finger_in:setVisible(flag)
				self.Label_finger_out:setVisible(not flag)
				self.ImageView_record:setVisible(flag)
				self.ImageView_cancel:setVisible(not flag)
			end
		end
		return true
	end,false,-99,false)
	parent:addChild(touch_layer)
	if not self.uploadCallback then
    	self.uploadCallback = uploadCallback
    end

    if not self.translateCallback then
		self.translateCallback = translateCallback
	end

	if not self.lengthCallback then
		self.lengthCallback = lengthCallback
	end
end

-- 放开手指后的处理函数
function VoiceSendUI:releaseFinger(isSend,fileName )
	VoiceMgr.stopRecord()
	if isSend and fileName then
		if self.lengthCallback then
			if self.timeLength ~= -99 then
				self.lengthCallback(fileName,os.time()-self.timeLength)
			else
				self.lengthCallback(fileName,15)
			end
		end

		self.timeTotal = 0
		self.handler = scheduler.create(function ( )
			if Voice.is_file_exist(CCFileUtils:sharedFileUtils():getWritablePath().."VoiceAmr/"..fileName) or self.timeTotal >=1 then
				scheduler.remove(self.handler)
				self.handler = nil
				VoiceMgr.upload_amr_to_server( fileName, function ( _fileName, md5Key)
					if md5Key then
						if self.uploadCallback then
							self.uploadCallback(_fileName, md5Key)
						end

						VoiceMgr.get_translate_from_server( md5Key, _fileName, function (_fileName,str )
							-- if str then
								if self.translateCallback then
									self.translateCallback(_fileName,str or "")
								end
							-- end
						end )
					end
				end)
			else
				self.timeTotal = self.timeTotal + 0.1
			end
		end,0.1)
	else
		if self.lengthCallback then
			self.lengthCallback(fileName,-1)
		end
	end
end

function VoiceSendUI:removeRecord(widget )
	local recordWidget = widget:getChildByTag(self.widget_tag)
	if recordWidget then
		-- recordWidget:runAction(animation.sequence({cc.DelayTime:create(0),cc.CallFunc:create(function (  )
			recordWidget:removeFromParentAndCleanup(true)
		-- end)}))
	end
end

-- lengthCallback 当返回-1是表示这条录音可以丢弃
function VoiceSendUI:when_btn_eventType( widget,btn_record,sender,eventType)
	if eventType == TOUCH_EVENT_ENDED then
		self:removeRecord(widget )
		self:releaseFinger(true,self.m_fileName )
        self:removeUI()
    elseif eventType == TOUCH_EVENT_BEGAN then
        self:create(widget,btn_record)
    elseif eventType == TOUCH_EVENT_CANCELED then
    	self:removeRecord(widget )
		self:releaseFinger(false,self.m_fileName )
       	self:removeUI()
    end
end

function VoiceSendUI:removeUI( )
	self.main_widget = nil
	self.m_fileName =nil
	self.Label_finger_in = nil
	self.Label_finger_out = nil
	self.touch_layer = nil
	self.ImageView_record = nil
	self.ImageView_cancel = nil
end

function VoiceSendUI:remove( )
	self:removeUI()
	self.uploadCallback = nil
	self.translateCallback = nil
	self.lengthCallback = nil
	self.timeTotal = nil
	if self.handler then
		scheduler.remove(self.handler)
		self.handler = nil
	end
	self = nil
end

function VoiceSendUI:getInstance()
	return self.main_widget
end

function VoiceSendUI:create(parent, recordBtn )
	if not parent then return end
	self.timeLength = os.time()
	local back_layout = Layout:create()
	back_layout:setSize(CCSize(parent:getSize().width, parent:getSize().height))
	-- back_layout:setTouchEnabled(true)
	parent:addChild(back_layout,self.widget_tag,self.widget_tag)

	self.main_widget = GUIReader:shareReader():widgetFromJsonFile("test/liaotian.json")
	back_layout:addChild(self.main_widget)
    self.main_widget:setAnchorPoint(cc.p(0.5,0.5))
    self.main_widget:setPosition(cc.p(back_layout:getSize().width/2, back_layout:getSize().height/2))

    -- 在录音按钮内要显示的提示
    self.Label_finger_in = tolua.cast(self.main_widget:getChildByName("Label_finger_in"),"Label")
    self.Label_finger_in:setVisible(true)

    -- 在录音按钮外要显示的提示
    self.Label_finger_out = tolua.cast(self.main_widget:getChildByName("Label_finger_out"),"Label")
    self.Label_finger_out:setVisible(false)

    local Panel_mirc = tolua.cast(self.main_widget:getChildByName("Panel_mirc"),"Layout")

    -- 当手指录音在按钮内显示的图片
    self.ImageView_record = tolua.cast(Panel_mirc:getChildByName("ImageView_record"),"ImageView")
    self.ImageView_record:setVisible(true)

    -- 当手指录音在按钮外显示的图片
    self.ImageView_cancel = tolua.cast(Panel_mirc:getChildByName("ImageView_cancel"),"ImageView")
    self.ImageView_cancel:setVisible(false)

    self.m_fileName = userData.getUserHelpId().."_"..os.time()..".amr"
    VoiceMgr.startRecord(self.m_fileName)

    -- 当还在录音时显示的东西
    local Panel_time = tolua.cast(self.main_widget:getChildByName("Panel_time"),"Layout")
    Panel_time:setVisible(true)

    local Label_left_time = tolua.cast(self.main_widget:getChildByName("Label_left_time"),"Label")
    Label_left_time:setVisible(true)

    local Label_record_end = tolua.cast(self.main_widget:getChildByName("Label_record_end"),"Label")
    Label_record_end:setVisible(false)

    local ImageView_recording = tolua.cast(Panel_mirc:getChildByName("ImageView_recording"),"ImageView")

    local leftTime = userData.getServerTime()
    local recordTime = 0
    local level = 0
    local scale = 1
    self.main_widget:runAction(CCRepeatForever:create(animation.sequence({cc.CallFunc:create(function ( )
        recordTime = userData.getServerTime() - leftTime
        if recordTime > 15 then
        	Panel_time:setVisible(false)
        	Label_left_time:setVisible(false)
        	Label_record_end:setVisible(true)
        	VoiceMgr.stopRecord()
        	self.timeLength = -99
        	ImageView_recording:stopAllActions()
        	ImageView_recording:setScale(1)
        	self.main_widget:stopAllActions()

        else
        	Label_left_time:setText(recordTime)

        	
        	level = VoiceRecord:sharedVoiceRecordMgr():getPowerLevelForRecord()
        	-- if level == 0 then
        		-- level = 1
        	-- end
        	if level == 0 then
        		scale = 1
        	elseif level == 1 then
        		scale = 1.1
        	elseif level == 2 then
        		scale = 1.2
        	else
        		scale = 1.2
        	end
        	ImageView_recording:stopAllActions()
        	ImageView_recording:setScale(scale)
        	ImageView_recording:runAction(CCScaleTo:create(1, 1))
        end
    end), cc.DelayTime:create(0.5)})))
end

