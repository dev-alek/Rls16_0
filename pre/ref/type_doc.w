DEFINE TEMP-TABLE tt-typeDoc NO-UNDO
  field type-code as character
  field typeName  as character.
define temp-table  tt-dateZakaz     no-undo
field id as integer
field dateStart as date
field dateEnd as date
index pi id
    .
DEFINE TEMP-TABLE tt-typeDocChoose NO-UNDO
  field type-code as character
  field typeName  as character.
define temp-table gds-list like ub.goods
  field minZapas as decimal
  field contract as character
  field contract-code as integer
  field price as decimal
  field doc-qnty as decimal
  index pi contract gds-code.
 define temp-table choose-gds-list like ub.goods
  field minZapas as decimal
  field contract as character
  field contract-code as integer
  field price as decimal
  field doc-qnty as decimal
  index pi contract gds-code.
  define temp-table tt-gds-list like ub.goods
  field contract-code as integer
  field price as decimal
  field doc-qnty as decimal
  index pi gds-code.
define input  parameter parParentProc  as widget-handle no-undo.
define input-output  PARAMETER TABLE FOR tt-typeDocChoose.
define variable vss-revision    as character no-undo init "$Revision: 998b6172f4a6, 2542, test $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Вт авг 04 12:57:22 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: collec.w $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/collec.w $":U .
define variable vss-description as character no-undo init "Справочник типов документов".
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
define variable rid-list              as character no-undo.
define variable row_type              as rowid     no-undo .
define variable ii                    as integer   no-undo .
define variable doc-ext-doc-type-list as character no-undo .
DEFINE BUTTON b-exit AUTO-GO
  LABEL "&Выход ":L
  SIZE 12 BY 1.
DEFINE BUTTON B-mark
  LABEL "&*"
  SIZE 3 BY 1.
DEFINE BUTTON b-sel AUTO-GO
  LABEL "Вы&бор ":L
  SIZE 10 BY 1.
DEFINE QUERY br-coll FOR
  tt-typeDoc SCROLLING.
DEFINE BROWSE br-coll
  QUERY br-coll NO-LOCK DISPLAY
      (IF ( CAN-DO (rid-list, string( recid( tt-typeDoc ) ) ) ) THEN ("*") ELSE (" ")) COLUMN-LABEL "*" FORMAT "X(1)":U
      tt-typeDoc.typeName column-label "Наименование" FORMAT "X(30)":U WIDTH 50
    WITH SEPARATORS SIZE 54.5 BY 19.46
         BGCOLOR 15 FGCOLOR 0 .
DEFINE FRAME d-type-tmp
  b-exit AT ROW 1 COL 1
  B-mark AT ROW 1 COL 13
  b-sel AT ROW 1 COL 16.5
  br-coll AT ROW 2.25 COL 1.5
  SPACE(0.37) SKIP(0.28)
  WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
  SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
  TITLE "Типы документов":L.
ASSIGN
  FRAME d-type-tmp:SCROLLABLE = FALSE.
ON CHOOSE OF B-mark IN FRAME d-type-tmp
  DO:
    define variable loc#log as logical no-undo .
    if available tt-typeDoc then
    do:
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid1 as character no-undo .
define variable v-num-entry1 as integer   no-undo .
assign
  v-str-recid1 = trim( string( recid( tt-typeDoc ) , "->>>>>>>>>>>9":U ) )
  v-num-entry1 = lookup( v-str-recid1 , rid-list )
