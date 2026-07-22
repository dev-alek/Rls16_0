block-level on error undo, throw.







define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: 0500dccfad42, 789, rls $":U .
define variable vss-author      as character no-undo init "$Author: PGridchina $":U .
define variable vss-date        as character no-undo init "$Date: Wed Sep 14 14:42:19 2016 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-form-ko.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-form-ko.p $":U .
define variable vss-description as character no-undo init " Журнал регистрации ПКО и РКО (КО-3)".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/r-page1.i new }

run rep/d-report.w (
                   input parparentproc
                   ,input "rep/r-form-ko.p " + string(parParentProc)
                   ,input (' Журнал регистрации ПКО и РКО (КО-3)')
                   ,input 4
                   ,input ""
                   ,input "{&o-currency}"
                   ,input ""
                   ,input ""
                   , input "{&shop}"
                   ,input yes).