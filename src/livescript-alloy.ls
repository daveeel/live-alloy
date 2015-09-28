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
      @program.directory += '/' unless
      @program.directory.charAt(subfolder.length-1) == '/'
    else
      'src/'
    @compiler = new compiler @subfolder

  compile: ->
    app.start!
    app.compiler.all!

  build: (platform = app.program.platform)->

  watch: ->

  setup: ->
    app.start!
    new Generator!setup app.subfolder

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
