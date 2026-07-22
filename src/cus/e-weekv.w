&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS F-Frame-Win
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Понедельный отчет по выручке

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/10/05
Author: Bakhtadze Natalya
Creation date: 10/10/05

*/

/* Create an unnamed pool to store all the widgets created
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Понедельный отчет по товарам (реализация)".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ cmp/r-page1.i  }
{ gbl/prn-lib.i }
{ cmp/operlist.i }
{ gbl/waitfram.i }
{ cmp/showinf.i }
define variable g#report-num as integer no-undo .

&global-define  no-benefits    "Не было никаких закрытых продаж на выбранных объектах ~
в течение заданного Вами периода времени."

define variable my-x-date-start as date no-undo.
define variable my-x-date-end as date no-undo.
define variable State-source as Widget-Handle.

&scop weekday-names  "Воскресенье,Понедельник,Вторник,Среда,Четверг,Пятница,Суббота"
&scop weekday-names-short  "вс,пн,вт,ср,чт,пн,сб"

define temp-table temp-sum no-undo
FIELD obj-type like ub.clients.obj-type
FIELD obj-code like ub.clients.obj-code
FIELD doc-date like ub.inkas.doc-date
FIELD tot-sum like ub.inkas.netto
FIELD tot-chk like ub.inkas.num-chk
index pi is UNIQUE PRIMARY
obj-type
obj-code
doc-date
.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER FRAME

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-1 RS_wdays
&Scoped-Define DISPLAYED-OBJECTS RS_wdays

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-weekday-name F-Frame-Win
FUNCTION get-weekday-name RETURNS CHARACTER
  ( input p-weekday as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-weekday-name-short F-Frame-Win
FUNCTION get-weekday-name-short RETURNS CHARACTER
  ( input p-weekday as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE RS_wdays AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Item 2", 2,
"Item 3", 3,
"Item 4", 4,
"Item 5", 5,
"Item 6", 6,
"Item 7", 7,
"Item 1", 1
     SIZE 24.88 BY 6.92 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 29.13 BY 8.88.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     RS_wdays AT ROW 3.21 COL 3.88 NO-LABEL
     "Начало отчетной недели" VIEW-AS TEXT
          SIZE 23.38 BY .71 AT ROW 2.13 COL 4
          FGCOLOR 4
     RECT-1 AT ROW 1.92 COL 2
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 32.25 BY 11.88.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartObject
   Allow: Basic,Browse,DB-Fields,Smart,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB)
  CREATE WINDOW F-Frame-Win ASSIGN
         HEIGHT             = 11.92
         WIDTH              = 32.13.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB F-Frame-Win
/* ************************* Included-Libraries *********************** */

