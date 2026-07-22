block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cmpraht.p $
$Archive: utl/cmpraht.p $

Программа удаления подробной информации в складсом архиве по типам приобретения.

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 01/09/04

*/

define input parameter p-obj-type         as character no-undo .
define input parameter p-obj-code         as integer   no-undo .
define input parameter p-last-fact-order  as decimal   no-undo .
define input parameter p-cut-fact-order   as decimal   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cmpraht.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/cmpraht.p $":U .
define variable vss-description as character no-undo init "Программа удаления подробной информации в складском архиве по типам приобретения".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ trg/factord.i  }
{ gbl/clntattr.i }


&scop def-temp-fact-order define temp-table temp-fact-order no-undo ~
  field temp-gds-code    like ub.aht-stk-line.gds-code ~
  field temp-sum-type    like ub.aht-stk-line.sum-type ~
  field temp-fact-order  like ub.aht-stk-line.fact-order ~
  field temp-break-value as integer ~
  field temp-need-delete as logical ~
  index xpk is primary unique temp-gds-code temp-sum-type temp-fact-order ~
  index xie1 temp-need-delete ~
  index xie2 temp-gds-code temp-sum-type temp-break-value ~
.

&scop def-temp-last-fact-order define temp-table temp-last-fact-order no-undo ~
  field temp-gds-code    like ub.aht-stk-line.gds-code ~
  field temp-sum-type    like ub.aht-stk-line.sum-type ~
  field temp-break-value as integer ~
  field temp-fact-order  like ub.aht-stk-line.fact-order ~
  index xpk is primary unique temp-gds-code temp-sum-type temp-break-value ~
.

{&def-temp-fact-order}
{&def-temp-last-fact-order}

define variable v-ind   as integer   no-undo .

do
on error undo, return error
:

  define variable v-start-time     as integer   no-undo .
  define variable v-current-time   as character no-undo .
  define variable v-current-action as character no-undo .
  define variable v-count          as integer   no-undo .
  define variable v-sub-action     as character no-undo .

  define frame a
    p-obj-type       label "Объект"
    p-obj-code       no-label skip
    v-current-action format "x(40)" no-label skip
    v-current-time   format "x(8)"  label "Время очистки складского архива" skip
    v-count          format ">>>,>>>,>>9" no-label skip
    v-sub-action     format "x(40)" no-label skip
    with view-as dialog-box side-labels three-d
    title "Очистка складского архива по типам приобретения"
    .

  assign
    v-start-time = time
  .
  view frame a .
  display
    p-obj-type
    p-obj-code
    with frame a .

  /* проверяем правильность задания объекта */
  define variable l-obj-exist as logical no-undo .
  { gbl/objat.i
    p-obj-type
    p-obj-code
    "'check-exist':u"
    l-obj-exist
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

  /* если входной параметр не задан, то удаляем весь складской архив */
  /* то есть от последнего до максимально возможного fact-order */
  if p-cut-fact-order = 0
  then do:
    /* по умолчанию обрабатываем весь складской архив */
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
  /* больше или равной v-aht-detail-date являются правильными и целостными */
  define variable v-aht-detail-date       as date    no-undo .
  define variable v-aht-detail-fact-order as decimal no-undo .

  if v-attr-type = {&type-date}
  then do:
    assign
      v-aht-detail-date = date(v-attr-value)
    .
  end.
  else do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный тип атрибута" {&attr-aht-detail-date} skip
      "Тип атрибута" v-attr-type skip
      view-as alert-box error .
    undo, return error . /* --->>>--- */
  end.

  run day-begin-fact-order in this-procedure
    (input  v-aht-detail-date /* p-last-fact-date  */
    ,output v-aht-detail-fact-order  /* p-last-fact-order */
    ).

  if p-last-fact-order = ?
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при задании входных параметров" skip
      "Не задана дата начиная с которой необходимо удалить складской архив" skip
      "Объект" p-obj-type p-obj-code skip
      "v-aht-detail-fact-order"  v-aht-detail-fact-order skip
      "p-last-fact-order" p-last-fact-order skip
      view-as alert-box error .
    undo, return error . /* --->>>--- */
  end.

  /* проверяем различные допустимые варианты для удаления складского архива */
  if  (v-aht-detail-fact-order  <= p-last-fact-order
        and p-last-fact-order <= p-cut-fact-order )
  or  (p-last-fact-order <= p-cut-fact-order
        and p-cut-fact-order <= v-aht-detail-fact-order
      )
  then do:
    /* это правильные варианты */
  end.
  else do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при сжатии складского архива" skip
      "Неправильный диапазон сжатия складского архива" skip
      "Объект" p-obj-type p-obj-code skip
      "v-aht-detail-fact-order" v-aht-detail-fact-order skip
      "p-last-fact-order"       p-last-fact-order skip
      "p-cut-fact-order"        p-last-fact-order skip
      view-as alert-box error .
    undo, return error . /* --->>>--- */
  end.

  run show-action in this-procedure
    (input "Удаление строк документов"
    ).
  assign
    v-ind = 0
  .

  /* удаляются все обороты по строкам документа */
  run delete-aht-ot-line in this-procedure .

  run show-action in this-procedure
    (input "Анализ итогов по товарам на объекте"
    ).
  assign
    v-ind = 0
  .

  /* очищаем информацию о датах в складском архиве */
  run clear-temp-fact-order in this-procedure
    no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове программы" 'clear-temp-fact-order':u skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.

  /* заполняем информацию */
  run fill-temp-fact-order in this-procedure
    no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры" 'fill-temp-fact-order':u skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  /* определяем информацию, подлежащую удалению */
  /* оставляем остатки на конец месяца */
  /* все промежуточные остатки удаляем */
  run select-temp-fact-order in this-procedure
    no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове программы" 'select-temp-fact-order':u skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.

  run show-action in this-procedure
    (input "Удаление итогов по товарам на объекте"
    ).
  assign
    v-ind = 0
  .

  run delete-aht-stk-line in this-procedure
    no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры" 'delete-aht-stk-line':u skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.
end.

procedure delete-aht-ot-line :

  define buffer buf_aht-ot-line for aht-ot-line .

  do
  on error undo, return error return-value
  :
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
          ,input "Код товара " + string(buf_aht-ot-line.gds-code)
          ).
      end.

      delete buf_aht-ot-line .
    end.
  end.

