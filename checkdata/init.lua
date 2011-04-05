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


local tablex   = require 'auxiliary'.tablex
local setvar   = tablex.setvar
local type     = type
local min, max = math.min, math.max
local huge     = math.huge


-- false/nil => false
-- anything  => anything
local function _nilisfalse(bool)
  if (bool == nil) then
    return false
  else
    return bool end
end


--- Check if data match against a template.
--
-- @param template A template to match
-- @param data A target data to test
-- @param label ['nolabel'] A label for the data
--
-- @return data??template, error message
local function checkdata(template, data, label)
  label = label or 'nolabel'

  local tmpl_errors = ''
  local data_errors = ''
  local target      = data


  -- helper functions
  local function _xor(a, b)
    return (a and not b) or (b and not a) end

  local function _addfield (field, dotafter)
    if dotafter then
      return (field ~= '') and (field .. '.') or ''
    else
      return (field ~= '') and ('.' .. field) or '' end end

  local function _tmpl_error(message)
    tmpl_errors = tmpl_errors .. '(TEMPLATE ERROR) ' .. message ..'\n'
    return false end

  local function _data_error(message)
    data_errors = data_errors .. '(DATA ERROR) ' .. message ..'\n'
    return false end


  -- main function
  local function _checkdata(subtemplate, subdata, allstrict, field)
    -- default arguments
    allstrict = _nilisfalse(allstrict)
    field     = field or ''

    -- initializations
    local lbl = 'field <'.. label .. _addfield(field) ..'>'

    local CONTAINS  = subtemplate.CONTAINS
    local TYPE      = subtemplate.TYPE
    local OPTIONAL  = subtemplate.OPTIONAL
    local DEFAULT   = subtemplate.DEFAULT
    local STRICT    = subtemplate.STRICT
    local ALLSTRICT = allstrict or subtemplate.ALLSTRICT
    local TEST      = subtemplate.TEST or function () return true end

    local typesubdata  = type(subdata)


    -- check if one (and only one) of CONTAINS and TYPE is present
    if not _xor(CONTAINS, TYPE) then
      return _tmpl_error(lbl .. ' either one of "CONTAINS" and "TYPE" must be supplied') end


    -- check if non supplied fields are OPTIONAL
    if subdata == nil then
      -- field is not OPTIONAL
      if not OPTIONAL then
        return _data_error(lbl .. ' missing (not optional)')
      -- field has no default value, no problem
      elseif DEFAULT == nil then
        return true
      -- field has a default value, pretend it was supplied
      else
        subdata     = DEFAULT
        typesubdata = type(subdata)
        setvar(target, field, subdata) end end


    -- TYPE was supplied: terminal data
    if TYPE ~= nil then
      -- check if type of data
      if typesubdata ~= TYPE then
        return _data_error(lbl .. ' incorrect type; must be a '.. TYPE) end
      -- check with TEST function
      local successful, message = TEST(subdata)
      if not successful then
        return _data_error(lbl .. ' ' .. message)
      else
        return true end -- everything is fine


    -- CONTAINS was supplied: non terminal data
    else
      -- check if CONTAINS is a non-void table
      if type(CONTAINS) ~= 'table' then
        return _tmpl_error(lbl ..' must be a table') end
      -- check if subdata is a non-void table
      if typesubdata ~= 'table' then
        return _data_error(lbl ..' must be a table') end
      -- check if CONTAINS has any extra field and should not
      if ALLSTRICT or STRICT then
        for key in pairs(subdata) do
          -- extra field detected
          if CONTAINS[key] == nil then
            lbl = 'field <' .. label .. _addfield(field)
            return _data_error(lbl .. _addfield(key) ..'> extra field in not allowed') end end end

      -- call recursively until terminal data
      for key, subtemplate in pairs(CONTAINS) do
        local name = field .. _addfield(field, true) .. tostring(key)
        if not _checkdata(subtemplate, subdata[key], ALLSTRICT, name) then
          return false end end end

    return true end

  local successful =  _checkdata(template, data)
  if not successful then
    error(tmpl_errors .. data_errors)
  else
    return true end
end


