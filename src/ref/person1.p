block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: person1.p $
$Archive: ref/person1.p $

Сохранение изменений в карточке человека

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/10/03
Author: Bakhtadze Natalya
Creation date: 12/10/03

Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!

*/

define input parameter parparentproc     as widget-handle no-undo .
define input parameter p-parent-handle   as handle no-undo .
define input-output parameter p-rid      as recid no-undo.
define input parameter p-mode            as character no-undo .
define input parameter p-callpoint       as character no-undo .
define input parameter p-silent          as logical no-undo .  /*может быть yes  с выводом в файл no с руганью на экран и ? c return-value*/
define input parameter p-psn-code        as integer no-undo .
define input parameter p-stts            as integer no-undo .
define input parameter p-obj-name        as character no-undo .
define input parameter p-lim-kr          as decimal no-undo .
define input parameter p-PS              as character no-undo .
define input parameter p-grp-code        as integer no-undo .
define input parameter p-address         as character no-undo .
define input parameter p-city            as character no-undo .
define input parameter p-date-birth      as date      no-undo .
define input parameter p-e-mail          as character no-undo .
define input parameter p-fax             as character no-undo .
define input parameter p-firm-code       as integer no-undo .
define input parameter p-firm-name       as character no-undo .
define input parameter p-gender          as logical   no-undo .
define input parameter p-given-by        as character no-undo .
define input parameter p-ind             as integer no-undo .
define input parameter p-inn             as character no-undo .
define input parameter p-no-check-inn    as logical                    no-undo .
define input parameter p-is-pboul        as logical no-undo .
define input parameter p-kpp             as character no-undo .
define input parameter p-name1           as character no-undo .
define input parameter p-name2           as character no-undo .
define input parameter p-okonh           as character no-undo .
define input parameter p-okpo            as character no-undo .
define input parameter p-passp-num       as character no-undo .
define input parameter p-passp-ser       as character no-undo .
define input parameter p-phone1          as character no-undo .
define input parameter p-phone1-note     as character no-undo .
define input parameter p-position        as character no-undo .
define input parameter p-post-box        as character no-undo .
define input parameter p-post-address    as character no-undo .
define input parameter p-post-city       as character no-undo .
define input parameter p-post-ind        as integer no-undo .
define input parameter p-reg-code           like ub.clients.reg-code            no-undo .
define input parameter p-turnover-buyer     like ub.clients.turnover-buyer      no-undo .
define input parameter p-turnover-buyer-gds like ub.clients.turnover-buyer-gds  no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: person1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/person1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в карточке человека".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ str/clc-rng.i  }
{ gbl/waitfram.i }
{ trg/new-bcod.i }

define variable v-db-num like ub.db.db-num no-undo .
define variable v-correct-inn as logical no-undo .
define buffer buf_cli-grp for ub.cli-grp.
define variable v-err-mess as character no-undo .
define variable v-is-correct as logical no-undo .
define variable v-int64 as int64 no-undo .
define variable int-buf as integer no-undo .
define variable v-check-zero as logical no-undo init yes.
define variable v-exp-imp-str as character no-undo .
define variable v-type        as character no-undo .
define variable v-issue-host-code like ub.sysconf.host-code no-undo .
define variable v-exist      as logical no-undo .
define variable v-inn-uniq-error as logical no-undo .
define variable v-new-inn as character no-undo .
define variable v-role-ii as integer no-undo .
define variable v-import as logical no-undo .

define buffer buf_clients for ub.clients.
define buffer buf_person for ub.person.
define buffer buf_dis-card for ub.dis-card.
define buffer buf_regions for ub.regions.

{ gbl/clntattr.i }

if p-mode <> {&add-def}
AND p-mode <> {&update}
and p-mode <> {&add-import} then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр p-mode" p-mode
  view-as alert-box error .
  return error '':u.
