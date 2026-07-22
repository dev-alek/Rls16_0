/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

кусок от РЕЕСТРА ДОКУМЕНТОВ . сбор распределения налогов

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 10/14/04
*/
create tmp#tax{1}.
assign tmp#tax{1}.type    = ot-tot.sum-type
      tmp#tax{1}.pc      = entry ({2} , ot-tot.cat-id)
      tmp#tax{1}.sum     = if tprintrubl then ot-tot.{1}-rubl else ot-tot.{1}-base
      tmp#tax{1}.sum_full     = if tprintrubl then ot-tot.sum-rubl else ot-tot.sum-base
      .
{3} = {3} + 1.

find first acc#tax{1} where acc#tax{1}.pc   = tmp#tax{1}.pc
                        and acc#tax{1}.type = tmp#tax{1}.type
                        no-error.

if available acc#tax{1} then
  assign  acc#tax{1}.sum     = acc#tax{1}.sum + (if tprintrubl then ot-tot.{1}-rubl else ot-tot.{1}-base).
  else do:
      create acc#tax{1}.
      assign acc#tax{1}.type    = ot-tot.sum-type
              acc#tax{1}.pc      = entry ({2} , ot-tot.cat-id)
              acc#tax{1}.sum     = if tprintrubl then ot-tot.{1}-rubl else ot-tot.{1}-base
              acc#tax{1}.sum_full = if tprintrubl then ot-tot.sum-rubl else ot-tot.sum-base.
          acc-{3} = acc-{3} + 1.
  end.