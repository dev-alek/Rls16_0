block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ssetvat.p $
$Archive: utl/ssetvat.p $

Изменение НДС в спецификации по 1 договору

Автор: Чернова Светлана Александровна
Дата создания: 05/13/10
Author: Svetlana Chernova
Creation date: 05/13/10

*/

define input parameter p-contract-code as integer   no-undo .
define input parameter p-host-code as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ssetvat.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/ssetvat.p $":U .
define variable vss-description as character no-undo init "Заполнение новых полей спецификации к договору".

{ cmp/str-glbl.i }
{ cmp/library.i }


main_block:
do
on error  undo main_block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
on stop   undo main_block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main_block, return error substitute( "&1. endkey", vss-workfile )
:
  define variable v-vat-pc as decimal   no-undo .
  define variable v-fo     as decimal   no-undo .

  define buffer buf_tax-rate-gds for ub.tax-rate-gds .

  assign
    v-fo = integer(date(1, 1, 5000))
  .


  for each ub.c-contract-specif exclusive-lock
     where ub.c-contract-specif.contract-num = p-contract-code and
           ub.c-contract-specif.host-code = p-host-code
  on error  undo main_block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  :
    find first ub.clients no-lock
      where ub.clients.host-code = ub.c-contract-specif.host-code
      no-error .
    find first ub.goods no-lock
      where ub.goods.gds-code = ub.c-contract-specif.gds-code
      no-error .
    if available ub.goods then do:
      find last buf_tax-rate-gds no-lock
        where buf_tax-rate-gds.gds-code   = ub.goods.gds-code
          and buf_tax-rate-gds.tax-code   = 1
          and buf_tax-rate-gds.host-code  = 0
          and buf_tax-rate-gds.obj-type   = ""
          and buf_tax-rate-gds.obj-code   = 0
          and buf_tax-rate-gds.fact-order <= v-fo
        no-error .
        if available buf_tax-rate-gds then do:
          run pftxvalo (
              input ?
            , input buf_tax-rate-gds.tax-code
            , input buf_tax-rate-gds.rate-code
            , input v-fo
            , input ub.c-contract-specif.host-code
            , input (if available ub.clients then ub.clients.obj-type else "":U )
            , input (if available ub.clients then ub.clients.obj-code else 0 )
            , output v-vat-pc
          ) .
        end.
        else do:
          assign
            v-vat-pc = 18
          .
        end.
      assign
        ub.c-contract-specif.gds-name      = ub.goods.gds-name
        ub.c-contract-specif.artic         = ub.goods.artic
        ub.c-contract-specif.prod-type     = ub.goods.prod-type
        ub.c-contract-specif.prod-code     = ub.goods.prod-code
        ub.c-contract-specif.unit-base     = ub.goods.unit-base
        ub.c-contract-specif.cli-base-rate = ub.goods.cli-base-rate
        ub.c-contract-specif.VAT-type      = {&inc-vat}
        ub.c-contract-specif.VAT-pc        = v-vat-pc
      .
    end.
  end.

  for each ub.contract-specif exclusive-lock
  where ub.contract-specif.contract-num = p-contract-code and
        ub.contract-specif.host-code = p-host-code
  on error  undo main_block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  :
    find first ub.clients no-lock
      where ub.clients.host-code = ub.contract-specif.host-code
      no-error .
    find first ub.goods no-lock
      where ub.goods.gds-code = ub.contract-specif.gds-code
      no-error .
    if available ub.goods then do:
      find last buf_tax-rate-gds no-lock
        where buf_tax-rate-gds.gds-code   = ub.goods.gds-code
          and buf_tax-rate-gds.tax-code   = 1
          and buf_tax-rate-gds.host-code  = 0
          and buf_tax-rate-gds.obj-type   = ""
          and buf_tax-rate-gds.obj-code   = 0
          and buf_tax-rate-gds.fact-order <= v-fo
        no-error .
      if available buf_tax-rate-gds then do:
        run pftxvalo (
            input ?
          , input buf_tax-rate-gds.tax-code
          , input buf_tax-rate-gds.rate-code
          , input v-fo
          , input ub.contract-specif.host-code
          , input (if available ub.clients then ub.clients.obj-type else "":U )
          , input (if available ub.clients then ub.clients.obj-code else 0 )
          , output v-vat-pc
        ) .
      end.
      else do:
        assign
          v-vat-pc = 18
        .
      end.
      assign
        ub.contract-specif.gds-name      = ub.goods.gds-name
        ub.contract-specif.artic         = ub.goods.artic
        ub.contract-specif.prod-type     = ub.goods.prod-type
        ub.contract-specif.prod-code     = ub.goods.prod-code
        ub.contract-specif.unit-base     = ub.goods.unit-base
        ub.contract-specif.cli-base-rate = ub.goods.cli-base-rate
        ub.contract-specif.VAT-type      = {&inc-vat}
        ub.contract-specif.VAT-pc        = v-vat-pc
      .
    end.
  end.
