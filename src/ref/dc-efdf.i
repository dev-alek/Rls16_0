/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Сводные таблицы для EasyFuel

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/30/08
Author: Bakhtadze Natalya
Creation date: 05/30/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ gbl/key-rec.i }
{ str/cd-trans.i ach }
{ str/cd-trans.i achexp }


define temp-table {1}temp-ef no-undo
field d-card as character
field car-reg-number as character label "Госрег. номер"
field car-brand as character  label "Марка трансп. ср-ва"
field ef-format as integer    label "Формат записи на МБ"
field access-key as character
field petrol-code-1 as integer label "Топливо №1"
field petrol-code-2 as integer label "Топливо №2"
field petrol-code-3 as integer label "Топливо №3"
field petrol-code-4 as integer label "Топливо №4"
field init-date-time as character
field petrol-list-1 as character
field petrol-list-2 as character
field issue-code as integer  label "Выдал магазин"
field db-num as integer
field user-id as integer
field issue-date as date     label "Дата Выдачи"
field issue-time as integer
field valid-from as date     label "Действует с"
field valid-date as date     label "Действует по"
field issued-by as character label "Выдал оператор"
field init-operator as character label "Прошивал"
index pi is unique primary
d-card
.


DEFINE TEMP-TABLE {1}temp-ef1 NO-UNDO
field d-card as character
FIELD petrol-code AS INTEGER /*основной бар-код топлива*/ format ">>>>>>>>9"  label "Код в IBS TH"
FIELD sum-id AS character    /*sum-id для объекта 24*/
FIELD dt-code AS integer    /*dt-code для объекта 24*/
FIELD dtm-code AS integer    /*dtm-code для объекта 24 всегда 24*/
FIELD ef-petrol-code AS INTEGER /*код топлива в EASYFUEL*/  label "Код топлива EasyFuel"
FIELD common-limit AS DECIMAL label "Общий лимит"
FIELD unlim-common-limit AS logical label "Общий!лимит!неогран"
FIELD month-limit AS DECIMAL label "Месячный лимит"
FIELD unlim-month-limit AS logical label "Месячн!лимит!неогран"
FIELD day-limit AS DECIMAL label "Дневной лимит"
FIELD unlim-day-limit AS logical label "Дневн!лимит!неогран"
FIELD standard-dose AS DECIMAL label "Cтандартная доза"
FIELD petrol-num AS INTEGER /*порядковый номер топлива на МБ если = 0 то через МБ этим топливом не торгуют*/ label "№ топлива на МБ"
FIELD common-expense AS DECIMAL label "Общий расход"
FIELD month-expense AS DECIMAL label "Месячный расход"
FIELD day-expense AS DECIMAL label "Дневной расход"
FIELD last-date AS Date label "Дата посл.измен"
FIELD last-time AS integer
field new_ as logical
INDEX pi IS UNIQUE PRIMARY
d-card
dt-code
INDEX ip petrol-code
index iefp ef-petrol-code
.

DEFINE TEMP-TABLE {1}temp-efh NO-UNDO
field d-card as character
FIELD petrol-code AS INTEGER /*основной бар-код топлива*/
FIELD ef-petrol-code AS INTEGER /*код топлива в EASYFUEL*/
field seq as integer
field date_ as date
field time_ as integer
field obj-code as integer
field pump-code as integer
field nozzle-code as integer
field cash-desk as integer
field chk-num as integer
field doc-qnty-pl100 as decimal /*в сотых долях*/
INDEX pi IS UNIQUE PRIMARY
d-card
petrol-code
INDEX ip petrol-code
.



DEFINE TEMP-TABLE {1}temp-ef2 NO-UNDO
field d-card as character
FIELD month-limit AS DECIMAL
FIELD day-limit AS DECIMAL
FIELD standard-dose AS DECIMAL
FIELD common-limit AS DECIMAL
FIELD purse-num AS INTEGER
INDEX pi IS UNIQUE PRIMARY
d-card purse-num
.

&if defined(dc-efdf_proc) = 0 &then

&glob dc-efdf_proc


FUNCTION get-ef-petrol-code RETURNS INTEGER
  ( INPUT p-b-code AS INTEGER ) :
DEFINE VARIABLE v-ef-petrol-code AS INTEGER NO-UNDO.
define variable v-key-rec as character no-undo .
DEFINE buffer buf_goods FOR ub.goods.
DEFINE buffer buf_ext-classif FOR ub.ext-classif.
FIND FIRST buf_goods NO-LOCK WHERE
        buf_goods.gds-code = p-b-code .
run gen-key-rec in THIS-PROCEDURE ( INPUT {&TABLE_goods}
                                  ,INPUT (buffer buf_goods:HANDLE)
                                    ,OUTPUT v-key-rec).
 FIND FIRST buf_ext-classif NO-LOCK WHERE
            buf_Ext-classif.classif-subject = {&TABLE_goods}
         AND buf_Ext-classif.classif-name = {&extclass_goods_easyfuel}
      AND buf_ext-classif.uniq-key-rec = v-key-rec NO-ERROR.
 IF AVAILABLE buf_ext-classif THEN DO:
   ASSIGN
   v-ef-petrol-code = buf_ext-classif.key#_one.

 END.
 RETURN v-ef-petrol-code.
END FUNCTION.

FUNCTION get-petrol-gds-code RETURNS INTEGER
  ( INPUT p-ef-petrol-code AS INTEGER ) :
define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-key-rec as character no-undo .
DEFINE buffer buf_goods FOR ub.goods.
DEFINE buffer buf_ext-classif FOR ub.ext-classif.
 FIND FIRST buf_ext-classif NO-LOCK WHERE
            buf_Ext-classif.classif-subject = {&TABLE_goods}
         AND buf_Ext-classif.classif-name = {&extclass_goods_easyfuel}
      AND buf_ext-classif.key#_one = p-ef-petrol-code NO-ERROR.
 IF AVAILABLE buf_ext-classif THEN DO:
   run gen-row-keyr in this-procedure (
                                        input  buf_ext-classif.uniq-key-rec
                                       ,input ? /* буфер записи которую будем искать. если ищем по key-rec то ? */
                                       ,input "ub"
                                       ,input ? /* буфер таблицы - если надо найти во временной таблице. если ищем в БД то ? */
                                       ,input no-lock
                                       ,output v-tbl-row
                                       ,output v-tbl-name) no-error.
   if not error-status:error then do:
     find first buf_goods no-lock where
              rowid(buf_goods) = v-tbl-row.
     return buf_goods.gds-code.
   end.
 END.
 RETURN 0.
END FUNCTION.



