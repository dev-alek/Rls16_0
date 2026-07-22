/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вывод строки содержащей информацию по скидке на дисконтной карте и значения скидки на объекте

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/20/06
Author: Bakhtadze Natalya
Creation date: 03/20/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


{ ref/dc-prop.i }

FUNCTION get-dpcn RETURNS CHARACTER (
     input p-d-card as character
    ,input p-emitent-host-code as integer
    ,input p-type as character
    ,input parhost-code as integer
    ,input parobj-type as character
    ,input parobj-code as integer
    ,input p-node-code as integer
    ,input p-d-pcnt as decimal
    ,input p-cash-d-pcnt as decimal
    ,input p-category as integer
    ) :
define buffer buf_dis-card-type for ub.dis-card-type.
define variable loc-d-v as decimal no-undo init ?.
define variable v-discnt-role as character no-undo .
define buffer buf_dis-card-property for ub.dis-card-property.
find first buf_dis-card-type no-lock where
          buf_dis-card-type.type = p-type
      and buf_dis-card-type.emitent-host-code = p-emitent-host-code
      and buf_dis-card-type.host-code = 0
      and buf_dis-card-type.obj-type = '':U
      and buf_dis-card-type.obj-code = 0 no-error.

if available buf_dis-card-type then do:
  case p-node-code:
    when {&dc_prop_discount_d-pcnt} then do:
      assign
      v-discnt-role = {&ddctr-def-pcnt} .
    end.
    when {&dc_prop_discount_cash-d-pcnt} then do:
      assign
      v-discnt-role = {&ddctr-def-cash-pcnt}.
    end.
    when {&dc_prop_discount_category} then do:
      assign
      v-discnt-role = {&ddctr-def-categ}.
    end.
  end case.
  if buf_dis-card-type.d-pcnt-byshop then do:
   /*надо найти свойство по объекту*/
   find first buf_dis-card-property no-lock where
             buf_dis-card-property.d-card = p-d-card
         and buf_dis-card-property.dtm-code = {&dc-prop_discount}
         and buf_dis-card-property.host-code = parhost-code
         and buf_dis-card-property.obj-type = parobj-type
         and buf_dis-card-property.obj-code = parobj-code
         and buf_dis-card-property.node-code = p-node-code no-error.
   if available buf_dis-card-property then do:
     if v-discnt-role = {&ddctr-def-categ} then do:
       assign
       loc-d-v = buf_dis-card-property.property-value-integer.
     end.
     else do:
       assign
       loc-d-v = buf_dis-card-property.property-value-decimal.
     end.
   end.
   /*надо найти свойство по объекту  С ТИПА КАРТЫ*/
   if loc-d-v = ? then do:
    { gbl/objdpcnt.i
      p-type
      p-emitent-host-code
      parhost-code
      parobj-type
      parobj-code
        v-discnt-role
        loc-d-v
        no-error
      }
    end. /*if loc-d-v = ? then do:*/
    if loc-d-v = ? then do:
      /*найдо найти свойство по фирме*/
      find first buf_dis-card-property no-lock where
                buf_dis-card-property.d-card = p-d-card
            and buf_dis-card-property.dtm-code = {&dc-prop_discount}
            and buf_dis-card-property.host-code = parhost-code
            and buf_dis-card-property.obj-type = ''
            and buf_dis-card-property.obj-code = 0
            and buf_dis-card-property.node-code = p-node-code no-error.
      if available buf_dis-card-property then do:
        if v-discnt-role = {&ddctr-def-categ} then do:
          assign
          loc-d-v = buf_dis-card-property.property-value-integer.
        end.
        else do:
          assign
          loc-d-v = buf_dis-card-property.property-value-decimal.
        end.
      end.
    end. /*if loc-d-v = ? then do:*/
    if loc-d-v = ? then do:
      /*надо найти свойство по фирме  С ТИПА КАРТЫ*/
      { gbl/objdpcnt.i
        p-type
        p-emitent-host-code
        parhost-code
        ''
        0
        v-discnt-role
      loc-d-v
      no-error
    }
    end.
    if loc-d-v = ? then do:
      case v-discnt-role:
        when {&ddctr-def-categ} then do:
          loc-d-v = p-category.
        end.
        when {&ddctr-def-pcnt} then do:
          loc-d-v = p-d-pcnt.
        end.
        when {&ddctr-def-cash-pcnt} then do:
          loc-d-v = p-cash-d-pcnt.
        end.
      end case.
    end.
    if v-discnt-role = {&ddctr-def-categ} then do:
      return substitute("(i) &1", string(loc-d-v, ">>>9")).
    end.
    else do:
      return substitute("(i) &1", string(loc-d-v, "->9.99%")).
    end.
  end. /*if buf_dis-card-type.d-pcnt-byshop then do:*/
end.
else do:
 return "ОШИБКА-НЕТ ТИПА".
end.
case v-discnt-role:
  when {&ddctr-def-categ} then do:
     loc-d-v = p-category.
     return string(loc-d-v, ">>>9").
  end.
  when {&ddctr-def-pcnt} then do:
    loc-d-v = p-d-pcnt.
    return string(loc-d-v, "->9.99%").
  end.
  when {&ddctr-def-cash-pcnt} then do:
    loc-d-v = p-cash-d-pcnt.
    return string(loc-d-v, "->9.99%").
  end.
end case.
END FUNCTION.


/* $Workfile$ e n d */