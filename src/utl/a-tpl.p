block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: a-tpl.p $
$Archive: utl/a-tpl.p $

Проставить АВТОПЕРЕОЦЕНКИ В ГТПЛ

Автор: Чернова Светлана Александровна
Дата создания: 07/07/08
Author: Svetlana Chernova
Creation date: 07/07/08

*/
define input parameter parparentproc as handle no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: a-tpl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/a-tpl.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ ref/xobjgrp.i  }  /* список объектов  */
{ cmp/library.i  }
{ str/lib-trn.i  }
{ cmp/showinf.i  }

define temp-table temp-obj no-undo like ub.clients
  field is-yes as logical
.

if g#db-num  <> 0 then  do:
 message "Утилита для ГБД" view-as alert-box information .
 return .
end.

define temp-table temp-tpl no-undo like ub.price-list-type .

for each ub.price-list-type no-lock where
         ub.price-list-type.stts = integer({&pdf-new}) and
         ub.price-list-type.main = true :

    for each x_obj-group : delete  x_obj-group . end.
    run metod-gop-obj ( 0 , ub.price-list-type.gop-id , ub.price-list-type.gop-db-num ) .

    for each x_obj-group :
        find first temp-obj where
                   temp-obj.obj-type = x_obj-group.obj-type and
                   temp-obj.obj-code = x_obj-group.obj-code
        no-error .
        if  not available temp-obj then do:
            create temp-obj.
            buffer-copy x_obj-group to temp-obj .
        end.
        else do:
           find first temp-tpl where
                      temp-tpl.plt-id      = ub.price-list-type.plt-id     and
                      temp-tpl.plt-db-num  = ub.price-list-type.plt-db-num
              no-error .
              if not available temp-tpl  then do:
                create temp-tpl.
                buffer-copy ub.price-list-type to  temp-tpl .
              end.
        end.
    end.

end.

for each ub.price-list-type exclusive-lock where
         ub.price-list-type.main = true and
         ub.price-list-type.stts = integer({&pdf-new})  and
         ub.price-list-type.only-gbd <> integer(yes) :

      find first temp-tpl where
                 temp-tpl.plt-id      = ub.price-list-type.plt-id       and
                 temp-tpl.plt-db-num  = ub.price-list-type.plt-db-num
      no-error .
      if not available temp-tpl  then do:
         ub.price-list-type.only-gbd = integer(yes) .
         ub.price-list-type.ban-discnt = 0 .
      end.
end.

define variable vvv as logical   no-undo init false .

if can-find (first temp-tpl ) then do:
   vvv = true .
   message "Найдены ТПЛ по которым объекты пересекаются. Они и их объекты будут выведены в файл dbltpl.txt" view-as alert-box information .
end.
else do:
   vvv = false  .
   message "Пересечений нет . ГТПЛ обнавлены. ОК" view-as alert-box information .
end.


if vvv = true  then do:
define stream rpt .
output stream rpt to "dbltpl.txt" .

for each temp-tpl :
    Put stream  rpt unformatted
        temp-tpl.plt-id     " БД"
        temp-tpl.plt-db-num  " "
        temp-tpl.name
        skip.

    for each x_obj-group : delete  x_obj-group . end.
    run metod-gop-obj ( 0 , temp-tpl.gop-id , temp-tpl.gop-db-num ) .
    for each x_obj-group :
       Put stream  rpt unformatted
        x_obj-group.obj-type
        x_obj-group.obj-code
        skip.
    end.
end.

output stream rpt close.
message "все".
end.