using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
USING ibs.th.gbl.*.
block-level on error undo, throw.
class ibs.th.bge.1crn.import.imposnovcorr implements ibs.th.bge.1crn.import.iimpsubject:
  define buffer buf_code for ub.code .
  define variable v-code as character no-undo .
  define property Msg as character no-undo
    get.
    set.
  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
    define variable ri           as recid no-undo .
    define variable objOsnovCorr as class osnovcorr no-undo.
    objOsnovCorr = cast (subjectObj, osnovcorr).
    if objOsnovCorr:code_ = 0 or objOsnovCorr:code_ = ? then
    do:
      Msg = "Основание коррекции не задано".
      return error.
    end.
    if objOsnovCorr:osn_name = "" or objOsnovCorr:osn_name = ? then
    do:
      Msg = "Основание коррекции " + string(objOsnovCorr:code_) + " . Не задана" .
      return error Msg.
    end.
        find first buf_code no-lock
      where buf_code.code = "OsnovCorr" no-error .
    if not available buf_code
      then
    do:
      create buf_code .
      assign
        buf_code.code     = "OsnovCorr"
        buf_code.codename = "Основание коррекции".
      buf_code.procview   = "ibs\th\ref\code\corrsys.p".
      .
    end.
    if objOsnovCorr:del-f = 0 then
    do:
      find first buf_code exclusive-lock where buf_code.parent = "OsnovCorr"
        and buf_code.code = string(objOsnovCorr:code_) no-error .
      if not available (buf_code) then
      do:
        create buf_code .
        assign
          buf_code.parent = "OsnovCorr"
          buf_code.code   = string(objOsnovCorr:code_)
          .
      end.
      assign
        buf_code.CodeName  = objOsnovCorr:osn_name
        buf_code.status_   = objOsnovCorr:del-l
        .
    end.
    else
    do:
      find first buf_code exclusive-lock where buf_code.parent = "OsnovCorr"
        and buf_code.code = string(objOsnovCorr:code_) no-error .
      if not available (buf_code) then
      do:
        Msg = "Удаление основания коррекции с кодом " + string(objOsnovCorr:code_) + ". Не возможно" .
        return error Msg.
      end.
      else
        delete buf_code .
    end.
  end method.
end class.
