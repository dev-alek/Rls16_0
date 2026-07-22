&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
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

Оборотная ведомость отчет по одному товару (из справочника товаров)

Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

*/

define  input  parameter parParentProc  as widget-handle no-undo.
define  input parameter  xartic      like   goods.artic    no-undo .
define  input parameter  xprod-type  like   goods.prod-type no-undo .
define  input parameter  xprod-code  like   goods.prod-code no-undo  .
define  input parameter  xstart-date as date no-undo .
define  input parameter  xend-date   as date no-undo .
define  input parameter  xobj-type   like ub.clients.obj-type no-undo .
define  input parameter  xobj-code   like ub.clients.obj-code no-undo .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Оборотная ведомость отчет по одному товару (из справочника товаров)".
{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/showinf.i     }
{ cmp/r-page1.i new }
{ cmp/library.i     }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
define variable v-archive-ok as logical   no-undo .
define variable v-comment    as character no-undo .
define variable v-can-print  as logical   no-undo .
define variable v-today      as date      no-undo .
my-handle =  parParentProc .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn-Cancel Btn_OK B-Help RECT-1 date-1 ~
date-2 TOG-inv
&Scoped-Define DISPLAYED-OBJECTS date-1 date-2 TOG-inv

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn-Cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "Печать"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE date-1 AS DATE FORMAT "99/99/9999":U
     LABEL "   с"
     VIEW-AS FILL-IN
     SIZE 13.75 BY 1 NO-UNDO.

DEFINE VARIABLE date-2 AS DATE FORMAT "99/99/9999":U
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 13.75 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 48.38 BY 4.5.

DEFINE VARIABLE TOG-inv AS LOGICAL INITIAL no
     LABEL "с последней инвентаризации"
     VIEW-AS TOGGLE-BOX
     SIZE 28.88 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn-Cancel AT ROW 1.25 COL 1.63
     Btn_OK AT ROW 1.25 COL 11.63
     B-Help AT ROW 1.25 COL 40.38
     date-1 AT ROW 2.79 COL 10 COLON-ALIGNED
     date-2 AT ROW 4 COL 9.88 COLON-ALIGNED
     TOG-inv AT ROW 5.38 COL 8
     RECT-1 AT ROW 2.46 COL 1.63
     SPACE(0.73) SKIP(0.36)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Печать списка документов"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn-Cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Печать списка документов */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK Dialog-Frame
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame /* Печать */
DO:
DEFINE VARIABLE v-host-code like ub.sysconf.host-code no-undo .

def buffer goods1 for goods .
define buffer buf_shop for ub.shop.
define buffer buf_store for ub.store.
define buffer buf_sysconf for ub.sysconf.
define buffer buf_currency for ub.currency.

/*строки в которых содержатся выбранные объекты */

assign frame {&frame-name}  date-1 date-2 tog-inv .

  for each gds-list share-lock:
     delete gds-list.
  End.
   find goods1 where
   goods1.artic     = xartic And
   goods1.prod-type = xprod-type And
   goods1.prod-code = xprod-code
     no-lock no-error.
    if available goods1 then DO:
        create gds-list.
        BUFFER-copy goods1 TO gds-list no-error.
    End.
  for each obj-list share-lock:
     delete obj-list.
  End.

  { cmp/cr-objls.i xobj-type xobj-code }

ReportNAme = "О Т Ч Е Т   О   С О С Т О Я Н И И   З А П А С А   И   П Р О Д А Ж А Х   ( по одному товару)".
 ReportHeader = ReportHeader  + {&new-line} + goods1.gds-name .
 Assign
  x-SET_val_TYPE = 1
  x-Date-Start = date-1
  x-Date-end   = date-2   .
if tog-inv then do:
  assign
    ReportHeader = ReportHeader + {&new-line} + " с момента последней инвентаризации "
  .
end.
  { gbl/curobjdt.i xobj-type xobj-code v-today }
      run rep/chk-ahz.p
        (input        xobj-type      /* p-obj-type          */
        ,input        xobj-code      /* p-obj-code          */
        ,input        yes            /* p-verify-detail     */
        ,input        yes            /* p-verify-arh        */
        ,input        no             /* p-verify-ahsp       */
        ,input        no             /* p-verify-aht        */
        ,input        yes            /* p-check-act         */
        ,input        v-cntxt-db-num /* p-check-act-db-num  */
        ,input        v-cntxt-userid /* p-check-act-user-id */
        ,input-output v-today        /* p-date-start        */
        ,input-output v-today        /* p-date-end          */
        ,output       v-archive-ok   /* p-archive-ok        */
        ,output       v-comment      /* p-comment           */
        ,output       v-can-print    /* p-can-print         */
        ) .
      if v-archive-ok = false
      then do:
        if v-can-print = true
        then do:
          define variable v-choice as logical   no-undo .
          message
            "ВНИМАНИЕ!" skip
            v-comment skip
            "" skip
            "Продолжить формирование отчета ?" skip
            view-as alert-box question buttons yes-no update v-choice .
          if v-choice = false
          then do:
            return . /* --->>>--- */
          end.
        end.
        else do:
          message
            "ВНИМАНИЕ !!!" skip
            "Отчет не может быть сформирован!" skip
            "На запрошенную дату нет архивов или они сжаты" skip
            v-comment skip
            view-as alert-box information .
          return . /* --->>>--- */
        end.
      End.


      CASE xobj-type:
        when {&shop} then do:
          find first buf_shop no-lock where
                    buf_shop.obj-code = xobj-code.
          assign
          v-host-code = buf_shop.host-code
          .
        end.
        when {&stock} then do:
          find first buf_store no-lock where
                    buf_store.obj-code = xobj-code.
          assign
          v-host-code = buf_store.host-code
          .
        end.
      END CASE.
      find first buf_sysconf no-lock where
             buf_sysconf.host-code = v-host-code.
      find first buf_currency no-lock where
                 buf_currency.curr-code = buf_sysconf.base-code .
      run rep/r-o-good.p   (input xobj-code ,
                        input xobj-type ,
                        input buf_currency.curr-abbr,
                        input buf_sysconf.base-code  ,
                        input {&all} ,
                        input tog-inv,
                        input "no-classify":U,
                        input "sort-article":U ,
                        input /*"all,no":U*/ "" ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */
{ gbl/app_help.i }
{ gbl/curobjdt.i v-cntxt-obj-type v-cntxt-obj-code v-today }
if xstart-date = ? or xend-date = ? then do:
  assign
      date-1 = v-today - 7
      date-2 = v-today
  .
end.
else do:
  assign
    date-1 = xstart-date
    date-2 = xend-date
    .
end.
{ gbl/ed_date.i date-1 }
{ gbl/ed_date.i date-2 }


/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
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
  DISPLAY date-1 date-2 TOG-inv
      WITH FRAME Dialog-Frame.
  ENABLE Btn-Cancel Btn_OK B-Help RECT-1 date-1 date-2 TOG-inv
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME