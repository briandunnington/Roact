sub init()
    m.rowlist = m.top.findNode("rowlist")
    m.title = m.top.findNode("title")
    m.subtitle = m.top.findNode("subtitle")
    m.back = m.top.findNode("back")

    m.global.observeField("state", "stateChanged")
    m.top.observeField("visible", "visibleChanged")
    m.top.backButtonHasFocus = false

    titleFont = CreateObject("roSGNode", "Font")
    titleFont.uri = "pkg:/locale/default/fonts/SourceSansPro/SourceSansPro-Regular.ttf"
    titleFont.size = 54
    m.title.font = titleFont

    subtitleFont = CreateObject("roSGNode", "Font")
    subtitleFont.uri = "pkg:/locale/default/fonts/SourceSansPro/SourceSansPro-Light.ttf"
    subtitleFont.size = 44
    m.subtitle.font = subtitleFont
end sub

sub visibleChanged()
    if m.top.visible
        updateFocus(true)
    end if
end sub

sub stateChanged()
    prevState = m.global.prevState
    state = m.global.state
    if prevState = invalid OR prevState.data = invalid then return

    if prevState.data.data = invalid AND state.data.data <> invalid
        if state.data.data.error <> invalid
            return
        end if

        data = state.data.data.where
        m.title.text = data.title
        m.subtitle.text = data.subtitle
        m.rowlist.content = data

        ' setting the offset if there are one or two items
        if data.contentproviders.GetChildCount() = 1
            m.rowlist.translation = [730,330]
        else if data.contentproviders.GetChildCount() = 2
            m.rowlist.translation = [440,330]
        else if data.contentproviders.GetChildCount() = 3
            m.rowlist.translation = [110,330]
        end if
        updateFocus(true)
    end if
end sub

' used to handle focus and change button image
function updateFocus(buttonHasFocus)
    if buttonHasFocus
        m.rowlist.setFocus(false)
        m.back.setFocus(true)
        m.top.backButtonHasFocus = true
        m.back.uri = "pkg:/locale/default/images/back-arrow-hover.png"
    else
        m.rowlist.setFocus(true)
        m.rowlist.drawFocusFeedback = true
        m.back.setFocus(false)
        m.top.backButtonHasFocus = false
        m.back.uri = "pkg:/locale/default/images/back-arrow.png"
    end if
end function

function onKeyEvent(key, press)
    if press
        if key = "OK"
            ' if back button has focus, hide, change back button to unfocused state
            if m.top.backButtonHasFocus
                HideWhereToFind()
                m.back.uri = "pkg:/locale/default/images/back-arrow.png"
                m.top.backButtonHasFocus = false
                return true
            end if
        else if key = "up"
            ' if button has focus, do nothing
            if m.top.backButtonHasFocus
                return false
            else
            ' otherwise, update focus
            updateFocus(true)
            end if    
        else if key = "down"
            ' if button has focus, update focus
            if m.top.backButtonHasFocus
                updateFocus(false)
            else
            ' rowlist already has focus, do nothing
                return false
            end if
        end if
    end if
    return false
end function


