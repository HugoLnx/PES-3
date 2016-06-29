return {
  get_text = function(self, path)
    local handle = io.popen("pdftotext '" .. path .. "' '-'")
    local content = handle:read("*a")
    handle:close()
    return content
  end,
}
