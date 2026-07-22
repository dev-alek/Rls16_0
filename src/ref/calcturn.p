block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: calcturn.p $
$Archive: ref/calcturn.p $

Расчет оборота по покупателю с нулЯ

Автор: Чернова Светлана Александровна
Дата создания: 11/25/05
Author: Svetlana Chernova
Creation date: 11/25/05

*/

define input  parameter p-cli-type as character no-undo .
define input  parameter p-cli-code as integer   no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: calcturn.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/calcturn.p $":U .
define variable vss-description as character no-undo init "Расчет оборота по покупателю с нуля ".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/clcprtsl.i }
{ gbl/waitfram.i }
{ cmp/obj-list.i new }
run waitfram-show ( "Ждите..." ) .
define buffer buf_trn-doc for ub.trn-doc  .
define buffer buf_clients for ub.clients  .

/* А надо ли ?*/
  define variable v-use-grp-buy           as logical   no-undo .
  define variable v-use-oborot-buy        as logical   no-undo .
  define variable v-use-qnty-group        as logical   no-undo .
  define variable v-use-sum-group         as logical   no-undo .
  define variable v-use-add-code          as logical   no-undo .
  define variable v-use-sys-date-time     as logical   no-undo .
  define variable v-use-shift-date-num    as logical   no-undo .
  define variable v-use-cassa             as logical   no-undo .
  define variable v-use-val               as logical   no-undo .
  define variable v-use-pay-type          as logical   no-undo .
  define variable v-use-cash-pay          as logical   no-undo .
  define variable v-use-child as logical   no-undo .
  { gbl/glstall.i
    v-use-grp-buy
    v-use-oborot-buy
    v-use-qnty-group
    v-use-sum-group
    v-use-add-code
    v-use-sys-date-time
    v-use-shift-date-num
    v-use-cassa
    v-use-val
    v-use-pay-type
    v-use-cash-pay
    v-use-child
    }
/* А надо ли ?*/
if not ( v-use-grp-buy or v-use-oborot-buy )  then return .


find buf_clients no-lock where
     buf_clients.obj-code = p-cli-code and
     buf_clients.obj-type = p-cli-type no-error .

if not buf_clients.turnover-buyer then return .

/*
delete from turnover-buyer-gds .
delete from turnover-buyer-main .
delete from turnover-buyer .
*/

define buffer obj_clients for ub.clients  .
define buffer buf_chk-doc for ub.chk-doc  .

define buffer buf_sysconf for ub.sysconf  .
for each buf_sysconf no-lock :
    for each buf_trn-doc no-lock  where
             buf_trn-doc.status_   = {&fact} and
             buf_trn-doc.host-code = buf_sysconf.host-code and
             buf_trn-doc.cli-type  = buf_clients.obj-type and
             buf_trn-doc.cli-code  = buf_clients.obj-code
             :
             run waitfram-show ( buf_trn-doc.doc-code  ) .
             run case-type.
    end.
  end.


run waitfram-show ( "Подсчет нарастающего итога..."  ) .

define variable   v-sum-acc-base       as decimal   no-undo init 0 .
define variable   v-sum-acc-rubl       as decimal   no-undo init 0 .
define variable   v-sum-doc-base       as decimal   no-undo init 0 .
define variable   v-sum-doc-rubl       as decimal   no-undo init 0 .
define variable   v-sum-slt-acc-base   as decimal   no-undo init 0 .
define variable   v-sum-slt-acc-rubl   as decimal   no-undo init 0 .
define variable   v-sum-slt-doc-base   as decimal   no-undo init 0 .
define variable   v-sum-slt-doc-rubl   as decimal   no-undo init 0 .
define variable   v-sum-vat-acc-base   as decimal   no-undo init 0 .
define variable   v-sum-vat-acc-rubl   as decimal   no-undo init 0 .
define variable   v-sum-vat-doc-base   as decimal   no-undo init 0 .
define variable   v-sum-vat-doc-rubl   as decimal   no-undo init 0 .
define variable   v-sum-qnty-doc       as decimal   no-undo init 0 .
define variable   v-sum-qnty-check     as decimal   no-undo init 0 .

