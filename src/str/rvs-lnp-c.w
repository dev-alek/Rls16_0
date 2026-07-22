&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-rvs-line-pump NO-UNDO LIKE ub.c-rvs-line-pump.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Данные с ТРК 

Автор: Шаланин Сергей 
Дата создания: 10/10/16
Author: Shalanin Sergey
Creation date: 10/10/16

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc    as widget-handle no-undo.
define input parameter p-rec-line-pump as recid     no-undo.
define input parameter p-mode          as character no-undo.
define input parameter p-title         as character no-undo.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Дынне с ТРК":U.
{ cmp/str-glbl.i }
{ cmp/vssrevis.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ gbl/getcntxt.i def }

define variable g-log as logical no-undo.

define buffer bf_rvs-doc          for c-rvs-doc.
define buffer prev_icnt-line      for icnt-line.
define buffer prev_rvs-line-pump  for c-rvs-line-pump.
define buffer bf_goods            for goods.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-rvs-line-pump

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-rvs-line-pump.meas-el-cnt ~
tt-rvs-line-pump.state-el-cnt tt-rvs-line-pump.meas-am-cnt ~
tt-rvs-line-pump.state-am-cnt tt-rvs-line-pump.meas-cf-cnt ~
tt-rvs-line-pump.state-cf-cnt tt-rvs-line-pump.meas-mh-cnt ~
tt-rvs-line-pump.state-mh-cnt tt-rvs-line-pump.meas-mh-qnty ~
tt-rvs-line-pump.state-mh-qnty tt-rvs-line-pump.meas-am-qnty ~
tt-rvs-line-pump.state-am-qnty tt-rvs-line-pump.meas-cf-qnty ~
tt-rvs-line-pump.state-cf-qnty

&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame ~
tt-rvs-line-pump.state-el-cnt tt-rvs-line-pump.state-am-cnt ~
tt-rvs-line-pump.state-cf-cnt tt-rvs-line-pump.state-mh-cnt ~
tt-rvs-line-pump.state-mh-qnty tt-rvs-line-pump.state-am-qnty ~
tt-rvs-line-pump.state-cf-qnty

&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-rvs-line-pump
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-rvs-line-pump

&Scoped-define FIELD-PAIRS-IN-QUERY-Dialog-Frame~
 ~{&FP1}state-el-cnt ~{&FP2}state-el-cnt ~{&FP3}~
 ~{&FP1}state-am-cnt ~{&FP2}state-am-cnt ~{&FP3}~
 ~{&FP1}state-cf-cnt ~{&FP2}state-cf-cnt ~{&FP3}~
 ~{&FP1}state-mh-cnt ~{&FP2}state-mh-cnt ~{&FP3}~
 ~{&FP1}state-mh-qnty ~{&FP2}state-mh-qnty ~{&FP3}~
 ~{&FP1}state-am-qnty ~{&FP2}state-am-qnty ~{&FP3}~
 ~{&FP1}state-cf-qnty ~{&FP2}state-cf-qnty ~{&FP3}

&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-rvs-line-pump SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-rvs-line-pump
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-rvs-line-pump


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-rvs-line-pump.state-el-cnt ~
tt-rvs-line-pump.state-am-cnt tt-rvs-line-pump.state-cf-cnt ~
tt-rvs-line-pump.state-mh-cnt tt-rvs-line-pump.state-mh-qnty ~
tt-rvs-line-pump.state-am-qnty tt-rvs-line-pump.state-cf-qnty

&Scoped-define FIELD-PAIRS~
 ~{&FP1}state-el-cnt ~{&FP2}state-el-cnt ~{&FP3}~
 ~{&FP1}state-am-cnt ~{&FP2}state-am-cnt ~{&FP3}~
 ~{&FP1}state-cf-cnt ~{&FP2}state-cf-cnt ~{&FP3}~
 ~{&FP1}state-mh-cnt ~{&FP2}state-mh-cnt ~{&FP3}~
 ~{&FP1}state-mh-qnty ~{&FP2}state-mh-qnty ~{&FP3}~
 ~{&FP1}state-am-qnty ~{&FP2}state-am-qnty ~{&FP3}~
 ~{&FP1}state-cf-qnty ~{&FP2}state-cf-qnty ~{&FP3}

&Scoped-define ENABLED-TABLES tt-rvs-line-pump
&Scoped-define FIRST-ENABLED-TABLE tt-rvs-line-pump
&Scoped-Define ENABLED-OBJECTS b-save b-cancel b-help
&Scoped-Define DISPLAYED-FIELDS tt-rvs-line-pump.meas-el-cnt ~
tt-rvs-line-pump.state-el-cnt tt-rvs-line-pump.meas-am-cnt ~
tt-rvs-line-pump.state-am-cnt tt-rvs-line-pump.meas-cf-cnt ~
tt-rvs-line-pump.state-cf-cnt tt-rvs-line-pump.meas-mh-cnt ~
tt-rvs-line-pump.state-mh-cnt tt-rvs-line-pump.meas-mh-qnty ~
tt-rvs-line-pump.state-mh-qnty tt-rvs-line-pump.meas-am-qnty ~
tt-rvs-line-pump.state-am-qnty tt-rvs-line-pump.meas-cf-qnty ~
tt-rvs-line-pump.state-cf-qnty

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */
&Scoped-define List-2 tt-rvs-line-pump.state-el-cnt ~
tt-rvs-line-pump.state-am-cnt tt-rvs-line-pump.state-cf-cnt ~
tt-rvs-line-pump.state-mh-cnt tt-rvs-line-pump.state-mh-qnty ~
tt-rvs-line-pump.state-am-qnty tt-rvs-line-pump.state-cf-qnty

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "&Отменить"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-save AUTO-GO
     LABEL "&Сохранить"
     SIZE 10 BY 1
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      tt-rvs-line-pump SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-save AT ROW 1.13 COL 1.5
     b-cancel AT ROW 1.13 COL 11.75
     b-help AT ROW 1.13 COL 22.13
     tt-rvs-line-pump.meas-el-cnt AT ROW 2.46 COL 25 COLON-ALIGNED
          LABEL "Измер. электр. счетчика"
          VIEW-AS FILL-IN
          SIZE 23 BY 1
     tt-rvs-line-pump.state-el-cnt AT ROW 2.46 COL 73.75 COLON-ALIGNED
          LABEL "Показ. электр. счетчика"
          VIEW-AS FILL-IN
          SIZE 23 BY 1
     tt-rvs-line-pump.meas-am-cnt AT ROW 3.67 COL 25 COLON-ALIGNED
          LABEL "Сумма по измер."
          VIEW-AS FILL-IN
          SIZE 23 BY 1
     tt-rvs-line-pump.state-am-cnt AT ROW 3.67 COL 73.75 COLON-ALIGNED
          LABEL "Сумма по показ."
          VIEW-AS FILL-IN
          SIZE 23 BY 1
     tt-rvs-line-pump.meas-cf-cnt AT ROW 4.88 COL 25 COLON-ALIGNED
          LABEL "Кол-во наливов по измер."
          VIEW-AS FILL-IN
          SIZE 19 BY 1
     tt-rvs-line-pump.state-cf-cnt AT ROW 4.88 COL 73.75 COLON-ALIGNED
          LABEL "Кол-во наливов по показ."
          VIEW-AS FILL-IN
          SIZE 19 BY 1
     tt-rvs-line-pump.meas-mh-cnt AT ROW 6.08 COL 25 COLON-ALIGNED
          LABEL "Измер. мех. счетчика"
          VIEW-AS FILL-IN
          SIZE 23 BY 1
     tt-rvs-line-pump.state-mh-cnt AT ROW 6.08 COL 73.75 COLON-ALIGNED
          LABEL "Показ. мех. счетчика"
          VIEW-AS FILL-IN
          SIZE 23 BY 1
     tt-rvs-line-pump.meas-mh-qnty AT ROW 7.29 COL 25 COLON-ALIGNED
          LABEL "Измер. оборот"
          VIEW-AS FILL-IN
          SIZE 17 BY 1
     tt-rvs-line-pump.state-mh-qnty AT ROW 7.29 COL 73.75 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 17 BY 1
     tt-rvs-line-pump.meas-am-qnty AT ROW 8.5 COL 25 COLON-ALIGNED
          LABEL "Измер. сумма оборота"
          VIEW-AS FILL-IN
          SIZE 16 BY 1
     tt-rvs-line-pump.state-am-qnty AT ROW 8.5 COL 73.75 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 16 BY 1
     tt-rvs-line-pump.meas-cf-qnty AT ROW 9.71 COL 25 COLON-ALIGNED
          LABEL "Измер. кол-во наливов"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     tt-rvs-line-pump.state-cf-qnty AT ROW 9.71 COL 73.75 COLON-ALIGNED
          LABEL "Факт кол-во наливов"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     SPACE(12.74) SKIP(0.11)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Данные с ТРК"
         CANCEL-BUTTON b-cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: tt-rvs-line-pump T "?" NO-UNDO ub rvs-line-pump
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN tt-rvs-line-pump.meas-am-cnt IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-rvs-line-pump.meas-am-qnty IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-rvs-line-pump.meas-cf-cnt IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-rvs-line-pump.meas-cf-qnty IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-rvs-line-pump.meas-el-cnt IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-rvs-line-pump.meas-mh-cnt IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-rvs-line-pump.meas-mh-qnty IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-rvs-line-pump.state-am-cnt IN FRAME Dialog-Frame
   2 EXP-LABEL                                                          */
/* SETTINGS FOR FILL-IN tt-rvs-line-pump.state-am-qnty IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR FILL-IN tt-rvs-line-pump.state-cf-cnt IN FRAME Dialog-Frame
   2 EXP-LABEL                                                          */
/* SETTINGS FOR FILL-IN tt-rvs-line-pump.state-cf-qnty IN FRAME Dialog-Frame
   2 EXP-LABEL                                                          */
/* SETTINGS FOR FILL-IN tt-rvs-line-pump.state-el-cnt IN FRAME Dialog-Frame
   2 EXP-LABEL                                                          */
/* SETTINGS FOR FILL-IN tt-rvs-line-pump.state-mh-cnt IN FRAME Dialog-Frame
   2 EXP-LABEL                                                          */
/* SETTINGS FOR FILL-IN tt-rvs-line-pump.state-mh-qnty IN FRAME Dialog-Frame
   2                                                                    */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-rvs-line-pump"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Данные с ТРК */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-save Dialog-Frame
ON CHOOSE OF b-save IN FRAME Dialog-Frame /* Сохранить */
DO:
  define buffer other-line-pump for ub.rvs-line-pump.

&scop mod-check ~
  if input frame {&frame-name} tt-rvs-line-pump.~{&check-field~} <> tt-rvs-line-pump.~{&check-field~} ~
     then run us-~{&check-field~}. ~
  if tt-rvs-line-pump.~{&check-field~} < 0 then do: ~
     message ~{&check-label~} ~
             "Будем сохранять?" ~
     view-as alert-box question buttons yes-no update g-log. ~
     if not g-log then do: ~
        apply "entry" to ~{&check-field~} in frame {&frame-name}. ~
         return no-apply. ~
     end. ~
  end.

  &scop check-field state-el-cnt
  &scop check-label "Показания электронного счетчика отрицательные."
  {&mod-check}
  &scop check-field state-mh-cnt
  &scop check-label "Показания механического счетчика отрицательные."
  {&mod-check}
  &scop check-field state-mh-qnty
  &scop check-label "Факт оборот отрицательный."
  {&mod-check}
  &scop check-field state-cf-cnt
  &scop check-label "Кол-во наливов по показаниям отрицательное."
  {&mod-check}
  &scop check-field state-cf-qnty
  &scop check-label "Факт кол-во наливов отрицательное."
  {&mod-check}
  &scop check-field state-am-cnt
  &scop check-label "Сумма по показаниям отрицательная."
  {&mod-check}
  &scop check-field state-am-qnty
  &scop check-label "Факт сумма оборота за смену отрицательная."
  {&mod-check}

  find first c-rvs-line-pump where  recid(c-rvs-line-pump) =  p-rec-line-pump no-error.
  buffer-copy tt-rvs-line-pump to c-rvs-line-pump.

  for each other-line-pump where
           other-line-pump.rvs-code    = c-rvs-line-pump.rvs-code    and
           other-line-pump.obj-type    = c-rvs-line-pump.obj-type    and
           other-line-pump.obj-code    = c-rvs-line-pump.obj-code    and
           other-line-pump.gds-code    = c-rvs-line-pump.gds-code    and
           other-line-pump.pump-code   = c-rvs-line-pump.pump-code   and
           other-line-pump.nozzle-code = c-rvs-line-pump.nozzle-code :
    if  recid(other-line-pump) = p-rec-line-pump then do: next. end.
    assign other-line-pump.state-am-cnt  = c-rvs-line-pump.state-am-cnt
           other-line-pump.state-am-qnty = c-rvs-line-pump.state-am-qnty
           other-line-pump.state-cf-cnt  = c-rvs-line-pump.state-cf-cnt
           other-line-pump.state-cf-qnty = c-rvs-line-pump.state-cf-qnty
           other-line-pump.state-el-cnt  = c-rvs-line-pump.state-el-cnt
           other-line-pump.state-mh-cnt  = c-rvs-line-pump.state-mh-cnt
           other-line-pump.state-mh-qnty = c-rvs-line-pump.state-mh-qnty.
  end. /* for each other-line-pump */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-rvs-line-pump.state-am-cnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line-pump.state-am-cnt Dialog-Frame
ON LEAVE OF tt-rvs-line-pump.state-am-cnt IN FRAME Dialog-Frame /* Сумма по показ. */
DO:
if input frame {&frame-name} {&self-name} <> {&self-name} then do:
  run us-state-am-cnt no-error.
  if error-status:error then return no-apply.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line-pump.state-am-cnt Dialog-Frame
ON return OF tt-rvs-line-pump.state-am-cnt IN FRAME Dialog-Frame /* Сумма по показ. */
DO:
   apply "entry" to tt-rvs-line-pump.state-cf-cnt in frame {&frame-name}.
 return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-rvs-line-pump.state-am-qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line-pump.state-am-qnty Dialog-Frame
ON LEAVE OF tt-rvs-line-pump.state-am-qnty IN FRAME Dialog-Frame /* Факт сумма оборота за смену */
DO:
if input frame {&frame-name} {&self-name} <> {&self-name} then do:
  run us-state-am-qnty no-error.
  if error-status:error then return no-apply.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line-pump.state-am-qnty Dialog-Frame
ON return OF tt-rvs-line-pump.state-am-qnty IN FRAME Dialog-Frame /* Факт сумма оборота за смену */
DO:
   apply "entry" to tt-rvs-line-pump.state-cf-qnty in frame {&frame-name}.
 return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-rvs-line-pump.state-cf-cnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line-pump.state-cf-cnt Dialog-Frame
ON LEAVE OF tt-rvs-line-pump.state-cf-cnt IN FRAME Dialog-Frame /* Кол-во наливов по показ. */
DO:
if input frame {&frame-name} {&self-name} <> {&self-name} then do:
  run us-state-cf-cnt no-error.
  if error-status:error then return no-apply.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line-pump.state-cf-cnt Dialog-Frame
