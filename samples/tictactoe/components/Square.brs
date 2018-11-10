sub init()
    m.top.observeField("focusedChild", "focusChanged")
    m.font = CreateObject("roSGNode", "Font")
    m.font.uri = "pkg:/locale/default/HelveticaNeue-Medium.ttf"
    m.font.size = 72
end sub

sub componentDidMount()
    findButton()
    m.button.observeField("buttonSelected", "buttonClicked")
end sub

sub findButton()
    if m.button = invalid then m.button = m.top.findNode("button")
end sub

sub focusChanged()
    findButton()
    if m.top.hasFocus() then m.button.setFocus(true)
end sub

sub buttonClicked()
    props = m.top.props
    executeHandler(props.onClick, {index: props.index})
end sub

function render()
    props = m.top.props

    val = props.value

    color = "0xFFFFFF"
    if val <> invalid
        if props.value = "X"
            color = "0xFF0000"
        else if props.value = "O"
            color = "0xFFFF00"
        end if
        val = val + "   " + Chr(160)
    end if

    return h("Button", {
        id: "button"
        minWidth: props.size
        maxWidth: props.size
        height: props.size
        showFocusFootprint: true
        iconUri: ""
        focusedIconUri: ""
        translation: props.translation
        textFont: m.font
        focusedTextFont: m.font
        text: val
        textColor: color
        focusedTextColor: color
    })
end function
