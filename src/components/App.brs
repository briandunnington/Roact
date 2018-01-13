sub componentDidMount(p)
    m.top.setFocus(true)
?"APP HAS FOCUS"
end sub

function render(p)
?"render.app", m.top.id, m.top.props.labelText

    return h("Label", {text: m.top.props.labelText}, [
                h("Legal", m.top.props)
            ])
end function

function onKeyEvent(key, press)
?"app onkeyevent", key, press

    if press and key = "down"
        m.top.setProps = {labelText: "this was updated by a key event"}
    end if

    return true
end function
