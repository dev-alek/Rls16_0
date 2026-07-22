DEFINE BUFFER buf_clients FOR clients.
DEFINE BUFFER buf_sys-ctrl FOR sys-ctrl.
define input  parameter parparentproc as handle    no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Утилита коррекции даты на объекте".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function usrfulnf returns character ( input p-user-id as character):
define variable v-user-name as character no-undo .
define variable vss-include-info1 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrfulnm in g#library
  (input  p-user-id
  ,output v-user-name
  ) no-error .
if error-status:error
or v-user-name = ""
then do:
  return p-user-id.
end.
else do:
  return v-user-name.
end.
end function.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-rollback
     LABEL "Откатить"
     SIZE 10 BY 1.
DEFINE BUTTON b-sel-obj
     LABEL ">"
     SIZE 3 BY 1.
DEFINE VARIABLE fi-close-id-cls AS CHARACTER FORMAT "X(256)":U
     LABEL "Закрыл"
     VIEW-AS FILL-IN
     SIZE 25.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-close-id-opn AS CHARACTER FORMAT "X(256)":U
     LABEL "Закрыл"
     VIEW-AS FILL-IN
     SIZE 25.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-close-time-cls AS INTEGER FORMAT ">>>>>>9":U INITIAL ?
     LABEL "Закрыта"
     VIEW-AS FILL-IN
     SIZE 14 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-close-time-hms-cls AS CHARACTER FORMAT "X(8)":U
     VIEW-AS FILL-IN
     SIZE 9 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-close-time-hms-opn AS CHARACTER FORMAT "X(8)":U
     VIEW-AS FILL-IN
     SIZE 9 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-close-time-opn AS INTEGER FORMAT ">>>>>>9":U INITIAL ?
     LABEL "Закрыта"
     VIEW-AS FILL-IN
     SIZE 14 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-db-num AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "БД"
      VIEW-AS TEXT
     SIZE 9.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-fo-cls AS DECIMAL FORMAT ">>>>>>>>>>>>>9.999999":U INITIAL ?
     LABEL "ФО"
     VIEW-AS FILL-IN
     SIZE 29.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-fo-opn AS DECIMAL FORMAT ">>>>>>>>>>>>>9.999999":U INITIAL ?
     LABEL "ФО"
     VIEW-AS FILL-IN
     SIZE 29.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-obj-code AS INTEGER FORMAT ">>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.
DEFINE VARIABLE fi-obj-type AS CHARACTER FORMAT "X(3)":U
     LABEL "Объект"
     VIEW-AS FILL-IN
     SIZE 4.5 BY 1 NO-UNDO.
