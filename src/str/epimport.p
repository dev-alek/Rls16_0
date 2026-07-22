block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: epimport.p $
$Archive: str/epimport.p $

Создание Возврата поставщику, списания и внутреннего расхода  по списку партий

Автор: Чернова Светлана Александровна
Дата создания: 12/02/09
Author: Svetlana Chernova
Creation date: 12/02/09


*/

define input  parameter parparentproc as widget-handle no-undo.
define input  parameter p-handle      as handle no-undo .
define input  parameter p-ext-doc-type as character no-undo .
DEFINE TEMP-TABLE x_parts NO-UNDO LIKE ub.parts.
define input parameter table for x_parts .



define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: epimport.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/epimport.p $":U .
define variable vss-description as character no-undo init "Создание Возврата поставщику, списания и внутреннего расхода  по списку партий".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ str/doc-code.i }
{ gbl/waitfram.i }
{ cmp/croslist.i }
{ gbl/clntattr.i }
{ cmp/strcodec.i }
{ str/lib-def.i  }
{ str/lib-calc.i }
{ str/getctxtp.i def }
{ str/getctxtp.i get }
{ cus/copyinqu.i }

define buffer buf_parts for x_parts  .
define temp-table temp-cli no-undo like ub.clients .
define temp-table temp-vat no-undo
  field vat-type as character
  index pi vat-type
.

define temp-table tt2-doc-line      no-undo like lib-trn_ret-line.
define variable i as integer   no-undo .
define variable i-err as integer   no-undo .
define variable v-spis as character no-undo .
define variable v-trn-doc as character no-undo .
define buffer buf_trn-doc for ub.trn-doc  .
define buffer new_trn-doc for ub.trn-doc  .

define variable v-cntxt-cash-pay as integer   no-undo .
define variable v-cntxt-base-code as integer   no-undo .
define variable v-curr-r-b as character no-undo .
define variable v-ext-doc-type as character no-undo .
define variable v-doc-type as character no-undo .
define variable v-discnt-type as character no-undo .
define variable v-ret-supp     as logical   no-undo .
define variable v-internal as logical   no-undo .
define variable v-cli-type as character no-undo .
define variable v-cli-code as integer   no-undo .
define variable v-cli-name as character no-undo .
define variable v-b-code as integer   no-undo .

if p-ext-doc-type = {&TDEDT_Ras_Perem}
 then do:
  run cb_choice-obj in p-handle (
        output v-cli-type ,
        output v-cli-code ,
        output v-cli-name  )
        no-error .
        if error-status :error then do:
            message
            return-value
            error-status :get-message(1)
            view-as alert-box error .
           return .
        end.
  end.

case p-ext-doc-type:
when  {&TDEDT_Ras_Vnesh_VP}  then do:
   assign
      v-ext-doc-type = p-ext-doc-type
      v-doc-type     = {&expense}
      v-discnt-type  = {&percent}
      v-ret-supp     = true
      v-internal     = false
   .
end.
when  {&TDEDT_Ras_Perem}  then do:
   assign
      v-ext-doc-type = p-ext-doc-type
      v-doc-type     = {&expense}
      v-discnt-type  = {&percent}
      v-ret-supp     = false
      v-internal     = true
   .
end.
when  {&TDEDT_Pri_Perem}  then do:
   assign
      v-ext-doc-type = p-ext-doc-type
      v-doc-type     = {&income}
      v-discnt-type  = {&percent}
      v-ret-supp     = false
      v-internal     = true
   .
end.


when  {&TDEDT_Spi_Vnesh}  then do:
   assign
      v-ext-doc-type = p-ext-doc-type
      v-doc-type     = {&write-off}
      v-discnt-type  = {&percent}
      v-ret-supp     = false
      v-internal     = false
   .
end.

otherwise do:
  message "Не верный расширенный тип"  p-ext-doc-type  view-as alert-box information .
end.
end case.

run create-tt in this-procedure .
i = 0 .
i-err = 0 .
v-spis = "" .

if p-ext-doc-type = {&TDEDT_Ras_Perem}  then do:
 for each temp-vat :
    i = i + 1 .
    run create-trn-2 in this-procedure (input  temp-vat.vat-type, output v-trn-doc ) no-error .
    find first buf_trn-doc no-lock where
               buf_trn-doc.doc-code = v-trn-doc no-error .
        if not available buf_trn-doc then do:
           i-err = i-err + 1 .
        end.
        else do:
           v-spis =  v-spis + buf_trn-doc.doc-code + ",".
        end.
 end.
end.
else do:
for each temp-cli :
 for each temp-vat :
    i = i + 1 .
    run create-trn in this-procedure (temp-cli.obj-type,temp-cli.obj-code, temp-vat.vat-type, output v-trn-doc ) no-error .
    find first buf_trn-doc no-lock where
               buf_trn-doc.doc-code = v-trn-doc no-error .
        if not available buf_trn-doc then do:
           i-err = i-err + 1 .
        end.
        else do:
           v-spis =  v-spis + buf_trn-doc.doc-code + ",".
        end.
 end.
 end.
end.
return substitute("Создано &1 , Ошибок &2 , Накладные: &3" , i, i-err , v-spis ) .
/*-----------------------------------------------------------------------------------------------------------------------*/

procedure clear-tt :

  do
  on error undo, return error return-value
  :
   for each tt-trn-doc:
    delete tt-trn-doc.
   end.

    for each tt2-doc-line :
        delete tt2-doc-line .
    end.
    for each tt-doc-line :
        delete tt-doc-line .
    end.
    for each tt-gds-dtl :
        delete tt-gds-dtl .
    end.
    for each tt-parts:
        delete tt-parts .
    end.
    for each lib-trn_ret-doc :
      delete lib-trn_ret-doc.
    end.
    for each lib-trn_ret-line :
      delete lib-trn_ret-line      .
    end.
    for each lib-trn_ret-line-attr :
      delete lib-trn_ret-line.
    end.
    for each lib-trn_ret-dtl :
      delete lib-trn_ret-dtl.
    end.
    for each lib-trn_ret-parts :
      delete lib-trn_ret-parts .
    end.

 end.
end procedure. /* clear-tt */

procedure create-tt :
define buffer buf_clients for ub.clients  .
  do
  on error undo, return error return-value
  :
if p-ext-doc-type = {&TDEDT_Pri_Perem} then do:
for each x_parts where
     not (x_parts.obj-type = v-cntxt-obj-type and
         x_parts.obj-code = v-cntxt-obj-code )
                 break by x_parts.obj-type
                       by x_parts.obj-code
                      :
   if first-of ( x_parts.obj-code ) then do:
      find first buf_clients no-lock where
                 buf_clients.db-num    <> ? and
                 buf_clients.obj-type  = x_parts.obj-type and
                 buf_clients.obj-code  = x_parts.obj-code no-error .
      if available buf_clients then do:
          create temp-cli.
          buffer-copy buf_clients to temp-cli.
      end.
   end.
end.

end.
else do:
for each x_parts break by x_parts.supp-type
                       by x_parts.supp-code
                      :
   if first-of ( x_parts.supp-code ) then do:
      find first buf_clients no-lock where
                 buf_clients.db-num    = ? and
                 buf_clients.obj-type  = x_parts.supp-type and
                 buf_clients.obj-code  = x_parts.supp-code no-error .
      if available buf_clients then do:
          create temp-cli.
          buffer-copy buf_clients to temp-cli.
      end.
   end.
end.
end.

for each x_parts
    break by x_parts.vat-type
    :
   if first-of ( x_parts.vat-type) then do:
      create temp-vat.
       assign
          temp-vat.vat-type = x_parts.vat-type
          .
   end.
end.


  end.

end procedure. /* create-tt */


procedure create-trn :
define input  parameter p-cli-type as character no-undo .
define input  parameter p-cli-code as integer   no-undo .
define input  parameter p-vat-type as character no-undo .
define output parameter v-num-doc as character no-undo .

define buffer buf_sysconf for ub.sysconf  .
define buffer buf_clients for ub.clients  .

define variable  v-fact-qnty  as decimal   no-undo .
define variable  v-cli-qnty   as decimal   no-undo .
define variable  v-root-node  as integer   no-undo .

  do
  on error undo, return error return-value
  :

run clear-tt.

find first buf_clients no-lock where
           buf_clients.obj-type  = p-cli-type and
           buf_clients.obj-code  = p-cli-code no-error .

