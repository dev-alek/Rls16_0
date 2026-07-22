&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Чеки по продаже в которых цена не сопадает с ценой документа

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/26/05
Author: Bakhtadze Natalya
Creation date: 09/26/05

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode as character no-undo .
define parameter buffer ink-doc for ub.inkas.
define input parameter prcl-spl AS logical no-undo .
define input parameter v-curr-r-b AS character no-undo .


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Чеки по продаже в которых цена не сопадает с ценой документа" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ str/lib-trn.i  }
{ gbl/cur-time.i }
{ str/neg-chk.i  new }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ gbl/waitfram.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ str/trdcalib.i }

define temp-table temp-sale-price no-undo
field price-r-b like ub.gds-dtl.price-rubl
field doc-kind as character
field chr-office as character
field doc-code as character
field fact-qnty like ub.gds-dtl.fact-qnty
index pi is unique primary
doc-kind
chr-office
.

DEFINE NEW SHARED BUFFER c-doc FOR ub.chk-doc.
define var for-return as logical no-undo.
define variable glog as logical no-undo .
define variable gds-rec as recid no-undo .

def MENU m-print
    MENU-ITEM m-list LABEL "Список чеков" ACCELERATOR "ALT-1"
    MENU-ITEM m-one LABEL "Чек"  ACCELERATOR "ALT-2"
    .
define var print-type as char init "" no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-nc

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES nc

/* Definitions for BROWSE BR-nc                                         */
&Scoped-define FIELDS-IN-QUERY-BR-nc nc.b-code nc.artic nc.gds-name nc.price-r-b nc.price-chk nc.discnt nc.chk-qnty nc.fact-qnty nc.chk-code nc.cashier nc.chk-num nc.pay-desk nc.doc-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-nc
&Scoped-define SELF-NAME BR-nc
&Scoped-define QUERY-STRING-BR-nc FOR EACH nc NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-nc OPEN QUERY {&SELF-NAME} FOR EACH nc NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-nc nc
&Scoped-define FIRST-TABLE-IN-QUERY-BR-nc nc


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-nc}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-lkp b-print B-help BR-nc pr-name
&Scoped-Define DISPLAYED-OBJECTS pr-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-del
     LABEL "&Исключить"
     SIZE 10 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Выход "
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON b-print
     LABEL "Пе&чать"
     SIZE 10 BY 1.

DEFINE VARIABLE pr-name AS CHARACTER FORMAT "X(45)":U
      VIEW-AS TEXT
     SIZE 38 BY .67 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-nc FOR
      nc SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-nc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-nc Dialog-Frame _FREEFORM
  QUERY BR-nc NO-LOCK DISPLAY
      nc.b-code COLUMN-LABEL "Бар-код"
            nc.artic COLUMN-LABEL "Артикул"
            nc.gds-name FORMAT "X(30)"
            nc.price-r-b COLUMN-LABEL "Цена док-та!прайс-листа" FORMAT ">>>,>>9.99"
            nc.price-chk COLUMN-LABEL "Цена чека" FORMAT ">>>,>>9.99"
            nc.discnt COLUMN-LABEL "Скидка чека" FORMAT "->>,>>9.99"
            nc.chk-qnty COLUMN-LABEL "Кол-во в чеке"
            nc.fact-qnty COLUMN-LABEL "Кол-во док-та"
            nc.chk-code COLUMN-LABEL "Код чека" FORMAT "x(20)"
            nc.cashier COLUMN-LABEL "Кассир" FORMAT ">>9"
            nc.chk-num COLUMN-LABEL "N по кассе" FORMAT "-99999"
            nc.pay-desk
            nc.doc-code COLUMN-LABEL "Док-т"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SIZE 98 BY 11.3.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-lkp AT ROW 1 COL 11
     b-del AT ROW 1 COL 21
     b-print AT ROW 1 COL 31
     B-help AT ROW 1 COL 83
     BR-nc AT ROW 4.03 COL 1
     pr-name AT ROW 2.93 COL 10.5 NO-LABEL
     "Пр-ль" VIEW-AS TEXT
          SIZE 8.1 BY .97 AT ROW 2.83 COL 1.9
     SPACE(89.49) SKIP(12.11)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Чеки, в которых цена не равна цене док-нта/прайс-листа"
         DEFAULT-BUTTON B-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-nc B-help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON b-del IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN pr-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-nc
