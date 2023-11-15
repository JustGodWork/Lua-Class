---@class class_metadata

---@class class_metatable
---@field index BaseObject
---@field newIndex fun(self: BaseObject, key: string, value: any)
---@field call fun(self: BaseObject, ...)
---@field len fun(self: BaseObject)
---@field unm fun(self: BaseObject)
---@field add fun(self: BaseObject, other: BaseObject)
---@field sub fun(self: BaseObject, other: BaseObject)
---@field mul fun(self: BaseObject, other: BaseObject)
---@field div fun(self: BaseObject, other: BaseObject)
---@field pow fun(self: BaseObject, other: BaseObject)
---@field concat fun(self: BaseObject, other: BaseObject)
---@field super fun(self: BaseObject, ...)
---@field metadata class_metadata

---@alias type
---| '"table"'
---| '"userdata"'
---| '"string"'
---| '"number"'
---| '"boolean"'
---| '"function"'
---| '"class"'
---| '"instance"'

local meta = require 'modules.system.class.meta';
local _type = _G["type"];

---@param var
---@return boolean
function is_table(var)
	return _type(var) == "table";
end

---@param var
---@return boolean
local function is_userdata(var)
	return _type(var) == "userdata";
end

---@param var
---@return boolean
function is_string(var)
	return _type(var) == "string";
end

---@param var
---@return boolean
function is_number(var)
	return _type(var) == "number"
		or _type(var) == "string" and tonumber(var) ~= nil;
end

---@param var
---@return boolean
function is_boolean(var)
	return _type(var) == "boolean";
end

---@param var
---@return boolean
function is_cfx_export_function(var)
	return is_table(var) and is_userdata(var.__cfx_functionReference);
end

---@param var
---@return boolean
function is_function(var)
	return _type(var) == "function" or is_cfx_export_function(var);
end

---@param var
---@param type type
---@return boolean
local function is_metatype_valid(var, type)
	local mt = meta.metatable.get(var);
	return is_table(mt) and mt.__type == type;
end

---@param var
---@return boolean
function is_class(var)
	return is_metatype_valid(var, "class");
end

---@param var
---@return boolean
function is_instance(var)
	return is_metatype_valid(var, "instance");
end

---@param var any
---@return type
function type(var)
	local _type = _type(var);
	if (is_table(var)) then
		local mt = meta.metatable.get(var);
		return is_table(mt) and mt.__type or _type;
	end
	return _type;
end

---@param var any
---@return string | nil
function typeof(var)
	return type(var) == "instance" and meta.metatable.get_key(var, '__name');
end