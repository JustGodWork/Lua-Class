--[[
----
----Created Date: 2:11 Tuesday May 2nd 2023
----Author: JustGod
----Made with ❤
----
----File: [example]
----
----Copyright (c) 2023 JustGodWork, All Rights Reserved.
----This file is part of JustGodWork project.
----
--]]

---You can set a variable to a class or just Class.require 'ClassName'
Class.new("ARandomClass", function(class)

    ---@class ARandomClass: BaseObject
    local self = class;

    function self:Constructor(name, some_variable)
        self.name = name;
        self.some_variable = some_variable;
    end

    function self:PrintName(...)
        print(self, self.name, self.some_variable, ...);
    end

    return self;

end);

--You can require a class like this:
local ARandomClass = Class.require 'ARandomClass';

--or you can also do like this: local ARandomChildClass = Class.extends 
local ARandomChildClass = Class.extends("ARandomChildClass", ARandomClass, function(class)

    ---@class ARandomChildClass: ARandomClass
    local self = class;

    function self:Constructor(name, some_variable, some_other_variable)
        self:super(ARandomClass, name, some_variable);
        self.some_other_variable = some_other_variable;
    end

    function self:PrintName()
        print("Overwriting PrintName method but without breaking it", self.some_other_variable);
        self:CallParentMethod(ARandomClass, "PrintName", "Hello From children");
    end

    return self;

end);

local instance = ARandomChildClass("Hello", "World", "Test");

print(("Testing object [ name: %s, Is instance of: %s ]"):format(instance, instance:IsInstanceOf 'ARandomChildClass'));

instance:PrintName();