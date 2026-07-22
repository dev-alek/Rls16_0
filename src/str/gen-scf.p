block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: gen-scf.p $
$Archive: str/gen-scf.p $

Генерация счета-фактуры

Автор: Чернова Светлана Александровна
Дата создания: 10/11/05
Author: Svetlana Chernova
Creation date: 10/11/05

*/

DEFINE INPUT  PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input  parameter p-ri   as recid     no-undo .
define input  parameter p-type as character no-undo .  /* trn-doc fin-ob fin-doc add-doc */
define output parameter p-list as character no-undo .  /* что сгенерили */

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: gen-scf.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/gen-scf.p $":U .
define variable vss-description as character no-undo initial "Генерация счета-фактуры":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ trg/factord.i  }
{ gbl/cur-time.i }
{ rep/fmtcli.i   }
{ gbl/clntattr.i }
{ str/trdcalib.i }
{ rep/torgconf.i }
{ str/clcprtsl.i }
{ gbl/waitfram.i }
{ str/fo-gtd.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

do
on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:

define buffer buf_contract  for ub.contract .
define buffer buf_trn-doc   for ub.trn-doc .
define buffer buf_sysconf   for ub.sysconf .
define buffer buf_clients   for ub.clients .

define variable is-delay               as logical initial no no-undo .
define variable is-fact                as logical initial no no-undo .
define variable gen-stat               as integer   no-undo .
define variable v-shift-end-fact-order as decimal   no-undo .
define variable v-day-end-fact-order   as decimal   no-undo .
define variable day-delay              as integer   no-undo .
define variable ii                     as integer   no-undo .
define variable db-list                as character no-undo .

define variable p-sys-time1     as character no-undo .
define variable p-user-db-num   like ub.schet-fact-doc.user-db-num no-undo .
define variable p-user-name     like ub.schet-fact-doc.user-name   no-undo .
define variable p-sys-date      like ub.schet-fact-doc.sys-date    no-undo .
define variable p-sys-time      like ub.schet-fact-doc.sys-time    no-undo .

find first buf_sysconf no-lock where buf_sysconf.host-code = v-cntxt-host-code-obj .
{ gbl/curdburt.i  p-user-db-num  p-user-name  p-sys-date  p-sys-time1  p-sys-time }

  run waitfram-show("Ждите...").
  case p-type :
    when "trn-doc" then do:
      find first buf_trn-doc exclusive-lock where recid (buf_trn-doc) = p-ri no-error .
      if not available buf_trn-doc then return error .

      find first buf_clients no-lock
        where buf_clients.obj-type = buf_trn-doc.obj-type
          and buf_clients.obj-code = buf_trn-doc.obj-code
      no-error .

      if buf_trn-doc.host-code <> v-cntxt-host-code-obj then
        return error substitute( "&1. Ошибка генерации. &2", vss-workfile, "Нельзя генерить счета-фактуры по документам не текущей фирмы!" ).

      if buf_sysconf.gen-s-f-office then do:
        if v-cntxt-db-num <> 0 then
          return error substitute( "&1. Ошибка генерации. &2", vss-workfile, "Генерация счетов-фактур на текущей фирме разрешена только в офисе!" ).
      end.
      else do:
        if v-cntxt-db-num <> buf_clients.db-num then
          return error substitute( "&1. Ошибка генерации. &2", vss-workfile, "Нельзя генерить счета-фактуры по документам не текущей БД!" ).
      end.

      if buf_trn-doc.ext-doc-type = {&TDEDT_Chg_Purch_Code} then run gen-by-trn-doc1 .
         else run gen-by-trn-doc .
    end.
    when "fin-ob" or
    when "fin-ob-spc" then do:
      run gen-by-fin-ob no-error .
      if error-status:error then  return error substitute( "&1. Ошибка генерации . &2", vss-workfile, return-value ).
    end.
    when "fin-doc" then do:
      run gen-by-fin-doc no-error .
      if error-status:error then  return error substitute( "&1. Ошибка генерации. &2", vss-workfile, return-value ).
    end.
    when "add-doc" then do:
      run gen-by-add-doc no-error .
      if error-status:error then  return error substitute( "&1. Ошибка генерации по ДопРасходу. &2", vss-workfile, return-value ).
    end.
  end case.
  run waitfram-hide.

end.



procedure gen-by-trn-doc :
  do
  on error undo, return error return-value
  :
    define buffer buf_doc-line for ub.doc-line .
    define buffer buf_parts    for ub.parts .
    define buffer buf_goods    for ub.goods .
    define buffer buf_parts-attr for ub.parts-attr .

    run torgconf-get-self-param ( input buf_trn-doc.obj-type, input buf_trn-doc.obj-code, 0) .
    run torgconf-get-cli-param ( input buf_trn-doc.host-code, input buf_trn-doc.cli-type, input buf_trn-doc.cli-code,input 0) .

    if buf_trn-doc.contract-code > 0 then do:
      find first buf_contract no-lock
        where buf_contract.host-code     = buf_trn-doc.host-code
          and buf_contract.contract-code = buf_trn-doc.contract-code
      no-error .
      assign gen-stat = buf_contract.gen-factur .
      if gen-stat > 100 then
        assign
          is-fact  = yes
          gen-stat = gen-stat - 100
        .
      if gen-stat > 10 then
        assign
          is-delay  = yes
          gen-stat  = gen-stat - 10
          day-delay = buf_contract.gen-factur-srok
        .
      /*  */
      if buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} and gen-stat <> 1 then
         assign
           is-fact  = no
           is-delay = no
         .
      if buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} and
         not (gen-stat = 1 or gen-stat = 11 or gen-stat = 101 or gen-stat = 111 or gen-stat = 0 ) then do:
             return error " По условиям договора Генерация счета-фактуры не предусмотрена по приходной накладной" .
         end.
    end.

    create ub.schet-fact-doc .
    assign
      ub.schet-fact-doc.doc-code      = string(next-value(s-sf-doc, {&db-name_schema}))
      ub.schet-fact-doc.db-num        = p-user-db-num
      ub.schet-fact-doc.doc-date      = if not is-delay then buf_trn-doc.fact-date else (buf_trn-doc.fact-date + day-delay)
      ub.schet-fact-doc.doc-type      = {&income}
      ub.schet-fact-doc.in-doc-type   = {&SFEDT_Trn_doc}
      ub.schet-fact-doc.in-ext-doc-type = buf_trn-doc.ext-doc-type
      ub.schet-fact-doc.host-code     = buf_trn-doc.host-code
      ub.schet-fact-doc.contract-code = buf_trn-doc.contract-code
      ub.schet-fact-doc.user-db-num   = p-user-db-num
      ub.schet-fact-doc.user-name     = p-user-name
      ub.schet-fact-doc.sys-date      = p-sys-date
      ub.schet-fact-doc.sys-time      = p-sys-time
      ub.schet-fact-doc.base-rate     = buf_trn-doc.base-rate
      ub.schet-fact-doc.base-scale    = buf_trn-doc.base-scale
      ub.schet-fact-doc.PS            = ""
      ub.schet-fact-doc.book-code     = ""
/*      ub.schet-fact-doc.own-address   = v-torgconf-self-host-addres*/
      ub.schet-fact-doc.own-inn       = v-torgconf-self-host-inn
      ub.schet-fact-doc.own-name      = v-torgconf-self-host-name
      ub.schet-fact-doc.own-kpp       = v-torgconf-self-host-kpp