find first buf_sysconf where buf_sysconf.host-code = v-cntxt-host-code-obj no-lock no-error .
if error-status :error then return error .
    v-cntxt-cash-pay  = buf_sysconf.cash-pay.
    v-cntxt-base-code = buf_sysconf.base-code.

    run doc-code in this-procedure
      ( input  "main":U         ,
        input  v-cntxt-obj-type ,
        input  v-cntxt-obj-code ,
        input  ?                ,
        output v-num-doc ) no-error .
    create tt-trn-doc.
    assign
      tt-trn-doc.cli-code      = buf_clients.obj-code
      tt-trn-doc.cli-type      = buf_clients.obj-type
      tt-trn-doc.cli-name      = buf_clients.obj-name
      tt-trn-doc.cr-db-num     = v-cntxt-db-num
      tt-trn-doc.creid         = v-cntxt-userid
      tt-trn-doc.discnt-type   = v-discnt-type
      tt-trn-doc.doc-code      = v-num-doc
      tt-trn-doc.office        = false
      tt-trn-doc.pay-code      = v-cntxp-out-pay
      tt-trn-doc.doc-date      = today
      tt-trn-doc.doc-type      = v-doc-type
      tt-trn-doc.flag_         = false
      tt-trn-doc.internal      = v-internal
      tt-trn-doc.obj-code      = v-cntxt-obj-code
      tt-trn-doc.obj-type      = v-cntxt-obj-type
      tt-trn-doc.ps            = "ФиБ"
      tt-trn-doc.ret-supp      = v-ret-supp
      tt-trn-doc.slt-type      = {&without-slt}
      tt-trn-doc.status_       = ( if v-ext-doc-type = {&TDEDT_Pri_perem} then {&inquiry} else {&wayb} )
      tt-trn-doc.vat-type      = p-vat-type
      tt-trn-doc.ext-doc-type  = v-ext-doc-type
      tt-trn-doc.purch-code    = buf_sysconf.purch-code
    .

    { gbl/curr-r-b.i
      v-curr-r-b
    }
    if v-curr-r-b = {&r-b-base}
        then tt-trn-doc.print-rubl = false .
        else tt-trn-doc.print-rubl = true .

    { gbl/hostcode.i
      tt-trn-doc.obj-type
      tt-trn-doc.obj-code
      tt-trn-doc.host-code
      }

    { gbl/baserate.i
      tt-trn-doc.host-code
      tt-trn-doc.doc-date
      tt-trn-doc.base-rate
      tt-trn-doc.base-scale
      }

    { str/crtrndoc.i
      tt-trn-doc.acc-date
      tt-trn-doc.bge-date
      tt-trn-doc.base-rate
      tt-trn-doc.base-scale
      tt-trn-doc.cli-code
      tt-trn-doc.cli-type
      tt-trn-doc.cli-name
      tt-trn-doc.cr-db-num
      tt-trn-doc.creid
      tt-trn-doc.discnt-type
      tt-trn-doc.doc-code
      tt-trn-doc.doc-date
      tt-trn-doc.doc-type
      tt-trn-doc.flag_
      tt-trn-doc.host-code
      tt-trn-doc.internal
      tt-trn-doc.obj-code
      tt-trn-doc.obj-type
      tt-trn-doc.office
      tt-trn-doc.pay-code
      tt-trn-doc.ps
      tt-trn-doc.ret-supp
      tt-trn-doc.slt-type
      tt-trn-doc.status_
      tt-trn-doc.vat-type
      tt-trn-doc.ext-doc-type
      tt-trn-doc.purch-code
      no-error }
      .
     if error-status :error then message
       vss-workfile vss-revision vss-description skip
       error-status :get-message(1) skip
       return-value skip
       ""
       view-as alert-box error
     .
     if p-ext-doc-type = {&TDEDT_Pri_Perem} then do:
        for each buf_parts where
                  buf_parts.obj-code  = p-cli-code and
                  buf_parts.obj-type  = p-cli-type and
                  buf_parts.vat-type  = p-vat-type :
          create tt-parts.
          buffer-copy buf_parts to tt-parts
          assign
            tt-parts.out-code = v-num-doc
            tt-parts.obj-type = tt-trn-doc.obj-type
            tt-parts.obj-code = tt-trn-doc.obj-code
            tt-parts.supp-type = tt-trn-doc.cli-type
            tt-parts.supp-code = tt-trn-doc.cli-code
          .
        end.
     end.
     else do:
        for each buf_parts where
                  buf_parts.supp-code = p-cli-code and
                  buf_parts.supp-type = p-cli-type and
                  buf_parts.vat-type  = p-vat-type :
          create tt-parts.
          buffer-copy buf_parts to tt-parts
          assign
            tt-parts.out-code = v-num-doc
          .
          end.
     end.

     for each tt-parts :
         find first tt2-doc-line where
                    tt2-doc-line.doc-code  =  v-num-doc and
                    tt2-doc-line.artic     =  tt-parts.artic and
                    tt2-doc-line.prod-type =  tt-parts.prod-type and
                    tt2-doc-line.prod-code =  tt-parts.prod-code no-error .
         if not available tt2-doc-line then do:
            create tt2-doc-line.
            v-fact-qnty = 0.
            v-cli-qnty  = 0.
         end.
         else do:
            v-fact-qnty = tt2-doc-line.fact-qnty.
            v-cli-qnty  = tt2-doc-line.cli-qnty.
         end.
         buffer-copy tt-parts except status_ to tt2-doc-line
         assign
             tt2-doc-line.doc-code  = v-num-doc
             tt2-doc-line.doc-qnty   = tt-parts.fact-qnty + v-fact-qnty
             tt2-doc-line.fact-qnty  = tt-parts.fact-qnty + v-fact-qnty
             tt2-doc-line.cli-qnty   = tt-parts.cli-qnty  + v-cli-qnty
         .
         find first tt-doc-line where
                    tt-doc-line.doc-code  =  v-num-doc and
                    tt-doc-line.artic     =  tt-parts.artic and
                    tt-doc-line.prod-type =  tt-parts.prod-type and
                    tt-doc-line.prod-code =  tt-parts.prod-code no-error .
         if not available tt2-doc-line then do:
            create tt-doc-line.
         end.

     end.

     for each  tt2-doc-line where
                    tt2-doc-line.doc-code  =  v-num-doc :
         find first tt-gds-dtl where
                    tt-gds-dtl.doc-code  =  v-num-doc and
                    tt-gds-dtl.artic     =  tt2-doc-line.artic and
                    tt-gds-dtl.prod-type =  tt2-doc-line.prod-type and
                    tt-gds-dtl.prod-code =  tt2-doc-line.prod-code no-error .

         if not available tt-gds-dtl then do:
            create tt-gds-dtl.
         end.
          { gbl/rootnode.i
          tt2-doc-line.artic
          tt2-doc-line.prod-type
          tt2-doc-line.prod-code
          v-root-node
          }

         buffer-copy tt2-doc-line to tt-gds-dtl
         assign
            tt-gds-dtl.doc-code  = v-num-doc
            tt-gds-dtl.prt-code  = v-root-node
         .
     end.

/*
    for each tt2-doc-line :
        message tt2-doc-line.cli-qnty
                tt2-doc-line.fact-qnty
                tt2-doc-line.doc-qnty
                skip
                'doc-line2' skip
                tt2-doc-line.artic .
    end.
    for each tt-gds-dtl :
        message tt-gds-dtl.fact-qnty tt-gds-dtl.doc-qnty 'gds-dtl'skip  tt-gds-dtl.artic.
    end.
    for each tt-parts:
        message tt-parts.cli-qnty tt-parts.fact-qnty tt-parts.qnty tt-parts.part-code 'parts' skip tt-parts.artic
        tt-parts.out-code
        .
    end.
*/

    find first new_trn-doc where new_trn-doc.doc-code = tt-trn-doc.doc-code  exclusive-lock no-error .

    if  available new_trn-doc then do:
    assign
        new_trn-doc.print-rubl = tt-trn-doc.print-rubl
        new_trn-doc.hold-doc-code-child  = "no-hold":u
        new_trn-doc.hold-doc-code-parent = "no-hold":u
        .

      if p-ext-doc-type = {&TDEDT_Ras_Perem}  then do:
      assign
          new_trn-doc.cli-type = v-cli-type
          new_trn-doc.cli-code = v-cli-code
          new_trn-doc.cli-name = v-cli-name
          .
        end.
      end.
      if p-ext-doc-type = {&TDEDT_Pri_Perem}  then do:

      for each tt2-doc-line :
        create tt-doc-line.
        buffer-copy tt2-doc-line to tt-doc-line
        assign
          tt-doc-line.doc-code = tt-trn-doc.doc-code
        .
      end.
  { cus/copyinqu.i
    tt-trn-doc.doc-code
    tt-trn-doc.doc-type
    tt-trn-doc.status_
    tt-trn-doc.internal
    tt-trn-doc.cli-type
    tt-trn-doc.cli-code
    tt-trn-doc.discnt-type
    tt-trn-doc.tot-calc
    tt-trn-doc.discnt-pc
    tt-trn-doc.agnt
    tt-trn-doc.boss
    tt-trn-doc.wrkr
    tt-trn-doc.base-rate
    tt-trn-doc.base-scale
    tt-trn-doc.exch-code
    tt-trn-doc.vat-type
    tt-trn-doc.doc-code
    no
    tt-trn-doc.discnt-pc
    tt-trn-doc.agnt
    tt-trn-doc.boss
    tt-trn-doc.wrkr
    tt-trn-doc.base-rate
    tt-trn-doc.base-scale
    v-cntxt-cash-pay
    v-cntxt-base-code
    tt-doc-line
    tt-gds-dtl
    tt-parts
    yes
    yes
    no
    no-error }
        if not error-status :error  then do:

          for each tt-parts :
          find first ub.goods no-lock where
                     ub.goods.artic      = tt-parts.artic and
                     ub.goods.prod-type  = tt-parts.prod-type and
                     ub.goods.prod-code  = tt-parts.prod-code no-error .

          find first ub.parts no-lock where
                     ub.parts.artic      = tt-parts.artic and
                     ub.parts.prod-type  = tt-parts.prod-type and
                     ub.parts.prod-code  = tt-parts.prod-code and
                     ub.parts.part-code  = tt-parts.part-code and
                     ub.parts.in-code    = tt-parts.in-code .
          { gbl/partbcod.i
            ub.parts
            v-b-code
            no-error
          }
          if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              error-status :get-message(1) skip
              return-value skip
              ""
              view-as alert-box error
            .
          end.
          create ub.doc-prts.
          buffer-copy tt-parts to ub.doc-prts
            assign
              ub.doc-prts.out-code = tt-trn-doc.doc-code
              ub.doc-prts.b-code   = v-b-code
              ub.doc-prts.gds-code  = ub.goods.gds-code
              ub.doc-prts.defect    = logical({&FiB})
          .
         end.

      end.
      end.
      else do:

    { str/copy-ret.i
      parparentproc
      tt-trn-doc.doc-code
      tt-trn-doc.doc-type
      tt-trn-doc.status_
      tt-trn-doc.internal
      tt-trn-doc.cli-type
      tt-trn-doc.cli-code
      tt-trn-doc.discnt-type
      tt-trn-doc.tot-calc
      tt-trn-doc.discnt-pc
      tt-trn-doc.agnt
      tt-trn-doc.boss
      tt-trn-doc.wrkr
      tt-trn-doc.base-rate
      tt-trn-doc.base-scale
      tt-trn-doc.exch-code
      tt-trn-doc.vat-type
      tt-trn-doc.doc-code
      no
      tt-trn-doc.discnt-pc
      tt-trn-doc.agnt
      tt-trn-doc.boss
      tt-trn-doc.wrkr
      tt-trn-doc.base-rate
      tt-trn-doc.base-scale
      v-cntxt-cash-pay
      v-cntxt-base-code
      tt2-doc-line
      tt-gds-dtl
      tt-parts
      yes
      yes
      yes
      yes
      no-error }
      end.

   if error-status :error then message
     vss-workfile vss-revision vss-description skip
     error-status :get-message(1) skip
     return-value skip
     "str/copy-ret.i"
     view-as alert-box error
   .

   if p-ext-doc-type = {&TDEDT_Ras_Vnesh_VP}  then do:
      run str/ep-corrp.p (input parparentproc , input v-num-doc ) no-error .
   end.
   else do:
      run gbl/calc-trn.p (input parparentproc, input recid (new_trn-doc) ) no-error.
   end.

  end.

