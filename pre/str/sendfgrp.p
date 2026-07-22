block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sendfgrp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/sendfgrp.p $":U .
define variable vss-description as character no-undo init "пересылка групп блюд на кассу - пускальник".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE SHARED TEMP-TABLE cash-fgrp no-undo
FIELD node-code like ub.fbr-gds-grp.node-code
FIELD upper-code like ub.fbr-gds-grp.upper-code
FIELD out-code like ub.fbr-gds-grp.out-code
FIELD node-name like ub.fbr-gds-grp.node-name
FIELD upper-out-code like ub.fbr-gds-grp.out-code
FIELD lvl-num        like ub.fbr-gds-grp.lvl-num
FIELD stts  as integer
FIELD action-code as integer
index iout-code IS PRIMARY out-code
index istts stts
index ilvl action-code lvl-num
.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable choice as integer no-undo.
define variable     v-recid-list            as char no-undo.
define variable     kk                  as int      no-undo.
define variable callpoint as char no-undo.
define variable glog as logical no-undo .
define variable v-upper-out-code like ub.fbr-gds-grp.out-code no-undo .
define variable log-file-name as character no-undo init "send-cd.txt".
define variable v-view-log as logical no-undo .
define variable i-obj-code like ub.clients.obj-code no-undo.
define variable mode     as   character no-undo.
define buffer buf_fbr-gds-grp for ub.fbr-gds-grp.
define buffer upper_fbr-gds-grp for ub.fbr-gds-grp.
assign
i-obj-code = integer(entry(1, p-parameter, chr(4)))
mode = entry(2, p-parameter, chr(4))
no-error
.
if error-status:error then return error.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
assign
callpoint = mode.
mode = if mode = "R" then "U" else mode.
for each cash-fgrp:
    delete cash-fgrp.
end.
FIND FIRST ub.cash-desk NO-LOCK WHERE
           ub.cash-desk.db-num = g#db-num AND
           ub.cash-desk.pos-type = 'MAGIA-XML':U
            No-error.
IF not avail(ub.cash-desk) then do:
  if callpoint <> "R" then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!&1 групп блюд реализуется только для касс &2"
                              , (if mode = "U" then "Передача" else "Удаление")
                              , 'MAGIA-XML':U
                            )
                                            ).
     return.
  end.
end.
else do:
  if callpoint = "R"
  then do:
    glog = yes.
  end.
  else do:
    define variable v-host-code as integer   no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  'маг':U
  ,input  abs(i-obj-code)
  ,output v-host-code
  )  .
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_cashdesk-goods-groups_update':U
    ,input  'object':U
    ,input  v-host-code
    ,input  'маг':U
    ,input  abs(i-obj-code)
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
  end.
  if NOT glog then return .
  glog = yes.
  if callpoint = "R" then choice = 2.
  else
  run gbl/d-askw.w (input "Выбор групп блюд для пересылки",
              input ( (if mode = "U" then "Переслать на кассу"
                        else "Удалить из кассы" ) +
                        chr(10) + "информацию о группах блюд по объекту"
                        ),
              input "|",
              input "Все  имеющиеся в базе|Выборочно|Отказ от пересылки",
              input "||",
              input 1,
              input 3,
              output choice).
  CASE choice :
    when 3 then
        return .
    when 2 then do:
      if callpoint = "R" then do:
      end.
      else do:
        run ref/fbrggrp.w (
              input parparentproc
            , input 'маг':U
            , input i-obj-code
            , input "b-sel,b-mark"
            , input-output v-recid-list
        ).
        if v-recid-list <> "" then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("&1 магазина &2: выборочная пересылка групп блюд"
                                , (if mode = "U" then "Пересылка на кассы" else "Удаление с касс" )
                                , i-obj-code)
              ).
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("Подготовка данных")
                                              ).
          DO kk = 1 TO num-entries( v-recid-list ) :
            FIND FIRST buf_fbr-gds-grp NO-LOCK WHERE
                 recid(buf_fbr-gds-grp) = integer(ENTRY(kk, v-recid-list)) NO-ERROR.
            IF AVAIL buf_fbr-gds-grp then do:
              find first upper_fbr-gds-grp no-lock where
                        upper_fbr-gds-grp.obj-type = 'маг':U
                    AND upper_fbr-gds-grp.obj-code = i-obj-code
                    AND upper_fbr-gds-grp.node-code = buf_fbr-gds-grp.upper-code no-error .
              if avail upper_fbr-gds-grp then do:
                assign
                v-upper-out-code = if upper_fbr-gds-grp.out-code = 0 then 1 else upper_fbr-gds-grp.out-code
                .
              end.
              else do:
                assign
                v-upper-out-code = 1
                .
              end.
              FIND FIRST cash-fgrp WHERE
                          cash-fgrp.node-code = buf_fbr-gds-grp.node-code NO-ERROR.
              if not avail cash-fgrp then do:
                create cash-fgrp.
                assign
                cash-fgrp.node-code  = buf_fbr-gds-grp.node-code
                cash-fgrp.upper-code = buf_fbr-gds-grp.upper-code
                cash-fgrp.out-code   = buf_fbr-gds-grp.out-code
                cash-fgrp.node-name  = buf_fbr-gds-grp.node-name
                cash-fgrp.upper-out-code  = v-upper-out-code
                cash-fgrp.lvl-num    = buf_fbr-gds-grp.lvl-num
                cash-fgrp.stts              = integer('0':U)
                .
                release cash-fgrp.
              end.
            END.
          END.
        end.
        else  do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("Не определен список групп блюд для пересылки")
                                              ).
          return .
        end.
      end.
    end.
    when 1 then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("&1 магазина &2: пересылка всех имеющихся в БД групп блюд"
                            , (if mode = "U" then "Пересылка на кассы" else "Удаление с касс" )
                            , i-obj-code)
          ).
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("Подготовка данных")
                                          ).
      FOR EACH buf_fbr-gds-grp no-lock where
              buf_fbr-gds-grp.obj-type = 'маг':U
          AND buf_fbr-gds-grp.obj-code = i-obj-code:
        find first upper_fbr-gds-grp no-lock where
                  upper_fbr-gds-grp.obj-type = 'маг':U
              AND upper_fbr-gds-grp.obj-code = i-obj-code
              AND upper_fbr-gds-grp.node-code = buf_fbr-gds-grp.upper-code no-error .
        if avail upper_fbr-gds-grp then do:
          assign
          v-upper-out-code = if upper_fbr-gds-grp.out-code = 0 then 1 else upper_fbr-gds-grp.out-code
          .
        end.
        else do:
          assign
          v-upper-out-code = 1
          .
        end.
        FIND FIRST cash-fgrp WHERE
                    cash-fgrp.node-code = buf_fbr-gds-grp.node-code NO-ERROR.
        if not avail cash-fgrp then do:
          create cash-fgrp.
          assign
          cash-fgrp.node-code  = buf_fbr-gds-grp.node-code
          cash-fgrp.upper-code = buf_fbr-gds-grp.upper-code
          cash-fgrp.out-code   = buf_fbr-gds-grp.out-code
          cash-fgrp.upper-out-code  = v-upper-out-code
          cash-fgrp.node-name  = buf_fbr-gds-grp.node-name
          cash-fgrp.lvl-num    = buf_fbr-gds-grp.lvl-num
          cash-fgrp.stts              = integer('0':U)
          .
          release cash-fgrp.
        end.
      END.
    end.
  END CASE.
  if can-find(first cash-fgrp ) then do:
    run str/send-fgr.p (
                      input parparentproc
                      ,input p-parent-handle
                      ,input p-log-handle
                      ,input (string(i-obj-code) + chr(4) + mode + chr(4) + "no":U) ) no-error.
    if not error-status:error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("&1 маг&2 &3"
                              , (if mode = "U"
                                then "Передача групп блюд на кассы"
                                else "Удаление групп блюд с касс")
                              , i-obj-code
                              , (if mode = "U"
                                then "проведена"
                                else "проведено")
                              )
                                          ).
    end.
    else do:
     assign
     v-view-log = yes
     .
    end.
  end.
  else do:
     run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("Не найдено информации по группам блюд для передачи на кассы маг&1")
                             , i-obj-code
                                          ).
  end.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При отсылке информации на кассы произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action6   as character no-undo .
  define variable v-printed6       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При отсылке информации на кассы произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + 'send-cd.txt')
    ,input  7
    ,output v-user-action6
    ,output v-printed6
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
end.
