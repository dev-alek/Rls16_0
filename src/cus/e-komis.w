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

Реализация комиссионного товара-интерфейс

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/28/05
Author: Bakhtadze Natalya
Creation date: 12/28/05

*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

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
define variable vss-description as character no-undo init "Реализация комиссионного товара-интерфейс" .
{ cmp/vssrevis.i }

{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/r-page1.i }
{ cmp/library.i }
{ cmp/operlist.i }
{ cmp/cli-list.i cli-list def "new shared" }
{ gbl/getcntxt.i def " " my-handle }

DEFINE VARIABLE cli-list                  as char         no-undo.
Define buffer cli_supp for ub.clients .
define new shared variable str-supp as character no-undo.
define new shared variable str-supp-name as character no-undo.

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
&Scoped-Define ENABLED-OBJECTS RECT-parts RECT-purpose RECT-columns ~
RECT-supp RECT-by RS-purpose T-prod T-price-without-tax-cost ~
T-sum-without-tax-cost button-supp T-sum-VAT-cost E-supp ~
T-price-without-tax-sale T-sum-without-tax-sale T-sum-VAT-sale RS-By ~
T-sum-SLT-sale T-sum-with-tax-sale T-parts
&Scoped-Define DISPLAYED-OBJECTS RS-purpose T-prod T-price-without-tax-cost ~
T-sum-without-tax-cost T-sum-VAT-cost E-supp T-sum-with-tax-cost ~
T-price-without-tax-sale T-sum-without-tax-sale T-sum-VAT-sale ~
T-price-without-slt-sale RS-By T-sum-SLT-sale T-sum-with-tax-sale T-parts

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON button-supp
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "button-sup"
     SIZE 3 BY .88.

DEFINE VARIABLE E-supp AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 41.75 BY 2.83 NO-UNDO.

DEFINE VARIABLE RS-By AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Отчеты о продаже (касса)", 1,
"Расх./возвр. накл. по реализ. (некасс.)", 2,
"Внешние расх. накл. (не реал.) и спис. пр-ва", 3,
"ВСЕ расх/возвр накладные и списание", 4
     SIZE 46.75 BY 3.38 NO-UNDO.

DEFINE VARIABLE RS-purpose AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Отчет по одному поставщику", 1,
"Отчет по списку поставщиков", 2
     SIZE 34.38 BY 1.67 NO-UNDO.

DEFINE RECTANGLE RECT-by
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 47.75 BY 5.08.

DEFINE RECTANGLE RECT-columns
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 29.25 BY 10.88.

DEFINE RECTANGLE RECT-parts
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 29.25 BY 2.21.

DEFINE RECTANGLE RECT-purpose
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 47.75 BY 2.25.

DEFINE RECTANGLE RECT-supp
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 47.75 BY 4.83.

DEFINE VARIABLE T-neg AS LOGICAL INITIAL no
     LABEL "Отрицательную наценку считать = 0"
     VIEW-AS TOGGLE-BOX
     SIZE 24.63 BY 1.04 NO-UNDO.

DEFINE VARIABLE T-parts AS LOGICAL INITIAL no
     LABEL "Каждую партию отд. строкой"
     VIEW-AS TOGGLE-BOX
     SIZE 27 BY 1.04 NO-UNDO.

DEFINE VARIABLE T-price-without-slt-sale AS LOGICAL INITIAL yes
     LABEL "Сумма товаров без НП"
     VIEW-AS TOGGLE-BOX
     SIZE 27 BY .67 NO-UNDO.

DEFINE VARIABLE T-price-without-tax-cost AS LOGICAL INITIAL yes
     LABEL "Учетная цена без НДС"
     VIEW-AS TOGGLE-BOX
     SIZE 27 BY .67 NO-UNDO.

DEFINE VARIABLE T-price-without-tax-sale AS LOGICAL INITIAL yes
     LABEL "Цена ед. изм. без налога"
     VIEW-AS TOGGLE-BOX
     SIZE 27 BY .67 NO-UNDO.

