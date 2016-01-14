# headerify
# headerify/lib/headerify.coffee - [Optional comment]
# Created at 11/01/2016 by Swith"

{CompositeDisposable} = require "atom"
fs = require "fs"
Util = require "./util"

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

        Util.formatDate file.birthtime

    getFileInfo: () ->
        if !atom.workspace.getActivePaneItem().buffer.file
            throw new Error "Save your file first!"

        oFile = atom.workspace.getActivePaneItem().buffer.file
        oProject = atom.project.relativizePath oFile.path
        sProjectName = oProject[ 0 ].split( "/" ).pop()
        sFilename = sProjectName + "/" + oProject[ 1 ]
        sCreatedAt = @getCreationDate oFile.path
        sAuthor = process.env.USER || "Nameless"

        return {} =
            "path": sFilename,
            "createdAt": sCreatedAt,
            "author": sAuthor,
            "projectName": sProjectName

    getTemplate: ( sLanguage ) ->
        sFileName = __dirname + "/templates/" + sLanguage + ".txt"

        fs.stat sFileName, ( oError, oStats ) ->
            if oError
                throw new Error "Language not supported!"

        fs.readFileSync sFileName, encoding: "utf8"

    insertText: ( oEditor ) ->
        oEditor.setCursorScreenPosition [ 0, 0 ]

        try
            file = @getFileInfo()
        catch oError
            return atom.notifications.addError oError.message

        try
            header = @getTemplate oEditor.getGrammar().name
        catch oErrror
            console.log oErrror
            return atom.notifications.addError oErrror.message

        header = header.replace "{{ projectName }}", file.projectName
        header = header.replace "{{ path }}", file.path
        header = header.replace "{{ createdAt }}", file.createdAt
        header = header.replace "{{ author }}", file.author

        oEditor.insertText header
