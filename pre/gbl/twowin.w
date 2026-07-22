define variable vss-include-info0 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_twowin_items no-undo
    field itm-key       as integer
    field itmExtKey     as character
    field itmName       as character
    field itmDesc       as character
    field itmSelected   as logical
    field selLeft       as logical
    field selRight      as logical
    index pi is primary unique
        itm-key
    index ie
        itmExtKey
.
define temp-table temp_twowin_itemsSelected no-undo
    field its-key   as integer
    field itm-key   as integer
    field itmExtKey as character
    index pi is primary unique
        its-key
    index im
        itm-key
.
define variable v-twowin0-itm-key    as integer      no-undo.
procedure twowin_clear :
    define buffer buf_temp_twowin_items        for temp_twowin_items.
do
for buf_temp_twowin_items
on error undo, return error
:
    empty temp-table buf_temp_twowin_items.
end.
end procedure.
procedure twowin_add-item :
define input parameter p-ext-key   as character        no-undo.
define input parameter p-item-name as character        no-undo.
define input parameter p-item-desc as character        no-undo.
define input parameter p-selected  as logical          no-undo.
    define buffer buf_temp_twowin_items        for temp_twowin_items.
do
for buf_temp_twowin_items
on error undo, return error
:
    assign
        v-twowin0-itm-key = v-twowin0-itm-key + 1
    .
    create temp_twowin_items.
    assign
        temp_twowin_items.itm-key      = v-twowin0-itm-key
        temp_twowin_items.itmExtKey    = p-ext-key
        temp_twowin_items.itmName      = p-item-name
        temp_twowin_items.itmDesc      = p-item-desc
        temp_twowin_items.itmSelected  = p-selected
        temp_twowin_items.selLeft      = no
        temp_twowin_items.selRight     = no
    .
end.
end procedure.
define input parameter p-mainmenu-handle    as widget-handle    no-undo.
define input parameter p-mode               as integer          no-undo.
define input parameter p-title              as character        no-undo.
define input parameter p-runfilename        as character        no-undo.
define input parameter p-runfilelabel       as character        no-undo.
define input parameter table for temp_twowin_items .
define output parameter table for temp_twowin_itemsSelected .
define output parameter p-changed           as logical          no-undo.
define output parameter p-accepted          as logical          no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Двухоконный интерфейс для выбора из небольшого количества записей".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR BLACK_COLOR        AS INTEGER NO-UNDO INIT  0.
DEF VAR DARK_BLUE_COLOR    AS INTEGER NO-UNDO INIT  1.
DEF VAR DARK_GREEN_COLOR   AS INTEGER NO-UNDO INIT  2.
DEF VAR CYAN_COLOR         AS INTEGER NO-UNDO INIT  3.
DEF VAR BROWN_COLOR        AS INTEGER NO-UNDO INIT  4.
DEF VAR DARK_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR DARK_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR GRAY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR GREY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR BLUE_COLOR         AS INTEGER NO-UNDO INIT  9.
DEF VAR GREEN_COLOR        AS INTEGER NO-UNDO INIT 10.
DEF VAR RED_COLOR          AS INTEGER NO-UNDO INIT 12.
DEF VAR LIGHT_RED_COLOR    AS INTEGER NO-UNDO INIT 13.
DEF VAR YELLOW_COLOR       AS INTEGER NO-UNDO INIT 14.
DEF VAR WHITE_COLOR        AS INTEGER NO-UNDO INIT 15.
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
    define variable v-twowin-close-enabled    as logical      no-undo.
    define buffer buf_right_temp_twowin_items             for temp_twowin_items.
    define buffer buf_left_temp_twowin_items              for temp_twowin_items.
    define buffer buf_temp_twowin_itemsSelected           for temp_twowin_itemsSelected.
DEFINE BUTTON b-cancel AUTO-END-KEY DEFAULT
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помощ&ь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON bt-deselect-type
     LABEL "<--"
     SIZE 4.13 BY 1.
DEFINE BUTTON bt-filter DEFAULT
     LABEL "&ФПоиск"
     SIZE 10 BY 1 TOOLTIP "Поиск с фильтром строки во всех текстовых полях"
     BGCOLOR 8 .
DEFINE BUTTON bt-not-sel-all
     LABEL "+"
     SIZE 3 BY 1 TOOLTIP "Выбрать все".
DEFINE BUTTON bt-not-sel-desel-all
     LABEL "-"
     SIZE 3 BY 1 TOOLTIP "Отменить выбор".
DEFINE BUTTON bt-not-sel-reverse
     LABEL "/"
     SIZE 3 BY 1 TOOLTIP "Инвертировать выбор".
DEFINE BUTTON bt-not-sel-sel
     LABEL "*"
     SIZE 3 BY 1 TOOLTIP "Выбрать".
DEFINE BUTTON bt-properties DEFAULT
     LABEL "&Свойства"
     SIZE 15 BY 1
     BGCOLOR 8 .
DEFINE BUTTON bt-sel-desel-all
     LABEL "-"
     SIZE 3 BY 1 TOOLTIP "Отменить выбор".
DEFINE BUTTON bt-sel-reverse
     LABEL "/"
     SIZE 3 BY 1 TOOLTIP "Инвертировать выбор".
DEFINE BUTTON bt-sel-sel
     LABEL "*"
     SIZE 3 BY 1 TOOLTIP "Выбрать".
DEFINE BUTTON bt-sel-sel-all
     LABEL "+"
     SIZE 3 BY 1 TOOLTIP "Выбрать все".
DEFINE BUTTON bt-select-type
     LABEL "-->"
     SIZE 4.13 BY 1.
DEFINE VARIABLE ed-desc-not-sel AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 45.5 BY 1.63
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE ed-desc-sel AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 45.63 BY 1.63
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-filter AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 20.75 BY 1 NO-UNDO.
DEFINE VARIABLE tb-filter AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.63 BY .79 TOOLTIP "Снятие поиска с фильтром" NO-UNDO.
DEFINE QUERY br-table-left FOR
      buf_left_temp_twowin_items SCROLLING.
DEFINE QUERY br-table-right FOR
      buf_right_temp_twowin_items SCROLLING.
DEFINE BROWSE br-table-left
  QUERY br-table-left NO-LOCK DISPLAY
      buf_left_temp_twowin_items.selLeft  column-label " *" format " */  "
      buf_left_temp_twowin_items.itmName column-label " Выбрано" format "X(40)"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 45.5 BY 18.5 ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.
