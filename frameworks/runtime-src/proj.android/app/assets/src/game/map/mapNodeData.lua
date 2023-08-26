module("MapNodeData", package.seeall)

--地表的底层node数据
local tSufaceNode = {}

--建筑的node数据
local tBuildingNode = {}

-- 建筑中废墟，分城建造中，要塞建造中, 新手阶段的地表(贼兵，栅栏什么的)等图片的node
local tBetweenMountainNode = {}

--山脉那层node的数据
local tMountainNode = {}

--水的边缘那层上面的node
local tWaterEdgeNode = {}

-- 沙地边缘的node
local tSandEdgeNode = {}

--资源地的那层的node
local tResourcesNode = {}

--战争迷雾那层的node
local tFogNode = {}

--水的那层的node
local tWaterNode = {}

--显示出来的草地那层
local tGrassNode = {}

--援军的那层node
local tYuanjunNode = {}

--山寨，关卡跟山的相接那部分node
local tAdditionWallNode = {}

--丘陵的那层
local tQiulingNode = {}

--扩建那层
local tExpandNode = {}

-- 屯田的那层
local tFarmingNode = {}

--五级地动画
local tLevel5AnimationNode = {}


-- 练兵的那层
local tTrainingNode = {}
function remove( )
	tLevel5AnimationNode = {}
	tSufaceNode = {}
	tBuildingNode = {}
	tMountainNode = {}
	tWaterEdgeNode = {}
	tResourcesNode = {}
	tFogNode = {}
	tWaterNode = {}
	tGrassNode = {}
	tYuanjunNode = {}
	tAdditionWallNode = {}
	tQiulingNode = {}
	tExpandNode = {}
	tSandEdgeNode = {}
	tBetweenMountainNode = {}
	tFarmingNode = {}
	tTrainingNode = {}
end

--获取最底层的地表数据
function addSurfaceNode(node, tag, name )
	tSufaceNode[tag] = {node, name}
end

function removeSurfaceNode( tag )
	if tSufaceNode[tag] then
		MapSpriteManage.pushSprite(mapElement.FOG, tSufaceNode[tag][2], tSufaceNode[tag][1] )
	end
	tSufaceNode[tag] = nil

	
end

function removeAllSurfaceNode( )
	for i, v in pairs(tSufaceNode) do
		MapSpriteManage.pushSprite(mapElement.FOG, v[2], v[1])
	end
	tSufaceNode = {}
	
end

function getSurfaceNode( )
	return tSufaceNode
end
--------------------------------------------------------------------------------
--城市那层资源的接口
function addBuildingNode(node, tag, name )
	tBuildingNode[tag] = {node,name}
end

function removeBuildingNode( tag )
	if tBuildingNode[tag] then
		tBuildingNode[tag][1]:removeAllChildrenWithCleanup(true)
		MapSpriteManage.pushSprite(mapElement.BUILDING, tBuildingNode[tag][2], tBuildingNode[tag][1])
	end
	tBuildingNode[tag] = nil
end

function removeAllBuildingNode( )
	for i, v in pairs(tBuildingNode) do
		v[1]:removeAllChildrenWithCleanup(true)
		MapSpriteManage.pushSprite(mapElement.BUILDING, v[2], v[1])
	end
	tBuildingNode = {}
end

function getBuildingNode( )
	return tBuildingNode
end

-------------------------------------------------------------------------------
--建筑中废墟，分城建造中，要塞建造中, 新手阶段的地表(贼兵，栅栏什么的)等图片的node
function addBetweenMountainNode(node, tag, name )
	tBetweenMountainNode[tag] = {node,name}
end

function removeBetweenMountainNode( tag )
	if tBetweenMountainNode[tag] then
		MapSpriteManage.pushSprite(mapElement.BETWEENNODE, tBetweenMountainNode[tag][2],tBetweenMountainNode[tag][1])
	end
	tBetweenMountainNode[tag] = nil
end

function removeAllBetweenMountainNode( )
	for i, v in pairs(tBetweenMountainNode) do
		MapSpriteManage.pushSprite(mapElement.BETWEENNODE, v[2],v[1])
	end
	tBetweenMountainNode = {}
end

function getBetweenMountainNode( )
	return tBetweenMountainNode
end

-------------------------------------------------------------------------------
--山脉那层的接口
function addMountainNode(node, tag, name )
	tMountainNode[tag] = {node,name}
end

function removeMountainNode( tag )
	if tMountainNode[tag] then
		tMountainNode[tag][1]:removeAllChildrenWithCleanup(true)
		MapSpriteManage.pushSprite(mapElement.MOUNTAIN, tMountainNode[tag][2], tMountainNode[tag][1])
	end
	tMountainNode[tag] = nil
end

function removeAllMountainNode( )
	for i, v in pairs(tMountainNode) do
		v[1]:removeAllChildrenWithCleanup(true)
		MapSpriteManage.pushSprite(mapElement.MOUNTAIN, v[2], v[1])
	end
	tMountainNode = {}
end

function getMountainNode( )
	return tMountainNode
end


-----------------------------------------------------------------------------------
--水的边缘和沙地的边缘那层
function addWaterEdgeNode(node, tag, name )
	tWaterEdgeNode[tag] = {node, name}
end

function removeWaterEdgeNode( tag )
	if tWaterEdgeNode[tag] then
		MapSpriteManage.pushSprite(mapElement.WATEREAGE, tWaterEdgeNode[tag][2], tWaterEdgeNode[tag][1])
	end
	tWaterEdgeNode[tag] = nil
end

function removeAllWaterEdgeNode( )
	for i, v in pairs(tWaterEdgeNode) do
		MapSpriteManage.pushSprite(mapElement.WATEREAGE, v[2], v[1])
	end
	tWaterEdgeNode = {}
end

function getWaterEdgeNode( )
	return tWaterEdgeNode
end

-----------------------------------------------------------------------------------
--沙地的边缘那层
function addSandEdgeNode(node, tag,name )
	tSandEdgeNode[tag] = {node,name}
end

function removeSandEdgeNode( tag )
	if tSandEdgeNode[tag] then
		MapSpriteManage.pushSprite(mapElement.SANDEAGE, tSandEdgeNode[tag][2], tSandEdgeNode[tag][1])
	end
	tSandEdgeNode[tag] = nil
end

function removeAllSandEdgeNode( )
	for i, v in pairs(tSandEdgeNode) do
		MapSpriteManage.pushSprite(mapElement.SANDEAGE, v[2], v[1])
	end
	tSandEdgeNode = {}
end

function getSandEdgeNode( )
	return tSandEdgeNode
end


-----------------------------------------------------------------------------------
--资源地的那层node接口
function addResourceNode(node, tag, name )
	tResourcesNode[tag] = {node,name}
end

function removeResourceNode( tag )
	if tResourcesNode[tag] then
		tResourcesNode[tag][1]:removeAllChildrenWithCleanup(true)
		MapSpriteManage.pushSprite(mapElement.RES, tResourcesNode[tag][2], tResourcesNode[tag][1])
	end
	tResourcesNode[tag] = nil
	local tagwid = mapData.getRealWid(tag )
	local tagX = math.floor(tagwid/10000)+1
	local tagY = tagX*10000-tagwid
	removeLevel5AnimationNode(tagX*10000+tagY)
end

function removeAllResourceNode( )
	for i, v in pairs(tResourcesNode) do
		v[1]:removeAllChildrenWithCleanup(true)
		MapSpriteManage.pushSprite(mapElement.RES, v[2], v[1])
	end
	tResourcesNode = {}
	removeAllLevel5AnimationNode()
end

function getResourceNode( )
	return tResourcesNode
end

-----------------------------------------------------------------------------------
--战争迷雾的那层node接口
function addFogNode(node, tag,name )
	tFogNode[tag] = {node,name}