/* Query rebuild information for BROWSE BR-nc
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH nc NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BR-nc */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON END-ERROR OF FRAME Dialog-Frame /* Чеки, в которых цена не равна цене док-нта/прайс-листа */
DO:
  return string(for-return, "yes/no").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Чеки, в которых цена не равна цене док-нта/прайс-листа */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Исключить */
DO:
define variable glog as logical no-undo .
defINE varIABLE for-chk-code like ub.chk-doc.doc-code.
define buffer DELETE_CHK-DOC for UB.CHK-DOC.

if avail nc then do:
    FIND FIRST ub.chk-doc No-LOCK WHERE ub.chk-doc.doc-code = nc.chk-code No-ERROR.
    if not avail ub.chk-doc then do:
        message "Неправильно выбран чек." view-as alert-box ERROR.
        return no-apply.
    end.
    { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_receipts_deletion':U
    {&cntxt-object}
    ink-doc.host-code
    ink-doc.obj-type
    ink-doc.obj-code
    0
    0
    0
    true
    glog
    }


    if NOT gLog then   return no-apply.
    if chk-doc.out-code <> ? then do:
      assign
      for-chk-code = chk-doc.doc-code
      .
      DO TRANSACTION:
          FIND DELETE_chk-doc where recid (DELETE_chk-doc) = RECID(CHK-DOC).
          run str/excl-chk.p (input parparentproc,  input v-curr-r-b, buffer DELETE_chk-doc) no-error.
          IF NOT ERROR-STATUS:ERROR THEN DO:
              for each nc no-lock where nc.chk-code = for-chk-code:
                  delete nc.
              end.
          END.
      END.
      if error-status:error then do:
          message
          substitute("Исключение чека &1 из продажи &2 не удалось:&3&4 &5"
                  ,chk-doc.doc-code
                  ,chk-doc.out-code
                  , {&new-line}
                  ,error-status:get-message(1)
                  ,return-value
                  )
          view-as alert-box ERROR.
          return no-apply.
      end.
      else do:
          for-return = yes.
      end.
      RUN OpenBr.
      return no-apply.
    end.

  end.
  else do:
      message "Неправильно выбран чек." view-as alert-box ERROR.
      return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Выход  */
DO:
  return string(for-return, "yes/no").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
define variable V-DOC-REC AS RECID no-undo .
define variable next-prev as character no-undo .
IF AVAIL nc then do:
  FIND FIRST c-doc No-LOCK WHERE c-doc.doc-code = nc.chk-code No-ERROR.
  if not avail c-doc then do:
     message
     "Неправильно выбран чек."
     view-as alert-box ERROR.
     return no-apply.
  end.
  assign
  v-doc-rec = recid (c-doc)
  .
  run str/superchk.w (
                  parparentproc
                  ,input {&lookup}
                  ,input c-doc.obj-type
                  ,input c-doc.obj-code
                  ,input-output v-doc-rec
                  ,input ? /*this-procedure:handle*/
                  ,input-output next-prev
                              ) no-error

  .
end.
else do:
            message "Неправильно выбран чек." view-as alert-box ERROR.
            return no-apply.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dialog-Frame
