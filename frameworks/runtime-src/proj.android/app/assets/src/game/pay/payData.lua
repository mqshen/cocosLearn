-- payData.lua
module("PayData", package.seeall)
local payGoodsData = nil
local goodsCount = nil
local yueka = 101
local schedulerHandler = nil
local payAdditionData = {}
local payAdditionHandler = nil
local payWaitHandler = nil
local isInit = nil
local ignore_orderid = nil
local this_round_sended_orderid = nil

local pidForLenovo = {
	[1] = 11061,
	[2] = 11162,
	[3] = 11163,
	[4] = 11164,
	[5] = 11165,
	[6] = 11166,
	[101] = 11167,
}

local function getRealPid( pid )
	if sdkMgr:sharedSkdMgr():getPlatform() == "ios" then
		return "com.netease.stzb."..pid
	else
		if sdkMgr:sharedSkdMgr():getChannel() == "lenovo_open" then
			return pidForLenovo[pid]
		elseif sdkMgr:sharedSkdMgr():getChannel() == "appchina" or sdkMgr:sharedSkdMgr():getChannel() == "coolpad_sdk" then
			if pid == 101 then
				return 7
			else
				return pid
			end
		else
			return pid
		end
	end
end

local function requestAllOrder( )
	if sdkMgr:sharedSkdMgr():getPlatform() == "ios" and isInit then
		schedulerHandler = scheduler.create(function ( )
			sdkMgr:sharedSkdMgr():requestFinishedOrder()
			scheduler.remove(schedulerHandler)
			schedulerHandler = nil
		end,30)
	end
end

local function requestPayOrder( data )
	if #data > 0 then
		-- config.dump(data)
		Net.send(PAY_DEAL_AFTER_PAY_DONE, data)
	end
end

function setAdditionData( data )
	-- local temp_table = {}
			-- temp_table["receipt-data"] = data2
			-- Net.send(PAY_DEAL_AFTER_PAY_DONE, {data, temp_table})
	scheduler.remove(schedulerHandler)
	schedulerHandler = nil
	table.insert(payAdditionData, data)
	if not payWaitHandler then
		payWaitHandler = true
		if payAdditionHandler then
			scheduler.remove(payAdditionHandler)
			payAdditionHandler = nil
		end
		payAdditionHandler = scheduler.create(function ( )
			if #payAdditionData > 0 then
				if not this_round_sended_orderid[payAdditionData[1][1]] then
					local temp_paydata = {}
					this_round_sended_orderid[payAdditionData[1][1]] = 1
					table.insert(temp_paydata, payAdditionData[1])
					requestPayOrder( temp_paydata )
					table.remove(payAdditionData, 1)
				end
			else
				if payAdditionHandler then
					scheduler.remove(payAdditionHandler)
					payAdditionHandler = nil
				end
				this_round_sended_orderid = {}
				payWaitHandler = nil
				requestAllOrder( )
			end
		end,2)
	end
end

function init( )
	isInit = true
	this_round_sended_orderid = {}
	ignore_orderid = {}
	netObserver.addObserver(PAY_GEN_ORDER_INFO,reciveOrder)
	netObserver.addObserver(PAY_DEAL_AFTER_PAY_DONE, receivePayDone)
	--游戏登录后每隔30秒检测是否有未验证的付费订单
	requestAllOrder()

	--通知客户端订单支付成功，可以删掉本地凭条
	-- netObserver.addObserver(NOTIFY_PAY_ORDER_SUCCESS, function (package )
	-- 	sdkMgr:sharedSkdMgr():removeCheckedOrders(package)
	-- end)

	--通知客户端这个订单不属于该玩家，不要再发送给服务器验证
	netObserver.addObserver(NOTIFY_PAY_ORDER_NOT_EXIST, function (packet )
		-- sdkMgr:sharedSkdMgr():removeCheckedOrders(package)
		ignore_orderid[packet] = 1
	end)
end

function remove(  )
	isInit = nil
	goodsCount = nil
	payWaitHandler = nil
	ignore_orderid = nil
	netObserver.removeObserver(PAY_GEN_ORDER_INFO)
	netObserver.removeObserver(PAY_DEAL_AFTER_PAY_DONE)
	-- netObserver.removeObserver(NOTIFY_PAY_ORDER_SUCCESS)
	netObserver.removeObserver(NOTIFY_PAY_ORDER_NOT_EXIST)
	scheduler.remove(schedulerHandler)
	schedulerHandler = nil
	payAdditionData = {}
	scheduler.remove(payAdditionHandler)
	payAdditionHandler = nil
end

function removeUIData(  )
	payGoodsData = nil
	UIUpdateManager.remove_prop_update(dbTableDesList.user_stuff.name, dataChangeType.update, PayUI.reloadData)
	UIUpdateManager.remove_prop_update(dbTableDesList.user_stuff.name, dataChangeType.add, PayUI.reloadData)
	UIUpdateManager.remove_prop_update(dbTableDesList.user_stuff.name, dataChangeType.remove, PayUI.reloadData)
end

function getYueka(  )
	return yueka
end

function initUIData(  )
	UIUpdateManager.add_prop_update(dbTableDesList.user_stuff.name, dataChangeType.update, PayUI.reloadData)
	UIUpdateManager.add_prop_update(dbTableDesList.user_stuff.name, dataChangeType.add, PayUI.reloadData)
	UIUpdateManager.add_prop_update(dbTableDesList.user_stuff.name, dataChangeType.remove, PayUI.reloadData)
	initData()
end

function initData(  )
	payGoodsData = {}
	goodsCount = 0

	local temp_recommend = {}
	local temp_normal = {}

	local user_stuff = allTableData[dbTableDesList.user_stuff.name][userData.getUserId()]
    local goods = stringFunc.anlayerMsg(user_stuff.goods_bought)
    local temp_goods = {}
    -- config.dump(goods)
    for i, v in pairs(goods) do
    	temp_goods[v[1]] = v[2]
    end
	for i, v in pairs(Tb_cfg_goods) do
		goodsCount = goodsCount + 1
		if v.good_id ~= yueka then
			if v.first_bonus~= 0 and (not temp_goods[v.good_id] or  temp_goods[v.good_id] == 0) then
				table.insert(temp_recommend, v)
			else
				table.insert(temp_normal, v)
			end
		end
	end

	table.sort( temp_recommend, function (a,b )
		return a.rmb > b.rmb
	end )

	table.sort( temp_normal, function (a,b )
		return a.rmb > b.rmb
	end )

	for i, v in ipairs(temp_recommend) do
		table.insert(payGoodsData,v)
	end

	for i, v in ipairs(temp_normal) do
		table.insert(payGoodsData,v)
	end

	table.insert(payGoodsData,1,Tb_cfg_goods[yueka])

	
	if goodsCount%2 == 0 then
		goodsCount = goodsCount/2
	else
		goodsCount = math.floor(goodsCount/2)+1
	end
end

function getGoodsDataByIndex(index)
	return payGoodsData[index]
end

function getGoodsCount( )
	return goodsCount
end

function reciveOrder( packet )
	-- [1,{"goodscount":1,"goodsid":1,"sn":"aebvk5jie4aagpow-sandbox-o-150608132911", 有可能还有一个透传参数}]
	-- 1成功 0失败
	if packet[1] == 1 then
		local etc = ""
		if sdkMgr:sharedSkdMgr():getChannel() == "nearme_vivo" then
			if packet[2].accessKey and packet[2].orderNumber then
				etc = packet[2].orderNumber.."|"..packet[2].accessKey
			end
		end

		if sdkMgr:sharedSkdMgr():getChannel() == "gionee" then
			if packet[2].submit_time then
				etc = packet[2].submit_time
			end
		end
		payProduct(packet[2].goodsid, packet[2].sn, Tb_cfg_goods[packet[2].goodsid].description, etc, packet[2].goodscount)
	else
	end
end

function receivePayDone( packet )
	for i, v in pairs(packet) do
		sdkMgr:sharedSkdMgr():removeCheckedOrders(v)
	end
end

function regProduct( pId, pName, pPrice, eRatio)
	if not eRatio then
		eRatio = 1
	end

	local sdkName =sdkMgr:sharedSkdMgr():getChannel()
	if sdkName == "meizu_sdk" or sdkName== "sogou" then
		eRatio = 10
	end

	local tempPid = getRealPid( pId )

	sdkMgr:sharedSkdMgr():regProduct(tostring(tempPid), pName, pPrice/100, eRatio)
	requestOrder(pId,1)
end

function requestOrder(pid, count )
	if not count then
		count = 1
	end

	local tempPid = getRealPid( pid )

	Net.send(PAY_GEN_ORDER_INFO,{sdkMgr:sharedSkdMgr():getChannel(), 
					sdkMgr:sharedSkdMgr():getPayChannelByPid(tostring(tempPid)), 
					sdkMgr:sharedSkdMgr():getAppChannel(),
					sdkMgr:sharedSkdMgr():getPlatform(), 
					sdkMgr:sharedSkdMgr():getUDID(), 
					configBeforeLoad:getAid() or 1, 
					sdkMgr:sharedSkdMgr():getDeviceInfo(), pid, count})

end

function payProduct(pId, orderid, desc, etc, productCount)
	-- SdkMgr.getInst().setUserInfo(ConstProp.USERINFO_BALANCE, "100");  // 玩家游戏内虚拟货币余额
 --  SdkMgr.getInst().setUserInfo(ConstProp.USERINFO_VIP, "1");  // vip等级
 --  SdkMgr.getInst().setUserInfo(ConstProp.USERINFO_GRADE, "10");  // 角色等级
 --  SdkMgr.getInst().setUserInfo(ConstProp.USERINFO_ORG, "帮派名");  // 工会，帮派
 --  SdkMgr.getInst().setUserInfo(ConstProp.USERINFO_NAME, "角色名");  // 角色名称
 --  SdkMgr.getInst().setUserInfo(ConstProp.USERINFO_HOSTNAME, "服务器名"); // 所在服务器
 	loadingLayer.create(3,true,true)
	sdkMgr:sharedSkdMgr():setUserInfo("USERINFO_UID",userData.getUserHelpId())
	sdkMgr:sharedSkdMgr():setUserInfo("USERINFO_BALANCE",userData.getYuanbao())
	sdkMgr:sharedSkdMgr():setUserInfo("USERINFO_VIP",userData.getUserName())
	sdkMgr:sharedSkdMgr():setUserInfo("USERINFO_ORG",userData.getUnion_name() or "")
	local sdkName =sdkMgr:sharedSkdMgr():getChannel()
	local id = loginData.getLastLoginServerId() or ""
	if sdkName == "pps" then
		sdkMgr:sharedSkdMgr():setUserInfo("USERINFO_HOSTID","ppsmobile_s"..id)
	else
		sdkMgr:sharedSkdMgr():setUserInfo("USERINFO_HOSTID",id)
	end
	-- sdkMgr:sharedSkdMgr():setUserInfo("USERINFO_HOSTID",loginData.getLastLoginServerId() or "")
	sdkMgr:sharedSkdMgr():setPropStr("currency",languagePack['jin'] )

	if sdkName == "sougou" then
		sdkMgr:sharedSkdMgr():setPropInt("FLOAT_BTN_POS", 2)
	end

	sdkMgr:sharedSkdMgr():ntUpLoadUserInfo()
	local tempPid = getRealPid( pId )
	if desc and string.len(desc) == 0 then
		if Tb_cfg_goods[pId] then
			desc = Tb_cfg_goods[pId].name
		else
			desc = orderid
		end
	end

	if sdkName == "anzhi" or sdkName == "sina_sdk" then
		desc = Tb_cfg_goods[pId].name
	end

	local result = sdkMgr:sharedSkdMgr():payProduct(tostring(tempPid), orderid, desc, etc, productCount)
	if result == 0 then
		tipsLayer.create(languageBeforeLogin["chongxindenglu"])
	end
end