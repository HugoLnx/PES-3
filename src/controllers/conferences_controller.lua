--[[  conferences_controller Módulo
modulo responsible for being the conference controller

it has the functions:
index: Indexa a conferência
create: Cria uma conferência
update: Atualiza uma conferência
destroy: Deleta uma conferência
show: Mostra uma conferência

]]

local ConferenceDao = require('models/conference_dao')
local Conference = require('models/conference')
local ConferenceSerializer = require('models/conference_serializer')
local utils = require 'utils'
local view = require('view')

local M = {
  new = function(self, connection, app)
    local controller = {dao = ConferenceDao:new(connection)}
    setmetatable(controller, {__index = self.metatable})
    return controller
  end,
}

M.metatable = {
  index = function(self, params)
    local conferences = self.dao:all(params.query)

    return view.render("conferences.html.elua", {args = {
      conferences = ConferenceSerializer:serialize_many(conferences),
      query = params.query,
    }})
  end,

  create = function(self, params)
    params.editors = utils.split(params.editors, "[^,]+")

    local conference = Conference:new(params)
    conference = self.dao:insert(conference)

    return view.redirect_to("/conferences.html")
  end,

  update = function(self, params)
    local conference = self.dao:update(Conference:new(params))
    if conference then
      return view.redirect_to("/conferences.html")
    else
      return view.render("not_found.html.elua", {status = 404})
    end
  end,

  destroy = function(self, params)
    if self.dao:delete(params.id) then
      return view.redirect_to("/conferences.html")
    else
      return view.render("not_found.html.elua", {status = 404})
    end
  end,

  show = function(self, params)
    local conference = self.dao:find(params.id)

    if conference then
      return view.render("conference.html.elua", {args = {
        conference = ConferenceSerializer:serialize_one(conference)
      }})
    else
      return view.render("not_found.html.elua", {status = 404})
    end
  end,
}

return M
