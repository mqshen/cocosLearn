module("VoiceMgr", package.seeall)

local VOICE_DIR = CCFileUtils:sharedFileUtils():getWritablePath().."VoiceAmr"

function init( )
	VoiceRecord:sharedVoiceRecordMgr():setplayBeginScriptCallback(playBeginScriptCallback)
	VoiceRecord:sharedVoiceRecordMgr():setplayEndScriptCallback(playEndScriptCallback)
	VoiceRecord:sharedVoiceRecordMgr():setplayErrorScriptCallback(playErrorScriptCallback)
end

function remove( )
	VoiceRecord:sharedVoiceRecordMgr():unplayBeginScriptCallback()
	VoiceRecord:sharedVoiceRecordMgr():unplayEndScriptCallback()
	VoiceRecord:sharedVoiceRecordMgr():unplayErrorScriptCallback()
end

-- 降低音量
function playBeginScriptCallback( )
	if not Setting.isMusicClosed() then
		LSound.setVolume(10)
	end
end

-- 恢复正常音量
function playEndScriptCallback( )
	if not Setting.isMusicClosed() then
		LSound.setVolume(100)
	end
end

function playErrorScriptCallback( )
	-- body
end

function upload_amr_to_server( fileName, callback)
	local fileData = Voice.get_file_content(VOICE_DIR.."/"..fileName)
	if not fileData then return end
	Voice.upload_amr(fileName, fileData, nil, function (md5Key )
		if md5Key then
			if callback then
				callback(fileName, md5Key)
			end
		end
	end)
end

-- key值就是服务器返回或者上传时返回的md5值
-- fileName下载的文件将要保存的命名
function downLoad_amr_from_server(key, fileName, callback)
	-- 检查是否已存在
	if CCFileUtils:sharedFileUtils():fullPathForFilename(fileName) ~= fileName then
		if callback then
			callback(fileName)
		end
	else
		Voice.download_amr(key, nil, function ( packet)
			if packet then
				Voice.save_file_content(VOICE_DIR.."/"..fileName, packet )
				if callback then
					callback(fileName)
				end
			end
		end)
	end
end

-- key值就是服务器返回或者上传时返回的md5值
-- fileName要取得翻译的文件名
function get_translate_from_server( key, fileName, callback )
	Voice.get_translate(key,function (str )
		if callback then
			callback(fileName, str)
		end
	end)
end

-- 返回这次录音的是否成功，ok代表成功，其他代表失败，sdk返回的不要问我为什么
function startRecord(fileName )
	LSound.setVolume(10)
	return VoiceRecord:sharedVoiceRecordMgr():startRecord(fileName)
end

-- 返回这次录音的是否成功，ok代表成功，其他代表失败，sdk返回的不要问我为什么
function stopRecord()
	LSound.setVolume(100)
	return VoiceRecord:sharedVoiceRecordMgr():stopRecord()
end

-- 返回是否能播放成功, ok代表成功，其他代表失败，sdk返回的不要问我为什么,
-- 当返回失败的时候重新下载文件
function playRecord(fileName )
	-- 检查文件是否存在
	if CCFileUtils:sharedFileUtils():fullPathForFilename(fileName) ~= fileName then
		return VoiceRecord:sharedVoiceRecordMgr():startPlay(fileName)
	else
		return "error"
	end
end

function stopPlay( )
	VoiceRecord:sharedVoiceRecordMgr():stopPlay()
end
