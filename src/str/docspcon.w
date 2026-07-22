/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Дополнительный экран просмотра в учете (разбивки по договорам)

Автор: Чернова Светлана Александровна
Дата создания: 11/20/06
Author: Svetlana Chernova
Creation date: 11/20/06

create: Булгаков Андрей Николаевич
Дата создания: 10/05/04


*/

/* ***************************  Definitions  ************************** */
/* Local Variable Definitions ---                                       */
DEFINE VARIABLE vss-revision    AS CHARACTER NO-UNDO INITIAL "$Revision$":U.
DEFINE VARIABLE vss-author      AS CHARACTER NO-UNDO INITIAL "$Author$":U.
DEFINE VARIABLE vss-date        AS CHARACTER NO-UNDO INITIAL "$Date$":U.
DEFINE VARIABLE vss-workfile    AS CHARACTER NO-UNDO INITIAL "$Workfile$":U.
DEFINE VARIABLE vss-archive     AS CHARACTER NO-UNDO INITIAL "$Archive$":U.
DEFINE VARIABLE vss-description AS CHARACTER NO-UNDO INITIAL "Дополнительный экран просмотра в учете (разбивки по договорам) ".

{ cmp/vssrevis.i }
{ str/d-supp.i   }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ gbl/tax-name.i }

DEFINE VARIABLE v_road-tax-label AS CHARACTER NO-UNDO.

/* ********************  Preprocessor Definitions  ******************** */
/* Name of first Frame and/or Browse and/or first Query                 */
&SCOP FRAME-NAME fr-D-SplitByContract-8

/* Definitions for BROWSE                                               */
&SCOP OPEN-QUERY-b-supp                OPEN QUERY b-supp                FOR EACH d-supp-fin.
&SCOP OPEN-QUERY-b-supp-grp            OPEN QUERY b-supp-grp            FOR EACH d-supp-grp-fin.
&SCOP OPEN-QUERY-b-supp-slts-vats-cons OPEN QUERY b-supp-slts-vats-cons FOR EACH d-supp-slts-vats-cons-fin.
&SCOP OPEN-QUERY-b-slts-vats-cons      OPEN QUERY b-slts-vats-cons      FOR EACH d-slts-vats-cons-fin.
&SCOP OPEN-QUERY-b-slts-vats-cons-grp  OPEN QUERY b-slts-vats-cons-grp  FOR EACH d-slts-vats-cons-grp-fin.
&SCOP OPEN-QUERY-b-slt-vat-cons        OPEN QUERY b-slt-vat-cons        FOR EACH d-slt-vat-cons-fin.
&SCOP OPEN-QUERY-b-slt-vat-cons-grp    OPEN QUERY b-slt-vat-cons-grp    FOR EACH d-slt-vat-cons-grp-fin.
&SCOP OPEN-QUERY-b-title               OPEN QUERY b-title               FOR EACH tt-title-fin.
&SCOP contract-field                   ~{&table}.contract-code COLUMN-LABEL "Договор"            FORMAT ">>>>>>>":U
&SCOP purchase-field                   ~{&table}.purch-name    COLUMN-LABEL "Тип приобр."        FORMAT "x(11)":U
&SCOP group-field                      ~{&table}.grp-name      COLUMN-LABEL "Группа товаров"     FORMAT "x(30)":U
&SCOP supplier-fields                  ~{&table}.supp-name     COLUMN-LABEL "Поставщик"          FORMAT "x(20)":U ~
                                       ~{&table}.supp-type     COLUMN-LABEL "Тип" ~
                                       ~{&table}.supp-code     COLUMN-LABEL "Код"
&SCOP tax-fields                       ~{&table}.vat-pc        COLUMN-LABEL "НДС" ~
                                       ~{&table}.slt-pc        COLUMN-LABEL "НП"
&SCOP common-fields                    ~{&table}.fact-qnty     COLUMN-LABEL "Факт. кол-во" ~
                                       ~{&table}.acc-base      COLUMN-LABEL "Учет. цены (вал)" ~
                                       ~{&table}.acc-rubl      COLUMN-LABEL "Учет. цены ({&abbr_rub})" ~
                                       ~{&table}.acc-vat-base  COLUMN-LABEL "НДС уч. цены (вал)" ~
                                       ~{&table}.acc-vat-rubl  COLUMN-LABEL "НДС уч. цены ({&abbr_rub})" ~
                                       ~{&table}.pay-base      COLUMN-LABEL "К оплате (вал)" ~
                                       ~{&table}.pay-rubl      COLUMN-LABEL "К оплате ({&abbr_rub})" ~
                                       ~{&table}.no-vat-base   COLUMN-LABEL "Без НДС (вал)" ~
                                       ~{&table}.no-vat-rubl   COLUMN-LABEL "Без НДС ({&abbr_rub})" ~
                                       ~{&table}.vat-base      COLUMN-LABEL "НДС (вал)" ~
                                       ~{&table}.vat-rubl      COLUMN-LABEL "НДС ({&abbr_rub})" ~
                                       ~{&table}.slt-base      COLUMN-LABEL "НП (вал)" ~
                                       ~{&table}.slt-rubl      COLUMN-LABEL "НП ({&abbr_rub})" ~
                                       ~{&table}.sale-base     COLUMN-LABEL "Продаж.цены" ~
                                       ~{&table}.ov-base       COLUMN-LABEL "Переоценка" ~
                                       ~{&table}.ov-vat        COLUMN-LABEL "НДС по переоценке" ~
                                       ~{&table}.road-tax ~
                                       ~{&table}.excise        COLUMN-LABEL "Акциз"

/* ***********************  Control Definitions  ********************** */
/* Definitions of the field level widgets                               */
DEFINE BUTTON   Btn_Exit  LABEL "Вы&ход " SIZE-CHARS 10.00 BY 1.00 DEFAULT AUTO-GO.
DEFINE BUTTON b-help LABEL "Помо&щь" SIZE-CHARS 10.00 BY 1.00 DEFAULT.

DEFINE VARIABLE table-type AS INTEGER NO-UNDO VIEW-AS RADIO-SET HORIZONTAL RADIO-BUTTONS
  "&Поставщики",          1,
  "&НДС и НП",            2,
  "Н&ДС и НП поставщика", 3,
  "Поставщики &и НДС-НП", 4,
  "Тип приобретени&я",    5  SIZE-CHARS 98.75 BY 1.00 INITIAL 1.

/* Query definitions                                                    */
DEFINE QUERY b-supp                FOR d-supp-fin                SCROLLING.
DEFINE QUERY b-supp-grp            FOR d-supp-grp-fin            SCROLLING.
DEFINE QUERY b-supp-slts-vats-cons FOR d-supp-slts-vats-cons-fin SCROLLING.
DEFINE QUERY b-slts-vats-cons      FOR d-slts-vats-cons-fin      SCROLLING.
DEFINE QUERY b-slts-vats-cons-grp  FOR d-slts-vats-cons-grp-fin  SCROLLING.
DEFINE QUERY b-slt-vat-cons        FOR d-slt-vat-cons-fin        SCROLLING.
DEFINE QUERY b-slt-vat-cons-grp    FOR d-slt-vat-cons-grp-fin    SCROLLING.
DEFINE QUERY b-title               FOR tt-title-fin              SCROLLING.

/* Browse definitions                                                   */
&SCOP table d-supp-fin
DEFINE BROWSE b-supp QUERY b-supp DISPLAY
  {&contract-field}
  {&supplier-fields}
  {&purchase-field}
  {&common-fields}
WITH NO-ROW-MARKERS SEPARATORS SIZE-CHARS 98.75 BY 10.50
     TITLE "Поставщик-Тип приобретения".

&SCOP table d-supp-grp-fin
DEFINE BROWSE b-supp-grp QUERY b-supp-grp DISPLAY
  {&contract-field}
  {&supplier-fields}
  {&purchase-field}
  {&group-field}
  {&common-fields}
WITH NO-ROW-MARKERS SEPARATORS SIZE-CHARS 98.75 BY 10.50
     TITLE "Поставщик-Тип приобретения-Группа товаров".

&SCOP table d-supp-slts-vats-cons-fin
DEFINE BROWSE b-supp-slts-vats-cons QUERY b-supp-slts-vats-cons DISPLAY
  {&contract-field}
  {&supplier-fields}
  {&tax-fields}
  {&purchase-field}
  {&common-fields}
WITH NO-ROW-MARKERS SEPARATORS SIZE-CHARS 98.75 BY 21.20
     TITLE "Поставщик-НДС поставщика-НП поставщика-Тип приобретения".

&SCOP table d-slts-vats-cons-fin
DEFINE BROWSE b-slts-vats-cons QUERY b-slts-vats-cons DISPLAY
  {&contract-field}
  {&tax-fields}
  {&purchase-field}
  {&common-fields}
WITH NO-ROW-MARKERS SEPARATORS SIZE-CHARS 98.75 BY 10.50
     TITLE "НДС поставщика-НП поставщика-Тип приобретения".

