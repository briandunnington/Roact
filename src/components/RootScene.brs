function init()
    m.top.backgroundURI = ""
    m.top.backgroundColor = "0x000000"

    m.root = m.top.findNode("root")

    ' RedokuRegisterReducer("data", allReducer)

    ' RedokuInitialize()

    x = h("Rectangle", {id: "rect", color: "0xff0000", width: 600, height: 400}, [
            h("Poster", {}, [
                h("Label", {text: "this is a label"})
            ])
        ])

    updateElement(m.root, invalid, x, 0)
    m.x = x

    m.top.setFocus(true)
end function


function onKeyEvent(key, press)
    if press
        if key = "down"
            y = h("Rectangle", {id: "rect", color: "0x0000ff", width: 700, height: 500}, [
                    h("Poster", {}, [
                        h("Label", {text: "the text changed"})
                    ])
                ])

            updateElement(m.root, m.x, y, 0)
            m.x = y

?m.top.findNode("rect").color
        end if
    end if

    return false
end function
