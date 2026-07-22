/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

вывод в поток для разных типов касс - пересылка ставок налогов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/15/06
Author: Bakhtadze Natalya
Creation date: 02/15/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE putc-13.
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter pos-type as char no-undo.
define input parameter p-cash-os like ub.cash-desk.cash-os no-undo .
define input parameter p-call-from-goods as logical no-undo .
define variable ii as integer no-undo .
define variable v-rate-code like ub.tax-rate.rate-code no-undo .
define variable v-envd as LOGICAL no-undo .
define variable v-plu as integer no-undo .
define buffer buf_tax-rate for ub.tax-rate.
define buffer buf_tax-rate-attr for ub.tax-rate-attr.

if cash-txr.rate-value = ?
and not (cash-txr.news-action OR cash-txr.status_ <> {&current-status})
then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!Для маг &1 ставка налога &2 НЕ ОПРЕДЕЛЕНА"
                            ,buf_cash-desk.obj-code
                            ,cash-txr.rate-code
                          )
                                          ).
    v-view-log = yes.
    return '':U .
end.
CASE pos-type:
  when {&cd-type-IBM} then do:
   if cd-vat = 0 or p-cash-os = "LINUX":U then do:
      PUT stream IBMstream unformatted
      '13 "'
      if cash-txr.news-action OR cash-txr.status_ <> {&current-status}
      then "D"
      else string( action, "x(1)" )
      '" '
      cash-txr.tax-code format "9"
      ' '
      cash-txr.rate-code
      ' '
      (if cash-txr.tax-type = {&percentive} then 2 else 1) format "9"
      (if cash-txr.rate-value = ?
        then 0
        else cash-txr.rate-value) format ">>>>>>>>>9.99"
      {&new-line}.
    end.
    else do:
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
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute( "!!!Для маг &1 ставка налога &2 не входит в число действующих на кассе &2"
                                  ,buf_cash-desk.obj-code
                                  ,v-rate-code
                                  ,buf_Cash-desk.pos-type
                                )
                                                ).
          v-view-log = yes.
          return error .
        end.
        if buf_tax-rate.rate-code = cash-txr.rate-code then do:
          PUT stream IBMstream unformatted
          '13 "'
          if cash-txr.news-action OR cash-txr.status_ <> {&current-status}
          then "D"
          else string( action, "x(1)" )
          '" '
          convert-tax-code(buf_tax-rate.rate-code, cdtaxlst)  format "9"
          ' '
          cash-txr.rate-code
          ' '
          (if cash-txr.tax-type = {&percentive} then 2 else 1) format "9"
          (if cash-txr.rate-value = ?
          then 0
          else cash-txr.rate-value) format ">>>>>>>>>9.99"
          {&new-line}.
        end.
      end.
    end.
  end.
  when {&cd-type-IBM-XML} then do:
      find first buf_tax-rate-attr where buf_tax-rate-attr.rate-code = cash-txr.rate-code
                                     and buf_tax-rate-attr.tax-code = cash-txr.tax-code
                                     and buf_tax-rate-attr.attr-code = "envd" no-error .
       if AVAILABLE buf_tax-rate-attr then do:
           v-envd = yes .
       end.
       else v-envd = no .                                           
    run bgelib-tag-open in this-procedure ( input 3, input "TaxCodes"
                                          , input "":U).
    run bgelib-tag-put in this-procedure ( input 4, input "TCCode"
                                          , input string(cash-txr.rate-code), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "TCType"
                                          , input string((if cash-txr.tax-type = {&percentive} then 2 else 1)), input 1 ).
    if v-envd then do:
    run bgelib-tag-put in this-procedure ( input 4, input "TCValue"
                                          , input string(-1), input 1 ).    
    end.    
    else do:
    run bgelib-tag-put in this-procedure ( input 4, input "TCValue"
                                          , input string(if cash-txr.rate-value = ?
                                                         then 0
                                                         else cash-txr.rate-value), input 1 ).
    end.                                                     
    run bgelib-tag-put in this-procedure ( input 4, input "TCInclude"
                                          , input string(1), input 1 ).
    run bgelib-tag-close in this-procedure ( input 3, input "TaxCodes").
  end.
  when {&cd-type-MAGIA-XML} then do:
    run bgelib-tag-open in this-procedure ( input 3, input "TaxCodes"
                                          , input "":U).
    run bgelib-tag-put in this-procedure ( input 4, input "TCCode"
                                          , input string(cash-txr.rate-code), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "TCType"
                                          , input string((if cash-txr.tax-type = {&percentive} then 2 else 1)), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "TCValue"
                                          , input string(if cash-txr.rate-value = ?
                                                         then 0
                                                         else cash-txr.rate-value), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "TCInclude"
                                          , input string(1), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "TCLock"
                                          , input string(if cash-txr.news-action
                                                         OR cash-txr.status_ <> {&current-status}
                                                         then 1
                                                         else 0), input 1 ).

    run bgelib-tag-close in this-procedure ( input 3, input "TaxCodes").
  end.
  when {&cd-type-maria} then do:
    /* на текущий момент не передаются*/
    /*
    if p-call-from-goods then.
    else do:
      v-plu = convert-maria-tax-code-2(cash-txr.rate-code, cdtaxlst).
      if v-plu = 0 then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute( "!!!Для маг &1 ставка налога &2 не входит в число действующих на кассе &2"
                                ,buf_cash-desk.obj-code
                                ,cash-txr.rate-code
                                ,buf_cash-desk.pos-type
                              )
                                              ).
       v-view-log = yes.
      end.
      else do:
        run maria-put in this-procedure (
                                        buffer buf_cash-desk
                                      , input out
                                      , input fname
                                      , input yes
                                      , input 0
                                      , input no
                                      , input {&tekka-obj-taxation}
                                      , input 8
                                      , input v-plu
                                      , input  if cash-txr.news-action OR cash-txr.status_ <> {&current-status}
                                               then ('000' + {&delim-par} +
                                                     '000' + {&delim-par} +
                                                     '0000' + {&delim-par} +
                                                     '000000000000')
                                               else
                                               ('000' + {&delim-par} + /*вложенный налог*/
                                               '000' + {&delim-par} + /*не исп*/
                                               string(cash-txr.rate-value * 100, '9999') + {&delim-par} + /*ставка*/
                                               '000000000000' /*не исп*/
                                               )).
      end.
    end.
    */
  end.
END CASE .
END PROCEDURE .

/* $Workfile$ e n d */