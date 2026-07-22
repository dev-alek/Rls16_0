&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
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

Параметры доставки

Автор: Чернова Светлана Александровна
Дата создания: 09/01/06
Author: Svetlana Chernova
Creation date: 09/01/06

*/

/*------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter       parParentproc          as handle no-undo .
define input  parameter       p-mode                 as character no-undo . /* lookup update add */
define input  parameter       p-type-doc             as character no-undo . /* ordBO             */
define input  parameter       p-curr-obj-type        as character no-undo .
define input  parameter       p-curr-obj-code        as integer   no-undo .
define input  parameter       p-cli-type             as character no-undo .
define input  parameter       p-cli-code             as integer   no-undo .
define input-output parameter p-deliv-type-code      as integer   no-undo .
define input-output parameter p-point-obj-code       as integer   no-undo .
define input-output parameter p-point-obj-db-num     as integer   no-undo .
define input-output parameter p-point-cli-code       as integer   no-undo .
define input-output parameter p-point-cli-db-num     as integer   no-undo .
define input-output parameter p-transport-host-code       as integer   no-undo .
define input-output parameter p-transport-cli-type       as character no-undo .
define input-output parameter p-transport-cli-code       as integer   no-undo .
define input-output parameter p-transport-contract   as integer   no-undo .
define input-output parameter p-transport-condition  as integer   no-undo .
define input-output parameter p-transport-value      as decimal   no-undo .
define input-output parameter p-transport-sum        as decimal   no-undo .
define input-output parameter p-transport-vat        as decimal   no-undo .
/*
message
skip 'parParentproc          '  parParentproc
skip 'p-mode                 '  p-mode
skip 'p-type-doc             '  p-type-doc
skip 'p-curr-obj-type        '  p-curr-obj-type
skip 'p-curr-obj-code        '  p-curr-obj-code
skip 'p-cli-type             '  p-cli-type
skip 'p-cli-code             '  p-cli-code
skip 'p-deliv-type-code      '  p-deliv-type-code
skip 'p-point-obj-code       '  p-point-obj-code
skip 'p-point-obj-db-num     '  p-point-obj-db-num
skip 'p-point-cli-code       '  p-point-cli-code
skip 'p-point-cli-db-num     '  p-point-cli-db-num
skip 'p-transport-host-code  '  p-transport-host-code
skip 'p-transport-cli-type   '  p-transport-cli-type
skip 'p-transport-cli-code   '  p-transport-cli-code
skip 'p-transport-contract   '  p-transport-contract
skip 'p-transport-condition  '  p-transport-condition
skip 'p-transport-value      '  p-transport-value
skip 'p-transport-sum        '  p-transport-sum
skip 'p-transport-vat        '  p-transport-vat
.

*/



/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Параметры доставки".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

define buffer cargo_clients  for ub.clients  .
define buffer cargo_contract for ub.contract .
define buffer buf_delivery-type for ub.delivery-type  .
define variable curr-host-code as integer   no-undo .
define buffer buf_place-io for ub.place-io  .
define buffer buf_point-io for ub.point-io  .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-save B-Cancel B-Help r-deliv r-point-1 ~
r-point-2 r-wrkr r-wrkr-2 B-contract scr-trasport-condition ~
scr-transport-value scr-transport-sum scr-transport-vat-pc ~
scr-deliv-type-code scr-deliv-type-name scr-point-obj-code ~
scr-point-obj-name scr-point-cli-code scr-point-cli-name scr-transport-cli-code ~
scr-transport-cli-type scr-transport-host-name scr-transport-contract ~
scr-transport-name
&Scoped-Define DISPLAYED-OBJECTS scr-trasport-condition scr-transport-value ~
scr-transport-sum scr-transport-vat-pc scr-deliv-type-code ~
scr-deliv-type-name scr-point-obj-code scr-point-obj-name ~
scr-point-cli-code scr-point-cli-name scr-transport-cli-code ~
scr-transport-cli-type scr-transport-host-name scr-transport-contract ~
scr-transport-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-contract
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U NO-CONVERT-3D-COLORS
     LABEL ""
     SIZE 3 BY .79 TOOLTIP "Посмотреть договор".

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-save AUTO-GO
     LABEL "Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON r-deliv
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.