&SCOP table d-slts-vats-cons-grp-fin
DEFINE BROWSE b-slts-vats-cons-grp QUERY b-slts-vats-cons-grp DISPLAY
  {&contract-field}
  {&tax-fields}
  {&purchase-field}
  {&group-field}
  {&common-fields}
WITH NO-ROW-MARKERS SEPARATORS SIZE-CHARS 98.75 BY 10.50
     TITLE "НДС поставщика-НП поставщика-Тип приобретения-Группа товаров".

&SCOP table d-slt-vat-cons-fin
DEFINE BROWSE b-slt-vat-cons QUERY b-slt-vat-cons DISPLAY
  {&contract-field}
  {&tax-fields}
  {&purchase-field}
  {&common-fields}
WITH NO-ROW-MARKERS SEPARATORS SIZE-CHARS 98.75 BY 10.50
     TITLE "НДС документа-НП документа-Тип приобретения".

&SCOP table d-slt-vat-cons-grp-fin
DEFINE BROWSE b-slt-vat-cons-grp QUERY b-slt-vat-cons-grp DISPLAY
  {&contract-field}
  {&tax-fields}
  {&purchase-field}
  {&group-field}
  {&common-fields}
WITH NO-ROW-MARKERS SEPARATORS SIZE-CHARS 98.75 BY 10.50
     TITLE "НДС документа-НП документа-Тип приобретения-Группа товаров".

&SCOP table tt-title-fin
DEFINE BROWSE b-title QUERY b-title DISPLAY
  {&contract-field}
  {&purchase-field}
  {&common-fields}
WITH NO-ROW-MARKERS SEPARATORS SIZE-CHARS 98.75 BY 21.20
     TITLE "Тип приобретения".

/* ************************  Frame Definitions  *********************** */
DEFINE FRAME {&FRAME-NAME}
    Btn_Exit            AT ROW  1.00 COL  1.00
  b-help           AT ROW  1.00 COL 11.00
  table-type            AT ROW  2.20 COL  1.00 NO-LABEL
  b-supp                AT ROW  3.40 COL  1.00
  b-supp-grp            AT ROW 14.10 COL  1.00
  b-slts-vats-cons      AT ROW  3.40 COL  1.00
  b-slts-vats-cons-grp  AT ROW 14.10 COL  1.00
  b-slt-vat-cons        AT ROW  3.40 COL  1.00
  b-slt-vat-cons-grp    AT ROW 14.10 COL  1.00
  b-title               AT ROW  3.40 COL  1.00
  b-supp-slts-vats-cons AT ROW  3.40 COL  1.00 SKIP( 0.12 )
WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER SIDE-LABELS NO-UNDERLINE THREE-D SCROLLABLE
     TITLE "УЧЕТ (Договоры)" DEFAULT-BUTTON Btn_Exit.

/* ***********  Runtime Attributes and AppBuilder Settings  *********** */
ASSIGN FRAME {&FRAME-NAME} :SCROLLABLE = NO.
ASSIGN b-supp                :NUM-LOCKED-COLUMNS IN FRAME {&FRAME-NAME} = 5
       b-supp-grp            :NUM-LOCKED-COLUMNS IN FRAME {&FRAME-NAME} = 5
       b-supp-slts-vats-cons :NUM-LOCKED-COLUMNS IN FRAME {&FRAME-NAME} = 6
       b-slts-vats-cons      :NUM-LOCKED-COLUMNS IN FRAME {&FRAME-NAME} = 4
       b-slts-vats-cons-grp  :NUM-LOCKED-COLUMNS IN FRAME {&FRAME-NAME} = 4
       b-slt-vat-cons        :NUM-LOCKED-COLUMNS IN FRAME {&FRAME-NAME} = 4
       b-slt-vat-cons-grp    :NUM-LOCKED-COLUMNS IN FRAME {&FRAME-NAME} = 4
       b-title               :NUM-LOCKED-COLUMNS IN FRAME {&FRAME-NAME} = 2.

/* ************************  Control Triggers  ************************ */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} DO: APPLY "END-ERROR":U TO SELF. END.

