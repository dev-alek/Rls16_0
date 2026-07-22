define parameter buffer bf_goods      for ub.goods.
define input parameter paranother-gds-code like ub.goods.gds-code no-undo.
define input  parameter pardoc-code  as character no-undo.
define input  parameter parobj-type  as character no-undo.
define input  parameter parobj-code  as integer   no-undo.
define input  parameter parwrite-off as logical   no-undo.
define input  parameter parmode      as character no-undo.
define output parameter parstate     as logical initial no no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Обработка топливных товаров в документе пересортица".
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable ptrlprop-denstclc      as character no-undo initial 'shft_rvs-inc':U .
define variable ptrlprop-inpptrl       as character no-undo initial 'weight':U .
define variable ptrlprop-expptrl       as character no-undo initial 'volume':U .
define variable ptrlprop-autopump      as logical   no-undo initial false .
define variable ptrlprop-avtinvpm      as logical   no-undo initial false .
define variable ptrlprop-rvsnmter      as logical   no-undo initial false .
define variable ptrlprop-olddens       as logical   no-undo initial false .
define variable ptrlprop-invclipt      as integer   no-undo initial ? .
define variable ptrlprop-algrvspt      as integer   no-undo initial 1 .
define variable ptrlprop-temp-for-pomi as integer   no-undo initial 1 .
define variable ptrlprop-algoincome as integer no-undo init 0.
define variable ptrlprop-mand-choice-autocar as logical no-undo init false.
define variable ptrlprop-Delta-mass-horiz      as character no-undo .
define variable ptrlprop-Delta-mass-vert       as character no-undo .
define variable ptrlprop-calc-free-vol as logical no-undo init false.
define variable ptrlprop-calc-free-vol-sug as logical no-undo init false.
define variable ptrlprop-trn-reas-sug as logical no-undo init true.
define variable ptrlprop-rvd-own-nb as logical no-undo init false.
define variable ptrlprop-qr-scan-time as integer no-undo init 5000 .
define variable ptrlprop-block-nozzle as logical no-undo init false.
define variable ptrlprop-timeout-block-nozzle as integer no-undo init 5 .
define variable ptrlprop-autopump-skip-time as integer no-undo init 0 .
procedure get-ptrl-prop :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  do
  on error  undo, return error substitute( "&1 (get-ptrl-prop). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (get-ptrl-prop). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (get-ptrl-prop). endkey", vss-workfile )
  :
    define variable par-type          as character no-undo.
    define variable v-value-character as character no-undo .
    define variable v-value-date      as date      no-undo .
    define variable v-value-decimal   as decimal   no-undo .
    define variable v-value-integer   as integer   no-undo .
    define variable v-value-logical   as logical   no-undo .
    for each thbjattr_thbj-attr
    :
      delete thbjattr_thbj-attr .
    end.
    run adm/shattri.p
      ( input "get":U
      , input p-obj-type
      , input p-obj-code
      , input 'petrol':U
      , input  ""
      , output v-value-character
      , output v-value-date
      , output v-value-decimal
      , output v-value-integer
      , output v-value-logical
      , output par-type
      , input-output table thbjattr_thbj-attr
      ) no-error .
    for each thbjattr_thbj-attr
    on error undo, return error return-value
    :
      case thbjattr_thbj-attr.prop-code :
        when 'denstclc':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'character':U then do:
            assign
              ptrlprop-denstclc = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'expptrl':U then do:
          if lookup( thbjattr_thbj-attr.property-value-character, 'volume,weight,volume+,weight+':U ) > 0
            and thbjattr_thbj-attr.prop-value-type = 'character':U
          then do:
            assign
              ptrlprop-expptrl = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'inpptrl':U then do:
          if lookup( thbjattr_thbj-attr.property-value-character, 'volume,weight,volume+,weight+':U ) > 0
            and thbjattr_thbj-attr.prop-value-type = 'character':U
          then do:
            assign
              ptrlprop-inpptrl = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'autopump':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-autopump = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'rvsnmter':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-rvsnmter = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'avtinvpm':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-avtinvpm = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'invclipt':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-invclipt = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'olddens':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-olddens = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'algrvspt':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-algrvspt = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'temp-for-pomi':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-temp-for-pomi = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'algoincome':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-algoincome = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'mand-choice-autocar':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-mand-choice-autocar = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'block-nozzle':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-block-nozzle = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'timeout-block-nozzle':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-timeout-block-nozzle = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'Delta-mass-horiz':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'character':U then do:
            assign
              ptrlprop-Delta-mass-horiz = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'Delta-mass-vert':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'character':U then do:
            assign
              ptrlprop-Delta-mass-vert = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'calc-free-vol':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-calc-free-vol = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'calc-free-vol-sug':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-calc-free-vol-sug = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'trn-reas-sug':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-trn-reas-sug = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
              when 'rvd-own-nb':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-rvd-own-nb = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'qr-scan-time':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-qr-scan-time = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'autopump-skip-time':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-autopump-skip-time = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
      end case.
      delete thbjattr_thbj-attr .
    end.
  end.
  return .
