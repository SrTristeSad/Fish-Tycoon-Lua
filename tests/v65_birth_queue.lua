-- V65 regression: purchased eggs hatch FIFO when space is limited.
package.path='./?.lua;./?/init.lua;'..package.path
local Game=require('core.game')
local JSON=require('core.json')
local C=require('core.config')
local function seeded(seed,spaces)
 local g=Game.new(seed)
 while #g.s.tanks.main<C.CAPACITY.main-spaces do
  assert(g:addFish('main',1,1,20))
 end
 return g
end
local function archive(g)
 local saved=JSON.encode(g.s)
 local restored,err=Game.fromTable(JSON.decode(saved))
 assert(restored,err)
 assert(JSON.encode(restored.s)==saved,'State changed during roundtrip')
 return restored
end
-- With only one vacancy, the oldest egg must hatch first.
local g=seeded(6501,1)
g.s.eggs={{body=2,tail=2,at=0},{body=3,tail=3,at=0}}
g=archive(g)
local before=g.s.stats.born
g:advance(1)
assert(g.s.stats.born==before+1)
assert(#g.s.eggs==1 and g.s.eggs[1].body==3 and g.s.eggs[1].waiting)
assert(g.s.tanks.main[#g.s.tanks.main].body==2)
local previousRng=g.s.rng
g:advance(1)
assert(#g.s.eggs==1 and g.s.rng==previousRng,
 'An egg waiting for room may not consume random numbers')
g=archive(g)
assert(g:move(g.s.tanks.main[1].id,'isolation'))
g:advance(1)
assert(#g.s.eggs==0 and g.s.tanks.main[#g.s.tanks.main].body==3)
assert(g.s.stats.born==before+2 and #g.s.tanks.main==C.CAPACITY.main)
archive(g)
-- When two vacancies are available, both older eggs hatch first.
local two=seeded(6502,2)
two.s.eggs={{body=2,tail=2,at=0},{body=3,tail=3,at=0},{body=4,tail=4,at=0}}
two:advance(1)
assert(two.s.tanks.main[#two.s.tanks.main-1].body==2)
assert(two.s.tanks.main[#two.s.tanks.main].body==3)
assert(#two.s.eggs==1 and two.s.eggs[1].body==4 and two.s.eggs[1].waiting)
archive(two)
-- At a shared deadline, eggs, shop visitors and research must converge
-- to the same state whether advance runs once or in 900 one-second steps.
for scenario=1,4 do
 local src=seeded(6550+scenario,2)
 src.s.sale_open=scenario%2==0
 src.s.eggs={{body=2,tail=2,at=180},{body=3,tail=3,at=180}}
 if scenario%2==1 then assert(src:startResearch('food')) end
 local one=archive(src)
 local small=archive(src)
 one:advance(900)
 for i=1,900 do small:advance(1) end
 assert(JSON.encode(one.s)==JSON.encode(small.s),
  'Combined events diverged: scenario '..scenario)
 assert(one.s.stats.born==2 and #one.s.eggs==0)
 archive(one)
end
print('OK v65: FIFO birth queue, limited capacity, backup roundtrip and combined events')
