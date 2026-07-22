define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Интерфейс очистки пользовательских фильтров".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define input  parameter parparentproc  as handle no-undo .
define variable v-userid as character no-undo .
DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-imp-exp
     LABEL "&Имп/Эксп"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-sel-user DEFAULT
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     size 2.5 by 1.08.
DEFINE VARIABLE fi-nik AS CHARACTER FORMAT "X(256)":U
     LABEL "Пользователь"
     VIEW-AS FILL-IN
     SIZE 31 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE tg-filters AS LOGICAL INITIAL no
     LABEL "Фильтры"
     VIEW-AS TOGGLE-BOX
     SIZE 11.13 BY .83 NO-UNDO.
DEFINE VARIABLE tg-usr-flt AS LOGICAL INITIAL no
     LABEL "Настройки"
     VIEW-AS TOGGLE-BOX
     SIZE 11.13 BY .83 NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1 WIDGET-ID 2
     b-imp-exp AT ROW 1 COL 11 WIDGET-ID 6
     b-del AT ROW 1 COL 21 WIDGET-ID 16
     B-help AT ROW 1 COL 51 WIDGET-ID 12
     tg-filters AT ROW 3 COL 2 WIDGET-ID 18
     fi-nik AT ROW 4 COL 28 COLON-ALIGNED WIDGET-ID 22
     b-sel-user at row 4 col 61.5 WIDGET-ID 24
     tg-usr-flt AT ROW 4.17 COL 2 WIDGET-ID 20
     SPACE(53.36) SKIP(1.45)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Удаление фильтров" WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       fi-nik:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-del IN FRAME Dialog-Frame
DO:
  assign
    tg-filters
    tg-usr-flt
  .
  run proc-delete in this-procedure no-error .
  if error-status :error then do:
    message
      "Ошибка при вызове процедуры удаления фильтров." skip
      error-status :get-message(1) skip
      error-status :get-message(2) skip
      return-value
    view-as alert-box information.
    return no-apply.
  end.
END.
ON CHOOSE OF b-imp-exp IN FRAME Dialog-Frame
DO:
  run proc-import-export in this-procedure no-error .
  if error-status :error then do:
    message
      "Ошибка при вызове утилиты импорта-экспорта." skip
      error-status :get-message(1) skip
      error-status :get-message(2) skip
      return-value
    view-as alert-box information.
    return no-apply.
  end.
END.
ON CHOOSE OF b-sel-user IN FRAME Dialog-Frame
DO:
  run proc-sel-user in this-procedure no-error .
  if error-status :error then do:
    assign
      fi-nik = ""
      fi-nik:private-data = ""
    .
    return no-apply.
  end.
END.
ON VALUE-CHANGED OF tg-usr-flt IN FRAME Dialog-Frame
DO:
  assign
    tg-usr-flt
  .
  if tg-usr-flt = yes
  then do :
    display
      fi-nik
      b-sel-user
    with frame Dialog-Frame.
  end.
  else do:
    hide
      fi-nik
      b-sel-user
    .
    assign
      fi-nik = ""
      fi-nik:private-data = ""
    .
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN my-enable in this-procedure .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN my-disable.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY tg-filters fi-nik tg-usr-flt
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-del B-help tg-filters fi-nik b-sel-user tg-usr-flt
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE my-disable :
  run disable_UI in this-procedure .
END PROCEDURE.
PROCEDURE my-enable :
  display
    tg-filters
    tg-usr-flt
  with frame Dialog-Frame.
  enable
    b-exit
    b-imp-exp
    b-del
    b-help
    b-sel-user
    tg-filters
    tg-usr-flt
  with frame Dialog-Frame.
  hide
    fi-nik
    b-sel-user
  .
  view frame Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-delete :
do
on error undo, return error return-value
:
  define buffer buf_filter  for ubflt.filter.
  define buffer buf_usr-flt for ubflt.usr-flt.
  define variable v-i           as integer   no-undo .
  define variable v-j           as integer   no-undo .
  define variable v-log         as logical   no-undo .
  define variable v-user-id     as character no-undo .
  define variable v-old-user-id as character no-undo .
  define variable v-str         as character no-undo .
  if ( tg-filters = no ) and ( tg-usr-flt = no)
  then do:
    return.
  end.
  message
    "Удалить?" skip
    "ВНИМАНИЕ! Предварительно рекомендуется экспортировать фильтры (Имп/Эксп)."
  view-as alert-box question buttons yes-no update v-log.
  if( v-log = no ) then do:
    return.
  end.
  if ( tg-usr-flt = yes ) then do:
    if fi-nik <> "" then do:
      message
        substitute( "Удалить все настройки для пользователя &1 ?" , fi-nik )
      view-as alert-box question buttons yes-no update v-log.
    end.
    else do:
      message
        "Пользователь не выбран. Удалить настройки для ВСЕХ пользователей?":U
      view-as alert-box question buttons yes-no update v-log.
    end.
    if( v-log = no ) then do:
      return.
    end.
  end.
if session :set-wait-state( "compiler" ) then.
  del-block:
  do on error undo del-block, return error return-value
  :
    for each buf_filter exclusive-lock
    :
      assign
        v-i = v-i + 1
      .
      delete buf_filter.
    end.
    if( tg-usr-flt = yes )
    then do:
      if( fi-nik <> "" ) then do:
        assign
          v-str = fi-nik:private-data in frame Dialog-Frame
        .
        if num-entries( v-str , chr(4) ) > 1
        then do:
          assign
            v-user-id     = entry( 1 , v-str , chr(4) )
            v-old-user-id = entry( 2 , v-str , chr(4) )
          .
        end.
        for each buf_usr-flt exclusive-lock
          where ( buf_usr-flt.user-name = v-user-id ) or
                ( buf_usr-flt.user-name = v-old-user-id and v-old-user-id <> "" )
        :
          assign
            v-j = v-j + 1
          .
          delete buf_usr-flt.
        end.
      end.
      else do:
        for each buf_usr-flt exclusive-lock
        :
          assign
            v-j = v-j + 1
          .
          delete buf_usr-flt.
        end.
      end.
    end.
  end.
if session :set-wait-state( "" ) then.
  message
    substitute("Фильтров удалено: &1.&2Настроек удалено: &3" , v-i , chr(10), v-j )
  view-as alert-box information.
end.
END PROCEDURE.
PROCEDURE proc-import-export :
do
on error undo, return error return-value
:
  run utl/exp-imp.w ( input parparentproc ) .
end.
END PROCEDURE.
PROCEDURE proc-sel-user :
do
on error undo, return error return-value
:
  define buffer buf_user-account for ub.user-account.
  define variable v-user-nik    as character no-undo .
  define variable v-selected-userid like ub.user-account.user-id        no-undo .
  define variable v-old-userid      like ub.user-account.parent-user-id no-undo .
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
  run str/usersel.p ( input parparentproc
                    , input v-cntxt-userid
                    , output v-selected-userid
                    , output v-old-userid
                    ).
  find buf_user-account no-lock
    where buf_user-account.user-id = v-selected-userid
  no-error .
  if available buf_user-account then do:
    assign
      fi-nik = buf_user-account.nik
      fi-nik:private-data in frame Dialog-Frame = buf_user-account.user-id + chr(4) + v-old-userid
    .
    display
      fi-nik
    with frame Dialog-Frame.
  end.
end.
END PROCEDURE.