end.

procedure pftxvalo :

  define input  parameter par-rc        as recid                          no-undo .
  define input  parameter partax-code   like ub.tax.tax-code              no-undo .
  define input  parameter parrate-code  like ub.tax-rate.rate-code        no-undo .
  define input  parameter parfact-order like ub.tax-rate-value.fact-order no-undo .
  define input  parameter parhost-code  like ub.sysconf.host-code         no-undo .
  define input  parameter parobj-type   like ub.clients.obj-type          no-undo .
  define input  parameter parobj-code   like ub.clients.obj-code          no-undo .
  define output parameter partax-value  as decimal no-undo .

  define variable vss-description as character no-undo initial "pftxvalo: Значение по ставке налога для данного fact-order для заданного объекта и фирмы".

  define buffer buf_tax-rate for ub.tax-rate.
  define buffer buf_tax-rate-value for ub.tax-rate-value.

  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    assign
      partax-value = ?
    .

    find last buf_tax-rate-value no-lock
      where buf_tax-rate-value.tax-code   = partax-code
        and buf_tax-rate-value.rate-code  = parrate-code
        and buf_tax-rate-value.host-code  = parhost-code
        and buf_tax-rate-value.obj-type   = parobj-type
        and buf_tax-rate-value.obj-code   = parobj-code
        and buf_tax-rate-value.fact-order <= parfact-order
        and buf_tax-rate-value.status_    = {&current-status}
      no-error .
    if available buf_tax-rate-value then do:
      assign
        partax-value = buf_tax-rate-value.rate-value
      .
      return.
    end.

    find last buf_tax-rate-value no-lock
      where buf_tax-rate-value.tax-code   = partax-code
        and buf_tax-rate-value.rate-code  = parrate-code
        and buf_tax-rate-value.host-code  = parhost-code
        and buf_tax-rate-value.obj-type   = ""
        and buf_tax-rate-value.obj-code   = 0
        and buf_tax-rate-value.fact-order <= parfact-order
        and buf_tax-rate-value.status_    = {&current-status}
      no-error .
    if available buf_tax-rate-value then do:
      assign
        partax-value = buf_tax-rate-value.rate-value
      .
      return.
    end.

    find last buf_tax-rate-value no-lock
      where buf_tax-rate-value.tax-code   = partax-code
        and buf_tax-rate-value.rate-code  = parrate-code
        and buf_tax-rate-value.host-code  = 0
        and buf_tax-rate-value.obj-type   = ""
        and buf_tax-rate-value.obj-code   = 0
        and buf_tax-rate-value.fact-order <= parfact-order
        and buf_tax-rate-value.status_    = {&current-status}
      no-error .
    if available buf_tax-rate-value then do:
      assign
        partax-value = buf_tax-rate-value.rate-value
      .
      return.
    end.
  end.

end procedure. /* pftaxval */