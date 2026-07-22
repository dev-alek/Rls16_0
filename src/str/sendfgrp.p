block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: sendfgrp.p $
$Archive: str/sendfgrp.p $

Пересылка групп блюд на кассу - пускальник

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/09/05
Author: Bakhtadze Natalya
Creation date: 09/09/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .

/*
p-parameter включает

def input parameter i-obj-code like shop.obj-code no-undo.
def input parameter mode as char no-undo .
/*"U' "D" "R" - справочник*/
*/


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sendfgrp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/sendfgrp.p $":U .
define variable vss-description as character no-undo init "пересылка групп блюд на кассу - пускальник".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ str/defc-fgr.i "SHARED" }
{ gbl/getcntxt.i def }

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
i-obj-code = integer(entry(1, p-parameter, {&delim-par}))
mode = entry(2, p-parameter, {&delim-par})
no-error
.
if error-status:error then return error.

{ gbl/getcntxt.i get }

assign
callpoint = mode.
mode = if mode = "R" then "U" else mode.
for each cash-fgrp:
    delete cash-fgrp.
end.

FIND FIRST ub.cash-desk NO-LOCK WHERE
           ub.cash-desk.db-num = g#db-num AND
           ub.cash-desk.pos-type = {&cd-type-MAGIA-XML}
            No-error.
IF not avail(ub.cash-desk) then do:
  if callpoint <> "R" then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!&1 групп блюд реализуется только для касс &2"
                              , (if mode = "U" then "Передача" else "Удаление")
                              , {&cd-type-MAGIA-XML}
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
    { gbl/hostcode.i
      {&shop}
      abs(i-obj-code)
      v-host-code
    }
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_cashdesk-goods-groups_update':U
      {&cntxt-object}
      v-host-code
      {&shop}
      abs(i-obj-code)
      0
      0
      0
      true
      glog
    }
  end.
  if NOT glog then return .
  glog = yes.
  if callpoint = "R" then choice = 2.
  else
  run gbl/d-askw.w (input "Выбор групп блюд для пересылки",
              input ( (if mode = "U" then "Переслать на кассу"
                        else "Удалить из кассы" ) +
                        {&new-line} + "информацию о группах блюд по объекту"
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
        /*все уже создано*/
      end. /*"R"*/
      else do:
        run ref/fbrggrp.w (
              input parparentproc
            , input {&shop}
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
                        upper_fbr-gds-grp.obj-type = {&shop}
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
                cash-fgrp.stts              = integer({&current-status-int})
                .
                release cash-fgrp.
              end.    /*if not avail cash-fgrp*/
            END.
          END. /*do*/
        end.
        else /*v-recid-list = ""*/ do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("Не определен список групп блюд для пересылки")
                                              ).
          return .
        end.
      end. /*not "R"*/
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
              buf_fbr-gds-grp.obj-type = {&shop}
          AND buf_fbr-gds-grp.obj-code = i-obj-code:
        find first upper_fbr-gds-grp no-lock where
                  upper_fbr-gds-grp.obj-type = {&shop}
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
          cash-fgrp.stts              = integer({&current-status-int})
          .
          release cash-fgrp.
        end.    /*if not avail cash-fgrp*/
      END.
    end.
  END CASE.
  if can-find(first cash-fgrp ) then do:
    run str/send-fgr.p (
                      input parparentproc
                      ,input p-parent-handle
                      ,input p-log-handle
                      ,input (string(i-obj-code) + {&delim-par} + mode + {&delim-par} + "no":U) ) no-error.
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
  { str/cdviewlg.i
  "'!!!При отсылке информации на кассы произошли ошибки!!!'"
  "'send-cd.txt'" }
end.