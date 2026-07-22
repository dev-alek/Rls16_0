/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Кусок процедуры из in-doc.w

Автор: Чернова Светлана Александровна
Дата создания: 09/21/06
Author: Svetlana Chernova
Creation date: 09/21/06

Не влазил в UIB
*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-vat-pc        like ub.doc-line.vat-pc    no-undo.
define variable v-slt-pc        like ub.doc-line.slt-pc    no-undo.
define variable v-have-slt-pc   as logical                 no-undo.
define variable v-host-code     like ub.sysconf.host-code  no-undo.
define variable b-c             as integer                 no-undo. /* обрабатываемый бар-код */
define variable b-c-char        as character               no-undo.
define variable rate            as decimal                 no-undo. /* коэффициент для единиц из бар-кода */
define variable temp-mes        as character               no-undo.
define variable is-petrolium    as logical                 no-undo.
define variable is-pieces       as logical                 no-undo.
define variable varext-cycle    as logical                 no-undo.
define variable v-part-code     as character               no-undo.

assign
  /*line-mode = {&update}*/
  line-rec = ?
  prt-rec = ?
  varlns-cnt = 1
  add-sens = b-add:SENSITIVE  in frame {&frame-name}
  b-c = 0
  gds-rec = ?
  pardoc-rec = RECID(t-doc)
  .
