sub AddTodo(text)
    RedokuDispatch({
        type: "ADD_TODO",
        text: text
    })
end sub

sub ToggleTodo(id)
    RedokuDispatch({
        type: "TOGGLE_TODO",
        id: id
    })
end sub

sub SetFilter(filter)
    RedokuDispatch({
        type: "SET_FILTER",
        filter: filter
    })
end sub
