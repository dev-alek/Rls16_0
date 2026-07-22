block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-alcdcl.p $
$Archive: rep/g-alcdcl.p $

Декларация об объемах розничной продажи алкогольной продукции

Автор: Хныкин Павел Андреевич
Дата создания: 07/05/06
Author: Pavel Khnykin
Creation date: 07/05/06

*/
define input  parameter parParentProc  as widget-handle no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-alcdcl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-alcdcl.p $":U .
define variable vss-description as character no-undo init "Декларация об объемах розничной продажи алкогольной продукции".

{ cmp/vssrevis.i      }
{ cmp/str-glbl.i      }
{ cmp/r-page1.i new   }

run rep/d-report.w
    ( input parParentProc
    , input 'rep/alcdcl01.p'
    , input "Декларация об объемах розничной продажи алкогольной продукции":U
    , input 1
    , input ""
    , input "{&o-firm},{&o-currency},{&o-choice}"
    , input "{&p-cost},{&p-crsa}"
    , input "{&v-rubl}"
    , input "all,{&Arc-stk-yes},{&Arc-OT-yes},X-SET_PAY_TYPE=2,{&Excel-yes}"
    , input yes
    ).