-- Teste v26: sinais de venda do JAR ficam no fundo, nao nos peixes.
package.path='./?.lua;./?/init.lua;'..package.path
local Game=require('core.game')
local Retro=require('ui.retro')
local noop=function()end
local prints,draws={},{}
love={graphics={
 newFont=function()return {setFilter=noop}end,
 getDimensions=function()return 480,640 end,
 newImage=function(path)
  local f=assert(io.open(path,'rb'))
  local h=f:read(24);f:close()
  assert(h:sub(1,8)=='\137PNG\r\n\26\n')
  local function n(k)local a,b,c,d=h:byte(k,k+3);return ((a*256+b)*256+c)*256+d end
  local im={w=n(17),h=n(21),path=path,setFilter=noop}
  function im:getDimensions()return self.w,self.h end
  function im:getWidth()return self.w end
  function im:getHeight()return self.h end
  return im
 end,
 newQuad=function(x,y,w,h,iw,ih) assert(x+w<=iw and y+h<=ih);return {x=x,y=y,w=w,h=h}end,
 draw=function(img) if img.path then draws[#draws+1]=img.path end end,
 printf=function(s) prints[#prints+1]=tostring(s) end,
}}
for _,op in ipairs({'setColor','rectangle','setFont','line','push','pop','translate','scale','clear'})do love.graphics[op]=noop end
local g=Game.new(2600)
local v=Retro.new(g,true);v:init()
local f=assert(g:addFish('sale',3,4,20))
v.room='sale';v.screen='detail';v.selected=f.id;v.bitmapFont=nil
v:draw()
local found=false
for _,p in ipairs(draws)do if p:match('tank3%.png$')then found=true end end
assert(found,'Imagem de tanque de vendas nao utilizada')
for _,t in ipairs(prints)do assert(t~='For Sale!','Overlay duplicado sobre peixe')end
assert(#v.fishHits>=1)
local h=v.fishHits[#v.fishHits]
v.screen='tank';v:draw()
assert(v:press(v.ox+h.x*v.scale,v.oy+h.y*v.scale))
assert(v.screen=='detail' and v.selected==f.id)
assert(g.s.version==9)
print('V26: placas nativas, selecao e salvamento preservados')
