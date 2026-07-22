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

Отчет о остатках серийных МЦ (вторая закладка)

Автор: Белоусов Илья Александрович
Дата создания: 05/07/08
Author: Ilia Belousov
Creation date: 05/07/08

Input:

Output:

*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Остатки материальных ценностей (ЗАКЛАДКА №2)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/rep-bt.i   }
{ gbl/onewin.i   }
{ gbl/thbjattr.i }
{ gbl/usr-flt.i }
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

define variable v-wth-pl-list     as character    no-undo.
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
&Scoped-Define ENABLED-OBJECTS RECT-7 ed-wth-pl rs-wth-pl bt-wth-pl ~
ed-wth rs-wth bt-wth
&Scoped-Define DISPLAYED-OBJECTS ed-wth-pl rs-wth-pl ed-wth rs-wth

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-wth-pl
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "&Изменить"
     SIZE 3 BY 1.

DEFINE BUTTON bt-wth
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "&Изменить"
     SIZE 3 BY 1.

DEFINE VARIABLE ed-wth-pl AS CHARACTER
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 43.5 BY 7.25
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE ed-wth AS CHARACTER
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 43.5 BY 7.25
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE rs-wth-pl AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", 1,
"Выборочно", 2
     SIZE 12 BY 2 NO-UNDO.

DEFINE VARIABLE rs-wth AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", 1,
"Выборочно", 2
     SIZE 12 BY 2 NO-UNDO.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 71.38 BY 16.25.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main

     "Материальные ценности:" VIEW-AS TEXT
          SIZE 21 BY .67 AT ROW 2.25 COL 4 WIDGET-ID 2
          FGCOLOR 4
     ed-wth AT ROW 2 COL 28.5 NO-LABEL WIDGET-ID 20
     rs-wth AT ROW 3 COL 4 NO-LABEL WIDGET-ID 30
     bt-wth AT ROW 4 COL 16 WIDGET-ID 14

     "Места хранения:" VIEW-AS TEXT
          SIZE 22.5 BY .67 AT ROW 10.25 COL 4
          FGCOLOR 4
     ed-wth-pl AT ROW 10 COL 28.5 NO-LABEL WIDGET-ID 28
     rs-wth-pl AT ROW 11 COL 4 NO-LABEL WIDGET-ID 34
     bt-wth-pl AT ROW 12 COL 16 WIDGET-ID 18

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
       ed-wth-pl:READ-ONLY IN FRAME F-Main        = TRUE.

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

&Scoped-define SELF-NAME bt-wth-pl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-wth-pl s-object
ON CHOOSE OF bt-wth-pl IN FRAME F-Main /* Изменить */
DO:
    assign
      rs-wth-pl = 2
    .
    run select-wth-pl in this-procedure.
    display
      rs-wth-pl
      ed-wth-pl
    with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-wth
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-wth s-object
ON CHOOSE OF bt-wth IN FRAME F-Main /* Изменить */
DO:
    assign
      rs-wth = 2
    .
    run select-wth in this-procedure.
    display
      rs-wth
      ed-wth
    with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-wth-pl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-wth-pl s-object
ON VALUE-CHANGED OF rs-wth-pl IN FRAME F-Main
DO:
  assign
    rs-wth-pl
  .
  case rs-wth-pl:
    when 1 then do:
      assign
        ed-wth-pl      = "Все"
      .
      display
        ed-wth-pl
      with frame {&frame-name}.
    end.
    when 2 then do:
      apply "choose" to bt-wth-pl.
    end.
    otherwise do:
      return no-apply.
    end.
  end case.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-wth
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-wth s-object
ON VALUE-CHANGED OF rs-wth IN FRAME F-Main
DO:
  define buffer buf_wealth for ub.wealth.

  assign
    rs-wth
  .
  case rs-wth :
    when 1 then do:
      assign
        ed-wth      = "Все"
        v-wth-list  = ""
      .
      for each buf_wealth
        where buf_wealth.is-ser = 1
          and buf_wealth.stts   = 0
         no-lock
      :
        assign
          v-wth-list = v-wth-list + string(buf_wealth.wth-code) + {&comma-char}
        .
      end.
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

  define buffer buf_wealth for ub.wealth.

  define variable v-i               as integer   no-undo .

  do
  on error undo, return error return-value
  :
    do v-i = 1 to num-entries( p-code-list )
    :
      find first buf_wealth
        where buf_wealth.wth-code = integer( entry( v-i, p-code-list ) )
         no-lock
         no-error
         .
      if available buf_wealth
      then do:
        assign
          p-recid-list = p-recid-list + string( recid(buf_wealth) ) + {&comma-char}
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

  define buffer buf_wealth for ub.wealth.

  define variable v-i               as integer   no-undo .

  do
  on error undo, return error return-value
  :
    do v-i = 1 to num-entries( p-recid-list )
    :
      find first buf_wealth no-lock
        where recid(buf_wealth) = integer( entry( v-i, p-recid-list ) )
      no-error .
      if available buf_wealth
      then do:
        assign
          p-code-list = p-code-list + string( buf_wealth.wth-code ) + {&comma-char}
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

    define buffer buf_wealth  for ub.wealth.
    define buffer buf_wth-place for ub.wth-place .

   define variable v-value-character as character no-undo .
   define variable v-value-date as date no-undo .
   define variable v-value-decimal as decimal no-undo .
   define variable v-value-integer as INTEGER no-undo .
   define variable v-value-logical AS LOGICAL no-undo .
   define variable v-param-type as character no-undo .

    define variable v-rs-wth-pl      as logical   no-undo.
    define variable v-rs-wth          as logical   no-undo.
    define variable v-void-logical-3        as logical      no-undo.
    define variable v-void-logical-4        as logical      no-undo.
    define variable v-found                 as logical      no-undo.
    define variable v-i               as integer   no-undo .
   define variable v-wth-pl-lst     as character    no-undo.
   define variable v-wth-lst         as character    no-undo.

do
on error undo, return error
:
   RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .

    run uf-get (
          input "wthres":U
        , input v-cntxt-userid
        , output v-wth-pl-lst
        , output v-wth-list
        , output v-rs-wth-pl
        , output v-rs-wth
        , output v-void-logical-3
        , output v-void-logical-4
    ) no-error.
    if error-status :error = false
    then do:
      if v-rs-wth-pl = no
      then do:
        assign
          rs-wth-pl  = 1
          ed-wth-pl  = "Все":u
        .
      end.
      else do:
         assign
            rs-wth-pl = 2
            v-wth-pl-list = "":U
         .
         _flt-grp-load:
         do v-i = 1 to num-entries(v-wth-pl-lst)
         :
            find first buf_wth-place
               where RECID(buf_wth-place) = integer( entry( v-i, v-wth-pl-lst, {&comma-char} ) )
               no-lock
               no-error
               .
            if available buf_wth-place
            then do:
               assign
               ed-wth-pl = ed-wth-pl + buf_wth-place.w-p-name + {&new-line}
               v-wth-pl-list = IF v-wth-pl-list = "":U THEN entry( v-i, v-wth-pl-lst, {&comma-char} )
                                                         ELSE v-wth-pl-list + {&comma-char} + entry( v-i, v-wth-pl-lst, {&comma-char} )
               .
            end.
         end.
         end.
      if v-rs-wth = no
      then do:
        assign
          rs-wth  = 1
          ed-wth  = "Все":u
        .
      end.
      else do:
        assign
          rs-wth = 2
          v-wth-list = "":U
        .
         do v-i = 1 to num-entries(v-wth-lst)
         :
            find first buf_wealth
               where buf_wealth.wth-code = integer( entry( v-i, v-wth-lst, {&comma-char} ) )
               no-lock
               no-error
               .
            if available buf_wealth
            then do:
               assign
               ed-wth = ed-wth + buf_wealth.wth-name + {&new-line}
               v-wth-list = IF v-wth-list = "":U THEN entry( v-i, v-wth-lst, {&comma-char} )
                                                ELSE v-wth-list + {&comma-char} + entry( v-i, v-wth-lst, {&comma-char} )

               .
            end.
         end.
         end.
      display
        rs-wth-pl
        rs-wth
        ed-wth-pl
        ed-wth
      with frame {&frame-name}.
    end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета с любыми параметрами
------------------------------------------------------------------------------*/
    define variable v-begin-date            as date         no-undo.
    define variable v-end-date              as date         no-undo.
    define variable v-begin-shift           as integer      no-undo.
    define variable v-end-shift             as integer      no-undo.
    define variable v-counter               as integer      no-undo.
    define variable v-ext-doc-type-list     as character    no-undo.

do
on error undo, return error
:
   IF v-wth-pl-list = "":U
   THEN DO:
      message
         "Не выбран список мест хранения"
         skip
      view-as alert-box information.
      return no-apply.
   END.
   IF v-wth-list = "":U
   THEN DO:
      message
         "Не выбран список материальных ценностей"
         skip
      view-as alert-box information.
      return no-apply.
   END.
   assign
      v-begin-date  = x-Date-Start
      v-end-date    = x-Date-End
      v-begin-shift = x-Shift-Start
      v-end-shift   = x-Shift-End
   .
   run uf-set (
         input "wthres":U
      , input  v-cntxt-userid
      , input v-wth-pl-list
      , input v-wth-list
      , input ( if rs-wth-pl = 1 then no else yes )
      , input ( if rs-wth    = 1 then no else yes )
      , input no
      , input no
   ) .

   run rep/r-wthres.p  ( input my-handle
                       , input (rs-wth    = 1) /*x-Date-Alone   X-date-Start */
                       , input (rs-wth-pl = 1) /*               X-shift-Alone*/
                       , input v-wth-list
                       , input v-wth-pl-list
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
    ReportHeader =  ReportHeader + "Группы объектов: " + {&new-line} + ed-wth-pl + {&new-line} + {&new-line} +
                    "Материальные ценности: " + {&new-line} + ed-wth
.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-wth-pl {&FRAME-NAME}
PROCEDURE select-wth-pl :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer buf_wth-place     for ub.wth-place .
define variable v-count    as integer      no-undo.

   define variable v-wth-pl-lst    as character    no-undo.
   define variable v-i    as integer      no-undo.

do
on error undo, return error
:

    IF v-cntxt-db-num = 0
    THEN DO:
    run ref/wthplref.w
      (input my-handle
      ,input 'b-sel,b-mark'
      ,input v-cntxt-host-code-obj
      ,input v-cntxt-obj-type
      ,input v-cntxt-obj-code
      ,input {&company}
      ,input-output v-wth-pl-lst
      ).
    END.
    ELSE DO:
      run ref/wthplref.w
        (input my-handle
        ,input 'b-sel,b-mark':u
        ,input v-cntxt-host-code-obj
        ,input v-cntxt-obj-type
        ,input v-cntxt-obj-code
        ,input {&g___object}
        ,input-output v-wth-pl-lst
        ).
    END.
    do v-i = 1 to num-entries(v-wth-pl-lst)
      :
      find first buf_wth-place
            where RECID(buf_wth-place) = integer( entry( v-i, v-wth-pl-lst, {&comma-char} ) )
            no-lock
            no-error
            .
         if available buf_wth-place
         then do:
         assign
            ed-wth-pl = ed-wth-pl + buf_wth-place.w-p-name + {&new-line}
            v-wth-pl-list = IF v-wth-pl-list = "":U THEN entry( v-i, v-wth-pl-lst, {&comma-char} )
                                                   ELSE v-wth-pl-list + {&comma-char} + entry( v-i, v-wth-pl-lst, {&comma-char} )
         .
         end.
    end.
end.  /* do on error */
END PROCEDURE. /* select-wth-pl */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-wth {&FRAME-NAME}
PROCEDURE select-wth :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
  define buffer buf_wealth for ub.wealth.

  define variable v-wth-recid-list  as character no-undo .
  define variable v-i               as integer   no-undo .

  run convert-wth-code in this-procedure ( input v-wth-list
                                         , output v-wth-recid-list
                                         ).

   run ref/wth-ref.w ( INPUT my-handle
                     , INPUT "b-sel,b-mark"
                     , INPUT v-cntxt-host-code-obj
                     , INPUT v-cntxt-obj-type
                     , INPUT v-cntxt-obj-code
                     , INPUT 'wth-ser'
                    , INPUT-OUTPUT v-wth-recid-list
                    ) .

  assign
    ed-wth = "":u
  .
  do v-i = 1 to num-entries( v-wth-recid-list )
  :
    find first buf_wealth no-lock
      where recid(buf_wealth) = integer( entry( v-i, v-wth-recid-list ) )
    no-error .
    if available buf_wealth
    then do:
      assign
        ed-wth = ed-wth + buf_wealth.wth-name + {&new-line}
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