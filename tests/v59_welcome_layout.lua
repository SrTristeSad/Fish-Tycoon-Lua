-- V59: o menu Java (d.class, f(32), estilo 1) mede as strings,
-- centraliza lista em x=120/y=160 e nao desenha grandes botoes individuais.
package.path='./?.lua;./?/init.lua;'..package.path
local Retro=require('ui.retro')
local Game=require('core.game')
local noop=function()end
love={graphics={
 getDimensions=function()return 480,640 end,
 newFont=function()return {setFilter=noop,getWidth=function(_,s)return #s*6 end}end,
 setFont=noop,setColor=noop,rectangle=noop,draw=noop,clear=noop,
 push=noop,pop=noop,translate=noop,scale=noop,printf=noop,
}}
local function inspect(hasSave)
 local v=Retro.new(Game.new(5900),hasSave)
 v.font=love.graphics.newFont()
 v:draw()
 local entries=v:titleEntries()
 local layout=v:welcomeLayout(entries)
 assert(#v.buttons==#entries+2,'expected only list choices and two softkeys')
 assert(layout.x+layout.w/2==120,'JAR menu must be centered horizontally')
 assert(layout.y>=45 and layout.y+#entries*layout.step<=298,
  'menu rows must not overlap softkeys')
 assert(layout.w<178,'JAR list must not use the 178px placeholder buttons')
 for i,entry in ipairs(entries) do
  local b=v.buttons[i]
  assert(b.role=='welcome' and b.x==layout.x and b.w==layout.w)
  assert(b.y==layout.y+(i-1)*layout.step and b.h==20)
  assert(b.y+b.h<299 and type(b.fn)=='function')
 end
 assert(v.buttons[#entries+1].y==299)
 assert(v.buttons[#entries+2].y==299)
 return v,layout
end
local with,layout=inspect(true)
local noSave,withoutLayout=inspect(false)
assert(withoutLayout.y>layout.y,'fewer choices must be centered independently')
local savedLayout=layout.w
with.font={getWidth=function(_,s)return #s*8 end}
assert(with:welcomeLayout(with:titleEntries()).w>=savedLayout,
 'list width must respond to actual font measurements')
with.font={getWidth=function(_,s)return #s*6 end}
local b=with.buttons[2]
assert(with:press(with.ox+(b.x+10)*with.scale,with.oy+(b.y+8)*with.scale))
assert(with.screen=='confirm' and with.confirmFrom=='title',
 'START NEW GAME must work by touching the centered row')
local options=noSave.buttons[2]
assert(noSave:press(noSave.ox+(options.x+10)*noSave.scale,
 noSave.oy+(options.y+8)*noSave.scale))
assert(noSave.screen=='settings','OPTIONS must remain accessible without save')
-- Imported 1.dat font: the title list must use face 1 (20px), not face 3.
local fontStyles,drawStyles={},{}
local face=Retro.new(Game.new(5905),true)
face.font=love.graphics.newFont()
face.bitmapFont={
 measure=function(_,label,style)
  fontStyles[#fontStyles+1]=style
  return #label*8
 end,
 print=function(_,label,x,y,w,align,style)
  drawStyles[#drawStyles+1]=style
 end
}
local importedLayout=face:welcomeLayout(face:titleEntries())
assert(importedLayout.w>=layout.w)
face:draw()
assert(#fontStyles>=8 and #drawStyles==8,'each menu label must use original font')
for _,style in ipairs(fontStyles) do assert(style==1,'font width uses wrong face') end
for _,style in ipairs(drawStyles) do assert(style==1,'label drawn with wrong face') end

print('OK v59: centered measured list, 20px JAR font, touch, softkey separation')
