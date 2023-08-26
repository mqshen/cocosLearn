module("userAgree", package.seeall)
local path = CCFileUtils:sharedFileUtils():getWritablePath()
function create(fileName )
	local file = io.open(path..fileName, "r")
	if file then
		-- rtn = file:read("*a")
		-- file:close()
		local data = {}
		local mabi = 0
		for line in file:lines() do
			line = line.."\n"
			mabi = mabi + 1
			if not string.find(line, "\n") and not string.find(line, "\r") then
				-- line = line.."\n"
			end
			if mabi%15 == 1 then
				table.insert(data, line )
			else
				data[#data] = data[#data]..line
			end
		end
		file:close()

		-- 必须是wb，不然在windows下会自动加入\r,导致在手机上显示出错
		local new_file = io.open(path.."VoiceAmr/agreement.lua","wb")
		new_file:write("userAgreementText = {\n")
		for i, v in ipairs(data) do
			new_file:write("["..i.."]=[["..v.."]],\n")
		end
		new_file:write("}")
		new_file:close()
		print(">>>>>>>>>>>>>>>>>>>>write end")
	end

end
