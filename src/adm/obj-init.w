&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-config


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_sysconf FOR sysconf.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-config 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Настройки системы Sysconf

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/13/05
Author: Bakhtadze Natalya
Creation date: 09/13/05

Author:  Романов Илья Иванович  (правил Исаков Андрей)
Created: 22.10.94

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Настройки системы Sysconf".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
/* 28/VIII-2018 - не используется
{ gbl/getcntxt.i def }
*/


define variable all-prt_ like ub.shop.all-prt no-undo.
define variable cd-bc-alt_ like ub.shop.cd-bc-alt no-undo.
define variable cd-bc-base_ like ub.shop.cd-bc-base no-undo.
define variable cd-loc-alt_ like ub.shop.cd-loc-alt no-undo.
define variable cd-loc-base_ like ub.shop.cd-loc-base no-undo.
define variable cd-parts-all_ like ub.shop.cd-parts-all no-undo.
define variable cd-parts-not-blank_ like ub.shop.cd-parts-not-blank no-undo.
define variable cd-parts-ser_ like ub.shop.cd-parts-ser no-undo.
define variable cd-pb-alt_ like ub.shop.cd-pb-alt no-undo.
define variable cd-pb-base_ like ub.shop.cd-pb-base no-undo.
define variable cd-sc-base_ like ub.shop.cd-sc-base no-undo.
define variable v-to-c-d as logical no-undo .
define buffer buf_clients for ub.clients.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-config

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS X_sysconf.rsrv-time X_sysconf.load-time ~
X_sysconf.holidays X_sysconf.out-line-discnt X_sysconf.price-calc ~
X_sysconf.out-rate X_sysconf.no-eq X_sysconf.in-ov X_sysconf.unit-cli-perm ~
X_sysconf.inout-price X_sysconf.in-perm X_sysconf.in-pay X_sysconf.out-pay ~
X_sysconf.ret-pay X_sysconf.ret-sup-pay X_sysconf.down-pay ~
X_sysconf.inv-pay X_sysconf.chk-pay X_sysconf.fbr-pay ~
X_sysconf.xdn-grp-code 
&Scoped-define ENABLED-TABLES X_sysconf
&Scoped-define FIRST-ENABLED-TABLE X_sysconf
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-tocd b-help RECT-1 b-inpay ~
b-outpay b-retpay b-suppay b-spipay b-invpay b-realpay b-fbrpay 
&Scoped-Define DISPLAYED-FIELDS X_sysconf.rsrv-time X_sysconf.load-time ~
X_sysconf.holidays X_sysconf.out-line-discnt X_sysconf.price-calc ~
X_sysconf.out-rate X_sysconf.no-eq X_sysconf.in-ov X_sysconf.unit-cli-perm ~
X_sysconf.inout-price X_sysconf.in-perm X_sysconf.in-pay X_sysconf.out-pay ~
X_sysconf.ret-pay X_sysconf.ret-sup-pay X_sysconf.down-pay ~
X_sysconf.inv-pay X_sysconf.chk-pay X_sysconf.fbr-pay ~
X_sysconf.xdn-grp-code 
&Scoped-define DISPLAYED-TABLES X_sysconf
&Scoped-define FIRST-DISPLAYED-TABLE X_sysconf


/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO 
     LABEL "&Ввод ":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-fbrpay 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L 
     SIZE 3 BY .91.

DEFINE BUTTON b-help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1.

DEFINE BUTTON b-inpay 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L 
     SIZE 3 BY .91.

DEFINE BUTTON b-invpay 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L 
     SIZE 3 BY .91.

DEFINE BUTTON b-outpay 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L 
     SIZE 3 BY .91.

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-realpay 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L 
     SIZE 3 BY .91.

DEFINE BUTTON b-retpay 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L 
     SIZE 3 BY .91.

DEFINE BUTTON b-spipay 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L 
     SIZE 3 BY .91.

DEFINE BUTTON b-suppay 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L 
     SIZE 3 BY .91.

DEFINE BUTTON b-tocd 
     LABEL "&На кассу" 
     SIZE 10 BY 1.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 3 GRAPHIC-EDGE    
     SIZE 34 BY 9.24
     BGCOLOR 8 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-config
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-tocd AT ROW 1 COL 41
     b-help AT ROW 1 COL 69
     X_sysconf.rsrv-time AT ROW 2 COL 31.8 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 4 BY 1
     X_sysconf.load-time AT ROW 2 COL 60 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 4 BY 1
     X_sysconf.holidays AT ROW 3 COL 52.6 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 11.6 BY 1
     X_sysconf.out-line-discnt AT ROW 5 COL 43
          VIEW-AS TOGGLE-BOX
          SIZE 22 BY .81
     X_sysconf.price-calc AT ROW 6 COL 2
          VIEW-AS TOGGLE-BOX
          SIZE 36.6 BY .81
     X_sysconf.out-rate AT ROW 6 COL 43
          VIEW-AS TOGGLE-BOX
          SIZE 22 BY .81
     X_sysconf.no-eq AT ROW 7 COL 2
          VIEW-AS TOGGLE-BOX
          SIZE 37.6 BY .81
     X_sysconf.in-ov AT ROW 7 COL 43
          VIEW-AS TOGGLE-BOX
          SIZE 23 BY .81
     X_sysconf.unit-cli-perm AT ROW 8 COL 2
          VIEW-AS TOGGLE-BOX
          SIZE 32.6 BY .81
     X_sysconf.inout-price AT ROW 8 COL 43
          VIEW-AS TOGGLE-BOX
          SIZE 32 BY .81
     X_sysconf.in-perm AT ROW 9 COL 2
          VIEW-AS TOGGLE-BOX
          SIZE 69 BY .81
     X_sysconf.in-pay AT ROW 11.52 COL 30.6 COLON-ALIGNED
          LABEL "п&рихода"
          VIEW-AS FILL-IN 
          SIZE 6 BY 1
     b-inpay AT ROW 11.52 COL 39.6 WIDGET-ID 6
     X_sysconf.out-pay AT ROW 12.52 COL 30.6 COLON-ALIGNED
          LABEL "рас&хода"
          VIEW-AS FILL-IN 
          SIZE 6 BY 1
     b-outpay AT ROW 12.52 COL 39.6 WIDGET-ID 10
     X_sysconf.ret-pay AT ROW 13.52 COL 30.6 COLON-ALIGNED
          LABEL "во&зврата"
          VIEW-AS FILL-IN 
          SIZE 6 BY 1
     b-retpay AT ROW 13.52 COL 39.6 WIDGET-ID 14
     X_sysconf.ret-sup-pay AT ROW 14.52 COL 30.6 COLON-ALIGNED
          LABEL "возвра&та пост."
          VIEW-AS FILL-IN 
          SIZE 6 BY 1
     b-suppay AT ROW 14.52 COL 39.6 WIDGET-ID 18
     X_sysconf.down-pay AT ROW 15.52 COL 30.6 COLON-ALIGNED
          LABEL "списани&я"
          VIEW-AS FILL-IN 
          SIZE 6 BY 1
     b-spipay AT ROW 15.52 COL 39.6 WIDGET-ID 16
     X_sysconf.inv-pay AT ROW 16.52 COL 30.6 COLON-ALIGNED
          LABEL "и&нвентар."
          VIEW-AS FILL-IN 
          SIZE 6 BY 1
     b-invpay AT ROW 16.52 COL 39.6 WIDGET-ID 8
     X_sysconf.chk-pay AT ROW 17.52 COL 30.6 COLON-ALIGNED
          LABEL "продажи"
          VIEW-AS FILL-IN 
          SIZE 6 BY 1
     b-realpay AT ROW 17.52 COL 39.6 WIDGET-ID 12
     X_sysconf.fbr-pay AT ROW 18.52 COL 30.6 COLON-ALIGNED
          LABEL "производства"
          VIEW-AS FILL-IN 
          SIZE 6 BY 1
     b-fbrpay AT ROW 18.52 COL 39.6 WIDGET-ID 4
     X_sysconf.xdn-grp-code AT ROW 20.52 COL 70 COLON-ALIGNED HELP
          "" WIDGET-ID 24
          LABEL "Номер БД для копирования прав при импорте из 1С" FORMAT ">>>>>>>>9"
          VIEW-AS FILL-IN 
          SIZE 10 BY 1
     "Оплаты :" VIEW-AS TEXT
          SIZE 8.6 BY .91 AT ROW 11.52 COL 15 WIDGET-ID 2
          FGCOLOR 4 
     RECT-1 AT ROW 10.76 COL 13
     SPACE(36.99) SKIP(2.04)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Системные настройки для объекта (начальные значения)":L
         DEFAULT-BUTTON b-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Temp-Tables and Buffers:
      TABLE: X_sysconf B "?" ? ub sysconf
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-config
   FRAME-NAME                                                           */
ASSIGN 
       FRAME d-config:SCROLLABLE       = FALSE.

