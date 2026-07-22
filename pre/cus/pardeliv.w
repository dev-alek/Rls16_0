define input  parameter       parParentproc          as handle no-undo .
define input  parameter       p-mode                 as character no-undo .
define input  parameter       p-type-doc             as character no-undo .
define input  parameter       p-curr-obj-type        as character no-undo .
define input  parameter       p-curr-obj-code        as integer   no-undo .
define input  parameter       p-cli-type             as character no-undo .
define input  parameter       p-cli-code             as integer   no-undo .
define input-output parameter p-deliv-type-code      as integer   no-undo .
define input-output parameter p-point-obj-code       as integer   no-undo .
define input-output parameter p-point-obj-db-num     as integer   no-undo .
define input-output parameter p-point-cli-code       as integer   no-undo .
define input-output parameter p-point-cli-db-num     as integer   no-undo .
define input-output parameter p-transport-host-code       as integer   no-undo .
define input-output parameter p-transport-cli-type       as character no-undo .
define input-output parameter p-transport-cli-code       as integer   no-undo .
define input-output parameter p-transport-contract   as integer   no-undo .
define input-output parameter p-transport-condition  as integer   no-undo .
define input-output parameter p-transport-value      as decimal   no-undo .
define input-output parameter p-transport-sum        as decimal   no-undo .
define input-output parameter p-transport-vat        as decimal   no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Параметры доставки".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
define buffer cargo_clients  for ub.clients  .
define buffer cargo_contract for ub.contract .
define buffer buf_delivery-type for ub.delivery-type  .
define variable curr-host-code as integer   no-undo .
define buffer buf_place-io for ub.place-io  .
define buffer buf_point-io for ub.point-io  .
DEFINE BUTTON B-Cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-contract
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U NO-CONVERT-3D-COLORS
     LABEL ""
     SIZE 3 BY .79 TOOLTIP "Посмотреть договор".
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-save AUTO-GO
     LABEL "Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON r-deliv
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.
DEFINE BUTTON r-point-1
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.
DEFINE BUTTON r-point-2
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.
DEFINE BUTTON r-wrkr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.
DEFINE BUTTON r-wrkr-2
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE VARIABLE scr-trasport-condition AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 1
     LABEL "Условия транспортных услуг"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Неопеределены",0
     DROP-DOWN-LIST
     SIZE 65.13 BY 1 NO-UNDO.
DEFINE VARIABLE scr-deliv-type-code AS INTEGER FORMAT ">>>>>>>":U INITIAL 0
     LABEL "Способ доставки"
      VIEW-AS TEXT
     SIZE 7 BY .67 NO-UNDO.
DEFINE VARIABLE scr-deliv-type-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 60.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE scr-point-cli-code AS INTEGER FORMAT ">>>>>>>":U INITIAL 0
     LABEL "Пункт  приемки"
      VIEW-AS TEXT
     SIZE 7 BY .67 NO-UNDO.
DEFINE VARIABLE scr-point-cli-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 60.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE scr-point-obj-code AS INTEGER FORMAT ">>>>>>>":U INITIAL 0
     LABEL "Пункт отгрузки"
      VIEW-AS TEXT
     SIZE 7 BY .67 NO-UNDO.
DEFINE VARIABLE scr-point-obj-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 60.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE scr-transport-cli-type AS CHARACTER FORMAT "X(3)":U
      VIEW-AS TEXT
     SIZE 3.63 BY .67 NO-UNDO.
DEFINE VARIABLE scr-transport-contract AS INTEGER FORMAT ">>>>>>>>>":U INITIAL 0
     LABEL "Транспортный договор"
      VIEW-AS TEXT
     SIZE 10.13 BY .79 TOOLTIP "Договор транспортных услуг" NO-UNDO.
DEFINE VARIABLE scr-transport-cli-code AS INTEGER FORMAT ">>>>>>>>>":U INITIAL 0
     LABEL "Грузоперевозчик"
      VIEW-AS TEXT
     SIZE 10.13 BY .67 NO-UNDO.
