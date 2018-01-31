sub init()
    m.top.state = {
        squares: [invalid, invalid, invalid,
                  invalid, invalid, invalid,
                  invalid, invalid, invalid]
        xIsNext: true
        winner: invalid
    }
    m.focusIndex = 0
end sub

sub componentDidMount(p)
    m.focuseater = m.top.findNode("focuseater")
    focusOn(0)
end sub

function render(p)
    state = m.top.state

    status = ""
    if state.winner <> invalid
        status = "Winner: " + state.winner
    else
        val = "X"
        if NOT state.xIsNext then val = "O"
        status = "Next player: " + val
    end if

    return h("Group", {}, [
                h("Button", {id: "focuseater", visible: false}),
                h("Label", {text: status, translation: [1000,144]}),
                renderSquare(0),
                renderSquare(1),
                renderSquare(2),
                renderSquare(3),
                renderSquare(4),
                renderSquare(5),
                renderSquare(6),
                renderSquare(7),
                renderSquare(8)
            ])
end function

function renderSquare(index)
    size = 300
    tx = (index MOD 3) * 300
    ty = (index \ 3) * 300
    clickHandler = createHandler("handleSquareClick")
    return h("Square", {id: "Square" + index.toStr(), index: index, value: m.top.state.squares[index], size: size, translation: [tx,ty], onClick: clickHandler})
end function

sub handleSquareClick(args)
    index = args.index
    state = m.top.state
    if state.winner <> invalid then return          'already a winner
    if state.squares[index] <> invalid then return  'square already taken

    squares = []
    for i=0 to state.squares.count() - 1
        squares.push(state.squares[i])
    end for
    val = "X"
    if NOT state.xIsNext then val = "O"
    squares[index] = val
    winner = calculateWinner(squares)
    if winner <> invalid then m.focuseater.setFocus(true)
    setState({squares: squares, xIsNext: (NOT state.xIsNext), winner: winner})
end sub

function calculateWinner(squares)
    lines = [
        [0, 1, 2],
        [3, 4, 5],
        [6, 7, 8],
        [0, 3, 6],
        [1, 4, 7],
        [2, 5, 8],
        [0, 4, 8],
        [2, 4, 6],
    ]

    for i=0 to lines.count() - 1
        line = lines[i]
        a = squares[line[0]]
        b = squares[line[1]]
        c = squares[line[2]]
        if a <> invalid AND b <> invalid AND c <> invalid AND a = b AND a = c
            return a
        end if
    end for

    isCatGame = true
    for i=0 to squares.count() - 1
        if squares[i] = invalid
            isCatGame = false
            exit for
        end if
    end for
    if isCatGame
        return "CAT GAME"
    end if
    return invalid
end function

sub restartGame()
    setState({
        squares: [invalid, invalid, invalid,
                  invalid, invalid, invalid,
                  invalid, invalid, invalid]
        xIsNext: true
        winner: invalid
    })
    focusOn(0)
end sub

sub focusOn(index)
    m.top.findNode("Square" + index.toStr()).setFocus(true)
    m.focusIndex = index
end sub

function onKeyEvent(key, press)
    if press
        keyDirection = getKeyMap()[key]
        if keyDirection <> invalid AND m.top.state.winner = invalid
            newIndex = getDirectionMap()[m.focusIndex][keyDirection]
            if newIndex <> invalid
                focusOn(newIndex)
            end if
        else if key = "play"
            restartGame()
        end if
    end if
    return true
end function

function getKeyMap()
    if m.keyMap = invalid
        m.keyMap = {
            up: 0
            right: 1
            down: 2
            left: 3
        }
    end if
    return m.keyMap
end function

function getDirectionMap()
    if m.directionMap = invalid
        m.directionMap =[
            [invalid, 1, 3, invalid],
            [invalid, 2, 4, 0],
            [invalid, invalid, 5, 1],
            [0, 4, 6, invalid],
            [1, 5, 7, 3],
            [2, invalid, 8, 4],
            [3, 7, invalid, invalid],
            [4, 8, invalid, 6],
            [5, invalid, invalid, 7]
        ]
    end if
    return m.directionMap
end function
