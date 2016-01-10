{CompositeDisposable} = require 'atom'

module.exports =
    subscriptions: null

    activate: ->
        @subscriptions = new CompositeDisposable
        @subscriptions.add atom.commands.add "atom-workspace",
            "headerify:add": => @add()

    deactivate: ->
        @subscriptions.dispose()

    add: ->
        if editor = atom.workspace.getActiveTextEditor()
            @insertText( editor )

    insertText: ( editor ) ->
        fs = require "fs"

        console.log editor

        path = editor.getPath()
        file = fs.statSync path
        createdAt = file.birthtime.goodFormat()

        editor.setCursorScreenPosition [ 0, 0 ]

        language = editor.getGrammar().name

        switch language
            when "CoffeeScript"
              header = "# Comment header \n
                      # #{ path } \n
                      # Created at #{ createdAt } \n"
            when "JavaScript"
              header = "/* Comment header \n
                      * #{ path } \n
                      * Created at #{ createdAt } \n
                      */\n"
            when "Jade"
              header = "//\n
                            Comment header \n
                            #{ path } \n
                            Created at #{ createdAt } \n"
            when "PHP"
              header = "/** Comment header \n
                         * #{ path } \n
                         * Created at #{ createdAt } \n
                         */\n"
            when "HTML"
              header = "<!-- Comment header \n
                         #{ path } \n
                         Created at #{ createdAt } \n
                         -->\n"

        if !path
            editor.insertText "Save you file first!"
            return


        editor.insertText header

Date.prototype.goodFormat = ->
    d = @getDate()
    y = @getFullYear()
    m = @getMonth()
    d + "/" + m + "/" + y
