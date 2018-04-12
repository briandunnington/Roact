sub init()
    m.top.state = {
        filter: m.global.state.all.filter
    }

    mapState(function(state, prevState)
        if prevState = invalid or state.all.filter <> prevState.all.filter
            return {
                filter: state.all.filter
            }
        else
            return invalid
        end if
    end function)
end sub

sub componentDidMount(p)
    m.label = m.top.findNode("lbl")
end sub

function render(p)
    m.top.translation = m.top.props.translation

    status = "Showing: " + m.top.state.filter
    return h("Label", {text: status})
end function
