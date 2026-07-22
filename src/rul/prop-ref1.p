block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Сохранение prop-ref

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/11/07
Author: Bakhtadze Natalya
Creation date: 02/11/07

*/

define input parameter        p-mode as character no-undo .
define input parameter        p-silent as logical no-undo .
define input-output parameter p-rec  as recid     no-undo .
define input parameter        p-dt-code as integer no-undo .
define input parameter        p-sum-id as character no-undo .
define input parameter        p-dtm-code as integer no-undo .
define input parameter        p-call-id as character no-undo .
define input parameter        p-ref-type as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сохранение prop-ref".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ rul/propreft.i }
{ gbl/cur-time.i }
define variable v-mess as character no-undo .
define variable v-entry as character no-undo .
define variable v-dis-card-storage as character no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer buf_prop-ref for ub.prop-ref.
define buffer buf2_prop-ref for ub.prop-ref.
define buffer buf_prop-head for ub.prop-head.

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

_main:
do for buf_prop-ref
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:
  assign
  v-dis-card-storage = '':U + {&comma-char} +
                       {&question-mark} + {&comma-char} +
                       {&table_dis-card} + {&comma-char} +
                       {&table_dis-obj} + {&comma-char} +
                       {&table_dis-card-property}.


  if p-dtm-code = 0 then do:
    assign
    v-mess = substitute("Неверный объект-операнд  с кодом &1", p-dtm-code).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'dtm-code':U).
  end.
  find first buf_prop-head no-lock where
            buf_prop-head.dtm-code  = p-dtm-code no-error.
  if not available buf_prop-head then do:
    assign
    v-mess = substitute("Не найден объект-операнд  с кодом &1", p-dtm-code).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'dtm-code':U).
  end.
  if lookup(buf_prop-head.storage-place, v-dis-card-storage) = 0
  and lookup(buf_prop-head.storage-place-host, v-dis-card-storage) = 0
  and lookup(buf_prop-head.storage-place-obj, v-dis-card-storage) = 0 then do:
    assign
    v-mess = substitute("Объект-операнд  с кодом &1 не предназначен для хранения данных по ДК", p-dtm-code).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'dtm-code':U).
  end.
  if p-sum-id = '':u
  then do:
    assign
    v-mess = substitute("Мнемонический идентификатор может быть пустым только&1" +
                       "для основного среза - с кодом 0").
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'sum-id':U).
  end.
  if lookup(p-ref-type, {&sum-id-type-list}) = 0 then do:
    assign
    v-mess = substitute("Неверный тип идентификатора &1", p-ref-type).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'ref-type':U).
  end.
  /*
  if p-ref-type <> {&sum-id-type-period}
  and p-call-id <> '':U then do:
&scoped-define  sum-id-type-code  ~{&sum-id-type-period~}
    assign
    v-mess = substitute("Доп.идентификатор может быть задан только для итогов/срезов типа &1", {&sum-id-type-name} ).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'ref-type':U).
  end.
  */
  if p-mode = {&add-def} then do:
    if p-dt-code = 0 then do:
      find last buf_prop-ref no-lock use-index pi no-error.
      assign
      p-dt-code = buf_prop-ref.dt-code + 1.
    end.
    else do:
      find first buf_prop-ref no-lock where
            buf_prop-ref.dt-code = p-dt-code no-error.
      if available buf_prop-ref then do:
        assign
        v-mess = "Уже существует Срез c таким кодом".
        run err-mess in this-procedure ( input-output v-mess).
        return error (if p-silent = yes then v-mess else 'dt-code':U).
      end.
    end.
    find first buf2_prop-ref no-lock where
              buf2_prop-ref.dtm-code = p-dtm-code
         and  buf2_prop-ref.sum-id = p-sum-id
         and buf2_prop-ref.caller_id = p-call-id no-error.
    if available buf2_prop-ref then do:
      assign
      v-mess = substitute("Уже существует Срез c таким мнемонич идентификатором  &1 и кодом объекта &2 и доп.идентификатором &3"
                            ,p-sum-id
                            ,p-dtm-code
                            ,p-call-id).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'dtm-code':U).
    end.
    if p-ref-type = {&sum-id-type-period} then do:
      /*проверим что диапазоны не пересекаются*/
      define variable v-date-from as date no-undo .
      define variable v-date-to as date no-undo .
      define variable v-date-from2 as date no-undo .
      define variable v-date-to2 as date no-undo .
      assign
      v-date-from = propreft-string-to-date( entry(1, p-sum-id, "-"))
      v-date-to = propreft-string-to-date( entry(2, p-sum-id, "-"))
      .
      run cur-time in this-procedure ( output v-today, output v-time).
      if v-date-from <= v-today then do:
        assign
        v-mess = substitute("Нельзя ввести частный итог для текущего периода времени").
        run err-mess in this-procedure ( input-output v-mess).
        return error (if p-silent = yes then v-mess else 'dtm-code':U).

      end.
      for each buf2_prop-ref no-lock where
                buf2_prop-ref.dtm-code = p-dtm-code
            and buf2_prop-ref.caller_id = p-call-id:

        assign
        v-date-from2 = propreft-string-to-date( entry(1, buf2_prop-ref.sum-id, "-"))
        v-date-to2 = propreft-string-to-date( entry(2,  buf2_prop-ref.sum-id, "-"))
        .
        if v-date-from <= v-date-from2
        and v-date-to >= v-date-to2
        /*новый итог вокруг старого*/
        then leave.

        if v-date-from >= v-date-from2
        and v-date-to <= v-date-to2
        /*новый итог внутри старого*/
        then leave.

        if v-date-from <= v-date-from2
        and v-date-to >= v-date-from2
        and v-date-to <= v-date-to2
        /*пересечение*/
        then leave.

        if v-date-from >= v-date-from2
        and v-date-from <= v-date-to2
        and v-date-to >= v-date-to2
        /*пересечение*/
        then leave.
      end.
      if available buf2_prop-ref then do:
        assign
        v-mess = substitute("Уже существует Срез &1 c кодом объекта &2 и доп.идентификатором &3, который захватывает период дат &4"
                              ,buf2_prop-ref.dt-code
                              ,p-dtm-code
                              ,p-call-id
                              ,p-sum-id
                              ).
        run err-mess in this-procedure ( input-output v-mess).
        return error (if p-silent = yes then v-mess else 'dtm-code':U).
      end.
    end.
    create buf_prop-ref.
    assign
    buf_prop-ref.dt-code = p-dt-code
    .
  end.
  if p-mode = {&update} then do:
    find first buf_prop-ref exclusive-lock where
              recid(buf_prop-ref) = p-rec .
    if buf_prop-ref.dt-code <> p-dt-code
    then do:
      assign
      v-mess = substitute("Для уже существующего среза невозможно изменение кода&1" +
                              "старые значения кода: &2"
                              , {&new-line}
                              , buf_prop-ref.dt-code)
      .
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'dt-code':U).
    end.
  end.
  assign
  buf_prop-ref.sum-id  = p-sum-id
  buf_prop-ref.dtm-code  = p-dtm-code
  buf_prop-ref.caller_id  = p-call-id
  buf_prop-ref.ref-type  = p-ref-type
  p-rec = recid(buf_prop-ref)
  .
end.  /*_main:*/

PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Срез данных по ДК код: &1 &2"
                         , p-dtm-code
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