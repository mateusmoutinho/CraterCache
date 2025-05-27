private.serialize_item = function(eelement)
    local function serialize(val, indent)
        indent = indent or 0
        local indentStr = string.rep("    ", indent)
        
        if type(val) == "string" then
            return string.format("%q", val)
        elseif type(val) == "number" then
            return tostring(val)
        elseif type(val) == "boolean" then
            return tostring(val)
        elseif type(val) == "table" then
            local result = "{\n"
            local nextIndent = indent + 1
            local nextIndentStr = string.rep("    ", nextIndent)
            local items = {}
            local hasNonNumeric = false
            
            for k, v in pairs(val) do
                local keyStr = type(k) == "number" and "" or string.format("%s = ", serialize(k))
                if type(k) ~= "number" then
                    hasNonNumeric = true
                end
                table.insert(items, string.format("%s%s%s,", nextIndentStr, keyStr, serialize(v, nextIndent)))
            end
            
            if #items > 0 then
                result = result .. table.concat(items, "\n")
                result = result .. "\n" .. indentStr .. "}"
            else
                result = result .. indentStr .. "}"
            end
            return result
        elseif val == nil then
            return "nil"
        else
            return "-- unsupported type: " .. type(val)
        end
    end
    
    return string.format("function()\n    return %s\nend", serialize(eelement))
end

