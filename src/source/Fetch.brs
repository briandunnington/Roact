function fetch(options)
    timeout = options.timeout
    if timeout = invalid then timeout = 0

    result = invalid
    port = CreateObject("roMessagePort")
    request = CreateObject("roUrlTransfer")
    request.SetCertificatesFile("common:/certs/ca-bundle.crt")
    request.InitClientCertificates()
    request.SetMessagePort(port)
    if options.headers <> invalid
        for each header in options.headers
            request.addHeader(header, options.headers[header])
        end for
    end if
    request.SetUrl(options.url)

    configureRequestProxy(request, options.proxy)

'?"REQ", request.getIdentity(), url
    requestSent = request.AsyncGetToString()
    if (requestSent)
        msg = wait(timeout, port)
        if (type(msg) = "roUrlEvent")
            code = msg.GetResponseCode()
'?"RES", request.getIdentity(), code
            if (code = 200)
                body = msg.GetString()
                if options.raw <> invalid AND options.raw
                    result = body
                else
                    result = ParseJSON(body)
                end if
            else
                result = { error: code }
            end if
        else
            result = { error: "timeout" }
        end if
    end if

'ADD FAKE DELAY
'wait(5000, port)

    return result
end function

function QueryStringBuilder()
    return {
        params: {}

        add: sub(key, val)
            m.params[key] = val
        end sub

        toStr: function(prefix = "")
            if prefix = invalid then prefix = ""
            parts = []
            for each param in m.params
                parts.push([param, m.params[param].encodeUriComponent()].join("="))
            end for
            return prefix + parts.join("&")
        end function
    }
end function