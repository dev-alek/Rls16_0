&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Глобальные параметры для системы ЗАКАЗОВ

Автор: Чернова Светлана Александровна
Дата создания: 02/11/02
Author: Svetlana Chernova
Creation date: 02/11/02

This .W file was created with the Progress AppBuilder.

*/

define input parameter parparentproc as widget-handle no-undo.
define input parameter p-mode     as character no-undo.
define input parameter p-obj-type like ub.clients.obj-type no-undo.
define input parameter p-obj-code like ub.clients.obj-code no-undo.


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-Workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Глобальные параметры для системы ЗАКАЗОВ" .
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/thbjattr.i }

define buffer bufglbl_thbj-attr for ub.thbj-attr.
define buffer bufobj_thbj-attr  for ub.thbj-attr.
define temp-table temp-thbj-attr no-undo like ub.thbj-attr.

define temp-table glbl_thbj-attr-ord no-undo like ub.thbj-attr.
define temp-table  obj_thbj-attr-ord no-undo like ub.thbj-attr.

define variable v-tth     as handle no-undo .
define variable v-tth-glbl as handle no-undo .
define variable v-tth-obj  as handle no-undo .
define variable v-to-create-glbl as logical no-undo.
define variable v-to-create-obj as logical no-undo.
define variable str-attr as character no-undo .
assign
v-tth      = buffer thbjattr_thbj-attr:table-handle .
v-tth-glbl = buffer glbl_thbj-attr-ord:table-handle .
v-tth-obj  = buffer obj_thbj-attr-ord:table-handle .

if p-obj-type = "" then do:
if g#db-num <> 0  and p-obj-type = "" then  p-mode = {&lookup} .
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit B-quit B-Help I-ord-log I-ord-ofof ~
I-ord-oobj I-ord-op I-ord-min-ost-day I-ord-askp I-ord-obj-rc I-ordshipd ~
I-ordcyclg I-ord-wgt-div-prc I-ord-11 I-ord-comp-prc ord-log ord-ofof ~
ord-oobj ord-op ord-min-ost-day B-attr-ord-askp ord-askp B-attr-ord-obj-rc ~
B-cli ordshipd ordcyclg B-attr-ord-wgt-div-prc ord-wgt-div-prc ~
B-attr-ord-11 ord-11 B-attr-ord-comp-prc ord-comp-prc v-ord-log v-ord-ofof ~
v-ord-oobj v-ord-op v-ord-min-ost-day v-ord-askp ord-obj-rc v-ord-obj-rc ~
v-ordshipd v-ordcyclg v-ord-wgt-div-prc v-ord-11 v-ord-comp-prc 
&Scoped-Define DISPLAYED-OBJECTS ord-log ord-ofof ord-oobj ord-op ~
ord-min-ost-day ord-askp ordshipd ordcyclg ord-wgt-div-prc ord-11 ~
ord-comp-prc v-ord-log v-ord-ofof v-ord-oobj v-ord-op v-ord-min-ost-day ~
v-ord-askp ord-obj-rc v-ord-obj-rc v-ordshipd v-ordcyclg v-ord-wgt-div-prc ~
v-ord-11 v-ord-comp-prc 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-attr-ord-11 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-attr-ord-askp 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-attr-ord-comp-prc 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-attr-ord-obj-rc 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-attr-ord-wgt-div-prc 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-cli 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-exit AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1.

DEFINE BUTTON B-Help 
     LABEL "&Help" 
     SIZE 10 BY 1.

DEFINE BUTTON B-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1.

DEFINE VARIABLE ord-comp-prc AS DECIMAL FORMAT ">>9.99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 7 BY 1 NO-UNDO.

DEFINE VARIABLE ord-obj-rc AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 13 BY 1 NO-UNDO.

DEFINE VARIABLE ord-wgt-div-prc AS DECIMAL FORMAT ">>9.99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 7 BY 1 NO-UNDO.

DEFINE VARIABLE ordshipd AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 4.63 BY 1 NO-UNDO.

DEFINE VARIABLE v-ord-11 AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 77.63 BY 1 NO-UNDO.

DEFINE VARIABLE v-ord-askp AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 77.63 BY 1 NO-UNDO.

DEFINE VARIABLE v-ord-comp-prc AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 69 BY 1 NO-UNDO.

DEFINE VARIABLE v-ord-log AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 77 BY 1 NO-UNDO.

DEFINE VARIABLE v-ord-min-ost-day AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 77 BY 1 NO-UNDO.

DEFINE VARIABLE v-ord-obj-rc AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 59.75 BY 1 NO-UNDO.

DEFINE VARIABLE v-ord-ofof AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 77 BY 1 NO-UNDO.

DEFINE VARIABLE v-ord-oobj AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 77 BY 1 NO-UNDO.

DEFINE VARIABLE v-ord-op AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 77 BY 1 NO-UNDO.

DEFINE VARIABLE v-ord-wgt-div-prc AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 69 BY 1 NO-UNDO.

DEFINE VARIABLE v-ordcyclg AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 77 BY 1 NO-UNDO.

DEFINE VARIABLE v-ordshipd AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 75 BY 1 NO-UNDO.

DEFINE IMAGE I-ord-11
     FILENAME "cmp/info.bmp":U
     SIZE 3.63 BY 1.

DEFINE IMAGE I-ord-askp
     FILENAME "cmp/info.bmp":U
     SIZE 3.63 BY 1.

DEFINE IMAGE I-ord-comp-prc
     FILENAME "cmp/info.bmp":U
     SIZE 3.63 BY 1.

DEFINE IMAGE I-ord-log
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.04.

DEFINE IMAGE I-ord-min-ost-day
     FILENAME "cmp/info.bmp":U
     SIZE 3.63 BY 1.

DEFINE IMAGE I-ord-obj-rc
     FILENAME "cmp/info.bmp":U
     SIZE 3.63 BY 1.

DEFINE IMAGE I-ord-ofof
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-ord-oobj
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-ord-op
     FILENAME "cmp/info.bmp":U
     SIZE 3.63 BY 1.

DEFINE IMAGE I-ord-wgt-div-prc
     FILENAME "cmp/info.bmp":U
     SIZE 3.63 BY 1.

DEFINE IMAGE I-ordcyclg
     FILENAME "cmp/info.bmp":U
     SIZE 3.63 BY 1.

DEFINE IMAGE I-ordshipd
     FILENAME "cmp/info.bmp":U
     SIZE 3.63 BY 1.

DEFINE VARIABLE ord-11 AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 2.38 BY 1 NO-UNDO.

DEFINE VARIABLE ord-askp AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 1.75 BY 1 NO-UNDO.

DEFINE VARIABLE ord-log AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 2 BY 1 NO-UNDO.

DEFINE VARIABLE ord-min-ost-day AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 2 BY 1 NO-UNDO.

DEFINE VARIABLE ord-ofof AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 2 BY 1 NO-UNDO.

DEFINE VARIABLE ord-oobj AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 2 BY 1 NO-UNDO.

DEFINE VARIABLE ord-op AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 2 BY 1 NO-UNDO.

