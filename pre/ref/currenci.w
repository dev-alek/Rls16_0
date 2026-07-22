DEFINE BUFFER locked_currency FOR ub.currency.
DEFINE TEMP-TABLE tt-currency NO-UNDO LIKE ub.currency.
DEFINE  INPUT        PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
define  input        parameter p-mode as char  no-undo.
define  input        parameter p-curr-code like ub.currency.curr-code no-undo .
define  input-output parameter p-rid   as   recid  init ? no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "карточка валюты".
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
define variable v-db-num like ub.db.db-num no-undo .
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE f-okv-code-chr AS CHARACTER FORMAT "X(3)":U
     LABEL "Буквенный код"
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.
DEFINE QUERY Dialog-Frame FOR
      tt-currency SCROLLING.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-hist AT ROW 1 COL 31
     B-Help AT ROW 1 COL 54.9
     tt-currency.curr-abbr AT ROW 3.63 COL 47.9 COLON-ALIGNED
          LABEL "Аббревиатура"
          VIEW-AS FILL-IN
          SIZE 7.6 BY 1
     tt-currency.curr-code AT ROW 3.67 COL 28.4 COLON-ALIGNED
          LABEL "Код валюты"
          VIEW-AS FILL-IN
          SIZE 3.3 BY 1
     tt-currency.okv-code AT ROW 4.97 COL 28 COLON-ALIGNED
          LABEL "Код Общерос.Классиф.Валют"
          VIEW-AS FILL-IN
          SIZE 8.1 BY 1
     f-okv-code-chr AT ROW 5 COL 55 COLON-ALIGNED WIDGET-ID 2
     tt-currency.curr-name AT ROW 6.3 COL 17.6 COLON-ALIGNED
          LABEL "Название"
          VIEW-AS FILL-IN
          SIZE 41 BY 1
     tt-currency.curr-name-one AT ROW 7.57 COL 27.4 COLON-ALIGNED
          LABEL "один/одна..."
          VIEW-AS FILL-IN
          SIZE 41 BY 1 TOOLTIP "Укажите название в единственном числе"
     tt-currency.curr-name-three AT ROW 8.8 COL 27.5 COLON-ALIGNED
          LABEL "три..."
          VIEW-AS FILL-IN
          SIZE 41 BY 1 TOOLTIP "Укажите спряжение для числительных 2-4"
     tt-currency.curr-name-five AT ROW 9.93 COL 27.5 COLON-ALIGNED
          LABEL "пять..."
          VIEW-AS FILL-IN
          SIZE 41 BY 1 TOOLTIP "Укажите спряженеи для числительных пять и т.д."
     tt-currency.curr-eng-name AT ROW 11.07 COL 1.1
          LABEL "Название (англ.)"
          VIEW-AS FILL-IN
          SIZE 41 BY 1
     tt-currency.curr-eng-name-one AT ROW 12.3 COL 28 COLON-ALIGNED
          LABEL "one..."
          VIEW-AS FILL-IN
          SIZE 41 BY 1 TOOLTIP "Укажите название в единственном числе"
     tt-currency.curr-eng-name-three AT ROW 13.37 COL 28 COLON-ALIGNED
          LABEL "three..."
          VIEW-AS FILL-IN
          SIZE 41 BY 1 TOOLTIP "Укажите спряжение для числительных 2-4"
     tt-currency.curr-eng-name-five AT ROW 14.5 COL 28.1 COLON-ALIGNED
          LABEL "five..."
          VIEW-AS FILL-IN
          SIZE 41 BY 1 TOOLTIP "Укажите спряженеи для числительных пять и т.д."
     tt-currency.part-name AT ROW 15.7 COL 23.8 COLON-ALIGNED
          LABEL "Название дробной части"
          VIEW-AS FILL-IN
          SIZE 36 BY 1
     tt-currency.part-name-one AT ROW 16.8 COL 28 COLON-ALIGNED
          LABEL "один/одна..."
          VIEW-AS FILL-IN
          SIZE 41 BY 1 TOOLTIP "Укажите название в единственном числе"
     tt-currency.part-name-three AT ROW 17.87 COL 28 COLON-ALIGNED
          LABEL "три..."
          VIEW-AS FILL-IN
          SIZE 41 BY 1 TOOLTIP "Укажите спряжение для числительных 2-4"
     tt-currency.part-name-five AT ROW 19 COL 28.1 COLON-ALIGNED
          LABEL "пять..."
          VIEW-AS FILL-IN
          SIZE 41 BY 1 TOOLTIP "Укажите спряженеи для числительных пять и т.д."
     tt-currency.part-abbr AT ROW 20.2 COL 28.3 COLON-ALIGNED
          LABEL "Сокращение дробной части"
          VIEW-AS FILL-IN
          SIZE 6.6 BY 1
     SPACE(39.72) SKIP(0.83)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Валюта"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
  run proc-save in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-hist IN FRAME Dialog-Frame
DO:
    define variable v-rid-list as character no-undo.
    run ref/ccurrenc.w
                (
                 input parParentProc
                ,input "":U
                ,input "one":U
                ,input tt-currency.curr-code
                ,input-output v-rid-list
                              ).
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
 if p-mode  <> 'ДОБАВЛЕНИЕ':U
 and p-mode <> 'ИЗМЕНЕНИЕ':U
 and p-mode <> 'ПРОСМОТР':U
 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"  p-mode
    view-as alert-box ERROR.
    undo, return error.
 end.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
 if p-mode <> 'ПРОСМОТР':U then do:
    if v-db-num <> 0
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметров вызова p-mode - нельзя изменять/добавлять записи ВАЛЮТЫ в УБД"
      view-as alert-box ERROR.
      undo, return error.
    end.
  end.
  for each tt-currency:
    delete tt-currency.
  end.
  if p-mode = 'ИЗМЕНЕНИЕ':U
  or p-mode = 'ПРОСМОТР':U then do:
    if p-mode = 'ИЗМЕНЕНИЕ':U then do:
      find first locked_currency EXclusive-lock where
                   recid(locked_currency) = p-rid no-wait no-error.
      if locked locked_currency then do:
        message
        vss-workfile vss-revision vss-description skip
         "Запись ВАЛЮТЫ занята"
        view-as alert-box error .
        undo, return error.
      end.
    end.
    else do:
      find first locked_currency no-lock where
                       recid(locked_currency) = p-rid no-error .
      if not avail locked_currency then do:
        find first locked_currency where
                  locKed_currency.curr-code = p-curr-code no-error .
      end.
    end.
    if not available locked_currency then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись ВАЛЮТЫ"
      view-as alert-box error .
      undo, return error.
    end.
    create tt-currency.
    buffer-copy locked_currency to tt-currency.
  end.
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    create tt-currency.
  end.
  RUN MYenable.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY f-okv-code-chr
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-currency THEN
    DISPLAY tt-currency.okv-code tt-currency.curr-name tt-currency.curr-name-one
          tt-currency.curr-name-three tt-currency.curr-name-five
          tt-currency.curr-eng-name tt-currency.curr-eng-name-one
          tt-currency.curr-eng-name-three tt-currency.curr-eng-name-five
          tt-currency.part-name tt-currency.part-name-one
          tt-currency.part-name-three tt-currency.part-name-five
          tt-currency.part-abbr
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-hist B-Help tt-currency.curr-abbr
         tt-currency.curr-code tt-currency.okv-code f-okv-code-chr
         tt-currency.curr-name tt-currency.curr-name-one
         tt-currency.curr-name-three tt-currency.curr-name-five
         tt-currency.curr-eng-name tt-currency.curr-eng-name-one
         tt-currency.curr-eng-name-three tt-currency.curr-eng-name-five
         tt-currency.part-name tt-currency.part-name-one
         tt-currency.part-name-three tt-currency.part-name-five
         tt-currency.part-abbr
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyEnable :
if num-entries(tt-currency.curr-eng-name, chr(4)) > 1 then do:
  f-okv-code-chr = entry(2, tt-currency.curr-eng-name, chr(4)).
  tt-currency.curr-eng-name = entry(2, tt-currency.curr-eng-name, chr(4)).
