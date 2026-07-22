block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: 2014/01/27 14:27:46 $
$Workfile: r-bnnto1.p $
$Archive: rep/r-bnnto1.p $

Печать отчета о выручке  Bytemp

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/07/05
Author: Bakhtadze Natalya
Creation date: 09/07/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter cas-num as integer no-undo .
define input parameter HowBreak        as logical     no-undo.
define input parameter t-time as logical no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: 2014/01/27 14:27:46 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-bnnto1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-bnnto1.p $":U .
define variable vss-description as character no-undo init "Печать отчета о выручке".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/r-page1.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ rep/rep-bt.i }
{ gbl/waitfram.i }
{ rep/r-bentt.i "new shared" }
{ rep/r-benttm.i "shared" }


DEFINE VARIABLE sale-price-type as character   no-undo .
DEFINE VARIABLE found           as logical init yes no-undo.
DEFINE VARIABLE NotInc          as logical     no-undo.
DEFINE VARIABLE choice          as logical     no-undo.

DEFINE VARIABLE Line            as character   no-undo.

DEFINE VARIABLE date_string     as      char    no-undo.
DEFINE VARIABLE doprubl as decimal no-undo.
DEFINE VARIABLE DatePrinted     as      logical     no-undo.
DEFINE VARIABLE sym1 as char init ":"   no-undo.
DEFINE VARIABLE sym2 as char init ":"   no-undo.
DEFINE VARIABLE sym3 as char init ":"   no-undo.
DEFINE VARIABLE sym4 as char init ":"   no-undo.
DEFINE VARIABLE sym5 as char init ":"   no-undo.
DEFINE VARIABLE sym6 as char init ":"   no-undo.
DEFINE VARIABLE sym7 as char init ":"   no-undo.
DEFINE VARIABLE sym8 as char init ":"   no-undo.


DEFINE VARIABLE ObjAmount    as      integer no-undo.
DEFINE VARIABLE ChkAmount    as      integer no-undo.
DEFINE VARIABLE  AllDay-BaseSum as decimal no-undo .
DEFINE VARIABLE  AllDay-RublSum as decimal no-undo .
DEFINE SHARED VARIABLE cas-shft as logical no-undo init no.
define buffer t-benefits for benefits.

{ rep/e-nobenq.i }
{ rep/r-benfr.i tot }
{ rep/r-benef1.i tot time }