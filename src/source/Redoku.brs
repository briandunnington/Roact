'THINGS TO NOTE:
' The only functions you should access outside of this file are:
'   * RedokuSetInitialState()
'   * RedokuRegisterReducer()
'   * RedokuInitialize()
'   * RedokuDispatch()
'   * RedokuClone()
'   * RedokuGetState()
'   * RedokuGetPrevState()
'   * IsRedokuActionQueued()
'
' m.global.state contains the state store (m.global.prevState contains the previous state) and are intended to be accessed outside this file.
' m.global.dispatch contains the dispatched action queue and timer (so that actions can be safely dispatched serially).
' m.reducers live only in the root scene to maintain consistent execution context.

'Call this from your main() function before you create your root scene.
sub RedokuSetInitialState(initialState as object, screen as object)
    m.global = screen.GetGlobalNode()
    m.global.addFields({
        state: RedokuClone(initialState),
        prevState: {}
    })
end sub

'Call this from your root scene BEFORE you call RedokuInitialize
sub RedokuRegisterReducer(section as string, reducer as function)
    if m.reducers = invalid then m.reducers = {}
    m.reducers[section] = reducer
end sub

'Call this from your root scene AFTER you have registered any reducers
sub RedokuInitialize()
    dispatchTimer = createObject("roSGNode", "Timer")
    dispatchTimer.duration = .01
    dispatchTimer.repeat = false
    dispatchTimer.observeField("fire", "RedokuDispatchTimerFired")

    m.global.addFields({
        dispatch: {
            timer: dispatchTimer,
            queue: []
        }
    })

    RedokuDispatch(invalid)
end sub

'Call this from any action creator to trigger a reducer cycle
sub RedokuDispatch(action as object)
    pre = m.global.dispatch.queue.count()
    dispatch = m.global.dispatch
    dispatch.queue.push(action)
    post = m.global.dispatch.queue.count()
    'TODO: come up with a better solution for this.
    'If multiple threads dispatch actions at the same time, there can be a race condition.
    'Since we have to copy the queue, modify it, and copy it back to the global node,
    'it can cause the wrong data to be written.
    'The temporary work-around is to check the queue count at the beginning of the operation
    'and again at the end to see if anybody else has modified the queue in the meantime.
    if NOT post = pre
        RedokuDispatch(action)
        return
    end if
    m.global.dispatch = dispatch

    if(m.global.dispatch.queue.count() > 0)
        m.global.dispatch.timer.control = "start"
    end if
end sub

'Call this from any reducer to clone the state
function RedokuClone(obj as object) as object
    newObj = {}

    if type(obj) = "roAssociativeArray"
        for each prop in obj
            newObj[prop] = obj[prop]
        end for
        newObj.__RedokuStateId = RedokuNewId()
    else if type(obj) = "roArray"
        size = obj.count()
        dim newObj[size]
        for i = 0 to size-1
            newObj[i] = obj[i]
        end for
    else if type(obj) = "roSGNode"
        fields = obj.GetFields()
        id = fields.id
        fields.__RedokuStateId = RedokuNewId()
        fields.delete("id")
        newObj = createObject("roSGNode", "ContentNode")
        newObj.id = id
        newObj.addFields(fields)
    end if
    return newObj
end function

function RedokuGetState()
    return m.global.state
end function

function RedokuGetPrevState()
    return m.global.prevState
end function

function IsRedokuActionQueued()
    return m.global.dispatch.queue.count() > 0
end function


'-------------------------------------------------------------------------------------
'Do not call the functions below here. They are called internally by the Redoku logic.
'-------------------------------------------------------------------------------------

'Do not call this - it is called automatically when RedokuDispatch is called
sub RedokuDispatchTimerFired()
    dispatch = m.global.dispatch
    if(dispatch.queue.count() > 0)
        action = dispatch.queue.shift()
        m.global.dispatch = dispatch
        RedokuRunReducers(action)
    end if
    ' If there are still events to process, start the timer again.
    if(m.global.dispatch.queue.count() > 0)
        m.global.dispatch.timer.control = "start"
    end if
end sub

'Do not call this - it is called automatically when RedokuDispatch is called
sub RedokuRunReducers(action as object)
    if m.reducers = invalid
        '?"Redoku: reducers were invalid"
        return
    else if action = invalid OR action.type = invalid
        '?"Redoku: action or action type was invalid"
        return
    end if

t = CreateObject("roTimespan")
    didChange = false
    state = RedokuGetState()
    prevState = state
    for each reducerKey in m.reducers
        section = reducerKey
        reducer = m.reducers[reducerKey]
        oldState = state[section]
        newState = reducer(oldState, action)
        if NOT RedokuCompareState(oldState, newState)
            state = RedokuClone(state)
            state[section] = newState
            didChange = true
        end if
    end for
    if didChange
        RedokuSetState(state)
    end if
?"REDUCERS TOOK:", t.TotalMilliseconds()
end sub

'Do not call this - it is only used to determine if the state has changed
'since Roku does not support object comparison.
function RedokuCompareState(oldState as object, newState as object) as boolean
    'return FormatJSON(oldState) = FormatJSON(newState)

    oldStateIsValid = (oldState <> invalid)
    newStateIsValid = (newState <> invalid)
    'Equal if:
    'both invalid
    'both valid AND dont have __RedokuStateId
    'both valid AND have __RedokuStateId AND ==
    if NOT oldStateIsValid AND NOT newStateIsValid then return true
    if oldStateIsValid AND newStateIsValid
        if NOT oldState.DoesExist("__RedokuStateId") AND NOT newState.DoesExist("__RedokuStateId") return true
        return oldState.__RedokuStateId = newState.__RedokuStateId
    end if
    'Otherwise, not equal
    return false
end function

sub RedokuSetState(newState)
    globals = m.global
    globals.prevState = RedokuGetState()
    globals.state = newState
end sub

' Returns an id, probably unique but not guaranteed.  Faster than
' roDeviceInfo's GetRandomUUID().  Collision chance: 0.00000000046566129%
function RedokuNewId()
    return strI(rnd(2147483647), 36)
end function
