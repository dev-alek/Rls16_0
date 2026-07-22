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

Отчет Реестр отоваренных талонов (ЗАКЛАДКА №2)

Автор: Хныкин Павел Андреевич
Дата создания: 05/13/08
Author: Pavel Khnykin
Creation date: 05/13/08

*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Отчет Реестр отоваренных талонов (ЗАКЛАДКА №2)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/rep-bt.i   }
{ gbl/onewin.i   }
{ gbl/thbjattr.i }
{ gbl/usr-flt.i  }

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

define variable v-cli-grp-list     as character    no-undo.
define variable v-cli-grp-out-list as character    no-undo .
define variable v-cli-grp-all      as character    no-undo .
define variable v-obj-out-list     as character    no-undo .
define variable v-wth-list         as character    no-undo .

define temp-table tt-object no-undo
  field id       as integer
  field obj-type as character
  field obj-code as integer
  field obj-name as character
  field selected as logical
index pi is primary unique
  id
index obj
  obj-type
  obj-code
index sel
  selected
.

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
&Scoped-Define ENABLED-OBJECTS RECT-7 ed-grp-obj rs-cli-grp bt-cli-grp ~
ed-grp-obj-out rs-cli-grp-out bt-cli-grp-out bt-cli-out ed-wth rs-wth ~
bt-wth tg-price-detail
&Scoped-Define DISPLAYED-OBJECTS ed-grp-obj rs-cli-grp ed-grp-obj-out ~
rs-cli-grp-out ed-wth rs-wth tg-price-detail

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-cli-grp
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON bt-cli-grp-out
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON bt-cli-out
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON bt-wth
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE VARIABLE ed-grp-obj AS CHARACTER
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 40 BY 5
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE ed-grp-obj-out AS CHARACTER
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 40 BY 5
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE ed-wth AS CHARACTER
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 40 BY 5
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE rs-cli-grp AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", 1,
"Выборочно", 2
     SIZE 12 BY 2 NO-UNDO.

DEFINE VARIABLE rs-cli-grp-out AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", 1,
"Выборочно группы", 2,
"Выборочно объекты", 3
     SIZE 19.5 BY 3 NO-UNDO.

DEFINE VARIABLE rs-wth AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", 1,
"Выборочно", 2
     SIZE 12 BY 2 NO-UNDO.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 69 BY 16.

DEFINE VARIABLE tg-price-detail AS LOGICAL INITIAL no
     LABEL "Детализация по ценам"
     VIEW-AS TOGGLE-BOX
     SIZE 23.5 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     ed-grp-obj AT ROW 1.5 COL 29.13 NO-LABEL WIDGET-ID 20
     rs-cli-grp AT ROW 2.5 COL 3 NO-LABEL WIDGET-ID 30
     bt-cli-grp AT ROW 3.5 COL 15 WIDGET-ID 14
     ed-grp-obj-out AT ROW 6.67 COL 29.13 NO-LABEL WIDGET-ID 38
     rs-cli-grp-out AT ROW 7.75 COL 3 NO-LABEL WIDGET-ID 52
     bt-cli-grp-out AT ROW 8.71 COL 23 WIDGET-ID 50
     bt-cli-out AT ROW 9.75 COL 23 WIDGET-ID 48
     ed-wth AT ROW 11.88 COL 29.13 NO-LABEL WIDGET-ID 28
     rs-wth AT ROW 12.88 COL 3 NO-LABEL WIDGET-ID 34
     bt-wth AT ROW 13.88 COL 15 WIDGET-ID 18
     tg-price-detail AT ROW 16 COL 2 WIDGET-ID 58
     "Материальные ценности:" VIEW-AS TEXT
          SIZE 22.5 BY .67 AT ROW 12.13 COL 2
          FGCOLOR 4
     "Объекты погашения:" VIEW-AS TEXT
          SIZE 26 BY .67 AT ROW 6.92 COL 2 WIDGET-ID 56
          FGCOLOR 4
     "Группы объектов реализации:" VIEW-AS TEXT
          SIZE 27 BY .67 AT ROW 1.75 COL 2 WIDGET-ID 2
          FGCOLOR 4
     RECT-7 AT ROW 1.25 COL 1.13
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
         HEIGHT             = 16.25
         WIDTH              = 69.13.
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
       ed-grp-obj:READ-ONLY IN FRAME F-Main        = TRUE.