/*      ub.schet-fact-doc.cli-address   = v-torgconf-cli-addres*/
      ub.schet-fact-doc.cli-inn       = v-torgconf-cli-inn
      ub.schet-fact-doc.cli-kpp       = v-torgconf-cli-kpp
      ub.schet-fact-doc.cli-type      = buf_trn-doc.cli-type
      ub.schet-fact-doc.cli-code      = buf_trn-doc.cli-code
      ub.schet-fact-doc.cli-name      = buf_trn-doc.cli-name
      ub.schet-fact-doc.Gruz-otprav   = "он же"
      ub.schet-fact-doc.Gruz-poluch   = substitute( "&1 &2 &3", caps( v-torgconf-self-host-name ),  v-torgconf-self-host-post-addres, v-torgconf-self-host-phone )
      ub.schet-fact-doc.gtd           = buf_trn-doc.cst-code
      ub.schet-fact-doc.country       = ""
      ub.schet-fact-doc.in-date       = buf_trn-doc.fact-date
      ub.schet-fact-doc.in-doc-code   = buf_trn-doc.doc-code
      ub.schet-fact-doc.in-doc-date   = buf_trn-doc.doc-date
      ub.schet-fact-doc.plat-ras-doc  = buf_trn-doc.doc-code + " от " + string(buf_trn-doc.doc-date,"99/99/9999")
      ub.schet-fact-doc.obj-code      = buf_trn-doc.obj-code
      ub.schet-fact-doc.obj-type      = buf_trn-doc.obj-type
      ub.schet-fact-doc.pay-date      = ?
      ub.schet-fact-doc.status_       = if is-fact = no then {&fin-new} else {&fact}
      ub.schet-fact-doc.office        = no
    .
    run Get-address ( input {&cmp}, input ub.schet-fact-doc.host-code, output ub.schet-fact-doc.own-address) .
    run Get-address ( input ub.schet-fact-doc.cli-type, input ub.schet-fact-doc.cli-code, output ub.schet-fact-doc.cli-address) .

    { gbl/docextnm.i  buf_trn-doc.doc-code ub.schet-fact-doc.ext-doc-type}  .
    create ub.factur-connect .
    assign
      buf_trn-doc.factur-date     = ub.schet-fact-doc.sys-date
      buf_trn-doc.cr-factur       = yes
      /*buf_trn-doc.need-factur     = 0 */
      ub.factur-connect.db-num       = ub.schet-fact-doc.db-num
      ub.factur-connect.user-db-num  = ub.schet-fact-doc.user-db-num
      ub.factur-connect.user-name    = ub.schet-fact-doc.user-name
      ub.factur-connect.sys-date     = ub.schet-fact-doc.sys-date
      ub.factur-connect.sys-time     = ub.schet-fact-doc.sys-time
      ub.factur-connect.factur-doc-code = ub.schet-fact-doc.doc-code
      ub.factur-connect.doc-type     = ub.schet-fact-doc.doc-type
      ub.factur-connect.host-code    = ub.schet-fact-doc.host-code
      ub.factur-connect.trn-doc-code = buf_trn-doc.doc-code
      ub.factur-connect.PS           = ""
      ub.factur-connect.connect-code = next-value(s-fin-connect, {&db-name_schema})
    .

    if is-fact then do:
      assign
        ub.schet-fact-doc.fact-date         = ub.schet-fact-doc.sys-date
        ub.schet-fact-doc.fact-time         = int(ub.schet-fact-doc.sys-time)
        ub.schet-fact-doc.fact-user-db-num  = ub.schet-fact-doc.user-db-num
        ub.schet-fact-doc.fact-user-name    = ub.schet-fact-doc.user-name
      .
      run factord (
        input  ub.schet-fact-doc.fact-date
       ,input  ub.schet-fact-doc.fact-time
       ,input  int(ub.schet-fact-doc.doc-code)
       ,input  ?
       ,input  ?
       ,input  no
       ,output ub.schet-fact-doc.fact-order
       ,output v-shift-end-fact-order
       ,output v-day-end-fact-order
      ).
    end.

    assign ii = 0 .

    for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code :
      find first buf_goods no-lock
         where buf_goods.prod-type = buf_doc-line.prod-type
           and buf_goods.prod-code = buf_doc-line.prod-code
           and buf_goods.artic     = buf_doc-line.artic
        .
      for each buf_parts no-lock
        where buf_parts.out-code  = buf_doc-line.doc-code
          and buf_parts.obj-type  = buf_doc-line.obj-type
          and buf_parts.obj-code  = buf_doc-line.obj-code
          and buf_parts.artic     = buf_doc-line.artic
          and buf_parts.prod-type = buf_doc-line.prod-type
          and buf_parts.prod-code = buf_doc-line.prod-code
        :
        if buf_trn-doc.ext-doc-type = {&TDEDT_Chg_Purch_Code} and buf_parts.fact-qnty < 0 then next.

        find first buf_parts-attr no-lock
          where buf_parts-attr.in-code   = buf_parts.in-code
            and buf_parts-attr.gds-code  = buf_goods.gds-code
            and buf_parts-attr.part-code = buf_parts.part-code
        .
        find first ub.country no-lock where ub.country.num-code = buf_parts-attr.country-code .

        empty temp-table tt-allsum.
        empty temp-table tt-clcparts.
        create tt-clcparts.
        buffer-copy buf_parts to tt-clcparts.
        run clcprtsl_calc-parts in this-procedure ( input recid( tt-clcparts ), no, no, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ).
        find first tt-allsum where tt-allsum.sum-type = {&sum-general}.
         ii =  ii + 1.
        create ub.factur-connect-line .
        assign
          ub.factur-connect-line.line-num  = ii
          ub.factur-connect-line.in-code   = buf_parts.in-code
          ub.factur-connect-line.gds-code  = buf_goods.gds-code
          ub.factur-connect-line.part-code = buf_parts.part-code
          ub.factur-connect-line.fact-qnty = tt-allsum.fact-qnty
          ub.factur-connect-line.connect-code = ub.factur-connect.connect-code
          ub.factur-connect-line.db-num    = ub.factur-connect.db-num
          ub.factur-connect-line.host-code = ub.factur-connect.host-code
        .

        create ub.schet-fact-line .
        assign
          ub.schet-fact-line.doc-code      = ub.schet-fact-doc.doc-code
          ub.schet-fact-line.line-num      = ii
          ub.schet-fact-line.db-num        = ub.schet-fact-doc.db-num
          ub.schet-fact-line.type          = {&fin-gen}
          ub.schet-fact-line.gds-code      = buf_goods.gds-code
          ub.schet-fact-line.gds-name      = buf_goods.gds-name
          ub.schet-fact-line.unit-base     = buf_goods.unit-base
          ub.schet-fact-line.fact-qnty     = tt-allsum.fact-qnty
          ub.schet-fact-line.sum-rubl      = tt-allsum.sum-dsc-rubl-acc - tt-allsum.vat-rubl-acc
          ub.schet-fact-line.sum-base      = tt-allsum.sum-dsc-base-acc - tt-allsum.vat-base-acc
          ub.schet-fact-line.price-rubl    = ub.schet-fact-line.sum-rubl / tt-allsum.fact-qnty
          ub.schet-fact-line.price-base    = ub.schet-fact-line.sum-base / tt-allsum.fact-qnty
          ub.schet-fact-line.VAT-rubl      = tt-allsum.vat-rubl-acc
          ub.schet-fact-line.VAT-base      = tt-allsum.vat-base-acc
          ub.schet-fact-line.sum-rubl-VAT  = tt-allsum.sum-dsc-rubl-acc
          ub.schet-fact-line.sum-base-VAT  = tt-allsum.sum-dsc-base-acc
          ub.schet-fact-line.VAT-pc        = buf_parts.VAT-pc
          ub.schet-fact-line.excise        = tt-allsum.excise-rubl-acc
          ub.schet-fact-line.other-base    = tt-allsum.other-base-acc
          ub.schet-fact-line.other-rubl    = tt-allsum.other-rubl-acc
          ub.schet-fact-line.obj-type      = buf_doc-line.obj-type
          ub.schet-fact-line.obj-code      = buf_doc-line.obj-code
          ub.schet-fact-line.ext-doc-type  = ub.schet-fact-doc.ext-doc-type
          ub.schet-fact-line.fact-order    = ub.schet-fact-doc.fact-order
          ub.schet-fact-line.status_       = ub.schet-fact-doc.status_
          ub.schet-fact-line.gtd           = buf_parts.cst-code
          ub.schet-fact-line.country       = ub.country.short-name
          ub.schet-fact-line.host-code     = buf_trn-doc.host-code
          ub.schet-fact-line.in-code       = buf_parts.in-code
          ub.schet-fact-line.part-code     = buf_parts.part-code
          ub.schet-fact-doc.sum-rubl       = ub.schet-fact-doc.sum-rubl + tt-allsum.sum-dsc-rubl-acc
          ub.schet-fact-doc.sum-base       = ub.schet-fact-doc.sum-base + tt-allsum.sum-dsc-base-acc
        .
        if ub.schet-fact-doc.gtd     = "" then  assign ub.schet-fact-doc.gtd     = ub.schet-fact-line.gtd .
        if ub.schet-fact-doc.country = "" then  assign ub.schet-fact-doc.country = ub.schet-fact-line.country .

        if ub.schet-fact-line.VAT-pc < 1 then do:
          if buf_parts.VAT-type = {&without-VAT} then do:
            assign
              ub.schet-fact-doc.sum-VAT-no-base = ub.schet-fact-doc.sum-VAT-no-base + ub.schet-fact-line.sum-base
              ub.schet-fact-doc.sum-VAT-no-rubl = ub.schet-fact-doc.sum-VAT-no-rubl + ub.schet-fact-line.sum-rubl
            .
          end.
          else do:
            assign
              ub.schet-fact-doc.sum-VAT-0-base = ub.schet-fact-doc.sum-VAT-0-base + ub.schet-fact-line.sum-base
              ub.schet-fact-doc.sum-VAT-0-rubl = ub.schet-fact-doc.sum-VAT-0-rubl + ub.schet-fact-line.sum-rubl
            .
          end.
        end.
        else do:
          if ub.schet-fact-line.VAT-pc < 11 then do:
            assign
              ub.schet-fact-doc.VAT-10-base      = ub.schet-fact-doc.VAT-10-base     + ub.schet-fact-line.VAT-base
              ub.schet-fact-doc.VAT-10-rubl      = ub.schet-fact-doc.VAT-10-rubl     + ub.schet-fact-line.VAT-rubl
              ub.schet-fact-doc.sum-VAT-10-base  = ub.schet-fact-doc.sum-VAT-10-base + ub.schet-fact-line.sum-base
              ub.schet-fact-doc.sum-VAT-10-rubl  = ub.schet-fact-doc.sum-VAT-10-rubl + ub.schet-fact-line.sum-rubl
            .
          end.
          else do:
            assign
              ub.schet-fact-doc.VAT-20-base      = ub.schet-fact-doc.VAT-20-base     + ub.schet-fact-line.VAT-base
              ub.schet-fact-doc.VAT-20-rubl      = ub.schet-fact-doc.VAT-20-rubl     + ub.schet-fact-line.VAT-rubl
              ub.schet-fact-doc.sum-VAT-20-base  = ub.schet-fact-doc.sum-VAT-20-base + ub.schet-fact-line.sum-base
              ub.schet-fact-doc.sum-VAT-20-rubl  = ub.schet-fact-doc.sum-VAT-20-rubl + ub.schet-fact-line.sum-rubl
            .
          end.
        end.
      end.
    end.  /* for ub.doc-line  */

    assign
      ub.factur-connect.sum-rubl        = ub.schet-fact-doc.sum-rubl
      ub.factur-connect.sum-VAT-20-rubl = ub.schet-fact-doc.sum-VAT-20-rubl
      ub.factur-connect.VAT-20-rubl     = ub.schet-fact-doc.VAT-20-rubl
      ub.factur-connect.sum-VAT-10-rubl = ub.schet-fact-doc.sum-VAT-10-rubl
      ub.factur-connect.VAT-10-rubl     = ub.schet-fact-doc.VAT-10-rubl
      ub.factur-connect.sum-VAT-0-rubl  = ub.schet-fact-doc.sum-VAT-0-rubl
      ub.factur-connect.sum-VAT-no-rubl = ub.schet-fact-doc.sum-VAT-no-rubl
      ub.factur-connect.sum-base        = ub.schet-fact-doc.sum-base
      ub.factur-connect.sum-VAT-20-base = ub.schet-fact-doc.sum-VAT-20-base
      ub.factur-connect.VAT-20-base     = ub.schet-fact-doc.VAT-20-base
      ub.factur-connect.sum-VAT-10-base = ub.schet-fact-doc.sum-VAT-10-base
      ub.factur-connect.VAT-10-base     = ub.schet-fact-doc.VAT-10-base
      ub.factur-connect.sum-VAT-0-base  = ub.schet-fact-doc.sum-VAT-0-base
      ub.factur-connect.sum-VAT-no-base = ub.schet-fact-doc.sum-VAT-no-base
      p-list = " создан c-ф " + string(ub.schet-fact-doc.doc-code) +  " БД " +  string(ub.schet-fact-doc.db-num) + " договор " + string(ub.schet-fact-doc.contract-code) + {&new-line} .
  end.
end procedure. /* gen-by-trn-doc */


    define temp-table temp-schet-fact-line no-undo like ub.schet-fact-line
      field contract-code as integer
      field VAT-type  like ub.parts.VAT-type
      index contract-code contract-code .
    .
    define temp-table temp-schet-fact-doc no-undo like ub.schet-fact-doc
      field is-delay  as logical
      field gen-stat  as integer
      field day-delay as integer
      field is-fact   as logical
      index contract-code contract-code .
    .

procedure gen-by-trn-doc1 :
  do on error undo, return error return-value :
    define buffer buf_doc-line for ub.doc-line .
    define buffer buf_parts    for ub.parts .
    define buffer buf_goods    for ub.goods .
    define buffer buf_parts-attr for ub.parts-attr .

    define variable v-num-doc as integer   no-undo .

    /* считаем, сколько должно быть с-ф */
    define buffer bf_trn-doc for ub.trn-doc .
    for each buf_parts no-lock where buf_parts.out-code = buf_trn-doc.doc-code :
      if buf_parts.in-code = buf_parts.out-code then next .
      find first bf_trn-doc no-lock where bf_trn-doc.doc-code = buf_parts.in-code no-error .
      if available bf_trn-doc then do:
        find first buf_contract where buf_contract.contract-code = bf_trn-doc.contract-code no-lock no-error.
        if available buf_contract then do:

          if buf_contract.gen-factur = 4 or buf_contract.gen-factur = 14 or buf_contract.gen-factur = 104 or buf_contract.gen-factur = 114 then do:
            find first temp-schet-fact-doc where temp-schet-fact-doc.contract-code = buf_contract.contract-code no-error .
            if not available temp-schet-fact-doc then do:
              run torgconf-get-self-param ( input buf_trn-doc.obj-type, input buf_trn-doc.obj-code, 0) .
              run torgconf-get-cli-param ( input buf_trn-doc.host-code, input buf_contract.cli-type, input buf_contract.cli-code, 0) .
              assign v-num-doc = v-num-doc + 1 .
              create temp-schet-fact-doc .
              assign temp-schet-fact-doc.gen-stat = buf_contract.gen-factur .
              if temp-schet-fact-doc.gen-stat > 100 then
                assign
                  temp-schet-fact-doc.is-fact  = yes
                  temp-schet-fact-doc.gen-stat = temp-schet-fact-doc.gen-stat - 100
                .
              if temp-schet-fact-doc.gen-stat > 10 then
                assign
                  temp-schet-fact-doc.is-delay  = yes
                  temp-schet-fact-doc.gen-stat  = temp-schet-fact-doc.gen-stat - 10
                  temp-schet-fact-doc.day-delay = buf_contract.gen-factur-srok
                .
              assign
                temp-schet-fact-doc.db-num        = p-user-db-num
                temp-schet-fact-doc.doc-date      = if not is-delay then buf_trn-doc.fact-date else (buf_trn-doc.fact-date + day-delay)
                temp-schet-fact-doc.doc-type      = {&income}
                temp-schet-fact-doc.in-doc-type   = {&SFEDT_Trn_doc}
                temp-schet-fact-doc.in-ext-doc-type = buf_trn-doc.ext-doc-type
                temp-schet-fact-doc.host-code     = buf_trn-doc.host-code
                temp-schet-fact-doc.contract-code = buf_contract.contract-code
                temp-schet-fact-doc.user-db-num   = p-user-db-num
                temp-schet-fact-doc.user-name     = p-user-name
                temp-schet-fact-doc.sys-date      = p-sys-date
                temp-schet-fact-doc.sys-time      = p-sys-time
                temp-schet-fact-doc.base-rate     = buf_trn-doc.base-rate
                temp-schet-fact-doc.base-scale    = buf_trn-doc.base-scale
                temp-schet-fact-doc.PS            = ""
                temp-schet-fact-doc.book-code     = ""
/*                temp-schet-fact-doc.own-address   = v-torgconf-self-host-addres*/
                temp-schet-fact-doc.own-inn       = v-torgconf-self-host-inn
                temp-schet-fact-doc.own-name      = v-torgconf-self-host-name
                temp-schet-fact-doc.own-kpp       = v-torgconf-self-host-kpp
                temp-schet-fact-doc.cli-type      = buf_contract.cli-type
                temp-schet-fact-doc.cli-code      = buf_contract.cli-code
                temp-schet-fact-doc.cli-name      = buf_contract.cli-name
                temp-schet-fact-doc.Gruz-otprav   = "он же"
                temp-schet-fact-doc.Gruz-poluch   = substitute( "&1 &2 &3", caps( v-torgconf-self-host-name ),  v-torgconf-self-host-post-addres, v-torgconf-self-host-phone )
                temp-schet-fact-doc.gtd           = ""
                temp-schet-fact-doc.country       = ""
                temp-schet-fact-doc.in-date       = buf_trn-doc.fact-date
                temp-schet-fact-doc.in-doc-code   = buf_trn-doc.doc-code
                temp-schet-fact-doc.in-doc-date   = buf_trn-doc.doc-date
                temp-schet-fact-doc.plat-ras-doc  = buf_trn-doc.doc-code + " от " + string(buf_trn-doc.doc-date,"99/99/9999")
                temp-schet-fact-doc.obj-code      = buf_trn-doc.obj-code
                temp-schet-fact-doc.obj-type      = buf_trn-doc.obj-type
                temp-schet-fact-doc.pay-date      = ?
                temp-schet-fact-doc.status_       = if is-fact = no then {&fin-new} else {&fact}
                temp-schet-fact-doc.office        = no
                buf_trn-doc.factur-date     = temp-schet-fact-doc.sys-date
                buf_trn-doc.cr-factur       = yes
                /*buf_trn-doc.need-factur     = 0*/
              .
              run Get-address ( input {&cmp}, input temp-schet-fact-doc.host-code, output temp-schet-fact-doc.own-address) .
              run Get-address ( input temp-schet-fact-doc.cli-type, input temp-schet-fact-doc.cli-code, output temp-schet-fact-doc.cli-address) .
              if temp-schet-fact-doc.cli-type = {&cmp} then do:
                find first ub.firm no-lock where ub.firm.firm-code = temp-schet-fact-doc.cli-code no-error.
                if available ub.firm then  assign temp-schet-fact-doc.cli-inn = ub.firm.inn  temp-schet-fact-doc.cli-kpp = ub.firm.kpp .
              end.
              { gbl/docextnm.i  buf_trn-doc.doc-code temp-schet-fact-doc.ext-doc-type}  .
            end.

            find first buf_goods no-lock
              where buf_goods.prod-type = buf_parts.prod-type
                and buf_goods.prod-code = buf_parts.prod-code
                and buf_goods.artic     = buf_parts.artic
            .
            find first buf_parts-attr no-lock
              where buf_parts-attr.in-code   = buf_parts.in-code
                and buf_parts-attr.gds-code  = buf_goods.gds-code
                and buf_parts-attr.part-code = buf_parts.part-code
            .
            find first ub.country no-lock where ub.country.num-code = buf_parts-attr.country-code no-error  .

            empty temp-table tt-allsum.
            empty temp-table tt-clcparts.
            create tt-clcparts.
            buffer-copy buf_parts to tt-clcparts.
            run clcprtsl_calc-parts in this-procedure ( input recid( tt-clcparts ), no, no, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ).
            find first tt-allsum where tt-allsum.sum-type = {&sum-general}.
            create temp-schet-fact-line .
/*        create ub.factur-connect-line .*/
            assign
              temp-schet-fact-line.contract-code = buf_contract.contract-code
              temp-schet-fact-line.db-num        = temp-schet-fact-doc.db-num
              temp-schet-fact-line.gds-code      = buf_goods.gds-code
              temp-schet-fact-line.gds-name      = buf_goods.gds-name
              temp-schet-fact-line.unit-base     = buf_goods.unit-base
              temp-schet-fact-line.fact-qnty     = ABSOLUTE (tt-allsum.fact-qnty)
              temp-schet-fact-line.sum-rubl      = ABSOLUTE (tt-allsum.sum-dsc-rubl-acc - tt-allsum.vat-rubl-acc)
              temp-schet-fact-line.sum-base      = ABSOLUTE (tt-allsum.sum-dsc-base-acc - tt-allsum.vat-base-acc)
              temp-schet-fact-line.price-rubl    = ABSOLUTE (temp-schet-fact-line.sum-rubl / tt-allsum.fact-qnty)
              temp-schet-fact-line.price-base    = ABSOLUTE (temp-schet-fact-line.sum-base / tt-allsum.fact-qnty)
              temp-schet-fact-line.VAT-rubl      = ABSOLUTE (tt-allsum.vat-rubl-acc)
              temp-schet-fact-line.VAT-base      = ABSOLUTE (tt-allsum.vat-base-acc)
              temp-schet-fact-line.sum-rubl-VAT  = ABSOLUTE (tt-allsum.sum-dsc-rubl-acc)
              temp-schet-fact-line.sum-base-VAT  = ABSOLUTE (tt-allsum.sum-dsc-base-acc)
              temp-schet-fact-line.VAT-pc        = buf_parts.VAT-pc
              temp-schet-fact-line.excise        = ABSOLUTE (tt-allsum.excise-rubl-acc)
              temp-schet-fact-line.other-base    = ABSOLUTE (tt-allsum.other-base-acc)
              temp-schet-fact-line.other-rubl    = ABSOLUTE (tt-allsum.other-rubl-acc)
              temp-schet-fact-line.obj-type      = buf_parts.obj-type
              temp-schet-fact-line.obj-code      = buf_parts.obj-code
              temp-schet-fact-line.gtd           = buf_parts.cst-code
              temp-schet-fact-line.country       = ub.country.short-name
              temp-schet-fact-line.host-code     = buf_parts.host-code
              temp-schet-fact-line.in-code       = buf_parts.in-code
              temp-schet-fact-line.part-code     = buf_parts.part-code
              temp-schet-fact-line.VAT-type      = buf_parts.VAT-type
            .
          end.
          else do:
            return error substitute( " По условиям договора Генерация счета-фактуры не предусмотрена по документу смена типа приобоетения" ).
          end.
        end.
      end.
    end.

    if v-num-doc > 0 then do: /* надо создавать */
      for each temp-schet-fact-doc :
        create ub.schet-fact-doc .
        buffer-copy temp-schet-fact-doc to ub.schet-fact-doc
        assign
           ub.schet-fact-doc.doc-code     = string(next-value(s-sf-doc, {&db-name_schema}))
        .

        create ub.factur-connect .
        assign
          ub.factur-connect.db-num       = ub.schet-fact-doc.db-num
          ub.factur-connect.user-db-num  = ub.schet-fact-doc.user-db-num
          ub.factur-connect.user-name    = ub.schet-fact-doc.user-name
          ub.factur-connect.sys-date     = ub.schet-fact-doc.sys-date
          ub.factur-connect.sys-time     = ub.schet-fact-doc.sys-time
          ub.factur-connect.factur-doc-code = ub.schet-fact-doc.doc-code
          ub.factur-connect.doc-type     = ub.schet-fact-doc.doc-type
          ub.factur-connect.host-code    = ub.schet-fact-doc.host-code
          ub.factur-connect.trn-doc-code = buf_trn-doc.doc-code
          ub.factur-connect.PS           = ""
          ub.factur-connect.connect-code = next-value(s-fin-connect, {&db-name_schema})
        .
        p-list = " создан c-ф " + string(ub.schet-fact-doc.doc-code) +  " БД " +  string(ub.schet-fact-doc.db-num) + " договор " + string(ub.schet-fact-doc.contract-code) + {&new-line} .
        if temp-schet-fact-doc.is-fact then do:

          assign
            ub.schet-fact-doc.fact-date         = ub.schet-fact-doc.sys-date
            ub.schet-fact-doc.fact-time         = int(ub.schet-fact-doc.sys-time)
            ub.schet-fact-doc.fact-user-db-num  = ub.schet-fact-doc.user-db-num
            ub.schet-fact-doc.fact-user-name    = ub.schet-fact-doc.user-name
          .
          run factord (
            input  ub.schet-fact-doc.fact-date
           ,input  ub.schet-fact-doc.fact-time
           ,input  int(ub.schet-fact-doc.doc-code)
           ,input  ?
           ,input  ?
           ,input  no
           ,output ub.schet-fact-doc.fact-order
           ,output v-shift-end-fact-order
           ,output v-day-end-fact-order
          ).
        end.

        assign ii = 0 .
        for each temp-schet-fact-line where temp-schet-fact-line.contract-code = temp-schet-fact-doc.contract-code :
          ii = ii + 1 .
          create ub.schet-fact-line .
          buffer-copy temp-schet-fact-line to ub.schet-fact-line
          assign
            ub.schet-fact-line.doc-code      = ub.schet-fact-doc.doc-code
            ub.schet-fact-line.type          = {&fin-gen}
            ub.schet-fact-line.db-num        = ub.schet-fact-doc.db-num
            ub.schet-fact-line.ext-doc-type  = ub.schet-fact-doc.ext-doc-type
            ub.schet-fact-line.fact-order    = ub.schet-fact-doc.fact-order
            ub.schet-fact-line.status_       = ub.schet-fact-doc.status_
            ub.schet-fact-doc.sum-rubl       = ub.schet-fact-doc.sum-rubl + ub.schet-fact-line.sum-rubl-VAT
            ub.schet-fact-doc.sum-base       = ub.schet-fact-doc.sum-base + ub.schet-fact-line.sum-base-VAT
            ub.schet-fact-line.line-num      = ii
          .

          create ub.factur-connect-line .
           assign
            ub.factur-connect-line.line-num      = ii
            ub.factur-connect-line.in-code   = ub.schet-fact-line.in-code
            ub.factur-connect-line.gds-code  = ub.schet-fact-line.gds-code
            ub.factur-connect-line.part-code = ub.schet-fact-line.part-code
            ub.factur-connect-line.fact-qnty = ub.schet-fact-line.fact-qnty
            ub.factur-connect-line.connect-code = ub.factur-connect.connect-code
            ub.factur-connect-line.db-num    = ub.factur-connect.db-num
            ub.factur-connect-line.host-code = ub.factur-connect.host-code
          .
          if ub.schet-fact-doc.gtd     = "" then  assign ub.schet-fact-doc.gtd     = ub.schet-fact-line.gtd .
          if ub.schet-fact-doc.country = "" then  assign ub.schet-fact-doc.country = ub.schet-fact-line.country .

          if ub.schet-fact-line.VAT-pc < 1 then do:
            if temp-schet-fact-line.VAT-type = {&without-VAT} then do:
              assign
                ub.schet-fact-doc.sum-VAT-no-base = ub.schet-fact-doc.sum-VAT-no-base + ub.schet-fact-line.sum-base
                ub.schet-fact-doc.sum-VAT-no-rubl = ub.schet-fact-doc.sum-VAT-no-rubl + ub.schet-fact-line.sum-rubl
              .
            end.
            else do:
              assign
                ub.schet-fact-doc.sum-VAT-0-base = ub.schet-fact-doc.sum-VAT-0-base + ub.schet-fact-line.sum-base
                ub.schet-fact-doc.sum-VAT-0-rubl = ub.schet-fact-doc.sum-VAT-0-rubl + ub.schet-fact-line.sum-rubl
              .
            end.
          end.
          else do:
            if ub.schet-fact-line.VAT-pc < 11 then do:
              assign
                ub.schet-fact-doc.VAT-10-base      = ub.schet-fact-doc.VAT-10-base     + ub.schet-fact-line.VAT-base
                ub.schet-fact-doc.VAT-10-rubl      = ub.schet-fact-doc.VAT-10-rubl     + ub.schet-fact-line.VAT-rubl
                ub.schet-fact-doc.sum-VAT-10-base  = ub.schet-fact-doc.sum-VAT-10-base + ub.schet-fact-line.sum-base
                ub.schet-fact-doc.sum-VAT-10-rubl  = ub.schet-fact-doc.sum-VAT-10-rubl + ub.schet-fact-line.sum-rubl
              .
            end.
            else do:
              assign
                ub.schet-fact-doc.VAT-20-base      = ub.schet-fact-doc.VAT-20-base     + ub.schet-fact-line.VAT-base
                ub.schet-fact-doc.VAT-20-rubl      = ub.schet-fact-doc.VAT-20-rubl     + ub.schet-fact-line.VAT-rubl
                ub.schet-fact-doc.sum-VAT-20-base  = ub.schet-fact-doc.sum-VAT-20-base + ub.schet-fact-line.sum-base
                ub.schet-fact-doc.sum-VAT-20-rubl  = ub.schet-fact-doc.sum-VAT-20-rubl + ub.schet-fact-line.sum-rubl
              .
            end.
          end.
          assign
            ub.factur-connect.sum-rubl        = ub.schet-fact-doc.sum-rubl
            ub.factur-connect.sum-VAT-20-rubl = ub.schet-fact-doc.sum-VAT-20-rubl
            ub.factur-connect.VAT-20-rubl     = ub.schet-fact-doc.VAT-20-rubl
            ub.factur-connect.sum-VAT-10-rubl = ub.schet-fact-doc.sum-VAT-10-rubl
            ub.factur-connect.VAT-10-rubl     = ub.schet-fact-doc.VAT-10-rubl
            ub.factur-connect.sum-VAT-0-rubl  = ub.schet-fact-doc.sum-VAT-0-rubl
            ub.factur-connect.sum-VAT-no-rubl = ub.schet-fact-doc.sum-VAT-no-rubl
            ub.factur-connect.sum-base        = ub.schet-fact-doc.sum-base
            ub.factur-connect.sum-VAT-20-base = ub.schet-fact-doc.sum-VAT-20-base
            ub.factur-connect.VAT-20-base     = ub.schet-fact-doc.VAT-20-base
            ub.factur-connect.sum-VAT-10-base = ub.schet-fact-doc.sum-VAT-10-base
            ub.factur-connect.VAT-10-base     = ub.schet-fact-doc.VAT-10-base
            ub.factur-connect.sum-VAT-0-base  = ub.schet-fact-doc.sum-VAT-0-base
            ub.factur-connect.sum-VAT-no-base = ub.schet-fact-doc.sum-VAT-no-base
          .
        end.
      end.
    end.
  end.