DEFINE BUTTON r-point-1
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.

DEFINE BUTTON r-point-2
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.

DEFINE BUTTON r-wrkr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.

DEFINE BUTTON r-wrkr-2
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE VARIABLE scr-trasport-condition AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 1
     LABEL "Условия транспортных услуг"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Неопеределены",0
     DROP-DOWN-LIST
     SIZE 65.13 BY 1 NO-UNDO.

DEFINE VARIABLE scr-deliv-type-code AS INTEGER FORMAT ">>>>>>>":U INITIAL 0
     LABEL "Способ доставки"
      VIEW-AS TEXT
     SIZE 7 BY .67 NO-UNDO.

DEFINE VARIABLE scr-deliv-type-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 60.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE scr-point-cli-code AS INTEGER FORMAT ">>>>>>>":U INITIAL 0
     LABEL "Пункт  приемки"
      VIEW-AS TEXT
     SIZE 7 BY .67 NO-UNDO.

DEFINE VARIABLE scr-point-cli-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 60.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE scr-point-obj-code AS INTEGER FORMAT ">>>>>>>":U INITIAL 0
     LABEL "Пункт отгрузки"
      VIEW-AS TEXT
     SIZE 7 BY .67 NO-UNDO.

DEFINE VARIABLE scr-point-obj-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 60.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE scr-transport-cli-type AS CHARACTER FORMAT "X(3)":U
      VIEW-AS TEXT
     SIZE 3.63 BY .67 NO-UNDO.

DEFINE VARIABLE scr-transport-contract AS INTEGER FORMAT ">>>>>>>>>":U INITIAL 0
     LABEL "Транспортный договор"
      VIEW-AS TEXT
     SIZE 10.13 BY .79 TOOLTIP "Договор транспортных услуг" NO-UNDO.

DEFINE VARIABLE scr-transport-cli-code AS INTEGER FORMAT ">>>>>>>>>":U INITIAL 0
     LABEL "Грузоперевозчик"
      VIEW-AS TEXT
     SIZE 10.13 BY .67 NO-UNDO.

DEFINE VARIABLE scr-transport-host-name AS CHARACTER FORMAT "X(120)":U
      VIEW-AS TEXT
     SIZE 37.38 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE scr-transport-name AS CHARACTER FORMAT "X(20)":U
      VIEW-AS TEXT
     SIZE 12.88 BY .79
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE scr-transport-sum AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "Сумма транспортных услуг"
     VIEW-AS FILL-IN
     SIZE 21.5 BY 1 NO-UNDO.

