DEFINE BUFFER locked_point-io FOR ub.point-io.
DEFINE TEMP-TABLE tt-point-io NO-UNDO LIKE ub.point-io.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-db-num      as integer   no-undo .
define input parameter p-cli-type like ub.clients.obj-type no-undo .
define input parameter p-cli-code like ub.clients.obj-code no-undo .
define input parameter p-mode        as character no-undo.
define input-output parameter p-rep-rec     as recid no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "создание и изменение пунктов отгрузки/доставки".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define buffer buf_clients for ub.clients.
define buffer buf_person for ub.person.
define buffer buf_firm for ub.firm.
define variable glog as logical no-undo .
DEFINE BUTTON b-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "2"
     SIZE 2.9 BY 1.
DEFINE BUTTON b-deliv-subj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "2"
     SIZE 2.9 BY 1.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1.
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 3 BY 1.
DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.
DEFINE BUTTON B-object
     LABEL "О&бъект"
     SIZE 10 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1.
DEFINE VARIABLE cli-name AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 90.7 BY 1.
DEFINE VARIABLE deliv-subj-name AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 58.7 BY 1.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 98 BY 2.5.
DEFINE QUERY Dialog-Frame FOR
      tt-point-io SCROLLING.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-hist AT ROW 1 COL 92
     b-help AT ROW 1 COL 95
     B-object AT ROW 2.43 COL 31 WIDGET-ID 4
     tt-point-io.cli-code AT ROW 2.47 COL 13.3 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     tt-point-io.cli-type AT ROW 2.47 COL 19.6 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 4.4 BY 1
     b-cli AT ROW 2.47 COL 26.8
     tt-point-io.point-type AT ROW 5 COL 3 NO-LABEL
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "доставки", "1":U,
"отгрузки", "2":U
          SIZE 26.5 BY 1
     tt-point-io.point-code AT ROW 5 COL 42.5 COLON-ALIGNED
          LABEL "Номер"
          VIEW-AS FILL-IN
          SIZE 19.5 BY 1
     tt-point-io.point-name AT ROW 6.33 COL 10 COLON-ALIGNED
          LABEL "Название"
          VIEW-AS FILL-IN
          SIZE 52 BY 1
     tt-point-io.deliv-subj-code AT ROW 7.4 COL 4.5 WIDGET-ID 8
          LABEL "Код субъекта доставки" FORMAT "->,>>>,>>9"
          VIEW-AS FILL-IN
          SIZE 9 BY 1
     b-deliv-subj AT ROW 7.4 COL 37 WIDGET-ID 6
     tt-point-io.address AT ROW 9 COL 3 COLON-ALIGNED NO-LABEL WIDGET-ID 12
          VIEW-AS FILL-IN
          SIZE 87 BY 1
     tt-point-io.is-default AT ROW 11 COL 31.5
          LABEL "По умолчанию"
          VIEW-AS TOGGLE-BOX
          SIZE 32.5 BY .83
     tt-point-io.PS AT ROW 13 COL 1 NO-LABEL
          VIEW-AS FILL-IN
          SIZE 98 BY 3.67
     cli-name AT ROW 3.47 COL 2.8 NO-LABEL
     deliv-subj-name AT ROW 7.4 COL 41 NO-LABEL WIDGET-ID 10
     "Примечание:" VIEW-AS TEXT
          SIZE 15 BY .67 AT ROW 12.3 COL 3
     "Контрагент:" VIEW-AS TEXT
          SIZE 12.1 BY 1 AT ROW 2.47 COL 2.9
          FGCOLOR 4
     RECT-2 AT ROW 2.27 COL 1.5
     SPACE(0.39) SKIP(13.29)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Пункт отгрузки/доставки".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       tt-point-io.point-code:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-cli IN FRAME Dialog-Frame
DO:
  define variable  v-rid-list as character no-undo .
  run ref/cli-all.w ( input parParentProc
                    ,input "b-sel"
                    ,input 'все':U
                    ,input 'все':U
                    ,input  'текущие':U
                    ,input ?
                    ,input "
                    ,,,,,,NO,,":u
                    , "without-obj":U
                    ,output v-rid-list ) .
  if v-rid-list <> "" then do:
    find first buf_clients no-lock where RECID(buf_clients) = int (v-rid-list) no-error.
    assign
    tt-point-io.cli-type = buf_clients.obj-type
    tt-point-io.cli-code = buf_clients.obj-code
    .
    assign
    tt-point-io.point-type .
    run find-cli in this-procedure ( input tt-point-io.cli-type
                                    , input tt-point-io.cli-code)  .
  end.
  else do:
    assign
    cli-name = ""
    tt-point-io.cli-code = ?
    tt-point-io.cli-type  = ? .
    display
    cli-name
    tt-point-io.cli-type
    tt-point-io.cli-code
    with frame Dialog-Frame.
  end.
END.
ON CHOOSE OF b-deliv-subj IN FRAME Dialog-Frame
DO:
  define buffer buf_delivery-subject for ub.delivery-subject.
  define variable v-rid-list as character no-undo.
  define variable v-stts as integer no-undo .
  v-stts = integer('0':U).
  run ref/dlvsubjs.w (input parParentProc
                , v-cntxt-obj-type
                , v-cntxt-obj-code
                , "b-sel":U
                , 'все':U
                , input-output v-stts
                , input-output v-rid-list ) no-error .
  if v-rid-list <> ? then do :
    find first buf_delivery-subject no-lock
      where recid(buf_delivery-subject) = integer(v-rid-list)
    no-error .
    if not available buf_delivery-subject then do:
      message
      "Неверный код субъекта доставки " v-rid-list
      view-as alert-box error.
      return no-apply.
    end.
    else do:
      assign
      tt-point-io.deliv-subj-code = buf_delivery-subject.deliv-subj-code
      .
      display
      tt-point-io.deliv-subj-code
      buf_delivery-subject.deliv-subj-name @ deliv-subj-name
      with frame Dialog-Frame.
    end.
  end.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
  run proc-save in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-hist IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  if not available locked_point-io then return .
  run ref/ptiohist.w ( INPUT parParentProc
                     , input locked_point-io.db-num
                     , input locked_point-io.point-code
                     , input "":U
                     , input-output v-rid-list
                     ) no-error .
END.
ON CHOOSE OF B-object IN FRAME Dialog-Frame
DO:
  define buffer b#clients for ub.clients.
  define variable v-type as char no-undo.
  define variable v-code as int no-undo.
  define buffer buf_person for ub.person.
  define buffer buf_firm for ub.firm.
  define buffer buf_shop for ub.shop.
  define buffer buf_store for ub.store.
  run str/chshobj.w ( tt-point-io.cli-code
                      , input ""
                      , input 0
                      , output v-type
                      , OUTPUT v-code).
  find first b#clients WHERE
         v-code = b#clients.obj-code
     AND v-type = b#clients.obj-type No-LOCK No-ERROR.
  if available b#clients then do:
    assign tt-point-io.point-name = b#clients.obj-name .
    Case b#clients.obj-type :
      when  'орг':U then do :
        FIND buf_firm  WHERE
              buf_firm.firm-code = b#clients.obj-code NO-LOCK.
        Assign tt-point-io.address = buf_firm.addres1 .
      end.
      when  'чел':U then do :
        FIND buf_person  WHERE
           buf_person.psn-code = b#clients.obj-code NO-LOCK.
        Assign tt-point-io.address = buf_person.address .
      end.
      when  'маг':U then do :
        FIND buf_shop  WHERE buf_shop.obj-code = b#clients.obj-code NO-LOCK.
        Assign tt-point-io.address = buf_shop.addres1 .
      end.
      when  'скл':U then do :
        FIND buf_store  WHERE buf_store.obj-code = b#clients.obj-code NO-LOCK.
        Assign tt-point-io.address = buf_store.addres1 .
      end.
    End case.
    display
    tt-point-io.point-name
    tt-point-io.address with frame Dialog-Frame.
  end.
END.
ON CHOOSE OF b-quit IN FRAME Dialog-Frame
DO:
p-rep-rec = ?.
END.
ON LEAVE OF tt-point-io.cli-code IN FRAME Dialog-Frame
DO:
  if tt-point-io.cli-code = int ( tt-point-io.cli-code:screen-value ) then return.
  assign
  tt-point-io.cli-code
  tt-point-io.point-type .
  run find-cli in this-procedure ( input tt-point-io.cli-type
                                 , input tt-point-io.cli-code)  .
END.
ON RETURN OF tt-point-io.cli-code IN FRAME Dialog-Frame
DO:
  if tt-point-io.cli-code = int ( tt-point-io.cli-code:screen-value ) then return.
  assign
  tt-point-io.cli-code
  tt-point-io.point-type .
  run find-cli in this-procedure ( input tt-point-io.cli-type
                                 , input tt-point-io.cli-code)  .