end

function removeFogNode( tag )
	if tFogNode[tag] then
		MapSpriteManage.pushSprite(mapElement.FOGEAGE, tFogNode[tag][2], tFogNode[tag][1] )
	end
	tFogNode[tag] = nil
end

function removeAllFogNode( )
	for i, v in pairs(tFogNode) do
		-- v:removeFromParentAndCleanup(true)
		MapSpriteManage.pushSprite(mapElement.FOGEAGE, v[2], v[1] )
	end
	tFogNode = {}
end

function getFogNode( )
	return tFogNode
end

-----------------------------------------------------------------------------------
--水的那层node接口
function addWaterNode(node, tag, name )
	tWaterNode[tag] = {node,name}
end

function removeWaterNode( tag )
	if tWaterNode[tag] then
		MapSpriteManage.pushSprite(mapElement.WATER, tWaterNode[tag][2], tWaterNode[tag][1] )
	end
	tWaterNode[tag] = nil
end

function removeAllWaterNode( )
	for i, v in pairs(tWaterNode) do
		MapSpriteManage.pushSprite(mapElement.WATER, v[2], v[1])
	end
	tWaterNode = {}
end

function getWaterNode( )
	return tWaterNode
end


-----------------------------------------------------------------------------------
--显示出来的草地那层node接口
function addGrassNode(node, tag,name )
	tGrassNode[tag] = {node,name}
end

function removeGrassNode( tag )
	if tGrassNode[tag] then
		MapSpriteManage.pushSprite(mapElement.GRASS, tGrassNode[tag][2], tGrassNode[tag][1])
	end
	tGrassNode[tag] = nil
end

function removeAllGrassNode( )
	for i, v in pairs(tGrassNode) do
		MapSpriteManage.pushSprite(mapElement.GRASS, v[2], v[1])
	end
	tGrassNode = {}
end

function getGrassNode( )
	return tGrassNode
end

-----------------------------------------------------------------------------------
--援军那层node接口
function addYuanjunNode(node, tag,name )
	tYuanjunNode[tag] = {node,name}
	setLevel5AnimationVisible(tag,false)
end

function removeYuanjunNode( tag )
	if tYuanjunNode[tag] then
		MapSpriteManage.pushSprite(mapElement.YUANJUN, tYuanjunNode[tag][2], tYuanjunNode[tag][1])
		tYuanjunNode[tag] = nil
		setLevel5AnimationVisible(tag,true)
	end
end

function removeAllYuanjunNode( )
	for i, v in pairs(tYuanjunNode) do
		MapSpriteManage.pushSprite(mapElement.YUANJUN, v[2], v[1])
		tYuanjunNode[i] = nil
		setLevel5AnimationVisible(i,true)
	end
	tYuanjunNode = {}
end

function getYuanjunNode( )
	return tYuanjunNode
end

-----------------------------------------------------------------------------------
--山寨，关卡跟山的相接那部分node
function addAdditionWallNode(node, tag, name)
	tAdditionWallNode[tag] = {node,name}
end

function removeAdditionWallNode( tag )
	if tAdditionWallNode[tag] then
		MapSpriteManage.pushSprite(mapElement.ADDITION,tAdditionWallNode[tag][2], tAdditionWallNode[tag][1])
	end
	tAdditionWallNode[tag] = nil
end

function removeAllAdditionWallNode( )
	for i, v in pairs(tAdditionWallNode) do
		MapSpriteManage.pushSprite(mapElement.ADDITION,v[2], v[1])
	end
	tAdditionWallNode = {}
end

function getAdditionWallNode( )
	return tAdditionWallNode
end

-----------------------------------------------------------------------------------
--丘陵那部分node
function addQiuLingNode(node, tag, name )
	tQiulingNode[tag] = {node,name}
end