DEFINE VARIABLE scr-transport-value AS DECIMAL FORMAT "->>,>>>,>>9.99":U INITIAL 0
     LABEL ""
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE scr-transport-vat-pc AS DECIMAL FORMAT ">>9.99":U INITIAL 0
     LABEL "НДС услуги,%"
     VIEW-AS FILL-IN
     SIZE 6.63 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-save AT ROW 1 COL 1
     B-Cancel AT ROW 1 COL 11
     B-Help AT ROW 1 COL 86
     r-deliv AT ROW 2 COL 30.38
     r-point-1 AT ROW 3 COL 30.38
     r-point-2 AT ROW 4 COL 30.38
     r-wrkr AT ROW 6 COL 38
     r-wrkr-2 AT ROW 7 COL 33.63
     B-contract AT ROW 7 COL 50
     scr-trasport-condition AT ROW 8 COL 1.62
     scr-transport-value AT ROW 9 COL 27.63 COLON-ALIGNED
     scr-transport-sum AT ROW 10 COL 27.63 COLON-ALIGNED
     scr-transport-vat-pc AT ROW 11 COL 27.63 COLON-ALIGNED
     scr-deliv-type-code AT ROW 2 COL 20.88 COLON-ALIGNED
     scr-deliv-type-name AT ROW 2 COL 31.63 COLON-ALIGNED NO-LABEL
     scr-point-obj-code AT ROW 3 COL 20.88 COLON-ALIGNED
     scr-point-obj-name AT ROW 3 COL 31.63 COLON-ALIGNED NO-LABEL
     scr-point-cli-code AT ROW 4 COL 20.88 COLON-ALIGNED
     scr-point-cli-name AT ROW 4 COL 31.63 COLON-ALIGNED NO-LABEL
     scr-transport-cli-code AT ROW 6 COL 21 COLON-ALIGNED
     scr-transport-cli-type AT ROW 6 COL 32.38 COLON-ALIGNED NO-LABEL WIDGET-ID 2
     scr-transport-host-name AT ROW 6 COL 39 COLON-ALIGNED NO-LABEL
     scr-transport-contract AT ROW 7 COL 21 COLON-ALIGNED
     scr-transport-name AT ROW 7 COL 34.63 COLON-ALIGNED NO-LABEL
     SPACE(46.98) SKIP(6.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Условия доставки"
         DEFAULT-BUTTON B-save CANCEL-BUTTON B-Cancel.


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

/* SETTINGS FOR COMBO-BOX scr-trasport-condition IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Условия доставки */
DO:
  /* */
  RUN save-proc no-error .
  if error-status :error then return no-apply .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Условия доставки */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-contract
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-contract Dialog-Frame
ON CHOOSE OF B-contract IN FRAME Dialog-Frame
DO:

assign scr-transport-contract .
define buffer b_contract for ub.contract.
find first b_contract no-lock  where b_contract.contract-code     = scr-transport-contract and
                                     b_contract.host-code         = curr-host-code
                                     no-error .
if error-status :error then return no-apply.

run str/sh-contr.p (
    input parParentProc ,
    input recid (b_contract))
    .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-Help
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-Help Dialog-Frame
ON CHOOSE OF B-Help IN FRAME Dialog-Frame /* Помощь */
OR HELP OF FRAME {&FRAME-NAME}
DO: /* Call Help Function (or a simple message). */

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-deliv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-deliv Dialog-Frame
ON CHOOSE OF r-deliv IN FRAME Dialog-Frame
DO:

define variable v-sts as integer init 0  no-undo .
define variable v-rid-list as character no-undo .

       scr-deliv-type-code = 0 .
       scr-deliv-type-name = "".

run ref/dlvtypes.w
  ( input parParentProc
  , input  p-curr-obj-type
  , input  p-curr-obj-code
  , input  "b-sel":U
  , input  {&all}
  , input-output v-sts
  , input-output v-rid-list )
      no-error .
    find first buf_delivery-type no-lock where recid(buf_delivery-type) = integer(v-rid-list) no-error .
    if available  buf_delivery-type then do:
       scr-deliv-type-code = buf_delivery-type.deliv-type-code.
       scr-deliv-type-name = buf_delivery-type.deliv-type-name.
    end.
    display scr-deliv-type-code
            scr-deliv-type-name
            with frame {&frame-name} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-point-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-point-1 Dialog-Frame
ON CHOOSE OF r-point-1 IN FRAME Dialog-Frame
DO:
  /* obj */
  scr-point-obj-code = 0.
  scr-point-obj-name = "".
  if p-curr-obj-code = ? then return .
  define variable rid-list as character no-undo .
  case  p-type-doc  :
      when "rcv" + {&o-o} or
      when "rcv" + {&f-p} or
      when "ord" + {&o-r} or
      when "ord" + {&o-o} or
      when "ord" + {&p-o} or
      when "ord" + {&o-f} or
      when "ord" + {&o-p}
      then do:
            run ref/place-io.w
              (input  parparentproc
              ,input  'b-sel' /*,b-add*/
              ,input  p-curr-obj-type
              ,input  p-curr-obj-code
              ,input  {&g___object}
              ,input  'all'
              ,input-output rid-list
              ).
            find first buf_place-io no-lock where
                recid (buf_place-io) = integer(rid-list) no-error .
            if available buf_place-io then do:
                scr-point-obj-code  = buf_place-io.place-io-code.
                scr-point-obj-name  = buf_place-io.place-io-name.
            end.
        end.
  end case.

  display scr-point-obj-code
          scr-point-obj-name
  with frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-point-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-point-2 Dialog-Frame
ON CHOOSE OF r-point-2 IN FRAME Dialog-Frame
DO:

  /* cli */
  scr-point-cli-code = 0.
  scr-point-cli-name = "".
  if p-cli-code = ? then return .
  define variable rid-list as character no-undo .
  case  p-type-doc  :
      when "rcv" + {&o-o} or
      when "ord" + {&o-r} or
      when "ord" + {&o-o} then do:
            run ref/place-io.w
              (input  parparentproc
              ,input  'b-sel' /*,b-add*/
              ,input  p-cli-type
              ,input  p-cli-code
              ,input  {&g___object}
              ,input  'all'
              ,input-output rid-list
              ).
            find first buf_place-io no-lock where
                recid (buf_place-io) = integer(rid-list) no-error .
            if available buf_place-io then do:
                scr-point-cli-code = buf_place-io.place-io-code .
                scr-point-cli-name = buf_place-io.place-io-name .
            end.
      end.

      when "ord" + {&p-o} or
      when "ord" + {&o-f} or
      when "ord" + {&f-p} or
      when "rcv" + {&f-p} or
      when "ord" + {&o-p}
      then do:
      run ref/point-io.w
        (input  parparentproc
        ,input  'b-sel' /*,b-add*/
        ,input  v-cntxt-db-num
        ,input  p-cli-type
        ,input  p-cli-code
        ,input  {&g___object}
        ,input  'all'
        ,input-output rid-list
        ).

      find first buf_point-io no-lock where
            recid (buf_point-io) = integer(rid-list) no-error .
      if available buf_point-io then do:
          p-point-cli-db-num  = buf_point-io.db-num.
          scr-point-cli-code  = buf_point-io.point-code.
          scr-point-cli-name  = buf_point-io.point-name.
      end.
  END.
  END CASE.


  display scr-point-cli-code
          scr-point-cli-name
  with frame {&frame-name} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-wrkr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-wrkr Dialog-Frame
ON CHOOSE OF r-wrkr IN FRAME Dialog-Frame
DO: /* Грузоперевозчик */

define variable rid-list as character no-undo.
scr-transport-cli-code   = 0 .
scr-transport-cli-type   = "" .
scr-transport-host-name = "".

  run ref/cli-all.w
      ( input parParentProc,
        input "b-sel",
        input {&cmp},
        input {&all},
        input {&current},
        input ?,
        input ",,,,,,NO,,":U,
        input "without-obj",  /*;lock-cli-type*/
        output rid-list ) .

find first cargo_clients no-lock where
     recid (cargo_clients) = integer(rid-list) no-error .
    if available cargo_clients then do:
        scr-transport-cli-code  = cargo_clients.obj-code .
        scr-transport-cli-type  = cargo_clients.obj-type .
        scr-transport-host-name = cargo_clients.obj-name .
    end.


display scr-transport-cli-code
        scr-transport-host-name
        scr-transport-cli-type
        with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-wrkr-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-wrkr-2 Dialog-Frame
ON CHOOSE OF r-wrkr-2 IN FRAME Dialog-Frame
DO:

/* Договор грузоперевозчика */
IF scr-transport-cli-code = 0  THEN DO:
   message "Не выбран грузоперевозчик !"  view-as alert-box information .
   return no-apply .
END.
define variable   rid-list   as character no-undo . /* recid выбранных договоров */
define buffer buf_contract for ub.contract.

ASSIGN scr-transport-cli-code .
scr-transport-contract = 0  .
scr-transport-name     = "" .

run str/cont-all.w (
      input   parParentProc   ,
      input   curr-host-code  ,
      input   "b-sel"         ,
      input   {&company}      ,
      input   scr-transport-cli-type ,
      input   scr-transport-cli-code ,
      input   ?               ,
      input   ?               ,
      input   "current"       ,
      input   "all"           ,
      input-output rid-list )
      .
find first buf_contract no-lock where recid (buf_contract) =  integer(rid-list) no-error .
if available buf_contract then do:
  scr-transport-contract = buf_contract.contract-code .
  scr-transport-name     = buf_contract.contract-prn-code.
  end.

DISPLAY scr-transport-contract
        scr-transport-name
    WITH FRAME {&FRAME-NAME}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME scr-point-cli-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL scr-point-cli-name Dialog-Frame
ON return OF scr-point-cli-name IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME scr-point-obj-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL scr-point-obj-name Dialog-Frame
ON return OF scr-point-obj-name IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME scr-transport-cli-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL scr-transport-cli-type Dialog-Frame
ON return OF scr-transport-cli-type IN FRAME Dialog-Frame
DO:
  run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME scr-transport-contract
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL scr-transport-contract Dialog-Frame
ON return OF scr-transport-contract IN FRAME Dialog-Frame /* Транспортный договор */
DO:
  run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME scr-transport-cli-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL scr-transport-cli-code Dialog-Frame
ON return OF scr-transport-cli-code IN FRAME Dialog-Frame /* Грузоперевозчик */
DO:
  run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME scr-transport-host-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL scr-transport-host-name Dialog-Frame
ON return OF scr-transport-host-name IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME scr-transport-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL scr-transport-name Dialog-Frame
ON return OF scr-transport-name IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME scr-trasport-condition
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL scr-trasport-condition Dialog-Frame
ON VALUE-CHANGED OF scr-trasport-condition IN FRAME Dialog-Frame /* Условия транспортных услуг */
DO:
 if scr-trasport-condition:screen-value = {&transport-prc}
    then do:
      assign
      scr-transport-value:visible = true
      .
    end.
    else
      scr-transport-value:visible = false  .

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
  run init-proc in this-procedure .
  if p-mode = {&lookup} then
       run lkp-enable in this-procedure .
  else run enable_ui in this-procedure .

  if scr-trasport-condition = integer ({&transport-prc})
    then
      assign
        scr-transport-value:visible = yes
        scr-transport-value:label = "%"
        .
    else scr-transport-value:visible = no .

   if  p-type-doc  = "ord" + {&p-o}
   then
   assign
     scr-point-obj-code:label = "Отгрузка"
     scr-point-cli-code:label = "Доставка до"
   .
   else
   assign
     scr-point-obj-code:label = "Прием"
     scr-point-cli-code:label = "Отгрузка с"
   .
  wait-for go of frame {&frame-name}.

end.
run disable_ui in this-procedure .

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
  DISPLAY scr-trasport-condition scr-transport-value scr-transport-sum
          scr-transport-vat-pc scr-deliv-type-code scr-deliv-type-name
          scr-point-obj-code scr-point-obj-name scr-point-cli-code
          scr-point-cli-name scr-transport-cli-code scr-transport-cli-type
          scr-transport-host-name scr-transport-contract scr-transport-name
      WITH FRAME Dialog-Frame.
  ENABLE B-save B-Cancel B-Help r-deliv r-point-1 r-point-2 r-wrkr r-wrkr-2
         B-contract scr-trasport-condition scr-transport-value
         scr-transport-sum scr-transport-vat-pc scr-deliv-type-code
         scr-deliv-type-name scr-point-obj-code scr-point-obj-name
         scr-point-cli-code scr-point-cli-name scr-transport-cli-code
         scr-transport-cli-type scr-transport-host-name scr-transport-contract
         scr-transport-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
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
scr-trasport-condition:List-Item-Pairs in frame {&frame-name} =
"{&bef-transport-include-full},{&bef-transport-include},{&bef-transport-prc-full},{&bef-transport-prc},{&bef-transport-dist-full},{&bef-transport-dist}"        .
assign
  scr-deliv-type-code     = p-deliv-type-code
  scr-transport-cli-code  = p-transport-cli-code
  scr-transport-cli-type  = p-transport-cli-type
  scr-trasport-condition  = p-transport-condition
  scr-transport-value     = p-transport-value
  scr-transport-sum       = p-transport-sum
  scr-transport-vat-pc    = p-transport-vat
  scr-point-obj-code      = p-point-obj-code
  scr-point-cli-code      = p-point-cli-code
  scr-transport-contract  = p-transport-contract
  .
  if p-curr-obj-code <> ? then do:
{ gbl/hostcode.i
  p-curr-obj-type
  p-curr-obj-code
  curr-host-code }
  end.
  else do:
    curr-host-code = v-cntxt-host-code-obj .
  end.

  p-transport-host-code = curr-host-code .


find first buf_delivery-type no-lock where
           buf_delivery-type.deliv-type-code = scr-deliv-type-code
           no-error .

if available  buf_delivery-type then do:
    scr-deliv-type-name = buf_delivery-type.deliv-type-name.
end.

find first cargo_clients no-lock where
      cargo_clients.obj-type = scr-transport-cli-type and
      cargo_clients.obj-code = scr-transport-cli-code
      no-error .
    if available cargo_clients then do:
          scr-transport-host-name = cargo_clients.obj-name .
          find first cargo_contract no-lock where
            cargo_contract.contract-code = scr-transport-contract and
            cargo_contract.host-code     = curr-host-code     no-error .
          if available cargo_contract then do:
            scr-transport-name     = cargo_contract.contract-prn-code.
          end.
    end.


  case  p-type-doc  :
      when "ord" + {&p-o} or
      when "ord" + {&o-f} or
      when "ord" + {&f-p} or
      when "rcv" + {&f-p} or
      when "ord" + {&o-p}
      then do:
            /* obj */
            find first buf_place-io no-lock where
                       buf_place-io.obj-type      = p-curr-obj-type and
                       buf_place-io.obj-code      = p-curr-obj-code and
                       buf_place-io.place-io-code = scr-point-obj-code
                       no-error .
            if available buf_place-io then do:
                scr-point-obj-code = buf_place-io.place-io-code.
                scr-point-obj-name = buf_place-io.place-io-name.
            end.
            /* cli */
            find first buf_point-io no-lock where
                       buf_point-io.point-code = scr-point-cli-code and
                       buf_point-io.db-num     = p-point-cli-db-num
                       no-error .
            if available buf_point-io then do:
                scr-point-cli-code = buf_point-io.point-code.
                scr-point-cli-name = buf_point-io.point-name.
            end.
            /*ASSIGN frame {&frame-name}:TITLE = "Условия доставки по заказу от ПОКУПАТЕЛЯ".*/
        end.
        otherwise do:
            /* obj */
            find first buf_place-io no-lock where
                       buf_place-io.obj-type      = p-curr-obj-type and
                       buf_place-io.obj-code      = p-curr-obj-code and
                       buf_place-io.place-io-code = scr-point-obj-code
                       no-error .
            if available buf_place-io then do:
                scr-point-obj-code = buf_place-io.place-io-code.
                scr-point-obj-name = buf_place-io.place-io-name.
            end.
            /* cli */
            find first buf_place-io no-lock where
                       buf_place-io.obj-type      = p-cli-type and
                       buf_place-io.obj-code      = p-cli-code and
                       buf_place-io.place-io-code = scr-point-cli-code
                       no-error .
            if available buf_place-io then do:
                scr-point-cli-code = buf_place-io.place-io-code.
                scr-point-cli-name = buf_place-io.place-io-name.

            end.
        end.
  end case.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE lkp-enable Dialog-Frame
PROCEDURE lkp-enable :
B-Cancel:label in frame {&frame-name}  = "&Выход".
  B-Cancel:column = 1.

  DISPLAY scr-deliv-type-code scr-transport-cli-code scr-trasport-condition
          scr-transport-value scr-transport-sum scr-transport-vat-pc
          scr-deliv-type-name scr-point-obj-code scr-point-obj-name
          scr-point-cli-code scr-point-cli-name scr-transport-host-name
          scr-transport-contract scr-transport-name
      WITH FRAME Dialog-Frame.

  ENABLE B-Cancel B-Help
         B-contract
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE next-focus Dialog-Frame
PROCEDURE next-focus :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
do
on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:

define input parameter p-widget-handle as handle no-undo .
define variable l-apply-entry as logical no-undo .

assign
  l-apply-entry = /* false */  true
.

do with frame {&frame-name} :
  if  scr-point-cli-name     :handle = p-widget-handle then do:  if scr-point-obj-name     :sensitive then do: apply "entry":u to scr-point-obj-name     . return . end. end.
  if  scr-point-obj-name     :handle = p-widget-handle then do:  if scr-transport-contract :sensitive then do: apply "entry":u to scr-transport-contract . return . end. end.
  if  scr-transport-contract :handle = p-widget-handle then do:  if scr-transport-cli-code     :sensitive then do: apply "entry":u to scr-transport-cli-code     . return . end. end.
  if  scr-transport-cli-code     :handle = p-widget-handle then do:  if scr-transport-name     :sensitive then do: apply "entry":u to scr-transport-name     . return . end. end.

  end. /* do with frame */

  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-proc Dialog-Frame
PROCEDURE save-proc :
assign frame {&frame-name}
scr-deliv-type-code
scr-transport-cli-code
scr-trasport-condition
scr-transport-value
scr-transport-sum
scr-transport-vat-pc
scr-point-obj-code
scr-point-cli-code
scr-transport-contract
.

assign
  p-deliv-type-code     = scr-deliv-type-code
  p-transport-cli-type  = scr-transport-cli-type
  p-transport-cli-code  = scr-transport-cli-code
  p-transport-condition = scr-trasport-condition
  p-transport-value     = scr-transport-value
  p-transport-sum       = scr-transport-sum
  p-transport-vat       = scr-transport-vat-pc
  p-point-obj-code      = scr-point-obj-code
  p-point-cli-code      = scr-point-cli-code
  p-transport-contract  = scr-transport-contract
  .


define buffer buf_contract for ub.contract  .
if p-transport-contract  <> 0 and p-transport-contract  <> ? then do:
   find first buf_contract no-lock where
              buf_contract.host-code     =  p-transport-host-code and
              buf_contract.contract-code =  p-transport-contract no-error .
   if not available buf_contract then do:
      message
        "Не верно задан договор грузоперевозчика" skip
        "Фирма  : " p-transport-host-code  skip
        "Договор: " p-transport-contract  skip
        view-as alert-box error
      .
      return error .
      end.
      if not ( buf_contract.cli-type  =  p-transport-cli-type and
               buf_contract.cli-code  =  p-transport-cli-code  ) then do:
      message
        "У Грузоперевозчика нет такого договора" skip
        "Грузоперевозчик: " p-transport-cli-type p-transport-cli-code      skip
        "Фирма  : " p-transport-host-code  skip
        "Договор: " p-transport-contract  skip

        view-as alert-box error
      .
      return error .

      end.


end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME