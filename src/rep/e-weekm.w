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

Понедельный отчет по товарам (реализация)

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/07/05
Author: Bakhtadze Natalya
Creation date: 09/07/05

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
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ cmp/r-page1.i  }
{ gbl/prn-lib.i }
{ gbl/waitfram.i }
{ cmp/operlist.i }
{ gbl/getcntxt.i def }
{ gbl/getsect.i  def }

def temp-table sj-goods no-undo
    field artic     like ub.goods.artic
    field prod-type like ub.goods.prod-type
    field prod-code like ub.goods.prod-code
    field date_ like ub.inkas.doc-date
    field weekn as integer
    field qnty              as   decimal
    field brutto-sum   as   decimal
    field discnt-sum  as   decimal
    field netto-sum    as   decimal
    field uchet-sum   as decimal /*учетные цены*/
    INDEX p1 IS PRIMARY   weekn date_ artic prod-type prod-code
    .

&global-define  no-benefits    "Не было никаких закрытых продаж на выбранных объектах ~
в течение заданного Вами периода времени."

define variable my-x-date-start as date no-undo.
define variable my-x-date-end as date no-undo.
define variable State-source as Widget-Handle.
define variable v-curr-r-b as character no-undo .
define variable p-XL-delim as character no-undo .

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
&Scoped-Define ENABLED-OBJECTS RECT-1 RS-method
&Scoped-Define DISPLAYED-OBJECTS RS-method

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE RS-method AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "С товарами":L, "ARTIC":U,
"Без товаров":L, "TOTALS":U
     SIZE 22.88 BY 2.21 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 29.13 BY 4.21.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     RS-method AT ROW 3.25 COL 3.88 NO-LABEL
     "Детализация" VIEW-AS TEXT
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




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK F-Frame-Win


/* ***************************  Main Block  *************************** */
{ gbl/getcntxt.i get " " my-handle }
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
DEFINE INPUT PARAMETER loud as logical no-undo.
define variable new-X-date-start as date no-undo.
define variable new-X-date-end as date no-undo.

IF weekday(p-date-start)  <> 2 then do:
    if weekday(p-date-start) = 1 then
    new-X-date-start = p-date-start + 1.
    else
    new-X-date-start = p-date-start - (weekday(p-date-start)  - 2).
    if loud then
    message "Дата начала периода должна быть понедельником!" skip
            "Заменяем" p-date-start " на " new-x-date-start
    view-as alert-box ERROR.
    p-date-start = new-X-date-start.
end.
IF weekday(p-date-end)  <> 1 then do:
    new-X-date-end = p-date-end + (8 - weekday(p-date-end)).
    if loud then
    message "Дата конца периода должна быть воскресеньем!" skip
            "Заменяем" p-date-end " на " new-x-date-end
    view-as alert-box ERROR.
    p-date-end = new-X-date-end.
end.
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
  DISPLAY RS-method
      WITH FRAME F-Main.
  ENABLE RECT-1 RS-method
      WITH FRAME F-Main.
  {&OPEN-BROWSERS-IN-QUERY-F-Main}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ini-from-SelectGood F-Frame-Win
PROCEDURE ini-from-SelectGood :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable glog as logical no-undo .
CASE X-SelectGood:
    WHEN {&g-all} then do:
        assign
        RS-method = "TOTALS":U
        .
        glog = RS-Method:disable(radio-label("ARTIC":U, RS-method:radio-buttons))
                     in frame {&frame-name}.
        Display
        RS-MEthod
        With frame {&FRAME-NAME}
        .
    end.
    WHEN {&g-choice} then do:
        glog = RS-Method:enable(radio-label("ARTIC":U, RS-method:radio-buttons))
                     in frame {&frame-name}.
        DISPLAY
        RS-method
        With frame {&FRAME-NAME}
        .
    end.
END CASE.
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
define variable glog as logical no-undo .
glog = no.
{ gbl/curr-r-b.i
  v-curr-r-b
}
define variable type-par1 as character no-undo .
define variable tmp-var1  as character no-undo .

