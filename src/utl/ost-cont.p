block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ost-cont.p $
$Archive: utl/ost-cont.p $

Создание записи остатков финансового архива

Автор: Кочетков Михаил Юрьевич
Дата создания: 07/16/07
Author: Michael Kochetkov
Creation date: 07/16/07

*/

define input parameter parparentproc as widget-handle no-undo .

/* ***************************  Definitions  ************************** */
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":u .
def var vss-author      as character no-undo init "$Author: expertek $":u .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":u .
def var vss-workfile    as character no-undo init "$Workfile: ost-cont.p $":u .
def var vss-archive     as character no-undo init "$Archive: utl/ost-cont.p $":u .
def var vss-description as character no-undo init "Создание записи остатков финансового архива arh-trn-doc-contract" .
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i }
{ str/libtfarh.i }
{ gbl/clntattr.i }
{ trg/factord.i }
{ trg/partslib.i }
{ str/in-vatp.i def }
{ gbl/userobjs.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

on write of ub.arh-trn-doc-contract override do:  end.
on delete of ub.arh-trn-doc-contract override do:  end.


define variable v-str          as CHAR    no-undo .
define variable par-type       as CHAR    no-undo .
define variable p-status       as integer no-undo .
define variable p-cut-date     as date    no-undo .
define variable p-cut-fin-date as date    no-undo.
define variable Counter1       as integer   no-undo .
define variable g-log          as logical   no-undo .
define variable v-fact-order   as decimal   no-undo .

define buffer buf_gds-obj for gds-obj.
define buffer buf_arh-trn-doc-contract for arh-trn-doc-contract.

define temp-table temp-contr no-undo
  field host-code as integer
  field contract-code as integer
  field cli-code      as integer
  field cli-type      as character
  field sum-base       as decimal
  field sum-rubl       as decimal
  field sum-vat-base   as decimal
  field sum-vat-rubl   as decimal
  field sum-slt-base   as decimal
  field sum-slt-rubl   as decimal
  field sum-rdt-base   as decimal
  field sum-rdt-rubl   as decimal
  field sum-transp-base as decimal
  field sum-transp-rubl as decimal
  field sum-other-base  as decimal
  field sum-other-rubl  as decimal
  INDEX pi  IS PRIMARY  host-code contract-code cli-type cli-code
.

  define variable v-num as integer   no-undo .
  run gbl/d-askw.w
    (input "Вопрос"
    ,input "Создание записи остатков финансового архива arh-trn-doc-contract" + {&new-line}
    ,input "|^"
    ,input "Все объекты^confirm|Выбрать объекты|Отмена"
    ,input "|"
         + "|"
         + ""
    ,input 1
    ,input 3
    ,output v-num
    ).

  { rep/repfrm.i def } /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 5 } /* Показать окно информации о текущем процессе */

  case v-num :
    when 1
    then do:
      define buffer buf_db for ub.db .
      define buffer buf_clients for ub.clients .
      for each buf_db no-lock
      ,each buf_clients no-lock where buf_clients.db-num = buf_db.db-num
      on error undo, return error return-value :
        if buf_clients.stts = 0  then do:
          run calc-archive in this-procedure ( input buf_clients.obj-type, input buf_clients.obj-code ).
        end.
      end.
    end.
    when 2
    then do:
      define variable v-user-select as logical   no-undo .
      { gbl/uobjsman.i  parparentproc  v-cntxt-db-num   v-cntxt-userid   v-cntxt-host-code-obj  v-cntxt-obj-type  v-cntxt-obj-code  v-user-select  }
      if v-user-select <> true then do:
        message "Объект не выбран" view-as alert-box information .
        return .
      end.

      define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
      for each buf_userobjs_temp-user-obj on error undo, return error return-value :
        run calc-archive in this-procedure (input buf_userobjs_temp-user-obj.obj-type, input buf_userobjs_temp-user-obj.obj-code ).
      end.
    end.
    otherwise do:
      return . /* --->>>--- */
    end.
  end.

  { rep/repfrm.i off } /* Показать окно информации о текущем процессе */

  message   "Работа утилиты завершена"   view-as alert-box.



procedure calc-archive :
  do on error undo, return error return-value :
    define input  parameter p-obj-type like clients.obj-type .
    define input  parameter p-obj-code like clients.obj-code .

    find first clients no-lock where clients.obj-type = p-obj-type and clients.obj-code = p-obj-code .
    { gbl/cutd-obj.i p-obj-type p-obj-code p-status p-cut-date p-cut-fin-date }

    if p-status = 2 or  p-status = 4 then do:  /* пересчет после обрезания */
