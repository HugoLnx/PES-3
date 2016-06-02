local utils = require "utils"
local path = require "pl.path"

local ATTRIBUTES = {"id", "title", "authors", "downloads", "document_text"}

local function to_data(values)
  local data = {}
  for _,attribute in ipairs(ATTRIBUTES) do
    data[attribute] = values[attribute]
  end
  return data
end

local M = {
  new = function(self, values)
    local article = to_data(values)
    article.downloads = article.downloads or 0
    setmetatable(article, {__index = self.metatable})
    return article
  end,
  
  build_all = function(self, articles_data)
    local articles = {}
    for i,values in ipairs(articles_data) do
      articles[#articles+1] = self:new(values)
    end
    return articles
  end,
  
  data_of_all = function(self, articles)
    return utils.map(articles, function(article) return article:data() end)
  end,
}

M.metatable = {
  data = function(self)
    return to_data(self)
  end,
  
  document_path = function(self)
    return path.join("articles", self.id .. ".pdf")
  end,
}

return M
