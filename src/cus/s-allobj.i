/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Если радиобаттон по ваыборке объекты стоит на ВСЕ

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 08/30/02 2:26

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

 /* SelectObject */
 &if "{1}" <>  "no-initial"  &then
 if not (temp-param-obj = '*'
    or lookup(string({&o-all}),temp-param-obj) > 0
    or lookup(string({&o-firm}),temp-param-obj) > 0  ) then do:
 message "Выполнить невозможно, смените текущий объект !" view-as alert-box error .
 return error.
 end.
&endif

  for each obj-list :  delete obj-list.  end.
  assign
    str-obj#  = ''
    str-obj2# = ''
    str-obj3# = ''.

  define buffer buf_user-obj for ub.user-obj .

  for each buf_user-obj no-lock
    where buf_user-obj.db-num  = v-cntxt-db-num
      and buf_user-obj.user-id = v-cntxt-userid
  ,each cli-obj no-lock
    where cli-obj.obj-type = buf_user-obj.obj-type
      and cli-obj.obj-code = buf_user-obj.obj-code
      and ( ( cli-obj.db-num = g#db-num ) or g#db-num = 0 )
  :

          find first ub.clients no-lock
            where ub.clients.obj-type = buf_user-obj.obj-type
              and ub.clients.obj-code = buf_user-obj.obj-code
            no-error .
          if verify-send-check  and ub.clients.db-num <> g#db-num  then do:
             find first ub.db where ub.db.db-num = ub.clients.db-num no-lock.
             if ub.db.send-check = false
             then do:
               assign
                 str-obj2# = str-obj2#  + " " + ub.clients.obj-name + ","
               .
               next.
             end.
          end.

          if temp-param-obj-type = 'shop':u
          then do:
            if buf_user-obj.obj-type = {&stock}
            then do:
              assign
                str-obj# = str-obj#  +  " " + ub.clients.obj-name + ","
              .
              next.
            end.
          end.

          if temp-param-obj-type = 'stock':u
          then do:
            if buf_user-obj.obj-type = {&shop} then do:
              assign
                str-obj# = str-obj#  +  " " +  ub.clients.obj-name + ","
              .
              next.
            end.
          end.

                case buf_user-obj.obj-type
                :
                    when {&stock} then
                        do:
                            find ub.store where ub.store.obj-code = buf_user-obj.obj-code no-lock.
                            if selectobject = {&obj-firm} then do:
                              if ub.store.host-code <> g#host-code then do:
                                  str-obj3# = str-obj3#  + " " + ub.clients.obj-name + ",".
                                  next.
                                  end.
                            end.

                            find first ub.sysconf no-lock where ub.sysconf.host-code = ub.store.host-code no-error.
                            find first ub.clients no-lock
                              where ub.clients.obj-type = buf_user-obj.obj-type
                                and ub.clients.obj-code = buf_user-obj.obj-code
                              no-error .

                            if ub.sysconf.base-code = base-code then
                                do:
                                    { cmp/cr-objls.i buf_user-obj.obj-type buf_user-obj.obj-code }
                                end.
                                else str-obj# = str-obj#  +  " " +   ub.clients.obj-name + "," .

                        end.
                    when {&shop} then
                        do:
                            find ub.shop where ub.shop.obj-code = buf_user-obj.obj-code no-lock.
                            if selectobject = {&obj-firm} then do:
                              if ub.shop.host-code <> g#host-code then do:
                                  str-obj3# = str-obj3#  + " " + ub.clients.obj-name + ",".
                                  next.
                                  end.
                            end.
                            find first ub.sysconf no-lock where ub.sysconf.host-code = ub.shop.host-code no-error.
                            find first ub.clients no-lock where
                                        ub.clients.obj-type = buf_user-obj.obj-type and
                                        ub.clients.obj-code = buf_user-obj.obj-code no-error.

                            if ub.sysconf.base-code = base-code
                            then do:
                                  { cmp/cr-objls.i buf_user-obj.obj-type buf_user-obj.obj-code }
                            end.
                            else do:
                              assign
                                str-obj# = str-obj#  +  " " +  ub.clients.obj-name +  ","
                              .
                            end.
                        end.
                end case.

  end.
/* $Workfile$ e n d */