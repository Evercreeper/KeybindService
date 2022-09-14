local KBService = {
	logEnabled = true,
	changes = {},
	keybinds = {
		--["rotate_left"] = "A",
		--["rotate_right"] = "D",
		--["rotate_down"] = "A",
	},
	controller_movement ={

	},
	mobile_movement ={

	},	
}


-- CORE FUNCTIONS
local function log(write: string)
	if KBService.logEnabled then
		table.insert(KBService.changes,write)	
	else 
		return
	end
end

local function search_sub(sub,search_term)
	for subterm, values in pairs(KBService[sub]) do
		if subterm == search_term then
			return true
		end
	end
	return false
end


local function search_service(search_term)
	for service, values in pairs(KBService) do
		if service == search_term then
			return true
		end
	end
	return false
end

local function search_service_parent(search_term)
	--warn("START <<") --more testy bits, commenting out so no bad outputs!!
	--warn(search_term)
	
	for service, values in pairs(KBService) do
		
		--[[print("") -- bug test it fixed tho
		warn(service)
		warn(typeof(values))]] 
		
		if typeof(values) == "table" then
			for value_name, actual_value in pairs(values) do
				
				--warn(actual_value) -- bug test
				
			if value_name == search_term then
				return true, service
			end
			end
		end 
	end
	return false, nil
end

local function set_kb(action,key)
	KBService.keybinds[action] = Enum.KeyCode[string.upper(key)]
end

-- EXTERNAL
function KBService:ReturnAllChanges()
	log("s>Prompted to return changes.")
	return KBService.changes
