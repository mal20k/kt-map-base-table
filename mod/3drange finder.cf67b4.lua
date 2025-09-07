self.interactable=false
RANGE_MAX = 7
RANGE_MIN=0
BASE_CURRENT=0
RANGE_CURRENT = 0
base={}
range={}
col={}
range[0]=2
range[1]=3
range[2]=4
range[3]=6
range[4]=7
range[5]=8
range[6]=9
range[7]=12
clean=nil
toggle=0
model=nil
col[0]={1, 1, 0,0.3}
col[1]={0,1,0,0.3}
col[2]={0,1,1,0.3}
col[3]={0, 0,1,0.3}
col[4]={1, 0,1,0.3}
col[5]={1, 0,0,0.3}
col[6]={1, 1,0,0.3}
col[7]={0, 1,0,0.3}



cleanch=nil
oldmodel=nil

function onload(saved_data)
  if saved_data ~= "" then
    local loaded_data = JSON.decode(saved_data)
    cleanch = loaded_data.cleanch
    oldmodel = loaded_data.oldmodel
    cleancheck()
    generateBtnParams()
    createBtns(Display_params)
    createBtns(range_params)
  else
  generateBtnParams()
  createBtns(Display_params)
  createBtns(range_params)
  end
end

function cleancheck()

local oldmod = getObjectFromGUID(oldmodel)
if oldmod ~= nil then
    local check=oldmod.getAttachments()
      local attachment=0
      if check ~= nil then
        for c=1, #check do
          attachment=c
        end
          if attachment >= 2 then
            oldmod.removeAttachment(attachment-1)
          else
            oldmod.removeAttachments()
          end

          cleanup=getObjectFromGUID(cleanch)
            if cleanup !=nil then
            cleanup.destruct()
            cleanch=nil
            oldmodel=nil
            end
        end
  end
end

function updateSave()
    local data_to_save = {["cleanch"]=clean,["oldmodel"]=oldmodel}
    saved_data = JSON.encode(data_to_save)
    self.script_state = saved_data
end



function generateBtnParams()
  Display_params = {position={0,1,-2},
    click_function = 'toggle1',
    label="3D Range";
    rot={0,90,0},
    bg_color = {0,0,0,1},
    h = 300,
    w = 1000,
    f_size = 200,
    f_color = {1,0.4,0}
  }
    range_params = {position={-0.7,1,-2},
      click_function = 'range_add_subtract',
      label = range[RANGE_CURRENT].."\"",
      rot={0,90,0},
      bg_color = {0,0,0,1},
      h = 300,
      w = 650,
      f_size = 200,
      f_color = {1,1,1}
}
end

function toggle1()
  if model != nil then
    if toggle == 0 then
      toggle=toggle +1
      self.editButton({
        index =0,
        font_color={0,0,0,1},
        color={1,0.4,0}
      })
      range_first()
    elseif toggle==1 then
      toggle = toggle-1
      self.editButton({
        index =0,
        font_color={1,0.4,0},
        color={0,0,0,1}
      })
      display_refresh()
    end
  else
    print("Select model first")
  end
end

function onObjectPickUp(playercol,target)
  local data = target.getData()
    local modelcheck = target.getTable('state')
    if modelcheck ~= nil then
      bsize=target.getTable('state')
      if model != nil then
        if target.getGUID() != model.getGUID() then
          if toggle ==1 then
            display_refresh()
            model=target
            calc()
            spawn1()
          else model=target
          end
        end
      else
        model=target
      end
    end
end

function createBtns(params)
	local rot = {0,0,0}
	self.createButton({
  label= params.label,
  click_function=params.click_function,
  function_owner=self,
  position=params.position,
  rotation=params.rot,
  height=params.h,
  width=params.w,
  font_size=params.f_size,
  font_color=params.f_color,
  color=params.bg_color,
})
end


function range_add_subtract(_obj, _color, alt_click)
  mod = alt_click and -1 or 1
  new_value=RANGE_CURRENT+mod
  if  new_value > RANGE_MAX then
    RANGE_CURRENT = 0
  else
      if new_value < RANGE_MIN then
        RANGE_CURRENT = 7
            else
        RANGE_CURRENT=new_value
      end
    end
    self.editButton({
      index = 1,
    label = range[RANGE_CURRENT].."\"",
    })
    if toggle==1 then
    range_display()
  end
end

function spawn1()
    local spawned = ""
       for _, obj in pairs(self.getData().ContainedObjects) do
          if obj.GUID != nil then
            local    spawned = obj
              oldmodel=model.getGUID()
            local  positionSelf = model.getPosition()
              spawnedscale=({x=rad /10, y=rad /10, z=rad /10})
              spawnedPosition={positionSelf.x,0.3+positionSelf.y,positionSelf.z}
              spawnObjectData({
              data     = spawned,
              position =  spawnedPosition,
              scale    = spawnedscale,
              callback_function = function(spawned)
                local tint=col[RANGE_CURRENT]
              spawned.setColorTint(tint)
                clean=spawned.getGUID()
                updateSave()
                model.addAttachment(spawned)
                                  end
                              })
            end
        end
end

function calc()
  local mtoi = 0.0393701
  rad=2*range[RANGE_CURRENT]+bsize.base.x*mtoi
end

function range_first()
calc()
    spawn1()
end

function range_display()
calc()

     if model != nil then
        display_refresh()
        spawn1()
      end
end

function display_refresh()
  if clean != nil  then
    local check=model.getAttachments()
      local attachment=0
      if check ~= nil then
        for c=1, #check do
          attachment=c
        end
          if attachment >= 2 then
            model.removeAttachment(attachment-1)
          else
            model.removeAttachments()
          end
          cleanup=getObjectFromGUID(clean)
            if cleanup !=nil then
            cleanup.destruct()
            clean=nil
            end
      end
  end
end