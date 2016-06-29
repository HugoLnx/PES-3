local DocumentParser = require('models/document_parser')
local view = require('view')

local M = {
  new = function(self, connection, app)
    local controller = {}
    setmetatable(controller, {__index = self.metatable})
    return controller
  end,
}

M.metatable = {
  read = function(self, params)
    local text = DocumentParser:get_text(params.document.path)

    return view.render_json{raw = text}
  end
}

return M
