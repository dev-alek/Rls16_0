DEFINE NEW GLOBAL SHARED TEMP-TABLE tt-clients NO-UNDO LIKE ub.clients.
DEFINE NEW GLOBAL SHARED TEMP-TABLE tt-goods NO-UNDO LIKE ub.goods.
CREATE WIDGET-POOL.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр оборота по товару".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define shared variable varparentproc as widget-handle no-undo.
define new shared variable line-rec as recid no-undo.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure dfactord:
define input  parameter parobj-type         like ub.clients.obj-type   no-undo.
define input  parameter parobj-code         like ub.clients.obj-code   no-undo.
define input  parameter paris-calend-day    as   logical            no-undo.
define input  parameter paris-shift-num     as   logical            no-undo.
define input  parameter pardate-start       as   date               no-undo.
define input  parameter pardate-end         as   date               no-undo.
define input  parameter parshift-start      as   integer            no-undo.
define input  parameter parshift-end        as   integer            no-undo.
define output parameter parfact-order-start like ub.stk-tot.fact-order no-undo.
define output parameter parfact-order-end   like ub.stk-tot.fact-order no-undo.
if paris-calend-day then do:
   run lastordr
       (input  parobj-type,
        input  parobj-code,
        input  no,
        input  ?,
        input  pardate-start - 1,
        input  ?,
        output parfact-order-start) no-error.
   if error-status:error then return error.
   run lastordr
       (input  parobj-type,
        input  parobj-code,
        input  no,
        input  ?,
        input  pardate-end,
        input  ?,
        output parfact-order-end) no-error.
   if error-status:error then return error.
end.
else do:
   if paris-shift-num then do:
      run lastordr
          (input  parobj-type,
           input  parobj-code,
           input  yes,
           input  yes,
           input  pardate-start,
           input  parshift-start - 1,
           output parfact-order-start) no-error.
      if error-status:error then return error.
      run lastordr
          (input  parobj-type,
           input  parobj-code,
           input  yes,
           input  yes,
           input  pardate-end,
           input  parshift-end,
           output parfact-order-end) no-error.
      if error-status:error then return error.
   end.
   else do:
      run lastordr
          (input  parobj-type,
           input  parobj-code,
           input  yes,
           input  no,
           input  pardate-start - 1,
           input  ?,
           output parfact-order-start) no-error.
      if error-status:error then return error.
      run lastordr
          (input  parobj-type,
           input  parobj-code,
           input  yes,
           input  no,
           input  pardate-end,
           input  ?,
           output parfact-order-end) no-error.
      if error-status:error then return error.
   end.
end.
end procedure.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure lastordr :
  define input  parameter parobj-type     as character no-undo .
  define input  parameter parobj-code     as integer   no-undo .
  define input  parameter paris-shift     as logical   no-undo .
  define input  parameter paris-shift-num as logical   no-undo .
  define input  parameter pardate         as date      no-undo .
  define input  parameter parshift-num    as integer   no-undo .
  define output parameter parfact-order   as decimal   no-undo .
  if paris-shift = no
  then do:
    find last ub.stk-tot no-lock
      where ub.stk-tot.obj-type    = parobj-type
        and ub.stk-tot.obj-code    = parobj-code
        and ub.stk-tot.fact-date <= pardate
        and ub.stk-tot.shift-num  = 0
      use-index fact-date
      no-error .
  end.
  else do:
    if paris-shift-num = no
    then do:
      find last ub.stk-tot no-lock
        where ub.stk-tot.obj-type    = parobj-type
          and ub.stk-tot.obj-code    = parobj-code
          and ub.stk-tot.shift-date <= pardate
          and ub.stk-tot.shift-num   > 0
        use-index shift-num
        no-error .
    end.
    else do:
      find last ub.stk-tot no-lock
        where ub.stk-tot.obj-type   = parobj-type
          and ub.stk-tot.obj-code   = parobj-code
          and ub.stk-tot.shift-date = pardate
          and ub.stk-tot.shift-num  <= parshift-num
          and ub.stk-tot.shift-num  > 0
        use-index shift-num
        no-error .
      if not available ub.stk-tot
      then do:
        find last ub.stk-tot no-lock
          where ub.stk-tot.obj-type   = parobj-type
            and ub.stk-tot.obj-code   = parobj-code
            and ub.stk-tot.shift-date < pardate
            and ub.stk-tot.shift-num  > 0
          use-index shift-num
          no-error .
      end.
    end.
  end.
  assign
    parfact-order = (if available ub.stk-tot then ub.stk-tot.fact-order else 0)
  .
