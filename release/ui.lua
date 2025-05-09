
local _a,aa,ba,ca=(function(da)local _b={[{}]=true}local ab;local bb={}local cb;local db={}ab=function(_c,ac)
if not bb[_c]then bb[_c]=ac end end
cb=function(_c)local ac=db[_c]
if ac then if ac==_b then
return nil end else
if not bb[_c]then
if not da then local bc=
type(_c)=='string'and'\"'.._c..'\"'or tostring(_c)
error(
'Tried to require '..bc..', but no such module has been registered')else return da(_c)end end;db[_c]=_b;ac=bb[_c](cb,db,ab,bb)db[_c]=ac end;return ac end;return cb,db,ab,bb end)(require)
ba("__root",function(da,_b,ab,bb)
local cb={Core=da("ccui.core"),Components=da("ccui.components"),Util=da("ccui.util"),new=da("ccui.core").new}return cb end)
ba("ccui.core",function(da,_b,ab,bb)local cb=da("ccui.components.Component")
local db=da("ccui.components.Frame")local _c=da("ccui.util")local ac={}ac.__index=ac;local bc=term
function ac.new(cc)
local dc=setmetatable({},ac)dc.term=cc or bc.current()
dc.root=db.new({term=dc.term})dc.running=false;dc.events={}local _d=dc.events["alarm"]return dc end
function ac:clearScreen()self.term.clear()
self.term.setCursorPos(1,1)self.term.setTextColor(colors.white)
self.term.setBackgroundColor(colors.black)end;function ac:renderUI()self:clearScreen()
self.root:render(self.term)end
function ac:addEventListener(cc,dc)if not self.events[cc]then
self.events[cc]={}end
table.insert(self.events[cc],dc)return self,dc end
function ac:removeEventListener(cc,dc)if not self.events[cc]then return self end;for _d,ad in
ipairs(self.events[cc])do
if ad==dc then table.remove(self.events[cc],_d)break end end;return self end
function ac:start()self.root:mount(self)self:renderUI()
self.running=true
while self.running do self:renderUI()local cc,dc,_d,ad=os.pullEvent()
if
self.events[cc]then for bd,cd in ipairs(self.events[cc])do cd(dc,_d,ad)end end end;self:clearScreen()return self end;function ac:stop()self.running=false;return self end;return ac end)
ba("ccui.util",function(da,_b,ab,bb)local cb={}local db=0;function cb.generateUniqueId()db=db+1;return db end;function cb.pointInRect(_c,ac,bc)
return

_c>=bc.x and _c<=bc.x+bc.width-1 and ac>=bc.y and ac<=bc.y+bc.height-1 end;return cb end)
ba("ccui.components.Frame",function(da,_b,ab,bb)local cb=da("ccui.components.Component")local db={}
setmetatable(db,cb)db.__index=db
function db.new(_c)local ac=cb.new(_c)setmetatable(ac,db)
local bc,cc=term.getSize()ac.props.type="frame"ac.props.x=_c.x or 1
ac.props.y=_c.y or 1;ac.props.width=_c.width or bc
ac.props.height=_c.height or cc;return ac end
function db:render(_c)local ac=self:getProps("x")local bc=self:getProps("y")
local cc=self:getProps("bgColor")local dc=self:getProps("fgColor")
local _d=self:getProps("width")local ad=self:getProps("height")_c.setCursorPos(ac,bc)if cc then
_c.setBackgroundColor(cc)end;if dc then _c.setTextColor(dc)end;for i=1,ad do
_c.write(string.rep(" ",_d))end;_c.setCursorPos(ac,bc)
cb.render(self,_c)end;return db end)
ba("ccui.components.Component",function(da,_b,ab,bb)local cb=da("ccui.util")local db={}db.__index=db
function db.new(_c)
local ac=setmetatable({},db)ac.props={}ac.props.type="component"ac.props.x=1;ac.props.y=1
ac.props.width=1;ac.props.height=1;for bc,cc in pairs(_c)do ac.props[bc]=cc end;if
_c.id==nil then
ac.props.id=tostring(cb.generateUniqueId())end;ac.parent=nil;ac.children={}
ac.eventListeners={}return ac end
function db:findById(_c)if self:getProps("id")==_c then return self end
for ac,bc in
ipairs(self.children)do local cc=bc:findById(_c)if cc then return cc end end end
function db:getProps(_c,ac)local bc=self.props[_c]if type(bc)=="function"then return bc(self)elseif
bc==nil then return ac else return bc end end
function db:add(_c)_c.parent=self;table.insert(self.children,_c)if self.core then
_c:mount(self.core)end;return self end
function db:mount(_c)self.core=_c;if self.eventListeners then
for ac,bc in pairs(self.eventListeners)do for cc,dc in ipairs(bc)do
_c:addEventListener(ac,dc)end end end;for ac,bc in
ipairs(self.children)do bc:mount(_c)end end
function db:unmount()
if self.core and self.eventListeners then for _c,ac in pairs(self.eventListeners)do
for bc,cc in
ipairs(ac)do self.core:removeEventListener(_c,cc)end end end;for _c,ac in ipairs(self.children)do ac:unmount()end
self.core=nil end
function db:on(_c,ac)if not self.eventListeners[_c]then
self.eventListeners[_c]={}end
local bc=function(...)ac(self,...)end;table.insert(self.eventListeners[_c],bc)return
self,bc end
function db:off(_c,ac)if not self.eventListeners[_c]then return self end
for bc,cc in
ipairs(self.eventListeners[_c])do if cc==ac then
table.remove(self.eventListeners[_c],bc)break end end;return self end
function db:hitTest(_c,ac)return
cb.pointInRect(_c,ac,{x=self:getProps("x"),y=self:getProps("y"),width=self:getProps("width"),height=self:getProps("height")})end
function db:onClick(_c)
self:on("mouse_click",function(ac,bc,cc,dc)
if bc==1 and self:hitTest(cc,dc)then _c(self)end end)return self end
function db:render(_c)local ac=self:getProps("x")local bc=self:getProps("y")
local cc=self:getProps("bgColor")local dc=self:getProps("fgColor")if ac and bc then
_c.setCursorPos(ac,bc)end;for _d,ad in ipairs(self.children)do if cc then
_c.setBackgroundColor(cc)end;if dc then _c.setTextColor(dc)end
ad:render(_c)end end;return db end)
ba("ccui.components",function(da,_b,ab,bb)
local cb={Component=da("ccui.components.Component"),Frame=da("ccui.components.Frame"),Label=da("ccui.components.Label"),Button=da("ccui.components.Button")}return cb end)
ba("ccui.components.Button",function(da,_b,ab,bb)local cb=da("ccui.components.Component")local db={}
setmetatable(db,cb)db.__index=db
function db.new(_c)local ac=cb.new(_c)setmetatable(ac,db)
ac.props.type="button"ac.props.text=_c.text or""
ac.props.width=_c.width or function(bc)return
#bc:getProps("text")+2 end;ac.props.height=_c.height or 1;return ac end
function db:render(_c)local ac=self:getProps("bgColor",colors.white)
local bc=self:getProps("fgColor",colors.black)local cc=self:getProps("x")local dc=self:getProps("y")
local _d=self:getProps("width")local ad=self:getProps("height")
local bd=self:getProps("text")local cd=dc+math.floor((ad-1)/2)
_c.setBackgroundColor(ac)_c.setTextColor(bc)_c.setCursorPos(cc,dc)for i=1,ad do _c.setCursorPos(cc,
dc+i-1)
_c.write(string.rep(" ",_d))end;_c.setCursorPos(cc+1,cd)
_c.write(bd)_c.setBackgroundColor(colors.black)
_c.setTextColor(colors.white)cb.render(self,_c)end;return db end)
ba("ccui.components.Label",function(da,_b,ab,bb)local cb=da("ccui.components.Component")local db={}
setmetatable(db,cb)db.__index=db
function db.new(_c)local ac=cb.new(_c)setmetatable(ac,db)
ac.props.type="label"ac.props.text=_c.text or""
ac.props.width=_c.width or function(bc)return
#bc:getProps("text")end;return ac end;function db:setText(_c)self.props.text=_c;return self end
function db:render(_c)
local ac=self:getProps("x")local bc=self:getProps("y")
local cc=self:getProps("fgColor",colors.white)local dc=self:getProps("bgColor",colors.black)
local _d=self:getProps("text")_c.setCursorPos(ac,bc)
_c.blit(_d,string.rep(colors.toBlit(cc),#_d),string.rep(colors.toBlit(dc),
#_d))cb.render(self,_c)end;return db end)return _a("__root")