DEFINE VARIABLE scr-transport-host-name AS CHARACTER FORMAT "X(120)":U
      VIEW-AS TEXT
     SIZE 37.38 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE scr-transport-name AS CHARACTER FORMAT "X(20)":U
      VIEW-AS TEXT
     SIZE 12.88 BY .79
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE scr-transport-sum AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "Сумма транспортных услуг"
     VIEW-AS FILL-IN
     SIZE 21.5 BY 1 NO-UNDO.
DEFINE VARIABLE scr-transport-value AS DECIMAL FORMAT "->>,>>>,>>9.99":U INITIAL 0
     LABEL ""
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE scr-transport-vat-pc AS DECIMAL FORMAT ">>9.99":U INITIAL 0
     LABEL "НДС услуги,%"
     VIEW-AS FILL-IN
     SIZE 6.63 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     B-save AT ROW 1 COL 1
     B-Cancel AT ROW 1 COL 11
     B-Help AT ROW 1 COL 86
     r-deliv AT ROW 2 COL 30.38
     r-point-1 AT ROW 3 COL 30.38
     r-point-2 AT ROW 4 COL 30.38
     r-wrkr AT ROW 6 COL 38
     r-wrkr-2 AT ROW 7 COL 33.63
     B-contract AT ROW 7 COL 50
     scr-trasport-condition AT ROW 8 COL 1.62
     scr-transport-value AT ROW 9 COL 27.63 COLON-ALIGNED
     scr-transport-sum AT ROW 10 COL 27.63 COLON-ALIGNED
     scr-transport-vat-pc AT ROW 11 COL 27.63 COLON-ALIGNED
     scr-deliv-type-code AT ROW 2 COL 20.88 COLON-ALIGNED
     scr-deliv-type-name AT ROW 2 COL 31.63 COLON-ALIGNED NO-LABEL
     scr-point-obj-code AT ROW 3 COL 20.88 COLON-ALIGNED
     scr-point-obj-name AT ROW 3 COL 31.63 COLON-ALIGNED NO-LABEL
     scr-point-cli-code AT ROW 4 COL 20.88 COLON-ALIGNED
     scr-point-cli-name AT ROW 4 COL 31.63 COLON-ALIGNED NO-LABEL
     scr-transport-cli-code AT ROW 6 COL 21 COLON-ALIGNED
     scr-transport-cli-type AT ROW 6 COL 32.38 COLON-ALIGNED NO-LABEL WIDGET-ID 2
     scr-transport-host-name AT ROW 6 COL 39 COLON-ALIGNED NO-LABEL
     scr-transport-contract AT ROW 7 COL 21 COLON-ALIGNED
     scr-transport-name AT ROW 7 COL 34.63 COLON-ALIGNED NO-LABEL
     SPACE(46.98) SKIP(6.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Условия доставки"
         DEFAULT-BUTTON B-save CANCEL-BUTTON B-Cancel.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  RUN save-proc no-error .
  if error-status :error then return no-apply .
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-contract IN FRAME Dialog-Frame
DO:
assign scr-transport-contract .
define buffer b_contract for ub.contract.
find first b_contract no-lock  where b_contract.contract-code     = scr-transport-contract and
                                     b_contract.host-code         = curr-host-code
                                     no-error .
if error-status :error then return no-apply.
run str/sh-contr.p (
    input parParentProc ,
    input recid (b_contract))
    .
END.
ON CHOOSE OF B-Help IN FRAME Dialog-Frame
OR HELP OF FRAME Dialog-Frame
DO:
END.
ON CHOOSE OF r-deliv IN FRAME Dialog-Frame
DO:
define variable v-sts as integer init 0  no-undo .
define variable v-rid-list as character no-undo .
       scr-deliv-type-code = 0 .
       scr-deliv-type-name = "".
run ref/dlvtypes.w
  ( input parParentProc
  , input  p-curr-obj-type
  , input  p-curr-obj-code
  , input  "b-sel":U
  , input  'все':U
  , input-output v-sts
  , input-output v-rid-list )
      no-error .
    find first buf_delivery-type no-lock where recid(buf_delivery-type) = integer(v-rid-list) no-error .
    if available  buf_delivery-type then do:
       scr-deliv-type-code = buf_delivery-type.deliv-type-code.
       scr-deliv-type-name = buf_delivery-type.deliv-type-name.
    end.
    display scr-deliv-type-code
            scr-deliv-type-name
            with frame Dialog-Frame .
END.
ON CHOOSE OF r-point-1 IN FRAME Dialog-Frame
DO:
  scr-point-obj-code = 0.
  scr-point-obj-name = "".
  if p-curr-obj-code = ? then return .
  define variable rid-list as character no-undo .
  case  p-type-doc  :
      when "rcv" + 'ОО':U or
      when "rcv" + 'ФП':U or
      when "ord" + 'ОР':U or
      when "ord" + 'ОО':U or
      when "ord" + 'ПО':U or
      when "ord" + 'ОФ':U or
      when "ord" + 'ОП':U
      then do:
            run ref/place-io.w
              (input  parparentproc
              ,input  'b-sel'
              ,input  p-curr-obj-type
              ,input  p-curr-obj-code
              ,input  'объект':U
              ,input  'all'
              ,input-output rid-list
              ).
            find first buf_place-io no-lock where
                recid (buf_place-io) = integer(rid-list) no-error .
            if available buf_place-io then do:
                scr-point-obj-code  = buf_place-io.place-io-code.
                scr-point-obj-name  = buf_place-io.place-io-name.
            end.
        end.
  end case.
  display scr-point-obj-code
          scr-point-obj-name
  with frame Dialog-Frame .
END.
ON CHOOSE OF r-point-2 IN FRAME Dialog-Frame
DO:
  scr-point-cli-code = 0.
  scr-point-cli-name = "".
  if p-cli-code = ? then return .
  define variable rid-list as character no-undo .
  case  p-type-doc  :
      when "rcv" + 'ОО':U or
      when "ord" + 'ОР':U or
      when "ord" + 'ОО':U then do:
            run ref/place-io.w
              (input  parparentproc
              ,input  'b-sel'
              ,input  p-cli-type
              ,input  p-cli-code
              ,input  'объект':U
              ,input  'all'
              ,input-output rid-list
              ).
            find first buf_place-io no-lock where
                recid (buf_place-io) = integer(rid-list) no-error .
            if available buf_place-io then do:
                scr-point-cli-code = buf_place-io.place-io-code .
                scr-point-cli-name = buf_place-io.place-io-name .
            end.
      end.
      when "ord" + 'ПО':U or
      when "ord" + 'ОФ':U or
      when "ord" + 'ФП':U or
      when "rcv" + 'ФП':U or
      when "ord" + 'ОП':U
      then do:
      run ref/point-io.w
        (input  parparentproc
        ,input  'b-sel'
        ,input  v-cntxt-db-num
        ,input  p-cli-type
        ,input  p-cli-code
        ,input  'объект':U
        ,input  'all'
        ,input-output rid-list
        ).
      find first buf_point-io no-lock where
            recid (buf_point-io) = integer(rid-list) no-error .
      if available buf_point-io then do:
          p-point-cli-db-num  = buf_point-io.db-num.
          scr-point-cli-code  = buf_point-io.point-code.
          scr-point-cli-name  = buf_point-io.point-name.
      end.
  END.
  END CASE.
  display scr-point-cli-code
          scr-point-cli-name
  with frame Dialog-Frame .
END.
ON CHOOSE OF r-wrkr IN FRAME Dialog-Frame
DO:
define variable rid-list as character no-undo.
scr-transport-cli-code   = 0 .
scr-transport-cli-type   = "" .
scr-transport-host-name = "".
  run ref/cli-all.w
      ( input parParentProc,
        input "b-sel",
        input 'орг':U,
        input 'все':U,
        input 'текущие':U,
        input ?,
        input ",,,,,,NO,,":U,
        input "without-obj",
        output rid-list ) .
find first cargo_clients no-lock where
     recid (cargo_clients) = integer(rid-list) no-error .
    if available cargo_clients then do:
        scr-transport-cli-code  = cargo_clients.obj-code .
        scr-transport-cli-type  = cargo_clients.obj-type .
        scr-transport-host-name = cargo_clients.obj-name .
    end.
display scr-transport-cli-code
        scr-transport-host-name
        scr-transport-cli-type
        with frame Dialog-Frame.
END.
ON CHOOSE OF r-wrkr-2 IN FRAME Dialog-Frame
DO:
IF scr-transport-cli-code = 0  THEN DO:
   message "Не выбран грузоперевозчик !"  view-as alert-box information .
   return no-apply .
END.
define variable   rid-list   as character no-undo .
define buffer buf_contract for ub.contract.
ASSIGN scr-transport-cli-code .
scr-transport-contract = 0  .
scr-transport-name     = "" .
run str/cont-all.w (
      input   parParentProc   ,
      input   curr-host-code  ,
      input   "b-sel"         ,
      input   'фирма':U      ,
      input   scr-transport-cli-type ,
      input   scr-transport-cli-code ,
      input   ?               ,
      input   ?               ,
      input   "current"       ,
      input   "all"           ,
      input-output rid-list )
      .
find first buf_contract no-lock where recid (buf_contract) =  integer(rid-list) no-error .
if available buf_contract then do:
  scr-transport-contract = buf_contract.contract-code .
  scr-transport-name     = buf_contract.contract-prn-code.
  end.
DISPLAY scr-transport-contract
        scr-transport-name
    WITH FRAME Dialog-Frame.
END.
ON return OF scr-point-cli-name IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  scr-point-cli-name:handle ) .
  return no-apply .
END.
ON return OF scr-point-obj-name IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  scr-point-obj-name:handle ) .
  return no-apply .
END.
ON return OF scr-transport-cli-type IN FRAME Dialog-Frame
DO:
  run next-focus in this-procedure  (input  scr-transport-cli-type:handle ) .
  return no-apply .
END.
ON return OF scr-transport-contract IN FRAME Dialog-Frame
DO:
  run next-focus in this-procedure  (input  scr-transport-contract:handle ) .
  return no-apply .
END.
ON return OF scr-transport-cli-code IN FRAME Dialog-Frame
DO:
  run next-focus in this-procedure  (input  scr-transport-cli-code:handle ) .
  return no-apply .
END.
ON return OF scr-transport-host-name IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  scr-transport-host-name:handle ) .
  return no-apply .
END.
ON return OF scr-transport-name IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  scr-transport-name:handle ) .
  return no-apply .
END.
ON VALUE-CHANGED OF scr-trasport-condition IN FRAME Dialog-Frame
DO:
 if scr-trasport-condition:screen-value = '1':U
    then do:
      assign
      scr-transport-value:visible = true
      .
    end.
    else
      scr-transport-value:visible = false  .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run init-proc in this-procedure .
  if p-mode = 'ПРОСМОТР':U then
       run lkp-enable in this-procedure .
  else run enable_ui in this-procedure .
  if scr-trasport-condition = integer ('1':U)
    then
      assign
        scr-transport-value:visible = yes
        scr-transport-value:label = "%"
        .
    else scr-transport-value:visible = no .
   if  p-type-doc  = "ord" + 'ПО':U
   then
   assign
     scr-point-obj-code:label = "Отгрузка"
     scr-point-cli-code:label = "Доставка до"
   .
   else
   assign
     scr-point-obj-code:label = "Прием"
     scr-point-cli-code:label = "Отгрузка с"
   .
  wait-for go of frame Dialog-Frame.
