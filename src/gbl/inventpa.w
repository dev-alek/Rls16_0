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

Настроечные параметры для инвентаризации

Автор: Чернова Светлана Александровна
Дата создания: 07/04/07
Author: Svetlana Chernova
Creation date: 07/04/07


This .W file was created with the Progress AppBuilder.

*/

define input parameter parparentproc as widget-handle no-undo.
define input parameter p-mode        as character no-undo.
define input parameter p-obj-type    like ub.clients.obj-type no-undo.
define input parameter p-obj-code    like ub.shop.obj-code no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-Workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Настроечные параметры для инвентаризации" .
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/thbjattr.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/onewin.i   }
define buffer obj_thbj-attr for ub.thbj-attr.
define buffer glb_thbj-attr for ub.thbj-attr.
define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
define variable v-tth     as handle no-undo .
define variable v-tthg    as handle no-undo .
define variable v-to-create as logical no-undo.
define variable v-to-create-trn as logical no-undo.
define variable v-to-create-trn-g as logical no-undo.
define variable str-attr as character no-undo .
define temp-table thbjattr_thbj-attr-g no-undo like thbjattr_thbj-attr .

assign
v-tth  = buffer thbjattr_thbj-attr:table-handle .
v-tthg = buffer thbjattr_thbj-attr-g:table-handle .
 if g#db-num <> 0 and p-obj-type = "" and  p-obj-code = 0
    then p-mode = {&lookup} .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit I-mxpcdcp I-invclcsp I-invdnull ~
I-pstunqtn I-mxsmdcp I-mxsmicp I-wastage I-mxpcicp I-invclcwt I-invclcas ~
I-inv-prs I-pstgrp I-pstunit I-izlcstpr I-minus B-quit B-Help B-2 ~
invclcsp B-3 invdnull B-4 pstunqtn invclcas invclcwt inv-prs B-7 wastage ~
B-1 mxpcdcp B-9 mxpcicp B-5 mxsmdcp B-6 mxsmicp B-8 pstgrp B-11 pstunit ~
B-10 izlcstpr B-12 minus v-invclcsp v-invdnull v-pstunqtn v-invclcas ~
v-invclcwt v-inv-prs v-wastage v-mxpcdcp v-mxpcicp v-mxsmdcp v-mxsmicp ~
v-pstgrp v-pstunit v-izlcstpr v-minus 
&Scoped-Define DISPLAYED-OBJECTS invclcsp invdnull pstunqtn invclcas ~
invclcwt inv-prs wastage mxpcdcp mxpcicp mxsmdcp mxsmicp pstgrp pstunit ~
izlcstpr minus v-invclcsp v-invdnull v-pstunqtn v-invclcas v-invclcwt ~
v-inv-prs v-wastage v-mxpcdcp v-mxpcicp v-mxsmdcp v-mxsmicp v-pstgrp ~
v-pstunit v-izlcstpr v-minus 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-1 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-10 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-11 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-12 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-2 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-3 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-4 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-5 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-6 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-7 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-8 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-9 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-exit AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help 
     LABEL "&Help" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE inv-prs AS INTEGER FORMAT ">>9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 13.38 BY 1 NO-UNDO.

DEFINE VARIABLE mxpcdcp AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 13.38 BY 1 NO-UNDO.

DEFINE VARIABLE mxpcicp AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 13.38 BY 1 NO-UNDO.

DEFINE VARIABLE mxsmdcp AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 13.38 BY 1 NO-UNDO.

DEFINE VARIABLE mxsmicp AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 13.38 BY 1 NO-UNDO.

DEFINE VARIABLE v-inv-prs AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 90.5 BY 1 NO-UNDO.

DEFINE VARIABLE v-invclcas AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 101.75 BY 1 NO-UNDO.

DEFINE VARIABLE v-invclcsp AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 98.63 BY 1 NO-UNDO.

DEFINE VARIABLE v-invclcwt AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 101.75 BY 1 NO-UNDO.

DEFINE VARIABLE v-invdnull AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 98.13 BY 1 NO-UNDO.

DEFINE VARIABLE v-izlcstpr AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 98.13 BY 1 NO-UNDO.

DEFINE VARIABLE v-mxpcdcp AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 87.5 BY 1 NO-UNDO.

DEFINE VARIABLE v-mxpcicp AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 87.5 BY 1 NO-UNDO.

DEFINE VARIABLE v-mxsmdcp AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 87.5 BY 1 NO-UNDO.

DEFINE VARIABLE v-mxsmicp AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 87.5 BY 1 NO-UNDO.

DEFINE VARIABLE v-minus AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 98.13 BY 1 NO-UNDO.

DEFINE VARIABLE v-pstgrp AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 98.13 BY 1 NO-UNDO.

DEFINE VARIABLE v-pstunit AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 98.13 BY 1 NO-UNDO.

DEFINE VARIABLE v-pstunqtn AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 98.13 BY 1 NO-UNDO.

DEFINE VARIABLE v-wastage AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 98.13 BY 1 NO-UNDO.

DEFINE IMAGE I-inv-prs
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.04.

DEFINE IMAGE I-invclcas
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-invclcsp
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-invclcwt
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-invdnull
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-izlcstpr
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-mxpcdcp
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.04.

DEFINE IMAGE I-mxpcicp
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-mxsmdcp
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-mxsmicp
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.04.

DEFINE IMAGE I-minus
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pstgrp
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pstunit
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-pstunqtn
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-wastage
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE VARIABLE invclcas AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 2.38 BY 1 NO-UNDO.

DEFINE VARIABLE invclcsp AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 2.38 BY 1 NO-UNDO.

DEFINE VARIABLE invclcwt AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 2.38 BY 1 NO-UNDO.

DEFINE VARIABLE invdnull AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 2.38 BY 1 NO-UNDO.

DEFINE VARIABLE izlcstpr AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 2.38 BY 1 NO-UNDO.

DEFINE VARIABLE minus AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 2.38 BY 1 NO-UNDO.

DEFINE VARIABLE pstgrp AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 2.38 BY 1 NO-UNDO.

DEFINE VARIABLE pstunit AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 2.38 BY 1 NO-UNDO.

DEFINE VARIABLE pstunqtn AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 2.38 BY 1 NO-UNDO.