DEFINE VARIABLE T-prod AS LOGICAL INITIAL yes
     LABEL "Производитель"
     VIEW-AS TOGGLE-BOX
     SIZE 27 BY .67 NO-UNDO.

DEFINE VARIABLE T-sum-SLT-sale AS LOGICAL INITIAL yes
     LABEL "НП"
     VIEW-AS TOGGLE-BOX
     SIZE 27 BY .67 NO-UNDO.

DEFINE VARIABLE T-sum-VAT-cost AS LOGICAL INITIAL yes
     LABEL "НДС поставщика"
     VIEW-AS TOGGLE-BOX
     SIZE 27 BY .67 NO-UNDO.

DEFINE VARIABLE T-sum-VAT-sale AS LOGICAL INITIAL yes
     LABEL "НДС"
     VIEW-AS TOGGLE-BOX
     SIZE 27 BY .67 NO-UNDO.

DEFINE VARIABLE T-sum-with-tax-cost AS LOGICAL INITIAL yes
     LABEL "Сумма учетных цен"
     VIEW-AS TOGGLE-BOX
     SIZE 27 BY .67 NO-UNDO.

DEFINE VARIABLE T-sum-with-tax-sale AS LOGICAL INITIAL yes
     LABEL "Сумма"
     VIEW-AS TOGGLE-BOX
     SIZE 27 BY .67 NO-UNDO.

DEFINE VARIABLE T-sum-without-tax-cost AS LOGICAL INITIAL yes
     LABEL "Сумма учет. цен без НДС"
     VIEW-AS TOGGLE-BOX
     SIZE 27 BY .67 NO-UNDO.

DEFINE VARIABLE T-sum-without-tax-sale AS LOGICAL INITIAL yes
     LABEL "Сумма товаров без налога"
     VIEW-AS TOGGLE-BOX
     SIZE 27 BY .67 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     RS-purpose AT ROW 1.58 COL 2.38 NO-LABEL
     T-prod AT ROW 1.79 COL 50.38
     T-price-without-tax-cost AT ROW 2.75 COL 50.38
     T-sum-without-tax-cost AT ROW 3.67 COL 50.38
     button-supp AT ROW 4.21 COL 40.13
     T-sum-VAT-cost AT ROW 4.63 COL 50.38
     E-supp AT ROW 5.38 COL 1.88 NO-LABEL
     T-sum-with-tax-cost AT ROW 5.5 COL 50.38
     T-price-without-tax-sale AT ROW 6.38 COL 50.38
     T-sum-without-tax-sale AT ROW 7.29 COL 50.38
     T-sum-VAT-sale AT ROW 8.25 COL 50.38
     T-price-without-slt-sale AT ROW 9.21 COL 50.38
     RS-By AT ROW 9.92 COL 1.75 NO-LABEL
     T-sum-SLT-sale AT ROW 10.13 COL 50.38
     T-sum-with-tax-sale AT ROW 11.04 COL 50.38
     T-parts AT ROW 13.13 COL 51
     T-neg AT ROW 13.13 COL 52.88
     "Источник формирования" VIEW-AS TEXT
          SIZE 34.63 BY .83 AT ROW 8.88 COL 1.63
          FGCOLOR 4
     "Выбор поставщика(-ов)" VIEW-AS TEXT
          SIZE 22.13 BY .88 AT ROW 4.29 COL 2
          FGCOLOR 4
     RECT-parts AT ROW 12.42 COL 49.25
     RECT-purpose AT ROW 1.25 COL 1.25
     RECT-columns AT ROW 1.25 COL 49.25
     RECT-supp AT ROW 3.71 COL 1.25
     RECT-by AT ROW 8.63 COL 1.25
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 77.88 BY 15.


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
         WIDTH              = 77.88.
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
ASSIGN
       E-supp:READ-ONLY IN FRAME F-Main        = TRUE.

