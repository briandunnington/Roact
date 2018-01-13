'Call these from any component to log analytics
sub AnalyticsLogPage(screenName)
    _AnalyticsLog({
        t: "screenview"
        cd: screenName
    })
    ?"analytics page view"
end sub

' TODO: figure out how the initialization is handled
sub AnalyticsLogInitialization()
    deviceInfo = CreateObject("roDeviceInfo")

    tvModel = deviceInfo.GetModelDisplayName()

    _AnalyticsLog({
        ' TODO: update this to the parameter that Gergo determines 
        t: "event"
        ec: "app"
        ea: "initialization"
        el: tvModel
    })
    ?"analytics initialization"
    
end sub

sub AnalyticsLogVideoSelect(eventCategory, eventAction, eventLabel, itemId, rowTitle, rowIndex, itemIndex)
    _AnalyticsLog({
        t: "event"
        ec: eventCategory
        ea: eventAction
        el: eventLabel
        cd1: itemId
        cd2: rowTitle
        cd3: rowIndex
        cd4: itemIndex
    })
    ?"log video selected"
end sub

sub AnalyticsLogPlayerEvent(eventCategory, eventAction, eventValue, eventLabel, itemId)
    _AnalyticsLog({
        t: "event"
        ec: eventCategory
        ea: eventAction
        ev: eventValue
        el: eventLabel
        cd1: itemId
    })
end sub

sub AnalyticsLogEvent(eventCategory, eventAction, eventLabel, eventValue)
    _AnalyticsLog({
        t: "event"
        ec: eventCategory
        ea: eventAction
        el: eventLabel
        ev: eventValue
    })
    ?"analytics event"
end sub

sub AnalyticsLogException(exceptionDescription)
    _AnalyticsLog({
        t: "exception"
        exd: exceptionDescription
    })
end sub

'Dont call this - it is for internal use only
sub _AnalyticsLog(data)
    m.global.analytics = data
end sub

'This should only be called from your main loop
sub ProcessAnalytics(msg, port, defaultAnalyticsValues, proxy)
    msgType = type(msg)
    if msgType = "roSGNodeEvent"
        field = msg.getField()
        if field = "analytics"
            data = {}
            data.append(defaultAnalyticsValues)
            data.append(msg.getData())
            request = _ProcessAnalyticsEvent(data, port, proxy)
            if request <> invalid
                id = request.getIdentity().toStr()
                m[id] = request
            end if
        end if
    else if msgType = "roUrlEvent"
        id = msg.getSourceIdentity().toStr()
        m.delete(id)
    end if
end sub

'Dont call this - it is for internal use only
function _ProcessAnalyticsEvent(data, port, proxy)
    qsBuilder = QueryStringBuilder()
    for each item in data
        qsBuilder.add(item, data[item])
    end for
    qs = qsBuilder.toStr("?")

    url = "https://www.google-analytics.com/collect" + qs

    request = CreateObject("roUrlTransfer")
    request.setMessagePort(port)
    request.SetCertificatesFile("common:/certs/ca-bundle.crt")
    request.InitClientCertificates()
    request.setUrl(url)
?"ANALYTICS:", url
    configureRequestProxy(request, proxy)
    request.AsyncPostFromString("")
    return request
end function
