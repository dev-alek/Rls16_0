define input parameter p-mode               as character    no-undo.
define input parameter p-destination_rowid  as character    no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Импорт данных из РКС - диалог настройки таблиц.".
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
DEFINE BUTTON b-exit
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помощ&ь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE fi-chanal AS CHARACTER FORMAT "X(5)"
     LABEL "Канал"
     VIEW-AS FILL-IN
     SIZE 7.38 BY 1.
DEFINE VARIABLE fi-entity-th AS CHARACTER FORMAT "X(30)"
     LABEL "Сущности TH"
     VIEW-AS FILL-IN
     SIZE 29.13 BY 1.
DEFINE VARIABLE fi-id AS CHARACTER FORMAT "X(22)"
     LABEL "Идентификатор"
     VIEW-AS FILL-IN
     SIZE 29 BY 1.
DEFINE VARIABLE fi-name AS CHARACTER FORMAT "X(30)"
     LABEL "Имя объекта"
     VIEW-AS FILL-IN
     SIZE 29.13 BY 1.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1.17 COL 2
     b-help AT ROW 1.17 COL 35.5
     fi-id AT ROW 2.67 COL 1.13
     fi-name AT ROW 3.96 COL 3.13
     fi-entity-th AT ROW 5.29 COL 3.13
     fi-chanal AT ROW 6.5 COL 9.13
     SPACE(23.36) SKIP(0.78)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Имя файла"
         DEFAULT-BUTTON b-exit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
    run assign-fields in this-procedure(
          input fi-id :screen-value
        , input fi-name :screen-value
        , input fi-entity-th :screen-value
        , input fi-chanal :screen-value
        , input recid( rcs-destn )
    ) no-error.
    if error-status :error
    then do:
        message
        "Ошибка записи: " + return-value
        view-as alert-box warning.
        undo, return no-apply.
    end.
    apply "WINDOW-CLOSE" TO FRAME Dialog-Frame .
END.
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
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    if p-mode = 'добавить-узлы':U
    then do:
        do transaction:
            create rcs-destn.
            assign
                p-destination_rowid         = "<Новый идентификатор>"
                rcs-destn.destination_rowid = p-destination_rowid
            .
        end.
    end.
    else do:
        find first rcs-destn no-lock
             where rcs-destn.destination_rowid = p-destination_rowid
        no-error.
        if not available rcs-destn
        then do:
            undo, return error "Неверно выбрана запись для изменения." + chr(10) + return-value.
        end.
    end.
    RUN enable_UI.
    assign
        fi-id           = rcs-destn.destination_rowid
    .
    if p-mode <> 'добавить-узлы':U
    then do:
        assign
            fi-name         = rcs-destn.name
            fi-entity-th    = rcs-destn.entity-th
            fi-chanal       = rcs-destn.chanel
        .
    end.
    display
        fi-id
        fi-name
        fi-entity-th
        fi-chanal
    with frame Dialog-Frame.
    apply "entry" to fi-id.
    WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE assign-fields :
do
on error undo, return error
:
define input parameter p-id                 as character    no-undo.
define input parameter p-name               as character    no-undo.
define input parameter p-entity-th          as character    no-undo.
define input parameter p-chanel             as character    no-undo.
define input parameter p-current-recid      as recid        no-undo.
    define buffer buf_rcs-destn         for rcs-destn.
    define buffer buf_current_rcs-destn for rcs-destn.
    find first buf_current_rcs-destn exclusive-lock
         where recid( buf_current_rcs-destn )    = p-current-recid
    no-error .
    if not available buf_current_rcs-destn
    then do:
        undo, return error "Ошибка поиска текущей записи" + chr(10) + return-value.
    end.
    find first buf_rcs-destn no-lock
         where buf_rcs-destn.destination_rowid    = p-id
           and recid( buf_rcs-destn ) <> recid( buf_current_rcs-destn )
    no-error .
    if available buf_rcs-destn
    then do:
        undo, return error "Уже есть запись с таким идентификатором." + chr(10) + return-value.
    end.
    find first buf_rcs-destn no-lock
         where buf_rcs-destn.name    = p-name
           and recid( buf_rcs-destn ) <> recid( buf_current_rcs-destn )
    no-error .
    if available buf_rcs-destn
    then do:
        undo, return error "Уже есть запись для такого поля." + chr(10) + return-value.
    end.
    assign
        buf_current_rcs-destn.destination_rowid     = p-id
        buf_current_rcs-destn.name                  = p-name
        buf_current_rcs-destn.entity-th             = p-entity-th
        buf_current_rcs-destn.chanel                = p-chanel
    .
end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY fi-id fi-name fi-entity-th fi-chanal
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-help fi-id fi-name fi-entity-th fi-chanal
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
