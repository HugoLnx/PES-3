local ArticleDao = require('article_dao')
local Article = require('article')
local ArticleSerializer = require('article_serializer')

local M = {
  new = function(self, connection, app)
    local controller = {dao = ArticleDao:new(connection)}
    setmetatable(controller, {__index = self.metatable})
    return controller
  end,
}

M.metatable = {
  index = function(self, params)
    local articles = self.dao:all()
    
    return {
      status = 200,
      body = ArticleSerializer:serialize_many(articles),
      headers = { ["Content-Type"] = "application/json" },
    }
  end,

  create = function(self, params)
    local article = Article:new(params)
    article = self.dao:insert(article, params.document)
    
    return {
      status = 201,
      body = ArticleSerializer:serialize_one(article),
      headers = { ["Content-Type"] = "application/json" },
    }
  end,

  update = function(self)
  end,

  destroy = function(self)
  end,

  show = function(self)
  end,
}

return M
