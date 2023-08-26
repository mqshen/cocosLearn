L_Userdefault=class()
function L_Userdefault:ctor()
	self.userdefault = cc.UserDefault:getInstance()
end

function L_Userdefault:hasUserHelpId( )
	if userData then
		return userData.getUserHelpId() or ""
	else
		return ""
	end
end

function L_Userdefault:sharedUserDefault()
	return self
end

function L_Userdefault:getStringForKey(pKey, noUid)
	if noUid then
		return self.userdefault:getStringForKey( pKey)
	else
		return self.userdefault:getStringForKey( self.hasUserHelpId( )..pKey)
	end
end

function L_Userdefault:getBoolForKey(pKey,noUid)
	if noUid then
		return self.userdefault:getBoolForKey( pKey)
	else
		return self.userdefault:getBoolForKey( self.hasUserHelpId( )..pKey)
	end
end

function L_Userdefault:getIntegerForKey(pKey)
	return self.userdefault:getIntegerForKey( self.hasUserHelpId( )..pKey)
end

function L_Userdefault:getFloatForKey(pKey)
	return self.userdefault:getFloatForKey( self.hasUserHelpId( )..pKey)
end

function L_Userdefault:getDoubleForKey(pKey)
	return self.userdefault:getDoubleForKey( self.hasUserHelpId( )..pKey)
end

function L_Userdefault:setBoolForKey(pKey, value,noUid)
	if noUid then
		self.userdefault:setBoolForKey( pKey, value)
	else
		self.userdefault:setBoolForKey( self.hasUserHelpId( )..pKey, value)
	end
end

function L_Userdefault:setIntegerForKey(pKey, value)
	self.userdefault:setIntegerForKey( self.hasUserHelpId( )..pKey, value)
end

function L_Userdefault:setFloatForKey(pKey, value)
	self.userdefault:setFloatForKey( self.hasUserHelpId( )..pKey, value)
end

function L_Userdefault:setDoubleForKey(pKey, value)
	self.userdefault:setDoubleForKey( self.hasUserHelpId( )..pKey, value)
end

function L_Userdefault:setStringForKey(pKey, value, noUid)
	if noUid then
		self.userdefault:setStringForKey( pKey, value)
	else
		self.userdefault:setStringForKey( self.hasUserHelpId( )..pKey, value)
	end
end

CCUserDefault = L_Userdefault.new()