procedure fill-main-table :
define input parameter p-d-card as character no-undo .
define parameter buffer buf_dis-card for ub.dis-card.
define buffer buf_temp-dis-card-property for temp-dis-card-property.
define buffer buf_temp-ef for temp-ef.
do
on error undo, return error
:
  for each buf_temp-ef:
    delete buf_temp-ef.
  end.
  create buf_temp-ef.
  buf_temp-ef.ef-format = 1.
  if available buf_dis-card then do:
    buffer-copy buf_dis-card
    except d-card
    to buf_temp-ef
    assign
    buf_temp-ef.d-card = p-d-card
    .
  end.
  else do:
    assign
    buf_temp-ef.d-card = p-d-card.
  end.
 FOR EACH temp-dis-card-property where
       temp-dis-card-property.d-card = p-d-card
    and temp-dis-card-property.dtm-code = {&dc-prop_easyfuel}
    :
   CASE temp-dis-card-property.node-code:
     WHEN {&dc_prop_easyfuel_car-reg-number} THEN DO:
       buf_temp-ef.car-reg-number = temp-dis-card-property.property-value-character.
     END.
     WHEN {&dc_prop_easyfuel_car-brand} THEN DO:
        buf_temp-ef.car-brand = temp-dis-card-property.property-value-character.
     END.
     WHEN {&dc_prop_easyfuel_ef-format} THEN DO:
       buf_temp-ef.ef-format = temp-dis-card-property.property-value-integer.
       IF ERROR-STATUS:ERROR THEN UNDO, RETURN ERROR.
     END.
     WHEN {&dc_prop_easyfuel_access-key} THEN DO:
       buf_temp-ef.access-key = temp-dis-card-property.property-value-character.
     END.
     WHEN {&dc_prop_easyfuel_petrol-code-1} THEN DO:
       buf_temp-ef.petrol-code-1 = temp-dis-card-property.property-value-integer.
     END.
     WHEN {&dc_prop_easyfuel_petrol-code-2} THEN DO:
       buf_temp-ef.petrol-code-2 = temp-dis-card-property.property-value-integer.
     END.
     WHEN {&dc_prop_easyfuel_petrol-code-3} THEN DO:
        buf_temp-ef.petrol-code-3 = temp-dis-card-property.property-value-integer.
     END.
     WHEN {&dc_prop_easyfuel_petrol-code-4} THEN DO:
       buf_temp-ef.petrol-code-4 = temp-dis-card-property.property-value-integer.
     END.
     WHEN {&dc_prop_easyfuel_init-date-time} THEN DO:
        buf_temp-ef.init-date-time = temp-dis-card-property.property-value-character.
     END.
     WHEN {&dc_prop_easyfuel_init-operator} THEN DO:
        buf_temp-ef.init-operator = temp-dis-card-property.property-value-character.
     END.
     WHEN {&dc_prop_easyfuel_issued-by} THEN DO:
        buf_temp-ef.issued-by = temp-dis-card-property.property-value-character.
        buf_temp-ef.db-num = integer(entry(1, temp-dis-card-property.property-value-character, "-")).
        buf_temp-ef.user-id = integer(entry(2, temp-dis-card-property.property-value-character, "-")).
     END.
   END CASE.
 END.
 RUN fill-tables IN THIS-PROCEDURE ( INPUT buf_temp-ef.ef-format, buffer buf_temp-ef) NO-ERROR.
end.

end procedure. /* fill-main-table */


