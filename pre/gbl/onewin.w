define variable vss-include-info0 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_onewin_items no-undo
    field itm-key       as integer
    field itmExtKey     as character
    field itmName       as character
    field itmDesc       as character
    field itmSelected   as logical
    index pi is primary unique
        itm-key
    index ie
        itmExtKey
.
define temp-table temp_onewin_itemsSelected no-undo
    field its-key   as integer
    field itm-key   as integer
    field itmExtKey as character
    index pi is primary unique
        its-key
    index im
        itm-key
.
define variable v-onewin0-itm-key    as integer      no-undo.
procedure onewin_clear :
    define buffer buf_temp_onewin_items        for temp_onewin_items.
do
for buf_temp_onewin_items
on error undo, return error
:
    empty temp-table buf_temp_onewin_items.
end.
end procedure.
procedure onewin_add-item :
define input parameter p-ext-key   as character        no-undo.
define input parameter p-item-name as character        no-undo.
define input parameter p-item-desc as character        no-undo.
define input parameter p-selected  as logical          no-undo.
    define buffer buf_temp_onewin_items        for temp_onewin_items.
do
for buf_temp_onewin_items
on error undo, return error
:
    find last buf_temp_onewin_items no-error.
    if available buf_temp_onewin_items then do:
      v-onewin0-itm-key = buf_temp_onewin_items.itm-key.
    end.
    else do:
      v-onewin0-itm-key = 0.
    end.
    assign
        v-onewin0-itm-key = v-onewin0-itm-key + 1
    .
    create buf_temp_onewin_items.
    assign
    buf_temp_onewin_items.itm-key      = v-onewin0-itm-key
    buf_temp_onewin_items.itmExtKey    = p-ext-key
    buf_temp_onewin_items.itmName      = p-item-name
    buf_temp_onewin_items.itmDesc      = p-item-desc
    buf_temp_onewin_items.itmSelected  = p-selected
    .
    if p-selected then do:
      run onewin_create-selection  in this-procedure ( input v-onewin0-itm-key
                                                      ,input p-ext-key).
    end.
end.
end procedure.
procedure onewin_create-selection :
define input parameter p-itm-key as integer no-undo .
define input parameter p-itmextkey as character no-undo .
define variable v-counter as integer no-undo .
define buffer buf_temp_onewin_itemsSelected for temp_onewin_itemsSelected .
do
on error undo, return error
:
  find last buf_temp_onewin_itemsSelected use-index pi no-error.
  if available buf_temp_onewin_itemsSelected then do:
    v-counter = buf_temp_onewin_itemsSelected.its-key.
  end.
  find first buf_temp_onewin_itemsSelected where
       buf_temp_onewin_itemsSelected.itm-key = p-itm-key no-error.
  if not available buf_temp_onewin_itemsSelected then do:
    create buf_temp_onewin_itemsSelected.
    assign
    buf_temp_onewin_itemsSelected.its-key   = v-counter + 1
    v-counter = v-counter + 1
    buf_temp_onewin_itemsSelected.itm-key   = p-itm-key
    buf_temp_onewin_itemsSelected.itmExtKey = p-itmExtKey
    .
  end.
end.
end procedure.
procedure onewin_check-item :
define input parameter p-ext-key   as character        no-undo.
define output parameter p-exists as logical no-undo .
define buffer buf_temp_onewin_items for temp_onewin_items.
find first buf_temp_onewin_items where
buf_temp_onewin_items.itmExtKey    = p-ext-key no-error.
if available buf_temp_onewin_items then do:
  p-exists = yes.
end.
end procedure.
define input parameter parparentproc    as widget-handle    no-undo.
define input parameter p-mode               as integer          no-undo.
define input parameter p-title              as character        no-undo.
define input parameter p-runfilename        as character        no-undo.
define input parameter p-runfilelabel       as character        no-undo.
define input parameter table for temp_onewin_items .
define output parameter table for temp_onewin_itemsSelected .
define output parameter p-cur-ext-key       as character        no-undo.
define output parameter p-accepted          as logical          no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Однооконный интерфейс для выбора из небольшого количества записей".
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
define variable v-onewin-close-enabled      as logical      no-undo.
define variable v-onewin-selected-rowid     as rowid        no-undo.
DEFINE VARIABLE v-parent-handle AS HANDLE NO-UNDO.
define buffer buf_right_temp_onewin_items             for temp_onewin_items.
define buffer buf_left_temp_onewin_items              for temp_onewin_items.
define buffer buf_temp_onewin_itemsSelected           for temp_onewin_itemsSelected.
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON b-close AUTO-END-KEY DEFAULT
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON b-down
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 4.1 BY 1.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помощ&ь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-up
     IMAGE-UP FILE "btn-up-arrow":U
     IMAGE-DOWN FILE "btn-up-arrow":U
     IMAGE-INSENSITIVE FILE "btn-up-arrow":U
     LABEL ""
     SIZE 4.1 BY 1.
DEFINE BUTTON bt-filter DEFAULT
     LABEL "&ФПоиск"
     SIZE 10 BY 1 TOOLTIP "Поиск с фильтром строки во всех текстовых полях"
     BGCOLOR 8 .
DEFINE BUTTON bt-not-sel-all
     LABEL "&+"
     SIZE 3 BY 1 TOOLTIP "Выбрать все".
DEFINE BUTTON bt-not-sel-desel-all
     LABEL "-"
     SIZE 3 BY 1 TOOLTIP "Отменить выбор".
DEFINE BUTTON bt-not-sel-reverse
     LABEL "/"
     SIZE 3 BY 1 TOOLTIP "Инвертировать выбор".
DEFINE BUTTON bt-not-sel-sel
     LABEL "&*"
     SIZE 3 BY 1 TOOLTIP "Выбрать".
DEFINE BUTTON bt-properties DEFAULT
     LABEL "&Свойства"
     SIZE 15 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE ed-desc-not-sel AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 62 BY 2.5
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-filter AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 18 BY 1 NO-UNDO.
DEFINE VARIABLE tb-filter AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.6 BY .8 NO-UNDO.
DEFINE QUERY br-table FOR
      buf_right_temp_onewin_items SCROLLING.
DEFINE BROWSE br-table
  QUERY br-table NO-LOCK DISPLAY
      buf_right_temp_onewin_items.itmSelected column-label " *" format " */  "
      buf_right_temp_onewin_items.itmName column-label " Список" format "X(40)"
    WITH NO-LABELS NO-ROW-MARKERS SEPARATORS SIZE 62 BY 17.07 ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 2 NO-TAB-STOP
     b-close AT ROW 1 COL 12 NO-TAB-STOP
     bt-filter AT ROW 1 COL 22 NO-TAB-STOP
     fi-filter AT ROW 1 COL 30.3 COLON-ALIGNED NO-LABEL
     tb-filter AT ROW 1 COL 51.3
     B-add AT ROW 1 COL 54 WIDGET-ID 6
     B-del AT ROW 1 COL 64 WIDGET-ID 8
     b-help AT ROW 1 COL 74 NO-TAB-STOP
     bt-not-sel-sel AT ROW 2.43 COL 2 NO-TAB-STOP
     bt-not-sel-all AT ROW 2.43 COL 5 NO-TAB-STOP
     bt-not-sel-desel-all AT ROW 2.43 COL 8 NO-TAB-STOP
     bt-not-sel-reverse AT ROW 2.43 COL 11 NO-TAB-STOP
     bt-properties AT ROW 2.5 COL 49 NO-TAB-STOP
     br-table AT ROW 3.67 COL 2
     b-up AT ROW 7.4 COL 71 WIDGET-ID 2 NO-TAB-STOP
     b-down AT ROW 8.47 COL 71 WIDGET-ID 4 NO-TAB-STOP
     ed-desc-not-sel AT ROW 21 COL 2 NO-LABEL NO-TAB-STOP
     SPACE(13.69) SKIP(0.26)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Выбор из списка"
         CANCEL-BUTTON b-close.
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
       fi-filter:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
    if v-onewin-close-enabled = no
    then do:
        undo, return no-apply.
    end.
    else do:
        assign
            p-accepted = yes
        .
        run check-data in this-procedure.
        run assign-export-table in this-procedure .
        assign
            p-cur-ext-key = ( if available buf_right_temp_onewin_items then buf_right_temp_onewin_items.itmExtKey else "":U )
        .
    end.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
    APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-add IN FRAME Dialog-Frame
DO:
  RUN onewin_custom-add-item IN v-parent-handle ( input this-procedure:handle  ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
     RETURN NO-APPLY.
  END.
  run local-open-query in this-procedure .
END.
ON CHOOSE OF b-close IN FRAME Dialog-Frame
DO:
    assign
        v-onewin-close-enabled  = yes
        p-accepted              = no
    .
END.
ON CHOOSE OF B-del IN FRAME Dialog-Frame
DO:
DEFINE buffer dEL_temp_onewin_items FOR temp_onewin_items.
  IF NOT AVAILABLE buf_right_temp_onewin_items THEN DO:
     RETURN NO-APPLY.
  END.
  find first dEL_temp_onewin_items where recid(dEL_temp_onewin_items) = recid(buf_right_temp_onewin_items).
  DELETE del_temp_onewin_items.
  run local-open-query in this-procedure .
END.
ON CHOOSE OF b-down IN FRAME Dialog-Frame
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
DEFINE VARIABLE v-new AS INTEGER NO-UNDO.
DEFINE VARIABLE v-old AS INTEGER NO-UNDO.
define variable v-rec as recid no-undo .
DEFINE BUFFER down_right_temp_onewin_items FOR temp_onewin_items.
IF NOT AVAILABLE buf_right_temp_onewin_items THEN RETURN NO-APPLY.
FIND last down_right_temp_onewin_items WHERE
            USE-INDEX pi .
 IF buf_right_temp_onewin_items.itm-key = down_right_temp_onewin_items.itm-key THEN DO:
     BELL.
     RETURN NO-APPLY.
 END.
 ASSIGN
 v-rec = recid(buf_right_temp_onewin_items)
 v-old = buf_right_temp_onewin_items.itm-key
 .
 FIND FIRST down_right_temp_onewin_items WHERE
            down_right_temp_onewin_items.itm-key > v-old use-index pi NO-ERROR.
 if available down_right_temp_onewin_items then do:
   v-new = down_right_temp_onewin_items.itm-key.
 end.
 else do:
   bell.
   return no-apply.
 end.
 ASSIGN
 buf_right_temp_onewin_items.itm-key = 0.
 RELEASE buf_right_temp_onewin_items.
 down_right_temp_onewin_items.itm-key = v-old.
 RELEASE down_right_temp_onewin_items.
 FIND FIRST down_right_temp_onewin_items WHERE
            down_right_temp_onewin_items.itm-key = 0.
 ASSIGN
 down_right_temp_onewin_items.itm-key = v-new.
 RELEASE down_right_temp_onewin_items.
 run local-open-query in this-procedure .
 reposition br-table to recid v-rec.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
or F2 of frame Dialog-Frame anywhere
DO:
define variable vss-include-info3 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
        v-onewin-close-enabled = yes
    .
END.
ON CHOOSE OF b-up IN FRAME Dialog-Frame
DO:
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
DEFINE VARIABLE v-new AS INTEGER NO-UNDO.
DEFINE VARIABLE v-old AS INTEGER NO-UNDO.
define variable v-rec as recid no-undo .
DEFINE BUFFER up_right_temp_onewin_items FOR temp_onewin_items.
IF NOT AVAILABLE buf_right_temp_onewin_items THEN RETURN NO-APPLY.
IF buf_right_temp_onewin_items.itm-key = 1 THEN DO:
  BELL.
  RETURN NO-APPLY.
END.
ASSIGN
v-rec = recid(buf_right_temp_onewin_items)
v-old = buf_right_temp_onewin_items.itm-key
.
FIND last up_right_temp_onewin_items WHERE
          up_right_temp_onewin_items.itm-key < v-old use-index pi NO-ERROR.
if available up_right_temp_onewin_items then do:
  v-new = up_right_temp_onewin_items.itm-key.
end.
else do:
  bell.
  return no-apply.
end.
ASSIGN
buf_right_temp_onewin_items.itm-key = 0.
RELEASE buf_right_temp_onewin_items.
up_right_temp_onewin_items.itm-key = v-old.
RELEASE up_right_temp_onewin_items.
FIND FIRST up_right_temp_onewin_items WHERE
          up_right_temp_onewin_items.itm-key = 0.
ASSIGN
up_right_temp_onewin_items.itm-key = v-new.
RELEASE up_right_temp_onewin_items.
run local-open-query in this-procedure .
reposition br-table to recid v-rec.
END.
ON insert-mode OF br-table IN FRAME Dialog-Frame
or " " of br-table in frame dialog-frame
DO:
    if p-mode = 1
    then do:
      apply "choose":u to bt-not-sel-sel.
    end.
END.
ON MOUSE-SELECT-CLICK OF br-table IN FRAME Dialog-Frame
DO:
    if p-mode = 1
    and buf_right_temp_onewin_items.itmselected:visible in browse br-table
    then do:
        if available buf_right_temp_onewin_items
        then do:
            assign
                buf_right_temp_onewin_items.itmSelected = not( buf_right_temp_onewin_items.itmSelected )
            .
            display
                itmSelected
            with browse br-table .
            apply "entry" to br-table.
        end.
    end.
END.
ON ROW-DISPLAY OF br-table IN FRAME Dialog-Frame
DO:
    define buffer buf_temp_onewin_itemsSelected    for temp_onewin_itemsSelected.
    if available buf_right_temp_onewin_items
    then do:
        find first buf_temp_onewin_itemsSelected
             where buf_temp_onewin_itemsSelected.itm-key = buf_right_temp_onewin_items.itm-key
        no-error.
        if available buf_temp_onewin_itemsSelected
        then do:
            assign
                buf_right_temp_onewin_items.itmName :bgcolor in browse br-table = GRAY_COLOR
                buf_right_temp_onewin_items.itmSelected :bgcolor in browse br-table = GRAY_COLOR
            .
        end.
    end.
END.
ON VALUE-CHANGED OF br-table IN FRAME Dialog-Frame
or entry of br-table IN FRAME Dialog-Frame
DO:
    if available buf_right_temp_onewin_items
    then do:
        assign
            ed-desc-not-sel = buf_right_temp_onewin_items.itmDesc
        .
    end.
    else do:
        assign
            ed-desc-not-sel = "":U
        .
    end.
    display
        ed-desc-not-sel
    with frame Dialog-Frame.
END.
ON CHOOSE OF bt-filter IN FRAME Dialog-Frame
DO:
    define variable v-new-filter    as character    no-undo.
    define variable v-accepted      as logical      no-undo.
    run gbl/onewinf.w (
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
                tb-filter = no
            .
        end.
        else do:
            assign
                tb-filter = yes
            .
        end.
        display
            fi-filter
            tb-filter
        with frame Dialog-Frame.
        run local-open-query in this-procedure .
        apply "entry":U to br-table.
    end.
END.
ON CHOOSE OF bt-not-sel-all IN FRAME Dialog-Frame
DO:
    if fi-filter = "":U
    or tb-filter = no
    then do:
        for each buf_right_temp_onewin_items
           where buf_right_temp_onewin_items.itmSelected = no
        :
            assign
                buf_right_temp_onewin_items.itmSelected = yes
            .
        end.
    end.
    else do:
        for each buf_right_temp_onewin_items
           where buf_right_temp_onewin_items.itmSelected = no
             and index( buf_right_temp_onewin_items.itmName, fi-filter ) <> 0
        :
            assign
                buf_right_temp_onewin_items.itmSelected = yes
            .
        end.
    end.
    br-table :refresh().
    apply "entry" to br-table.
END.
ON CHOOSE OF bt-not-sel-desel-all IN FRAME Dialog-Frame
DO:
    for each buf_right_temp_onewin_items
    :
        assign
            buf_right_temp_onewin_items.itmSelected = no
        .
    end.
    br-table :refresh().
    apply "entry" to br-table.
END.
ON CHOOSE OF bt-not-sel-reverse IN FRAME Dialog-Frame
DO:
    for each buf_right_temp_onewin_items
    :
        assign
            buf_right_temp_onewin_items.itmSelected = not( buf_right_temp_onewin_items.itmSelected )
        .
    end.
    br-table :refresh().
    apply "entry" to br-table.
END.
ON CHOOSE OF bt-not-sel-sel IN FRAME Dialog-Frame
DO:
    if available buf_right_temp_onewin_items
    then do:
        assign
            buf_right_temp_onewin_items.itmSelected = not( buf_right_temp_onewin_items.itmSelected )
        .
        display
            itmSelected
        with browse br-table .
        run select-and-move-down in this-procedure (
              input browse br-table :handle
            , input query br-table :handle
        ).
        apply "entry" to br-table.
    end.
END.
ON CHOOSE OF bt-properties IN FRAME Dialog-Frame
DO:
    if available buf_right_temp_onewin_items
    then do:
        run value( p-runfilename ) (
              input parparentproc
            , input buf_right_temp_onewin_items.itmExtKey
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
ON VALUE-CHANGED OF tb-filter IN FRAME Dialog-Frame
DO:
    assign
        tb-filter
    .
    run local-open-query in this-procedure .
    apply "entry":U to br-table.
END.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-F7 of frame Dialog-Frame anywhere do:
  if b-close :sensitive then DO: apply "CHOOSE":U to b-close in frame Dialog-Frame. END.
  return no-apply.
end.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  ASSIGN
  v-parent-handle = THIS-PROCEDURE:INSTANTIATING-PROCEDURE.
  run init-fields in this-procedure.
  RUN enable_UI.
  run ui-disable-all in this-procedure.
  run ui-enable in this-procedure.
  apply "entry" to br-table.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE assign-export-table :
    define variable v-counter    as integer      no-undo.
    define buffer buf_temp_onewin_itemsSelected    for temp_onewin_itemsSelected.
    define buffer buf_temp_onewin_items            for temp_onewin_items.
do
for buf_temp_onewin_items
  , buf_temp_onewin_itemsSelected
on error undo, return error
:
    empty temp-table
        buf_temp_onewin_itemsSelected
    .
    for each buf_temp_onewin_items
        where buf_temp_onewin_items.itmSelected = yes
    on error undo, return error
    :
        run onewin_create-selection in this-procedure ( input buf_temp_onewin_items.itm-key
                                                       ,input buf_temp_onewin_items.itmExtKey
                                                       ).
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
  DISPLAY fi-filter tb-filter ed-desc-not-sel
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-close bt-filter tb-filter B-add B-del b-help bt-properties
         br-table b-up b-down ed-desc-not-sel
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  run local-open-query in this-procedure .
END PROCEDURE.
PROCEDURE init-fields :
    define variable v-counter    as integer      no-undo.
    define buffer buf_temp_onewin_items         for temp_onewin_items.
    define buffer buf_temp_onewin_itemsSelected for temp_onewin_itemsSelected.
do
for buf_temp_onewin_items
  , buf_temp_onewin_itemsSelected
on error undo, return error
:
    if p-title <> "":U
    then do:
        assign
            frame Dialog-Frame :title = p-title
        .
    end.
    for each buf_temp_onewin_items
       where buf_temp_onewin_items.itmSelected = yes
    on error undo, return error
    :
        assign
            v-counter = v-counter + 1
        .
        create buf_temp_onewin_itemsSelected.
        assign
            buf_temp_onewin_itemsSelected.its-key   = v-counter
            buf_temp_onewin_itemsSelected.itm-key   = buf_temp_onewin_items.itm-key
            buf_temp_onewin_itemsSelected.itmExtKey = buf_temp_onewin_items.itmExtKey
        .
        assign
            v-onewin-selected-rowid = rowid( buf_temp_onewin_items )
        .
        if p-mode = 0
        or p-mode = 2
        then do:
            assign
                buf_temp_onewin_items.itmSelected = no
            .
        end.
    end.
end.
END PROCEDURE.
PROCEDURE local-open-query :
do
with frame Dialog-Frame
on error undo, return error
:
if b-up:visible in frame Dialog-Frame then do:
  if fi-filter = "":U
  or tb-filter = no
  then do:
    open query br-table
        for each buf_right_temp_onewin_items no-lock
        by buf_right_temp_onewin_items.itm-key
    .
    assign
    fi-filter :bgcolor = GREY_COLOR
    bt-filter :bgcolor = GREY_COLOR
    .
  end.
  else do:
    open query br-table
        for each buf_right_temp_onewin_items no-lock
            where index( buf_right_temp_onewin_items.itmName, fi-filter ) <> 0
        by buf_right_temp_onewin_items.itm-key
    .
    assign
    fi-filter :bgcolor = RED_COLOR
    bt-filter :bgcolor = RED_COLOR
    .
  end.
end.
else do:
    if fi-filter = "":U
    or tb-filter = no
    then do:
        open query br-table
            for each buf_right_temp_onewin_items no-lock
            by buf_right_temp_onewin_items.itmName
        .
        assign
            fi-filter :bgcolor = GREY_COLOR
            bt-filter :bgcolor = GREY_COLOR
        .
    end.
    else do:
        open query br-table
            for each buf_right_temp_onewin_items no-lock
               where index( buf_right_temp_onewin_items.itmName, fi-filter ) <> 0
            by buf_right_temp_onewin_items.itmName
        .
        assign
            fi-filter :bgcolor = RED_COLOR
            bt-filter :bgcolor = RED_COLOR
        .
    end.
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
            br-table
    .
end.
END PROCEDURE.
PROCEDURE ui-enable :
define variable v-bttns as character no-undo .
do
with frame Dialog-Frame
on error undo, return error
:
    enable
        bt-filter
        fi-filter
        tb-filter
        ed-desc-not-sel
    .
  case p-mode:
    when 1 then do:
            enable
                b-close
                bt-not-sel-sel
                bt-not-sel-desel-all
                bt-not-sel-all
                bt-not-sel-reverse
            .
        end.
      when 2 then do:
            enable
                b-close
            .
            reposition br-table to rowid( v-onewin-selected-rowid ) no-error.
        end.
      when 0 then do:
            assign
                b-exit :label = "В&ыход"
            .
        end.
    end case.
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
  IF LOOKUP("onewin_get-bttns", v-parent-handle:INTERNAL-ENTRIES) > 0 THEN DO:
    run onewin_get-bttns in v-parent-handle ( output v-bttns).
    if lookup("bt-not-sel-sel", v-bttns) = 0 then do:
      disable
      bt-not-sel-sel
      with frame Dialog-Frame .
      hide
      bt-not-sel-sel
      in frame Dialog-Frame .
    end.
    if lookup("bt-not-sel-desel-all", v-bttns) = 0 then do:
      disable
      bt-not-sel-desel-all
      with frame Dialog-Frame .
      hide
      bt-not-sel-desel-all
      in frame Dialog-Frame .
    end.
    if lookup("bt-not-sel-all", v-bttns) = 0 then do:
      disable
      bt-not-sel-all
      with frame Dialog-Frame .
      hide
      bt-not-sel-all
      in frame Dialog-Frame .
    end.
    if lookup("bt-not-sel-reverse", v-bttns) = 0 then do:
      disable
      bt-not-sel-reverse
      with frame Dialog-Frame .
      hide
      bt-not-sel-reverse
      in frame Dialog-Frame .
    end.
    IF LOOKUP("b-exit", v-bttns) > 0 THEN DO:
      enable
      b-exit
      with frame Dialog-Frame .
    end.
    else do:
      hide
      b-exit
      in frame Dialog-Frame .
    end.
    IF LOOKUP("onewin_custom-add-item", v-parent-handle:INTERNAL-ENTRIES) > 0
    and lookup("b-add", v-bttns) > 0
    THEN DO:
      enable
      b-add
      with frame Dialog-Frame .
    end.
    else do:
      hide
      b-add
      in frame Dialog-Frame .
    end.
    IF LOOKUP("b-del", v-bttns) > 0 THEN DO:
      enable
      b-del
      with frame Dialog-Frame .
    end.
    else do:
      hide
      b-del
      in frame Dialog-Frame .
    end.
    IF LOOKUP("b-up", v-bttns) > 0 THEN DO:
      enable
      b-up
      with frame Dialog-Frame .
    end.
    else do:
      hide
      b-up
      in frame Dialog-Frame .
    end.
    IF LOOKUP("b-down", v-bttns) > 0 THEN DO:
      enable
      b-down
      with frame Dialog-Frame .
    end.
    else do:
      hide
      b-down
      in frame Dialog-Frame .
    end.
  end.
  if bt-not-sel-sel:visible in frame Dialog-Frame = no
  and bt-not-sel-desel-all:visible in frame Dialog-Frame = no
  and bt-not-sel-all:visible in frame Dialog-Frame = no
  and bt-not-sel-reverse:visible in frame Dialog-Frame = no then do:
    assign
    buf_right_temp_onewin_items.itmselected:visible in browse br-table = no.
  end.
end.
END PROCEDURE.
