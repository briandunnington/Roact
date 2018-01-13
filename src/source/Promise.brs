function createPromiseFromTask(taskName as string, fields as object, signalField = "completedTask" as string) as object
    id = Str(Rnd(0))
    task = CreateObject("roSGNode", taskName)
    task.observeField(signalField, "taskPromiseCallbackHandler")
    if fields <> invalid
        for each key in fields
           task[key] = fields[key]
        end for
    end if
    task.id = id
    task.control = "run"
    promise = {
        then: function(callback as function)
           m.context[m.id + "_callback"] = callback
        end function
    }
    promise.context = m
    promise.id = id
    promise.task = task
    m[id] = promise
    return promise
end function

function taskPromiseCallbackHandler(e as object)
    task = e.getRoSGNode()
    id = task.id
    promise = m[id]
    promise.context[id + "_callback"](promise.task)
    'cleanup circular references
    if promise.suppressDispose = invalid
        promise.context = invalid
        promise.task = invalid
        m[id] = invalid
        m[id + "_callback"] = invalid
    end if
end function

function whenAllPromisesComplete(arrayOfPromises as object)
    id = Str(Rnd(0))
    for i=0 to arrayOfPromises.Count() - 1
        promise = arrayOfPromises[i]
        promise.masterPromiseId = id
        promise.then(function(task)
            id = task.id
            promise = m[id]
            m[promise.masterPromiseId].complete(promise)
            promise.suppressDispose = true
        end function)
    end for
    masterPromise = {
        then: function(callback as function)
            m.context[m.id + "_callback"] = callback
        end function,
        complete: function(promise)
            mp = m
            mp.pendingPromiseCount = mp.pendingPromiseCount - 1
            if mp.pendingPromiseCount = 0
                mp.context[mp.id + "_callback"](mp.promises)
                for i=0 to mp.promises.Count() - 1
                    promise = mp.promises[i]
                    promise.context = invalid
                    promise.task = invalid
                    mp.context[promise.id] = invalid
                    mp.context[promise.id + "_callback"] = invalid
                end for
                mp.context[mp.id] = invalid
                mp.context[mp.id + "_callback"] = invalid
                mp.promises = invalid
                mp.context = invalid
            end if
        end function
    }
    masterPromise.id = id
    masterPromise.context = m
    masterPromise.promises = arrayOfPromises
    masterPromise.pendingPromiseCount = arrayOfPromises.Count()
    m[id] = masterPromise
    return masterPromise
end function