/* SETTINGS FOR TOGGLE-BOX T-neg IN FRAME F-Main
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       T-neg:HIDDEN IN FRAME F-Main           = TRUE.

/* SETTINGS FOR TOGGLE-BOX T-price-without-slt-sale IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR TOGGLE-BOX T-sum-with-tax-cost IN FRAME F-Main
   NO-ENABLE                                                            */
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

&Scoped-define SELF-NAME button-supp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL button-supp F-Frame-Win
ON CHOOSE OF button-supp IN FRAME F-Main /* button-sup */
DO:
  CASE rs-purpose:
    when  1 then do:
      run ref/cli-all.w (   input my-handle
                      ,input "b-sel"
                      ,input {&all}
                      ,input {&all}
                      ,input {&current}
                      ,input (if avail cli_supp then recid(cli_supp) else ?)
                      ,input ",,,,,,NO,,"
                      ,input ?
                      , output cli-list ) .
      if cli-list <> ""
      then do:
        FIND FIRST cli_supp WHERE recid( cli_supp ) = int( cli-list ) NO-LOCK .
        assign
        E-supp:screen-value = cli_supp.obj-name.
      end.
      else do:
        assign
        E-supp:screen-value = "".
      end.
    end.
    when 2 then do:
      run str/cli-list.w (my-handle, v-cntxt-host-code-obj, v-cntxt-obj-type, v-cntxt-obj-code).
      run get-str-supp in this-procedure .
      assign
      E-supp:screen-value = str-supp-name.
    end.
  END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-purpose
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-purpose F-Frame-Win
ON VALUE-CHANGED OF RS-purpose IN FRAME F-Main
DO:
  assign
  RS-purpose.
  CASE rs-purpose:
    when 1 then do:
      if available cli_supp then do:
        assign
        E-supp:screen-value = cli_supp.obj-name.
      end.
      else do:
        assign
        E-supp:screen-value = "".
      end.
      display
      T-parts
      T-price-without-slt-sale
      T-price-without-tax-cost
      T-price-without-tax-sale
      T-prod
      T-sum-SLT-sale
      T-sum-VAT-cost
      T-sum-VAT-sale
      T-sum-without-tax-cost
      T-sum-without-tax-sale
      T-sum-with-tax-cost
      T-sum-with-tax-sale
      RECT-columns
      RECT-parts
      with frame {&frame-name}.
    end.
    when 2 then do:
      assign
      E-supp:screen-value = str-supp-name.
      HIDE
      T-parts
      T-price-without-slt-sale
      T-price-without-tax-cost
      T-price-without-tax-sale
      T-prod
      T-sum-SLT-sale
      T-sum-VAT-cost
      T-sum-VAT-sale
      T-sum-without-tax-cost
      T-sum-without-tax-sale
      T-sum-with-tax-cost
      T-sum-with-tax-sale
      RECT-columns
      RECT-parts
      in frame {&frame-name}.
    end.
  END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-parts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-parts F-Frame-Win
