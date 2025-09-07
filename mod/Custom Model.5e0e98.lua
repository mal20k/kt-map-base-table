local colorMap = {
  "Red",
  "Blue",
  "Yellow",
  "Teal",
  "White",
  "Grey"
}
self.max_typed_number = 1
function onNumberTyped( pc, n)
  color = Color.fromString(colorMap[((n - 1) % #colorMap)+1])
  self.setColorTint(color)
end