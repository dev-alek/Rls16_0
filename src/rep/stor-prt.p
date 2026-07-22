block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: stor-prt.p $
$Archive: rep/stor-prt.p $

Печать списка складов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: stor-prt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/stor-prt.p $":U .
define variable vss-description as character no-undo init "Печать списка складов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i   }
{ gbl/prn-lib.i }
{ gbl/waitfram.i }




define variable Line as char no-undo.

define variable sym1 as char init ":!:"   no-undo.
define variable sym2 as char init ":!:"   no-undo.
define variable sym3 as char init ":!:"   no-undo.
define variable sym4 as char init ":!:"   no-undo.
define variable sym5 as char init ":!:"   no-undo.
define variable sym6 as char init ":!:"   no-undo.
define variable sym7 as char init ":!:"   no-undo.
define variable sym8 as char init ":!:"   no-undo.

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&CS_PS}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).
{ rep/sh-st-pr.i ub.store }

OUTPUT STREAM PrnLibStream CLOSE.

run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).