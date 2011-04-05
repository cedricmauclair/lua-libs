------------------------------------------------------------------------
--
-- Vardump: The Power of Seeing What's Behind
-- (Lua gens, Chapter 3)
--
--
-- author: Tobias Sulzenbruck
--         Christoph Beckmann
--
--
-- Last edited by Cédric Mauclair <Cedric.Mauclair(nospam)@gmail.com>
--
--
-- [2011-03-29] Cédric Mauclair
--    * Creation of module, copied from book
--    * LuaDoc
--    * 'vardump' modified to print keys for metatables, functions,
--      threads and userdata too
--
------------------------------------------------------------------------


--- Dump the type and content of a value.
-- @param value Value to dump
-- @param full  [false] Print key before metatables, functions, threads
--              and userdata too
-- @param depth [[intern]] Used to compute indentation
-- @param key   [[intern]] Used to print the key in a table
------------------------------------------------------------------------
local function vardump(value, full, depth, key)
  local linePrefix = ""
  local spaces = ""
  if key ~= nil then
     linePrefix = "[" .. key .. "] = "
  end
  if depth == nil then
     depth = 0
  else
     depth = depth + 1
     for i = 1, depth do spaces = spaces .. "  " end
  end
  if type(value) == 'table' then
     local mttable = getmetatable(value)
     if mttable == nil then
       print(spaces .. linePrefix .. "(table) ")
     else
       print(spaces .. (full and linePrefix or '') .. "(metatable) ")
         value = mttable
     end
     for tableKey, tableValue in pairs(value) do
       vardump(tableValue, full, depth, tableKey)
     end
  elseif  type(value) == 'function'
       or type(value) == 'thread'
       or type(value) == 'userdata'
       or value       == nil
  then
     print(spaces .. (full and linePrefix or '') .. tostring(value))
  else
     print(spaces .. linePrefix .. "(" .. type(value) .. ") " .. tostring(value))
  end
end


-- public interface
return {
  vardump = vardump
}
