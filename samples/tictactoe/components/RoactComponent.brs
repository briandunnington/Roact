'------------------------------------------------------------------
' Override any of these methods in your Roact component
sub init()
    m.top.state = {}
end sub

sub componentDidMount()
end sub

sub componentDidUpdate(prevProps, prevState)
end sub

function shouldComponentUpdate(nextProps, nextState)
    return true
end function

function render()
    ?"WARNING: render() not implemented", m.top.id
    return invalid
end function

'------------------------------------------------------------------




'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
' Everything below here is used internally by Roact

sub setState(changedState)
    state = m.top.state
    newState = {}
    newState.append(state)
    newState.append(changedState)
    RoactUpdateElement(m.top, newState)
end sub

function roactComponentDidMount(ignore)
    componentDidMount()
end function

function roactComponentDidUpdate(prevPropsAndState)
    componentDidUpdate(prevPropsAndState.props, prevPropsAndState.state)
end function

function roactConditionalRender(nextPropsAndState)
    shouldRender = true
    if nextPropsAndState <> invalid
        shouldRender = shouldComponentUpdate(nextPropsAndState.props, nextPropsAndState.state)
        if shouldRender
            m.top.setFields({
                props: nextPropsAndState.props
                state: nextPropsAndState.state
            })
        end if
    end if

    if shouldRender
        r = render()
        r.__instance = strI(rnd(2147483647), 36)
        m.top.lastRender = r
    end if
    return m.top.lastRender
end function

function createHandler(functionName)
    return {
        node: m.top
        func: functionName
    }
end function

sub executeHandler(handler, args = invalid)
    handler.node.callFunc(handler.func, args)
end sub
