block-level on error undo, throw.
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
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define new global shared variable g#libbcrcn as handle no-undo .
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref as character no-undo .
define variable varpgscales-pref as character no-undo .
define variable varscales-pref-type1 as character no-undo.
varscales-pref  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'sclspref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varscales-pref
  ,output varscales-pref-type1
  ) no-error .
if varscales-pref = ? then do:
  assign
  varscales-pref = '21,23,25':U.
end.
define variable varpgscales-pref-type1 as character no-undo.
varpgscales-pref  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'scpgpref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varpgscales-pref
  ,output varpgscales-pref-type1
  ) no-error .
if varpgscales-pref = ? then do:
  assign
  varpgscales-pref = '24IIIIIQQ000C,28IIIIIQQQ00C':U.
end.
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_bc-rcnz in g#libbcrcn
(
 input  parparentproc
,input  p-bar-code
,input  0
,input  ''
,input  0
,input  no
,input  no
,input  varscales-pref
,input  varpgscales-pref
,output v-result
,output v-type-bc
,output v-weight
,buffer buf_bar-code
,buffer buf_prod-bc
,buffer buf_place
) no-error.
  if error-status :error
  then do:
    assign
      p-status        = '1'
      p-error-message = substitute( "Ошибка при поиске бар-кода &1&2&3&2&4"
                                  , p-bar-code
                                  , chr(10)
                                  , error-status :get-message(1)
                                  , return-value
                                  )
      p-b-code        = ?
    .
    return .
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
    return .
  end.
  assign
    p-b-code = buf_bar-code.b-code
  .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run arptpc in g#library
  (input  buf_bar-code.gds-code
  ,output v-artic
  ,output v-prod-type
  ,output v-prod-code
  ) no-error .
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
    return .
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
    return .
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
    return .
  end.
  if lookup('шту':U, buf_units.type) > 0
  or lookup('сер':U, buf_units.type) > 0
  then do:
    if p-fact-qnty <> truncate(p-fact-qnty, 0)
    then do:
      assign
        p-status        = '1'
        p-error-message = substitute('rt-bcode.p. Для штучного и серийного товаров резервируемое количество должно быть целым.&1Кол-во: &2'
                                    ,chr(10)
                                    ,p-fact-qnty
                                    )
        p-b-code        = ?
      .
      return .
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
    return .
  end.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
  run adm/shattri.p ( input "get":U
                    , input  v-cntxt-obj-type
                    , input  v-cntxt-obj-code
                    , input  'ord-obj':U
                    , input  'ord-wgt-div-prc':U
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
        return .
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
        return .
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
        return .
      end.
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
        return .
      end.
      if lookup('вес':U, buf_units.type) = 0
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
          return .
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
                                        , chr(10)
                                        , v-max-div-qnty
                                        )
          .
          return .
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
        return .
      end.
      assign
        p-price-docf = string(buf_ord-line-rcv.price-cli)
      .
      assign
        p-status        = '0':u
        p-error-message = '':u
      .
      return .
    end.
    when 'ПН':u
    then do:
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
        return .
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
        return .
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
        return .
      end.
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
      end.
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
        return .
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
        return .
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
        return .
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
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_ckcntspc in g#lib-trn3
( input buf_trn-doc.host-code
 ,input buf_trn-doc.contract-code
 ,input buf_goods.gds-code
 ,input p-inp-price
 ,input buf_parts.VAT-type
 ,input buf_parts.VAT-pc
) no-error .
            if error-status :error
            then do:
              assign
                p-status        = '2':u
                p-error-message = substitute( "&1&2&2&3"
                                            , return-value
                                            , chr(10)
                                            , "Вы хотите принять товар?"
                                            )
              .
              return .
            end.
          end.
        end.
      end.
      assign
        p-price-docf = string(buf_doc-line.price-cli)
      .
      assign
        p-status        = '0':u
        p-error-message = '':u
      .
      return .
    end.
    when 'ОР':u
    then do:
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
        return .
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
        return .
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
        return .
      end.
      assign
        p-doc-qnty = string(buf_ord-line.qnty)
      .
      define variable v-curr-qnty       as decimal   no-undo .
      define variable v-curr-last-date  as date      no-undo .
      define variable v-curr-price-docf as decimal   no-undo .
      define variable v-fact-qnty       as decimal   no-undo .
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
        return .
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
        return .
      end.
      assign
        v-fact-qnty = v-curr-qnty + p-fact-qnty
      .
      if lookup('вес':U, buf_units.type) = 0
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
          return .
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
                                        , chr(10)
                                        , v-max-div-qnty
                                        , v-curr-qnty
                                        )
          .
          return .
        end.
        if v-weight > 0
        then do:
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
        return .
      end.
      assign
        p-price-docf = string(buf_ord-line.price-cli)
      .
      assign
        p-status        = '0':u
        p-error-message = '':u
      .
      return .
    end.
    when 'РН':U
    then do:
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
        return .
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
        return .
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
        return .
      end.
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
      end.
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
        return .
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
        return .
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
        return .
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
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_ckcntspc in g#lib-trn3
( input buf_trn-doc.host-code
 ,input buf_trn-doc.contract-code
 ,input buf_goods.gds-code
 ,input p-inp-price
 ,input buf_parts.VAT-type
 ,input buf_parts.VAT-pc
) no-error .
            if error-status :error
            then do:
              assign
                p-status        = '2':u
                p-error-message = substitute( "&1&2&2&3"
                                            , return-value
                                            , chr(10)
                                            , "Вы хотите принять товар?"
                                            )
              .
              return .
            end.
          end.
        end.
      end.
      assign
        p-price-docf = string(buf_doc-line.price-cli)
      .
      assign
        p-status        = '0':u
        p-error-message = '':u
      .
      return .
    end.
    otherwise do:
      assign
        p-status        = '1'
        p-error-message = substitute('rt-bcode.p: Неизвестный тип документа &1'
                                    ,v-doc-type
                                    )
        p-b-code        = 0
      .
      return .
    end.
  end.
end.
