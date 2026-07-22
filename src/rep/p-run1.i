/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

ПРОЦЕДУРА foreach для поставшиков   объекты раздельно

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Дата создания: 08/16/01
*/
       For each obj-list no-lock :
          &if "{&page-object}" = "yes" &then
          find first sheetf where entry(3, sheetf.colformat, {&delim-par})  = obj-list.obj-name no-error.
          if available sheetf then do:
            run rep/extitle.p ( input sheetf.sheet-num ).
            assign
            Sheetf.Bas-Params = obj-list.obj-name
            .
          end.
          &endif
         for each temp-t-post-stk-line : delete temp-t-post-stk-line. end.
         if t#kol-rec-obj > 1 THEN run print-header (1, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
          /* выборка товаров  из архива в тт */
          For each post-stk-line  no-lock where
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
                   if not available  temp-t-post-stk-line then do:
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
          For each temp-t-post-stk-line no-lock   ,
                 Last temp-post-stk-line  where
                      temp-post-stk-line.fact-order <= fact-order-2   and
                      temp-post-stk-line.cat-id     =  t#cat-id      and
                      temp-post-stk-line.Sum-type   =  t#sum-type    and
                      temp-post-stk-line.artic      =  temp-t-post-stk-line.artic       and
                      temp-post-stk-line.prod-type  =  temp-t-post-stk-line.prod-type   and
                      temp-post-stk-line.prod-code  =  temp-t-post-stk-line.prod-code   and
                      temp-post-stk-line.obj-type   =  temp-t-post-stk-line.obj-type    and
                      temp-post-stk-line.obj-code   =  temp-t-post-stk-line.obj-code and
                      temp-post-stk-line.cli-type   =  temp-t-post-stk-line.cli-type  and
                      temp-post-stk-line.cli-code   =  temp-t-post-stk-line.cli-code
                      no-lock
                      on error undo , next
                      break
                      &if  "{&b1}" <> "1"   &then BY
                          &if  "{&b1}" = "{&lavel-goods-grp-name}"
                          &then temp-t-post-stk-line.goods-grp-name &endif
                          &if  "{&b1}" = "{&lavel-clients-grp-name}"
                          &then temp-t-post-stk-line.clients-grp-name  &endif
                          &if  "{&b1}" <> "{&lavel-goods-grp-name}"   and
                               "{&b1}" <> "{&lavel-clients-grp-name}"
                          &then {&b1} &endif
                      &endif
                      &if  "{&b2}" <> "1"   &then By {&b2} &endif
                      By ({&id-clients})
                      &if  "{&b3}" <> ""   &then By {&b3} &endif
                      By ({&id-goods})
                      By Temp-t-post-stk-line.Fact-order
                     :

               &if  "{&b1}" <> "1" and  "{&b1}" <> "{&lavel-goods-grp-name}" and "{&b1}" <> "{&lavel-clients-grp-name}"
                   &then   if first-of(  {&b1}  )  Then DO : run print-header (1, {&b1} ). end.   &endif
               &if  "{&b1}" = "{&lavel-goods-grp-name}" OR "{&b1}" = "{&lavel-clients-grp-name}"   &then
                      if old-name <> {&b1}
                                Then DO :
                                if old-n = false then DO: run print-footer (1, old-name ). old-n = true . end.
                                run print-header (1, {&b1} ). old-n = false. end.
                                Assign old-name = {&b1}  .
                                                      &endif

               &if  "{&b2}" <> "1"   &then     if first-of( {&b2}  )  Then DO : run print-header (2, {&b2} ). end.  &endif

              if NOT(Sums-Only = true ) then DO:
                  if first-of( {&id-clients} ) Then DO : run print-header ( 3,temp-t-post-stk-line.clients-obj-name). end.
              End.
                                    if first-of( {&id-goods} ) then do : run goods-start. end .
                                    if last-of ( {&id-goods} ) then do : run goods-end.
                                         run display-line .
                                    End.
                  if last-of( {&id-clients} ) Then DO : run print-footer ( 3 , temp-t-post-stk-line.clients-obj-name). end.
              &if  "{&b2}" <> "1"   &then     if last-of( {&b2} )  Then DO : run print-footer ( 2 ,{&b2}). end. &endif
              &if "{&b1}" <> "1" and  "{&b1}" <> "{&lavel-goods-grp-name}" and "{&b1}" <> "{&lavel-clients-grp-name}"
                &then   if last-of( {&b1} )  then do : run print-footer ( 1, {&b1} ). end.   &endif
          End. /* For each post-stk-line */
         if t#kol-rec-obj > 1 THEN run print-footer ( 0, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
        &if "{&page-object}" = "yes" &then
        {&pageexcel}
        &endif.
       End. /* For each obj-list */

 &if  "{&b1}" = "{&lavel-goods-grp-name}" OR "{&b1}" = "{&lavel-clients-grp-name}"   &then    run print-footer ( 1, old-name ).  &endif
 /* $Workfile$ e n d */