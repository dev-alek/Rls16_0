&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_chk-doc FOR ub.chk-doc.
DEFINE BUFFER X_chk-gds FOR ub.chk-gds.
DEFINE BUFFER X_inkas FOR ub.inkas.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Продажа номерного товара

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/19/05
Author: Bakhtadze Natalya
Creation date: 10/19/05

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
/*товар передается через шареную переменную gds-rec*/
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-gds-rec as recid no-undo .


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Продажа номерного товара" .
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i  }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }


DEFINE VARIABLE partic like ub.goods.artic NO-UNDO.
DEFINE VARIABLE pprod-type like ub.goods.prod-type NO-UNDO.
DEFINE VARIABLE pprod-code like ub.goods.prod-code NO-UNDO.
DEFINE VARIABLE pgds-code like ub.goods.gds-code NO-UNDO.
DEFINE VARIABLE punit-base like ub.goods.unit-base NO-UNDO.
DEFINE VARIABLE pnode-code like ub.gds-prt.node-code NO-UNDO.

DEFINE NEW SHARED BUFFER c-doc FOR ub.chk-doc.
DEFINE NEW SHARED BUFFER ink-doc FOR ub.inkas.
DEFINE NEW SHARED QUERY br-docs FOR ink-doc SCROLLING.
define buffer buf_goods for ub.goods.


/* список приходных партий для серийного товара */
define temp-table temp-inparts no-undo
  field in-code   like ub.parts.in-code
  field part-code like ub.parts.part-code
  field b-code    like ub.bar-code.b-code
  .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-parts

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-inparts X_chk-gds X_inkas X_chk-doc

/* Definitions for BROWSE BR-parts                                      */
&Scoped-define FIELDS-IN-QUERY-BR-parts temp-inparts.b-code temp-inparts.in-code temp-inparts.part-code X_inkas.inkas-code X_chk-doc.doc-code X_chk-doc.chk-date X_chk-doc.chk-num
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-parts
&Scoped-define SELF-NAME BR-parts
&Scoped-define QUERY-STRING-BR-parts FOR EACH temp-inparts, ~
                EACH X_chk-gds where                X_chk-gds.b-code   = temp-inparts.b-code AND                X_chk-gds.out-code <> ?, ~
                FIRST X_inkas NO-LOCK WHERE                X_inkas.inkas-code = X_chk-gds.out-code AND                X_inkas.status_    = {&fact}, ~
                FIRST X_chk-doc No-LOCK WHERE                X_chk-doc.doc-code = X_chk-gds.doc-code
&Scoped-define OPEN-QUERY-BR-parts OPEN QUERY br-parts      FOR EACH temp-inparts, ~
                EACH X_chk-gds where                X_chk-gds.b-code   = temp-inparts.b-code AND                X_chk-gds.out-code <> ?, ~
                FIRST X_inkas NO-LOCK WHERE                X_inkas.inkas-code = X_chk-gds.out-code AND                X_inkas.status_    = {&fact}, ~
                FIRST X_chk-doc No-LOCK WHERE                X_chk-doc.doc-code = X_chk-gds.doc-code                       .
&Scoped-define TABLES-IN-QUERY-BR-parts temp-inparts X_chk-gds X_inkas ~
X_chk-doc
&Scoped-define FIRST-TABLE-IN-QUERY-BR-parts temp-inparts
&Scoped-define SECOND-TABLE-IN-QUERY-BR-parts X_chk-gds
&Scoped-define THIRD-TABLE-IN-QUERY-BR-parts X_inkas
&Scoped-define FOURTH-TABLE-IN-QUERY-BR-parts X_chk-doc


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-exit b-gds B-parts B-chk B-doc ~
B-cli B-print B-Help SerNum BR-parts gds-name
&Scoped-Define DISPLAYED-OBJECTS SerNum gds-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-chk
     LABEL "&Чек"
     SIZE 10 BY 1.

DEFINE BUTTON B-cli
     LABEL "&Клиент"
     SIZE 10 BY 1.

DEFINE BUTTON B-doc
     LABEL "&Накладная"
     SIZE 10 BY 1.

DEFINE BUTTON B-exit
     LABEL "Пои&ск"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-gds
     LABEL "&Товар"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-parts
     LABEL "&Партия"
     SIZE 10 BY 1.

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE gds-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Товар"
      VIEW-AS TEXT
     SIZE 71.3 BY .67 NO-UNDO.

