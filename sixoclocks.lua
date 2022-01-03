loop_start={}
loop_length={}
duration={}

bufferMinMax={
    {1,1,80,-1},
    {1,82,161,-1},
    {1,163,243,-1},
    {2,1,80,1},
    {2,82,161,1},
    {2,163,243,1},
  }


function init()

  params:add_group('clocks',12)
    
  for i=1,6 do
  
    params:add_number(i..'min',i..' clock min',0,80,1)
    params:add_number(i..'max',i..' clock max',0,80,2)
  
  end 
  
  for i=1,6 do
    loop_start[i]=0
    loop_length[i]=1000
    
    softcut.enable(i,1)
    softcut.buffer(i,bufferMinMax[i][1])
    softcut.pan(i,bufferMinMax[i][4])
    softcut.level(i,1.0)
    softcut.position(i,1)
    softcut.play(i,1)
    softcut.loop(i,1)
    
    params:add_group(i..'voice',11)
    
    params:add_file(i..'sample',i..'sample')
    params:set_action(i..'sample',function (x) read_file(x,i) end)
    params:add_number(i..'amp',i..'amp',0,100,50)
    params:set_action(i..'amp',function (x) softcut.level(1,x/100) end)
  
    

    params:add_number(i..'smin',i..'start min',0,100,0)
    params:add_number(i..'smax',i..'start max',0,100,10)
    params:add_number(i..'sclock',i..'start clock source',1,6,1)
    
    params:add_number(i..'lmin',i..'length min',0,100,0)
    params:add_number(i..'lmax',i..'length max',0,100,10)
    params:add_number(i..'lclock',i..'length clock source',1,6,1)
    
    params:add_number(i..'rmin',i..'rate min',0,400,100)
    params:add_number(i..'rmax',i..'rate max',0,400,100)
    params:add_number(i..'rclock',i..'rate clock source',1,6,1)
    
  end
  
  

end

function rlfo(id)
  --rate is in milliseconds
  while true do
    x=math.random(params:get(tostring(id)..'min')*1000,params:get(tostring(id)..'max')*1000)
    rlfo_update(id)
    clock.sleep(x/1000)
  end
end

function rlfo_update(id)
     
  for i=1,2 do
    if params:get(i..'sclock')==id then
      update_loop_start(i)
    end
    if params:get(i..'lclock')==id then
      update_loop_length(i)
    end
    if params:get(i..'rclock')==id then
      update_rate(i)
    end
  end
  
end

function update_loop_start(i)
  --clamp between bufferminmax
  loop_start[i]=util.clamp(math.random(params:get(i..'smin'),params:get(i..'smax'))/100*duration[i]+bufferMinMax[i][2],bufferMinMax[i][2],bufferMinMax[i][3])
  --print('start '..loop_start)
  softcut.loop_start(i,loop_start[i])
  softcut.loop_end(i,loop_start[i]+loop_length[i])
end

function update_loop_length(i)
  loop_length[i]=util.clamp(math.random(params:get(i..'lmin'),params:get(i..'lmax'))/100*duration[i],0,79)
 -- print('length '..loop_length)
  softcut.loop_end(i,loop_start[i]+loop_length[i])
end

function update_rate(i)
  softcut.rate(i,math.random(params:get(i..'rmin'),params:get(i..'rmax'))/100)
end

function read_file(x,i)
  softcut.buffer_read_mono(x,0,bufferMinMax[i][2],80,1,bufferMinMax[i][1],0.0,1.0)
  ch,length,sr = audio.file_info(x)
  duration[i]=length/sr
end

function key(n,z)
  if n==2 and z==1 then
    clock.run(rlfo,1)
    clock.run(rlfo,2)
  end
end









