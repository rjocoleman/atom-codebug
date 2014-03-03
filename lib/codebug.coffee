Shell = require 'shell'
{Range} = require 'atom'

module.exports =
  configDefaults:
    openCodebug: true

  activate: ->
    atom.workspaceView.command 'codebug:break', '.editor', => @codebugBreak()

  codebugBreak: ->
    if @isOpenable()
      @openUrlInBrowser(@breakUrl())
      console.log @breakUrl()
    else
      @reportValidationErrors()

  file: ->
    activeItem = atom.workspaceView.getActivePaneItem()
    if activeItem.buffer.file?
      encodeURI(activeItem.buffer.file.path)

  getLineNumber: ->
    lineRange = atom.workspaceView.getActivePaneItem()?.getSelectedBufferRange?()
    if lineRange
      lineRange = Range.fromObject(lineRange)
      startRow = lineRange.start.row + 1
      endRow = lineRange.end.row + 1
      return startRow

  openIt: ->
    if atom.config.get 'codebug.openCodebug'
      '1'
    else
      '2'

  openUrlInBrowser: (url) ->
    Shell.openExternal url

  breakUrl: ->
    "codebug://send?file=#{@file()}&line=#{@getLineNumber()}&op=#{@whichOperation()}&open=#{@openIt()}"

  whichOperation: ->
    'add'

  isOpenable: ->
    @validationErrors().length == 0

  validationErrors: ->
    unless @file()
      return ['Buffer is not saved!']

    []

  reportValidationErrors: ->
    atom.beep()
    console.warn error for error in @validationErrors()