end.
if p-mode = {&add-import} then do:
  assign
  p-mode = {&add-def}
  v-import = yes
  .
end.

define variable v-callpoint-dcard as character no-undo .
assign
v-callpoint-dcard = (if num-entries(p-callpoint, {&delim-par}) > 1
                    then entry(2, p-callpoint, {&delim-par} )
                    else '':U)
p-callpoint = entry(1, p-callpoint, {&delim-par})
.

if p-callpoint  <> {&role-cashier}
and p-callpoint <> {&role-seller}
and p-callpoint <> "discards":U
and p-callpoint <> "cli-all":U
then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-callpoint"  p-callpoint
    view-as alert-box ERROR.
    undo, return error.
end.

{ gbl/curdbnum.i v-db-num }

if p-mode = {&add-def} then do:
  RUN chk-code in this-procedure ( output v-is-correct) no-error.
  if error-status:error THEN do:
    assign
    v-err-mess = substitute("Ошибка при проверке кода физ.лица &1&2&3"
                            , p-psn-code
                            , {&new-line}
                            , return-value ).
    run err-mess ( input-output v-err-mess ).
    undo, return error (if p-silent  then v-err-mess else (if return-value = "":U then "psn-code":U else return-value)).
  end.
  if not v-is-correct then do:
    undo, return error (if p-silent  then v-err-mess else (if return-value = "":U then "psn-code":U else return-value)).
  end.
  p-psn-code = abs(p-psn-code).
end.

RUN chk-name in this-procedure ( input p-psn-code, output v-is-correct) no-error.
if error-status:error THEN do:
  assign
  v-err-mess = substitute("Ошибка при проверке фамилии человека &1&2&3"
                          , p-obj-name
                          , {&new-line}
                          , return-value
                          ).
  run err-mess ( input-output v-err-mess ).
  undo, return error (if p-silent  then v-err-mess else "obj-name":U).
end.
if not v-is-correct then do:
  undo, return error (if p-silent  then v-err-mess else "obj-name":U).
end.

find first buf_cli-grp no-lock where
          buf_cli-grp.node-code = p-grp-code no-error .
if not avail buf_cli-grp then do:
  assign
  v-err-mess = substitute("Неверный код группы клиента &1", p-grp-code).
  run err-mess ( input-output v-err-mess ).
  undo, return error (if p-silent  then v-err-mess else "":U).
end.
define buffer down_cli-grp for ub.cli-grp.
find first down_cli-grp  no-lock where
          down_cli-grp.upper-code = p-grp-code no-error .
if available down_cli-grp then do:
  assign
  v-err-mess = "Клиент может быть привязан только к терминальной группе".
  run err-mess ( input-output v-err-mess).
  undo, return error (if p-silent then v-err-mess else "":U).
end.

if p-inn <> "":U and not p-no-check-inn then do:
  run gbl/keyinn.p ( input p-inn, input {&prs},  input p-psn-code, input p-is-pboul, output v-correct-inn) no-error .
  if error-status:error or not v-correct-inn then do:
    assign
    v-err-mess = substitute("Неверный {&abbr_inn_allshift} &1: &2", p-inn, return-value).
    run err-mess ( input-output v-err-mess ).
    return error ( if p-silent then v-err-mess else "inn":U).
  end.
end.

if p-reg-code <> 0  then do:
  find first buf_regions no-lock where
            buf_regions.reg-code = p-reg-code no-error.
  if not available buf_regions then do:
    assign
    v-err-mess = substitute("Неверный код региона &1", p-reg-code).
    run err-mess ( input-output v-err-mess ).
    return error ( if p-silent then v-err-mess else "reg-code":U).
  end.
end.

if p-passp-num <> "":U then do:
  assign
  v-int64 = ?
  v-int64 = int64(p-passp-num)
  no-error .
  if error-status:error
  or v-int64 = ?
  or trim(p-passp-num, "0123456789") <> '':U
  then do:
    assign
    v-err-mess = substitute("Неверный № паспорта &1: &2", p-passp-num, return-value).
    run err-mess ( input-output v-err-mess ).
    return error ( if p-silent then v-err-mess else "passp-num":U).
  end.
