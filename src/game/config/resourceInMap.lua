--资源数据
local numTable = {91,92,93,94,81,82,83,84,71,72,73,74,61,62,63,64,51,52,53,54,41,42,43,44,31,32,33,34,
					22,23,24,25,11,12}
local des = {"a","b", "c", "d", "e", "f", "g","h","i","j","k","l","m","n","o","p","q","r","s","t","u",
				"v","w","x","y","z","A","B","C","D","E","F","G","H"}


local temp = {}

for i,v in ipairs(des) do
	temp[v] = numTable[i]
end

local function resourceLevel(x, y )
	return temp[string.sub(resourcesInMap,(x-1)*1501+y, (x-1)*1501+y)]
end

resourceData = {
					resourceLevel = resourceLevel
}