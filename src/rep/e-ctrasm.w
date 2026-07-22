&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS s-object
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отчет "Контроль АМ" (ЗАКЛАДКА №2)

Автор: Комаров Иван Сергеевич
Дата создания: 07/12/10
Author: Ivan Komarov
Creation date: 07/12/10

Автор1: Хныкин Павел Андреевич
Дата создания1: 07/28/09

*/
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Декларация об объемах розничной продажи алкогольной продукции (ЗАКЛАДКА №2)".
{ cmp/vssrevis.i  }
{ cmp/str-glbl.i  }
{ cmp/r-page1.i   }
{ rep/rep-bt.i    }
{ gbl/usr-flt.i   }

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

def var state-source                      as  widget-handle.
define variable loc-ref-list              as character no-undo .
define variable v-profile-id              as integer   no-undo .
define variable v-gds-by-am               as logical   no-undo.
define variable v-days-wt-goods           as integer   no-undo .
define variable v-gds-qnty                as decimal   no-undo .
define variable v-critical-qnty-balance   as decimal   no-undo .
define variable v-critical-qnty-sale      as decimal   no-undo .
define variable v-critical-qnty-order     as decimal   no-undo .
define variable v-group-by-post           as logical   no-undo .
define variable v-group-by-order          as logical   no-undo .
define variable v-detailed                as logical   no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartViewer
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-8 RECT-9 RECT-10 tg-gds-by-am ~
tg-group-by-order fi-days-wt-goods fi-critical-qnty-balance ~
fi-critical-qnty-sale fi-critical-qnty-order tog-1 tog-2 tog-3 tog-4 tog-5 ~
tog-6 
&Scoped-Define DISPLAYED-OBJECTS tg-gds-by-am tg-group-by-order ~
fi-days-wt-goods fi-critical-qnty-balance fi-critical-qnty-sale ~
fi-critical-qnty-order tog-1 tog-2 tog-3 tog-4 tog-5 tog-6 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE fi-critical-qnty-balance AS DECIMAL FORMAT ">>>,>>>,>>9.99":U INITIAL 0
     LABEL "Критический остаток"
     VIEW-AS FILL-IN
     SIZE 7.5 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE fi-critical-qnty-order AS DECIMAL FORMAT ">>>,>>>,>>9.99":U INITIAL 0
     LABEL "Критический заказ"
     VIEW-AS FILL-IN
     SIZE 7.5 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE fi-critical-qnty-sale AS DECIMAL FORMAT ">>>,>>>,>>9.99":U INITIAL 0
     LABEL "Критическая продажа"
     VIEW-AS FILL-IN
     SIZE 7.5 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE fi-days-wt-goods AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0
     LABEL "Количество дней без товара"
     VIEW-AS FILL-IN
     SIZE 7.5 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE fi-gds-qnty AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     LABEL "Кол-во отсутствующего товара"
     VIEW-AS FILL-IN
     SIZE 7.5 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE RECTANGLE RECT-10
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 32.5 BY 10.5.

DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 71 BY 5.25.

DEFINE RECTANGLE RECT-9
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 38.5 BY 10.5.

DEFINE VARIABLE tg-detailed AS LOGICAL INITIAL no
     LABEL "Детализированный отчет"
     VIEW-AS TOGGLE-BOX
     SIZE 43 BY .83 NO-UNDO.

DEFINE VARIABLE tg-gds-by-am AS LOGICAL INITIAL no
     LABEL "Товары по ассортиментной матрице объекта"
     VIEW-AS TOGGLE-BOX
     SIZE 43.5 BY .83 NO-UNDO.

DEFINE VARIABLE tg-group-by-order AS LOGICAL INITIAL no 
     LABEL "По заказам" 
     VIEW-AS TOGGLE-BOX
     SIZE 43 BY .83 NO-UNDO.

DEFINE VARIABLE tg-group-by-post AS LOGICAL INITIAL no 
     LABEL "Группировка по поставщикам" 
     VIEW-AS TOGGLE-BOX
     SIZE 43 BY .83 NO-UNDO.

DEFINE VARIABLE tog-1 AS LOGICAL INITIAL no 
     LABEL "Item1" 
     VIEW-AS TOGGLE-BOX
     SIZE 28 BY .83 NO-UNDO.

