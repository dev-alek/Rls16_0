block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-otv-xr.p $
$Archive: cus/r-otv-xr.p $

Печать объединенного счета-фактуры по ответственному хранению

Автор: Булгаков Андрей Николаевич
Дата создания: 09/21/05
Author: Andrew Bulgakoff
Creation date: 09/21/05

*/

DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.

DEFINE INPUT PARAMETER p-supp-type AS CHARACTER NO-UNDO. /* тип поставщика */
DEFINE INPUT PARAMETER p-supp-code AS INTEGER   NO-UNDO. /* код поставщика */
DEFINE INPUT PARAMETER p-date-from AS DATE      NO-UNDO. /* дата начала    */
DEFINE INPUT PARAMETER p-date-till AS DATE      NO-UNDO. /* дата окончания */
DEFINE INPUT PARAMETER p-scf-code  AS CHARACTER NO-UNDO. /* номер счета-фактуры */
DEFINE INPUT PARAMETER p-pay-code  AS CHARACTER NO-UNDO. /* к платежному документу */
DEFINE INPUT PARAMETER p-title     AS CHARACTER NO-UNDO. /* заголовок */
DEFINE INPUT PARAMETER p-ins-date  AS LOGICAL   NO-UNDO. /* вставлять дату в н-р платежного документа */
/* DEFINE INPUT PARAMETER p-detail    AS LOGICAL   NO-UNDO. */ /* детализация по признакам */

/* VSS Variables Definitions */
DEFINE VARIABLE vss-revision    AS CHARACTER NO-UNDO INITIAL "$Revision: aea5316774be, 0, rls $":U.
DEFINE VARIABLE vss-author      AS CHARACTER NO-UNDO INITIAL "$Author: expertek $":U.
DEFINE VARIABLE vss-date        AS CHARACTER NO-UNDO INITIAL "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U.
DEFINE VARIABLE vss-workfile    AS CHARACTER NO-UNDO INITIAL "$Workfile: r-otv-xr.p $":U.
DEFINE VARIABLE vss-archive     AS CHARACTER NO-UNDO INITIAL "$Archive: cus/r-otv-xr.p $":U.
DEFINE VARIABLE vss-description AS CHARACTER NO-UNDO INITIAL "$Description: печать объединенного счета-фактуры по ответственному хранению $":U.

{ cmp/vssrevis.i         }
{ cmp/str-glbl.i         }
{ cmp/library.i          }
{ cmp/r-page1.i          }
{ rep/rep-bt.i           }
{ cmp/r-pril.i           }
{ gbl/prn-lib.i          }
{ cmp/breakstr.i         }
{ str/in-vatp.i def      }
{ str/out-vatp.i def     }
{ rep/r-factur.i def     }
{ rep/r-sym.i            }
{ rep/repfrm.i   def     }
{ rep/repfrm.i   on  100 }
{ gbl/clntattr.i         }


&SCOP FRAME-NAME r-factur-print-1
&SCOP gds-len    59
&SCOP curr-abbr  " (" + TRIM( ( IF PrintRubl THEN "{&abbr_rub_allshift}" ELSE base-type ) ) + ")"
&SCOP b-neg-list {&bef-TDEDT_Vozvrat_Vnesh},{&bef-TDEDT_Vozvrat_Vnesh_Kass}
&SCOP neg-list   '{&b-neg-list}':U
&SCOP our-list   '{&bef-TDEDT_Chg_Purch_Code},{&bef-TDEDT_Ras_Vnesh},{&bef-TDEDT_Ras_Vnesh_Kass},{&b-neg-list}':U

DEFINE TEMP-TABLE tt-line NO-UNDO
  FIELD artic        AS CHARACTER                                                     FORMAT "x(16)":U
  FIELD prod-type    AS CHARACTER                                                     FORMAT "x(3)":U
  FIELD prod-code    AS INTEGER                                                       FORMAT ">>>>>>>>9":U
  FIELD gds-qty      AS DECIMAL   COLUMN-LABEL "Количество ! "                        FORMAT "->>>>>9.<<<":U
  FIELD price-no-VAT AS DECIMAL   COLUMN-LABEL "Цена!за ед.изм."                      FORMAT "->>>>>>>9.99":U
  FIELD sum-no-VAT   AS DECIMAL   COLUMN-LABEL "Стоимость товаров!всего без налога"   FORMAT "->>>>>>>>>>>>9.99":U
  FIELD VAT-pc       AS DECIMAL   COLUMN-LABEL "Ставка!налога"                        FORMAT ">9.9<%":U
  FIELD VAT          AS DECIMAL   COLUMN-LABEL "Сумма!налога"                         FORMAT "->>>>>>>9.99":U
  FIELD sum          AS DECIMAL   COLUMN-LABEL "Ст-ть товаров!с учетом налога"        FORMAT "->>>>>>>>>>9.99":U
  FIELD country      AS CHARACTER COLUMN-LABEL "Страна!происхождения"                 FORMAT "x(15)":U
  FIELD GTD          AS CHARACTER COLUMN-LABEL "Номер грузовой таможенной!декларации" FORMAT "x(31)":U
  FIELD is-positive  AS LOGICAL
  INDEX pi           IS UNIQUE    PRIMARY is-positive prod-type prod-code artic VAT-pc price-no-VAT GTD.

