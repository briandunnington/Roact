sub configureRequestProxy(request, proxy)
    if request <> invalid and proxy <> invalid
        proxyPrefix = "http://" + proxy + "/;"
        currentUrl = request.getUrl()
        if currentUrl.instr(proxyPrefix) = 0 then return
        proxiedUrl = proxyPrefix + currentUrl
?"PROXYING " + currentUrl + " to " + proxiedUrl
        request.setUrl(proxiedUrl)
    end if
end sub
