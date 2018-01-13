sub init()
    m.poster = m.top.findNode("poster")
    m.title = m.top.findNode("title")
    m.desc = m.top.findNode("desc")
    m.videoInfoContainer = m.top.findNode("videoInfoContainer")
    m.top.observeField("itemContent", "contentChanged")
    m.top.observeField("height", "heightChanged")
    m.top.observeField("focusPercent", "focusPercentChanged")
    m.minScale = 0.96
    m.poster.scale = [m.minScale, m.minScale]

    ' styling labels
    titleFont = CreateObject("roSGNode", "Font")
    titleFont.uri = "pkg:/locale/default/fonts/SourceSansPro/SourceSansPro-Semibold.ttf"
    titleFont.size = 30
    m.title.font = titleFont

    descFont = CreateObject("roSGNode", "Font")
    descFont.uri = "pkg:/locale/default/fonts/SourceSansPro/SourceSansPro-Regular.ttf"
    descFont.size = 27
    m.desc.font = descFont

    m.timer = CreateObject("roSGNode", "Timer")
    m.timer.interval = 0.1
    m.timer.observeField("fire", "talkerTimerFired")
end sub

sub contentChanged()
    content = m.top.itemContent
    
    ' portrait items have up to 3 lines
    if content.type = "portraititem"
        m.desc.maxLines = 3
    ' landscape items have up to 2 lines
    else if content.type = "rowitem"
        m.desc.maxLines = 2
    end if

    ' setting content
    m.poster.uri = content.thumbnail + "?w=" + m.top.width.toStr()
    m.title.text = content.title
    ' description includes duration and description
    m.desc.text = timeFromSeconds(content.runtimeseconds) + " | " + content.shortDescription

    ' setting videoInfo to the correct spot on the videoItem
    m.videoInfoContainer.height = 75
    m.videoInfoContainer.translation = [0, ((m.top.height - m.videoInfoContainer.height))]
    m.videoInfoContainer.width = m.top.width

    m.top.clippingRect = [0, 0, m.top.width, m.top.height]
    
    m.title.width = m.top.width - 60
    m.desc.width = m.top.width - 60

    m.title.translation = [25, 10]
    m.desc.translation = [25, 52]
end sub

sub heightChanged()
    m.poster.scaleRotateCenter = [m.top.width/2, m.top.height/2]
end sub

sub talkerTimerFired()
    content = m.top.itemContent
    if m.top.visible AND m.top.rowHasFocus AND m.top.focusPercent = 1.0 AND content <> invalid 
        talker = CreateObject("roAudioGuide")
        talker.flush()
        talker.say(content.title, false, true)
        talker.say(timeAsString(content.runtimeseconds), false, true)
        talker.say(content.shortDescription, false, true)
    end if
end sub

sub focusPercentChanged()
    scale = 1 - ((1 - m.minScale) * (1 - m.top.focusPercent))
    m.poster.scale = [scale, scale]
    
    content = m.top.itemContent
    if m.top.focusPercent = 1.0 AND content <> invalid
        'this interrupts the built-in system speech. then we trigger a timer to speak the custom audio
        talker = CreateObject("roAudioGuide")
        talker.flush()
        m.timer.control = "start"
    end if

    if m.top.focusPercent > 0.0
        ' adjusting title translation for focus
        if (100 + m.desc.boundingRect().height) * m.top.focusPercent >= 65
            m.title.translation = [25, 10]
            m.desc.visible = true
            m.videoInfoContainer.height = (75 + m.desc.boundingRect().height) * m.top.focusPercent
            m.videoInfoContainer.translation = [0, (m.top.height - m.videoInfoContainer.height)]
        else
            hideDesc()
        end if
    else
        hideDesc()
    end if
end sub

sub hideDesc()
    m.videoInfoContainer.height = 75
    m.title.translation = [25, 10]
    m.desc.visible = false
    m.videoInfoContainer.translation = [0, ((m.top.height - m.videoInfoContainer.height))]
end sub

' used to appropriately display the duration
function timeFromSeconds(seconds as Integer)
    time = CreateObject("roDateTime")
    time.FromSeconds(seconds)

    hoursString = ""
    minutesString = ""
    secondsString = ""

' minutes and seconds are always visible but there is no leading zero
' so, if there are no hours, then single digit minutes do not display the zero

    if time.GetHours() > 0
        hoursString = time.GetHours().toStr() + ":"
    end if

    if time.GetMinutes() > 0
        if time.GetMinutes() < 10 AND time.GetHours() > 0
            minutesString = "0" + time.GetMinutes().toStr() + ":"
        else
            minutesString = time.GetMinutes().toStr() + ":"
        end if
    else if time.GetMinutes() = 0
        minutesString = "00:"
    end if

    if time.GetSeconds() > 9
        secondsString = time.GetSeconds().toStr()
    else if time.GetSeconds() > 0 AND time.GetSeconds() < 10
        secondsString = "0" + time.GetSeconds().toStr()
    else 
        secondsString = "00"
    end if

    duration = hoursString + minutesString + secondsString
    
    return duration

end function

function timeAsString(seconds as Integer)
    time = CreateObject("roDateTime")
    time.FromSeconds(seconds)

    hoursString = ""
    minutesString = ""
    secondsString = ""

    if time.GetHours() > 0
        if time.GetHours() = 1
            hoursString = time.GetHours().toStr() + " hour "
        else 
            hoursString = time.GetHours().toStr() + " hours "
        end if
    end if

    if time.GetMinutes() = 1
        minutesString = time.GetMinutes().toStr() + " minute "
    else
        minutesString = time.GetMinutes().toStr() + " minutes "
    end if

    if time.GetSeconds() = 1
        secondsString = time.GetSeconds().toStr() + " second "
    else
        secondsString = time.GetSeconds().toStr() + " seconds "
    end if

    duration = hoursString + minutesString + secondsString
    return duration

end function