ASSIGN
       ed-grp-obj-out:READ-ONLY IN FRAME F-Main        = TRUE.

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

&Scoped-define SELF-NAME bt-cli-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-cli-grp s-object
ON CHOOSE OF bt-cli-grp IN FRAME F-Main
DO:
    assign
      rs-cli-grp = 2
    .
    display
      rs-cli-grp
    with frame {&frame-name}.
    run select-cli-grp in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-cli-grp-out
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-cli-grp-out s-object
ON CHOOSE OF bt-cli-grp-out IN FRAME F-Main
DO:
    assign
      rs-cli-grp-out = 2
    .
    display
      rs-cli-grp-out
    with frame {&frame-name}.
    run select-cli-grp-out in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-cli-out
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-cli-out s-object
ON CHOOSE OF bt-cli-out IN FRAME F-Main
DO:
    assign
      rs-cli-grp-out = 3
    .
    display
      rs-cli-grp-out
    with frame {&frame-name}.
    run select-cli-out in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-wth
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-wth s-object
ON CHOOSE OF bt-wth IN FRAME F-Main
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


&Scoped-define SELF-NAME rs-cli-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-cli-grp s-object
ON VALUE-CHANGED OF rs-cli-grp IN FRAME F-Main
DO:
  assign
    rs-cli-grp
  .
  case rs-cli-grp:
    when 1 then do:
      assign
        ed-grp-obj      = "Все"
        v-cli-grp-list  = ""
        v-cli-grp-list  = v-cli-grp-all
      .

      display
        ed-grp-obj
      with frame {&frame-name}.
    end.
    when 2 then do:
      apply "choose" to bt-cli-grp.
    end.
    otherwise do:
      return no-apply.
    end.
  end case.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-cli-grp-out
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-cli-grp-out s-object
ON VALUE-CHANGED OF rs-cli-grp-out IN FRAME F-Main
DO:
  assign
    rs-cli-grp-out
  .
  case rs-cli-grp-out:
    when 1 then do:
      assign
        ed-grp-obj-out      = "Все"
        v-cli-grp-out-list  = ""
        v-cli-grp-out-list = v-cli-grp-all
      .
      display
        ed-grp-obj-out
      with frame {&frame-name}.
    end.
    when 2 then do:
      apply "choose" to bt-cli-grp-out.
    end.
    when 3 then do:
      apply "choose" to bt-cli-out.
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
      for each buf_wealth no-lock
        where buf_wealth.is-ser = 1
          and buf_wealth.stts   = 0
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
      find first buf_wealth no-lock
        where buf_wealth.wth-code = integer( entry( v-i, p-code-list ) )
      no-error .
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
RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .

    define buffer buf_wealth    for ub.wealth.
    define buffer buf_cli-grp   for ub.cli-grp.
    define buffer buf_clients   for ub.clients.
    define buffer buf_tt-object for tt-object.

    define variable v-rs-cli-grp            as logical   no-undo .
    define variable v-rs-cli-grp-out-str    as character no-undo .
    define variable v-rs-cli-grp-out        as integer   no-undo .
    define variable v-rs-wth                as logical   no-undo .
    define variable v-void-str              as character no-undo .
    define variable v-void-logical-1        as logical   no-undo .
    define variable v-void-logical-2        as logical   no-undo .
    define variable v-void-logical-3        as logical   no-undo .
    define variable v-void-logical-4        as logical   no-undo .
    define variable v-found                 as logical   no-undo .
    define variable v-i                     as integer   no-undo .
    define variable v-j                     as integer   no-undo .
    define variable v-value-character       as character no-undo .
    define variable v-value-date            as date      no-undo .
    define variable v-value-decimal         as decimal   no-undo .
    define variable v-value-integer         as integer   no-undo .
    define variable v-value-logical         as logical   no-undo .
    define variable v-param-type            as character no-undo .
    define variable v-grp-code              as integer   no-undo .
    define variable v-cli-grp-list-tmp      as character no-undo .
    define variable v-cli-grp-out-list-tmp  as character no-undo .
    define variable v-str                   as character no-undo .

