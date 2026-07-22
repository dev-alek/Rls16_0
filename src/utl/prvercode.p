block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: prvercode.p $
$Archive: utl/prvercode.p $



Автор: Чернова Светлана Александровна
Дата создания: 10/23/08
Author: Svetlana Chernova
Creation date: 10/23/08

*/
define input  parameter parparentproc as handle no-undo .
define input  parameter p-doc-code as character no-undo .


{ cmp/trg-def.i  }

define buffer main_price-list for ub.price-list  .
define buffer main_price-doc-forming-gds for ub.price-doc-forming-gds  .

define variable k as integer   no-undo .
define variable v-root-b-code as integer no-undo .

find first ub.price-doc no-lock where ub.price-doc.doc-num = p-doc-code .
find first ub.price-doc-forming no-lock where
           ub.price-doc-forming.plt-db-num  = ub.price-doc.plt-db-num and
           ub.price-doc-forming.plt-id      = ub.price-doc.plt-id     and
           ub.price-doc-forming.pdf-db      = ub.price-doc.pdf-db     and
           ub.price-doc-forming.pdf-id      = ub.price-doc.pdf-id     no-error .

for each ub.price-list exclusive-lock  where
          ub.price-list.doc-num = p-doc-code :
      find first ub.goods no-lock where
                 ub.goods.artic     =  ub.price-list.artic and
                 ub.goods.prod-type =  ub.price-list.prod-type and
                 ub.goods.prod-code =  ub.price-list.prod-code .

                  { gbl/gdsbcode.i
                    ub.goods.gds-code
                    ?
                    v-root-b-code
                  }

          if v-root-b-code <> ub.price-list.b-code
                then ub.price-list.main-price = false .
                else ub.price-list.main-price = true .

      find first ub.price-doc-forming-gds no-lock  where
                  ub.price-doc-forming-gds.plt-db-num  = ub.price-doc.plt-db-num and
                  ub.price-doc-forming-gds.plt-id      = ub.price-doc.plt-id     and
                  ub.price-doc-forming-gds.pdf-db      = ub.price-doc.pdf-db     and
                  ub.price-doc-forming-gds.pdf-id      = ub.price-doc.pdf-id     and
                  ub.price-doc-forming-gds.b-code      = ub.price-list.b-code no-error .

        if ub.price-list.main-price = false then do:
           /* найдем главную для него */
           find first main_price-list no-lock where
                      main_price-list.doc-num = p-doc-code and
                      main_price-list.b-code  = v-root-b-code no-error .

          if not available main_price-list then do:
             find first ub.gds-obj no-lock where
                        ub.gds-obj.gds-code = ub.goods.gds-code and
                        ub.gds-obj.obj-code = ub.price-doc.obj-code and
                        ub.gds-obj.obj-type = ub.price-doc.obj-type.
             create main_price-list.
             buffer-copy ub.price-list to main_price-list
                assign
                  main_price-list.b-code     = v-root-b-code
                  main_price-list.main-price = true
                  main_price-list.price-sale = ub.gds-obj.price-sale
                .
                k = k + 1 .
                find first main_price-doc-forming-gds exclusive-lock where
                           main_price-doc-forming-gds.plt-db-num  = ub.price-doc.plt-db-num and
                           main_price-doc-forming-gds.plt-id      = ub.price-doc.plt-id     and
                           main_price-doc-forming-gds.pdf-db      = ub.price-doc.pdf-db     and
                           main_price-doc-forming-gds.pdf-id      = ub.price-doc.pdf-id     and
                           main_price-doc-forming-gds.b-code      = main_price-list.b-code
                           no-error .

               if available ub.price-doc-forming-gds and not available main_price-doc-forming-gds then do:
                  create main_price-doc-forming-gds.
                  buffer-copy ub.price-doc-forming-gds to main_price-doc-forming-gds
                    assign
                      main_price-doc-forming-gds.b-code          = v-root-b-code
                      main_price-doc-forming-gds.price-sale-doc  = ub.gds-obj.price-sale
                      main_price-doc-forming-gds.price-sale-rubl = ub.gds-obj.price-sale  * ub.price-doc-forming.exch-rate / ub.price-doc-forming.exch-scale
                      main_price-doc-forming-gds.price-sale-base = main_price-doc-forming-gds.price-sale-rubl  / ub.price-doc.base-rate * ub.price-doc.base-scale
                      .
               end.
          end.
        end.
    end.

message substitute("Исправлено  &1 бар-кодов " ,k ) .