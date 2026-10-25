-- V48: backgrounds must load even when fish atlases are absent.
package.path='./?.lua;./?/init.lua;'..package.path
local Assets=require('core.assets')
local present={tank1=true,tank2=true,tank3=true,tanktop=true,isolation_tank=true,menutank=true}
local function nameOf(path) return path:match('/([%w_]+)%.png$') end
love={graphics={
 newQuad=function(...)return {...}end,
 newImage=function(path)
  local name=nameOf(path)
  assert(present[name],'missing test asset: '..tostring(name))
  return {setFilter=function()end}
 end,
}}
local a=Assets.new()
assert(a:init()==false,'sprites missing should not report full initialization')
assert(not a.available,'fish rendering must stay disabled when atlases are missing')
for name in pairs(present) do
 assert(a.images[name],'original background not loaded: '..name)
end
-- When the fish atlases are restored, the same loader can enable fish rendering.
present.fish=true;present.fins=true
local b=Assets.new()
-- Quad stub accepts any coordinates and does not require real PNG files.
assert(b:init()==true,'fish sprites should enable rendering when available')
assert(b.available and b.images.tank1 and b.images.fish and b.images.fins)
print('OK v48: backgrounds independent of fish sprites')
