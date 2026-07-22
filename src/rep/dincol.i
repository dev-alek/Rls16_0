/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

создание и высвечивание динамических колонок

Автор: Чернова Светлана Александровна
Дата создания: 04/12/06
Author: Svetlana Chernova
Creation date: 04/12/06



*/

&if "{1}" = "def" &then

define variable l-col-type         as character no-undo .
define variable l-col-pos          as integer no-undo .
define variable l-col-len          as integer no-undo .
define variable l-col-format       as character no-undo .
define variable l-col-lable        as character no-undo .
define variable v-dec-sep          as character no-undo init ? .
define variable v-th-sep           as character no-undo init ? .
define variable v-r-col-num        as integer no-undo .
define variable v-reg-replace      as logical no-undo .
define variable v-date-col-format  as character no-undo .

DEFINE VARIABLE last-col-num as integer no-undo.

run gbl/getlocal.p (
                  output v-dec-sep
                 ,output v-th-sep
                 ,output v-sdate
                 ,output v-shortdate
                 ) no-error .
assign
v-reg-replace = NOT (v-dec-sep = ".":U and v-th-sep = {&comma-char})
                AND (v-dec-sep <> ? and v-th-sep <> ?)
.


  FUNCTION supress-null RETURNS CHARACTER ( INPUT p-string  AS CHARACTER,
                                            INPUT p-dec-sep AS CHARACTER  ) :
    DEFINE VARIABLE v-string AS CHARACTER NO-UNDO.

    IF TRIM( p-string ) = "0"                    OR
       TRIM( p-string ) = "0" + p-dec-sep + "00" OR
       TRIM( p-string ) =       p-dec-sep + "00" OR
       TRIM( p-string ) =       p-dec-sep + "0"  OR
       TRIM( p-string ) = "0" + p-dec-sep + "0"  THEN DO: ASSIGN v-string = "":U.     END.
                                                 ELSE DO: ASSIGN v-string = p-string. END.
    RETURN ( TRIM( v-string ) ).
  END FUNCTION. /* supress-null */

FUNCTION reg-output returns character( input p-string as character
                                      ,input p-private-data as character
                                      ,input p-replace as logical
                                      ,input p-supress as logical
                                      ,input p-dec-sep as character
                                      ,input p-th-sep as character
                                      ):

DEFINE VARIABLE v-reg-output as character no-undo .
DEFINE VARIABLE v-data-type as character no-undo .
DEFINE VARIABLE v-progress-format as character no-undo .
assign
v-progress-format = entry(1, p-private-data, {&delim-par})
v-data-type = entry(2, p-private-data, {&delim-par})
.
if p-string = ? then return {&question-mark}.
if (v-data-type = "INTEGER"
    OR v-data-type = "DECIMAL" ) THEN DO:
  IF p-replace THEN DO:
    assign
      v-reg-output = replace( p-string
                                      ,{&comma-char}
                                      ,"":U
                                    )
      v-reg-output = trim(v-reg-output)
    .
  END.
  else do:
    v-reg-output = p-string.
  end.
  IF p-supress THEN DO: ASSIGN v-reg-output = supress-null( TRIM( v-reg-output ), p-dec-sep ). END.
  return v-reg-output.
end.
  return p-string.

END FUNCTION.


&endif

&if "{1}" = "cr" &then
  define variable ed{2}{5} as handle no-undo.
  define variable l-{2}{5} as handle no-undo.
  define variable ll-{2}{5} as handle no-undo.
  define variable c-{3}{5} as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[{2}] = true then DO:
  /*line 1 */
        CREATE EDITOR LL-{2}{5} IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame{5}:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
    &if defined(din-label-height) &then
            HEIGHT-CHARS = {&din-label-height}
    &else
            HEIGHT-CHARS = 3
    &endif
        .
    /*label */
        CREATE EDITOR ed{2}{5} IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame{5}:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
    &if defined(din-label-height) &then
            HEIGHT-CHARS = {&din-label-height}
    &else
            HEIGHT-CHARS = 3
    &endif

        .
     /* line-2 */
        CREATE EDITOR L-{2}{5} IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame{5}:HANDLE
    &if defined(din-label-height) &then
            ROW = {&din-label-height} + 1
    &else
            ROW = 4
    &endif
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
    &if defined(din-label-height) &then
            HEIGHT-CHARS = {&din-label-height}
    &else
            HEIGHT-CHARS = 3
    &endif

        .
    /*Значение*/
        CREATE FILL-IN C-{3}{5} IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME {4}:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + {&delim-par} + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
&endif

&if "{1}" = "crx" &then
if use-column[{2}] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + {&comma-char} + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + {&comma-char} + string(l-col-len))
                )
last-col-num = {2}
entry(1, sheetf.colformat, {&delim-par}) = entry(1, sheetf.colformat, {&delim-par}) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, {&delim-par}) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, {&delim-par}) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
&endif

&if "{1}" = "di" &then
  if use-column[{2}]
  then  C-{3}{5}:screen-value = string({4}, entry(1, c-{3}{5}:private-data, {&delim-par})).
&endif

&if "{1}" = "dif" &then
  if use-column[{2}]
  then  C-{3}{5}:screen-value = string({4}, {6}).
&endif

&if "{1}" = "dix" &then
  /*в Excel*/
  if use-column[{2}]
  then (reg-output(
                    string({4}, entry(1, c-{3}{5}:private-data, {&delim-par}))
                   ,c-{3}{5}:private-data
                   ,v-reg-replace
&if "{6}" = "" &then
                   ,no
&else
                   ,{6}
&endif
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if {2} < last-col-num
         then {&tabulation}
         else ""))
  else "":U
&endif

&if "{1}" = "dixf" &then
  /*в Excel*/
  if use-column[{2}]
  then (reg-output(
                    {4}
                   ,c-{3}{5}:private-data
                   ,v-reg-replace
&if "{6}" = "" &then
                   ,no
&else
                   ,{6}
&endif
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if {2} < last-col-num
         then {&tabulation}
         else ""))
  else "":U
&endif



&if "{1}" = "un" &then
  if use-column[{2}]
  then  C-{3}{5}:screen-value = string({4}).
&endif

&if "{1}" = "unx" &then
  /*в Excel*/
  if use-column[{2}]
  then (string({4}) + (if {2} < last-col-num then {&tabulation} else ""))
  else ""
&endif

&if "{1}" = "dit" &then
  if use-column[{2}]
  then (if {2} < last-col-num then {&tabulation} else "")
  else ""
&endif

&if "{1}" = "dil" &then
  IF (line-counter({2})  modulo page-size({2})= 0) AND
     (line-counter({2}) >= page-size({2})) then DO:
      display STREAM {2}    with frame {3} .
  End.
&endif


/* $Workfile$   E n d */