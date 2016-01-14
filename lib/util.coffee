exports.formatDate = ( oDate ) ->
    d = oDate.getDate()
    y = oDate.getFullYear()
    m = oDate.getMonth() + 1
    m < 10 && m = "0" + m
    d + "/" + m + "/" + y