DEFINE VARIABLE wastage AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 2.38 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 98
     B-2 AT ROW 3.04 COL 3.63 WIDGET-ID 82
     invclcsp AT ROW 3.04 COL 6.63 WIDGET-ID 46
     B-3 AT ROW 4 COL 3.63 WIDGET-ID 84
     invdnull AT ROW 4 COL 6.63 WIDGET-ID 52
     B-4 AT ROW 5.04 COL 3.63 WIDGET-ID 86
     pstunqtn AT ROW 5.04 COL 6.63 WIDGET-ID 58
     invclcas AT ROW 6 COL 3.63 WIDGET-ID 182
     invclcwt AT ROW 7 COL 3.63 WIDGET-ID 148
     inv-prs AT ROW 8 COL 1.63 COLON-ALIGNED NO-LABEL WIDGET-ID 194
     B-7 AT ROW 9.25 COL 3.63 WIDGET-ID 92
     wastage AT ROW 9.25 COL 6.63 WIDGET-ID 96
     B-1 AT ROW 12.92 COL 3.63 WIDGET-ID 80
     mxpcdcp AT ROW 12.92 COL 4.63 COLON-ALIGNED NO-LABEL WIDGET-ID 48
     B-9 AT ROW 14 COL 3.63 WIDGET-ID 108
     mxpcicp AT ROW 14 COL 4.63 COLON-ALIGNED NO-LABEL WIDGET-ID 186
     B-5 AT ROW 15.75 COL 3.63 WIDGET-ID 88
     mxsmdcp AT ROW 15.75 COL 4.63 COLON-ALIGNED NO-LABEL WIDGET-ID 188
     B-6 AT ROW 16.88 COL 3.63 WIDGET-ID 90
     mxsmicp AT ROW 16.88 COL 4.63 COLON-ALIGNED NO-LABEL WIDGET-ID 190
     B-8 AT ROW 18.63 COL 3.63 WIDGET-ID 198
     pstgrp AT ROW 18.63 COL 6.63 WIDGET-ID 202
     B-11 AT ROW 20 COL 3.63 WIDGET-ID 298
     pstunit AT ROW 20 COL 6.63 WIDGET-ID 302
     B-10 AT ROW 21.5 COL 3.63 WIDGET-ID 84
     izlcstpr AT ROW 21.5 COL 6.63 WIDGET-ID 20
     B-12 AT ROW 22.71 COL 3.75 WIDGET-ID 306
     minus AT ROW 22.71 COL 6.75 WIDGET-ID 308
     v-invclcsp AT ROW 3.04 COL 9.38 NO-LABEL WIDGET-ID 18
     v-invdnull AT ROW 4 COL 9.38 NO-LABEL WIDGET-ID 54
     v-pstunqtn AT ROW 5.13 COL 9.38 NO-LABEL WIDGET-ID 60
     v-invclcas AT ROW 6 COL 5.75 NO-LABEL WIDGET-ID 184
     v-invclcwt AT ROW 7 COL 5.75 NO-LABEL WIDGET-ID 150
     v-inv-prs AT ROW 8 COL 17 NO-LABEL WIDGET-ID 196
     v-wastage AT ROW 9.38 COL 9.38 NO-LABEL WIDGET-ID 98
     v-mxpcdcp AT ROW 12.92 COL 20 NO-LABEL WIDGET-ID 6
     v-mxpcicp AT ROW 14 COL 20 NO-LABEL WIDGET-ID 114
     v-mxsmdcp AT ROW 15.75 COL 20 NO-LABEL WIDGET-ID 66
     v-mxsmicp AT ROW 16.88 COL 20 NO-LABEL WIDGET-ID 78
     v-pstgrp AT ROW 18.63 COL 9.38 NO-LABEL WIDGET-ID 204
     v-pstunit AT ROW 20 COL 9.38 NO-LABEL WIDGET-ID 304
     v-izlcstpr AT ROW 21.5 COL 7.38 COLON-ALIGNED NO-LABEL WIDGET-ID 20
     v-minus AT ROW 22.71 COL 7.5 COLON-ALIGNED NO-LABEL WIDGET-ID 310
     I-mxpcdcp AT ROW 12.92 COL 1 WIDGET-ID 10
     I-invclcsp AT ROW 3.04 COL 1 WIDGET-ID 34
     I-invdnull AT ROW 4 COL 1 WIDGET-ID 50
     I-pstunqtn AT ROW 5.04 COL 1 WIDGET-ID 56
     I-mxsmdcp AT ROW 15.75 COL 1 WIDGET-ID 64
     I-mxsmicp AT ROW 16.88 COL 1 WIDGET-ID 72
     I-wastage AT ROW 9.25 COL 1 WIDGET-ID 94
     I-mxpcicp AT ROW 14 COL 1 WIDGET-ID 110
     I-invclcwt AT ROW 7 COL 1 WIDGET-ID 146
     I-invclcas AT ROW 6 COL 1 WIDGET-ID 180
     I-inv-prs AT ROW 8 COL 1 WIDGET-ID 192
     I-pstgrp AT ROW 18.63 COL 1 WIDGET-ID 200
     I-pstunit AT ROW 20 COL 1 WIDGET-ID 300
     I-izlcstpr AT ROW 21.5 COL 1 WIDGET-ID 36
     I-minus AT ROW 22.67 COL 1 WIDGET-ID 312
     SPACE(103.99) SKIP(0.32)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Настройки Инвентаризации"
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

