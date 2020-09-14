
local Raid = false

local scf = { }
local relativeFrame = relativeFrame
local Point = Point
local relativePoint = relativePoint
local buffs1 = {}
local buffs2= {}
local spellIds = {
	[17] = "True",
	[194384] = "True",
	[21562] = "True",
	[297412] = "True",
}


local LoseControlWarning = CreateFrame('Frame')
LoseControlWarning:SetScript('OnEvent', function(self, event, ...)
	self[event](self, ...)
end)
LoseControlWarning:RegisterUnitEvent('UNIT_AURA', "player", "party1", "party2")
LoseControlWarning:RegisterEvent("GROUP_ROSTER_UPDATE")
LoseControlWarning:RegisterEvent("GROUP_JOINED")

LoseControlparty1:HookScript("OnShow", function(self)
if GetNumGroupMembers() > 5  and Raid == false then return end
	LoseControlWarning("party1")
end)
LoseControlparty2:HookScript("OnShow", function(self)
if GetNumGroupMembers() > 5  and Raid == false then return end
	LoseControlWarning("party2")
end)

function LoseControlWarning:GROUP_ROSTER_UPDATE()
if GetNumGroupMembers() > 5  and Raid == false then return end
	LoseControlWarning("player")
	for i = 1, GetNumGroupMembers() do
	local unitId = "party"..i
	LoseControlWarning(unitId)
	end
end

function LoseControlWarning:GROUP_JOINED()
self:GROUP_ROSTER_UPDATE()
end

function LoseControlWarning:UNIT_AURA(unitId)
if GetNumGroupMembers() > 5  and Raid == false then return end
local k = 1

		if not buffs1[unitId] then
			buffs1[unitId] = {}
		end
		if not buffs2[unitId] then
			buffs2[unitId] = {}
		end

	if #buffs1[unitId] > 0 then
			for i = 1, #buffs1[unitId] do
					buffs1[unitId][i] = nil
				end
	end

		for i = 1, 40 do
				local name, icon, count, _, duration, expirationTime, _, _, _, spellId = UnitAura(unitId, i, HELPFUL)
				if not spellId then break end
				if spellIds[spellId] then
				table.insert(buffs1[unitId], k , expirationTime )
			  --print(unitId, "buff1", k, ")", name, "|", duration, "|", expirationTime, "|", spellId)
					k = k + 1
				end
			end

					if #buffs1[unitId] ~= #buffs2[unitId] then
							--print("fire cond 1")
							LoseControlWarning(unitId)
							if #buffs2[unitId] > 0 then
								for i = 1, #buffs2[unitId] do
										buffs2[unitId][i] = nil
								end
							end
							if #buffs1[unitId] > 0 then
								for i = 1, #buffs1[unitId] do
										buffs2[unitId][i] = buffs1[unitId][i]
								end
				    	end
					else
							if compare(buffs1[unitId], buffs2[unitId]) then
							--print("no fire cond 2")
							else
							--print("fire cond 2")
								LoseControlWarning(unitId)
								if #buffs2[unitId] > 0 then
										for i = 1, #buffs2[unitId] do
												buffs2[unitId][i] = nil
										end
								end
								if #buffs1[unitId] > 0 then
									for i = 1, #buffs1[unitId] do
											buffs2[unitId][i] = buffs1[unitId][i]
									end
								end
							end
					end
end


function LoseControlWarning(unitId)
if GetNumGroupMembers() > 5  and Raid == false then return end
		--print("buffs1:", dump(buffs1))
		--print("buffs2:", dump(buffs2))
	  	local j = 1
			for i = 1, 40 do
			local name, icon, count, _, duration, expirationTime, _, _, _, spellId = UnitAura(unitId, i, HELPFUL)
						if scf[j..unitId] then
						--	print(unitId, "buff", i, ")", name, "|", duration, "|", expirationTime, "|", spellId)
							scf[j..unitId]:Hide()
							scf[j..unitId].cooldown:Hide()
						end
			   				if spellIds[spellId] then
									if unitId == "player" or "party1" or "party2" then
												scf[j..unitId] = CreateFrame("Frame", "UAdebuff"..j..unitId)
												scf[j..unitId]:SetHeight(40)
												scf[j..unitId]:SetWidth(40)
												scf[j..unitId].texture = scf[j..unitId]:CreateTexture(scf[j..unitId], 'BACKGROUND')
												scf[j..unitId].texture:SetAllPoints(scf[j..unitId])
												scf[j..unitId].cooldown = CreateFrame("Cooldown", nil, scf[j..unitId], 'CooldownFrameTemplate')
												scf[j..unitId].count=scf[j..unitId]:CreateFontString(scf[j..unitId],"OVERLAY","NumberFontNormal");
												scf[j..unitId].count:SetPoint("BOTTOMRIGHT",-5,2);
												scf[j..unitId].count:SetJustifyH("RIGHT");
												scf[j..unitId].texture:SetTexture(icon)
														if count then
															if ( count > 1 ) then
															local countText = count
																if ( count >= 100 ) then
																 countText = BUFF_STACKS_OVERFLOW
																end
																scf[j..unitId].count:Show();
																scf[j..unitId].count:SetText(countText)
														else
														  	scf[j..unitId].count:Hide();
														end
														end
												scf[j..unitId].cooldown:SetCooldown( expirationTime - duration, duration)
												scf[j..unitId].cooldown:SetAllPoints(scf[j..unitId])
												scf[j..unitId].cooldown:SetDrawSwipe()
												scf[j..unitId].cooldown:SetDrawEdge()
												scf[j..unitId].cooldown:SetReverse(false) --will reverse the swipe if actionbars or debuff, by default bliz sets the swipe to actionbars if this = true it will be set to debuffs
												scf[j..unitId].cooldown:SetDrawBling()
																							if unitId == "player" then
																												relativeFrame = PF
																												relativePoint = "BOTTOMRIGHT"
																												Point = "BOTTOMRIGHT"
																						 elseif unitId == "party1" then
																											if LoseControlparty1:IsShown() then
																												relativeFrame = LoseControlparty1
																												relativePoint = "BOTTOMLEFT"
																												Point = "BOTTOMRIGHT"
																											else
																												relativeFrame = PartyAnchor1
																												relativePoint = "BOTTOMRIGHT"
																												Point = "BOTTOMRIGHT"
																											end
																							elseif unitId == "party2" then
																											if LoseControlparty2:IsShown() then
																												relativeFrame = LoseControlparty2
																												relativePoint = "BOTTOMLEFT"
																												Point = "BOTTOMRIGHT"
																											else
																												relativeFrame = PartyAnchor1
																												relativePoint = "BOTTOMRIGHT"
																												Point = "BOTTOMRIGHT"
																											end
																								else
																								end
																												if j == 1 then
																												scf[j..unitId]:ClearAllPoints()
																												scf[j..unitId]:SetParent(relativeFrame)
																												scf[j..unitId]:SetPoint(Point, relativeFrame, relativePoint, 0, 0)
																												else
																												scf[j..unitId]:SetParent(relativeFrame)
																												scf[j..unitId]:SetPoint("BOTTOMRIGHT", scf[(j-1)..unitId], "BOTTOMLEFT",0,0)
																												end
										 	j = j + 1
									end
							end
		    end
end

function compare(t1,t2,ignore_mt)
   local ty1 = type(t1)
   local ty2 = type(t2)
   if ty1 ~= ty2 then return false end
   -- non-table types can be directly compared
   if ty1 ~= 'table' and ty2 ~= 'table' then return t1 == t2 end
   -- as well as tables which have the metamethod __eq
   local mt = getmetatable(t1)
   if not ignore_mt and mt and mt.__eq then return t1 == t2 end
   for k1,v1 in pairs(t1) do
      local v2 = t2[k1]
      if v2 == nil or not compare(v1,v2) then return false end
   end
   for k2,v2 in pairs(t2) do
      local v1 = t1[k2]
      if v1 == nil or not compare(v1,v2) then return false end
   end
   return true
end

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end