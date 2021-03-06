PompomodoroView = require './pompomodoro-view'
PomoBar = require './status-bar-view'
{CompositeDisposable} = require 'atom'

module.exports = Pompomodoro =

  pompomodoroView: null
  modalPanel: null
  subscriptions: null
  noOfIntervals: null
  breakLength: null
  workTime: null
  pomoBar: null
  statusBar: null
  currentPom: 1
  min: 0
  sec: 0

  activate: (state) ->
    @pompomodoroView = new PompomodoroView(state.pompomodoroViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @pompomodoroView.getElement(), visible: false)
    @pomoBar = new PomoBar([@min,@sec], [@currentPom,@noOfIntervals])

    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'pompomodoro:start': => @start()
    @subscriptions.add atom.commands.add 'atom-workspace', 'pompomodoro:skip': => @skip()

    @noOfIntervals = atom.config.get('Pompomodoro.numberOfIntervals')
    @breakLength = atom.config.get('Pompomodoro.breakLength') * 1000 * 60
    @workTime = atom.config.get('Pompomodoro.workIntervalLength') * 1000 * 60

  consumeStatusBar: (statusBar) ->
    @statusBar = statusBar
    @statusBarTile1 = statusBar.addRightTile(item: @pomoBar.getTimer(), priority: 101)
    @statusBarTile2 = statusBar.addRightTile(item: @pomoBar.getElement(), priority: 100)

  break: (i) ->
    if i < this.noOfIntervals
      @modalPanel.show()
      document.onkeypress = -> false
    else
      atom.notifications.addSuccess("Well done, you've finished your sprint!")

  work: ->
    this.hidePanel()
    setTimeout ( =>
      atom.notifications.addInfo("1 minute until your break!")
    ) , @workTime - 1000 * 60
    @startTime = new Date()
    this.ticker()

  ticker: ->
    clock = setInterval ( =>
      timeRemaining = (@workTime - (new Date() - @startTime))/1000
      @min = Math.floor(timeRemaining / 60)
      second = Math.floor(timeRemaining % 60)
      @sec = if second < 10 then "0#{second}" else second
      @pomoBar.update([@min,@sec],[@currentPom,@noOfIntervals])
      @consumeStatusBar(@statusBar)
      clearInterval(clock) if timeRemaining < 1
    ) , 1000

  start: ->
    this.session(1)

  session: (i) ->
    this.work()
    setTimeout ( =>
      this.break(i)
      setTimeout ( =>
        if @currentPom < @noOfIntervals
          @currentPom++
          this.session(i+1)
      ) , @breakLength
    ) , @workTime

  hidePanel: ->
    @modalPanel.hide()
    document.onkeypress = -> true

  skip: ->
    this.hidePanel()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @pompomodoroView.destroy()

  config:
    breakLength:
      description: 'Length of break in minutes'
      type: 'integer'
      default: 5

    workIntervalLength:
      description: 'Length of work intervals in minutes'
      type: 'integer'
      default: 25

    numberOfIntervals:
      description: 'Number of work intervals in a session'
      type: 'integer'
      default: 4