DEFINE VARIABLE str                  AS CHARACTER NO-UNDO.
DEFINE VARIABLE gds-str              AS CHARACTER NO-UNDO.
DEFINE VARIABLE gds-str1             AS CHARACTER NO-UNDO.
DEFINE VARIABLE gds-str2             AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-lines-counter      AS INTEGER   NO-UNDO.
DEFINE VARIABLE v-qnty               AS DECIMAL   NO-UNDO FORMAT "->>>>>9.<<<":U.
DEFINE VARIABLE v-price              AS DECIMAL   NO-UNDO.
DEFINE VARIABLE v-price-no-VAT       AS DECIMAL   NO-UNDO FORMAT "->>>>>>>9.99":U.
DEFINE VARIABLE v-sum                AS DECIMAL   NO-UNDO FORMAT "->>>>>>>>>>9.99":U.
DEFINE VARIABLE v-sum-no-VAT         AS DECIMAL   NO-UNDO FORMAT "->>>>>>>>>>>>9.99":U.
DEFINE VARIABLE v-sum-excise         AS DECIMAL   NO-UNDO FORMAT ">>>>>9.99":U.
DEFINE VARIABLE v-VAT                AS DECIMAL   NO-UNDO FORMAT "->>>>>>>9.99":U.
DEFINE VARIABLE v-SLT                AS DECIMAL   NO-UNDO.
DEFINE VARIABLE v-parts-price        AS DECIMAL   NO-UNDO.
DEFINE VARIABLE v-parts-price-no-VAT AS DECIMAL   NO-UNDO.
DEFINE VARIABLE v-parts-sum          AS DECIMAL   NO-UNDO.
DEFINE VARIABLE v-parts-sum-no-VAT   AS DECIMAL   NO-UNDO.
DEFINE VARIABLE v-parts-sum-excise   AS DECIMAL   NO-UNDO.
DEFINE VARIABLE v-parts-VAT          AS DECIMAL   NO-UNDO.
DEFINE VARIABLE v-parts-SLT          AS DECIMAL   NO-UNDO.
DEFINE VARIABLE v-tot-sum            AS DECIMAL   NO-UNDO.
DEFINE VARIABLE v-tot-VAT            AS DECIMAL   NO-UNDO.
DEFINE VARIABLE v-tot-SLT            AS DECIMAL   NO-UNDO.
DEFINE VARIABLE v-tot-sum-no-VAT     AS DECIMAL   NO-UNDO.
DEFINE VARIABLE v-prt-qnty           AS DECIMAL   NO-UNDO.
DEFINE VARIABLE v-prt-VAT            AS DECIMAL   NO-UNDO.
DEFINE VARIABLE v-prt-SLT            AS DECIMAL   NO-UNDO.
DEFINE VARIABLE v-prt-sum-no-VAT     AS DECIMAL   NO-UNDO.
DEFINE VARIABLE v-prt-sum            AS DECIMAL   NO-UNDO.
DEFINE VARIABLE v-tot-prt-qnty       AS DECIMAL   NO-UNDO.
DEFINE VARIABLE v-tot-prt-VAT        AS DECIMAL   NO-UNDO.
DEFINE VARIABLE v-tot-prt-SLT        AS DECIMAL   NO-UNDO.
DEFINE VARIABLE v-tot-prt-sum-no-VAT AS DECIMAL   NO-UNDO.
DEFINE VARIABLE v-tot-prt-sum        AS DECIMAL   NO-UNDO.
DEFINE VARIABLE v-country            AS CHARACTER NO-UNDO FORMAT "x(15)":U.
DEFINE VARIABLE v-GTD                AS CHARACTER NO-UNDO FORMAT "x(31)":U.
DEFINE VARIABLE v-single-line        AS CHARACTER NO-UNDO.
DEFINE VARIABLE t-m_adr              AS CHARACTER NO-UNDO.
DEFINE VARIABLE t-a_adr              AS CHARACTER NO-UNDO.
DEFINE VARIABLE t-m_INN              AS CHARACTER NO-UNDO.
DEFINE VARIABLE t-a_INN              AS CHARACTER NO-UNDO.
DEFINE VARIABLE t-num                AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-num                AS CHARACTER NO-UNDO.
DEFINE VARIABLE is_positive          AS LOGICAL   NO-UNDO.


DEFINE BUFFER buf_suppl FOR ub.clients.
DEFINE BUFFER buf_owner FOR ub.clients.
DEFINE BUFFER buf_mf    FOR ub.firm.
DEFINE BUFFER buf_af    FOR ub.firm.
DEFINE BUFFER buf_mp    FOR ub.person.
DEFINE BUFFER buf_ap    FOR ub.person.

