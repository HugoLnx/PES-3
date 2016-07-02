--[[
Módulo responsável por ser o controlador da rota principal (raiz)

Possui as seguintes funções:
home: instancia os DAOs de artigos e conferências e exibe retorna uma página exibindo ambos

]]

local ArticleDao = require('models/article_dao')
local Article = require('models/article')
local ArticleSerializer = require('models/article_serializer')
local ConferenceDao = require('models/conference_dao')
local Conference = require('models/conference')
local ConferenceSerializer = require('models/conference_serializer')
local Authentication = require('models/authentication')
local utils = require 'utils'
local view = require('view')

local M = {
  new = function(self, connection)
    local controller = {
      article_dao = ArticleDao:new(connection),
      conference_dao = ConferenceDao:new(connection)
    }
    setmetatable(controller, {__index = self.metatable})
    return controller
  end,
}

M.metatable = {
  --[[
  Responsabilidade: Método para a rota principal do site (exibe conferências e artigos)
  Pré-Condição: * Deve receber parametros da rota
  Pós-Condição: * Retorna a página html renderizada
  ]]
  home = function(self, params)
    local articles = self.article_dao:all()
    local conferences = self.conference_dao:all()
    local auth = Authentication:new(params.cookie)

    return view.render("home.html.elua", {args = {
      articles = ArticleSerializer:serialize_many(articles),
      conferences = ConferenceSerializer:serialize_many(conferences),
        is_admin = auth:is_signedin(),
    }})
  end
}

return M
