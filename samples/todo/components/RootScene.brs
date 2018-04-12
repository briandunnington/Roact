function init()
    m.top.backgroundURI = ""
    m.top.backgroundColor = "0x000000"

    RedokuRegisterReducer("all", allReducer)
    RedokuInitialize()

    ' render you app into the scene
    RoactRenderScene(m.top, h("App", {id: "app"}))
end function
