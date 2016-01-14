# headerify
# headerify/lib/util.coffee - Usefull function for this plugin
# Created at 14/01/2016 by Swith"

exports.formatDate = ( oDate ) ->
    d = oDate.getDate()
    y = oDate.getFullYear()
    m = oDate.getMonth() + 1
    m < 10 && m = "0" + m
    d + "/" + m + "/" + y