end procedure. /* create-trn */


procedure create-trn-2 :
define input  parameter p-vat-type as character no-undo .
define output parameter v-num-doc as character no-undo .

define buffer buf_sysconf for ub.sysconf  .

define variable  v-fact-qnty  as decimal   no-undo .
define variable  v-cli-qnty   as decimal   no-undo .
define variable  v-root-node  as integer   no-undo .

  do
  on error undo, return error return-value
  :

run clear-tt.


find first buf_sysconf where buf_sysconf.host-code = v-cntxt-host-code-obj no-lock no-error .
if error-status :error then return error .
    v-cntxt-cash-pay  = buf_sysconf.cash-pay.
    v-cntxt-base-code = buf_sysconf.base-code.

    run doc-code in this-procedure
      ( input  "main":U         ,
        input  v-cntxt-obj-type ,
        input  v-cntxt-obj-code ,
        input  ?                ,
        output v-num-doc ) no-error .
    create tt-trn-doc.
    assign
      tt-trn-doc.cli-code      = v-cli-code
      tt-trn-doc.cli-type      = v-cli-type
      tt-trn-doc.cli-name      = v-cli-name
      tt-trn-doc.cr-db-num     = v-cntxt-db-num
      tt-trn-doc.creid         = v-cntxt-userid
      tt-trn-doc.discnt-type   = v-discnt-type
      tt-trn-doc.doc-code      = v-num-doc
      tt-trn-doc.office        = false
      tt-trn-doc.pay-code      = v-cntxp-out-pay
      tt-trn-doc.doc-date      = today
      tt-trn-doc.doc-type      = v-doc-type
      tt-trn-doc.flag_         = false
      tt-trn-doc.internal      = v-internal
      tt-trn-doc.obj-code      = v-cntxt-obj-code
      tt-trn-doc.obj-type      = v-cntxt-obj-type
      tt-trn-doc.ps            = "ФиБ"
      tt-trn-doc.ret-supp      = v-ret-supp
      tt-trn-doc.slt-type      = {&without-slt}
      tt-trn-doc.status_       = {&wayb}
      tt-trn-doc.vat-type      = p-vat-type
      tt-trn-doc.ext-doc-type  = v-ext-doc-type
      tt-trn-doc.purch-code    = buf_sysconf.purch-code
    .

    { gbl/curr-r-b.i
      v-curr-r-b
    }
    if v-curr-r-b = {&r-b-base}
        then tt-trn-doc.print-rubl = false .
        else tt-trn-doc.print-rubl = true .

    { gbl/hostcode.i
      tt-trn-doc.obj-type
      tt-trn-doc.obj-code
      tt-trn-doc.host-code
      }

    { gbl/baserate.i
      tt-trn-doc.host-code
      tt-trn-doc.doc-date
      tt-trn-doc.base-rate
      tt-trn-doc.base-scale
      }

    { str/crtrndoc.i
      tt-trn-doc.acc-date
      tt-trn-doc.bge-date
      tt-trn-doc.base-rate
      tt-trn-doc.base-scale
      tt-trn-doc.cli-code
      tt-trn-doc.cli-type
      tt-trn-doc.cli-name
      tt-trn-doc.cr-db-num
      tt-trn-doc.creid
      tt-trn-doc.discnt-type
      tt-trn-doc.doc-code
      tt-trn-doc.doc-date
      tt-trn-doc.doc-type
      tt-trn-doc.flag_
      tt-trn-doc.host-code
      tt-trn-doc.internal
      tt-trn-doc.obj-code
      tt-trn-doc.obj-type
      tt-trn-doc.office
      tt-trn-doc.pay-code
      tt-trn-doc.ps
      tt-trn-doc.ret-supp
      tt-trn-doc.slt-type
      tt-trn-doc.status_
      tt-trn-doc.vat-type
      tt-trn-doc.ext-doc-type
      tt-trn-doc.purch-code
      no-error }
      .
     if error-status :error then message
       vss-workfile vss-revision vss-description skip
       error-status :get-message(1) skip
       return-value skip
       ""
       view-as alert-box error
     .


    for each buf_parts where
             buf_parts.vat-type  = p-vat-type :
      create tt-parts.
      buffer-copy buf_parts to tt-parts
      assign
        tt-parts.out-code = v-num-doc
      .
      end.

     for each tt-parts :
         find first tt2-doc-line where
                    tt2-doc-line.doc-code  =  v-num-doc and
                    tt2-doc-line.artic     =  tt-parts.artic and
                    tt2-doc-line.prod-type =  tt-parts.prod-type and
                    tt2-doc-line.prod-code =  tt-parts.prod-code no-error .
         if not available tt2-doc-line then do:
            create tt2-doc-line.
            v-fact-qnty = 0.
            v-cli-qnty  = 0.
         end.
         else do:
            v-fact-qnty = tt2-doc-line.fact-qnty.
            v-cli-qnty  = tt2-doc-line.cli-qnty.
         end.
         buffer-copy tt-parts except status_ to tt2-doc-line
         assign
             tt2-doc-line.doc-code  = v-num-doc
             tt2-doc-line.doc-qnty   = tt-parts.fact-qnty + v-fact-qnty
             tt2-doc-line.fact-qnty  = tt-parts.fact-qnty + v-fact-qnty
             tt2-doc-line.cli-qnty   = tt-parts.cli-qnty  + v-cli-qnty
         .
         find first tt-doc-line where
                    tt-doc-line.doc-code  =  v-num-doc and
                    tt-doc-line.artic     =  tt-parts.artic and
                    tt-doc-line.prod-type =  tt-parts.prod-type and
                    tt-doc-line.prod-code =  tt-parts.prod-code no-error .
         if not available tt2-doc-line then do:
            create tt-doc-line.
         end.

     end.

     for each  tt2-doc-line where
                    tt2-doc-line.doc-code  =  v-num-doc :
         find first tt-gds-dtl where
                    tt-gds-dtl.doc-code  =  v-num-doc and
                    tt-gds-dtl.artic     =  tt2-doc-line.artic and
                    tt-gds-dtl.prod-type =  tt2-doc-line.prod-type and
                    tt-gds-dtl.prod-code =  tt2-doc-line.prod-code no-error .

         if not available tt-gds-dtl then do:
            create tt-gds-dtl.
         end.
          { gbl/rootnode.i
          tt2-doc-line.artic
          tt2-doc-line.prod-type
          tt2-doc-line.prod-code
          v-root-node
          }

         buffer-copy tt2-doc-line to tt-gds-dtl
         assign
            tt-gds-dtl.doc-code  = v-num-doc
            tt-gds-dtl.prt-code  = v-root-node
         .
     end.

