block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-alcxml.p $
$Archive: rep/g-alcxml.p $

Декларация об объемах розничной продажи алкогольной продукции в XML (Москва)

Автор: Хныкин Павел Андреевич
Дата создания: 01/22/08
Author: Pavel Khnykin
Creation date: 01/22/08

*/
define input  parameter parParentProc  as widget-handle no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-alcxml.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-alcxml.p $":U .
define variable vss-description as character no-undo init "Декларация об объемах розничной продажи алкогольной продукции в XML (Москва)".
{ cmp/vssrevis.i      }
{ cmp/str-glbl.i      }
{ cmp/r-page1.i new   }

run rep/d-report.w
    ( input parParentProc
    , input 'rep/e-alcxml.w'
    , input "Декларация об объемах розничной продажи алкогольной продукции. Экспорт в XML ":U
    , input 1
    , input ""
    , input "{&o-currency}"
    , input ""
    , input ""
    , input "all,{&Arc-stk-yes},{&Arc-OT-yes}"
    , input no
    ).