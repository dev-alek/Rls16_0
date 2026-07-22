/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вывод в поток для разных типов касс - пересылка категории налогов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/15/06
Author: Bakhtadze Natalya
Creation date: 02/15/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE putc-12.
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter pos-type as char no-undo.
define input parameter p-cash-os like ub.cash-desk.cash-os no-undo .
define variable ii as integer no-undo .
define variable v-rate-code like ub.tax-rate.rate-code no-undo .
define variable v-value as decimal no-undo .
define buffer buf_tax-rate for ub.tax-rate.

CASE pos-type:
  when {&cd-type-IBM} then do:
    if cd-vat = 0 or p-cash-os = "LINUX":U then do:
      PUT stream IBMstream unformatted
      '12 "'
      if cash-txn.news-action then "D" else string( action, "x(1)" )
      '" '
      cash-txn.tax-code format "9"
      ' "'
      cash-txn.tax-name format "X(15)"
      '"'
      {&new-line}.
    end.
    else do:
      /*если нет ставки налога по этому налогу в списке cdtaxlst то игнорируем*/
      _do:
      do ii = 1 to num-entries(cdtaxlst, ";":U):
        assign
        v-rate-code = integer(entry(1, entry(ii, cdtaxlst, ";":U), "-":U))
        no-error .
        if error-status:error then do:
          message
          "Неверное значение настроечного параметра cdtaxlst" cdtaxlst
          view-as alert-box error .
          return error .
        end.
        find first buf_tax-rate no-lock where
                  buf_tax-rate.rate-code = v-rate-code no-error .
        if not available buf_tax-rate then do:
          message
          "Неверное значение настроечного параметра cdtaxlst" cdtaxlst
          view-as alert-box error .
          return error .
        end.
        if buf_tax-rate.tax-code = cash-txn.tax-code then do:
          { gbl/pftaxval.i recid(buf_tax-rate) cash-txn.tax-code buf_tax-rate.rate-code  v-today  ub.shop.host-code  {&shop} ub.shop.obj-code v-value no-error }
          if error-status:error then do:
            message
            "Неверное значение ставки налога" buf_tax-rate.rate-code {&shop}  shop.obj-code
            view-as alert-box error .
            return error .
          end.
         if v-value = ?
          and not cash-txn.news-action then do:
            run write-log-and-file in p-log-handle (
                  input 1
                , input log-file-name
                , input 1
                , input substitute( "!!!Для маг &1 ставка налога &2 НЕ ОПРЕДЕЛЕНА"
                                    ,shop.host-code
                                    ,buf_tax-rate.rate-code
                                  )
                                                  ).
            v-view-log = yes.
          end.
          else do:
            PUT stream IBMstream unformatted
            '12 "'
            if cash-txn.news-action then "D" else string( action, "x(1)" )
            '" '
            convert-tax-code(buf_tax-rate.rate-code, cdtaxlst)  format "9"
            ' "'
            (substring(cash-txn.tax-name, 1, 8) + {&space-char} + string((if v-value = ? then 0 else v-value) , ">9.99%":U)) format "X(15)"
            '"'
            {&new-line}.
          end.
        end.
      end.
    end.
  end.
  when {&cd-type-magia-XML} then do:
    run bgelib-tag-open in this-procedure ( input 2, input "Tax"
                                          , input substitute("ctrl='&1' tms='&2' code='&3'",
                                           (if cash-txn.news-action
                                            then "DEL"
                                            else (if action = "U":U
                                                  then "ADD":U
                                                  else "DEL":U)
                                            )
                                           ,OS2-time, cash-txn.tax-code)).
    run bgelib-tag-put in this-procedure ( input 3, input "TaxCatName"
                                          , input trim(cash-txn.tax-name, {&space-char}), input 1 ).
  end.
  when {&cd-type-IBM-XML} then do:
    run bgelib-tag-open in this-procedure ( input 2, input "Tax"
                                          , input substitute("ctrl='&1' tms='&2' code='&3'",
                                           (if cash-txn.news-action
                                            then "DEL"
                                            else (IF action = "U":U
                                                  then "ADD":U
                                                  else "DEL":U)
                                           )
                                          ,OS2-time, if cash-txn.tax-code eq ? then "*" else string(cash-txn.tax-code))).
    run bgelib-tag-put in this-procedure ( input 3, input "TaxCatName"
                                          , input trim(cash-txn.tax-name, {&space-char}), input 1 ).
  end.
END CASE .
FOR EACH cash-txr
where cash-txr.tax-code = cash-txn.tax-code
BY cash-txr.host-code
BY cash-txr.obj-type
BY cash-txr.obj-code:
  /*блок проверки ставки*/
  if cash-txr.host-code = 0 OR
      cash-txr.host-code = shop-buffer.host-code or
      (cash-txr.obj-type = {&shop} AND
      cash-txr.obj-code = i-obj-code) then do:
    /*надо еще проверить что текущая на обекъте или фирме*/
    if g#news then do:
      run cur-time in this-procedure ( output v-today, output v-time ).
        /*проверим надо ли изменять/удалять фирменную или глобальную - вдруг есть действующая ставка более низкого уровня*/
      { gbl/pftaxvlx.i ? cash-txr.tax-code cash-txr.rate-code  v-today  shop-buffer.host-code  {&shop} i-obj-code x-host-code x-obj-type x-obj-code no-error }
      if error-status:error then next.
      if x-obj-code > cash-txr.obj-code OR
          x-host-code > cash-txr.host-code then NEXT.
      /*находим действующее значение по ставке и пересылаем его в моде U даже если нам пришла команда на удаление - new-action = yes*/
      if not cash-txr.news-action then do:
        { gbl/pftaxval.i ? cash-txr.tax-code cash-txr.rate-code  v-today  shop-buffer.host-code  {&shop} i-obj-code cash-txr.rate-value no-error }
        if error-status:error then do:
          /*может удалили последнюю - тогда стоит удалить и на кассе*/
          assign
          cash-txr.news-action = yes
          .
        end.
      end.
      else do:
        assign
        cash-txr.rate-value = 0
        .
      end.
    end.
  end.
  RUN putc-13( buffer buf_cash-desk
             , input pos-type
             , input p-cash-os
             , input no /*p-call-from-goods*/
             ).
end. /*for each cash-txr*/
CASE pos-type:
  when {&cd-type-MAGIA-XML} then do:
    run bgelib-tag-close in this-procedure ( input 2, input "Tax").
  end.
  when {&cd-type-IBM-XML} then do:
    run bgelib-tag-close in this-procedure ( input 2, input "Tax").
  end.
END CASE.
END PROCEDURE .

/* $Workfile$ e n d */