/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Опеределения функций для запросо в интерефейсе продажи

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/25/06
Author: Bakhtadze Natalya
Creation date: 04/25/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

function get-OK returns CHARACTER (input p-is-tpsi-obj as logical
                                ,input p-artic   as character
                                ,input p-prod-type as character
                                ,input p-prod-code  as integer
                                ,input p-prt-code   as integer
                                ,input p-doc-qnty as decimal
                                ,input p-fact-qnty as decimal
                                ):
define buffer buf_tt0-gds-dtl for tt0-gds-dtl.
CASE p-is-tpsi-obj:
when yes then do:
  find first buf_tt0-gds-dtl no-lock where
            buf_tt0-gds-dtl.artic     = p-artic
        AND buf_tt0-gds-dtl.prod-type = p-prod-type
        AND buf_tt0-gds-dtl.prod-code = p-prod-code
        AND buf_tt0-gds-dtl.prt-code = p-prt-code no-error .
  if p-fact-qnty = p-doc-qnty
  or (available buf_tt0-gds-dtl and (buf_tt0-gds-dtl.doc-qnty + p-doc-qnty) = p-fact-qnty)
  then do:
    return "++":U.
  end.
  if available buf_tt0-gds-dtl   then do:
    return "+-":U.
  end.
  else do:
    return "--":U.
  end.
end.
when no then do:
  if p-fact-qnty = p-doc-qnty then do:
    return "+":U.
  end.
  else return "-":U.
end.
END CASE.
END FUNCTION.

function get-name returns CHARACTER (
                                      input p-node-name as character
                                     ,input p-upper-code as integer
                                     ,input p-prt-root as integer
                                     ,input p-gds-name as character ) :
define variable v-name as character no-undo .
assign
v-name  =  if p-node-name <> {&empty-scale}
           and p-upper-code <> p-prt-root
           then (p-gds-name + " - " + p-node-name)
           else p-gds-name
no-error
.
return v-name.
END FUNCTION.

function get-prt-name returns character ( input p-node-name as character
                                          ,input p-upper-code as integer
                                          ,input p-prt-root as integer
                                          ,input p-f-name as character  ):
define variable v-name as character no-undo .
assign
v-name = if p-node-name = {&empty-scale}
         then "-"
         else (if p-upper-code = p-prt-root
               then "-------------------"
               else p-f-name).
return v-name.
END FUNCTION.

FUNCTION get-pcnt returns decimal ( input p-price-base as decimal
                                   ,input p-price-rubl as decimal
                                   ,input p-discnt-base as decimal
                                   ,input p-discnt-rubl as decimal ) :
define variable v-pcnt as decimal no-undo .
assign
v-pcnt = (if v-curr-r-b = {&r-b-base}
         then (p-discnt-base / p-price-base * 100)
         else (p-discnt-rubl / p-price-rubl * 100 ))
.
return v-pcnt.
END FUNCTION.


/* $Workfile$ e n d */