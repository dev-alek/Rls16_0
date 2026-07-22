block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Очистка и экспорт складского архива по товарам

Автор: Белоусов Илья Александрович
Дата создания: 07/16/07
Author: Ilia Belousov
Creation date: 07/16/07

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
define variable vss-description as character no-undo init "Очистка и экспорт складского архива по товарам".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5':u,p-obj-type,p-obj-code,p-last-fact-order,p-cut-fact-order,v-export-file-name)" }
{ cmp/trg-def.i  }
{ trg/factord.i  }
{ gbl/clntattr.i }

define variable v-export-archive as logical   no-undo .
define variable v-action         as character no-undo .
define stream slog .

define temp-table temp-goods no-undo
  field gds-code  as integer
  field artic     as character
  field prod-type as character
  field prod-code as integer
  index xpk is primary unique gds-code
  index xie artic prod-type prod-code
  .

define temp-table temp-ot-tot no-undo like ub.ot-tot
  .
define temp-table temp-ot-line no-undo like ub.ot-line
  field gds-code as integer
  .
define temp-table temp-stk-tot no-undo like ub.stk-tot
  .
define temp-table temp-stk-line no-undo like ub.stk-line
  field gds-code as integer
  .


define buffer buf_ot-tot        for ub.ot-tot     .
define buffer buf_ot-line       for ub.ot-line    .
define buffer buf_stk-tot       for ub.stk-tot    .
define buffer buf_stk-line      for ub.stk-line   .
define buffer buf_temp-ot-tot   for temp-ot-tot   .
define buffer buf_temp-ot-line  for temp-ot-line  .
define buffer buf_temp-stk-tot  for temp-stk-tot  .
define buffer buf_temp-stk-line for temp-stk-line .

main-block:
do
on error undo main-block, return error
:

  if  v-export-file-name <> ""
  and v-export-file-name <> ?
  then do:
    assign
      v-export-archive = true
      v-action         = "Экспорт складского архива по товарам"
    .
  end.
  else do:
    assign
      v-export-archive = false
      v-action         = "Очистка складского архива по товарам"
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
    ,input  {&attr-arh-detail-date} /* p-code     */
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
      "Неправильный тип атрибута" {&attr-arh-detail-date} skip
      "Тип атрибута" v-attr-type skip
      view-as alert-box error .
    undo, return error . /* --->>>--- */
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
      "Не задана дата начиная с которой необходимо удалить складской архив по товарам" skip
      "Объект" p-obj-type p-obj-code skip
      "v-cut-fact-order"  v-cut-fact-order skip
      "p-last-fact-order" p-last-fact-order skip
      view-as alert-box error .
    undo, return error . /* --->>>--- */
  end.

  /* проверяем различные допустимые варианты для удаления складского архива по товарам */
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
        "Ошибка при удалении складского архива по товарам" skip
        "Неправильный диапазон удаления складского архива по товарам" skip
        "Объект" p-obj-type p-obj-code skip
        "v-cut-fact-order"  v-cut-fact-order skip
        "p-last-fact-order" p-last-fact-order skip
        "p-cut-fact-order" p-cut-fact-order skip
        view-as alert-box error .
      undo, return error . /* --->>>--- */
    end.
  end.


  define variable v-ind as integer no-undo .

  run show-action in this-procedure
    (input "Итоги по документам"
    ).

  for each buf_ot-tot
    where buf_ot-tot.obj-type   = p-obj-type
      and buf_ot-tot.obj-code   = p-obj-code
      and buf_ot-tot.fact-order > p-last-fact-order
      and buf_ot-tot.fact-order <= p-cut-fact-order
  on error undo main-block, return error
  :
    assign
      v-ind = v-ind + 1
    .
    if v-ind modulo 10 = 0
    then do:
      run show-count in this-procedure
        (input v-ind
        ,input "Документ " + string(buf_ot-tot.doc-code)
        ).
    end.

    if v-export-archive = true
    then do:
      create buf_temp-ot-tot .
      buffer-copy buf_ot-tot to buf_temp-ot-tot .

      export stream slog {&table_ot-tot} .
      export stream slog buf_temp-ot-tot .

      delete buf_temp-ot-tot .
    end.
    else do:
      delete buf_ot-tot .
    end.
  end.

  run show-action in this-procedure
    (input "Итоги по строкам документов"
    ).

  for each buf_ot-line
    where buf_ot-line.obj-type   = p-obj-type
      and buf_ot-line.obj-code   = p-obj-code
      and buf_ot-line.fact-order > p-last-fact-order
      and buf_ot-line.fact-order <= p-cut-fact-order
  on error undo main-block, return error
  :
    assign
      v-ind = v-ind + 1
    .
    if v-ind modulo 10 = 0
    then do:
      run show-count in this-procedure
        (input v-ind
        ,input "Документ " + string(buf_ot-line.doc-code)
                + " Артикул " + string(buf_ot-line.artic)
        ).
    end.

    if v-export-archive = true
    then do:
      create buf_temp-ot-line  .

      buffer-copy buf_ot-line to buf_temp-ot-line .

      run fill-gds-code in this-procedure
        (input  buf_temp-ot-line.artic
        ,input  buf_temp-ot-line.prod-type
        ,input  buf_temp-ot-line.prod-code
        ,output buf_temp-ot-line.gds-code
        ) .

      export stream slog {&table_ot-line} .
      export stream slog buf_temp-ot-line except artic prod-type prod-code .

      delete buf_temp-ot-line  .
    end.
    else do:
      delete buf_ot-line .
    end.
  end.

  run show-action in this-procedure
    (input "Итоги по объекту"
    ).

  for each buf_stk-tot
    where buf_stk-tot.obj-type   = p-obj-type
      and buf_stk-tot.obj-code   = p-obj-code
      and buf_stk-tot.fact-order > p-last-fact-order
      and buf_stk-tot.fact-order <= p-cut-fact-order
  on error undo main-block, return error
  :
    assign
      v-ind = v-ind + 1
    .
    if v-ind modulo 10 = 0
    then do:
      run show-count in this-procedure
        (input v-ind
        ,input "Дата " + string(buf_stk-tot.fact-date, '99/99/9999':U )
        ).
    end.

    if v-export-archive = true
    then do:
      create buf_temp-stk-tot .
      buffer-copy buf_stk-tot to buf_temp-stk-tot .

      export stream slog {&table_stk-tot} .
      export stream slog buf_temp-stk-tot .
      delete buf_temp-stk-tot .
    end.
    else do:
      delete buf_stk-tot .
    end.
  end.

  run show-action in this-procedure
    (input "Итоги по товарам на объекте"
    ).

  for each buf_stk-line
    where buf_stk-line.obj-type   = p-obj-type
      and buf_stk-line.obj-code   = p-obj-code
      and buf_stk-line.fact-order > p-last-fact-order
      and buf_stk-line.fact-order <= p-cut-fact-order
  on error undo main-block, return error
  :
    assign
      v-ind = v-ind + 1
    .
    if v-ind modulo 10 = 0
    then do:
      run show-count in this-procedure
        (input v-ind
        ,input "Артикул " + string(buf_stk-line.artic)
        ).
    end.

    if v-export-archive = true
    then do:
      create buf_temp-stk-line .
      buffer-copy buf_stk-line to buf_temp-stk-line .

      run fill-gds-code in this-procedure
        (input  buf_temp-stk-line.artic
        ,input  buf_temp-stk-line.prod-type
        ,input  buf_temp-stk-line.prod-code
        ,output buf_temp-stk-line.gds-code
        ) .

      export stream slog {&table_stk-line} .
      export stream slog buf_temp-stk-line except artic prod-type prod-code .
      delete buf_temp-stk-line .
    end.
    else do:
      delete buf_stk-line .
    end.
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


procedure fill-gds-code :

  define input  parameter p-artic     as character no-undo .
  define input  parameter p-prod-type as character no-undo .
  define input  parameter p-prod-code as integer   no-undo .
  define output parameter p-gds-code  as integer   no-undo .

  define buffer buf_temp-goods for temp-goods .
  define buffer buf_goods for ub.goods .

  do
  on error undo, return error return-value
  :
    find first buf_temp-goods
      where buf_temp-goods.artic     = p-artic
        and buf_temp-goods.prod-type = p-prod-type
        and buf_temp-goods.prod-code = p-prod-code
      no-error .
    if not available buf_temp-goods
    then do:
      find first buf_goods no-lock
        where buf_goods.artic     = p-artic
          and buf_goods.prod-type = p-prod-type
          and buf_goods.prod-code = p-prod-code
        no-error .
      if not available buf_goods
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не найден товар" skip
          "Товар" p-artic p-prod-type p-prod-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      create buf_temp-goods .
      assign
        buf_temp-goods.artic     = p-artic
        buf_temp-goods.prod-type = p-prod-type
        buf_temp-goods.prod-code = p-prod-code
        buf_temp-goods.gds-code  = buf_goods.gds-code
      .
    end.

    assign
      p-gds-code = buf_temp-goods.gds-code
    .
  end.

end procedure. /* fill-gds-code */