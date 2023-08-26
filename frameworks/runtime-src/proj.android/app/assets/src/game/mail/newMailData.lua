module("newMailData", package.seeall)
local m_common_inbox_list = nil 	--普通收件列表
local m_system_inbox_list = nil 	--系统邮件列表
local m_outbox_list = nil 			--发件列表
local m_mail_detail_list = nil 		--邮件详情

local m_mail_source = nil 			--0收件箱、1发件箱
local m_mail_type = nil				--0普通邮件、1系统邮件

--发送邮件相关数据
local m_union_member_list = nil

local function sort_ruler(a_mail, b_mail)
	return a_mail.id > b_mail.id
end

--请求发件箱数据
local function requestOutboxMailList()
	Net.send(MAIL_OUTBOX,{})
end

local function organizeOutboxMailInfo(packet)
	local temp_content_info = {}
	temp_content_info["id"] = packet[1]
	temp_content_info["title"] = packet[2]
	temp_content_info["receiver_id"] = packet[3]
	temp_content_info["receiver_name"] = packet[4]
	temp_content_info["send_time"] = packet[5]

	table.insert(m_outbox_list, 1, temp_content_info)
end

local function receiveOutboxMailList(packet)
	-- 1 邮件id 2 邮件标题 3 收件人id 4 收件人名字 5 发送时间
	for k,v in pairs(packet) do
		organizeOutboxMailInfo(v)
	end

	table.sort(m_outbox_list, sort_ruler)

	mailManager.create()
end

--请求收件箱数据
local function requestInboxMailList()
	m_iFirst = true
	Net.send(MAIL_INBOX,{})
end

local function organizeInboxMailInfo(packet)
	local temp_content_info = {}
	temp_content_info["id"] = packet[5]
	temp_content_info["title"] = packet[1]
	temp_content_info["send_time"] = packet[3]
	temp_content_info["readed"] = packet[4]
	temp_content_info["has_attach"] = packet[7]
	temp_content_info["got_attach"] = packet[9]

	if packet[8] == 0 then
		temp_content_info["sender_id"] = packet[6]
		temp_content_info["sender_name"] = packet[2]
		table.insert(m_common_inbox_list, 1, temp_content_info)
	else
		temp_content_info["sender_name"] = languagePack["xitongyoujian"]
		table.insert(m_system_inbox_list, 1, temp_content_info)
	end
end

--接收收件箱数据
local function receiveInboxMailList(packet)
	-- 1 邮件标题 2 发件人名字（空串表示系统发送） 3 发送时间 4 是否已读（1已读，0未读） 5 邮件id
	-- 6 发件人id 7 是否有附件（1有，0没有） 8 邮件类型（0普通邮件、1系统邮件） 9 是否已领取附件（1已领取，0未领取）
	for k,v in pairs(packet) do
		organizeInboxMailInfo(v)
	end

	table.sort(m_common_inbox_list, sort_ruler)
	table.sort(m_system_inbox_list, sort_ruler)

	requestOutboxMailList()
end

function get_mail_list_new_state()
	local common_new_index, system_new_index = 0, 0
	for k,v in pairs(m_common_inbox_list) do
		if v.readed == 0 then
			common_new_index = k
			break
		end
	end

	for k,v in pairs(m_system_inbox_list) do
		if v.readed == 0 then
			system_new_index = k
			break
		else
			if v.has_attach == 1 and v.got_attach == 0 then
				system_new_index = k
				break
			end
		end
	end

	return common_new_index, system_new_index
end

function get_mail_content_in_list(tab_page_num, index)
	if tab_page_num == 1 then
		return m_common_inbox_list[index]
	elseif tab_page_num == 2 then
		return m_system_inbox_list[index]
	elseif tab_page_num == 3 then
		return m_outbox_list[index]
	end
end

function get_cell_nums(tab_page_num)
	if tab_page_num == 1 then
		return #m_common_inbox_list
	elseif tab_page_num == 2 then
		return #m_system_inbox_list
	elseif tab_page_num == 3 then
		return #m_outbox_list
	end
end

--请求领取附件
function requestGetAttachment(mail_id)
	Net.send(MAIL_REWARD,{mail_id})
end

--是否领取成功
local function receiveGetAttachment(package)
	LSound.playSound(musicSound["mail_file"])

	for k,v in pairs(m_system_inbox_list) do
		if v.id == package then
			v.got_attach = 1
			break
		end
	end

	if mailListManager then
		mailListManager.update_selected_cell()
	end

	if mailManager then
		mailManager.update_new_state_show()
	end

	if mailDetailManager then
		mailDetailManager.obtain_attach_success(package)
	end
end

--发送详细邮件信息请求
-- 邮件id；邮件类型（0普通邮件、1系统邮件）；来自收件箱还是发件箱（0收件箱、1发件箱）
local function requestMailDetail(mail_id, mail_type, mail_source)
	Net.send(MAIL_INFO,{mail_id, mail_type, mail_source})
end

-- 返回值： 不带附件时：0邮件id、1正文
--          带附件时： 0邮件id、1正文、2附件、 3弹窗内容
function receiveMailDetail(packet)
	local temp_mail_id = packet[1]
	if not m_mail_detail_list[temp_mail_id] then
		m_mail_detail_list[temp_mail_id] = {}
	end

	m_mail_detail_list[temp_mail_id].text = packet[2]
	m_mail_detail_list[temp_mail_id].attachment = packet[3]
	m_mail_detail_list[temp_mail_id].confirm_content = packet[4]

	mailDetailManager.set_mail_detail_info()
	--[==[
	if m_tInboxAndOutboxMailSort[package[1]] then
		m_tInboxAndOutboxMailSort[package[1]].text = package[2]
		m_tInboxAndOutboxMailSort[package[1]].attachment = package[3]
		m_tInboxAndOutboxMailSort[package[1]].getAttachment = package[4]
		m_tInboxAndOutboxMailSort[package[1]].mailType = package[5]
		MailTextUI.create(package[1])
	end
	--]==]
end

function get_mail_detail_info(mail_id)
	return m_mail_detail_list[mail_id]
end

--点击邮件列表中的邮件时，根据具体情况来确定是否要请求具体详情以及是否要刷新读取状态标示
function is_owned_mail_detail(tab_page_num, index)
	local temp_mail_info = get_mail_content_in_list(tab_page_num, index)
	if m_mail_detail_list[temp_mail_info.id] then
		return true, false
	else
		if tab_page_num == 1 or tab_page_num == 2 then
			if tab_page_num == 1 then
				requestMailDetail(temp_mail_info.id, m_mail_type.common, m_mail_source.receive)
			else
				requestMailDetail(temp_mail_info.id, m_mail_type.system, m_mail_source.receive)
			end
			
			if temp_mail_info.readed == 0 then
				temp_mail_info.readed = 1
				return false, true
			else
				return false, false
			end
		else
			requestMailDetail(temp_mail_info.id, m_mail_type.common, m_mail_source.send)
			return false, false
		end
	end
end

local function requestMailBriefInfo(mail_id, mail_source)
	Net.send(MAIL_BRIEF_INFO_BY_MAILID, {mail_id, mail_source})
end

local function recieveMailSimpleInfo(package)
	local mail_type = package[1]
	local mail_data = package[2]
	if mail_type == 0 then
		organizeInboxMailInfo(mail_data)
		if mail_data[8] == 0 then
			table.sort(m_common_inbox_list, sort_ruler)
			mailListManager.deal_with_add_mail(1)
		else
			table.sort(m_system_inbox_list, sort_ruler)
			mailListManager.deal_with_add_mail(2)
		end

		mailManager.update_new_state_show()
	else
		organizeOutboxMailInfo(mail_data)
		table.sort(m_outbox_list, sort_ruler)
		mailListManager.deal_with_add_mail(3)
	end
end

function deal_with_receive_new_mail(package)
	requestMailBriefInfo(package["id"], m_mail_source.receive)
end

--删除与邮件列表相关的数据
function remove_with_mail_list()
	netObserver.removeObserver(MAIL_INBOX)
	netObserver.removeObserver(MAIL_OUTBOX)
	netObserver.removeObserver(MAIL_INFO)
	netObserver.removeObserver(MAIL_REWARD)
	netObserver.removeObserver(MAIL_BRIEF_INFO_BY_MAILID)

	m_common_inbox_list = nil
	m_system_inbox_list = nil
	m_outbox_list = nil
	m_mail_detail_list = nil

	m_mail_source = nil
	m_mail_type = nil
end

--初始化与邮件列表相关的数据
function create_with_mail_list()
	m_common_inbox_list = {}
	m_system_inbox_list = {}
	m_outbox_list = {}

	m_mail_detail_list = {}

	m_mail_source = {receive = 0, send = 1}
	m_mail_type = {common = 0, system = 1}

	netObserver.addObserver(MAIL_INBOX,receiveInboxMailList)
	netObserver.addObserver(MAIL_OUTBOX,receiveOutboxMailList)
	netObserver.addObserver(MAIL_INFO,receiveMailDetail)
	netObserver.addObserver(MAIL_REWARD,receiveGetAttachment)
	netObserver.addObserver(MAIL_BRIEF_INFO_BY_MAILID, recieveMailSimpleInfo)

	requestInboxMailList()
end


-- 给全同盟发邮件
-- 0:同盟id、1:标题、2:正文
function requestSendUnionMail(unionId,title,text)
	Net.send(MAIL_SEND_UNION_MAIL,{unionId,title,text})
end

--发送邮件
function requestSendMail(title, text, userid, name)
	local iTemp = 0
	if name and name == userData.getUserName() then
		tipsLayer.create(languagePack['bunengfasong']) 
		return
	end
	
	if userid then
		if userid == userData.getUserId() then
			tipsLayer.create(languagePack['bunengfasong']) 
			return
		end
		iTemp = userid
	end
	Net.send(MAIL_SEND_PLAYER_MAIL,{title,text,iTemp,name})
end

local function receiveSendMail(package)
	if type(package) ~= "number" then
		return
	end

	if package == -1 then
		tipsLayer.create(languagePack["notmailblack"])
	else
		tipsLayer.create(languagePack["fasongchenggong"])
		LSound.playSound(musicSound["mail_send"])
		SendMailUI.remove_self()

		if m_mail_source then
			requestMailBriefInfo(package, m_mail_source.send)
		end
	end
end

local function receiveSendUnionMail(package)
	if type(package) ~= "number" then
		return
	end

	if package == -1 then
		-- tipsLayer.create(languagePack["notmailblack"])
		SendMailUI.remove_self()
	else
		tipsLayer.create(languagePack["fasongchenggong"])
		LSound.playSound(musicSound["mail_send"])
		SendMailUI.remove_self()
	end
end
--删除与邮件发送相关数据
function remove_with_send_mail()
	netObserver.removeObserver(MAIL_SEND_PLAYER_MAIL)
	netObserver.removeObserver(MAIL_SEND_UNION_MAIL)
end

--初始化与邮件发送相关数据
function create_with_send_mail()
	netObserver.addObserver(MAIL_SEND_PLAYER_MAIL, receiveSendMail)
	netObserver.addObserver(MAIL_SEND_UNION_MAIL,receiveSendUnionMail)
end

--请求盟友
local function requestUnionMember()
	Net.send(MAIL_SIMPLE_UNION_MEMBER_LIST,{})
end

--接收盟友数据
local function receiveUnionMember(package)
	for i, v in ipairs(package) do
		if v[1] ~= userData.getUserId() then
			if not userData.checkIsInUserBlackList(v[1]) then
				table.insert(m_union_member_list, {userid = v[1],userName = v[2]})
			end
		end
	end

	ReceiverChooseUI.create()
end

function getUnionMember()
	return m_union_member_list
end

--删除与邮件发送盟友相关的数据
function remove_with_union_member()
	netObserver.removeObserver(MAIL_SIMPLE_UNION_MEMBER_LIST)

	m_union_member_list = nil
end

--初始化与邮件发送盟友相关的数据
function create_with_union_member()
	m_union_member_list = {}

	netObserver.addObserver(MAIL_SIMPLE_UNION_MEMBER_LIST, receiveUnionMember)

	requestUnionMember()
end
