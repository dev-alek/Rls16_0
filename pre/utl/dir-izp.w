define output parameter p-source-dir as character no-undo .
define output parameter p-archive-dir as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Директории Импорта НАКЛАДНЫХ".
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
p-source-dir  = ?.
p-archive-dir = ?.
define stream test2.
define variable v-old-source-dir as character no-undo .
define variable v-old-archive-dir as character no-undo .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-save AUTO-GO DEFAULT
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-sel-archive-dir DEFAULT
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE-PIXELS 20 BY 26.
DEFINE BUTTON b-sel-source-dir DEFAULT
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE-PIXELS 20 BY 26.
DEFINE VARIABLE v-archive-dir AS CHARACTER FORMAT "X(256)":U
     LABEL "Директория архив"
     VIEW-AS FILL-IN
     SIZE 38 BY 1 NO-UNDO.
DEFINE VARIABLE v-source-dir AS CHARACTER FORMAT "X(256)":U
     LABEL "Директория источник"
     VIEW-AS FILL-IN
     SIZE 38 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-save AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 77
     b-sel-source-dir AT Y 48 X 548
     v-source-dir AT ROW 3.04 COL 9.5
     b-sel-archive-dir AT Y 76 X 548
     v-archive-dir AT ROW 4.25 COL 28.5 COLON-ALIGNED
     SPACE(18.74) SKIP(1.78)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Директории обмена c import-rash"
         CANCEL-BUTTON B-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-quit IN FRAME Dialog-Frame
DO:
          p-source-dir  = ?.
          p-archive-dir = ?.
END.
ON CHOOSE OF b-save IN FRAME Dialog-Frame
DO:
  assign
    v-source-dir
    v-archive-dir
  .
    p-source-dir  =  v-source-dir  .
    p-archive-dir =  v-archive-dir .
  run check-dir ( input-output v-source-dir ) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      return-value skip
      error-status :get-message(0) skip
      error-status :get-message(1)
      view-as alert-box error.
      p-source-dir  = ?.
      p-archive-dir = ?.
    return no-apply.
  end.
  else do:
    if v-source-dir <> v-old-source-dir then do:
      put-key-value section "import-rash":U key "import-rash-source-dir":U value v-source-dir  no-error.
      if error-status:error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Файл настроек progress доступен только для чтения!" skip
          "Сохранение параметров невозможно."
          view-as alert-box error.
        return no-apply.
      end.
    end.
  end.
  run check-dir ( input-output v-archive-dir ) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      return-value skip
      error-status :get-message(0) skip
      error-status :get-message(1)
      view-as alert-box error.
      p-source-dir  = ?.
      p-archive-dir = ?.
    return no-apply.
  end.
  else do:
    if v-archive-dir <> v-old-archive-dir then do:
      put-key-value section "import-rash":U key "import-rash-archive-dir":U value v-archive-dir .
      if error-status:error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Файл настроек progress доступен только для чтения!" skip
          "Сохранение параметров невозможно."
          view-as alert-box error.
        return no-apply.
      end.
    end.
  end.
p-source-dir  =  v-source-dir  .
p-archive-dir =  v-archive-dir .
END.
ON CHOOSE OF b-sel-archive-dir IN FRAME Dialog-Frame
DO:
  define variable v-dir-name  as character no-undo .
  define variable v-type      as character no-undo .
  define variable v-can-write as logical   no-undo .
  run gbl/dir-sel.p ( output v-dir-name
                 ,output v-type
                 ,output v-can-write
                ).
  if v-can-write then do:
    assign
      v-archive-dir = v-dir-name
    .
    display
      v-archive-dir
      with frame Dialog-Frame
    .
  end.
  APPLY "ENTRY" TO v-archive-dir IN FRAME Dialog-Frame .
END.
ON CHOOSE OF b-sel-source-dir IN FRAME Dialog-Frame
DO:
  define variable v-dir-name  as character no-undo .
  define variable v-type      as character no-undo .
  define variable v-can-write as logical   no-undo .
  run gbl/dir-sel.p ( output v-dir-name
                 ,output v-type
                 ,output v-can-write
                ).
  if v-can-write then do:
    assign
      v-source-dir = v-dir-name
    .
    display
      v-source-dir
      with frame Dialog-Frame
    .
  end.
  APPLY "ENTRY" TO v-source-dir IN FRAME Dialog-Frame .
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
get-key-value section "import-rash":U key "import-rash-source-dir":U value v-source-dir .
get-key-value section "import-rash":U key "import-rash-archive-dir":U value v-archive-dir .
if v-source-dir = ? then do:
  assign
    v-source-dir = "":U
  .
end.
if v-archive-dir = ? then do:
  assign
    v-archive-dir = "":U
  .
end.
assign
  v-old-source-dir = v-source-dir
  v-old-archive-dir = v-archive-dir
.
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE check-dir :
define input-output parameter p-dir-name as character no-undo .
do
on error undo, return error
:
  define variable v-log as logical no-undo .
  assign
    file-info:file-name = p-dir-name
  .
  if file-info:file-type <> ?
    and index( file-info:file-type, "D":U ) <> 0
  then do:
    output stream test2 to "test2.tst":U .
    put stream test2 unformatted "test2":U skip.
    output stream test2 close.
    os-copy "test2.tst":U value( p-dir-name ) .
    if os-error <> 0 then do:
      return error string( "Каталог" + chr(32) + p-dir-name + chr(32)
                           + "недоступен для чтения и(или) записи!"
                           + chr(10) + "Сохранение параметров невозможно."
                         ).
    end.
    else do:
      os-delete value( "test2.tst":U ) .
      os-delete value( p-dir-name + chr(92) + "test2.tst":U ) .
    end.
  end.
  else do:
    message
      "Каталог" p-dir-name "не существует!" skip
      "Cоздать его?"
      view-as alert-box information buttons yes-no update v-log.
    if v-log = false then do:
      return error substitute( "Отказ от создания каталога!" ).
    end.
    else do:
      run gbl/dir-cre.p ( input p-dir-name ) no-error .
      if error-status:error then do:
        return error substitute( "Ошибка при создании каталога &1&2&3", p-dir-name, chr(10), return-value ).
      end.
    end.
  end.
  assign
    file-info:file-name = p-dir-name
  .
  if file-info:file-type <> ? then do:
    assign
      p-dir-name = file-info:full-pathname
    .
  end.
end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY v-source-dir v-archive-dir
      WITH FRAME Dialog-Frame.
  ENABLE b-save B-quit B-Help b-sel-source-dir v-source-dir b-sel-archive-dir
         v-archive-dir
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