DEFINE FRAME {&FRAME-NAME}
  sym1  SPACE( 0 ) ub.goods.gds-name  COLUMN-LABEL "Наименование товара! " FORMAT "x(59)":U  SPACE( 0 )
  sym2  SPACE( 0 ) ub.goods.unit-base COLUMN-LABEL "Ед.!изм."              FORMAT "x(4)":U   SPACE( 0 )
  sym3  SPACE( 0 ) v-qnty             COLUMN-LABEL "Количество ! "                           SPACE( 0 )
  sym4  SPACE( 0 ) v-price-no-VAT     COLUMN-LABEL "Цена!за ед.изм."                         SPACE( 0 )
  sym5  SPACE( 0 ) v-sum-no-VAT       COLUMN-LABEL "Стоимость товаров!всего без налога"      SPACE( 0 )
  sym6  SPACE( 0 ) v-sum-excise       COLUMN-LABEL "в т.ч.!акциз"                            SPACE( 0 )
  sym7  SPACE( 0 ) ub.doc-line.Vat-pc COLUMN-LABEL "Ставка!налога"         FORMAT ">9.9<%":U SPACE( 0 )
  sym8  SPACE( 0 ) v-VAT              COLUMN-LABEL "Сумма!налога"                            SPACE( 0 )
  sym9  SPACE( 0 ) v-sum              COLUMN-LABEL "Ст-ть товаров!с учетом налога"           SPACE( 0 )
  sym10 SPACE( 0 ) v-country          COLUMN-LABEL "Страна!происхождения"                    SPACE( 0 )
  sym11 SPACE( 0 ) v-GTD              COLUMN-LABEL "Номер грузовой таможенной!декларации"    SPACE( 0 ) sym12 SPACE( 0 )
HEADER STRING( "Страница " + STRING( PAGE-NUMBER( PrnLibStream ), ">>9":U ) ) AT 180 FORMAT "x(13)":U SKIP
               v-single-line                                                  AT   1 FORMAT "x(198)":U
WITH WIDTH {&DOS_CW} DOWN STREAM-IO.

FORM HEADER
  v-single-line FORMAT "x(198)":U       AT  1 SKIP
  "Продолжение - на следующей странице" AT 30 SKIP
WITH FRAME Bottomframe WIDTH {&DOS_CW} PAGE-BOTTOM NO-LABELS NO-BOX.

FUNCTION SheetFormat RETURNS INTEGER :
  DEFINE VARIABLE log-sheet-answer AS LOGICAL NO-UNDO.

  { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_waybills-to-file_print':U
  {&cntxt-firm}
  v-cntxt-host-code-obj
  '':U
  0
  0
  0
  0
  no
  log-sheet-answer
  }
  RETURN ( IF log-sheet-answer THEN 8 ELSE 0 ).
END FUNCTION. /* SheetFormat */

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
Main-Block:
DO ON ERROR   UNDO Main-Block, LEAVE Main-Block
   ON END-KEY UNDO Main-Block, LEAVE Main-Block :

  FIND buf_owner NO-LOCK WHERE
       buf_owner.obj-type = {&cmp}      AND
       buf_owner.obj-code = v-cntxt-host-code-obj.
  FIND buf_suppl NO-LOCK WHERE
       buf_suppl.obj-type = p-supp-type AND
       buf_suppl.obj-code = p-supp-code NO-ERROR.
  IF NOT AVAILABLE buf_suppl THEN DO:
    MESSAGE "Не найден поставщик: " p-supp-type p-supp-code "." VIEW-AS ALERT-BOX.
    RETURN ERROR.
  END.

  RUN init-var                  IN THIS-PROCEDURE.
  RUN calc-sum                  IN THIS-PROCEDURE.
  RUN print-responsible_storage IN THIS-PROCEDURE.
END. /* Main-Block */

