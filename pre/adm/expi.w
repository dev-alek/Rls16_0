define input        parameter p-standalone as logical                  no-undo .
define input        parameter p-selected   as logical                  no-undo .
define input-output parameter p-fname      as character format "x(80)" no-undo .
define input        parameter p-db-list    as character                no-undo .
define       output parameter p-sel-dbs    as character                no-undo .
define       output parameter p-exp-type   as character                no-undo .
define       output parameter p-new-db-num as integer                  no-undo .
define       output parameter p-new-db-key as character                no-undo .
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
define  shared temp-table cnf no-undo
    field param-code    as character   format "x(8)"        column-label "Код"                               field param-type    as character                        column-label "Тип"                               field param-value   as character   format "x(250)"      column-label "Значение"                          field param-encoded as character                        column-label "Кодированное значение"             field host-code     as integer                          column-label "Фирма"                             field obj-type      as character                        column-label "Тип объекта"                       field obj-code      as integer     format ">>>>>>"      column-label "Код объекта"                       field conf-type     as character                        column-label "Кодировка"                         field beg-date      as date                             column-label "Начало действия параметра"         field end-date      as date                             column-label "Окончание действия параметра"      field db-num        as integer     format ">>>>>"       column-label "БД"                                field stts          as integer                          column-label "Статус"
    field db-key        as character   format "x(12)"       column-label "Ключ БД"
    field param-PS      as character   format "x(40)"       column-label "PS"
    field param-name    as character   format "x(30)"       column-label "Название"
    field is-changed    as logical initial false            column-label "Изменен"
    field NotUsed       as logical initial False            column-label "Выключен"
    field ErrorExist    as integer initial 0  format ">>"   column-label "Уровень ошибки"
    index pi
      is unique
      param-code
      host-code
      obj-type
      obj-code
      beg-date
      end-date
      db-num
    index db-num
      db-num
    index db-key
      db-key
    index par-name
      is word-index
      param-name
    index par-value
      is word-index
      param-value
 .
def  shared temp-table log-table no-undo
    field stroka       as character format "x(256)".
def  shared variable err-level as integer no-undo.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод ":L
     SIZE 9 BY 1.
DEFINE BUTTON b-file
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U NO-FOCUS
     LABEL "b-file"
     SIZE 3 BY .88 TOOLTIP "Вызов окна выбора файла".
DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 3 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена":L
     SIZE 9 BY 1.
DEFINE VARIABLE f-new-db-key LIKE ub.db.db-key
     LABEL "Ключ новой БД"
     FORMAT "X(25)"
     VIEW-AS FILL-IN
     SIZE 9 BY 1 NO-UNDO.
DEFINE VARIABLE f-new-db-num LIKE ub.db.db-num
     LABEL "Номер новой БД"
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.
DEFINE VARIABLE FName AS CHARACTER FORMAT "X(256)":U
     LABEL "Имя файла"
     VIEW-AS FILL-IN NATIVE
     SIZE 56 BY 1 TOOLTIP "Файл конфигурации" NO-UNDO.
DEFINE VARIABLE export-type AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все включенные", "all",
"Текущий", "curr",
"Отмеченные", "mark",
"Все кодированные", "all-protect",
"Все обязательные", "all-mandatory"
     SIZE 19.63 BY 4 NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 71.5 BY 9.5.
DEFINE VARIABLE sel-dbs AS CHARACTER
     VIEW-AS SELECTION-LIST MULTIPLE SORT SCROLLBAR-VERTICAL
     SIZE 9.5 BY 7.5 NO-UNDO.
DEFINE VARIABLE t-for-db AS LOGICAL INITIAL no
     LABEL "Для новой БД"
     VIEW-AS TOGGLE-BOX
     SIZE 16 BY 1 NO-UNDO.
DEFINE FRAME d-cnf
     b-file AT ROW 2.5 COL 70
     b-exit AT ROW 1 COL 2
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 70
     FName AT ROW 2.5 COL 11.5 COLON-ALIGNED
     export-type AT ROW 5 COL 3.5 NO-LABEL
     sel-dbs AT ROW 5.25 COL 34.5 NO-LABEL WIDGET-ID 4
     t-for-db AT ROW 9.5 COL 4 WIDGET-ID 8
     f-new-db-num AT ROW 10.5 COL 19 COLON-ALIGNED HELP
          "" WIDGET-ID 10
          LABEL "Номер новой БД"
     f-new-db-key AT ROW 11.5 COL 19 COLON-ALIGNED HELP
          "" WIDGET-ID 12
          LABEL "Ключ новой БД"
     "Выводить параметры:" VIEW-AS TEXT
          SIZE 19.88 BY .67 AT ROW 4 COL 2.5
     "БД:" VIEW-AS TEXT
          SIZE 4 BY .67 AT ROW 5.25 COL 29.5 WIDGET-ID 6
     RECT-1 AT ROW 3.75 COL 1.5 WIDGET-ID 2
     SPACE(0.87) SKIP(0.32)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Экспорт конфигурационных параметров":L.
ASSIGN
       FRAME d-cnf:SCROLLABLE       = FALSE.
ASSIGN
       f-new-db-key:HIDDEN IN FRAME d-cnf           = TRUE.
ASSIGN
       f-new-db-num:HIDDEN IN FRAME d-cnf           = TRUE.
ON CHOOSE OF b-exit IN FRAME d-cnf
DO:
  ASSIGN
    export-type
    FName
    t-for-db
    f-new-db-num
    f-new-db-key
  .
  if ( sel-dbs:screen-value = ?
       or sel-dbs:screen-value = "":U
     )
    and export-type <> "curr":U
  then do:
    message
      "Необходимо выбрать хотя бы одну БД параметры которой будут выгружаться !"
      view-as alert-box.
    return no-apply .
  end.
  if t-for-db = true
    and num-entries( sel-dbs :screen-value ) > 1
  then do:
    message
      substitute("При выгрузке параметров для новой БД допускается выбирать только одну БД источник!") skip
      view-as alert-box error .
    return no-apply .
  end.
  if trim( FName ) = "":U then do:
    message
      "Необходимо указать имя файла в который будут выгружаться параметры !"
      view-as alert-box.
    return no-apply .
  end.
  assign
    p-fname    = fname
    p-exp-type = export-type
    p-sel-dbs  = sel-dbs:screen-value
  .
  if t-for-db = true then do:
    assign
      p-new-db-num = f-new-db-num
      p-new-db-key = f-new-db-key
    .
  end.
  else do:
    assign
      p-new-db-num = ?
      p-new-db-key = "":U
    .
  end.
END.
ON CHOOSE OF b-file IN FRAME d-cnf
DO:
  define variable is-choosen as logical no-undo.
  SYSTEM-DIALOG GET-FILE Fname
  FILTERS "Файлы конфигурации *.cfg" "*.cfg",
          "Все файлы"  "*.*"
  ASK-OVERWRITE
  CREATE-TEST-FILE
  DEFAULT-EXTENSION "*.cfg"
  SAVE-AS
  TITLE "Выберите файл для вывода конфигурации"
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
  assign
    p-exp-type = ?
    p-fname    = ?
  .
END.
ON RETURN OF export-type IN FRAME d-cnf
DO:
  apply "TAB" to export-type.
END.
ON VALUE-CHANGED OF export-type IN FRAME d-cnf
DO:
  assign
    export-type
  .
  if export-type = "curr":U then do:
    disable
      sel-dbs
      with frame d-cnf.
  end.
  else do:
    enable
      sel-dbs
      with frame d-cnf.
  end.
END.
ON VALUE-CHANGED OF t-for-db IN FRAME d-cnf
DO:
  assign
    t-for-db
  .
  if t-for-db = true then do:
    enable
      f-new-db-num
      f-new-db-key
      with frame d-cnf.
  end.
  else do:
    disable
      f-new-db-num
      f-new-db-key
      with frame d-cnf.
    hide
      f-new-db-num
      f-new-db-key
      in frame d-cnf.
  end.
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
assign
  cur-der                   = session:data-entry-return
  session:data-entry-return = yes
.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  define variable v-log         as logical   no-undo .
  assign
    fname      = p-fname
    p-exp-type = ?
  .
  run enable_UI.
  if p-db-list <> "":U then do:
    sel-dbs :list-items in frame d-cnf = p-db-list  .
  end.
  if p-selected = FALSE then do:
    assign
      v-log = export-type:disable( "Текущий" )
    .
  end.
  apply "entry" to export-type.
  WAIT-FOR GO OF FRAME d-cnf.
END.
RUN disable_UI.
assign
  session:data-entry-return = cur-der
.
PROCEDURE disable_UI :
  HIDE FRAME d-cnf.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY FName export-type sel-dbs t-for-db
      WITH FRAME d-cnf.
  ENABLE b-file b-exit b-quit b-help RECT-1 FName export-type sel-dbs t-for-db
      WITH FRAME d-cnf.
END PROCEDURE.