/* SETTINGS FOR FILL-IN X_sysconf.chk-pay IN FRAME d-config
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN X_sysconf.down-pay IN FRAME d-config
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN X_sysconf.fbr-pay IN FRAME d-config
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN X_sysconf.in-pay IN FRAME d-config
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN X_sysconf.inv-pay IN FRAME d-config
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN X_sysconf.out-pay IN FRAME d-config
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN X_sysconf.ret-pay IN FRAME d-config
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN X_sysconf.ret-sup-pay IN FRAME d-config
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN X_sysconf.xdn-grp-code IN FRAME d-config
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX d-config
/* Query rebuild information for DIALOG-BOX d-config
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX d-config */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME d-config
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-config d-config
ON GO OF FRAME d-config /* Системные настройки для объекта (начальные значения) */
DO:
assign
        X_sysconf.chk-pay
        X_sysconf.down-pay
        X_sysconf.in-pay
        X_sysconf.inv-pay
        X_sysconf.out-pay
        X_sysconf.ret-pay
        X_sysconf.ret-sup-pay
        X_sysconf.fbr-pay

        X_sysconf.out-rate
        X_sysconf.out-line-discnt
        X_sysconf.inout-price
        X_sysconf.no-eq
        X_sysconf.unit-cli-perm
        X_sysconf.in-ov
        X_sysconf.in-perm
        X_sysconf.price-calc
        X_sysconf.rsrv-time
        X_sysconf.load-time
        X_sysconf.holidays
        X_sysconf.xdn-grp-code
        .
        if v-to-c-d = yes then
        assign
        X_sysconf.all-prt = all-prt_
        X_sysconf.cd-bc-alt = cd-bc-alt_
        X_sysconf.cd-bc-base = cd-bc-base_
        X_sysconf.cd-loc-alt = cd-loc-alt_
        X_sysconf.cd-loc-base = cd-loc-base_
        X_sysconf.cd-parts-all = cd-parts-all_
        X_sysconf.cd-parts-not-blank = cd-parts-not-blank_
        X_sysconf.cd-parts-ser = cd-parts-ser_
        X_sysconf.cd-pb-alt = cd-pb-alt_
        X_sysconf.cd-pb-base = cd-pb-base_
        X_sysconf.cd-sc-base =cd-sc-base_

        .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-fbrpay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-fbrpay d-config
ON CHOOSE OF b-fbrpay IN FRAME d-config
DO:
    define variable ref-rec as character no-undo .
    define buffer buf_pay-type for ub.pay-type.
    run ref/paytype.w (input parparentproc, "b-sel", output ref-rec ).
    apply "ENTRY" to self .
    if ref-rec = "" then return no-apply.
    else do:
        FIND buf_pay-type WHERE
                 recid( buf_pay-type ) = integer(ref-rec) NO-LOCK .
        assign
        X_sysconf.fbr-pay = buf_pay-type.obj-code .
        display
        X_sysconf.fbr-pay
        with frame {&frame-name}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-inpay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-inpay d-config
ON CHOOSE OF b-inpay IN FRAME d-config
DO:
    define variable ref-rec as character no-undo .
    define buffer buf_pay-type for ub.pay-type.
    run ref/paytype.w (input parparentproc, "b-sel", output ref-rec ).
    apply "ENTRY" to self .
    if ref-rec = "" then return no-apply.
    else do:
        FIND buf_pay-type WHERE
                recid( buf_pay-type ) = integer(ref-rec) NO-LOCK .
        assign
        X_sysconf.in-pay = buf_pay-type.obj-code .
        display X_sysconf.in-pay with frame {&frame-name}.
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-invpay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-invpay d-config
ON CHOOSE OF b-invpay IN FRAME d-config
DO:
    define variable ref-rec as character no-undo .
    define buffer buf_pay-type for ub.pay-type.

    run ref/paytype.w (input parparentproc, "b-sel", output ref-rec ).
    apply "ENTRY" to self .
    if ref-rec = "" then  return no-apply.
    else do:
        FIND buf_pay-type WHERE
               recid( buf_pay-type ) = integer(ref-rec) NO-LOCK .
        assign
        X_sysconf.inv-pay = buf_pay-type.obj-code .
        display
              X_sysconf.inv-pay with frame {&frame-name}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-outpay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-outpay d-config
ON CHOOSE OF b-outpay IN FRAME d-config
DO:
    define variable ref-rec as character no-undo .
    define buffer buf_pay-type for ub.pay-type.
    run ref/paytype.w (input parparentproc, "b-sel", output ref-rec ).
    apply "ENTRY" to self .
    if ref-rec = "" then return no-apply.
    else do:
        FIND buf_pay-type WHERE
                recid( buf_pay-type ) = int(ref-rec) NO-LOCK .
        assign
        X_sysconf.out-pay = buf_pay-type.obj-code .
        display
        X_sysconf.out-pay
        with frame {&frame-name}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-realpay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-realpay d-config
ON CHOOSE OF b-realpay IN FRAME d-config
DO:
    define variable ref-rec as character no-undo .
    define buffer buf_pay-type for ub.pay-type.
    run ref/paytype.w (input parparentproc, "b-sel", output ref-rec ).
    apply "ENTRY" to self .
    if ref-rec = ? then return no-apply.
    else do:
        FIND buf_pay-type WHERE
                 recid( buf_pay-type ) = int(ref-rec) NO-LOCK .
        assign
        X_sysconf.chk-pay = buf_pay-type.obj-code .
        display
        X_sysconf.chk-pay
        with frame {&frame-name}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-retpay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-retpay d-config
ON CHOOSE OF b-retpay IN FRAME d-config
DO:
    define variable ref-rec as character no-undo .
    define buffer buf_pay-type for ub.pay-type.
    run ref/paytype.w (input parparentproc, "b-sel", output ref-rec ).
    apply "ENTRY" to self .
    if ref-rec = "" then return no-apply.
    else do:
        FIND buf_pay-type WHERE
                 recid( buf_pay-type ) = int(ref-rec) NO-LOCK .
        assign
        X_sysconf.ret-pay = buf_pay-type.obj-code .
        display
        X_sysconf.ret-pay
        with frame {&frame-name}.
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-spipay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-spipay d-config
ON CHOOSE OF b-spipay IN FRAME d-config
DO:
    define variable ref-rec as character no-undo .
    define buffer buf_pay-type for ub.pay-type.
    run ref/paytype.w (input parparentproc, "b-sel", output ref-rec ).
    apply "ENTRY" to self .
    if ref-rec = "" then return no-apply.
    else do:
        FIND buf_pay-type WHERE
                 recid( buf_pay-type ) = int(ref-rec) NO-LOCK .
        assign
        X_sysconf.down-pay = buf_pay-type.obj-code .
        display
        X_sysconf.down-pay
        with frame {&frame-name}.
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-suppay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-suppay d-config
ON CHOOSE OF b-suppay IN FRAME d-config
DO:
    define variable ref-rec as character no-undo .
    define buffer buf_pay-type for ub.pay-type.
    run ref/paytype.w (input parparentproc, "b-sel", output ref-rec ).
    apply "ENTRY" to self .
    if ref-rec = "" then return no-apply.
    else do:
        FIND buf_pay-type WHERE
                recid( buf_pay-type ) = int(ref-rec) NO-LOCK .
        assign
        X_sysconf.ret-sup-pay = buf_pay-type.obj-code .
        display
               X_sysconf.ret-sup-pay with frame {&frame-name}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-tocd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-tocd d-config
