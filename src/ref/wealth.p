block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: wealth.p $
$Archive: ref/wealth.p $

Сохранение МЦ

Автор: Гридчина Полина Дмитриевна
Дата создания: 05/10/07
Author: Polina Gridchina
Creation date: 05/10/07

Input:

Output:

*/
define input parameter        p-mode as character no-undo .
define input parameter        p-silent as logical no-undo .
define input-output parameter p-rec  as recid     no-undo .
define input PARAMETER        p-wth-code LIKE ub.wealth.wth-code NO-UNDO.
define input PARAMETER        p-money AS LOG NO-UNDO.
define input PARAMETER        p-ser AS INT NO-UNDO.
define input PARAMETER        p-unit LIKE ub.wealth.unit-base no-undo.
define input PARAMETER        p-curr-code LIKE ub.wealth.curr-code NO-UNDO.
define input PARAMETER        p-name LIKE ub.wealth.wth-name NO-UNDO.
define input  parameter       p-get-qnty-method as character no-undo .
define input PARAMETER        p-ps LIKE ub.wealth.ps NO-UNDO.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: wealth.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/wealth.p $":U .
define variable vss-description as character no-undo init "Сохранение МЦ".
{ cmp/vssrevis.i }
{ cmp/library.i  }
{ cmp/trg-def.i }

define variable v-mess as character no-undo .
define buffer buf_wealth for ub.wealth.



/* if p-mode <> {&add-def}                                   */
/* AND p-mode <> {&update} then do:                          */
/*   message vss-workfile vss-revision vss-description skip  */
/*           "Неверный параметр p-mode - " p-mode            */
/*   view-as alert-box error .                               */
/*   return error '':u.                                      */
/* end.                                                      */

main-block:
do
 on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
 on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
 on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
    if p-name = "" then do:
        v-mess =  "Введите название МЦ" .
        run err-mess in this-procedure ( input-output v-mess).
        return error (if p-silent = yes then v-mess else 'wth-name':U).
    end.
    if p-money = yes and p-curr-code = ? then do:
        v-mess = "Для материальных ценностей - денежных средств или имеющих денежный эквивалент~n
              необходимо ввести код валюты" .
        run err-mess in this-procedure ( input-output v-mess).
        return error (if p-silent = yes then v-mess else 'curr-code':U).
    end.
    if NOT p-money /*and p-ser = 0*/ and p-unit = "" then do:
        v-mess = "Для материальных ценностей - не денежных средств  или не имеющих денежный эквивалент~n
                  необходимо ввести единицу измерения" .
        run err-mess in this-procedure ( input-output v-mess).
        return error (if p-silent = yes then v-mess else 'unit-base':U).
    end.

/*  find first buf_wealth no-lock where
          buf_wealth.wth-code = p-wth-code no-error .
  if not available buf_wealth then do:
    v-mess = substitute("Не найдена МЦ").
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'wth-code':U).
  end.    */

  if Lookup(p-get-qnty-method, {&wth-qnty-methods}) = 0 then do:
     v-mess = substitute("Неверное значение метода получения кол-ва МЦ = &1", p-get-qnty-method).
     run err-mess in this-procedure ( input-output v-mess).
     return error (if p-silent = yes then v-mess else 'wth-code':U).
  end.

  if p-mode = {&add-def} then do:
    create buf_wealth.
      assign
      buf_wealth.wth-code = next-value(s-wth-code, {&db-name_schema})    .
  end.
  else  find first buf_wealth where  recid(buf_wealth) = p-rec exclusive-lock no-error.
  if not available buf_wealth then do:
     v-mess = substitute("Не найдена МЦ").
     run err-mess in this-procedure ( input-output v-mess).
     return error (if p-silent = yes then v-mess else 'wth-code':U).
   end.

    assign
    buf_wealth.wth-name = p-name
    buf_wealth.curr-code = p-curr-code
    buf_wealth.PS = p-PS
    buf_wealth.is-money = p-money
    buf_wealth.is-ser = p-ser
    buf_wealth.unit-base = /*if p-ser = 1 then '':U else */ p-unit
    buf_wealth.get-qnty-method = p-get-qnty-method
    p-rec = recid(buf_wealth)
  .

  release buf_wealth no-error .
  if error-status:error then do:
    v-mess = substitute("Ошибка при сохранения МЦ:&1&2&3"
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