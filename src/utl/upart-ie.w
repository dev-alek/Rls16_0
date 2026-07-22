&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_goods FOR goods.
DEFINE TEMP-TABLE x_parts LIKE parts.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список партий внешнего прихода для корректировки задним числом

Автор: Чернова Светлана Александровна
Дата создания: 08/22/07
Author: Svetlana Chernova
Creation date: 08/22/07

*/
/*------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

define input  parameter parparentproc       as widget-handle no-undo.
define input  parameter p-recid             as recid no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список партий внешнего прихода для корректировки задним числом".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }

/* Local Variable Definitions ---                                       */
define buffer buf_trn-doc for ub.trn-doc  .
define buffer buf_parts   for ub.parts  .
define variable p-p-recid as recid no-undo .
define variable gds-rec as recid no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-2

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES x_parts buf_goods

/* Definitions for BROWSE BROWSE-2                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-2 x_parts.artic buf_goods.gds-name ~
x_parts.cli-qnty x_parts.price-cli x_parts.qnty x_parts.price-rubl ~
x_parts.VAT-pc x_parts.pl-code x_parts.pay-code x_parts.part-code ~
x_parts.in-code x_parts.fact-date
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-2
&Scoped-define QUERY-STRING-BROWSE-2 FOR EACH x_parts NO-LOCK, ~
      EACH buf_goods OF x_parts NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-2 OPEN QUERY BROWSE-2 FOR EACH x_parts NO-LOCK, ~
      EACH buf_goods OF x_parts NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-2 x_parts buf_goods
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-2 x_parts
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-2 buf_goods


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-2}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS BROWSE-2 B-Cancel B-exit i-exit B-Help B-chg ~
B-lkp B-lkp-In

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Cancel AUTO-END-KEY
     LABEL "Вы&ход"
     SIZE 10 BY 1 TOOLTIP "Выход без изменений"
     BGCOLOR 8 .

DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1 TOOLTIP "Изменить партию товара"
     BGCOLOR 8 .

DEFINE BUTTON B-exit AUTO-GO
     LABEL "_ Выполнить"
     SIZE 13 BY 1 TOOLTIP "Запустить пересчет"
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "&Help"
     SIZE 3.5 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON B-lkp
     LABEL "&Просмотр Исх"
     SIZE 13 BY 1 TOOLTIP "Посмотреть исходную партию товара"
     BGCOLOR 8 .

DEFINE BUTTON B-lkp-In
     LABEL "&ПН"
     SIZE 10 BY 1 TOOLTIP "Просмотр приходной накладной"
     BGCOLOR 8 .

DEFINE BUTTON i-exit
     IMAGE-UP FILE "cmp/i-run.bmp":U
     IMAGE-DOWN FILE "cmp/i-run.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/i-rund.bmp":U
     LABEL ""
     SIZE 2.5 BY .75.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-2 FOR
      x_parts,
      buf_goods SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-2 Dialog-Frame _STRUCTURED
  QUERY BROWSE-2 NO-LOCK DISPLAY
      x_parts.artic FORMAT "X(16)":U
      buf_goods.gds-name FORMAT "X(40)":U
      x_parts.cli-qnty FORMAT "->>,>>>,>>9.999":U
      x_parts.price-cli FORMAT "->>,>>>,>>>,>>9.999":U
      x_parts.qnty FORMAT "->>,>>>,>>9.999":U
      x_parts.price-rubl FORMAT "->>,>>>,>>9.99":U
      x_parts.VAT-pc FORMAT ">9.9<%":U
      x_parts.pl-code FORMAT "999999999":U
      x_parts.pay-code FORMAT "99999":U
      x_parts.part-code FORMAT "X(20)":U
      x_parts.in-code FORMAT "X(14)":U
      x_parts.fact-date FORMAT "99/99/99":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 95.5 BY 16.79 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     BROWSE-2 AT ROW 3.67 COL 1.5 WIDGET-ID 200
     B-Cancel AT ROW 1 COL 1
     B-exit AT ROW 1 COL 11
     i-exit AT ROW 1.13 COL 11.25 WIDGET-ID 4
     B-Help AT ROW 1 COL 94.5
     B-chg AT ROW 2.63 COL 1.5 WIDGET-ID 2
     B-lkp AT ROW 2.63 COL 11.63 WIDGET-ID 6
     B-lkp-In AT ROW 2.63 COL 24.75 WIDGET-ID 8
     SPACE(66.25) SKIP(19.03)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Корректировка партий внешнего прихода закрытого на факт"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-Cancel WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_goods B "?" ? ub goods
      TABLE: x_parts T "?" ? ub parts
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME Custom                                                    */
/* BROWSE-TAB BROWSE-2 1 Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-2
/* Query rebuild information for BROWSE BROWSE-2
     _TblList          = "Temp-Tables.x_parts,buf_goods OF Temp-Tables.x_parts"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   = Temp-Tables.x_parts.artic
     _FldNameList[2]   > Temp-Tables.buf_goods.gds-name
"buf_goods.gds-name" ? "X(40)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   = Temp-Tables.x_parts.cli-qnty
     _FldNameList[4]   = Temp-Tables.x_parts.price-cli
     _FldNameList[5]   = Temp-Tables.x_parts.qnty
     _FldNameList[6]   = Temp-Tables.x_parts.price-rubl
     _FldNameList[7]   = Temp-Tables.x_parts.VAT-pc
     _FldNameList[8]   = Temp-Tables.x_parts.pl-code
     _FldNameList[9]   = Temp-Tables.x_parts.pay-code
     _FldNameList[10]   = Temp-Tables.x_parts.part-code
     _FldNameList[11]   = Temp-Tables.x_parts.in-code
     _FldNameList[12]   = Temp-Tables.x_parts.fact-date
     _Query            is OPENED
*/  /* BROWSE BROWSE-2 */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Корректировка партий внешнего прихода закрытого на факт */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-Cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-Cancel Dialog-Frame
ON CHOOSE OF B-Cancel IN FRAME Dialog-Frame /* Выход */
DO:
  /**/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
