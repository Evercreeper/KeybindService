# KeybindService
It is a module script meant for organizing Enum.KeyCodes and strings to interact with keybinds.

## Features


## Information
Written in Roblox's LuaU, probably not the best way to handle things but I am just giving this a go for the fun of it. Hopefully it is somewhat useful and doesn't cause a memory leak somewhere.

## Branches
N/A


### Externals to call
| Name                     | Value                                                                                                                     |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------- |
| ReturnAllChanges()       | Return all the logs as an array                                                                                           |
| ReturnLastChange()       | Returns the last log                                                                                                      |
| ReturnChanges(i,iEnd)    | Returns a specific index of a log, a range of logs or all logs if no inputs are present                                   |
| ClearChanges()           | Clears all changes                                                                                                        |
| RecordLogs(v:bool)       | Sets self.logEnabled to the bool value provided, controlling if logs are logged or ignored                                |
| Get()                    | Get the service as an array, why does this exist? Well, why not, who knows, more functionality = clearly better           |
| GetKeybinds()            | Return an array of the keybinds under the default keybind array                                                           |
| GetBinds(name:string)    | Return an array of the binds under the passed table                                                                       |
| HasKeybind(name,v)       | Returns a callback of (true, bind name or key), or (false and nil). Key or bind name, and optionally toggle first found   |
| GetKeybind(name)         | Identical to HasKeybind but does not have a callback and assumes first found, pass a key or bind name                     |
| GetBindParent()          | Returns the parent table (aka service, array) name                                                                        |
| GetBind(...)             | If first passed is a table, it scans it else scan it's parent. Returns callback and name or bind accordingly, See [Issue #1](https://github.com/Evercreeper/KeybindService/issues/1) |
| GetBindObject(...)       | Uses GetBind to get an explicit EnumItem object, returns a callback and the bind as EnumItem                              |
| CreateKeybind(action,key)| Pass (action: string,key: string), checks if action already exists, will warn if so, else it makes the keybind            |
| SetKeybind(action,key)   | Sets (overrides)/creates a new keybind, unless the *key* is already bound, then it will warn                              |
| CreateBindTable(name)    | Creates a new bind table, unless it already exists, it will silently log                                                  |
| CreateBind(name,bindname)| Create a bind with the bindname under the table name passed, unless it already exists, it will silently log               |
| SetBind(name,bname,bind) | Set a bind with the bindname to the bind (string or EnumItem) under the table name passed !NON FUNCTIONAL!                |


### Internals to call (should NOT be called externally)
| Name                     | Value                                                                                                                     |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------- |
| self.changes             | An array of the logged changes                                                                                            |
| self.logEnabled          | An boolean representing if logs should be kept                                                                            |
| log                      | An internal function to log the status of the current proccess which can be printed out by external functions             |
| search_sub               | An internal function to search a specific sub category of binds, albeit custom or default                                 |
| search_service           | An internal function to search the entire service for all sub category of binds, albeit custom or default                 |
| set_kb                   | An internal function to set a keybind to the default keybind table                                                        |
| self                     | KS references its own functions repeatedly and is self-reliant, and the entire module can be fetched {see :Get()}       |


## License and Credits

Code adheres to attached license.

Main Author:
* Evercreeper


