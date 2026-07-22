&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_gds-grp FOR ub.gds-grp.
DEFINE BUFFER X_scales FOR ub.scales.
DEFINE BUFFER X_scales-grp FOR ub.scales-grp.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Группы товаров на весах

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/20/06
Author: Bakhtadze Natalya
Creation date: 03/20/06

Author: Черных В.Г.
Created: 30/11/98

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter bttns    as character no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-mode   as character no-undo .
/*{&all} {&table_db} {&table_scales} {&table_db} + {&comma-char} + {&table_gds-grp}*/
define input parameter p-db-num as integer no-undo .
define input parameter p-scales-num as integer no-undo .
define input parameter n-code like ub.gds-grp.node-code no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Группы товаров на весах".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ cmp/showinf.i }
{ ref/grplibfn.i }
{ gbl/getcntxt.i def }
{ gbl/waitfram.i }


define variable  full-grpname as char no-undo .
define variable  rec-list as char no-undo .
define variable  jj                  as integer no-undo .
define variable  ii                  as integer no-undo .
define variable  v-doc-rec           as integer no-undo .
define buffer locked_scales for ub.scales.
&SCOPED-DEFINE col-label1 "Название группы"

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-scal-grp

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_scales-grp X_gds-grp X_scales

/* Definitions for BROWSE br-scal-grp                                   */
&Scoped-define FIELDS-IN-QUERY-br-scal-grp X_scales-grp.db-num X_scales-grp.scales-num X_scales.scales-name X_scales.unit-base X_scales.tot-gds X_scales-grp.node-code get-full-name(X_scales-grp.node-code)
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-scal-grp
&Scoped-define SELF-NAME br-scal-grp
&Scoped-define QUERY-STRING-br-scal-grp FOR EACH X_scales-grp       WHERE X_scales-grp.node-code = n-code NO-LOCK, ~
             EACH X_gds-grp WHERE X_gds-grp.node-code = X_scales-grp.node-code NO-LOCK, ~
             EACH X_scales WHERE X_scales.scales-num = X_scales-grp.scales-num            AND X_scales.db-num = X_scales-grp.db-num     NO-LOCK     BY X_scales-grp.scales-num
&Scoped-define OPEN-QUERY-br-scal-grp OPEN QUERY {&SELF-NAME} FOR EACH X_scales-grp       WHERE X_scales-grp.node-code = n-code NO-LOCK, ~
             EACH X_gds-grp WHERE X_gds-grp.node-code = X_scales-grp.node-code NO-LOCK, ~
             EACH X_scales WHERE X_scales.scales-num = X_scales-grp.scales-num            AND X_scales.db-num = X_scales-grp.db-num     NO-LOCK     BY X_scales-grp.scales-num.
