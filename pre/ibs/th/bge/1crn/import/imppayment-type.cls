using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
USING ibs.th.ref.cpattr FROM PROPATH.
USING ibs.th.gbl.getcntxt FROM PROPATH.
block-level on error undo, throw.
class ibs.th.bge.1crn.import.imppayment-type implements ibs.th.bge.1crn.import.iimpsubject:
  define variable cpattr   as class cpattr   no-undo .
  define variable getcntxt as class getcntxt no-undo .
  define property Msg as character no-undo
    get.
    set.
  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
    define var v-rec         as recid         no-undo .
    define var parparentproc as widget-handle no-undo .
    define var v-delete      as logical       no-undo .
    define var v-dop-doc     as character     no-undo .
    define var v-name        as character     no-undo .
    define var v-ptg-code    as integer       no-undo .
    define var v-mode        as character     no-undo .
    define var v-status      as character     no-undo .
    define var v-is-cash     as LOGICAL       no-undo .
    define var v-atr1        as LOGICAL       no-undo .
    define var v-has-return  as integer       no-undo .
    define var v-can-mix     as integer       no-undo .
    define buffer buf_cash-pay-attr for ub.cash-pay-attr .
    define variable objPaymentType as class payment-type no-undo.
    cpattr = new cpattr ().
    objPaymentType = cast (subjectObj, payment-type).
    if objPaymentType:del-f = 1 then
    do:
      find first ub.cash-pay EXCLUSIVE-LOCK where ub.cash-pay.cdpay-code = integer(objPaymentType:code_) no-error .
      if AVAILABLE ub.cash-pay then
      do:
        for each ub.cash-pay-attr EXCLUSIVE-LOCK where ub.cash-pay-attr.cdpay-code = ub.cash-pay.cdpay-code
          and ub.cash-pay-attr.curr-code = ub.cash-pay.curr-code:
          CpAttr:CpAttrDelete(ub.cash-pay-attr.cdpay-code,
            ub.cash-pay-attr.curr-code,
            ub.cash-pay-attr.host-code,
            ub.cash-pay-attr.obj-type,
            ub.cash-pay-attr.obj-code,
            ub.cash-pay-attr.attr-code,
            output v-delete
            ).
        end.
        delete ub.cash-pay .
      end.
    end.
    else
    do:
      find first ub.cash-pay EXCLUSIVE-LOCK where ub.cash-pay.cdpay-code = integer(objPaymentType:code_) no-error .
      if AVAILABLE ub.cash-pay then
      do:
        assign
          v-rec  = recid(ub.cash-pay)
          v-mode = '»«Ã≈Õ≈Õ»≈':U
          .
      end.
      else
      do:
        ASSIGN
          v-rec  = ?
          v-mode = 'ƒŒ¡¿¬À≈Õ»≈':U
          .
      end.
      find first ub.currency no-lock where ub.currency.okv-code = INTEGER (objPaymentType:curr-code) no-error .
      if not AVAILABLE (ub.currency) then
      do:
        Msg = "ÕÂÚ ‚‡Î˛Ú˚ Ò ÍÓ‰ÓÏ" + objPaymentType:curr-code.
        return false.
      end.
      if integer(objPaymentType:code_) = 1 then
      do:
        assign
          v-is-cash    = yes
          v-atr1       = yes
          v-has-return = 1
          v-can-mix    = 1
          .
      end.
      if AVAILABLE ub.cash-pay then
      do:
        assign
          v-is-cash    = ub.cash-pay.is-cash
          v-atr1       = ub.cash-pay.atr1
          v-has-return = ub.cash-pay.has-return
          v-can-mix    = ub.cash-pay.can-mix
          .
      end.
      run ref/cashpay1.p (
        input ?
        ,input yes
        ,input-output v-rec
        ,input v-mode
        ,input if AVAILABLE ub.cash-pay then ub.cash-pay.cdpay-code else integer(objPaymentType:code_)
        ,input objPaymentType:name_
        ,input ub.currency.curr-code
        ,input integer(objPaymentType:ptg-code)
        ,input 0
        ,input 0
        ,input v-is-cash
        ,input v-atr1
        ,input if AVAILABLE ub.cash-pay then ub.cash-pay.atr2 else no
        ,input if AVAILABLE ub.cash-pay then ub.cash-pay.atr4 else no
        ,input if AVAILABLE ub.cash-pay then ub.cash-pay.atr8 else no
        ,input if AVAILABLE ub.cash-pay then ub.cash-pay.atr16 else no
        ,input if AVAILABLE ub.cash-pay then ub.cash-pay.atr32 else no
        ,input if AVAILABLE ub.cash-pay then ub.cash-pay.atr64 else no
        ,input if AVAILABLE ub.cash-pay then ub.cash-pay.atr128 else no
        ,input if AVAILABLE ub.cash-pay then ub.cash-pay.pay-card-view else ""
        ,input if AVAILABLE ub.cash-pay then ub.cash-pay.is-advance else no
        ,input if AVAILABLE ub.cash-pay then ub.cash-pay.is-credit else no
        ,input if AVAILABLE ub.cash-pay then ub.cash-pay.is-credit-card else no
        ,input if AVAILABLE ub.cash-pay then ub.cash-pay.is-debet-card else no
        ,input if AVAILABLE ub.cash-pay then ub.cash-pay.is-all-pay else no
        ,input if AVAILABLE ub.cash-pay then ub.cash-pay.is-bar-read else no
        ,input if AVAILABLE ub.cash-pay then ub.cash-pay.is-card-swap else no
        ,input if AVAILABLE ub.cash-pay then ub.cash-pay.is-goods-pay else no
        ,input if AVAILABLE ub.cash-pay then ub.cash-pay.is-service-pay else no
        ,input if AVAILABLE ub.cash-pay then ub.cash-pay.is-kbo else 0
        ,input if AVAILABLE ub.cash-pay then ub.cash-pay.is-lnr else 0
        ,input v-can-mix
        ,input v-has-return
        ,input if AVAILABLE ub.cash-pay then ub.cash-pay.has-overpay else 0
        ,input if AVAILABLE ub.cash-pay then ub.cash-pay.rule-file-name else ""
        ,input if AVAILABLE ub.cash-pay then ub.cash-pay.slip-file-name else ""
        ,input if AVAILABLE ub.cash-pay then ub.cash-pay.register else 0
        ) no-error .
      if error-status:error then
      do:
        Msg = return-value.
        return false.
      end.
      find first ub.cash-pay EXCLUSIVE-LOCK where ub.cash-pay.cdpay-code = integer(objPaymentType:code_) no-error .
      if AVAILABLE ub.cash-pay then
      do:
        assign
          ub.cash-pay.status_ = if objPaymentType:del-l = 1 then 'Û‰‡Î':U else 'ÚÂÍ':U .
        .
      end.
      find first buf_cash-pay-attr EXCLUSIVE-LOCK where buf_cash-pay-attr.cdpay-code = ub.cash-pay.cdpay-code
        and buf_cash-pay-attr.curr-code = ub.cash-pay.curr-code
        and buf_cash-pay-attr.attr-code = "cash-prop" no-error .
      if not AVAILABLE buf_cash-pay-attr then
      do:
        create buf_cash-pay-attr .
        assign
          buf_cash-pay-attr.cdpay-code = ub.cash-pay.cdpay-code
          buf_cash-pay-attr.curr-code  = ub.cash-pay.curr-code
          buf_cash-pay-attr.attr-code  = "cash-prop"
          .
      end.
      case objPaymentType:pay-type_:
        when 0 then
          do:
            buf_cash-pay-attr.attr-value = "0" .
          end.
        when 1 then
          do:
            buf_cash-pay-attr.attr-value = "1" .
          end.
        when 2 then
          do:
            buf_cash-pay-attr.attr-value = "2" .
          end.
        when 3 then
          do:
            buf_cash-pay-attr.attr-value = "4" .
          end.
        when 4 then
          do:
            buf_cash-pay-attr.attr-value = "5" .
          end.
        when 5 then
          do:
            buf_cash-pay-attr.attr-value = "13" .
          end.
        when 6 then
          do:
            buf_cash-pay-attr.attr-value = "6" .
          end.
        when 7 then
          do:
            buf_cash-pay-attr.attr-value = "7" .
          end.
      end case.
      if objPaymentType:pay-type_ <> 0 and objPaymentType:pay-type_ <> 1 and objPaymentType:pay-type_ <> 2
        and objPaymentType:pay-type_ <> 3 and objPaymentType:pay-type_ <> 4 and objPaymentType:pay-type_ <> 5
        and objPaymentType:pay-type_ <> 6 and objPaymentType:pay-type_ <> 7 then
      do:
        buf_cash-pay-attr.attr-value = "0" .
      end.
      return true.
    end.
  end method.
  method public logical CashPayAttr ():
  end METHOD .
end class.
