/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

оборотка

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 04/19/02 5:50

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{3}"  = "6"  &then
/* *** */
if x-selectobject = "currency":u  or  xtog-obj then do :
define variable first-l{&vssseq} as logical   no-undo .
  first-l{&vssseq} = true .

      for  each gds-obj where
                gds-obj.obj-code   = x-store-code and
                gds-obj.obj-type   = x-store-type
                {&ver-last-doc}
                no-lock ,
      first  tmp#grp  where gds-obj.grp-name   begins tmp#grp.grp-name   no-lock ,
      first {4}       where gds-obj.gds-code   = {4}.gds-code  no-lock
      break by func-vat (input gds-obj.gds-code , input x-store-type, input x-store-code)
            by ({5})
            :
      var-vat-pc = func-vat ( input gds-obj.gds-code, input x-store-type, input x-store-code) .
      if last-vat <> var-vat-pc then do:
          if not first-l{&vssseq} then do:
            Assign
                s-bar-code    = ""
                gds-zap-artic = "        Итого по "
                gds-zap-gds-name = b1-name
                .
              run display-b1.
              run clear-b1  .
          end.
          Assign
            first-l{&vssseq} = false
            break_group = true
            break_group1 = true
            .
          end.
      first-l{&vssseq} = false .
      run item-goods ( "{3}" , "{4}" ) .
      last-vat = func-vat (input gds-obj.gds-code , input x-store-type, input x-store-code) .
   end.
    Assign
        s-bar-code   = ""
        gds-zap-artic = "        Итого по "
        gds-zap-gds-name = b1-name
        .
      run display-b1.
      run clear-b1.
end.
else do:
   for each obj-list no-lock :
            for each gds-obj where
                gds-obj.obj-type = obj-list.obj-type    and
                gds-obj.obj-code = obj-list.obj-code
                {&ver-last-doc}
                 no-lock ,
              first  tmp#grp  where gds-obj.grp-name   begins tmp#grp.grp-name   no-lock ,
              first {4}       where gds-obj.gds-code   = {4}.gds-code  no-lock :
                  if not can-find(first temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) then do:
                              create temp-gds-list.
                                { gbl/pftxvalg.i
                                gds-obj.gds-code
                                {&vat-tax-code}
                                ?
                                v-cntxt-host-code-obj
                                gds-obj.obj-type
                                gds-obj.obj-code
                                var-vat-pc
                                no-error }
                              assign
                                temp-gds-list.prod-code = gds-obj.prod-code
                                temp-gds-list.grp-name  = gds-obj.grp-name
                                temp-gds-list.gds-name  = {4}.gds-name
                                temp-gds-list.gds-code  = gds-obj.gds-code
                                temp-gds-list.artic     = gds-obj.artic
                                temp-gds-list.vat-pc    = var-vat-pc
                              .
                  end.
            end.
  end.

  for each temp-gds-list no-lock
    &if "{4}" = "goods":u  &then     , first goods     where goods.gds-code  = temp-gds-list.gds-code no-lock   &endif
    &if "{4}" = "gds-list":u  &then  , first gds-list  where gds-list.gds-code  = temp-gds-list.gds-code no-lock  &endif
      break by {2}  by {5} :
    run item-goods ( "{3}" , "{4}" ) .
      if return-value <> "" then next.
      { rep/o-item2.i "{1}" "{2}" {3} {4} {5} }
  end.
end.
 /* * ************************************************************************************************ */
&else

  if x-selectobject = "currency":u  or  xtog-obj then do:
      for  each gds-obj
                  where gds-obj.obj-code   = x-store-code
                   and  gds-obj.obj-type   = x-store-type
                        {&ver-last-doc}
                        no-lock ,
              first  tmp#grp  where gds-obj.grp-name   begins tmp#grp.grp-name   no-lock ,
              first {4}       where gds-obj.gds-code   = {4}.gds-code  no-lock
          &if ("{1}" begins "(clients":u)  or ("{2}" begins "(clients":u)  &then
          , first clients  where  clients.obj-code = gds-obj.prod-code and
                                  clients.obj-type = gds-obj.prod-type no-lock
          &endif
                  break
                  &if "{1}" <> "1"  &then by {1}  &endif
                  &if "{2}" <> "1"  &then by {2}  &endif
                  by {5} :
                  run item-goods ( input "{3}" , input "{4}" ) .
                  if return-value <> "" then next.
                  { rep/o-item2.i "{1}" "{2}" {3} {4}  {5}}
      end.
  end.
  else do:
   /*--------------------------------------------------------------------------------------------------*/
      for each obj-list no-lock :
            for  each gds-obj
              where  gds-obj.obj-code   = obj-list.obj-code
                and  gds-obj.obj-type   = obj-list.obj-type
                     {&ver-last-doc}
              no-lock ,
              first  tmp#grp  where gds-obj.grp-name   begins tmp#grp.grp-name   no-lock ,
              first {4}       where gds-obj.gds-code   = {4}.gds-code  no-lock :
                    if not can-find(first temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) then do:
                        create temp-gds-list.
                        assign
                          temp-gds-list.prod-code = gds-obj.prod-code
                          temp-gds-list.grp-name  = gds-obj.grp-name
                          temp-gds-list.gds-name  = {4}.grp-name
                          temp-gds-list.gds-code  = gds-obj.gds-code
                          temp-gds-list.artic     = gds-obj.artic
                        .
                    end.
            end.
    end.
  for each temp-gds-list no-lock
    &if "{4}" = "goods":u  &then     , first goods  where goods.gds-code  = temp-gds-list.gds-code no-lock   &endif
    &if "{4}" = "gds-list":u  &then  , first gds-list  where gds-list.gds-code  = temp-gds-list.gds-code no-lock  &endif
          &if ("{1}" begins "(clients":u)  or ("{2}" begins "(clients":u)  &then
                                    ,  first clients   where  clients.obj-code = {4}.prod-code and
                                                              clients.obj-type = {4}.prod-type no-lock

          &endif

      break
        &if "{1}" <> "1"  &then by {1}  &endif
        &if "{2}" <> "1"  &then by {2}  &endif
    by {5} :
    run item-goods ( "{3}" , "{4}" ) .
      if return-value <> "" then next.
      { rep/o-item2.i "{1}" "{2}" {3} {4} {5} }
  end.
end.
&endif
/* $Workfile$ e n d */