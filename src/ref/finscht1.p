block-level on error undo, throw.
/*

$Revision: 70a347534c9d, 1171, rls $
$Author: PGridchina $
$Date: Thu Dec 14 02:20:27 2017 +0300 $
$Workfile: finscht1.p $
$Archive: ref/finscht1.p $

Сохранение изменений в карточке банковского счета

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/24/03
Author: Bakhtadze Natalya
Creation date: 10/24/03

Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!

*/

define input-output parameter p-doc-rec as recid no-undo.
define input parameter p-mode            as character no-undo .
define input parameter p-silent                       as logical no-undo .
define input parameter p-verify          as character no-undo .
define input parameter p-host-code       like ub.fin-schet.host-code no-undo .
define input parameter p-code-schet      like ub.fin-schet.code-schet no-undo .
define input parameter p-c-schet         like ub.fin-schet.c-schet   no-undo .
define input parameter p-cli-type        like ub.fin-schet.cli-type  no-undo .
define input parameter p-cli-code        like ub.fin-schet.cli-code  no-undo .
define input parameter p-code-bank       like ub.fin-schet.code-bank no-undo .
define input parameter p-curr-code       like ub.fin-schet.curr-code no-undo .
define input parameter p-dop1            like ub.fin-schet.dop1      no-undo .
define input parameter p-dop2            like ub.fin-schet.dop2      no-undo .
define input parameter p-r-schet         like ub.fin-schet.r-schet   no-undo .
define input parameter p-PS              like ub.fin-schet.PS        no-undo .

define variable vss-revision    as character no-undo init "$Revision: 70a347534c9d, 1171, rls $":U .
define variable vss-author      as character no-undo init "$Author: PGridchina $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 14 02:20:27 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: finscht1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/finscht1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в карточке банковского счета".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/clntattr.i }

define variable v-db-num like ub.db.db-num no-undo .
define variable v-correct-schet as logical no-undo .
define variable v-err-mess as character no-undo .
define variable v1-mainholder as character no-undo .
define variable v2-mainholder as character no-undo .
define variable v1type as character no-undo .
define variable v2type as character no-undo .
define variable v-dop1 as character no-undo .
define variable v-value as character no-undo.
define variable v-ttype as character no-undo.

define buffer buf_sysconf  for ub.sysconf.
define buffer buf_fin-bank for ub.fin-bank.
define buffer buf_schet-clients for ub.clients.
define buffer buf_currency for ub.currency.
define buffer buf-db_fin-schet for ub.fin-schet.

if p-mode <> {&add-def}
AND p-mode <> {&update} then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр p-mode" p-mode
  view-as alert-box error .
  return error '':u.
end.

{ gbl/curdbnum.i v-db-num }
if num-entries(p-dop1, {&delim-par} ) > 1 then do:
  /*это если организации на самом деле магазины как для ORA*/
  v-dop1 = entry(2, p-dop1, {&delim-par} ).
  p-dop1 = entry(1, p-dop1, {&delim-par} ).
end.
find first buf_sysconf no-lock where
                buf_sysconf.host-code = p-host-code.
if not avail buf_sysconf then dO:
  v-err-mess = substitute("Не найдена фирма с кодом &1", p-host-code).
  run err-mess in this-procedure ( input-output v-err-mess ).
  undo, return error (if p-silent = yes then v-err-mess else 'host-code':U).
end.
run gbl/conf-rd.p ("is-erpRN", "", "", 0, "", "", "", no, output v-value, output v-ttype) no-error.
if v-value = "no"  then 
do:   
if v-db-num <> buf_sysconf.firm-db-num
then do:
  v-err-mess = substitute("Нельзя изменять запись БАНКОВСКОГО СЧЕТА в БД, отличной от главной БД фирмы:&1" +
                           "Номер текущей БД &2 Номер главной БД фирмы &3"
                           , {&new-line}
                           , v-db-num
                           , buf_sysconf.firm-db-num) .
  run err-mess in this-procedure ( input-output v-err-mess ).
  undo, return error (if p-silent = yes then v-err-mess else 'host-code':U).
