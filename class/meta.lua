local metatable, metadata = {}, {};

---@param var
---@return class_metatable | nil
function metatable.get(var)
	local mt = getmetatable(var);
	return is_table(mt) and mt;
end

---@param mt table
---@return class_metadata | nil
function metatable.get_metadata(mt)
	assert(is_table(mt), ("metatable.get_metadata: attempt to index a (%s) value field mt"):format(type(mt)));
	return is_table(mt.__metadata) and mt.__metadata;
end

---@param var any
---@param key string
---@return any
function metatable.get_key(var, key)
	assert(is_table(var), ("metatable.get_key: attempt to index a (%s) value field var"):format(type(var)));
	local metatable = metatable.get(var);
	return metatable and metatable[key];
end

---@param var any
---@param key string
---@param value any
---@return boolean
function metatable.set_key(var, key, value)
	assert(is_table(var), ("metatable.set_key: attempt to index a (%s) value field var"):format(type(var)));
	local metatable = metatable.get(var);
	if (metatable) then
		metatable[key] = value;
		return true;
	end
	return false;
end

---@param key string
---@return any
function metadata.get_key(var, key)
	local mt = metatable.get(var);
	if (is_table(mt)) then
		local metadata = metatable.get_metadata(mt);
		return is_table(metadata) and metadata[key];
	end
	return nil;
end

---@param var
---@param key string
---@return boolean
function metadata.set_key(var, key, value)
	assert(is_table(var), ("metadata.set_key: attempt to index a (%s) value field var"):format(type(var)));
	local mt = metatable.get(var);
	if (is_table(mt)) then
		local metadata = metatable.get_metadata(mt);
		metadata[key] = value;
		return true;
	end
	return false;
end

return {
	metatable = metatable,
	metadata = metadata
}