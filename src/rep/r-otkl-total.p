/*

$Revision: b2031575dcde, 1694, rls $
$Author: EShklyar $
$Date: Tue Dec 11 10:07:56 2018 +0300 $
$Workfile: r-otkl-total.p $
$Archive: rep/r-otkl-total.p $

Сбор данных для допустимого значения

Автор: Уханов Дмитрий Юрьевич
Дата создания: 09/14/05
Author: Dmitry Ukhanov
Creation date: 09/14/05

*/
using ibs.th.str.*.
block-level on error undo, throw.

DEFINE INPUT PARAMETER prvs-code             LIKE ub.rvs-doc.rvs-code     NO-UNDO.
DEFINE INPUT PARAMETER prvs-type             LIKE ub.rvs-doc.rvs-type     NO-UNDO.
DEFINE INPUT PARAMETER pobj-code             LIKE ub.shift-obj.obj-code   NO-UNDO.
DEFINE INPUT PARAMETER pobj-type             LIKE ub.shift-obj.obj-type   NO-UNDO.
DEFINE INPUT PARAMETER pshift-date           LIKE ub.shift-obj.shift-date NO-UNDO.
DEFINE INPUT PARAMETER pshift-num            LIKE ub.shift-obj.shift-num  NO-UNDO.


DEFINE VARIABLE vss-revision    AS CHARACTER NO-UNDO INITIAL "$Revision: b2031575dcde, 1694, rls $":U.
DEFINE VARIABLE vss-author      AS CHARACTER NO-UNDO INITIAL "$Author: EShklyar $":U.
DEFINE VARIABLE vss-date        AS CHARACTER NO-UNDO INITIAL "$Date: Tue Dec 11 10:07:56 2018 +0300 $":U.
DEFINE VARIABLE vss-workfile    AS CHARACTER NO-UNDO INITIAL "$Workfile: r-otkl-total.p $":U.
DEFINE VARIABLE vss-archive     AS CHARACTER NO-UNDO INITIAL "$Archive: rep/r-otkl-total.p $":U.
DEFINE VARIABLE vss-description AS CHARACTER NO-UNDO INITIAL "Сбор данных для допустимого значения":U.

{ cmp/vssrevis.i                }
{ cmp/str-glbl.i                }
{ cmp/library.i                 }
{ cmp/trg-def.i  }
{ trg/factord.i                 }
{ gbl/clntattr.i                }
{ str/clcprtsl.i                }
{ ref/gds-attr.i }
{ gbl/getsect.i def }
{ gbl/cur-time.i }
{ gbl/sys-time.i }

DEFINE variable pshift-date1           LIKE ub.shift-obj.shift-date NO-UNDO.
DEFINE variable pshift-num1            LIKE ub.shift-obj.shift-num NO-UNDO.
DEFINE variable p-previous-shift-date  AS DATE      NO-UNDO.
DEFINE VARIABLE loc-ii                 AS INTEGER   NO-UNDO INITIAL 1.
DEFINE VARIABLE for-supp-name          AS CHARACTER NO-UNDO.
DEFINE VARIABLE vdoc-num               LIKE ub.price-list.doc-num NO-UNDO.
DEFINE VARIABLE vprice-sale            LIKE ub.price-list.price-sale NO-UNDO.
DEFINE VARIABLE vroad-tax              AS DECIMAL   NO-UNDO.
DEFINE VARIABLE vexcise                AS DECIMAL   NO-UNDO.
DEFINE VARIABLE acc-other-qnty1        AS DECIMAL   NO-UNDO.
DEFINE VARIABLE acc-other-qnty2        AS DECIMAL   NO-UNDO.
DEFINE VARIABLE acc-other-netto        AS DECIMAL   NO-UNDO.
DEFINE VARIABLE acc-other-found        AS LOGICAL   NO-UNDO.
DEFINE VARIABLE acc-cli-qnty1          AS DECIMAL   NO-UNDO.
DEFINE VARIABLE acc-cli-qnty2          AS DECIMAL   NO-UNDO.
DEFINE VARIABLE acc-cli-netto          AS DECIMAL   NO-UNDO.
DEFINE VARIABLE acc-cli-found          AS LOGICAL   NO-UNDO.
DEFINE VARIABLE current-cli            AS INTEGER   NO-UNDO.
DEFINE VARIABLE current-cli-type       AS CHARACTER NO-UNDO.
DEFINE VARIABLE dop-sum                AS DECIMAL   NO-UNDO.
DEFINE VARIABLE dop-qnty               AS DECIMAL   NO-UNDO.
DEFINE VARIABLE dop-kg                 AS DECIMAL   NO-UNDO.
DEFINE VARIABLE found-in-previous      AS LOGICAL   NO-UNDO.
DEFINE VARIABLE mc                     LIKE ub.bar-code.b-code NO-UNDO.
DEFINE VARIABLE v-attr-value           AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-attr-type            AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-sum-base             LIKE ub.ot-line.sum-base NO-UNDO.
DEFINE VARIABLE p-base-code            AS INTEGER   NO-UNDO.
DEFINE VARIABLE v-qnty1                AS DECIMAL   NO-UNDO.
DEFINE VARIABLE v-qnty2                AS DECIMAL   NO-UNDO.