end.
run disable_ui in this-procedure .
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY scr-trasport-condition scr-transport-value scr-transport-sum
          scr-transport-vat-pc scr-deliv-type-code scr-deliv-type-name
          scr-point-obj-code scr-point-obj-name scr-point-cli-code
          scr-point-cli-name scr-transport-cli-code scr-transport-cli-type
          scr-transport-host-name scr-transport-contract scr-transport-name
      WITH FRAME Dialog-Frame.
  ENABLE B-save B-Cancel B-Help r-deliv r-point-1 r-point-2 r-wrkr r-wrkr-2
         B-contract scr-trasport-condition scr-transport-value
         scr-transport-sum scr-transport-vat-pc scr-deliv-type-code
         scr-deliv-type-name scr-point-obj-code scr-point-obj-name
         scr-point-cli-code scr-point-cli-name scr-transport-cli-code
         scr-transport-cli-type scr-transport-host-name scr-transport-contract
         scr-transport-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE init-proc :
scr-trasport-condition:List-Item-Pairs in frame Dialog-Frame =
"Доставка включена,0,Доставка за процент стоимости,1,Сумма доставки зависит от расстояния,2"        .
assign
  scr-deliv-type-code     = p-deliv-type-code
  scr-transport-cli-code  = p-transport-cli-code
  scr-transport-cli-type  = p-transport-cli-type
  scr-trasport-condition  = p-transport-condition
  scr-transport-value     = p-transport-value
  scr-transport-sum       = p-transport-sum
  scr-transport-vat-pc    = p-transport-vat
  scr-point-obj-code      = p-point-obj-code
  scr-point-cli-code      = p-point-cli-code
  scr-transport-contract  = p-transport-contract
  .
  if p-curr-obj-code <> ? then do:
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,output curr-host-code
  )  .
  end.
  else do:
    curr-host-code = v-cntxt-host-code-obj .
  end.
  p-transport-host-code = curr-host-code .
find first buf_delivery-type no-lock where
           buf_delivery-type.deliv-type-code = scr-deliv-type-code
           no-error .
if available  buf_delivery-type then do:
    scr-deliv-type-name = buf_delivery-type.deliv-type-name.
end.
find first cargo_clients no-lock where
      cargo_clients.obj-type = scr-transport-cli-type and
      cargo_clients.obj-code = scr-transport-cli-code
      no-error .
    if available cargo_clients then do:
          scr-transport-host-name = cargo_clients.obj-name .
          find first cargo_contract no-lock where
            cargo_contract.contract-code = scr-transport-contract and
            cargo_contract.host-code     = curr-host-code     no-error .
          if available cargo_contract then do:
            scr-transport-name     = cargo_contract.contract-prn-code.
          end.
    end.
  case  p-type-doc  :
      when "ord" + 'ПО':U or
      when "ord" + 'ОФ':U or
      when "ord" + 'ФП':U or
      when "rcv" + 'ФП':U or
      when "ord" + 'ОП':U
      then do:
            find first buf_place-io no-lock where
                       buf_place-io.obj-type      = p-curr-obj-type and
                       buf_place-io.obj-code      = p-curr-obj-code and
                       buf_place-io.place-io-code = scr-point-obj-code
                       no-error .
            if available buf_place-io then do:
                scr-point-obj-code = buf_place-io.place-io-code.
                scr-point-obj-name = buf_place-io.place-io-name.
            end.
            find first buf_point-io no-lock where
                       buf_point-io.point-code = scr-point-cli-code and
                       buf_point-io.db-num     = p-point-cli-db-num
                       no-error .
            if available buf_point-io then do:
                scr-point-cli-code = buf_point-io.point-code.
                scr-point-cli-name = buf_point-io.point-name.
            end.
        end.
        otherwise do:
            find first buf_place-io no-lock where
                       buf_place-io.obj-type      = p-curr-obj-type and
                       buf_place-io.obj-code      = p-curr-obj-code and
                       buf_place-io.place-io-code = scr-point-obj-code
                       no-error .
            if available buf_place-io then do:
                scr-point-obj-code = buf_place-io.place-io-code.
                scr-point-obj-name = buf_place-io.place-io-name.
            end.
            find first buf_place-io no-lock where
                       buf_place-io.obj-type      = p-cli-type and
                       buf_place-io.obj-code      = p-cli-code and
                       buf_place-io.place-io-code = scr-point-cli-code
                       no-error .
            if available buf_place-io then do:
                scr-point-cli-code = buf_place-io.place-io-code.
                scr-point-cli-name = buf_place-io.place-io-name.
            end.
        end.
  end case.
