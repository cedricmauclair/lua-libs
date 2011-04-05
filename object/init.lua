------------------------------------------------------------------------
--
-- Oject, Lua-style
-- (Lua gems, Chapter 12)
--
--
-- author: Reuben Thomas
--
--
-- Last edited by Cédric Mauclair <Cedric.Mauclair(nospam)@gmail.com>
--
--
-- [2011-03-29] Cédric Mauclair
--    * Creation of module, copied from book
--    * LuaDoc
--    * 'Object._clone' modified to set '_prototype' field
--    * 'subclass' modified to do pre/post-actions around 'merge'.
--      Default subclasspre does nothing.
--      Default subclasspost sets '_init' & '_prototype' fields.
--    * 'rearrange' modified to support optionnal arguments with default
--      values and support positionnal and named arguments.
--
------------------------------------------------------------------------


local function clone(t)
  local u = setmetatable({}, getmetatable(t))
  for i, v in pairs(t) do
    u[i] = v
  end
  return u
end


local function merge(t, u)
  local r = clone(t)
  for i, v in pairs(u) do
    r[i] = v
  end
  return r
end


local function rearrange(p, t)
  local r = clone(t)
  for k, v in pairs(p) do
    if type(k) == 'number' then
      assert(t[v] or t[k],
             "Argument '" .. k .. "' or '" .. v .. "' is mandatory")
      r[v] = t[v] or t[k]
      r[k] = nil
    else
      r[k] = t[k] or v
    end
  end
  return r
end


local function subclasspre(object, ...) end
local function subclasspost(object, ...)
  local r, s = {}, {}
  for _, c in pairs({...}) do
    r[#r+1] = c._prototype
    for k, v in pairs(c._init) do
      if type(k) == 'number' then
        s[#s+1] = v
      else
        s[k] = v
      end
    end
  end
  object._prototype = r
  object._init = s
end


local function subclass(...)
  local object = {}
  subclasspre(object, ...)
  for _, c in pairs({...}) do
    object = merge(object, c)
  end
  subclasspost(object, ...)
  return setmetatable(object, object)
end


local Object = {
  _init  = {},
  _clone = function (self, values)
             local object = merge(self, rearrange(self._init, values))
             object._prototype = self
             return setmetatable(object, object)
           end,
  __call = function (...)
             return (...)._clone(...)
           end,
}

setmetatable(Object, Object)


-- public interface
return {
  Object       = Object,
  subclass     = subclass,
  subclasspre  = subclasspre,
  subclasspost = subclasspost
}


-- -- unit tests
-- vardump = require 'vardump'.vardump

-- Rectangle = Object {_init = {'l', 'L'}}
-- Couleur   = Object {_init = {'color'}}
-- Couleur   = Object {_init = {['color'] = 'red'}}
-- Couleur   = Object {_init = {color = 'red'}}

-- RectangleColore = subclass(Rectangle, Couleur)

-- rc = RectangleColore {10, L=20, color='blue'}
-- vardump(rc)

-- print('===================================')

-- rc = RectangleColore {10, L=20}
-- vardump(rc)
