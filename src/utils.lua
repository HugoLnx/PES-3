M = {}

M.merge = function(table1, table2)
  local table = {}
  for k,v in pairs(table1) do table[k] = v end
  for k,v in pairs(table2) do table[k] = v end
  return table
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

return M
