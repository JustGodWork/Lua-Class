--[[
----
----Created Date: 11:32 Tuesday May 2nd 2023
----Author: JustGod
----Made with ❤
----
----File: [Index]
----
----Copyright (c) 2023 JustGodWork, All Rights Reserved.
----This file is part of JustGodWork project.
----Unauthorized using, copying, modifying and/or distributing of this file
----via any medium is strictly prohibited. This code is confidential.
----
--]]

local cache = {};

---@class BaseObject
---@field private Constructor fun(): BaseObject
---@field private super fun(class: string, ...: any): BaseObject

BaseObject = setmetatable({}, {
    __name = "BaseObject";
    __type = "class";
    __call = function(self, ...)
        return self:new(...);
    end
});

cache["BaseObject"] = BaseObject;

---@param name string
---@return BaseObject
local function require_class(name)
    return cache[name];
end

---@param class BaseObject
---@return BaseObject | nil
local function class_super(class)
	local metatable = getmetatable(class);
	local metaSuper = metatable.__super;
	if (metaSuper) then
		return metaSuper;
	end
	return nil;
end

---@param class BaseObject
---@return table
local function class_build(class)
	
    assert(class, "Attempt to build from an invalid class");

    local metatable = getmetatable(class);
    assert(metatable, "Attempt to build from an invalid class");

    local super = class_super(class);

    return setmetatable({}, {
        __index = class;
        __super = super;
        __newindex = metatable.__newindex;
        --__call = metatable.__call; -- Remove because we don't want to create a new instance from an instance
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
        __tostring = metatable.__tostring;
    });

end

---@param class BaseObject
---@vararg
---@return BaseObject
local function class_instance(class, ...)

	if (class) then

		local instance = class_build(class);

		if (type(class["Constructor"]) == "function") then

			local constructor = class["Constructor"](instance, ...);

			if (type(constructor) == "table") then
				return constructor;
			end

		end

		return instance;

	end

end

---@param name string
---@param fromClass string
---@param callback fun(class: BaseObject): BaseObject
local function class_prepare(name, fromClass, callback)

    assert(fromClass, "Attempt to extends from an invalid class");

    local metatable = getmetatable(fromClass);
    local extend = callback({});

    assert(extend, "Attempt to extends but no class has been returned.");

    setmetatable(extend, {
        __index = fromClass;
        __super = fromClass;
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
        __tostring = function()
            return name;
        end;
    });

    cache[name] = extend;

    return cache[name];

end

---@param name string
---@param callback fun(class: BaseObject): BaseObject
---@return BaseObject
local function class_singleton(name, callback)

    local metatable = getmetatable(BaseObject);
    local singleton = callback({});

    assert(singleton, "Attempt to make a singleton but no class has been returned.");

    setmetatable(singleton, {
        __index = BaseObject;
        __super = BaseObject;
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
        __tostring = function()
            return name;
        end;
    });

    cache[name] = singleton();

    return cache[name];

end

---@param name string
---@param callback fun(class: BaseObject): BaseObject
local function class_new(name, callback)
	return class_prepare(name, BaseObject, callback);
end

---@param name string
---@param callback fun(class: BaseObject): BaseObject
local function class_extends(name, fromClass, callback)
    return class_prepare(name, fromClass, callback);
end

---@class Class
---@field extends fun(name: string, fromClass: BaseObject, callback: fun(class: BaseObject): BaseObject): BaseObject
---@field singleton fun(name: string, callback: fun(class: BaseObject): BaseObject): BaseObject
---@field new fun(name: string, callback: fun(class: BaseObject): BaseObject): BaseObject
---@field instance fun(class: BaseObject, varargs: any): BaseObject
---@field require fun(name: string): BaseObject
Class = {};
Class.extends = class_extends;
Class.singleton = class_singleton;
Class.new = class_new;
Class.require = require_class;

--BASE OBJECT

---@private
---@return BaseObject
function BaseObject:new(...)
    return class_instance(self, ...);
end

---@param class? BaseObject
---@vararg any
function BaseObject:super(class, ...)

    local metatable = getmetatable(self);
    local _class = metatable.__super;

    if (type(class) == "table") then _class = class; end

    assert(_class, "BaseObject:super(): Class not found");

    if (type(_class["Constructor"]) == "function") then
        return _class["Constructor"](self, ...);
    end

    return nil;

end

---@private
---@param parentClass? BaseObject
---@param methodName string
---@vararg any
---@return any
function BaseObject:CallParentMethod(parentClass, methodName, ...)

    local metatable = getmetatable(self);
    local _class = metatable.__super;

    if (type(parentClass) == "table") then _class = parentClass; end
    assert(_class, "BaseObject:CallParentMethod(): Class not found");

    if (type(_class[methodName]) == "function") then
        return _class[methodName](self, ...);
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

---@param class_name string
---@return boolean
function BaseObject:IsInstanceOf(class_name)

    if(type(cache[class_name]) ~= "table") then return false; end
    local class_metatable = cache[class_name]:GetMetatable();

    local class_name = class_metatable and class_metatable.__name or nil;
    if (not class_name) then return false; end

    local metatable = getmetatable(self);
    local name = metatable and metatable.__name or nil;

    return name ~= nil and class_name == name or false;

end

---@private
---@return table
function BaseObject:GetMetatable()
    return getmetatable(self);
end

--RETURN STATEMENT

-- if you want to export it using require uncomment this
--return Class;