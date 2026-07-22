block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: tare01.p $
$Archive: ref/tare01.p $

Сохранение изменений в карточке ТАРЫ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/30/09
Author: Bakhtadze Natalya
Creation date: 09/30/09

Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!


*/

define input-output parameter p-rec as recid no-undo.
define input parameter        p-silent         as logical no-undo .
define input parameter        p-mode             as character no-undo .
define input parameter        p-tare-name      like ub.tare.tare-name no-undo .
define input parameter        p-tare-code      like ub.tare.tare-code  no-undo .
define input parameter        p-key#_one       as integer no-undo .
define input parameter        p-key#_two       as integer no-undo .
define input parameter        p-charkey_one    as character no-undo .
define input parameter        p-charkey_two    as character no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: tare01.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/tare01.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в карточке ТАРЫ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }

define variable v-db-num like ub.db.db-num no-undo .
define variable v-log         as logical   no-undo .
define variable v-err-mess as character no-undo .
define buffer buf_tare for ub.tare.

if p-mode <> {&add-def}
AND p-mode <> {&update} then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр p-mode" p-mode
  view-as alert-box error .
  return error '':u.
end.

{ gbl/curdbnum.i v-db-num }

if v-db-num <> 0
then do:
  v-err-mess = substitute("Нельзя изменять запись ТАРЫ в УБД: Номер текущей БД &1 ", v-db-num ).
  run err-mess in this-procedure ( input-output v-err-mess).
  undo, return error (if p-silent then v-err-mess else "":U).
end.

if p-tare-name = "":U then do:
  v-err-mess = substitute("Не указано полное наименование тары" ).
  run err-mess in this-procedure ( input-output v-err-mess).
  undo, return error (if p-silent then v-err-mess else "tare-name":U).

end.

if p-tare-code = "":U
or p-tare-code = ?
then do:
  v-err-mess = "Не указан код (аббревиатура) тары".
  run err-mess in this-procedure ( input-output v-err-mess).
  undo, return error (if p-silent then v-err-mess else "tare-code":U).
end.
if trim(p-tare-code) <> p-tare-code
then do:
  v-err-mess = "В коде (аббревиатуре) тары присутствуют недопустимые символы".
  run err-mess in this-procedure ( input-output v-err-mess).
  undo, return error (if p-silent then v-err-mess else "tare-code":U).
end.
if can-find(first buf_tare no-lock where
                  buf_tare.tare-code = p-tare-code
              AND (p-mode = {&add-def} OR p-rec <> recid(buf_tare))
              ) then do:
  v-err-mess = substitute("Уже есть такая ТАРА &1", p-tare-code).
  run err-mess in this-procedure ( input-output v-err-mess).
  undo, return error (if p-silent then v-err-mess else "tare-code":U).
end.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if p-mode = {&add-def} then do:
    create buf_tare.
    assign
    buf_tare.tare-code = p-tare-code
    .
  end.
  else do:
    FIND FIRST buf_tare where
              recid(buf_tare) = p-rec No-ERROR.
    if not available buf_tare then do:
      v-err-mess = substitute("&1 &2 &3&4Не найдена запись ТАРЫ - p-rec=&5"
                              ,vss-workfile
                              ,vss-revision
                              ,vss-description
                              , {&new-line}
                              ,p-rec).
      run err-mess in this-procedure ( input-output v-err-mess).
      undo main-block, return error (if p-silent then v-err-mess else "":U).
    end.
    if buf_tare.tare-code <> p-tare-code
    then do:
      v-err-mess = substitute("&1 &2 &3&4Для уже имеющейся записи нельзя изменить код тары&4ранее был &5 - попытка изменить на &6"
                              ,vss-workfile
                              ,vss-revision
                              ,vss-description
                              , {&new-line}
                              ,buf_tare.tare-code
                              ,p-tare-code
                               ).
      run err-mess in this-procedure ( input-output v-err-mess).
      undo main-block, return error (if p-silent then v-err-mess else "":U).
    end.
  end.
  assign
  buf_tare.tare-code = p-tare-code
  buf_tare.tare-name  = p-tare-name
  buf_tare.key#_one = p-key#_one
  buf_tare.key#_two = p-key#_two
  buf_tare.charkey_one = p-charkey_one
  buf_tare.charkey_two = p-charkey_two
  buf_tare.stts    =  (if p-mode = {&add-def}
                             then 0
                             else buf_tare.stts)
  p-rec = recid(buf_tare)
  .
  release buf_tare no-error.
  if error-status:error then do:
    v-err-mess = substitute("Ошибка при попытке сохранения записи:&1&2&1&3"
                            , {&new-line}
                            , error-status:get-message(1)
                            , return-value ).
    run err-mess in this-procedure ( input-output v-err-mess).
    undo main-block, return error (if p-silent then v-err-mess else "":U).
  end.
end. /*doe*/



PROCEDURE err-mess:
DEFINE INPUT-output PARAMETER p-mess as character No-UNDO.
if p-silent then do:
  assign
  p-mess = substitute("ТАРА: код &1&2:&3"
                      , (if p-mode = {&add-def} or not available buf_tare then p-tare-code else buf_tare.tare-code)
                      , {&new-line}
                      , p-mess)
  .
end.
else do:
  message
  p-mess
  view-as alert-box error .
end.

END PROCEDURE.