block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: snd-stpl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/snd-stpl.p $":U .
define variable vss-description as character no-undo init "Пересылка стоплистов на кассы всех магазинов".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable p-stop-list-code as character no-undo.
define variable log-file-name                as character      no-undo init "send-cd.txt".
define variable v-view-log                   as logical        no-undo .
define buffer buf_stop-list for ub.stop-list.
define buffer buf2_stop-list for ub.stop-list.
define buffer buf_clients for ub.clients.
define buffer buf_cash-desk for ub.cash-desk.
assign
p-stop-list-code = entry(1, p-parameter, chr(4))
no-error
.
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2&3&4"
                         , p-parameter
                         , chr(10)
                         , error-status:get-message(1)
                         , return-value
                         )).
  assign
  v-view-log = yes.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При отсылке информации на кассы произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action1   as character no-undo .
  define variable v-printed1       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При отсылке информации на кассы произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + 'send-cd.txt')
    ,input  7
    ,output v-user-action1
    ,output v-printed1
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'send-cd.txt').
end.
                        return.
end.
find first buf_stop-list no-lock where
          buf_stop-list.classif-type = 'dis-card':U
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При отсылке информации на кассы произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action3   as character no-undo .
  define variable v-printed3       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При отсылке информации на кассы произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + 'send-cd.txt')
    ,input  7
    ,output v-user-action3
    ,output v-printed3
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'send-cd.txt').
end.
                        return.
end.
IF buf_stop-list.status_   <> 'факт':U then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input  substitute("Стоплист &1 не закрыт на факт&2Отослать на кассу невозможно"
             , buf_stop-list.status_
             , chr(10)))
             .
  assign
  v-view-log = yes.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При отсылке информации на кассы произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action5   as character no-undo .
  define variable v-printed5       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При отсылке информации на кассы произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + 'send-cd.txt')
    ,input  7
    ,output v-user-action5
    ,output v-printed5
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'send-cd.txt').
end.
                        return.
END.
find first buf2_stop-list NO-LOCK WHERE
        buf2_stop-list.classif-type = buf_stop-list.classif-type
    and buf2_stop-list.host-code = 0
    and buf2_stop-list.obj-type = '':U
    and buf2_stop-list.obj-code = 0
    and buf2_stop-list.status_ = 'факт':U
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
              , chr(10)))
              .
  assign
  v-view-log = yes.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При отсылке информации на кассы произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action7   as character no-undo .
  define variable v-printed7       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При отсылке информации на кассы произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + 'send-cd.txt')
    ,input  7
    ,output v-user-action7
    ,output v-printed7
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'send-cd.txt').
end.
                        return.
END.
for each buf_clients no-lock
    where buf_clients.obj-type = 'маг':U
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
                ,input (string(buf_clients.obj-code) + chr(4) + p-stop-list-code + chr(4) )
                  ) no-error .
  if error-status:error then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "ошибка при отправке стоплистов на кассу по магазину &1&2&3&2&4"
                          , buf_clients.obj-code
                          , chr(10)
                          , error-status:get-message(1)
                          , return-value
                          )).
    assign
    v-view-log = yes.
  end.
end.
