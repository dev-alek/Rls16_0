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

Текущие остатки серийных МЦ (параметры)

Автор: Белоусов Илья Александрович
Дата создания: 05/12/09
Author: Ilia Belousov
Creation date: 05/12/09

Input:

Output:

*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Текущие остатки серийных МЦ (параметры)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/rep-bt.i   }
{ gbl/usr-flt.i  }

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
/*
DEFINE TEMP-TABLE tt-grp NO-UNDO
      FIELD grp-name    as character
      FIELD grp-code    as integer

      INDEX pi IS PRIMARY UNIQUE
            grp-code
.
*/

define variable v-wth-list         as character    no-undo.

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
&Scoped-Define ENABLED-OBJECTS RECT-7 v-free-zone v-put-zone ed-wth rs-wth ~
bt-wth
&Scoped-Define DISPLAYED-OBJECTS v-free-zone v-put-zone ed-wth rs-wth

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-wth
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "&Изменить"
     SIZE 3 BY 1.

DEFINE VARIABLE ed-wth AS CHARACTER
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 51.5 BY 13
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE rs-wth AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", 1,
"Выборочно", 2
     SIZE 12 BY 2 NO-UNDO.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 71.38 BY 16.25.

DEFINE VARIABLE v-free-zone AS LOGICAL INITIAL no
     LABEL "Свободные"
     VIEW-AS TOGGLE-BOX
     SIZE 13 BY .83 NO-UNDO.

DEFINE VARIABLE v-put-zone AS LOGICAL INITIAL no
     LABEL "Погашенные"
     VIEW-AS TOGGLE-BOX
     SIZE 14 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     v-free-zone AT ROW 2 COL 4 WIDGET-ID 38
     v-put-zone AT ROW 3 COL 4 WIDGET-ID 40
     ed-wth AT ROW 4 COL 20.5 NO-LABEL WIDGET-ID 28
     rs-wth AT ROW 4.79 COL 4 NO-LABEL WIDGET-ID 34
     bt-wth AT ROW 5.79 COL 16 WIDGET-ID 18
     "Номиналы:" VIEW-AS TEXT
          SIZE 15 BY .67 AT ROW 4.04 COL 4
          FGCOLOR 4
     RECT-7 AT ROW 1.25 COL 2
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
   NOT-VISIBLE FRAME-NAME Size-to-Fit                                   */
ASSIGN
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.

ASSIGN
       ed-wth:READ-ONLY IN FRAME F-Main        = TRUE.

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

&Scoped-define SELF-NAME bt-wth
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-wth s-object
ON CHOOSE OF bt-wth IN FRAME F-Main /* Изменить */
DO:
    assign
      rs-wth = 2
    .
    display
      rs-wth
    with frame {&frame-name}.
    run select-wth in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-wth
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-wth s-object
ON VALUE-CHANGED OF rs-wth IN FRAME F-Main
DO:
define buffer buf_wth-par for ub.wth-par.
define buffer buf_wealth  for ub.wealth .

   assign
      rs-wth
   .
   case rs-wth :
   when 1 then do:
      assign
         ed-wth      = "Все"
         v-wth-list  = ""
      .
      for each buf_wth-par
         no-lock
         ,
         FIRST buf_wealth
         WHERE buf_wealth.wth-code  = buf_wth-par.wth-code
           and buf_wealth.is-ser    = 1
/*         and   buf_wealth.stts      = 0*/
         no-lock
         :
         assign
            v-wth-list = v-wth-list
                        + string( buf_wth-par.wth-code )
                        + {&delim-par}
                        + string( buf_wth-par.par-code )
                        + {&comma-char}
         .
      end.
      assign
         v-wth-list = trim( v-wth-list, {&comma-char} )
      .

      display
         ed-wth
      with frame {&frame-name}.
   end.
   when 2 then do:
      apply "choose" to bt-wth.
   end.
   otherwise do:
      return no-apply.
   end.
   end case.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE convert-wth-code s-object
PROCEDURE convert-wth-code :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input  parameter p-code-list   as character no-undo .
define output parameter p-recid-list  as character no-undo .

define buffer buf_wth-par for ub.wth-par.

define variable v-i               as integer   no-undo .

do
on error undo, return error return-value
:
   do v-i = 1 to num-entries( p-code-list , {&comma-char} )
   :
      find first buf_wth-par
           where buf_wth-par.wth-code = integer( ENTRY(1, entry( v-i, p-code-list, {&comma-char}), {&delim-par} ))
             and buf_wth-par.par-code = integer( ENTRY(2, entry( v-i, p-code-list, {&comma-char}), {&delim-par} ))
           no-lock
         no-error
         .
      if available buf_wth-par
      then do:
      assign
         p-recid-list = p-recid-list + string( recid(buf_wth-par) ) + {&comma-char}
      .
      end.
   end.
   assign
      p-recid-list = trim( p-recid-list, {&comma-char} )
   .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE convert-wth-recid s-object
PROCEDURE convert-wth-recid :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input  parameter p-recid-list  as character no-undo .
define output parameter p-code-list   as character no-undo .

define buffer buf_wth-par for ub.wth-par.

define variable v-i               as integer   no-undo .

do
on error undo, return error return-value
:
   do v-i = 1 to num-entries( p-recid-list, {&comma-char} )
   :
      find first buf_wth-par no-lock
         where recid(buf_wth-par) = integer( entry( v-i, p-recid-list ) )
      no-error .
      if available buf_wth-par
      then do:
         assign
            p-code-list = p-code-list
                        + string( buf_wth-par.wth-code )
                        + {&delim-par}
                        + string( buf_wth-par.par-code )
                        + {&comma-char}
         .
      end.
   end.
   assign
      p-code-list = trim( p-code-list, {&comma-char} )
   .
end.
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
   define buffer buf_wth-par for ub.wth-par .
   define buffer buf_wealth  for ub.wealth .

   define variable v-value-character as character no-undo .
   define variable v-value-date as date no-undo .
   define variable v-value-decimal as decimal no-undo .
   define variable v-value-integer as INTEGER no-undo .
   define variable v-value-logical AS LOGICAL no-undo .
   define variable v-param-type as character no-undo .

   define variable v-rs-cli-grp      as logical   no-undo.
   define variable v-rs-wth          as logical   no-undo.
   define variable v-void-logical-3        as logical      no-undo.
   define variable v-void-logical-4        as logical      no-undo.
   define variable v-i               as integer   no-undo .
   define variable v-cli-grp-lst     as character    no-undo.

do
on error undo, return error
:
   RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .

   run uf-get (
        input {&uf-wthrst}
      , input  v-cntxt-userid
      , output v-cli-grp-lst
      , output v-wth-list
      , output v-free-zone
      , output v-put-zone
      , output v-rs-wth
      , output v-void-logical-4
   ) .

   if v-rs-wth = no
   then do:
      assign
         rs-wth  = 1
         ed-wth  = "Все":u
         v-wth-list = "":U
      .

      for each buf_wth-par
         no-lock
         ,
         FIRST buf_wealth
         WHERE buf_wealth.wth-code  = buf_wth-par.wth-code
           and buf_wealth.is-ser    = 1
/*         and   buf_wealth.stts      = 0*/
         no-lock
         :
         assign
            v-wth-list = v-wth-list
                        + string( buf_wth-par.wth-code )
                        + {&delim-par}
                        + string( buf_wth-par.par-code )
                        + {&comma-char}
         .
      end.
      assign
         v-wth-list = trim( v-wth-list, {&comma-char} )
      .

   end.
   else do:
      assign
         rs-wth = 2
      .
      do v-i = 1 to num-entries(v-wth-list, {&comma-char} )
      :
         find first buf_wth-par
              where buf_wth-par.wth-code = integer( ENTRY(1, entry( v-i, v-wth-list, {&comma-char}), {&delim-par} ))
                and buf_wth-par.par-code = integer( ENTRY(2, entry( v-i, v-wth-list, {&comma-char}), {&delim-par} ))
              no-lock
              no-error
              .
         if available buf_wth-par
         then do:
            assign
               ed-wth = ed-wth + STRING(buf_wth-par.par-val, ">>>>>9") + " " + buf_wth-par.par-unit + {&new-line}
            .
         end.
      end.
   end.
   display
      v-free-zone
      v-put-zone
      rs-wth
      ed-wth
   with frame {&frame-name}.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета с любыми параметрами
------------------------------------------------------------------------------*/

do
on error undo, return error
with frame {&frame-name}
:
   ASSIGN
     v-free-zone
     v-put-zone
     rs-wth
   .

   IF  v-free-zone = FALSE
   AND v-put-zone  = FALSE
   THEN DO:
      message
         "Не выбрана зона"
         skip
      view-as alert-box error.
      return no-apply.
   END.

   IF v-wth-list = "":U
   THEN DO:
      message
         "Не выбран список материальных ценностей"
         skip
      view-as alert-box error.
      return no-apply.
   END.

   run uf-set (
        input {&uf-wthrst}
      , input v-cntxt-userid
      , input "":U
      , input v-wth-list
      , input v-free-zone
      , input v-put-zone
      , input (rs-wth <> 1)
      , input no
   ) .

   run rep/r-wthrst.p ( input my-handle
                      , input v-wth-list
                      , input v-free-zone
                      , input v-put-zone
                      , input (rs-wth = 1)
                      , input ((x-SelectObject = "{&o-all}":U) OR (x-SelectObject = "все"))
                      ) .
end.
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
    ReportHeader =  ReportHeader + "Группы объектов: " + {&new-line} + {&new-line} +
                    "Материальные ценности: " + {&new-line} + ed-wth
.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-cli-grp s-object
PROCEDURE select-cli-grp :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer buf_cli-grp     for ub.cli-grp .
define variable v-count    as integer      no-undo.

do
on error undo, return error
:
end.  /* do on error */
END PROCEDURE. /* select-cli-grp */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-wth s-object
PROCEDURE select-wth :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
  define buffer buf_wth-par for ub.wth-par.

  define variable v-wth-recid-list  as character no-undo .
  define variable v-i               as integer   no-undo .

  run convert-wth-code in this-procedure ( input v-wth-list
                                         , output v-wth-recid-list
                                         ).
   run ref/wthp-ref.w ( INPUT my-handle
                     , INPUT "b-sel,b-mark"
                     , INPUT v-cntxt-host-code-obj
                     , INPUT v-cntxt-obj-type
                     , INPUT v-cntxt-obj-code
                     , INPUT 'ser_wealth':U
                     , INPUT ?
                     , INPUT-OUTPUT v-wth-recid-list
                     ) .

  assign
    ed-wth = "":u
  .
  do v-i = 1 to num-entries( v-wth-recid-list, {&comma-char} )
  :
    find first buf_wth-par no-lock
      where recid(buf_wth-par) = integer( entry( v-i, v-wth-recid-list ) )
    no-error .
    if available buf_wth-par
    then do:
      assign
        ed-wth = ed-wth + STRING(buf_wth-par.par-val, ">>>>>9") + " " + buf_wth-par.par-unit + {&new-line}
      .
    end.
  end.

  run convert-wth-recid in this-procedure ( input v-wth-recid-list
                                          , output v-wth-list
                     ) .
  display
    ed-wth
  with frame {&frame-name}.

end.  /* do on error */
END PROCEDURE. /* select-wth */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME