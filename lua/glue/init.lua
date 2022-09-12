glue = {
    loaded = { },
    stack = { }
}

-- predefine the return value to prevent require recursion
---@generic T
---@param value T
---@return T
function glue.load(value)
    local path = assert(glue.stack[#glue.stack])
    glue.loaded[path] = value
    return value
end

function glue.require(path)
    if glue.loaded[path] then 
        return glue.loaded[path]
    end

    table.insert(glue.stack, path)

    local code = assert(file.Read(path:gsub("%.", "/") .. ".lua", "LUA"), "File not found")
    local f = CompileString(code, path)
    local ret = f()

    table.remove(glue.stack)

    if ret == nil then 
        if glue.loaded[path] then return glue.loaded[path] end
        ret = true 
    end

    glue.loaded[path] = ret
    return ret
end

grequire = glue.require