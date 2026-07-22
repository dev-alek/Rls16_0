using Progress.Lang.*.
block-level on error undo, throw.
class ibs.th.gbl.logging.logger:
  define static property Path as character no-undo
    get.
    set.
  define static property StrLogPut as character no-undo
    get.
    set (a as char):
      StrLogPut = a.
      PutStr(StrLogPut).
    end.
 define stream strlog.
  method static public void PutStr (str as char):
    define variable v-path as character no-undo.
    if search (Path) = ?
    then v-path = Path.
    else v-path = search (Path).
    output stream strlog to value (v-path) append.
    put stream strlog unformatted str chr(10).
    output stream strlog close.
  end.
end class.