DEFINE VARIABLE ordcyclg AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 2 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 74.63
     ord-log AT ROW 3 COL 4 WIDGET-ID 44
     ord-ofof AT ROW 3.96 COL 4 WIDGET-ID 46
     ord-oobj AT ROW 4.96 COL 4 WIDGET-ID 48
     ord-op AT ROW 5.92 COL 4 WIDGET-ID 50
     ord-min-ost-day AT ROW 6.88 COL 4 WIDGET-ID 54
     B-attr-ord-askp AT ROW 7.79 COL 3.63 WIDGET-ID 72
     ord-askp AT ROW 7.79 COL 6.75 WIDGET-ID 60
     B-attr-ord-obj-rc AT ROW 9.04 COL 3.63 WIDGET-ID 74
     B-cli AT ROW 9.04 COL 6.25 WIDGET-ID 76
     ordshipd AT ROW 10.21 COL 1.63 COLON-ALIGNED NO-LABEL WIDGET-ID 84
     ordcyclg AT ROW 11.21 COL 4 WIDGET-ID 88
     B-attr-ord-wgt-div-prc AT ROW 12.29 COL 3.63 WIDGET-ID 98
     ord-wgt-div-prc AT ROW 12.29 COL 4.75 COLON-ALIGNED NO-LABEL WIDGET-ID 94
     B-attr-ord-11 AT ROW 13.5 COL 3.38 WIDGET-ID 100
     ord-11 AT ROW 13.5 COL 6.63 WIDGET-ID 104
     B-attr-ord-comp-prc AT ROW 14.71 COL 3.63 WIDGET-ID 108
     ord-comp-prc AT ROW 14.71 COL 4.75 COLON-ALIGNED NO-LABEL WIDGET-ID 112
     v-ord-log AT ROW 3 COL 6.63 NO-LABEL WIDGET-ID 6
     v-ord-ofof AT ROW 3.96 COL 6.63 NO-LABEL WIDGET-ID 18
     v-ord-oobj AT ROW 4.96 COL 6.63 NO-LABEL WIDGET-ID 20
     v-ord-op AT ROW 5.92 COL 6.63 NO-LABEL WIDGET-ID 38
     v-ord-min-ost-day AT ROW 6.88 COL 6.63 NO-LABEL WIDGET-ID 56
     v-ord-askp AT ROW 7.88 COL 9.63 NO-LABEL WIDGET-ID 62
     ord-obj-rc AT ROW 9.04 COL 7.63 COLON-ALIGNED NO-LABEL WIDGET-ID 70
     v-ord-obj-rc AT ROW 9.04 COL 23.63 NO-LABEL WIDGET-ID 68
     v-ordshipd AT ROW 10.21 COL 8.63 NO-LABEL WIDGET-ID 82
     v-ordcyclg AT ROW 11.21 COL 6.63 NO-LABEL WIDGET-ID 90
     v-ord-wgt-div-prc AT ROW 12.29 COL 12.25 COLON-ALIGNED NO-LABEL WIDGET-ID 96
     v-ord-11 AT ROW 13.5 COL 9.38 NO-LABEL WIDGET-ID 106
     v-ord-comp-prc AT ROW 14.71 COL 12.25 COLON-ALIGNED NO-LABEL WIDGET-ID 114
     I-ord-log AT ROW 3 COL 1.63 WIDGET-ID 10
     I-ord-ofof AT ROW 3.96 COL 1.63 WIDGET-ID 34
     I-ord-oobj AT ROW 4.96 COL 1.63 WIDGET-ID 36
     I-ord-op AT ROW 5.92 COL 1.63 WIDGET-ID 40
     I-ord-min-ost-day AT ROW 6.88 COL 1.63 WIDGET-ID 52
     I-ord-askp AT ROW 7.88 COL 1.63 WIDGET-ID 58
     I-ord-obj-rc AT ROW 9.04 COL 1.63 WIDGET-ID 64
     I-ordshipd AT ROW 10.21 COL 1.63 WIDGET-ID 78
     I-ordcyclg AT ROW 11.21 COL 1.63 WIDGET-ID 86
     I-ord-wgt-div-prc AT ROW 12.29 COL 1.63 WIDGET-ID 92
     I-ord-11 AT ROW 13.5 COL 1.63 WIDGET-ID 102
     I-ord-comp-prc AT ROW 14.71 COL 1.63 WIDGET-ID 110
     SPACE(81.98) SKIP(3.45)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Настройки для заказов"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN 
       ord-obj-rc:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-ord-11 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN 
       v-ord-11:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-ord-askp IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN 
       v-ord-askp:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN 
       v-ord-comp-prc:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-ord-log IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN 
       v-ord-log:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-ord-min-ost-day IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN 
       v-ord-min-ost-day:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-ord-obj-rc IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN 
       v-ord-obj-rc:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-ord-ofof IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN 
       v-ord-ofof:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-ord-oobj IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN 
       v-ord-oobj:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-ord-op IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN 
       v-ord-op:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN 
       v-ord-wgt-div-prc:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-ordcyclg IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN 
       v-ordcyclg:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-ordshipd IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN 
       v-ordshipd:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Настройки для заказов */
