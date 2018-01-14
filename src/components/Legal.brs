sub componentDidMount(p)
'    m.top.setFocus(true)
'?"LEGAL HAS FOCUS"
end sub

function shouldComponentUpdate()
' ?"$$$$$$$$$$$$$$$$", m.top.state
'     if m.top.state.ab <> invalid and NOT m.top.state.ab
' ?"SHORTCIRCUIT"
'         return false
'     end if
    return true
end function

function render(p)
?"render.legal", m.top.id

    props = m.top.props
    state = m.top.state

    if state.ab <> invalid AND NOT state.ab
        return h("Rectangle", {color: "0xFF00FF", width: 100, height: 100})
    else
        labelText = props.legalText
        if state.legalText <> invalid then labelText = state.legalText
        return h("Label", {text: labelText, translation: [100,100]})
    end if
end function

function onKeyEvent(key, press)
?"legal onkeyevent", key, press

    if press and key = "down"
        ab = true
        if m.top.state.ab <> invalid then ab = false
        m.top.setState = {legalText: "this was updated by a key event", ab: ab}
    end if

    return true
end function
