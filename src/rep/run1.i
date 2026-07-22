/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Creation date: 12/18/01 1:38

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
for each gds-obj
    where  gds-obj.obj-code   = x-store-code
      and  gds-obj.obj-type   = x-store-type
                                no-lock ,
    first {4}
          where gds-obj.prod-code  = {4}.prod-code and
                gds-obj.prod-type  = {4}.prod-type and
                gds-obj.artic      = {4}.artic  no-lock ,
    first b-clients no-lock where b-clients.obj-type = {4}.prod-type and
                                  b-clients.obj-code = {4}.prod-code
          break
          &if "{1}" <> "1" &then by {1} &endif
          &if "{2}" <> "1" &then by {2} &endif
          by {5} :
      { rep/z-item2.i "{1}"  "{2}"  "{3}"  "{4}"   "{5}" }
end.
/* $Workfile$ e n d */