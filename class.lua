local system = {};
local cache = {};
local singletons = {};

---@param name string
---@return BaseObject
function system.require(name)
    return cache[name];
end

---@param name string
---@return BaseObject
function system.singleton_require(name)
    return singletons[name];
end

---@param self BaseObject
function system.get_super_list(self)

    local list = {};

    local function recursive(_self)
        local metatable = getmetatable(_self);
        local super = metatable.__super;
        if (super) then
            table.insert(list, super);
            return recursive(super);
        end
        return list;
    end

    return recursive(self);

end

---@param class BaseObject
---@return BaseObject | nil
function system.super(class)
	local metatable = getmetatable(class);
	local metaSuper = metatable.__super;
	if (metaSuper) then
		return metaSuper;
	end
	return nil;
end

---@param class BaseObject
---@return table
function system.build(class)

    assert(class, "Attempt to build from an invalid class");

    local metatable = getmetatable(class);

    assert(metatable, "Attempt to build from an invalid class");
    assert(singletons[metatable.__name] == nil, "Attempt to build instance from a singleton");

    local super = system.super(class);

    return setmetatable({}, {
        __index = class;
        __super = super;
        __newindex = metatable.__newindex;
        --__call = metatable.__call; -- Remove because we don't want to create a new instance from another one.
        __len = metatable.__len;
        __unm = metatable.__unm;
        __add = metatable.__add;
        __sub = metatable.__sub;
        __mul = metatable.__mul;
        __div = metatable.__div;
        __pow = metatable.__pow;
        __concat = metatable.__concat;
        __type = metatable.__new_type;
        __name = metatable.__name;
        __super_called = 0;
    });

end

---@param class BaseObject
---@vararg
---@return BaseObject
function system.instance(class, ...)

	if (class) then

		local instance = system.build(class);

        local metatable = getmetatable(instance);
        local metasuper = getmetatable(metatable.__super);

		if (type(instance["Constructor"]) == "function") then

            local success, err = pcall(instance["Constructor"], instance, ...);

            if (not success) then
                console.err("^1Constructor of class ^7(^6" .. metatable.__name .. "^7)^1 has triggered an error^0: ^7(^6" .. err .. "^7)");
                return nil;
            end

            if (metasuper.__name ~= "BaseObject") then

                if (metatable.__super_called == 0) then
                    console.err("^1Constructor ^7(^6" .. metatable.__name .. "^7)^1 not called super().^0");
                    return nil;
                end

            end

        else
            console.err("^1Constructor ^7(^6" .. metatable.__name .. "^7)^1 not found.^0");
            return nil;
		end

		return instance;

	end

end

--- Callback optional
---@param name string
---@param fromClass string
---@param callback? fun(class: BaseObject): table
---@return BaseObject
function system.prepare(name, fromClass, callback)

    local _class = type(fromClass) == "string" and cache[fromClass] or fromClass;

    assert(_class, "Attempt to extends from an invalid class");
    assert(singletons[name] == nil, "Attempt to extends from a singleton");

    local tbl = type(callback) == "function" and callback({}) or {};
    local metatable = getmetatable(_class);

    cache[name] = setmetatable(tbl, {
        __index = _class;
        __super = _class;
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
        __type = "class";
        __new_type = "instance";
        __name = name;
    });

    return cache[name];

end

--- Callback required
---@param name string
---@param callback fun(class: BaseObject): table
---@vararg any
---@return BaseObject
function system.singleton(name, callback, ...)

    local metatable = getmetatable(cache["BaseObject"]);
    assert(callback, "Attempt to create a singleton without callback");

    cache[name] = setmetatable(callback({}), {
        __index = cache["BaseObject"];
        __super = cache["BaseObject"];
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
        __type = "class";
        __new_type = "singleton";
        __name = name;
    });

    singletons[name] = cache[name](...);

    return singletons[name];

end

--- Callback optional
---@param name string
---@param callback fun(class: BaseObject): table
---@return BaseObject
function system.new(name, callback)
	return system.prepare(name, cache["BaseObject"], callback);
