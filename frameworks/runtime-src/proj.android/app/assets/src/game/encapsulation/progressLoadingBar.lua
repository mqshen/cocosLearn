local DEFAULT_TOTAL_FRAME = 10000
local STEP_FRAME = 1000

local UPDATE_TICK_FRAME = 30
local DEFAULT_TOTAL_SEC = 1
ProgressLoadingBar = class()

ProgressLoadingBar.scheduleUpdateHandler = nil
ProgressLoadingBar.scheduleUpdateId = nil
ProgressLoadingBar.totalFrame = 0

ProgressLoadingBar.loadingBar = nil
ProgressLoadingBar.curFrameCount = 0
ProgressLoadingBar.updateFrameCount = 0
ProgressLoadingBar.callback = nil


function ProgressLoadingBar:dispose()	
	self:disposeScheduleUpdate()
	self.loadingBar = nil
	self.curFrameCount = 0
	self.updateFrameCount = 0
	self.callback = nil
end

function ProgressLoadingBar:ctor()
	self.totalFrame = DEFAULT_TOTAL_FRAME
end

function ProgressLoadingBar:create(loadingBarT)
	self.loadingBar = loadingBarT
	self.totalTime = DEFAULT_TOTAL_SEC
end

function ProgressLoadingBar:disposeCallBack()
    self.callback = nil
end
function ProgressLoadingBar:docallback()
	if not self.callback then return end
	if type(self.callback) == "function" then 
		self.callback()
	end
end

function ProgressLoadingBar:setTotalTime(sec)
	self.totalTime = sec
end

function ProgressLoadingBar:setVisible(visible)
    self.loadingBar:setVisible(visible)
end

function ProgressLoadingBar:setPercentIgnoreCallBack(percent)
    self.loadingBar:setPercent(percent)
    self.curFrameCount = math.floor(math.floor(self.loadingBar:getPercent()) * self.totalFrame / 100)
end

function ProgressLoadingBar:setPercent(percent,needEffect,callbackT)
    -- percent = math.floor(percent)
	if percent == self.loadingBar:getPercent() then 
        self.callback = callbackT
		self:docallback()
		return 
	end
	
	if needEffect then 
		self.curFrameCount = math.floor(math.floor(self.loadingBar:getPercent()) * self.totalFrame / 100)
		self.updateFrameCount = math.ceil( percent * self.totalFrame / 100 )
		self:activeScheduleUpdate()
        self.callback = callbackT
	else
		self.loadingBar:setPercent(percent)
        self.callback = callbackT
		self:docallback()
	end
end

function ProgressLoadingBar:getPercent()
	return self.loadingBar:getPercent()
end

function ProgressLoadingBar:updateAdd()
	if not self.loadingBar then return end
	if self.curFrameCount >= self.updateFrameCount 
        or (self.updateFrameCount < (self.curFrameCount + STEP_FRAME) ) then 
		self.curFrameCount = self.updateFrameCount
		self:disposeScheduleUpdate()
		self:docallback()
		return 
	end
	self.curFrameCount = self.curFrameCount + STEP_FRAME
	self.loadingBar:setPercent(math.floor(self.curFrameCount * 100 / self.totalFrame))
end

function ProgressLoadingBar:updateSub()
	if not self.loadingBar then return end
	if self.curFrameCount <= self.updateFrameCount 
        or (self.curFrameCount < (self.updateFrameCount  + STEP_FRAME)) then 
		self.curFrameCount = self.updateFrameCount
		self:disposeScheduleUpdate()
		self:docallback()
		return
	end
	self.curFrameCount = self.curFrameCount - STEP_FRAME
	self.loadingBar:setPercent(math.floor(self.curFrameCount * 100 / self.totalFrame))
end


function ProgressLoadingBar:activeScheduleUpdate()
	self:disposeScheduleUpdate()
	if self.updateFrameCount >= self.curFrameCount then 
		self.scheduleUpdateHandler = function ()
			self:updateAdd()
		end
	else
		self.scheduleUpdateHandler = function ()
			self:updateSub()
		end
	end
	self.curFrameCount = math.floor(math.floor(self.loadingBar:getPercent()) * self.totalFrame / 100)
	self.scheduleUpdateId = scheduler.create(self.scheduleUpdateHandler,self.totalTime/UPDATE_TICK_FRAME)
end

function ProgressLoadingBar:disposeScheduleUpdate()
	if self.scheduleUpdateId then 
		scheduler.remove(self.scheduleUpdateId)
		self.scheduleUpdateId = nil
		self.scheduleUpdateHandler = nil
        self.loadingBar:setPercent(math.floor(self.updateFrameCount * 100 / self.totalFrame))
	end
end