/* SETTINGS FOR FILL-IN v-inv-prs IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN 
       v-inv-prs:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-invclcas IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN 
       v-invclcas:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-invclcsp IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN 
       v-invclcsp:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-invclcwt IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN 
       v-invclcwt:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-invdnull IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN 
       v-invdnull:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-mxpcdcp IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN 
       v-mxpcdcp:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-mxpcicp IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN 
       v-mxpcicp:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-mxsmdcp IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN 
       v-mxsmdcp:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-mxsmicp IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN 
       v-mxsmicp:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-pstgrp IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN 
       v-pstgrp:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-pstunit IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN 
       v-pstunit:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-pstunqtn IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN 
       v-pstunqtn:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-wastage IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN 
       v-wastage:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Настройки Инвентаризации */
DO:
  run save-proc in this-procedure no-error.
  if error-status :error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Настройки Инвентаризации */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-1 Dialog-Frame
ON CHOOSE OF B-1 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-inv-obj},
       "mxpcdcp"
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-10
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-10 Dialog-Frame
ON CHOOSE OF B-10 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-inv-obj},
       "izlcstpr"
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-11
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-11 Dialog-Frame
ON CHOOSE OF B-11 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-inv-obj},
       "pstunit"
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-12
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-12 Dialog-Frame
ON CHOOSE OF B-12 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-inv-obj},
       "minus"
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-2 Dialog-Frame
ON CHOOSE OF B-2 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-inv-obj},
       "invclcsp"
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-3 Dialog-Frame
ON CHOOSE OF B-3 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-inv-obj},
       "invdnull"
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-4 Dialog-Frame
ON CHOOSE OF B-4 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-inv-obj},
       "pstunqtn"
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-5
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-5 Dialog-Frame
ON CHOOSE OF B-5 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-inv-obj},
       "mxsmdcp"
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-6
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-6 Dialog-Frame
ON CHOOSE OF B-6 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-inv-obj},
       "mxsmicp"
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-7
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-7 Dialog-Frame
ON CHOOSE OF B-7 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-inv-obj},
       "wastage"
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-8
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-8 Dialog-Frame
ON CHOOSE OF B-8 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-inv-obj},
       "pstgrp"
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-9
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-9 Dialog-Frame
ON CHOOSE OF B-9 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-inv-obj},
       "mxpcicp"
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-inv-prs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-inv-prs Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-inv-prs IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-invclcas
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-invclcas Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-invclcas IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-invclcsp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-invclcsp Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-invclcsp IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-invclcwt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-invclcwt Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-invclcwt IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-invdnull
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-invdnull Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-invdnull IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-izlcstpr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-izlcstpr Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-izlcstpr IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-mxpcdcp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-mxpcdcp Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-mxpcdcp IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-mxpcicp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-mxpcicp Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-mxpcicp IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-mxsmdcp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-mxsmdcp Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-mxsmdcp IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-mxsmicp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-mxsmicp Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-mxsmicp IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-minus
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-minus Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-minus IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pstgrp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pstgrp Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pstgrp IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pstunit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pstunit Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pstunit IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-pstunqtn
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-pstunqtn Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-pstunqtn IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-wastage
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-wastage Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-wastage IN FRAME Dialog-Frame
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
{ gbl/ed_date.i mxpcdcp}
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
if p-obj-type <> "" then
   frame {&frame-name}:title = frame {&frame-name}:title + (if p-obj-type = {&cmp} then " фирма" else " маг") + string(p-obj-code) .

define variable loc#log as logical   no-undo .
/* Проверка прав */
  { gbl/chk-actg.i
    g#db-num
    g#userid
    {&action-head-code-main}
    'actn_nakl-par_lookup':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    loc#log
  }
   if loc#log <> yes then do: return error. end.
    run init-tt.
    run enable_UI.
    run init-proc.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_UI.

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
  DISPLAY invclcsp invdnull pstunqtn invclcas invclcwt inv-prs wastage mxpcdcp 
          mxpcicp mxsmdcp mxsmicp pstgrp pstunit izlcstpr minus v-invclcsp 
          v-invdnull v-pstunqtn v-invclcas v-invclcwt v-inv-prs v-wastage 
          v-mxpcdcp v-mxpcicp v-mxsmdcp v-mxsmicp v-pstgrp v-pstunit v-izlcstpr 
          v-minus 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit I-mxpcdcp I-invclcsp I-invdnull I-pstunqtn I-mxsmdcp I-mxsmicp 
         I-wastage I-mxpcicp I-invclcwt I-invclcas I-inv-prs I-pstgrp I-pstunit 
         I-izlcstpr I-minus B-quit B-Help B-2 invclcsp B-3 invdnull B-4 
         pstunqtn invclcas invclcwt inv-prs B-7 wastage B-1 mxpcdcp B-9 mxpcicp 
         B-5 mxsmdcp B-6 mxsmicp B-8 pstgrp B-11 pstunit B-10 izlcstpr B-12 
         minus v-invclcsp v-invdnull v-pstunqtn v-invclcas v-invclcwt 
         v-inv-prs v-wastage v-mxpcdcp v-mxpcicp v-mxsmdcp v-mxsmicp v-pstgrp 
         v-pstunit v-izlcstpr v-minus 
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
for each thbjattr_thbj-attr-g:
  delete thbjattr_thbj-attr-g.
end.


for each temp-thbj-attr:
  delete temp-thbj-attr.
end.

run adm/shattri.p (
    input "init":U
  , input p-obj-type
  , input p-obj-code
  , input {&attr-inv-obj}
  , input "":U
  , output v-value-character
  , output v-value-date
  , output v-value-decimal
  , output v-value-integer
  , output v-value-logical
  , output v-param-type
  , input-output TABLE-HANDLE v-tth
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
  , input ""
  , input 0
  , input {&attr-inv-global}
  , input "":U
  , output v-value-character
  , output v-value-date
  , output v-value-decimal
  , output v-value-integer
  , output v-value-logical
  , output v-param-type
  , input-output TABLE-HANDLE v-tthg
  ) no-error .
if error-status:error then do:
  message
  "Не удалось получить начальные значения настроек" skip
  error-status:get-message(1) return-value
  view-as alert-box error .
  undo, return error .
end.


&scop telo1  IF thbjattr_thbj-attr.prop-code = ~{&attr-inv-obj_~{&pole~}~} THEN DO: ~
    ~{&pole~} = thbjattr_thbj-attr.property-value-~{&type~}. ~
    ~{&pole~}:private-data in frame {&frame-name} = "recid2=" + string(recid(thbjattr_thbj-attr)). ~
    display ~{&pole~} with frame {&frame-name} . ~
END.

&scop telo1g  IF thbjattr_thbj-attr-g.prop-code = ~{&attr-inv-global_~{&pole~}~} THEN DO: ~
    ~{&pole~} = thbjattr_thbj-attr-g.property-value-~{&type~}. ~
    ~{&pole~}:private-data in frame {&frame-name} = "recid3=" + string(recid(thbjattr_thbj-attr-g)). ~
    display ~{&pole~} with frame {&frame-name} . ~
END.


FOR EACH thbjattr_thbj-attr-g
:


&scop pole invclcwt
&scop type logical
{&telo1g}


&scop pole invclcas
&scop type logical
{&telo1g}

&scop pole inv-prs
&scop type integer
{&telo1g}


  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr-g to temp-thbj-attr.

end.


FOR EACH thbjattr_thbj-attr
:
&scop pole mxpcdcp
&scop type decimal
{&telo1}

&scop pole invclcsp
&scop type logical
{&telo1}

&scop pole invdnull
&scop type logical
{&telo1}

&scop pole pstunqtn
&scop type logical
{&telo1}

&scop pole mxsmdcp
&scop type decimal
{&telo1}

&scop pole mxsmicp
&scop type decimal
{&telo1}

&scop pole wastage
&scop type logical
{&telo1}

&scop pole pstgrp
&scop type logical
{&telo1}

&scop pole pstunit
&scop type logical
{&telo1}

&scop pole mxpcicp
&scop type decimal
{&telo1}

&scop pole izlcstpr
&scop type logical
{&telo1}

&scop pole minus
&scop type logical
{&telo1}

  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr to temp-thbj-attr.

END.


define variable v-tooltip as character no-undo .
define variable v-label   as character no-undo .
define variable v-tooltip-code as character no-undo .

