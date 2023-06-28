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
---@class ARandomClass: BaseObject
---@overload fun(name: string, some_variable: string): ARandomClass
local ARandomClass = Class.new "ARandomClass";

function ARandomClass:Constructor(name, some_variable)
    self.name = name;
    self.some_variable = some_variable;
end

function ARandomClass:PrintName(...)
    print(self, self.name, self.some_variable, ...);
end

--You can require a class like this:
local ARandomClass_required = Class.require 'ARandomClass';

--or you can also do like this: local ARandomChildClass = Class.extends
---@class ARandomChildClass: ARandomClass
---@overload fun(name: string, some_variable: string, some_other_variable: string): ARandomChildClass
local ARandomChildClass = Class.extends ( "ARandomChildClass", ARandomClass_required );

function ARandomChildClass:Constructor(name, some_variable, some_other_variable)
    self:super(ARandomClass, name, some_variable);
    self.some_other_variable = some_other_variable;
end

function ARandomChildClass:PrintName()
    print("Overwriting PrintName method but without breaking it", self.some_other_variable);
    self:CallParentMethod(ARandomClass, "PrintName", "Hello From children");
end

local instance = ARandomChildClass("Hello", "World", "Test");

print(("Testing object [ name: %s, Is instance of: %s ]"):format(instance, instance:IsInstanceOf 'ARandomChildClass'));

instance:PrintName();