end procedure. /* gen-by-trn-doc */


procedure gen-by-fin-ob :
  do
  on error undo, return error return-value
  :

    define buffer buf_fin-ob          for ub.fin-ob .
    define buffer buf_fin-ob-tax      for ub.fin-ob-tax .
    define buffer buf_fin-gds-part    for ub.fin-gds-part .
    define buffer buf_goods           for ub.goods .
    define buffer buf_parts-attr      for ub.parts-attr .

    find first buf_fin-ob exclusive-lock where recid (buf_fin-ob) = p-ri no-error .
    if not available buf_fin-ob then return error error-status :get-message(1) .

    if buf_fin-ob.host-code <> v-cntxt-host-code-obj then
      return error substitute( "&1. Ошибка генерации. &2", vss-workfile, "Нельзя генерить счета-фактуры по документам не текущей фирмы!" ).

    if buf_sysconf.gen-s-f-office then do:
      if v-cntxt-db-num <> 0 then
        return error substitute( "&1. Ошибка генерации. &2", vss-workfile, "Генерация счетов-фактур на текущей фирме разрешена только в офисе!" ).
    end.
    else do:
      if v-cntxt-db-num <> buf_fin-ob.user-db-num-doc then
        return error substitute( "&1. Ошибка генерации. &2", vss-workfile, "Нельзя генерить счета-фактуры по документам не текущей БД!" ).
    end.

    if buf_fin-ob.contract-code > 0 then do:
      find first buf_contract no-lock
        where buf_contract.host-code     = buf_fin-ob.host-code
          and buf_contract.contract-code = buf_fin-ob.contract-code
      no-error .
      assign gen-stat = buf_contract.gen-factur .
      if gen-stat > 100 then
        assign
          is-fact  = yes
          gen-stat = gen-stat - 100
        .
      if gen-stat > 10 then
        assign
          is-delay  = yes
          gen-stat  = gen-stat - 10
          day-delay = buf_contract.gen-factur-srok
        .
      if gen-stat <> 2 then assign  is-fact  = no    is-delay = no  .
      if not (gen-stat = 2 or gen-stat = 12 or gen-stat = 102 or gen-stat = 112) then do:
         return error substitute( " По условиям договора Генерация счета-фактуры не предусмотрена по финансовому обязательству" ).
      end.
    end.

    create ub.schet-fact-doc .
    assign
      ub.schet-fact-doc.doc-code      = string(next-value(s-sf-doc, {&db-name_schema}))
      ub.schet-fact-doc.db-num        = p-user-db-num
      ub.schet-fact-doc.doc-date      = if not is-delay then buf_fin-ob.fact-date else (buf_fin-ob.fact-date + day-delay)
      ub.schet-fact-doc.doc-type      = {&income}
      ub.schet-fact-doc.ext-doc-type  = {&SFEDT_Fin_Ob-full}
      ub.schet-fact-doc.in-doc-type   = {&SFEDT_Fin_Ob}
      ub.schet-fact-doc.in-ext-doc-type = buf_fin-ob.doc-type
      ub.schet-fact-doc.host-code     = buf_fin-ob.host-code
      ub.schet-fact-doc.contract-code = buf_fin-ob.contract-code
      ub.schet-fact-doc.user-db-num   = p-user-db-num
      ub.schet-fact-doc.user-name     = p-user-name
      ub.schet-fact-doc.sys-date      = p-sys-date
      ub.schet-fact-doc.sys-time      = p-sys-time
      ub.schet-fact-doc.base-rate     = buf_fin-ob.base-rate
      ub.schet-fact-doc.base-scale    = buf_fin-ob.base-scale
      ub.schet-fact-doc.PS            = ""
      ub.schet-fact-doc.book-code     = ""
      ub.schet-fact-doc.Gruz-otprav   = "он же"
      ub.schet-fact-doc.gtd           = ""
      ub.schet-fact-doc.country       = ""
      ub.schet-fact-doc.in-date       = buf_fin-ob.fact-date
      ub.schet-fact-doc.in-doc-code   = string(buf_fin-ob.doc-code)
      ub.schet-fact-doc.in-doc-date   = buf_fin-ob.doc-date
      ub.schet-fact-doc.plat-ras-doc  = string(buf_fin-ob.doc-code) + " от " + string(buf_fin-ob.doc-date,"99/99/9999")
      ub.schet-fact-doc.obj-code      = buf_fin-ob.obj-code
      ub.schet-fact-doc.obj-type      = buf_fin-ob.obj-type
      ub.schet-fact-doc.pay-date      = ?
      ub.schet-fact-doc.status_       = if is-fact = no then {&fin-new} else {&fact}
      ub.schet-fact-doc.office        = no
    .
    if buf_fin-ob.payer-type = {&cmp} and buf_fin-ob.payer-code = buf_fin-ob.host-code then do: /* платим мы */
      assign
        ub.schet-fact-doc.cli-type      = buf_fin-ob.receiver-type
        ub.schet-fact-doc.cli-code      = buf_fin-ob.receiver-code
        ub.schet-fact-doc.cli-name      = buf_fin-ob.receiver-name
        ub.schet-fact-doc.own-name      = buf_fin-ob.payer-name
      .
    end.
    else do:
      assign
        ub.schet-fact-doc.cli-type      = buf_fin-ob.payer-type
        ub.schet-fact-doc.cli-code      = buf_fin-ob.payer-code
        ub.schet-fact-doc.cli-name      = buf_fin-ob.payer-name
        ub.schet-fact-doc.own-name      = buf_fin-ob.receiver-name
      .
    end.

    run Get-address ( input {&cmp}, input ub.schet-fact-doc.host-code, output ub.schet-fact-doc.own-address) .
    run Get-address ( input ub.schet-fact-doc.cli-type, input ub.schet-fact-doc.cli-code, output ub.schet-fact-doc.cli-address) .

    find first ub.firm no-lock where ub.firm.firm-code = buf_fin-ob.host-code no-error .
    if error-status :error then return error error-status :get-message(1) .

    assign ub.schet-fact-doc.Gruz-poluch = substitute( "&1 &2", caps( ub.schet-fact-doc.own-name ), trim(firm.post-addr1) ) .

    if buf_fin-ob.contract-code > 0 then do:
      assign
        ub.schet-fact-doc.own-inn       = buf_contract.own-inn
        ub.schet-fact-doc.own-kpp       = buf_contract.own-kpp
        ub.schet-fact-doc.cli-inn       = buf_contract.cli-inn
        ub.schet-fact-doc.cli-kpp       = buf_contract.cli-kpp
      .
    end.
    else do:
      assign
        ub.schet-fact-doc.own-inn     = ub.firm.inn
        ub.schet-fact-doc.own-kpp     = ub.firm.kpp
      .
      if ub.schet-fact-doc.cli-type = {&cmp} then do:
        find first ub.firm no-lock where ub.firm.firm-code = ub.schet-fact-doc.cli-code no-error.
        if available ub.firm then  assign ub.schet-fact-doc.cli-inn = ub.firm.inn  ub.schet-fact-doc.cli-kpp = ub.firm.kpp .
      end.
    end.

    create ub.factur-connect .
    assign
      buf_fin-ob.factur-date         = ub.schet-fact-doc.sys-date
      buf_fin-ob.cr-factur           = yes
      /*buf_fin-ob.need-factur         = 0 */

      ub.factur-connect.db-num       = ub.schet-fact-doc.db-num
      ub.factur-connect.user-db-num  = ub.schet-fact-doc.user-db-num
      ub.factur-connect.user-name    = ub.schet-fact-doc.user-name
      ub.factur-connect.sys-date     = ub.schet-fact-doc.sys-date
      ub.factur-connect.sys-time     = ub.schet-fact-doc.sys-time
      ub.factur-connect.factur-doc-code = ub.schet-fact-doc.doc-code
      ub.factur-connect.doc-type     = ub.schet-fact-doc.doc-type
      ub.factur-connect.host-code    = ub.schet-fact-doc.host-code
      ub.factur-connect.trn-doc-code = string(buf_fin-ob.doc-code)
      ub.factur-connect.PS           = ""
      ub.factur-connect.connect-code = next-value(s-fin-connect, {&db-name_schema})
    .

    if is-fact then do:
      assign
        ub.schet-fact-doc.fact-date         = ub.schet-fact-doc.sys-date
        ub.schet-fact-doc.fact-time         = int(ub.schet-fact-doc.sys-time)
        ub.schet-fact-doc.fact-user-db-num  = ub.schet-fact-doc.user-db-num
        ub.schet-fact-doc.fact-user-name    = ub.schet-fact-doc.user-name
      .
      run factord (
        input  ub.schet-fact-doc.fact-date
       ,input  ub.schet-fact-doc.fact-time
       ,input  int(ub.schet-fact-doc.doc-code)
       ,input  ?
       ,input  ?
       ,input  no
       ,output ub.schet-fact-doc.fact-order
       ,output v-shift-end-fact-order
       ,output v-day-end-fact-order
      ).
    end.


    assign ii = 0 .
    define buffer buf_fin-ob-trn for ub.fin-ob-trn.
    find first buf_fin-ob-trn no-lock
      where buf_fin-ob-trn.doc-code       = buf_fin-ob.doc-code
        and buf_fin-ob-trn.host-code      = buf_fin-ob.host-code
        and buf_fin-ob-trn.doc-type       = "spc"
        and buf_fin-ob-trn.trn-doc-code   = string(buf_fin-ob.contract-code)
    no-error .
    if not available buf_fin-ob-trn then do: /* по обычному ФО */
      for each buf_fin-gds-part no-lock where
               buf_fin-gds-part.fin-ob-code = buf_fin-ob.doc-code and
               buf_fin-gds-part.host-code   = buf_fin-ob.host-code
               :
        find first buf_goods no-lock where buf_goods.gds-code = buf_fin-gds-part.gds-code .

        run fo-find-part (
          input  buf_fin-ob.host-code,
          input  buf_fin-ob.doc-code,
          input  buf_fin-gds-part.obj-type,
          input  buf_fin-gds-part.obj-code,
          input  buf_fin-gds-part.gds-code,
          input  buf_fin-gds-part.in-code,
          input  buf_fin-gds-part.part-code,
          input  buf_fin-gds-part.out-code,
          input  buf_fin-gds-part.doc-type,
          output TABLE temp-by-fo_parts ).

        for each  temp-by-fo_parts :
          empty temp-table tt-allsum.
          empty temp-table tt-clcparts.
          create tt-clcparts.
          buffer-copy temp-by-fo_parts to tt-clcparts.
          run clcprtsl_calc-parts in this-procedure ( input recid( tt-clcparts ), no, no, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ).
          find first tt-allsum where tt-allsum.sum-type = {&sum-general}.
          .
          ii  = ii + 1.
          create ub.schet-fact-line .
          assign
            ub.schet-fact-line.line-num      = ii
            ub.schet-fact-line.doc-code      = ub.schet-fact-doc.doc-code
            ub.schet-fact-line.db-num        = ub.schet-fact-doc.db-num
            ub.schet-fact-line.type          = {&fin-gen}
            ub.schet-fact-line.gds-code      = buf_goods.gds-code
            ub.schet-fact-line.gds-name      = buf_goods.gds-name
            ub.schet-fact-line.unit-base     = buf_goods.unit-base
            ub.schet-fact-line.fact-qnty     = tt-allsum.fact-qnty
            ub.schet-fact-line.sum-rubl      = tt-allsum.sum-dsc-rubl-acc - tt-allsum.vat-rubl-acc
            ub.schet-fact-line.sum-base      = tt-allsum.sum-dsc-base-acc - tt-allsum.vat-base-acc
            ub.schet-fact-line.price-rubl    = ub.schet-fact-line.sum-rubl / tt-allsum.fact-qnty
            ub.schet-fact-line.price-base    = ub.schet-fact-line.sum-base / tt-allsum.fact-qnty
            ub.schet-fact-line.VAT-rubl      = tt-allsum.vat-rubl-acc
            ub.schet-fact-line.VAT-base      = tt-allsum.vat-base-acc
            ub.schet-fact-line.sum-rubl-VAT  = tt-allsum.sum-dsc-rubl-acc
            ub.schet-fact-line.sum-base-VAT  = tt-allsum.sum-dsc-base-acc
            ub.schet-fact-line.VAT-pc        = temp-by-fo_parts.VAT-pc
            ub.schet-fact-line.excise        = tt-allsum.excise-rubl-acc
            ub.schet-fact-line.other-base    = tt-allsum.other-base-acc
            ub.schet-fact-line.other-rubl    = tt-allsum.other-rubl-acc
            ub.schet-fact-line.obj-type      = temp-by-fo_parts.obj-type
            ub.schet-fact-line.obj-code      = temp-by-fo_parts.obj-code
            ub.schet-fact-line.ext-doc-type  = ub.schet-fact-doc.ext-doc-type
            ub.schet-fact-line.fact-order    = ub.schet-fact-doc.fact-order
            ub.schet-fact-line.status_       = ub.schet-fact-doc.status_
            ub.schet-fact-line.host-code     = temp-by-fo_parts.host-code
            ub.schet-fact-line.in-code       = temp-by-fo_parts.in-code
            ub.schet-fact-line.part-code     = temp-by-fo_parts.part-code
            ub.schet-fact-doc.sum-rubl       = ub.schet-fact-doc.sum-rubl + tt-allsum.sum-dsc-rubl-acc
            ub.schet-fact-doc.sum-base       = ub.schet-fact-doc.sum-base + tt-allsum.sum-dsc-base-acc

            .
          create ub.factur-connect-line .
            assign
            ub.factur-connect-line.line-num  = ii
            ub.factur-connect-line.in-code   = temp-by-fo_parts.in-code
            ub.factur-connect-line.gds-code  = buf_goods.gds-code
            ub.factur-connect-line.part-code = temp-by-fo_parts.part-code
            ub.factur-connect-line.fact-qnty = tt-allsum.fact-qnty
            ub.factur-connect-line.connect-code = ub.factur-connect.connect-code
            ub.factur-connect-line.db-num       = ub.factur-connect.db-num
            ub.factur-connect-line.host-code    = ub.factur-connect.host-code
          .
          find first buf_parts-attr no-lock
            where buf_parts-attr.in-code   = temp-by-fo_parts.in-code
              and buf_parts-attr.gds-code  = buf_goods.gds-code
              and buf_parts-attr.part-code = temp-by-fo_parts.part-code
          no-error .
          if available buf_parts-attr then do:
            find first ub.country no-lock where ub.country.num-code = buf_parts-attr.country-code .
            assign
              ub.schet-fact-line.gtd           = buf_parts-attr.cst-code
              ub.schet-fact-line.country       = ub.country.short-name
            .
          end.

          if ub.schet-fact-doc.gtd     = "" then  assign ub.schet-fact-doc.gtd     = ub.schet-fact-line.gtd .
          if ub.schet-fact-doc.country = "" then  assign ub.schet-fact-doc.country = ub.schet-fact-line.country .

          if ub.schet-fact-line.VAT-pc < 1 then do:
            if temp-by-fo_parts.VAT-type = {&without-VAT} then do:
              assign
                ub.schet-fact-doc.sum-VAT-no-base = ub.schet-fact-doc.sum-VAT-no-base + ub.schet-fact-line.sum-base
                ub.schet-fact-doc.sum-VAT-no-rubl = ub.schet-fact-doc.sum-VAT-no-rubl + ub.schet-fact-line.sum-rubl
              .
            end.
            else do:
              assign
                ub.schet-fact-doc.sum-VAT-0-base = ub.schet-fact-doc.sum-VAT-0-base + ub.schet-fact-line.sum-base
                ub.schet-fact-doc.sum-VAT-0-rubl = ub.schet-fact-doc.sum-VAT-0-rubl + ub.schet-fact-line.sum-rubl
              .
            end.
          end.
          else do:
            if ub.schet-fact-line.VAT-pc < 11 then do:
              assign
                ub.schet-fact-doc.VAT-10-base      = ub.schet-fact-doc.VAT-10-base     + ub.schet-fact-line.VAT-base
                ub.schet-fact-doc.VAT-10-rubl      = ub.schet-fact-doc.VAT-10-rubl     + ub.schet-fact-line.VAT-rubl
                ub.schet-fact-doc.sum-VAT-10-base  = ub.schet-fact-doc.sum-VAT-10-base + ub.schet-fact-line.sum-base
                ub.schet-fact-doc.sum-VAT-10-rubl  = ub.schet-fact-doc.sum-VAT-10-rubl + ub.schet-fact-line.sum-rubl
              .
            end.
            else do:
              assign
                ub.schet-fact-doc.VAT-20-base      = ub.schet-fact-doc.VAT-20-base     + ub.schet-fact-line.VAT-base
                ub.schet-fact-doc.VAT-20-rubl      = ub.schet-fact-doc.VAT-20-rubl     + ub.schet-fact-line.VAT-rubl
                ub.schet-fact-doc.sum-VAT-20-base  = ub.schet-fact-doc.sum-VAT-20-base + ub.schet-fact-line.sum-base
                ub.schet-fact-doc.sum-VAT-20-rubl  = ub.schet-fact-doc.sum-VAT-20-rubl + ub.schet-fact-line.sum-rubl
              .
            end.
          end.
        end.
      end.
    end.
    else do: /* по ФО по спецификации */
      for each buf_fin-gds-part no-lock where buf_fin-gds-part.fin-ob-code = buf_fin-ob.doc-code :
        ii = ii + 1 .
        find first buf_goods no-lock where buf_goods.gds-code = buf_fin-gds-part.gds-code .
        create ub.schet-fact-line .
        assign
          ub.schet-fact-line.line-num      = ii
          ub.schet-fact-line.doc-code      = ub.schet-fact-doc.doc-code
          ub.schet-fact-line.db-num        = ub.schet-fact-doc.db-num
          ub.schet-fact-line.type          = {&fin-gen}
          ub.schet-fact-line.gds-code      = buf_goods.gds-code
          ub.schet-fact-line.gds-name      = buf_goods.gds-name
          ub.schet-fact-line.unit-base     = buf_goods.unit-base
          ub.schet-fact-line.fact-qnty     = buf_fin-gds-part.fact-qnty
          ub.schet-fact-line.sum-rubl      = buf_fin-gds-part.sum-rubl - buf_fin-gds-part.vat-rubl
          ub.schet-fact-line.sum-base      = buf_fin-gds-part.sum-base - buf_fin-gds-part.vat-base
          ub.schet-fact-line.VAT-rubl      = buf_fin-gds-part.vat-rubl
          ub.schet-fact-line.VAT-base      = buf_fin-gds-part.vat-base
          ub.schet-fact-line.sum-rubl-VAT  = buf_fin-gds-part.sum-rubl
          ub.schet-fact-line.sum-base-VAT  = buf_fin-gds-part.sum-base
          ub.schet-fact-line.price-rubl    = ub.schet-fact-line.sum-rubl / ub.schet-fact-line.fact-qnty
          ub.schet-fact-line.price-base    = ub.schet-fact-line.sum-base / ub.schet-fact-line.fact-qnty
          ub.schet-fact-line.VAT-pc        = buf_fin-gds-part.VAT-pc
          ub.schet-fact-line.excise        = 0
          ub.schet-fact-line.other-base    = buf_fin-gds-part.other-base
          ub.schet-fact-line.other-rubl    = buf_fin-gds-part.other-rubl
          ub.schet-fact-line.obj-type      = ub.schet-fact-doc.obj-type
          ub.schet-fact-line.obj-code      = ub.schet-fact-doc.obj-code
          ub.schet-fact-line.ext-doc-type  = ub.schet-fact-doc.ext-doc-type
          ub.schet-fact-line.fact-order    = ub.schet-fact-doc.fact-order
          ub.schet-fact-line.status_       = ub.schet-fact-doc.status_
          ub.schet-fact-line.host-code     = ub.schet-fact-doc.host-code
          ub.schet-fact-line.in-code       = buf_fin-gds-part.in-code
          ub.schet-fact-line.part-code     = buf_fin-gds-part.part-code

          ub.schet-fact-doc.sum-rubl       = ub.schet-fact-doc.sum-rubl + ub.schet-fact-line.sum-rubl-VAT
          ub.schet-fact-doc.sum-base       = ub.schet-fact-doc.sum-base + ub.schet-fact-line.sum-base-VAT

        .
        create ub.factur-connect-line .
        assign
          ub.factur-connect-line.line-num  = ii
          ub.factur-connect-line.in-code   = ub.schet-fact-line.in-code
          ub.factur-connect-line.gds-code  = buf_goods.gds-code
          ub.factur-connect-line.part-code = ub.schet-fact-line.part-code
          ub.factur-connect-line.fact-qnty = ub.schet-fact-line.fact-qnty
          ub.factur-connect-line.connect-code = ub.factur-connect.connect-code
          ub.factur-connect-line.db-num    = ub.factur-connect.db-num
          ub.factur-connect-line.host-code = ub.factur-connect.host-code
        .
        find first buf_parts-attr no-lock
          where buf_parts-attr.gds-code  = buf_fin-gds-part.gds-code
            and buf_parts-attr.part-code = buf_fin-gds-part.part-code
        no-error .
        if available buf_parts-attr then do:
          find first ub.country no-lock where ub.country.num-code = buf_parts-attr.country-code .
          assign
            ub.schet-fact-line.gtd           = buf_parts-attr.cst-code
            ub.schet-fact-line.country       = ub.country.short-name
          .
        end.

        if ub.schet-fact-doc.gtd     = "" then  assign ub.schet-fact-doc.gtd     = ub.schet-fact-line.gtd .
        if ub.schet-fact-doc.country = "" then  assign ub.schet-fact-doc.country = ub.schet-fact-line.country .

        if ub.schet-fact-line.VAT-pc < 1 then do:
          if temp-by-fo_parts.VAT-type = {&without-VAT} then do:
            assign
              ub.schet-fact-doc.sum-VAT-no-base = ub.schet-fact-doc.sum-VAT-no-base + ub.schet-fact-line.sum-base
              ub.schet-fact-doc.sum-VAT-no-rubl = ub.schet-fact-doc.sum-VAT-no-rubl + ub.schet-fact-line.sum-rubl
            .
          end.
          else do:
            assign
              ub.schet-fact-doc.sum-VAT-0-base = ub.schet-fact-doc.sum-VAT-0-base + ub.schet-fact-line.sum-base
              ub.schet-fact-doc.sum-VAT-0-rubl = ub.schet-fact-doc.sum-VAT-0-rubl + ub.schet-fact-line.sum-rubl
            .
          end.
        end.
        else do:
          if ub.schet-fact-line.VAT-pc < 11 then do:
            assign
              ub.schet-fact-doc.VAT-10-base      = ub.schet-fact-doc.VAT-10-base     + ub.schet-fact-line.VAT-base
              ub.schet-fact-doc.VAT-10-rubl      = ub.schet-fact-doc.VAT-10-rubl     + ub.schet-fact-line.VAT-rubl
              ub.schet-fact-doc.sum-VAT-10-base  = ub.schet-fact-doc.sum-VAT-10-base + ub.schet-fact-line.sum-base
              ub.schet-fact-doc.sum-VAT-10-rubl  = ub.schet-fact-doc.sum-VAT-10-rubl + ub.schet-fact-line.sum-rubl
            .
          end.
          else do:
            assign
              ub.schet-fact-doc.VAT-20-base      = ub.schet-fact-doc.VAT-20-base     + ub.schet-fact-line.VAT-base
              ub.schet-fact-doc.VAT-20-rubl      = ub.schet-fact-doc.VAT-20-rubl     + ub.schet-fact-line.VAT-rubl
              ub.schet-fact-doc.sum-VAT-20-base  = ub.schet-fact-doc.sum-VAT-20-base + ub.schet-fact-line.sum-base
              ub.schet-fact-doc.sum-VAT-20-rubl  = ub.schet-fact-doc.sum-VAT-20-rubl + ub.schet-fact-line.sum-rubl
            .
          end.
        end.
      end.
    end.
    if ii = 0 then do: /* нет товарных строк */
       return error "Нельзя создать счет-фактуру по ФО без товаров!" .
    end.

    assign
      ub.factur-connect.sum-rubl        = ub.schet-fact-doc.sum-rubl
      ub.factur-connect.sum-VAT-20-rubl = ub.schet-fact-doc.sum-VAT-20-rubl
      ub.factur-connect.VAT-20-rubl     = ub.schet-fact-doc.VAT-20-rubl
      ub.factur-connect.sum-VAT-10-rubl = ub.schet-fact-doc.sum-VAT-10-rubl
      ub.factur-connect.VAT-10-rubl     = ub.schet-fact-doc.VAT-10-rubl
      ub.factur-connect.sum-VAT-0-rubl  = ub.schet-fact-doc.sum-VAT-0-rubl
      ub.factur-connect.sum-VAT-no-rubl = ub.schet-fact-doc.sum-VAT-no-rubl
      ub.factur-connect.sum-base        = ub.schet-fact-doc.sum-base
      ub.factur-connect.sum-VAT-20-base = ub.schet-fact-doc.sum-VAT-20-base
      ub.factur-connect.VAT-20-base     = ub.schet-fact-doc.VAT-20-base
      ub.factur-connect.sum-VAT-10-base = ub.schet-fact-doc.sum-VAT-10-base
      ub.factur-connect.VAT-10-base     = ub.schet-fact-doc.VAT-10-base
      ub.factur-connect.sum-VAT-0-base  = ub.schet-fact-doc.sum-VAT-0-base
      ub.factur-connect.sum-VAT-no-base = ub.schet-fact-doc.sum-VAT-no-base
      p-list = " создан c-ф " + string(ub.schet-fact-doc.doc-code) +  " БД " +  string(ub.schet-fact-doc.db-num) + " договор " + string(ub.schet-fact-doc.contract-code) + {&new-line} .
    .
  end.
