block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: car-aht.p $
$Archive: utl/car-aht.p $

Программа проверки складского архива по типам приобретени

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 03/16/04

*/

define input  parameter p-obj-type               as character no-undo .
define input  parameter p-obj-code               as integer   no-undo .
define output parameter p-err-num                as integer   no-undo .
define output parameter p-last-date              as date      no-undo .
define output parameter p-error-description      as character no-undo .
define output parameter p-detail-error-file-name as character no-undo .


define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: car-aht.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: utl/car-aht.p $":U .
define variable vss-description as character no-undo initial "Программа проверки складского архива по типам приобретения".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ gbl/waitfram.i }
{ trg/factord.i  }
{ gbl/clntattr.i }
{ trg/partslib.i }

define variable v-ind            as integer   no-undo .
define variable v-total-err      as integer   no-undo .
define variable v-today          as date      no-undo .
define variable v-time           as integer   no-undo .

define variable v-log-err-file   as character no-undo .

define stream sout .

define temp-table temp-date no-undo
  field arch-date          as date    format '99/99/9999':u
  field fact-ord-begin-day as decimal format '>>>,>>>,>>9.99':u
  field fact-ord-end-day   as decimal format '>>>,>>>,>>9.99':u
  field temp-date-ok       as logical
  index xpk is primary unique arch-date
    .

define temp-table temp-aht-ot-day no-undo
  field temp-gds-code            as integer
  field temp-sum-type            as character
  field temp-fact-qnty           as decimal
  field temp-cost-sum-base       as decimal
  field temp-cost-sum-rubl       as decimal
  field temp-cost-VAT-base       as decimal
  field temp-cost-VAT-rubl       as decimal
  field temp-cost-SLT-base       as decimal
  field temp-cost-SLT-rubl       as decimal
  field temp-cost-road-tax-base  as decimal
  field temp-cost-road-tax-rubl  as decimal
  field temp-cost-excise-base    as decimal
  field temp-cost-excise-rubl    as decimal
  field temp-cost-transport-base as decimal
  field temp-cost-transport-rubl as decimal
  field temp-cost-other-base     as decimal
  field temp-cost-other-rubl     as decimal
  field temp-cost-discnt-base    as decimal
  field temp-cost-discnt-rubl    as decimal
  field temp-crsa-sum-base       as decimal
  field temp-crsa-sum-rubl       as decimal
  field temp-crsa-VAT-base       as decimal
  field temp-crsa-VAT-rubl       as decimal
  field temp-crsa-SLT-base       as decimal
  field temp-crsa-SLT-rubl       as decimal
  field temp-crsa-road-tax-base  as decimal
  field temp-crsa-road-tax-rubl  as decimal
  field temp-crsa-excise-base    as decimal
  field temp-crsa-excise-rubl    as decimal
  field temp-crsa-transport-base as decimal
  field temp-crsa-transport-rubl as decimal
  field temp-crsa-other-base     as decimal
  field temp-crsa-other-rubl     as decimal
  field temp-crsa-discnt-base    as decimal
  field temp-crsa-discnt-rubl    as decimal
  field temp-sale-sum-base       as decimal
  field temp-sale-sum-rubl       as decimal
  field temp-sale-VAT-base       as decimal
  field temp-sale-VAT-rubl       as decimal
  field temp-sale-SLT-base       as decimal
  field temp-sale-SLT-rubl       as decimal
  field temp-sale-road-tax-base  as decimal
  field temp-sale-road-tax-rubl  as decimal
  field temp-sale-excise-base    as decimal
  field temp-sale-excise-rubl    as decimal
  field temp-sale-transport-base as decimal
  field temp-sale-transport-rubl as decimal
  field temp-sale-other-base     as decimal
  field temp-sale-other-rubl     as decimal
  field temp-sale-discnt-base    as decimal
  field temp-sale-discnt-rubl    as decimal
  index xpk is primary unique
    temp-gds-code
    temp-sum-type
  index xie temp-sum-type
    .

define temp-table temp-aht-stk-line no-undo
  field temp-gds-code   as integer
  field temp-sum-type   as character
  field temp-fact-qnty  as decimal
  field temp-fact-order as decimal
  field temp-gds-qnty   as decimal
  index xpk is primary unique
    temp-gds-code
    temp-sum-type
  index xie temp-sum-type
    .

define temp-table temp-gds no-undo
  field temp-gds-code as integer
  index xpk is primary unique
    temp-gds-code
    .

do
on error undo, return error return-value
:
  assign
    v-log-err-file = substitute('car-aht-&1-&2.err':U
                               ,p-obj-type
                               ,p-obj-code
                               )
    p-detail-error-file-name = v-log-err-file
  .

  os-delete value(v-log-err-file) .

  /* определяем дни, когда был оборот или остатки */
  run fill-temp-date in this-procedure .

  /* проверяем соответствие оборота и остатков */
  run check-temp-date in this-procedure .

  /* очищаем все временные таблицы */
  run clear-temp-date in this-procedure .

  run clear-temp-aht-ot-day in this-procedure .

  /* проверяем соответствие остатков текущей свободной зоне */
  /* free-zone -> aht-stk-line */
  run validate-free-zone in this-procedure .

  /* проверяем соответствие текущей свободной зоны остатка */
  /* aht-stk-line -> free-zone */
  run clear-temp-aht-stk-line in this-procedure .

  run check-fact-order in this-procedure .

  run fill-temp-aht-stk-line in this-procedure .

  run check-free-zone-from-aht-stk-line in this-procedure .

  assign
    p-err-num = v-total-err
  .
end.


procedure clear-temp-date :

  define buffer buf_temp-date for temp-date .

  do
  on error undo, return error return-value
  :
    for each buf_temp-date
    on error undo, return error return-value
    :
      delete buf_temp-date .
    end.
  end.

end procedure. /* clear-temp-date */

procedure fill-temp-date :

  define variable v-attr-value          as character no-undo .
  define variable v-attr-type           as character no-undo .
  define variable v-aht-detail-date     as date      no-undo .
  define variable v-fact-ord-begin-aht  as decimal   no-undo .
  define variable v-fact-date           as date      no-undo .
  define variable v-fact-ord-begin-day  as decimal   no-undo .
  define variable v-fact-ord-end-day    as decimal   no-undo .

  define buffer buf_temp-date for temp-date .
  define buffer buf_aht-ot-line for ub.aht-ot-line .
  define buffer buf_aht-stk-line for ub.aht-stk-line .

  do
  on error undo, return error return-value
  :

    /* сначала определяем начало подробного архива */
    /* проверка целостности рассчитана только на проверку подробного складского архива */
    run clntattr-value in this-procedure
      (input  p-obj-type               /* p-obj-type */
      ,input  p-obj-code               /* p-obj-code */
      ,input  {&attr-aht-detail-date} /* p-code     */
      ,output v-attr-value             /* p-value    */
      ,output v-attr-type              /* p-type     */
      ) .
    assign
      v-aht-detail-date = date(v-attr-value)
    .

    if v-aht-detail-date <> ?
    then do:
      run day-begin-fact-order in this-procedure
        (input  v-aht-detail-date    /* p-fact-date            */
        ,output v-fact-ord-begin-aht /* p-day-begin-fact-order */
        ) .
    end.
    else do:
      assign
        v-fact-ord-begin-aht = 0
      .
    end.

    /* составляем список дат, за которые имеется складской архив */
    /* на основании записей оборота по типам приобретения */
    find first buf_aht-ot-line no-lock
      where buf_aht-ot-line.obj-type   = p-obj-type
        and buf_aht-ot-line.obj-code   = p-obj-code
        and buf_aht-ot-line.fact-order > v-fact-ord-begin-aht
      use-index fact-order
      no-error .
    do while available buf_aht-ot-line
    :
      run factord-to-date in this-procedure
        (input  buf_aht-ot-line.fact-order /* p-fact-order */
        ,output v-fact-date                /* p-fact-date  */
        ) .

      run day-begin-fact-order in this-procedure
        (input  v-fact-date          /* p-fact-date            */
        ,output v-fact-ord-begin-day /* p-day-begin-fact-order */
        ) .

      run factord-end-day in this-procedure
        (input  v-fact-date        /* p-fact-date          */
        ,output v-fact-ord-end-day /* p-day-end-fact-order */
        ) .

      create buf_temp-date .
      assign
        buf_temp-date.arch-date          = v-fact-date
        buf_temp-date.fact-ord-begin-day = v-fact-ord-begin-day
        buf_temp-date.fact-ord-end-day   = v-fact-ord-end-day
      .

      find first buf_aht-ot-line no-lock
        where buf_aht-ot-line.obj-type   = p-obj-type
          and buf_aht-ot-line.obj-code   = p-obj-code
          and buf_aht-ot-line.fact-order > v-fact-ord-end-day
        use-index fact-order
        no-error .
    end.

    /* составляем список дат за которые имеется складской архив */
    /* на основании записей остатков */
    find first buf_aht-stk-line no-lock
      where buf_aht-stk-line.obj-type   = p-obj-type
        and buf_aht-stk-line.obj-code   = p-obj-code
        and buf_aht-stk-line.fact-order > v-fact-ord-begin-aht
      use-index fact-order
      no-error .
    do while available buf_aht-stk-line
    :
      run factord-to-date in this-procedure
        (input  buf_aht-stk-line.fact-order /* p-fact-order */
        ,output v-fact-date                 /* p-fact-date  */
        ) .

      run day-begin-fact-order in this-procedure
        (input  v-fact-date          /* p-fact-date            */
        ,output v-fact-ord-begin-day /* p-day-begin-fact-order */
        ) .

      run factord-end-day in this-procedure
        (input  v-fact-date        /* p-fact-date          */
        ,output v-fact-ord-end-day /* p-day-end-fact-order */
        ) .

      find first buf_temp-date
        where buf_temp-date.arch-date = v-fact-date
        no-error .
      if not available buf_temp-date
      then do:
        create buf_temp-date .
        assign
          buf_temp-date.arch-date          = v-fact-date
          buf_temp-date.fact-ord-begin-day = v-fact-ord-begin-day
          buf_temp-date.fact-ord-end-day   = v-fact-ord-end-day
        .
      end.

      find first buf_aht-stk-line no-lock
        where buf_aht-stk-line.obj-type   = p-obj-type
          and buf_aht-stk-line.obj-code   = p-obj-code
          and buf_aht-stk-line.fact-order > v-fact-ord-end-day
        use-index fact-order
        no-error .
    end.
  end.

end procedure. /* fill-temp-date */



procedure check-temp-date :

  define buffer buf_temp-date for temp-date .

  do
  on error undo, return error return-value
  :
    define variable v-aht-detail-date as date      no-undo .
    define variable v-attr-value      as character no-undo .
    define variable v-attr-type       as character no-undo .

    /* сначала определяем начало подробного складского архива */
    /* в случае если складской архив был рассчитан с определенной даты */
    /* следует пропустить первый день при проверке накопительного складского архива */

    run clntattr-value in this-procedure
      (input  p-obj-type               /* p-obj-type */
      ,input  p-obj-code               /* p-obj-code */
      ,input  {&attr-aht-detail-date}  /* p-code     */
      ,output v-attr-value             /* p-value    */
      ,output v-attr-type              /* p-type     */
      ) .
    assign
      v-aht-detail-date = date(v-attr-value)
    .

    for each buf_temp-date
    on error undo, return error return-value
    :
      run waitfram-show in this-procedure
        (input substitute("Анализ складского архива по типам приобретения. Ошибок &1. Объект &2 &3. Дата &4."
                        ,v-total-err
                        ,p-obj-type
                        ,p-obj-code
                        ,string(buf_temp-date.arch-date, '99/99/9999':u)
                        )
        ).
      run clear-temp-aht-ot-day in this-procedure .

      run fill-temp-aht-ot-day in this-procedure
        (input  buf_temp-date.arch-date          /* p-fact-date            */
        ,input  buf_temp-date.fact-ord-begin-day /* p-fact-order-begin-day */
        ,input  buf_temp-date.fact-ord-end-day   /* p-fact-order-end-day   */
        ) .

      run validate-aht-ot-line-stk in this-procedure
        (input  buf_temp-date.arch-date          /* p-fact-date            */
        ,input  buf_temp-date.fact-ord-begin-day /* p-fact-order-begin-day */
        ,input  buf_temp-date.fact-ord-end-day   /* p-fact-order-end-day   */
        ) .

      if v-aht-detail-date = ?
      or (v-aht-detail-date <> ?
          and buf_temp-date.arch-date >= v-aht-detail-date
         )
      then do:
        run validate-aht-stk-line in this-procedure
          (input buf_temp-date.arch-date          /* p-fact-date            */
          ,input buf_temp-date.fact-ord-begin-day /* p-fact-order-begin-day */
          ,input buf_temp-date.fact-ord-end-day   /* p-fact-order-end-day   */
          ) .
      end.
    end.
  end.

end procedure. /* check-temp-date */


procedure validate-aht-ot-line-stk :

  define input  parameter p-fact-date            as date      no-undo .
  define input  parameter p-fact-order-begin-day as decimal   no-undo .
  define input  parameter p-fact-order-end-day   as decimal   no-undo .

  define variable v-fact-qnty           as decimal   no-undo .

  define variable v-cost-sum-base       as decimal   no-undo .
  define variable v-cost-sum-rubl       as decimal   no-undo .
  define variable v-cost-VAT-base       as decimal   no-undo .
  define variable v-cost-VAT-rubl       as decimal   no-undo .
  define variable v-cost-SLT-base       as decimal   no-undo .
  define variable v-cost-SLT-rubl       as decimal   no-undo .
  define variable v-cost-road-tax-base  as decimal   no-undo .
  define variable v-cost-road-tax-rubl  as decimal   no-undo .
  define variable v-cost-excise-base    as decimal   no-undo .
  define variable v-cost-excise-rubl    as decimal   no-undo .
  define variable v-cost-transport-base as decimal   no-undo .
  define variable v-cost-transport-rubl as decimal   no-undo .
  define variable v-cost-other-base     as decimal   no-undo .
  define variable v-cost-other-rubl     as decimal   no-undo .
  define variable v-cost-discnt-base    as decimal   no-undo .
  define variable v-cost-discnt-rubl    as decimal   no-undo .

  define variable v-crsa-sum-base       as decimal   no-undo .
  define variable v-crsa-sum-rubl       as decimal   no-undo .
  define variable v-crsa-VAT-base       as decimal   no-undo .
  define variable v-crsa-VAT-rubl       as decimal   no-undo .
  define variable v-crsa-SLT-base       as decimal   no-undo .
  define variable v-crsa-SLT-rubl       as decimal   no-undo .
  define variable v-crsa-road-tax-base  as decimal   no-undo .
  define variable v-crsa-road-tax-rubl  as decimal   no-undo .
  define variable v-crsa-excise-base    as decimal   no-undo .
  define variable v-crsa-excise-rubl    as decimal   no-undo .
  define variable v-crsa-transport-base as decimal   no-undo .
  define variable v-crsa-transport-rubl as decimal   no-undo .
  define variable v-crsa-other-base     as decimal   no-undo .
  define variable v-crsa-other-rubl     as decimal   no-undo .
  define variable v-crsa-discnt-base    as decimal   no-undo .
  define variable v-crsa-discnt-rubl    as decimal   no-undo .

  define variable v-sale-sum-base       as decimal   no-undo .
  define variable v-sale-sum-rubl       as decimal   no-undo .
  define variable v-sale-VAT-base       as decimal   no-undo .
  define variable v-sale-VAT-rubl       as decimal   no-undo .
  define variable v-sale-SLT-base       as decimal   no-undo .
  define variable v-sale-SLT-rubl       as decimal   no-undo .
  define variable v-sale-road-tax-base  as decimal   no-undo .
  define variable v-sale-road-tax-rubl  as decimal   no-undo .
  define variable v-sale-excise-base    as decimal   no-undo .
  define variable v-sale-excise-rubl    as decimal   no-undo .
  define variable v-sale-transport-base as decimal   no-undo .
  define variable v-sale-transport-rubl as decimal   no-undo .
  define variable v-sale-other-base     as decimal   no-undo .
  define variable v-sale-other-rubl     as decimal   no-undo .
  define variable v-sale-discnt-base    as decimal   no-undo .
  define variable v-sale-discnt-rubl    as decimal   no-undo .

  define buffer buf_aht-stk-line    for ub.aht-stk-line .
  define buffer buf_temp-aht-ot-day for temp-aht-ot-day .

  do
  on error undo, return error return-value
  :
    for each buf_temp-aht-ot-day
    on error undo, return error return-value
    :
      find last buf_aht-stk-line no-lock
        where buf_aht-stk-line.obj-type   = p-obj-type
          and buf_aht-stk-line.obj-code   = p-obj-code
          and buf_aht-stk-line.gds-code   = buf_temp-aht-ot-day.temp-gds-code
          and buf_aht-stk-line.sum-type   = buf_temp-aht-ot-day.temp-sum-type
          and buf_aht-stk-line.fact-order < p-fact-order-begin-day
        use-index category
        no-error .
      if available buf_aht-stk-line
      then do:
        if buf_temp-aht-ot-day.temp-sum-type <> {&aht-service}
        then do:
          assign
            v-fact-qnty           = - buf_aht-stk-line.fact-qnty

            v-cost-sum-base       = - buf_aht-stk-line.cost-sum-base
            v-cost-sum-rubl       = - buf_aht-stk-line.cost-sum-rubl
            v-cost-VAT-base       = - buf_aht-stk-line.cost-VAT-base
            v-cost-VAT-rubl       = - buf_aht-stk-line.cost-VAT-rubl
            v-cost-SLT-base       = - buf_aht-stk-line.cost-SLT-base
            v-cost-SLT-rubl       = - buf_aht-stk-line.cost-SLT-rubl
            v-cost-road-tax-base  = - buf_aht-stk-line.cost-road-tax-base
            v-cost-road-tax-rubl  = - buf_aht-stk-line.cost-road-tax-rubl
            v-cost-excise-base    = - buf_aht-stk-line.cost-excise-base
            v-cost-excise-rubl    = - buf_aht-stk-line.cost-excise-rubl
            v-cost-transport-base = - buf_aht-stk-line.cost-transport-base
            v-cost-transport-rubl = - buf_aht-stk-line.cost-transport-rubl
            v-cost-other-base     = - buf_aht-stk-line.cost-other-base
            v-cost-other-rubl     = - buf_aht-stk-line.cost-other-rubl
            v-cost-discnt-base    = - buf_aht-stk-line.cost-discnt-base
            v-cost-discnt-rubl    = - buf_aht-stk-line.cost-discnt-rubl

            v-crsa-sum-base       = - buf_aht-stk-line.crsa-sum-base
            v-crsa-sum-rubl       = - buf_aht-stk-line.crsa-sum-rubl
            v-crsa-VAT-base       = - buf_aht-stk-line.crsa-VAT-base
            v-crsa-VAT-rubl       = - buf_aht-stk-line.crsa-VAT-rubl
            v-crsa-SLT-base       = - buf_aht-stk-line.crsa-SLT-base
            v-crsa-SLT-rubl       = - buf_aht-stk-line.crsa-SLT-rubl
            v-crsa-road-tax-base  = - buf_aht-stk-line.crsa-road-tax-base
            v-crsa-road-tax-rubl  = - buf_aht-stk-line.crsa-road-tax-rubl
            v-crsa-excise-base    = - buf_aht-stk-line.crsa-excise-base
            v-crsa-excise-rubl    = - buf_aht-stk-line.crsa-excise-rubl
            v-crsa-transport-base = - buf_aht-stk-line.crsa-transport-base
            v-crsa-transport-rubl = - buf_aht-stk-line.crsa-transport-rubl
            v-crsa-other-base     = - buf_aht-stk-line.crsa-other-base
            v-crsa-other-rubl     = - buf_aht-stk-line.crsa-other-rubl
            v-crsa-discnt-base    = - buf_aht-stk-line.crsa-discnt-base
            v-crsa-discnt-rubl    = - buf_aht-stk-line.crsa-discnt-rubl

            v-sale-sum-base       = - buf_aht-stk-line.sale-sum-base
            v-sale-sum-rubl       = - buf_aht-stk-line.sale-sum-rubl
            v-sale-VAT-base       = - buf_aht-stk-line.sale-VAT-base
            v-sale-VAT-rubl       = - buf_aht-stk-line.sale-VAT-rubl
            v-sale-SLT-base       = - buf_aht-stk-line.sale-SLT-base
            v-sale-SLT-rubl       = - buf_aht-stk-line.sale-SLT-rubl
            v-sale-road-tax-base  = - buf_aht-stk-line.sale-road-tax-base
            v-sale-road-tax-rubl  = - buf_aht-stk-line.sale-road-tax-rubl
            v-sale-excise-base    = - buf_aht-stk-line.sale-excise-base
            v-sale-excise-rubl    = - buf_aht-stk-line.sale-excise-rubl
            v-sale-transport-base = - buf_aht-stk-line.sale-transport-base
            v-sale-transport-rubl = - buf_aht-stk-line.sale-transport-rubl
            v-sale-other-base     = - buf_aht-stk-line.sale-other-base
            v-sale-other-rubl     = - buf_aht-stk-line.sale-other-rubl
            v-sale-discnt-base    = - buf_aht-stk-line.sale-discnt-base
            v-sale-discnt-rubl    = - buf_aht-stk-line.sale-discnt-rubl
          .
        end.
        else do:
          assign
            v-fact-qnty           = 0
            v-cost-sum-base       = 0
            v-cost-sum-rubl       = 0
            v-cost-VAT-base       = 0
            v-cost-VAT-rubl       = 0
            v-cost-SLT-base       = 0
            v-cost-SLT-rubl       = 0
            v-cost-road-tax-base  = 0
            v-cost-road-tax-rubl  = 0
            v-cost-excise-base    = 0
            v-cost-excise-rubl    = 0
            v-cost-transport-base = 0
            v-cost-transport-rubl = 0
            v-cost-other-base     = 0
            v-cost-other-rubl     = 0
            v-cost-discnt-base    = 0
            v-cost-discnt-rubl    = 0

            v-crsa-sum-base       = 0
            v-crsa-sum-rubl       = 0
            v-crsa-VAT-base       = 0
            v-crsa-VAT-rubl       = 0
            v-crsa-SLT-base       = 0
            v-crsa-SLT-rubl       = 0
            v-crsa-road-tax-base  = 0
            v-crsa-road-tax-rubl  = 0
            v-crsa-excise-base    = 0
            v-crsa-excise-rubl    = 0
            v-crsa-transport-base = 0
            v-crsa-transport-rubl = 0
            v-crsa-other-base     = 0
            v-crsa-other-rubl     = 0
            v-crsa-discnt-base    = 0
            v-crsa-discnt-rubl    = 0

            v-sale-sum-base       = 0
            v-sale-sum-rubl       = 0
            v-sale-VAT-base       = 0
            v-sale-VAT-rubl       = 0
            v-sale-SLT-base       = 0
            v-sale-SLT-rubl       = 0
            v-sale-road-tax-base  = 0
            v-sale-road-tax-rubl  = 0
            v-sale-excise-base    = 0
            v-sale-excise-rubl    = 0
            v-sale-transport-base = 0
            v-sale-transport-rubl = 0
            v-sale-other-base     = 0
            v-sale-other-rubl     = 0
            v-sale-discnt-base    = 0
            v-sale-discnt-rubl    = 0
          .
        end.
      end.
      else do:
        assign
          v-fact-qnty           = 0
          v-cost-sum-base       = 0
          v-cost-sum-rubl       = 0
          v-cost-VAT-base       = 0
          v-cost-VAT-rubl       = 0
          v-cost-SLT-base       = 0
          v-cost-SLT-rubl       = 0
          v-cost-road-tax-base  = 0
          v-cost-road-tax-rubl  = 0
          v-cost-excise-base    = 0
          v-cost-excise-rubl    = 0
          v-cost-transport-base = 0
          v-cost-transport-rubl = 0
          v-cost-other-base     = 0
          v-cost-other-rubl     = 0
          v-cost-discnt-base    = 0
          v-cost-discnt-rubl    = 0

          v-crsa-sum-base       = 0
          v-crsa-sum-rubl       = 0
          v-crsa-VAT-base       = 0
          v-crsa-VAT-rubl       = 0
          v-crsa-SLT-base       = 0
          v-crsa-SLT-rubl       = 0
          v-crsa-road-tax-base  = 0
          v-crsa-road-tax-rubl  = 0
          v-crsa-excise-base    = 0
          v-crsa-excise-rubl    = 0
          v-crsa-transport-base = 0
          v-crsa-transport-rubl = 0
          v-crsa-other-base     = 0
          v-crsa-other-rubl     = 0
          v-crsa-discnt-base    = 0
          v-crsa-discnt-rubl    = 0

          v-sale-sum-base       = 0
          v-sale-sum-rubl       = 0
          v-sale-VAT-base       = 0
          v-sale-VAT-rubl       = 0
          v-sale-SLT-base       = 0
          v-sale-SLT-rubl       = 0
          v-sale-road-tax-base  = 0
          v-sale-road-tax-rubl  = 0
          v-sale-excise-base    = 0
          v-sale-excise-rubl    = 0
          v-sale-transport-base = 0
          v-sale-transport-rubl = 0
          v-sale-other-base     = 0
          v-sale-other-rubl     = 0
          v-sale-discnt-base    = 0
          v-sale-discnt-rubl    = 0
        .
      end.

      if buf_temp-aht-ot-day.temp-sum-type <> {&aht-service}
      then do:
        assign
          v-fact-qnty           = v-fact-qnty           - buf_temp-aht-ot-day.temp-fact-qnty

          v-cost-sum-base       = v-cost-sum-base       - buf_temp-aht-ot-day.temp-cost-sum-base
          v-cost-sum-rubl       = v-cost-sum-rubl       - buf_temp-aht-ot-day.temp-cost-sum-rubl
          v-cost-VAT-base       = v-cost-VAT-base       - buf_temp-aht-ot-day.temp-cost-VAT-base
          v-cost-VAT-rubl       = v-cost-VAT-rubl       - buf_temp-aht-ot-day.temp-cost-VAT-rubl
          v-cost-SLT-base       = v-cost-SLT-base       - buf_temp-aht-ot-day.temp-cost-SLT-base
          v-cost-SLT-rubl       = v-cost-SLT-rubl       - buf_temp-aht-ot-day.temp-cost-SLT-rubl
          v-cost-road-tax-base  = v-cost-road-tax-base  - buf_temp-aht-ot-day.temp-cost-road-tax-base
          v-cost-road-tax-rubl  = v-cost-road-tax-rubl  - buf_temp-aht-ot-day.temp-cost-road-tax-rubl
          v-cost-excise-base    = v-cost-excise-base    - buf_temp-aht-ot-day.temp-cost-excise-base
          v-cost-excise-rubl    = v-cost-excise-rubl    - buf_temp-aht-ot-day.temp-cost-excise-rubl
          v-cost-transport-base = v-cost-transport-base - buf_temp-aht-ot-day.temp-cost-transport-base
          v-cost-transport-rubl = v-cost-transport-rubl - buf_temp-aht-ot-day.temp-cost-transport-rubl
          v-cost-other-base     = v-cost-other-base     - buf_temp-aht-ot-day.temp-cost-other-base
          v-cost-other-rubl     = v-cost-other-rubl     - buf_temp-aht-ot-day.temp-cost-other-rubl
          v-cost-discnt-base    = v-cost-discnt-base    - buf_temp-aht-ot-day.temp-cost-discnt-base
          v-cost-discnt-rubl    = v-cost-discnt-rubl    - buf_temp-aht-ot-day.temp-cost-discnt-rubl

          v-crsa-sum-base       = v-crsa-sum-base       - buf_temp-aht-ot-day.temp-crsa-sum-base
          v-crsa-sum-rubl       = v-crsa-sum-rubl       - buf_temp-aht-ot-day.temp-crsa-sum-rubl
          v-crsa-VAT-base       = v-crsa-VAT-base       - buf_temp-aht-ot-day.temp-crsa-VAT-base
          v-crsa-VAT-rubl       = v-crsa-VAT-rubl       - buf_temp-aht-ot-day.temp-crsa-VAT-rubl
          v-crsa-SLT-base       = v-crsa-SLT-base       - buf_temp-aht-ot-day.temp-crsa-SLT-base
          v-crsa-SLT-rubl       = v-crsa-SLT-rubl       - buf_temp-aht-ot-day.temp-crsa-SLT-rubl
          v-crsa-road-tax-base  = v-crsa-road-tax-base  - buf_temp-aht-ot-day.temp-crsa-road-tax-base
          v-crsa-road-tax-rubl  = v-crsa-road-tax-rubl  - buf_temp-aht-ot-day.temp-crsa-road-tax-rubl
          v-crsa-excise-base    = v-crsa-excise-base    - buf_temp-aht-ot-day.temp-crsa-excise-base
          v-crsa-excise-rubl    = v-crsa-excise-rubl    - buf_temp-aht-ot-day.temp-crsa-excise-rubl
          v-crsa-transport-base = v-crsa-transport-base - buf_temp-aht-ot-day.temp-crsa-transport-base
          v-crsa-transport-rubl = v-crsa-transport-rubl - buf_temp-aht-ot-day.temp-crsa-transport-rubl
          v-crsa-other-base     = v-crsa-other-base     - buf_temp-aht-ot-day.temp-crsa-other-base
          v-crsa-other-rubl     = v-crsa-other-rubl     - buf_temp-aht-ot-day.temp-crsa-other-rubl
          v-crsa-discnt-base    = v-crsa-discnt-base    - buf_temp-aht-ot-day.temp-crsa-discnt-base
          v-crsa-discnt-rubl    = v-crsa-discnt-rubl    - buf_temp-aht-ot-day.temp-crsa-discnt-rubl
        .
        if length(buf_temp-aht-ot-day.temp-sum-type) > 1
        then do:
          assign
            v-sale-sum-base       = v-sale-sum-base       - buf_temp-aht-ot-day.temp-sale-sum-base
            v-sale-sum-rubl       = v-sale-sum-rubl       - buf_temp-aht-ot-day.temp-sale-sum-rubl
            v-sale-VAT-base       = v-sale-VAT-base       - buf_temp-aht-ot-day.temp-sale-VAT-base
            v-sale-VAT-rubl       = v-sale-VAT-rubl       - buf_temp-aht-ot-day.temp-sale-VAT-rubl
            v-sale-SLT-base       = v-sale-SLT-base       - buf_temp-aht-ot-day.temp-sale-SLT-base
            v-sale-SLT-rubl       = v-sale-SLT-rubl       - buf_temp-aht-ot-day.temp-sale-SLT-rubl
            v-sale-road-tax-base  = v-sale-road-tax-base  - buf_temp-aht-ot-day.temp-sale-road-tax-base
            v-sale-road-tax-rubl  = v-sale-road-tax-rubl  - buf_temp-aht-ot-day.temp-sale-road-tax-rubl
            v-sale-excise-base    = v-sale-excise-base    - buf_temp-aht-ot-day.temp-sale-excise-base
            v-sale-excise-rubl    = v-sale-excise-rubl    - buf_temp-aht-ot-day.temp-sale-excise-rubl
            v-sale-transport-base = v-sale-transport-base - buf_temp-aht-ot-day.temp-sale-transport-base
            v-sale-transport-rubl = v-sale-transport-rubl - buf_temp-aht-ot-day.temp-sale-transport-rubl
            v-sale-other-base     = v-sale-other-base     - buf_temp-aht-ot-day.temp-sale-other-base
            v-sale-other-rubl     = v-sale-other-rubl     - buf_temp-aht-ot-day.temp-sale-other-rubl
            v-sale-discnt-base    = v-sale-discnt-base    - buf_temp-aht-ot-day.temp-sale-discnt-base
            v-sale-discnt-rubl    = v-sale-discnt-rubl    - buf_temp-aht-ot-day.temp-sale-discnt-rubl
          .
        end.
      end.

      /* в течение дня были операции */
      /* должен быть остаток на конец дня */
      find first buf_aht-stk-line no-lock
        where buf_aht-stk-line.obj-type   = p-obj-type
          and buf_aht-stk-line.obj-code   = p-obj-code
          and buf_aht-stk-line.gds-code   = buf_temp-aht-ot-day.temp-gds-code
          and buf_aht-stk-line.sum-type   = buf_temp-aht-ot-day.temp-sum-type
          and buf_aht-stk-line.fact-order = p-fact-order-end-day
        use-index category
        no-error .
      if available buf_aht-stk-line
      then do:
        if buf_temp-aht-ot-day.temp-sum-type <> {&aht-service}
        then do:
          assign
            v-fact-qnty           = v-fact-qnty           + buf_aht-stk-line.fact-qnty

            v-cost-sum-base       = v-cost-sum-base       + buf_aht-stk-line.cost-sum-base
            v-cost-sum-rubl       = v-cost-sum-rubl       + buf_aht-stk-line.cost-sum-rubl
            v-cost-VAT-base       = v-cost-VAT-base       + buf_aht-stk-line.cost-VAT-base
            v-cost-VAT-rubl       = v-cost-VAT-rubl       + buf_aht-stk-line.cost-VAT-rubl
            v-cost-SLT-base       = v-cost-SLT-base       + buf_aht-stk-line.cost-SLT-base
            v-cost-SLT-rubl       = v-cost-SLT-rubl       + buf_aht-stk-line.cost-SLT-rubl
            v-cost-road-tax-base  = v-cost-road-tax-base  + buf_aht-stk-line.cost-road-tax-base
            v-cost-road-tax-rubl  = v-cost-road-tax-rubl  + buf_aht-stk-line.cost-road-tax-rubl
            v-cost-excise-base    = v-cost-excise-base    + buf_aht-stk-line.cost-excise-base
            v-cost-excise-rubl    = v-cost-excise-rubl    + buf_aht-stk-line.cost-excise-rubl
            v-cost-transport-base = v-cost-transport-base + buf_aht-stk-line.cost-transport-base
            v-cost-transport-rubl = v-cost-transport-rubl + buf_aht-stk-line.cost-transport-rubl
            v-cost-other-base     = v-cost-other-base     + buf_aht-stk-line.cost-other-base
            v-cost-other-rubl     = v-cost-other-rubl     + buf_aht-stk-line.cost-other-rubl
            v-cost-discnt-base    = v-cost-discnt-base    + buf_aht-stk-line.cost-discnt-base
            v-cost-discnt-rubl    = v-cost-discnt-rubl    + buf_aht-stk-line.cost-discnt-rubl

            v-crsa-sum-base       = v-crsa-sum-base       + buf_aht-stk-line.crsa-sum-base
            v-crsa-sum-rubl       = v-crsa-sum-rubl       + buf_aht-stk-line.crsa-sum-rubl
            v-crsa-VAT-base       = v-crsa-VAT-base       + buf_aht-stk-line.crsa-VAT-base
            v-crsa-VAT-rubl       = v-crsa-VAT-rubl       + buf_aht-stk-line.crsa-VAT-rubl
            v-crsa-SLT-base       = v-crsa-SLT-base       + buf_aht-stk-line.crsa-SLT-base
            v-crsa-SLT-rubl       = v-crsa-SLT-rubl       + buf_aht-stk-line.crsa-SLT-rubl
            v-crsa-road-tax-base  = v-crsa-road-tax-base  + buf_aht-stk-line.crsa-road-tax-base
            v-crsa-road-tax-rubl  = v-crsa-road-tax-rubl  + buf_aht-stk-line.crsa-road-tax-rubl
            v-crsa-excise-base    = v-crsa-excise-base    + buf_aht-stk-line.crsa-excise-base
            v-crsa-excise-rubl    = v-crsa-excise-rubl    + buf_aht-stk-line.crsa-excise-rubl
            v-crsa-transport-base = v-crsa-transport-base + buf_aht-stk-line.crsa-transport-base
            v-crsa-transport-rubl = v-crsa-transport-rubl + buf_aht-stk-line.crsa-transport-rubl
            v-crsa-other-base     = v-crsa-other-base     + buf_aht-stk-line.crsa-other-base
            v-crsa-other-rubl     = v-crsa-other-rubl     + buf_aht-stk-line.crsa-other-rubl
            v-crsa-discnt-base    = v-crsa-discnt-base    + buf_aht-stk-line.crsa-discnt-base
            v-crsa-discnt-rubl    = v-crsa-discnt-rubl    + buf_aht-stk-line.crsa-discnt-rubl

            v-sale-sum-base       = v-sale-sum-base       + buf_aht-stk-line.sale-sum-base
            v-sale-sum-rubl       = v-sale-sum-rubl       + buf_aht-stk-line.sale-sum-rubl
            v-sale-VAT-base       = v-sale-VAT-base       + buf_aht-stk-line.sale-VAT-base
            v-sale-VAT-rubl       = v-sale-VAT-rubl       + buf_aht-stk-line.sale-VAT-rubl
            v-sale-SLT-base       = v-sale-SLT-base       + buf_aht-stk-line.sale-SLT-base
            v-sale-SLT-rubl       = v-sale-SLT-rubl       + buf_aht-stk-line.sale-SLT-rubl
            v-sale-road-tax-base  = v-sale-road-tax-base  + buf_aht-stk-line.sale-road-tax-base
            v-sale-road-tax-rubl  = v-sale-road-tax-rubl  + buf_aht-stk-line.sale-road-tax-rubl
            v-sale-excise-base    = v-sale-excise-base    + buf_aht-stk-line.sale-excise-base
            v-sale-excise-rubl    = v-sale-excise-rubl    + buf_aht-stk-line.sale-excise-rubl
            v-sale-transport-base = v-sale-transport-base + buf_aht-stk-line.sale-transport-base
            v-sale-transport-rubl = v-sale-transport-rubl + buf_aht-stk-line.sale-transport-rubl
            v-sale-other-base     = v-sale-other-base     + buf_aht-stk-line.sale-other-base
            v-sale-other-rubl     = v-sale-other-rubl     + buf_aht-stk-line.sale-other-rubl
            v-sale-discnt-base    = v-sale-discnt-base    + buf_aht-stk-line.sale-discnt-base
            v-sale-discnt-rubl    = v-sale-discnt-rubl    + buf_aht-stk-line.sale-discnt-rubl
          .
        end.
      end.
      else do:
        /* должен быть остаток на конец дня, кроме */
        /* случая, когда его быть не должно */
        assign
          v-total-err = v-total-err + 1
        .

        run cur-time in this-procedure
          (output v-today
          ,output v-time
          ) .
        run update-last-date in this-procedure
          (input p-fact-date
          ) .

        output stream sout to value(v-log-err-file) append .
        export stream sout '***':u string(v-today, '99/99/9999':u) string(v-time, 'HH:MM:SS':u) .
        export stream sout "error-01: aht-stk-line not found" .
        export stream sout "obj-type"            p-obj-type                        .
        export stream sout "obj-code"            p-obj-code                        .
        export stream sout "fact-date"           p-fact-date                       .
        export stream sout "gds-code"            buf_temp-aht-ot-day.temp-gds-code .
        export stream sout "sum-type"            buf_temp-aht-ot-day.temp-sum-type .
        export stream sout "fact-order"          p-fact-order-end-day              .
        export stream sout "fact-qnty"           v-fact-qnty                       .
        export stream sout "cost-sum-base"       v-cost-sum-base                   .
        export stream sout "cost-sum-rubl"       v-cost-sum-rubl                   .
        export stream sout "cost-VAT-base"       v-cost-VAT-base                   .
        export stream sout "cost-VAT-rubl"       v-cost-VAT-rubl                   .
        export stream sout "cost-SLT-base"       v-cost-SLT-base                   .
        export stream sout "cost-SLT-rubl"       v-cost-SLT-rubl                   .
        export stream sout "cost-road-tax-base"  v-cost-road-tax-base              .
        export stream sout "cost-road-tax-rubl"  v-cost-road-tax-rubl              .
        export stream sout "cost-excise-base"    v-cost-excise-base                .
        export stream sout "cost-excise-rubl"    v-cost-excise-rubl                .
        export stream sout "cost-transport-base" v-cost-transport-base             .
        export stream sout "cost-transport-rubl" v-cost-transport-rubl             .
        export stream sout "cost-other-base"     v-cost-other-base                 .
        export stream sout "cost-other-rubl"     v-cost-other-rubl                 .
        export stream sout "cost-discnt-base"    v-cost-discnt-base                .
        export stream sout "cost-discnt-rubl"    v-cost-discnt-rubl                .
        export stream sout "crsa-sum-base"       v-crsa-sum-base                   .
        export stream sout "crsa-sum-rubl"       v-crsa-sum-rubl                   .
        export stream sout "crsa-VAT-base"       v-crsa-VAT-base                   .
        export stream sout "crsa-VAT-rubl"       v-crsa-VAT-rubl                   .
        export stream sout "crsa-SLT-base"       v-crsa-SLT-base                   .
        export stream sout "crsa-SLT-rubl"       v-crsa-SLT-rubl                   .
        export stream sout "crsa-road-tax-base"  v-crsa-road-tax-base              .
        export stream sout "crsa-road-tax-rubl"  v-crsa-road-tax-rubl              .
        export stream sout "crsa-excise-base"    v-crsa-excise-base                .
        export stream sout "crsa-excise-rubl"    v-crsa-excise-rubl                .
        export stream sout "crsa-transport-base" v-crsa-transport-base             .
        export stream sout "crsa-transport-rubl" v-crsa-transport-rubl             .
        export stream sout "crsa-other-base"     v-crsa-other-base                 .
        export stream sout "crsa-other-rubl"     v-crsa-other-rubl                 .
        export stream sout "crsa-discnt-base"    v-crsa-discnt-base                .
        export stream sout "crsa-discnt-rubl"    v-crsa-discnt-rubl                .
        export stream sout "sale-sum-base"       v-sale-sum-base                   .
        export stream sout "sale-sum-rubl"       v-sale-sum-rubl                   .
        export stream sout "sale-VAT-base"       v-sale-VAT-base                   .
        export stream sout "sale-VAT-rubl"       v-sale-VAT-rubl                   .
        export stream sout "sale-SLT-base"       v-sale-SLT-base                   .
        export stream sout "sale-SLT-rubl"       v-sale-SLT-rubl                   .
        export stream sout "sale-road-tax-base"  v-sale-road-tax-base              .
        export stream sout "sale-road-tax-rubl"  v-sale-road-tax-rubl              .
        export stream sout "sale-excise-base"    v-sale-excise-base                .
        export stream sout "sale-excise-rubl"    v-sale-excise-rubl                .
        export stream sout "sale-transport-base" v-sale-transport-base             .
        export stream sout "sale-transport-rubl" v-sale-transport-rubl             .
        export stream sout "sale-other-base"     v-sale-other-base                 .
        export stream sout "sale-other-rubl"     v-sale-other-rubl                 .
        export stream sout "sale-discnt-base"    v-sale-discnt-base                .
        export stream sout "sale-discnt-rubl"    v-sale-discnt-rubl                .
        output stream sout close .
      end.

      if v-fact-qnty           <> 0
      or v-cost-sum-base       <> 0
      or v-cost-sum-rubl       <> 0
      or v-cost-VAT-base       <> 0
      or v-cost-VAT-rubl       <> 0
      or v-cost-SLT-base       <> 0
      or v-cost-SLT-rubl       <> 0
      or v-cost-road-tax-base  <> 0
      or v-cost-road-tax-rubl  <> 0
      or v-cost-excise-base    <> 0
      or v-cost-excise-rubl    <> 0
      or v-cost-transport-base <> 0
      or v-cost-transport-rubl <> 0
      or v-cost-other-base     <> 0
      or v-cost-other-rubl     <> 0
      or v-cost-discnt-base    <> 0
      or v-cost-discnt-rubl    <> 0
      or v-crsa-sum-base       <> 0
      or v-crsa-sum-rubl       <> 0
      or v-crsa-VAT-base       <> 0
      or v-crsa-VAT-rubl       <> 0
      or v-crsa-SLT-base       <> 0
      or v-crsa-SLT-rubl       <> 0
      or v-crsa-road-tax-base  <> 0
      or v-crsa-road-tax-rubl  <> 0
      or v-crsa-excise-base    <> 0
      or v-crsa-excise-rubl    <> 0
      or v-crsa-transport-base <> 0
      or v-crsa-transport-rubl <> 0
      or v-crsa-other-base     <> 0
      or v-crsa-other-rubl     <> 0
      or v-crsa-discnt-base    <> 0
      or v-crsa-discnt-rubl    <> 0
      or v-sale-sum-base       <> 0
      or v-sale-sum-rubl       <> 0
      or v-sale-VAT-base       <> 0
      or v-sale-VAT-rubl       <> 0
      or v-sale-SLT-base       <> 0
      or v-sale-SLT-rubl       <> 0
      or v-sale-road-tax-base  <> 0
      or v-sale-road-tax-rubl  <> 0
      or v-sale-excise-base    <> 0
      or v-sale-excise-rubl    <> 0
      or v-sale-transport-base <> 0
      or v-sale-transport-rubl <> 0
      or v-sale-other-base     <> 0
      or v-sale-other-rubl     <> 0
      or v-sale-discnt-base    <> 0
      or v-sale-discnt-rubl    <> 0
      then do:
        assign
          v-total-err = v-total-err + 1
        .

        run cur-time in this-procedure
          (output v-today
          ,output v-time
          ) .
        run update-last-date in this-procedure
          (input p-fact-date
          ) .

        output stream sout to value(v-log-err-file) append .
        export stream sout '***':u string(v-today, '99/99/9999':u) string(v-time, 'HH:MM:SS':u) .
        export stream sout "error-02: aht-stk-line different quantity" .
        export stream sout "obj-type"            p-obj-type                        .
        export stream sout "obj-code"            p-obj-code                        .
        export stream sout "fact-date"           p-fact-date                       .
        export stream sout "gds-code"            buf_temp-aht-ot-day.temp-gds-code .
        export stream sout "sum-type"            buf_temp-aht-ot-day.temp-sum-type .
        export stream sout "fact-order"          p-fact-order-end-day              .
        export stream sout "fact-qnty"           v-fact-qnty                       .
        export stream sout "cost-sum-base"       v-cost-sum-base                   .
        export stream sout "cost-sum-rubl"       v-cost-sum-rubl                   .
        export stream sout "cost-VAT-base"       v-cost-VAT-base                   .
        export stream sout "cost-VAT-rubl"       v-cost-VAT-rubl                   .
        export stream sout "cost-SLT-base"       v-cost-SLT-base                   .
        export stream sout "cost-SLT-rubl"       v-cost-SLT-rubl                   .
        export stream sout "cost-road-tax-base"  v-cost-road-tax-base              .
        export stream sout "cost-road-tax-rubl"  v-cost-road-tax-rubl              .
        export stream sout "cost-excise-base"    v-cost-excise-base                .
        export stream sout "cost-excise-rubl"    v-cost-excise-rubl                .
        export stream sout "cost-transport-base" v-cost-transport-base             .
        export stream sout "cost-transport-rubl" v-cost-transport-rubl             .
        export stream sout "cost-other-base"     v-cost-other-base                 .
        export stream sout "cost-other-rubl"     v-cost-other-rubl                 .
        export stream sout "cost-discnt-base"    v-cost-discnt-base                .
        export stream sout "cost-discnt-rubl"    v-cost-discnt-rubl                .
        export stream sout "crsa-sum-base"       v-crsa-sum-base                   .
        export stream sout "crsa-sum-rubl"       v-crsa-sum-rubl                   .
        export stream sout "crsa-VAT-base"       v-crsa-VAT-base                   .
        export stream sout "crsa-VAT-rubl"       v-crsa-VAT-rubl                   .
        export stream sout "crsa-SLT-base"       v-crsa-SLT-base                   .
        export stream sout "crsa-SLT-rubl"       v-crsa-SLT-rubl                   .
        export stream sout "crsa-road-tax-base"  v-crsa-road-tax-base              .
        export stream sout "crsa-road-tax-rubl"  v-crsa-road-tax-rubl              .
        export stream sout "crsa-excise-base"    v-crsa-excise-base                .
        export stream sout "crsa-excise-rubl"    v-crsa-excise-rubl                .
        export stream sout "crsa-transport-base" v-crsa-transport-base             .
        export stream sout "crsa-transport-rubl" v-crsa-transport-rubl             .
        export stream sout "crsa-other-base"     v-crsa-other-base                 .
        export stream sout "crsa-other-rubl"     v-crsa-other-rubl                 .
        export stream sout "crsa-discnt-base"    v-crsa-discnt-base                .
        export stream sout "crsa-discnt-rubl"    v-crsa-discnt-rubl                .
        export stream sout "sale-sum-base"       v-sale-sum-base                   .
        export stream sout "sale-sum-rubl"       v-sale-sum-rubl                   .
        export stream sout "sale-VAT-base"       v-sale-VAT-base                   .
        export stream sout "sale-VAT-rubl"       v-sale-VAT-rubl                   .
        export stream sout "sale-SLT-base"       v-sale-SLT-base                   .
        export stream sout "sale-SLT-rubl"       v-sale-SLT-rubl                   .
        export stream sout "sale-road-tax-base"  v-sale-road-tax-base              .
        export stream sout "sale-road-tax-rubl"  v-sale-road-tax-rubl              .
        export stream sout "sale-excise-base"    v-sale-excise-base                .
        export stream sout "sale-excise-rubl"    v-sale-excise-rubl                .
        export stream sout "sale-transport-base" v-sale-transport-base             .
        export stream sout "sale-transport-rubl" v-sale-transport-rubl             .
        export stream sout "sale-other-base"     v-sale-other-base                 .
        export stream sout "sale-other-rubl"     v-sale-other-rubl                 .
        export stream sout "sale-discnt-base"    v-sale-discnt-base                .
        export stream sout "sale-discnt-rubl"    v-sale-discnt-rubl                .
        output stream sout close .
      end.
    end.
  end.

