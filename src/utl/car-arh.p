block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: car-arh.p $
$Archive: utl/car-arh.p $

Программа проверки складского архива по товарам

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 03/24/04

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
define variable vss-workfile    as character no-undo initial "$Workfile: car-arh.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: utl/car-arh.p $":U .
define variable vss-description as character no-undo initial "Программа проверки складского архива по товарам".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ gbl/waitfram.i }
{ trg/factord.i  }
{ gbl/clntattr.i }
{ trg/partslib.i }

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

define temp-table temp-ot-day no-undo
  field temp-gds-code       as integer
  field temp-artic          as character
  field temp-prod-type      as character
  field temp-prod-code      as integer
  field temp-sum-type       as character
  field temp-cat-id         as character
  field temp-fact-qnty      as decimal
  field temp-sum-base       as decimal
  field temp-sum-rubl       as decimal
  field temp-VAT-base       as decimal
  field temp-VAT-rubl       as decimal
  field temp-SLT-base       as decimal
  field temp-SLT-rubl       as decimal
  field temp-road-tax-base  as decimal
  field temp-road-tax-rubl  as decimal
  field temp-excise-base    as decimal
  field temp-excise-rubl    as decimal
  field temp-transport-base as decimal
  field temp-transport-rubl as decimal
  field temp-other-base     as decimal
  field temp-other-rubl     as decimal
  index xpk is primary unique
    temp-artic
    temp-prod-type
    temp-prod-code
    temp-sum-type
    temp-cat-id
  index xie temp-sum-type temp-cat-id
    .

define temp-table temp-stk-line no-undo
  field temp-artic          as character
  field temp-prod-type      as character
  field temp-prod-code      as integer
  field temp-fact-order     as decimal
  field temp-gds-qnty       as decimal
  field temp-fact-qnty      as decimal
  index xpk is primary unique
    temp-artic
    temp-prod-type
    temp-prod-code
    .

define temp-table temp-gds no-undo
  field temp-artic      as character
  field temp-prod-type  as character
  field temp-prod-code  as integer
  index xpk is primary unique
    temp-artic
    temp-prod-type
    temp-prod-code
    .

