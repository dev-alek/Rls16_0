block-level on error undo, throw.
/*

$Revision: a4b26bb1ecde, 241, rls $
$Author: SSlivenko $
$Date: Mon Aug 31 16:27:00 2015 +0400 $
$Workfile: sendstaf.p $
$Archive: str/sendstaf.p $

Пересылка персонала - для АРМ ресторан

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/04/03
Author: Bakhtadze Natalya
Creation date: 12/04/03

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .

/*
p-parameter включает
/*эти параметры не имеют смысла тут
МАГИЯ работает как кассовый сервер на БД
а подразеделния одинаковы для всей БД
но ПУСТЬ БУДУТ!!*/
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
DEFINE INPUT PARAMETER action as char no-undo.
/*"U' "D" "R" - справочник*/

*/

define variable vss-revision    as character no-undo init "$Revision: a4b26bb1ecde, 241, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Mon Aug 31 16:27:00 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sendstaf.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/sendstaf.p $":U .
define variable vss-description as character no-undo init "Пересылка персонала - для АРМ ресторан".
{ cmp/vssrevis.i }


{ cmp/trg-def.i }
define variable p-obj-type like ub.clients.obj-type no-undo .
define variable p-obj-code like ub.clients.obj-code no-undo .
define variable action as char no-undo.




{ str/defc-csh.i "NEW SHARED" psn-code }
{ cmp/stf-list.i }
{ gbl/clntattr.i }
{ gbl/gbclcode.i }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

define variable choice as integer no-undo.
define variable cli-list  as character no-undo.
define variable kk        as integer      no-undo.
define variable callpoint as character no-undo.
/*вспомогат*/
define variable dops as character no-undo format "X(250)".
define variable dopst as character no-undo format "X(1)".
define variable glog as logical no-undo .
define variable log-file-name as character no-undo init "send-cd.txt".
define variable v-view-log as logical no-undo .
define variable v-value as character no-undo .
define variable v-type as character no-undo .
define variable v-work-place as character no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-host-code as integer no-undo .

define buffer buf_clients for ub.clients.
define buffer buf_staff for ub.staff.

&scop get-superviser-flag run clntattr-value  in this-procedure (             ~
                                        input  ~{&prs~}                       ~
                                        ,input  cash-cash.psn-code            ~
                                       ,input ~{&attr-is-superviser~}         ~
                                       ,output v-value                        ~
                                       ,output v-type     ) no-error .        ~
if not error-status:error then do:                                            ~
  assign                                                                      ~
  cash-cash.superviser = (if v-value = "yes" then 1 else 0)                   ~
  .                                                                           ~
end


assign
p-obj-type = entry(1, p-parameter, {&delim-par})
p-obj-code = integer(entry(2, p-parameter, {&delim-par}))
action = entry(3, p-parameter, {&delim-par})
no-error
.
if error-status:error then return error.



assign
callpoint = action.
action = if action = "R" then "U" else action.
for each cash-cash:
    delete cash-cash.
end.
FIND FIRST ub.cash-desk NO-LOCK WHERE
           ub.cash-desk.db-num = g#db-num
      AND  ub.cash-desk.pos-type = {&cd-type-MAGIA-XML}
            No-error.
IF not avail(ub.cash-desk) then do:
  if callpoint <> "R" then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!&1 персонала реализуется только для POS"
                              , (if action = "U" then "Передача" else "Удаление")
                              , {&cd-type-MAGIA-XML}
                            )
                                            ).
     return.
  end.
end.
if callpoint = "R" then glog = yes.
else do:
  if not g#news then do:
    { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
    { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_cashdesk-restaurant_work':U
    {&cntxt-firm}
    v-host-code
    '':U
    0
    0
    0
    0
    true
    glog
    }
    if NOT glog then return .
  end.
end.

glog = yes.
if callpoint = "R" then choice = 2.
else
run gbl/d-askw.w (input "Выбор персонала для пересылки",
            input ( (if action = "U" then "Переслать на кассу"
                      else "Удалить (заблокировать)" ) +
                      if g#db-num = 0
                      then
                      {&new-line} + "информацию по персоналу"
                      else
                      {&new-line} + "информацию по персоналу, заведенную в ГБД и текущей БД"
                      ),
            input "|",
            input "Официанты и кассиры-Все имеющиеся в базе|Официанты-Выборочно|Кассиры-Выборочно|Отказ от пересылки",
            input "|||",
            input 1,
            input 4,
            output choice).
run cur-time in this-procedure ( output v-today, output v-time).
CASE choice :
  when 4 then
      return .
  when 3
  or
  when 2
  then do:
    if callpoint = "R" then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("Подготовка данных")
                                          ).
      FOR EACH stf-list No-LOCK,
        first buf_clients no-lock where
            buf_clients.obj-type = {&prs}
        and buf_clients.obj-code = stf-list.psn-code:
        FIND FIRST cash-cash WHERE
                    cash-cash.psn-code = stf-list.psn-code NO-ERROR.
        if not avail cash-cash then do:
          create cash-cash.
          assign
          cash-cash.psn-code =  stf-list.psn-code
          cash-cash.cash-code = (if stf-list.role = {&role-cashier} then stf-list.staff-code else 0 )
          cash-cash.slr-code =  (if stf-list.role = {&role-seller} then stf-list.staff-code else 0 )
          cash-cash.cash-name = buf_clients.obj-name
          cash-cash.stts = (if stf-list.date-end < v-today then 1 else 0)
          cash-cash.psswd = (if stf-list.role = {&role-cashier} then stf-list.password else ? )
          cash-cash.s-psswd = (if stf-list.role = {&role-seller} then stf-list.password else ? )
          /* todo */
          cash-cash.ident-type = 1 /*ключ ТМ*/
          .
          {&get-superviser-flag}.
          release cash-cash.
        end.    /*if not avail cash-cash*/
      END. /*FOR EACH stf-list*/
    end. /*"R"*/
    else do:
      run ref/staffs.w (
                       input parparentproc
                     , input "b-sel,b-mark"
                     , input (if choice = 3 then {&role-cashier} else {&role-seller})
                     , input g#db-num
                     , input 0
                     , output cli-list ) .
      if cli-list <> "" then do:
