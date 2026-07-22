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

FUNCTION get-d-pcnt{2} RETURNS CHARACTER

&if "{1}" <> "" &then
  ( buffer loc-dis-card for {1},
&else
  ( buffer loc-dis-card for ub.dis-card,
&endif
    input parhost-code as integer,
    input parobj-type as character,
    input parobj-code as integer,
    input p-discnt-role as character,
    output loc-d-v as decimal) :
define variable v-node-code as integer no-undo .
define buffer buf_dis-card-type for ub.dis-card-type.
define buffer buf_dis-card-property for ub.dis-card-property.
find first buf_dis-card-type no-lock where
          buf_dis-card-type.type = loc-dis-card.type
      and buf_dis-card-type.emitent-host-code = loc-dis-card.emitent-host-code
      and buf_dis-card-type.host-code = 0
      and buf_dis-card-type.obj-type = '':U
      and buf_dis-card-type.obj-code = 0 no-error.

if available buf_dis-card-type then do:
  case p-discnt-role:
    when {&ddctr-def-pcnt}  then do:
      assign
      v-node-code = {&dc_prop_discount_d-pcnt}.
    end.
    when {&ddctr-def-cash-pcnt} then do:
      assign
      v-node-code = {&dc_prop_discount_cash-d-pcnt}.
    end.
    when {&ddctr-def-categ} then do:
      assign
      v-node-code = {&dc_prop_discount_category}.
    end.
  end.

  if buf_dis-card-type.d-pcnt-byshop then do:

    /*надо найти свойство по объекту по ДК*/
   /*надо найти свойство по объекту*/
   find first buf_dis-card-property no-lock where
             buf_dis-card-property.d-card = loc-dis-card.d-card
         and buf_dis-card-property.dtm-code = {&dc-prop_discount}
         and buf_dis-card-property.host-code = parhost-code
         and buf_dis-card-property.obj-type = parobj-type
         and buf_dis-card-property.obj-code = parobj-code
         and buf_dis-card-property.node-code = v-node-code no-error.
   if available buf_dis-card-property then do:
     if p-discnt-role = {&ddctr-def-categ} then do:
       assign
       loc-d-v = buf_dis-card-property.property-value-integer.
     end.
     else do:
       assign
       loc-d-v = buf_dis-card-property.property-value-decimal.
     end.
   end. /*if available buf_dis-card-property then do:*/

    /*надо найти свойство по объекту по типу ДК*/
    if loc-d-v = ? then do:
    { gbl/objdpcnt.i
      loc-dis-card.type
      loC-dis-card.emitent-host-code
      parhost-code
      parobj-type
      parobj-code
      p-discnt-role
      loc-d-v
      no-error
    }
    end.

    /*надо найти свойство по фирме*/
    if loc-d-v = ? then do:
      find first buf_dis-card-property no-lock where
                buf_dis-card-property.d-card = loc-dis-card.d-card
            and buf_dis-card-property.dtm-code = {&dc-prop_discount}
            and buf_dis-card-property.host-code = parhost-code
            and buf_dis-card-property.obj-type = ''
            and buf_dis-card-property.obj-code = 0
            and buf_dis-card-property.node-code = v-node-code no-error.
      if available buf_dis-card-property then do:
        if p-discnt-role = {&ddctr-def-categ} then do:
          assign
          loc-d-v = buf_dis-card-property.property-value-integer.
        end.
        else do:
          assign
          loc-d-v = buf_dis-card-property.property-value-decimal.
        end.
      end. /*if available buf_dis-card-property then do:*/
    end.
    /*надо найти свойство по фирме по типу ДК*/
    if loc-d-v = ? then do:
      { gbl/objdpcnt.i
        loc-dis-card.type
        loC-dis-card.emitent-host-code
        parhost-code
        ''
        0
        p-discnt-role
        loc-d-v
        no-error
      }
    end.
    if loc-d-v = ? then do:
      case p-discnt-role:
        when {&ddctr-def-categ} then do:
          loc-d-v = loc-dis-card.category.
        end.
        when {&ddctr-def-pcnt} then do:
          loc-d-v = loc-dis-card.d-pcnt.
        end.
        when {&ddctr-def-cash-pcnt} then do:
          loc-d-v = loc-dis-card.cash-d-pcnt.
        end.
      end case.
    end.
    if p-discnt-role = {&ddctr-def-categ} then do:
      return substitute("(i) &1", string(loc-d-v, ">>>9")).
    end.
    else do:
      return substitute("(i) &1", string(loc-d-v, "->9.99%")).
    end.
  end.
end.
else do:
 return "ОШИБКА-НЕТ ТИПА".
end.
case p-discnt-role:
  when {&ddctr-def-categ} then do:
     loc-d-v = loc-dis-card.category.
     return string(loc-d-v, ">>>9").
  end.
  when {&ddctr-def-pcnt} then do:
    loc-d-v = loc-dis-card.d-pcnt.
    return string(loc-d-v, "->9.99%").
  end.
  when {&ddctr-def-cash-pcnt} then do:
    loc-d-v = loc-dis-card.cash-d-pcnt.
    return string(loc-d-v, "->9.99%").
  end.
end case.
END FUNCTION.


/* $Workfile$ e n d */