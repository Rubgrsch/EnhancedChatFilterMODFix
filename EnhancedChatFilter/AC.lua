-- A Lua implementation of the Aho-Corasick string matching algorithm
--
-- Copyright (c) 2013-2014 CloudFlare, Inc.
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are
-- met:
--
--    * Redistributions of source code must retain the above copyright
-- notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above
-- copyright notice, this list of conditions and the following disclaimer
-- in the documentation and/or other materials provided with the
-- distribution.
--    * Neither the name of CloudFlare, Inc. nor the names of its
-- contributors may be used to endorse or promote products derived from
-- this software without specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
-- "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
-- LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
-- A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
-- OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
-- SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
-- LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
-- DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
-- THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
-- OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

-- ECF
local _, ecf = ...
local _, _, _, AC = unpack(ecf)

local char, pairs, ipairs, type = string.char, pairs, ipairs, type

function AC:Build(m) -- m: blackwordTable
	local t = {[""] = {}}
	for k,v in pairs(m) do
		local current = ""
		for j = 1, #k do
			local c = k:byte(j)
			local path = current..char(c)
			if t[current][c] == nil then
				t[current][c] = path
				t[path] = {}
			end
			current = path
		end
		t[k].word = v.lesser -- word = nil: not blackword, true/false: isLesser
	end

	local q = {""}
	while #q > 0 do
		local path = q[#q]
		q[#q] = nil
		for k, p in pairs(t[path]) do
			if type(k) == "number" then
				q[#q+1] = p
				local fail = p:sub(2)
				while fail ~= "" and t[fail] == nil do fail = fail:sub(2) end
				if fail ~= "" then t[p].fail = fail end
				local hit = p:sub(2)
				while hit ~= "" and (t[hit] == nil or t[hit].word == nil) do hit = hit:sub(2) end
				if hit ~= "" then t[p].hit = hit end
			end
		end
	end
	return t
end

function AC:Match(s, t) -- s: arrays of byte
	local path, hits = "", 0
	for _, c in ipairs(s) do
		while t[path][c] == nil and path ~= "" do path = t[path].fail or "" end
		local n = t[path][c]
		if n ~= nil then
			path = n
			repeat
				if t[n].word == false then
					return -1, n
				elseif t[n].word == true then
					hits = hits + 1
				end
				n = t[n].hit
			until not n
		end
	end
	return hits
end