do
on error undo, return error return-value
:
  assign
    v-log-err-file = substitute('car-arh-&1-&2.err':U
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

  run clear-temp-ot-day in this-procedure .

  /* проверяем соответствие остатков текущей свободной зоне */
  /* free-zone -> stk-line */
  run validate-free-zone in this-procedure .

  /* проверяем соответствие текущей свободной зоны остатка */
  /* stk-line -> free-zone */
  run clear-temp-stk-line in this-procedure .

  run check-fact-order in this-procedure .

  run fill-temp-stk-line in this-procedure .

  run check-free-zone-from-stk-line in this-procedure .

  run check-sub-type-stk-line in this-procedure .

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
  define variable v-arh-detail-date     as date      no-undo .
  define variable v-fact-ord-begin-aht  as decimal   no-undo .
  define variable v-fact-date           as date      no-undo .
  define variable v-fact-ord-begin-day  as decimal   no-undo .
  define variable v-fact-ord-end-day    as decimal   no-undo .

  define buffer buf_temp-date for temp-date .
  define buffer buf_ot-line for ub.ot-line .
  define buffer buf_stk-line for ub.stk-line .

  do
  on error undo, return error return-value
  :

    /* сначала определяем начало подробного складского архива по товарам */
    /* проверка целостности рассчитана только на проверку подробного складского архива */
    run clntattr-value in this-procedure
      (input  p-obj-type               /* p-obj-type */
      ,input  p-obj-code               /* p-obj-code */
      ,input  {&attr-arh-detail-date}  /* p-code     */
      ,output v-attr-value             /* p-value    */
      ,output v-attr-type              /* p-type     */
      ) .
    assign
      v-arh-detail-date = date(v-attr-value)
    .

    if v-arh-detail-date <> ?
    then do:
      run day-begin-fact-order in this-procedure
        (input  v-arh-detail-date    /* p-fact-date            */
        ,output v-fact-ord-begin-aht /* p-day-begin-fact-order */
        ) .
    end.
    else do:
      assign
        v-fact-ord-begin-aht = 0
      .
    end.

    /* составляем список дат, за которые имеется складской архив по товарам */
    /* на основании записей арихва по товарам - оборот*/
    find first buf_ot-line no-lock
      where buf_ot-line.obj-type   = p-obj-type
        and buf_ot-line.obj-code   = p-obj-code
        and buf_ot-line.fact-order > v-fact-ord-begin-aht
      use-index fact-order
      no-error .
    do while available buf_ot-line
    :
      run factord-to-date in this-procedure
        (input  buf_ot-line.fact-order /* p-fact-order */
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

      find first buf_ot-line no-lock
        where buf_ot-line.obj-type   = p-obj-type
          and buf_ot-line.obj-code   = p-obj-code
          and buf_ot-line.fact-order > v-fact-ord-end-day
        use-index fact-order
        no-error .
    end.

    /* составляем список дат за которые имеется складской архив по товарам */
    /* на основании записей остатков */
    find first buf_stk-line no-lock
      where buf_stk-line.obj-type   = p-obj-type
        and buf_stk-line.obj-code   = p-obj-code
        and buf_stk-line.fact-order > v-fact-ord-begin-aht
      use-index fact-order
      no-error .
    do while available buf_stk-line
    :
      run factord-to-date in this-procedure
        (input  buf_stk-line.fact-order /* p-fact-order */
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

      find first buf_stk-line no-lock
        where buf_stk-line.obj-type   = p-obj-type
          and buf_stk-line.obj-code   = p-obj-code
          and buf_stk-line.fact-order > v-fact-ord-end-day
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
    define variable v-arh-detail-date as date      no-undo .
    define variable v-attr-value      as character no-undo .
    define variable v-attr-type       as character no-undo .

    /* сначала определяем начало подробного складского архива по товарам */
    /* в случае если складской архив был рассчитан с определенной даты */
    /* следует пропустить первый день при проверке накопительного складского архива */

    run clntattr-value in this-procedure
      (input  p-obj-type               /* p-obj-type */
      ,input  p-obj-code               /* p-obj-code */
      ,input  {&attr-arh-detail-date}  /* p-code     */
      ,output v-attr-value             /* p-value    */
      ,output v-attr-type              /* p-type     */
      ) .
    assign
      v-arh-detail-date = date(v-attr-value)
    .

    for each buf_temp-date
    on error undo, return error return-value
    :
      run waitfram-show in this-procedure
        (input substitute("Анализ складского архива по товарам. Ошибок &1. Объект &2 &3. Дата &4."
                        ,v-total-err
                        ,p-obj-type
                        ,p-obj-code
                        ,string(buf_temp-date.arch-date, '99/99/9999':u)
                        )
        ).
      run clear-temp-ot-day in this-procedure .

      run fill-temp-ot-day in this-procedure
        (input  buf_temp-date.arch-date          /* p-fact-date            */
        ,input  buf_temp-date.fact-ord-begin-day /* p-fact-order-begin-day */
        ,input  buf_temp-date.fact-ord-end-day   /* p-fact-order-end-day   */
        ) .

      run validate-ot-line-stk in this-procedure
        (input  buf_temp-date.arch-date          /* p-fact-date            */
        ,input  buf_temp-date.fact-ord-begin-day /* p-fact-order-begin-day */
        ,input  buf_temp-date.fact-ord-end-day   /* p-fact-order-end-day   */
        ) .

      if v-arh-detail-date = ?
      or (v-arh-detail-date <> ?
          and buf_temp-date.arch-date >= v-arh-detail-date
         )
      then do:
        run validate-stk-line in this-procedure
          (input buf_temp-date.arch-date          /* p-fact-date            */
          ,input buf_temp-date.fact-ord-begin-day /* p-fact-order-begin-day */
          ,input buf_temp-date.fact-ord-end-day   /* p-fact-order-end-day   */
          ) .
      end.
    end.
  end.

end procedure. /* check-temp-date */


procedure validate-ot-line-stk :

  define input  parameter p-fact-date            as date      no-undo .
  define input  parameter p-fact-order-begin-day as decimal   no-undo .
  define input  parameter p-fact-order-end-day   as decimal   no-undo .

  define variable v-fact-qnty      as decimal   no-undo .
  define variable v-sum-base       as decimal   no-undo .
  define variable v-sum-rubl       as decimal   no-undo .
  define variable v-VAT-base       as decimal   no-undo .
  define variable v-VAT-rubl       as decimal   no-undo .
  define variable v-SLT-base       as decimal   no-undo .
  define variable v-SLT-rubl       as decimal   no-undo .
  define variable v-road-tax-base  as decimal   no-undo .
  define variable v-road-tax-rubl  as decimal   no-undo .
  define variable v-excise-base    as decimal   no-undo .
  define variable v-excise-rubl    as decimal   no-undo .
  define variable v-transport-base as decimal   no-undo .
  define variable v-transport-rubl as decimal   no-undo .
  define variable v-other-base     as decimal   no-undo .
  define variable v-other-rubl     as decimal   no-undo .

  define buffer buf_stk-line    for ub.stk-line .
  define buffer buf_temp-ot-day for temp-ot-day .

  do
  on error undo, return error return-value
  :
    for each buf_temp-ot-day
    on error undo, return error return-value
    :
      if buf_temp-ot-day.temp-sum-type begins {&arh-cost}
      or buf_temp-ot-day.temp-sum-type begins {&arh-csdt}
      or buf_temp-ot-day.temp-sum-type begins {&arh-sadt}
      then do:
        if buf_temp-ot-day.temp-sum-type begins {&arh-cost}
        then do:
          find last buf_stk-line no-lock
            where buf_stk-line.obj-type   = p-obj-type
              and buf_stk-line.obj-code   = p-obj-code
              and buf_stk-line.artic      = buf_temp-ot-day.temp-artic
              and buf_stk-line.prod-type  = buf_temp-ot-day.temp-prod-type
              and buf_stk-line.prod-code  = buf_temp-ot-day.temp-prod-code
              and buf_stk-line.sum-type   = {&arh-cost}
              and buf_stk-line.cat-id     = {&root-cat-id}
              and buf_stk-line.fact-order < p-fact-order-begin-day
              and buf_stk-line.shift-date = ?
            use-index category
            no-error .
          if  available buf_stk-line
          and buf_temp-ot-day.temp-sum-type <> {&arh-cost}
          then do:
            /* таким образом учитывается факт, что нулевые подчиненные записи */
            /* в базе данных не хранятся */
            define variable v-sub-fact-order as decimal   no-undo .
            assign
              v-sub-fact-order = buf_stk-line.fact-order
            .

            find last buf_stk-line no-lock
              where buf_stk-line.obj-type   = p-obj-type
                and buf_stk-line.obj-code   = p-obj-code
                and buf_stk-line.artic      = buf_temp-ot-day.temp-artic
                and buf_stk-line.prod-type  = buf_temp-ot-day.temp-prod-type
                and buf_stk-line.prod-code  = buf_temp-ot-day.temp-prod-code
                and buf_stk-line.sum-type   = buf_temp-ot-day.temp-sum-type
                and buf_stk-line.cat-id     = buf_temp-ot-day.temp-cat-id
                and buf_stk-line.fact-order = v-sub-fact-order
                and buf_stk-line.shift-date = ?
              use-index category
              no-error .
          end.
        end.
        else do:
          find last buf_stk-line no-lock
            where buf_stk-line.obj-type   = p-obj-type
              and buf_stk-line.obj-code   = p-obj-code
              and buf_stk-line.artic      = buf_temp-ot-day.temp-artic
              and buf_stk-line.prod-type  = buf_temp-ot-day.temp-prod-type
              and buf_stk-line.prod-code  = buf_temp-ot-day.temp-prod-code
              and buf_stk-line.sum-type   = buf_temp-ot-day.temp-sum-type
              and buf_stk-line.cat-id     = buf_temp-ot-day.temp-cat-id
              and buf_stk-line.fact-order < p-fact-order-begin-day
              and buf_stk-line.shift-date = ?
            use-index category
            no-error .
        end.

        if available buf_stk-line
        then do:
          assign
            v-fact-qnty      = - buf_stk-line.fact-qnty
            v-sum-base       = - buf_stk-line.sum-base
            v-sum-rubl       = - buf_stk-line.sum-rubl
            v-VAT-base       = - buf_stk-line.VAT-base
            v-VAT-rubl       = - buf_stk-line.VAT-rubl
            v-SLT-base       = - buf_stk-line.SLT-base
            v-SLT-rubl       = - buf_stk-line.SLT-rubl
            v-road-tax-base  = - buf_stk-line.road-tax-base
            v-road-tax-rubl  = - buf_stk-line.road-tax-rubl
            v-excise-base    = - buf_stk-line.excise-base
            v-excise-rubl    = - buf_stk-line.excise-rubl
            v-transport-base = - buf_stk-line.transport-base
            v-transport-rubl = - buf_stk-line.transport-rubl
            v-other-base     = - buf_stk-line.other-base
            v-other-rubl     = - buf_stk-line.other-rubl
          .
        end.
        else do:
          assign
            v-fact-qnty      = 0
            v-sum-base       = 0
            v-sum-rubl       = 0
            v-VAT-base       = 0
            v-VAT-rubl       = 0
            v-SLT-base       = 0
            v-SLT-rubl       = 0
            v-road-tax-base  = 0
            v-road-tax-rubl  = 0
            v-excise-base    = 0
            v-excise-rubl    = 0
            v-transport-base = 0
            v-transport-rubl = 0
            v-other-base     = 0
            v-other-rubl     = 0
          .
        end.

        assign
          v-fact-qnty      = v-fact-qnty      - buf_temp-ot-day.temp-fact-qnty
          v-sum-base       = v-sum-base       - buf_temp-ot-day.temp-sum-base
          v-sum-rubl       = v-sum-rubl       - buf_temp-ot-day.temp-sum-rubl
          v-VAT-base       = v-VAT-base       - buf_temp-ot-day.temp-VAT-base
          v-VAT-rubl       = v-VAT-rubl       - buf_temp-ot-day.temp-VAT-rubl
          v-SLT-base       = v-SLT-base       - buf_temp-ot-day.temp-SLT-base
          v-SLT-rubl       = v-SLT-rubl       - buf_temp-ot-day.temp-SLT-rubl
          v-road-tax-base  = v-road-tax-base  - buf_temp-ot-day.temp-road-tax-base
          v-road-tax-rubl  = v-road-tax-rubl  - buf_temp-ot-day.temp-road-tax-rubl
          v-excise-base    = v-excise-base    - buf_temp-ot-day.temp-excise-base
          v-excise-rubl    = v-excise-rubl    - buf_temp-ot-day.temp-excise-rubl
          v-transport-base = v-transport-base - buf_temp-ot-day.temp-transport-base
          v-transport-rubl = v-transport-rubl - buf_temp-ot-day.temp-transport-rubl
          v-other-base     = v-other-base     - buf_temp-ot-day.temp-other-base
          v-other-rubl     = v-other-rubl     - buf_temp-ot-day.temp-other-rubl
        .

        /* в течение дня были операции */
        /* должен быть остаток на конец дня */
        find first buf_stk-line no-lock
          where buf_stk-line.obj-type   = p-obj-type
            and buf_stk-line.obj-code   = p-obj-code
            and buf_stk-line.artic      = buf_temp-ot-day.temp-artic
            and buf_stk-line.prod-type  = buf_temp-ot-day.temp-prod-type
            and buf_stk-line.prod-code  = buf_temp-ot-day.temp-prod-code
            and buf_stk-line.sum-type   = buf_temp-ot-day.temp-sum-type
            and buf_stk-line.cat-id     = buf_temp-ot-day.temp-cat-id
            and buf_stk-line.fact-order = p-fact-order-end-day
          use-index category
          no-error .
        if available buf_stk-line
        then do:
          assign
            v-fact-qnty      = v-fact-qnty      + buf_stk-line.fact-qnty
            v-sum-base       = v-sum-base       + buf_stk-line.sum-base
            v-sum-rubl       = v-sum-rubl       + buf_stk-line.sum-rubl
            v-VAT-base       = v-VAT-base       + buf_stk-line.VAT-base
            v-VAT-rubl       = v-VAT-rubl       + buf_stk-line.VAT-rubl
            v-SLT-base       = v-SLT-base       + buf_stk-line.SLT-base
            v-SLT-rubl       = v-SLT-rubl       + buf_stk-line.SLT-rubl
            v-road-tax-base  = v-road-tax-base  + buf_stk-line.road-tax-base
            v-road-tax-rubl  = v-road-tax-rubl  + buf_stk-line.road-tax-rubl
            v-excise-base    = v-excise-base    + buf_stk-line.excise-base
            v-excise-rubl    = v-excise-rubl    + buf_stk-line.excise-rubl
            v-transport-base = v-transport-base + buf_stk-line.transport-base
            v-transport-rubl = v-transport-rubl + buf_stk-line.transport-rubl
            v-other-base     = v-other-base     + buf_stk-line.other-base
            v-other-rubl     = v-other-rubl     + buf_stk-line.other-rubl
          .
        end.
        else do:
          /* должен быть остаток на конец дня, кроме */
          /* случая, когда его быть не должно */
          if  buf_temp-ot-day.temp-sum-type begins {&arh-cost}
          and buf_temp-ot-day.temp-sum-type <>     {&arh-cost}
          and v-fact-qnty       = 0
          and v-sum-base        = 0
          and v-sum-rubl        = 0
          and v-VAT-base        = 0
          and v-VAT-rubl        = 0
          and v-SLT-base        = 0
          and v-SLT-rubl        = 0
          and v-road-tax-base   = 0
          and v-road-tax-rubl   = 0
          and v-excise-base     = 0
          and v-excise-rubl     = 0
          and v-transport-base  = 0
          and v-transport-rubl  = 0
          and v-other-base      = 0
          and v-other-rubl      = 0
          then do:
            /* может отсутствовать только подчиненная запись, */
            /* если все количества равны нулю */
          end.
          else do:
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
            export stream sout "error-01: stk-line not found" .
            export stream sout "obj-type"       p-obj-type                     .
            export stream sout "obj-code"       p-obj-code                     .
            export stream sout "fact-date"      p-fact-date                    .
            export stream sout "artic"          buf_temp-ot-day.temp-artic     .
            export stream sout "prod-type"      buf_temp-ot-day.temp-prod-type .
            export stream sout "prod-code"      buf_temp-ot-day.temp-prod-code .
            export stream sout "sum-type"       buf_temp-ot-day.temp-sum-type  .
            export stream sout "cat-id"         buf_temp-ot-day.temp-cat-id    .
            export stream sout "fact-order"     p-fact-order-end-day           .
            export stream sout "fact-qnty"      v-fact-qnty                    .
            export stream sout "sum-base"       v-sum-base                     .
            export stream sout "sum-rubl"       v-sum-rubl                     .
            export stream sout "VAT-base"       v-VAT-base                     .
            export stream sout "VAT-rubl"       v-VAT-rubl                     .
            export stream sout "SLT-base"       v-SLT-base                     .
            export stream sout "SLT-rubl"       v-SLT-rubl                     .
            export stream sout "road-tax-base"  v-road-tax-base                .
            export stream sout "road-tax-rubl"  v-road-tax-rubl                .
            export stream sout "excise-base"    v-excise-base                  .
            export stream sout "excise-rubl"    v-excise-rubl                  .
            export stream sout "transport-base" v-transport-base               .
            export stream sout "transport-rubl" v-transport-rubl               .
            export stream sout "other-base"     v-other-base                   .
            export stream sout "other-rubl"     v-other-rubl                   .
            output stream sout close .

          end.
        end.

        if v-fact-qnty      <> 0
        or v-sum-base       <> 0
        or v-sum-rubl       <> 0
        or v-VAT-base       <> 0
        or v-VAT-rubl       <> 0
        or v-SLT-base       <> 0
        or v-SLT-rubl       <> 0
        or v-road-tax-base  <> 0
        or v-road-tax-rubl  <> 0
        or v-excise-base    <> 0
        or v-excise-rubl    <> 0
        or v-transport-base <> 0
        or v-transport-rubl <> 0
        or v-other-base     <> 0
        or v-other-rubl     <> 0
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
          export stream sout "error-02: stk-line different quantity" .
          export stream sout "obj-type"       p-obj-type                     .
          export stream sout "obj-code"       p-obj-code                     .
          export stream sout "fact-date"      p-fact-date                    .
          export stream sout "artic"          buf_temp-ot-day.temp-artic     .
          export stream sout "prod-type"      buf_temp-ot-day.temp-prod-type .
          export stream sout "prod-code"      buf_temp-ot-day.temp-prod-code .
          export stream sout "sum-type"       buf_temp-ot-day.temp-sum-type  .
          export stream sout "cat-id"         buf_temp-ot-day.temp-cat-id    .
          export stream sout "fact-order"     p-fact-order-end-day           .
          export stream sout "fact-qnty"      v-fact-qnty                    .
          export stream sout "sum-base"       v-sum-base                     .
          export stream sout "sum-rubl"       v-sum-rubl                     .
          export stream sout "VAT-base"       v-VAT-base                     .
          export stream sout "VAT-rubl"       v-VAT-rubl                     .
          export stream sout "SLT-base"       v-SLT-base                     .
          export stream sout "SLT-rubl"       v-SLT-rubl                     .
          export stream sout "road-tax-base"  v-road-tax-base                .
          export stream sout "road-tax-rubl"  v-road-tax-rubl                .
          export stream sout "excise-base"    v-excise-base                  .
          export stream sout "excise-rubl"    v-excise-rubl                  .
          export stream sout "transport-base" v-transport-base               .
          export stream sout "transport-rubl" v-transport-rubl               .
          export stream sout "other-base"     v-other-base                   .
          export stream sout "other-rubl"     v-other-rubl                   .
          output stream sout close .
        end.
      end.
    end.
  end.

end procedure. /* validate-ot-line-stk */


procedure clear-temp-ot-day :

  define buffer buf_temp-ot-day for temp-ot-day .

  do
  on error undo, return error return-value
  :
    for each buf_temp-ot-day
    on error undo, return error return-value
    :
      delete buf_temp-ot-day .
    end.
  end.

end procedure. /* clear-temp-ot-day */


procedure fill-temp-ot-day :

  define input  parameter p-fact-date            as date      no-undo .
  define input  parameter p-fact-order-begin-day as decimal   no-undo .
  define input  parameter p-fact-order-end-day   as decimal   no-undo .

  define buffer buf_temp-ot-day for temp-ot-day .
  define buffer buf_ot-line     for ub.ot-line .

  do
  on error undo, return error return-value
  :
    for each buf_ot-line no-lock
      where buf_ot-line.obj-type   = p-obj-type
        and buf_ot-line.obj-code   = p-obj-code
        and buf_ot-line.fact-order > p-fact-order-begin-day
        and buf_ot-line.fact-order < p-fact-order-end-day
    on error undo, return error return-value
    :
      /* оборот по документу */
      find first buf_temp-ot-day
        where buf_temp-ot-day.temp-artic     = buf_ot-line.artic
          and buf_temp-ot-day.temp-prod-type = buf_ot-line.prod-type
          and buf_temp-ot-day.temp-prod-code = buf_ot-line.prod-code
          and buf_temp-ot-day.temp-sum-type  = buf_ot-line.sum-type
          and buf_temp-ot-day.temp-cat-id    = buf_ot-line.cat-id
        no-error .
      if not available buf_temp-ot-day
      then do:
        create buf_temp-ot-day .
        assign
          buf_temp-ot-day.temp-artic     = buf_ot-line.artic
          buf_temp-ot-day.temp-prod-type = buf_ot-line.prod-type
          buf_temp-ot-day.temp-prod-code = buf_ot-line.prod-code
          buf_temp-ot-day.temp-sum-type  = buf_ot-line.sum-type
          buf_temp-ot-day.temp-cat-id    = buf_ot-line.cat-id
        .
      end.

      assign
        buf_temp-ot-day.temp-fact-qnty      = buf_temp-ot-day.temp-fact-qnty
                                            + buf_ot-line.fact-qnty
        buf_temp-ot-day.temp-sum-base       = buf_temp-ot-day.temp-sum-base
                                            + buf_ot-line.sum-base
        buf_temp-ot-day.temp-sum-rubl       = buf_temp-ot-day.temp-sum-rubl
                                            + buf_ot-line.sum-rubl
        buf_temp-ot-day.temp-VAT-base       = buf_temp-ot-day.temp-VAT-base
                                            + buf_ot-line.VAT-base
        buf_temp-ot-day.temp-VAT-rubl       = buf_temp-ot-day.temp-VAT-rubl
                                            + buf_ot-line.VAT-rubl
        buf_temp-ot-day.temp-SLT-base       = buf_temp-ot-day.temp-SLT-base
                                            + buf_ot-line.SLT-base
        buf_temp-ot-day.temp-SLT-rubl       = buf_temp-ot-day.temp-SLT-rubl
                                            + buf_ot-line.SLT-rubl
        buf_temp-ot-day.temp-road-tax-base  = buf_temp-ot-day.temp-road-tax-base
                                            + buf_ot-line.road-tax-base
        buf_temp-ot-day.temp-road-tax-rubl  = buf_temp-ot-day.temp-road-tax-rubl
                                            + buf_ot-line.road-tax-rubl
        buf_temp-ot-day.temp-excise-base    = buf_temp-ot-day.temp-excise-base
                                            + buf_ot-line.excise-base
        buf_temp-ot-day.temp-excise-rubl    = buf_temp-ot-day.temp-excise-rubl
                                            + buf_ot-line.excise-rubl
        buf_temp-ot-day.temp-transport-base = buf_temp-ot-day.temp-transport-base
                                            + buf_ot-line.transport-base
        buf_temp-ot-day.temp-transport-rubl = buf_temp-ot-day.temp-transport-rubl
                                            + buf_ot-line.transport-rubl
        buf_temp-ot-day.temp-other-base     = buf_temp-ot-day.temp-other-base
                                            + buf_ot-line.other-base
        buf_temp-ot-day.temp-other-rubl     = buf_temp-ot-day.temp-other-rubl
                                            + buf_ot-line.other-rubl
      .

      /* оборот для накопительного складского архива в учетных ценах */
      if buf_ot-line.sum-type = {&arh-cost}
      then do:
        find first buf_temp-ot-day
          where buf_temp-ot-day.temp-artic     = buf_ot-line.artic
            and buf_temp-ot-day.temp-prod-type = buf_ot-line.prod-type
            and buf_temp-ot-day.temp-prod-code = buf_ot-line.prod-code
            and buf_temp-ot-day.temp-sum-type  = {&arh-csdt} + buf_ot-line.ext-doc-type
            and buf_temp-ot-day.temp-cat-id    = {&root-cat-id}
          no-error .
        if not available buf_temp-ot-day
        then do:
          create buf_temp-ot-day .
          assign
            buf_temp-ot-day.temp-artic     = buf_ot-line.artic
            buf_temp-ot-day.temp-prod-type = buf_ot-line.prod-type
            buf_temp-ot-day.temp-prod-code = buf_ot-line.prod-code
            buf_temp-ot-day.temp-sum-type  = {&arh-csdt} + buf_ot-line.ext-doc-type
            buf_temp-ot-day.temp-cat-id    = {&root-cat-id}
          .
        end.

        assign
          buf_temp-ot-day.temp-fact-qnty      = buf_temp-ot-day.temp-fact-qnty
                                                   + buf_ot-line.fact-qnty
          buf_temp-ot-day.temp-sum-base       = buf_temp-ot-day.temp-sum-base
                                                   + buf_ot-line.sum-base
          buf_temp-ot-day.temp-sum-rubl       = buf_temp-ot-day.temp-sum-rubl
                                                   + buf_ot-line.sum-rubl
          buf_temp-ot-day.temp-VAT-base       = buf_temp-ot-day.temp-VAT-base
                                                   + buf_ot-line.VAT-base
          buf_temp-ot-day.temp-VAT-rubl       = buf_temp-ot-day.temp-VAT-rubl
                                                   + buf_ot-line.VAT-rubl
          buf_temp-ot-day.temp-SLT-base       = buf_temp-ot-day.temp-SLT-base
                                                   + buf_ot-line.SLT-base
          buf_temp-ot-day.temp-SLT-rubl       = buf_temp-ot-day.temp-SLT-rubl
                                                   + buf_ot-line.SLT-rubl
          buf_temp-ot-day.temp-road-tax-base  = buf_temp-ot-day.temp-road-tax-base
                                                   + buf_ot-line.road-tax-base
          buf_temp-ot-day.temp-road-tax-rubl  = buf_temp-ot-day.temp-road-tax-rubl
                                                   + buf_ot-line.road-tax-rubl
          buf_temp-ot-day.temp-excise-base    = buf_temp-ot-day.temp-excise-base
                                                   + buf_ot-line.excise-base
          buf_temp-ot-day.temp-excise-rubl    = buf_temp-ot-day.temp-excise-rubl
                                                   + buf_ot-line.excise-rubl
          buf_temp-ot-day.temp-transport-base = buf_temp-ot-day.temp-transport-base
                                                   + buf_ot-line.transport-base
          buf_temp-ot-day.temp-transport-rubl = buf_temp-ot-day.temp-transport-rubl
                                                   + buf_ot-line.transport-rubl
          buf_temp-ot-day.temp-other-base     = buf_temp-ot-day.temp-other-base
                                                   + buf_ot-line.other-base
          buf_temp-ot-day.temp-other-rubl     = buf_temp-ot-day.temp-other-rubl
                                                   + buf_ot-line.other-rubl
        .
      end.

      /* оборот для накопительного складского архива в ценах документа */
      if buf_ot-line.sum-type = {&arh-sale}
      then do:
        find first buf_temp-ot-day
          where buf_temp-ot-day.temp-artic     = buf_ot-line.artic
            and buf_temp-ot-day.temp-prod-type = buf_ot-line.prod-type
            and buf_temp-ot-day.temp-prod-code = buf_ot-line.prod-code
            and buf_temp-ot-day.temp-sum-type  = {&arh-sadt} + buf_ot-line.ext-doc-type
            and buf_temp-ot-day.temp-cat-id    = {&root-cat-id}
          no-error .
        if not available buf_temp-ot-day
        then do:
          create buf_temp-ot-day .
          assign
            buf_temp-ot-day.temp-artic     = buf_ot-line.artic
            buf_temp-ot-day.temp-prod-type = buf_ot-line.prod-type
            buf_temp-ot-day.temp-prod-code = buf_ot-line.prod-code
            buf_temp-ot-day.temp-sum-type  = {&arh-sadt} + buf_ot-line.ext-doc-type
            buf_temp-ot-day.temp-cat-id    = {&root-cat-id}
          .
        end.

        assign
          buf_temp-ot-day.temp-fact-qnty      = buf_temp-ot-day.temp-fact-qnty
                                                   + buf_ot-line.fact-qnty
          buf_temp-ot-day.temp-sum-base       = buf_temp-ot-day.temp-sum-base
                                                   + buf_ot-line.sum-base
          buf_temp-ot-day.temp-sum-rubl       = buf_temp-ot-day.temp-sum-rubl
                                                   + buf_ot-line.sum-rubl
          buf_temp-ot-day.temp-VAT-base       = buf_temp-ot-day.temp-VAT-base
                                                   + buf_ot-line.VAT-base
          buf_temp-ot-day.temp-VAT-rubl       = buf_temp-ot-day.temp-VAT-rubl
                                                   + buf_ot-line.VAT-rubl
          buf_temp-ot-day.temp-SLT-base       = buf_temp-ot-day.temp-SLT-base
                                                   + buf_ot-line.SLT-base
          buf_temp-ot-day.temp-SLT-rubl       = buf_temp-ot-day.temp-SLT-rubl
                                                   + buf_ot-line.SLT-rubl
          buf_temp-ot-day.temp-road-tax-base  = buf_temp-ot-day.temp-road-tax-base
                                                   + buf_ot-line.road-tax-base
          buf_temp-ot-day.temp-road-tax-rubl  = buf_temp-ot-day.temp-road-tax-rubl
                                                   + buf_ot-line.road-tax-rubl
          buf_temp-ot-day.temp-excise-base    = buf_temp-ot-day.temp-excise-base
                                                   + buf_ot-line.excise-base
          buf_temp-ot-day.temp-excise-rubl    = buf_temp-ot-day.temp-excise-rubl
                                                   + buf_ot-line.excise-rubl
          buf_temp-ot-day.temp-transport-base = buf_temp-ot-day.temp-transport-base
                                                   + buf_ot-line.transport-base
          buf_temp-ot-day.temp-transport-rubl = buf_temp-ot-day.temp-transport-rubl
                                                   + buf_ot-line.transport-rubl
          buf_temp-ot-day.temp-other-base     = buf_temp-ot-day.temp-other-base
                                                   + buf_ot-line.other-base
          buf_temp-ot-day.temp-other-rubl     = buf_temp-ot-day.temp-other-rubl
                                                   + buf_ot-line.other-rubl
        .
      end.
    end.
  end.

end procedure. /* fill-temp-ot-day */


procedure validate-stk-line :

  define input  parameter p-fact-date            as date      no-undo .
  define input  parameter p-fact-order-begin-day as decimal   no-undo .
  define input  parameter p-fact-order-end-day   as decimal   no-undo .

  define variable v-fact-qnty      as decimal   no-undo .
  define variable v-sum-base       as decimal   no-undo .
  define variable v-sum-rubl       as decimal   no-undo .
  define variable v-VAT-base       as decimal   no-undo .
  define variable v-VAT-rubl       as decimal   no-undo .
  define variable v-SLT-base       as decimal   no-undo .
  define variable v-SLT-rubl       as decimal   no-undo .
  define variable v-road-tax-base  as decimal   no-undo .
  define variable v-road-tax-rubl  as decimal   no-undo .
  define variable v-excise-base    as decimal   no-undo .
  define variable v-excise-rubl    as decimal   no-undo .
  define variable v-transport-base as decimal   no-undo .
  define variable v-transport-rubl as decimal   no-undo .
  define variable v-other-base     as decimal   no-undo .
  define variable v-other-rubl     as decimal   no-undo .

  define buffer buf_stk-line for ub.stk-line .
  define buffer buf_prev_stk-line for ub.stk-line .
  define buffer buf_temp-ot-day for temp-ot-day .

  do
  on error undo, return error return-value
  :
    for each buf_stk-line no-lock
      where buf_stk-line.obj-type   = p-obj-type
        and buf_stk-line.obj-code   = p-obj-code
        and buf_stk-line.fact-order = p-fact-order-end-day
    on error undo, return error return-value
    :
      if buf_stk-line.sum-type = {&arh-cost}
      then do:
        assign
          v-fact-qnty      = buf_stk-line.fact-qnty
          v-sum-base       = buf_stk-line.sum-base
          v-sum-rubl       = buf_stk-line.sum-rubl
          v-VAT-base       = buf_stk-line.VAT-base
          v-VAT-rubl       = buf_stk-line.VAT-rubl
          v-SLT-base       = buf_stk-line.SLT-base
          v-SLT-rubl       = buf_stk-line.SLT-rubl
          v-road-tax-base  = buf_stk-line.road-tax-base
          v-road-tax-rubl  = buf_stk-line.road-tax-rubl
          v-excise-base    = buf_stk-line.excise-base
          v-excise-rubl    = buf_stk-line.excise-rubl
          v-transport-base = buf_stk-line.transport-base
          v-transport-rubl = buf_stk-line.transport-rubl
          v-other-base     = buf_stk-line.other-base
          v-other-rubl     = buf_stk-line.other-rubl
        .

        find last buf_prev_stk-line no-lock
          where buf_prev_stk-line.obj-type   = buf_stk-line.obj-type
            and buf_prev_stk-line.obj-code   = buf_stk-line.obj-code
            and buf_prev_stk-line.artic      = buf_stk-line.artic
            and buf_prev_stk-line.prod-type  = buf_stk-line.prod-type
            and buf_prev_stk-line.prod-code  = buf_stk-line.prod-code
            and buf_prev_stk-line.sum-type   = {&arh-cost}
            and buf_prev_stk-line.cat-id     = {&root-cat-id}
            and buf_prev_stk-line.fact-order < p-fact-order-begin-day
            and buf_prev_stk-line.shift-date = ?
          use-index category
          no-error .
        if  available buf_prev_stk-line
        and buf_stk-line.sum-type <> {&arh-cost}
        then do:
          /* таким образом учитывается факт, что нулевые подчиненные записи */
          /* в базе данных не хранятся */
          define variable v-prev-fact-order as decimal   no-undo .
          assign
            v-prev-fact-order = buf_prev_stk-line.fact-order
          .

          find last buf_prev_stk-line no-lock
            where buf_prev_stk-line.obj-type   = buf_stk-line.obj-type
              and buf_prev_stk-line.obj-code   = buf_stk-line.obj-code
              and buf_prev_stk-line.artic      = buf_stk-line.artic
              and buf_prev_stk-line.prod-type  = buf_stk-line.prod-type
              and buf_prev_stk-line.prod-code  = buf_stk-line.prod-code
              and buf_prev_stk-line.sum-type   = buf_stk-line.sum-type
              and buf_prev_stk-line.cat-id     = buf_stk-line.cat-id
              and buf_prev_stk-line.fact-order = v-prev-fact-order
              and buf_prev_stk-line.shift-date = ?
            use-index category
            no-error .
        end.
        if available buf_prev_stk-line
        then do:
          assign
            v-fact-qnty      = v-fact-qnty      - buf_prev_stk-line.fact-qnty
            v-sum-base       = v-sum-base       - buf_prev_stk-line.sum-base
            v-sum-rubl       = v-sum-rubl       - buf_prev_stk-line.sum-rubl
            v-VAT-base       = v-VAT-base       - buf_prev_stk-line.VAT-base
            v-VAT-rubl       = v-VAT-rubl       - buf_prev_stk-line.VAT-rubl
            v-SLT-base       = v-SLT-base       - buf_prev_stk-line.SLT-base
            v-SLT-rubl       = v-SLT-rubl       - buf_prev_stk-line.SLT-rubl
            v-road-tax-base  = v-road-tax-base  - buf_prev_stk-line.road-tax-base
            v-road-tax-rubl  = v-road-tax-rubl  - buf_prev_stk-line.road-tax-rubl
            v-excise-base    = v-excise-base    - buf_prev_stk-line.excise-base
            v-excise-rubl    = v-excise-rubl    - buf_prev_stk-line.excise-rubl
            v-transport-base = v-transport-base - buf_prev_stk-line.transport-base
            v-transport-rubl = v-transport-rubl - buf_prev_stk-line.transport-rubl
            v-other-base     = v-other-base     - buf_prev_stk-line.other-base
            v-other-rubl     = v-other-rubl     - buf_prev_stk-line.other-rubl
          .
        end.

        find first buf_temp-ot-day
          where buf_temp-ot-day.temp-artic     = buf_stk-line.artic
            and buf_temp-ot-day.temp-prod-type = buf_stk-line.prod-type
            and buf_temp-ot-day.temp-prod-code = buf_stk-line.prod-code
            and buf_temp-ot-day.temp-sum-type  = buf_stk-line.sum-type
            and buf_temp-ot-day.temp-cat-id    = buf_stk-line.cat-id
          no-error .
        if available buf_temp-ot-day
        then do:
          assign
            v-fact-qnty      = v-fact-qnty      - buf_temp-ot-day.temp-fact-qnty
            v-sum-base       = v-sum-base       - buf_temp-ot-day.temp-sum-base
            v-sum-rubl       = v-sum-rubl       - buf_temp-ot-day.temp-sum-rubl
            v-VAT-base       = v-VAT-base       - buf_temp-ot-day.temp-VAT-base
            v-VAT-rubl       = v-VAT-rubl       - buf_temp-ot-day.temp-VAT-rubl
            v-SLT-base       = v-SLT-base       - buf_temp-ot-day.temp-SLT-base
            v-SLT-rubl       = v-SLT-rubl       - buf_temp-ot-day.temp-SLT-rubl
            v-road-tax-base  = v-road-tax-base  - buf_temp-ot-day.temp-road-tax-base
            v-road-tax-rubl  = v-road-tax-rubl  - buf_temp-ot-day.temp-road-tax-rubl
            v-excise-base    = v-excise-base    - buf_temp-ot-day.temp-excise-base
            v-excise-rubl    = v-excise-rubl    - buf_temp-ot-day.temp-excise-rubl
            v-transport-base = v-transport-base - buf_temp-ot-day.temp-transport-base
            v-transport-rubl = v-transport-rubl - buf_temp-ot-day.temp-transport-rubl
            v-other-base     = v-other-base     - buf_temp-ot-day.temp-other-base
            v-other-rubl     = v-other-rubl     - buf_temp-ot-day.temp-other-rubl
          .
        end.

        if v-fact-qnty      <> 0
        or v-sum-base       <> 0
        or v-sum-rubl       <> 0
        or v-VAT-base       <> 0
        or v-VAT-rubl       <> 0
        or v-SLT-base       <> 0
        or v-SLT-rubl       <> 0
        or v-road-tax-base  <> 0
        or v-road-tax-rubl  <> 0
        or v-excise-base    <> 0
        or v-excise-rubl    <> 0
        or v-transport-base <> 0
        or v-transport-rubl <> 0
        or v-other-base     <> 0
        or v-other-rubl     <> 0
        then do:
          assign
            v-total-err = v-total-err + 1
          .

          run cur-time in this-procedure
            (output v-today
            ,output v-time
            ) .
          run update-last-date in this-procedure
            (input buf_stk-line.fact-date
            ) .

          output stream sout to value(v-log-err-file) append .
          export stream sout '***':u string(v-today, '99/99/9999':u) string(v-time, 'HH:MM:SS':u) .
          export stream sout "error-03: stk-line record different quantity" .
          export stream sout "obj-type"       buf_stk-line.obj-type       .
          export stream sout "obj-code"       buf_stk-line.obj-code       .
          export stream sout "fact-date"      buf_stk-line.fact-date      .
          export stream sout "artic"          buf_stk-line.artic          .
          export stream sout "prod-type"      buf_stk-line.prod-type      .
          export stream sout "prod-code"      buf_stk-line.prod-code      .
          export stream sout "sum-type"       buf_stk-line.sum-type       .
          export stream sout "cat-id"         buf_stk-line.cat-id         .
          export stream sout "fact-order"     buf_stk-line.fact-order     .
          export stream sout "fact-qnty"      buf_stk-line.fact-qnty      .
          export stream sout "sum-base"       buf_stk-line.sum-base       .
          export stream sout "sum-rubl"       buf_stk-line.sum-rubl       .
          export stream sout "VAT-base"       buf_stk-line.VAT-base       .
          export stream sout "VAT-rubl"       buf_stk-line.VAT-rubl       .
          export stream sout "SLT-base"       buf_stk-line.SLT-base       .
          export stream sout "SLT-rubl"       buf_stk-line.SLT-rubl       .
          export stream sout "road-tax-base"  buf_stk-line.road-tax-base  .
          export stream sout "road-tax-rubl"  buf_stk-line.road-tax-rubl  .
          export stream sout "excise-base"    buf_stk-line.excise-base    .
          export stream sout "excise-rubl"    buf_stk-line.excise-rubl    .
          export stream sout "transport-base" buf_stk-line.transport-base .
          export stream sout "transport-rubl" buf_stk-line.transport-rubl .
          export stream sout "other-base"     buf_stk-line.other-base     .
          export stream sout "other-rubl"     buf_stk-line.other-rubl     .
          output stream sout close .
        end.
      end.

      if buf_stk-line.sum-type begins {&arh-sadt}
      then do:
        assign
          v-fact-qnty      = buf_stk-line.fact-qnty
          v-sum-base       = buf_stk-line.sum-base
          v-sum-rubl       = buf_stk-line.sum-rubl
          v-VAT-base       = buf_stk-line.VAT-base
          v-VAT-rubl       = buf_stk-line.VAT-rubl
          v-SLT-base       = buf_stk-line.SLT-base
          v-SLT-rubl       = buf_stk-line.SLT-rubl
          v-road-tax-base  = buf_stk-line.road-tax-base
          v-road-tax-rubl  = buf_stk-line.road-tax-rubl
          v-excise-base    = buf_stk-line.excise-base
          v-excise-rubl    = buf_stk-line.excise-rubl
          v-transport-base = buf_stk-line.transport-base
          v-transport-rubl = buf_stk-line.transport-rubl
          v-other-base     = buf_stk-line.other-base
          v-other-rubl     = buf_stk-line.other-rubl
        .

        find last buf_prev_stk-line no-lock
          where buf_prev_stk-line.obj-type   = buf_stk-line.obj-type
            and buf_prev_stk-line.obj-code   = buf_stk-line.obj-code
            and buf_prev_stk-line.artic      = buf_stk-line.artic
            and buf_prev_stk-line.prod-type  = buf_stk-line.prod-type
            and buf_prev_stk-line.prod-code  = buf_stk-line.prod-code
            and buf_prev_stk-line.sum-type   = buf_stk-line.sum-type
            and buf_prev_stk-line.cat-id     = buf_stk-line.cat-id
            and buf_prev_stk-line.fact-order < p-fact-order-begin-day
            and buf_prev_stk-line.shift-date = ?
          use-index category
          no-error .
        if available buf_prev_stk-line
        then do:
          assign
            v-fact-qnty      = v-fact-qnty      - buf_prev_stk-line.fact-qnty
            v-sum-base       = v-sum-base       - buf_prev_stk-line.sum-base
            v-sum-rubl       = v-sum-rubl       - buf_prev_stk-line.sum-rubl
            v-VAT-base       = v-VAT-base       - buf_prev_stk-line.VAT-base
            v-VAT-rubl       = v-VAT-rubl       - buf_prev_stk-line.VAT-rubl
            v-SLT-base       = v-SLT-base       - buf_prev_stk-line.SLT-base
            v-SLT-rubl       = v-SLT-rubl       - buf_prev_stk-line.SLT-rubl
            v-road-tax-base  = v-road-tax-base  - buf_prev_stk-line.road-tax-base
            v-road-tax-rubl  = v-road-tax-rubl  - buf_prev_stk-line.road-tax-rubl
            v-excise-base    = v-excise-base    - buf_prev_stk-line.excise-base
            v-excise-rubl    = v-excise-rubl    - buf_prev_stk-line.excise-rubl
            v-transport-base = v-transport-base - buf_prev_stk-line.transport-base
            v-transport-rubl = v-transport-rubl - buf_prev_stk-line.transport-rubl
            v-other-base     = v-other-base     - buf_prev_stk-line.other-base
            v-other-rubl     = v-other-rubl     - buf_prev_stk-line.other-rubl
          .
        end.

        find first buf_temp-ot-day
          where buf_temp-ot-day.temp-artic     = buf_stk-line.artic
            and buf_temp-ot-day.temp-prod-type = buf_stk-line.prod-type
            and buf_temp-ot-day.temp-prod-code = buf_stk-line.prod-code
            and buf_temp-ot-day.temp-sum-type  = buf_stk-line.sum-type
            and buf_temp-ot-day.temp-cat-id    = buf_stk-line.cat-id
          no-error .
        if available buf_temp-ot-day
        then do:
          assign
            v-fact-qnty      = v-fact-qnty      - buf_temp-ot-day.temp-fact-qnty
            v-sum-base       = v-sum-base       - buf_temp-ot-day.temp-sum-base
            v-sum-rubl       = v-sum-rubl       - buf_temp-ot-day.temp-sum-rubl
            v-VAT-base       = v-VAT-base       - buf_temp-ot-day.temp-VAT-base
            v-VAT-rubl       = v-VAT-rubl       - buf_temp-ot-day.temp-VAT-rubl
            v-SLT-base       = v-SLT-base       - buf_temp-ot-day.temp-SLT-base
            v-SLT-rubl       = v-SLT-rubl       - buf_temp-ot-day.temp-SLT-rubl
            v-road-tax-base  = v-road-tax-base  - buf_temp-ot-day.temp-road-tax-base
            v-road-tax-rubl  = v-road-tax-rubl  - buf_temp-ot-day.temp-road-tax-rubl
            v-excise-base    = v-excise-base    - buf_temp-ot-day.temp-excise-base
            v-excise-rubl    = v-excise-rubl    - buf_temp-ot-day.temp-excise-rubl
            v-transport-base = v-transport-base - buf_temp-ot-day.temp-transport-base
            v-transport-rubl = v-transport-rubl - buf_temp-ot-day.temp-transport-rubl
            v-other-base     = v-other-base     - buf_temp-ot-day.temp-other-base
            v-other-rubl     = v-other-rubl     - buf_temp-ot-day.temp-other-rubl
          .
        end.

        if v-fact-qnty      <> 0
        or v-sum-base       <> 0
        or v-sum-rubl       <> 0
        or v-VAT-base       <> 0
        or v-VAT-rubl       <> 0
        or v-SLT-base       <> 0
        or v-SLT-rubl       <> 0
        or v-road-tax-base  <> 0
        or v-road-tax-rubl  <> 0
        or v-excise-base    <> 0
        or v-excise-rubl    <> 0
        or v-transport-base <> 0
        or v-transport-rubl <> 0
        or v-other-base     <> 0
        or v-other-rubl     <> 0
        then do:
          assign
            v-total-err = v-total-err + 1
          .

          run cur-time in this-procedure
            (output v-today
            ,output v-time
            ) .
          run update-last-date in this-procedure
            (input buf_stk-line.fact-date
            ) .

          output stream sout to value(v-log-err-file) append .
          export stream sout '***':u string(v-today, '99/99/9999':u) string(v-time, 'HH:MM:SS':u) .
          export stream sout "error-04: stk-line record different quantity" .
          export stream sout "obj-type"       buf_stk-line.obj-type       .
          export stream sout "obj-code"       buf_stk-line.obj-code       .
          export stream sout "fact-date"      buf_stk-line.fact-date      .
          export stream sout "artic"          buf_stk-line.artic          .
          export stream sout "prod-type"      buf_stk-line.prod-type      .
          export stream sout "prod-code"      buf_stk-line.prod-code      .
          export stream sout "sum-type"       buf_stk-line.sum-type       .
          export stream sout "cat-id"         buf_stk-line.cat-id         .
          export stream sout "fact-order"     buf_stk-line.fact-order     .
          export stream sout "fact-qnty"      buf_stk-line.fact-qnty      .
          export stream sout "sum-base"       buf_stk-line.sum-base       .
          export stream sout "sum-rubl"       buf_stk-line.sum-rubl       .
          export stream sout "VAT-base"       buf_stk-line.VAT-base       .
          export stream sout "VAT-rubl"       buf_stk-line.VAT-rubl       .
          export stream sout "SLT-base"       buf_stk-line.SLT-base       .
          export stream sout "SLT-rubl"       buf_stk-line.SLT-rubl       .
          export stream sout "road-tax-base"  buf_stk-line.road-tax-base  .
          export stream sout "road-tax-rubl"  buf_stk-line.road-tax-rubl  .
          export stream sout "excise-base"    buf_stk-line.excise-base    .
          export stream sout "excise-rubl"    buf_stk-line.excise-rubl    .
          export stream sout "transport-base" buf_stk-line.transport-base .
          export stream sout "transport-rubl" buf_stk-line.transport-rubl .
          export stream sout "other-base"     buf_stk-line.other-base     .
          export stream sout "other-rubl"     buf_stk-line.other-rubl     .
          output stream sout close .
        end.
      end.

      if buf_stk-line.sum-type begins {&arh-csdt}
      then do:
        assign
          v-fact-qnty      = buf_stk-line.fact-qnty
          v-sum-base       = buf_stk-line.sum-base
          v-sum-rubl       = buf_stk-line.sum-rubl
          v-VAT-base       = buf_stk-line.VAT-base
          v-VAT-rubl       = buf_stk-line.VAT-rubl
          v-SLT-base       = buf_stk-line.SLT-base
          v-SLT-rubl       = buf_stk-line.SLT-rubl
          v-road-tax-base  = buf_stk-line.road-tax-base
          v-road-tax-rubl  = buf_stk-line.road-tax-rubl
          v-excise-base    = buf_stk-line.excise-base
          v-excise-rubl    = buf_stk-line.excise-rubl
          v-transport-base = buf_stk-line.transport-base
          v-transport-rubl = buf_stk-line.transport-rubl
          v-other-base     = buf_stk-line.other-base
          v-other-rubl     = buf_stk-line.other-rubl
        .

        find last buf_prev_stk-line no-lock
          where buf_prev_stk-line.obj-type   = buf_stk-line.obj-type
            and buf_prev_stk-line.obj-code   = buf_stk-line.obj-code
            and buf_prev_stk-line.artic      = buf_stk-line.artic
            and buf_prev_stk-line.prod-type  = buf_stk-line.prod-type
            and buf_prev_stk-line.prod-code  = buf_stk-line.prod-code
            and buf_prev_stk-line.sum-type   = buf_stk-line.sum-type
            and buf_prev_stk-line.cat-id     = buf_stk-line.cat-id
            and buf_prev_stk-line.fact-order < p-fact-order-begin-day
            and buf_prev_stk-line.shift-date = ?
          use-index category
          no-error .
        if available buf_prev_stk-line
        then do:
          assign
            v-fact-qnty      = v-fact-qnty      - buf_prev_stk-line.fact-qnty
            v-sum-base       = v-sum-base       - buf_prev_stk-line.sum-base
            v-sum-rubl       = v-sum-rubl       - buf_prev_stk-line.sum-rubl
            v-VAT-base       = v-VAT-base       - buf_prev_stk-line.VAT-base
            v-VAT-rubl       = v-VAT-rubl       - buf_prev_stk-line.VAT-rubl
            v-SLT-base       = v-SLT-base       - buf_prev_stk-line.SLT-base
            v-SLT-rubl       = v-SLT-rubl       - buf_prev_stk-line.SLT-rubl
            v-road-tax-base  = v-road-tax-base  - buf_prev_stk-line.road-tax-base
            v-road-tax-rubl  = v-road-tax-rubl  - buf_prev_stk-line.road-tax-rubl
            v-excise-base    = v-excise-base    - buf_prev_stk-line.excise-base
            v-excise-rubl    = v-excise-rubl    - buf_prev_stk-line.excise-rubl
            v-transport-base = v-transport-base - buf_prev_stk-line.transport-base
            v-transport-rubl = v-transport-rubl - buf_prev_stk-line.transport-rubl
            v-other-base     = v-other-base     - buf_prev_stk-line.other-base
            v-other-rubl     = v-other-rubl     - buf_prev_stk-line.other-rubl
          .
        end.

        find first buf_temp-ot-day
          where buf_temp-ot-day.temp-artic     = buf_stk-line.artic
            and buf_temp-ot-day.temp-prod-type = buf_stk-line.prod-type
            and buf_temp-ot-day.temp-prod-code = buf_stk-line.prod-code
            and buf_temp-ot-day.temp-sum-type  = buf_stk-line.sum-type
            and buf_temp-ot-day.temp-cat-id    = buf_stk-line.cat-id
          no-error .
        if available buf_temp-ot-day
        then do:
          assign
            v-fact-qnty      = v-fact-qnty      - buf_temp-ot-day.temp-fact-qnty
            v-sum-base       = v-sum-base       - buf_temp-ot-day.temp-sum-base
            v-sum-rubl       = v-sum-rubl       - buf_temp-ot-day.temp-sum-rubl
            v-VAT-base       = v-VAT-base       - buf_temp-ot-day.temp-VAT-base
            v-VAT-rubl       = v-VAT-rubl       - buf_temp-ot-day.temp-VAT-rubl
            v-SLT-base       = v-SLT-base       - buf_temp-ot-day.temp-SLT-base
            v-SLT-rubl       = v-SLT-rubl       - buf_temp-ot-day.temp-SLT-rubl
            v-road-tax-base  = v-road-tax-base  - buf_temp-ot-day.temp-road-tax-base
            v-road-tax-rubl  = v-road-tax-rubl  - buf_temp-ot-day.temp-road-tax-rubl
            v-excise-base    = v-excise-base    - buf_temp-ot-day.temp-excise-base
            v-excise-rubl    = v-excise-rubl    - buf_temp-ot-day.temp-excise-rubl
            v-transport-base = v-transport-base - buf_temp-ot-day.temp-transport-base
            v-transport-rubl = v-transport-rubl - buf_temp-ot-day.temp-transport-rubl
            v-other-base     = v-other-base     - buf_temp-ot-day.temp-other-base
            v-other-rubl     = v-other-rubl     - buf_temp-ot-day.temp-other-rubl
          .
        end.

        if v-fact-qnty      <> 0
        or v-sum-base       <> 0
        or v-sum-rubl       <> 0
        or v-VAT-base       <> 0
        or v-VAT-rubl       <> 0
        or v-SLT-base       <> 0
        or v-SLT-rubl       <> 0
        or v-road-tax-base  <> 0
        or v-road-tax-rubl  <> 0
        or v-excise-base    <> 0
        or v-excise-rubl    <> 0
        or v-transport-base <> 0
        or v-transport-rubl <> 0
        or v-other-base     <> 0
        or v-other-rubl     <> 0
        then do:
          assign
            v-total-err = v-total-err + 1
          .

          run cur-time in this-procedure
            (output v-today
            ,output v-time
            ) .
          run update-last-date in this-procedure
            (input buf_stk-line.fact-date
            ) .

          output stream sout to value(v-log-err-file) append .
          export stream sout '***':u string(v-today, '99/99/9999':u) string(v-time, 'HH:MM:SS':u) .
          export stream sout "error-05: stk-line record different quantity" .
          export stream sout "obj-type"       buf_stk-line.obj-type       .
          export stream sout "obj-code"       buf_stk-line.obj-code       .
          export stream sout "fact-date"      buf_stk-line.fact-date      .
          export stream sout "artic"          buf_stk-line.artic          .
          export stream sout "prod-type"      buf_stk-line.prod-type      .
          export stream sout "prod-code"      buf_stk-line.prod-code      .
          export stream sout "sum-type"       buf_stk-line.sum-type       .
          export stream sout "cat-id"         buf_stk-line.cat-id         .
          export stream sout "fact-order"     buf_stk-line.fact-order     .
          export stream sout "fact-qnty"      buf_stk-line.fact-qnty      .
          export stream sout "sum-base"       buf_stk-line.sum-base       .
          export stream sout "sum-rubl"       buf_stk-line.sum-rubl       .
          export stream sout "VAT-base"       buf_stk-line.VAT-base       .
          export stream sout "VAT-rubl"       buf_stk-line.VAT-rubl       .
          export stream sout "SLT-base"       buf_stk-line.SLT-base       .
          export stream sout "SLT-rubl"       buf_stk-line.SLT-rubl       .
          export stream sout "road-tax-base"  buf_stk-line.road-tax-base  .
          export stream sout "road-tax-rubl"  buf_stk-line.road-tax-rubl  .
          export stream sout "excise-base"    buf_stk-line.excise-base    .
          export stream sout "excise-rubl"    buf_stk-line.excise-rubl    .
          export stream sout "transport-base" buf_stk-line.transport-base .
          export stream sout "transport-rubl" buf_stk-line.transport-rubl .
          export stream sout "other-base"     buf_stk-line.other-base     .
          export stream sout "other-rubl"     buf_stk-line.other-rubl     .
          output stream sout close .
        end.
      end.
    end.
  end.

end procedure. /* validate-stk-line */


procedure validate-free-zone :

  define buffer buf_gds-obj for ub.gds-obj .
  define buffer buf_lock_gds-obj for ub.gds-obj .
  define buffer buf_stk-line for ub.stk-line .
  define buffer buf_temp-stk-line for temp-stk-line .
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
          (input substitute("Проверка 01. Ошибок &1. Объект &2 &3. Артикул &4 &5 &6."
                          ,v-total-err
                          ,p-obj-type
                          ,p-obj-code
                          ,buf_gds-obj.artic
                          ,buf_gds-obj.prod-type
                          ,buf_gds-obj.prod-code
                          )
          ).
      end.


      run clear-temp-stk-line in this-procedure .

      run partslib-clear-temp-parts in this-procedure .

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
        export stream sout "error-06: ub.goods not found"      .
        export stream sout "obj-type"  p-obj-type           .
        export stream sout "obj-code"  p-obj-code           .
        export stream sout "gds-code"  buf_gds-obj.gds-code .
        output stream sout close .
      end.

      if buf_goods.gds-type = {&gds-goods}
      then do:
        for each buf_temp-parts
        on error undo, return error return-value
        :
          find first buf_temp-stk-line
            where buf_temp-stk-line.temp-artic     = buf_gds-obj.artic
              and buf_temp-stk-line.temp-prod-type = buf_gds-obj.prod-type
              and buf_temp-stk-line.temp-prod-code = buf_gds-obj.prod-code
            no-error .
          if not available buf_temp-stk-line
          then do:
            create buf_temp-stk-line .
            assign
              buf_temp-stk-line.temp-artic     = buf_gds-obj.artic
              buf_temp-stk-line.temp-prod-type = buf_gds-obj.prod-type
              buf_temp-stk-line.temp-prod-code = buf_gds-obj.prod-code
            .
          end.

          assign
            buf_temp-stk-line.temp-fact-qnty = buf_temp-stk-line.temp-fact-qnty
                                             + buf_temp-parts.fact-qnty
          .
        end.
      end.
      else do:
        find first buf_temp-stk-line
          where buf_temp-stk-line.temp-artic     = buf_gds-obj.artic
            and buf_temp-stk-line.temp-prod-type = buf_gds-obj.prod-type
            and buf_temp-stk-line.temp-prod-code = buf_gds-obj.prod-code
          no-error .
        if not available buf_temp-stk-line
        then do:
          create buf_temp-stk-line .
          assign
            buf_temp-stk-line.temp-artic     = buf_gds-obj.artic
            buf_temp-stk-line.temp-prod-type = buf_gds-obj.prod-type
            buf_temp-stk-line.temp-prod-code = buf_gds-obj.prod-code
          .
        end.

        assign
          buf_temp-stk-line.temp-fact-qnty = buf_temp-stk-line.temp-fact-qnty
                                           + buf_gds-obj.fact-qnty
        .
      end.


      for each buf_temp-stk-line
      on error undo, return error return-value
      :
        find last buf_stk-line no-lock
          where buf_stk-line.obj-type   = p-obj-type
            and buf_stk-line.obj-code   = p-obj-code
            and buf_stk-line.artic      = buf_temp-stk-line.temp-artic
            and buf_stk-line.prod-type  = buf_temp-stk-line.temp-prod-type
            and buf_stk-line.prod-code  = buf_temp-stk-line.temp-prod-code
            and buf_stk-line.sum-type   = {&arh-cost}
            and buf_stk-line.cat-id     = {&root-cat-id}
            and buf_stk-line.shift-date = ?
          use-index category
          no-error .
        if (available buf_stk-line
            and buf_temp-stk-line.temp-fact-qnty <> buf_stk-line.fact-qnty
           )
        or (not available buf_stk-line
            and buf_temp-stk-line.temp-fact-qnty <> 0
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
          export stream sout "error-07: gds-obj stk-line different fact-qnty"   .
          export stream sout "obj-type"  p-obj-type                             .
          export stream sout "obj-code"  p-obj-code                             .
          export stream sout "fact-date" v-today                                .
          export stream sout "artic"     buf_temp-stk-line.temp-artic           .
          export stream sout "prod-type" buf_temp-stk-line.temp-prod-type       .
          export stream sout "prod-code" buf_temp-stk-line.temp-prod-code       .
          export stream sout "parts.fact-qnty" buf_temp-stk-line.temp-fact-qnty .
          if available buf_stk-line
          then do:
            export stream sout "stk-line.fact-qnty" buf_stk-line.fact-qnty .
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


procedure clear-temp-stk-line :

  define buffer buf_temp-stk-line for temp-stk-line .

  do
  on error undo, return error return-value
  :

    for each buf_temp-stk-line
    on error undo, return error return-value
    :
      delete buf_temp-stk-line .
    end.
  end.

end procedure. /* clear-temp-stk-line */


procedure check-fact-order :

  define buffer buf_stk-line for ub.stk-line .

  define variable v-ind as integer   no-undo .

  do
  on error undo, return error return-value
  :
    /* просматриваем все линии остатков и проверяем правильность fact-order */
    for each buf_stk-line no-lock
      where buf_stk-line.obj-type = p-obj-type
        and buf_stk-line.obj-code = p-obj-code
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
        (input  buf_stk-line.fact-order
        ,output v-factord-date
        ) .

      if truncate(buf_stk-line.fact-order, 2) <> buf_stk-line.fact-order
      or buf_stk-line.fact-date               <> v-factord-date
      then do:
        assign
          v-total-err = v-total-err + 1
        .

        run update-last-date in this-procedure
          (input buf_stk-line.fact-date
          ) .
        run update-last-date in this-procedure
          (input v-factord-date
          ) .

        output stream sout to value(v-log-err-file) append .
        export stream sout '***':u string(v-today, '99/99/9999':u) string(v-time, 'HH:MM:SS':u) .
        export stream sout "error-08: fact-order"                .
        export stream sout "obj-type"    buf_stk-line.obj-type   .
        export stream sout "obj-code"    buf_stk-line.obj-code   .
        export stream sout "artic"       buf_stk-line.artic      .
        export stream sout "prod-type"   buf_stk-line.prod-type  .
        export stream sout "prod-code"   buf_stk-line.prod-code  .
        export stream sout "fact-order"  buf_stk-line.fact-order .
        export stream sout "sum-type"    buf_stk-line.sum-type   .
        export stream sout "cat-id"      buf_stk-line.cat-id     .
        export stream sout "fact-date"   buf_stk-line.fact-date  .
        export stream sout "v-factord-date" v-factord-date .
        export stream sout "stk-line" .
        export stream sout buf_stk-line .
        output stream sout close .
      end.
    end.
  end.

end procedure. /* check-fact-order */


procedure fill-temp-stk-line :

  define buffer buf_stk-line for ub.stk-line .
  define buffer buf_temp-stk-line for temp-stk-line .
  define buffer buf_temp-gds for temp-gds .

  define variable v-ind as integer   no-undo .

  do
  on error undo, return error return-value
  :
    /* просматриваем все линии остатков и получаем информацию о самом последнем остатке */
    for each buf_stk-line no-lock
      where buf_stk-line.obj-type = p-obj-type
        and buf_stk-line.obj-code = p-obj-code
        and buf_stk-line.sum-type = {&arh-cost}
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Проверка 03. Ошибок &1. Объект &2 &3. Записей &4."
                          ,v-total-err
                          ,p-obj-type
                          ,p-obj-code
                          ,v-ind
                          )
          ).
      end.

      find first buf_temp-stk-line
        where buf_temp-stk-line.temp-artic     = buf_stk-line.artic
          and buf_temp-stk-line.temp-prod-type = buf_stk-line.prod-type
          and buf_temp-stk-line.temp-prod-code = buf_stk-line.prod-code
        no-error .
      if not available buf_temp-stk-line
      then do:
        create buf_temp-stk-line .

        assign
          buf_temp-stk-line.temp-artic          = buf_stk-line.artic
          buf_temp-stk-line.temp-prod-type      = buf_stk-line.prod-type
          buf_temp-stk-line.temp-prod-code      = buf_stk-line.prod-code
          buf_temp-stk-line.temp-fact-order     = buf_stk-line.fact-order
          buf_temp-stk-line.temp-fact-qnty      = buf_stk-line.fact-qnty
        .
      end.

      if buf_temp-stk-line.temp-fact-order < buf_stk-line.fact-order
      then do:
        assign
          buf_temp-stk-line.temp-fact-order     = buf_stk-line.fact-order
          buf_temp-stk-line.temp-fact-qnty      = buf_stk-line.fact-qnty
        .
      end.

      find first buf_temp-gds
        where buf_temp-gds.temp-artic      = buf_stk-line.artic
          and buf_temp-gds.temp-prod-type  = buf_stk-line.prod-type
          and buf_temp-gds.temp-prod-code  = buf_stk-line.prod-code
        no-error .
      if not available buf_temp-gds
      then do:
        create buf_temp-gds .

        assign
          buf_temp-gds.temp-artic      = buf_stk-line.artic
          buf_temp-gds.temp-prod-type  = buf_stk-line.prod-type
          buf_temp-gds.temp-prod-code  = buf_stk-line.prod-code
        .
      end.
    end.
  end.

end procedure. /* fill-temp-stk-line */


procedure check-free-zone-from-stk-line :

  define buffer buf_lock_gds-obj for ub.gds-obj .
  define buffer buf_temp-gds for temp-gds .
  define buffer buf_temp-stk-line for temp-stk-line .
  define buffer buf_temp-parts for temp-parts .

  define variable v-ind as integer   no-undo .

  do
  on error undo, return error return-value
  :
    for each buf_temp-gds
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Проверка 04. Ошибок &1. Объект &2 &3. Артикул &4 &5 &6."
                          ,v-total-err
                          ,p-obj-type
                          ,p-obj-code
                          ,buf_temp-gds.temp-artic
                          ,buf_temp-gds.temp-prod-type
                          ,buf_temp-gds.temp-prod-code
                          )
          ).
      end.

      run partslib-clear-temp-parts in this-procedure .

      do transaction
      on error undo, return error return-value
      :
        find buf_lock_gds-obj exclusive-lock
          where buf_lock_gds-obj.obj-type  = p-obj-type
            and buf_lock_gds-obj.obj-code  = p-obj-code
            and buf_lock_gds-obj.artic     = buf_temp-gds.temp-artic
            and buf_lock_gds-obj.prod-type = buf_temp-gds.temp-prod-type
            and buf_lock_gds-obj.prod-code = buf_temp-gds.temp-prod-code
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
          export stream sout "error-09: gds-obj not found"           .
          export stream sout "obj-type"  p-obj-type                  .
          export stream sout "obj-code"  p-obj-code                  .
          export stream sout "artic"     buf_temp-gds.temp-artic     .
          export stream sout "prod-type" buf_temp-gds.temp-prod-type .
          export stream sout "prod-code" buf_temp-gds.temp-prod-code .
          output stream sout close .
        end.
        else do:
          run partslib-init-temp-parts in this-procedure
            (input  p-obj-type                  /* p-obj-type  */
            ,input  p-obj-code                  /* p-obj-code  */
            ,input  buf_temp-gds.temp-artic     /* p-artic     */
            ,input  buf_temp-gds.temp-prod-type /* p-prod-type */
            ,input  buf_temp-gds.temp-prod-code /* p-prod-code */
            ) .
        end.
      end.

      for each buf_temp-parts
      on error undo, return error return-value
      :
        find first buf_temp-stk-line
          where buf_temp-stk-line.temp-artic     = buf_temp-parts.artic
            and buf_temp-stk-line.temp-prod-type = buf_temp-parts.prod-type
            and buf_temp-stk-line.temp-prod-code = buf_temp-parts.prod-code
          no-error .
        if not available buf_temp-stk-line
        then do:
          create buf_temp-stk-line .
          assign
            buf_temp-stk-line.temp-artic     = buf_temp-parts.artic
            buf_temp-stk-line.temp-prod-type = buf_temp-parts.prod-type
            buf_temp-stk-line.temp-prod-code = buf_temp-parts.prod-code
          .
        end.

        assign
          buf_temp-stk-line.temp-gds-qnty = buf_temp-stk-line.temp-gds-qnty
                                                + buf_temp-parts.fact-qnty
        .
      end.
    end.

    for each buf_temp-stk-line
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Проверка 05. Ошибок &1. Объект &2 &3. Записей &4."
                          ,v-total-err
                          ,p-obj-type
                          ,p-obj-code
                          ,v-ind
                          )
          ).
      end.

      if buf_temp-stk-line.temp-fact-qnty <> buf_temp-stk-line.temp-gds-qnty
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
        export stream sout "error-10: gds-obj stk-line different fact-qnty"      .
        export stream sout "obj-type"  p-obj-type                                .
        export stream sout "obj-code"  p-obj-code                                .
        export stream sout "fact-date" v-today                                   .
        export stream sout "artic"     buf_temp-stk-line.temp-artic              .
        export stream sout "prod-type" buf_temp-stk-line.temp-prod-type          .
        export stream sout "prod-code" buf_temp-stk-line.temp-prod-code          .
        export stream sout "stk-line.fact-qnty" buf_temp-stk-line.temp-fact-qnty .
        export stream sout "parts.fact-qnty" buf_temp-stk-line.temp-gds-qnty     .
        output stream sout close .
      end.
    end.
  end.

