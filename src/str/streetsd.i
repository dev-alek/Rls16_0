/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обход веток товаров при выгрузке в файл ТСД

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/30/03
Author: Bakhtadze Natalya
Creation date: 07/30/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/*включается с товаром из списка {1} = gds-list или с товаром {1} = goods*/
FIND FIRST ub.prt-obj WHERE
        ub.prt-obj.obj-type = i-obj-type AND
        ub.prt-obj.obj-code = i-obj-code AND
        ub.prt-obj.prod-type = {1}.prod-type AND
        ub.prt-obj.prod-code = {1}.prod-code AND
        ub.prt-obj.artic = {1}.artic AND
        ub.prt-obj.prt-code = b-g-p.node-code NO-LOCK NO-ERROR .

&scop seq {&sequence}
def var l-in-ov{&seq} as logical no-undo .
{ gbl/gdsobjat.i
  i-obj-type
  i-obj-code
  {1}.artic
  {1}.prod-type
  {1}.prod-code
  "'in-ov=request'"
  l-in-ov{&seq}
  no-error
}
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка получения признака товара на объекте - товар &1 &2&3: &4 &5"
                        ,{1}.artic
                        ,{1}.prod-type
                        ,{1}.prod-code
                        ,error-status :get-message(1)
                        ,return-value)
                                            ).
  assign
  v-view-log = yes
  .
  undo, return error .
end.
if (v-in-ov and  l-in-ov{&seq} ) then assign v-err-ov = 1.
assign
v-no-good = no
.
if (NOT temp-shop.all-prt )
    AND  {1}.gds-type = {&gds-goods}
    AND  NOT l-empty-scale then do:
  /*только для шкальных если включена настройка НЕ ВСЕ признаки на кассу*/
  if not available ub.prt-obj then do:
    /*не было движения по признаку*/
    if avail ub.shop and ub.shop.sub-store-on then do:
      /*есть подсобка - ищем на ней*/
      if NOT can-find( first ub.gds-dtl where
                          ub.gds-dtl.artic = {1}.artic AND
                          ub.gds-dtl.prod-type = {1}.prod-type AND
                          ub.gds-dtl.prod-code = {1}.prod-code AND
                          ub.gds-dtl.prt-code = b-g-p.node-code AND
                          ub.gds-dtl.obj-type =  ub.shop.sub-store-type AND
                          ub.gds-dtl.obj-code = ub.shop.sub-store-code) then do:
        assign
        v-no-good = yes
        .
        /*NEXT _b-g-p.*/
      end.
    end.
    else do:
      assign
      v-no-good = yes
      .
      /*NEXT _b-g-p.*/
    end.
  end.
end.

/* $Workfile$ e n d */