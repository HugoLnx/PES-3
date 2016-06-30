--[[article serializer modulos
This modulo has the functions about the article serializer
]]
local utils = require "utils"

local function data_for(article)
  return utils.merge(article:data(), {
    download_path = article:document_path(),
    authors = table.concat(article.authors, ", "),
    view_path = "/articles/" .. article.id .. ".html",
  })
end

return {
  serialize_one = function(self, article)
    return data_for(article)
  end,
  
  serialize_many = function(self, articles)
    return utils.map(articles, function(article) return data_for(article) end)
  end,
}

