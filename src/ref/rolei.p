block-level on error undo, throw.
/*

$Revision: 9d0726b3ce11, 2757, rls $
$Author: EShklyar $
$Date: Сб фев 20 15:59:21 2021 +0300 $
$Workfile: rolei.p $
$Archive: ref/rolei.p $

Заведение и редактирование ролей

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/17/06
Author: Bakhtadze Natalya
Creation date: 04/17/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode as character no-undo .
define input parameter p-psn-code like ub.person.psn-code no-undo .
define input parameter p-role as character no-undo .
define input parameter p-role-level as character no-undo .
define input-output parameter p-rid as recid no-undo .
define temp-table tt0-staff no-undo like ub.staff.
DEFINE INPUT-OUTPUT PARAMETER TABLE FOR tt0-staff.


define variable vss-revision    as character no-undo init "$Revision: 9d0726b3ce11, 2757, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Сб фев 20 15:59:21 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rolei.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/rolei.p $":U .
define variable vss-description as character no-undo init "Заведение и редактирование ролей".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/library.i }
{ gbl/gbclcode.i }
{ gbl/cur-time.i }

define variable ref-list as character no-undo .
define variable to-grp  as integer no-undo .
define variable v-level as character no-undo .
define variable v-db-num like ub.db.db-num no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-obj-type like ub.clients.obj-type no-undo .
define variable v-obj-code like ub.clients.obj-code no-undo .
define variable v-title as character no-undo .
define variable v-staff-code-label as character no-undo .
define variable v-staff-code-format as character no-undo .
define variable v-password-option as integer no-undo .
define variable v-password-label as character no-undo .
define variable v-password-format as character no-undo .
define variable v-notes as character no-undo .
define variable v-cashier-code as integer no-undo .
define variable v-seller-code as integer no-undo .
define variable v-password as character no-undo .
define variable v-staff-code as integer no-undo .
define variable ri as recid no-undo .
define variable v-ok as logical no-undo .
define variable glog as logical no-undo .
define variable v-id-string as character no-undo .
define variable v-work-place as character no-undo .
define variable v-omron as logical no-undo .
define variable v-ncr as logical no-undo .
define variable v-servis as logical no-undo .
define variable v-date-start as date no-undo .
define variable v-date-end as date no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .


define buffer buf_cli-grp for ub.cli-grp.
define buffer buf_clients for ub.clients.
define buffer tt-staff for tt0-staff.
define buffer buf_staff for ub.staff.
define buffer buf_cash-desk for ub.cash-desk.


do
on error undo, return error return-value
:
  CASE p-mode :
    when {&add-def} then do:
      if p-psn-code = 0 then do:
        run ref/cli-grps.w (
                      input parparentproc
                    , input "b-sel,b-mark"
                    , input-output ref-list ) .
        if ref-list <> "" then do:
          FIND buf_cli-grp where recid( buf_cli-grp ) = integer( ref-list ) .
          if can-find( FIRST ub.cli-grp where ub.cli-grp.upper-code = buf_cli-grp.node-code ) then do:
            message
            "Добавлять можно только в группы," skip
            "у которых нет подгрупп." skip
            "Выбирайте другую группу !" view-as alert-box WARNING .
            undo, return error .
          end.
          assign
          to-grp = buf_cli-grp.node-code
          .
          run ref/personi.w (
                         INPUT parparentproc
                        ,input {&add-def}
                        ,input 0
                        ,input to-grp
                        ,input p-role
                        ,input-output p-rid ) no-error .
          if error-status:error then return error return-value .
        end.
        else do:
          return.
        end.
      end. /*if p-psn-code = 0*/
      if p-psn-code = ? then do: /*выбираем из справочникаа физ лиц*/
        run ref/cli-all.w (
                         input parparentproc
                        ,input "b-sel"
                        ,input {&prs}
                        ,input {&all}
                        ,input {&current}
                        ,input ?
                        ,input ",,,,,,NO,,"
                        ,input "lock-cli-type":U
                        ,output ref-list).
        if ref-list = "" then return.
        ri = integer(entry(1, ref-list)) .
        FIND first buf_clients no-lock WHERE recid( buf_clients ) = ri  .
        if g#db-num > 0 then do:
          if p-role = {&role-cashier} then do:
            assign
            v-cashier-code = gbclcode-get-db-role (
                                                    input {&role-cashier}
                                                   ,input g#db-num
                                                   ,input buf_clients.obj-code
                                                   ,input ? /*p-date-start*/
                                                   ,output v-password)
            no-error .
            if v-cashier-code > 0 then do:
              message
              substitute("Данное физическое лицо уже является кассиром в БД &1!"  +
                         "Вы уверены, что хотите дать ему еще один код кассира?&1" +
                         "Это может привести к ошибкам при разборе чеков"
                       , g#db-num)
              view-as alert-box QUESTION buttons YES-NO update glog.
              if not glog then  undo, return.
            end.
          end.
          if p-role = {&role-seller} then do:
            assign
            v-seller-code = gbclcode-get-db-role ( input {&role-seller}
                                                  ,input g#db-num
                                                  ,input buf_clients.obj-code
                                                  ,input ? /*p-date-start*/
                                                  ,output v-password)
            no-error .
            if v-seller-code > 0 then do:
              message
              substitute("Данное физическое лицо уже является продавцом в БД &1!"  +
                         "Вы уверены, что хотите дать ему еще один код продавца?&1" +
                         "Это может привести к ошибкам при разборе чеков"
                       , g#db-num)
              view-as alert-box QUESTION buttons YES-NO update glog.
              if not glog then  undo, return.
            end.
          end. /*if p-role = {&role-seller}*/
        end. /*if g#db-num > 0*/
        assign
        p-psn-code = buf_clients.obj-code
        .
      end.
    end.
  END CASE.

  do
  on error undo, return error
  on stop undo, return error :
    if p-mode = {&update} then do:
      find first buf_staff exclusive-lock where
              recid(buf_staff) = p-rid.
    end.
    if p-mode = {&lookup} then do:
      find first buf_staff no-lock where
                recid(buf_staff) = p-rid.
    end.
  end.
  if not (p-mode = {&add-def}
          and
          p-psn-code = 0)
  or p-mode = {&update}
  or p-mode = ({&add-def} + {&comma-char} + 'temp') then do:
    assign
    v-db-num = (if p-mode = {&update}
                    or p-mode = {&lookup}
                    then buf_staff.db-num
                    else (if g#db-num = 0 then ? else g#db-num))
    .

    find first buf_cash-desk no-lock where
            buf_cash-desk.db-num = v-db-num
        and buf_cash-desk.pos-type = {&cd-type-omron-new} no-error.
    if available buf_cash-desk then do:
      v-omron = yes.
    end.
    find first buf_cash-desk no-lock where
            buf_cash-desk.db-num = v-db-num
        and buf_cash-desk.pos-type = {&cd-type-ncr-gm} no-error.
    if available buf_cash-desk then do:
      v-ncr = yes.
    end.
    find first buf_cash-desk no-lock where
            buf_cash-desk.db-num = v-db-num
        and buf_cash-desk.pos-type = {&cd-type-ncr-AS-R} no-error.
    if available buf_cash-desk then do:
      v-ncr = yes.
    end.
    run cur-time in this-procedure ( output v-today, output v-time).
    case p-role:
      when {&role-cashier} then do:
        assign
        v-staff-code = (if p-mode = {&lookup}
                        or p-mode = {&update}
                        then buf_staff.staff-code
                        else 0)
        v-level = {&role-level-db}
        v-host-code = 0
        v-obj-type = '':U
        v-obj-code = 0
        v-title = "Данные кассира"
        v-staff-code-label = "Код кассира"
        v-staff-code-format = (if v-omron = yes or v-ncr = yes then ">>>9" else ">>9")
        v-password-option = 2
        v-password-label = "Пароль кассира"
        v-password-format = "X(5)"
        v-notes = substitute("Внимание!&1Диапазон значений <КОДA КАССИРА> и <ПАРОЛЯ> различен для касс и POS разного типа&1"  +
                            "Перед вводом кода и пароля кассира проконсультируйтесь с Вашим администратором"
                            , {&new-line})
        v-password = (if p-mode = {&update}
                      or p-mode = {&lookup}
                      then  buf_staff.password
                      else '':U)
        v-date-start = (if p-mode = {&update}
                      or p-mode = {&lookup}
                      then  buf_staff.date-start
                      else v-today + 1)
        v-date-end   = (if p-mode = {&update}
                      or p-mode = {&lookup}
                      then  buf_staff.date-end
                      else {&end-of-age})
        .
      end.
      when {&role-seller} then do:
        assign
        v-staff-code = (if p-mode = {&lookup}
                        or p-mode = {&update}
                        then buf_staff.staff-code
                        else 0)
        v-level = {&role-level-db}
        v-host-code = 0
        v-obj-type = '':U
        v-obj-code = 0
        v-title = "Данные продавца (официанта)"
        v-staff-code-label = "Код продавца (официанта)"
        v-staff-code-format = (if v-omron = yes or v-ncr = yes then ">>>9" else ">>9")
        v-password-option = 1
        v-password-label = "Пароль продавца (официанта)"
        v-password-format = "X(3)"
        v-notes = substitute("Внимание!&1Диапазон значений <КОДA ПРОДАВЦА> и <ПАРОЛЯ> различен для касс и POS разного типа&1"  +
                            "Пароль ПРОДАВЦА для некоторых касс и POS не требуется&1" +
                            "Перед вводом кода и пароля продавца (официанта) проконсультируйтесь с Вашим администратором&1"
                            , {&new-line})
        v-password = (if p-mode = {&update}
                      or p-mode = {&lookup}
                      then  buf_staff.password
                      else '':U)
        v-date-start = (if p-mode = {&update}
                      or p-mode = {&lookup}
                      then  buf_staff.date-start
                      else v-today + 1)
        v-date-end   = (if p-mode = {&update}
                      or p-mode = {&lookup}
                      then  buf_staff.date-end
                      else {&end-of-age})
        .
      end.
      otherwise do:
        assign
        v-host-code =  (if p-mode = {&update}
                       or p-mode = {&lookup}
                       then buf_staff.host-code
                       else 0)
        v-obj-type =  (if p-mode = {&update}
                      or p-mode = {&lookup}
                      then buf_staff.obj-type
                      else '':U)
        v-obj-code =  (if p-mode = {&update}
                      or p-mode = {&lookup}
                      then buf_staff.obj-code
                      else 0)
          .
      end.
    END CASE.
    run ref/staffi.w (
                     INPUT parparentproc
                    ,INPUT this-procedure /*p-parent-handle */
                    ,input p-role
                    ,INPUT p-mode
                    ,input v-level
                    ,INPUT-OUTPUT v-db-num
                    ,INPUT-OUTPUT v-host-code
                    ,INPUT-OUTPUT v-obj-type
                    ,INPUT-OUTPUT v-obj-code
                    ,INPUT v-title
                    ,INPUT v-staff-code-label
                    ,INPUT v-staff-code-format
                    ,INPUT v-password-option
                    ,INPUT v-password-label
                    ,INPUT v-password-format
                    ,INPUT v-notes
                    ,INPUT-OUTPUT v-staff-code
                    ,INPUT-OUTPUT v-password
                    ,input-output v-date-start
                    ,input-output v-date-end
                    ,OUTPUT v-ok
                    ) no-error.
    if not v-ok then undo, return.
    if p-mode = {&update}
    or (p-mode = {&add-def} and p-psn-code > 0)
    then do:
      run ref/staff01.p (
                     input-output p-rid
                    ,input p-mode
                    ,input no /*p-silent*/
                    ,input p-role
                    ,input v-staff-code
                    ,input p-psn-code
                    ,input v-level
                    ,input v-date-start
                    ,input v-date-end
                    ,input v-db-num
                    ,input v-host-code
                    ,input v-obj-type
                    ,input v-obj-code
                    ,input (if p-mode = {&update} then buf_staff.work-place else v-work-place)
                    ,input v-password) no-error .
      if error-status:error then do:
&scop role-code p-role
        message
        substitute("Ошибка при сохранении записи &1&2&3&2&4"
                   , {&role-name}
                   , {&new-line}
                   , error-status:get-message(1)
                   , return-value )
        view-as alert-box error .
        undo, return error return-value .
      end.
    end.
    if p-mode = {&add-def} + {&comma-char} + 'temp':U then do:
       CASE v-level:
         when {&role-level-db} then do:
            assign
            v-work-place = string(v-db-num, '99999').
         end.
         when {&role-level-firm} then do:
            assign
            v-work-place = string(v-host-code, '99999').
         end.
         when {&role-level-object} then do:
            assign
            v-work-place = v-obj-type + string(v-obj-code, '999999999').
         end.
       END CASE.
       /*
       run cur-time in this-procedure ( output v-today, output v-time).
       v-date-start = v-today + 1.
       */
       find first tt-staff where
                  tt-staff.role = p-role
             and  tt-staff.role-level = p-role-level
             and  tt-staff.work-place = v-work-place
             and tt-staff.staff-code  = v-staff-code
             and tt-staff.date-start  = v-date-start  no-error.
      if not available tt-staff then do:
        create tt-staff.
        assign
        tt-staff.db-num     = v-db-num
        tt-staff.role       = p-role
        tt-staff.role-level = p-role-level
        tt-staff.work-place = v-work-place
        tt-staff.staff-code  = v-staff-code
        tt-staff.psn-code = p-psn-code
        tt-staff.date-start = v-date-start
        .
      end.
      tt-staff.password = v-password.
    end.
  end. /*if not (p-mode = {&add-def}*/
end. /*doe*/