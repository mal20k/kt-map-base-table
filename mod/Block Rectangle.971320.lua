self.createButton({
  label="Random Crit Op", click_function="randomMission", function_owner=self,
  position={0.5,1,0}, rotation={0,90,0}, height=300, width=1500,
  font_size=200, color={0,0,0}, font_color={1,0.4,0}
})
self.createButton({
  label="Select Crit Op", click_function="selectMission", function_owner=self,
  position={-0.5,1,0}, rotation={0,90,0}, height=300, width=1500,
  font_size=200, color={0,0,0}, font_color={1,0.4,0}
})

local dealtCardGuid

function randomMission()
  recoverPreviousCard()
  getObjectFromGUID("07dff6").shuffle()
  --37.5 is Z component of blue hand zone, should probably change this method to a cleaner one
  Wait.frames(
    function ()
      local dealtCard = getObjectFromGUID("07dff6").dealToColorWithOffset({67.47,5.0-0.96,8.06+37.50}, true, "Blue")
      dealtCard.setLock(true)
      dealtCard.setRotation(Vector(45,270,0))
      dealtCard.addTag("MissionDealt")
      dealtCardGuid = dealtCard.getGUID()
    end,
    1
  )
end

function recoverPreviousCard()
  local deck = getObjectFromGUID("07dff6")
  if dealtCardGuid then
    local oldCard = getObjectFromGUID(dealtCardGuid)
    if oldCard then
      oldCard.setLock(false)
      local deckPosition = deck.getPosition()
      deckPosition.y = deckPosition.y-1
      oldCard.setPosition(deckPosition)
      deck.putObject(oldCard)
    end
  end
end

function selectMission()
  recoverPreviousCard()
  Wait.frames(
    function ()
      local dealtCard = getObjectFromGUID("07dff6").takeObject({
        position = {67.47,5.0,8.06}
      })
      dealtCard.setLock(true)
      dealtCard.setRotation(Vector(45,270,0))
      dealtCard.addTag("MissionDealt")
      dealtCardGuid = dealtCard.getGUID()
    end,
    1
  )
end


--[[
self.createButton({
  label="Random Map", click_function="Map", function_owner=self,
  position={0,1,2}, rotation={0,90,0}, height=300, width=1300,
  font_size=200, color={0,0,0}, font_color={1,0.4,0}
})


function Map()
  getObjectFromGUID("63c4a2").shuffle()
  Wait.frames(
    function ()
      local dealtCard = getObjectFromGUID("63c4a2").dealToColorWithOffset({55.0,1.0,61.00}, true, "Blue")
      dealtCard.setRotation(Vector(0,270,0))
      dealtCard.addTag("MapDealt")
    end, 1
  )
end
]]