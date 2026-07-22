block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: wth-gds.p $
$Archive: ref/wth-gds.p $

Добавление\изменение записи в таблице связи МЦ с товарами

Автор: Гридчина Полина Дмитриевна
Дата создания: 09/04/07
Author: Polina Gridchina
Creation date: 09/04/07

Input:

Output:

*/

define input parameter        p-mode as character no-undo .
define input parameter        p-silent as logical no-undo .
define input-output parameter p-rec  as recid     no-undo .
define input PARAMETER        p-wth-code LIKE ub.wealth.wth-code NO-UNDO.
define input PARAMETER        p-gds LIKE ub.wth-gds.gds-code NO-UNDO.
define input parameter        p-stts like ub.wth-gds.stts no-undo.


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: wth-gds.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/wth-gds.p $":U .
define variable vss-description as character no-undo init "Добавление\изменение записи в таблице связи МЦ с товарами".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }

define variable v-mess as character no-undo .
define buffer buf_wth-gds for ub.wth-gds.
define buffer buf_wealth for ub.wealth.
define buffer buf_goods for ub.goods.


 if p-mode <> {&add-def}
 AND p-mode <> {&update} then do:
   message vss-workfile vss-revision vss-description skip
           "Неверный параметр p-mode - " p-mode
   view-as alert-box error .
   return error '':u.
 end.

main-block:
do
 on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
 on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
 on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  find first  buf_goods where buf_goods.gds-code = p-gds no-lock no-error.
   if not available buf_goods then do:
     v-mess = substitute("Не найден товар с кодом &1",p-gds).
     run err-mess in this-procedure ( input-output v-mess).
     return error (if p-silent = yes then v-mess else 'gds-code':U).
   end.
  FIND FIRST  buf_wealth where buf_wealth.wth-code = p-wth-code  NO-LOCK NO-ERROR.
   if not available buf_wealth then do:
     v-mess = substitute("Не найдена МЦ с кодом &1",p-wth-code).
     run err-mess in this-procedure ( input-output v-mess).
     return error (if p-silent = yes then v-mess else 'wth-code':U).
   end.
  if p-mode = {&add-def} then do:
    create buf_wth-gds.
  end.
  else do:
    find first buf_wth-gds where RECID(buf_wth-gds) = p-rec exclusive-lock no-wait no-error.
    if not available buf_wth-gds then do:
      v-mess = substitute('Запись связи МЦ с товаром не найдена!').
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
  end.
    assign
    buf_wth-gds.wth-code = p-wth-code
    buf_wth-gds.gds-code = p-gds
    buf_wth-gds.stts = p-stts
    p-rec = recid(buf_wth-gds)
  .
  release buf_wth-gds no-error .
  if error-status:error then do:
    v-mess = substitute("Ошибка при сохранения связи МЦ с товарами:&1&2&3"
                         , error-status:get-message(1)
                         , {&new-line}
                         , return-value
                         ).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else '':U).
  end.
end. /*doe*/

PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Материальная ценность: код &1&3&4"
                         , p-wth-code
                         , {&new-line}
                         , p-mess)
      .
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.