block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-pychk0.p $
$Archive: rep/r-pychk0.p $

Разброс чеков продажи

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/07/05
Author: Bakhtadze Natalya
Creation date: 09/07/05

*/

define input parameter p-log-handle     as handle no-undo .
DEFINE INPUT PARAMETER pobj-type like ub.shift-obj.obj-type no-undo.
DEFINE INPUT PARAMETER pobj-code like ub.shift-obj.obj-code no-undo.
define input parameter p-out-code as character no-undo .

define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision: aea5316774be, 0, rls $":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author: expertek $":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile: r-pychk0.p $":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive: rep/r-pychk0.p $":U.
define variable vss-description AS CHAR NO-UNDO INIT "Разброс чеков продажи":U.

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }


define buffer buf_inkas for ub.inkas.
find first buf_Inkas where buf_inkas.inkas-code = p-out-code.

run rep/rpychk0.p ( input "r-pychk0"
                    ,input buf_inkas.obj-type
                    ,input buf_inkas.obj-code
                    ,input ? /*p-date-from*/
                    ,input ? /*p-date-to*/
                    ,input ? /*p-shift-date-from*/
                    ,input ? /*p-shift-date-to*/
                    ,input ? /*p-shift-num-start*/
                    ,input ? /*p-shift-num-end*/
                    ,input p-out-code /*p-inkas-code*/
                    ).

