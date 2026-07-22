DEFINE TEMP-TABLE tt-ex-mark NO-UNDO LIKE ub.ex-mark.
define input parameter parParentProc as widget-handle no-undo.
define input parameter p-mode        as character no-undo.
define input parameter p-mark-type   as integer no-undo.
define input-output parameter p-rec  as recid no-undo.
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Корректировка акцизной или специальной марки".
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
define variable v-db-num like ub.db.db-num no-undo.
define buffer locked_ex-mark for ub.ex-mark.
define buffer locked_ex-mark-attr for ub.ex-mark-attr.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE FILL-IN-Date-to AS DATE FORMAT "99/99/9999":U INITIAL ?
     LABEL "Действительна до"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-Descr AS CHARACTER FORMAT "X(256)":U INITIAL "Тип марки:"
      VIEW-AS TEXT
     SIZE 10.6 BY .67 NO-UNDO.
DEFINE VARIABLE r-mark-type AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Специальная", 0,
"Акцизная", 1
     SIZE 22 BY 1.62 NO-UNDO.
DEFINE QUERY Dialog-Frame FOR
      tt-ex-mark SCROLLING.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 50.6
     tt-ex-mark.mark-name AT ROW 4.71 COL 24 COLON-ALIGNED
          LABEL "Код марки" FORMAT "X(20)"
          VIEW-AS FILL-IN
          SIZE 30.6 BY 1
     r-mark-type AT ROW 6.05 COL 26 NO-LABEL
     FILL-IN-Date-to AT ROW 7.91 COL 24 COLON-ALIGNED WIDGET-ID 2
     tt-ex-mark.db-num AT ROW 2.62 COL 24 COLON-ALIGNED
          LABEL "Код БД создания"
           VIEW-AS TEXT
          SIZE 5.6 BY .67
          FGCOLOR 4
     tt-ex-mark.mark-code AT ROW 3.67 COL 24 COLON-ALIGNED
          LABEL "Внутренний код"
           VIEW-AS TEXT
          SIZE 10 BY .67
          FGCOLOR 4
     FILL-IN-Descr AT ROW 6.05 COL 13 COLON-ALIGNED NO-LABEL
     SPACE(37.59) SKIP(2.75)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Акцизная или специальная марка"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
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
  if p-mode = 'ПРОСМОТР':U then return no-apply.
  do on error undo, return no-apply:
    run proc-save in this-procedure.
  end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
assign frame Dialog-Frame:title = frame Dialog-Frame:title + " - " + p-mode.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  if p-mode <> 'ДОБАВЛЕНИЕ':U and
     p-mode <> 'ИЗМЕНЕНИЕ':U  and
     p-mode <> 'ПРОСМОТР':U
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметров вызова p-mode"  p-mode
      view-as alert-box error.
    return error.
  end.
  if p-mode = 'ПРОСМОТР':U then do:
    find first locked_ex-mark no-lock
      where recid(locked_ex-mark) = p-rec no-error .
    if not available locked_ex-mark then do:
      message
        "Не найдена запись Акцизной или Специальной марки"
        view-as alert-box error.
        return error.
    end.
  end.
  if p-mode = 'ИЗМЕНЕНИЕ':U then
  do transaction on error undo, return error:
    find first locked_ex-mark exclusive-lock
      where recid(locked_ex-mark) = p-rec no-error no-wait.
    if not available locked_ex-mark then do:
      if locked locked_ex-mark then do:
        message "Запись редактируется другим пользователем"
          view-as alert-box error.
      end.
      else do:
        message "Не найдена запись Акцизной или Специальной марки"
          view-as alert-box error.
      end.
      return error.
    end.
  end.
  create tt-ex-mark.
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
    assign
      tt-ex-mark.db-num    = v-db-num
      tt-ex-mark.mark-code = 0
      tt-ex-mark.mark-type = 0
    .
    if p-mark-type <> ? then do:
      assign
        tt-ex-mark.mark-type = p-mark-type
      .
    end.
  end.
  else do:
    buffer-copy locked_ex-mark to tt-ex-mark.
  end.
  run MyEnable in this-procedure.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH tt-ex-mark SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY r-mark-type FILL-IN-Date-to FILL-IN-Descr
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-ex-mark THEN
    DISPLAY tt-ex-mark.mark-name tt-ex-mark.db-num tt-ex-mark.mark-code
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-quit B-Help tt-ex-mark.mark-name r-mark-type FILL-IN-Date-to
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyEnable :
  if available tt-ex-mark then do:
    r-mark-type = tt-ex-mark.mark-type.
  end.
  find first locked_ex-mark-attr no-lock
    where locked_ex-mark-attr.db-num = tt-ex-mark.db-num
    and locked_ex-mark-attr.mark-code = tt-ex-mark.mark-code
    and locked_ex-mark-attr.attr-code = "exp-date" no-error.
  if available locked_ex-mark-attr then do:
    FILL-IN-Date-to = date(locked_ex-mark-attr.attr-value).
  end.
  display
    tt-ex-mark.db-num
    tt-ex-mark.mark-code
    tt-ex-mark.mark-name
    r-mark-type
    FILL-IN-Date-to
   with frame Dialog-Frame.
  view frame Dialog-Frame.
  enable B-quit B-Help
    with frame Dialog-Frame.
  if p-mode = 'ПРОСМОТР':U then do:
    assign
      b-exit:label  = "&Выход"
    .
    hide b-quit in frame Dialog-Frame.
  end.
  else do:
    enable B-exit
           tt-ex-mark.mark-name
           r-mark-type when p-mark-type = ?
           FILL-IN-Date-to
      with frame Dialog-Frame.
    apply "entry" to tt-ex-mark.mark-name in frame Dialog-Frame.
  end.
  return.
