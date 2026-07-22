define input        parameter p-mode                as character no-undo .
define input        parameter p-type                as character no-undo .
define input        parameter p-host-code           as integer   no-undo .
define input        parameter parParentProc         AS WIDGET-HANDLE NO-UNDO.
define input-output parameter p-transport-cli-type  like ub.sysconf.transport-cli-type   no-undo .
define input-output parameter p-transport-cli-code  like ub.sysconf.transport-cli-code   no-undo .
define input-output parameter p-transport-host      like ub.sysconf.transport-host       no-undo .
define input-output parameter p-transport-contract  like ub.sysconf.transport-contract   no-undo .
define input-output parameter p-transport-uslov     like ub.sysconf.transport-uslov      no-undo .
define input-output parameter p-transport-value     like ub.sysconf.transport-value      no-undo .
define input-output parameter p-transport-type      like ub.contract.transport-type      no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "транспортные настройки фирмы".
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
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
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
define buffer buf_delivery-type for ub.delivery-type .
define variable  agnt-list as character no-undo .
define variable v-transport-host as integer   no-undo .
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON BUTTON-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "2"
     SIZE 2.88 BY 1.
DEFINE BUTTON BUTTON-contr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "2"
     SIZE 2.88 BY 1.
DEFINE BUTTON BUTTON-type
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "2"
     SIZE 2.88 BY 1.
DEFINE VARIABLE COMBO-usl AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 3
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 58.5 BY 1 NO-UNDO.
DEFINE VARIABLE cli-type AS CHARACTER FORMAT "X(3)"
     VIEW-AS FILL-IN
     SIZE 4.38 BY 1.
DEFINE VARIABLE cli-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 41.75 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-cont AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 41.75 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-type AS CHARACTER FORMAT "X(56)":U
     VIEW-AS FILL-IN
     SIZE 49.5 BY 1 NO-UNDO.
DEFINE VARIABLE transport-contract LIKE ub.sysconf.transport-contract
     LABEL "Транспортный договор"
     VIEW-AS FILL-IN
     SIZE 8 BY 1 NO-UNDO.
DEFINE VARIABLE cli-code LIKE ub.sysconf.transport-cli-code
     LABEL "Контрагент"
     VIEW-AS FILL-IN
     SIZE 7.5 BY 1 NO-UNDO.
DEFINE VARIABLE transport-type AS INTEGER FORMAT ">>>>9" INITIAL 0
     LABEL "Тип доставки"
     VIEW-AS FILL-IN
     SIZE 6.75 BY 1 NO-UNDO.
DEFINE VARIABLE transport-value LIKE ub.sysconf.transport-value
     LABEL "%"
     VIEW-AS FILL-IN
     SIZE 9.75 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 66.13
     cli-code AT ROW 2.5 COL 16.5 COLON-ALIGNED HELP
          ""
     cli-type AT ROW 2.5 COL 24.5 COLON-ALIGNED NO-LABEL WIDGET-ID 8
     BUTTON-cli AT ROW 2.5 COL 31.13 WIDGET-ID 4
     cli-name AT ROW 2.5 COL 32.25 COLON-ALIGNED NO-LABEL
     transport-contract AT ROW 3.71 COL 21 COLON-ALIGNED HELP
          ""
          LABEL "Транспортный договор"
     BUTTON-contr AT ROW 3.71 COL 31.25 WIDGET-ID 2
     FILL-cont AT ROW 3.75 COL 32.25 COLON-ALIGNED NO-LABEL
     transport-value AT ROW 5.96 COL 64.25 COLON-ALIGNED HELP
          ""
          LABEL "%"
     COMBO-usl AT ROW 6.04 COL 1 COLON-ALIGNED NO-LABEL
     transport-type AT ROW 7.25 COL 13.75 COLON-ALIGNED
     BUTTON-type AT ROW 7.25 COL 23
     FILL-type AT ROW 7.25 COL 24.5 COLON-ALIGNED NO-LABEL
     "Условие предоставления транспортных услуг:" VIEW-AS TEXT
          SIZE 53 BY .67 AT ROW 5.21 COL 3
          FGCOLOR 4
     SPACE(20.62) SKIP(2.61)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Транспортные настройки фирмы".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       cli-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       FILL-cont:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       FILL-type:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
  if p-mode <> 'ПРОСМОТР':U then do:
    assign transport-value cli-code cli-type transport-contract COMBO-usl .
    case COMBO-usl :
      when 'Доставка включена':U then assign p-transport-uslov = int('0':U) .
      when 'Доставка за процент стоимости':U     then
          assign
            p-transport-uslov = int('1':U)
            p-transport-value = transport-value
          .
      when 'Сумма доставки зависит от расстояния':U    then assign p-transport-uslov = int('2':U) .
    end.
    assign
      p-transport-cli-type = cli-type
      p-transport-cli-code = cli-code
      p-transport-host     = v-transport-host
      p-transport-contract = transport-contract
      p-transport-type     = transport-type
    .
  end.