function removeQiuLingNode( tag )
	if tQiulingNode[tag] then
		MapSpriteManage.pushSprite(mapElement.QIULING,tQiulingNode[tag][2],tQiulingNode[tag][1] )
	end
	tQiulingNode[tag] = nil
end

function removeAllQiuLingNode( )
	for i, v in pairs(tQiulingNode) do
		MapSpriteManage.pushSprite(mapElement.QIULING, v[2],v[1] )
	end
	tQiulingNode = {}
end

function getQiuLingNode( )
	return tQiulingNode
end

-----------------------------------------------------------------------------------
--扩建那部分node
function addExpandNode(node, tag )
	tExpandNode[tag] = node
end

function removeExpandNode( tag )
	tExpandNode[tag] = nil
end

function removeAllExpandNode( )
	for i, v in pairs(tExpandNode) do
		v:removeFromParentAndCleanup(true)
	end
	tExpandNode = {}
end

function getExpandNode( )
	return tExpandNode
end

--------------------------------------------------------------------------------
--屯田那层资源的接口
function addFarmingNode(node, tag, name )
	tFarmingNode[tag] = {node,name}
	setLevel5AnimationVisible(tag,false)
end

function removeFarmingNode( tag )
	if tFarmingNode[tag] then
		MapSpriteManage.pushSprite(mapElement.FARMING, tFarmingNode[tag][2], tFarmingNode[tag][1])
		tFarmingNode[tag] = nil
		setLevel5AnimationVisible( tag,true )
	end
end

function removeAllFarmingNode( )
	for i, v in pairs(tFarmingNode) do
		MapSpriteManage.pushSprite(mapElement.FARMING, v[2], v[1])
		tFarmingNode[i] = nil
		setLevel5AnimationVisible( i,true )
	end
	tFarmingNode = {}
end

function getFarmingNode( )
	return tFarmingNode
end


--------------------------------------------------------------------------------
--练兵那层资源的接口
function addTrainingNode(node, tag, name )
	tTrainingNode[tag] = {node,name}
	setLevel5AnimationVisible(tag,false)
end

function removeTrainingNode( tag )
	if tTrainingNode[tag] then
		MapSpriteManage.pushSprite(mapElement.TRAINING, tTrainingNode[tag][2], tTrainingNode[tag][1])  
		tTrainingNode[tag] = nil
		setLevel5AnimationVisible(tag,true)
	end
end

function removeAllTrainingNode( )
	for i, v in pairs(tTrainingNode) do
		MapSpriteManage.pushSprite(mapElement.TRAINING, v[2], v[1])
		tTrainingNode[i] = nil
		setLevel5AnimationVisible(i,true)
	end
	tTrainingNode = {}
end

function getTrainingNode( )
	return tTrainingNode
end

function getLevel5AnimationNode( wid )
	return tLevel5AnimationNode[wid]
end

function getAllLevel5AnimationNode( )
	return tLevel5AnimationNode
end

function addLevel5AnimationNode(wid,node,totalCount,total_index,name )
	if not tLevel5AnimationNode[wid] then
		tLevel5AnimationNode[wid] = {}
	end
	table.insert(tLevel5AnimationNode[wid], {node,totalCount,total_index,name})
end

function removeLevel5AnimationNode( wid )
	if tLevel5AnimationNode[wid] then
		for i, v in pairs(tLevel5AnimationNode[wid]) do
			v[1]:removeFromParentAndCleanup(true)
		end
	end
	tLevel5AnimationNode[wid] = nil
end

function removeAllLevel5AnimationNode( )
	for i, v in pairs(tLevel5AnimationNode) do
		for m, n in pairs(v) do
			n[1]:removeFromParentAndCleanup(true)
		end
	end
	tLevel5AnimationNode = {}
end

function setLevel5AnimationVisible( tag,visible )
	local tagwid = mapData.getRealWid(tag )
	local tagX = math.floor(tagwid/10000)+1
	local tagY = tagX*10000-tagwid
	mapController.setLevel5animationVisible(tagX*10000+tagY,visible)
end