end.
if p-firm-code <> 0 then do:
  IF NOT can-find(first ub.clients NO-LOCK WHERE
              ub.clients.obj-type = {&prs} AND
              ub.clients.obj-code = p-firm-code) then do:
    v-err-mess = substitute("Значение поля <<КОД ФИРМЫ>> должно соответствовать&1имеющемуся в системе клиенту типа <<&2>>"
                          ,{&new-line}
                          ,{&cmp}).
    run err-mess ( input-output v-err-mess ).
    return error ( if p-silent then v-err-mess else "firm-code":U).
  END.
end.

main-block:
DO for buf_clients
      ,buf_person
ON ERROR undo main-block, RETURN ERROR
ON STOP undo main-block, RETURN ERROR :
  if p-mode = {&add-def} then do:
    if available buf_clients then release buf_clients.
    create buf_clients.
    assign
    buf_clients.obj-type = {&prs}
    buf_clients.obj-code = p-psn-code
    buf_clients.obj-name = p-obj-name
    buf_clients.stts     = p-stts
    buf_clients.grp-code = p-grp-code
    .
    create buf_person.
    assign
    buf_person.psn-code =  p-psn-code
    .
    assign
    p-rid = recid(buf_clients)
    .

  end.
  else do:
    FIND FIRST buf_clients where
              recid(buf_clients) = p-rid No-ERROR.
    if not available buf_clients then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись КЛИЕНТ - p-rid" p-rid
      view-as alert-box error .
      undo main-block, return error '':u.
    end.
    if buf_clients.obj-type <>  {&prs}
    OR buf_clients.obj-code <> p-psn-code then do:
      message
      vss-workfile vss-revision vss-description skip
      "Для уже имеющейся записи нельзя изменить"
      "тип и код клиента" skip
      view-as alert-box ERROR.
      undo main-block, return error '':U.
    end.
    FIND FIRST buf_person where
              buf_person.psn-code = p-psn-code No-ERROR.
    if not available buf_person then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись ЧЕЛОВЕК - p-psn-code" p-psn-code
      view-as alert-box error .
      undo main-block, return error '':u.
    end.
  end.
  assign
  v-new-inn = p-inn.
  run trg/inn-uniq.p (
                   input-output v-new-inn
                  ,input (if p-mode = {&add-def} then p-inn else buf_person.inn)
                  ,input {&prs}
                  ,input buf_person.psn-code
                  ,input p-silent
                  ,input recid(buf_person)
                  ,input buffer buf_person:handle
                  ,output v-inn-uniq-error
                  ) no-error.
  if error-status:error then do:
    v-err-mess = substitute("Ошибка при проверке {&abbr_inn_allshift} на уникальность&1&2&1&3"
                            , {&new-line}
                            , error-status:get-message(1)
                            , return-value) .
    run err-mess ( input-output v-err-mess ).
    undo main-block, return error (if p-silent then v-err-mess else "inn-uniq":U).
  end.
  if v-inn-uniq-error then do:
    v-err-mess = return-value .
    if v-err-mess = 'inn-uniq-no-message' then do:
      v-err-mess = 'inn-uniq'.
    end.
    else do:
      run err-mess ( input-output v-err-mess ).
    end.
    undo main-block, return error (if p-silent then v-err-mess else "inn-uniq":U).
  end.
  assign
  buf_clients.obj-name    =    p-obj-name
  buf_clients.lim-kr      =    p-lim-kr
  buf_clients.PS          =    p-PS
  buf_clients.grp-code    =    p-grp-code
  buf_clients.reg-code    =    p-reg-code
  buf_clients.turnover-buyer     = p-turnover-buyer
  buf_clients.turnover-buyer-gds = p-turnover-buyer-gds
  buf_person.address      =    p-address
  buf_person.city         =    p-city
  buf_person.date-birth   =    p-date-birth
  buf_person.e-mail       =    p-e-mail
  buf_person.fax          =    p-fax
  buf_person.firm-name    =    p-firm-name
  buf_person.gender       =    p-gender
  buf_person.given-by     =    p-given-by
  buf_person.ind          =    p-ind
  buf_person.inn          =    p-inn
  buf_person.is-pboul     =    p-is-pboul
  buf_person.kpp          =    p-kpp
  buf_person.name1        =    p-name1
  buf_person.name2        =    p-name2
  buf_person.passp-num    =    p-passp-num
  buf_person.passp-ser    =    p-passp-ser
  buf_person.phone1       =    p-phone1
  buf_person.phone1-note  =    p-phone1-note
  buf_person.position     =    p-position
  buf_person.post-box     =    p-post-box
  buf_person.post-address =    p-post-address
  buf_person.post-city    =    p-post-city
  buf_person.post-ind     =    p-post-ind
  buf_clients.trg-param   =    (if v-import
                               and p-callpoint = "discards"
                               then {&trg-param-no-callnews}
                               else '':U)
  buf_person.trg-param    =    (if v-import
                               and p-callpoint = "discards"
                               then {&trg-param-no-callnews}
                               else '':U)
  .
  release buf_clients no-error.
  if error-status:error then do:
    message
    vss-workfile vss-revision vss-description skip
    "Ошибка при сохранении записи КЛИЕНТА" skip
    ERROR-STATUS:GET-NUMBER(1) skip
    return-value
    view-as alert-box .
    undo main-block, return error "":U.
  end.
  release buf_person no-error.
  if error-status:error then do:
    message
    vss-workfile vss-revision vss-description skip
    "Ошибка при сохранении записи ЧЕЛОВЕКА" skip
    ERROR-STATUS:GET-NUMBER(1) skip
    return-value
    view-as alert-box .
    undo main-block, return error "":U.
  end.
  if p-mode = {&add-def}
  and lookup(p-callpoint, {&role-list}) > 0
  then do:
    run request-proc-save-staff in p-parent-handle (
                                                      input this-procedure:handle
                                                     ,input p-mode
                                                     ,input p-callpoint) no-error.
    if error-status:error then do:
      undo main-block, return error return-value .
    end.
  end. /*if p-mode = {&add-def} then do:*/
end. /*doe*/



procedure chk-code :
define output parameter p-is-correct as logical no-undo .
define variable v-rid as recid no-undo .
define variable glog as logical no-undo .
define variable v-stts as character no-undo .
define variable v2-db-num like ub.db.db-num no-undo .
define variable ii as integer no-undo .
define variable v-result as logical no-undo .

define buffer buf_clients for ub.clients.
define buffer buf_person for ub.person.
define buffer buf_code-range for ub.code-range.

do
on error undo, return error return-value
:
  if p-mode = {&add-def} then do:
    if p-psn-code = 0 then do:
      run gen-b-code in this-procedure ( input {&gbl-pn-code}, output p-psn-code) no-error .
      if error-status:error then do:
        assign
        v-err-mess = substitute("Ошибка при получении кода физ.лица для нового контрагента&1&2&1&3"
                              , {&new-line}
                              , error-status:get-message(1)
                              , return-value ).
        run err-mess ( input-output v-err-mess ).
        undo, return  error (if p-silent then v-err-mess else "psn-code":U).
      end.
    end. /*    if p-psn-code = 0 then do:*/
    else do:
      v-result = calc-range(
                        input v-db-num
                        ,input p-psn-code
                        ,input {&gbl-pn-code}
                        )
     no-error .
     if v-result = ?  then  do:
        assign
        v-err-mess = substitute("Не найден диапапазон контрагентов для кода контрагента &1 в БД &2", p-psn-code, v-db-num).
        run err-mess ( input-output v-err-mess ).
        undo, return  error (if p-silent then v-err-mess else "psn-code":U).

     end.
     if v-result = no and v-import = no then  do:
        assign
        v-err-mess = substitute("Вы не можете САМОСТОЯТЕЛЬНО определить код НОВОГО физ.лица = &1", p-psn-code).
        run err-mess ( input-output v-err-mess ).
        undo, return  error (if p-silent then v-err-mess else "psn-code":U).
      end.
    end.
    if p-psn-code = 0 then  do:
      assign
      v-err-mess = "Код физ.лица не может быть равен 0".
      run err-mess ( input-output v-err-mess).
      undo, return error (if p-silent then v-err-mess else "":U).
    end.
    define buffer another_person for ub.person.
    find first another_person no-lock where
             another_person.psn-code = p-psn-code  no-error.
    if available another_person then do:
      assign
      v-err-mess = substitute("Человек с кодом &1 уже есть", p-psn-code).
      run err-mess ( input-output v-err-mess ).
      undo, return error (if p-silent then v-err-mess else "psn-code":U).
    end.
    assign
    p-is-correct = yes
    .
  end.
