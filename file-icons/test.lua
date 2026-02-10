local http = require("socket.http")
local json = require("cjson")

local Cache = {}
Cache.__index = Cache

function Cache:new(max_size)
    local instance = setmetatable({}, Cache)
    instance.store = {}
    instance.max_size = max_size or 100
    instance.count = 0
    return instance
end

function Cache:get(key)
    local entry = self.store[key]
    if entry and os.time() < entry.expires then
        return entry.value
    end
    self.store[key] = nil
    return nil
end

function Cache:set(key, value, ttl)
    if self.count >= self.max_size then
        self:evict()
    end
    self.store[key] = {
        value = value,
        expires = os.time() + (ttl or 60)
    }
    self.count = self.count + 1
end

function Cache:evict()
    local oldest_key, oldest_time = nil, math.huge
    for k, v in pairs(self.store) do
        if v.expires < oldest_time then
            oldest_key, oldest_time = k, v.expires
        end
    end
    if oldest_key then
        self.store[oldest_key] = nil
        self.count = self.count - 1
    end
end

return Cache
