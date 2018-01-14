sub init()
    m.top.state = {}
end sub

sub componentDidMount(p)
?"Component did mount", m.top.id
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

sub setStateChanged(msg)
    changedState = msg.getData()
    state = m.top.state
    state.append(changedState)
    m.top.state = state
    RoactUpdateElement(m.top)
end sub
