&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-type-tmp


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-typeDoc NO-UNDO 
  field type-code as character
  field typeName  as character.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-type-tmp 
/*

$Revision: 998b6172f4a6, 2542, test $
$Author: SSlivenko $
$Date: Вт авг 04 12:57:22 2020 +0300 $
$Workfile: typ.w $
$Archive: ref/collec.w $

Справочник типов документов

Автор: Шкляр Елена
Дата создания: 07/20/06

*/
{ rep/tt-date.i }

define input  parameter parParentProc  as widget-handle no-undo.
define input-output  PARAMETER TABLE FOR tt-typeDocChoose.


define variable vss-revision    as character no-undo init "$Revision: 998b6172f4a6, 2542, test $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Вт авг 04 12:57:22 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: collec.w $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/collec.w $":U .
define variable vss-description as character no-undo init "Справочник типов документов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }



define variable rid-list              as character no-undo.
define variable row_type              as rowid     no-undo .
define variable ii                    as integer   no-undo .
define variable doc-ext-doc-type-list as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-type-tmp
&Scoped-define BROWSE-NAME br-coll

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-typeDoc

/* Definitions for BROWSE br-coll                                       */
&Scoped-define FIELDS-IN-QUERY-br-coll ~
(IF ( CAN-DO (rid-list, string( recid( tt-typeDoc ) ) ) ) THEN ("*") ELSE (" ")) ~
tt-typeDoc.sea-name 
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-coll 
&Scoped-define QUERY-STRING-br-coll FOR EACH tt-typeDoc NO-LOCK
&Scoped-define OPEN-QUERY-br-coll OPEN QUERY br-coll FOR EACH tt-typeDoc NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-coll tt-typeDoc
&Scoped-define FIRST-TABLE-IN-QUERY-br-coll tt-typeDoc


/* Definitions for DIALOG-BOX d-type-tmp                                */
&Scoped-define OPEN-BROWSERS-IN-QUERY-d-type-tmp ~
    ~{&OPEN-QUERY-br-coll}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit B-mark b-sel br-coll 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO 
  LABEL "&Выход ":L 
  SIZE 12 BY 1.

DEFINE BUTTON B-mark 
  LABEL "&*" 
  SIZE 3 BY 1.

DEFINE BUTTON b-sel AUTO-GO 
  LABEL "Вы&бор ":L 
  SIZE 10 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-coll FOR 
  tt-typeDoc SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-coll
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-coll d-type-tmp _STRUCTURED
  QUERY br-coll NO-LOCK DISPLAY
      (IF ( CAN-DO (rid-list, string( recid( tt-typeDoc ) ) ) ) THEN ("*") ELSE (" ")) COLUMN-LABEL "*" FORMAT "X(1)":U
      tt-typeDoc.typeName column-label "Наименование" FORMAT "X(30)":U WIDTH 50 
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 54.5 BY 19.46
         BGCOLOR 15 FGCOLOR 0 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-type-tmp
  b-exit AT ROW 1 COL 1
  B-mark AT ROW 1 COL 13
  b-sel AT ROW 1 COL 16.5
  br-coll AT ROW 2.25 COL 1.5
  SPACE(0.37) SKIP(0.28)
  WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
  SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
  TITLE "Типы документов":L.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Temp-Tables and Buffers:
      TABLE: tt-typeDoc T "?" NO-UNDO ub season
      ADDITIONAL-FIELDS:
          field type-code as character
          field type-name as character
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-type-tmp
   FRAME-NAME                                                           */
/* BROWSE-TAB br-coll b-sel d-type-tmp */
ASSIGN 
  FRAME d-type-tmp:SCROLLABLE = FALSE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-coll
/* Query rebuild information for BROWSE br-coll
     _TblList          = "Temp-Tables.tt-typeDoc"
     _Options          = "NO-LOCK"
     _FldNameList[1]   > "_<CALC>"
"(IF ( CAN-DO (rid-list, string( recid( tt-typeDoc ) ) ) ) THEN (""*"") ELSE ("" ""))" "*" "X(1)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > Temp-Tables.tt-typeDoc.sea-name
"sea-name" ? ? "character" ? ? ? ? ? ? no ? no no "50" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE br-coll */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX d-type-tmp
/* Query rebuild information for DIALOG-BOX d-type-tmp
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX d-type-tmp */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */
&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark d-type-tmp
ON CHOOSE OF B-mark IN FRAME d-type-tmp /* * */
  DO:
    define variable loc#log as logical no-undo .
      
    if available tt-typeDoc then 
    do:
      { gbl/markstrn.i tt-typeDoc rid-list }
      row_type = rowid(tt-typeDoc).
      loc#log = {&browse-name}:refresh() .
      reposition br-coll to rowid row_type.

      if last-event:function <> "MOUSE-SELECT-DBLCLICK" then 
      do:
        loc#log = {&browse-name}:select-next-row ().
        apply "VALUE-CHANGED" to {&browse-name} in frame {&frame-name}.
      end.
    end.
    apply "entry" to {&browse-name} in frame {&frame-name}.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel d-type-tmp