define variable v-InfoSectionsTotal    as class     InfoSectionsTotal no-undo .
define variable v-InfoSection          as class     InfoSection       no-undo .
define variable iNum                   as integer   no-undo .

define variable v-otkl-fact-volue      as decimal   no-undo .
define variable v-otkl-density         as decimal   no-undo FORMAT "->>,>>9.999":U .
define variable v-otkl-temp            as decimal   no-undo .
define variable v-otkl-water           as decimal   no-undo .
    
define variable v-value                as character no-undo .
define variable v-type                 as character no-undo .
define variable v-date                 as character no-undo .
define variable v-time                 as character no-undo .

define variable v-vid-ok               as logical   no-undo .
define variable v-vid-mes              as character no-undo .
define variable v-vid-action           as integer   no-undo .
define variable v-vid-param            as longchar  no-undo .  
    
define variable v-computer-name        as character no-undo .
define variable v-computer-tcp-name    as character no-undo .
define variable v-computer-ip-addr     as character no-undo .
define variable v-computer-login-name  as character no-undo .
define variable v-computer-process-pid as integer   no-undo .    
/*какие вообще топлива были за смену*/
DEFINE TEMP-TABLE t-2 no-undo
  FIELD gds-code     like ub.goods.gds-code
  FIELD artic        like ub.goods.artic
  FIELD prod-type    like ub.goods.prod-type
  FIELD prod-code    like ub.goods.prod-code
  FIELD qnty1-before as decimal FORMAT "->>>>9.99"
  FIELD qnty2-before as decimal FORMAT "->>>>9.99"
  FIELD qnty1-after  as decimal FORMAT "->>>>9.99"
  FIELD qnty2-after  as decimal FORMAT "->>>>9.99"
  FIELD last-price   as decimal FORMAT ">>>>9.99"
  FIELD gds-name     like ub.goods.gds-name FORMAT "X(12)"
  field pl-code      like ub.rvs-line.pl-code
  FIELD lines        as integer
  INDEX pi IS UNIQUE primary
  gds-code pl-code
  INDEX art IS UNIQUE
  artic
  prod-type
  prod-code
  .

pshift-date1 = pshift-date .
p-previous-shift-date = pshift-date .
pshift-num1 = pshift-num .
/* находим fact-order */
{ rep/r-shftfo.i attr-arh-detail-date }

DEFINE BUFFER previous-rvs-doc    FOR ub.rvs-doc.
DEFINE BUFFER previous-rvs-line   FOR ub.rvs-line.
DEFINE BUFFER this-shift-rvs-doc  FOR ub.rvs-doc.
DEFINE BUFFER this-shift-rvs-line FOR ub.rvs-line.
DEFINE BUFFER buf_doc-line        FOR ub.doc-line.
DEFINE BUFFER buf_inv-line        FOR ub.inv-line.
DEFINE BUFFER buf_trn-doc         FOR ub.trn-doc.