end. /*doe*/

end procedure. /* chk-code */


procedure chk-name :
DEFINE INPUT PARAMETER p-psn-code like ub.person.psn-code no-undo.
define output parameter p-is-correct as logical no-undo .
DEFINE buffer buf_person for ub.person.

  do
  on error undo, return error
  :

    if p-obj-name  = ""
    or p-obj-name = ?
    then do:
      assign
      v-err-mess = "Нет фамилии".
      run err-mess ( input-output v-err-mess).
      undo, return (if p-silent then v-err-mess else "obj-name":U).
    end.
    assign
    p-is-correct = yes
    .
  end.

end procedure. /* chk-name */


PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      p-mess = substitute("Клиент чел&1: &2", p-psn-code,  p-mess).
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.

procedure proc-save-staff :
define input parameter p-role as character no-undo .
define input parameter p-staff-code as integer no-undo .
define input parameter p-level as character no-undo .
define input parameter p-role-db-num as character no-undo .
define input parameter p-role-host-code as integer no-undo .
define input parameter p-role-obj-type as character no-undo .
define input parameter p-role-obj-code as integer no-undo .
define input parameter p-staff-password as character no-undo .
define input parameter p-date-start as date no-undo .
define input parameter p-date-end as date no-undo .
define input parameter p-work-place as character no-undo .

define variable v-rid as recid no-undo .
define variable v-role-rid as recid no-undo .
define buffer buf_staff for ub.staff.

  do
  on error undo, return error return-value
  :
    if p-role = p-callpoint then v-role-ii = v-role-ii + 1.
    find first buf_staff where
                buf_staff.role = p-role
            and buf_staff.role-level = p-level
          and  buf_staff.psn-code = p-psn-code
          and buf_staff.staff-code = p-staff-code
          and buf_staff.work-place = p-work-place no-error .
    if not available buf_staff then do:
      run ref/staff01.p (
                     input-output v-rid
                    ,input p-mode
                    ,input p-silent
                    ,input p-role
                    ,input p-staff-code
                    ,input p-psn-code
                    ,input p-level
                    ,input p-date-start
                    ,input p-date-end
                    ,input p-role-db-num
                    ,input p-role-host-code
                    ,input p-role-obj-type
                    ,input p-role-obj-code
                    ,input p-work-place
                    ,input p-staff-password) no-error .
      if error-status:error then do:
        undo , return error return-value .
      end.
      if v-role-ii = 1
      and p-role = p-callpoint
      then v-role-rid = v-rid.
    end.
    if v-role-rid <> ? then
    p-rid = v-role-rid.
  end.

end procedure. /* proc-save-staff */