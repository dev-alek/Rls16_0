block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: staff01.p $
$Archive: ref/staff01.p $

Сохранение изменений в карточке персонала

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/23/06
Author: Bakhtadze Natalya
Creation date: 04/23/06

Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!

*/

define input-output parameter p-rid      as recid no-undo.
define input parameter p-mode            as character no-undo .
define input parameter p-silent          as logical no-undo .  /*может быть yes  c return-value и с руганью на экран */
define input parameter p-role            as character no-undo .
define input parameter p-staff-code      as integer no-undo .
define input parameter p-psn-code        like  ub.person.psn-code      no-undo .
define input parameter p-level           as character no-undo .
define input parameter p-date-start      like ub.staff.date-start no-undo .
define input parameter p-date-end        like ub.staff.date-end no-undo .
define input parameter p-db-num          like ub.db.db-num no-undo .
define input parameter p-host-code       like ub.sysconf.host-code no-undo .
define input parameter p-obj-type        like ub.clients.obj-type no-undo .
define input parameter p-obj-code        like ub.clients.obj-code no-undo .
define input parameter p-work-place      as character no-undo .

define input parameter p-password        as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: staff01.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/staff01.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в карточке персонала".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/waitfram.i }
{ gbl/cur-time.i }
{ gbl/gbclcode.i }

define variable v-curr-db-num like ub.db.db-num no-undo .
define variable v-err-mess as character no-undo .
define variable v-role-name as character no-undo .
define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-obj-type like ub.clients.obj-type no-undo .
define variable v-obj-code like ub.clients.obj-code no-undo .
define variable v-role-level as character no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-work-place as character no-undo .
define variable v-no-uniq as logical no-undo .

define buffer buf_staff for ub.staff.
define buffer main_staff for ub.staff .
define temp-table tt-staff no-undo like ub.staff.


if p-mode <> {&add-def}
AND p-mode <> {&update}
and p-mode <> {&deletion}
then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр p-mode" p-mode
  view-as alert-box error .
  return error '':u.
end.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  { gbl/curdbnum.i v-curr-db-num }

  if lookup( p-role, {&role-list}) = 0 then do:
    assign
    v-err-mess = substitute("Неизвестная роль персонала &1", p-role).
    run err-mess in this-procedure ( input-output v-err-mess ).
    undo main-block, return error '':U.
  end.
&scop role-code p-role
      assign
      v-role-name = {&role-name}
      no-error.

  if v-curr-db-num  <> 0
  and v-curr-db-num <> p-db-num
  and p-level = {&role-level-db}  then do:
    assign
    v-err-mess = substitute("Нельзя изменять запись &1 в чужой БД&2БД для &1 - &3, текущая БД &4"
                           , p-role
                           , {&new-line}
                           , v-role-name
                           , p-db-num
                           , v-curr-db-num
                           ).
    run err-mess in this-procedure ( input-output v-err-mess ).
    undo main-block, return error '':U.
  end.
  if p-staff-code = 0
  or p-staff-code = ? then do:
    assign
    v-err-mess = substitute("Код персонала для роли типа &1 должен быть > 0 "
                            , v-role-name).
    run err-mess in this-procedure ( input-output v-err-mess ).
    undo main-block, return error (if p-silent then v-err-mess else "staff-code":U).
  end.
  if p-date-start > p-date-end
  or (p-mode = {&deletion}
     and p-date-start > v-today
     )
  then do:
    assign
    v-err-mess = substitute("Дата начала работы &1 в данной должности должна быть меньше даты окончания работы &1 "
                            , string(p-date-start, "99/99/9999")
                            , string(p-date-end, "99/99/9999")
                            ).
    run err-mess in this-procedure ( input-output v-err-mess ).
    undo main-block, return error (if p-silent then v-err-mess else "date-start":U).

  end.


  if p-mode = {&add-def} then do:
    v-work-place = gbclcode-get-work-place (
                                             input p-role
                                            ,input p-level
                                            ,input p-db-num
                                            ,input p-host-code
                                            ,input p-obj-type
                                            ,input p-obj-code
                                               ) .
  end.
  else do:
    FIND FIRST main_staff EXCLUSIVE-lock where
              recid(main_staff) = p-rid No-ERROR.
    if not available main_staff then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись ПЕРСОНАЛА - p-rid" p-rid
      view-as alert-box error .
      undo main-block, return error '':u.
    end.
  end.
  if p-mode = {&add-def} then do:
    if not available tt-staff then create tt-staff.
    ASSIGN
    tt-staff.role       = p-role
    tt-staff.role-level = p-level
    tt-staff.work-place = v-work-place
    tt-staff.staff-code = p-staff-code
    tt-staff.date-start = p-date-start
    tt-staff.date-end   = p-date-end
    .
    { trg/staffunq.i tt-staff buf_staff "(p-mode = {&add-def})" v-no-uniq v-err-mess }
  end.
  else do:
    { trg/staffunq.i main_staff buf_staff "(p-mode = {&add-def})" v-no-uniq v-err-mess }
  end.
  if v-no-uniq then do:
    undo main-block, return error v-err-mess.
  end.
  if p-mode = {&add-def} then do:
    create main_staff.
    assign
    main_staff.role = p-role
    main_staff.role-level = p-level
    main_staff.work-place = v-work-place
    main_staff.date-start = p-date-start
    main_staff.staff-code = p-staff-code
    main_staff.db-num = p-db-num
    main_staff.host-code = p-host-code
    main_staff.obj-type = p-obj-type
    main_staff.obj-code = p-obj-code
    main_staff.obj-code = p-obj-code
    p-rid = recid(main_staff)
    .
  end.
  if p-mode = {&update} then do:
    v-work-place = p-work-place.
    if p-mode <> {&deletion}
    then do:
      if main_staff.psn-code <>  p-psn-code
      or main_staff.role <>  p-role
      or main_staff.role-level <>  p-level
      or main_staff.work-place <>  v-work-place
      or main_staff.date-start <>  p-date-start
      or main_staff.db-num     <>  p-db-num
      or main_staff.host-code  <>  p-host-code
      or main_staff.obj-type   <>  p-obj-type
      or main_staff.obj-code   <>  p-obj-code
      then do:
        message

        vss-workfile vss-revision vss-description skip
        "Для уже имеющейся записи нельзя изменить"
        "код физ.лица и/или" skip
        "роль" skip
        "место работы и/или" skip
        "дату начала работы в данной роли и/или" skip
        "№ БД, код фирмы, объект" skip
        view-as alert-box ERROR.
        undo main-block, return error '':U.
      end.
    end.
  end.
  if p-mode = {&deletion} then do:
    run cur-time in this-procedure ( output v-today, output v-time).
    assign
    main_staff.date-end = v-today
    .
  end.
  else do:
    assign
    main_staff.psn-code = p-psn-code
    main_staff.password = p-password
    main_staff.date-end = p-date-end
    .
  end.
  release main_staff no-error.
  if error-status:error then do:
    message
    vss-workfile vss-revision vss-description skip
    "Ошибка при сохранении записи ПЕРСОНАЛА" skip
    ERROR-STATUS:GET-NUMBER(1) skip
    return-value
    view-as alert-box .
    undo main-block, return error "":U.
  end.
end. /*doe*/

PROCEDURE err-mess:
DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.

  CASE p-silent:
    when yes then do:

      p-mess = substitute("&1 чел&2: &3", v-role-name, p-psn-code,  p-mess).
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.