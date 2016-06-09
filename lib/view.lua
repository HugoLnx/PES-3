local template = require "resty.template"
local utils = require "utils"
local path = require "pl.path"

local RENDER_DEFAULT_PARAMS = {
  status = 200,
  headers = {["Content-Type"] = "text/html"},
}

M = {}

M.respond_with = function(params)
  return params
end

M.render = function(view_path, params)
  local params = params or {}
  local view = template.new(path.join("views", view_path), path.join("views", "layout.html.elua"))
  utils.copy_to(params.args or {}, view)
  params.args = nil
  return M.respond_with(utils.merge(RENDER_DEFAULT_PARAMS, params, {body = tostring(view)}))
end

M.redirect_to = function(path, params)
  return M.respond_with({redirect_to = path})
end

return M
