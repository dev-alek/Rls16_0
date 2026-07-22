block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rt-bcode.p $
$Archive: gbl/rt-bcode.p $

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
define input  parameter p-bar-code        as character no-undo .
define input  parameter p-fact-qnty       as decimal   no-undo .
define input  parameter p-inp-price       as decimal   no-undo .
define input  parameter p-is-cop-check    as logical   no-undo .
define output parameter p-status          as character no-undo .
define output parameter p-error-message   as character no-undo .
define output parameter p-b-code          as integer   no-undo .
define output parameter p-artic           as character no-undo .
define output parameter p-name            as character no-undo .
define output parameter p-prod-type       as character no-undo .
define output parameter p-prod-code       as integer   no-undo .
define output parameter p-prod-name       as character no-undo .
define output parameter p-doc-qnty        as character no-undo .
define output parameter p-unit-base       as character no-undo .
define output parameter p-doc-sum         as character no-undo .
define output parameter p-curr-abbr       as character no-undo .
define output parameter p-last-date       as character no-undo .
define output parameter p-price-docf      as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rt-bcode.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/rt-bcode.p $":U .
define variable vss-description as character no-undo init "Радиотерминал. Поиск товара по штрих-коду в документе".
{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/library.i      }
{ str/lib-trn.i      }
{ gbl/getcntxt.i def }
{ str/libbcrcn.i     }



define variable v-doc-type        as character  no-undo .
define variable v-doc-code        as character  no-undo .
define variable v-artic           as character  no-undo .
define variable v-prod-type       as character  no-undo .
define variable v-prod-code       as integer    no-undo .
define variable v-last-date       as date       no-undo .
define variable v-correct-price   as logical    no-undo .
define variable v-param-type      as character  no-undo .
define variable v-value-character as character  no-undo .
define variable v-value-date      as date       no-undo .
define variable v-value-decimal   as decimal    no-undo .
define variable v-value-integer   as integer    no-undo .
define variable v-value-logical   as logical    no-undo .
define variable v-tth             as handle     no-undo .
define variable v-divergence-prc  as decimal    no-undo .
define variable v-result          as character no-undo .
define variable v-type-bc         as character no-undo .
define variable v-weight          as decimal   no-undo .

define buffer buf_currency     for ub.currency .
define buffer buf_bar-code     for ub.bar-code .
define buffer buf_prod-bc      for ub.prod-bc .
define buffer buf_place        for ub.place .
define buffer buf_goods        for ub.goods .
define buffer buf_trn-doc      for ub.trn-doc .
define buffer buf_doc-line     for ub.doc-line .
define buffer buf_gds-dtl      for ub.gds-dtl .
define buffer buf_clients      for ub.clients .
define buffer buf_ord-doc-rcv  for ub.ord-doc-rcv .
define buffer buf_ord-line-rcv for ub.ord-line-rcv .
define buffer buf_parts        for ub.parts.
define buffer buf_units        for ub.units .
define buffer buf_contract     for ub.contract.

do
on error undo, return error return-value
:
  { str/sclspref.i }
  { str/bc-rcnz.i
    parparentproc
    p-bar-code
    0
    ''
    0
    no
    no
    varscales-pref
    varpgscales-pref
    v-result
    v-type-bc
    v-weight
    buf_bar-code
    buf_prod-bc
    buf_place
    no-error
  }
  if error-status :error
  then do:
    assign
      p-status        = '1'
      p-error-message = substitute( "Ошибка при поиске бар-кода &1&2&3&2&4"
                                  , p-bar-code
                                  , {&new-line}
                                  , error-status :get-message(1)
                                  , return-value
                                  )
      p-b-code        = ?
    .
    return . /* --->>>--- */
  end.
  if not available buf_bar-code
  then do:
    assign
      p-status        = '1'
      p-error-message = substitute('Ошибка поиска записи bar-code &1'
                                  ,p-bar-code
                                  )
      p-b-code        = ?
    .
    return . /* --->>>--- */
  end.
  assign
    p-b-code = buf_bar-code.b-code
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
      p-error-message = substitute('rt-bcode.p. Не найден товар &1 &2 &3'
                                  ,v-artic
                                  ,v-prod-type
                                  ,v-prod-code
                                  )
      p-b-code        = ?
    .
    return . /* --->>>--- */
  end.

  find first buf_units no-lock
    where buf_units.unit-name = buf_goods.unit-base
    no-error .
  if not available buf_units
  then do:
    assign
      p-status        = '1'
      p-error-message = substitute('rt-bcode.p. Не найдена единица измерения &1 для товара &2 &3 &4'
                                  ,buf_goods.unit-base
                                  ,v-artic
                                  ,v-prod-type
                                  ,v-prod-code
                                  )
      p-b-code        = ?
    .
    return . /* --->>>--- */
  end.

  /* Для серийного и штучного товара количество должно быть целым  */
  if lookup({&pieces}, buf_units.type) > 0
  or lookup({&serial}, buf_units.type) > 0
  then do:
    if p-fact-qnty <> truncate(p-fact-qnty, 0)
    then do:
      assign
        p-status        = '1'
        p-error-message = substitute('rt-bcode.p. Для штучного и серийного товаров резервируемое количество должно быть целым.&1Кол-во: &2'
                                    ,{&new-line}
                                    ,p-fact-qnty
                                    )
        p-b-code        = ?
      .
      return . /* --->>>--- */
    end.
  end.


  find first buf_clients no-lock
    where buf_clients.obj-type = buf_goods.prod-type
      and buf_clients.obj-code = buf_goods.prod-code
    no-error .
  if not available buf_clients
  then do:
    assign
      p-status        = '1'
      p-error-message = substitute('rt-bcode.p. Товар &1 &2 &3. Не найден производитель'
                                  ,v-artic
                                  ,v-prod-type
                                  ,v-prod-code
                                  )
      p-b-code        = ?
    .
    return . /* --->>>--- */
  end.

  { gbl/getcntxt.i get }
  /* считываем допустимый процент отклонения для весового товара */
  run adm/shattri.p ( input "get":U
                    , input  v-cntxt-obj-type
                    , input  v-cntxt-obj-code
                    , input  {&attr-ord-obj}
                    , input  {&attr-ord-obj_ord-wgt-div-prc}
                    , output v-value-character
                    , output v-value-date
                    , output v-value-decimal
                    , output v-value-integer
                    , output v-value-logical
                    , output v-param-type
                    , input-output table-handle v-tth
                    ) no-error .
  delete object v-tth.
  assign
    v-divergence-prc = if v-value-decimal <> ? then v-value-decimal else 0
    p-artic          = buf_goods.artic
    p-name           = buf_goods.gds-name
    p-prod-name      = buf_clients.obj-name
    p-unit-base      = buf_goods.unit-base
    p-prod-type      = buf_goods.prod-type
    p-prod-code      = buf_goods.prod-code
  .

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
          p-error-message = substitute('rt-bcode.p: Не найден документ поставки &1'
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
          p-error-message = substitute('rt-bcode.p: Не найдена валюта с кодом &1. Поставка &2'
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

      find first buf_ord-line-rcv no-lock
        where buf_ord-line-rcv.doc-code  = buf_ord-doc-rcv.doc-code
          and buf_ord-line-rcv.rcv-code  = v-doc-code
          and buf_ord-line-rcv.artic     = v-artic
          and buf_ord-line-rcv.prod-type = v-prod-type
          and buf_ord-line-rcv.prod-code = v-prod-code
        no-error .
      if not available buf_ord-line-rcv
      then do:
        assign
          p-status        = '1'
          p-error-message = substitute('В документе поставки &1 отсутствует строка для товара &2 со штрих-кодом &3.'
                                      ,p-unique-doc-code
                                      ,v-artic + ' ' + p-name + ' ' + p-prod-name
                                      ,p-bar-code
                                      )
          p-b-code        = 0
        .
        return . /* --->>>--- */
      end.

      /* todo - анализировать товар со шкалой */

      assign
        p-doc-qnty = string(buf_ord-line-rcv.qnty)
        p-doc-sum  = string(buf_ord-line-rcv.qnty * buf_ord-line-rcv.price-cli / buf_ord-line-rcv.cli-base-rate)
      .

      if p-fact-qnty < 0
      then do:
        assign
          p-status        = '1':u
          p-error-message = substitute('Фактическое количество &1 не может быть отрицательным':u
                                      ,p-fact-qnty
                                      )
        .
        return . /* --->>>--- */
      end.

      if lookup({&weight}, buf_units.type) = 0
      then do:
        if p-fact-qnty > buf_ord-line-rcv.qnty
        then do:
          assign
            p-status        = '1':u
            p-error-message = substitute('Фактическое количество &1 не может превышать количество по документу &2':u
                                        , p-fact-qnty
                                        , p-doc-qnty
                                        )
          .
          return . /* --->>>--- */
        end.
      end.
      else do:
        define variable v-max-div-qnty as decimal   no-undo .

        assign
          v-max-div-qnty = buf_ord-line-rcv.qnty * ( ( 100 + v-divergence-prc ) / 100)
        .
        if p-fact-qnty > v-max-div-qnty
        then do:
          assign
            p-status        = '1':u
            p-error-message = substitute('Фактическое количество &1 не может превышать количество по документу &2 более чем на &3%.&4Максимальное допустимое значение &5.':u
                                        , p-fact-qnty
                                        , p-doc-qnty
                                        , v-divergence-prc
                                        , {&new-line}
                                        , v-max-div-qnty
                                        )
          .
          return . /* --->>>--- */
        end.
      end.

      if p-inp-price <> ? and p-inp-price > buf_ord-line-rcv.price-cli
      then do:
        assign
          p-status        = '1':u
          p-error-message = substitute('Входная цена поставщика &1 не может превышать цену по поставке &2':u
                                      ,p-inp-price
                                      ,buf_ord-line-rcv.price-cli
                                      )
        .
        return . /* --->>>--- */
      end.

      assign
        p-price-docf = string(buf_ord-line-rcv.price-cli)
      .

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
          p-error-message = substitute('rt-bcode.p: Не найден складской документ &1'
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
          p-error-message = substitute('rt-bcode.p: Не найдена валюта с кодом &1. Складской документ &2'
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

      find first buf_doc-line no-lock
        where buf_doc-line.doc-code  = buf_trn-doc.doc-code
          and buf_doc-line.artic     = v-artic
          and buf_doc-line.prod-type = v-prod-type
          and buf_doc-line.prod-code = v-prod-code
        no-error .
      if not available buf_doc-line
      then do:
        assign
          p-status        = '1'
          p-error-message = substitute('В документе &1 отсутствует строка для товара &2 со штрих-кодом &3.'
                                      ,p-unique-doc-code
                                      ,v-artic + ' ' + p-name + ' ' + p-prod-name
                                      ,p-bar-code
                                      )
          p-b-code        = 0
        .
        return . /* --->>>--- */
      end.

      /* срок годности по товару из документа */
      for each buf_parts no-lock
        where buf_parts.obj-type  = buf_doc-line.obj-type
          and buf_parts.obj-code  = buf_doc-line.obj-code
          and buf_parts.artic     = buf_doc-line.artic
          and buf_parts.prod-type = buf_doc-line.prod-type
          and buf_parts.prod-code = buf_doc-line.prod-code
          and buf_parts.in-code   = buf_doc-line.doc-code
      :
        if  buf_parts.last-date <> ?
        and ( v-last-date = ?
              or
                (v-last-date <> ?
                and
                buf_parts.last-date < v-last-date
                )
            )
        then do:
          assign
            v-last-date = buf_parts.last-date
          .
        end.
      end. /* for each buf_parts no-lock */
      assign
        p-last-date   = ( if v-last-date = ? then "" else string( v-last-date , "99.99.9999" ) )
      .

      find first buf_gds-dtl no-lock
        where buf_gds-dtl.doc-code  = buf_trn-doc.doc-code
          and buf_gds-dtl.artic     = v-artic
          and buf_gds-dtl.prod-type = v-prod-type
          and buf_gds-dtl.prod-code = v-prod-code
          and buf_gds-dtl.prt-code  = buf_bar-code.node-code
        no-error .
      if not available buf_gds-dtl
      then do:
        assign
          p-status        = '1'
          p-error-message = substitute('В документе &1 отсутствует строка признака для товара &2 со штрих-кодом &3.'
                                      ,p-unique-doc-code
                                      ,v-artic + ' ' + p-name + ' ' + p-prod-name
                                      ,p-bar-code
                                      )
          p-b-code        = 0
        .
        return . /* --->>>--- */
      end.

      assign
        p-doc-qnty = string(buf_gds-dtl.doc-qnty)
        p-doc-sum  = string(buf_gds-dtl.doc-qnty * buf_doc-line.price-cli / buf_doc-line.cli-base-rate )
      .

      if p-fact-qnty < 0
      then do:
        assign
          p-status        = '1':u
          p-error-message = substitute('Фактическое количество &1 не может быть отрицательным':u
                                      ,p-fact-qnty
                                      )
        .
        return . /* --->>>--- */
      end.

      if p-fact-qnty > buf_gds-dtl.doc-qnty
      then do:
        assign
          p-status        = '1':u
          p-error-message = substitute('Фактическое количество &1 не может превышать количество по документу &2':u
                                      ,p-fact-qnty
                                      ,p-doc-qnty
                                      )
        .
        return . /* --->>>--- */
      end.
      if p-is-cop-check = yes and p-inp-price <> ?
      then do:

        find first buf_contract no-lock
          where buf_contract.host-code      = buf_trn-doc.host-code
            and buf_contract.contract-code  = buf_trn-doc.contract-code
        no-error.
        if available buf_contract
        then do:
          for each buf_parts no-lock
            where buf_parts.obj-type  = buf_doc-line.obj-type
              and buf_parts.obj-code  = buf_doc-line.obj-code
              and buf_parts.artic     = buf_doc-line.artic
              and buf_parts.prod-type = buf_doc-line.prod-type
              and buf_parts.prod-code = buf_doc-line.prod-code
              and buf_parts.in-code   = buf_doc-line.doc-code
          :
            { str/ckcntspc.i
              buf_trn-doc.host-code
              buf_trn-doc.contract-code
              buf_goods.gds-code
              p-inp-price
              buf_parts.VAT-type
              buf_parts.VAT-pc
              no-error }
            if error-status :error
            then do:
              assign
                p-status        = '2':u
                p-error-message = substitute( "&1&2&2&3"
                                            , return-value
                                            , {&new-line}
                                            , "Вы хотите принять товар?"
                                            )
              .
              return . /* --->>>--- */
            end.
          end. /* for each buf_parts no-lock */
        end. /* if available buf_contract */
      end. /* if p-is-cop-check = yes and p-inp-price <> ? */

      assign
        p-price-docf = string(buf_doc-line.price-cli)
      .

      assign
        p-status        = '0':u
        p-error-message = '':u
      .
      return . /* --->>>--- */
    end.

    when 'ОР':u
    then do:
      /* заявка */
      define buffer buf_ord-doc   for ub.ord-doc.
      define buffer buf_ord-line  for ub.ord-line.

      assign
        v-doc-code = entry(2, p-unique-doc-code, '|':u)
      .

      find first buf_ord-doc no-lock
        where buf_ord-doc.doc-code = v-doc-code
      no-error .
      if not available buf_ord-doc
      then do:
        assign
          p-status        = '1'
          p-error-message = substitute('rt-bcode.p: Не найден документ &1'
                                      ,p-unique-doc-code
                                      )
          p-b-code        = 0
        .
        return . /* --->>>--- */
      end.

      find first buf_currency no-lock
        where buf_currency.curr-code = buf_ord-doc.exch-code
      no-error .
      if not available buf_currency
      then do:
        assign
          p-status        = '1'
          p-error-message = substitute('rt-bcode.p: Не найдена валюта с кодом &1. Поставка &2'
                                      ,buf_ord-doc.exch-code
                                      ,buf_ord-doc.doc-code
                                      )
          p-b-code        = 0
        .
        return . /* --->>>--- */
      end.
      assign
        p-curr-abbr = buf_currency.curr-abbr
      .

      find first buf_ord-line no-lock
        where buf_ord-line.doc-code  = buf_ord-doc.doc-code
          and buf_ord-line.artic     = v-artic
          and buf_ord-line.prod-type = v-prod-type
          and buf_ord-line.prod-code = v-prod-code
        no-error .
      if not available buf_ord-line
      then do:
        assign
          p-status        = '1'
          p-error-message = substitute('В документе &1 отсутствует строка для товара &2 со штрих-кодом &3.'
                                      ,p-unique-doc-code
                                      ,v-artic + ' ' + p-name + ' ' + p-prod-name
                                      ,p-bar-code
                                      )
          p-b-code        = 0
        .
        return . /* --->>>--- */
      end.
      assign
        p-doc-qnty = string(buf_ord-line.qnty)
      .

      define variable v-curr-qnty       as decimal   no-undo .
      define variable v-curr-last-date  as date      no-undo .
      define variable v-curr-price-docf as decimal   no-undo .
      define variable v-fact-qnty       as decimal   no-undo .

      /* факт введенное с РТ кол-во */
      run gbl/rt-lingt.p ( input  p-unique-doc-code
                         , input  p-b-code
                         , output v-curr-qnty
                         , output v-curr-last-date
                         , output v-curr-price-docf
                         , output p-status
                         , output p-error-message
                         ) .
      if p-status <> '0'
      then do:
        assign
          p-status = '1':u
          p-b-code = 0
        .
        return . /* --->>>--- */
      end.
      assign
        p-doc-sum = string(buf_ord-line.qnty - v-curr-qnty)
      .
      if p-fact-qnty < 0
      then do:
        assign
          p-status        = '1':u
          p-error-message = substitute('Фактическое количество &1 не может быть отрицательным':u
                                      ,p-fact-qnty
                                      )
        .
        return . /* --->>>--- */
      end.
      assign
        v-fact-qnty = v-curr-qnty + p-fact-qnty
      .
      if lookup({&weight}, buf_units.type) = 0
      then do:
        if v-fact-qnty > buf_ord-line.qnty
        then do:
          assign
            p-status        = '1':u
            p-error-message = substitute('Фактическое количество &1 не может превышать количество по документу &2':u
                                        , v-fact-qnty
                                        , p-doc-qnty
                                        )
          .
          return . /* --->>>--- */
        end.
      end.
      else do:
        assign
          v-max-div-qnty = buf_ord-line.qnty * ( ( 100 + v-divergence-prc ) / 100)
        .
        if v-fact-qnty > v-max-div-qnty
        then do:
          assign
            p-status        = '1':u
            p-error-message = substitute('Фактическое количество &1 не может превышать количество по документу &2 более чем на &3%.&4Максимальное допустимое значение &5.Текущее зарегистрированное кол-во: &6':u
                                        , v-fact-qnty
                                        , p-doc-qnty
                                        , v-divergence-prc
                                        , {&new-line}
                                        , v-max-div-qnty
                                        , v-curr-qnty
                                        )
          .
          return . /* --->>>--- */
        end.
        if v-weight > 0
        then do:
          /* Для весового товара делаем финт ушами и выставляем не кол-во по документу, а вес сосканированного ШК */
          assign
            p-doc-qnty = string(v-weight)
            p-doc-sum  = string(buf_ord-line.qnty - v-curr-qnty)
          .
        end.
      end.

      if p-inp-price <> ? and p-inp-price > buf_ord-line.price-cli
      then do:
        assign
          p-status        = '1':u
          p-error-message = substitute('Входная цена поставщика &1 не может превышать цену по заявке &2':u
                                      ,p-inp-price
                                      ,buf_ord-line.price-cli
                                      )
        .
        return . /* --->>>--- */
      end.

      assign
        p-price-docf = string(buf_ord-line.price-cli)
      .

      assign
        p-status        = '0':u
        p-error-message = '':u
      .
      return . /* --->>>--- */
    end.
    when 'РН':U
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
          p-error-message = substitute('rt-bcode.p: Не найден складской документ &1'
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
          p-error-message = substitute('rt-bcode.p: Не найдена валюта с кодом &1. Складской документ &2'
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

      find first buf_doc-line no-lock
        where buf_doc-line.doc-code  = buf_trn-doc.doc-code
          and buf_doc-line.artic     = v-artic
          and buf_doc-line.prod-type = v-prod-type
          and buf_doc-line.prod-code = v-prod-code
        no-error .
      if not available buf_doc-line
      then do:
        assign
          p-status        = '1'
          p-error-message = substitute('В документе &1 отсутствует строка для товара &2 со штрих-кодом &3.'
                                      ,p-unique-doc-code
                                      ,v-artic + ' ' + p-name + ' ' + p-prod-name
                                      ,p-bar-code
                                      )
          p-b-code        = 0
        .
        return . /* --->>>--- */
      end.

      /* срок годности по товару из документа */
      for each buf_parts no-lock
        where buf_parts.obj-type  = buf_doc-line.obj-type
          and buf_parts.obj-code  = buf_doc-line.obj-code
          and buf_parts.artic     = buf_doc-line.artic
          and buf_parts.prod-type = buf_doc-line.prod-type
          and buf_parts.prod-code = buf_doc-line.prod-code
          and buf_parts.in-code   = buf_doc-line.doc-code
      :
        if  buf_parts.last-date <> ?
        and ( v-last-date = ?
              or
                (v-last-date <> ?
                and
                buf_parts.last-date < v-last-date
                )
            )
        then do:
          assign
            v-last-date = buf_parts.last-date
          .
        end.
      end. /* for each buf_parts no-lock */
      assign
        p-last-date   = ( if v-last-date = ? then "" else string( v-last-date , "99.99.9999" ) )
      .

      find first buf_gds-dtl no-lock
        where buf_gds-dtl.doc-code  = buf_trn-doc.doc-code
          and buf_gds-dtl.artic     = v-artic
          and buf_gds-dtl.prod-type = v-prod-type
          and buf_gds-dtl.prod-code = v-prod-code
          and buf_gds-dtl.prt-code  = buf_bar-code.node-code
        no-error .
      if not available buf_gds-dtl
      then do:
        assign
          p-status        = '1'
          p-error-message = substitute('В документе &1 отсутствует строка признака для товара &2 со штрих-кодом &3.'
                                      ,p-unique-doc-code
                                      ,v-artic + ' ' + p-name + ' ' + p-prod-name
                                      ,p-bar-code
                                      )
          p-b-code        = 0
        .
        return . /* --->>>--- */
      end.

      assign
        p-doc-qnty = string(buf_gds-dtl.doc-qnty)
        p-doc-sum  = string(buf_gds-dtl.doc-qnty * buf_doc-line.price-cli / buf_doc-line.cli-base-rate )
      .

      if p-fact-qnty < 0
      then do:
        assign
          p-status        = '1':u
          p-error-message = substitute('Фактическое количество &1 не может быть отрицательным':u
                                      ,p-fact-qnty
                                      )
        .
        return . /* --->>>--- */
      end.

      if p-fact-qnty > buf_gds-dtl.doc-qnty
      then do:
        assign
          p-status        = '1':u
          p-error-message = substitute('Фактическое количество &1 не может превышать количество по документу &2':u
                                      ,p-fact-qnty
                                      ,p-doc-qnty
                                      )
        .
        return . /* --->>>--- */
      end.
      if p-is-cop-check = yes and p-inp-price <> ?
      then do:

        find first buf_contract no-lock
          where buf_contract.host-code      = buf_trn-doc.host-code
            and buf_contract.contract-code  = buf_trn-doc.contract-code
        no-error.
        if available buf_contract
        then do:
          for each buf_parts no-lock
            where buf_parts.obj-type  = buf_doc-line.obj-type
              and buf_parts.obj-code  = buf_doc-line.obj-code
              and buf_parts.artic     = buf_doc-line.artic
              and buf_parts.prod-type = buf_doc-line.prod-type
              and buf_parts.prod-code = buf_doc-line.prod-code
              and buf_parts.in-code   = buf_doc-line.doc-code
          :
            { str/ckcntspc.i
              buf_trn-doc.host-code
              buf_trn-doc.contract-code
              buf_goods.gds-code
              p-inp-price
              buf_parts.VAT-type
              buf_parts.VAT-pc
              no-error
            }
            if error-status :error
            then do:
              assign
                p-status        = '2':u
                p-error-message = substitute( "&1&2&2&3"
                                            , return-value
                                            , {&new-line}
                                            , "Вы хотите принять товар?"
                                            )
              .
              return . /* --->>>--- */
            end.
          end. /* for each buf_parts no-lock */
        end. /* if available buf_contract */
      end. /* if p-is-cop-check = yes and p-inp-price <> ? */

      assign
        p-price-docf = string(buf_doc-line.price-cli)
      .

      assign
        p-status        = '0':u
        p-error-message = '':u
      .
      return . /* --->>>--- */
    end.
    otherwise do:
      assign
        p-status        = '1'
        p-error-message = substitute('rt-bcode.p: Неизвестный тип документа &1'
                                    ,v-doc-type
                                    )
        p-b-code        = 0
      .
      return . /* --->>>--- */
    end.
  end.
end.