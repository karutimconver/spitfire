_G.SCREEN_WIDTH = 480 -- 1920
_G.SCREEN_HEIGHT = 270 --1080

_G.DEBBUGGING = true

_G.FULLSCREEN = false


function _G.round(val)
    return math.floor(val + 0.5)
end

-- Utility functions found on stackoverflow
function _G.copy(obj, seen)
    if type(obj) ~= 'table' then return obj end
    if seen and seen[obj] then return seen[obj] end
    local s = seen or {}
    local res = setmetatable({}, getmetatable(obj))
    s[obj] = res
    for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
    return res
end

function _G.split (inputstr, sep)
    if sep == nil then
       sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
       table.insert(t, str)
    end
    return t
 end

 function table.contains(table, element)
    for _, value in pairs(table) do
      if value == element then
        return true
      end
    end
    return false
end