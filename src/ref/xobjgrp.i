/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Метод формирования списка объектов в статусе ТЕК по номеру группы .

Автор: Чернова Светлана Александровна
Дата создания: 12/20/05
Author: Svetlana Chernova
Creation date: 12/20/05

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
{ cmp/str-glbl.i }
define temp-table x_obj-group no-undo like ub.clients  .
define temp-table x_grp-obj-price no-undo like ub.grp-obj-price .

procedure metod-gop-obj :

  do
  on error undo, return error return-value
  :
define input  parameter p-cntxt-db-num as integer   no-undo .
define input  parameter p-gop-id       as integer   no-undo .
define input  parameter p-gop-db-num   as integer   no-undo .

define buffer buf1_clients for ub.clients  .
define buffer buf_db-grp-obj-price   for ub.db-grp-obj-price  .
define buffer buf_host-grp-obj-price for ub.host-grp-obj-price  .
define buffer buf_obj-grp-obj-price  for ub.obj-grp-obj-price  .

for each  x_obj-group : delete x_obj-group. end.

if p-gop-id = 0 or p-gop-id = ? /* по всем объектам */ then do:
   if p-cntxt-db-num = 0  then do: /* ГБД */
        for each buf1_clients no-lock where
                (buf1_clients.obj-type = {&shop}  or
                 buf1_clients.obj-type = {&stock}  )
                and
                buf1_clients.db-num >= 0  and
                buf1_clients.stts = 0
                :
          create x_obj-group .
          assign
            x_obj-group.obj-code   = buf1_clients.obj-code
            x_obj-group.obj-type   = buf1_clients.obj-type
            x_obj-group.obj-name   = buf1_clients.obj-name
            x_obj-group.db-num     = buf1_clients.db-num
          .
        end.

   end.
   else do: /* УБД */
        for each buf1_clients no-lock where
                (buf1_clients.obj-type = {&shop}  or
                 buf1_clients.obj-type = {&stock}  ) and
                 buf1_clients.db-num = p-cntxt-db-num  and
                 buf1_clients.stts = 0
                :
          create x_obj-group .
          assign
            x_obj-group.obj-code   = buf1_clients.obj-code
            x_obj-group.obj-type   = buf1_clients.obj-type
            x_obj-group.obj-name   = buf1_clients.obj-name
            x_obj-group.db-num     = buf1_clients.db-num
          .
        end.
   end.
end.
else do:
      for each buf_db-grp-obj-price  where
              buf_db-grp-obj-price.gop-id     = p-gop-id and
              buf_db-grp-obj-price.gop-db-num = p-gop-db-num and
              buf_db-grp-obj-price.stts = {&bef-current-status-int}  no-lock :
        for each buf1_clients no-lock where
               (buf1_clients.obj-type = {&shop}  or
                buf1_clients.obj-type = {&stock}  ) and
                buf1_clients.db-num = buf_db-grp-obj-price.dgo-db-num  and
                buf1_clients.stts = 0
                :
          create x_obj-group .
          assign
            x_obj-group.obj-code   = buf1_clients.obj-code
            x_obj-group.obj-type   = buf1_clients.obj-type
            x_obj-group.obj-name   = buf1_clients.obj-name
            x_obj-group.db-num     = buf1_clients.db-num
          .
        end.
      end.



    for each buf_host-grp-obj-price where
            buf_host-grp-obj-price.gop-id     = p-gop-id and
            buf_host-grp-obj-price.gop-db-num = p-gop-db-num and
            buf_host-grp-obj-price.stts = {&bef-current-status-int}
            no-lock :
      for each buf1_clients no-lock where
             (buf1_clients.obj-type = {&shop}  or
              buf1_clients.obj-type = {&stock}  ) and
              buf1_clients.host-code = buf_host-grp-obj-price.host-code and
              buf1_clients.stts = 0
              :
          find first x_obj-group no-lock  where
                    x_obj-group.obj-code   = buf1_clients.obj-code and
                    x_obj-group.obj-type   = buf1_clients.obj-type no-error .
          if not available  x_obj-group then   create x_obj-group .
          assign
            x_obj-group.obj-code   = buf1_clients.obj-code
            x_obj-group.obj-type   = buf1_clients.obj-type
            x_obj-group.obj-name   = buf1_clients.obj-name
            x_obj-group.db-num     = buf1_clients.db-num
          .
      end.
    end.


    for each buf_obj-grp-obj-price where
            buf_obj-grp-obj-price.gop-id     = p-gop-id and
            buf_obj-grp-obj-price.gop-db-num = p-gop-db-num and
            buf_obj-grp-obj-price.stts = {&bef-current-status-int}
            no-lock :

      for each buf1_clients no-lock where
                buf1_clients.obj-type = buf_obj-grp-obj-price.obj-type and
                buf1_clients.obj-code = buf_obj-grp-obj-price.obj-code and
                buf1_clients.stts     = 0
                :
          find first  x_obj-group no-lock  where
                      x_obj-group.obj-code   = buf1_clients.obj-code and
                      x_obj-group.obj-type   = buf1_clients.obj-type no-error .
          if not available  x_obj-group then   create x_obj-group .
          assign
            x_obj-group.obj-code   = buf1_clients.obj-code
            x_obj-group.obj-type   = buf1_clients.obj-type
            x_obj-group.obj-name   = buf1_clients.obj-name
            x_obj-group.db-num     = buf1_clients.db-num
          .
      end.
    end.
end.

end.
end procedure. /* metod-gop-obj */

/* Найти все группы куда входит объект */
procedure metod-obj-in-gop :
define input  parameter p-curr-db-num as integer   no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define buffer buf_grp-obj-price for ub.grp-obj-price  .
  do
  on error undo, return error return-value
  :
    empty temp-table x_grp-obj-price.

    for each buf_grp-obj-price where
             buf_grp-obj-price.stts = {&bef-current-status-int}
             no-lock :
               run metod-gop-obj (p-curr-db-num , buf_grp-obj-price.gop-id ,buf_grp-obj-price.gop-db-num) .
               for each x_obj-group where
                        x_obj-group.obj-type = p-obj-type and
                        x_obj-group.obj-code = p-obj-code :
                    create  x_grp-obj-price.
                    buffer-copy buf_grp-obj-price to x_grp-obj-price .
               end.
    end.
  end.

end procedure. /* metod-obj-in-gop */

procedure metod-delobj-usr :
/* Уберем исключения пользователя */
define input  parameter p-pdf-id  as integer   no-undo .
define input  parameter p-pdf-db  as integer   no-undo .
define input  parameter p-plt-id  as integer   no-undo .
define input  parameter p-plt-db-num as integer   no-undo .
define buffer buf_price-doc-forming-attr for ub.price-doc-forming-attr  .

  do
  on error undo, return error return-value
  :
for each buf_price-doc-forming-attr no-lock  where
         buf_price-doc-forming-attr.pdf-id =     p-pdf-id and
         buf_price-doc-forming-attr.pdf-db =     p-pdf-db and
         buf_price-doc-forming-attr.plt-id =     p-plt-id and
         buf_price-doc-forming-attr.plt-db-num = p-plt-db-num and
         buf_price-doc-forming-attr.attr-code begins "obj" :
   for each x_obj-group  where
            x_obj-group.obj-type = substring(buf_price-doc-forming-attr.attr-code,4,3) and
            x_obj-group.obj-code = int(substring(buf_price-doc-forming-attr.attr-code,7,20)) :
     delete x_obj-group.
   end.
end.

  if not can-find (first x_obj-group) then do:
     /* todo  вставить в log */
     return "nullobj" .
  end.

end.

end procedure. /* metod-delobj-usr */


procedure metod-obj-pdf :
define input  parameter p-cntxt-db-num as integer   no-undo . /* Текущая БД */
define input  parameter p-pdf-id     like ub.price-doc-forming.pdf-id   no-undo .
define input  parameter p-pdf-db-num like ub.price-doc-forming.pdf-db   no-undo .
define input  parameter p-plt-id     like ub.price-doc-forming.plt-id   no-undo .
define input  parameter p-plt-db-num like ub.price-doc-forming.plt-db-num  no-undo .

define buffer buf_price-list-type for ub.price-list-type  .
define buffer buf_price-doc-forming for ub.price-doc-forming  .

  do
  on error undo, return error return-value
  :


 for each  x_obj-group : delete x_obj-group. end.
 find first buf_price-list-type no-lock where
            buf_price-list-type.plt-id = p-plt-id and
            buf_price-list-type.plt-db-num = p-plt-db-num no-error .
if error-status :error then return error return-value .

 find first buf_price-doc-forming no-lock where
            buf_price-doc-forming.plt-id     = p-plt-id and
            buf_price-doc-forming.plt-db-num = p-plt-db-num and
            buf_price-doc-forming.pdf-id     = p-pdf-id and
            buf_price-doc-forming.pdf-db     = p-pdf-db-num

            no-error .
if error-status :error then return error return-value .

  run metod-gop-obj in this-procedure (
      p-cntxt-db-num,
      buf_price-list-type.gop-id ,
      buf_price-list-type.gop-db-num
      ) no-error .
/* Уберем исключения пользователя */
  run metod-delobj-usr in this-procedure (
    buf_price-doc-forming.pdf-id ,
    buf_price-doc-forming.pdf-db ,
    buf_price-doc-forming.plt-id ,
    buf_price-doc-forming.plt-db-num
    ) no-error .

  end.

end procedure. /* metod-obj-pdf */