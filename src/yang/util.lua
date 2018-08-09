
local _M = {}

-- extend t1 with all the elements of t2
function _M.table_extend(t1, t2)
  for i,v in pairs(t2) do
    table.insert(t1, v)
  end
end

-- Concat the contents of the parameter list,
-- separated by the string delimiter (just like in perl)
-- example: strjoin(", ", {"Anna", "Bob", "Charlie", "Dolores"})
function _M.str_join(delimiter, list)
   local len = table.getn(list)
   if len == 0 then
      return ""
   end
   local string = list[1]
   for i = 2, len do
      string = string .. delimiter .. list[i]
   end
   return string
end

-- split on *non*-matches of the pattern
-- e.g. str_isplit("a,b,c", ",") -> { ",", "," }
-- e.g. str_isplit("a,b,c", "[^,]") -> { "a", "b", "c" }
function _M.str_isplit(str, pattern)
   local tbl = {}
   str:gsub(pattern, function(x) tbl[#tbl+1]=x end)
   return tbl
end

-- split on literal substring
function _M.str_split(str, substr)
  local result = {}
  local cur = str
  if substr:len() == 0 then error("str_split with empty argument") end
  local i,j = str:find(substr)
  while i ~= nil do
    if j ~= nil then
      local part = str:sub(0, i-1)
      table.insert(result, part)
      str = str:sub(j+1)
      i,j = str:find(substr)
    end
  end
  table.insert(result, str)
  return result
end

-- splits the string on the given sub string, but
-- returns only the first element, and the rest of the original string
-- if the substring was not found at all, returns nil, <original_string>
function _M.str_split_one(str, substr)
  local parts = _M.str_split(str, substr)
  if table.getn(parts) == 1 then
    return nil, str
  else
    return table.remove(parts, 1), _M.str_join(substr, parts)
  end
end

-- returns the name and index of a list path (e.g. acls[3])
-- returns nil, nil if the first part does not contain a list index
function get_path_list_index(path)
  if path ~= nil then
    local name, index = string.match(path, "^([%w-_]+)%[(%d+)%]")
    if index ~= nil then return name, tonumber(index) end
  end
end



return _M

