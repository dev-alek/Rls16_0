block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: chumsess.p $
$Archive: adm/chumsess.p $

Процедура обнаружения подключений к БД IBS TH

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/26/06
Author: Bakhtadze Natalya
Creation date: 05/26/06

*/

define input parameter parparentproc    as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle     as handle no-undo .
define input parameter p-parameter      as character no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chumsess.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/chumsess.p $":U .
define variable vss-description as character no-undo init "Процедура обнаружения подключений к БД IBS TH".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/sys-time.i }

&scop wrlf run write-log-and-file in p-log-handle (                 ~
            input 1                                                 ~
          , input log-file-name                                     ~
          , input 1                                                 ~
          , input ~{&my-message~})


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  define variable v-read-records as integer no-undo .
  define variable v-read-records2 as integer no-undo .
  define variable log-file-name as character no-undo .
  define buffer buf_connect for ub._connect.
  define buffer buf_myconnection for ub._myconnection.
  define temp-table temp-connect no-undo like ub._connect.
  define temp-table temp-myconnection no-undo like ub._myconnection.
  assign
  log-file-name = entry(1 , p-parameter, {&delim-par}).


&scop my-message substitute("!!!Проверка отсутствия подключенных пользователей IBS TH (в т.ч. СПН в ручном режиме)")

   {&wrlf}.

&scop my-message substitute("!!!Проверка отсутствия подключенных пользователей IBS TH&1" + ~
                            "Пожалуйста, ждите......" ~
                            , {&new-line})

    {&wrlf}.
  FOR EACH buf_myconnection:
    create temp-myconnection.
    buffer-copy buf_myconnection to temp-myconnection.
    LEAVE.
  END.
  FOR EACH buf_connect:
    IF buf_connect._connect-type = "REMC" OR
       buf_connect._connect-type = "SELF"  then do:
      if buf_connect._connect-pid <> temp-myconnection._Myconn-pid
      or buf_connect._connect-usr <> temp-myconnection._Myconn-userid then do:
      create temp-connect.
      buffer-copy buf_connect to temp-connect.
      end.
    end.
  END. /*FOR EACH buf_connect:*/
  if can-find(first temp-connect) then do:
    for each temp-connect:

&scop my-message substitute("Обнаружено подключение к БД IBS TH&1пользователь &2 &3" ~
                            , ~{&new-line~} ~
                            , temp-connect._connect-usr ~
                            , temp-connect._connect-name ~
                             )
      {&wrlf}.

    end. /*for each temp-connect:*/
    return error.
  end. /*if can-find(first temp-connect) then do:*/
end. /*doe*/