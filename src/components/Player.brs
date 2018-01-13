sub init()
    m.meta = m.top.findNode("meta")
    m.title = m.top.findNode("title")
    m.desc = m.top.findNode("desc")
    m.errorMessage = m.top.findNode("errorMessage")
    m.errorText = m.top.findNode("errorText")
    m.dolbyText = m.top.findNode("dolbyText")
    m.dolbyMessage = m.top.findNode("dolbyMessage")

    m.top.trickPlayBar.filledBarBlendColor = "0x068dca"
    m.top.bufferingBar.filledBarBlendColor = "0x068dca"
    m.top.retrievingBar.filledBarBlendColor = "0x068dca"

    m.top.observeField("visible", "visibleChanged")
    m.top.observeField("state", "playerStateChanged")
    m.top.observeField("position", "playerPositionChanged")
    m.global.observeField("state", "stateChanged")
    m.top.trickPlayBar.observeField("visible", "controlsVisibleChange")

    m.hideInitialMeta = false
    m.timer = CreateObject("roSGNode", "Timer")
    m.timer.duration = 5
    m.timer.observeField("fire", "timerFired")

    m.showDolbyMsg = true
    m.hideDolbyMsgTimer = CreateObject("roSGNode", "Timer")
    m.hideDolbyMsgTimer.duration = 8
    m.hideDolbyMsgTimer.observeField("fire", "dolbyMsgTimerFired")

    dolbyMsgFont = CreateObject("roSGNode", "Font")
    dolbyMsgFont.uri = "pkg:/locale/default/fonts/SourceSansPro/SourceSansPro-Regular.ttf"
    dolbyMsgFont.size = 32
    m.dolbyText.font = dolbyMsgFont

    errorTextFont = CreateObject("roSGNode", "Font")
    errorTextFont.uri = "pkg:/locale/default/fonts/SourceSansPro/SourceSansPro-Regular.ttf"
    errorTextFont.size = 34
    m.errorText.font = errorTextFont

    titleFont = CreateObject("roSGNode", "Font")
    titleFont.uri = "pkg:/locale/default/fonts/SourceSansPro/SourceSansPro-Regular.ttf"
    titleFont.size = 54
    m.title.font = titleFont

    descFont = CreateObject("roSGNode", "Font")
    descFont.uri = "pkg:/locale/default/fonts/SourceSansPro/SourceSansPro-Regular.ttf"
    descFont.size = 27
    m.desc.font = descFont

    m.top.observeField("atmosSoundbarText", "atmosSoundbarTextChanged")

    m.top.notificationInterval = 1
    m.watchedPercent = 0
end sub

sub visibleChanged()
    if m.top.visible
        deviceInfo = CreateObject("roDeviceInfo")
        if deviceInfo.GetLinkStatus()
            m.quartileEvents = {}
            m.quartileEvents["0"] = "0"
            m.quartileEvents["25"] = "25"
            m.quartileEvents["50"] = "50"
            m.quartileEvents["75"] = "75"
            m.quartileEvents["99"] = "100"
            m.quartileEvents["100"] = "100"
            videoItem = m.global.state.data.videoItem
            m.videoTitle = videoItem.title
            m.videoId = videoItem.id
            m.title.text = videoItem.title
            m.desc.text = videoItem.longDescription
            
            'videoItem.videoManifestFilename ="http://dash.akamaized.net/dash264/TestCasesUHD/2a/5/MultiRate.mpd"
            urlArr = videoItem.videoManifestFilename.split(".")
            extension = urlArr[urlArr.count() - 1]

            if extension = "mpd" or extension = "dash"
                format = "dash"
            else
                format = "hls"
            end if
             
            ?"########################################################"
            ?"URL: ";videoItem.videoManifestFilename
            ?"FORMAT: ";format
            ?"########################################################"

            content = CreateObject("roSGNode", "ContentNode")
            content.setFields({
                streamformat: format
                id: videoItem.id
                url: videoItem.videoManifestFilename
                FullHD: true
            })
            m.top.content = content
            m.top.control = "play"
            m.meta.visible = true
            m.timer.control = "start"
        else
            m.errorMessage.visible = true
            m.errorText.text = "A network error occurred. Please check your network connectivity."
        end if
        
    else
        m.top.control = "stop"
        m.top.content = invalid
        m.errorMessage.visible = false
        m.hideInitialMeta = false
        m.showDolbyMsg = true
        m.dolbyMessage.visible = false
        m.watchedPercent = 0
        m.videoTitle = invalid
        m.videoId = invalid
    end if
end sub

sub controlsVisibleChange()
    if m.hideInitialMeta
        m.meta.visible = m.top.trickPlayBar.visible
    end if
end sub

sub timerFired()
    m.hideInitialMeta = true 
    controlsVisibleChange()
end sub

sub dolbyMsgTimerFired()
    m.dolbyMessage.visible = false
end sub

sub stateChanged() 
    if m.global.state.data.noNetwork
        m.top.control = "stop"
        m.errorMessage.visible = true
        m.errorText.text = "A network error occurred. Please check your network connectivity."
    end if
end sub

sub playerPositionChanged()
    if m.top.duration > 0 AND m.top.state = "playing"
        percentage = Cint((m.top.position / m.top.duration) * 100).toStr()
        m.watchedPercent = percentage
        quartile = m.quartileEvents[percentage]
        if quartile <> invalid
            m.quartileEvents.delete(percentage)
            m.quartileEvents.delete(quartile)
            AnalyticsLogPlayerEvent("Video", "playback_quartile", quartile, m.videoTitle, m.videoId)
        end if
    end if
end sub

sub playerStateChanged()
?m.top.state, m.top.errorCode, m.top.errorMsg
    if m.showDolbyMsg AND m.top.state = "playing"
        if m.global.state.data.videoItem.isAtmos
            m.hideDolbyMsgTimer.control = "start"
            m.dolbyMessage.visible = true
            m.showDolbyMsg = false
        end if
    end if

    if m.top.state = "error"
        m.meta.visible = false
        m.errorMessage.visible = true
        AnalyticsLogException("no network connection")
    else
        if m.top.state = "finished"
            if NOT m.errorMessage.visible
                m.watchedPercent = "100"
                logWatchedPercent()
                HidePlayer()
            end if
        else
            m.errorMessage.visible = false
        end if
    end if
end sub

sub logWatchedPercent()
    if m.top.duration > 0
        if type(m.watchedPercent) <> "roInteger"
            AnalyticsLogPlayerEvent("Video", "playback_percentage", m.watchedPercent, m.videoTitle, m.videoId)
        end if
    end if
end sub

sub atmosSoundbarTextChanged()
    height = m.dolbyText.boundingRect().height
    m.dolbyMessage.height = height + (m.dolbyText.translation[1] * 2)
    m.dolbyMessage.translation = [m.dolbyMessage.translation[0], (1080 - m.dolbyMessage.height - 80)]
end sub

function onKeyEvent(key, press)
    ' if user navigates back, fire analytics percentage complete
    if press AND key = "back"
        logWatchedPercent()            
    end if

    #if dev
        if press 
            if key = "back"
                logWatchedPercent()            
            else if key = "up"
                handleShowVideoInfo()
            end if
        end if
    #else
        if press AND key = "back"
            logWatchedPercent()            
        end if
    #end if

    ' return false to bubble up to homescene onKeyEvent
    return false
end function

#if dev
function handleShowVideoInfo()
    if m.infoVisible = invalid
        m.infoVisible = false
    end if

    if m.infoVisible
        m.infoVisible = false
        m.top.removeChild(m.infoLabel)
        m.infoLabel = invalid
    else
        kbps = cInt(m.top.downloadedSegment.bitrateBps / 100)
        dataTxt = "Measured Bitrate: " + cInt(m.top.streamInfo.measuredBitrate / 100).toStr() + " kbps"
        dataTxt = dataTxt + chr(10) + "Segment Bitrate: " + kbps.toStr() + " kbps"
        dataTxt = dataTxt + chr(10) + "Format: " + m.top.videoFormat
        dataTxt = dataTxt + chr(10) + "Segment url: " + m.top.downloadedSegment.segUrl
        m.infoVisible = true
        m.infoLabel = CreateObject("roSGNode", "Rectangle")
        m.infoLabel.width = 700
        m.infoLabel.height = 700
        m.infoLabel.color = "0x4D86E2FF"
        xPos = (m.meta.width / 2) - 350
        m.infoLabel.translation = [xPos,200]
        txt = CreateObject("roSGNode", "Label")
        txt.width = 700
        txt.height = 700
        txt.horizAlign = "center"
        txt.vertAlign = "center"
        txt.color = "0xFFFFFFFF"
        txt.wrap = true
        txt.text = dataTxt
        m.infoLabel.appendChild(txt)
        m.top.appendChild(m.infoLabel)
    end if
end function
#end if
