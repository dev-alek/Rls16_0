/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Печать сменного отчета ЮКОС лист 2 сбор данных

Автор: Уханов Дмитрий Юрьевич
Дата создания: 09/14/05
Author: Dmitry Ukhanov
Creation date: 09/14/05

*/
using ibs.th.str.*.
block-level on error undo, throw.

DEFINE INPUT PARAMETER pobj-type             LIKE ub.shift-obj.obj-type   NO-UNDO.
DEFINE INPUT PARAMETER pobj-code             LIKE ub.shift-obj.obj-code   NO-UNDO.
DEFINE INPUT PARAMETER pshift-date           LIKE ub.shift-obj.shift-date NO-UNDO.
DEFINE INPUT PARAMETER pshift-num            LIKE ub.shift-obj.shift-num  NO-UNDO.
DEFINE INPUT PARAMETER pshift-date1          LIKE ub.shift-obj.shift-date NO-UNDO.
DEFINE INPUT PARAMETER pshift-num1           LIKE ub.shift-obj.shift-num  NO-UNDO.
DEFINE INPUT PARAMETER p-previous-shift-date AS   DATE                    NO-UNDO.
define input parameter p-batch               as integer                   no-undo.
define input parameter p-codex-id            as integer                   no-undo.
define input parameter p-ruleset-id          as integer                   no-undo.

DEFINE VARIABLE vss-revision    AS CHARACTER NO-UNDO INITIAL "$Revision$":U.
DEFINE VARIABLE vss-author      AS CHARACTER NO-UNDO INITIAL "$Author$":U.
DEFINE VARIABLE vss-date        AS CHARACTER NO-UNDO INITIAL "$Date$":U.
DEFINE VARIABLE vss-workfile    AS CHARACTER NO-UNDO INITIAL "$Workfile$":U.
DEFINE VARIABLE vss-archive     AS CHARACTER NO-UNDO INITIAL "$Archive$":U.
DEFINE VARIABLE vss-description AS CHARACTER NO-UNDO INITIAL "Сбор данных для сменного отчета - лист 2 ":U.

{ cmp/vssrevis.i                }
{ cmp/str-glbl.i                }
{ cmp/library.i                 }
{ rep/real-2df.i SHARED treal-2 }
{ rep/icm-2df.i  SHARED         }
{ arc/ot-lnrv.i  def            }
{ trg/factord.i                 }
{ gbl/clntattr.i                }
{ str/clcprtsl.i                }
{ rep/real-2cr.i treal-2        }
{ arc/ot-lnrv.i  calc           }
{ ref/gds-attr.i }
{ str/trdcalib.i }
{ str/is-sug.i }
{ str/is-gas.i }

DEFINE VARIABLE loc-ii              AS INTEGER   NO-UNDO INITIAL 1.
DEFINE VARIABLE for-supp-name       AS CHARACTER NO-UNDO.
DEFINE VARIABLE vdoc-num            LIKE ub.price-list.doc-num NO-UNDO.
DEFINE VARIABLE vprice-sale         LIKE ub.price-list.price-sale NO-UNDO.
DEFINE VARIABLE vroad-tax           AS DECIMAL   NO-UNDO.
DEFINE VARIABLE vexcise             AS DECIMAL   NO-UNDO.
DEFINE VARIABLE acc-other-qnty1     AS DECIMAL   NO-UNDO.
DEFINE VARIABLE acc-other-qnty2     AS DECIMAL   NO-UNDO.
DEFINE VARIABLE acc-other-netto     AS DECIMAL   NO-UNDO.
DEFINE VARIABLE acc-other-found     AS LOGICAL   NO-UNDO.
DEFINE VARIABLE acc-cli-qnty1       AS DECIMAL   NO-UNDO.
DEFINE VARIABLE acc-cli-qnty2       AS DECIMAL   NO-UNDO.
DEFINE VARIABLE acc-cli-netto       AS DECIMAL   NO-UNDO.
DEFINE VARIABLE acc-cli-found       AS LOGICAL   NO-UNDO.
DEFINE VARIABLE current-cli         AS INTEGER   NO-UNDO.
DEFINE VARIABLE current-cli-type    AS CHARACTER NO-UNDO.
DEFINE VARIABLE dop-sum             AS DECIMAL   NO-UNDO.
DEFINE VARIABLE dop-qnty            AS DECIMAL   NO-UNDO.
DEFINE VARIABLE dop-kg              AS DECIMAL   NO-UNDO.
DEFINE VARIABLE found-in-previous   AS LOGICAL   NO-UNDO.
DEFINE VARIABLE mc                  LIKE ub.bar-code.b-code NO-UNDO.
DEFINE VARIABLE v-value-attr        AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-attr-value        AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-attr-type         AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-sum-base          LIKE ub.ot-line.sum-base NO-UNDO.
DEFINE VARIABLE p-base-code         AS INTEGER   NO-UNDO.
DEFINE VARIABLE v-qnty1             AS DECIMAL   NO-UNDO.
DEFINE VARIABLE v-qnty2             AS DECIMAL   NO-UNDO.
DEFINE VARIABLE v-qnty3             AS DECIMAL   NO-UNDO.
define variable v-value             as character no-undo.
define variable v-type              as character no-undo.
define variable v-doc-code          as character no-undo.

