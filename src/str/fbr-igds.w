&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-fbr-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-fbr-gds
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр документа производства по товарам

Автор: Белоусов Илья Александрович
Дата создания: 09/09/05
Author: Ilia Belousov
Creation date: 09/09/05

Input:

Output:

*/
/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-fbr-doc-recid      as recid            no-undo.
define input-output parameter p-goods-recid as recid            no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр документа производства по товарам".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/doc-code.i }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }

define temp-table temp_fbr-gds no-undo
  field artic           like fbr-line.artic
  field prod-type       like fbr-line.prod-type
  field prod-code       like fbr-line.prod-code
  field price-rubl      like fbr-line.price-rubl
  field sum-rubl        like fbr-line.price-rubl
  field sum-vat-rubl    like fbr-line.price-rubl
  field in-qnty         like fbr-line.fact-qnty
  field out-qnty        like fbr-line.fact-qnty
  field in-exp          like doc-line.fact-qnty
  field out-exp         like doc-line.fact-qnty
  field in-trn          like doc-line.fact-qnty
  field out-trn         like doc-line.fact-qnty
  field qnty-mark       as char format "xx"
  field order-num       as integer
  field delta_value     as decimal
  field delta_sum       as decimal
  field delta_sum_vat   as decimal
  index pi is unique primary artic prod-type prod-code
.

define variable v-doc-code      as character    no-undo.
define variable gds-rec         as recid        no-undo.

def buffer flt-gds for goods.       /* для режима ТОВАР */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME d-fbr-gds
&Scoped-define BROWSE-NAME br-fbr-gds

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp_fbr-gds goods

/* Definitions for BROWSE br-fbr-gds                                    */
&Scoped-define FIELDS-IN-QUERY-br-fbr-gds temp_fbr-gds.qnty-mark goods.artic goods.gds-name temp_fbr-gds.in-qnty temp_fbr-gds.out-qnty (if (temp_fbr-gds.out-qnty - temp_fbr-gds.in-qnty) > 0 then (temp_fbr-gds.out-qnty - temp_fbr-gds.in-qnty) else 0) (if (temp_fbr-gds.out-qnty - temp_fbr-gds.in-qnty) < 0 then (temp_fbr-gds.in-qnty - temp_fbr-gds.out-qnty) else 0) temp_fbr-gds.out-trn temp_fbr-gds.in-trn
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-fbr-gds
&Scoped-define FIELD-PAIRS-IN-QUERY-br-fbr-gds
&Scoped-define SELF-NAME br-fbr-gds
&Scoped-define OPEN-QUERY-br-fbr-gds OPEN QUERY {&SELF-NAME} FOR EACH temp_fbr-gds no-lock, ~
                                   each goods of temp_fbr-gds no-lock                             by temp_fbr-gds.order-num by temp_fbr-gds.artic.
&Scoped-define TABLES-IN-QUERY-br-fbr-gds temp_fbr-gds goods
&Scoped-define FIRST-TABLE-IN-QUERY-br-fbr-gds temp_fbr-gds


/* Definitions for DIALOG-BOX d-fbr-gds                                 */
&Scoped-define OPEN-BROWSERS-IN-QUERY-d-fbr-gds ~
    ~{&OPEN-QUERY-br-fbr-gds}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-sel b-help br-fbr-gds

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-END-KEY
     LABEL "&Выход "
     SIZE 15 BY 1.13 TOOLTIP "Выход из просмотра документа производства по товарам"
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 15 BY 1.13 TOOLTIP "Помощь"
     BGCOLOR 8 .

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор "
     SIZE 15 BY 1.13 TOOLTIP "Выбор товара для просмотра документа в режиме ТОВАР"
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-fbr-gds FOR
      temp_fbr-gds,
      goods SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-fbr-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-fbr-gds d-fbr-gds _FREEFORM
  QUERY br-fbr-gds DISPLAY