/* **********************  Internal Procedures  *********************** */
PROCEDURE init-var :
  ASSIGN v-single-line   = FILL( "-", 198 )
         v-lines-counter = 1
         t-num           = "за период с " +
                           STRING( IF p-date-from > TODAY THEN TODAY ELSE p-date-from, "99/99/9999":U ) + " по " +
                           STRING( IF p-date-till > TODAY THEN TODAY ELSE p-date-till, "99/99/9999":U )
         v-num           = " № " + p-scf-code + " от " +
                           STRING( IF p-date-till > TODAY THEN TODAY ELSE p-date-till, "99/99/9999":U ).
  IF p-ins-date = YES THEN DO:
    ASSIGN p-pay-code = p-pay-code + " от " + STRING( IF p-date-till > TODAY THEN TODAY ELSE p-date-till, "99/99/9999":U ).
  END.
  IF buf_owner.obj-type = {&cmp} THEN DO:
    FIND buf_mf  NO-LOCK WHERE buf_mf.firm-code   = v-cntxt-host-code-obj.
    ASSIGN t-m_adr = ( ( IF buf_mf.ind <> 0 THEN STRING( buf_mf.ind ) + " ":U ELSE "":U ) + buf_mf.city + " ":U +
                     TRIM( buf_mf.addres1 ) + " ":U + TRIM( buf_mf.addres2 ) )
           t-m_INN = buf_mf.inn + ( IF buf_mf.kpp = ? OR TRIM( buf_mf.kpp ) = "":U THEN "":U ELSE ( "/" + buf_mf.kpp ) ).
  END.                           ELSE DO:
    FIND buf_mp  NO-LOCK WHERE buf_mp.psn-code    = v-cntxt-host-code-obj.
    ASSIGN t-m_adr = ( ( IF buf_mp.ind <> 0 THEN STRING( buf_mp.ind ) + " ":U ELSE "":U ) + buf_mp.city + " ":U +
                     TRIM( buf_mp.address )                                  )
           t-m_INN = buf_mp.inn + ( IF buf_mp.kpp = ? OR TRIM( buf_mp.kpp ) = "":U THEN "":U ELSE ( "/" + buf_mp.kpp ) ).
  END.
  IF buf_suppl.obj-type = {&cmp} THEN DO:
    FIND buf_af  NO-LOCK WHERE buf_af.firm-code   = p-supp-code.
    ASSIGN t-a_adr = ( ( IF buf_af.ind <> 0 THEN STRING( buf_af.ind ) + " ":U ELSE "":U ) + buf_af.city + " ":U +
                     TRIM( buf_af.addres1 ) + " ":U + TRIM( buf_af.addres2 ) )
           t-a_INN = buf_af.inn + ( IF buf_af.kpp = ? OR TRIM( buf_af.kpp ) = "":U THEN "":U ELSE ( "/" + buf_af.kpp ) ).
  END.                           ELSE DO:
    FIND buf_ap  NO-LOCK WHERE buf_ap.psn-code    = p-supp-code.
    ASSIGN t-a_adr = ( ( IF buf_ap.ind <> 0 THEN STRING( buf_ap.ind ) + " ":U ELSE "":U ) + buf_ap.city + " ":U +
                     TRIM( buf_ap.address ) )
           t-a_INN = buf_ap.inn + ( IF buf_ap.kpp = ? OR TRIM( buf_ap.kpp ) = "":U THEN "":U ELSE ( "/" + buf_ap.kpp ) ).
  END.
END PROCEDURE. /* init-var */

PROCEDURE calc-sum :
  FOR EACH ub.parts NO-LOCK WHERE
           ub.parts.host-code  = v-cntxt-host-code-obj AND
           ub.parts.supp-type  = p-supp-type AND
           ub.parts.supp-code  = p-supp-code AND
           ub.parts.status_    = YES         AND
           ub.parts.fact-date >= p-date-from AND
           ub.parts.fact-date <= p-date-till :
    IF ub.parts.out-code = {&free-code} OR ub.parts.out-code = {&output-code} THEN DO: NEXT. END.
    FIND ub.trn-doc NO-LOCK WHERE ub.trn-doc.doc-code = ub.parts.out-code NO-ERROR.
    IF NOT AVAILABLE ub.trn-doc THEN DO: NEXT. END.
    IF LOOKUP( ub.trn-doc.ext-doc-type, {&our-list} ) = 0 THEN DO: NEXT. END.
    FIND ub.doc-line NO-LOCK WHERE
         ub.doc-line.doc-code  = ub.trn-doc.doc-code AND
         ub.doc-line.artic     = ub.parts.artic      AND
         ub.doc-line.prod-type = ub.parts.prod-type  AND
         ub.doc-line.prod-code = ub.parts.prod-code  NO-ERROR.
    IF NOT AVAILABLE ub.doc-line THEN DO: NEXT. END.
    FIND ub.goods NO-LOCK WHERE
         ub.goods.artic     = ub.doc-line.artic     AND
         ub.goods.prod-type = ub.doc-line.prod-type AND
         ub.goods.prod-code = ub.doc-line.prod-code NO-ERROR.
    IF NOT AVAILABLE ub.goods THEN DO: NEXT. END.
    IF LOOKUP( ub.trn-doc.ext-doc-type, {&neg-list} ) <> 0 THEN DO:
      IF ub.parts.purch-code <> INTEGER( {&old-consignation-code} ) THEN DO: NEXT. END.
    END.                                                   ELSE DO:
      IF ub.trn-doc.ext-doc-type <> {&TDEDT_Chg_Purch_code} AND
         ub.parts.purch-code  = INTEGER( {&old-consignation-code} ) THEN DO:
      END.                                                          ELSE DO:
        IF ub.trn-doc.ext-doc-type =  {&TDEDT_Chg_Purch_Code}                AND
           ub.parts.purch-code     =  INTEGER( {&responsible-storage-code} ) AND
           ub.parts.in-code        <> ub.parts.out-code                      THEN DO:
        END.                                                                 ELSE DO: NEXT. END.
      END.
    END.
    FIND obj-list WHERE obj-list.obj-type = ub.parts.obj-type AND obj-list.obj-code = ub.parts.obj-code NO-ERROR.
    IF NOT AVAILABLE obj-list THEN DO: NEXT. END.
    IF           obj-list.obj-type = {&stock} THEN DO:
      FIND ub.store NO-LOCK WHERE ub.store.obj-code = obj-list.obj-code NO-ERROR.
      IF NOT AVAILABLE ub.store THEN DO: NEXT. END.
      IF ub.store.host-code <> ub.parts.host-code THEN DO: NEXT. END.
    END. ELSE IF obj-list.obj-type = {&shop}  THEN DO:
      FIND ub.shop  NO-LOCK WHERE ub.shop.obj-code  = obj-list.obj-code NO-ERROR.
      IF NOT AVAILABLE ub.shop  THEN DO: NEXT. END.
      IF ub.shop.host-code  <> ub.parts.host-code THEN DO: NEXT. END.
    END.
    ASSIGN is_positive = ( LOOKUP( ub.trn-doc.ext-doc-type, {&neg-list} ) = 0).
    FIND FIRST ub.country NO-LOCK WHERE ub.country.alpha1 = ub.goods.alpha1 NO-ERROR.
    ASSIGN v-country = IF AVAILABLE ub.country THEN ub.country.short-name ELSE "":U  .
     IF ub.goods.gds-type <> {&gds-office} THEN DO:
      ASSIGN v-GTD      = ub.parts.cst-code
             v-prt-qnty = ub.parts.fact-qnty.
      IF LOOKUP( ub.trn-doc.ext-doc-type, {&neg-list} ) <> 0 or ub.trn-doc.ext-doc-type = {&TDEDT_Chg_Purch_Code} THEN DO:
        ASSIGN v-prt-qnty = - v-prt-qnty.
      END.
      { str/in-vatp.i calc-parts parts. ub.trn-doc. g }

      ASSIGN v-parts-VAT = ( IF PrintRubl THEN vat-rubl-loc      ELSE vat-base-loc      )
             v-parts-SLT = ( IF PrintRubl THEN slt-rubl-loc      ELSE slt-base-loc      )
             v-tax-price = ( IF PrintRubl THEN road-tax-rubl-loc ELSE road-tax-base-loc ).
      IF v-parts-VAT = ? THEN DO: ASSIGN v-parts-VAT = 0. END.
      IF v-parts-SLT = ? THEN DO: ASSIGN v-parts-SLT = 0. END.
      IF v-tax-price = ? THEN DO: ASSIGN v-tax-price = 0. END.
      ASSIGN v-parts-price-no-VAT =
               ( IF PrintRubl THEN ( price-rubl-with-tax-loc - ( vat-rubl-loc + slt-rubl-loc + road-tax-rubl-loc ) )
                              ELSE ( price-base-with-tax-loc - ( vat-base-loc + slt-base-loc + road-tax-base-loc ) ) )
             v-parts-sum          =
               ( IF PrintRubl THEN   price-rubl-with-tax-loc ELSE price-base-with-tax-loc ) * v-prt-qnty.
    END.

    FIND tt-line WHERE
         tt-line.is-positive  = is_positive          AND
         tt-line.artic        = ub.goods.artic       AND
         tt-line.prod-type    = ub.goods.prod-type   AND
         tt-line.prod-code    = ub.goods.prod-code   AND
         tt-line.VAT-pc       = ub.doc-line.VAT-pc   AND
         tt-line.price-no-VAT = v-parts-price-no-VAT AND
         tt-line.GTD          = v-GTD                NO-ERROR.
    IF NOT AVAILABLE tt-line THEN DO:
      CREATE tt-line.
      ASSIGN tt-line.artic        = ub.goods.artic
             tt-line.prod-type    = ub.goods.prod-type
             tt-line.prod-code    = ub.goods.prod-code
             tt-line.VAT-pc       = ub.doc-line.VAT-pc
             tt-line.price-no-VAT = v-parts-price-no-VAT
             tt-line.country      = v-country
             tt-line.GTD          = v-GTD
             tt-line.is-positive  = is_positive.
    END.
    ASSIGN tt-line.gds-qty    = tt-line.gds-qty    + v-prt-qnty
           tt-line.sum-no-VAT = tt-line.sum-no-VAT + v-parts-price-no-VAT * v-prt-qnty
           tt-line.VAT        = tt-line.VAT        + v-parts-VAT          * v-prt-qnty
           tt-line.sum        = tt-line.sum        + v-parts-sum.
  END. /* FOR EACH ub.parts ... */
END PROCEDURE. /* calc-sum */

PROCEDURE print-responsible_storage :
  ASSIGN v-tot-sum-no-VAT = 0
         v-tot-VAT        = 0
         v-tot-sum        = 0.

  SESSION :SET-WAIT-STATE( "COMPILER":U ).

  RUN prn-lib-open-stream IN THIS-PROCEDURE ( INPUT parparentproc, INPUT {&LS_PS_A4}, INPUT YES, INPUT NO ).

  VIEW STREAM PrnLibStream FRAME Bottomframe.

  RUN print-header-1 IN THIS-PROCEDURE.

  FORM WITH FRAME {&FRAME-NAME}.

  FOR EACH tt-line WHERE tt-line.is-positive = YES :
    RUN print-line IN THIS-PROCEDURE.
    ASSIGN v-tot-sum-no-VAT = v-tot-sum-no-VAT + ( IF tt-line.sum-no-VAT = ? THEN 0 ELSE ABS( tt-line.sum-no-VAT ) )
           v-tot-VAT        = v-tot-VAT        + ( IF tt-line.sum-no-VAT = ? THEN 0 ELSE ABS( tt-line.VAT        ) )
           v-tot-sum        = v-tot-sum        + ( IF tt-line.sum-no-VAT = ? THEN 0 ELSE ABS( tt-line.sum        ) ).
  END. /* FOR EACH tt-line */

  PUT  STREAM PrnLibStream v-single-line FORMAT "x(198)":U.
  IF LINE-COUNTER( PrnLibStream ) + 7 > PAGE-SIZE( PrnLibStream ) THEN DO: PAGE STREAM PrnLibStream. END.

  IF v-tot-sum-no-VAT <> 0 OR v-tot-VAT <> 0 OR v-tot-sum <> 0 THEN DO:
    DISPLAY STREAM PrnLibStream "Всего"          @ ub.goods.gds-name
                                v-tot-sum-no-VAT @ v-sum-no-VAT
                                v-tot-VAT        @ v-VAT
                                v-tot-sum        @ v-sum
    WITH FRAME {&FRAME-NAME}.
  END.

  RUN print-footer IN THIS-PROCEDURE.

  HIDE   STREAM PrnLibStream FRAME Bottomframe.
  PAGE   STREAM PrnLibStream.

  OUTPUT STREAM PrnLibStream CLOSE.

  ASSIGN v-tot-sum-no-VAT = 0
         v-tot-VAT        = 0
         v-tot-sum        = 0.

  RUN prn-lib-open-stream IN THIS-PROCEDURE ( INPUT parparentproc, INPUT {&LS_PS_A4}, INPUT YES, INPUT YES ).

  VIEW STREAM PrnLibStream FRAME Bottomframe.

  RUN print-header-2 IN THIS-PROCEDURE.

  FORM WITH FRAME {&FRAME-NAME}.

  FOR EACH tt-line WHERE tt-line.is-positive = NO  :
    RUN print-line IN THIS-PROCEDURE.
    ASSIGN v-tot-sum-no-VAT = v-tot-sum-no-VAT + ( IF tt-line.sum-no-VAT = ? THEN 0 ELSE ABS( tt-line.sum-no-VAT ) )
           v-tot-VAT        = v-tot-VAT        + ( IF tt-line.sum-no-VAT = ? THEN 0 ELSE ABS( tt-line.VAT        ) )
           v-tot-sum        = v-tot-sum        + ( IF tt-line.sum-no-VAT = ? THEN 0 ELSE ABS( tt-line.sum        ) ).
  END. /* FOR EACH tt-line */

  PUT STREAM PrnLibStream v-single-line FORMAT "x(198)":U.
  IF LINE-COUNTER( PrnLibStream ) + 7 > PAGE-SIZE( PrnLibStream ) THEN DO: PAGE STREAM PrnLibStream. END.

  IF v-tot-sum-no-VAT <> 0 OR v-tot-VAT <> 0 OR v-tot-sum <> 0 THEN DO:
    DISPLAY STREAM PrnLibStream "Всего"          @ ub.goods.gds-name
                                v-tot-sum-no-VAT @ v-sum-no-VAT
                                v-tot-VAT        @ v-VAT
                                v-tot-sum        @ v-sum
    WITH FRAME {&FRAME-NAME}.
  END.

  RUN print-footer IN THIS-PROCEDURE.

  HIDE   STREAM PrnLibStream FRAME Bottomframe.

  OUTPUT STREAM PrnLibStream CLOSE.

  { rep/repfrm.i off }
  SESSION :SET-WAIT-STATE( "":U ).

  RUN prn-lib-prn-file IN THIS-PROCEDURE ( INPUT parparentproc, INPUT SheetFormat( ) ).
END PROCEDURE. /* print-responsible_storage */

PROCEDURE print-header-1 :
      IF           p-title = "отчет"        THEN DO:
  PUT STREAM PrnLibStream
    SPACE( 25 ) STRING( "ОТЧЕТ ПО РЕАЛИЗАЦИИ "                        + t-num                                   ) FORMAT "x(100)":U SKIP( 1 ).
      END. ELSE IF p-title = "счет-фактура" THEN DO:
  PUT STREAM PrnLibStream
    SPACE( 25 ) STRING( "СЧЕТ-ФАКТУРА "                               + CAPS( v-num )                           ) FORMAT "x(100)":U SKIP( 1 ).
      END.
  PUT STREAM PrnLibStream
    SPACE(  5 ) STRING( "Продавец   "                                 + buf_suppl.obj-name                      ) FORMAT "x(100)":U SKIP
    SPACE(  5 ) STRING( "Адрес   "                                    + t-a_adr                                 ) FORMAT "x(90)":U  SKIP
    SPACE(  5 ) STRING( "{&abbr_inn_allshift}/{&abbr_kpp_allshift} продавца   "                         + t-a_INN                                 ) FORMAT "x(100)":U SKIP
    SPACE(  5 ) STRING( "Грузоотправитель и его адрес   "             + TRIM( buf_suppl.obj-name )              ) FORMAT "x(100)":U SKIP
    SPACE(  5 ) STRING( "Грузополучатель  и его адрес   " + TRIM( buf_owner.obj-name ) + ", " + t-m_adr         ) FORMAT "x(130)":U SKIP
    SPACE(  5 ) STRING( "К платежно-расчетному документу  "           + p-pay-code                              ) FORMAT "x(100)":U SKIP( 1 )
    SPACE(  5 ) STRING( "Покупатель   " + buf_owner.obj-name + "(" + STRING( buf_owner.obj-code ) + ")"         ) FORMAT "x(100)":U SKIP
    SPACE(  5 ) STRING( "Адрес   "                                    + t-m_adr                                 ) FORMAT "x(90)":U  SKIP
    SPACE(  5 ) STRING( "{&abbr_inn_allshift}/{&abbr_kpp_allshift} покупателя  "                        + t-m_INN                                 ) FORMAT "x(100)":U SKIP
    SPACE(  5 ) "Дополнение (условия оплаты по договору (контракту), способ отправления и т.п.)"                  FORMAT "x(130)":U SKIP
    SPACE(  5 ) STRING( FILL( "_", 130 ) )                                                                        FORMAT "x(130)":U SKIP
    SPACE( 10 ) STRING( "Цены и суммы указаны в " + TRIM( ( IF PrintRubl THEN "{&abbr_rublyah}" ELSE base-type ) ) + "." ) FORMAT "x(120)":U SKIP( 1 ).
END PROCEDURE. /* print-header-1 */

PROCEDURE print-header-2 :
      IF           p-title = "отчет"        THEN DO:
  PUT STREAM PrnLibStream
    SPACE( 25 ) STRING( "ОТЧЕТ ПО ВОЗВРАТАМ ТОВАРА ОТ ПОКУПАТЕЛЯ "                 + t-num                      ) FORMAT "x(100)":U SKIP( 1 ).
      END. ELSE IF p-title = "счет-фактура" THEN DO:
  PUT STREAM PrnLibStream
    SPACE( 25 ) STRING( "СЧЕТ-ФАКТУРА "                                            + CAPS( v-num )              ) FORMAT "x(100)":U SKIP( 1 ).
      END.
  PUT STREAM PrnLibStream
    SPACE(  5 ) STRING( "Продавец   "                                              + buf_owner.obj-name         ) FORMAT "x(100)":U SKIP
    SPACE(  5 ) STRING( "Адрес   "                                                 + t-m_adr                    ) FORMAT "x(90)":U  SKIP
    SPACE(  5 ) STRING( "{&abbr_inn_allshift}/{&abbr_kpp_allshift} продавца  "                                       + t-m_INN                    ) FORMAT "x(100)":U SKIP
    SPACE(  5 ) STRING( "Грузоотправитель и его адрес   "                          + TRIM( buf_owner.obj-name ) ) FORMAT "x(100)":U SKIP
    SPACE(  5 ) STRING( "Грузополучатель  и его адрес   " + TRIM( buf_suppl.obj-name ) + ", " + t-a_adr         ) FORMAT "x(130)":U SKIP
    SPACE(  5 ) STRING( "К платежно-расчетному документу  "                        + p-pay-code                 ) FORMAT "x(100)":U SKIP( 1 )
    SPACE(  5 ) STRING( "Покупатель   " + buf_suppl.obj-name + "(" + STRING( buf_suppl.obj-code ) + ")"         ) FORMAT "x(100)":U SKIP
    SPACE(  5 ) STRING( "Адрес   "                                                 + t-a_adr                    ) FORMAT "x(90)":U  SKIP
    SPACE(  5 ) STRING( "{&abbr_inn_allshift}/{&abbr_kpp_allshift} покупателя  "                                     + t-a_INN                    ) FORMAT "x(100)":U SKIP
    SPACE(  5 ) "Дополнение (условия оплаты по договору (контракту), способ отправления и т.п.)"                  FORMAT "x(130)":U SKIP
    SPACE(  5 ) STRING( FILL( "_", 130 ) )                                                                        FORMAT "x(130)":U SKIP
    SPACE( 10 ) STRING( "Цены и суммы указаны в " + TRIM( ( IF PrintRubl THEN "{&abbr_rublyah}" ELSE base-type ) ) + "." ) FORMAT "x(120)":U SKIP( 1 ).
END PROCEDURE. /* print-header-2 */