&scop role-code (if choice = 3 then {&role-cashier} else {&role-seller})
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("&1 магазина &2: &3: выборочная пересылка"
                              , (if action = "U" then "Пересылка на кассы" else "Удаление с касс" )
                              , p-obj-code
                              , {&role-name}
                              )
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
                          cash-cash.psn-code = buf_staff.psn-code NO-ERROR.
              if not avail cash-cash then do:
                create cash-cash.
                assign
                cash-cash.psn-code = buf_staff.psn-code
                cash-cash.cash-code = (if buf_staff.role = {&role-cashier} then buf_staff.staff-code else 0)
                cash-cash.slr-code = (if buf_staff.role = {&role-seller} then buf_staff.staff-code else 0)
                cash-cash.cash-name = buf_clients.obj-name
                cash-cash.stts = (if buf_staff.date-end < v-today then 1 else 0)
                cash-cash.psswd = (if buf_staff.role = {&role-cashier} then buf_staff.password else ? )
                cash-cash.s-psswd = (if buf_staff.role = {&role-seller} then buf_staff.password else ? )
                /* todo */
                cash-cash.ident-type = 1 /*ключ ТМ*/
                .
                {&get-superviser-flag}.
                release cash-cash.
              end.    /*if not avail cash-cash*/
            END. /*IF avail buf_clients*/
          END. /*IF AVAIL buf_staff*/
        END. /*DO kk*/
      end.
      else /*cli-list = ""*/ do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("&1: Не определен список для пересылки", {&role-name})
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
        , input substitute("Подготовка данных")
                                                  ).
    assign
    v-work-place =  gbclcode-get-work-place  (
                                                input {&role-cashier}
                                               ,input {&role-level-db}
                                               ,input g#db-num
                                               ,input 0
                                               ,input '':U
                                               ,input 0).
    for each buf_staff no-lock where
            buf_staff.role = {&role-cashier}
        and buf_staff.role-leve = {&role-level-db}
        and buf_staff.work-place = v-work-place
        and buf_staff.date-end >= v-today,
      FIRST buf_clients WHERE
            buf_clients.obj-type = {&prs}
        AND buf_clients.obj-code = buf_staff.psn-code:
      FIND FIRST cash-cash WHERE
                  cash-cash.psn-code = buf_staff.psn-code NO-ERROR.
      if not avail cash-cash then do:
        create cash-cash.
        assign
        cash-cash.psn-code = buf_staff.psn-code
        cash-cash.cash-name = buf_clients.obj-name
        cash-cash.stts = buf_clients.stts
        cash-cash.cash-code = buf_staff.staff-code
        cash-cash.psswd = buf_staff.password
        cash-cash.stts = (if buf_staff.date-end < v-today then 1 else 0)
        /* todo */
        cash-cash.ident-type = 1 /*ключ ТМ*/
        .
        {&get-superviser-flag}.
        release cash-cash.
      end.
    END.
    v-work-place =  gbclcode-get-work-place  (
                                                input {&role-seller}
                                               ,input {&role-level-db}
                                               ,input g#db-num
                                               ,input 0
                                               ,input '':U
                                               ,input 0).
    for each buf_staff no-lock where
            buf_staff.role = {&role-seller}
        and buf_staff.role-level = {&role-level-db}
        and buf_staff.work-place = v-work-place
        and buf_staff.date-end >= v-today ,
      FIRST buf_clients WHERE
            buf_clients.obj-type = {&prs}
        AND buf_clients.obj-code = buf_staff.psn-code:
      FIND FIRST cash-cash WHERE
                  cash-cash.psn-code = buf_staff.psn-code NO-ERROR.
      if not avail cash-cash then do:
        create cash-cash.
        assign
        cash-cash.psn-code = buf_staff.psn-code
        cash-cash.cash-name = buf_clients.obj-name
        cash-cash.slr-code = buf_staff.staff-code
        cash-cash.s-psswd = buf_staff.password
        cash-cash.stts = (if buf_staff.date-end < v-today then 1 else 0)
        /* todo */
        cash-cash.ident-type = 1 /*ключ ТМ*/
        .
        {&get-superviser-flag}.
        release cash-cash.
      end.
      else do:
        assign
        cash-cash.slr-code = buf_staff.staff-code
        cash-cash.s-psswd = buf_staff.password
        cash-cash.stts = (if buf_staff.date-end < v-today or cash-cash.stts = 1 then 1 else 0)
        /* todo */
        cash-cash.ident-type = 1 /*ключ ТМ*/
        .
        {&get-superviser-flag}.
        release cash-cash.
      end.
    END.
  end.
END CASE.
if can-find(first cash-cash ) then do:
  run str/send-stf.p (
                  input parparentproc
                 ,input p-parent-handle
                 ,input p-log-handle
                 ,input (p-obj-type + {&delim-par} + string(p-obj-code) + {&delim-par} + action +
                         {&delim-par} + "no":U)) no-error.
  if not error-status:error then do:
    run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("&1 маг&2 &3"
                              , (if action = "U"
                                then "Передача персонала на кассы"
                                else "Удаление перасонала с касс")
                              , p-obj-code
                              , (if action = "U"
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
      , input substitute("Не найдено информации по персоналу для передачи на кассы маг&1"
                          , p-obj-code )
                          ).
end.
{ str/cdviewlg.i
"'!!!При отсылке информации на кассы произошли ошибки!!!'"
"'send-cd.txt'" }