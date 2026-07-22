define input         parameter parparentproc as handle no-undo .
define input-output  parameter gds-name   as character no-undo .
define input-output  parameter unit-base  as character no-undo .
define input-output  parameter fact-qnty  as decimal   no-undo .
define input-output  parameter price-rubl as decimal   no-undo .
define input-output  parameter sum-rubl   as decimal   no-undo .
define input-output  parameter excise     as decimal   no-undo .
define input-output  parameter VAT-pc     as decimal   no-undo .
define input-output  parameter VAT-rubl   as decimal   no-undo .
define input-output  parameter sum-rubl-VAT as decimal   no-undo .
define input-output  parameter country    as character no-undo .
define input-output  parameter gtd        as character no-undo .
define input-output  parameter res        as logical   no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Изменение строки счета-фактуры".
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
DEFINE BUTTON b-calc
     LABEL "&Расчет":L
     SIZE 10 BY 1 TOOLTIP "Пересчитать суммы по цене , количеству и НДС".
DEFINE BUTTON b-exit AUTO-END-KEY
     LABEL "&Отмена":L
     SIZE 10 BY 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-OK AUTO-GO
     LABEL "&Ввод ":L
     SIZE 10 BY 1.
DEFINE BUTTON r-contry
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.
DEFINE BUTTON r-units
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-units"
     SIZE 3 BY .88.
DEFINE VARIABLE FILL-IN_country AS CHARACTER FORMAT "X(25)"
     LABEL "Страна"
     VIEW-AS FILL-IN
     SIZE 22.5 BY 1.
DEFINE VARIABLE FILL-IN_excise AS DECIMAL FORMAT "->,>>>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Акциз"
     VIEW-AS FILL-IN
     SIZE 16 BY 1.
DEFINE VARIABLE FILL-IN_fact-qnty AS DECIMAL FORMAT ">>,>>>,>>9.<<<" INITIAL 0
     LABEL "Кол-во"
     VIEW-AS FILL-IN
     SIZE 23.5 BY 1.
DEFINE VARIABLE FILL-IN_gds-name AS CHARACTER FORMAT "X(48)"
     LABEL "Название"
     VIEW-AS FILL-IN
     SIZE 50 BY 1.
DEFINE VARIABLE FILL-IN_gtd AS CHARACTER FORMAT "X(25)"
     LABEL "ГТД"
     VIEW-AS FILL-IN
     SIZE 22.5 BY 1.
DEFINE VARIABLE FILL-IN_price-rubl AS DECIMAL FORMAT ">,>>>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Цена"
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1
     FGCOLOR 4 .
DEFINE VARIABLE FILL-IN_sum-rubl AS DECIMAL FORMAT "->,>>>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Сумма"
     VIEW-AS FILL-IN
     SIZE 21.5 BY 1
     FGCOLOR 4 .
DEFINE VARIABLE FILL-IN_sum-rubl-VAT AS DECIMAL FORMAT ">,>>>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Сумма с налогами"
     VIEW-AS FILL-IN
     SIZE 41.38 BY 1.
DEFINE VARIABLE FILL-IN_unit-base AS CHARACTER FORMAT "X(3)"
     LABEL "Ед.изм."
     VIEW-AS FILL-IN
     SIZE 5.13 BY 1.
DEFINE VARIABLE FILL-IN_VAT-pc AS DECIMAL FORMAT ">9.9<%" INITIAL 0
     LABEL "НДС"
     VIEW-AS FILL-IN
     SIZE 6 BY 1.
DEFINE VARIABLE FILL-IN_VAT-rubl AS DECIMAL FORMAT "->,>>>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Сумма НДС"
     VIEW-AS FILL-IN
     SIZE 16 BY 1.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 69 BY 1.75.
DEFINE QUERY Dialog-Frame FOR
      ub.schet-fact-line SCROLLING.
