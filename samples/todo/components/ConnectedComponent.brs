sub mapState(fx)
    m.global.observeField("state", "_mapStateHandler")
    m._mapStateImplementation = fx
end sub

sub _mapStateHandler()
    props = m._mapStateImplementation(m.global.state, m.global.prevState)
    if props <> invalid then setState(props) else ?"IGNORED GLOBAL STATE CHANGE"
end sub
