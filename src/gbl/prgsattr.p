block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: prgsattr.p $
$Archive: gbl/prgsattr.p $

Процедура возвращает тип атрибутов WIDGET - справедливо для Progress 8.3B

Автор: Перваков Михаил Сергеевич
Дата создания: 03/18/02
Author: Mikhail Pervakov
Creation date: 03/18/02

Разработана на основе сообщени
http://forums.progresstalk.com/showthread.php?s=&threadid=30308

*/

define input  parameter p-attribute-name as character no-undo .
define output parameter p-attribute-type as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: prgsattr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/prgsattr.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }


/* для этого фрагмента текста нельзя делать отступ */
/* если его сделать, то программа перестанет работать */
define variable v-widget-handle-list as character no-undo
initial
"BACKGROUND~
,CURRENT-COLUMN~
,CURRENT-ITERATION~
,FIRST-CHILD~
,FIRST-COLUMN~
,FIRST-PROCEDURE~
,FIRST-SERVER~
,FRAME~
,HANDLE~
,LAST-CHILD~
,LAST-PROCEDURE~
,LAST-SERVER~
,MENU-BAR~
,NEXT-COLUMN~
,NEXT-SIBLING~
,NEXT-TAB-ITEM~
,OWNER~
,PARENT~
,POPUP-MENU~
,PREV-COLUMN~
,PREV-SIBLING~
,PREV-TAB-ITEM~
,SIDE-LABEL-HANDLE~
,WINDOW~
" .


define variable v-logical-list as character no-undo
initial
"APPL-ALERT-BOXES~
,ATTR-SPACE~
,AUTO-END-KEY~
,AUTO-ENDKEY~
,AUTO-GO~
,AUTO-INDENT~
,AUTO-RESIZE~
,AUTO-RETURN~
,AUTO-ZAP~
,BATCH-MODE~
,BLANK~
,BLOCK-ITERATION-DISPLA~
,BOX~
,BOX-SELECTABLE~
,CENTERED~
,CHECKED~
,COLUMN-SCROLLING~
,CONVERT-3D-COLORS~
,CURRENT-ROW-MODIFIED~
,DATA-ENTRY-RETURN~
,DEBLANK~
,DEFAULT~
,DRAG-ENABLED~
,DYNAMIC~
,EMPTY~
,EXPAND~
,FILLED~
,FOREGROUND~
,GRAPHIC-EDGE~
,GRID-SNAP~
,GRID-VISIBLE~
,HIDDEN~
,HORIZONTAL~
,IMMEDIATE-DISPLAY~
,KEEP-FRAME-Z-ORDER~
,LABELS~
,LARGE~
,LARGE-TO-SMALL~
,MANUAL-HIGHLIGHT~
,MESSAGE-AREA~
,MODIFIED~
,MOVABLE~
,MULTIPLE~
,NEW-ROW~
,NO-CURRENT-VALUE~
,NO-FOCUS~
,OVERLAY~
,PAGE-BOTTOM~
,PAGE-TOP~
,POPUP-ONLY~
,PROGRESS-SOURCE~
,READ-ONLY~
,REFRESHABLE~
,RESIZABLE~
,RESIZE~
,RETURN-INSERTED~
,ROW-MARKERS~
,SCROLL-BARS~
,SCROLLABLE~
,SCROLLBAR-HORIZONTAL~
,SCROLLBAR-VERTICAL~
,SELECTABLE~
,SELECTED~
,SENSITIVE~
,SEPARATORS~
,SIDE-LABELS~
,SORT~
,STATUS-AREA~
,SUPPRESS-WARNINGS~
,SYSTEM-ALERT-BOXES~
,TEXT-SELECTED~
,THREE-D~
,TOOLTIPS~
,TOP-ONLY~
,V6DISPLAY~
,VISIBLE~
,WORD-WRAP~
" .

