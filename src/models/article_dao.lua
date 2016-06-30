--[[article DAO modulos
This modulo has the functions about the article DAO's(Data acess Object)
]]
local Article = require "models/article"
local DocumentParser = require "models/document_parser"
local utils = require "utils"
local app = require "app"
local path = require "pl.path"
local file = require "pl.file"
local plutils = require "pl.utils"
local ConferenceDAO = require("models/conference_dao")
local ObjectId = require("mongorover.luaBSONObjects").ObjectId

local M = {
  new = function(self, connection)
    local dao = {
      connection = connection,
      conferenceDao = ConferenceDAO:new(connection),
    }
    setmetatable(dao, {__index = self.metatable})
    return dao
  end,
}

M.metatable = {
  insert = function(self, article, uploaded_document)
    if not article or not uploaded_document then error() end
    
    article.document_text = DocumentParser:get_text(uploaded_document.path)
    local result = self:__collection():insert_one(utils.merge(article:data(), self:__extra_data_for(article)))
    if result.acknowledged then
      local data = utils.merge(article:data(), {id = result.inserted_id.key})
      local article = Article:new(data)
      self:__move_uploaded_document(uploaded_document, article)
      return article
    else
      return nil
    end
  end,

  all = function(self, search_term)
    if search_term and search_term ~= "" then
      return self:__all{["$text"] = {["$search"] = search_term}}
    else
      return self:__all()
    end
  end,

  all_on_conference = function(self, conference_id)
    return self:__all{conference_id = conference_id}
  end,

  find = function(self, id)
    local id = self:__safe_object_id(id)
    if not id then return nil end
    return self:__build_article(self:__find_all({_id = id})[1])
  end,
  
  delete = function(self, id)
    local id = self:__safe_object_id(id)
    if not id then return nil end
    return self:__collection():delete_one({_id = id}).acknowledged
  end,
  
  update = function(self, article, uploaded_document)
    local data = utils.merge(article:data(), self:__extra_data_for(article))
    data.id = nil
    local id = self:__safe_object_id(article.id)
    if not id then return nil end
    local result = self:__collection():update_one({_id = id}, {["$set"] = data})
    
    if result.raw_result.nMatched > 0 then
      local article = self:find(article.id)
      self:__move_uploaded_document(uploaded_document, article)
      return article
    else
      return nil
    end
  end,

  download = function(self, id)
    local objId = self:__safe_object_id(id)
    if not objId then return nil end
    self:__collection():update_one({_id = objId}, {["$inc"] = {downloads = 1}})
    local article = self:find(id)
    local file = plutils.readfile(self:__document_abs_path(article), true)
    return article, file
  end,
  
  __all = function(self, query)
    local query = query or {}
    local articles = Article:build_all(self:__find_all(query))
    for i,article in ipairs(articles) do
      articles[i] = self:__build_article(article:data())
    end
    return articles
  end,
  
  __find_all = function(self, query)
    local query = query or {}
    return utils.map_iterator(self:__collection():find(query), function(article_data)
      article_data.id = article_data._id.key
      article_data._id = nil
      return article_data
    end)
  end,
  
  __move_uploaded_document = function(self, uploaded_document, article)
    if not uploaded_document then return end
    local destination_path = self:__document_abs_path(article)
    file.delete(destination_path)
    file.move(uploaded_document.path, destination_path)
  end,
  
  __document_abs_path = function(self, article)
    return path.join(app.root, "documents", article.id .. ".pdf")
  end,
  
  __collection = function(self)
    local database = self.connection:getDatabase("pes3")
    return database:getCollection("articles")
  end,
  
  __safe_object_id = function(self, id)
    local ok, ret_or_err = pcall(ObjectId.new, id)
    if ok then return ret_or_err else return nil end
  end,
  
  __extra_data_for = function(self, article)
    return {authors_text = table.concat(article.authors, " ")}
  end,
  
  __build_article = function(self, data)
    local article = Article:new(data)
    if article.conference_id then
      article.conference = self.conferenceDao:find(article.conference_id)
    end
    return article
    
  end
}

return M
