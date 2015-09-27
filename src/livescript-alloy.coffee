fs = require("fs")
path = require("path")
match = require("match-files")
promptly = require("promptly")
livescript = require("livescript")
jade = require("jade")
sty = require('sty')
app = null

directory = process.cwd()

console.info = (msg) ->
  console.log sty.red msg

console.debug = (msg) ->
  console.log sty.green msg



class Application
  constructor: ->
    app = this
    @program = require('commander')
    @titanium = null

    @program
      .version('0.0.5')
      .usage('[COMMAND] [OPTIONS]')
      #.option('-s, --setup', 'Setup lazy-alloy directory structure.')
      # .option('-c, --compile', 'Just compile.')
      # .option('-w, --watch', 'Watch file changes & compile.')
      .option('-p, --platform [platform]', '(watch) When done, run titanium on `platform`')
      .option('-d, --directory [dirname]', 'Set source directory (default `src/`)')

    @program.command('compile')
      .alias('c')
      .description('Just compile.')
      .action(@compile)

    @program.command('watch')
      .alias('w')
      .description('Watch file changes & compile.')
      .action(@watch)

    @program.command('build <platform>')
      .alias('b')
      .description('Run titanium on `platform`')
      .action(@build)

    @program.command('new')
      .alias('n')
      .description('Setup the lazy-alloy directory structure.')
      .action(@setup)

    @program.command('generate [type] [name]')
      .alias('g')
      .description('Generate a new (lazy-)alloy type such as a controller.')
      .action(@generate)

    @program.parse(process.argv)

  # start: ->
  #   return @compile() if @program.compile
  #   return @watch() if @program.watch
  #   return @build() if @program.platform

  #   console.info "nothing to do!"

  start: ->
    @subfolder = if @program.directory
      @program.directory += '/' unless @program.directory.charAt(subfolder.length-1) == '/'
    else
     'src/'
    @compiler = new Compiler(@subfolder)

  compile: ->
    app.start()
    app.compiler.all()

  build: (platform = app.program.platform) ->
    app.start()
    spawn = require("child_process").spawn
    exec = require("child_process").exec

    if app.titanium isnt null
      console.info "stopping titanium..."
      app.titanium.kill()

    alloy = exec "alloy compile", (error, stdout, stderr) ->
      console.debug stdout if stdout
      console.log stderr if stderr

    alloy.on 'exit', (code) =>
      console.log "alloy stopped with code #{ code }"

      if code isnt 1
        console.info "starting titanium..."

        @titanium = spawn "titanium", ["build", "-p", platform]

        @titanium.stdout.on "data", (data) ->
          console.log "titanium: " + data

        @titanium.stderr.on "data", (data) ->
          console.log "titanium: " + data

        @titanium.on "exit", (code) ->
          console.log "titanium exited with code " + code

  watch: ->
    app.start()
    watchr = require("watchr")

    console.info "Waiting for file change..."

    watchr.watch
      ignoreHiddenFiles: true
      paths: [directory]
      listeners:
        error: (err) ->
          console.log "an error occured:", err

        change: (changeType, filePath, fileCurrentStat, filePreviousStat) =>
          return unless changeType in ["create", "update"]

          #only compile correct files
          file = getFileType filePath
          return unless file

          app.compiler.files [filePath], file.fromTo[0], file.fromTo[1]

          app.build() if app.program.platform

    next: (err, watchers) ->
      if err
        return console.log("watching everything failed with error", err)
      else
        console.debug "Waiting for file change..."

  setup: ->
    app.start()
    new Generator().setup app.subfolder

  generate: (type, name) ->
    app.start()
    app.type = type
    app.name = name
    app.ensureType()

  ensureType: ->
    if app.type
      app.ensureName()
    else
      generators = ['controller', 'view', 'model', 'widget']
      console.debug 'What should I generate?'
      promptly.choose generators.join(', ') + ': ', generators, app.ensureName

  ensureName: (i, type) ->
    app.type = type if type
    if app.name # might not be needed for all future generators
      app.startGenerator()
    else
      promptly.prompt "Please enter a name for your #{app.type}: ", (err, name) ->
        app.startGenerator(name)

  startGenerator: (name) ->
    app.name = name if name
    new Generator().generate app.type, app.name

  getFileType = (path) ->
    #check if file path contains string
    inpath = (name) ->
      !!~ path.indexOf name

    return {type: "view", fromTo: ["jade", "xml"]} if inpath ".jade"
    return {type: "widgets/view", fromTo: ["jade", "xml"]} if inpath "widgets/view"

    return null unless inpath ".ls"

    return {type: "style", fromTo: ["ls", "tss"]} if inpath "styles/"
    return {type: "alloy", fromTo: ["ls", "js"]} if inpath "alloy.ls"
    return {type: "controller", fromTo: ["ls", "js"]} if inpath "controllers/"
    return {type: "model", fromTo: ["ls", "js"]} if inpath "models/"
    return {type: "library", fromTo: ["ls", "js"]} if inpath "lib/"
    return {type: "widgets/style", fromTo: ["ls", "tss"]} if inpath "widgets/style"
    return {type: "widgets/controller", fromTo: ["ls", "js"]} if inpath "widgets/controller"

