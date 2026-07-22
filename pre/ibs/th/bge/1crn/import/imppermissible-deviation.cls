using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
using ibs.th.gbl.*.
block-level on error undo, throw.
class ibs.th.bge.1crn.import.imppermissible-deviation implements ibs.th.bge.1crn.import.iimpsubject:
  define buffer buf_shift-param for ub.shift-param .
  define property Msg as character no-undo
    get.
    set.
  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
    define variable ri           as recid no-undo .
    define variable permissible as class permissible-deviations no-undo.
    define buffer buf_clients for ub.clients .
    find first ub.sys-ctrl no-lock.
    find first buf_clients where buf_clients.db-num = ub.sys-ctrl.db-num.
    permissible = cast (subjectObj, permissible-deviations).
    if permissible:code_ = 0 or permissible:code_ = ? then
    do:
      Msg = "Код интеграции допустимого отклонения не задано".
      return error Msg .
    end.
    if permissible:name_ = "" or permissible:name_ = ? then
    do:
      Msg = "Наименование допустимого отклонения с кодом " + string(permissible:code_) + ". Не задано название" .
      return error Msg .
    end.
      find first buf_shift-param exclusive-lock where
      buf_shift-param.obj-code = 0 and
      buf_shift-param.obj-type = "" and
      buf_shift-param.shift-date = 01.01.1900  no-error .
      if not available (buf_shift-param) then do:
        create buf_shift-param .
        assign
        buf_shift-param.obj-code = 0
        buf_shift-param.obj-type = ""
        buf_shift-param.shift-date = 01.01.1900
        .
      end.
      else do:
          find last ub.shift-obj no-lock where ub.shift-obj.obj-code = buf_clients.obj-code and
          ub.shift-obj.obj-type = buf_clients.obj-type and
          ub.shift-obj.status_ = "ТЕК" no-error .
          if available (ub.shift-obj) then do:
          find first ub.shift-param exclusive-lock where ub.shift-param.obj-code = ub.shift-obj.obj-code and
          ub.shift-param.obj-type = ub.shift-obj.obj-type and
          ub.shift-param.shift-date = ub.shift-obj.shift-date and
          ub.shift-param.shift-num = ub.shift-obj.shift-num no-error .
          if not available (ub.shift-param) then do:
              create ub.shift-param .
              assign
              ub.shift-param.obj-code = ub.shift-obj.obj-code
              ub.shift-param.obj-type = ub.shift-obj.obj-type
              ub.shift-param.shift-date = ub.shift-obj.shift-date
              ub.shift-param.shift-num = ub.shift-obj.shift-num
              ub.shift-param.shift-name = ub.shift-obj.shift-name
              ub.shift-param.dev-paid-trans = buf_shift-param.dev-paid-trans
              ub.shift-param.prc-dev-mass = buf_shift-param.prc-dev-mass
              .
          end.
          end.
      end.
      case permissible:code_:
       when 1 then buf_shift-param.prc-dev-mass = decimal(permissible:value_) .
       when 2 then buf_shift-param.dev-paid-trans = decimal(permissible:value_) .
      end.
  end method.
end class.
