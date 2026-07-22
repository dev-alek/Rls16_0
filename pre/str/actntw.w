define variable vss-include-info0 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_actntw_items no-undo
    field itm-key       as integer
    field itmExtKey     as character
    field itmType       as character
    field itmName       as character
    field itmDesc       as character
    field itmGdsList    as character
    field itmGds        as logical
    field itmGrpList    as character
    field itmGrp        as logical
    field itmSelected   as logical
    field selLeft       as logical
    field selRight      as logical
    index pi is primary unique
        itm-key
    index ie
        itmExtKey
    index tp
        itmType
        itmName
    index sel
        itmSelected
.
define temp-table temp_actntw_itemsSelected no-undo
    field its-key       as integer
    field itm-key       as integer
    field itmExtKey     as character
    field itmGdsList    as character
    field itmGds        as logical
    field itmGrpList    as character
    field itmGrp        as logical
    index pi is primary unique
        its-key
    index im
        itm-key
.
define variable v-actntw0-itm-key    as integer      no-undo.
procedure actntw_clear :
    define buffer buf_temp_actntw_items        for temp_actntw_items.
do
for buf_temp_actntw_items
on error undo, return error
:
    empty temp-table buf_temp_actntw_items.
end.
end procedure.
procedure actntw_add-item :
define input parameter p-ext-key   as character        no-undo.
define input parameter p-item-type as character        no-undo.
define input parameter p-item-name as character        no-undo.
define input parameter p-item-desc as character        no-undo.
define input parameter p-selected  as logical          no-undo.
define input parameter p-gds       as logical          no-undo.
define input parameter p-grp       as logical          no-undo.
define input parameter p-list      as character        no-undo.
    define buffer buf_temp_actntw_items        for temp_actntw_items.
do
for buf_temp_actntw_items
on error undo, return error
:
    assign
        v-actntw0-itm-key = v-actntw0-itm-key + 1
    .
    create temp_actntw_items.
    assign
        temp_actntw_items.itm-key      = v-actntw0-itm-key
        temp_actntw_items.itmExtKey    = p-ext-key
        temp_actntw_items.itmType      = p-item-type
        temp_actntw_items.itmName      = p-item-name
        temp_actntw_items.itmDesc      = p-item-desc
        temp_actntw_items.itmSelected  = p-selected
        temp_actntw_items.selLeft      = no
        temp_actntw_items.selRight     = no
        temp_actntw_items.itmGds       = p-gds
        temp_actntw_items.itmGrp       = p-grp
        temp_actntw_items.itmGdsList   = IF p-gds THEN p-list ELSE "":U
        temp_actntw_items.itmGrpList   = IF p-grp THEN p-list ELSE "":U
    .
end.
end procedure.
define input parameter p-mainmenu-handle    as widget-handle    no-undo.
define input parameter p-mode               as integer          no-undo.
define input parameter p-title              as character        no-undo.
define input parameter p-runfilename        as character        no-undo.
define input parameter p-runfilelabel       as character        no-undo.
define input parameter table for temp_actntw_items .
define input parameter p-head-code          as integer          no-undo.
define input parameter p-role-code          as integer          no-undo.
define output parameter table for temp_actntw_itemsSelected .
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
    define variable v-actntw-close-enabled    as logical      no-undo.
    define variable v-gds-list                as character    no-undo.
    define variable v-change-goods            as logical      no-undo.
    define buffer buf_right_temp_actntw_items             for temp_actntw_items.
    define buffer buf_left_temp_actntw_items              for temp_actntw_items.
    define buffer buf_temp_actntw_itemsSelected           for temp_actntw_itemsSelected.
DEFINE BUTTON b-cancel AUTO-END-KEY DEFAULT
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-gds-grp
     LABEL "Группы"
     SIZE 10 BY 1 TOOLTIP "Группы товаров, с которыми разрешает работать данное право".
DEFINE BUTTON b-goods
     LABEL "Товары"
     SIZE 10 BY 1 TOOLTIP "Товары, с которыми разрешает работать данное право".
DEFINE BUTTON b-help
     LABEL "Помощ&ь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON bt-deselect-type
     LABEL "<--"
     SIZE 4.25 BY 1.
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
     SIZE 4.25 BY 1.
DEFINE VARIABLE cb-type AS CHARACTER FORMAT "X(256)":U
     LABEL "Тема"
     VIEW-AS COMBO-BOX INNER-LINES 15
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 30 BY 1 NO-UNDO.
DEFINE VARIABLE ed-desc-not-sel AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 45.63 BY 1.63
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE ed-desc-sel AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 45.63 BY 1.63
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-filter AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 19.25 BY 1 NO-UNDO.
DEFINE VARIABLE tb-filter AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.63 BY .79 TOOLTIP "Снятие поиска с фильтром" NO-UNDO.
DEFINE QUERY br-table-left FOR
      buf_left_temp_actntw_items SCROLLING.
DEFINE QUERY br-table-right FOR
      buf_right_temp_actntw_items SCROLLING.
DEFINE BROWSE br-table-left
  QUERY br-table-left NO-LOCK DISPLAY
      buf_left_temp_actntw_items.selLeft  column-label " *" format " */  "
          buf_left_temp_actntw_items.itmType column-label " Тема" format "X(15)"
          buf_left_temp_actntw_items.itmName column-label " Имя права" format "X(40)"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 45.63 BY 18.5 ROW-HEIGHT-CHARS .67.
DEFINE BROWSE br-table-right
  QUERY br-table-right NO-LOCK DISPLAY
      buf_right_temp_actntw_items.selRight column-label " *" format " */  "
          buf_right_temp_actntw_items.itmType column-label " Тема" format "X(15)"
          buf_right_temp_actntw_items.itmName column-label " Имя права" format "X(40)"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 45.63 BY 18.5 ROW-HEIGHT-CHARS .67.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 2 NO-TAB-STOP
     b-cancel AT ROW 1 COL 12 NO-TAB-STOP
     cb-type AT ROW 1 COL 37 COLON-ALIGNED WIDGET-ID 2
     bt-properties AT ROW 1 COL 66.63 NO-TAB-STOP
     b-help AT ROW 1 COL 89 NO-TAB-STOP
     bt-not-sel-sel AT ROW 2.25 COL 2 NO-TAB-STOP
     bt-not-sel-all AT ROW 2.25 COL 5 NO-TAB-STOP
     bt-not-sel-desel-all AT ROW 2.25 COL 8 NO-TAB-STOP
     bt-not-sel-reverse AT ROW 2.25 COL 11 NO-TAB-STOP
     bt-filter AT ROW 2.25 COL 14.63 NO-TAB-STOP
     fi-filter AT ROW 2.25 COL 22.75 COLON-ALIGNED NO-LABEL
     tb-filter AT ROW 2.25 COL 44.63
     bt-sel-sel AT ROW 2.25 COL 53 NO-TAB-STOP
     bt-sel-sel-all AT ROW 2.25 COL 56 NO-TAB-STOP
     bt-sel-desel-all AT ROW 2.25 COL 59 NO-TAB-STOP
     bt-sel-reverse AT ROW 2.25 COL 62 NO-TAB-STOP
     b-goods AT ROW 2.25 COL 78.5 WIDGET-ID 4
     b-gds-grp AT ROW 2.25 COL 88.5 WIDGET-ID 6
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
    if v-actntw-close-enabled = no
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
        v-actntw-close-enabled  = yes
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
        v-actntw-close-enabled = yes
    .
END.
ON CHOOSE OF b-gds-grp IN FRAME Dialog-Frame
DO:
  define variable v-ok    as logical      no-undo.
  IF AVAILABLE buf_left_temp_actntw_items
  AND buf_left_temp_actntw_items.itmGrp
  THEN DO:
      assign
         v-gds-list = buf_left_temp_actntw_items.itmGrpList
      .
      run adm/actngrpg.w (
        INPUT p-mainmenu-handle
            , INPUT p-head-code
            , INPUT p-role-code
            , INPUT INTEGER(buf_left_temp_actntw_items.itmExtKey)
            , INPUT-OUTPUT v-gds-list
            , OUTPUT v-ok
      ) .
      IF  v-ok
      AND buf_left_temp_actntw_items.itmGrpList <> v-gds-list
      THEN DO:
         assign
            v-change-goods                         = TRUE
            buf_left_temp_actntw_items.itmGrpList  = v-gds-list
         .
      end.
  END.
END.
ON CHOOSE OF b-goods IN FRAME Dialog-Frame
DO:
  define variable v-ok    as logical      no-undo.
  IF AVAILABLE buf_left_temp_actntw_items
  AND buf_left_temp_actntw_items.itmGds
  THEN DO:
      assign
         v-gds-list = buf_left_temp_actntw_items.itmGdsList
      .
      run adm/actngdgr.w (
          INPUT p-mainmenu-handle
        , INPUT p-head-code
        , INPUT p-role-code
        , INPUT INTEGER(buf_left_temp_actntw_items.itmExtKey)
        , INPUT-OUTPUT v-gds-list
        , OUTPUT v-ok
      ) .
      IF  v-ok
      AND buf_left_temp_actntw_items.itmGdsList <> v-gds-list
      THEN DO:
         assign
            v-change-goods                         = TRUE
            buf_left_temp_actntw_items.itmGdsList  = v-gds-list
         .
      end.
  END.
END.
ON MOUSE-SELECT-CLICK OF br-table-left IN FRAME Dialog-Frame
or insert-mode of br-table-left in frame dialog-frame
or " " of br-table-left in frame dialog-frame
DO:
    if p-mode = 1
    then do:
        if available buf_left_temp_actntw_items
        and buf_left_temp_actntw_items.itmSelected = yes
        then do:
            assign
                buf_left_temp_actntw_items.selLeft = not( buf_left_temp_actntw_items.selLeft )
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
    if available buf_left_temp_actntw_items
    then do:
        assign
            ed-desc-sel = buf_left_temp_actntw_items.itmDesc
            br-table-left :tooltip = buf_left_temp_actntw_items.itmName
        .
        IF buf_left_temp_actntw_items.itmGds THEN DO:
           ENABLE
               b-goods
           with frame Dialog-Frame .
        END.
        ELSE DO:
            DISABLE
                b-goods
            with frame Dialog-Frame .
        END.
        IF buf_left_temp_actntw_items.itmGrp THEN DO:
           ENABLE
               b-gds-grp
           with frame Dialog-Frame .
        END.
        ELSE DO:
            DISABLE
                b-gds-grp
            with frame Dialog-Frame .
        END.
    end.
    else do:
        assign
            ed-desc-sel = "":U
        .
    end.
    if available buf_right_temp_actntw_items
    then do:
        assign
            ed-desc-not-sel = buf_right_temp_actntw_items.itmDesc
            br-table-right :tooltip = buf_right_temp_actntw_items.itmName
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
        if available buf_right_temp_actntw_items
        and buf_right_temp_actntw_items.itmSelected = no
        then do:
            assign
                buf_right_temp_actntw_items.selRight = not( buf_right_temp_actntw_items.selRight )
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
    if buf_right_temp_actntw_items.itmSelected = yes
    then do:
        assign
            buf_right_temp_actntw_items.itmType :bgcolor in browse br-table-right = GREY_COLOR
            buf_right_temp_actntw_items.itmName :bgcolor in browse br-table-right = GREY_COLOR
            buf_right_temp_actntw_items.selRight :bgcolor in browse br-table-right = GREY_COLOR
        .
    end.
END.
ON CHOOSE OF bt-deselect-type IN FRAME Dialog-Frame
or return of br-table-left in frame dialog-frame
DO:
    if p-mode = 1
    then do:
        for each buf_left_temp_actntw_items
           where buf_left_temp_actntw_items.selLeft = yes
        :
            assign
                buf_left_temp_actntw_items.itmSelected = no
                buf_left_temp_actntw_items.selLeft     = no
            .
        end.
        run local-open-query-left in this-procedure .    run local-open-query-right in this-procedure .
        if available buf_left_temp_actntw_items
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
    if cb-type = "< Все >"
    then do:
        if fi-filter = "":U
        or tb-filter = no
        then do:
            for each buf_right_temp_actntw_items
               where buf_right_temp_actntw_items.itmSelected = no
            :
                assign
                    buf_right_temp_actntw_items.selRight = yes
                .
            end.
        end.
        else do:
            for each buf_right_temp_actntw_items
               where buf_right_temp_actntw_items.itmSelected = no
                and index( buf_right_temp_actntw_items.itmName, fi-filter ) <> 0
            :
                assign
                    buf_right_temp_actntw_items.selRight = yes
                .
            end.
        end.
    end.
    else do:
    if fi-filter = "":U
    or tb-filter = no
    then do:
        for each buf_right_temp_actntw_items
           where buf_right_temp_actntw_items.itmSelected = no
                 and buf_right_temp_actntw_items.itmType     = cb-type
        :
            assign
                buf_right_temp_actntw_items.selRight = yes
            .
        end.
    end.
    else do:
        for each buf_right_temp_actntw_items
           where buf_right_temp_actntw_items.itmSelected = no
                 and buf_right_temp_actntw_items.itmType     = cb-type
             and index( buf_right_temp_actntw_items.itmName, fi-filter ) <> 0
        :
            assign
                buf_right_temp_actntw_items.selRight = yes
            .
        end.
    end.
    end.
    br-table-right :refresh().
    apply "entry" to br-table-right.
END.
ON CHOOSE OF bt-not-sel-desel-all IN FRAME Dialog-Frame
DO:
    for each buf_right_temp_actntw_items
    :
        assign
            buf_right_temp_actntw_items.selRight = no
        .
    end.
    br-table-right :refresh().
    apply "entry" to br-table-right.
END.
ON CHOOSE OF bt-not-sel-reverse IN FRAME Dialog-Frame
DO:
    for each buf_right_temp_actntw_items
       where buf_right_temp_actntw_items.itmSelected = no
    :
        assign
            buf_right_temp_actntw_items.selRight = not( buf_right_temp_actntw_items.selRight )
        .
    end.
    br-table-right :refresh().
    apply "entry" to br-table-right.
END.
ON CHOOSE OF bt-not-sel-sel IN FRAME Dialog-Frame
DO:
    if available buf_right_temp_actntw_items
    and buf_right_temp_actntw_items.itmSelected = no
    then do:
        assign
            buf_right_temp_actntw_items.selRight = not( buf_right_temp_actntw_items.selRight )
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
    if available buf_right_temp_actntw_items
    then do:
        run value( p-runfilename ) (
              input p-mainmenu-handle
            , input buf_right_temp_actntw_items.itmExtKey
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
    for each buf_left_temp_actntw_items
       where buf_left_temp_actntw_items.itmSelected = yes
    :
        assign
            buf_left_temp_actntw_items.selLeft = no
        .
    end.
    br-table-left :refresh().
    apply "entry" to br-table-left.
END.
ON CHOOSE OF bt-sel-reverse IN FRAME Dialog-Frame
DO:
    for each buf_left_temp_actntw_items
       where buf_left_temp_actntw_items.itmSelected = yes
    :
        assign
            buf_left_temp_actntw_items.selLeft = not( buf_left_temp_actntw_items.selLeft )
        .
    end.
    br-table-left :refresh().
    apply "entry" to br-table-left.
END.
ON CHOOSE OF bt-sel-sel IN FRAME Dialog-Frame
DO:
    if available buf_left_temp_actntw_items
    and buf_left_temp_actntw_items.itmSelected = yes
    then do:
        assign
            buf_left_temp_actntw_items.selLeft = not( buf_left_temp_actntw_items.selLeft )
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
    if cb-type = "< Все >"
    then do:
    for each buf_left_temp_actntw_items
       where buf_left_temp_actntw_items.itmSelected = yes
    :
        assign
            buf_left_temp_actntw_items.selLeft = yes
        .
    end.
    end.
    else do:
        for each buf_left_temp_actntw_items
           where buf_left_temp_actntw_items.itmSelected = yes
             and buf_left_temp_actntw_items.itmType     = cb-type
        :
            assign
                buf_left_temp_actntw_items.selLeft = yes
            .
        end.
    end.
    br-table-left :refresh().
    apply "entry" to br-table-left.
END.
ON CHOOSE OF bt-select-type IN FRAME Dialog-Frame
or return of br-table-right in frame dialog-frame
DO:
    define buffer buf_temp_actntw_items for temp_actntw_items.
    if p-mode = 1
    then do:
        for each buf_right_temp_actntw_items
           where buf_right_temp_actntw_items.selRight = yes
        :
            assign
                buf_right_temp_actntw_items.itmSelected = yes
                buf_right_temp_actntw_items.selRight    = no
            .
        end.
        br-table-right :refresh().
        run local-open-query-left in this-procedure .
        find first buf_temp_actntw_items
             where buf_temp_actntw_items.itmSelected = no
        no-error.
        if available buf_temp_actntw_items
        then do:
            apply "entry" to br-table-right.
        end.
        else do:
            apply "entry" to br-table-left.
        end.
    end.
END.
ON VALUE-CHANGED OF cb-type IN FRAME Dialog-Frame
DO:
    assign
        cb-type
    .
    run local-open-query-left in this-procedure .    run local-open-query-right in this-procedure .
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dialog-Frame :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dialog-Frame :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame Dialog-Frame :height
      v-frame-virtual-height = frame Dialog-Frame :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame Dialog-Frame :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame Dialog-Frame :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dialog-Frame :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dialog-Frame :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame Dialog-Frame :width
      v-frame-virtual-width = frame Dialog-Frame :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dialog-Frame :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame Dialog-Frame :width = frame Dialog-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame Dialog-Frame :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame Dialog-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dialog-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dialog-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dialog-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dialog-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dialog-Frame :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame Dialog-Frame
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame Dialog-Frame :height
      v-col-delta = v-new-col - frame Dialog-Frame :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame Dialog-Frame :width
      v-diasize-current-frame-height = frame Dialog-Frame :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      assign
        v-diasize-orig-frame-height = frame Dialog-Frame :height
        v-diasize-orig-frame-width  = frame Dialog-Frame :width
        v-diasize-browse-handle     = browse br-table-left :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dialog-Frame :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
    run diasize_init in this-procedure .
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
    define buffer buf_temp_actntw_itemsSelected    for temp_actntw_itemsSelected.
    define buffer buf_temp_actntw_items            for temp_actntw_items.
do
for buf_temp_actntw_items
  , buf_temp_actntw_itemsSelected
on error undo, return error
:
    assign
        p-changed = no
    .
    check-selected-table:
    for each buf_temp_actntw_itemsSelected no-lock
    on error undo, return error
    :
        find first buf_temp_actntw_items
             where buf_temp_actntw_items.itm-key = buf_temp_actntw_itemsSelected.itm-key
        .
        if buf_temp_actntw_items.itmSelected = no
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
        for each buf_temp_actntw_items
           where buf_temp_actntw_items.itmSelected = yes
        on error undo, return error
        :
            find first buf_temp_actntw_itemsSelected
                 where buf_temp_actntw_itemsSelected.itm-key = buf_temp_actntw_items.itm-key
            no-error.
            if not available buf_temp_actntw_itemsSelected
            then do:
                assign
                    p-changed = yes
                .
                undo check-items-table, leave check-items-table.
            end.
        end.
    end.
    IF v-change-goods = TRUE
    THEN DO:
      assign
         p-changed = yes
      .
    END.
    IF p-changed = yes
    then do:
        empty temp-table
            buf_temp_actntw_itemsSelected
        .
        for each buf_temp_actntw_items
           where buf_temp_actntw_items.itmSelected = yes
        on error undo, return error
        :
            assign
                v-counter = v-counter + 1
            .
            create buf_temp_actntw_itemsSelected.
            assign
                buf_temp_actntw_itemsSelected.its-key    = v-counter
                buf_temp_actntw_itemsSelected.itm-key    = buf_temp_actntw_items.itm-key
                buf_temp_actntw_itemsSelected.itmExtKey  = buf_temp_actntw_items.itmExtKey
                buf_temp_actntw_itemsSelected.itmGdsList = buf_temp_actntw_items.itmGdsList
                buf_temp_actntw_itemsSelected.itmGds     = buf_temp_actntw_items.itmGds
                buf_temp_actntw_itemsSelected.itmGrpList = buf_temp_actntw_items.itmGrpList
                buf_temp_actntw_itemsSelected.itmGrp     = buf_temp_actntw_items.itmGrp
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
  DISPLAY cb-type fi-filter tb-filter ed-desc-not-sel ed-desc-sel
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-cancel cb-type bt-properties b-help bt-filter tb-filter
         b-goods b-gds-grp br-table-right br-table-left bt-select-type
         bt-deselect-type ed-desc-not-sel ed-desc-sel
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  run local-open-query-left in this-procedure .    run local-open-query-right in this-procedure .
END PROCEDURE.
PROCEDURE init-fields :
    define variable v-counter    as integer      no-undo.
    define buffer buf_temp_actntw_items     for temp_actntw_items.
    define buffer buf_temp_actntw_itemsSelected     for temp_actntw_itemsSelected.
do
for buf_temp_actntw_items
  , buf_temp_actntw_itemsSelected
on error undo, return error
:
    if p-title <> "":U
    then do:
        assign
            frame Dialog-Frame :title = p-title
        .
    end.
    assign
        cb-type :list-items = "< Все >"
    .
    for each buf_temp_actntw_items
    break by buf_temp_actntw_items.itmType
    :
        if first-of( buf_temp_actntw_items.itmType )
        then do:
            assign
                cb-type :list-items = substitute( "&1&2&3"
                                    , cb-type :list-items
                                    , ( if cb-type :list-items = "":U
                                        then "":U
                                        else ",":U )
                                    , buf_temp_actntw_items.itmType
                                    )
            .
        end.
    end.
    assign
        cb-type = "< Все >"
    .
    for each buf_temp_actntw_items
       where buf_temp_actntw_items.itmSelected = yes
    :
        assign
            v-counter = v-counter + 1
        .
        create buf_temp_actntw_itemsSelected.
        assign
            buf_temp_actntw_itemsSelected.its-key    = v-counter
            buf_temp_actntw_itemsSelected.itm-key    = buf_temp_actntw_items.itm-key
            buf_temp_actntw_itemsSelected.itmExtKey  = buf_temp_actntw_items.itmExtKey
            buf_temp_actntw_itemsSelected.itmGdsList = buf_temp_actntw_items.itmGdsList
            buf_temp_actntw_itemsSelected.itmGds     = buf_temp_actntw_items.itmGds
            buf_temp_actntw_itemsSelected.itmGrpList = buf_temp_actntw_items.itmGrpList
            buf_temp_actntw_itemsSelected.itmGrp     = buf_temp_actntw_items.itmGrp
        .
    end.
end.
END PROCEDURE.
PROCEDURE local-open-query-left :
    if cb-type = "< Все >"
    then do:
        open query br-table-left
            for each buf_left_temp_actntw_items no-lock
            where buf_left_temp_actntw_items.itmSelected = yes
        by buf_left_temp_actntw_items.itmType
        by buf_left_temp_actntw_items.itmName
        .
    end.
    else do:
        open query br-table-left
            for each buf_left_temp_actntw_items no-lock
               where buf_left_temp_actntw_items.itmSelected = yes
                 and buf_left_temp_actntw_items.itmType     = cb-type
        by buf_left_temp_actntw_items.itmType
        by buf_left_temp_actntw_items.itmName
        .
    end.
 END PROCEDURE.
PROCEDURE local-open-query-right :
do
with frame Dialog-Frame
on error undo, return error
:
    if fi-filter = "":U
    or tb-filter = no
    then do:
        if cb-type = "< Все >"
        then do:
            open query br-table-right
                for each buf_right_temp_actntw_items no-lock
                by buf_right_temp_actntw_items.itmType
                by buf_right_temp_actntw_items.itmName
            .
        end.
        else do:
            open query br-table-right
                for each buf_right_temp_actntw_items no-lock
                   where buf_right_temp_actntw_items.itmType = cb-type
                by buf_right_temp_actntw_items.itmName
            .
        end.
        assign
            fi-filter :bgcolor = GREY_COLOR
            bt-filter :bgcolor = GREY_COLOR
        .
    end.
    else do:
        if cb-type = "< Все >"
        then do:
            open query br-table-right
                for each buf_right_temp_actntw_items no-lock
                where index( buf_right_temp_actntw_items.itmName, fi-filter ) <> 0
                by buf_right_temp_actntw_items.itmType
                by buf_right_temp_actntw_items.itmName
            .
        end.
        else do:
            open query br-table-right
                for each buf_right_temp_actntw_items no-lock
                   where buf_right_temp_actntw_items.itmType = cb-type
                     and index( buf_right_temp_actntw_items.itmName, fi-filter ) <> 0
                by buf_right_temp_actntw_items.itmName
            .
        end.
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
        cb-type
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