end procedure.
define variable fact-order-start like ub.ot-line.fact-order no-undo.
define variable fact-order-end   like ub.ot-line.fact-order no-undo.
define variable fact-order-min   like ub.ot-line.fact-order no-undo.
define variable fact-order-max   like ub.ot-line.fact-order no-undo.
define variable varh_caller-main as widget-handle no-undo.
define variable varh_arh as widget-handle no-undo.
define variable vardoc-code  as character no-undo.
define variable varfact-date as date      no-undo.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varis-calend     as integer   no-undo.
define variable varis-shift-num  as logical   no-undo.
define variable vardate-start    as date      no-undo.
define variable vardate-end      as date      no-undo.
define variable varshift-start   as integer   no-undo.
define variable varshift-end     as integer   no-undo.
define variable varext-doc-type  as character no-undo.
define variable varrubl-base     as integer   no-undo.
define variable varsum-type as character no-undo.
define variable varcontragent as char no-undo.
define variable varsum like ub.ot-line.sum-base no-undo.
define variable varsum-doc like ub.ot-line.sum-base no-undo.
define variable varsum-sale like ub.ot-line.sum-base no-undo.
define variable varprice-doc like ub.ot-line.sum-base no-undo.
define variable varprice-sale like ub.ot-line.sum-base no-undo.
define variable varvat like ub.ot-line.sum-base no-undo.
define variable varvat-doc like ub.ot-line.sum-base no-undo.
define variable varslt like ub.ot-line.sum-base no-undo.
define variable varslt-doc like ub.ot-line.sum-base no-undo.
define variable varroad-tax like ub.ot-line.sum-base no-undo.
define variable varroad-tax-doc like ub.ot-line.sum-base no-undo.
define variable varexcise like ub.ot-line.sum-base no-undo.
define variable varexcise-doc like ub.ot-line.sum-base no-undo.
define variable vartransport like ub.ot-line.sum-base no-undo.
define variable vartransport-doc like ub.ot-line.sum-base no-undo.
define variable varother like ub.ot-line.sum-base no-undo.
define variable varother-doc like ub.ot-line.sum-base no-undo.
define variable rdtaxname as character no-undo.
define variable varext-doc-type-short like ub.ot-line.ext-doc-type no-undo.
def var vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure tax-name:
define input  parameter pardef-tax  as character           no-undo.
define output parameter parname-tax as character initial ? no-undo.
define buffer bf_tax for ub.tax.
do on error undo, return error :
   case pardef-tax:
      when 'vat':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('1':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '1':U(не задействован)".
      end.
      when 'slt':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('2':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '2':U(не задействован)".
      end.
      when 'rdt':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('3':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '3':U(не задействован)".
      end.
      when 'exc':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('4':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '4':U(не задействован)".
      end.
      otherwise do:
         return error "Задан неверный параметр " + pardef-tax + " .".
      end.
   end case.
end.
end procedure.
define buffer rt_tax   for ub.tax.
define temp-table ot-full no-undo
field doc-code like ub.ot-line.doc-code
field doc-type like ub.trn-doc.doc-type
field cli-type like ub.clients.obj-type
field cli-code like ub.clients.obj-code
field cli-name like ub.clients.obj-name
field fact-date like ub.trn-doc.fact-date
field fact-order like ub.ot-line.fact-order
field ext-doc-type like ub.ot-line.ext-doc-type
field ext-doc-type-full as character
field fact-qnty like ub.ot-line.fact-qnty
field sum-base like ub.ot-line.sum-base
field sum-rubl like ub.ot-line.sum-base
field sum-base-doc like ub.ot-line.sum-base
field sum-rubl-doc like ub.ot-line.sum-base
field sum-base-sale like ub.ot-line.sum-base
field sum-rubl-sale like ub.ot-line.sum-base
field vat-base like ub.ot-line.sum-base
field vat-rubl like ub.ot-line.sum-base
field vat-base-doc like ub.ot-line.sum-base
field vat-rubl-doc like ub.ot-line.sum-base
field vat-base-sale like ub.ot-line.sum-base
field vat-rubl-sale like ub.ot-line.sum-base
field slt-base like ub.ot-line.sum-base
field slt-rubl like ub.ot-line.sum-base
field slt-base-doc like ub.ot-line.sum-base
field slt-rubl-doc like ub.ot-line.sum-base
field slt-base-sale like ub.ot-line.sum-base
field slt-rubl-sale like ub.ot-line.sum-base
field excise-base like ub.ot-line.sum-base
field excise-rubl like ub.ot-line.sum-base
field excise-base-doc like ub.ot-line.sum-base
field excise-rubl-doc like ub.ot-line.sum-base
field excise-base-sale like ub.ot-line.sum-base
field excise-rubl-sale like ub.ot-line.sum-base
field road-tax-base like ub.ot-line.sum-base
field road-tax-rubl like ub.ot-line.sum-base
field road-tax-base-doc like ub.ot-line.sum-base
field road-tax-rubl-doc like ub.ot-line.sum-base
field road-tax-base-sale like ub.ot-line.sum-base
field road-tax-rubl-sale like ub.ot-line.sum-base
field transport-base like ub.ot-line.sum-base
field transport-rubl like ub.ot-line.sum-base
field transport-base-doc like ub.ot-line.sum-base
field transport-rubl-doc like ub.ot-line.sum-base
field transport-base-sale like ub.ot-line.sum-base
field transport-rubl-sale like ub.ot-line.sum-base
field other-base like ub.ot-line.sum-base
field other-rubl like ub.ot-line.sum-base
field other-base-doc like ub.ot-line.sum-base
field other-rubl-doc like ub.ot-line.sum-base
field other-base-sale like ub.ot-line.sum-base
field other-rubl-sale like ub.ot-line.sum-base
field artic like ub.goods.artic
field prod-type like ub.goods.prod-type
field prod-code like ub.goods.prod-code
field gds-type  like ub.goods.gds-type
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
index pi is primary fact-order
index doc-code doc-code
index edt ext-doc-type.
RUN set-attribute-list (
    'Keys-Accepted = "",
     Keys-Supplied = ""':U).
RUN set-attribute-list (
    'SortBy-Options = ""':U).
FUNCTION func-excise RETURNS DECIMAL
      ( buffer bf_ot-full for ot-full )  FORWARD.
FUNCTION func-excise-doc RETURNS DECIMAL
   ( buffer bf_ot-full for ot-full )  FORWARD.
FUNCTION func-other RETURNS DECIMAL
    ( buffer bf_ot-full for ot-full )  FORWARD.
FUNCTION func-other-doc RETURNS DECIMAL
    ( buffer bf_ot-full for ot-full )  FORWARD.
FUNCTION func-price-doc RETURNS DECIMAL
  ( buffer bf_ot-full for ot-full )  FORWARD.
FUNCTION func-price-sale RETURNS DECIMAL
  ( buffer bf_ot-full for ot-full )  FORWARD.
FUNCTION func-road-tax RETURNS DECIMAL
    ( buffer bf_ot-full for ot-full )  FORWARD.
FUNCTION func-road-tax-doc RETURNS DECIMAL
    ( buffer bf_ot-full for ot-full )  FORWARD.
FUNCTION func-SLT RETURNS DECIMAL
    ( buffer bf_ot-full for ot-full )  FORWARD.
FUNCTION func-slt-doc RETURNS DECIMAL
      ( buffer bf_ot-full for ot-full )  FORWARD.
FUNCTION func-sum RETURNS DECIMAL
    ( buffer bf_ot-full for ot-full )  FORWARD.
FUNCTION func-sum-doc RETURNS DECIMAL
    ( buffer bf_ot-full for ot-full )  FORWARD.
FUNCTION func-sum-sale RETURNS DECIMAL
     ( buffer bf_ot-full for ot-full )  FORWARD.
FUNCTION func-transport RETURNS DECIMAL
      ( buffer bf_ot-full for ot-full )  FORWARD.
FUNCTION func-transport-doc RETURNS DECIMAL
      ( buffer bf_ot-full for ot-full )  FORWARD.
FUNCTION func-VAT RETURNS DECIMAL
      ( buffer bf_ot-full for ot-full )  FORWARD.
FUNCTION func-VAT-doc RETURNS DECIMAL
     ( buffer bf_ot-full for ot-full )  FORWARD.
DEFINE BUTTON b-all-docs
     LABEL "Все документы"
     SIZE 16 BY 1.
DEFINE BUTTON b-lookup
     LABEL "Просмотр"
     SIZE 14 BY 1.
DEFINE QUERY b-ot-line FOR
      ot-full SCROLLING.
DEFINE BROWSE b-ot-line
  QUERY b-ot-line NO-LOCK DISPLAY
      ot-full.fact-date @ varfact-date column-label "Дата"
      ot-full.doc-code @ vardoc-code column-label "Документ"
      ot-full.ext-doc-type-full format "x(11)" column-label " "
      ot-full.cli-name @ varcontragent format "x(15)" column-label "Контрагент"
      ot-full.fact-qnty column-label "Кол-во"
      func-sum-doc (buffer ot-full) @ varsum-doc format "->,>>>,>>>,>>9.99" column-label "Сумма(по док)"
      func-sum (buffer ot-full) @ varsum format "->,>>>,>>>,>>9.99" column-label "Сумма(учет)"
      func-sum-sale (buffer ot-full) @ varsum-sale format "->,>>>,>>>,>>9.99" column-label "Сумма(прод)"
      func-other-doc (buffer ot-full) @ varother-doc format "->,>>>,>>>,>>9.99" column-label "Скидка(Прочие расходы)(по док)"
      func-VAT-doc (buffer ot-full) @ varvat-doc format "->,>>>,>>>,>>9.99" column-label "НДС(по док)"
      func-SLT-doc (buffer ot-full) @ varslt-doc format "->,>>>,>>>,>>9.99" column-label "НП(по док)"
      func-VAT (buffer ot-full) @ varvat format "->,>>>,>>>,>>9.99" column-label "НДС(учет)"
      func-SLT (buffer ot-full) @ varslt format "->,>>>,>>>,>>9.99" column-label "НП(учет)"
      func-excise-doc (buffer ot-full) @ varexcise-doc format "->,>>>,>>>,>>9.99" column-label "Акциз(по док)"
      func-excise (buffer ot-full) @ varexcise format "->,>>>,>>>,>>9.99" column-label "Акциз(учет)"
      func-road-tax-doc (buffer ot-full) @ varroad-tax-doc format "->,>>>,>>>,>>9.99"
      func-road-tax (buffer ot-full) @ varroad-tax format "->,>>>,>>>,>>9.99"
      func-transport-doc (buffer ot-full) @ vartransport-doc format "->,>>>,>>>,>>9.99" column-label "Трансп.расх.(по док)"
      func-transport (buffer ot-full) @ vartransport format "->,>>>,>>>,>>9.99" column-label "Трансп.расх.(учет)"
      func-other (buffer ot-full) @ varother format "->,>>>,>>>,>>9.99" column-label "Прочие расх.(Скидка)(учет)"
      func-price-doc (buffer ot-full) @ varprice-doc format "->,>>>,>>>,>>9.99" column-label "Сумма/Кол-во(по док)"
      func-price-sale (buffer ot-full) @ varprice-sale format "->,>>>,>>>,>>9.99" column-label "Сумма/Кол-во(учет)"
      ot-full.artic
      ot-full.prod-type
      ot-full.prod-code
      ot-full.obj-type
      ot-full.obj-code
    WITH NO-ROW-MARKERS SEPARATORS SIZE 96.88 BY 14.08
         BGCOLOR 15 .
DEFINE FRAME F-Main
     b-lookup AT ROW 1.13 COL 3
     b-all-docs AT ROW 1.13 COL 18
     b-ot-line AT ROW 2.63 COL 1.13
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY
         THREE-D
         AT COL 1 ROW 1
         SIZE 97.25 BY 16.71
         BGCOLOR 8 FGCOLOR 0
         TITLE "".
DEFINE VARIABLE adm-sts           AS LOGICAL NO-UNDO.
DEFINE VARIABLE adm-brs-in-update AS LOGICAL NO-UNDO INIT no.
DEFINE VARIABLE adm-brs-initted   AS LOGICAL NO-UNDO INIT no.
DEFINE VAR adm-object-hdl       AS HANDLE NO-UNDO.
DEFINE VAR adm-query-opened        AS LOGICAL NO-UNDO INIT NO.
DEFINE VAR adm-row-avail-state     AS LOGICAL NO-UNDO INIT ?.
DEFINE VAR adm-initial-lock        AS CHARACTER NO-UNDO INIT "NO-LOCK":U.
DEFINE VAR adm-new-record          AS LOGICAL NO-UNDO INIT no.
DEFINE VAR adm-updating-record     AS LOGICAL NO-UNDO INIT no.
DEFINE VAR adm-check-modified-all  AS LOGICAL NO-UNDO INIT no.
DEFINE NEW GLOBAL SHARED VAR adm-broker-hdl    AS HANDLE  NO-UNDO.
      adm-object-hdl = FRAME F-Main:HANDLE.
RUN ensure-broker.
THIS-PROCEDURE:ADM-DATA =
     'ADM1.1~`':U +
     'SmartObject~`':U +
     '~`':U +
     'YES~`':U +
     '~`':U +
     'ot-full~`':U +
     '~`':U +
     (IF adm-object-hdl = ? THEN "":U ELSE STRING(adm-object-hdl))
        + "~`":U +
     'Initial-Lock,Hide-on-Init,Disable-on-Init,Key-Name,Layout,Create-On-Add,SortBy-Case~`':U +
     'Record-Source,Record-Target,TableIO-Target~`':U +
     '~`':U +
     '~`~`~`~`~`~`~`~`~`~`~`':U +
     IF THIS-PROCEDURE:ADM-DATA = "":U OR THIS-PROCEDURE:ADM-DATA = ?
         THEN "^^":U
     ELSE "^":U + ENTRY(2, THIS-PROCEDURE:ADM-DATA, "^":U) +
          "^":U + ENTRY(3, THIS-PROCEDURE:ADM-DATA, "^":U).
PROCEDURE adm-apply-entry :
  RUN broker-apply-entry IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE adm-destroy :
 RUN broker-destroy IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE adm-disable :
    DISABLE b-lookup b-all-docs b-ot-line WITH FRAME F-Main.
    RUN dispatch ('disable-fields':U).
    RUN set-attribute-list ('ENABLED=no':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-edit-attribute-list :
      RUN adm/support/browserd.w (INPUT THIS-PROCEDURE).
      RETURN.
END PROCEDURE.
PROCEDURE adm-enable :
    ENABLE UNLESS-HIDDEN b-lookup b-all-docs b-ot-line WITH FRAME F-Main.
    RUN enable_UI IN THIS-PROCEDURE NO-ERROR.
    RUN set-attribute-list ('ENABLED=yes':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-exit :
     RUN notify ('exit':U).
  RETURN.
END PROCEDURE.
PROCEDURE adm-hide :
  RUN broker-hide IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE adm-initialize :
  RUN broker-initialize IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE adm-show-errors :
    DEFINE VARIABLE        cntr                  AS INTEGER   NO-UNDO.
    DO cntr = 1 TO ERROR-STATUS:NUM-MESSAGES:
        MESSAGE ERROR-STATUS:GET-MESSAGE(cntr).
    END.
    RETURN.
END PROCEDURE.
PROCEDURE adm-UIB-mode :
  RUN broker-UIB-mode IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE adm-view :
  RUN broker-view IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE dispatch :
    DEFINE INPUT PARAMETER p-method-name    AS CHARACTER NO-UNDO.
    RUN broker-dispatch IN adm-broker-hdl
        (THIS-PROCEDURE, p-method-name) NO-ERROR.
    IF RETURN-VALUE = "ADM-ERROR":U THEN RETURN "ADM-ERROR":U.
END PROCEDURE.
PROCEDURE ensure-broker :
RUN get-attribute IN adm-broker-hdl ('TYPE':U) NO-ERROR.
IF RETURN-VALUE NE "ADM-Broker":U THEN
DO:
    RUN adm/objects/broker.p PERSISTENT set adm-broker-hdl.
    RUN set-broker-owner IN adm-broker-hdl (THIS-PROCEDURE).
END.
END PROCEDURE.
PROCEDURE get-attribute :
  DEFINE INPUT PARAMETER p-attr-name    AS CHARACTER NO-UNDO.
  RUN broker-get-attribute IN adm-broker-hdl
      (INPUT THIS-PROCEDURE, INPUT p-attr-name) NO-ERROR.
  RETURN RETURN-VALUE.
END PROCEDURE.
PROCEDURE get-attribute-list :
  DEFINE OUTPUT PARAMETER p-attr-list AS CHARACTER NO-UNDO.
  RUN broker-get-attribute-list IN adm-broker-hdl
      (INPUT THIS-PROCEDURE,
       INPUT ?,
       OUTPUT p-attr-list) NO-ERROR.
  RETURN.
END PROCEDURE.
PROCEDURE new-state :
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.
  RUN broker-new-state IN adm-broker-hdl (THIS-PROCEDURE, p-state) NO-ERROR.
  RETURN.
END PROCEDURE.
PROCEDURE notify :
  DEFINE INPUT PARAMETER p-method AS CHARACTER NO-UNDO.
  RUN broker-notify IN adm-broker-hdl (THIS-PROCEDURE, p-method) NO-ERROR.
  IF RETURN-VALUE = "ADM-ERROR":U THEN
      RETURN "ADM-ERROR":U.
  RETURN.
END PROCEDURE.
PROCEDURE set-attribute-list :
  DEFINE INPUT PARAMETER p-attr-list    AS CHARACTER NO-UNDO.
  RUN ensure-broker.
  RUN broker-set-attribute-list IN adm-broker-hdl
      (INPUT THIS-PROCEDURE, INPUT p-attr-list) NO-ERROR.
  RETURN.
END PROCEDURE.
PROCEDURE set-position :
    DEFINE INPUT PARAMETER p-row    AS DECIMAL NO-UNDO.
    DEFINE INPUT PARAMETER p-col    AS DECIMAL NO-UNDO.
    IF VALID-HANDLE(adm-object-hdl) THEN
    DO:
      ASSIGN adm-object-hdl:ROW    =   p-row
             adm-object-hdl:COLUMN =   p-col.
    END.
    RETURN.
END PROCEDURE.
  DEFINE VARIABLE adm-first-table         AS ROWID NO-UNDO.
  DEFINE VARIABLE adm-second-table        AS ROWID NO-UNDO.
  DEFINE VARIABLE adm-third-table         AS ROWID NO-UNDO.
  DEFINE VARIABLE adm-adding-record       AS LOGICAL NO-UNDO INIT no.
  DEFINE VARIABLE adm-return-status       AS LOGICAL   NO-UNDO.
  DEFINE VARIABLE adm-first-prev-rowid    AS ROWID     NO-UNDO.
  DEFINE VARIABLE adm-second-prev-rowid   AS ROWID     NO-UNDO.
  DEFINE VARIABLE adm-third-prev-rowid    AS ROWID     NO-UNDO.
  DEFINE VARIABLE adm-first-tmpl-recid    AS RECID     NO-UNDO INIT ?.
  DEFINE VARIABLE adm-second-tmpl-recid   AS RECID     NO-UNDO INIT ?.
  DEFINE VARIABLE adm-third-tmpl-recid    AS RECID     NO-UNDO INIT ?.
  DEFINE VARIABLE adm-index-pos           AS INTEGER   NO-UNDO.
  DEFINE VARIABLE adm-query-empty         AS LOGICAL   NO-UNDO.
  DEFINE VARIABLE adm-create-complete     AS LOGICAL   NO-UNDO.
  DEFINE VARIABLE adm-create-on-add       AS LOGICAL   NO-UNDO INIT ?.
  DEFINE VARIABLE group-assign-target     AS LOGICAL   NO-UNDO INIT ?.
  DEFINE VARIABLE group-target-list       AS CHARACTER NO-UNDO INIT ?.
  IF "":U = "":U THEN
    RUN modify-list-attribute IN adm-broker-hdl
      (THIS-PROCEDURE, "REMOVE":U, "SUPPORTED-LINKS":U, "TABLEIO-TARGET":U).
  RUN use-create-on-add(?).
PROCEDURE adm-add-record :
    MESSAGE "Object ":U THIS-PROCEDURE:FILE-NAME
       "must have at least one Enabled Table to perform Add.":U
       VIEW-AS ALERT-BOX ERROR.
    RETURN.
END PROCEDURE.
PROCEDURE adm-assign-record :
 MESSAGE
       "Object ":U THIS-PROCEDURE:FILE-NAME
         "must have at least one Enabled Table to perform Assign.":U
           VIEW-AS ALERT-BOX ERROR.
   RETURN.
  END PROCEDURE.
PROCEDURE adm-assign-statement :
  RETURN.
END PROCEDURE.
PROCEDURE adm-cancel-record :
   RETURN.
  END PROCEDURE.
PROCEDURE adm-copy-record :
    MESSAGE "Object ":U THIS-PROCEDURE:FILE-NAME
     "must have at least one Enabled Table to perform Copy.":U
       VIEW-AS ALERT-BOX ERROR.
    RETURN.
END PROCEDURE.
PROCEDURE adm-create-record :
   RETURN.
END PROCEDURE.
PROCEDURE adm-current-changed :
  RETURN.
END PROCEDURE.
PROCEDURE adm-delete-record :
 MESSAGE
       "Object ":U THIS-PROCEDURE:FILE-NAME
         "must have at least one Enabled Table to perform Delete.":U
           VIEW-AS ALERT-BOX ERROR.
    RUN dispatch IN THIS-PROCEDURE ('apply-entry':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-disable-fields :
      RUN notify ('disable-fields, GROUP-ASSIGN-TARGET':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-enable-fields :
    RETURN.
END PROCEDURE.
PROCEDURE adm-end-update :
  RETURN.
END PROCEDURE.
PROCEDURE adm-reset-record :
    RETURN.
END PROCEDURE.
PROCEDURE adm-update-record :
    MESSAGE
      "Object ":U THIS-PROCEDURE:FILE-NAME
        "must have at least one Enabled Table to perform Update.":U
          VIEW-AS ALERT-BOX ERROR.
   RETURN.
END PROCEDURE.
PROCEDURE check-modified :
DEFINE INPUT PARAMETER check-state AS CHARACTER NO-UNDO.
DEFINE VARIABLE curr-widget       AS HANDLE      NO-UNDO.
DEFINE VARIABLE container-hdl-str AS CHARACTER   NO-UNDO.
DEFINE VARIABLE i                 AS INTEGER     NO-UNDO.
  IF check-state = "check":U THEN
  DO:
    RUN get-link-handle IN adm-broker-hdl
      (INPUT THIS-PROCEDURE, INPUT 'GROUP-ASSIGN-TARGET':U,
         OUTPUT group-target-list).
    IF group-target-list NE "":U THEN
    DO i = 1 TO NUM-ENTRIES(group-target-list):
      curr-widget = WIDGET-HANDLE(ENTRY(i, group-target-list)).
      RUN check-modified IN curr-widget ('group-check':U).
      IF RETURN-VALUE NE "":U THEN
      DO:
        RUN check-modified-message(RETURN-VALUE).
        RETURN "":U.
      END.
    END.
  END.
  RETURN "":U.
END PROCEDURE.
PROCEDURE check-modified-message :
  DEFINE INPUT PARAMETER p-changed-table AS CHARACTER NO-UNDO.
     RUN request-attribute IN adm-broker-hdl (THIS-PROCEDURE,
        'CONTAINER-SOURCE':U, 'HIDDEN':U).
     IF RETURN-VALUE = "YES":U THEN
        RUN notify ('view,CONTAINER-SOURCE':U).
     MESSAGE IF p-changed-table NE ? THEN
        SUBSTITUTE ("Current &1 record has been changed.", p-changed-table)
        ELSE "Current values have been changed."
        SKIP "  Do you wish to save those changes?"
        VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE ANS AS LOGICAL.
     IF ANS THEN
     DO:
        IF group-assign-target THEN
          RUN notify('update-record,GROUP-ASSIGN-SOURCE':U).
        ELSE RUN dispatch('update-record':U).
        IF RETURN-VALUE = "ADM-ERROR":U THEN
        DO:
            MESSAGE "Changes to the previous record were not saved."
              VIEW-AS ALERT-BOX ERROR.
            IF group-assign-target THEN
              RUN notify('cancel-record,GROUP-ASSIGN-SOURCE':U).
            ELSE RUN dispatch ('cancel-record':U).
        END.
     END.
     ELSE DO:
       IF group-assign-target THEN
          RUN notify('cancel-record,GROUP-ASSIGN-SOURCE':U).
       ELSE RUN dispatch('cancel-record':U).
     END.
     RETURN.
END PROCEDURE.
PROCEDURE get-rowid :
    DEFINE OUTPUT PARAMETER p-table           AS ROWID NO-UNDO.
    ASSIGN
    p-table   =   adm-first-table.
    RETURN.
END PROCEDURE.
PROCEDURE init-group-assign :
    RUN request-attribute IN adm-broker-hdl
      (THIS-PROCEDURE, 'GROUP-ASSIGN-SOURCE':U, 'ENABLED-TABLES':U).
    IF LOOKUP("":U, RETURN-VALUE, " ":U) NE 0 THEN
      group-assign-target = yes.
    ELSE group-assign-target = no.
    RETURN.
END PROCEDURE.
PROCEDURE set-editors :
    DEFINE INPUT PARAMETER p-field-setting  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE curr-widget             AS HANDLE    NO-UNDO.
    DEFINE VARIABLE read-only-list          AS CHARACTER NO-UNDO INIT "":U.
    ASSIGN curr-widget = FRAME F-Main:CURRENT-ITERATION.
    ASSIGN curr-widget = curr-widget:FIRST-CHILD.
    DO WHILE VALID-HANDLE (curr-widget):
        IF curr-widget:TYPE = "EDITOR":U AND curr-widget:TABLE NE ? AND
           curr-widget:HIDDEN = no THEN DO:
          CASE p-field-setting:
            WHEN "INITIALIZE":U THEN
            DO:
              IF curr-widget:READ-ONLY = yes THEN read-only-list =
                  read-only-list +
                    (IF read-only-list NE "":U THEN ",":U ELSE "":U) +
                     STRING(curr-widget).
            END.
            WHEN "DISABLE":U OR
            WHEN "ENABLE":U THEN
            DO:
                curr-widget:SENSITIVE = yes.
                RUN get-attribute ('Read-Only-Editors':U).
                IF RETURN-VALUE = ? OR
                  LOOKUP (STRING(curr-widget), RETURN-VALUE) EQ 0 THEN
                    curr-widget:READ-ONLY =
                      IF p-field-setting = "ENABLE":U THEN no ELSE yes.
            END.
            WHEN "CLEAR":U THEN
                curr-widget:SCREEN-VALUE = "":U.
          END CASE.
        END.
        ASSIGN curr-widget = curr-widget:NEXT-SIBLING.
    END.
    IF p-field-setting = "INITIALIZE":U AND read-only-list NE "":U THEN
      RUN set-attribute-list ('Read-Only-Editors = "':U + read-only-list
        + '"':U).
    RETURN.
END PROCEDURE.
PROCEDURE use-check-modified-all :
 DEFINE INPUT PARAMETER p-attr-value AS CHARACTER NO-UNDO.
  ASSIGN adm-check-modified-all = IF p-attr-value = "YES":U THEN yes ELSE no.
  RETURN.
END PROCEDURE.
PROCEDURE use-create-on-add :
DEFINE INPUT PARAMETER p-attr-value AS CHARACTER NO-UNDO.
   RETURN.
END PROCEDURE.
PROCEDURE use-initial-lock :
  DEFINE INPUT PARAMETER p-attr-value AS CHARACTER NO-UNDO.
  ASSIGN adm-initial-lock = p-attr-value.
  RETURN.
END PROCEDURE.
PROCEDURE adm-display-fields :
      IF AVAILABLE ot-full THEN
          DISPLAY ot-full.fact-date @ varfact-date ot-full.doc-code @ vardoc-code ot-full.ext-doc-type-full ot-full.cli-name @ varcontragent ot-full.fact-qnty func-sum-doc (buffer ot-full) @ varsum-doc func-sum (buffer ot-full) @ varsum func-sum-sale (buffer ot-full) @ varsum-sale func-other-doc (buffer ot-full) @ varother-doc func-VAT-doc (buffer ot-full) @ varvat-doc func-SLT-doc (buffer ot-full) @ varslt-doc func-VAT (buffer ot-full) @ varvat func-SLT (buffer ot-full) @ varslt func-excise-doc (buffer ot-full) @ varexcise-doc func-excise (buffer ot-full) @ varexcise func-road-tax-doc (buffer ot-full) @ varroad-tax-doc func-road-tax (buffer ot-full) @ varroad-tax func-transport-doc (buffer ot-full) @ vartransport-doc func-transport (buffer ot-full) @ vartransport func-other (buffer ot-full) @ varother func-price-doc (buffer ot-full) @ varprice-doc func-price-sale (buffer ot-full) @ varprice-sale ot-full.artic ot-full.prod-type ot-full.prod-code ot-full.obj-type ot-full.obj-code WITH BROWSE b-ot-line
            NO-ERROR.
    RUN check-modified IN THIS-PROCEDURE ('clear':U) NO-ERROR.
    RETURN.
END PROCEDURE.
PROCEDURE adm-open-query :
            OPEN QUERY b-ot-line FOR EACH ot-full.
        adm-query-opened = yes.
        IF NUM-RESULTS("b-ot-line":U) = 0 THEN
            RUN new-state ('no-record-available,SELF':U).
        ELSE DO:
            RUN new-state ('record-available,SELF':U).
            RUN new-state ('first-record,SELF':U).
        END.
        IF NOT adm-updating-record THEN
            RUN dispatch IN THIS-PROCEDURE ('row-changed':U).
  RETURN.
END PROCEDURE.
PROCEDURE adm-row-changed :
      IF VALID-HANDLE(adm-object-hdl) THEN
        RUN dispatch IN THIS-PROCEDURE ('display-fields':U).
      RUN notify ('row-available':U).
      RETURN.
END PROCEDURE.
PROCEDURE reposition-query :
    DEFINE INPUT PARAMETER p-requestor-hdl     AS HANDLE NO-UNDO.
    DEFINE VARIABLE table-name                 AS ROWID NO-UNDO.
    RUN get-rowid IN p-requestor-hdl (OUTPUT table-name).
    IF table-name <> ? THEN
        REPOSITION b-ot-line TO ROWID table-name NO-ERROR.
    RUN set-attribute-list ('REPOSITION-PENDING = NO':U).
    RETURN.
END PROCEDURE.
  adm-sts = b-ot-line:SET-REPOSITIONED-ROW
    (b-ot-line:DOWN,"CONDITIONAL":U).
  RUN set-attribute-list ('FIELDS-ENABLED=no,ADM-NEW-RECORD=no':U).
PROCEDURE set-size :
  DEFINE INPUT PARAMETER pd_height AS DECIMAL NO-UNDO.
  DEFINE INPUT PARAMETER pd_width  AS DECIMAL NO-UNDO.
  DEFINE VARIABLE hBrowse     AS HANDLE           NO-UNDO.
  DEFINE VARIABLE hFieldGroup AS HANDLE           NO-UNDO.
  DEFINE VARIABLE hFrame      AS HANDLE           NO-UNDO.
  DEFINE VARIABLE htmpWidget  AS HANDLE           NO-UNDO.
  DEFINE VARIABLE otherWidget AS LOGICAL          NO-UNDO.
  ASSIGN pd_height = MAX(pd_height, 2.0)
         pd_width  = MAX(pd_width, 2.0)
         hBrowse     = b-ot-line:HANDLE IN FRAME F-Main
         hFieldGroup = hBrowse:PARENT
         htmpWidget  = hFieldGroup:FIRST-CHILD
         hFrame      = hFieldGroup:PARENT.
  Search-For-Siblings:
  REPEAT WHILE VALID-HANDLE(htmpWidget):
    IF htmpWidget NE hBrowse THEN DO:
      IF htmpWidget:TYPE NE "BUTTON" OR
         htmpWidget:X    NE 4 OR
         htmpWidget:Y    NE 4 THEN DO:
        RETURN.
      END.
    END.
    htmpWidget = htmpWidget:NEXT-SIBLING.
  END.
  IF pd_width < hBrowse:WIDTH THEN
    ASSIGN hBrowse:WIDTH = pd_width
           hFrame:WIDTH  = pd_width     NO-ERROR.
  ELSE
    ASSIGN hFrame:WIDTH  = pd_width
           hBrowse:WIDTH = pd_width     NO-ERROR.
  IF pd_height < hBrowse:HEIGHT THEN
    ASSIGN hBrowse:HEIGHT = pd_height
           hFrame:HEIGHT  = pd_height     NO-ERROR.
  ELSE
    ASSIGN hFrame:HEIGHT  = pd_height
           hBrowse:HEIGHT = pd_height     NO-ERROR.
END PROCEDURE.
ASSIGN
       FRAME F-Main:HIDDEN           = TRUE.
ASSIGN
       b-ot-line:NUM-LOCKED-COLUMNS IN FRAME F-Main     = 4.
ON END-ERROR OF FRAME F-Main
DO:
     run return-up.
   return no-apply.
END.
ON ENDKEY OF FRAME F-Main
DO:
     run return-up.
   return no-apply.
END.
ON CHOOSE OF b-all-docs IN FRAME F-Main
DO:
run notify ('read_doc-type-all,doctype-target':u).
run show_arh.
END.
ON CHOOSE OF b-lookup IN FRAME F-Main
DO:
  if available ot-full then do:
     run lookup-doc.
   end.
END.
ON MOUSE-SELECT-DBLCLICK OF b-ot-line IN FRAME F-Main
DO:
  if available ot-full  then run lookup-doc.
END.
if not this-procedure :persistent
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при запуске процедуры" skip
    "Данную процедуру следует запускать только с параметром persistent" skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in varparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
run tax-name ('rdt':U, output rdtaxname).
assign varroad-tax-doc :label in browse b-ot-line = rdtaxname
       varroad-tax     :label in browse b-ot-line = rdtaxname.
PROCEDURE adm-row-available :
  DEFINE VARIABLE tbl-list           AS CHARACTER INIT "":U NO-UNDO.
  DEFINE VARIABLE rowid-list         AS CHARACTER NO-UNDO.
  DEFINE VARIABLE row-avail-cntr     AS INTEGER INIT 0 NO-UNDO.
  DEFINE VARIABLE row-avail-rowid    AS ROWID NO-UNDO.
  DEFINE VARIABLE row-avail-enabled  AS LOGICAL NO-UNDO.
  DEFINE VARIABLE link-handle        AS CHARACTER NO-UNDO.
  DEFINE VARIABLE record-source-hdl  AS HANDLE NO-UNDO.
  DEFINE VARIABLE different-row      AS LOGICAL NO-UNDO INIT no.
  DEFINE VARIABLE key-name           AS CHARACTER INIT ? NO-UNDO.
  DEFINE VARIABLE key-value          AS CHARACTER INIT ? NO-UNDO.
  RUN check-modified IN THIS-PROCEDURE ('check':U) NO-ERROR.
  IF adm-updating-record THEN RETURN.
  RUN get-attribute ('FIELDS-ENABLED':U).
  row-avail-enabled = IF RETURN-VALUE = "YES":U THEN yes ELSE no.
  RUN get-link-handle IN adm-broker-hdl (THIS-PROCEDURE, 'RECORD-SOURCE':U,
      OUTPUT link-handle) NO-ERROR.
  IF link-handle = "":U THEN
      RETURN.
  ASSIGN record-source-hdl = WIDGET-HANDLE(ENTRY(1,link-handle)).
  IF NUM-ENTRIES(link-handle) > 1 THEN
      MESSAGE "row-available in ":U THIS-PROCEDURE:FILE-NAME
          "encountered more than one RECORD-SOURCE.":U SKIP
          "The first - ":U record-source-hdl:file-name " - will be used.":U
             VIEW-AS ALERT-BOX ERROR.
  RUN get-attribute ('Key-Name':U).
  key-name = RETURN-VALUE.
  IF key-name = "":U THEN key-name = ?.
  IF key-name NE ? THEN DO:
    RUN send-key IN record-source-hdl (INPUT key-name, OUTPUT key-value)
      NO-ERROR.
    IF key-value NE ? THEN
      RUN set-attribute-list (SUBSTITUTE ('Key-Value="&1"':U, key-value)).
  END.
IF VALID-HANDLE (adm-object-hdl) THEN
    RUN dispatch IN THIS-PROCEDURE ('display-fields':U).
  IF key-name ne ? OR different-row
  THEN RUN dispatch IN THIS-PROCEDURE ('open-query':U).
  ELSE RUN notify IN THIS-PROCEDURE('row-available':U).
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME F-Main.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.
PROCEDURE local-initialize :
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .
  run show_arh no-error.
END PROCEDURE.
PROCEDURE lookup-doc :
define variable g-log as logical no-undo.
case ot-full.ext-doc-type:
when 'ot':U then do:
   find first ub.price-doc where ub.price-doc.doc-num = ot-full.doc-code no-lock.
   if not available ub.price-doc then do:
      message "Не найден документ переоценки для просмотра" view-as alert-box.
      return error.
   end.
   find ub.price-list where ub.price-list.doc-num   = ub.price-doc.doc-num  and
                         ub.price-list.artic     = ot-full.artic     and
                         ub.price-list.prod-type = ot-full.prod-type and
                         ub.price-list.prod-code = ot-full.prod-code no-lock no-error.
   assign line-rec = recid(ub.price-list).
   run str/pr-lkp.p
     (input varparentproc
     ,recid(ub.price-doc)
     ).
end.
otherwise do:
   find first ub.trn-doc where ub.trn-doc.doc-code = ot-full.doc-code no-lock.
   if not available ub.trn-doc then do:
      message "Не найден документ для просмотра" view-as alert-box.
      return error.
   end.
   case ub.trn-doc.doc-type
   :
     when 'при':U
     then do:
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_income_lookup':U
    ,input  'object':U
    ,input  ub.trn-doc.host-code
    ,input  ub.trn-doc.obj-type
    ,input  ub.trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
     end.
     when 'рас':U
     then do:
define variable vss-include-info7 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_expense_lookup':U
    ,input  'object':U
    ,input  ub.trn-doc.host-code
    ,input  ub.trn-doc.obj-type
    ,input  ub.trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
     end.
     when 'спи':U
     then do:
define variable vss-include-info8 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_write-off_lookup':U
    ,input  'object':U
    ,input  ub.trn-doc.host-code
    ,input  ub.trn-doc.obj-type
    ,input  ub.trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
     end.
     when 'инв':U
     then do:
define variable vss-include-info9 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_inventory_lookup':U
    ,input  'object':U
    ,input  ub.trn-doc.host-code
    ,input  ub.trn-doc.obj-type
    ,input  ub.trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
     end.
     when 'возврат':U
     then do:
define variable vss-include-info10 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_return_lookup':U
    ,input  'object':U
    ,input  ub.trn-doc.host-code
    ,input  ub.trn-doc.obj-type
    ,input  ub.trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
     end.
     otherwise do:
       message
         vss-workfile vss-revision vss-description skip
         "Неизвестный тип документа" skip
         "Тип документа" ub.trn-doc.doc-type skip
         "Код документа" ub.trn-doc.doc-code skip
         view-as alert-box error .
       undo, return error return-value .
     end.
   end case .
   if not g-log then return no-apply.
   find ub.doc-line where ub.doc-line.doc-code  = ub.trn-doc.doc-code  and
                       ub.doc-line.artic     = ot-full.artic     and
                       ub.doc-line.prod-type = ot-full.prod-type and
                       ub.doc-line.prod-code = ot-full.prod-code no-lock no-error.
   assign line-rec = recid(ub.doc-line).
   run str/trn-lkp.p (varparentproc, recid(ub.trn-doc), recid(ub.doc-line)).
end.
end case.
END PROCEDURE.
PROCEDURE return-up :
END PROCEDURE.
PROCEDURE send-records :
  DEFINE INPUT PARAMETER p-tbl-list AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-rowid-list AS CHARACTER NO-UNDO.
  DEFINE VARIABLE i            AS INTEGER   NO-UNDO.
  DEFINE VARIABLE link-handle  AS CHARACTER NO-UNDO.
  DEFINE VARIABLE rowid-string AS CHARACTER NO-UNDO.
  DO i = 1 TO NUM-ENTRIES(p-tbl-list):
      IF i > 1 THEN p-rowid-list = p-rowid-list + ",":U.
      CASE ENTRY(i, p-tbl-list):
    WHEN "ot-full":U THEN p-rowid-list = p-rowid-list +
        IF AVAILABLE ot-full THEN STRING(ROWID(ot-full))
        ELSE "?":U.
        OTHERWISE
        DO:
            RUN get-link-handle IN adm-broker-hdl (INPUT THIS-PROCEDURE,
                INPUT "RECORD-SOURCE":U, OUTPUT link-handle) NO-ERROR.
            IF link-handle NE "":U THEN
            DO:
                IF NUM-ENTRIES(link-handle) > 1 THEN
                    MESSAGE "send-records in ":U THIS-PROCEDURE:FILE-NAME
                            "encountered more than one RECORD-SOURCE.":U SKIP
                            "The first will be used.":U
                            VIEW-AS ALERT-BOX ERROR.
                RUN send-records IN WIDGET-HANDLE(ENTRY(1,link-handle))
                    (INPUT ENTRY(i, p-tbl-list), OUTPUT rowid-string).
                p-rowid-list = p-rowid-list + rowid-string.
            END.
            ELSE
            DO:
                MESSAGE "Requested table":U ENTRY(i, p-tbl-list)
                        "does not match tables in send-records":U
                        "in procedure":U THIS-PROCEDURE:FILE-NAME ".":U SKIP
                        "Check that objects are linked properly and that":U
                        "database qualification is consistent.":U
                    VIEW-AS ALERT-BOX ERROR.
                RETURN ERROR.
            END.
        END.
        END CASE.
    END.
END PROCEDURE.
PROCEDURE show_arh :
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
RUN request-attribute IN adm-broker-hdl                     (INPUT THIS-PROCEDURE,                                       INPUT 'Container-Source':U,                                 INPUT 'main-handle':U) NO-ERROR.                        if return-value = "" or return-value = ? or return-value = "?" then do:                        return error "Нет атрибута: " + "main-handle" + " для получения данных." .                    end.
assign varh_caller-main = widget-handle(return-value).
RUN request-attribute IN adm-broker-hdl                     (INPUT THIS-PROCEDURE,                                       INPUT 'Container-Source':U,                                 INPUT 'varis-calend':U) NO-ERROR.                        if return-value = "" or return-value = ? or return-value = "?" then do:                        return error "Нет атрибута: " + "varis-calend" + " для получения данных." .                    end.
assign varis-calend = integer(return-value).
RUN request-attribute IN adm-broker-hdl                     (INPUT THIS-PROCEDURE,                                       INPUT 'Container-Source':U,                                 INPUT 'varis-shift-num':U) NO-ERROR.                        if return-value = "" or return-value = ? or return-value = "?" then do:                        return error "Нет атрибута: " + "varis-shift-num" + " для получения данных." .                    end.
assign varis-shift-num = if return-value = 'yes' then yes else no.
RUN request-attribute IN adm-broker-hdl                     (INPUT THIS-PROCEDURE,                                       INPUT 'Container-Source':U,                                 INPUT 'vardate-start':U) NO-ERROR.                        if return-value = "" or return-value = ? or return-value = "?" then do:                        return error "Нет атрибута: " + "vardate-start" + " для получения данных." .                    end.
assign vardate-start = date(return-value).
RUN request-attribute IN adm-broker-hdl                     (INPUT THIS-PROCEDURE,                                       INPUT 'Container-Source':U,                                 INPUT 'vardate-end':U) NO-ERROR.                        if return-value = "" or return-value = ? or return-value = "?" then do:                        return error "Нет атрибута: " + "vardate-end" + " для получения данных." .                    end.
assign vardate-end = date(return-value).
RUN request-attribute IN adm-broker-hdl                     (INPUT THIS-PROCEDURE,                                       INPUT 'Container-Source':U,                                 INPUT 'varshift-start':U) NO-ERROR.                        if return-value = "" or return-value = ? or return-value = "?" then do:                        return error "Нет атрибута: " + "varshift-start" + " для получения данных." .                    end.
assign varshift-start = integer(return-value).
RUN request-attribute IN adm-broker-hdl                     (INPUT THIS-PROCEDURE,                                       INPUT 'Container-Source':U,                                 INPUT 'varshift-end':U) NO-ERROR.                        if return-value = "" or return-value = ? or return-value = "?" then do:                        return error "Нет атрибута: " + "varshift-end" + " для получения данных." .                    end.
assign varshift-end = integer(return-value).
RUN request-attribute IN adm-broker-hdl                     (INPUT THIS-PROCEDURE,                                       INPUT 'Container-Source':U,                                 INPUT 'varext-doc-type':U) NO-ERROR.                        if return-value = "" or return-value = ? or return-value = "?" then do:                        return error "Нет атрибута: " + "varext-doc-type" + " для получения данных." .                    end.
assign varext-doc-type = return-value.
RUN request-attribute IN adm-broker-hdl                     (INPUT THIS-PROCEDURE,                                       INPUT 'Container-Source':U,                                 INPUT 'rubl-base':U) NO-ERROR.                        if return-value = "" or return-value = ? or return-value = "?" then do:                        return error "Нет атрибута: " + "rubl-base" + " для получения данных." .                    end.
assign varrubl-base = integer(return-value).
if varext-doc-type = "?" then do:
   message "Не считаны атрибуты для запроса." view-as alert-box error.
   return error.
end.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign fact-order-min = 0
       fact-order-max = 0.
for each tt-clients:
   run dfactord (input  tt-clients.obj-type,
                 input  tt-clients.obj-code,
                 input  (if varis-calend = 1 then yes else no),
                 input  varis-shift-num,
                 input  vardate-start,
                 input  vardate-end,
                 input  varshift-start,
                 input  varshift-end,
                 output fact-order-start,
                 output fact-order-end) no-error.
   if error-status:error then do:
      message "Ошибка при определении диапазона данных."
      view-as alert-box error.
      return no-apply.
   end.
   if fact-order-end = 0 then next.
   if fact-order-start > fact-order-min then assign fact-order-min = fact-order-start.
   if fact-order-end   > fact-order-max then assign fact-order-max = fact-order-end.
end.
assign varsum-type = "all".
for each ot-full:
    delete ot-full.
end.
define variable g-cost as logical no-undo.
assign frame F-Main:title = "Документы: " +
(if varext-doc-type = 'all' then 'Все' else varext-doc-type).
if varext-doc-type <> 'all' then
   assign varext-doc-type-short = entry(lookup(varext-doc-type, 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U), 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U).
define variable v-chk-act-host-code as integer   no-undo .
assign
  g-cost = true
.
scan_block:
for each tt-clients
on error undo, return error return-value
:
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  tt-clients.obj-type
  ,input  tt-clients.obj-code
  ,output v-chk-act-host-code
  )  .
define variable vss-include-info14 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_archive_cost':U
    ,input  'object':U
    ,input  v-chk-act-host-code
    ,input  tt-clients.obj-type
    ,input  tt-clients.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output g-cost
    )  .
end.
  if g-cost <> true
  then do:
    leave scan_block.
  end.
end.
if varext-doc-type = 'all'
then do:
   if g-cost
   then do:
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FOR EACH tt-clients,
    EACH tt-goods,
    EACH ub.ot-line WHERE
         ub.ot-line.obj-code   = tt-clients.obj-code and
         ub.ot-line.obj-type   = tt-clients.obj-type and
         ub.ot-line.artic      = tt-goods.artic      and
         ub.ot-line.prod-type  = tt-goods.prod-type  and
         ub.ot-line.prod-code  = tt-goods.prod-code  and
         ub.ot-line.fact-order > fact-order-min      and
         ub.ot-line.fact-order <= fact-order-max
           NO-LOCK:
    if ub.ot-line.sum-type begins 'cost':U         and ub.ot-line.cat-id <> '##,##':U then next.
    if ub.ot-line.sum-type begins 'cssr':U and ub.ot-line.cat-id <> '##,##':U then next.
    FIND FIRST ub.trn-doc   WHERE ub.trn-doc.doc-code  = ub.ot-line.doc-code NO-LOCK NO-ERROR.
    FIND FIRST ub.price-doc WHERE ub.price-doc.doc-num = ub.ot-line.doc-code NO-LOCK NO-ERROR.
    IF AVAILABLE ub.trn-doc THEN
       FIND FIRST ot-full WHERE ot-full.doc-code = ub.trn-doc.doc-code NO-ERROR.
    ELSE
       FIND FIRST ot-full WHERE ot-full.doc-code = ub.price-doc.doc-num NO-ERROR.
    IF NOT AVAILABLE ot-full THEN DO:
       CREATE ot-full.
       ASSIGN
       ot-full.doc-code     = ub.ot-line.doc-code
       ot-full.doc-type     = (if available ub.trn-doc then ub.trn-doc.doc-code else " ")
       ot-full.cli-type     = (if available ub.trn-doc then ub.trn-doc.cli-type else " ")
       ot-full.cli-code     = (if available ub.trn-doc then ub.trn-doc.cli-code else 0)
       ot-full.artic        = tt-goods.artic
       ot-full.prod-type    = tt-goods.prod-type
       ot-full.prod-code    = tt-goods.prod-code
       ot-full.gds-type     = tt-goods.gds-type
       ot-full.obj-type     = tt-clients.obj-type
       ot-full.obj-code     = tt-clients.obj-code
       ot-full.fact-date    = (if available ub.trn-doc then ub.trn-doc.fact-date else ub.price-doc.fact-date)
       ot-full.fact-order   = (if available ub.trn-doc then ub.trn-doc.fact-order else ub.price-doc.fact-order)
       ot-full.ext-doc-type = ub.ot-line.ext-doc-type.
       ot-full.ext-doc-type-full =  entry(lookup(ot-full.ext-doc-type, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U), 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U).
       if available ub.trn-doc then do:
          find  ub.clients where  ub.clients.obj-type = ub.trn-doc.cli-type and
                              ub.clients.obj-code = ub.trn-doc.cli-code no-lock.
          assign ot-full.cli-name =  ub.clients.obj-name.
       end.
       else ot-full.cli-name = " ".
    END.
    if ot-full.gds-type = 'у':U then do:
      CASE ub.ot-line.sum-type:
         WHEN 'cssr':U THEN DO:
           if g-cost then
              ASSIGN
              ot-full.sum-base       = ot-full.sum-base       + ub.ot-line.sum-base
              ot-full.sum-rubl       = ot-full.sum-rubl       + ub.ot-line.sum-rubl
              ot-full.vat-base       = ot-full.vat-base       + ub.ot-line.vat-base
              ot-full.vat-rubl       = ot-full.vat-rubl       + ub.ot-line.vat-rubl
              ot-full.slt-base       = ot-full.slt-base       + ub.ot-line.slt-base
              ot-full.slt-rubl       = ot-full.slt-rubl       + ub.ot-line.slt-rubl
              ot-full.excise-base    = ot-full.excise-base    + ub.ot-line.excise-base
              ot-full.excise-rubl    = ot-full.excise-rubl    + ub.ot-line.excise-rubl
              ot-full.road-tax-base  = ot-full.road-tax-base  + ub.ot-line.road-tax-base
              ot-full.road-tax-rubl  = ot-full.road-tax-rubl  + ub.ot-line.road-tax-rubl
              ot-full.transport-base = ot-full.transport-base + ub.ot-line.transport-base
              ot-full.transport-rubl = ot-full.transport-rubl + ub.ot-line.transport-rubl
              ot-full.other-base     = ot-full.other-base     + ub.ot-line.other-base
              ot-full.other-rubl     = ot-full.other-rubl     + ub.ot-line.other-rubl.
           else
              ASSIGN
              ot-full.sum-base       = ?
              ot-full.sum-rubl       = ?
              ot-full.vat-base       = ?
              ot-full.vat-rubl       = ?
              ot-full.slt-base       = ?
              ot-full.slt-rubl       = ?
              ot-full.excise-base    = ?
              ot-full.excise-rubl    = ?
              ot-full.road-tax-base  = ?
              ot-full.road-tax-rubl  = ?
              ot-full.transport-base = ?
              ot-full.transport-rubl = ?
              ot-full.other-base     = ?
              ot-full.other-rubl     = ?.
         END.
         WHEN 'sasr':U THEN DO:
              assign ot-full.fact-qnty = ot-full.fact-qnty + ub.ot-line.fact-qnty.
              ASSIGN
              ot-full.sum-base-doc       = ot-full.sum-base-doc       + ub.ot-line.sum-base
              ot-full.sum-rubl-doc       = ot-full.sum-rubl-doc       + ub.ot-line.sum-rubl
              ot-full.vat-base-doc       = ot-full.vat-base-doc       + ub.ot-line.vat-base
              ot-full.vat-rubl-doc       = ot-full.vat-rubl-doc       + ub.ot-line.vat-rubl
              ot-full.slt-base-doc       = ot-full.slt-base-doc       + ub.ot-line.slt-base
              ot-full.slt-rubl-doc       = ot-full.slt-rubl-doc       + ub.ot-line.slt-rubl
              ot-full.excise-base-doc    = ot-full.excise-base-doc    + ub.ot-line.excise-base
              ot-full.excise-rubl-doc    = ot-full.excise-rubl-doc    + ub.ot-line.excise-rubl
              ot-full.road-tax-base-doc  = ot-full.road-tax-base-doc  + ub.ot-line.road-tax-base
              ot-full.road-tax-rubl-doc  = ot-full.road-tax-rubl-doc  + ub.ot-line.road-tax-rubl
              ot-full.transport-base-doc = ot-full.transport-base-doc + ub.ot-line.transport-base
              ot-full.transport-rubl-doc = ot-full.transport-rubl-doc + ub.ot-line.transport-rubl
              ot-full.other-base-doc     = ot-full.other-base-doc     + ub.ot-line.other-base
              ot-full.other-rubl-doc     = ot-full.other-rubl-doc     + ub.ot-line.other-rubl.
         END.
         WHEN 'cgsr':U THEN DO:
              ASSIGN
              ot-full.sum-base-sale       = ot-full.sum-base-sale       + ub.ot-line.sum-base
              ot-full.sum-rubl-sale       = ot-full.sum-rubl-sale       + ub.ot-line.sum-rubl
              ot-full.vat-base-sale       = ot-full.vat-base-sale       + ub.ot-line.vat-base
              ot-full.vat-rubl-sale       = ot-full.vat-rubl-sale       + ub.ot-line.vat-rubl
              ot-full.slt-base-sale       = ot-full.slt-base-sale       + ub.ot-line.slt-base
              ot-full.slt-rubl-sale       = ot-full.slt-rubl-sale       + ub.ot-line.slt-rubl
              ot-full.excise-base-sale    = ot-full.excise-base-sale    + ub.ot-line.excise-base
              ot-full.excise-rubl-sale    = ot-full.excise-rubl-sale    + ub.ot-line.excise-rubl
              ot-full.road-tax-base-sale  = ot-full.road-tax-base-sale  + ub.ot-line.road-tax-base
              ot-full.road-tax-rubl-sale  = ot-full.road-tax-rubl-sale  + ub.ot-line.road-tax-rubl
              ot-full.transport-base-sale = ot-full.transport-base-sale + ub.ot-line.transport-base
              ot-full.transport-rubl-sale = ot-full.transport-rubl-sale + ub.ot-line.transport-rubl
              ot-full.other-base-sale     = ot-full.other-base-sale     + ub.ot-line.other-base
              ot-full.other-rubl-sale     = ot-full.other-rubl-sale     + ub.ot-line.other-rubl .
         END.
         OTHERWISE DO:
           message "Некорректный sum-type " ub.ot-line.sum-type " при просмотре архива(b-otlina.w)." skip
                   "Ошибка в расчетах."
                   view-as alert-box error.
         END.
      END CASE.
    end.
    else do:
      CASE ub.ot-line.sum-type:
         WHEN 'cost':U THEN DO:
           assign ot-full.fact-qnty = ot-full.fact-qnty + ub.ot-line.fact-qnty.
           if g-cost then
              ASSIGN
              ot-full.sum-base       = ot-full.sum-base       + ub.ot-line.sum-base
              ot-full.sum-rubl       = ot-full.sum-rubl       + ub.ot-line.sum-rubl
              ot-full.vat-base       = ot-full.vat-base       + ub.ot-line.vat-base
              ot-full.vat-rubl       = ot-full.vat-rubl       + ub.ot-line.vat-rubl
              ot-full.slt-base       = ot-full.slt-base       + ub.ot-line.slt-base
              ot-full.slt-rubl       = ot-full.slt-rubl       + ub.ot-line.slt-rubl
              ot-full.excise-base    = ot-full.excise-base    + ub.ot-line.excise-base
              ot-full.excise-rubl    = ot-full.excise-rubl    + ub.ot-line.excise-rubl
              ot-full.road-tax-base  = ot-full.road-tax-base  + ub.ot-line.road-tax-base
              ot-full.road-tax-rubl  = ot-full.road-tax-rubl  + ub.ot-line.road-tax-rubl
              ot-full.transport-base = ot-full.transport-base + ub.ot-line.transport-base
              ot-full.transport-rubl = ot-full.transport-rubl + ub.ot-line.transport-rubl
              ot-full.other-base     = ot-full.other-base     + ub.ot-line.other-base
              ot-full.other-rubl     = ot-full.other-rubl     + ub.ot-line.other-rubl.
           else
              ASSIGN
              ot-full.sum-base       = ?
              ot-full.sum-rubl       = ?
              ot-full.vat-base       = ?
              ot-full.vat-rubl       = ?
              ot-full.slt-base       = ?
              ot-full.slt-rubl       = ?
              ot-full.excise-base    = ?
              ot-full.excise-rubl    = ?
              ot-full.road-tax-base  = ?
              ot-full.road-tax-rubl  = ?
              ot-full.transport-base = ?
              ot-full.transport-rubl = ?
              ot-full.other-base     = ?
              ot-full.other-rubl     = ?.
         END.
         WHEN 'sale':U THEN DO:
              ASSIGN
              ot-full.sum-base-doc       = ot-full.sum-base-doc       + ub.ot-line.sum-base
              ot-full.sum-rubl-doc       = ot-full.sum-rubl-doc       + ub.ot-line.sum-rubl
              ot-full.vat-base-doc       = ot-full.vat-base-doc       + ub.ot-line.vat-base
              ot-full.vat-rubl-doc       = ot-full.vat-rubl-doc       + ub.ot-line.vat-rubl
              ot-full.slt-base-doc       = ot-full.slt-base-doc       + ub.ot-line.slt-base
              ot-full.slt-rubl-doc       = ot-full.slt-rubl-doc       + ub.ot-line.slt-rubl
              ot-full.excise-base-doc    = ot-full.excise-base-doc    + ub.ot-line.excise-base
              ot-full.excise-rubl-doc    = ot-full.excise-rubl-doc    + ub.ot-line.excise-rubl
              ot-full.road-tax-base-doc  = ot-full.road-tax-base-doc  + ub.ot-line.road-tax-base
              ot-full.road-tax-rubl-doc  = ot-full.road-tax-rubl-doc  + ub.ot-line.road-tax-rubl
              ot-full.transport-base-doc = ot-full.transport-base-doc + ub.ot-line.transport-base
              ot-full.transport-rubl-doc = ot-full.transport-rubl-doc + ub.ot-line.transport-rubl
              ot-full.other-base-doc     = ot-full.other-base-doc     + ub.ot-line.other-base
              ot-full.other-rubl-doc     = ot-full.other-rubl-doc     + ub.ot-line.other-rubl.
         END.
         WHEN 'crsa':U THEN DO:
              ASSIGN
              ot-full.sum-base-sale       = ot-full.sum-base-sale       + ub.ot-line.sum-base
              ot-full.sum-rubl-sale       = ot-full.sum-rubl-sale       + ub.ot-line.sum-rubl
              ot-full.vat-base-sale       = ot-full.vat-base-sale       + ub.ot-line.vat-base
              ot-full.vat-rubl-sale       = ot-full.vat-rubl-sale       + ub.ot-line.vat-rubl
              ot-full.slt-base-sale       = ot-full.slt-base-sale       + ub.ot-line.slt-base
              ot-full.slt-rubl-sale       = ot-full.slt-rubl-sale       + ub.ot-line.slt-rubl
              ot-full.excise-base-sale    = ot-full.excise-base-sale    + ub.ot-line.excise-base
              ot-full.excise-rubl-sale    = ot-full.excise-rubl-sale    + ub.ot-line.excise-rubl
              ot-full.road-tax-base-sale  = ot-full.road-tax-base-sale  + ub.ot-line.road-tax-base
              ot-full.road-tax-rubl-sale  = ot-full.road-tax-rubl-sale  + ub.ot-line.road-tax-rubl
              ot-full.transport-base-sale = ot-full.transport-base-sale + ub.ot-line.transport-base
              ot-full.transport-rubl-sale = ot-full.transport-rubl-sale + ub.ot-line.transport-rubl
              ot-full.other-base-sale     = ot-full.other-base-sale     + ub.ot-line.other-base
              ot-full.other-rubl-sale     = ot-full.other-rubl-sale     + ub.ot-line.other-rubl .
         END.
         OTHERWISE DO:
           message "Некорректный sum-type " ub.ot-line.sum-type " при просмотре архива(b-otlina.w)." skip
                   "Ошибка в расчетах."
                   view-as alert-box error.
         END.
      END CASE.
    end.
END.
      OPEN QUERY b-ot-line FOR EACH ot-full.
   end.
   else do:
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FOR EACH tt-clients,
    EACH tt-goods,
    EACH ub.ot-line WHERE
         ub.ot-line.obj-code   = tt-clients.obj-code and
         ub.ot-line.obj-type   = tt-clients.obj-type and
         ub.ot-line.artic      = tt-goods.artic      and
         ub.ot-line.prod-type  = tt-goods.prod-type  and
         ub.ot-line.prod-code  = tt-goods.prod-code  and
         ub.ot-line.fact-order > fact-order-min      and
         ub.ot-line.fact-order <= fact-order-max
         and ub.ot-line.sum-type <> 'cost':U
           NO-LOCK:
    if ub.ot-line.sum-type begins 'cost':U         and ub.ot-line.cat-id <> '##,##':U then next.
    if ub.ot-line.sum-type begins 'cssr':U and ub.ot-line.cat-id <> '##,##':U then next.
    FIND FIRST ub.trn-doc   WHERE ub.trn-doc.doc-code  = ub.ot-line.doc-code NO-LOCK NO-ERROR.
    FIND FIRST ub.price-doc WHERE ub.price-doc.doc-num = ub.ot-line.doc-code NO-LOCK NO-ERROR.
    IF AVAILABLE ub.trn-doc THEN
       FIND FIRST ot-full WHERE ot-full.doc-code = ub.trn-doc.doc-code NO-ERROR.
    ELSE
       FIND FIRST ot-full WHERE ot-full.doc-code = ub.price-doc.doc-num NO-ERROR.
    IF NOT AVAILABLE ot-full THEN DO:
       CREATE ot-full.
       ASSIGN
       ot-full.doc-code     = ub.ot-line.doc-code
       ot-full.doc-type     = (if available ub.trn-doc then ub.trn-doc.doc-code else " ")
       ot-full.cli-type     = (if available ub.trn-doc then ub.trn-doc.cli-type else " ")
       ot-full.cli-code     = (if available ub.trn-doc then ub.trn-doc.cli-code else 0)
       ot-full.artic        = tt-goods.artic
       ot-full.prod-type    = tt-goods.prod-type
       ot-full.prod-code    = tt-goods.prod-code
       ot-full.gds-type     = tt-goods.gds-type
       ot-full.obj-type     = tt-clients.obj-type
       ot-full.obj-code     = tt-clients.obj-code
       ot-full.fact-date    = (if available ub.trn-doc then ub.trn-doc.fact-date else ub.price-doc.fact-date)
       ot-full.fact-order   = (if available ub.trn-doc then ub.trn-doc.fact-order else ub.price-doc.fact-order)
       ot-full.ext-doc-type = ub.ot-line.ext-doc-type.
       ot-full.ext-doc-type-full =  entry(lookup(ot-full.ext-doc-type, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U), 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U).
       if available ub.trn-doc then do:
          find  ub.clients where  ub.clients.obj-type = ub.trn-doc.cli-type and
                              ub.clients.obj-code = ub.trn-doc.cli-code no-lock.
          assign ot-full.cli-name =  ub.clients.obj-name.
       end.
       else ot-full.cli-name = " ".
    END.
    if ot-full.gds-type = 'у':U then do:
      CASE ub.ot-line.sum-type:
         WHEN 'cssr':U THEN DO:
           if g-cost then
              ASSIGN
              ot-full.sum-base       = ot-full.sum-base       + ub.ot-line.sum-base
              ot-full.sum-rubl       = ot-full.sum-rubl       + ub.ot-line.sum-rubl
              ot-full.vat-base       = ot-full.vat-base       + ub.ot-line.vat-base
              ot-full.vat-rubl       = ot-full.vat-rubl       + ub.ot-line.vat-rubl
              ot-full.slt-base       = ot-full.slt-base       + ub.ot-line.slt-base
              ot-full.slt-rubl       = ot-full.slt-rubl       + ub.ot-line.slt-rubl
              ot-full.excise-base    = ot-full.excise-base    + ub.ot-line.excise-base
              ot-full.excise-rubl    = ot-full.excise-rubl    + ub.ot-line.excise-rubl
              ot-full.road-tax-base  = ot-full.road-tax-base  + ub.ot-line.road-tax-base
              ot-full.road-tax-rubl  = ot-full.road-tax-rubl  + ub.ot-line.road-tax-rubl
              ot-full.transport-base = ot-full.transport-base + ub.ot-line.transport-base
              ot-full.transport-rubl = ot-full.transport-rubl + ub.ot-line.transport-rubl
              ot-full.other-base     = ot-full.other-base     + ub.ot-line.other-base
              ot-full.other-rubl     = ot-full.other-rubl     + ub.ot-line.other-rubl.
           else
              ASSIGN
              ot-full.sum-base       = ?
              ot-full.sum-rubl       = ?
              ot-full.vat-base       = ?
              ot-full.vat-rubl       = ?
              ot-full.slt-base       = ?
              ot-full.slt-rubl       = ?
              ot-full.excise-base    = ?
              ot-full.excise-rubl    = ?
              ot-full.road-tax-base  = ?
              ot-full.road-tax-rubl  = ?
              ot-full.transport-base = ?
              ot-full.transport-rubl = ?
              ot-full.other-base     = ?
              ot-full.other-rubl     = ?.
         END.
         WHEN 'sasr':U THEN DO:
              assign ot-full.fact-qnty = ot-full.fact-qnty + ub.ot-line.fact-qnty.
              ASSIGN
              ot-full.sum-base-doc       = ot-full.sum-base-doc       + ub.ot-line.sum-base
              ot-full.sum-rubl-doc       = ot-full.sum-rubl-doc       + ub.ot-line.sum-rubl
              ot-full.vat-base-doc       = ot-full.vat-base-doc       + ub.ot-line.vat-base
              ot-full.vat-rubl-doc       = ot-full.vat-rubl-doc       + ub.ot-line.vat-rubl
              ot-full.slt-base-doc       = ot-full.slt-base-doc       + ub.ot-line.slt-base
              ot-full.slt-rubl-doc       = ot-full.slt-rubl-doc       + ub.ot-line.slt-rubl
              ot-full.excise-base-doc    = ot-full.excise-base-doc    + ub.ot-line.excise-base
              ot-full.excise-rubl-doc    = ot-full.excise-rubl-doc    + ub.ot-line.excise-rubl
              ot-full.road-tax-base-doc  = ot-full.road-tax-base-doc  + ub.ot-line.road-tax-base
              ot-full.road-tax-rubl-doc  = ot-full.road-tax-rubl-doc  + ub.ot-line.road-tax-rubl
              ot-full.transport-base-doc = ot-full.transport-base-doc + ub.ot-line.transport-base
              ot-full.transport-rubl-doc = ot-full.transport-rubl-doc + ub.ot-line.transport-rubl
              ot-full.other-base-doc     = ot-full.other-base-doc     + ub.ot-line.other-base
              ot-full.other-rubl-doc     = ot-full.other-rubl-doc     + ub.ot-line.other-rubl.
         END.
         WHEN 'cgsr':U THEN DO:
              ASSIGN
              ot-full.sum-base-sale       = ot-full.sum-base-sale       + ub.ot-line.sum-base
              ot-full.sum-rubl-sale       = ot-full.sum-rubl-sale       + ub.ot-line.sum-rubl
              ot-full.vat-base-sale       = ot-full.vat-base-sale       + ub.ot-line.vat-base
              ot-full.vat-rubl-sale       = ot-full.vat-rubl-sale       + ub.ot-line.vat-rubl
              ot-full.slt-base-sale       = ot-full.slt-base-sale       + ub.ot-line.slt-base
              ot-full.slt-rubl-sale       = ot-full.slt-rubl-sale       + ub.ot-line.slt-rubl
              ot-full.excise-base-sale    = ot-full.excise-base-sale    + ub.ot-line.excise-base
              ot-full.excise-rubl-sale    = ot-full.excise-rubl-sale    + ub.ot-line.excise-rubl
              ot-full.road-tax-base-sale  = ot-full.road-tax-base-sale  + ub.ot-line.road-tax-base
              ot-full.road-tax-rubl-sale  = ot-full.road-tax-rubl-sale  + ub.ot-line.road-tax-rubl
              ot-full.transport-base-sale = ot-full.transport-base-sale + ub.ot-line.transport-base
              ot-full.transport-rubl-sale = ot-full.transport-rubl-sale + ub.ot-line.transport-rubl
              ot-full.other-base-sale     = ot-full.other-base-sale     + ub.ot-line.other-base
              ot-full.other-rubl-sale     = ot-full.other-rubl-sale     + ub.ot-line.other-rubl .
         END.
         OTHERWISE DO:
           message "Некорректный sum-type " ub.ot-line.sum-type " при просмотре архива(b-otlina.w)." skip
                   "Ошибка в расчетах."
                   view-as alert-box error.
         END.
      END CASE.
    end.
    else do:
      CASE ub.ot-line.sum-type:
         WHEN 'cost':U THEN DO:
           assign ot-full.fact-qnty = ot-full.fact-qnty + ub.ot-line.fact-qnty.
           if g-cost then
              ASSIGN
              ot-full.sum-base       = ot-full.sum-base       + ub.ot-line.sum-base
              ot-full.sum-rubl       = ot-full.sum-rubl       + ub.ot-line.sum-rubl
              ot-full.vat-base       = ot-full.vat-base       + ub.ot-line.vat-base
              ot-full.vat-rubl       = ot-full.vat-rubl       + ub.ot-line.vat-rubl
              ot-full.slt-base       = ot-full.slt-base       + ub.ot-line.slt-base
              ot-full.slt-rubl       = ot-full.slt-rubl       + ub.ot-line.slt-rubl
              ot-full.excise-base    = ot-full.excise-base    + ub.ot-line.excise-base
              ot-full.excise-rubl    = ot-full.excise-rubl    + ub.ot-line.excise-rubl
              ot-full.road-tax-base  = ot-full.road-tax-base  + ub.ot-line.road-tax-base
              ot-full.road-tax-rubl  = ot-full.road-tax-rubl  + ub.ot-line.road-tax-rubl
              ot-full.transport-base = ot-full.transport-base + ub.ot-line.transport-base
              ot-full.transport-rubl = ot-full.transport-rubl + ub.ot-line.transport-rubl
              ot-full.other-base     = ot-full.other-base     + ub.ot-line.other-base
              ot-full.other-rubl     = ot-full.other-rubl     + ub.ot-line.other-rubl.
           else
              ASSIGN
              ot-full.sum-base       = ?
              ot-full.sum-rubl       = ?
              ot-full.vat-base       = ?
              ot-full.vat-rubl       = ?
              ot-full.slt-base       = ?
              ot-full.slt-rubl       = ?
              ot-full.excise-base    = ?
              ot-full.excise-rubl    = ?
              ot-full.road-tax-base  = ?
              ot-full.road-tax-rubl  = ?
              ot-full.transport-base = ?
              ot-full.transport-rubl = ?
              ot-full.other-base     = ?
              ot-full.other-rubl     = ?.
         END.
         WHEN 'sale':U THEN DO:
              ASSIGN
              ot-full.sum-base-doc       = ot-full.sum-base-doc       + ub.ot-line.sum-base
              ot-full.sum-rubl-doc       = ot-full.sum-rubl-doc       + ub.ot-line.sum-rubl
              ot-full.vat-base-doc       = ot-full.vat-base-doc       + ub.ot-line.vat-base
              ot-full.vat-rubl-doc       = ot-full.vat-rubl-doc       + ub.ot-line.vat-rubl
              ot-full.slt-base-doc       = ot-full.slt-base-doc       + ub.ot-line.slt-base
              ot-full.slt-rubl-doc       = ot-full.slt-rubl-doc       + ub.ot-line.slt-rubl
              ot-full.excise-base-doc    = ot-full.excise-base-doc    + ub.ot-line.excise-base
              ot-full.excise-rubl-doc    = ot-full.excise-rubl-doc    + ub.ot-line.excise-rubl
              ot-full.road-tax-base-doc  = ot-full.road-tax-base-doc  + ub.ot-line.road-tax-base
              ot-full.road-tax-rubl-doc  = ot-full.road-tax-rubl-doc  + ub.ot-line.road-tax-rubl
              ot-full.transport-base-doc = ot-full.transport-base-doc + ub.ot-line.transport-base
              ot-full.transport-rubl-doc = ot-full.transport-rubl-doc + ub.ot-line.transport-rubl
              ot-full.other-base-doc     = ot-full.other-base-doc     + ub.ot-line.other-base
              ot-full.other-rubl-doc     = ot-full.other-rubl-doc     + ub.ot-line.other-rubl.
         END.
         WHEN 'crsa':U THEN DO:
              ASSIGN
              ot-full.sum-base-sale       = ot-full.sum-base-sale       + ub.ot-line.sum-base
              ot-full.sum-rubl-sale       = ot-full.sum-rubl-sale       + ub.ot-line.sum-rubl
              ot-full.vat-base-sale       = ot-full.vat-base-sale       + ub.ot-line.vat-base
              ot-full.vat-rubl-sale       = ot-full.vat-rubl-sale       + ub.ot-line.vat-rubl
              ot-full.slt-base-sale       = ot-full.slt-base-sale       + ub.ot-line.slt-base
              ot-full.slt-rubl-sale       = ot-full.slt-rubl-sale       + ub.ot-line.slt-rubl
              ot-full.excise-base-sale    = ot-full.excise-base-sale    + ub.ot-line.excise-base
              ot-full.excise-rubl-sale    = ot-full.excise-rubl-sale    + ub.ot-line.excise-rubl
              ot-full.road-tax-base-sale  = ot-full.road-tax-base-sale  + ub.ot-line.road-tax-base
              ot-full.road-tax-rubl-sale  = ot-full.road-tax-rubl-sale  + ub.ot-line.road-tax-rubl
              ot-full.transport-base-sale = ot-full.transport-base-sale + ub.ot-line.transport-base
              ot-full.transport-rubl-sale = ot-full.transport-rubl-sale + ub.ot-line.transport-rubl
              ot-full.other-base-sale     = ot-full.other-base-sale     + ub.ot-line.other-base
              ot-full.other-rubl-sale     = ot-full.other-rubl-sale     + ub.ot-line.other-rubl .
         END.
         OTHERWISE DO:
           message "Некорректный sum-type " ub.ot-line.sum-type " при просмотре архива(b-otlina.w)." skip
                   "Ошибка в расчетах."
                   view-as alert-box error.
         END.
      END CASE.
    end.
END.
      OPEN QUERY b-ot-line FOR EACH ot-full.
   end.
end.
else do:
   if g-cost
   then do:
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FOR EACH tt-clients,
    EACH tt-goods,
    EACH ub.ot-line WHERE
         ub.ot-line.obj-code   = tt-clients.obj-code and
         ub.ot-line.obj-type   = tt-clients.obj-type and
         ub.ot-line.artic      = tt-goods.artic      and
         ub.ot-line.prod-type  = tt-goods.prod-type  and
         ub.ot-line.prod-code  = tt-goods.prod-code  and
         ub.ot-line.fact-order > fact-order-min      and
         ub.ot-line.fact-order <= fact-order-max
         and ub.ot-line.ext-doc-type = varext-doc-type-short NO-LOCK:
    if ub.ot-line.sum-type begins 'cost':U         and ub.ot-line.cat-id <> '##,##':U then next.
    if ub.ot-line.sum-type begins 'cssr':U and ub.ot-line.cat-id <> '##,##':U then next.
    FIND FIRST ub.trn-doc   WHERE ub.trn-doc.doc-code  = ub.ot-line.doc-code NO-LOCK NO-ERROR.
    FIND FIRST ub.price-doc WHERE ub.price-doc.doc-num = ub.ot-line.doc-code NO-LOCK NO-ERROR.
    IF AVAILABLE ub.trn-doc THEN
       FIND FIRST ot-full WHERE ot-full.doc-code = ub.trn-doc.doc-code NO-ERROR.
    ELSE
       FIND FIRST ot-full WHERE ot-full.doc-code = ub.price-doc.doc-num NO-ERROR.
    IF NOT AVAILABLE ot-full THEN DO:
       CREATE ot-full.
       ASSIGN
       ot-full.doc-code     = ub.ot-line.doc-code
       ot-full.doc-type     = (if available ub.trn-doc then ub.trn-doc.doc-code else " ")
       ot-full.cli-type     = (if available ub.trn-doc then ub.trn-doc.cli-type else " ")
       ot-full.cli-code     = (if available ub.trn-doc then ub.trn-doc.cli-code else 0)
       ot-full.artic        = tt-goods.artic
       ot-full.prod-type    = tt-goods.prod-type
       ot-full.prod-code    = tt-goods.prod-code
       ot-full.gds-type     = tt-goods.gds-type
       ot-full.obj-type     = tt-clients.obj-type
       ot-full.obj-code     = tt-clients.obj-code
       ot-full.fact-date    = (if available ub.trn-doc then ub.trn-doc.fact-date else ub.price-doc.fact-date)
       ot-full.fact-order   = (if available ub.trn-doc then ub.trn-doc.fact-order else ub.price-doc.fact-order)
       ot-full.ext-doc-type = ub.ot-line.ext-doc-type.
       ot-full.ext-doc-type-full =  entry(lookup(ot-full.ext-doc-type, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U), 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U).
       if available ub.trn-doc then do:
          find  ub.clients where  ub.clients.obj-type = ub.trn-doc.cli-type and
                              ub.clients.obj-code = ub.trn-doc.cli-code no-lock.
          assign ot-full.cli-name =  ub.clients.obj-name.
       end.
       else ot-full.cli-name = " ".
    END.
    if ot-full.gds-type = 'у':U then do:
      CASE ub.ot-line.sum-type:
         WHEN 'cssr':U THEN DO:
           if g-cost then
              ASSIGN
              ot-full.sum-base       = ot-full.sum-base       + ub.ot-line.sum-base
              ot-full.sum-rubl       = ot-full.sum-rubl       + ub.ot-line.sum-rubl
              ot-full.vat-base       = ot-full.vat-base       + ub.ot-line.vat-base
              ot-full.vat-rubl       = ot-full.vat-rubl       + ub.ot-line.vat-rubl
              ot-full.slt-base       = ot-full.slt-base       + ub.ot-line.slt-base
              ot-full.slt-rubl       = ot-full.slt-rubl       + ub.ot-line.slt-rubl
              ot-full.excise-base    = ot-full.excise-base    + ub.ot-line.excise-base
              ot-full.excise-rubl    = ot-full.excise-rubl    + ub.ot-line.excise-rubl
              ot-full.road-tax-base  = ot-full.road-tax-base  + ub.ot-line.road-tax-base
              ot-full.road-tax-rubl  = ot-full.road-tax-rubl  + ub.ot-line.road-tax-rubl
              ot-full.transport-base = ot-full.transport-base + ub.ot-line.transport-base
              ot-full.transport-rubl = ot-full.transport-rubl + ub.ot-line.transport-rubl
              ot-full.other-base     = ot-full.other-base     + ub.ot-line.other-base
              ot-full.other-rubl     = ot-full.other-rubl     + ub.ot-line.other-rubl.
           else
              ASSIGN
              ot-full.sum-base       = ?
              ot-full.sum-rubl       = ?
              ot-full.vat-base       = ?
              ot-full.vat-rubl       = ?
              ot-full.slt-base       = ?
              ot-full.slt-rubl       = ?
              ot-full.excise-base    = ?
              ot-full.excise-rubl    = ?
              ot-full.road-tax-base  = ?
              ot-full.road-tax-rubl  = ?
              ot-full.transport-base = ?
              ot-full.transport-rubl = ?
              ot-full.other-base     = ?
              ot-full.other-rubl     = ?.
         END.
         WHEN 'sasr':U THEN DO:
              assign ot-full.fact-qnty = ot-full.fact-qnty + ub.ot-line.fact-qnty.
              ASSIGN
              ot-full.sum-base-doc       = ot-full.sum-base-doc       + ub.ot-line.sum-base
              ot-full.sum-rubl-doc       = ot-full.sum-rubl-doc       + ub.ot-line.sum-rubl
              ot-full.vat-base-doc       = ot-full.vat-base-doc       + ub.ot-line.vat-base
              ot-full.vat-rubl-doc       = ot-full.vat-rubl-doc       + ub.ot-line.vat-rubl
              ot-full.slt-base-doc       = ot-full.slt-base-doc       + ub.ot-line.slt-base
              ot-full.slt-rubl-doc       = ot-full.slt-rubl-doc       + ub.ot-line.slt-rubl
              ot-full.excise-base-doc    = ot-full.excise-base-doc    + ub.ot-line.excise-base
              ot-full.excise-rubl-doc    = ot-full.excise-rubl-doc    + ub.ot-line.excise-rubl
              ot-full.road-tax-base-doc  = ot-full.road-tax-base-doc  + ub.ot-line.road-tax-base
              ot-full.road-tax-rubl-doc  = ot-full.road-tax-rubl-doc  + ub.ot-line.road-tax-rubl
              ot-full.transport-base-doc = ot-full.transport-base-doc + ub.ot-line.transport-base
              ot-full.transport-rubl-doc = ot-full.transport-rubl-doc + ub.ot-line.transport-rubl
              ot-full.other-base-doc     = ot-full.other-base-doc     + ub.ot-line.other-base
              ot-full.other-rubl-doc     = ot-full.other-rubl-doc     + ub.ot-line.other-rubl.
         END.
         WHEN 'cgsr':U THEN DO:
              ASSIGN
              ot-full.sum-base-sale       = ot-full.sum-base-sale       + ub.ot-line.sum-base
              ot-full.sum-rubl-sale       = ot-full.sum-rubl-sale       + ub.ot-line.sum-rubl
              ot-full.vat-base-sale       = ot-full.vat-base-sale       + ub.ot-line.vat-base
              ot-full.vat-rubl-sale       = ot-full.vat-rubl-sale       + ub.ot-line.vat-rubl
              ot-full.slt-base-sale       = ot-full.slt-base-sale       + ub.ot-line.slt-base
              ot-full.slt-rubl-sale       = ot-full.slt-rubl-sale       + ub.ot-line.slt-rubl
              ot-full.excise-base-sale    = ot-full.excise-base-sale    + ub.ot-line.excise-base
              ot-full.excise-rubl-sale    = ot-full.excise-rubl-sale    + ub.ot-line.excise-rubl
              ot-full.road-tax-base-sale  = ot-full.road-tax-base-sale  + ub.ot-line.road-tax-base
              ot-full.road-tax-rubl-sale  = ot-full.road-tax-rubl-sale  + ub.ot-line.road-tax-rubl
              ot-full.transport-base-sale = ot-full.transport-base-sale + ub.ot-line.transport-base
              ot-full.transport-rubl-sale = ot-full.transport-rubl-sale + ub.ot-line.transport-rubl
              ot-full.other-base-sale     = ot-full.other-base-sale     + ub.ot-line.other-base
              ot-full.other-rubl-sale     = ot-full.other-rubl-sale     + ub.ot-line.other-rubl .
         END.
         OTHERWISE DO:
           message "Некорректный sum-type " ub.ot-line.sum-type " при просмотре архива(b-otlina.w)." skip
                   "Ошибка в расчетах."
                   view-as alert-box error.
         END.
      END CASE.
    end.
    else do:
      CASE ub.ot-line.sum-type:
         WHEN 'cost':U THEN DO:
           assign ot-full.fact-qnty = ot-full.fact-qnty + ub.ot-line.fact-qnty.
           if g-cost then
              ASSIGN
              ot-full.sum-base       = ot-full.sum-base       + ub.ot-line.sum-base
              ot-full.sum-rubl       = ot-full.sum-rubl       + ub.ot-line.sum-rubl
              ot-full.vat-base       = ot-full.vat-base       + ub.ot-line.vat-base
              ot-full.vat-rubl       = ot-full.vat-rubl       + ub.ot-line.vat-rubl
              ot-full.slt-base       = ot-full.slt-base       + ub.ot-line.slt-base
              ot-full.slt-rubl       = ot-full.slt-rubl       + ub.ot-line.slt-rubl
              ot-full.excise-base    = ot-full.excise-base    + ub.ot-line.excise-base
              ot-full.excise-rubl    = ot-full.excise-rubl    + ub.ot-line.excise-rubl
              ot-full.road-tax-base  = ot-full.road-tax-base  + ub.ot-line.road-tax-base
              ot-full.road-tax-rubl  = ot-full.road-tax-rubl  + ub.ot-line.road-tax-rubl
              ot-full.transport-base = ot-full.transport-base + ub.ot-line.transport-base
              ot-full.transport-rubl = ot-full.transport-rubl + ub.ot-line.transport-rubl
              ot-full.other-base     = ot-full.other-base     + ub.ot-line.other-base
              ot-full.other-rubl     = ot-full.other-rubl     + ub.ot-line.other-rubl.
           else
              ASSIGN
              ot-full.sum-base       = ?
              ot-full.sum-rubl       = ?
              ot-full.vat-base       = ?
              ot-full.vat-rubl       = ?
              ot-full.slt-base       = ?
              ot-full.slt-rubl       = ?
              ot-full.excise-base    = ?
              ot-full.excise-rubl    = ?
              ot-full.road-tax-base  = ?
              ot-full.road-tax-rubl  = ?
              ot-full.transport-base = ?
              ot-full.transport-rubl = ?
              ot-full.other-base     = ?
              ot-full.other-rubl     = ?.
         END.
         WHEN 'sale':U THEN DO:
              ASSIGN
              ot-full.sum-base-doc       = ot-full.sum-base-doc       + ub.ot-line.sum-base
              ot-full.sum-rubl-doc       = ot-full.sum-rubl-doc       + ub.ot-line.sum-rubl
              ot-full.vat-base-doc       = ot-full.vat-base-doc       + ub.ot-line.vat-base
              ot-full.vat-rubl-doc       = ot-full.vat-rubl-doc       + ub.ot-line.vat-rubl
              ot-full.slt-base-doc       = ot-full.slt-base-doc       + ub.ot-line.slt-base
              ot-full.slt-rubl-doc       = ot-full.slt-rubl-doc       + ub.ot-line.slt-rubl
              ot-full.excise-base-doc    = ot-full.excise-base-doc    + ub.ot-line.excise-base
              ot-full.excise-rubl-doc    = ot-full.excise-rubl-doc    + ub.ot-line.excise-rubl
              ot-full.road-tax-base-doc  = ot-full.road-tax-base-doc  + ub.ot-line.road-tax-base
              ot-full.road-tax-rubl-doc  = ot-full.road-tax-rubl-doc  + ub.ot-line.road-tax-rubl
              ot-full.transport-base-doc = ot-full.transport-base-doc + ub.ot-line.transport-base
              ot-full.transport-rubl-doc = ot-full.transport-rubl-doc + ub.ot-line.transport-rubl
              ot-full.other-base-doc     = ot-full.other-base-doc     + ub.ot-line.other-base
              ot-full.other-rubl-doc     = ot-full.other-rubl-doc     + ub.ot-line.other-rubl.
         END.
         WHEN 'crsa':U THEN DO:
              ASSIGN
              ot-full.sum-base-sale       = ot-full.sum-base-sale       + ub.ot-line.sum-base
              ot-full.sum-rubl-sale       = ot-full.sum-rubl-sale       + ub.ot-line.sum-rubl
              ot-full.vat-base-sale       = ot-full.vat-base-sale       + ub.ot-line.vat-base
              ot-full.vat-rubl-sale       = ot-full.vat-rubl-sale       + ub.ot-line.vat-rubl
              ot-full.slt-base-sale       = ot-full.slt-base-sale       + ub.ot-line.slt-base
              ot-full.slt-rubl-sale       = ot-full.slt-rubl-sale       + ub.ot-line.slt-rubl
              ot-full.excise-base-sale    = ot-full.excise-base-sale    + ub.ot-line.excise-base
              ot-full.excise-rubl-sale    = ot-full.excise-rubl-sale    + ub.ot-line.excise-rubl
              ot-full.road-tax-base-sale  = ot-full.road-tax-base-sale  + ub.ot-line.road-tax-base
              ot-full.road-tax-rubl-sale  = ot-full.road-tax-rubl-sale  + ub.ot-line.road-tax-rubl
              ot-full.transport-base-sale = ot-full.transport-base-sale + ub.ot-line.transport-base
              ot-full.transport-rubl-sale = ot-full.transport-rubl-sale + ub.ot-line.transport-rubl
              ot-full.other-base-sale     = ot-full.other-base-sale     + ub.ot-line.other-base
              ot-full.other-rubl-sale     = ot-full.other-rubl-sale     + ub.ot-line.other-rubl .
         END.
         OTHERWISE DO:
           message "Некорректный sum-type " ub.ot-line.sum-type " при просмотре архива(b-otlina.w)." skip
                   "Ошибка в расчетах."
                   view-as alert-box error.
         END.
      END CASE.
    end.
END.
      OPEN QUERY b-ot-line FOR EACH ot-full.
   end.
   else do:
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FOR EACH tt-clients,
    EACH tt-goods,
    EACH ub.ot-line WHERE
         ub.ot-line.obj-code   = tt-clients.obj-code and
         ub.ot-line.obj-type   = tt-clients.obj-type and
         ub.ot-line.artic      = tt-goods.artic      and
         ub.ot-line.prod-type  = tt-goods.prod-type  and
         ub.ot-line.prod-code  = tt-goods.prod-code  and
         ub.ot-line.fact-order > fact-order-min      and
         ub.ot-line.fact-order <= fact-order-max
         and ub.ot-line.sum-type <> 'cost':U
         and ub.ot-line.ext-doc-type = varext-doc-type-short NO-LOCK:
    if ub.ot-line.sum-type begins 'cost':U         and ub.ot-line.cat-id <> '##,##':U then next.
    if ub.ot-line.sum-type begins 'cssr':U and ub.ot-line.cat-id <> '##,##':U then next.
    FIND FIRST ub.trn-doc   WHERE ub.trn-doc.doc-code  = ub.ot-line.doc-code NO-LOCK NO-ERROR.
    FIND FIRST ub.price-doc WHERE ub.price-doc.doc-num = ub.ot-line.doc-code NO-LOCK NO-ERROR.
    IF AVAILABLE ub.trn-doc THEN
       FIND FIRST ot-full WHERE ot-full.doc-code = ub.trn-doc.doc-code NO-ERROR.
    ELSE
       FIND FIRST ot-full WHERE ot-full.doc-code = ub.price-doc.doc-num NO-ERROR.
    IF NOT AVAILABLE ot-full THEN DO:
       CREATE ot-full.
       ASSIGN
       ot-full.doc-code     = ub.ot-line.doc-code
       ot-full.doc-type     = (if available ub.trn-doc then ub.trn-doc.doc-code else " ")
       ot-full.cli-type     = (if available ub.trn-doc then ub.trn-doc.cli-type else " ")
       ot-full.cli-code     = (if available ub.trn-doc then ub.trn-doc.cli-code else 0)
       ot-full.artic        = tt-goods.artic
       ot-full.prod-type    = tt-goods.prod-type
       ot-full.prod-code    = tt-goods.prod-code
       ot-full.gds-type     = tt-goods.gds-type
       ot-full.obj-type     = tt-clients.obj-type
       ot-full.obj-code     = tt-clients.obj-code
       ot-full.fact-date    = (if available ub.trn-doc then ub.trn-doc.fact-date else ub.price-doc.fact-date)
       ot-full.fact-order   = (if available ub.trn-doc then ub.trn-doc.fact-order else ub.price-doc.fact-order)
       ot-full.ext-doc-type = ub.ot-line.ext-doc-type.
       ot-full.ext-doc-type-full =  entry(lookup(ot-full.ext-doc-type, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U), 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U).
       if available ub.trn-doc then do:
          find  ub.clients where  ub.clients.obj-type = ub.trn-doc.cli-type and
                              ub.clients.obj-code = ub.trn-doc.cli-code no-lock.
          assign ot-full.cli-name =  ub.clients.obj-name.
       end.
       else ot-full.cli-name = " ".
    END.
    if ot-full.gds-type = 'у':U then do:
      CASE ub.ot-line.sum-type:
         WHEN 'cssr':U THEN DO:
           if g-cost then
              ASSIGN
              ot-full.sum-base       = ot-full.sum-base       + ub.ot-line.sum-base
              ot-full.sum-rubl       = ot-full.sum-rubl       + ub.ot-line.sum-rubl
              ot-full.vat-base       = ot-full.vat-base       + ub.ot-line.vat-base
              ot-full.vat-rubl       = ot-full.vat-rubl       + ub.ot-line.vat-rubl
              ot-full.slt-base       = ot-full.slt-base       + ub.ot-line.slt-base
              ot-full.slt-rubl       = ot-full.slt-rubl       + ub.ot-line.slt-rubl
              ot-full.excise-base    = ot-full.excise-base    + ub.ot-line.excise-base
              ot-full.excise-rubl    = ot-full.excise-rubl    + ub.ot-line.excise-rubl
              ot-full.road-tax-base  = ot-full.road-tax-base  + ub.ot-line.road-tax-base
              ot-full.road-tax-rubl  = ot-full.road-tax-rubl  + ub.ot-line.road-tax-rubl
              ot-full.transport-base = ot-full.transport-base + ub.ot-line.transport-base
              ot-full.transport-rubl = ot-full.transport-rubl + ub.ot-line.transport-rubl
              ot-full.other-base     = ot-full.other-base     + ub.ot-line.other-base
              ot-full.other-rubl     = ot-full.other-rubl     + ub.ot-line.other-rubl.
           else
              ASSIGN
              ot-full.sum-base       = ?
              ot-full.sum-rubl       = ?
              ot-full.vat-base       = ?
              ot-full.vat-rubl       = ?
              ot-full.slt-base       = ?
              ot-full.slt-rubl       = ?
              ot-full.excise-base    = ?
              ot-full.excise-rubl    = ?
              ot-full.road-tax-base  = ?
              ot-full.road-tax-rubl  = ?
              ot-full.transport-base = ?
              ot-full.transport-rubl = ?
              ot-full.other-base     = ?
              ot-full.other-rubl     = ?.
         END.
         WHEN 'sasr':U THEN DO:
              assign ot-full.fact-qnty = ot-full.fact-qnty + ub.ot-line.fact-qnty.
              ASSIGN
              ot-full.sum-base-doc       = ot-full.sum-base-doc       + ub.ot-line.sum-base
              ot-full.sum-rubl-doc       = ot-full.sum-rubl-doc       + ub.ot-line.sum-rubl
              ot-full.vat-base-doc       = ot-full.vat-base-doc       + ub.ot-line.vat-base
              ot-full.vat-rubl-doc       = ot-full.vat-rubl-doc       + ub.ot-line.vat-rubl
              ot-full.slt-base-doc       = ot-full.slt-base-doc       + ub.ot-line.slt-base
              ot-full.slt-rubl-doc       = ot-full.slt-rubl-doc       + ub.ot-line.slt-rubl
              ot-full.excise-base-doc    = ot-full.excise-base-doc    + ub.ot-line.excise-base
              ot-full.excise-rubl-doc    = ot-full.excise-rubl-doc    + ub.ot-line.excise-rubl
              ot-full.road-tax-base-doc  = ot-full.road-tax-base-doc  + ub.ot-line.road-tax-base
              ot-full.road-tax-rubl-doc  = ot-full.road-tax-rubl-doc  + ub.ot-line.road-tax-rubl
              ot-full.transport-base-doc = ot-full.transport-base-doc + ub.ot-line.transport-base
              ot-full.transport-rubl-doc = ot-full.transport-rubl-doc + ub.ot-line.transport-rubl
              ot-full.other-base-doc     = ot-full.other-base-doc     + ub.ot-line.other-base
              ot-full.other-rubl-doc     = ot-full.other-rubl-doc     + ub.ot-line.other-rubl.
         END.
         WHEN 'cgsr':U THEN DO:
              ASSIGN
              ot-full.sum-base-sale       = ot-full.sum-base-sale       + ub.ot-line.sum-base
              ot-full.sum-rubl-sale       = ot-full.sum-rubl-sale       + ub.ot-line.sum-rubl
              ot-full.vat-base-sale       = ot-full.vat-base-sale       + ub.ot-line.vat-base
              ot-full.vat-rubl-sale       = ot-full.vat-rubl-sale       + ub.ot-line.vat-rubl
              ot-full.slt-base-sale       = ot-full.slt-base-sale       + ub.ot-line.slt-base
              ot-full.slt-rubl-sale       = ot-full.slt-rubl-sale       + ub.ot-line.slt-rubl
              ot-full.excise-base-sale    = ot-full.excise-base-sale    + ub.ot-line.excise-base
              ot-full.excise-rubl-sale    = ot-full.excise-rubl-sale    + ub.ot-line.excise-rubl
              ot-full.road-tax-base-sale  = ot-full.road-tax-base-sale  + ub.ot-line.road-tax-base
              ot-full.road-tax-rubl-sale  = ot-full.road-tax-rubl-sale  + ub.ot-line.road-tax-rubl
              ot-full.transport-base-sale = ot-full.transport-base-sale + ub.ot-line.transport-base
              ot-full.transport-rubl-sale = ot-full.transport-rubl-sale + ub.ot-line.transport-rubl
              ot-full.other-base-sale     = ot-full.other-base-sale     + ub.ot-line.other-base
              ot-full.other-rubl-sale     = ot-full.other-rubl-sale     + ub.ot-line.other-rubl .
         END.
         OTHERWISE DO:
           message "Некорректный sum-type " ub.ot-line.sum-type " при просмотре архива(b-otlina.w)." skip
                   "Ошибка в расчетах."
                   view-as alert-box error.
         END.
      END CASE.
    end.
    else do:
      CASE ub.ot-line.sum-type:
         WHEN 'cost':U THEN DO:
           assign ot-full.fact-qnty = ot-full.fact-qnty + ub.ot-line.fact-qnty.
           if g-cost then
              ASSIGN
              ot-full.sum-base       = ot-full.sum-base       + ub.ot-line.sum-base
              ot-full.sum-rubl       = ot-full.sum-rubl       + ub.ot-line.sum-rubl
              ot-full.vat-base       = ot-full.vat-base       + ub.ot-line.vat-base
              ot-full.vat-rubl       = ot-full.vat-rubl       + ub.ot-line.vat-rubl
              ot-full.slt-base       = ot-full.slt-base       + ub.ot-line.slt-base
              ot-full.slt-rubl       = ot-full.slt-rubl       + ub.ot-line.slt-rubl
              ot-full.excise-base    = ot-full.excise-base    + ub.ot-line.excise-base
              ot-full.excise-rubl    = ot-full.excise-rubl    + ub.ot-line.excise-rubl
              ot-full.road-tax-base  = ot-full.road-tax-base  + ub.ot-line.road-tax-base
              ot-full.road-tax-rubl  = ot-full.road-tax-rubl  + ub.ot-line.road-tax-rubl
              ot-full.transport-base = ot-full.transport-base + ub.ot-line.transport-base
              ot-full.transport-rubl = ot-full.transport-rubl + ub.ot-line.transport-rubl
              ot-full.other-base     = ot-full.other-base     + ub.ot-line.other-base
              ot-full.other-rubl     = ot-full.other-rubl     + ub.ot-line.other-rubl.
           else
              ASSIGN
              ot-full.sum-base       = ?
              ot-full.sum-rubl       = ?
              ot-full.vat-base       = ?
              ot-full.vat-rubl       = ?
              ot-full.slt-base       = ?
              ot-full.slt-rubl       = ?
              ot-full.excise-base    = ?
              ot-full.excise-rubl    = ?
              ot-full.road-tax-base  = ?
              ot-full.road-tax-rubl  = ?
              ot-full.transport-base = ?
              ot-full.transport-rubl = ?
              ot-full.other-base     = ?
              ot-full.other-rubl     = ?.
         END.
         WHEN 'sale':U THEN DO:
              ASSIGN
              ot-full.sum-base-doc       = ot-full.sum-base-doc       + ub.ot-line.sum-base
              ot-full.sum-rubl-doc       = ot-full.sum-rubl-doc       + ub.ot-line.sum-rubl
              ot-full.vat-base-doc       = ot-full.vat-base-doc       + ub.ot-line.vat-base
              ot-full.vat-rubl-doc       = ot-full.vat-rubl-doc       + ub.ot-line.vat-rubl
              ot-full.slt-base-doc       = ot-full.slt-base-doc       + ub.ot-line.slt-base
              ot-full.slt-rubl-doc       = ot-full.slt-rubl-doc       + ub.ot-line.slt-rubl
              ot-full.excise-base-doc    = ot-full.excise-base-doc    + ub.ot-line.excise-base
              ot-full.excise-rubl-doc    = ot-full.excise-rubl-doc    + ub.ot-line.excise-rubl
              ot-full.road-tax-base-doc  = ot-full.road-tax-base-doc  + ub.ot-line.road-tax-base
              ot-full.road-tax-rubl-doc  = ot-full.road-tax-rubl-doc  + ub.ot-line.road-tax-rubl
              ot-full.transport-base-doc = ot-full.transport-base-doc + ub.ot-line.transport-base
              ot-full.transport-rubl-doc = ot-full.transport-rubl-doc + ub.ot-line.transport-rubl
              ot-full.other-base-doc     = ot-full.other-base-doc     + ub.ot-line.other-base
              ot-full.other-rubl-doc     = ot-full.other-rubl-doc     + ub.ot-line.other-rubl.
         END.
         WHEN 'crsa':U THEN DO:
              ASSIGN
              ot-full.sum-base-sale       = ot-full.sum-base-sale       + ub.ot-line.sum-base
              ot-full.sum-rubl-sale       = ot-full.sum-rubl-sale       + ub.ot-line.sum-rubl
              ot-full.vat-base-sale       = ot-full.vat-base-sale       + ub.ot-line.vat-base
              ot-full.vat-rubl-sale       = ot-full.vat-rubl-sale       + ub.ot-line.vat-rubl
              ot-full.slt-base-sale       = ot-full.slt-base-sale       + ub.ot-line.slt-base
              ot-full.slt-rubl-sale       = ot-full.slt-rubl-sale       + ub.ot-line.slt-rubl
              ot-full.excise-base-sale    = ot-full.excise-base-sale    + ub.ot-line.excise-base
              ot-full.excise-rubl-sale    = ot-full.excise-rubl-sale    + ub.ot-line.excise-rubl
              ot-full.road-tax-base-sale  = ot-full.road-tax-base-sale  + ub.ot-line.road-tax-base
              ot-full.road-tax-rubl-sale  = ot-full.road-tax-rubl-sale  + ub.ot-line.road-tax-rubl
              ot-full.transport-base-sale = ot-full.transport-base-sale + ub.ot-line.transport-base
              ot-full.transport-rubl-sale = ot-full.transport-rubl-sale + ub.ot-line.transport-rubl
              ot-full.other-base-sale     = ot-full.other-base-sale     + ub.ot-line.other-base
              ot-full.other-rubl-sale     = ot-full.other-rubl-sale     + ub.ot-line.other-rubl .
         END.
         OTHERWISE DO:
           message "Некорректный sum-type " ub.ot-line.sum-type " при просмотре архива(b-otlina.w)." skip
                   "Ошибка в расчетах."
                   view-as alert-box error.
         END.
      END CASE.
    end.
END.
      OPEN QUERY b-ot-line FOR EACH ot-full.
   end.
end.
END PROCEDURE.
PROCEDURE state-changed :
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER p-state      AS CHARACTER NO-UNDO.
  CASE p-state:
       when 'detail' then do:
          assign varh_arh = p-issuer-hdl.
       end.
    WHEN "update-begin":U THEN
    DO:
        adm-brs-in-update = yes.
        RUN dispatch ('enable-fields':U).
        IF RETURN-VALUE = "ADM-ERROR":U THEN
        DO:
          RUN new-state('update-failed,TABLEIO-SOURCE':U).
          RUN new-state('update-complete':U).
        END.
        ELSE DO:
          RUN dispatch ('apply-entry':U).
          RUN new-state('update':U).
        END.
    END.
    WHEN "update":U THEN
      DO:
        DEFINE VARIABLE group-link AS CHARACTER NO-UNDO INIT "":U.
        RUN get-link-handle IN adm-broker-hdl
            (INPUT THIS-PROCEDURE, 'GROUP-ASSIGN-TARGET':U, OUTPUT group-link)
                NO-ERROR.
        IF LOOKUP(STRING(p-issuer-hdl), group-link) EQ 0 THEN
          b-ot-line:SENSITIVE IN FRAME F-Main = no.
      END.
    WHEN "update-complete":U THEN DO:
        b-ot-line:SENSITIVE IN FRAME F-Main = yes.
        adm-brs-in-update = no.
        RUN get-attribute IN p-issuer-hdl ('QUERY-OBJECT':U).
        IF RETURN-VALUE NE "YES":U THEN
        DO:
          IF NUM-RESULTS("b-ot-line":U) NE ? AND
             NUM-RESULTS("b-ot-line":U) NE 0
          THEN DO:
            GET CURRENT b-ot-line.
            RUN dispatch ('row-changed':U).
          END.
        END.
        RUN new-state ('update-complete':U).
    END.
    WHEN "delete-complete":U THEN DO:
       DEFINE VARIABLE sts AS LOGICAL NO-UNDO.
       sts = b-ot-line:DELETE-CURRENT-ROW() IN FRAME F-Main.
       IF NUM-RESULTS("b-ot-line":U) = 0 THEN
         RUN notify('row-available':U).
    END.
    WHEN   'first-record':U        OR
      WHEN 'last-record':U         OR
      WHEN 'only-record':U         OR
      WHEN 'not-first-or-last':U   OR
      WHEN 'no-record-available':U OR
      WHEN 'no-external-record-available':U THEN
        RUN set-attribute-list('Query-Position=':U + p-state).
  END CASE.
END PROCEDURE.
FUNCTION func-excise RETURNS DECIMAL
      ( buffer bf_ot-full for ot-full ) :
    if varrubl-base = 1 then return bf_ot-full.excise-rubl.
                        else return bf_ot-full.excise-base.
END FUNCTION.
FUNCTION func-excise-doc RETURNS DECIMAL
   ( buffer bf_ot-full for ot-full ) :
    if varrubl-base = 1 then return bf_ot-full.excise-rubl-doc.
                        else return bf_ot-full.excise-base-doc.
END FUNCTION.
FUNCTION func-other RETURNS DECIMAL
    ( buffer bf_ot-full for ot-full ) :
    if varrubl-base = 1 then return bf_ot-full.other-rubl.
                        else return bf_ot-full.other-base.
END FUNCTION.
FUNCTION func-other-doc RETURNS DECIMAL
    ( buffer bf_ot-full for ot-full ) :
    if varrubl-base = 1 then return bf_ot-full.other-rubl-doc.
                        else return bf_ot-full.other-base-doc.
END FUNCTION.
FUNCTION func-price-doc RETURNS DECIMAL
  ( buffer bf_ot-full for ot-full ) :
    if varrubl-base = 1 then return (bf_ot-full.sum-rubl-doc / bf_ot-full.fact-qnty).
                        else return (bf_ot-full.sum-base-doc / bf_ot-full.fact-qnty).
END FUNCTION.
FUNCTION func-price-sale RETURNS DECIMAL
  ( buffer bf_ot-full for ot-full ) :
    if varrubl-base = 1 then return (bf_ot-full.sum-rubl-sale / bf_ot-full.fact-qnty).
                        else return (bf_ot-full.sum-base-sale / bf_ot-full.fact-qnty).
END FUNCTION.
FUNCTION func-road-tax RETURNS DECIMAL
    ( buffer bf_ot-full for ot-full ) :
    if varrubl-base = 1 then return bf_ot-full.road-tax-rubl.
                        else return bf_ot-full.road-tax-base.
END FUNCTION.
FUNCTION func-road-tax-doc RETURNS DECIMAL
    ( buffer bf_ot-full for ot-full ) :
    if varrubl-base = 1 then return bf_ot-full.road-tax-rubl-doc.
                        else return bf_ot-full.road-tax-base-doc.
END FUNCTION.
FUNCTION func-SLT RETURNS DECIMAL
    ( buffer bf_ot-full for ot-full ) :
    if varrubl-base = 1 then return bf_ot-full.slt-rubl.
                        else return bf_ot-full.slt-base.
END FUNCTION.
FUNCTION func-slt-doc RETURNS DECIMAL
      ( buffer bf_ot-full for ot-full ) :
    if varrubl-base = 1 then return bf_ot-full.slt-rubl-doc.
                        else return bf_ot-full.slt-base-doc.
END FUNCTION.
FUNCTION func-sum RETURNS DECIMAL
    ( buffer bf_ot-full for ot-full ) :
    if varrubl-base = 1 then return bf_ot-full.sum-rubl.
                        else return bf_ot-full.sum-base.
END FUNCTION.
FUNCTION func-sum-doc RETURNS DECIMAL
    ( buffer bf_ot-full for ot-full ) :
    if varrubl-base = 1 then return bf_ot-full.sum-rubl-doc.
                        else return bf_ot-full.sum-base-doc.
END FUNCTION.
FUNCTION func-sum-sale RETURNS DECIMAL
     ( buffer bf_ot-full for ot-full ) :
    if varrubl-base = 1 then return bf_ot-full.sum-rubl-sale.
                        else return bf_ot-full.sum-base-sale.
END FUNCTION.
FUNCTION func-transport RETURNS DECIMAL
      ( buffer bf_ot-full for ot-full ) :
    if varrubl-base = 1 then return bf_ot-full.transport-rubl.
                        else return bf_ot-full.transport-base.
END FUNCTION.
FUNCTION func-transport-doc RETURNS DECIMAL
      ( buffer bf_ot-full for ot-full ) :
    if varrubl-base = 1 then return bf_ot-full.transport-rubl-doc.
                        else return bf_ot-full.transport-base-doc.
END FUNCTION.
FUNCTION func-VAT RETURNS DECIMAL
      ( buffer bf_ot-full for ot-full ) :
    if varrubl-base = 1 then return bf_ot-full.vat-rubl.
                        else return bf_ot-full.vat-base.
END FUNCTION.
FUNCTION func-VAT-doc RETURNS DECIMAL
     ( buffer bf_ot-full for ot-full ) :
    if varrubl-base = 1 then return bf_ot-full.vat-rubl-doc.
                        else return bf_ot-full.vat-base-doc.
END FUNCTION.
