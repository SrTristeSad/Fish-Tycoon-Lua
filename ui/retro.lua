-- Reconstrucao da interface J2ME 240x320. Fonte visual: assets.png,
-- splash.png, tanktop.png, tank1..3.png, isolation_tank.png do JAR.
-- A simulacao original do port fica isolada em core/game.lua.
local Assets=require('core.assets')
local Swim=require('ui.swim')
local Catalog=require('core.catalog')
local Config=require('core.config')
local Retro={}; Retro.__index=Retro
local W,H=240,320
local function rgb(r,g,b,a) love.graphics.setColor(r/255,g/255,b/255,a or 1) end
local function fill(x,y,w,h,r,g,b,a)
 rgb(r,g,b,a);love.graphics.rectangle('fill',x,y,w,h)
end
local function stroke(x,y,w,h,r,g,b)
 rgb(r,g,b);love.graphics.rectangle('line',x+.5,y+.5,w-1,h-1)
end
local function fontText(s,x,y,width,align,tint)
 if tint then rgb(tint[1],tint[2],tint[3]) else rgb(245,245,242) end
 love.graphics.printf(tostring(s),x,y,width or 220,align or 'left')
end
local function centered(s,y,tint) fontText(s,10,y,220,'center',tint) end
local function load(name)
 local ok,img=pcall(love.graphics.newImage,'assets/original/'..name..'.png')
 if ok and img then img:setFilter('nearest','nearest');return img end
end
local rooms={'main','second','sale'}
local function roomName(r) return ({main='TANK 1',second='TANK 2',sale='SALE TANK',isolation='ISOLATION'})[r] or r end
function Retro.new(game,hasSave)
 return setmetatable({g=game,hasSave=not not hasSave,screen='title',room='main',selected=nil,
  popup=nil,popupFrom=nil,buttons={},fishHits={},images={},assets=Assets.new(),
  speed=1,soundEnabled=true,shopPage=1,toast='',toastTime=0,time=0,
  scale=1,ox=0,oy=0,onSave=nil,onNewGame=nil,onSound=nil},Retro)
end
function Retro:init()
 self.assets:init()
 for _,name in ipairs({'splash','assets','gameMenuTank','menutank'}) do
  self.images[name]=load(name)
 end
 self.font=love.graphics.newFont(9)
 self.font:setFilter('nearest','nearest')
end
function Retro:setGame(game,hasSave)
 self.g=game;self.hasSave=not not hasSave
 self.selected=nil;self.room='main';self.screen='tank';self.popup=nil
end
function Retro:isPlaying() return self.hasSave and self.screen~='title' and self.screen~='confirm' and self.screen~='settings' end
function Retro:notify(message) self.toast=tostring(message or '');self.toastTime=3.3 end
function Retro:update(dt)
 self.time=self.time+dt;self.toastTime=math.max(0,self.toastTime-dt)
