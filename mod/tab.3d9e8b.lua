--************************************************************
--DEVELOPED BY Ixidior (PE)
--Discord: Ixidior
--VERSION: 1.0
--************************************************************

function detectItemOnTop()  --casts a ball that detects all the items on top
    local start = {self.getPosition().x,self.getPosition().y,self.getPosition().z}
    local hitList = Physics.cast({
        origin       = start,
        direction    = {0,1,0},
        type         = 3,
        size         = {12,1,6},
	orientation  = {x=self.getRotation().x,y=self.getRotation().y,z=self.getRotation().z},
        max_distance = 5,
        debug        = false,
	})
    return hitList
end
str1=""
str2=""
function insertCode(player)

	local allTops = detectItemOnTop()

	
      for _,hitlist in ipairs(allTops) do
        local object = hitlist["hit_object"]
	if object.tag == "Figurine" then
	
        script = object.getLuaScript()
	if string.find(script,"--Actualizado KTMT") == nill then
		inicio = string.find(script,"self.addContextMenuItem")
		if inicio != nill then
		str1 = string.sub(script,1,inicio-1).."\n"
		str2 = string.sub(script,inicio-1,string.len(script)).."\n"
		WebRequest.get("https://raw.githubusercontent.com/Ixidior/KTMT/main/insertCode_pt1", function(req) 
		strX = req.text
		sep = string.find(strX,"--parte2")-1
		cod1 = string.sub(strX,1,sep)
		cod2 = string.sub(strX,sep+1,string.len(strX))
		object.setLuaScript(str1..cod1..str2..cod2)
		object = object.reload()
		object.addTag("KTMT")
		Wait.frames(function() object.call("setOwningPlayer", player.steam_id) end, 1)
		Wait.frames(function() object.call("refreshVectors") end, 1)
		end)
	end
	end
	end
      end

end