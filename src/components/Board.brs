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
    focusOn(0)
end sub

function render(p)
?"render.board", m.top.id

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
                h("Label", {text: status, translation: [1000,0]}),
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
    return h("Square", {id: "Square" + index.toStr(), index: index, value: m.top.state.squares[index], size: size, translation: [tx,ty], onClick: createHandler("handleSquareClick")})
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
    m.top.setState = {squares: squares, xIsNext: (NOT state.xIsNext), winner: winner}
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
?"WINNER!!!!!!!!", a
            return a
        end if
    end for
    return invalid
end function

sub focusOn(index)
    m.top.findNode("Square" + index.toStr()).setFocus(true)
    m.focusIndex = index
end sub

function onKeyEvent(key, press)
    if press
        y = {
            up: 0
            right: 1
            down: 2
            left: 3
        }
        x = y[key]
        if x <> invalid
            n = [
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
            newIndex = n[m.focusIndex][x]
            if newIndex <> invalid
                focusOn(newIndex)
            end if
        end if
    end if
    return true
end function
