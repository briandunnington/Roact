sub init()
?"init init init"
    m.oldVNode = invalid
end sub

sub componentDidMount(p)
?"Component did mount", m.top.id
end sub

function shouldComponentUpdate()
?"should component update", m.top.id
    return true
end function

function render(p)
?"render", m.top.id
    return invalid
end function

function conditionalRender(p)
    if shouldComponentUpdate() then m.oldVNode = render(p)
    return m.oldVNode
end function



sub setPropsChanged(msg)
    changedProps = msg.getData()
?"SETPROPS", changedProps
    props = m.top.props
    props.append(changedProps)
?"PP", props
    m.top.props = props
    newVNode = render(invalid)
    RoactUpdateElement(m.top, m.oldVNode, newVNode, 0)
end sub