&Scoped-define TABLES-IN-QUERY-br-scal-grp X_scales-grp X_gds-grp X_scales
&Scoped-define FIRST-TABLE-IN-QUERY-br-scal-grp X_scales-grp
&Scoped-define SECOND-TABLE-IN-QUERY-br-scal-grp X_gds-grp
&Scoped-define THIRD-TABLE-IN-QUERY-br-scal-grp X_scales


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-scal-grp}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-add b-del b-help br-scal-grp

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-full-name Dialog-Frame
FUNCTION get-full-name RETURNS CHARACTER
  ( INPUT p-node-code AS INTEGER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход "
     SIZE 10 BY 1
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-scal-grp FOR
      X_scales-grp,
      X_gds-grp,
      X_scales SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-scal-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-scal-grp Dialog-Frame _FREEFORM
  QUERY br-scal-grp NO-LOCK DISPLAY
      X_scales-grp.db-num FORMAT ">>>>9":U
X_scales-grp.scales-num FORMAT ">>9":U
X_scales.scales-name COLUMN-LABEL "Название весов" FORMAT "X(40)":U
X_scales.unit-base COLUMN-LABEL "Ед.изм." FORMAT "X(3)":U
X_scales.tot-gds FORMAT ">>>>9":U
X_scales-grp.node-code COLUMN-LABEL "Вн.код группы" FORMAT ">>>>>>>>9"
get-full-name(X_scales-grp.node-code) COLUMN-LABEL {&col-label1} FORMAT "X(255)":U  WIDTH 80
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 20
         BGCOLOR 15 FGCOLOR 0 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-add AT ROW 1 COL 21
     b-del AT ROW 1 COL 31
     b-help AT ROW 1 COL 95
     br-scal-grp AT ROW 3.3 COL 1
     SPACE(0.00) SKIP(0.26)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         BGCOLOR 8 FGCOLOR 0
         TITLE " Весы по группе".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_gds-grp B "?" ? ub gds-grp
      TABLE: X_scales B "?" ? ub scales
      TABLE: X_scales-grp B "?" ? ub scales-grp
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-scal-grp b-help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       br-scal-grp:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 3.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-scal-grp
/* Query rebuild information for BROWSE br-scal-grp
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_scales-grp
      WHERE X_scales-grp.node-code = n-code NO-LOCK,
      EACH X_gds-grp WHERE X_gds-grp.node-code = X_scales-grp.node-code NO-LOCK,
      EACH X_scales WHERE X_scales.scales-num = X_scales-grp.scales-num
           AND X_scales.db-num = X_scales-grp.db-num
    NO-LOCK
    BY X_scales-grp.scales-num.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _OrdList          = "ub.scales-grp.scales-num|yes"
     _Where[1]         = "scales-grp.node-code = n-code"
     _JoinCode[2]      = "gds-grp.node-code = scales-grp.node-code"
     _JoinCode[3]      = "scales.scales-num = scales-grp.scales-num"
     _Query            is OPENED
*/  /* BROWSE br-scal-grp */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _Options          = "NO-LOCK KEEP-EMPTY"
     _TblOptList       = ","
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /*  Весы по группе */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
RUN proc-b-add IN THIS-PROCEDURE NO-ERROR.
IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
define variable glog as logical no-undo .
define variable v-doc-rec as recid no-undo .
define buffer buf_scales-grp for ub.scales-grp.
if not available X_scales-grp then  do:
  message "Весы не выбраны."
  view-as alert-box ERROR .
  return no-apply.
end.
glog = no.
IF X_scales-grp.db-num <> g#db-num THEN DO:
  MESSAGE
  SUBSTITUTE("Нельзя удалить группу товаров для весов чужой БД &1"
               , X_scales.db-num)
  VIEW-AS ALERT-BOX.
END.
message
substitute("Удаление весов из списка весов,&1" +
           "привязанных к группе товаров.&1"  +
           "Товары данной группы НЕ БУДУТ&1"  +
           "автоматически изменяться в списке товаров&1" +
           "ЭТИХ весов ( с номером &2 (БД &3)&1)" +
           "при появлении их в наличии на каком-либо объекте.&1" +
           "Вы уверены ?&1"
           ,{&new-line}
           ,X_scales.scales-num
           ,X_scales.db-num
           )
view-as alert-box question buttons OK-Cancel update glog.
if not glog then  return no-apply.
glog = no.

{ gbl/chk-actg.i
v-cntxt-db-num
v-cntxt-userid
{&action-head-code-main}
'actn_scales-goods-groups_adding-deletion':U
{&cntxt-global}
0
'':U
0
0
0
0
true
glog
}

if NOT glog then return no-apply.
v-doc-rec = recid( X_scales-grp ).
FIND buf_scales-grp WHERE recid( buf_scales-grp ) = v-doc-rec exclusive.
delete buf_scales-grp no-error .
if error-status:error then do:
  message
  substitute("Ошибки при удалении привязки группы к весам&1&2&1&3"
            , {&NEW-LINE}
            , error-status:get-message(1)
            , return-value )
  view-as alert-box .
  return no-apply.
end.
RUN Openbr in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-scal-grp
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }
 { gbl/brwrepos.i
  &line-num=5}
 { gbl/brwrefre.i "v-doc-rec = recid(X_scales-grp). run Openbr in this-procedure. reposition br-scal-grp to recid v-doc-rec NO-ERROR. v-doc-rec = ?. " }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   { gbl/getcntxt.i get }
    CASE p-mode:
      WHEN {&table_gds-grp}
      OR
      WHEN ({&TABLE_db} + {&comma-char} + {&table_gds-grp}) THEN DO:
        RUN grplib-get-full-name in this-procedure( input n-code, output full-grpname ) .
      END.
      WHEN {&TABLE_scales} THEN DO:
         FIND FIRST locked_scales EXCLUSIVE-LOCK WHERE
                    locked_scales.db-num = p-db-num
                AND locked_scales.scales-num = p-scales-num.
         IF NOT AVAILABLE locked_scales THEN DO:
           MESSAGE
           vss-workfile vss-revision vss-description skip
           substitute("Неверное значение параметра p-db-num=&1 или p-scales-num=&2"
                      , p-db-num
                      , p-scales-num)
           view-as alert-box error .
           undo, return error .
        END.
        if locked_scales.master > 0 then do:
           MESSAGE
           vss-workfile vss-revision vss-description skip
           substitute("Нельзя привязывать группы к подчиненным весам!"
                      , p-db-num
                      , p-scales-num)
           view-as alert-box error .
           undo, return error .
        end.
      END.
    END CASE.
    RUN MYenable in this-procedure .
    RUN Openbr IN THIS-PROCEDURE.
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
  ENABLE b-quit b-add b-del b-help br-scal-grp
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
define variable v-h as handle no-undo .
v-h = br-scal-grp:FIRST-COLUMN IN FRAME {&FRAME-NAME}.
    DO while valid-handle(v-h) :
      if v-h:LABEL = {&col-label1} then do:
        v-h:resizable = yes.
        leave.
      end.
      ELSE DO:
        v-h = v-h:NEXT-COLUMN.
      END.
    END.
ENABLE
b-quit
b-add WHEN (LOOKUP('b-add', bttns) > 0
       AND (p-mode = {&table_db} + {&comma-char} + {&table_gds-grp}
            or
            p-mode = {&table_scales})
       AND p-db-num = v-cntxt-db-num)
b-del WHEN (LOOKUP('b-add', bttns) > 0
       AND (p-mode = {&table_db} + {&comma-char} + {&table_gds-grp}
            or
            p-mode = {&table_scales})
       AND p-db-num = v-cntxt-db-num)
b-help
br-scal-grp
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
CASE p-mode:
  WHEN ({&TABLE_db} + {&comma-char} + {&table_gds-grp})
  or
  when {&table_gds-grp}
  tHEN DO:
    ASSIGN
    X_scales-grp.node-code:VISIBLE IN BROWSE br-scal-grp = NO
    .
    DO while valid-handle(v-h) :
      if v-h:LABEL = {&col-label1} then do:
        v-h:visible = no.
        leave.
      end.
      ELSE DO:
        v-h = v-h:NEXT-COLUMN.
      END.
    END.
  END.
  WHEN {&TABLE_scales} THEN DO:
    ASSIGN
    X_scales-grp.db-num:VISIBLE IN BROWSE br-scal-grp = NO
    X_scales-grp.scales-num:VISIBLE IN BROWSE br-scal-grp = NO
    X_scales.scales-name:VISIBLE IN BROWSE br-scal-grp = NO
    X_scales.unit-base:VISIBLE IN BROWSE br-scal-grp = NO
    X_scales.tot-gds:VISIBLE IN BROWSE br-scal-grp = NO
    .
  END.
END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr Dialog-Frame
PROCEDURE Openbr :
CASE p-mode:
  WHEN ({&table_db} + {&comma-char} + {&table_gds-grp}) THEN DO:
    frame {&frame-name}:title = substitute("Привязка группы товаров &1 к весам для БД &2"
                                          , full-grpname
                                          , p-db-num).
    OPEN QUERY br-scal-grp FOR EACH X_scales-grp
        WHERE X_scales-grp.db-num = p-db-num
            AND X_scales-grp.node-code = n-code NO-LOCK,
        EACH X_gds-grp WHERE X_gds-grp.node-code = X_scales-grp.node-code NO-LOCK, ~
        EACH X_scales WHERE
              X_scales.db-num = X_scales-grp.db-num AND
              X_scales.scales-num = X_scales-grp.scales-num NO-LOCK
      BY X_scales-grp.scales-num.
  END.
  WHEN {&table_db} THEN DO:
    frame {&frame-name}:title = substitute("Привязка групп товаров к весам для БД &1", p-db-num).
    OPEN QUERY br-scal-grp FOR EACH X_scales-grp
        WHERE X_scales-grp.db-num = p-db-num NO-LOCK,
        EACH X_gds-grp WHERE X_gds-grp.node-code = X_scales-grp.node-code NO-LOCK, ~
        EACH X_scales WHERE
              X_scales.db-num = X_scales-grp.db-num AND
              X_scales.scales-num = X_scales-grp.scales-num NO-LOCK
      BY X_scales-grp.scales-num.
  END.
  WHEN {&ALL}  THEN DO:
    frame {&frame-name}:title = substitute("Привязка групп товаров к весам").
    OPEN QUERY br-scal-grp FOR EACH X_scales-grp NO-LOCK,
        EACH X_gds-grp WHERE
            X_gds-grp.node-code = X_scales-grp.node-code NO-LOCK,
        EACH X_scales WHERE
              X_scales.scales-num = X_scales-grp.scales-num NO-LOCK
      BY X_scales-grp.db-num
      BY X_scales-grp.scales-num
        .
  END.
  WHEN {&table_gds-grp}  THEN DO:
    frame {&frame-name}:title = substitute("Привязка группы товаров &1 к весам", full-grpname).
    OPEN QUERY br-scal-grp FOR EACH X_scales-grp
        WHERE X_scales-grp.db-num >= 0
          AND X_scales-grp.node-code = n-code NO-LOCK,
        EACH X_gds-grp WHERE X_gds-grp.node-code = X_scales-grp.node-code NO-LOCK, ~
        EACH X_scales WHERE
              X_scales.scales-num = X_scales-grp.scales-num NO-LOCK
      BY X_scales-grp.db-num
      BY X_scales-grp.scales-num
      .
  END.
  WHEN {&table_scales}  THEN DO:
    frame {&frame-name}:title = substitute("Привязка групп товаров к весам: БД &1 весы № &2", p-db-num, p-scales-num).
      OPEN QUERY br-scal-grp FOR EACH X_scales-grp
          WHERE X_scales-grp.db-num >= p-db-num
            AND X_scales-grp.scales-num = p-scales-num
            NO-LOCK,
          EACH X_gds-grp WHERE X_gds-grp.node-code = X_scales-grp.node-code NO-LOCK, ~
          EACH X_scales WHERE
                X_scales.scales-num = X_scales-grp.scales-num NO-LOCK
        BY X_scales-grp.db-num
        BY X_scales-grp.scales-num
        .
  END.
