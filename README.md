# N28S Defold Example

This repository demonstrates how to use **n28s** (No More Global Functions in Scripts) inside a Defold project. The helper module (`n28s.lua`) lets you keep your gameplay logic encapsulated in a regular Lua table instead of spreading Defold lifecycle callbacks (`init`, `update`, `on_input`, etc.) over the global scope. It is a tiny drop-in utility inspired by [Lerg's approach](https://gist.github.com/Lerg/888c7df3844ab38cc39ef81d1c786da4) and trimmed down for simplicity.

Keeping the script APIs on a table also makes auto-completion and type hints work better in editors such as VS Code or JetBrains IDEs—the tooling understands methods on explicit tables far more reliably than anonymous global callbacks with implicit `self`.

Defold injects a userdata `self` into callbacks by default, but storing your state on a plain Lua table and passing that around keeps all lookups inside Lua and is measurably faster than going through the userdata wrapper.

## What the sample does
- Loads `n28s.lua` from the project root.
- Defines a script table in `main/main.script`, registers it with `N28S.register`, and delegates the Defold callbacks through that table.
- Shows how to acquire input focus, set a fixed-fit projection, and react to the `touch` input action without leaking globals.

```lua
local N28S = require "n28s"

local Script = {}

function Script:init(go_self)
	self.go_self = go_self
	msg.post(".", "acquire_input_focus")
	msg.post("@render:", "use_fixed_fit_projection", { near = -1, far = 1 })
end

function Script:on_input(action_id, action)
	if action_id == hash("touch") and action.pressed then
		print("Touch!")
	end
end

N28S.register(Script)
```


## Using n28s in your own scripts
1. Copy `n28s.lua` into your project (keep it somewhere in the Lua module search path, e.g., the project root or `libs/`).
2. `require "n28s"` inside any script file.
3. Place lifecycle functions (`init`, `update`, `fixed_update`, `on_message`, `on_input`, `on_reload`, `final`) as methods on a Lua table.
4. Call `N28S.register(MyScriptTable)` once. The helper asserts that no global callbacks are already defined, ensuring a single source of truth per script file.

This pattern keeps state localized, enables reuse across game objects, and makes Lua tooling (linters, unit tests, IDE completion) easier to apply since the script logic is regular table methods instead of hidden global functions.

## Folder layout
- `main/main.script` – example game object script that uses n28s.
- `n28s.lua` – the helper module described above.
- `game.project`, `assets`, `input` – standard Defold desktop template files.

Feel free to extend the main script or replace it with your own gameplay logic. As long as you register your table with `N28S.register`, Defold will keep calling into your encapsulated script without cluttering the global namespace.
