/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

ПРОЦЕДУРА foreach для поставшиков   объекты слитно

Автор: Чернова Светлана Александровна
Дата создания: 08/16/01
Author: Svetlana Chernova
Creation date: 08/16/01

*/
       for each obj-list no-lock :
          for each temp-t-post-stk-line : delete temp-t-post-stk-line. end.
          for each post-stk-line  no-lock where
                  post-stk-line.obj-type = obj-list.obj-type and
                  post-stk-line.obj-code = obj-list.obj-code and
                  post-stk-line.fact-order >= null-fact-order   and
                  post-stk-line.fact-order <= fact-order-2   and
                  post-stk-line.sum-type    = {&arh-cost}    and
                  post-stk-line.cat-id      = {&single-cat-id}
                  {&f3}
                  {&p1}
                  &if not ( "{&f2}" = "" and  "{&f45}" = "")  &then
                  ,
                 each ub.goods no-lock where
                      ub.goods.artic     = post-stk-line.artic     and
                      ub.goods.prod-type = post-stk-line.prod-type and
                      ub.goods.prod-code = post-stk-line.prod-code {&f2} {&f45}
                      &endif
                      :


                 find first  temp-t-post-stk-line where
                   temp-t-post-stk-line.cli-type  = post-stk-line.cli-type  and
                   temp-t-post-stk-line.cli-code  = post-stk-line.cli-code   and
                   temp-t-post-stk-line.artic     = post-stk-line.artic     and
                   temp-t-post-stk-line.prod-type = post-stk-line.prod-type and
                   temp-t-post-stk-line.prod-code = post-stk-line.prod-code no-lock no-error .
                   if not available temp-t-post-stk-line then do:
                  &if  ( "{&f2}" = "" and  "{&f45}" = "")  &then
                      find first  ub.goods no-lock where
                                            ub.goods.artic     = post-stk-line.artic     and
                                            ub.goods.prod-type = post-stk-line.prod-type and
                                            ub.goods.prod-code = post-stk-line.prod-code no-error .   &endif

                      find first  prod-cli no-lock  where
                                                prod-cli.obj-type = post-stk-line.prod-type and
                                                prod-cli.obj-code = post-stk-line.prod-code
                                                no-error .
                      find first  ub.clients  no-lock  where
                                                ub.clients.obj-type = post-stk-line.cli-type and
                                                ub.clients.obj-code = post-stk-line.cli-code no-error .
                        run create-temp-t-post-stk-line .
                 end.
                 else do:
                         assign
                           temp-t-post-stk-line.fact-order = post-stk-line.fact-order  .
                         .
                 end.
          end.
          /* подтягивание остатков и сумм и печать */
          for each temp-t-post-stk-line no-lock   ,
                 last temp-post-stk-line  where
                                            temp-post-stk-line.fact-order <=  fact-order-2 and
                                            temp-post-stk-line.cat-id     =  t#cat-id                         and
                                            temp-post-stk-line.sum-type   =  t#sum-type                       and
                                            temp-post-stk-line.artic      =  temp-t-post-stk-line.artic       and
                                            temp-post-stk-line.prod-type  =  temp-t-post-stk-line.prod-type   and
                                            temp-post-stk-line.prod-code  =  temp-t-post-stk-line.prod-code   and
                                            temp-post-stk-line.obj-type   =  temp-t-post-stk-line.obj-type    and
                                            temp-post-stk-line.obj-code   =  temp-t-post-stk-line.obj-code    and
                                            temp-post-stk-line.cli-type   =  temp-t-post-stk-line.cli-type    and
                                            temp-post-stk-line.cli-code   =  temp-t-post-stk-line.cli-code
                                            no-lock
                                            break
                                            by ({&id-clients})
                                            by ({&id-goods})
                                            by temp-t-post-stk-line.fact-order :
                                    if first-of( {&id-goods} ) then do : run goods-start. end .
                                    if last-of ( {&id-goods} ) then do : run goods-end.
                                       run display-line .
                                    end.
                                    if last-of( {&id-clients} ) then do :
                                       run tmp-create (temp-t-post-stk-line.cli-code,
                                                       temp-t-post-stk-line.cli-type,
                                                       temp-t-post-stk-line.clients-obj-name,
                                                       obj-list.obj-code,
                                                       obj-list.obj-type ) .
                                       run tmp-clear.
                                    end.
          end.  /* for each  post-stk-line */
       end. /* for each obj-list*/


       for each tmp-cli-gds no-lock
           break
           by tmp-cli-gds.name
           by (tmp-cli-gds.cli-type + string(tmp-cli-gds.cli-code)) :
           if first-of(tmp-cli-gds.cli-type + string(tmp-cli-gds.cli-code)) then run tmp-clear.

            run tmp-assign.
           if last-of((tmp-cli-gds.cli-type + string(tmp-cli-gds.cli-code))) then do:
               run print-footer ( 3 ,tmp-cli-gds.name).
           end.

       end.
 /* $Workfile$ e n d */