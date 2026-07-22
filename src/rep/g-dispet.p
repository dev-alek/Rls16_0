block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-dispet.p $
$Archive: rep/g-dispet.p $

Отчет диспетчера. Стартовая процедура

Автор: Белоусов Илья Александрович
Дата создания: 11/22/07
Author: Ilia Belousov
Creation date: 11/22/07

Input:

Output:

*/
define input  parameter parparentproc      as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-dispet.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-dispet.p $":U .
define variable vss-description as character no-undo init "Отчет диспетчера".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ cmp/r-page1.i new }


do
on error undo, return error
:
{ gbl/getcntxt.i get }

   IF v-cntxt-db-num = 0 THEN do:
      run rep/d-report.w
         ( input parparentproc      /* 0 */
         , input 'rep/e-dispet.w'   /* 1 */
         , input "Отчет диспетчера" /* 2 */
         , input 1                  /* 3 date 7 - одна дата */
         , input ""                 /* 4 */
         , input "{&o-choice}"      /* 5 */
         , input ""                 /* 6 */
         , input ""                 /* 7 */
         , input "{&Excel-yes}"     /* 8 */
         , input NO                 /* 9 */
         ).
   end.
   else do:
      run rep/d-report.w
         ( input parparentproc      /* 0 */
         , input 'rep/e-dispet.w'   /* 1 */
         , input "Отчет диспетчера" /* 2 */
         , input 1                  /* 3 date 7 - одна дата */
         , input ""                 /* 4 */
         , input "{&o-currency}"    /* 5 */
         , input ""                 /* 6 */
         , input ""                 /* 7 */
         , input "{&Excel-yes}"     /* 8 */
         , input NO                 /* 9 */
         ).
   end.
end.
