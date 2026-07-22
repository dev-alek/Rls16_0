define input  parameter parparentproc               as widget-handle no-undo .
define input  parameter p-input-mode                as character no-undo .
define input-output parameter p-db-num                    as integer   no-undo .
define input  parameter p-user-id                   as character no-undo .
define input  parameter p-user-login                as character no-undo .
define input  parameter p-user-administrator        as logical   no-undo .
define input  parameter p-max-discnt                as decimal   no-undo .
define input  parameter p-quest-print               as logical   no-undo .
define output parameter v-update-data               as logical   no-undo .
define output parameter v-output-user-login         as character no-undo .
define output parameter v-output-user-administrator as logical   no-undo .
define output parameter v-output-max-discnt         as decimal   no-undo .
define output parameter v-output-quest-print        as logical   no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование данных для логина пользователя".
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
DEFINE BUTTON b-choice-bd
     LABEL "Выбор"
     SIZE 11 BY 1.
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
DEFINE VARIABLE fi-db-num LIKE user-login.db-num
     VIEW-AS FILL-IN
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-max-discnt LIKE user-login.max-discnt
     VIEW-AS FILL-IN
     SIZE 7 BY 1 NO-UNDO.
DEFINE VARIABLE fi-user-id LIKE user-login.user-id
     VIEW-AS FILL-IN
     SIZE 16 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-user-login LIKE user-login.user-login
     VIEW-AS FILL-IN
     SIZE 13 BY 1 NO-UNDO.
DEFINE VARIABLE fi-user-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 79 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE t-quest-print LIKE user-login.quest-print
     VIEW-AS TOGGLE-BOX
     SIZE 43.13 BY .83 NO-UNDO.
DEFINE VARIABLE t-user-administrator LIKE user-login.user-administrator
     VIEW-AS TOGGLE-BOX
     SIZE 16.13 BY .83 NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 73
     fi-db-num AT ROW 2.75 COL 25.5 COLON-ALIGNED HELP
          "" WIDGET-ID 2
          FGCOLOR 4
     b-choice-bd AT ROW 2.75 COL 37.5 WIDGET-ID 20
     fi-user-id AT ROW 4 COL 25.5 COLON-ALIGNED HELP
          "" WIDGET-ID 4
          FGCOLOR 4
     fi-user-login AT ROW 6.75 COL 25.5 COLON-ALIGNED HELP
          "" WIDGET-ID 6
     t-user-administrator AT ROW 8 COL 27.5 HELP
          "" WIDGET-ID 14
     fi-max-discnt AT ROW 9 COL 25.5 COLON-ALIGNED HELP
          "" WIDGET-ID 10
     t-quest-print AT ROW 10.25 COL 27.5 HELP
          "" WIDGET-ID 16
     fi-user-name AT ROW 5.25 COL 1.5 COLON-ALIGNED NO-LABEL WIDGET-ID 18
     SPACE(1.62) SKIP(6.36)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Логин пользователя"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       t-user-administrator:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  run update-record in this-procedure
    no-error .
  if error-status :error
  then do:
    return no-apply .
  end.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-choice-bd IN FRAME Dialog-Frame
DO:
  define variable ri as recid no-undo.
  define buffer buf_db for ub.db.
  run adm/dbs.w (
                input parparentproc
               ,input 'ПРОСМОТР':U
               ,output ri) no-error.
  if ri <> ?
  then do:
    find buf_db where recid (buf_db) = ri .
    display
    buf_db.db-num @ fi-db-num
    with frame Dialog-Frame.
    assign
       fi-db-num = buf_db.db-num.
  end.
  else do:
    assign
      fi-db-num = ?
      p-db-num  = ?.
    display
    ? @ fi-db-num
    with frame Dialog-Frame.
  end.
END.
ON VALUE-CHANGED OF fi-db-num IN FRAME Dialog-Frame
DO:
    assign
        fi-db-num
    .
END.
ON LEAVE OF fi-db-num IN FRAME Dialog-Frame
DO:
  define buffer buf_db for ub.db.
  if fi-db-num <> ? and
   not can-find (buf_db where buf_db.db-num = input frame Dialog-Frame fi-db-num no-lock ) then do:
    message "Нет БД с таким номером."
            view-as alert-box error.
    assign
      fi-db-num = ?
      p-db-num  = ?.
    display
    ? @ fi-db-num
    with frame Dialog-Frame.
  end.
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
  RUN enable_UI.
  run display-data in this-procedure .
  run enable-fields in this-procedure .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE display-data :
  define buffer buf_user-account for ub.user-account .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      assign
        fi-user-id            = p-user-id
        fi-user-login         = p-user-login
        t-user-administrator  = p-user-administrator
        fi-max-discnt         = p-max-discnt
        t-quest-print         = p-quest-print
      .
      if p-db-num ne ? then do:
        fi-db-num = p-db-num .
      end.
      display
        fi-db-num    when p-db-num ne ?
        fi-user-id
        fi-user-login
        fi-max-discnt
        t-quest-print
        with frame Dialog-Frame .
        b-choice-bd:visible = p-db-num ne ?.
        fi-db-num:visible   = p-db-num ne ?.
    end.
  end.
END PROCEDURE.
PROCEDURE enable-fields :
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      if p-input-mode = 'ИЗМЕНЕНИЕ':U
      then do:
        assign
          fi-user-login        :sensitive = true
          t-user-administrator :sensitive = true
          fi-max-discnt        :sensitive = true
          t-quest-print        :sensitive = true
        .
      end.
      else do:
        assign
          fi-user-login        :sensitive = false
          t-user-administrator :sensitive = false
          fi-max-discnt        :sensitive = false
          t-quest-print        :sensitive = false
          t-user-administrator :HIDDEN    = false
        .
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY fi-db-num fi-user-id fi-user-login fi-max-discnt t-quest-print
          fi-user-name
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit b-help fi-db-num b-choice-bd fi-user-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE update-record :
  define buffer buf_user-login for ub.user-login .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      assign
        fi-user-login
        fi-max-discnt
        t-quest-print
      .
      if fi-user-login = ?
      or fi-user-login = '':U
      then do:
        message
          "Необходимо ввести логин пользователя" skip
          view-as alert-box error .
        apply 'entry':U to fi-user-login .
        undo, return error return-value .
      end.
      if     p-db-num  ne ?
         and fi-db-num eq ?
      then do:
        message
          "Необходимо ввести номер базы данных" skip
          view-as alert-box error .
        apply 'entry':U to fi-db-num .
        undo, return error return-value .
      end.
      find first buf_user-login no-lock
        where buf_user-login.db-num = fi-db-num
          and buf_user-login.user-login = fi-user-login
          and buf_user-login.user-id <> p-user-id
        no-error .
      if available buf_user-login
      then do:
        message
          "У другого пользователя уже существует логин" fi-user-login skip
          "для БД" fi-db-num SKIP
          view-as alert-box error .
        apply 'entry':U to fi-user-login .
        undo, return error return-value .
      end.
      assign
        v-update-data               = true
        v-output-user-login         = fi-user-login
        v-output-user-administrator = t-user-administrator
        v-output-max-discnt         = fi-max-discnt
        v-output-quest-print        = t-quest-print
        p-db-num                    = fi-db-num
      .
    end.
  end.
END PROCEDURE.
