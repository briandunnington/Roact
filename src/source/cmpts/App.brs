function App()
    return {
        type: "RoactComponent"

        render: function()
?"XXXXX RENDERED", m.props
            return h("Group", {id: "xxxxxxxxxxxxxxxxx"}, m.children)
        end function
    }
end function


function C1()
    return {
        type: "C1"

        render: function()
?"C1 RENDERED", m.props
            props = {}
            props.append(m.props)
            props.append({opacity: 0.9})
            return h(C2, m.props, m.children)
        end function
    }
end function


function C2()
    return {
        type: "C2"

        render: function()
?"C2 RENDERED", m.props
            return h("Label", {id: "xyz", text: m.props.proppy}, m.children)
        end function
    }
end function

