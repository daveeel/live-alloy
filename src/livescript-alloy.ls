fs = require \fs
path = require \path
matchFiles = require \match-files
promptly = require \promptly
livescript = require \livescript
jade = require \jade
sty = require \sty
app = null

directory = process.cwd!

console.info = (msg) ->
  console.log sty.red msg

console.debug = (msg) ->
  console.log sty.green msg

class Application
  ->
    app := this
    @program = require \commander
    @titanium = null

    @program
      .version \0.0.1
      .usage '[COMMAND] [OPTIONS]'
      .option '-p, --platform [platform]', '(watch) When done, run titanium on `platform`'
      .option '-d, --directory [dirname]', 'Set source directory (default `src/`)'

    @program.command \test
      .alias \t
      .description 'livescript-alloy test'
      .action @test

    @program.command \compile
      .alias \c
      .description 'Just compile.'
      .action @compile

    @program.command \new
      .alias \n
      .description 'Setup the lazy-alloy directory structure.'
      .action @setup

    @program.command 'generate [type] [name]'
      .alias \g
      .description 'Generate a new (lazy-)alloy type such as a controller.'
      .action @generate

    @program.parse process.argv

  test: ->
    console.log 'Testing Util structure ...'

  start: ->
    @subfolder = if @program.directory
      @program.directory += '/' unless @program.directory.charAt(subfolder.length-1) == '/'
    else
      'src/'
    @compiler = new Compiler @subfolder

  compile: ->
    app.start!
    app.compiler.all!

  build: (platform = app.program.platform)->
    app.start!
    spawn = require \child_process .spawn
    exec = require \child_process .exec

    if app.titanium isnt null
      console.info 'stopping titanium ...'
      app.titanium.kill!

    alloy = exec 'alloy compile' (error, stdout, stderr) ->
      console.debug stdout if stdout
      console.log stderr if stderr

    alloy.on \exit (code) ->
      console.log "alloy stopped with code #{ code }"

      if code isnt 1
        console.info 'starting titanium ...'
        @titanium = spawn \titanium [\build \-p platform]
        @titanium.stdout.on \data (data) ->
          console.log "titanium: #{ data }"
        @titanium.stderr.on \data (data) ->
          console.log "titanium: #{ data }"
        @titanium.on \exit (code) ->
          console.log "titanium exited with code #{ code }"

  watch: !->
    app.start!
    watchr = require \watchr

    console.info 'Waiting for file change ...'

    watchr.watch do
      ignoreHiddenFiles: true
      paths: [directory]
      listeners:
        error: (err) ->
          console.log "an error occured:", err

        change: (changeType, filePath, fileCurrentStat, filePreviousStat) ->
          return unless changeType in ["create", "update"]

          #only compile correct files
          file = getFileType filePath
          return unless file

          app.compiler.files [filePath], file.fromTo[0], file.fromTo[1]

          app.build() if app.program.platform

    next: (err, watchers) ->
      if err
        return console.log "watching everything failed with error" err
      else
        console.debug 'Waiting for file change ...'


  setup: ->
    app.start!
    new Generator!setup app.subfolder

  # TODO: continue
  generate: (type, name)->

  ensureType: ->

  ensureName: (i, type)->

  startGenerator: (name)->

  getFileType: (path)->

class Compiler

class Generator
  setup: (subfolder) ->
    console.info "Setting up folder structure at #{subfolder}"
    mkdir subfolder
    mkdir subfolder+'views'
    mkdir subfolder+'styles'
    mkdir subfolder+'controllers'
    mkdir subfolder+'widgets'
    mkdir subfolder+'lib'
    console.debug 'Setup complete.'
    process.exit()

  generate: (type, name) ->


module.exports = new Application
