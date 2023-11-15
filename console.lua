---@class console
console = {};

-- Cache table.insert as local because it's faster
local table_insert = table.insert;
local _print = print;
local logTypes = {
    ["INFO"] = "^4INFO",
    ["WARN"] = "^3WARN",
    ["ERROR"] = "^1ERROR",
    ["DEBUG"] = "^6DEBUG",
    ["SUCCESS"] = "^2SUCCESS",
};

---@private
---@param obj any
---@return string
local function get_type_name(obj)
    local is_cls = is_class(obj);
    local is_cls_instance = is_instance(obj);
    local is_tbl = is_table(obj) and not is_cls and not is_cls_instance;

    local cls_name = not is_tbl and Class.getName(obj);
    local name = not is_tbl and is_boolean(cls_name) and tostring(cls_name) or cls_name;

    return is_tbl and 'table'
        or is_cls and ('class \'%s\''):format(name)
        or is_cls_instance and ('instance of \'%s\''):format(name);
end

---@private
---@param tbl table
---@param show_metatable boolean
local function dump_table(tbl, show_metatable)
    local data, buffer = {}, {};

    local function dump_table_recursive(object, indentation, show_meta)
        local object_type = type(object);

        if (is_table(object) and not data[object]) then
            local object_metatable = getmetatable(object);

            if (object_metatable and show_meta) then
                dump_table_recursive(object_metatable, indentation, show_meta);
            end

            data[object] = true;

            local keys = {};

            for key in pairs(object) do
                table_insert(keys, key);
            end

            table.sort(keys, function(a, b)
                if type(a) == "number" and type(b) == "number" then
                    return a < b
                else
                    return tostring(a) < tostring(b);
                end
            end)

            indentation = indentation + 1
            local name = get_type_name(object);

            table_insert(buffer, indentation == 1 and "\n^7" .. name .. " -> {^0" or "^7" .. name .. " -> {^0");
            for _, key in ipairs(keys) do
                local formatted_key = type(key) == "number" and tostring(key) or '^7"^5' .. tostring(key) .. '^7"^0';

                table_insert(buffer, "\n" .. string.rep(" ", indentation * 4) .. formatted_key .. " = ");
                dump_table_recursive(object[key], indentation, show_meta);
                table_insert(buffer, ",");
            end
            indentation = indentation - 1
            table_insert(buffer, "\n" .. string.rep(" ", indentation * 4) .. "^7}^0");
        else
            local obj = tostring(object);
            local obj_msg = "";

            if (object_type == "string") then
                obj_msg = '^7"^3' .. obj .. '^7"^0';
            elseif (object_type == "number") then
                obj_msg = '^2' .. obj .. '^0';
            elseif (object_type == "boolean") then
                obj_msg = '^5' .. obj .. '^0';
            elseif (object_type == "nil") then
                obj_msg = '^11undefined^0';
            elseif (is_table(object)) then
                obj_msg = '^6' .. get_type_name(object) .. ': ' .. obj .. '^0';
            else
                obj_msg = '^6' .. obj .. '^0';
            end
            table_insert(buffer, obj_msg);
        end
        return data, buffer;
    end
    dump_table_recursive(tbl, 0, show_metatable);
    return table.concat(buffer);
end

---@private
---@param logType string
---@param message any
---@param messageType string
---@vararg
---@return string | boolean
local function format_message(logType, ...)
    local msg = string.format("^7(%s^7)^0 =>", logTypes[logType]);
    local args = { ... };

    if (#args > 0) then
        for i = 1, #args do
            if (is_table(args[i])) then
                msg = ("%s\n^3%s"):format(msg, dump_table(args[i], args[i].show_meta));
            else
                msg = ("%s %s"):format(msg, tostring(args[i]));
            end
        end
        return string.format("%s^0", msg);
    else
        return false;
    end
end

---@private
---@param logType string
---@param ... any
local function send_message(logType, ...)
    local success, msg = pcall(format_message, logType, ...);

    if (success) then
        if (type(msg) == "string") then
            _print(msg);
        end
    else
        console.err(("An error occured when trying to trace content, stack: ^7(^1%s^7)"):format(msg));
    end
end

---@vararg any
function console.log(...)
    return send_message("INFO", ...);
end

---@vararg any
function console.warn(...)
    return send_message("WARN", ...);
end

---@vararg any
function console.err(...)
    return send_message("ERROR", ...);
end

---@varargs any
function console.debug(...)
    if (jUtils.debug) then
        return send_message("DEBUG", ...);
    end
end

---@varargs any
function console.success(...)
    return send_message("SUCCESS", ...);
end

print = console.log;
_G._print = _print;

return console;