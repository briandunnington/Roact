sub init()
    m.top.observeField("focusedChild", "focusChanged")
end sub

sub componentDidMount(p)
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

function render(p)
    props = m.top.props

    return h("Button", {
        id: "button"
        minWidth: props.size
        maxWidth: props.size
        height: props.size
        showFocusFootprint: true
        iconUri: ""
        focusedIconUri: ""
        translation: props.translation
        text: props.value
    })
end function
