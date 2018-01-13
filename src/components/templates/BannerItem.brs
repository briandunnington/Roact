sub init()
    m.title = m.top.findNode("title")
    m.subtitle = m.top.findNode("subtitle")
    m.button = m.top.findNode("button")
    m.desc = m.top.findNode("desc")
    m.buttonContainer = m.top.findNode("buttonContainer")
    m.top.observeField("itemContent", "contentChanged")
    m.top.observeField("rowHasFocus", "rowHasFocusChanged")

    titleFont = CreateObject("roSGNode", "Font")
    titleFont.uri = "pkg:/locale/default/fonts/SourceSansPro/SourceSansPro-Light.ttf"
    titleFont.size = 54
    m.title.font = titleFont

    subtitleFont = CreateObject("roSGNode", "Font")
    subtitleFont.uri = "pkg:/locale/default/fonts/SourceSansPro/SourceSansPro-Light.ttf"
    subtitleFont.size = 38
    m.subtitle.font = subtitleFont

    descFont = CreateObject("roSGNode", "Font")
    descFont.uri = "pkg:/locale/default/fonts/SourceSansPro/SourceSansPro-Regular.ttf"
    descFont.size = 29
    m.desc.font = descFont

    buttonFont = CreateObject("roSGNode", "Font")
    buttonFont.uri = "pkg:/locale/default/fonts/SourceSansPro/SourceSansPro-Regular.ttf"
    buttonFont.size = 27
    m.button.font = buttonFont

    m.timer = CreateObject("roSGNode", "Timer")
    m.timer.interval = 0.1
    m.timer.observeField("fire", "talkerTimerFired")
end sub

sub contentChanged()
    content = m.top.itemContent

    m.title.text = content.title
    m.subtitle.text = content.subtitle
    m.desc.text = content.body
    m.button.text = content.buttonTitle
end sub

sub talkerTimerFired()
    content = m.top.itemContent
    if m.top.visible AND m.top.rowHasFocus AND content <> invalid 
        ?"speaking banner item info............."
        talker = CreateObject("roAudioGuide")
        talker.flush()
        talker.say(content.title, false, true)
        talker.say(content.subtitle, false, true)
        talker.say(content.body, false, true)
        talker.say(content.buttonTitle + " button", false, true)
    end if
end sub

sub rowHasFocusChanged()
    if m.top.rowHasFocus AND m.top.visible
        m.buttonContainer.color = "0x068dca"

        content = m.top.itemContent
        if content <> invalid
            'this interrupts the built-in system speech. then we trigger a timer to speak the custom audio
            talker = CreateObject("roAudioGuide")
            talker.flush()
            m.timer.control = "start"
        end if
    else
        m.buttonContainer.color = "0x3d484d"
    end if
end sub