for each obj-list :
    assign
    v-sum-acc-base      = 0
    v-sum-acc-rubl      = 0
    v-sum-doc-base      = 0
    v-sum-doc-rubl      = 0
    v-sum-slt-acc-base  = 0
    v-sum-slt-acc-rubl  = 0
    v-sum-slt-doc-base  = 0
    v-sum-slt-doc-rubl  = 0
    v-sum-vat-acc-base  = 0
    v-sum-vat-acc-rubl  = 0
    v-sum-vat-doc-base  = 0
    v-sum-vat-doc-rubl  = 0
    v-sum-qnty-doc      = 0
    v-sum-qnty-check    = 0

    .

    for each ub.turnover-buyer exclusive-lock where
            ub.turnover-buyer.cli-type  = buf_clients.obj-type and
            ub.turnover-buyer.cli-code  = buf_clients.obj-code and
            ub.turnover-buyer.obj-type  = obj-list.obj-type and
            ub.turnover-buyer.obj-code  = obj-list.obj-code
            by ub.turnover-buyer.fact-order
            :
      assign
        v-sum-acc-base     =  v-sum-acc-base     +  ub.turnover-buyer.sum-acc-base
        v-sum-acc-rubl     =  v-sum-acc-rubl     +  ub.turnover-buyer.sum-acc-rubl
        v-sum-doc-base     =  v-sum-doc-base     +  ub.turnover-buyer.sum-doc-base
        v-sum-doc-rubl     =  v-sum-doc-rubl     +  ub.turnover-buyer.sum-doc-rubl
        v-sum-slt-acc-base =  v-sum-slt-acc-base +  ub.turnover-buyer.sum-slt-acc-base
        v-sum-slt-acc-rubl =  v-sum-slt-acc-rubl +  ub.turnover-buyer.sum-slt-acc-rubl
        v-sum-slt-doc-base =  v-sum-slt-doc-base +  ub.turnover-buyer.sum-slt-doc-base
        v-sum-slt-doc-rubl =  v-sum-slt-doc-rubl +  ub.turnover-buyer.sum-slt-doc-rubl
        v-sum-vat-acc-base =  v-sum-vat-acc-base +  ub.turnover-buyer.sum-vat-acc-base
        v-sum-vat-acc-rubl =  v-sum-vat-acc-rubl +  ub.turnover-buyer.sum-vat-acc-rubl
        v-sum-vat-doc-base =  v-sum-vat-doc-base +  ub.turnover-buyer.sum-vat-doc-base
        v-sum-vat-doc-rubl =  v-sum-vat-doc-rubl +  ub.turnover-buyer.sum-vat-doc-rubl
        .
        if ub.turnover-buyer.doc-code   <> "" then v-sum-qnty-doc = v-sum-qnty-doc + 1.
        if ub.turnover-buyer.inkas-code <> "" then v-sum-qnty-check = v-sum-qnty-check + 1.

      assign
        ub.turnover-buyer.sum-acc-base-itog      = v-sum-acc-base
        ub.turnover-buyer.sum-acc-rubl-itog      = v-sum-acc-rubl
        ub.turnover-buyer.sum-doc-base-itog      = v-sum-doc-base
        ub.turnover-buyer.sum-doc-rubl-itog      = v-sum-doc-rubl
        ub.turnover-buyer.sum-slt-acc-base-itog  = v-sum-slt-acc-base
        ub.turnover-buyer.sum-slt-acc-rubl-itog  = v-sum-slt-acc-rubl
        ub.turnover-buyer.sum-slt-doc-base-itog  = v-sum-slt-doc-base
        ub.turnover-buyer.sum-slt-doc-rubl-itog  = v-sum-slt-doc-rubl
        ub.turnover-buyer.sum-vat-acc-base-itog  = v-sum-vat-acc-base
        ub.turnover-buyer.sum-vat-acc-rubl-itog  = v-sum-vat-acc-rubl
        ub.turnover-buyer.sum-vat-doc-base-itog  = v-sum-vat-doc-base
        ub.turnover-buyer.sum-vat-doc-rubl-itog  = v-sum-vat-doc-rubl
        ub.turnover-buyer.qnty-doc-itog          = v-sum-qnty-doc
        ub.turnover-buyer.qnty-check-itog        = v-sum-qnty-check
        .
    end.
      find first ub.turnover-buyer-main exclusive-lock where
                  ub.turnover-buyer-main.cli-code     = buf_clients.obj-code and
                  ub.turnover-buyer-main.cli-type     = buf_clients.obj-type and
                  ub.turnover-buyer-main.obj-code     = obj-list.obj-code    and
                  ub.turnover-buyer-main.obj-type     = obj-list.obj-type    no-error .

      if not available ub.turnover-buyer-main then create ub.turnover-buyer-main .
      assign
      ub.turnover-buyer-main.cli-code     = buf_clients.obj-code
      ub.turnover-buyer-main.cli-type     = buf_clients.obj-type
      ub.turnover-buyer-main.obj-code     = obj-list.obj-code
      ub.turnover-buyer-main.obj-type     = obj-list.obj-type
      ub.turnover-buyer-main.des          = ""
      ub.turnover-buyer-main.sum-acc-base-itog     =  v-sum-acc-base
      ub.turnover-buyer-main.sum-acc-rubl-itog     =  v-sum-acc-rubl
      ub.turnover-buyer-main.sum-doc-base-itog     =  v-sum-doc-base
      ub.turnover-buyer-main.sum-doc-rubl-itog     =  v-sum-doc-rubl
      ub.turnover-buyer-main.qnty-doc-itog   = v-sum-qnty-doc
      ub.turnover-buyer-main.qnty-check-itog = v-sum-qnty-check
      .

end.

  for each buf_sysconf no-lock :
  for each obj_clients no-lock where
           obj_clients.host-code = buf_sysconf.host-code
           :
    run waitfram-show ( "По чекам  по фирмы " + string (obj_clients.host-code)  ) .
    for each buf_trn-doc no-lock  where
             buf_trn-doc.status_      = {&fact}   and
             buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass} and
             buf_trn-doc.doc-type = {&expense} and
             buf_trn-doc.internal = false      and
             buf_trn-doc.obj-type = obj_clients.obj-type and
             buf_trn-doc.obj-code = obj_clients.obj-code ,
             each buf_chk-doc no-lock where
                  buf_chk-doc.out-code  = buf_trn-doc.doc-code and
                  buf_chk-doc.cli-type  = buf_clients.obj-type and
                  buf_chk-doc.cli-code  = buf_clients.obj-code
                  :
                  run ref/calctur4.p ( buf_chk-doc.doc-code ) .
    end.
  end.
end.


run waitfram-hide .


procedure case-type :
  do
  on error undo, return error return-value
  :
define variable   v-sum-acc-base       as decimal   no-undo init 0 .
define variable   v-sum-acc-rubl       as decimal   no-undo init 0 .
define variable   v-sum-doc-base       as decimal   no-undo init 0 .
define variable   v-sum-doc-rubl       as decimal   no-undo init 0 .
define variable   v-sum-slt-acc-base   as decimal   no-undo init 0 .
define variable   v-sum-slt-acc-rubl   as decimal   no-undo init 0 .
define variable   v-sum-slt-doc-base   as decimal   no-undo init 0 .
define variable   v-sum-slt-doc-rubl   as decimal   no-undo init 0 .
define variable   v-sum-vat-acc-base   as decimal   no-undo init 0 .
define variable   v-sum-vat-acc-rubl   as decimal   no-undo init 0 .
define variable   v-sum-vat-doc-base   as decimal   no-undo init 0 .
define variable   v-sum-vat-doc-rubl   as decimal   no-undo init 0 .

define variable   v-acc-base       as decimal   no-undo init 0 .
define variable   v-acc-rubl       as decimal   no-undo init 0 .
define variable   v-doc-base       as decimal   no-undo init 0 .
define variable   v-doc-rubl       as decimal   no-undo init 0 .
define variable   v-slt-acc-base   as decimal   no-undo init 0 .
define variable   v-slt-acc-rubl   as decimal   no-undo init 0 .
define variable   v-slt-doc-base   as decimal   no-undo init 0 .
define variable   v-slt-doc-rubl   as decimal   no-undo init 0 .
define variable   v-vat-acc-base   as decimal   no-undo init 0 .
define variable   v-vat-acc-rubl   as decimal   no-undo init 0 .
define variable   v-vat-doc-base   as decimal   no-undo init 0 .
define variable   v-vat-doc-rubl   as decimal   no-undo init 0 .

define variable v-sign as integer   no-undo .

