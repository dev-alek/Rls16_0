DEFINE INPUT  PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE OUTPUT PARAMETER p-obj-type AS character NO-UNDO.
DEFINE OUTPUT PARAMETER p-obj-code AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-ext-obj-type AS character NO-UNDO.
DEFINE OUTPUT PARAMETER p-ext-obj-code AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-Ok        AS logical NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Ввод данных для нового клиента во внешнем классификаторе соответствия контрагентов" .
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
define variable ref-list as character no-undo.
define variable v-rec as recid no-undo .
define buffer buf_db for ub.db.
DEFINE BUTTON b-choose-client
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-choose-client"
     SIZE 3 BY 1.
DEFINE BUTTON b-choose-contragent
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-choose-contragent"
     SIZE 3 BY 1.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод "
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE fi-ext-obj-code AS INTEGER FORMAT ">>>>>>>9" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 9.2 BY 1 TOOLTIP "Соответствующий код контрагента в ТН или другой системе"
     BGCOLOR 15 .
DEFINE VARIABLE fi-ext-obj-type AS CHARACTER FORMAT "X(3)"
     LABEL "Контрагент"
     VIEW-AS FILL-IN
     SIZE 4.2 BY 1 TOOLTIP "Соответствующий тип контрагента в ТН или другой системе"
     BGCOLOR 15 .
DEFINE VARIABLE fi-obj-code AS INTEGER FORMAT ">>>>>>>9" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 9.2 BY 1 TOOLTIP "код клиента"
     BGCOLOR 15 .
DEFINE VARIABLE fi-obj-type AS CHARACTER FORMAT "X(3)"
     LABEL "Клиент в ТН"
     VIEW-AS FILL-IN
     SIZE 4.2 BY 1 TOOLTIP "тип клиента"
     BGCOLOR 15 .
DEFINE FRAME d-add-ext-client
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-help AT ROW 1 COL 50
     fi-obj-type AT ROW 2.43 COL 13 COLON-ALIGNED
     fi-obj-code AT ROW 2.43 COL 18 COLON-ALIGNED NO-LABEL WIDGET-ID 2
     b-choose-client AT ROW 2.43 COL 29
     fi-ext-obj-type AT ROW 3.86 COL 13 COLON-ALIGNED
     fi-ext-obj-code AT ROW 3.86 COL 18 COLON-ALIGNED NO-LABEL WIDGET-ID 4
     b-choose-contragent AT ROW 3.86 COL 29
     SPACE(34.37) SKIP(1.78)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Соответствие контрагентов"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME d-add-ext-client:SCROLLABLE       = FALSE
       FRAME d-add-ext-client:HIDDEN           = TRUE.
ON GO OF FRAME d-add-ext-client
DO:
  define buffer buf_db for ub.db .
  define buffer buf_clients for ub.clients.
  assign
    fi-obj-type
    fi-obj-code
    fi-ext-obj-type
    fi-ext-obj-code
  .
  find first buf_clients no-lock
    where buf_clients.obj-type = fi-obj-type
      and buf_clients.obj-code = fi-obj-code
    no-error.
  if not avail buf_clients then do:
    message
      substitute( "Не возможно найти клиента &1 &2", fi-obj-type, string( fi-obj-code ) )
      view-as alert-box error .
    apply "entry" to fi-obj-type.
    return no-apply.
  end.
  assign
    p-obj-type     = fi-obj-type
    p-obj-code     = fi-obj-code
    p-ext-obj-type = fi-ext-obj-type
    p-ext-obj-code = fi-ext-obj-code
    p-Ok = yes
  .
 END.
ON WINDOW-CLOSE OF FRAME d-add-ext-client
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-choose-client IN FRAME d-add-ext-client
DO:
  run ref/cli-all.w
  ( parparentproc
    , input  "b-sel"
    , ?
    , ?
    , ?
    , ?
    , ?
    , ?
  ,output ref-list
  ).
  If ref-list <> "" then do :
    find first ub.clients no-lock
      where recid(ub.clients) = integer(ref-list) no-error.
    if available ub.clients then do with frame d-add-ext-client:
      assign
        fi-obj-type = ub.clients.obj-type
        fi-obj-code = ub.clients.obj-code
      .
      display fi-obj-type fi-obj-code.
    end.
  end.
END.
ON CHOOSE OF b-choose-contragent IN FRAME d-add-ext-client
DO:
  run ref/cli-all.w
  ( parparentproc
    , input  "b-sel"
    , ?
    , ?
    , ?
    , ?
    , ?
    , ?
  ,output ref-list
  ).
  If ref-list <> "" then do :
    find first ub.clients no-lock
         where recid(ub.clients) = integer(ref-list) no-error.
    if available ub.clients then do with frame d-add-ext-client:
      assign
        fi-ext-obj-type = ub.clients.obj-type
        fi-ext-obj-code = ub.clients.obj-code
      .
      display fi-ext-obj-type fi-ext-obj-code.
    end.
  end.
END.
ON CHOOSE OF b-quit IN FRAME d-add-ext-client
DO:
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME d-add-ext-client:PARENT eq ?
THEN FRAME d-add-ext-client:PARENT = ACTIVE-WINDOW.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-add-ext-client
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
on choose of b-help in frame d-add-ext-client
do:
  apply "help":u to frame d-add-ext-client .
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
                v-frame-width = frame d-add-ext-client:width - 0.3
                fh            = frame d-add-ext-client:first-child
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
  RUN MyEnable.
  WAIT-FOR GO OF FRAME d-add-ext-client.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME d-add-ext-client.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY fi-obj-type fi-obj-code fi-ext-obj-type fi-ext-obj-code
      WITH FRAME d-add-ext-client.
  ENABLE b-exit b-quit B-help fi-obj-type fi-obj-code b-choose-client
         fi-ext-obj-type fi-ext-obj-code b-choose-contragent
      WITH FRAME d-add-ext-client.
  VIEW FRAME d-add-ext-client.
END PROCEDURE.
PROCEDURE MyEnable :
    DISPLAY
    fi-obj-type fi-obj-code fi-ext-obj-type fi-ext-obj-code
    WITH FRAME d-add-ext-client.
  ENABLE
  B-exit
  B-quit
  B-Help
  fi-obj-type fi-obj-code b-choose-client fi-ext-obj-type fi-ext-obj-code b-choose-contragent
  WITH FRAME d-add-ext-client.
  VIEW FRAME d-add-ext-client.
END PROCEDURE.
