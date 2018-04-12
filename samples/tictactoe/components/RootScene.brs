function init()
    m.top.backgroundURI = ""
    m.top.backgroundColor = "0x000000"

    ' render you app into the scene
    RoactRenderScene(m.top, h("Game", {id: "game"}))
end function
