define input-output parameter par-fname    as character format "x(80)" no-undo.
define       output parameter par-clearcnf as logical   initial false  no-undo.
define       output parameter par-uselast  as logical   initial true   no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Экспорт конфигурационных параметров".
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
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод ":L
     SIZE 10 BY 1.
DEFINE BUTTON b-file
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U NO-FOCUS
     LABEL "b-file"
     SIZE 2.88 BY .92.
DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 10 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена":L
     SIZE 10 BY 1.
DEFINE VARIABLE FName AS CHARACTER FORMAT "X(256)":U
     LABEL "Имя файла"
     VIEW-AS FILL-IN NATIVE
     SIZE 51.13 BY 1 TOOLTIP "Имя файла конфигурации" NO-UNDO.
DEFINE VARIABLE ClearCnf AS LOGICAL INITIAL no
     LABEL "Удалить существующие"
     VIEW-AS TOGGLE-BOX
     SIZE 30.25 BY .83 TOOLTIP "Существующий набор параметров будет полностью удален" NO-UNDO.
DEFINE VARIABLE UseLast AS LOGICAL INITIAL yes
     LABEL "Заменять дублируемые"
     VIEW-AS TOGGLE-BOX
     SIZE 25.75 BY .83 TOOLTIP "Параметры из импортируемого файла заменят ранее существующие" NO-UNDO.
DEFINE FRAME d-cnf
     b-exit AT ROW 1 COL 2
     b-quit AT ROW 1 COL 12
     b-help AT ROW 1 COL 60
     ClearCnf AT ROW 3 COL 14
     UseLast AT ROW 4 COL 14
     FName AT ROW 5 COL 12 COLON-ALIGNED
     b-file AT ROW 5 COL 66
     SPACE(1.49) SKIP(0.65)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Импорт конфигурации":L.
ASSIGN
       FRAME d-cnf:SCROLLABLE       = FALSE.
ASSIGN
       ClearCnf:AUTO-RESIZE IN FRAME d-cnf      = TRUE.
ON CHOOSE OF b-exit IN FRAME d-cnf
DO:
  assign
    UseLast
    ClearCnf
    fname
  .
  assign
    par-fname = fname
    par-clearcnf = ClearCnf
    par-uselast = UseLast
  .
END.
ON CHOOSE OF b-file IN FRAME d-cnf
DO:
    define variable is-choosen as logical no-undo.
    SYSTEM-DIALOG GET-FILE fname
    FILTERS "Файлы конфигурации *.cfg" "*.cfg",
            "Все файлы"  "*.*"
    must-exist
    TITLE "Выберите файл для импорта конфигурации"
    USE-FILENAME
    UPDATE is-choosen.
    if is-choosen then do:
       display
         fname
         with frame d-cnf.
    end.
END.
ON CHOOSE OF b-quit IN FRAME d-cnf
DO:
  par-fname = "".
END.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-cnf
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
on choose of b-help in frame d-cnf
do:
  apply "help":u to frame d-cnf .
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
                v-frame-width = frame d-cnf:width - 0.3
                fh            = frame d-cnf:first-child
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
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME d-cnf:PARENT eq ?
THEN FRAME d-cnf:PARENT = ACTIVE-WINDOW.
define variable cur-der as logical no-undo.
  cur-der = session:data-entry-return.
  session:data-entry-return = yes.
fname = search (par-fname).
if fname <> ? then par-fname = fname.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   run enable_UI.
   WAIT-FOR GO OF FRAME d-cnf.
END.
RUN disable_UI.
session:data-entry-return = cur-der .
PROCEDURE disable_UI :
  HIDE FRAME d-cnf.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY ClearCnf UseLast FName
      WITH FRAME d-cnf.
  ENABLE b-exit b-quit b-help ClearCnf UseLast FName b-file
      WITH FRAME d-cnf.
END PROCEDURE.