end procedure. /* validate-aht-ot-line-stk */


procedure clear-temp-aht-ot-day :

  define buffer buf_temp-aht-ot-day for temp-aht-ot-day .

  do
  on error undo, return error return-value
  :
    for each buf_temp-aht-ot-day
    on error undo, return error return-value
    :
      delete buf_temp-aht-ot-day .
    end.
  end.

end procedure. /* clear-temp-aht-ot-day */


procedure fill-temp-aht-ot-day :

  define input  parameter p-fact-date            as date      no-undo .
  define input  parameter p-fact-order-begin-day as decimal   no-undo .
  define input  parameter p-fact-order-end-day   as decimal   no-undo .

  define buffer buf_temp-aht-ot-day for temp-aht-ot-day .
  define buffer buf_aht-ot-line     for ub.aht-ot-line .

  do
  on error undo, return error return-value
  :

    for each buf_aht-ot-line no-lock
      where buf_aht-ot-line.obj-type   = p-obj-type
        and buf_aht-ot-line.obj-code   = p-obj-code
        and buf_aht-ot-line.fact-order > p-fact-order-begin-day
        and buf_aht-ot-line.fact-order < p-fact-order-end-day
    on error undo, return error return-value
    :
      /* оборот по документу */
      find first buf_temp-aht-ot-day
        where buf_temp-aht-ot-day.temp-gds-code  = buf_aht-ot-line.gds-code
          and buf_temp-aht-ot-day.temp-sum-type  = buf_aht-ot-line.sum-type
        no-error .
      if not available buf_temp-aht-ot-day
      then do:
        create buf_temp-aht-ot-day .
        assign
          buf_temp-aht-ot-day.temp-gds-code  = buf_aht-ot-line.gds-code
          buf_temp-aht-ot-day.temp-sum-type  = buf_aht-ot-line.sum-type
        .
      end.

      assign
        buf_temp-aht-ot-day.temp-fact-qnty           = buf_temp-aht-ot-day.temp-fact-qnty
                                                     + buf_aht-ot-line.fact-qnty

        buf_temp-aht-ot-day.temp-cost-sum-base       = buf_temp-aht-ot-day.temp-cost-sum-base
                                                     + buf_aht-ot-line.cost-sum-base
        buf_temp-aht-ot-day.temp-cost-sum-rubl       = buf_temp-aht-ot-day.temp-cost-sum-rubl
                                                     + buf_aht-ot-line.cost-sum-rubl
        buf_temp-aht-ot-day.temp-cost-VAT-base       = buf_temp-aht-ot-day.temp-cost-VAT-base
                                                     + buf_aht-ot-line.cost-VAT-base
        buf_temp-aht-ot-day.temp-cost-VAT-rubl       = buf_temp-aht-ot-day.temp-cost-VAT-rubl
                                                     + buf_aht-ot-line.cost-VAT-rubl
        buf_temp-aht-ot-day.temp-cost-SLT-base       = buf_temp-aht-ot-day.temp-cost-SLT-base
                                                     + buf_aht-ot-line.cost-SLT-base
        buf_temp-aht-ot-day.temp-cost-SLT-rubl       = buf_temp-aht-ot-day.temp-cost-SLT-rubl
                                                     + buf_aht-ot-line.cost-SLT-rubl
        buf_temp-aht-ot-day.temp-cost-road-tax-base  = buf_temp-aht-ot-day.temp-cost-road-tax-base
                                                     + buf_aht-ot-line.cost-road-tax-base
        buf_temp-aht-ot-day.temp-cost-road-tax-rubl  = buf_temp-aht-ot-day.temp-cost-road-tax-rubl
                                                     + buf_aht-ot-line.cost-road-tax-rubl
        buf_temp-aht-ot-day.temp-cost-excise-base    = buf_temp-aht-ot-day.temp-cost-excise-base
                                                     + buf_aht-ot-line.cost-excise-base
        buf_temp-aht-ot-day.temp-cost-excise-rubl    = buf_temp-aht-ot-day.temp-cost-excise-rubl
                                                     + buf_aht-ot-line.cost-excise-rubl
        buf_temp-aht-ot-day.temp-cost-transport-base = buf_temp-aht-ot-day.temp-cost-transport-base
                                                     + buf_aht-ot-line.cost-transport-base
        buf_temp-aht-ot-day.temp-cost-transport-rubl = buf_temp-aht-ot-day.temp-cost-transport-rubl
                                                     + buf_aht-ot-line.cost-transport-rubl
        buf_temp-aht-ot-day.temp-cost-other-base     = buf_temp-aht-ot-day.temp-cost-other-base
                                                     + buf_aht-ot-line.cost-other-base
        buf_temp-aht-ot-day.temp-cost-other-rubl     = buf_temp-aht-ot-day.temp-cost-other-rubl
                                                     + buf_aht-ot-line.cost-other-rubl
        buf_temp-aht-ot-day.temp-cost-discnt-base    = buf_temp-aht-ot-day.temp-cost-discnt-base
                                                     + buf_aht-ot-line.cost-discnt-base
        buf_temp-aht-ot-day.temp-cost-discnt-rubl    = buf_temp-aht-ot-day.temp-cost-discnt-rubl
                                                     + buf_aht-ot-line.cost-discnt-rubl

        buf_temp-aht-ot-day.temp-crsa-sum-base       = buf_temp-aht-ot-day.temp-crsa-sum-base
                                                     + buf_aht-ot-line.crsa-sum-base
        buf_temp-aht-ot-day.temp-crsa-sum-rubl       = buf_temp-aht-ot-day.temp-crsa-sum-rubl
                                                     + buf_aht-ot-line.crsa-sum-rubl
        buf_temp-aht-ot-day.temp-crsa-VAT-base       = buf_temp-aht-ot-day.temp-crsa-VAT-base
                                                     + buf_aht-ot-line.crsa-VAT-base
        buf_temp-aht-ot-day.temp-crsa-VAT-rubl       = buf_temp-aht-ot-day.temp-crsa-VAT-rubl
                                                     + buf_aht-ot-line.crsa-VAT-rubl
        buf_temp-aht-ot-day.temp-crsa-SLT-base       = buf_temp-aht-ot-day.temp-crsa-SLT-base
                                                     + buf_aht-ot-line.crsa-SLT-base
        buf_temp-aht-ot-day.temp-crsa-SLT-rubl       = buf_temp-aht-ot-day.temp-crsa-SLT-rubl
                                                     + buf_aht-ot-line.crsa-SLT-rubl
        buf_temp-aht-ot-day.temp-crsa-road-tax-base  = buf_temp-aht-ot-day.temp-crsa-road-tax-base
                                                     + buf_aht-ot-line.crsa-road-tax-base
        buf_temp-aht-ot-day.temp-crsa-road-tax-rubl  = buf_temp-aht-ot-day.temp-crsa-road-tax-rubl
                                                     + buf_aht-ot-line.crsa-road-tax-rubl
        buf_temp-aht-ot-day.temp-crsa-excise-base    = buf_temp-aht-ot-day.temp-crsa-excise-base
                                                     + buf_aht-ot-line.crsa-excise-base
        buf_temp-aht-ot-day.temp-crsa-excise-rubl    = buf_temp-aht-ot-day.temp-crsa-excise-rubl
                                                     + buf_aht-ot-line.crsa-excise-rubl
        buf_temp-aht-ot-day.temp-crsa-transport-base = buf_temp-aht-ot-day.temp-crsa-transport-base
                                                     + buf_aht-ot-line.crsa-transport-base
        buf_temp-aht-ot-day.temp-crsa-transport-rubl = buf_temp-aht-ot-day.temp-crsa-transport-rubl
                                                     + buf_aht-ot-line.crsa-transport-rubl
        buf_temp-aht-ot-day.temp-crsa-other-base     = buf_temp-aht-ot-day.temp-crsa-other-base
                                                     + buf_aht-ot-line.crsa-other-base
        buf_temp-aht-ot-day.temp-crsa-other-rubl     = buf_temp-aht-ot-day.temp-crsa-other-rubl
                                                     + buf_aht-ot-line.crsa-other-rubl
        buf_temp-aht-ot-day.temp-crsa-discnt-base    = buf_temp-aht-ot-day.temp-crsa-discnt-base
                                                     + buf_aht-ot-line.crsa-discnt-base
        buf_temp-aht-ot-day.temp-crsa-discnt-rubl    = buf_temp-aht-ot-day.temp-crsa-discnt-rubl
                                                     + buf_aht-ot-line.crsa-discnt-rubl

        buf_temp-aht-ot-day.temp-sale-sum-base       = buf_temp-aht-ot-day.temp-sale-sum-base
                                                     + buf_aht-ot-line.sale-sum-base
        buf_temp-aht-ot-day.temp-sale-sum-rubl       = buf_temp-aht-ot-day.temp-sale-sum-rubl
                                                     + buf_aht-ot-line.sale-sum-rubl
        buf_temp-aht-ot-day.temp-sale-VAT-base       = buf_temp-aht-ot-day.temp-sale-VAT-base
                                                     + buf_aht-ot-line.sale-VAT-base
        buf_temp-aht-ot-day.temp-sale-VAT-rubl       = buf_temp-aht-ot-day.temp-sale-VAT-rubl
                                                     + buf_aht-ot-line.sale-VAT-rubl
        buf_temp-aht-ot-day.temp-sale-SLT-base       = buf_temp-aht-ot-day.temp-sale-SLT-base
                                                     + buf_aht-ot-line.sale-SLT-base
        buf_temp-aht-ot-day.temp-sale-SLT-rubl       = buf_temp-aht-ot-day.temp-sale-SLT-rubl
                                                     + buf_aht-ot-line.sale-SLT-rubl
        buf_temp-aht-ot-day.temp-sale-road-tax-base  = buf_temp-aht-ot-day.temp-sale-road-tax-base
                                                     + buf_aht-ot-line.sale-road-tax-base
        buf_temp-aht-ot-day.temp-sale-road-tax-rubl  = buf_temp-aht-ot-day.temp-sale-road-tax-rubl
                                                     + buf_aht-ot-line.sale-road-tax-rubl
        buf_temp-aht-ot-day.temp-sale-excise-base    = buf_temp-aht-ot-day.temp-sale-excise-base
                                                     + buf_aht-ot-line.sale-excise-base
        buf_temp-aht-ot-day.temp-sale-excise-rubl    = buf_temp-aht-ot-day.temp-sale-excise-rubl
                                                     + buf_aht-ot-line.sale-excise-rubl
        buf_temp-aht-ot-day.temp-sale-transport-base = buf_temp-aht-ot-day.temp-sale-transport-base
                                                     + buf_aht-ot-line.sale-transport-base
        buf_temp-aht-ot-day.temp-sale-transport-rubl = buf_temp-aht-ot-day.temp-sale-transport-rubl
                                                     + buf_aht-ot-line.sale-transport-rubl
        buf_temp-aht-ot-day.temp-sale-other-base     = buf_temp-aht-ot-day.temp-sale-other-base
                                                     + buf_aht-ot-line.sale-other-base
        buf_temp-aht-ot-day.temp-sale-other-rubl     = buf_temp-aht-ot-day.temp-sale-other-rubl
                                                     + buf_aht-ot-line.sale-other-rubl
        buf_temp-aht-ot-day.temp-sale-discnt-base    = buf_temp-aht-ot-day.temp-sale-discnt-base
                                                     + buf_aht-ot-line.sale-discnt-base
        buf_temp-aht-ot-day.temp-sale-discnt-rubl    = buf_temp-aht-ot-day.temp-sale-discnt-rubl
                                                     + buf_aht-ot-line.sale-discnt-rubl
      .

      /* оборот для накопительного складского архива */
      find first buf_temp-aht-ot-day
        where buf_temp-aht-ot-day.temp-gds-code  = buf_aht-ot-line.gds-code
          and buf_temp-aht-ot-day.temp-sum-type  = buf_aht-ot-line.sum-type + buf_aht-ot-line.ext-doc-type
        no-error .
      if not available buf_temp-aht-ot-day
      then do:
        create buf_temp-aht-ot-day .
        assign
          buf_temp-aht-ot-day.temp-gds-code  = buf_aht-ot-line.gds-code
          buf_temp-aht-ot-day.temp-sum-type  = buf_aht-ot-line.sum-type + buf_aht-ot-line.ext-doc-type
        .
      end.

      assign
        buf_temp-aht-ot-day.temp-fact-qnty           = buf_temp-aht-ot-day.temp-fact-qnty
                                                     + buf_aht-ot-line.fact-qnty
        buf_temp-aht-ot-day.temp-cost-sum-base       = buf_temp-aht-ot-day.temp-cost-sum-base
                                                     + buf_aht-ot-line.cost-sum-base
        buf_temp-aht-ot-day.temp-cost-sum-rubl       = buf_temp-aht-ot-day.temp-cost-sum-rubl
                                                     + buf_aht-ot-line.cost-sum-rubl
        buf_temp-aht-ot-day.temp-cost-VAT-base       = buf_temp-aht-ot-day.temp-cost-VAT-base
                                                     + buf_aht-ot-line.cost-VAT-base
        buf_temp-aht-ot-day.temp-cost-VAT-rubl       = buf_temp-aht-ot-day.temp-cost-VAT-rubl
                                                     + buf_aht-ot-line.cost-VAT-rubl
        buf_temp-aht-ot-day.temp-cost-SLT-base       = buf_temp-aht-ot-day.temp-cost-SLT-base
                                                     + buf_aht-ot-line.cost-SLT-base
        buf_temp-aht-ot-day.temp-cost-SLT-rubl       = buf_temp-aht-ot-day.temp-cost-SLT-rubl
                                                     + buf_aht-ot-line.cost-SLT-rubl
        buf_temp-aht-ot-day.temp-cost-road-tax-base  = buf_temp-aht-ot-day.temp-cost-road-tax-base
                                                     + buf_aht-ot-line.cost-road-tax-base
        buf_temp-aht-ot-day.temp-cost-road-tax-rubl  = buf_temp-aht-ot-day.temp-cost-road-tax-rubl
                                                     + buf_aht-ot-line.cost-road-tax-rubl
        buf_temp-aht-ot-day.temp-cost-excise-base    = buf_temp-aht-ot-day.temp-cost-excise-base
                                                     + buf_aht-ot-line.cost-excise-base
        buf_temp-aht-ot-day.temp-cost-excise-rubl    = buf_temp-aht-ot-day.temp-cost-excise-rubl
                                                     + buf_aht-ot-line.cost-excise-rubl
        buf_temp-aht-ot-day.temp-cost-transport-base = buf_temp-aht-ot-day.temp-cost-transport-base
                                                     + buf_aht-ot-line.cost-transport-base
        buf_temp-aht-ot-day.temp-cost-transport-rubl = buf_temp-aht-ot-day.temp-cost-transport-rubl
                                                     + buf_aht-ot-line.cost-transport-rubl
        buf_temp-aht-ot-day.temp-cost-other-base     = buf_temp-aht-ot-day.temp-cost-other-base
                                                     + buf_aht-ot-line.cost-other-base
        buf_temp-aht-ot-day.temp-cost-other-rubl     = buf_temp-aht-ot-day.temp-cost-other-rubl
                                                     + buf_aht-ot-line.cost-other-rubl
        buf_temp-aht-ot-day.temp-cost-discnt-base    = buf_temp-aht-ot-day.temp-cost-discnt-base
                                                     + buf_aht-ot-line.cost-discnt-base
        buf_temp-aht-ot-day.temp-cost-discnt-rubl    = buf_temp-aht-ot-day.temp-cost-discnt-rubl
                                                     + buf_aht-ot-line.cost-discnt-rubl

        buf_temp-aht-ot-day.temp-crsa-sum-base       = buf_temp-aht-ot-day.temp-crsa-sum-base
                                                     + buf_aht-ot-line.crsa-sum-base
        buf_temp-aht-ot-day.temp-crsa-sum-rubl       = buf_temp-aht-ot-day.temp-crsa-sum-rubl
                                                     + buf_aht-ot-line.crsa-sum-rubl
        buf_temp-aht-ot-day.temp-crsa-VAT-base       = buf_temp-aht-ot-day.temp-crsa-VAT-base
                                                     + buf_aht-ot-line.crsa-VAT-base
        buf_temp-aht-ot-day.temp-crsa-VAT-rubl       = buf_temp-aht-ot-day.temp-crsa-VAT-rubl
                                                     + buf_aht-ot-line.crsa-VAT-rubl
        buf_temp-aht-ot-day.temp-crsa-SLT-base       = buf_temp-aht-ot-day.temp-crsa-SLT-base
                                                     + buf_aht-ot-line.crsa-SLT-base
        buf_temp-aht-ot-day.temp-crsa-SLT-rubl       = buf_temp-aht-ot-day.temp-crsa-SLT-rubl
                                                     + buf_aht-ot-line.crsa-SLT-rubl
        buf_temp-aht-ot-day.temp-crsa-road-tax-base  = buf_temp-aht-ot-day.temp-crsa-road-tax-base
                                                     + buf_aht-ot-line.crsa-road-tax-base
        buf_temp-aht-ot-day.temp-crsa-road-tax-rubl  = buf_temp-aht-ot-day.temp-crsa-road-tax-rubl
                                                     + buf_aht-ot-line.crsa-road-tax-rubl
        buf_temp-aht-ot-day.temp-crsa-excise-base    = buf_temp-aht-ot-day.temp-crsa-excise-base
                                                     + buf_aht-ot-line.crsa-excise-base
        buf_temp-aht-ot-day.temp-crsa-excise-rubl    = buf_temp-aht-ot-day.temp-crsa-excise-rubl
                                                     + buf_aht-ot-line.crsa-excise-rubl
        buf_temp-aht-ot-day.temp-crsa-transport-base = buf_temp-aht-ot-day.temp-crsa-transport-base
                                                     + buf_aht-ot-line.crsa-transport-base
        buf_temp-aht-ot-day.temp-crsa-transport-rubl = buf_temp-aht-ot-day.temp-crsa-transport-rubl
                                                     + buf_aht-ot-line.crsa-transport-rubl
        buf_temp-aht-ot-day.temp-crsa-other-base     = buf_temp-aht-ot-day.temp-crsa-other-base
                                                     + buf_aht-ot-line.crsa-other-base
        buf_temp-aht-ot-day.temp-crsa-other-rubl     = buf_temp-aht-ot-day.temp-crsa-other-rubl
                                                     + buf_aht-ot-line.crsa-other-rubl
        buf_temp-aht-ot-day.temp-crsa-discnt-base    = buf_temp-aht-ot-day.temp-crsa-discnt-base
                                                     + buf_aht-ot-line.crsa-discnt-base
        buf_temp-aht-ot-day.temp-crsa-discnt-rubl    = buf_temp-aht-ot-day.temp-crsa-discnt-rubl
                                                     + buf_aht-ot-line.crsa-discnt-rubl

        buf_temp-aht-ot-day.temp-sale-sum-base       = buf_temp-aht-ot-day.temp-sale-sum-base
                                                     + buf_aht-ot-line.sale-sum-base
        buf_temp-aht-ot-day.temp-sale-sum-rubl       = buf_temp-aht-ot-day.temp-sale-sum-rubl
                                                     + buf_aht-ot-line.sale-sum-rubl
        buf_temp-aht-ot-day.temp-sale-VAT-base       = buf_temp-aht-ot-day.temp-sale-VAT-base
                                                     + buf_aht-ot-line.sale-VAT-base
        buf_temp-aht-ot-day.temp-sale-VAT-rubl       = buf_temp-aht-ot-day.temp-sale-VAT-rubl
                                                     + buf_aht-ot-line.sale-VAT-rubl
        buf_temp-aht-ot-day.temp-sale-SLT-base       = buf_temp-aht-ot-day.temp-sale-SLT-base
                                                     + buf_aht-ot-line.sale-SLT-base
        buf_temp-aht-ot-day.temp-sale-SLT-rubl       = buf_temp-aht-ot-day.temp-sale-SLT-rubl
                                                     + buf_aht-ot-line.sale-SLT-rubl
        buf_temp-aht-ot-day.temp-sale-road-tax-base  = buf_temp-aht-ot-day.temp-sale-road-tax-base
                                                     + buf_aht-ot-line.sale-road-tax-base
        buf_temp-aht-ot-day.temp-sale-road-tax-rubl  = buf_temp-aht-ot-day.temp-sale-road-tax-rubl
                                                     + buf_aht-ot-line.sale-road-tax-rubl
        buf_temp-aht-ot-day.temp-sale-excise-base    = buf_temp-aht-ot-day.temp-sale-excise-base
                                                     + buf_aht-ot-line.sale-excise-base
        buf_temp-aht-ot-day.temp-sale-excise-rubl    = buf_temp-aht-ot-day.temp-sale-excise-rubl
                                                     + buf_aht-ot-line.sale-excise-rubl
        buf_temp-aht-ot-day.temp-sale-transport-base = buf_temp-aht-ot-day.temp-sale-transport-base
                                                     + buf_aht-ot-line.sale-transport-base
        buf_temp-aht-ot-day.temp-sale-transport-rubl = buf_temp-aht-ot-day.temp-sale-transport-rubl
                                                     + buf_aht-ot-line.sale-transport-rubl
        buf_temp-aht-ot-day.temp-sale-other-base     = buf_temp-aht-ot-day.temp-sale-other-base
                                                     + buf_aht-ot-line.sale-other-base
        buf_temp-aht-ot-day.temp-sale-other-rubl     = buf_temp-aht-ot-day.temp-sale-other-rubl
                                                     + buf_aht-ot-line.sale-other-rubl
        buf_temp-aht-ot-day.temp-sale-discnt-base    = buf_temp-aht-ot-day.temp-sale-discnt-base
                                                     + buf_aht-ot-line.sale-discnt-base
        buf_temp-aht-ot-day.temp-sale-discnt-rubl    = buf_temp-aht-ot-day.temp-sale-discnt-rubl
                                                     + buf_aht-ot-line.sale-discnt-rubl
      .
    end.
  end.

end procedure. /* fill-temp-aht-ot-day */


procedure validate-aht-stk-line :

  define input  parameter p-fact-date            as date      no-undo .
  define input  parameter p-fact-order-begin-day as decimal   no-undo .
  define input  parameter p-fact-order-end-day   as decimal   no-undo .

  define variable v-fact-qnty           as decimal   no-undo .
  define variable v-cost-sum-base       as decimal   no-undo .
  define variable v-cost-sum-rubl       as decimal   no-undo .
  define variable v-cost-VAT-base       as decimal   no-undo .
  define variable v-cost-VAT-rubl       as decimal   no-undo .
  define variable v-cost-SLT-base       as decimal   no-undo .
  define variable v-cost-SLT-rubl       as decimal   no-undo .
  define variable v-cost-road-tax-base  as decimal   no-undo .
  define variable v-cost-road-tax-rubl  as decimal   no-undo .
  define variable v-cost-excise-base    as decimal   no-undo .
  define variable v-cost-excise-rubl    as decimal   no-undo .
  define variable v-cost-transport-base as decimal   no-undo .
  define variable v-cost-transport-rubl as decimal   no-undo .
  define variable v-cost-other-base     as decimal   no-undo .
  define variable v-cost-other-rubl     as decimal   no-undo .
  define variable v-cost-discnt-base    as decimal   no-undo .
  define variable v-cost-discnt-rubl    as decimal   no-undo .
  define variable v-crsa-sum-base       as decimal   no-undo .
  define variable v-crsa-sum-rubl       as decimal   no-undo .
  define variable v-crsa-VAT-base       as decimal   no-undo .
  define variable v-crsa-VAT-rubl       as decimal   no-undo .
  define variable v-crsa-SLT-base       as decimal   no-undo .
  define variable v-crsa-SLT-rubl       as decimal   no-undo .
  define variable v-crsa-road-tax-base  as decimal   no-undo .
  define variable v-crsa-road-tax-rubl  as decimal   no-undo .
  define variable v-crsa-excise-base    as decimal   no-undo .
  define variable v-crsa-excise-rubl    as decimal   no-undo .
  define variable v-crsa-transport-base as decimal   no-undo .
  define variable v-crsa-transport-rubl as decimal   no-undo .
  define variable v-crsa-other-base     as decimal   no-undo .
  define variable v-crsa-other-rubl     as decimal   no-undo .
  define variable v-crsa-discnt-base    as decimal   no-undo .
  define variable v-crsa-discnt-rubl    as decimal   no-undo .
  define variable v-sale-sum-base       as decimal   no-undo .
  define variable v-sale-sum-rubl       as decimal   no-undo .
  define variable v-sale-VAT-base       as decimal   no-undo .
  define variable v-sale-VAT-rubl       as decimal   no-undo .
  define variable v-sale-SLT-base       as decimal   no-undo .
  define variable v-sale-SLT-rubl       as decimal   no-undo .
  define variable v-sale-road-tax-base  as decimal   no-undo .
  define variable v-sale-road-tax-rubl  as decimal   no-undo .
  define variable v-sale-excise-base    as decimal   no-undo .
  define variable v-sale-excise-rubl    as decimal   no-undo .
  define variable v-sale-transport-base as decimal   no-undo .
  define variable v-sale-transport-rubl as decimal   no-undo .
  define variable v-sale-other-base     as decimal   no-undo .
  define variable v-sale-other-rubl     as decimal   no-undo .
  define variable v-sale-discnt-base    as decimal   no-undo .
  define variable v-sale-discnt-rubl    as decimal   no-undo .

  define buffer buf_aht-stk-line for ub.aht-stk-line .
  define buffer buf_prev_aht-stk-line for ub.aht-stk-line .
  define buffer buf_temp-aht-ot-day for temp-aht-ot-day .

  do
  on error undo, return error return-value
  :
    for each buf_aht-stk-line no-lock
      where buf_aht-stk-line.obj-type   = p-obj-type
        and buf_aht-stk-line.obj-code   = p-obj-code
        and buf_aht-stk-line.fact-order = p-fact-order-end-day
    on error undo, return error return-value
    :
      assign
        v-fact-qnty           = buf_aht-stk-line.fact-qnty
        v-cost-sum-base       = buf_aht-stk-line.cost-sum-base
        v-cost-sum-rubl       = buf_aht-stk-line.cost-sum-rubl
        v-cost-VAT-base       = buf_aht-stk-line.cost-VAT-base
        v-cost-VAT-rubl       = buf_aht-stk-line.cost-VAT-rubl
        v-cost-SLT-base       = buf_aht-stk-line.cost-SLT-base
        v-cost-SLT-rubl       = buf_aht-stk-line.cost-SLT-rubl
        v-cost-road-tax-base  = buf_aht-stk-line.cost-road-tax-base
        v-cost-road-tax-rubl  = buf_aht-stk-line.cost-road-tax-rubl
        v-cost-excise-base    = buf_aht-stk-line.cost-excise-base
        v-cost-excise-rubl    = buf_aht-stk-line.cost-excise-rubl
        v-cost-transport-base = buf_aht-stk-line.cost-transport-base
        v-cost-transport-rubl = buf_aht-stk-line.cost-transport-rubl
        v-cost-other-base     = buf_aht-stk-line.cost-other-base
        v-cost-other-rubl     = buf_aht-stk-line.cost-other-rubl
        v-cost-discnt-base    = buf_aht-stk-line.cost-discnt-base
        v-cost-discnt-rubl    = buf_aht-stk-line.cost-discnt-rubl
        v-crsa-sum-base       = buf_aht-stk-line.crsa-sum-base
        v-crsa-sum-rubl       = buf_aht-stk-line.crsa-sum-rubl
        v-crsa-VAT-base       = buf_aht-stk-line.crsa-VAT-base
        v-crsa-VAT-rubl       = buf_aht-stk-line.crsa-VAT-rubl
        v-crsa-SLT-base       = buf_aht-stk-line.crsa-SLT-base
        v-crsa-SLT-rubl       = buf_aht-stk-line.crsa-SLT-rubl
        v-crsa-road-tax-base  = buf_aht-stk-line.crsa-road-tax-base
        v-crsa-road-tax-rubl  = buf_aht-stk-line.crsa-road-tax-rubl
        v-crsa-excise-base    = buf_aht-stk-line.crsa-excise-base
        v-crsa-excise-rubl    = buf_aht-stk-line.crsa-excise-rubl
        v-crsa-transport-base = buf_aht-stk-line.crsa-transport-base
        v-crsa-transport-rubl = buf_aht-stk-line.crsa-transport-rubl
        v-crsa-other-base     = buf_aht-stk-line.crsa-other-base
        v-crsa-other-rubl     = buf_aht-stk-line.crsa-other-rubl
        v-crsa-discnt-base    = buf_aht-stk-line.crsa-discnt-base
        v-crsa-discnt-rubl    = buf_aht-stk-line.crsa-discnt-rubl
        v-sale-sum-base       = buf_aht-stk-line.sale-sum-base
        v-sale-sum-rubl       = buf_aht-stk-line.sale-sum-rubl
        v-sale-VAT-base       = buf_aht-stk-line.sale-VAT-base
        v-sale-VAT-rubl       = buf_aht-stk-line.sale-VAT-rubl
        v-sale-SLT-base       = buf_aht-stk-line.sale-SLT-base
        v-sale-SLT-rubl       = buf_aht-stk-line.sale-SLT-rubl
        v-sale-road-tax-base  = buf_aht-stk-line.sale-road-tax-base
        v-sale-road-tax-rubl  = buf_aht-stk-line.sale-road-tax-rubl
        v-sale-excise-base    = buf_aht-stk-line.sale-excise-base
        v-sale-excise-rubl    = buf_aht-stk-line.sale-excise-rubl
        v-sale-transport-base = buf_aht-stk-line.sale-transport-base
        v-sale-transport-rubl = buf_aht-stk-line.sale-transport-rubl
        v-sale-other-base     = buf_aht-stk-line.sale-other-base
        v-sale-other-rubl     = buf_aht-stk-line.sale-other-rubl
        v-sale-discnt-base    = buf_aht-stk-line.sale-discnt-base
        v-sale-discnt-rubl    = buf_aht-stk-line.sale-discnt-rubl
      .

      find last buf_prev_aht-stk-line no-lock
        where buf_prev_aht-stk-line.obj-type   = buf_aht-stk-line.obj-type
          and buf_prev_aht-stk-line.obj-code   = buf_aht-stk-line.obj-code
          and buf_prev_aht-stk-line.gds-code   = buf_aht-stk-line.gds-code
          and buf_prev_aht-stk-line.sum-type   = buf_aht-stk-line.sum-type
          and buf_prev_aht-stk-line.fact-order < p-fact-order-begin-day
        use-index category
        no-error .
      if  available buf_prev_aht-stk-line
      then do:
        assign
          v-fact-qnty           = v-fact-qnty           - buf_prev_aht-stk-line.fact-qnty
          v-cost-sum-base       = v-cost-sum-base       - buf_prev_aht-stk-line.cost-sum-base
          v-cost-sum-rubl       = v-cost-sum-rubl       - buf_prev_aht-stk-line.cost-sum-rubl
          v-cost-VAT-base       = v-cost-VAT-base       - buf_prev_aht-stk-line.cost-VAT-base
          v-cost-VAT-rubl       = v-cost-VAT-rubl       - buf_prev_aht-stk-line.cost-VAT-rubl
          v-cost-SLT-base       = v-cost-SLT-base       - buf_prev_aht-stk-line.cost-SLT-base
          v-cost-SLT-rubl       = v-cost-SLT-rubl       - buf_prev_aht-stk-line.cost-SLT-rubl
          v-cost-road-tax-base  = v-cost-road-tax-base  - buf_prev_aht-stk-line.cost-road-tax-base
          v-cost-road-tax-rubl  = v-cost-road-tax-rubl  - buf_prev_aht-stk-line.cost-road-tax-rubl
          v-cost-excise-base    = v-cost-excise-base    - buf_prev_aht-stk-line.cost-excise-base
          v-cost-excise-rubl    = v-cost-excise-rubl    - buf_prev_aht-stk-line.cost-excise-rubl
          v-cost-transport-base = v-cost-transport-base - buf_prev_aht-stk-line.cost-transport-base
          v-cost-transport-rubl = v-cost-transport-rubl - buf_prev_aht-stk-line.cost-transport-rubl
          v-cost-other-base     = v-cost-other-base     - buf_prev_aht-stk-line.cost-other-base
          v-cost-other-rubl     = v-cost-other-rubl     - buf_prev_aht-stk-line.cost-other-rubl
          v-cost-discnt-base    = v-cost-discnt-base    - buf_prev_aht-stk-line.cost-discnt-base
          v-cost-discnt-rubl    = v-cost-discnt-rubl    - buf_prev_aht-stk-line.cost-discnt-rubl

          v-crsa-sum-base       = v-crsa-sum-base       - buf_prev_aht-stk-line.crsa-sum-base
          v-crsa-sum-rubl       = v-crsa-sum-rubl       - buf_prev_aht-stk-line.crsa-sum-rubl
          v-crsa-VAT-base       = v-crsa-VAT-base       - buf_prev_aht-stk-line.crsa-VAT-base
          v-crsa-VAT-rubl       = v-crsa-VAT-rubl       - buf_prev_aht-stk-line.crsa-VAT-rubl
          v-crsa-SLT-base       = v-crsa-SLT-base       - buf_prev_aht-stk-line.crsa-SLT-base
          v-crsa-SLT-rubl       = v-crsa-SLT-rubl       - buf_prev_aht-stk-line.crsa-SLT-rubl
          v-crsa-road-tax-base  = v-crsa-road-tax-base  - buf_prev_aht-stk-line.crsa-road-tax-base
          v-crsa-road-tax-rubl  = v-crsa-road-tax-rubl  - buf_prev_aht-stk-line.crsa-road-tax-rubl
          v-crsa-excise-base    = v-crsa-excise-base    - buf_prev_aht-stk-line.crsa-excise-base
          v-crsa-excise-rubl    = v-crsa-excise-rubl    - buf_prev_aht-stk-line.crsa-excise-rubl
          v-crsa-transport-base = v-crsa-transport-base - buf_prev_aht-stk-line.crsa-transport-base
          v-crsa-transport-rubl = v-crsa-transport-rubl - buf_prev_aht-stk-line.crsa-transport-rubl
          v-crsa-other-base     = v-crsa-other-base     - buf_prev_aht-stk-line.crsa-other-base
          v-crsa-other-rubl     = v-crsa-other-rubl     - buf_prev_aht-stk-line.crsa-other-rubl
          v-crsa-discnt-base    = v-crsa-discnt-base    - buf_prev_aht-stk-line.crsa-discnt-base
          v-crsa-discnt-rubl    = v-crsa-discnt-rubl    - buf_prev_aht-stk-line.crsa-discnt-rubl

          v-sale-sum-base       = v-sale-sum-base       - buf_prev_aht-stk-line.sale-sum-base
          v-sale-sum-rubl       = v-sale-sum-rubl       - buf_prev_aht-stk-line.sale-sum-rubl
          v-sale-VAT-base       = v-sale-VAT-base       - buf_prev_aht-stk-line.sale-VAT-base
          v-sale-VAT-rubl       = v-sale-VAT-rubl       - buf_prev_aht-stk-line.sale-VAT-rubl
          v-sale-SLT-base       = v-sale-SLT-base       - buf_prev_aht-stk-line.sale-SLT-base
          v-sale-SLT-rubl       = v-sale-SLT-rubl       - buf_prev_aht-stk-line.sale-SLT-rubl
          v-sale-road-tax-base  = v-sale-road-tax-base  - buf_prev_aht-stk-line.sale-road-tax-base
          v-sale-road-tax-rubl  = v-sale-road-tax-rubl  - buf_prev_aht-stk-line.sale-road-tax-rubl
          v-sale-excise-base    = v-sale-excise-base    - buf_prev_aht-stk-line.sale-excise-base
          v-sale-excise-rubl    = v-sale-excise-rubl    - buf_prev_aht-stk-line.sale-excise-rubl
          v-sale-transport-base = v-sale-transport-base - buf_prev_aht-stk-line.sale-transport-base
          v-sale-transport-rubl = v-sale-transport-rubl - buf_prev_aht-stk-line.sale-transport-rubl
          v-sale-other-base     = v-sale-other-base     - buf_prev_aht-stk-line.sale-other-base
          v-sale-other-rubl     = v-sale-other-rubl     - buf_prev_aht-stk-line.sale-other-rubl
          v-sale-discnt-base    = v-sale-discnt-base    - buf_prev_aht-stk-line.sale-discnt-base
          v-sale-discnt-rubl    = v-sale-discnt-rubl    - buf_prev_aht-stk-line.sale-discnt-rubl
        .
      end.

      find first buf_temp-aht-ot-day
        where buf_temp-aht-ot-day.temp-gds-code  = buf_aht-stk-line.gds-code
          and buf_temp-aht-ot-day.temp-sum-type  = buf_aht-stk-line.sum-type
        no-error .
      if available buf_temp-aht-ot-day
      then do:
        if buf_aht-stk-line.sum-type <> {&aht-service}
        then do:
          assign
            v-fact-qnty           = v-fact-qnty           - buf_temp-aht-ot-day.temp-fact-qnty
            v-cost-sum-base       = v-cost-sum-base       - buf_temp-aht-ot-day.temp-cost-sum-base
            v-cost-sum-rubl       = v-cost-sum-rubl       - buf_temp-aht-ot-day.temp-cost-sum-rubl
            v-cost-VAT-base       = v-cost-VAT-base       - buf_temp-aht-ot-day.temp-cost-VAT-base
            v-cost-VAT-rubl       = v-cost-VAT-rubl       - buf_temp-aht-ot-day.temp-cost-VAT-rubl
            v-cost-SLT-base       = v-cost-SLT-base       - buf_temp-aht-ot-day.temp-cost-SLT-base
            v-cost-SLT-rubl       = v-cost-SLT-rubl       - buf_temp-aht-ot-day.temp-cost-SLT-rubl
            v-cost-road-tax-base  = v-cost-road-tax-base  - buf_temp-aht-ot-day.temp-cost-road-tax-base
            v-cost-road-tax-rubl  = v-cost-road-tax-rubl  - buf_temp-aht-ot-day.temp-cost-road-tax-rubl
            v-cost-excise-base    = v-cost-excise-base    - buf_temp-aht-ot-day.temp-cost-excise-base
            v-cost-excise-rubl    = v-cost-excise-rubl    - buf_temp-aht-ot-day.temp-cost-excise-rubl
            v-cost-transport-base = v-cost-transport-base - buf_temp-aht-ot-day.temp-cost-transport-base
            v-cost-transport-rubl = v-cost-transport-rubl - buf_temp-aht-ot-day.temp-cost-transport-rubl
            v-cost-other-base     = v-cost-other-base     - buf_temp-aht-ot-day.temp-cost-other-base
            v-cost-other-rubl     = v-cost-other-rubl     - buf_temp-aht-ot-day.temp-cost-other-rubl
            v-cost-discnt-base    = v-cost-discnt-base    - buf_temp-aht-ot-day.temp-cost-discnt-base
            v-cost-discnt-rubl    = v-cost-discnt-rubl    - buf_temp-aht-ot-day.temp-cost-discnt-rubl

            v-crsa-sum-base       = v-crsa-sum-base       - buf_temp-aht-ot-day.temp-crsa-sum-base
            v-crsa-sum-rubl       = v-crsa-sum-rubl       - buf_temp-aht-ot-day.temp-crsa-sum-rubl
            v-crsa-VAT-base       = v-crsa-VAT-base       - buf_temp-aht-ot-day.temp-crsa-VAT-base
            v-crsa-VAT-rubl       = v-crsa-VAT-rubl       - buf_temp-aht-ot-day.temp-crsa-VAT-rubl
            v-crsa-SLT-base       = v-crsa-SLT-base       - buf_temp-aht-ot-day.temp-crsa-SLT-base
            v-crsa-SLT-rubl       = v-crsa-SLT-rubl       - buf_temp-aht-ot-day.temp-crsa-SLT-rubl
            v-crsa-road-tax-base  = v-crsa-road-tax-base  - buf_temp-aht-ot-day.temp-crsa-road-tax-base
            v-crsa-road-tax-rubl  = v-crsa-road-tax-rubl  - buf_temp-aht-ot-day.temp-crsa-road-tax-rubl
            v-crsa-excise-base    = v-crsa-excise-base    - buf_temp-aht-ot-day.temp-crsa-excise-base
            v-crsa-excise-rubl    = v-crsa-excise-rubl    - buf_temp-aht-ot-day.temp-crsa-excise-rubl
            v-crsa-transport-base = v-crsa-transport-base - buf_temp-aht-ot-day.temp-crsa-transport-base
            v-crsa-transport-rubl = v-crsa-transport-rubl - buf_temp-aht-ot-day.temp-crsa-transport-rubl
            v-crsa-other-base     = v-crsa-other-base     - buf_temp-aht-ot-day.temp-crsa-other-base
            v-crsa-other-rubl     = v-crsa-other-rubl     - buf_temp-aht-ot-day.temp-crsa-other-rubl
            v-crsa-discnt-base    = v-crsa-discnt-base    - buf_temp-aht-ot-day.temp-crsa-discnt-base
            v-crsa-discnt-rubl    = v-crsa-discnt-rubl    - buf_temp-aht-ot-day.temp-crsa-discnt-rubl
          .
          if length(buf_aht-stk-line.sum-type) > 1
          then do:
            assign
              v-sale-sum-base       = v-sale-sum-base       - buf_temp-aht-ot-day.temp-sale-sum-base
              v-sale-sum-rubl       = v-sale-sum-rubl       - buf_temp-aht-ot-day.temp-sale-sum-rubl
              v-sale-VAT-base       = v-sale-VAT-base       - buf_temp-aht-ot-day.temp-sale-VAT-base
              v-sale-VAT-rubl       = v-sale-VAT-rubl       - buf_temp-aht-ot-day.temp-sale-VAT-rubl
              v-sale-SLT-base       = v-sale-SLT-base       - buf_temp-aht-ot-day.temp-sale-SLT-base
              v-sale-SLT-rubl       = v-sale-SLT-rubl       - buf_temp-aht-ot-day.temp-sale-SLT-rubl
              v-sale-road-tax-base  = v-sale-road-tax-base  - buf_temp-aht-ot-day.temp-sale-road-tax-base
              v-sale-road-tax-rubl  = v-sale-road-tax-rubl  - buf_temp-aht-ot-day.temp-sale-road-tax-rubl
              v-sale-excise-base    = v-sale-excise-base    - buf_temp-aht-ot-day.temp-sale-excise-base
              v-sale-excise-rubl    = v-sale-excise-rubl    - buf_temp-aht-ot-day.temp-sale-excise-rubl
              v-sale-transport-base = v-sale-transport-base - buf_temp-aht-ot-day.temp-sale-transport-base
              v-sale-transport-rubl = v-sale-transport-rubl - buf_temp-aht-ot-day.temp-sale-transport-rubl
              v-sale-other-base     = v-sale-other-base     - buf_temp-aht-ot-day.temp-sale-other-base
              v-sale-other-rubl     = v-sale-other-rubl     - buf_temp-aht-ot-day.temp-sale-other-rubl
              v-sale-discnt-base    = v-sale-discnt-base    - buf_temp-aht-ot-day.temp-sale-discnt-base
              v-sale-discnt-rubl    = v-sale-discnt-rubl    - buf_temp-aht-ot-day.temp-sale-discnt-rubl
            .
          end.
        end.
      end.

      if v-fact-qnty           <> 0
      or v-cost-sum-base       <> 0
      or v-cost-sum-rubl       <> 0
      or v-cost-VAT-base       <> 0
      or v-cost-VAT-rubl       <> 0
      or v-cost-SLT-base       <> 0
      or v-cost-SLT-rubl       <> 0
      or v-cost-road-tax-base  <> 0
      or v-cost-road-tax-rubl  <> 0
      or v-cost-excise-base    <> 0
      or v-cost-excise-rubl    <> 0
      or v-cost-transport-base <> 0
      or v-cost-transport-rubl <> 0
      or v-cost-other-base     <> 0
      or v-cost-other-rubl     <> 0
      or v-cost-discnt-base    <> 0
      or v-cost-discnt-rubl    <> 0

      or v-crsa-sum-base       <> 0
      or v-crsa-sum-rubl       <> 0
      or v-crsa-VAT-base       <> 0
      or v-crsa-VAT-rubl       <> 0
      or v-crsa-SLT-base       <> 0
      or v-crsa-SLT-rubl       <> 0
      or v-crsa-road-tax-base  <> 0
      or v-crsa-road-tax-rubl  <> 0
      or v-crsa-excise-base    <> 0
      or v-crsa-excise-rubl    <> 0
      or v-crsa-transport-base <> 0
      or v-crsa-transport-rubl <> 0
      or v-crsa-other-base     <> 0
      or v-crsa-other-rubl     <> 0
      or v-crsa-discnt-base    <> 0
      or v-crsa-discnt-rubl    <> 0

      or v-sale-sum-base       <> 0
      or v-sale-sum-rubl       <> 0
      or v-sale-VAT-base       <> 0
      or v-sale-VAT-rubl       <> 0
      or v-sale-SLT-base       <> 0
      or v-sale-SLT-rubl       <> 0
      or v-sale-road-tax-base  <> 0
      or v-sale-road-tax-rubl  <> 0
      or v-sale-excise-base    <> 0
      or v-sale-excise-rubl    <> 0
      or v-sale-transport-base <> 0
      or v-sale-transport-rubl <> 0
      or v-sale-other-base     <> 0
      or v-sale-other-rubl     <> 0
      or v-sale-discnt-base    <> 0
      or v-sale-discnt-rubl    <> 0
      then do:
        assign
          v-total-err = v-total-err + 1
        .

        run cur-time in this-procedure
          (output v-today
          ,output v-time
          ) .

        define variable v-fact-date as date      no-undo .

        run factord-to-date in this-procedure
          (input  buf_aht-stk-line.fact-order
          ,output v-fact-date
          ) .

        run update-last-date in this-procedure
          (input v-fact-date
          ) .

        output stream sout to value(v-log-err-file) append .
        export stream sout '***':u string(v-today, '99/99/9999':u) string(v-time, 'HH:MM:SS':u) .
        export stream sout "error-03: aht-stk-line record different quantity" .
        export stream sout "obj-type"            buf_aht-stk-line.obj-type            .
        export stream sout "obj-code"            buf_aht-stk-line.obj-code            .
        export stream sout "fact-order"          buf_aht-stk-line.fact-order          .
        export stream sout "fact-date"           v-fact-date                          .
        export stream sout "gds-code"            buf_aht-stk-line.gds-code            .
        export stream sout "sum-type"            buf_aht-stk-line.sum-type            .
        export stream sout "fact-order"          buf_aht-stk-line.fact-order          .
        export stream sout "fact-qnty"           buf_aht-stk-line.fact-qnty           .
        export stream sout "cost-sum-base"       buf_aht-stk-line.cost-sum-base       .
        export stream sout "cost-sum-rubl"       buf_aht-stk-line.cost-sum-rubl       .
        export stream sout "cost-VAT-base"       buf_aht-stk-line.cost-VAT-base       .
        export stream sout "cost-VAT-rubl"       buf_aht-stk-line.cost-VAT-rubl       .
        export stream sout "cost-SLT-base"       buf_aht-stk-line.cost-SLT-base       .
        export stream sout "cost-SLT-rubl"       buf_aht-stk-line.cost-SLT-rubl       .
        export stream sout "cost-road-tax-base"  buf_aht-stk-line.cost-road-tax-base  .
        export stream sout "cost-road-tax-rubl"  buf_aht-stk-line.cost-road-tax-rubl  .
        export stream sout "cost-excise-base"    buf_aht-stk-line.cost-excise-base    .
        export stream sout "cost-excise-rubl"    buf_aht-stk-line.cost-excise-rubl    .
        export stream sout "cost-transport-base" buf_aht-stk-line.cost-transport-base .
        export stream sout "cost-transport-rubl" buf_aht-stk-line.cost-transport-rubl .
        export stream sout "cost-other-base"     buf_aht-stk-line.cost-other-base     .
        export stream sout "cost-other-rubl"     buf_aht-stk-line.cost-other-rubl     .
        export stream sout "cost-discnt-base"    buf_aht-stk-line.cost-discnt-base    .
        export stream sout "cost-discnt-rubl"    buf_aht-stk-line.cost-discnt-rubl    .
        export stream sout "crsa-sum-base"       buf_aht-stk-line.crsa-sum-base       .
        export stream sout "crsa-sum-rubl"       buf_aht-stk-line.crsa-sum-rubl       .
        export stream sout "crsa-VAT-base"       buf_aht-stk-line.crsa-VAT-base       .
        export stream sout "crsa-VAT-rubl"       buf_aht-stk-line.crsa-VAT-rubl       .
        export stream sout "crsa-SLT-base"       buf_aht-stk-line.crsa-SLT-base       .
        export stream sout "crsa-SLT-rubl"       buf_aht-stk-line.crsa-SLT-rubl       .
        export stream sout "crsa-road-tax-base"  buf_aht-stk-line.crsa-road-tax-base  .
        export stream sout "crsa-road-tax-rubl"  buf_aht-stk-line.crsa-road-tax-rubl  .
        export stream sout "crsa-excise-base"    buf_aht-stk-line.crsa-excise-base    .
        export stream sout "crsa-excise-rubl"    buf_aht-stk-line.crsa-excise-rubl    .
        export stream sout "crsa-transport-base" buf_aht-stk-line.crsa-transport-base .
        export stream sout "crsa-transport-rubl" buf_aht-stk-line.crsa-transport-rubl .
        export stream sout "crsa-other-base"     buf_aht-stk-line.crsa-other-base     .
        export stream sout "crsa-other-rubl"     buf_aht-stk-line.crsa-other-rubl     .
        export stream sout "crsa-discnt-base"    buf_aht-stk-line.crsa-discnt-base    .
        export stream sout "crsa-discnt-rubl"    buf_aht-stk-line.crsa-discnt-rubl    .
        export stream sout "sale-sum-base"       buf_aht-stk-line.sale-sum-base       .
        export stream sout "sale-sum-rubl"       buf_aht-stk-line.sale-sum-rubl       .
        export stream sout "sale-VAT-base"       buf_aht-stk-line.sale-VAT-base       .
        export stream sout "sale-VAT-rubl"       buf_aht-stk-line.sale-VAT-rubl       .
        export stream sout "sale-SLT-base"       buf_aht-stk-line.sale-SLT-base       .
        export stream sout "sale-SLT-rubl"       buf_aht-stk-line.sale-SLT-rubl       .
        export stream sout "sale-road-tax-base"  buf_aht-stk-line.sale-road-tax-base  .
        export stream sout "sale-road-tax-rubl"  buf_aht-stk-line.sale-road-tax-rubl  .
        export stream sout "sale-excise-base"    buf_aht-stk-line.sale-excise-base    .
        export stream sout "sale-excise-rubl"    buf_aht-stk-line.sale-excise-rubl    .
        export stream sout "sale-transport-base" buf_aht-stk-line.sale-transport-base .
        export stream sout "sale-transport-rubl" buf_aht-stk-line.sale-transport-rubl .
        export stream sout "sale-other-base"     buf_aht-stk-line.sale-other-base     .
        export stream sout "sale-other-rubl"     buf_aht-stk-line.sale-other-rubl     .
        export stream sout "sale-discnt-base"    buf_aht-stk-line.sale-discnt-base    .
        export stream sout "sale-discnt-rubl"    buf_aht-stk-line.sale-discnt-rubl    .
        export stream sout "diff-fact-qnty"           v-fact-qnty           .
        export stream sout "diff-cost-sum-base"       v-cost-sum-base       .
        export stream sout "diff-cost-sum-rubl"       v-cost-sum-rubl       .
        export stream sout "diff-cost-VAT-base"       v-cost-VAT-base       .
        export stream sout "diff-cost-VAT-rubl"       v-cost-VAT-rubl       .
        export stream sout "diff-cost-SLT-base"       v-cost-SLT-base       .
        export stream sout "diff-cost-SLT-rubl"       v-cost-SLT-rubl       .
        export stream sout "diff-cost-road-tax-base"  v-cost-road-tax-base  .
        export stream sout "diff-cost-road-tax-rubl"  v-cost-road-tax-rubl  .
        export stream sout "diff-cost-excise-base"    v-cost-excise-base    .
        export stream sout "diff-cost-excise-rubl"    v-cost-excise-rubl    .
        export stream sout "diff-cost-transport-base" v-cost-transport-base .
        export stream sout "diff-cost-transport-rubl" v-cost-transport-rubl .
        export stream sout "diff-cost-other-base"     v-cost-other-base     .
        export stream sout "diff-cost-other-rubl"     v-cost-other-rubl     .
        export stream sout "diff-cost-discnt-base"    v-cost-discnt-base    .
        export stream sout "diff-cost-discnt-rubl"    v-cost-discnt-rubl    .
        export stream sout "diff-crsa-sum-base"       v-crsa-sum-base       .
        export stream sout "diff-crsa-sum-rubl"       v-crsa-sum-rubl       .
        export stream sout "diff-crsa-VAT-base"       v-crsa-VAT-base       .
        export stream sout "diff-crsa-VAT-rubl"       v-crsa-VAT-rubl       .
        export stream sout "diff-crsa-SLT-base"       v-crsa-SLT-base       .
        export stream sout "diff-crsa-SLT-rubl"       v-crsa-SLT-rubl       .
        export stream sout "diff-crsa-road-tax-base"  v-crsa-road-tax-base  .
        export stream sout "diff-crsa-road-tax-rubl"  v-crsa-road-tax-rubl  .
        export stream sout "diff-crsa-excise-base"    v-crsa-excise-base    .
        export stream sout "diff-crsa-excise-rubl"    v-crsa-excise-rubl    .
        export stream sout "diff-crsa-transport-base" v-crsa-transport-base .
        export stream sout "diff-crsa-transport-rubl" v-crsa-transport-rubl .
        export stream sout "diff-crsa-other-base"     v-crsa-other-base     .
        export stream sout "diff-crsa-other-rubl"     v-crsa-other-rubl     .
        export stream sout "diff-crsa-discnt-base"    v-crsa-discnt-base    .
        export stream sout "diff-crsa-discnt-rubl"    v-crsa-discnt-rubl    .
        export stream sout "diff-sale-sum-base"       v-sale-sum-base       .
        export stream sout "diff-sale-sum-rubl"       v-sale-sum-rubl       .
        export stream sout "diff-sale-VAT-base"       v-sale-VAT-base       .
        export stream sout "diff-sale-VAT-rubl"       v-sale-VAT-rubl       .
        export stream sout "diff-sale-SLT-base"       v-sale-SLT-base       .
        export stream sout "diff-sale-SLT-rubl"       v-sale-SLT-rubl       .
        export stream sout "diff-sale-road-tax-base"  v-sale-road-tax-base  .
        export stream sout "diff-sale-road-tax-rubl"  v-sale-road-tax-rubl  .
        export stream sout "diff-sale-excise-base"    v-sale-excise-base    .
        export stream sout "diff-sale-excise-rubl"    v-sale-excise-rubl    .
        export stream sout "diff-sale-transport-base" v-sale-transport-base .
        export stream sout "diff-sale-transport-rubl" v-sale-transport-rubl .
        export stream sout "diff-sale-other-base"     v-sale-other-base     .
        export stream sout "diff-sale-other-rubl"     v-sale-other-rubl     .
        export stream sout "diff-sale-discnt-base"    v-sale-discnt-base    .
        export stream sout "diff-sale-discnt-rubl"    v-sale-discnt-rubl    .
        export stream sout "available prev_aht-stk-line" (available buf_prev_aht-stk-line) .
        if available buf_prev_aht-stk-line
        then do:
          export stream sout "prev-obj-type"            buf_prev_aht-stk-line.obj-type            .
          export stream sout "prev-obj-code"            buf_prev_aht-stk-line.obj-code            .
          export stream sout "prev-fact-order"          buf_prev_aht-stk-line.fact-order          .
          export stream sout "prev-gds-code"            buf_prev_aht-stk-line.gds-code            .
          export stream sout "prev-sum-type"            buf_prev_aht-stk-line.sum-type            .
          export stream sout "prev-fact-order"          buf_prev_aht-stk-line.fact-order          .
          export stream sout "prev-fact-qnty"           buf_prev_aht-stk-line.fact-qnty           .
          export stream sout "prev-cost-sum-base"       buf_prev_aht-stk-line.cost-sum-base       .
          export stream sout "prev-cost-sum-rubl"       buf_prev_aht-stk-line.cost-sum-rubl       .
          export stream sout "prev-cost-VAT-base"       buf_prev_aht-stk-line.cost-VAT-base       .
          export stream sout "prev-cost-VAT-rubl"       buf_prev_aht-stk-line.cost-VAT-rubl       .
          export stream sout "prev-cost-SLT-base"       buf_prev_aht-stk-line.cost-SLT-base       .
          export stream sout "prev-cost-SLT-rubl"       buf_prev_aht-stk-line.cost-SLT-rubl       .
          export stream sout "prev-cost-road-tax-base"  buf_prev_aht-stk-line.cost-road-tax-base  .
          export stream sout "prev-cost-road-tax-rubl"  buf_prev_aht-stk-line.cost-road-tax-rubl  .
          export stream sout "prev-cost-excise-base"    buf_prev_aht-stk-line.cost-excise-base    .
          export stream sout "prev-cost-excise-rubl"    buf_prev_aht-stk-line.cost-excise-rubl    .
          export stream sout "prev-cost-transport-base" buf_prev_aht-stk-line.cost-transport-base .
          export stream sout "prev-cost-transport-rubl" buf_prev_aht-stk-line.cost-transport-rubl .
          export stream sout "prev-cost-other-base"     buf_prev_aht-stk-line.cost-other-base     .
          export stream sout "prev-cost-other-rubl"     buf_prev_aht-stk-line.cost-other-rubl     .
          export stream sout "prev-cost-discnt-base"    buf_prev_aht-stk-line.cost-discnt-base    .
          export stream sout "prev-cost-discnt-rubl"    buf_prev_aht-stk-line.cost-discnt-rubl    .
          export stream sout "prev-crsa-sum-base"       buf_prev_aht-stk-line.crsa-sum-base       .
          export stream sout "prev-crsa-sum-rubl"       buf_prev_aht-stk-line.crsa-sum-rubl       .
          export stream sout "prev-crsa-VAT-base"       buf_prev_aht-stk-line.crsa-VAT-base       .
          export stream sout "prev-crsa-VAT-rubl"       buf_prev_aht-stk-line.crsa-VAT-rubl       .
          export stream sout "prev-crsa-SLT-base"       buf_prev_aht-stk-line.crsa-SLT-base       .
          export stream sout "prev-crsa-SLT-rubl"       buf_prev_aht-stk-line.crsa-SLT-rubl       .
          export stream sout "prev-crsa-road-tax-base"  buf_prev_aht-stk-line.crsa-road-tax-base  .
          export stream sout "prev-crsa-road-tax-rubl"  buf_prev_aht-stk-line.crsa-road-tax-rubl  .
          export stream sout "prev-crsa-excise-base"    buf_prev_aht-stk-line.crsa-excise-base    .
          export stream sout "prev-crsa-excise-rubl"    buf_prev_aht-stk-line.crsa-excise-rubl    .
          export stream sout "prev-crsa-transport-base" buf_prev_aht-stk-line.crsa-transport-base .
          export stream sout "prev-crsa-transport-rubl" buf_prev_aht-stk-line.crsa-transport-rubl .
          export stream sout "prev-crsa-other-base"     buf_prev_aht-stk-line.crsa-other-base     .
          export stream sout "prev-crsa-other-rubl"     buf_prev_aht-stk-line.crsa-other-rubl     .
          export stream sout "prev-crsa-discnt-base"    buf_prev_aht-stk-line.crsa-discnt-base    .
          export stream sout "prev-crsa-discnt-rubl"    buf_prev_aht-stk-line.crsa-discnt-rubl    .
          export stream sout "prev-sale-sum-base"       buf_prev_aht-stk-line.sale-sum-base       .
          export stream sout "prev-sale-sum-rubl"       buf_prev_aht-stk-line.sale-sum-rubl       .
          export stream sout "prev-sale-VAT-base"       buf_prev_aht-stk-line.sale-VAT-base       .
          export stream sout "prev-sale-VAT-rubl"       buf_prev_aht-stk-line.sale-VAT-rubl       .
          export stream sout "prev-sale-SLT-base"       buf_prev_aht-stk-line.sale-SLT-base       .
          export stream sout "prev-sale-SLT-rubl"       buf_prev_aht-stk-line.sale-SLT-rubl       .
          export stream sout "prev-sale-road-tax-base"  buf_prev_aht-stk-line.sale-road-tax-base  .
          export stream sout "prev-sale-road-tax-rubl"  buf_prev_aht-stk-line.sale-road-tax-rubl  .
          export stream sout "prev-sale-excise-base"    buf_prev_aht-stk-line.sale-excise-base    .
          export stream sout "prev-sale-excise-rubl"    buf_prev_aht-stk-line.sale-excise-rubl    .
          export stream sout "prev-sale-transport-base" buf_prev_aht-stk-line.sale-transport-base .
          export stream sout "prev-sale-transport-rubl" buf_prev_aht-stk-line.sale-transport-rubl .
          export stream sout "prev-sale-other-base"     buf_prev_aht-stk-line.sale-other-base     .
          export stream sout "prev-sale-other-rubl"     buf_prev_aht-stk-line.sale-other-rubl     .
          export stream sout "prev-sale-discnt-base"    buf_prev_aht-stk-line.sale-discnt-base    .
          export stream sout "prev-sale-discnt-rubl"    buf_prev_aht-stk-line.sale-discnt-rubl    .
        end.
        export stream sout "available aht-ot-day" (available buf_temp-aht-ot-day) .
        if available buf_temp-aht-ot-day
        then do:
          export stream sout "ot-day-gds-code"            buf_temp-aht-ot-day.temp-gds-code            .
          export stream sout "ot-day-sum-type"            buf_temp-aht-ot-day.temp-sum-type            .
          export stream sout "ot-day-fact-qnty"           buf_temp-aht-ot-day.temp-fact-qnty           .
          export stream sout "ot-day-cost-sum-base"       buf_temp-aht-ot-day.temp-cost-sum-base       .
          export stream sout "ot-day-cost-sum-rubl"       buf_temp-aht-ot-day.temp-cost-sum-rubl       .
          export stream sout "ot-day-cost-VAT-base"       buf_temp-aht-ot-day.temp-cost-VAT-base       .
          export stream sout "ot-day-cost-VAT-rubl"       buf_temp-aht-ot-day.temp-cost-VAT-rubl       .
          export stream sout "ot-day-cost-SLT-base"       buf_temp-aht-ot-day.temp-cost-SLT-base       .
          export stream sout "ot-day-cost-SLT-rubl"       buf_temp-aht-ot-day.temp-cost-SLT-rubl       .
          export stream sout "ot-day-cost-road-tax-base"  buf_temp-aht-ot-day.temp-cost-road-tax-base  .
          export stream sout "ot-day-cost-road-tax-rubl"  buf_temp-aht-ot-day.temp-cost-road-tax-rubl  .
          export stream sout "ot-day-cost-excise-base"    buf_temp-aht-ot-day.temp-cost-excise-base    .
          export stream sout "ot-day-cost-excise-rubl"    buf_temp-aht-ot-day.temp-cost-excise-rubl    .
          export stream sout "ot-day-cost-transport-base" buf_temp-aht-ot-day.temp-cost-transport-base .
          export stream sout "ot-day-cost-transport-rubl" buf_temp-aht-ot-day.temp-cost-transport-rubl .
          export stream sout "ot-day-cost-other-base"     buf_temp-aht-ot-day.temp-cost-other-base     .
          export stream sout "ot-day-cost-other-rubl"     buf_temp-aht-ot-day.temp-cost-other-rubl     .
          export stream sout "ot-day-cost-discnt-base"    buf_temp-aht-ot-day.temp-cost-discnt-base    .
          export stream sout "ot-day-cost-discnt-rubl"    buf_temp-aht-ot-day.temp-cost-discnt-rubl    .
          export stream sout "ot-day-crsa-sum-base"       buf_temp-aht-ot-day.temp-crsa-sum-base       .
          export stream sout "ot-day-crsa-sum-rubl"       buf_temp-aht-ot-day.temp-crsa-sum-rubl       .
          export stream sout "ot-day-crsa-VAT-base"       buf_temp-aht-ot-day.temp-crsa-VAT-base       .
          export stream sout "ot-day-crsa-VAT-rubl"       buf_temp-aht-ot-day.temp-crsa-VAT-rubl       .
          export stream sout "ot-day-crsa-SLT-base"       buf_temp-aht-ot-day.temp-crsa-SLT-base       .
          export stream sout "ot-day-crsa-SLT-rubl"       buf_temp-aht-ot-day.temp-crsa-SLT-rubl       .
          export stream sout "ot-day-crsa-road-tax-base"  buf_temp-aht-ot-day.temp-crsa-road-tax-base  .
          export stream sout "ot-day-crsa-road-tax-rubl"  buf_temp-aht-ot-day.temp-crsa-road-tax-rubl  .
          export stream sout "ot-day-crsa-excise-base"    buf_temp-aht-ot-day.temp-crsa-excise-base    .
          export stream sout "ot-day-crsa-excise-rubl"    buf_temp-aht-ot-day.temp-crsa-excise-rubl    .
          export stream sout "ot-day-crsa-transport-base" buf_temp-aht-ot-day.temp-crsa-transport-base .
          export stream sout "ot-day-crsa-transport-rubl" buf_temp-aht-ot-day.temp-crsa-transport-rubl .
          export stream sout "ot-day-crsa-other-base"     buf_temp-aht-ot-day.temp-crsa-other-base     .
          export stream sout "ot-day-crsa-other-rubl"     buf_temp-aht-ot-day.temp-crsa-other-rubl     .
          export stream sout "ot-day-crsa-discnt-base"    buf_temp-aht-ot-day.temp-crsa-discnt-base    .
          export stream sout "ot-day-crsa-discnt-rubl"    buf_temp-aht-ot-day.temp-crsa-discnt-rubl    .
          export stream sout "ot-day-sale-sum-base"       buf_temp-aht-ot-day.temp-sale-sum-base       .
          export stream sout "ot-day-sale-sum-rubl"       buf_temp-aht-ot-day.temp-sale-sum-rubl       .
          export stream sout "ot-day-sale-VAT-base"       buf_temp-aht-ot-day.temp-sale-VAT-base       .
          export stream sout "ot-day-sale-VAT-rubl"       buf_temp-aht-ot-day.temp-sale-VAT-rubl       .
          export stream sout "ot-day-sale-SLT-base"       buf_temp-aht-ot-day.temp-sale-SLT-base       .
          export stream sout "ot-day-sale-SLT-rubl"       buf_temp-aht-ot-day.temp-sale-SLT-rubl       .
          export stream sout "ot-day-sale-road-tax-base"  buf_temp-aht-ot-day.temp-sale-road-tax-base  .
          export stream sout "ot-day-sale-road-tax-rubl"  buf_temp-aht-ot-day.temp-sale-road-tax-rubl  .
          export stream sout "ot-day-sale-excise-base"    buf_temp-aht-ot-day.temp-sale-excise-base    .
          export stream sout "ot-day-sale-excise-rubl"    buf_temp-aht-ot-day.temp-sale-excise-rubl    .
          export stream sout "ot-day-sale-transport-base" buf_temp-aht-ot-day.temp-sale-transport-base .
          export stream sout "ot-day-sale-transport-rubl" buf_temp-aht-ot-day.temp-sale-transport-rubl .
          export stream sout "ot-day-sale-other-base"     buf_temp-aht-ot-day.temp-sale-other-base     .
          export stream sout "ot-day-sale-other-rubl"     buf_temp-aht-ot-day.temp-sale-other-rubl     .
          export stream sout "ot-day-sale-discnt-base"    buf_temp-aht-ot-day.temp-sale-discnt-base    .
          export stream sout "ot-day-sale-discnt-rubl"    buf_temp-aht-ot-day.temp-sale-discnt-rubl    .
        end.
        output stream sout close .
      end.
    end.
  end.