END PROCEDURE.
PROCEDURE lkp-enable :
B-Cancel:label in frame Dialog-Frame  = "&Выход".
  B-Cancel:column = 1.
  DISPLAY scr-deliv-type-code scr-transport-cli-code scr-trasport-condition
          scr-transport-value scr-transport-sum scr-transport-vat-pc
          scr-deliv-type-name scr-point-obj-code scr-point-obj-name
          scr-point-cli-code scr-point-cli-name scr-transport-host-name
          scr-transport-contract scr-transport-name
      WITH FRAME Dialog-Frame.
  ENABLE B-Cancel B-Help
         B-contract
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE next-focus :
do
on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
define input parameter p-widget-handle as handle no-undo .
define variable l-apply-entry as logical no-undo .
assign
  l-apply-entry =   true
.
do with frame Dialog-Frame :
  if  scr-point-cli-name     :handle = p-widget-handle then do:  if scr-point-obj-name     :sensitive then do: apply "entry":u to scr-point-obj-name     . return . end. end.
  if  scr-point-obj-name     :handle = p-widget-handle then do:  if scr-transport-contract :sensitive then do: apply "entry":u to scr-transport-contract . return . end. end.
  if  scr-transport-contract :handle = p-widget-handle then do:  if scr-transport-cli-code     :sensitive then do: apply "entry":u to scr-transport-cli-code     . return . end. end.
  if  scr-transport-cli-code     :handle = p-widget-handle then do:  if scr-transport-name     :sensitive then do: apply "entry":u to scr-transport-name     . return . end. end.
  end.
  end.
END PROCEDURE.
PROCEDURE save-proc :
assign frame Dialog-Frame
scr-deliv-type-code
scr-transport-cli-code
scr-trasport-condition
scr-transport-value
scr-transport-sum
scr-transport-vat-pc
scr-point-obj-code
scr-point-cli-code
scr-transport-contract
.
assign
  p-deliv-type-code     = scr-deliv-type-code
  p-transport-cli-type  = scr-transport-cli-type
  p-transport-cli-code  = scr-transport-cli-code
  p-transport-condition = scr-trasport-condition
  p-transport-value     = scr-transport-value
  p-transport-sum       = scr-transport-sum
  p-transport-vat       = scr-transport-vat-pc
  p-point-obj-code      = scr-point-obj-code
  p-point-cli-code      = scr-point-cli-code
  p-transport-contract  = scr-transport-contract
  .
define buffer buf_contract for ub.contract  .
if p-transport-contract  <> 0 and p-transport-contract  <> ? then do:
   find first buf_contract no-lock where
              buf_contract.host-code     =  p-transport-host-code and
              buf_contract.contract-code =  p-transport-contract no-error .
   if not available buf_contract then do:
      message
        "Не верно задан договор грузоперевозчика" skip
        "Фирма  : " p-transport-host-code  skip
        "Договор: " p-transport-contract  skip
        view-as alert-box error
      .
      return error .
      end.
      if not ( buf_contract.cli-type  =  p-transport-cli-type and
               buf_contract.cli-code  =  p-transport-cli-code  ) then do:
      message
        "У Грузоперевозчика нет такого договора" skip
        "Грузоперевозчик: " p-transport-cli-type p-transport-cli-code      skip
        "Фирма  : " p-transport-host-code  skip
        "Договор: " p-transport-contract  skip
        view-as alert-box error
      .
      return error .
      end.
end.
END PROCEDURE.
