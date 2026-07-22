/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

*/
  if x-selectobject = "currency":u  or  xtog-obj then do:
        for each gds-obj where
                              gds-obj.obj-type = x-store-type    and
                              gds-obj.obj-code = x-store-code
                              {&ver-last-doc}
                              and
            can-find(first ub.ot-line where
                  ub.ot-line.obj-code     = gds-obj.obj-code
            and   ub.ot-line.obj-type     = gds-obj.obj-type
            and   ub.ot-line.artic        = gds-obj.artic
            and   ub.ot-line.prod-code    = gds-obj.prod-code
            and   ub.ot-line.prod-type    = gds-obj.prod-type
            and   ub.ot-line.fact-order   <= fact-order-2
            and   ub.ot-line.fact-order   >= fact-order-1
            and   ub.ot-line.sum-type      = {&arh-cost}
            and   (ub.ot-line.ext-doc-type = {&tdedt_ras_perem}      or
                  ub.ot-line.ext-doc-type = {&tdedt_ras_vnesh}       or
                  ub.ot-line.ext-doc-type = {&tdedt_vozvrat_vnesh}   or
                  ub.ot-line.ext-doc-type = {&tdedt_ras_prvo}        or
                  ub.ot-line.ext-doc-type = {&tdedt_spi_prvo}        or
                  ub.ot-line.ext-doc-type = {&tdedt_ras_vnesh_kass}  or
                  ub.ot-line.ext-doc-type = {&tdedt_vozvrat_vnesh_kass})
                  no-lock ) = true
                                    no-lock,
                        first {4}  where
                              gds-obj.prod-code  = {4}.prod-code and
                              gds-obj.prod-type  = {4}.prod-type and
                              gds-obj.artic      = {4}.artic       no-lock

                    :
                    run item-goods ( "{3}" , "{4}" ) .
      end.
  end.

  else do:  /*--------------------------------------------------------------------------------------------------*/
  /*по списку obj-list */
  for each {4} where
      can-find(first gds-obj where gds-obj.prod-code   =  {4}.prod-code  and
                  gds-obj.prod-type  = {4}.prod-type    and
                  gds-obj.artic      = {4}.artic        and
                  lookup (gds-obj.obj-type +  '#' +  string( gds-obj.obj-code) , str-obj )  > 0
                  {&ver-last-doc}
                    and
                can-find(first ub.ot-line where
                        ub.ot-line.obj-code     = gds-obj.obj-code
                  and   ub.ot-line.obj-type     = gds-obj.obj-type
                  and   ub.ot-line.artic        = gds-obj.artic
                  and   ub.ot-line.prod-code    = gds-obj.prod-code
                  and   ub.ot-line.prod-type    = gds-obj.prod-type
                  and   ub.ot-line.fact-order   <= fact-order-2
                  and   ub.ot-line.fact-order   >= fact-order-1
                  and   ub.ot-line.sum-type      = {&arh-cost}
                  and   (ub.ot-line.ext-doc-type = {&tdedt_ras_perem}      or
                        ub.ot-line.ext-doc-type = {&tdedt_ras_vnesh}       or
                        ub.ot-line.ext-doc-type = {&tdedt_vozvrat_vnesh}       or
                        ub.ot-line.ext-doc-type = {&tdedt_ras_prvo}        or
                        ub.ot-line.ext-doc-type = {&tdedt_spi_prvo}        or
                        ub.ot-line.ext-doc-type = {&tdedt_ras_vnesh_kass}  or
                        ub.ot-line.ext-doc-type = {&tdedt_vozvrat_vnesh_kass})
                        no-lock ) = true ) = true
                    no-lock
                    :
                    run item-goods ("{3}" , "{4}" ) .
     end.
  end.