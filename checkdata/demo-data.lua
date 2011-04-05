-- Sample for parsing data

number = 15

-- a box
box {
   id = 'box1',
   place = 'front',
   --adjust = {horizontal = 'c', vertical = 'm'},
   angle = number,
   position = {x = 0, y = 0},
   width = 20,
   height = 20,
   more = {{1, 'g'}, {2, 'h'}}
}

-- an arc
arc {
   id = 'arc1',
   place = 'back',
   center = {x = 2, y = 30},
   radius = 60,
   startangle = 0,
   endangle = 360
}