DEFINE VARIABLE tog-2 AS LOGICAL INITIAL no
     LABEL "Item2"
     VIEW-AS TOGGLE-BOX
     SIZE 28 BY .83 NO-UNDO.

DEFINE VARIABLE tog-3 AS LOGICAL INITIAL no
     LABEL "Item3"
     VIEW-AS TOGGLE-BOX
     SIZE 28 BY .83 NO-UNDO.

DEFINE VARIABLE tog-4 AS LOGICAL INITIAL no
     LABEL "Item4"
     VIEW-AS TOGGLE-BOX
     SIZE 28 BY .83 NO-UNDO.

DEFINE VARIABLE tog-5 AS LOGICAL INITIAL no
     LABEL "Item5"
     VIEW-AS TOGGLE-BOX
     SIZE 28 BY .83 NO-UNDO.

DEFINE VARIABLE tog-6 AS LOGICAL INITIAL no
     LABEL "Item6"
     VIEW-AS TOGGLE-BOX
     SIZE 28 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     tg-gds-by-am AT ROW 2 COL 2 WIDGET-ID 2
     tg-group-by-order AT ROW 3 COL 2 WIDGET-ID 56
     tg-group-by-post AT ROW 3.92 COL 2.13 WIDGET-ID 4
     tg-detailed AT ROW 4.92 COL 2.13 WIDGET-ID 6
     fi-days-wt-goods AT ROW 7.25 COL 3.5 WIDGET-ID 14
     fi-critical-qnty-balance AT ROW 7.5 COL 42 WIDGET-ID 24
     fi-gds-qnty AT ROW 8.25 COL 1.5 WIDGET-ID 16
     fi-critical-qnty-sale AT ROW 8.5 COL 42.13 WIDGET-ID 26
     fi-critical-qnty-order AT ROW 9.5 COL 44 WIDGET-ID 28
     tog-1 AT ROW 10.75 COL 2 WIDGET-ID 42
     tog-2 AT ROW 11.75 COL 2 WIDGET-ID 44
     tog-3 AT ROW 12.75 COL 2 WIDGET-ID 46
     tog-4 AT ROW 13.75 COL 2 WIDGET-ID 48
     tog-5 AT ROW 14.75 COL 2 WIDGET-ID 50
     tog-6 AT ROW 15.75 COL 2 WIDGET-ID 54
     "Критерии" VIEW-AS TEXT
          SIZE 8 BY .67 AT ROW 6.75 COL 41 WIDGET-ID 22
          FGCOLOR 4 
     "Фильтры" VIEW-AS TEXT
          SIZE 8 BY .67 AT ROW 6.75 COL 1.5 WIDGET-ID 12
          FGCOLOR 4 
     "Общее" VIEW-AS TEXT
          SIZE 8 BY .67 AT ROW 1.25 COL 1.5 WIDGET-ID 18
          FGCOLOR 4 
     "Показывать товары с ИЖТ:" VIEW-AS TEXT
          SIZE 26 BY .67 AT ROW 9.75 COL 3 WIDGET-ID 52
     RECT-8 AT ROW 1 COL 1 WIDGET-ID 8
     RECT-9 AT ROW 6.25 COL 1 WIDGET-ID 10
     RECT-10 AT ROW 6.25 COL 39.5 WIDGET-ID 20
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE 
         BGCOLOR 8 .


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartViewer
   Allow: Basic,DB-Fields
   Frames: 1
   Add Fields to: EXTERNAL-TABLES
   Other Settings: PERSISTENT-ONLY
 */

/* This procedure should always be RUN PERSISTENT.  Report the error,  */
/* then cleanup and return.                                            */
IF NOT THIS-PROCEDURE:PERSISTENT THEN DO:
  MESSAGE "{&FILE-NAME} should only be RUN PERSISTENT.":U
          VIEW-AS ALERT-BOX ERROR BUTTONS OK.
  RETURN.
END.

&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB)
  CREATE WINDOW s-object ASSIGN
         HEIGHT             = 16.04
         WIDTH              = 71.5.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB s-object
/* ************************* Included-Libraries *********************** */