END PROCEDURE.
PROCEDURE proc-save :
  define variable v-new-code like ex-mark.mark-code no-undo.
  define buffer buf_ex-mark for ub.ex-mark.
  if p-mode = 'ПРОСМОТР':U then do:
      return error.
  end.
  assign frame Dialog-Frame
    tt-ex-mark.mark-name
    r-mark-type
    FILL-IN-Date-to
  .
  if tt-ex-mark.mark-name = "":U then do:
    message "Не указан код марки"
      view-as alert-box error.
    apply "entry" to tt-ex-mark.mark-name in frame Dialog-Frame.
    return error.
  end.
  find first buf_ex-mark no-lock
    where buf_ex-mark.mark-name = tt-ex-mark.mark-name
      and buf_ex-mark.stts      = integer('0':U)
      and (p-mode = 'ДОБАВЛЕНИЕ':U or p-rec <> recid(buf_ex-mark))
    no-error.
  if available buf_ex-mark then do:
    message substitute("Уже существует &1 марка с указанным кодом"
                      , (if buf_ex-mark.mark-type = 0 then "Специальная"
                                                      else "Акцизная")
                      )
      view-as alert-box error.
    apply "entry" to tt-ex-mark.mark-name in frame Dialog-Frame.
    return error.
  end.
  do on error undo, return error
     on stop  undo, return error
    :
    if p-mode = 'ДОБАВЛЕНИЕ':U then do:
      create locked_ex-mark.
      assign
        locked_ex-mark.db-num    = v-db-num
        locked_ex-mark.mark-code = NEXT-VALUE( s-ex-mark, ub )
      .
      if FILL-IN-Date-to <> ? then do:
        create locked_ex-mark-attr.
        assign
        locked_ex-mark-attr.db-num = locked_ex-mark.db-num
        locked_ex-mark-attr.mark-code = locked_ex-mark.mark-code
        locked_ex-mark-attr.attr-code = "exp-date"
        locked_ex-mark-attr.attr-value = string(FILL-IN-Date-to).
      end.
    end.
    else do:
      find current locked_ex-mark exclusive-lock.
      find first locked_ex-mark-attr exclusive-lock
            where locked_ex-mark-attr.db-num = locked_ex-mark.db-num
              and locked_ex-mark-attr.mark-code = locked_ex-mark.mark-code
              and locked_ex-mark-attr.attr-code = "exp-date" no-error.
      if not available(locked_ex-mark-attr) and FILL-IN-Date-to <> ? then do:
            create locked_ex-mark-attr.
            assign
            locked_ex-mark-attr.db-num = locked_ex-mark.db-num
            locked_ex-mark-attr.mark-code = locked_ex-mark.mark-code
            locked_ex-mark-attr.attr-code = "exp-date"
            locked_ex-mark-attr.attr-value = string(FILL-IN-Date-to).
      end.
      else do:
        if FILL-IN-Date-to <> ? then
        locked_ex-mark-attr.attr-value = string(FILL-IN-Date-to).
      end.
    end.
    assign
      locked_ex-mark.mark-type = r-mark-type
      locked_ex-mark.mark-name = tt-ex-mark.mark-name
    .
    p-rec = recid(locked_ex-mark).
    release locked_ex-mark no-error.
    if error-status:error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при сохранении записи Акцизной или Специальной марки" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error.
    end.
  end.
  return.
END PROCEDURE.
