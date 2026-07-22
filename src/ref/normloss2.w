&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_norm-loss FOR ub.norm-loss.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник норм технологических потерь

Автор: Шкляр Елена
Дата создания: 01/16/07
Author: Elena Shklyar
Creation date: 01/16/07

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parParentProc as widget-handle                    no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Справочник норм технологических потерь".
{ cmp/vssrevis.i    }
{ cmp/trg-def.i     }
{ cmp/showinf.i     }
{ gbl/waitfram.i    }
{ rep/p-fmt.i       }
{ rep/r-sym.i       }
{ cmp/r-pril.i new  }
{ gbl/prn-lib.i     }

define temp-table tt-norm-loss no-undo
  field clim-grp   as character
  field position   as character
  field oil-grp    as character
  field season     as character
  field value-loss as decimal
  field type-id    as integer
  field sec-vol    as character
  field id         as integer
  index pi id type-id
  .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-norm-loss

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-norm-loss

/* Definitions for BROWSE BR-norm-loss                                      */
&Scoped-define FIELDS-IN-QUERY-Br-norm-loss tt-norm-loss.sec-vol tt-norm-loss.clim-grp tt-norm-loss.oil-grp tt-norm-loss.season tt-norm-loss.norm-value   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-norm-loss   
&Scoped-define SELF-NAME BR-norm-loss
&Scoped-define QUERY-STRING-BR-norm-loss FOR EACH tt-norm-loss NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-norm-loss OPEN QUERY BR-norm-loss FOR EACH tt-norm-loss NO-LOCK by tt-norm-loss.sec-vol by tt-norm-loss.clim-grp by tt-norm-loss.oil-grp by tt-norm-loss.season INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-norm-loss tt-norm-loss
&Scoped-define FIRST-TABLE-IN-QUERY-BR-norm-loss tt-norm-loss


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-norm-loss}


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-add b-print B-Help BR-norm-loss 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add 
     LABEL "&Добавить" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-exit AUTO-END-KEY 
     LABEL "&Выход" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-print 
  LABEL "Печ&ать" 
  SIZE 10 BY 1
  BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-norm-loss FOR 
  tt-norm-loss SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-norm-loss
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-norm-loss Dialog-Frame _FREEFORM
  QUERY br-norm-loss DISPLAY
  tt-norm-loss.sec-vol FORMAT "x(10)":U  label "Вместим."
  tt-norm-loss.clim-grp FORMAT "x(10)":U label "Клим.гр."
  tt-norm-loss.oil-grp FORMAT "x(10)":U label "Гр.НП"
  tt-norm-loss.season FORMAT "x(10)":U label "Сезон"
  tt-norm-loss.value-loss FORMAT "->>>>>>>9.999":U label "Норма потерь при сливе из АЦ"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 87.75 BY 18.5 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1 WIDGET-ID 2
     b-add AT ROW 1 COL 11 WIDGET-ID 14
     b-print AT ROW 1 COL 69.13 WIDGET-ID 12
     B-Help AT ROW 1 COL 79.13 WIDGET-ID 4
     BR-norm-loss AT ROW 2.25 COL 1.75 WIDGET-ID 200
     SPACE(0.99) SKIP(0.20)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Нормы технологических потерь НП при сливе из АЦ" WIDGET-ID 100.


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
/* BROWSE-TAB BR-norm-loss B-Help Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
  run ref/normloss-add.w (parparentproc,
  input 1)no-error.
    run init-tt-table in this-procedure .   
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
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


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dialog-Frame
ON CHOOSE OF b-print IN FRAME Dialog-Frame /* Печать */
DO:
    if not available tt-norm-loss then return no-apply.
    run proc-b-print in this-procedure no-error.
    if error-status:error then 
    do:
      return no-apply.
    end.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-norm-loss
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
  THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ gbl/hot-key.i b-exit }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  run init-tt-table in this-procedure .   
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
  ENABLE B-exit b-print B-Help 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-tt-table Dialog-Frame 
PROCEDURE init-tt-table :
/*------------------------------------------------------------------------------
    Purpose:     
    Parameters:  <none>
    Notes:       
  ------------------------------------------------------------------------------*/
  for each buf_norm-loss no-lock where buf_norm-loss.type = 1:
    create tt-norm-loss .
    buffer-copy buf_norm-loss except buf_norm-loss.season buf_norm-loss.position buf_norm-loss.sec-vol1 buf_norm-loss.sec-vol2 to tt-norm-loss no-error .
    if buf_norm-loss.season = 0 then tt-norm-loss.season = "В-Л" .
    else tt-norm-loss.season = "О-З" .
    if buf_norm-loss.position = "0" then tt-norm-loss.position = "наземный" .
    else tt-norm-loss.position = "подземный" .
    tt-norm-loss.sec-vol = string(buf_norm-loss.sec-vol1) + 
    if buf_norm-loss.sec-vol2 <> 0 then "-" + string(buf_norm-loss.sec-vol2) else "".
  end.  


  
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
    b-help
    b-print
    br-norm-loss
    with frame {&frame-name}.
  disable
    b-add
    with frame {&frame-name} .
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
    run rep/print_NormLoss.p (
          input parParentProc
        , input 1
    ) no-error . 
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