end procedure. /* check-free-zone-from-stk-line */



procedure check-sub-type-stk-line :

  define buffer buf_temp-gds for temp-gds .
  define buffer buf_stk-line for ub.stk-line .
  define buffer buf_sub_stk-line for ub.stk-line .

  define variable v-ind            as integer   no-undo .

  define variable v-fact-qnty      as decimal   no-undo .
  define variable v-sum-base       as decimal   no-undo .
  define variable v-sum-rubl       as decimal   no-undo .
  define variable v-VAT-base       as decimal   no-undo .
  define variable v-VAT-rubl       as decimal   no-undo .
  define variable v-SLT-base       as decimal   no-undo .
  define variable v-SLT-rubl       as decimal   no-undo .
  define variable v-road-tax-base  as decimal   no-undo .
  define variable v-road-tax-rubl  as decimal   no-undo .
  define variable v-excise-base    as decimal   no-undo .
  define variable v-excise-rubl    as decimal   no-undo .
  define variable v-transport-base as decimal   no-undo .
  define variable v-transport-rubl as decimal   no-undo .
  define variable v-other-base     as decimal   no-undo .
  define variable v-other-rubl     as decimal   no-undo .

  do
  on error undo, return error return-value
  :

    for each buf_stk-line no-lock
      where buf_stk-line.obj-type  = p-obj-type
        and buf_stk-line.obj-code  = p-obj-code
        and buf_stk-line.sum-type  = {&arh-cost}
    on error undo, return error return-value
    :

      assign
        v-ind = v-ind + 1
      .

      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Проверка 06. Ошибок &1. Объект &2 &3. Артикул &4 &5 &6."
                          ,v-total-err
                          ,p-obj-type
                          ,p-obj-code
                          ,buf_stk-line.artic
                          ,buf_stk-line.prod-type
                          ,buf_stk-line.prod-code
                          )
          ).
      end.
      assign
        v-fact-qnty      = 0
        v-sum-base       = 0
        v-sum-rubl       = 0
        v-VAT-base       = 0
        v-VAT-rubl       = 0
        v-SLT-base       = 0
        v-SLT-rubl       = 0
        v-road-tax-base  = 0
        v-road-tax-rubl  = 0
        v-excise-base    = 0
        v-excise-rubl    = 0
        v-transport-base = 0
        v-transport-rubl = 0
        v-other-base     = 0
        v-other-rubl     = 0
      .

      for each buf_sub_stk-line no-lock
        where buf_sub_stk-line.obj-type   = buf_stk-line.obj-type
          and buf_sub_stk-line.obj-code   = buf_stk-line.obj-code
          and buf_sub_stk-line.artic      = buf_stk-line.artic
          and buf_sub_stk-line.prod-type  = buf_stk-line.prod-type
          and buf_sub_stk-line.prod-code  = buf_stk-line.prod-code
          and buf_sub_stk-line.fact-order = buf_stk-line.fact-order
          and buf_sub_stk-line.sum-type   = {&arh-cost} + {&arh-VAT}
      on error undo, return error return-value
      :
        assign
          v-fact-qnty      = v-fact-qnty      + buf_sub_stk-line.fact-qnty
          v-sum-base       = v-sum-base       + buf_sub_stk-line.sum-base
          v-sum-rubl       = v-sum-rubl       + buf_sub_stk-line.sum-rubl
          v-VAT-base       = v-VAT-base       + buf_sub_stk-line.VAT-base
          v-VAT-rubl       = v-VAT-rubl       + buf_sub_stk-line.VAT-rubl
          v-SLT-base       = v-SLT-base       + buf_sub_stk-line.SLT-base
          v-SLT-rubl       = v-SLT-rubl       + buf_sub_stk-line.SLT-rubl
          v-road-tax-base  = v-road-tax-base  + buf_sub_stk-line.road-tax-base
          v-road-tax-rubl  = v-road-tax-rubl  + buf_sub_stk-line.road-tax-rubl
          v-excise-base    = v-excise-base    + buf_sub_stk-line.excise-base
          v-excise-rubl    = v-excise-rubl    + buf_sub_stk-line.excise-rubl
          v-transport-base = v-transport-base + buf_sub_stk-line.transport-base
          v-transport-rubl = v-transport-rubl + buf_sub_stk-line.transport-rubl
          v-other-base     = v-other-base     + buf_sub_stk-line.other-base
          v-other-rubl     = v-other-rubl     + buf_sub_stk-line.other-rubl
        .
      end.


      if buf_stk-line.fact-qnty       <> v-fact-qnty
      or buf_stk-line.sum-base        <> v-sum-base
      or buf_stk-line.sum-rubl        <> v-sum-rubl
      or buf_stk-line.VAT-base        <> v-VAT-base
      or buf_stk-line.VAT-rubl        <> v-VAT-rubl
      or buf_stk-line.SLT-base        <> v-SLT-base
      or buf_stk-line.SLT-rubl        <> v-SLT-rubl
      or buf_stk-line.road-tax-base   <> v-road-tax-base
      or buf_stk-line.road-tax-rubl   <> v-road-tax-rubl
      or buf_stk-line.excise-base     <> v-excise-base
      or buf_stk-line.excise-rubl     <> v-excise-rubl
      or buf_stk-line.transport-base  <> v-transport-base
      or buf_stk-line.transport-rubl  <> v-transport-rubl
      or buf_stk-line.other-base      <> v-other-base
      or buf_stk-line.other-rubl      <> v-other-rubl
      then do:
        output stream sout to value(v-log-err-file) append .
        export stream sout '***':u string(v-today, '99/99/9999':u) string(v-time, 'HH:MM:SS':u) .
        export stream sout "error-11: sub_stk-line different qnty"                              .
        export stream sout "obj-type"            p-obj-type                                     .
        export stream sout "obj-code"            p-obj-code                                     .
        export stream sout "obj-type"            buf_stk-line.obj-type                          .
        export stream sout "obj-type"            buf_stk-line.obj-type                          .
        export stream sout "artic"               buf_stk-line.artic                             .
        export stream sout "prod-type"           buf_stk-line.prod-type                         .
        export stream sout "prod-code"           buf_stk-line.prod-code                         .
        export stream sout "fact-order"          buf_stk-line.fact-order                        .
        export stream sout "diff-fact-qnty"      buf_stk-line.fact-qnty      - v-fact-qnty      .
        export stream sout "diff-sum-base"       buf_stk-line.sum-base       - v-sum-base       .
        export stream sout "diff-sum-rubl"       buf_stk-line.sum-rubl       - v-sum-rubl       .
        export stream sout "diff-VAT-base"       buf_stk-line.VAT-base       - v-VAT-base       .
        export stream sout "diff-VAT-rubl"       buf_stk-line.VAT-rubl       - v-VAT-rubl       .
        export stream sout "diff-SLT-base"       buf_stk-line.SLT-base       - v-SLT-base       .
        export stream sout "diff-SLT-rubl"       buf_stk-line.SLT-rubl       - v-SLT-rubl       .
        export stream sout "diff-road-tax-base"  buf_stk-line.road-tax-base  - v-road-tax-base  .
        export stream sout "diff-road-tax-rubl"  buf_stk-line.road-tax-rubl  - v-road-tax-rubl  .
        export stream sout "diff-excise-base"    buf_stk-line.excise-base    - v-excise-base    .
        export stream sout "diff-excise-rubl"    buf_stk-line.excise-rubl    - v-excise-rubl    .
        export stream sout "diff-transport-base" buf_stk-line.transport-base - v-transport-base .
        export stream sout "diff-transport-rubl" buf_stk-line.transport-rubl - v-transport-rubl .
        export stream sout "diff-other-base"     buf_stk-line.other-base     - v-other-base     .
        export stream sout "diff-other-rubl"     buf_stk-line.other-rubl     - v-other-rubl     .
        export stream sout "sub-sum-type"        {&arh-cost} + {&arh-VAT}                       .
        export stream sout "fact-qnty"           buf_stk-line.fact-qnty                         .
        export stream sout "sum-base"            buf_stk-line.sum-base                          .
        export stream sout "sum-rubl"            buf_stk-line.sum-rubl                          .
        export stream sout "VAT-base"            buf_stk-line.VAT-base                          .
        export stream sout "VAT-rubl"            buf_stk-line.VAT-rubl                          .
        export stream sout "SLT-base"            buf_stk-line.SLT-base                          .
        export stream sout "SLT-rubl"            buf_stk-line.SLT-rubl                          .
        export stream sout "road-tax-base"       buf_stk-line.road-tax-base                     .
        export stream sout "road-tax-rubl"       buf_stk-line.road-tax-rubl                     .
        export stream sout "excise-base"         buf_stk-line.excise-base                       .
        export stream sout "excise-rubl"         buf_stk-line.excise-rubl                       .
        export stream sout "transport-base"      buf_stk-line.transport-base                    .
        export stream sout "transport-rubl"      buf_stk-line.transport-rubl                    .
        export stream sout "other-base"          buf_stk-line.other-base                        .
        export stream sout "other-rubl"          buf_stk-line.other-rubl                        .
        export stream sout "sub-fact-qnty"       v-fact-qnty                                    .
        export stream sout "sub-sum-base"        v-sum-base                                     .
        export stream sout "sub-sum-rubl"        v-sum-rubl                                     .
        export stream sout "sub-VAT-base"        v-VAT-base                                     .
        export stream sout "sub-VAT-rubl"        v-VAT-rubl                                     .
        export stream sout "sub-SLT-base"        v-SLT-base                                     .
        export stream sout "sub-SLT-rubl"        v-SLT-rubl                                     .
        export stream sout "sub-road-tax-base"   v-road-tax-base                                .
        export stream sout "sub-road-tax-rubl"   v-road-tax-rubl                                .
        export stream sout "sub-excise-base"     v-excise-base                                  .
        export stream sout "sub-excise-rubl"     v-excise-rubl                                  .
        export stream sout "sub-transport-base"  v-transport-base                               .
        export stream sout "sub-transport-rubl"  v-transport-rubl                               .
        export stream sout "sub-other-base"      v-other-base                                   .
        export stream sout "sub-other-rubl"      v-other-rubl                                   .
        output stream sout close .
      end.



      assign
        v-fact-qnty      = 0
        v-sum-base       = 0
        v-sum-rubl       = 0
        v-VAT-base       = 0
        v-VAT-rubl       = 0
        v-SLT-base       = 0
        v-SLT-rubl       = 0
        v-road-tax-base  = 0
        v-road-tax-rubl  = 0
        v-excise-base    = 0
        v-excise-rubl    = 0
        v-transport-base = 0
        v-transport-rubl = 0
        v-other-base     = 0
        v-other-rubl     = 0
      .

      for each buf_sub_stk-line no-lock
        where buf_sub_stk-line.obj-type   = buf_stk-line.obj-type
          and buf_sub_stk-line.obj-code   = buf_stk-line.obj-code
          and buf_sub_stk-line.artic      = buf_stk-line.artic
          and buf_sub_stk-line.prod-type  = buf_stk-line.prod-type
          and buf_sub_stk-line.prod-code  = buf_stk-line.prod-code
          and buf_sub_stk-line.fact-order = buf_stk-line.fact-order
          and buf_sub_stk-line.sum-type   = {&arh-cost} + {&arh-SLT}
      on error undo, return error return-value
      :
        assign
          v-fact-qnty      = v-fact-qnty      + buf_sub_stk-line.fact-qnty
          v-sum-base       = v-sum-base       + buf_sub_stk-line.sum-base
          v-sum-rubl       = v-sum-rubl       + buf_sub_stk-line.sum-rubl
          v-VAT-base       = v-VAT-base       + buf_sub_stk-line.VAT-base
          v-VAT-rubl       = v-VAT-rubl       + buf_sub_stk-line.VAT-rubl
          v-SLT-base       = v-SLT-base       + buf_sub_stk-line.SLT-base
          v-SLT-rubl       = v-SLT-rubl       + buf_sub_stk-line.SLT-rubl
          v-road-tax-base  = v-road-tax-base  + buf_sub_stk-line.road-tax-base
          v-road-tax-rubl  = v-road-tax-rubl  + buf_sub_stk-line.road-tax-rubl
          v-excise-base    = v-excise-base    + buf_sub_stk-line.excise-base
          v-excise-rubl    = v-excise-rubl    + buf_sub_stk-line.excise-rubl
          v-transport-base = v-transport-base + buf_sub_stk-line.transport-base
          v-transport-rubl = v-transport-rubl + buf_sub_stk-line.transport-rubl
          v-other-base     = v-other-base     + buf_sub_stk-line.other-base
          v-other-rubl     = v-other-rubl     + buf_sub_stk-line.other-rubl
        .
      end.

      if buf_stk-line.fact-qnty       <> v-fact-qnty
      or buf_stk-line.sum-base        <> v-sum-base
      or buf_stk-line.sum-rubl        <> v-sum-rubl
      or buf_stk-line.VAT-base        <> v-VAT-base
      or buf_stk-line.VAT-rubl        <> v-VAT-rubl
      or buf_stk-line.SLT-base        <> v-SLT-base
      or buf_stk-line.SLT-rubl        <> v-SLT-rubl
      or buf_stk-line.road-tax-base   <> v-road-tax-base
      or buf_stk-line.road-tax-rubl   <> v-road-tax-rubl
      or buf_stk-line.excise-base     <> v-excise-base
      or buf_stk-line.excise-rubl     <> v-excise-rubl
      or buf_stk-line.transport-base  <> v-transport-base
      or buf_stk-line.transport-rubl  <> v-transport-rubl
      or buf_stk-line.other-base      <> v-other-base
      or buf_stk-line.other-rubl      <> v-other-rubl
      then do:
        output stream sout to value(v-log-err-file) append .
        export stream sout '***':u string(v-today, '99/99/9999':u) string(v-time, 'HH:MM:SS':u) .
        export stream sout "error-12: sub_stk-line different qnty"                              .
        export stream sout "obj-type"            p-obj-type                                     .
        export stream sout "obj-code"            p-obj-code                                     .
        export stream sout "obj-type"            buf_stk-line.obj-type                          .
        export stream sout "obj-type"            buf_stk-line.obj-type                          .
        export stream sout "artic"               buf_stk-line.artic                             .
        export stream sout "prod-type"           buf_stk-line.prod-type                         .
        export stream sout "prod-code"           buf_stk-line.prod-code                         .
        export stream sout "fact-order"          buf_stk-line.fact-order                        .
        export stream sout "diff-fact-qnty"      buf_stk-line.fact-qnty      - v-fact-qnty      .
        export stream sout "diff-sum-base"       buf_stk-line.sum-base       - v-sum-base       .
        export stream sout "diff-sum-rubl"       buf_stk-line.sum-rubl       - v-sum-rubl       .
        export stream sout "diff-VAT-base"       buf_stk-line.VAT-base       - v-VAT-base       .
        export stream sout "diff-VAT-rubl"       buf_stk-line.VAT-rubl       - v-VAT-rubl       .
        export stream sout "diff-SLT-base"       buf_stk-line.SLT-base       - v-SLT-base       .
        export stream sout "diff-SLT-rubl"       buf_stk-line.SLT-rubl       - v-SLT-rubl       .
        export stream sout "diff-road-tax-base"  buf_stk-line.road-tax-base  - v-road-tax-base  .
        export stream sout "diff-road-tax-rubl"  buf_stk-line.road-tax-rubl  - v-road-tax-rubl  .
        export stream sout "diff-excise-base"    buf_stk-line.excise-base    - v-excise-base    .
        export stream sout "diff-excise-rubl"    buf_stk-line.excise-rubl    - v-excise-rubl    .
        export stream sout "diff-transport-base" buf_stk-line.transport-base - v-transport-base .
        export stream sout "diff-transport-rubl" buf_stk-line.transport-rubl - v-transport-rubl .
        export stream sout "diff-other-base"     buf_stk-line.other-base     - v-other-base     .
        export stream sout "diff-other-rubl"     buf_stk-line.other-rubl     - v-other-rubl     .
        export stream sout "sub-sum-type"        {&arh-cost} + {&arh-SLT}                       .
        export stream sout "fact-qnty"           buf_stk-line.fact-qnty                         .
        export stream sout "sum-base"            buf_stk-line.sum-base                          .
        export stream sout "sum-rubl"            buf_stk-line.sum-rubl                          .
        export stream sout "VAT-base"            buf_stk-line.VAT-base                          .
        export stream sout "VAT-rubl"            buf_stk-line.VAT-rubl                          .
        export stream sout "SLT-base"            buf_stk-line.SLT-base                          .
        export stream sout "SLT-rubl"            buf_stk-line.SLT-rubl                          .
        export stream sout "road-tax-base"       buf_stk-line.road-tax-base                     .
        export stream sout "road-tax-rubl"       buf_stk-line.road-tax-rubl                     .
        export stream sout "excise-base"         buf_stk-line.excise-base                       .
        export stream sout "excise-rubl"         buf_stk-line.excise-rubl                       .
        export stream sout "transport-base"      buf_stk-line.transport-base                    .
        export stream sout "transport-rubl"      buf_stk-line.transport-rubl                    .
        export stream sout "other-base"          buf_stk-line.other-base                        .
        export stream sout "other-rubl"          buf_stk-line.other-rubl                        .
        export stream sout "sub-fact-qnty"       v-fact-qnty                                    .
        export stream sout "sub-sum-base"        v-sum-base                                     .
        export stream sout "sub-sum-rubl"        v-sum-rubl                                     .
        export stream sout "sub-VAT-base"        v-VAT-base                                     .
        export stream sout "sub-VAT-rubl"        v-VAT-rubl                                     .
        export stream sout "sub-SLT-base"        v-SLT-base                                     .
        export stream sout "sub-SLT-rubl"        v-SLT-rubl                                     .
        export stream sout "sub-road-tax-base"   v-road-tax-base                                .
        export stream sout "sub-road-tax-rubl"   v-road-tax-rubl                                .
        export stream sout "sub-excise-base"     v-excise-base                                  .
        export stream sout "sub-excise-rubl"     v-excise-rubl                                  .
        export stream sout "sub-transport-base"  v-transport-base                               .
        export stream sout "sub-transport-rubl"  v-transport-rubl                               .
        export stream sout "sub-other-base"      v-other-base                                   .
        export stream sout "sub-other-rubl"      v-other-rubl                                   .
        output stream sout close .
      end.


      assign
        v-fact-qnty      = 0
        v-sum-base       = 0
        v-sum-rubl       = 0
        v-VAT-base       = 0
        v-VAT-rubl       = 0
        v-SLT-base       = 0
        v-SLT-rubl       = 0
        v-road-tax-base  = 0
        v-road-tax-rubl  = 0
        v-excise-base    = 0
        v-excise-rubl    = 0
        v-transport-base = 0
        v-transport-rubl = 0
        v-other-base     = 0
        v-other-rubl     = 0
      .

      for each buf_sub_stk-line no-lock
        where buf_sub_stk-line.obj-type   = buf_stk-line.obj-type
          and buf_sub_stk-line.obj-code   = buf_stk-line.obj-code
          and buf_sub_stk-line.artic      = buf_stk-line.artic
          and buf_sub_stk-line.prod-type  = buf_stk-line.prod-type
          and buf_sub_stk-line.prod-code  = buf_stk-line.prod-code
          and buf_sub_stk-line.fact-order = buf_stk-line.fact-order
          and buf_sub_stk-line.sum-type   = {&arh-cost} + {&arh-VATSLT}
      on error undo, return error return-value
      :
        assign
          v-fact-qnty      = v-fact-qnty      + buf_sub_stk-line.fact-qnty
          v-sum-base       = v-sum-base       + buf_sub_stk-line.sum-base
          v-sum-rubl       = v-sum-rubl       + buf_sub_stk-line.sum-rubl
          v-VAT-base       = v-VAT-base       + buf_sub_stk-line.VAT-base
          v-VAT-rubl       = v-VAT-rubl       + buf_sub_stk-line.VAT-rubl
          v-SLT-base       = v-SLT-base       + buf_sub_stk-line.SLT-base
          v-SLT-rubl       = v-SLT-rubl       + buf_sub_stk-line.SLT-rubl
          v-road-tax-base  = v-road-tax-base  + buf_sub_stk-line.road-tax-base
          v-road-tax-rubl  = v-road-tax-rubl  + buf_sub_stk-line.road-tax-rubl
          v-excise-base    = v-excise-base    + buf_sub_stk-line.excise-base
          v-excise-rubl    = v-excise-rubl    + buf_sub_stk-line.excise-rubl
          v-transport-base = v-transport-base + buf_sub_stk-line.transport-base
          v-transport-rubl = v-transport-rubl + buf_sub_stk-line.transport-rubl
          v-other-base     = v-other-base     + buf_sub_stk-line.other-base
          v-other-rubl     = v-other-rubl     + buf_sub_stk-line.other-rubl
        .
      end.

      if buf_stk-line.fact-qnty       <> v-fact-qnty
      or buf_stk-line.sum-base        <> v-sum-base
      or buf_stk-line.sum-rubl        <> v-sum-rubl
      or buf_stk-line.VAT-base        <> v-VAT-base
      or buf_stk-line.VAT-rubl        <> v-VAT-rubl
      or buf_stk-line.SLT-base        <> v-SLT-base
      or buf_stk-line.SLT-rubl        <> v-SLT-rubl
      or buf_stk-line.road-tax-base   <> v-road-tax-base
      or buf_stk-line.road-tax-rubl   <> v-road-tax-rubl
      or buf_stk-line.excise-base     <> v-excise-base
      or buf_stk-line.excise-rubl     <> v-excise-rubl
      or buf_stk-line.transport-base  <> v-transport-base
      or buf_stk-line.transport-rubl  <> v-transport-rubl
      or buf_stk-line.other-base      <> v-other-base
      or buf_stk-line.other-rubl      <> v-other-rubl
      then do:
        output stream sout to value(v-log-err-file) append .
        export stream sout '***':u string(v-today, '99/99/9999':u) string(v-time, 'HH:MM:SS':u) .
        export stream sout "error-13: sub_stk-line different qnty"                              .
        export stream sout "obj-type"            p-obj-type                                     .
        export stream sout "obj-code"            p-obj-code                                     .
        export stream sout "obj-type"            buf_stk-line.obj-type                          .
        export stream sout "obj-type"            buf_stk-line.obj-type                          .
        export stream sout "artic"               buf_stk-line.artic                             .
        export stream sout "prod-type"           buf_stk-line.prod-type                         .
        export stream sout "prod-code"           buf_stk-line.prod-code                         .
        export stream sout "fact-order"          buf_stk-line.fact-order                        .
        export stream sout "diff-fact-qnty"      buf_stk-line.fact-qnty      - v-fact-qnty      .
        export stream sout "diff-sum-base"       buf_stk-line.sum-base       - v-sum-base       .
        export stream sout "diff-sum-rubl"       buf_stk-line.sum-rubl       - v-sum-rubl       .
        export stream sout "diff-VAT-base"       buf_stk-line.VAT-base       - v-VAT-base       .
        export stream sout "diff-VAT-rubl"       buf_stk-line.VAT-rubl       - v-VAT-rubl       .
        export stream sout "diff-SLT-base"       buf_stk-line.SLT-base       - v-SLT-base       .
        export stream sout "diff-SLT-rubl"       buf_stk-line.SLT-rubl       - v-SLT-rubl       .
        export stream sout "diff-road-tax-base"  buf_stk-line.road-tax-base  - v-road-tax-base  .
        export stream sout "diff-road-tax-rubl"  buf_stk-line.road-tax-rubl  - v-road-tax-rubl  .
        export stream sout "diff-excise-base"    buf_stk-line.excise-base    - v-excise-base    .
        export stream sout "diff-excise-rubl"    buf_stk-line.excise-rubl    - v-excise-rubl    .
        export stream sout "diff-transport-base" buf_stk-line.transport-base - v-transport-base .
        export stream sout "diff-transport-rubl" buf_stk-line.transport-rubl - v-transport-rubl .
        export stream sout "diff-other-base"     buf_stk-line.other-base     - v-other-base     .
        export stream sout "diff-other-rubl"     buf_stk-line.other-rubl     - v-other-rubl     .
        export stream sout "sub-sum-type"        {&arh-cost} + {&arh-VATSLT}                    .
        export stream sout "fact-qnty"           buf_stk-line.fact-qnty                         .
        export stream sout "sum-base"            buf_stk-line.sum-base                          .
        export stream sout "sum-rubl"            buf_stk-line.sum-rubl                          .
        export stream sout "VAT-base"            buf_stk-line.VAT-base                          .
        export stream sout "VAT-rubl"            buf_stk-line.VAT-rubl                          .
        export stream sout "SLT-base"            buf_stk-line.SLT-base                          .
        export stream sout "SLT-rubl"            buf_stk-line.SLT-rubl                          .
        export stream sout "road-tax-base"       buf_stk-line.road-tax-base                     .
        export stream sout "road-tax-rubl"       buf_stk-line.road-tax-rubl                     .
        export stream sout "excise-base"         buf_stk-line.excise-base                       .
        export stream sout "excise-rubl"         buf_stk-line.excise-rubl                       .
        export stream sout "transport-base"      buf_stk-line.transport-base                    .
        export stream sout "transport-rubl"      buf_stk-line.transport-rubl                    .
        export stream sout "other-base"          buf_stk-line.other-base                        .
        export stream sout "other-rubl"          buf_stk-line.other-rubl                        .
        export stream sout "sub-fact-qnty"       v-fact-qnty                                    .
        export stream sout "sub-sum-base"        v-sum-base                                     .
        export stream sout "sub-sum-rubl"        v-sum-rubl                                     .
        export stream sout "sub-VAT-base"        v-VAT-base                                     .
        export stream sout "sub-VAT-rubl"        v-VAT-rubl                                     .
        export stream sout "sub-SLT-base"        v-SLT-base                                     .
        export stream sout "sub-SLT-rubl"        v-SLT-rubl                                     .
        export stream sout "sub-road-tax-base"   v-road-tax-base                                .
        export stream sout "sub-road-tax-rubl"   v-road-tax-rubl                                .
        export stream sout "sub-excise-base"     v-excise-base                                  .
        export stream sout "sub-excise-rubl"     v-excise-rubl                                  .
        export stream sout "sub-transport-base"  v-transport-base                               .
        export stream sout "sub-transport-rubl"  v-transport-rubl                               .
        export stream sout "sub-other-base"      v-other-base                                   .
        export stream sout "sub-other-rubl"      v-other-rubl                                   .
        output stream sout close .
      end.
    end.
  end.

end procedure. /* check-sub-type-stk-line */