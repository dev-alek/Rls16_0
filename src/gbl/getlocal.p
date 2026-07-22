block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: getlocal.p $
$Archive: gbl/getlocal.p $

Определение локальных настроек системы пользователя -

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/20/06
Author: Bakhtadze Natalya
Creation date: 03/20/06

*/

define output parameter par-dec as character no-undo .
define output parameter par-tho as character no-undo .
define output parameter par-sdate as character no-undo .
define output parameter par-shortdate as character no-undo .
/*
define output parameter par-longdate as character no-undo .*/


def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: getlocal.p $":U .
def var vss-archive     as character no-undo init "$Archive: gbl/getlocal.p $":U .
def var vss-description as character no-undo init "Определение локальных настроек системы пользователя".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/i18n.i }

DEFINE VARIABLE cchRet as integer no-undo.
do
on error undo, return error
:

assign
par-dec = fill({&space-char},50)
par-tho = fill({&space-char},50)
par-sdate = fill({&space-char},50)
par-shortdate = fill({&space-char},50)
/*par-longdate = fill({&space-char},50)*/
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

  RUN GetLocaleInfoA in hpApi ( {&LOCALE_USER_DEFAULT}
                               ,{&LOCALE_SSHORTDATE }
                               ,input-output par-shortdate
                               ,length(par-shortdate)
                               ,output cchRet
                                  ).

  RUN GetLocaleInfoA in hpApi ( {&LOCALE_USER_DEFAULT}
                               ,{&LOCALE_SDATE }
                               ,input-output par-sdate
                               ,length(par-sdate)
                               ,output cchRet
                                  ).
/*
  RUN GetLocaleInfoA in hpApi ( {&LOCALE_USER_DEFAULT}
                               ,{&LOCALE_SLONGDATE }
                               ,input-output par-longdate
                               ,length(par-longdate)
                               ,output cchRet
                                  ).

*/
  assign
  par-dec = trim(par-dec)
  par-tho = trim(par-tho)
  par-sdate = trim(par-sdate)
  par-shortdate = trim(par-shortdate)
  /*par-longdate = trim(par-longdate)*/
  .

end.