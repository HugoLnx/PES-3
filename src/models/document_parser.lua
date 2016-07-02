return {
  --[[
  Responsabilidade: Retorna o texto de um pdf
  Pré-Condição: * Deve receber caminho para o pdf
  Pós-Condição: * Retorna o texto contido no pdf
  ]]
  get_text = function(self, path)
    local handle = io.popen("pdftotext '" .. path .. "' '-'")
    local content = handle:read("*a")
    handle:close()
    return content
  end,
}