ON CHOOSE OF b-print IN FRAME Dialog-Frame /* Печать */
DO:
def buffer s-doc for ub.trn-doc.
define variable nc-rc as recid.

   if print-type = "" then do:
       run gbl/pop-up.p (self:handle, no) no-error.
   end.
   if print-type = "list" then do:
      nc-rc = recid(nc).
      DO WHILE available nc :
            GET prev br-nc.
      END.
      run PrintProc.
      print-type = "".
      reposition br-nc to recid nc-rc no-error.
      apply "entry" to br-nc in frame {&frame-name}.
    end.
    else do:
        if avail nc then do:
        FIND FIRST c-doc No-LOCK WHERE c-doc.doc-code = nc.chk-code NO-ERROR.
        if NOT available c-doc then do:
            message "Неправильно выбран чек." view-as alert-box ERROR.
            return no-apply.
        end.
        run str/checkp.p (input parparentproc, c-doc.doc-code).
        print-type = "".
        end.
        else do:
        end.
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-nc
&Scoped-define SELF-NAME BR-nc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-nc Dialog-Frame
ON VALUE-CHANGED OF BR-nc IN FRAME Dialog-Frame
DO:
  FIND FIRST ub.clients No-LOCK WHERE ub.clients.obj-type = nc.prod-type AND
                                   ub.clients.obj-code = nc.prod-code No-ERROR.
    if avail ub.clients then do:
        pr-name = ub.clients.obj-name.
    end.
    else pr-name = "".
    display pr-name with frame {&frame-name}.
  FIND FIRST ub.goods No-LOCK WHERE ub.goods.artic = nc.artic AND
                                 ub.goods.prod-type = nc.prod-type AND
                                 ub.goods.prod-code = nc.prod-code No-ERROR.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

ASSIGN b-PRINT:POPUP-MENU IN FRAME {&frame-name} = MENU m-print:HANDLE.
ASSIGN b-print:MENU-MOUSE = 1.

/*перемещение колонок*/
{ gbl/mv-clmn.i
&browse-name = "br-nc"
&frame-name = "{&frame-name}"
&ext-col = 13
&start-column = 4}

{ gbl/brwrepos.i
  &line-num=5
}

ON choose OF MENU-ITEM m-list in menu m-print DO:
    print-type = "list".
    apply "choose" to b-print in frame {&frame-name}.
END.

ON choose OF MENU-ITEM m-one in menu m-print DO:
    print-type = "one".
    apply "choose" to b-print in frame {&frame-name}.
END.

{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  { gbl/f2.i br-nc goods-recid get-good }
  { gbl/curr-r-b.i
    v-curr-r-b
  }
  RUN fill-table IN THIS-PROCEDURE NO-ERROR.
  IF NOT CAN-FIND (FIRST nc) THEN DO:
      message
      "Не найдено чеков, по которым цена чека отличается от цены документа!"
      view-as alert-box.
      RETURN.
  END.
  RUN enable_UI.
  RUN MyEnable.
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
  DISPLAY pr-name
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-lkp b-print B-help BR-nc pr-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-table Dialog-Frame
PROCEDURE fill-table :
define buffer b-goods for ub.goods.
define buffer b-gds-dtl for ub.gds-dtl.
define variable for-price as decimal no-undo.
define variable for-qnty as decimal no-undo.
define variable for-artic like ub.goods.artic no-undo.
define variable for-prod-type like ub.goods.prod-type no-undo.
define variable for-prod-code like ub.goods.prod-code no-undo.
define variable for-node-code like ub.bar-code.node-code no-undo.
define variable for-prt-root like ub.goods.prt-root no-undo.
define variable for-gds-name like ub.goods.gds-name no-undo.
define variable for-gds-code like ub.goods.gds-code no-undo.
define variable v-doc-kind as character no-undo .
define variable v-create as logical no-undo .
define variable v-dopi as integer no-undo .
define buffer buf_chk-doc for ub.chk-doc.
DEFINE BUFFER buf-bar   FOR ub.bar-code. /*используется для поиска серийных партий*/
define buffer buf_temp-sale-price for temp-sale-price.
define buffer buf_sale-doc for ub.sale-doc.
{ str/get-pr.i def }
run waitfram-show in this-procedure ( input "Ждите...").
FOR EACH nc:
  DELETE nc.
END.
_chkgds:
FOR EACH ub.chk-gds NO-LOCK WHERE
         ub.chk-gds.out-code = ink-doc.inkas-code break by ub.chk-gds.b-code:
  IF FIRST-OF(ub.chk-gds.b-code) then do:
    for each buf_temp-sale-price :
      delete buf_temp-sale-price.
    end.
    FIND FIRST buf-bar WHERE buf-bar.b-code = ub.chk-gds.b-code NO-LOCK .
    FIND FIRST b-goods WHERE b-goods.gds-code = buf-bar.gds-code No-LOCK.
    assign
    for-gds-code = b-goods.gds-code
    for-artic = b-goods.artic
    for-prod-type = b-goods.prod-type
    for-prod-code = b-goods.prod-code
    for-node-code = buf-bar.node-code
    for-gds-name = b-goods.gds-name
    .
    if NOT (prcl-spl OR ink-doc.status_ = {&fact}) then do:
      { str/get-pr.i calc ink-doc.obj-type ink-doc.obj-code for-gds-code for-node-code "return error." }
      if error-status:error then
      assign
      gp-price-sale = 0
      for-price = 0
      .
      else
      assign
      for-price = gp-price-sale
      .
    end.
    for each buf_sale-doc where
            buf_sale-doc.inkas-code = ink-doc.inkas-code
        and buf_sale-doc.order > 0 :
      FIND FIRST b-gds-dtl WHERE
                    b-gds-dtl.doc-code = buf_sale-doc.doc-code
               AND  b-gds-dtl.artic = b-goods.artic
               AND  b-gds-dtl.prod-code = b-goods.prod-code
               AND  b-gds-dtl.prod-type = b-goods.prod-type
               AND  b-gds-dtl.prt-code = buf-bar.node-code NO-ERROR .
      IF NOT available b-gds-dtl  then NEXT _chkgds.
      create buf_temp-sale-price.
      assign
      buf_temp-sale-price.price-r-b  = (if v-curr-r-b = {&r-b-base}
                                        then b-gds-dtl.price-base
                                        else b-gds-dtl.price-rubl)
      buf_temp-sale-price.doc-kind = buf_sale-doc.doc-kind
      buf_temp-sale-price.doc-code = buf_sale-doc.doc-code
      buf_temp-sale-price.fact-qnty = b-gds-dtl.fact-qnty
      .
    end. /*            if prcl-spl then do: */
  end. /*first-of*/
  v-create = no.
  assign
  v-dopi = num-entries(chk-gds.line-type, {&delim-par})
  no-error .
  if not error-status:error
  and v-dopi = 2
  then do:
    v-doc-kind = entry(1, entry(2, chk-gds.line-type, {&delim-par})).
  end.
  else do:
    find first buf_chk-doc no-lock where
            buf_chk-doc.doc-code = chk-gds.doc-code.
    if buf_chk-doc.netto >= 0 then do:
      v-doc-kind = {&TDEDT_Ras_Vnesh_Kass}.
    end.
    else do:
      v-doc-kind = {&TDEDT_Vozvrat_Vnesh_Kass}.
    end.
  end.
  find first buf_temp-sale-price where
            buf_temp-sale-price.doc-kind = v-doc-kind
        and buf_temp-sale-price.chr-office = entry(2, chk-gds.line-type, {&delim-par}) no-error.
  if not available buf_temp-sale-price then nEXT _chkgds.
  if NOT (prcl-spl OR ink-doc.status_ = {&fact})  then do:
    if chk-gds.price-base <> for-price then v-create = yes.
  end.
  else do:
    if chk-gds.price-base <> buf_temp-sale-price.price-r-b then v-create = yes.
  end.
  if v-create then do:
    find first buf_chk-doc no-lock where
            buf_chk-doc.doc-code = chk-gds.doc-code.
    CREATE nc.
    assign
    nc.doc-code = buf_temp-sale-price.doc-code
    nc.b-code = chk-gds.b-code
    nc.artic = for-artic
    nc.prod-type = for-prod-type
    nc.prod-code = for-prod-code
    nc.prt-code = for-node-code
    nc.gds-name = for-gds-name
    nc.chk-code = buf_chk-doc.doc-code
    nc.cashier = buf_chk-doc.cashier
    nc.price-r-b = buf_temp-sale-price.price-r-b
    nc.price-chk  = chk-gds.price-base
    nc.chk-qnty = chk-gds.doc-qnty
    nc.fact-qnty = buf_temp-sale-price.fact-qnty
    nc.discnt =  chk-gds.discnt
    nc.chk-num =  buf_chk-doc.chk-num
    nc.pay-desk = buf_chk-doc.pay-desk
    .
  end. /* if v-create */
END. /*for each chk-gds*/
run waitfram-hide in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-good Dialog-Frame
PROCEDURE get-good :
DEFINE BUFFER buf_goods for ub.goods.
IF NOT AVAILABLE nc THEN gds-rec = ?.
gds-rec = ?.
FIND FIRST buf_goods NO-LOCK WHERE
          buf_goods.artic = nc.artic
   AND    buf_goods.prod-type = nc.prod-type
    AND   buf_goods.prod-code = nc.prod-code NO-ERROR.
IF AVAILABLE buf_goods THEN DO:
    gds-rec = RECID(buf_goods).
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
IF p-mode = {&update} then do:
  ENABLE b-del with frame {&frame-name}.
end.
frame {&frame-name}:title = frame {&frame-name}:title + substitute(" - отчет о продаже N &1", ink-doc.inkas-code).
APPLY "ENTRY" to br-nc.
APPLY "VALUE-CHANGED" to br-nc.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PrintProc Dialog-Frame
PROCEDURE PrintProc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable  date_string     as      char    no-undo.
define variable Line                as      char    no-undo.
define variable v-header-base-curr as character no-undo .
define variable v-base-code like ub.sysconf.base-code no-undo .
define buffer buf_inkas for ub.inkas.
define buffer buf_currency for ub.currency.
if v-curr-r-b = {&r-b-base} then do:
  find first buf_inkas no-lock where buf_inkas.inkas-code = ink-doc.inkas-code.
  { gbl/basecode.i buf_inkas.host-code v-base-code }
  find first buf_currency no-lock where
          buf_currency.curr-code = v-base-code.
  assign
  v-header-base-curr = string( "( Б.Вал. - " + caps( buf_Currency.curr-abbr ) + " )" )
  .
end.


DEFINE FRAME Chk-List
nc.b-code COLUMN-LABEL "Бар-код"
nc.artic COLUMN-LABEL "Артикул"
nc.gds-name FORMAT "X(30)"
nc.price-r-b COLUMN-LABEL "Цена док-та" FORMAT ">>>,>>9.99"
nc.price-chk COLUMN-LABEL "Цена чека" FORMAT ">>>,>>9.99"
nc.discnt COLUMN-LABEL "Скидка чека" FORMAT "->>,>>9.99"
nc.chk-qnty COLUMN-LABEL "Кол-во в чеке"
nc.fact-qnty COLUMN-LABEL "Кол-во док-та"
nc.chk-code COLUMN-LABEL "Код чека" FORMAT "x(20)"
nc.cashier COLUMN-LABEL "Кассир" FORMAT ">>9"
nc.chk-num COLUMN-LABEL "N по кассе" FORMAT "-99999"
nc.pay-desk
nc.doc-code COLUMN-LABEL "Док-т"
HEADER  date_string AT 5 format "X(35)"
v-header-base-curr        format "X(20)" AT 42
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
Line format "X(177)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

Line = fill("-", 177).
date_string = cur-time-print() .

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).

PUT  STREAM PrnLibStream
SPACE(25) ( frame {&frame-name}:title )
format "x(90)" SKIP(1) .
FORM HEADER
        Line format "X(177)" AT 1 SKIP
        "Продолжение - на следующей странице" AT 30 SKIP
        with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .

FORM with FRAME Chk-List  .
run waitfram-show in this-procedure ("Ждите...").
GET next br-nc.
DO WHILE available nc :
  Display STREAM PrnLibStream
  nc.b-code
  nc.artic
  nc.gds-name
  nc.price-r-b
  nc.price-chk
  nc.discnt
  nc.chk-qnty
  nc.fact-qnty
  nc.chk-code
  nc.cashier
  nc.chk-num
  nc.pay-desk
  nc.doc-code
  with FRAME Chk-List .
  DOWN STREAM PrnLibStream 1 with FRAME CHk-List  .
  GET next br-nc.
END.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME CheckList.
output  STREAM PrnLibStream CLOSE.
/*
       assign
             g#rep-tblname = ""
             g#rep-tblrid = -117
             g#rep-updflds = string( "Список чеков|" ) .
*/
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME