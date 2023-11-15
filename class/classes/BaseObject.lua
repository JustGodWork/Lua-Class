local meta = require 'modules.system.class.meta';
local utils = require 'modules.system.class.utils';
local builder = require 'modules.system.class.builder';

---@class BaseObject
---@field private Constructor fun(): BaseObject
local BaseObject = setmetatable({}, {
	__version = 2.1;
    __name = 'BaseObject';
    __type = 'class';
    __call = function(self, ...)
        return builder.new_instance(self, ...);
    end
});

---@vararg any
function BaseObject.super(self, ...)

    local metatable = self:GetMeta().table();
    local list = utils.get_super_list(self);
	local constructor_called = meta.metatable.get_key(self, "__constructor_called");

    constructor_called += 1;

    local class = list[constructor_called];

    assert(class, "BaseObject:super(): Class not found");
    meta.metatable.set_key(self, "__constructor_called", constructor_called);

	local constructor = rawget(class, "Constructor");
    if (type(constructor) == "function") then
        return constructor(self, ...);
    end

    return nil;

end

---@return string
function BaseObject.GetType(self)
    return typeof(self);
end

---@return string
function BaseObject.ToString(self)
    return tostring(self);
end

---@private
---@param parentClass? BaseObject
---@param methodName string
---@vararg any
---@return any
function BaseObject.CallParentMethod(self, methodName, ...)

    local super = utils.get_super(self);
    assert(is_table(super), "BaseObject:CallParentMethod(): Class not found");

	local method = rawget(super, methodName);
    if (type(method) == "function") then
        return method(self, ...);
    end

    return nil;

end

---@param class string | BaseObject
---@return boolean
function BaseObject.IsInstanceOf(self, class)
	local _class = is_string(class) and builder.get(class) or class;
	if (is_class(class)) then
		return typeof(self) == meta.metatable.get_key(_class, "name");
	end
	return false;
end

---@class BaseObjectMetaGetter
---@field private instance BaseObject
---@field public table fun(key: string): class_metatable | any
---@field public metadata fun(key?: string): any
---@overload fun(): BaseObjectMetaGetter
local meta_get = setmetatable({}, {
    __call = function (self, obj)
        local mt = getmetatable(self);
        local instance = setmetatable({}, {__index = mt.__index});
        instance.instance = obj;
        return instance;
    end;
    __index = function(self, k)
        if (k == 'metadata') then
            return function(key)
                if (not key) then
                    return meta.metatable.get_metadata(self.instance:GetMeta().table());
                end
                return meta.metadata.get_key(self.instance, key);
            end;
        elseif (k == 'table') then
            return function(key)
                if (not key) then
                    return meta.metatable.get(self.instance);
                end
                return meta.metatable.get_key(self.instance, key);
            end
        end
    end;
});

---@private
---@return BaseObjectMetaGetter
function BaseObject.GetMeta(self)
    return meta_get(self);
end

---@class BaseObjectMetaSetter
---@field private instance BaseObject
---@field public table fun(key: string, value: any): BaseObjectMetaSetter
---@field public metadata fun(key: string, value: any): BaseObjectMetaSetter
local meta_set = setmetatable({}, {
    __call = function (self, obj)
        local mt = getmetatable(self);
        local instance = setmetatable({}, {__index = mt.__index});
        instance.instance = obj;
        return instance;
    end;
    __index = function(self, k)
        if (k == 'metadata') then
            return function(key, value)
                meta.metadata.set_key(self.instance, key, value);
                return self;
            end;
        elseif (k == 'table') then
            return function(key, value)
                meta.metatable.set_key(self.instance, key, value);
                return self;
            end
        end
    end;
});

---@private
---@return BaseObjectMetaSetter
function BaseObject.SetMeta(self)
    return meta_set(self);
end

---@private
---@param name string
function BaseObject.SetToString(self, name)
    self:SetMeta().table("__tostring", function()
        return name;
    end);
    return self;
end

return BaseObject;