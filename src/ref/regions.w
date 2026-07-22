&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_regions FOR ub.regions.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник регионов РФ

Автор: Хныкин Павел Андреевич
Дата создания: 01/16/07
Author: Pavel Khnykin
Creation date: 01/16/07

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parParentProc as widget-handle                    no-undo .
define input  parameter p-mode        as character                        no-undo .
define output parameter p-reg-code    like ub.regions.reg-code initial ?  no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i    }
{ cmp/trg-def.i     }
{ cmp/showinf.i     }
{ gbl/waitfram.i    }
{ rep/p-fmt.i       }
{ rep/r-sym.i       }
{ cmp/r-pril.i new  }
{ gbl/prn-lib.i     }

define variable v-regions-mark-list as character no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-region

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_regions

/* Definitions for BROWSE br-region                                     */
&Scoped-define FIELDS-IN-QUERY-br-region ~
mark-str-regions(buffer buf_regions, v-regions-mark-list) ~
buf_regions.reg-code buf_regions.reg-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-region
&Scoped-define QUERY-STRING-br-region FOR EACH buf_regions NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-region OPEN QUERY br-region FOR EACH buf_regions NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-region buf_regions
&Scoped-define FIRST-TABLE-IN-QUERY-br-region buf_regions


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-region}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit B-sel b-mark b-print B-Help br-region ~
mark-num
&Scoped-Define DISPLAYED-OBJECTS mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD mark-str-regions Dialog-Frame
FUNCTION mark-str-regions RETURNS CHARACTER
  ( buffer buf_regions for ub.regions, input v-regions-mark-list as character)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON b-print
     LABEL "Печ&ать"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE mark-num AS INTEGER FORMAT ">>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-region FOR
      buf_regions SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-region
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-region Dialog-Frame _STRUCTURED
  QUERY br-region NO-LOCK DISPLAY
      mark-str-regions(buffer buf_regions, v-regions-mark-list) COLUMN-LABEL "*"
            WIDTH 1
      buf_regions.reg-code COLUMN-LABEL "Код" FORMAT "ZZ9":U
      buf_regions.reg-name COLUMN-LABEL "Регион" FORMAT "X(40)":U
            WIDTH 54
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS NO-COLUMN-SCROLLING SEPARATORS SIZE 60 BY 15 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1 WIDGET-ID 2
     B-sel AT ROW 1 COL 11 WIDGET-ID 6
     b-mark AT ROW 1 COL 26 WIDGET-ID 8
     b-print AT ROW 1 COL 40.5 WIDGET-ID 12
     B-Help AT ROW 1 COL 50.5 WIDGET-ID 4
     br-region AT ROW 3 COL 1 WIDGET-ID 200
     mark-num AT ROW 2 COL 1 NO-LABEL WIDGET-ID 10
     SPACE(46.00) SKIP(15.33)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Справочник регионов РФ" WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_regions B "?" ? ub regions
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-region B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN mark-num IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-region
/* Query rebuild information for BROWSE br-region
     _TblList          = "buf_regions"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   > "_<CALC>"
"mark-str-regions(buffer buf_regions, v-regions-mark-list)" "*" ? ? ? ? ? ? ? ? no ? no no "1" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > Temp-Tables.buf_regions.reg-code
"buf_regions.reg-code" "Код" ? "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > Temp-Tables.buf_regions.reg-name
"buf_regions.reg-name" "Регион" ? "character" ? ? ? ? ? ? no ? no no "54" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE br-region */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Справочник регионов РФ */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Выход */
DO:
  { gbl/stdbtn.i }
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
define variable v-log as logical no-undo.

     if available buf_regions then do:
      { gbl/markstrn.i buf_regions v-regions-mark-list }
      v-log = br-region:refresh() .
      if last-event:function <> "MOUSE-SELECT-DBLCLICK" then  do:
        v-log = br-region:select-next-row ().
        apply "iteration-changed" to br-region in frame {&frame-name}.
      end.
      if num-entries( v-regions-mark-list ) = 0 then
          hide mark-num in frame {&frame-name}.
      else
          disp num-entries( v-regions-mark-list ) @ mark-num with frame {&frame-name}.
    end.
    apply "entry" to br-region in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dialog-Frame
