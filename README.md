livescript-alloy
==========

`livescript-alloy` is a LiveScript & Jade preprocessor for [Titanium Alloy Framework](http://projects.appcelerator.com/alloy/docs/Alloy-bootstrap/index.html).

This utility is a fork from [lazy-alloy](https://github.com/itzaks/lazy-alloy) which uses CoffeeScript


## Why?

It makes you write less code so that your could focus more on getting things done faster instead of syntax details. Optionally, LiveScript allows more functional thinking than CoffeeScript. See [LiveScript Official Website](http://livescript.net) for more insight.

Compile from sourcefile | To alloy readable output
------------ | -------------
`src/controllers/{{name}}.ls` | `app/controllers/{{name}}.js`
`src/styles/{{name}}.ls` | `app/styles/{{name}}.tss`
`src/views/{{name}}.jade` | `app/views/{{name}}.xml`
`src/models/{{name}}.ls` | `app/models/{{name}}.js`
`src/lib/{{name}}.ls` | `app/lib/{{name}}.js`

Also, it will compile your widgets from src/widgets stored in the following directories.

From | To
------------ | -------------
`src/widgets/{{name}}/controllers/*.ls` | `app/widgets/{{name}}/controllers/*.js`
`src/widgets/{{name}}/styles/*.ls` | `app/widgets/{{name}}/styles/*.tss`
`src/widgets/{{name}}/views/*.jade` | `app/widgets/{{name}}/views/*.xml`

## Usage

### Dependencies
* nodejs
* npm
* titanium *(cli)*
* alloy
* brain *(optional)*

### Installation
1. Install [Titanium Alloy Framework](http://projects.appcelerator.com/alloy/docs/Alloy-bootstrap/index.html).
2. `npm install -g livescript-alloy`

### Note regarding the \*.ls –> \*.tss conversion
The files need to be valid livescript objects; thus the first line of these files needs to be a variable assignment like the following

    tss =
	  ".container":
	    backgroundColor: "red"

	  "Label":
		width: Ti.UI.SIZE
		height: Ti.UI.SIZE
		color: "#fff"


Its output will look like this:

    ".container": {
      backgroundColor: "red"
    },
    "Label": {
      width: Ti.UI.SIZE,
      height: Ti.UI.SIZE,
      color: "#fff"
    }

Perhaps something like *stylus* would be a better fit for this kind of job. Feel free to help us improve this section!

###Options
    Usage: livealloy [COMMAND] [OPTIONS]

    Commands:

      compile                Just compile.
      watch                  Watch file changes & compile.
      build <platform>       Run titanium on `platform`
      new                    Setup the livescript-alloy directory structure.
      generate <type> <name> Generate a new (livescript-)alloy type such as a controller.

    Options:

      -h, --help                 output usage information
      -V, --version              output the version number
      -p, --platform [platform]  (watch) When done, run titanium on `platform`
      -d, --directory [dirname]  Set source directory (default `src/`)