END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame
PROCEDURE proc-b-add :
define variable glog as logical no-undo .
define buffer buf_scales for ub.scales.
define buffer buf_gds-grp for ub.gds-grp.
define buffer buf2_gds-grp for ub.gds-grp.
define buffer buf_scales-grp for ub.scales-grp.
assign
jj = br-scal-grp:FOCUSED-ROW IN FRAME {&FRAME-NAME}
rec-list = "" .
CASE p-mode:
  WHEN ({&table_db} + {&comma-char} + {&table_gds-grp}) THEN DO:
    run ref/scales.w ( input parparentproc
                    ,input p-obj-type
                    ,input p-obj-code
                    ,input "b-sel,b-mark"
                    ,input 'db':U
                    ,output rec-list ) no-error .
    if ( NOT error-status:error )
    AND ( rec-list <> "" ) then do:
      run waitfram-show in this-procedure ( input "Ждите..." ).
      _II:
      DO ii = 1 TO num-entries( rec-list ) TRANSACTION
              ON ERROR UNDO, return NO-APPLY
              ON END-KEY UNDO, return NO-APPLY
              ON STOP UNDO, return NO-APPLY :
        FIND buf_scales WHERE recid ( buf_scales ) = integer( entry( ii, rec-list ) ) .
        if buf_scales.master > 0 then do:
            message
            substitute("Нельзя привязывать группы к подчиненным весам: игнорируем выбор весов № &1", buf_scales.scales-num)
            view-as alert-box warning .
            next _ii.
        end.
        if NOT can-find( first ub.scales-grp where
                              ub.scales-grp.db-num = buf_scales.db-num AND
                              ub.scales-grp.node-code = n-code AND
                              ub.scales-grp.scales-num = buf_scales.scales-num ) then do:
          CREATE buf_scales-grp .
          assign
          buf_scales-grp.db-num = buf_scales.db-num
          buf_scales-grp.node-code = n-code
          buf_scales-grp.scales-num = buf_scales.scales-num .
        end.
      END .
      run waitfram-hide in this-procedure .
      RUN Openbr in this-procedure .
      glog = br-scal-grp:SET-REPOSITIONED-ROW( jj, "ALWAYS" ).
      REPOSITION br-scal-grp FORWARDS -1.
    end.
  END.
  WHEN {&TABLE_scales} THEN DO:
    run ref/gds-grp.w (
                      input parparentproc
                    , input "b-sel,b-mark"
                    , input p-obj-type
                    , input p-obj-code
                    , input-output rec-list).

    if ( NOT error-status:error )
    AND ( rec-list <> "" ) then do:

      run waitfram-show in this-procedure ( input "Ждите..." ).
      _ii:
      DO ii = 1 TO num-entries( rec-list ) TRANSACTION
              ON ERROR UNDO, return NO-APPLY
              ON END-KEY UNDO, return NO-APPLY
              ON STOP UNDO, return NO-APPLY :
        FIND buf_gds-grp WHERE recid ( buf_gds-grp ) = integer( entry( ii, rec-list ) ) .
        find first buf2_gds-grp no-lock where
                  buf2_gds-grp.upper-code = buf_gds-grp.node-code no-error.
        if available buf2_gds-grp then do:
          message
          substitute("Нельзя привязывать к весам нетерминальные группы: игнорируем выбор группы &1", buf2_gds-grp.node-code)
          view-as alert-box warning .
          next _ii.
        end.
        if NOT can-find( first ub.scales-grp where
                              ub.scales-grp.db-num = locked_scales.db-num AND
                              ub.scales-grp.node-code = buf_gds-grp.node-code AND
                              ub.scales-grp.scales-num = locked_scales.scales-num ) then do:
          CREATE buf_scales-grp .
          assign
          buf_scales-grp.db-num = locked_scales.db-num
          buf_scales-grp.node-code = buf_gds-grp.node-code
          buf_scales-grp.scales-num = locked_scales.scales-num .
        end.
      END .
      run waitfram-hide in this-procedure .
      RUN Openbr in this-procedure .
      glog = br-scal-grp:SET-REPOSITIONED-ROW( jj, "ALWAYS" ).
      REPOSITION br-scal-grp FORWARDS -1.
    end.
  END.
END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-full-name Dialog-Frame
FUNCTION get-full-name RETURNS CHARACTER
  ( INPUT p-node-code AS INTEGER ) :
DEFINE VARIABLE v-full-grpname AS CHARACTER NO-UNDO.
RUN grplib-get-full-name in this-procedure( input p-node-code, output v-full-grpname ) NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
   v-full-grpname = "!!!НЕИЗВЕСТНАЯ ГРУППА".
END.
RETURN v-full-grpname.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME