block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Очистка и экспорт складского архива по типам приобретени

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 09/26/01

*/

define input parameter p-obj-type         as character no-undo .
define input parameter p-obj-code         as integer   no-undo .
define input parameter p-last-fact-order  as decimal   no-undo .
define input parameter p-cut-fact-order   as decimal   no-undo .
define input parameter v-export-file-name as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Очистка и экспорт складского архива по типам приобретения".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ trg/factord.i  }
{ gbl/clntattr.i }

define variable v-export-archive as logical   no-undo .
define variable v-action         as character no-undo .
define stream slog .

main-block:
do
on error undo main-block, return error
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
  define variable v-start-time     as integer   no-undo .
  define variable v-current-time   as character no-undo .
  define variable v-current-action as character no-undo .
  define variable v-count          as integer   no-undo .
  define variable v-sub-action     as character no-undo .

  def frame a
    v-obj-type       label "Объект"
    v-obj-code       no-label skip
    v-current-action format "x(40)" no-label skip
    v-current-time   format "x(8)"  label "Время очистки архива" skip
    v-count          format ">>>,>>>,>>9" no-label skip
    v-sub-action     format "x(40)" no-label skip
    with view-as dialog-box side-labels three-d
    title v-action
    .

  assign
    v-obj-type   = p-obj-type
    v-obj-code   = p-obj-code
    v-start-time = time
  .
  view frame a .
  display
    v-obj-type
    v-obj-code
    with frame a .



  if v-export-archive = true
  then do:
    output stream slog to value(v-export-file-name) append .
  end.

  /* проверяем правильность задания объекта */
  define variable v-obj-exist as logical no-undo .
  { gbl/objat.i
    p-obj-type
    p-obj-code
    "'check-exist':u"
    v-obj-exist
  }

  /* проверяем дату задания интервала */
  if p-cut-fact-order = ?
  then do:
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
  if p-cut-fact-order = 0
  then do:
    /* по умолчанию обрабатываем весь архив */
    /* поэтому необходимо взять число, которое заведомо больше */
    /* чем любая возможная дата в системе */
    assign
      p-cut-fact-order = v-max-fact-order
    .
  end.

  /* определяем дату с которой в системе существуют правильные документы */
  define variable v-attr-value as character no-undo .
  define variable v-attr-type  as character no-undo .

  run clntattr-value in this-procedure
    (input  p-obj-type              /* p-obj-type */
    ,input  p-obj-code              /* p-obj-code */
    ,input  {&attr-aht-detail-date} /* p-code     */
    ,output v-attr-value            /* p-value    */
    ,output v-attr-type             /* p-type     */
    ) .

  /* считается, что все документы с датой фактического закрытия */
  /* больше или равной v-cut-date являются правильными и целостными */
  define variable v-cut-date       as date    no-undo .
  define variable v-cut-fact-order as decimal no-undo .

  if v-attr-type = {&type-date}
  then do:
    assign
      v-cut-date = date(v-attr-value)
    .
  end.
  else do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный тип атрибута aht-start-date=request" skip
      view-as alert-box error .
    undo, return error .
  end.

  run day-begin-fact-order in this-procedure
    (input  v-cut-date       /* p-last-fact-date  */
    ,output v-cut-fact-order /* p-last-fact-order */
    ).

  if p-last-fact-order = ?
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при задании входных параметров" skip
      "Не задана дата начиная с которой необходимо удалить складской архив по типам приобретения" skip
      "Объект" p-obj-type p-obj-code skip
      "v-cut-fact-order"  v-cut-fact-order skip
      "p-last-fact-order" p-last-fact-order skip
      view-as alert-box error .
    undo, return error .
  end.

  /* проверяем различные допустимые варианты для удаления складского архива по типам приобретения */
  if v-export-archive = false
  then do:
    if  (v-cut-fact-order  <= p-last-fact-order
         and p-last-fact-order <= p-cut-fact-order )
    or  (p-last-fact-order <= p-cut-fact-order
         and p-cut-fact-order <= v-cut-fact-order
        )
    then do:
      /* это правильные варианты */
    end.
    else do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при удалении складского архива по типам приобретения" skip
        "Неправильный диапазон удаления складского архива по типам приобретения" skip
        "Объект" p-obj-type p-obj-code skip
        "v-cut-fact-order"  v-cut-fact-order skip
        "p-last-fact-order" p-last-fact-order skip
        "p-cut-fact-order" p-cut-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
  end.

  run clear-aht-doc in this-procedure no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры clear-aht-doc" skip
      "Объект" p-obj-type p-obj-code skip
      "Начальная дата очистки" p-last-fact-order skip
      "Конечная дата очистки" p-cut-fact-order skip
      "Имя файла" v-export-file-name skip
      view-as alert-box error .
    undo, return error .
  end.

  run clear-aht-ot-line in this-procedure no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры clear-aht-ot-line" skip
      "Объект" p-obj-type p-obj-code skip
      "Начальная дата очистки" p-last-fact-order skip
      "Конечная дата очистки" p-cut-fact-order skip
      "Имя файла" v-export-file-name skip
      view-as alert-box error .
    undo, return error .
  end.

  run clear-aht-ot-tot in this-procedure no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры clear-aht-ot-tot" skip
      "Объект" p-obj-type p-obj-code skip
      "Начальная дата очистки" p-last-fact-order skip
      "Конечная дата очистки" p-cut-fact-order skip
      "Имя файла" v-export-file-name skip
      view-as alert-box error .
    undo, return error .
  end.

  run clear-aht-stk in this-procedure no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры clear-aht-stk" skip
      "Объект" p-obj-type p-obj-code skip
      "Начальная дата очистки" p-last-fact-order skip
      "Конечная дата очистки" p-cut-fact-order skip
      "Имя файла" v-export-file-name skip
      view-as alert-box error .
    undo, return error .
  end.

  run clear-aht-stk-line in this-procedure no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры clear-aht-stk-line" skip
      "Объект" p-obj-type p-obj-code skip
      "Начальная дата очистки" p-last-fact-order skip
      "Конечная дата очистки" p-cut-fact-order skip
      "Имя файла" v-export-file-name skip
      view-as alert-box error .
    undo, return error .
  end.

  run clear-aht-stk-tot in this-procedure no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры clear-aht-stk-tot" skip
      "Объект" p-obj-type p-obj-code skip
      "Начальная дата очистки" p-last-fact-order skip
      "Конечная дата очистки" p-cut-fact-order skip
      "Имя файла" v-export-file-name skip
      view-as alert-box error .
    undo, return error .
  end.

  if v-export-archive = true
  then do:
    output stream slog close .
  end.
