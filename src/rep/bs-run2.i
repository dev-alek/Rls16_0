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
  IF x-SelectObject = "currency":U  OR  xTog-obj THEN DO:
      For  EACH gds-obj
                  where gds-obj.obj-code   = x-store-code /* obj-list.obj-code */
                  AND  gds-obj.obj-type   = x-store-type /* obj-list.obj-type */
                       {&ver-last-doc}
                       and
                 can-find(First ub.ot-line where
                        ub.ot-line.obj-code     = gds-obj.obj-code
                  AND   ub.ot-line.obj-type     = gds-obj.obj-type
                  AND   ub.ot-line.artic        = gds-obj.artic
                  AND   ub.ot-line.prod-code    = gds-obj.prod-code
                  AND   ub.ot-line.prod-type    = gds-obj.prod-type
                  AND   ub.ot-line.fact-order   <= Fact-order-2
                  AND   ub.ot-line.fact-order   >= Fact-order-1
                  AND   ub.ot-line.sum-type      = {&arh-cost}
                  AND   (ub.ot-line.ext-doc-type = {&TDEDT_Ras_Perem}      OR
                        ub.ot-line.ext-doc-type = {&TDEDT_Ras_Vnesh}       OR
                        ub.ot-line.ext-doc-type = {&TDEDT_Vozvrat_Vnesh}   OR
                        ub.ot-line.ext-doc-type = {&TDEDT_Ras_Prvo}        OR
                        ub.ot-line.ext-doc-type = {&TDEDT_Spi_Prvo}        OR
                        ub.ot-line.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}  OR
                        ub.ot-line.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass})
                        no-lock use-index art-ot) = true
                                          no-lock,
            First  tmp#grp
                  WHERE  gds-obj.grp-name   begins tmp#grp.grp-name
                      no-lock ,
              First Goods
                 where gds-obj.prod-code  = Goods.prod-code and
                       gds-obj.prod-type  = Goods.prod-type and
                       gds-obj.artic      = Goods.artic no-lock  Use-index pi

                  :
                  Run Item-Goods ( "{3}" , "{4}" ) .

      End.
  End.

  Else DO:  /*--------------------------------------------------------------------------------------------------*/
  /*по списку obj-list */
  For EACH goods  where
        can-find(First  tmp#grp  WHERE  goods.grp-name   begins tmp#grp.grp-name  no-lock ) = true
        AND
        CAN-find(first gds-obj where gds-obj.prod-code   = goods.prod-code     and
                            gds-obj.prod-type  = goods.prod-type    and
                            gds-obj.artic      = goods.artic        and
                            lookup (gds-obj.obj-type +  '#' +  string( gds-obj.obj-code) , STR-obj )  > 0
                            {&ver-last-doc}
                             And
                          can-find (First ub.ot-line where
                                  ub.ot-line.obj-code     = gds-obj.obj-code
                            AND   ub.ot-line.obj-type     = gds-obj.obj-type
                            AND   ub.ot-line.artic        = gds-obj.artic
                            AND   ub.ot-line.prod-code    = gds-obj.prod-code
                            AND   ub.ot-line.prod-type    = gds-obj.prod-type
                            AND   ub.ot-line.fact-order   <= Fact-order-2
                            AND   ub.ot-line.fact-order   >= Fact-order-1
                            AND   ub.ot-line.sum-type      = {&arh-cost}
                            AND   (ub.ot-line.ext-doc-type = {&TDEDT_Ras_Perem}      OR
                                  ub.ot-line.ext-doc-type = {&TDEDT_Ras_Vnesh}       OR
                                  ub.ot-line.ext-doc-type = {&TDEDT_Vozvrat_Vnesh}       OR
                                  ub.ot-line.ext-doc-type = {&TDEDT_Ras_Prvo}        OR
                                  ub.ot-line.ext-doc-type = {&TDEDT_Spi_Prvo}        OR
                                  ub.ot-line.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}  OR
                                  ub.ot-line.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass})
                                  no-lock use-index art-ot) = true no-lock) = true
                              :
         Run Item-Goods ( "{3}" , "{4}" ) .
     End.
  End.