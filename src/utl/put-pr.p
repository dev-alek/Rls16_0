block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: put-pr.p $
$Archive: utl/put-pr.p $

Утилита по выгрузке текущих цен по товарам и признакам

Автор: Чернова Светлана Александровна
Дата создания: 04/13/06
Author: Svetlana Chernova
Creation date: 04/13/06

*/


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: put-pr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/put-pr.p $":U .
define variable vss-description as character no-undo init "Утилита по выгрузке текущих цен по товарам и признакам".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

{ cmp/library.i }
{ str/lib-trn.i  }
{ str/get-pr.i def }
{ gbl/waitfram.i }


define stream out-str.
define buffer buf_db         for ub.db.
define buffer buf_clients    for ub.clients.
define buffer buf_gds-obj    for ub.gds-obj.
define buffer buf_prt-obj    for ub.prt-obj.
define buffer buf_price-doc  for ub.price-doc.
define buffer buf_price-list for ub.price-list.
define buffer buf_bar-code   for ub.bar-code.
define buffer buf_gds-prt    for ub.gds-prt.
define buffer buf_goods      for ub.goods.
define variable varoldcli-type like ub.clients.obj-type initial ? no-undo.
define variable varoldcli-code like ub.clients.obj-code initial ? no-undo.
define variable varempty-scale as logical                         no-undo .
message
"Цены будут выгружены в файлы '<тип объекта>-<код объекта>-pr.adb.'"
view-as alert-box information.

run waitfram-show in this-procedure (input "Выгрузка цен").

for each buf_db no-lock
  ,each buf_clients no-lock
    where buf_clients.db-num = buf_db.db-num
    ,each buf_gds-obj no-lock where buf_gds-obj.obj-type = buf_clients.obj-type and
                                    buf_gds-obj.obj-code = buf_clients.obj-code
      ,first buf_goods no-lock where buf_goods.artic     = buf_gds-obj.artic     and
                                     buf_goods.prod-type = buf_gds-obj.prod-type and
                                     buf_goods.prod-code = buf_gds-obj.prod-code
       on error undo, return error :
    run waitfram-show in this-procedure ("Выгрузка цен по объекту: " + buf_clients.obj-type + " " + string(buf_clients.obj-code) + ". Товар: " + buf_gds-obj.artic + " " + buf_gds-obj.prod-type + " " + string(buf_gds-obj.prod-code)).
    { str/get-pr.i
      no-def
      buf_clients.obj-type
      buf_clients.obj-code
      buf_gds-obj.gds-code
      ?
    }
    if gp-doc-num    <> ? and
       gp-price-sale <> ? and
       gp-price-sale <> 0 then do:
      if buf_clients.obj-type <> varoldcli-type or
         buf_clients.obj-code <> varoldcli-code then do:
         output stream out-str close.
         output stream out-str to value (buf_clients.obj-type + "-" + string(buf_clients.obj-code) + "-pr.adb").
         assign
           varoldcli-type = buf_clients.obj-type
           varoldcli-code = buf_clients.obj-code.
      end.
      put stream out-str unformatted "ITEM:" + buf_gds-obj.artic + ";" + string(buf_gds-obj.prod-code) + ";;;" + string(gp-b-code) + ";" + string(gp-price-sale) + ";;" + buf_goods.unit-base + ";1;" + "0;;;;" skip.
      for each buf_price-list no-lock where buf_price-list.doc-num    = gp-doc-num            and
                                            buf_price-list.main-price = no                    and
                                            buf_price-list.artic      = buf_gds-obj.artic     and
                                            buf_price-list.prod-type  = buf_gds-obj.prod-type and
                                            buf_price-list.prod-code  = buf_gds-obj.prod-code
         , first buf_bar-code where buf_bar-code.b-code = buf_price-list.b-code on error undo, return error :
         if buf_bar-code.in-code <> "" then do:
           put stream out-str unformatted "PART:" + buf_gds-obj.artic + ";" + string(buf_gds-obj.prod-code) + ";" + buf_bar-code.in-code + ";" + buf_bar-code.part-code + ";" + string(buf_price-list.b-code) + ";" + string(buf_price-list.price-sale) + ";;" + buf_bar-code.unit-cli + ";" + string(buf_bar-code.cli-base-rate) + ";" + (if buf_bar-code.cli-base-rate = 1 then "0" else string(buf_price-list.d-pcnt)) + ";;;;" skip.
         end.
         else do:
           find first buf_gds-prt no-lock where buf_gds-prt.node-code = buf_bar-code.node-code.
           if buf_gds-prt.upper-code  =  buf_goods.prt-root then do:

             put stream out-str unformatted "ITEM:" + buf_gds-obj.artic + ";" + string(buf_gds-obj.prod-code) + ";;;" + string(buf_price-list.b-code) + ";" + string(buf_price-list.price-sale) + ";;" + buf_bar-code.unit-cli + ";" + string(buf_bar-code.cli-base-rate) + ";" + (if buf_bar-code.cli-base-rate = 1 then "0" else string(buf_price-list.d-pcnt)) + ";;;;" skip.
           end.
           else do:
             put stream out-str unformatted "SCALE:" buf_gds-obj.artic + ";" + string(buf_gds-obj.prod-code) + ";" + buf_gds-prt.f-name + ";;" + string(buf_price-list.b-code) + ";" + string(buf_price-list.price-sale) + ";;" + buf_bar-code.unit-cli + ";" + string(buf_bar-code.cli-base-rate) + ";" + (if buf_bar-code.cli-base-rate = 1 then "0" else string(buf_price-list.d-pcnt)) + ";;;;" skip.
           end.
         end.
      end.
    end.
end.
run waitfram-hide in this-procedure .
message
"Выгрузка цен закончена."
view-as alert-box.