if not available x_parts then return .
define buffer buf_goods for ub.goods  .

find first buf_goods no-lock
  where buf_goods.artic     = x_parts.artic
    and buf_goods.prod-type = x_parts.prod-type
    and buf_goods.prod-code = x_parts.prod-code
  no-error .
    if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      ""
      view-as alert-box error
    .
    return .
    end.
    /* проверяем целостность товара */
    { gbl/gdscheck.i
      x_parts.obj-type
      x_parts.obj-code
      x_parts.artic
      x_parts.prod-type
      x_parts.prod-code
      ?
      "'return':u"
      no-error
    }
    if error-status :error
    then do:
      message
         return-value
         view-as alert-box error .
      return .
    end.

   run utl/uparts-f.w
    ( input parparentproc ,
      input this-procedure ,
      input buf_trn-doc.doc-code ,
      input buf_goods.gds-code ,
      input x_parts.pl-code    ,
      input x_parts.in-code    ,
      input x_parts.part-code  ,
      input x_parts.out-code  ,
      input-output table x_parts ) no-error .
      if error-status :error then message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "utl/uparts-f.w"
        view-as alert-box error
      .
    run reopen-query in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* _ Выполнить */
DO:
define variable v-ok as logical   no-undo .
  message "Запускать утилиту пересчета внешнего прихода № " buf_trn-doc.doc-code skip
  "Вы уверены ?"
  view-as alert-box question
  buttons yes-no
  title "Вопрос"
  update v-ok .
  if v-ok = false then  return no-apply .
  else do:
    run utl/trnfactb.p
        ( input parParentProc ,
          input buf_trn-doc.doc-code ,
          input table x_parts ) no-error .
          if error-status :error then message
            vss-workfile vss-revision vss-description skip
            error-status :get-message(1) skip
            return-value skip
            "utl/trnfactb.p"
            view-as alert-box error
          .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lkp Dialog-Frame
ON CHOOSE OF B-lkp IN FRAME Dialog-Frame /* Просмотр Исх */
DO:
if not available x_parts then return .
define buffer buf_goods for ub.goods  .
define variable v-prt-rec as recid no-undo .

find first buf_goods no-lock
  where buf_goods.artic     = x_parts.artic
    and buf_goods.prod-type = x_parts.prod-type
    and buf_goods.prod-code = x_parts.prod-code
  no-error .
    if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      ""
      view-as alert-box error
    .
    return .
    end.

    define buffer old-parts for ub.parts  .
    find first old-parts no-lock where
               old-parts.out-code = buf_trn-doc.doc-code and
               old-parts.obj-type = buf_trn-doc.obj-type and
               old-parts.obj-code = buf_trn-doc.obj-code and
               old-parts.artic      = x_parts.artic and
               old-parts.prod-type  = x_parts.prod-type and
               old-parts.prod-code  = x_parts.prod-code and
               old-parts.in-code    = x_parts.in-code  no-error .
    if available old-parts then do:
        v-prt-rec = recid(old-parts) .
        run str/parts-f.w
          (input        parparentproc  /* parparentproc    */
          ,input        this-procedure /* h-call-prog      */
          ,input        {&lookup}      /* p-mode           */
          ,input        buf_trn-doc.doc-code     /* p-doc-code       */
          ,input        buf_goods.gds-code     /* p-gds-code       */
          ,input        x_parts.pl-code      /* p-pl-code        */
          ,input-output v-prt-rec      /* p-parts-recid    */
          ).
     end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lkp-In
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lkp-In Dialog-Frame
ON CHOOSE OF B-lkp-In IN FRAME Dialog-Frame /* ПН */
DO:
if not available x_parts then return .
    run str/showdoc.p
    ( input parparentproc
     ,input x_parts.in-code
     ,input ?
     ,input ?
     ,input ?
     ,input true
    ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-2
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ gbl/f2.i {&browse-name} goods-recid goods-recid parparentproc  }
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  run init-proc.
  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE data-changed Dialog-Frame
PROCEDURE data-changed :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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
  ENABLE BROWSE-2 B-Cancel B-exit i-exit B-Help B-chg B-lkp B-lkp-In
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-attr-chg-qnty Dialog-Frame
PROCEDURE get-attr-chg-qnty :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define output parameter p-chg-qnty as decimal   no-undo .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE goods-recid Dialog-Frame
PROCEDURE goods-recid :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
if available buf_goods then gds-rec = recid (buf_goods) .
else gds-rec = ?.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-proc Dialog-Frame
PROCEDURE init-proc :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

find first buf_trn-doc exclusive-lock where
        recid (buf_trn-doc) = p-recid
        no-error .
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

frame {&frame-name}:title  = frame {&frame-name}:title + ' ' + buf_trn-doc.doc-code .

for each buf_parts no-lock where
         buf_parts.out-code = buf_trn-doc.doc-code
:
    create x_parts.
    buffer-copy buf_parts to x_parts .
end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reopen-query Dialog-Frame
PROCEDURE reopen-query :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
{&OPEN-QUERY-BROWSE-2}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-parts Dialog-Frame
PROCEDURE reposition-parts :
define input  parameter p-direction   as character no-undo .
define output parameter p-parts-recid as recid no-undo .

  /* перемещение на первую, последнюю, предыдущую, следующую
     или на определенную запись по recid
   */
  case p-direction :
    when "first":U
    then do:
      get first {&browse-name} .
    end.
    when "last":U
    then do:
      get last {&browse-name} .
    end.
    when "prev":U
    then do:
      get prev {&browse-name} .
    end.
    when "next":U
    then do:
      get next {&browse-name} .
    end.
    otherwise do:
      reposition {&browse-name}  to recid integer(p-direction) no-error .
    end.
  end case . /* p-direction */

  assign
    p-parts-recid = recid(x_parts)
  .
  run reposition-query in this-procedure
    (input p-parts-recid
    ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-query Dialog-Frame
PROCEDURE reposition-query :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define input parameter p-recid as recid no-undo .

  if p-recid <> ?
  then do:
    reposition {&browse-name} to recid p-recid no-error.
  end.

  do with frame {&frame-name}:
    apply "entry":u to browse {&browse-name} .
  end. /* do with frame */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