ON CHOOSE OF b-print IN FRAME Dialog-Frame /* Печать */
DO:
  if not available buf_regions then return no-apply.
  run proc-b-print in this-procedure no-error.
  if error-status:error then do:
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if available buf_regions then do:
    assign
      p-reg-code = buf_regions.reg-code
    .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-region
&Scoped-define SELF-NAME br-region
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-region Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF br-region IN FRAME Dialog-Frame
DO:
  if p-mode = {&choose} then do:
    apply "choose" to b-sel.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ gbl/hot-key.i b-exit }
{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-sel }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN my-enable in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN my-disable.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame  _DEFAULT-DISABLE
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
  HIDE FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame  _DEFAULT-ENABLE
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
  DISPLAY mark-num
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-sel b-mark b-print B-Help br-region mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-disable Dialog-Frame
PROCEDURE my-disable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  run disable_UI in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-enable Dialog-Frame
PROCEDURE my-enable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  enable
    b-exit
    b-sel     when (p-mode = {&choose})
/*    b-mark*/
    b-help
    b-print
    br-region
    mark-num
  with frame {&frame-name}.
  hide
    mark-num
  in frame {&frame-name}.
  view frame {&frame-name}.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-print Dialog-Frame
PROCEDURE proc-b-print :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
&scop header "РЕГИОНЫ РФ":U

define variable v-line            as character no-undo .
define variable v-curr-doc-rowid  as rowid     no-undo .

define frame reg-frame
  sym1                 column-label ":"         format "X(1)"   space(0)
  buf_regions.reg-code column-label "Код"       format "zz9"    space(0)
  sym2                 column-label ":"         format "X(1)"   space(0)
  buf_regions.reg-name column-label "Название"  format "X(120)" space(0)
  sym3                 column-label ":"         format "X(1)"   space(0)
header
  string( "Страница " ) format "x(9)" at 100 page-number(prnlibstream) at 115 format ">>9" skip
  v-line format "x(126)" at 1
with width {&A4_CW} down stream-io use-text.

form header
  v-line format "x(126)" at 1 skip
  "Продолжение - на следующей странице" at 30 skip
with frame bottomframe width {&A4_CW} page-bottom no-labels no-box .

assign
  v-line = fill("-", 300)
.

run prn-lib-open-stream  in this-procedure ( input parParentProc
                                           , input {&CS_PS}
                                           , input yes  /*p-is-stream*/
                                           , input no   /*p-append*/
                                           ).

view  stream prnlibstream frame bottomframe .
put stream prnlibstream {&header} at center-field(1,126, length({&header})) skip(2).
assign
  v-curr-doc-rowid = rowid( buf_regions )
.
do while available buf_regions :
  get prev {&browse-name}.
end.
get next {&browse-name}.
do while available buf_regions :
  display stream prnlibstream
    sym1
    buf_regions.reg-code
    sym2
    buf_regions.reg-name
    sym3
  with frame reg-frame.
  down stream prnlibstream with frame reg-frame.
  get next {&browse-name}.
end.
put stream prnlibstream v-line format "x(126)" at 1 .

hide  stream prnlibstream frame bottomframe .
/*hide  stream prnlibstream frame reg-frame.*/

output  stream prnlibstream close.
reposition {&browse-name} to rowid v-curr-doc-rowid no-error.
apply "display" to {&browse-name} in frame {&frame-name}.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure ( input parparentproc
                                       , input 8
                                       ).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION mark-str-regions Dialog-Frame
FUNCTION mark-str-regions RETURNS CHARACTER
  ( buffer buf_regions for ub.regions, input v-regions-mark-list as character) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

  RETURN (if ( lookup( string( recid( buf_regions ) ) , v-regions-mark-list ) ) > 0 then "*":u else '':u ).   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME