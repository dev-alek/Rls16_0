block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: pr-oldd.p $
$Archive: str/pr-oldd.p $

Пересчет переоценки

Автор: Чернова Светлана Александровна
Дата создания: 03/10/02
Author: Svetlana Chernova
Creation date: 03/10/02

*/

define input parameter p-doc-num like ub.price-doc.doc-num no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: pr-oldd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/pr-oldd.p $":U .
define variable vss-description as character no-undo init "Пересчет переоценки".
{ cmp/vssrevis.i "substitute('&1':u,p-doc-num)" }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ trg/factord.i  }
{ trg/partslib.i }
{ trg/prdoclib.i }
{ gbl/dtm.i      }
define variable p-corr-doc-code like ub.price-doc.doc-num no-undo .
define variable p-ship-num      like ub.c-price-doc.chip-num no-undo .
define variable num_rec         as integer   no-undo .
define variable start-time      as integer   no-undo .
define variable current-time    as character no-undo .
define variable current-action  as character no-undo .
define variable v-description-ord-type as character no-undo .
define variable v-today         as date      no-undo.
define variable v-time          as integer   no-undo.
define variable loc-qnty        like    ub.price-list.doc-qnty no-undo .
define variable varcut-status    as integer                   no-undo.
define variable varcut-date      as date                      no-undo.
define variable varcut-fin-date  as date                      no-undo.

define buffer prt-price-list for price-list .
/* для показа процесса переоценки */

define frame a
  ub.price-doc.doc-num                       label "Переоценка" skip
  ub.price-doc.status_                       label "Статус" skip
  current-action         format "x(40)"      no-label skip
  num_rec                format ">>>>>>>9"   label "Обработано артикулов" skip
  ub.price-list.artic                        label "Текущий артикул" skip
  current-time           format "x(8)"       label "Время" skip
  with view-as dialog-box side-labels three-d
  title "Пересчет переоценки"
  .

/* message "Пересчет переоценки" . */

main-block :
do transaction
on error undo main-block, return error
:

  find first ub.price-doc exclusive-lock
    where ub.price-doc.doc-num = p-doc-num
    no-error .
  if not available ub.price-doc then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найдена переоценка" skip
      "Переоценка" p-doc-num skip
      error-status :get-message(1)
      view-as alert-box error .
    undo, return error.
  end.

  if ub.price-doc.status_ <> {&act-overvalue}
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Переоценка не закрыта" skip
      "Данная процедура может перерассчитывать только закрытые переоценки" skip
      "Переоценка" p-doc-num skip
      error-status :get-message(1)
      view-as alert-box error .
    undo, return error.
  end.
{ gbl/cutd-obj.i ub.price-doc.obj-type ub.price-doc.obj-code varcut-status varcut-date varcut-fin-date no-error }
if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute ("Ошибка при определении состояния объекта по обрезанию данных &1 &2.", return-value , error-status :get-message(1) )
      view-as alert-box error .
    undo, return error.
end.
  case varcut-status:
  when 1 then do:
    /*1 - БД никогда не обрезалась ( при этом p-cut-date = ? ) */
  end.
  when 2 then do:
    /*2 - БД обрезалась "полностью"*/
  end.
  when 3 then do:
    /*3 - Обрезались документы по запрашиваемому объекту, но БД не была выгружена*/
    if varcut-date > ub.price-doc.fact-date then do:
       message
        vss-workfile vss-revision vss-description skip
        substitute ("В главной базе данных проводилось обрезание по объекту &1 &2. База данных этого объекта не была выгружена. Продолжать невозможно.", ub.price-doc.obj-type, ub.price-doc.obj-code)
        view-as alert-box error .
        undo, return error.
    end.
  end.
  when 4 then do:
    /*4 - БД была выгружена после обрезания документов по запрашиваемому объекту*/
  end.
  otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        substitute ("Неверный статус объекта &1 получен от программы cutd-obj.", varcut-status)
        view-as alert-box error
        .
        undo, return error.
  end.
  end case.



  view frame a.
    display
    ub.price-doc.doc-num
    ub.price-doc.status_
    with frame a.

  /*----------------------------------------*/
  assign
    current-action = "Проверка шапки."
  .
  run show-action (current-action) .

  /* копируем в архив */
  run str/c-pr-crt.p
    (input  ub.price-doc.doc-num
    ,output p-ship-num
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Невозможно записать в архив" skip
      "Переоценка" ub.price-doc.doc-num skip
      "Щепка" p-ship-num skip
      error-status :error skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.

  /*----------------------------------------*/
  assign
    current-action = "Проверка строк."
  .
  run show-action (current-action) .

  assign
    loc-qnty = 0
  .

  for each ub.price-list exclusive-lock
    where ub.price-list.doc-num = ub.price-doc.doc-num
      and ub.price-list.main-price = true
  on error undo main-block, return error
  :
    run process-line in this-procedure no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при обработке товара" skip
        "ПЕРЕОЦЕНКА" ub.price-doc.doc-num skip
        "Артикул" ub.price-list.artic ub.price-list.prod-type ub.price-list.prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo main-block, return error .
    end.
    assign
      loc-qnty = loc-qnty + determined(ub.price-list.doc-qnty)
    .
  end.

  /* Пересчет прайс-листа   */
  assign
    current-action = "Пересчет шапки."
  .
  run show-action (current-action).
  { gbl/curobjdt.i ub.price-doc.obj-type ub.price-doc.obj-code ub.price-doc.corr-date no-error }
  { gbl/curshift.i ub.price-doc.obj-type ub.price-doc.obj-code ub.price-doc.corr-shift-date ub.price-doc.corr-shift-num ub.price-doc.corr-shift-name no-error }

  assign
    ub.price-doc.corr-doc-code     = p-corr-doc-code
    ub.price-doc.corr-man          = g#userid
    ub.price-doc.rest-sale         = ub.price-doc.rest-sale * loc-qnty / ub.price-doc.rest-qnty
    ub.price-doc.rest-base         = ub.price-doc.rest-base * loc-qnty / ub.price-doc.rest-qnty
    ub.price-doc.sale-base         = ub.price-doc.sale-base * loc-qnty / ub.price-doc.rest-qnty
    ub.price-doc.rest-last         = ub.price-doc.rest-last * loc-qnty / ub.price-doc.rest-qnty
    ub.price-doc.rest-qnty         = loc-qnty
  .
  /*------------------------*/
end.



procedure show-action :
  do
  on error undo, return error
  :
    define input parameter p-action as character no-undo .

    define variable v-today as date      no-undo.
    define variable v-time  as integer   no-undo.

    run cur-time in this-procedure ( output v-today
                                   , output v-time
                                   ).
    assign
      current-time = string(v-time - start-time, "HH:MM:SS")
      current-action = p-action
    .
    display
      current-time current-action
      with frame a.

  end.
end procedure. /* show-action */


procedure process-line :

  do
  on error undo, return error substitute("  &1 &2" , error-status :get-message(1) , return-value )
  on stop undo, return error substitute(" STOP &1 &2" , error-status :get-message(1) , return-value )
  on end-key undo, return error substitute("END-KEY  &1 &2" , error-status :get-message(1) , return-value )

  :
    define variable v-today as date      no-undo.
    define variable v-time  as integer   no-undo.

    define variable    p-obj-type           like ub.gds-obj.obj-type  no-undo .
    define variable    p-obj-code           like ub.gds-obj.obj-code  no-undo .
    define variable    p-artic              like ub.gds-obj.artic     no-undo .
    define variable    p-prod-type          like ub.gds-obj.prod-type no-undo .
    define variable    p-prod-code          like ub.gds-obj.prod-code no-undo .
    define variable    p-fact-order         as decimal   no-undo .
    define variable    p-include-fact-order as logical   no-undo .

    define buffer buf_parts for ub.parts  .
    define variable v-total-qnty as decimal no-undo .

    assign
      v-total-qnty = 0
    .
    for each buf_parts exclusive-lock
      where buf_parts.out-code  = ub.price-list.doc-num
        and buf_parts.artic     = ub.price-list.artic
        and buf_parts.prod-type = ub.price-list.prod-type
        and buf_parts.prod-code = ub.price-list.prod-code
        and buf_parts.obj-type  = ub.price-list.obj-type
        and buf_parts.obj-code  = ub.price-list.obj-code
    on error undo, return error
    :
      delete buf_parts .
    end.

    /* вытащим свободную зону */
    assign
      p-obj-type           = ub.price-doc.obj-type
      p-obj-code           = ub.price-doc.obj-code
      p-artic              = ub.price-list.artic
      p-prod-type          = ub.price-list.prod-type
      p-prod-code          = ub.price-list.prod-code
      p-fact-order         = ub.price-doc.fact-order
      p-include-fact-order = false
    .
    run partslib-clear-temp-parts in this-procedure .     /* зачистка временной таблицы */
    run prdoclib-clear-temp-prt-obj in this-procedure .   /* зачистка временной таблицы */

    run partslib-init-temp-parts-by-factord in this-procedure
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-artic
      ,input  p-prod-type
      ,input  p-prod-code
      ,input  p-fact-order
      ,input  p-include-fact-order
      ) .

    run prdoclib-init-prt-obj-by-factord in this-procedure
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-artic
      ,input  p-prod-type
      ,input  p-prod-code
      ,input  p-fact-order
      ,input  p-include-fact-order
      ) .

    /* создание архивных партий */

    for each temp-parts
    on error undo, return error return-value
    :
      create buf_parts .
      buffer-copy temp-parts to buf_parts
      assign
        buf_parts.out-code  = ub.price-list.doc-num
        buf_parts.status_   = true
        buf_parts.rsrv-free = ?
        buf_parts.doc-type  = {&act-overvalue}
        buf_parts.PS        = 'архив переоценки ' + ub.price-list.doc-num
      .

      assign
        v-total-qnty = v-total-qnty + determined(buf_parts.fact-qnty)
      .
    end.
    /* учесть количество по спец ценам  и вычесть это количество  из  v-total-qnty */

      for each  prt-price-list exclusive-lock
          where prt-price-list.doc-num   = ub.price-doc.doc-num
            and prt-price-list.artic     = ub.price-list.artic
            and prt-price-list.prod-code = ub.price-list.prod-code
            and prt-price-list.prod-type = ub.price-list.prod-type
            and prt-price-list.main-price = false
            on error undo, return error
            :
            find first ub.bar-code  no-lock where ub.bar-code.b-code  = prt-price-list.b-code no-error .
            if not available ub.bar-code  then next.
            find first ub.goods     no-lock where ub.goods.gds-code  = ub.bar-code.gds-code no-error .
            if not available ub.goods then next.

            /* проверяем, что это основной едизм - иначе пропускаем */

            if ub.bar-code.unit-cli <> ub.goods.unit-base then do:
               if prt-price-list.doc-qnty <> 0 then prt-price-list.doc-qnty = ? .
               next.
             end.

            if ub.bar-code.in-code = ""  then do:
                find first temp-prt-obj no-lock where
                          temp-prt-obj.prt-code = ub.bar-code.node-code
                          no-error  .

                /*если ошибка, то это неосновные цены */
                  if available temp-prt-obj then do:
                      assign
                        prt-price-list.doc-qnty = determined(temp-prt-obj.fact-qnty)
                        v-total-qnty            = v-total-qnty - determined(temp-prt-obj.fact-qnty)
                      .
                  end.
            end.
            else do:
               prt-price-list.doc-qnty = 0.
               for each temp-parts where
                        temp-parts.in-code   = ub.bar-code.in-code and
                        temp-parts.part-code = ub.bar-code.part-code and
                        temp-parts.artic     = ub.goods.artic and
                        temp-parts.prod-type = ub.goods.prod-type and
                        temp-parts.prod-code = ub.goods.prod-code
               :
                      assign
                        prt-price-list.doc-qnty = determined(temp-parts.fact-qnty)
                        v-total-qnty            = v-total-qnty - determined(temp-parts.fact-qnty)
                      .

               end.
            end.
      end.

    /* Пересчет прайс-листа по новым арх партиям  */
      .
    do transaction :
    assign
      ub.price-list.doc-qnty = v-total-qnty
    .
    end.

    run partslib-clear-temp-parts in this-procedure .     /* зачистка временной таблицы */
    run prdoclib-clear-temp-prt-obj in this-procedure .   /* зачистка временной таблицы */
    assign
      num_rec   = num_rec + 1
    .

    if num_rec mod 10 = 0
    then do:
      run cur-time in this-procedure ( output v-today
                                    , output v-time ).
      assign
        current-time = string(v-time - start-time, "HH:MM:SS")
      .
      display
        num_rec ub.price-list.artic  current-time current-action
        with frame a.

    end.
  end.

end procedure . /* process-line */
/* $Workfile: pr-oldd.p $ e n d */