END.
ON CHOOSE OF BUTTON-cli IN FRAME Dialog-Frame
DO:
  assign
    transport-contract = 0
    v-transport-host   = 0
    FILL-cont          = ""
  .
  define buffer buf_clients for ub.clients.
  run ref/cli-all.w (parParentProc, "b-sel", 'все':U, 'все':U, 'текущие':U, ?, ",,,,,,NO,,":u, "without-obj":U, output agnt-list ) .
  if agnt-list <> "" then do:
    find first buf_clients no-lock where RECID(buf_clients) = int (agnt-list) no-error.
    if buf_clients.obj-type <> 'чел':U and buf_clients.obj-type <> 'орг':U then do:
      message
        "Контрагент может быть только " 'орг':U " или " 'чел':U
        view-as alert-box ERROR .
      return no-apply.
    end.
    assign
      cli-name = buf_clients.obj-name
      cli-code = buf_clients.obj-code
      cli-type = buf_clients.obj-type
    .
  end.
  else assign cli-name = ""  cli-code = ?  cli-type  = ? .
  display     cli-name       cli-code      cli-type transport-contract FILL-cont   with frame Dialog-Frame.
END.
ON CHOOSE OF BUTTON-contr IN FRAME Dialog-Frame
DO:
  define buffer buf_contract for ub.contract.
  run str/cont-all.w ( input  parParentProc, input p-host-code, input "b-sel":U, input 'фирма':U, input cli-type, input cli-code, input  ?, input  ?, input  "current", input 'при':U , input-output agnt-list   ) no-error .
  find first buf_contract no-lock where RECID(buf_contract) = int (agnt-list) no-error.
  if not available buf_contract then do:
    assign
      transport-contract = 0
      v-transport-host = 0
      FILL-cont = ""
    .
    display transport-contract FILL-cont  with frame Dialog-Frame.
    return.
  end.
  assign
    transport-contract = buf_contract.contract-code
    v-transport-host   = buf_contract.host-code
    FILL-cont          = buf_contract.contract-prn-code + " от " + string(buf_contract.contract-date,"99/99/9999")
  .
  display transport-contract FILL-cont  with frame Dialog-Frame.
END.
ON CHOOSE OF BUTTON-type IN FRAME Dialog-Frame
DO:
  define variable v-rid-list as character no-undo.
  define variable v-sts as integer no-undo .
define variable vss-include-info1 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  if available buf_delivery-type then
    assign
      v-rid-list = string(recid(buf_delivery-type))
      v-sts = buf_delivery-type.sts
    .
  run ref/dlvtypes.w (input parParentProc, v-cntxt-obj-type, v-cntxt-obj-code, "b-sel":U, 'все':U, input-output v-sts, input-output v-rid-list ) no-error .
  if v-rid-list <> "":U then do:
    FIND FIRST buf_delivery-type WHERE recid( buf_delivery-type ) = integer(entry(1, v-rid-list)) NO-LOCK .
    assign
      transport-type = buf_delivery-type.deliv-type-code
      FILL-type      = buf_delivery-type.deliv-type-name
    .
    display transport-type  FILL-type  with frame Dialog-Frame .
  end.
END.
ON LEAVE OF cli-type IN FRAME Dialog-Frame
DO:
  assign cli-type.
  assign
    transport-contract = 0
    v-transport-host   = 0
    FILL-cont          = ""
  .
  define buffer buf_clients for ub.clients.
  if cli-type <> 'орг':U and cli-type <> 'чел':U then do:
    find first buf_clients no-lock where buf_clients.obj-type = 'орг':U and buf_clients.obj-code = cli-code no-error.
    if not available buf_clients then do:
      find first buf_clients no-lock where buf_clients.obj-type = 'чел':U and buf_clients.obj-code = cli-code no-error.
    end.
  end.
  else find first buf_clients no-lock where buf_clients.obj-type = cli-type and buf_clients.obj-code = cli-code no-error.
  if not available buf_clients then do:
    if cli-code = 0 then assign cli-code = ? .
    if cli-code = ? then do:
      assign cli-name = ""   cli-code = ?  cli-type  = ? .
      display cli-name    cli-code     cli-type    with frame Dialog-Frame.
    end.
    else do:
      apply "CHOOSE" to BUTTON-cli IN FRAME Dialog-Frame .
    end.
    return.
  end.
  assign
    cli-name = buf_clients.obj-name
    cli-code = buf_clients.obj-code
    cli-type = buf_clients.obj-type
  .
  display cli-name    cli-code     cli-type  transport-contract FILL-cont   with frame Dialog-Frame.
