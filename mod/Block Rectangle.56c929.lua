self.createButton({
    label="Lower barriers", click_function="Lower", function_owner=self,
    position={0,1,-3}, rotation={0,90,0}, height=300, width=1300,
    font_size=200, color={0,0,0}, font_color={1,0.4,0}
  })

  self.createButton({
      label="Raise barriers", click_function="Raise", function_owner=self,
      position={0,1,3}, rotation={0,90,0}, height=300, width=1300,
      font_size=200, color={0,0,0}, font_color={1,0.4,0}
    })



function Lower()
  for _, obj in pairs(getObjectsWithTag('Barrier')) do
    obj.scale({1,0.25,1})
  end
end

function Raise()
  for _, obj in pairs(getObjectsWithTag('Barrier')) do
    obj.scale({1,4,1})
  end
end