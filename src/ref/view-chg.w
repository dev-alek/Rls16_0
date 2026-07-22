&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME REDDialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS REDDialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр и изменение коррекции записи в связи с происшедними изменениями реляционных таблиц

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/11/05
Author: Bakhtadze Natalya
Creation date: 11/11/05

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-call-handle AS HANDLE NO-UNDO.
define input parameter p-tbl-name as character no-undo .
DEFINE INPUT PARAMETER p-first-bh AS HANDLE no-undo.
DEFINE INPUT PARAMETER p-next-bh AS HANDLE no-undo.
DEFINE INPUT PARAMETER p-mode AS CHARACTER no-undo.
DEFINE INPUT PARAMETER p-limit-access AS integer no-undo.
DEFINE INPUT PARAMETER p-title AS character no-undo.
define input parameter p-col-old-label as character no-undo .
define input parameter p-col-new-label as character no-undo .
define input parameter p-col-aux-label as character no-undo .
DEFINE INPUT PARAMETER p-descr AS character no-undo.
DEFINE OUTPUT PARAMETER p-ok AS logical no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр и изменение коррекции записи в связи с происшедними изменениями реляционных таблиц".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/color.i }
{ gbl/key-rec.i }
{ ref/tmpchgs.i "SHARED" temp-labels UPDATE }
{ ref/tmpchgs.i " " " " UPDATE}
{ ref/tmpchgs2.i }
DEFINE VARIABLE hndlCellf_update AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE v-first-bh AS HANDLE NO-UNDO.
DEFINE VARIABLE v-next-bh AS HANDLE NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME REDDialog-Frame
&Scoped-define BROWSE-NAME BR-changes

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-changes

/* Definitions for BROWSE BR-changes                                    */
&Scoped-define FIELDS-IN-QUERY-BR-changes temp-changes.l_name temp-changes.f_update temp-changes.f_can_update temp-changes.v_old temp-changes.v_new
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-changes
&Scoped-define SELF-NAME BR-changes
&Scoped-define QUERY-STRING-BR-changes FOR EACH temp-changes
&Scoped-define OPEN-QUERY-BR-changes OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
&Scoped-define TABLES-IN-QUERY-BR-changes temp-changes
&Scoped-define FIRST-TABLE-IN-QUERY-BR-changes temp-changes


/* Definitions for DIALOG-BOX REDDialog-Frame                           */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-mark B-Help ED-notes ~
BR-changes
&Scoped-Define DISPLAYED-OBJECTS ED-notes

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-mark
     LABEL "*"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE ED-notes AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 2.77 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-changes FOR
      temp-changes SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-changes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-changes REDDialog-Frame _FREEFORM
  QUERY BR-changes DISPLAY
      temp-changes.l_name COLUMn-LABEL "Поле" format "X(35)"
temp-changes.f_update COLUMn-LABEL "Изменить" FORMAT "Да/Нет" WIDTH 11
temp-changes.f_can_update COLUMn-LABEL "Можно!Изменить" FORMAT "Да/Нет" WIDTH 11
temp-changes.v_old COLUMn-LABEL "Было" format "X(255)"
temp-changes.v_new COLUMn-LABEL "Стало" format "X(255)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 14.73.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME REDDialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-mark AT ROW 1 COL 31
     B-Help AT ROW 1 COL 95
     ED-notes AT ROW 2.13 COL 1 NO-LABEL
     BR-changes AT ROW 5 COL 1
     SPACE(0.29) SKIP(0.00)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX REDDialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-changes ED-notes REDDialog-Frame */
ASSIGN
       FRAME REDDialog-Frame:SCROLLABLE       = FALSE
       FRAME REDDialog-Frame:HIDDEN           = TRUE.

ASSIGN
       ED-notes:READ-ONLY IN FRAME REDDialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-changes
/* Query rebuild information for BROWSE BR-changes
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE BR-changes */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME REDDialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL REDDialog-Frame REDDialog-Frame
ON WINDOW-CLOSE OF FRAME REDDialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit REDDialog-Frame
ON CHOOSE OF B-exit IN FRAME REDDialog-Frame /* Ввод */
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark REDDialog-Frame
ON CHOOSE OF B-mark IN FRAME REDDialog-Frame /* * */
DO:
    RUN proc-b-mark IN THIS-PROCEDURE NO-ERROR.
    IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-changes
