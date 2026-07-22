block-level on error undo, throw.
/*

$Revision: d47c064bc860, 1107, rls $
$Author: SMMolotkov $
$Date: Thu Dec 14 02:13:53 2017 +0300 $
$Workfile: firm1.p $
$Archive: ref/firm1.p $

Сохранение изменений в карточке организации

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
define input-output parameter p-rid      as recid no-undo.
define input parameter p-mode            as character no-undo .
define input parameter p-callpoint       as character no-undo .
define input parameter p-silent          as logical no-undo . /*может быть yes  с выводом в return-value no с руганью на экран */
define input parameter p-firm-code       like  ub.firm.firm-code      no-undo .
define input parameter p-stts            like  ub.clients.stts         no-undo .
define input parameter p-obj-name        like  ub.clients.obj-name     no-undo .
define input parameter p-lim-kr          like  ub.clients.lim-kr       no-undo .
define input parameter p-PS              like  ub.clients.PS           no-undo .
define input parameter p-grp-code        like  ub.clients.grp-code     no-undo .
define input parameter p-addres1         like  ub.firm.addres1         no-undo .
define input parameter p-addres2         like  ub.firm.addres2         no-undo .
define input parameter p-city            like  ub.firm.city            no-undo .
define input parameter p-contact-psn     like  ub.firm.contact-psn     no-undo .
define input parameter p-director        like  ub.firm.director        no-undo .
define input parameter p-e-mail          like  ub.firm.e-mail          no-undo .
define input parameter p-engl-name       like  ub.firm.engl-name       no-undo .
define input parameter p-fax             like  ub.firm.fax             no-undo .
define input parameter p-given-by        like  ub.firm.given-by        no-undo .
define input parameter p-ind             like  ub.firm.ind             no-undo .
define input parameter p-inn             like  ub.firm.inn             no-undo .
define input parameter p-no-check-inn    as logical                    no-undo .
define input parameter p-is-pboul        like  ub.firm.is-pboul        no-undo .
define input parameter p-kpp             like  ub.firm.kpp             no-undo .
define input parameter p-okonh           like  ub.firm.okonh           no-undo .
define input parameter p-okpo            like  ub.firm.okpo            no-undo .
define input parameter p-passp-num       like  ub.firm.passp-num       no-undo .
define input parameter p-passp-ser       like  ub.firm.passp-ser       no-undo .
define input parameter p-phone           like  ub.firm.phone           no-undo .
define input parameter p-phone1-note     like  ub.firm.phone1-note     no-undo .
define input parameter p-post-addr1      like  ub.firm.post-addr1      no-undo .
define input parameter p-post-addr2      like  ub.firm.post-addr2      no-undo .
define input parameter p-post-city       like  ub.firm.post-city       no-undo .
define input parameter p-post-ind        like  ub.firm.post-ind        no-undo .
define input parameter p-reg-code        like  ub.clients.reg-code     no-undo .
define input parameter p-telex           like  ub.firm.telex           no-undo .
define input parameter p-tobj-code       like  ub.firm.tobj-code       no-undo .
define input parameter p-turnover-buyer      like ub.clients.turnover-buyer       no-undo .
define input parameter p-turnover-buyer-gds  like ub.clients.turnover-buyer-gds   no-undo .


define variable vss-revision    as character no-undo init "$Revision: d47c064bc860, 1107, rls $":U .
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 14 02:13:53 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: firm1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/firm1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в карточке организации".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ str/clc-rng.i  }

define variable v-db-num like ub.db.db-num no-undo .
define variable v-correct-inn as logical no-undo .
define buffer buf_cli-grp for ub.cli-grp.
define variable v-err-mess as character no-undo .
define variable v-is-correct as logical no-undo .
define variable v-type        as character no-undo .
define variable v-issue-host-code like ub.sysconf.host-code no-undo .
define variable v-inn-uniq-error as logical no-undo .
define variable v-new-inn like ub.firm.inn no-undo .
define variable v-import as logical no-undo .

