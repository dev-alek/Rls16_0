block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle as handle no-undo .
define input parameter p-parameter   as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sendalcd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/sendalcd.p $":U .
define variable vss-description as character no-undo init "Отправка на кассу изменений товаров или клиентов, накопленных в результате работы со справочниками".
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
define variable p-gds as logical no-undo .
define variable p-dcard as logical no-undo .
define variable p-seller as logical no-undo .
define variable p-cashier as logical no-undo .
define variable p-fgrp as logical no-undo .
define variable v-view-log as logical no-undo .
define variable log-file-name as character no-undo init "send-cd.txt".
define variable v-stop as logical no-undo .
define buffer buf_BatchProcess for ub.batchProcess .
assign
p-gds = (if entry(1, p-parameter, chr(4)) = "yes"
        then yes
        else (if entry(1, p-parameter, chr(4)) = "no"
              then no
              else ?)
        )
p-dcard = (if entry(2, p-parameter, chr(4)) = "yes"
        then yes
        else (if entry(2, p-parameter, chr(4)) = "no"
              then no
              else ?)
        )
p-seller = (if entry(3, p-parameter, chr(4)) = "yes"
        then yes
        else (if entry(3, p-parameter, chr(4)) = "no"
              then no
              else ?)
        )
p-cashier = (if entry(4, p-parameter, chr(4)) = "yes"
        then yes
        else (if entry(4, p-parameter, chr(4)) = "no"
              then no
              else ?)
        )
p-fgrp   = (if entry(5, p-parameter, chr(4)) = "yes"
        then yes
        else (if entry(5, p-parameter, chr(4)) = "no"
              then no
              else ?)
        )
no-error
.
if error-status:error
or p-gds = ?
or p-dcard = ?
or p-seller = ?
or p-cashier = ?
then return error.
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute( "Пересылка на кассы БД &1 изменений, сделанных в справочнике", g#db-num )
                                      ).
if p-gds and  can-find (first  buf_BatchProcess no-lock
      where buf_BatchProcess.bp_type       = 'gds':U
        and buf_BatchProcess.bp_status     = 'N':U
               ) then do:
    run set-title in p-log-handle (
          input "Отправка товаров на кассу"
                                   ).
  run trg/bt_gds.p (
                parparentproc
               , input p-log-handle
               ,no) no-error .
  if error-status:error or
  return-value = "yes":U then do:
    run set-view-log in p-log-handle(yes).
  end.
end.
run set-counter-value in p-log-handle ( input '':U ).
run hide-counter in p-log-handle.
run get-stop-state in p-log-handle (output v-stop).
if p-dcard
and not  v-stop
and can-find (first  buf_BatchProcess no-lock
      where buf_BatchProcess.bp_type       = 'dcard':U
        and buf_BatchProcess.bp_status     = 'N':U
               ) then do:
    run set-title in p-log-handle (
          input 'Отправка информации по клиентским картам на кассу'
                                    ).
  run trg/bt_dcard.p (
                   input parparentproc
                 , input p-log-handle
                 , input no) no-error .
  if error-status:error or
  return-value = "yes":U then do:
    run set-view-log in p-log-handle(yes).
  end.
end.
run set-counter-value in p-log-handle ( input '':U ).
run hide-counter in p-log-handle.
if p-seller
and not  v-stop
and can-find (first  buf_BatchProcess no-lock
      where buf_BatchProcess.bp_type       = 'slr':U
        and buf_BatchProcess.bp_status     = 'N':U
               ) then do:
    run set-title in p-log-handle (
          input 'Отправка информации по продавцам на кассу'
                                    ).
  run trg/bt_slr.p (
                 input parparentproc
                ,input p-log-handle
                ,input string(no)
                ) no-error .
  if error-status:error or
  return-value = "yes":U then do:
    run set-view-log in p-log-handle(yes).
  end.
end.
run set-counter-value in p-log-handle ( input '':U ).
run hide-counter in p-log-handle.
if p-cashier
and not  v-stop
and can-find (first  buf_BatchProcess no-lock
      where buf_BatchProcess.bp_type       = 'cshr':U
        and buf_BatchProcess.bp_status     = 'N':U
               ) then do:
    run set-title in p-log-handle (
          input 'Отправка информации по кассирам на кассу'
                                    ).
  run trg/bt_cshr.p ( input parparentproc
                ,input p-log-handle
                ,input string(no)
                ) no-error .
  if error-status:error or
  return-value = "yes":U then do:
    run set-view-log in p-log-handle(yes).
  end.
end.
run set-counter-value in p-log-handle ( input '':U ).
run hide-counter in p-log-handle.
if p-fgrp
and not  v-stop
and can-find (first  buf_BatchProcess no-lock
      where buf_BatchProcess.bp_type       = 'fgrp':U
        and buf_BatchProcess.bp_status     = 'N':U
               ) then do:
    run set-title in p-log-handle (
          input 'Отправка информации по группам блюд на кассу'
                                    ).
  run trg/bt_fgrp.p ( input parparentproc
                ,input p-log-handle
                ,input string(no)
                ) no-error .
  if error-status:error or
  return-value = "yes":U then do:
    run set-view-log in p-log-handle(yes).
  end.
end.
run set-counter-value in p-log-handle ( input '':U ).
run hide-counter in p-log-handle.
 run get-view-log in p-log-handle(output v-view-log).
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
