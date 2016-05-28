local Article = require "article"
local utils = require "utils"
local path = require "pl.path"
local file = require "pl.file"
local app = require "app"

local M = {
  new = function(self, connection, app)
    local dao = {connection = connection}
    setmetatable(dao, {__index = self.metatable})
    return dao
  end,
}

M.metatable = {
  insert = function(self, article, uploaded_document)
    if not article or not uploaded_document then error() end
    local result = self:__collection():insert_one(article:data())
    if result.acknowledged then
      local data = utils.merge(article:data(), {id = result.inserted_id.key})
      local article = Article:new(data)
      local abs_path = path.join(app.root, "public", article:document_path())
      file.copy(uploaded_document.path, abs_path)
      return article
    else
      return nil
    end
  end,

  all = function(self)
    return Article:build_all(self:__find_all())
  end,

  find = function(self, id)
    return Article:new(self:__find_all({_id = id})[1])
  end,
  
  __collection = function(self)
    local database = self.connection:getDatabase("pes3")
    return database:getCollection("articles")
  end,
  
  __find_all = function(self, query)
    local query = query or {}
    return utils.map_iterator(self:__collection():find(query), function(article_data)
      article_data.id = article_data._id.key
      article_data._id = nil
      return article_data
    end)
  end
}

return M
