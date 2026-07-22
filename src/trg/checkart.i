/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка возможности создания строки с данным артикулом и производителем

Автор: Уханов Дмитрий Юрьевич
Дата создания: 09/29/05
Author: Dmitry Ukhanov
Creation date: 09/29/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character no-undo format "x(65)":U initial "@(#)$Workfile$ $Revision$":U.

{ cmp/str-glbl.i }
{ utl/rart-tbl.i }

&if "{1}" = "" &then
  &scoped-define log-db-name ub
&else
  &scoped-define log-db-name {1}
&endif

procedure check-use-artic :
  define input  parameter p-tbl-name  as   character                      no-undo .
  define input  parameter p-artic     like {&log-db-name}.goods.artic     no-undo .
  define input  parameter p-prod-type like {&log-db-name}.goods.prod-type no-undo .
  define input  parameter p-prod-code like {&log-db-name}.goods.prod-code no-undo .

  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop",   vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1. endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_goods for {&log-db-name}.goods .

    if lookup( p-tbl-name, {&TABLE-RART_IGNORE} ) = 0 then do:
      find first buf_goods no-lock
        where buf_goods.artic     = p-artic
          and buf_goods.prod-type = p-prod-type
          and buf_goods.prod-code = p-prod-code
        no-error .
      if not available buf_goods then do:
        return error substitute( "&1 (check-use-artic). Не найден товар с артикулом &2 и производителем &3 &4", vss-include-info{&vssseq}, p-artic, p-prod-type, p-prod-code ) .
      end.

      if buf_goods.stts = integer({&artic-change-int}) then do:
        return error substitute( "&1 (check-use-artic). Нельзя использовать товар с артикулом &2 и производителем &3 &4&5"
                                + "Выполняется переименование артикула и(или) производителя"
                                ,vss-include-info{&vssseq}
                                ,p-artic
                                ,p-prod-type
                                ,p-prod-code
                                ,{&new-line}
                              ) .
      end.
    end.

    return .
  end.

end procedure. /* check-use-artic */

/* $Workfile$   E n d */