end procedure. /* validate-aht-stk-line */


procedure validate-free-zone :

  define buffer buf_lock_gds-obj for ub.gds-obj .
  define buffer buf_gds-obj for ub.gds-obj .
  define buffer buf_aht-stk-line for ub.aht-stk-line .
  define buffer buf_temp-aht-stk-line for temp-aht-stk-line .
  define buffer buf_temp-parts for temp-parts .
  define buffer buf_goods for ub.goods .

  define variable v-ind as integer   no-undo .

  do
  on error undo, return error return-value
  :

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
          (input substitute("Проверка остатков. Ошибок &1. Объект &2 &3. Артикул &4 &5 &6."
                          ,v-total-err
                          ,p-obj-type
                          ,p-obj-code
                          ,buf_gds-obj.artic
                          ,buf_gds-obj.prod-type
                          ,buf_gds-obj.prod-code
                          )
          ).
      end.


      run clear-temp-aht-stk-line in this-procedure .

      do transaction
      on error undo, return error return-value
      :
        find buf_lock_gds-obj exclusive-lock
          where rowid(buf_lock_gds-obj) = rowid(buf_gds-obj)
          .

        run partslib-init-temp-parts in this-procedure
          (input  buf_gds-obj.obj-type  /* p-obj-type  */
          ,input  buf_gds-obj.obj-code  /* p-obj-code  */
          ,input  buf_gds-obj.artic     /* p-artic     */
          ,input  buf_gds-obj.prod-type /* p-prod-type */
          ,input  buf_gds-obj.prod-code /* p-prod-code */
          ) .
      end.

      define variable v-sum-type as character no-undo .

      find first buf_goods no-lock
        where buf_goods.gds-code = buf_gds-obj.gds-code
        no-error .
      if not available buf_goods
      then do:
        assign
          v-total-err = v-total-err + 1
        .

        run cur-time in this-procedure
          (output v-today
          ,output v-time
          ) .
        run update-last-date in this-procedure
          (input v-today
          ) .

        output stream sout to value(v-log-err-file) append .
        export stream sout '***':u string(v-today, '99/99/9999':u) string(v-time, 'HH:MM:SS':u) .
        export stream sout "error-04: ub.goods not found" .
        export stream sout "obj-type"  p-obj-type                            .
        export stream sout "obj-code"  p-obj-code                            .
        export stream sout "gds-code"  buf_gds-obj.gds-code                  .
        output stream sout close .
      end.

      if buf_goods.gds-type = {&gds-goods}
      then do:
        for each buf_temp-parts
        on error undo, return error return-value
        :
          case buf_temp-parts.purch-code
          :
            when {&bef-repayment-code}
            then do:
              assign
                v-sum-type = {&aht-repayment}
              .
            end.
            when {&bef-consignation-code}
            then do:
              assign
                v-sum-type = {&aht-cons_acc}
              .
            end.
            when {&bef-responsible-storage-code}
            then do:
              assign
                v-sum-type = {&aht-resp_stor}
              .
            end.
            when {&bef-old-consignation-code}
            then do:
              assign
                v-sum-type = {&aht-old_cons}
              .
            end.
            otherwise do:
              /* todo - неизвестный тип приобретения */
            end.
          end.

          find first buf_temp-aht-stk-line
            where buf_temp-aht-stk-line.temp-gds-code = buf_gds-obj.gds-code
              and buf_temp-aht-stk-line.temp-sum-type = v-sum-type
            no-error .
          if not available buf_temp-aht-stk-line
          then do:
            create buf_temp-aht-stk-line .
            assign
              buf_temp-aht-stk-line.temp-gds-code = buf_gds-obj.gds-code
              buf_temp-aht-stk-line.temp-sum-type = v-sum-type
            .
          end.

          assign
            buf_temp-aht-stk-line.temp-fact-qnty = buf_temp-aht-stk-line.temp-fact-qnty
                                                + buf_temp-parts.fact-qnty
          .

          if v-sum-type = {&aht-cons_acc}
          then do:
            find first buf_temp-aht-stk-line
              where buf_temp-aht-stk-line.temp-gds-code = buf_gds-obj.gds-code
                and buf_temp-aht-stk-line.temp-sum-type = {&aht-cons_benf}
              no-error .
            if not available buf_temp-aht-stk-line
            then do:
              create buf_temp-aht-stk-line .
              assign
                buf_temp-aht-stk-line.temp-gds-code = buf_gds-obj.gds-code
                buf_temp-aht-stk-line.temp-sum-type = {&aht-cons_benf}
              .
            end.

            assign
              buf_temp-aht-stk-line.temp-fact-qnty = buf_temp-aht-stk-line.temp-fact-qnty
                                                  + buf_temp-parts.fact-qnty
            .
          end.
        end.
      end.
      else do:
        find first buf_temp-aht-stk-line
          where buf_temp-aht-stk-line.temp-gds-code = buf_gds-obj.gds-code
            and buf_temp-aht-stk-line.temp-sum-type = {&aht-service}
          no-error .
        if not available buf_temp-aht-stk-line
        then do:
          create buf_temp-aht-stk-line .
          assign
            buf_temp-aht-stk-line.temp-gds-code = buf_gds-obj.gds-code
            buf_temp-aht-stk-line.temp-sum-type = {&aht-service}
          .
        end.

        assign
          buf_temp-aht-stk-line.temp-fact-qnty = buf_temp-aht-stk-line.temp-fact-qnty
                                               + buf_gds-obj.fact-qnty
        .
      end.


      for each buf_temp-aht-stk-line
      on error undo, return error return-value
      :
        find last buf_aht-stk-line no-lock
          where buf_aht-stk-line.obj-type   = p-obj-type
            and buf_aht-stk-line.obj-code   = p-obj-code
            and buf_aht-stk-line.gds-code   = buf_temp-aht-stk-line.temp-gds-code
            and buf_aht-stk-line.sum-type   = buf_temp-aht-stk-line.temp-sum-type
          use-index category
          no-error .
        if (available buf_aht-stk-line
            and buf_temp-aht-stk-line.temp-fact-qnty <> buf_aht-stk-line.fact-qnty
           )
        or (not available buf_aht-stk-line
            and buf_temp-aht-stk-line.temp-fact-qnty <> 0
           )
        then do:
          assign
            v-total-err = v-total-err + 1
          .

          run cur-time in this-procedure
            (output v-today
            ,output v-time
            ) .
          run update-last-date in this-procedure
            (input v-today
            ) .

          output stream sout to value(v-log-err-file) append .
          export stream sout '***':u string(v-today, '99/99/9999':u) string(v-time, 'HH:MM:SS':u) .
          export stream sout "error-05: gds-obj aht-stk-line different fact-qnty" .
          export stream sout "obj-type"  p-obj-type                            .
          export stream sout "obj-code"  p-obj-code                            .
          export stream sout "fact-date" v-today                               .
          export stream sout "gds-code"  buf_temp-aht-stk-line.temp-gds-code   .
          export stream sout "sum-type"  buf_temp-aht-stk-line.temp-sum-type   .
          export stream sout "parts.fact-qnty" buf_temp-aht-stk-line.temp-fact-qnty .
          if available buf_aht-stk-line
          then do:
            export stream sout "aht-stk-line.fact-qnty" buf_aht-stk-line.fact-qnty .
          end.
          output stream sout close .
        end.
      end.
    end.
  end.