END.
ON VALUE-CHANGED OF COMBO-usl IN FRAME Dialog-Frame
DO:
  assign COMBO-usl .
  if COMBO-usl:screen-value = 'Доставка за процент стоимости':U then transport-value:visible = yes .
  else                                                   transport-value:visible = no .
END.
ON LEAVE OF transport-contract IN FRAME Dialog-Frame
DO:
  if transport-contract = int ( transport-contract:screen-value ) then return.
  assign transport-contract .
  define buffer buf_contract for ub.contract .
  find first buf_contract no-lock
    where buf_contract.host-code     = p-host-code
      and buf_contract.contract-code = transport-contract
      and buf_contract.cli-code      = cli-code
      and buf_contract.cli-type      = cli-type
  no-error.
  if not available buf_contract then do:
    apply "CHOOSE" to BUTTON-contr IN FRAME Dialog-Frame .
  end.
  else do:
    assign
      transport-contract = buf_contract.contract-code
      v-transport-host   = buf_contract.host-code
      FILL-cont          = buf_contract.contract-prn-code + " от " + string(buf_contract.contract-date,"99/99/9999")
    .
  end.
  display transport-contract FILL-cont  with frame Dialog-Frame.
END.
ON RETURN OF transport-contract IN FRAME Dialog-Frame
DO:
  if transport-contract = int ( transport-contract:screen-value ) then return.
  assign transport-contract .
  define buffer buf_contract for ub.contract .
  find first buf_contract no-lock
    where buf_contract.host-code     = p-host-code
      and buf_contract.contract-code = transport-contract
      and buf_contract.cli-code      = cli-code
      and buf_contract.cli-type      = cli-type
  no-error.
  if not available buf_contract then do:
    apply "CHOOSE" to BUTTON-contr IN FRAME Dialog-Frame .
  end.
  else do:
    assign
      transport-contract = buf_contract.contract-code
      v-transport-host   = buf_contract.host-code
      FILL-cont          = buf_contract.contract-prn-code + " от " + string(buf_contract.contract-date,"99/99/9999")
    .
    display transport-contract FILL-cont  with frame Dialog-Frame.
  end.
END.
ON LEAVE OF cli-code IN FRAME Dialog-Frame
DO:
  if cli-code = int ( cli-code:screen-value ) then return.
  assign cli-code .
  DISABLE transport-contract WITH FRAME Dialog-Frame.
  assign
    transport-contract = 0
    v-transport-host   = 0
    FILL-cont          = ""
  .
  define buffer buf_clients for ub.clients.
  find first buf_clients no-lock where buf_clients.obj-type = cli-type and buf_clients.obj-code = cli-code no-error.
  if not available buf_clients then do:
    apply "CHOOSE" to BUTTON-cli IN FRAME Dialog-Frame .
  end.
  else do:
    assign
      cli-code           = buf_clients.obj-code
      cli-type           = buf_clients.obj-type
      cli-name           = buf_clients.obj-name
    .
  end.
  ENABLE transport-contract WITH FRAME Dialog-Frame.
  display cli-code cli-type cli-name  transport-contract FILL-cont  with frame Dialog-Frame.
END.
ON RETURN OF cli-code IN FRAME Dialog-Frame
DO:
  if cli-code = int ( cli-code:screen-value ) then return.
  assign cli-code .
  DISABLE transport-contract WITH FRAME Dialog-Frame.
  assign
    transport-contract = 0
    v-transport-host   = 0
    FILL-cont          = ""
  .
  define buffer buf_clients for ub.clients.
  find first buf_clients no-lock where buf_clients.obj-type = cli-type and buf_clients.obj-code = cli-code no-error.
  if not available buf_clients then do:
    apply "CHOOSE" to BUTTON-cli IN FRAME Dialog-Frame .
  end.
  else do:
    assign
      cli-code           = buf_clients.obj-code
      cli-type           = buf_clients.obj-type
      cli-name           = buf_clients.obj-name
    .
  end.
  ENABLE transport-contract WITH FRAME Dialog-Frame.
  display cli-code cli-type cli-name  transport-contract FILL-cont  with frame Dialog-Frame.
