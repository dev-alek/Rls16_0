block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-alcdc3.p $
$Archive: rep/g-alcdc3.p $

Декларация об объемах розничной продажи алкогольной продукции для Москвы

Автор: Белоусов Илья Александрович
Дата создания:
Author: Ilia Belousov
Creation date:

*/

define input  parameter parParentProc  as widget-handle no-undo.

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":u .
def var vss-author      as character no-undo init "$Author: expertek $":u .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":u .
def var vss-workfile    as character no-undo init "$Workfile: g-alcdc3.p $":u .
def var vss-archive     as character no-undo init "$Archive: rep/g-alcdc3.p $":u .
def var vss-description as character no-undo init "Декларация об продажах алкоголя для Москвы" .
{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/r-page1.i new }

run rep/d-report.w
    ( input parParentProc
    , input 'rep/alcdcl03.p'
    , input "Декларация об объемах розничной продажи алкогольной продукции для Москвы":U
    , input 1
    , input ""
    , input "{&o-firm},{&o-currency},{&o-choice}"
    , input ""
    , input ""
    , input "all,{&Arc-stk-yes},{&Arc-OT-yes},X-SET_PAY_TYPE=2,{&Excel-yes}"
    , input yes
    ).