END.
ON LEAVE OF tt-point-io.cli-type IN FRAME Dialog-Frame
DO:
  assign
  tt-point-io.cli-type
  tt-point-io.point-type .
  run find-cli in this-procedure ( input tt-point-io.cli-type
                                  , input tt-point-io.cli-code)  .
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON stop UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
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
 if p-cli-code > 0
 and p-mode = 'ДОБАВЛЕНИЕ':U
 then do:
   find first buf_clients no-lock where
            buf_clients.obj-type = p-cli-type
       AND buf_clients.obj-code = p-cli-code no-error.
  if not available buf_clients then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-cli-type/p-cli-code"
    p-cli-type p-cli-code
    view-as alert-box ERROR.
    return error .
  end.
 end.
 for each tt-point-io:
    delete tt-point-io.
  end.
  if p-mode = 'ИЗМЕНЕНИЕ':U
  or p-mode = 'ПРОСМОТР':U then do:
    if p-mode = 'ИЗМЕНЕНИЕ':U then do:
      find first locked_point-io EXclusive-lock where
                   recid(locked_point-io) = p-rep-rec no-error.
    end.
    else do:
      find first locked_point-io no-lock where
                       recid(locked_point-io) = p-rep-rec no-error .
    end.
    if not available locked_point-io then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись ПУНКТ ДОСТАВКИ/ОТГРУЗКИ"
      view-as alert-box error .
      undo, return error.
    end.
    find first buf_clients no-lock where
            buf_clients.obj-type = locked_point-io.cli-type
       AND buf_clients.obj-code = locked_point-io.cli-code no-error.
    create tt-point-io.
    buffer-copy locked_point-io to tt-point-io.
    if available buf_clients then do:
      cli-name = buf_clients.obj-name.
    end.
  end.
  else do:
    create tt-point-io.
    assign
    tt-point-io.db-num = v-cntxt-db-num.
    tt-point-io.point-type = 'доставки':U.
    if available buf_clients then do:
      assign
      cli-name = buf_clients.obj-name
      tt-point-io.cli-type = p-cli-type
      tt-point-io.cli-code = p-cli-code
      .
    end.
  end.
  RUN Myenable in this-procedure .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY cli-name deliv-subj-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-point-io THEN
    DISPLAY tt-point-io.cli-code tt-point-io.cli-type tt-point-io.point-type
          tt-point-io.point-code tt-point-io.point-name
          tt-point-io.deliv-subj-code tt-point-io.address tt-point-io.is-default
          tt-point-io.PS
      WITH FRAME Dialog-Frame.
  ENABLE b-exit RECT-2 b-quit B-hist b-help B-object tt-point-io.cli-code
         tt-point-io.cli-type b-cli tt-point-io.point-type
         tt-point-io.point-code tt-point-io.point-name
         tt-point-io.deliv-subj-code b-deliv-subj tt-point-io.address
         tt-point-io.is-default tt-point-io.PS
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE find-cli :
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define buffer buf_sysconf for ub.sysconf.
define buffer buf_point-io for ub.point-io.
if p-obj-type <> 'орг':U and p-obj-type <> 'чел':U then do:
  find first buf_clients no-lock where
           buf_clients.obj-type = 'орг':U
       and buf_clients.obj-code = p-obj-code no-error.
  if not available buf_clients then do:
    find first buf_clients no-lock where
           buf_clients.obj-type = 'чел':U
       and buf_clients.obj-code = p-obj-code no-error.
  end.
end.
else do:
  find first buf_clients no-lock where
           buf_clients.obj-type = p-obj-type
       and buf_clients.obj-code = p-obj-code no-error.
end.
if not available buf_clients then do:
  if p-obj-code = 0 then assign p-obj-code = ? .
  if p-obj-code = ? then do:
    assign
    cli-name = ""
    tt-point-io.cli-code = ?
    tt-point-io.cli-type  = ? .
    display
    cli-name
    tt-point-io.cli-code
    tt-point-io.cli-type
    with frame Dialog-Frame.
  end.
  else do:
    apply "CHOOSE" to b-cli IN FRAME Dialog-Frame  .
  end.
  return.
end.
if buf_clients.obj-type = 'орг':U then do:
  find first buf_firm no-lock where
            buf_firm.firm-code = buf_clients.obj-code no-error.
  if available buf_firm then
  assign tt-point-io.address = buf_firm.addres1 .
  find first buf_sysconf no-lock where
           buf_sysconf.host-code = buf_clients.obj-code no-error .
  if available buf_sysconf then do:
     assign
     B-object:visible = yes .
  end.
  else do:
    assign
    B-object:visible = no .
  end.
end.
else do:
  find first buf_person no-lock where
           buf_person.psn-code = buf_clients.obj-code no-error.
  if available buf_person then
  assign  tt-point-io.address = buf_person.address .
end.
find first buf_point-io no-lock
  where buf_point-io.cli-code   = buf_clients.obj-code
    and buf_point-io.cli-type   = buf_clients.obj-type
    and buf_point-io.point-type = tt-point-io.point-type
    and buf_point-io.is-default = yes
no-error .
if available buf_point-io then do:
  assign
  tt-point-io.is-default = no .
end.
else do:
  assign
  tt-point-io.is-default = yes .
end.
assign
cli-name  = buf_clients.obj-name
tt-point-io.cli-code  = p-obj-code
tt-point-io.cli-type  = buf_clients.obj-type.
display
cli-name
tt-point-io.cli-code
tt-point-io.cli-type
tt-point-io.address
tt-point-io.is-default
with frame Dialog-Frame.
END PROCEDURE.
PROCEDURE Myenable :
define buffer buf_sysconf for ub.sysconf.
define buffer buf_delivery-subject for ub.delivery-subject.
IF tt-point-io.deliv-subj-code > 0  THEN DO:
  find first buf_delivery-subject no-lock
      where buf_delivery-subject.deliv-subj-code = tt-point-io.deliv-subj-code
    no-error .
  if not available buf_delivery-subject then do:
    message
    SUBSTITUTE("Неверный код субъекта доставки &1", tt-point-io.deliv-subj-code)
    view-as alert-box error.
   end.
   deliv-subj-name = buf_delivery-subject.deliv-subj-name.
END.
assign
frame Dialog-Frame:title = substitute("Пункт отгрузки/доставки         &1", p-mode).
assign
tt-point-io.point-type:radio-buttons  in frame Dialog-Frame
 =  'доставки':U + chr(44) + 'доставки':U + chr(44) +
                          'отгрузки':U + chr(44) + 'отгрузки':U .
DISPLAY
cli-name
deliv-subj-name
WITH FRAME Dialog-Frame .
IF AVAILABLE tt-point-io THEN do:
  DISPLAY
  tt-point-io.cli-code
  tt-point-io.cli-type
  tt-point-io.point-code
  tt-point-io.point-name
  tt-point-io.deliv-subj-code
  tt-point-io.address
  tt-point-io.is-default
  tt-point-io.PS
  tt-point-io.point-type
  WITH FRAME Dialog-Frame .
end.
if p-mode <> 'ПРОСМОТР':U then do:
  if tt-point-io.cli-type = 'орг':U then do:
    find first buf_sysconf no-lock where
            buf_sysconf.host-code = cli-code no-error .
    if available buf_sysconf then do:
      assign B-object:visible = yes .
    end.
    else do:
      assign B-object:visible = no .
    end.
  end.
  else do:
    assign B-object:visible = no .
  end.
end.
else
assign
B-object:visible = no .
ENABLE
b-exit when p-mode <> 'ПРОСМОТР':U
b-quit
B-hist  when p-mode <> 'ДОБАВЛЕНИЕ':U
b-help
B-object  when b-object:visible in frame Dialog-Frame
tt-point-io.cli-code when p-mode = 'ДОБАВЛЕНИЕ':U
tt-point-io.cli-type when p-mode = 'ДОБАВЛЕНИЕ':U
b-cli when p-mode = 'ДОБАВЛЕНИЕ':U
tt-point-io.point-type  when p-mode <> 'ПРОСМОТР':U
tt-point-io.point-code
tt-point-io.point-name  when p-mode <> 'ПРОСМОТР':U
b-deliv-subj when p-mode <> 'ПРОСМОТР':U
tt-point-io.address  when p-mode <> 'ПРОСМОТР':U
tt-point-io.is-default  when p-mode <> 'ПРОСМОТР':U
tt-point-io.ps
RECT-2
WITH FRAME Dialog-Frame .
if p-mode = 'ПРОСМОТР':U then do:
  tt-point-io.PS:read-only = yes.
  b-quit:column = 1.
  b-exit:visible = no.
  b-quit:label = "&Выход".
end.
VIEW FRAME Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-save :
define variable v-rep-rec as recid no-undo .
assign
frame Dialog-Frame
tt-point-io.ps
tt-point-io.point-name
tt-point-io.point-type
tt-point-io.address
tt-point-io.is-default
tt-point-io.deliv-subj-code
v-rep-rec = recid(locked_point-io)
.
run ref/pt-io-f1.p ( input-output v-rep-rec
                    ,input p-mode
                    ,input no
                    ,input tt-point-io.point-code
                    ,input tt-point-io.db-num
                    ,input tt-point-io.cli-type
                    ,input tt-point-io.cli-code
                    ,input tt-point-io.point-name
                    ,input tt-point-io.point-type
                    ,input tt-point-io.deliv-subj-code
                    ,input tt-point-io.is-default
                    ,input tt-point-io.address
                    ,input tt-point-io.ps ) no-error.
if error-status:error then do:
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
if return-value = "quit" then undo, return error .
p-rep-rec = v-rep-rec.
END PROCEDURE.
