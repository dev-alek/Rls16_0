/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

обход веток товаров при пересылке

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/*включается с товаром из списка {1} = gds-list или с товаром {1} = goods*/
FIND FIRST ub.prt-obj WHERE
        ub.prt-obj.obj-type = {3} AND
        ub.prt-obj.obj-code = {4} AND
        ub.prt-obj.prod-type = {1}.prod-type AND
        ub.prt-obj.prod-code = {1}.prod-code AND
        ub.prt-obj.artic = {1}.artic AND
        ub.prt-obj.prt-code = b-g-p.node-code NO-LOCK NO-ERROR .
if v-is-restaurant and v-is-null-price then.
else do:
&if "{&called}" <> "in-ov"
and "{&bbc}" = ""
&then
  &scop seq {&sequence}
  def var l-in-ov{&seq} as logical no-undo .

  { gbl/gdsobjat.i
    {3}
    {4}
    {1}.artic
    {1}.prod-type
    {1}.prod-code
    "'in-ov=request'"
    l-in-ov{&seq}
    no-error
  }
  if error-status:error then do:
    message
      "Ошибка получения признака товара на объекте" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.
  if ({2}.in-ov and  l-in-ov{&seq} ) then
  &if "{&called}" = "in-ov" or "{&called}" = "send-gds" OR "{&called}" = "del-gds" OR "{&called}" = "sndalgds" OR "{&called}" = "send-codes-only" or "{&called}" = "pdf" &then
              NEXT _b-g-p.
  &else
              return.
  &endif
&endif
if (NOT {2}.all-prt )
    AND  {1}.gds-type = {&gds-goods}
    AND  NOT l-empty-scale then do:
  /*только для шкальных если включена настройка НЕ ВСЕ признаки на кассу*/
  if not available ub.prt-obj then do:
    /*не было движения по признаку*/
    if {2}.sub-store-on then do:
      /*есть подсобка - ищем на ней*/
      if NOT can-find( first ub.gds-dtl where
                          ub.gds-dtl.artic = {1}.artic AND
                          ub.gds-dtl.prod-type = {1}.prod-type AND
                          ub.gds-dtl.prod-code = {1}.prod-code AND
                          ub.gds-dtl.prt-code = b-g-p.node-code AND
                          ub.gds-dtl.obj-type =  {2}.sub-store-type AND
                          ub.gds-dtl.obj-code = {2}.sub-store-code) then
      &if "{&called}" = "in-ov" or "{&called}" = "send-gds" OR "{&called}" = "del-gds" OR "{&called}" = "sndalgds" or "{&called}" = "send-codes-only" or "{&called}" = "pdf" &then
                  NEXT _b-g-p.
      &else
                  return.
      &endif
    end.
    else do:
      &if "{&called}" = "in-ov" or "{&called}" = "send-gds" OR "{&called}" = "del-gds" OR "{&called}" = "sndalgds" or "{&called}" = "send-codes-only" or "{&called}" = "pdf" &then
                  NEXT _b-g-p.
      &else
                  return.
      &endif
    end.
  end.
end.
end. /*не ресторан не нулевая цена*/

/* $Workfile$ e n d */