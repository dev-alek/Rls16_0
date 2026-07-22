/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Пересылка кассиров на кассу - пускальник

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/09/05
Author: Bakhtadze Natalya
Creation date: 09/09/05

*/
block-level on error undo, throw.

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .

/*
p-parameter включает

define input parameter i-obj-code like shop.obj-code no-undo.
define input parameter mode as char no-undo .
*/

/*"U' "D" "R" - справочник*/
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "пересылка кассиров на кассу - пускальник".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ str/defc-csh.i "NEW SHARED" }
{ cmp/stf-list.i }
{ gbl/gbclcode.i }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }


define variable choice as integer no-undo.
define variable cli-list  as character no-undo.
define variable kk as integer no-undo.
define variable callpoint as char no-undo.
define variable glog as logical no-undo .
define variable log-file-name as character no-undo init "send-cd.txt".
define variable v-view-log as logical no-undo .

define variable i-obj-code like ub.clients.obj-code no-undo.
define variable mode     as   character no-undo.
define variable v-work-place as character no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer buf_clients for ub.clients.
define buffer buf_staff for ub.staff.
assign
i-obj-code = integer(entry(1, p-parameter, {&delim-par}))
mode = entry(2, p-parameter, {&delim-par})
no-error
.
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2&3"
                         , p-parameter
                         , {&new-line}
                         , error-status:get-message(1)
                         )).
  v-view-log = yes.
  undo, return error .
end .

{ gbl/getcntxt.i get }

assign
callpoint = mode.
mode = if mode = "R" then "U" else mode.
for each cash-cash:
  delete cash-cash.
end.
FIND FIRST ub.cash-desk NO-LOCK WHERE
           ub.cash-desk.db-num = g#db-num
           AND ub.cash-desk.obj-code = i-obj-code
           and
           (ub.cash-desk.pos-type = {&cd-type-ibm}
           or
           ub.cash-desk.pos-type = {&cd-type-ibm-xml}) No-error.
