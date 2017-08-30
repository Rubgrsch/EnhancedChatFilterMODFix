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
local G = ecf.G -- global variables

local char, pairs = string.char, pairs

local root = ""

local function ACMake(t, c, f)
	t[c]	  = {}
	t[c].to   = {}
	t[c].fail = f
	t[c].hit  = root
	t[c].word = false
end

function G.ACBuild(m)
	local t = {}
	ACMake(t, root, root)

	for k in pairs(m) do
		local current = root
		for j = 1, k:len() do
			local c = k:byte(j)
			local path = current..char(c)
			if t[current].to[c] == nil then
				t[current].to[c] = path
				if current == root then
					ACMake(t, path, root)
				else
					ACMake(t, path)
				end
			end
			current = path
		end
		t[k].word = true
	end

	local q = {root}
	while #q > 0 do
		local path = q[#q]
		q[#q] = nil
		for _, p in pairs(t[path].to) do
			q[#q+1] = p
			local fail = p:sub(2)
			while fail ~= "" and t[fail] == nil do fail = fail:sub(2) end
			t[p].fail = fail
			local hit = p:sub(2)
			while hit ~= "" and (t[hit] == nil or not t[hit].word) do hit = hit:sub(2) end
			t[p].hit = hit
		end
	end

	return t
end

function G.ACMatch(s, t, m)
	local path = root
	local hits = 0
	for i = 1,s:len() do
		local c = s:byte(i)
		while t[path].to[c] == nil and path ~= root do path = t[path].fail end
		local n = t[path].to[c]
		if n ~= nil then
			path = n
			if t[n].word then hits = hits + 1 end
			while t[n].hit ~= root do
				n = t[n].hit
				hits = hits + 1
			end
			if m[n] and not m[n].lesser and hits > 0 then return -1, n end
		end
	end

	return hits
end
