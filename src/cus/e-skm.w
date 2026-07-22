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

Выгрузка в файл данных по продажам по СКМ-форма запроса

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/24/04
Author: Bakhtadze Natalya
Creation date: 06/24/04

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
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Выгрузка в файл данных по продажам по СКМ-форма запроса" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/cur-time.i }
{ cmp/r-page1.i  }
{ cmp/r-pril.i }
{ gbl/prn-lib.i }
{ cmp/operlist.i  }
{ gbl/waitfram.i }
{ gbl/usr-flt.i }
define variable parparentproc as widget-handle no-undo .
{ gbl/getcntxt.i def }

define variable State-source as Widget-Handle.


define buffer buf_dis-card-type for ub.dis-card-type.

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
&Scoped-Define ENABLED-OBJECTS RECT-checks B-type f-region-code f-org-code ~
f-shop-code F-substring f-type-name
&Scoped-Define DISPLAYED-OBJECTS f-region-code f-org-code f-shop-code ~
F-substring f-type-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-type
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE VARIABLE f-org-code AS INTEGER FORMAT "9999":U INITIAL 0
     LABEL "Номер организации"
     VIEW-AS FILL-IN
     SIZE 8 BY 1 NO-UNDO.

DEFINE VARIABLE f-region-code AS INTEGER FORMAT "99":U INITIAL 0
     LABEL "Код региона (RR)"
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE f-shop-code AS INTEGER FORMAT "9999":U INITIAL 0
     LABEL "Номер торгового предприятия организации"
     VIEW-AS FILL-IN
     SIZE 8 BY 1 NO-UNDO.

DEFINE VARIABLE F-substring AS INTEGER FORMAT ">9":U INITIAL 0
     LABEL "Порядковый № символа в строке № социальной карты"
     VIEW-AS FILL-IN
     SIZE 8.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-type-name AS CHARACTER FORMAT "X(8)"
     LABEL "Тип карты, соответствующий СКМ, в системе"
      VIEW-AS TEXT
     SIZE 12.63 BY 1 TOOLTIP "Тип карты"
     FGCOLOR 4 .

DEFINE RECTANGLE RECT-checks
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 62.38 BY 10.25.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     B-type AT ROW 2 COL 60
     f-region-code AT ROW 4 COL 21 COLON-ALIGNED
     f-org-code AT ROW 5.75 COL 20 COLON-ALIGNED
     f-shop-code AT ROW 7 COL 42 COLON-ALIGNED
     F-substring AT ROW 8.75 COL 3
     f-type-name AT ROW 2 COL 2.5
     "с которого начинается социальный № (RR##########)" VIEW-AS TEXT
          SIZE 50.5 BY 1 AT ROW 10 COL 3.5
     RECT-checks AT ROW 1.25 COL 1.5
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 63.88 BY 10.92.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartObject
   Allow: Basic,Browse,DB-Fields,Smart,Query
   Container Links:
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB)
  CREATE WINDOW F-Frame-Win ASSIGN
         HEIGHT             = 10.88
         WIDTH              = 64.5.
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
/* SETTINGS FOR FILL-IN F-substring IN FRAME F-Main
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-type-name IN FRAME F-Main
   ALIGN-L                                                              */
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

&Scoped-define SELF-NAME B-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-type F-Frame-Win
ON CHOOSE OF B-type IN FRAME F-Main
DO:
 run proc-b-type no-error.
 if error-status:error then return no-apply.



END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK F-Frame-Win


/* ***************************  Main Block  *************************** */
{ gbl/personly.i }
parparentproc = my-handle.
{ gbl/getcntxt.i get }
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
  DISPLAY f-region-code f-org-code f-shop-code F-substring f-type-name
      WITH FRAME F-Main.
  ENABLE RECT-checks B-type f-region-code f-org-code f-shop-code F-substring
         f-type-name
      WITH FRAME F-Main.
  {&OPEN-BROWSERS-IN-QUERY-F-Main}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize F-Frame-Win
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
run uf-get in this-procedure(
     input  {&uf-skm-rep}
    ,input  v-cntxt-userid
    ,output v-uf-List_
    ,output v-uf-Naim
    ,output v-uf-print-graft
    ,output v-uf-sort-gr
    ,output v-uf-type-price
    ,output v-uf-type-val
)  no-error.

if not error-status:error
and num-entries(v-uf-List_, {&delim-par}) = 5 then do:
  assign
  f-type-name = entry(1, v-uf-List_, {&delim-par})
  f-region-code = integer(entry(2, v-uf-List_, {&delim-par}))
  f-org-code = integer(entry(3, v-uf-List_, {&delim-par}))
  f-shop-code = integer(entry(4, v-uf-List_, {&delim-par}))
  f-substring = integer(entry(5, v-uf-List_, {&delim-par}))
  NO-ERROR
  .
  FIND FIRST buf_dis-card-type NO-LOCK WHERE
            buf_dis-card-type.emitent-host-code = 0
         AND buf_dis-card-type.TYPE = f-type-name NO-ERROR.
  IF NOT AVAILABLE buf_dis-card-type THEN DO:
     MESSAGE
     "Неверные сохраненные данные по умолчанию для запуска выгрузки данных" SKIP
     "Нет глобального типа карт" f-type-name
     VIEW-AS ALERT-BOX ERROR.
     RETURN ERROR.
  END.
end.
RUN enable_UI IN THIS-PROCEDURE.
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
DEFINE VARIABLE v-sum-brutto AS DECIMAL NO-UNDO.
DEFINE VARIABLE v-sum-discnt AS DECIMAL NO-UNDO.
DEFINE VARIABL v-curr-r-b LIKE ub.currency.curr-code NO-UNDO.
DEFINE VARIABL v-exch AS DECIMAL NO-UNDO.
DEFINE VARIABL v-host-code LIKE ub.sysconf.host-code NO-UNDO.
define variable v-err-format as integer no-undo .
define variable v-is-err as logical no-undo .
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_dis-card for ub.dis-card.
 DEFINE BUFFER buf_Curr-shop FOR ub.curr-shop.

do
on error undo, return error
:
  /*найдем fact-order 1990 года*/
  assign
  Sheetf.ColFOrmat = '6=dd/mm/yyyy;7=0;8=0' + {&delim-par} + '7=@;8=@'
  .
  run waitfram-show in this-procedure ("Ждите...").
  assign
  sheetf.Excel-Column-Lable =
  "Код региона"  + {&comma-char} +
  "№ Организации"  + {&comma-char} +
  "№ торгового предприятия Организации"  + {&comma-char} +
  "№ кассы"  + {&comma-char} +
  "№ чека"  + {&comma-char} +
  "Дата чека"  + {&comma-char} +
  "Время чека"  + {&comma-char} +
  "Социальный номер"  + {&comma-char} +
  "Стоимость купленных товаров"  + {&comma-char} +
  "Скидка"  + {&comma-char} +
  "Несоответствие сумм формату выгрузки"
     sheetf.sizes =
  "12"  + {&comma-char} +
  "12"  + {&comma-char} +
  "12"  + {&comma-char} +
  "6"  + {&comma-char} +
  "20"  + {&comma-char} +
  "10"  + {&comma-char} +
  "10"  + {&comma-char} +
  "12"  + {&comma-char} +
  "12"  + {&comma-char} +
  "12"  + {&comma-char} +
  "12"
  str3 = " "
  .

run prn-lib-open-stream  in this-procedure (
                                            input parparentproc
                                            ,input 0
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).

  run rep/extitle.p (1) .

  FOR EACH obj-list No-LOCK:
   { gbl/hostcode.i obj-list.obj-type obj-list.obj-code v-host-code }
    /*узнаем r-b*/
   { gbl/r-b-curr.i v-host-code v-curr-r-b }
   IF v-curr-r-b = 0 THEN v-exch = 1.
   ELSE v-exch = ?.
  _chk-gds:
    FOR EACH buf_chk-doc No-LOCK WHERE
              buf_chk-doc.obj-type = obj-list.obj-type AND
              buf_chk-doc.obj-code = obj-list.obj-code AND
              buf_chk-doc.out-code <> ? AND
              buf_chk-doc.d-card <> "":U AND
              buf_chk-doc.chk-date >= X-date-start AND
              buf_chk-doc.chk-date <= X-date-end,
      FIRST buf_dis-card NO-LOCK WHERE
            buf_dis-card.d-card = buf_chk-doc.d-card
       AND  buf_dis-card.emitent-host-code  = 0
       AND  buf_dis-card.TYPE = f-type-name:
      if lookup(string(buf_chk-doc.chk-type), {&no-sale-receipt-codes}) > 0
      or buf_chk-doc.chk-type = integer({&rcpt-write-off})
      then next _chk-gds.
      IF v-exch = 1 THEN DO:
          ASSIGN
          v-sum-brutto = buf_chk-doc.tot-doc
          v-sum-discnt = buf_chk-doc.discnt
          .
      END.
      ELSE DO:
          IF buf_chk-doc.cash-rate <> ?  AND buf_chk-doc.cash-scale <> ? THEN DO:
            ASSIGN
              v-sum-brutto = buf_chk-doc.tot-doc * buf_chk-doc.cash-rate / buf_Chk-doc.cash-scale
              v-sum-discnt = buf_chk-doc.discnt * buf_chk-doc.cash-rate / buf_Chk-doc.cash-scale
              .
          END.
          ELSE DO:
            FIND LAST buf_curr-shop NO-LOCK Where
                     buf_curr-shop.obj-type = buf_chk-doc.obj-type AND
                    buf_curr-shop.obj-code  = buf_chk-doc.obj-code AND
                    buf_curr-shop.curr-code = v-curr-r-b AND
                   ( ( buf_curr-shop.exch-date = buf_chk-doc.chk-date AND
                   buf_curr-shop.exch-time <= buf_chk-doc.chk-time ) OR
                   buf_curr-shop.exch-date < buf_chk-doc.chk-date ) NO-ERROR .
            IF AVAILABLE buf_curr-shop  THEN DO:
              ASSIGN
              v-sum-brutto = buf_chk-doc.tot-doc * buf_curr-shop.exch-rate / buf_curr-shop.exch-scale
              v-sum-discnt = buf_chk-doc.discnt * buf_curr-shop.exch-rate / buf_curr-shop.exch-scale
              .


            END.
          END.
      END.
      if buf_chk-doc.tot-doc < - 99999.99
      or buf_chk-doc.tot-doc >  999999.99
      or buf_chk-doc.discnt < - 99999.99
      or buf_chk-doc.discnt > 999999.99 then do:
        assign
        v-err-format = v-err-format + 1
        v-is-err = yes
        .
      end.
      else do:
        assign
        v-is-err = no.
      end.
      accumulate buf_Chk-doc.doc-code (COUNT).
      PUT STREAM PrnLibStream UNFORMATTED
      f-region-code  FORMAT "99":U {&space-char}
      f-org-code  FORMAT "9999":U {&space-char}
      f-shop-code  FORMAT "9999":U {&space-char}
      buf_chk-doc.pay-desk FORMAT "99" {&space-char}
      buf_chk-doc.chk-num FORMAT  "999999" {&space-char}
      string(buf_chk-doc.chk-date, "99/99/9999") {&space-char}
      string(buf_chk-doc.chk-time, "hh:mm")      {&space-char}
      substring(STRING(buf_chk-doc.src-d-card), f-substring, 12) FORMAT "x(12)" {&space-char}
      .
      if buf_chk-doc.tot-doc < 0 then
      PUT STREAM PrnLibStream UNFORMATTED
      buf_chk-doc.tot-doc FORMAT "-99999.99" {&space-char}
      buf_chk-doc.discnt FORMAT "-99999.99" {&space-char}
      "000000.00"
      SKIP
      .
      else
      PUT STREAM PrnLibStream UNFORMATTED
      buf_chk-doc.tot-doc FORMAT "999999.99" {&space-char}
      buf_chk-doc.discnt FORMAT "999999.99" {&space-char}
      "000000.00"
      SKIP
      .


      {&PUTExcel}
      f-region-code  FORMAT "99":U {&tabulation}
      f-org-code  FORMAT "9999":U {&tabulation}
      f-shop-code  FORMAT "9999":U {&tabulation}
      buf_chk-doc.pay-desk FORMAT "99" {&tabulation}
      buf_chk-doc.chk-num FORMAT  "999999" {&tabulation}
      string(buf_chk-doc.chk-date, "99/99/9999") {&tabulation}
      ({&delim-par} + string(buf_chk-doc.chk-time, "hh:mm"))      {&tabulation}
      ({&delim-par} + substring(STRING(buf_chk-doc.src-d-card), f-substring, 12)) FORMAT "x(13)" {&tabulation}
      buf_chk-doc.tot-doc FORMAT "-999999.99" {&tabulation}
      buf_chk-doc.discnt FORMAT "-999999.99" {&tabulation}
      string(v-is-err, "Да/нет")
      SKIP
      .
    IF (ACCUM COUNT buf_chk-doc.doc-code) MODULO 50 = 0 then
    run waitfram-show in this-procedure ("Ждите..." + "Объект " + string(obj-list.obj-code) + " Обработано " +
                  string(ACCUM COUNT buf_chk-doc.doc-code) + " чеков").

    END.  /*FOR EACH buf_chk-doc*/
