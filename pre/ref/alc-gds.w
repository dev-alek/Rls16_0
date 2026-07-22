define input parameter parParentProc  as widget-handle no-undo.
define input parameter p-alc-type-inner-code   like ub.alc-type.alc-type-inner-code no-undo.
define input parameter p-db-num like ub.alc-type.create-user-db-num no-undo.
define input parameter p-name   like ub.alc-type.alc-type-name no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Привязка товаров к типам алкоголя".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table gds-list no-undo like ub.goods
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field to-sel as logical
  field promo-code as character
  field ActionId  as int64
  field db-num as integer
  index art  is primary unique artic prod-type prod-code
  index code is         unique gds-code
  index oi order-num
  index isel to-sel
  .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table gds-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
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
define variable rid-list    as  character no-undo .
define variable log-res     as log no-undo.
define variable rr          as recid no-undo.
define variable v-log       as logical   no-undo .
define variable line-mode   as character no-undo .
define variable doc-rec     as recid no-undo .
define variable gds-rec     as recid no-undo .
define variable lns-cnt     as integer   no-undo .
define variable g#log       as logical   no-undo .
define variable varschartic like ub.price-list.artic initial " " no-undo.
define variable ref-list    as character                     no-undo.
define variable sch-field   as character no-undo.
define variable sort-column-name as character no-undo .
define variable list-option as character no-undo.
define variable v-brws-mark as character no-undo COLUMN-LABEL "*"        FORMAT "X(1)":U  .
define stream sout.
define temp-table tt-gds-list no-undo like ub.goods
field nn as integer
index by-nn nn
index by_gds-code gds-code
.
define buffer buf_alc-type-gds for ub.alc-type-gds.
define buffer buf_goods        for ub.goods.
define buffer buf_alc-type     for ub.alc-type.
DEFINE MENU POPUP-MENU-b-mark
       MENU-ITEM m_mark_all     LABEL "Выбрать все"
       MENU-ITEM m_mark_no_one  LABEL "Снять выбор у всех"
       MENU-ITEM m_mark_invert  LABEL "Инвертировать выбор".
DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 3 BY 1.
DEFINE BUTTON b-add
     LABEL "&Добавить":L
     SIZE 10 BY 1.
DEFINE BUTTON b-del
     LABEL "&Удалить":L
     SIZE 10 BY 1.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход ":L
     SIZE 10 BY 1.
DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 10 BY 1.
DEFINE BUTTON b-print
     LABEL "Пе&чать":L
     SIZE 10 BY 1.
DEFINE VARIABLE FILL-IN-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Поиск по"
      VIEW-AS TEXT
     SIZE 8.88 BY .67 NO-UNDO.
DEFINE VARIABLE s-artic AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 25 BY 1 NO-UNDO.
DEFINE VARIABLE s-code AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 25 BY 1 NO-UNDO.
DEFINE VARIABLE s-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 25 BY 1 NO-UNDO.
DEFINE VARIABLE s-name-cnt AS CHARACTER FORMAT "X(256)":U
     LABEL ""
     VIEW-AS FILL-IN
     SIZE 25 BY 1 NO-UNDO.
DEFINE VARIABLE r-sort AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Код", 1,
"Артикул", 2,
"Нач.назв", 3
     SIZE 38.75 BY .96 TOOLTIP "Поиск по" NO-UNDO.
DEFINE QUERY BROWSE-2 FOR
      alc-type-gds,
      goods
      SCROLLING.
DEFINE BROWSE BROWSE-2
  QUERY BROWSE-2 NO-LOCK DISPLAY
      (IF ( INDEX (rid-list, string( recid(alc-type-gds)) ) > 0 ) THEN ("*") ELSE (" ")) @ v-brws-mark
      goods.artic FORMAT "X(16)":U
      goods.gds-name FORMAT "X(48)":U
      goods.gds-code FORMAT "999999999":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 87 BY 18.92
         BGCOLOR 15 .
DEFINE FRAME Dialog-Frame
     b-mark AT ROW 1.0 COL 33
     b-exit AT ROW 1 COL 1
     b-add AT ROW 1 COL 12
     b-del AT ROW 1 COL 22
     b-print AT ROW 1 COL 68
     b-help AT ROW 1 COL 78
     r-sort AT ROW 2.04 COL 10.75 NO-LABEL WIDGET-ID 4
     s-artic AT ROW 2.04 COL 49 COLON-ALIGNED NO-LABEL WIDGET-ID 10
     s-name AT ROW 2.04 COL 49 COLON-ALIGNED NO-LABEL WIDGET-ID 8
     s-name-cnt AT ROW 2.04 COL 49 COLON-ALIGNED WIDGET-ID 12
     s-code AT ROW 2.04 COL 49 COLON-ALIGNED NO-LABEL WIDGET-ID 14
     BROWSE-2 AT ROW 3.13 COL 1
     FILL-IN-2 AT ROW 2.21 COL 1 NO-LABEL WIDGET-ID 2
     SPACE(78.12) SKIP(19.17)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Товары ".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
       ASSIGN
       b-mark:POPUP-MENU IN FRAME Dialog-Frame       = MENU POPUP-MENU-b-mark:HANDLE.
ON CHOOSE OF b-mark IN FRAME Dialog-Frame
or insert-mode of browse-2 IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF BROWSE-2 IN FRAME Dialog-Frame
DO:
   define variable v-ok as logical no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid5 as character no-undo .
define variable v-num-entry5 as integer   no-undo .
assign
  v-str-recid5 = trim( string( recid( alc-type-gds ) , "->>>>>>>>>>>9":U ) )
  v-num-entry5 = lookup( v-str-recid5 , rid-list )
.
if v-num-entry5 > 0 then do:
  assign
    entry( v-num-entry5, rid-list ) = "":U
    rid-list = trim( replace( rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    rid-list = rid-list + ( if rid-list = "":U then "":U else chr(44) ) + v-str-recid5
  .
end.
   v-ok = BROWSE-2:select-next-row () no-error .
   v-ok = BROWSE-2:refresh( )  in frame Dialog-Frame no-error .
END.
ON CHOOSE OF MENU-ITEM m_mark_all
or + of browse-2 IN FRAME Dialog-Frame
DO:
   define variable v-ok as logical no-undo .
   assign rid-list = "" .
     for each alc-type-gds
      WHERE alc-type-gds.alc-type-inner-code = p-alc-type-inner-code  NO-LOCK,
      EACH goods WHERE goods.gds-code = alc-type-gds.gds-code NO-LOCK
      :
      rid-list = rid-list + string( recid(alc-type-gds) ) .
   end .
   v-ok = BROWSE-2:refresh( )  in frame Dialog-Frame no-error.
END.
ON CHOOSE OF MENU-ITEM m_mark_no_one
or - of browse-2 IN FRAME Dialog-Frame
DO:
   define variable v-ok as logical no-undo .
   rid-list =  " " .
   v-ok = BROWSE-2:refresh( )  in frame Dialog-Frame no-error.
END.
ON CHOOSE OF MENU-ITEM m_mark_invert
or * of browse-2 IN FRAME Dialog-Frame
DO:
   define variable v-ok as logical no-undo .
     for each alc-type-gds
      WHERE alc-type-gds.alc-type-inner-code = p-alc-type-inner-code  NO-LOCK,
      EACH goods WHERE goods.gds-code = alc-type-gds.gds-code NO-LOCK
      :
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid7 as character no-undo .
define variable v-num-entry7 as integer   no-undo .
assign
  v-str-recid7 = trim( string( recid( alc-type-gds ) , "->>>>>>>>>>>9":U ) )
  v-num-entry7 = lookup( v-str-recid7 , rid-list )
.
if v-num-entry7 > 0 then do:
  assign
    entry( v-num-entry7, rid-list ) = "":U
    rid-list = trim( replace( rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    rid-list = rid-list + ( if rid-list = "":U then "":U else chr(44) ) + v-str-recid7
  .
end.
   end .
   v-ok = BROWSE-2:refresh( )  in frame Dialog-Frame no-error.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-add IN FRAME Dialog-Frame
DO:
assign
  line-mode = 'ДОБАВЛЕНИЕ':U
.
run str/chsgdsls.w
(   input parParentProc ,
    input "alc-type" ,
    input "Вид акоголя: " + p-name  ,
    input ? ,
    input ? ,
    input v-cntxt-host-code-obj,
    input-output varschartic,
    output ref-list,
    output table tt-gds-list,
    false )
    .
    if ref-list <> "" then do:
       run cycle-add in this-procedure no-error.
      if error-status:error then do:
         message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процедуры создания товара" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
         return no-apply.
      end.
    end.
    OPEN QUERY BROWSE-2 FOR EACH alc-type-gds       WHERE alc-type-gds.alc-type-inner-code = p-alc-type-inner-code  NO-LOCK,       EACH goods WHERE goods.gds-code = alc-type-gds.gds-code NO-LOCK     .
    for first goods WHERE recid (goods) = integer (entry (1, ref-list)),
     first alc-type-gds where goods.gds-code = alc-type-gds.gds-code NO-LOCK
     :
       def var p-rec as recid no-undo .
       p-rec = recid(alc-type-gds) .
       REPOSITION BROWSE-2 TO RECID p-rec  NO-ERROR.
    end .
END.
ON CHOOSE OF b-del IN FRAME Dialog-Frame
DO:
      define buffer del_alc-type-gds for ub.alc-type-gds.
      message "Удалить выбранные записи ?"
      view-as alert-box question
      buttons ok-cancel
      update v-ok as logical
      .
      if v-ok then do:
        if string(rid-list) eq "" then do:
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid9 as character no-undo .
define variable v-num-entry9 as integer   no-undo .
assign
  v-str-recid9 = trim( string( recid( alc-type-gds ) , "->>>>>>>>>>>9":U ) )
  v-num-entry9 = lookup( v-str-recid9 , rid-list )
.
if v-num-entry9 > 0 then do:
  assign
    entry( v-num-entry9, rid-list ) = "":U
    rid-list = trim( replace( rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    rid-list = rid-list + ( if rid-list = "":U then "":U else chr(44) ) + v-str-recid9
  .
end.
           v-ok = BROWSE-2:select-next-row () no-error .
           if v-ok eq no then v-ok = BROWSE-2:select-prev-row () no-error .
        end .
       def var p-int as int no-undo .
       do  p-int = 1 to NUM-ENTRIES(rid-list) :
           find first del_alc-type-gds
            WHERE   ENTRY( p-int , rid-list )  eq string( recid(del_alc-type-gds)) no-error.
           delete del_alc-type-gds.
       end .
        assign rid-list = "" .
      end .
      v-ok = BROWSE-2:select-prev-row () no-error .
      if v-ok eq YES then
       v-ok = BROWSE-2:select-next-row () no-error .
      v-ok = BROWSE-2:refresh( )  in frame Dialog-Frame no-error.
END.
ON VALUE-CHANGED OF r-sort IN FRAME Dialog-Frame
DO:
  Assign frame Dialog-Frame r-sort.
  case r-sort :
  when 1 then do:
        if sch-field = "s-name-cnt" then do:
                       assign frame Dialog-Frame:title = "Товары >> Вид алкогольной продукции - " + p-name.
                      OPEN QUERY BROWSE-2 FOR EACH alc-type-gds       WHERE alc-type-gds.alc-type-inner-code = p-alc-type-inner-code  NO-LOCK,       EACH goods WHERE goods.gds-code = alc-type-gds.gds-code NO-LOCK     .
                      end.
        enable s-code with frame Dialog-Frame.
            Hide s-name  s-name-cnt s-artic in frame Dialog-Frame.
        display s-code with frame Dialog-Frame.
        apply "entry" to s-code in frame Dialog-Frame.
   end.
  when 2 then do:
        if sch-field = "s-name-cnt" then do:
                       assign frame Dialog-Frame:title = "Товары >> Вид алкогольной продукции - " + p-name.
                      OPEN QUERY BROWSE-2 FOR EACH alc-type-gds       WHERE alc-type-gds.alc-type-inner-code = p-alc-type-inner-code  NO-LOCK,       EACH goods WHERE goods.gds-code = alc-type-gds.gds-code NO-LOCK     .
                      end.
        enable s-artic with frame Dialog-Frame.
            Hide s-name  s-name-cnt s-code in frame Dialog-Frame.
        display s-artic with frame Dialog-Frame.
        apply "entry" to s-artic in frame Dialog-Frame.
   end.
  when 3 then do:
    if sch-field = "s-name-cnt" then do:
                 assign frame Dialog-Frame:title = "Товары >> Вид алкогольной продукции - " + p-name.
                OPEN QUERY BROWSE-2 FOR EACH alc-type-gds       WHERE alc-type-gds.alc-type-inner-code = p-alc-type-inner-code  NO-LOCK,       EACH goods WHERE goods.gds-code = alc-type-gds.gds-code NO-LOCK     .
                end.
        enable s-name with frame Dialog-Frame.
        hide s-artic  s-name-cnt s-code in frame Dialog-Frame.
        display s-name with frame Dialog-Frame.
        apply "entry" to s-name in frame Dialog-Frame.
   end.
  when 4 then do:
        enable s-name-cnt with frame Dialog-Frame.
        hide s-artic  s-name s-code in frame Dialog-Frame.
        display s-name-cnt with frame Dialog-Frame.
        apply "entry" to s-name-cnt in frame Dialog-Frame.
   end.
  end case.
END.
ON MOUSE-SELECT-DBLCLICK OF s-artic IN FRAME Dialog-Frame
OR  RETURN OF s-artic IN FRAME Dialog-Frame
DO:
  if s-artic <> input frame Dialog-Frame s-artic or sch-field <> "s-artic" then do:
 sch-field = "s-artic".
 assign s-artic = input frame Dialog-Frame s-artic.
 doc-rec = ?.
 for each buf_alc-type-gds where buf_alc-type-gds.alc-type-inner-code = p-alc-type-inner-code,
            first buf_goods where buf_alc-type-gds.gds-code = buf_goods.gds-code and
                                  buf_goods.artic begins s-artic :
         doc-rec = recid(buf_alc-type-gds) .
         leave.
 end.
  if doc-rec = ? then message "Товар не найден !"  .
  else
      reposition BROWSE-2 to recid doc-rec no-error.
return no-apply.
end.
END.
ON MOUSE-SELECT-DBLCLICK OF s-code IN FRAME Dialog-Frame
OR  RETURN OF s-code IN FRAME Dialog-Frame
DO:
  if s-code <> input frame Dialog-Frame s-code or sch-field <> "s-code" then do:
 sch-field = "s-code".
 assign s-code = input frame Dialog-Frame s-code.
 doc-rec = ?.
 for each buf_alc-type-gds where buf_alc-type-gds.alc-type-inner-code = p-alc-type-inner-code,
            first buf_goods where buf_alc-type-gds.gds-code = buf_goods.gds-code and
                                  buf_goods.gds-code = integer(s-code) :
         doc-rec = recid(buf_alc-type-gds) .
         leave.
 end.
  if doc-rec = ? then message "Товар не найден !"  .
  else
      reposition BROWSE-2 to recid doc-rec no-error.
return no-apply.
end.
END.
ON MOUSE-SELECT-DBLCLICK OF s-name IN FRAME Dialog-Frame
OR  RETURN OF s-name IN FRAME Dialog-Frame
DO:
  if s-name <> input frame Dialog-Frame s-name or sch-field <> "s-name" then do:
 sch-field = "s-name".
 assign s-name = input frame Dialog-Frame s-name.
 doc-rec = ?.
 for each buf_alc-type-gds where buf_alc-type-gds.alc-type-inner-code = p-alc-type-inner-code,
            first buf_goods where buf_alc-type-gds.gds-code = buf_goods.gds-code and
                                  buf_goods.gds-name begins s-name :
         doc-rec = recid(buf_alc-type-gds) .
         leave.
 end.
  if doc-rec = ? then message "Товар не найден !"  .
  else
      reposition BROWSE-2 to recid doc-rec no-error.
return no-apply.
end.
END.
ON MOUSE-SELECT-DBLCLICK OF s-name-cnt IN FRAME Dialog-Frame
OR  RETURN OF s-name-cnt IN FRAME Dialog-Frame
DO:
  if s-name-cnt <> input frame Dialog-Frame s-name-cnt or sch-field <> "s-name-cnt" then do:
 sch-field = "s-name-cnt".
 assign s-name-cnt = input frame Dialog-Frame s-name-cnt.
 doc-rec = ?.
 for each buf_alc-type-gds where buf_alc-type-gds.alc-type-inner-code = p-alc-type-inner-code,
            first buf_goods where
               buf_alc-type-gds.gds-code = buf_goods.gds-code and
             INDEX(buf_goods.gds-name,s-name-cnt) > 0 :
         doc-rec = recid(buf_alc-type-gds) .
         leave.
 end.
  if doc-rec = ? then message "Товар не найден !"  .
  else do:
     assign frame Dialog-Frame:title = "Товары >> виды алкогольной продукции - " + p-name + " , содержащие в названии " + s-name-cnt .
      OPEN QUERY BROWSE-2 FOR EACH ub.alc-type-gds       WHERE ub.alc-type-gds.alc-type-inner-code = p-alc-type-inner-code and             ub.alc-type-gds.create-user-db-num   = p-db-num NO-LOCK,       first ub.goods where       ub.goods.gds-code = ub.alc-type-gds.gds-code       NO-LOCK .
     end.
return no-apply.
end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse BROWSE-2 :handle
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
assign
   frame Dialog-Frame:title = "Товары >> " + p-name
.
def var sort-labelBROWSE-2   as character no-undo .
def var sort-clmnBROWSE-2    as handle    no-undo .
def var cur-clmnBROWSE-2     as handle    no-undo .
def var cur-clmn-locBROWSE-2 as integer   no-undo .
def var re-queryBROWSE-2     as logical   initial no no-undo .
on start-search, ctrl-o of BROWSE-2 in frame Dialog-Frame do:
   run sort-brBROWSE-2
     (input (if available alc-type-gds
             then recid(alc-type-gds)
             else ?
            )
     ).
end.
PROCEDURE sort-brBROWSE-2 :
  define input parameter p-recid as recid no-undo .
  if re-queryBROWSE-2 = no then do:
    assign
       cur-clmnBROWSE-2 = BROWSE-2:current-column in frame Dialog-Frame
    .
    if sort-clmnBROWSE-2 <> ? then sort-clmnBROWSE-2:column-fgcolor = 0.
    if cur-clmnBROWSE-2 = sort-clmnBROWSE-2 then do:
      assign
         sort-labelBROWSE-2 = ""
         sort-clmnBROWSE-2 = ?
      .
     end.
     else do:
       assign
         sort-labelBROWSE-2 = cur-clmnBROWSE-2:label
         sort-clmnBROWSE-2  = cur-clmnBROWSE-2
         sort-clmnBROWSE-2:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locBROWSE-2 = 1
  .
  def var column-handle as handle no-undo .
  column-handle = BROWSE-2:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnBROWSE-2 then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locBROWSE-2 = cur-clmn-locBROWSE-2 + 1
    .
  end.
  case sort-labelBROWSE-2:
        when ub.goods.artic:label in browse BROWSE-2 then DO:   assign     sort-column-name = "ub.goods.artic"   .   run OpenBr.   . END.
        when ub.goods.gds-name:label in browse BROWSE-2 then DO:   assign     sort-column-name = "ub.goods.gds-name"   .   run OpenBr.   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run OpenBr.
      if sort-labelBROWSE-2 <> "" then do:
        assign
          cur-clmnBROWSE-2:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locBROWSE-2 = ?
      .
    end.
  end case.
  if p-recid <> ? then do:
    reposition BROWSE-2 to recid p-recid no-error.
    apply "value-changed" to BROWSE-2 in frame Dialog-Frame.
  end.
  apply "entry" to BROWSE-2 in frame Dialog-Frame.
END PROCEDURE.
procedure re-open-query-srt-clmnBROWSE-2:
if cur-clmnBROWSE-2 = ? then do:
   run OpenBr.
end.
else do:
   assign re-queryBROWSE-2 = yes.
   run sort-brBROWSE-2
     (input (if available alc-type-gds
             then recid(alc-type-gds)
             else ?
            )
     ).
   assign re-queryBROWSE-2 = no.
end.
end.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F9 of frame Dialog-Frame anywhere do:
  if not available ub.goods then
    return no-apply.
  gds-rec = recid (ub.goods).
  run ref/gds-form.w ( input parParentProc
                      ,input 'ПРОСМОТР':U
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input-output gds-rec).
  apply "entry" to BROWSE-2 in frame Dialog-Frame.
  return no-apply.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   run enable_UI in this-procedure .
   run post_enable_UI in this-procedure .
   find first  buf_alc-type no-lock
        where  buf_alc-type.alc-type-inner-code = p-alc-type-inner-code
          and  buf_alc-type.create-user-db-num   = p-db-num
        no-error
        .
   if not available buf_alc-type  then return error .
   enable  s-code with frame Dialog-Frame.
   Hide      s-name  s-name-cnt s-artic in frame Dialog-Frame.
   display s-code with frame Dialog-Frame.
   WAIT-FOR GO OF FRAME Dialog-Frame.
END.
run disable_UI in this-procedure .
PROCEDURE cycle-add :
define variable v-num   as integer no-undo .
   define variable v-count as integer no-undo .
   define variable v-ok    as logical      no-undo.
   define variable v-first as logical      no-undo.
   define variable v-not-list    as character    no-undo.
   define variable v-flag as logical   no-undo init false .
   define buffer bb_alc-type-gds for ub.alc-type-gds .
   define buffer buf_goods       for ub.goods .
   run gbl/d-askw.w
      (input "Вопрос"
      ,input "Если товар уже прикреплен к виду алкоголя, пропускаем его?"
      ,input "|^"
      ,input "Не добавлять|Добавлять|Остановка"
      ,input "Не добавляем товар к новому виду алкоголя, товар остается со старым видом|"
         + "Добавляем товар к новому виду и открепляем от старого|"
         + "Остановить добавление товаров, если встречаются товары прикрепленные к другим видам алкоголя."
      ,input 1
      ,input 2
      ,output v-num
      ).
   assign
      v-first = TRUE
   .
    case v-num :
      when 1 then do :
          for each tt-gds-list no-lock  by tt-gds-list.nn :
            lns-cnt  =  lns-cnt + 1 .
            if lns-cnt > 1 then assign line-mode = "ЦИКЛ":U.
              v-flag = false .
              for each bb_alc-type-gds no-lock where
                       bb_alc-type-gds.gds-code = tt-gds-list.gds-code
              :
                v-flag = true.
                leave.
              end.
              if v-flag = false then do :
                find first bb_alc-type-gds no-lock
                     where bb_alc-type-gds.gds-code            = tt-gds-list.gds-code
                       and bb_alc-type-gds.alc-type-inner-code = p-alc-type-inner-code
                       and bb_alc-type-gds.create-user-db-num  = p-db-num no-error.
                if not available bb_alc-type-gds then do :
                  create bb_alc-type-gds.
                  assign
                      bb_alc-type-gds.gds-code            = tt-gds-list.gds-code
                      bb_alc-type-gds.alc-type-inner-code = p-alc-type-inner-code
                      bb_alc-type-gds.create-user-db-num  = p-db-num
                  .
                end.
              end.
          end.
      end.
      when 2 then do :
          for each tt-gds-list no-lock  by tt-gds-list.nn :
            lns-cnt  =  lns-cnt + 1 .
            if lns-cnt > 1 then assign line-mode = "ЦИКЛ":U.
              v-flag = false .
              for each bb_alc-type-gds exclusive-lock where
                       bb_alc-type-gds.gds-code = tt-gds-list.gds-code and
                       bb_alc-type-gds.alc-type-inner-code <> p-alc-type-inner-code
              :
                delete bb_alc-type-gds.
              end.
              find first bb_alc-type-gds no-lock
                    where bb_alc-type-gds.gds-code            = tt-gds-list.gds-code
                      and bb_alc-type-gds.alc-type-inner-code = p-alc-type-inner-code
                      and bb_alc-type-gds.create-user-db-num  = p-db-num no-error.
              if not available bb_alc-type-gds then do :
                create bb_alc-type-gds.
                assign
                    bb_alc-type-gds.gds-code            = tt-gds-list.gds-code
                    bb_alc-type-gds.alc-type-inner-code = p-alc-type-inner-code
                    bb_alc-type-gds.create-user-db-num  = p-db-num
                .
              end.
          end.
      end.
      when 3 then do :
          for each tt-gds-list no-lock  by tt-gds-list.nn :
            lns-cnt  =  lns-cnt + 1 .
            if lns-cnt > 1 then assign line-mode = "ЦИКЛ":U.
              v-flag = false .
              for each bb_alc-type-gds no-lock where
                        bb_alc-type-gds.gds-code = tt-gds-list.gds-code and
                        bb_alc-type-gds.alc-type-inner-code <> p-alc-type-inner-code
              :
                v-flag = true .
                leave.
              end.
            if v-flag = true then do :
              leave.
            end.
          end.
          if v-flag <> true then do :
            for each tt-gds-list no-lock  by tt-gds-list.nn :
              find first bb_alc-type-gds no-lock
                    where bb_alc-type-gds.gds-code            = tt-gds-list.gds-code
                      and bb_alc-type-gds.alc-type-inner-code = p-alc-type-inner-code
                      and bb_alc-type-gds.create-user-db-num  = p-db-num no-error.
              if not available bb_alc-type-gds then do :
                create bb_alc-type-gds.
                assign
                    bb_alc-type-gds.gds-code            = tt-gds-list.gds-code
                    bb_alc-type-gds.alc-type-inner-code = p-alc-type-inner-code
                    bb_alc-type-gds.create-user-db-num  = p-db-num
                .
              end.
            end.
          end.
      end.
    end case.
end procedure.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY r-sort s-artic s-name s-name-cnt s-code FILL-IN-2
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-add b-del b-help r-sort s-artic s-code BROWSE-2 FILL-IN-2 b-mark
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BROWSE-2 FOR EACH alc-type-gds       WHERE alc-type-gds.alc-type-inner-code = p-alc-type-inner-code  NO-LOCK,       EACH goods WHERE goods.gds-code = alc-type-gds.gds-code NO-LOCK     .
END PROCEDURE.
PROCEDURE OpenBr :
define variable t-ret as logical no-undo .
t-ret =  session:SET-WAIT-STATE("GENERAL") .
message
   "X"
   skip sort-column-name
view-as alert-box information.
case sort-column-name :
  when "ub.goods.artic" then do:
        assign frame Dialog-Frame:title = "Товары >> " + p-name.    OPEN QUERY BROWSE-2 FOR EACH alc-type-gds       WHERE alc-type-gds.alc-type-inner-code = p-alc-type-inner-code  NO-LOCK,       EACH goods WHERE goods.gds-code = alc-type-gds.gds-code NO-LOCK     by goods.artic.    .
  end.
  when "ub.goods.gds-name" then do:
        assign frame Dialog-Frame:title = "Товары >> " + p-name.    OPEN QUERY BROWSE-2 FOR EACH alc-type-gds       WHERE alc-type-gds.alc-type-inner-code = p-alc-type-inner-code  NO-LOCK,       EACH goods WHERE goods.gds-code = alc-type-gds.gds-code NO-LOCK     by goods.gds-name.    .
  end.
  otherwise do:
        assign frame Dialog-Frame:title = "Товары >> " + p-name.    OPEN QUERY BROWSE-2 FOR EACH alc-type-gds       WHERE alc-type-gds.alc-type-inner-code = p-alc-type-inner-code  NO-LOCK,       EACH goods WHERE goods.gds-code = alc-type-gds.gds-code NO-LOCK     .    .
  end.
end case.
t-ret =  session:SET-WAIT-STATE("") .
apply "HOME" to BROWSE-2 in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE post_enable_UI :
   if v-cntxt-db-num <> 0 then do:
      disable
            b-add b-del
      WITH FRAME Dialog-Frame.
   end.
END PROCEDURE.
PROCEDURE proc-b-list :
END PROCEDURE.