DEFINE VARIABLE fi-open-id-cls AS CHARACTER FORMAT "X(256)":U
     LABEL "Открыл"
     VIEW-AS FILL-IN
     SIZE 25.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-open-id-opn AS CHARACTER FORMAT "X(256)":U
     LABEL "Открыл"
     VIEW-AS FILL-IN
     SIZE 25.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-open-time-cls AS INTEGER FORMAT ">>>>>>9":U INITIAL ?
     LABEL "Открыта"
     VIEW-AS FILL-IN
     SIZE 14 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-open-time-hms-cls AS CHARACTER FORMAT "X(8)":U
     VIEW-AS FILL-IN
     SIZE 9 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-open-time-hms-opn AS CHARACTER FORMAT "X(8)":U
     VIEW-AS FILL-IN
     SIZE 9 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-open-time-opn AS INTEGER FORMAT ">>>>>>9":U INITIAL ?
     LABEL "Открыта"
     VIEW-AS FILL-IN
     SIZE 14 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-sys-date-cls AS DATE FORMAT "99/99/9999":U
     LABEL "Дата"
     VIEW-AS FILL-IN
     SIZE 14 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-sys-date-opn AS DATE FORMAT "99/99/9999":U
     LABEL "Дата"
     VIEW-AS FILL-IN
     SIZE 14 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 35.5 BY 7.25.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 35 BY 7.25.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-rollback AT ROW 1 COL 11
     b-help AT ROW 1 COL 61
     fi-obj-type AT ROW 2 COL 24 COLON-ALIGNED
     fi-obj-code AT ROW 2 COL 29 COLON-ALIGNED NO-LABEL
     b-sel-obj AT ROW 2 COL 37.5
     fi-sys-date-cls AT ROW 5 COL 6.63 COLON-ALIGNED
     fi-sys-date-opn AT ROW 5 COL 42.38 COLON-ALIGNED
     fi-open-time-cls AT ROW 6 COL 9.5 COLON-ALIGNED
     fi-open-time-hms-cls AT ROW 6 COL 24 COLON-ALIGNED NO-LABEL
     fi-open-time-opn AT ROW 6 COL 45.38 COLON-ALIGNED
     fi-open-time-hms-opn AT ROW 6 COL 59.88 COLON-ALIGNED NO-LABEL
     fi-close-time-cls AT ROW 7 COL 9.5 COLON-ALIGNED
     fi-close-time-hms-cls AT ROW 7 COL 24 COLON-ALIGNED NO-LABEL
     fi-close-time-opn AT ROW 7 COL 45.38 COLON-ALIGNED
     fi-close-time-hms-opn AT ROW 7 COL 59.88 COLON-ALIGNED NO-LABEL
     fi-fo-cls AT ROW 8 COL 4.5 COLON-ALIGNED
     fi-fo-opn AT ROW 8 COL 40.38 COLON-ALIGNED
     fi-open-id-cls AT ROW 9 COL 8.5 COLON-ALIGNED
     fi-open-id-opn AT ROW 9 COL 44.38 COLON-ALIGNED
     fi-close-id-cls AT ROW 10 COL 8.5 COLON-ALIGNED
     fi-close-id-opn AT ROW 10 COL 44.38 COLON-ALIGNED
     fi-db-num AT ROW 2.25 COL 4 COLON-ALIGNED
     "Текущая дата на объекте" VIEW-AS TEXT
          SIZE 29.5 BY .67 AT ROW 4 COL 37
          FGCOLOR 4
     "Последняя закрытая дата" VIEW-AS TEXT
          SIZE 29.5 BY .67 AT ROW 4 COL 2
          FGCOLOR 4
     RECT-1 AT ROW 4.75 COL 1.5
     RECT-2 AT ROW 4.75 COL 37.5
     SPACE(0.49) SKIP(0.28)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Откат даты на объекте"
         DEFAULT-BUTTON b-exit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       fi-close-id-cls:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       fi-close-id-opn:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       fi-close-time-cls:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       fi-close-time-hms-cls:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       fi-close-time-hms-opn:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       fi-close-time-opn:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       fi-fo-cls:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       fi-fo-opn:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       fi-open-id-cls:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       fi-open-id-opn:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       fi-open-time-cls:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       fi-open-time-hms-cls:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       fi-open-time-hms-opn:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       fi-open-time-opn:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       fi-sys-date-cls:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       fi-sys-date-opn:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-rollback IN FRAME Dialog-Frame
DO:
run  proc-sel-doc in this-procedure no-error .
  if error-status :error = yes
  then do:
    message
      return-value skip
      error-status :get-message(1) skip
      error-status :get-message(2) skip
    view-as alert-box error.
    run proc-clr-info in this-procedure .
  end.
END.
ON CHOOSE OF b-sel-obj IN FRAME Dialog-Frame
DO:
  run proc-sel-obj in this-procedure no-error .
  if error-status :error
  then do:
    message
      return-value skip
      error-status :get-message(1) skip
      error-status :get-message(2) skip
    view-as alert-box error.
    run proc-clr-info in this-procedure .
    return no-apply.
  end.
END.
ON LEAVE OF fi-obj-code IN FRAME Dialog-Frame
DO:
END.
ON RETURN OF fi-obj-code IN FRAME Dialog-Frame
DO:
  run proc-sel-obj in this-procedure no-error .
  if error-status :error
  then do:
    message
      return-value skip
      error-status :get-message(1) skip
      error-status :get-message(2) skip
    view-as alert-box error.
    run proc-clr-info in this-procedure .
    return no-apply.
  end.
END.
ON LEAVE OF fi-obj-type IN FRAME Dialog-Frame
DO:
END.
ON RETURN OF fi-obj-type IN FRAME Dialog-Frame
DO:
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
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame Dialog-Frame anywhere do:
  if b-exit :sensitive then DO: apply "CHOOSE":U to b-exit in frame Dialog-Frame. END.
  return no-apply.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN my-enable in this-procedure .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY fi-obj-type fi-obj-code fi-sys-date-cls fi-sys-date-opn
          fi-open-time-cls fi-open-time-hms-cls fi-open-time-opn
          fi-open-time-hms-opn fi-close-time-cls fi-close-time-hms-cls
          fi-close-time-opn fi-close-time-hms-opn fi-fo-cls fi-fo-opn
          fi-open-id-cls fi-open-id-opn fi-close-id-cls fi-close-id-opn
          fi-db-num
      WITH FRAME Dialog-Frame.
  ENABLE b-exit RECT-1 RECT-2 b-help fi-obj-type fi-obj-code b-sel-obj
         fi-sys-date-cls fi-sys-date-opn fi-open-time-cls fi-open-time-hms-cls
         fi-open-time-opn fi-open-time-hms-opn fi-close-time-cls
         fi-close-time-hms-cls fi-close-time-opn fi-close-time-hms-opn
         fi-fo-cls fi-fo-opn fi-open-id-cls fi-open-id-opn fi-close-id-cls
         fi-close-id-opn
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE my-disable :
END PROCEDURE.
PROCEDURE my-enable :
  find first buf_sys-ctrl no-lock .
  assign
    fi-db-num   = buf_sys-ctrl.db-num
    fi-obj-type = 'маг':U
  .
  display
    fi-obj-type
    fi-obj-code
    fi-sys-date-cls
    fi-sys-date-opn
    fi-open-time-cls
    fi-open-time-hms-cls
    fi-open-time-opn
    fi-open-time-hms-opn
    fi-close-time-cls
    fi-close-time-hms-cls
    fi-close-time-opn
    fi-close-time-hms-opn
    fi-fo-cls
    fi-fo-opn
    fi-db-num
    fi-open-id-cls
    fi-close-id-cls
    fi-open-id-opn
    fi-close-id-opn
  with frame Dialog-Frame.
  enable
    b-exit
    b-help
    b-sel-obj
    fi-obj-type fi-obj-code
  with frame Dialog-Frame.
  view frame Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-clr-info :
  assign
    fi-sys-date-cls       = ?
    fi-open-time-cls      = ?
    fi-open-time-hms-cls  = ?
    fi-close-time-cls     = ?
    fi-close-time-hms-cls = ?
    fi-fo-cls             = ?
    fi-sys-date-opn       = ?
    fi-open-time-opn      = ?
    fi-open-time-hms-opn  = ?
    fi-close-time-opn     = ?
    fi-close-time-hms-opn = ?
    fi-fo-opn             = ?
    fi-open-id-cls        = ?
    fi-close-id-cls       = ?
    fi-open-id-opn        = ?
    fi-close-id-opn       = ?
  .
  display
    fi-sys-date-cls
    fi-open-time-cls
    fi-open-time-hms-cls
    fi-close-time-cls
    fi-close-time-hms-cls
    fi-fo-cls
    fi-sys-date-opn
    fi-open-time-opn
    fi-open-time-hms-opn
    fi-close-time-opn
    fi-close-time-hms-opn
    fi-fo-opn
    fi-open-id-cls
    fi-close-id-cls
    fi-open-id-opn
    fi-close-id-opn
  with frame Dialog-Frame .
  disable
    b-rollback
  with frame Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-cor-date :
  define buffer cor_obj-date for ub.obj-date.
  define buffer buf_obj-date for ub.obj-date.
  define variable v-log as logical   no-undo .
do
on error undo, return error return-value
:
  message
    substitute("Откатить дату с &1 на &2 ?" , fi-sys-date-opn, fi-sys-date-cls) skip
    "Внимательно проверьте дату перед тем как произвести откат!"
  view-as alert-box question buttons yes-no update v-log.
  if v-log <> yes then do:
    return .
  end.
  find first buf_obj-date no-lock
    where buf_obj-date.obj-type   = fi-obj-type
      and buf_obj-date.obj-code   = fi-obj-code
      and buf_obj-date.sys-date   = fi-sys-date-cls
      and buf_obj-date.status_    = 'зкр':U
      and buf_obj-date.fact-order = fi-fo-cls
  no-error.
  if not available buf_obj-date
  then do:
    return error substitute( "Утилита не может быть запущена: Не прошла проверка предыдущей даты.&1&2&1&3&1&4&1&5&1&6"
                           , chr(10)
                           , fi-obj-type
                           , fi-obj-code
                           , fi-sys-date-cls
                           , 'зкр':U
                           , fi-fo-cls
                           ) .
  end.
  if buf_obj-date.open-time  <> fi-open-time-cls
  or buf_obj-date.close-time <> fi-close-time-cls
  then do:
    return error substitute( "Утилита не может быть запущена: Не прошла проверка предыдущей даты. Время открытия/закрытия не совпадают!&1&2&1&3"
                           , chr(10)
                           , fi-open-time-cls
                           , fi-close-time-cls
                           ) .
  end.
  on delete of ub.obj-date override do: end.
  on write of ub.obj-date override do: end.
  _rollback:
  do transaction
  on error undo _rollback, return error return-value
  on endkey undo _rollback, return error return-value
  :
    find first cor_obj-date exclusive-lock
      where cor_obj-date.obj-type   = fi-obj-type
        and cor_obj-date.obj-code   = fi-obj-code
        and cor_obj-date.sys-date   = fi-sys-date-opn
        and cor_obj-date.status_    = 'тек':U
    no-error.
    if not available cor_obj-date
    then do:
      return error substitute( "Невозможно удалить несуществующую запись.&1&2&1&3&1&4&1&5"
                             , chr(10)
                             , fi-obj-type
                             , fi-obj-code
                             , fi-sys-date-opn
                             , 'тек':U
                             ) .
    end.
    delete cor_obj-date.
    find current buf_obj-date exclusive-lock .
    assign
        buf_obj-date.status_    = 'тек':U
        buf_obj-date.close-date = ?
        buf_obj-date.close-time = 0
        buf_obj-date.close-id   = ""
        buf_obj-date.fact-order = 0
    .
  end.
  on delete of ub.obj-date revert.
  on write of ub.obj-date revert.
  run proc-obj-dates in this-procedure ( input fi-obj-type
                                       , input fi-obj-code
                                       ) .
end.
END PROCEDURE.
PROCEDURE proc-obj-dates :
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define buffer buf_obj-date  for ub.obj-date.
define buffer sch_obj-date  for ub.obj-date.
do
on error undo, return error return-value
:
  find last buf_obj-date
    where buf_obj-date.obj-type   = p-obj-type
      and buf_obj-date.obj-code   = p-obj-code
      and buf_obj-date.status_    = 'зкр':U
  no-error .
  if not available buf_obj-date
  then do:
    return error substitute( "На объекте &1 &2 не найдено закрытых дат."
                           , p-obj-type
                           , p-obj-code
                           ) .
  end.
  assign
    fi-sys-date-cls       = buf_obj-date.sys-date
    fi-open-time-cls      = buf_obj-date.open-time
    fi-open-time-hms-cls  = string( buf_obj-date.open-time , "hh:mm:ss" )
    fi-close-time-cls     = buf_obj-date.close-time
    fi-close-time-hms-cls = string(buf_obj-date.close-time , "hh:mm:ss" )
    fi-fo-cls             = buf_obj-date.fact-order
    fi-open-id-cls        = usrfulnf(buf_obj-date.open-id)
    fi-close-id-cls       = usrfulnf(buf_obj-date.close-id)
  .
  find first buf_obj-date no-lock
    where buf_obj-date.obj-type   = p-obj-type
      and buf_obj-date.obj-code   = p-obj-code
      and buf_obj-date.status_    = 'тек':U
  no-error.
  if not available buf_obj-date
  then do:
    return error substitute( "На объекте &1 &2 не найдена дата в статусе &3."
                           , p-obj-type
                           , p-obj-code
                           , 'тек':U
                           ) .
  end.
  find first sch_obj-date no-lock
    where sch_obj-date.obj-type   = buf_obj-date.obj-type
      and sch_obj-date.obj-code   = buf_obj-date.obj-code
      and sch_obj-date.status_    = buf_obj-date.status_
      and recid(sch_obj-date)    <> recid(buf_obj-date)
  no-error .
  if available sch_obj-date
  then do:
    return error substitute( "На объекте &1 &2 найдено две даты в статусе &3."
                           , p-obj-type
                           , p-obj-code
                           , 'тек':U
                           ) .
  end.
  assign
    fi-sys-date-opn       = buf_obj-date.sys-date
    fi-open-time-opn      = buf_obj-date.open-time
    fi-open-time-hms-opn  = string( buf_obj-date.open-time , "hh:mm:ss" )
    fi-close-time-opn     = buf_obj-date.close-time
    fi-close-time-hms-opn = string(buf_obj-date.close-time , "hh:mm:ss" )
    fi-fo-opn             = buf_obj-date.fact-order
    fi-open-id-opn        = usrfulnf(buf_obj-date.open-id)
    fi-close-id-opn       = usrfulnf(buf_obj-date.close-id)
  .
  display
    fi-sys-date-cls
    fi-open-time-cls
    fi-open-time-hms-cls
    fi-close-time-cls
    fi-close-time-hms-cls
    fi-fo-cls
    fi-sys-date-opn
    fi-open-time-opn
    fi-open-time-hms-opn
    fi-close-time-opn
    fi-close-time-hms-opn
    fi-fo-opn
    fi-open-id-cls
    fi-close-id-cls
    fi-open-id-opn
    fi-close-id-opn
  with frame Dialog-Frame .
  enable
    b-rollback
  with frame Dialog-Frame.