ON return OF tt-rvs-line-pump.state-cf-cnt IN FRAME Dialog-Frame /* Кол-во наливов по показ. */
DO:
   apply "entry" to tt-rvs-line-pump.state-mh-cnt in frame {&frame-name}.
 return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-rvs-line-pump.state-cf-qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line-pump.state-cf-qnty Dialog-Frame
ON LEAVE OF tt-rvs-line-pump.state-cf-qnty IN FRAME Dialog-Frame /* Факт кол-во наливов */
DO:
if input frame {&frame-name} {&self-name} <> {&self-name} then do:
  run us-state-cf-qnty no-error.
  if error-status:error then return no-apply.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line-pump.state-cf-qnty Dialog-Frame
ON return OF tt-rvs-line-pump.state-cf-qnty IN FRAME Dialog-Frame /* Факт кол-во наливов */
DO:
   apply "entry" to b-save in frame {&frame-name}.
 return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-rvs-line-pump.state-el-cnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line-pump.state-el-cnt Dialog-Frame
ON LEAVE OF tt-rvs-line-pump.state-el-cnt IN FRAME Dialog-Frame /* Показ. электр. счетчика */
DO:
if input frame {&frame-name} {&self-name} <> {&self-name} then do:
  run us-state-el-cnt no-error.
  if error-status:error then return no-apply.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line-pump.state-el-cnt Dialog-Frame
ON return OF tt-rvs-line-pump.state-el-cnt IN FRAME Dialog-Frame /* Показ. электр. счетчика */
DO:
 apply "entry" to tt-rvs-line-pump.state-am-cnt in frame {&frame-name}.
 return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-rvs-line-pump.state-mh-cnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line-pump.state-mh-cnt Dialog-Frame
ON LEAVE OF tt-rvs-line-pump.state-mh-cnt IN FRAME Dialog-Frame /* Показ. мех. счетчика */
DO:
if input frame {&frame-name} {&self-name} <> {&self-name} then do:
  run us-state-mh-cnt no-error.
  if error-status:error then return no-apply.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line-pump.state-mh-cnt Dialog-Frame
ON return OF tt-rvs-line-pump.state-mh-cnt IN FRAME Dialog-Frame /* Показ. мех. счетчика */
DO:
   apply "entry" to tt-rvs-line-pump.state-mh-qnty in frame {&frame-name}.
 return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-rvs-line-pump.state-mh-qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line-pump.state-mh-qnty Dialog-Frame
ON LEAVE OF tt-rvs-line-pump.state-mh-qnty IN FRAME Dialog-Frame /* Факт оборот */
DO:
if input frame {&frame-name} {&self-name} <> {&self-name} then do:
  run us-state-mh-qnty no-error.
  if error-status:error then return no-apply.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line-pump.state-mh-qnty Dialog-Frame
ON return OF tt-rvs-line-pump.state-mh-qnty IN FRAME Dialog-Frame /* Факт оборот */
DO:
   apply "entry" to tt-rvs-line-pump.state-am-qnty in frame {&frame-name}.
 return no-apply.
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
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }

  if p-mode = {&update} then
     find first c-rvs-line-pump where recid(c-rvs-line-pump) =  p-rec-line-pump no-error.
  else
     find first c-rvs-line-pump where recid(c-rvs-line-pump) =  p-rec-line-pump no-lock no-error.
  if not available c-rvs-line-pump then do:
     message "Неверно переданы параметры."
             "Не найдена строка данных с ТРК с recid " p-rec-line-pump " ."
     view-as alert-box error.
     return error.
  end.
  create tt-rvs-line-pump.
  buffer-copy c-rvs-line-pump to tt-rvs-line-pump.
  release c-rvs-line-pump.
  find first bf_rvs-doc where bf_rvs-doc.rvs-code = tt-rvs-line-pump.rvs-code.
  RUN enable_UI.
  if p-mode <> {&update} then do:
     disable {&list-2} with frame {&frame-name}.
  end.
/*  else do:                                                */
/*      case bf_rvs-doc.rvs-type                            */
/*      :                                                   */
/*        when {&rvs-before-doc}                            */
/*        or when {&rvs-after-doc}                          */
/*        then do:                                          */
/*          { gbl/chk-actg.i                                */
/*            v-cntxt-db-num                                */
/*            v-cntxt-userid                                */
/*            {&action-head-code-main}                      */
/*            'actn_rvs-on-doc_upd-revision':U              */
/*            {&cntxt-object}                               */
/*            bf_rvs-doc.host-code                          */
/*            bf_rvs-doc.obj-type                           */
/*            bf_rvs-doc.obj-code                           */
/*            0                                             */
/*            0                                             */
/*            0                                             */
/*            false                                         */
/*            g-log                                         */
/*          }                                               */
/*        end.                                              */
/*        when {&rvs-shift}                                 */
/*        then do:                                          */
/*          { gbl/chk-actg.i                                */
/*            v-cntxt-db-num                                */
/*            v-cntxt-userid                                */
/*            {&action-head-code-main}                      */
/*            'actn_rvs-shift_upd-revision':U               */
/*            {&cntxt-object}                               */
/*            bf_rvs-doc.host-code                          */
/*            bf_rvs-doc.obj-type                           */
/*            bf_rvs-doc.obj-code                           */
/*            0                                             */
/*            0                                             */
/*            0                                             */
/*            false                                         */
/*            g-log                                         */
/*          }                                               */
/*        end.                                              */
/*        when {&rvs-control}                               */
/*        then do:                                          */
/*          { gbl/chk-actg.i                                */
/*            v-cntxt-db-num                                */
/*            v-cntxt-userid                                */
/*            {&action-head-code-main}                      */
/*            'actn_rvs-control_upd-revision':U             */
/*            {&cntxt-object}                               */
/*            bf_rvs-doc.host-code                          */
/*            bf_rvs-doc.obj-type                           */
/*            bf_rvs-doc.obj-code                           */
/*            0                                             */
/*            0                                             */
/*            0                                             */
/*            false                                         */
/*            g-log                                         */
/*          }                                               */
/*        end.                                              */
/*        otherwise do:                                     */
/*          message                                         */
/*            vss-workfile vss-revision vss-description skip*/
/*            "Неизвестный тип сверки" skip                 */
/*            "Тип документа" bf_rvs-doc.rvs-type skip      */
/*            "Код документа" bf_rvs-doc.rvs-code skip      */
/*            view-as alert-box error .                     */
/*          undo, return error return-value .               */
/*        end.                                              */
/*      end case .                                          */
/*     if not g-log then do:                                */
/*        disable {&list-2} with frame {&frame-name}.       */
/*     end.                                                 */
/*  end.                                                    */
  if p-mode <> {&update} then
    disable b-save with frame {&frame-name}.
   /*Ищем предыдущую инвентаризацию*/
   if tt-rvs-line-pump.icnt-code <> ? then do:
      find prev_icnt-line where prev_icnt-line.doc-code    = tt-rvs-line-pump.icnt-code   and
                                prev_icnt-line.obj-type    = tt-rvs-line-pump.obj-type    and
                                prev_icnt-line.obj-code    = tt-rvs-line-pump.obj-code    and
                                prev_icnt-line.pump-code   = tt-rvs-line-pump.pump-code   and
                                prev_icnt-line.nozzle-code = tt-rvs-line-pump.nozzle-code no-lock no-error.
      if not available prev_icnt-line then do:
         message "Фатальная ошибка. Нет инвентаризации счетчика № " tt-rvs-line-pump.icnt-code " !" skip
              "Объект: " tt-rvs-line-pump.obj-type " " tt-rvs-line-pump.obj-code skip
              "ТРК: " tt-rvs-line-pump.pump-code skip
              "Пистолет: " tt-rvs-line-pump.nozzle-code
         view-as alert-box error.
      end.
   end.

   /*Ищем предыдущую сверку*/
   if tt-rvs-line-pump.rvs-prev-code <> ? then do:
      find first prev_rvs-line-pump where prev_rvs-line-pump.rvs-code    = tt-rvs-line-pump.rvs-prev-code and
                                          prev_rvs-line-pump.obj-type    = tt-rvs-line-pump.obj-type      and
                                          prev_rvs-line-pump.obj-code    = tt-rvs-line-pump.obj-code      and
                                          prev_rvs-line-pump.pl-code     = tt-rvs-line-pump.pl-code       and
                                          prev_rvs-line-pump.gds-code    = tt-rvs-line-pump.gds-code      and
                                          prev_rvs-line-pump.pump-code   = tt-rvs-line-pump.pump-code     and
                                          prev_rvs-line-pump.nozzle-code = tt-rvs-line-pump.nozzle-code   no-lock no-error.
      if not available prev_rvs-line-pump then do:
         find first bf_goods where bf_goods.gds-code = tt-rvs-line-pump.gds-code no-lock.
         message "Фатальная ошибка. Нет сверки № " tt-rvs-line-pump.rvs-prev-code " !" skip
              "Объект: " tt-rvs-line-pump.obj-type " " tt-rvs-line-pump.obj-code skip
              "Складское место: " tt-rvs-line-pump.pl-code skip
              "Товар: " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " " bf_goods.gds-name skip
              "ТРК: " tt-rvs-line-pump.pump-code skip
              "Пистолет: " tt-rvs-line-pump.nozzle-code
         view-as alert-box error.
      end.
   end.
  assign frame {&frame-name}:title = frame {&frame-name}:title + " - " + p-mode
  + " - " +  p-title.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame _DEFAULT-DISABLE
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame _DEFAULT-ENABLE
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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  IF AVAILABLE tt-rvs-line-pump THEN
    DISPLAY tt-rvs-line-pump.meas-el-cnt tt-rvs-line-pump.state-el-cnt
          tt-rvs-line-pump.meas-am-cnt tt-rvs-line-pump.state-am-cnt
          tt-rvs-line-pump.meas-cf-cnt tt-rvs-line-pump.state-cf-cnt
          tt-rvs-line-pump.meas-mh-cnt tt-rvs-line-pump.state-mh-cnt
          tt-rvs-line-pump.meas-mh-qnty tt-rvs-line-pump.state-mh-qnty
          tt-rvs-line-pump.meas-am-qnty tt-rvs-line-pump.state-am-qnty
          tt-rvs-line-pump.meas-cf-qnty tt-rvs-line-pump.state-cf-qnty
      WITH FRAME Dialog-Frame.
  ENABLE b-save b-cancel b-help tt-rvs-line-pump.state-el-cnt
         tt-rvs-line-pump.state-am-cnt tt-rvs-line-pump.state-cf-cnt
         tt-rvs-line-pump.state-mh-cnt tt-rvs-line-pump.state-mh-qnty
         tt-rvs-line-pump.state-am-qnty tt-rvs-line-pump.state-cf-qnty
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE us-state-am-cnt Dialog-Frame
PROCEDURE us-state-am-cnt :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
assign frame {&frame-name} tt-rvs-line-pump.state-am-cnt.
assign tt-rvs-line-pump.state-am-qnty = tt-rvs-line-pump.state-am-cnt -
                                        (if tt-rvs-line-pump.rvs-prev-code <> ? then
                                         prev_rvs-line-pump.state-am-cnt else ?).
