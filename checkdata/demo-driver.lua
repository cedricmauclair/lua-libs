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

local tempfile  = arg[1] or 'demo-template'
local template  = require(tempfile)


-- One function per element to check: box and arc
local process = {}

local function basic_process(type, template)
  return function (elt)
           return checkdata(template[type], elt, type) end
end

process.box = basic_process('box', template)
process.arc = basic_process('arc', template)


-- Sand-boxing
local function myloadfile(filename)
  local successful, message = loadfile(filename)

  if successful then
    return successful
  else
    print(message)
    os.exit(1) end
end

local function sandbox(filename, func)
  setfenv(func,
          {math   = math,
           string = string,
           table  = table,
           box    = process.box,
           arc    = process.arc})

  local successful, message = pcall(func)

  if not successful then
    local b, e = string.find(message, ' ')
    print(string.sub(message, e + 1))
    os.exit(2) end
end


-- Main program
local file = arg[2] or 'demo-data.lua'
print('Template: '.. tempfile ..'.lua')
print('Datas:    '.. file)

print('Loading...')
local data = myloadfile(file)

print('Checking...')
sandbox(file, data)

print('Done')
