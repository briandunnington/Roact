function render(p)
?"render.game", m.top.id

    return h("Group", {}, [
                h("Board"),
                h("Label", {text: "status", translation: [1000,100]}),
            ])
end function

function onKeyEvent(key, press)
?"app onkeyevent", key, press

    if press and key = "down"
        x = m.top.state.x + 1
        m.top.setState = {lblText: "this was updated by a key event", x: x, legalText: x.toStr()}

        if x = 3
            m.top.findNode("legal").setFocus(true)
?"set focus to Legal"
        end if
    end if

    return true
end function