end procedure. /* validate-free-zone */


procedure update-last-date :

  define input  parameter p-update-date as date      no-undo .

  do
  on error undo, return error return-value
  :
    if p-last-date = ?
    or p-last-date < p-update-date
    then do:
      assign
        p-last-date = p-update-date
      .
    end.
  end.

end procedure. /* update-last-date */


procedure clear-temp-aht-stk-line :

  define buffer buf_temp-aht-stk-line for temp-aht-stk-line .

  do
  on error undo, return error return-value
  :

    for each buf_temp-aht-stk-line
    on error undo, return error return-value
    :
      delete buf_temp-aht-stk-line .
    end.
  end.

end procedure. /* clear-temp-aht-stk-line */


procedure check-fact-order :

  define buffer buf_aht-stk-line for ub.aht-stk-line .

  define variable v-ind as integer   no-undo .

  do
  on error undo, return error return-value
  :
    /* просматриваем все линии остатков и проверяем правильность fact-order */
    for each buf_aht-stk-line no-lock
      where buf_aht-stk-line.obj-type = p-obj-type
        and buf_aht-stk-line.obj-code = p-obj-code
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Проверка 02. Ошибок &1. Объект &2 &3. Записей &4."
                          ,v-total-err
                          ,p-obj-type
                          ,p-obj-code
                          ,v-ind
                          )
          ).
      end.

      define variable v-factord-date as date      no-undo .

      run factord-to-date in this-procedure
        (input  buf_aht-stk-line.fact-order
        ,output v-factord-date
        ) .

      if truncate(buf_aht-stk-line.fact-order, 2) <> buf_aht-stk-line.fact-order
      then do:
        assign
          v-total-err = v-total-err + 1
        .

        run update-last-date in this-procedure
          (input v-factord-date
          ) .

        output stream sout to value(v-log-err-file) append .
        export stream sout '***':u string(v-today, '99/99/9999':u) string(v-time, 'HH:MM:SS':u) .
        export stream sout "error-06: fact-order"                .
        export stream sout "obj-type"    buf_aht-stk-line.obj-type   .
        export stream sout "obj-code"    buf_aht-stk-line.obj-code   .
        export stream sout "gds-code"    buf_aht-stk-line.gds-code   .
        export stream sout "fact-order"  buf_aht-stk-line.fact-order .
        export stream sout "sum-type"    buf_aht-stk-line.sum-type   .
        export stream sout "v-factord-date" v-factord-date .
        export stream sout "aht-stk-line" .
        export stream sout buf_aht-stk-line .
        output stream sout close .
      end.
    end.
  end.

