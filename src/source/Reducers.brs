function allReducer(state, action)
    if action <> invalid AND action.type <> invalid
        if action.type = "DATA_LOADED"
            newState = RedokuClone(state)
            newState.data = action.data
            return newState
        else if action.type = "NETWORK_ERROR"
            newState = RedokuClone(state)
            newState.noNetwork = true
            return newState
        else if action.type = "TOGGLE_PLAYER"
            newState = RedokuClone(state)
            newState.videoItem = action.videoItem
            return newState
        else if action.type = "TOGGLE_WHERETOFIND"
            newState = RedokuClone(state)
            newState.showWhereToFind = action.showWhereToFind
            return newState
        else if action.type = "TOGGLE_LEGAL"
            newState = RedokuClone(state)
            newState.showLegal = action.showLegal
            return newState
        else if action.type = "CHANGE_LEGAL_SECTION"
            newState = RedokuClone(state)
            newState.legalSection = action.legalSection
            return newState
        end if
    end if
    return state
end function