define variable v-InfoSectionsTotal as class     InfoSectionsTotal no-undo .
define variable v-InfoSection       as class     InfoSection       no-undo .
define variable iNum                as integer   no-undo .



define temp-table temp-ptrl-goods no-undo
  field gds-code  as integer
  field ptrl-good as logical /*no -good yes -petrol*/
  index pi as unique primary
  gds-code
  .

/* находим fact-order */
{ rep/r-shftfo.i attr-arh-detail-date }

v-InfoSectionsTotal = new InfoSectionsTotal().
v-InfoSection = new InfoSection().
    
DEFINE BUFFER previous-rvs-doc    FOR ub.rvs-doc.
DEFINE BUFFER previous-rvs-line   FOR ub.rvs-line.
DEFINE BUFFER this-shift-rvs-doc  FOR ub.rvs-doc.
DEFINE BUFFER this-shift-rvs-line FOR ub.rvs-line.
DEFINE BUFFER buf_doc-line        FOR ub.doc-line.
DEFINE BUFFER buf_inv-line        FOR ub.inv-line.
DEFINE BUFFER buf_trn-doc         FOR ub.trn-doc.


/* записываем во временную таблицу все топлива за сверку данной смены */
FIND FIRST ub.rvs-doc NO-LOCK WHERE
  ub.rvs-doc.obj-type   = pobj-type    AND
  ub.rvs-doc.obj-code   = pobj-code    AND
  ub.rvs-doc.shift-date = pshift-date  AND
  ub.rvs-doc.shift-num  = pshift-num   AND
  ub.rvs-doc.status_    = {&fact}      AND
  ub.rvs-doc.rvs-type   = {&rvs-shift} NO-ERROR.
IF NOT AVAILABLE ub.rvs-doc THEN 
DO:
  return error substitute("&1 &2 &3&4Не найдена сверка типа СМН объект &5&6 смена &7 порядок &8"
    ,vss-workfile
    ,vss-revision
    ,vss-description
    ,{&new-line}
    ,pobj-type
    ,pobj-code
    ,pshift-date
    ,pshift-num).
END.

FIND FIRST ub.sysconf NO-LOCK WHERE
  ub.sysconf.host-code = ub.rvs-doc.host-code NO-ERROR.
IF NOT AVAILABLE ub.sysconf THEN 
DO:
  return error substitute("&1 &2 &3&4Не найдена фирма типа &5 СМН объект &6&7 смена &8 порядок &9"
    ,vss-workfile
    ,vss-revision
    ,vss-description
    ,{&new-line}
    ,ub.rvs-doc.host-code
    ,pobj-type
    ,pobj-code
    ,pshift-date
    ,pshift-num).
END.
ASSIGN 
  p-base-code = ub.sysconf.base-code.

/* нам надо еще знать сверку за предыдущую смену */
/* предыдущая смена по объекту найдена в r-shftfo.i previous-shift-obj */
IF AVAILABLE previous-shift-obj THEN 
DO:
  FIND FIRST previous-rvs-doc NO-LOCK WHERE
    previous-rvs-doc.obj-type   = pobj-type                     AND
    previous-rvs-doc.obj-code   = pobj-code                     AND
    previous-rvs-doc.shift-date = previous-shift-obj.shift-date AND
    previous-rvs-doc.shift-num  = previous-shift-obj.shift-num  AND
    previous-rvs-doc.status_    = {&fact}                       AND
    previous-rvs-doc.rvs-type   = {&rvs-shift}                  NO-ERROR.
END.


define temp-table temp-rvs no-undo
  FIELD gds-code   as integer
  FIELD shift-date like ub.rvs-doc.shift-date
  FIELD shift-num  like ub.rvs-doc.shift-num
  field pl-code    like ub.rvs-line.pl-code
  field rvs-code   like ub.rvs-line.rvs-code
  INDEX pi IS UNIQUE PRIMARY gds-code pl-code
  .
define buffer bf_temp-rvs for temp-rvs .