end procedure. /* delete-aht-ot-line */


procedure clear-temp-fact-order :

  do
  on error undo, return error
  :

    define buffer buf_temp-fact-order for temp-fact-order .

    for each buf_temp-fact-order
    on error undo, return error
    :
      delete buf_temp-fact-order .
    end.

  end.

end procedure. /* clear-temp-fact-order */


procedure accum-temp-fact-order :

  define input parameter p-gds-code   as integer   no-undo .
  define input parameter p-sum-type   as character no-undo .
  define input parameter p-fact-order as decimal   no-undo .

  do
  on error undo, return error
  :
    define buffer buf_temp-fact-order for temp-fact-order .

    find first buf_temp-fact-order
      where buf_temp-fact-order.temp-gds-code   = p-gds-code
        and buf_temp-fact-order.temp-sum-type   = p-sum-type
        and buf_temp-fact-order.temp-fact-order = p-fact-order
      no-error .
    if not available buf_temp-fact-order
    then do:
      create buf_temp-fact-order .
      assign
        buf_temp-fact-order.temp-gds-code   = p-gds-code
        buf_temp-fact-order.temp-sum-type   = p-sum-type
        buf_temp-fact-order.temp-fact-order = p-fact-order
      .

      define variable v-fact-date as date      no-undo .

      run factord-to-date in this-procedure
        (input  p-fact-order
        ,output v-fact-date
        ) .

      assign
        buf_temp-fact-order.temp-break-value = year(v-fact-date) * 10000
                                             + month(v-fact-date) * 100
        buf_temp-fact-order.temp-need-delete = true
      .
    end.
  end.


end procedure. /* accum-temp-fact-order */


procedure fill-temp-fact-order :

  define buffer buf_aht-stk-line for ub.aht-stk-line .

  do
  on error undo, return error return-value
  :
    /* первоначальный проход по всем корневым записям */
    for each buf_aht-stk-line no-lock
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
          ,input "Код товара " + string(buf_aht-stk-line.gds-code)
          ).
      end.

      run accum-temp-fact-order in this-procedure
        (input  buf_aht-stk-line.gds-code   /* p-gds-code   */
        ,input  buf_aht-stk-line.sum-type   /* p-sum-type   */
        ,input  buf_aht-stk-line.fact-order /* p-fact-order */
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове программы" 'accum-temp-fact-order':u skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
  end.

end procedure. /* fill-temp-fact-order */


procedure select-temp-fact-order :

  do
  on error undo, return error
  :
    define buffer buf_temp-fact-order for temp-fact-order .
    define buffer buf_temp-last-fact-order for temp-last-fact-order .

    for each buf_temp-last-fact-order
    on error undo, return error return-value
    :
      delete buf_temp-last-fact-order .
    end.

    for each buf_temp-fact-order
    on error undo, return error return-value
    :
      find first buf_temp-last-fact-order
        where buf_temp-last-fact-order.temp-gds-code    = buf_temp-fact-order.temp-gds-code
          and buf_temp-last-fact-order.temp-sum-type    = buf_temp-fact-order.temp-sum-type
          and buf_temp-last-fact-order.temp-break-value = buf_temp-fact-order.temp-break-value
        no-error .
      if not available buf_temp-last-fact-order
      then do:
        create buf_temp-last-fact-order .
        assign
          buf_temp-last-fact-order.temp-gds-code    = buf_temp-fact-order.temp-gds-code
          buf_temp-last-fact-order.temp-sum-type    = buf_temp-fact-order.temp-sum-type
          buf_temp-last-fact-order.temp-break-value = buf_temp-fact-order.temp-break-value

          buf_temp-last-fact-order.temp-fact-order  = buf_temp-fact-order.temp-fact-order
        .
      end.

      if buf_temp-last-fact-order.temp-fact-order < buf_temp-fact-order.temp-fact-order
      then do:
        assign
          buf_temp-last-fact-order.temp-fact-order = buf_temp-fact-order.temp-fact-order
        .
      end.
    end.

    for each buf_temp-last-fact-order
    on error undo, return error return-value
    :
      find first buf_temp-fact-order
        where buf_temp-fact-order.temp-gds-code   = buf_temp-last-fact-order.temp-gds-code
          and buf_temp-fact-order.temp-sum-type   = buf_temp-last-fact-order.temp-sum-type
          and buf_temp-fact-order.temp-fact-order = buf_temp-last-fact-order.temp-fact-order
        .
      assign
        buf_temp-fact-order.temp-need-delete = false
      .
    end.
  end.

end procedure. /* select-temp-fact-order */


procedure show-action :
  do
  on error undo, return error
  :
    define input parameter p-action as character no-undo .

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


procedure delete-aht-stk-line :

  define buffer buf_temp-fact-order for temp-fact-order .
  define buffer buf_aht-stk-line for aht-stk-line .

  do
  on error undo, return error return-value
  :
    for each buf_temp-fact-order
      where buf_temp-fact-order.temp-need-delete = true
    on error undo, return error
    :
      for each buf_aht-stk-line
        where buf_aht-stk-line.obj-type   = p-obj-type
          and buf_aht-stk-line.obj-code   = p-obj-code
          and buf_aht-stk-line.gds-code   = buf_temp-fact-order.temp-gds-code
          and buf_aht-stk-line.fact-order = buf_temp-fact-order.temp-fact-order
          and buf_aht-stk-line.sum-type   = buf_temp-fact-order.temp-sum-type
      on error undo, return error
      :
        assign
          v-ind = v-ind + 1
        .
        if v-ind modulo 10 = 0
        then do:
          run show-count in this-procedure
            (input v-ind
            ,input "Код товара " + string(buf_aht-stk-line.gds-code)
            ).
        end.

        delete buf_aht-stk-line .
      end.
    end.
  end.

end procedure. /* delete-aht-stk-line */