temp_fbr-gds.qnty-mark column-label "<>"
goods.artic
goods.gds-name   format "x(30)"
/*temp_fbr-gds.in-qnty      format ">,>>>,>>>.<<<"    column-label "Произве-!дено"*/
/*temp_fbr-gds.out-qnty     format ">,>>>,>>>.<<<"    column-label "Исполь-!зовано"*/
temp_fbr-gds.in-qnty      format ">>>,>>9.999999"   column-label "Произведено"
temp_fbr-gds.out-qnty     format ">>>,>>9.999999"   column-label "Использовано"
temp_fbr-gds.in-exp       format ">,>>>,>>>.<<<"    column-label "Ожидается!Приход"
temp_fbr-gds.out-exp      format ">,>>>,>>>.<<<"    column-label "Требуется!списать"
temp_fbr-gds.in-trn       format ">,>>>,>>>.<<<"    column-label "Приход!по ПН"
temp_fbr-gds.out-trn      format ">,>>>,>>>.<<<"    column-label "Списано!по НС"
temp_fbr-gds.delta_value  format "->>>,>>9.999999"  column-label "Разница!кол-во"
temp_fbr-gds.delta_sum    format "->,>>9.99999999"  column-label "Разница учет.!цен c НДС"

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 95.63 BY 19.25.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-fbr-gds
     b-exit AT ROW 1.5 COL 2
     b-sel AT ROW 1.5 COL 20
     b-help AT ROW 1.5 COL 81
     br-fbr-gds AT ROW 2.88 COL 2
     SPACE(1.24) SKIP(0.28)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "<insert dialog title>"
         DEFAULT-BUTTON b-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-fbr-gds
                                                                        */
/* BROWSE-TAB br-fbr-gds b-help d-fbr-gds */
ASSIGN
       FRAME d-fbr-gds:SCROLLABLE       = FALSE
       FRAME d-fbr-gds:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-fbr-gds
/* Query rebuild information for BROWSE br-fbr-gds
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp_fbr-gds no-lock,
                            each goods of temp_fbr-gds no-lock
                            by temp_fbr-gds.order-num by temp_fbr-gds.artic.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-fbr-gds */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX d-fbr-gds
/* Query rebuild information for DIALOG-BOX d-fbr-gds
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX d-fbr-gds */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME d-fbr-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-fbr-gds d-fbr-gds
ON WINDOW-CLOSE OF FRAME d-fbr-gds /* <insert dialog title> */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel d-fbr-gds
ON CHOOSE OF b-sel IN FRAME d-fbr-gds /* Выбор  */
DO:
p-goods-recid = recid (goods).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-fbr-gds
&Scoped-define SELF-NAME br-fbr-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-fbr-gds d-fbr-gds
ON MOUSE-SELECT-DBLCLICK OF br-fbr-gds IN FRAME d-fbr-gds
DO:
apply "choose" to b-sel in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-fbr-gds d-fbr-gds
ON RETURN OF br-fbr-gds IN FRAME d-fbr-gds
DO:
apply "choose" to b-sel in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-fbr-gds


/* ***************************  Main Block  *************************** */
/*{ gbl/f2gds.i br-fbr-gds get-current-goods-recid p-mainmenu-handle }*/
{ gbl/f2.i {&browse-name} "goods-recid" "get-current-goods-recid" p-mainmenu-handle  }

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
{ gbl/working.i }
run fbr-igds-fill-fbr-gds in this-procedure (
      input p-fbr-doc-recid
    , output v-doc-code
) no-error.
if error-status :error
then do:
    message
         vss-workfile vss-revision vss-description
    skip "Ошибка заполнения списка товаров"
    skip return-value
    skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
    view-as alert-box error.
    undo, return error .
end.
{ gbl/getcntxt.i get " " p-mainmenu-handle }
{ gbl/stopwork.i }
RUN enable_UI.
frame {&frame-name}:title = "Информация по товарам. Документ № " + v-doc-code.
find flt-gds where recid (flt-gds) = p-goods-recid no-lock no-error.
if available flt-gds then do:
  /* пытаемся сделать reposition */
    find first temp_fbr-gds no-lock
         where temp_fbr-gds.artic     = flt-gds.artic
           and temp_fbr-gds.prod-type = flt-gds.prod-type
           and temp_fbr-gds.prod-code = flt-gds.prod-code
    no-error.
  if available temp_fbr-gds then
    reposition br-fbr-gds to recid recid (temp_fbr-gds) no-error.
end.
p-goods-recid = ?.
apply "entry" to br-fbr-gds.
WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-fbr-gds _DEFAULT-DISABLE
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
  HIDE FRAME d-fbr-gds.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-fbr-gds _DEFAULT-ENABLE
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
  ENABLE b-exit b-sel b-help br-fbr-gds
      WITH FRAME d-fbr-gds.
  VIEW FRAME d-fbr-gds.
  {&OPEN-BROWSERS-IN-QUERY-d-fbr-gds}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fbr-igds-fill-fbr-gds {&FRAME-NAME}
PROCEDURE fbr-igds-fill-fbr-gds :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input  parameter p-fbr-doc-recid as recid        no-undo .
define output parameter p-doc-code      as character    no-undo .

    define variable serv-code like trn-doc.doc-code no-undo .
    define variable in-code   like trn-doc.doc-code no-undo .
    define variable out-code  like trn-doc.doc-code no-undo .

    define variable par-fbr-ooff as char no-undo .                       /* для чтения параметра конфигурации */
    define variable par-type     as char no-undo .                       /* тип параметра конфигурации */
    define variable list-marks   as char init ">>,<<,.,=,>,<" no-undo .  /* значение по умолчанию, можно через настройки */
    define variable list-orders  as char init "5,4,6,3,2,1"   no-undo .  /* значение по умолчанию, можно через настройки */

    define buffer buf_fbr-doc      for fbr-doc .
    define buffer buf_fbr-line     for fbr-line .
    define buffer buf_goods        for goods .
    define buffer buf_doc-line     for doc-line .
    define buffer buf_temp_fbr-gds for temp_fbr-gds .
do
for buf_fbr-doc
  , buf_fbr-line
  , buf_goods
  , buf_doc-line
  , buf_temp_fbr-gds
on error undo, return error
:
    find first buf_fbr-doc no-lock
         where recid (buf_fbr-doc) = p-fbr-doc-recid
    .
    assign
        p-doc-code = buf_fbr-doc.doc-code
    .
    run gbl/conf-rd.p (
          input "fbr-ooff"
        , input 0
        , input ""
        , input 0
        , input ""
        , input ""
        , input ""
        , input no
        , output par-fbr-ooff
        , output par-type
    ) no-error.
    for each buf_fbr-line no-lock
       where buf_fbr-line.doc-code = buf_fbr-doc.doc-code
    on error undo, return error return-value
    :
        find first buf_temp_fbr-gds
             where buf_temp_fbr-gds.artic     = buf_fbr-line.artic
               and buf_temp_fbr-gds.prod-type = buf_fbr-line.prod-type
               and buf_temp_fbr-gds.prod-code = buf_fbr-line.prod-code
        no-error.
        if not available buf_temp_fbr-gds
        then do:
            create buf_temp_fbr-gds.
            assign
                buf_temp_fbr-gds.artic        = buf_fbr-line.artic
                buf_temp_fbr-gds.prod-type    = buf_fbr-line.prod-type
                buf_temp_fbr-gds.prod-code    = buf_fbr-line.prod-code
                buf_temp_fbr-gds.price-rubl   = buf_fbr-line.price-rubl
                buf_temp_fbr-gds.sum-rubl     = buf_fbr-line.price-sum-rubl
                buf_temp_fbr-gds.sum-vat-rubl = buf_fbr-line.price-sum-vat-rubl
            .
        end.
        if buf_fbr-line.trn-type = {&income}
        then do:
            assign
                buf_temp_fbr-gds.in-qnty = buf_temp_fbr-gds.in-qnty + buf_fbr-line.fact-qnty
            .
            if not buf_fbr-line.rsrv-qnty = ?
            then do:        /* не отходы */
                assign
                    buf_temp_fbr-gds.in-exp = buf_temp_fbr-gds.in-exp + buf_fbr-line.fact-qnty
                .
            end.
        end.
        else do:
            assign
                buf_temp_fbr-gds.out-qnty = buf_temp_fbr-gds.out-qnty + buf_fbr-line.fact-qnty
            .
            if buf_fbr-line.rsrv-qnty <> ?
            then do:        /* не отходы */
                assign
                    buf_temp_fbr-gds.out-exp = buf_temp_fbr-gds.out-exp + buf_fbr-line.fact-qnty
                .
            end.
        end.
        /* todo изменить алгоритм заполнения переменной qnty-mark */
        /* использовать вспомогательную целую переменную */
        assign
            buf_temp_fbr-gds.qnty-mark =
            (if buf_temp_fbr-gds.in-qnty  > 0 and buf_temp_fbr-gds.out-qnty = 0 then ">>" else
            if buf_temp_fbr-gds.out-qnty > 0 and buf_temp_fbr-gds.in-qnty = 0  then "<<" else
            if buf_temp_fbr-gds.in-qnty  = 0 and buf_temp_fbr-gds.out-qnty = 0 then "." else
            if buf_temp_fbr-gds.in-qnty  = buf_temp_fbr-gds.out-qnty           then "=" else
            if buf_temp_fbr-gds.in-qnty  > buf_temp_fbr-gds.out-qnty           then ">" else "<")
            list-marks = ">>,<<,.,=,>,<"
            buf_temp_fbr-gds.order-num = integer (entry (lookup (buf_temp_fbr-gds.qnty-mark, list-marks), list-orders))
        .
        if par-fbr-ooff <> "yes"
        then do:        /* оптимизация ингридиентов включена */
            if buf_temp_fbr-gds.in-exp > buf_temp_fbr-gds.out-exp
            then do:
                assign
                    buf_temp_fbr-gds.in-exp = buf_temp_fbr-gds.in-exp - buf_temp_fbr-gds.out-exp
                    buf_temp_fbr-gds.out-exp = 0
                .
            end.
            else do:
                assign
                    buf_temp_fbr-gds.out-exp = buf_temp_fbr-gds.out-exp - buf_temp_fbr-gds.in-exp
                    buf_temp_fbr-gds.in-exp = 0
                .
            end.
        end.
    end.
    assign
        out-code = buf_fbr-doc.doc-code
    .
    run doc-code in this-procedure (
          input "pair":U
        , input v-cntxt-obj-type
        , input v-cntxt-obj-code
        , input out-code
        , output in-code
    ) no-error.
    if error-status:error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip "Ошибка при генерации номера приходной накладной."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    run doc-code in this-procedure (
          input "trio":U
        , input v-cntxt-obj-type
        , input v-cntxt-obj-code
        , input in-code
        , output serv-code
    ) no-error.
    if error-status:error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip "Ошибка при генерации номера накладной расхода."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    for each buf_temp_fbr-gds no-lock
    on error undo, return error return-value
    :
        find first buf_goods no-lock
             where buf_goods.artic     = buf_temp_fbr-gds.artic
               and buf_goods.prod-type = buf_temp_fbr-gds.prod-type
               and buf_goods.prod-code = buf_temp_fbr-gds.prod-code
        .
        if buf_temp_fbr-gds.in-qnty > buf_temp_fbr-gds.out-qnty
        then do:        /* ищем приход */
            find first buf_doc-line no-lock
                 where buf_doc-line.doc-code  = in-code
                   and buf_doc-line.artic     = buf_temp_fbr-gds.artic
                   and buf_doc-line.prod-type = buf_temp_fbr-gds.prod-type
                   and buf_doc-line.prod-code = buf_temp_fbr-gds.prod-code
            no-error.
            if available buf_doc-line
            then do:
                assign
                    buf_temp_fbr-gds.in-trn      = buf_doc-line.doc-qnty
                    buf_temp_fbr-gds.delta_value = buf_temp_fbr-gds.in-qnty - buf_doc-line.doc-qnty
                    buf_temp_fbr-gds.delta_sum   = buf_temp_fbr-gds.sum-rubl + buf_temp_fbr-gds.sum-vat-rubl - ( buf_doc-line.price-rubl * buf_doc-line.doc-qnty )
                .
            end.
        end.
        else do:        /* ищем расход */
            if buf_goods.gds-type = {&gds-office}
            then do:
                find first buf_doc-line no-lock
                     where buf_doc-line.doc-code  = serv-code
                       and buf_doc-line.artic     = buf_temp_fbr-gds.artic
                       and buf_doc-line.prod-type = buf_temp_fbr-gds.prod-type
                       and buf_doc-line.prod-code = buf_temp_fbr-gds.prod-code
                no-error.
            end.
            else do:
                find first buf_doc-line no-lock
                     where buf_doc-line.doc-code  = out-code
                       and buf_doc-line.artic     = buf_temp_fbr-gds.artic
                       and buf_doc-line.prod-type = buf_temp_fbr-gds.prod-type
                       and buf_doc-line.prod-code = buf_temp_fbr-gds.prod-code
                no-error.
            end.
            if available buf_doc-line
            then do:
                assign
                    buf_temp_fbr-gds.delta_value = buf_temp_fbr-gds.out-qnty - buf_doc-line.doc-qnty
                    buf_temp_fbr-gds.delta_sum   = buf_temp_fbr-gds.sum-rubl + buf_temp_fbr-gds.sum-vat-rubl - ( buf_doc-line.price-rubl * buf_doc-line.doc-qnty )
                    buf_temp_fbr-gds.out-trn     = buf_doc-line.doc-qnty
                .
            end.
        end.
    end.
end.
END PROCEDURE. /* fbr-igds-fill-fbr-gds */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-current-goods-recid {&FRAME-NAME}
PROCEDURE get-current-goods-recid :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    if available goods
    then do:
        assign
            gds-rec = recid( goods )
        .
    end.
    else do:
        assign
            gds-rec = ?
        .
    end.
end.
END PROCEDURE. /* get-current-goods-recid */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME