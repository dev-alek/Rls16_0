block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: sndwsht.p $
$Archive: str/sndwsht.p $

Пересылка масок серийных МЦ на кассы всех магазинов фирмы

Автор: Гридчина Полина Дмитриевна
Дата создания: 08/15/07
Author: Polina Gridchina
Creation date: 08/15/07


*/
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-ser-list   as character no-undo .
define input parameter p-action as char no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sndwsht.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/sndwsht.p $":U .
define variable vss-description as character no-undo init "Пересылка масок серийных МЦ на кассы всех магазинов фирмы".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
&scop view-log   ~{ str/cdviewlg.i   ~
                   "'!!!При отсылке информации на кассы произошли ошибки!!!'" ~
                   "'send-cd.txt'" ~}   ~
                    return


define variable log-file-name                as character      no-undo init "send-cd.txt".
define variable v-view-log                   as logical        no-undo .
define buffer buf_clients for ub.clients.
define buffer buf_cash-desk for ub.cash-desk.

for each buf_clients no-lock
    where buf_clients.obj-type = {&shop}
      and buf_clients.db-num   = g#db-num,
    first buf_cash-desk no-lock where
          buf_cash-desk.db-num = G#db-num
      AND buf_cash-desk.obj-code = buf_clients.obj-code
      AND buf_cash-desk.cash-on = yes
      AND buf_cash-desk.pos-type = {&cd-type-IBM-XML}
on error undo, return error
:
  run set-title in p-log-handle (
        input "Отправка масок МЦ на кассу"
                                  ).
  run str/sndwssh.p (
                  input parparentproc
                ,input p-parent-handle
                ,input p-log-handle
                ,input  buf_clients.obj-type
                ,input buf_clients.obj-code
                ,input string(p-ser-list)
                ,p-action
                  ) no-error .
  if error-status:error then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "ошибка при отправке масок серийных МЦ на кассу по магазину &1&2&3&2&4"
                          , buf_clients.obj-code
                          , {&new-line}
                          , error-status:get-message(1)
                          , return-value
                          )).
    assign
    v-view-log = yes.
  end.
end.