ON VALUE-CHANGED OF table-type IN FRAME {&FRAME-NAME} DO:
  ASSIGN table-type.
  CASE table-type :
    WHEN 1 THEN DO: /* Поставщики */
      DISABLE b-supp-slts-vats-cons b-slts-vats-cons b-slts-vats-cons-grp b-slt-vat-cons
              b-slt-vat-cons-grp    b-title
      WITH FRAME {&FRAME-NAME}.
      ASSIGN  b-supp-slts-vats-cons :VISIBLE IN FRAME {&FRAME-NAME} = NO
              b-slts-vats-cons      :VISIBLE IN FRAME {&FRAME-NAME} = NO
              b-slts-vats-cons-grp  :VISIBLE IN FRAME {&FRAME-NAME} = NO
              b-slt-vat-cons        :VISIBLE IN FRAME {&FRAME-NAME} = NO
              b-slt-vat-cons-grp    :VISIBLE IN FRAME {&FRAME-NAME} = NO
              b-title               :VISIBLE IN FRAME {&FRAME-NAME} = NO
              b-supp                :VISIBLE IN FRAME {&FRAME-NAME} = YES
              b-supp-grp            :VISIBLE IN FRAME {&FRAME-NAME} = YES.
      ENABLE  b-supp b-supp-grp WITH FRAME {&FRAME-NAME}.
      {&OPEN-QUERY-b-supp}
      {&OPEN-QUERY-b-supp-grp}
      APPLY "ENTRY":U TO b-supp IN FRAME {&FRAME-NAME}.
    END. /* Поставщики */
    WHEN 2 THEN DO: /* НДС и НсП */
      DISABLE b-supp-slts-vats-cons b-slts-vats-cons b-slts-vats-cons-grp b-supp
              b-supp-grp            b-title
      WITH FRAME {&FRAME-NAME}.
      ASSIGN  b-supp-slts-vats-cons :VISIBLE IN FRAME {&FRAME-NAME} = NO
              b-slts-vats-cons      :VISIBLE IN FRAME {&FRAME-NAME} = NO
              b-slts-vats-cons-grp  :VISIBLE IN FRAME {&FRAME-NAME} = NO
              b-slt-vat-cons        :VISIBLE IN FRAME {&FRAME-NAME} = YES
              b-slt-vat-cons-grp    :VISIBLE IN FRAME {&FRAME-NAME} = YES
              b-title               :VISIBLE IN FRAME {&FRAME-NAME} = NO
              b-supp                :VISIBLE IN FRAME {&FRAME-NAME} = NO
              b-supp-grp            :VISIBLE IN FRAME {&FRAME-NAME} = NO.
      ENABLE  b-slt-vat-cons b-slt-vat-cons-grp WITH FRAME {&FRAME-NAME}.
      {&OPEN-QUERY-b-slt-vat-cons}
      {&OPEN-QUERY-b-slt-vat-cons-grp}
      APPLY "ENTRY":U TO b-slt-vat-cons IN FRAME {&FRAME-NAME}.
    END. /* НДС и НсП */
    WHEN 3 THEN DO: /* НДС и НсП поставщика */
      DISABLE b-supp-slts-vats-cons b-slt-vat-cons b-slt-vat-cons-grp b-supp
              b-supp-grp            b-title
      WITH FRAME {&FRAME-NAME}.
      ASSIGN  b-supp-slts-vats-cons :VISIBLE IN FRAME {&FRAME-NAME} = NO
              b-slts-vats-cons      :VISIBLE IN FRAME {&FRAME-NAME} = YES
              b-slts-vats-cons-grp  :VISIBLE IN FRAME {&FRAME-NAME} = YES
              b-slt-vat-cons        :VISIBLE IN FRAME {&FRAME-NAME} = NO
              b-slt-vat-cons-grp    :VISIBLE IN FRAME {&FRAME-NAME} = NO
              b-title               :VISIBLE IN FRAME {&FRAME-NAME} = NO
              b-supp                :VISIBLE IN FRAME {&FRAME-NAME} = NO
              b-supp-grp            :VISIBLE IN FRAME {&FRAME-NAME} = NO.
      ENABLE  b-slts-vats-cons b-slts-vats-cons-grp WITH FRAME {&FRAME-NAME}.
      {&OPEN-QUERY-b-slts-vats-cons}
      {&OPEN-QUERY-b-slts-vats-cons-grp}
      APPLY "ENTRY":U TO b-slts-vats-cons IN FRAME {&FRAME-NAME}.
    END. /* НДС и НсП поставщика */
    WHEN 4 THEN DO: /* Поставщики и НДС-НсП */
      DISABLE b-slt-vat-cons   b-slt-vat-cons-grp   b-supp b-supp-grp b-title
              b-slts-vats-cons b-slts-vats-cons-grp
      WITH FRAME {&FRAME-NAME}.
      ASSIGN  b-supp-slts-vats-cons :VISIBLE IN FRAME {&FRAME-NAME} = YES
              b-slts-vats-cons      :VISIBLE IN FRAME {&FRAME-NAME} = NO
              b-slts-vats-cons-grp  :VISIBLE IN FRAME {&FRAME-NAME} = NO
              b-slt-vat-cons        :VISIBLE IN FRAME {&FRAME-NAME} = NO
              b-slt-vat-cons-grp    :VISIBLE IN FRAME {&FRAME-NAME} = NO
              b-title               :VISIBLE IN FRAME {&FRAME-NAME} = NO
              b-supp                :VISIBLE IN FRAME {&FRAME-NAME} = NO
              b-supp-grp            :VISIBLE IN FRAME {&FRAME-NAME} = NO.
      ENABLE  b-supp-slts-vats-cons WITH FRAME {&FRAME-NAME}.
      {&OPEN-QUERY-b-supp-slts-vats-cons}
      APPLY "ENTRY":U TO b-supp-slts-vats-cons IN FRAME {&FRAME-NAME}.
    END. /* Поставщики и НДС-НсП */
    WHEN 5 THEN DO: /* Тип приобретения */
      DISABLE b-slt-vat-cons   b-slt-vat-cons-grp   b-supp b-supp-grp
              b-slts-vats-cons b-slts-vats-cons-grp b-supp-slts-vats-cons
      WITH FRAME {&FRAME-NAME}.
      ASSIGN  b-supp-slts-vats-cons :VISIBLE IN FRAME {&FRAME-NAME} = NO
              b-slts-vats-cons      :VISIBLE IN FRAME {&FRAME-NAME} = NO
              b-slts-vats-cons-grp  :VISIBLE IN FRAME {&FRAME-NAME} = NO
              b-slt-vat-cons        :VISIBLE IN FRAME {&FRAME-NAME} = NO
              b-slt-vat-cons-grp    :VISIBLE IN FRAME {&FRAME-NAME} = NO
              b-title               :VISIBLE IN FRAME {&FRAME-NAME} = YES
              b-supp                :VISIBLE IN FRAME {&FRAME-NAME} = NO
              b-supp-grp            :VISIBLE IN FRAME {&FRAME-NAME} = NO.
      ENABLE  b-title WITH FRAME {&FRAME-NAME}.
      {&OPEN-QUERY-b-title}
      APPLY "ENTRY":U TO b-title IN FRAME {&FRAME-NAME}.
    END. /* Тип приобретения */
  END CASE. /* table-type */