DEFINE FRAME Dialog-Frame
     b-OK AT ROW 1 COL 1
     b-exit AT ROW 1 COL 11
     b-calc AT ROW 1 COL 21
     B-Help AT ROW 1 COL 60.5
     FILL-IN_gds-name AT ROW 2.08 COL 2
     FILL-IN_unit-base AT ROW 3.21 COL 54.88 COLON-ALIGNED
     FILL-IN_fact-qnty AT ROW 3.25 COL 10 COLON-ALIGNED
     r-units AT ROW 3.25 COL 62.5 WIDGET-ID 4
     FILL-IN_price-rubl AT ROW 5.38 COL 18.5 COLON-ALIGNED
     FILL-IN_sum-rubl AT ROW 5.38 COL 42.5 COLON-ALIGNED
     FILL-IN_VAT-pc AT ROW 6.75 COL 18.5 COLON-ALIGNED
     FILL-IN_VAT-rubl AT ROW 8 COL 18.5 COLON-ALIGNED
     FILL-IN_excise AT ROW 9.5 COL 18.5 COLON-ALIGNED
     FILL-IN_sum-rubl-VAT AT ROW 10.75 COL 2.5
     FILL-IN_country AT ROW 12 COL 18.5 COLON-ALIGNED
     r-contry AT ROW 12 COL 43.5 WIDGET-ID 6
     FILL-IN_gtd AT ROW 13.17 COL 18.5 COLON-ALIGNED
     " Без НДС" VIEW-AS TEXT
          SIZE 9 BY 1 AT ROW 4.75 COL 2.5
          FGCOLOR 4
     RECT-1 AT ROW 5 COL 1 WIDGET-ID 2
     SPACE(0.62) SKIP(8.91)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Строка счета-фактуры".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-calc IN FRAME Dialog-Frame
DO:
  assign FILL-IN_fact-qnty FILL-IN_price-rubl  FILL-IN_sum-rubl FILL-IN_excise  FILL-IN_VAT-pc  FILL-IN_VAT-rubl FILL-IN_sum-rubl-VAT .
  IF FILL-IN_fact-qnty = 0 then do:
    message  "Кол-во 0 - расчет невозможен!"  view-as alert-box.
    return.
  end.
  IF FILL-IN_price-rubl = 0 and FILL-IN_sum-rubl-VAT = 0 then do:
    message  "Цена без НДС 0 и общая сумма 0 - оба варианта расчета невозможны расчет невозможен!"  view-as alert-box.
    return.
  end.
  if FILL-IN_price-rubl > 0 then do:
    assign
      FILL-IN_sum-rubl = FILL-IN_price-rubl * FILL-IN_fact-qnty
      FILL-IN_VAT-rubl = FILL-IN_sum-rubl * FILL-IN_VAT-pc / 100
      FILL-IN_sum-rubl-VAT = FILL-IN_sum-rubl + FILL-IN_VAT-rubl
    .
  end.
  else do:
    assign
      FILL-IN_VAT-rubl = FILL-IN_sum-rubl-VAT * FILL-IN_VAT-pc / ( 100 + FILL-IN_VAT-pc )
      FILL-IN_sum-rubl = FILL-IN_sum-rubl-VAT - FILL-IN_VAT-rubl
      FILL-IN_price-rubl = FILL-IN_sum-rubl / FILL-IN_fact-qnty
    .
  end.
  DISPLAY FILL-IN_price-rubl FILL-IN_sum-rubl  FILL-IN_VAT-rubl FILL-IN_sum-rubl-VAT   WITH FRAME Dialog-Frame.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