define buffer buf_goods for ub.goods  .
define buffer buf_doc-line for ub.doc-line  .

 for each buf_doc-line no-lock
    where buf_doc-line.doc-code = buf_trn-doc.doc-code  :

    run clcprtsl_calc-line in this-procedure ( input recid( buf_doc-line ) ).
    /*
    for each tt-allsum-line :
       message tt-allsum-line.sum-type skip
               'sum-dsc-rubl-cur' tt-allsum-line.sum-dsc-rubl-cur  SKIP
               'sum-dsc-rubl-acc ' tt-allsum-line.sum-dsc-rubl-acc SKIP
               'sum-dsc-rubl-DOC ' tt-allsum-line.sum-dsc-rubl-DOC SKIP
.
    end.
    */
    find first tt-allsum-line
         where tt-allsum-line.sum-type = {&sum-general}
    no-error.
    if not available tt-allsum-line then next.
        assign
          v-acc-base      = tt-allsum-line.sum-dsc-base-acc
          v-acc-rubl      = tt-allsum-line.sum-dsc-rubl-acc
          v-doc-base      = tt-allsum-line.sum-dsc-base-doc
          v-doc-rubl      = tt-allsum-line.sum-dsc-rubl-doc
          v-slt-acc-base  = tt-allsum-line.slt-base-acc
          v-slt-acc-rubl  = tt-allsum-line.slt-rubl-acc
          v-slt-doc-base  = tt-allsum-line.slt-base-doc
          v-slt-doc-rubl  = tt-allsum-line.slt-rubl-doc
          v-vat-acc-base  = tt-allsum-line.vat-base-acc
          v-vat-acc-rubl  = tt-allsum-line.vat-rubl-acc
          v-vat-doc-base  = tt-allsum-line.vat-base-doc
          v-vat-doc-rubl  = tt-allsum-line.vat-rubl-doc
       .
    assign
    v-sum-acc-base     =  v-sum-acc-base     +  v-acc-base
    v-sum-acc-rubl     =  v-sum-acc-rubl     +  v-acc-rubl
    v-sum-doc-base     =  v-sum-doc-base     +  v-doc-base
    v-sum-doc-rubl     =  v-sum-doc-rubl     +  v-doc-rubl
    v-sum-slt-acc-base =  v-sum-slt-acc-base +  v-slt-acc-base
    v-sum-slt-acc-rubl =  v-sum-slt-acc-rubl +  v-slt-acc-rubl
    v-sum-slt-doc-base =  v-sum-slt-doc-base +  v-slt-doc-base
    v-sum-slt-doc-rubl =  v-sum-slt-doc-rubl +  v-slt-doc-rubl
    v-sum-vat-acc-base =  v-sum-vat-acc-base +  v-vat-acc-base
    v-sum-vat-acc-rubl =  v-sum-vat-acc-rubl +  v-vat-acc-rubl
    v-sum-vat-doc-base =  v-sum-vat-doc-base +  v-vat-doc-base
    v-sum-vat-doc-rubl =  v-sum-vat-doc-rubl +  v-vat-doc-rubl

    .

   if buf_clients.turnover-buyer-gds then do :

      find first buf_goods no-lock where
                 buf_goods.artic = buf_doc-line.artic         and
                 buf_goods.prod-type = buf_doc-line.prod-type and
                 buf_goods.prod-code = buf_doc-line.prod-code no-error  .
  if  buf_trn-doc.ext-doc-type =  {&TDEDT_Ras_Vnesh} or
      buf_trn-doc.ext-doc-type =  {&TDEDT_Vozvrat_Vnesh}
  then do:
      if buf_trn-doc.ext-doc-type =  {&TDEDT_Vozvrat_Vnesh} then v-sign = (-1) .
        else v-sign = 1 .
      create ub.turnover-buyer-gds .
      assign
      ub.turnover-buyer-gds.gds-code     = buf_goods.gds-code
      ub.turnover-buyer-gds.cli-code     = buf_trn-doc.cli-code
      ub.turnover-buyer-gds.cli-type     = buf_trn-doc.cli-type
      ub.turnover-buyer-gds.d-card       = ""
      ub.turnover-buyer-gds.des          = ""
      ub.turnover-buyer-gds.doc-code     = buf_trn-doc.doc-code
      ub.turnover-buyer-gds.ext-doc-type = buf_trn-doc.ext-doc-type
      ub.turnover-buyer-gds.fact-date    = buf_trn-doc.fact-date
      ub.turnover-buyer-gds.fact-order   = buf_trn-doc.fact-order
      ub.turnover-buyer-gds.inkas-code   = ""
      ub.turnover-buyer-gds.obj-code     = buf_trn-doc.obj-code
      ub.turnover-buyer-gds.obj-type     = buf_trn-doc.obj-type
      ub.turnover-buyer-gds.shift-date       = buf_trn-doc.shift-date
      ub.turnover-buyer-gds.shift-num        = buf_trn-doc.shift-num
      ub.turnover-buyer-gds.shift-name       = buf_trn-doc.shift-name
      ub.turnover-buyer-gds.sum-acc-base     =  v-acc-base
      ub.turnover-buyer-gds.sum-acc-rubl     =  v-acc-rubl
      ub.turnover-buyer-gds.sum-doc-base     =  v-doc-base
      ub.turnover-buyer-gds.sum-doc-rubl     =  v-doc-rubl
      ub.turnover-buyer-gds.sum-slt-acc-base = v-sign * v-slt-acc-base
      ub.turnover-buyer-gds.sum-slt-acc-rubl = v-sign * v-slt-acc-rubl
      ub.turnover-buyer-gds.sum-slt-doc-base = v-sign * v-slt-doc-base
      ub.turnover-buyer-gds.sum-slt-doc-rubl = v-sign * v-slt-doc-rubl
      ub.turnover-buyer-gds.sum-vat-acc-base = v-sign * v-vat-acc-base
      ub.turnover-buyer-gds.sum-vat-acc-rubl = v-sign * v-vat-acc-rubl
      ub.turnover-buyer-gds.sum-vat-doc-base = v-sign * v-vat-doc-base
      ub.turnover-buyer-gds.sum-vat-doc-rubl = v-sign * v-vat-doc-rubl
      ub.turnover-buyer-gds.sum-type         = ""
      ub.turnover-buyer-gds.sys-date         = today
      ub.turnover-buyer-gds.sys-time         = time
      ub.turnover-buyer-gds.sys-time-char    = string(ub.turnover-buyer-gds.sys-time,"hh:mm")
      ub.turnover-buyer-gds.type             = 0
      .
      end.
   end.
 end.


  case buf_trn-doc.ext-doc-type :
      when {&TDEDT_Ras_Vnesh}  then do:
        run create_tbl (
            v-sum-acc-base     ,
            v-sum-acc-rubl     ,
            v-sum-doc-base     ,
            v-sum-doc-rubl     ,
            v-sum-slt-acc-base ,
            v-sum-slt-acc-rubl ,
            v-sum-slt-doc-base ,
            v-sum-slt-doc-rubl ,
            v-sum-vat-acc-base ,
            v-sum-vat-acc-rubl ,
            v-sum-vat-doc-base ,
            v-sum-vat-doc-rubl  ).
      end.
      when {&TDEDT_Vozvrat_Vnesh}  then do:
        run create_tbl (
            (-1) * v-sum-acc-base     ,
            (-1) * v-sum-acc-rubl     ,
            (-1) * v-sum-doc-base     ,
            (-1) * v-sum-doc-rubl     ,
            (-1) * v-sum-slt-acc-base ,
            (-1) * v-sum-slt-acc-rubl ,
            (-1) * v-sum-slt-doc-base ,
            (-1) * v-sum-slt-doc-rubl ,
            (-1) * v-sum-vat-acc-base ,
            (-1) * v-sum-vat-acc-rubl ,
            (-1) * v-sum-vat-doc-base ,
            (-1) * v-sum-vat-doc-rubl  ).
      end.

  end case.

  end.