&scop telo2 run thbjattr_tooltip in this-procedure ( ~
   input   {&attr-inv-obj} ~
  ,input  "~{&pole~}" ~
  ,output v-tooltip ~
  ,output v-label ~
  ,output v-tooltip-code ~
  ) no-error . ~
v-~{&pole~}:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  ~
I-~{&pole~}:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .

&scop telo2g run thbjattr_tooltip in this-procedure ( ~
   input   {&attr-inv-global} ~
  ,input  "~{&pole~}" ~
  ,output v-tooltip ~
  ,output v-label ~
  ,output v-tooltip-code ~
  ) no-error . ~
v-~{&pole~}:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  ~
I-~{&pole~}:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .

&scop pole mxpcdcp
{&telo2}

&scop pole invclcsp
{&telo2}

&scop pole mxsmdcp
{&telo2}

&scop pole mxsmicp
{&telo2}

&scop pole invdnull
{&telo2}

&scop pole pstunqtn
{&telo2}

&scop pole wastage
{&telo2}

&scop pole pstgrp
{&telo2}

&scop pole pstunit
{&telo2}

&scop pole mxpcicp
{&telo2}


&scop pole invclcwt
{&telo2g}


&scop pole invclcas
{&telo2g}

&scop pole inv-prs
{&telo2g}

&scop pole izlcstpr
{&telo2}

&scop pole minus
{&telo2}

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
    find first obj_thbj-attr exclusive-lock where
              obj_thbj-attr.obj-type = p-obj-type
        and   obj_thbj-attr.obj-code = p-obj-code
        and   obj_thbj-attr.upper-prop-code = {&attr-inv-obj}
        and   obj_thbj-attr.prop-code = '':u no-wait no-error.
     if locked obj_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
        {&attr-inv-obj} skip
        "Запись ПАРАМЕТРОВ  занята"
        view-as alert-box error .
        undo, return error.
      end.
    find first glb_thbj-attr exclusive-lock where
              glb_thbj-attr.obj-type = ""
        and   glb_thbj-attr.obj-code = 0
        and   glb_thbj-attr.upper-prop-code = {&attr-inv-global}
        and   glb_thbj-attr.prop-code = '':u no-wait no-error.
     if locked glb_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
        {&attr-inv-global} skip
        "Запись Глобальных ПАРАМЕТРОВ  занята"
        view-as alert-box error .
        undo, return error.
      end.

  end.
  else do:
    find first obj_thbj-attr no-lock where
          obj_thbj-attr.obj-type = p-obj-type
    and   obj_thbj-attr.obj-code = p-obj-code
    and   obj_thbj-attr.upper-prop-code = {&attr-inv-obj}
    and   obj_thbj-attr.prop-code = '':u no-error.
    find first glb_thbj-attr no-lock where
          glb_thbj-attr.obj-type = ""
    and   glb_thbj-attr.obj-code = 0
    and   glb_thbj-attr.upper-prop-code = {&attr-inv-global}
    and   glb_thbj-attr.prop-code = '':u no-error.

  end.
  if not available obj_thbj-attr then do:
    assign
      v-to-create-trn  = true
      .
    message
    substitute ("Внимание!!!&1Параметра НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                {&new-line})
                 view-as alert-box warning.

  end.

  if not available glb_thbj-attr then do:
    assign
      v-to-create-trn-g  = true
      .
    message
    substitute ("Внимание!!!&1Гл.Параметра НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                {&new-line})
                 view-as alert-box warning.

  end.

  run fill-widgets in this-procedure no-error.
  if error-status:error then undo, return error.
  if p-mode <> {&update} then do:
     disable
     mxpcdcp
     invclcsp
     mxsmdcp
     mxsmicp
     invdnull
     pstunqtn
     wastage
     mxpcicp
     invclcwt
     invclcas
     inv-prs
     pstgrp
     pstunit
     izlcstpr
     minus
     with frame {&frame-name}.
     B-exit:label = "Вы&ход"  .
     hide B-quit in frame {&frame-name} .
  END.
  if not ( p-obj-type = "" and p-obj-code = 0 ) then do:
     disable
       pstgrp
       invclcwt
       invclcas
       inv-prs
     with frame {&frame-name}.
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
define variable v-same as logical no-undo .
define variable v-sameg as logical no-undo .
IF p-mode = {&LOOKUP} THEN RETURN .
define variable loc#log as logical   no-undo .
/* Проверка прав */
  { gbl/chk-actg.i
    g#db-num
    g#userid
    {&action-head-code-main}
    'actn_nakl-par_update':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    loc#log
  }
  if loc#log <> yes then do: return error. end.

ASSIGN
    mxpcdcp FRAME {&FRAME-NAME}
    invclcsp
    mxsmdcp
    mxsmicp
    invdnull
    pstunqtn
    wastage
    mxpcicp
    invclcwt
    invclcas
    inv-prs
    pstgrp
    pstunit
    izlcstpr
    minus
 .
assign
  fh = frame {&frame-name}:first-child
  wh = fh:first-child
  .
do while valid-handle(wh):
  if wh:private-data begins "recid2=" then do:

    find first thbjattr_thbj-attr where
               recid(thbjattr_thbj-attr) = integer(entry(2, wh:private-data, '='))
               no-error .
    if available thbjattr_thbj-attr then do:
    assign
    buffer thbjattr_thbj-attr:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value.
           thbjattr_thbj-attr.obj-type = p-obj-type.
           thbjattr_thbj-attr.obj-code = p-obj-code.
    end.
  end.
  if wh:private-data begins "recid3=" then do:

    find first thbjattr_thbj-attr-g where
               recid(thbjattr_thbj-attr-g) = integer(entry(2, wh:private-data, '='))
               no-error .
    if available thbjattr_thbj-attr-g then do:
    assign
    buffer thbjattr_thbj-attr-g:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value.
    end.
  end.


  wh = wh:next-sibling.
end.
v-same = yes.
for each thbjattr_thbj-attr where
         thbjattr_thbj-attr.obj-type = p-obj-type and
         thbjattr_thbj-attr.obj-code = p-obj-code ,
    first temp-thbj-attr where
          temp-thbj-attr.obj-type = p-obj-type
      and temp-thbj-attr.obj-code = p-obj-code
      and temp-thbj-attr.upper-prop-code = thbjattr_thbj-attr.upper-prop-code
      and temp-thbj-attr.prop-code = thbjattr_thbj-attr.prop-code :
   buffer-compare
   thbjattr_thbj-attr
   to temp-thbj-attr
   save result in v-same.
   if not v-same then leave.
end.

v-same = no.
v-sameg = yes.
for each thbjattr_thbj-attr-g ,
    first temp-thbj-attr where
          temp-thbj-attr.obj-type = ""
      and temp-thbj-attr.obj-code = 0
      and temp-thbj-attr.upper-prop-code = thbjattr_thbj-attr-g.upper-prop-code
      and temp-thbj-attr.prop-code = thbjattr_thbj-attr-g.prop-code :
   buffer-compare
   thbjattr_thbj-attr-g
   to temp-thbj-attr
   save result in v-sameg.
   if not v-sameg then leave.
end.

v-sameg = no.

do transaction
on error undo, return error return-value
:

  run thbjattr_set-section in this-procedure (
        input p-obj-type
      , input p-obj-code
      , input {&attr-inv-obj}
      , input table thbjattr_thbj-attr
  ) no-error.
  if error-status:error then do:
    message error-status:get-message(1)  skip
    return-value
    view-as alert-box.
    undo, return error.
  end.
  if p-obj-type = "" and p-obj-code = 0  then do:
      run thbjattr_set-section in this-procedure (
            input p-obj-type
          , input p-obj-code
          , input {&attr-inv-global}
          , input table thbjattr_thbj-attr-g
      ) no-error.
      if error-status:error then do:
        message error-status:get-message(1)  skip
        return-value
        view-as alert-box.
        undo, return error.
      end.
  end.

end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