ON CHOOSE OF b-tocd IN FRAME d-config /* На кассу */
DO:
    assign
    all-prt_ = X_sysconf.all-prt
    cd-bc-alt_ = X_sysconf.cd-bc-alt
    cd-bc-base_ = X_sysconf.cd-bc-base
    cd-loc-alt_ = X_sysconf.cd-loc-alt
    cd-loc-base_ = X_sysconf.cd-loc-base
    cd-parts-all_ = X_sysconf.cd-parts-all
    cd-parts-not-blank_ = X_sysconf.cd-parts-not-blank
    cd-parts-ser_ = X_sysconf.cd-parts-ser
    cd-pb-alt_ = X_sysconf.cd-pb-alt
    cd-pb-base_ = X_sysconf.cd-pb-base
    cd-sc-base_ = X_sysconf.cd-sc-base.
    run adm/to-cd.w ( INPUT (if ibs.th.gbl.gbl-var:g#db-num = 0 then {&update} else {&lookup})
                     ,INPUT X_sysconf.host-code
                     ,INPUT {&shop}
                     ,INPUT 0
                     ,input  ("Параметры отсылки товаров на кассу по умолчанию для маг-нов фирмы " +
                                                string(X_sysconf.host-code))
                      ,INPUT-OUTPUT all-prt_
                      ,INPUT-OUTPUT cd-bc-alt_
                      ,INPUT-OUTPUT cd-bc-base_
                      ,INPUT-OUTPUT cd-loc-alt_
                      ,INPUT-OUTPUT cd-loc-base_
                      ,INPUT-OUTPUT cd-parts-all_
                      ,INPUT-OUTPUT cd-parts-not-blank_
                      ,INPUT-OUTPUT cd-parts-ser_
                      ,INPUT-OUTPUT cd-pb-alt_
                      ,INPUT-OUTPUT cd-pb-base_
                      ,INPUT-OUTPUT cd-sc-base_) .
    assign
    v-to-c-d = yes.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-config 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  /* 28/VIII-2018 не используется.   
  { gbl/getcntxt.i get }
  Внутри вызывается mainmenu_getcntxt in parparentproc.
  Какой именно экземпляр mainmenu_getcntxt вызывается - зависит от parparentproc.
  Отследить значение parparentproc по исходным текстам не представляется возможным.
  Единственная переменная, используемая в текущем модуле из getcntxt.i, это v-cntxt-db-num.
  Заменена на ibs.th.gbl.gbl-var:g#db-num - номер текщей БД 
  */
  
  find X_sysconf where X_sysconf.host-code = p-curr-host-code.
  find first buf_clients no-lock where
            buf_clients.obj-type = {&cmp}
        and buf_clients.obj-code = p-curr-host-code.
  RUN enable_UI.
  assign
  frame {&frame-name}:title = substitute("&1 для фирмы &2"
                                        , frame {&frame-name}:title
                                       , buf_clients.obj-name).
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-config  _DEFAULT-DISABLE
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
  HIDE FRAME d-config.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-config  _DEFAULT-ENABLE
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
  IF AVAILABLE X_sysconf THEN 
    DISPLAY X_sysconf.rsrv-time X_sysconf.load-time X_sysconf.holidays 
          X_sysconf.out-line-discnt X_sysconf.price-calc X_sysconf.out-rate 
          X_sysconf.no-eq X_sysconf.in-ov X_sysconf.unit-cli-perm 
          X_sysconf.inout-price X_sysconf.in-perm X_sysconf.in-pay 
          X_sysconf.out-pay X_sysconf.ret-pay X_sysconf.ret-sup-pay 
          X_sysconf.down-pay X_sysconf.inv-pay X_sysconf.chk-pay 
          X_sysconf.fbr-pay X_sysconf.xdn-grp-code 
      WITH FRAME d-config.
  ENABLE b-exit b-quit b-tocd b-help RECT-1 X_sysconf.rsrv-time 
         X_sysconf.load-time X_sysconf.holidays X_sysconf.out-line-discnt 
         X_sysconf.price-calc X_sysconf.out-rate X_sysconf.no-eq 
         X_sysconf.in-ov X_sysconf.unit-cli-perm X_sysconf.inout-price 
         X_sysconf.in-perm X_sysconf.in-pay b-inpay X_sysconf.out-pay b-outpay 
         X_sysconf.ret-pay b-retpay X_sysconf.ret-sup-pay b-suppay 
         X_sysconf.down-pay b-spipay X_sysconf.inv-pay b-invpay 
         X_sysconf.chk-pay b-realpay X_sysconf.fbr-pay b-fbrpay 
         X_sysconf.xdn-grp-code 
      WITH FRAME d-config.
  {&OPEN-BROWSERS-IN-QUERY-d-config}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Myenable d-config 
PROCEDURE Myenable :
IF AVAILABLE X_sysconf THEN
    DISPLAY X_sysconf.rsrv-time X_sysconf.load-time X_sysconf.holidays
          X_sysconf.out-line-discnt X_sysconf.price-calc X_sysconf.out-rate
          X_sysconf.no-eq X_sysconf.in-ov X_sysconf.unit-cli-perm
          X_sysconf.inout-price X_sysconf.in-perm X_sysconf.in-pay
          X_sysconf.down-pay X_sysconf.out-pay X_sysconf.inv-pay
          X_sysconf.ret-pay X_sysconf.chk-pay X_sysconf.ret-sup-pay
          X_sysconf.fbr-pay X_sysconf.xdn-grp-code
      WITH FRAME d-config.
  ENABLE b-exit b-quit b-tocd b-help X_sysconf.rsrv-time X_sysconf.load-time
         X_sysconf.holidays X_sysconf.out-line-discnt X_sysconf.price-calc
         X_sysconf.out-rate X_sysconf.no-eq X_sysconf.in-ov
         X_sysconf.unit-cli-perm X_sysconf.inout-price X_sysconf.in-perm
         X_sysconf.in-pay X_sysconf.down-pay X_sysconf.out-pay
         X_sysconf.inv-pay X_sysconf.ret-pay X_sysconf.chk-pay
         X_sysconf.ret-sup-pay X_sysconf.fbr-pay RECT-1 X_sysconf.xdn-grp-code
      WITH FRAME d-config.
IF ibs.th.gbl.gbl-var:g#db-num <> 0 THEN DO:
    HIDE
    b-exit IN FRAME {&FRAME-NAME}.
    ASSIGN
    b-quit:COLUMN = 1
    b-quit:LABEL = "&Выход".

END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

