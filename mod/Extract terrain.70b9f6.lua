-- FTC-GUID: 70b9f6
keepForTerrainEditor = true

playZone = nil
playZoneData={
    type = "ScriptingTrigger",
    position          = {x=0, y=10, z=0},
    rotation          = {x=0, y=0, z=0},
    scale             = {x=72.2, y=100, z=48.2},
    sound             = false,
    snap_to_grid      = false,
}
playZoneScale= {{x=48.2, y=100, z=48.2} ,
{x=72.2, y=100, z=48.2},
{x=96.2, y=100, z=48.2},
{x=30.2, y=100, z=22.2},
{x=72.2, y=100, z=72.2},
{x=96.2, y=100, z=72.2}
}
selectedMat=2



function onLoad()
    assignVariables()
    --createExtractButton()
    self.setPosition({40,-2,-90})
    self.setRotation({0,180,0})
    self.interactable = false
    self.setScale({1,0.5,1})
end

extractLbl="EXTRACT\nTERRAIN"
subtitleLbl="Confirm size first"
subtitleLbl=""
scaleBtn={6,6,6}
offsetX=-5
extractBtn={
    label=extractLbl, click_function="showYNButtonsExtract", function_owner=self,
    position={0+offsetX,0,17}, rotation={0,0,0}, height=750, width=2000,
    font_size=300, color={0.8,0.8,0.8}, font_color={0,0,0}, scale=scaleBtn
}
subtitleBtn={
    label=subtitleLbl, click_function="none", function_owner=self,
    position={0+offsetX,0,20.8}, rotation={0,0,0}, height=0, width=0,
    font_size=100, color={0.8,0.8,0.8}, font_color="Red", scale=scaleBtn
}
backgroundBtn={
    label="", click_function="none", function_owner=self,
    position={0+offsetX,-1,18}, rotation={0,0,0}, height=2000, width=2500,
    font_size=300, color={0.4,0.4,0.4,0.7}, font_color={1,1,1}, scale=scaleBtn
}
confirmYesBtnExtract={
    label="Yes", click_function="extract", function_owner=self,
    position={-7+offsetX,0,29}, rotation={0,0,0}, height=750, width=820,
    font_size=300, color={0,0.6,0}, font_color={1,1,1}, scale=scaleBtn
}
confirmNoBtnExtract={
    label="No", click_function="hideYNButtonsExtract", function_owner=self,
    position={7+offsetX,0,29}, rotation={0,0,0}, height=750, width=820,
    font_size=300, color={0.6,0,0}, font_color={1,1,1}, scale=scaleBtn
}
infoBtn={
    label="TERRAIN\nEXPORTING\nINSTRUCTIONS", click_function="showInstructions", function_owner=self,
    position={0+offsetX,0,36}, rotation={0,0,0}, height=1000, width=2000,
    font_size=200, color={0,0,0}, font_color={1,1,1}, scale=scaleBtn
}

deleteLbl="DELETE\nTERRAIN"
deleteBtn={
    label=deleteLbl, click_function="showYNButtonsDelete", function_owner=self,
    position={0+offsetX,0,46}, rotation={0,0,0}, height=750, width=2000,
    font_size=300, color={0.8,0.8,0.8}, font_color={0,0,0}, scale=scaleBtn
}

confirmYesBtnDelete={
    label="Yes", click_function="deleteTerrain", function_owner=self,
    position={-7+offsetX,0,57}, rotation={0,0,0}, height=750, width=820,
    font_size=300, color={0,0.6,0}, font_color={1,1,1}, scale=scaleBtn
}
confirmNoBtnDelete={
    label="No", click_function="hideYNButtonsDelete", function_owner=self,
    position={7+offsetX,0,57}, rotation={0,0,0}, height=750, width=820,
    font_size=300, color={0.6,0,0}, font_color={1,1,1}, scale=scaleBtn
}


