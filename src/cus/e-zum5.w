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

ОТЧЕТ ПО ДОКУМЕНТАМ (РЕАЛИЗАЦИЯ В МАГАЗИНЕ)

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/03/04
Author: Bakhtadze Natalya
Creation date: 02/03/04

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
define variable vss-description as character no-undo init "Отчет о налогах в магазине" .
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ cmp/r-page1.i  }
{ gbl/waitfram.i }
{ cmp/doc-list.i doc-list def  "new shared" }
{ cmp/operlist.i }
{ cmp/breakstr.i }
{ gbl/getcntxt.i def " " my-handle }
{ cmp/showinf.i }
define variable Line                as      char    no-undo.
define variable date_string     as      char    no-undo.

define variable     choice               as      logical     no-undo.
define variable     DatePrinted      as      logical     no-undo.
define variable     FrameType      as      char        no-undo.

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
&Scoped-Define ENABLED-OBJECTS RECT-8 RS-by2 RS-By
&Scoped-Define DISPLAYED-OBJECTS RS-by2 RS-By

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE RS-By AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Расход и возврат", 1,
"Расход", 2,
"Возврат от покупателя", 3,
"Списание", 4,
"Выборочно", 5
     SIZE 24.13 BY 12.29 NO-UNDO.

DEFINE VARIABLE RS-by2 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Касса-розница", 1,
"Оптовые", 2,
"Все", 3
     SIZE 16.63 BY 4.08 NO-UNDO.

DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 27.25 BY 14.75.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     RS-by2 AT ROW 2 COL 30.75 NO-LABEL
     RS-By AT ROW 2.5 COL 3.5 NO-LABEL
     "Источник формирования" VIEW-AS TEXT
          SIZE 23.63 BY .83 AT ROW 1.5 COL 3.5
          FGCOLOR 4
     RECT-8 AT ROW 1 COL 2.25
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 47.63 BY 15.


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
         HEIGHT             = 15
         WIDTH              = 49.63.
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

&Scoped-define SELF-NAME RS-By
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-By F-Frame-Win
ON VALUE-CHANGED OF RS-By IN FRAME F-Main
DO:
  ASSIGN
  RS-BY.
  CASE RS-BY:
    when 1 or
    when 2 or
    when 3 then do:
        enable
        rs-by2
        with frame {&frame-name}.
    end.
    when 5 then do:
        disable
        rs-by2
        with frame {&frame-name}.
        run str/doc-list.w (input my-handle , v-cntxt-host-code-obj, v-cntxt-obj-type, v-cntxt-obj-code) no-error.
        find first doc-list no-lock no-error.
        if not available doc-list then do:
          assign
          rs-by = 1.
          display rs-by with frame {&frame-name} .
        end.
    end.
    when 4
    then do:
        disable
        rs-by2
        with frame {&frame-name}.
    end.
  END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK F-Frame-Win


/* ***************************  Main Block  *************************** */
{ gbl/personly.i }
{ gbl/getcntxt.i get " " my-handle }
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
  DISPLAY RS-by2 RS-By
      WITH FRAME F-Main.
  ENABLE RECT-8 RS-by2 RS-By
      WITH FRAME F-Main.
  {&OPEN-BROWSERS-IN-QUERY-F-Main}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE My-report F-Frame-Win
PROCEDURE My-report :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable glog as logical no-undo .
run My-var.
assign
date_string = cur-time-print()
Line = fill( "-", 187 )
.

run waitfram-show in this-procedure ( {&MyWaitMess} ) .
run cus/r-zum5.p (input my-handle
            ,input rs-by
            ,input rs-by2
            ,input X-date-start
            ,input x-date-end
            ,input reportheader) no-error.
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
Assign
frame {&frame-name} RS-by
frame {&frame-name} RS-by2
.
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
Reportname = "ОТЧЕТ ПО ДОКУМЕНТАМ".
ReportHeader =  "Источник формирования: " +
                radio-label(string(RS-BY), RS-BY:radio-buttons) + {&New-line} +
                (if (Rs-by = 1 or Rs-by = 2 or rs-by = 3)
                 then radio-label(string(RS-BY2), RS-BY2:radio-buttons)
                 else "":U)
.

assign