end procedure. /* check-fact-order */


procedure fill-temp-aht-stk-line :

  define buffer buf_aht-stk-line for ub.aht-stk-line .
  define buffer buf_temp-aht-stk-line for temp-aht-stk-line .
  define buffer buf_temp-gds for temp-gds .

  define variable v-ind as integer   no-undo .

  do
  on error undo, return error return-value
  :
    /* просматриваем все линии остатков и получаем информацию о самом последнем остатке */
    for each buf_aht-stk-line no-lock
      where buf_aht-stk-line.obj-type = p-obj-type
        and buf_aht-stk-line.obj-code = p-obj-code
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Проверка остатков 02. Ошибок &1. Объект &2 &3. Записей &4."
                          ,v-total-err
                          ,p-obj-type
                          ,p-obj-code
                          ,v-ind
                          )
          ).
      end.

      find first buf_temp-aht-stk-line
        where buf_temp-aht-stk-line.temp-gds-code = buf_aht-stk-line.gds-code
          and buf_temp-aht-stk-line.temp-sum-type = buf_aht-stk-line.sum-type
        no-error .
      if not available buf_temp-aht-stk-line
      then do:
        create buf_temp-aht-stk-line .

        assign
          buf_temp-aht-stk-line.temp-gds-code   = buf_aht-stk-line.gds-code
          buf_temp-aht-stk-line.temp-sum-type   = buf_aht-stk-line.sum-type
          buf_temp-aht-stk-line.temp-fact-qnty  = buf_aht-stk-line.fact-qnty
          buf_temp-aht-stk-line.temp-fact-order = buf_aht-stk-line.fact-order
        .
      end.

      if buf_temp-aht-stk-line.temp-fact-order < buf_aht-stk-line.fact-order
      then do:
        assign
          buf_temp-aht-stk-line.temp-fact-qnty  = buf_aht-stk-line.fact-qnty
          buf_temp-aht-stk-line.temp-fact-order = buf_aht-stk-line.fact-order
        .
      end.

      find first buf_temp-gds
        where buf_temp-gds.temp-gds-code = buf_aht-stk-line.gds-code
        no-error .
      if not available buf_temp-gds
      then do:
        create buf_temp-gds .

        assign
          buf_temp-gds.temp-gds-code = buf_aht-stk-line.gds-code
        .
      end.
    end.
  end.

