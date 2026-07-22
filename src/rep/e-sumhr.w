&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions                                    */
DEFINE NEW SHARED TEMP-TABLE temp-dis-card-type NO-UNDO LIKE ub.dis-card-type.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS F-Frame-Win
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Почасовая статистика розничных продаж по СУММАМ ПРОДАЖ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/08/05
Author: Bakhtadze Natalya
Creation date: 09/08/05

*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* Create an unnamed pool to store all the widgets created
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Почасовая статистика розничных продаж по СУММE ПРОДАЖ".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/r-page1.i }
{ rep/s-hour.i NEW }
{ cmp/operlist.i }
{ rep/e-sumhdf.i "NEW SHARED" }
{ gbl/waitfram.i }
{ gbl/prn-lib.i }
define variable parparentproc as widget-handle no-undo .
{ gbl/getcntxt.i def }



def buffer cli-obj for ub.clients .
def variable ii as integer.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER FRAME

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME F-Main
&Scoped-define BROWSE-NAME BR-dis-card-type

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-dis-card-type

/* Definitions for BROWSE BR-dis-card-type                              */
&Scoped-define FIELDS-IN-QUERY-BR-dis-card-type temp-dis-card-type.type ~
temp-dis-card-type.emitent-host-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-dis-card-type
&Scoped-define QUERY-STRING-BR-dis-card-type FOR EACH temp-dis-card-type NO-LOCK
&Scoped-define OPEN-QUERY-BR-dis-card-type OPEN QUERY BR-dis-card-type FOR EACH temp-dis-card-type NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-dis-card-type temp-dis-card-type
&Scoped-define FIRST-TABLE-IN-QUERY-BR-dis-card-type temp-dis-card-type


/* Definitions for FRAME F-Main                                         */
&Scoped-define OPEN-BROWSERS-IN-QUERY-F-Main ~
    ~{&OPEN-QUERY-BR-dis-card-type}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS T-dis-card BR-dis-card-type Tree RS-OPTION ~
t-byobject
&Scoped-Define DISPLAYED-OBJECTS T-dis-card RS-dis-card Tree RS-OPTION ~
t-byobject

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of handles for SmartObjects                              */
DEFINE VARIABLE h_s-hour AS HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE VARIABLE RS-dis-card AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все типы карт", 0,
"Выборочно", 1
     SIZE 19 BY 2.13 NO-UNDO.

DEFINE VARIABLE RS-OPTION AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Только итоги", "TOTALS":U,
"По группам", "GROUPS":U,
"Потоварно", "GOODS":U,
"По оплатам", "PAYS":U,
"По кассам", "pay-desk":U
     SIZE 25.63 BY 3.63 NO-UNDO.

DEFINE VARIABLE t-byobject AS LOGICAL INITIAL no
     LABEL "С разбивкой по объектам"
     VIEW-AS TOGGLE-BOX
     SIZE 25.5 BY 1 NO-UNDO.

DEFINE VARIABLE T-dis-card AS LOGICAL INITIAL no
     LABEL "Только покупки по картам"
     VIEW-AS TOGGLE-BOX
     SIZE 26.63 BY 1 NO-UNDO.

DEFINE VARIABLE Tree AS LOGICAL INITIAL no
     LABEL "Названия групп полностью"
     VIEW-AS TOGGLE-BOX
     SIZE 42.5 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-dis-card-type FOR
      temp-dis-card-type SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-dis-card-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-dis-card-type F-Frame-Win _STRUCTURED
  QUERY BR-dis-card-type DISPLAY
      temp-dis-card-type.type COLUMN-LABEL "Тип" FORMAT "X(8)":U
      temp-dis-card-type.emitent-host-code COLUMN-LABEL "Код эмитента" FORMAT "99999":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 23.63 BY 8.04
         TITLE "Выбранные типы карт".


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     T-dis-card AT ROW 1.25 COL 49
     RS-dis-card AT ROW 2.92 COL 49.13 NO-LABEL
     BR-dis-card-type AT ROW 5.67 COL 48.38
     Tree AT ROW 12.46 COL 1.88
     RS-OPTION AT ROW 13.54 COL 2 NO-LABEL
     t-byobject AT ROW 16 COL 31
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 77.38 BY 16.21.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartObject
   Allow: Basic,Browse,DB-Fields,Smart,Query
   Container Links:
   Temp-Tables and Buffers:
      TABLE: temp-dis-card-type T "NEW SHARED" NO-UNDO ub dis-card-type
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB)
  CREATE WINDOW F-Frame-Win ASSIGN
         HEIGHT             = 16.21
         WIDTH              = 77.38.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB F-Frame-Win
/* ************************* Included-Libraries *********************** */

{src/adm/method/containr.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW F-Frame-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE                                                          */
/* BROWSE-TAB BR-dis-card-type RS-dis-card F-Main */
ASSIGN
       BR-dis-card-type:HIDDEN  IN FRAME F-Main                = TRUE.

/* SETTINGS FOR RADIO-SET RS-dis-card IN FRAME F-Main
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-dis-card-type
/* Query rebuild information for BROWSE BR-dis-card-type
     _TblList          = "Temp-Tables.temp-dis-card-type"
     _FldNameList[1]   > Temp-Tables.temp-dis-card-type.type
"temp-dis-card-type.type" "Тип" ? "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[2]   > Temp-Tables.temp-dis-card-type.emitent-host-code
"temp-dis-card-type.emitent-host-code" "Код эмитента" ? "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _Query            is OPENED
*/  /* BROWSE BR-dis-card-type */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = ""
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME RS-dis-card
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-dis-card F-Frame-Win
ON VALUE-CHANGED OF RS-dis-card IN FRAME F-Main
DO:
DEFINE VARIABLE varrid-list as character no-undo.
  ASSIGN
  RS-dis-card.
  CASE RS-dis-card:
    when 1 then do:
        run ref/dc-types.w (
                       input parparentproc
                      ,INPUT "":U /*p-mode*/
                      ,INPUT "b-sel,b-mark":U
                      ,INPUT 0
                      ,INPUT v-cntxt-host-code-obj
                      ,INPUT v-cntxt-obj-type
                      ,INPUT v-cntxt-obj-code
                      ,input-OUTPUT varrid-list).
                if varrid-list = "" then do:
            for each temp-dis-card-type:
                delete temp-dis-card-type.
            end.
            rs-dis-card = 0.
            {&OPEN-QUERY-BR-dis-card-type}
            DISPLAY
            rs-dis-card
            with frame {&frame-name}.
            HIDE
            br-dis-card-type
            in frame {&frame-name}.
        end.
        else dO:
          DO ii = 1 to num-entries(varrid-list):
            FIND FIRST ub.dis-card-type No-LOCK WHERE
                              recid(ub.dis-card-type) = integer(entry(ii, varrid-list)) No-ERROR.
          if avail ub.dis-card-type then dO:
            create temp-dis-card-type.
            buffer-copy ub.dis-card-type to temp-dis-card-type.
          END.
        END.
        {&OPEN-QUERY-BR-dis-card-type}
        DISPLAY
        br-dis-card-type
        with frame {&frame-name} .
      end.
    end.
    when 0 then do:
      for each temp-dis-card-type:
        delete temp-dis-card-type.
      end.
     {&OPEN-QUERY-BR-dis-card-type}
      HIDE
      br-dis-card-type
      in frame {&frame-name}.
    end.
  END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-OPTION
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-OPTION F-Frame-Win
ON VALUE-CHANGED OF RS-OPTION IN FRAME F-Main
DO:
  ASSIGN
  rs-option.
  IF rs-option = "pay-desk" THEN DO:
      ASSIGN
      t-byobject = YES.
      DISPLAY
      t-byobject
      WITH FRAME {&FRAME-NAME}.
      DISABLE t-byobject
      WITH FRAME {&FRAME-NAME}.

  END.
  ELSE DO:
      ENABLE t-byobject
      WITH FRAME {&FRAME-NAME}.

  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-byobject
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-byobject F-Frame-Win
ON VALUE-CHANGED OF t-byobject IN FRAME F-Main /* Раздельно по объектам */
DO:
  ASSIGN
  t-byobject.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-dis-card
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-dis-card F-Frame-Win
ON VALUE-CHANGED OF T-dis-card IN FRAME F-Main /* Только покупки по картам */
DO:
  assign
  t-dis-card.
  CASE t-dis-card:
    when yes then do:
        assign
        Rs-dis-card = 0.
        DISPLAY
        RS-dis-card
        with frame {&frame-name}.
        ENABLE
        RS-dis-card
        with frame {&frame-name}.
    end.
    when no then do:
        assign
        Rs-dis-card = 0.
        DISABLE
        RS-dis-card
        with frame {&frame-name}.
    end.
  END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-dis-card-type
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK F-Frame-Win


/* ***************************  Main Block  *************************** */
{ gbl/personly.i }
&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
   /* Now enable the interface  if in test mode - otherwise this happens when
      the object is explicitly initialized from its container. */
   RUN dispatch IN THIS-PROCEDURE ('initialize':U).
&ENDIF

assign
loc#db-num = v-cntxt-db-num
loc#host-code = v-cntxt-host-code-obj
loc#store-code = v-cntxt-obj-code
.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects F-Frame-Win  _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/
  DEFINE VARIABLE adm-current-page  AS INTEGER NO-UNDO.

  RUN get-attribute IN THIS-PROCEDURE ('Current-Page':U).
  ASSIGN adm-current-page = INTEGER(RETURN-VALUE).

  CASE adm-current-page:

    WHEN 0 THEN DO:
       RUN init-object IN THIS-PROCEDURE (
             INPUT  'rep/s-hour.w':U ,
             INPUT  FRAME F-Main:HANDLE ,
             INPUT  '':U ,
             OUTPUT h_s-hour ).
       /* Position in AB:  ( 1.17 , 1.25 ) */
       /* Size in UIB:  ( 11.17 , 46.88 ) */

       /* Adjust the tab order of the smart objects. */
       RUN adjust-tab-order IN adm-broker-hdl ( h_s-hour ,
             T-dis-card:HANDLE IN FRAME F-Main , 'BEFORE':U ).
    END. /* Page 0 */

  END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available F-Frame-Win  _ADM-ROW-AVAILABLE
PROCEDURE adm-row-available :
/*------------------------------------------------------------------------------
  Purpose:     Dispatched to this procedure when the Record-
               Source has a new row available.  This procedure
               tries to get the new row (or foriegn keys) from
               the Record-Source and process it.
  Parameters:  <none>
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.             */
  {src/adm/template/row-head.i}

  /* Process the newly available records (i.e. display fields,
     open queries, and/or pass records on to any RECORD-TARGETS).    */
  {src/adm/template/row-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI F-Frame-Win  _DEFAULT-DISABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI F-Frame-Win  _DEFAULT-ENABLE
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
  DISPLAY T-dis-card RS-dis-card Tree RS-OPTION t-byobject
      WITH FRAME F-Main.
  ENABLE T-dis-card BR-dis-card-type Tree RS-OPTION t-byobject
      WITH FRAME F-Main.
  {&OPEN-BROWSERS-IN-QUERY-F-Main}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize F-Frame-Win
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .

  /* Code placed here will execute AFTER standard behavior.    */
  run ini-from-selobj in h_s-hour.
  APPLY "VALUE-CHANGED" to T-dis-card in frame {&frame-name}.
  APPLY "VALUE-CHANGED" to RS-dis-card in frame {&frame-name}.
  parparentproc = my-handle.
  { gbl/getcntxt.i get }

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE My-report F-Frame-Win
PROCEDURE My-report :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable num-cols as integer.
define variable choice as integer.
define variable With-goods as integer no-undo.
DEFINE VARIABLE for-h-str as character no-undo .
define variable glog as logical no-undo .
run Assign-Frame in h_s-hour.
assign
FRAME {&frame-name} RS-OPTION
FRAME {&frame-name} Tree
FRAME {&frame-name} t-byobject

.
run My-var.
case rs-option:
  when "TOTALS":U then with-goods = 0.
  when "GOODS":U then with-goods = 3.
  when "GROUPS":U then with-goods = 2.
  when "PAY-DESK":U then with-goods = 1.
  when "PAYS":U then with-goods = 4
  .
END CASE.
assign
num-cols = ( integer( vH-0 ) + integer( vH-1 ) + integer( vH-2 ) + integer( vH-3 ) + integer( vH-4 ) +
             integer( vH-5 ) + integer( vH-6 ) + integer( vH-7 ) + integer( vH-8 ) + integer( vH-9 ) +
             integer( vH-10 ) + integer( vH-11 ) + integer( vH-12 ) + integer( vH-13 ) + integer( vH-14 ) +
             integer( vH-15 ) + integer( vH-16 ) + integer( vH-17 ) + integer( vH-18 ) + integer( vH-19 ) +
             integer( vH-20 ) + integer( vH-21 ) + integer( vH-22 ) + integer( vH-23 ) ).
glog = ?.
if num-cols > 10 AND num-cols < 14  and NOT vXl AND NOT RS-option = "TOTALS":U
then do:
    run gbl/d-askw.w (input "Формат вывода",
                input ("Количество интересующих Вас интервалов времени больше 10 :" + {&new-line} +
                       "отчет не уместится на бумаге формата А4 (ориентация альбомная)"
                      ),
                input "|",
                input ("Выводить в Excel|" +
                       "Формат А3 (ориентация альбомная)|" +
                       "Уменьшить количество интервалов"),
                input "||",
                input 1,
                input 3,
                output choice).
   if choice = 3 then return no-apply.
   if choice = 1 then vXl = yes.
   run display_ in h_s-hour.
end.
else if num-cols >=14 AND NOT vXl  AND NOT RS-option = "TOTALS":U then do:
    run gbl/d-askw.w (input "Формат вывода",
                 input ("Количество интересующих Вас интервалов времени больше 13 :" + {&new-line} +
                        "отчет не уместится на бумаге формата А3 (ориентация альбомная)"
                       ),
                 input "|",
                 input ("Выводить в Excel|" +
                        "Уменьшить количество интервалов"),
                 input "|",
                 input 1,
                 input 2,
                 output choice).
    if choice = 2 then return no-apply.
    vXl = yes.
    run display_ in h_s-hour.
end.
if ( integer( vH-0 ) + integer( vH-1 ) + integer( vH-2 ) + integer( vH-3 ) + integer( vH-4 ) +
     integer( vH-5 ) + integer( vH-6 ) + integer( vH-7 ) + integer( vH-8 ) + integer( vH-9 ) +
     integer( vH-10 ) + integer( vH-11 ) + integer( vH-12 ) + integer( vH-13 ) + integer( vH-14 ) +
     integer( vH-15 ) + integer( vH-16 ) + integer( vH-17 ) + integer( vH-18 ) + integer( vH-19 ) +
     integer( vH-20 ) + integer( vH-21 ) + integer( vH-22 ) + integer( vH-23 ) ) = 0
then do:
    message "Вы не определили," skip
            "какие интервалы времени" skip
            "Вас интересуют."     view-as alert-box ERROR .
    return no-apply.
end.
else do:
  run waitfram-show in this-procedure ( "Подождите ..." ).
  do ii = 1 to 24:
    for-h-str =
     string( vH-0 ) + {&comma-char} + string( vH-1 ) + {&comma-char} +
     string( vH-2 ) + {&comma-char} + string( vH-3 ) +  {&comma-char} +
     string( vH-4 ) + {&comma-char} + string( vH-5 ) + {&comma-char} +
     string( vH-6 ) + {&comma-char} + string( vH-7 ) + {&comma-char} +
     string( vH-8 ) + {&comma-char} + string( vH-9 ) +  {&comma-char} +
     string( vH-10 ) + {&comma-char} + string( vH-11 ) + {&comma-char} +
     string( vH-12 ) + {&comma-char} + string( vH-13 ) + {&comma-char} +
     string( vH-14 ) + {&comma-char} + string( vH-15 ) + {&comma-char} +
     string( vH-16 ) + {&comma-char} + string( vH-17 ) + {&comma-char} +
     string( vH-18 ) + {&comma-char} + string( vH-19 ) + {&comma-char} +
     string( vH-20 ) + {&comma-char} + string( vH-21 ) + {&comma-char} +
     string( vH-22 ) + {&comma-char} + string( vH-23 ).
  end.
  run rep/r-sumhr.p (
                 input for-h-str
                ,input yes
                ,input with-goods
                ,input t-dis-card
                ,input rs-dis-card
                ) no-error .
  if error-status:error then do:
    message
    vss-workfile vss-revision vss-description skip
    error-status:get-message(1) skip
    return-value
    view-as alert-box error .
    run waitfram-hide in this-procedure .
    return.
  end.
  run waitfram-show in this-procedure ("Ждите... ").
  if can-find( first grp-h ) then do:
    if vXl THEN DO:
      run rep/sxgrp-h.p (
                      input my-handle
                     ,input v-cntxt-host-code-obj
                     ,input X-date-start
                     ,input X-date-end
                     ,input X-SelectObject
                     ,input str4
                     ,input RS-option
                     ,input (if X-selectobject <> {&obj-currency} and t-byobject then yes else no)
                     ,input integer( WH-Start )
                     ,input integer( WH-End )
                     ,input TREE
                     ,input t-dis-card
                     ,input rs-dis-card
                     ,input for-h-str ) no-error .
      if error-status:error then do:
        message
        vss-workfile vss-revision vss-description skip
        error-status:get-message(1) skip
        return-value
        view-as alert-box error .
        run waitfram-hide in this-procedure .
        return.
      end.
    END.
    ELSE DO:
      run rep/s-grp-h.p (
                      input my-handle
                    , input X-date-start
                    , input X-date-end
                    , input str4
                    , input RS-option
                    , input (if X-selectobject <> {&obj-currency} and t-byobject then yes else no)
                    , input integer( WH-Start )
                    , input integer( WH-End )
                    , input TREE
                    , input t-dis-card
                    , input rs-dis-card
                    , input for-h-str ) no-error.
      if error-status:error then do:
        message
        vss-workfile vss-revision vss-description skip
        error-status:get-message(1) skip
        return-value
        view-as alert-box error .
        run waitfram-hide in this-procedure .
        return.
      end.
    END.
    run waitfram-hide in this-procedure .
    /*
    assign
    g#rep-tblname = ""
    g#rep-tblrid = -124
    g#rep-updflds = "Почасовая статистика " + string(X-date-start) + ".." +
                    string( X-date-end ) .
    */
    if vXl and RS-option <> "TOTALS":U then
    run prn-lib-prn-file in this-procedure (
                                              input parParentProc
                                              ,input 3
                                              ).

    else
    run prn-lib-prn-file in this-procedure (
                                              input parParentProc
                                              ,input 8
                                              ).

    FOR EACH grp-h :
    delete grp-h .
    END .
    FOR EACH gds-h :
    delete gds-h .
    END .
  end.
  else do:
    run waitfram-hide in this-procedure .
    message "В указанный Вами период времени" skip
            "на интересующих Вас объектах" skip
            "не было НИКАКИХ продаж."
    view-as alert-box INFORMATION .
  end.
 end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE My-var F-Frame-Win
PROCEDURE My-var :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

assign frame {&frame-name}
Tree Rs-Option
t-dis-card rs-dis-card t-byobject
.
Assign
 STR-obj-type = ''
 STR-obj-code = ''
 STR-obj-name = ''
 STR-obj      = ''.

For each obj-list no-lock:
 Assign
 STR-obj-type = STR-obj-type + obj-list.obj-type + ','
 STR-obj-code = STR-obj-code + String(obj-list.obj-code) + ','
 STR-obj-name = STR-obj-name + obj-list.obj-name + ','
 STR-obj = STR-obj +  obj-list.obj-type + '#' + string(obj-list.obj-code)  + ',' .
End.
ReportNAme = "Почасовая статистика розничных продаж по СУММЕ ПРОДАЖ".
ReportHeader =  radio-label(string(Rs-Option), RS-Option:radio-buttons) +
                (if t-byobject then "Раздельно по объектам" else '':U) +
                            if Tree then (", " + Tree:label ) else "" +
                            string(if vXl then ", Вывод в Excel" else "").
if RS-option = "TOTALS":U then do:
  do ii = 1 to 6:
    use-column[ii] = yes.
  end.
  do ii = 7 to 24:
    use-column[ii] = no.
  end.
end.
else do:
  assign
  use-column[1] = yes
  use-column[2] = yes
  use-column[3] = yes
  use-column[28] = yes
  use-column[29] = yes
  .
  assign
  use-column[4] = vH-0
  use-column[5] = vH-1
  use-column[6] = vh-2
  use-column[7] = vh-3
  use-column[8] = vh-4
  use-column[9] = vH-5
  use-column[10] = vH-6
  use-column[11] = vh-7
  use-column[12] = vh-8
  use-column[13] = vh-9
  use-column[14] = vH-10
  use-column[15] = vH-11
  use-column[16] = vh-12
  use-column[17] = vh-13
  use-column[18] = vh-14
  use-column[19] = vH-15
  use-column[20] = vH-16
  use-column[21] = vh-17
  use-column[22] = vh-18
  use-column[23] = vh-19
  use-column[24] = vH-20
  use-column[25] = vH-21
  use-column[26] = vh-22
  use-column[27] = vh-23
  .
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records F-Frame-Win  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.               */
  {src/adm/template/snd-head.i}

  /* For each requested table, put it's ROWID in the output list.      */
  {src/adm/template/snd-list.i "temp-dis-card-type"}

  /* Deal with any unexpected table requests before closing.           */
  {src/adm/template/snd-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed F-Frame-Win
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE NO-UNDO.
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.
  CASE p-state:
  END CASE.
  IF INDEX(p-state, "SELECTOBJECT=") > 0 then do:
        RUn ini-from-selobj in h_s-hour.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME