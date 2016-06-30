--[[  home_controller Modulo
this is the modulo responsible for being the controller of the home page

this modulo creates the DAO of the articles and conference and serializes them
]]
local ArticleDao = require('models/article_dao')
local Article = require('models/article')
local ArticleSerializer = require('models/article_serializer')
local ConferenceDao = require('models/conference_dao')
local Conference = require('models/conference')
local ConferenceSerializer = require('models/conference_serializer')
local utils = require 'utils'
local view = require('view')

local M = {
  new = function(self, connection, app)
    local controller = {
      article_dao = ArticleDao:new(connection),
      conference_dao = ConferenceDao:new(connection)
    }
    setmetatable(controller, {__index = self.metatable})
    return controller
  end,
}

M.metatable = {
  home = function(self, params)
    local articles = self.article_dao:all()
    local conferences = self.conference_dao:all()

    return view.render("home.html.elua", {args = {
      articles = ArticleSerializer:serialize_many(articles),
      conferences = ConferenceSerializer:serialize_many(conferences),
    }})
  end
}

return M
