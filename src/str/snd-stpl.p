block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: snd-stpl.p $
$Archive: str/snd-stpl.p $

Пересылка стоплистов на кассы всех магазинов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/06/07
Author: Bakhtadze Natalya
Creation date: 07/06/07

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .
/*
p-parameter включает
define input parameter p-stop-list-code as character no-undo.
*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: snd-stpl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/snd-stpl.p $":U .
define variable vss-description as character no-undo init "Пересылка стоплистов на кассы всех магазинов".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

&scop view-log   ~{ str/cdviewlg.i   ~
                   "'!!!При отсылке информации на кассы произошли ошибки!!!'" ~
                   "'send-cd.txt'" ~}   ~
                    return


define variable p-stop-list-code as character no-undo.
define variable log-file-name                as character      no-undo init "send-cd.txt".
define variable v-view-log                   as logical        no-undo .
define buffer buf_stop-list for ub.stop-list.
define buffer buf2_stop-list for ub.stop-list.
define buffer buf_clients for ub.clients.
define buffer buf_cash-desk for ub.cash-desk.

assign
p-stop-list-code = entry(1, p-parameter, {&delim-par})
no-error
.
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2&3&4"
                         , p-parameter
                         , {&new-line}
                         , error-status:get-message(1)
                         , return-value
                         )).
  assign
  v-view-log = yes.
  {&view-log}.
end.


find first buf_stop-list no-lock where
          buf_stop-list.classif-type = {&table_dis-card}
     and  buf_stop-list.stop-list-code = p-stop-list-code no-error .
if not available buf_stop-list then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входного параметра p-stop-list-code&1:не найден стоп-лист с таким номером"
                        ,p-stop-list-code
                        )               ).
  assign
  v-view-log = yes.
  {&view-log}.

end.
IF buf_stop-list.status_   <> {&fact} then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input  substitute("Стоплист &1 не закрыт на факт&2Отослать на кассу невозможно"
             , buf_stop-list.status_
             , {&NEW-LINE}))
             .
  assign
  v-view-log = yes.
  {&view-log}.
END.
find first buf2_stop-list NO-LOCK WHERE
        buf2_stop-list.classif-type = buf_stop-list.classif-type
    and buf2_stop-list.host-code = 0
    and buf2_stop-list.obj-type = '':U
    and buf2_stop-list.obj-code = 0
    and buf2_stop-list.status_ = {&fact}
    and buf2_stop-list.fact-order > buf_stop-list.fact-order no-error .
if available buf2_stop-list THEN DO:
    if g#news then return.
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input  substitute("Уже есть более поздний стоплист &1 чем стоплист &2&3" +
                            "Нельзя отослать стоплист &2 на кассу"
              , buf2_stop-list.stop-list-code
              , buf_stop-list.stop-list-code
              , {&NEW-LINE}))
              .
  assign
  v-view-log = yes.
  {&view-log}.
END.

for each buf_clients no-lock
    where buf_clients.obj-type = {&shop}
      and buf_clients.db-num   = g#db-num,
    first buf_cash-desk no-lock where
          buf_cash-desk.db-num = G#db-num
      AND buf_cash-desk.obj-code = buf_clients.obj-code
      AND buf_cash-desk.cash-on = yes
on error undo, return error
:
  run set-title in p-log-handle (
        input "Отправка стоп листов на кассу"
                                  ).
  run str/sendstpl.p (
                  input parparentproc
                ,input p-parent-handle
                ,input p-log-handle
                ,input (string(buf_clients.obj-code) + {&delim-par} + p-stop-list-code + {&delim-par} )
                  ) no-error .
  if error-status:error then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "ошибка при отправке стоплистов на кассу по магазину &1&2&3&2&4"
                          , buf_clients.obj-code
                          , {&new-line}
                          , error-status:get-message(1)
                          , return-value
                          )).
    assign
    v-view-log = yes.
  end.
end.