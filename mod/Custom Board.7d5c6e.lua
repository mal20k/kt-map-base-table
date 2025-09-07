
oldScript = nil
kt24Script = nil

function KTUI_ResetScripts()
  broadcastToAll("Reloading KT UI Extender")
  local r = 0
  for _, obj in ipairs(getAllObjects()) do
    if obj.hasTag('KTUIMini') then
      obj.reload()
      r = r+1
    end
  end
  broadcastToAll("Reloaded "..r.." items")
end

function detectItemOnTop()  --casts a ball that detects all the items on top
    local start = {self.getPosition()[1],self.getPosition()[2]+3.1,self.getPosition()[3]}
    local hitList = Physics.cast({
        origin       = start,
        direction    = {0,1,0},
        type         = 2,
        size         = {15,15,15},
        max_distance = 3,
        debug        = false,
    })
    return hitList
end

function extendUIForAllModels(player)
  local allTops = detectItemOnTop()
  for _,hitlist in ipairs(allTops) do
    local object = hitlist["hit_object"]
    if object.tag == "Figurine" then
      somethingExtended = true
      local objState = object.getTable('state')

      if objState.stats.W then
        broadcastToAll('Model ' .. object.getName() ..' using old stats, use new Command Node and New Recruit for KT24 stats')
        object.setLuaScript(oldScript)
      elseif objState.stats.Wounds then
        object.setLuaScript(kt24Script)
      end
      object = object.reload()
      object.addTag("KTUIMini")
      Wait.frames(function() object.call("setOwningPlayer", player.steam_id) end, 1)
    end
  end
end

-- TODO: refactor this to avoid horrible code repetition
-- lazy-load required scripts and apply required script
function ExtendUI(player)
  if not oldScript then
    WebRequest.get("https://raw.githubusercontent.com/feuerfritas/KTUI/gamelog-refactor/Scripts/MiniatureScript.lua", function(req)
      if req.is_error then
        log(req.error)
      else
        oldScript = req.text
        if oldScript and kt24Script then
          extendUIForAllModels(player)
        end
      end
    end)
  end
  if not kt24Script then
    WebRequest.get("https://raw.githubusercontent.com/feuerfritas/KTUI/main/Scripts/MiniatureScript24.lua", function(req)
      if req.is_error then
        log(req.error)
      else
        kt24Script = req.text
        if oldScript and kt24Script then
          extendUIForAllModels(player)
        end
      end
    end)
  end
  if oldScript and kt24Script then
    extendUIForAllModels(player)
  end
end

function SaveAllPositions(player)
  for _, obj in ipairs(getAllObjects()) do
    if obj.hasTag('KTUIMini') then
      local op = obj.call("getOwningPlayer")
      if op ~= nil then
        obj.call("savePosition")
      end
    end
  end
  player.broadcast("All positions saved")
end

function LoadAllPositions(player, test, alt, aa)
  print(alt)
  for _, obj in ipairs(getAllObjects()) do
    if obj.hasTag('KTUIMini') then
      local op = obj.call("getOwningPlayer")
      if op ~= nil then
        obj.call("loadPosition")
      end
    end
  end
  player.broadcast("All positions loaded")
end

function ReadyAllOperatives(player)
  for _, obj in ipairs(getAllObjects()) do
    if obj.hasTag('KTUIMini') then
      local op = obj.call("getOwningPlayer")
      if op ~= nil then
        obj.call("KTUI_ReadyOperative")
      end
    end
  end
  player.broadcast("All operatives have been readied")
end




function CleanAllOperatives(player)
  local allTops = detectItemOnTop()
  for _,hitlist in ipairs(allTops) do
    local obj = hitlist["hit_object"]
    if obj.hasTag('KTUIMini') then
      local op = obj.call("getOwningPlayer")
      if op ~= nil then
        obj.call("KTUI_CleanOperative")
      end
    end
  end
  player.broadcast("All operatives have been cleaned of their tokens")
end

function EngageAllOperatives()
  local allTops = detectItemOnTop()
  for _,hitlist in ipairs(allTops) do
    local obj = hitlist["hit_object"]
    if obj.hasTag('KTUIMini') then
      local op = obj.call("getOwningPlayer")
      if op ~= nil then
        obj.call("setEngage")
      end
    end
  end
end

function ConcealAllOperatives()
  local allTops = detectItemOnTop()
  for _,hitlist in ipairs(allTops) do
    local obj = hitlist["hit_object"]
    if obj.hasTag('KTUIMini') then
      local op = obj.call("getOwningPlayer")
      if op ~= nil then
        obj.call("setConceal")
      end
    end
  end
end