end.
IF AVAILABLE
tt-currency THEN
DISPLAY
f-okv-code-chr
tt-currency.okv-code
tt-currency.curr-abbr
tt-currency.curr-code
tt-currency.curr-name
tt-currency.curr-name-one
tt-currency.curr-name-three
tt-currency.curr-name-five
tt-currency.curr-eng-name
tt-currency.curr-eng-name-one
tt-currency.curr-eng-name-three
tt-currency.curr-eng-name-five
tt-currency.part-name
tt-currency.part-name-one
tt-currency.part-name-three
tt-currency.part-name-five
tt-currency.part-abbr
WITH FRAME Dialog-Frame.
if p-mode = 'ПРОСМОТР':U then do:
  assign
  b-quit:label = "&Выход".
  ENABLE
  b-quit
  B-Help
  with frame Dialog-Frame .
  hide
  b-exit in frame Dialog-Frame .
end.
else do:
  ENABLE
  B-exit
  b-quit
  b-hist WHEN p-mode <> 'ДОБАВЛЕНИЕ':U
  B-Help
  f-okv-code-chr
  tt-currency.curr-abbr when p-mode = 'ДОБАВЛЕНИЕ':U
  tt-currency.curr-code when p-mode = 'ДОБАВЛЕНИЕ':U
  tt-currency.okv-code
  tt-currency.curr-name
  tt-currency.curr-name-one
  tt-currency.curr-name-three
  tt-currency.curr-name-five
  tt-currency.curr-eng-name
  tt-currency.curr-eng-name-one
  tt-currency.curr-eng-name-three
  tt-currency.curr-eng-name-five
  tt-currency.part-name
  tt-currency.part-name-one
  tt-currency.part-name-three
  tt-currency.part-name-five
  tt-currency.part-abbr
  WITH FRAME Dialog-Frame .
end.
VIEW FRAME Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-save :
define variable glog as logical no-undo .
if tt-currency.curr-eng-name:screen-value in frame Dialog-Frame = ""  then do:
  message
  "Вы уверены, что для данной валюты НЕ НУЖНО вводить АНГЛИЙСКОE НАЗВАНИЕ?"
  view-as alert-box QUESTION buttons YES-NO update glog.
  if not glog then do:
      apply "ENTRY":U to tt-currency.curr-eng-name.
      return error.
  end.
end.
if tt-currency.part-abbr:screen-value = "" OR
   tt-currency.part-name:screen-value  = "" then do:
  message
  "Вы уверены, что у данной валюты НЕТ ДРОБНОЙ ЧАСТИ?"
  view-as alert-box QUESTION buttons YES-NO update glog.
  if not glog then do:
    apply "ENTRY":U  to tt-currency.part-name.
    return error.
  end.
end.
assign
frame Dialog-Frame
f-okv-code-chr
tt-currency.curr-code
tt-currency.curr-abbr
tt-currency.part-abbr
tt-currency.curr-name
tt-currency.curr-name-one
tt-currency.curr-name-three
tt-currency.curr-name-five
tt-currency.curr-eng-name
tt-currency.curr-eng-name-one
tt-currency.curr-eng-name-three
tt-currency.curr-eng-name-five
tt-currency.part-name
tt-currency.part-name-one
tt-currency.part-name-three
tt-currency.part-name-five
tt-currency.okv-code
.
run ref/currenc1.p (
 input-output p-rid
,input p-mode
,input false
,input tt-currency.curr-code
,input tt-currency.curr-abbr
,input tt-currency.part-abbr
,input tt-currency.curr-name
,input tt-currency.curr-name-one
,input tt-currency.curr-name-three
,input tt-currency.curr-name-five
,input tt-currency.curr-eng-name
,input tt-currency.curr-eng-name-one
,input tt-currency.curr-eng-name-three
,input tt-currency.curr-eng-name-five
,input tt-currency.part-name
,input tt-currency.part-name-one
,input tt-currency.part-name-three
,input tt-currency.part-name-five
,input tt-currency.okv-code
,input f-okv-code-chr
) no-error .
if error-status:error then do:
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable rv as character no-undo .
assign
rv = entry(1, return-value , chr(4)).
if rv <> "":U then do:
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = rv then do:
      APPLY "ENTRY" to hh.
      undo ,
      return error.
    end.
    hh = hh:next-sibling.
  end.
end.
  undo, return error.
end.
END PROCEDURE.
