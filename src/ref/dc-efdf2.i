/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Сводные таблицы для EasyFuel2

Автор: Сливенко Сергей Андреевич
Дата создания: 26/09/12
Author: Slivenko Sergey
Creation date: 26/09/12

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
index pi is unique primary
d-card
.


DEFINE TEMP-TABLE {1}temp-ef1 NO-UNDO
field d-card as character
FIELD rfn-code AS character /* номер RFN */ format "X(16)"  label "Номер RFN"
FIELD limit AS decimal    /* Максимальный объем (т.е. обхем бака) */ label "Максимальный!объем"
FIELD status_ AS logical /* Статус (Активная метка/удалена) */ label "Статус"
field name as character   /*  "easyfuel2-rfn"  */
field new_ as logical
INDEX pi IS UNIQUE PRIMARY
d-card
rfn-code
INDEX ip rfn-code
INDEX name d-card name
.
/*
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
 */

/*
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
 */
&if defined(dc-efdf_proc) = 0 &then

&glob dc-efdf_proc


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
  if available buf_dis-card then do:
    /*buffer-copy buf_dis-card
    except d-card
    to buf_temp-ef*/
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
    and temp-dis-card-property.dtm-code = {&dc-prop_easyfuel2}
    :
   CASE temp-dis-card-property.node-code:
     WHEN {&dc_prop_easyfuel_car-reg-number} THEN DO:
       buf_temp-ef.car-reg-number = temp-dis-card-property.property-value-character.
     END.
     WHEN {&dc_prop_easyfuel_car-brand} THEN DO:
        buf_temp-ef.car-brand = temp-dis-card-property.property-value-character.
     END.
   END CASE.
 END.
 RUN fill-tables IN THIS-PROCEDURE ( buffer buf_temp-ef) NO-ERROR.
end.

end procedure. /* fill-main-table */


PROCEDURE fill-tables :
define parameter buffer buf_temp-ef for temp-ef.
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-gds-code AS INTEGER NO-UNDO.
define buffer buf_ext-classif for ub.ext-classif.

    for each buf_ext-classif no-lock where buf_ext-classif.classif-subject = buf_temp-ef.d-card and
                                           buf_ext-classif.classif-name = "easyfuel2-rfn" :
      find first temp-ef1 no-lock where temp-ef1.d-card   = buf_temp-ef.d-card and
                                        temp-ef1.name     = buf_ext-classif.classif-name and
                                        temp-ef1.rfn-code = buf_ext-classif.CharKey_One no-error.
      if not available temp-ef1 then do :
        create temp-ef1.
        assign
          temp-ef1.d-card = buf_temp-ef.d-card
          temp-ef1.name   = buf_ext-classif.classif-name
          temp-ef1.rfn-code = buf_ext-classif.CharKey_One
          temp-ef1.limit = decimal(buf_ext-classif.CharKey_Two)
          temp-ef1.status_ = logical(buf_ext-classif.CharKey_Three)
        .
      end.
    end.

END PROCEDURE.


&endif