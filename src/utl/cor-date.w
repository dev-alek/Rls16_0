&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_clients FOR clients.
DEFINE BUFFER buf_sys-ctrl FOR sys-ctrl.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Утилита коррекции даты на объекте

Автор: Хныкин Павел Андреевич
Дата создания: 01/12/10
Author: Pavel Khnykin
Creation date: 01/12/10

*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parparentproc as handle    no-undo .

/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Утилита коррекции даты на объекте".
{ cmp/str-glbl.i }
{ cmp/vssrevis.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ gbl/usrfulnf.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit RECT-1 RECT-2 b-help fi-obj-type ~
fi-obj-code b-sel-obj fi-sys-date-cls fi-sys-date-opn fi-open-time-cls ~
fi-open-time-hms-cls fi-open-time-opn fi-open-time-hms-opn ~
fi-close-time-cls fi-close-time-hms-cls fi-close-time-opn ~
fi-close-time-hms-opn fi-fo-cls fi-fo-opn fi-open-id-cls fi-open-id-opn ~
fi-close-id-cls fi-close-id-opn 
&Scoped-Define DISPLAYED-OBJECTS fi-obj-type fi-obj-code fi-sys-date-cls ~
fi-sys-date-opn fi-open-time-cls fi-open-time-hms-cls fi-open-time-opn ~
fi-open-time-hms-opn fi-close-time-cls fi-close-time-hms-cls ~
fi-close-time-opn fi-close-time-hms-opn fi-fo-cls fi-fo-opn fi-open-id-cls ~
fi-open-id-opn fi-close-id-cls fi-close-id-opn fi-db-num 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO 
     LABEL "&Выход" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help 
     LABEL "Помо&щь" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-rollback 
     LABEL "Откатить" 
     SIZE 10 BY 1.

DEFINE BUTTON b-sel-obj 
     LABEL ">" 
     SIZE 3 BY 1.

DEFINE VARIABLE fi-close-id-cls AS CHARACTER FORMAT "X(256)":U 
     LABEL "Закрыл" 
     VIEW-AS FILL-IN 
     SIZE 25.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-close-id-opn AS CHARACTER FORMAT "X(256)":U 
     LABEL "Закрыл" 
     VIEW-AS FILL-IN 
     SIZE 25.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-close-time-cls AS INTEGER FORMAT ">>>>>>9":U INITIAL ? 
     LABEL "Закрыта" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-close-time-hms-cls AS CHARACTER FORMAT "X(8)":U 
     VIEW-AS FILL-IN 
     SIZE 9 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-close-time-hms-opn AS CHARACTER FORMAT "X(8)":U 
     VIEW-AS FILL-IN 
     SIZE 9 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-close-time-opn AS INTEGER FORMAT ">>>>>>9":U INITIAL ? 
     LABEL "Закрыта" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-db-num AS INTEGER FORMAT ">>>>9":U INITIAL 0 
     LABEL "БД" 
      VIEW-AS TEXT 
     SIZE 9.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-fo-cls AS DECIMAL FORMAT ">>>>>>>>>>>>>9.999999":U INITIAL ? 
     LABEL "ФО" 
     VIEW-AS FILL-IN 
     SIZE 29.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-fo-opn AS DECIMAL FORMAT ">>>>>>>>>>>>>9.999999":U INITIAL ? 
     LABEL "ФО" 
     VIEW-AS FILL-IN 
     SIZE 29.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-obj-code AS INTEGER FORMAT ">>>>9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 6 BY 1 NO-UNDO.

DEFINE VARIABLE fi-obj-type AS CHARACTER FORMAT "X(3)":U 
     LABEL "Объект" 
     VIEW-AS FILL-IN 
     SIZE 4.5 BY 1 NO-UNDO.

DEFINE VARIABLE fi-open-id-cls AS CHARACTER FORMAT "X(256)":U 
     LABEL "Открыл" 
     VIEW-AS FILL-IN 
     SIZE 25.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-open-id-opn AS CHARACTER FORMAT "X(256)":U 
     LABEL "Открыл" 
     VIEW-AS FILL-IN 
     SIZE 25.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-open-time-cls AS INTEGER FORMAT ">>>>>>9":U INITIAL ? 
     LABEL "Открыта" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-open-time-hms-cls AS CHARACTER FORMAT "X(8)":U 
     VIEW-AS FILL-IN 
     SIZE 9 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-open-time-hms-opn AS CHARACTER FORMAT "X(8)":U 
     VIEW-AS FILL-IN 
     SIZE 9 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-open-time-opn AS INTEGER FORMAT ">>>>>>9":U INITIAL ? 
     LABEL "Открыта" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-sys-date-cls AS DATE FORMAT "99/99/9999":U 
     LABEL "Дата" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-sys-date-opn AS DATE FORMAT "99/99/9999":U 
     LABEL "Дата" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 35.5 BY 7.25.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 35 BY 7.25.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-rollback AT ROW 1 COL 11
     b-help AT ROW 1 COL 61
     fi-obj-type AT ROW 2 COL 24 COLON-ALIGNED
     fi-obj-code AT ROW 2 COL 29 COLON-ALIGNED NO-LABEL
     b-sel-obj AT ROW 2 COL 37.5
     fi-sys-date-cls AT ROW 5 COL 6.63 COLON-ALIGNED
     fi-sys-date-opn AT ROW 5 COL 42.38 COLON-ALIGNED
     fi-open-time-cls AT ROW 6 COL 9.5 COLON-ALIGNED
     fi-open-time-hms-cls AT ROW 6 COL 24 COLON-ALIGNED NO-LABEL
     fi-open-time-opn AT ROW 6 COL 45.38 COLON-ALIGNED
     fi-open-time-hms-opn AT ROW 6 COL 59.88 COLON-ALIGNED NO-LABEL
     fi-close-time-cls AT ROW 7 COL 9.5 COLON-ALIGNED
     fi-close-time-hms-cls AT ROW 7 COL 24 COLON-ALIGNED NO-LABEL
     fi-close-time-opn AT ROW 7 COL 45.38 COLON-ALIGNED
     fi-close-time-hms-opn AT ROW 7 COL 59.88 COLON-ALIGNED NO-LABEL
     fi-fo-cls AT ROW 8 COL 4.5 COLON-ALIGNED
     fi-fo-opn AT ROW 8 COL 40.38 COLON-ALIGNED
     fi-open-id-cls AT ROW 9 COL 8.5 COLON-ALIGNED
     fi-open-id-opn AT ROW 9 COL 44.38 COLON-ALIGNED
     fi-close-id-cls AT ROW 10 COL 8.5 COLON-ALIGNED
     fi-close-id-opn AT ROW 10 COL 44.38 COLON-ALIGNED
     fi-db-num AT ROW 2.25 COL 4 COLON-ALIGNED
     "Текущая дата на объекте" VIEW-AS TEXT
          SIZE 29.5 BY .67 AT ROW 4 COL 37
          FGCOLOR 4 
     "Последняя закрытая дата" VIEW-AS TEXT
          SIZE 29.5 BY .67 AT ROW 4 COL 2
          FGCOLOR 4 
     RECT-1 AT ROW 4.75 COL 1.5
     RECT-2 AT ROW 4.75 COL 37.5
     SPACE(0.49) SKIP(0.28)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Откат даты на объекте"
         DEFAULT-BUTTON b-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_clients B "?" ? ub clients
      TABLE: buf_sys-ctrl B "?" ? ub sys-ctrl
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON b-rollback IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       fi-close-id-cls:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN 
       fi-close-id-opn:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN 
       fi-close-time-cls:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN 
       fi-close-time-hms-cls:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN 
       fi-close-time-hms-opn:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN 
       fi-close-time-opn:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN fi-db-num IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       fi-fo-cls:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN 
       fi-fo-opn:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN 
       fi-open-id-cls:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN 
       fi-open-id-opn:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN 
       fi-open-time-cls:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN 
       fi-open-time-hms-cls:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN 
       fi-open-time-hms-opn:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN 
       fi-open-time-opn:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN 
       fi-sys-date-cls:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN 
       fi-sys-date-opn:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Откат даты на объекте */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-rollback
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-rollback Dialog-Frame
ON CHOOSE OF b-rollback IN FRAME Dialog-Frame /* Откатить */
DO: 

run  proc-sel-doc in this-procedure no-error .
/*  run proc-cor-date in this-procedure no-error .*/
 
  if error-status :error = yes
  then do:
    message
      return-value skip
      error-status :get-message(1) skip
      error-status :get-message(2) skip
    view-as alert-box error.
    run proc-clr-info in this-procedure .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel-obj Dialog-Frame
ON CHOOSE OF b-sel-obj IN FRAME Dialog-Frame /* > */
DO:
  run proc-sel-obj in this-procedure no-error .
  if error-status :error
  then do:
    message
      return-value skip
      error-status :get-message(1) skip
      error-status :get-message(2) skip
    view-as alert-box error.
    run proc-clr-info in this-procedure .
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-obj-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-obj-code Dialog-Frame
ON LEAVE OF fi-obj-code IN FRAME Dialog-Frame
DO:
/*  run proc-sel-obj in this-procedure no-error .*/
/*  if error-status :error*/
/*  then do:*/
/*    return no-apply.*/
/*  end.*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-obj-code Dialog-Frame
ON RETURN OF fi-obj-code IN FRAME Dialog-Frame
DO:
  run proc-sel-obj in this-procedure no-error .
  if error-status :error
  then do:
    message
      return-value skip
      error-status :get-message(1) skip
      error-status :get-message(2) skip
    view-as alert-box error.
    run proc-clr-info in this-procedure .
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-obj-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-obj-type Dialog-Frame
ON LEAVE OF fi-obj-type IN FRAME Dialog-Frame /* Объект */
DO:
  /*!*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-obj-type Dialog-Frame
ON RETURN OF fi-obj-type IN FRAME Dialog-Frame /* Объект */
DO:
  /*!*/

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

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN my-enable in this-procedure .
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
  DISPLAY fi-obj-type fi-obj-code fi-sys-date-cls fi-sys-date-opn 
          fi-open-time-cls fi-open-time-hms-cls fi-open-time-opn 
          fi-open-time-hms-opn fi-close-time-cls fi-close-time-hms-cls 
          fi-close-time-opn fi-close-time-hms-opn fi-fo-cls fi-fo-opn 
          fi-open-id-cls fi-open-id-opn fi-close-id-cls fi-close-id-opn 
          fi-db-num 
      WITH FRAME Dialog-Frame.
  ENABLE b-exit RECT-1 RECT-2 b-help fi-obj-type fi-obj-code b-sel-obj 
         fi-sys-date-cls fi-sys-date-opn fi-open-time-cls fi-open-time-hms-cls 
         fi-open-time-opn fi-open-time-hms-opn fi-close-time-cls 
         fi-close-time-hms-cls fi-close-time-opn fi-close-time-hms-opn 
         fi-fo-cls fi-fo-opn fi-open-id-cls fi-open-id-opn fi-close-id-cls 
         fi-close-id-opn 
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

  find first buf_sys-ctrl no-lock .

  assign
    fi-db-num   = buf_sys-ctrl.db-num
    fi-obj-type = {&shop}
  .
  display
    fi-obj-type
    fi-obj-code
    fi-sys-date-cls
    fi-sys-date-opn
    fi-open-time-cls
    fi-open-time-hms-cls
    fi-open-time-opn
    fi-open-time-hms-opn
    fi-close-time-cls
    fi-close-time-hms-cls
    fi-close-time-opn
    fi-close-time-hms-opn
    fi-fo-cls
    fi-fo-opn
    fi-db-num
    fi-open-id-cls
    fi-close-id-cls
    fi-open-id-opn
    fi-close-id-opn
  with frame {&frame-name}.
  enable
    b-exit
    b-help
    b-sel-obj
/*    rect-1 */
/*    rect-2 */
    fi-obj-type fi-obj-code
/*    fi-sys-date-cls fi-sys-date-opn fi-open-time-cls fi-open-time-hms-cls*/
/*    fi-open-time-opn fi-open-time-hms-opn fi-close-time-cls*/
/*    fi-close-time-hms-cls fi-close-time-opn fi-close-time-hms-opn*/
/*    fi-fo-cls fi-fo-opn*/
  with frame {&frame-name}.
  view frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-clr-info Dialog-Frame 
PROCEDURE proc-clr-info :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  assign
    fi-sys-date-cls       = ?
    fi-open-time-cls      = ?
    fi-open-time-hms-cls  = ?
    fi-close-time-cls     = ?
    fi-close-time-hms-cls = ?
    fi-fo-cls             = ?
    fi-sys-date-opn       = ?
    fi-open-time-opn      = ?
    fi-open-time-hms-opn  = ?
    fi-close-time-opn     = ?
    fi-close-time-hms-opn = ?
    fi-fo-opn             = ?
    fi-open-id-cls        = ?
    fi-close-id-cls       = ?
    fi-open-id-opn        = ?
    fi-close-id-opn       = ?
  .
  display
    fi-sys-date-cls
    fi-open-time-cls
    fi-open-time-hms-cls
    fi-close-time-cls
    fi-close-time-hms-cls
    fi-fo-cls
    fi-sys-date-opn
    fi-open-time-opn
    fi-open-time-hms-opn
    fi-close-time-opn
    fi-close-time-hms-opn
    fi-fo-opn
    fi-open-id-cls
    fi-close-id-cls
    fi-open-id-opn
    fi-close-id-opn
  with frame {&frame-name} .
  disable
    b-rollback
  with frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-cor-date Dialog-Frame 
PROCEDURE proc-cor-date :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define buffer cor_obj-date for ub.obj-date.
  define buffer buf_obj-date for ub.obj-date.

  define variable v-log as logical   no-undo .
do
on error undo, return error return-value
:
  message
    substitute("Откатить дату с &1 на &2 ?" , fi-sys-date-opn, fi-sys-date-cls) skip
    "Внимательно проверьте дату перед тем как произвести откат!"
  view-as alert-box question buttons yes-no update v-log.

  if v-log <> yes then do:
    return . /* --->>>--- */
  end.

  find first buf_obj-date no-lock
    where buf_obj-date.obj-type   = fi-obj-type
      and buf_obj-date.obj-code   = fi-obj-code
      and buf_obj-date.sys-date   = fi-sys-date-cls
      and buf_obj-date.status_    = {&objdt-closed}
      and buf_obj-date.fact-order = fi-fo-cls
  no-error.
  if not available buf_obj-date
  then do:
    return error substitute( "Утилита не может быть запущена: Не прошла проверка предыдущей даты.&1&2&1&3&1&4&1&5&1&6"
                           , {&new-line}
                           , fi-obj-type
                           , fi-obj-code
                           , fi-sys-date-cls
                           , {&objdt-closed}
                           , fi-fo-cls
                           ) .
  end.

  if buf_obj-date.open-time  <> fi-open-time-cls
  or buf_obj-date.close-time <> fi-close-time-cls
  then do:
    return error substitute( "Утилита не может быть запущена: Не прошла проверка предыдущей даты. Время открытия/закрытия не совпадают!&1&2&1&3"
                           , {&new-line}
                           , fi-open-time-cls
                           , fi-close-time-cls
                           ) .
  end.

  on delete of ub.obj-date override do: end.
  on write of ub.obj-date override do: end.

  _rollback:
  do transaction
  on error undo _rollback, return error return-value
  on endkey undo _rollback, return error return-value
  :
    /* ищем нашу корявку */
    find first cor_obj-date exclusive-lock
      where cor_obj-date.obj-type   = fi-obj-type
        and cor_obj-date.obj-code   = fi-obj-code
        and cor_obj-date.sys-date   = fi-sys-date-opn
        and cor_obj-date.status_    = {&objdt-current}
    no-error.
    if not available cor_obj-date
    then do:
      return error substitute( "Невозможно удалить несуществующую запись.&1&2&1&3&1&4&1&5"
                             , {&new-line}
                             , fi-obj-type
                             , fi-obj-code
                             , fi-sys-date-opn
                             , {&objdt-current}
                             ) .
    end.
/*    if cor_obj-date.open-date <> fi-open-time-opn*/
/*    or cor_obj-date.open-time <> fi-close-time-opn*/
/*    then do:*/
/*      return error substitute( "Невозможно удалить несуществующую запись. Не прошли проверки записи.&1&2&1&3"*/
/*                             , {&new-line}*/
/*                             , fi-open-time-opn*/
/*                             , fi-close-time-opn*/
/*                             ) .*/
/*    end.*/
    delete cor_obj-date.
    find current buf_obj-date exclusive-lock .
    assign
        buf_obj-date.status_    = {&objdt-current}
        buf_obj-date.close-date = ?
        buf_obj-date.close-time = 0
        buf_obj-date.close-id   = ""
        buf_obj-date.fact-order = 0
    .
  end.

  on delete of ub.obj-date revert.
  on write of ub.obj-date revert.

  run proc-obj-dates in this-procedure ( input fi-obj-type
                                       , input fi-obj-code
                                       ) .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-obj-dates Dialog-Frame 
PROCEDURE proc-obj-dates :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .

define buffer buf_obj-date  for ub.obj-date.
define buffer sch_obj-date  for ub.obj-date.
     
do
on error undo, return error return-value
:
  find last buf_obj-date
    where buf_obj-date.obj-type   = p-obj-type
      and buf_obj-date.obj-code   = p-obj-code
      and buf_obj-date.status_    = {&objdt-closed}
  no-error .
  if not available buf_obj-date
  then do:
    return error substitute( "На объекте &1 &2 не найдено закрытых дат."
                           , p-obj-type
                           , p-obj-code
                           ) .
  end.
  assign
    fi-sys-date-cls       = buf_obj-date.sys-date
    fi-open-time-cls      = buf_obj-date.open-time
    fi-open-time-hms-cls  = string( buf_obj-date.open-time , "hh:mm:ss" )
    fi-close-time-cls     = buf_obj-date.close-time
    fi-close-time-hms-cls = string(buf_obj-date.close-time , "hh:mm:ss" )
    fi-fo-cls             = buf_obj-date.fact-order
    fi-open-id-cls        = usrfulnf(buf_obj-date.open-id)
    fi-close-id-cls       = usrfulnf(buf_obj-date.close-id)
  .


/*    return error substitute( "На объекте &1 &2 не найдено закрытых дат."*/
/*                           , p-obj-type*/
/*                           , p-obj-code*/
/*                           ) .*/
  find first buf_obj-date no-lock
    where buf_obj-date.obj-type   = p-obj-type
      and buf_obj-date.obj-code   = p-obj-code
      and buf_obj-date.status_    = {&objdt-current}
  no-error.
  if not available buf_obj-date
  then do:
    return error substitute( "На объекте &1 &2 не найдена дата в статусе &3."
                           , p-obj-type
                           , p-obj-code
                           , {&objdt-current}
                           ) .
  end.

  find first sch_obj-date no-lock
    where sch_obj-date.obj-type   = buf_obj-date.obj-type
      and sch_obj-date.obj-code   = buf_obj-date.obj-code
      and sch_obj-date.status_    = buf_obj-date.status_
      and recid(sch_obj-date)    <> recid(buf_obj-date)
  no-error .
  if available sch_obj-date
  then do: 
    return error substitute( "На объекте &1 &2 найдено две даты в статусе &3."
                           , p-obj-type
                           , p-obj-code
                           , {&objdt-current}
                           ) .
  end.

  assign
    fi-sys-date-opn       = buf_obj-date.sys-date
    fi-open-time-opn      = buf_obj-date.open-time
    fi-open-time-hms-opn  = string( buf_obj-date.open-time , "hh:mm:ss" )
    fi-close-time-opn     = buf_obj-date.close-time
    fi-close-time-hms-opn = string(buf_obj-date.close-time , "hh:mm:ss" )
    fi-fo-opn             = buf_obj-date.fact-order
    fi-open-id-opn        = usrfulnf(buf_obj-date.open-id)
    fi-close-id-opn       = usrfulnf(buf_obj-date.close-id)
  .

  display
    fi-sys-date-cls
    fi-open-time-cls
    fi-open-time-hms-cls
    fi-close-time-cls
    fi-close-time-hms-cls
    fi-fo-cls
    fi-sys-date-opn
    fi-open-time-opn
    fi-open-time-hms-opn
    fi-close-time-opn
    fi-close-time-hms-opn
    fi-fo-opn
    fi-open-id-cls
    fi-close-id-cls
    fi-open-id-opn
    fi-close-id-opn
  with frame {&frame-name} .
  enable
    b-rollback
  with frame {&frame-name}.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-sel-doc Dialog-Frame 
PROCEDURE proc-sel-doc :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    define buffer buf_trn-doc  for trn-doc.
    define buffer buf_obj-date for obj-date.
    define buffer buf_rvs-doc  for rvs-doc.
    define buffer buf_price-doc for price-doc.
    do
        on error undo, return error return-value
        :


          find first buf_price-doc where
          buf_price-doc.obj-code = fi-obj-code
          and
          buf_price-doc.obj-type = fi-obj-type
          and
          buf_price-doc.fact-order > fi-fo-cls
          no-error.
          
          if available buf_price-doc
          then do:
              return error substitute ("На объекте, на котором коректируется дата ,существуют документы с fact-order больше, чем дата которую делаем текущей "     ).
        end.



        find first buf_rvs-doc where       
        buf_rvs-doc.obj-code = fi-obj-code                                                                                                                                                                                                                                            
            and                                                                                                                                                   
            buf_rvs-doc.obj-type = fi-obj-type                                                                                                                    
            and                                                                                                                                                   
            buf_rvs-doc.fact-order > fi-fo-cls                                                                                          
            no-error.

        if available buf_rvs-doc
            then
        do:
            return error substitute ("На объекте, на котором коректируется дата ,существуют документы с fact-order больше, чем дата которую делаем текущей "     ).
        end.


        find first buf_trn-doc
            where

            buf_trn-doc.obj-code = fi-obj-code
            and
            buf_trn-doc.obj-type = fi-obj-type
            and buf_trn-doc.fact-order > fi-fo-cls
            no-error.

        if available buf_trn-doc

            then 
        do:
            return error substitute ("На объекте, на котором коректируется дата ,существуют документы с fact-order больше, чем дата которую делаем текущей "     ).
 
        /* end.*/
        end.
    end.
    run proc-cor-date in this-procedure no-error .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-sel-obj Dialog-Frame 
PROCEDURE proc-sel-obj :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-obj-type-list as character no-undo .

do
on error undo, return error return-value
:

 assign frame {&frame-name}
  fi-obj-type
  fi-obj-code
 .
 assign
  v-obj-type-list = {&stock} + ',' + {&shop}
 .
 if lookup(fi-obj-type , v-obj-type-list ) > 0
 then do:
  find first buf_clients no-lock
    where buf_clients.obj-type = fi-obj-type
      and buf_clients.obj-code = fi-obj-code
  no-error .
 end.

 if not available buf_clients
 then do:
  return error substitute( "Объект &1 &2 не найден"
                         , fi-obj-type
                         , fi-obj-code
                         ) .
 end.

 run proc-obj-dates in this-procedure ( input buf_clients.obj-type
                                      , input buf_clients.obj-code
                                      ) .
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

