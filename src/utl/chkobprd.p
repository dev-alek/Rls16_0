block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: chkobprd.p $
$Archive: utl/chkobprd.p $

Программа проверки документов переоценки на объекте начиная с определенной даты

Автор: Чернова Светлана Александровна
Дата создания: 03/03/10
Author: Svetlana Chernova
Creation date: 03/03/10

Автор1: Перваков Михаил Сергеевич
Дата создания1: 06/19/06

Общая идея:
  Проанализировать текущие остатки и складские документы
  и сравнить вычисленные остатки (признаки, партии) с информацией, записанной в переоценке

  В случае обнаружения отличий ошибки будут зафиксированы

  По окончании результаты проверки записываются в файл,
  а также сохраняется информация в истории операций по архивам

Для услуг и товаров требуется специальная обработка

У услуг отсутствуют партии

У золота коди партий могут изменяться без документов при разбиении партий на штуки

*/

define input  parameter p-obj-type                 as character no-undo .
define input  parameter p-obj-code                 as integer   no-undo .
define input  parameter p-start-date               as date      no-undo .
define output parameter p-error-number             as integer   no-undo .
define output parameter p-state-description        as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chkobprd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/chkobprd.p $":U .
define variable vss-description as character no-undo init "Программа проверки документов переоценки на объекте начиная с определенной даты".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ trg/partslib.i }
{ trg/prdoclib.i }
{ trg/factord.i  }
{ gbl/waitfram.i }

define temp-table goods-operation-list no-undo
  field doc-code   as character format 'x(14)':u
  field table-name as character format 'x(16)':u
  field fact-order as decimal   format '999999999999999.9999999999':U

  index xpk is primary unique doc-code
  index ie1 fact-order
  index ie2 table-name
  .

/* для партий будем сравнивать все поля кроме следующих */
/*   out-code  */
/*   rsrv-free */
/*   status_   */
/* эти поля будут проверяться по предопределенному значению */

/* значения полей во временной таблице */
/*   buf_temp-parts.out-code  = {&free-code} */
/*   buf_temp-parts.status_   = no           */
/*   buf_temp-parts.rsrv-free = yes          */

/* значения полей в переоценке */
/*   buf_parts.out-code  = price-doc.doc-num */
/*   buf_parts.status_   = yes               */
/*   buf_parts.rsrv-free = ?                 */

define temp-table temp-price-list-parts no-undo
  like ub.parts
  field temp-price-list-parts-process as logical

  index xpk is primary unique out-code in-code part-code
  index xie1 temp-price-list-parts-process
  .

define temp-table temp-price-list-gds-dtl no-undo
  field b-code                          as integer
  field prt-code                        as integer
  field price-sale                      as decimal
  field fact-qnty                       as decimal
  field gds-dtl-qnty                    as decimal

  index xpk is primary unique prt-code
  index xie1 b-code
  .

define temp-table temp-trn-doc-list no-undo
  field doc-code   as character
  field fact-order as decimal
  field fact-date  as date

  index xpk is primary unique doc-code
  .

define temp-table temp-price-doc-list no-undo
  field doc-code   as character
  field fact-order as decimal
  field fact-date  as date

  index xpk is primary unique doc-code
  .

define variable v-start-fact-order         as decimal   no-undo .
define variable v-b-code                   as integer   no-undo .
define variable v-ind                      as integer   no-undo .
define variable v-create-chip-num          as integer   no-undo .
define variable v-detail-err-file-name     as character no-undo .
define variable v-price-doc-list-file-name as character no-undo .
define variable v-trn-doc-list-file-name   as character no-undo .
define variable v-unit-base                as character no-undo .

define stream sout .

do
on error undo, return error return-value
:
  assign
    v-detail-err-file-name     = substitute('chkobprd_&1_&2.err'
                                           ,p-obj-type
                                           ,p-obj-code
                                           )
    v-price-doc-list-file-name = substitute('chkobprd_&1_&2_price_doc.err'
                                           ,p-obj-type
                                           ,p-obj-code
                                           )
    v-trn-doc-list-file-name   = substitute('chkobprd_&1_&2_trn-doc.err'
                                           ,p-obj-type
                                           ,p-obj-code
                                           )
  .

  os-delete value(v-detail-err-file-name) .

  os-delete value(v-price-doc-list-file-name) .

  os-delete value(v-trn-doc-list-file-name) .

  /* сохраняем информацию о начале проверке переоценок */
  run utl/arhichk.p
    (input  p-obj-type                     /* p-obj-type        */
    ,input  p-obj-code                     /* p-obj-code        */
    ,input  {&btpr-type-prc}               /* p-archive-type    */
    ,input  {&archive-history-check-start} /* p-action-type     */
    ,input  p-start-date                   /* p-start-check-date*/
    ,input  0                              /* p-error-number    */
    ,input  '':U                           /* p-status-message  */
    ,output v-create-chip-num              /* p-create-chip-num */
    ) .

  assign
    p-error-number      = 0
    p-state-description = '':U
  .

  /* проанализировать товары */
  run process-gds-obj in this-procedure .

  /* сохранить информацию о плохих переоценках */
  run temp-price-doc-list-export in this-procedure
    (input  p-obj-type
    ,input  p-obj-code
    ) .

  /* сохранить информацию о плохих документах */
  run temp-trn-doc-list-export in this-procedure
    (input  p-obj-type
    ,input  p-obj-code
    ) .

  /* сохраняем информацию о завершении проверки переоценок */
  /* сохраняется информация о найденных ошибках */
  run utl/arhichk.p
    (input  p-obj-type                    /* p-obj-type         */
    ,input  p-obj-code                    /* p-obj-code         */
    ,input  {&btpr-type-prc}              /* p-archive-type     */
    ,input  {&archive-history-check-stop} /* p-action-type      */
    ,input  p-start-date                  /* p-start-check-date */
    ,input  p-error-number                /* p-error-number     */
    ,input  p-state-description           /* p-status-message   */
    ,output v-create-chip-num             /* p-create-chip-num  */
    ) .

  /* todo - сохранять информацию о "здоровье" объекта */

end.


procedure process-gds-obj :

  define buffer buf_gds-obj      for ub.gds-obj .
  define buffer buf_lock_gds-obj for ub.gds-obj .
  define buffer buf_price-doc    for ub.price-doc .

  define variable v-goods-gds-goods as logical   no-undo .
  define variable v-goods-twounit   as logical   no-undo .
  define variable v-doc-num         as character no-undo .
  define variable v-price-sale      as decimal   no-undo .
  define variable v-road-tax        as decimal   no-undo .
  define variable v-excise          as decimal   no-undo .
  define variable v-crsa-vat-pc     as decimal   no-undo .
  define variable v-crsa-slt-pc     as decimal   no-undo .

  do
  on error undo, return error return-value
  :
    gds-obj_cycle:
    for each buf_gds-obj no-lock
      where buf_gds-obj.obj-type = p-obj-type
        and buf_gds-obj.obj-code = p-obj-code
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Проверка переоценок. Объект &1 &2. Проверено &3. Ошибок &4"
                           ,p-obj-type
                           ,p-obj-code
                           ,v-ind
                           ,p-error-number
                           )
          ) .
      end.

      /* блокируем товар на объекте на время проверки */
      do transaction
      on error undo, return error return-value
      :
        find first buf_lock_gds-obj exclusive-lock
          where rowid(buf_lock_gds-obj) = rowid(buf_gds-obj)
          .
      end.

      { gbl/gdsat.i
        buf_gds-obj.artic
        buf_gds-obj.prod-type
        buf_gds-obj.prod-code
        "'gds-goods=request':u"
        v-goods-gds-goods
        no-error
      }
      if error-status :error
      then do:
        assign
          p-error-number = p-error-number + 1
        .
        output stream sout to value(v-detail-err-file-name) append .
        export stream sout '### error {&line-number}':U string(today, '99/99/9999':U) string(time, 'HH:MM:SS':U).
        export stream sout 'ошибка при определении атрибута товара (gdsat.i gds-goods=request)':U .
        export stream sout 'artic':U buf_gds-obj.artic .
        export stream sout 'prod-type':U buf_gds-obj.prod-type .
        export stream sout 'prod-code':U buf_gds-obj.prod-code .
        export stream sout 'error-message':U error-status :get-message(1)  .
        export stream sout 'return-value':U return-value .
        output stream sout close .

        next gds-obj_cycle . /* --->>>--- */
      end.


      { gbl/gdsat.i
        buf_gds-obj.artic
        buf_gds-obj.prod-type
        buf_gds-obj.prod-code
        "'twounit=request':u"
        v-goods-twounit
        no-error
      }
      if error-status :error
      then do:
        assign
          p-error-number = p-error-number + 1
        .
        output stream sout to value(v-detail-err-file-name) append .
        export stream sout '### error {&line-number}':U string(today, '99/99/9999':U) string(time, 'HH:MM:SS':U).
        export stream sout 'ошибка при определении атрибута товара (gdsat.i twounit=request)':U .
        export stream sout 'artic':U buf_gds-obj.artic .
        export stream sout 'prod-type':U buf_gds-obj.prod-type .
        export stream sout 'prod-code':U buf_gds-obj.prod-code .
        export stream sout 'error-message':U error-status :get-message(1)  .
        export stream sout 'return-value':U return-value .
        output stream sout close .

        next gds-obj_cycle . /* --->>>--- */
      end.

      { gbl/unitbase.i
        buf_gds-obj.gds-code
        v-unit-base
        no-error
      }
      if error-status :error
      then do:
        assign
          p-error-number = p-error-number + 1
        .
        output stream sout to value(v-detail-err-file-name) append .
        export stream sout '### error {&line-number}':U string(today, '99/99/9999':U) string(time, 'HH:MM:SS':U).
        export stream sout 'ошибка при поиске базовой единицы измерения (unitbase.i)':U .
        export stream sout 'gds-code':U buf_gds-obj.gds-code .
        export stream sout 'error-message':U error-status :get-message(1)  .
        export stream sout 'return-value':U return-value .
        output stream sout close .

        next gds-obj_cycle . /* --->>>--- */
      end.

      { gbl/gdsbcode.i
        buf_gds-obj.gds-code
        ?
        v-b-code
        no-error
      }
      if error-status :error
      then do:
        assign
          p-error-number = p-error-number + 1
        .
        output stream sout to value(v-detail-err-file-name) append .
        export stream sout '### error {&line-number}':U string(today, '99/99/9999':U) string(time, 'HH:MM:SS':U).
        export stream sout 'ошибка при поиске основного штрих-кода для товара (gdsbcode.i)':U .
        export stream sout 'gds-code':U buf_gds-obj.gds-code .
        export stream sout 'error-message':U error-status :get-message(1)  .
        export stream sout 'return-value':U return-value .
        output stream sout close .

        next gds-obj_cycle . /* --->>>--- */
      end.

      if p-start-date = ?
      then do:
        assign
          v-start-fact-order = 0
        .
      end.
      else do:
        /* необходимо уточнить начальный fact-order */
        /* это последняя переоценка непосредственно перед датой проверки */
        run factord-end-day in this-procedure
          (input  p-start-date - 1
          ,output v-start-fact-order
          ) .

        { gbl/bcprcex.i
          p-obj-type
          p-obj-code
          v-b-code
          0
          v-start-fact-order
          v-doc-num
          v-price-sale
          v-road-tax
          v-excise
          v-crsa-vat-pc
          v-crsa-slt-pc
          no-error
        }
        if error-status :error
        then do:
          assign
            p-error-number = p-error-number + 1
          .
          output stream sout to value(v-detail-err-file-name) append .
          export stream sout '### error {&line-number}':U string(today, '99/99/9999':U) string(time, 'HH:MM:SS':U).
          export stream sout 'ошибка при поиске цены на определенное время (bcprcex.i)':U .
          export stream sout 'obj-type':U p-obj-type .
          export stream sout 'obj-code':U p-obj-code .
          export stream sout 'b-code':U v-b-code .
          export stream sout 'fact-order':U v-start-fact-order.
          export stream sout 'error-message':U error-status :get-message(1)  .
          export stream sout 'return-value':U return-value .
          output stream sout close .

          next gds-obj_cycle . /* --->>>--- */
        end.

        if v-doc-num <> ?
        then do:
          find first buf_price-doc no-lock
            where buf_price-doc.doc-num = v-doc-num
            no-error .
          if error-status :error
          then do:
            assign
              p-error-number = p-error-number + 1
            .
            output stream sout to value(v-detail-err-file-name) append .
            export stream sout '### error {&line-number}':U string(today, '99/99/9999':U) string(time, 'HH:MM:SS':U).
            export stream sout 'ошибка при поиске переоценки':U .
            export stream sout 'doc-num':U v-doc-num .
            output stream sout close .
            run factord-end-day in this-procedure
              (input  buf_price-doc.fact-date - 1
              ,output v-start-fact-order
              ) .

            next gds-obj_cycle . /* --->>>--- */

          end.
          else do:
            /* изначальная переоценка отсутствует */
            /* цена товара равна нулю             */
          end.
        end.
      end.

      run goods-operation-list-clear in this-procedure .

      run goods-operation-list-init in this-procedure
        (input  buf_gds-obj.obj-type  /* p-obj-type         */
        ,input  buf_gds-obj.obj-code  /* p-obj-code         */
        ,input  buf_gds-obj.artic     /* p-artic            */
        ,input  buf_gds-obj.prod-type /* p-prod-type        */
        ,input  buf_gds-obj.prod-code /* p-prod-code        */
        ,input  v-b-code              /* p-b-code           */
        ,input  v-start-fact-order    /* p-start-fact-order */
        ) .

      run partslib-init-temp-parts in this-procedure
        (input  buf_gds-obj.obj-type  /* p-obj-type  */
        ,input  buf_gds-obj.obj-code  /* p-obj-code  */
        ,input  buf_gds-obj.artic     /* p-artic     */
        ,input  buf_gds-obj.prod-type /* p-prod-type */
        ,input  buf_gds-obj.prod-code /* p-prod-code */
        ) .

      run prdoclib-init-temp-prt-obj in this-procedure
        (input  buf_gds-obj.obj-type  /* p-obj-type        */
        ,input  buf_gds-obj.obj-code  /* p-obj-code        */
        ,input  buf_gds-obj.artic     /* p-artic           */
        ,input  buf_gds-obj.prod-type /* p-prod-type       */
        ,input  buf_gds-obj.prod-code /* p-prod-code       */
        ,input  0                     /* p-root-price-sale */
        ) .

      run temp-prt-obj-leave-term in this-procedure
        .


      /* идем от конца к началу */
      /* для складского документа - обновляем таблицы  */
      /* для переоценки           - сравниваем таблицы */

      /* debug раскомментируте следующий оператор для отладки списка операций */
/*      run goods-operation-list-show in this-procedure .*/

      /* обработка всех операций документа */
      run goods-operation-list-process in this-procedure
        (input  buf_gds-obj.obj-type  /* p-obj-type        */
        ,input  buf_gds-obj.obj-code  /* p-obj-code        */
        ,input  buf_gds-obj.artic     /* p-artic           */
        ,input  buf_gds-obj.prod-type /* p-prod-type       */
        ,input  buf_gds-obj.prod-code /* p-prod-code       */
        ,input  v-b-code              /* p-b-code          */
        ,input  v-goods-gds-goods     /* p-goods-gds-goods */
        ,input  v-goods-twounit       /* p-goods-twounit   */
        ) .
    end.
  end.

end procedure. /* process-gds-obj */


procedure scan-doc-line :

  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define input  parameter p-artic            as character no-undo .
  define input  parameter p-prod-type        as character no-undo .
  define input  parameter p-prod-code        as integer   no-undo .
  define input  parameter p-start-fact-order as decimal   no-undo .

  define buffer buf_doc-line for ub.doc-line .

  do
  on error undo, return error return-value
  :
    for each buf_doc-line no-lock
      where buf_doc-line.obj-type   = p-obj-type
        and buf_doc-line.obj-code   = p-obj-code
        and buf_doc-line.artic      = p-artic
        and buf_doc-line.prod-type  = p-prod-type
        and buf_doc-line.prod-code  = p-prod-code
        and buf_doc-line.status_    = {&fact}
        and buf_doc-line.fact-order > p-start-fact-order
    on error undo, return error return-value
    :
      run goods-operation-list-append in this-procedure
        (input  buf_doc-line.doc-code     /* p-doc-code   */
        ,input  {&table_trn-doc}          /* p-table-name */
        ,input  buf_doc-line.fact-order   /* p-fact-order */
        ) .
    end.
  end.

end procedure. /* scan-doc-line */

procedure scan-price-list :

  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define input  parameter p-b-code           as integer   no-undo .
  define input  parameter p-start-fact-order as decimal   no-undo .

  define buffer buf_price-list for ub.price-list .

  do
  on error undo, return error return-value
  :
    for each buf_price-list no-lock
      where buf_price-list.obj-type   = p-obj-type
        and buf_price-list.obj-code   = p-obj-code
        and buf_price-list.b-code     = p-b-code
        and buf_price-list.price-type = '':U
        and buf_price-list.fact-order > p-start-fact-order
    on error undo, return error return-value
    :
      run goods-operation-list-append in this-procedure
        (input  buf_price-list.doc-num    /* p-doc-code   */
        ,input  {&table_price-doc}        /* p-table-name */
        ,input  buf_price-list.fact-order /* p-fact-order */
        ) .
    end.
  end.

end procedure. /* scan-price-list */

procedure goods-operation-list-clear :

  define buffer buf_goods-operation-list for goods-operation-list .

  do
  on error undo, return error return-value
  :
    for each buf_goods-operation-list
    on error undo, return error return-value
    :
      delete buf_goods-operation-list .
    end.
  end.

end procedure. /* goods-operation-list-clear */

procedure goods-operation-list-append :

  define input  parameter p-doc-code   as character no-undo .
  define input  parameter p-table-name as character no-undo .
  define input  parameter p-fact-order as decimal   no-undo .

  define buffer buf_goods-operation-list for goods-operation-list .

  do
  for buf_goods-operation-list
  on error undo, return error return-value
  :
    find first buf_goods-operation-list
      where buf_goods-operation-list.doc-code = p-doc-code
      no-error .
    if available buf_goods-operation-list
    then do:
      undo, return error '':U .
    end.

    if p-table-name = ?
    or lookup(p-table-name, {&table_trn-doc} + {&comma-char} + {&table_price-doc}) = 0
    then do:
      undo, return error substitute("Неизвестный тип таблицы &1", p-table-name) .
    end.

    create buf_goods-operation-list .
    assign
      buf_goods-operation-list.doc-code   = p-doc-code
      buf_goods-operation-list.table-name = p-table-name
      buf_goods-operation-list.fact-order = p-fact-order
    .
  end.

end procedure. /* goods-operation-list-append */

procedure goods-operation-list-init :

  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define input  parameter p-artic            as character no-undo .
  define input  parameter p-prod-type        as character no-undo .
  define input  parameter p-prod-code        as integer   no-undo .
  define input  parameter p-b-code           as integer   no-undo .
  define input  parameter p-start-fact-order as decimal   no-undo .

  do
  on error undo, return error return-value
  :
    run scan-doc-line in this-procedure
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-artic
      ,input  p-prod-type
      ,input  p-prod-code
      ,input  p-start-fact-order
      ) .

    run scan-price-list in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-b-code
      ,input p-start-fact-order
      ) .
  end.

end procedure. /* goods-operation-list-init */

procedure goods-operation-list-show :

  define buffer buf_goods-operation-list for goods-operation-list .

  do
  on error undo, return error return-value
  :
    for each buf_goods-operation-list
      by buf_goods-operation-list.fact-order
    on error undo, return error return-value
    :
      display buf_goods-operation-list .
    end.
  end.

end procedure. /* goods-operation-list-show */

procedure goods-operation-list-process :

  define input  parameter p-obj-type        as character no-undo .
  define input  parameter p-obj-code        as integer   no-undo .
  define input  parameter p-artic           as character no-undo .
  define input  parameter p-prod-type       as character no-undo .
  define input  parameter p-prod-code       as integer   no-undo .
  define input  parameter p-b-code          as integer   no-undo .
  define input  parameter p-goods-gds-goods as logical   no-undo .
  define input  parameter p-goods-twounit   as logical   no-undo .

  define buffer buf_goods-operation-list for goods-operation-list .

  define variable v-total-parts-qnty   as decimal   no-undo .
  define variable v-total-gds-dtl-qnty as decimal   no-undo .

  do
  on error undo, return error return-value
  :
    for each buf_goods-operation-list
    by buf_goods-operation-list.fact-order descending
    :
      case buf_goods-operation-list.table-name
      :
        when {&table_trn-doc}
        then do:
          /* обработать документ */
          run partslib-process-document in this-procedure
            (input  buf_goods-operation-list.doc-code /* p-doc-code         */
            ,input  p-obj-type                        /* p-obj-type         */
            ,input  p-obj-code                        /* p-obj-code         */
            ,input  p-artic                           /* p-artic            */
            ,input  p-prod-type                       /* p-prod-type        */
            ,input  p-prod-code                       /* p-prod-code        */
            ,input  p-goods-gds-goods                 /* p-goods-gds-goods  */
            ,input  p-goods-twounit                   /* p-goods-twounit    */
            ,output v-total-parts-qnty                /* p-total-parts-qnty */
            ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при вызове процедуры partslib-process-document" skip
              "Документ" buf_goods-operation-list.doc-code skip
              "Объект" p-obj-type p-obj-code skip
              "Артикул" p-artic p-prod-type p-prod-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.

          run prdoclib-process-document in this-procedure
            (input  buf_goods-operation-list.doc-code /* p-doc-code           */
            ,input  p-obj-type                        /* p-obj-type           */
            ,input  p-obj-code                        /* p-obj-code           */
            ,input  p-artic                           /* p-artic              */
            ,input  p-prod-type                       /* p-prod-type          */
            ,input  p-prod-code                       /* p-prod-code          */
            ,output v-total-gds-dtl-qnty              /* p-total-gds-dtl-qnty */
            ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при вызове процедуры prdoclib-process-document" skip
              "Документ" buf_goods-operation-list.doc-code skip
              "Объект" p-obj-type p-obj-code skip
              "Артикул" p-artic p-prod-type p-prod-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.

          define variable v-error-exist as logical   no-undo .

          run compare-parts-gds-dtl-total in this-procedure
            (input  buf_goods-operation-list.doc-code /* p-doc-code           */
            ,input  p-obj-type                        /* p-obj-type           */
            ,input  p-obj-code                        /* p-obj-code           */
            ,input  p-artic                           /* p-artic              */
            ,input  p-prod-type                       /* p-prod-type          */
            ,input  p-prod-code                       /* p-prod-code          */
            ,input  v-total-parts-qnty                /* p-total-parts-qnty   */
            ,input  v-total-gds-dtl-qnty              /* p-total-gds-dtl-qnty */
            ,output v-error-exist                     /* p-error-exist        */
            ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при вызове процедуры compare-parts-prt-obj" skip
              "Документ" buf_goods-operation-list.doc-code skip
              "Объект" p-obj-type p-obj-code skip
              "Артикул" p-artic p-prod-type p-prod-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.

          if v-error-exist = true
          then do:
            run temp-trn-doc-list-append in this-procedure
              (input buf_goods-operation-list.doc-code
              ) .
          end.
        end.
        when {&table_price-doc}
        then do:
          /* сравнить рассчитанные количества с партиями и признаками переоценки  */
          run price-list-verify in this-procedure
            (input  buf_goods-operation-list.doc-code /* p-doc-code      */
            ,input  p-obj-type                        /* p-obj-type      */
            ,input  p-obj-code                        /* p-obj-code      */
            ,input  p-artic                           /* p-artic         */
            ,input  p-prod-type                       /* p-prod-type     */
            ,input  p-prod-code                       /* p-prod-code     */
            ,input  p-b-code                          /* p-b-code        */
            ,input  p-goods-twounit                   /* p-goods-twounit */
            ) .
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Внутренняя ошибка" skip
            "Неизвестный тип таблицы" skip
            "Код" buf_goods-operation-list.doc-code skip
            "Тип" buf_goods-operation-list.table-name skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end case .
    end.
  end.

end procedure. /* goods-operation-list-process */


procedure price-list-verify :

  define input  parameter p-doc-code      as character no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define input  parameter p-artic         as character no-undo .
  define input  parameter p-prod-type     as character no-undo .
  define input  parameter p-prod-code     as integer   no-undo .
  define input  parameter p-b-code        as integer   no-undo .
  define input  parameter p-goods-twounit as logical   no-undo .

  define variable v-error-exist as logical   no-undo .

  do
  on error undo, return error return-value
  :
    run temp-price-list-parts-clear in this-procedure .

    run temp-price-list-parts-init in this-procedure
      (input  p-doc-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-artic
      ,input  p-prod-type
      ,input  p-prod-code
      ,input  p-goods-twounit
      ) .

    run temp-price-list-parts-validate in this-procedure
      (input  p-doc-code
      ,output v-error-exist
      ).
    if v-error-exist = true
    then do:
      run temp-price-doc-list-append in this-procedure
        (input p-doc-code
        ) .
    end.


    run temp-price-list-gds-dtl-clear in this-procedure .

    run temp-price-list-gds-dtl-init in this-procedure
      (input  p-doc-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-artic
      ,input  p-prod-type
      ,input  p-prod-code
      ,input  p-b-code
      ,output v-error-exist
      ) .
    if v-error-exist = true
    then do:
      run temp-price-doc-list-append in this-procedure
        (input p-doc-code
        ) .
    end.

    run temp-price-list-gds-dtl-validate in this-procedure
      (input  p-doc-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-artic
      ,input  p-prod-type
      ,input  p-prod-code
      ,output v-error-exist
      ).
    if v-error-exist = true
    then do:
      run temp-price-doc-list-append in this-procedure
        (input p-doc-code
        ) .
    end.
  end.

end procedure. /* price-list-verify */

procedure temp-price-list-parts-clear :

  define buffer buf_temp-price-list-parts for temp-price-list-parts .

  do
  on error undo, return error return-value
  :
    for each buf_temp-price-list-parts
    on error undo, return error return-value
    :
      delete buf_temp-price-list-parts .
    end.
  end.

end procedure. /* temp-price-list-parts-clear */


procedure temp-price-list-parts-init :

  define input  parameter p-doc-code      as character no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define input  parameter p-artic         as character no-undo .
  define input  parameter p-prod-type     as character no-undo .
  define input  parameter p-prod-code     as integer   no-undo .
  define input  parameter p-goods-twounit as logical   no-undo .

  define buffer buf_parts for ub.parts .
  define buffer buf_temp-price-list-parts for temp-price-list-parts .

  define variable v-base-part-code as character no-undo .

  do
  on error undo, return error return-value
  :
    for each buf_parts no-lock
      where buf_parts.out-code  = p-doc-code
        and buf_parts.obj-type  = p-obj-type
        and buf_parts.obj-code  = p-obj-code
        and buf_parts.artic     = p-artic
        and buf_parts.prod-type = p-prod-type
        and buf_parts.prod-code = p-prod-code
    on error undo, return error return-value
    :
      if p-goods-twounit = true
      then do:
        assign
          v-base-part-code = entry(1, buf_parts.part-code, '#':U)
        .
      end.
      else do:
        assign
          v-base-part-code = buf_parts.part-code
        .
      end.

      find first buf_temp-price-list-parts
        where buf_temp-price-list-parts.obj-type  = buf_parts.obj-type
          and buf_temp-price-list-parts.obj-code  = buf_parts.obj-code
          and buf_temp-price-list-parts.artic     = buf_parts.artic
          and buf_temp-price-list-parts.prod-type = buf_parts.prod-type
          and buf_temp-price-list-parts.prod-code = buf_parts.prod-code
          and buf_temp-price-list-parts.in-code   = buf_parts.in-code
          and buf_temp-price-list-parts.out-code  = buf_parts.out-code
          and buf_temp-price-list-parts.part-code = v-base-part-code
        no-error .
      if not available buf_temp-price-list-parts
      then do:
        create buf_temp-price-list-parts .
        buffer-copy buf_parts to buf_temp-price-list-parts
        assign
          buf_temp-price-list-parts.temp-price-list-parts-process = false
          buf_temp-price-list-parts.part-code = v-base-part-code

          buf_temp-price-list-parts.qnty      = 0
          buf_temp-price-list-parts.fact-qnty = 0
          buf_temp-price-list-parts.real-qnty = 0
          buf_temp-price-list-parts.cli-qnty  = 0
        .
      end.

      /* todo - если партия уже была создана - проверить совпадение полей */

      assign
        buf_temp-price-list-parts.qnty      = buf_temp-price-list-parts.qnty
                                            + buf_parts.qnty
        buf_temp-price-list-parts.fact-qnty = buf_temp-price-list-parts.fact-qnty
                                            + buf_parts.fact-qnty
        buf_temp-price-list-parts.real-qnty = buf_temp-price-list-parts.real-qnty
                                            + buf_parts.real-qnty
        buf_temp-price-list-parts.cli-qnty  = buf_temp-price-list-parts.cli-qnty
                                            + buf_parts.cli-qnty
      .
    end.
  end.

end procedure. /* temp-price-list-parts-init */


procedure temp-price-list-parts-validate :

  define input  parameter p-doc-code    as character no-undo .
  define output parameter p-error-exist as logical   no-undo .

  define buffer buf_temp-parts for temp-parts .
  define buffer buf_temp-price-list-parts for temp-price-list-parts .

  define variable v-difference-field-list as character no-undo .

  do
  on error undo, return error return-value
  :
    assign
      p-error-exist = false
    .

    temp-parts_cycle:
    for each buf_temp-parts
    on error undo, return error return-value
    :
      find first buf_temp-price-list-parts
        where buf_temp-price-list-parts.obj-type  = buf_temp-parts.obj-type
          and buf_temp-price-list-parts.obj-code  = buf_temp-parts.obj-code
          and buf_temp-price-list-parts.artic     = buf_temp-parts.artic
          and buf_temp-price-list-parts.prod-type = buf_temp-parts.prod-type
          and buf_temp-price-list-parts.prod-code = buf_temp-parts.prod-code
          and buf_temp-price-list-parts.in-code   = buf_temp-parts.in-code
          and buf_temp-price-list-parts.out-code  = p-doc-code
          and buf_temp-price-list-parts.part-code = buf_temp-parts.part-code
        no-error .
      if not available buf_temp-price-list-parts
      then do:
        assign
          p-error-number = p-error-number + 1
        .
        assign
          p-error-exist = true
        .
        output stream sout to value(v-detail-err-file-name) append .
        export stream sout '### error {&line-number}':U string(today, '99/99/9999':U) string(time, 'HH:MM:SS':U).
        export stream sout 'не найдена партия в переоценке':U .
        export stream sout 'price-doc':U p-doc-code .
        export stream sout 'obj-type':U buf_temp-parts.obj-type .
        export stream sout 'obj-code':U buf_temp-parts.obj-code .
        export stream sout 'artic':U buf_temp-parts.artic .
        export stream sout 'prod-type':U buf_temp-parts.prod-type .
        export stream sout 'prod-code':U buf_temp-parts.prod-code .
        export stream sout 'in-code':U buf_temp-parts.in-code .
        export stream sout 'out-code':U buf_temp-parts.out-code .
        export stream sout 'part-code':U buf_temp-parts.part-code .
        export stream sout 'calculated parts.fact-qnty':U buf_temp-parts.fact-qnty  .
        output stream sout close .

        next temp-parts_cycle . /* --->>>--- */
      end.

      assign
        buf_temp-price-list-parts.temp-price-list-parts-process = true
      .

      buffer-compare buf_temp-parts
        except
          out-code
          status_
          rsrv-free
        to buf_temp-price-list-parts
        save result in v-difference-field-list
        .
      if v-difference-field-list = '':U
      then do:
        assign
          p-error-number = p-error-number + 1
        .
        assign
          p-error-exist = true
        .
        output stream sout to value(v-detail-err-file-name) append .
        export stream sout '### error {&line-number}':U string(today, '99/99/9999':U) string(time, 'HH:MM:SS':U).
        export stream sout 'вычисленная парти и партия переоценки различаются':U .
        export stream sout 'список полей отличий':U v-difference-field-list .
        export stream sout 'price-doc':U p-doc-code .
        export stream sout 'obj-type':U buf_temp-parts.obj-type .
        export stream sout 'obj-code':U buf_temp-parts.obj-code .
        export stream sout 'artic':U buf_temp-parts.artic .
        export stream sout 'prod-type':U buf_temp-parts.prod-type .
        export stream sout 'prod-code':U buf_temp-parts.prod-code .
        export stream sout 'in-code':U buf_temp-parts.in-code .
        export stream sout 'out-code':U buf_temp-parts.out-code .
        export stream sout 'part-code':U buf_temp-parts.part-code .
        export stream sout 'calculated parts.fact-qnty':U buf_temp-parts.fact-qnty  .
        export stream sout 'price-doc parts.fact-qnty':U buf_temp-price-list-parts.fact-qnty .
        export stream sout 'вычисленная партия':U .
        export stream sout buf_temp-parts .
        export stream sout 'партия переоценки':U .
        export stream sout buf_temp-price-list-parts .
        output stream sout close .

        next temp-parts_cycle . /* --->>>--- */
      end.
    end.

    for each buf_temp-price-list-parts
      where buf_temp-price-list-parts.temp-price-list-parts-process = false
    on error undo, return error return-value
    :
      assign
        p-error-number = p-error-number + 1
      .
      assign
        p-error-exist = true
      .
      output stream sout to value(v-detail-err-file-name) append .
      export stream sout '### error {&line-number}':U string(today, '99/99/9999':U) string(time, 'HH:MM:SS':U).
      export stream sout 'в переоценке найдена лишняя партия (не найдена вычисленная партия)':U .
      export stream sout 'price-doc':U p-doc-code .
      export stream sout 'obj-type':U buf_temp-price-list-parts.obj-type .
      export stream sout 'obj-code':U buf_temp-price-list-parts.obj-code .
      export stream sout 'artic':U buf_temp-price-list-parts.artic .
      export stream sout 'prod-type':U buf_temp-price-list-parts.prod-type .
      export stream sout 'prod-code':U buf_temp-price-list-parts.prod-code .
      export stream sout 'in-code':U buf_temp-price-list-parts.in-code .
      export stream sout 'out-code':U buf_temp-price-list-parts.out-code .
      export stream sout 'part-code':U buf_temp-price-list-parts.part-code .
      export stream sout 'difference-field-list':U v-difference-field-list .
      export stream sout 'price-doc parts.fact-qnty':U buf_temp-price-list-parts.fact-qnty .
      export stream sout 'партия переоценки':U .
      export stream sout buf_temp-price-list-parts .
      output stream sout close .
    end.
  end.

end procedure. /* temp-price-list-parts-validate */

procedure temp-price-list-gds-dtl-clear :

  define buffer buf_temp-price-list-gds-dtl for temp-price-list-gds-dtl .

  do
  on error undo, return error return-value
  :
    for each buf_temp-price-list-gds-dtl
    on error undo, return error return-value
    :
      delete buf_temp-price-list-gds-dtl .
    end.
  end.

end procedure. /* temp-price-list-parts-clear */


procedure temp-price-list-gds-dtl-init :

  define input  parameter p-doc-code    as character no-undo .
  define input  parameter p-obj-type    as character no-undo .
  define input  parameter p-obj-code    as integer   no-undo .
  define input  parameter p-artic       as character no-undo .
  define input  parameter p-prod-type   as character no-undo .
  define input  parameter p-prod-code   as integer   no-undo .
  define input  parameter p-b-code      as integer   no-undo .
  define output parameter p-error-exist as logical   no-undo .

  define buffer buf_bar-code                for ub.bar-code .
  define buffer buf_price-list              for ub.price-list .
  define buffer buf_temp-price-list-gds-dtl for temp-price-list-gds-dtl .

  do
  on error undo, return error return-value
  :
    assign
      p-error-exist = false
    .

    find first buf_price-list no-lock
      where buf_price-list.doc-num    = p-doc-code
        and buf_price-list.main-price = true
        and buf_price-list.artic      = p-artic
        and buf_price-list.prod-type  = p-prod-type
        and buf_price-list.prod-code  = p-prod-code
      no-error .
    if not available buf_price-list
    then do:
      assign
        p-error-number = p-error-number + 1
      .
      assign
        p-error-exist = true
      .
      output stream sout to value(v-detail-err-file-name) append .
      export stream sout '### error {&line-number}':U string(today, '99/99/9999':U) string(time, 'HH:MM:SS':U).
      export stream sout 'ошибка при поиске основной цены':U .
      export stream sout 'doc-code':U p-doc-code .
      export stream sout 'artic':U p-artic .
      export stream sout 'prod-type':U p-prod-type .
      export stream sout 'prod-code':U p-prod-code .
      output stream sout close .

      return . /* --->>>--- */
    end.

    find first buf_bar-code no-lock
      where buf_bar-code.b-code = buf_price-list.b-code
      no-error .
    if not available buf_bar-code
    then do:
      assign
        p-error-number = p-error-number + 1
      .
      assign
        p-error-exist = true
      .
      output stream sout to value(v-detail-err-file-name) append .
      export stream sout '### error {&line-number}':U string(today, '99/99/9999':U) string(time, 'HH:MM:SS':U).
      export stream sout 'ошибка при поиске штрих-кода':U .
      export stream sout 'doc-code':U buf_price-list.doc-num .
      export stream sout 'artic':U buf_price-list.artic .
      export stream sout 'prod-type':U buf_price-list.prod-type .
      export stream sout 'prod-code':U buf_price-list.prod-code .
      export stream sout 'b-code':U buf_price-list.b-code .
      output stream sout close .

      return . /* --->>>--- */
    end.


    create buf_temp-price-list-gds-dtl .
    assign
      buf_temp-price-list-gds-dtl.b-code       = buf_price-list.b-code
      buf_temp-price-list-gds-dtl.prt-code     = buf_bar-code.node-code
      buf_temp-price-list-gds-dtl.price-sale   = buf_price-list.price-sale
      buf_temp-price-list-gds-dtl.fact-qnty    = buf_price-list.doc-qnty
      buf_temp-price-list-gds-dtl.gds-dtl-qnty = 0
    .

    price-list_cycle:
    for each buf_price-list no-lock
      where buf_price-list.doc-num    = p-doc-code
        and buf_price-list.main-price = false
        and buf_price-list.artic      = p-artic
        and buf_price-list.prod-type  = p-prod-type
        and buf_price-list.prod-code  = p-prod-code
    on error undo, return error return-value
    :
      find first buf_bar-code no-lock
        where buf_bar-code.b-code = buf_price-list.b-code
        no-error .
      if not available buf_bar-code
      then do:
        assign
          p-error-number = p-error-number + 1
        .
        assign
          p-error-exist = true
        .
        output stream sout to value(v-detail-err-file-name) append .
        export stream sout '### error {&line-number}':U string(today, '99/99/9999':U) string(time, 'HH:MM:SS':U).
        export stream sout 'ошибка при поиске штрих-кода':U .
        export stream sout 'doc-code':U buf_price-list.doc-num .
        export stream sout 'artic':U buf_price-list.artic .
        export stream sout 'prod-type':U buf_price-list.prod-type .
        export stream sout 'prod-code':U buf_price-list.prod-code .
        export stream sout 'b-code':U buf_price-list.b-code .
        output stream sout close .

        next price-list_cycle . /* --->>>--- */
      end.

      /* анализ штрих кода */

      if buf_bar-code.in-code <> ""
      or buf_bar-code.part-code <> ""
      then do:
        /* цены на штрих-коды партий не поддерживаются */
        assign
          p-error-number = p-error-number + 1
        .
        assign
          p-error-exist = true
        .
        output stream sout to value(v-detail-err-file-name) append .
        export stream sout '### error {&line-number}':U string(today, '99/99/9999':U) string(time, 'HH:MM:SS':U).
        export stream sout 'цены для штрих-кодов партий не поддерживаются':U .
        export stream sout 'doc-code':U buf_price-list.doc-num .
        export stream sout 'artic':U buf_price-list.artic .
        export stream sout 'prod-type':U buf_price-list.prod-type .
        export stream sout 'prod-code':U buf_price-list.prod-code .
        export stream sout 'b-code':U buf_price-list.b-code .
        output stream sout close .

        next price-list_cycle . /* --->>>--- */
      end.

      /* проанализировать единицу измерения */
      /* если единица изменения отлична от базовой, то количество должно быть равно нулю */

      if buf_bar-code.unit-cli <> v-unit-base
      then do:
        if buf_price-list.doc-qnty <> ?
        then do:
          assign
            p-error-number = p-error-number + 1
          .
          assign
            p-error-exist = true
          .
          output stream sout to value(v-detail-err-file-name) append .
          export stream sout '### error {&line-number}':U string(today, '99/99/9999':U) string(time, 'HH:MM:SS':U).
          export stream sout 'для неосновных единиц измерения количество должно равняться вопросительному знаку':U .
          export stream sout 'doc-code':U buf_price-list.doc-num .
          export stream sout 'artic':U buf_price-list.artic .
          export stream sout 'prod-type':U buf_price-list.prod-type .
          export stream sout 'prod-code':U buf_price-list.prod-code .
          export stream sout 'b-code':U buf_price-list.b-code .
          export stream sout 'unit-base':U v-unit-base .
          export stream sout 'bar-code.unit-cli':U buf_bar-code.unit-cli .
          export stream sout 'price-list.doc-qnty':U buf_price-list.doc-qnty .
          output stream sout close .
        end.
        next price-list_cycle . /* --->>>--- */
      end.

      /* цена для любого признака с основной единицей измерения */
      /* записывается во временную таблицу */
      create buf_temp-price-list-gds-dtl .
      assign
        buf_temp-price-list-gds-dtl.b-code                          = buf_price-list.b-code
        buf_temp-price-list-gds-dtl.prt-code                        = buf_bar-code.node-code
        buf_temp-price-list-gds-dtl.price-sale                      = buf_price-list.price-sale
        buf_temp-price-list-gds-dtl.fact-qnty                       = buf_price-list.doc-qnty
        buf_temp-price-list-gds-dtl.gds-dtl-qnty                    = 0
      .
    end.
  end.

end procedure. /* temp-price-list-gds-dtl-init */


procedure temp-price-list-gds-dtl-validate :

  define input  parameter p-doc-code    as character no-undo .
  define input  parameter p-obj-type    as character no-undo .
  define input  parameter p-obj-code    as integer   no-undo .
  define input  parameter p-artic       as character no-undo .
  define input  parameter p-prod-type   as character no-undo .
  define input  parameter p-prod-code   as integer   no-undo .
  define output parameter p-error-exist as logical   no-undo .

  define buffer buf_gds-prt for ub.gds-prt .
  define buffer buf_temp-prt-obj for temp-prt-obj .
  define buffer buf_temp-price-list-gds-dtl for temp-price-list-gds-dtl .

  define variable v-difference-field-list as character no-undo .
  define variable v-error-exist           as logical   no-undo .

  do
  on error undo, return error return-value
  :
    assign
      p-error-exist = false
    .

    /* для каждого признака производится поиск цены */
    /* если ее нет производится поиск для родительского признака */
    /* и так до корневого признака */
    /* когда цена найдена - записывается количество по признаку */

    temp-prt-obj_cycle:
    for each buf_temp-prt-obj
    on error undo, return error return-value
    :
      find first buf_gds-prt no-lock
        where buf_gds-prt.node-code = buf_temp-prt-obj.prt-code
        no-error .
      if not available buf_gds-prt
      then do:
        assign
          p-error-number = p-error-number + 1
        .
        assign
          p-error-exist = true
        .
        output stream sout to value(v-detail-err-file-name) append .
        export stream sout '### error {&line-number}':U string(today, '99/99/9999':U) string(time, 'HH:MM:SS':U).
        export stream sout 'не найден признак шкалы':U .
        export stream sout 'doc-code':U p-doc-code .
        export stream sout 'obj-type':U p-obj-type .
        export stream sout 'obj-code':U p-obj-code .
        export stream sout 'artic':U p-artic .
        export stream sout 'prod-type':U p-prod-type .
        export stream sout 'prod-code':U p-prod-code .
        export stream sout 'prt-code':U buf_temp-prt-obj.prt-code .
        output stream sout close .

        return . /* --->>>--- */
      end.

      do while available buf_gds-prt
      :
        find first buf_temp-price-list-gds-dtl
          where buf_temp-price-list-gds-dtl.prt-code = buf_gds-prt.node-code
          no-error .
        if available buf_temp-price-list-gds-dtl
        then do:
          assign
            buf_temp-price-list-gds-dtl.gds-dtl-qnty = buf_temp-price-list-gds-dtl.gds-dtl-qnty
                                                     + buf_temp-prt-obj.fact-qnty
          .
          next temp-prt-obj_cycle . /* --->>>--- */
        end.

        define variable v-node-code as integer   no-undo .
        assign
          v-node-code = buf_gds-prt.upper-code
        .
        find first buf_gds-prt no-lock
          where buf_gds-prt.node-code = v-node-code
          no-error .
      end.
    end.

    /* сравниваются количества по признаку и по переоценке */
    for each buf_temp-price-list-gds-dtl
    on error undo, return error return-value
    :
      if buf_temp-price-list-gds-dtl.fact-qnty <> buf_temp-price-list-gds-dtl.gds-dtl-qnty
      then do:
        assign
          p-error-number = p-error-number + 1
        .
        assign
          p-error-exist = true
        .
        output stream sout to value(v-detail-err-file-name) append .
        export stream sout '### error {&line-number}':U string(today, '99/99/9999':U) string(time, 'HH:MM:SS':U).
        export stream sout 'отличия в количествах для переоценки и вычисленных количествах по признаку':U .
        export stream sout 'doc-code':U p-doc-code .
        export stream sout 'obj-type':U p-obj-type .
        export stream sout 'obj-code':U p-obj-code .
        export stream sout 'artic':U p-artic .
        export stream sout 'prod-type':U p-prod-type .
        export stream sout 'prod-code':U p-prod-code .
        export stream sout 'b-code':U buf_temp-price-list-gds-dtl.b-code .
        export stream sout 'prt-code':U buf_temp-price-list-gds-dtl.prt-code .
        export stream sout 'price-sale':U buf_temp-price-list-gds-dtl.price-sale .
        export stream sout 'fact-qnty':U buf_temp-price-list-gds-dtl.fact-qnty .
        export stream sout 'gds-dtl-qnty':U buf_temp-price-list-gds-dtl.gds-dtl-qnty .
        output stream sout close .
      end.
    end.
  end.

end procedure. /* temp-price-list-gds-dtl-validate */

procedure temp-price-doc-list-append :

  define input  parameter p-doc-code as character no-undo .

  define buffer buf_temp-price-doc-list for temp-price-doc-list .
  define buffer buf_price-doc           for ub.price-doc .

  do
  on error undo, return error return-value
  :
    find first buf_temp-price-doc-list
      where buf_temp-price-doc-list.doc-code = p-doc-code
      no-error .
    if not available buf_temp-price-doc-list
    then do:
      create buf_temp-price-doc-list .
      assign
        buf_temp-price-doc-list.doc-code = p-doc-code
      .

      find first buf_price-doc no-lock
        where buf_price-doc.doc-num = p-doc-code
        no-error .
      if available buf_price-doc
      then do:
        assign
          buf_temp-price-doc-list.fact-order = buf_price-doc.fact-order
          buf_temp-price-doc-list.fact-date  = buf_price-doc.fact-date
        .
      end.
    end.
  end.

end procedure. /* temp-price-doc-list-append */


procedure temp-price-doc-list-export :

  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  define buffer buf_temp-price-doc-list for temp-price-doc-list .

  do
  on error undo, return error return-value
  :
    find first buf_temp-price-doc-list
      no-error .
    if available buf_temp-price-doc-list
    then do:
      output stream sout to value(v-price-doc-list-file-name) append .
      export stream sout '### list of error price-doc':U string(today, '99/99/9999':U) string(time, 'HH:MM:SS':U).
      export stream sout 'p-obj-type' p-obj-type .
      export stream sout 'p-obj-code' p-obj-code .

      for each buf_temp-price-doc-list
      by buf_temp-price-doc-list.fact-order
      on error undo, return error return-value
      :
        export stream sout
          buf_temp-price-doc-list.doc-code
          buf_temp-price-doc-list.fact-date
          .
      end.

      output stream sout close .
    end.
  end.

end procedure. /* temp-price-doc-list-export */


procedure temp-trn-doc-list-append :

  define input  parameter p-doc-code as character no-undo .

  define buffer buf_temp-trn-doc-list for temp-trn-doc-list .
  define buffer buf_trn-doc           for ub.trn-doc .

  do
  on error undo, return error return-value
  :
    find first buf_temp-trn-doc-list
      where buf_temp-trn-doc-list.doc-code = p-doc-code
      no-error .
    if not available buf_temp-trn-doc-list
    then do:
      create buf_temp-trn-doc-list .
      assign
        buf_temp-trn-doc-list.doc-code = p-doc-code
      .

      find first buf_trn-doc no-lock
        where buf_trn-doc.doc-code = p-doc-code
        no-error .
      if available buf_trn-doc
      then do:
        assign
          buf_temp-trn-doc-list.fact-order = buf_trn-doc.fact-order
          buf_temp-trn-doc-list.fact-date  = buf_trn-doc.fact-date
        .
      end.
    end.
  end.

end procedure. /* temp-trn-doc-list-append */


procedure temp-trn-doc-list-export :

  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  define buffer buf_temp-trn-doc-list for temp-trn-doc-list .

  do
  on error undo, return error return-value
  :
    find first buf_temp-trn-doc-list
      no-error .
    if available buf_temp-trn-doc-list
    then do:
      output stream sout to value(v-trn-doc-list-file-name) append .
      export stream sout '### list of error trn-doc':U string(today, '99/99/9999':U) string(time, 'HH:MM:SS':U).
      export stream sout 'p-obj-type' p-obj-type .
      export stream sout 'p-obj-code' p-obj-code .

      for each buf_temp-trn-doc-list
      by buf_temp-trn-doc-list.fact-order
      on error undo, return error return-value
      :
        export stream sout
          buf_temp-trn-doc-list.doc-code
          buf_temp-trn-doc-list.fact-date
          .
      end.

      output stream sout close .
    end.
  end.

end procedure. /* temp-trn-doc-list-export */


procedure compare-parts-gds-dtl-total :

  define input  parameter p-doc-code           as character no-undo .
  define input  parameter p-obj-type           as character no-undo .
  define input  parameter p-obj-code           as integer   no-undo .
  define input  parameter p-artic              as character no-undo .
  define input  parameter p-prod-type          as character no-undo .
  define input  parameter p-prod-code          as integer   no-undo .
  define input  parameter p-total-parts-qnty   as decimal   no-undo .
  define input  parameter p-total-gds-dtl-qnty as decimal   no-undo .
  define output parameter p-error-exist        as logical   no-undo .

  define buffer buf_temp-parts   for temp-parts .
  define buffer buf_temp-prt-obj for temp-prt-obj .

  do
  on error undo, return error return-value
  :
    assign
      p-error-exist = false
    .

    if p-total-parts-qnty <> p-total-gds-dtl-qnty
    then do:
      assign
        p-error-number = p-error-number + 1
      .
      output stream sout to value(v-detail-err-file-name) append .
      export stream sout '### error {&line-number}':U string(today, '99/99/9999':U) string(time, 'HH:MM:SS':U).
      export stream sout 'для складского документа обнаружена разница в общем количестве по партиям и признакам':U .
      export stream sout 'trn-doc':U p-doc-code .
      export stream sout 'obj-type':U p-obj-type .
      export stream sout 'obj-code':U p-obj-code .
      export stream sout 'artic':U p-artic .
      export stream sout 'prod-type':U p-prod-type .
      export stream sout 'prod-code':U p-prod-code .
      export stream sout 'p-total-parts-qnty':U p-total-parts-qnty .
      export stream sout 'p-total-gds-dtl-qnty':U p-total-gds-dtl-qnty .
      output stream sout close .

      assign
        p-error-exist = true
      .
    end.
  end.

end procedure. /* compare-parts-gds-dtl-total */


procedure temp-prt-obj-leave-term :

  define buffer buf_temp-prt-obj for temp-prt-obj .

  do
  on error undo, return error return-value
  :
    for each buf_temp-prt-obj
      where buf_temp-prt-obj.is-term <> true
    :
      delete buf_temp-prt-obj .
    end.
  end.

end procedure. /* temp-prt-obj-leave-term */