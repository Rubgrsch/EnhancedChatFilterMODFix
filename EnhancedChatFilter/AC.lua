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
local AC = ecf.AC -- Aho-Corasick

local char, pairs, ipairs = string.char, pairs, ipairs

local root = ""

function AC:Build(m) -- m: blackwordTable
	local t = {}
	-- [1] = to, [2] = fail, [3] = hit, [4] = nil: not blackword, true/false: isLesser
	t[root] = {{}, root, root, nil}
	for k,v in pairs(m) do
		local current = root
		for j = 1, #k do
			local c = k:byte(j)
			local path = current..char(c)
			if t[current][1][c] == nil then
				t[current][1][c] = path
				t[path] = {{}, root, root, nil}
			end
			current = path
		end
		t[k][4] = v.lesser
	end

	local q = {root}
	while #q > 0 do
		local path = q[#q]
		q[#q] = nil
		for _, p in pairs(t[path][1]) do
			q[#q+1] = p
			local fail = p:sub(2)
			while fail ~= "" and t[fail] == nil do fail = fail:sub(2) end
			t[p][2] = fail
			local hit = p:sub(2)
			while hit ~= "" and (t[hit] == nil or t[hit][4] == nil) do hit = hit:sub(2) end
			t[p][3] = hit
		end
	end
	return t
end

function AC:Match(s, t) -- s: arrays of byte
	local path, hits = root, 0
	for _, c in ipairs(s) do
		while t[path][1][c] == nil and path ~= root do path = t[path][2] end
		local n = t[path][1][c]
		if n ~= nil then
			path = n
			if t[n][4] ~= nil then hits = hits + 1 end
			while t[n][3] ~= root do
				n = t[n][3]
				hits = hits + 1
			end
			if t[n] and t[n][4] == false then return -1, n end
		end
	end
	return hits
end
