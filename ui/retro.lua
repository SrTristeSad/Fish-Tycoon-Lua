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
  speed=1,soundEnabled=true,shopPage=1,selectedShopIndex=1,toast='',toastTime=0,time=0,browseIndex=1,
  scale=1,ox=0,oy=0,onSave=nil,onNewGame=nil,onSound=nil},Retro)
end
function Retro:init()
 self.assets:init()
 for _,name in ipairs({'splash','assets','gameMenuTank','menutank','store'}) do
  self.images[name]=load(name)
 end
 self.font=love.graphics.newFont(9)
 self.font:setFilter('nearest','nearest')
 -- Partes do atlas PNG original; alternativas simples sao exibidas
 -- quando o proprietario ainda nao importou assets.png de seu JAR.
 self.quads={}
 local atlas=self.images.assets
 if atlas and love.graphics.newQuad then
  local iw,ih=atlas:getDimensions()
  local coords={slot={20,153,18,25},fish={88,219,16,23},
   food={115,181,21,36},cart={31,218,23,24},
   hourglass={125,94,11,14},money={111,157,20,23},
   breed={113,113,23,18},medicine={113,181,21,36},
   arrow={94,123,24,12},heart={104,132,28,25}}
  for name,c in pairs(coords) do
   if c[1]+c[3]<=iw and c[2]+c[4]<=ih then
    self.quads[name]={q=love.graphics.newQuad(c[1],c[2],c[3],c[4],iw,ih),w=c[3],h=c[4]}
   end
  end
 end
 -- Itens recortados do atlas store.png do JAR (113x123).
 -- As coordenadas sao do arquivo original, e NAO de imagens recriadas.
 -- Nem todos os produtos tiveram sprite individual identificado: nesses
 -- casos, o layout usa o quadro de reserva sem desenhar sprite incorreto.
 self.storeQuads={}
 local store=self.images.store
 if store and love.graphics.newQuad then
  local iw,ih=store:getDimensions()
  local coords={food={97,52,15,20},ick={86,52,23,25},fungus={92,46,18,23},
   vitamin={23,73,22,25},hormone={23,46,24,29},mutagen={52,1,23,24},
   eggs={84,0,23,25},aerator={57,21,18,23},heater={94,83,17,23},
   snail={77,104,18,16},plant={61,53,21,29},
   curing_plant={31,28,25,22},fertility_plant={31,52,22,23},
   decor={64,100,19,20},second={25,1,30,19}}
  for id,q in pairs(coords) do
   if q[1]+q[3]<=iw and q[2]+q[4]<=ih then
    self.storeQuads[id]={quad=love.graphics.newQuad(q[1],q[2],q[3],q[4],iw,ih),w=q[3],h=q[4]}
   end
  end
 end
 -- Miniaturas nativas dos tres tanques na barra de ferramentas.
 self.tankIcons={}
 for i,name in ipairs({'tank1','tank2','tank3'}) do
  local image=self.assets.images[name]
  if image and love.graphics.newQuad then
   local iw,ih=image:getDimensions()
   self.tankIcons[i]={image=image,quad=love.graphics.newQuad(45,35,70,75,iw,ih)}
  end
 end
end
function Retro:setGame(game,hasSave)
 self.g=game;self.hasSave=not not hasSave
 self.selected=nil;self.browseIndex=1;self.room='main';self.screen='tank';self.popup=nil
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
-- Desenha os icones do atlas comercial, sem modificar nenhum sprite PNG.
function Retro:atlasIcon(name,x,y,w,h)
 local atlas=self.images.assets
 local entry=self.quads and self.quads[name]
 if not atlas or not entry then return false end
 rgb(255,255,255)
 love.graphics.draw(atlas,entry.q,x,y,0,w/entry.w,h/entry.h)
 return true
end
function Retro:toolbar()
 fill(0,0,240,25,41,22,69)
 fill(0,0,240,2,124,82,163)
 fill(0,23,240,2,17,9,37)
 local menu={
  {tip='1',kind='tank',room='main'},
  {tip='2',kind='tank',room='second'},
  {tip='3',kind='tank',room='sale'},
  {tip='F',kind='fish',icon='fish'},
  {tip='E',kind='feed',icon='food'},
  {tip='M',kind='medicine',icon='medicine'},
  {tip='B',kind='breed',icon='breed'},
  {tip='?',kind='species',icon='heart'},
  {tip='S',kind='shop',icon='cart'},
  {tip='R',kind='research',icon='hourglass'},
  {tip='$',kind='cash',icon='money'},
 }
 for i,item in ipairs(menu) do
  local x=(i-1)*19
  if not self:atlasIcon('slot',x,1,19,22) then
   fill(x,2,18,20,76,44,102);stroke(x,2,18,20,153,99,188)
  end
  local active=(item.room and item.room==self.room) or
   (item.kind=='fish' and self.screen=='detail')
  if active then stroke(x+1,3,17,18,239,222,70) end
  if item.kind=='tank' then
   local idx=i
   local preview=self.tankIcons[idx]
   if preview then
    rgb(255,255,255)
    love.graphics.draw(preview.image,preview.quad,x+3,5,0,13/70,13/75)
   else fontText(item.tip,x+2,7,15,'center',{224,252,180}) end
   fontText(item.tip,x+11,13,7,'right',{255,249,153})
  elseif not self:atlasIcon(item.icon,x+3,4,13,15) then
   fontText(item.tip,x+2,7,15,'center',{230,223,185})
  end
  self:hit(x,2,19,21,function()
   if item.kind=='tank' then
    if item.room=='second' and not self.g.s.unlocked.second then
     self:notify('TANK 2: BUY AT STORE')
    else self.room=item.room;self.screen='tank';self.selected=nil;self.browseIndex=1 end
   elseif item.kind=='fish' then self:beginBrowse()
   elseif item.kind=='feed' then
    local ok,msg
    if self.selected then ok,msg=self.g:feed(self.selected)
    else ok,msg=self.g:feedTank(self.room) end
    self:notify(msg or (ok and 'FISH FED' or 'NO FOOD'))
   elseif item.kind=='medicine' then
    if self.selected then self.screen='treat' else self:notify('SELECT A FISH FIRST') end
   elseif item.kind=='breed' then
    if self.room=='isolation' then
     local ok,msg=self.g:breed();self:notify(msg or (ok and 'BREEDING' or 'NEED TWO ADULTS'))
    else self:notify('BREED IN ISOLATION') end
   elseif item.kind=='species' then
    if self.selected then self.screen='detail' else self:notify('SELECT A FISH FIRST') end
   elseif item.kind=='shop' or item.kind=='cash' then self.screen='shop';self.shopPage=1
   elseif item.kind=='research' then self.screen='research' end
  end)
 end
 rgb(223,235,193)
 fontText('$'..math.floor(self.g.s.cash),211,8,29,'right',{240,223,162})
end
function Retro:beginBrowse()
 local tank=self.g.s.tanks[self.room]
 if not tank or #tank==0 then return self:notify('NO FISH IN TANK') end
 self.browseIndex=math.max(1,math.min(self.browseIndex,#tank))
 self.selected=tank[self.browseIndex].id
 self.screen='detail'
end
function Retro:browseFish(direction)
 local tank=self.g.s.tanks[self.room]
 if not tank or #tank==0 then self.selected=nil;self.screen='tank';return false end
 for i,f in ipairs(tank) do if f.id==self.selected then self.browseIndex=i;break end end
 self.browseIndex=(self.browseIndex-1+(direction or 0))%#tank+1
 self.selected=tank[self.browseIndex].id
 return true
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
   -- Marcador de navegacao visto na captura original do J2ME.
   stroke(sx-28,sy-15,56,32,242,208,28)
  end
  self.assets:drawFish(f,sx,sy,scale,face)
  if self.room=='sale' and f.age>=20 and self.screen=='tank' then
   fill(sx-19,sy+12,38,10,63,34,19,.91)
   fontText('For Sale!',sx-19,sy+12,38,'center',{239,217,148})
  end
  self.fishHits[#self.fishHits+1]={id=f.id,x=sx,y=sy}
 end
end
function Retro:statsBar(f)
 fill(13,1,214,34,62,33,96);stroke(13,1,214,34,176,118,198)
 fontText('FED',17,4,30)
 fontText('HEALTH',17,17,42)
 fill(60,7,16,3,22,7,43);fill(60,7,math.max(0,16*(f.fed or 0)/100),3,160,220,102)
 fill(60,20,16,3,22,7,43);fill(60,20,math.max(0,16*(f.health or 0)/100),3,210,140,122)
 -- Nomes recuperados da tabela inglesa do JAR, indices 51..92.
 local fullname=Catalog.nameFor(f.body,f.tail)
 local finName=Catalog.finNames[f.tail] or 'FIN'
 local bodyName=Catalog.bodyNames[f.body] or 'FISH'
 fontText(finName,90,4,69,'center',{243,246,222})
 fontText(bodyName,90,18,69,'center',{243,246,222})
 fontText('AGE:'..math.floor(f.age),165,6,58)
end
function Retro:drawTank()
 self:background(self.room)
 if self.screen=='detail' then
  local f=self.selected and self.g:find(self.selected)
  if f then self:statsBar(f) else self.screen='tank';self:toolbar() end
 else self:toolbar() end
 self:tray() -- o peixe isolado deve ser desenhado SOBRE o recipiente
 self:fishDraw()
 if self.screen=='detail' and self.selected then
  self:buttonHint({label='SELECT',fn=function()self.screen='actions' end},
   {label='BACK',fn=function()self.screen='tank';self.selected=nil end})
 else
  local left
  if self.room=='isolation' then
   left={label='BREED',fn=function()
    local ok,msg=self.g:breed()
    self:notify(msg or (ok and 'BREEDING STARTED' or 'SELECT 2 ADULT FISH'))
   end}
  elseif self.room=='sale' then
   left={label=self.g.s.sale_open and 'CLOSE' or 'OPEN',fn=function()
    self.g.s.sale_open=not self.g.s.sale_open
    self:notify(self.g.s.sale_open and 'SALES OPEN' or 'SALES CLOSED')
   end}
  else
   left={label='FISH',fn=function()
    local tank=self.g.s.tanks[self.room]
    self:beginBrowse()
   end}
  end
  self:buttonHint(left,{label='MENU',fn=function()self.screen='pause' end})
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
-- Rótulos compactos no idioma das capturas fornecidas; custos do motor
-- Lua permanecem provisórios, não apresentados como valores do JAR.
local supplyLabels={food='FISH FOOD',ick='ICK TREATMENT',fungus='FUNGUS CURE',
 vitamin='VITAMINS',hormone='GROWTH HORMONE',mutagen='UNKNOWN CHEMICAL',
 eggs='FISH EGGS',aerator='AERATOR',heater='HEATER',snail='CLEANER SNAIL',
 plant='NUTRIENT PLANT',curing_plant='MEDICINAL PLANT',
 fertility_plant='FERTILITY PLANT',decor='DECORATIONS',second='TANK 2'}
local supplyNotes={food='FOOD FOR THE TANK',ick='TREAT FISH WITH ICK',
 fungus='TREAT FUNGUS',vitamin='IMPROVE FISH HEALTH',
 hormone='SPEED UP GROWTH',mutagen='MAY CHANGE FISH',
 eggs='HATCH NEW FISH',aerator='IMPROVE WATER',heater='CONTROL TEMPERATURE',
 snail='KEEP WATER CLEAN',plant='HELP FEED FISH',
 curing_plant='SUPPORT FISH HEALTH',fertility_plant='MORE BABY FISH',
 decor='ATTRACT CUSTOMERS',second='UNLOCK ANOTHER TANK'}
function Retro:storeIcon(id,x,y)
 local atlas=self.images.store
 local sprite=self.storeQuads and self.storeQuads[id]
 if not atlas or not sprite then return false end
 rgb(255,255,255)
 local sc=math.min(27/sprite.w,28/sprite.h,1.35)
 love.graphics.draw(atlas,sprite.quad,x+(28-sprite.w*sc)/2,
  y+(29-sprite.h*sc)/2,0,sc,sc)
 return true
end
function Retro:shop()
 self:panelTitle('FISH SUPPLIES')
 local total=#Catalog.supplies
 local pages=math.ceil(total/4)
 self.shopPage=math.max(1,math.min(self.shopPage,pages))
 local startIndex=(self.shopPage-1)*4+1
 if not self.selectedShopIndex or self.selectedShopIndex<startIndex
    or self.selectedShopIndex>startIndex+3 then
  self.selectedShopIndex=startIndex
 end
 fontText('CASH $'..math.floor(self.g.s.cash),20,66,201,'right',{255,238,139})
 for row=0,3 do
  local i=startIndex+row
  local item=Catalog.supplies[i]
  if item then
   local y=83+row*43
   fill(15,y,210,39,48,25,80,.9)
   stroke(15,y,210,39,117,75,145)
   if self.selectedShopIndex==i then
    stroke(16,y+1,208,37,241,210,45)
   end
   if not self:storeIcon(item.id,20,y+4) then
    fill(21,y+5,27,28,69,45,104)
    fontText('?',27,y+13,15,'center',{222,205,152})
   end
   fontText(supplyLabels[item.id] or item.title:upper(),54,y+6,156,'left',
    {245,241,207})
   fontText('$'..tostring(item.price),54,y+22,57,'left',{254,220,119})
   self:menuButton('BUY',171,y+20,48,18,function()
    self.selectedShopIndex=i
    local ok,msg=self.g:purchase(item.id)
    self:notify(ok and 'PURCHASED' or msg)
   end)
   self:hit(15,y,153,39,function() self.selectedShopIndex=i end)
  end
 end
 local item=Catalog.supplies[self.selectedShopIndex]
 fill(15,257,210,22,32,17,59,.94)
 stroke(15,257,210,22,120,83,156)
 if item then
  fontText(supplyNotes[item.id] or (item.desc or ''):upper():sub(1,33),19,265,202,'center',{215,213,191})
 end
 self:menuButton('<',55,281,36,17,function()
  self.shopPage=math.max(1,self.shopPage-1)
  self.selectedShopIndex=(self.shopPage-1)*4+1
 end,self.shopPage<=1)
 fontText(self.shopPage..'/'..pages,100,284,40,'center',{246,228,180})
 self:menuButton('>',148,281,36,17,function()
  self.shopPage=math.min(pages,self.shopPage+1)
  self.selectedShopIndex=(self.shopPage-1)*4+1
 end,self.shopPage>=pages)
 self:buttonHint(nil,{label='BACK',fn=function()self.screen='pause' end})
end
function Retro:research()
 self:panelTitle('RESEARCH')
 local active=self.g:researchInfo()
 for i,entry in ipairs(Catalog.research) do
  local lvl=self.g.s.research[entry.id] or 0
  local y=77+(i-1)*65
  fill(16,y,208,60,49,29,84,.95)
  stroke(16,y,208,60,134,94,161)
  fontText(entry.title:upper(),23,y+5,116,'left',{249,225,154})
  fontText('LEVEL '..lvl..'/'..Config.RESEARCH_MAX,137,y+5,78,'right')
  -- Barra de nivel, inspirada na apresentacao compacta J2ME.
  fill(23,y+21,130,5,17,9,34)
  local progress=math.floor(130*lvl/Config.RESEARCH_MAX)
  fill(23,y+21,progress,5,112,197,87)
  local preview=self.g:researchProjection(entry.id)
  if preview then
   -- Texto curto: nao invadir o botao START na tela 240x320.
   local summary
   if entry.id=='food' then
    summary='FOOD USE '..(preview.current:match('(%d+)%%') or '?')..'%/CYCLE'
   elseif entry.id=='environment' then
    summary='HEALTH '..(preview.current:match('([%+%-]?%d+%.?%d*)/ciclo') or '?')..'/CYCLE'
   else
    summary='SHOP INTEREST '..(preview.current:match('(%d+)
  local disabled=lvl>=Config.RESEARCH_MAX or (self.g.s.research_job~=false and self.g.s.research_job~=nil)
  self:menuButton(lvl>=Config.RESEARCH_MAX and 'MAX' or 'START',157,y+42,57,16,function()
   local ok,msg=self.g:startResearch(entry.id)
   self:notify(ok and 'RESEARCH STARTED' or msg)
  end,disabled)
 end
 fill(16,275,208,21,34,20,61,.96)
 if active then
  fontText('IN PROGRESS: '..math.ceil(active.remaining/60)..' MIN',18,281,204,'center',
   {225,227,167})
 else
  fontText('CHOOSE A FIELD TO RESEARCH',18,281,204,'center',{211,204,189})
 end
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
  if closest then
   self.selected=closest.id;self.screen='detail'
   for i,f in ipairs(self.g.s.tanks[self.room]) do
    if f.id==closest.id then self.browseIndex=i;break end
   end
   return true
  end
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
 -- Navegacao classica dos aparelhos Java: 4/6 (anterior/proximo),
 -- 2/8 para percorrer e 5 para selecionar. Mouse e toque continuam.
 if self.screen=='detail' and (k=='left' or k=='right' or k=='up' or k=='down' or k=='4' or k=='6' or k=='2' or k=='8' or k=='kp4' or k=='kp6') then
  self:browseFish((k=='left' or k=='up' or k=='4' or k=='2' or k=='kp4') and -1 or 1)
  return
 end
 if (k=='f' or k=='space') and self.screen=='tank' then self:beginBrowse();return end
 if (k=='5' or k=='kp5') and self.screen=='detail' then self.screen='actions';return end
 if k=='escape'  or k=='back' then
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
return Retro) or '?')
   end
   fontText(summary,23,y+29,186,'left',{201,219,190})
  end
  local disabled=lvl>=Config.RESEARCH_MAX or (self.g.s.research_job~=false and self.g.s.research_job~=nil)
  self:menuButton(lvl>=Config.RESEARCH_MAX and 'MAX' or 'START',157,y+42,57,16,function()
   local ok,msg=self.g:startResearch(entry.id)
   self:notify(ok and 'RESEARCH STARTED' or msg)
  end,disabled)
 end
 fill(16,275,208,21,34,20,61,.96)
 if active then
  fontText('IN PROGRESS: '..math.ceil(active.remaining/60)..' MIN',18,281,204,'center',
   {225,227,167})
 else
  fontText('CHOOSE A FIELD TO RESEARCH',18,281,204,'center',{211,204,189})
 end
 self:buttonHint(nil,{label='BACK',fn=function()self.screen='pause' end})
end
