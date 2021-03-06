Pompomodoro = require '../lib/pompomodoro'

describe "Pompomodoro", ->
  [workspaceElement, activationPromise, obscureElement, messageElement] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('pompomodoro')
    jasmine.attachToDOM(workspaceElement)
    atom.commands.dispatch workspaceElement, 'pompomodoro:start'
    obscureElement = workspaceElement.querySelector('.obscure')
    messageElement = workspaceElement.querySelector('.break-message')

  describe "pompomodoro:break", ->
    it "shows a message", ->
      expect(messageElement).not.toBeVisible()
      Pompomodoro.break()
      expect(messageElement).toBeVisible()
      expect(messageElement.innerHTML).toEqual("It's time to take a break!")

    it "covers the view with a div", ->
      expect(obscureElement).not.toBeVisible()
      Pompomodoro.break()
      expect(obscureElement).toBeVisible()

  describe "pompomodoro:work", ->
    it "renders the div invisible", ->
      Pompomodoro.break()
      expect(obscureElement).toBeVisible()
      Pompomodoro.work()
      expect(obscureElement).not.toBeVisible()

    it "Allows us to type during work periods", ->
      Pompomodoro.break()
      expect(document.onkeypress()).toEqual(false)
      Pompomodoro.work()
      expect(document.onkeypress()).toEqual(true)

    #
    # fit "overwrites setTimeout", ->
    #   @timerCallback = jasmine.createSpy('atom.notifications.addWarning("1 minute warning")')
    #   jasmine.Clock.useMock()
    #   Pompomodoro.work()
    #   expect(@timerCallback).not.toHaveBeenCalled()
    #   jasmine.Clock.tick(1001)
    #   console.log(@timerCallback)
    #   expect(@timerCallback.wasCalled).toEqual(true)

  describe "pompomodoro:start", ->

    beforeEach ->
      atom.config.set('pompomodoro.numberOfSessions', 4)
      atom.config.set('pompomodoro.breakLength', 5)
      atom.config.set('pompomodoro.workIntervalLength', 25)

    it "has variable settings", ->
      expect(Pompomodoro.noOfIntervals).toBe 4
      expect(Pompomodoro.breakLength).toBe 300000
      expect(Pompomodoro.workTime).toBe 1500000


  # describe "pompomodoro:start", ->
    # it "calls break when start is called", ->
    #   panel = atom.workspace.panelContainers.modal.panels[0]
    #   jasmine.Clock.useMock()
    #   spy = spyOn(panel, 'show')
    #   Pompomodoro.start()
    #   console.log(Pompomodoro.workTime)
    #   console.log(spy.callCount)
    #   jasmine.Clock.tick(Pompomodoro.workTime + 1)
    #   expect(panel.show.callCount).toEqual(1)

    # it "creates two breaks", ->
    #   panel = atom.workspace.panelContainers.modal.panels[0]
    #   spy = spyOn(panel, 'show')
    #   waits(2000)
    #   runs ->
    #     expect(panel.show.callCount).toEqual(2)

  describe "pompomodoro:skip", ->
    it "overrides break", ->
      Pompomodoro.break()
      Pompomodoro.skip()
      expect(obscureElement).not.toBeVisible()

    it 'allows you to type during the break time when you skip the break', ->
      Pompomodoro.break()
      Pompomodoro.skip()
      expect(document.onkeypress()).toEqual(true)

  describe "pompomodoro:start runs the first session", ->
    it "confirms the session starts", ->
      expect(Pompomodoro.start()).toEqual("Session 1 was run")
