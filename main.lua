local Game=require('core.game')
local Storage=require('core.storage')
local View=require('ui.view')
local Audio=require('core.audio')
local OfflineReport=require('core.offline_report')
local game,view,music,nativeSmoke
local autosave=0
local suppressMouseUntil=0
local focused=true

local function save()
 return Storage.save(game)
end

function love.load()
 if os.getenv('FISH_NATIVE_SMOKE')=='1' then
  -- Teste isolado: nao le nem grava a partida do jogador.
  game=Game.new(1600)
  for i=5,18 do
   assert(game:addFish('main',((i-1)%21)+1,((i*3-1)%21)+1,20))
  end
  view=View.new(game);view:init()
  nativeSmoke=require('core.native_smoke').new(view)
  return
 end
 local loaded,err=Storage.load()
 game=loaded or Game.new()
 local before=loaded and OfflineReport.snapshot(game) or nil
 local passed=loaded and game:offline(os.time()) or 0
 local report=OfflineReport.build(before,game,passed)
 view=View.new(game);view:init();view.onSave=save
 if passed>=60 then view:showOfflineReport(report) end
 music=Audio.new();music:init();view.onSound=function() return music:toggle() end
 if err and loaded then view:notify(err)
 elseif passed>60 then view:notify('Progresso offline: '..math.floor(passed/60)..' min simulados')
 elseif err and err~='Sem salvamento anterior' then view:notify(err) end
end

function love.update(dt)
 if nativeSmoke then view:update(math.min(dt,1));return end
 if not focused then return end
 dt=math.min(dt,1)
 game:advance(dt*game.s.game_speed)
 view:update(dt)
 if music then music:update(view.page,view.room) end
 autosave=autosave+dt
 if autosave>=12 then
  autosave=0
  save()
 end
end

function love.draw()
 view:draw()
 if nativeSmoke then nativeSmoke:afterDraw() end
end
function love.mousepressed(x,y,button)
 if button~=1 then return end
 if love.timer.getTime()<suppressMouseUntil then return end
 view:press(x,y)
end
function love.touchpressed(id,x,y)
 suppressMouseUntil=love.timer.getTime()+.5
 view:press(x,y)
end
function love.keypressed(key) view:key(key) end
function love.focus(f)
 focused=f
 if not f then if music then music:pause() end;save()
 else
  local before=OfflineReport.snapshot(game)
  local passed=game:offline(os.time())
  if passed>=60 then view:showOfflineReport(OfflineReport.build(before,game,passed)) end
 end
end
function love.quit()
 if not nativeSmoke then save() end
end
