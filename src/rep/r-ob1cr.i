/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

создание дин.об для отчета оборотка по всем

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 09/17/01
*/
&if "{1}" = "def" &then
def {4} var ed{2} as handle .
def {4}  var s{2} as handle .
def {4}  var sf{2} as handle .
def {4}  var l-{2} as handle .
def {4}  var ll-{2} as handle .

&endif
&if "{1}" = "cr2" &then
if l-col-pos + l-col-len > 320 Then DO:
  Assign
    /*l-col-pos = 315
    l-col-len = 5*/
    l-col-pos = 316
    l-col-len = 14
    .
End.
  if use-column[{2}] = true then DO:
  /*line 1 */
        CREATE EDITOR LL-{2} IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
    /*label */
        CREATE EDITOR ed{2} IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
     /* line-2 */
        CREATE EDITOR L-{2} IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4
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
            COLUMN = l-col-pos
        .

      /*палки в шапке*/
        CREATE EDITOR s{2} IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
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
        l-col-pos =  l-col-pos + l-col-len + 1.
   End.
&endif


&if "{1}" = "cr" &then
def {4}  var ed{2} as handle .
def {4}  var s{2} as handle .
def {4}  var sf{2} as handle .
def {4}  var l-{2} as handle .
def {4}  var ll-{2} as handle .
if l-col-pos + l-col-len > 320 Then DO:
  Assign
    l-col-pos = 315
    l-col-len = 5
    .
End.
  if use-column[{2}] = true then DO:
  /*line 1 */
        CREATE EDITOR LL-{2} IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
    /*label */
        CREATE EDITOR ed{2} IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
     /* line-2 */
        CREATE EDITOR L-{2} IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4
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
            COLUMN = l-col-pos
        .

      /*палки в шапке*/
        CREATE EDITOR s{2} IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
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
        l-col-pos =  l-col-pos + l-col-len + 1.
   End.
&endif
/* $Workfile$ e n d */