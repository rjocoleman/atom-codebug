{exec} = require 'child_process'
{Range} = require 'atom'

module.exports =
  config:
    openCodebug:
      type: 'boolean'
      default: true

  activate: ->
    atom.commands.add 'atom-workspace', 'codebug:break', => @codebugBreak()

  codebugBreak: ->
    if @isOpenable()
      @openUrlInBrowser(@breakUrl())
      console.log @breakUrl()
    else
      @reportValidationErrors()

  file: ->
    activeItem = atom.workspace.getActivePaneItem()
    if activeItem.buffer.file?
      encodeURI(activeItem.buffer.file.path)

  getLineNumber: ->
    lineRange = atom.workspace.getActivePaneItem()?.getSelectedBufferRange?()
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
    exec "open '#{url}'", (err, stdout, stderr) ->
      console.log "codebug stdout: #{stdout}" if stdout
      console.warn "codebug stderr: #{stderr}" if stderr
      console.warn "codebug err: #{err}" if err

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
