define input parameter parparentproc as widget-handle   no-undo.
define input parameter p-mode       as character    no-undo.
define input parameter p-store-type as character    no-undo.
define input parameter p-store-code as integer      no-undo.
define input parameter p-grp-code   as integer      no-undo.
define input parameter p-upper-code as integer      no-undo.
define input parameter p-in-name    as character    no-undo.
define input parameter p-in-code    as integer      no-undo.
define output parameter p-out-name  as character    no-undo.
define output parameter p-out-code  as integer      no-undo.
define output parameter p-cancel    as logical initial yes no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр и редактирование группы блюд".
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
define variable dflt-cd as character no-undo .
DEFINE BUTTON b-cancel
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-exit
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помощ&ь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1.
DEFINE VARIABLE fi-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Наименование"
     VIEW-AS FILL-IN
     SIZE 46.63 BY 1 NO-UNDO.
DEFINE VARIABLE fi-out-code AS INTEGER FORMAT ">>9":U INITIAL 0
     LABEL "Код кассы"
     VIEW-AS FILL-IN
     SIZE 11.38 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-cancel AT ROW 1 COL 11
     B-hist AT ROW 1 COL 41
     b-help AT ROW 1 COL 51
     fi-name AT ROW 3.13 COL 1.63
     fi-out-code AT ROW 4.5 COL 13.63 COLON-ALIGNED
     SPACE(36.23) SKIP(0.53)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Группа блюд"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-cancel.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-cancel IN FRAME Dialog-Frame
DO:
    assign
        p-cancel   = yes
    .
    apply "WINDOW-CLOSE" TO FRAME Dialog-Frame .
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
    assign
        fi-name
        fi-out-code
    .
    run check-output in this-procedure (
          input fi-name
        , input fi-out-code
    ).
    assign
        p-out-name = fi-name
        p-out-code = fi-out-code
        p-cancel   = no
    .
    apply "WINDOW-CLOSE" TO FRAME Dialog-Frame .
END.
ON CHOOSE OF B-hist IN FRAME Dialog-Frame
DO:
 DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
 run ref/cfggrphi.w (
                  input parparentproc
                 ,INPUT '':U
                 ,INPUT 'one'
                 ,INPUT p-store-type
                 ,INPUT p-store-code
                 ,INPUT p-grp-code
                 ,INPUT '':U
                 ,INPUT NO
                 ,INPUT '':U
                 ,OUTPUT v-rid-list) NO-ERROR.
END.
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
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    run init-fields in this-procedure.
    RUN Myenable.
    if p-mode = 'ПРОСМОТР':U
    then do:
        apply "entry" to b-exit in frame Dialog-Frame .
        disable
            fi-name
        with frame Dialog-Frame .
        assign
            fi-name :fgcolor = 4
        .
    end.
    else do:
        apply "entry" to fi-name in frame Dialog-Frame .
    end.
    WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE check-output :
do
on error undo, return error
:
define input parameter p-name       as character    no-undo.
define input parameter p-out-code   as integer      no-undo.
define variable v-rezerved-out-code like ub.fbr-gds-grp.out-code no-undo .
    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.
    if p-name = '' then do:
      message
      "Название группы не может быть пустым!"
      view-as alert-box error .
      undo, return error .
    end.
    find first buf_fbr-gds-grp no-lock
         where buf_fbr-gds-grp.obj-type   = p-store-type
           and buf_fbr-gds-grp.obj-code   = p-store-code
           and buf_fbr-gds-grp.upper-code = p-upper-code
           and buf_fbr-gds-grp.node-name  = p-name
           and buf_fbr-gds-grp.node-code  <> p-grp-code
    no-error.
    if available buf_fbr-gds-grp
    then do:
        message
            skip "Есть другая группа блюд с таким именем."
            skip(1)
            skip "Измените имя группы."
        view-as alert-box error
        title "Проверка введенных значений".
        undo, return error .
    end.
    find last buf_fbr-gds-grp no-lock where
              buf_fbr-gds-grp.obj-type = "":U
          AND buf_fbr-gds-grp.obj-code = 0
          use-index pi .
    assign
    v-rezerved-out-code = buf_fbr-gds-grp.out-code
    .
    if p-out-code > 65535
    then do:
        message
                "Код группы на кассе может быть числом от 0 до 65535."
            skip(1)
            skip "Измените код группы на кассе."
        view-as alert-box error
        title "Проверка введенных значений".
        undo, return error .
    end.
    if p-out-code <> 0
    and p-out-code < 9998
    then do:
        find first buf_fbr-gds-grp no-lock
             where buf_fbr-gds-grp.obj-type   = p-store-type
               and buf_fbr-gds-grp.obj-code   = p-store-code
               and buf_fbr-gds-grp.out-code   = p-out-code
               and buf_fbr-gds-grp.node-code  <> p-grp-code
        no-error.
        if available buf_fbr-gds-grp
        then do:
            message
                skip "Есть другая группа блюд с таким кодом на кассе."
                skip(1)
                skip "Измените код на кассе."
            view-as alert-box error
            title "Проверка введенных значений".
            undo, return error .
        end.
    end.
    if  p-out-code <> p-in-code
    and p-out-code <= v-rezerved-out-code
    and dflt-cd = 'MAGIA-XML':U
    then do:
        message
            skip substitute("Коды групп на кассе со значением менее &1 зарезервированы.",  v-rezerved-out-code)
            skip(1)
            skip "Измените код на кассе."
        view-as alert-box error
        title "Проверка введенных значений".
        undo, return error .
    end.
end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY fi-name fi-out-code
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-cancel B-hist b-help fi-name fi-out-code
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE init-fields :
do
on error undo, return error
:
    assign
        fi-name     = p-in-name
        fi-out-code = p-in-code
    .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type2 as character no-undo .
define variable v-value-date2 as date no-undo .
define variable v-value-decimal2 as decimal no-undo .
define variable v-value-integer2 as INTEGER no-undo .
define variable v-value-logical2 AS LOGICAL no-undo .
define variable v-tth2 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  p-store-type
    ,input  p-store-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output dflt-cd
    ,output v-value-date2
    ,output v-value-decimal2
    ,output v-value-integer2
    ,output v-value-logical2
    ,output v-param-type2
    ,INPUT-OUTPUT table-handle v-tth2
    )  .
delete object v-tth2 no-error.
end.
END PROCEDURE.
PROCEDURE MyEnable :
  DISPLAY
  fi-name
  fi-out-code
  WITH FRAME Dialog-Frame.
  ENABLE
  b-exit
  b-cancel
  B-hist
  b-help WHEN p-mode <> 'ДОБАВЛЕНИЕ':U
  fi-name
  fi-out-code
  WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