end.


procedure show-action :
  define input  parameter p-action as character no-undo .

  do
  on error undo, return error
  :

    assign
      v-current-time = string(time - v-start-time, "HH:MM:SS")
      v-current-action = p-action
    .
    display
      v-current-time
      v-current-action
      with frame a.
  end.
end procedure. /* show-action */

procedure show-count :
  define input  parameter p-count      as integer   no-undo .
  define input  parameter p-sub-action as character no-undo .

  do
  on error undo, return error
  :
    assign
      v-current-time = string(time - v-start-time, "HH:MM:SS")
      v-count        = p-count
      v-sub-action   = p-sub-action
    .
    display
      v-current-time
      v-count
      v-sub-action
      with frame a.
  end.
end procedure. /* show-action */


procedure clear-aht-doc :

  do
  on error undo, return error return-value
  :
    define buffer buf_aht-doc for ub.aht-doc .

    define variable v-ind as integer   no-undo .

    run show-action in this-procedure
      (input "Итоги по документам"
      ).

    for each buf_aht-doc
      where buf_aht-doc.obj-type   = p-obj-type
        and buf_aht-doc.obj-code   = p-obj-code
        and buf_aht-doc.fact-order > p-last-fact-order
        and buf_aht-doc.fact-order <= p-cut-fact-order
    on error undo, return error
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-ind
          ,input "Документ " + string(buf_aht-doc.doc-code)
          ).
      end.

      if v-export-archive = true
      then do:
        export stream slog {&table_aht-doc} .
        export stream slog buf_aht-doc .
      end.
      else do:
        delete buf_aht-doc .
      end.
    end.
  end.

end procedure. /* clear-aht-doc */


procedure clear-aht-ot-line :

  do
  on error undo, return error return-value
  :
    define buffer buf_aht-ot-line for ub.aht-ot-line .

    define variable v-ind as integer   no-undo .

    run show-action in this-procedure
      (input "Итоги по документам"
      ).

    for each buf_aht-ot-line
      where buf_aht-ot-line.obj-type   = p-obj-type
        and buf_aht-ot-line.obj-code   = p-obj-code
        and buf_aht-ot-line.fact-order > p-last-fact-order
        and buf_aht-ot-line.fact-order <= p-cut-fact-order
    on error undo, return error
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-ind
          ,input "Документ " + string(buf_aht-ot-line.doc-code)
          ).
      end.

      if v-export-archive = true
      then do:
        export stream slog {&table_aht-ot-line} .
        export stream slog buf_aht-ot-line .
      end.
      else do:
        delete buf_aht-ot-line .
      end.
    end.
  end.

end procedure. /* clear-aht-ot-line */


procedure clear-aht-ot-tot :

  do
  on error undo, return error return-value
  :
    define buffer buf_aht-ot-tot for ub.aht-ot-tot .

    define variable v-ind as integer   no-undo .

    run show-action in this-procedure
      (input "Итоги по документам"
      ).

    for each buf_aht-ot-tot
      where buf_aht-ot-tot.obj-type   = p-obj-type
        and buf_aht-ot-tot.obj-code   = p-obj-code
        and buf_aht-ot-tot.fact-order > p-last-fact-order
        and buf_aht-ot-tot.fact-order <= p-cut-fact-order
    on error undo, return error
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-ind
          ,input "Документ " + string(buf_aht-ot-tot.doc-code)
          ).
      end.

      if v-export-archive = true
      then do:
        export stream slog {&table_aht-ot-tot} .
        export stream slog buf_aht-ot-tot .
      end.
      else do:
        delete buf_aht-ot-tot .
      end.
    end.
  end.

end procedure. /* clear-aht-ot-tot */


procedure clear-aht-stk :

  do
  on error undo, return error return-value
  :
    define buffer buf_aht-stk for ub.aht-stk .

    define variable v-ind as integer   no-undo .

    run show-action in this-procedure
      (input "Итоги по документам"
      ).

    for each buf_aht-stk
      where buf_aht-stk.obj-type   = p-obj-type
        and buf_aht-stk.obj-code   = p-obj-code
        and buf_aht-stk.fact-order > p-last-fact-order
        and buf_aht-stk.fact-order <= p-cut-fact-order
    on error undo, return error
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-ind
          ,input "Документ " + string(buf_aht-stk.fact-date)
          ).
      end.

      if v-export-archive = true
      then do:
        export stream slog {&table_aht-stk} .
        export stream slog buf_aht-stk .
      end.
      else do:
        delete buf_aht-stk .
      end.
    end.
  end.

end procedure. /* clear-aht-stk */



procedure clear-aht-stk-line :

  do
  on error undo, return error return-value
  :
    define buffer buf_aht-stk-line for ub.aht-stk-line .

    define variable v-ind as integer   no-undo .

    run show-action in this-procedure
      (input "Итоги по документам"
      ).

    for each buf_aht-stk-line
      where buf_aht-stk-line.obj-type   = p-obj-type
        and buf_aht-stk-line.obj-code   = p-obj-code
        and buf_aht-stk-line.fact-order > p-last-fact-order
        and buf_aht-stk-line.fact-order <= p-cut-fact-order
    on error undo, return error
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-ind
          ,input "Документ " + string(buf_aht-stk-line.gds-code)
          ).
      end.

      if v-export-archive = true
      then do:
        export stream slog {&table_aht-stk-line} .
        export stream slog buf_aht-stk-line .
      end.
      else do:
        delete buf_aht-stk-line .
      end.
    end.
  end.

end procedure. /* clear-aht-stk-line */


procedure clear-aht-stk-tot :

  do
  on error undo, return error return-value
  :
    define buffer buf_aht-stk-tot for ub.aht-stk-tot .

    define variable v-ind as integer   no-undo .

    run show-action in this-procedure
      (input "Итоги по документам"
      ).

    for each buf_aht-stk-tot
      where buf_aht-stk-tot.obj-type   = p-obj-type
        and buf_aht-stk-tot.obj-code   = p-obj-code
        and buf_aht-stk-tot.fact-order > p-last-fact-order
        and buf_aht-stk-tot.fact-order <= p-cut-fact-order
    on error undo, return error
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-ind
          ,input "Документ " + string(buf_aht-stk-tot.fact-order)
          ).
      end.

      if v-export-archive = true
      then do:
        export stream slog {&table_aht-stk-tot} .
        export stream slog buf_aht-stk-tot .
      end.
      else do:
        delete buf_aht-stk-tot .
      end.
    end.
  end.

end procedure. /* clear-aht-stk-tot */