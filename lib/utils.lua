--[[
Módulo responsável por fornecer funções muito utilizadas e de utilidade geral
]]

M = {}

--[[
Responsabilidade: Efetua um merge entre tabelas
Pré-Condição: * Deve receber tabelas a serem juntadas
Pós-Condição: * Retorna uma tabela com a junção de todas as tabelas
]]
M.merge = function(...)
  local table = {}
  for i, t in ipairs{...} do
    for k,v in pairs(t) do table[k] = v end
  end
  return table
end

--[[
Responsabilidade: Copia dados de uma tabela para outra
Pré-Condição: * Deve receber tabela de origem
              * Deve receber tabela de destino
Pós-Condição: * Retorna a tabela de destino com os dados copiados
]]
M.copy_to = function(origin, destiny)
  for k,v in pairs(origin) do destiny[k] = v end
  return destiny
end

--[[
Responsabilidade: Itera por cada elemento e aplica uma função
Pré-Condição: * Deve receber uma lista
              * Deve receber a função a ser aplicada
Pós-Condição: * Retorna uma lista com o resultado da função para cada elemento da lista de entrada
]]
M.map = function(list, func)
  local new_list = {}
  for i,element in ipairs(list) do
    new_list[#new_list+1] = func(element)
  end
  return new_list
end

--[[
Responsabilidade: Itera por cada elemento e aplica uma função
Pré-Condição: * Deve receber o iterator
              * Deve receber a função a ser aplicada
Pós-Condição: * Retorna uma lista com o resultado da função para cada elemento do iterator
]]
M.map_iterator = function(iterator, func)
  local new_list = {}
  for element in iterator do
    new_list[#new_list+1] = func(element)
  end
  return new_list
end

--[[
Responsabilidade: Separa string baseado num padrão de separação
Pré-Condição: * Deve receber o padrão de separação
              * Deve receber a string a ser separada
Pós-Condição: * Retorna uma lista contendo a string separada ou vazio caso não consiga
]]
M.split = function(str, pattern)
  -- função auxiliar que separa uma string usando pattern
  local parts = {}
  for part in str:gmatch(pattern) do
    parts[#parts+1] = part
  end
  return parts
end

return M
