{CompositeDisposable} = require "atom"
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
        if !atom.workspace.getActivePaneItem().buffer.file
            throw new Error "Save your file first!"

        oFile = atom.workspace.getActivePaneItem().buffer.file
        atom.project.relativizePath oFile.path
        oProject = atom.project.relativizePath oFile.path
        sProjectName = oProject[ 0 ].split( "/" ).pop()
        sFilename = sProjectName + "/" + oProject[ 1 ]
        sCreatedAt = @getCreationDate oFile.path

        sAuthor = process.env.USER || "Nameless"

        return {
            "path": sFilename,
            "createdAt": sCreatedAt,
            "author": sAuthor,
            "projectName": sProjectName
        }

    getTemplate: ( language ) ->
        return fs.readFileSync __dirname + "/templates/" + language + ".txt", encoding: "utf8"

    insertText: ( editor ) ->
        editor.setCursorScreenPosition [ 0, 0 ]

        try
            file = @getFileInfo()
        catch oError
            return atom.notifications.addError oError.message

        header = @getTemplate( editor.getGrammar().name )
        header = header.replace "{{ projectName }}", file.projectName
        header = header.replace "{{ path }}", file.path
        header = header.replace "{{ createdAt }}", file.createdAt
        header = header.replace "{{ author }}", file.author

        editor.insertText header

Date.prototype.goodFormat = ->
    d = @getDate()
    y = @getFullYear()
    m = @getMonth() + 1
    m < 10 && m = "0" + m
    d + "/" + m + "/" + y