DEFINE BROWSE br-table-right
  QUERY br-table-right NO-LOCK DISPLAY
      buf_right_temp_twowin_items.selRight column-label " *" format " */  "
      buf_right_temp_twowin_items.itmName column-label " Доступно" format "X(40)"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 45.5 BY 18.5 ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 2 NO-TAB-STOP
     b-cancel AT ROW 1 COL 12 NO-TAB-STOP
     bt-filter AT ROW 1 COL 22 NO-TAB-STOP
     fi-filter AT ROW 1 COL 30.25 COLON-ALIGNED NO-LABEL
     tb-filter AT ROW 1 COL 54
     b-help AT ROW 1 COL 89 NO-TAB-STOP
     bt-not-sel-sel AT ROW 2.25 COL 2 NO-TAB-STOP
     bt-not-sel-all AT ROW 2.25 COL 5 NO-TAB-STOP
     bt-not-sel-desel-all AT ROW 2.25 COL 8 NO-TAB-STOP
     bt-not-sel-reverse AT ROW 2.25 COL 11 NO-TAB-STOP
     bt-properties AT ROW 2.25 COL 32.5 NO-TAB-STOP
     bt-sel-sel AT ROW 2.25 COL 53 NO-TAB-STOP
     bt-sel-sel-all AT ROW 2.25 COL 56 NO-TAB-STOP
     bt-sel-desel-all AT ROW 2.25 COL 59 NO-TAB-STOP
     bt-sel-reverse AT ROW 2.25 COL 62 NO-TAB-STOP
     br-table-right AT ROW 3.25 COL 2
     br-table-left AT ROW 3.25 COL 53
     bt-select-type AT ROW 10.5 COL 48 NO-TAB-STOP
     bt-deselect-type AT ROW 11.5 COL 48 NO-TAB-STOP
     ed-desc-not-sel AT ROW 22 COL 2 NO-LABEL NO-TAB-STOP
     ed-desc-sel AT ROW 22 COL 53 NO-LABEL NO-TAB-STOP
     SPACE(0.99) SKIP(0.11)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Выбор из списка"
         CANCEL-BUTTON b-cancel.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       bt-filter:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       bt-properties:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       ed-desc-not-sel:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       ed-desc-sel:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       fi-filter:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
    if v-twowin-close-enabled = no
    then do:
        undo, return no-apply.
    end.
    else do:
        run check-data in this-procedure.
        run assign-export-table in this-procedure (
              output p-changed
        ).
        assign
            p-accepted = yes
        .
    end.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
    APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-cancel IN FRAME Dialog-Frame
DO:
    assign
        v-twowin-close-enabled  = yes
        p-accepted              = no
    .
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
or F2 of frame Dialog-Frame anywhere
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
    assign
        v-twowin-close-enabled = yes
    .
END.
ON MOUSE-SELECT-CLICK OF br-table-left IN FRAME Dialog-Frame
or insert-mode of br-table-left in frame dialog-frame
or " " of br-table-left in frame dialog-frame
DO:
    if p-mode = 1
    then do:
        if available buf_left_temp_twowin_items
        and buf_left_temp_twowin_items.itmSelected = yes
        then do:
            assign
                buf_left_temp_twowin_items.selLeft = not( buf_left_temp_twowin_items.selLeft )
            .
            display
                selLeft
            with browse br-table-left .
            apply "entry" to br-table-left.
        end.
    end.
END.
ON VALUE-CHANGED OF br-table-left IN FRAME Dialog-Frame
or entry of br-table-left IN FRAME Dialog-Frame
or entry of br-table-right IN FRAME Dialog-Frame
or value-changed of br-table-right IN FRAME Dialog-Frame
DO:
    if available buf_left_temp_twowin_items
    then do:
        assign
            ed-desc-sel = buf_left_temp_twowin_items.itmDesc
        .
    end.
    else do:
        assign
            ed-desc-sel = "":U
        .
    end.
    if available buf_right_temp_twowin_items
    then do:
        assign
            ed-desc-not-sel = buf_right_temp_twowin_items.itmDesc
        .
    end.
    else do:
        assign
            ed-desc-not-sel = "":U
        .
    end.
    display
        ed-desc-sel
        ed-desc-not-sel
    with frame Dialog-Frame.
END.
ON MOUSE-SELECT-CLICK OF br-table-right IN FRAME Dialog-Frame
or insert-mode of br-table-right in frame dialog-frame
or " " of br-table-right in frame dialog-frame
DO:
    if p-mode = 1
    then do:
        if available buf_right_temp_twowin_items
        and buf_right_temp_twowin_items.itmSelected = no
        then do:
            assign
                buf_right_temp_twowin_items.selRight = not( buf_right_temp_twowin_items.selRight )
            .
            display
                selRight
            with browse br-table-right .
            apply "entry" to br-table-right.
        end.
    end.
END.
ON ROW-DISPLAY OF br-table-right IN FRAME Dialog-Frame
DO:
    if buf_right_temp_twowin_items.itmSelected = yes
    then do:
        assign
            buf_right_temp_twowin_items.itmName :bgcolor in browse br-table-right = GRAY_COLOR
            buf_right_temp_twowin_items.selRight :bgcolor in browse br-table-right = GRAY_COLOR
        .
    end.
