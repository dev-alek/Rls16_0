block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Инициализация остатков складском архиве по поставщикам на основании текущих остатков товара

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/28/04

Для восстановления складского архива по поставщикам на основании документов

*/

define input  parameter p-handle-callback    as handle    no-undo .
define input  parameter p-obj-type           as character no-undo .
define input  parameter p-obj-code           as integer   no-undo .
define input  parameter p-new-start-date     as date      no-undo .
define input  parameter p-current-start-date as date      no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Расчет остатков складском архиве по поставщикам на основании текущих остатков товара".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5':u,p-handle-callback,p-obj-type,p-obj-code,p-new-start-date,p-current-start-date)" }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ gbl/ah-csp.i   }
{ trg/factord.i  }
{ gbl/clntattr.i }
{ trg/doclslib.i }
{ trg/prdoclib.i }
{ trg/partslib.i }
{ str/prl-vat.i  }
{ str/clcprtsl.i }

{&def-temp-stk-supp-tot}
{&def-temp-stk-supp-line}
&scop fp1   define variable v-
&scop fps1
&scop fp2   like ub.ot-supp-tot.
&scop fps2
&scop fp3   no-undo .
&scop fp4
{&price-pair-list}

define buffer buf_stk-supp-line for ub.stk-supp-line .
define buffer buf_stk-supp-tot for ub.stk-supp-tot .
define buffer buf_temp-stk-supp-line for temp-stk-supp-line .
define buffer buf_temp-stk-supp-tot for temp-stk-supp-tot .

define stream slog .

define temp-table temp-supp no-undo
  field cli-type as character
  field cli-code as integer
  index xpk is primary unique cli-type cli-code
  .

define temp-table temp-supp-gds no-undo
  field cli-type       as character
  field cli-code       as integer
  field artic          as character
  field prod-type      as character
  field prod-code      as integer
  index xpk is primary unique cli-type cli-code artic prod-type prod-code
  index xie1 artic prod-type prod-code
  .

