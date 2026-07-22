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

Отчет "Почасовая реализация на АЗК" (ЗАКЛАДКА №2)

Автор: Хныкин Павел Андреевич
Дата создания: 07/04/07
Author: Pavel Khnykin
Creation date: 07/04/07

*/

def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Отчет Почасовая реализация на АЗК (ЗАКЛАДКА №2)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ cmp/operlist.i }
{ cmp/cli-list.i cli-list def "new shared" }

/* no app_help.i */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

def var State-source as  WIDGET-HANDLE.
define variable v-time-start-sec  as integer   no-undo .
define variable v-time-end-sec    as integer   no-undo .

def buffer cli-post for ub.clients .
def new  SHARED temp-table g#post NO-UNDO
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    INDEX pi IS UNIQUE PRIMARY obj-type obj-code.

def New SHARED temp-table g#post-f NO-UNDO
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    field grp-code like ub.clients.grp-code
    field grp-name like ub.clients.grp-name
    field lvl-num like  ub.cli-grp.lvl-num
    INDEX pi IS UNIQUE PRIMARY obj-type obj-code
    INDEX p1  obj-name
    .
def var  post-grp_recids as character no-undo .
def var ii as integer no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartViewer
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS fi-date-start fi-date-end fi-time-start ~
fi-time-end
&Scoped-Define DISPLAYED-OBJECTS fi-date-start fi-date-end fi-time-start ~
fi-time-end

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE fi-date-end AS DATE FORMAT "99/99/9999":U
     LABEL "Дата по"
     VIEW-AS FILL-IN
     SIZE 11 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE fi-date-start AS DATE FORMAT "99/99/9999":U
     LABEL "Дата с"
     VIEW-AS FILL-IN
     SIZE 11 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE fi-time-end AS CHARACTER FORMAT "99:99":U
     LABEL "Время по"
     VIEW-AS FILL-IN
     SIZE 6 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE fi-time-start AS CHARACTER FORMAT "99:99":U
     LABEL "Время с"
     VIEW-AS FILL-IN
     SIZE 6 BY 1
     BGCOLOR 15  NO-UNDO.

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     fi-date-start AT ROW 2 COL 9 COLON-ALIGNED
     fi-date-end AT ROW 2 COL 44 COLON-ALIGNED
     fi-time-start AT ROW 3 COL 9 COLON-ALIGNED
     fi-time-end AT ROW 3 COL 44 COLON-ALIGNED
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
         HEIGHT             = 16.75
         WIDTH              = 73.
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
   NOT-VISIBLE Size-to-Fit                                              */
ASSIGN
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.

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

&Scoped-define SELF-NAME fi-date-end
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-date-end s-object
ON LEAVE OF fi-date-end IN FRAME F-Main /* Дата по */
DO:
  assign
      fi-date-end
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-date-start
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-date-start s-object
ON LEAVE OF fi-date-start IN FRAME F-Main /* Дата с */
DO:
  assign fi-date-start.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-time-end
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-time-end s-object
ON LEAVE OF fi-time-end IN FRAME F-Main /* Время по */
DO:
    DEFINE VARIABLE v-ok AS LOGICAL    NO-UNDO.
    run check-time-format in this-procedure ( input self :handle
                                            , output v-ok
                                            ) .
    if not v-ok then do:
        message
            "Неправильное значение времени."
        view-as alert-box error.
        return no-apply.
    end.
    assign
        fi-time-end
    .
    run get-time-in-sec in this-procedure ( input fi-time-end
                                          , output v-time-end-sec
                                          ) no-error .
    if error-status :error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-time-start
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-time-start s-object
ON LEAVE OF fi-time-start IN FRAME F-Main /* Время с */
DO:
  DEFINE VARIABLE v-ok AS LOGICAL    NO-UNDO.
  run check-time-format in this-procedure ( input self :handle
                                          , output v-ok
                                          ) .
  if not v-ok then do:
      message
          "Неправильное значение времени."
      view-as alert-box error.
      return no-apply.
  end.
  assign
      fi-time-start
  .
  run get-time-in-sec in this-procedure ( input fi-time-start
                                        , output v-time-start-sec
                                        ) no-error .
  if error-status :error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK s-object


/* ***************************  Main Block  *************************** */
{ gbl/ed_date.i fi-date-start }
{ gbl/ed_date.i fi-date-end   }
/* If testing in the UIB, initialize the SmartObject. */

&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
  RUN dispatch IN THIS-PROCEDURE ('initialize':U).
&ENDIF

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-time-format s-object
PROCEDURE check-time-format :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-fi-handle as handle  no-undo .
define output parameter p-ok       as logical no-undo .

  define variable v-time-str    as character no-undo .
  define variable v-hh          as integer   no-undo .
  define variable v-mm          as integer   no-undo .

  assign
      v-time-str = p-fi-handle :screen-value
      v-hh = integer(substring(v-time-str,1,2))
      v-mm = integer(substring(v-time-str,4,2))
  .

  if v-hh < 0 or v-hh > 24 then do:
    return.
  end.
  if v-mm < 0 or v-mm > 59 then do:
    return.
  end.
  if v-hh = 24 and v-mm <> 0 then do :
    return.
  end.
  assign
    p-ok = yes
  .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-time-in-sec s-object
PROCEDURE get-time-in-sec :
/*
  Преобразует текстовую строку с временем в формате "HHMM" в integer.
*/
define input  parameter p-str-time as character no-undo .
define output parameter p-int-time as integer   no-undo .
do
on error undo, return error return-value
:
  define variable v-h as integer   no-undo .
  define variable v-m as integer   no-undo .

  if length( p-str-time ) <> 4 then do:
      message
          "Неверный формат времени"
      view-as alert-box error.
      undo, return error.
  end.
  assign
    v-h = integer( substring( p-str-time,1,2) )
    v-m = integer( substring( p-str-time,3,2) )
  .
  if v-h < 0 or v-h > 24 then do:
      message
          "Диапазон часов задан неверно"
      view-as alert-box error.
      undo, return error.
  end.
  if v-m < 0 or v-m > 59 then do :
      message
          "Диапазон минут задан неверно"
      view-as alert-box error.
    undo, return error.
  end.
  assign
    p-int-time = v-h * 3600 + v-m * 60
  .

end.

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
  assign
      fi-date-start = today - 1
      fi-date-end   = today
      fi-time-start = "0700":U
      fi-time-end   = "0700":U
  .
  run get-time-in-sec in this-procedure ( input fi-time-start
                                        , output v-time-start-sec
                                        ) .
  run get-time-in-sec in this-procedure ( input fi-time-end
                                        , output v-time-end-sec
                                        ) .
  display
      fi-date-start
      fi-date-end
      fi-time-start
      fi-time-end
  with frame {&frame-name}.
  /* Code placed here will execute AFTER standard behavior.    */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета с любыми параметрами
------------------------------------------------------------------------------*/
 run rep/r-hazkrt.p ( input fi-date-start
                    , input v-time-start-sec
                    , input fi-date-end
                    , input v-time-end-sec
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
  assign
    ReportHeader =    "Диапазон:" + {&new-line}
                   + "    " + "C: " +  string( fi-date-start , "99/99/9999" ) + " " + string( v-time-start-sec , "hh:mm" ) + {&new-line}
                   + "    " + "По: " +  string( fi-date-end , "99/99/9999" ) + " " + string( v-time-end-sec , "hh:mm" ) + {&new-line}
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