{src/adm/method/viewer.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW s-object
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE FRAME-NAME Size-to-Fit                                   */
ASSIGN
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN fi-critical-qnty-balance IN FRAME F-Main
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN fi-critical-qnty-order IN FRAME F-Main
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN fi-critical-qnty-sale IN FRAME F-Main
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN fi-days-wt-goods IN FRAME F-Main
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN fi-gds-qnty IN FRAME F-Main
   NO-DISPLAY NO-ENABLE ALIGN-L                                         */
ASSIGN
       fi-gds-qnty:HIDDEN IN FRAME F-Main           = TRUE.

/* SETTINGS FOR TOGGLE-BOX tg-detailed IN FRAME F-Main
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       tg-detailed:HIDDEN IN FRAME F-Main           = TRUE.

/* SETTINGS FOR TOGGLE-BOX tg-group-by-post IN FRAME F-Main
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       tg-group-by-post:HIDDEN IN FRAME F-Main           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME tg-gds-by-am
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tg-gds-by-am s-object
ON VALUE-CHANGED OF tg-gds-by-am IN FRAME F-Main /* Товары по ассортиментной матрице объекта */
DO:
  if not tg-gds-by-am:checked then do:
    disable tog-1 tog-2 tog-3 tog-4 tog-5 tog-6 with frame {&frame-name}.
  end.
  else do:
    enable tog-1 tog-2 tog-3 tog-4 tog-5 tog-6 with frame {&frame-name}.
    apply "value-changed" to tog-1.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tog-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tog-1 s-object
ON VALUE-CHANGED OF tog-1 IN FRAME F-Main /* Item1 */
DO:
  if tog-1:checked then do :
    disable tog-2 tog-3 tog-4 tog-5 tog-6 with frame {&frame-name}.
  end.
  else do :
    enable tog-2 tog-3 tog-4 tog-5 tog-6 with frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK s-object


/* ***************************  Main Block  *************************** */

/* If testing in the UIB, initialize the SmartObject. */

&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
  RUN dispatch IN THIS-PROCEDURE ('initialize':U).
&ENDIF

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI s-object  _DEFAULT-DISABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-apply-layout s-object
PROCEDURE local-apply-layout :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'apply-layout':U ) .

  /* Code placed here will execute AFTER standard behavior.    */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize s-object