ON CHOOSE OF b-sel IN FRAME d-type-tmp /* Выбор  */
  DO:
    empty temp-table tt-typeDocChoose .
      do ii = 1 to num-entries (rid-list):
        find first tt-typeDoc where recid(tt-typeDoc) = integer(entry(ii,rid-list)) no-error .
        if available (tt-typeDoc) then 
        do:
          create tt-typeDocChoose .
          buffer-copy tt-typeDoc to tt-typeDocChoose .  
        end.
      end.

    find first tt-typeDocChoose no-error .
    if not available (tt-typeDocChoose) then do:
      message "Не задан тип документа для анализа, расчет невозможен"
      view-as alert-box.
      return no-apply .
    end.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-coll d-type-tmp
ON MOUSE-SELECT-DBLCLICK OF br-coll IN FRAME d-type-tmp
  DO:
    apply "choose" to b-sel in frame {&frame-name} .
    return no-apply .
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-coll d-type-tmp
ON RETURN OF br-coll IN FRAME d-type-tmp
  DO:
    apply "choose" to b-sel in frame {&frame-name} .
    return no-apply .
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-type-tmp 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
  THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} 
  APPLY "END-ERROR":U TO SELF.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
     
  doc-ext-doc-type-list = {&TDEDT_Ras_Vnesh_Kass} + {&slash-char} + "расход внешний касса" + {&comma-char} + 
    {&TDEDT_Vozvrat_Vnesh_Kass} + {&slash-char} + "возврат внешний касса" + {&comma-char} + 
    {&tdedt_spi_prvo} + {&slash-char} + "расход производство" + {&comma-char} + 
    {&TDEDT_Spi_Vnesh} + {&slash-char} + {&TDEDT_Spi_Vnesh-full} + {&comma-char} + 
    {&TDEDT_Ras_Vnesh} + {&slash-char} + {&TDEDT_Ras_Vnesh-full} + {&comma-char} + 
    {&TDEDT_Vozvrat_Vnesh} + {&slash-char} + {&TDEDT_Vozvrat_Vnesh-full} + {&comma-char} + 
    {&TDEDT_Vozvrat_Perem} + {&slash-char} + {&TDEDT_Vozvrat_Perem-full} + {&comma-char} + 
    {&TDEDT_Ras_Perem} + {&slash-char} + {&TDEDT_Ras_Perem-full} .    
 
  define variable doc-type as character no-undo .
  do ii = 1 to num-entries (doc-ext-doc-type-list,{&comma-char}):
    doc-type = entry (ii,doc-ext-doc-type-list,{&comma-char}) .
    create tt-typeDoc .
    assign
      tt-typeDoc.type-code = entry (1,doc-type,{&slash-char})
      tt-typeDoc.typeName  = entry (2,doc-type,{&slash-char})
      .
  end.  

  /*отмеченные документы*/
  define variable loc#log as logical no-undo .
  for each tt-typeDocChoose:
    find first tt-typeDoc where tt-typeDoc.type-code = tt-typeDocChoose.type-code no-error .      
    if available tt-typeDoc then 
    do:
      { gbl/markstrn.i tt-typeDoc rid-list }
    end.
    apply "entry" to {&browse-name} in frame {&frame-name}.
  end.
    
  run enable_ui.
  APPLY "VALUE-CHANGED":U TO {&browse-name} in frame {&frame-name}.
    
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_ui.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-type-tmp  _DEFAULT-DISABLE
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
  HIDE FRAME d-type-tmp.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-type-tmp 
PROCEDURE enable_UI :
  /* --------------------------------------------------------------------
    Purpose:     ENABLE the User Interface
    Parameters:  <none>
    Notes:       Here we display/view/enable the widgets in the
                 user-interface.  In addition, OPEN all queries
                 associated with each FRAME and BROWSE.
                 These statements here are based on the "Other
                 Settings" section of the widget Property Sheets.
     -------------------------------------------------------------------- */
  ENABLE
    br-coll
    b-exit
    b-sel
    b-mark
    WITH FRAME  {&frame-name}.
  {&OPEN-QUERY-br-coll}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION mon-name d-type-tmp 
FUNCTION mon-name RETURNS CHARACTER
  (input n-mon as int) :
  define variable name-mon as char no-undo.
  run gbl/monthnam.p ( input n-mon, output name-mon ) .
  RETURN name-mon.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

