-- RE4 map teleport. F6 target / F7 undo. No save-file edits.
local back, pending, verifying
local context_address
local notice_until=0
local status='F6: map target | F7: return'
local keys={}
local query=sdk.create_instance('via.physics.CastRayQuery'):add_ref()
local result=sdk.create_instance('via.physics.CastRayResult'):add_ref()
local ct=sdk.find_type_definition('via.physics.ContactPoint')
local function v(p) return {x=p.x,y=p.y,z=p.z} end
local function pos(ctx) return ctx:call('get_BodyGameObject'):call('get_Transform'):call('get_Position') end
local function report(t) notice_until=os.clock()+5;t.status=status;json.dump_file('codex_map_teleport_status.json',t) end
local function warp(ctx,t)
 local p=sdk.create_instance('via.vec3')
 local ty=sdk.find_type_definition('via.vec3')
 for _,k in ipairs({'x','y','z'}) do sdk.set_native_field(p,ty,k,t[k]) end
 local quat=sdk.create_instance('via.Quaternion');local qt=sdk.find_type_definition('via.Quaternion');local rot=ctx:call('get_BodyGameObject'):call('get_Transform'):call('get_Rotation');for _,k in ipairs({'x','y','z','w'}) do sdk.set_native_field(quat,qt,k,rot[k]) end;local si=sdk.create_instance('chainsaw.StageIdentifier')
 si:call('setup(chainsaw.LocID, chainsaw.StageID, chainsaw.AreaID)',math.floor(t.stage/1000)*1000,t.stage,0)
 sdk.get_managed_singleton('chainsaw.CharacterManager'):call('requestWarp(chainsaw.ContextID, System.Nullable`1<via.vec3>, System.Nullable`1<via.Quaternion>, chainsaw.StageIdentifier)',ctx:get_field('_ID'),p,quat,si)
end
local function ground(mm,p,captured)
 local mp=captured
 query:call('setRay(via.vec3, via.vec3)',Vector3f.new(mp.x,p.y+150,mp.z),Vector3f.new(mp.x,p.y-150,mp.z))
 query:call('clearOptions');query:call('enableAllHits');query:call('enableNearSort')
 local f=query:call('get_FilterInfo');f:call('set_Group',0);f:call('set_MaskBits',2);f:call('set_Layer',2);query:call('set_FilterInfo',f)
 result:call('clear')
 sdk.call_native_func(sdk.get_native_singleton('via.physics.System'),sdk.find_type_definition('via.physics.System'),'castRay(via.physics.CastRayQuery, via.physics.CastRayResult)',query,result)
 local dm=sdk.get_managed_singleton('chainsaw.LevelMapDataManager')
 local sections=dm:call('getFloorSections',mm:call('get_CurrMapSceneID'),mp.floor)
 local dict=dm:get_field('_SectionInfo');local groupdict={};local entries=dict:get_field('_entries');if entries then for _,en in ipairs(entries:get_elements()) do local val=en:get_field('value');if val then groupdict[en:get_field('key')]=val end end end
 local candidates={}
 for i=0,result:call('get_NumContactPoints')-1 do
  local cp=result:call('getContactPoint',i)
  local hp=sdk.get_native_field(cp,ct,'Position');local normal=sdk.get_native_field(cp,ct,'Normal');local col=result:call('getContactCollidable',i);local go=col and col:call('get_GameObject');local name=go and go:call('get_Name') or '';local pre,num=name:match('^st(%d+)_(%d+)');local hitstage=pre and (tonumber(pre)*1000+tonumber(num))

  if normal.y>0.65 and sections then
   local checkpos=Vector3f.new(hp.x,hp.y+0.15,hp.z)
   for _,sec in ipairs(sections:get_elements()) do
    local stage=sec:get_field('ID');local group=sec:get_field('Group')
    local groups=groupdict[stage]
    if hitstage==stage then
     local g=groups and group>=0 and group<groups:get_size() and groups:get_element(group)
     if (not g and group==0) or (g and g:call('check',checkpos)) then
      local t=v(hp);t.y=t.y+0.15;t.stage=stage;t.floor=mp.floor;candidates[#candidates+1]=t
     end
    end
   end
  end
 end
 local current=sdk.get_managed_singleton('chainsaw.CharacterManager'):call('getPlayerContextRef'):call('get_CurrentStageID');table.sort(candidates,function(a,b) local da=math.abs(a.y-p.y)+(a.stage==current and 0 or 0.3);local db=math.abs(b.y-p.y)+(b.stage==current and 0 or 0.3);return da<db end)

 return candidates[1]
end
local function close_map()
 local hub=sdk.get_managed_singleton('chainsaw.HighwayGuiManager')
 if hub then hub:call('closeCsItemWindowGui') end
end
local function action(kind)
 if pending or verifying then return end
 local cm=sdk.get_managed_singleton('chainsaw.CharacterManager')
 local ctx=cm and cm:call('getPlayerContextRef');if not ctx then status='Load a save first';return end
 local mm=sdk.get_managed_singleton('chainsaw.MapManager')
 if kind=='return' then
  if not back then status='No return point';return end
  pending={x=back.x,y=back.y,z=back.z,stage=back.stage,created=os.clock()};status='Returning';if mm:call('isMapGuiOpen') then close_map() end;return
 end
 if not mm:call('isMapGuiOpen') then status='Open map first';return end
 local offset=mm:call('get_MapGuiPos')
 local gui=mm:call('revertRotation',Vector3f.new(-offset.x,-offset.y,-offset.z))
 local mp=v(mm:call('ConvertGuiPosToGamePos',gui));mp.floor=mm:call('get_CurrMapFloorID')
 pending={maptarget=mp,created=os.clock()}
 status='Closing map, preparing teleport'
 report({captured=mp});close_map()

end
re.on_frame(function()
 local ok,err=pcall(function()
  if pending or verifying or os.clock()<notice_until then draw.text('Map Teleport: '..status,30,130,0xFFFFFFFF) end
  for _,entry in ipairs({{0x75,'target'},{0x76,'return'}}) do
   local down=reframework:is_key_down(entry[1]);if down and not keys[entry[1]] then action(entry[2]) end;keys[entry[1]]=down
  end
  local cm=sdk.get_managed_singleton('chainsaw.CharacterManager')
  local ctx=cm and cm:call('getPlayerContextRef')
  local addr=ctx and ctx:get_address()
  if context_address and addr~=context_address then back=nil;pending=nil;verifying=nil end
  context_address=addr
  if verifying and ctx and os.clock()-verifying.started>1 then
   local actual=pos(ctx);local t=verifying.target
   local distance=math.sqrt((actual.x-t.x)^2+(actual.z-t.z)^2)
   status=distance<0.75 and 'Teleport complete' or 'Teleport not confirmed'
   report({destination=t,actual=v(actual),distance=distance,return_point=back});verifying=nil
  end
  if pending and os.clock()-pending.created>8 then pending=nil;status='Cancelled: map did not close';report({cancelled=true}) end
  if pending then
   local mm=sdk.get_managed_singleton('chainsaw.MapManager')
   if mm and not mm:call('isMapGuiOpen') then
    local ctx=sdk.get_managed_singleton('chainsaw.CharacterManager'):call('getPlayerContextRef')
    pending.closed_since=pending.closed_since or os.clock();if ctx and os.clock()-pending.closed_since>1.2 then
     if pending.next_try and os.clock()<pending.next_try then return end
     local t=pending;pending=nil
     if t.maptarget then
      local p=pos(ctx);local target=ground(mm,p,t.maptarget)
      if not target then if os.clock()-t.closed_since<4 then t.next_try=os.clock()+0.2;pending=t;return end;status='No loaded ground on selected floor';report({rejected=t.maptarget});return end
      back=v(p);back.stage=ctx:call('get_CurrentStageID');t=target
     end
     warp(ctx,t);verifying={target=t,started=os.clock()};status='Waiting for teleport';report({destination=t,return_point=back})
    end
   end
  end
 end)
 if not ok then status=tostring(err);pending=nil;verifying=nil;report({error=status}) end
end)
re.on_draw_ui(function()
 if imgui.tree_node('Map teleport - F6 / F7') then
  imgui.text(status)
  
  if imgui.button('Teleport (F6)') then pcall(action,'target') end
  if imgui.button('Return (F7)') then pcall(action,'return') end
  imgui.tree_pop()
 end
end)
