local ArticleDao = require('article_dao')
local Article = require('article')

local M = {
  new = function(self, connection)
    local controller = {dao = ArticleDao:new(connection)}
    setmetatable(controller, {__index = self.metatable})
    return controller
  end,
}

M.metatable = {
  index = function(self, params)
    local articles = Article:data_of_all(self.dao:all())
    
    return {
      status = 200,
      json = { collection = articles },
    }
  end,

  create = function(self, params)
    local article = Article:new(params)
    article = self.dao:insert(article)
    
    return {
      status = 201,
      json = article:data(),
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
