DEFINE BUFFER buf_cash-desk FOR ub.cash-desk.
DEFINE BUFFER buf_obj FOR ub.clients.
DEFINE BUFFER buf_sysconf FOR ub.sysconf.
DEFINE BUFFER locked_wth-place FOR ub.wth-place.
DEFINE TEMP-TABLE tt-wth-place NO-UNDO LIKE ub.wth-place.
define input parameter parparentproc as widget-handle no-undo .
define input parameter par-mode as character no-undo.
define input parameter parhost-code like ub.clients.obj-code no-undo.
define input parameter parobj-type like ub.clients.obj-type no-undo.
define input parameter parobj-code like ub.clients.obj-code no-undo.
define input-output parameter par-ri as recid no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка места хранения МЦ ".
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
DEFINE VARIABLE vardb-num like ub.clients.db-num.
DEFINE BUTTON b-cash-desk
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3 BY 1
     BGCOLOR 8 FGCOLOR 0 .
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
DEFINE VARIABLE for-obj-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 36.25 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE QUERY Dialog-Frame FOR
      tt-wth-place SCROLLING.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-hist AT ROW 1 COL 41
     B-Help AT ROW 1 COL 61
     tt-wth-place.obj-code AT ROW 3.67 COL 20.75 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     tt-wth-place.obj-type AT ROW 3.71 COL 13.75 NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL
          SIZE 7.88 BY 1
     tt-wth-place.w-p-code AT ROW 5.04 COL 20.88 COLON-ALIGNED
          LABEL "Код места хранения"
          VIEW-AS FILL-IN
          SIZE 13 BY 1
          FGCOLOR 4
     tt-wth-place.w-p-name AT ROW 6.42 COL 20.88 COLON-ALIGNED
          LABEL "Название" FORMAT "X(100)"
          VIEW-AS FILL-IN
          SIZE 37.75 BY 1
     b-cash-desk AT ROW 7.67 COL 30.75
     tt-wth-place.cash-desk AT ROW 7.75 COL 20.88 COLON-ALIGNED
          LABEL "Номер кассы" FORMAT ">>>9"
          VIEW-AS FILL-IN
          SIZE 6.75 BY 1
     tt-wth-place.main-cash-desk AT ROW 9.08 COL 22.75
          LABEL "Главная касса"
          VIEW-AS TOGGLE-BOX
          SIZE 26.75 BY 1
     tt-wth-place.PS AT ROW 11.25 COL 1.63 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 75.13 BY 2.75
     tt-wth-place.host-code AT ROW 2.46 COL 12.25 COLON-ALIGNED
          LABEL "Фирма"
           VIEW-AS TEXT
          SIZE 10 BY .67
     for-obj-name AT ROW 3.83 COL 37.63 COLON-ALIGNED NO-LABEL
     "Примечание" VIEW-AS TEXT
          SIZE 12.63 BY .75 AT ROW 10.13 COL 1.5
     SPACE(63.86) SKIP(3.36)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Место хранения МЦ"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       tt-wth-place.PS:RETURN-INSERTED IN FRAME Dialog-Frame  = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
 run proc-save-record in this-procedure No-ERROR.
  if error-status:error then return no-apply.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-cash-desk IN FRAME Dialog-Frame
DO:
 define variable rid-list as character no-undo .
  run ref/cashlist.w (
                 input parparentproc
                ,input "b-sel":U
                ,input 'объект':U
                ,input vardb-num
                ,input parhost-code
                ,input parobj-type
                ,input parobj-code
                ,input ?
                ,output rid-list).
  if rid-list <> "":U then do:
      FIND FIRST buf_cash-desk WHERE
                  recid(buf_cash-desk) = integer(entry(1, rid-list)) NO-LOCK .
      if buf_cash-desk.obj-code <> parobj-code then do:
        message "Выбранная касса принадлежит другому магазину"
        view-as alert-box.
        return no-apply.
      end.
      if buf_cash-desk.db-num <> vardb-num then do:
          message "Выбранная касса принадлежит другой БД"
          view-as alert-box.
          return no-apply.
      end.
      DISPLAY
      buf_cash-desk.cash-num @ tt-wth-place.cash-desk
      with frame Dialog-Frame .
  end.
END.
ON CHOOSE OF B-hist IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  run ref/wthc-pls.w (
                    INPUT parParentProc
                   ,input '':U
                   ,input 'one':U
                   ,input parobj-type
                   ,input parobj-code
                   ,INPUT tt-wth-place.w-p-code
                   ,INPUT-OUTPUT v-rid-list) NO-ERROR.
END.
ON LEAVE OF tt-wth-place.cash-desk IN FRAME Dialog-Frame
DO:
  if INPUT FRAME Dialog-Frame tt-WTH-PLACE.cash-desk = 0 then return.
  FIND FIRST buf_CASH-DESK NO-LOCK WHERE
             buf_CASH-DESK.CASH-NUM = INPUT FRAME Dialog-Frame tt-WTH-PLACE.cash-desk AND
             buf_cash-desk.obj-code = tt-wth-place.obj-code AND
             buf_cash-desk.db-num = vardb-num NO-ERROR.
  if not avail buf_cash-desk then do:
    message
    "Нет кассы с N" INPUT FRAME Dialog-Frame tt-WTH-PLACE.cash-desk
    view-as alert-box ERROR.
  end.
  else if buf_cash-desk.obj-code <> tt-wth-place.obj-code then do:
    message
    "Выбранная касса принадлежит другому магазину"
    view-as alert-box ERROR.
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
    if par-mode <> 'ИЗМЕНЕНИЕ':U and par-mode <> 'ДОБАВЛЕНИЕ':U and par-mode <> 'ПРОСМОТР':U then do:
        message vss-workfile vss-revision vss-description skip
                    "Неверный параметр вызова par-mode"
        view-as alert-box ERROR.
        return error.
    end.
    find first ub.sysconf No-LOCK WHERE
                     ub.sysconf.host-code = parhost-code No-ERROR.
    if not avail ub.sysconf then do:
        message vss-workfile vss-revision vss-description skip
                        "Неверный параметр вызова parhost-code"
            view-as alert-box ERROR.
            return error.
    end.
    find first ub.clients No-LOCK WHERE
                ub.clients.obj-type = parobj-type AND
                ub.clients.obj-code = parobj-code No-ERROR.
    if not avail ub.clients then do:
        message vss-workfile vss-revision vss-description skip
                        "Неверный параметр вызова parobj-type/parobj-code"
            view-as alert-box ERROR.
            return error.
    end.
    vardb-num = ub.clients.db-num.
    find first ub.sys-ctrl No-LOCK.
    if vardb-num <> ub.sys-ctrl.db-num then do:
      if par-mode <> 'ПРОСМОТР':U then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверный параметр вызова par-mode" par-mode
        "для объекта, принадлежащего другой БД"
        view-as alert-box error .
        return error .
      end.
    end.
    tt-wth-place.obj-type:list-items =
                                    'маг':U + chr(44) +
                                    'скл':U + chr(44).
  Run fill-tables in this-procedure no-error.
  if error-status:error then return error.
  RUN MYenable.
  WAIT-FOR GO OF FRAME Dialog-Frame FOCUS tt-wth-place.w-p-name.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH tt-wth-place SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY for-obj-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-wth-place THEN
    DISPLAY tt-wth-place.obj-code tt-wth-place.obj-type tt-wth-place.w-p-code
          tt-wth-place.w-p-name tt-wth-place.cash-desk
          tt-wth-place.main-cash-desk tt-wth-place.PS tt-wth-place.host-code
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-hist B-Help tt-wth-place.obj-code
         tt-wth-place.obj-type tt-wth-place.w-p-code tt-wth-place.w-p-name
         b-cash-desk tt-wth-place.cash-desk tt-wth-place.main-cash-desk
         tt-wth-place.PS tt-wth-place.host-code for-obj-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE fill-tables :
for each tt-wth-place:
    delete tt-wth-place.
end.
IF par-mode = 'ДОБАВЛЕНИЕ':U then do:
    DO TRANSACTION ON ERROR UNDO, RETURN ERROR return-value :
      create tt-wth-place.
      assign
      tt-wth-place.host-code = parhost-code
      tt-wth-place.obj-type = parobj-type
      tt-wth-place.obj-code = parobj-code
      tt-wth-place.status_ = 'тек':U
      .
    END.
    FIND FIRST buf_obj No-LOCK WHERe
                buf_obj.obj-type = parobj-type AND
                buf_obj.obj-code = parobj-code No-ERROR.
end.
else do:
  if par-mode = 'ПРОСМОТР':U then do:
    FIND FIRST locked_wth-place NO-LOCK WHERE
                recid(locked_wth-place) = par-ri.
  end.
  ELSE do:
    DO TRANSACTION
      ON ERROR UNDO, RETURN ERROR:
           FIND FIRST locked_wth-place NO-LOCK WHERE
                recid(locked_wth-place) = par-ri.
    END.
  END.
  if
  locked_wth-place.host-code <> parhost-code or
  locked_wth-place.obj-type<> parobj-type or
  locked_wth-place.obj-code <> parobj-code then do:
    message vss-workfile vss-revision vss-description skip
                        "Неверный параметр вызова parhost-code и/или"
                        "parobj-type/parobj-code"
            view-as alert-box ERROR.
            return error.
end.
  IF NOT AVAIL locked_wth-place then
  return error.
  create tt-wth-place.
  buffer-copy locked_wth-place to tt-wth-place.
    FIND FIRST buf_obj No-LOCK WHERe
                buf_obj.obj-type = tt-wth-place.obj-type AND
                buf_obj.obj-code = tt-wth-place.obj-code No-ERROR.
    if not avail buf_obj then do:
      message "Место хранения" locked_wth-place.w-p-code  skip
              "Неверный объект" locked_wth-place.obj-type locked_wth-place.obj-code
      view-as alert-box ERROR.
      return error.
    end.
    if tt-wth-place.obj-type = 'скл':U then do:
        if tt-wth-place.cash-desk <>  0 then do:
        FIND FIRST buf_cash-desk No-LOCK WHERE
                buf_cash-desk.db-num = vardb-num AND
                buf_cash-desk.obj-code = tt-wth-place.obj-code AND
                buf_cash-desk.cash-num = tt-wth-place.cash-desk No-ERROR.
            if not avail buf_cash-desk then do:
              message "Место хранения" locked_wth-place.w-p-code  skip
                      "Неверный номер кассы" locked_wth-place.cash-desk
              view-as alert-box ERROR.
              return error.
            end.
    end.
    end.
end.
END PROCEDURE.
PROCEDURE MyEnable :
  DISPLAY for-obj-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-wth-place THEN
    DISPLAY
    tt-wth-place.obj-type
    tt-wth-place.obj-code
    tt-wth-place.w-p-code
    tt-wth-place.w-p-name
    tt-wth-place.cash-desk
    tt-wth-place.main-cash-desk
    tt-wth-place.PS
    tt-wth-place.host-code
    WITH FRAME Dialog-Frame.
    if available buf_obj then
    display
    buf_obj.obj-name @ for-obj-name
    WITH FRAME Dialog-Frame.
    CASE par-mode:
        when 'ДОБАВЛЕНИЕ':U then do:
            ENABLE
            B-exit
            b-quit
            B-Help
            tt-wth-place.w-p-name
            b-cash-desk when tt-wth-place.obj-type = 'маг':U
            tt-wth-place.cash-desk when tt-wth-place.obj-type = 'маг':U
            tt-wth-place.main-cash-desk  when tt-wth-place.obj-type = 'маг':U
            tt-wth-place.PS
            WITH FRAME Dialog-Frame.
        end.
        when 'ИЗМЕНЕНИЕ':U then do:
                    ENABLE
                    B-exit
                    b-quit
                    B-Help
                    tt-wth-place.w-p-name
                    b-cash-desk when tt-wth-place.obj-type = 'маг':U
                    tt-wth-place.cash-desk when tt-wth-place.obj-type = 'маг':U
                    tt-wth-place.main-cash-desk  when tt-wth-place.obj-type = 'маг':U
                    tt-wth-place.PS
                    WITH FRAME Dialog-Frame.
        end.
        when 'ПРОСМОТР':U then do:
            b-quit:label = "&Выход".
                        HIDE
                        b-exit
                        in frame Dialog-Frame.
        end.
    END CASE.
  ENABLE
  b-quit
  B-Help
  b-hist WHEN par-mode <> 'ДОБАВЛЕНИЕ':U
  WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-save-record :
 IF par-mode = 'ПРОСМОТР':U THEN DO:
    RETURN error.
 END.
 assign
tt-wth-place.w-p-code frame Dialog-Frame
tt-wth-place.host-code
tt-wth-place.obj-type
tt-wth-place.obj-code
tt-wth-place.w-p-name
tt-wth-place.cash-desk
tt-wth-place.main-cash-desk
tt-wth-place.PS
 .
 if par-mode <> 'ДОБАВЛЕНИЕ':U then
 par-ri = recid(locked_wth-place).
 else par-ri = ?.
 run ref/wthplfr1.p (
                  input-output par-ri
                 ,input        par-mode
                 ,input tt-wth-place.w-p-code
                 ,input tt-wth-place.host-code
                 ,input tt-wth-place.obj-type
                 ,input tt-wth-place.obj-code
                 ,input tt-wth-place.w-p-name
                 ,input tt-wth-place.status_
                 ,input tt-wth-place.cash-desk
                 ,input tt-wth-place.main-cash-desk
                 ,input tt-wth-place.PS
                 ) no-error .
    IF ERROR-STATUS:ERROR THEN DO:
    if return-value <> '':U then do:
      CASE return-value:
        when "obj-code":U then do:
          APPLY "ENTRY":U TO tt-wth-place.obj-code IN FRAME Dialog-Frame.
        end.
        when "cash-desk":U then do:
          APPLY "ENTRY":U TO tt-wth-place.cash-desk IN FRAME Dialog-Frame.
        end.
        when "main-cash-desk":U then do:
          APPLY "ENTRY":U TO tt-wth-place.main-cash-desk IN FRAME Dialog-Frame.
        end.
      END CASE.
    end.
    RETURN error.
  END.
END PROCEDURE.
