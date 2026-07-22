/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Cоздание и высвечивание динамических колонок для обороток

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

*/
/*-----------------------------------------------------------------------------------------------------------------------*/
&if "{1}" = "def" &then
def  var l-col-type         as character no-undo .
def  var l-col-pos          as integer no-undo .
def  var l-row-pos           as integer no-undo init 1.
def  var l-col-len          as integer no-undo .
def  var l-col-format       as character no-undo .
def  var l-col-lable        as character no-undo .

DEFINE VARIABLE t-1 AS CHARACTER INITIAL "||||"
     VIEW-AS EDITOR
     SIZE 1 BY &if "{2}" = "" &then 4 &else {2} &endif NO-UNDO.

DEFINE FRAME top-frame
    t-1       AT ROW 1 COL 1 no-label
    HEADER
        cur-time-print() AT 5 format "X(35)"
        "Цены указаны в" (if tPrintRubl then "{&abbr_rub_allshift}" else x-base-type )
        string( "Страница " + string( PAGE-NUMBER( OutStream ), ">>>>>>9") ) AT 110 format "X(16)" SKIP
     WITH {&l-frame} DOWN stream-io
         NO-UNDERLINE use-text NO-BOX no-label
         AT COL 1 ROW 1
         SIZE {&l-frame} BY 35  .

DEFINE FRAME zapas
   with width {&l-frame} down stream-io use-text NO-BOX no-label.
&endif
&if "{1}" = "cr" &then
/*-----------------------------------------------------------------------------------------------------------------------*/
  def var ed{2} as handle .
  def var s{2} as handle .
  def var sf{2} as handle .
  def var l-{2} as handle .
  def var ll-{2} as handle .
  if l-row-pos = 0 then l-row-pos = 1.
  if use-column[{2}] = true then DO:
  /*line 1 */
        CREATE EDITOR LL-{2} IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
    /*label */
        CREATE EDITOR ed{2} IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW =  l-row-pos + 1
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
     /* line-2 */
        CREATE EDITOR L-{2} IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos + 3
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
    /*Значение*/
        CREATE FILL-IN C-{3} IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            DATA-TYPE = l-col-type
            FORMAT = l-col-format
            ROW = 1
            WIDTH-CHARS = l-col-len
            COLUMN = l-col-pos
        .

      /*палки в шапке*/
         if  (l-col-pos + l-col-len) <= 320 THEN DO:
        CREATE EDITOR s{2} IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = (l-col-pos + l-col-len)
            screen-value = "::::"
            WIDTH-CHARS = 1
            HEIGHT-CHARS = 5
        .
        /*палки в колонках*/
        CREATE EDITOR sf{2} IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            ROW = 1
            Screen-value = ":"
            WIDTH-CHARS = 1
            COLUMN = l-col-pos + l-col-len
         .
           End.
        l-col-pos =  l-col-pos + l-col-len + 1.
   End .
&endif
&if "{1}" = "disp" &then
/*-----------------------------------------------------------------------------------------------------------------------*/
  if c-{3} <>  ?  then do :
    c-{3}:screen-value = string({2}) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
&endif
&if "{1}" = "full" &then
/*-----------------------------------------------------------------------------------------------------------------------*/
if c-{3} <>  ?  then do :
Assign
    l1{3}  = c-{3}:DATA-TYPE
    l2{3}  = c-{3}:FORMAT
    c-{3}:DATA-TYPE = "CHARACTER"
    c-{3}:FORMAT    = "x(" + string(C-{3}:WIDTH-CHARS) + ")"
    c-{3}:screen-value = string({2})  .
End.
&endif
&if "{1}" = "sfull" &then
/*-----------------------------------------------------------------------------------------------------------------------*/
if c-{2} <>  ?  then do :
Assign
    c-{2}:DATA-TYPE = l1{2}
    c-{2}:FORMAT    = l2{2}.
End.
&endif
&if "{1}" = "cr2" &then
/*-----------------------------------------------------------------------------------------------------------------------*/
  def var ed{2} as handle .
  def var s{2} as handle .
  def var ll-{2} as handle .
  if l-col-len > 0 then DO:
  /*line 1 */
        CREATE EDITOR LL-{2} IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME {3}:HANDLE
            ROW = l-row-pos
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
    /*label */
        CREATE EDITOR ed{2} IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME {3}:HANDLE
            ROW = l-row-pos + 1
            COLUMN = l-col-pos
            screen-value = fill(" ",Integer((l-col-len - LENGTH(trim(l-col-lable))) / 2))  + l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .

      /*палки в шапке*/
         if  (l-col-pos + l-col-len) <= 320 THEN DO:
        CREATE EDITOR s{2} IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME {3}:HANDLE
            ROW = l-row-pos
            COLUMN = (l-col-pos + l-col-len)
            screen-value = "::"
            WIDTH-CHARS = 1
            HEIGHT-CHARS = 3
        .
           End.
        l-col-pos =  l-col-pos + l-col-len + 1.
   End.
&endif

/* $Workfile$ e n d */