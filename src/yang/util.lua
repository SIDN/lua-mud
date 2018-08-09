
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

-- Finds the index of the given element in the given list
function _M.get_index_of(list, element)
  for i,v in pairs(list) do
    if v == element then
      print("[XX] yooy: " .. i)
      return i
    end
  end
  error('element not found in list')
end


-- returns the name and index of a list path (e.g. acls[3])
-- returns nil, nil if the first part does not contain a list index
function get_path_list_index(path)
  if path ~= nil then
    local name, index = string.match(path, "^([%w-_]+)%[(%d+)%]")
    if index ~= nil then return name, tonumber(index) end
  end
end

-- Based on http://lua-users.org/wiki/InheritanceTutorial
-- Defining a class with inheritsFrom instead of just {} will
-- add all methods, and class, superclass and isa method
function _M.subClass( baseClass )

    local new_class = {}
    local class_mt = { __index = new_class }

    function new_class:create()
        local newinst = {}
        setmetatable( newinst, class_mt )
        return newinst
    end

    if nil ~= baseClass then
        setmetatable( new_class, { __index = baseClass } )
    end

    -- Implementation of additional OO properties starts here --

    -- Return the class object of the instance
    function new_class:class()
        return new_class
    end

    -- Return the super class object of the instance
    function new_class:superClass()
        return baseClass
    end

    -- Return true if the caller is an instance of theClass
    function new_class:isa( theClass )
        local b_isa = false

        local cur_class = new_class

        while ( nil ~= cur_class ) and ( false == b_isa ) do
            if cur_class == theClass then
                b_isa = true
            else
                print("[XX] get superclass of " .. self:getType())
                cur_class = cur_class:superClass()
            end
        end

        return b_isa
    end

    return new_class
end

-- helper function for deep copying data nodes
function _M.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[_M.deepcopy(orig_key)] = _M.deepcopy(orig_value)
        end
        setmetatable(copy, _M.deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end


return _M