/*текущая сверка*/
FIND FIRST ub.rvs-doc NO-LOCK WHERE
  ub.rvs-doc.obj-type   = pobj-type    AND
  ub.rvs-doc.obj-code   = pobj-code    AND
  ub.rvs-doc.rvs-code   = prvs-code    AND
  ub.rvs-doc.shift-date = pshift-date  AND
  ub.rvs-doc.shift-num  = pshift-num   NO-ERROR.
IF NOT AVAILABLE ub.rvs-doc THEN 
DO:
  return error substitute("&1 &2 &3&4Не найдена сверка объект &5&6 смена &7 порядок &8"
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

/*Таблица в которой соберем все данные*/
define temp-table temp-rvs no-undo
  FIELD gds-code      as integer
  FIELD shift-date    like ub.rvs-doc.shift-date
  FIELD shift-num     like ub.rvs-doc.shift-num
  field prod-type     like ub.goods.prod-type
  field prod-code     like ub.goods.prod-code
  field artic         like ub.goods.artic
  Field qnty1         as decimal /*на начало смены*/
  field qnty2         as decimal /*приход*/
  field qnty3         as decimal /*расход*/
  field qnty4         as decimal /*текущая смена*/
  field temp1         as decimal /*на начало смены*/
  field temp2         as decimal
  field density1      as decimal /*на начало смены*/
  field density2      as decimal
  field water1        as decimal /*на начало смены*/
  field water2        as decimal
  field pl-code       as integer
  field rvs-error     as logical
  field delta-qnty    as decimal
  field delta-temp    as decimal
  field delta-density as decimal
  field delta-water   as decimal
  field list-otkl     as character
  INDEX pi IS UNIQUE PRIMARY gds-code pl-code artic prod-type prod-code
  .
for each temp-rvs:
  delete temp-rvs .
end.  

/*Заполним таблицу с товарыми, по которым будем смотреть расхождения*/

FOR EACH ub.rvs-line NO-LOCK WHERE
  ub.rvs-line.rvs-code = ub.rvs-doc.rvs-code AND
  ub.rvs-line.obj-type = ub.rvs-doc.obj-type AND
  ub.rvs-line.obj-code = ub.rvs-doc.obj-code
  BREAK BY ub.rvs-line.gds-code :
  FIND FIRST temp-rvs WHERE temp-rvs.gds-code = ub.rvs-line.gds-code and temp-rvs.pl-code = ub.rvs-line.pl-code NO-ERROR.
  IF NOT AVAILABLE temp-rvs THEN 
  DO:
    v-value = ''.
    run gds-attr-value in this-procedure (
      input ub.rvs-line.gds-code
      ,input {&attr-ptrl-as-good}
      ,output v-value
      ,output v-type) no-error.
    if not logical(v-value) then 
    do:
      FIND FIRST ub.goods NO-LOCK WHERE ub.goods.gds-code = ub.rvs-line.gds-code NO-ERROR.
      IF AVAILABLE ub.goods THEN 
      DO:
        create temp-rvs .
        assign
          temp-rvs.gds-code  = ub.rvs-line.gds-code
          temp-rvs.pl-code   = ub.rvs-line.pl-code
          temp-rvs.artic     = ub.goods.artic
          temp-rvs.prod-type = ub.goods.prod-type
          temp-rvs.prod-code = ub.goods.prod-code
          temp-rvs.qnty4     = ub.rvs-line.state-measure-qnty
          temp-rvs.density2  = ub.rvs-line.density
          temp-rvs.temp2     = ub.rvs-line.temperature
          temp-rvs.water2    = ub.rvs-line.level-water
          .
      end.
    end.
  end.
end.

FOR EACH temp-rvs NO-LOCK BREAK BY temp-rvs.gds-code :
      
  /*Записываем данные на начало смены*/
  IF AVAILABLE previous-rvs-doc THEN 
  DO:
    FOR EACH previous-rvs-line NO-LOCK WHERE
      previous-rvs-line.rvs-code = previous-rvs-doc.rvs-code AND
      previous-rvs-line.gds-code = temp-rvs.gds-code
      and previous-rvs-line.pl-code = temp-rvs.pl-code              :
      ASSIGN
        temp-rvs.qnty1      = temp-rvs.qnty1 + previous-rvs-line.state-measure-qnty
        temp-rvs.gds-code   = previous-rvs-line.gds-code
        temp-rvs.pl-code    = previous-rvs-line.pl-code
        temp-rvs.shift-date = previous-rvs-doc.shift-date
        temp-rvs.shift-num  = previous-rvs-doc.shift-num
        temp-rvs.density1   = previous-rvs-line.density
        temp-rvs.temp1      = previous-rvs-line.temperature
        temp-rvs.water1     = previous-rvs-line.level-water
        .
    END. /* FOR EACH previous-rvs-line */
  END. /* IF AVAILABLE previous-rvs-doc */
end.

/* начинаем заполнение данными по приходу */
FOR EACH  ub.trn-doc  NO-LOCK
  WHERE ub.trn-doc.obj-type   = pobj-type
  AND ub.trn-doc.obj-code   = pobj-code
  AND ub.trn-doc.fact-order >= prev-fo
  AND ub.trn-doc.status_    = {&fact}
  AND ub.trn-doc.doc-type   = {&income}
  , EACH  ub.doc-line NO-LOCK WHERE
  ub.doc-line.doc-code = ub.trn-doc.doc-code
  , FIRST temp-rvs                 WHERE
  temp-rvs.artic     = ub.doc-line.artic     AND
  temp-rvs.prod-type = ub.doc-line.prod-type AND
  temp-rvs.prod-code = ub.doc-line.prod-code
  BREAK BY ub.doc-line.artic
  BY ub.doc-line.prod-type
  BY ub.doc-line.prod-code
  by ub.trn-doc.cli-code
  :
  for each ub.doc-pl no-lock where ub.doc-pl.gds-code = temp-rvs.gds-code and ub.doc-pl.obj-code = pobj-code
    and ub.doc-pl.obj-type = pobj-type and ub.doc-pl.out-code = ub.doc-line.doc-code and temp-rvs.pl-code = ub.doc-pl.pl-code:
    assign
      temp-rvs.qnty2 = temp-rvs.qnty2 + ub.doc-pl.fact-qnty  
      .
  end.  
END. /* FOR EACH ub.trn-doc */

  
/* Расход внутренний */
FOR EACH  ub.trn-doc  NO-LOCK
  WHERE ub.trn-doc.obj-type   = pobj-type
  AND ub.trn-doc.obj-code   = pobj-code
  AND ub.trn-doc.fact-order >= prev-fo
  AND ub.trn-doc.status_    = {&fact}
  AND ub.trn-doc.doc-type   = {&expense}
  , EACH  ub.doc-line NO-LOCK WHERE
  ub.doc-line.doc-code = ub.trn-doc.doc-code
  , FIRST temp-rvs                 WHERE
  temp-rvs.artic     = ub.doc-line.artic     AND
  temp-rvs.prod-type = ub.doc-line.prod-type AND
  temp-rvs.prod-code = ub.doc-line.prod-code
  BREAK BY ub.doc-line.artic
  BY ub.doc-line.prod-type
  BY ub.doc-line.prod-code
  by ub.trn-doc.cli-code
  :
  for each ub.doc-pl no-lock where ub.doc-pl.gds-code = temp-rvs.gds-code and ub.doc-pl.obj-code = pobj-code
    and ub.doc-pl.obj-type = pobj-type and ub.doc-pl.out-code = ub.doc-line.doc-code and temp-rvs.pl-code = ub.doc-pl.pl-code:
    assign
      temp-rvs.qnty3 = temp-rvs.qnty3 + ub.doc-pl.fact-qnty  
      .
  end.
   
END. /* FOR EACH ub.trn-doc */

{ gbl/getsect.i run  pobj-type  pobj-code  {&attr-petrol} }
    
for each thbjattr_thbj-attr :    
  if thbjattr_thbj-attr.prop-code = {&attr-petrol_otkl-fact-volue} then assign v-otkl-fact-volue = thbjattr_thbj-attr.property-value-decimal .
end.
for each thbjattr_thbj-attr :    
  if thbjattr_thbj-attr.prop-code = {&attr-petrol_otkl-water} then assign v-otkl-water = thbjattr_thbj-attr.property-value-decimal .
end.
for each thbjattr_thbj-attr :    
  if thbjattr_thbj-attr.prop-code = {&attr-petrol_otkl-temp} then assign v-otkl-temp = thbjattr_thbj-attr.property-value-decimal .
end.
for each thbjattr_thbj-attr :    
  if thbjattr_thbj-attr.prop-code = {&attr-petrol_otkl-density} then assign v-otkl-density = decimal(thbjattr_thbj-attr.property-value-character) .
end.

/*если параметры не заданы, процесс не запускать*/
if v-otkl-fact-volue = 0 and v-otkl-water = 0 and v-otkl-temp = 0 and (v-otkl-density = 0 or v-otkl-density = ?) then return no-apply .

for each temp-rvs no-lock:
  if v-otkl-fact-volue < abs(abs(temp-rvs.qnty1 - temp-rvs.qnty4) - abs(temp-rvs.qnty2 - temp-rvs.qnty3)) then 
  do:
    temp-rvs.rvs-error = yes .
  end.
  if v-otkl-temp < abs (temp-rvs.temp1 - temp-rvs.temp2) then
  do:
    if temp-rvs.rvs-error <> yes then 
    do:
      temp-rvs.rvs-error = yes .
    end.  
  end.                           
  if v-otkl-density < abs (temp-rvs.density1 - temp-rvs.density2) then 
  do:
    if temp-rvs.rvs-error <> yes then 
    do:
      temp-rvs.rvs-error = yes .
    end.  
  end.  
  if v-otkl-water < abs (temp-rvs.water1 - temp-rvs.water2) then 
  do:
    if temp-rvs.rvs-error <> yes then 
    do:
      temp-rvs.rvs-error = yes .
    end.  
  end.  
  /*  if temp-rvs.rvs-error = yes then do:*/
  assign 
    temp-rvs.delta-qnty    = (abs(temp-rvs.qnty2 - temp-rvs.qnty3) - abs(temp-rvs.qnty1 - temp-rvs.qnty4))
    temp-rvs.delta-density = (temp-rvs.density1 - temp-rvs.density2)
    temp-rvs.delta-temp    = (temp-rvs.temp1 - temp-rvs.temp2)
    temp-rvs.delta-water   = (temp-rvs.water1 - temp-rvs.water2)
    temp-rvs.list-otkl     = "Объем: " + string (v-otkl-fact-volue) + ";" + "Плотность: " + string (v-otkl-density,"9.999") + ";" + "Температура: " + string (v-otkl-temp) + ";" + "Вода: " + string(v-otkl-water) .    
/*  end.*/
end.  

define buffer buf_temp-rvs for temp-rvs .
define buffer bf_temp-rvs  for temp-rvs .    
define variable v-time-hour as integer no-undo .
define variable v-time-min  as integer no-undo .

for each buf_temp-rvs no-lock where buf_temp-rvs.rvs-error = yes : 

  run cur-time in this-procedure ( output v-date, output v-time).
  v-time-hour = truncate(integer(v-time) / 3600, 0).
  v-time-min  = (integer(v-time) - (v-time-hour * 3600)) / 60 .
  
  run sys-time_get-comp-user-name in this-procedure
    (output v-computer-name
    ,output v-computer-login-name
    ,output v-computer-process-pid
    ) .
  v-vid-action = 65 .
  
  { str/initiator.i }
  v-vid-param = 
    "UniqueIdRecordARM=" + v-initiator + {&delim-par} +
    "NumShop=" + string(pobj-code) + {&delim-par} +
    "PlCode=" + string (buf_temp-rvs.pl-code) + {&delim-par} +
    "VolumeStart=" + string(buf_temp-rvs.qnty1) + {&delim-par} +
    "DensityStart=" + string(buf_temp-rvs.density1) + {&delim-par} +
    "TemperatureStart=" + string(buf_temp-rvs.temp1) + {&delim-par} +
    "LevelWaterStart=" + string(buf_temp-rvs.water1) + {&delim-par} +
    "CurrentVolume=" + string(buf_temp-rvs.qnty4) + {&delim-par} +
    "CurrentDensity=" + string(buf_temp-rvs.density2) + {&delim-par} +
    "CurrentTemperature=" + string(buf_temp-rvs.temp2) + {&delim-par} +
    "CurrentLevelWater=" + string(buf_temp-rvs.water2) + {&delim-par} +
    "DivergenceVolume=" + string(buf_temp-rvs.delta-qnty) + {&delim-par} +
    "DivergenceDensity=" + string(buf_temp-rvs.delta-density) + {&delim-par} +
    "DivergenceTemperature=" + string(buf_temp-rvs.delta-temp) + {&delim-par} +
    "DivergenceLevelWater=" + string(buf_temp-rvs.delta-water) + {&delim-par} +            
    "DocNum=" + string(ub.rvs-doc.rvs-code) + {&delim-par} +
    "PermissibleDivergence="   + string(buf_temp-rvs.list-otkl) no-error.

        run trg/userlog.p (
            input {&nwsdochs_action_create}
            , input {&table_rvs-doc}
            , input ( buffer ub.rvs-doc :handle )
            , input v-vid-action
            , input v-vid-param
            ) no-error.
        if error-status :error
            then
        do:
          return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
                , {&new-line}
                , vss-workfile
                , return-value
                , error-status :get-message ( 1 ) ).
        end.