class Compiler
  logger: console
  constructor: (@subfolder = 'src/') ->

  views: ->
    @process "views/", "jade", "xml"

  controllers: ->
    @process "controllers/", "ls", "js"

  models: ->
    @process "models/", "ls", "js"

  styles: ->
    @process "styles/", "ls", "tss"

  widgets: ->
    widgets = fs.readdirSync "#{@subfolder}/widgets"
    for widget in widgets
      @process "widgets/#{widget}/views/", "jade", "xml"
      @process "widgets/#{widget}/styles/", "ls", "tss"
      @process "widgets/#{widget}/controllers/", "ls", "js"

  lib: ->
    @process "lib/", "ls", "js"

  alloy: ->
    @process "./alloy.ls", "ls", "js"

  all: ->
    @views()
    @controllers()
    @styles()
    @widgets()
    @lib()
    @alloy()

  process: (path, from, to) ->
    path = @subfolder + path
    @logger.info "Preprocessing #{ from } files in #{ path }"

    filter = (dir) ->
      # It should contain the expected extension but not a hidden file (starting with a dot)
      dir.indexOf(".#{ from }") isnt -1 and dir.indexOf(".") isnt 0

    match.find (process.cwd() + "/" + path), {fileFilters: [filter]}, (err, files) => @files files, from, to

  file: (from, output, type) ->
    @logger.debug "Building #{type}: #{from} --> #{output}"
    data = fs.readFileSync from, 'utf8'
    compiled = @build[type] data
    # Create the base path
    @mkdirPSync output.split('/')[0...-1]
    fs.writeFileSync output, compiled, 'utf8'

  files: (files, from, to, to_path) ->
    return @logger.debug "No '*.#{from}' files need to preprocess.. #{files.length} files" if files.length is 0

    # Create necessary directory in case it doesn't exist
    paths = ['app', 'app/controllers', 'app/styles', 'app/views', 'app/lib']
    for path in paths
      unless fs.existsSync path
        fs.mkdirSync path

    for file in files
      break if !!~ file.indexOf "lazyalloy"

      output = file.substring(0, file.length - from.length).toString() + to
      output = output.replace(/\\/g, '/') if process.platform is 'win32'
      output = output.replace(new RegExp('(.*)'+@subfolder), '$1app/') # Replacing subfolder with app. Only last occurence in case it exists twice in the path.

      @file file, output, to

  build:
    xml: (data) ->
      jade.compile(data,
        pretty: true
      )(this)

    tss: (data) ->
      data = @js data

      (data.replace "};", "").replace """
        var tss;

        tss = {

        """, ""

    js: (data) ->
      livescript.compile data.toString(), {bare: true}

    json: (data) ->
      data

  # The equivalent of running `mkdir -p <path>` on the command line
  mkdirPSync: (segments, pos=0) ->
    return if pos >= segments.length
    # Construct path at current segment
    segment = segments[pos]
    path = segments[0..pos].join '/'

    # Create path if it doesn't exist
    if path.length > 0
      unless fs.existsSync path
        fs.mkdirSync path
    # Go deeper
    @mkdirPSync segments, pos + 1

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
    switch type
      when 'controller'
        createController name
      when 'model'
        createModel name
      when 'jmk'
        not_yet_implemented()
      when 'model'
        createModel name
      when 'migration'
        not_yet_implemented()
      when 'view'
        createView name
      when 'widget'
        createWidget name
      when 'lib'
        createLibrary name
      else
        console.info "Don't know how to build #{type}"
    process.exit()

  createController = (name) ->
    console.debug "Creating controller #{name}"
    touch app.subfolder + 'controllers/' + name + '.ls'
    createView name

  createView = (name) ->
    console.debug "Building view #{name}"
    touch app.subfolder + 'views/' + name + '.jade'
    createStyle name

  createStyle = (name) ->
    console.debug "Building style #{name}"
    touch app.subfolder + 'styles/' + name + '.ls'

  createModel = (name) ->
    console.debug "Building model #{name}"
    touch app.subfolder + 'models/' + name + '.ls'

  createWidget = (name) ->
    console.debug "Creating widget #{name}"
    mkdir app.subfolder + 'widgets/'
    mkdir app.subfolder + 'widgets/' + name
    mkdir app.subfolder + 'widgets/' + name + '/controllers/'
    mkdir app.subfolder + 'widgets/' + name + '/views/'
    mkdir app.subfolder + 'widgets/' + name + '/styles/'
    touch app.subfolder + 'widgets/' + name + '/controllers/widget.ls'
    touch app.subfolder + 'widgets/' + name + '/views/widget.jade'
    touch app.subfolder + 'widgets/' + name + '/styles/widget.ls'

  createLibrary = (name) ->
    console.debug "Creating library #{name}"
    touch app.subfolder + 'lib/' + name + '.ls'

  not_yet_implemented = ->
    console.info "This generator hasn't been built into lazy-alloy yet. Please help us out by building it in:"
    console.info "https://github.com/vastness/lazy-alloy"

  mkdir = (path) ->
    execUnlessExists fs.mkdirSync, path
  touch = (path) ->
    execUnlessExists fs.openSync, path, 'w'
  execUnlessExists = (fn, path, attr = null) ->
    if fs.existsSync(path)
      console.debug("#{path} already exists, doing nothing")
    else
      fn path, attr

module.exports = new Application
