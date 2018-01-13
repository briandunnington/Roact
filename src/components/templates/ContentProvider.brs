sub init()
    m.poster = m.top.findNode("poster")
    m.border = m.top.findNode("border")
    m.desc = m.top.findNode("desc")
    m.top.observeField("itemContent", "contentChanged")
    m.top.observeField("focusPercent", "focusPercentChanged")
    m.top.observeField("rowHasFocus", "rowHasFocusChanged")

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

    m.poster.uri = content.logoImage + "?w=" + m.top.width.toStr()
    m.desc.width = m.top.width - 75
    m.desc.text = content.body
end sub

sub talkerTimerFired()
    content = m.top.itemContent
    if m.top.visible AND m.top.rowHasFocus AND m.top.focusPercent = 1.0 AND content <> invalid 
        talker = CreateObject("roAudioGuide")
        talker.flush()
        talker.say(content.body, false, true)
    end if
end sub

sub focusPercentChanged()    
    content = m.top.itemContent
    if m.top.focusPercent = 1.0 AND content <> invalid
        ' m.border.visible = false
        'this interrupts the built-in system speech. then we trigger a timer to speak the custom audio
        talker = CreateObject("roAudioGuide")
        talker.flush()
        m.timer.control = "start"
    else 
        ' m.border.visible = true
    end if
    handleBorder()
end sub

sub rowHasFocusChanged()
    handleBorder()
end sub

sub handleBorder()
    if m.top.rowHasFocus AND m.top.focusPercent = 1.0
        m.border.visible = false
    else
        m.border.visible = true
    end if
end sub