end procedure. /* gen-by-fin-ob */


procedure gen-by-fin-doc :
  do
  on error undo, return error return-value
  :
    define buffer buf_fin-doc   for ub.fin-doc .
    define buffer buf_fin-doc-tax    for ub.fin-doc-tax .
    define buffer buf_goods    for ub.goods .

    find first buf_fin-doc exclusive-lock where recid (buf_fin-doc) = p-ri no-error .
    if not available buf_fin-doc then return error .

    if buf_fin-doc.host-code <> v-cntxt-host-code-obj then
      return error substitute( "&1. Ошибка генерации. &2", vss-workfile, "Нельзя генерить счета-фактуры по документам не текущей фирмы!" ).

    if buf_sysconf.gen-s-f-office then do:
      if v-cntxt-db-num <> 0 then
        return error substitute( "&1. Ошибка генерации. &2", vss-workfile, "Генерация счетов-фактур на текущей фирме разрешена только в офисе!" ).
    end.
    else do:
      if v-cntxt-db-num <> buf_fin-doc.user-db-num-doc then
        return error substitute( "&1. Ошибка генерации. &2", vss-workfile, "Нельзя генерить счета-фактуры по документам не текущей БД!" ).
    end.

    if buf_fin-doc.contract-code > 0 then do:
      find first buf_contract no-lock
        where buf_contract.host-code     = buf_fin-doc.host-code
          and buf_contract.contract-code = buf_fin-doc.contract-code
      no-error .
      assign gen-stat = buf_contract.gen-factur .
      if gen-stat > 100 then
        assign
          is-fact  = yes
          gen-stat = gen-stat - 100
        .
      if gen-stat > 10 then
        assign
          is-delay  = yes
          gen-stat  = gen-stat - 10
          day-delay = buf_contract.gen-factur-srok
        .
      if gen-stat <> 3 then assign  is-fact  = no    is-delay = no  .

      if not (gen-stat = 3 or gen-stat = 13 or gen-stat = 103 or gen-stat = 113) then do:
         return error substitute( " По условиям договора Генерация счета-фактуры не предусмотрена по финансовому  документу" ).
      end.
    end.

    create ub.schet-fact-doc .
    assign
      ub.schet-fact-doc.doc-code      = string(next-value(s-sf-doc, {&db-name_schema}))
      ub.schet-fact-doc.db-num        = p-user-db-num
      ub.schet-fact-doc.doc-date      = if not is-delay then buf_fin-doc.fact-date else (buf_fin-doc.fact-date + day-delay)
      ub.schet-fact-doc.doc-type      = {&income}
      ub.schet-fact-doc.ext-doc-type  = buf_fin-doc.fin-ext-doc-type
      ub.schet-fact-doc.in-doc-type   = {&SFEDT_Fin_Doc}
      ub.schet-fact-doc.in-ext-doc-type = buf_fin-doc.fin-ext-doc-type
      ub.schet-fact-doc.host-code     = buf_fin-doc.host-code
      ub.schet-fact-doc.contract-code = buf_fin-doc.contract-code
      ub.schet-fact-doc.user-db-num   = p-user-db-num
      ub.schet-fact-doc.user-name     = p-user-name
      ub.schet-fact-doc.sys-date      = p-sys-date
      ub.schet-fact-doc.sys-time      = p-sys-time
      ub.schet-fact-doc.base-rate     = buf_fin-doc.base-rate
      ub.schet-fact-doc.base-scale    = buf_fin-doc.base-scale
      ub.schet-fact-doc.PS            = ""
      ub.schet-fact-doc.book-code     = ""
      ub.schet-fact-doc.Gruz-otprav   = "он же"
      ub.schet-fact-doc.gtd           = ""
      ub.schet-fact-doc.country       = ""
      ub.schet-fact-doc.in-date       = buf_fin-doc.fact-date
      ub.schet-fact-doc.in-doc-code   = string(buf_fin-doc.fin-doc-code)
      ub.schet-fact-doc.in-doc-date   = buf_fin-doc.doc-date
      ub.schet-fact-doc.plat-ras-doc  = string(buf_fin-doc.fin-doc-code) + " от " + string(buf_fin-doc.doc-date,"99/99/9999")
      ub.schet-fact-doc.obj-code      = buf_fin-doc.obj-code
      ub.schet-fact-doc.obj-type      = buf_fin-doc.obj-type
      ub.schet-fact-doc.pay-date      = buf_fin-doc.fact-date
      ub.schet-fact-doc.status_       = if is-fact = no then {&fin-new} else {&fact}
      ub.schet-fact-doc.office        = yes
    .
    if buf_fin-doc.payer-type = {&cmp} and buf_fin-doc.payer-code = buf_fin-doc.host-code then do: /* платим мы */
      assign
        ub.schet-fact-doc.cli-type      = buf_fin-doc.receiver-type
        ub.schet-fact-doc.cli-code      = buf_fin-doc.receiver-code
        ub.schet-fact-doc.cli-name      = buf_fin-doc.receiver-name
        ub.schet-fact-doc.cli-inn       = buf_fin-doc.receiver-inn
        ub.schet-fact-doc.cli-kpp       = buf_fin-doc.receiver-kpp
        ub.schet-fact-doc.own-name      = buf_fin-doc.payer-name
        ub.schet-fact-doc.own-inn       = buf_fin-doc.payer-inn
        ub.schet-fact-doc.own-kpp       = buf_fin-doc.payer-kpp
      .
    end.
    else do:
      assign
        ub.schet-fact-doc.cli-type      = buf_fin-doc.payer-type
        ub.schet-fact-doc.cli-code      = buf_fin-doc.payer-code
        ub.schet-fact-doc.cli-name      = buf_fin-doc.payer-name
        ub.schet-fact-doc.cli-inn       = buf_fin-doc.payer-inn
        ub.schet-fact-doc.cli-kpp       = buf_fin-doc.payer-kpp
        ub.schet-fact-doc.own-name      = buf_fin-doc.receiver-name
        ub.schet-fact-doc.own-inn       = buf_fin-doc.receiver-inn
        ub.schet-fact-doc.own-kpp       = buf_fin-doc.receiver-kpp
      .
    end.

    find first ub.firm no-lock where ub.firm.firm-code = buf_fin-doc.host-code no-error .
    assign ub.schet-fact-doc.Gruz-poluch = substitute( "&1 &2", caps( ub.schet-fact-doc.own-name ), ub.firm.post-addr1 ) .

    run Get-address ( input {&cmp}, input ub.schet-fact-doc.host-code, output ub.schet-fact-doc.own-address) .
    run Get-address ( input ub.schet-fact-doc.cli-type, input ub.schet-fact-doc.cli-code, output ub.schet-fact-doc.cli-address) .

    create ub.factur-connect .
    assign
      buf_fin-doc.factur-date      = ub.schet-fact-doc.sys-date
      buf_fin-doc.cr-factur        = yes
      /*buf_fin-doc.need-factur      = 0*/
      ub.factur-connect.db-num        = ub.schet-fact-doc.db-num
      ub.factur-connect.user-db-num   = ub.schet-fact-doc.user-db-num
      ub.factur-connect.user-name     = ub.schet-fact-doc.user-name
      ub.factur-connect.sys-date      = ub.schet-fact-doc.sys-date
      ub.factur-connect.sys-time      = ub.schet-fact-doc.sys-time
      ub.factur-connect.factur-doc-code = ub.schet-fact-doc.doc-code
      ub.factur-connect.doc-type      = ub.schet-fact-doc.doc-type
      ub.factur-connect.host-code     = ub.schet-fact-doc.host-code
      ub.factur-connect.trn-doc-code  = string(buf_fin-doc.fin-doc-code)
      ub.factur-connect.PS            = ""
      ub.factur-connect.connect-code = next-value(s-fin-connect, {&db-name_schema})
    .

    if is-fact then do:
      assign
        ub.schet-fact-doc.fact-date         = ub.schet-fact-doc.sys-date
        ub.schet-fact-doc.fact-time         = int(ub.schet-fact-doc.sys-time)
        ub.schet-fact-doc.fact-user-db-num  = ub.schet-fact-doc.user-db-num
        ub.schet-fact-doc.fact-user-name    = ub.schet-fact-doc.user-name
      .
      run factord (
        input  ub.schet-fact-doc.fact-date
       ,input  ub.schet-fact-doc.fact-time
       ,input  int(ub.schet-fact-doc.doc-code)
       ,input  ?
       ,input  ?
       ,input  no
       ,output ub.schet-fact-doc.fact-order
       ,output v-shift-end-fact-order
       ,output v-day-end-fact-order
      ).
    end.

    assign ii = 0 .

    for each buf_fin-doc-tax no-lock where buf_fin-doc-tax.host-code = buf_fin-doc.host-code and buf_fin-doc-tax.fin-doc-code = buf_fin-doc.fin-doc-code :
      find first ub.schet-fact-line exclusive-lock
        where ub.schet-fact-line.doc-code   = ub.schet-fact-doc.doc-code
          and ub.schet-fact-line.host-code  = ub.schet-fact-doc.host-code
          and ub.schet-fact-line.VAT-pc     = buf_fin-doc-tax.VAT-pc
      no-error .
      if not available ub.schet-fact-line then do:
        ii                            = ii + 1 .
        create ub.schet-fact-line .
        assign
          ub.schet-fact-line.line-num      = ii
          ub.schet-fact-line.doc-code      = ub.schet-fact-doc.doc-code
          ub.schet-fact-line.db-num        = ub.schet-fact-doc.db-num
          ub.schet-fact-line.type          = {&fin-new}
          ub.schet-fact-line.gtd           = ""
          ub.schet-fact-line.country       = ""
          ub.schet-fact-line.gds-code      = ?
          ub.schet-fact-line.gds-name      = "по платежу НДС " + string(buf_fin-doc-tax.VAT-pc) + " %"
          ub.schet-fact-line.fact-qnty     = 1
          ub.schet-fact-line.ext-doc-type  = ub.schet-fact-doc.ext-doc-type
          ub.schet-fact-line.fact-order    = ub.schet-fact-doc.fact-order
          ub.schet-fact-line.status_       = ub.schet-fact-doc.status_
          ub.schet-fact-line.host-code     = buf_fin-doc.host-code
          ub.schet-fact-line.in-code       = string(buf_fin-doc.fin-doc-code)
          ub.schet-fact-doc.office         = yes
          ub.schet-fact-line.VAT-pc        = buf_fin-doc-tax.VAT-pc
          ub.schet-fact-line.other-base    = 0
          ub.schet-fact-line.other-rubl    = 0
          ub.schet-fact-line.excise        = 0
        .
        create ub.factur-connect-line .
        assign
        ub.factur-connect-line.line-num      = ii
        ub.factur-connect-line.in-code   = ub.schet-fact-line.in-code
        ub.factur-connect-line.gds-code  = ub.schet-fact-line.gds-code
        ub.factur-connect-line.part-code = ub.schet-fact-line.part-code
        ub.factur-connect-line.fact-qnty = 1
        ub.factur-connect-line.connect-code = ub.factur-connect.connect-code
        ub.factur-connect-line.db-num    = ub.factur-connect.db-num
        ub.factur-connect-line.host-code = ub.factur-connect.host-code
        .
      end.
      assign
        ub.schet-fact-line.sum-rubl      = ub.schet-fact-line.sum-rubl     + buf_fin-doc-tax.sum-line-rubl - buf_fin-doc-tax.sum-vat-line-rubl
        ub.schet-fact-line.sum-base      = ub.schet-fact-line.sum-base     + buf_fin-doc-tax.sum-line-base - buf_fin-doc-tax.sum-vat-line-base
        ub.schet-fact-line.price-rubl    = ub.schet-fact-line.price-rubl   + buf_fin-doc-tax.sum-line-rubl - buf_fin-doc-tax.sum-vat-line-rubl
        ub.schet-fact-line.price-base    = ub.schet-fact-line.price-base   + buf_fin-doc-tax.sum-line-base - buf_fin-doc-tax.sum-vat-line-base
        ub.schet-fact-line.VAT-rubl      = ub.schet-fact-line.VAT-rubl     + buf_fin-doc-tax.sum-vat-line-rubl
        ub.schet-fact-line.VAT-base      = ub.schet-fact-line.VAT-base     + buf_fin-doc-tax.sum-vat-line-base
        ub.schet-fact-line.sum-rubl-VAT  = ub.schet-fact-line.sum-rubl-VAT + buf_fin-doc-tax.sum-line-rubl
        ub.schet-fact-line.sum-base-VAT  = ub.schet-fact-line.sum-base-VAT + buf_fin-doc-tax.sum-line-base
        ub.schet-fact-doc.sum-rubl       = ub.schet-fact-doc.sum-rubl + buf_fin-doc-tax.sum-line-rubl
        ub.schet-fact-doc.sum-base       = ub.schet-fact-doc.sum-base + buf_fin-doc-tax.sum-line-base
      .

      if ub.schet-fact-line.VAT-pc < 1 then do:
        if buf_fin-doc-tax.with-vat = no then do:
          assign
            ub.schet-fact-doc.sum-VAT-no-base = ub.schet-fact-doc.sum-VAT-no-base + ub.schet-fact-line.sum-base
            ub.schet-fact-doc.sum-VAT-no-rubl = ub.schet-fact-doc.sum-VAT-no-rubl + ub.schet-fact-line.sum-rubl
          .
        end.
        else do:
          assign
            ub.schet-fact-doc.sum-VAT-0-base = ub.schet-fact-doc.sum-VAT-0-base + ub.schet-fact-line.sum-base
            ub.schet-fact-doc.sum-VAT-0-rubl = ub.schet-fact-doc.sum-VAT-0-rubl + ub.schet-fact-line.sum-rubl
          .
        end.
      end.
      else do:
        if ub.schet-fact-line.VAT-pc < 11 then do:
          assign
            ub.schet-fact-doc.VAT-10-base      = ub.schet-fact-doc.VAT-10-base     + ub.schet-fact-line.VAT-base
            ub.schet-fact-doc.VAT-10-rubl      = ub.schet-fact-doc.VAT-10-rubl     + ub.schet-fact-line.VAT-rubl
            ub.schet-fact-doc.sum-VAT-10-base  = ub.schet-fact-doc.sum-VAT-10-base + ub.schet-fact-line.sum-base
            ub.schet-fact-doc.sum-VAT-10-rubl  = ub.schet-fact-doc.sum-VAT-10-rubl + ub.schet-fact-line.sum-rubl
          .
        end.
        else do:
          assign
            ub.schet-fact-doc.VAT-20-base      = ub.schet-fact-doc.VAT-20-base     + ub.schet-fact-line.VAT-base
            ub.schet-fact-doc.VAT-20-rubl      = ub.schet-fact-doc.VAT-20-rubl     + ub.schet-fact-line.VAT-rubl
            ub.schet-fact-doc.sum-VAT-20-base  = ub.schet-fact-doc.sum-VAT-20-base + ub.schet-fact-line.sum-base
            ub.schet-fact-doc.sum-VAT-20-rubl  = ub.schet-fact-doc.sum-VAT-20-rubl + ub.schet-fact-line.sum-rubl
          .
        end.
      end.
    end.

    assign
      p-list = " создан c-ф " + string(ub.schet-fact-doc.doc-code) +  " БД " +  string(ub.schet-fact-doc.db-num) + " договор " + string(ub.schet-fact-doc.contract-code) + {&new-line}
      ub.factur-connect.sum-rubl        = ub.schet-fact-doc.sum-rubl
      ub.factur-connect.sum-VAT-20-rubl = ub.schet-fact-doc.sum-VAT-20-rubl
      ub.factur-connect.VAT-20-rubl     = ub.schet-fact-doc.VAT-20-rubl
      ub.factur-connect.sum-VAT-10-rubl = ub.schet-fact-doc.sum-VAT-10-rubl
      ub.factur-connect.VAT-10-rubl     = ub.schet-fact-doc.VAT-10-rubl
      ub.factur-connect.sum-VAT-0-rubl  = ub.schet-fact-doc.sum-VAT-0-rubl
      ub.factur-connect.sum-VAT-no-rubl = ub.schet-fact-doc.sum-VAT-no-rubl
      ub.factur-connect.sum-base        = ub.schet-fact-doc.sum-base
      ub.factur-connect.sum-VAT-20-base = ub.schet-fact-doc.sum-VAT-20-base
      ub.factur-connect.VAT-20-base     = ub.schet-fact-doc.VAT-20-base
      ub.factur-connect.sum-VAT-10-base = ub.schet-fact-doc.sum-VAT-10-base
      ub.factur-connect.VAT-10-base     = ub.schet-fact-doc.VAT-10-base
      ub.factur-connect.sum-VAT-0-base  = ub.schet-fact-doc.sum-VAT-0-base
      ub.factur-connect.sum-VAT-no-base = ub.schet-fact-doc.sum-VAT-no-base
    .
    /* вызвать новости */
    if v-cntxt-db-num <> 0 then assign db-list = "0" .
    else do:
      if buf_fin-doc.user-db-num-doc <> 0 then assign db-list = string(buf_fin-doc.user-db-num-doc) .
    end.
    if db-list <> "" then do:
      run nws/cr-route.p ( input {&send-cmd}
                ,input "command":U + {&delim-nws} + "fin-doc-factur-date":U + {&delim-nws} + string(buf_fin-doc.fin-doc-code) + {&delim-nws} + string(buf_fin-doc.host-code) + {&delim-nws} + string(p-sys-date) + {&delim-nws} + "yes" + {&delim-nws} + "1"
                ,input ?
                ,input db-list
               ).
    end.
  end.
end procedure. /* gen-by-fin-doc */


procedure Get-address :
  do on error undo, return error return-value :
    define input  parameter  p-cli-type like ub.clients.obj-type .
    define input  parameter  p-cli-code like ub.clients.obj-code .
    define output parameter  p-address  as character no-undo .

    define buffer buf_firm   for ub.firm.
    define buffer buf_person for ub.person.

    if p-cli-type = {&cmp} then do:
      find first buf_firm no-lock where buf_firm.firm-code = p-cli-code no-error.
      if available buf_firm then assign  p-address = trim(buf_firm.addres1) + " " + trim(buf_firm.addres2) .
    end.
    else do:
      find first buf_person no-lock where buf_person.psn-code = p-cli-code no-error.
      if available buf_person then assign p-address = buf_person.address  .
    end.
  end.
end procedure. /* Get-address */


procedure gen-by-add-doc :
  do
  on error undo, return error return-value
  :
    define buffer buf_add-doc   for ub.add-doc .
    define buffer buf_add-line    for ub.add-line .
    define buffer buf2_add-line    for ub.add-line .
    define buffer buf_goods    for ub.goods .

    find first buf_add-doc exclusive-lock where recid (buf_add-doc) = p-ri no-error .
    if not available buf_add-doc then return error .

    if buf_add-doc.host-code <> v-cntxt-host-code-obj then
      return error substitute( "&1. Ошибка генерации. &2", vss-workfile, "Нельзя генерить счета-фактуры по документам не текущей фирмы!" ).

    if buf_sysconf.gen-s-f-office then do:
      if v-cntxt-db-num <> 0 then
        return error substitute( "&1. Ошибка генерации. &2", vss-workfile, "Генерация счетов-фактур на текущей фирме разрешена только в офисе!" ).
    end.
    else do:
    end.

    run torgconf-get-self-param ( input buf_add-doc.obj-type, input buf_add-doc.obj-code, 0 ) .

    for each buf_add-line no-lock  where
             buf_add-line.doc-code =  buf_add-doc.doc-code
        break by buf_add-line.contract-code
              by buf_add-line.gds-code
        :

    if first-of(buf_add-line.contract-code) then do:

    run torgconf-get-cli-param ( input buf_add-line.host-code, input buf_add-line.cli-type, input buf_add-line.cli-code, 0) .

    if buf_add-line.contract-code > 0 then do:
      find first buf_contract no-lock
        where buf_contract.host-code     = buf_add-line.host-code
          and buf_contract.contract-code = buf_add-line.contract-code
      no-error .
      assign gen-stat = buf_contract.gen-factur .

      if gen-stat > 100 then
        assign
          is-fact  = yes
          gen-stat = gen-stat - 100
        .
      if gen-stat > 10 then
        assign
          is-delay  = yes
          gen-stat  = gen-stat - 10
          day-delay = buf_contract.gen-factur-srok
        .
      if gen-stat <> 1 then
         assign
           is-fact  = no
           is-delay = no
         .
      if not (gen-stat = 1 or gen-stat = 11 or gen-stat = 101 or gen-stat = 111 or gen-stat = 0 ) then do:
             return error " По условиям договора Генерация счета-фактуры не предусмотрена " .
         end.

    end.

    create ub.schet-fact-doc .
    assign
      ub.schet-fact-doc.doc-code      = string(next-value(s-sf-doc, {&db-name_schema}))
      ub.schet-fact-doc.db-num        = p-user-db-num
      ub.schet-fact-doc.doc-date      = if not is-delay then buf_add-doc.fact-date else (buf_add-doc.fact-date + day-delay)
      ub.schet-fact-doc.doc-type      = {&income}
      ub.schet-fact-doc.ext-doc-type  = {&SFEDT_add_doc}
      ub.schet-fact-doc.in-doc-type   = {&SFEDT_add_doc}
      ub.schet-fact-doc.in-ext-doc-type = {&SFEDT_add_doc}
      ub.schet-fact-doc.host-code     = buf_add-line.host-code
      ub.schet-fact-doc.contract-code = buf_add-line.contract-code
      ub.schet-fact-doc.user-db-num   = p-user-db-num
      ub.schet-fact-doc.user-name     = p-user-name
      ub.schet-fact-doc.sys-date      = p-sys-date
      ub.schet-fact-doc.sys-time      = p-sys-time
      ub.schet-fact-doc.base-rate     = buf_add-doc.base-rate
      ub.schet-fact-doc.base-scale    = buf_add-doc.base-scale
      ub.schet-fact-doc.PS            = ""
      ub.schet-fact-doc.book-code     = ""
      ub.schet-fact-doc.gtd           = ""
      ub.schet-fact-doc.country       = ""
      ub.schet-fact-doc.in-date       = buf_add-doc.fact-date
      ub.schet-fact-doc.in-doc-code   = string(buf_add-doc.doc-code)
      ub.schet-fact-doc.in-doc-date   = buf_add-doc.doc-date
      ub.schet-fact-doc.plat-ras-doc  = string(buf_add-doc.doc-code) + " от " + string(buf_add-doc.doc-date,"99/99/9999")
      ub.schet-fact-doc.obj-code      = buf_add-doc.obj-code
      ub.schet-fact-doc.obj-type      = buf_add-doc.obj-type
      ub.schet-fact-doc.pay-date      = buf_add-doc.fact-date
      ub.schet-fact-doc.status_       = if is-fact = no then {&fin-new} else {&fact}
      ub.schet-fact-doc.office        = yes
    .
    define variable v-cli-name as character no-undo .

      find first buf_clients no-lock
        where buf_clients.obj-type = buf_add-line.cli-type
          and buf_clients.obj-code = buf_add-line.cli-code
      no-error .
      if not  error-status :error  then v-cli-name = buf_clients.obj-name.
      else v-cli-name = '' .

      assign
        ub.schet-fact-doc.cli-inn       = v-torgconf-cli-inn
        ub.schet-fact-doc.cli-kpp       = v-torgconf-cli-kpp
        ub.schet-fact-doc.cli-type      = buf_add-line.cli-type
        ub.schet-fact-doc.cli-code      = buf_add-line.cli-code
        ub.schet-fact-doc.cli-name      = v-cli-name
        ub.schet-fact-doc.own-inn       = v-torgconf-self-host-inn
        ub.schet-fact-doc.own-name      = v-torgconf-self-host-name
        ub.schet-fact-doc.own-kpp       = v-torgconf-self-host-kpp
        ub.schet-fact-doc.Gruz-otprav   = "он же"
        ub.schet-fact-doc.Gruz-poluch   = substitute( "&1 &2 &3", caps( v-torgconf-self-host-name ),  v-torgconf-self-host-post-addres, v-torgconf-self-host-phone )
     .
    find first ub.firm no-lock where ub.firm.firm-code = buf_add-doc.host-code no-error .
    assign ub.schet-fact-doc.Gruz-poluch = substitute( "&1 &2", caps( ub.schet-fact-doc.own-name ), ub.firm.post-addr1 ) .

    run Get-address ( input {&cmp}, input ub.schet-fact-doc.host-code, output ub.schet-fact-doc.own-address) .
    run Get-address ( input ub.schet-fact-doc.cli-type, input ub.schet-fact-doc.cli-code, output ub.schet-fact-doc.cli-address) .

    create ub.factur-connect .
    assign
      buf_add-doc.factur-date      = ub.schet-fact-doc.sys-date
      buf_add-doc.cr-factur        = yes
      /*buf_add-doc.need-factur      = 0*/
      ub.factur-connect.db-num        = ub.schet-fact-doc.db-num
      ub.factur-connect.user-db-num   = ub.schet-fact-doc.user-db-num
      ub.factur-connect.user-name     = ub.schet-fact-doc.user-name
      ub.factur-connect.sys-date      = ub.schet-fact-doc.sys-date
      ub.factur-connect.sys-time      = ub.schet-fact-doc.sys-time
      ub.factur-connect.factur-doc-code = ub.schet-fact-doc.doc-code
      ub.factur-connect.doc-type      = ub.schet-fact-doc.doc-type
      ub.factur-connect.host-code     = ub.schet-fact-doc.host-code
      ub.factur-connect.trn-doc-code  = string(buf_add-doc.doc-code)
      ub.factur-connect.PS            = ""
      ub.factur-connect.connect-code = next-value(s-fin-connect, {&db-name_schema})
    .

      if is-fact then do:
        assign
          ub.schet-fact-doc.fact-date         = ub.schet-fact-doc.sys-date
          ub.schet-fact-doc.fact-time         = int(ub.schet-fact-doc.sys-time)
          ub.schet-fact-doc.fact-user-db-num  = ub.schet-fact-doc.user-db-num
          ub.schet-fact-doc.fact-user-name    = ub.schet-fact-doc.user-name
        .
        run factord (
          input  ub.schet-fact-doc.fact-date
        ,input  ub.schet-fact-doc.fact-time
        ,input  int(ub.schet-fact-doc.doc-code)
        ,input  ?
        ,input  ?
        ,input  no
        ,output ub.schet-fact-doc.fact-order
        ,output v-shift-end-fact-order
        ,output v-day-end-fact-order
        ).
      end.
    /* строки */
    run proc-line-add (
        buf_add-line.doc-code      ,
        buf_add-line.contract-code ,
        buf_add-line.host-code
        ).
    assign
      p-list = " создан c-ф " + string(ub.schet-fact-doc.doc-code) +  " БД " +  string(ub.schet-fact-doc.db-num) + " договор " + string(ub.schet-fact-doc.contract-code) + {&new-line}
      ub.factur-connect.sum-rubl        = ub.schet-fact-doc.sum-rubl
      ub.factur-connect.sum-VAT-20-rubl = ub.schet-fact-doc.sum-VAT-20-rubl
      ub.factur-connect.VAT-20-rubl     = ub.schet-fact-doc.VAT-20-rubl
      ub.factur-connect.sum-VAT-10-rubl = ub.schet-fact-doc.sum-VAT-10-rubl
      ub.factur-connect.VAT-10-rubl     = ub.schet-fact-doc.VAT-10-rubl
      ub.factur-connect.sum-VAT-0-rubl  = ub.schet-fact-doc.sum-VAT-0-rubl
      ub.factur-connect.sum-VAT-no-rubl = ub.schet-fact-doc.sum-VAT-no-rubl
      ub.factur-connect.sum-base        = ub.schet-fact-doc.sum-base
      ub.factur-connect.sum-VAT-20-base = ub.schet-fact-doc.sum-VAT-20-base
      ub.factur-connect.VAT-20-base     = ub.schet-fact-doc.VAT-20-base
      ub.factur-connect.sum-VAT-10-base = ub.schet-fact-doc.sum-VAT-10-base
      ub.factur-connect.VAT-10-base     = ub.schet-fact-doc.VAT-10-base
      ub.factur-connect.sum-VAT-0-base  = ub.schet-fact-doc.sum-VAT-0-base
      ub.factur-connect.sum-VAT-no-base = ub.schet-fact-doc.sum-VAT-no-base
    .
    /* вызвать новости */
        if v-cntxt-db-num <> 0 then assign db-list = "0" .
        else do:
          if buf_add-doc.cr-db-num <> 0 then assign db-list = string(buf_add-doc.cr-db-num) .
        end.
        if db-list <> "" then do:

    /* ???
        run nws/cr-route.p ( input {&send-cmd}
                    ,input "command":U + {&delim-nws} + "add-doc-factur-date":U + {&delim-nws} + string(buf_add-doc.doc-code) + {&delim-nws} + string(buf_add-doc.host-code) + {&delim-nws} + string(p-sys-date) + {&delim-nws} + "yes" + {&delim-nws} + "1"
                    ,input ?
                    ,input db-list
                  ).
    */
        end.
  end.

  end. /* foreach buf_add-line */
  end.
end procedure. /* gen-by-add-doc */

procedure proc-line-add :
define input  parameter p-doc-code      as character no-undo .
define input  parameter p-contract-code as integer   no-undo .
define input  parameter p-host-code     as integer   no-undo .

define buffer buf2_add-line for ub.add-line  .
define buffer buf_goods for ub.goods  .
  do
  on error undo, return error return-value
  :
    assign ii = 0 .
    for each buf2_add-line no-lock where
             buf2_add-line.doc-code      = p-doc-code and
             buf2_add-line.contract-code = p-contract-code and
             buf2_add-line.host-code     = p-host-code
    :
    find first ub.schet-fact-line exclusive-lock
          where ub.schet-fact-line.doc-code   = ub.schet-fact-doc.doc-code
            and ub.schet-fact-line.host-code  = p-host-code
            and ub.schet-fact-line.vat-pc     = buf2_add-line.vat-pc
            and ub.schet-fact-line.gds-code   = buf2_add-line.gds-code
      no-error .
      if not available ub.schet-fact-line then do:
         find first buf_goods no-lock where
                    buf_goods.gds-code = buf2_add-line.gds-code  .

        ii = ii + 1 .
        create ub.schet-fact-line .
        assign
          ub.schet-fact-line.line-num      = ii
          ub.schet-fact-line.doc-code      = ub.schet-fact-doc.doc-code
          ub.schet-fact-line.db-num        = ub.schet-fact-doc.db-num
          ub.schet-fact-line.type          = {&fin-new}
          ub.schet-fact-line.gtd           = ""
          ub.schet-fact-line.country       = ""
          ub.schet-fact-line.gds-code      = buf2_add-line.gds-code
          ub.schet-fact-line.gds-name      = buf_goods.gds-name
          ub.schet-fact-line.fact-qnty     = 1
          ub.schet-fact-line.ext-doc-type  = ub.schet-fact-doc.ext-doc-type
          ub.schet-fact-line.fact-order    = ub.schet-fact-doc.fact-order
          ub.schet-fact-line.status_       = ub.schet-fact-doc.status_
          ub.schet-fact-line.host-code     = p-host-code
          ub.schet-fact-line.in-code       = p-doc-code
          ub.schet-fact-doc.office         = yes
          ub.schet-fact-line.VAT-pc        = buf2_add-line.VAT-pc
          ub.schet-fact-line.other-base    = 0
          ub.schet-fact-line.other-rubl    = 0
          ub.schet-fact-line.excise        = 0
        .
        create ub.factur-connect-line .
        assign
        ub.factur-connect-line.line-num      = ii
        ub.factur-connect-line.in-code   = ub.schet-fact-line.in-code
        ub.factur-connect-line.gds-code  = ub.schet-fact-line.gds-code
        ub.factur-connect-line.part-code = ub.schet-fact-line.part-code
        ub.factur-connect-line.fact-qnty = 1
        ub.factur-connect-line.connect-code = ub.factur-connect.connect-code
        ub.factur-connect-line.db-num    = ub.factur-connect.db-num
        ub.factur-connect-line.host-code = ub.factur-connect.host-code
        .
      end.
      assign
        ub.schet-fact-line.sum-rubl      = ub.schet-fact-line.sum-rubl     + buf2_add-line.sum-rubl - buf2_add-line.vat-rubl
        ub.schet-fact-line.sum-base      = ub.schet-fact-line.sum-base     + buf2_add-line.sum-base - buf2_add-line.vat-base
        ub.schet-fact-line.price-rubl    = ub.schet-fact-line.price-rubl   + buf2_add-line.sum-rubl - buf2_add-line.vat-rubl
        ub.schet-fact-line.price-base    = ub.schet-fact-line.price-base   + buf2_add-line.sum-base - buf2_add-line.vat-base
        ub.schet-fact-line.VAT-rubl      = ub.schet-fact-line.VAT-rubl     + buf2_add-line.vat-rubl
        ub.schet-fact-line.VAT-base      = ub.schet-fact-line.VAT-base     + buf2_add-line.vat-base
        ub.schet-fact-line.sum-rubl-VAT  = ub.schet-fact-line.sum-rubl-VAT + buf2_add-line.sum-rubl
        ub.schet-fact-line.sum-base-VAT  = ub.schet-fact-line.sum-base-VAT + buf2_add-line.sum-base
        ub.schet-fact-doc.sum-rubl       = ub.schet-fact-doc.sum-rubl + buf2_add-line.sum-rubl
        ub.schet-fact-doc.sum-base       = ub.schet-fact-doc.sum-base + buf2_add-line.sum-base
      .

      if ub.schet-fact-line.VAT-pc < 1 then do:
        if buf2_add-line.VAT-pc > 0 then do:
          assign
            ub.schet-fact-doc.sum-VAT-no-base = ub.schet-fact-doc.sum-VAT-no-base + ub.schet-fact-line.sum-base
            ub.schet-fact-doc.sum-VAT-no-rubl = ub.schet-fact-doc.sum-VAT-no-rubl + ub.schet-fact-line.sum-rubl
          .
        end.
        else do:
          assign
            ub.schet-fact-doc.sum-VAT-0-base = ub.schet-fact-doc.sum-VAT-0-base + ub.schet-fact-line.sum-base
            ub.schet-fact-doc.sum-VAT-0-rubl = ub.schet-fact-doc.sum-VAT-0-rubl + ub.schet-fact-line.sum-rubl
          .
        end.
      end.
      else do:
        if ub.schet-fact-line.VAT-pc < 11 then do:
          assign
            ub.schet-fact-doc.VAT-10-base      = ub.schet-fact-doc.VAT-10-base     + ub.schet-fact-line.VAT-base
            ub.schet-fact-doc.VAT-10-rubl      = ub.schet-fact-doc.VAT-10-rubl     + ub.schet-fact-line.VAT-rubl
            ub.schet-fact-doc.sum-VAT-10-base  = ub.schet-fact-doc.sum-VAT-10-base + ub.schet-fact-line.sum-base
            ub.schet-fact-doc.sum-VAT-10-rubl  = ub.schet-fact-doc.sum-VAT-10-rubl + ub.schet-fact-line.sum-rubl
          .
        end.
        else do:
          assign
            ub.schet-fact-doc.VAT-20-base      = ub.schet-fact-doc.VAT-20-base     + ub.schet-fact-line.VAT-base
            ub.schet-fact-doc.VAT-20-rubl      = ub.schet-fact-doc.VAT-20-rubl     + ub.schet-fact-line.VAT-rubl
            ub.schet-fact-doc.sum-VAT-20-base  = ub.schet-fact-doc.sum-VAT-20-base + ub.schet-fact-line.sum-base
            ub.schet-fact-doc.sum-VAT-20-rubl  = ub.schet-fact-doc.sum-VAT-20-rubl + ub.schet-fact-line.sum-rubl
          .
        end.
      end.
    end.

  end.

end procedure. /* line-add */