display tt-rvs-line-pump.state-am-qnty with frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE us-state-am-qnty Dialog-Frame
PROCEDURE us-state-am-qnty :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
assign frame {&frame-name} tt-rvs-line-pump.state-am-qnty.
assign tt-rvs-line-pump.state-am-cnt = tt-rvs-line-pump.state-am-qnty +
                                        (if tt-rvs-line-pump.rvs-prev-code <> ? then
                                         prev_rvs-line-pump.state-am-cnt else ?).
display tt-rvs-line-pump.state-am-cnt with frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE us-state-cf-cnt Dialog-Frame
PROCEDURE us-state-cf-cnt :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
assign frame {&frame-name} tt-rvs-line-pump.state-cf-cnt.
assign tt-rvs-line-pump.state-cf-qnty = tt-rvs-line-pump.state-cf-cnt -
                                        (if tt-rvs-line-pump.rvs-prev-code <> ? then
                                         prev_rvs-line-pump.state-cf-cnt else ?).
display tt-rvs-line-pump.state-cf-qnty with frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE us-state-cf-qnty Dialog-Frame
PROCEDURE us-state-cf-qnty :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

assign frame {&frame-name} tt-rvs-line-pump.state-cf-qnty.
assign tt-rvs-line-pump.state-cf-cnt = tt-rvs-line-pump.state-cf-qnty +
                                        (if tt-rvs-line-pump.rvs-prev-code <> ? then
                                         prev_rvs-line-pump.state-cf-cnt else ?).
display tt-rvs-line-pump.state-cf-cnt with frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE us-state-el-cnt Dialog-Frame
PROCEDURE us-state-el-cnt :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
assign frame {&frame-name} tt-rvs-line-pump.state-el-cnt.
assign tt-rvs-line-pump.state-mh-cnt = tt-rvs-line-pump.state-el-cnt -
                                       (if tt-rvs-line-pump.icnt-code <> ? then (prev_icnt-line.state-el-cnt - prev_icnt-line.state-mh-cnt) else 0)
       tt-rvs-line-pump.state-mh-qnty = tt-rvs-line-pump.state-mh-cnt -
                                       (if tt-rvs-line-pump.rvs-prev-code <> ? then prev_rvs-line-pump.state-mh-cnt else ?).
display tt-rvs-line-pump.state-mh-cnt tt-rvs-line-pump.state-mh-qnty with frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE us-state-mh-cnt Dialog-Frame
PROCEDURE us-state-mh-cnt :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
assign frame {&frame-name} tt-rvs-line-pump.state-mh-cnt.
assign tt-rvs-line-pump.state-el-cnt = tt-rvs-line-pump.state-mh-cnt +
                                       (if tt-rvs-line-pump.icnt-code <> ? then (prev_icnt-line.state-el-cnt - prev_icnt-line.state-mh-cnt) else 0)
       tt-rvs-line-pump.state-mh-qnty = tt-rvs-line-pump.state-mh-cnt -
                                        (if tt-rvs-line-pump.rvs-prev-code <> ? then prev_rvs-line-pump.state-mh-cnt else ?).
display tt-rvs-line-pump.state-el-cnt tt-rvs-line-pump.state-mh-qnty with frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE us-state-mh-qnty Dialog-Frame
PROCEDURE us-state-mh-qnty :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
assign frame {&frame-name} tt-rvs-line-pump.state-mh-qnty.
assign  tt-rvs-line-pump.state-mh-cnt = tt-rvs-line-pump.state-mh-qnty +
                                       (if available prev_rvs-line-pump then prev_rvs-line-pump.state-mh-cnt else ?).
        tt-rvs-line-pump.state-el-cnt = tt-rvs-line-pump.state-mh-cnt +
                                       (if tt-rvs-line-pump.icnt-code <> ? then (prev_icnt-line.state-el-cnt - prev_icnt-line.state-mh-cnt) else ?).

display tt-rvs-line-pump.state-el-cnt tt-rvs-line-pump.state-mh-cnt with frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
