mq:subscribe('node/stdin', 0, function(msg)
    node.input(msg)
end)

mq:subscribe('node/console', 0, function(msg)
    if msg == 'q' then 
        node.output(nil) 
    else
        node.output(_output, 1)       
    end
end)

function _output(str)
  if mq.running then
     mq:publish('node/stdout', str)
  end
end