/*
    for each tt2-doc-line :
        message tt2-doc-line.cli-qnty
                tt2-doc-line.fact-qnty
                tt2-doc-line.doc-qnty
                skip
                'doc-line2' skip
                tt2-doc-line.artic .
    end.
    for each tt-gds-dtl :
        message tt-gds-dtl.fact-qnty tt-gds-dtl.doc-qnty 'gds-dtl'skip  tt-gds-dtl.artic.
    end.
    for each tt-parts:
        message tt-parts.cli-qnty tt-parts.fact-qnty tt-parts.qnty tt-parts.part-code 'parts' skip tt-parts.artic
        tt-parts.out-code
        .
    end.
*/

    find first new_trn-doc where new_trn-doc.doc-code = tt-trn-doc.doc-code  exclusive-lock no-error .

    if  available new_trn-doc then do:
    assign
        new_trn-doc.print-rubl = tt-trn-doc.print-rubl
        new_trn-doc.hold-doc-code-child  = "no-hold":u
        new_trn-doc.hold-doc-code-parent = "no-hold":u
        .

      assign
          new_trn-doc.cli-type = v-cli-type
          new_trn-doc.cli-code = v-cli-code
          new_trn-doc.cli-name = v-cli-name
          .
        end.

    { str/copy-ret.i
      parparentproc
      tt-trn-doc.doc-code
      tt-trn-doc.doc-type
      tt-trn-doc.status_
      tt-trn-doc.internal
      tt-trn-doc.cli-type
      tt-trn-doc.cli-code
      tt-trn-doc.discnt-type
      tt-trn-doc.tot-calc
      tt-trn-doc.discnt-pc
      tt-trn-doc.agnt
      tt-trn-doc.boss
      tt-trn-doc.wrkr
      tt-trn-doc.base-rate
      tt-trn-doc.base-scale
      tt-trn-doc.exch-code
      tt-trn-doc.vat-type
      tt-trn-doc.doc-code
      no
      tt-trn-doc.discnt-pc
      tt-trn-doc.agnt
      tt-trn-doc.boss
      tt-trn-doc.wrkr
      tt-trn-doc.base-rate
      tt-trn-doc.base-scale
      v-cntxt-cash-pay
      v-cntxt-base-code
      tt2-doc-line
      tt-gds-dtl
      tt-parts
      yes
      yes
      yes
      yes
      no-error }

   if error-status :error then message
     vss-workfile vss-revision vss-description skip
     error-status :get-message(1) skip
     return-value skip
     "str/copy-ret.i"
     view-as alert-box error
   .
   run gbl/calc-trn.p (input parparentproc, input recid (new_trn-doc) ) no-error.

  end.

end procedure. /* create-trn */