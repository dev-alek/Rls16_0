&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-doc-line-attr NO-UNDO LIKE doc-line-attr
       field node-code as int
       field price-rubl as dec
       field price-base as dec.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Доплата по документу (флористы)

Автор: Чернова Светлана Александровна
Дата создания: 03/03/05
Author: Svetlana Chernova
Creation date: 03/03/05


*/
/*------------------------------------------------------------------------

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Доплата по документу (флористы)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ gbl/lineattr.i }
{ str/trdcalib.i }
{ str/lib-calc.i }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }

define variable v-pr-1 as decimal   no-undo .

/* Parameters Definitions ---                                           */
define input  parameter parParentProc  as widget-handle no-undo.
define input  parameter   p-doc-mode  as character no-undo .
define input  parameter   p-doc-code  as character no-undo . /* Номер накладной */

define variable g#host-name  as character no-undo .
define variable g#host-code    as integer   no-undo .
define variable store-type   as character no-undo .
define variable store-code   as integer   no-undo .
define variable g#log      as logical   no-undo .

{ gbl/getcntxt.i get }
assign
  store-type    = v-cntxt-obj-type
  store-code    = v-cntxt-obj-code
.
{ gbl/hostname.i store-type store-code  g#host-code g#host-name }

define buffer nakl_trn-doc for trn-doc.
if p-doc-mode = {&lookup} then
   find first nakl_trn-doc no-lock  where nakl_trn-doc.doc-code = p-doc-code no-error .
else
  find first nakl_trn-doc exclusive-lock where nakl_trn-doc.doc-code = p-doc-code no-error .



/* Local Variable Definitions ---                                       */

DEF VAR v-sum-deliv AS CHAR NO-UNDO.


define variable v-itogo-base2 like gds-dtl.price-rubl  no-undo .
define variable v-itogo-rubl2 like gds-dtl.price-rubl   no-undo .
define variable v-pr-dl like gds-dtl.price-rubl no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-calc F- B-ok v-sum v-n v-date B-exit ~
B-Help f-1 v-pr-wrk v-itogo-base v-pr-srk v-itogo-rubl v-dis ~
v-sum-with-disc-base v-sum-with-disc-rubl f-2 v-dost v-dost-sum f-3 ~
v-bef-sum v-bef-n v-bef-date f-4 v-sum-new-rubl f-5 v-sum-new-base v-pr-new ~
F-6
&Scoped-Define DISPLAYED-OBJECTS F- v-sum v-n v-date f-1 v-pr-wrk ~
v-itogo-base v-pr-srk v-itogo-rubl v-dis v-sum-with-disc-base ~
v-sum-with-disc-rubl f-2 v-dost v-dost-sum f-3 v-bef-sum v-bef-n v-bef-date ~
f-4 v-sum-new-rubl f-5 v-sum-new-base v-pr-new F-6

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-calc
     LABEL "Пересчитать"
     SIZE 15 BY 1.13 TOOLTIP "Пересчитать % за работу и Сумму к оплате исходя из суммы Предоплата+Доплата".

DEFINE BUTTON B-exit AUTO-END-KEY
     LABEL "Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-ok AUTO-GO
     LABEL "Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE F- AS DECIMAL FORMAT "->>,>>>,>>9.99":U INITIAL 0
     LABEL "Получено"
      VIEW-AS TEXT
     SIZE 15 BY .67 TOOLTIP "Предоплата + Доплата" NO-UNDO.

DEFINE VARIABLE f-1 AS CHARACTER FORMAT "X(256)":U INITIAL " По накладной"
      VIEW-AS TEXT
     SIZE 87 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE f-2 AS CHARACTER FORMAT "X(256)":U INITIAL " Доставка"
      VIEW-AS TEXT
     SIZE 87 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE f-3 AS CHARACTER FORMAT "X(256)":U INITIAL " Предоплата"
      VIEW-AS TEXT
     SIZE 87.5 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE f-4 AS CHARACTER FORMAT "X(256)":U INITIAL " Доплата"
      VIEW-AS TEXT
     SIZE 43.5 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE f-5 AS CHARACTER FORMAT "X(256)":U INITIAL "Наценка"
      VIEW-AS TEXT
     SIZE 41.5 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE F-6 AS DECIMAL FORMAT "->>,>>>,>>9.99":U INITIAL 0
     LABEL "Взять как доплату"
      VIEW-AS TEXT
     SIZE 15 BY .67
     FGCOLOR 12  NO-UNDO.

DEFINE VARIABLE v-bef-date AS CHARACTER FORMAT "X(256)":U
     LABEL "Дата чека"
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.

DEFINE VARIABLE v-bef-n AS CHARACTER FORMAT "X(256)":U
     LABEL "№ чека"
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.

DEFINE VARIABLE v-bef-sum AS CHARACTER FORMAT "X(256)":U
     LABEL "Сумма"
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.

DEFINE VARIABLE v-date AS DATE FORMAT "99/99/9999":U
     LABEL "Дата чека"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE v-dis AS DECIMAL FORMAT "->>>>>>>>9.99":U INITIAL 0
     LABEL "Скидка %"
      VIEW-AS TEXT
     SIZE 12.5 BY .67
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE v-dost AS CHARACTER FORMAT "X(256)":U
     LABEL "Доставка"
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.

DEFINE VARIABLE v-dost-sum AS CHARACTER FORMAT "X(256)":U
     LABEL "Сумма"
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.

DEFINE VARIABLE v-itogo-base AS DECIMAL FORMAT "->>>>>>>>9.99":U INITIAL 0
     LABEL "По накл (баз.вал)"
      VIEW-AS TEXT
     SIZE 21.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-itogo-rubl AS DECIMAL FORMAT "->>>>>>>>9.99":U INITIAL 0
     LABEL "По накл abbr-rub"
      VIEW-AS TEXT
     SIZE 21.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-n AS CHARACTER FORMAT "X(256)":U
     LABEL "№ чека"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE v-pr-new AS DECIMAL FORMAT "->>>9.9999":U INITIAL 0
     LABEL "Наценка за работу %"
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-pr-srk AS CHARACTER FORMAT "X(256)":U
     LABEL "Наценка за срочность %"
      VIEW-AS TEXT
     SIZE 10 BY .67
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE v-pr-wrk AS CHARACTER FORMAT "X(256)":U
     LABEL "Наценка за работу %"
      VIEW-AS TEXT
     SIZE 10 BY .67
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE v-sum AS DECIMAL FORMAT "->>>>>>>9.99":U INITIAL 0
     LABEL "Сумма"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 TOOLTIP "Сумма доплаты" NO-UNDO.

DEFINE VARIABLE v-sum-new-base AS DECIMAL FORMAT "->>>>>>>9.99":U INITIAL 0
     LABEL "Сумма к оплате(баз.вал)"
      VIEW-AS TEXT
     SIZE 14 BY .67 TOOLTIP "Сумма с наценками и с доставкой"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-sum-new-rubl AS DECIMAL FORMAT "->>>>>>>9.99":U INITIAL 0
     LABEL "Сумма к оплате"
      VIEW-AS TEXT
     SIZE 14 BY .67 TOOLTIP "Сумма с наценками и с доставкой"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-sum-with-disc-base AS DECIMAL FORMAT "->>>>>>>>9.99":U INITIAL 0
     LABEL "Итого (баз.вал)"
      VIEW-AS TEXT
     SIZE 21.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-sum-with-disc-rubl AS DECIMAL FORMAT "->>>>>>>>9.99":U INITIAL 0
     LABEL "Итого "
      VIEW-AS TEXT
     SIZE 21.5 BY .67
     FGCOLOR 4  NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-calc AT ROW 20 COL 39.5
     F- AT ROW 16.5 COL 21 COLON-ALIGNED
     B-ok AT ROW 1 COL 1
     v-sum AT ROW 18.25 COL 12.5 COLON-ALIGNED
     v-n AT ROW 19.5 COL 12.5 COLON-ALIGNED
     v-date AT ROW 20.75 COL 12.5 COLON-ALIGNED
     B-exit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 81
     f-1 AT ROW 2.25 COL 2 NO-LABEL
     v-pr-wrk AT ROW 4 COL 23 COLON-ALIGNED
     v-itogo-base AT ROW 4 COL 65 COLON-ALIGNED
     v-pr-srk AT ROW 4.75 COL 23 COLON-ALIGNED
     v-itogo-rubl AT ROW 4.75 COL 65 COLON-ALIGNED
     v-dis AT ROW 5.75 COL 23 COLON-ALIGNED
     v-sum-with-disc-base AT ROW 5.75 COL 65 COLON-ALIGNED
     v-sum-with-disc-rubl AT ROW 6.5 COL 65 COLON-ALIGNED
     f-2 AT ROW 7.75 COL 2 NO-LABEL
     v-dost AT ROW 9 COL 12 COLON-ALIGNED
     v-dost-sum AT ROW 10.25 COL 12 COLON-ALIGNED
     f-3 AT ROW 11.25 COL 2 NO-LABEL
     v-bef-sum AT ROW 13 COL 12.5 COLON-ALIGNED
     v-bef-n AT ROW 13 COL 41.5 COLON-ALIGNED
     v-bef-date AT ROW 13 COL 70 COLON-ALIGNED
     f-4 AT ROW 15 COL 2 NO-LABEL
     v-sum-new-rubl AT ROW 19 COL 73 COLON-ALIGNED
     f-5 AT ROW 15 COL 47.5 NO-LABEL
     v-sum-new-base AT ROW 18.25 COL 73 COLON-ALIGNED
     v-pr-new AT ROW 21.5 COL 73 COLON-ALIGNED
     F-6 AT ROW 17.25 COL 21 COLON-ALIGNED
     SPACE(53.12) SKIP(4.70)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Доплата по документу"
         CANCEL-BUTTON B-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: tt-doc-line-attr T "?" NO-UNDO ub doc-line-attr
      ADDITIONAL-FIELDS:
          field node-code as int
          field price-rubl as dec
          field price-base as dec
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   Custom                                                               */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN f-1 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-2 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-3 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-4 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-5 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Доплата по документу */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-calc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-calc Dialog-Frame
ON CHOOSE OF B-calc IN FRAME Dialog-Frame /* Пересчитать */
DO:
  run proc-recalc.
  DISPLAY v-pr-new v-sum-new-base v-sum-new-rubl f-6 WITH FRAME {&FRAME-NAME} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-ok
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-ok Dialog-Frame
ON CHOOSE OF B-ok IN FRAME Dialog-Frame /* Ввод */
DO:
  ASSIGN
      v-date
      v-n
      v-sum
      .

     if v-date <> ? then do:
        { str/tdat-wrt.i
            p-doc-code
            {&trdcattr-postdchek}
            v-date
        }

        { str/tdat-oth.i
            p-doc-code
            {&trdcattr-postdchek}
            v-date
            no-error
        }
        if error-status :error then do:
           message "Ошибка при обработке атрибута." view-as alert-box.
           undo, return no-apply.
        end.

     end.

     if v-n <> "" then do:
        { str/tdat-wrt.i
            p-doc-code
            {&trdcattr-postNchek}
            v-n
        }
        { str/tdat-oth.i
            p-doc-code
            {&trdcattr-postNchek}
            v-n
            no-error
        }
        if error-status :error then do:
           message "Ошибка при обработке атрибута." view-as alert-box.
           undo, return no-apply.
        end.

     end.

         { str/tdat-wrt.i
             p-doc-code
             {&trdcattr-postpay}
             v-sum
         }

         { str/tdat-oth.i
             p-doc-code
             {&trdcattr-postpay}
             v-sum
             no-error
         }
         if error-status :error then do:
            message "Ошибка при обработке атрибута." view-as alert-box.
            undo, return no-apply.
         end.

{ str/tdat-wrt.i
    nakl_trn-doc.doc-code
    {&trdcattr-sumwrk}
    string(v-pr-dl)
}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-sum
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-sum Dialog-Frame
ON LEAVE OF v-sum IN FRAME Dialog-Frame /* Сумма */
DO:
  ASSIGN v-sum.

  F- =  DEC(v-bef-sum)  + v-sum .
  DISPLAY  F-  WITH FRAME {&FRAME-NAME} .
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
{ gbl/ed_date.i v-date }
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  run init-proc.
  v-itogo-rubl:label = "По накл ({&abbr_rub})".
  v-sum-new-rubl:label = "Сумма к оплате ({&abbr_rub})".
  v-sum-with-disc-rubl:label = "Итого ({&abbr_rub})".

  run enable_ui.
  hide v-pr-srk in frame {&frame-name} .
  if p-doc-mode =  {&lookup} then do:
     hide b-ok  in frame {&frame-name} .
     disable B-calc
             v-sum
             v-n
             v-date
             with frame {&frame-name} .
     B-exit:label = "Вы&ход".
     B-exit:COLUMN = 1.
  end.
IF nakl_trn-doc.status_ = {&fact} THEN do:
    HIDE
    F- F-6 v-sum-new-base v-sum-new-rubl
    B-calc
    v-itogo-base
    v-itogo-rubl
    IN FRAME {&FRAME-NAME}.

end.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.

run disable_ui.

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
  DISPLAY F- v-sum v-n v-date f-1 v-pr-wrk v-itogo-base v-pr-srk v-itogo-rubl
          v-dis v-sum-with-disc-base v-sum-with-disc-rubl f-2 v-dost v-dost-sum
          f-3 v-bef-sum v-bef-n v-bef-date f-4 v-sum-new-rubl f-5 v-sum-new-base
          v-pr-new F-6
      WITH FRAME Dialog-Frame.
  ENABLE B-calc F- B-ok v-sum v-n v-date B-exit B-Help f-1 v-pr-wrk
         v-itogo-base v-pr-srk v-itogo-rubl v-dis v-sum-with-disc-base
         v-sum-with-disc-rubl f-2 v-dost v-dost-sum f-3 v-bef-sum v-bef-n
         v-bef-date f-4 v-sum-new-rubl f-5 v-sum-new-base v-pr-new F-6
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-proc Dialog-Frame
PROCEDURE init-proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

define variable  v-type       as character no-undo .
define variable  v-postdchek as character no-undo .
define variable  v-postpay   as character no-undo .
define variable  v-postNchek as character no-undo .


&scop attr-temp-full-code ~{&v-code~} = "" . ~
run attr-read in this-procedure (  input p-doc-code  ~
                                ,  input ~{&attr-code~}    ~
                                , output ~{&v-code~}    ~
                                , output v-type ).


&scop attr-code {&trdcattr-dchek}
&scop v-code          v-bef-date
{&attr-temp-full-code}
&scop attr-code {&trdcattr-befpay}
&scop v-code           v-bef-sum
{&attr-temp-full-code}
&scop attr-code {&trdcattr-ord_nchek}
&scop v-code           v-bef-n
{&attr-temp-full-code}

&scop attr-code {&trdcattr-deliv}
&scop v-code           v-dost-sum
{&attr-temp-full-code}
&scop attr-code {&trdcattr-ord_dl}
&scop v-code    v-dost
{&attr-temp-full-code}


&scop attr-code {&trdcattr-sumwrk}
&scop v-code           v-pr-wrk
{&attr-temp-full-code}

&scop attr-code {&trdcattr-postdchek}
&scop v-code v-postdchek
{&attr-temp-full-code}
&scop attr-code {&trdcattr-postpay}
&scop v-code v-postpay
{&attr-temp-full-code}
&scop attr-code {&trdcattr-postNchek}
&scop v-code v-postNchek
{&attr-temp-full-code}
  ASSIGN
      v-date = date(v-postdchek)
      v-n    = v-postNchek
      v-sum  = dec(v-postpay)
      v-dis =  nakl_trn-doc.discnt-pc
      .

  v-pr-1 = decimal (v-pr-wrk)  .
  if v-dost = "yes" then v-dost = "Да"   .
                    else  v-dost = "Нет" .
assign
  v-itogo-base = 0
  v-itogo-rubl = 0
  .

 define buffer buf_goods for goods.
 define variable  v-nab as logical   no-undo .

   for each gds-dtl no-lock where gds-dtl.doc-code = p-doc-code :
        find first buf_goods no-lock
            where buf_goods.artic      = gds-dtl.artic
              and buf_goods.prod-type  = gds-dtl.prod-type
              and buf_goods.prod-code  = gds-dtl.prod-code .

      { str/grpnabor.i buf_goods.gds-code v-nab }
      if v-nab = false then do:
          assign
            v-itogo-base = (gds-dtl.price-base * gds-dtl.fact-qnty)  + v-itogo-base
            v-itogo-rubl = (gds-dtl.price-rubl * gds-dtl.fact-qnty)  + v-itogo-rubl

        .
      end.
   end.

  v-itogo-base2 = 0 .
  v-itogo-rubl2 = 0 .
  if LOOKUP ( nakl_trn-doc.status_ , {&fact} ) > 0  then do:
    v-itogo-base2 =   nakl_trn-doc.tot-fact -  nakl_trn-doc.tot-calc   .
    v-itogo-rubl2 =   nakl_trn-doc.tot-sale -  nakl_trn-doc.discnt-rubl.
  END.
  ELSE DO:
    IF  nakl_trn-doc.status_ = {&permitted} THEN DO:
        for each gds-dtl no-lock where gds-dtl.doc-code = p-doc-code :
              v-itogo-base2 = v-itogo-base2 +  ((gds-dtl.price-base - gds-dtl.discnt-base) * gds-dtl.fact-qnty) .
              v-itogo-rubl2 = v-itogo-rubl2 +  ((gds-dtl.price-rubl - gds-dtl.discnt-rubl) * gds-dtl.fact-qnty) .
        end.
    end.
    else do:
        v-itogo-base2 =  nakl_trn-doc.tot-doc  -  nakl_trn-doc.tot-calc     .
        v-itogo-rubl2 =  nakl_trn-doc.tot-rubl -  nakl_trn-doc.discnt-rubl  .
    end.
  END.


IF  nakl_trn-doc.status_ <> {&fact} THEN DO:
    v-sum-with-disc-base = v-itogo-base2  +  (v-pr-1) * v-itogo-base2 / 100 .
    v-sum-with-disc-rubl = v-itogo-rubl2  +  (v-pr-1) * v-itogo-rubl2 / 100 .
END.
ELSE DO:
    v-sum-with-disc-base = v-itogo-base2   .
    v-sum-with-disc-rubl = v-itogo-rubl2   .
END.

if   nakl_trn-doc.status_ = {&fact} then
assign
 v-pr-new  = decimal(v-pr-wrk)
 v-sum-new-rubl = v-sum-with-disc-rubl
 v-sum-new-base = v-sum-with-disc-base
.
else
assign
 v-pr-new  = decimal(v-pr-wrk)
 v-sum-new-rubl = v-sum-with-disc-rubl + DEC(v-dost-sum)
 v-sum-new-base = v-sum-with-disc-base + ( DEC(v-dost-sum)  * nakl_trn-doc.base-scale / nakl_trn-doc.base-rate )
.
 v-pr-dl  =  v-pr-new .

 F- =   DEC(v-bef-sum)  + v-sum .
 f-6 = v-sum-new-rubl  - DEC(v-bef-sum) .
display
  f-6
  v-pr-wrk

  v-date
  v-n
  v-sum
  v-sum-with-disc-rubl
  v-sum-with-disc-base
  v-itogo-base
  v-itogo-rubl
  v-dis
  F-
  v-dis
  with frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-recalc Dialog-Frame
PROCEDURE proc-recalc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-sum-rubl-1 as decimal   no-undo .
define variable v-pr2 as decimal   no-undo .
define variable v-dos as decimal   no-undo .
assign
  v-dos = DECimal(v-dost-sum)
  v-sum-rubl-1   = f-
  v-sum-new-rubl = v-sum-rubl-1
  v-sum-new-base = v-sum-new-rubl * nakl_trn-doc.base-scale / nakl_trn-doc.base-rate

  v-pr-new = (( v-sum-rubl-1  - ( v-itogo-rubl2 + v-dos) ) * 100 / v-itogo-rubl2 )


.

  define variable v1 as decimal   no-undo .
  define variable v2 as decimal   no-undo .

  v-itogo-rubl2 =  v-itogo-rubl * (1 - (nakl_trn-doc.discnt-pc / 100) )    .
/*
  v1 = (v-sum-new-rubl - v-dos) * nakl_trn-doc.discnt-pc / ( 100 - nakl_trn-doc.discnt-pc ) .

  message "сумма скидки нов" v1       skip
          "по цветам " v-itogo-rubl2  skip
         v-sum-new-rubl - v-dos + nakl_trn-doc.discnt-rubl skip
        " сумма наценки " (v-sum-new-rubl + nakl_trn-doc.discnt-rubl - v-dos  - v1 - v-itogo-rubl2 )
   .

  v2 = (v-sum-new-rubl + nakl_trn-doc.discnt-rubl - v-dos  - v1 - v-itogo-rubl2 ) .

 */

  v-pr-new = 100 * ((( v-sum-new-rubl - v-dos ) / ( v-itogo-rubl2) ) - 1) .
  v-pr-dl  = 100 * ((( v-sum-new-rubl - v-dos ) / ( v-itogo-rubl2) ) - 1) .
  { str/tdat-wrt.i
      nakl_trn-doc.doc-code
      {&trdcattr-discnt-stop}
      string(v-sum-new-rubl)
  }

END PROCEDURE.

procedure attr-read :
  define  input parameter p-doc-code like ub.doc-attr.doc-code   no-undo.
  define  input parameter p-code     like ub.doc-attr.attr-code  no-undo.
  define output parameter p-value    like ub.doc-attr.attr-value no-undo.
  define output parameter p-type     as   character              no-undo.

  do on error undo, return error return-value :
    { str/tdat-val.i
        p-doc-code
        p-code
        p-value
        p-type
    }
  end. /* on error */
end procedure. /* attr-read */


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME