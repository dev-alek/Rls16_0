define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-parent-handle      as handle           no-undo.
define input parameter p-mode               as character        no-undo.
define input parameter p-esys-id            as integer          no-undo.
define input parameter p-db-num             as integer          no-undo.
define input parameter p-current-db-num     as integer          no-undo.
define output parameter p-success           as logical          no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Open XML. Редактирование записи внешней подсистемы".
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
define variable vss-include-info0 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure oxmlext-create :
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-current-db-num     as integer          no-undo.
define output parameter p-esys-id           as integer          no-undo.
    define variable v-today     as date         no-undo.
    define variable v-time      as integer      no-undo.
    define variable v-userid    as character    no-undo.
    define buffer buf_ext-system        for ub.ext-system.
do
for buf_ext-system
on error undo, return error
:
    run cur-time in this-procedure (
          output v-today
        , output v-time
    ).
    run oxmlext-esys-id in this-procedure (
        output p-esys-id
    ).
    run get-userid in p-mainmenu-handle (
        output v-userid
    ).
    create buf_ext-system.
    assign
        buf_ext-system.esys-id                          = p-esys-id
        buf_ext-system.db-num                           = p-current-db-num
        buf_ext-system.esys-date-change                 = v-today
        buf_ext-system.esys-chk-ingr-imp                = no
        buf_ext-system.esys-chk-seq-imp                 = no
        buf_ext-system.esys-date-change-attr            = v-today
        buf_ext-system.esys-date-change-exp             = v-today
        buf_ext-system.esys-date-change-imp             = v-today
        buf_ext-system.esys-db-num-exp                  = p-current-db-num
        buf_ext-system.esys-db-num-imp                  = p-current-db-num
        buf_ext-system.esys-des                         = ""
        buf_ext-system.esys-file-chk-ing-imp            = "":U
        buf_ext-system.esys-have-export                 = no
        buf_ext-system.esys-have-import                 = no
        buf_ext-system.esys-have-proc-chk-ing-imp       = no
        buf_ext-system.esys-last-pack                   = 0
        buf_ext-system.esys-name                        = "<Новая внешняя система>"
        buf_ext-system.esys-num-days-keep-exp           = 0
        buf_ext-system.esys-num-days-keep-imp           = 0
        buf_ext-system.esys-proc-chk-ing-imp            = "":U
        buf_ext-system.esys-send-news-exp               = no
        buf_ext-system.esys-send-news-imp               = no
        buf_ext-system.esys-status                      = integer( '-1':U )
        buf_ext-system.esys-work-update                 = no
        buf_ext-system.esys-creid                       = v-userid
        buf_ext-system.esys-sys-date                    = v-today
        buf_ext-system.esys-sys-time-int                = v-time
        buf_ext-system.esys-sys-time                    = string( v-time, "HH:MM:SS" )
        buf_ext-system.esys-user-name                   = v-userid
        buf_ext-system.esys-user-db-num                 = p-current-db-num
    .
end.
end procedure.
procedure oxmlext-start-subsystem :
define input parameter p-esys-id    as integer          no-undo.
define input parameter p-db-num     as integer          no-undo.
    define buffer buf_ext-system        for ub.ext-system.
do
for buf_ext-system
on error undo, return error
:
    find first buf_ext-system exclusive-lock
         where buf_ext-system.esys-id = p-esys-id
           and buf_ext-system.db-num  = p-db-num
    .
    if buf_ext-system.esys-status = 20
    then do:
        assign
            buf_ext-system.esys-status = 21
        .
    end.
    else do:
        assign
            buf_ext-system.esys-status = 1
        .
    end.
end.
end procedure.
procedure oxmlext-stop-subsystem :
define input parameter p-esys-id    as integer          no-undo.
define input parameter p-db-num     as integer          no-undo.
    define buffer buf_ext-system        for ub.ext-system.
do
for buf_ext-system
on error undo, return error
:
    find first buf_ext-system exclusive-lock
         where buf_ext-system.esys-id = p-esys-id
           and buf_ext-system.db-num  = p-db-num
    .
    if buf_ext-system.esys-status = 21
    then do:
        assign
            buf_ext-system.esys-status = 20
        .
    end.
    else do:
        assign
            buf_ext-system.esys-status = 0
        .
    end.