do
on error undo, return error return-value
:
  define variable v-curr-r-b as character no-undo .
  { gbl/curr-r-b.i
    v-curr-r-b
  }

  define variable v-shift-on                 as logical   no-undo .
  define variable v-shift-date               as date      no-undo .
  define variable v-shift-num                as integer   no-undo .
  define variable v-fact-order               as decimal   no-undo .
  define variable v-shift-end-fact-order     as decimal   no-undo .
  define variable v-day-end-fact-order       as decimal   no-undo .
  define variable v-old-shift-on             as logical   no-undo .
  define variable v-old-shift-date           as date      no-undo .
  define variable v-old-shift-num            as integer   no-undo .
  define variable v-old-fact-order           as decimal   no-undo .
  define variable v-old-shift-end-fact-order as decimal   no-undo .
  define variable v-old-day-end-fact-order   as decimal   no-undo .

  run factord-cut-archive in this-procedure
    (input  p-obj-type             /* p-obj-type             */
    ,input  p-obj-code             /* p-obj-code             */
    ,input  p-new-start-date       /* p-fact-date            */
    ,output v-shift-on             /* p-shift-on             */
    ,output v-shift-date           /* p-shift-date           */
    ,output v-shift-num            /* p-shift-num            */
    ,output v-day-end-fact-order   /* p-day-end-fact-order   */
    ,output v-shift-end-fact-order /* p-shift-end-fact-order */
    ) .

  run factord-cut-archive in this-procedure
    (input  p-obj-type                 /* p-obj-type             */
    ,input  p-obj-code                 /* p-obj-code             */
    ,input  p-current-start-date       /* p-fact-date            */
    ,output v-old-shift-on             /* p-shift-on             */
    ,output v-old-shift-date           /* p-shift-date           */
    ,output v-old-shift-num            /* p-shift-num            */
    ,output v-old-day-end-fact-order   /* p-day-end-fact-order   */
    ,output v-old-shift-end-fact-order /* p-shift-end-fact-order */
    ) .

  run doclslib-clear-doc-list in this-procedure .

  run doclslib-init-trn-doc in this-procedure
    (input p-obj-type           /* p-obj-type */
    ,input p-obj-code           /* p-obj-code */
    ,input p-new-start-date + 1 /* p-cut-date */
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры doclslib-init-trn-doc" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value . /* --->>>--- */
  end.

  run clear-tot in this-procedure .

  define buffer buf_gds-obj for ub.gds-obj .

  define variable v-host-code  as integer   no-undo .
  define variable v-base-rate  like ub.curr-accnt.exch-rate no-undo .
  define variable v-base-scale like ub.curr-accnt.exch-scale no-undo .
  define variable v-ind        as integer   no-undo .
  define variable v-cons-pay   as integer   no-undo .
  define variable v-cons-type  as character no-undo .

  { gbl/hostcode.i
    p-obj-type
    p-obj-code
    v-host-code
  }

  /* определяем код поставки - консигнация */
  { gbl/objatext.i
    p-obj-type
    p-obj-code
    "'cons-pay=request'"
    v-cons-pay
    v-cons-type
  }

  { gbl/baserate.i
    v-host-code
    p-new-start-date
    v-base-rate
    v-base-scale
    no-error
  }
  /* курс может быть неопределенным */
  /* но это имеет значение, только если остаток по товару отличен от нуля */
  define variable v-base-rate-reason as character no-undo .
  assign
    v-base-rate-reason = return-value
  .

  form
    p-obj-type label "Объект" p-obj-code no-label skip
    v-ind      label "Обработано" skip
    buf_gds-obj.artic label "Артикул" skip
    with frame a view-as dialog-box side-labels three-d
    title "Создание начальных остатков. Архив по поставщикам" .
  display
    p-obj-type p-obj-code
    with frame a .

  run cb_rst-ahsp_get-temp-supp-gds in p-handle-callback
    (input  this-procedure :handle
    ,input  "cb_inahsp_store-temp-supp-gds"
    ) .

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
      display
        v-ind skip
        buf_gds-obj.artic skip
        with frame a .
    end.

    run clear-line in this-procedure .

    define variable v-gds-goods as logical   no-undo .
    { gbl/gdscdat.i
      buf_gds-obj.gds-code
      "'gds-goods=request':u"
      v-gds-goods
      no-error
    }

    define variable v-need-copy-cost as logical   no-undo .

    /* обрабатываем только товары */
    if v-gds-goods = true
    then do:
      define variable v-overturn-exist as logical   no-undo .

      run cb_rst-ahsp_overturn-exist in p-handle-callback
        (input  buf_gds-obj.artic
        ,input  buf_gds-obj.prod-type
        ,input  buf_gds-obj.prod-code
        ,output v-overturn-exist
        ) .

      if v-overturn-exist = true
      then do:
        assign
          v-need-copy-cost = false
        .

        run process-gds-obj in this-procedure
          (input buf_gds-obj.obj-type   /* p-obj-type             */
          ,input buf_gds-obj.obj-code   /* p-obj-code             */
          ,input buf_gds-obj.artic      /* p-artic                */
          ,input buf_gds-obj.prod-type  /* p-prod-type            */
          ,input buf_gds-obj.prod-code  /* p-prod-code            */
          ,input v-cons-pay             /* p-cons-pay             */
          ,input v-base-rate            /* p-base-rate            */
          ,input v-base-scale           /* p-base-scale           */
          ,input v-base-rate-reason     /* p-base-rate-reason     */
          ,input p-new-start-date       /* p-archive-date         */
          ,input v-shift-on             /* p-shift-on             */
          ,input v-shift-date           /* p-shift-date           */
          ,input v-shift-num            /* p-shift-num            */
          ,input v-day-end-fact-order   /* p-day-end-fact-order   */
          ,input v-shift-end-fact-order /* p-shift-end-fact-order */
          ) .
      end.
      else do:
        assign
          v-need-copy-cost = true
        .
      end.

      define variable v-sum-type-list        as character no-undo .
      define variable v-sum-type             as character no-undo .
      define variable v-num-entries-sum-type as integer   no-undo .

      run ahrstutl-supp-line-sum-type-list in this-procedure
        (output v-sum-type-list /* p-sum-type-list */
        ) .

      assign
        v-num-entries-sum-type = num-entries(v-sum-type-list)
      .
      do v-ind = 1 to v-num-entries-sum-type
      :
        assign
          v-sum-type = entry(v-ind, v-sum-type-list)
        .
        if v-need-copy-cost = true
        or (v-need-copy-cost = false
            and not v-sum-type begins {&arh-cost}
            )
        then do:
          /* копируются остатки за исключением {&arh-cost} */
          /* или копируются все остатки */
          /* в зависимости от того была ли произведена инициализация */
          define buffer buf_temp-supp-gds for temp-supp-gds .

          for each buf_temp-supp-gds
            where buf_temp-supp-gds.artic     = buf_gds-obj.artic
              and buf_temp-supp-gds.prod-type = buf_gds-obj.prod-type
              and buf_temp-supp-gds.prod-code = buf_gds-obj.prod-code
          on error undo, return error return-value
          :

            for each buf_stk-supp-line
              where buf_stk-supp-line.obj-type   = p-obj-type
                and buf_stk-supp-line.obj-code   = p-obj-code
                and buf_stk-supp-line.cli-type   = buf_temp-supp-gds.cli-type
                and buf_stk-supp-line.cli-code   = buf_temp-supp-gds.cli-code
                and buf_stk-supp-line.artic      = buf_temp-supp-gds.artic
                and buf_stk-supp-line.prod-type  = buf_temp-supp-gds.prod-type
                and buf_stk-supp-line.prod-code  = buf_temp-supp-gds.prod-code
                and buf_stk-supp-line.fact-order = v-old-day-end-fact-order
                and buf_stk-supp-line.sum-type   begins v-sum-type
            on error undo, return error return-value
            :
              create buf_temp-stk-supp-line .
              assign
                &scop fp1 buf_temp-stk-supp-line.
                &scop fp2 = buf_stk-supp-line.
                {&stk-supp-line-pair-list}
                buf_temp-stk-supp-line.fact-order = v-day-end-fact-order
                buf_temp-stk-supp-line.fact-date  = p-new-start-date
                buf_temp-stk-supp-line.shift-date = ?
                buf_temp-stk-supp-line.shift-num  = 0
                &scop fp1   buf_temp-stk-supp-line.new-
                &scop fps1
                &scop fp2   = buf_stk-supp-line.
                &scop fps2
                &scop fp3
                &scop fp4
                {&price-pair-list}
              .
            end.

            if v-shift-on = true
            then do:
              for each buf_stk-supp-line
                where buf_stk-supp-line.obj-type   = p-obj-type
                  and buf_stk-supp-line.obj-code   = p-obj-code
                  and buf_stk-supp-line.cli-type   = buf_temp-supp-gds.cli-type
                  and buf_stk-supp-line.cli-code   = buf_temp-supp-gds.cli-code
                  and buf_stk-supp-line.artic      = buf_temp-supp-gds.artic
                  and buf_stk-supp-line.prod-type  = buf_temp-supp-gds.prod-type
                  and buf_stk-supp-line.prod-code  = buf_temp-supp-gds.prod-code
                  and buf_stk-supp-line.fact-order = v-old-day-end-fact-order
                  and buf_stk-supp-line.sum-type   begins v-sum-type
              on error undo, return error return-value
              :
                create buf_temp-stk-supp-line .
                assign
                  &scop fp1 buf_temp-stk-supp-line.
                  &scop fp2 = buf_stk-supp-line.
                  {&stk-supp-line-pair-list}
                  buf_temp-stk-supp-line.fact-order = v-shift-end-fact-order
                  buf_temp-stk-supp-line.fact-date  = p-new-start-date
                  buf_temp-stk-supp-line.shift-date = v-shift-date
                  buf_temp-stk-supp-line.shift-num  = v-shift-num

                  &scop fp1   buf_temp-stk-supp-line.new-
                  &scop fps1
                  &scop fp2   = buf_stk-supp-line.
                  &scop fps2
                  &scop fp3
                  &scop fp4
                  {&price-pair-list}
                .
              end.
            end.
          end.
        end.
      end.

      /* сохраняем информацию об остатке на начало складского архива */
      run store-line in this-procedure .

      /* обновляем итоговую информацию по объекту на основании данных по строке */
      run update-tot in this-procedure .
    end.
  end.

  run ahrstutl-supp-tot-sum-type-list in this-procedure
    (output v-sum-type-list
    ) .
  assign
    v-num-entries-sum-type = num-entries(v-sum-type-list)
  .
  do v-ind = 1 to v-num-entries-sum-type
  :
    assign
      v-sum-type = entry(v-ind, v-sum-type-list)
    .

    define buffer buf_temp-supp for temp-supp .

    for each buf_temp-supp
    on error undo, return error return-value
    :
      find first buf_temp-stk-supp-tot
        where buf_temp-stk-supp-tot.obj-type   = p-obj-type
          and buf_temp-stk-supp-tot.obj-code   = p-obj-code
          and buf_temp-stk-supp-tot.cli-type   = buf_temp-supp.cli-type
          and buf_temp-stk-supp-tot.cli-code   = buf_temp-supp.cli-code
          and buf_temp-stk-supp-tot.fact-order = v-day-end-fact-order
          and buf_temp-stk-supp-tot.sum-type   = v-sum-type
          and buf_temp-stk-supp-tot.cat-id     = {&single-cat-id}
        no-error .
      if not available buf_temp-stk-supp-tot
      then do:
        create buf_temp-stk-supp-tot .
        assign
          buf_temp-stk-supp-tot.obj-type   = p-obj-type
          buf_temp-stk-supp-tot.obj-code   = p-obj-code
          buf_temp-stk-supp-tot.cli-type   = buf_temp-supp.cli-type
          buf_temp-stk-supp-tot.cli-code   = buf_temp-supp.cli-code
          buf_temp-stk-supp-tot.sum-type   = v-sum-type
          buf_temp-stk-supp-tot.cat-id     = {&single-cat-id}
          buf_temp-stk-supp-tot.fact-order = v-day-end-fact-order
          buf_temp-stk-supp-tot.fact-date  = p-new-start-date
          buf_temp-stk-supp-tot.shift-date = ?
          buf_temp-stk-supp-tot.shift-num  = 0
        .
      end.

      if v-shift-on = true
      then do:
        find first buf_temp-stk-supp-tot
          where buf_temp-stk-supp-tot.obj-type   = p-obj-type
            and buf_temp-stk-supp-tot.obj-code   = p-obj-code
            and buf_temp-stk-supp-tot.cli-type   = buf_temp-supp.cli-type
            and buf_temp-stk-supp-tot.cli-code   = buf_temp-supp.cli-code
            and buf_temp-stk-supp-tot.fact-order = v-shift-end-fact-order
            and buf_temp-stk-supp-tot.sum-type   = v-sum-type
            and buf_temp-stk-supp-tot.cat-id     = {&single-cat-id}
          no-error .
        if not available buf_temp-stk-supp-tot
        then do:
          create buf_temp-stk-supp-tot .
          assign
            buf_temp-stk-supp-tot.obj-type   = p-obj-type
            buf_temp-stk-supp-tot.obj-code   = p-obj-code
            buf_temp-stk-supp-tot.cli-type   = buf_temp-supp.cli-type
            buf_temp-stk-supp-tot.cli-code   = buf_temp-supp.cli-code
            buf_temp-stk-supp-tot.sum-type   = v-sum-type
            buf_temp-stk-supp-tot.cat-id     = {&single-cat-id}
            buf_temp-stk-supp-tot.fact-order = v-shift-end-fact-order
            buf_temp-stk-supp-tot.fact-date  = p-new-start-date
            buf_temp-stk-supp-tot.shift-date = v-shift-date
            buf_temp-stk-supp-tot.shift-num  = v-shift-num
          .
        end.
      end.
    end.
  end.

  run store-tot in this-procedure .
end.


procedure cb_inahsp_store-temp-supp-gds :

  define input  parameter p-cli-type  as character no-undo .
  define input  parameter p-cli-code  as integer   no-undo .
  define input  parameter p-artic     as character no-undo .
  define input  parameter p-prod-type as character no-undo .
  define input  parameter p-prod-code as integer   no-undo .

  define buffer buf_temp-supp for temp-supp .
  define buffer buf_temp-supp-gds for temp-supp-gds .

  do
  on error undo, return error return-value
  :
    find first buf_temp-supp
      where buf_temp-supp.cli-type = p-cli-type
        and buf_temp-supp.cli-code = p-cli-code
      no-error .
    if not available buf_temp-supp
    then do:
      create buf_temp-supp .
      assign
        buf_temp-supp.cli-type = p-cli-type
        buf_temp-supp.cli-code = p-cli-code
      .
    end.

    find first buf_temp-supp-gds
      where buf_temp-supp-gds.cli-type  = p-cli-type
        and buf_temp-supp-gds.cli-code  = p-cli-code
        and buf_temp-supp-gds.artic     = p-artic
        and buf_temp-supp-gds.prod-type = p-prod-type
        and buf_temp-supp-gds.prod-code = p-prod-code
      no-error .
    if not available buf_temp-supp-gds
    then do:
      create buf_temp-supp-gds .
      assign
        buf_temp-supp-gds.cli-type  = p-cli-type
        buf_temp-supp-gds.cli-code  = p-cli-code
        buf_temp-supp-gds.artic     = p-artic
        buf_temp-supp-gds.prod-type = p-prod-type
        buf_temp-supp-gds.prod-code = p-prod-code
      .
    end.
  end.

end procedure. /* cb_inahsp_store-temp-supp-gds */

procedure process-gds-obj :

  define input  parameter p-obj-type             like ub.gds-obj.obj-type  no-undo .
  define input  parameter p-obj-code             like ub.gds-obj.obj-code  no-undo .
  define input  parameter p-artic                like ub.gds-obj.artic     no-undo .
  define input  parameter p-prod-type            like ub.gds-obj.prod-type no-undo .
  define input  parameter p-prod-code            like ub.gds-obj.prod-code no-undo .
  define input  parameter p-cons-pay             as integer   no-undo .
  define input  parameter p-base-rate            like ub.curr-accnt.exch-rate no-undo .
  define input  parameter p-base-scale           like ub.curr-accnt.exch-scale no-undo .
  define input  parameter p-base-rate-reason     as character no-undo .
  define input  parameter p-archive-date         as date      no-undo .
  define input  parameter p-shift-on             as logical   no-undo .
  define input  parameter p-shift-date           as date      no-undo .
  define input  parameter p-shift-num            as integer   no-undo .
  define input  parameter p-day-end-fact-order   as decimal   no-undo .
  define input  parameter p-shift-end-fact-order as decimal   no-undo .

  define buffer buf_goods              for ub.goods .
  define buffer buf_temp-parts         for temp-parts .
  define buffer buf_tt-clcparts        for tt-clcparts .
  define buffer buf_tt-allsum-line     for tt-allsum-line .
  define buffer buf_temp-stk-supp-line for temp-stk-supp-line .
  define buffer buf_temp-stk-supp-tot  for temp-stk-supp-tot .

  do
  on error undo, return error return-value
  :
    /* получаем количество по партиям на необходимую дату */
    run partslib-init-temp-parts-by-factord in this-procedure
      (input p-obj-type           /* p-obj-type           */
      ,input p-obj-code           /* p-obj-code           */
      ,input p-artic              /* p-artic              */
      ,input p-prod-type          /* p-prod-type          */
      ,input p-prod-code          /* p-prod-code          */
      ,input p-day-end-fact-order /* p-fact-order         */
      ,input false                /* p-include-fact-order */
      ) .

    /* вычисляем остаток в учетных ценах */
    /* с разбивками по НДС, НП */
    /* с разбивками по виду поставки */
    /* идем по всем партиям свободной зоны */
    /* во временной таблице уже находятся только те партии, которые нужны */
    for each buf_temp-parts
    on error undo, return error return-value
    :
      for each buf_tt-clcparts
      on error undo, return error return-value
      :
        delete buf_tt-clcparts .
      end.

      create buf_tt-clcparts .
      buffer-copy buf_temp-parts to buf_tt-clcparts .

      run clcprtsl_calc-ttable in this-procedure
        (input false /* paris-doc         */
        ,input false /* paris-cur         */
        ,input ?     /* parroad-tax       */
        ,input ?     /* parexcise         */
        ,input ?     /* parvat-pc         */
        ,input ?     /* parcons-vat-pc    */
        ,input ?     /* parslt-pc         */
        ,input ?     /* parbase-rate      */
        ,input ?     /* parbase-scale     */
        ,input ?     /* parr-b            */
        ,input ?     /* parcur-base       */
        ,input ?     /* parcur-road-tax   */
        ,input ?     /* parcur-excise     */
        ,input ?     /* parcur-vat-pc     */
        ,input ?     /* parcurcons-vat-pc */
        ,input ?     /* parcurslt-pc      */
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры clcprtsl_calc-ttable" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      find first buf_tt-allsum-line
        where buf_tt-allsum-line.sum-type = {&sum-general-sign}
        no-error .
      if available buf_tt-allsum-line
      then do:
        /* надо брать суммы с обратным знаком */
        assign
          v-fact-qnty      = - buf_tt-allsum-line.fact-qnty
          v-sum-base       = - buf_tt-allsum-line.sum-dsc-base-acc
          v-sum-rubl       = - buf_tt-allsum-line.sum-dsc-rubl-acc
          v-vat-base       = - buf_tt-allsum-line.vat-base-acc
          v-vat-rubl       = - buf_tt-allsum-line.vat-rubl-acc
          v-slt-base       = - buf_tt-allsum-line.slt-base-acc
          v-slt-rubl       = - buf_tt-allsum-line.slt-rubl-acc
          v-road-tax-base  = - buf_tt-allsum-line.road-tax-base-acc
          v-road-tax-rubl  = - buf_tt-allsum-line.road-tax-rubl-acc
          v-excise-base    = - buf_tt-allsum-line.excise-base-acc
          v-excise-rubl    = - buf_tt-allsum-line.excise-rubl-acc
          v-transport-base = - buf_tt-allsum-line.transport-base-acc
          v-transport-rubl = - buf_tt-allsum-line.transport-rubl-acc
          v-other-base     = - buf_tt-allsum-line.other-base-acc
          v-other-rubl     = - buf_tt-allsum-line.other-rubl-acc
        .
      end.
      else do:
        assign
          v-fact-qnty      = 0
          v-sum-base       = 0
          v-sum-rubl       = 0
          v-vat-base       = 0
          v-vat-rubl       = 0
          v-slt-base       = 0
          v-slt-rubl       = 0
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

      if
      &scop fl1  v-
      &scop fls1
      &scop fl2  = ?
      &scop fl3  or
      {&price-single-list}
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Программа clcprtsl_calc-ttable вернула неопределенные значения" skip
          "Расчет складского архива невозможен" skip
          "Объект" p-obj-type p-obj-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "Тип суммы" {&sum-general-sign} skip
          &scop fp1   "v-
          &scop fps1  "
          &scop fp2   v-
          &scop fps2
          &scop fp3
          &scop fp4   skip
          {&price-pair-list}
          view-as alert-box error .
        undo, return error return-value .
      end.


      /* сохраняем информацию о поставщиках (с разбиениями по типам поставки) */
      define variable v-ahsp-type-ind        as integer   no-undo .
      define variable v-ahsp-type-list       as character extent 5 no-undo
        initial [{&arh-repayment}, {&arh-cons_acc}, {&arh-cons_benf}, {&arh-resp_stor}, {&arh-old_cons}] .
      define variable v-allsum-sum-type-list as character extent 5 no-undo
        initial [{&sum-repayment-sign}, {&sum-cons_acc-sign}, {&sum-cons_benf-sign}, {&sum-resp_stor-sign}, {&sum-old-cons-sign}] .
      define variable v-ahsp-type            as character no-undo .
      define variable v-allsum-sum-type      as character no-undo .

      do v-ahsp-type-ind = 1 to extent(v-ahsp-type-list)
      :
        assign
          v-ahsp-type       = v-ahsp-type-list[v-ahsp-type-ind]
          v-allsum-sum-type = v-allsum-sum-type-list[v-ahsp-type-ind]
        .

        find first buf_tt-allsum-line
          where buf_tt-allsum-line.sum-type = v-allsum-sum-type
          no-error .
        if available buf_tt-allsum-line
        then do:
          /* надо брать суммы с обратным знаком */
          assign
            v-fact-qnty      = - buf_tt-allsum-line.fact-qnty
            v-sum-base       = - buf_tt-allsum-line.sum-dsc-base-acc
            v-sum-rubl       = - buf_tt-allsum-line.sum-dsc-rubl-acc
            v-vat-base       = - buf_tt-allsum-line.vat-base-acc
            v-vat-rubl       = - buf_tt-allsum-line.vat-rubl-acc
            v-slt-base       = - buf_tt-allsum-line.slt-base-acc
            v-slt-rubl       = - buf_tt-allsum-line.slt-rubl-acc
            v-road-tax-base  = - buf_tt-allsum-line.road-tax-base-acc
            v-road-tax-rubl  = - buf_tt-allsum-line.road-tax-rubl-acc
            v-excise-base    = - buf_tt-allsum-line.excise-base-acc
            v-excise-rubl    = - buf_tt-allsum-line.excise-rubl-acc
            v-transport-base = - buf_tt-allsum-line.transport-base-acc
            v-transport-rubl = - buf_tt-allsum-line.transport-rubl-acc
            v-other-base     = - buf_tt-allsum-line.other-base-acc
            v-other-rubl     = - buf_tt-allsum-line.other-rubl-acc
          .
        end.
        else do:
          assign
            v-fact-qnty      = 0
            v-sum-base       = 0
            v-sum-rubl       = 0
            v-vat-base       = 0
            v-vat-rubl       = 0
            v-slt-base       = 0
            v-slt-rubl       = 0
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

        if v-ahsp-type = {&arh-cons_benf}
        then do:
          assign
            v-fact-qnty = 0
          .
        end.

        if
        &scop fl1  v-
        &scop fls1
        &scop fl2  = ?
        &scop fl3  or
        {&price-single-list}
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Программа clcprtsl_calc-ttable вернула неопределенные значения" skip
            "Расчет складского архива невозможен" skip
            "Объект" p-obj-type p-obj-code skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            "Тип суммы" v-allsum-sum-type skip
            &scop fp1   "v-
            &scop fps1  "
            &scop fp2   v-
            &scop fps2
            &scop fp3
            &scop fp4   skip
            {&price-pair-list}
            view-as alert-box error .
          undo, return error return-value .
        end.

        define variable ind-ext    as integer no-undo .
        define variable v-cat-id   as character no-undo extent 4 .
        define variable v-sum-type as character no-undo extent 4 .

        assign
          v-sum-type[1] = {&arh-cost}
          v-cat-id[1]   = {&single-cat-id}
          v-sum-type[2] = {&arh-cost} + {&arh-supp}
          v-cat-id[2]   = v-ahsp-type
        .
        do ind-ext = 1 to 2
        :
          find first buf_temp-stk-supp-line
            where buf_temp-stk-supp-line.obj-type   = p-obj-type
              and buf_temp-stk-supp-line.obj-code   = p-obj-code
              and buf_temp-stk-supp-line.cli-type   = buf_temp-parts.supp-type
              and buf_temp-stk-supp-line.cli-code   = buf_temp-parts.supp-code
              and buf_temp-stk-supp-line.artic      = p-artic
              and buf_temp-stk-supp-line.prod-type  = p-prod-type
              and buf_temp-stk-supp-line.prod-code  = p-prod-code
              and buf_temp-stk-supp-line.fact-order = p-day-end-fact-order
              and buf_temp-stk-supp-line.sum-type   = v-sum-type[ind-ext]
              and buf_temp-stk-supp-line.cat-id     = v-cat-id[ind-ext]
            no-error .
          if not available buf_temp-stk-supp-line
          then do:
            create buf_temp-stk-supp-line .
            assign
              buf_temp-stk-supp-line.obj-type   = p-obj-type
              buf_temp-stk-supp-line.obj-code   = p-obj-code
              buf_temp-stk-supp-line.cli-type   = buf_temp-parts.supp-type
              buf_temp-stk-supp-line.cli-code   = buf_temp-parts.supp-code
              buf_temp-stk-supp-line.artic      = p-artic
              buf_temp-stk-supp-line.prod-type  = p-prod-type
              buf_temp-stk-supp-line.prod-code  = p-prod-code
              buf_temp-stk-supp-line.fact-order = p-day-end-fact-order
              buf_temp-stk-supp-line.sum-type   = v-sum-type[ind-ext]
              buf_temp-stk-supp-line.cat-id     = v-cat-id[ind-ext]
            .
            assign
              buf_temp-stk-supp-line.fact-date    = p-archive-date
              buf_temp-stk-supp-line.shift-date   = ?
              buf_temp-stk-supp-line.shift-num    = 0
            .
          end.

          assign
            &scop FT1    buf_temp-stk-supp-line.new-
            &scop FTs1
            &scop FT2    = buf_temp-stk-supp-line.new-
            &scop FTs2
            &scop FT3    + v-
            &scop FTs3
            &scop FT4
            &scop FT5
            {&price-trio-list}
          .

          if v-shift-on = true
          then do:
            find first buf_temp-stk-supp-line
              where buf_temp-stk-supp-line.obj-type   = p-obj-type
                and buf_temp-stk-supp-line.obj-code   = p-obj-code
                and buf_temp-stk-supp-line.cli-type   = buf_temp-parts.supp-type
                and buf_temp-stk-supp-line.cli-code   = buf_temp-parts.supp-code
                and buf_temp-stk-supp-line.artic      = p-artic
                and buf_temp-stk-supp-line.prod-type  = p-prod-type
                and buf_temp-stk-supp-line.prod-code  = p-prod-code
                and buf_temp-stk-supp-line.fact-order = p-shift-end-fact-order
                and buf_temp-stk-supp-line.sum-type   = v-sum-type[ind-ext]
                and buf_temp-stk-supp-line.cat-id     = v-cat-id[ind-ext]
              no-error .
            if not available buf_temp-stk-supp-line
            then do:
              create buf_temp-stk-supp-line .
              assign
                buf_temp-stk-supp-line.obj-type   = p-obj-type
                buf_temp-stk-supp-line.obj-code   = p-obj-code
                buf_temp-stk-supp-line.cli-type   = buf_temp-parts.supp-type
                buf_temp-stk-supp-line.cli-code   = buf_temp-parts.supp-code
                buf_temp-stk-supp-line.artic      = p-artic
                buf_temp-stk-supp-line.prod-type  = p-prod-type
                buf_temp-stk-supp-line.prod-code  = p-prod-code
                buf_temp-stk-supp-line.fact-order = p-shift-end-fact-order
                buf_temp-stk-supp-line.sum-type   = v-sum-type[ind-ext]
                buf_temp-stk-supp-line.cat-id     = v-cat-id[ind-ext]
              .
              assign
                buf_temp-stk-supp-line.fact-date    = p-archive-date
                buf_temp-stk-supp-line.shift-date   = p-shift-date
                buf_temp-stk-supp-line.shift-num    = p-shift-num
              .
            end.

            assign
              &scop FT1    buf_temp-stk-supp-line.new-
              &scop FTs1
              &scop FT2    = buf_temp-stk-supp-line.new-
              &scop FTs2
              &scop FT3    + v-
              &scop FTs3
              &scop FT4
              &scop FT5
              {&price-trio-list}
            .
          end.
        end.
      end.
    end.
  end.
end procedure. /* process-gds-obj */

procedure store-line :

  define buffer buf_temp-stk-supp-line for temp-stk-supp-line .
  define buffer buf_stk-supp-line      for ub.stk-supp-line .

  do
  on error undo, return error return-value
  :
    for each buf_temp-stk-supp-line
    on error undo, return error return-value
    :
      create buf_stk-supp-line .
      buffer-copy buf_temp-stk-supp-line to buf_stk-supp-line
      assign
        &scop fp1   buf_stk-supp-line.
        &scop fps1
        &scop fp2   = buf_temp-stk-supp-line.new-
        &scop fps2
        &scop fp3
        &scop fp4
        {&price-pair-list}
      .
    end.
  end.
end procedure. /* store-line */

procedure store-tot :

  define buffer buf_temp-stk-supp-tot for temp-stk-supp-tot .
  define buffer buf_stk-supp-tot      for ub.stk-supp-tot .

  do
  on error undo, return error return-value
  :
    for each buf_temp-stk-supp-tot
    on error undo, return error return-value
    :
      create buf_stk-supp-tot .
      buffer-copy buf_temp-stk-supp-tot to buf_stk-supp-tot
      assign
        &scop fp1   buf_stk-supp-tot.
        &scop fps1
        &scop fp2   = buf_temp-stk-supp-tot.new-
        &scop fps2
        &scop fp3
        &scop fp4
        {&price-pair-list}
      .
    end.
  end.
end procedure. /* store-tot */

procedure clear-tot :

  define buffer buf_temp-stk-supp-tot for temp-stk-supp-tot .

  do
  on error undo, return error return-value
  :
    for each buf_temp-stk-supp-tot
    on error undo, return error return-value
    :
      delete buf_temp-stk-supp-tot .
    end.
  end.
end procedure. /* clear-tot */

procedure clear-line :

  define buffer buf_temp-stk-supp-line for temp-stk-supp-line .

  do
  on error undo, return error return-value
  :
    for each buf_temp-stk-supp-line
    on error undo, return error return-value
    :
      delete buf_temp-stk-supp-line .
    end.
  end.
end procedure. /* clear-line */


procedure update-tot :

  define buffer buf_temp-stk-supp-line for temp-stk-supp-line .
  define buffer buf_temp-stk-supp-tot  for temp-stk-supp-tot .

  do
  on error undo, return error return-value
  :
    for each buf_temp-stk-supp-line
    on error undo, return error return-value
    :
      find first buf_temp-stk-supp-tot
        where buf_temp-stk-supp-tot.obj-type   = p-obj-type
          and buf_temp-stk-supp-tot.obj-code   = p-obj-code
          and buf_temp-stk-supp-tot.cli-type   = buf_temp-stk-supp-line.cli-type
          and buf_temp-stk-supp-tot.cli-code   = buf_temp-stk-supp-line.cli-code
          and buf_temp-stk-supp-tot.fact-order = v-day-end-fact-order
          and buf_temp-stk-supp-tot.sum-type   = buf_temp-stk-supp-line.sum-type
          and buf_temp-stk-supp-tot.cat-id     = buf_temp-stk-supp-line.cat-id
        no-error .
      if not available buf_temp-stk-supp-tot
      then do:
        create buf_temp-stk-supp-tot .
        assign
          buf_temp-stk-supp-tot.obj-type   = p-obj-type
          buf_temp-stk-supp-tot.obj-code   = p-obj-code
          buf_temp-stk-supp-tot.cli-type   = buf_temp-stk-supp-line.cli-type
          buf_temp-stk-supp-tot.cli-code   = buf_temp-stk-supp-line.cli-code
          buf_temp-stk-supp-tot.sum-type   = buf_temp-stk-supp-line.sum-type
          buf_temp-stk-supp-tot.cat-id     = buf_temp-stk-supp-line.cat-id
          buf_temp-stk-supp-tot.fact-order = v-day-end-fact-order
          buf_temp-stk-supp-tot.fact-date  = p-new-start-date
          buf_temp-stk-supp-tot.shift-date = ?
          buf_temp-stk-supp-tot.shift-num  = 0
        .
      end.
      assign
        &scop FT1    buf_temp-stk-supp-tot.new-
        &scop FTs1
        &scop FT2    = buf_temp-stk-supp-tot.new-
        &scop FTs2
        &scop FT3    + buf_temp-stk-supp-line.new-
        &scop FTs3
        &scop FT4
        &scop FT5
        {&price-trio-list}
      .

      if v-shift-on = true
      then do:
        find first buf_temp-stk-supp-tot
          where buf_temp-stk-supp-tot.obj-type   = p-obj-type
            and buf_temp-stk-supp-tot.obj-code   = p-obj-code
            and buf_temp-stk-supp-tot.cli-type   = buf_temp-stk-supp-line.cli-type
            and buf_temp-stk-supp-tot.cli-code   = buf_temp-stk-supp-line.cli-code
            and buf_temp-stk-supp-tot.fact-order = v-shift-end-fact-order
            and buf_temp-stk-supp-tot.sum-type   = buf_temp-stk-supp-line.sum-type
            and buf_temp-stk-supp-tot.cat-id     = buf_temp-stk-supp-line.cat-id
          no-error .
        if not available buf_temp-stk-supp-tot
        then do:
          create buf_temp-stk-supp-tot .
          assign
            buf_temp-stk-supp-tot.obj-type   = p-obj-type
            buf_temp-stk-supp-tot.obj-code   = p-obj-code
            buf_temp-stk-supp-tot.cli-type   = buf_temp-stk-supp-line.cli-type
            buf_temp-stk-supp-tot.cli-code   = buf_temp-stk-supp-line.cli-code
            buf_temp-stk-supp-tot.sum-type   = buf_temp-stk-supp-line.sum-type
            buf_temp-stk-supp-tot.cat-id     = buf_temp-stk-supp-line.cat-id
            buf_temp-stk-supp-tot.fact-order = v-shift-end-fact-order
            buf_temp-stk-supp-tot.fact-date  = p-new-start-date
            buf_temp-stk-supp-tot.shift-date = v-shift-date
            buf_temp-stk-supp-tot.shift-num  = v-shift-num
          .
        end.
        assign
          &scop FT1    buf_temp-stk-supp-tot.new-
          &scop FTs1
          &scop FT2    = buf_temp-stk-supp-tot.new-
          &scop FTs2
          &scop FT3    + buf_temp-stk-supp-line.new-
          &scop FTs3
          &scop FT4
          &scop FT5
          {&price-trio-list}
        .
      end.
    end.
  end.

end procedure. /* update-tot */


procedure ahrstutl-supp-tot-sum-type-list :

  define output parameter p-sum-type-list as character no-undo .

  do
  on error undo, return error return-value
  :
    define variable v-ind                    as integer   no-undo .
    define variable v-num-entries-TDEDT_List as integer   no-undo .

    assign
      v-num-entries-TDEDT_List = num-entries({&TDEDT_List})
    .
    assign
      p-sum-type-list = {&arh-cost}
    .
    do v-ind = 1 to v-num-entries-TDEDT_List
    :
      assign
        p-sum-type-list = p-sum-type-list
                        + {&comma-char}
                        + {&arh-sadt} + entry(v-ind, {&TDEDT_List})
      .
    end.
    do v-ind = 1 to v-num-entries-TDEDT_List
    :
      assign
        p-sum-type-list = p-sum-type-list
                        + {&comma-char}
                        + {&arh-csdt} + entry(v-ind, {&TDEDT_List})
      .
    end.
  end.

end procedure. /* ahrstutl-supp-tot-sum-type-list */


procedure ahrstutl-supp-line-sum-type-list :

  define output parameter p-sum-type-list as character no-undo .

  do
  on error undo, return error return-value
  :
    define variable v-ind                    as integer   no-undo .
    define variable v-num-entries-TDEDT_List as integer   no-undo .

    assign
      v-num-entries-TDEDT_List = num-entries({&TDEDT_List})
    .

    assign
      p-sum-type-list = {&arh-cost}
    .
    do v-ind = 1 to v-num-entries-TDEDT_List
    :
      assign
        p-sum-type-list = p-sum-type-list
                        + {&comma-char}
                        + {&arh-sadt} + entry(v-ind, {&TDEDT_List})
      .
    end.
    do v-ind = 1 to v-num-entries-TDEDT_List
    :
      assign
        p-sum-type-list = p-sum-type-list
                        + {&comma-char}
                        + {&arh-csdt} + entry(v-ind, {&TDEDT_List})
      .
    end.
  end.

end procedure. /* ahrstutl-supp-line-sum-type-list */