for each  ub.rvs-doc NO-LOCK WHERE
  ub.rvs-doc.obj-type   = pobj-type    AND
  ub.rvs-doc.obj-code   = pobj-code    AND
  ub.rvs-doc.shift-date >= pshift-date  AND
  ub.rvs-doc.shift-date <= pshift-date1  AND
  ub.rvs-doc.status_    = {&fact}      AND
  ub.rvs-doc.rvs-type   = {&rvs-shift}
  break by ub.rvs-doc.shift-date by ub.rvs-doc.shift-num:
  if ub.rvs-doc.shift-date = pshift-date  and ub.rvs-doc.shift-num < pshift-num  then next .
  if ub.rvs-doc.shift-date = pshift-date1 and ub.rvs-doc.shift-num > pshift-num1 then next .



  _rvs-line:
  FOR EACH ub.rvs-line NO-LOCK WHERE
    ub.rvs-line.rvs-code = ub.rvs-doc.rvs-code AND
    ub.rvs-line.obj-type = ub.rvs-doc.obj-type AND
    ub.rvs-line.obj-code = ub.rvs-doc.obj-code
    BREAK BY ub.rvs-line.gds-code :
    FIND FIRST t-2 WHERE t-2.gds-code = ub.rvs-line.gds-code NO-ERROR.
    IF NOT AVAILABLE t-2 THEN 
    DO:
      v-value = ''.
      run gds-attr-value in this-procedure (
        input ub.rvs-line.gds-code
        ,input {&attr-ptrl-as-good}
        ,output v-value
        ,output v-type) no-error.
      if logical(v-value) then next _rvs-line.
      FIND FIRST ub.goods NO-LOCK WHERE ub.goods.gds-code = ub.rvs-line.gds-code NO-ERROR.
      IF AVAILABLE ub.goods THEN 
      DO:
          /* найдем последнюю розничную цену */
        { gbl/bcodeprc.i pobj-type pobj-code ub.rvs-line.gds-code 0 fo vdoc-num vprice-sale vroad-tax vexcise no-error }
        ASSIGN 
          mc = ub.goods.gds-code.
        { gbl/gdsbcode.i ub.goods.gds-code ? mc }
        CREATE t-2.
        ASSIGN
          t-2.gds-code      = ub.rvs-line.gds-code
          t-2.main-code     = mc
          t-2.gds-name      = ub.goods.gds-name
          t-2.artic         = ub.goods.artic
          t-2.prod-type     = ub.goods.prod-type
          t-2.prod-code     = ub.goods.prod-code
          t-2.last-price    = vprice-sale
          found-in-previous = NO
          .
      end.
    end.

    IF AVAILABLE previous-rvs-doc THEN 
    DO:
      FOR EACH previous-rvs-line NO-LOCK WHERE
        previous-rvs-line.rvs-code = previous-rvs-doc.rvs-code AND
        previous-rvs-line.pl-code  = ub.rvs-line.pl-code       AND
        previous-rvs-line.gds-code = t-2.gds-code              :

        ASSIGN 
          found-in-previous = YES .
        if pshift-date = ub.rvs-doc.shift-date and pshift-num  = ub.rvs-doc.shift-num then 
        do:
          ASSIGN
            t-2.qnty1-before = t-2.qnty1-before + previous-rvs-line.system-qnty
            t-2.qnty2-before = t-2.qnty2-before + previous-rvs-line.system-cli-qnty
            .
          end.  

      END. /* FOR EACH previous-rvs-line */
    END. /* IF AVAILABLE previous-rvs-doc */
    IF found-in-previous = NO THEN 
    DO:
      FOR EACH this-shift-rvs-doc  WHERE
        this-shift-rvs-doc.obj-type   =  pobj-type    AND
        this-shift-rvs-doc.obj-code   =  pobj-code    AND
        this-shift-rvs-doc.shift-date =  pshift-date  AND
        this-shift-rvs-doc.shift-num  =  pshift-num   AND
        this-shift-rvs-doc.status_    =  {&fact}      AND
        this-shift-rvs-doc.rvs-type   <> {&rvs-shift}
        , EACH this-shift-rvs-line WHERE
        this-shift-rvs-line.rvs-code  =  this-shift-rvs-doc.rvs-code AND
        this-shift-rvs-line.obj-type  =  this-shift-rvs-doc.obj-type AND
        this-shift-rvs-line.obj-code  =  this-shift-rvs-doc.obj-code AND
        this-shift-rvs-line.gds-code  =  t-2.gds-code
        BY this-shift-rvs-doc.fact-order
        :
        ASSIGN
          t-2.qnty1-before = this-shift-rvs-line.system-qnty
          t-2.qnty2-before = this-shift-rvs-line.system-cli-qnty
          .
        LEAVE.
      END. /* FOR EACH this-shift-rvs-doc */
    END. /* IF NOT found-in-previous */
/*if ub.rvs-line.gds-code = 107305 then run gbl/inidebug.p.*/

    find first temp-rvs where temp-rvs.gds-code = ub.rvs-line.gds-code no-error .
    if available temp-rvs then 
    do:
      if temp-rvs.shift-date < ub.rvs-doc.shift-date or temp-rvs.shift-date = ub.rvs-doc.shift-date and temp-rvs.shift-num  <= ub.rvs-doc.shift-num then 
      do:
        if temp-rvs.pl-code <> ub.rvs-line.pl-code then do:
        
        ASSIGN
          t-2.qnty1-after = t-2.qnty1-after + ub.rvs-line.system-qnty
          t-2.qnty2-after = t-2.qnty2-after + ub.rvs-line.system-cli-qnty
          .
          if temp-rvs.rvs-code <> ub.rvs-line.rvs-code then temp-rvs.pl-code = ub.rvs-line.pl-code .