DO:
  run save-proc in this-procedure no-error.
  if error-status :error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Настройки для заказов */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-attr-ord-11
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-attr-ord-11 Dialog-Frame
ON CHOOSE OF B-attr-ord-11 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-ord-obj},
       {&attr-ord-obj_ord-11}
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-attr-ord-askp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-attr-ord-askp Dialog-Frame
ON CHOOSE OF B-attr-ord-askp IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-ord-obj},
       {&attr-ord-obj_ord-askp}
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-attr-ord-comp-prc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-attr-ord-comp-prc Dialog-Frame
ON CHOOSE OF B-attr-ord-comp-prc IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-ord-obj},
       {&attr-ord-obj_ord-comp-prc}
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-attr-ord-obj-rc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-attr-ord-obj-rc Dialog-Frame
ON CHOOSE OF B-attr-ord-obj-rc IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-ord-obj},
       {&attr-ord-obj_ord-obj-rc}
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-attr-ord-wgt-div-prc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-attr-ord-wgt-div-prc Dialog-Frame
ON CHOOSE OF B-attr-ord-wgt-div-prc IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-ord-obj},
       {&attr-ord-obj_ord-wgt-div-prc}
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-cli Dialog-Frame
ON CHOOSE OF B-cli IN FRAME Dialog-Frame
DO:
  define variable rid-list    as  char no-undo . /* список recid'ов выбранных клиентов */
  def buffer buf_clients for ub.clients.
    run ref/cli-all.w
    ( input parParentProc,
      input "b-sel",
      input {&g___object},
      input ?,
      input ?,
      input ? ,
      input ",,,,,,NO"   ,
      input "lock-cli-type",
      output  rid-list
      ) .

    find first buf_clients where recid(buf_clients) = integer(rid-list) no-lock no-error.
    if available buf_clients
    then
        Assign
           ord-obj-rc = buf_clients.obj-type + string( buf_clients.obj-code)
           .
    else
        assign
          ord-obj-rc = ""
        .
    Display ord-obj-rc with frame {&frame-name} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-ord-11
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-ord-11 Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-ord-11 IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-ord-askp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-ord-askp Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-ord-askp IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-ord-comp-prc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-ord-comp-prc Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-ord-comp-prc IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-ord-log
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-ord-log Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-ord-log IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-ord-min-ost-day
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-ord-min-ost-day Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-ord-min-ost-day IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-ord-obj-rc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-ord-obj-rc Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-ord-obj-rc IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-ord-ofof
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-ord-ofof Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-ord-ofof IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-ord-oobj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-ord-oobj Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-ord-oobj IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-ord-op
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-ord-op Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-ord-op IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-ord-wgt-div-prc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-ord-wgt-div-prc Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-ord-wgt-div-prc IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-ordcyclg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-ordcyclg Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-ordcyclg IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-ordshipd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-ordshipd Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-ordshipd IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
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

define variable loc#log as logical   no-undo .
/* Проверка прав */
  { gbl/chk-actg.i
    g#db-num
    g#userid
    {&action-head-code-main}
    'actn_global-ord_lookup':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    loc#log
  }
  if loc#log <> yes then do:
     return.
  end.
  if p-obj-type <> "" then do:
     FRAME {&FRAME-NAME}:TITLE = FRAME {&FRAME-NAME}:TITLE + (if p-obj-type = {&cmp} then " фирма" else " маг") + STRING(p-obj-code) .
  end.

    RUN init-tt.
    RUN enable_UI.
    RUN init-proc.

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
  DISPLAY ord-log ord-ofof ord-oobj ord-op ord-min-ost-day ord-askp ordshipd 
          ordcyclg ord-wgt-div-prc ord-11 ord-comp-prc v-ord-log v-ord-ofof 
          v-ord-oobj v-ord-op v-ord-min-ost-day v-ord-askp ord-obj-rc 
          v-ord-obj-rc v-ordshipd v-ordcyclg v-ord-wgt-div-prc v-ord-11 
          v-ord-comp-prc 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-quit B-Help I-ord-log I-ord-ofof I-ord-oobj I-ord-op 
         I-ord-min-ost-day I-ord-askp I-ord-obj-rc I-ordshipd I-ordcyclg 
         I-ord-wgt-div-prc I-ord-11 I-ord-comp-prc ord-log ord-ofof ord-oobj 
         ord-op ord-min-ost-day B-attr-ord-askp ord-askp B-attr-ord-obj-rc 
         B-cli ordshipd ordcyclg B-attr-ord-wgt-div-prc ord-wgt-div-prc 
         B-attr-ord-11 ord-11 B-attr-ord-comp-prc ord-comp-prc v-ord-log 
         v-ord-ofof v-ord-oobj v-ord-op v-ord-min-ost-day v-ord-askp ord-obj-rc 
         v-ord-obj-rc v-ordshipd v-ordcyclg v-ord-wgt-div-prc v-ord-11 
         v-ord-comp-prc 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-widgets Dialog-Frame 
PROCEDURE fill-widgets :
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-param-type as character no-undo .
define variable v-param-value as character no-undo .

for each thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.

for each glbl_thbj-attr-ord:
  delete glbl_thbj-attr-ord.
end.
for each obj_thbj-attr-ord:
  delete obj_thbj-attr-ord.
end.


for each temp-thbj-attr:
  delete temp-thbj-attr.
end.

run adm/shattri.p (
    input "init":U
  , input ""
  , input 0
  , input {&attr-ord-global}
  , input "":U
  , output v-value-character
  , output v-value-date
  , output v-value-decimal
  , output v-value-integer
  , output v-value-logical
  , output v-param-type
  , input-output TABLE-HANDLE v-tth-glbl
  ) no-error .
if error-status:error then do:
  message
  "Не удалось получить начальные значения настроек" skip
  error-status:get-message(1) return-value
  view-as alert-box error .
  undo, return error .
end.

run adm/shattri.p (
    input "init":U
  , input p-obj-type
  , input p-obj-code
  , input {&attr-ord-obj}
  , input "":U
  , output v-value-character
  , output v-value-date
  , output v-value-decimal
  , output v-value-integer
  , output v-value-logical
  , output v-param-type
  , input-output TABLE-HANDLE v-tth-obj
  ) no-error .
if error-status:error then do:
  message
  "Не удалось получить начальные значения настроек" skip
  error-status:get-message(1) return-value
  view-as alert-box error .
  undo, return error .
end.


FOR EACH glbl_thbj-attr-ord
  :
  IF glbl_thbj-attr-ord.prop-code = {&attr-ord-global_ord-log} THEN DO:
     ord-log = glbl_thbj-attr-ord.property-value-logical.
     ord-log:PRIVATE-DATA IN FRAME {&frame-name}  = "recid2=" + string(recid(glbl_thbj-attr-ord)).
     display ord-log with frame {&frame-name} .
  END.
  IF glbl_thbj-attr-ord.prop-code = {&attr-ord-global_ord-ofof} THEN DO:
     ord-ofof = glbl_thbj-attr-ord.property-value-logical.
     ord-ofof:private-data = "recid2=" + string(recid(glbl_thbj-attr-ord)).
     display ord-ofof with frame {&frame-name} .
  END.
  IF glbl_thbj-attr-ord.prop-code = {&attr-ord-global_ord-oobj} THEN DO:
     ord-oobj = glbl_thbj-attr-ord.property-value-logical.
     ord-oobj:private-data = "recid2=" + string(recid(glbl_thbj-attr-ord)).
     display ord-oobj with frame {&frame-name} .
  END.
  IF glbl_thbj-attr-ord.prop-code = {&attr-ord-global_ord-op} THEN DO:
     ord-op = glbl_thbj-attr-ord.property-value-logical.
     ord-op:private-data = "recid2=" + string(recid(glbl_thbj-attr-ord)).
    display ord-op with frame {&frame-name} .
  END.
  IF glbl_thbj-attr-ord.prop-code = {&attr-ord-global_ordshipd} THEN DO:
     ordshipd = glbl_thbj-attr-ord.property-value-integer.
     ordshipd:private-data = "recid2=" + string(recid(glbl_thbj-attr-ord)).
    display ordshipd with frame {&frame-name} .
  END.

  IF glbl_thbj-attr-ord.prop-code = {&attr-ord-global_ordcyclg} THEN DO:
     ordcyclg = glbl_thbj-attr-ord.property-value-logical.
     ordcyclg:private-data = "recid2=" + string(recid(glbl_thbj-attr-ord)).
    display ordcyclg with frame {&frame-name} .
  END.

  IF glbl_thbj-attr-ord.prop-code = {&attr-ord-global_ord-min-ost-day} THEN DO:
     ord-min-ost-day = glbl_thbj-attr-ord.property-value-logical.
     ord-min-ost-day:private-data = "recid2=" + string(recid(glbl_thbj-attr-ord)).
    display ord-min-ost-day with frame {&frame-name} .
  END.

  create temp-thbj-attr.
  buffer-copy glbl_thbj-attr-ord to temp-thbj-attr.
END.

FOR EACH obj_thbj-attr-ord:
  IF obj_thbj-attr-ord.prop-code = {&attr-ord-obj_ord-askp} THEN DO:
     ord-askp = obj_thbj-attr-ord.property-value-logical.
     ord-askp:PRIVATE-DATA IN FRAME {&frame-name}  = "recid3=" + string(recid(obj_thbj-attr-ord)).
     display ord-askp with frame {&frame-name} .
  END.
  IF obj_thbj-attr-ord.prop-code = {&attr-ord-obj_ord-obj-rc} THEN DO:
     ord-obj-rc = obj_thbj-attr-ord.property-value-character.
     ord-obj-rc:PRIVATE-DATA IN FRAME {&frame-name}  = "recid3=" + string(recid(obj_thbj-attr-ord)).
     display ord-obj-rc with frame {&frame-name} .
  END.
  IF obj_thbj-attr-ord.prop-code = {&attr-ord-obj_ord-wgt-div-prc} THEN DO:
     ord-wgt-div-prc = obj_thbj-attr-ord.property-value-decimal.
     ord-wgt-div-prc:PRIVATE-DATA IN FRAME {&frame-name}  = "recid3=" + string(recid(obj_thbj-attr-ord)).
     display ord-wgt-div-prc with frame {&frame-name} .
  END.
  IF obj_thbj-attr-ord.prop-code = {&attr-ord-obj_ord-comp-prc} THEN DO:
     ord-comp-prc = obj_thbj-attr-ord.property-value-decimal.
     ord-comp-prc:PRIVATE-DATA IN FRAME {&frame-name}  = "recid3=" + string(recid(obj_thbj-attr-ord)).
     display ord-comp-prc with frame {&frame-name} .
  END.
  IF obj_thbj-attr-ord.prop-code = {&attr-ord-obj_ord-11} THEN DO:
     ord-11 = obj_thbj-attr-ord.property-value-logical.
     ord-11:PRIVATE-DATA IN FRAME {&frame-name}  = "recid3=" + string(recid(obj_thbj-attr-ord)).
     display ord-11 with frame {&frame-name} .
  END.

  create temp-thbj-attr.
  buffer-copy obj_thbj-attr-ord to temp-thbj-attr.
END.


define variable v-tooltip as character no-undo .
define variable v-label   as character no-undo .
define variable v-tooltip-code as character no-undo .


