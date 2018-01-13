sub init()
    m.title = m.top.findNode("title")
    m.container = m.top.findNode("container")

    m.body = invalid
    m.legalSection = invalid
    m.lastRenderedSection = invalid

    m.top.observeField("visible", "visibleChanged")
    m.top.observeField("focusedChild", "focusChanged")

    m.global.observeField("state", "stateChanged")
end sub

sub visibleChanged()
    if m.top.visible 'AND m.legalSection <> m.lastRenderedSection
?"RERENDER"
        m.container.removeChildIndex(0)
        m.lastRenderedSection = m.legalSection
        legalItem = m.global.state.data.data[m.legalSection]

        ' styling title
        titleFont = CreateObject("roSGNode", "Font")
        titleFont.uri = "pkg:/locale/default/fonts/SourceSansPro/SourceSansPro-Light.ttf"
        titleFont.size = 54
        m.title.color = "0xe6e6e6"

        m.title.font = titleFont
        m.title.text = legalItem.title
        AnalyticsLogPage(legalItem.title)
        'NOTE: we have to recreate the ScrollableText component each time.
        'If we only update the text, the scroll position is retained and can cause issues when the text lengths are different.
        body = CreateObject("roSGNode", "ScrollableText")
        body.setFields({
            width: 1500,
            height: 790,
            text: legalItem.body
        })

        ' styling body
        bodyFont = CreateObject("roSGNode", "Font")
        bodyFont.uri = "pkg:/locale/default/fonts/SourceSansPro/SourceSansPro-Regular.ttf"
        bodyFont.size = 27
        body.font = bodyFont
        body.color = "0xe6e6e6"
        body.scrollbarTrackBitmapUri = "pkg:/locale/default/images/textfieldscrollbg.png"
        body.scrollbarThumbBitmapUri = "pkg:/locale/default/images/textfieldscroll.png"

        m.body = body
        m.container.appendChild(body)
    end if
end sub

sub focusChanged()
    if m.top.hasFocus()
        m.body.setFocus(true)
    end if
end sub

sub stateChanged()
    prevState = m.global.prevState
    state = m.global.state
    if prevState = invalid OR prevState.data = invalid then return

    if m.legalSection <> state.data.legalSection
        m.legalSection = state.data.legalSection
    end if
end sub

function onKeyEvent(key, press)
    if press
        if key = "OK"
            HideLegal()
            return true
        end if
    end if
    return false
end function