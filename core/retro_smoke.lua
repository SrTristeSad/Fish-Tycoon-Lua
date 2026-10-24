-- Testa o NOVO front-end 240x320 no binario real do LOVE.
local Smoke={};Smoke.__index=Smoke
function Smoke.new(view)
 love.filesystem.createDirectory('retro-smoke')
 local actions={
  {'01-menu',function(v) assert(v.screen=='title') end},
  {'02-tanque',function(v)
   v:press(v.ox+120*v.scale,v.oy+198*v.scale); assert(v.screen=='tank') end},
  {'03-peixe',function(v)
   local hit=v.fishHits[1];assert(hit)
   v:press(v.ox+hit.x*v.scale,v.oy+hit.y*v.scale)
   assert(v.screen=='detail') end},
  {'04-acoes',function(v) v:press(v.ox+31*v.scale,v.oy+307*v.scale);assert(v.screen=='actions') end},
  {'05-menu-pausa',function(v)
   v:key('escape');v:key('escape');v:key('escape');assert(v.screen=='pause') end},
  {'06-suprimentos',function(v) v:press(v.ox+114*v.scale,v.oy+119*v.scale);assert(v.screen=='shop') end},
  {'07-suprimentos-pagina2',function(v)
   v:press(v.ox+165*v.scale,v.oy+289*v.scale)
   assert(v.screen=='shop' and v.shopPage==2) end},
  {'08-pesquisas',function(v)
   v:key('escape');v:draw()
   v:press(v.ox+114*v.scale,v.oy+151*v.scale)
   assert(v.screen=='research') end},
  {'09-configuracoes',function(v)
   v:key('escape');v:draw()
   v:press(v.ox+114*v.scale,v.oy+215*v.scale)
   assert(v.screen=='settings') end},
  {'10-vendas',function(v)
   v:key('escape');v:key('escape');v:draw()
   v:press(v.ox+45*v.scale,v.oy+12*v.scale)
   assert(v.screen=='tank' and v.room=='sale')
   assert(v.g:addFish('sale',3,4,20)) end},
  {'11-vendas-peixe',function(v)
   local h=v.fishHits[1];assert(h)
   v:press(v.ox+h.x*v.scale,v.oy+h.y*v.scale)
   assert(v.screen=='detail' and v.room=='sale') end}
 }
 return setmetatable({v=view,steps=actions,n=1,ready=false,pending=false,done=false},Smoke)
end
function Smoke:afterDraw()
 if self.done or self.pending then return end
 local stage=self.steps[self.n]
 if not stage then
  assert(love.filesystem.write('retro-smoke/ok.txt','Eleven J2ME-style screens rendered\n'))
  self.done=true;print('FISH_RETRO_SMOKE_OK 11');love.event.quit(0);return
 end
 if not self.ready then
  local ok,err=pcall(stage[2],self.v)
  if not ok then print('FISH_RETRO_SMOKE_FAIL: '..tostring(err));self.done=true;love.event.quit(1);return end
  self.ready=true
  return
 end
 self.pending=true
 local path='retro-smoke/'..stage[1]..'.png'
 love.graphics.captureScreenshot(function(data)
  local ok,err=pcall(function() data:encode('png',path) end)
  if not ok then print('FISH_RETRO_ERROR '..tostring(err));love.event.quit(1);return end
  print('FISH_RETRO_PNG '..path)
  self.n=self.n+1;self.ready=false;self.pending=false
 end)
end
return Smoke