end

--- Callback optional
---@param name string
---@param fromClass string | BaseObject
---@param callback fun(class: BaseObject): table
---@return BaseObject
function system.extends(name, fromClass, callback)
    return system.prepare(name, fromClass, callback);
end

--CLASS

---@class Class
Class = {};

Class.extends = system.extends;
Class.singleton = system.singleton;
Class.new = system.new;
Class.require = system.require;
Class.singleton_require = system.singleton_require;

---@param var any
---@return boolean
function Class.HasMetatable(var)
    return type(var) == "table" and type(getmetatable(var)) == "table";
end

---@param var any
---@return table | nil
function Class.GetMetatable(var)
    return Class.HasMetatable(var) and getmetatable(var) or nil;
end

---@param var any
---@return string | nil
function Class.GetName(var)
    local metatable = Class.GetMetatable(var);
    return metatable and metatable.__name or nil;
end

---@param var any
---@return boolean
function Class.IsValid(var)
    local metatable = Class.GetMetatable(var);
    return metatable and metatable.__type == "class" or false;
end

---@param var any
---@return boolean
function Class.IsInstance(var)
    local metatable = Class.GetMetatable(var);
    return metatable and metatable.__type == "instance" or false;
end

---@param var any
---@param class BaseObject | string
---@return boolean
function Class.IsInstanceOf(var, class)

    local _class = type(class) == "string" and Class.require(class) or class;
    if (Class.IsInstance(var)) then
        return var:IsInstanceOf(Class.GetName(_class));
    end

    return false;

end

---@param var any
---@return boolean
function Class.IsSingleton(var)
    local metatable = Class.GetMetatable(var);
    return metatable and metatable.__type == "singleton" or false;
end

--BASE OBJECT

---@class BaseObject
---@field private Constructor fun(): BaseObject
local BaseObject = setmetatable({}, {
    __name = "BaseObject";
    __type = "class";
    __call = function(self, ...)
        return self:new(...);
    end
});

---@private
---@return BaseObject
function BaseObject:new(...)
    return system.instance(self, ...);
end

---@return string
function BaseObject:ToString()
    return tostring(self);
end

---@vararg any
function BaseObject:super(...)

    local metatable = getmetatable(self);
    local list = system.get_super_list(self);
    metatable.__super_called = metatable.__super_called + 1;
    local class = list[metatable.__super_called];

    assert(class, "BaseObject:super(): Class not found");

    if (type(class["Constructor"]) == "function") then
        return class["Constructor"](self, ...);
    end

    return nil;

end

---@private
---@param parentClass? BaseObject
---@param methodName string
---@vararg any
---@return any
function BaseObject:CallParentMethod(methodName, ...)

    local metatable = getmetatable(self);
    local class = metatable.__super;
    assert(class, "BaseObject:CallParentMethod(): Class not found");

    if (type(class[methodName]) == "function") then
        return class[methodName](self, ...);
    end

    return nil;

end

---@private
---@param key string
---@param value any
function BaseObject:SetValue(key, value)
    if (string.sub(key, 1, 2) ~= "__") then
        self[key] = value;
    end
end

---@private
---@param key string
---@return any
function BaseObject:GetValue(key)
    if (string.sub(key, 1, 2) ~= "__") then
        return self[key];
    end
end

---@param class_name string | BaseObject
---@return boolean
function BaseObject:IsInstanceOf(class_name)

    local _class = type(class_name) == "string" and cache[class_name] or class_name;

    if(type(_class) ~= "table") then return false; end
    local class_metatable = cache[class_name]:GetMetatable();

    local _class_name = class_metatable and class_metatable.__name or nil;
    if (not _class_name) then return false; end

    local metatable = self:GetMetatable();
    return class_name == metatable.__name or false;

end

---@private
---@return table
function BaseObject:GetMetatable()
    return getmetatable(self);
end

cache["BaseObject"] = BaseObject;