DEFINE VARIABLE SerNum AS CHARACTER FORMAT "X(256)":U
     LABEL "Серийный номер"
     VIEW-AS FILL-IN
     SIZE 18.3 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-parts FOR
      temp-inparts,
      X_chk-gds,
      X_inkas,
      X_chk-doc SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-parts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-parts Dialog-Frame _FREEFORM
  QUERY BR-parts NO-LOCK DISPLAY
      temp-inparts.b-code COLUMN-LABEL "Бар-код"
      temp-inparts.in-code COLUMN-LABEL "Номер ПН"
      temp-inparts.part-code COLUMN-LABEL "Сер. номер" FORMAT "X(14)"
      X_inkas.inkas-code COLUMN-LABEL "Продажа"
      X_chk-doc.doc-code COLUMN-LABEL "Номер чека"
      X_chk-doc.chk-date COLUMN-LABEL "Дата чека"
      X_chk-doc.chk-num COLUMN-LABEL "N чека на кассе"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 12.37.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-exit AT ROW 1 COL 11
     b-gds AT ROW 1 COL 21
     B-parts AT ROW 1 COL 31
     B-chk AT ROW 1 COL 41
     B-doc AT ROW 1 COL 51
     B-cli AT ROW 1 COL 61
     B-print AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     SerNum AT ROW 2.87 COL 24.6 COLON-ALIGNED
     BR-parts AT ROW 5.77 COL 1
     gds-name AT ROW 4.37 COL 24.6 COLON-ALIGNED
     SPACE(1.09) SKIP(13.52)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Поиск продаж номерного товара"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_chk-doc B "?" ? ub chk-doc
      TABLE: X_chk-gds B "?" ? ub chk-gds
      TABLE: X_inkas B "?" ? ub inkas
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-parts SerNum Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-parts
/* Query rebuild information for BROWSE BR-parts
     _START_FREEFORM
OPEN QUERY br-parts
     FOR EACH temp-inparts,
         EACH X_chk-gds where
               X_chk-gds.b-code   = temp-inparts.b-code AND
               X_chk-gds.out-code <> ?,
         FIRST X_inkas NO-LOCK WHERE
               X_inkas.inkas-code = X_chk-gds.out-code AND
               X_inkas.status_    = {&fact},
         FIRST X_chk-doc No-LOCK WHERE
               X_chk-doc.doc-code = X_chk-gds.doc-code
                      .
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Where[1]         = "parts.artic = partic
 AND parts.prod-code = pprod-code
 AND parts.prod-type = pprod-type
 AND parts.out-code <> """"
 AND parts.obj-type = p-obj-type
 AND parts.obj-code = p-obj-code
 AND parts.part-code = SerNum
 AND parts.status_ = TRUE
 AND parts.doc-type <> {&act-overvalue}"
     _JoinCode[2]      = "bar-code.in-code = parts.in-code
  AND bar-code.part-code = parts.part-code
"
     _Where[2]         = "bar-code.gds-code = pgds-code
 AND bar-code.unit-cli = punit-base
 AND bar-code.node-code = pnode-code
 "
     _JoinCode[3]      = "X_chk-gds.b-code = bar-code.b-code"
     _JoinCode[4]      = "X_inkas.inkas-code = X_chk-gds.out-code"
     _Where[4]         = "X_inkas.status_ = {&fact}
 AND X_inkas.inkas-code = X_chk-gds.out-code "
     _Query            is NOT OPENED
*/  /* BROWSE BR-parts */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Поиск продаж номерного товара */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chk
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chk Dialog-Frame
ON CHOOSE OF B-chk IN FRAME Dialog-Frame /* Чек */
DO:
define variable next-prev as character no-undo .
define variable v-doc-rec as recid no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
    IF NOT AVAIL X_chk-doc then do:
        RETURN NO-APPLY.
    END.
    FIND FIRST c-doc where
               recid(c-doc) = recid(X_chk-doc) NO-ERROR.
    DO WHILE next-prev = '':U:
        if NOT available c-doc then do:
                message "Неправильно выбран чек." view-as alert-box ERROR.
                return no-apply.
        end.
        v-doc-rec = recid (X_chk-doc).
        { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
        run str/superchk.w (
                        input parparentproc
                       ,input {&lookup}
                       ,input p-obj-type
                       ,input p-obj-code
                       ,input-output v-doc-rec
                       ,input this-procedure:handle
                       ,input-output next-prev
                       )
        .
    END .
    apply "entry" to br-parts in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-cli Dialog-Frame
ON CHOOSE OF B-cli IN FRAME Dialog-Frame /* Клиент */
DO:
    IF NOT AVAIL X_chk-doc then do:
        RETURN NO-APPLY.
    END.
  if X_chk-doc.d-card <> "" then do:
    FIND FIRST ub.dis-card No-LOCK WHERE
               ub.dis-card.d-card = X_chk-doc.d-card No-ERROR.
    IF NOT AVAIL(dis-card) then dO:
        message "Не найдена запись о дисконтной карте N " X_chk-doc.d-card
        view-as alert-box ERROR.
        return no-apply.
    END.
    FIND FIRST ub.clients No-LOCK WHERE
               ub.clients.obj-type = ub.dis-card.cli-type AND
               ub.clients.obj-code = ub.dis-card.cli-code No-ERROR.
    IF NOT AVAIL(clients) then do:
        message "Не найдена запись о клиенте типа " ub.dis-card.cli-type
        " и кодом " ub.dis-card.cli-code
        view-as alert-box ERROR.
        return no-apply.
    END.
    run ref/showcli.p
    (input parparentproc
    ,input clients.obj-type /* p-obj-type */
    ,input clients.obj-code /* p-obj-code */
    ).
  END.
  ELSE do:
    message "Чек не привязан к клиенту!"
    view-as alert-box.
    return no-apply.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-doc Dialog-Frame
ON CHOOSE OF B-doc IN FRAME Dialog-Frame /* Накладная */
DO:
define variable next-prev as character no-undo .
define variable v-call-handle as handle no-undo .
define variable glog as logical no-undo .
define variable v-doc-rec as recid no-undo .
IF NOT AVAIL X_inkas then do:
    RETURN NO-APPLY.
END.
  assign
  next-prev = '':U
  .
  DO WHILE next-prev <> ?:
    if NOT available X_inkas then do:
            message "Неправильный выбор кассового отчета."
            view-as alert-box WARNING .
            return no-apply.
    end.
    define variable v-host-code as integer   no-undo .
    { gbl/hostcode.i
      p-obj-type
      p-obj-code
      v-host-code
    }
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_sale_lookup':U
      {&cntxt-object}
      v-host-code
      p-obj-type
      p-obj-code
      0
      0
      0
      true
      glog
    }

    if NOT glog then return no-apply.
    FIND FIRST ink-doc No-LOCK where
                                recid(ink-doc) = recid(X_inkas).
    assign
    v-doc-rec = recid( X_inkas ).
    v-call-handle = this-procedure:handle.
    run str/sale.w (
                  input parparentproc
                , input {&lookup}
                , input-output v-doc-rec
                , input-output v-call-handle
                , input-output next-prev
                , buffer ink-doc
                ).
  end.
  apply "entry" to br-parts in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Поиск */
DO:
  IF p-gds-rec = ? then do:
    Message "Не выбран товар!"
    view-as alert-box ERROR.
    return no-apply.
  end.
  assign
  sernum.
  IF trim(sernum) = "" then do:
    Message "Не введен серийный номер!"
    view-as alert-box ERROR.
    return no-apply.
  end.
  RUn OpenBr.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-gds Dialog-Frame
ON CHOOSE OF b-gds IN FRAME Dialog-Frame /* Товар */
DO:
  DEFINE VARIABLE rid-list as char no-undo.
  run ref/gds-ref.p (
                  input parparentproc
                  ,input "b-sel"
                  ,input ?                /*p-stat */
                  ,input ?                /*p-list  */
                  ,input ?                /*p-cond  */
                  ,input ?                /*p-rec   */
                  ,input ?                /*p-grp   */
                  ,input ?                /*p-cli-type */
                  ,input ?                /*p-cli-code  */
                  ,input p-obj-type       /*p-obj-type  */
                  ,input p-obj-code       /*p-obj-code  */
                  ,input ?                /*p-other     */
                  ,output rid-list ).
  if rid-list <> "" then do:
    FIND FIRST buf_goods No-LOCK WHERE
                recid(buf_goods) = integer(entry(1, rid-list)) NO-ERROR.
    IF NOT AVAIL buf_goods then do:
      message "Не найден товар!"
      view-as alert-box ERROR.
      return no-apply.
    END.
    assign
    p-gds-rec = recid(buf_goods).
    Run setGood in this-procedure no-error.
    If error-status:error then return no-apply.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-parts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-parts Dialog-Frame