define variable v-integer-list as character no-undo
initial
"BGCOLOR~
,BORDER-BOTTOM-PIXELS~
,BORDER-LEFT-PIXELS~
,BORDER-RIGHT-PIXELS~
,BORDER-TOP-PIXELS~
,BUFFER-CHARS~
,BUFFER-LINES~
,COLUMN-BGCOLOR~
,COLUMN-DCOLOR~
,COLUMN-FGCOLOR~
,COLUMN-FONT~
,COLUMN-PFCOLOR~
,CURSOR-CHAR~
,CURSOR-LINE~
,CURSOR-OFFSET~
,DCOLOR~
,DDE-ERROR~
,DDE-ID~
,DOWN~
,EDGE-PIXELS~
,FGCOLOR~
,FOCUSED-ROW~
,FONT~
,FRAME-SPACING~
,FRAME-X~
,FRAME-Y~
,FREQUENCY~
,FULL-HEIGHT-PIXELS~
,FULL-WIDTH-PIXELS~
,GRID-FACTOR-HORIZONTAL~
,GRID-FACTOR-VERTICAL~
,GRID-UNIT-HEIGHT-PIXEL~
,GRID-UNIT-WIDTH-PIXELS~
,HEIGHT-PIXELS~
,HWND~
,INDEX~
,INNER-CHARS~
,INNER-LINES~
,LABEL-BGCOLOR~
,LABEL-DCOLOR~
,LABEL-FGCOLOR~
,LABEL-FONT~
,LENGTH~
,LINE~
,MAX-CHARS~
,MAX-DATA-GUESS~
,MAX-HEIGHT-PIXELS~
,MAX-VALUE~
,MAX-WIDTH-PIXELS~
,MENU-MOUSE~
,MESSAGE-AREA-FONT~
,MIN-HEIGHT-PIXELS~
,MIN-VALUE~
,MIN-WIDTH-PIXELS~
,MULTITASKING-INTERVAL~
,NUM-BUTTONS~
,NUM-COLUMNS~
,NUM-ITEMS~
,NUM-ITERATIONS~
,NUM-LINES~
,NUM-LOCKED-COLUMNS~
,NUM-SELECTED-ROWS~
,NUM-SELECTED-WIDGETS~
,NUM-TABS~
,NUM-TO-RETAIN~
,PFCOLOR~
,PIXELS-PER-COLUMN~
,PIXELS-PER-ROW~
,PRINTER-CONTROL-HANDLE~
,SELECTION-END~
,SELECTION-START~
,STATUS-AREA-FONT~
,TAB-POSITION~
,TITLE-BGCOLOR~
,TITLE-DCOLOR~
,TITLE-FGCOLOR~
,TITLE-FONT~
,VIRTUAL-HEIGHT-PIXELS~
,VIRTUAL-WIDTH-PIXELS~
,WIDTH-PIXELS~
,WINDOW-STATE~
,X~
,Y~
,YEAR-OFFSET~
" .

define variable v-decimal-list as character no-undo
initial
"BORDER-BOTTOM-CHARS~
,BORDER-LEFT-CHARS~
,BORDER-RIGHT-CHARS~
,BORDER-TOP-CHARS~
,COLUMN~
,EDGE-CHARS~
,FRAME-COL~
,FRAME-ROW~
,FULL-HEIGHT-CHARS~
,FULL-WIDTH-CHARS~
,GRID-UNIT-HEIGHT-CHARS~
,GRID-UNIT-WIDTH-CHARS~
,HEIGHT-CHARS~
,MAX-HEIGHT-CHARS~
,MAX-WIDTH-CHARS~
,MIN-HEIGHT-CHARS~
,MIN-WIDTH-CHARS~
,ROW~
,SCREEN-LINES~
,VIRTUAL-HEIGHT-CHARS~
,VIRTUAL-WIDTH-CHARS~
,WIDTH-CHARS~
" .

define variable v-com-handle-list as character no-undo
initial
"COM-HANDLE~
" .

define variable v-character-list as character no-undo
initial
"ACCELERATOR~
,CHARSET~
,CPCASE~
,CPCOLL~
,CPINTERNAL~
,CPLOG~
,CPPRINT~
,CPRCODEIN~
,CPRCODEOUT~
,CPSTREAM~
,CPTERM~
,DATA-TYPE~
,DATE-FORMAT~
,DBNAME~
,DDE-ITEM~
,DDE-NAME~
,DDE-TOPIC~
,DELIMITER~
,DISPLAY-TYPE~
,FORMAT~
,FRAME-NAME~
,HELP~
,LABEL~
,LIST-ITEMS~
,MENU-KEY~
,NAME~
,NUMERIC-FORMAT~
,PARAMETER~
,PRINTER-NAME~
,PRINTER-PORT~
,PRIVATE-DATA~
,RADIO-BUTTONS~
,SCREEN-VALUE~
,SELECTION-TEXT~
,STREAM~
,SUBTYPE~
,TABLE~
,TEMP-DIRECTORY~
,TIC-MARKS~
,TIME-SOURCE~
,TITLE~
,TOOLTIP~
,TYPE~
,WINDOW-SYSTEM~
" .


do
on error undo, return error return-value
:


  define variable v-attrib-name as character no-undo .
  assign
    v-attrib-name = keyword-all(p-attribute-name)
  .

  if  v-attrib-name <> ?
  and v-attrib-name <> "" then do:
    if lookup(v-attrib-name, v-widget-handle-list) > 0 then do:
      assign
        p-attribute-type = {&type-widget-handle}
      .
    end.
    if lookup(v-attrib-name, v-com-handle-list) > 0 then do:
      assign
        p-attribute-type = {&type-com-handle}
      .
    end.
    if lookup(v-attrib-name, v-logical-list) > 0 then do:
      assign
        p-attribute-type = {&type-log}
      .
    end.
    if lookup(v-attrib-name, v-integer-list) > 0 then do:
      assign
        p-attribute-type = {&type-int}
      .
    end.
    if lookup(v-attrib-name, v-decimal-list) > 0 then do:
      assign
        p-attribute-type = {&type-dec}
      .
    end.
    if lookup(v-attrib-name, v-character-list) > 0 then do:
      assign
        p-attribute-type = {&type-char}
      .
    end.
  end.
end.