end.
end.
find first buf_fin-bank no-lock where
                  buf_fin-bank.host-code = p-host-code
              AND buf_fin-bank.code-bank = p-code-bank no-error .
if not available buf_fin-bank then do:
  v-err-mess = substitute("Не найден банк вн№ &1 в фирме &2", p-code-bank, p-host-code) .
  run err-mess in this-procedure ( input-output v-err-mess ).
  undo, return error (if p-silent = yes then v-err-mess else 'code-bank':U).
end.
if lookup("r-schet", p-verify) > 0 then do:
run gbl/keyschet.p (
                 input p-r-schet
                ,input buf_fin-bank.bik
                ,input p-curr-code
                ,input (if substring(buf_fin-bank.bik, 7, 3) = '000'
                        or substring(buf_fin-bank.bik, 7, 3) = '001'
                        or substring(buf_fin-bank.bik, 7, 3) = '002'
                        then no
                        else yes)
                ,output v-correct-schet
              )  no-error.

if error-status:error then do:
  v-err-mess = substitute("Ошибка при проверке валидности расчетного счета &1: &2", p-r-schet, ERROR-STATUS:GET-message(1)) .
  run err-mess in this-procedure ( input-output v-err-mess ).
  undo, return error "r-schet":U.
end.
if not v-correct-schet then do:
  v-err-mess = substitute("Неверный расчетный счет &1: &2", p-r-schet, return-value) .
  run err-mess in this-procedure ( input-output v-err-mess ).
  undo, return error (if p-silent = yes then v-err-mess else 'r-schet':U).
end.
end.

if not can-find(first buf_currency no-lock where
                  buf_currency.curr-code = p-curr-code
                            ) then do:
  v-err-mess = substitute("Не найдена валюта с кодом &1", p-curr-code) .
  run err-mess in this-procedure ( input-output v-err-mess ).
  undo, return error (if p-silent = yes then v-err-mess else 'curr-code':U).
end.
if not can-find(first buf_schet-clients no-lock where
                  buf_schet-clients.obj-type = p-cli-type
              AND buf_schet-clients.obj-code = p-cli-code
              ) then do:
  v-err-mess = substitute("Не найден контрагент &1&2", p-cli-type, p-cli-code) .
  run err-mess in this-procedure ( input-output v-err-mess ).
  undo, return error (if p-silent = yes then v-err-mess else 'cli-code':U).
end.



if p-r-schet = "":U then do:
  v-err-mess = "Поле РАСЧЕТНЫЙ СЧЕТ не может быть пустым" .
  run err-mess in this-procedure ( input-output v-err-mess ).
  undo, return error (if p-silent = yes then v-err-mess else 'r-schet':U).
end.


_MAIN:
DO ON ERROR UNDO, RETURN ERROR
ON STOP UNDO, RETURN ERROR:
  if p-mode = {&add-def} then do:
    create ub.fin-schet.
    assign
    ub.fin-schet.host-code = p-host-code
    ub.fin-schet.code-schet = next-value(s-fin-schet, {&db-name_schema})
    p-doc-rec = recid(ub.fin-schet)
    .
  end.
  else do:
    FIND FIRST ub.fin-schet where
              recid(ub.fin-schet) = p-doc-rec No-ERROR.
    if not available ub.fin-schet then do:
      v-err-mess = substitute("&1 &2 &3&4Не найдена запись банковского счета - p-doc-rec=&5"
                              ,vss-workfile
                              ,vss-revision
                              ,vss-description
                              ,{&new-line}
                              ,p-doc-rec).
      run err-mess in this-procedure ( input-output v-err-mess ).
      undo _main, return error (if p-silent = yes then v-err-mess else '':U).
    end.
    if ub.fin-schet.host-code <> p-host-code
    OR ub.fin-schet.code-schet <> p-code-schet then do:
      v-err-mess = "Для уже имеющейся записи нельзя изменить код фирмы и код счета" .
      run err-mess in this-procedure ( input-output v-err-mess ).
      undo _main, return error (if p-silent = yes then v-err-mess else '':U).
    end.
    if ub.fin-schet.cli-type <> p-cli-type
    OR ub.fin-schet.cli-code <> p-cli-code then do:
      v-err-mess = "Для уже имеющейся записи нельзя изменить держателя счета" .
      run err-mess in this-procedure ( input-output v-err-mess ).
      undo _main, return error (if p-silent = yes then v-err-mess else '':U).
    end.
  end.
