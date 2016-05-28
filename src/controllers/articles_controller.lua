local ArticleDao = require('models/article_dao')
local Article = require('models/article')
local ArticleSerializer = require('models/article_serializer')

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

  download = function(self, params)
    local article, file = self.dao:download(params.id)
    
    if article then
      return {
        status = 200,
        body = file,
        headers = {
          ["Content-Type"] = "application/octet-stream",
          ["Content-Disposition"] = "attachment;filename='"..article.title..".pdf'",
        },
      }
    else
      return {
        status = 404,
        body = '{"error" : "Not found"}',
        headers = {
          ["Content-Type"] = "application/json",
        },
      }
    end
  end,

  update = function(self, params)
    local article = self.dao:update(Article:new(params), params.document)
    if article then
      return {
        status = 200,
        body = ArticleSerializer:serialize_one(article),
        headers = {
          ["Content-Type"] = "application/json",
        },
      }
    else
      return {
        status = 404,
        body = '{"error" : "Not found"}',
        headers = {
          ["Content-Type"] = "application/json",
        },
      }
    end
  end,

  destroy = function(self, params)
    if self.dao:delete(params.id) then
      return { status = 204, }
    else
      return {
        status = 404,
        body = '{"error" : "Not found"}',
        headers = {
          ["Content-Type"] = "application/json",
        },
      }
    end
  end,

  show = function(self)
  end,
}

return M