ON CHOOSE OF B-parts IN FRAME Dialog-Frame /* Партия */
DO:
    IF NOT AVAIL temp-inparts then do:
      RETURN NO-APPLY.
    END.

    define buffer buf_trn-doc for ub.trn-doc .
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = ub.inkas.inkas-code
      no-error .
    if not available buf_trn-doc then do:
        message "Не найден документ " ub.inkas.inkas-code
          view-as alert-box error .
        return no-apply.
    end.

    /* определяем код расходной или возвратной накладной */
    define variable v-trn-doc-doc-code as character no-undo .
    if X_chk-doc.netto > 0 then do:
      assign
        v-trn-doc-doc-code = buf_trn-doc.doc-code
      .
    end.
    else do:
      assign
        v-trn-doc-doc-code = buf_trn-doc.out-code
      .
    end.

    FIND FIRST ub.doc-line no-lock where
               ub.doc-line.doc-code  = v-trn-doc-doc-code AND
               ub.doc-line.artic     = partic AND
               ub.doc-line.prod-type = pprod-type AND
               ub.doc-line.prod-code = pprod-code No-ERROR.
    IF NOT avail(ub.doc-line) then do:
        message "Не найдена строка документа " v-trn-doc-doc-code " для товара "
        gds-name
        view-as alert-box ERROR.
        return no-apply.
    END.
    run str/partsedt.p (input parparentproc,
                   buffer ub.doc-line,
                   input no /*l-update*/,
                   input no /*l-reserv*/,
                   input 0) no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
    if num-results( "br-parts" ) = 0 or num-results("br-parts")  = ?then do:
       return no-apply.
    end.

    define variable sym1 as char init ":"   no-undo.
    define variable sym2 as char init ":"   no-undo.
    define variable sym3 as char init ":"   no-undo.
    define variable sym4 as char init ":"   no-undo.
    define variable sym5 as char init ":"   no-undo.
    define variable sym6 as char init ":"   no-undo.
    define variable sym7 as char init ":"   no-undo.
    define variable sym8 as char init ":"   no-undo.
    define variable sym9 as char init ":"   no-undo.

    define variable Line as char no-undo.
    define variable obj-attr as char no-undo.

    define variable StartRecid as recid .

    define variable ii as int no-undo .

    def frame List
    sym1 column-label ":" format "X(1)"
    temp-inparts.part-code column-label "Партия" FORMAT "X(14)"
    sym2 column-label ":" format "X(1)"
    temp-inparts.b-code column-label "Бар-код  " FORMAT ">>>>>>>>>>>>9"
    sym4 column-label ":" format "X(1)"
    obj-attr COLUMN-LABEL "Объект" FORMAT "x(10)"
    sym5 column-label ":" format "X(1)"
    X_chk-doc.chk-date COLUMN-LABEL "Дата продажи" FORMAT "99/99/9999"
    sym6 column-label ":" format "X(1)"
    X_inkas.inkas-code COLUMN-LABEL "Накладная" FORMAT "X(12)"
    sym7 column-label ":" format "X(1)"
    X_chk-doc.doc-code column-label "Номер чека" FORMAT "X(12)"
    sym8 column-label ":" format "X(1)"
    X_chk-doc.chk-num COLUMN-LABEL "Чек по кассе" FORMAT ">>>>>>>>>>>9"
    sym9 column-label ":" format "X(1)"
    HEADER
      cur-time-print() AT 5 format "X(35)"
                        "Страница " AT 65 PAGE-NUMBER( PrnLibStream ) AT 75 FORMAT ">>9" SKIP
                    Line format "X(124)" AT 1
    with width {&A4_CW} down stream-io use-text .

    Line = fill( "-" , 140 ) .
    run waitfram-show in this-procedure ({&MyWaitMess} ) .
    StartRecid = recid( temp-inparts ) .
    GET FIRST br-parts .
    ii = 1 .

    run prn-lib-open-stream  in this-procedure (
                                                input parParentProc
                                                ,input {&CS_PS}
                                                ,input yes /*p-is-stream*/
                                                ,input no /*p-append*/
                                                ).


    FORM HEADER
                Line format "X(124)" SKIP
                "Продолжение - на следующей странице" AT 30 SKIP
                with FRAME CliBottomFrame width {&A4_CW} PAGE-BOTTOM NO-LABELS no-box.
    VIEW stream PrnLibStream FRAME CliBottomFrame .
    PUT stream PrnLibStream
    space(30)
    string( "С П И С О К   П А Р Т И Й   по серийному номеру  " + SerNum ) format "X(100)" SKIP
    space(30) buf_goods.gds-name SKIP(2) .
    FORM with frame List .
    DO WHILE available temp-inparts :
        DISPLAY stream PrnLibStream
        sym1 temp-inparts.part-code
        sym2 temp-inparts.b-code
        sym4 ( X_chk-doc.obj-type + " " + STRING( X_chk-doc.obj-code ) ) @ obj-attr
        sym5 X_chk-doc.chk-date
        sym6 X_inkas.inkas-code
        sym7 X_chk-doc.doc-code
        sym8 X_chk-doc.chk-num
        sym9     with frame List .
        DOWN stream PrnLibStream 1 with frame List .
            ii =  ii + 1 .
            if ( ( ii modulo 10 ) = 0 ) AND ( ii >= 10 ) then
               run waitfram-show in this-procedure ( "Просмотрено строк : " + string( ii ) ) .
            GET next br-parts .
    END.
    run waitfram-hide in this-procedure .
    PUT stream PrnLibStream
    Line format "X(124)" SKIP.
    HIDE stream PrnLibStream
    FRAME CliBottomFrame .
    output stream PrnLibStream close .
    run prn-lib-prn-file in this-procedure (
                                              input parParentProc
                                              ,input 0
                                              ).

    reposition br-parts to recid StartRecid .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME SerNum
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL SerNum Dialog-Frame
ON RETURN OF SerNum IN FRAME Dialog-Frame /* Серийный номер */
DO:
  APPLY "CHOOSE" to b-exit.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-parts
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

  IF p-gds-rec <> ? then do:
    FIND FIRST buf_goods No-LOCK where
               recid(buf_goods) = p-gds-rec NO-ERROR.
    IF NOT AVAIL buf_goods then return error.
    DISPLAY
    gds-name
    WITH FRAME {&FRAME-NAME}.
    run setGood in this-procedure no-error.
    If error-status:error then return error.
  END.
  RUN MYenable in this-procedure .
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
  DISPLAY SerNum gds-name
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-exit b-gds B-parts B-chk B-doc B-cli B-print B-Help SerNum
         BR-parts gds-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
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
  DISPLAY
  SerNum
  gds-name
  WITH FRAME Dialog-Frame.
  ENABLE
  B-exit
  b-quit
  b-gds when p-gds-rec = ?
  b-parts
  b-chk
  b-doc
  B-print
  B-Help
  b-cli
  SerNum
  BR-parts gds-name
  WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.

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
run waitfram-show in this-procedure ( {&MyWaitMess}).

