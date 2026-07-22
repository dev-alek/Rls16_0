block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rt-bcdoc.p $
$Archive: gbl/rt-bcdoc.p $

Радиотерминал. Поиск товара по штрих-коду в документе

Автор: Хныкин Павел Андреевич
Дата создания: 27/02/07
Author: Pavel Khnykin
Creation date: 27/02/07

create: Перваков Михаил Сергеевич
Дата создания: 09/27/05

*/

define input  parameter parparentproc     as widget-handle no-undo .
define input  parameter p-unique-doc-code as character no-undo .
define input  parameter p-obj-type        as character no-undo .
define input  parameter p-obj-code        as integer   no-undo .
define input  parameter p-host-code       as integer   no-undo .
define input  parameter p-bar-code        as character no-undo .
define output parameter p-status          as character no-undo .
define output parameter p-error-message   as character no-undo .
define output parameter p-b-code          as integer   no-undo .
define output parameter p-artic           as character no-undo .
define output parameter p-name            as character no-undo .
define output parameter p-prod-name       as character no-undo .
define output parameter p-unit-cli        as character no-undo .
define output parameter p-cli-base-rate   as character no-undo .
define output parameter p-price-cli       as character no-undo .
define output parameter p-vat-pc          as character no-undo .
define output parameter p-curr-abbr       as character no-undo .
define output parameter p-unit-base       as character no-undo .
define output parameter p-doc-qnty        as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rt-bcdoc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/rt-bcdoc.p $":U .
define variable vss-description as character no-undo init "Радиотерминал. Поиск товара по штрих-коду в документе".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ str/cpprclig.i }

define variable v-doc-type    as character no-undo .
define variable v-doc-code    as character no-undo .
define variable v-artic       as character no-undo .
define variable v-prod-type   as character no-undo .
define variable v-prod-code   as integer   no-undo .
define variable v-price-cli   as decimal   no-undo .
define variable v-price-base  as decimal   no-undo .
define variable v-price-rubl  as decimal   no-undo .
define variable v-vat-pc      as decimal   no-undo .
define variable v-slt-pc      as decimal   no-undo .
define variable v-road-tax    as decimal   no-undo .
define variable v-excise      as decimal   no-undo .
define variable v-empty-scale as logical   no-undo .
define variable v-rbisbase    as logical   no-undo .

define buffer buf_currency         for ub.currency .
define buffer buf_bar-code         for ub.bar-code .
define buffer buf_goods            for ub.goods .
define buffer buf_trn-doc          for ub.trn-doc .
define buffer buf_doc-line         for ub.doc-line .
define buffer buf_gds-dtl          for ub.gds-dtl .
define buffer buf_clients          for ub.clients .
define buffer buf_ord-doc          for ub.ord-doc .
define buffer buf_ord-doc-rcv      for ub.ord-doc-rcv .
define buffer buf_ord-line-rcv     for ub.ord-line-rcv .
define buffer buf_cli-gds          for ub.cli-gds .
define buffer buf_cbr_doc-line     for ub.doc-line .
define buffer buf_previos_doc-line for ub.doc-line .

do
on error undo, return error return-value
:
  { gbl/rbisbase.i
    v-rbisbase
  }

  run gbl/getbcode.p
    (input  parparentproc /* parparentproc */
    ,input  p-bar-code    /* p-search-code */
    ,input  ""            /* p-obj-type    */
    ,input  0             /* p-obj-code    */
    ,input  false         /* p-with-chs    */
    ,output p-b-code      /* p-b-code      */
    ) .
  if p-b-code = ?
  then do:
    assign
      p-status        = '1'
      p-error-message = substitute('Ошибка при поиске штрих-кода &1'
                                  ,p-bar-code
                                  )
      p-b-code        = ?
    .
    return . /* --->>>--- */
  end.

  find first buf_bar-code no-lock
    where buf_bar-code.b-code = p-b-code
    no-error .
  if not available buf_bar-code
  then do:
    assign
      p-status        = '1'
      p-error-message = substitute('Ошибка поиска записи bar-code &1'
                                  ,p-b-code
                                  )
      p-b-code        = ?
    .
    return . /* --->>>--- */
  end.

  define variable v-default-cli-base-rate as decimal   no-undo .

  assign
    v-default-cli-base-rate = buf_bar-code.cli-base-rate
  .

  { gbl/arptpc.i
    buf_bar-code.gds-code
    v-artic
    v-prod-type
    v-prod-code
    no-error
  }
  if error-status :error
  then do:
    assign
      p-status        = '1'
      p-error-message = substitute('Ошибка выполнения процедуры arptpc.i &1 &2'
                                  ,error-status :get-message(1)
                                  ,return-value
                                  )
      p-b-code        = ?
    .
    return . /* --->>>--- */
  end.

  find first buf_goods no-lock
    where buf_goods.artic     = v-artic
      and buf_goods.prod-type = v-prod-type
      and buf_goods.prod-code = v-prod-code
    no-error .
  if not available buf_goods
  then do:
    assign
      p-status        = '1'
      p-error-message = substitute('rt-bcdoc.p. Не найден товар &1 &2 &3'
                                  ,v-artic
                                  ,v-prod-type
                                  ,v-prod-code
                                  )
      p-b-code        = ?
    .
    return . /* --->>>--- */
  end.

  { gbl/gdscdat.i
    buf_bar-code.gds-code
    "'empty-scale=request':u"
    v-empty-scale
  }
  if v-empty-scale <> true
  then do:
    assign
      p-status        = '1'
      p-error-message = substitute('Товар &1 &2 &3 нельзя добавить, потому что он имеет непустую шкалу.'
                                  ,v-artic
                                  ,v-prod-type
                                  ,v-prod-code
                                  )
      p-b-code        = ?
    .
    return . /* --->>>--- */
  end.

  find first buf_clients no-lock
    where buf_clients.obj-type = buf_goods.prod-type
      and buf_clients.obj-code = buf_goods.prod-code
    no-error .
  if not available buf_clients
  then do:
    assign
      p-status        = '1'
      p-error-message = substitute('rt-bcdoc.p. Товар &1 &2 &3. Не найден производитель'
                                  ,v-artic
                                  ,v-prod-type
                                  ,v-prod-code
                                  )
      p-b-code        = ?
    .
    return . /* --->>>--- */
  end.

  assign
    v-doc-type = entry(1, p-unique-doc-code, '|':u)
  .

  case v-doc-type
  :
    when 'ПТ':u
    then do:
      /* поставка в статусе поставка */
      assign
        v-doc-code = entry(2, p-unique-doc-code, '|':u)
      .

      find first buf_ord-doc-rcv no-lock
        where buf_ord-doc-rcv.rcv-code = v-doc-code
        no-error .
      if not available buf_ord-doc-rcv
      then do:
        assign
          p-status        = '1'
          p-error-message = substitute('rt-bcdoc.p: Не найден документ поставки &1'
                                      ,p-unique-doc-code
                                      )
          p-b-code        = 0
        .
        return . /* --->>>--- */
      end.

      find first buf_ord-doc no-lock
        where buf_ord-doc.doc-code = buf_ord-doc-rcv.doc-code
        no-error .
      if not available buf_ord-doc
      then do:
        assign
          p-status        = '1'
          p-error-message = substitute('rt-bcdoc.p: Не найден документ заказа &1 на основании документа поставки &2'
                                      ,buf_ord-doc-rcv.doc-code
                                      ,p-unique-doc-code
                                      )
          p-b-code        = 0
        .
        return . /* --->>>--- */
      end.

      find first buf_currency no-lock
        where buf_currency.curr-code = buf_ord-doc-rcv.exch-code
        no-error .
      if not available buf_currency
      then do:
        assign
          p-status        = '1'
          p-error-message = substitute('rt-bcdoc.p: Не найдена валюта с кодом &1. Поставка &2'
                                      ,buf_ord-doc-rcv.exch-code
                                      ,buf_ord-doc-rcv.doc-code
                                      )
          p-b-code        = 0
        .
        return . /* --->>>--- */
      end.
      assign
        p-curr-abbr = buf_currency.curr-abbr
      .

      { gbl/pftxvalg.i
        buf_bar-code.gds-code
        {&vat-tax-code}
        ?
        p-host-code
        p-obj-type
        p-obj-code
        v-vat-pc
      }

      find first buf_cli-gds no-lock
        where buf_cli-gds.cli-code  = buf_ord-doc-rcv.cli-code
          and buf_cli-gds.cli-type  = buf_ord-doc-rcv.cli-type
          and buf_cli-gds.host-code = buf_ord-doc-rcv.host-code
          and buf_cli-gds.artic     = v-artic
          and buf_cli-gds.prod-code = v-prod-code
          and buf_cli-gds.prod-type = v-prod-type
        no-error .
      if available buf_cli-gds
      then do:
        find first buf_cbr_doc-line no-lock
          where buf_cbr_doc-line.doc-code  = buf_cli-gds.in-code
            and buf_cbr_doc-line.artic     = buf_cli-gds.artic
            and buf_cbr_doc-line.prod-type = buf_cli-gds.prod-type
            and buf_cbr_doc-line.prod-code = buf_cli-gds.prod-code
          no-error .
        if available buf_cbr_doc-line
        then do:
          assign
            v-default-cli-base-rate = buf_cbr_doc-line.cli-base-rate
          .
        end.
      end.

      run cpprclig in this-procedure
        (input  'zakaz':u                  /* pardoc-code       */
        ,input  buf_ord-doc-rcv.cli-code   /* parcli-code       */
        ,input  buf_ord-doc-rcv.cli-type   /* parcli-type       */
        ,input  buf_ord-doc-rcv.host-code  /* parhost-code      */
        ,input  buf_ord-doc-rcv.base-rate  /* parbase-rate      */
        ,input  buf_ord-doc-rcv.base-scale /* parbase-scale     */
        ,input  buf_ord-doc-rcv.exch-rate  /* parexch-rate      */
        ,input  buf_ord-doc-rcv.exch-scale /* parexch-scale     */
        ,input  buf_ord-doc.vat-type       /* parvat-type       */
        ,input  buf_ord-doc.slt-type       /* parslt-type       */
        ,input  buf_goods.artic            /* parartic          */
        ,input  buf_goods.prod-type        /* parprod-type      */
        ,input  buf_goods.prod-code        /* parprod-code      */
        ,input  false                      /* paris-cli-tax     */
        ,input  v-default-cli-base-rate    /* parcli-base-rate  */
        ,input  0                          /* partransport-rubl */
        ,input  0                          /* parother-rubl     */
        ,output       v-price-cli          /* parprice-cli      */
        ,output       v-price-base         /* parprice-base     */
        ,output       v-price-rubl         /* parprice-rubl     */
        ,input-output v-vat-pc             /* parvat-pc         */
        ,input-output v-slt-pc             /* parslt-pc         */
        ,input-output v-road-tax           /* parroad-tax       */
        ,input-output v-excise             /* parexcise         */
        ).

      assign
        p-artic         = buf_goods.artic
        p-name          = buf_goods.gds-name
        p-prod-name     = buf_clients.obj-name
        p-unit-base     = buf_goods.unit-base
        p-unit-cli      = buf_bar-code.unit-cli
        p-cli-base-rate = string(buf_bar-code.cli-base-rate)
        p-vat-pc        = string(v-vat-pc)
      .

      if v-rbisbase = true
      then do:
        assign
          p-price-cli = string(v-price-base * buf_bar-code.cli-base-rate)
        .
      end.
      else do:
        assign
          p-price-cli = string(v-price-rubl * buf_bar-code.cli-base-rate)
        .
      end.

      find first buf_ord-line-rcv no-lock
        where buf_ord-line-rcv.doc-code   = buf_ord-doc-rcv.doc-code
          and buf_ord-line-rcv.rcv-code   = buf_ord-doc-rcv.rcv-code
          and buf_ord-line-rcv.artic      = buf_goods.artic
          and buf_ord-line-rcv.prod-type  = buf_goods.prod-type
          and buf_ord-line-rcv.prod-code  = buf_goods.prod-code
      no-error .
      if available buf_ord-line-rcv
      then do:
        assign
          p-doc-qnty = string(buf_ord-line-rcv.qnty / buf_bar-code.cli-base-rate )
        .
      end.
      else do:
        assign
          p-doc-qnty = string(0)
        .
      end.

      assign
        p-status        = '0':u
        p-error-message = '':u
      .
      return . /* --->>>--- */
    end.

    when 'ПН':u
    then do:
      /* приход внешний */
      assign
        v-doc-code = entry(2, p-unique-doc-code, '|':u)
      .

      find first buf_trn-doc no-lock
        where buf_trn-doc.doc-code = v-doc-code
        no-error .
      if not available buf_trn-doc
      then do:
        assign
          p-status        = '1'
          p-error-message = substitute('rt-bcdoc.p: Не найден складской документ &1'
                                      ,p-unique-doc-code
                                      )
          p-b-code        = 0
        .
        return . /* --->>>--- */
      end.

      find first buf_currency no-lock
        where buf_currency.curr-code = buf_trn-doc.exch-code
        no-error .
      if not available buf_currency
      then do:
        assign
          p-status        = '1'
          p-error-message = substitute('rt-bcdoc.p: Не найдена валюта с кодом &1. Складской документ &2'
                                      ,buf_trn-doc.exch-code
                                      ,buf_trn-doc.doc-code
                                      )
          p-b-code        = 0
        .
        return . /* --->>>--- */
      end.

      assign
        p-curr-abbr = buf_currency.curr-abbr
      .

      { gbl/pftxvalg.i
        buf_bar-code.gds-code
        {&vat-tax-code}
        ?
        p-host-code
        p-obj-type
        p-obj-code
        v-vat-pc
      }

      find first buf_previos_doc-line exclusive-lock
        where buf_previos_doc-line.doc-code = buf_trn-doc.doc-code
          and buf_previos_doc-line.artic     = v-artic
          and buf_previos_doc-line.prod-code = v-prod-code
          and buf_previos_doc-line.prod-type = v-prod-type
        no-error .
      if available buf_previos_doc-line
      then do:
        assign
          p-artic         = buf_goods.artic
          p-name          = buf_goods.gds-name
          p-prod-name     = buf_clients.obj-name
          p-unit-base     = buf_goods.unit-base
          p-unit-cli      = buf_previos_doc-line.unit-cli
          p-price-cli     = string(buf_previos_doc-line.price-cli)
          p-cli-base-rate = string(buf_previos_doc-line.cli-base-rate)
          p-vat-pc        = string(buf_previos_doc-line.vat-pc)
          p-doc-qnty      = string( buf_previos_doc-line.doc-qnty / buf_previos_doc-line.cli-base-rate )
        .
      end.
      else do:
        find first buf_cli-gds no-lock
          where buf_cli-gds.cli-code  = buf_trn-doc.cli-code
            and buf_cli-gds.cli-type  = buf_trn-doc.cli-type
            and buf_cli-gds.host-code = buf_trn-doc.host-code
            and buf_cli-gds.artic     = v-artic
            and buf_cli-gds.prod-code = v-prod-code
            and buf_cli-gds.prod-type = v-prod-type
          no-error .
        if available buf_cli-gds
        then do:
          find first buf_cbr_doc-line no-lock
            where buf_cbr_doc-line.doc-code  = buf_cli-gds.in-code
              and buf_cbr_doc-line.artic     = buf_cli-gds.artic
              and buf_cbr_doc-line.prod-type = buf_cli-gds.prod-type
              and buf_cbr_doc-line.prod-code = buf_cli-gds.prod-code
            no-error .
          if available buf_cbr_doc-line
          then do:
            assign
              v-default-cli-base-rate = buf_cbr_doc-line.cli-base-rate
            .
          end.
        end.

        run cpprclig in this-procedure
          (input  buf_trn-doc.doc-code       /* pardoc-code       */
          ,input  buf_trn-doc.cli-code       /* parcli-code       */
          ,input  buf_trn-doc.cli-type       /* parcli-type       */
          ,input  buf_trn-doc.host-code      /* parhost-code      */
          ,input  buf_trn-doc.base-rate      /* parbase-rate      */
          ,input  buf_trn-doc.base-scale     /* parbase-scale     */
          ,input  buf_trn-doc.exch-rate      /* parexch-rate      */
          ,input  buf_trn-doc.exch-scale     /* parexch-scale     */
          ,input  buf_trn-doc.vat-type       /* parvat-type       */
          ,input  buf_trn-doc.slt-type       /* parslt-type       */
          ,input  buf_goods.artic            /* parartic          */
          ,input  buf_goods.prod-type        /* parprod-type      */
          ,input  buf_goods.prod-code        /* parprod-code      */
          ,input  false                      /* paris-cli-tax     */
          ,input  v-default-cli-base-rate    /* parcli-base-rate  */
          ,input  0                          /* partransport-rubl */
          ,input  0                          /* parother-rubl     */
          ,output       v-price-cli          /* parprice-cli      */
          ,output       v-price-base         /* parprice-base     */
          ,output       v-price-rubl         /* parprice-rubl     */
          ,input-output v-vat-pc             /* parvat-pc         */
          ,input-output v-slt-pc             /* parslt-pc         */
          ,input-output v-road-tax           /* parroad-tax       */
          ,input-output v-excise             /* parexcise         */
          ).

        assign
          p-artic         = buf_goods.artic
          p-name          = buf_goods.gds-name
          p-prod-name     = buf_clients.obj-name
          p-unit-base     = buf_goods.unit-base
          p-unit-cli      = buf_bar-code.unit-cli
          p-cli-base-rate = string(buf_bar-code.cli-base-rate)
          p-vat-pc        = string(v-vat-pc)
          p-doc-qnty      = string(0)
        .
        if v-rbisbase = true
        then do:
          assign
            p-price-cli = string(v-price-base * buf_bar-code.cli-base-rate)
          .
        end.
        else do:
          assign
            p-price-cli = string(v-price-rubl * buf_bar-code.cli-base-rate)
          .
        end.
      end.

      assign
        p-status        = '0':u
        p-error-message = '':u
      .
      return . /* --->>>--- */
    end.

    otherwise do:
      assign
        p-status        = '1'
        p-error-message = substitute('rt-bcdoc.p: Неизвестный тип документа &1'
                                    ,v-doc-type
                                    )
        p-b-code        = 0
      .
      return . /* --->>>--- */
    end.
  end.
end.