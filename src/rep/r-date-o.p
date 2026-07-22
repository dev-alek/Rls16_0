block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-date-o.p $
$Archive: rep/r-date-o.p $

Отчет о датах на объектах

Автор: Демин Алексей Сергеевич
Дата создания: 03/27/06
Author: Alexey Demin
Creation date: 03/27/06

*/

define Stream OutStream.

do
on error undo, return error
:
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-date-o.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-date-o.p $":U .
define variable vss-description as character no-undo init "Отчет о датах на объектах".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ cmp/r-pril.i   }
{ rep/r-sym.i    }

DEFINE VARIABLE parParentProc     AS WIDGET-HANDLE NO-UNDO.
ASSIGN parParentProc =  my-handle .

  define variable g#report-num as integer   no-undo .
  run get-report-num  in parParentProc ( output g#report-num ).

  define buffer buf_shift-obj  for shift-obj .
  define buffer buf_clients    for clients .

  define variable Counter1 as integer initial 0   no-undo .
  define variable Line     as character no-undo .
  define variable name     as character no-undo .
  define variable dat      as date      no-undo .
  define variable dat1     as date      no-undo .
  define variable num      as character no-undo .

  { rep/repfrm.i def } /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 1 } /* Показать окно информации о текущем процессе */

  { gbl/working.i }

  Line = fill("-", 250).

  DEFINE frame f-doc
      sym1 at 8  name     column-label " Объект "       format "X(59)"        space(0)
      sym2  num           column-label "Номер!смены"    format "X(6)"         space(0)
      sym3  dat           column-label "  Дата! смены"  format "99.99.9999"   space(0)
      sym4  dat1          column-label "  Дата!объекта" format "99.99.9999"   space(0)
      sym5
    HEADER
      string( "Дата печати : " + string(TODAY , "99.99.9999") + " , " + string(TIME, "HH:MM") ) AT 10 format "X(60)"
      string( "Страница " + string( PAGE-NUMBER( OutStream )  , ">>9") ) AT 80 format "X(15)" SKIP
      Line at 8 format "X(94)"
  with width {&A4_CW} down stream-io.

  { cmp/open-out.i stream OutStream " " {&PT_PS_A4} }

  FORM HEADER
      "       " Line format "X(94)" AT 1 SKIP
      "Продолжение - на следующей странице" AT 30 SKIP
      with FRAME BottomFrame width {&A4_CW} PAGE-BOTTOM NO-LABELS NO-BOX .
  VIEW stream OutStream FRAME BottomFrame .

  FORM with FRAME f-doc .

  PUT stream OutStream SPACE(30) "Отчет о текущих датах на объектах. " format "X(45)"  SKIP .

  for each obj-list :
    assign Counter1 = Counter1 + 1.
    { rep/repfrm.i disp Counter1 }

    find first buf_clients no-lock
      where buf_clients.obj-type  = obj-list.obj-type
        and buf_clients.obj-code  = obj-list.obj-code
    no-error .
    assign name = buf_clients.obj-name + " (" + buf_clients.obj-type + '#' + string(buf_clients.obj-code) + ")"  .

    find first buf_shift-obj no-lock
      where buf_shift-obj.obj-type  = obj-list.obj-type
        and buf_shift-obj.obj-code  = obj-list.obj-code
        and buf_shift-obj.status_   = {&sht-current}
    no-error .
    if available buf_shift-obj then
      assign
        dat = buf_shift-obj.shift-date
        num = (if buf_shift-obj.shift-name = string (buf_shift-obj.shift-num) then buf_shift-obj.shift-name else buf_shift-obj.shift-name + "(" + string(buf_shift-obj.shift-name) + ")")
      .
    else
      assign
        dat = ?
        num = ""
      .
    { gbl/objdtget.i obj-list.obj-type obj-list.obj-code dat1 }

    display stream outstream  sym1 at 8 name sym2  num  sym3 dat sym4 dat1 sym5  with frame f-doc.
    down stream outstream with frame f-doc .
  end.

  PUT STREAM OutStream  Line at 8 format "X(94)"  .

  HIDE stream OutStream FRAME BottomFrame .
  OUTPUT stream OutStream CLOSE.

  { rep/repfrm.i off } /* Показать окно информации о текущем процессе */
  { gbl/stopwork.i }

  define variable v-user-action as character no-undo .
  define variable v-printed as logical   no-undo .
  run gbl/prnfilen.w
    (input  ""
    ,input  0
    ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
    ,input  7
    ,output v-user-action
    ,output v-printed
    ) .
end.