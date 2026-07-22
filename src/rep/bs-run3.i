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
                WHERE  gds-obj.obj-code   = x-store-code /* obj-list.obj-code */
                  AND  gds-obj.obj-type   = x-store-type /* obj-list.obj-type */
                  {&ver-last-doc}
                  And
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
                        ub.ot-line.ext-doc-type = {&TDEDT_Vozvrat_Vnesh}       OR
                        ub.ot-line.ext-doc-type = {&TDEDT_Ras_Prvo}        OR
                        ub.ot-line.ext-doc-type = {&TDEDT_Spi_Prvo}        OR
                        ub.ot-line.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}  OR
                        ub.ot-line.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass})
                        no-lock use-index art-ot) = true
                 AND
                CAN-Find ( First G#cli
                          Where gds-obj.prod-code  = g#cli.obj-code
                          AND   gds-obj.prod-type  = g#cli.obj-type
                          no-lock ) = true
                  no-lock,
            First Goods
                 where gds-obj.prod-code  = Goods.prod-code and
                       gds-obj.prod-type  = Goods.prod-type and
                       gds-obj.artic      = Goods.artic no-lock  Use-index pi :

                  Run Item-Goods ( "{3}" , "{4}" ) .

        End.
   End.

   Else DO:
  For EACH goods  where
         CAN-Find ( First G#cli
                  Where goods.prod-code  = g#cli.obj-code
                  AND   goods.prod-type  = g#cli.obj-type
                  no-lock ) = true
          AND
               can-find(first gds-obj where gds-obj.prod-code   =  {4}.prod-code  and
                            gds-obj.prod-type  = {4}.prod-type    and
                            gds-obj.artic      = {4}.artic        and
                            lookup (gds-obj.obj-type +  '#' +  string( gds-obj.obj-code) , STR-obj )  > 0
                            {&ver-last-doc}
                             And
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
                                  no-lock use-index art-ot) = true ) = TRUE
                             no-lock
                             :
         Run Item-Goods ( "{3}" , "{4}" ) .
     End.
  End.