run thbjattr_tooltip in this-procedure (
             input   {&attr-ord-global}
            ,input  "ord-log"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-ord-log:screen-value = entry(2,v-label,":") .
I-ord-log:private-data =  REPLACE ( v-tooltip-code , '`' , ',' ).

run thbjattr_tooltip in this-procedure (
             input   {&attr-ord-global}
            ,input  "ord-ofof"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-ord-ofof:screen-value = entry(2,v-label,":") .
I-ord-ofof:private-data = REPLACE ( v-tooltip-code , '`' , ',' ) .

run thbjattr_tooltip in this-procedure (
             input   {&attr-ord-global}
            ,input  "ord-oobj"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-ord-oobj:screen-value = entry(2,v-label,":") .
I-ord-oobj:private-data = REPLACE ( v-tooltip-code , '`' , ',' ) .

run thbjattr_tooltip in this-procedure (
             input   {&attr-ord-global}
            ,input  "ord-op"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-ord-op:screen-value = entry(2,v-label,":") .
I-ord-op:private-data = REPLACE ( v-tooltip-code , '`' , ',' ) .
run thbjattr_tooltip in this-procedure (
             input   {&attr-ord-global}
            ,input  "ordshipd"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-ordshipd:screen-value = entry(2,v-label,":") .
I-ordshipd:private-data = REPLACE ( v-tooltip-code , '`' , ',' ) .

run thbjattr_tooltip in this-procedure (
             input   {&attr-ord-global}
            ,input  "ordcyclg"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-ordcyclg:screen-value = entry(2,v-label,":") .
I-ordcyclg:private-data = REPLACE ( v-tooltip-code , '`' , ',' ) .

run thbjattr_tooltip in this-procedure (
             input   {&attr-ord-global}
            ,input  "ord-min-ost-day"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-ord-min-ost-day:screen-value = entry(2,v-label,":") .
I-ord-min-ost-day:private-data = REPLACE ( v-tooltip-code , '`' , ',' ) .

run thbjattr_tooltip in this-procedure (
             input   {&attr-ord-obj}
            ,input  "ord-askp"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-ord-askp:screen-value = entry(2,v-label,":") .
I-ord-askp:private-data = REPLACE ( v-tooltip-code , '`' , ',' ) .
run thbjattr_tooltip in this-procedure (
             input   {&attr-ord-obj}
            ,input  "ord-11"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-ord-11:screen-value = entry(2,v-label,":") .
I-ord-11:private-data = REPLACE ( v-tooltip-code , '`' , ',' ) .

run thbjattr_tooltip in this-procedure (
             input   {&attr-ord-obj}
            ,input  "ord-obj-rc"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-ord-obj-rc:screen-value = entry(2,v-label,":") .
I-ord-obj-rc:private-data = REPLACE ( v-tooltip-code , '`' , ',' ) .
run thbjattr_tooltip in this-procedure (
             input  {&attr-ord-obj}
            ,input  {&attr-ord-obj_ord-wgt-div-prc}
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-ord-wgt-div-prc:screen-value = entry(2,v-label,":") .
I-ord-wgt-div-prc:private-data = REPLACE ( v-tooltip-code , '`' , ',' ) .

run thbjattr_tooltip in this-procedure (
             input  {&attr-ord-obj}
            ,input  {&attr-ord-obj_ord-comp-prc}
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-ord-comp-prc:screen-value = entry(2,v-label,":") .
I-ord-comp-prc:private-data = REPLACE ( v-tooltip-code , '`' , ',' ) .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-proc Dialog-Frame 
PROCEDURE init-proc :
define variable v-i as integer   no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-type as character no-undo .
define variable v-value as character no-undo .
define variable v-found as decimal   no-undo .
  if p-mode = {&update} then do:
    find first bufglbl_thbj-attr exclusive-lock where
              bufglbl_thbj-attr.obj-type = ""
        and   bufglbl_thbj-attr.obj-code = 0
        and   bufglbl_thbj-attr.upper-prop-code = {&attr-ord-global}
        and   bufglbl_thbj-attr.prop-code = '':u no-wait no-error.
     if locked bufglbl_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
        {&attr-ord-global} skip
        "Запись Глобальных ПАРАМЕТРОВ ord занята"
        view-as alert-box error .
        undo, return error.
      end.
  end.
  else do:
    find first bufglbl_thbj-attr no-lock where
          bufglbl_thbj-attr.obj-type = ""
    and   bufglbl_thbj-attr.obj-code = 0
    and   bufglbl_thbj-attr.upper-prop-code = {&attr-ord-global}
    and   bufglbl_thbj-attr.prop-code = '':u no-error.
  end.
  if not available bufglbl_thbj-attr then do:
    assign
      v-to-create-glbl  = true
      .
    message
    substitute ("Внимание!!!&1Параметра ord-gbl НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                {&new-line})
                 view-as alert-box warning.
  end.

   find first bufobj_thbj-attr exclusive-lock where
              bufobj_thbj-attr.obj-type = p-obj-type
        and   bufobj_thbj-attr.obj-code = p-obj-code
        and   bufobj_thbj-attr.upper-prop-code = {&attr-ord-obj}
        and   bufobj_thbj-attr.prop-code = '':u no-wait no-error.
     if locked bufobj_thbj-attr then do:
        message
        "Запись ПАРАМЕТРОВ ord-obj занята"
        view-as alert-box error .
        undo, return error.
  end.
  else do:
    find first bufobj_thbj-attr no-lock where
          bufobj_thbj-attr.obj-type = p-obj-type
    and   bufobj_thbj-attr.obj-code = p-obj-code
    and   bufobj_thbj-attr.upper-prop-code = {&attr-ord-obj}
    and   bufobj_thbj-attr.prop-code = '':u no-error.
  end.
  if not available bufobj_thbj-attr then do:
    assign
      v-to-create-obj  = true
      .
    message
    substitute ("Внимание!!!&1Параметра ord-obj НЕТ в БД &2&3 !&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                {&new-line},
                p-obj-type ,
                p-obj-code
                )
                 view-as alert-box warning.
  end.

  run fill-widgets in this-procedure no-error.
  if error-status:error then undo, return error.
  if p-mode <> {&update} then do:
     disable ord-log ord-ofof ord-oobj ord-op ordshipd ord-min-ost-day  ord-askp ord-11 ord-obj-rc b-cli ordcyclg  with frame {&frame-name}.
     B-exit:label = "Вы&ход"  .
     hide B-quit in frame {&frame-name} .
  END.
  /* Глобальные параметры для объектов только на просмотр */
  if p-obj-type <> "" then do:
     disable ord-log ord-ofof ord-oobj ord-op ord-min-ost-day ordshipd ordcyclg with frame {&frame-name}.
  end.

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-tt Dialog-Frame 
PROCEDURE init-tt :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-proc Dialog-Frame 
PROCEDURE save-proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-sale-add as character no-undo .
define variable v-trf-type like ub.clients.obj-type no-undo .
define variable v-trf-code like ub.clients.obj-code no-undo .
define variable v-param-type as character no-undo .
define variable wh as widget-handle no-undo .
define variable fh as widget-handle no-undo .
define variable v-same-glbl as logical no-undo .
define variable v-same-obj  as logical no-undo .

IF p-mode = {&LOOKUP} THEN RETURN .
define variable loc#log as logical   no-undo .
/* Проверка прав */
  { gbl/chk-actg.i
    g#db-num
    g#userid
    {&action-head-code-main}
    'actn_global-ord_update':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    loc#log
  }
  if loc#log <> yes then do: return error. end.

ASSIGN
    ord-log FRAME {&FRAME-NAME}
    ord-ofof
    ord-oobj
    ord-op
    ordshipd
    ordcyclg
    ord-min-ost-day
    ord-askp
    ord-11
    ord-obj-rc
    .
assign
  fh = frame {&frame-name}:first-child
  wh = fh:first-child
  .

do while valid-handle(wh):
  if wh:private-data begins "recid2=" then do:
    find first glbl_thbj-attr-ord where
              recid(glbl_thbj-attr-ord) = integer(entry(2, wh:private-data, '=')).
    assign
    buffer glbl_thbj-attr-ord:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value.
  end.
  if wh:private-data begins "recid3=" then do:
    find first obj_thbj-attr-ord where
              recid(obj_thbj-attr-ord) = integer(entry(2, wh:private-data, '=')).
    assign
    buffer obj_thbj-attr-ord:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value.
  end.
  wh = wh:next-sibling.
end.
v-same-glbl = yes.
v-same-obj = yes.


for each glbl_thbj-attr-ord,
    first temp-thbj-attr where
          temp-thbj-attr.obj-type = glbl_thbj-attr-ord.obj-type
      and temp-thbj-attr.obj-code = glbl_thbj-attr-ord.obj-code
      and temp-thbj-attr.upper-prop-code = glbl_thbj-attr-ord.upper-prop-code
      and temp-thbj-attr.prop-code = glbl_thbj-attr-ord.prop-code:
   buffer-compare
   glbl_thbj-attr-ord
   to temp-thbj-attr
   save result in v-same-glbl.
   if not v-same-glbl then leave.
end.
v-same-glbl = no.

for each obj_thbj-attr-ord,
    first temp-thbj-attr where
          temp-thbj-attr.obj-type = obj_thbj-attr-ord.obj-type
      and temp-thbj-attr.obj-code = obj_thbj-attr-ord.obj-code
      and temp-thbj-attr.upper-prop-code = obj_thbj-attr-ord.upper-prop-code
      and temp-thbj-attr.prop-code       = obj_thbj-attr-ord.prop-code:
   buffer-compare
   obj_thbj-attr-ord
   to temp-thbj-attr
   save result in v-same-obj.
   if not v-same-obj then leave.
end.
v-same-obj = no.

 /*IF  v-same-obj   and not v-to-create-obj  and v-same-glbl  and not v-to-create-glbl  THEN RETURN.*/

do TRANSACTION
on error undo, return error return-value
:
  run thbjattr_set-section in this-procedure (
       input ""
      ,input 0
      ,input {&attr-ord-global}
      ,input table glbl_thbj-attr-ord
  ) no-error.
  if error-status:error then do:
    message error-status:get-message(1)  skip
    return-value
    view-as alert-box.
    undo, return error.
  end.

  run thbjattr_set-section in this-procedure (
       input p-obj-type
      ,input p-obj-code
      ,input {&attr-ord-obj}
      ,input table obj_thbj-attr-ord
  ) no-error.
  if error-status:error then do:
    message error-status:get-message(1)  skip
    return-value
    view-as alert-box.
    undo, return error.
  end.

end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