define buffer buf_dis-card for ub.dis-card.
define buffer buf_clients for ub.clients.
define buffer buf_firm for ub.firm.
define buffer buf_regions for ub.regions.


{ gbl/clntattr.i }
{ trg/new-bcod.i }

if p-mode <> {&add-def}
AND p-mode <> {&update}
and p-mode <> {&add-import}
then do:
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

if p-callpoint <> "discards":U
and p-callpoint <> "cli-all":U
and p-callpoint <> "":U
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
    v-err-mess = substitute("Ошибка при проверке кода организации &1&2&3"
                            , p-firm-code
                            , {&new-line}
                            , return-value ).
    run err-mess in this-procedure ( input-output v-err-mess).
    undo, return error (if p-silent then v-err-mess else (if return-value = "":U then "firm-code":U else return-value)).
  end.
  if not v-is-correct then do:
    undo, return error (if p-silent then v-err-mess else (if return-value = "":U then "firm-code":U else return-value)).
  end.
  p-firm-code = abs(p-firm-code).
end.

RUN chk-name in this-procedure ( p-firm-code, output v-is-correct) no-error.
if error-status:error THEN do:
  assign
  v-err-mess = substitute("Ошибка при проверке названия организации &1", p-obj-name)
  .
  run err-mess in this-procedure ( input-output  v-err-mess ).
  undo, return error (if p-silent then v-err-mess else "obj-name":U).
end.
if not v-is-correct then do:
  undo, return error (if p-silent then v-err-mess else "obj-name":U).
end.

find first buf_cli-grp no-lock where
          buf_cli-grp.node-code = p-grp-code no-error .
if not avail buf_cli-grp then do:
  assign
  v-err-mess = substitute("Неверный код группы клиента &1", p-grp-code) .
  run err-mess in this-procedure ( input-output v-err-mess ).
  undo, return error v-err-mess.
end.
if can-find(first ub.cli-grp no-lock where
                    ub.cli-grp.upper-code = p-grp-code) then do:
  v-err-mess = "Клиент может быть привязан только к терминальной группе".
  run err-mess in this-procedure ( input-output v-err-mess).
  undo, return error (if p-silent then v-err-mess else "":U).
end.

if p-inn <> "":U and not p-no-check-inn then do:
  run gbl/keyinn.p ( input p-inn, input {&cmp}, input p-firm-code, input p-is-pboul, output v-correct-inn) no-error .
  if error-status:error or not v-correct-inn then do:
    assign
    v-err-mess = substitute("Неверный {&abbr_inn_allshift} &1: &2", p-inn, return-value).
    run err-mess in this-procedure ( input-output v-err-mess ).
    return error (if p-silent then v-err-mess else "inn":U).
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
define variable v-int as integer no-undo .
if p-passp-num <> "":U then do:
  assign
  v-int = integer(p-passp-num)
  no-error .
  if error-status:error
  or v-int = ?
  or trim(p-passp-num, "0123456789") <> '':U
  then do:
    assign
    v-err-mess = substitute("Неверный № паспорта &1: &2", p-passp-num, return-value).
    run err-mess ( input-output v-err-mess ).
    return error ( if p-silent then v-err-mess else "passp-num":U).
  end.
end.

if p-tobj-code > 0 then do:
  IF NOT can-find(first ub.clients where
                       ub.clients.obj-type = {&prs}
                   and ub.clients.obj-code = p-tobj-code) then do:
    assign
    v-err-mess = substitute("Значение поля <<КОД ТОРГОВОГО ПРЕДСТАВИТЕЛЯ>>&1должно соответствовать имеющемуся в системе клиенту типа <<&2>>"
                          ,{&new-line}
                        ,{&prs}).
    run err-mess ( input-output v-err-mess ).
    return error ( if p-silent then v-err-mess else "tobj-code":U).
  END.
end.



main-block:
DO for buf_clients
      ,buf_firm
