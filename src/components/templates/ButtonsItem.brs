sub init()
    m.privacy = m.top.findNode("privacy")
    m.tos = m.top.findNode("tos")

    m.TEMPp = m.top.findNode("TEMPp")
    m.TEMPt = m.top.findNode("TEMPt")

    m.top.observeField("itemContent", "contentChanged")
    m.top.observeField("rowHasFocus", "rowHasFocusChanged")

    m.global.observeField("state", "stateChanged")

    m.timer = CreateObject("roSGNode", "Timer")
    m.timer.interval = 0.1
    m.timer.observeField("fire", "talkerTimerFired")
end sub

sub stateChanged()
    if m.top.rowHasFocus AND m.top.visible
        m.legalSection = m.global.state.data.legalSection
        setFocus()
    end if
end sub

sub contentChanged()
    content = m.top.itemContent

    privacyButtonNode = content["tclprivacybutton"]
    tosButtonNode = content["tcltosbutton"]

    m.privacy.text = privacyButtonNode.prompt
    m.tos.text = tosButtonNode.prompt
end sub

sub rowHasFocusChanged()
    m.legalSection = m.global.state.data.legalSection
    setFocus()
end sub

sub talkerTimerFired()
    content = m.top.itemContent
    if m.top.visible AND m.top.rowHasFocus AND content <> invalid 
        ?"speaking button item info............."
        talker = CreateObject("roAudioGuide")
        talker.flush()
        if m.legalSection = "tos"
            talker.say("terms of service button", true, false)
        else
            talker.say(m.legalSection + "button", true, false)
        end if
    end if
end sub

sub setFocus()
    p = false
    t = false
    if m.top.rowHasFocus AND m.top.visible
        p = (m.legalSection = "privacy")
        t = (m.legalSection = "tos")

        'this interrupts the built-in system speech. then we trigger a timer to speak the custom audio
        talker = CreateObject("roAudioGuide")
        talker.flush()
        m.timer.control = "start"
    end if
    
    if p
        m.TEMPp.uri = "pkg:/locale/default/images/focusedButton.png"
    else
        m.TEMPp.uri = "pkg:/locale/default/images/unfocusedButton.png"
    end if

    if t
        m.TEMPt.uri = "pkg:/locale/default/images/focusedButton.png"
    else
        m.TEMPt.uri = "pkg:/locale/default/images/unfocusedButton.png"
    end if
end sub