PROCEDURE print-footer :
  DOWN   STREAM PrnLibStream 2 WITH FRAME {&FRAME-NAME}.
  PUT    STREAM PrnLibStream                                 SKIP( 1 )
    SPACE( 5 ) ( IF v-tot-sum + v-tot-SLT <> 0 THEN "Всего к оплате: " +
               STRING( TRIM( STRING( ABS( v-tot-sum + v-tot-SLT ), "->,>>>,>>>,>>>,>>>,>>9.99":U ) ) +
               {&curr-abbr} ) ELSE "":U )  FORMAT "x(150)":U SKIP
    SPACE( 5 ) ( IF v-tot-tax <> 0 THEN "В том числе " + v-tax-name + " : " +
                      TRIM( STRING( ABS( v-tot-tax ),              "->,>>>,>>>,>>>,>>>,>>9.99":U ) ) +
               {&curr-abbr} ELSE "":U )    FORMAT "x(150)":U SKIP( 1 )
               "Руководитель предприятия  ____________________    ____________________" FORMAT "x(70)":U
    SPACE( 5 )        "Главный бухгалтер  ____________________    ____________________" FORMAT "x(63)":U SKIP
               "                            (подпись)               (ф. и. о.) "
    SPACE( 5 ) "                            (подпись)               (ф. и. о.)"                          SKIP.
END PROCEDURE. /* print-footer */

PROCEDURE print-line :
  DEFINE VARIABLE v-start-string AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-add-string   AS CHARACTER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    FIND FIRST ub.goods NO-LOCK WHERE
               ub.goods.prod-type = tt-line.prod-type AND
               ub.goods.prod-code = tt-line.prod-code AND
               ub.goods.artic     = tt-line.artic.
    ASSIGN gds-str   = "":U
           gds-str1  = "":U
           gds-str2  = "":U.
    FIND FIRST ub.units NO-LOCK WHERE ub.units.unit-name = ub.goods.unit-base.
    IF ub.units.type = {&divisional} + "," + {&twounit} OR ub.units.type = {&divisional} + "," + {&altunit} THEN DO:
      ASSIGN str = STRING( ub.goods.artic, "x(16)":U ) + " ":U + STRING( ub.goods.Sort, "x(5)":U ) + " ":U +
                   TRIM(   ub.goods.gds-name ) + " ":U + TRIM( ub.goods.PS ).
    END.                                                                                                    ELSE DO:
      ASSIGN str = STRING( ub.goods.artic, "x(16)":U ) + " ":U + TRIM(   ub.goods.gds-name ).
    END.
    ASSIGN   gds-str1 = breakstr( str,     {&gds-len}, INPUT-OUTPUT gds-str1, INPUT-OUTPUT gds-str2 ).
    DO WHILE TRIM( gds-str2 ) <> "":U :
      ASSIGN gds-str  = gds-str2
             gds-str1 = breakstr( gds-str, {&gds-len}, INPUT-OUTPUT gds-str1, INPUT-OUTPUT gds-str2 ).
    END.
    ASSIGN   gds-str1 = breakstr( str,     {&gds-len}, INPUT-OUTPUT gds-str1, INPUT-OUTPUT gds-str2 ).

    DISPLAY STREAM PrnLibStream sym1  gds-str1                    @ ub.goods.gds-name
                                sym2  ub.goods.unit-base
                                sym3  ABS( tt-line.gds-qty      ) @ v-qnty
                                sym4  ABS( tt-line.price-no-VAT ) @ v-price-no-VAT
                                sym5  ABS( tt-line.sum-no-VAT   ) @ v-sum-no-VAT
                                sym6  "   ---" FORMAT "x(6)":U    @ v-sum-excise
                                sym7  ABS( tt-line.VAT-pc       ) @ ub.doc-line.VAT-pc
                                sym8  ABS( tt-line.VAT          ) @ v-VAT
                                sym9  ABS( tt-line.sum          ) @ v-sum
                                sym10 tt-line.country             @ v-country
                                sym11 tt-line.GTD                 @ v-GTD              sym12
    WITH FRAME {&FRAME-NAME}.
    DOWN STREAM PrnLibStream 1 WITH FRAME {&FRAME-NAME}.

    ASSIGN v-start-string = gds-str2.
    DO WHILE TRIM( v-start-string ) <> "":U :
      ASSIGN gds-str = v-start-string.
      ASSIGN v-add-string = breakstr( gds-str, {&gds-len}, INPUT-OUTPUT v-add-string, INPUT-OUTPUT v-start-string ).
      DISPLAY STREAM PrnLibStream sym1 FILL( " ":U, 17 ) + v-add-string @ ub.goods.gds-name sym2
                                  sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12
      WITH FRAME {&FRAME-NAME}.
      DOWN STREAM PrnLibStream 1 WITH FRAME {&FRAME-NAME}.
    END. /* DO WHILE ... */
    ASSIGN v-lines-counter = v-lines-counter + 1.
    { rep/repfrm.i disp v-lines-counter ReportName }
  END.
END PROCEDURE. /* print-line */