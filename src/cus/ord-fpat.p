block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ord-fpat.p $
$Archive: cus/ord-fpat.p $

Размазывание по объектам используя атрибуты заказа

Автор: Чернова Светлана Александровна
Дата создания: 10/02/06
Author: Svetlana Chernova
Creation date: 10/02/06

*/
define input  parameter parparentproc as handle no-undo .
define input  parameter p-doc-code as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ord-fpat.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/ord-fpat.p $":U .
define variable vss-description as character no-undo init "Размазывание по объектам используя атрибуты заказа".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ cmp/obj-list.i }
{ cus/ord-code.i def }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

define variable str-pos as integer no-undo .
define variable str-pos2 as integer no-undo .
define variable str-1 as character no-undo .
define variable i  as integer no-undo .
define variable e1 as character no-undo .
define variable e2 as integer no-undo .

define buffer buf_ord-doc       for ub.ord-doc  .
define buffer buf_ord-line      for ub.ord-line  .
define buffer buf_ord-line-attr for ub.ord-line-attr  .

find first buf_ord-doc no-lock where
           buf_ord-doc.doc-code =  p-doc-code no-error .
if error-status :error then return error return-value .
/* Список объектов */
define variable p-e-m as character no-undo .
p-e-m = buf_ord-doc.e-method.
for each  obj-list : delete obj-list . end.

    str-pos = index (  p-e-m , "&" ) .
    str-pos2 = length ( p-e-m ) - str-pos .

    str-1 = substring (p-e-m , str-pos + 1 , str-pos2 ).
    do i = 1 to num-entries (str-1) :
        assign
          e1 = entry(1, (entry( i , str-1, "," )) , " ")
          e2 = integer(entry(2, (entry( i , str-1, "," )), " " ))
          no-error .
          if error-status :error then next.
          { cmp/cr-objls.i e1 e2 }
    end.
/* Создание поставки */
define variable p-rcv-code as character no-undo .
define variable v-empty-rcv as logical no-undo .
do transaction :
  for each obj-list:
    run create-ord-doc-rcv in this-procedure
    (input obj-list.obj-type,
        input obj-list.obj-code ,
        output p-rcv-code ) .
        assign v-empty-rcv = yes.
        for each buf_ord-line no-lock where
                buf_ord-line.doc-code = buf_ord-doc.doc-code :
            find first buf_ord-line-attr no-lock where
                      buf_ord-line-attr.doc-code = buf_ord-doc.doc-code and
                      buf_ord-line-attr.gds-code = buf_ord-line.gds-code and
                      buf_ord-line-attr.attr-code = "objqnty"  + {&delim-par} +
                                                    obj-list.obj-type + {&delim-par} +
                                                    string(obj-list.obj-code)    no-error .

                if available buf_ord-line-attr and decimal (buf_ord-line-attr.attr-value) > 0 then do:
                  assign v-empty-rcv = no.
                  run create-ord-line-rcv in this-procedure
                      (input p-rcv-code ,
                       input decimal( buf_ord-line-attr.attr-value )).
                end.
        end.
        if v-empty-rcv = yes then do: /*если у всех линий в поставке кол-во = 0, удаляем поставку*/
          find first ub.ord-doc-rcv where ub.ord-doc-rcv.rcv-code = p-rcv-code no-error.
          if available ub.ord-doc-rcv then do:
              delete ub.ord-doc-rcv.
          end.
        end.
  end.
end.

procedure create-ord-doc-rcv :
 do
 on error undo, return error return-value
 :
define input parameter  p-obj-type like ub.clients.obj-type no-undo .
define input parameter  p-obj-code like ub.clients.obj-code no-undo .
define output parameter loc-ord-num as character no-undo .
{ cmp/df-sub.i  }
{ gbl/curobjdt.i p-obj-type p-obj-code to-day }
loc-ord-num = "" .
find first  ub.ord-doc-rcv where
      ub.ord-doc-rcv.doc-code  = buf_ord-doc.doc-code and
      ub.ord-doc-rcv.obj-code  = p-obj-code and
      ub.ord-doc-rcv.obj-type  = p-obj-type no-lock no-error  .

if available ub.ord-doc-rcv  then do:
  loc-ord-num = ub.ord-doc-rcv.rcv-code .
  return.
end.
define variable store-type as character no-undo .
define variable store-code as integer   no-undo .
define variable v-i-doc as character no-undo .
store-type = p-obj-type.
store-code = p-obj-code.

{ cus/ord-code.i
 'main'
  v-cntxt-db-num
  p-obj-type
  p-obj-code
  v-i-doc
  loc-ord-num
  }
   create ub.ord-doc-rcv.
   buffer-copy buf_ord-doc to ub.ord-doc-rcv.
   assign
      ub.ord-doc-rcv.rcv-code  = loc-ord-num
      ub.ord-doc-rcv.doc-type  = 'out':U
      ub.ord-doc-rcv.doc-date  = to-day
      ub.ord-doc-rcv.creid     = v-cntxt-userid
      ub.ord-doc-rcv.status_   = {&g___new}
      ub.ord-doc-rcv.obj-code  = p-obj-code
      ub.ord-doc-rcv.obj-type  = p-obj-type
      ub.ord-doc-rcv.sub-par   = trim(entry(1, buf_ord-doc.cli-out-doc, {&delim-par})) + {&delim-par} + trim(buf_ord-doc.vat-type) + {&delim-par}
   .
  end. /* do */
end procedure. /* create-ord-doc-rcv */


procedure create-ord-line-rcv :
 do
 on error undo, return error return-value
 :
 define input parameter p-rcv-code as character no-undo .
 define input parameter p-qnty     as decimal   no-undo .

 define buffer b-ord-doc-rcv  for ub.ord-doc-rcv.

 create ub.ord-line-rcv .
 BUFFER-COPY buf_ord-line to ub.ord-line-rcv
 assign
   ub.ord-line-rcv.rcv-code  = p-rcv-code
   ub.ord-line-rcv.qnty      = p-qnty
 .

    find first ub.goods no-lock where
               ub.goods.gds-code = buf_ord-line.gds-code .

    if can-find ( first ub.units where ub.units.unit-name = ub.goods.unit-base
        and lookup({&pieces}, ub.units.type) > 0)
        and trunc( ub.ord-line-rcv.qnty, 0 ) <> ub.ord-line-rcv.qnty then do:
            ub.ord-line-rcv.qnty = trunc( ub.ord-line-rcv.qnty, 0 ) + 1 .
    end.

    ub.ord-line-rcv.cli-qnty  = ub.ord-line-rcv.qnty / ub.ord-line-rcv.cli-base-rate .

    if can-find(first ub.units where ub.units.unit-name = ub.goods.unit-cli
        and lookup({&pieces}, ub.units.type) > 0)
        and trunc( ub.ord-line-rcv.cli-qnty, 0 ) <> ub.ord-line-rcv.cli-qnty then do:
            ub.ord-line-rcv.cli-qnty = trunc( ub.ord-line-rcv.cli-qnty, 0 ) + 1 .
            ub.ord-line-rcv.qnty  = ub.ord-line-rcv.cli-qnty * ub.ord-line-rcv.cli-base-rate .
    end.

 end. /* do */
end procedure. /* create-ord-line-rcv */