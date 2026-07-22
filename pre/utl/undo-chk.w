define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "".
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
define stream imp-str.
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1.
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON BUTTON-1
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE VARIABLE filename AS CHARACTER FORMAT "X(256)":U
     LABEL "Имя файла"
     VIEW-AS FILL-IN
     SIZE 51 BY 1 NO-UNDO.
DEFINE VARIABLE ii AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0
     LABEL "Просмотрено чеков"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE ii-ok AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0
     LABEL "Импортировано чеков"
     VIEW-AS FILL-IN
     SIZE 14 BY 1.
DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1 COL 1
     Btn_Cancel AT ROW 1 COL 11
     b-help AT ROW 1 COL 58 WIDGET-ID 2
     filename AT ROW 2.6 COL 11 COLON-ALIGNED
     BUTTON-1 AT ROW 2.6 COL 65.5
     ii AT ROW 4.07 COL 19.6 COLON-ALIGNED
     ii-ok AT ROW 5.4 COL 20 COLON-ALIGNED
     SPACE(32.89) SKIP(2.62)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Загрузка Архивов по чекам"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame
DO:
    if filename = ""  then   do:
        message "Неправильно введено имя дампа" view-as alert-box message.
        return no-apply.
    end.
    RUN exp-arh(filename).
END.
ON CHOOSE OF BUTTON-1 IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE OKpressed AS LOGICAL INITIAL TRUE.
  system-dialog get-file filename
  SAVE-AS
         USE-FILENAME
        UPDATE OKpressed.
  if okpressed then
    disp filename with frame dialog-frame.
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
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY filename ii ii-ok
      WITH FRAME Dialog-Frame.
  ENABLE Btn_OK Btn_Cancel b-help BUTTON-1
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE exp-arh :
    def input param filename as char no-undo.
    define variable t-name as char no-undo.
    define variable date-ga as char no-undo.
disable triggers for  load   of ub.chk-doc.
disable triggers for  load   of ub.chk-gds.
disable triggers for  load   of ub.chk-pay.
disable triggers for  load   of ub.chk-discnt.
disable triggers for  load   of ub.chk-doc-attr.
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_inkas   for ub.inkas.
define variable v-import as logical no-undo .
define variable v-doc-code   like ub.chk-doc.doc-code no-undo .
define variable v-inkas-code like ub.inkas.inkas-code no-undo .
define variable v-skip as character no-undo .
define variable v-version as decimal no-undo .
define variable glog as logical no-undo .
message
"Внимание!" skip
"Файл-источник" filename
"после импорта будет уничтожен, сделайте резервную копию" skip
"Продолжить?"
view-as alert-box question update glog.
if not glog then return.
assign
ii = 0
ii-ok = 0
.
    input stream imp-str from value(filename).
    import stream imp-str unformatted t-name.
    if index(t-name, "v1.01":U) > 0 then do:
      assign
      v-version = 1.01
      .
    end.
    else do:
      assign
      v-inkas-code = "":U
      v-import = yes
      .
    end.
    DO ON ERROR   UNDO, RETURN ERROR
      ON ENDKEY UNDO, RETURN ERROR
      ON STOP      UNDO, RETURN ERROR:
        _repeat:
        repeat:
            disp ii ii-ok with frame Dialog-Frame.
            if v-version = 0 then do:
              import stream imp-str t-name.
            end.
            if v-version = 1.01 then do:
              import stream imp-str t-name v-inkas-code v-doc-code.
            end.
            case t-name:
    when "chk-doc" then do:
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
          assign
          v-import = no
          ii = ii + 1
          .
          if v-inkas-code = "":U then do:
            assign
            v-import = yes
            ii-ok = ii-ok + 1
            .
          end.
          else do:
            if v-inkas-code = ? then do:
              assign
              v-import = no
              .
            end.
            else do:
              find first buf_inkas where
                        buf_inkas.inkas-code = v-inkas-code no-error .
              if available buf_inkas
              and (buf_inkas.status_ = 'факт':U
                  or
              buf_inkas.status_ = 'запрос':U  )
              then do:
                find first buf_chk-doc no-lock where
                          buf_chk-doc.doc-code = v-doc-code no-error.
                if not available buf_chk-doc then do:
                  assign
                  v-import = yes
                  ii-ok = ii-ok + 1
                  .
                end.
              end.
            end.
          end.
        if v-import = yes then do:
          create chk-doc.
          import stream imp-str chk-doc no-error .
          if error-status:error then do:
             undo _repeat, next _repeat.
          end.
        end.
        else do:
          import stream imp-str unformatted v-skip.
        end.
    end.
    when "chk-pay" then do:
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
        if v-import = yes then do:
          create chk-pay.
          import stream imp-str chk-pay no-error .
          if error-status:error then do:
             undo _repeat, next _repeat.
          end.
        end.
        else do:
          import stream imp-str unformatted v-skip.
        end.
    end.
    when "chk-gds" then do:
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
        if v-import = yes then do:
          create chk-gds.
          import stream imp-str chk-gds no-error .
          if error-status:error then do:
             undo _repeat, next _repeat.
          end.
        end.
        else do:
          import stream imp-str unformatted v-skip.
        end.
    end.
    when "chk-discnt" then do:
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
        if v-import = yes then do:
          create chk-discnt.
          import stream imp-str chk-discnt no-error .
          if error-status:error then do:
             undo _repeat, next _repeat.
          end.
        end.
        else do:
          import stream imp-str unformatted v-skip.
        end.
    end.
    when "chk-doc-attr" then do:
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
        if v-import = yes then do:
          create chk-doc-attr.
          import stream imp-str chk-doc-attr no-error .
          if error-status:error then do:
             undo _repeat, next _repeat.
          end.
        end.
        else do:
          import stream imp-str unformatted v-skip.
        end.
    end.
            end case.
        end.
    end.
    input stream imp-str close.
    os-delete value(filename).
    message "Загрузка чеков закончена. "  view-as alert-box message.
END PROCEDURE.
