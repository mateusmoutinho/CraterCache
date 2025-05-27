
local project  = darwin.create_project("cratercraft")
local files = darwin.dtw.list_files_recursively("src",true)
project.add_lua_code([[return (function()
    local private = {}
    local public = {}
]])
for i=1,#files do
  local file = files[i]
  project.add_lua_file(file)

end
project.add_lua_code("    return public")
project.add_lua_code("end)()")

project.generate_lua_file({output="craterCraft.lua"})