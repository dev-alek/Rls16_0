block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: wth-par1.p $
$Archive: ref/wth-par1.p $

Сохранение номинала МЦ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/18/07
Author: Bakhtadze Natalya
Creation date: 04/18/07

*/

define input parameter        p-mode as character no-undo .
define input parameter        p-silent as logical no-undo .
define input-output parameter p-rec  as recid     no-undo .
define input parameter p-wth-code as integer no-undo .
define input parameter p-par-code as integer no-undo .
define input parameter p-par-val  as integer no-undo .
define input parameter p-par-feat as character no-undo .
define input parameter p-par-rate as decimal no-undo .
define input parameter p-par-unit as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: wth-par1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/wth-par1.p $":U .
define variable vss-description as character no-undo init "Сохранение номинала МЦ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

define variable v-mess as character no-undo .
define buffer buf_wealth for ub.wealth.
define buffer buf_wth-par for ub.wth-par.


if p-mode <> {&add-def}
AND p-mode <> {&update} then do:
  message vss-workfile vss-revision vss-description skip
          "Неверный параметр p-mode - " p-mode
  view-as alert-box error .
  return error '':u.
end.

if g#db-num <> 0 then do:
  message vss-workfile vss-revision vss-description skip
          "Запрещено вызывать процедуру в УБД"
  view-as alert-box error .
  return error '':u.
end.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  find first buf_wealth no-lock where
          buf_wealth.wth-code = p-wth-code no-error .
  if not available buf_wealth then do:
    v-mess = substitute("Не найдена МЦ").
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'wth-code':U).
  end.
  if p-par-val = ?
  or p-par-val = 0 then do:
    v-mess = "Не определено значение номинала" .
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'par-val':U).
  end.
  if p-par-rate = ?
  or p-par-rate = 0 then do:
    v-mess = "Не определен коэффициент" .
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'par-rate':U).
  end.
  if (p-par-feat = "" or p-par-feat = ? )
  and buf_wealth.is-money then do:
    v-mess = substitute("Для материальных ценностей - денежных средств или имеющих денежный эквивалент&1" +
                        "необходимо указать дополнительный признак"
                        , {&new-line}).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'par-feat':U).
  end.
  if buf_wealth.is-money = no then do:
    if p-par-unit = ? or p-par-unit = "" then do:
      v-mess = substitute("Укажите ед. изм. номинала или выберите ее из справочника единиц измерения").
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'par-unit':U).
    end.
    if (p-par-rate <> p-par-val)
    AND p-par-unit = buf_wealth.unit-base
    then do:
      v-mess = substitute("Ед. изм. номинала совпадает с базовой ед.изм. МЦ, а коэффициент не равен значению номинала").
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'par-unit':U).
    end.
  end.
  else do:
    if p-par-unit = ? or p-par-unit = "" then do:
      v-mess = substitute("Не задана ед. изм. номинала").
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'par-unit':U).
    end.
  end.
  if p-mode = {&add-def} then do:
    create buf_wth-par.
    assign
    buf_wth-par.par-code = next-value(s-par-code, {&db-name_schema})
    buf_wth-par.wth-code = p-wth-code
    .
  end.
  if p-mode = {&update} then do:
    find first buf_wth-par exclusive-lock where
              recid(buf_wth-par) = p-rec .
    if buf_wth-par.par-code <> p-par-code
    or buf_wth-par.wth-code <> p-wth-code then do:
      v-mess = substitute("Для уже имеющейся записи Номинала МЦ нельзя изменить код МЦ или код Номинала&1" +
                           "старый код МЦ - &2, старый код номинала &3"
                           ,{&new-line}
                           , buf_wth-par.wth-code
                           , buf_wth-par.par-code).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
  end.
  assign
  buf_wth-par.par-val = p-par-val
  buf_wth-par.par-unit = p-par-unit
  buf_wth-par.par-feat = p-par-feat
  buf_wth-par.par-rate = p-par-rate
  p-rec = recid(buf_wth-par)
  .
  release buf_wth-par no-error .
  if error-status:error then do:
    v-mess = substitute("Ошибка при сохранения записи номинала МЦ:&1&2&3"
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
      p-mess = substitute("Номинал МЦ: код МЦ &1 код номинала &2&3&4"
                         , p-wth-code
                         , p-par-code
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