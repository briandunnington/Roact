function shouldComponentUpdate()
    return m._shouldComponentUpdate()
end function

sub mapState(fx)
    m.global.observeField("state", "_mapStateHandler")
    m._mapStateImplementation = fx
    m._mapStateShouldComponentUpdate = true
    m._shouldComponentUpdate = function()
        return m._mapStateShouldComponentUpdate
    end function
end sub

sub _mapStateHandler()
    props = m._mapStateImplementation(m.global.state, m.global.prevState)
    if props <> invalid
        m._mapStateShouldComponentUpdate = true
        if props <> invalid then setState(props)
        m._mapStateShouldComponentUpdate = false
    end if
end sub
