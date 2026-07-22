&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------


$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Ошибки документа

Автор: Шкляр Елена
Дата создания: 20/04/95
Author: Shklyar Elena
Creation date: 20/04/95
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
using ibs.th.gbl.sys.objsrv.
using ibs.th.str.marking.sts.*.

/* Parameters Definitions ---                                           */
define input parameter p-db-num as integer no-undo .
define input parameter p-doc-id as integer no-undo .
define input parameter p-reckey  as character no-undo .
define input parameter p-line-num as integer no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Ошибки документа".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ str/temp_upd.i }
{ str/utd-err.i }
{ gbl/key-rec.i }

define buffer buf_utd-err for ub.utd-err .
define buffer utd-err for tt-utd-err .
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

def var Marking as class mark no-undo .
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD StatusTHName Dialog-Frame
FUNCTION StatusTHName RETURNS CHARACTER
  (input p-stsTH as integer)  .
  Return Marking:GetLabel(p-stsTH) .
END FUNCTION .
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-2

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-utd-err

/* Definitions for BROWSE BROWSE-2                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-2 tt-utd-err.CheckType tt-utd-err.CodeErr ~
tt-utd-err.CheckObj 
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-2 
&Scoped-define QUERY-STRING-BROWSE-2 FOR EACH tt-utd-err NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-2 OPEN QUERY BROWSE-2 FOR EACH tt-utd-err NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-2 tt-utd-err
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-2 tt-utd-err


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-2}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_OK b-print BROWSE-2 
&Scoped-Define DISPLAYED-OBJECTS f-error 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-print 
    IMAGE-UP FILE "cmp/b-print.bmp":U
    IMAGE-DOWN FILE "cmp/b-print.bmp":U
    IMAGE-INSENSITIVE FILE "cmp/b-print.bmp":U NO-CONVERT-3D-COLORS
    LABEL "Печать" 
    SIZE 3 BY 1.

DEFINE BUTTON Btn_OK AUTO-GO 
     LABEL "Выход" 
     SIZE 15 BY 1.13
     BGCOLOR 8 .





/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-2 FOR 
      tt-utd-err SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-2 Dialog-Frame _STRUCTURED
  QUERY BROWSE-2 NO-LOCK DISPLAY
      tt-utd-err.LineNum COLUMN-LABEL "№" FORMAT "999":U
      tt-utd-err.gds-code COLUMN-LABEL "Код товара" FORMAT ">>>>>>>>>>>>9":U
      tt-utd-err.descr COLUMN-LABEL "Описание" FORMAT "x(256)":U width 120 
      tt-utd-err.CheckType FORMAT "x(8)":U
      tt-utd-err.CodeErr FORMAT "x(15)":U
      tt-utd-err.CheckObj FORMAT "x(256)":U width 120
      
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 128 BY 13.5
         FONT 2 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1 COL 1
     b-print AT ROW 1 COL 127 WIDGET-ID 62
     
     BROWSE-2 AT ROW 3.5 COL 2 WIDGET-ID 200
     "Сформированные ошибки:" VIEW-AS TEXT
          SIZE 27 BY .67 AT ROW 2.5 COL 2.5 WIDGET-ID 16
     SPACE(101.62) SKIP(14.36)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Ошибки документа"
         CANCEL-BUTTON Btn_OK WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-2 TEXT-1 Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN 
       BROWSE-2:COLUMN-RESIZABLE IN FRAME Dialog-Frame       = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-2
/* Query rebuild information for BROWSE BROWSE-2
     _TblList          = "ub.utd-err"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   = ub.utd-err.CheckType
     _FldNameList[2]   = ub.utd-err.CodeErr
     _FldNameList[3]   = ub.utd-err.CheckObj
     _Query            is OPENED
*/  /* BROWSE BROWSE-2 */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Ошибки документа */
DO:
    APPLY "END-ERROR":U TO SELF.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dialog-Frame
ON CHOOSE OF b-print IN FRAME Dialog-Frame /* Печать */
DO:

   run rep\r-print-error.p (
   input p-doc-id,
   input p-db-num,
   input table tt-utd-err 
   ).   
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK Dialog-Frame
ON choose OF Btn_OK IN FRAME Dialog-Frame /* Ввод */
DO:

  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-2
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
  THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  Marking = ObjSrv:Env:Marking:Sts:Mark.  
  run init-temp .
   {  gbl/diasize.i }
  run diasize_init in this-procedure .
  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

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
  ENABLE Btn_OK BROWSE-2 b-print
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-temp Dialog-Frame 
PROCEDURE init-temp :
/* --------------------------------------------------------------------
                    Purpose:     ENABLE the User Interface
                    Parameters:  <none>
                    Notes:       Here we display/view/enable the widgets in the
                                 user-interface.  In addition, OPEN all queries
                                 associated with each FRAME and BROWSE.
                                 These statements here are based on the "Other
                                 Settings" section of the widget Property Sheets.
                     -------------------------------------------------------------------- */
define buffer buf_marking for ub.marking .
define buffer buf_utd-marking-lines for ub.utd-marking-lines .
define variable ii as integer no-undo .
define variable status_ as character no-undo . 
define variable vline as integer no-undo.
define variable vHn as handle no-undo.
define VARIABLE vRecKey-markLine as character no-undo .

ii = 0 .  

