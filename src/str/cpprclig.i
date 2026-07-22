/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Простановка цены поставщика или цены из товарной спецификации в строку

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич
+ НДС и типа вычислени

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)":U no-undo initial "@(#)$Workfile$ $Revision$".

{ str/cont-ms-def.i }


procedure cpprclig :
  define input        parameter pardoc-code       as   character                  no-undo.
  define input        parameter parcli-code       like ub.trn-doc.cli-code        no-undo.
  define input        parameter parcli-type       like ub.trn-doc.cli-type        no-undo.
  define input        parameter parhost-code      like ub.trn-doc.host-code       no-undo.
  define input        parameter parbase-rate      like ub.trn-doc.base-rate       no-undo.
  define input        parameter parbase-scale     like ub.trn-doc.base-scale      no-undo.
  define input        parameter parexch-rate      like ub.trn-doc.exch-rate       no-undo.
  define input        parameter parexch-scale     like ub.trn-doc.exch-scale      no-undo.
  define input        parameter parvat-type       like ub.trn-doc.vat-type        no-undo.
  define input        parameter parslt-type       like ub.trn-doc.slt-type        no-undo.
  define input        parameter parartic          like ub.doc-line.artic          no-undo.
  define input        parameter parprod-type      like ub.doc-line.prod-type      no-undo.
  define input        parameter parprod-code      like ub.doc-line.prod-code      no-undo.
  define input        parameter paris-cli-tax     as   logical                    no-undo.
  define input        parameter parcli-base-rate  like ub.doc-line.cli-base-rate  no-undo.
  define input        parameter partransport-rubl like ub.doc-line.transport-rubl no-undo.
  define input        parameter parother-rubl     like ub.doc-line.other-rubl     no-undo.
  define output       parameter parprice-cli      like ub.doc-line.price-cli      no-undo.
  define output       parameter parprice-base     like ub.doc-line.price-base     no-undo.
  define output       parameter parprice-rubl     like ub.doc-line.price-rubl     no-undo.
  define input-output parameter parvat-pc         like ub.doc-line.vat-pc         no-undo.
  define input-output parameter parslt-pc         like ub.doc-line.slt-pc         no-undo.
  define input-output parameter parroad-tax       like ub.doc-line.road-tax       no-undo.
  define input-output parameter parexcise         like ub.doc-line.excise         no-undo.

  define variable varprice-cli                like ub.doc-line.price-rubl no-undo.
  define variable varprice-cli-unit-base      like ub.doc-line.price-rubl no-undo.
  define variable varprice-road-tax           like ub.doc-line.price-rubl no-undo.
  define variable varprice-other-exp          like ub.doc-line.price-rubl no-undo.
  define variable varprice-transport-exp      like ub.doc-line.price-rubl no-undo.
  define variable varprice-without-abs        like ub.doc-line.price-rubl no-undo.
  define variable varprice-slt                like ub.doc-line.price-rubl no-undo.
  define variable varprice-no-slt             like ub.doc-line.price-rubl no-undo.
  define variable varprice-vat                like ub.doc-line.price-rubl no-undo.
  define variable varprice-no-vat-slt         like ub.doc-line.price-rubl no-undo.
  define variable varprice-rubl               like ub.doc-line.price-rubl no-undo.
  define variable varprice-road-tax-rubl      like ub.doc-line.price-rubl no-undo.
  define variable varprice-other-exp-rubl     like ub.doc-line.price-rubl no-undo.
  define variable varprice-transport-exp-rubl like ub.doc-line.price-rubl no-undo.
  define variable varprice-without-abs-rubl   like ub.doc-line.price-rubl no-undo.
  define variable varprice-slt-rubl           like ub.doc-line.price-rubl no-undo.
  define variable varprice-no-slt-rubl        like ub.doc-line.price-rubl no-undo.
  define variable varprice-vat-rubl           like ub.doc-line.price-rubl no-undo.
  define variable varprice-no-vat-slt-rubl    like ub.doc-line.price-rubl no-undo.
  define variable varprice-base               like ub.doc-line.price-base no-undo.
  define variable varprice-road-tax-base      like ub.doc-line.price-base no-undo.
  define variable varprice-other-exp-base     like ub.doc-line.price-base no-undo.
  define variable varprice-transport-exp-base like ub.doc-line.price-base no-undo.
  define variable varprice-without-abs-base   like ub.doc-line.price-base no-undo.
  define variable varprice-slt-base           like ub.doc-line.price-base no-undo.
  define variable varprice-no-slt-base        like ub.doc-line.price-base no-undo.
  define variable varprice-vat-base           like ub.doc-line.price-base no-undo.
  define variable varprice-no-vat-slt-base    like ub.doc-line.price-base no-undo.
  define variable v-specif-found              as   logical                no-undo.
  define variable v-rcv-found                 as   logical                no-undo .

  define buffer bf_cli-gds         for ub.cli-gds .
  define buffer bf_doc-line        for ub.doc-line.
  define buffer bf_trn-doc         for ub.trn-doc.
  define buffer bf_goods           for ub.goods.
  define buffer bf_contract-specif for ub.contract-specif.
  define buffer buf_ord-chain      for ub.ord-chain .
  define buffer buf_ord-doc-rcv    for ub.ord-doc-rcv .
  define buffer buf_ord-line-rcv   for ub.ord-line-rcv .

  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1. stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1. endkey", vss-include-info{&vssseq} )
  :

    assign
      v-rcv-found    = false
      v-specif-found = false
    .
    /* Пытаемся найти поставку и взять цену из нее */
    find first buf_ord-chain no-lock
      where buf_ord-chain.rel-doc-code =  pardoc-code
        and buf_ord-chain.rel-doc-type = 'trn':u
      no-error .
    if available buf_ord-chain then do:
      find first buf_ord-doc-rcv no-lock
        where buf_ord-doc-rcv.rcv-code = buf_ord-chain.doc-code
      no-error .
      if available buf_ord-doc-rcv then do:
        find first buf_ord-line-rcv no-lock
          where buf_ord-line-rcv.doc-code  = buf_ord-doc-rcv.doc-code
            and buf_ord-line-rcv.artic     = parartic
            and buf_ord-line-rcv.prod-type = parprod-type
            and buf_ord-line-rcv.prod-code = parprod-code
          no-error .
        if available buf_ord-line-rcv then do:
          find first bf_trn-doc  no-lock
            where bf_trn-doc.doc-code = pardoc-code
          .
          assign
            parprice-cli = buf_ord-line-rcv.price-cli
            parroad-tax  = buf_ord-line-rcv.road-tax
            parexcise    = buf_ord-line-rcv.excise
            v-rcv-found  = true
            .
          if parslt-type <> {&without-slt} then do:
            if bf_trn-doc.slt-type <> {&without-slt} then do:
              assign
                parslt-pc = buf_ord-line-rcv.slt-pc
              .
            end.
          end.
          else do:
            assign
              parslt-pc = 0
            .
          end.
          if parvat-type <> {&without-vat} then do:
            if bf_trn-doc.vat-type <> {&without-vat} then do:
              assign
                parvat-pc = buf_ord-line-rcv.vat-pc
              .
            end.
          end.
          else do:
            assign
              parvat-pc = 0
            .
          end.
        end.
      end.
    end.

    if v-rcv-found = false then do:
      /* Пытаемся найти строку спецификации для договора, указанного в документе */
      find first bf_trn-doc no-lock
        where bf_trn-doc.doc-code = pardoc-code
        no-error.
      if available bf_trn-doc
        and bf_trn-doc.contract-code <> 0
      then do:
        find first bf_goods no-lock
          where bf_goods.artic     = parartic
            and bf_goods.prod-code = parprod-code
            and bf_goods.prod-type = parprod-type
          no-error.
        if available bf_goods then do:
/*
          find first bf_contract-specif no-lock
            where bf_contract-specif.host-code    = bf_trn-doc.host-code
              and bf_contract-specif.contract-num = bf_trn-doc.contract-code
              and bf_contract-specif.gds-code     = bf_goods.gds-code
            no-error.
*/
          {str/cont-slave-inc.i
               &FIND_FIRST = YES
               &BUFFER_SPECIF   = bf_contract-specif
               &P_HOST_CODE     = bf_trn-doc.host-code
               &P_CONTRACT_NUM  = bf_trn-doc.contract-code
               &P_GDS_CODE      = bf_goods.gds-code
               &NO_LOCK=YES
               &NO_ERROR=YES
          }

          /* Если нашли - берем цену из нее */
          if available bf_contract-specif then do:
            assign
              parprice-cli   = (bf_contract-specif.price-cli / bf_contract-specif.cli-base-rate)  * parcli-base-rate
              parvat-type    = bf_contract-specif.vat-type
              parvat-pc      = bf_contract-specif.vat-pc
              v-specif-found = yes
            .
          end.
        end.
      end.

      find first bf_cli-gds no-lock
        where bf_cli-gds.cli-code  = parcli-code
          and bf_cli-gds.cli-type  = parcli-type
          and bf_cli-gds.host-code = parhost-code
          and bf_cli-gds.artic     = parartic
          and bf_cli-gds.prod-code = parprod-code
          and bf_cli-gds.prod-type = parprod-type
        no-error.
      if available bf_cli-gds then do:
        /* Если строка спецификации не найдена - берем цену cli-gds */
        if v-specif-found = false then do:
          assign
            parprice-cli = bf_cli-gds.price-cli
          .
        end.
        if paris-cli-tax then do:
          find first bf_doc-line no-lock
            where bf_doc-line.doc-code  = bf_cli-gds.in-code
              and bf_doc-line.artic     = bf_cli-gds.artic
              and bf_doc-line.prod-type = bf_cli-gds.prod-type
              and bf_doc-line.prod-code = bf_cli-gds.prod-code
            no-error.
          if available bf_doc-line then do:
            find first bf_trn-doc where bf_trn-doc.doc-code = bf_doc-line.doc-code no-lock.
            assign
              parroad-tax = bf_doc-line.road-tax
              parexcise   = bf_doc-line.excise
            .

            if parslt-type <> {&without-slt} then do:
              if bf_trn-doc.slt-type <> {&without-slt} then do:
                assign
                  parslt-pc = bf_doc-line.slt-pc
                .
              end.
            end.
            else do:
              assign
                parslt-pc = 0
              .
            end.
            if parvat-type <> {&without-vat} then do:
              if bf_trn-doc.vat-type <> {&without-vat} then do:
                if v-specif-found = false then do:
                  assign
                    parvat-pc = bf_doc-line.vat-pc
                  .
                end.
              end.
            end.
            else do:
              assign
                parvat-pc = 0
              .
            end.
          end.
        end.
      end.
    end.
    { str/in-vat.i
      pardoc-code
      parbase-rate
      parbase-scale
      parexch-rate
      parexch-scale
      parvat-type
      parslt-type
      parartic
      parprod-type
      parprod-code
      parprice-cli
      parcli-base-rate
      parprice-rubl
      parvat-pc
      parslt-pc
      parroad-tax
      partransport-rubl
      parother-rubl
      varprice-cli
      varprice-cli-unit-base
      varprice-road-tax
      varprice-other-exp
      varprice-transport-exp
      varprice-without-abs
      varprice-slt
      varprice-no-slt
      varprice-vat
      varprice-no-vat-slt
      varprice-rubl
      varprice-road-tax-rubl
      varprice-other-exp-rubl
      varprice-transport-exp-rubl
      varprice-without-abs-rubl
      varprice-slt-rubl
      varprice-no-slt-rubl
      varprice-vat-rubl
      varprice-no-vat-slt-rubl
      varprice-base
      varprice-road-tax-base
      varprice-other-exp-base
      varprice-transport-exp-base
      varprice-without-abs-base
      varprice-slt-base
      varprice-no-slt-base
      varprice-vat-base
      varprice-no-vat-slt-base
      no-error
    }
    if error-status:error then do:
      return error "Ошибка при пересчете линии документа".
    end.
    assign
      parprice-cli  = varprice-cli
      parprice-rubl = varprice-rubl
      parprice-base = varprice-base
    .
  end.
end procedure.
/*end of cpprclig.i*/