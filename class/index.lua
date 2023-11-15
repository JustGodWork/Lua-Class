local BaseObject = require 'modules.system.class.classes.BaseObject';
require 'modules.system.class.types';

local builder = require 'modules.system.class.builder';
builder.add("BaseObject", BaseObject);

---@class Class
Class = {};

---@param var any
---@return boolean
function Class.hasMetatable(var)
    return is_class(var) or is_instance(var) and getmetatable(var);
end

---@param var any
---@return table | nil
function Class.getMetatable(var)
    return Class.hasMetatable(var) and getmetatable(var);
end

---@param var any
---@return string | nil
function Class.getName(var)
    local mt = Class.getMetatable(var);
    return is_table(mt) and mt.__name;
end

---@param var any
---@return boolean
function Class.isValid(var)
    local metatable = Class.getMetatable(var);
    return metatable and metatable.__type == "class" or false;
end

---@param var any
---@return boolean
function Class.isInstance(var)
    local metatable = Class.getMetatable(var);
    return metatable and metatable.__type == "instance" or false;
end

---@param var any
---@param class BaseObject | string
---@return boolean
function Class.isInstanceOf(var, class)

    local _class = type(class) == "string" and Class.get(class) or class;

    if (Class.isInstance(var)) then
        return var:IsInstanceOf(Class.getName(_class));
    end

    return false;

end

---@param var any
---@return boolean
function Class.isSingleton(var)
    local metatable = Class.getMetatable(var);
    return metatable and metatable.__type == "singleton" or false;
end

---@class new
---@field public extends fun(name: string, class: BaseObject): BaseObject
---@overload fun(name: string): BaseObject
Class.new = setmetatable({}, {
    __call = function(_, name)
        return builder.prepare_metatable(name, builder.get("BaseObject"));
    end,
    __index = function(_, key)
        if (key == 'extends') then
            return builder.prepare_metatable;
        end
        error("Class.new: Invalid method '" .. key .. "'");
    end,
    __newindex = function(_, key)
        error(("Class.new.%s: Not allowed to add new methods"):format(key));
    end
});

---@param name string
---@return BaseObject
function Class.get(name)
    return builder.get(name);
end

return Class;