end.
end procedure.
procedure oxmlext-stop-import :
define input parameter p-esys-id    as integer          no-undo.
define input parameter p-db-num     as integer          no-undo.
do
on error undo, return error
:
end.
end procedure.
procedure oxmlext-stop-export :
define input parameter p-esys-id    as integer          no-undo.
define input parameter p-db-num     as integer          no-undo.
do
on error undo, return error
:
end.
end procedure.
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
define variable v-oxmlextd-can-change-db-imp    as logical      no-undo.
define variable v-oxmlextd-can-change-db-exp    as logical      no-undo.
define variable v-oxmlextd-can-change-imp       as logical      no-undo.
define variable v-oxmlextd-can-change-exp       as logical      no-undo.
define variable v-oxmlextd-have-import          as logical      no-undo.
define variable v-oxmlextd-have-export          as logical      no-undo.
define variable v-oxmlextd-has-import               as logical      no-undo.
DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON bt-types-exp
     LABEL "Типы данных"
     SIZE 14.5 BY 1.
DEFINE VARIABLE ed-des AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 29 BY 3.75 NO-UNDO.
DEFINE VARIABLE fi-db-num-exp AS INTEGER FORMAT "->>>>9" INITIAL 0
     LABEL "БД"
     VIEW-AS FILL-IN
     SIZE 5.5 BY 1.
DEFINE VARIABLE fi-des-label AS CHARACTER FORMAT "X(256)":U INITIAL "Описание:"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE fi-esys-id AS INTEGER FORMAT ">>>>>9":U INITIAL 0
     LABEL "Номер"
      VIEW-AS TEXT
     SIZE 9.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Название"
     VIEW-AS FILL-IN
     SIZE 29 BY 1 NO-UNDO.
DEFINE VARIABLE fi-num-days-keep-exp AS INTEGER FORMAT "->,>>>,>>9" INITIAL 0
     LABEL "Дней хранения пакетов"
     VIEW-AS FILL-IN
     SIZE 7.5 BY 1.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 40 BY 5.5.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 12.5 BY 1.25
     BGCOLOR 8 FGCOLOR 8 .
DEFINE VARIABLE tg-have-export AS LOGICAL INITIAL no
     LABEL "Экспорт"
     VIEW-AS TOGGLE-BOX
     SIZE 10.5 BY .83 NO-UNDO.
DEFINE VARIABLE tg-have-import AS LOGICAL INITIAL no
     LABEL "Импорт"
     VIEW-AS TOGGLE-BOX
     SIZE 10.5 BY .83 NO-UNDO.
DEFINE VARIABLE tg-send-news-exp AS LOGICAL INITIAL no
     LABEL "Отправлять в новости"
     VIEW-AS TOGGLE-BOX
     SIZE 24 BY .83 NO-UNDO.
DEFINE VARIABLE tg-spec AS LOGICAL INITIAL no
     LABEL "Спецсистема"
     VIEW-AS TOGGLE-BOX
     SIZE 17 BY .83 NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-cancel AT ROW 1 COL 11
     b-help AT ROW 1 COL 32
     fi-name AT ROW 3.5 COL 11 COLON-ALIGNED
     fi-des-label AT ROW 5 COL 2.5 NO-LABEL
     ed-des AT ROW 5 COL 13 NO-LABEL
     tg-spec AT ROW 9.25 COL 4.5 WIDGET-ID 2
     tg-have-export AT ROW 10.5 COL 4.5
     fi-db-num-exp AT ROW 11.75 COL 6.5 COLON-ALIGNED
     tg-send-news-exp AT ROW 11.75 COL 16.5
     fi-num-days-keep-exp AT ROW 13 COL 25.5 COLON-ALIGNED
     bt-types-exp AT ROW 14.75 COL 4
     tg-have-import AT ROW 16.75 COL 4.5 WIDGET-ID 6
     fi-esys-id AT ROW 2.25 COL 11 COLON-ALIGNED WIDGET-ID 4
     RECT-1 AT ROW 10.75 COL 2
     RECT-2 AT ROW 10.25 COL 3.5
     SPACE(27.24) SKIP(6.45)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Внешняя подсистема Open XML"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-cancel.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-cancel IN FRAME Dialog-Frame
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
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
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
    define variable v-err-desc      as character    no-undo.
    define variable v-err           as logical      no-undo.
    define variable v-yesno         as logical      no-undo.
    if p-mode <> 'ПРОСМОТР':U
    then do:
        assign
            tg-have-import
        .
        run check-data in this-procedure (
              output v-err-desc
            , output v-err
        ).
        if v-err = yes
        then do:
            message
                "Ошибка ввода данных."
                skip (1)
                skip v-err-desc
                skip (1)
                skip "Исправьте данные или отмените ввод."
            view-as alert-box warning.
            undo, return no-apply.
        end.
        if v-oxmlextd-have-import = yes
        and v-oxmlextd-has-import = yes
        and tg-have-import        = no
        then do:
            message
                     "Для сохранения выбранных параметров"
                skip "необходимо остановить импорт из внешней подсистемы."
                skip "Будут удалены все данные по импорту из этой подсистемы."
                skip (1)
                skip "Внешняя подсистема:"
                skip "  номер   " p-esys-id
                skip "  БД номер" p-db-num
                skip "  имя     " fi-name :screen-value
                skip (1)
                skip "Остановить импорт?"
            view-as alert-box information
            buttons yes-no
            title "Остановка импорта"
            update v-yesno.
            if v-yesno = yes
            then do:
                run oxmlext-stop-import in this-procedure (
                      input p-esys-id
                    , input p-db-num
                ).
            end.
            else do:
                undo, return no-apply.
            end.
        end.
        if v-oxmlextd-have-export = yes
        and tg-have-export :screen-value = "no"
        then do:
            message
                     "Для сохранения выбранных параметров"
                skip "необходимо остановить экспорт во внешнюю подсистему."
                skip "Будут удалены все данные по экспорту в эту подсистему."
                skip (1)
                skip "Внешняя подсистема:"
                skip "  номер   " p-esys-id
                skip "  БД номер" p-db-num
                skip "  имя     " fi-name :screen-value
                skip (1)
                skip "Остановить экспорт?"
            view-as alert-box information
            buttons yes-no
            title "Остановка экспорта"
            update v-yesno.
            if v-yesno = yes
            then do:
                run oxmlext-stop-export in this-procedure (
                      input p-esys-id
                    , input p-db-num
                ).
            end.
            else do:
                undo, return no-apply.
            end.
        end.
        assign
            fi-name
            ed-des
            tg-have-export
            tg-have-import
            fi-db-num-exp
            tg-send-news-exp
            fi-num-days-keep-exp
            tg-spec
        .
        run assign-fields in this-procedure .
    end.
    assign
        p-success = yes
    .
END.
ON CHOOSE OF bt-types-exp IN FRAME Dialog-Frame
DO:
    run bge/oxmlexty.w (
          input p-mainmenu-handle
        , input ( if p-mode = 'ПРОСМОТР':U then 0 else 1 )
        , input 'экспорт':U
        , input p-esys-id
        , input p-db-num
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка списка типов экспорта."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
END.
ON VALUE-CHANGED OF tg-have-export IN FRAME Dialog-Frame
DO:
    assign
        tg-have-export
    .
    run manage-export in this-procedure (
        input tg-have-export
    ).
END.
ON VALUE-CHANGED OF tg-have-import IN FRAME Dialog-Frame
DO:
    assign
        tg-have-import
    .
END.
ON VALUE-CHANGED OF tg-spec IN FRAME Dialog-Frame
DO:
    assign
        tg-spec
    .
    run manage-spec in this-procedure (
        input tg-spec
    ).
END.
define variable vss-include-info3 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame Dialog-Frame anywhere do:
  if b-exit :sensitive then DO: apply "CHOOSE":U to b-exit in frame Dialog-Frame. END.
  return no-apply.
end.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    run init-fields in this-procedure .
    RUN enable_UI.
    run disable-all in this-procedure .
    run ui-enable in this-procedure .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE assign-fields :
    define buffer buf_ext-system        for ub.ext-system.
do
for buf_ext-system
on error undo, return error
:
    find first buf_ext-system exclusive-lock
         where buf_ext-system.esys-id = p-esys-id
    .
    assign
        buf_ext-system.esys-name                       = fi-name
        buf_ext-system.esys-des                        = ed-des
        buf_ext-system.esys-have-export                = tg-have-export
        buf_ext-system.esys-have-import                = tg-have-import
        buf_ext-system.esys-db-num-exp                 = fi-db-num-exp
        buf_ext-system.esys-send-news-exp              = tg-send-news-exp
        buf_ext-system.esys-num-days-keep-exp          = fi-num-days-keep-exp
    .
    if p-mode = 'ДОБАВЛЕНИЕ':U
    then do:
        if tg-spec = yes
        then do:
            assign
                buf_ext-system.esys-type = integer('1':U)
            .
        end.
        else do:
            assign
                buf_ext-system.esys-type = integer('0':U)
            .
        end.
    end.
end.
END PROCEDURE.
PROCEDURE check-data :
define output parameter p-error-desc    as character        no-undo.
define output parameter p-error         as logical          no-undo.
do
with frame Dialog-Frame
on error undo, return error
:
    if p-current-db-num <> 0
    then do:
        if fi-db-num-exp :sensitive = yes
        and integer( fi-db-num-exp ) <> p-current-db-num
        then do:
            assign
                p-error      = yes
                p-error-desc = substitute( "&2&1&3"
                                , chr(10)
                                , "Номер базы данных для экспорта"
                                , "не равен номеру текущей базы данных." )
            .
        end.
    end.
end.
END PROCEDURE.
PROCEDURE disable-all :
do
with frame Dialog-Frame
on error undo, return error
:
    disable
        all
        except
            b-exit
            b-help
    .
end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY fi-name fi-des-label ed-des tg-spec tg-have-export fi-db-num-exp
          tg-send-news-exp fi-num-days-keep-exp tg-have-import fi-esys-id
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-cancel b-help RECT-1 RECT-2 fi-name ed-des tg-spec
         tg-have-export fi-db-num-exp tg-send-news-exp fi-num-days-keep-exp
         bt-types-exp tg-have-import
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE init-fields :
    define buffer buf_ext-system        for ub.ext-system.
do
for buf_ext-system
on error undo, return error
:
    assign
        fi-esys-id = p-esys-id
    .
    assign
        p-success = no
    .
    find first buf_ext-system exclusive-lock
         where buf_ext-system.esys-id = p-esys-id
           and buf_ext-system.db-num  = p-db-num
    no-error.
    if not available buf_ext-system
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Не удаётся получить запись внешней подсистемы"
            skip "для изменения."
        view-as alert-box error.
        undo, return error .
    end.
    assign
        fi-name                        = buf_ext-system.esys-name
        ed-des                         = buf_ext-system.esys-des
        tg-have-export                 = buf_ext-system.esys-have-export
        tg-have-import                 = buf_ext-system.esys-have-import
        fi-db-num-exp                  = buf_ext-system.esys-db-num-exp
        tg-send-news-exp               = buf_ext-system.esys-send-news-exp
        fi-num-days-keep-exp           = buf_ext-system.esys-num-days-keep-exp
        tg-spec                        = ( buf_ext-system.esys-type = 1 )
        v-oxmlextd-has-import              = buf_ext-system.esys-have-import
    .
    if tg-spec = yes
    then do:
        assign
            v-oxmlextd-can-change-exp   = no
            v-oxmlextd-have-export      = no
            tg-have-export              = no
        .
        if p-current-db-num = 0
        then do:
            assign
                v-oxmlextd-have-import      = buf_ext-system.esys-have-import
                v-oxmlextd-can-change-imp   = yes
            .
        end.
        else do:
            assign
                v-oxmlextd-have-import      = no
                v-oxmlextd-can-change-imp   = no
            .
        end.
    end.
    else do:
        assign
            v-oxmlextd-have-export      = tg-have-export
            v-oxmlextd-have-import      = no
            v-oxmlextd-can-change-imp   = no
        .
        assign
            v-oxmlextd-can-change-exp       = no
            v-oxmlextd-can-change-db-exp    = no
        .
        if p-current-db-num = 0
        then do:
            assign
                v-oxmlextd-can-change-exp       = yes
                v-oxmlextd-can-change-db-exp    = yes
            .
        end.
        else do:
            assign
                v-oxmlextd-can-change-db-exp    = no
            .
            if buf_ext-system.esys-db-num-exp = p-current-db-num
            then do:
                assign
                    v-oxmlextd-can-change-exp       = yes
                .
            end.
            else do:
                assign
                    v-oxmlextd-can-change-exp       = no
                .
            end.
        end.
    end.
end.
END PROCEDURE.
PROCEDURE manage-export :
define input parameter p-have-export    as logical          no-undo.
do
with frame Dialog-Frame
on error undo, return error
:
    if p-have-export = yes
    then do:
        if v-oxmlextd-can-change-db-exp = yes
        then do:
            enable
                fi-db-num-exp
            .
        end.
        else do:
            disable
                fi-db-num-exp
            .
        end.
        enable
            tg-send-news-exp
            fi-num-days-keep-exp
            bt-types-exp
        .
    end.
    else do:
        disable
            fi-db-num-exp
            tg-send-news-exp
            fi-num-days-keep-exp
            bt-types-exp
        .
    end.
end.
END PROCEDURE.
PROCEDURE manage-spec :
define input parameter p-spec   as logical     no-undo.
do
with frame Dialog-Frame
on error undo, return error
:
    if p-spec = yes
    then do:
        disable
            tg-have-export
            fi-db-num-exp
            tg-send-news-exp
            tg-send-news-exp
            fi-num-days-keep-exp
            bt-types-exp
        .
        enable
            fi-num-days-keep-exp
        .
    end.
    else do:
        enable
            tg-have-export
            fi-db-num-exp
            tg-send-news-exp
            tg-send-news-exp
            fi-num-days-keep-exp
            bt-types-exp
        .
        run manage-export in this-procedure (
            input tg-have-export
        ).
    end.
end.
END PROCEDURE.
PROCEDURE ui-enable :
do
with frame Dialog-Frame
on error undo, return error
:
    if tg-spec = yes
    then do:
        display
            tg-have-import
        .
        if p-mode = 'ДОБАВЛЕНИЕ':U
        or p-mode = 'ИЗМЕНЕНИЕ':U
        then do:
            enable
                tg-have-import
            .
        end.
        else do:
            disable
                tg-have-import
            .
        end.
    end.
    else do:
        hide
            tg-have-import
        .
    end.
    case p-mode
    :
        when 'ДОБАВЛЕНИЕ':U
        then do:
            enable
                b-cancel
                fi-name
                ed-des
                fi-num-days-keep-exp
            .
            if v-oxmlextd-can-change-exp = yes
            then do:
                enable
                    tg-have-export
                .
                run manage-export in this-procedure (
                    input tg-have-export
                ).
            end.
        end.
        when 'ИЗМЕНЕНИЕ':U
        then do:
            enable
                b-cancel
                fi-name
                ed-des
                fi-num-days-keep-exp
            .
            if v-oxmlextd-can-change-exp    = yes
            and tg-spec                     = no
            then do:
                enable
                    tg-have-export
                .
                run manage-export in this-procedure (
                    input tg-have-export
                ).
            end.
        end.
        when 'ПРОСМОТР':U
        then do:
            assign
                b-exit   :label     = "В&ыход"
                b-cancel :visible   = no
            .
            if tg-have-export   = yes
            and tg-spec         = no
            then do:
                enable
                    bt-types-exp
                .
            end.
        end.
        otherwise do:
            message
                "Указанный режим просмотра записи некорректен."
            view-as alert-box error
            title vss-description.
            undo, return error.
        end.
    end case.
end.
END PROCEDURE.