--- Return a function that checks a number is in a given range.
--
-- @param inf Lower bound of the range
-- @param sup Upper bound of the range
local function inrange(inf, sup)
  inf, sup = min(inf, sup), max(inf, sup)
  return function (v)
    local test = v >= inf and v <= sup
    return test, (not test) and 'Must be between '.. inf ..' and '.. sup end
end


--- Return a function that checks a value is in a set of values.
--
-- @param tab A homogeneous table
-- @param func [identiy] A function applied before the comparison to
--             both fields of target and reference (string.lower,
--             math.abs, etc.)
local function inset(tab, func)
  --default arguments
  func = func or function (s) return s end

  -- initializations
  local set = {}
  for _, v in pairs(tab) do
    set[func(v)] = true end

  return function (s)
    return set[func(s)] end
end


--- Return a function that checks if a value is a list of elements of
--  a certain type.
--
-- These elements must follow the template. There can be between inf and
-- sup of them (included). template must be a table without subtables.
--
-- @param template A scalar or table that describes the elements
-- @param inf [1] Lower bound on the size list
-- @param sup [math.huge] Upper bound on the size list
local function listof(template, inf, sup)
  -- default arguments
  local inf = inf or 1
  local sup = sup or huge


  -- initializations
  local typetemplate = type(template)


  -- helper functions
  local function _nelts(list)
    local n = 0
    for _ in pairs(list) do
      n = n + 1 end
    return n end

  local function _same_structure(tab1, tab2)
    for k, v in pairs(tab1) do
      if type(tab2[k]) ~= v then
        return false end end
    for k, v in pairs(tab2) do
      if type(v) ~= tab1[k] then
        return false end end
    return true end


  -- main function
  return function (list)
    local nelts = _nelts(list)
    if nelts < inf or nelts > sup then
      return false, 'Incorrect number of elements must be in [' ..
      tostring(inf) .. ', ' .. tostring(sup) .. ']\n' end

    -- scalar values to compare
    if typetemplate ~= 'table' then
      for _, v in pairs(list) do -- negative indices maybe
        if type(v) ~= typetemplate then
          return false, 'Type mismatch\n' end end

    -- table values to compare
    else
      -- check each element of the list
      for k, v in pairs(list) do
        -- check type, should be a table (like typetemplate)
        if type(v) ~= typetemplate then
          return false, 'Element '.. k ..' should be a table\n' end
        if _nelts(v) ~=_nelts(template)
        -- count the elements
        or not _same_structure(template, v) then
          return false, 'Different structure\n' end end end

    -- everything is fine
    return true, '' end
end


local types = {
  ['number']   = 'number',
  ['string']   = 'string',
  ['table']    = 'table',
  ['userdata'] = 'userdata',
  ['function'] = 'function',
  ['thread']   = 'thread',
}

setmetatable(types, {__call = function (self, s) return types[s] end})


-- public interface
local checkdata_mt = {__call = function (self, ...) return checkdata(...) end}

return setmetatable({
  checkdata = checkdata,
  inrange   = inrange,
  inset     = inset,
  listof    = listof,
  types     = types}, checkdata_mt)


-- -- tests

-- local vardump = require 'vardump'.vardump

-- local isnonnegative = inrange(0, math.huge)
-- local isnonpositive = inrange(-math.huge, 0)

-- local function isnatural (n)
--   return isnonnegative(n) and n == math.floor(n), 'Must be a natural' end


-- local natural_number = {
--   TYPE = 'number',
--   TEST = isnonnegative}

-- local percentage = {
--   TYPE = types.number,
--   TEST = inrange(0, 1)}


-- local template = {
--   CONTAINS = {
--     width  = {
--       TYPE      = types['number'],
--       TEST      = isnatural},
--     height = {
--       TYPE      = types('number'),
--       TEST      = isnonnegative,
--       OPTIONAL  = true,
--       DEFAULT   = 10},
--     color  = {
--       CONTAINS = {
--         r = percentage,
--         g = percentage,
--         b = percentage}}
--   }}

-- local data = {
--   width = 20,
--   color = {r=1, g=1, b=0}}

-- print(checkdata(template, data, 'tests'))

-- vardump(data)
