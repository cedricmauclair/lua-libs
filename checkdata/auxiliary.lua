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
-- [2011-04-01] Cédric Mauclair
--    * Creation of module, inpired from book
--    * LuaDoc
--
------------------------------------------------------------------------


local tablex = {}


--- Formats tables with cycles recursively to any depth.
--
--  Author: Julio Manuel Fernandez-Diaz
--  Date:   January 12, 2007
--  (For Lua 5.1)
--
--  Modified slightly by RiciLake to avoid the unnecessary table traversal in tablecount()
--
--  The output is returned as a string. References to other tables are
--  shown as values. Self references are indicated.
--
--  The string returned is "Lua code", which can be procesed (in the
--  case in which indent is composed by spaces or "--"). Userdata and
--  function keys and values are shown as strings, which logically are
--  exactly not equivalent to the original code.
--
--  This routine can serve for pretty formating tables with proper
--  indentations, apart from printing them:
--
--    print(table.show(t, "t"))   -- a typical use
--
--  Heavily based on "Saving tables with cycles", PIL2, p. 113.
--
-- @param t A table
-- @param ['__unnamed__'] name A name to print before the table
-- @param [''] indent Initial indent on the line
function tablex.show(t, name, indent)
   local cart     -- a container
   local autoref  -- for self references

   -- (RiciLake) returns true if the table is empty
   local function isemptytable(t) return next(t) == nil end

   local function basicSerialize (o)
      local so = tostring(o)
      if type(o) == "function" then
         local info = debug.getinfo(o, "S")
         -- info.name is nil because o is not a calling level
         if info.what == "C" then
            return string.format("%q", so .. ", C function")
         else
            -- the information is defined through lines
            return string.format("%q", so .. ", defined in (" ..
                info.linedefined .. "-" .. info.lastlinedefined ..
                ")" .. info.source)
         end
      elseif type(o) == "number" then
         return so
      else
         return string.format("%q", so)
      end
   end

   local function addtocart (value, name, indent, saved, field)
      indent = indent or ""
      saved = saved or {}
      field = field or name

      cart = cart .. indent .. field

      if type(value) ~= "table" then
         cart = cart .. " = " .. basicSerialize(value) .. ";\n"
      else
         if saved[value] then
            cart = cart .. " = {}; -- " .. saved[value]
                        .. " (self reference)\n"
            autoref = autoref ..  name .. " = " .. saved[value] .. ";\n"
         else
            saved[value] = name
            --if tablecount(value) == 0 then
            if isemptytable(value) then
               cart = cart .. " = {};\n"
            else
               cart = cart .. " = {\n"
               for k, v in pairs(value) do
                  k = basicSerialize(k)
                  local fname = string.format("%s[%s]", name, k)
                  field = string.format("[%s]", k)
                  -- three spaces between levels
                  addtocart(v, fname, indent .. "   ", saved, field)
               end
               cart = cart .. indent .. "};\n"
            end
         end
      end
   end

   name = name or "__unnamed__"
   if type(t) ~= "table" then
      return name .. " = " .. basicSerialize(t)
   end
   cart, autoref = "", ""
   addtocart(t, name, indent)
   return cart .. autoref
end


--- Set a field in a table, takes care of intermediary tables.
--
--  from http://lua-users.org/wiki/SetVariablesAndTablesWithFunction
--  No changes, only renamed to tablex.setvar
--
-- @param Table [_G] A table
-- @param Name Name of the variable, e.g.
--        * A.B.C ensures the table A and A.B and sets A.B.C to <Value>
--        * single dots at the end inserts the value in the last position of the array
--          e.g. A. ensures table A and sets A[#A] to <Value>
--        * multiple dots are interpreted as a string
--          e.g. A..B. ensures the table A..B
-- @param Value (any)
function tablex.setvar (Table, Name, Value)
  -- default arguments
  if type(Table) ~= 'table' then
    Table, Name, Value = _G, Table, Name end

  -- initializations
  local Concat, Key = false, ''

  string.gsub(
    Name,
    '([^%.]+)(%.*)',
    function(Word, Delimiter)
      if Delimiter == '.' then
        if Concat then
          Word = Key .. Word
          Concat, Key = false, '' end
        if type(Table[Word]) ~= 'table' then
          Table[Word] = {} end
        Table = Table[Word]
      else
        Key = Key .. Word .. Delimiter
        Concat = true end end)

  if Key == '' then
    table.insert(Table, Value)
  else
    Table[Key] = Value end
end


-- public interface
return {
  tablex = tablex
}