/* показать все операции с товаром */

  for each temp-inparts
  :
    delete temp-inparts .
  end.

  define buffer buf_parts for ub.parts .


  FOR EACH buf_parts NO-LOCK WHERE
          buf_parts.artic     = partic AND
          buf_parts.prod-type = pprod-type AND
          buf_parts.prod-code = pprod-code AND
          buf_parts.obj-type  = p-obj-type AND
          buf_parts.obj-code  = p-obj-code AND
          buf_parts.out-code  <> {&free-code} AND
          buf_parts.out-code  <> {&output-code} and
          buf_parts.part-code = Sernum AND
          buf_parts.status_   = yes AND
          buf_parts.doc-type  <> {&act-overvalue} AND
          buf_parts.doc-type  <> {&income}
  :
    find first temp-inparts
      where temp-inparts.in-code   = buf_parts.in-code
        and temp-inparts.part-code = buf_parts.part-code
      no-error .
    if not available temp-inparts then do:
      create temp-inparts .
      assign
        temp-inparts.in-code   = buf_parts.in-code
        temp-inparts.part-code = buf_parts.part-code
      .

      define buffer buf_bar-code for ub.bar-code .
      find first buf_bar-code no-lock
        where buf_bar-code.gds-code  = pgds-code
          and buf_bar-code.unit-cli  = punit-base
          and buf_bar-code.part-code = temp-inparts.part-code
          and buf_bar-code.in-code   = temp-inparts.in-code
          and buf_bar-code.node-code = pnode-code
        no-error .
      if available buf_bar-code then do:
        assign
          temp-inparts.b-code = buf_bar-code.b-code
        .
      end.
    end.
  end.

  OPEN QUERY Br-parts
      FOR EACH temp-inparts,
          EACH X_chk-gds where
                X_chk-gds.b-code   = temp-inparts.b-code AND
                X_chk-gds.out-code <> ?,
          FIRST X_inkas NO-LOCK WHERE
                X_inkas.inkas-code = X_chk-gds.out-code AND
                X_inkas.status_    = {&fact},
          FIRST X_chk-doc No-LOCK WHERE
                X_chk-doc.doc-code = X_chk-gds.doc-code
                        .
