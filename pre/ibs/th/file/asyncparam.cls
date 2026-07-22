using Progress.Lang.*.
block-level on error undo, throw.
class ibs.th.file.asyncparam:
    define public property nameParam as character  no-undo
    get.
    private set.
    define public property valueParam as character no-undo init ?
    get.
    set.
    constructor asyncparam(inameParam as character):
        nameParam = inameParam.
    end.
end class.
