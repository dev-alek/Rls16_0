define input  parameter parparentproc as handle no-undo .
define input  parameter p-mode as character no-undo .
define input-output parameter p-recid as recid no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Добавление новой группы покупателей".
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
DEFINE BUTTON B-Cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-save AUTO-GO
     LABEL "Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON r-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-cli"
     SIZE 3 BY .88 TOOLTIP "Выбор из списка".
DEFINE VARIABLE v-gr AS INTEGER FORMAT ">>>>>9":U INITIAL 0
     LABEL "Переходит в группу"
      VIEW-AS TEXT
     SIZE 11.5 BY .67 NO-UNDO.
DEFINE VARIABLE v-gr-db-num AS INTEGER FORMAT "(>>9)":U INITIAL 0
      VIEW-AS TEXT
     SIZE 4 BY .67 NO-UNDO.
DEFINE VARIABLE v-gr-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 42 BY .67 NO-UNDO.
DEFINE VARIABLE v-name LIKE ub.buyer-group.name
     LABEL "Название группы покупателей"
     VIEW-AS FILL-IN
     SIZE 55 BY 1 NO-UNDO.
DEFINE VARIABLE v-oborot LIKE ub.buyer-group.oborot
     LABEL "Оборот для перехода в другую группу"
     VIEW-AS FILL-IN
     SIZE 21 BY 1 NO-UNDO.
DEFINE VARIABLE v-rule-grp LIKE ub.buyer-group.rule-grp
     LABEL "Правило"
     VIEW-AS FILL-IN
     SIZE 26 BY 1 NO-UNDO.
DEFINE VARIABLE v-use-alg LIKE ub.buyer-group.use-alg
     LABEL "Работает алгоритм при переходе по группам"
     VIEW-AS TOGGLE-BOX
     SIZE 44.5 BY .83 NO-UNDO.
DEFINE FRAME Dialog-Frame
     B-Cancel AT ROW 1 COL 11
     B-save AT ROW 1 COL 1
     B-Help AT ROW 1 COL 77
     v-name AT ROW 2.75 COL 28 COLON-ALIGNED HELP
          ""
          LABEL "Название группы покупателей" FORMAT "X(80)"
     v-oborot AT ROW 4 COL 39 COLON-ALIGNED HELP
          ""
          LABEL "Оборот для перехода в другую группу" FORMAT "->>>,>>>,>>>,>>9.99"
     r-cli AT ROW 5.17 COL 39.5
     v-rule-grp AT ROW 8.25 COL 34.5 COLON-ALIGNED HELP
          ""
          LABEL "Правило" FORMAT "X(256)"
     v-use-alg AT ROW 9.5 COL 36.5 HELP
          ""
          LABEL "Работает алгоритм при переходе по группам"
     v-gr AT ROW 5.25 COL 20.5 COLON-ALIGNED
     v-gr-db-num AT ROW 5.25 COL 33.38 COLON-ALIGNED NO-LABEL
     v-gr-name AT ROW 5.25 COL 40.5 COLON-ALIGNED NO-LABEL
     SPACE(2.50) SKIP(6.36)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Добавление группы покупателей для ценообразования"
         DEFAULT-BUTTON B-save CANCEL-BUTTON B-Cancel.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       v-gr-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-rule-grp:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       v-use-alg:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  RUN save-proc.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF r-cli IN FRAME Dialog-Frame
DO:
  define variable v-recid as character no-undo .
  define buffer bf_buyer-group for ub.buyer-group  .
  run ref/gr-bupr.w  (parParentProc , "b-sel" , input-output  v-recid).
  find first bf_buyer-group no-lock where recid(bf_buyer-group) = int(v-recid)  no-error .
  if not available bf_buyer-group then do:
  display "" @ v-gr
          "" @ v-gr-db-num
          "" @ v-gr-name
          with frame Dialog-Frame .
  return .
  end.
  assign
      v-gr        = bf_buyer-group.bgr-id
      v-gr-db-num = bf_buyer-group.bgr-db-num
      v-gr-name   = bf_buyer-group.name
  .
  display v-gr
          v-gr-db-num
          v-gr-name
          with frame Dialog-Frame .
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
  run enable_ui in this-procedure .
  WAIT-FOR GO OF FRAME Dialog-Frame FOCUS v-name.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY v-name v-oborot v-gr v-gr-db-num v-gr-name
      WITH FRAME Dialog-Frame.
  ENABLE B-Cancel B-save B-Help v-name v-oborot r-cli v-gr v-gr-db-num
         v-gr-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE init-proc :
  if p-mode = 'ИЗМЕНЕНИЕ':U then do:
    find first  ub.buyer-group exclusive-lock where recid(ub.buyer-group) = p-recid no-error .
    if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          ""
          view-as alert-box error
        .
        return .
    end.
    assign
      v-name     =     ub.buyer-group.name
      v-oborot   =     ub.buyer-group.oborot
      v-rule-grp =     ub.buyer-group.rule-grp
      v-use-alg  =     ub.buyer-group.use-alg
      v-gr-db-num =    ub.buyer-group.gop-db-num
      v-gr        =    ub.buyer-group.gop-id
    .
define buffer bf_buyer-group for ub.buyer-group  .
display v-name
        v-oborot
        v-gr-db-num
        v-gr
        with frame Dialog-Frame .
find first bf_buyer-group no-lock where
            bf_buyer-group.bgr-id       = v-gr and
            bf_buyer-group.bgr-db-num   = v-gr-db-num
            no-error .
if available bf_buyer-group then do:
assign
    v-gr-name   = bf_buyer-group.name
.
display v-gr-db-num
        v-gr-name
        v-gr
        with frame Dialog-Frame .
  end.
  end.
END PROCEDURE.
PROCEDURE save-proc :
ASSIGN frame Dialog-Frame
        v-name
        v-oborot
        v-rule-grp
        v-use-alg
        v-gr
        v-gr-db-num
        .
if p-mode = 'ДОБАВЛЕНИЕ':U then do:
create ub.buyer-group.
assign
  ub.buyer-group.bgr-db-num   = v-cntxt-db-num
  ub.buyer-group.bgr-id       = next-value ( s-bgr , ub )
  ub.buyer-group.db-num-chg   = v-cntxt-db-num
  ub.buyer-group.gop-db-num   = v-cntxt-db-num
  ub.buyer-group.gop-id       = 0
  ub.buyer-group.stts         = 0
  ub.buyer-group.name       = v-name
  ub.buyer-group.oborot     = v-oborot
  ub.buyer-group.gop-id     = v-gr
  ub.buyer-group.gop-db-num = v-gr-db-num
  ub.buyer-group.use-alg    = v-use-alg
  p-recid = recid(ub.buyer-group)
.
end.
else do:
assign
  ub.buyer-group.db-num-chg   = v-cntxt-db-num
  ub.buyer-group.stts         = 0
  ub.buyer-group.name       = v-name
  ub.buyer-group.oborot     = v-oborot
  ub.buyer-group.gop-id     = v-gr
  ub.buyer-group.gop-db-num = v-gr-db-num
  ub.buyer-group.use-alg    = v-use-alg
  p-recid = recid(ub.buyer-group)
.
end.
END PROCEDURE.