/*          find first bf_temp-rvs no-lock where bf_temp-rvs.gds-code = temp-rvs.gds-code and*/
/*          bf_temp-rvs.pl-code = temp-rvs.pl-code and                                       */
/*          bf_temp-rvs.rvs-code = temp-rvs.rvs-code no-error .                              */
/*          if not available (bf_temp-rvs) then                                              */
/*          temp-rvs.pl-code = ub.rvs-line.pl-code                                           */
/*          .          .                                                                     */
          end.
          else do:
        ASSIGN
          t-2.qnty1-after = ub.rvs-line.system-qnty
          t-2.qnty2-after = ub.rvs-line.system-cli-qnty
          temp-rvs.rvs-code   = ub.rvs-line.rvs-code
          .            
          end.
      end.
    end.
    else 
    do:
      
      create temp-rvs .
      assign
        temp-rvs.gds-code   = ub.rvs-line.gds-code
        temp-rvs.shift-date = ub.rvs-doc.shift-date
        temp-rvs.shift-num  = ub.rvs-doc.shift-num
        temp-rvs.pl-code    = ub.rvs-line.pl-code
        temp-rvs.rvs-code   = ub.rvs-line.rvs-code
        t-2.qnty1-after     = ub.rvs-line.system-qnty
        t-2.qnty2-after     = ub.rvs-line.system-cli-qnty 
        .
    end.
    
  END. /* FOR EACH ub.rvs-line */

end.


IF moving <> YES THEN 
DO: 
  RETURN. 
END.
/* имеем готовый список топливных товаров для сменного отчета */

/* начинаем заполнение данными по приходу */
FOR EACH  ub.trn-doc  NO-LOCK
  WHERE ub.trn-doc.obj-type   = pobj-type
  AND ub.trn-doc.obj-code   = pobj-code
  AND ub.trn-doc.fact-order >= prev-fo
  AND ub.trn-doc.fact-order <= fo
  /* AND ub.trn-doc.internal   = NO */
  AND ub.trn-doc.status_    = {&fact}
  AND ub.trn-doc.doc-type   = {&income}
  , EACH  ub.doc-line NO-LOCK WHERE
  ub.doc-line.doc-code = ub.trn-doc.doc-code
  , FIRST t-2                 WHERE
  t-2.artic     = ub.doc-line.artic     AND
  t-2.prod-type = ub.doc-line.prod-type AND
  t-2.prod-code = ub.doc-line.prod-code
  BREAK BY ub.doc-line.artic
  BY ub.doc-line.prod-type
  BY ub.doc-line.prod-code
  by ub.trn-doc.cli-code
  :
  IF FIRST-OF( ub.doc-line.prod-code ) THEN ASSIGN loc-ii = 1.

  FIND FIRST ub.clients NO-LOCK WHERE ub.clients.obj-type = ub.trn-doc.cli-type AND ub.clients.obj-code = ub.trn-doc.cli-code NO-ERROR.
  ASSIGN 
    for-supp-name = ( IF AVAILABLE ub.clients THEN ub.clients.obj-name ELSE "":U ) .

  FIND FIRST ub.inv-line NO-LOCK WHERE
    ub.inv-line.doc-code  = ub.doc-line.doc-code  AND
    ub.inv-line.artic     = ub.doc-line.artic     AND
    ub.inv-line.prod-type = ub.doc-line.prod-type AND
    ub.inv-line.prod-code = ub.doc-line.prod-code NO-ERROR.

          /* номер документа из атрибутов */
    { str/tdat-val.i
        ub.trn-doc.doc-code
        {&trdcattr-nids}
        v-attr-value
        v-attr-type
        }
  if v-attr-value <> "" then v-doc-code = v-attr-value .  
  else v-doc-code       = ub.trn-doc.doc-code .
      
    { str/tdat-val.i                                    
      ub.trn-doc.doc-code
      {&trdcattr-is-fuel}
      v-value 
      v-type 
      no-error
    }

  if v-value <> "yes" then 
  do:
    CREATE tincome-2.
    assign
      tincome-2.gds-code     = t-2.gds-code
      tincome-2.supp-name    = for-supp-name
      tincome-2.supp-type    = ub.trn-doc.cli-type
      tincome-2.supp-code    = ub.trn-doc.cli-code
      tincome-2.doc-code     = v-doc-code
      tincome-2.doc-code-trn = ub.trn-doc.doc-code
      tincome-2.qnty2        = ( IF AVAILABLE ub.inv-line THEN ub.inv-line.wast-cli-qnty ELSE 0 )
      tincome-2.qnty3        = ub.doc-line.cli-qnty
      tincome-2.temperature  = ub.doc-line.temperature
      tincome-2.density      = ( IF tincome-2.qnty2 / ub.doc-line.fact-qnty = ? THEN 0 ELSE tincome-2.qnty2 / ub.doc-line.fact-qnty )
      tincome-2.naturalloss  = 0
      tincome-2.is-fact      = YES
      tincome-2.ii           = loc-ii.
    if is-sug(t-2.gds-code) then tincome-2.qnty1       = ub.doc-line.fact-qnty * tincome-2.density .
    else tincome-2.qnty1       = ub.doc-line.fact-qnty .
    assign
      loc-ii  = loc-ii + 1
      v-qnty1 = v-qnty1 + tincome-2.qnty1
      v-qnty2 = v-qnty2 + tincome-2.qnty2
      v-qnty3 = v-qnty3 + tincome-2.qnty3
      .

      
  end.
  else 
  do:  
    v-InfoSectionsTotal:Initialization(ub.trn-doc.doc-code, t-2.gds-code).
    v-InfoSectionsTotal:GetDBAllAttr().
    do iNum = 1 to v-InfoSectionsTotal:SectionNum:  
      v-InfoSectionsTotal:GetInfoSectionProp(iNum).
      CREATE tincome-2.
      assign
        tincome-2.gds-code     = t-2.gds-code
        tincome-2.supp-name    = if iNum = 1 then for-supp-name else ""
        tincome-2.supp-type    = ub.trn-doc.cli-type
        tincome-2.supp-code    = ub.trn-doc.cli-code
        tincome-2.doc-code     = v-doc-code + "/" + v-InfoSectionsTotal:InfoSectionCurr:SectionName
        tincome-2.doc-code-trn = ub.trn-doc.doc-code
        tincome-2.qnty1       = v-InfoSectionsTotal:InfoSectionCurr:DocQnty
        tincome-2.qnty3        = ub.doc-line.cli-qnty
        tincome-2.qnty2        = ( IF AVAILABLE ub.inv-line THEN (v-InfoSectionsTotal:InfoSectionCurr:DocQnty * v-InfoSectionsTotal:InfoSectionCurr:DocDensity) ELSE 0 )
        tincome-2.temperature  = v-InfoSectionsTotal:GetInfoSectionProp(iNum):DensTemp
        tincome-2.density      = ( IF tincome-2.qnty2 / tincome-2.qnty1 = ? THEN 0 ELSE tincome-2.qnty2 / tincome-2.qnty1 )
        tincome-2.naturalloss  = v-InfoSectionsTotal:InfoSectionCurr:NaturalLoss
        tincome-2.is-fact      = YES
        tincome-2.ii           = loc-ii
        loc-ii                 = loc-ii + 1.
      if is-sug(t-2.gds-code) then tincome-2.qnty1       = ub.doc-line.fact-qnty * tincome-2.density .
      else tincome-2.qnty1       = v-InfoSectionsTotal:InfoSectionCurr:DocQnty .
      if is-gas(t-2.gds-code)
      then
      assign
        tincome-2.qnty1 = ub.doc-line.fact-qnty
        tincome-2.qnty2 = ub.doc-line.doc-qnty
      .
      v-qnty1               = v-qnty1 + tincome-2.qnty1 .
      v-qnty2               = v-qnty2 + tincome-2.qnty2 .
      v-qnty3               = v-qnty3 + tincome-2.qnty3
        .
    end.
  end.
  if last-of(ub.trn-doc.cli-code) then 
  do:
    if pshift-date <> pshift-date1 or (pshift-date = pshift-date1 and pshift-num <> pshift-num1) then 
    do:
      CREATE tincome-2.
      ASSIGN
        tincome-2.gds-code    = t-2.gds-code
        tincome-2.supp-name   = "Итого по поставщику"
        tincome-2.supp-type   = ub.trn-doc.cli-type
        tincome-2.supp-code   = ub.trn-doc.cli-code
        tincome-2.qnty1       = v-qnty1
        tincome-2.qnty2       = v-qnty2
        tincome-2.qnty3       = v-qnty3
        tincome-2.temperature = ?
        tincome-2.density     = ?
        tincome-2.is-fact     = no
        tincome-2.ii          = loc-ii
        loc-ii                = loc-ii + 1
        v-qnty1               = 0
        v-qnty2               = 0
        v-qnty3               = 0
        .
    end.
  end.