END.
ON CHOOSE OF b-OK IN FRAME Dialog-Frame
DO:
  assign FILL-IN_gds-name   FILL-IN_unit-base  FILL-IN_fact-qnty  FILL-IN_price-rubl    FILL-IN_sum-rubl
         FILL-IN_excise     FILL-IN_VAT-pc     FILL-IN_VAT-rubl   FILL-IN_sum-rubl-VAT  FILL-IN_country   FILL-IN_gtd .
  if FILL-IN_gds-name = "" then do:
     message "Не заполнено наименование!" view-as alert-box.
     return no-apply.
  end.
  IF FILL-IN_fact-qnty = 0 then do:
    message  "Кол-во 0!"  view-as alert-box.
    return no-apply.
  end.
  IF FILL-IN_price-rubl = 0 and FILL-IN_sum-rubl-VAT = 0 then do:
    message  "Цена без НДС 0 и/или общая сумма 0!"  view-as alert-box.
    return no-apply.
  end.
  assign
    gds-name     = FILL-IN_gds-name
    unit-base    = FILL-IN_unit-base
    fact-qnty    = FILL-IN_fact-qnty
    price-rubl   = FILL-IN_price-rubl
    sum-rubl     = FILL-IN_sum-rubl
    excise       = FILL-IN_excise
    VAT-pc       = FILL-IN_VAT-pc
    VAT-rubl     = FILL-IN_VAT-rubl
    sum-rubl-VAT = FILL-IN_sum-rubl-VAT
    country      = FILL-IN_country
    gtd          = FILL-IN_gtd
    res          = yes
  .
END.
ON CHOOSE OF r-contry IN FRAME Dialog-Frame
DO:
define variable varrid-list as character no-undo.
define variable varrecid    as recid     no-undo.
define buffer bf_country for ub.country.
run ref/countris.w
    (  input parparentproc
      , input "b-sel"
      , input-output varrid-list ) no-error.
  if error-status :error then do:
     message vss-workfile vss-revision vss-description skip
             error-status :get-message( 1 )
     view-as alert-box.
     return no-apply .
     end.
if varrid-list = '' then return no-apply.
assign
  varrecid = integer(entry(1, varrid-list)).
find first bf_country no-lock where recid(bf_country) = varrecid no-error.
if available bf_country then do:
  assign
      FILL-IN_country   = bf_country.short-name
      .
  display
     FILL-IN_country
     with frame Dialog-Frame.
end.
END.
ON CHOOSE OF r-units IN FRAME Dialog-Frame
DO:
define buffer bf-r-units for ub.units.
define variable ref-rec as recid no-undo.
run ref/units.w (input parparentproc, input yes, output ref-rec).
if ref-rec = ? then return no-apply.
find bf-r-units where recid (bf-r-units) = ref-rec no-lock.
assign FILL-IN_unit-base  = bf-r-units.unit-name.
release bf-r-units.
display FILL-IN_unit-base with frame Dialog-Frame.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  assign
    FILL-IN_gds-name     = gds-name
    FILL-IN_unit-base    = unit-base
    FILL-IN_fact-qnty    = fact-qnty
    FILL-IN_price-rubl   = price-rubl
    FILL-IN_sum-rubl     = sum-rubl
    FILL-IN_excise       = excise
    FILL-IN_VAT-pc       = VAT-pc
    FILL-IN_VAT-rubl     = VAT-rubl
    FILL-IN_sum-rubl-VAT = sum-rubl-VAT
    FILL-IN_country      = country
    FILL-IN_gtd          = gtd
  .
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH ub.schet-fact-line SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY FILL-IN_gds-name FILL-IN_unit-base FILL-IN_fact-qnty
          FILL-IN_price-rubl FILL-IN_sum-rubl FILL-IN_VAT-pc FILL-IN_VAT-rubl
          FILL-IN_excise FILL-IN_sum-rubl-VAT FILL-IN_country FILL-IN_gtd
      WITH FRAME Dialog-Frame.
  ENABLE b-OK RECT-1 b-exit b-calc B-Help FILL-IN_gds-name FILL-IN_unit-base
         FILL-IN_fact-qnty r-units FILL-IN_price-rubl FILL-IN_sum-rubl
         FILL-IN_VAT-pc FILL-IN_VAT-rubl FILL-IN_excise FILL-IN_sum-rubl-VAT
         FILL-IN_country r-contry FILL-IN_gtd
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
