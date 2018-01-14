function init()
    m.top.backgroundURI = ""
    m.top.backgroundColor = "0x000000"

    m.top.setFocus(true)
end function


function onKeyEvent(key, press)
    if press
        'set the focus on the 'App' component so it can receive key presses
        x = m.top.findNode("app")
        x.setFocus(true)
    end if
    return false
end function