{src/adm/method/containr.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW F-Frame-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE                                                          */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = ""
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME RS_wdays
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS_wdays F-Frame-Win
ON LEAVE OF RS_wdays IN FRAME F-Main
DO:
  assign
    RS_wdays
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK F-Frame-Win


/* ***************************  Main Block  *************************** */
{ gbl/personly.i }
&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
   /* Now enable the interface  if in test mode - otherwise this happens when
      the object is explicitly initialized from its container. */
   RUN dispatch IN THIS-PROCEDURE ('initialize':U).
&ENDIF

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects F-Frame-Win  _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available F-Frame-Win  _ADM-ROW-AVAILABLE
PROCEDURE adm-row-available :
/*------------------------------------------------------------------------------
  Purpose:     Dispatched to this procedure when the Record-
               Source has a new row available.  This procedure
               tries to get the new row (or foriegn keys) from
               the Record-Source and process it.
  Parameters:  <none>
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.             */
  {src/adm/template/row-head.i}

  /* Process the newly available records (i.e. display fields,
     open queries, and/or pass records on to any RECORD-TARGETS).    */
  {src/adm/template/row-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-dates F-Frame-Win
PROCEDURE check-dates :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT-OUTPUT PARAMETER p-Date-Start as date no-undo.
DEFINE INPUT-OUTPUT PARAMETER p-Date-END as date no-undo.
define input parameter p-week-start as integer no-undo .
DEFINE INPUT PARAMETER loud as logical no-undo.
define variable new-X-date-start as date no-undo.
define variable new-X-date-end as date no-undo.
define variable new1-X-date-start as date no-undo.
define variable new1-X-date-end as date no-undo.
define variable new2-X-date-start as date no-undo.
define variable new2-X-date-end as date no-undo.
DEFINE VARIABLE v-week-end as integer no-undo .
define variable jj as integer no-undo.
define variable loud1 as logical no-undo.
define variable loud2 as logical no-undo.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .

run cur-time in this-procedure(output v-today, output v-time).

assign
v-week-end = (if p-week-start = 1
              then 7
              else (p-week-start - 1)
              )
.

 if p-date-start < 01/01/1990 then do:
  message
  "Вы выбрали слишком большой период времени" skip
  "уменьшаем"
  view-as alert-box WARNING.
  assign
  p-date-start = 01/01/1990
  .
 end.

IF weekday(p-date-start)  <> p-week-start then do:
    assign loud1 = yes.
    do jj = 1 to  7:
        assign
        new1-x-date-start = p-date-start - jj
        .
        if weekday(new1-x-date-start) = p-week-start then do:
            LEAVE.
        end.
    end.
    do jj = 1 to  7:
        assign
        new2-x-date-start = p-date-start + jj
        .
        if weekday(new2-x-date-start) = p-week-start then do:
            LEAVE.
        end.
    end.
end.
else do:
  assign
  new1-x-date-start = p-date-start
  new2-x-date-start = p-date-start
  new-x-date-start = p-date-start
  .
end.
IF weekday(p-date-end)  <> v-week-end then do:
    assign loud2 = yes.

    do jj = 1 to  7:
        assign
        new1-x-date-end = p-date-end + jj
        .
        if weekday(new1-x-date-end) = v-week-end then do:
            LEAVE.
        end.
    end.
    do jj = 1 to  7:
        assign
        new2-x-date-end = p-date-end - jj
        .
        if weekday(new2-x-date-end) = v-week-end then do:
            LEAVE.
        end.
    end.

end.
else do:
  assign
  new1-x-date-end = p-date-end
  new2-x-date-end = p-date-end
  new-x-date-end = p-date-end
  .
end.
 if loud1 then do:

    assign
    new-x-date-start = (if (abs(p-date-start - new2-x-date-start) < abs(p-date-start - new2-x-date-start)) AND new2-x-date-start < new2-x-date-end
                                  then new2-x-date-start
                                  else new1-x-date-start)
    .
end.
 if loud2 then do:
    assign
    new-x-date-end = (if (abs(p-date-end - new1-x-date-end) < abs(p-date-end - new2-x-date-end)) or new2-x-date-end <= new2-x-date-start
                                  then new1-x-date-end
                                  else new2-x-date-end)
    .
  end.
 if new-x-date-end > v-today then do:
  assign
  new-x-date-start = new-x-date-start - 7
  new-x-date-end = new-x-date-end - 7
  loud1 = yes
  loud2 = yes
  .
 end.
    if loud and loud1 then
    message "Дата начала периода должна быть" get-weekday-name(p-week-start) skip
            "Заменяем" p-date-start " на " new-x-date-start
    view-as alert-box ERROR.
    if loud and loud2 then
    message "Дата конца периода должна быть" get-weekday-name(v-week-end) skip
            "Заменяем" p-date-end " на " new-x-date-end
    view-as alert-box ERROR.
    assign
    p-date-start = if loud1
                         then new-X-date-start
                          else p-date-start
    p-date-end = if loud2
                        then new-X-date-end
                         else p-date-end
    .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI F-Frame-Win  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Hide all frames. */
  HIDE FRAME F-Main.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI F-Frame-Win  _DEFAULT-ENABLE
PROCEDURE enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
  DISPLAY RS_wdays
      WITH FRAME F-Main.
  ENABLE RECT-1 RS_wdays
      WITH FRAME F-Main.
  {&OPEN-BROWSERS-IN-QUERY-F-Main}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize F-Frame-Win
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .
  assign
  RS_wdays:radio-buttons in frame {&frame-name} =
  entry(2, {&weekday-names}) + {&comma-char} + string(2 ) + {&comma-char} +
entry(3, {&weekday-names}) + {&comma-char} + string(3 ) + {&comma-char} +
entry(4, {&weekday-names}) + {&comma-char} + string(4 ) + {&comma-char} +
entry(5, {&weekday-names}) + {&comma-char} + string(5 ) + {&comma-char} +
entry(6, {&weekday-names}) + {&comma-char} + string(6 ) + {&comma-char} +
entry(7, {&weekday-names}) + {&comma-char} + string(7 ) + {&comma-char} +
entry(1, {&weekday-names}) + {&comma-char} + string(1 ).
  assign
  RS_wdays  = 2
  .


  /* Code placed here will execute AFTER standard behavior.    */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE My-Report F-Frame-Win
PROCEDURE My-Report :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE VARIABLE accum-tot-sum like ub.inkas.netto no-undo .
DEFINE VARIABLE accum-tot-chk like ub.inkas.num-chk no-undo .
DEFINE VARIABLE accum-week-tot-sum like ub.inkas.netto no-undo .
DEFINE VARIABLE accum-week-tot-chk like ub.inkas.num-chk no-undo .
DEFINE VARIABLE accum-all-tot-sum like ub.inkas.netto no-undo .
DEFINE VARIABLE accum-all-tot-chk like ub.inkas.num-chk no-undo .
DEFINE VARIABLE v-print-date as date no-undo .
DEFINE VARIABLE v-week-start as integer no-undo .
DEFINE VARIABLE v-week-end as integer no-undo .
DEFINE VARIABLE Strbuf as character no-undo .
DEFINE VARIABLE v-col-num as integer no-undo .
define variable date_string as character no-undo.
DEFINE VARIABLE kol_obj as integer no-undo .
define variable glog as logical no-undo .
/*кол-во чеков в продаже*/
define variable chk-amount as integer no-undo .
/*кол-во нф чеков в продаже*/
define variable nf-chk-amount as integer no-undo .



define buffer cli_shop for ub.clients .
define buffer buf_inkas for ub.inkas.
for each temp-sum:
  delete temp-sum.
end.

glog = no.
FOR EACH obj-list NO-LOCK,
    FIRST buf_inkas where
        buf_inkas.doc-date >= my-X-Date-Start AND
        buf_inkas.doc-date <= my-X-Date-End AND
        buf_inkas.obj-type = obj-list.obj-type AND
        buf_inkas.obj-code = obj-list.obj-code AND
        buf_inkas.status_ = {&fact} NO-LOCK:
  glog = (if glog = no then yes else glog) .
END.
if NOT glog then do:
    message {&no-benefits} view-as alert-box.
    return.
end.
assign
v-week-start = RS_wdays
v-week-end = (if v-week-start = 1
              then 7
              else (v-week-start - 1)
              )
.

date_string = cur-time-print() .
run waitfram-show in this-procedure ("Ждите...").

assign
sheetf.Excel-COlumn-Lable = string( "Дата", "x(10)" ) + {&comma-char} +
                            string("День недели", "X(11)") + {&comma-char}
sheetf.sizes = "10" + {&comma-char} +
               "11" + {&comma-char}
sheetf.MergeCellsH = "":U
sheetf.MergeCellsV = "":U

.
for each obj-list no-lock:
  find first cli_shop no-lock where
             cli_shop.obj-code = obj-list.obj-code
         AND cli_shop.obj-type = obj-list.obj-type no-error .
  assign
  sheetf.Excel-COlumn-Lable = sheetf.Excel-Column-Lable +
                             string(replace(cli_shop.obj-name, {&comma-char}, {&space-char}), "x(15)" ) + {&comma-char} +
                             fill ({&space-char}, 12) + {&comma-char} +
                             fill ({&space-char}, 12) + {&comma-char}
  sheetf.sizes = sheetf.sizes +
                "6" + {&comma-char} +
                "12" + {&comma-char} +
                "12" + {&comma-char}
  kol_obj = kol_obj + 1
  .
end.
assign
sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable +
                          string("Итог дня", "X(8)") +  {&comma-char} +
                          fill( {&space-char}, 15 ) + {&comma-char} +
                          string("Итог недели", "X(11)") + {&comma-char} +
                          fill({&space-char}, 15 )
sheetf.sizes = sheetf.sizes +
              "8" + {&comma-char} +
              "15" + {&comma-char} +
              "11" + {&comma-char} +
              "15"
.
 /*конец 1-ой строки шапки*/
assign
sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + {&new-line} +
                            {&comma-char} +
                            {&comma-char}
.
assign
v-col-num = 3
.
for each obj-list no-lock:
  find first cli_shop no-lock where
             cli_shop.obj-code = obj-list.obj-code
         AND cli_shop.obj-type = obj-list.obj-type no-error .
  assign
  sheetf.Excel-COlumn-Lable = sheetf.Excel-Column-Lable +
                             string("Чеки", "x(6)" ) + {&comma-char} +
                             string("Сред. покупка", "X(12)") + {&comma-char} +
                             string("Выручка", "X(12)") + {&comma-char}
  sheetf.MergeCellsH = Sheetf.MergeCellsH + (if Sheetf.MergeCellsH = "":U then "":U else {&comma-char}) +
                       string(v-col-num)+ ":":U + string(v-col-num + 2)
  v-col-num = v-col-num + 3
  .

end.
assign
sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable +
                            string("Чеки", "X(8)") + {&comma-char} +
                            string("Выручка", "X(15)") +  {&comma-char} +
                            string("Чеки", "X(11)") + {&comma-char} +
                            string("Выручка", "X(15)")
sheetf.MergeCellsH = Sheetf.MergeCellsH + (if Sheetf.MergeCellsH = "":U then "":U else {&comma-char}) +
                       string(v-col-num)+ ":":U + string(v-col-num + 1) + {&comma-char} +
                       string(v-col-num + 2)+ ":":U + string(v-col-num + 3)
sheetf.MergeCellsV =  "1=1:2/2=1:2":U
Sheetf.colformat = "1=dd/mm/yy":U
.

Sheetf.Bas-File = "exe/e-weekv.bas".
run rep/extitle.p (1).
/*конец 2-ой строки шапки*/

assign
Sheetf.Bas-Params = string(kol_obj) + {&delim-par} + string(Sheetf.Excel-Row-Heder + 2 /*количество строк в назв колонок*/ )
.


/*собирем информацию во времен таблице*/
FOR EACH obj-list NO-LOCK,
    EACH buf_inkas NO-LOCK where
        buf_inkas.doc-date >= my-X-Date-Start AND
        buf_inkas.doc-date <= my-X-Date-End AND
        buf_inkas.obj-type = obj-list.obj-type AND
        buf_inkas.obj-code = obj-list.obj-code AND
        buf_inkas.status_ = {&fact}
BREAK
by buf_inkas.obj-type
by buf_inkas.obj-code
by buf_inkas.status_
by buf_inkas.doc-date
:
  if first-of(buf_inkas.doc-date) then do:
    assign
    accum-tot-sum = 0
    accum-tot-chk = 0
    .
  end.
  nf-chk-amount = 0.
  assign
  accum-tot-sum = accum-tot-sum + buf_inkas.netto
  accum-tot-chk = accum-tot-chk + buf_inkas.num-chk - buf_inkas.num-chk-nff
  .
  if last-of(buf_inkas.doc-date) then do:
    find first temp-sum no-lock where
               temp-sum.obj-type = obj-list.obj-type
           AND temp-sum.obj-code = obj-list.obj-code
           AND temp-sum.doc-date = buf_inkas.doc-date no-error .
    if not avail temp-sum then do:
      create temp-sum.
      assign
      temp-sum.doc-date = buf_inkas.doc-date
      temp-sum.obj-type = obj-list.obj-type
      temp-sum.obj-code = obj-list.obj-code
      temp-sum.tot-sum = accum-tot-sum
      temp-sum.tot-chk = accum-tot-chk
      .
    end.
  end.
END. /*for each obj-list*/

do v-print-date = my-x-date-start to my-x-date-end:
  if weekday(v-print-date) = v-week-start then do:
    assign
    accum-week-tot-sum = 0
    accum-week-tot-chk = 0
    .
  end.
  assign
  accum-tot-sum = 0
  accum-tot-chk = 0
  .
  {&PutExcel}
  string(v-print-date, "99/99/99":U) {&tabulation}
  get-weekday-name-short(weekday(v-print-date)) {&tabulation}
  .
  for each obj-list no-lock:
    find first temp-sum no-lock where
               temp-sum.obj-type = obj-list.obj-type
          AND temp-sum.obj-code = obj-list.obj-code
          AND temp-sum.doc-date = v-print-date no-error .
    assign
    StrBuf =
              (if avail temp-sum
              then (string(temp-sum.tot-chk) + {&tabulation} +
                    string(ROUND((temp-sum.tot-sum / temp-sum.tot-chk), 2)) + {&tabulation} +
                    string(temp-sum.tot-sum) + {&tabulation})
              else  ({&tabulation} +
                     {&tabulation} +
                     {&tabulation})
             )
    accum-tot-sum = accum-tot-sum + (if avail temp-sum then temp-sum.tot-sum else 0)
    accum-tot-chk = accum-tot-chk + (if avail temp-sum then temp-sum.tot-chk else 0)
    /*это общее за день*/
    accum-week-tot-sum = accum-week-tot-sum + (if avail temp-sum then temp-sum.tot-sum else 0)
    accum-week-tot-chk = accum-week-tot-chk + (if avail temp-sum then temp-sum.tot-chk else 0)
    /*это за неделю*/
    accum-all-tot-sum = accum-all-tot-sum + (if avail temp-sum then temp-sum.tot-sum else 0)
    accum-all-tot-chk = accum-all-tot-chk + (if avail temp-sum then temp-sum.tot-chk else 0)
    /*это за весь период*/
    .
    {&PutExcel}
    Strbuf
    .

  end. /*for each obj-list*/
  if weekday(v-print-date) = v-week-end then do:
    {&PutExcel}
    (if accum-tot-chk <> 0 then string(accum-tot-chk) else "":U) {&tabulation}
    (if accum-tot-chk <> 0 then string(accum-tot-sum) else "":U) {&tabulation}
    (if accum-week-tot-chk <> 0 then string(accum-week-tot-chk) else "":U) {&tabulation}
    (if accum-week-tot-chk <> 0 then string(accum-week-tot-sum) else "":U)
    SKIP.
  end.
  else do:
    {&PutExcel}
    (if accum-tot-chk <> 0 then string(accum-tot-chk) else "":U) {&tabulation}
    (if accum-tot-chk <> 0 then string(accum-tot-sum) else "":U) {&tabulation}
    {&tabulation}
    SKIP.
  end.
end. /*do v-print*/
{&PutExcel}
"ИТОГО" {&tabulation}
{&tabulation}
.
for each obj-list no-lock:
  {&PutExcel}
  {&tabulation}
  {&tabulation}
  {&tabulation}
  .
end.
{&PutExcel}
{&tabulation}
{&tabulation}
accum-all-tot-chk {&tabulation}
accum-all-tot-sum
skip
.
{&CloseExcel}
run waitfram-hide in this-procedure .
run get-report-num  in my-handle(output g#report-num).
run rep/runexcel.p (string( session:temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt").
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE My-var F-Frame-Win
PROCEDURE My-var :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable State-source as handle.
define variable my#x-date-start  like  x-date-start no-undo.
define variable my#x-date-end    like  x-date-end   no-undo.


Assign FRAME {&FRAME-NAME} RS_wdays .
Assign
 STR-obj-type = ''
 STR-obj-code = ''
 STR-obj-name = ''
 STR-obj      = ''.

For each obj-list no-lock:
 Assign
 STR-obj-type = STR-obj-type + obj-list.obj-type + ','
 STR-obj-code = STR-obj-code + String(obj-list.obj-code) + ','
 STR-obj-name = STR-obj-name + obj-list.obj-name + ','
 STR-obj = STR-obj +  obj-list.obj-type + '#' + string(obj-list.obj-code)  + ',' .
End.
assign
ReportNAme = "Понедельный отчет по выручке"
ReportHeader =  ("Началом отчетной недели считается" + {&space-char} +
radio-label(string(RS_wdays), RS_wdays:radio-buttons))
.

assign
my-x-date-start = x-date-start
my-x-date-end = x-date-end
my#x-date-start = x-date-start
my#x-date-end = x-date-end

.
run check-dates(input-output my-X-date-Start, input-output my-X-date-End, RS_wdays,  yes).
x-date-start = my-x-date-start  .
x-date-end   = my-x-date-end    .
 IF ( my#x-date-start <> my-x-date-start
   OR my#x-date-end <> my-x-date-end) THEN DO:
   { rep/get-link.i 'State':U}
   Run Select1 IN State-source.
   Return error 'First-page':U.
End.



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Print-Proc F-Frame-Win
PROCEDURE Print-Proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records F-Frame-Win  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* SEND-RECORDS does nothing because there are no External
     Tables specified for this SmartObject, and there are no
     tables specified in any contained Browse, Query, or Frame. */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed F-Frame-Win
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE NO-UNDO.
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.
/*
  if p-state begins "DATE-START" then do:
    my-x-date-start = date(substr(p-state, length(p-state) - 10 + 1)).
    message my-x-date-start "mm".
    run check-dates(input-output my-x-date-start, input-output my-x-date-end, RS_wdays, no).
  end.
  if p-state begins "DATE-END" then do:
    my-x-date-end = date(substr(p-state, length(p-state) - 10 + 1)).
    message my-x-date-start "mm".
    run check-dates(input-output my-x-date-start, input-output my-x-date-end, RS_wdays, no).
  end.
*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-weekday-name F-Frame-Win
FUNCTION get-weekday-name RETURNS CHARACTER
  ( input p-weekday as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
  RETURN entry(p-weekday, {&weekday-names}).   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-weekday-name-short F-Frame-Win
FUNCTION get-weekday-name-short RETURNS CHARACTER
  ( input p-weekday as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

  RETURN entry(p-weekday, {&weekday-names-short}).   /* Function return value. */



END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME