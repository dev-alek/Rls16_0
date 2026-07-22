&Scoped-define WINDOW-NAME    d-inv-prt
&Scoped-define FRAME-NAME     d-inv-prt
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Корректировка строки в Инвентаризации для признака

Автор: Чернова Светлана Александровна
Дата создания: 11/02/06
Author: Svetlana Chernova
Creation date: 11/02/06

Указание факт кол-ва на складе (в магазине) для терм. признака - пересорт, либо корн. признака - инвентаризаци

Create: Суслов Алексей Юрьевич


______________________________________________________________________________________________________________
|                                                  |                              |                          |
|    Было                                          |    Стало                     |    Разница               |
|__________________________________________________|______________________________|__________________________|
|                                                  |                              |                          |
|    doc-line.doc-qnty - doc-line.fact-qnty        |    doc-line.doc-qnty         |    doc-line.fact-qnty    |
|__________________________________________________|______________________________|__________________________|
|                                                  |                              |                          |
|    gds-dtl.fact-qnty - gds-dtl.doc-qnty          |    gds-dtl.fact-qnty         |    gds-dtl.doc-qnty      |
|__________________________________________________|______________________________|__________________________|
|                                                  |                              |                          |
|    inv-line.wast-cli-qnty - doc-line.cli-qnty    |    inv-line.wast-cli-qnty    |    doc-line.cli-qnty     | кг
|  = inv-line.before-cli-qnty                      |  = inv-line.after-cli-qnty   |                          |
|__________________________________________________|______________________________|__________________________|
|                                                  |    doc-line.doc-density      |                          | плотность
|                                                  |  = doc-line.fact-density     |                          |
|__________________________________________________|______________________________|__________________________|

*/

/* ***************************  Definitions  ************************** */
define input parameter parparentproc as widget-handle no-undo.
define input parameter doc-rec       as recid         no-undo.
define input parameter line-rec      as recid         no-undo.
define input parameter gds-rec       as recid         no-undo.
define input parameter prt-mode      as character     no-undo.
define input parameter cur-rec       as recid         no-undo.
define input parameter node-type     as character     no-undo.

define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "указание факт кол-ва на складе (в магазине) для терм. признака - пересорт, либо корн. признака - инвентаризаци":U.

{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/library.i      }
{ cmp/showinf.i      }
{ gbl/getcntxt.i def }
{ str/lib-trn.i      }
{ str/valddnst.i def }
{ trg/prdoclib.i     }
{ trg/factord.i      }

define variable g#host-name    as character no-undo .
define variable g#host-code    as integer   no-undo .
define variable store-type     as character no-undo .
define variable store-code     as integer   no-undo .
define variable g#log          as logical   no-undo .
define variable g#report-num   as integer   no-undo .
define variable base-code      as integer   no-undo .
define variable g#type         as character no-undo .
define variable prt-rec        as recid     no-undo .
define variable v-fact-order   as decimal   no-undo .
define variable v-fact-order-day1 as date   no-undo .
define variable v-inv_peresort as decimal   no-undo .
define variable v-inv-prsr     as character no-undo .
define variable v-single-place as logical   no-undo .

{ gbl/getcntxt.i get }
assign
  store-type    = v-cntxt-obj-type
  store-code    = v-cntxt-obj-code
.
{ gbl/hostname.i store-type store-code  g#host-code g#host-name }
run get-report-num  in parParentProc ( output g#report-num ).
{ gbl/basecode.i g#host-code base-code }

define variable old-val        like ub.gds-dtl.fact-qnty no-undo.
define variable varnew_gds-dtl as   logical              no-undo.
define variable varr-b         as   character            no-undo.
define variable is-petrol      as   logical              no-undo initial no.
define variable is-pieces      as   logical              no-undo initial no.
define variable v-is-ptrl      as   character            no-undo initial "":U.
define variable v-data-type    as   character            no-undo initial "":U.
define variable r-petrol-rec   as   recid                no-undo initial ?.

{ str/get-pr.i   def    }
{ gbl/curr-r-b.i varr-b }
{ gbl/ptrlprop.i  def    }

define new shared temp-table tt-doc-pl no-undo
field pl-code as integer format "99999999999"
field pl-code2 as integer format "99999999999"
field whole-send-news like ub.doc-pl.whole-send-news
field obj-type like ub.doc-pl.obj-type
field obj-code like ub.doc-pl.obj-code
field out-code like ub.doc-pl.out-code
field fact-qnty like ub.doc-pl.fact-qnty
field doc-qnty like ub.doc-pl.doc-qnty
field gds-code as integer format "99999999999"
field cli-qnty like ub.doc-pl.cli-qnty
field cli-fact-qnty like ub.doc-pl.cli-fact-qnty
field cli-doc-qnty like ub.doc-pl.cli-doc-qnty
field rest-af-qnty like ub.doc-pl.rest-af-qnty
field cli-rest-af-qnty like ub.doc-pl.cli-rest-af-qnty
field rest-bf-qnty like ub.doc-pl.rest-bf-qnty
field cli-rest-bf-qnty like ub.doc-pl.cli-rest-bf-qnty
index pi obj-type obj-code pl-code out-code gds-code
index doc out-code gds-code obj-code obj-type pl-code
index gds-code gds-code
.

define buffer b-c-b for ub.bar-code.

/* ***********************  Control Definitions  ********************** */
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1.

DEFINE BUTTON b-alcmark
     LABEL "&АлкМарк"
     SIZE 10 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 8.75 BY 1.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 75.50 BY 5.50
     BGCOLOR 8 .

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 63.00 BY 3.00
     BGCOLOR 8 .

/* ************************  Frame Definitions  *********************** */
DEFINE FRAME {&FRAME-NAME}
  b-exit                    AT ROW  1 COL  2.00
  b-alcmark                 AT ROW  2 COL  2.00
  b-help                    AT ROW  1 COL  2.00
  ub.doc-line.artic         AT ROW  2.00 COL 19.00 COLON-ALIGNED NO-LABEL VIEW-AS FILL-IN SIZE-CHARS 11.63 BY 1.00
  ub.goods.gds-name         AT ROW  2.00 COL 32.00 COLON-ALIGNED NO-LABEL VIEW-AS FILL-IN SIZE-CHARS 41.00 BY 1.00 FGCOLOR 4
  ub.doc-line.prod-code     AT ROW  3.00 COL 12.00 COLON-ALIGNED NO-LABEL VIEW-AS FILL-IN SIZE-CHARS  6.00 BY 1.00
  ub.doc-line.prod-type     AT ROW  3.00 COL 19.00 COLON-ALIGNED NO-LABEL VIEW-AS FILL-IN SIZE-CHARS 11.63 BY 1.00
  ub.clients.obj-name       AT ROW  3.00 COL 32.00 COLON-ALIGNED NO-LABEL VIEW-AS FILL-IN SIZE-CHARS 41.00 BY 1.00 FGCOLOR 4
  ub.doc-line.fact-qnty     AT ROW  5.00 COL 48.00 COLON-ALIGNED    LABEL "Разница по товару"
                                                                          VIEW-AS FILL-IN SIZE-CHARS 14.00 BY 1.00
  b-c-b.b-code              AT ROW  6.00 COL 20.00 COLON-ALIGNED    LABEL "Бар-код"
                                                                          VIEW-AS FILL-IN SIZE-CHARS 10.00 BY 1.00 FGCOLOR 4
  ub.gds-prt.f-name         AT ROW  6.00 COL 33.00 COLON-ALIGNED NO-LABEL VIEW-AS FILL-IN SIZE-CHARS 25.00 BY 1.00 FGCOLOR 4
  ub.gds-dtl.fact-qnty      AT ROW  7.50 COL 14.00 COLON-ALIGNED    LABEL "Стало"
                                                                          VIEW-AS FILL-IN SIZE-CHARS 16.00 BY 1.00
  ub.goods.unit-base        AT ROW  7.50 COL 32.50 COLON-ALIGNED NO-LABEL VIEW-AS FILL-IN SIZE-CHARS  8.00 BY 1.00
  ub.gds-dtl.doc-qnty       AT ROW  7.50 COL 50.00 COLON-ALIGNED    LABEL "Разница"
                                                                          VIEW-AS FILL-IN SIZE-CHARS 16.00 BY 1.00
  v-inv_peresort            AT ROW  8.50 COL 15.00 COLON-ALIGNED    LABEL "&Пересортица" FORMAT "->>>>>>>>>>9.<<<"
                                                                          VIEW-AS FILL-IN SIZE-CHARS 16.00 BY 1.00
  ub.doc-line.doc-density   AT ROW  8.75 COL 14.00 COLON-ALIGNED    LABEL "Плотность" FORMAT ">>9.9999999999":U
                                                                          VIEW-AS FILL-IN SIZE-CHARS 16.00 BY 1.00 FGCOLOR 4
  ub.goods.unit-cli         AT ROW 10.00 COL 32.50 COLON-ALIGNED NO-LABEL VIEW-AS FILL-IN SIZE-CHARS  8.00 BY 1.00
  ub.inv-line.wast-cli-qnty AT ROW 10.00 COL 14.00 COLON-ALIGNED    LABEL "Стало"
                                                                          VIEW-AS FILL-IN SIZE-CHARS 16.00 BY 1.00
  ub.doc-line.cli-qnty      AT ROW 10.00 COL 48.00 COLON-ALIGNED    LABEL "Разница"
                                                                          VIEW-AS FILL-IN SIZE-CHARS 16.00 BY 1.00
  RECT-2                    AT ROW  1.50 COL 13.00
  RECT-1                    AT ROW  6.50 COL  1.50 SPACE( 0.58 )    SKIP( 0.54 )
WITH VIEW-AS DIALOG-BOX SIDE-LABELS THREE-D SCROLLABLE DEFAULT-BUTTON b-exit.

/* ***************  Runtime Attributes and UIB Settings  ************** */
ASSIGN FRAME {&FRAME-NAME} :SCROLLABLE = NO.

/* ************************  Control Triggers  ************************ */

ON CHOOSE OF b-exit IN FRAME {&FRAME-NAME} /* выход */
DO:
  { gbl/stdbtn.i }
  IF prt-mode <> {&lookup} THEN DO:
    IF ub.gds-dtl.doc-qnty       :SENSITIVE        IN FRAME {&FRAME-NAME} THEN DO:
      FIND FIRST ub.units NO-LOCK WHERE ub.units.unit-name = ub.goods.unit-base.
      IF LOOKUP( {&pieces}, ub.units.type ) > 0 AND
                  INPUT FRAME {&FRAME-NAME} ub.gds-dtl.doc-qnty - ub.gds-dtl.doc-qnty + ub.gds-dtl.fact-qnty      <>
        TRUNCATE( INPUT FRAME {&FRAME-NAME} ub.gds-dtl.doc-qnty - ub.gds-dtl.doc-qnty + ub.gds-dtl.fact-qnty, 0 ) THEN DO:
        MESSAGE "Данная разница выведет штучный товар в нецелое количество!" VIEW-AS ALERT-BOX ERROR.
        APPLY "ENTRY":U TO ub.gds-dtl.doc-qnty       IN FRAME {&FRAME-NAME}.
        RETURN NO-APPLY.
      END.
    END.
    IF ub.gds-dtl.fact-qnty      :SENSITIVE        IN FRAME {&FRAME-NAME} THEN DO:
      IF INPUT FRAME {&FRAME-NAME} ub.gds-dtl.fact-qnty < 0 THEN DO:
        MESSAGE "Отрицательного количества товара не бывает !" VIEW-AS ALERT-BOX ERROR.
        APPLY "ENTRY":U TO ub.gds-dtl.fact-qnty      IN FRAME {&FRAME-NAME}.
        RETURN NO-APPLY.
      END.
      FIND FIRST ub.units NO-LOCK WHERE ub.units.unit-name = ub.goods.unit-base.
      IF LOOKUP( {&pieces}, ub.units.type ) > 0 AND
                   INPUT FRAME {&FRAME-NAME} ub.gds-dtl.fact-qnty      <>
         TRUNCATE( INPUT FRAME {&FRAME-NAME} ub.gds-dtl.fact-qnty, 0 ) THEN DO:
        MESSAGE "Нельзя вводить дробное количество для штучного товара!" VIEW-AS ALERT-BOX ERROR.
        APPLY "ENTRY":U TO ub.gds-dtl.fact-qnty      IN FRAME {&FRAME-NAME}.
        RETURN NO-APPLY.
      END.
    END.
    IF ub.inv-line.wast-cli-qnty :SENSITIVE        IN FRAME {&FRAME-NAME} THEN DO:
      IF INPUT FRAME {&FRAME-NAME} ub.inv-line.wast-cli-qnty < 0 THEN DO:
        MESSAGE "Отрицательного количества товара не бывает !" VIEW-AS ALERT-BOX ERROR.
        APPLY "ENTRY":U TO ub.inv-line.wast-cli-qnty IN FRAME {&FRAME-NAME}.
        RETURN NO-APPLY.
      END.
    END.
    IF ub.doc-line.doc-density       :SENSITIVE        IN FRAME {&FRAME-NAME} THEN DO:
      if valid-density( INPUT FRAME {&FRAME-NAME} ub.doc-line.doc-density, (ub.goods.unit-base = ub.goods.unit-cli) ) <> true then do:
        MESSAGE "Внимание!" SKIP
                "Неверное значение плотности для топлива:" INPUT FRAME {&FRAME-NAME} ub.doc-line.doc-density "." SKIP
                "Плотность топлива должна быть в диапазоне: больше 0 и меньше 1."
        VIEW-AS ALERT-BOX ERROR TITLE " О Ш И Б К А ! ! ! ".
        APPLY "ENTRY":U TO ub.doc-line.doc-density     IN FRAME {&FRAME-NAME}.
        RETURN NO-APPLY.
      END. /* density */
    END.
    assign
      ub.doc-line.doc-density
      ub.doc-line.cli-qnty
    .
    if ub.inv-line.wast-cli-qnty :sensitive in frame {&frame-name} then do:
      assign
        ub.inv-line.wast-cli-qnty
      .
    end.
    assign
      ub.doc-line.fact-density = ub.doc-line.doc-density
    .
    /* Пересортица */
    if v-inv-prsr = "yes" then  do:
      assign frame {&frame-name}  v-inv_peresort .
      ub.doc-line.inv-peresort = v-inv_peresort  .
    end.
  END.
END.

on leave of b-alcmark IN FRAME {&FRAME-NAME}  /* АлкМарк */
do:

  

end.

on leave of v-inv_peresort IN FRAME {&FRAME-NAME}  /* Стало */
do:
  assign frame {&frame-name}  v-inv_peresort.
  if prt-mode = {&prt-def} then do:
      if (ub.doc-line.doc-qnty ) < v-inv_peresort then do:
        message "Значение по пересортице должно быть меньше " ub.doc-line.doc-qnty view-as alert-box information .
        return no-apply .
      end.
  end.
  else do:
  if (INPUT FRAME {&FRAME-NAME} ub.gds-dtl.fact-qnty ) < v-inv_peresort then do:
    message "Значение по пересортице должно быть меньше " (INPUT FRAME {&FRAME-NAME} ub.gds-dtl.fact-qnty) view-as alert-box information .
    return no-apply .
  end.
  end.
end.

ON LEAVE OF ub.gds-dtl.doc-qnty IN FRAME {&FRAME-NAME} /* Разница */
DO:
  FIND FIRST ub.units NO-LOCK WHERE ub.units.unit-name = ub.goods.unit-base.
  IF LOOKUP( {&pieces}, ub.units.type ) > 0 AND
               INPUT FRAME {&FRAME-NAME} ub.gds-dtl.doc-qnty - ub.gds-dtl.doc-qnty + ub.gds-dtl.fact-qnty      <>
     TRUNCATE( INPUT FRAME {&FRAME-NAME} ub.gds-dtl.doc-qnty - ub.gds-dtl.doc-qnty + ub.gds-dtl.fact-qnty, 0 ) THEN DO:
    MESSAGE "Данная разница выведет штучный товар в нецелое количество!" VIEW-AS ALERT-BOX ERROR.
    RETURN NO-APPLY.
  END.
END.

ON LEAVE OF ub.gds-dtl.fact-qnty IN FRAME {&FRAME-NAME} /* {&fact} */
DO:
  IF INPUT FRAME {&FRAME-NAME} ub.gds-dtl.fact-qnty < 0 THEN DO:
    MESSAGE "Отрицательного количества товара не бывает !" VIEW-AS ALERT-BOX ERROR.
    RETURN NO-APPLY.
  END.
  FIND FIRST ub.units NO-LOCK WHERE ub.units.unit-name = ub.goods.unit-base.
  IF LOOKUP( {&pieces}, ub.units.type ) > 0 AND
     INPUT FRAME {&FRAME-NAME} ub.gds-dtl.fact-qnty <> TRUNCATE( INPUT FRAME {&FRAME-NAME} ub.gds-dtl.fact-qnty, 0 )
  THEN DO:
    MESSAGE "Нельзя вводить дробное количество для штучного товара!" VIEW-AS ALERT-BOX ERROR.
    RETURN NO-APPLY.
  END.
  DISPLAY
    ( INPUT FRAME {&FRAME-NAME} ub.gds-dtl.fact-qnty        -
                                ub.gds-dtl.fact-qnty        +
                                ub.gds-dtl.doc-qnty         ) @ ub.gds-dtl.doc-qnty
  WITH FRAME {&FRAME-NAME}.
  IF ptrlprop-expptrl <> ? THEN DO:
    DISPLAY
      ( INPUT FRAME {&FRAME-NAME} ub.gds-dtl.fact-qnty        *
        INPUT FRAME {&FRAME-NAME} ub.doc-line.doc-density         ) @ ub.inv-line.wast-cli-qnty
      ( INPUT FRAME {&FRAME-NAME} ub.inv-line.wast-cli-qnty   -
                                  ub.inv-line.before-cli-qnty ) @ ub.doc-line.cli-qnty
    WITH FRAME {&FRAME-NAME}.
  END.
END.


ON LEAVE OF ub.inv-line.wast-cli-qnty IN FRAME {&FRAME-NAME} /* Стало */
DO:
  IF INPUT FRAME {&FRAME-NAME} ub.inv-line.wast-cli-qnty < 0 THEN DO:
    MESSAGE "Отрицательного количества товара не бывает !" VIEW-AS ALERT-BOX ERROR.
    RETURN NO-APPLY.
  END.
  FIND FIRST ub.units NO-LOCK WHERE ub.units.unit-name = ub.goods.unit-base.
  IF ptrlprop-expptrl <> ? THEN DO:
    DISPLAY
      ( INPUT FRAME {&FRAME-NAME} ub.inv-line.wast-cli-qnty   /
        INPUT FRAME {&FRAME-NAME} ub.doc-line.doc-density         ) @ ub.gds-dtl.fact-qnty
      ( INPUT FRAME {&FRAME-NAME} ub.inv-line.wast-cli-qnty   -
                                  ub.inv-line.before-cli-qnty ) @ ub.doc-line.cli-qnty
    WITH FRAME {&FRAME-NAME}.
  END.
  DISPLAY
    ( INPUT FRAME {&FRAME-NAME} ub.gds-dtl.fact-qnty        -
                                ub.gds-dtl.fact-qnty        +
                                ub.gds-dtl.doc-qnty         ) @ ub.gds-dtl.doc-qnty
  WITH FRAME {&FRAME-NAME}.
END.

ON LEAVE OF ub.doc-line.doc-density IN FRAME {&FRAME-NAME}
DO:
  IF ptrlprop-expptrl = ? THEN DO: RETURN. END.
  if valid-density( INPUT FRAME {&FRAME-NAME} ub.doc-line.doc-density, (ub.goods.unit-base = ub.goods.unit-cli) ) <> true then do:
    MESSAGE "Внимание!" SKIP
            "Неверное значение плотности для топлива:" INPUT FRAME {&FRAME-NAME} ub.doc-line.doc-density "." SKIP
            "Плотность топлива должна быть в диапазоне: больше 0 и меньше 1."
    VIEW-AS ALERT-BOX ERROR TITLE " О Ш И Б К А ! ! ! ".
    APPLY "ENTRY":U TO ub.doc-line.doc-density IN FRAME {&FRAME-NAME}.
    RETURN NO-APPLY.
  END. /* density */
  IF ptrlprop-expptrl = {&calc-petrol-weight} THEN DO:
      DISPLAY
        ( INPUT FRAME {&FRAME-NAME} ub.inv-line.wast-cli-qnty /
          INPUT FRAME {&FRAME-NAME} ub.doc-line.doc-density       ) @ ub.gds-dtl.fact-qnty
        ( INPUT FRAME {&FRAME-NAME} ub.gds-dtl.fact-qnty      -
                                    ub.gds-dtl.fact-qnty      +
                                    ub.gds-dtl.doc-qnty       ) @ ub.gds-dtl.doc-qnty
      WITH FRAME {&FRAME-NAME}.
  END.
  ELSE DO:
    DISPLAY
      ( INPUT FRAME {&FRAME-NAME} ub.gds-dtl.fact-qnty        *
        INPUT FRAME {&FRAME-NAME} ub.doc-line.doc-density         ) @ ub.inv-line.wast-cli-qnty
      ( INPUT FRAME {&FRAME-NAME} ub.inv-line.wast-cli-qnty   -
                                  ub.inv-line.before-cli-qnty ) @ ub.doc-line.cli-qnty
    WITH FRAME {&FRAME-NAME}.
  END. /* ptrlprop-expptrl */
END.


/* ***************************  Main Block  *************************** */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

{ gbl/app_help.i }

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK :

  define variable chg-qnty      like ub.gds-dtl.fact-qnty no-undo initial ?.
  define variable v-err-msg     as character no-undo .
  define variable old-pl-qnty   as decimal no-undo.  /* Уже зарезервированное количество cкладско-местного товара*/
  define variable new-pl-qnty   as decimal no-undo.  /* Необходимое для резервирования количество cкладско-местного товара*/
  define variable v-count-place as integer   no-undo .

  define buffer buf_doc-pl for ub.doc-pl .

  for each tt-doc-pl
  on error undo, return error return-value
  :
    delete tt-doc-pl.
  end.

  { gbl/conf-rd.i  "'inv-prsr'" "''" "''" 0 "''" "''" "''" no v-inv-prsr v-data-type no-error }
  if error-status :error then v-inv-prsr = "no" .
  if v-inv-prsr = "no" then hide v-inv_peresort in frame {&frame-name} .

  find ub.gds-prt no-lock where recid( ub.gds-prt ) = cur-rec.
  if prt-mode = {&prt-def} and node-type <> {&g#term} then do:
    message "В режиме ШКАЛА можно указывать количества только по самым подробным признакам." view-as alert-box error.
    undo, return error.
  end.
  find first ub.trn-doc no-lock
    where recid( ub.trn-doc ) = doc-rec
  .
  find first ub.doc-line no-lock
    where recid( ub.doc-line ) = line-rec
  .
  find first ub.goods no-lock
    where recid( ub.goods   ) = gds-rec
  .
  find first ub.clients no-lock
    where ub.clients.obj-code = ub.goods.prod-code
      and ub.clients.obj-type = ub.goods.prod-type
    .
  find first ub.prt-obj no-lock
    where ub.prt-obj.prt-code  = ub.gds-prt.node-code
      and ub.prt-obj.prod-code = ub.goods.prod-code
      and ub.prt-obj.prod-type = ub.goods.prod-type
      and ub.prt-obj.artic     = ub.goods.artic
      and ub.prt-obj.obj-code  = store-code
      and ub.prt-obj.obj-type  = store-type
    no-error.
  if ub.trn-doc.fact-date = ? then do:
    assign
      old-val = ( if available ub.prt-obj then ub.prt-obj.fact-qnty else 0 )
      v-fact-order = integer ( ub.trn-doc.doc-date ) + 0.99
      .
  end.
  else do:
    /* Старое значение на fact-order */
    if available ub.prt-obj then do:
    run doc-qnty-by-factord (
        input  recid(ub.trn-doc)   ,
        input  ub.trn-doc.obj-type ,
        input  ub.trn-doc.obj-code ,
        input  ub.goods.artic      ,
        input  ub.goods.prod-type  ,
        input  ub.goods.prod-code  ,
        input  ub.prt-obj.prt-code ,
        output old-val ,
        output v-fact-order
        ).
        end.
        else do:
          old-val = 0.
          v-fact-order  = ub.trn-doc.fact-order.
        end.

  end.

  { gbl/conf-rd.i
    "'is-ptrl'"
    "''"
    "''"
    0
    "''"
    "''"
    "''"
    no
    v-is-ptrl
    v-data-type
    no-error
  }
  if error-status :error
    or v-data-type <> "L"
    or lookup( v-is-ptrl, "yes,no" ) = 0
  then do:
    assign
      v-is-ptrl = "no"
    .
  end.

  assign
    ptrlprop-expptrl = ?
  .

  if v-is-ptrl = "yes" then do:
    { str/is-petrl.i
      ub.goods.artic
      ub.goods.prod-type
      ub.goods.prod-code
      is-petrol
      is-pieces
      no-error
    }
    if not error-status :error
      and is-petrol = yes
      and is-pieces = no
    then do:

      { gbl/ptrlprop.i run ub.trn-doc.obj-type ub.trn-doc.obj-code }

      find first ub.inv-line no-lock
        where ub.inv-line.doc-code  = ub.doc-line.doc-code
          and ub.inv-line.artic     = ub.doc-line.artic
          and ub.inv-line.prod-type = ub.doc-line.prod-type
          and ub.inv-line.prod-code = ub.doc-line.prod-code
        no-error.

      assign
        v-count-place = 0
      .
      for each buf_doc-pl no-lock
        where buf_doc-pl.out-code = ub.doc-line.doc-code
          and buf_doc-pl.gds-code = ub.goods.gds-code
      on error undo, return error return-value
      :
        create tt-doc-pl.
        buffer-copy buf_doc-pl to tt-doc-pl .
        assign
          v-count-place = v-count-place + 1
        .
      end.
      if v-count-place = 1 then do:
        assign
          v-single-place = true
        .
      end.
      else do:
        assign
          v-single-place = false
        .
      end.
    end. /* is-petrol = yes and is-pieces = no */
  end. /* v-is-ptrl */

  if prt-mode = {&lookup} then do:
    find ub.gds-dtl  no-lock
      where ub.gds-dtl.prt-code  = ub.gds-prt.node-code
        and ub.gds-dtl.prod-code = ub.doc-line.prod-code
        and ub.gds-dtl.prod-type = ub.doc-line.prod-type
        and ub.gds-dtl.artic     = ub.doc-line.artic
        and ub.gds-dtl.doc-code  = ub.trn-doc.doc-code
      no-error.
  end. /* if prt-mode = {&lookup} */
  else do:
    find ub.doc-line exclusive-lock where recid( ub.doc-line ) = line-rec.
    if ptrlprop-expptrl <> ? then do:
      find first ub.inv-line exclusive-lock
        where ub.inv-line.doc-code  = ub.doc-line.doc-code
          and ub.inv-line.artic     = ub.doc-line.artic
          and ub.inv-line.prod-type = ub.doc-line.prod-type
          and ub.inv-line.prod-code = ub.doc-line.prod-code
        .
    end. /* if ptrlprop-expptrl <> ? */

    find ub.gds-dtl  exclusive-lock where
        ub.gds-dtl.doc-code  = ub.trn-doc.doc-code   and
        ub.gds-dtl.prod-code = ub.doc-line.prod-code and
        ub.gds-dtl.prod-type = ub.doc-line.prod-type and
        ub.gds-dtl.artic     = ub.doc-line.artic     and
        ub.gds-dtl.prt-code  = ub.gds-prt.node-code  no-error.
    assign varnew_gds-dtl = ( not available ub.gds-dtl ).
    { str/crgdsdtl.i
      ub.doc-line.obj-code
      ub.doc-line.obj-type
      ub.doc-line.doc-code
      ub.doc-line.artic
      ub.doc-line.prod-code
      ub.doc-line.prod-type
      ub.gds-prt.node-code
      yes
      no-error
    }
    if error-status :error then do:
      message "Ошибка при создании признака." skip
              return-value
      view-as alert-box error.
      return error.
    end.

    if varnew_gds-dtl = yes then do:
      find ub.gds-dtl exclusive-lock where
          ub.gds-dtl.doc-code  = ub.trn-doc.doc-code   and
          ub.gds-dtl.prod-code = ub.doc-line.prod-code and
          ub.gds-dtl.prod-type = ub.doc-line.prod-type and
          ub.gds-dtl.artic     = ub.doc-line.artic     and
          ub.gds-dtl.prt-code  = ub.gds-prt.node-code.
      assign ub.gds-dtl.doc-qnty  = 0
            ub.gds-dtl.fact-qnty = old-val.
      find first ub.goods no-lock where
                ub.goods.artic     = ub.gds-dtl.artic     and
                ub.goods.prod-type = ub.gds-dtl.prod-type and
                ub.goods.prod-code = ub.gds-dtl.prod-code.
      { str/get-pr.i calc ub.gds-dtl.obj-type ub.gds-dtl.obj-code ub.goods.gds-code ub.gds-dtl.prt-code " " v-fact-order  }

      if gp-price-sale <> ? then do:
        ASSIGN ub.doc-line.excise   = gp-excise
              ub.doc-line.road-tax = gp-road-tax.
        if varr-b = "rubl":U then do: ASSIGN ub.gds-dtl.price-rubl = gp-price-sale. end.
                            else do: ASSIGN ub.gds-dtl.price-base = gp-price-sale. end.
      end.
      else do:
        /*!!!!*/
        if v-fact-order = 0  then  do:
             message "Невозможно рассчитать fact-order.  Возможно не открыта смена на объекте "  view-as alert-box error .
        end.
        else do:
            run factord-to-date in this-procedure ( v-fact-order , output v-fact-order-day1 ) .
            message substitute("Нет цены для товара &1  &4 (признак &2) на дату &3. Сделайте переоценку " , ub.goods.artic , ub.gds-dtl.prt-code, string(v-fact-order-day1, "99/99/9999" ) , ub.goods.gds-name )  view-as alert-box .
            if varr-b = "rubl":U then do: ASSIGN ub.gds-dtl.price-rubl = 0. end.
                                 else do: ASSIGN ub.gds-dtl.price-base = 0. end.
        end.
      end.

      if varr-b = "base":U then do:
        assign ub.gds-dtl.price-rubl = ub.gds-dtl.price-base * ub.trn-doc.base-rate / ub.trn-doc.base-scale.
      end.
      else do:
        assign ub.gds-dtl.price-base = ub.gds-dtl.price-rubl / ub.trn-doc.base-rate * ub.trn-doc.base-scale.
      end.
    end. /* varnew_gds-dtl */
  end.

  if ptrlprop-expptrl <> ? then do:
    run str/doc-pls.w
      ( input parparentproc
      ,input (if prt-mode = {&lookup} then {&lookup} else {&update})
      ,input (if ub.trn-doc.status_ = {&permitted} and ub.trn-doc.flag_ = false then "rest-fact":U else "rest":U)
      ,input (if ptrlprop-expptrl = {&calc-petrol-weight} then "cli":U else "base":U )
      ,input ub.doc-line.doc-code
      ,input ub.goods.gds-code
      ,input ub.goods.unit-cli
      ,input ?
      ,input ?
      ,input ?
      ,input ub.doc-line.cli-qnty
      ,input ub.doc-line.fact-qnty
      ,input ub.doc-line.fact-qnty
      ,input ub.doc-line.cli-qnty
      ,input ub.doc-line.cli-qnty
      ,input ub.doc-line.doc-density
      ,input ub.doc-line.doc-qnty
      ,input ub.inv-line.wast-cli-qnty
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при разбиении кол-ва по местам хранения." skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
  end.
  else do:
    if prt-mode = {&lookup} then do:
      RUN UI-on IN THIS-PROCEDURE.
      if not available ub.gds-dtl then do:
        display
          0.0 @ ub.gds-dtl.doc-qnty
          old-val @ ub.gds-dtl.fact-qnty
          ub.inv-line.wast-cli-qnty when ptrlprop-expptrl <> ?
          ub.doc-line.doc-density   when ptrlprop-expptrl <> ?
          ub.doc-line.cli-qnty      when ptrlprop-expptrl <> ?
          with frame {&FRAME-NAME}.
      end. /* if not available ub.gds-dtl */
      WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS b-exit.
    end. /* if prt-mode = {&lookup} */
    else do:
      RUN UI-on IN THIS-PROCEDURE.

      IF ub.trn-doc.flag_ = YES THEN DO:
        IF ptrlprop-expptrl = {&calc-petrol-weight} THEN DO:
          WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS ub.inv-line.wast-cli-qnty.
        END.
        ELSE DO:
          WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS ub.gds-dtl.fact-qnty.
        END.
      END. /* IF ub.trn-doc.flag_ = YES */
      ELSE DO: /* IF ub.trn-doc.flag_ <> YES */
        IF ptrlprop-expptrl = {&calc-petrol-weight} THEN DO:
          WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS ub.doc-line.cli-qnty.
        END.
        ELSE DO:
          WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS ub.gds-dtl.doc-qnty.
        END.
      END. /* IF ub.trn-doc.flag_ <> YES */
    end.
  end.

  if prt-mode <> {&lookup} then do:
    if ptrlprop-expptrl <> ? then do:
      define variable v-fact-qnty         as decimal   no-undo .
      define variable v-fact-cli-qnty     as decimal   no-undo .
      define variable v-rest-qnty         as decimal   no-undo .
      define variable v-rest-cli-qnty     as decimal   no-undo .

      assign
        v-rest-qnty     = 0.0
        v-rest-cli-qnty = 0.0
      .
      for each ub.doc-pl exclusive-lock
        where ub.doc-pl.out-code  = ub.doc-line.doc-code
          and ub.doc-pl.gds-code  = ub.goods.gds-code
      on error undo, return error return-value
      :
        assign
          old-pl-qnty = (- ub.doc-pl.doc-qnty)
        .
        if old-pl-qnty <> 0.0 then do:
          run trg/rsrv-dtl.p
            ( input parparentproc
            ,input {&rsrv-dtl_action_reserv} + "," + {&rsrv-dtl_pl-code} + "=" + string(ub.doc-pl.pl-code) + ',' + {&rsrv-dtl_negative-check} + "=1"
            ,buffer ub.gds-dtl
            ,input-output old-pl-qnty
            ,input-output ub.doc-line.price-base
            ,input-output ub.doc-line.price-rubl
            ,-1
            ,""
            ) no-error.
          if error-status :error then do:
            assign
              v-err-msg = substitute( "Ошибка при разрезервировании.&1&2", {&new-line}, return-value )
            .
          end.
          else do:
            if old-pl-qnty <> (- ub.doc-pl.doc-qnty) then do:
              assign
                v-err-msg = substitute( "Не удалось снять резервы по ранее зарезервированному количеству.&1Запрошено: &2&1Удалось разрезервировать: &3&1"
                                      , {&new-line}
                                      , (- ub.doc-pl.doc-qnty)
                                      , old-pl-qnty
                                      )
              .
            end.
          end.
          if v-err-msg <> "":U then do:
            message
              vss-workfile vss-revision vss-description skip
              v-err-msg skip
              view-as alert-box error .
            undo, return error v-err-msg .
          end.
        end.
        find first tt-doc-pl
          where tt-doc-pl.out-code = ub.doc-pl.out-code
            and tt-doc-pl.gds-code = ub.doc-pl.gds-code
            and tt-doc-pl.pl-code  = ub.doc-pl.pl-code
          .
        buffer-copy tt-doc-pl to ub.doc-pl .
        assign
          new-pl-qnty = ub.doc-pl.doc-qnty
        .
        if new-pl-qnty <> 0.0 then do:
          run trg/rsrv-dtl.p
            ( input parparentproc
            ,input {&rsrv-dtl_action_reserv} + "," + {&rsrv-dtl_pl-code} + "=" + string(ub.doc-pl.pl-code) + ',' + {&rsrv-dtl_negative-check} + "=1"
            ,buffer ub.gds-dtl
            ,input-output new-pl-qnty
            ,input-output ub.doc-line.price-base
            ,input-output ub.doc-line.price-rubl
            ,-1
            ,""
          ) no-error.
          if error-status :error then do:
            assign
              v-err-msg = substitute( "Ошибка при резервировании.&1&2", {&new-line}, return-value )
            .
          end.
          else do:
            if new-pl-qnty <> ub.doc-pl.doc-qnty then do:
              assign
                v-err-msg = substitute( "Не удалось зарезервировать все запрошенное количество.&1Запрошено: &2&1Удалось разрезервировать: &3&1"
                                      , {&new-line}
                                      , ub.doc-pl.doc-qnty - old-pl-qnty
                                      , new-pl-qnty - old-pl-qnty
                                      )
              .
            end.
          end.
          if v-err-msg <> "":U then do:
            message
              vss-workfile vss-revision vss-description skip
              v-err-msg skip
              view-as alert-box error .
            undo, return error v-err-msg .
          end.
        end.
        assign
          v-fact-qnty     = v-fact-qnty     + ub.doc-pl.fact-qnty
          v-fact-cli-qnty = v-fact-cli-qnty + ub.doc-pl.cli-fact-qnty
          v-rest-qnty     = v-rest-qnty     + ub.doc-pl.rest-af-qnty
          v-rest-cli-qnty = v-rest-cli-qnty + ub.doc-pl.cli-rest-af-qnty
        .
      end.
      if v-rest-qnty <> 0.0
        and v-rest-cli-qnty <> 0.0
      then do:
        assign
          ub.doc-line.doc-density  = v-rest-cli-qnty / v-rest-qnty
          ub.doc-line.fact-density = ub.doc-line.doc-density
        .
      end.

      assign
        ub.gds-dtl.fact-qnty      = v-rest-qnty
        ub.doc-line.doc-qnty      = v-rest-qnty
        ub.inv-line.wast-cli-qnty = v-rest-cli-qnty
        ub.gds-dtl.doc-qnty       = v-fact-qnty
        ub.doc-line.fact-qnty     = v-fact-qnty
        ub.doc-line.cli-qnty      = v-fact-cli-qnty
      .
    end.
    else do:
      IF ub.trn-doc.flag_ = YES THEN DO:
        assign chg-qnty = input frame {&FRAME-NAME} ub.gds-dtl.fact-qnty - ub.gds-dtl.fact-qnty.
        run trg/rsrv-dtl.p ( input        parParentProc,
                        input        {&rsrv-dtl_action_reserv},
                        buffer       ub.gds-dtl,
                        input-output chg-qnty,
                        input-output ub.doc-line.price-base,
                        input-output ub.doc-line.price-rubl,
                        input        -1,
                        input ""                         ).
        assign ub.gds-dtl.fact-qnty  = ub.gds-dtl.fact-qnty  + chg-qnty
              ub.gds-dtl.doc-qnty   = ub.gds-dtl.fact-qnty  - old-val
              ub.doc-line.doc-qnty  = ub.doc-line.doc-qnty  + chg-qnty
              ub.doc-line.fact-qnty = ub.doc-line.fact-qnty + chg-qnty.
      END. /* ub.trn-doc.flag_ = YES */
      ELSE DO: /* ub.trn-doc.flag_ <> YES */
        assign chg-qnty = input frame {&FRAME-NAME} ub.gds-dtl.doc-qnty - ub.gds-dtl.doc-qnty.
        run trg/rsrv-dtl.p ( input        parParentProc,
                        input        {&rsrv-dtl_action_reserv},
                        buffer       ub.gds-dtl,
                        input-output chg-qnty,
                        input-output ub.doc-line.price-base,
                        input-output ub.doc-line.price-rubl,
                        input        -1,
                        input ""                         ).
        assign ub.gds-dtl.fact-qnty  = ub.gds-dtl.fact-qnty  + chg-qnty
              ub.gds-dtl.doc-qnty   = ub.gds-dtl.doc-qnty   + chg-qnty
              ub.doc-line.doc-qnty  = ub.doc-line.doc-qnty  + chg-qnty
              ub.doc-line.fact-qnty = ub.doc-line.fact-qnty + chg-qnty.
      END. /* ub.trn-doc.flag_ <> YES */
    end.

    assign prt-rec = recid( ub.gds-dtl ).
    if ub.gds-dtl.doc-qnty = 0 then do:
      delete ub.gds-dtl.
      assign prt-rec = ?.
    end.

    assign ub.doc-line.prt-OK = no. /* начальное значение prt-OK */
    find ub.gds-prt no-lock where ub.gds-prt.upper-code = ub.goods.prt-root.
    for each ub.gds-dtl where /* назначено по всем признакам */
            ub.gds-dtl.prod-code = ub.goods.prod-code   and
            ub.gds-dtl.prod-type = ub.goods.prod-type   and
            ub.gds-dtl.artic     = ub.goods.artic       and
            ub.gds-dtl.doc-code  = ub.doc-line.doc-code :
      if ub.gds-dtl.doc-qnty <> 0 and ub.gds-dtl.prt-code <> ub.gds-prt.node-code then do:
        assign ub.doc-line.prt-OK = yes.
      end.
    end. /* for each ub.gds-dtl */
  end.
END. /* MAIN-BLOCK */
RUN disable_UI IN THIS-PROCEDURE.

for each tt-doc-pl
on error undo, return error return-value
:
  delete tt-doc-pl.
end.

if prt-mode = {&lookup} then do:
  return error.
end.


/* **********************  Internal Procedures  *********************** */
PROCEDURE disable_UI :
  HIDE FRAME {&FRAME-NAME} NO-PAUSE.
END PROCEDURE. /* disable_UI */

PROCEDURE UI-on :
/* Пересортица */
  v-inv_peresort = 0 .
  if v-inv-prsr = "yes" then do:
          assign
            v-inv_peresort  = ub.doc-line.inv-peresort
          .
      display v-inv_peresort with frame {&frame-name}.
  end.

  IF ptrlprop-expptrl <> ? THEN DO:
    ASSIGN FRAME {&FRAME-NAME}  :HEIGHT-CHARS                        = 13.
    ASSIGN RECT-1               :HEIGHT-CHARS IN FRAME {&FRAME-NAME} =  5.50.
/*    assign*/
/*      ub.inv-line.wast-cli-qnty:label in frame {&frame-name} = ub.inv-line.wast-cli-qnty:label in frame {&frame-name} + " (" + ub.goods.unit-cli + ")".*/
/*    .*/
  END.
  ELSE DO:
    ASSIGN ub.doc-line.doc-density       :ROW IN FRAME {&FRAME-NAME} =
           ub.doc-line.doc-density       :ROW IN FRAME {&FRAME-NAME} - 1.25
           ub.inv-line.wast-cli-qnty :ROW IN FRAME {&FRAME-NAME} =
           ub.inv-line.wast-cli-qnty :ROW IN FRAME {&FRAME-NAME} - 2.50
           ub.doc-line.cli-qnty      :ROW IN FRAME {&FRAME-NAME} =
           ub.doc-line.cli-qnty      :ROW IN FRAME {&FRAME-NAME} - 2.50
           ub.goods.unit-cli         :ROW IN FRAME {&FRAME-NAME} =
           ub.goods.unit-cli         :ROW IN FRAME {&FRAME-NAME} - 2.50.
    HIDE   ub.doc-line.doc-density            IN FRAME {&FRAME-NAME}
           ub.inv-line.wast-cli-qnty      IN FRAME {&FRAME-NAME}
           ub.doc-line.cli-qnty           IN FRAME {&FRAME-NAME}
           ub.goods.unit-cli              IN FRAME {&FRAME-NAME}.
    ASSIGN FRAME {&FRAME-NAME} :HEIGHT-CHARS                        = 13.
    ASSIGN RECT-1              :HEIGHT-CHARS IN FRAME {&FRAME-NAME} =  3.00.
  END. /* ptrlprop-expptrl = ? */
  HIDE RECT-1 IN FRAME {&FRAME-NAME}.
  HIDE           FRAME {&FRAME-NAME} NO-PAUSE.
  VIEW           FRAME {&FRAME-NAME}.   PAUSE 0.
  DISPLAY   WITH FRAME {&FRAME-NAME}.

  ASSIGN FRAME {&FRAME-NAME} :TITLE = "Инвентаризация №  " + ub.trn-doc.doc-code + ".    {&row}     " + prt-mode.
  FIND b-c-b NO-LOCK WHERE
       b-c-b.gds-code  = ub.goods.gds-code    AND
       b-c-b.node-code = ub.gds-prt.node-code AND
       b-c-b.in-code   = "":U                 AND
       b-c-b.unit-cli  = ub.goods.unit-base   AND
       b-c-b.part-code = "":U                 NO-ERROR.
  DISPLAY ub.clients.obj-name ub.doc-line.artic  ub.doc-line.prod-type ub.doc-line.prod-code
          ub.goods.gds-name   ub.goods.unit-base RECT-1
  WITH FRAME {&FRAME-NAME}.
  IF AVAILABLE b-c-b THEN DO: DISPLAY b-c-b.b-code WITH FRAME {&FRAME-NAME}. END.
  IF node-type = {&g#root} THEN DO: HIDE    ub.doc-line.fact-qnty ub.gds-prt.f-name   IN FRAME {&FRAME-NAME}. END.
                           ELSE DO: DISPLAY ub.doc-line.fact-qnty ub.gds-prt.f-name WITH FRAME {&FRAME-NAME}. END.
  IF AVAILABLE ub.gds-dtl THEN DO:
    DISPLAY ub.gds-dtl.doc-qnty ub.gds-dtl.fact-qnty WITH FRAME {&FRAME-NAME}.
  END.
  IF ptrlprop-expptrl <> ? THEN DO:
    DISPLAY ub.doc-line.doc-density ub.inv-line.wast-cli-qnty ub.doc-line.cli-qnty
            ub.goods.unit-cli
    WITH FRAME {&FRAME-NAME}.
  END. /* ptrlprop-expptrl <> ? */

  ENABLE b-exit b-help WITH FRAME {&FRAME-NAME}.
  IF prt-mode <> {&lookup} THEN DO:
    IF ptrlprop-expptrl <> ? THEN DO:
      ENABLE
        ub.doc-line.doc-density when v-single-place = true
        WITH FRAME {&FRAME-NAME}.
      if v-single-place = true
        and valid-density( ub.doc-line.doc-density, (ub.goods.unit-base = ub.goods.unit-cli) ) = true
      then do:
        apply "leave":u to ub.doc-line.doc-density in frame {&frame-name}.
      end.
    END.
    IF ub.trn-doc.flag_ = YES THEN DO:
      IF ptrlprop-expptrl = {&calc-petrol-weight} THEN DO: ENABLE ub.inv-line.wast-cli-qnty WITH FRAME {&FRAME-NAME}. END.
                                           ELSE DO: ENABLE ub.gds-dtl.fact-qnty      WITH FRAME {&FRAME-NAME}. END.
    END. /* IF ub.trn-doc.flag_ = YES */
    ELSE DO: /* IF ub.trn-doc.flag_ <> YES */
      IF ptrlprop-expptrl = {&calc-petrol-weight} THEN DO: ENABLE ub.doc-line.cli-qnty      WITH FRAME {&FRAME-NAME}. END.
                                           ELSE DO: ENABLE ub.gds-dtl.doc-qnty       WITH FRAME {&FRAME-NAME}. END.
    END. /* IF ub.trn-doc.flag_ <> YES */
  END. /* IF prt-mode <> {&lookup} */
END PROCEDURE. /* UI-on */

procedure doc-qnty-by-factord :
/* Подсчет "было" на конец дня или смены  fact-date по признаку  */
define input  parameter par-recid     as recid no-undo .
define input  parameter par-obj-type  like ub.doc-line.obj-type  no-undo .
define input  parameter par-obj-code  like ub.doc-line.obj-code  no-undo .
define input  parameter par-artic     like ub.doc-line.artic     no-undo .
define input  parameter par-prod-type like ub.doc-line.prod-type no-undo .
define input  parameter par-prod-code like ub.doc-line.prod-code no-undo .
define input  parameter par-prt-code  like ub.prt-obj.prt-code no-undo .
define output parameter v-doc-qnty    as decimal   no-undo .
define output parameter v-fact-order-end as decimal   no-undo .

define variable v-shift-on  as logical   no-undo .

define variable v-shift-end-fact-order as decimal   no-undo .
define variable v-day-end-fact-order   as decimal   no-undo .
define buffer buf_trn-doc for ub.trn-doc  .
  do
  on error undo, return error return-value
  :
find first buf_trn-doc no-lock  where recid(buf_trn-doc) =  par-recid no-error .
v-doc-qnty = 0 .
{ gbl/objat.i
  buf_trn-doc.obj-type
  buf_trn-doc.obj-code
  "'shift-on=request'"
  v-shift-on
  no-error
}
    if error-status :error then do:
      message
          vss-workfile vss-revision vss-description
          skip "Ошибка при запросе, включены ли смены"
          skip error-status :get-message(1)
          skip return-value
      view-as alert-box error .
      undo, return error .
    end.
        run factord in this-procedure (
              input  buf_trn-doc.fact-date  /* p-fact-date            */
            , input  buf_trn-doc.fact-time  /* p-fact-time            */
            , input  buf_trn-doc.fact-time  /* p-fact-num             */
            , input  buf_trn-doc.shift-date /* p-shift-date           */
            , input  buf_trn-doc.shift-num  /* p-shift-num            */
            , input  v-shift-on              /* p-shift-on             */
            , output v-fact-order-end        /* p-fact-order           */
            , output v-shift-end-fact-order  /* p-shift-end-fact-order */
            , output v-day-end-fact-order    /* p-day-end-fact-order   */
        ) no-error .
if v-shift-on = true then  v-fact-order-end = v-shift-end-fact-order .
                     else  v-fact-order-end = v-day-end-fact-order .

  run prdoclib-init-prt-obj-by-factord in this-procedure
    ( input par-obj-type,
      input par-obj-code,
      input par-artic,
      input par-prod-type,
      input par-prod-code,
      input v-fact-order-end,
      input false ) .
  end.
v-doc-qnty = 0.
for each temp-prt-obj where temp-prt-obj.prt-code  = par-prt-code :
  v-doc-qnty = v-doc-qnty + temp-prt-obj.fact-qnty .
end.

if v-inv-prsr = "yes" then do:
    if prt-mode = {&prt-def} then do:
      v-inv_peresort:tooltip in frame {&frame-name} = "Пересортица по товару вцелом , без разбивки по шкале" .
    end.
    enable  v-inv_peresort  with frame {&frame-name}.
end.
else hide  v-inv_peresort  in frame {&frame-name}.

end procedure. /* doc-qnty-by-factord */

&UNDEFINE FRAME-NAME
&UNDEFINE WINDOW-NAME