END.
ON CHOOSE OF bt-deselect-type IN FRAME Dialog-Frame
or return of br-table-left in frame dialog-frame
DO:
    if p-mode = 1
    then do:
        for each buf_left_temp_twowin_items
           where buf_left_temp_twowin_items.selLeft = yes
        :
            assign
                buf_left_temp_twowin_items.itmSelected = no
                buf_left_temp_twowin_items.selLeft     = no
            .
        end.
        run local-open-query-left in this-procedure .    run local-open-query-right in this-procedure .
        if available buf_left_temp_twowin_items
        then do:
            apply "entry" to br-table-left.
        end.
        else do:
            apply "entry" to br-table-right.
        end.
    end.
END.
ON CHOOSE OF bt-filter IN FRAME Dialog-Frame
DO:
    define variable v-new-filter    as character    no-undo.
    define variable v-accepted      as logical      no-undo.
    run gbl/twowinf.w (
          input fi-filter
        , output v-new-filter
        , output v-accepted
    ).
    if v-accepted = yes
    then do:
        assign
            fi-filter = v-new-filter
        .
        if fi-filter = "":U
        then do:
            assign
                tb-filter               = no
                tb-filter :sensitive    = no
            .
        end.
        else do:
            assign
                tb-filter               = yes
                tb-filter :sensitive    = yes
            .
        end.
        display
            fi-filter
            tb-filter
        with frame Dialog-Frame.
        run local-open-query-right in this-procedure .
        apply "entry":U to br-table-right.
    end.
END.
ON CHOOSE OF bt-not-sel-all IN FRAME Dialog-Frame
DO:
    define variable v-changed    as integer      no-undo.
    if fi-filter = "":U
    or tb-filter = no
    then do:
        for each buf_right_temp_twowin_items
           where buf_right_temp_twowin_items.itmSelected = no
        :
            assign
                buf_right_temp_twowin_items.selRight    = yes
                v-changed                               = v-changed + 1
            .
        end.
    end.
    else do:
        for each buf_right_temp_twowin_items
           where buf_right_temp_twowin_items.itmSelected = no
             and index( buf_right_temp_twowin_items.itmName, fi-filter ) <> 0
        :
            assign
                buf_right_temp_twowin_items.selRight    = yes
                v-changed                               = v-changed + 1
            .
        end.
    end.
    if v-changed > 0
    then do:
        br-table-right :refresh().
    end.
    apply "entry" to br-table-right.
END.
ON CHOOSE OF bt-not-sel-desel-all IN FRAME Dialog-Frame
DO:
    define variable v-changed    as integer      no-undo.
    for each buf_right_temp_twowin_items
    :
        assign
            buf_right_temp_twowin_items.selRight    = no
            v-changed                               = v-changed + 1
        .
    end.
    if v-changed > 0
    then do:
        br-table-right :refresh().
    end.
    apply "entry" to br-table-right.
END.
ON CHOOSE OF bt-not-sel-reverse IN FRAME Dialog-Frame
DO:
    define variable v-changed    as integer      no-undo.
    for each buf_right_temp_twowin_items
       where buf_right_temp_twowin_items.itmSelected = no
    :
        assign
            buf_right_temp_twowin_items.selRight    = not( buf_right_temp_twowin_items.selRight )
            v-changed                               = v-changed + 1
        .
    end.
    if v-changed > 0
    then do:
        br-table-right :refresh().
    end.
    apply "entry" to br-table-right.
END.
ON CHOOSE OF bt-not-sel-sel IN FRAME Dialog-Frame
DO:
    if available buf_right_temp_twowin_items
    and buf_right_temp_twowin_items.itmSelected = no
    then do:
        assign
            buf_right_temp_twowin_items.selRight    = not( buf_right_temp_twowin_items.selRight )
        .
        display
            selRight
        with browse br-table-right .
        run select-and-move-down in this-procedure (
              input browse br-table-right :handle
            , input query br-table-right :handle
        ).
        apply "entry" to br-table-right.
    end.
END.
ON CHOOSE OF bt-properties IN FRAME Dialog-Frame
DO:
    if available buf_right_temp_twowin_items
    then do:
        run value( p-runfilename ) (
              input p-mainmenu-handle
            , input buf_right_temp_twowin_items.itmExtKey
        ) no-error.
        if error-status :error
        then do:
            message
                     vss-workfile vss-revision vss-description
                skip(1)
                skip "Ошибка выполнения процедуры" p-runfilename
                skip return-value
                skip trim( error-status :get-message( 1 ) )
                     trim( error-status :get-message( 2 ) )
                     trim( error-status :get-message( 3 ) )
            view-as alert-box error.
            undo, return no-apply.
        end.
    end.
END.
ON CHOOSE OF bt-sel-desel-all IN FRAME Dialog-Frame
DO:
    define variable v-changed    as integer      no-undo.
    for each buf_left_temp_twowin_items
       where buf_left_temp_twowin_items.itmSelected = yes
    :
        assign
            buf_left_temp_twowin_items.selLeft  = no
            v-changed                           = v-changed + 1
        .
    end.
    if v-changed > 0
    then do:
        br-table-left :refresh().
    end.
    apply "entry" to br-table-left.
END.
ON CHOOSE OF bt-sel-reverse IN FRAME Dialog-Frame
DO:
    define variable v-changed    as integer      no-undo.
    for each buf_left_temp_twowin_items
       where buf_left_temp_twowin_items.itmSelected = yes
    :
        assign
            buf_left_temp_twowin_items.selLeft  = not( buf_left_temp_twowin_items.selLeft )
            v-changed                           = v-changed + 1
        .
    end.
    if v-changed > 0
    then do:
        br-table-left :refresh().
    end.
    apply "entry" to br-table-left.
END.
ON CHOOSE OF bt-sel-sel IN FRAME Dialog-Frame
DO:
    if available buf_left_temp_twowin_items
    and buf_left_temp_twowin_items.itmSelected = yes
    then do:
        assign
            buf_left_temp_twowin_items.selLeft = not( buf_left_temp_twowin_items.selLeft )
        .
        display
            selLeft
        with browse br-table-left .
        run select-and-move-down in this-procedure (
              input browse br-table-left :handle
            , input query br-table-left :handle
        ).
        apply "entry" to br-table-left.
    end.
END.
ON CHOOSE OF bt-sel-sel-all IN FRAME Dialog-Frame
DO:
    define variable v-changed    as integer      no-undo.
    for each buf_left_temp_twowin_items
       where buf_left_temp_twowin_items.itmSelected = yes
    :
        assign
            buf_left_temp_twowin_items.selLeft  = yes
            v-changed                           = v-changed + 1
        .
    end.
    if v-changed > 0
    then do:
        br-table-left :refresh().
    end.
    apply "entry" to br-table-left.
END.
ON CHOOSE OF bt-select-type IN FRAME Dialog-Frame
or return of br-table-right in frame dialog-frame
DO:
    define variable v-changed    as integer      no-undo.
    define buffer buf_temp_twowin_items for temp_twowin_items.
    if p-mode = 1
    then do:
        for each buf_right_temp_twowin_items
           where buf_right_temp_twowin_items.selRight = yes
        :
            assign
                buf_right_temp_twowin_items.itmSelected = yes
                buf_right_temp_twowin_items.selRight    = no
                v-changed                               = v-changed + 1
            .
        end.
        if v-changed > 0
        then do:
            br-table-right :refresh().
        end.
        run local-open-query-left in this-procedure .
        find first buf_temp_twowin_items
             where buf_temp_twowin_items.itmSelected = no
        no-error.
        if available buf_temp_twowin_items
        then do:
            apply "entry" to br-table-right.
        end.
        else do:
            apply "entry" to br-table-left.
        end.
    end.
END.
ON VALUE-CHANGED OF tb-filter IN FRAME Dialog-Frame
DO:
    assign
        tb-filter
    .
    run local-open-query-right in this-procedure .
    apply "entry":U to br-table-right.
END.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    RUN enable_UI.
    run ui-disable-all in this-procedure.
    run ui-enable in this-procedure.
    apply "value-changed" to br-table-left.
    apply "entry" to br-table-left.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE assign-export-table :
define output parameter p-changed   as logical          no-undo.
    define variable v-counter    as integer      no-undo.
    define buffer buf_temp_twowin_itemsSelected    for temp_twowin_itemsSelected.
    define buffer buf_temp_twowin_items            for temp_twowin_items.
do
for buf_temp_twowin_items
  , buf_temp_twowin_itemsSelected
on error undo, return error
:
    assign
        p-changed = no
    .
    check-selected-table:
    for each buf_temp_twowin_itemsSelected no-lock
    on error undo, return error
    :
        find first buf_temp_twowin_items
             where buf_temp_twowin_items.itm-key = buf_temp_twowin_itemsSelected.itm-key
        .
        if buf_temp_twowin_items.itmSelected = no
        then do:
            assign
                p-changed = yes
            .
            undo check-selected-table, leave check-selected-table.
        end.
    end.
    if p-changed = no
    then do:
        check-items-table:
        for each buf_temp_twowin_items
           where buf_temp_twowin_items.itmSelected = yes
        on error undo, return error
        :
            find first buf_temp_twowin_itemsSelected
                 where buf_temp_twowin_itemsSelected.itm-key = buf_temp_twowin_items.itm-key
            no-error.
            if not available buf_temp_twowin_itemsSelected
            then do:
                assign
                    p-changed = yes
                .
                undo check-items-table, leave check-items-table.
            end.
        end.
    end.
    if p-changed = yes
    then do:
        empty temp-table
            buf_temp_twowin_itemsSelected
        .
        for each buf_temp_twowin_items
           where buf_temp_twowin_items.itmSelected = yes
        on error undo, return error
        :
            assign
                v-counter = v-counter + 1
            .
            create buf_temp_twowin_itemsSelected.
            assign
                buf_temp_twowin_itemsSelected.its-key   = v-counter
                buf_temp_twowin_itemsSelected.itm-key   = buf_temp_twowin_items.itm-key
                buf_temp_twowin_itemsSelected.itmExtKey = buf_temp_twowin_items.itmExtKey
            .
        end.
    end.
end.
END PROCEDURE.
PROCEDURE change-properties :
define input parameter p-id     as integer          no-undo.
do
on error undo, return error
:
end.
END PROCEDURE.
PROCEDURE check-data :
do
on error undo, return error
:
end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY fi-filter tb-filter ed-desc-not-sel ed-desc-sel
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-cancel bt-filter tb-filter b-help bt-properties
         br-table-right br-table-left bt-select-type bt-deselect-type
         ed-desc-not-sel ed-desc-sel
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  run local-open-query-left in this-procedure .    run local-open-query-right in this-procedure .
END PROCEDURE.
PROCEDURE init-fields :
    define variable v-counter    as integer      no-undo.
    define buffer buf_temp_twowin_items     for temp_twowin_items.
    define buffer buf_temp_twowin_itemsSelected     for temp_twowin_itemsSelected.
do
for buf_temp_twowin_items
  , buf_temp_twowin_itemsSelected
