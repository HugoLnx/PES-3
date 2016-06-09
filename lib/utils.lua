M = {}

M.merge = function(...)
  local table = {}
  for i, t in ipairs{...} do
    for k,v in pairs(t) do table[k] = v end
  end
  return table
end

M.copy_to = function(origin, destiny)
  for k,v in pairs(origin) do destiny[k] = v end
  return destiny
end

M.map = function(list, func)
  local new_list = {}
  for i,element in ipairs(list) do
    new_list[#new_list+1] = func(element)
  end
  return new_list
end

M.map_iterator = function(iterator, func)
  local new_list = {}
  for element in iterator do
    new_list[#new_list+1] = func(element)
  end
  return new_list
end

M.split = function(str, pattern)
  -- função auxiliar que separa uma string usando pattern
  local parts = {}
  for part in str:gmatch(pattern) do
    parts[#parts+1] = part
  end
  return parts
end

return M
