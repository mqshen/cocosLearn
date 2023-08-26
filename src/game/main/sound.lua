--声音播放接口

musicSound = {}
musicSound["skill_expreward"] = "ui/skill_expreward" --技能强化爆击
musicSound["skill_delete"] = "ui/skill_delete" --技能遗忘
musicSound["card_getnormal"] = "ui/card_getnormal" --刷新出普通品质的卡
musicSound["card_getbetter"] = "ui/card_getbetter" --刷新出高品质的卡
musicSound["sys_alarm"] = "ui/sys_alarm" --PVP预警消息
musicSound["mail_file"] = "ui/mail_file" --收取邮件附件
musicSound["buttom_touch"] = "ui/buttom_touch" --按下按钮
musicSound["ui_cancel"] = "ui/ui_cancel" --关闭当前界面或返回上一级界面
musicSound["skill_get"] = "ui/skill_get" --学会新技能
musicSound["skill_exp"] = "ui/skill_exp" --技能强化时走经验条
musicSound["skill_up"] = "ui/skill_up" --技能强化
musicSound["skill_fail"] = "ui/skill_fail" --技能学习失败
musicSound["sys_ring"] = "ui/sys_ring" --收到邮件或有新未读战报
musicSound["mail_send"] = "ui/mail_send" --邮件发送成功
musicSound["sys_quest"] = "ui/sys_quest" --领取任务奖励
musicSound["city_build"] = "ui/city_build" --筑城
musicSound["op_arrow"] = "ui/op_arrow" --开场射火箭
musicSound["op_fire"] = "ui/op_fire" --开场火烧

module("LSound", package.seeall)
local musicPriority = {}
musicPriority["OP_bgm"] = 0
musicPriority["guard_bgm"] = 1
musicPriority["seige_bgm"] = 1
musicPriority["main_bgm4"] = 2
musicPriority["main_bgm3"] = 2
musicPriority["main_bgm2"] = 3
musicPriority["main_bgm1"] = 3
musicPriority["UI_bgm1"] = 3 --全屏界面音乐

local soundSch = nil
local b_isRegister = false
local MUSIC_END = 2
local MUSIC_STOLEN = 3
local MUSIC_EVENTFINISHED = 4
local i_fullScreen = 0
local MusicDt = nil

local m_playingMusic = nil
require("game/encapsulation/timer")
-- local lastSoundTime = nil

function remove( )
	stopMusic()
	stopSound(musicSound["op_fire"])
	if soundSch then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(soundSch)
        soundSch = nil
    end

    if MusicDt then
		scheduler.remove(MusicDt)
		MusicDt = nil
	end
end

local function removeSoundAndPlay(fileName )
	if MusicDt then
		scheduler.remove(MusicDt)
		MusicDt = nil
	end
	MusicDt = scheduler.create(function ( )
		if MusicDt then
			scheduler.remove(MusicDt)
			MusicDt = nil
		end
		playMusic(fileName)
	end,0.1)
end

function musicStateCallback(state, fileName )
	
	if state == MUSIC_END or state == MUSIC_STOLEN then
		
		if musicPriority[fileName] and musicPriority[fileName] == 0 then
			removeSoundAndPlay(fileName )
		else
			if i_fullScreen > 0 then
				removeSoundAndPlay("UI_bgm1")
			else
				if fileName == "main_bgm1" then
					playMusic("main_bgm2")
				else
					playMusic("main_bgm1")
				end
			end
		end
	end
end

local function registerMusicHandler( )
	CSound:sharedSound():registerScriptHandler(musicStateCallback)
end

function startMusic( )
	local function call( )
        CSound:sharedSound():update()
    end

    require("game/option/setting")
    -- if configBeforeLoad.getPlatFormInfo() ~= kTargetWindows then
    	if not Setting.isMusicClosed() then
	    	CSound:sharedSound():openMusic(true)
	    end

	    if not Setting.isSoundClosed() then
	    	CSound:sharedSound():openSound(true)
	    end

	    CSound:sharedSound():setButtonSound(musicSound["buttom_touch"], "gameSound/G10_output_03",
	    			"new_button_in_normal_state_2.png")
	    CSound:sharedSound():setDelayAndCloseUISound(musicSound["ui_cancel"], 300)
        playMusic("OP_bgm")

        if soundSch then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(soundSch)
            soundSch = nil
        end
        soundSch =cc.Director:getInstance():getScheduler():scheduleScriptFunc(call, 1, false)
    -- end
end

function openMusic(flag )
	CSound:sharedSound():openMusic(flag)
	if flag and m_playingMusic then
		playMusic(m_playingMusic)
	end
end

function openSound(flag )
	CSound:sharedSound():openSound(flag)
end

function openFullScreen( )
	i_fullScreen = i_fullScreen + 1
end

function closeFullScreen( )
	i_fullScreen = i_fullScreen - 1
	if i_fullScreen < 0 then
		i_fullScreen = 0 
	end
end

function setFullScreenZero( )
	i_fullScreen = 0
end

function playMusic(file)
	if not b_isRegister then
		registerMusicHandler()
		b_isRegister = true
	end
	local name = CSound:sharedSound():getCurrenMusicName()
	if not musicPriority[name] or musicPriority[file] < musicPriority[name] then
		stopMusic()
		cc.Director:getInstance():getRunningScene():runAction(animation.sequence({cc.DelayTime:create(0.1), cc.CallFunc:create(function (  )
			CSound:sharedSound():playMusic(1,file,"gameSound/music")
			m_playingMusic = file
		end)}))
	end
end

function playSound(file)
	-- if not lastSoundTime or os.time() - lastSoundTime > 1 then
		CSound:sharedSound():playSound(1,file,"gameSound/G10_output_03")
		-- lastSoundTime = os.time()
	-- end
end

function stopSound(file)
	-- if not lastSoundTime or os.time() - lastSoundTime > 1 then
		CSound:sharedSound():stopSound(file,"gameSound/G10_output_03")
		-- lastSoundTime = os.time()
	-- end
end

function onPause(flag )
	CSound:sharedSound():onPause(flag)
end

function stopMusic( )
	CSound:sharedSound():stopMusic(1)
end

function setVolume( vol )
	CSound:sharedSound():setVolume(vol)
end

function fromOPToEnterGame(dt )
	local pScene = cc.Director:getInstance():getRunningScene()
	if pScene then
		pScene:runAction(animation.sequence({cc.DelayTime:create(dt or 5), cc.CallFunc:create(function (  )
			playMusic("main_bgm1")
		end)}))
	end
end