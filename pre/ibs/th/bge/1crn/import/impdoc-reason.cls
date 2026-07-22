using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
using ibs.th.gbl.*.
block-level on error undo, throw.
class ibs.th.bge.1crn.import.impdoc-reason implements ibs.th.bge.1crn.import.iimpsubject:
  define buffer buf_trn-reason for ub.trn-reason .
  define property Msg as character no-undo
    get.
    set.
  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
    define variable ri           as recid no-undo .
    define variable objDoc-reason as class doc-reason no-undo.
    objDoc-reason = cast (subjectObj, doc-reason).
    if objDoc-reason:code_ = "" or objDoc-reason:code_ = ? then
    do:
      Msg = "ќснование/причина создани€ документа не задано".
      return error Msg .
    end.
    if objDoc-reason:name_ = "" or objDoc-reason:name_ = ? then
    do:
      Msg = "ќснование/причина создани€ документа с кодом " + objDoc-reason:code_ + ". Ќе задано название" .
      return error Msg .
    end.
    if objDoc-reason:del-f = 0
    then do:
      find first buf_trn-reason exclusive-lock where buf_trn-reason.reason-code = integer(objDoc-reason:code_) no-error .
      if not available buf_trn-reason
      then do :
        create buf_trn-reason .
        assign buf_trn-reason.reason-code = integer(objDoc-reason:code_) .
      end .
      assign
        buf_trn-reason.reason-name = objDoc-reason:name_
        buf_trn-reason.PS = if objDoc-reason:description_ <> ? then objDoc-reason:description_ else ""
      .
    end.
    else do:
      find first buf_trn-reason exclusive-lock where buf_trn-reason.reason-code = integer(objDoc-reason:code_) no-error .
      if not available buf_trn-reason
      then do :
        Msg = "”даление основани€/причины создани€ документа с кодом " + objDoc-reason:code_ + " не возможно" .
        return error Msg.
      end.
      else
        delete buf_trn-reason
      .
    end.
  end method.
end class.
