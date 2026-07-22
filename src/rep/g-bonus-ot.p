block-level on error undo, throw.
/*


*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: 5b4da7b58b15, 345, rls $":U .
define variable vss-author      as character no-undo init "$Author: SShalanin $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 17 17:49:45 2015 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-bonus-ot.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-bonus-ot.p $":U .
define variable vss-description as character no-undo init "Отчет по бонусам".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/r-page1.i new }

 run rep/d-report.w (            input parparentproc
                            ,input "rep/e-bonus-ot.w "
                            ,input ('Отчет по бонусам')
                            ,input 4
                            ,input  "{&g-all},{&g-grp},{&g-choice},{&g-one}":U
                            ,input "*"
                            ,input ""
                            ,input " "
                            ,input "all,{&Excel-yes}"
                            ,input no).