end
function KBService:ReturnLastChange()
	-- was gonna add functionality to return the log of it returning as well,
	-- but seems like code bloat and pointless. in what case would you want to check
	-- if the return last change was logged correctly? Not me.
	log("s>Prompted to return last change.")
	return KBService.changes[#KBService.changes-2] -- skip the log above to get the real last
end

function KBService:ReturnChanges(...)
	local given = {...}
	local newChangeArray = {}
	if given[1] then
		if given[2] then -- both 1 given and 2 given
			for count = given[1], given[2] do
				table.insert(newChangeArray,KBService.changes[count])	
			end
			
			return newChangeArray -- return the new table
		else -- 1 given, no 2 given
			return KBService.changes[given[1]] -- return the specific change
		end
	else -- no variables passed, they want all
		return KBService:ReturnAllChanges() -- return all
	end
end

function KBService:ClearChanges(...)
	KBService.changes = {} --clear the log
end

function KBService:RecordLogs(value : boolean)
	log("RecordingLogs set to: ".. tostring(value))
	KBService.logEnabled = value
end

function KBService:Get()
	return KBService
end

function KBService:GetKeybinds()
	log("s<KBs returned.")
	return KBService.keybinds
end

-- BIND FETCHING --------------------------------------------------------------------------- BIND FETCHING
function KBService:GetBinds(tablename: string)
	log("s>Custom table ("..tablename..") request.")
	if search_service(tablename) then
		log("s<Custom table returned.")
		return KBService[tablename]
	else
		log("s>Custom table not found, request cancelled.")
		return nil
	end
end

function KBService:HasKeybind(keybind_or_key: string, first_found: boolean) 
	log("s>Start HasKeybind")
	local returns_found = {}

	for keybind_name, boundkey in pairs(KBService.keybinds) do
		if keybind_name == keybind_or_key or boundkey == keybind_or_key then
			if first_found then
				return true, keybind_name
			else
				table.insert(returns_found,keybind_name)
			end
		end
	end
	if #returns_found == 0 then
		log("s<Fail find on: \""..keybind_or_key.."\"")
		return false, nil
	elseif #returns_found == 1 then
		log("s<Found and returned: \""..keybind_or_key.."\"")
		return true, returns_found[1]
	else
		log("s<Found and returned list (reference return var data for list)")
		return true, returns_found
	end
end

function KBService:GetKeybind(keybind_name)
	log("s>Start GetBind")
	log("s<Transfer HasKeybind")
	local callback, bind = KBService:HasKeybind(keybind_name, true)

	if callback then
		log("s<Returning bind")
		return bind
	else
		log("s<Returning nil")
		return nil
	end
end

function KBService:GetBindParent(keybind_name)
	log("s>Start GetBindParent")
	log("s^Core function")
	local callback, parent_service = search_service_parent(keybind_name)

	if callback then
		log("s<Returning parent")
		return parent_service
	else
		log("s<Returning nil, no parent, is there a child?")
		return nil
	end
end

function KBService:GetBind(...)
	log("s>GetBind started")
	local given = {...}

	local table_to_search, bind

	-- we need to implement a feature that binds cannot be named the same as
	-- bind tables because then GetBind or any other search service function 
	-- would get false positives

	-- more code checking could be done here cause this could possibly error
	if search_service(given[1]) and 0 < #given then -- if the first passed is a service, then use it to search
		table_to_search = KBService[given[1]]
		bind = given[2]
		log("s>Found a service as first variable passed")
	else
		--warn(given[1]) -- for testing a bug, its fixed now
		
		table_to_search = KBService[KBService:GetBindParent(given[1])]
		if table_to_search == nil then log("s<Exit GetBind, no parent") return false,nil end -- no parent, no bind 😂
		bind = given[1]
		log("s>Assuming first var is bind, searching its parent.")
		
		--[[ -- Said issue as described in GetBindObject
		table_to_search = KBService
		bind = given[1]
		log("s>Assuming first var is bind, searching entire module")
		]]
	end


	for keybind_name, boundkey in pairs(table_to_search) do
		if type(boundkey) == "table" and boundkey ~= KBService.changes then


			log("s<GetBind Found nested bind table, scanning...")
			for bind_name, bound in pairs(boundkey) do
				if bind_name == bind or bound == bind then
					log("s<GetBind Nested Found and returned: \""..bind.."\"")
					return true, keybind_name
				end
			end
			log("s<GetBind Fail nested table")	
		end

		if keybind_name == bind  then -- name found so return bind
			log("s<GetBind Found and returned: \""..tostring(boundkey).."\"") -- tostring incase enum
			return true, boundkey
		end
		if boundkey == bind then -- bind found so return name
			log("s<GetBind Found and returned: \""..keybind_name.."\"")
			return true, keybind_name
		end
	end

	log("s<Fail find on: \""..bind.."\", could not GetBind")
	return false, nil
end

-- OBJECTS

function KBService:GetBindObject(...)
	-- RETURNS AN ENUM ITEM EXPLICITLY
	-- (sorta pointless, on hold)
	log("s>GetBindObject started")
	local given = {...}
	--local table_to_search, bind
	local callback, bind = KBService:GetBind(given[1])
	
	if callback == false then
		log("s<GetBindObject failed on GetBind, exiting")
		return false, nil
	else
		
		--warn(typeof(bind))
		
		--Was going to handle parent here, but seemed to be an issue in GetBind not GetBindObject
		--KBService:GetBindParent(bind)
		
		if typeof(bind) == "string" and #bind == 1 then -- if string(1) then we got a key
			bind = Enum.KeyCode[string.upper(bind)]
			log("s^GetBindObject convert bind character to enum object")
			log("s<GetBindObject Found and returned: \""..tostring(bind).."\"")
			return true, bind
		end
			
		if typeof(bind) == "string" then -- if string then we got a bind name
			-- we dont have a check here cause we assuming its a char,
			-- could lead to a bug :p
			bind = Enum.KeyCode[KBService.keybinds[bind]]
			log("s^GetBindObject convert bind name to enum object")
			log("s<GetBindObject Found and returned: \""..tostring(bind).."\"")
			return true, bind
		end
		
		if typeof(bind) == "EnumItem" then -- is a keycode!! yay :D
			log("s<GetBindObject Found and returned: \""..tostring(bind).."\"")
			return true, bind
		end
		
		bind = tostring(bind)
		-- if all else fails, return a bad bind
		log("s<Fail find with found: \""..bind.."\", could not GetBindObject")
		return false, nil
	end
end


-- BIND CREATION --------------------------------------------------------------------------- BIND CREATION

function KBService:CreateKeybind(action: string,key: string)
	log("s>Start CreateKeybind")
	local action_already_bound, res = KBService:HasKeybind(action)
	if action_already_bound == true then
		log("s<Tried KB create on existing action")
		warn("The action provided ["..action.."] already exists and is bound to the key(s): \n\t", res )
	end

	if action_already_bound == false then
		log("s>KB create created: \""..action.."\" and \""..key.."\"")
		set_kb(action,key)
	end
end
function KBService:SetKeybind(action: string,key: string)
	log("s>Start SetKeybind")
	local action_already_bound, res = KBService:HasKeybind(action)
	local key_already_bound, results = KBService:HasKeybind(key)
	if action_already_bound == true then
		KBService.keybinds[action] = Enum.KeyCode[string.upper(key)]
	end
	if key_already_bound == true then
		log("s<Tried KB set on existing key -> \""..key.."\"")
		warn("The key provided ["..key.."] is already bound to the action(s): \n\t", results )
	end

	if action_already_bound == false then
		log("s>KB set value: \""..action.."\" and \""..key)
		set_kb(action,key)
	end
end
function KBService:CreateBindTable(name: string)
	log("s>Start CreateBindTable")
	if not search_service(name) then
		log("s>BT create created: \""..name.."\"")
		KBService[name] = {}
	else
		log("s>BT create FAIL: \""..name.."\" already exists")
	end
end

function KBService:CreateBind(tablename: string, bindname : string, bind)
	log("s>Start CreateBind")
	if typeof(bind) ~= "string" and typeof(bind)~= "EnumItem" then
		return log("s>CreateBind create FAIL: the bind provided is not a string (key) or enum (movement type)")
	end
	if not search_sub(tablename,bindname) then
		log("s>CreateBind create created: \""..bindname.."\" with the value of: \""..tostring(bind).."\"")
		KBService[tablename][bindname] = bind
	else
		log("s>CreateBind create FAIL: \""..bindname.."\" already exists")
	end
end

function KBService:SetBind(tablename: string, bindname : string, bind)
	log("s>Start SetBind")
	--print(typeof(bind))
	if typeof(bind) ~= "string" and typeof(bind)~= "EnumItem" then
		return log("s>SetBind set FAIL: the bind provided is not a string (key) or enum (movement type)")
	end

end



-- BIND CONVERSION --------------------------------------------------------------------------- BIND CONVERSION


return KBService
