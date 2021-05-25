local cvd = CV_RegisterVar({"showdebug", "1", 0, CV_YesNo})
rawset(_G, "recursiveTableContents", function(dw, pos, t, level)
	if not cvd.value then return end
	if level == nil then level = 0 end
	if level == 0 then
		local ttype = type(t)
		if type(pos) ~= "table" then error("arg POS not a table",2) end
		if ttype ~= "table" then error("arg TABLE not a table, is "..ttype,2) end
	end
	for k,v in pairs(t) do
		local str = type(v)
		
		if str == "number" or str == "string" then str = v
		elseif str == "boolean" then str = v and "true" or "false" end
		
		dw.drawString(pos.x, pos.y, string.rep("  ",level)..k.." \131"..str, V_ALLOWLOWERCASE, "small")
		pos.y = $+4
		
		if type(v) == "table" then
			if not v._RECURSIVEHIDE then
				recursiveTableContents(dw, pos, v, level+1)
			else
				dw.drawString(pos.x, pos.y, string.rep("  ",level+1).."\131".."hidden", V_ALLOWLOWERCASE, "small")
				pos.y = $+4
			end
		end
	end
end)