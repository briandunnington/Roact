function allReducer(state, action)
    if action.type = "ADD_TODO"
        items = []
        for i=0 to state.items.Count() - 1
            items.push(state.items[i])
        end for

        items.push({
            id: items.count().toStr()
            text: action.text,
            completed: false
        })
        newState = RedokuClone(state)
        newState.items = items
        return newState
    else if action.type = "TOGGLE_TODO"
        items = []
        for i=0 to state.items.Count() - 1
            item = state.items[i]
            if item.id = action.id
                item = RedokuClone(item)
                item.completed = NOT item.completed
            end if
            items.push(item)
        end for
        newState = RedokuClone(state)
        newState.items = items
        return newState
    else if action.type = "SET_FILTER"
        if NOT state.fitler = action.filter
            newState = RedokuClone(state)
            newState.filter = action.filter
            return newState
        end if
    end if
    return state
end function