end procedure. /* fill-temp-aht-stk-line */


procedure check-free-zone-from-aht-stk-line :

  define buffer buf_lock_gds-obj for ub.gds-obj .
  define buffer buf_temp-gds for temp-gds .
  define buffer buf_temp-aht-stk-line for temp-aht-stk-line .
  define buffer buf_temp-parts for temp-parts .
  define buffer buf_goods for ub.goods .

  define variable v-ind as integer   no-undo .

  do
  on error undo, return error return-value
  :
    for each buf_temp-gds
    on error undo, return error return-value
    :
      find first buf_goods no-lock
        where buf_goods.gds-code = buf_temp-gds.temp-gds-code
        no-error .
      if not available buf_goods
      then do:
        /* todo - ошибка */
        undo, next .
      end.

      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Проверка остатков 03. Ошибок &1. Объект &2 &3. Код товара &4."
                          ,v-total-err
                          ,p-obj-type
                          ,p-obj-code
                          ,buf_temp-gds.temp-gds-code
                          )
          ).
      end.

      do transaction
      on error undo, return error return-value
      :
        find buf_lock_gds-obj exclusive-lock
          where buf_lock_gds-obj.obj-type  = p-obj-type
            and buf_lock_gds-obj.obj-code  = p-obj-code
            and buf_lock_gds-obj.artic     = buf_goods.artic
            and buf_lock_gds-obj.prod-type = buf_goods.prod-type
            and buf_lock_gds-obj.prod-code = buf_goods.prod-code
          no-error .
        if not available buf_lock_gds-obj
        then do:
          assign
            v-total-err = v-total-err + 1
          .

          run cur-time in this-procedure
            (output v-today
            ,output v-time
            ) .
          run update-last-date in this-procedure
            (input v-today
            ) .

          output stream sout to value(v-log-err-file) append .
          export stream sout '***':u string(v-today, '99/99/9999':u) string(v-time, 'HH:MM:SS':u) .
          export stream sout "error-07: gds-obj not found"   .
          export stream sout "obj-type"  p-obj-type          .
          export stream sout "obj-code"  p-obj-code          .
          export stream sout "artic"     buf_goods.artic     .
          export stream sout "prod-type" buf_goods.prod-type .
          export stream sout "prod-code" buf_goods.prod-code .
          output stream sout close .
        end.
        else do:
          run partslib-init-temp-parts in this-procedure
            (input  p-obj-type          /* p-obj-type  */
            ,input  p-obj-code          /* p-obj-code  */
            ,input  buf_goods.artic     /* p-artic     */
            ,input  buf_goods.prod-type /* p-prod-type */
            ,input  buf_goods.prod-code /* p-prod-code */
            ) .
        end.
      end.

      define variable v-sum-type as character no-undo .

      for each buf_temp-parts
      on error undo, return error return-value
      :
        case buf_temp-parts.purch-code
        :
          when {&bef-repayment-code}
          then do:
            assign
              v-sum-type = {&aht-repayment}
            .
          end.
          when {&bef-consignation-code}
          then do:
            assign
              v-sum-type = {&aht-cons_acc}
            .
          end.
          when {&bef-responsible-storage-code}
          then do:
            assign
              v-sum-type = {&aht-resp_stor}
            .
          end.
          when {&bef-old-consignation-code}
          then do:
            assign
              v-sum-type = {&aht-old_cons}
            .
          end.
          otherwise do:
            /* todo - неизвестный тип приобретения */
          end.
        end.

        find first buf_temp-aht-stk-line
          where buf_temp-aht-stk-line.temp-gds-code = buf_temp-gds.temp-gds-code
            and buf_temp-aht-stk-line.temp-sum-type = v-sum-type
          no-error .
        if not available buf_temp-aht-stk-line
        then do:
          create buf_temp-aht-stk-line .
          assign
            buf_temp-aht-stk-line.temp-gds-code = buf_temp-gds.temp-gds-code
            buf_temp-aht-stk-line.temp-sum-type = v-sum-type
          .
        end.

        assign
          buf_temp-aht-stk-line.temp-gds-qnty = buf_temp-aht-stk-line.temp-gds-qnty
                                              + buf_temp-parts.fact-qnty
        .

        if v-sum-type = {&aht-cons_acc}
        then do:
          find first buf_temp-aht-stk-line
            where buf_temp-aht-stk-line.temp-gds-code = buf_temp-gds.temp-gds-code
              and buf_temp-aht-stk-line.temp-sum-type = {&aht-cons_benf}
            no-error .
          if not available buf_temp-aht-stk-line
          then do:
            create buf_temp-aht-stk-line .
            assign
              buf_temp-aht-stk-line.temp-gds-code = buf_temp-gds.temp-gds-code
              buf_temp-aht-stk-line.temp-sum-type = {&aht-cons_benf}
            .
          end.

          assign
            buf_temp-aht-stk-line.temp-gds-qnty = buf_temp-aht-stk-line.temp-gds-qnty
                                                + buf_temp-parts.fact-qnty
          .
        end.
      end.
    end.

    for each buf_temp-aht-stk-line
      where length(buf_temp-aht-stk-line.temp-sum-type) = 1
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Проверка остатков 04. Ошибок &1. Объект &2 &3. Записей &4."
                          ,v-total-err
                          ,p-obj-type
                          ,p-obj-code
                          ,v-ind
                          )
          ).
      end.

      if buf_temp-aht-stk-line.temp-fact-qnty <> buf_temp-aht-stk-line.temp-gds-qnty
      then do:
        assign
          v-total-err = v-total-err + 1
        .

        run cur-time in this-procedure
          (output v-today
          ,output v-time
          ) .
        run update-last-date in this-procedure
          (input v-today
          ) .
        output stream sout to value(v-log-err-file) append .
        export stream sout '***':u string(v-today, '99/99/9999':u) string(v-time, 'HH:MM:SS':u) .
        export stream sout "error-08: gds-obj aht-stk-line different fact-qnty" .
        export stream sout "obj-type"  p-obj-type                            .
        export stream sout "obj-code"  p-obj-code                            .
        export stream sout "fact-date" v-today                               .
        export stream sout "gds-code"  buf_temp-aht-stk-line.temp-gds-code   .
        export stream sout "sum-type"  buf_temp-aht-stk-line.temp-sum-type   .
        export stream sout "aht-stk-line.fact-qnty" buf_temp-aht-stk-line.temp-fact-qnty .
        export stream sout "parts.fact-qnty" buf_temp-aht-stk-line.temp-gds-qnty .
        output stream sout close .
      end.
    end.
  end.

end procedure. /* check-free-zone-from-aht-stk-line */