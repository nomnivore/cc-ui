local root = fs.combine(fs.getDir(shell.getRunningProgram()), "..")
package.path = "/" .. root .. "/?.lua;/" .. root .. "/?/init.lua;" .. package.path
