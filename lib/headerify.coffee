{CompositeDisposable} = require 'atom'
fs = require "fs"

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

    getCreationDate: ( filepath ) ->
        file = fs.statSync filepath

        file.birthtime.goodFormat()

    getFileInfo: () ->
        file = atom.workspace.getActivePaneItem().buffer.file
        project = atom.project.relativizePath file.path
        projectName = project[ 0 ].split( "/" ).pop()
        filename = projectName + "/" + project[ 1 ]
        createdAt = @getCreationDate file.path
        author = process.env.USER || "Nameless"

        return {
            "path": filename,
            "createdAt": createdAt,
            "author": author,
            "projectName": projectName
        }

    insertText: ( editor ) ->
        editor.setCursorScreenPosition [ 0, 0 ]

        file = @getFileInfo()
        language = editor.getGrammar().name

        switch language
            when "CoffeeScript"
              header = "# #{ file.projectName } \n
                      # #{ file.path } - [Optional comment] \n
                      # Created at #{ file.createdAt } by #{ file.author }\n"
            when "JavaScript"
              header = "/* #{ file.projectName } \n
                      * #{ file.path } - [Optional comment] \n
                      * Created at #{ file.createdAt } by #{ file.author } \n
                      */\n"
            when "Jade"
              header = "//\n
                            #{ file.projectName } \n
                            #{ file.path } - [Optional comment] \n
                            Created at #{ file.createdAt } by #{ file.author } \n"
            when "PHP"
              header = "/** #{ file.projectName } \n
                         * #{ file.path } - [Optional comment] \n
                         * Created at #{ file.createdAt } by #{ file.author } \n
                         */"
            when "HTML"
              header = "<!-- #{ file.projectName } \n
                         #{ file.path } - [Optional comment] \n
                         Created at #{ file.createdAt } by #{ file.author } \n
                         -->\n"

        if !path
            editor.insertText "Save your file first!"
            return


        editor.insertText header

Date.prototype.goodFormat = ->
    d = @getDate()
    y = @getFullYear()
    m = @getMonth() + 1
    m < 10 && m = "0" + m
    d + "/" + m + "/" + y
