 /*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура отслыки справочника оснований чеков коррекций

Автор: Морозов Александр Сергеевич
Дата создания: 02/14/14
Author: Alexandr Morozov
Creation date: 02/14/14

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
{ cmp/str-glbl.i  }

procedure putc-corr :
define input parameter p-pos-type like ub.cash-desk.pos-type no-undo .
define input parameter p-version like ub.cash-desk.version no-undo .
define input parameter p-cash-os like ub.cash-desk.cash-os no-undo .
define input parameter p-cash-num like ub.cash-desk.cash-num  no-undo .
define input parameter p-is-del as logical no-undo .

define buffer buf_code for ub.code.

define variable ii as integer no-undo.

  do
  on error undo, return error
  :

    if p-is-del then do:
      for each buf_code where buf_code.parent = "OsnovCorr" and buf_code.status_ = 0 :
        ii = ii + 1.
        run bgelib-tag-open in this-procedure ( input 2, input "CorrectionReason", input substitute("ctrl='&2' code='&1'", string (ii), "ADD":u)).
          run bgelib-tag-put in this-procedure ( input 3, input "CorrectionReasonName", input string(buf_code.CodeName), input 1 ).
        run bgelib-tag-close in this-procedure ( input 2, input "CorrectionReason").    
  
      end.
      ii = 0 .
    end.
    else do:
      run bgelib-tag-open in this-procedure ( input 2, input "CorrectionReason", input substitute("ctrl='&2' code='&1'", "*", "DEL":u)).
      run bgelib-tag-close in this-procedure ( input 2, input "CorrectionReason").
    end.
  end.

end procedure. /* putc-par */

/* $Workfile$ e n d */