on error undo, return error
:
    if p-title <> "":U
    then do:
        assign
            frame Dialog-Frame :title = p-title
        .
    end.
    for each buf_temp_twowin_items
       where buf_temp_twowin_items.itmSelected = yes
    :
        assign
            v-counter = v-counter + 1
        .
        create buf_temp_twowin_itemsSelected.
        assign
            buf_temp_twowin_itemsSelected.its-key   = v-counter
            buf_temp_twowin_itemsSelected.itm-key   = buf_temp_twowin_items.itm-key
            buf_temp_twowin_itemsSelected.itmExtKey = buf_temp_twowin_items.itmExtKey
        .
    end.
end.
END PROCEDURE.
PROCEDURE local-open-query-left :
    open query br-table-left
        for each buf_left_temp_twowin_items no-lock
           where buf_left_temp_twowin_items.itmSelected = yes
    by buf_left_temp_twowin_items.itmName
    .
 END PROCEDURE.
PROCEDURE local-open-query-right :
do
with frame Dialog-Frame
on error undo, return error
:
    if fi-filter = "":U
    or tb-filter = no
    then do:
        open query br-table-right
            for each buf_right_temp_twowin_items no-lock
            by buf_right_temp_twowin_items.itmName
        .
        assign
            fi-filter :bgcolor = GREY_COLOR
            bt-filter :bgcolor = GREY_COLOR
        .
    end.
    else do:
        open query br-table-right
            for each buf_right_temp_twowin_items no-lock
               where index( buf_right_temp_twowin_items.itmName, fi-filter ) <> 0
            by buf_right_temp_twowin_items.itmName
        .
        assign
            fi-filter :bgcolor = RED_COLOR
            bt-filter :bgcolor = RED_COLOR
        .
    end.
end.
END PROCEDURE.
PROCEDURE select-and-move-down :
define input parameter p-browse-handle  as handle           no-undo.
define input parameter p-query-handle   as handle           no-undo.
    define variable v-focused-row       as integer  no-undo.
    define variable v-repositioned-row  as integer  no-undo.
do
with frame Dialog-Frame
on error undo, return error
:
        assign
            v-focused-row      = p-browse-handle :focused-row
            v-repositioned-row = p-query-handle  :current-result-row
        .
        p-query-handle :get-next ().
        if p-query-handle :query-off-end = no
        then do:
            if v-focused-row > p-browse-handle :height - 2
            then do:
                assign
                    v-repositioned-row  = v-repositioned-row + 1
                .
            end.
            else do:
                assign
                    v-focused-row       = v-focused-row + 1
                    v-repositioned-row  = v-repositioned-row + 1
                .
            end.
            p-browse-handle :set-repositioned-row( v-focused-row, "ALWAYS").
            p-query-handle  :reposition-to-row( v-repositioned-row ).
        end.
end.
END PROCEDURE.
PROCEDURE ui-disable-all :
do
with frame Dialog-Frame
on error undo, return error
:
    disable
        all
        except
            b-exit
            b-help
            br-table-left
            br-table-right
    .
end.
END PROCEDURE.
PROCEDURE ui-enable :
do
with frame Dialog-Frame
on error undo, return error
:
    enable
        bt-filter
        fi-filter
    .
    if p-mode = 1
    then do:
        enable
            b-cancel
            b-help
            bt-sel-sel
            bt-sel-sel-all
            bt-sel-desel-all
            bt-sel-reverse
            bt-not-sel-sel
            bt-not-sel-desel-all
            bt-not-sel-all
            bt-not-sel-reverse
            ed-desc-not-sel
            ed-desc-sel
            bt-select-type
            bt-deselect-type
        .
    end.
    if p-mode = 0
    then do:
        hide
            b-cancel
        .
        assign
            b-exit :label = "В&ыход"
        .
    end.
    if p-runfilename <> "":U
    then do:
        assign
            bt-properties :visible      = yes
            bt-properties :sensitive    = yes
        .
        if p-runfilelabel <> "":U
        then do:
            assign
                bt-properties :label = p-runfilelabel
            .
        end.
    end.
    else do:
        assign
            bt-properties :visible      = no
        .
    end.
end.
END PROCEDURE.