PROCEDURE fill-tables :
DEFINE INPUT PARAMETER p-ef-format AS INTEGER NO-UNDO.
define parameter buffer buf_temp-ef for temp-ef.
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-gds-code AS INTEGER NO-UNDO.
DEFINE BUFFER bufl_temp-dis-card-property FOR temp-dis-card-property.
DEFINE BUFFER buf_temp-dis-card-property FOR temp-dis-card-property.
CASE p-ef-format:
  WHEN 1  THEN DO:
    FOR EACH bufl_temp-dis-card-property NO-LOCK WHERE
            bufl_temp-dis-card-property.d-card = buf_temp-ef.d-card
         AND bufl_temp-dis-card-property.dtm-code = {&dc-prop_easyfuel-limits}:
      FIND FIRST temp-ef1 WHERE
                temp-ef1.d-card = buf_temp-ef.d-card
            and temp-ef1.dt-code = bufl_temp-dis-card-property.dt-code NO-ERROR.
      IF NOT AVAILABLE temp-ef1 THEN do:
         CREATE temp-ef1.
         ASSIGN
         temp-ef1.d-card = buf_temp-ef.d-card
         temp-ef1.sum-id = bufl_temp-dis-card-property.sum-id
         temp-ef1.dt-code = bufl_temp-dis-card-property.dt-code
         temp-ef1.dtm-code = bufl_temp-dis-card-property.dtm-code
         .
         v-gds-code = propreft-string-to-petrol( INPUT bufl_temp-dis-card-property.sum-id).
         ASSIGN
         temp-ef1.petrol-code  = v-gds-CODE
         .
         ASSIGN
         temp-ef1.ef-petrol-code = get-ef-petrol-code ( temp-ef1.petrol-code)
          .

         DO v-ii = 1 TO 4:
           IF temp-ef1.petrol-code = buffer buf_temp-ef:buffer-field( substitute("petrol-code-&1", v-ii)):buffer-value THEN DO:
             temp-ef1.petrol-num = v-ii.
           END.
         END.

      END.
      CASE bufl_temp-dis-card-property.node-code:
        WHEN {&dc_prop_easyfuel-limits_month-limit} THEN DO:
            ASSIGN
            temp-ef1.month-limit = bufl_temp-dis-card-property.property-value-decimal
            temp-ef1.unlim-month-limit = (temp-ef1.month-limit = ?)
            .

        END.
        WHEN {&dc_prop_easyfuel-limits_day-limit} THEN DO:
            ASSIGN
            temp-ef1.day-limit = bufl_temp-dis-card-property.property-value-decimal
            temp-ef1.unlim-day-limit = (temp-ef1.day-limit = ?)
            .

        END.
        WHEN {&dc_prop_easyfuel-limits_standard-dose} THEN DO:
            ASSIGN
            temp-ef1.standard-dose = bufl_temp-dis-card-property.property-value-decimal.

        END.
        WHEN {&dc_prop_easyfuel-limits_common-limit} THEN DO:
            ASSIGN
            temp-ef1.common-limit = bufl_temp-dis-card-property.property-value-decimal
            temp-ef1.unlim-common-limit = (temp-ef1.common-limit = ?)
            .

        END.

      END CASE.
   END.
  END.
  OTHERWISE DO:
     MESSAGE
     substitute("Формат данныx &1 для МБ в настоящий момент не поддерживается", p-ef-format)
     VIEW-AS ALERT-BOX ERROR.
     UNDO, RETURN ERROR.

  END.
END CASE.
END PROCEDURE.

procedure fill-expenses :
DEFINE INPUT PARAMETER p-ef-format AS INTEGER NO-UNDO.
define parameter buffer buf_temp-ef for temp-ef.
define variable v-cd-petrol-code as character no-undo .
define buffer buf_cd-trans for ub.cd-trans.
define buffer bufe_cd-trans for ub.cd-trans.
define buffer buf_temp-ef1 for temp-ef1.

do
on error undo, return error
:
  for each buf_temp-ef1 where
        buf_temp-ef1.d-card = buf_temp-ef.d-card:
    /*найдем топливный код*/

    find last buf_cd-trans no-lock where
            buf_cd-trans.trans-type  = integer({&cdt-ach})
        and buf_cd-trans.{&achcardnum} = buf_temp-ef.d-card
        and buf_cd-trans.{&achcode} = v-cd-petrol-code use-index ichkdate
          no-error.
    if available buf_cd-trans then do:
      find first bufe_cd-trans no-lock where
            bufe_cd-trans.trans-type  = integer({&cdt-achexp})
        and bufe_cd-trans.{&achcardnum} = buf_temp-ef.d-card
        and bufe_cd-trans.{&achcode} = v-cd-petrol-code
        and bufe_cd-trans.trans-id-chr = buf_cd-trans.trans-id-chr use-index ichkdate no-error .
      if available bufe_cd-trans then do:
        assign
        buf_temp-ef1.common-expense = buf_cd-trans.{&acheexp}
        buf_temp-ef1.month-expense = buf_cd-trans.{&achemonthexp}
        buf_temp-ef1.day-expense = buf_cd-trans.{&achedayexp}
        buf_temp-ef1.last-date = buf_cd-trans.{&achelastdate}
        .
      end.
      else do:
        assign
        buf_temp-ef1.last-date = string-to-date(buf_temp-ef.init-date-time)
        .
      end.
    end.
    else do:
      assign
      buf_temp-ef1.last-date = string-to-date(buf_temp-ef.init-date-time)
      .
    end.
  end. /*  for each buf_temp_ef1 where*/
end.

end procedure. /* filll-expenses */

&endif