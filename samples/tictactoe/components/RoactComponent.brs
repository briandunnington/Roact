sub init()
end sub

sub componentDidMount(p)
end sub

function shouldComponentUpdate()
    return true
end function

function render(p)
    ?"WARNING: render() not implemented", m.top.id
    return invalid
end function

function conditionalRender(p)
    if shouldComponentUpdate() then m.top.lastRender = render(p)
    return m.top.lastRender
end function

sub setState(changedState)
    state = m.top.state
    state.append(changedState)
    m.top.state = state
    RoactUpdateElement(m.top)
end sub

function createHandler(functionName)
    return {
        node: m.top
        func: functionName
    }
end function

sub executeHandler(handler, args = invalid)
    handler.node.callFunc(handler.func, args)
end sub