END. /*FOR EACH OBJ-LIST*/
  output stream PrnLibStream CLOSE .
  {&CloseExcel}

end.
run waitfram-hide in this-procedure.
IF (ACCUM COUNT buf_chk-doc.doc-code) > v-err-format THEN DO:
    RUN prn-lib-prn-file in this-procedure (
                                              input  parparentproc
                                              ,input 0
                                              ).

END.
ELSE DO:
  if v-err-format = 0 then do:
    MESSAGE
    "Не было продаж по СКМ на выбранных объектах за выбранный пeриод времени"
    VIEW-AS ALERT-BOX.
  end.
  else do:
    MESSAGE
    "Нет данных для выгрузки в файл - чеков по СКМ на выбранных объектах за выбранный пeриод времени &1," +
    "&2невозможно выгрузить из-за несоответствия сумм форматам выгрузки - &3"
    VIEW-AS ALERT-BOX.
  end.
END.

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
 assign
 FRAME {&frame-name} f-type-name
 f-org-code f-region-code f-shop-code f-substring
 .

 if f-org-code = 0
 or f-region-code = 0
 or f-shop-code = 0
 or f-type-name = "":U then do:
  message
  "Вы не ввели параметры для формирования файлы данных продажам" skip(1)
  (if f-type-name  = "":U
   then ("Введите тип карты, соответствующий СКМ"  + {&new-line})
   else "":U)
  (if f-org-code  = 0
   then ("Введите номер Организации"  + {&new-line})
   else "":U)
  (if f-shop-code  = 0
   then ("Введите номер торгового предприятия"  + {&new-line})
   else "":U)
  (if f-region-code  = 0
   then ("Введите код региона"  + {&new-line})
   else "":U)
   view-as alert-box error .
   return error .
 end.
 assign
 v-uf-list_ = f-type-name + {&delim-par} +
             string(f-region-code, "9999":U) +  {&delim-par} +
             string(f-org-code, "9999":U) +  {&delim-par} +
             string(f-shop-code, "9999":U) + {&delim-par} +
             string(f-substring)

.
/* тип карты, соответсвующей СКМ  "X(8)"
код регина "99"
код Организации "9999"
код торгового предприятия "9999"
символ с которого вырезать из номер - например из ПОЛНОГО номера  9643907768247200011 надо ввырезать с  6 символа по 18
*/
  run uf-set in this-procedure(
    input  {&uf-skm-rep}
    ,input  v-cntxt-userid
    ,input v-uf-List_
    ,input v-uf-Naim
    ,input v-uf-print-graft
    ,input v-uf-sort-gr
    ,input v-uf-type-price
    ,input v-uf-type-val
)  no-error .


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
ReportHeader =
               "Тип карты в системе:" + {&space-char} + f-type-name + {&NEW-LINE} +
               "Номер Организации:" + {&space-char} + string(f-org-code, "9999":U) + {&NEW-LINE} +
               "Номер торгового предприятия Организации:" + {&space-char} + string(f-shop-code, "9999":U)
                .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-type F-Frame-Win
PROCEDURE proc-b-type :
define variable var-rid-str as character no-undo.
define buffer b_clients for ub.clients.
define variable choice as integer.
if avail buf_dis-card-type then do:
  var-rid-str = string(recid(buf_dis-card-type)).
end.
/*этот отчет только для ГЛОБАЛЬНОЙ КАРТЫ - СКМ такая*/
run ref/dc-types.w (
                input parparentproc
              , input {&all}
              , input "b-sel":U
              , input 0 /*buf_dis-card-type.emititent-host-code*/
              , input v-cntxt-host-code-obj
              , input v-cntxt-obj-type
              , input v-cntxt-obj-code
              , input-output  var-rid-str) .
if var-rid-str = "" then return no-apply.
find first buf_dis-card-type no-lock where
           recid(buf_dis-card-type) = integer(var-rid-str) No-ERROR.
if not avail buf_dis-card-type then return error.
ASSIGN
f-type-name = buf_dis-card-type.TYPE
.
DISPLAY
f-type-name
WITH FRAME {&FRAME-NAME}.
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
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME