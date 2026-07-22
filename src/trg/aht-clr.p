block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Удаление складского архива по типу приобретени

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 12/10/02

*/

define input parameter p-obj-type         as character no-undo .
define input parameter p-obj-code         as integer   no-undo .
define input parameter p-last-fact-order  as decimal   no-undo .
define input parameter p-cut-fact-order   as decimal   no-undo .
define input parameter v-export-file-name as character no-undo .

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Удаление складского архива по типу приобретения".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ trg/factord.i  }

define variable v-export-archive as logical   no-undo .
define variable v-action         as character no-undo .
define variable v-ind            as integer   no-undo .

define stream slog .

do
on error undo, return error return-value
:
  if  v-export-file-name <> ""
  and v-export-file-name <> ?
  then do:
    assign
      v-export-archive = true
      v-action         = "Экспорт складского архива по типам приобретения"
    .
  end.
  else do:
    assign
      v-export-archive = false
      v-action         = "Очистка складского архива по типам приобретения"
    .
  end.

  define variable v-obj-type       like ub.gds-obj.obj-type no-undo .
  define variable v-obj-code       like ub.gds-obj.obj-code no-undo .
  define variable v-start-etime    as int64     no-undo .
  define variable v-exec-time      as character no-undo .
  define variable v-current-action as character no-undo .
  define variable v-count          as integer   no-undo .
  define variable v-sub-action     as character no-undo .

  def frame a
    v-obj-type       label "Объект"
    v-obj-code       no-label skip
    v-current-action format "x(40)" no-label skip
    v-exec-time      format "x(8)"  label "Время очистки архива" skip
    v-count          format ">>>,>>>,>>9" no-label skip
    v-sub-action     format "x(40)" no-label skip
    with view-as dialog-box side-labels three-d
    title v-action
    .

  assign
    v-obj-type    = p-obj-type
    v-obj-code    = p-obj-code
    v-start-etime = etime
  .
  view frame a .
  display
    v-obj-type
    v-obj-code
    with frame a .

  if v-export-archive = true then do:
    output stream slog to value(v-export-file-name) append .
  end.

  /* проверяем правильность задания объекта */
  define variable v-obj-exist as logical   no-undo .
  { gbl/objat.i
    p-obj-type
    p-obj-code
    "'check-exist':u"
    v-obj-exist
  }

  /* проверяем дату задания интервала */
  if p-cut-fact-order = ? then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Объект" p-obj-type p-obj-code skip
      "p-cut-fact-order" p-cut-fact-order skip
      view-as alert-box error .
    undo, return error .
  end.

  define variable v-max-fact-order as decimal   no-undo .

  run factord-max-fact-order in this-procedure
    (output v-max-fact-order /* p-max-fact-order */
    ) .

  /* если входной параметр не задан, то удаляем весь архив */
  /* то есть от последнего до максимально возможного fact-order */
  if p-cut-fact-order = 0 then do:
    /* по умолчанию обрабатываем весь архив */
    /* поэтому необходимо взять число, которое заведомо больше */
    /* чем любая возможная дата в системе */
    assign
      p-cut-fact-order = v-max-fact-order
    .
  end.

  define buffer buf_aht-ot-tot for ub.aht-ot-tot .

  for each buf_aht-ot-tot exclusive-lock
    where buf_aht-ot-tot.obj-type = p-obj-type
      and buf_aht-ot-tot.obj-code = p-obj-code
      and buf_aht-ot-tot.fact-order > p-last-fact-order
      and buf_aht-ot-tot.fact-order <= p-cut-fact-order
  on error undo, return error return-value
  :
    assign
      v-ind = v-ind + 1
    .
    if v-ind modulo 10 = 0 then do:
      run show-count in this-procedure
        (input v-ind
        ,input "Документ " + string(buf_aht-ot-tot.doc-code)
        ).
    end.

    if v-export-archive = true then do:
      export stream slog "aht-ot-tot" .
      export stream slog buf_aht-ot-tot .
    end.
    else do:
      delete buf_aht-ot-tot .
    end.
  end.

  define buffer buf_aht-ot-line for ub.aht-ot-line .
  for each buf_aht-ot-line exclusive-lock
    where buf_aht-ot-line.obj-type = p-obj-type
      and buf_aht-ot-line.obj-code = p-obj-code
      and buf_aht-ot-line.fact-order > p-last-fact-order
      and buf_aht-ot-line.fact-order <= p-cut-fact-order
  on error undo, return error return-value
  :
    assign
      v-ind = v-ind + 1
    .
    if v-ind modulo 10 = 0 then do:
      run show-count in this-procedure
        (input v-ind
        ,input "Строки документа " + string(buf_aht-ot-line.doc-code)
        ).
    end.

    if v-export-archive = true then do:
      export stream slog "aht-ot-line" .
      export stream slog buf_aht-ot-line .
    end.
    else do:
      delete buf_aht-ot-line .
    end.
  end.

  define buffer buf_aht-stk-tot for ub.aht-stk-tot .
  for each buf_aht-stk-tot exclusive-lock
    where buf_aht-stk-tot.obj-type = p-obj-type
      and buf_aht-stk-tot.obj-code = p-obj-code
      and buf_aht-stk-tot.fact-order > p-last-fact-order
      and buf_aht-stk-tot.fact-order <= p-cut-fact-order
  on error undo, return error return-value
  :
    assign
      v-ind = v-ind + 1
    .
    if v-ind modulo 10 = 0 then do:
      run show-count in this-procedure
        (input v-ind
        ,input "Остатки по объекту"
        ).
    end.

    if v-export-archive = true then do:
      export stream slog "aht-stk-tot" .
      export stream slog buf_aht-stk-tot .
    end.
    else do:
      delete buf_aht-stk-tot .
    end.
  end.

  define buffer buf_aht-stk-line for ub.aht-stk-line .
  for each buf_aht-stk-line exclusive-lock
    where buf_aht-stk-line.obj-type = p-obj-type
      and buf_aht-stk-line.obj-code = p-obj-code
      and buf_aht-stk-line.fact-order > p-last-fact-order
      and buf_aht-stk-line.fact-order <= p-cut-fact-order
  on error undo, return error return-value
  :
    assign
      v-ind = v-ind + 1
    .
    if v-ind modulo 10 = 0 then do:
      run show-count in this-procedure
        (input v-ind
        ,input "Остатки по товару " + string(buf_aht-stk-line.gds-code)
        ).
    end.

    if v-export-archive = true then do:
      export stream slog "aht-stk-line" .
      export stream slog buf_aht-stk-line .
    end.
    else do:
      delete buf_aht-stk-line .
    end.
  end.

  define buffer buf_aht-stk for ub.aht-stk .
  for each buf_aht-stk exclusive-lock
    where buf_aht-stk.obj-type = p-obj-type
      and buf_aht-stk.obj-code = p-obj-code
      and buf_aht-stk.fact-order > p-last-fact-order
      and buf_aht-stk.fact-order <= p-cut-fact-order
  on error undo, return error return-value
  :
    assign
      v-ind = v-ind + 1
    .
    if v-ind modulo 10 = 0 then do:
      run show-count in this-procedure
        (input v-ind
        ,input "Даты остатков на объекте " + string(buf_aht-stk.fact-date)
        ).
    end.

    if v-export-archive = true then do:
      export stream slog "aht-stk" .
      export stream slog buf_aht-stk.
    end.
    else do:
      delete buf_aht-stk .
    end.
  end.

  define buffer buf_aht-doc for ub.aht-doc .
  for each buf_aht-doc exclusive-lock
    where buf_aht-doc.obj-type = p-obj-type
      and buf_aht-doc.obj-code = p-obj-code
      and buf_aht-doc.fact-order > p-last-fact-order
      and buf_aht-doc.fact-order <= p-cut-fact-order
  on error undo, return error return-value
  :
    assign
      v-ind = v-ind + 1
    .
    if v-ind modulo 10 = 0 then do:
      run show-count in this-procedure
        (input v-ind
        ,input "Номера документов " + string(buf_aht-doc.doc-code)
        ).
    end.

    if v-export-archive = true then do:
      export stream slog "aht-doc" .
      export stream slog buf_aht-doc .
    end.
    else do:
      delete buf_aht-doc .
    end.
  end.

  if v-export-archive = true then do:
    output stream slog close .
  end.

end.

procedure show-count :
  define input  parameter p-count      as integer   no-undo .
  define input  parameter p-sub-action as character no-undo .

  do
  on error undo, return error
  :
    assign
      v-exec-time = string(etime - v-start-etime, "HH:MM:SS")
      v-count        = p-count
      v-sub-action   = p-sub-action
    .
    display
      v-exec-time
      v-count
      v-sub-action
      with frame a.
  end.
end procedure. /* show-action */