.
if v-num-entry1 > 0 then do:
  assign
    entry( v-num-entry1, rid-list ) = "":U
    rid-list = trim( replace( rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    rid-list = rid-list + ( if rid-list = "":U then "":U else chr(44) ) + v-str-recid1
  .
end.
      row_type = rowid(tt-typeDoc).
      loc#log = br-coll:refresh() .
      reposition br-coll to rowid row_type.
      if last-event:function <> "MOUSE-SELECT-DBLCLICK" then
      do:
        loc#log = br-coll:select-next-row ().
        apply "VALUE-CHANGED" to br-coll in frame d-type-tmp.
      end.
    end.
    apply "entry" to br-coll in frame d-type-tmp.
  END.
ON CHOOSE OF b-sel IN FRAME d-type-tmp
  DO:
    empty temp-table tt-typeDocChoose .
      do ii = 1 to num-entries (rid-list):
        find first tt-typeDoc where recid(tt-typeDoc) = integer(entry(ii,rid-list)) no-error .
        if available (tt-typeDoc) then
        do:
          create tt-typeDocChoose .
          buffer-copy tt-typeDoc to tt-typeDocChoose .
        end.
      end.
    find first tt-typeDocChoose no-error .
    if not available (tt-typeDocChoose) then do:
      message "Не задан тип документа для анализа, расчет невозможен"
      view-as alert-box.
      return no-apply .
    end.
  END.
ON MOUSE-SELECT-DBLCLICK OF br-coll IN FRAME d-type-tmp
  DO:
    apply "choose" to b-sel in frame d-type-tmp .
    return no-apply .
  END.
ON RETURN OF br-coll IN FRAME d-type-tmp
  DO:
    apply "choose" to b-sel in frame d-type-tmp .
    return no-apply .
  END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME d-type-tmp:PARENT eq ?
  THEN FRAME d-type-tmp:PARENT = ACTIVE-WINDOW.
ON WINDOW-CLOSE OF FRAME d-type-tmp
  APPLY "END-ERROR":U TO SELF.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  doc-ext-doc-type-list = 'es':U + chr(47) + "расход внешний касса" + chr(44) +
    'rs':U + chr(47) + "возврат внешний касса" + chr(44) +
    'wm':U + chr(47) + "расход производство" + chr(44) +
    'we':U + chr(47) + 'списание':U + chr(44) +
    'ee':U + chr(47) + 'расход внешний':U + chr(44) +
    're':U + chr(47) + 'возврат внешний':U + chr(44) +
    'rv':U + chr(47) + 'возврат внутренний':U + chr(44) +
    'ev':U + chr(47) + 'расход внутренний':U .
  define variable doc-type as character no-undo .
  do ii = 1 to num-entries (doc-ext-doc-type-list,chr(44)):
    doc-type = entry (ii,doc-ext-doc-type-list,chr(44)) .
    create tt-typeDoc .
    assign
      tt-typeDoc.type-code = entry (1,doc-type,chr(47))
      tt-typeDoc.typeName  = entry (2,doc-type,chr(47))
      .
  end.
  define variable loc#log as logical no-undo .
  for each tt-typeDocChoose:
    find first tt-typeDoc where tt-typeDoc.type-code = tt-typeDocChoose.type-code no-error .
    if available tt-typeDoc then
    do:
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid3 as character no-undo .
define variable v-num-entry3 as integer   no-undo .
assign
  v-str-recid3 = trim( string( recid( tt-typeDoc ) , "->>>>>>>>>>>9":U ) )
  v-num-entry3 = lookup( v-str-recid3 , rid-list )
.
if v-num-entry3 > 0 then do:
  assign
    entry( v-num-entry3, rid-list ) = "":U
    rid-list = trim( replace( rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    rid-list = rid-list + ( if rid-list = "":U then "":U else chr(44) ) + v-str-recid3
  .
end.
    end.
    apply "entry" to br-coll in frame d-type-tmp.
  end.
  run enable_ui.
  APPLY "VALUE-CHANGED":U TO br-coll in frame d-type-tmp.
  WAIT-FOR GO OF FRAME d-type-tmp.
END.
run disable_ui.
PROCEDURE disable_UI :
  HIDE FRAME d-type-tmp.
END PROCEDURE.
PROCEDURE enable_UI :
  ENABLE
    br-coll
    b-exit
    b-sel
    b-mark
    WITH FRAME  d-type-tmp.
  OPEN QUERY br-coll FOR EACH tt-typeDoc NO-LOCK.
END PROCEDURE.
FUNCTION mon-name RETURNS CHARACTER
  (input n-mon as int) :
  define variable name-mon as char no-undo.
  run gbl/monthnam.p ( input n-mon, output name-mon ) .
  RETURN name-mon.
END FUNCTION.
