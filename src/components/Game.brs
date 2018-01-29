function render(p)
    return h("Group", {}, [
                h("Board"),
                h("Label", {text: "status", translation: [1000,100]}),
            ])
end function
