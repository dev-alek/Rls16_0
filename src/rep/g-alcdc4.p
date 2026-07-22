block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-alcdc4.p $
$Archive: rep/g-alcdc4.p $

Декларация об объемах розничной продажи алкогольной продукции (Псков)

Автор: Хныкин Павел Андреевич
Дата создания: 09/18/07
Author: Pavel Khnykin
Creation date: 09/18/07

*/

define input  parameter parParentProc  as widget-handle no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-alcdc4.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-alcdc4.p $":U .
define variable vss-description as character no-undo init "Декларация об объемах розничной продажи алкогольной продукции (Псков)".
{ cmp/vssrevis.i      }
{ cmp/str-glbl.i      }
{ cmp/r-page1.i new   }
{ gbl/getcntxt.i def  }

define variable v-object-choice as character no-undo .


{ gbl/getcntxt.i get  }

if v-cntxt-db-num <> 0 then do:
  assign
    v-object-choice  = "{&o-currency}":U
  .
end.
else do:
  assign
    v-object-choice = "{&o-firm},{&o-currency},{&o-choice}":U
  .
end.


run rep/d-report.w
    ( input parParentProc
    , input 'rep/alcdcl04.p'
    , input "Декларация об объемах розничной продажи алкогольной продукции":U
    , input 1
    , input ""
    , input v-object-choice
    , input ""
    , input ""
    , input "all,{&Arc-stk-yes}"
    , input yes
    ).