end procedure. /* case-type */




procedure create_tbl  :
  do
  on error undo, return error return-value
  :

define input  parameter v-sum-acc-base       as decimal   no-undo .
define input  parameter v-sum-acc-rubl       as decimal   no-undo .
define input  parameter v-sum-doc-base       as decimal   no-undo .
define input  parameter v-sum-doc-rubl       as decimal   no-undo .
define input  parameter v-sum-slt-acc-base   as decimal   no-undo .
define input  parameter v-sum-slt-acc-rubl   as decimal   no-undo .
define input  parameter v-sum-slt-doc-base   as decimal   no-undo .
define input  parameter v-sum-slt-doc-rubl   as decimal   no-undo .
define input  parameter v-sum-vat-acc-base   as decimal   no-undo .
define input  parameter v-sum-vat-acc-rubl   as decimal   no-undo .
define input  parameter v-sum-vat-doc-base   as decimal   no-undo .
define input  parameter v-sum-vat-doc-rubl   as decimal   no-undo .

    create ub.turnover-buyer .
    assign
      ub.turnover-buyer.cli-code     = buf_trn-doc.cli-code
      ub.turnover-buyer.cli-type     = buf_trn-doc.cli-type
      ub.turnover-buyer.d-card       = ""
      ub.turnover-buyer.des          = ""
      ub.turnover-buyer.doc-code     = buf_trn-doc.doc-code
      ub.turnover-buyer.ext-doc-type = buf_trn-doc.ext-doc-type
      ub.turnover-buyer.fact-date    = buf_trn-doc.fact-date
      ub.turnover-buyer.fact-order   = buf_trn-doc.fact-order
      ub.turnover-buyer.inkas-code   = ""
      ub.turnover-buyer.obj-code     = buf_trn-doc.obj-code
      ub.turnover-buyer.obj-type     = buf_trn-doc.obj-type
      ub.turnover-buyer.qnty-check       = 0
      ub.turnover-buyer.qnty-doc-itog    = 1
      ub.turnover-buyer.shift-date       = buf_trn-doc.shift-date
      ub.turnover-buyer.shift-num        = buf_trn-doc.shift-num
      ub.turnover-buyer.shift-name       = buf_trn-doc.shift-name
      ub.turnover-buyer.sum-acc-base     =  v-sum-acc-base
      ub.turnover-buyer.sum-acc-rubl     =  v-sum-acc-rubl
      ub.turnover-buyer.sum-doc-base     =  v-sum-doc-base
      ub.turnover-buyer.sum-doc-rubl     =  v-sum-doc-rubl
      ub.turnover-buyer.sum-slt-acc-base =  v-sum-slt-acc-base
      ub.turnover-buyer.sum-slt-acc-rubl =  v-sum-slt-acc-rubl
      ub.turnover-buyer.sum-slt-doc-base =  v-sum-slt-doc-base
      ub.turnover-buyer.sum-slt-doc-rubl =  v-sum-slt-doc-rubl
      ub.turnover-buyer.sum-vat-acc-base =  v-sum-vat-acc-base
      ub.turnover-buyer.sum-vat-acc-rubl =  v-sum-vat-acc-rubl
      ub.turnover-buyer.sum-vat-doc-base =  v-sum-vat-doc-base
      ub.turnover-buyer.sum-vat-doc-rubl =  v-sum-vat-doc-rubl
      ub.turnover-buyer.sum-type         = ""
      ub.turnover-buyer.sys-date         = today
      ub.turnover-buyer.sys-time         = time
      ub.turnover-buyer.sys-time-char    = string(ub.turnover-buyer.sys-time,"hh:mm")
      ub.turnover-buyer.type             = 0
/*
      ub.turnover-buyer.qnty-doc-itog   =
      ub.turnover-buyer.qnty-check-itog =
      ub.turnover-buyer.sum-acc-base-itog     =
      ub.turnover-buyer.sum-acc-rubl-itog     =
      ub.turnover-buyer.sum-doc-base-itog     =
      ub.turnover-buyer.sum-doc-rubl-itog     =
      ub.turnover-buyer.sum-slt-acc-base-itog =
      ub.turnover-buyer.sum-slt-acc-rubl-itog =
      ub.turnover-buyer.sum-slt-doc-base-itog =
      ub.turnover-buyer.sum-slt-doc-rubl-itog =
      ub.turnover-buyer.sum-vat-acc-base-itog =
      ub.turnover-buyer.sum-vat-acc-rubl-itog =
      ub.turnover-buyer.sum-vat-doc-base-itog =
      ub.turnover-buyer.sum-vat-doc-rubl-itog =
*/
    .

  if not can-find (first obj-list where
                  obj-list.obj-type = buf_trn-doc.obj-type and
                  obj-list.obj-code = buf_trn-doc.obj-code   ) then
   run create_obj-list ( buf_trn-doc.obj-type , buf_trn-doc.obj-code ).


  end.

end procedure. /* create_tbl  */