run waitfram-hide in this-procedure .
apply "entry" to br-parts in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-chk-doc Dialog-Frame
PROCEDURE reposition-chk-doc :
define input  parameter p-direction   as character no-undo .
define output parameter p-chk-doc-recid as recid no-undo .

define variable v-parts-recid as recid no-undo .

  /* перемещение на первую, последнюю, предыдущую, следующую */
  case p-direction :
    when "first":U
    then do:
      get first br-parts.
    end.
    when "last":U
    then do:
      get last br-parts.
    end.
    when "prev":U
    then do:
      get prev br-parts.
      if not available temp-inparts then do:
        message
        "Это первый документ списка"
        view-as alert-box.
      end.
    end.
    when "next":U
    then do:
      get next br-parts.
      if not available temp-inparts then do:
        message
        "Это последний документ списка"
        view-as alert-box.
      end.
    end.
  end case . /* p-direction */
  assign
  p-chk-doc-recid = recid(X_chk-doc)
  v-parts-recid = recid(temp-inparts)
  .
  run reposition-query in this-procedure
    (input v-parts-recid
    ).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-inkas Dialog-Frame
PROCEDURE reposition-inkas :
define input  parameter p-direction   as character no-undo .
define output parameter p-inkas-recid as recid no-undo .

define variable v-parts-recid as recid no-undo .

  /* перемещение на первую, последнюю, предыдущую, следующую */
  case p-direction :
    when "first":U
    then do:
      get first br-parts.
    end.
    when "last":U
    then do:
      get last br-parts.
    end.
    when "prev":U
    then do:
      get prev br-parts.
      if not available temp-inparts then do:
        message
        "Это первый документ списка"
        view-as alert-box.
      end.
    end.
    when "next":U
    then do:
      get next br-parts.
      if not available temp-inparts then do:
        message
        "Это последний документ списка"
        view-as alert-box.
      end.
    end.
  end case . /* p-direction */
  assign
  p-inkas-recid = recid(X_inkas)
  v-parts-recid = recid(temp-inparts)
  .
  run reposition-query in this-procedure
    (input v-parts-recid
    ).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-query Dialog-Frame
PROCEDURE reposition-query :
define input parameter p-recid as recid no-undo .

  if p-recid <> ?
  then do:
    reposition br-parts to recid p-recid no-error.
  end.

  do with frame {&frame-name}:
    apply "entry":u to browse {&browse-name} .
  end. /* do with frame */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE SetGood Dialog-Frame
PROCEDURE SetGood :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer buf_units for ub.units .
define buffer buf_gds-prt for ub.gds-prt.
FIND FIRST buf_units No-LOCK WHERE
          buf_units.unit-name = buf_goods.unit-base No-ERROR.
IF NOT AVAIL buf_units then do:
    RETURN ERROR.
END.
IF LOOKUP({&serial}, buf_units.type) = 0 then do:
    message "Товар несерийный (неномерной)!"
    view-as alert-box WARNING.
    return error.
end.
ASSIGN
partic = buf_goods.artic
pprod-type = buf_goods.prod-type
pprod-code = buf_goods.prod-code
pgds-code = buf_goods.gds-code
punit-base = buf_goods.unit-base
.
FIND FIRST buf_gds-prt No-LOCK WHERE
         buf_gds-prt.upper-code = buf_goods.prt-root No-ERROR.
IF not avail buf_gds-prt then do:
    RETURN ERROR.
END.
assign
pnode-code = buf_gds-prt.node-code.
gds-name =  (buf_goods.artic + {&space-char} + buf_goods.prod-type + string(buf_goods.prod-code) +
              {&space-char} + buf_goods.gds-name).
DISPLAY
gds-name
WITH FRAME {&FRAME-NAME}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME