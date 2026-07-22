 /*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура отслыки справочника оснований чеков коррекций

Автор: Шкляр Елена
Дата создания: 02/14/14
Author: Elena Shklyar
Creation date: 02/14/14

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
{ cmp/str-glbl.i  }

procedure putc-kkt :
define input parameter p-pos-type like ub.cash-desk.pos-type no-undo .
define input parameter p-version like ub.cash-desk.version no-undo .
define input parameter p-cash-os like ub.cash-desk.cash-os no-undo .
define input parameter p-cash-num like ub.cash-desk.cash-num  no-undo .
define input parameter p-value   as character no-undo .
define input parameter p-is-del as logical no-undo .

define variable ii as integer no-undo.

  do
  on error undo, return error
  :
        run bgelib-tag-open in this-procedure ( input 2, input "Param", input substitute("ctrl='&2' group='&1' key='&3'", "OFD":u, "ADD":u, "KKT_SCHEMA":u)).
          run bgelib-tag-put in this-procedure ( input 3, input "ParamValue", input p-value, input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "ParamDesc", input "Схема интеграции ККТ. 0-с ожиданием ответа; 1-без ожидания ответа", input 1 ).
        run bgelib-tag-close in this-procedure ( input 2, input "Param").    
  end.

end procedure. /* putc-par */

/* $Workfile$ e n d */