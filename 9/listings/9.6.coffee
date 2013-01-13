with_events = (emitter, event) ->
    pipeline = []
  data = []

  reset = ->
      pipeline = []

  reset()

  run = ->
      result = data
    for processor in pipeline
        if processor.filter?
            mapped = result.filter processor.filter
        else if processor.map?
          result = result.map processor.map
      result

  emitter.on event, (datum) ->
      data.push datum

  interface =
    filter: (filter) ->
        pipeline.push {filter: filter}
        @
      map: (map) ->
        pipeline.push {map: map}
        @
      drain: (fn) ->                   #A
      emitter.on event, (datum) ->   #A
        result = run()               #A
          data = []                    #A
          fn result                    #A
      evaluate: ->
        result = run()
        reset()
        result

  interface

UP = 38       #B
DOWN = 40     #B
Q = 81        #B
A = 65        #B

doc =                                      #C
  on: (event, fn) ->                       #C
    old = document["on#{event}"] || ->     #C
    document["on#{event}"] = (e) ->        #C
      old e                                #C
      fn e                                 #C

class Paddle

  constructor: (@top=0, @left=0) ->
      @render()

  move: (displacement) ->              #D
    @top += displacement*5             #D
    @paddle.style.top = @top + 'px'    #D

  render: ->                                                #E
    @paddle = document.createElement 'div'                  #E
    @paddle.className = 'paddle'                            #E
    @paddle.style.backgroundColor = 'black'                 #E
    @paddle.style.position = 'absolute'                     #E
    @paddle.style.top = "#{@top}px"                         #E
    @paddle.style.left = "#{@left}px"                       #E
    @paddle.style.width = '20px'                            #E
    @paddle.style.height = '100px'                          #E
    document.querySelector('#pong').appendChild @paddle     #E

displacement = ([up,down]) ->
    (event) ->
      switch event.keyCode
      when up then -1
      when down then 1
      else 0

move = (paddle) ->
    (moves) ->
      for displacement in moves
        paddle.move displacement

keys = (expected) ->
    (pressed) ->
      pressed.keyCode in expected

paddle1 = new Paddle 0,0      #F
paddle1.keys = [Q,A]          #F

paddle2 = new Paddle 0,200    #F
paddle2.keys = [UP,DOWN]      #F

with_events(doc, 'keydown')         #G
.filter(keys paddle1.keys)          #G
.map(displacement paddle1.keys)     #G
.drain(move paddle1)                #G

with_events(doc, 'keydown')         #G
.filter(keys paddle2.keys)          #G
.map(displacement paddle2.keys)     #G
.drain(move paddle2)                #G