end procedure.
DEFINE SHARED TEMP-TABLE tt-place NO-UNDO
    FIELD pl-code             LIKE ub.place.pl-code
    FIELD loc1                LIKE ub.place.loc1
    FIELD pl-name             LIKE ub.place.pl-name
    FIELD before-l            AS   DECIMAL FORMAT "->,>>>,>>>,>>9.9999"
    FIELD before-kg           AS   DECIMAL FORMAT "->,>>>,>>>,>>9.9999"
    FIELD write-off-l         AS   DECIMAL FORMAT "->,>>>,>>>,>>9.9999"
    FIELD income-l            AS   DECIMAL FORMAT "->,>>>,>>>,>>9.9999"
    FIELD write-off-kg        AS   DECIMAL FORMAT "->,>>>,>>>,>>9.9999"
    FIELD income-kg           AS   DECIMAL FORMAT "->,>>>,>>>,>>9.9999"
    FIELD write-off-doc-l     AS   DECIMAL FORMAT "->,>>>,>>>,>>9.9999"
    FIELD income-doc-l        AS   DECIMAL FORMAT "->,>>>,>>>,>>9.9999"
    FIELD write-off-doc-kg    AS   DECIMAL FORMAT "->,>>>,>>>,>>9.9999"
    FIELD income-doc-kg       AS   DECIMAL FORMAT "->,>>>,>>>,>>9.9999"
    INDEX pi IS UNIQUE PRIMARY pl-code.
DEFINE BUFFER bf_gds-obj  FOR ub.gds-obj.
DEFINE BUFFER bf_doc-line FOR ub.doc-line.
DEFINE BUFFER bf_inv-line FOR ub.inv-line.
DEFINE BUFFER bf_clients  FOR ub.clients.
DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.
DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-save AUTO-GO
     LABEL "&Сохранить"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE varafter-l AS DECIMAL FORMAT "->,>>>,>>>,>>9.9999":U INITIAL 0
     LABEL "Остаток (л)"
     VIEW-AS FILL-IN
     SIZE 13 BY 1 NO-UNDO.
DEFINE VARIABLE varbefore-l AS DECIMAL FORMAT "->,>>>,>>>,>>9.9999":U INITIAL 0
     LABEL "Факт(л)"
     VIEW-AS FILL-IN
     SIZE 13 BY 1 NO-UNDO.
DEFINE VARIABLE varwork-kg AS DECIMAL FORMAT "->,>>>,>>>,>>9.9999":U INITIAL 0
     LABEL "По документу(кг)"
     VIEW-AS FILL-IN
     SIZE 13 BY 1 NO-UNDO.
DEFINE VARIABLE varwork-l AS DECIMAL FORMAT "->,>>>,>>>,>>9.9999":U INITIAL 0
     LABEL "По документу(л)"
     VIEW-AS FILL-IN
     SIZE 13 BY 1 NO-UNDO.
DEFINE QUERY b-place FOR
      tt-place SCROLLING.
DEFINE BROWSE b-place
  QUERY b-place DISPLAY
      pl-code             COLUMN-LABEL "Бар-код рез." FORMAT "99999999999":U
loc1                COLUMN-LABEL "Код"
pl-name             COLUMN-LABEL "Название"
before-l            COLUMN-LABEL "Факт(л)"
write-off-l         COLUMN-LABEL "Списано(л)"
income-l            COLUMN-LABEL "Оприходовано(л)"
write-off-kg        COLUMN-LABEL "Списано(кг)"
income-kg           COLUMN-LABEL "Оприходовано(кг)"
write-off-doc-l     COLUMN-LABEL "Списано в док(л)"
income-doc-l        COLUMN-LABEL "Оприходовано в док(л)"
write-off-doc-kg    COLUMN-LABEL "Списано в док(кг)"
income-doc-kg       COLUMN-LABEL "Оприходовано в док(кг)"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 94.25 BY 15.75 EXPANDABLE.
DEFINE FRAME frame-place
     b-save AT ROW 1 COL 1
     b-cancel AT ROW 1 COL 11
     b-chg AT ROW 1 COL 21
     b-help AT ROW 1 COL 86
     varbefore-l AT ROW 2.5 COL 8 COLON-ALIGNED
     varafter-l AT ROW 2.5 COL 56 COLON-ALIGNED
     varwork-l AT ROW 3.75 COL 20.5 COLON-ALIGNED
     varwork-kg AT ROW 3.75 COL 69 COLON-ALIGNED
     b-place AT ROW 5 COL 1.5
     SPACE(0.25) SKIP(0.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "<insert dialog title>"
         DEFAULT-BUTTON b-save CANCEL-BUTTON b-cancel.
ASSIGN
       FRAME frame-place:SCROLLABLE       = FALSE
       FRAME frame-place:HIDDEN           = TRUE.
ON GO OF FRAME frame-place
DO:
  ASSIGN
    parstate = YES.
END.
ON return OF FRAME frame-place
DO:
  RETURN NO-APPLY.
END.
ON WINDOW-CLOSE OF FRAME frame-place
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-chg IN FRAME frame-place
DO:
  define variable varstate       as logical no-undo.
  define variable varqnty-l      as decimal no-undo.
  define variable varqnty-kg     as decimal no-undo.
  define variable varqnty-l-mem  as decimal no-undo.
  define variable varqnty-kg-mem as decimal no-undo.
  define buffer bf_place for ub.place.
  if available tt-place then do:
    if parwrite-off = yes then do:
      assign
        varqnty-l-mem  = tt-place.write-off-l
        varqnty-kg-mem = tt-place.write-off-kg .
    end.
    else do:
      assign
        varqnty-l-mem  = tt-place.income-l
        varqnty-kg-mem = tt-place.income-kg .
    end.
    find first bf_place where bf_place.obj-type = parobj-type      and
                              bf_place.obj-code = parobj-code      and
                              bf_place.pl-code  = tt-place.pl-code no-lock.
    run str/prstptru.w (buffer bf_goods,
                    buffer bf_place,
                    input  (if ptrlprop-expptrl = 'volume':U then yes else no),
                    input  'ИЗМЕНЕНИЕ':U,
                    input  (if parwrite-off = yes then yes else no),
                    input  tt-place.before-l,
                    input  tt-place.before-kg,
                    input  (if parwrite-off = yes then tt-place.write-off-l  else tt-place.income-l),
                    input  (if parwrite-off = yes then tt-place.write-off-kg else tt-place.income-kg),
                    input  tt-place.write-off-doc-l,
                    input  tt-place.write-off-doc-kg,
                    input  tt-place.income-doc-l,
                    input  tt-place.income-doc-kg,
                    output varstate,
                    output varqnty-l,
                    output varqnty-kg) no-error.
    if not error-status:error and
       varstate = yes         then do:
      if parwrite-off = yes then do:
        assign
          tt-place.write-off-l  = varqnty-l
          tt-place.write-off-kg = varqnty-kg
          tt-place.write-off-doc-l  = tt-place.write-off-doc-l  - varqnty-l-mem + varqnty-l
          tt-place.write-off-doc-kg = tt-place.write-off-doc-kg - varqnty-kg-mem + varqnty-kg
        .
      end.
      else do:
        assign
          tt-place.income-l  = varqnty-l
          tt-place.income-kg = varqnty-kg
          tt-place.income-doc-l  = tt-place.income-doc-l  - varqnty-l-mem + varqnty-l
          tt-place.income-doc-kg = tt-place.income-doc-kg - varqnty-kg-mem + varqnty-kg
        .
      end.
      display tt-place.write-off-l tt-place.write-off-kg tt-place.write-off-doc-l tt-place.write-off-doc-kg tt-place.income-l tt-place.income-kg tt-place.income-doc-l tt-place.income-doc-kg
      with browse b-place.
      run disp-free-qnty in this-procedure.
    end.
  end.
END.
ON return OF b-place IN FRAME frame-place
DO:
  RETURN NO-APPLY.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME frame-place:PARENT eq ?
THEN FRAME frame-place:PARENT = ACTIVE-WINDOW.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame frame-place
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
on choose of b-help in frame frame-place
do:
  apply "help":u to frame frame-place .
end.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame frame-place:width - 0.3
                fh            = frame frame-place:first-child
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame frame-place :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame frame-place :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame frame-place :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame frame-place :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame frame-place :height = v-frame-height
          .
          if frame frame-place :scrollable = true
          then do:
            assign
              frame frame-place :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame frame-place :scrollable = true
          then do:
            assign
              frame frame-place :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame frame-place :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame frame-place :height
      v-frame-virtual-height = frame frame-place :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame frame-place :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame frame-place
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame frame-place :scrollable = true
      then do:
        assign
          frame frame-place :virtual-height = frame frame-place :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame frame-place :height = frame frame-place :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame frame-place :height = frame frame-place :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame frame-place :scrollable = true
      then do:
        assign
          frame frame-place :virtual-height = frame frame-place :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame frame-place :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame frame-place :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame frame-place :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame frame-place :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame frame-place :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame frame-place :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame frame-place :width = v-frame-width
          .
          if frame frame-place :scrollable = true
          then do:
            assign
              frame frame-place :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame frame-place :scrollable = true
          then do:
            assign
              frame frame-place :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame frame-place :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame frame-place :width
      v-frame-virtual-width = frame frame-place :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame frame-place :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame frame-place
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame frame-place :scrollable = true
      then do:
        assign
          frame frame-place :virtual-width = frame frame-place :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame frame-place :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame frame-place :width = frame frame-place :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame frame-place :scrollable = true
      then do:
        assign
          frame frame-place :virtual-width = frame frame-place :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame frame-place :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame frame-place :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame frame-place
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame frame-place :height - v-diasize-resize-button :height
                  - 1
                  - (frame frame-place :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame frame-place :width - v-diasize-resize-button :width
                  - 1
                  - (frame frame-place :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame frame-place
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame frame-place :height
      v-col-delta = v-new-col - frame frame-place :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame frame-place :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame frame-place :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame frame-place :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame frame-place :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame frame-place :width
      v-diasize-current-frame-height = frame frame-place :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame frame-place
    :
      assign
        v-diasize-orig-frame-height = frame frame-place :height
        v-diasize-orig-frame-width  = frame frame-place :width
        v-diasize-browse-handle     = browse b-place :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame frame-place :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
    run diasize_init in this-procedure .
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 ASSIGN
    frame frame-place:TITLE = "Определение количеств в резервуарах для документа пересортица " + pardoc-code + " для товара " + bf_goods.artic + " " + bf_goods.prod-type + " " + string(bf_goods.prod-code) + " " + bf_goods.gds-name.
  FIND FIRST bf_gds-obj WHERE bf_gds-obj.obj-type  = parobj-type  AND
                              bf_gds-obj.obj-code  = parobj-code  AND
                              bf_gds-obj.artic     = bf_goods.artic     AND
                              bf_gds-obj.prod-type = bf_goods.prod-type AND
                              bf_gds-obj.prod-code = bf_goods.prod-code NO-LOCK no-error.
  if available bf_gds-obj then do:
    ASSIGN
      varbefore-l = bf_gds-obj.fact-qnty.
  end.
  DISPLAY varbefore-l WITH FRAME frame-place.
  RUN make-tt-table IN THIS-PROCEDURE.
  RUN disp-free-qnty IN THIS-PROCEDURE.
  FIND FIRST bf_clients WHERE bf_clients.obj-type = parobj-type AND
                              bf_clients.obj-code = parobj-code NO-LOCK.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run get-ptrl-prop in this-procedure
  ( input parobj-type
  , input parobj-code
  ) .
  RUN enable_UI.
  IF parmode = 'ДОБАВЛЕНИЕ':U OR
     parmode = 'ИЗМЕНЕНИЕ':U  THEN DO:
    ENABLE b-save b-chg WITH FRAME frame-place.
  END.
  ASSIGN
    tt-place.pl-name:WIDTH IN BROWSE b-place = 30
    tt-place.pl-name:RESIZABLE IN BROWSE b-place = YES.
  WAIT-FOR GO OF FRAME frame-place.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME frame-place.
END PROCEDURE.
PROCEDURE disp-free-qnty :
DEFINE BUFFER bf_tt-place FOR tt-place.
  ASSIGN
    varwork-l  = 0.00
    varwork-kg = 0.00  .
  FOR EACH bf_tt-place ON ERROR UNDO, RETURN ERROR RETURN-VALUE :
    assign
      varwork-l  = varwork-l  + bf_tt-place.income-doc-l  - bf_tt-place.write-off-doc-l
      varwork-kg = varwork-kg + bf_tt-place.income-doc-kg - bf_tt-place.write-off-doc-kg.
  END.
  ASSIGN
    varafter-l  = varbefore-l  + varwork-l.
  DISPLAY varwork-l varwork-kg varafter-l WITH FRAME frame-place.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY varbefore-l varafter-l varwork-l varwork-kg
      WITH FRAME frame-place.
  ENABLE b-cancel b-help b-place
      WITH FRAME frame-place.
  VIEW FRAME frame-place.
  OPEN QUERY b-place FOR EACH tt-place.
END PROCEDURE.
PROCEDURE make-tt-table :
DEFINE BUFFER bf_pl-gds     FOR ub.pl-gds.
DEFINE BUFFER bf_place      FOR ub.place.
DEFINE BUFFER bf_parts      FOR ub.parts.
define buffer bf-another_parts for ub.parts.
define buffer bf_parts-root for ub.parts-root.
define buffer bf-another_goods for ub.goods.
define buffer bf_doc-pl        for ub.doc-pl.
DEFINE VARIABLE varwrite-off-doc-l  AS DECIMAL NO-UNDO.
DEFINE VARIABLE varincome-doc-l     AS DECIMAL NO-UNDO.
DEFINE VARIABLE varwrite-off-doc-kg AS DECIMAL NO-UNDO.
DEFINE VARIABLE varincome-doc-kg    AS DECIMAL NO-UNDO.
DEFINE VARIABLE varwrite-off-l      AS DECIMAL NO-UNDO.
DEFINE VARIABLE varincome-l         AS DECIMAL NO-UNDO.
DEFINE VARIABLE varwrite-off-kg     AS DECIMAL NO-UNDO.
DEFINE VARIABLE varincome-kg        AS DECIMAL NO-UNDO.
FOR EACH tt-place ON ERROR UNDO, RETURN ERROR RETURN-VALUE :
  DELETE tt-place.
END.
FOR EACH bf_pl-gds WHERE bf_pl-gds.gds-code = bf_goods.gds-code AND
                         bf_pl-gds.obj-type = parobj-type       AND
                         bf_pl-gds.obj-code = parobj-code       NO-LOCK ON ERROR UNDO, RETURN ERROR RETURN-VALUE :
  FIND FIRST bf_place WHERE bf_place.obj-type = bf_pl-gds.obj-type AND
                            bf_place.obj-code = bf_pl-gds.obj-code AND
                            bf_place.pl-code  = bf_pl-gds.pl-code  NO-LOCK.
  ASSIGN
    varwrite-off-doc-l  = 0.00
    varincome-doc-l     = 0.00
    varwrite-off-doc-kg = 0.00
    varincome-doc-kg    = 0.00
    varwrite-off-l  = 0.00
    varincome-l     = 0.00
    varwrite-off-kg = 0.00
    varincome-kg    = 0.00
    .
  FOR EACH bf_parts WHERE bf_parts.out-code  = pardoc-code        AND
                          bf_parts.obj-type  = parobj-type        AND
                          bf_parts.obj-code  = parobj-code        AND
                          bf_parts.artic     = bf_goods.artic     AND
                          bf_parts.prod-type = bf_goods.prod-type AND
                          bf_parts.prod-code = bf_goods.prod-code AND
                          bf_parts.pl-code   = bf_pl-gds.pl-code  ON ERROR UNDO, RETURN ERROR RETURN-VALUE :
    find first bf_doc-pl where bf_doc-pl.obj-type = bf_parts.obj-type and
                               bf_doc-pl.obj-code = bf_parts.obj-code and
                               bf_doc-pl.pl-code  = bf_parts.pl-code  and
                               bf_doc-pl.out-code = bf_parts.out-code and
                               bf_doc-pl.gds-code = bf_goods.gds-code no-lock.
    IF bf_parts.fact-qnty < 0 THEN DO:
      ASSIGN
        varwrite-off-doc-l  = varwrite-off-doc-l  - bf_parts.fact-qnty
        varwrite-off-doc-kg = varwrite-off-doc-kg - (bf_doc-pl.cli-fact-qnty / bf_doc-pl.fact-qnty) * bf_parts.fact-qnty.
    END.
    ELSE DO:
      ASSIGN
        varincome-doc-l  = varincome-doc-l  + bf_parts.fact-qnty
        varincome-doc-kg = varincome-doc-kg + (bf_doc-pl.cli-fact-qnty / bf_doc-pl.fact-qnty) * bf_parts.fact-qnty.
    END.
    if parmode <> 'ДОБАВЛЕНИЕ':U then do:
      find first bf-another_goods where bf-another_goods.gds-code = paranother-gds-code no-lock.
      if parwrite-off then do:
        find first bf_parts-root where bf_parts-root.doc-code       = bf_parts.out-code         and
                                       bf_parts-root.orig-in-code   = bf_parts.in-code          and
                                       bf_parts-root.orig-gds-code  = bf_goods.gds-code         and
                                       bf_parts-root.orig-part-code = bf_parts.part-code        and
                                       bf_parts-root.gds-code       = bf-another_goods.gds-code no-lock no-error.
        if available bf_parts-root then do:
          find first bf-another_parts where bf-another_parts.obj-type   = bf_parts.obj-type          and
                                            bf-another_parts.obj-code   = bf_parts.obj-code          and
                                            bf-another_parts.artic      = bf-another_goods.artic     and
                                            bf-another_parts.prod-type  = bf-another_goods.prod-type and
                                            bf-another_parts.prod-code  = bf-another_goods.prod-code and
                                            bf-another_parts.in-code    = bf_parts-root.in-code      and
                                            bf-another_parts.out-code   = bf_parts.out-code          and
                                            bf-another_parts.part-code  = bf_parts-root.part-code    no-lock.
             ASSIGN
               varwrite-off-l  = varwrite-off-l  + bf-another_parts.real-qnty
               varwrite-off-kg = varwrite-off-kg + (bf_doc-pl.cli-fact-qnty / bf_doc-pl.fact-qnty) * bf-another_parts.real-qnty.
        end.
      end.
      else do:
        find first bf_parts-root where bf_parts-root.doc-code      = bf_parts.out-code         and
                                       bf_parts-root.orig-gds-code = bf-another_goods.gds-code and
                                       bf_parts-root.in-code       = bf_parts.in-code          and
                                       bf_parts-root.gds-code      = bf_goods.gds-code         and
                                       bf_parts-root.part-code     = bf_parts.part-code        no-lock no-error.
        if available bf_parts-root then do:
          find first bf-another_parts where bf-another_parts.obj-type   = bf_parts.obj-type            and
                                            bf-another_parts.obj-code   = bf_parts.obj-code            and
                                            bf-another_parts.artic      = bf-another_goods.artic       and
                                            bf-another_parts.prod-type  = bf-another_goods.prod-type   and
                                            bf-another_parts.prod-code  = bf-another_goods.prod-code   and
                                            bf-another_parts.in-code    = bf_parts-root.orig-in-code   and
                                            bf-another_parts.out-code   = bf_parts.out-code            and
                                            bf-another_parts.part-code  = bf_parts-root.orig-part-code no-lock.
          ASSIGN
            varincome-l  = varincome-l  + bf-another_parts.real-qnty
            varincome-kg = varincome-kg + (bf_doc-pl.cli-fact-qnty / bf_doc-pl.fact-qnty) * bf-another_parts.real-qnty.
        end.
      end.
    end.
  END.
  CREATE tt-place.
  ASSIGN
    tt-place.pl-code          = bf_place.pl-code
    tt-place.loc1             = bf_place.loc1
    tt-place.pl-name          = bf_place.pl-name
    tt-place.before-l         = bf_pl-gds.fact-qnty
    tt-place.before-kg        = bf_pl-gds.cli-fact-qnty
    tt-place.write-off-l      = (if parmode = 'ДОБАВЛЕНИЕ':U then 0 else varwrite-off-l)
    tt-place.income-l         = (if parmode = 'ДОБАВЛЕНИЕ':U then 0 else varincome-l)
    tt-place.write-off-kg     = (if parmode = 'ДОБАВЛЕНИЕ':U then 0 else varwrite-off-kg)
    tt-place.income-kg        = (if parmode = 'ДОБАВЛЕНИЕ':U then 0 else varincome-kg   )
    tt-place.write-off-doc-l  = varwrite-off-doc-l
    tt-place.income-doc-l     = varincome-doc-l
    tt-place.write-off-doc-kg = varwrite-off-doc-kg
    tt-place.income-doc-kg    = varincome-doc-kg
  .
END.
END PROCEDURE.