end.  

  
output to value (ibs.th.gbl.gbl-inipar:logDir + "temp-rvs.log") .
for each temp-rvs:
  export temp-rvs .
end.  
output close .

output to value (ibs.th.gbl.gbl-inipar:logDir + "balance.log") append.

for each temp-rvs no-lock where temp-rvs.rvs-error = yes :
  
  put unformatted            "Идентификатор пользователя =" + v-computer-login-name skip .
  put unformatted            "Дата события =" + string(v-date, "99999999") skip .
  put unformatted            "Время события =" + string(v-time-hour,"99") + ":" + string(v-time-min,"99") skip .
  put unformatted            "HostName ПК, на котором запущен процесс =" + string(v-computer-name) skip .
  put unformatted            "Номер документа сверки =" + string (ub.rvs-doc.rvs-code) skip .
  put unformatted            "№Резервуара =" + string (temp-rvs.pl-code) skip .
  put unformatted            "Объем на начало смены =" + string(temp-rvs.qnty1) skip .
  put unformatted            "Плотность на начало смены =" + string(temp-rvs.density1) skip .
  put unformatted            "Температура на начало смены =" + string(temp-rvs.temp1) skip .
  put unformatted            "Уровень воды на начало смены =" + string(temp-rvs.water1) skip .
  put unformatted            "Текущий объем =" + string(temp-rvs.qnty4) skip .
  put unformatted            "Текущая плотность =" + string(temp-rvs.density2) skip .
  put unformatted            "Текущая температура =" + string(temp-rvs.temp2) skip .
  put unformatted            "Текущий уровень воды =" + string(temp-rvs.water2) skip .
  put unformatted            "Расхождение объема =" + string(temp-rvs.delta-qnty) skip .
  put unformatted            "Расхождение плотности =" + string(temp-rvs.delta-density) skip .
  put unformatted            "Расхождение температуры =" + string(temp-rvs.delta-temp) skip .
  put unformatted            "Расхождение воды =" + string(temp-rvs.delta-water) skip .            
  put unformatted            "Допустимые расхождения ="   + string(temp-rvs.list-otkl) skip.
  put unformatted            "________________________________________________________" skip .
  
end.
output close .       