PROCEDURE local-initialize :
define variable v-naim           as character        no-undo.
  define variable v-list           as character        no-undo.
  define variable v-print-graft    as logical          no-undo.
  define variable v-sort-gr        as logical          no-undo.
  define variable v-type-price     as logical          no-undo.
  define variable v-type-val       as logical          no-undo.
  define variable v-i              as integer          no-undo .

  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .
    /*
    Pri_Perem:screen-value in frame {&frame-name} = string(True).
    display Pri_Perem with frame {&FRAME-NAME} .
    */

  do with frame {&frame-name}
  :
    assign
      tog-1:label = {&all}
      tog-2:label = {&ass-izd-new}
      tog-3:label = {&ass-izd-com}
      tog-4:label = {&ass-izd-spec}
      tog-5:label = {&ass-izd-del}
      tog-6:label = {&ass-izd-empty}
    .

  end.
  CASE place-call:
    WHEN {&TABLE_schedule} THEN DO:
      RUN rcps_get-profile-id IN parent-handle ( OUTPUT v-profile-id).
      CASE v-profile-id:
        WHEN 54 THEN DO:
          assign
            fi-days-wt-goods          = v-days-wt-goods
            fi-critical-qnty-balance  = v-critical-qnty-balance
            fi-critical-qnty-sale     = v-critical-qnty-sale
            fi-critical-qnty-order    = v-critical-qnty-order
            tg-gds-by-am              = v-gds-by-am
            tg-group-by-post          = v-group-by-post
            tg-group-by-order         = v-group-by-order  
          .
          /*выключить все галки которые в режиме по расписанию не нужны*/
          display
            fi-days-wt-goods
            fi-critical-qnty-balance
            fi-critical-qnty-sale
            fi-critical-qnty-order
            tg-gds-by-am
            /*tg-group-by-post*/
          with frame {&frame-name} .
          enable
          fi-days-wt-goods
          fi-critical-qnty-balance
          fi-critical-qnty-sale
          fi-critical-qnty-order
          tg-gds-by-am
          tg-group-by-order
          /*tg-group-by-post*/
          with frame {&frame-name} .
          assign tog-1 = yes.
          display
          tog-1
          with frame {&frame-name} .
          apply "VALUE-CHANGED" to tog-1.
          disable
          tog-1
          with frame {&frame-name} .
        end.
      end case. /*CASE v-profile-id:*/
    end. /*when schedule*/
    otherwise do:
      run uf-get( input {&uf-ctrasm}
                , input v-cntxt-userid
                , output v-list
                , output v-naim
                , output v-print-graft
                , output v-sort-gr
                , output v-type-price
                , output v-type-val
                ) .
      if num-entries(v-list , {&delim-par}) = 15
      then do:
        assign
          tg-gds-by-am              = logical(entry( 1, v-list, {&delim-par}))
          tg-group-by-post          = logical(entry( 2, v-list, {&delim-par}))
          tg-detailed               = logical(entry( 3, v-list, {&delim-par}))
          fi-critical-qnty-balance  = decimal(entry( 4, v-list, {&delim-par}))
          fi-critical-qnty-sale     = decimal(entry( 5, v-list, {&delim-par}))
          fi-critical-qnty-order    = decimal(entry( 6, v-list, {&delim-par}))
          fi-days-wt-goods          = decimal(entry( 7, v-list, {&delim-par}))
          fi-gds-qnty               = decimal(entry( 8, v-list, {&delim-par}))
          tog-1                     = logical(entry( 9, v-list, {&delim-par}))
          tog-2                     = logical(entry( 10, v-list, {&delim-par}))
          tog-3                     = logical(entry( 11, v-list, {&delim-par}))
          tog-4                     = logical(entry( 12, v-list, {&delim-par}))
          tog-5                     = logical(entry( 13, v-list, {&delim-par}))
          tog-6                     = logical(entry( 14, v-list, {&delim-par}))
          tg-group-by-order         = logical(entry( 15, v-list, {&delim-par}))
        no-error .
        display
          tg-gds-by-am
          tg-group-by-order
          /*tg-group-by-post*/
    /*      tg-detailed*/
          fi-critical-qnty-balance
          fi-critical-qnty-sale
          fi-critical-qnty-order
          fi-days-wt-goods
          tog-1
          tog-2
          tog-3
          tog-4
          tog-5
          tog-6
    /*      fi-gds-qnty*/
        with frame {&frame-name}.
      end.
      else do:
        display
          tg-gds-by-am
          tg-group-by-order
          /*tg-group-by-post*/
    /*      tg-detailed*/
          fi-critical-qnty-balance
          fi-critical-qnty-sale
          fi-critical-qnty-order
          fi-days-wt-goods
          tog-1
          tog-2
          tog-3
          tog-4
          tog-5
          tog-6
        with frame {&frame-name}.
      end.

    END.
  END CASE.
  assign
    tg-group-by-post = no
  .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-params s-object
PROCEDURE my-params :
define input parameter p-action as character no-undo .

define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as integer no-undo .
define variable v-value-logical as logical no-undo .
DEFINE VARIABLE v-index-id AS INTEGER NO-UNDO.
define variable v-obj-str as character no-undo .
CASE p-action:
   WHEN "get" THEN DO:
    IF v-profile-id = 54  THEN DO:
       v-index-id = 0.
       RUN rcps_get-value IN parent-handle (
                                          input "p-gds-by-am"
                                         ,INPUT-output v-index-id
                                         ,output v-value-character /*p-value-character*/
                                         ,output v-value-date /*p-value-date*/
                                         ,output v-value-decimal /*p-value-decimal*/
                                         ,output v-value-integer /*p-value-integer*/
                                         ,output v-gds-by-am /*p-value-logical*/
                                         ) no-error .
       v-index-id = 0.
       RUN rcps_get-value IN parent-handle (
                                          input "p-group-by-post"
                                         ,INPUT-output v-index-id
                                         ,output v-value-character /*p-value-character*/
                                         ,output v-value-date /*p-value-date*/
                                         ,output v-value-decimal /*p-value-decimal*/
                                         ,output v-value-integer /*p-value-integer*/
                                         ,output v-group-by-post /*p-value-logical*/
                                         ) no-error .
       v-index-id = 0.
       RUN rcps_get-value IN parent-handle (
                                          input "p-critical-qnty-balance"
                                         ,INPUT-output v-index-id
                                         ,output v-value-character /*p-value-character*/
                                         ,output v-value-date /*p-value-date*/
                                         ,output v-critical-qnty-balance /*p-value-decimal*/
                                         ,output v-value-integer /*p-value-integer*/
                                         ,output v-value-logical /*p-value-logical*/
                                         ) no-error .
       v-index-id = 0.
       RUN rcps_get-value IN parent-handle (
                                          input "p-critical-qnty-sale"
                                         ,INPUT-output v-index-id
                                         ,output v-value-character /*p-value-character*/
                                         ,output v-value-date /*p-value-date*/
                                         ,output v-critical-qnty-sale /*p-value-decimal*/
                                         ,output v-value-integer /*p-value-integer*/
                                         ,output v-value-logical /*p-value-logical*/
                                         ) no-error .
       v-index-id = 0.
       RUN rcps_get-value IN parent-handle (
                                          input "p-critical-qnty-order"
                                         ,INPUT-output v-index-id
                                         ,output v-value-character /*p-value-character*/
                                         ,output v-value-date /*p-value-date*/
                                         ,output v-critical-qnty-order /*p-value-decimal*/
                                         ,output v-value-integer /*p-value-integer*/
                                         ,output v-value-logical /*p-value-logical*/
                                         ) no-error .
       v-index-id = 0.
       RUN rcps_get-value IN parent-handle (
                                          input "p-days-wt-goods"
                                         ,INPUT-output v-index-id
                                         ,output v-value-character /*p-value-character*/
                                         ,output v-value-date /*p-value-date*/
                                         ,output v-value-decimal /*p-value-decimal*/
                                         ,output v-days-wt-goods /*p-value-integer*/
                                         ,output v-value-logical /*p-value-logical*/
                                         ) no-error .

      empty temp-table X-init_obj-list.
      v-index-id = 1.
      do while v-index-id >= 1 :
        RUN rcps_get-value IN parent-handle (
                                        input "p-objects"
                                        ,INPUT-output v-index-id
                                        ,output v-obj-str /*p-value-character*/
                                        ,output v-value-date /*p-value-date*/
                                        ,output v-value-decimal /*p-value-decimal*/
                                        ,output v-value-integer /*p-value-integer*/
                                        ,output v-value-logical /*p-value-logical*/
                                        ) no-error .
        if error-status:error then leave.
        if v-obj-str = '' then leave.
        find first X-init_obj-list where
                  X-init_obj-list.obj-type = substring(v-obj-str, 1, 3)
              and  X-init_obj-list.obj-code = integer(substring(v-obj-str, 4)) no-error.
        if not available X-init_obj-list then do:
          create X-init_obj-list.
          assign
          X-init_obj-list.obj-type = substring(v-obj-str, 1, 3)
          X-init_obj-list.obj-code = integer(substring(v-obj-str, 4))
          .
          release X-init_obj-list.
        end.
      end. /*      do while v-index-id >= 1 :*/
      X-selectobject =  {&obj-choice}.

    END. /*IF v-profile-id = 53  THEN DO:*/
    RUN local-initialize IN THIS-PROCEDURE.

   END.
   WHEN "set" THEN do:
    IF v-profile-id = 54 THEN DO:
      assign frame {&frame-name}
        fi-days-wt-goods
        fi-gds-qnty
        fi-critical-qnty-balance
        fi-critical-qnty-sale
        fi-critical-qnty-order
        tg-gds-by-am
        tg-group-by-order
        tg-group-by-post
        tg-detailed
      .
      RUN rcps_set-value IN parent-handle (
                                       input "p-gds-by-am"
                                      ,INPUT 0
                                      ,input '' /*p-value-character*/
                                      ,input ?  /*p-value-date*/
                                      ,input 0.0 /*p-value-decimal*/
                                      ,input 0 /*p-value-integer*/
                                      ,input tg-gds-by-am /*p-value-logical*/
                                      ) no-error .
      RUN rcps_set-value IN parent-handle (
                                       input "p-group-by-post"
                                      ,INPUT 0
                                      ,input '' /*p-value-character*/
                                      ,input ?  /*p-value-date*/
                                      ,input 0.0 /*p-value-decimal*/
                                      ,input 0 /*p-value-integer*/
                                      ,input tg-group-by-post /*p-value-logical*/
                                      ) no-error .
      RUN rcps_set-value IN parent-handle (
                                       input "p-critical-qnty-balance"
                                      ,INPUT 0
                                      ,input '' /*p-value-character*/
                                      ,input ?  /*p-value-date*/
                                      ,input fi-critical-qnty-balance /*p-value-decimal*/
                                      ,input 0 /*p-value-integer*/
                                      ,input no /*p-value-logical*/
                                      ) no-error .
      RUN rcps_set-value IN parent-handle (
                                       input "p-critical-qnty-sale"
                                      ,INPUT 0
                                      ,input '' /*p-value-character*/
                                      ,input ?  /*p-value-date*/
                                      ,input fi-critical-qnty-sale /*p-value-decimal*/
                                      ,input 0 /*p-value-integer*/
                                      ,input no /*p-value-logical*/
                                      ) no-error .
      RUN rcps_set-value IN parent-handle (
                                       input "p-critical-qnty-order"
                                      ,INPUT 0
                                      ,input '' /*p-value-character*/
                                      ,input ?  /*p-value-date*/
                                      ,input fi-critical-qnty-order /*p-value-decimal*/
                                      ,input 0 /*p-value-integer*/
                                      ,input no /*p-value-logical*/
                                      ) no-error .
      RUN rcps_set-value IN parent-handle (
                                       input "p-days-wt-goods"
                                      ,INPUT 0
                                      ,input '' /*p-value-character*/
                                      ,input ?  /*p-value-date*/
                                      ,input 0.0 /*p-value-decimal*/
                                      ,input fi-days-wt-goods /*p-value-integer*/
                                      ,input no /*p-value-logical*/
                                      ) no-error .

      v-index-id = 0.
      for each obj-list :
        v-index-id = v-index-id + 1.
        RUN rcps_set-value IN parent-handle (
                                        input "p-objects"
                                        ,INPUT v-index-id
                                        ,input substitute("&1&2", obj-list.obj-type, obj-list.obj-code) /*p-value-character*/
                                        ,input ?  /*p-value-date*/
                                        ,input 0.0 /*p-value-decimal*/
                                        ,input 0 /*p-value-integer*/
                                        ,input no /*p-value-logical*/
                                        ) no-error .
        if error-status:error then do:
          message
          error-status:get-message(1) return-value
          view-as alert-box .
          undo, return error .
        end.
      end. /*    for each obj-list :*/
      v-index-id = v-index-id + 1.
      do while true:
        run rcps_proc-b-del in parent-handle (
                                               input "p-objects"
                                              ,input v-index-id) no-error.
        if error-status:error
        or return-value = "not-found" then leave.
        v-index-id = v-index-id + 1.
      end.
      if error-status:error then do:
        message
        error-status:get-message(1) return-value
        view-as alert-box .
        undo, return error .
      end.
    END. /*IF v-profile-id = 54 THEN DO:*/

   END.