{ gbl/getsect.i run v-cntxt-obj-type  v-cntxt-obj-code {&attr-report-firm} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'XL-delim'  then tmp-var1   = thbjattr_thbj-attr.property-value-character.
end.
IF tmp-var1 = "" then p-XL-delim = ";".
else p-XL-delim = tmp-var1.

FOR EACH obj-list NO-LOCK,
        FIRST ub.inkas where ub.inkas.doc-date >= my-X-Date-Start AND
                   ub.inkas.doc-date <= my-X-Date-End AND
                   ub.inkas.obj-type = obj-list.obj-type AND
                   ub.inkas.obj-code = obj-list.obj-code NO-LOCK:
                   glog = yes.
END.
if NOT glog then do:
    message {&no-benefits} view-as alert-box.
    return.
end.


run waitfram-show in this-procedure ({&MyWaitMess} ) .

RUN Print-Proc.
run waitfram-hide in this-procedure .
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


Assign FRAME {&FRAME-NAME} Rs-Method .

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
ReportNAme = "Понедельный отчет по товарам".
ReportHeader =  radio-label(RS-method, RS-method:radio-buttons).

assign
my-x-date-start = x-date-start
my-x-date-end = x-date-end
my#x-date-start = x-date-start
my#x-date-end = x-date-end

.
run check-dates(input-output my-X-date-Start, input-output my-X-date-End, yes).
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
define variable is-out as integer init 1.
def buffer ret-doc for ub.trn-doc.
define variable doc-num like ub.trn-doc.doc-code no-undo.
define variable doc-date like ub.trn-doc.doc-date no-undo.
define variable jj as integer no-undo.
define variable cur-quant like ub.gds-dtl.doc-qnty no-undo.

define variable tot-qnty as decimal.
define variable tot-netto as decimal.
define variable tot-uchet as decimal.
define variable column-qnty as decimal extent 8.
define variable column-netto as decimal extent 8.
define variable column-uchet as decimal extent 8.
define variable current-date as date format "99/99/9999" no-undo.
define variable stroka-qnty as char.
define variable stroka-netto as char.
define variable stroka-uchet as char.


define variable i as integer no-undo .
define variable date_string     as      char    no-undo.
define variable tdoc-code     as      char    no-undo.
define variable s-price as decimal no-undo .
define variable cur-discnt as decimal no-undo .
define variable g#log as logical no-undo .

ASSIGN
frame {&frame-name} RS-METHOD.

run waitfram-show in this-procedure ( "Подождите ..." ).
FOR EACH sj-goods :
    delete sj-goods .
END .
IF X-SelectGood = {&g-all} then do: /*все*/
    create gds-list.
END.

FOR EACH obj-list NO-LOCK,
    EACH ub.inkas WHERE
         ub.inkas.doc-date >= my-X-Date-Start and
         ub.inkas.doc-date <= my-X-Date-End AND
         ub.inkas.obj-code = obj-list.obj-code and
         ub.inkas.obj-type = obj-list.obj-type AND
         ub.inkas.status_ = {&fact} NO-LOCK:
    FIND FIRST ub.trn-doc WHERE ub.trn-doc.doc-code = ub.inkas.inkas-code NO-LOCK NO-ERROR.
    FIND FIRST ret-doc WHERE ret-doc.doc-code = ub.trn-doc.out-code NO-LOCK NO-ERROR.
    assign
    doc-num = ub.trn-doc.doc-code
    doc-date = ub.inkas.doc-date
    is-out = 1.
    { rep/e-weekm.i }
      if available ret-doc then do:
      assign
      doc-num = ret-doc.doc-code
      is-out = -1.
      { rep/e-weekm.i }
   end.
END. /*FOR EACH obj*/


date_string = cur-time-print() .
run waitfram-hide in this-procedure .
run waitfram-show in this-procedure ("Ждите...").

{ cmp/open-exp.i STREAM PrnLibStream " " }
PUT STREAM PrnLibStream UNFORMATTED
"ПОНЕДЕЛЬНЫЙ ОТЧЕТ ПО ТОВАРАМ (РЕАЛИЗАЦИЯ В МАГАЗИНЕ) " format "X(100)"
SKIP(0)
str1
SKIP(0)
str4
SKIP(0)
radio-label(string(RS-method), RS-method:radio-buttons)
SKIP(0)
.
FOR EACH obj-list :
    FIND FIRST ub.clients WHERE ub.clients.obj-type = obj-list.obj-type AND
                             ub.clients.obj-code = obj-list.obj-code NO-LOCK .
    PUT  STREAM PrnLibStream ub.clients.obj-name format "X(100)" SKIP.
    END.
    PUT STREAM PrnLibStream
    date_string format "X(35)"
    SKIP(0).
    PUT STREAM PrnLibStream " " SKIP(1) .
    IF RS-method = "ARTIC":U THEN DO:
            PUT STREAM PrnLibStream UNFORMATTED
            "Артикул" p-XL-delim
            "Название" p-XL-delim
            "Производитель" p-XL-delim
            "Ед.изм." p-XL-delim.
     END.
     ELSE
     PUT STREAM PrnLibStream UNFORMATTED
     (IF X-SelectGood = {&g-choice}
      then "ВСЕ_ВЫБРАННЫЕ_ТОВАРЫ"
      ELSE "ВСЕ_ТОВАРЫ")
     p-XL-delim.
     PUT STREAM PrnLibStream UNFORMATTED
    "Понедельник   " p-XL-delim
    "Вторник   " p-XL-delim
    "Среда     " p-XL-delim
    "Четверг    " p-XL-delim
    "Пятница    " p-XL-delim
    "Суббота    " p-XL-delim
    "Воскресенье   " p-XL-delim
    "Итого_кол-во_по строке   " p-XL-delim
    ""                        p-XL-delim
    "Понедельник   " p-XL-delim
    "Вторник   " p-XL-delim
    "Среда     " p-XL-delim
    "Четверг    " p-XL-delim
    "Пятница    " p-XL-delim
    "Суббота    " p-XL-delim
    "Воскресенье   " p-XL-delim
    "Итого_сумма_продажных_цен_по строке" p-XL-delim
    ""                        p-XL-delim
    "Понедельник   " p-XL-delim
    "Вторник   " p-XL-delim
    "Среда     " p-XL-delim
    "Четверг    " p-XL-delim
    "Пятница    " p-XL-delim
    "Суббота    " p-XL-delim
    "Воскресенье   " p-XL-delim
    "Итого_сумма_учетных_цен_по строке" SKIP(0)
    .

    current-date = my-X-Date-Start.
    REPEAT WHILE current-date <= my-X-Date-End:
    IF RS-method = "ARTIC":U THEN DO:
        PUT STREAM PrnLibStream UNFORMATTED
        "" p-XL-delim
        "" p-XL-delim
        "" p-XL-delim
        "" p-XL-delim.
     END.
     ELSE
     PUT STREAM PrnLibStream UNFORMATTED
     "" p-XL-delim.
     PUT STREAM PrnLibStream UNFORMATTED
      current-date      p-XL-delim
     (current-date + 1) p-XL-delim
     (current-date + 2) p-XL-delim
     (current-date + 3) p-XL-delim
     (current-date + 4) p-XL-delim
     (current-date + 5) p-XL-delim
     (current-date + 6) p-XL-delim
     "" p-XL-delim
     "" p-XL-delim
     (current-date) p-XL-delim
     (current-date + 1) p-XL-delim
     (current-date + 2) p-XL-delim
     (current-date + 3) p-XL-delim
     (current-date + 4) p-XL-delim
     (current-date + 5) p-XL-delim
     (current-date + 6) p-XL-delim
     "" p-XL-delim
     "" p-XL-delim
     (current-date) p-XL-delim
     (current-date + 1) p-XL-delim
     (current-date + 2) p-XL-delim
     (current-date + 3) p-XL-delim
     (current-date + 4) p-XL-delim
     (current-date + 5) p-XL-delim
     (current-date + 6) p-XL-delim
     "" p-XL-delim
     "" SKip(0)
     .
     assign
     tot-qnty = 0
     tot-netto = 0
     tot-uchet = 0
     stroka-qnty = ""
     stroka-netto = ""
     stroka-uchet = "".

    IF RS-METHOD = "ARTIC":U then do:
        FOR EACH gds-list No-lock :
            assign
            tot-qnty = 0
            tot-netto = 0
            tot-uchet = 0
            stroka-qnty = ""
            stroka-netto = ""
            stroka-uchet = "".
            FOR EACH sj-goods NO-LOCK WHERE
                              sj-goods.prod-type = gds-list.prod-type AND
                              sj-goods.prod-code = gds-list.prod-code AND
                              sj-goods.artic = gds-list.artic AND
                              sj-goods.weekn = INTEGER(truncate(INTEGER(current-date - my-X-Date-Start) / 7, 0))
                              by sj-goods.date_:
                sj-goods.netto-sum = sj-goods.brutto-sum - sj-goods.discnt.
                assign
                stroka-qnty =  stroka-qnty + string(weekday(sj-goods.date_)) +
                                       {&slash-char} + string(sj-goods.qnty) + "@"
                stroka-netto =  stroka-netto + string(weekday(sj-goods.date_)) +
                                        {&slash-char} + string(sj-goods.netto-sum) + "@"
                 stroka-uchet =  stroka-uchet + string(weekday(sj-goods.date_)) +
                                        {&slash-char} + string(sj-goods.uchet-sum) + "@"
                 tot-qnty = tot-qnty + sj-goods.qnty
                 tot-netto = tot-netto + sj-goods.netto-sum
                 tot-uchet = tot-uchet + sj-goods.uchet-sum
                 column-qnty[weekday(sj-goods.date_)] = column-qnty[weekday(sj-goods.date_)] +
                                                                                  sj-goods.qnty
                 column-netto[weekday(sj-goods.date_)] = column-netto[weekday(sj-goods.date_)] +
                                                                                    sj-goods.netto-sum
                 column-uchet[weekday(sj-goods.date_)] = column-uchet[weekday(sj-goods.date_)] +
                                                                                     sj-goods.uchet-sum
                 column-qnty[8] = column-qnty[8] + sj-goods.qnty
                 column-netto[8] = column-netto[8] + sj-goods.netto-sum
                 column-uchet[8] = column-uchet[8] + sj-goods.uchet-sum.
           END. /*FOR EAC SH-goods*/
           FIND FIRST clients WHERE
                               clients.obj-type = gds-list.prod-type AND
                               clients.obj-code = gds-list.prod-code NO-LOCK .
            PUT STREAM PrnLibStream UNFORMATTED
            gds-list.artic p-XL-delim
            replace(gds-list.gds-name, " ", "_") p-XL-delim
            replace(clients.obj-name, " ", "_") p-XL-delim
            gds-list.unit-base p-XL-delim.
            .
            PUT STREAM PrnLibStream UNFORMATTED
            (IF INDEX(stroka-qnty, "2/") > 0
             then ENTRY(1, SUBSTR(stroka-qnty, (INDEX(stroka-qnty, "2/") + 2)), "@")
             else "0")  p-XL-delim
            (IF INDEX(stroka-qnty, "3/") > 0
             then ENTRY(1, SUBSTR(stroka-qnty, (INDEX(stroka-qnty, "3/") + 2)), "@")
             else "0")  p-XL-delim
            (IF INDEX(stroka-qnty, "4/") > 0
             then ENTRY(1, SUBSTR(stroka-qnty, (INDEX(stroka-qnty, "4/") + 2)), "@")
             else "0")  p-XL-delim
            (IF INDEX(stroka-qnty, "5/") > 0
             then ENTRY(1, SUBSTR(stroka-qnty, (INDEX(stroka-qnty, "5/") + 2)), "@")
             else "0")  p-XL-delim
            (IF INDEX(stroka-qnty, "6/") > 0
             then ENTRY(1, SUBSTR(stroka-qnty, (INDEX(stroka-qnty, "6/") + 2)), "@")
             else "0")  p-XL-delim
            (IF INDEX(stroka-qnty, "7/") > 0
             then ENTRY(1, SUBSTR(stroka-qnty, (INDEX(stroka-qnty, "7/") + 2)), "@")
             else "0")  p-XL-delim
            (IF INDEX(stroka-qnty, "1/") > 0
             then ENTRY(1, SUBSTR(stroka-qnty, (INDEX(stroka-qnty, "1/") + 2)), "@")
             else "0")  p-XL-delim
            tot-qnty p-XL-delim
            ""          p-XL-delim
            (IF INDEX(stroka-netto, "2/") > 0
             then ENTRY(1, SUBSTR(stroka-netto, (INDEX(stroka-netto, "2/") + 2)), "@")
             else "0")  p-XL-delim
            (IF INDEX(stroka-netto, "3/") > 0
             then ENTRY(1, SUBSTR(stroka-netto, (INDEX(stroka-netto, "3/") + 2)), "@")
             else "0")  p-XL-delim
            (IF INDEX(stroka-netto, "4/") > 0
             then ENTRY(1, SUBSTR(stroka-netto, (INDEX(stroka-netto, "4/") + 2)), "@")
             else "0")  p-XL-delim
            (IF INDEX(stroka-netto, "5/") > 0
             then ENTRY(1, SUBSTR(stroka-netto, (INDEX(stroka-netto, "5/") + 2)), "@")
             else "0")  p-XL-delim
            (IF INDEX(stroka-netto, "6/") > 0
             then ENTRY(1, SUBSTR(stroka-netto, (INDEX(stroka-netto, "6/") + 2)), "@")
             else "0")  p-XL-delim
            (IF INDEX(stroka-netto, "7/") > 0
             then ENTRY(1, SUBSTR(stroka-netto, (INDEX(stroka-netto, "7/") + 2)), "@")
             else "0")  p-XL-delim
            (IF INDEX(stroka-netto, "1/") > 0
             then ENTRY(1, SUBSTR(stroka-netto, (INDEX(stroka-netto, "1/") + 2)), "@")
             else "0")  p-XL-delim
            tot-netto p-XL-delim
            ""          p-XL-delim
           (IF INDEX(stroka-uchet, "2/") > 0
            then ENTRY(1, SUBSTR(stroka-uchet, (INDEX(stroka-uchet, "2/") + 2)), "@")
            else "0")  p-XL-delim
           (IF INDEX(stroka-uchet, "3/") > 0
            then ENTRY(1, SUBSTR(stroka-uchet, (INDEX(stroka-uchet, "3/") + 2)), "@")
            else "0")  p-XL-delim
           (IF INDEX(stroka-uchet, "4/") > 0
            then ENTRY(1, SUBSTR(stroka-uchet, (INDEX(stroka-uchet, "4/") + 2)), "@")
            else "0")  p-XL-delim
           (IF INDEX(stroka-uchet, "5/") > 0
            then ENTRY(1, SUBSTR(stroka-uchet, (INDEX(stroka-uchet, "5/") + 2)), "@")
            else "0")  p-XL-delim
           (IF INDEX(stroka-uchet, "6/") > 0
            then ENTRY(1, SUBSTR(stroka-uchet, (INDEX(stroka-uchet, "6/") + 2)), "@")
            else "0")  p-XL-delim
           (IF INDEX(stroka-uchet, "7/") > 0
            then ENTRY(1, SUBSTR(stroka-uchet, (INDEX(stroka-uchet, "7/") + 2)), "@")
            else "0")  p-XL-delim
           (IF INDEX(stroka-uchet, "1/") > 0
            then ENTRY(1, SUBSTR(stroka-uchet, (INDEX(stroka-uchet, "1/") + 2)), "@")
            else "0")  p-XL-delim
           tot-uchet
           skip(0).
        END. /*FOR EACH gds-list*/
    END. /*IF RS_method = artic*/
    ELSE DO: /*RS-method <> "ARTIC"*/
        FOR EACH sj-goods NO-LOCK WHERE
                          sj-goods.weekn = INTEGER(truncate(INTEGER(current-date - my-X-Date-Start) / 7, 0))
                          by sj-goods.date_:
            sj-goods.netto-sum = sj-goods.brutto-sum - sj-goods.discnt.
            assign
            stroka-qnty =  stroka-qnty + string(weekday(sj-goods.date_)) +
                                   {&slash-char} + string(sj-goods.qnty) + "@"
            stroka-netto =  stroka-netto + string(weekday(sj-goods.date_)) +
                                    {&slash-char} + string(sj-goods.netto-sum) + "@"
            stroka-uchet =  stroka-uchet + string(weekday(sj-goods.date_)) +
                                    {&slash-char} + string(sj-goods.uchet-sum) + "@"
            tot-qnty = tot-qnty + sj-goods.qnty
            tot-netto = tot-netto + sj-goods.netto-sum
            tot-uchet = tot-uchet + sj-goods.uchet-sum
            column-qnty[weekday(sj-goods.date_)] = column-qnty[weekday(sj-goods.date_)] +
                                                                               sj-goods.qnty
            column-netto[weekday(sj-goods.date_)] = column-netto[weekday(sj-goods.date_)] +
                                                                                sj-goods.netto-sum
            column-uchet[weekday(sj-goods.date_)] = column-uchet[weekday(sj-goods.date_)] +
                                                                                sj-goods.uchet-sum
            column-qnty[8] = column-qnty[8] + sj-goods.qnty
            column-netto[8] = column-netto[8] + sj-goods.netto-sum
            column-uchet[8] = column-uchet[8] + sj-goods.uchet-sum.
        END. /*FOR EAC SH-goods*/
        PUT STREAM PrnLibStream UNFORMATTED
        "" p-XL-delim.
        PUT STREAM PrnLibStream UNFORMATTED
        (IF INDEX(stroka-qnty, "2/") > 0
          then ENTRY(1, SUBSTR(stroka-qnty, (INDEX(stroka-qnty, "2/") + 2)), "@")
          else "0")  p-XL-delim
         (IF INDEX(stroka-qnty, "3/") > 0
          then ENTRY(1, SUBSTR(stroka-qnty, (INDEX(stroka-qnty, "3/") + 2)), "@")
          else "0")  p-XL-delim
         (IF INDEX(stroka-qnty, "4/") > 0
          then ENTRY(1, SUBSTR(stroka-qnty, (INDEX(stroka-qnty, "4/") + 2)), "@")
          else "0")  p-XL-delim
         (IF INDEX(stroka-qnty, "5/") > 0
          then ENTRY(1, SUBSTR(stroka-qnty, (INDEX(stroka-qnty, "5/") + 2)), "@")
          else "0")  p-XL-delim
         (IF INDEX(stroka-qnty, "6/") > 0
          then ENTRY(1, SUBSTR(stroka-qnty, (INDEX(stroka-qnty, "6/") + 2)), "@")
          else "0")  p-XL-delim
         (IF INDEX(stroka-qnty, "7/") > 0
          then ENTRY(1, SUBSTR(stroka-qnty, (INDEX(stroka-qnty, "7/") + 2)), "@")
          else "0")  p-XL-delim
         (IF INDEX(stroka-qnty, "1/") > 0
          then ENTRY(1, SUBSTR(stroka-qnty, (INDEX(stroka-qnty, "1/") + 2)), "@")
          else "0")  p-XL-delim
        tot-qnty p-XL-delim
        ""          p-XL-delim
        (IF INDEX(stroka-netto, "2/") > 0
         then ENTRY(1, SUBSTR(stroka-netto, (INDEX(stroka-netto, "2/") + 2)), "@")
         else "0")  p-XL-delim
        (IF INDEX(stroka-netto, "3/") > 0
         then ENTRY(1, SUBSTR(stroka-netto, (INDEX(stroka-netto, "3/") + 2)), "@")
         else "0")  p-XL-delim
        (IF INDEX(stroka-netto, "4/") > 0
         then ENTRY(1, SUBSTR(stroka-netto, (INDEX(stroka-netto, "4/") + 2)), "@")
         else "0")  p-XL-delim
        (IF INDEX(stroka-netto, "5/") > 0
         then ENTRY(1, SUBSTR(stroka-netto, (INDEX(stroka-netto, "5/") + 2)), "@")
         else "0")  p-XL-delim
        (IF INDEX(stroka-netto, "6/") > 0
         then ENTRY(1, SUBSTR(stroka-netto, (INDEX(stroka-netto, "6/") + 2)), "@")
         else "0")  p-XL-delim
        (IF INDEX(stroka-netto, "7/") > 0
         then ENTRY(1, SUBSTR(stroka-netto, (INDEX(stroka-netto, "7/") + 2)), "@")
         else "0")  p-XL-delim
        (IF INDEX(stroka-netto, "1/") > 0
         then ENTRY(1, SUBSTR(stroka-netto, (INDEX(stroka-netto, "1/") + 2)), "@")
         else "0")  p-XL-delim
        tot-netto p-XL-delim
        ""          p-XL-delim
       (IF INDEX(stroka-uchet, "2/") > 0
        then ENTRY(1, SUBSTR(stroka-uchet, (INDEX(stroka-uchet, "2/") + 2)), "@")
        else "0")  p-XL-delim
       (IF INDEX(stroka-uchet, "3/") > 0
        then ENTRY(1, SUBSTR(stroka-uchet, (INDEX(stroka-uchet, "3/") + 2)), "@")
        else "0")  p-XL-delim
       (IF INDEX(stroka-uchet, "4/") > 0
        then ENTRY(1, SUBSTR(stroka-uchet, (INDEX(stroka-uchet, "4/") + 2)), "@")
        else "0")  p-XL-delim
       (IF INDEX(stroka-uchet, "5/") > 0
        then ENTRY(1, SUBSTR(stroka-uchet, (INDEX(stroka-uchet, "5/") + 2)), "@")
        else "0")  p-XL-delim
       (IF INDEX(stroka-uchet, "6/") > 0
        then ENTRY(1, SUBSTR(stroka-uchet, (INDEX(stroka-uchet, "6/") + 2)), "@")
        else "0")  p-XL-delim
       (IF INDEX(stroka-uchet, "7/") > 0
        then ENTRY(1, SUBSTR(stroka-uchet, (INDEX(stroka-uchet, "7/") + 2)), "@")
        else "0")  p-XL-delim
       (IF INDEX(stroka-uchet, "1/") > 0
        then ENTRY(1, SUBSTR(stroka-uchet, (INDEX(stroka-uchet, "1/") + 2)), "@")
        else "0")  p-XL-delim
       tot-uchet
       skip(0).
    END.
    current-date = current-date + 7.
END. /*REPEAT*/
IF RS-method = "ARTIC":U THEN DO:
    PUT STREAM PrnLibStream UNFORMATTED
    (IF X-SelectGood = {&g-choice}
     then "ИТОГО_ПО_ВСЕМ_ВЫБРАННЫМ_ТОВАРАМ"
     ELSE "ИТОГО_ПО_ВСЕМ_ТОВАРАМ") p-XL-delim
    "" p-XL-delim
    "" p-XL-delim
    "" p-XL-delim.
END.
ELSE
PUT STREAM PrnLibStream UNFORMATTED
(IF X-SelectGood = {&g-choice}
 then "ИТОГО_ПО_ВСЕМ_ВЫБРАННЫМ_ТОВАРАМ"
 ELSE "ИТОГО_ПО_ВСЕМ_ТОВАРАМ") p-XL-delim.
PUT STREAM PrnLibStream UNFORMATTED
column-qnty[2] p-XL-delim
column-qnty[3] p-XL-delim
column-qnty[4] p-XL-delim
column-qnty[5] p-XL-delim
column-qnty[6] p-XL-delim
column-qnty[7] p-XL-delim
column-qnty[1] p-XL-delim
column-qnty[8] p-XL-delim
"" p-XL-delim
column-netto[2] p-XL-delim
column-netto[3] p-XL-delim
column-netto[4] p-XL-delim
column-netto[5] p-XL-delim
column-netto[6] p-XL-delim
column-netto[7] p-XL-delim
column-netto[1] p-XL-delim
column-netto[8] p-XL-delim
"" p-XL-delim
column-uchet[2] p-XL-delim
column-uchet[3] p-XL-delim
column-uchet[4] p-XL-delim
column-uchet[5] p-XL-delim
column-uchet[6] p-XL-delim
column-uchet[7] p-XL-delim
column-uchet[1] p-XL-delim
column-uchet[8] SKIP(0).
output STREAM PrnLibStream CLOSE.
/*
assign
g#rep-tblname = ""
g#rep-tblrid = -116
g#rep-updflds = "Понедельный отчет по товарам|" + str1.
*/

if X-selectGood = {&g-all} then do:
    for each gds-list:
        delete gds-list.
    end.
end.

run waitfram-hide in this-procedure .

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
  run ini-from-SelectGood.
/*
  if p-state begins "DATE-START" then do:
    my-x-date-start = date(substr(p-state, length(p-state) - 10 + 1)).
    message my-x-date-start "mm".
    run check-dates(input-output my-x-date-start, input-output my-x-date-end, no).
  end.
  if p-state begins "DATE-END" then do:
    my-x-date-end = date(substr(p-state, length(p-state) - 10 + 1)).
    message my-x-date-start "mm".
    run check-dates(input-output my-x-date-start, input-output my-x-date-end, no).
  end.
*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME