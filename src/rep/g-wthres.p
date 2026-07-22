block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-wthres.p $
$Archive: rep/g-wthres.p $

Остатки материальных ценностей (старт)

Автор: Белоусов Илья Александрович
Дата создания: 05/07/08
Author: Ilia Belousov
Creation date: 05/07/08

Input:

Output:

*/
define input  parameter       parparentproc      as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-wthres.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-wthres.p $":U .
define variable vss-description as character no-undo init "Остатки материальных ценностей (старт)".

define variable v-obj-shift     as logical   no-undo .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i  def }
{ gbl/getcntxt.i  get }

do
on error undo, return error
:
   { gbl/objat.i
         v-cntxt-obj-type
         v-cntxt-obj-code
         "'shift-on=request'"
         v-obj-shift
         no-error
   }
   if error-status :error
   then do:
      message
         vss-workfile vss-revision vss-description skip
         "Ошибка при запуске процедуры objat" skip
         error-status :get-message(1) skip
         return-value skip
         view-as alert-box error .
      return.
   end.
IF v-obj-shift
THEN DO:
    run rep/d-report.w ( input parparentproc
                       , input "rep/e-wthres.w":U
                       , input "Остатки материальных ценностей":U
                       , input 7
                       , input "":U
                       , input "":U
                       , input "":U
                       , input "":U
                       , input "all,{&Excel-yes}":U
                       , input no
                       ) .
END.
ELSE DO:
    run rep/d-report.w ( input parparentproc
                       , input "rep/e-wthres.w":U
                       , input "Остатки материальных ценностей":U
                       , input 1
                       , input "":U
                       , input "":U
                       , input "":U
                       , input "":U
                       , input "all,{&Excel-yes}":U
                       , input no
                       ) .
END.
end.