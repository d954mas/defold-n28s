-- NoMoreGlobalFunctionsInScripts
-- inspired by https://gist.github.com/Lerg/888c7df3844ab38cc39ef81d1c786da4
-- I used a more complex version that could register multiple scripts for a while:
-- https://github.com/d954mas/game-varvars-jam-5/blob/master/libs/n28s.lua
-- but I didn’t like it, so I switched back to a simpler one.

local M = {}

function M.register(script)
	assert(not _G.init, "global init already exist")
	assert(not script.__n28s_inited, "script already inited")
	script.__n28s_inited = true
	if script.init then _G.init = function (go_self) script:init(go_self) end end

	if script.update then
		local f = script.update
		_G.update = function (_, dt) f(script, dt) end
	end

	if script.fixed_update then
		local f = script.fixed_update
		_G.fixed_update = function (_, dt) f(script, dt) end
	end

	if script.on_message then
		local f = script.on_message
		_G.on_message = function (_, message_id, message, sender) f(script, message_id, message, sender) end
	end

	if script.on_input then
		local f = script.on_input
		_G.on_input = function (_, action_id, action) return f(script, action_id, action) end
	end

	if script.on_reload then
		local f = script.on_reload
		_G.on_reload = function (_) f(script) end
	end

	if script.final then
		_G.final = function (_) script.final(script) end
	end
end

return M