function assignVariables()
    --[[
    playZone=getObjectFromGUID('5d3218')
    junkyard1=getObjectFromGUID('894611')
    junkyard2=getObjectFromGUID('2ae8cf')
    junkyard3=getObjectFromGUID('d32b38')
    junkyard4=getObjectFromGUID('0b6f7d')
    table=getObjectFromGUID('948ce5')
    mat=getObjectFromGUID('4ee1f2')
    matUrlDisplay=getObjectFromGUID('c5e288')
    matUrlDisplay.setPosition({0,-5.53,0})
    --matUrlDisplay.setPosition({42,5,0})
    ]]--
    table=getObjectFromGUID('948ce5')
    mat=getObjectFromGUID('4ee1f2')
    mat.setPosition({0,mat.getPosition().y,mat.getPosition().z})
    matUrlDisplay=getObjectFromGUID('c5e288')
    Wait.frames(hideOther, 5)
    matUrlDisplay.setPosition({185,-6,0})
    flexControl=getObjectFromGUID('bd69bd')
    YNButtonsExtract=false
    YNButtonsDelete=false
    label0="E X P O R T\nT E R R A I N"
    adjust=3.5
    scaleBtn=6
    offsetBtn=-8.2*adjust
    offsetYBtn=2.8*adjust
    txtSize=120
end

function hideOther()
    matUrlDisplay.setInvisibleTo({"Red", "Blue", "Black", "Grey", "White"})
end

function showInstructions()
    Global.call("openTerrain")
end

function writeMenu()
    self.clearButtons()
    if YNButtonsExtract==false then
        extractBtn.label=extractLbl
    else
        extractBtn.label="Are you sure?"
        self.createButton(confirmYesBtnExtract)
        self.createButton(confirmNoBtnExtract)
    end
    if YNButtonsDelete == false then
        deleteBtn.label=deleteLbl
    else
        deleteBtn.label="Are you sure?"
        self.createButton(confirmYesBtnDelete)
        self.createButton(confirmNoBtnDelete)
    end
    createExtractButton()
    createDeleteButton()
end

function createMenu()
    createExtractButton()
    createDeleteButton()
end

function createExtractButton()
    --self.createButton(backgroundBtn)
    if extractBtn.label == extractLbl then
        self.createButton(subtitleBtn)
    end
    self.createButton(extractBtn)
    --self.createButton(infoBtn)
end

function createNoButtonExtract()
    self.createButton(confirmNoBtnExtract)
end

function createYesButtonExtract()
    self.createButton(confirmYesBtnExtract)
end

function showYNButtonsExtract()
    YNButtonsExtract = true
    writeMenu()
end

function hideYNButtonsExtract()
    YNButtonsExtract = false
    writeMenu()
end

function createDeleteButton()
    self.createButton(deleteBtn)
end

function showYNButtonsDelete()
    YNButtonsDelete = true
    writeMenu()
end

function hideYNButtonsDelete()
    YNButtonsDelete = false
    writeMenu()
end

function extract()
    broadcastToAll("EXTRATCING TERRAIN\nwait some seconds ...", "Yellow")
    mat=getObjectFromGUID("4ee1f2")
    createDebugMat()
    local startMenu=getObjectFromGUID("738804")
    if startMenu ~= nil then
      startMenu.call("recallAll")
    end
    Wait.time(extract2, 2)
end

function extract2()

    matUrlDisplay.call('retriveUrl')

    matUrlDisplay.clearInputs()
    matUrlDisplay.clearButtons()
    matUrlDisplay.setPosition({-38,-0.53,0})
    matUrlDisplay.setInvisibleTo({"Red", "Blue", "Black", "Grey", "White"})
    matUrlDisplay.interactable=false
    spawnPlayZone()
    Wait.frames(extract3, 3)
end

