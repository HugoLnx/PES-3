local Article = require "article"
local utils = require "utils"
local cjson = require "cjson"

local function data_for(article)
  return utils.merge(article:data(), {download_path = article:document_path()})
end

return {
  serialize_one = function(self, article)
    local data = data_for(article)
    return cjson.encode({article = data})
  end,
  
  serialize_many = function(self, articles)
    local json = {}
    if #articles == 0 then
      return '{"articles":[]}'
    else
      local data = utils.map(articles, function(article) return data_for(article) end)
      return cjson.encode({articles = data})
    end
  end,
}

