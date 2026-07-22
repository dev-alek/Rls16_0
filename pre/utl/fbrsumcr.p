block-level on error undo, throw.
do
on error undo, return error
:
    define buffer buf_fbr-line      for fbr-line.
    for each buf_fbr-line exclusive-lock
    on error undo, return error
    :
        if buf_fbr-line.price-sum-rubl = 0
        and buf_fbr-line.price-sum-base = 0
        then do:
            assign
                buf_fbr-line.price-sum-rubl = buf_fbr-line.price-rubl * buf_fbr-line.fact-qnty
                buf_fbr-line.price-sum-base = buf_fbr-line.price-base * buf_fbr-line.fact-qnty
            .
        end.
        if buf_fbr-line.price-rubl = ?
        then do:
            assign
                buf_fbr-line.price-rubl = 0
            .
        end.
        if buf_fbr-line.price-base = ?
        then do:
            assign
                buf_fbr-line.price-base = 0
            .
        end.
        if buf_fbr-line.price-sum-rubl = ?
        then do:
            assign
                buf_fbr-line.price-sum-rubl = 0
            .
        end.
        if buf_fbr-line.price-sum-base = ?
        then do:
            assign
                buf_fbr-line.price-sum-base = 0
            .
        end.
        if buf_fbr-line.price-sum-vat-rubl = ?
        then do:
            assign
                buf_fbr-line.price-sum-vat-rubl = 0
            .
        end.
        if buf_fbr-line.price-sum-vat-base = ?
        then do:
            assign
                buf_fbr-line.price-sum-vat-base = 0
            .
        end.
    end.
end.