IF not avail(ub.cash-desk) then do:
  if callpoint <> "R" then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!&1 кассиров реализуется только для касс &1 &2"
                              , (if mode = "U" then "Передача" else "Удаление")
                              , {&cd-type-ibm}
                              , {&cd-type-ibm-xml}
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
      'actn_cashdesk-cashiers_update':U
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
  run gbl/d-askw.w (input "Выбор кассиров для пересылки",
              input ( (if mode = "U"
                        then "Переслать на кассу"
                        else "Удалить из кассы" ) +
                        if g#db-num = 0
                        then
                        {&new-line} + "информацию о кассирах"
                        else
                        {&new-line} + "информацию о кассирах, заведенную в ГБД и текущей БД"
                        ),
              input "|",
              input "Все  имеющиеся в базе|Выборочно|Отказ от пересылки",
              input "||",
              input 1,
              input 3,
              output choice).
  run cur-time in this-procedure ( output v-today, output v-time).
  CASE choice :
    when 3 then  return .
    when 2 then do:
      if callpoint = "R" then do:
        FOR EACH stf-list No-LOCK,
            FIRST buf_clients no-lock WHERE
                  buf_clients.obj-type = {&prs}
              AND buf_clients.obj-code = stf-list.psn-code:
          FIND FIRST cash-cash WHERE
                      cash-cash.cash-code = stf-list.staff-code NO-ERROR.
          if not avail cash-cash then do:
            create cash-cash.
            assign
            cash-cash.cash-code = stf-list.staff-code
            cash-cash.cash-name = buf_clients.obj-name
            cash-cash.psn-code  = stf-list.psn-code
            cash-cash.stts =  (if stf-list.date-end < v-today then 1 else 0)
            cash-cash.psswd = stf-list.password
            .
          end.    /*if not avail cash-cash*/
        END. /*FOR EACH stf-list*/
      end. /*"R"*/
      else do:
        run ref/staffs.w (
                        input parparentproc
                      , input "b-sel,b-mark"
                      , input {&role-cashier}
                      , input g#db-num
                      , input 0
                      , output cli-list ) .
        if cli-list <> "" then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("&1 магазина &2: выборочная пересылка кассиров"
                                , (if mode = "U" then "Пересылка на кассы" else "Удаление с касс" )
                                , i-obj-code)
              ).
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("Подготовка данных")
                                              ).
          DO kk = 1 TO num-entries( cli-list ) :
            FIND FIRST buf_staff NO-LOCK WHERE
                 recid(buf_staff) = integer(ENTRY(kk, cli-list)) NO-ERROR.
            IF AVAIL buf_staff then do:
              FIND FIRST buf_clients NO-LOCK WHERE
                       buf_clients.obj-type = {&prs}
                  AND buf_clients.obj-code = buf_staff.psn-code NO-ERROR.
              IF avail buf_clients then do:
                FIND FIRST cash-cash WHERE
                          cash-cash.cash-code = buf_staff.staff-code NO-ERROR.
                if not avail cash-cash then do:
                create cash-cash.
                assign
                cash-cash.cash-code = buf_staff.staff-code
                cash-cash.psn-code  = buf_staff.psn-code
                cash-cash.cash-name = buf_clients.obj-name
                cash-cash.stts = (if buf_staff.date-end < v-today then 1 else 0)
                cash-cash.psswd = buf_staff.password
                .
                release cash-cash.
              end.    /*if not avail cash-cash*/
            END. /*IF AVAIL clients*/
          end. /*if avail buf_staff*/
        END. /*DO kk*/
      end.
      else /*cli-list = ""*/ do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("Не определен список кассиров для пересылки")
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
          , input substitute("&1 магазина &2: пересылка всех имеющихся в БД кассиров"
                            , (if mode = "U" then "Пересылка на кассы" else "Удаление с касс" )
                            , i-obj-code)
          ).
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("Подготовка данных")
                                          ).
    v-work-place =  gbclcode-get-work-place  (
                                                input {&role-cashier}
                                               ,input {&role-level-db}
                                               ,input g#db-num
                                               ,input 0
                                               ,input '':U
                                               ,input 0).

      FOR EACH buf_staff WHERE
            /*   buf_staff.role = {&role-cashier}
           and buf_staff.role-level = {&role-level-db}
           and buf_staff.work-place = v-work-place
           and buf_staff.date-end >= v-today*/ ,
        FIRST buf_clients no-lock WHERE
              buf_clients.obj-type = {&prs}
         AND  buf_clients.obj-code = buf_staff.psn-code :
        FIND FIRST cash-cash WHERE
                 cash-cash.cash-code = BUF_STAFF.staff-code NO-ERROR.
        if not avail cash-cash then do:
          create cash-cash.
          assign
          cash-cash.cash-code = buf_staff.staff-code
          cash-cash.cash-name = buf_clients.obj-name
          cash-cash.stts = (if buf_staff.date-end < v-today then 1 else 0)
          cash-cash.psn-code = buf_staff.psn-code
          cash-cash.psswd = buf_staff.password
          .
        end.
      END.
    end.
    when 4 then do:
      if mode = "D" 
      then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("&1 магазина &2 всех кассиров"
                            , (if mode = "U" then "Пересылка на кассы" else "Удаление с касс" )
                            , i-obj-code)
          ).
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("Подготовка данных")
                                          ).
    
          create cash-cash.
          assign
          cash-cash.cash-code = ?
          
          no-error.
          validate cash-cash no-error.
          if error-status:error
          then
            message error-status:get-message(1)
            view-as alert-box.
       end.
    end.
  END CASE.
  if can-find(first cash-cash) then do:
      run str/send-csh.p (
                       input parparentproc
                       ,input p-parent-handle
                       ,input p-log-handle
                       ,input (string(i-obj-code) + {&delim-par} + mode + {&delim-par} + "no":U)) no-error.
      if not error-status:error then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("&1 маг&2 &3"
                                , (if mode = "U"
                                    then "Передача кассиров на кассы"
                                    else "Удаление кассиров с кассы")
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
          , input substitute("Не найдено информации по кассирам для передачи на кассы маг&1"
                             , i-obj-code)
                                             ).
  end.
end.

define variable v-disp-msg as character no-undo .
catch exAppErrors as class Progress.Lang.AppError :
  v-disp-msg = exAppErrors:ReturnValue .
  if v-disp-msg > "" then . else do :
    v-disp-msg = exAppErrors:GetMessage(1) .
    if v-disp-msg > "" then . else v-disp-msg = "Ошибка A-sendcash" .
  end .
  run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input v-disp-msg
  ).
  v-view-log = yes .
end catch .
catch exProErrors as class Progress.Lang.ProError :
  v-disp-msg = exAppErrors:GetMessage(1) .
  if v-disp-msg > "" then . else v-disp-msg = "Ошибка P-sendcash" .
  run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input v-disp-msg
  ).
  v-view-log = yes .
end catch .
catch exAnyErrors as class Progress.Lang.Error:
  v-disp-msg = "Ошибка U-sendcash" .
  run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input v-disp-msg
  ).
  v-view-log = yes .
end catch .
finally :
    run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("&1", {&new-line})
    ).
  define variable v-save-file-name as character no-undo .
  
  v-save-file-name = substitute("&1send-cd.log", ibs.th.gbl.gbl-inipar:logDir) .
  
  // где смотрят файл и где его удаляют - не известно.
  // поэтому здесь мы его только копируем  
  OS-APPEND value(log-file-name) value(v-save-file-name).
end finally .
