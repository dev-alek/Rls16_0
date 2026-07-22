block-level on error undo, throw.
/*


*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: b1cdac0247d6, 2107, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Wed Dec 25 15:23:52 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-bank-product.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-bank-product.p $":U .
define variable vss-description as character no-undo init "Отчет о реализации банковских продуктов".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/r-page1.i new }

 run rep/d-report.w (            input parparentproc
                            ,input "rep/e-bank-product.w "
                            ,input ('Отчет о реализации банковских продуктов')
                            ,input 5
                            ,input "":U
                            ,input "*"
                            ,input ""
                            ,input ""
                            ,input "all,{&Excel-yes}"
                            ,input no).