ON ERROR undo main-block, RETURN ERROR
ON STOP undo main-block, RETURN ERROR :
  if p-mode = {&add-def} then do:
    if available buf_clients then release buf_clients.
    create buf_clients.
    assign
    buf_clients.obj-type = {&cmp}
    buf_clients.obj-code = p-firm-code
    buf_clients.obj-name = p-obj-name
    buf_clients.stts     = p-stts
    buf_clients.grp-code = p-grp-code
    .
    create buf_firm.
    assign
    buf_firm.firm-code =  p-firm-code
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
    if buf_clients.obj-type <>  {&cmp}
    OR buf_clients.obj-code <> p-firm-code then do:
      message
      vss-workfile vss-revision vss-description skip
      "Для уже имеющейся записи нельзя изменить"
      "тип и код клиента" skip
      view-as alert-box ERROR.
      undo main-block, return error '':U.
    end.
    FIND FIRST buf_firm where
              buf_firm.firm-code = p-firm-code No-ERROR.
    if not available buf_firm then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись ОРГАНИЗАЦИЯ - p-firm-code" p-firm-code
      view-as alert-box error .
      undo main-block, return error '':u.
    end.
  end.
  assign
  v-new-inn = p-inn.
  run trg/inn-uniq.p (
                   input-output v-new-inn
                  ,input (if p-mode = {&add-def} then p-inn else buf_firm.inn)
                  ,input {&cmp}
                  ,input buf_firm.firm-code
                  ,input p-silent
                  ,input recid(buf_firm)
                  ,input buffer buf_firm:handle
                  ,output v-inn-uniq-error
                  ) no-error.
  if error-status:error then do:
    v-err-mess = substitute("Ошибка при проверке {&abbr_inn_allshift} на уникальность&1&2&1&3"
                            , {&new-line}
                            , error-status:get-message(1)
                            , return-value) .
    run err-mess in this-procedure ( input-output v-err-mess ).
    undo, return error (if p-silent then v-err-mess else "inn-uniq":U).
  end.
  if v-inn-uniq-error then do:
    v-err-mess = return-value .
    if v-err-mess = 'inn-uniq-no-message' then do:
      v-err-mess = 'inn-uniq'.
    end.
    else do:
      run err-mess in this-procedure ( input-output v-err-mess ).
    end.
    undo, return error (if p-silent then v-err-mess else "inn-uniq":U).
  end.
  assign
  buf_clients.obj-name    =  p-obj-name
  buf_clients.lim-kr      =  p-lim-kr
  buf_clients.PS          =  p-PS
  buf_clients.grp-code    =  p-grp-code
  buf_firm.addres1        =  p-addres1
  buf_firm.addres2        =  p-addres2
  buf_firm.city           =  p-city
  buf_firm.contact-psn    =  p-contact-psn
  buf_firm.director       =  p-director
  buf_firm.e-mail         =  p-e-mail
  buf_firm.engl-name      =  p-engl-name
  buf_firm.fax            =  p-fax
  buf_firm.given-by       =  p-given-by
  buf_firm.ind            =  p-ind
  buf_firm.inn            =  p-inn
  buf_firm.is-pboul       =  p-is-pboul
  buf_firm.kpp            =  p-kpp
  buf_firm.okonh          =  p-okonh
  buf_firm.okpo           =  p-okpo
  buf_firm.passp-num      =  p-passp-num
  buf_firm.passp-ser      =  p-passp-ser
  buf_firm.phone          =  p-phone
  buf_firm.phone1-note    =  p-phone1-note
  buf_firm.post-addr1     =  p-post-addr1
  buf_firm.post-addr2     =  p-post-addr2
  buf_firm.post-city      =  p-post-city
  buf_firm.post-ind       =  p-post-ind
  buf_clients.reg-code    =  p-reg-code
  buf_firm.telex          =  p-telex
  buf_firm.tobj-code      =  p-tobj-code
  buf_clients.turnover-buyer     = p-turnover-buyer
  buf_clients.turnover-buyer-gds = p-turnover-buyer-gds
  buf_clients.trg-param   =    (if v-import
                               and p-callpoint = "discards"
                               then {&trg-param-no-callnews}
                               else '':U)
  buf_firm.trg-param      =    (if v-import
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
  release buf_firm no-error.
  if error-status:error then do:
    message
    vss-workfile vss-revision vss-description skip
    "Ошибка при сохранении записи ОРГАНИЗАЦИИ" skip
    ERROR-STATUS:GET-NUMBER(1) skip
    return-value
    view-as alert-box .
    undo main-block, return error "":U.
  end.
end. /*doe*/



procedure chk-code :
define output parameter p-is-correct as logical no-undo .
define variable v-rid as recid no-undo .
define variable maindb-begin-code as integer no-undo.
define variable maindb-end-code as integer no-undo.
define variable currentdb-begin-code as integer no-undo.
define variable currentdb-end-code as integer no-undo.
define variable glog as logical no-undo .
define variable v-result as logical no-undo .

define buffer buf_clients for ub.clients.
define buffer buf_person for ub.person.

do
on error undo, return error return-value
:

 if p-mode = {&add-def} then do:
    if p-firm-code = 0 then do:
      run gen-b-code in this-procedure ( input {&gbl-fm-code}, output p-firm-code) no-error .
      if error-status:error then do:
        assign
        v-err-mess = substitute("Ошибка при получении кода организации для нового контрагента&1&2&1&3"
                                , {&new-line}
                                , error-status:get-message(1)
                                , return-value ).
        run err-mess in this-procedure ( input-output v-err-mess ).
        undo, return  error (if p-silent then v-err-mess else "firm-code":U).
      end.
    end. /*if p-firm-code = 0 then do:*/
    else do:
      assign
      v-result = calc-range(
                         input v-db-num
                        ,input p-firm-code
                        ,input {&gbl-fm-code}
                        )
      no-error .
      if v-result = ?  then  do:
          assign
          v-err-mess = substitute("Не найден диапапазон контрагентов для кода контрагента &1 в БД &2", p-firm-code, v-db-num).
          run err-mess in this-procedure ( input-output v-err-mess ).
          undo, return  error (if p-silent then v-err-mess else "psn-code":U).

      end.
      if v-result = no  and v-import = no then  do:
        assign
        v-err-mess = substitute("Вы не можете САМОСТОЯТЕЛЬНО определить код НОВОЙ организации = &1", p-firm-code).
        run err-mess in this-procedure ( input-output v-err-mess ).
        undo, return  error (if p-silent then v-err-mess else "firm-code":U).
      end.
    end.
    if p-firm-code = 0 then  do:
      assign
      v-err-mess = "Код организации не может быть равен 0".
      run err-mess in this-procedure (input-output v-err-mess).
      undo, return error (if p-silent then v-err-mess else "":U).
    end.
    if can-find( first ub.firm where
                      ub.firm.firm-code = p-firm-code ) then do:
      assign
      v-err-mess =  substitute("Организация с кодом &1 уже есть", p-firm-code).
      run err-mess in this-procedure ( input-output v-err-mess).
      undo, return error (if p-silent then v-err-mess else "firm-code":U).
    end.
  end.
  assign
  p-is-correct = yes
  .
end. /*doe*/

end procedure. /* chk-code */


procedure chk-name :
DEFINE INPUT PARAMETER p-firm-code like ub.firm.firm-code no-undo.
define output parameter p-is-correct as logical no-undo .
define variable int-buf as integer no-undo .
DEFINE buffer buf_firm for ub.firm.

  do
  on error undo, return error return-value
  :

    if p-obj-name  = "" then do:
      assign
      v-err-mess = "Нет названия".
      run err-mess in this-procedure  ( input-output v-err-mess ).
      undo, return error (if p-silent then v-err-mess else "obj-name":U).
    end.
    assign
    p-is-correct = yes
    .
  end.

end procedure. /* chk-name */


PROCEDURE err-mess:
  DEFINE INPUT-output PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      p-mess = substitute("Клиент орг&1: &2", p-firm-code,  p-mess).
    end.
    otherwise do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.