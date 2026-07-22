DEFINE TEMP-TABLE tt_pay-type NO-UNDO LIKE ub.pay-type.
define input        parameter parparentproc as widget-handle no-undo .
define input        parameter ref-mode      as character     no-undo .
define input-output parameter rid           as recid         no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Форма редактирования вида оплаты".
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
DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1.
DEFINE BUTTON B-help
     LABEL "Помо&щь"
     SIZE 10 BY 1.
DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1.
DEFINE BUTTON b-OK AUTO-GO
     LABEL "&Ввод "
     SIZE 10 BY 1.
DEFINE QUERY d-pay-type FOR
      tt_pay-type SCROLLING.
DEFINE FRAME d-pay-type
     b-OK AT ROW 1 COL 1
     b-cancel AT ROW 1 COL 11
     B-hist AT ROW 1 COL 31
     B-help AT ROW 1 COL 51
     tt_pay-type.obj-code AT ROW 2.5 COL 8.5 COLON-ALIGNED
          LABEL "&Код"
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     tt_pay-type.obj-name AT ROW 3.75 COL 8.5 COLON-ALIGNED
          LABEL "О&плата"
          VIEW-AS FILL-IN
          SIZE 41 BY 1
     SPACE(11.12) SKIP(0.82)
    WITH VIEW-AS DIALOG-BOX
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "О П Л А Т А".
ASSIGN
       FRAME d-pay-type:SCROLLABLE       = FALSE.
ON CHOOSE OF B-hist IN FRAME d-pay-type
DO:
    define variable v-rid-list as character no-undo .
        run ref/cpaytyps.w (
                     INPUT parparentproc
                    ,INPUT '':U
                    ,INPUT 'one':U
                    ,INPUT tt_pay-type.obj-code
                    ,INPUT-OUTPUT v-rid-list) NO-ERROR.
END.
ON CHOOSE OF b-OK IN FRAME d-pay-type
DO:
  assign
    tt_pay-type.obj-code
    tt_pay-type.obj-name
    .
   run ref/paytype1.p
     ( input-output rid
     , input ref-mode
     , input no
     , input tt_pay-type.obj-code
     , input tt_pay-type.obj-name
     ) no-error.
  if error-status:error then do:
    if return-value = "":U then do:
      return no-apply.
    end.
    case return-value:
      when "obj-code":U then do:
        APPLY "ENTRY" to tt_pay-type.obj-code .
      end.
      when "obj-name":U then do:
        APPLY "ENTRY" to tt_pay-type.obj-name .
      end.
    end.
    return no-apply.
  end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME d-pay-type:PARENT eq ?
THEN FRAME d-pay-type:PARENT = ACTIVE-WINDOW.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-pay-type
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
on choose of b-help in frame d-pay-type
do:
  apply "help":u to frame d-pay-type .
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
                v-frame-width = frame d-pay-type:width - 0.3
                fh            = frame d-pay-type:first-child
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
ON WINDOW-CLOSE OF FRAME d-pay-type APPLY "END-ERROR":U TO SELF.
MAIN-BLOCK:
DO ON ERROR UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
ON END-KEY  UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
ON STOP     UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  define buffer buf_pay-type for ub.pay-type .
  create tt_pay-type.
  if ref-mode = 'ДОБАВЛЕНИЕ':U then  do:
    assign
      rid = ?
    .
    find last buf_pay-type no-lock
      use-index pi
      no-error .
    if available buf_pay-type then do:
      assign
        tt_pay-type.obj-code = buf_pay-type.obj-code + 1
      .
    end.
    else do:
      assign
        tt_pay-type.obj-code = 1
      .
    end.
  end.
  else do:
    find first buf_pay-type exclusive-lock
      where recid( buf_pay-type ) = rid
      .
    buffer-copy buf_pay-type to tt_pay-type .
  end.
  session:data-entry-return = yes .
  RUN enable_UI.
  if ref-mode = 'ДОБАВЛЕНИЕ':U then do:
    WAIT-FOR GO OF FRAME d-pay-type FOCUS tt_pay-type.obj-code .
  end.
  else do:
    WAIT-FOR GO OF FRAME d-pay-type FOCUS tt_pay-type.obj-name .
  end.
END.
RUN disable_UI.
session:data-entry-return = no .
PROCEDURE disable_UI :
  HIDE FRAME d-pay-type.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY
      tt_pay-type.obj-code
      tt_pay-type.obj-name
      WITH FRAME d-pay-type.
  ENABLE
      b-OK
      b-cancel
      b-hist               WHEN ref-mode <> 'ДОБАВЛЕНИЕ':U
      tt_pay-type.obj-code WHEN ref-mode = 'ДОБАВЛЕНИЕ':U
      tt_pay-type.obj-name
      WITH FRAME d-pay-type.
END PROCEDURE.
