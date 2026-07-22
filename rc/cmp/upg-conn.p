block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: upg-conn.p $
$Archive: cmp/upg-conn.p $

процедура connect`а к 14 БД

Автор: Чернова Светлана Александровна
Дата создания: 08/31/09
Author: Svetlana Chernova
Creation date: 08/31/09

*/

define input  parameter p-action    as character no-undo .
define input  parameter p-check-version as character no-undo .
define output parameter p-ok        as logical   no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: upg-conn.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cmp/upg-conn.p $":U .
define variable vss-description as character no-undo init "процедура connect`а к БД IBS TH другой версии".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:

  define buffer buf_rep for ub.rep .

  define variable v-conn-par as character no-undo .

  if lookup( p-action, "connect,clear-conn-par":U ) = 0 then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute("Ошибка задания входных параметров.") skip
      substitute("Неизвестное действие &1.", p-action ) skip
      view-as alert-box error .
    return error .
  end.

  assign
    p-ok = false
  .

  find first buf_rep exclusive-lock
    where buf_rep.rep-num = 1996011202
    no-error
  .

  case p-action :
    when "connect":U then do:
      run adm/conn-db.w
        ( input "Параметры подключения к БД источнику"
        , input (if available buf_rep and buf_rep.name2 = p-check-version then buf_rep.name1 else ? )
        , input "sysadm":U
        , input "sysadm":U
        , input  "src":U
        , output v-conn-par
        ) no-error .
      if error-status :error
        or v-conn-par = ?
      then do:
        return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) ) .
      end.
      else do:
        run cmp/upgconnt.p ( input p-check-version) .  /*ПРОВЕРКИ */
        if error-status :error then do:
          disconnect src.
          return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) ) .
        end.
        if not available buf_rep then do:
          create buf_rep .
          assign
            buf_rep.rep-num = 1996011202
          .
        end.
        assign
          p-ok          = true
          buf_rep.name1 = v-conn-par
          buf_rep.name2 = p-check-version
        .
      end.
    end.
    when "clear-conn-par":U then do:
      delete buf_rep .
      assign
        p-ok = true
      .
    end.
  end case.

  return .

end.