END.
ON LEAVE OF transport-type IN FRAME Dialog-Frame
DO:
  assign transport-type .
  find first buf_delivery-type no-lock where buf_delivery-type.deliv-type-code = transport-type no-error .
  if available buf_delivery-type then do:
    assign
      transport-type = buf_delivery-type.deliv-type-code
      FILL-type      = buf_delivery-type.deliv-type-name
    .
    display transport-type  FILL-type  with frame Dialog-Frame .
  end.
  else apply "CHOOSE"  to BUTTON-type  IN FRAME Dialog-Frame .
END.
ON RETURN OF transport-type IN FRAME Dialog-Frame
DO:
  assign transport-type .
  find first buf_delivery-type no-lock where buf_delivery-type.deliv-type-code = transport-type no-error .
  if available buf_delivery-type then do:
    assign
      transport-type = buf_delivery-type.deliv-type-code
      FILL-type      = buf_delivery-type.deliv-type-name
    .
    display transport-type  FILL-type  with frame Dialog-Frame .
  end.
  else apply "CHOOSE"  to BUTTON-type  IN FRAME Dialog-Frame .
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  if p-type = "contract" then ASSIGN  frame Dialog-Frame:TITLE = "Транспортные настройки договора" .
  COMBO-usl:list-items   = 'Доставка включена':U + ","  + 'Доставка за процент стоимости':U + ","  + 'Сумма доставки зависит от расстояния':U .
  define buffer buf_clients for ub.clients.
  find first buf_clients no-lock where buf_clients.obj-type = p-transport-cli-type and buf_clients.obj-code = p-transport-cli-code no-error.
  if available buf_clients then assign cli-name = buf_clients.obj-name .
  define buffer buf_contract for ub.contract .
  find first buf_contract no-lock where buf_contract.host-code = p-transport-host and buf_contract.contract-code = p-transport-contract no-error.
  if available buf_contract then assign FILL-cont = buf_contract.contract-prn-code + " от " + string(contract-date,"99/99/9999") .
  case p-mode :
    when 'ДОБАВЛЕНИЕ':U then do:
      assign COMBO-usl:screen-value   = 'Доставка включена':U .
    end.
    when 'ИЗМЕНЕНИЕ':U or when 'ПРОСМОТР':U then do:
      assign
        cli-type           = p-transport-cli-type
        cli-code           = p-transport-cli-code
        transport-contract = p-transport-contract
        transport-type     = p-transport-type
      .
      if available buf_contract then assign v-transport-host = buf_contract.host-code .
      case p-transport-uslov :
        when int('0':U) then assign COMBO-usl:screen-value   = 'Доставка включена':U .
        when int('1':U)     then
          assign
            COMBO-usl:screen-value   = 'Доставка за процент стоимости':U
            transport-value = p-transport-value
          .
        when int('2':U)    then assign COMBO-usl:screen-value   = 'Сумма доставки зависит от расстояния':U .
      end.
      apply "LEAVE"  to transport-type  IN FRAME Dialog-Frame .
      apply "LEAVE"  to transport-contract  IN FRAME Dialog-Frame .
    end.
  end case.
  RUN Myenable_UI.
  apply "VALUE-CHANGED"  to COMBO-usl  IN FRAME Dialog-Frame .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE Myenable_UI :
  DISPLAY cli-code cli-type cli-name transport-contract FILL-cont
          transport-value COMBO-usl transport-type FILL-type
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help  WITH FRAME Dialog-Frame.
  if p-mode = 'ДОБАВЛЕНИЕ':U or p-mode = 'ИЗМЕНЕНИЕ':U then do:
    ENABLE cli-code cli-type BUTTON-cli cli-name
         transport-contract BUTTON-contr FILL-cont transport-value COMBO-usl
         transport-type BUTTON-type FILL-type
      WITH FRAME Dialog-Frame.
  end.
  else do:
    B-exit:label in frame Dialog-Frame = "&Выход" .
    b-quit:visible = no .
  end.
  if p-type <> "contract" then do:
    assign
      transport-type:visible = no
      FILL-type:visible = no
      BUTTON-type:visible = no
    .
  end.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