function extract3()
    local allObj=getAllObjects()
    local zoneObj=playZone.getObjects()
    for i, objA in ipairs(allObj) do
        local delete=true
        for j, objZ in ipairs (zoneObj) do
            if objA == objZ or objA == self or objA == matUrlDisplay then
                delete=false
                objZ.setLock(true)
                --objZ.setDescription("")
            end
        end
        if delete then
            objA.destroy()
        end
    end
    local allObj2 = getAllObjects()

    deleteTable()

    Wait.frames(injectLua, 2)
    --self.setPosition({37,2,0})
    --self.destroy()
end

function createDebugMat()
    local customInfo = mat.getCustomObject()
    --print("MAT :"..customInfo.diffuse..":")
    local clone=spawnObject({
        type              = "Custom_Model",
        position          = mat.getPosition(),

        params            = {mesh="https://steamusercontent-a.akamaihd.net/ugc/879750610978796176/4A5A65543B98BCFBF57E910D06EC984208223D38/",diffuse="https://steamusercontent-a.akamaihd.net/ugc/786374678935692054/F32489A74087FB9D9E26AC5F9461841B8C40B37A/"},

    })
    clone.setLuaScript("")
    --clone.setCustomObject(mat.getCustomObject())
    clone.setCustomObject({mesh="https://steamusercontent-a.akamaihd.net/ugc/879750610978796176/4A5A65543B98BCFBF57E910D06EC984208223D38/", diffuse=mat.getCustomObject().diffuse, material = 3})
    clone.setScale(mat.getScale())
    clone.setLock(true)
    --clone.interactable=false
    clone.setName("Mat url debug")
end

function deleteTable()
    --flexTable=getObjectFromGUID(flexTableGuid)
    local guidList = {
        "afc863","c8edca","393bf7","12c65e","f938a2","9f95fd","35b95f",
        "5af8f2","4ee1f2","bd69bd", "28865a", "9f95fd"
    }

    for i, tbl in ipairs(guidList) do
      local obj = getObjectFromGUID(tbl)
      if obj ~= nil then
        obj.destroy()
      end
    end
    --mat.destroy()
    --flexControl.destroy()
end

function deleteSelf()
    broadcastToAll("DONE", "Yellow")
    self.destroy()
end

function deleteTerrain()
    broadcastToAll("DELETING TERRAIN\nwait some seconds ...", "Red")
    local startMenu=getObjectFromGUID("738804")
    if startMenu ~= nil then
      startMenu.call("recallAll")
    end
    Wait.time(deleteTerrain2, 2)
end

function deleteTerrain2()
    spawnPlayZone()
    Wait.frames(deleteTerrain3, 3)
end

function deleteTerrain3()
    local zoneObj=playZone.getObjects()
    for i, obj in ipairs(zoneObj) do
        if obj.getGUID() ~= "4ee1f2" and obj.getGUID() ~= "28865a" and obj.getGUID() ~= "f938a2" then
            obj.destroy()
        end
    end
    broadcastToAll("DONE", "Red")
end

function spawnPlayZone()
    --local startMenu=getObjectFromGUID("738804")
    --selectedMat= startMenu.getVar("matSize")
    --playZoneData.scale=playZoneScale[selectedMat]
    playZoneData.scale=mat.getScale()

    playZoneData.scale.x=playZoneData.scale.x*36.02+0.2
    playZoneData.scale.y=100
    playZoneData.scale.z=playZoneData.scale.z*35.83+0.2
    --print("Scale: "..playZoneData.scale.x.." * "..playZoneData.scale.y.." * "..playZoneData.scale.z)
    playZone=spawnObject(playZoneData)
end

function injectLua()
    local objList = getAllObjects()
    local oldLua = ""
    local addLua = '\nBCBtype = "terrain"\n'
    local newLua = ""
    for i, obj in ipairs(objList) do
        if obj.getVar("BCBtype") == "terrain" or obj == matUrlDisplay then

        else
            oldLua = obj.getLuaScript()
            newLua = addLua .. oldLua
            obj.setLuaScript(newLua)
        end
    end
    Wait.frames(deleteSelf, 1)
end

function none()
end