sheetf.colformat =  "4=dd/mm/yyyy;5=dd/mm/yyyy;13=0":U  /*это артикул*/
sheetf.Excel-Column-Lable =
                          "Тип документа"                 + {&comma-char} +
                          "Номер документа"               + {&comma-char} +
                          "Объект"                        + {&comma-char} +
                          "Дата документа"                + {&comma-char} +
                          "Дата факт документа"           + {&comma-char} +
                          "Контрагент"                    + {&comma-char} +
                          "Код оплаты документа"          + {&comma-char} +

                          "Код товара"                    + {&comma-char} +
                          "Бар-код"                        + {&comma-char} +
                          "Название товара"               + {&comma-char} +
                          "Группа товара"                 + {&comma-char} +
                          "Признак шкалы товара"          + {&comma-char} +
                          "Артикул"                       + {&comma-char} +
                          "Производитель"                 + {&comma-char} +
                          "Название производителя"        + {&comma-char} +
                          "Состав сырья"                  + {&comma-char} +
                          "Ед. изм"                       + {&comma-char} +
                          "Количество"                    + {&comma-char} +

                          /*учетная часть*/
                          "Поставщик"                     + {&comma-char} +
                          "Название поставщика"           + {&comma-char} +
                          "Код типа приобертения партии товара"      + {&comma-char} +
                          "Код оплаты партии товара"      + {&comma-char} +
                          "Номер документа поставки"      + {&comma-char} +
                          "Номер партии"                  + {&comma-char} +
                          "Уч цена"                       + {&comma-char} +
                          "Сумма учетных цен"             + {&comma-char} +
                          "Ставка НДС поставщика"         + {&comma-char} +
                          "Сумма НДС поставщика"          + {&comma-char} +

                          /*продажная */
                          "Ставка НДС документа"          + {&comma-char} +
                          "Сумма НДС документа"           + {&comma-char} +
                          "Цена продажи на момент закр. док-та"          + {&comma-char} +
                          "Сумма продажных цен"           + {&comma-char} +
                          "Цена документа"                + {&comma-char} +
                          "Сумма цен по документу"        + {&comma-char} +
                          "Сумма скидки"
sheetf.Sizes =
                          "15"                            + {&comma-char} +
                          "14"                            + {&comma-char} +
                          "8"                             + {&comma-char} +
                          "10"                            + {&comma-char} +
                          "10"                            + {&comma-char} +
                          "12"                            + {&comma-char} +
                          "6"                             + {&comma-char} +

                          "9"                             + {&comma-char} +
                          "9"                             + {&comma-char} +
                          "25"                            + {&comma-char} +
                          "50"                            + {&comma-char} +
                          "25"                            + {&comma-char} +
                          "14"                            + {&comma-char} +
                          "12"                            + {&comma-char} +
                          "25"                            + {&comma-char} +
                          "25"                            + {&comma-char} +
                          "6"                             + {&comma-char} +
                          "12"                            + {&comma-char} +

                          /*учетная часть*/
                          "12"                            + {&comma-char} +
                          "25"                            + {&comma-char} +
                          "2"                             + {&comma-char} +
                          "5"                             + {&comma-char} +
                          "14"                            + {&comma-char} +
                          "20"                            + {&comma-char} +
                          "12"                            + {&comma-char} +
                          "18"                            + {&comma-char} +
                          "6"                             + {&comma-char} +
                          "18"                            + {&comma-char} +

                          /*продажная */
                          "6"                             + {&comma-char} +
                          "18"                            + {&comma-char} +
                          "12"                            + {&comma-char} +
                          "18"                            + {&comma-char} +
                          "12"                            + {&comma-char} +
                          "18"                            + {&comma-char} +
                          "18"
.

For each obj-list no-lock:
 Assign
 STR-obj-type = STR-obj-type + obj-list.obj-type + ','
 STR-obj-code = STR-obj-code + String(obj-list.obj-code) + ','
 STR-obj-name = STR-obj-name + obj-list.obj-name + ','
 STR-obj = STR-obj +  obj-list.obj-type + '#' + string(obj-list.obj-code)  + ',' .
End.
assign
str1 =     "":U
ReportNAme = "Партии товаров по документам "
.


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