do for buf_wealth
     , buf_cli-grp
     , buf_clients
     , buf_tt-object
on error undo, return error
:
   run adm/shattri.p ( input "get":U
                     , input ""
                     , input 0
                     , input {&attr-wthrep}
                     , input  ""
                     , output v-value-character
                     , output v-value-date
                     , output v-value-decimal
                     , output v-value-integer
                     , output v-value-logical
                     , output v-param-type
                     , INPUT-OUTPUT TABLE thbjattr_thbj-attr
                     ) no-error .

   find first thbjattr_thbj-attr
        where thbjattr_thbj-attr.obj-code  = 0
          and thbjattr_thbj-attr.obj-type  = ""
          and thbjattr_thbj-attr.prop-code = {&attr-wthrep_cligrplist}
          and thbjattr_thbj-attr.upper-prop-code = {&attr-wthrep}
        no-error
        .
   .
   if error-status :error then do:
      message
         vss-workfile vss-revision vss-description skip
         error-status :get-message(1) skip
         return-value skip
         ""
         view-as alert-box error
      .
         return error return-value .
   end.

   assign
      v-cli-grp-all = thbjattr_thbj-attr.property-value-character
   .

    run uf-get in this-procedure ( input {&uf-wrsttl1}
                                 , input  v-cntxt-userid
                                 , output v-wth-list
                                 , output v-cli-grp-list-tmp
                                 , output v-rs-cli-grp
                                 , output v-rs-wth
                                 , output tg-price-detail
                                 , output v-void-logical-4
                                 ) no-error .
    if not error-status :error
    then do:
      if v-rs-cli-grp = no
      then do:
        assign
          rs-cli-grp     = 1
          ed-grp-obj     = "Все":u
          v-cli-grp-list = v-cli-grp-all
        .
      end.
      else do:
        assign
          rs-cli-grp = 2
          v-cli-grp-list = ''
        .
        do v-i = 1 to num-entries(v-cli-grp-list-tmp)
        :
          assign
            v-grp-code = integer( entry( v-i, v-cli-grp-list-tmp, {&comma-char} ) )
          .

          find first buf_cli-grp no-lock
            where buf_cli-grp.node-code = v-grp-code
          no-error .
          if available buf_cli-grp and ( lookup( string(v-grp-code) , v-cli-grp-all , {&comma-char}) > 0)
          then do:
            assign
              ed-grp-obj = ed-grp-obj + buf_cli-grp.node-name + {&new-line}
              v-cli-grp-list = v-cli-grp-list + string(v-grp-code) + {&comma-char}
            .

          end.
        end.
        assign
          v-cli-grp-list = trim( v-cli-grp-list , {&comma-char} )
        .
      end.
      if v-rs-wth = no
      then do:
        assign
          rs-wth      = 1
          ed-wth      = "Все":u
          v-wth-list  = ""
        .

        for each buf_wealth no-lock
          where buf_wealth.is-ser = 1
            and buf_wealth.stts   = 0
        :
          assign
            v-wth-list = v-wth-list + string(buf_wealth.wth-code) + {&comma-char}
          .
        end.
      end.
      else do:
        assign
          rs-wth = 2
        .
        do v-i = 1 to num-entries(v-wth-list)
        :
          find first buf_wealth no-lock
            where buf_wealth.wth-code = integer( entry( v-i, v-wth-list, {&comma-char} ) )
          no-error .
          if available buf_wealth
          then do:
            assign
              ed-wth = ed-wth + buf_wealth.wth-name + {&new-line}
            .
          end.
        end.
      end.
    end.
    else do:
      apply "value-changed" to rs-cli-grp in frame {&frame-name}.
      apply "value-changed" to rs-wth in frame {&frame-name}.
    end.

    run uf-get in this-procedure ( input {&uf-wrsttl2}
                                 , input  v-cntxt-userid
                                 , output v-rs-cli-grp-out-str
                                 , output v-cli-grp-out-list-tmp
                                 , output v-void-logical-1
                                 , output v-void-logical-2
                                 , output v-void-logical-3
                                 , output v-void-logical-4
                                 ) no-error .
    if not error-status :error
    then do:
      assign
        v-rs-cli-grp-out = integer( v-rs-cli-grp-out-str)
      no-error .
      if    error-status :error
        or  v-rs-cli-grp-out = ?
        or  v-rs-cli-grp-out < 1
        or  v-rs-cli-grp-out > 3
      then do:
        assign
          v-rs-cli-grp-out = 1
        .
      end.

      case v-rs-cli-grp-out
      :
        when 1
        then do:
          assign
            ed-grp-obj-out      = "Все":u
            v-cli-grp-out-list  = v-cli-grp-all
          .
        end.
        when 2
        then do:
          assign
            v-cli-grp-out-list  = ''
          .
          do v-i = 1 to num-entries(v-cli-grp-out-list-tmp)
          :
            assign
              v-grp-code = integer( entry( v-i, v-cli-grp-out-list-tmp, {&comma-char} ) )
            .
            find first buf_cli-grp no-lock
              where buf_cli-grp.node-code = v-grp-code
            no-error .
            if available buf_cli-grp and ( lookup( string(v-grp-code) ,v-cli-grp-all, {&comma-char} ) > 0 )
            then do:
              assign
                ed-grp-obj-out = ed-grp-obj-out + buf_cli-grp.node-name + {&new-line}
                v-cli-grp-out-list = v-cli-grp-out-list + string(v-grp-code) + {&comma-char}
              .
            end.
          end.
          assign
            v-cli-grp-out-list = trim( v-cli-grp-out-list, {&comma-char} )
          .
        end.
        when 3
        then do:
          do v-i = 1 to num-entries(v-cli-grp-all)
          on error undo, next
          :
              find first buf_cli-grp no-lock
                where buf_cli-grp.node-code = integer(entry(v-i, v-cli-grp-all, {&comma-char}))
              no-error.
              if available buf_cli-grp
              then do:
                for each buf_clients no-lock
                  where buf_clients.grp-code = buf_cli-grp.node-code
                    and buf_clients.stts     = 0
                :
                  find first buf_tt-object
                    where buf_tt-object.obj-type = buf_clients.obj-type
                      and buf_tt-object.obj-code = buf_clients.obj-code
                  no-error .
                  if not available buf_tt-object
                  then do:
                    define variable v-k         as integer   no-undo .
                    define variable v-l         as integer   no-undo .
                    define variable v-selected  as logical   no-undo .

                    create buf_tt-object.
                    assign
                      v-j                     = v-j + 1
                      buf_tt-object.id        = v-j
                      buf_tt-object.obj-type  = buf_clients.obj-type
                      buf_tt-object.obj-code  = buf_clients.obj-code
                      buf_tt-object.obj-name  = buf_clients.obj-name
                      v-selected              = no
                    .

                    _search-obj:
                    do v-k = 1 to num-entries(v-cli-grp-out-list-tmp,',')
                    :
                      assign
                        v-selected  = if entry(v-k,v-cli-grp-out-list-tmp) = substitute( "&1:&2" , buf_clients.obj-type , buf_clients.obj-code )
                                      then yes
                                      else no
                      .
                      if v-selected = yes
                      then do:
                        leave _search-obj.
                      end.
                    end.
                    assign
                      buf_tt-object.selected = v-selected
                    .
                    if buf_tt-object.selected = yes
                    then do:
                      assign
                        ed-grp-obj-out = ed-grp-obj-out + buf_tt-object.obj-name + {&new-line}
                      .
                    end.
                  end.
                end. /* for each buf_clients no-lock */

              end.
          end. /* объекты по списку групп */
        end.
        otherwise do:
        end.
      end case.
    end.
    else do:
      apply "value-changed" to rs-cli-grp-out in frame {&frame-name}.
    end.
    assign
      rs-cli-grp-out = v-rs-cli-grp-out
    .
    display
      rs-cli-grp
      rs-cli-grp-out
      rs-wth
      ed-grp-obj
      ed-grp-obj-out
      ed-wth
      tg-price-detail
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
  define buffer buf_tt-object for tt-object.

  define variable v-str as character no-undo .

do for buf_tt-object
on error undo, return error
:
   if v-cli-grp-list = "":u
   then do:
      message
         "Не выбран список групп объектов реализации"
         skip
      view-as alert-box information.
      return no-apply.
   end.

   if rs-cli-grp-out = 2 and v-cli-grp-out-list = "":u
   then do:
      message
         "Не выбран список групп объектов погашения"
         skip
      view-as alert-box information.
      return no-apply.
   end.

   if rs-cli-grp-out = 3
   then do:
    find first buf_tt-object
      where buf_tt-object.selected = yes
    no-error .
    if not available buf_tt-object
    then do:
      message
          "Не выбран список объектов погашения"
          skip
      view-as alert-box information.
      return no-apply.
    end.
   end.

   if v-wth-list = "":u
   then do:
      message
         "Не выбран список материальных ценностей"
         skip
      view-as alert-box information.
      return no-apply.
   end.

   case rs-cli-grp-out
   :
    when 1
    then do:
      assign
        v-str = v-cli-grp-out-list
      .
    end.
    when 2
    then do:
      assign
        v-str = v-cli-grp-out-list
      .
    end.
    when 3
    then do:
      for each buf_tt-object
        where buf_tt-object.selected = yes
      :
        assign
          v-str = v-str + ',' + substitute( "&1:&2" , buf_tt-object.obj-type , buf_tt-object.obj-code )
        .
      end.
      assign
        v-str = trim( v-str , ',' )
      .
    end.
   end case.
   run uf-set in this-procedure ( input {&uf-wrsttl1}
                                , input v-cntxt-userid
                                , input v-wth-list
                                , input v-cli-grp-list
                                , input ( if rs-cli-grp = 1 then no else yes )
                                , input ( if rs-wth     = 1 then no else yes )
                                , input tg-price-detail
                                , input no
                                ) .
   run uf-set in this-procedure ( input {&uf-wrsttl2}
                                , input v-cntxt-userid
                                , input string( rs-cli-grp-out )
                                , input v-str
                                , input no
                                , input no
                                , input no
                                , input no
                                ) .
   run rep/r-wrsttl.p ( input my-handle
                      , input v-cli-grp-list
                      , input rs-cli-grp-out
                      , input v-str
                      , input v-wth-list
                      , input tg-price-detail
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
  assign frame {&frame-name}
    rs-cli-grp-out
    ed-grp-obj
    tg-price-detail
  .
  assign
    ReportHeader =  ( if rs-cli-grp-out = 3 then "Объекты погашения: " else "Группы объектов погашения: " ) + {&new-line} + ed-grp-obj-out + {&new-line} + {&new-line} +
                    "Группы объектов реализации: " + {&new-line} + ed-grp-obj + {&new-line} + {&new-line} +
                    "Материальные ценности: " + {&new-line} + ed-wth + {&new-line}
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

   define variable v-cur-ext-key    as character    no-undo.
   define variable v-accepted    as logical      no-undo.

do
on error undo, return error
:
   /* любые группы клиентов
   run ref/cli-grps.w ( INPUT my-handle
                      , INPUT "b-mark,b-sel"
                      , INPUT-OUTPUT v-cli-grp-all
                      ) .
   */
   run onewin_clear in this-procedure.

   DO v-count = 1 TO NUM-ENTRIES(v-cli-grp-all)
   on error undo, next
   :
      find first buf_cli-grp
           where buf_cli-grp.node-code = INTEGER(ENTRY(v-count, v-cli-grp-all, {&comma-char}))
           no-lock
           no-error
           .
      IF AVAILABLE buf_cli-grp
      THEN DO:
        run onewin_add-item in this-procedure   ( input buf_cli-grp.node-code
                                                , INPUT buf_cli-grp.node-name
                                                , INPUT ""
                                                , input (LOOKUP(STRING(buf_cli-grp.node-code), v-cli-grp-list, {&comma-char}) <> 0)
                                                ) .
      END.
   END. /* объекты по списку групп */
   run gbl/onewin.w  ( input my-handle
                     , input 1
                     , input "Список групп объектов для сводных отчетов"
                     , input "":U
                     , input "":U
                     , input  table temp_onewin_items
                     , output table temp_onewin_itemsSelected
                     , output v-cur-ext-key
                     , output v-accepted
                     ) .
   assign
      v-cli-grp-list = "":U
      ed-grp-obj     = "":u
   .
   FOR EACH temp_onewin_itemsSelected
   :


      find first buf_cli-grp no-lock
        where buf_cli-grp.node-code = integer(temp_onewin_itemsSelected.itmExtKey)
      no-error .
      if available buf_cli-grp
      then do:
        assign
          v-cli-grp-list = IF v-cli-grp-list = "":U THEN temp_onewin_itemsSelected.itmExtKey
                                                    ELSE v-cli-grp-list + {&comma-char} + temp_onewin_itemsSelected.itmExtKey
          ed-grp-obj = ed-grp-obj + buf_cli-grp.node-name + {&new-line}
        .
      end.
   END.

   display
    ed-grp-obj
   with frame {&frame-name}.
end.  /* do on error */END PROCEDURE. /* select-cli-grp */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-cli-grp-out s-object
PROCEDURE select-cli-grp-out :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer buf_cli-grp     for ub.cli-grp .
define variable v-count    as integer      no-undo.

   define variable v-value-character as character no-undo .
   define variable v-value-date as date no-undo .
   define variable v-value-decimal as decimal no-undo .
   define variable v-value-integer as INTEGER no-undo .
   define variable v-value-logical AS LOGICAL no-undo .
   define variable v-param-type as character no-undo .
   define variable v-cur-ext-key    as character    no-undo.
   define variable v-accepted    as logical      no-undo.

do
on error undo, return error
:
   /* список групп из глобального параметра */
   run onewin_clear in this-procedure.

   DO v-count = 1 TO NUM-ENTRIES(v-cli-grp-all)
   on error undo, next
   :
      find first buf_cli-grp
           where buf_cli-grp.node-code = INTEGER(ENTRY(v-count, v-cli-grp-all, {&comma-char}))
           no-lock
           no-error
           .
      IF AVAILABLE buf_cli-grp
      THEN DO:
        run onewin_add-item in this-procedure   ( input buf_cli-grp.node-code
                                                , INPUT buf_cli-grp.node-name
                                                , INPUT ""
                                                , input (LOOKUP(STRING(buf_cli-grp.node-code), v-cli-grp-list, {&comma-char}) <> 0)
                                                ) .
      END.
   END. /* объекты по списку групп */
   run gbl/onewin.w  ( input my-handle
                     , input 1
                     , input "Список групп объектов для сводных отчетов"
                     , input "":U
                     , input "":U
                     , input  table temp_onewin_items
                     , output table temp_onewin_itemsSelected
                     , output v-cur-ext-key
                     , output v-accepted
                     ) .
   assign
      v-cli-grp-out-list = "":U
      ed-grp-obj-out     = "":u
   .
   FOR EACH temp_onewin_itemsSelected
   :


      find first buf_cli-grp no-lock
        where buf_cli-grp.node-code = integer(temp_onewin_itemsSelected.itmExtKey)
      no-error .
      if available buf_cli-grp
      then do:
        assign
          v-cli-grp-out-list = IF v-cli-grp-out-list = "":U THEN temp_onewin_itemsSelected.itmExtKey
                               ELSE v-cli-grp-out-list + {&comma-char} + temp_onewin_itemsSelected.itmExtKey
          ed-grp-obj-out     = ed-grp-obj-out + buf_cli-grp.node-name + {&new-line}
        .
      end.
   END.

   display
    ed-grp-obj-out
   with frame {&frame-name}.
end.  /* do on error */
END PROCEDURE. /* select-cli-grp-out */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-cli-out s-object
PROCEDURE select-cli-out :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define buffer buf_cli-grp     for ub.cli-grp .
  define buffer buf_clients     for ub.clients.
  define buffer buf_tt-object   for tt-object.

  define variable v-count           as integer   no-undo .
  define variable v-value-character as character no-undo .
  define variable v-value-date      as date      no-undo .
  define variable v-value-decimal   as decimal   no-undo .
  define variable v-value-integer   as integer   no-undo .
  define variable v-value-logical   as logical   no-undo .
  define variable v-param-type      as character no-undo .
  define variable v-cur-ext-key     as character no-undo .
  define variable v-accepted        as logical   no-undo .
  define variable v-i               as integer   no-undo .

do for buf_cli-grp
     , buf_clients
     , buf_tt-object
on error undo, return error
:
   /* список групп из глобального параметра */
   run onewin_clear in this-procedure.

   find first buf_tt-object no-error .
   if not available buf_tt-object
   then do:
    do v-count = 1 to num-entries(v-cli-grp-all)
    on error undo, next
    :
        find first buf_cli-grp no-lock
          where buf_cli-grp.node-code = integer(entry(v-count, v-cli-grp-all, {&comma-char}))
        no-error.
        if available buf_cli-grp
        then do:
          for each buf_clients no-lock
            where buf_clients.grp-code = buf_cli-grp.node-code
              and buf_clients.stts     = 0
          :
            find first buf_tt-object
              where buf_tt-object.obj-type = buf_clients.obj-type
                and buf_tt-object.obj-code = buf_clients.obj-code
            no-error .
            if not available buf_tt-object
            then do:
              create buf_tt-object.
              assign
                v-i                     = v-i + 1
                buf_tt-object.id        = v-i
                buf_tt-object.obj-type  = buf_clients.obj-type
                buf_tt-object.obj-code  = buf_clients.obj-code
                buf_tt-object.obj-name  = buf_clients.obj-name
              .
            end.
          end. /* for each buf_clients no-lock */

        end.
    end. /* объекты по списку групп */
   end.

   for each buf_tt-object
   :
      run onewin_add-item in this-procedure   ( input buf_tt-object.id
                                              , input buf_tt-object.obj-name
                                              , input substitute( "&1 &2"
                                                                , string(buf_tt-object.obj-code , "999999999")
                                                                , buf_tt-object.obj-type
                                                                )
                                              , input buf_tt-object.selected
                                              ) .

   end.

   run gbl/onewin.w  ( input my-handle
                     , input 1
                     , input "Список групп объектов для сводных отчетов"
                     , input "":U
                     , input "":U
                     , input  table temp_onewin_items
                     , output table temp_onewin_itemsSelected
                     , output v-cur-ext-key
                     , output v-accepted
                     ) .
   for each buf_tt-object
   :
    assign
      buf_tt-object.selected = no
    .
   end.
   assign
/*      v-cli-grp-out-list = "":U*/
      ed-grp-obj-out     = "":u
   .
   for each temp_onewin_itemsselected
   :
      find first buf_tt-object
        where buf_tt-object.id = integer(temp_onewin_itemsselected.itmextkey)
      no-error .
      if available buf_tt-object
      then do:
        assign
          ed-grp-obj-out          = ed-grp-obj-out + buf_tt-object.obj-name + {&new-line}
          buf_tt-object.selected  = yes
        .
      end.
   end. /* for each temp_onewin_itemsselected */
   display
    ed-grp-obj-out
   with frame {&frame-name}.
end.  /* do on error */
END PROCEDURE.

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
                                          ).
  display
    ed-wth
  with frame {&frame-name}.

end.  /* do on error */
END PROCEDURE. /* select-wth */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
