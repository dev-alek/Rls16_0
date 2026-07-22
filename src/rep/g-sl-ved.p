block-level on error undo, throw.
/*


*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: 609ed9224f21, 348, rls $":U .
define variable vss-author      as character no-undo init "$Author: SShalanin $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 17 17:50:05 2015 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-sl-ved.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-sl-ved.p $":U .
define variable vss-description as character no-undo init "Общая сличислительная ведомость".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/r-page1.i new }

 run rep/d-report.w (            input parparentproc
                            ,input "rep/r-sl-ved.p " + string(parParentProc)
                            ,input ('Общая сличислительная ведомость')
                            ,input 4
                            ,input  "{&g-all},{&g-grp},{&g-prod},{&g-choice},{&g-one}":U
                            ,input "*"
                            ,input "{&p-crsa},{&p-cost}"
                            ,input " "
                            ,input "all,{&Excel-yes}"
                            ,input yes).