DO WHILE b-c <> ?:
   run str/chs-bc.w (parparentproc, "Строка накладной № " + t-doc.doc-code, add-sens, YES, YES, output b-c-char, output rate, output ret-mode, input-output add-scan, input-output bar-str).
   b-c = integer(b-c-char).
      IF b-c <> ? then DO:
      run checkTypeByBarCode in this-procedure (b-c, t-doc.ext-doc-type) no-error.
      if error-status:error then next.

      find ub.bar-code where ub.bar-code.b-code = b-c no-lock no-error.
      find ub.goods where ub.goods.gds-code  = ub.bar-code.gds-code no-lock.
      find ub.gds-prt where ub.gds-prt.upper-code = ub.goods.prt-root no-lock.
      ASSIGN gds-rec = RECID(ub.goods).
      FIND ub.doc-line where ub.doc-line.doc-code  = t-doc.doc-code  and
                          ub.doc-line.artic     = ub.goods.artic     and
                          ub.doc-line.prod-type = ub.goods.prod-type and
                          ub.doc-line.prod-code = ub.goods.prod-code NO-LOCK NO-ERROR.
      IF AVAILABLE ub.doc-line THEN
         assign
         /*line-mode = {&update}*/
         line-rec  = RECID(ub.doc-line).
      ELSE DO:
          IF t-doc.flag_ THEN DO:
             MESSAGE "Товар: " ub.goods.artic " " ub.goods.prod-type " " ub.goods.prod-code " не найден в документе."
             VIEW-AS ALERT-BOX ERROR BUTTONS OK.
             UNDO, return no-apply.
          END.
          assign
              /*line-mode = {&add-def}*/
              line-rec = ?.
          assign prt-rec   = ?
                 varnotes = ''
                 varlns-cnt = 1.
      END.
      d-l:
      DO transaction ON ERROR   UNDO d-l, return error return-value :
         /*Если не включен флаг добавить кол-во*/
         IF not add-scan THEN DO:
            if {&term-b-c-no-empty} THEN DO:
               find ub.gds-prt where ub.gds-prt.node-code = ub.bar-code.node-code no-lock.
               /*Если нет еще ни одного признака идем все одно через строку,
                 чтобы завести цену*/
               if NOT AVAILABLE doc-line THEN do:
                 run str/in-line.w (input  parparentproc,
                                    input  {&update},
                                    input  pardoc-rec,
                                    input-output  line-rec,
                                    input  gds-rec,
                                    input  varlns-cnt,
                                    output varext-cycle,
                                    0,
                                    ?,
                                    varinplnsum) no-error.
               end.
               ELSE DO:
                  run str/out-prt.w (
                       parparentproc ,
                       pardoc-rec    ,
                       line-rec      ,
                       gds-rec       ,
                       {&prt-def}    ,
                       recid (gds-prt),
                       {&g#term})
                       no-error.
                  if error-status :error then do: undo d-l, leave. end.
                  run str/chk-prt.p (line-rec, no, buffer t-doc) no-error.
                  if error-status :error THEN do:
                    message
                      vss-workfile vss-revision vss-description skip
                      "Ошибка про проверке разнесения строки по признакам" skip
                      error-status :get-message(1) skip
                      return-value skip
                      view-as alert-box error .
                    UNDO d-l, LEAVE.
                  end.
               END.
            END.
            ELSE do:
              run str/in-line.w (input  parparentproc,
                                 input  (if line-rec = ? then {&add-def} else  {&update} ),
                                 input  pardoc-rec,
                                 input-output  line-rec,
                                 input  gds-rec,
                                 input  varlns-cnt,
                                 output varext-cycle,
                                 0,
                                 ?,
                                 varinplnsum) no-error.
            end.
         END.
         ELSE DO:
            /*терминальный бар-код*/
            if {&term-b-c} THEN DO:
               /*Создадим временные таблицы на основе таблиц из БД и скопируем через стандартный алгоритм копирования*/
               /*Нельзя пускать по первому признаку, т.к. сначала следует указать цену*/
               if NOT AVAILABLE doc-line THEN do:
                 run str/in-line.w (input  parparentproc,
                                    input  {&update},
                                    input  pardoc-rec,
                                    input-output  line-rec,
                                    input  gds-rec,
                                    input  varlns-cnt,
                                    output varext-cycle,
                                    input  rate,
                                    input  "doc",
                                    input  varinplnsum ) no-error.
               end.
               ELSE DO:
                  run str/copy-tmp.p (input parparentproc, input pardoc-rec, input gds-rec, b-c, rate) no-error.
                  if error-status :error THEN do: UNDO d-l, LEAVE. end.
               END.
            END.
            /*нетерминальный бар-код*/
            ELSE DO:
               /*Строка уже есть в данной накладной*/
               IF AVAILABLE ub.doc-line THEN DO:
                 /* Код партии для алкогольной продукции */
                 run get-alc-part in this-procedure
                   (input recid(ub.doc-line),
                    output v-part-code
                   ).
                 /*добавляем кол-во из бар-кода*/
                 IF NOT t-doc.flag_ THEN DO:
                    find ub.goods where ub.goods.artic     = ub.doc-line.artic     and
                                     ub.goods.prod-type = ub.doc-line.prod-type and
                                     ub.goods.prod-code = ub.doc-line.prod-code no-lock.
                    find ub.units   where ub.units.unit-name    = ub.goods.unit-base no-lock.
                    run prev-cor-line in this-procedure
                      ( input ub.units.type
                      , input ub.doc-line.obj-type
                      , input ub.doc-line.obj-code
                      , input ub.doc-line.artic
                      , input ub.doc-line.prod-type
                      , input ub.doc-line.prod-code
                      ) no-error.
                    if error-status :error then do:
                       message return-value view-as alert-box error.
                       undo d-l, leave.
                    end.
                    /*направление всех пересчетов cl-qnty -> doc-qnty, fact-qnty*/
                    run str/cor-line.p
                      (input parparentproc
                      ,input-output line-rec                                                                  /* par-rec-doc-line    */
                      ,input ub.doc-line.doc-code                                                             /* pardoc-code         */
                      ,input ub.doc-line.prod-type                                                            /* parprod-type        */
                      ,input ub.doc-line.prod-code                                                            /* parprod-code        */
                      ,input ub.doc-line.artic                                                                /* parartic            */
                      ,input ub.doc-line.cli-qnty  + rate / ub.doc-line.cli-base-rate                         /* parcli-qnty         */
                      ,input ub.doc-line.cli-base-rate                                                        /* parcli-base-rate    */
                      ,input (ub.doc-line.cli-qnty  + rate / ub.doc-line.cli-base-rate) * ub.doc-line.cli-base-rate /* parfact-qnty        */
                      ,input (ub.doc-line.cli-qnty  + rate / ub.doc-line.cli-base-rate) * ub.doc-line.cli-base-rate /* pardoc-qnty         */
                      ,input ub.doc-line.unit-cli                                                             /* parunit-cli         */
                      ,input ub.doc-line.vat-pc                                                               /* parvat-pc           */
                      ,input ub.doc-line.slt-pc                                                               /* parslt-pc           */
                      ,input ub.doc-line.price-cli                                                            /* parprice-cli        */
                      ,input ub.doc-line.price-base                                                           /* parprice-base       */
                      ,input ub.doc-line.price-rubl                                                           /* parprice-rubl       */
                      ,input ub.doc-line.new-price-sale                                                       /* parprice-rubl       */
                      ,input ub.doc-line.wt-brutto                                                            /* parnum-place        */
                      ,input ub.doc-line.num-place                                                            /* parwt-brutto        */
                      ,input ub.doc-line.road-tax                                                             /* parroad-tax         */
                      ,input ub.doc-line.excise                                                               /* parexcise           */
                      ,input ub.doc-line.doc-density                                                          /* pardoc-density      */
                      ,input ub.doc-line.temperature                                                          /* partemperature      */
                      ,input ?                                                                                /* parcontract-code    */
                      ,input ?                                                                                /* parlast-date        */
                      ,input ub.doc-line.cli-qnty  + rate / ub.doc-line.cli-base-rate                         /* parfact-qnty-kg     */
                      ,input ub.doc-line.fact-density                                                         /* parfact-density     */
                      ,input ?                                                                                /* parcst-code         */
                      ,input no                     /* paralc-update              */
                      ,input v-part-code            /* paralc-part-code           */
                      ,input ?                      /* paralc-mark-db-num         */
                      ,input ?                      /* paralc-mark-code           */
                      ,input ?                      /* paralc-bottling-date       */
                      ,input ?                      /* paralc-ref-ab-path         */
                      ,input ?                      /* paralc-quality-certif-path */
                      ,input ?                      /* paralc-imp-type            */
                      ,input ?                      /* paralc-imp-code            */
                      ,input ?                      /* paralc-certif-path         */
                      ) no-error.
                    if error-status :error then do:
                      if error-status :get-message(1) <> ""
                      then do:
                        message
                          vss-workfile vss-revision vss-description skip
                          "Ошибка при вызове процедуры cor-line.p" skip
                          error-status :get-message(1) skip
                          return-value skip
                          view-as alert-box error .
                      end.
                      UNDO d-l, leave.
                    end.
                 END.
                 ELSE DO:
                    find ub.goods where ub.goods.artic  = ub.doc-line.artic     and
                                     ub.goods.prod-type = ub.doc-line.prod-type and
                                     ub.goods.prod-code = ub.doc-line.prod-code no-lock.
                    { str/is-petrl.i
                      ub.goods.artic
                      ub.goods.prod-type
                      ub.goods.prod-code
                      is-petrolium
                      is-pieces
                      no-error
                    }
                    if is-petrolium and not is-pieces then do:
                       MESSAGE "В жидком топливе нельзя редактировать фактическое количество".
                       display ub.doc-line.fact-qnty WITH BROWSE {&browse-name}.
                       return error.
                    end.
                    run str/cor-line.p
                      (input parparentproc
                      ,input-output line-rec               /* par-rec-doc-line    */
                      ,input ub.doc-line.doc-code          /* pardoc-code         */
                      ,input ub.doc-line.prod-type         /* parprod-type        */
                      ,input ub.doc-line.prod-code         /* parprod-code        */
                      ,input ub.doc-line.artic             /* parartic            */
                      ,input ub.doc-line.cli-qnty          /* parcli-qnty         */
                      ,input ub.doc-line.cli-base-rate     /* parcli-base-rate    */
                      ,input ub.doc-line.fact-qnty + rate  /* parfact-qnty        */
                      ,input ub.doc-line.doc-qnty          /* pardoc-qnty         */
                      ,input ub.doc-line.unit-cli          /* parunit-cli         */
                      ,input ub.doc-line.vat-pc            /* parvat-pc           */
                      ,input ub.doc-line.slt-pc            /* parslt-pc           */
                      ,input ub.doc-line.price-cli         /* parprice-cli        */
                      ,input ub.doc-line.price-base        /* parprice-base       */
                      ,input ub.doc-line.price-rubl        /* parprice-rubl       */
                      ,input ub.doc-line.new-price-sale    /* parprice-rubl       */
                      ,input ub.doc-line.wt-brutto         /* parnum-place        */
                      ,input ub.doc-line.num-place         /* parwt-brutto        */
                      ,input ub.doc-line.road-tax          /* parroad-tax         */
                      ,input ub.doc-line.excise            /* parexcise           */
                      ,input ub.doc-line.doc-density       /* pardoc-density      */
                      ,input ub.doc-line.temperature       /* partemperature      */
                      ,input ?                             /* parcontract-code    */
                      ,input ?                             /* parlast-date        */
                      ,input ?                             /* parfact-qnty-kg     */
                      ,input ub.doc-line.fact-density      /* parfact-density     */
                      ,input ?                             /* parcst-code         */
                      ,input no                         /* paralc-update              */
                      ,input v-part-code                /* paralc-part-code           */
                      ,input ?                          /* paralc-mark-db-num         */
                      ,input ?                          /* paralc-mark-code           */
                      ,input ?                          /* paralc-bottling-date       */
                      ,input ?                          /* paralc-ref-ab-path         */
                      ,input ?                          /* paralc-quality-certif-path */
                      ,input ?                          /* paralc-imp-type            */
                      ,input ?                          /* paralc-imp-code            */
                      ,input ?                          /* paralc-certif-path         */
                      ) no-error.
                    if error-status :error
                    then do:
                      if error-status :get-message(1) <> ""
                      then do:
                        message
                          vss-workfile vss-revision vss-description skip
                          "Ошибка при вызове процедуры cor-line.p" skip
                          error-status :get-message(1) skip
                          return-value skip
                          view-as alert-box error .
                      end.
                      UNDO d-l, leave.
                    end.
                 END.
                 run str/chk-prt.p (line-rec, no, buffer t-doc) no-error.
                 if error-status :error THEN do:
                   message
                     vss-workfile vss-revision vss-description skip
                     "Ошибка про проверке разнесения строки по признакам" skip
                     error-status :get-message(1) skip
                     return-value skip
                     view-as alert-box error .
                    UNDO d-l, leave.
                  end.
               END.
               ELSE DO: /* not available doc-line */
                 IF t-doc.status_ = {&wayb} THEN DO:
                    /*добавляем строку с заданым кол-ом из бар-кода и редактируем ее*/
                    run str/in-line.w (input  parparentproc,
                                       input  {&update},
                                       input  pardoc-rec,
                                       input-output  line-rec,
                                       input  gds-rec,
                                       input  varlns-cnt,
                                       output varext-cycle,
                                       rate,
                                       "doc",
                                       varinplnsum) no-error.
                 END.
                 /*Запрос обрабатываем без редактирования, пытаясь подставить какую-либо цену*/
                 ELSE DO:
                   { gbl/hostcode.i t-doc.obj-type t-doc.obj-code v-host-code }
                   { gbl/pftxvalg.i ub.goods.gds-code {&vat-tax-code} ? v-host-code t-doc.obj-type t-doc.obj-code v-vat-pc no-error }
                   ASSIGN varprice-cli-temp      = 0
                          varprice-base-temp     = 0
                          varprice-rubl-temp     = 0
                          varvat-pc         = v-vat-pc
                          varcli-base-rate  = ub.goods.cli-base-rate
                          vardoc-qnty       = 0
                          varfact-qnty      = 0
                          varroad-tax       = 0
                          varexcise         = 0
                          vartransport-base = 0
                          vartransport-rubl = 0
                          varother-base     = 0
                          varother-rubl     = 0
                          varartic          = ub.goods.artic
                          varprod-type      = ub.goods.prod-type
                          varprod-code      = ub.goods.prod-code
                   .
                   run cpprclig in this-procedure   (
                    input        t-doc.doc-code          ,
                    input        t-doc.cli-code          ,
                    input        t-doc.cli-type          ,
                    input        t-doc.host-code         ,
                    input        t-doc.base-rate         ,
                    input        t-doc.base-scale        ,
                    input        t-doc.exch-rate         ,
                    input        t-doc.exch-scale        ,
                    input        t-doc.vat-type          ,
                    input        t-doc.slt-type          ,
                    input        ub.goods.artic          ,
                    input        ub.goods.prod-type      ,
                    input        ub.goods.prod-code      ,
                    input        yes                     ,
                    input        varcli-base-rate        ,
                    input        vartransport-rubl       ,
                    input        varother-rubl           ,
                    output       varprice-cli            ,
                    output       varprice-base           ,
                    output       varprice-rubl           ,
                    input-output varvat-pc               ,
                    input-output varslt-pc               ,
                    input-output varroad-tax             ,
                    input-output varexcise               ) no-error.
                   { str/stprqr.i var}
                   RUN tax-val in this-procedure
                     (input  ?                     /* parartic      */
                     ,input  ?                     /* parprod-type  */
                     ,input  ?                     /* parprod-code  */
                     ,input  ?                     /* parunit-base  */
                     ,input  ?                     /* parnode-code  */
                     ,input  ?                     /* parunits-type */
                     ,input  recid(ub.goods)       /* parrec-id     */
                     ,input  no                    /* paris-log     */
                     ,input  rdtaxcdvalue          /* rdtaxcdvalue  */
                     ,input  vattaxcdvalue         /* vattaxcdvalue */
                     ,input  exctaxcdvalue         /* exctaxcdvalue */
                     ,input  no                    /* only-check    */
                     ,input  v-cntxt-host-code-obj /* parhost-code  */
                     ,input  v-cntxt-obj-type      /* parobj-type   */
                     ,input  v-cntxt-obj-code      /* parobj-code   */
                     ,input  ?                     /* parroad-tax   */
                     ,input  ?                     /* parexcise     */
                     ,output temp-mes              /* parerr-mes    */
                     ,input-output temp-sale       /* parprice-sale */
                     ) no-error.
                   if error-status :error
                   then do:
                     return no-apply.
                   end.
                   define buffer exc-tt-tax for tt-tax.
                   find tt-tax where tt-tax.tax-code = integer(rdtaxcdvalue) no-lock.
                   find exc-tt-tax where exc-tt-tax.tax-code = integer(exctaxcdvalue) no-lock.
                   /*добавляем кол-во из бар-кода*/
                   find ub.units   where ub.units.unit-name    = ub.goods.unit-base no-lock.
                   run prev-cor-line in this-procedure
                     ( input ub.units.type
                     , input t-doc.obj-type
                     , input t-doc.obj-code
                     , input ub.goods.artic
                     , input ub.goods.prod-type
                     , input ub.goods.prod-code
                     ) no-error.
                   if error-status :error then do:
                      message return-value view-as alert-box error.
                      undo d-l, leave.
                   end.
                   /*направление всех пересчетов cli-qnty -> doc-qnty, fact-qnty*/
                   { gbl/hostcode.i t-doc.obj-type t-doc.obj-code v-host-code }
                   { gbl/pftxvalg.i ub.goods.gds-code {&vat-tax-code} ? v-host-code t-doc.obj-type t-doc.obj-code v-vat-pc no-error }
                   { gbl/pftxvalg.i ub.goods.gds-code {&slt-tax-code} ? v-host-code t-doc.obj-type t-doc.obj-code v-slt-pc no-error }
                   run str/cor-line.p
                     (input parparentproc
                     ,input-output line-rec                                           /* par-rec-doc-line    */
                     ,input t-doc.doc-code                                            /* pardoc-code         */
                     ,input ub.goods.prod-type                                        /* parprod-type        */
                     ,input ub.goods.prod-code                                        /* parprod-code        */
                     ,input ub.goods.artic                                            /* parartic            */
                     ,input rate / ub.goods.cli-base-rate                             /* parcli-qnty         */
                     ,input ub.goods.cli-base-rate                                    /* parcli-base-rate    */
                     ,input (rate / ub.goods.cli-base-rate) * ub.goods.cli-base-rate  /* parfact-qnty        */
                     ,input (rate / ub.goods.cli-base-rate) * ub.goods.cli-base-rate  /* pardoc-qnty         */
                     ,input ub.goods.unit-cli                                         /* parunit-cli         */
                     ,input v-vat-pc                                                  /* parvat-pc           */
                     ,input v-slt-pc                                                  /* parslt-pc           */
                     ,input varprice-cli-temp                                         /* parprice-cli        */
                     ,input varprice-base-temp                                        /* parprice-base       */
                     ,input varprice-rubl-temp                                        /* parprice-rubl       */
                     ,input ?                                                         /* parprice-rubl       */
                     ,input ?                                                         /* parnum-place        */
                     ,input ?                                                         /* parwt-brutto        */
                     ,input if available tt-tax then tt-tax.rate-value else 0         /* parroad-tax         */
                     ,input if available exc-tt-tax then exc-tt-tax.rate-value else 0 /* parexcise           */
                     ,input ?                                                         /* pardensity          */
                     ,input ?                                                         /* partemperature      */
                     ,input ?                                                         /* parcontract-code    */
                     ,input ?                                                         /* parlast-date        */
                     ,input rate / ub.goods.cli-base-rate                             /* parfact-qnty-kg     */
                     ,input ?                                                         /* parfact-density     */
                     ,input ?                                                         /* parcst-code         */
                     ,input no                                                        /* paralc-update              */
                     ,input v-part-code                                               /* paralc-part-code           */
                     ,input ?                                                         /* paralc-mark-db-num         */
                     ,input ?                                                         /* paralc-mark-code           */
                     ,input ?                                                         /* paralc-bottling-date       */
                     ,input ?                                                         /* paralc-ref-ab-path         */
                     ,input ?                                                         /* paralc-quality-certif-path */
                     ,input ?                                                         /* paralc-imp-type            */
                     ,input ?                                                         /* paralc-imp-code            */
                     ,input ?                                                         /* paralc-certif-path         */
                     ) no-error.
                   if error-status :error then do:
                      if error-status :get-message(1) <> ""
                      then do:
                        message
                          vss-workfile vss-revision vss-description skip
                          "Ошибка при вызове процедуры cor-line.p" skip
                          error-status :get-message(1) skip
                          return-value skip
                          view-as alert-box error .
                      end.
                     UNDO d-l, leave.
                   end.
                   run str/chk-prt.p (line-rec, no, buffer t-doc) no-error.
                   if error-status :error THEN do:
                     message
                       vss-workfile vss-revision vss-description skip
                       "Ошибка про проверке разнесения строки по признакам" skip
                       error-status :get-message(1) skip
                       return-value skip
                       view-as alert-box error .
                     UNDO d-l, leave.
                   end.
                 END. /*обработка новой строки в запросе*/
               END. /*not avai doc-line*/
            END. /*нетерминальный бар-код*/
         END. /*добавляем кол-во*/
      END. /*transaction*/
   END. /*b-c <> ?*/
END.