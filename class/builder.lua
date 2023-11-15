local utils = require 'modules.system.class.utils';
local builder = {};
local classes = {};

---@param type string
---@param metatable class_metatable
---@param index BaseObject
---@param super fun(self: BaseObject, ...)
---@param name string
---@param super_name string
---@return class_metatable
local function create_metatable(type, metatable, index, super, name, super_name)
	return setmetatable({}, {
        __index = index;
        __newindex = metatable.__newindex;
        __call = metatable.__call;
        __len = metatable.__len;
        __unm = metatable.__unm;
        __add = metatable.__add;
        __sub = metatable.__sub;
        __mul = metatable.__mul;
        __div = metatable.__div;
        __pow = metatable.__pow;
        __concat = metatable.__concat;
		__super = super;
		__super_name = super_name;
		__name = name;
		__type = type;
		__constructor_called = 0;
		__metadata = {};
    });
end

---@param name string
---@param class BaseObject | string
function builder.prepare_metatable(name, class)
	local _class = is_string(class) and classes[class] or class;
	assert(is_class(_class), ("prepare_metatable(): attempt to index a (%s) value field 'class'"):format(type(_class)));
	local class_mt = getmetatable(_class);
	classes[name] = create_metatable(
		'class',
		class_mt,
		_class,
		_class,
		name,
		class_mt.__name
	);
	return classes[name];
end

---@param class BaseObject
---@param metatable table
---@return BaseObject, BaseObject
local function build_instance(class, metatable)
	local super = metatable.__super;
	local super_mt = getmetatable(super);
	return create_metatable(
		'instance',
		metatable,
		class,
		super,
		metatable.__name,
		super_mt.__name
	), super;
end

---@param class BaseObject
---@vararg any
function builder.new_instance(class, ...)
	assert(is_table(class), ("new_instance(): attempt to index a (%s) value field 'class'"):format(type(class)));

    local class_mt = getmetatable(class);

    assert(is_table(class_mt), "Attempt to build from an invalid class");

	local instance, super = build_instance(class, class_mt);
	local constructor = rawget(class, 'Constructor');

	if (is_function(constructor)) then
		constructor(instance, ...);
	end

	local super_mt = getmetatable(super);
	local instance_mt = getmetatable(instance);

	if (super_mt.__name ~= 'BaseObject') then
		local superList = utils.get_super_list(instance);
		if (instance_mt.__constructor_called ~= #superList - 1) then
			error('instance of ' .. class_mt.__name .. ' has not called super()');
		end
	end
    return instance;
end

---@param name string
---@return BaseObject
function builder.get(name)
	return classes[name];
end

---@param name string
---@param value BaseObject
function builder.add(name, value)
	assert(is_string(name), ("add(): attempt to index a (%s) value field 'name'"):format(type(name)));
	assert(is_table(value), ("add(): attempt to index a (%s) value field 'value'"):format(type(value)));
	assert(not classes[name], ("add(): Class (%s) already registered."):format(type(name)));
	classes[name] = value;
end

return builder;