if p-line-num <> 0 then do:
    vRecKey-markLine = replace(p-reckey,"utd-lines","utd-marking-lines") + {&delim-key}.
  for each buf_utd-err no-lock where buf_utd-err.db-num = p-db-num 
                                 and buf_utd-err.doc-id = p-doc-id 
                                 and (buf_utd-err.reckey = p-reckey or buf_utd-err.reckey begins vRecKey-markLine):
    create tt-utd-err .
    buffer-copy buf_utd-err to tt-utd-err .
    assign
    tt-utd-err.descr = GetTextError(tt-utd-err.CheckType,tt-utd-err.CodeErr,tt-utd-err.CheckObj)
    .
    if buf_utd-err.reckey begins "utd-lines" or buf_utd-err.reckey begins "utd-marking-lines" 
    or buf_utd-err.reckey begins "marking" then do:
/*        vline  = integer (entry(4,buf_utd-err.reckey,{&delim-key})).*/
      run gen-hn-keyr(input buf_utd-err.reckey,input ?,input "{&db-name_schema}" , input ? ,input no-lock , output vHn).
      if vHn:available
      then do:
      if buf_utd-err.reckey begins "marking" then do:
          tt-utd-err.gds-code = vHn::gds-code .
          tt-utd-err.LineNum  = 0 . 
      end.                
      else do:
          tt-utd-err.LineNum = vHn::lineNum . 
          tt-utd-err.gds-code = vHn::gds-code .
      end.
      delete object vHn no-error.
    end.     
    end.
  end.
      
end.
else do:
        
  for each buf_utd-err no-lock where buf_utd-err.db-num = p-db-num and buf_utd-err.doc-id = p-doc-id and buf_utd-err.reckey begins p-reckey:
    create tt-utd-err .
    buffer-copy buf_utd-err to tt-utd-err .
    assign
    tt-utd-err.descr = GetTextError(tt-utd-err.CheckType,tt-utd-err.CodeErr,tt-utd-err.CheckObj)
    .
    if buf_utd-err.reckey begins "utd-lines" or buf_utd-err.reckey begins "utd-marking-lines" 
    or buf_utd-err.reckey begins "marking" then do:
/*        vline  = integer (entry(4,buf_utd-err.reckey,{&delim-key})).*/
      run gen-hn-keyr(input buf_utd-err.reckey,input ?,input "{&db-name_schema}" , input ? ,input no-lock , output vHn).
      if vHn:available
      then do:
      if buf_utd-err.reckey begins "marking" then do:
          tt-utd-err.gds-code = vHn::gds-code .
          tt-utd-err.LineNum  = 0 . 
      end.                
      else do:
          tt-utd-err.LineNum = vHn::lineNum . 
          tt-utd-err.gds-code = vHn::gds-code .
      end.
      delete object vHn no-error.
    end.     
    end.
  end.
 end. 
  /*По линии*/   
  if p-line-num <> 0 then 
  do:
    for each buf_utd-marking-lines no-lock where buf_utd-marking-lines.db-num = p-db-num and 
      buf_utd-marking-lines.doc-id = p-doc-id and 
      buf_utd-marking-lines.LineNum = p-line-num and
      buf_utd-marking-lines.doc-level = 1,
      first buf_marking no-lock where buf_marking.mark = buf_utd-marking-lines.mark and
      buf_marking.sts =  Marking:NotAvailable:KeyIntDB :
      create tt-utd-err .
      ii = ii + 1 .
      assign
        tt-utd-err.CheckType = "UCDСompar"
        tt-utd-err.CheckObj  = "По товару " + string(buf_utd-marking-lines.gds-code) + " по линии " + string(buf_utd-marking-lines.LineNum)
        tt-utd-err.CodeErr   = "MARKDECLINED"
        tt-utd-err.db-num    = buf_utd-marking-lines.db-num 
        tt-utd-err.doc-id    = buf_utd-marking-lines.doc-id
        tt-utd-err.reckey    = string(ii)
        tt-utd-err.LineNum   = buf_utd-marking-lines.LineNum
        tt-utd-err.gds-code  = buf_utd-marking-lines.gds-code
       
        .
      status_ = StatusTHName(buf_marking.sts) .
      tt-utd-err.descr = "Ошибка № 15. В результате проверки товаров на АЗК по строке " + string(buf_utd-marking-lines.LineNum) +  " марка " + buf_utd-marking-lines.mark + " не была принята."
        .
    end.  
  end.
  /*По документу*/
  else 
  do:
    for each buf_utd-marking-lines no-lock where buf_utd-marking-lines.db-num = p-db-num and 
      buf_utd-marking-lines.doc-id = p-doc-id and buf_utd-marking-lines.doc-level = 1,
      first buf_marking no-lock where buf_marking.mark = buf_utd-marking-lines.mark and
      buf_marking.sts =  Marking:NotAvailable:KeyIntDB :
      create tt-utd-err .
      ii = ii + 1 .
      assign
        tt-utd-err.CheckType = "UCDСompar"
        tt-utd-err.CheckObj  = "По товару " + string(buf_utd-marking-lines.gds-code) + " по линии " + string(buf_utd-marking-lines.LineNum)
        tt-utd-err.CodeErr   = "MARKDECLINED"
        tt-utd-err.db-num    = buf_utd-marking-lines.db-num 
        tt-utd-err.doc-id    = buf_utd-marking-lines.doc-id
        tt-utd-err.reckey    = string(ii)
        tt-utd-err.LineNum   = buf_utd-marking-lines.LineNum
        tt-utd-err.gds-code  = buf_utd-marking-lines.gds-code
        
        .
      status_ = StatusTHName(buf_marking.sts) .
      tt-utd-err.descr = "Ошибка № 15. В результате проверки товаров на АЗК по строке " + string(buf_utd-marking-lines.LineNum) +  " марка " + buf_utd-marking-lines.mark + " не была принята."
        .    
    end.      
  end.  
  
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

