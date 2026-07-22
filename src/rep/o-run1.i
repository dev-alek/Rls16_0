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

Дата создания: 08/15/01

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&if "{3}"  = "6"  &then
/* *** */
IF x-SelectObject = "currency":U  OR  xTog-obj then do :
define variable first-l{&vssseq} as logical   no-undo .
  first-l{&vssseq} = true .
  for each gds-obj
    where gds-obj.obj-type = x-store-type
      and gds-obj.obj-code = x-store-code
          {&ver-last-doc}
          no-lock,
      first goods  where  goods.gds-code = gds-obj.gds-code
      &if "{4}" = "gds-list":U  &then
      no-lock,
      First gds-list  where gds-list.gds-code =  gds-obj.gds-code
      &endif
      no-lock
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
   For each obj-list no-lock :
                  FOR EACH gds-obj where
                      gds-obj.obj-type = obj-list.obj-type    and
                      gds-obj.obj-code = obj-list.obj-code
                      {&ver-last-doc}
                &if "{4}" = "gds-list":U  &then
                      no-lock,
                First gds-list  where gds-obj.gds-code  = gds-list.gds-code
                      &endif
                      no-lock :
                      find first temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code no-error .
                      if not available temp-gds-list then do:
                          find first goods no-lock  where goods.gds-code  = gds-obj.gds-code .
                          Create temp-gds-list.
                            { gbl/pftxvalg.i
                            gds-obj.gds-code
                            {&vat-tax-code}
                            ?
                            v-cntxt-host-code-obj
                            gds-obj.obj-type
                            gds-obj.obj-code
                            var-vat-pc
                            no-error }
                          Assign
                            temp-gds-list.prod-code = gds-obj.prod-code
                            temp-gds-list.grp-name  = gds-obj.grp-name
                            temp-gds-list.gds-name  = goods.gds-name
                            temp-gds-list.gds-code  = gds-obj.gds-code
                            temp-gds-list.artic     = gds-obj.artic
                            temp-gds-list.vat-pc    = var-vat-pc
                          .
                      End.
                      else do:
                      if temp-gds-list.vat-pc = 0 or temp-gds-list.vat-pc = ? then do:
                            { gbl/pftxvalg.i
                            gds-obj.gds-code
                            {&vat-tax-code}
                            ?
                            v-cntxt-host-code-obj
                            gds-obj.obj-type
                            gds-obj.obj-code
                            var-vat-pc
                            no-error }
                            Assign
                              temp-gds-list.vat-pc    = var-vat-pc
                            .
                      end.
                      end.
            End.
  End.
  for each temp-gds-list no-lock
    &if "{4}" = "goods":U  &then     , First goods     where goods.gds-code  = temp-gds-list.gds-code no-lock   &endif
    &if "{4}" = "gds-list":U  &then  , First gds-list  where gds-list.gds-code  = temp-gds-list.gds-code no-lock  &endif
      BREAK BY {2}  BY {5} :
    run item-goods ( "{3}" , "{4}" ) .
      if return-value <> "" then NEXT.
      { rep/o-item2.i "{1}" "{2}" {3} {4} {5} }
  End.
End.
 /* * ************************************************************************************************ */
&else
IF x-SelectObject = "currency":U  OR  xTog-obj THEN DO :

    for each gds-obj  where
          gds-obj.obj-type = x-store-type  and
          gds-obj.obj-code = x-store-code
          {&ver-last-doc}
&if  INDEX("{1}", "clients":U) > 0  OR INDEX("{2}", "clients":U) > 0 &then
      no-lock,
First clients  where  clients.obj-code = gds-obj.prod-code and
                      clients.obj-type = gds-obj.prod-type
&endif
                no-lock,
          First goods  where  gds-obj.gds-code   = goods.gds-code
&if "{4}" = "gds-list":U  &then
      no-lock,
First gds-list  where gds-obj.gds-code  = gds-list.gds-code
&endif
no-lock
BREAK &If "{1}" <> "1"  &then BY ({1})  &endif
      &If "{2}" <> "1"  &then BY ({2})  &endif
    BY ({5}) :
      run item-goods ( "{3}" , "{4}" ) .
      if return-value <> "" then NEXT.
      { rep/o-item2.i "{1}" "{2}" {3} {4} {5} }
    End.
  END.
  Else DO:
  /*по списку obj-list */

   For each obj-list no-lock :
                  FOR EACH gds-obj where
                gds-obj.obj-type = obj-list.obj-type    and
                gds-obj.obj-code = obj-list.obj-code
                {&ver-last-doc}
          &if "{4}" = "gds-list":U  &then
                no-lock,
          First gds-list  where gds-obj.gds-code  = gds-list.gds-code
                &endif
                no-lock :
                if NOT can-find(First temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) Then do:
                    find first goods no-lock  where goods.gds-code  = gds-obj.gds-code .
                    Create temp-gds-list.
                    Assign
                      temp-gds-list.prod-code = gds-obj.prod-code
                      temp-gds-list.grp-name  = gds-obj.grp-name
                      temp-gds-list.gds-name  = goods.gds-name
                      temp-gds-list.gds-code  = gds-obj.gds-code
                      temp-gds-list.artic     = gds-obj.artic
                    .
                End.
            End.
  End.

  for each temp-gds-list no-lock
    &if "{4}" = "goods":U  &then     , First goods     where goods.gds-code  = temp-gds-list.gds-code no-lock   &endif
    &if "{4}" = "gds-list":U  &then  , First gds-list  where gds-list.gds-code  = temp-gds-list.gds-code no-lock  &endif
    &if  INDEX("{1}", "clients":U) > 0 OR INDEX("{2}", "clients":U) > 0 &then
                                     , First clients   where  clients.obj-code = {4}.prod-code and
                                                              clients.obj-type = {4}.prod-type &endif
      BREAK
&If "{1}" <> "1"  &then BY {1}  &endif
&If "{2}" <> "1"  &then BY ({2})  &endif
    BY {5} :
    run item-goods ( "{3}" , "{4}" ) .
      if return-value <> "" then NEXT.
      { rep/o-item2.i "{1}" "{2}" {3} {4} {5} }
  End.
End.
&endif
/* $Workfile$ e n d */