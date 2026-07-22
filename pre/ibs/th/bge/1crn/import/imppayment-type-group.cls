using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
block-level on error undo, throw.
class ibs.th.bge.1crn.import.imppayment-type-group implements ibs.th.bge.1crn.import.iimpsubject:
  define property Msg as character no-undo
    get.
    set.
  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
    def var v-rec  as recid     no-undo .
    def var v-mode as character no-undo .
    define variable objPaymentTypeGroup as class payment-type-group no-undo.
    objPaymentTypeGroup = cast (subjectObj, payment-type-group).
                if objPaymentTypeGroup:del-f = 1 then do:
                  Msg = "Физическое удаление в базе не реализовано".
                end.
                else do:
      find first ub.pay-type where ub.pay-type.obj-code = integer(objPaymentTypeGroup:code_) no-error .
      if AVAILABLE ub.pay-type then do:
        assign
          v-mode = 'ИЗМЕНЕНИЕ':U
          v-rec = recid (ub.pay-type)
          .
      end.
      else do:
        assign
          v-mode = 'ДОБАВЛЕНИЕ':U
          v-rec = ?
        .
      end.
   run ref/paytype1.p
     ( input-output v-rec
     , input v-mode
     , input yes
     , input objPaymentTypeGroup:code_
     , input objPaymentTypeGroup:name_
     ) no-error.
        if error-status:error then do:
          Msg = return-value.
          return false.
        end.
                return true.
    end.
        end method.
end class.