end.
END PROCEDURE.
PROCEDURE proc-sel-doc :
    define buffer buf_trn-doc  for trn-doc.
    define buffer buf_obj-date for obj-date.
    define buffer buf_rvs-doc  for rvs-doc.
    define buffer buf_price-doc for price-doc.
    do
        on error undo, return error return-value
        :
          find first buf_price-doc where
          buf_price-doc.obj-code = fi-obj-code
          and
          buf_price-doc.obj-type = fi-obj-type
          and
          buf_price-doc.fact-order > fi-fo-cls
          no-error.
          if available buf_price-doc
          then do:
              return error substitute ("На объекте, на котором коректируется дата ,существуют документы с fact-order больше, чем дата которую делаем текущей "     ).
        end.
        find first buf_rvs-doc where
        buf_rvs-doc.obj-code = fi-obj-code
            and
            buf_rvs-doc.obj-type = fi-obj-type
            and
            buf_rvs-doc.fact-order > fi-fo-cls
            no-error.
        if available buf_rvs-doc
            then
        do:
            return error substitute ("На объекте, на котором коректируется дата ,существуют документы с fact-order больше, чем дата которую делаем текущей "     ).
        end.
        find first buf_trn-doc
            where
            buf_trn-doc.obj-code = fi-obj-code
            and
            buf_trn-doc.obj-type = fi-obj-type
            and buf_trn-doc.fact-order > fi-fo-cls
            no-error.
        if available buf_trn-doc
            then
        do:
            return error substitute ("На объекте, на котором коректируется дата ,существуют документы с fact-order больше, чем дата которую делаем текущей "     ).
        end.
    end.
    run proc-cor-date in this-procedure no-error .
END PROCEDURE.
PROCEDURE proc-sel-obj :
define variable v-obj-type-list as character no-undo .
do
on error undo, return error return-value
:
 assign frame Dialog-Frame
  fi-obj-type
  fi-obj-code
 .
 assign
  v-obj-type-list = 'скл':U + ',' + 'маг':U
 .
 if lookup(fi-obj-type , v-obj-type-list ) > 0
 then do:
  find first buf_clients no-lock
    where buf_clients.obj-type = fi-obj-type
      and buf_clients.obj-code = fi-obj-code
  no-error .
 end.
 if not available buf_clients
 then do:
  return error substitute( "Объект &1 &2 не найден"
                         , fi-obj-type
                         , fi-obj-code
                         ) .
 end.
 run proc-obj-dates in this-procedure ( input buf_clients.obj-type
                                      , input buf_clients.obj-code
                                      ) .
end.
END PROCEDURE.
