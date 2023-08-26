module("Voice", package.seeall)
-- local api_key = "xxxxxxxxxxxxxxxx"
-- local secret_key = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
VoiceRecord:sharedVoiceRecordMgr():createDir("VoiceAmr")
local VOICE_DIR = CCFileUtils:sharedFileUtils():getWritablePath().."VoiceAmr"
local UPLOAD_USER_AGENT = "g10"
local boundary = "----------ThIs_Is_tHe_bouNdaRY_$"

local UPLOAD_HOST = "http://voice.x.netease.com:8020"
local UPLOAD_URL = "/g10/upload?md5=%s&host=%s&tousers=%s&usernum=%s"
local TRANSLATION_URL = "/g10/get_translation?key=%s"
local GETFILE_URL = "/g10/getfile?key=%s&host=%s&usernum=%s"


local function get_http_result(httpbuff)
	local data_start_pos = string.find(httpbuff, "\n")
	if not data_start_pos then return nil end
	local code = string.sub(httpbuff, 1, data_start_pos - 1)
	if not code then return nil end
	if code ~= "0" then return nil end
	local data = string.sub(httpbuff, data_start_pos + 1, #httpbuff)
	return data
end

function get_file_content(path)
	local rtn = nil
	local file = io.open(path, "rb")
	if file then
		rtn = file:read("*a")
		file:close()
	end
	return rtn
end

function is_file_exist( path )
	if not io.open(path, "rb") then
		return false
	else
		return true
	end
end

function save_file_content(path, content)
	local rtn = nil
	local file = io.open(path, "wb")
	if file then
		rtn = file:write(content)
		file:flush()
		file:close()
	end
	return rtn
end

local function http_request(data)
	loadingLayer.create()
	local request = CCLuaHttpRequest:create()
	request:setUrl(data.host..data.path)
	print("http_reques, path:"..data.host..data.path)
	request:setRequestType(data.reques_type)
	if data.reques_type == CCHttpRequest.kHttpPost then
		request:setRequestData(data.content, string.len(data.content))
		request:setHeaders("Content-Type: multipart/form-data; boundary="..boundary)
		request:setHeaders("Expect:")
	elseif data.reques_type == CCHttpRequest.kHttpPostFile then
		data.content = ""
		request:setFileData(data.content, string.len(data.content), data.upload)
		request:setHeaders("Expect:")
	end
	request:setHeaders(string.format("User-Agent: %s", UPLOAD_USER_AGENT))
	request:setResponseScriptCallback(data.callback)
	CCHttpClient:getInstance():send(request)
	request:release()
end

local function http_callback(request, result, body, header, status, errors, callback)
	loadingLayer.remove()
	if result then
		local data = get_http_result(body)
		if data then
			if callback then
				callback(data)
			end
			return
		else
			if callback then
				callback(nil)
			end
		end
	else
		print("http_callback error.")
		print("body: "..body)
		print("header: "..header)
		print("status: "..status)
		print("errors: "..errors)
		if callback then
			callback(nil)
		end
	end

end

-- 如果上传成功，返回key callback的参数是key,否则是nil
-- touser 是id，不是id@host
function upload_amr(voice_file, voice_data, channel, callback)
	-- html post µÄ multipart/form-data ¸ñÊ½¾ÍÊÇÕâÑù£¬²»ÓÃ¾À½á
	local function encode_multipart_form_data()
		local crlf = "\r\n"
		local ret = ""
		ret = ret.."--"..boundary..crlf
		ret = ret.."Content-Type: audio/amr"..crlf
		ret = ret..crlf
		ret = ret..voice_data..crlf
		ret = ret.."--"..boundary.."--"..crlf..crlf
		return ret
	end

	-- 一般不定义，这个是定义获取语音的权限，如果touser = _1_表示所有人都可以获取， _2_表示只有user是2的玩家才能获取
	local touser = "_"..(channel or "1").."_" -- ÆµµÀ
	-- touser = "_1_" -- ÆµµÀ
	local content = encode_multipart_form_data()
	local amr_md5 = VoiceRecord:sharedVoiceRecordMgr():md5Encode(voice_data, string.len(voice_data))--MD5.md5(voice_data)
	local _,_,_,_,hostnum = loginData.getCacheUserInfo() --CLIENT:get_server_info().id or 0
	local usernum = userData.getUserId()--XYSCENE.hero:get_id()
	-- ·þÎñÆ÷²»Ö§³Ö£¬ÈÃÎÒÃÇ×ÔÐÐ½â¾ö
	if not usernum then 
		usernum = "123" 
	end
	local data = {
		upload = voice_file,
		content = content,
		host = UPLOAD_HOST,
		-- reques_type = CCHttpRequest.kHttpPostFile,
		reques_type = CCHttpRequest.kHttpPost,
		path = string.format(UPLOAD_URL, amr_md5, hostnum, touser, usernum)
	}
	local function upload_callback(request, result, body, header, status, errors)
		http_callback(request, result, body, header, status, errors, callback)
	end
	data.expect = true
	data.callback = upload_callback
	http_request(data)
end

--------------------------------------------------------------------------------

-- ·­Òë
--------------------------------------------------------------------------------
--获得翻译结果，返回的翻译结果或者nil
function get_translate(key, callback)
	local function translate_callback(request, result, body, header, status, errors)
		http_callback(request, result, body, header, status, errors, callback)
	end
	local data = {
		host = UPLOAD_HOST,
		reques_type = CCHttpRequest.kHttpGet,
		path = string.format(TRANSLATION_URL, key),
		callback = translate_callback,
	}
	http_request(data)
end

-- 下载amr文件，返回的是amr的文件内容或者nil
function download_amr(key, channel, callback)
	local function download_callback(request, result, body, header, status, errors)
		http_callback(request, result, body, header, status, errors, callback)
	end
	local _,_,_,_,hostnum = loginData.getCacheUserInfo()--CLIENT:get_server_info().id or 0
	local data = {
		host = UPLOAD_HOST,
		reques_type = CCHttpRequest.kHttpGet,
		path = string.format(GETFILE_URL, key, hostnum, userData.getUserId()),
		callback = download_callback,
	}
	http_request(data)
end