END. /* FOR EACH ub.trn-doc */

FOR EACH t-2 NO-LOCK :
  ASSIGN
    acc-other-found = NO
    acc-other-qnty1 = 0
    acc-other-qnty2 = 0
    acc-other-netto = 0
    .
  /* соберем данные по спецклиентам */
  FOR EACH ub.clients-attr WHERE ub.clients-attr.attr-code  = {&attr-shftrep2} AND ub.clients-attr.attr-value = "yes":U :
    ASSIGN
      current-cli      = ub.clients-attr.obj-code
      current-cli-type = ub.clients-attr.obj-type
      .
    FIND FIRST ub.clients NO-LOCK WHERE ub.clients.obj-type = current-cli-type AND ub.clients.obj-code = current-cli NO-ERROR.
    IF AVAILABLE ub.clients THEN 
    DO:
      RUN ot-lnrv IN THIS-PROCEDURE (  INPUT       pobj-type
        ,  INPUT       pobj-code
        ,  INPUT       current-cli-type
        ,  INPUT       current-cli
        ,  INPUT       t-2.artic
        ,  INPUT       t-2.prod-type
        ,  INPUT       t-2.prod-code
        ,  INPUT       prev-fo
        ,  INPUT       fo
        ,  INPUT       {&arh-sale}
        ,  INPUT       ?
        , OUTPUT TABLE tt-ot-line        ) NO-ERROR.
      IF NOT ERROR-STATUS :ERROR THEN 
      DO:
        ASSIGN
          acc-cli-qnty1 = 0
          acc-cli-qnty2 = 0
          acc-cli-netto = 0
          acc-cli-found = NO
          .
        FOR EACH tt-ot-line NO-LOCK WHERE
          tt-ot-line.cli-type  = current-cli-type AND
          tt-ot-line.cli-code  = current-cli      AND
          tt-ot-line.artic     = t-2.artic        AND
          tt-ot-line.prod-type = t-2.prod-type    AND
          tt-ot-line.prod-code = t-2.prod-code    :
          /* по клиенту суммируем все кроме прихода */
          IF tt-ot-line.ext-doc-type <> {&TDEDT_Pri_Vnesh} THEN 
          DO:
            ASSIGN
              acc-cli-found = YES
              acc-cli-qnty1 = acc-cli-qnty1 + tt-ot-line.fact-qnty
              acc-cli-netto = acc-cli-netto + tt-ot-line.sum-base
              .
            FOR EACH  buf_doc-line NO-LOCK WHERE
              buf_doc-line.obj-type      = tt-ot-line.obj-type     AND
              buf_doc-line.obj-code      = tt-ot-line.obj-code     AND
              buf_doc-line.prod-type     = tt-ot-line.prod-type    AND
              buf_doc-line.prod-code     = tt-ot-line.prod-code    AND
              buf_doc-line.artic         = tt-ot-line.artic        AND
              buf_doc-line.ext-doc-type  = tt-ot-line.ext-doc-type AND
              buf_doc-line.status_       = {&fact}                 AND
              buf_doc-line.fact-order   >= prev-fo                 AND
              buf_doc-line.fact-order   <= fo
              , FIRST buf_trn-doc  NO-LOCK WHERE
              buf_trn-doc.doc-code = buf_doc-line.doc-code AND
              buf_trn-doc.cli-type = current-cli-type      AND
              buf_trn-doc.cli-code = current-cli
              :
              IF tt-ot-line.ext-doc-type = {&TDEDT_Inv} or tt-ot-line.ext-doc-type = {&TDEDT_Peresort} THEN 
              DO:
                ASSIGN 
                  acc-cli-qnty2 = acc-cli-qnty2 + ( IF buf_doc-line.cli-qnty = ? THEN 0 ELSE buf_doc-line.cli-qnty ).
              END.
              ELSE 
              DO:
                FIND FIRST buf_inv-line NO-LOCK WHERE
                  buf_inv-line.doc-code  = buf_doc-line.doc-code  AND
                  buf_inv-line.artic     = buf_doc-line.artic     AND
                  buf_inv-line.prod-type = buf_doc-line.prod-type AND
                  buf_inv-line.prod-code = buf_doc-line.prod-code NO-ERROR.
                ASSIGN 
                  acc-cli-qnty2 = acc-cli-qnty2 + ( IF AVAILABLE buf_inv-line THEN ( IF buf_inv-line.wast-cli-qnty = ? THEN 0 ELSE ( - buf_inv-line.wast-cli-qnty ) ) ELSE 0 ).
              END.
            END. /* FOR EACH buf_doc-line */
          END. /* IF tt-ot-line.ext-doc-type <> {&TDEDT_Pri_Vnesh} */
        END. /* FOR EACH tt-ot-line */
        IF acc-cli-found = YES THEN 
        DO:
          RUN create-treal-2 IN THIS-PROCEDURE ( INPUT t-2.gds-code,
            INPUT -2,
            INPUT p-base-code,
            INPUT - acc-cli-qnty1,
            INPUT - acc-cli-qnty2,
            INPUT - acc-cli-netto,
            INPUT ub.clients.obj-name,
            INPUT NO,
            INPUT ?                    ) NO-ERROR.
        END.
      END. /* IF NOT ERROR-STATUS :ERROR */
    END. /* IF AVAILABLE ub.clients */
  END. /* FOR EACH ub.clients-attr */

  FOR EACH  ub.trn-doc NO-LOCK WHERE
    ub.trn-doc.obj-type     = pobj-type          AND
    ub.trn-doc.obj-code     = pobj-code          AND
    ub.trn-doc.fact-order >= prev-fo             and
    ub.trn-doc.fact-order <= fo                  and
    ub.trn-doc.internal     = NO                 AND
    ub.trn-doc.status_      = {&fact}            AND
    ub.trn-doc.ext-doc-type = {&TDEDT_Inv}       OR
    ub.trn-doc.obj-type     = pobj-type          AND
    ub.trn-doc.obj-code     = pobj-code          AND
    ub.trn-doc.fact-order >= prev-fo             and
    ub.trn-doc.fact-order <= fo                  and
    ub.trn-doc.internal     = NO                 AND
    ub.trn-doc.status_      = {&fact}            AND
    ub.trn-doc.ext-doc-type = {&TDEDT_Peresort}
    , FIRST ub.doc-line NO-LOCK WHERE
    ub.doc-line.doc-code  = ub.trn-doc.doc-code AND
    ub.doc-line.artic     = t-2.artic           AND
    ub.doc-line.prod-type = t-2.prod-type       AND
    ub.doc-line.prod-code = t-2.prod-code
    :
    RUN clntattr-value IN THIS-PROCEDURE (  INPUT ub.trn-doc.cli-type, INPUT ub.trn-doc.cli-code, INPUT {&attr-shftrep2}, OUTPUT v-attr-value, OUTPUT v-attr-type).
    IF v-attr-value = "no":U THEN 
    DO:
      RUN clcprtsl_calc-line IN THIS-PROCEDURE ( INPUT RECID( ub.doc-line ) ).
      FIND FIRST tt-allsum-line NO-LOCK WHERE tt-allsum-line.sum-type = {&sum-general} NO-ERROR.
      ASSIGN 
        v-sum-base = ( IF AVAILABLE tt-allsum-line THEN tt-allsum-line.sum-dsc-base-doc ELSE 0.0 ).

      RUN create-treal-2 IN THIS-PROCEDURE ( INPUT t-2.gds-code
        , INPUT -4
        , INPUT 0
        , INPUT - ub.doc-line.fact-qnty
        , INPUT - ub.doc-line.cli-qnty
        , INPUT - v-sum-base
        , INPUT "Инвентаризация"
        , INPUT NO
        , INPUT ?                          ) NO-ERROR.
    END. /* v-attr-value = "no":U */
  END. /* FOR EACH ub.trn-doc */

  FOR EACH  ub.trn-doc NO-LOCK WHERE
    ub.trn-doc.obj-type     = pobj-type          AND
    ub.trn-doc.obj-code     = pobj-code          AND
    ub.trn-doc.fact-order >= prev-fo             and
    ub.trn-doc.fact-order <= fo                  and
    ub.trn-doc.internal     = NO                 AND
    ub.trn-doc.status_      = {&fact}            AND
    ub.trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}
    , FIRST ub.doc-line NO-LOCK WHERE
    ub.doc-line.doc-code  = ub.trn-doc.doc-code AND
    ub.doc-line.artic     = t-2.artic           AND
    ub.doc-line.prod-type = t-2.prod-type       AND
    ub.doc-line.prod-code = t-2.prod-code
    :
    RUN clntattr-value IN THIS-PROCEDURE ( INPUT ub.trn-doc.cli-type , INPUT ub.trn-doc.cli-code, INPUT {&attr-shftrep2}, OUTPUT v-attr-value, OUTPUT v-attr-type ).
    IF v-attr-value = "no":U THEN 
    DO:
      RUN clcprtsl_calc-line IN THIS-PROCEDURE ( INPUT RECID( ub.doc-line ) ).
      FIND FIRST tt-allsum-line NO-LOCK WHERE tt-allsum-line.sum-type = {&sum-general} NO-ERROR.
      ASSIGN 
        v-sum-base = ( IF AVAILABLE tt-allsum-line THEN tt-allsum-line.sum-dsc-base-doc ELSE 0.0 ).
      FIND FIRST ub.inv-line NO-LOCK WHERE
        ub.inv-line.doc-code  = ub.doc-line.doc-code  AND
        ub.inv-line.artic     = ub.doc-line.artic     AND
        ub.inv-line.prod-type = ub.doc-line.prod-type AND
        ub.inv-line.prod-code = ub.doc-line.prod-code NO-ERROR.
      RUN create-treal-2 IN THIS-PROCEDURE ( INPUT t-2.gds-code
        , INPUT -3
        , INPUT 0
        , INPUT ub.doc-line.fact-qnty
        , INPUT ( IF AVAILABLE ub.inv-line THEN ub.inv-line.wast-cli-qnty ELSE 0 )
        , INPUT v-sum-base
        , INPUT "Отпуск без ККМ"
        , INPUT NO
        , INPUT ?                          ) NO-ERROR.
    END. /* v-attr-value = "no":U */
  END. /* FOR EACH ub.trn-doc */
  /* Расход внутренний */

  FOR EACH  ub.trn-doc NO-LOCK WHERE
    ( ub.trn-doc.obj-type     = pobj-type         AND
    ub.trn-doc.obj-code     = pobj-code          AND
    ub.trn-doc.fact-order >= prev-fo             and
    ub.trn-doc.fact-order <= fo                  and
    /*            ub.trn-doc.internal     = NO                 AND*/
    ub.trn-doc.status_      = {&fact}            AND
    ub.trn-doc.ext-doc-type = {&TDEDT_Ras_Perem} ) OR
          
    ( ub.trn-doc.obj-type     = pobj-type          AND
    ub.trn-doc.obj-code     = pobj-code          AND 
    ub.trn-doc.fact-order >= prev-fo             and
    ub.trn-doc.fact-order <= fo                  and
    ub.trn-doc.status_      = {&fact}            AND  
    ub.trn-doc.ext-doc-type = {&TDEDT_Ras_Object} )
             
    , FIRST ub.doc-line NO-LOCK WHERE
    ub.doc-line.doc-code  = ub.trn-doc.doc-code AND
    ub.doc-line.artic     = t-2.artic           AND
    ub.doc-line.prod-type = t-2.prod-type       AND
    ub.doc-line.prod-code = t-2.prod-code
    :
    RUN clntattr-value IN THIS-PROCEDURE ( INPUT ub.trn-doc.cli-type , INPUT ub.trn-doc.cli-code, INPUT {&attr-shftrep2}, OUTPUT v-attr-value, OUTPUT v-attr-type ).
    IF v-attr-value = "no":U THEN 
    DO:
      RUN clcprtsl_calc-line IN THIS-PROCEDURE ( INPUT RECID( ub.doc-line ) ).
      FIND FIRST tt-allsum-line NO-LOCK WHERE tt-allsum-line.sum-type = {&sum-general} NO-ERROR.
      ASSIGN 
        v-sum-base = ( IF AVAILABLE tt-allsum-line THEN tt-allsum-line.sum-dsc-base-doc ELSE 0.0 ).
      FIND FIRST ub.inv-line NO-LOCK WHERE
        ub.inv-line.doc-code  = ub.doc-line.doc-code  AND
        ub.inv-line.artic     = ub.doc-line.artic     AND
        ub.inv-line.prod-type = ub.doc-line.prod-type AND
        ub.inv-line.prod-code = ub.doc-line.prod-code NO-ERROR.
      RUN create-treal-2 IN THIS-PROCEDURE ( INPUT t-2.gds-code
        , INPUT -5
        , INPUT 0
        , INPUT ub.doc-line.fact-qnty
        , INPUT ( IF AVAILABLE ub.inv-line THEN ub.inv-line.wast-cli-qnty ELSE 0 )
        , INPUT v-sum-base
        , INPUT "Расход внутр."
        , INPUT NO
        , INPUT ?                          ) NO-ERROR.
    END. /* v-attr-value = "no":U */
  END. /* FOR EACH ub.trn-doc */

  /* прочие расходы: списание, возврат внешний, возврат поставщику */
  _trn-doc:
  FOR EACH  ub.trn-doc NO-LOCK WHERE
    ub.trn-doc.obj-type     = pobj-type              AND
    ub.trn-doc.obj-code     = pobj-code              AND
    ub.trn-doc.fact-order >= prev-fo             and
    ub.trn-doc.fact-order <= fo                  and
    ub.trn-doc.internal     = NO                     AND
    ub.trn-doc.status_      = {&fact}                AND
    (  ub.trn-doc.ext-doc-type = {&TDEDT_Spi_Vnesh}     OR
    ub.trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh} OR
    ub.trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}    )
    , FIRST ub.doc-line NO-LOCK WHERE
    ub.doc-line.doc-code  = ub.trn-doc.doc-code AND
    ub.doc-line.artic     = t-2.artic           AND
    ub.doc-line.prod-type = t-2.prod-type       AND
    ub.doc-line.prod-code = t-2.prod-code
    :
    if ub.trn-doc.ext-doc-type = {&TDEDT_Spi_Vnesh} then 
    do:
      RUN clntattr-value IN THIS-PROCEDURE (  INPUT ub.trn-doc.cli-type, INPUT ub.trn-doc.cli-code, INPUT {&attr-shftrep2}, OUTPUT v-attr-value, OUTPUT v-attr-type ).
      if v-attr-value = "yes" then NEXT.
    end.

    RUN clcprtsl_calc-line IN THIS-PROCEDURE ( INPUT RECID( ub.doc-line ) ).
    FIND FIRST tt-allsum-line NO-LOCK WHERE tt-allsum-line.sum-type = {&sum-general} NO-ERROR.
    ASSIGN
      v-sum-base      = ( IF AVAILABLE tt-allsum-line THEN tt-allsum-line.sum-dsc-base-doc ELSE 0.0 )
      acc-other-qnty1 = acc-other-qnty1 + ( IF ub.trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh} THEN ( - ub.doc-line.fact-qnty ) ELSE ub.doc-line.fact-qnty )
      acc-other-netto = acc-other-netto + v-sum-base
      acc-other-found = YES
      .
    FIND FIRST ub.inv-line NO-LOCK WHERE
      ub.inv-line.doc-code  = ub.doc-line.doc-code  AND
      ub.inv-line.artic     = ub.doc-line.artic     AND
      ub.inv-line.prod-type = ub.doc-line.prod-type AND
      ub.inv-line.prod-code = ub.doc-line.prod-code NO-ERROR.
    IF AVAILABLE ub.inv-line THEN 
    DO:
      ASSIGN 
        acc-other-qnty2 = acc-other-qnty2 + ( IF ub.trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh} THEN ( - ub.inv-line.wast-cli-qnty ) ELSE ub.inv-line.wast-cli-qnty ).
    END.
  END. /* FOR EACH ub.trn-doc */
  IF acc-other-found = YES THEN 
  DO:
    RUN create-treal-2 IN THIS-PROCEDURE ( INPUT t-2.gds-code
      , INPUT -1
      , INPUT 0
      , INPUT acc-other-qnty1
      , INPUT acc-other-qnty2
      , INPUT v-sum-base
      , INPUT "Проч докум.расход"
      , INPUT NO
      , INPUT ?                   ) NO-ERROR.
  END. /* acc-other-found */
END. /* FOR EACH t-2 */
