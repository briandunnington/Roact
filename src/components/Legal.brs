sub componentDidMount(p)
    m.top.setFocus(true)
?"LEGAL HAS FOCUS"
end sub

function render(p)
?"render.legal", m.top.id, m.top.props.labelText

    return h("Label", {text: m.top.props.labelText, translation: [100,100]})
end function

function onKeyEvent(key, press)
?"legal onkeyevent", key, press

    if press and key = "down"
        m.top.setProps = {labelText: "this was updated by a key event"}
    end if

    return true
end function