END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета с любыми параметрами
------------------------------------------------------------------------------*/
define variable v-naim           as character        no-undo.
define variable v-list           as character        no-undo.
define variable v-print-graft    as logical          no-undo.
define variable v-sort-gr        as logical          no-undo.
define variable v-type-price     as logical          no-undo.
define variable v-type-val       as logical          no-undo.

  assign frame {&frame-name}
    fi-days-wt-goods
    fi-gds-qnty
    fi-critical-qnty-balance
    fi-critical-qnty-sale
    fi-critical-qnty-order
    tg-gds-by-am
    tg-group-by-order
    tg-group-by-post
    tg-detailed
    tog-1
    tog-2
    tog-3
    tog-4
    tog-5
    tog-6
  .

  if fi-days-wt-goods > ( x-Date-End - x-Date-Start )
  then do:
    message
      "Количество дней без товара не может превышать количество дней в периоде" skip
    view-as alert-box information.
    assign
      fi-days-wt-goods = ( x-Date-End - x-Date-Start )
    .
    display
      fi-days-wt-goods
    with frame {&frame-name}.
    return . /* --->>>--- */
  end.
  assign
    v-list =  string(tg-gds-by-am     , "yes/no") + {&delim-par} +
              string(tg-group-by-post , "yes/no") + {&delim-par} +
              string(tg-detailed      , "yes/no") + {&delim-par} +
              string(fi-critical-qnty-balance   ) + {&delim-par} +
              string(fi-critical-qnty-sale      ) + {&delim-par} +
              string(fi-critical-qnty-order     ) + {&delim-par} +
              string(fi-days-wt-goods           ) + {&delim-par} +
              string(fi-gds-qnty                ) + {&delim-par} +
              string(tog-1            , "yes/no") + {&delim-par} +
              string(tog-2            , "yes/no") + {&delim-par} +
              string(tog-3            , "yes/no") + {&delim-par} +
              string(tog-4            , "yes/no") + {&delim-par} +
              string(tog-5            , "yes/no") + {&delim-par} +
              string(tog-6            , "yes/no") + {&delim-par} +
              string(tg-group-by-order, "yes/no")
  .

  run uf-set( input {&uf-ctrasm}
            , input v-cntxt-userid
            , input v-list
            , input v-naim
            , input v-print-graft
            , input v-sort-gr
            , input v-type-price
            , input v-type-val
            ) .

  run rep/r-ctrasm.p ( input my-handle
                     , input ? /*p-call-handle*/
                     , input no /*p-schedule*/
                     , input x-date-start
                     , input x-date-end
                     , input tg-gds-by-am
                     , input tg-group-by-order
                     , input tg-group-by-post
                     , input fi-critical-qnty-balance
                     , input fi-critical-qnty-sale
                     , input fi-critical-qnty-order
                     , input fi-days-wt-goods
                     , input '' /*p-dir-name*/
                     , input '' /*p-current-rep-code*/
                     , input tog-1
                     , input tog-2
                     , input tog-3
                     , input tog-4
                     , input tog-5
                     , input tog-6
                     ).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки???