ON VALUE-CHANGED OF T-parts IN FRAME F-Main /* Каждую партию отд. строкой */
DO:
    ASSIGN {&self-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-price-without-slt-sale
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-price-without-slt-sale F-Frame-Win
ON VALUE-CHANGED OF T-price-without-slt-sale IN FRAME F-Main /* Сумма товаров без НП */
DO:
    ASSIGN {&self-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-price-without-tax-cost
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-price-without-tax-cost F-Frame-Win
ON VALUE-CHANGED OF T-price-without-tax-cost IN FRAME F-Main /* Учетная цена без НДС */
DO:
    ASSIGN {&self-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-price-without-tax-sale
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-price-without-tax-sale F-Frame-Win
ON VALUE-CHANGED OF T-price-without-tax-sale IN FRAME F-Main /* Цена ед. изм. без налога */
DO:
    ASSIGN {&self-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-prod
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-prod F-Frame-Win
ON VALUE-CHANGED OF T-prod IN FRAME F-Main /* Производитель */
DO:
  ASSIGN {&self-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-sum-SLT-sale
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-sum-SLT-sale F-Frame-Win
ON VALUE-CHANGED OF T-sum-SLT-sale IN FRAME F-Main /* НП */
DO:
    ASSIGN {&self-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-sum-VAT-cost
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-sum-VAT-cost F-Frame-Win
ON VALUE-CHANGED OF T-sum-VAT-cost IN FRAME F-Main /* НДС поставщика */
DO:
    ASSIGN {&self-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-sum-VAT-sale
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-sum-VAT-sale F-Frame-Win
ON VALUE-CHANGED OF T-sum-VAT-sale IN FRAME F-Main /* НДС */
DO:
    ASSIGN {&self-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-sum-with-tax-cost
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-sum-with-tax-cost F-Frame-Win
ON VALUE-CHANGED OF T-sum-with-tax-cost IN FRAME F-Main /* Сумма учетных цен */
DO:
    ASSIGN {&self-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-sum-with-tax-sale
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-sum-with-tax-sale F-Frame-Win
ON VALUE-CHANGED OF T-sum-with-tax-sale IN FRAME F-Main /* Сумма */
DO:
    ASSIGN {&self-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-sum-without-tax-cost
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-sum-without-tax-cost F-Frame-Win
ON VALUE-CHANGED OF T-sum-without-tax-cost IN FRAME F-Main /* Сумма учет. цен без НДС */
DO:
    ASSIGN {&self-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-sum-without-tax-sale
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-sum-without-tax-sale F-Frame-Win
ON VALUE-CHANGED OF T-sum-without-tax-sale IN FRAME F-Main /* Сумма товаров без налога */
DO:
    ASSIGN {&self-name}.

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
  DISPLAY RS-purpose T-prod T-price-without-tax-cost T-sum-without-tax-cost
          T-sum-VAT-cost E-supp T-sum-with-tax-cost T-price-without-tax-sale
          T-sum-without-tax-sale T-sum-VAT-sale T-price-without-slt-sale RS-By
          T-sum-SLT-sale T-sum-with-tax-sale T-parts
      WITH FRAME F-Main.
  ENABLE RECT-parts RECT-purpose RECT-columns RECT-supp RECT-by RS-purpose
         T-prod T-price-without-tax-cost T-sum-without-tax-cost button-supp
         T-sum-VAT-cost E-supp T-price-without-tax-sale T-sum-without-tax-sale
         T-sum-VAT-sale RS-By T-sum-SLT-sale T-sum-with-tax-sale T-parts
      WITH FRAME F-Main.
  {&OPEN-BROWSERS-IN-QUERY-F-Main}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-str-supp F-Frame-Win
PROCEDURE get-str-supp :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
 Assign
 STR-supp-name = "":U
 STR-supp = "":U
 .
For each cli-list no-lock:
 Assign
 STR-supp-name = STR-supp-name + cli-list.obj-name + {&new-line}
 STR-supp = STR-supp +  cli-list.obj-type + '#' + string(cli-list.obj-code)  + ',' .
End.

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
  APPLY "VALUE-CHANGED" to RS-purpose in frame {&frame-name}.
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
DEFINE VARIABLE v-report-header as character no-undo .
DEFINE VARIABLE v-frame-width as integer no-undo .
define variable glog as logical no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-host-name like ub.clients.obj-name no-undo .
run My-var.
CASE rs-purpose:
  when 1 then do:
    if NOT avail cli_supp then do:
      message "Не выбран поставщик"
      view-as alert-box ERROR.
      return.
    end.
    glog = no.

    assign
    /*NN*/
    use-column[1] = yes
    /*artic*/
    use-column[2] = yes
    /*gds-name*/
    use-column[3] = yes
    /*prod*/
    use-column[4] = T-prod
    /*ед изм*/
    use-column[5] = yes
    /*кол-во*/
    use-column[6] = yes
    use-column[7] = T-price-without-tax-cost
    use-column[8] = T-sum-without-tax-cost
    use-column[9] = T-sum-VAT-cost
    use-column[10] = T-sum-with-tax-cost
    use-column[11] = T-price-without-tax-sale
    use-column[12] = T-sum-without-tax-sale
    use-column[13] = T-sum-VAT-sale
    use-column[14] = T-price-without-slt-sale
    use-column[15] = T-sum-SLT-sale
    use-column[16] = T-sum-with-tax-sale
    frame {&frame-name} RS-by
    .
    { gbl/hostname.i v-cntxt-obj-type v-cntxt-obj-code v-host-code v-host-name }
    assign
    ReportHeader = "":U
    ReportName = "Отчет"
    str1 =  "о продаже товаров принятых на комиссию" + {&space-char} +
            v-host-name + {&space-char} +
            "от фирмы" + {&space-char} +
            (if available cli_supp
              then cli_supp.obj-name
              else "( поставщик не определен) ")
    str2 =    "за период с" + {&space-char} + string(X-date-start, "99/99/9999") + {&space-char}  +
              "по" + {&space-char} + string(X-date-end, "99/99/9999") + {&space-char} +
              "произведена продажа следующего товара"
    str3 =  "Источник формирования: " +
                radio-label(string(RS-BY), RS-BY:radio-buttons)
    str4 = "":U
    v-report-header = ReportName + {&new-line} +
                      str1 + {&new-line} +
                      str2 + {&new-line} +
                      str3
                      .


    run cus/r-komis.p (
                   input my-handle
                  ,input v-host-name
                  ,input cli_supp.obj-type
                  ,input cli_supp.obj-code
                  ,input cli_supp.obj-name
                  ,input RS-by
                  ,input T-parts
                  ,input v-report-header
                  ,output v-frame-width
                  ).
  end.
  when 2 then do:
    if not can-find( first cli-list no-lock) then do:
      message "Не выбрано ни одного поставщика"
      view-as alert-box ERROR.
      return.
    end.

    assign
    ReportHeader = "":U
    str3 =  "Источник формирования: " +
             radio-label(string(RS-BY), RS-BY:radio-buttons)
    ReportName = "Акт о реализации комиссионного товара"
    v-report-header = ReportName + {&new-line} +
                      str1 + {&new-line} +
                      str4 + {&new-line} +
                      "Источник формирования: " +
                      radio-label(string(RS-BY), RS-BY:radio-buttons)
                      .

    run cus/r-komisl.p (
                   input my-handle
                  ,input v-host-name
                  ,input RS-by
                  ,input v-report-header
                  ,output v-frame-width
                  ).

  end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE My-var F-Frame-Win
PROCEDURE My-var :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-----------------------------------------------------------------------------*/
Assign
frame {&frame-name} T-neg
frame {&frame-name} T-parts
frame {&frame-name} RS-by
frame {&frame-name} RS-purpose
frame {&frame-name} T-price-without-slt-sale
frame {&frame-name} T-price-without-tax-cost
frame {&frame-name} T-price-without-tax-sale
frame {&frame-name} T-sum-SLT-sale
frame {&frame-name} T-sum-VAT-cost
frame {&frame-name} T-sum-VAT-sale
frame {&frame-name} T-sum-without-tax-cost
frame {&frame-name} T-sum-without-tax-sale
frame {&frame-name} T-sum-with-tax-cost
frame {&frame-name} T-sum-with-tax-sale
frame {&frame-name} T-prod
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
run get-str-supp in this-procedure .
Reportname = "РЕАЛИЗАЦИЯ КОМИССИОННОГО ТОВАРА".
ReportHeader =  "Источник формирования: " +
                radio-label(string(RS-BY), RS-BY:radio-buttons) + {&New-line} +
                (if RS-purpose = 1 then
                ("Поставщик: " +
                (if available cli_supp
                  then cli_supp.obj-name
                  else "( поставщик не определен) "))
                  else str-supp) +
                {&New-line} +
                (if T-neg then t-neg:label else "") + {&new-line} +
                (if T-parts then t-parts:label else "")                .

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

