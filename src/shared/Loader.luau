--!strict
-- Carga todos los ModuleScripts de una carpeta y los arranca en dos pasos:
-- primero Init() en todos (preparar estado, sin depender de otros),
-- después Start() en todos (conectar eventos, usar otros módulos).

export type Module = {
	Name: string?,
	Init: ((self: any) -> ())?,
	Start: ((self: any) -> ())?,
}

local Loader = {}

function Loader.LoadFolder(folder: Instance): { [string]: Module }
	local modules: { [string]: Module } = {}

	for _, child in folder:GetChildren() do
		if child:IsA("ModuleScript") then
			modules[child.Name] = require(child) :: any
		end
	end

	for name, module in modules do
		if module.Init then
			local ok, err = pcall(module.Init, module)
			if not ok then
				warn(`[Loader] {name}.Init falló: {err}`)
			end
		end
	end

	for name, module in modules do
		if module.Start then
			task.spawn(function()
				local ok, err = pcall(module.Start, module)
				if not ok then
					warn(`[Loader] {name}.Start falló: {err}`)
				end
			end)
		end
	end

	return modules
end

return Loader
