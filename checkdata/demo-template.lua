------------------------------------------------------------------------
--
-- Complex Structured Data Input
--
-- A bit simpler/more readable than the original (get it at [1])
-- [1] http://argon.mieres.uniovi.es/lua/gems/csdi
--
-- author: Cédric Mauclair
--
-- based on the work by: Julio M. Fernández-Diáz
-- published in Lua gems, chapter 17 'Complex Structured Data Input'
--
-- Last edited by Cédric Mauclair <Cedric.Mauclair(nospam)@gmail.com>
--
-- [2011-04-04] Cédric Mauclair
--    * Creation of module, inpired from book
--    * LuaDoc
--
------------------------------------------------------------------------


local checkdata = require 'checkdata'


local positive = checkdata.inrange(0, math.huge)

local purecolor = {
  TYPE = 'number',
  TEST = checkdata.inrange(0, 1)}

local rgbcolor = {
  r = purecolor,
  g = purecolor,
  b = purecolor}


local template = {}

-- A box template
template.box = {
  ALLSTRICT = true,
  CONTAINS  = {
    id = {
      TYPE = 'string'},

    place = {
      TYPE = 'string',
      TEST = checkdata.inset({'front', 'back', 'spine'},
                             string.lower)},

    fill = {
      OPTIONAL = true,
      CONTAINS = {
        color = {
          CONTAINS = rgbcolor}}},

    adjust = {
      OPTIONAL = true,
      CONTAINS = {
        horizontal = {
          OPTIONAL = true,
          TYPE     = 'string',
          DEFAULT  = 'l',
          TEST     = checkdata.inset({'l', 'c', 'r'},
                                     string.lower)},
        vertical = {
          OPTIONAL = true,
          TYPE     = 'string',
          DEFAULT  = 'b',
          TEST     = checkdata.inset({'t', 'm', 'b'},
                                     string.lower)}},
      DEFAULT = {
        horizontal = 'l',
        vertical   = 'b'}},

    angle = {
      OPTIONAL = true,
      TYPE     = 'number',
      DEFAULT  = 0},

    position = {
      CONTAINS = {
        x = {TYPE = 'number'},
        y = {TYPE = 'number'}}},

    border = {
      OPTIONAL = true,
      CONTAINS = {
        color = {
          CONTAINS = rgbcolor},
        linewidth = {
          TYPE = 'number',
          TEST = positive}},
      DEFAULT = {
        color     = {r = 0, g = 1, b = 1},
        linewidth = 0.5}},

    width = {
      TYPE = 'number',
      TEST = positive},

    height = {
      TYPE = 'number',
      TEST = positive},

    more = {
      OPTIONAL = true,
      TYPE = 'table',
      DEFAULT = {},
      TEST = checkdata.listof({'number', 'string'})}
  }}


-- An arc template
template.arc = {
  CONTAINS = {
    id = {
      OPTIONAL = true,
      TYPE     = 'string'},

    place = {
      TYPE = 'string',
      TEST = checkdata.inset({'front', 'back', 'spine'},
                             string.lower)},

    fill  = {
      OPTIONAL = true,
      CONTAINS = {
        color = {CONTAINS = rgbcolor}}},

    border = {
      OPTIONAL = true,
      CONTAINS = {
        color     = {CONTAINS = rgbcolor},
        linewidth = {
          TYPE = 'number',
          TEST = positive}},
      DEFAULT = {
        color     = {r = 1, g = 0, b = 1},
        linewidth = 0.5}},

    radius = {
      TYPE = 'number',
      TEST = positive},

    startangle = {
      OPTIONAL = true,
      TYPE     = 'number',
      DEFAULT  = 0},

    endangle = {
      OPTIONAL = true,
      TYPE     = 'number',
      DEFAULT  = 360},

    center = {
      STRICT   = true,
      CONTAINS = {
        x = {TYPE = 'number'},
        y = {TYPE = 'number'}}},
  }}


return template