END.

{ gbl/hot-key.i b-help }

/* ***************************  Main Block  *************************** */
/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE( ACTIVE-WINDOW ) AND FRAME {&FRAME-NAME} :PARENT = ? THEN FRAME {&FRAME-NAME} :PARENT = ACTIVE-WINDOW.

/* Restore the current-window if it is an icon. Otherwise the dialog box will be hidden */
IF CURRENT-WINDOW :WINDOW-STATE = WINDOW-MINIMIZED THEN DO: CURRENT-WINDOW :WINDOW-STATE = WINDOW-NORMAL. END.

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} DO: APPLY "END-ERROR":U TO SELF. END.

{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
Main-Block:
DO ON ERROR   UNDO Main-Block, LEAVE Main-Block
   ON END-KEY UNDO Main-Block, LEAVE Main-Block :
  RUN tax-name IN THIS-PROCEDURE ( INPUT {&road-tax}, OUTPUT v_road-tax-label ) NO-ERROR.
  ASSIGN d-slts-vats-cons-fin.road-tax      :LABEL IN BROWSE b-slts-vats-cons      = v_road-tax-label
         d-slts-vats-cons-grp-fin.road-tax  :LABEL IN BROWSE b-slts-vats-cons-grp  = v_road-tax-label
         d-supp-slts-vats-cons-fin.road-tax :LABEL IN BROWSE b-supp-slts-vats-cons = v_road-tax-label
         d-slt-vat-cons-grp-fin.road-tax    :LABEL IN BROWSE b-slt-vat-cons-grp    = v_road-tax-label
         d-slt-vat-cons-fin.road-tax        :LABEL IN BROWSE b-slt-vat-cons        = v_road-tax-label
         tt-title-fin.road-tax              :LABEL IN BROWSE b-title               = v_road-tax-label
         d-supp-fin.road-tax                :LABEL IN BROWSE b-supp                = v_road-tax-label
         d-supp-grp-fin.road-tax            :LABEL IN BROWSE b-supp-grp            = v_road-tax-label.

  DISPLAY                      table-type WITH FRAME {&FRAME-NAME}.
  ENABLE  Btn_Exit b-help table-type WITH FRAME {&FRAME-NAME}.
  APPLY   "VALUE-CHANGED":U TO table-type   IN FRAME {&FRAME-NAME}.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END. /* Main-Block */
HIDE FRAME {&FRAME-NAME} NO-PAUSE.