block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: chuasess.p $
$Archive: adm/chuasess.p $

Процедура обнаружения автоматичесикх сессий

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
define variable vss-workfile    as character no-undo init "$Workfile: chuasess.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/chuasess.p $":U .
define variable vss-description as character no-undo init "Процедура обнаружения автоматических сессий".
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
  define buffer buf_actrecord for ub._actrecord.
  assign
  log-file-name = entry(1 , p-parameter, {&delim-par}).

&scop my-message substitute("!!!Проверка отсутствия сессий, работающих в автоматическом режиме&1(по расписанию) займет менее 2 мин&1" + ~
                            "Пожалуйста, ждите......" ~
                            , {&new-line})

    {&wrlf}.

    find first buf_actrecord.
    assign
    v-read-records = buf_actrecord._record-recread
    .
    /*
    FOR EACH buf_tablestat no-lock ,
       first buf_file no-lock where
           buf_tablestat._tablestat-id = buf_tile._file-number
       and buf_file._file-name = 'db':
       assign
       v-db-read-records = buf_tablestat._tablestat-read .
    END.
    */
    etime (yes) .
    do while true:
      if etime > 100000 then leave.
      if etime modulo 1000 = 0 then do:
        process events.
      end.
    end.

    find first buf_actrecord.
    assign
    v-read-records2 = buf_actrecord._record-recread
    .
    if v-read-records2 - v-read-records > 0 then do:
      undo main-block, return error "Обнаружена активность в работе с БД".
    end.
end.