end
function Retro:hit(x,y,w,h,fn)
 self.buttons[#self.buttons+1]={x=x,y=y,w=w,h=h,fn=fn}
end
function Retro:menuButton(label,x,y,w,h,fn,disabled)
 fill(x,y,w,h,63,34,93)
 stroke(x,y,w,h,150,99,184)
 fill(x+2,y+2,w-4,2,129,85,164)
 fontText(label,x+3,y+math.floor((h-10)/2),w-6,'center',disabled and {141,126,149} or {185,252,150})
 if fn and not disabled then self:hit(x,y,w,h,fn) end
end
function Retro:buttonHint(left,right)
 fill(0,298,240,22,37,20,64)
 fill(0,299,240,2,118,79,164)
 fill(0,301,240,2,67,36,97)
 fill(0,303,240,17,54,26,82)
 if left then self:menuButton(left.label,0,299,63,21,left.fn,left.disabled) end
 if right then self:menuButton(right.label,177,299,63,21,right.fn,right.disabled) end
end
function Retro:background(room)
 local sky=self.assets.images.tanktop
 local source=({main='tank1',second='tank2',sale='tank3',isolation='gameMenuTank'})[room] or 'tank1'
 local floor=self.assets.images[source] or self.images.gameMenuTank or self.assets.images.tank1
 rgb(255,255,255)
 if sky then love.graphics.draw(sky,0,24) else fill(0,24,240,110,12,100,160) end
 if floor then
  if room=='isolation' and self.images.gameMenuTank then floor=self.images.gameMenuTank end
  love.graphics.draw(floor,0,122)
 else fill(0,122,240,154,12,76,130) end
end
function Retro:tray()
 local im=self.assets.images.isolation_tank
 if im then rgb(255,255,255);love.graphics.draw(im,70,274) end
 self:hit(69,272,102,47,function()
  if self.room=='isolation' then self.room='main' else self.room='isolation' end
  self.selected=nil;self.screen='tank'
 end)
end
function Retro:toolbar()
 fill(0,0,240,25,42,24,72)
 fill(0,0,240,2,120,79,162)
 fill(0,22,240,3,16,8,37)
 -- Tres miniaturas de tanque na mesma posicao da barra J2ME.
 for i,room in ipairs(rooms) do
  local x=(i-1)*20+1
  fill(x,3,18,19,83,51,119)
  stroke(x,3,18,19,146,95,182)
  if self.room==room then stroke(x+2,5,14,15,234,215,80) end
  fontText(tostring(i),x+3,7,12,'center',{210,255,161})
  self:hit(x,2,19,21,function()
   if room=='second' and not self.g.s.unlocked.second then self:notify('TANK 2: BUY AT STORE')
   else self.room=room;self.screen='tank';self.selected=nil end
  end)
 end
 local slots={{63,'F'},{82,'S'},{101,'R'},{120,'?'},{181,'$'}}
 for _,p in ipairs(slots) do
  local x=p[1]
  fill(x,2,18,20,71,42,100);stroke(x,2,18,20,143,94,181)
  fontText(p[2],x+1,7,16,'center',{238,224,170})
 end
 self:hit(63,2,18,21,function() self.screen='tank';self.room='main';self.selected=nil end)
 self:hit(82,2,18,21,function() self.screen='shop';self.shopPage=1 end)
 self:hit(101,2,18,21,function() self.screen='research' end)
 self:hit(120,2,18,21,function() self.screen='collection' end)
 self:hit(181,2,34,21,function() self.screen='shop';self.shopPage=1 end)
end
function Retro:fishDraw()
 self.fishHits={}
 local tank=self.g.s.tanks[self.room]
 if self.room=='second' and not self.g.s.unlocked.second then
  fill(25,114,190,34,34,24,65,.9);centered('TANK 2 LOCKED',119)
  self:menuButton('GO TO STORE',75,156,90,22,function()self.screen='shop' end)
  return
 end
 for i,f in ipairs(tank) do
  local x,y,face=Swim.position(f,i,self.room,self.time)
  local sx,sy
  if self.room=='isolation' then
   sx=83+((i-1)%2)*64;sy=281 -- isolamento de 2 peixes
  else
   sx=17+(x-70)/281*206
   sy=48+(y-233)/220*154
  end
  local scale=f.age<20 and .85 or .78
  if self.selected==f.id and self.screen=='detail' then
   stroke(sx-27,sy-16,54,35,244,217,32)
  end
  self.assets:drawFish(f,sx,sy,scale,face)
  self.fishHits[#self.fishHits+1]={id=f.id,x=sx,y=sy}
 end
end
function Retro:statsBar(f)
 fill(13,1,214,34,62,33,96);stroke(13,1,214,34,176,118,198)
 fontText('FED',17,4,30)
 fontText('HEALTH',17,17,42)
 fill(60,7,16,3,22,7,43);fill(60,7,math.max(0,16*(f.fed or 0)/100),3,160,220,102)
 fill(60,20,16,3,22,7,43);fill(60,20,math.max(0,16*(f.health or 0)/100),3,210,140,122)
 fontText(('FORM %02d'):format(f.body-1),91,4,74)
 fontText(('FIN %02d'):format(f.tail-1),91,18,74)
 fontText('AGE:'..math.floor(f.age),165,6,58)
end
function Retro:drawTank()
 self:background(self.room)
 if self.screen=='detail' then
  local f=self.selected and self.g:find(self.selected)
  if f then self:statsBar(f) else self.screen='tank';self:toolbar() end
 else self:toolbar() end
 self:fishDraw()
 self:tray()
 if self.screen=='detail' and self.selected then
  self:buttonHint({label='SELECT',fn=function()self.screen='actions' end},
   {label='BACK',fn=function()self.screen='tank';self.selected=nil end})
 else
  self:buttonHint({label='FISH',fn=function()
   local tank=self.g.s.tanks[self.room]
   if tank[1] then self.selected=tank[1].id;self.screen='detail'
   else self:notify('NO FISH IN TANK') end end},
   {label='MENU',fn=function()self.screen='pause' end})
 end
end
function Retro:title()
 local splash=self.images.splash
 if splash then rgb(255,255,255);love.graphics.draw(splash,0,0)
 else
  self:background('main')
  fill(17,61,206,79,28,13,68,.85)
  stroke(17,61,206,79,245,195,80)
  centered('FISH TYCOON',79,{253,218,118})
  centered('MOBILE - LUA',103,{240,238,213})
 end
 fill(12,180,216,124,34,18,66,.87);stroke(12,180,216,124,172,112,205)
 self:menuButton('CONTINUE',38,187,164,24,function()
  if not self.hasSave then return end
  self.screen='tank';self.room='main'
 end,not self.hasSave)
 self:menuButton('NEW GAME',38,214,164,24,function()
  if self.hasSave then self.screen='confirm' else self:startNewGame() end
 end)
 self:menuButton('OPTIONS',38,241,164,24,function()self.from='title';self.screen='settings' end)
 self:menuButton('ABOUT',38,268,164,24,function()self.screen='about' end)
end
function Retro:startNewGame()
 if not self.onNewGame then return self:notify('NEW GAME NOT AVAILABLE') end
 local ok,err,newGame=self.onNewGame()
 if not ok then return self:notify(err or 'SAVE ERROR') end
 self:setGame(newGame,true)
 self:notify('NEW GAME STARTED')
end
function Retro:confirm()
 self:background('main')
 fill(11,81,218,147,41,22,74,.93);stroke(11,81,218,147,181,108,193)
 centered('START A NEW GAME?',93,{252,218,147})
 centered('CURRENT GAME WILL BE',124)
 centered('ARCHIVED BEFORE RESET.',139)
 self:menuButton('YES, NEW GAME',34,173,173,23,function()self:startNewGame() end)
 self:menuButton('CANCEL',34,201,173,23,function()self.screen='title' end)
end
function Retro:panelTitle(title)
 self:background('main');self:toolbar()
 fill(9,37,222,242,37,22,70,.96);stroke(9,37,222,242,168,116,187)
 centered(title,49,{246,226,164})
end
function Retro:pause()
 self:panelTitle('GAME MENU')
 local entries={
  {'RETURN TO TANK',function()self.screen='tank' end},
  {'FISH SUPPLIES',function()self.screen='shop';self.shopPage=1 end},
  {'RESEARCH',function()self.screen='research' end},
  {'DISCOVERIES',function()self.screen='collection' end},
  {'SETTINGS',function()self.from='pause';self.screen='settings' end},
  {'SAVE AND MAIN MENU',function()
   if self.onSave then local ok,err=self.onSave();if not ok then return self:notify(err) end end
   self.screen='title';self.selected=nil
  end}
 }
 for i,v in ipairs(entries) do self:menuButton(v[1],31,75+(i-1)*32,178,27,v[2]) end
 self:buttonHint(nil,{label='BACK',fn=function()self.screen='tank' end})
end
function Retro:settings()
 self:panelTitle('OPTIONS')
 self:menuButton('MUSIC: '..(self.soundEnabled and 'ON' or 'OFF'),25,85,190,30,function()
  if self.onSound then self.soundEnabled=self.onSound() end
 end)
 self:menuButton('GAME SPEED: '..(self.g.s.game_speed or 1)..'X',25,122,190,30,function()
  local a=self.g.s.game_speed
  self.g.s.game_speed=a==1 and 5 or (a==5 and 20 or 1)
 end)
 self:menuButton('GROWTH: '..self.g.s.growth_minutes..' MIN',25,159,190,30,function()
  local a=self.g.s.growth_minutes
  self.g:setGrowthMinutes(a==5 and 10 or (a==10 and 15 or 5))
 end)
 centered('Settings are saved with the game.',223,{211,202,211})
 self:buttonHint(nil,{label='BACK',fn=function()self.screen=self.from or 'title' end})
end
function Retro:about()
 self:panelTitle('FISH TYCOON - LUA')
 centered('J2ME 240x320 INTERFACE',110)
 centered('ENGINE: LUA + LOVE2D',130)
 centered('ORIGINAL ART: STUDY ONLY',153)
 centered('NOT AN OFFICIAL PORT',175)
 self:buttonHint(nil,{label='BACK',fn=function()self.screen='title' end})
end
function Retro:drawActions()
 self:panelTitle('FISH MENU')
 local f=self.selected and self.g:find(self.selected)
 if not f then self.screen='tank';return end
 centered('AGE '..math.floor(f.age)..'     $'..(f.price or 0),72,{239,218,167})
 local list={
  {'FEED',function()local ok,msg=self.g:feed(f.id);self:notify(msg or ok) end},
  {'TREAT',function()self.screen='treat' end},
  {'MOVE',function()self.screen='move' end},
  {'PRICE -5',function()local ok,n=self.g:changePrice(f.id,-5);self:notify(ok and '$'..n or n) end},
  {'PRICE +5',function()local ok,n=self.g:changePrice(f.id,5);self:notify(ok and '$'..n or n) end},
  {'SELL',function()local ok,n=self.g:sell(f.id);self:notify(ok and 'SOLD!' or n);if ok then self.selected=nil;self.screen='tank' end end},
 }
 for i,v in ipairs(list) do
  local col=(i-1)%2;local row=math.floor((i-1)/2)
  self:menuButton(v[1],17+col*106,99+row*46,100,39,v[2])
 end
 self:buttonHint(nil,{label='BACK',fn=function()self.screen='detail' end})
end
function Retro:drawMove()
 self:panelTitle('MOVE FISH')
 local list={{'TANK 1','main'},{'TANK 2','second'},{'ISOLATION','isolation'},{'SALE TANK','sale'}}
 for i,v in ipairs(list) do self:menuButton(v[1],38,83+(i-1)*43,164,32,function()
  local ok,msg=self.g:move(self.selected,v[2]);self:notify(msg or (ok and 'MOVED!' or 'CANNOT MOVE'))
  if ok then self.room=v[2];self.screen='tank';self.selected=nil end
 end) end
 self:buttonHint(nil,{label='BACK',fn=function()self.screen='actions' end})
end
function Retro:drawTreat()
 self:panelTitle('TREAT FISH')
 local list={{'ICK','ick'},{'FUNGUS','fungus'},{'VITAMINS','vitamin'},{'HORMONE','hormone'},{'CHEMICAL','mutagen'}}
 for i,v in ipairs(list) do self:menuButton(v[1]..'  X'..(self.g.s.supplies[v[2]] or 0),23,75+(i-1)*39,194,32,function()
  local ok,msg=self.g:medicine(self.selected,v[2]);self:notify(msg or (ok and 'APPLIED' or 'FAILED'))
  if ok then self.screen='actions' end
 end) end
 self:buttonHint(nil,{label='BACK',fn=function()self.screen='actions' end})
end
function Retro:shop()
 self:panelTitle('FISH SUPPLIES')
 fontText('CASH: $'..self.g.s.cash,18,66,198,'right',{254,231,126})
 for i=1,5 do
  local item=Catalog.supplies[(self.shopPage-1)*5+i]
  if item then
   local y=82+(i-1)*39
   fontText(item.title:sub(1,23),18,y,144)
   fontText('$'..item.price,164,y,57,'right',{243,206,129})
   self:menuButton('BUY',172,y+13,51,21,function()
    local ok,msg=self.g:purchase(item.id)
    self:notify(ok and 'PURCHASED' or msg)
   end)
  end
 end
 self:menuButton('<',53,280,40,18,function()self.shopPage=math.max(1,self.shopPage-1) end)
 fontText(self.shopPage..'/'..math.ceil(#Catalog.supplies/5),98,284,44,'center')
 self:menuButton('>',147,280,40,18,function()self.shopPage=math.min(math.ceil(#Catalog.supplies/5),self.shopPage+1) end)
 self:buttonHint(nil,{label='BACK',fn=function()self.screen='pause' end})
end
function Retro:research()
 self:panelTitle('RESEARCH')
 for i,entry in ipairs(Catalog.research) do
  local lvl=self.g.s.research[entry.id] or 0
  local y=80+(i-1)*62
  fontText(entry.title:upper()..' '..lvl..'/3',17,y,200)
  local p=self.g:researchProjection(entry.id)
  if p then fontText(p.current:sub(1,38),17,y+14,200,'left',{194,221,206}) end
  self:menuButton('RESEARCH',28,y+30,182,25,function()
   local ok,msg=self.g:startResearch(entry.id)
   self:notify(ok and 'RESEARCH STARTED' or msg)
  end,lvl>=Config.RESEARCH_MAX or self.g.s.research_job~=false)
 end
 local job=self.g:researchInfo()
 if job then centered('IN PROGRESS: '..math.ceil(job.remaining/60)..' MIN',280) end
 self:buttonHint(nil,{label='BACK',fn=function()self.screen='pause' end})
end
function Retro:collection()
 self:panelTitle('MAGIC FISH')
 centered(self.g:countMagic()..' / 7 DISCOVERED',71,{241,219,144})
 for i,v in ipairs(Catalog.magic) do
  local found=self.g.s.magic[tostring(i)]
  fontText((found and v.name or '????  -  FISH '..i),20,95+(i-1)*25,200,'left',found and {233,229,158} or {172,147,186})
 end
 self:buttonHint(nil,{label='BACK',fn=function()self.screen='pause' end})
end
function Retro:draw()
 local gw,gh=love.graphics.getDimensions()
 self.scale=math.min(gw/W,gh/H)
 -- manter pixels nitidos em 2x/3x sempre que possivel
 if self.scale>=1 then self.scale=math.max(1,math.floor(self.scale)) end
 self.ox=math.floor((gw-W*self.scale)/2);self.oy=math.floor((gh-H*self.scale)/2)
 love.graphics.clear(.04,.03,.10,1)
 self.buttons={};self.fishHits={}
 love.graphics.push();love.graphics.translate(self.ox,self.oy);love.graphics.scale(self.scale)
 love.graphics.setFont(self.font)
 if self.screen=='title' then self:title()
 elseif self.screen=='confirm' then self:confirm()
 elseif self.screen=='tank' or self.screen=='detail' then self:drawTank()
 elseif self.screen=='pause' then self:pause()
 elseif self.screen=='settings' then self:settings()
 elseif self.screen=='about' then self:about()
 elseif self.screen=='actions' then self:drawActions()
 elseif self.screen=='move' then self:drawMove()
 elseif self.screen=='treat' then self:drawTreat()
 elseif self.screen=='shop' then self:shop()
 elseif self.screen=='research' then self:research()
 elseif self.screen=='collection' then self:collection()
 end
 if self.toastTime>0 then
  fill(10,263,220,23,46,23,71,.95)
  fontText(self.toast:sub(1,52),14,268,212,'center',{251,229,153})
 end
 love.graphics.pop()
end
function Retro:press(px,py)
 local x=(px-self.ox)/self.scale
 local y=(py-self.oy)/self.scale
 if x<0 or x>=W or y<0 or y>=H then return false end
 -- Clicar em um peixe abre a mesma tela de selecao observada no J2ME.
 if self.screen=='tank' then
  local closest,best=nil,math.huge
  for _,hit in ipairs(self.fishHits) do
   local dx,dy=x-hit.x,y-hit.y
   local distance=dx*dx+dy*dy
   if math.abs(dx)<26 and math.abs(dy)<16 and distance<best then
    closest,best=hit,distance
   end
  end
  if closest then self.selected=closest.id;self.screen='detail';return true end
 end
 for i=#self.buttons,1,-1 do
  local b=self.buttons[i]
  if x>=b.x and x<=b.x+b.w and y>=b.y and y<=b.y+b.h then
   b.fn();return true
  end
 end
 return false
end
function Retro:key(k)
 if k=='escape' or k=='back' then
  local back={title='title',confirm='title',tank='pause',detail='tank',pause='tank',
   settings=self.from or 'title',actions='detail',move='actions',treat='actions',
   shop='pause',research='pause',collection='pause',about='title'}
  self.screen=back[self.screen] or 'title'
  if self.screen=='tank' then self.selected=nil end
 elseif k=='return' or k=='kpenter' then
  if self.screen=='title' and self.hasSave then self.screen='tank'
  elseif self.screen=='detail' then self.screen='actions' end
 end
end
return Retro