&Scoped-define SELF-NAME BR-changes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-changes REDDialog-Frame
ON MOUSE-SELECT-DBLCLICK OF BR-changes IN FRAME REDDialog-Frame
DO:
   RUN proc-b-mark IN THIS-PROCEDURE NO-ERROR.
    IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-changes REDDialog-Frame
ON ROW-DISPLAY OF BR-changes IN FRAME REDDialog-Frame
DO:
 DO WITH FRAME {&FRAME-NAME}:
  IF Temp-changes.f_can_update THEN
     ASSIGN Temp-changes.f_update:FGCOLOR IN BROWSE br-changes = BROWN_COLOR
            Temp-changes.f_update:BGCOLOR IN BROWSE br-changes = ?.
  ELSE
      ASSIGN Temp-changes.f_update:FGCOLOR IN BROWSE br-changes = 0
             Temp-changes.f_update:BGCOLOR IN BROWSE br-changes = GREY_COLOR.
  IF Temp-changes.f_can_update = no
  and Temp-changes.f_parent <> '' then do:
     ASSIGN Temp-changes.l_name:FGCOLOR IN BROWSE br-changes = GREY_COLOR.
  end.
  else do:
     ASSIGN Temp-changes.l_name:FGCOLOR IN BROWSE br-changes = 0.
  end.
END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-changes REDDialog-Frame
ON VALUE-CHANGED OF BR-changes IN FRAME REDDialog-Frame
DO:
  DO WITH FRAME {&FRAME-NAME}:
    IF AVAILABLE temp-changes THEN DO:
        IF temp-changes.f_can_update = YES THEN
        ASSIGN
        b-mark:sensitive IN FRAME {&frame-name} = YES.
        ELSE
        ASSIGN
        b-mark:sensitive IN FRAME {&frame-name} = no.
    END.
    ELSE DO:

    END.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK REDDialog-Frame


/* ***************************  Main Block  *************************** */

ON ROW-DISPLAY OF br-changes IN frame {&frame-name}
DO:
  RUN set-row-color IN this-procedure  ( INPUT temp-changes.v_old, INPUT temp-changes.v_new).
END.


/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }

   /* Now enable the interface and wait for the exit condition.            */
   /* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN fill-tables IN THIS-PROCEDURE NO-ERROR.
  FIND FIRST temp-changes  NO-ERROR.
  IF NOT AVAILABLE temp-changes THEN RETURN.
  RUN Myenable.
  APPLY "ENTRY":U TO br-changes IN FRAME {&FRAME-NAME}.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE br-changesassignproc REDDialog-Frame
PROCEDURE br-changesassignproc :
DO WITH FRAME {&FRAME-NAME}:
  IF AVAILABLE Temp-changes THEN DO:
    IF SESSION:SET-WAIT-STATE("GENERAL":U) THEN.

    GET CURRENT br-changes EXCLUSIVE-LOCK NO-WAIT.
    IF temp-changes.f_can_update THEN DO:

      ASSIGN
      Temp-changes.f_update = NOT (INPUT BROWSE {&browse-name} Temp-changes.f_update ).
      GET CURRENT br-changes NO-LOCK.
      br-changes:REFRESH().
      IF SESSION:SET-WAIT-STATE("") THEN.
    END.
    else do:
      BELL.
    end.
    IF SESSION:SET-WAIT-STATE("") THEN.
  END.
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI REDDialog-Frame  _DEFAULT-DISABLE
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
  HIDE FRAME REDDialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI REDDialog-Frame  _DEFAULT-ENABLE
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
  DISPLAY ED-notes
      WITH FRAME REDDialog-Frame.
  ENABLE B-exit b-quit B-mark B-Help ED-notes BR-changes
      WITH FRAME REDDialog-Frame.
  VIEW FRAME REDDialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-REDDialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tables REDDialog-Frame
PROCEDURE fill-tables :
DEFINE VARIABLE v-log1 AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-log2 AS LOGICAL NO-UNDO.
define variable fh-first as handle no-undo .
define variable fh-next as handle no-undo .
define variable v-first-rw as rowid no-undo .
define variable v-next-rw as rowid no-undo .
define variable v-ii as integer no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-tbl-name as character no-undo .
CREATE BUFFER v-first-bh FOR TABLE p-first-bh .
CREATE BUFFER v-next-bh FOR TABLE p-next-bh .
if lookup("available", p-mode) > 0 then do:
  assign
  v-first-rw = p-first-bh:rowid
  v-next-rw = p-next-bh:rowid
  .
  /*
  assign
  v-log1 = v-first-bh:FIND-by-rowid(v-first-rw, exclusive-lock) no-error .*/
  run gen-key-rec in this-procedure ( input p-tbl-name
                                     ,input p-first-bh
                                     ,output v-uniq-key-rec).
  run gen-row-keyr in this-procedure
    ( input  v-uniq-key-rec
     ,input  ?
     ,input  '':U /*db-name не играет значения*/
     ,input  p-next-bh
     ,input  0 /*lock не исп*/
     ,output v-next-rw
     ,output v-tbl-name
    ).
  assign
  v-log2 = p-next-bh:FIND-by-rowid(v-next-rw) no-error .
  if not (p-first-bh:available
    and p-next-bh:available) then do:
    undo, return error .
  end.
end.
else do:
  assign
  v-log1 = v-first-bh:FIND-FIRST('') no-error .
  assign
  v-log2 = v-next-bh:FIND-FIRST('') no-error .
end.
if not can-find(first temp-labels) then do:
  do v-ii = 1 to min(v-first-bh:num-fields, v-next-bh:num-fields):
    assign
    fh-first      = p-first-bh:buffer-field( v-ii )
    fh-next       = p-next-bh:buffer-field( v-ii )
    .
    if fh-first:name = fh-next:name
    and fh-first:data-type = fh-next:data-type then do:
      IF  fh-first:BUFFER-VALUE <> fh-next:BUFFER-VALUE
      THEN DO:
        create temp-changes.
        assign
        temp-changes.t_name = p-tbl-name
        temp-changes.f_name = fh-first:name
        temp-changes.l_name = fh-first:label
        temp-changes.v_old = fh-first:string-VALUE
        temp-changes.v_new = fh-next:string-value
        temp-changes.f_can_update = (lookup({&update}, p-mode) > 0)
        temp-changes.f_parent ='':U
        temp-changes.f_visible = yes
        temp-changes.f_root =  p-tbl-name
        temp-changes.num_ = 0
        .
        run tempchgs-create-lable-record in this-procedure (
                                                            input p-tbl-name
                                                          , input fh-first:name
                                                          , input fh-first:name
                                                          , input yes /*update*/
                                                          , input '':U /*parent*/
                                                          , input yes /*vidible*/
                                                          ).
      END.
    end.
  end.
end.
else do:
  IF v-log1 AND v-log2
  or lookup("available", p-mode) > 0
  THEN DO:
    FOR EACH temp-labels NO-LOCK
              where temp-labels.t_name = p-tbl-name:
      IF  v-first-bh:BUFFER-FIELD(temp-labels.f_name):BUFFER-VALUE <>
        v-next-bh:BUFFER-FIELD(temp-labels.f_name):BUFFER-VALUE
      or lookup("view-identical", p-mode) > 0 THEN DO:
        create temp-changes.
        assign
        temp-changes.t_name = temp-labels.t_name
        temp-changes.f_name = temp-labels.f_name
        temp-changes.l_name = temp-labels.l_name
        temp-changes.v_old = string(v-first-bh:BUFFER-FIELD(temp-labels.f_name):BUFFER-VALUE)
        temp-changes.v_new = string(v-next-bh:BUFFER-FIELD(temp-labels.f_name):BUFFER-VALUE)
        temp-changes.f_can_update = temp-labels.f_can_upDATE
        temp-changes.f_parent = temp-labels.f_parent
        temp-changes.f_visible = temp-labels.f_visible
        temp-changes.f_root = temp-labels.f_root
        temp-changes.num_ = 0
        .
      END.
    END.
    /*проверим не подчиненная ли это запись - если да , то проверим не произошло ли изменение в результате смены родителя*/
    /*если в результате смены родителя то отдельно эту запись менять нельзя*/
    run tempchgs-check-child-label-record  in this-procedure .
  END.
end.
delete object v-first-bh  .
delete object v-next-bh  .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable REDDialog-Frame
PROCEDURE MyEnable :
ASSIGN
FRAME {&FRAME-NAME}:TITLE = p-title
ed-notes:SCREEN-VALUE = p-descr
temp-changes.l_name:resizable in browse br-changes = true
temp-changes.v_old:resizable in browse br-changes = true
temp-changes.v_new:resizable in browse br-changes = true
temp-changes.l_name:width in browse br-changes = 30
temp-changes.v_old:width in browse br-changes = 40
temp-changes.v_new:width in browse br-changes = 40
temp-changes.f_update:visible in browse br-changes = (lookup({&LOOKUP}, p-mode) = 0)
.
DISPLAY
ED-notes
WITH FRAME {&frame-name}.
ENABLE
B-exit
b-quit
B-Help
ED-notes
BR-changes
b-mark WHEN (lookup({&LOOKUP}, p-mode) = 0)
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
IF lookup({&LOOKUP}, p-mode) > 0 THEN DO:
  HIDE b-exit
  b-mark
  IN FRAME {&FRAME-NAME}.
  ASSIGN
  b-quit:LABEL = "&Выход"
  b-quit:COL  = 1
  .

END.
ASSIGN
FRAME {&FRAME-NAME}:TITLE = p-title
ed-notes:SCREEN-VALUE = p-descr
temp-changes.v_old:label in browse br-changes = p-col-old-label
temp-changes.v_new:label in browse br-changes = p-col-new-label
.

Open query br-changes
for each temp-changes where
         temp-changes.f_visible = yes
by temp-changes.f_root
by temp-changes.f_parent
by temp-changes.l_name
.
APPLY "ENTRY" to br-changes.
apply "VALUE-CHANGED" to br-changes .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-mark REDDialog-Frame
PROCEDURE proc-b-mark :
define variable glog as logical no-undo .
   DO WITH FRAME {&FRAME-NAME}:
      IF AVAILABLE Temp-changes THEN DO:
        ASSIGN br-changes:SENSITIVE = NO.
        RUN br-changesassignproc IN THIS-PROCEDURE NO-ERROR.
        ASSIGN br-changes:SENSITIVE =YES.
        if lookup( last-event :function, "MOUSE-SELECT-DBLCLICK,Return" ) = 0 then do:
          assign
          glog = {&BROWSE-NAME} :select-next-row () in frame {&FRAME-NAME}
          .
          apply "VALUE-changed":U to {&BROWSE-NAME} in frame {&FRAME-NAME}.
        end.
        apply "entry":U to {&BROWSE-NAME} in frame {&FRAME-NAME}.
     END.
   END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save REDDialog-Frame
PROCEDURE proc-save :
define buffer buf_temp-labels for temp-labels.
FOR EACH temp-changes WHERE
        temp-changes.f_update,
    FIRST temp-labels WHERE
         temp-labels.t_name = temp-changes.t_name
     and temp-labels.f_name = temp-changes.f_name :
    temp-labels.f_Update = YES.
END.
for each temp-labels where
            temp-labels.f_parent = ''
        and temp-labels.f_update = yes:
  for each buf_temp-labels where
          buf_temp-labels.t_name = temp-labels.t_name
      and buf_temp-labels.f_parent = temp-labels.f_name:
    buf_temp-labels.f_update = yes.
  end.
end.
ASSIGN
p-ok = YES.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-row-color REDDialog-Frame
PROCEDURE set-row-color :
DEFINE INPUT PARAMETER p-old AS character.
DEFINE INPUT PARAMETER p-new AS character.
DEFINE VARIABLE iFGColor AS INTEGER NO-UNDO.
DEFINE VARIABLE iBGColor AS INTEGER NO-UNDO.

IF p-old <> p-new THEN DO:
  ASSIGN
  iFGColor = WHITE_COLOR
  iBGColor = DARK_GREEN_COLOR
    .
end.
ELSE do:
  ASSIGN
  iFGColor = Black_COLOR
  iBGColor = White_COLOR
  .
end.
ASSIGN
temp-changes.v_old:FGCOLOR IN BROWSE br-changes = iFGColor
temp-changes.v_old:BGCOLOR IN BROWSE br-changes = iBGColor
temp-changes.v_new:FGCOLOR IN BROWSE br-changes = iFGColor
temp-changes.v_new:BGCOLOR IN BROWSE br-changes = iBGColor

.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME