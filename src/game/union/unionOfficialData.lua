module("UnionOfficialData",package.seeall)

local UnionOfficialInvite = require("game/union/unionOfficialInvite")

function requestUnionOfficialList()
    Net.send(UNION_OFFICIAL_LIST,{})
end

function responeUnionOfficialList(package)
    UnionOfficialManagement.updateData(package,1)
end



function requestUnionLeaderDemise(targetUserID)
    Net.send(UNION_DEMISE_LEADER,{targetUserID})
end
function responeUnionLeaderDemise(package)
    UnionOfficialManagement.requestDataFromServer(1)
end


function requestUnionLeaderCancelDemise()
    Net.send(UNION_CANCEL_DEMISS,{})
end
function responeUnionLeaderCancelDemise()
    UnionOfficialManagement.requestDataFromServer(1)
end



function requestUnionSimpleMemberList(rtype)
    Net.send(UNION_SIMPLE_MEMBER_LIST,{rtype})
end
function responeUnionSimpleMemberList(package)
    UnionOfficialManagement.updateAppointList(package)
end


function requestUnionLeaderAppointOfficial(userID,positionType,positionNum)
    Net.send(UNION_APPOINT_OFFICIAL,{userID,positionType,positionNum})
end

function responeUnionLeaderAppointOfficial()
    UnionOfficialManagement.requestDataFromServer(1)
end


function requestUnionLeaderDesposetOfficial(userID)
    Net.send(UNION_DEPOSE_OFFICIAL,{userID})
end

function responeUnionLeaderDesposeOfficial()
    UnionOfficialManagement.requestDataFromServer(1)
end


function requestUnionDeputyLeaderResign()
    Net.send(UNION_GIVE_UP_OFFICIAL,{})
end

function responeUnionDeputyLeaderResign()
    -- UnionOfficialManagement.requestDataFromServer(1)
    UnionOfficialManagement.autoAlginBtns()
end



function requestUnionApplyList()
    Net.send(UNION_APPLICANT_LIST,{})
end

function responeUnionApplyList(package)
    UnionOfficialManagement.updateData(package,2)
end


function requestSwitchAppllyState()
    Net.send(UNION_SWITCH_APPLY_STATE,{})
end

function responeSwitchAppllyState()
    UnionOfficialManagement.setViewIndx(2)
end

function requestHandlingAplly(applyID,state)
    Net.send(UNION_DEAL_APPLICATION,{{applyID},state})
end

function responeHandlingAplly(package)
    if not package then return end
    local userIdList = package[1]
    local handlerFlag = package[2]
    UnionOfficialManagement.responeHandlerApplyItem(handlerFlag)
end



function requestNearbyUserList()
    Net.send(UNION_NEARBY_PLAYER_LIST,{})
end
function responeNearbyUserList(package)
    UnionOfficialManagement.updateData(package,3)
end


function requestInviteUserByID(userID)
    Net.send(N_INVITE,{userID})
end
    
function responeInviteUserByID(userID)
    UnionOfficialInvite.refreshCell(userID)
    -- UnionOfficialManagement.requestDataFromServer(3)
end


function requestInviteUserByName(userName)
    Net.send(UNION_INVITE_DIRECTLY,{userName})
end

function responeInviteUserByName()
    UnionOfficialManagement.requestDataFromServer(3)
end

function remove()
    netObserver.removeObserver(UNION_OFFICIAL_LIST)
    netObserver.removeObserver(UNION_DEMISE_LEADER)
    netObserver.removeObserver(UNION_CANCEL_DEMISS)
    netObserver.removeObserver(UNION_SIMPLE_MEMBER_LIST)
    netObserver.removeObserver(UNION_APPOINT_OFFICIAL)
    netObserver.removeObserver(UNION_DEPOSE_OFFICIAL)
    netObserver.removeObserver(UNION_APPLICANT_LIST)
    netObserver.removeObserver(UNION_SWITCH_APPLY_STATE)
    netObserver.removeObserver(UNION_DEAL_APPLICATION)
    netObserver.removeObserver(UNION_NEARBY_PLAYER_LIST)
    netObserver.removeObserver(N_INVITE)
    netObserver.removeObserver(UNION_INVITE_DIRECTLY)
end


function initData()
    
	netObserver.addObserver(UNION_OFFICIAL_LIST,responeUnionOfficialList)

    
	netObserver.addObserver(UNION_DEMISE_LEADER,responeUnionLeaderDemise)

    
	netObserver.addObserver(UNION_CANCEL_DEMISS,responeUnionLeaderCancelDemise)

    
	netObserver.addObserver(UNION_SIMPLE_MEMBER_LIST,responeUnionSimpleMemberList)
    
    
	netObserver.addObserver(UNION_APPOINT_OFFICIAL,responeUnionLeaderAppointOfficial)

    
	netObserver.addObserver(UNION_DEPOSE_OFFICIAL,responeUnionLeaderDesposeOfficial)

    
	netObserver.addObserver(UNION_GIVE_UP_OFFICIAL,responeUnionDeputyLeaderResign)

    
    netObserver.addObserver(UNION_APPLICANT_LIST,responeUnionApplyList)

    
    netObserver.addObserver(UNION_SWITCH_APPLY_STATE,responeSwitchAppllyState)
      
    
    netObserver.addObserver(UNION_DEAL_APPLICATION,responeHandlingAplly)

    
    netObserver.addObserver(UNION_NEARBY_PLAYER_LIST,responeNearbyUserList)
    

    netObserver.addObserver(N_INVITE,responeInviteUserByID)
    
    
    netObserver.addObserver(UNION_INVITE_DIRECTLY,responeInviteUserByName)
    
    

end




