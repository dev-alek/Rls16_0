using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
USING ibs.th.gbl.cur-time FROM PROPATH.
USING ibs.th.gbl.*.
block-level on error undo, throw.
class ibs.th.bge.1crn.import.impcashiers implements ibs.th.bge.1crn.import.iimpsubject:
  define variable curtime as class cur-time no-undo .
  define property Msg as character no-undo
    get.
    set.
  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
    define variable objCashiers as class cashiers no-undo.
    objCashiers = cast (subjectObj, cashiers) .
    run ref/imp-cashiers-1c-RN.p (input objCashiers) no-error .
    if error-status:error
      then
    do :
      Msg = return-value .
      return false.
    end.
  end method.
end class.