------------------------------------------------------------------------------*/
  assign frame {&frame-name}
    fi-days-wt-goods
    fi-gds-qnty
    fi-critical-qnty-balance
    fi-critical-qnty-sale
    fi-critical-qnty-order
    tg-gds-by-am
    tg-group-by-order
    tg-group-by-post
    tg-detailed
    tog-1
    tog-2
    tog-3
    tog-4
    tog-5
    tog-6
  .
  assign
    ReportHeader = "":U
  .

  if tg-gds-by-am = yes
  then do:
    assign
      ReportHeader = {&new-line} + "По АМ":U
    .
  end.
  if tg-group-by-post = yes
  then do:
    assign
      ReportHeader = ReportHeader + {&new-line} + "Группировка по поставщику":U
    .
  end.
  if tg-detailed = yes
  then do:
    assign
      ReportHeader = ReportHeader + {&new-line} + "Детализированный отчет":U
    .
  end.
  assign
    ReportHeader = ReportHeader + {&new-line} + substitute( "Критический остаток: &1" , fi-critical-qnty-balance ) +
                                  {&new-line} + substitute( "Критическая продажа: &1" , fi-critical-qnty-sale    ) +
                                  {&new-line} + substitute( "Критический заказ: &1"   , fi-critical-qnty-order   ) +
                                  {&new-line} + substitute( "Фильтры:"                                           ) +
                                  {&new-line} + substitute( "Дней без товара: &1"     , fi-days-wt-goods         )
  .
  assign
    ReportHeader = ReportHeader + {&new-line} + "Показывать товары с ИЖТ:":U +
      ( if tog-1 = yes then {&all} else
      ( if tog-2 = yes then {&ass-izd-new}   + "," else "" ) +
      ( if tog-3 = yes then {&ass-izd-com}   + "," else "" ) +
      ( if tog-4 = yes then {&ass-izd-spec}  + "," else "" ) +
      ( if tog-5 = yes then {&ass-izd-del}   + "," else "" ) +
      ( if tog-6 = yes then {&ass-izd-empty}       else "" ) )
  .

  assign
    ReportHeader = ReportHeader + {&new-line}
  .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed s-object
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:     Receive and process 'state-changed' methods
               (issued by 'new-state' event).
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER p-state      AS CHARACTER NO-UNDO.


  CASE p-state:
      /* Object instance CASEs can go here to replace standard behavior
         or add new cases. */
      /* link-changed */
  END CASE.
  END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME