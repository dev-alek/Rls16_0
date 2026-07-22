block-level on error undo, throw.
define input  parameter parParentProc  as handle no-undo.

define variable vss-revision    as character no-undo init "$Revision: 17dfe15be2b1, 1388, rls $":U .
define variable vss-author      as character no-undo init "$Author: DARuban $":U .
define variable vss-date        as character no-undo init "$Date: Thu Jun 28 15:24:32 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-statusvsd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-statusvsd.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i new}
run rep/d-report.w ( input parParentProc ,
input                   'rep/e-statusvsd.w',"Отчет для получения информации по статусу ВСД",
input                        2,
input                        "{&g-all},{&g-choice},{&g-one}":U,
input                        "*":U,
input                        "",
input                        "",
input                        "all,{&Excel-yes}",
input                        no).