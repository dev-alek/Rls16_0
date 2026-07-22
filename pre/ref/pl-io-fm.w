define input parameter parparentproc as widget-handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-mode        as character no-undo.
define input-output parameter p-rep-rec     as recid no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "создание и изменение мест приемки/отгрузки".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define buffer buf_place-io for ub.place-io .
define variable p-sys-time as character no-undo .
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1.
DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1.
DEFINE BUTTON b-save AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1.
DEFINE VARIABLE v-name AS CHARACTER FORMAT "X(40)"
     LABEL "Название"
     VIEW-AS FILL-IN
     SIZE 51 BY 1.
DEFINE VARIABLE v-num AS INTEGER FORMAT ">>>>>>>>>9" INITIAL 0
     LABEL "Номер"
     VIEW-AS FILL-IN
     SIZE 19.5 BY 1.
DEFINE VARIABLE v-PS AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 62.5 BY 6.25 NO-UNDO.
DEFINE VARIABLE RADIO-type AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "приемки", 1,
"отгрузки", 2
     SIZE 26.5 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-save AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-hist AT ROW 1 COL 41
     b-help AT ROW 1 COL 55.13
     RADIO-type AT ROW 2.5 COL 3 NO-LABEL
     v-num AT ROW 2.5 COL 42.5 COLON-ALIGNED
     v-name AT ROW 3.71 COL 11 COLON-ALIGNED
     v-PS AT ROW 5.92 COL 2 NO-LABEL
     "Примечание:" VIEW-AS TEXT
          SIZE 15 BY .67 AT ROW 5.08 COL 3
     SPACE(47.12) SKIP(6.70)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Место приемки/отгрузки".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       v-num:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-hist IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  if not available buf_place-io then return .
  run ref/pliohist.w ( INPUT parParentProc
                     , input buf_place-io.obj-type
                     , input buf_place-io.obj-code
                     , input buf_place-io.place-io-code
                     , input "":U
                     , input-output v-rid-list
                     ) no-error .
END.
ON CHOOSE OF b-quit IN FRAME Dialog-Frame
DO:
p-rep-rec = ?.
END.
ON CHOOSE OF b-save IN FRAME Dialog-Frame
DO:
  assign RADIO-type v-name v-PS .
  if v-name = "" or v-name = ? then do:
    message "Название места должно быть заполнено.".
    apply "entry" to v-name in frame Dialog-Frame.
    return no-apply.
  end.
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    create buf_place-io .
    if can-find( ub.place-io no-lock where ub.place-io.place-io-code = v-num and ub.place-io.obj-type = p-obj-type and ub.place-io.obj-code = p-obj-code ) then do:
      run gen_code(input-output v-num ) no-error.
      if error-status:error then undo, return .
    end.
    assign
      buf_place-io.place-io-code = v-num
      buf_place-io.obj-type      = p-obj-type
      buf_place-io.obj-code      = p-obj-code
      buf_place-io.status_       = 'новый':U
    .
  end.
  assign
    buf_place-io.place-io-name = v-name
    buf_place-io.PS            = v-PS
  .
  if RADIO-type = 1 then assign buf_place-io.place-io-type = 'приемки':U .
  else                   assign buf_place-io.place-io-type = 'отгрузки':U .
  p-rep-rec = recid (buf_place-io).
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
  if p-mode = 'ИЗМЕНЕНИЕ':U then do:
    find buf_place-io where recid (buf_place-io) = p-rep-rec.
    assign
      v-num  = buf_place-io.place-io-code
      v-name = buf_place-io.place-io-name
      v-PS   = buf_place-io.PS
    .
    if buf_place-io.place-io-type = 'приемки':U then assign RADIO-type = 1 .
    else                                             assign RADIO-type = 2 .
  end.
  else  run gen_code( input-output v-num ) no-error.
  frame Dialog-Frame:title = "Место приемки/отгрузки на объекте : " + p-obj-type + " " + string (p-obj-code) + "         " + p-mode.
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY RADIO-type v-num v-name v-PS WITH FRAME Dialog-Frame.
  ENABLE b-save b-quit B-hist b-help RADIO-type v-num v-name v-PS WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE gen_code :
  DEFINE INPUT-OUTPUT PARAMETER loc-f-code as integer no-undo.
  def var my-value as integer no-undo.
gen-code:
  do while true:
    my-value = next-value( s-place-io, ub ).
    if my-value >= 99999999 or my-value = ? then do:
      current-value(s-place-io, ub) = 1.
      next.
    end.
    if not can-find( ub.place-io no-lock where ub.place-io.place-io-code = my-value and ub.place-io.obj-type = p-obj-type and ub.place-io.obj-code = p-obj-code ) then leave gen-code.
  end.
  assign loc-f-code = my-value .
END PROCEDURE.
