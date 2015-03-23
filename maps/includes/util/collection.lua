-- backwards compatibility for the Collection class

local Class = require "util.class"

local function setup_items_key(self)
	-- keep a usable reference to the base metatable
	local real_obj = setmetatable({}, getmetatable(self))
	-- add special handling of the items key
	setmetatable(self, {
		-- the items key returns an iterator
		__index = function(t, k)
			if k == "items" then
				local i = 0
				local n = self:Count()
				return function()
					i = i + 1
					if i <= n then return self.entities[i] end
				end
			end
			return real_obj[k]
		end,
		-- protect the items key from being assigned
		__newindex = function(t, k, v)
			if k == "items" then
				return
			end
			real_obj[k] = v
		end
	})
end

local Collection = Class(function(self)
	setup_items_key(self)
	self.entities = {}
end)


local function get_param_as_table(param)
	if param == nil then return {} end
	if type(param) == "table" then return param end
	return {param}
end

-- lua tables start at index 1
local function to_lua_index(collection_index)
	return collection_index+1
end

-- Collection started at index 0
local function to_collection_index(lua_index)
	return lua_index-1
end

function Collection:AddItem(entity_or_entities)
	local entities_to_add = get_param_as_table(entity_or_entities)

	for i,entity_to_add in ipairs(entities_to_add) do
		table.insert(self.entities, entity_to_add)
	end
end

function Collection:RemoveItem(entity_or_entities)
	local entities_to_find = get_param_as_table(entity_or_entities)

	for i,entity_to_find in ipairs(entities_to_find) do
		local i = self:FindItemIndex(entity_to_find)
		if i then
			table.remove(self.entities, to_lua_index(i))
		end
	end
end

function Collection:RemoveAllItems()
	for k in ipairs(self.entities) do
		self.entities[k] = nil
	end
end

function Collection:Count()
	return #self.entities
end

function Collection:HasItem(entity_or_entities)
	local entities_to_find = get_param_as_table(entity_or_entities)

	for i,entity_to_find in ipairs(entities_to_find) do
		if self:FindItemIndex(entity_to_find) then
			return true
		end
	end
	return false
end

-- this is a strange function
function Collection:GetItem(entity_or_entities)
	local entities_to_find = get_param_as_table(entity_or_entities)

	for i,entity_to_find in ipairs(entities_to_find) do
		local i = self:FindItemIndex(entity_to_find)
		if i then
			return self:Element(i)
		end
	end
end

function Collection:FindItemIndex(entity_to_find)
	for i,entity in ipairs(self.entities) do
		if entity:GetId() == entity_to_find:GetId() then
			return to_collection_index(i)
		end
	end
	return nil
end

function Collection:Element(i)
	return self.entities[to_lua_index(i)]
end

return Collection