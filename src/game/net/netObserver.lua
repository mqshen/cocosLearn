--网络的通知中心和其他函数的代理

local listeners = {}

local function addObserver(name, listener)
	if not listeners[name] then
		listeners[name] = {}
		table.insert(listeners[name], listener)
	end
end

local function removeObserver(name)
	if listeners[name] then
		listeners[name] = nil
	end
end

local function post(name, ...)
	if listeners[name] then
		for i, v in pairs(listeners[name]) do
			v(...)
		end
	end
end


netObserver = {
				addObserver = addObserver,
				removeObserver = removeObserver,
				post = post
}


local listenerArray = {}

local function addSender( name, listener)
	if not listenerArray[name] then
		listenerArray[name] = {}
	end
	table.insert(listenerArray[name], listener)
end

local function removeSender(name)
	if listenerArray[name] then
		listenerArray[name] = nil
	end
end

local function postSender( name, ... )
	if listenerArray[name] then
		for i, v in pairs(listenerArray[name]) do
			v(...)
		end
	end
end

notificationCenter = {
						addSender = addSender,
						removeSender = removeSender,
						postSender = postSender
}