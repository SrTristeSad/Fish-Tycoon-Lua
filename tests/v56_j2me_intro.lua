-- V56: o Java exibe oberon.png por 3s, depois splash.png por 3s.
-- O menu nao deve desenhar a splash atras dos botoes.
package.path='./?.lua;./?/init.lua;'..package.path
local Retro=require('ui.retro')
local calls={}
local noop=function()end
love={graphics={
 getDimensions=function()return 480,640 end,
 clear=noop,push=noop,pop=noop,translate=noop,scale=noop,
 setFont=noop,setColor=noop,rectangle=noop,printf=noop,
 draw=function(image)calls[#calls+1]=image.name end
}}
local game={s={}}
local view=Retro.new(game,true)
view.font={}
view.images.oberon={name='oberon'}
view.images.splash={name='splash'}
view:beginIntro()
assert(view.screen=='intro_oberon' and not view:isPlaying())
view:draw()
assert(#calls==1 and calls[1]=='oberon' and #view.buttons==0)
assert(not view:press(200,300),'intro must not accept menu touches')
view:key('5')
assert(view.screen=='intro_oberon','intro must not accept menu shortcuts')
view:update(2.99)
assert(view.screen=='intro_oberon')
view:update(.02)
assert(view.screen=='intro_splash' and not view:isPlaying())
calls={}
view:draw()
assert(#calls==1 and calls[1]=='splash' and #view.buttons==0)
view:update(2.99)
assert(view.screen=='title','second 3s should conclude at six seconds')
calls={}
view:draw()
for _,name in ipairs(calls) do
 assert(name~='splash' and name~='oberon','menu reused transient intro art')
end
assert(#view.buttons==3,'CONTINUE disabled + NEW GAME/OPTIONS/ABOUT should be active')
-- Missing resources: start directly at the menu, no synthetic art.
local missing=Retro.new(game,false)
missing:beginIntro()
assert(missing.screen=='title')
local onlySplash=Retro.new(game,false)
onlySplash.images.splash={name='splash'}
onlySplash:beginIntro()
assert(onlySplash.screen=='intro_splash')
onlySplash:update(3)
assert(onlySplash.screen=='title')
print('OK v56: Java logos 3s+3s and separate title, no save mutation')
