block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cnf-chk.p $
$Archive: adm/cnf-chk.p $

Процедура проверки всех параметров конфигурации

Автор: Уханов Дмитрий Юрьевич
Дата создания: 09/04/06
Author: Dmitry Ukhanov
Creation date: 09/04/06

В этой процедуре доступны shared temp-table cnf и cnf-struct.
cnf - это temp-table like config, только в нее добавлены несколько служебных полей.
      Существенное поле NotUsed, которое говорит что параметр выключен, если оно имеет значение true.
cnf-struct - таблица созданная по файлу mold_db.sch

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cnf-chk.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/cnf-chk.p $":U .
define variable vss-description as character no-undo init "Процедура проверки всех параметров конфигурации".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

{ adm/cnf-inc.i }
{ adm/cfg-pr.i  }

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:


  return.
end.

/* $Workfile: cnf-chk.p $ e n d */