/*      run day-begin-fact-order in this-procedure ( input p-cut-date, output v-fact-order ).*/
      run factord-end-day in this-procedure ( input p-cut-date - 1, output v-fact-order ).
      /* считаем свободную зону и создаем заглушку на начало */
      for each temp-contr : delete temp-contr . end.
      for each buf_gds-obj no-lock where buf_gds-obj.obj-type = p-obj-type and buf_gds-obj.obj-code = p-obj-code :
        for each temp-parts : delete temp-parts . end.
        run partslib-init-temp-parts-by-factord (input p-obj-type,
                                             input p-obj-code,
                                             input buf_gds-obj.artic,
                                             input buf_gds-obj.prod-type,
                                             input buf_gds-obj.prod-code,
                                             input v-fact-order,
                                             false) .
        for each temp-parts use-index contr break by temp-parts.contract-code :
          find first temp-contr
            where temp-contr.contract-code = temp-parts.contract-code
              and temp-contr.host-code     = temp-parts.host-code
              and temp-contr.cli-code      = temp-parts.supp-code
              and temp-contr.cli-type      = temp-parts.supp-type
          no-error .
          if not available temp-contr then do:
            create temp-contr .
            assign
              temp-contr.host-code     = temp-parts.host-code
              temp-contr.contract-code = temp-parts.contract-code
              temp-contr.cli-code      = temp-parts.supp-code
              temp-contr.cli-type      = temp-parts.supp-type
            .
          end.
          { str/in-vatp.i calc-parts temp-parts. " " loc}
          assign
            temp-contr.sum-base        = temp-contr.sum-base        + price-base-with-tax-loc * temp-parts.fact-qnty
            temp-contr.sum-rubl        = temp-contr.sum-rubl        + price-rubl-with-tax-loc * temp-parts.fact-qnty
            temp-contr.sum-vat-base    = temp-contr.sum-vat-base    + vat-base-loc            * temp-parts.fact-qnty
            temp-contr.sum-vat-rubl    = temp-contr.sum-vat-rubl    + vat-rubl-loc            * temp-parts.fact-qnty
            temp-contr.sum-slt-base    = temp-contr.sum-slt-base    + slt-base-loc            * temp-parts.fact-qnty
            temp-contr.sum-slt-rubl    = temp-contr.sum-slt-rubl    + slt-rubl-loc            * temp-parts.fact-qnty
            temp-contr.sum-rdt-base    = temp-contr.sum-rdt-base    + road-tax-base-loc       * temp-parts.fact-qnty
            temp-contr.sum-rdt-rubl    = temp-contr.sum-rdt-rubl    + road-tax-rubl-loc       * temp-parts.fact-qnty
            temp-contr.sum-transp-base = temp-contr.sum-transp-base + transport-base-loc      * temp-parts.fact-qnty
            temp-contr.sum-transp-rubl = temp-contr.sum-transp-rubl + transport-rubl-loc      * temp-parts.fact-qnty
            temp-contr.sum-other-base  = temp-contr.sum-other-base  + other-base-loc          * temp-parts.fact-qnty
            temp-contr.sum-other-rubl  = temp-contr.sum-other-rubl  + other-rubl-loc          * temp-parts.fact-qnty
          .
        end.
      end.
      for each temp-contr :
        if temp-contr.sum-base = 0 and temp-contr.sum-rubl = 0 then next .
        create buf_arh-trn-doc-contract .
        assign
          buf_arh-trn-doc-contract.cli-code          = temp-contr.cli-code
          buf_arh-trn-doc-contract.cli-type          = temp-contr.cli-type
          buf_arh-trn-doc-contract.contract-code     = temp-contr.contract-code
          buf_arh-trn-doc-contract.host-code         = temp-contr.host-code
          buf_arh-trn-doc-contract.doc-code          = "остаток"
          buf_arh-trn-doc-contract.doc-date          = p-cut-date
          buf_arh-trn-doc-contract.ext-doc-type      = {&TDEDT_Pri_Vnesh}
          buf_arh-trn-doc-contract.fact-date         = p-cut-date
          buf_arh-trn-doc-contract.fact-order        = v-fact-order
          buf_arh-trn-doc-contract.obj-code          = p-obj-code
          buf_arh-trn-doc-contract.obj-type          = p-obj-type
          buf_arh-trn-doc-contract.shift-date        = p-cut-date
          buf_arh-trn-doc-contract.shift-num         = 0

          buf_arh-trn-doc-contract.sum-type          = "":u
          buf_arh-trn-doc-contract.inc-sum-base        = temp-contr.sum-base
          buf_arh-trn-doc-contract.inc-sum-rubl        = temp-contr.sum-rubl
          buf_arh-trn-doc-contract.inc-sum-vat-base    = temp-contr.sum-vat-base
          buf_arh-trn-doc-contract.inc-sum-vat-rubl    = temp-contr.sum-vat-rubl
          buf_arh-trn-doc-contract.inc-sum-slt-base    = temp-contr.sum-slt-base
          buf_arh-trn-doc-contract.inc-sum-slt-rubl    = temp-contr.sum-slt-rubl
          buf_arh-trn-doc-contract.inc-sum-rdt-base    = temp-contr.sum-rdt-base
          buf_arh-trn-doc-contract.inc-sum-rdt-rubl    = temp-contr.sum-rdt-rubl
          buf_arh-trn-doc-contract.inc-sum-transp-base = temp-contr.sum-transp-base
          buf_arh-trn-doc-contract.inc-sum-transp-rubl = temp-contr.sum-transp-rubl
          buf_arh-trn-doc-contract.inc-sum-other-base  = temp-contr.sum-other-base
          buf_arh-trn-doc-contract.inc-sum-other-rubl  = temp-contr.sum-other-rubl
        .
      end.
    end.

  end.
end procedure. /* calc-archive */