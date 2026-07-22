using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
using ibs.th.bge.1crn.import.*.
block-level on error undo, throw.
class ibs.th.bge.1crn.import.impint-point implements ibs.th.bge.1crn.import.iimpsubject:
method private void getAttrLib ():
   define variable g#attr-lib  as handle no-undo .
   run gbl/getgattrlib.p (output g#attr-lib).
end.
  define buffer buf_db for ub.db.
  define buffer buf_clients for ub.clients.
  define property Msg as character no-undo
    get.
    set.
  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
    define variable result      as logical   no-undo.
    define variable mode        as character no-undo.
    define variable objIntPoint as class     int-point no-undo.
    objIntPoint = cast (subjectObj, int-point).
    if not (objIntPoint:azk-code = ? or integer (objIntPoint:azk-code) = 0)
    then do:
      find first buf_clients where buf_clients.obj-code = integer (objIntPoint:azk-code) and buf_clients.db-num <> ? no-error.
      if error-status:error then
      do:
        undo, throw new Progress.Lang.AppError("Нет объект с кодом (azk-code) - " + objIntPoint:azk-code).
      end.
    end.
        if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run db-attr-write in ibs.th.gbl.gbl-hndllib:g#attr-lib
      (input (if not available (buf_clients) then 0 else buf_clients.db-num)
      ,input 'int-point':U
      ,input objIntPoint:code_
      ) no-error .
    if error-status:error then
    do:
      undo, throw new Progress.Lang.AppError(return-value).
    end.
    result = true.
    catch exAppErrors as class Progress.Lang.AppError :
      Msg = Msg + "; " + exAppErrors:ReturnValue .
      if Msg = "" then Msg = exAppErrors:GetMessage(1) .
      result = false.
    end catch .
    catch exProErrors as class Progress.Lang.ProError :
      Msg = exProErrors:GetMessage(1) .
      result = false.
    end catch .
    catch exAnyErrors as class Progress.Lang.Error:
      Msg = "Unexpected error occurred..." .
      result = false.
    end catch .
    finally:
      return result.
    end.
  end method.
end class.
