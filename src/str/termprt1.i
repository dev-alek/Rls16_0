/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

обработка всех бар-кодов и ДОПБК


Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06


со всеми единицами измерения,
партиями для данного терм узла шкалы имеющих prt-code = n-b-c.node-code


{1} -  буфер goods или gds-list
{2} shop или temp-shop
{3} {&shop} или i-obj-type
{4} shop.obj-code или i-obj-code


*/

  /*заполнение полей временной таблицы для отсылки товаров на кассы*/

  /*непартионные бар-коды*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

  if ((LOOKUP({&serial}, ub.units.type) = 0  and not cashparts) OR
      (LOOKUP({&serial}, ub.units.type) > 0 and NOT {2}.cd-parts-ser)
     )
    then do:
    { str/termprt0.i "{1}" ub.bar-code pusto pusto {2} {3} {4} }
  end.
  if petrol-trk then return.



  /*если товар с признаками и признаки на объекте включены то коды партий на отсылаем!!!*/
  if {2}.doc-prt AND b-g-p.node-name <> {&empty-scale} then NEXT _b-g-p.


  /*нужно ли посылать на кассу все бар-коды партий */
  if {2}.cd-parts-all or (cashparts AND LOOKUP({&serial}, units.type) = 0) then do:
  /*отбираются партии только свободные в настоящий момент*/
    if action = "D":U then do:
      for each p-bar-code No-LOCK WHERE
               p-bar-code.gds-code = {1}.gds-code
           AND p-bar-code.node-code = ub.bar-code.node-code,
          FIRST ub.parts No-LOCK WHERE
                ub.parts.obj-type  = {3}
            AND ub.parts.obj-code  = {4}
            AND ub.parts.artic     = {1}.artic
            AND ub.parts.prod-type = {1}.prod-type
            AND ub.parts.prod-code = {1}.prod-code
            AND ub.parts.in-code   = p-bar-code.in-code
            AND ub.parts.part-code =  p-bar-code.part-code
      break
      by p-bar-code.in-code
      by p-bar-code.part-code:
      IF p-bar-code.unit-cli <> {1}.unit-base then next.
      IF FIRST-OF(p-bar-code.part-code) then do:
        { str/termprt0.i {1} p-bar-code ub.parts.in-code ub.parts.part-code {2} {3} {4} }
      end.
    end.
   end.
   else do:
      FOR EACH ub.parts NO-LOCK WHERE
                ub.parts.obj-type  = {3} AND
                ub.parts.obj-code  = {4} AND
                ub.parts.artic     = {1}.artic AND
                ub.parts.prod-type = {1}.prod-type AND
                ub.parts.prod-code = {1}.prod-code AND
                ub.parts.rsrv-free = yes AND
                ub.parts.status_ = no
      break
      by ub.parts.in-code
      by ub.parts.part-code:
        IF FIRST-OF(ub.parts.part-code) then
        FOR EACH p-bar-code NO-LOCK WHERE
                p-bar-code.gds-code = {1}.gds-code AND
                p-bar-code.in-code = ub.parts.in-code AND
                p-bar-code.part-code = ub.parts.part-code AND
                p-bar-code.node-code = ub.bar-code.node-code AND
                p-bar-code.unit-cli = {1}.unit-base:
          { str/termprt0.i {1} p-bar-code ub.parts.in-code ub.parts.part-code {2} {3} {4} }
        END. /*for each p-bar-code*/
      END. /*for each ub.parts*/
    end.
    return.
  end. /*if ub.shop.cd-parts-all */

  /*нужно ли посылать на кассу все бар-коды партий с непустыми номерами*/
  if {2}.cd-parts-not-blank or (cashparts AND LOOKUP({&serial}, units.type) = 0) then do:
  /*отбираются партии только свободные в настоящий момент*/
    if action = "D":U then do:
      for each p-bar-code No-LOCK WHERE
               p-bar-code.gds-code = {1}.gds-code
           AND p-bar-code.node-code = ub.bar-code.node-code,
          EACH ub.parts No-LOCK WHERE
               ub.parts.obj-type  = {3}
            AND ub.parts.obj-code  = {4}
            AND ub.parts.artic     = {1}.artic
            AND ub.parts.prod-type = {1}.prod-type
            AND ub.parts.prod-code = {1}.prod-code
            AND ub.parts.in-code   = p-bar-code.in-code
            AND ub.parts.part-code =  p-bar-code.part-code
      break
      by p-bar-code.in-code
      by p-bar-code.part-code:
        if p-bar-code.part-code = "":U then NEXT.
        if p-bar-code.unit-cli <> {1}.unit-base then NEXT.
        IF FIRST-OF(p-bar-code.part-code) then do:
          { str/termprt0.i {1} p-bar-code ub.parts.in-code ub.parts.part-code {2} {3} {4} }
        end.
      end.
    end.
    else do:
      FOR EACH ub.parts NO-LOCK  WHERE
                ub.parts.obj-type  = {3} AND
                ub.parts.obj-code  = {4} AND
                ub.parts.artic     = {1}.artic AND
                ub.parts.prod-type = {1}.prod-type AND
                ub.parts.prod-code = {1}.prod-code AND
                ub.parts.rsrv-free = yes AND
                ub.parts.status_ = no AND
                ub.parts.part-code <> ""
      break
      by ub.parts.in-code
      by ub.parts.part-code:
        IF FIRST-OF(ub.parts.part-code) then
        FOR   EACH p-bar-code NO-LOCK WHERE
                    p-bar-code.gds-code = {1}.gds-code AND
                    p-bar-code.in-code = ub.parts.in-code AND
                    p-bar-code.part-code = ub.parts.part-code AND
                    p-bar-code.node-code = ub.bar-code.node-code AND
                    p-bar-code.unit-cli = {1}.unit-base:
          { str/termprt0.i {1} p-bar-code ub.parts.in-code ub.parts.part-code {2} {3} {4} }
        END. /*for each p-bar-code*/
      END. /*for each ub.parts*/
    end.
  end. /*if ub.shop.cd-parts-not-blank */


  /*нужно ли посылать на кассу бар-коды серийных товаров*/
  if LOOKUP({&serial}, units.type) > 0 AND {2}.cd-parts-ser then do:
    /*отбираются партии только свободные в настоящий момент*/
    if action = "D":U then do:
      for each p-bar-code No-LOCK WHERE
               p-bar-code.gds-code = {1}.gds-code
           AND p-bar-code.node-code = ub.bar-code.node-code,
          EACH ub.parts No-LOCK WHERE
               ub.parts.obj-type  = {3}
            AND ub.parts.obj-code  = {4}
            AND ub.parts.artic     = {1}.artic
            AND ub.parts.prod-type = {1}.prod-type
            AND ub.parts.prod-code = {1}.prod-code
            AND ub.parts.in-code   = p-bar-code.in-code
            AND ub.parts.part-code =  p-bar-code.part-code
      break
      by p-bar-code.in-code
      by p-bar-code.part-code:
        if p-bar-code.unit-cli <> {1}.unit-base then NEXT.
        if ub.parts.part-code <> "" and  {2}.cd-parts-not-blank then NEXT.
        IF FIRST-OF(p-bar-code.part-code) then do:
          { str/termprt0.i {1} p-bar-code ub.parts.in-code ub.parts.part-code {2} {3} {4} }
        end.
      end.
    end.
    else do:
      FOR EACH ub.parts NO-LOCK  WHERE
                ub.parts.obj-type  = {3} AND
                ub.parts.obj-code  = {4} AND
                ub.parts.artic     = {1}.artic AND
                ub.parts.prod-type = {1}.prod-type AND
                ub.parts.prod-code = {1}.prod-code AND
                ub.parts.rsrv-free = yes AND
                ub.parts.status_ = no AND
                ub.parts.part-code <> ""
      break
      by ub.parts.in-code
      by ub.parts.part-code:
        IF FIRST-OF(ub.parts.part-code) then do:
          if ub.parts.part-code <> "" and  {2}.cd-parts-not-blank then NEXT.
          FOR EACH p-bar-code NO-LOCK WHERE
                    p-bar-code.gds-code = {1}.gds-code AND
                    p-bar-code.in-code = ub.parts.in-code AND
                    p-bar-code.part-code = ub.parts.part-code AND
                    p-bar-code.node-code = ub.bar-code.node-code AND
                    p-bar-code.unit-cli = {1}.unit-base:
            { str/termprt0.i {1} p-bar-code ub.parts.in-code ub.parts.part-code {2} {3} {4} }
          END. /*for each p-bar-code*/
        END.
      END. /*for each ub.parts*/
    end.
  end. /*if ub.shop.cd-parts-ser*/


/* $Workfile$ e n d */