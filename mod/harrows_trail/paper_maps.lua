-- Native formspec drawing keeps the paper maps readable without external artwork or shaders.
return function(ctx)
 local ink='#4e3527';local paper='#dbc69d';local faded='#bca477'
 local function build(id,title,note)
  local site,p=ctx.site,ctx.chapter.positions
  local points,path
  local ranch={label='Harrow Ranch',pos=site.barn}
  local mesa={label='Red Mesa',pos=site.ada}
  local dust={label='Dust Flats',pos=p.dust}
  local gulch={label='Dry Gulch',pos=p.gulch}
  local pass={label='Iron Pass',pos=p.pass}
  local silver={label='Silver Spur',pos=p.assay}
  if id=='fragment_1' then
   points={ranch,mesa};path={site.barn,site.ada}
   if ctx.opening and site.barn.x==ctx.opening.positions.barn.x and site.barn.z==ctx.opening.positions.barn.z then
    path={site.barn};for _,v in ipairs(ctx.opening.route)do path[#path+1]=v end;path[#path+1]=site.ada
   end
  elseif id=='fragment_2' then points={mesa,dust,gulch};path={site.ada,p.dust,p.gulch}
  elseif id=='fragment_3' then points={pass,silver};path={p.pass,p.assay}
  else points={ranch,mesa,gulch,silver};path={site.barn,site.ada,p.dust,p.gulch,p.pass,p.assay}end
  local f={'formspec_version[4]size[12.8,9]bgcolor[#211a16;true]style_type[label;font=mono]style_type[textarea;border=false;textcolor=#eadbc0]'}
  local function box(x,y,w,h,color)f[#f+1]=string.format('box[%.3f,%.3f;%.3f,%.3f;%s]',x,y,w,h,color)end
  local function label(x,y,w,h,text,color)
   f[#f+1]=string.format('label[%.3f,%.3f;%.3f,%.3f;%s]',x,y,w,h,core.formspec_escape(core.colorize(color or ink,text)))
  end
  local function line(x1,y1,x2,y2,color,dashed)
   local n=math.max(1,math.ceil(math.sqrt((x2-x1)^2+(y2-y1)^2)*24))
   for i=0,n do if not dashed or i%9<5 then box(x1+(x2-x1)*i/n-.018,y1+(y2-y1)*i/n-.018,.036,.036,color)end end
  end
  label(.5,.3,11,.5,title,'#f1dfbd')
  box(.45,1,7.85,6.9,'#826446');box(.51,1.06,7.73,6.78,paper)
  -- Uneven edges suggest the torn pieces; the assembled map retains its stitched seams.
  for i=0,34 do box(.51,1.06+i*.195,.025+(i*7%5)*.015,.12,faded);box(8.16-(i%3)*.02,1.06+i*.195,.08,.1,faded)end
  if id=='harrow_map' then line(3.08,1.2,3.08,7.7,faded,true);line(5.72,1.2,5.72,7.7,faded,true)end
  local minx,maxx,minz,maxz=math.huge,-math.huge,math.huge,-math.huge
  for _,v in ipairs(path)do minx=math.min(minx,v.x);maxx=math.max(maxx,v.x);minz=math.min(minz,v.z);maxz=math.max(maxz,v.z)end
  if maxx-minx<1 then minx=minx-40;maxx=maxx+40 end
  if maxz-minz<1 then minz=minz-40;maxz=maxz+40 end
  local function project(pos)return 1.9+(pos.x-minx)/(maxx-minx)*4.7,3.2+(maxz-pos.z)/(maxz-minz)*3.05 end
  -- Compass: Luanti north is increasing Z, matching the top of this sketch.
  line(1.2,1.7,1.2,2.35,ink);line(.98,1.9,1.2,1.7,ink);line(1.42,1.9,1.2,1.7,ink)
  label(1.04,1.27,.6,.4,'N');label(5.2,1.35,2.7,.4,'Samuel Harrow')
  for i=2,#path do local x,y=project(path[i-1]);local xx,yy=project(path[i]);line(x,y,xx,yy,'#8c5b37',true)end
  for i,point in ipairs(points)do
   local x,y=project(point.pos)
   -- A small roof and doorway distinguish settlements from the dotted trail.
   box(x-.12,y-.08,.24,.2,ink);box(x-.035,y+.01,.07,.11,paper)
   line(x-.16,y-.09,x,y-.24,ink);line(x,y-.24,x+.16,y-.09,ink)
   local textx=math.max(.72,math.min(4.95,x-1.3))
   local texty=y+(i%2==1 and -.77 or .31)
   box(textx-.03,texty,3.26,.45,paper);label(textx,texty,3.2,.45,point.label)
  end
  label(.8,7.18,6.9,.4,'Dotted line: old trail   /   North up')
  box(8.55,1.05,3.8,6.8,'#30251e')
  label(8.8,1.35,3.2,.45,id=='harrow_map' and 'THE ASSEMBLED MAP' or 'A TORN FRAGMENT','#e4c18a')
  local notes_y=2.05
  if id=='harrow_map' then
   label(8.8,1.95,3.2,.45,'SILVER SPUR','#e4c18a')
   box(8.85,2.55,3.15,2.05,paper)
   line(9.03,2.78,11.75,2.78,ink);line(9.03,2.78,9.03,4.35,ink);line(9.03,4.35,11.75,4.35,ink);line(11.75,2.78,11.75,4.35,ink)
   label(9.15,2.95,2.5,.4,'Assay office')
   local dx,dz=p.gold_cache.x-p.assay.x,p.gold_cache.z-p.assay.z
   local sx=10.35+math.max(-1,math.min(1,dx/4))*.7
   local sy=3.8+math.max(-1,math.min(1,dz/4))*.2
   line(sx-.13,sy-.13,sx+.13,sy+.13,'#8b3328');line(sx-.13,sy+.13,sx+.13,sy-.13,'#8b3328')
   label(9.2,4.05,2.6,.3,'X: gold cache')
   notes_y=4.95
  end
  f[#f+1]=string.format('textarea[8.8,%.2f;3.25,%.2f;;;%s]',notes_y,7.25-notes_y,core.formspec_escape(note))
  label(.6,8.12,7.5,.4,'Route sketch - follow the trail signs.','#d4bd94')
  f[#f+1]='button_exit[9.05,8.04;2.9,.65;close;Fold map]'
  return table.concat(f)
 end
 return {build=build}
end
