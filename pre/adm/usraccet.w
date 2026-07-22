define input  parameter parParentProc  as widget-handle no-undo.
define input-output parameter p-company               LIKE ub.user-account.company NO-UNDO.
define input-output parameter p-department            LIKE ub.user-account.department NO-UNDO.
define input-output parameter p-e-mail                LIKE ub.user-account.e-mail NO-UNDO.
define input-output parameter p-first-name            LIKE ub.user-account.first-name NO-UNDO.
define input-output parameter p-internal-phone-number LIKE ub.user-account.internal-phone-number NO-UNDO.
define input-output parameter p-last-name             LIKE ub.user-account.last-name NO-UNDO.
define input-output parameter p-mobile-phone-number   LIKE ub.user-account.mobile-phone-number NO-UNDO.
define input-output parameter p-phone-number          LIKE ub.user-account.phone-number NO-UNDO.
define input-output parameter p-position              LIKE ub.user-account.position NO-UNDO.
define input-output parameter p-room                  LIKE ub.user-account.room NO-UNDO.
define input-output parameter p-second-name           LIKE ub.user-account.second-name NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование записи пользователь (temp-table)".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR BLACK_COLOR        AS INTEGER NO-UNDO INIT  0.
DEF VAR DARK_BLUE_COLOR    AS INTEGER NO-UNDO INIT  1.
DEF VAR DARK_GREEN_COLOR   AS INTEGER NO-UNDO INIT  2.
DEF VAR CYAN_COLOR         AS INTEGER NO-UNDO INIT  3.
DEF VAR BROWN_COLOR        AS INTEGER NO-UNDO INIT  4.
DEF VAR DARK_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR DARK_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR GRAY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR GREY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR BLUE_COLOR         AS INTEGER NO-UNDO INIT  9.
DEF VAR GREEN_COLOR        AS INTEGER NO-UNDO INIT 10.
DEF VAR RED_COLOR          AS INTEGER NO-UNDO INIT 12.
DEF VAR LIGHT_RED_COLOR    AS INTEGER NO-UNDO INIT 13.
DEF VAR YELLOW_COLOR       AS INTEGER NO-UNDO INIT 14.
DEF VAR WHITE_COLOR        AS INTEGER NO-UNDO INIT 15.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE fi-company LIKE ub.user-account.company
     VIEW-AS FILL-IN
     SIZE 33 BY 1 NO-UNDO.
DEFINE VARIABLE fi-department LIKE ub.user-account.department
     VIEW-AS FILL-IN
     SIZE 33 BY 1 NO-UNDO.
DEFINE VARIABLE fi-e-mail LIKE ub.user-account.e-mail
     VIEW-AS FILL-IN
     SIZE 33 BY 1 NO-UNDO.
DEFINE VARIABLE fi-first-name LIKE ub.user-account.first-name
     VIEW-AS FILL-IN
     SIZE 33 BY 1 NO-UNDO.
DEFINE VARIABLE fi-internal-phone-number LIKE ub.user-account.internal-phone-number
     VIEW-AS FILL-IN
     SIZE 33 BY 1 NO-UNDO.
DEFINE VARIABLE fi-last-name LIKE ub.user-account.last-name
     VIEW-AS FILL-IN
     SIZE 33 BY 1 NO-UNDO.
DEFINE VARIABLE fi-mobile-phone-number LIKE ub.user-account.mobile-phone-number
     VIEW-AS FILL-IN
     SIZE 33 BY 1 NO-UNDO.
DEFINE VARIABLE fi-phone-number LIKE ub.user-account.phone-number
     VIEW-AS FILL-IN
     SIZE 33 BY 1 NO-UNDO.
DEFINE VARIABLE fi-position LIKE ub.user-account.position
     VIEW-AS FILL-IN
     SIZE 33 BY 1 NO-UNDO.
DEFINE VARIABLE fi-room LIKE ub.user-account.room
     VIEW-AS FILL-IN
     SIZE 33 BY 1 NO-UNDO.
DEFINE VARIABLE fi-second-name LIKE ub.user-account.second-name
     VIEW-AS FILL-IN
     SIZE 33 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 81
     fi-last-name AT ROW 4 COL 22 COLON-ALIGNED HELP
          "" WIDGET-ID 4
     fi-first-name AT ROW 5.27 COL 22 COLON-ALIGNED HELP
          "" WIDGET-ID 10
     fi-second-name AT ROW 6.77 COL 22 COLON-ALIGNED HELP
          "" WIDGET-ID 8
     fi-position AT ROW 8.27 COL 22 COLON-ALIGNED HELP
          "" WIDGET-ID 12
     fi-room AT ROW 9.77 COL 22 COLON-ALIGNED HELP
          "" WIDGET-ID 14
     fi-company AT ROW 11 COL 22 COLON-ALIGNED HELP
          "" WIDGET-ID 16
     fi-department AT ROW 12.27 COL 22 COLON-ALIGNED HELP
          "" WIDGET-ID 18
     fi-e-mail AT ROW 13.5 COL 22 COLON-ALIGNED HELP
          "" WIDGET-ID 20
     fi-phone-number AT ROW 14.77 COL 22 COLON-ALIGNED HELP
          "" WIDGET-ID 22
     fi-internal-phone-number AT ROW 16 COL 22 COLON-ALIGNED HELP
          "" WIDGET-ID 24
     fi-mobile-phone-number AT ROW 17.5 COL 22 COLON-ALIGNED HELP
          "" WIDGET-ID 26
     SPACE(34.00) SKIP(0.00)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Редактирование пользователя"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  run update-info in this-procedure
    no-error .
  if error-status :error
  then do:
    undo, return no-apply .
  end.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON LEAVE OF fi-last-name IN FRAME Dialog-Frame
DO:
  IF fi-last-name :screen-value = ?
  OR fi-last-name :screen-value = '':U
  THEN DO:
    MESSAGE "Фамилию заполнять обязательно"
    VIEW-AS ALERT-BOX.
    undo, return no-apply .
  END.
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
DO ON ERROR   UNDO MAIN-BLOCK, RETURN ERROR
   ON END-KEY UNDO MAIN-BLOCK, RETURN ERROR:
  RUN enable_UI.
  run display-info in this-procedure .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE display-info :
  do
  with frame Dialog-Frame
  on error undo, return error return-value
  :
     assign
       fi-last-name :screen-value             = p-last-name
       fi-first-name :screen-value            = p-first-name
       fi-second-name :screen-value           = p-second-name
       fi-position :screen-value              = p-position
       fi-room :screen-value                  = p-room
       fi-company :screen-value               = p-company
       fi-department :screen-value            = p-department
       fi-e-mail :screen-value                = p-e-mail
       fi-phone-number :screen-value          = p-phone-number
       fi-internal-phone-number :screen-value = p-internal-phone-number
       fi-mobile-phone-number :screen-value   = p-mobile-phone-number
       fi-last-name             :sensitive = true
       fi-last-name             :fgcolor   = black_color
       fi-first-name            :sensitive = true
       fi-first-name            :fgcolor   = black_color
       fi-second-name           :sensitive = true
       fi-second-name           :fgcolor   = black_color
       fi-position              :sensitive = true
       fi-position              :fgcolor   = black_color
       fi-room                  :sensitive = true
       fi-room                  :fgcolor   = black_color
       fi-company               :sensitive = true
       fi-company               :fgcolor   = black_color
       fi-department            :sensitive = true
       fi-department            :fgcolor   = black_color
       fi-e-mail                :sensitive = true
       fi-e-mail                :fgcolor   = black_color
       fi-phone-number          :sensitive = true
       fi-phone-number          :fgcolor   = black_color
       fi-internal-phone-number :sensitive = true
       fi-internal-phone-number :fgcolor   = black_color
       fi-mobile-phone-number   :sensitive = true
       fi-mobile-phone-number   :fgcolor   = black_color
     .
  end.
END PROCEDURE.
PROCEDURE enable_UI :
  ENABLE b-exit b-quit b-help
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE update-info :
  do
  on error undo, return error return-value
  :
     do with frame Dialog-Frame
     :
         assign
           p-last-name             = fi-last-name :screen-value
           p-first-name            = fi-first-name :screen-value
           p-second-name           = fi-second-name :screen-value
           p-position              = fi-position :screen-value
           p-room                  = fi-room :screen-value
           p-company               = fi-company :screen-value
           p-department            = fi-department :screen-value
           p-e-mail                = fi-e-mail :screen-value
           p-phone-number          = fi-phone-number :screen-value
           p-internal-phone-number = fi-internal-phone-number :screen-value
           p-mobile-phone-number   = fi-mobile-phone-number :screen-value
         .
     end.
  end.
END PROCEDURE.
