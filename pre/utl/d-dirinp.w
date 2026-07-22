define input-output parameter p-dir1 as character no-undo .
define input-output parameter p-dir2 as character no-undo .
define input-output parameter p-dir3 as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Запрашивает три директории".
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
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "Отка&з"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-sel-dir1
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b sel dir 1"
     SIZE 3 BY .87.
DEFINE BUTTON b-sel-dir2
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b sel dir 2"
     SIZE 3 BY .87.
DEFINE BUTTON b-sel-dir3
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b sel dir 2"
     SIZE 3 BY .87.
DEFINE VARIABLE fi-dir1 AS CHARACTER FORMAT "X(256)":U
     LABEL "Старая"
     VIEW-AS FILL-IN
     SIZE 60.8 BY 1 NO-UNDO.
DEFINE VARIABLE fi-dir2 AS CHARACTER FORMAT "X(256)":U
     LABEL "Новая"
     VIEW-AS FILL-IN
     SIZE 60.9 BY 1 NO-UNDO.
DEFINE VARIABLE fi-dir3 AS CHARACTER FORMAT "X(256)":U
     LABEL "Пакет обновления"
     VIEW-AS FILL-IN
     SIZE 60.8 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 21
     fi-dir1 AT ROW 2.6 COL 15
     b-sel-dir1 AT ROW 2.63 COL 84.8
     fi-dir2 AT ROW 4.13 COL 21 COLON-ALIGNED
     b-sel-dir2 AT ROW 4.17 COL 85
     fi-dir3 AT ROW 5.63 COL 21 COLON-ALIGNED
     b-sel-dir3 AT ROW 5.7 COL 85.1
     SPACE(8.89) SKIP(0.69)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Сравнение директорий *.r кодов"
         CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  run validate-dir in this-procedure
    (input fi-dir1 :screen-value
    ,input fi-dir2 :screen-value
    ,input fi-dir3 :screen-value
    ) no-error .
  if error-status :error
  then do:
    if return-value <> ""
    then do:
      case return-value :
        when "p-dir1"
        then do:
          apply "entry":u to fi-dir1 .
        end.
        when "p-dir2"
        then do:
          apply "entry":u to fi-dir2 .
        end.
        when "p-dir3"
        then do:
          apply "entry":u to fi-dir3 .
        end.
      end.
    end.
    undo, return no-apply .
  end.
  assign
    p-dir1 = fi-dir1 :screen-value
    p-dir2 = fi-dir2 :screen-value
    p-dir3 = fi-dir3 :screen-value
  .
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-sel-dir1 IN FRAME Dialog-Frame
DO:
define variable vss-include-info0 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  define variable v-dir-name  as character no-undo .
  define variable v-dir-type  as character no-undo .
  define variable v-can-write as logical   no-undo .
  run gbl/dir-sel.p
    (output v-dir-name
    ,output v-dir-type
    ,output v-can-write
    ) .
  if v-dir-name <> ""
  then do:
    assign
      fi-dir1 :screen-value = v-dir-name
    .
  end.
END.
ON CHOOSE OF b-sel-dir2 IN FRAME Dialog-Frame
DO:
define variable vss-include-info1 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  define variable v-dir-name  as character no-undo .
  define variable v-dir-type  as character no-undo .
  define variable v-can-write as logical   no-undo .
  run gbl/dir-sel.p
    (output v-dir-name
    ,output v-dir-type
    ,output v-can-write
    ) .
  if v-dir-name <> ""
  then do:
    assign
      fi-dir2 :screen-value = v-dir-name
    .
  end.
END.
ON CHOOSE OF b-sel-dir3 IN FRAME Dialog-Frame
DO:
define variable vss-include-info2 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  define variable v-dir-name  as character no-undo .
  define variable v-dir-type  as character no-undo .
  define variable v-can-write as logical   no-undo .
  run gbl/dir-sel.p
    (output v-dir-name
    ,output v-dir-type
    ,output v-can-write
    ) .
  if v-dir-name <> ""
  then do:
    assign
      fi-dir3 :screen-value = v-dir-name
    .
  end.
END.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  RUN enable_UI.
  assign
    fi-dir1 :screen-value = p-dir1
    fi-dir2 :screen-value = p-dir2
    fi-dir3 :screen-value = p-dir3
  .
  assign
    p-dir1 = ""
    p-dir2 = ""
    p-dir3 = ""
  .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY fi-dir1 fi-dir2 fi-dir3
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit b-help fi-dir1 b-sel-dir1 fi-dir2 b-sel-dir2 fi-dir3
         b-sel-dir3
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE validate-dir :
  define input  parameter p-dir1 as character no-undo .
  define input  parameter p-dir2 as character no-undo .
  define input  parameter p-dir3 as character no-undo .
  if p-dir1 = ""
  or p-dir1 = ?
  then do:
    message
      "Необходимо ввести имя директории" skip
      view-as alert-box error .
    undo, return error "p-dir1" .
  end.
  if p-dir2 = ""
  or p-dir2 = ?
  then do:
    message
      "Необходимо ввести имя директории" skip
      view-as alert-box error .
    undo, return error "p-dir2" .
  end.
  if p-dir3 = ""
  or p-dir3 = ?
  then do:
    message
      "Необходимо ввести имя директории" skip
      view-as alert-box error .
    undo, return error "p-dir3" .
  end.
  if p-dir1 = p-dir2
  or p-dir2 = p-dir3
  or p-dir1 = p-dir3
  then do:
    message
      "Все директории должны быть различны" skip
      view-as alert-box error .
    undo, return error .
  end.
  assign
    file-info :file-name = p-dir1
  .
  if file-info :file-type = ?
  or index(file-info :file-type, 'D':u) = 0
  then do:
    message
      "Неправильно указана Директория 1" skip
      "" p-dir1 skip
      view-as alert-box error .
    undo, return error "p-dir1" .
  end.
  assign
    file-info :file-name = p-dir2
  .
  if file-info :file-type = ?
  or index(file-info :file-type, 'D':u) = 0
  then do:
    message
      "Неправильно указана Директория 2" skip
      "" p-dir2 skip
      view-as alert-box error .
    undo, return error "p-dir2" .
  end.
  assign
    file-info :file-name = p-dir3
  .
  if file-info :file-type = ?
  or index(file-info :file-type, 'D':u) = 0
  then do:
    message
      "Неправильно указана Директория 3" skip
      "" p-dir3 skip
      view-as alert-box error .
    undo, return error "p-dir3" .
  end.
END PROCEDURE.
