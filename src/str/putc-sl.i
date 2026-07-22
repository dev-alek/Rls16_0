/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

вывод в поток для разных типов касс - пересылка стоплистов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/06/07
Author: Bakhtadze Natalya
Creation date: 07/06/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE putc-sl.
define input parameter pos-type   as character no-undo.
define input parameter p-version  as character no-undo .
define input parameter p-full-stop-list-code as character no-undo .

define variable v-version-dec as decimal no-undo .
define variable v-ii as integer no-undo .
define buffer buf_stop-list-line for ub.stop-list-line.


CASE pos-type:
  when {&cd-type-ibm-xml}  then do:
    assign
    v-version-dec = decimal(p-version) no-error .
    if v-version-dec >= 1.07 then do:
      run bgelib-tag-open in this-procedure ( input 2, input "StopList"
                                            , input substitute("ctrl='&1' tms='&2' code='&3'"
                                                              ,'ADD':U
                                                              , OS2-time
                                                              , p-stop-list-code
                                                              )).
    for each buf_stop-list-line no-lock where
            buf_stop-list-line.classif-type =  {&table_dis-card}
        and buf_stop-list-line.stop-list-code =  p-full-stop-list-code
            :
        if buf_stop-list-line.key#_one = integer({&delete-card}) then next.
        run bgelib-tag-open in this-procedure ( input 3
                                              , input "StopNum"
                                              , input '':U      ).


        run bgelib-tag-put in this-procedure ( input 4, input "SNN"             , input buf_stop-list-line.charkey_one, input 0 ).
        run bgelib-tag-put in this-procedure ( input 4, input "SNMes"             , input buf_stop-list-line.line-message, input 0 ).
        run bgelib-tag-close in this-procedure ( input 3, input "StopNum").
    end.
    run bgelib-tag-close in this-procedure ( input 2, input "StopList").
    if integer(p-stop-list-code) > 1 then do:
      do v-ii = max((integer(p-stop-list-code) - 100), 1) to (integer(p-stop-list-code) - 1):
        run bgelib-tag-open in this-procedure ( input 2, input "StopList"
                                                , input substitute("ctrl='&1' tms='&2' code='&3'"
                                                                  ,'DEL':U
                                                                  , OS2-time
                                                                  , v-ii
                                                                  )).
        run bgelib-tag-close in this-procedure ( input 2, input "StopList").
      end.
    end.

   end.
  end.
END CASE .
END PROCEDURE .


/* $Workfile$ e n d */