-- Simple LibDataBroker-1.1 implementation for SurvivalMode
local MAJOR, MINOR = "LibDataBroker-1.1", 4
local lib = LibStub:NewLibrary(MAJOR, MINOR)

if not lib then return end

lib.callbacks = lib.callbacks or LibStub:GetLibrary("CallbackHandler-1.0"):New(lib)
lib.attributestorage, lib.namestorage, lib.proxystorage = lib.attributestorage or {}, lib.namestorage or {}, lib.proxystorage or {}
local attributestorage, namestorage, proxystorage = lib.attributestorage, lib.namestorage, lib.proxystorage

local domt = {
    __metatable = "access denied",
    __newindex = function(self, key, value)
        if key == nil then return error("attempt to index nil key") end
        local name = namestorage[self]
        if not name then return error("attempt to index unnamed dataobject") end
        
        attributestorage[name][key] = value
        lib.callbacks:Fire("LibDataBroker_AttributeChanged", name, key, value)
        lib.callbacks:Fire("LibDataBroker_AttributeChanged_"..name, name, key, value)
        lib.callbacks:Fire("LibDataBroker_AttributeChanged_"..name.."_"..key, name, key, value)
        lib.callbacks:Fire("LibDataBroker_AttributeChanged__"..key, name, key, value)
    end,
    __index = function(self, key)
        local name = namestorage[self]
        if not name then return end
        return attributestorage[name][key]
    end,
}

function lib:NewDataObject(name, dataobj)
    if not name then return end
    if proxystorage[name] then return end
    
    if dataobj then
        assert(type(dataobj) == "table", "Invalid dataobj, must be nil or a table")
        attributestorage[name] = dataobj
    else
        attributestorage[name] = {}
    end
    
    local proxy = {}
    proxystorage[name] = proxy
    namestorage[proxy] = name
    
    setmetatable(proxy, domt)
    
    lib.callbacks:Fire("LibDataBroker_DataObjectCreated", name, proxy)
    return proxy
end

function lib:DataObjectIterator()
    return pairs(proxystorage)
end

function lib:GetDataObjectByName(name)
    return proxystorage[name]
end

function lib:GetNameByDataObject(dataobj)
    return namestorage[dataobj]
end