/* Закомментировано по задаче ТН-3206 от 2014г Арн.*/
/*ТН-3206 от 2014г Арн. if v-dop1 = '' then do:
    for each buf-db_fin-schet where buf-db_fin-schet.host-code = p-host-code and
                                      buf-db_fin-schet.r-schet   = p-r-schet   and
                                      buf-db_fin-schet.code-bank = p-code-bank and
                                      buf-db_fin-schet.status_   = {&current-status}
                                and (p-mode = {&add-def} or (p-mode = {&update} and ub.fin-schet.status_ = {&current-status})):
      if buf-db_fin-schet.code-schet   = p-code-schet    then next.
      run clntattr-value in this-procedure (
                                              input p-cli-type
                                            ,input p-cli-code
                                            ,input {&attr-main-accholder}
                                            ,output v1-mainholder
                                            ,output v1type) no-error.
      run clntattr-value in this-procedure (
                                              input buf-db_fin-schet.cli-type
                                            ,input buf-db_fin-schet.cli-code
                                            ,input {&attr-main-accholder}
                                            ,output v2-mainholder
                                            ,output v2type) no-error.

      if v1-mainholder = v2-mainholder
      and v1-mainholder <> '':U
      and v2-mainholder <> '':U
      and buf-db_Fin-schet.dop1 <> p-dop1
      and buf-db_Fin-schet.dop1 <> '':U
      and p-dop1 <> '':U
      then next.
      leave.
    end.
  end.
ТН-3206 от 2014г Арн.*/
    run clntattr-value in this-procedure (
        input p-cli-type,
        input p-cli-code,
        input {&attr-main-accholder},
        output v1-mainholder,
        output v1type)
    no-error.

 
    for each buf-db_fin-schet where buf-db_fin-schet.host-code = p-host-code and        /* Хост код фирмы-держателя счёта, к которой хотим доб. контрагента с тем-же Р/с */
                                      buf-db_fin-schet.r-schet = p-r-schet and          /* Р/с фирмы-держателя счёта, к которой хотим доб. контрагента с тем-же Р/с  */
                                      buf-db_fin-schet.code-bank = p-code-bank and      /* Код Банка фирмы-держателя счёта, к которой хотим доб. контрагента с тем-же Р/с  */
                                      buf-db_fin-schet.status_ = {&current-status}      /* Статус фин докум. фирмы-держателя счёта, к которой хотим доб. контрагента с тем-же Р/с  */
                                and (p-mode = {&add-def} or (p-mode = {&update} and ub.fin-schet.status_ = {&current-status})):
    if buf-db_fin-schet.code-schet = p-code-schet then next.

    run clntattr-value in this-procedure (
        input buf-db_fin-schet.cli-type,
        input buf-db_fin-schet.cli-code,
        input {&attr-main-accholder},
        output v2-mainholder,
        output v2type)
    no-error.


    if buf-db_fin-schet.cli-type = p-cli-type
        and buf-db_fin-schet.cli-code = p-cli-code
    then
        do:
            
             /* Запрет ввода одной и той-же фирмы HOST-CODE на один и тот-же р/счёт. */
            v-err-mess = substitute("Для клиена &6,&7 уже заведен счёт &1 по фирме &2 в том же банке." +
                "&3Вн.номер счета = &4" +
                "&3Доп.назв.держ.счёта = &5",
                p-r-schet,
                p-host-code,
                {&new-line},
                buf-db_fin-schet.code-schet,
                buf-db_fin-schet.dop1,
                buf-db_fin-schet.cli-type,
                buf-db_fin-schet.cli-code
                ).
            run err-mess in this-procedure (input-output v-err-mess).
            undo, return error (if p-silent = yes then v-err-mess else 'r-schet':U).
        end.

    if p-dop1 <> '':U
        and buf-db_Fin-schet.dop1 = '':U
        and  v1-mainholder <> '':U 
        and v1-mainholder = buf-db_fin-schet.cli-type + "," + string(buf-db_fin-schet.cli-code)
        and v2-mainholder = '':U        
    then
        do:
            next.
        end.

    if p-dop1 = ''
        and v1-mainholder = '' 
        and v2-mainholder <> '':U and v2-mainholder = string(p-cli-type + "," + string(p-cli-code))
        and buf-db_Fin-schet.dop1 <> '':U
    then
        do:
            next.
        end.

    if p-dop1 <> ''
        and buf-db_Fin-schet.dop1 <> '' 
        and p-dop1 <> buf-db_Fin-schet.dop1
        and v1-mainholder <> '':U 
        and v1-mainholder = v2-mainholder
    then 
        do:
            next.
        end.

    v-err-mess = substitute("Уже есть расчетный счет &1 по фирме &2 в том же банке." +
        "&3Вн.номер счета = &4" +
        (if v1-mainholder <> ''
            and v1-mainholder = v2-mainholder
            and buf-db_Fin-schet.dop1 <> ''
            and buf-db_Fin-schet.dop1 = p-dop1
            then
                "&3Объект = &6,&7" +
                "&3Доп.назв.держ.счёта = &5"
            else ""),
        p-r-schet,
        p-host-code,
        {&new-line},
        buf-db_fin-schet.code-schet,
        buf-db_fin-schet.dop1,
        buf-db_fin-schet.cli-type,
        buf-db_fin-schet.cli-code
        ).
    run err-mess in this-procedure (input-output v-err-mess).
    undo, return error (if p-silent = yes then v-err-mess else 'r-schet':U).

