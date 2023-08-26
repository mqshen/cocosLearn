--判断是否是在野，加载不同的ui
module("UnionUIJudge", package.seeall)
--union_name 或者union_id
function create(union )
	local union_ = nil
	if type(union) == "string" and union == "" then
		union_ = 0
	else
		union_ = union
	end
	
	if union_ == 0 then
		require("game/union/NoUnionTipsUI")
		UnionCreateMainUI.create()
		local time = CCUserDefault:sharedUserDefault():getStringForKey("openUnionTime")
		if time ~=os.date( "%d",os.time()) then
			CCUserDefault:sharedUserDefault():setStringForKey("openUnionTime", os.date( "%d",os.time()))
			NoUnionTipsUI.create()
		end
	else
		UnionMainUI.create(union_)
	end
end