sub componentDidMount()
    m.addTodo = m.top.findNode("addTodo")
    m.todoList = m.top.findNode("todoList")
    m.addTodo.setFocus(true)
end sub

function render()
    return h("Group", {translation: [64, 64]}, [
        h("AddTodo", {id: "addTodo"}),
        h("TodoList", {id: "todoList", translation: [600, 9]}),
        h("Status", {id: "status", translation: [0, 100]})
    ])
end function

function onKeyEvent(key, press)
    if press
        if key = "left" AND NOT m.addTodo.isInFocusChain()
            m.addTodo.setFocus(true)
        else if key = "right" AND NOT m.todoList.isInFocusChain()
            m.todoList.setFocus(true)
        else if key = "options"
            filter = "OPEN"
            if m.global.state.all.filter <> "ALL" then filter = "ALL"
            SetFilter(filter)
        end if
    end if
    return false
end function
