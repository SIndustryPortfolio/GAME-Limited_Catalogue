local InterfacesInfoModule = {}

-- CORE
local InterfaceType = 
{
	["Custom"] = {MultiPaged = true},	
	["Pages"] = {MultiPaged = false, DisableCoreUi = true},
	["Main"] = {MultiPaged = true, DisableCoreUi = true},
	["Billboards"] = {MultiPaged = true}
}

-- Functions
function InterfacesInfoModule.GetInterfaceTypes()
	return InterfaceType
end

function InterfacesInfoModule.GetInterfaceType(NilParam, Type)
	return InterfaceType[Type]
end

return InterfacesInfoModule