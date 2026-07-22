define input parameter parparentproc as widget-handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Управление расписанием сообщений" .
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
define buffer buf_clients for ub.clients .
define buffer buf2_clients for ub.clients .
define buffer buf_clients-attr for ub.clients-attr .
DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
DEFINE BUTTON b-ok AUTO-GO
     LABEL "Ввод"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
DEFINE VARIABLE f-level AS integer FORMAT ">>9":U
     LABEL "Сообщения по превышению уровня повторять каждые"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE f-water AS integer FORMAT ">>9":U
     LABEL "Сообщения по воде повторять каждые"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE rs-obj AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Текущий объект", 1,
"По фирме", 2
     SIZE 36 BY 1.1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-ok AT ROW 1.24 COL 3
     b-cancel AT ROW 1.24 COL 17.8
     f-water AT ROW 3.14 COL 58 COLON-ALIGNED WIDGET-ID 2
     f-level AT ROW 4.57 COL 58 COLON-ALIGNED WIDGET-ID 6
     rs-obj AT ROW 6.48 COL 35 NO-LABEL WIDGET-ID 10
     "Установить на:" VIEW-AS TEXT
          SIZE 17 BY .62 AT ROW 6.67 COL 15.8 WIDGET-ID 14
     "мин." VIEW-AS TEXT
          SIZE 6 BY .62 AT ROW 3.33 COL 70.6 WIDGET-ID 4
     "мин." VIEW-AS TEXT
          SIZE 6 BY .62 AT ROW 4.81 COL 70.6 WIDGET-ID 8
     SPACE(1.39) SKIP(2.85)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Управление расписанием сообщений"
         DEFAULT-BUTTON b-ok CANCEL-BUTTON b-cancel WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-ok IN FRAME Dialog-Frame
DO:
  assign
    f-water
    f-level
    rs-obj
  .
  case rs-obj :
    when 1
    then do :
      run save-obj (input p-obj-type,
                    input p-obj-code)
                    .
      run trg/userlog.p (
              input 'atd-alarm-sched'
            , input ("Период алармов с АТД на объекте " +
                    buf_clients.obj-type + string(buf_clients.obj-code) +
                    substitute("; вода: &1мин; уровень: &2мин", f-water, f-level) +
                    chr(3) +
                    buf_clients.obj-type + string(buf_clients.obj-code) +
                    substitute("; вода: &1мин; уровень: &2мин", f-water, f-level) )
            , input ?
            , input ?
            , input ""
            ) no-error.
      if error-status :error
      then do:
          message return-value + error-status:get-message(1) view-as alert-box title "Ошибка записи истории действий пользователя".
      end.
    end .
    when 2
    then do :
      for each buf2_clients no-lock where buf2_clients.host-code = buf_clients.host-code :
        run save-obj (input buf2_clients.obj-type,
                      input buf2_clients.obj-code)
                      .
      end .
      run trg/userlog.p (
              input 'atd-alarm-sched'
            , input ("Период алармов с АТД по фирме орг" +
                    string(buf_clients.host-code) +
                    substitute("; вода: &1мин; уровень: &2мин", f-water, f-level) +
                    chr(3) +
                    "орг" + string(buf_clients.host-code) +
                    substitute("; вода: &1мин; уровень: &2мин", f-water, f-level) )
            , input ?
            , input ?
            , input ""
            ) no-error.
      if error-status :error
      then do:
          message return-value + error-status:get-message(1) view-as alert-box title "Ошибка записи истории действий пользователя".
      end.
    end .
  end case .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  find first buf_clients no-lock where buf_clients.obj-type = p-obj-type
                                   and buf_clients.obj-code = p-obj-code
                                   .
  for first buf_clients-attr no-lock where buf_clients-attr.obj-type = buf_clients.obj-type
                                       and buf_clients-attr.obj-code = buf_clients.obj-code
                                       and buf_clients-attr.attr-code = 'atd-alarm-schedule':U
                                       and buf_clients-attr.attr-value > ""
                                       :
    if num-entries(buf_clients-attr.attr-value) = 2
    then do :
      f-water = integer(entry(1, buf_clients-attr.attr-value)) .
      f-level = integer(entry(2, buf_clients-attr.attr-value)) .
    end .
  end .
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
procedure save-obj :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  find first buf_clients-attr exclusive-lock where buf_clients-attr.obj-type = p-obj-type
                                               and buf_clients-attr.obj-code = p-obj-code
                                               and buf_clients-attr.attr-code = 'atd-alarm-schedule':U
                                               no-error .
  if not available buf_clients-attr
  then do :
    create buf_clients-attr .
    assign
      buf_clients-attr.obj-type = p-obj-type
      buf_clients-attr.obj-code = p-obj-code
      buf_clients-attr.attr-code = 'atd-alarm-schedule':U
    .
  end.
  assign
    buf_clients-attr.attr-value = string(f-water) + "," + string(f-level)
  .
end procedure .
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY f-water f-level rs-obj
      WITH FRAME Dialog-Frame.
  ENABLE b-ok b-cancel f-water f-level rs-obj
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
