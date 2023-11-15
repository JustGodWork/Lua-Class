--- @class ErrorHandler: BaseObject
---@field private err string
---@overload fun(callback, ...: any): ErrorHandler
Try = Class.new 'ErrorHandler';

---@param callback fun(...: any)
function Try:Constructor(callback, ...)
	local status, err = pcall(callback, ...);
	if (not status) then
		self.err = err;
	end
end

---@param callback fun(err: string)
function Try:Catch(callback)
	if (self.err) then
		callback(self.err);
	end
	return self;
end

return Try;