---@param self BaseObject
---@return BaseObject[]
local function get_super_list(self)

	local list = {};

	---@param _self BaseObject
	local function search_recursive(_self)
		local metatable = getmetatable(_self);
		local super = metatable.__super;
		if (is_table(super)) then
			list[#list + 1] = super;
			return search_recursive(super);
		end
		return list;
	end

	return search_recursive(self);

end

---@param self BaseObject
---@return BaseObject | nil
function get_super(self)
	local metatable = getmetatable(self);
	local super = metatable.__super;
	if (is_table(super)) then
		return super;
	end
end

return {
	get_super_list = get_super_list,
	get_super = get_super
};