function init()
    m.top.backgroundURI = ""
    m.top.backgroundColor = "0x000000"

    m.top.setFocus(true)


end function


function onKeyEvent(key, press)
?"asdfasdf"
    if press

    x = m.top.findNode("app")
    '?x
    x.setFocus(true)

        if key = "down"
'             y = h("Rectangle", {id: "rect", color: "0x0000ff", width: 700, height: 500}, [
'                     h("Poster", {}, [
'                         h("Label", {text: "the text changed"})
'                     ])
'                 ])

'             updateElement(m.root, m.x, y, 0)
'             m.x = y

' ?m.top.findNode("rect").color
        end if
    end if

    return false
end function
