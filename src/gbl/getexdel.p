block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: getexdel.p $
$Archive: gbl/getexdel.p $

Определение локальных настроек системы пользователя - разделителя дес точки и тысяч

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

define output parameter par-dec as character no-undo .
define output parameter par-tho as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: getexdel.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/getexdel.p $":U .
define variable vss-description as character no-undo init "Определение локальных настроек системы пользователя - разделителя дес точки и тысяч".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/i18n.i }

DEFINE VARIABLE cchRet as integer no-undo.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:



assign
par-dec = fill({&space-char},50)
par-tho = fill({&space-char},50)
.
  RUN GetLocaleInfoA in hpApi ( {&LOCALE_USER_DEFAULT}
                               ,{&LOCALE_SDECIMAL}
                               ,input-output par-dec
                               ,length(par-dec)
                               ,output cchRet
                                  ).

  RUN GetLocaleInfoA in hpApi ( {&LOCALE_USER_DEFAULT}
                               ,{&LOCALE_STHOUSAND}
                               ,input-output par-tho
                               ,length(par-tho)
                               ,output cchRet
                                  ).

  assign
  par-dec = trim(par-dec)
  par-tho = trim(par-tho)
  .

end.