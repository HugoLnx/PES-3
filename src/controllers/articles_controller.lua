local ArticleDao = require('models/article_dao')
local Article = require('models/article')
local ArticleSerializer = require('models/article_serializer')
local view = require('view')

local M = {
  new = function(self, connection, app)
    local controller = {dao = ArticleDao:new(connection)}
    setmetatable(controller, {__index = self.metatable})
    return controller
  end,
}

M.metatable = {
  home = function(self, params)
    local articles = self.dao:all()
    
    return view.render("home.html.elua", {args = {
      articles = ArticleSerializer:serialize_many(articles),
    }})
  end,

  index = function(self, params)
    local articles = self.dao:all()
    
    return view.render("articles.html.elua", {args = {
      articles = ArticleSerializer:serialize_many(articles),
    }})
  end,

  create = function(self, params)
    local article = Article:new(params)
    article = self.dao:insert(article, params.document)
    
    return view.redirect_to("/articles.html")
  end,

  download = function(self, params)
    local article, file = self.dao:download(params.id)
    
    if article then
      return view.respond_with({
        status = 200,
        body = file,
        headers = {
          ["Content-Type"] = "application/octet-stream",
          ["Content-Disposition"] = "attachment;filename='"..article.title..".pdf'",
        },
      })
    else
      return view.respond_with({
        status = 404,
        body = '{"error" : "Not found"}',
        headers = {
          ["Content-Type"] = "application/json",
        },
      })
    end
  end,

  update = function(self, params)
    local article = self.dao:update(Article:new(params), params.document)
    if article then
      return view.redirect_to("/articles.html")
    else
      return view.render("not_found.html.elua", {status = 404})
    end
  end,

  destroy = function(self, params)
    if self.dao:delete(params.id) then
      return view.redirect_to("/articles.html")
    else
      return view.render("not_found.html.elua", {status = 404})
    end
  end,

  show = function(self, params)
    local article = self.dao:find(params.id)
    
    if article then
      return view.render("article.html.elua", {args = {
        article = ArticleSerializer:serialize_one(article)
      }})
    else
      return view.render("not_found.html.elua", {status = 404})
    end
  end,
}

return M
