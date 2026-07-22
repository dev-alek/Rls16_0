block-level on error undo, throw.
/*

$Revision: a38042964324, 1747, rls $
$Author: ASMorozov $
$Date: Thu Jan 24 17:02:17 2019 +0300 $
$Workfile: g-sndreq.p $
$Archive: utl/g-sndreq.p $

Выбрать объекты для отправки запроса распределённой проверки целостности остатков по товарам

Автор: Перваков Михаил Сергеевич
Дата создания: 08/10/04
Author: Mikhail Pervakov
Creation date: 08/10/04

*/

define input parameter parparentproc as handle           no-undo.

define variable vss-revision    as character no-undo init "$Revision: a38042964324, 1747, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Jan 24 17:02:17 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-sndreq.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/g-sndreq.p $":U .
define variable vss-description as character no-undo init "Выбрать объекты для отправки запроса распределённой проверки целостности остатков по товарам".
{ cmp/vssrevis.i    }
{ cmp/trg-def.i     }
{ cmp/r-page1.i new }

do
on error undo, return error
:

  define variable conf-par as character no-undo.
  define variable mode-erprn as logical no-undo.
  define variable par-type as character no-undo.
    { gbl/conf-rd.i
    "'is-erpRN'"
    0
    "''"
    0
    "''"
    "''"
    "''"
    NO
    conf-par
    par-type
    no-error
    }
  if not error-status:error and conf-par = "yes":u then mode-erprn = yes.
  else mode-erprn = no.
  if mode-erprn 
  then do:
    message "При включенном параметре is-erpRN запуск распределенной проверки остатков по товарам невозможен." view-as alert-box information title "Внимание".
    return.
  end.

  
  run rep/d-report.w
    (input parparentproc
    ,input 'utl/e-sndreq.p'
    ,input "Отправить запрос для распределённой проверки целостности остатков по товарам"
    ,input 0
    ,input ""
    ,input "*"
    ,input ""
    ,input ""
    ,input "all"
    ,input true
    ).
end.