end. /* for each buf-db_fin-schet ... */

/*
  if available buf-db_fin-schet then do:
    v-err-mess = substitute("Уже есть расчетный счет &1 по фирме &2 в том же банке.&3" +
                                  "Вн.номер счета: &4"
                                  , p-r-schet
                                  , p-host-code
                                  , {&new-line}
                                  ,buf-db_fin-schet.code-schet).
    run err-mess in this-procedure ( input-output v-err-mess ).
    undo, return error (if p-silent = yes then v-err-mess else 'r-schet':U).
  end.
*/

  assign
  ub.fin-schet.c-schet   = p-c-schet
  ub.fin-schet.cli-type  = p-cli-type
  ub.fin-schet.cli-code  = p-cli-code
  ub.fin-schet.code-bank = p-code-bank
  ub.fin-schet.curr-code = p-curr-code
  ub.fin-schet.dop1      = p-dop1
  ub.fin-schet.dop2      = p-dop2
  ub.fin-schet.r-schet   = p-r-schet
  ub.fin-schet.PS        = p-PS
  ub.fin-schet.status_   = (if p-mode = {&add-def}
                            then {&current-status}
                            else ub.fin-schet.status_)
  .
  release ub.fin-schet no-error.
  if error-status:error then do:
    v-err-mess = substitute("Ошибка при сохранении записи БАНКОВСКОГО СЧЕТА &1: &2", ERROR-STATUS:GET-NUMBER(1), return-value ) .
    run err-mess in this-procedure ( input-output v-err-mess ).
    undo _main, return error (if p-silent = yes then v-err-mess else '':U).
  end.

end. /*doe*/

PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      p-mess = substitute("Счет вн.№ &1: фирма: &2:&3&4"
                         , p-code-schet
                         , p-host-code
                         , {&new-line}
                         , p-mess
                         ).
    end.
    otherwise do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.