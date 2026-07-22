block-level on error undo, throw.
define input  parameter p-doc-code as character no-undo .
define input  parameter p-cut-date as date      no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Расчет складского архива по товарам по документу".
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
    assign
      p-vss-parameters = substitute('&1|&2':u,p-doc-code,p-cut-date)
    .
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure factord :
  define input  parameter p-fact-date            as date    no-undo .
  define input  parameter p-fact-time            as integer no-undo .
  define input  parameter p-fact-num             as integer no-undo .
  define input  parameter p-shift-date           as date    no-undo .
  define input  parameter p-shift-num            as integer no-undo .
  define input  parameter p-shift-on             as logical no-undo .
  define output parameter p-fact-order           as decimal no-undo .
  define output parameter p-shift-end-fact-order as decimal no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  define variable vss-description as character no-undo init "factord: Определение порядкового номера документа".
  if p-fact-date = ?
  then do:
    return error "Не указана фактическая дата" .
  end.
  define variable v-fact-date-num as integer no-undo .
  assign
    v-fact-date-num = integer(p-fact-date)
  .
  if p-fact-num = ?
  or p-fact-num = 0
  then do:
    return error "Не задан p-fact-num " + string(p-fact-num) .
  end.
  if p-fact-num < 0
  then do:
    return error "Отрицательный fact-num " + string(p-fact-num) .
  end.
  if p-fact-num >= 100000000
  then do:
    return error "Недопустимо большой fact-num " + string(p-fact-num) .
  end.
  if p-shift-on = true
  then do:
    if p-shift-date = ?
    then do:
      return error "Не задана дата смены" .
    end.
    if p-shift-num = ?
    or p-shift-num = 0
    then do:
      return error "Не задан номер смены" .
    end.
  end.
  else do:
    assign
      p-shift-date = p-fact-date
      p-shift-num  = 24
    .
  end.
  define variable v-shift-offset as integer no-undo .
  if p-shift-date = p-fact-date
  then do:
    assign
      v-shift-offset = 1
    .
  end.
  if p-shift-date < p-fact-date
  then do:
    assign
      v-shift-offset = 0
    .
  end.
  if p-shift-date > p-fact-date
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильная дата закрытия смены" skip
      "Дата закрытия не смены не может быть раньше чем дата открытия смены" skip
      view-as alert-box error .
    undo, return error
      substitute("Дата закрытия не смены &1 не может быть раньше чем дата открытия смены &2"
        ,string(p-fact-date, '99/99/9999':U)
        ,string(p-shift-date, '99/99/9999':U)
        )
    .
  end.
  if p-shift-num < 1
  or p-shift-num > 24
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный номер смены" skip
      "p-shift-num" p-shift-num skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  assign
    p-fact-order           = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02 - 0.01
                           + p-fact-num     * 0.0000000001
    p-shift-end-fact-order = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02
    p-day-end-fact-order   = v-fact-date-num
                           + 0.99
  .
  if p-fact-order           <= v-fact-date-num
  or p-shift-end-fact-order <= v-fact-date-num
  or p-fact-order           >= p-shift-end-fact-order - 0.0000000001
  or p-shift-end-fact-order >= p-day-end-fact-order
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Внутренняя ошибка при генерации фактического номера" skip
      "p-fact-date"            p-fact-date            skip
      "p-fact-time"            p-fact-time            skip
      "p-fact-num"             p-fact-num             skip
      "p-shift-date"           p-shift-date           skip
      "p-shift-num"            p-shift-num            skip
      "p-shift-on"             p-shift-on             skip
      "p-shift-end-fact-order" p-shift-end-fact-order skip
      "p-day-end-fact-order"   p-day-end-fact-order   skip
      "v-fact-date-num"        v-fact-date-num        skip
      view-as alert-box error .
    undo, return error return-value .
  end.
end procedure.
procedure day-begin-fact-order :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-begin-fact-order as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      assign
        p-day-begin-fact-order = 0
      .
    end.
    else do:
      assign
        p-day-begin-fact-order = integer(p-fact-date)
      .
    end.
  end.
end procedure.
procedure factord-max-fact-order :
  define output parameter p-max-fact-order as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    run day-begin-fact-order in this-procedure
      (input  date(1, 1, 5000)
      ,output p-max-fact-order
      ) .
  end.
end procedure.
procedure factord-cut-archive :
  define input  parameter p-obj-type             as character no-undo .
  define input  parameter p-obj-code             as integer   no-undo .
  define input  parameter p-fact-date            as date      no-undo .
  define output parameter p-shift-on             as logical   no-undo .
  define output parameter p-shift-date           as date      no-undo .
  define output parameter p-shift-num            as integer   no-undo .
  define output parameter p-day-end-fact-order   as decimal   no-undo .
  define output parameter p-shift-end-fact-order as decimal   no-undo .
  define variable v-fact-order as decimal   no-undo .
  define buffer buf_shift-obj for ub.shift-obj .
  do
  on error undo, return error return-value
  :
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output p-shift-on
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута объекта" skip
        "Объект" p-obj-type p-obj-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-shift-on = false
    then do:
      assign
        p-shift-date               = ?
        p-shift-num                = 0
      .
    end.
    else do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно вычислить последнюю смену" skip
          "Отсутствует закрытая смена с датой большей чем дата инициализации архива" skip
          "Объект" p-obj-type p-obj-code skip
          "Дата" p-fact-date skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      find last buf_shift-obj share-lock
        where buf_shift-obj.obj-type = p-obj-type
          and buf_shift-obj.obj-code = p-obj-code
          and buf_shift-obj.shift-date <= p-fact-date
        use-index pi
        no-error .
      if available buf_shift-obj
      then do:
        if  buf_shift-obj.status_ = 'зкр':U
        then do:
          assign
            p-shift-date = buf_shift-obj.shift-date
            p-shift-num  = buf_shift-obj.shift-num
          .
        end.
        else do:
          message
            vss-workfile vss-revision vss-description skip
            "Невозможно вычислить последнюю смену" skip
            "Статус смены отличен от статуса" 'зкр':U skip
            "Объект" p-obj-type p-obj-code skip
            "Дата" p-fact-date skip
            "Смена" buf_shift-obj.shift-date buf_shift-obj.shift-num skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
      else do:
        assign
          p-shift-date = p-fact-date - 1
          p-shift-num  = 1
        .
      end.
    end.
    run factord in this-procedure
      (input  p-fact-date
      ,input  1
      ,input  1
      ,input  p-shift-date
      ,input  p-shift-num
      ,input  p-shift-on
      ,output v-fact-order
      ,output p-shift-end-fact-order
      ,output p-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры factord"
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure factord-lock-shift :
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-fact-date as date      no-undo .
  define parameter buffer buf_shift-obj for ub.shift-obj .
  define variable v-shift-on      as logical   no-undo .
  define variable v-extra-message as character no-undo .
  define variable v-error as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output v-shift-on
  ) no-error .
    if error-status :error
    then do:
      v-error = substitute("Ошибка при определении атрибута объекта  &1 &2 &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value) .
      undo, return error v-error .
    end.
    if v-shift-on = true
    then do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        find last buf_shift-obj
          where buf_shift-obj.obj-type = p-obj-type
            and buf_shift-obj.obj-code = p-obj-code
            and buf_shift-obj.status_  = 'зкр':U
          use-index stts
          no-error .
        if available buf_shift-obj
        then do:
          assign
            v-extra-message =
                  substitute("Дата начала последеней закрытой смены на объекте &1"
                            ,string(buf_shift-obj.shift-date, '99/99/9999':u)
                            )
          .
        end.
        v-error = substitute("Ошибка при блокировке смены объекта  &1 &2 Отсутствует закрытая смена с датой большей чем указанная дата  &5  &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value , p-fact-date) .
        undo, return error v-error .
      end.
    end.
  end.
end procedure.
procedure factord-end-day :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      return error "Не указана фактическая дата" .
    end.
    assign
      p-day-end-fact-order = integer(p-fact-date) + 0.99
    .
  end.
end procedure.
procedure factord-to-date :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-date  as date    no-undo .
  define variable v-ref-date  as date      no-undo .
  define variable v-ref-delta as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
      v-ref-date  = date(1, 1, 2000)
    .
    assign
      v-ref-delta = integer(truncate(p-fact-order, 0)) - integer(v-ref-date)
    .
    assign
      p-fact-date = v-ref-date + v-ref-delta
    .
  end.
end procedure.
procedure factord-to-fact-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-num   as integer no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)
    .
    assign
      p-fact-num = (p-fact-order - v-fact-order-trunc ) * 10000000000
    .
  end.
end procedure.
procedure factord-to-shift-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-shift-num   as integer no-undo .
  define variable  p-shift-numd  as decimal   no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)  - truncate(p-fact-order,0)
    .
    if v-fact-order-trunc < 0.5 then do:
      v-fact-order-trunc = v-fact-order-trunc + 0.5.
    end.
    assign
      p-shift-numd = (( v-fact-order-trunc  * 100 - 50 ) + 1 ) / 2
      .
     assign
      p-shift-num = truncate (p-shift-numd , 0)
    .
  end.
end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure prl-vat:
  define input parameter parrecid as recid no-undo.
    define output parameter price-rubl-with-tax-saleprl    like ub.doc-line.price-rubl no-undo.
    define output parameter price-base-with-tax-saleprl    like ub.doc-line.price-base no-undo.
    define output parameter price-rubl-without-tax-saleprl like ub.doc-line.price-rubl no-undo.
    define output parameter price-base-without-tax-saleprl like ub.doc-line.price-base no-undo.
    define output parameter vat-base-saleprl               like ub.doc-line.price-base no-undo.
    define output parameter vat-rubl-saleprl               like ub.doc-line.price-rubl no-undo.
    define output parameter vat-base-buyerprl              like ub.doc-line.price-base no-undo.
    define output parameter vat-rubl-buyerprl              like ub.doc-line.price-rubl no-undo.
    define output parameter slt-base-saleprl               like ub.doc-line.price-base no-undo.
    define output parameter slt-rubl-saleprl               like ub.doc-line.price-rubl no-undo.
    define output parameter road-tax-base-saleprl          like ub.doc-line.road-tax   no-undo.
    define output parameter road-tax-rubl-saleprl          like ub.doc-line.road-tax   no-undo.
    define output parameter excise-base-saleprl            like ub.doc-line.price-base no-undo.
    define output parameter excise-rubl-saleprl            like ub.doc-line.price-rubl no-undo.
    define output parameter discnt-base-saleprl            like ub.gds-dtl.discnt-base no-undo.
    define output parameter discnt-rubl-saleprl            like ub.gds-dtl.discnt-rubl no-undo.
    define buffer out-vatp_gds-dtlprl     for ub.gds-dtl.
    define buffer buf_out-vatp_gds-dtlprl for ub.gds-dtl.
    define buffer out-vatp_partsprl       for ub.parts.
    define buffer out-vatp_sysconfprl     for ub.sysconf.
    define buffer out-vatp_doc-lineprl    for ub.doc-line.
    define buffer out-vatp_goodsprl       for ub.goods.
    define buffer out-vatp_trn-docprl     for ub.trn-doc.
    define buffer out-vatp_doc-attrprl    for ub.doc-attr.
    define variable varprice-base-consprl      like ub.doc-line.price-base initial 0.00 no-undo.
    define variable varprice-rubl-consprl      like ub.doc-line.price-rubl initial 0.00 no-undo.
    define variable varfrm-cnsv-typeprl         as   character                           no-undo.
    define variable varfrm-cnsvprl              as   character                           no-undo.
    define variable varroot-nodeprl             as   integer                             no-undo.
    define variable varempty-scaleprl           as   logical                             no-undo.
    define variable varis-cons-parts-haveprl    as   logical                             no-undo.
    define variable varsum-base-factovpprl      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-factovpprl      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-factovpprl      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-factovpprl  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-factovpprl      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-base-docovpprl       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-docovpprl       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-docovpprl       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-docovpprl   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-docovpprl       like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-factovpprl      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-factovpprl      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-factovpprl      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-factovpprl  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-factovpprl      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-docovpprl       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-docovpprl       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-docovpprl       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-docovpprl   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-docovpprl       like ub.gds-dtl.price-base               no-undo.
    define variable varfact-qntyprl             like ub.parts.fact-qnty                  no-undo.
    define variable varcons-qntyprl             like ub.parts.fact-qnty                  no-undo.
    define variable varis-one-gds-dtlprl        as   logical                             no-undo.
    define variable varcurprlprice-base         like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurprlprice-rubl         like ub.gds-dtl.price-base               no-undo.
    define variable varcurprldiscnt-base        like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurprldiscnt-rubl        like ub.gds-dtl.price-base               no-undo.
    define variable varoutvprbprl               as   character                           no-undo.
    define variable out-vatp-have-vat-sltprl    as   logical initial yes                 no-undo.
    define buffer   in-vatp-trn-docoprl  for ub.trn-doc .
    define buffer   in-vatp-partsoprl    for ub.parts   .
    define buffer   in-vatp-docoprl      for ub.trn-doc .
    define buffer   in-vatp-goodsoprl    for ub.goods   .
    define buffer   in-vatp-sysconfoprl  for ub.sysconf .
    define buffer   in-vatp_doc-attroprl for ub.doc-attr.
    define variable in-vatp-have-vat-sltoprl       as   logical initial yes    no-undo.
    define variable vat-pc-locoprl                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprboprl                  as   character              no-undo.
    define variable slt-pc-locoprl                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rateoprl              as   decimal                no-undo.
    define variable price-rubl-with-tax-locoprl    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-locoprl    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-locoprl     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-locoprl like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-locoprl like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-locoprl  like ub.doc-line.price-base no-undo.
    define variable vat-base-locoprl               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-locoprl               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-locoprl                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-locoprl               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-locoprl               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-locoprl                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-locoprl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-locoprl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-locoprl           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-locoprl         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-locoprl         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-locoprl          like ub.doc-line.price-rubl no-undo.
    define variable other-base-locoprl             like ub.doc-line.price-base no-undo.
    define variable other-rubl-locoprl             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-locoprl              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-locoprl          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdoprl             as   character              no-undo.
    define variable varinvatp-typeoprl             as   character              no-undo.
  define buffer bf_price-list for ub.price-list.
  define buffer bf_goods      for ub.goods.
  define buffer bf_sysconf    for ub.sysconf.
  define buffer bf_parts      for ub.parts.
  define variable varbase-rate   like ub.trn-doc.base-rate     no-undo.
  define variable varbase-scale  like ub.trn-doc.base-scale    no-undo.
  define variable varroad-tax    like ub.price-list.road-tax   no-undo.
  define variable varexcise      like ub.price-list.excise     no-undo.
  define variable varvat-pc      like ub.doc-line.vat-pc       no-undo.
  define variable varslt-pc      like ub.doc-line.slt-pc       no-undo.
  define variable varprice-base  like ub.price-list.price-sale no-undo.
  define variable varprice-rubl  like ub.price-list.price-sale no-undo.
  define variable vardiscnt-base like ub.price-list.price-sale no-undo.
  define variable vardiscnt-rubl like ub.price-list.price-sale no-undo.
  define variable v-host-code    like ub.sysconf.host-code     no-undo.
  define variable vardoc-num     like ub.price-list.doc-num    no-undo.
  define variable vardoc-code    like ub.price-list.doc-num    no-undo.
  define variable varobj-type    like ub.price-list.obj-type   no-undo.
  define variable varobj-code    like ub.price-list.obj-code   no-undo.
  define variable varartic       like ub.price-list.artic      no-undo.
  define variable varprod-type   like ub.price-list.prod-type  no-undo.
  define variable varprod-code   like ub.price-list.prod-code  no-undo.
  define variable varfact-qnty   like ub.price-list.doc-qnty   no-undo.
  define variable varcons-vat-pc like ub.doc-line.vat-pc       no-undo.
  define variable varext-doc-type like ub.trn-doc.ext-doc-type no-undo.
  define variable vardoc-qnty     like ub.price-list.doc-qnty no-undo.
  define variable vardoc-type     as   character              no-undo.
  do
  on error undo, return error "Ошибка при вызове процедуры prl-vat."
  :
    find first bf_price-list no-lock
      where recid(bf_price-list) = parrecid
      no-error .
    if not available bf_price-list
    then do:
      return error "Ошибка во входящих параметрах prl-vat.i" .
    end.
    find first bf_goods no-lock
      where bf_goods.artic     = bf_price-list.artic
        and bf_goods.prod-type = bf_price-list.prod-type
        and bf_goods.prod-code = bf_price-list.prod-code
      no-error .
    if not available bf_goods
    then do:
      undo, return error substitute("Не найден товар &1 &2 &3 для переоценки с кодом &4",bf_price-list.artic,bf_price-list.prod-type,bf_price-list.prod-code,parrecid).
    end.
    assign
      varvat-pc = bf_price-list.vat-pc
      varslt-pc = bf_price-list.slt-pc
    .
    if varvat-pc = ?
    then do:
      undo, return error substitute("В переоценке &1 для товара &2 &3 &4 не задан НДС",bf_price-list.doc-num,bf_price-list.artic,bf_price-list.prod-type,bf_price-list.prod-code).
    end.
    if varslt-pc = ?
    then do:
      undo, return error substitute("В переоценке &1 для товара &2 &3 &4 не задан НП",bf_price-list.doc-num,bf_price-list.artic,bf_price-list.prod-type,bf_price-list.prod-code).
    end.
    assign
      varbase-rate   = 1
      varbase-scale  = 1
      varroad-tax    = bf_price-list.road-tax
      varexcise      = bf_price-list.excise
      varprice-base  = bf_price-list.price-sale
      varprice-rubl  = bf_price-list.price-sale
      vardiscnt-base = 0
      vardiscnt-rubl = 0
    .
    assign
      varfact-qnty = 0
    .
    for each bf_parts no-lock
      where bf_parts.out-code   = bf_price-list.doc-num
        and bf_parts.obj-type   = bf_price-list.obj-type
        and bf_parts.obj-code   = bf_price-list.obj-code
        and bf_parts.artic      = bf_price-list.artic
        and bf_parts.prod-type  = bf_price-list.prod-type
        and bf_parts.prod-code  = bf_price-list.prod-code
    :
      assign
        varfact-qnty = varfact-qnty + bf_parts.fact-qnty
      .
    end.
    assign
      vardoc-num   = bf_price-list.doc-num
      vardoc-code  = bf_price-list.doc-num
      varobj-type  = bf_price-list.obj-type
      varobj-code  = bf_price-list.obj-code
      varartic     = bf_price-list.artic
      varprod-type = bf_price-list.prod-type
      varprod-code = bf_price-list.prod-code
      vardoc-qnty  = varfact-qnty
      varext-doc-type = 'ot':U
    .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  bf_price-list.obj-type
  ,input  bf_price-list.obj-code
  ,output v-host-code
  )  .
    find first bf_sysconf no-lock
      where bf_sysconf.host-code = v-host-code
      .
    if bf_sysconf.cons-vat-pc = ?
    then do:
      return error "Не задан консигнационный НДС по фирме." .
    end.
    else do:
      assign
        varcons-vat-pc = bf_sysconf.cons-vat-pc
      .
    end.
if varext-doc-type = 'ot':U or
   varext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-sltprl = yes.
end.
else do:
  find first out-vatp_doc-attrprl no-lock
    where out-vatp_doc-attrprl.doc-code  = vardoc-code
      and out-vatp_doc-attrprl.attr-code = 'envd':U
      no-error .
  if not available out-vatp_doc-attrprl then do:
    assign
      out-vatp-have-vat-sltprl = yes.
  end.
  else do:
     out-vatp-have-vat-sltprl = no.
  end.
end.
find first out-vatp_goodsprl where out-vatp_goodsprl.artic     = varartic     and
                                   out-vatp_goodsprl.prod-type = varprod-type and
                                   out-vatp_goodsprl.prod-code = varprod-code no-lock.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  varartic
  ,input  varprod-type
  ,input  varprod-code
  ,output varroot-nodeprl
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" varartic varprod-type varprod-code skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  varroot-nodeprl
  ,input  'empty-scale=request'
  ,output varempty-scaleprl
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении атрибута признака" skip
    "Артикул" varartic varprod-type varprod-code skip
    "Признак" varroot-nodeprl skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprbprl
  )  .
if varoutvprbprl = "base":u then do:
  assign
        road-tax-base-saleprl    =  (if varroad-tax = ? then 0 else varroad-tax * 1)
    excise-base-saleprl      =  (if varexcise   = ? then 0 else varexcise   * 1)
  .
end.
else do:
  assign
        road-tax-base-saleprl    =  (if varroad-tax = ? then 0 else varroad-tax / varbase-rate * varbase-scale)
    excise-base-saleprl      =  (if varexcise   = ? then 0 else varexcise   / varbase-rate * varbase-scale)
  .
end.
if varoutvprbprl = "rubl":u then do:
  assign
        road-tax-rubl-saleprl    = (if varroad-tax = ? then 0 else varroad-tax * 1)
    excise-rubl-saleprl      = (if varexcise   = ? then 0 else varexcise   * 1) .
end.
else do:
  assign
        road-tax-rubl-saleprl    = (if varroad-tax = ? then 0 else varroad-tax * varbase-rate / varbase-scale)
    excise-rubl-saleprl      = (if varexcise   = ? then 0 else varexcise   * varbase-rate / varbase-scale) .
end.
assign
  varis-cons-parts-haveprl =  no.
assign
  varfact-qntyprl       = 0
  varcons-qntyprl       = 0
  varprice-base-consprl = 0
  varprice-rubl-consprl = 0.
find first out-vatp_doc-lineprl where
           out-vatp_doc-lineprl.doc-code   = vardoc-num
       and out-vatp_doc-lineprl.artic      = varartic
       and out-vatp_doc-lineprl.prod-type  = varprod-type
       and out-vatp_doc-lineprl.prod-code  = varprod-code no-lock no-error.
if available out-vatp_doc-lineprl           and
  (out-vatp_doc-lineprl.status_ = 'запрос':U or out-vatp_goodsprl.gds-type = 'у':U) then do:
  assign
    varfact-qntyprl = out-vatp_doc-lineprl.fact-qnty.
end.
else do:
  for each out-vatp_partsprl where out-vatp_partsprl.out-code   = vardoc-num
                               and out-vatp_partsprl.obj-type   = varobj-type
                               and out-vatp_partsprl.obj-code   = varobj-code
                               and out-vatp_partsprl.artic      = varartic
                               and out-vatp_partsprl.prod-type  = varprod-type
                               and out-vatp_partsprl.prod-code  = varprod-code no-lock :
    if out-vatp_partsprl.purch-code = 2 then do:
assign
  price-rubl-with-tax-locoprl = out-vatp_partsprl.price-rubl
  price-base-with-tax-locoprl = out-vatp_partsprl.price-base
.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprboprl
  )  .
  if out-vatp_partsprl.out-code = 'free-zone':U     or
     out-vatp_partsprl.out-code = 'out-zone':U   or
     out-vatp_partsprl.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-sltoprl = yes.
  end.
  else do:
    find first in-vatp_doc-attroprl no-lock
      where in-vatp_doc-attroprl.doc-code  = out-vatp_partsprl.out-code
        and in-vatp_doc-attroprl.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attroprl then do:
      assign
        in-vatp-have-vat-sltoprl = yes.
    end.
    else do:
         in-vatp-have-vat-sltoprl = no.
    end.
  end.
  assign
   price-cli-with-tax-locoprl = out-vatp_partsprl.price-cli
   cli-base-rateoprl          = out-vatp_partsprl.cli-base-rate.
  ASSIGN   road-tax-base-locoprl  = (if out-vatp_partsprl.road-tax-base  = ? then 0 else out-vatp_partsprl.road-tax-base)
           road-tax-rubl-locoprl  = (if out-vatp_partsprl.road-tax-rubl  = ? then 0 else out-vatp_partsprl.road-tax-rubl).
  ASSIGN  transport-base-locoprl = (if out-vatp_partsprl.transport-base = ? then 0 else out-vatp_partsprl.transport-base)
          transport-rubl-locoprl = (if out-vatp_partsprl.transport-rubl = ? then 0 else out-vatp_partsprl.transport-rubl)
          other-base-locoprl     = (if out-vatp_partsprl.other-base     = ? then 0 else out-vatp_partsprl.other-base)
          other-rubl-locoprl     = (if out-vatp_partsprl.other-rubl     = ? then 0 else out-vatp_partsprl.other-rubl)
          vat-pc-locoprl         = (if out-vatp_partsprl.vat-pc         = ? then 0 else out-vatp_partsprl.vat-pc)
          slt-pc-locoprl         = (if out-vatp_partsprl.slt-pc         = ? then 0 else out-vatp_partsprl.slt-pc).
          ASSIGN   slt-base-locoprl    = (if in-vatp-have-vat-sltoprl = no then 0 else (price-base-with-tax-locoprl - ((if road-tax-base-locoprl  = ? then 0 else road-tax-base-locoprl) + (if transport-base-locoprl = ? then 0 else transport-base-locoprl) + (if other-base-locoprl = ? then 0 else other-base-locoprl)))                           * slt-pc-locoprl / (100 + slt-pc-locoprl))                        vat-base-locoprl    = (if in-vatp-have-vat-sltoprl = no then 0 else (price-base-with-tax-locoprl - ((if road-tax-base-locoprl  = ? then 0 else road-tax-base-locoprl) + (if transport-base-locoprl = ? then 0 else transport-base-locoprl) + (if other-base-locoprl = ? then 0 else other-base-locoprl))) * (1 - slt-pc-locoprl / (100 + slt-pc-locoprl)) * vat-pc-locoprl / (100 + vat-pc-locoprl)).
    ASSIGN   slt-rubl-locoprl    = (if in-vatp-have-vat-sltoprl = no then 0 else (price-rubl-with-tax-locoprl - ((if road-tax-rubl-locoprl  = ? then 0 else road-tax-rubl-locoprl) + (if transport-rubl-locoprl = ? then 0 else transport-rubl-locoprl) + (if other-rubl-locoprl = ? then 0 else other-rubl-locoprl)))                           * slt-pc-locoprl / (100 + slt-pc-locoprl))                        vat-rubl-locoprl    = (if in-vatp-have-vat-sltoprl = no then 0 else (price-rubl-with-tax-locoprl - ((if road-tax-rubl-locoprl  = ? then 0 else road-tax-rubl-locoprl) + (if transport-rubl-locoprl = ? then 0 else transport-rubl-locoprl) + (if other-rubl-locoprl = ? then 0 else other-rubl-locoprl))) * (1 - slt-pc-locoprl / (100 + slt-pc-locoprl)) * vat-pc-locoprl / (100 + vat-pc-locoprl)).
  assign
    exch-rate-cli-locoprl = (out-vatp_partsprl.price-rubl - transport-rubl-locoprl - other-rubl-locoprl - road-tax-rubl-locoprl - (if out-vatp_partsprl.vat-type <> 'в т. ч.':U then vat-rubl-locoprl else 0) - (if out-vatp_partsprl.slt-type <> 'в т. ч.':U then slt-rubl-locoprl else 0)) / out-vatp_partsprl.price-cli .
  assign
    slt-cli-locoprl        = slt-rubl-locoprl       / exch-rate-cli-locoprl
    vat-cli-locoprl        = vat-rubl-locoprl       / exch-rate-cli-locoprl
    road-tax-cli-locoprl   = road-tax-rubl-locoprl  / exch-rate-cli-locoprl
    transport-cli-locoprl  = 0
    other-cli-locoprl      = 0
  .
ASSIGN
          price-base-without-tax-locoprl = price-base-with-tax-locoprl - vat-base-locoprl - slt-base-locoprl - ((if road-tax-base-locoprl  = ? then 0 else road-tax-base-locoprl) + (if transport-base-locoprl = ? then 0 else transport-base-locoprl) + (if other-base-locoprl = ? then 0 else other-base-locoprl))
    price-rubl-without-tax-locoprl = price-rubl-with-tax-locoprl - vat-rubl-locoprl - slt-rubl-locoprl - ((if road-tax-rubl-locoprl  = ? then 0 else road-tax-rubl-locoprl) + (if transport-rubl-locoprl = ? then 0 else transport-rubl-locoprl) + (if other-rubl-locoprl = ? then 0 else other-rubl-locoprl))
.
      assign
        varprice-base-consprl = varprice-base-consprl + (price-base-with-tax-locoprl - (if road-tax-base-locoprl = ? then 0 else road-tax-base-locoprl))* out-vatp_partsprl.fact-qnty
        varprice-rubl-consprl = varprice-rubl-consprl + (price-rubl-with-tax-locoprl - (if road-tax-rubl-locoprl = ? then 0 else road-tax-rubl-locoprl))* out-vatp_partsprl.fact-qnty.
      assign
        varis-cons-parts-haveprl = yes
        varcons-qntyprl          = varcons-qntyprl + out-vatp_partsprl.fact-qnty.
    end.
    assign
      varfact-qntyprl = varfact-qntyprl + out-vatp_partsprl.fact-qnty.
  end.
end.
assign
  varprice-base-consprl = varprice-base-consprl / varcons-qntyprl
  varprice-rubl-consprl = varprice-rubl-consprl / varcons-qntyprl.
if varprice-base-consprl = ? then do:
  assign
    varprice-base-consprl = 0.
end.
if varprice-rubl-consprl = ? then do:
  assign
    varprice-rubl-consprl = 0.
end.
assign
    slt-base-saleprl               = (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base                - road-tax-base-saleprl) * varSLT-pc / (100 + varSLT-pc)
  vat-base-buyerprl              = (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base - (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base                - road-tax-base-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-base-saleprl) * varvat-pc / (100 + varvat-pc)
  discnt-base-saleprl            = vardiscnt-base
  price-base-with-tax-saleprl    = (varprice-base - vardiscnt-base)
    slt-rubl-saleprl               = (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl                - road-tax-rubl-saleprl) * varSLT-pc / (100 + varSLT-pc)
  vat-rubl-buyerprl              = (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl - (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl                - road-tax-rubl-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-rubl-saleprl) * varvat-pc / (100 + varvat-pc)
  discnt-rubl-saleprl            = vardiscnt-rubl
  price-rubl-with-tax-saleprl    = (varprice-rubl - vardiscnt-rubl)
  .
if vardoc-type = 'инв':U then do:
  assign
    varfact-qntyprl = vardoc-qnty.
end.
else do:
  assign
    varfact-qntyprl = varfact-qnty.
end.
if varis-cons-parts-haveprl = no then do:
  assign
        vat-base-saleprl               = (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base - (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base                - road-tax-base-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-base-saleprl) * varvat-pc / (100 + varvat-pc)
        vat-rubl-saleprl               = (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl - (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl                - road-tax-rubl-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-rubl-saleprl) * varvat-pc / (100 + varvat-pc).
end.
else do:
  if vardoc-type = 'инв':U then do:
    assign
            vat-base-saleprl               = (if out-vatp-have-vat-sltprl = no then 0 else (((varprice-base - vardiscnt-base) - (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base                - road-tax-base-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-base-saleprl - varprice-base-consprl) * varcons-vat-pc / (100 + varcons-vat-pc) * vardoc-qnty * varcons-qntyprl / varfact-qntyprl + ((varprice-base - vardiscnt-base) - (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base                - road-tax-base-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-base-saleprl) * varvat-pc / (100 + varvat-pc) * vardoc-qnty * (varfact-qntyprl - varcons-qntyprl) / varfact-qntyprl) / varfact-qntyprl)
            vat-rubl-saleprl               = (if out-vatp-have-vat-sltprl = no then 0 else (((varprice-rubl - vardiscnt-rubl) - (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl                - road-tax-rubl-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-rubl-saleprl - varprice-rubl-consprl) * varcons-vat-pc / (100 + varcons-vat-pc) * vardoc-qnty * varcons-qntyprl / varfact-qntyprl + ((varprice-rubl - vardiscnt-rubl) - (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl                - road-tax-rubl-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-rubl-saleprl) * varvat-pc / (100 + varvat-pc) * vardoc-qnty * (varfact-qntyprl - varcons-qntyprl) / varfact-qntyprl) / varfact-qntyprl)
     .
  end.
  else do:
    assign
            vat-base-saleprl               = (if out-vatp-have-vat-sltprl = no then 0 else (((varprice-base - vardiscnt-base) - (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base                - road-tax-base-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-base-saleprl - varprice-base-consprl) * varcons-vat-pc / (100 + varcons-vat-pc) * varfact-qnty * varcons-qntyprl / varfact-qntyprl + ((varprice-base - vardiscnt-base) - (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base                - road-tax-base-saleprl) * varSLT-pc / (100 + varSLT-pc) - varprice-base-consprl) * varvat-pc / (100 + varvat-pc) * varfact-qnty * (varfact-qntyprl - varcons-qntyprl) / varfact-qntyprl) / varfact-qntyprl)
            vat-rubl-saleprl               = (if out-vatp-have-vat-sltprl = no then 0 else (((varprice-rubl - vardiscnt-rubl) - (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl                - road-tax-rubl-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-rubl-saleprl - varprice-rubl-consprl) * varcons-vat-pc / (100 + varcons-vat-pc) * varfact-qnty * varcons-qntyprl / varfact-qntyprl + ((varprice-rubl - vardiscnt-rubl) - (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl                - road-tax-rubl-saleprl) * varSLT-pc / (100 + varSLT-pc) - varprice-rubl-consprl) * varvat-pc / (100 + varvat-pc) * varfact-qnty * (varfact-qntyprl - varcons-qntyprl) / varfact-qntyprl) / varfact-qntyprl)
     .
  end.
end.
assign
price-base-without-tax-saleprl = price-base-with-tax-saleprl - vat-base-saleprl - slt-base-saleprl - road-tax-base-saleprl
price-rubl-without-tax-saleprl = price-rubl-with-tax-saleprl - vat-rubl-saleprl - slt-rubl-saleprl - road-tax-rubl-saleprl.
  end.
end procedure.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cur-time :
   define output parameter p-today as date      no-undo .
   define output parameter p-time  as integer   no-undo .
  do
  on error undo, return error
  :
    define variable v-date1 as date      no-undo .
    define variable v-date2 as date      no-undo .
    define variable v-time  as integer   no-undo .
    assign
      v-date1 = today
      v-time  = time
      v-date2 = today
    .
    if v-date1 <> v-date2
    then do:
      assign
        v-date1 = today
        v-time  = v-time
      .
    end.
    assign
      p-today = v-date1
      p-time  = v-time
    .
  end.
end.
function cur-time-date returns character
:
  return string(today, '99/99/9999':U) .
end.
function cur-time-mjd returns decimal
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return integer(v-date) - 2400002 + (v-time / 86400) .
end.
function cur-time-get-ending-index returns integer
(input p-number as integer
)
:
  if p-number < 0
  or p-number = ?
  then do:
    return 1 .
  end.
  define variable v-rest as integer   no-undo .
  assign
    p-number = p-number modulo 100
  .
  if p-number < 20
  then do:
    assign
      v-rest = p-number
    .
  end.
  else do:
    assign
      v-rest = p-number modulo 10
    .
  end.
  case v-rest :
    when 1
    then do:
      return 2 .
    end.
    when 2 or
    when 3 or
    when 4
    then do:
      return 3 .
    end.
    otherwise do:
      return 1 .
    end.
  end case .
end.
procedure cur-time-mjd-to-date :
   define input  parameter i-mjd-diff as decimal no-undo.
   define output parameter o-Date     as date    no-undo.
   define output parameter o-Time     as integer no-undo.
   define variable v-day-number as integer   no-undo .
   if    i-mjd-diff < 0
      or i-mjd-diff = ?
   then do:
      return "?" .
   end.
   assign
      v-day-number = truncate(i-mjd-diff,0).
      o-Date = date(v-day-number + 2400002).
      o-Time = truncate((i-mjd-diff - v-day-number) * 86400, 0)
  .
end.
function cur-time-mjd-to-string returns character
(input p-mjd-diff as decimal
)
:
  define variable v-day-number as integer   no-undo .
  define variable v-seconds    as integer   no-undo .
  define variable v-hour       as integer   no-undo .
  define variable v-min        as integer   no-undo .
  define variable v-day-name    as character no-undo extent 3 initial [   "дней",    "день",     "дня" ] .
  define variable v-hour-name   as character no-undo extent 3 initial [  "часов",     "час",    "часа" ] .
  define variable v-min-name    as character no-undo extent 3 initial [  "минут",  "минута",  "минуты" ] .
  define variable v-second-name as character no-undo extent 3 initial [ "секунд", "секунда", "секунды" ] .
  if p-mjd-diff < 0
  or p-mjd-diff = ?
  then do:
    return "?" .
  end.
  assign
    v-day-number = integer(truncate(p-mjd-diff,0))
    v-seconds    = truncate((p-mjd-diff - v-day-number) * 86400, 0)
  .
  if v-seconds > 86400
  then do:
    assign
      v-seconds = 86400 - 1
    .
  end.
  if v-seconds < 0
  then do:
    assign
      v-seconds = 0
    .
  end.
  assign
    v-hour = truncate(v-seconds / 3600, 0)
  .
  assign
    v-seconds = v-seconds modulo 3600
  .
  assign
    v-min = truncate(v-seconds / 60, 0)
  .
  assign
    v-seconds = v-seconds modulo 60
  .
  return
      (if v-day-number <> 0
        then string(v-day-number) + " " + v-day-name[cur-time-get-ending-index(v-day-number)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0
        then string(v-hour) + " " + v-hour-name[cur-time-get-ending-index(v-hour)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0 or v-min <> 0
        then string(v-min) + " " + v-min-name[cur-time-get-ending-index(v-min)] + " "
        else ""
      )
    + string(v-seconds) + " " + v-second-name[cur-time-get-ending-index(v-seconds)]
    .
end.
function cur-time-string returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM':U) .
end.
function cur-time-string-sec returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM:SS':U) .
end.
function cur-time-custom  returns character
(input p-prefix as character
,input p-date-format as character
,input p-delimiter as character
,input p-time-format as character
,input p-suffix as character
)
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return
    p-prefix
    + string(v-date, p-date-format)
    + p-delimiter
    + string(v-time, p-time-format)
    + p-suffix
    .
end.
function cur-time-print  returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return "Дата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
end.
function cur-time-datetime returns datetime
:
  define variable v-char as character no-undo .
  define variable v-datetime as datetime no-undo .
  v-char = cur-time-string().
  v-datetime = datetime(v-char).
  return  v-datetime.
end.
function cur-time-string-msec returns character
:
  define variable v-date as datetime  no-undo .
  v-date = now.
  return string(v-date) .
end.
def var vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define temp-table tt-allsum-line      no-undo
field sum-type           as   character
field fact-qnty          like ub.doc-line.fact-qnty
field cli-qnty           like ub.doc-line.cli-qnty
field sum-dsc-base-doc   like ub.doc-line.price-base
field sum-dsc-rubl-doc   like ub.doc-line.price-base
field dsc-base-doc       like ub.doc-line.price-base
field dsc-rubl-doc       like ub.doc-line.price-base
field vat-base-doc       like ub.doc-line.price-base
field vat-rubl-doc       like ub.doc-line.price-base
field vat-base-buyer-doc like ub.doc-line.price-base
field vat-rubl-buyer-doc like ub.doc-line.price-base
field slt-base-doc       like ub.doc-line.price-base
field slt-rubl-doc       like ub.doc-line.price-base
field road-tax-base-doc  like ub.doc-line.price-base
field road-tax-rubl-doc  like ub.doc-line.price-base
field excise-base-doc    like ub.doc-line.price-base
field excise-rubl-doc    like ub.doc-line.price-base
field sum-dsc-base-acc   like ub.doc-line.price-base
field sum-dsc-rubl-acc   like ub.doc-line.price-base
field sum-dsc-cli-acc    like ub.doc-line.price-cli
field dsc-base-acc       like ub.doc-line.price-base
field dsc-rubl-acc       like ub.doc-line.price-base
field dsc-cli-acc        like ub.doc-line.price-cli
field vat-base-acc       like ub.doc-line.price-base
field vat-rubl-acc       like ub.doc-line.price-base
field vat-cli-acc        like ub.doc-line.price-cli
field slt-base-acc       like ub.doc-line.price-base
field slt-rubl-acc       like ub.doc-line.price-base
field slt-cli-acc        like ub.doc-line.price-cli
field road-tax-base-acc  like ub.doc-line.price-base
field road-tax-rubl-acc  like ub.doc-line.price-base
field road-tax-cli-acc   like ub.doc-line.price-cli
field excise-base-acc    like ub.doc-line.price-base
field excise-rubl-acc    like ub.doc-line.price-base
field excise-cli-acc     like ub.doc-line.price-cli
field transport-base-acc like ub.doc-line.price-base
field transport-rubl-acc like ub.doc-line.price-base
field transport-cli-acc  like ub.doc-line.price-cli
field other-base-acc     like ub.doc-line.price-base
field other-rubl-acc     like ub.doc-line.price-base
field other-cli-acc      like ub.doc-line.price-cli
field sum-dsc-base-cur   like ub.doc-line.price-base
field sum-dsc-rubl-cur   like ub.doc-line.price-base
field dsc-base-cur       like ub.doc-line.price-base
field dsc-rubl-cur       like ub.doc-line.price-base
field vat-base-cur       like ub.doc-line.price-base
field vat-rubl-cur       like ub.doc-line.price-base
field vat-base-buyer-cur like ub.doc-line.price-base
field vat-rubl-buyer-cur like ub.doc-line.price-base
field slt-base-cur       like ub.doc-line.price-base
field slt-rubl-cur       like ub.doc-line.price-base
field road-tax-base-cur  like ub.doc-line.price-base
field road-tax-rubl-cur  like ub.doc-line.price-base
field excise-base-cur    like ub.doc-line.price-base
field excise-rubl-cur    like ub.doc-line.price-base
index sum-type is primary unique sum-type.
.
define temp-table tt-allsum no-undo
field sum-type           as   character
field fact-qnty             as decimal
field cli-qnty              as decimal
field sum-dsc-base-doc      as decimal
field sum-dsc-rubl-doc      as decimal
field dsc-base-doc          as decimal
field dsc-rubl-doc          as decimal
field vat-base-doc          as decimal
field vat-rubl-doc          as decimal
field vat-base-buyer-doc    as decimal
field vat-rubl-buyer-doc    as decimal
field slt-base-doc          as decimal
field slt-rubl-doc          as decimal
field road-tax-base-doc     as decimal
field road-tax-rubl-doc     as decimal
field excise-base-doc       as decimal
field excise-rubl-doc       as decimal
field sum-dsc-base-acc      as decimal
field sum-dsc-rubl-acc      as decimal
field sum-dsc-cli-acc       as decimal
field dsc-base-acc          as decimal
field dsc-rubl-acc          as decimal
field dsc-cli-acc           as decimal
field vat-base-acc          as decimal
field vat-rubl-acc          as decimal
field vat-cli-acc           as decimal
field slt-base-acc          as decimal
field slt-rubl-acc          as decimal
field slt-cli-acc           as decimal
field road-tax-base-acc     as decimal
field road-tax-rubl-acc     as decimal
field road-tax-cli-acc      as decimal
field excise-base-acc       as decimal
field excise-rubl-acc       as decimal
field excise-cli-acc        as decimal
field transport-base-acc    as decimal
field transport-rubl-acc    as decimal
field transport-cli-acc     as decimal
field other-base-acc        as decimal
field other-rubl-acc        as decimal
field other-cli-acc         as decimal
field sum-dsc-base-cur      as decimal
field sum-dsc-rubl-cur      as decimal
field dsc-base-cur          as decimal
field dsc-rubl-cur          as decimal
field vat-base-cur          as decimal
field vat-rubl-cur          as decimal
field vat-base-buyer-cur    as decimal
field vat-rubl-buyer-cur    as decimal
field slt-base-cur          as decimal
field slt-rubl-cur          as decimal
field road-tax-base-cur     as decimal
field road-tax-rubl-cur     as decimal
field excise-base-cur       as decimal
field excise-rubl-cur       as decimal
index sum-type is primary unique sum-type.
define temp-table tt-clcparts no-undo like ub.parts
field part-cur-base like ub.gds-dtl.price-base
field part-cur-road-tax like ub.gds-dtl.price-base
field part-cur-excise like ub.gds-dtl.price-base
.
define variable v-calcbypart as log no-undo.
procedure clcprtsl_calc-parts :
define input parameter parrec-parts        as   recid                   no-undo.
define input parameter paris-doc           as   logical                 no-undo.
define input parameter paris-cur           as   logical                 no-undo.
define input parameter parroad-tax         like ub.doc-line.road-tax    no-undo.
define input parameter parexcise           like ub.doc-line.excise      no-undo.
define input parameter parvat-pc           like ub.doc-line.vat-pc      no-undo.
define input parameter parcons-vat-pc      like ub.doc-line.cons-vat-pc no-undo.
define input parameter parslt-pc           like ub.doc-line.slt-pc      no-undo.
define input parameter parbase-rate        like ub.trn-doc.base-rate    no-undo.
define input parameter parbase-scale       like ub.trn-doc.base-scale   no-undo.
define input parameter parr-b              as   character               no-undo.
define input parameter parcur-base         like ub.gds-dtl.cur-base     no-undo.
define input parameter parcurroad-tax      like ub.doc-line.road-tax    no-undo.
define input parameter parcurexcise        like ub.doc-line.excise      no-undo.
define input parameter parcurvat-pc        like ub.doc-line.vat-pc      no-undo.
define input parameter parcurcons-vat-pc   like ub.doc-line.cons-vat-pc no-undo.
define input parameter parcurslt-pc        like ub.doc-line.slt-pc      no-undo.
define variable parartic        like ub.parts.artic         no-undo.
define variable parprod-type    like ub.parts.prod-type     no-undo.
define variable parprod-code    like ub.parts.prod-code     no-undo.
define variable pardoc-type     like ub.parts.doc-type      no-undo.
define variable pardoc-code     like ub.parts.out-code      no-undo.
define variable parobj-type     like ub.parts.obj-type      no-undo.
define variable parobj-code     like ub.parts.obj-code      no-undo.
define variable parprice-base   like ub.gds-dtl.price-base  no-undo.
define variable parprice-rubl   like ub.gds-dtl.price-rubl  no-undo.
define variable pardiscnt-base  like ub.gds-dtl.discnt-base no-undo.
define variable pardiscnt-rubl  like ub.gds-dtl.discnt-rubl no-undo.
define variable parfact-qnty    like ub.parts.fact-qnty     no-undo.
define variable parcli-qnty     like ub.parts.cli-qnty      no-undo.
define variable pardoc-qnty     like ub.parts.qnty          no-undo.
define variable parext-doc-type like ub.trn-doc.ext-doc-type no-undo.
define variable parcurartic        like ub.parts.artic         no-undo.
define variable parcurprod-type    like ub.parts.prod-type     no-undo.
define variable parcurprod-code    like ub.parts.prod-code     no-undo.
define variable parcurdoc-type     like ub.parts.doc-type      no-undo.
define variable parcurdoc-code     like ub.parts.out-code      no-undo.
define variable parcurobj-type     like ub.parts.obj-type      no-undo.
define variable parcurobj-code     like ub.parts.obj-code      no-undo.
define variable parcurprice-base   like ub.gds-dtl.price-base  no-undo.
define variable parcurprice-rubl   like ub.gds-dtl.price-rubl  no-undo.
define variable parcurdiscnt-base  like ub.gds-dtl.discnt-base no-undo.
define variable parcurdiscnt-rubl  like ub.gds-dtl.discnt-rubl no-undo.
define variable parcurfact-qnty    like ub.parts.fact-qnty     no-undo.
define variable parcurcli-qnty     like ub.parts.cli-qnty      no-undo.
define variable parcurdoc-qnty     like ub.parts.qnty          no-undo.
define variable parcurbase-rate    like ub.trn-doc.base-rate   no-undo.
define variable parcurbase-scale   like ub.trn-doc.base-scale  no-undo.
define variable parcurext-doc-type like ub.trn-doc.ext-doc-type no-undo.
define buffer bf_tt-allsum     for tt-allsum.
define buffer bfs_tt-allsum    for tt-allsum.
define buffer bfpc_tt-allsum   for tt-allsum.
define buffer bfspc_tt-allsum  for tt-allsum.
define buffer bfacc_tt-allsum  for tt-allsum.
define buffer bfsacc_tt-allsum for tt-allsum.
define buffer cl_tt-clcparts   for tt-clcparts.
define buffer bf_trn-doc       for ub.trn-doc.
define buffer bf_sysconf       for ub.sysconf.
    define buffer   in-vatp-trn-doccl  for ub.trn-doc .
    define buffer   in-vatp-partscl    for ub.parts   .
    define buffer   in-vatp-doccl      for ub.trn-doc .
    define buffer   in-vatp-goodscl    for ub.goods   .
    define buffer   in-vatp-sysconfcl  for ub.sysconf .
    define buffer   in-vatp_doc-attrcl for ub.doc-attr.
    define variable in-vatp-have-vat-sltcl       as   logical initial yes    no-undo.
    define variable vat-pc-loccl                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbcl                  as   character              no-undo.
    define variable slt-pc-loccl                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-ratecl              as   decimal                no-undo.
    define variable price-rubl-with-tax-loccl    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loccl    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loccl     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loccl like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loccl like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loccl  like ub.doc-line.price-base no-undo.
    define variable vat-base-loccl               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loccl               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loccl                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loccl               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loccl               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loccl                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loccl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loccl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loccl           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loccl         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loccl         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loccl          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loccl             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loccl             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loccl              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loccl          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdcl             as   character              no-undo.
    define variable varinvatp-typecl             as   character              no-undo.
    define  variable price-rubl-with-tax-salecl    like ub.doc-line.price-rubl no-undo.
    define  variable price-base-with-tax-salecl    like ub.doc-line.price-base no-undo.
    define  variable price-rubl-without-tax-salecl like ub.doc-line.price-rubl no-undo.
    define  variable price-base-without-tax-salecl like ub.doc-line.price-base no-undo.
    define  variable vat-base-salecl               like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-salecl               like ub.doc-line.price-rubl no-undo.
    define  variable vat-base-buyercl              like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-buyercl              like ub.doc-line.price-rubl no-undo.
    define  variable slt-base-salecl               like ub.doc-line.price-base no-undo.
    define  variable slt-rubl-salecl               like ub.doc-line.price-rubl no-undo.
    define  variable road-tax-base-salecl          like ub.doc-line.road-tax   no-undo.
    define  variable road-tax-rubl-salecl          like ub.doc-line.road-tax   no-undo.
    define  variable excise-base-salecl            like ub.doc-line.price-base no-undo.
    define  variable excise-rubl-salecl            like ub.doc-line.price-rubl no-undo.
    define  variable discnt-base-salecl            like ub.gds-dtl.discnt-base no-undo.
    define  variable discnt-rubl-salecl            like ub.gds-dtl.discnt-rubl no-undo.
    define buffer out-vatp_gds-dtlcl     for ub.gds-dtl.
    define buffer buf_out-vatp_gds-dtlcl for ub.gds-dtl.
    define buffer out-vatp_partscl       for ub.parts.
    define buffer out-vatp_sysconfcl     for ub.sysconf.
    define buffer out-vatp_doc-linecl    for ub.doc-line.
    define buffer out-vatp_goodscl       for ub.goods.
    define buffer out-vatp_trn-doccl     for ub.trn-doc.
    define buffer out-vatp_doc-attrcl    for ub.doc-attr.
    define variable varprice-base-conscl      like ub.doc-line.price-base initial 0.00 no-undo.
    define variable varprice-rubl-conscl      like ub.doc-line.price-rubl initial 0.00 no-undo.
    define variable varfrm-cnsv-typecl         as   character                           no-undo.
    define variable varfrm-cnsvcl              as   character                           no-undo.
    define variable varroot-nodecl             as   integer                             no-undo.
    define variable varempty-scalecl           as   logical                             no-undo.
    define variable varis-cons-parts-havecl    as   logical                             no-undo.
    define variable varsum-base-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-factovpcl  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-base-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-docovpcl   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-factovpcl  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-docovpcl   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varfact-qntycl             like ub.parts.fact-qnty                  no-undo.
    define variable varcons-qntycl             like ub.parts.fact-qnty                  no-undo.
    define variable varis-one-gds-dtlcl        as   logical                             no-undo.
    define variable varcurclprice-base         like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurclprice-rubl         like ub.gds-dtl.price-base               no-undo.
    define variable varcurcldiscnt-base        like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurcldiscnt-rubl        like ub.gds-dtl.price-base               no-undo.
    define variable varoutvprbcl               as   character                           no-undo.
    define variable out-vatp-have-vat-sltcl    as   logical initial yes                 no-undo.
    define buffer   in-vatp-trn-dococl  for ub.trn-doc .
    define buffer   in-vatp-partsocl    for ub.parts   .
    define buffer   in-vatp-dococl      for ub.trn-doc .
    define buffer   in-vatp-goodsocl    for ub.goods   .
    define buffer   in-vatp-sysconfocl  for ub.sysconf .
    define buffer   in-vatp_doc-attrocl for ub.doc-attr.
    define variable in-vatp-have-vat-sltocl       as   logical initial yes    no-undo.
    define variable vat-pc-lococl                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbocl                  as   character              no-undo.
    define variable slt-pc-lococl                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rateocl              as   decimal                no-undo.
    define variable price-rubl-with-tax-lococl    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-lococl    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-lococl     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-lococl like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-lococl like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-lococl  like ub.doc-line.price-base no-undo.
    define variable vat-base-lococl               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-lococl               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-lococl                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-lococl               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-lococl               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-lococl                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-lococl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-lococl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-lococl           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-lococl         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-lococl         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-lococl          like ub.doc-line.price-rubl no-undo.
    define variable other-base-lococl             like ub.doc-line.price-base no-undo.
    define variable other-rubl-lococl             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-lococl              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-lococl          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdocl             as   character              no-undo.
    define variable varinvatp-typeocl             as   character              no-undo.
    define  variable price-rubl-with-tax-salecur    like ub.doc-line.price-rubl no-undo.
    define  variable price-base-with-tax-salecur    like ub.doc-line.price-base no-undo.
    define  variable price-rubl-without-tax-salecur like ub.doc-line.price-rubl no-undo.
    define  variable price-base-without-tax-salecur like ub.doc-line.price-base no-undo.
    define  variable vat-base-salecur               like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-salecur               like ub.doc-line.price-rubl no-undo.
    define  variable vat-base-buyercur              like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-buyercur              like ub.doc-line.price-rubl no-undo.
    define  variable slt-base-salecur               like ub.doc-line.price-base no-undo.
    define  variable slt-rubl-salecur               like ub.doc-line.price-rubl no-undo.
    define  variable road-tax-base-salecur          like ub.doc-line.road-tax   no-undo.
    define  variable road-tax-rubl-salecur          like ub.doc-line.road-tax   no-undo.
    define  variable excise-base-salecur            like ub.doc-line.price-base no-undo.
    define  variable excise-rubl-salecur            like ub.doc-line.price-rubl no-undo.
    define  variable discnt-base-salecur            like ub.gds-dtl.discnt-base no-undo.
    define  variable discnt-rubl-salecur            like ub.gds-dtl.discnt-rubl no-undo.
    define buffer out-vatp_gds-dtlcur     for ub.gds-dtl.
    define buffer buf_out-vatp_gds-dtlcur for ub.gds-dtl.
    define buffer out-vatp_partscur       for ub.parts.
    define buffer out-vatp_sysconfcur     for ub.sysconf.
    define buffer out-vatp_doc-linecur    for ub.doc-line.
    define buffer out-vatp_goodscur       for ub.goods.
    define buffer out-vatp_trn-doccur     for ub.trn-doc.
    define buffer out-vatp_doc-attrcur    for ub.doc-attr.
    define variable varprice-base-conscur      like ub.doc-line.price-base initial 0.00 no-undo.
    define variable varprice-rubl-conscur      like ub.doc-line.price-rubl initial 0.00 no-undo.
    define variable varfrm-cnsv-typecur         as   character                           no-undo.
    define variable varfrm-cnsvcur              as   character                           no-undo.
    define variable varroot-nodecur             as   integer                             no-undo.
    define variable varempty-scalecur           as   logical                             no-undo.
    define variable varis-cons-parts-havecur    as   logical                             no-undo.
    define variable varsum-base-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-factovpcur  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-base-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-docovpcur   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-factovpcur  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-docovpcur   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varfact-qntycur             like ub.parts.fact-qnty                  no-undo.
    define variable varcons-qntycur             like ub.parts.fact-qnty                  no-undo.
    define variable varis-one-gds-dtlcur        as   logical                             no-undo.
    define variable varcurcurprice-base         like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurcurprice-rubl         like ub.gds-dtl.price-base               no-undo.
    define variable varcurcurdiscnt-base        like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurcurdiscnt-rubl        like ub.gds-dtl.price-base               no-undo.
    define variable varoutvprbcur               as   character                           no-undo.
    define variable out-vatp-have-vat-sltcur    as   logical initial yes                 no-undo.
    define buffer   in-vatp-trn-dococur  for ub.trn-doc .
    define buffer   in-vatp-partsocur    for ub.parts   .
    define buffer   in-vatp-dococur      for ub.trn-doc .
    define buffer   in-vatp-goodsocur    for ub.goods   .
    define buffer   in-vatp-sysconfocur  for ub.sysconf .
    define buffer   in-vatp_doc-attrocur for ub.doc-attr.
    define variable in-vatp-have-vat-sltocur       as   logical initial yes    no-undo.
    define variable vat-pc-lococur                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbocur                  as   character              no-undo.
    define variable slt-pc-lococur                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rateocur              as   decimal                no-undo.
    define variable price-rubl-with-tax-lococur    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-lococur    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-lococur     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-lococur like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-lococur like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-lococur  like ub.doc-line.price-base no-undo.
    define variable vat-base-lococur               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-lococur               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-lococur                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-lococur               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-lococur               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-lococur                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-lococur          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-lococur          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-lococur           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-lococur         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-lococur         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-lococur          like ub.doc-line.price-rubl no-undo.
    define variable other-base-lococur             like ub.doc-line.price-base no-undo.
    define variable other-rubl-lococur             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-lococur              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-lococur          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdocur             as   character              no-undo.
    define variable varinvatp-typeocur             as   character              no-undo.
do on error undo, return error return-value :
find first cl_tt-clcparts where recid(cl_tt-clcparts) = parrec-parts no-lock.
for each bf_tt-allsum on error undo, return error return-value :
  delete bf_tt-allsum.
end.
assign
  price-rubl-with-tax-loccl = cl_tt-clcparts.price-rubl
  price-base-with-tax-loccl = cl_tt-clcparts.price-base
.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprbcl
  )  .
  if cl_tt-clcparts.out-code = 'free-zone':U     or
     cl_tt-clcparts.out-code = 'out-zone':U   or
     cl_tt-clcparts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-sltcl = yes.
  end.
  else do:
    find first in-vatp_doc-attrcl no-lock
      where in-vatp_doc-attrcl.doc-code  = cl_tt-clcparts.out-code
        and in-vatp_doc-attrcl.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attrcl then do:
      assign
        in-vatp-have-vat-sltcl = yes.
    end.
    else do:
         in-vatp-have-vat-sltcl = no.
    end.
  end.
  assign
   price-cli-with-tax-loccl = cl_tt-clcparts.price-cli
   cli-base-ratecl          = cl_tt-clcparts.cli-base-rate.
  ASSIGN   road-tax-base-loccl  = (if cl_tt-clcparts.road-tax-base  = ? then 0 else cl_tt-clcparts.road-tax-base)
           road-tax-rubl-loccl  = (if cl_tt-clcparts.road-tax-rubl  = ? then 0 else cl_tt-clcparts.road-tax-rubl).
  ASSIGN  transport-base-loccl = (if cl_tt-clcparts.transport-base = ? then 0 else cl_tt-clcparts.transport-base)
          transport-rubl-loccl = (if cl_tt-clcparts.transport-rubl = ? then 0 else cl_tt-clcparts.transport-rubl)
          other-base-loccl     = (if cl_tt-clcparts.other-base     = ? then 0 else cl_tt-clcparts.other-base)
          other-rubl-loccl     = (if cl_tt-clcparts.other-rubl     = ? then 0 else cl_tt-clcparts.other-rubl)
          vat-pc-loccl         = (if cl_tt-clcparts.vat-pc         = ? then 0 else cl_tt-clcparts.vat-pc)
          slt-pc-loccl         = (if cl_tt-clcparts.slt-pc         = ? then 0 else cl_tt-clcparts.slt-pc).
          ASSIGN   slt-base-loccl    = (if in-vatp-have-vat-sltcl = no then 0 else (price-base-with-tax-loccl - ((if road-tax-base-loccl  = ? then 0 else road-tax-base-loccl) + (if transport-base-loccl = ? then 0 else transport-base-loccl) + (if other-base-loccl = ? then 0 else other-base-loccl)))                           * slt-pc-loccl / (100 + slt-pc-loccl))                        vat-base-loccl    = (if in-vatp-have-vat-sltcl = no then 0 else (price-base-with-tax-loccl - ((if road-tax-base-loccl  = ? then 0 else road-tax-base-loccl) + (if transport-base-loccl = ? then 0 else transport-base-loccl) + (if other-base-loccl = ? then 0 else other-base-loccl))) * (1 - slt-pc-loccl / (100 + slt-pc-loccl)) * vat-pc-loccl / (100 + vat-pc-loccl)).
    ASSIGN   slt-rubl-loccl    = (if in-vatp-have-vat-sltcl = no then 0 else (price-rubl-with-tax-loccl - ((if road-tax-rubl-loccl  = ? then 0 else road-tax-rubl-loccl) + (if transport-rubl-loccl = ? then 0 else transport-rubl-loccl) + (if other-rubl-loccl = ? then 0 else other-rubl-loccl)))                           * slt-pc-loccl / (100 + slt-pc-loccl))                        vat-rubl-loccl    = (if in-vatp-have-vat-sltcl = no then 0 else (price-rubl-with-tax-loccl - ((if road-tax-rubl-loccl  = ? then 0 else road-tax-rubl-loccl) + (if transport-rubl-loccl = ? then 0 else transport-rubl-loccl) + (if other-rubl-loccl = ? then 0 else other-rubl-loccl))) * (1 - slt-pc-loccl / (100 + slt-pc-loccl)) * vat-pc-loccl / (100 + vat-pc-loccl)).
  assign
    exch-rate-cli-loccl = (cl_tt-clcparts.price-rubl - transport-rubl-loccl - other-rubl-loccl - road-tax-rubl-loccl - (if cl_tt-clcparts.vat-type <> 'в т. ч.':U then vat-rubl-loccl else 0) - (if cl_tt-clcparts.slt-type <> 'в т. ч.':U then slt-rubl-loccl else 0)) / cl_tt-clcparts.price-cli .
  assign
    slt-cli-loccl        = slt-rubl-loccl       / exch-rate-cli-loccl
    vat-cli-loccl        = vat-rubl-loccl       / exch-rate-cli-loccl
    road-tax-cli-loccl   = road-tax-rubl-loccl  / exch-rate-cli-loccl
    transport-cli-loccl  = 0
    other-cli-loccl      = 0
  .
ASSIGN
          price-base-without-tax-loccl = price-base-with-tax-loccl - vat-base-loccl - slt-base-loccl - ((if road-tax-base-loccl  = ? then 0 else road-tax-base-loccl) + (if transport-base-loccl = ? then 0 else transport-base-loccl) + (if other-base-loccl = ? then 0 else other-base-loccl))
    price-rubl-without-tax-loccl = price-rubl-with-tax-loccl - vat-rubl-loccl - slt-rubl-loccl - ((if road-tax-rubl-loccl  = ? then 0 else road-tax-rubl-loccl) + (if transport-rubl-loccl = ? then 0 else transport-rubl-loccl) + (if other-rubl-loccl = ? then 0 else other-rubl-loccl))
.
if paris-doc then do:
  assign
    parartic     = cl_tt-clcparts.artic
    parprod-type = cl_tt-clcparts.prod-type
    parprod-code = cl_tt-clcparts.prod-code
    pardoc-type  = cl_tt-clcparts.doc-type
    pardoc-code  = cl_tt-clcparts.out-code
    parobj-type  = cl_tt-clcparts.obj-type
    parobj-code  = cl_tt-clcparts.obj-code.
if parext-doc-type = 'ot':U or
   parext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-sltcl = yes.
end.
else do:
  find first out-vatp_doc-attrcl no-lock
    where out-vatp_doc-attrcl.doc-code  = pardoc-code
      and out-vatp_doc-attrcl.attr-code = 'envd':U
      no-error .
  if not available out-vatp_doc-attrcl then do:
    assign
      out-vatp-have-vat-sltcl = yes.
  end.
  else do:
     out-vatp-have-vat-sltcl = no.
  end.
end.
find first out-vatp_goodscl where out-vatp_goodscl.artic     = parartic     and
                                   out-vatp_goodscl.prod-type = parprod-type and
                                   out-vatp_goodscl.prod-code = parprod-code no-lock.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  parartic
  ,input  parprod-type
  ,input  parprod-code
  ,output varroot-nodecl
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" parartic parprod-type parprod-code skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  varroot-nodecl
  ,input  'empty-scale=request'
  ,output varempty-scalecl
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении атрибута признака" skip
    "Артикул" parartic parprod-type parprod-code skip
    "Признак" varroot-nodecl skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprbcl
  )  .
if varoutvprbcl = "base":u then do:
  assign
        road-tax-base-salecl    =  (if parroad-tax = ? then 0 else parroad-tax * 1)
    excise-base-salecl      =  (if parexcise   = ? then 0 else parexcise   * 1)
  .
end.
else do:
  assign
        road-tax-base-salecl    =  (if parroad-tax = ? then 0 else parroad-tax / parbase-rate * parbase-scale)
    excise-base-salecl      =  (if parexcise   = ? then 0 else parexcise   / parbase-rate * parbase-scale)
  .
end.
if varoutvprbcl = "rubl":u then do:
  assign
        road-tax-rubl-salecl    = (if parroad-tax = ? then 0 else parroad-tax * 1)
    excise-rubl-salecl      = (if parexcise   = ? then 0 else parexcise   * 1) .
end.
else do:
  assign
        road-tax-rubl-salecl    = (if parroad-tax = ? then 0 else parroad-tax * parbase-rate / parbase-scale)
    excise-rubl-salecl      = (if parexcise   = ? then 0 else parexcise   * parbase-rate / parbase-scale) .
end.
assign
  varis-cons-parts-havecl =  no.
assign
  varfact-qntycl       = 0
  varcons-qntycl       = 0
  varprice-base-conscl = 0
  varprice-rubl-conscl = 0.
find first out-vatp_doc-linecl where
           out-vatp_doc-linecl.doc-code   = pardoc-code
       and out-vatp_doc-linecl.artic      = parartic
       and out-vatp_doc-linecl.prod-type  = parprod-type
       and out-vatp_doc-linecl.prod-code  = parprod-code no-lock no-error.
if available out-vatp_doc-linecl           and
  (out-vatp_doc-linecl.status_ = 'запрос':U or out-vatp_goodscl.gds-type = 'у':U) then do:
  assign
    varfact-qntycl = out-vatp_doc-linecl.fact-qnty.
end.
else do:
  for each out-vatp_partscl where out-vatp_partscl.out-code   = pardoc-code
                               and out-vatp_partscl.obj-type   = parobj-type
                               and out-vatp_partscl.obj-code   = parobj-code
                               and out-vatp_partscl.artic      = parartic
                               and out-vatp_partscl.prod-type  = parprod-type
                               and out-vatp_partscl.prod-code  = parprod-code no-lock :
    if out-vatp_partscl.purch-code = 2 then do:
assign
  price-rubl-with-tax-lococl = out-vatp_partscl.price-rubl
  price-base-with-tax-lococl = out-vatp_partscl.price-base
.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprbocl
  )  .
  if out-vatp_partscl.out-code = 'free-zone':U     or
     out-vatp_partscl.out-code = 'out-zone':U   or
     out-vatp_partscl.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-sltocl = yes.
  end.
  else do:
    find first in-vatp_doc-attrocl no-lock
      where in-vatp_doc-attrocl.doc-code  = out-vatp_partscl.out-code
        and in-vatp_doc-attrocl.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attrocl then do:
      assign
        in-vatp-have-vat-sltocl = yes.
    end.
    else do:
         in-vatp-have-vat-sltocl = no.
    end.
  end.
  assign
   price-cli-with-tax-lococl = out-vatp_partscl.price-cli
   cli-base-rateocl          = out-vatp_partscl.cli-base-rate.
  ASSIGN   road-tax-base-lococl  = (if out-vatp_partscl.road-tax-base  = ? then 0 else out-vatp_partscl.road-tax-base)
           road-tax-rubl-lococl  = (if out-vatp_partscl.road-tax-rubl  = ? then 0 else out-vatp_partscl.road-tax-rubl).
  ASSIGN  transport-base-lococl = (if out-vatp_partscl.transport-base = ? then 0 else out-vatp_partscl.transport-base)
          transport-rubl-lococl = (if out-vatp_partscl.transport-rubl = ? then 0 else out-vatp_partscl.transport-rubl)
          other-base-lococl     = (if out-vatp_partscl.other-base     = ? then 0 else out-vatp_partscl.other-base)
          other-rubl-lococl     = (if out-vatp_partscl.other-rubl     = ? then 0 else out-vatp_partscl.other-rubl)
          vat-pc-lococl         = (if out-vatp_partscl.vat-pc         = ? then 0 else out-vatp_partscl.vat-pc)
          slt-pc-lococl         = (if out-vatp_partscl.slt-pc         = ? then 0 else out-vatp_partscl.slt-pc).
          ASSIGN   slt-base-lococl    = (if in-vatp-have-vat-sltocl = no then 0 else (price-base-with-tax-lococl - ((if road-tax-base-lococl  = ? then 0 else road-tax-base-lococl) + (if transport-base-lococl = ? then 0 else transport-base-lococl) + (if other-base-lococl = ? then 0 else other-base-lococl)))                           * slt-pc-lococl / (100 + slt-pc-lococl))                        vat-base-lococl    = (if in-vatp-have-vat-sltocl = no then 0 else (price-base-with-tax-lococl - ((if road-tax-base-lococl  = ? then 0 else road-tax-base-lococl) + (if transport-base-lococl = ? then 0 else transport-base-lococl) + (if other-base-lococl = ? then 0 else other-base-lococl))) * (1 - slt-pc-lococl / (100 + slt-pc-lococl)) * vat-pc-lococl / (100 + vat-pc-lococl)).
    ASSIGN   slt-rubl-lococl    = (if in-vatp-have-vat-sltocl = no then 0 else (price-rubl-with-tax-lococl - ((if road-tax-rubl-lococl  = ? then 0 else road-tax-rubl-lococl) + (if transport-rubl-lococl = ? then 0 else transport-rubl-lococl) + (if other-rubl-lococl = ? then 0 else other-rubl-lococl)))                           * slt-pc-lococl / (100 + slt-pc-lococl))                        vat-rubl-lococl    = (if in-vatp-have-vat-sltocl = no then 0 else (price-rubl-with-tax-lococl - ((if road-tax-rubl-lococl  = ? then 0 else road-tax-rubl-lococl) + (if transport-rubl-lococl = ? then 0 else transport-rubl-lococl) + (if other-rubl-lococl = ? then 0 else other-rubl-lococl))) * (1 - slt-pc-lococl / (100 + slt-pc-lococl)) * vat-pc-lococl / (100 + vat-pc-lococl)).
  assign
    exch-rate-cli-lococl = (out-vatp_partscl.price-rubl - transport-rubl-lococl - other-rubl-lococl - road-tax-rubl-lococl - (if out-vatp_partscl.vat-type <> 'в т. ч.':U then vat-rubl-lococl else 0) - (if out-vatp_partscl.slt-type <> 'в т. ч.':U then slt-rubl-lococl else 0)) / out-vatp_partscl.price-cli .
  assign
    slt-cli-lococl        = slt-rubl-lococl       / exch-rate-cli-lococl
    vat-cli-lococl        = vat-rubl-lococl       / exch-rate-cli-lococl
    road-tax-cli-lococl   = road-tax-rubl-lococl  / exch-rate-cli-lococl
    transport-cli-lococl  = 0
    other-cli-lococl      = 0
  .
ASSIGN
          price-base-without-tax-lococl = price-base-with-tax-lococl - vat-base-lococl - slt-base-lococl - ((if road-tax-base-lococl  = ? then 0 else road-tax-base-lococl) + (if transport-base-lococl = ? then 0 else transport-base-lococl) + (if other-base-lococl = ? then 0 else other-base-lococl))
    price-rubl-without-tax-lococl = price-rubl-with-tax-lococl - vat-rubl-lococl - slt-rubl-lococl - ((if road-tax-rubl-lococl  = ? then 0 else road-tax-rubl-lococl) + (if transport-rubl-lococl = ? then 0 else transport-rubl-lococl) + (if other-rubl-lococl = ? then 0 else other-rubl-lococl))
.
      assign
        varprice-base-conscl = varprice-base-conscl + (price-base-with-tax-lococl - (if road-tax-base-lococl = ? then 0 else road-tax-base-lococl))* out-vatp_partscl.fact-qnty
        varprice-rubl-conscl = varprice-rubl-conscl + (price-rubl-with-tax-lococl - (if road-tax-rubl-lococl = ? then 0 else road-tax-rubl-lococl))* out-vatp_partscl.fact-qnty.
      assign
        varis-cons-parts-havecl = yes
        varcons-qntycl          = varcons-qntycl + out-vatp_partscl.fact-qnty.
    end.
    assign
      varfact-qntycl = varfact-qntycl + out-vatp_partscl.fact-qnty.
  end.
end.
assign
  varprice-base-conscl = varprice-base-conscl / varcons-qntycl
  varprice-rubl-conscl = varprice-rubl-conscl / varcons-qntycl.
if varprice-base-conscl = ? then do:
  assign
    varprice-base-conscl = 0.
end.
if varprice-rubl-conscl = ? then do:
  assign
    varprice-rubl-conscl = 0.
end.
assign
  varsum-base-factovpcl     = 0
  varslt-base-factovpcl     = 0
  varvat-base-factovpcl     = 0
  varvatcons-base-factovpcl = 0
  vardsc-base-factovpcl     = 0
  varsum-base-docovpcl      = 0
  varslt-base-docovpcl      = 0
  varvat-base-docovpcl      = 0
  varvatcons-base-docovpcl  = 0
  vardsc-base-docovpcl      = 0
  varsum-rubl-factovpcl     = 0
  varslt-rubl-factovpcl     = 0
  varvat-rubl-factovpcl     = 0
  varvatcons-rubl-factovpcl = 0
  vardsc-rubl-factovpcl     = 0
  varsum-rubl-docovpcl      = 0
  varslt-rubl-docovpcl      = 0
  varvat-rubl-docovpcl      = 0
  varvatcons-rubl-docovpcl  = 0
  vardsc-rubl-docovpcl      = 0.
assign
  varis-one-gds-dtlcl = no.
find first out-vatp_gds-dtlcl where out-vatp_gds-dtlcl.doc-code  = pardoc-code  and
                                     out-vatp_gds-dtlcl.artic     = parartic     and
                                     out-vatp_gds-dtlcl.prod-type = parprod-type and
                                     out-vatp_gds-dtlcl.prod-code = parprod-code no-lock no-error.
if available out-vatp_gds-dtlcl then do:
  find first buf_out-vatp_gds-dtlcl where buf_out-vatp_gds-dtlcl.doc-code  =  pardoc-code                and
                                           buf_out-vatp_gds-dtlcl.artic     =  parartic                   and
                                           buf_out-vatp_gds-dtlcl.prod-type =  parprod-type               and
                                           buf_out-vatp_gds-dtlcl.prod-code =  parprod-code               and
                                           recid(buf_out-vatp_gds-dtlcl)    <> recid(out-vatp_gds-dtlcl) no-lock no-error.
  if not available buf_out-vatp_gds-dtlcl then do:
    assign
      varis-one-gds-dtlcl = yes.
  end.
  if varoutvprbcl = "base":u then do:
    assign
      varcurclprice-base = out-vatp_gds-dtlcl.cur-base
      varcurclprice-rubl = out-vatp_gds-dtlcl.cur-base * ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) / (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base)).
  end.
  else do:
    assign
      varcurclprice-base = out-vatp_gds-dtlcl.cur-base / ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) / (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base))
      varcurclprice-rubl = out-vatp_gds-dtlcl.cur-base.
  end.
  if varempty-scalecl    = yes or
     varis-one-gds-dtlcl = yes   then do:
    assign
                price-base-with-tax-salecl    = (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base)
        slt-base-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc)
        vat-base-buyercl              = (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc)
        discnt-base-salecl            = out-vatp_gds-dtlcl.discnt-base
                price-rubl-with-tax-salecl    = (out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl)
        slt-rubl-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc)
        vat-rubl-buyercl              = (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc)
        discnt-rubl-salecl            = out-vatp_gds-dtlcl.discnt-rubl
        .
    if pardoc-type = 'инв':U then do:
      ASSIGN
                vat-base-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else (((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl - varprice-base-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.doc-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.doc-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl) / varfact-qntycl)
                vat-rubl-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else (((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl - varprice-rubl-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.doc-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.doc-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl) / varfact-qntycl)
        .
    end.
    else do:
      ASSIGN
                vat-base-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else (((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl - varprice-base-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.fact-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl ) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.fact-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl) / varfact-qntycl)
                vat-rubl-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else (((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl - varprice-rubl-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.fact-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.fact-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl) / varfact-qntycl)
        .
    end.
  end.
  else do:
    for each out-vatp_gds-dtlcl where out-vatp_gds-dtlcl.doc-code  = pardoc-code  and
                                       out-vatp_gds-dtlcl.artic     = parartic     and
                                       out-vatp_gds-dtlcl.prod-type = parprod-type and
                                       out-vatp_gds-dtlcl.prod-code = parprod-code no-lock :
      if varoutvprbcl = "base":u then do:
        assign
          varcurclprice-base = out-vatp_gds-dtlcl.cur-base
          varcurclprice-rubl = out-vatp_gds-dtlcl.cur-base * ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) / (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base)).
      end.
      else do:
        assign
          varcurclprice-base = out-vatp_gds-dtlcl.cur-base / ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) / (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base))
          varcurclprice-rubl = out-vatp_gds-dtlcl.cur-base.
      end.
      assign
             varsum-base-factovpcl = varsum-base-factovpcl + (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base)                 * out-vatp_gds-dtlcl.fact-qnty
       varslt-base-factovpcl = varslt-base-factovpcl + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc)                   * out-vatp_gds-dtlcl.fact-qnty
       varvat-base-factovpcl = varvat-base-factovpcl + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc)                   * out-vatp_gds-dtlcl.fact-qnty
       varvatcons-base-factovpcl = varvatcons-base-factovpcl + (((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl - varprice-base-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.fact-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.fact-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl)
       vardsc-base-factovpcl = vardsc-base-factovpcl + out-vatp_gds-dtlcl.discnt-base * out-vatp_gds-dtlcl.fact-qnty
       varsum-base-docovpcl  = varsum-base-docovpcl  + (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base)                 * out-vatp_gds-dtlcl.doc-qnty
       varslt-base-docovpcl  = varslt-base-docovpcl  + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc)                   * out-vatp_gds-dtlcl.doc-qnty
       varvat-base-docovpcl  = varvat-base-docovpcl  + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc)                   * out-vatp_gds-dtlcl.doc-qnty
       varvatcons-base-docovpcl  = varvatcons-base-docovpcl  + (((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl - varprice-base-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.doc-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.doc-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl)
       vardsc-base-docovpcl  = vardsc-base-docovpcl  + out-vatp_gds-dtlcl.discnt-base * out-vatp_gds-dtlcl.doc-qnty
      .
      assign
             varsum-rubl-factovpcl = varsum-rubl-factovpcl + (out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl)                 * out-vatp_gds-dtlcl.fact-qnty
       varslt-rubl-factovpcl = varslt-rubl-factovpcl + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc)                   * out-vatp_gds-dtlcl.fact-qnty
       varvat-rubl-factovpcl = varvat-rubl-factovpcl + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc)                   * out-vatp_gds-dtlcl.fact-qnty
       varvatcons-rubl-factovpcl = varvatcons-rubl-factovpcl + (((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl - varprice-rubl-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.fact-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.fact-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl)
       vardsc-rubl-factovpcl = vardsc-rubl-factovpcl + out-vatp_gds-dtlcl.discnt-rubl * out-vatp_gds-dtlcl.fact-qnty
       varsum-rubl-docovpcl  = varsum-rubl-docovpcl  + (out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl)                 * out-vatp_gds-dtlcl.doc-qnty
       varslt-rubl-docovpcl  = varslt-rubl-docovpcl  + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc)                   * out-vatp_gds-dtlcl.doc-qnty
       varvat-rubl-docovpcl  = varvat-rubl-docovpcl  + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc)                   * out-vatp_gds-dtlcl.doc-qnty
       varvatcons-rubl-docovpcl  = varvatcons-rubl-docovpcl  + (((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl - varprice-rubl-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.doc-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.doc-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl)
       vardsc-rubl-docovpcl  = vardsc-rubl-docovpcl  + out-vatp_gds-dtlcl.discnt-rubl * out-vatp_gds-dtlcl.doc-qnty   .
    end.
    if pardoc-type = 'инв':U then do:
      ASSIGN
                price-base-with-tax-salecl    = varsum-base-docovpcl / varfact-qntycl
        slt-base-salecl               = varslt-base-docovpcl / varfact-qntycl
        vat-base-buyercl              = varvat-base-docovpcl / varfact-qntycl
        discnt-base-salecl            = vardsc-base-docovpcl / varfact-qntycl
        vat-base-salecl               = varvatcons-base-docovpcl / varfact-qntycl
                price-rubl-with-tax-salecl    = varsum-rubl-docovpcl / varfact-qntycl
        slt-rubl-salecl               = varslt-rubl-docovpcl / varfact-qntycl
        vat-rubl-buyercl              = varvat-rubl-docovpcl / varfact-qntycl
        discnt-rubl-salecl            = vardsc-rubl-docovpcl / varfact-qntycl
        vat-rubl-salecl               = varvatcons-rubl-docovpcl / varfact-qntycl.
    end.
    else do:
      ASSIGN
                price-base-with-tax-salecl    = varsum-base-factovpcl / varfact-qntycl
        slt-base-salecl               = varslt-base-factovpcl / varfact-qntycl
        vat-base-buyercl              = varvat-base-factovpcl / varfact-qntycl
        discnt-base-salecl            = vardsc-base-factovpcl / varfact-qntycl
        vat-base-salecl               = varvatcons-base-factovpcl / varfact-qntycl
                price-rubl-with-tax-salecl    = varsum-rubl-factovpcl / varfact-qntycl
        slt-rubl-salecl               = varslt-rubl-factovpcl / varfact-qntycl
        vat-rubl-buyercl              = varvat-rubl-factovpcl / varfact-qntycl
        discnt-rubl-salecl            = vardsc-rubl-factovpcl / varfact-qntycl
        vat-rubl-salecl               = varvatcons-rubl-factovpcl / varfact-qntycl.
    end.
  end.
end.
assign
  price-base-without-tax-salecl = price-base-with-tax-salecl - vat-base-salecl - slt-base-salecl - road-tax-base-salecl
  price-rubl-without-tax-salecl = price-rubl-with-tax-salecl - vat-rubl-salecl - slt-rubl-salecl - road-tax-rubl-salecl.
end.
if paris-cur then do:
  assign
    parcurartic      = cl_tt-clcparts.artic
    parcurprod-type  = cl_tt-clcparts.prod-type
    parcurprod-code  = cl_tt-clcparts.prod-code
    parcurdoc-type   = cl_tt-clcparts.doc-type
    parcurdoc-code   = cl_tt-clcparts.out-code
    parcurobj-type   = cl_tt-clcparts.obj-type
    parcurobj-code   = cl_tt-clcparts.obj-code.
  if parr-b = "base" then do:
    assign
      parcurprice-base = parcur-base
      parcurprice-rubl = parcur-base * parbase-rate / parbase-scale.
  end.
  else do:
    assign
      parcurprice-base = parcur-base / parbase-rate * parbase-scale
      parcurprice-rubl = parcur-base.
  end.
  assign
    parcurbase-rate   = parbase-rate
    parcurbase-scale  = parbase-scale
    parcurdiscnt-base = 0
    parcurdiscnt-rubl = 0
    parcurfact-qnty   = cl_tt-clcparts.fact-qnty
    parcurcli-qnty    = cl_tt-clcparts.cli-qnty
    parcurdoc-qnty    = cl_tt-clcparts.qnty.
if parcurext-doc-type = 'ot':U or
   parcurext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-sltcur = yes.
end.
else do:
  find first out-vatp_doc-attrcur no-lock
    where out-vatp_doc-attrcur.doc-code  = parcurdoc-code
      and out-vatp_doc-attrcur.attr-code = 'envd':U
      no-error .
  if not available out-vatp_doc-attrcur then do:
    assign
      out-vatp-have-vat-sltcur = yes.
  end.
  else do:
     out-vatp-have-vat-sltcur = no.
  end.
end.
find first out-vatp_goodscur where out-vatp_goodscur.artic     = parcurartic     and
                                   out-vatp_goodscur.prod-type = parcurprod-type and
                                   out-vatp_goodscur.prod-code = parcurprod-code no-lock.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  parcurartic
  ,input  parcurprod-type
  ,input  parcurprod-code
  ,output varroot-nodecur
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" parcurartic parcurprod-type parcurprod-code skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  varroot-nodecur
  ,input  'empty-scale=request'
  ,output varempty-scalecur
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении атрибута признака" skip
    "Артикул" parcurartic parcurprod-type parcurprod-code skip
    "Признак" varroot-nodecur skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprbcur
  )  .
if varoutvprbcur = "base":u then do:
  assign
        road-tax-base-salecur    =  (if parcurroad-tax = ? then 0 else parcurroad-tax * 1)
    excise-base-salecur      =  (if parcurexcise   = ? then 0 else parcurexcise   * 1)
  .
end.
else do:
  assign
        road-tax-base-salecur    =  (if parcurroad-tax = ? then 0 else parcurroad-tax / parcurbase-rate * parcurbase-scale)
    excise-base-salecur      =  (if parcurexcise   = ? then 0 else parcurexcise   / parcurbase-rate * parcurbase-scale)
  .
end.
if varoutvprbcur = "rubl":u then do:
  assign
        road-tax-rubl-salecur    = (if parcurroad-tax = ? then 0 else parcurroad-tax * 1)
    excise-rubl-salecur      = (if parcurexcise   = ? then 0 else parcurexcise   * 1) .
end.
else do:
  assign
        road-tax-rubl-salecur    = (if parcurroad-tax = ? then 0 else parcurroad-tax * parcurbase-rate / parcurbase-scale)
    excise-rubl-salecur      = (if parcurexcise   = ? then 0 else parcurexcise   * parcurbase-rate / parcurbase-scale) .
end.
assign
  varis-cons-parts-havecur =  no.
assign
  varfact-qntycur       = 0
  varcons-qntycur       = 0
  varprice-base-conscur = 0
  varprice-rubl-conscur = 0.
if cl_tt-clcparts.purch-code = 2 then do:
assign
  price-rubl-with-tax-lococur = cl_tt-clcparts.price-rubl
  price-base-with-tax-lococur = cl_tt-clcparts.price-base
.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprbocur
  )  .
  if cl_tt-clcparts.out-code = 'free-zone':U     or
     cl_tt-clcparts.out-code = 'out-zone':U   or
     cl_tt-clcparts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-sltocur = yes.
  end.
  else do:
    find first in-vatp_doc-attrocur no-lock
      where in-vatp_doc-attrocur.doc-code  = cl_tt-clcparts.out-code
        and in-vatp_doc-attrocur.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attrocur then do:
      assign
        in-vatp-have-vat-sltocur = yes.
    end.
    else do:
         in-vatp-have-vat-sltocur = no.
    end.
  end.
  assign
   price-cli-with-tax-lococur = cl_tt-clcparts.price-cli
   cli-base-rateocur          = cl_tt-clcparts.cli-base-rate.
  ASSIGN   road-tax-base-lococur  = (if cl_tt-clcparts.road-tax-base  = ? then 0 else cl_tt-clcparts.road-tax-base)
           road-tax-rubl-lococur  = (if cl_tt-clcparts.road-tax-rubl  = ? then 0 else cl_tt-clcparts.road-tax-rubl).
  ASSIGN  transport-base-lococur = (if cl_tt-clcparts.transport-base = ? then 0 else cl_tt-clcparts.transport-base)
          transport-rubl-lococur = (if cl_tt-clcparts.transport-rubl = ? then 0 else cl_tt-clcparts.transport-rubl)
          other-base-lococur     = (if cl_tt-clcparts.other-base     = ? then 0 else cl_tt-clcparts.other-base)
          other-rubl-lococur     = (if cl_tt-clcparts.other-rubl     = ? then 0 else cl_tt-clcparts.other-rubl)
          vat-pc-lococur         = (if cl_tt-clcparts.vat-pc         = ? then 0 else cl_tt-clcparts.vat-pc)
          slt-pc-lococur         = (if cl_tt-clcparts.slt-pc         = ? then 0 else cl_tt-clcparts.slt-pc).
          ASSIGN   slt-base-lococur    = (if in-vatp-have-vat-sltocur = no then 0 else (price-base-with-tax-lococur - ((if road-tax-base-lococur  = ? then 0 else road-tax-base-lococur) + (if transport-base-lococur = ? then 0 else transport-base-lococur) + (if other-base-lococur = ? then 0 else other-base-lococur)))                           * slt-pc-lococur / (100 + slt-pc-lococur))                        vat-base-lococur    = (if in-vatp-have-vat-sltocur = no then 0 else (price-base-with-tax-lococur - ((if road-tax-base-lococur  = ? then 0 else road-tax-base-lococur) + (if transport-base-lococur = ? then 0 else transport-base-lococur) + (if other-base-lococur = ? then 0 else other-base-lococur))) * (1 - slt-pc-lococur / (100 + slt-pc-lococur)) * vat-pc-lococur / (100 + vat-pc-lococur)).
    ASSIGN   slt-rubl-lococur    = (if in-vatp-have-vat-sltocur = no then 0 else (price-rubl-with-tax-lococur - ((if road-tax-rubl-lococur  = ? then 0 else road-tax-rubl-lococur) + (if transport-rubl-lococur = ? then 0 else transport-rubl-lococur) + (if other-rubl-lococur = ? then 0 else other-rubl-lococur)))                           * slt-pc-lococur / (100 + slt-pc-lococur))                        vat-rubl-lococur    = (if in-vatp-have-vat-sltocur = no then 0 else (price-rubl-with-tax-lococur - ((if road-tax-rubl-lococur  = ? then 0 else road-tax-rubl-lococur) + (if transport-rubl-lococur = ? then 0 else transport-rubl-lococur) + (if other-rubl-lococur = ? then 0 else other-rubl-lococur))) * (1 - slt-pc-lococur / (100 + slt-pc-lococur)) * vat-pc-lococur / (100 + vat-pc-lococur)).
  assign
    exch-rate-cli-lococur = (cl_tt-clcparts.price-rubl - transport-rubl-lococur - other-rubl-lococur - road-tax-rubl-lococur - (if cl_tt-clcparts.vat-type <> 'в т. ч.':U then vat-rubl-lococur else 0) - (if cl_tt-clcparts.slt-type <> 'в т. ч.':U then slt-rubl-lococur else 0)) / cl_tt-clcparts.price-cli .
  assign
    slt-cli-lococur        = slt-rubl-lococur       / exch-rate-cli-lococur
    vat-cli-lococur        = vat-rubl-lococur       / exch-rate-cli-lococur
    road-tax-cli-lococur   = road-tax-rubl-lococur  / exch-rate-cli-lococur
    transport-cli-lococur  = 0
    other-cli-lococur      = 0
  .
ASSIGN
          price-base-without-tax-lococur = price-base-with-tax-lococur - vat-base-lococur - slt-base-lococur - ((if road-tax-base-lococur  = ? then 0 else road-tax-base-lococur) + (if transport-base-lococur = ? then 0 else transport-base-lococur) + (if other-base-lococur = ? then 0 else other-base-lococur))
    price-rubl-without-tax-lococur = price-rubl-with-tax-lococur - vat-rubl-lococur - slt-rubl-lococur - ((if road-tax-rubl-lococur  = ? then 0 else road-tax-rubl-lococur) + (if transport-rubl-lococur = ? then 0 else transport-rubl-lococur) + (if other-rubl-lococur = ? then 0 else other-rubl-lococur))
.
  assign
    varprice-base-conscur    = varprice-base-conscur + (price-base-with-tax-lococur - (if road-tax-base-lococur = ? then 0 else road-tax-base-lococur))* cl_tt-clcparts.fact-qnty
    varprice-rubl-conscur    = varprice-rubl-conscur + (price-rubl-with-tax-lococur - (if road-tax-rubl-lococur = ? then 0 else road-tax-rubl-lococur))* cl_tt-clcparts.fact-qnty
    varis-cons-parts-havecur = yes
    varcons-qntycur          = varcons-qntycur + cl_tt-clcparts.fact-qnty.
end.
assign
  varfact-qntycur = cl_tt-clcparts.fact-qnty.
assign
  varprice-base-conscur = varprice-base-conscur / varcons-qntycur
  varprice-rubl-conscur = varprice-rubl-conscur / varcons-qntycur.
if varprice-base-conscur = ? then do:
  assign
    varprice-base-conscur = 0.
end.
if varprice-rubl-conscur = ? then do:
  assign
    varprice-rubl-conscur = 0.
end.
assign
    slt-base-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc)
  vat-base-buyercur              = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-base-salecur) * parcurvat-pc / (100 + parcurvat-pc)
  discnt-base-salecur            = parcurdiscnt-base
  price-base-with-tax-salecur    = (parcurprice-base - parcurdiscnt-base)
    slt-rubl-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc)
  vat-rubl-buyercur              = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-rubl-salecur) * parcurvat-pc / (100 + parcurvat-pc)
  discnt-rubl-salecur            = parcurdiscnt-rubl
  price-rubl-with-tax-salecur    = (parcurprice-rubl - parcurdiscnt-rubl)
  .
if parcurdoc-type = 'инв':U then do:
  assign
    varfact-qntycur = parcurdoc-qnty.
end.
else do:
  assign
    varfact-qntycur = parcurfact-qnty.
end.
if varis-cons-parts-havecur = no then do:
  assign
        vat-base-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-base-salecur) * parcurvat-pc / (100 + parcurvat-pc)
        vat-rubl-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-rubl-salecur) * parcurvat-pc / (100 + parcurvat-pc).
end.
else do:
  if parcurdoc-type = 'инв':U then do:
    assign
            vat-base-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else (((parcurprice-base - parcurdiscnt-base) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-base-salecur - varprice-base-conscur) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * parcurdoc-qnty * varcons-qntycur / varfact-qntycur + ((parcurprice-base - parcurdiscnt-base) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-base-salecur) * parcurvat-pc / (100 + parcurvat-pc) * parcurdoc-qnty * (varfact-qntycur - varcons-qntycur) / varfact-qntycur) / varfact-qntycur)
            vat-rubl-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else (((parcurprice-rubl - parcurdiscnt-rubl) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-rubl-salecur - varprice-rubl-conscur) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * parcurdoc-qnty * varcons-qntycur / varfact-qntycur + ((parcurprice-rubl - parcurdiscnt-rubl) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-rubl-salecur) * parcurvat-pc / (100 + parcurvat-pc) * parcurdoc-qnty * (varfact-qntycur - varcons-qntycur) / varfact-qntycur) / varfact-qntycur)
     .
  end.
  else do:
    assign
            vat-base-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else (((parcurprice-base - parcurdiscnt-base) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-base-salecur - varprice-base-conscur) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * parcurfact-qnty * varcons-qntycur / varfact-qntycur + ((parcurprice-base - parcurdiscnt-base) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - varprice-base-conscur) * parcurvat-pc / (100 + parcurvat-pc) * parcurfact-qnty * (varfact-qntycur - varcons-qntycur) / varfact-qntycur) / varfact-qntycur)
            vat-rubl-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else (((parcurprice-rubl - parcurdiscnt-rubl) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-rubl-salecur - varprice-rubl-conscur) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * parcurfact-qnty * varcons-qntycur / varfact-qntycur + ((parcurprice-rubl - parcurdiscnt-rubl) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - varprice-rubl-conscur) * parcurvat-pc / (100 + parcurvat-pc) * parcurfact-qnty * (varfact-qntycur - varcons-qntycur) / varfact-qntycur) / varfact-qntycur)
     .
  end.
end.
assign
price-base-without-tax-salecur = price-base-with-tax-salecur - vat-base-salecur - slt-base-salecur - road-tax-base-salecur
price-rubl-without-tax-salecur = price-rubl-with-tax-salecur - vat-rubl-salecur - slt-rubl-salecur - road-tax-rubl-salecur.
end.
create bf_tt-allsum.
assign
  bf_tt-allsum.sum-type = 'основная_сумма':U.
assign
  bf_tt-allsum.fact-qnty          =  cl_tt-clcparts.fact-qnty
  bf_tt-allsum.cli-qnty           =  cl_tt-clcparts.cli-qnty
  bf_tt-allsum.sum-dsc-base-doc   =  (if price-base-with-tax-salecl  = ? then 0 else price-base-with-tax-salecl  * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.sum-dsc-rubl-doc   =  (if price-rubl-with-tax-salecl  = ? then 0 else price-rubl-with-tax-salecl  * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.dsc-base-doc       =  (if discnt-base-salecl          = ? then 0 else discnt-base-salecl          * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.dsc-rubl-doc       =  (if discnt-rubl-salecl          = ? then 0 else discnt-rubl-salecl          * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-base-doc       =  (if slt-base-salecl             = ? then 0 else slt-base-salecl             * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-rubl-doc       =  (if slt-rubl-salecl             = ? then 0 else slt-rubl-salecl             * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-base-buyer-doc =  (if vat-base-buyercl            = ? then 0 else vat-base-buyercl            * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-rubl-buyer-doc =  (if vat-rubl-buyercl            = ? then 0 else vat-rubl-buyercl            * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-base-doc  =  (if road-tax-base-salecl        = ? then 0 else road-tax-base-salecl        * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-rubl-doc  =  (if road-tax-rubl-salecl        = ? then 0 else road-tax-rubl-salecl        * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.excise-base-doc    =  (if excise-base-salecl          = ? then 0 else excise-base-salecl          * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.excise-rubl-doc    =  (if excise-rubl-salecl          = ? then 0 else excise-rubl-salecl          * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.sum-dsc-base-cur   =  (if price-base-with-tax-salecur = ? then 0 else price-base-with-tax-salecur * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.sum-dsc-rubl-cur   =  (if price-rubl-with-tax-salecur = ? then 0 else price-rubl-with-tax-salecur * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.dsc-base-cur       =  (if discnt-base-salecur         = ? then 0 else discnt-base-salecur         * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.dsc-rubl-cur       =  (if discnt-rubl-salecur         = ? then 0 else discnt-rubl-salecur         * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-base-cur       =  (if slt-base-salecur            = ? then 0 else slt-base-salecur            * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-rubl-cur       =  (if slt-rubl-salecur            = ? then 0 else slt-rubl-salecur            * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-base-buyer-cur =  (if vat-base-buyercur           = ? then 0 else vat-base-buyercur           * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-rubl-buyer-cur =  (if vat-rubl-buyercur           = ? then 0 else vat-rubl-buyercur           * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-base-cur  =  (if road-tax-base-salecur       = ? then 0 else road-tax-base-salecur       * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-rubl-cur  =  (if road-tax-rubl-salecur       = ? then 0 else road-tax-rubl-salecur       * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.excise-base-cur    =  (if excise-base-salecur         = ? then 0 else excise-base-salecur         * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.excise-rubl-cur    =  (if excise-rubl-salecur         = ? then 0 else excise-rubl-salecur         * cl_tt-clcparts.fact-qnty)
  .
if cl_tt-clcparts.purch-code = integer('2':U) then do:
  assign
    bf_tt-allsum.vat-base-doc = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-base-with-tax-salecl  - road-tax-base-salecl  - slt-base-salecl  - (cl_tt-clcparts.price-base - cl_tt-clcparts.road-tax-base)) * parcons-vat-pc / (100 + parcons-vat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-rubl-doc = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-rubl-with-tax-salecl  - road-tax-rubl-salecl  - slt-rubl-salecl  - (cl_tt-clcparts.price-rubl - cl_tt-clcparts.road-tax-rubl)) * parcons-vat-pc / (100 + parcons-vat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-base-cur = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-base-with-tax-salecur - road-tax-base-salecur - slt-base-salecur - (cl_tt-clcparts.price-base - cl_tt-clcparts.road-tax-base)) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-rubl-cur = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-rubl-with-tax-salecur - road-tax-rubl-salecur - slt-rubl-salecur - (cl_tt-clcparts.price-rubl - cl_tt-clcparts.road-tax-rubl)) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * cl_tt-clcparts.fact-qnty)
    .
end.
else do:
  assign
    bf_tt-allsum.vat-base-doc = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-base-with-tax-salecl  - road-tax-base-salecl  - slt-base-salecl ) * parvat-pc / (100 + parvat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-rubl-doc = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-rubl-with-tax-salecl  - road-tax-rubl-salecl  - slt-rubl-salecl ) * parvat-pc / (100 + parvat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-base-cur = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-base-with-tax-salecur - road-tax-base-salecur - slt-base-salecur) * parcurvat-pc / (100 + parcurvat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-rubl-cur = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-rubl-with-tax-salecur - road-tax-rubl-salecur - slt-rubl-salecur) * parcurvat-pc / (100 + parcurvat-pc) * cl_tt-clcparts.fact-qnty)
    .
end.
if bf_tt-allsum.vat-base-doc = ? then bf_tt-allsum.vat-base-doc = 0.
if bf_tt-allsum.vat-rubl-doc = ? then bf_tt-allsum.vat-rubl-doc = 0.
assign
  bf_tt-allsum.sum-dsc-base-acc     = (if price-base-with-tax-loccl    = ? then 0 else price-base-with-tax-loccl    * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.sum-dsc-rubl-acc     = (if price-rubl-with-tax-loccl    = ? then 0 else price-rubl-with-tax-loccl    * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.sum-dsc-cli-acc      = (if (price-cli-with-tax-loccl +
                                           road-tax-cli-loccl       +
                                           (if cl_tt-clcparts.vat-type <> 'в т. ч.':U then vat-cli-loccl else 0) +
                                           (if cl_tt-clcparts.slt-type <> 'в т. ч.':U then slt-cli-loccl else 0)
                                           ) / cli-base-ratecl = ? then 0
                                        else
                                          (price-cli-with-tax-loccl +
                                           road-tax-cli-loccl       +
                                           (if cl_tt-clcparts.vat-type <> 'в т. ч.':U then vat-cli-loccl else 0) +
                                           (if cl_tt-clcparts.slt-type <> 'в т. ч.':U then slt-cli-loccl else 0)
                                           ) / cli-base-ratecl * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.dsc-base-acc         = 0
  bf_tt-allsum.dsc-rubl-acc         = 0
  bf_tt-allsum.dsc-cli-acc          = 0
  bf_tt-allsum.vat-base-acc         = (if vat-base-loccl      = ? then 0 else vat-base-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-rubl-acc         = (if vat-rubl-loccl      = ? then 0 else vat-rubl-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-cli-acc          = (if vat-cli-loccl / cli-base-ratecl      = ? then 0 else vat-cli-loccl / cli-base-ratecl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-base-acc         = (if slt-base-loccl      = ? then 0 else slt-base-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-rubl-acc         = (if slt-rubl-loccl      = ? then 0 else slt-rubl-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-cli-acc          = (if slt-cli-loccl / cli-base-ratecl      = ? then 0 else slt-cli-loccl / cli-base-ratecl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-base-acc    = (if road-tax-base-loccl = ? then 0 else road-tax-base-loccl * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-rubl-acc    = (if road-tax-rubl-loccl = ? then 0 else road-tax-rubl-loccl * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-cli-acc     = (if road-tax-cli-loccl / cli-base-ratecl = ? then 0 else road-tax-cli-loccl / cli-base-ratecl * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.excise-base-acc      = 0
  bf_tt-allsum.excise-rubl-acc      = 0
  bf_tt-allsum.excise-cli-acc       = 0
  bf_tt-allsum.transport-base-acc   = (if transport-base-loccl   = ? then 0 else transport-base-loccl  * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.transport-rubl-acc   = (if transport-rubl-loccl   = ? then 0 else transport-rubl-loccl  * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.transport-cli-acc    = (if transport-cli-loccl / cli-base-ratecl   = ? then 0 else transport-cli-loccl / cli-base-ratecl  * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.other-base-acc       = (if other-base-loccl       = ? then 0 else other-base-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.other-rubl-acc       = (if other-rubl-loccl       = ? then 0 else other-rubl-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.other-cli-acc        = (if other-cli-loccl / cli-base-ratecl       = ? then 0 else other-cli-loccl     / cli-base-ratecl  * cl_tt-clcparts.fact-qnty).
create bfs_tt-allsum.
assign
  bfs_tt-allsum.sum-type = 'основная_сумма_со_знаком':U.
if pardoc-type = 'инв':U or
   pardoc-type = 'при':U    or
   pardoc-type = 'возврат':U    then do:
   buffer-copy bf_tt-allsum except bf_tt-allsum.sum-type to bfs_tt-allsum.
end.
else do:
  assign
    bfs_tt-allsum.fact-qnty           =  - bf_tt-allsum.fact-qnty
    bfs_tt-allsum.cli-qnty            =  - bf_tt-allsum.cli-qnty
    bfs_tt-allsum.sum-dsc-base-doc    =  - bf_tt-allsum.sum-dsc-base-doc
    bfs_tt-allsum.sum-dsc-rubl-doc    =  - bf_tt-allsum.sum-dsc-rubl-doc
    bfs_tt-allsum.dsc-base-doc        =  - bf_tt-allsum.dsc-base-doc
    bfs_tt-allsum.dsc-rubl-doc        =  - bf_tt-allsum.dsc-rubl-doc
    bfs_tt-allsum.vat-base-doc        =  - bf_tt-allsum.vat-base-doc
    bfs_tt-allsum.vat-rubl-doc        =  - bf_tt-allsum.vat-rubl-doc
    bfs_tt-allsum.vat-base-buyer-doc  =  - bf_tt-allsum.vat-base-buyer-doc
    bfs_tt-allsum.vat-rubl-buyer-doc  =  - bf_tt-allsum.vat-rubl-buyer-doc
    bfs_tt-allsum.slt-base-doc        =  - bf_tt-allsum.slt-base-doc
    bfs_tt-allsum.slt-rubl-doc        =  - bf_tt-allsum.slt-rubl-doc
    bfs_tt-allsum.road-tax-base-doc   =  - bf_tt-allsum.road-tax-base-doc
    bfs_tt-allsum.road-tax-rubl-doc   =  - bf_tt-allsum.road-tax-rubl-doc
    bfs_tt-allsum.excise-base-doc     =  - bf_tt-allsum.excise-base-doc
    bfs_tt-allsum.excise-rubl-doc     =  - bf_tt-allsum.excise-rubl-doc
    bfs_tt-allsum.sum-dsc-base-cur    =  - bf_tt-allsum.sum-dsc-base-cur
    bfs_tt-allsum.sum-dsc-rubl-cur    =  - bf_tt-allsum.sum-dsc-rubl-cur
    bfs_tt-allsum.dsc-base-cur        =  - bf_tt-allsum.dsc-base-cur
    bfs_tt-allsum.dsc-rubl-cur        =  - bf_tt-allsum.dsc-rubl-cur
    bfs_tt-allsum.vat-base-cur        =  - bf_tt-allsum.vat-base-cur
    bfs_tt-allsum.vat-rubl-cur        =  - bf_tt-allsum.vat-rubl-cur
    bfs_tt-allsum.vat-base-buyer-cur  =  - bf_tt-allsum.vat-base-buyer-cur
    bfs_tt-allsum.vat-rubl-buyer-cur  =  - bf_tt-allsum.vat-rubl-buyer-cur
    bfs_tt-allsum.slt-base-cur        =  - bf_tt-allsum.slt-base-cur
    bfs_tt-allsum.slt-rubl-cur        =  - bf_tt-allsum.slt-rubl-cur
    bfs_tt-allsum.road-tax-base-cur   =  - bf_tt-allsum.road-tax-base-cur
    bfs_tt-allsum.road-tax-rubl-cur   =  - bf_tt-allsum.road-tax-rubl-cur
    bfs_tt-allsum.excise-base-cur     =  - bf_tt-allsum.excise-base-cur
    bfs_tt-allsum.excise-rubl-cur     =  - bf_tt-allsum.excise-rubl-cur
    bfs_tt-allsum.sum-dsc-base-acc    =  - bf_tt-allsum.sum-dsc-base-acc
    bfs_tt-allsum.sum-dsc-rubl-acc    =  - bf_tt-allsum.sum-dsc-rubl-acc
    bfs_tt-allsum.sum-dsc-cli-acc     =  - bf_tt-allsum.sum-dsc-cli-acc
    bfs_tt-allsum.dsc-base-acc        =  - bf_tt-allsum.dsc-base-acc
    bfs_tt-allsum.dsc-rubl-acc        =  - bf_tt-allsum.dsc-rubl-acc
    bfs_tt-allsum.dsc-cli-acc         =  - bf_tt-allsum.dsc-cli-acc
    bfs_tt-allsum.vat-base-acc        =  - bf_tt-allsum.vat-base-acc
    bfs_tt-allsum.vat-rubl-acc        =  - bf_tt-allsum.vat-rubl-acc
    bfs_tt-allsum.vat-cli-acc         =  - bf_tt-allsum.vat-cli-acc
    bfs_tt-allsum.slt-base-acc        =  - bf_tt-allsum.slt-base-acc
    bfs_tt-allsum.slt-rubl-acc        =  - bf_tt-allsum.slt-rubl-acc
    bfs_tt-allsum.slt-cli-acc         =  - bf_tt-allsum.slt-cli-acc
    bfs_tt-allsum.road-tax-base-acc   =  - bf_tt-allsum.road-tax-base-acc
    bfs_tt-allsum.road-tax-rubl-acc   =  - bf_tt-allsum.road-tax-rubl-acc
    bfs_tt-allsum.road-tax-cli-acc    =  - bf_tt-allsum.road-tax-cli-acc
    bfs_tt-allsum.excise-base-acc     =  - bf_tt-allsum.excise-base-acc
    bfs_tt-allsum.excise-rubl-acc     =  - bf_tt-allsum.excise-rubl-acc
    bfs_tt-allsum.excise-cli-acc      =  - bf_tt-allsum.excise-cli-acc
    bfs_tt-allsum.transport-base-acc  =  - bf_tt-allsum.transport-base-acc
    bfs_tt-allsum.transport-rubl-acc  =  - bf_tt-allsum.transport-rubl-acc
    bfs_tt-allsum.transport-cli-acc   =  - bf_tt-allsum.transport-cli-acc
    bfs_tt-allsum.other-base-acc      =  - bf_tt-allsum.other-base-acc
    bfs_tt-allsum.other-rubl-acc      =  - bf_tt-allsum.other-rubl-acc
    bfs_tt-allsum.other-cli-acc       =  - bf_tt-allsum.other-cli-acc.
end.
create bfpc_tt-allsum.
create bfspc_tt-allsum.
case cl_tt-clcparts.purch-code :
when 1           then do:
  assign
    bfpc_tt-allsum.sum-type  = 'сумма_по_выкупу':U
    bfspc_tt-allsum.sum-type = 'сумма_по_выкупу_со_знаком':U.
  buffer-copy bf_tt-allsum  except bf_tt-allsum.sum-type  to bfpc_tt-allsum.
  buffer-copy bfs_tt-allsum except bfs_tt-allsum.sum-type to bfspc_tt-allsum.
end.
when 4    then do:
  assign
    bfpc_tt-allsum.sum-type  = 'сумма_по_старой_консигнации':U
    bfspc_tt-allsum.sum-type = 'сумма_по_старой_консигнации_со_знаком':U.
  buffer-copy bf_tt-allsum  except bf_tt-allsum.sum-type  to bfpc_tt-allsum.
  buffer-copy bfs_tt-allsum except bfs_tt-allsum.sum-type to bfspc_tt-allsum.
end.
when 3 then do:
  assign
    bfpc_tt-allsum.sum-type  = 'сумма_по_ответственному_хранению':U
    bfspc_tt-allsum.sum-type = 'сумма_по_ответственному_хранению_со_знаком':U.
  buffer-copy bf_tt-allsum  except bf_tt-allsum.sum-type  to bfpc_tt-allsum.
  buffer-copy bfs_tt-allsum except bfs_tt-allsum.sum-type to bfspc_tt-allsum.
end.
when 2 then do:
  assign
    bfpc_tt-allsum.sum-type  = 'сумма_по_консигнации_выгода':U
    bfspc_tt-allsum.sum-type = 'сумма_по_консигнации_выгода_со_знаком':U.
  assign
    bfpc_tt-allsum.fact-qnty           = bf_tt-allsum.fact-qnty
    bfpc_tt-allsum.cli-qnty            = bf_tt-allsum.cli-qnty
    bfpc_tt-allsum.sum-dsc-base-doc    = bf_tt-allsum.sum-dsc-base-doc    - bf_tt-allsum.sum-dsc-base-acc
    bfpc_tt-allsum.sum-dsc-rubl-doc    = bf_tt-allsum.sum-dsc-rubl-doc    - bf_tt-allsum.sum-dsc-rubl-acc
    bfpc_tt-allsum.dsc-base-doc        = bf_tt-allsum.dsc-base-doc        - bf_tt-allsum.dsc-base-acc
    bfpc_tt-allsum.dsc-rubl-doc        = bf_tt-allsum.dsc-rubl-doc        - bf_tt-allsum.dsc-rubl-acc
    bfpc_tt-allsum.vat-base-doc        = bf_tt-allsum.vat-base-doc
    bfpc_tt-allsum.vat-rubl-doc        = bf_tt-allsum.vat-rubl-doc
    bfpc_tt-allsum.vat-base-buyer-doc  = bf_tt-allsum.vat-base-buyer-doc  - bf_tt-allsum.vat-base-acc
    bfpc_tt-allsum.vat-rubl-buyer-doc  = bf_tt-allsum.vat-rubl-buyer-doc  - bf_tt-allsum.vat-rubl-acc
    bfpc_tt-allsum.slt-base-doc        = bf_tt-allsum.slt-base-doc        - bf_tt-allsum.slt-base-acc
    bfpc_tt-allsum.slt-rubl-doc        = bf_tt-allsum.slt-rubl-doc        - bf_tt-allsum.slt-rubl-acc
    bfpc_tt-allsum.road-tax-base-doc   = bf_tt-allsum.road-tax-base-doc   - bf_tt-allsum.road-tax-base-acc
    bfpc_tt-allsum.road-tax-rubl-doc   = bf_tt-allsum.road-tax-rubl-doc   - bf_tt-allsum.road-tax-rubl-acc
    bfpc_tt-allsum.excise-base-doc     = bf_tt-allsum.excise-base-doc
    bfpc_tt-allsum.excise-rubl-doc     = bf_tt-allsum.excise-rubl-doc
    bfpc_tt-allsum.sum-dsc-base-cur    = bf_tt-allsum.sum-dsc-base-cur    - bf_tt-allsum.sum-dsc-base-acc
    bfpc_tt-allsum.sum-dsc-rubl-cur    = bf_tt-allsum.sum-dsc-rubl-cur    - bf_tt-allsum.sum-dsc-rubl-acc
    bfpc_tt-allsum.dsc-base-cur        = bf_tt-allsum.dsc-base-cur        - bf_tt-allsum.dsc-base-acc
    bfpc_tt-allsum.dsc-rubl-cur        = bf_tt-allsum.dsc-rubl-cur        - bf_tt-allsum.dsc-rubl-acc
    bfpc_tt-allsum.vat-base-cur        = bf_tt-allsum.vat-base-cur
    bfpc_tt-allsum.vat-rubl-cur        = bf_tt-allsum.vat-rubl-cur
    bfpc_tt-allsum.vat-base-buyer-cur  = bf_tt-allsum.vat-base-buyer-cur  - bf_tt-allsum.vat-base-acc
    bfpc_tt-allsum.vat-rubl-buyer-cur  = bf_tt-allsum.vat-rubl-buyer-cur  - bf_tt-allsum.vat-rubl-acc
    bfpc_tt-allsum.slt-base-cur        = bf_tt-allsum.slt-base-cur        - bf_tt-allsum.slt-base-acc
    bfpc_tt-allsum.slt-rubl-cur        = bf_tt-allsum.slt-rubl-cur        - bf_tt-allsum.slt-rubl-acc
    bfpc_tt-allsum.road-tax-base-cur   = bf_tt-allsum.road-tax-base-cur   - bf_tt-allsum.road-tax-base-acc
    bfpc_tt-allsum.road-tax-rubl-cur   = bf_tt-allsum.road-tax-rubl-cur   - bf_tt-allsum.road-tax-rubl-acc
    bfpc_tt-allsum.excise-base-cur     = bf_tt-allsum.excise-base-cur
    bfpc_tt-allsum.excise-rubl-cur     = bf_tt-allsum.excise-rubl-cur
    bfpc_tt-allsum.sum-dsc-base-acc    = 0
    bfpc_tt-allsum.sum-dsc-rubl-acc    = 0
    bfpc_tt-allsum.sum-dsc-cli-acc     = 0
    bfpc_tt-allsum.dsc-base-acc        = 0
    bfpc_tt-allsum.dsc-rubl-acc        = 0
    bfpc_tt-allsum.dsc-cli-acc         = 0
    bfpc_tt-allsum.vat-base-acc        = 0
    bfpc_tt-allsum.vat-rubl-acc        = 0
    bfpc_tt-allsum.vat-cli-acc         = 0
    bfpc_tt-allsum.slt-base-acc        = 0
    bfpc_tt-allsum.slt-rubl-acc        = 0
    bfpc_tt-allsum.slt-cli-acc         = 0
    bfpc_tt-allsum.road-tax-base-acc   = 0
    bfpc_tt-allsum.road-tax-rubl-acc   = 0
    bfpc_tt-allsum.road-tax-cli-acc    = 0
    bfpc_tt-allsum.excise-base-acc     = 0
    bfpc_tt-allsum.excise-rubl-acc     = 0
    bfpc_tt-allsum.excise-cli-acc      = 0
    bfpc_tt-allsum.transport-base-acc  = 0
    bfpc_tt-allsum.transport-rubl-acc  = 0
    bfpc_tt-allsum.transport-cli-acc   = 0
    bfpc_tt-allsum.other-base-acc      = 0
    bfpc_tt-allsum.other-rubl-acc      = 0
    bfpc_tt-allsum.other-cli-acc       = 0
    .
  assign
    bfspc_tt-allsum.fact-qnty           = bfs_tt-allsum.fact-qnty
    bfspc_tt-allsum.cli-qnty            = bfs_tt-allsum.cli-qnty
    bfspc_tt-allsum.sum-dsc-base-doc    = bfs_tt-allsum.sum-dsc-base-doc    - bfs_tt-allsum.sum-dsc-base-acc
    bfspc_tt-allsum.sum-dsc-rubl-doc    = bfs_tt-allsum.sum-dsc-rubl-doc    - bfs_tt-allsum.sum-dsc-rubl-acc
    bfspc_tt-allsum.dsc-base-doc        = bfs_tt-allsum.dsc-base-doc        - bfs_tt-allsum.dsc-base-acc
    bfspc_tt-allsum.dsc-rubl-doc        = bfs_tt-allsum.dsc-rubl-doc        - bfs_tt-allsum.dsc-rubl-acc
    bfspc_tt-allsum.vat-base-doc        = bfs_tt-allsum.vat-base-doc
    bfspc_tt-allsum.vat-rubl-doc        = bfs_tt-allsum.vat-rubl-doc
    bfspc_tt-allsum.vat-base-buyer-doc  = bfs_tt-allsum.vat-base-buyer-doc  - bfs_tt-allsum.vat-base-acc
    bfspc_tt-allsum.vat-rubl-buyer-doc  = bfs_tt-allsum.vat-rubl-buyer-doc  - bfs_tt-allsum.vat-rubl-acc
    bfspc_tt-allsum.slt-base-doc        = bfs_tt-allsum.slt-base-doc        - bfs_tt-allsum.slt-base-acc
    bfspc_tt-allsum.slt-rubl-doc        = bfs_tt-allsum.slt-rubl-doc        - bfs_tt-allsum.slt-rubl-acc
    bfspc_tt-allsum.road-tax-base-doc   = bfs_tt-allsum.road-tax-base-doc   - bfs_tt-allsum.road-tax-base-acc
    bfspc_tt-allsum.road-tax-rubl-doc   = bfs_tt-allsum.road-tax-rubl-doc   - bfs_tt-allsum.road-tax-rubl-acc
    bfspc_tt-allsum.excise-base-doc     = bfs_tt-allsum.excise-base-doc
    bfspc_tt-allsum.excise-rubl-doc     = bfs_tt-allsum.excise-rubl-doc
    bfspc_tt-allsum.sum-dsc-base-cur    = bfs_tt-allsum.sum-dsc-base-cur    - bfs_tt-allsum.sum-dsc-base-acc
    bfspc_tt-allsum.sum-dsc-rubl-cur    = bfs_tt-allsum.sum-dsc-rubl-cur    - bfs_tt-allsum.sum-dsc-rubl-acc
    bfspc_tt-allsum.dsc-base-cur        = bfs_tt-allsum.dsc-base-cur        - bfs_tt-allsum.dsc-base-acc
    bfspc_tt-allsum.dsc-rubl-cur        = bfs_tt-allsum.dsc-rubl-cur        - bfs_tt-allsum.dsc-rubl-acc
    bfspc_tt-allsum.vat-base-cur        = bfs_tt-allsum.vat-base-cur
    bfspc_tt-allsum.vat-rubl-cur        = bfs_tt-allsum.vat-rubl-cur
    bfspc_tt-allsum.vat-base-buyer-cur  = bfs_tt-allsum.vat-base-buyer-cur  - bfs_tt-allsum.vat-base-acc
    bfspc_tt-allsum.vat-rubl-buyer-cur  = bfs_tt-allsum.vat-rubl-buyer-cur  - bfs_tt-allsum.vat-rubl-acc
    bfspc_tt-allsum.slt-base-cur        = bfs_tt-allsum.slt-base-cur        - bfs_tt-allsum.slt-base-acc
    bfspc_tt-allsum.slt-rubl-cur        = bfs_tt-allsum.slt-rubl-cur        - bfs_tt-allsum.slt-rubl-acc
    bfspc_tt-allsum.road-tax-base-cur   = bfs_tt-allsum.road-tax-base-cur   - bfs_tt-allsum.road-tax-base-acc
    bfspc_tt-allsum.road-tax-rubl-cur   = bfs_tt-allsum.road-tax-rubl-cur   - bfs_tt-allsum.road-tax-rubl-acc
    bfspc_tt-allsum.excise-base-cur     = bfs_tt-allsum.excise-base-cur
    bfspc_tt-allsum.excise-rubl-cur     = bfs_tt-allsum.excise-rubl-cur
    bfspc_tt-allsum.sum-dsc-base-acc    = 0
    bfspc_tt-allsum.sum-dsc-rubl-acc    = 0
    bfspc_tt-allsum.sum-dsc-cli-acc     = 0
    bfspc_tt-allsum.dsc-base-acc        = 0
    bfspc_tt-allsum.dsc-rubl-acc        = 0
    bfspc_tt-allsum.dsc-cli-acc         = 0
    bfspc_tt-allsum.vat-base-acc        = 0
    bfspc_tt-allsum.vat-rubl-acc        = 0
    bfspc_tt-allsum.vat-cli-acc         = 0
    bfspc_tt-allsum.slt-base-acc        = 0
    bfspc_tt-allsum.slt-rubl-acc        = 0
    bfspc_tt-allsum.slt-cli-acc         = 0
    bfspc_tt-allsum.road-tax-base-acc   = 0
    bfspc_tt-allsum.road-tax-rubl-acc   = 0
    bfspc_tt-allsum.road-tax-cli-acc    = 0
    bfspc_tt-allsum.excise-base-acc     = 0
    bfspc_tt-allsum.excise-rubl-acc     = 0
    bfspc_tt-allsum.excise-cli-acc      = 0
    bfspc_tt-allsum.transport-base-acc  = 0
    bfspc_tt-allsum.transport-rubl-acc  = 0
    bfspc_tt-allsum.transport-cli-acc   = 0
    bfspc_tt-allsum.other-base-acc      = 0
    bfspc_tt-allsum.other-rubl-acc      = 0
    bfspc_tt-allsum.other-cli-acc       = 0
    .
  create bfacc_tt-allsum.
  assign
    bfacc_tt-allsum.sum-type = 'сумма_по_консигнации_закупка':U.
  create bfsacc_tt-allsum.
  assign
    bfsacc_tt-allsum.sum-type = 'сумма_по_консигнации_закупка_со_знаком':U.
  assign
    bfacc_tt-allsum.fact-qnty           = bf_tt-allsum.fact-qnty
    bfacc_tt-allsum.cli-qnty            = bf_tt-allsum.cli-qnty
    bfacc_tt-allsum.sum-dsc-base-doc    = bf_tt-allsum.sum-dsc-base-acc
    bfacc_tt-allsum.sum-dsc-rubl-doc    = bf_tt-allsum.sum-dsc-rubl-acc
    bfacc_tt-allsum.dsc-base-doc        = bf_tt-allsum.dsc-base-acc
    bfacc_tt-allsum.dsc-rubl-doc        = bf_tt-allsum.dsc-rubl-acc
    bfacc_tt-allsum.vat-base-doc        = 0
    bfacc_tt-allsum.vat-rubl-doc        = 0
    bfacc_tt-allsum.vat-base-buyer-doc  = bf_tt-allsum.vat-base-acc
    bfacc_tt-allsum.vat-rubl-buyer-doc  = bf_tt-allsum.vat-rubl-acc
    bfacc_tt-allsum.slt-base-doc        = bf_tt-allsum.slt-base-acc
    bfacc_tt-allsum.slt-rubl-doc        = bf_tt-allsum.slt-rubl-acc
    bfacc_tt-allsum.road-tax-base-doc   = bf_tt-allsum.road-tax-base-acc
    bfacc_tt-allsum.road-tax-rubl-doc   = bf_tt-allsum.road-tax-rubl-acc
    bfacc_tt-allsum.excise-base-doc     = bf_tt-allsum.excise-base-acc
    bfacc_tt-allsum.excise-rubl-doc     = bf_tt-allsum.excise-rubl-acc
    bfacc_tt-allsum.sum-dsc-base-cur    = bf_tt-allsum.sum-dsc-base-acc
    bfacc_tt-allsum.sum-dsc-rubl-cur    = bf_tt-allsum.sum-dsc-rubl-acc
    bfacc_tt-allsum.dsc-base-cur        = bf_tt-allsum.dsc-base-acc
    bfacc_tt-allsum.dsc-rubl-cur        = bf_tt-allsum.dsc-rubl-acc
    bfacc_tt-allsum.vat-base-cur        = 0
    bfacc_tt-allsum.vat-rubl-cur        = 0
    bfacc_tt-allsum.vat-base-buyer-cur  = bf_tt-allsum.vat-base-acc
    bfacc_tt-allsum.vat-rubl-buyer-cur  = bf_tt-allsum.vat-rubl-acc
    bfacc_tt-allsum.slt-base-cur        = bf_tt-allsum.slt-base-acc
    bfacc_tt-allsum.slt-rubl-cur        = bf_tt-allsum.slt-rubl-acc
    bfacc_tt-allsum.road-tax-base-cur   = bf_tt-allsum.road-tax-base-acc
    bfacc_tt-allsum.road-tax-rubl-cur   = bf_tt-allsum.road-tax-rubl-acc
    bfacc_tt-allsum.excise-base-cur     = bf_tt-allsum.excise-base-acc
    bfacc_tt-allsum.excise-rubl-cur     = bf_tt-allsum.excise-rubl-acc
    bfacc_tt-allsum.sum-dsc-base-acc    = bf_tt-allsum.sum-dsc-base-acc
    bfacc_tt-allsum.sum-dsc-rubl-acc    = bf_tt-allsum.sum-dsc-rubl-acc
    bfacc_tt-allsum.sum-dsc-cli-acc     = bf_tt-allsum.sum-dsc-cli-acc
    bfacc_tt-allsum.dsc-base-acc        = bf_tt-allsum.dsc-base-acc
    bfacc_tt-allsum.dsc-rubl-acc        = bf_tt-allsum.dsc-rubl-acc
    bfacc_tt-allsum.dsc-cli-acc         = bf_tt-allsum.dsc-cli-acc
    bfacc_tt-allsum.vat-base-acc        = bf_tt-allsum.vat-base-acc
    bfacc_tt-allsum.vat-rubl-acc        = bf_tt-allsum.vat-rubl-acc
    bfacc_tt-allsum.vat-cli-acc         = bf_tt-allsum.vat-cli-acc
    bfacc_tt-allsum.slt-base-acc        = bf_tt-allsum.slt-base-acc
    bfacc_tt-allsum.slt-rubl-acc        = bf_tt-allsum.slt-rubl-acc
    bfacc_tt-allsum.slt-cli-acc         = bf_tt-allsum.slt-cli-acc
    bfacc_tt-allsum.excise-base-acc     = bf_tt-allsum.excise-base-acc
    bfacc_tt-allsum.excise-rubl-acc     = bf_tt-allsum.excise-rubl-acc
    bfacc_tt-allsum.excise-cli-acc      = bf_tt-allsum.excise-cli-acc
    bfacc_tt-allsum.road-tax-base-acc   = bf_tt-allsum.road-tax-base-acc
    bfacc_tt-allsum.road-tax-rubl-acc   = bf_tt-allsum.road-tax-rubl-acc
    bfacc_tt-allsum.road-tax-cli-acc    = bf_tt-allsum.road-tax-cli-acc
    bfacc_tt-allsum.transport-base-acc  = bf_tt-allsum.transport-base-acc
    bfacc_tt-allsum.transport-rubl-acc  = bf_tt-allsum.transport-rubl-acc
    bfacc_tt-allsum.transport-cli-acc   = bf_tt-allsum.transport-cli-acc
    bfacc_tt-allsum.other-base-acc      = bf_tt-allsum.other-base-acc
    bfacc_tt-allsum.other-rubl-acc      = bf_tt-allsum.other-rubl-acc
    bfacc_tt-allsum.other-cli-acc       = bf_tt-allsum.other-cli-acc
    .
  assign
    bfsacc_tt-allsum.fact-qnty           = bfs_tt-allsum.fact-qnty
    bfsacc_tt-allsum.cli-qnty            = bfs_tt-allsum.cli-qnty
    bfsacc_tt-allsum.sum-dsc-base-doc    = bfs_tt-allsum.sum-dsc-base-acc
    bfsacc_tt-allsum.sum-dsc-rubl-doc    = bfs_tt-allsum.sum-dsc-rubl-acc
    bfsacc_tt-allsum.dsc-base-doc        = bfs_tt-allsum.dsc-base-acc
    bfsacc_tt-allsum.dsc-rubl-doc        = bfs_tt-allsum.dsc-rubl-acc
    bfsacc_tt-allsum.vat-base-doc        = 0
    bfsacc_tt-allsum.vat-rubl-doc        = 0
    bfsacc_tt-allsum.vat-base-buyer-doc  = bfs_tt-allsum.vat-base-acc
    bfsacc_tt-allsum.vat-rubl-buyer-doc  = bfs_tt-allsum.vat-rubl-acc
    bfsacc_tt-allsum.slt-base-doc        = bfs_tt-allsum.slt-base-acc
    bfsacc_tt-allsum.slt-rubl-doc        = bfs_tt-allsum.slt-rubl-acc
    bfsacc_tt-allsum.road-tax-base-doc   = bfs_tt-allsum.road-tax-base-acc
    bfsacc_tt-allsum.road-tax-rubl-doc   = bfs_tt-allsum.road-tax-rubl-acc
    bfsacc_tt-allsum.excise-base-doc     = bfs_tt-allsum.excise-base-acc
    bfsacc_tt-allsum.excise-rubl-doc     = bfs_tt-allsum.excise-rubl-acc
    bfsacc_tt-allsum.sum-dsc-base-cur    = bfs_tt-allsum.sum-dsc-base-acc
    bfsacc_tt-allsum.sum-dsc-rubl-cur    = bfs_tt-allsum.sum-dsc-rubl-acc
    bfsacc_tt-allsum.dsc-base-cur        = bfs_tt-allsum.dsc-base-acc
    bfsacc_tt-allsum.dsc-rubl-cur        = bfs_tt-allsum.dsc-rubl-acc
    bfsacc_tt-allsum.vat-base-cur        = 0
    bfsacc_tt-allsum.vat-rubl-cur        = 0
    bfsacc_tt-allsum.vat-base-buyer-cur  = bfs_tt-allsum.vat-base-acc
    bfsacc_tt-allsum.vat-rubl-buyer-cur  = bfs_tt-allsum.vat-rubl-acc
    bfsacc_tt-allsum.slt-base-cur        = bfs_tt-allsum.slt-base-acc
    bfsacc_tt-allsum.slt-rubl-cur        = bfs_tt-allsum.slt-rubl-acc
    bfsacc_tt-allsum.road-tax-base-cur   = bfs_tt-allsum.road-tax-base-acc
    bfsacc_tt-allsum.road-tax-rubl-cur   = bfs_tt-allsum.road-tax-rubl-acc
    bfsacc_tt-allsum.excise-base-cur     = bfs_tt-allsum.excise-base-acc
    bfsacc_tt-allsum.excise-rubl-cur     = bfs_tt-allsum.excise-rubl-acc
    bfsacc_tt-allsum.sum-dsc-base-acc    = bfs_tt-allsum.sum-dsc-base-acc
    bfsacc_tt-allsum.sum-dsc-rubl-acc    = bfs_tt-allsum.sum-dsc-rubl-acc
    bfsacc_tt-allsum.sum-dsc-cli-acc     = bfs_tt-allsum.sum-dsc-cli-acc
    bfsacc_tt-allsum.dsc-base-acc        = bfs_tt-allsum.dsc-base-acc
    bfsacc_tt-allsum.dsc-rubl-acc        = bfs_tt-allsum.dsc-rubl-acc
    bfsacc_tt-allsum.dsc-cli-acc         = bfs_tt-allsum.dsc-cli-acc
    bfsacc_tt-allsum.vat-base-acc        = bfs_tt-allsum.vat-base-acc
    bfsacc_tt-allsum.vat-rubl-acc        = bfs_tt-allsum.vat-rubl-acc
    bfsacc_tt-allsum.vat-cli-acc         = bfs_tt-allsum.vat-cli-acc
    bfsacc_tt-allsum.slt-base-acc        = bfs_tt-allsum.slt-base-acc
    bfsacc_tt-allsum.slt-rubl-acc        = bfs_tt-allsum.slt-rubl-acc
    bfsacc_tt-allsum.slt-cli-acc         = bfs_tt-allsum.slt-cli-acc
    bfsacc_tt-allsum.excise-base-acc     = bfs_tt-allsum.excise-base-acc
    bfsacc_tt-allsum.excise-rubl-acc     = bfs_tt-allsum.excise-rubl-acc
    bfsacc_tt-allsum.excise-cli-acc      = bfs_tt-allsum.excise-cli-acc
    bfsacc_tt-allsum.road-tax-base-acc   = bfs_tt-allsum.road-tax-base-acc
    bfsacc_tt-allsum.road-tax-rubl-acc   = bfs_tt-allsum.road-tax-rubl-acc
    bfsacc_tt-allsum.road-tax-cli-acc    = bfs_tt-allsum.road-tax-cli-acc
    bfsacc_tt-allsum.transport-base-acc  = bfs_tt-allsum.transport-base-acc
    bfsacc_tt-allsum.transport-rubl-acc  = bfs_tt-allsum.transport-rubl-acc
    bfsacc_tt-allsum.transport-cli-acc   = bfs_tt-allsum.transport-cli-acc
    bfsacc_tt-allsum.other-base-acc      = bfs_tt-allsum.other-base-acc
    bfsacc_tt-allsum.other-rubl-acc      = bfs_tt-allsum.other-rubl-acc
    bfsacc_tt-allsum.other-cli-acc       = bfs_tt-allsum.other-cli-acc
    .
end.
otherwise do:
  return error substitute ("Неизвестный тип приобретения &1 по партии с кодом &2 по документу &3, порожденную документом &4 по товару &5 &6 &7.",
                           cl_tt-clcparts.purch-code,
                           cl_tt-clcparts.part-code,
                           cl_tt-clcparts.out-code,
                           cl_tt-clcparts.in-code,
                           cl_tt-clcparts.artic,
                           cl_tt-clcparts.prod-type,
                           cl_tt-clcparts.prod-code).
end.
end case.
end.
end procedure.
procedure clcprtsl_calc-line :
define input  parameter parrec-line as recid no-undo.
define variable v-tax-date         as   date                     no-undo.
define variable v-vat-pc           like ub.doc-line.vat-pc       no-undo.
define variable varr-b             as   character                no-undo.
define variable varr-btype         as   character                no-undo.
define variable varcur-base        like ub.gds-dtl.price-base    no-undo.
define variable varcur-road-tax    like ub.doc-line.road-tax     no-undo.
define variable varcur-excise      like ub.doc-line.excise       no-undo.
define variable varcur-vat-pc      like ub.doc-line.vat-pc       no-undo.
define variable varcur-cons-vat-pc like ub.doc-line.cons-vat-pc  no-undo.
define variable varcur-slt-pc      like ub.doc-line.slt-pc       no-undo.
define variable varcur-fact-qnty   like ub.gds-dtl.fact-qnty     no-undo.
define variable varb-code          like ub.bar-code.b-code       no-undo.
define variable vardoc-num         like ub.price-doc.doc-num     no-undo.
define variable varprice-sale      like ub.price-list.price-sale no-undo.
define variable varroad-tax        like ub.price-list.road-tax   no-undo.
define variable varexcise          like ub.price-list.excise     no-undo.
define variable varlastcur-base        like ub.gds-dtl.price-base no-undo.
define variable varlastcur-road-tax    like ub.gds-dtl.price-base no-undo.
define variable varlastcur-excise      like ub.gds-dtl.price-base     no-undo.
define variable v-b-pcode          like ub.bar-code.b-code     no-undo.
define variable v-varsum           as decimal                  no-undo.
define variable varprice-salef as decimal   no-undo .
define buffer bf_trn-doc             for ub.trn-doc.
define buffer bf_doc-line            for ub.doc-line.
define buffer bf_gds-dtl             for ub.gds-dtl.
define buffer bf_goods               for ub.goods.
define buffer bf_parts               for ub.parts.
define buffer bf_sysconf             for ub.sysconf.
define buffer bf_tt-allsum-line      for tt-allsum-line.
define buffer bfs_tt-allsum-line     for tt-allsum-line.
define buffer bfo_tt-allsum-line     for tt-allsum-line.
define buffer bfos_tt-allsum-line    for tt-allsum-line.
define buffer buf_parts        for ub.parts.
v-calcbypart = no.
do on error undo, return error return-value :
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varr-b
  )  .
  find first bf_doc-line where recid (bf_doc-line) = parrec-line no-lock.
  find first bf_trn-doc where bf_trn-doc.doc-code = bf_doc-line.doc-code no-lock.
  find first bf_goods where bf_goods.artic     = bf_doc-line.artic     and
                            bf_goods.prod-type = bf_doc-line.prod-type and
                            bf_goods.prod-code = bf_doc-line.prod-code no-lock.
  if bf_trn-doc.fact-date <> ?        then do:
    assign v-tax-date = bf_trn-doc.fact-date.
  end.
  else do:
    assign v-tax-date = ?.
  end.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  bf_goods.gds-code
  ,input  '1':U
  ,input  v-tax-date
  ,input  bf_trn-doc.host-code
  ,input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,output v-vat-pc
  ) no-error .
  if error-status :error
  or v-vat-pc = ? then do:
     return error substitute ("Ошибка при поиске НДС для товара &1 &2 &3", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code).
  end.
  if bf_goods.gds-type = 'у':U or
     bf_trn-doc.status_ = 'запрос':U then do:
    for each bf_tt-allsum-line
    on error undo, return error return-value
     :
      delete bf_tt-allsum-line.
    end.
    create bf_tt-allsum-line.
    assign
     bf_tt-allsum-line.sum-type = 'основная_сумма':U.
    for each bf_gds-dtl where bf_gds-dtl.doc-code  = bf_doc-line.doc-code  and
                              bf_gds-dtl.artic     = bf_doc-line.artic     and
                              bf_gds-dtl.prod-type = bf_doc-line.prod-type and
                              bf_gds-dtl.prod-code = bf_doc-line.prod-code no-lock on error undo, return error return-value :
      assign
        bf_tt-allsum-line.fact-qnty            =  bf_tt-allsum-line.fact-qnty        + bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-base-doc     =  bf_tt-allsum-line.sum-dsc-base-doc + (bf_gds-dtl.price-base - bf_gds-dtl.discnt-base) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-rubl-doc     =  bf_tt-allsum-line.sum-dsc-rubl-doc + (bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.dsc-base-doc         =  bf_tt-allsum-line.dsc-base-doc     + bf_gds-dtl.discnt-base * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.dsc-rubl-doc         =  bf_tt-allsum-line.dsc-rubl-doc     + bf_gds-dtl.discnt-rubl * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-base-cur     =  bf_tt-allsum-line.sum-dsc-base-cur + (if varr-b = "base" then bf_gds-dtl.cur-base else bf_gds-dtl.cur-base / bf_trn-doc.exch-rate * bf_trn-doc.exch-scale) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-rubl-cur     =  bf_tt-allsum-line.sum-dsc-rubl-cur + (if varr-b = "rubl" then bf_gds-dtl.cur-base else bf_gds-dtl.cur-base * bf_trn-doc.exch-rate / bf_trn-doc.exch-scale) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-base-acc     =  bf_tt-allsum-line.sum-dsc-base-acc + bf_doc-line.price-base * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-rubl-acc     =  bf_tt-allsum-line.sum-dsc-rubl-acc + bf_doc-line.price-rubl * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-cli-acc      =  ?
        bf_tt-allsum-line.vat-base-acc         =  bf_tt-allsum-line.vat-base-acc     + bf_doc-line.price-base * v-vat-pc / (100 + v-vat-pc) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.vat-rubl-acc         =  bf_tt-allsum-line.vat-rubl-acc     + bf_doc-line.price-rubl * v-vat-pc / (100 + v-vat-pc) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.vat-cli-acc          =  ?
        .
    end.
    assign
      bf_tt-allsum-line.cli-qnty             =  ?
      bf_tt-allsum-line.slt-base-doc         =  bf_tt-allsum-line.sum-dsc-base-doc * bf_doc-line.slt-pc / (100 + bf_doc-line.slt-pc)
      bf_tt-allsum-line.slt-rubl-doc         =  bf_tt-allsum-line.sum-dsc-rubl-doc * bf_doc-line.slt-pc / (100 + bf_doc-line.slt-pc)
      bf_tt-allsum-line.vat-base-buyer-doc   =  (bf_tt-allsum-line.sum-dsc-base-doc - bf_tt-allsum-line.slt-base-doc) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
      bf_tt-allsum-line.vat-rubl-buyer-doc   =  (bf_tt-allsum-line.sum-dsc-rubl-doc - bf_tt-allsum-line.slt-rubl-doc) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
      bf_tt-allsum-line.road-tax-base-doc    =  0
      bf_tt-allsum-line.road-tax-rubl-doc    =  0
      bf_tt-allsum-line.excise-base-doc      =  0
      bf_tt-allsum-line.excise-rubl-doc      =  0
      bf_tt-allsum-line.vat-base-doc         =  bf_tt-allsum-line.vat-base-buyer-doc
      bf_tt-allsum-line.vat-rubl-doc         =  bf_tt-allsum-line.vat-rubl-buyer-doc
      bf_tt-allsum-line.dsc-base-cur         =  0
      bf_tt-allsum-line.dsc-rubl-cur         =  0
      bf_tt-allsum-line.slt-base-cur         =  bf_tt-allsum-line.sum-dsc-base-cur * bf_doc-line.slt-pc / (100 + bf_doc-line.slt-pc)
      bf_tt-allsum-line.slt-rubl-cur         =  bf_tt-allsum-line.sum-dsc-rubl-cur * bf_doc-line.slt-pc / (100 + bf_doc-line.slt-pc)
      bf_tt-allsum-line.vat-base-buyer-cur   =  (bf_tt-allsum-line.sum-dsc-base-cur - bf_tt-allsum-line.slt-base-cur) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
      bf_tt-allsum-line.vat-rubl-buyer-cur   =  (bf_tt-allsum-line.sum-dsc-rubl-cur - bf_tt-allsum-line.slt-rubl-cur) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
      bf_tt-allsum-line.road-tax-base-cur    =  0
      bf_tt-allsum-line.road-tax-rubl-cur    =  0
      bf_tt-allsum-line.excise-base-cur      =  0
      bf_tt-allsum-line.excise-rubl-cur      =  0
      bf_tt-allsum-line.vat-base-cur         =  bf_tt-allsum-line.vat-base-buyer-cur
      bf_tt-allsum-line.vat-rubl-cur         =  bf_tt-allsum-line.vat-rubl-buyer-cur
      bf_tt-allsum-line.dsc-base-acc         =  0
      bf_tt-allsum-line.dsc-rubl-acc         =  0
      bf_tt-allsum-line.dsc-cli-acc          =  0
      bf_tt-allsum-line.slt-base-acc         =  0
      bf_tt-allsum-line.slt-rubl-acc         =  0
      bf_tt-allsum-line.slt-cli-acc          =  0
      bf_tt-allsum-line.road-tax-base-acc    =  0
      bf_tt-allsum-line.road-tax-rubl-acc    =  0
      bf_tt-allsum-line.road-tax-cli-acc     =  0
      bf_tt-allsum-line.excise-base-acc      =  0
      bf_tt-allsum-line.excise-rubl-acc      =  0
      bf_tt-allsum-line.excise-cli-acc       =  0
      bf_tt-allsum-line.transport-base-acc   =  0
      bf_tt-allsum-line.transport-rubl-acc   =  0
      bf_tt-allsum-line.transport-cli-acc    =  0
      bf_tt-allsum-line.other-base-acc       =  0
      bf_tt-allsum-line.other-rubl-acc       =  0
      bf_tt-allsum-line.other-cli-acc        =  0
      .
    create bfs_tt-allsum-line.
    assign
    bfs_tt-allsum-line.sum-type = 'основная_сумма_со_знаком':U.
    if bf_trn-doc.doc-type = 'инв':U or
       bf_trn-doc.doc-type = 'при':U    or
       bf_trn-doc.doc-type = 'возврат':U    then do:
       buffer-copy bf_tt-allsum-line except bf_tt-allsum-line.sum-type to bfs_tt-allsum-line.
    end.
    else do:
      assign
        bfs_tt-allsum-line.fact-qnty           =  - bf_tt-allsum-line.fact-qnty
        bfs_tt-allsum-line.cli-qnty            =  - bf_tt-allsum-line.cli-qnty
        bfs_tt-allsum-line.sum-dsc-base-doc    =  - bf_tt-allsum-line.sum-dsc-base-doc
        bfs_tt-allsum-line.sum-dsc-rubl-doc    =  - bf_tt-allsum-line.sum-dsc-rubl-doc
        bfs_tt-allsum-line.dsc-base-doc        =  - bf_tt-allsum-line.dsc-base-doc
        bfs_tt-allsum-line.dsc-rubl-doc        =  - bf_tt-allsum-line.dsc-rubl-doc
        bfs_tt-allsum-line.vat-base-doc        =  - bf_tt-allsum-line.vat-base-doc
        bfs_tt-allsum-line.vat-rubl-doc        =  - bf_tt-allsum-line.vat-rubl-doc
        bfs_tt-allsum-line.vat-base-buyer-doc  =  - bf_tt-allsum-line.vat-base-buyer-doc
        bfs_tt-allsum-line.vat-rubl-buyer-doc  =  - bf_tt-allsum-line.vat-rubl-buyer-doc
        bfs_tt-allsum-line.slt-base-doc        =  - bf_tt-allsum-line.slt-base-doc
        bfs_tt-allsum-line.slt-rubl-doc        =  - bf_tt-allsum-line.slt-rubl-doc
        bfs_tt-allsum-line.road-tax-base-doc   =  - bf_tt-allsum-line.road-tax-base-doc
        bfs_tt-allsum-line.road-tax-rubl-doc   =  - bf_tt-allsum-line.road-tax-rubl-doc
        bfs_tt-allsum-line.excise-base-doc     =  - bf_tt-allsum-line.excise-base-doc
        bfs_tt-allsum-line.excise-rubl-doc     =  - bf_tt-allsum-line.excise-rubl-doc
        bfs_tt-allsum-line.sum-dsc-base-cur    =  - bf_tt-allsum-line.sum-dsc-base-cur
        bfs_tt-allsum-line.sum-dsc-rubl-cur    =  - bf_tt-allsum-line.sum-dsc-rubl-cur
        bfs_tt-allsum-line.dsc-base-cur        =  - bf_tt-allsum-line.dsc-base-cur
        bfs_tt-allsum-line.dsc-rubl-cur        =  - bf_tt-allsum-line.dsc-rubl-cur
        bfs_tt-allsum-line.vat-base-cur        =  - bf_tt-allsum-line.vat-base-cur
        bfs_tt-allsum-line.vat-rubl-cur        =  - bf_tt-allsum-line.vat-rubl-cur
        bfs_tt-allsum-line.vat-base-buyer-cur  =  - bf_tt-allsum-line.vat-base-buyer-cur
        bfs_tt-allsum-line.vat-rubl-buyer-cur  =  - bf_tt-allsum-line.vat-rubl-buyer-cur
        bfs_tt-allsum-line.slt-base-cur        =  - bf_tt-allsum-line.slt-base-cur
        bfs_tt-allsum-line.slt-rubl-cur        =  - bf_tt-allsum-line.slt-rubl-cur
        bfs_tt-allsum-line.road-tax-base-cur   =  - bf_tt-allsum-line.road-tax-base-cur
        bfs_tt-allsum-line.road-tax-rubl-cur   =  - bf_tt-allsum-line.road-tax-rubl-cur
        bfs_tt-allsum-line.excise-base-cur     =  - bf_tt-allsum-line.excise-base-cur
        bfs_tt-allsum-line.excise-rubl-cur     =  - bf_tt-allsum-line.excise-rubl-cur
        bfs_tt-allsum-line.sum-dsc-base-acc    =  - bf_tt-allsum-line.sum-dsc-base-acc
        bfs_tt-allsum-line.sum-dsc-rubl-acc    =  - bf_tt-allsum-line.sum-dsc-rubl-acc
        bfs_tt-allsum-line.sum-dsc-cli-acc     =  - bf_tt-allsum-line.sum-dsc-cli-acc
        bfs_tt-allsum-line.dsc-base-acc        =  - bf_tt-allsum-line.dsc-base-acc
        bfs_tt-allsum-line.dsc-rubl-acc        =  - bf_tt-allsum-line.dsc-rubl-acc
        bfs_tt-allsum-line.dsc-cli-acc         =  - bf_tt-allsum-line.dsc-cli-acc
        bfs_tt-allsum-line.vat-base-acc        =  - bf_tt-allsum-line.vat-base-acc
        bfs_tt-allsum-line.vat-rubl-acc        =  - bf_tt-allsum-line.vat-rubl-acc
        bfs_tt-allsum-line.vat-cli-acc         =  - bf_tt-allsum-line.vat-cli-acc
        bfs_tt-allsum-line.slt-base-acc        =  - bf_tt-allsum-line.slt-base-acc
        bfs_tt-allsum-line.slt-rubl-acc        =  - bf_tt-allsum-line.slt-rubl-acc
        bfs_tt-allsum-line.slt-cli-acc         =  - bf_tt-allsum-line.slt-cli-acc
        bfs_tt-allsum-line.road-tax-base-acc   =  - bf_tt-allsum-line.road-tax-base-acc
        bfs_tt-allsum-line.road-tax-rubl-acc   =  - bf_tt-allsum-line.road-tax-rubl-acc
        bfs_tt-allsum-line.road-tax-cli-acc    =  - bf_tt-allsum-line.road-tax-cli-acc
        bfs_tt-allsum-line.excise-base-acc     =  - bf_tt-allsum-line.excise-base-acc
        bfs_tt-allsum-line.excise-rubl-acc     =  - bf_tt-allsum-line.excise-rubl-acc
        bfs_tt-allsum-line.excise-cli-acc      =  - bf_tt-allsum-line.excise-cli-acc
        bfs_tt-allsum-line.transport-base-acc  =  - bf_tt-allsum-line.transport-base-acc
        bfs_tt-allsum-line.transport-rubl-acc  =  - bf_tt-allsum-line.transport-rubl-acc
        bfs_tt-allsum-line.transport-cli-acc   =  - bf_tt-allsum-line.transport-cli-acc
        bfs_tt-allsum-line.other-base-acc      =  - bf_tt-allsum-line.other-base-acc
        bfs_tt-allsum-line.other-rubl-acc      =  - bf_tt-allsum-line.other-rubl-acc
        bfs_tt-allsum-line.other-cli-acc       =  - bf_tt-allsum-line.other-cli-acc
        .
    end.
    create bfo_tt-allsum-line.
    assign
      bfo_tt-allsum-line.sum-type = 'сумма_по_услуге':U.
    buffer-copy bf_tt-allsum-line except bf_tt-allsum-line.sum-type to bfo_tt-allsum-line.
    create bfos_tt-allsum-line.
    assign
      bfos_tt-allsum-line.sum-type = 'сумма_по_услуге_со_знаком':U.
    buffer-copy bfs_tt-allsum-line except bfs_tt-allsum-line.sum-type to bfos_tt-allsum-line.
  end.
  else do:
    assign
      varlastcur-base      = 0
      varlastcur-road-tax  = 0
      varlastcur-excise    = 0
      varcur-base          = 0
      varcur-road-tax      = 0
      varcur-excise        = 0
      varcur-vat-pc        = 0
      varcur-slt-pc        = 0
      varcur-fact-qnty     = 0
    .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  bf_goods.gds-code
  ,input  ?
  ,output varb-code
  )  .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcprcex in g#library
  (input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,input  varb-code
  ,input  0
  ,input  bf_trn-doc.fact-order
  ,output vardoc-num
  ,output varprice-sale
  ,output varroad-tax
  ,output varexcise
  ,output varcur-vat-pc
  ,output varcur-slt-pc
  )  .
    if varprice-sale = ?
    then do:
      assign
        varcur-vat-pc = 0
        varcur-slt-pc = 0
      .
    end.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  bf_goods.gds-code
  ,input  '1':U
  ,input  bf_trn-doc.fact-date
  ,input  bf_trn-doc.host-code
  ,input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,output varcur-vat-pc
  ) no-error .
    if varcur-vat-pc = ?
    then do:
      return error substitute ("Ошибка при поиске НДС для товара &1 &2 &3 документ &4", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code, bf_trn-doc.doc-code).
    end.
    if varcur-slt-pc = ?
    then do:
      return error substitute ("Ошибка при поиске НДС для товара &1 &2 &3 документ &4", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code, bf_trn-doc.doc-code).
    end.
    v-calcbypart = no.
    if bf_doc-line.whole-send-news = integer('1':U)   then
    v-calcbypart = yes.
    else do:
    for each bf_gds-dtl no-lock
      where bf_gds-dtl.doc-code  = bf_doc-line.doc-code
        and bf_gds-dtl.artic     = bf_doc-line.artic
        and bf_gds-dtl.prod-type = bf_doc-line.prod-type
        and bf_gds-dtl.prod-code = bf_doc-line.prod-code
    on error undo, return error return-value
    :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  bf_goods.gds-code
  ,input  bf_gds-dtl.prt-code
  ,output varb-code
  ) no-error .
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,input  varb-code
  ,input  0
  ,input  bf_trn-doc.fact-order
  ,output vardoc-num
  ,output varprice-sale
  ,output varroad-tax
  ,output varexcise
  )  .
          if varprice-sale = ?
          then do:
            assign
              varprice-sale = 0
              varroad-tax   = 0
              varexcise     = 0
            .
          end.
          assign
            varlastcur-base     = varprice-sale
            varlastcur-road-tax = varroad-tax
            varlastcur-excise   = varexcise
            varcur-base         = varcur-base      + varprice-sale * bf_gds-dtl.fact-qnty
            varcur-road-tax     = varcur-road-tax  + varroad-tax   * bf_gds-dtl.fact-qnty
            varcur-excise       = varcur-excise    + varexcise     * bf_gds-dtl.fact-qnty
            varcur-fact-qnty    = varcur-fact-qnty + bf_gds-dtl.fact-qnty
          .
      end.
    end.
    if varcur-fact-qnty = 0 then do:
      assign
        varcur-base      = varlastcur-base
        varcur-road-tax  = varlastcur-road-tax
        varcur-excise    = varlastcur-excise
      .
    end.
    else do:
      assign
        varcur-base      = varcur-base      / varcur-fact-qnty
        varcur-road-tax  = varcur-road-tax  / varcur-fact-qnty
        varcur-excise    = varcur-excise    / varcur-fact-qnty
      .
    end.
    if varcur-vat-pc = ?
    then do:
      return error substitute ("Нет текущего продажного НДС по товару &1 &2 &3", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code).
    end.
    if varcur-slt-pc = ?
    then do:
      return error substitute ("Нет текущего продажного НП по товару &1 &2 &3", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code).
    end.
    find first bf_sysconf where bf_sysconf.host-code = bf_trn-doc.host-code no-lock.
    assign
      varcur-cons-vat-pc = bf_sysconf.cons-vat-pc.
    if varcur-cons-vat-pc = ? then do:
      return error substitute ("Нет текущего продажного консигнационного НДС по фирме &1", bf_trn-doc.host-code).
    end.
    define buffer buf_tt-clcparts for tt-clcparts .
    for each buf_tt-clcparts
    on error undo, return error return-value
    :
      delete buf_tt-clcparts.
    end.
    for each bf_parts no-lock
      where bf_parts.out-code  = bf_doc-line.doc-code
        and bf_parts.obj-type  = bf_doc-line.obj-type
        and bf_parts.obj-code  = bf_doc-line.obj-code
        and bf_parts.artic     = bf_doc-line.artic
        and bf_parts.prod-type = bf_doc-line.prod-type
        and bf_parts.prod-code = bf_doc-line.prod-code
    on error undo, return error return-value
    :
      create buf_tt-clcparts .
      buffer-copy bf_parts to buf_tt-clcparts .
      if v-calcbypart = yes   then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run partbcod in g#library
  (buffer bf_parts
  ,output v-b-pcode
  ) no-error .
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  bf_parts.obj-type
  ,input  bf_parts.obj-code
  ,input  v-b-pcode
  ,input  0
  ,input  bf_trn-doc.fact-order
  ,output vardoc-num
  ,output varprice-salef
  ,output varroad-tax
  ,output varexcise
  ) no-error .
          if varprice-sale = ?
          then do:
            assign
              varprice-salef = 0
              varroad-tax   = 0
              varexcise     = 0
            .
          end.
          assign
          part-cur-base  = varprice-salef
          part-cur-road-tax  = varroad-tax
          part-cur-excise = varexcise.
      end.
    end.
    run clcprtsl_calc-ttable in this-procedure
      (input yes,
       input yes,
       input bf_doc-line.road-tax,
       input bf_doc-line.excise,
       input bf_doc-line.vat-pc,
       input bf_doc-line.cons-vat-pc,
       input bf_doc-line.slt-pc,
       input bf_trn-doc.base-rate,
       input bf_trn-doc.base-scale,
       input varr-b,
       input varcur-base,
       input varcur-road-tax,
       input varcur-excise,
       input varcur-vat-pc,
       input varcur-cons-vat-pc,
       input varcur-slt-pc
       ) no-error.
    if error-status:error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры clcprtsl_calc-ttable." skip
        return-value skip
        trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
        trim(error-status :get-message(4))
        trim(error-status :get-message(5)) skip
        view-as alert-box error.
      undo, return error .
    end.
  end.
end.
end.
procedure clcprtsl_calc-ttable :
define input parameter paris-doc           as   logical                 no-undo.
define input parameter paris-cur           as   logical                 no-undo.
define input parameter parroad-tax         like ub.doc-line.road-tax    no-undo.
define input parameter parexcise           like ub.doc-line.excise      no-undo.
define input parameter parvat-pc           like ub.doc-line.vat-pc      no-undo.
define input parameter parcons-vat-pc      like ub.doc-line.cons-vat-pc no-undo.
define input parameter parslt-pc           like ub.doc-line.slt-pc      no-undo.
define input parameter parbase-rate        like ub.trn-doc.base-rate    no-undo.
define input parameter parbase-scale       like ub.trn-doc.base-scale   no-undo.
define input parameter parr-b              as   character               no-undo.
define input parameter parcur-base         like ub.gds-dtl.cur-base     no-undo.
define input parameter parcur-road-tax     like ub.doc-line.road-tax    no-undo.
define input parameter parcur-excise       like ub.doc-line.excise      no-undo.
define input parameter parcur-vat-pc       like ub.doc-line.vat-pc      no-undo.
define input parameter parcurcons-vat-pc   like ub.doc-line.cons-vat-pc no-undo.
define input parameter parcurslt-pc        like ub.doc-line.slt-pc      no-undo.
define buffer bf_tt-allsum      for tt-allsum.
define buffer bf_tt-clcparts    for tt-clcparts.
define buffer bf_tt-allsum-line for tt-allsum-line.
define variable v-b-pcode          like ub.bar-code.b-code     no-undo.
define variable vardoc-num         like ub.price-doc.doc-num     no-undo.
define variable varprice-sale      like ub.price-list.price-sale no-undo.
define variable varroad-tax        like ub.price-list.road-tax   no-undo.
define variable varexcise          like ub.price-list.excise     no-undo.
do on error undo, return error return-value :
for each bf_tt-allsum-line
on error undo, return error return-value
 :
  delete bf_tt-allsum-line.
end.
for each bf_tt-allsum
on error undo, return error return-value
:
  delete bf_tt-allsum.
end.
for each bf_tt-clcparts
on error undo, return error return-value
:
if v-calcbypart then do:
          assign
          parcur-base =   bf_tt-clcparts.part-cur-base
          parcur-road-tax = bf_tt-clcparts.part-cur-road-tax
          parcur-excise =   bf_tt-clcparts.part-cur-excise
          .
end.
   run clcprtsl_calc-parts in this-procedure (
     input recid(bf_tt-clcparts),
     input paris-doc,
     input paris-cur,
     input parroad-tax,
     input parexcise,
     input parvat-pc,
     input parcons-vat-pc,
     input parslt-pc,
     input parbase-rate,
     input parbase-scale,
     input parr-b,
     input parcur-base,
     input parcur-road-tax,
     input parcur-excise,
     input parcur-vat-pc,
     input parcurcons-vat-pc,
     input parcurslt-pc
     ) no-error.
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      vss-include-info10 skip
      "Ошибка при обсчете партии" skip
      "Документ партии " bf_tt-clcparts.out-code skip
      "Товар" bf_tt-clcparts.artic bf_tt-clcparts.prod-type bf_tt-clcparts.prod-code skip
      return-value skip
      error-status:get-message(1) skip
      error-status:get-message(2) skip
      error-status:get-message(3) skip
      view-as alert-box error .
    undo, return error .
  end.
  for each bf_tt-allsum on error undo, return error return-value :
    find first bf_tt-allsum-line where bf_tt-allsum-line.sum-type = bf_tt-allsum.sum-type no-error.
    if not available bf_tt-allsum-line then do:
      create bf_tt-allsum-line.
      assign
        bf_tt-allsum-line.sum-type = bf_tt-allsum.sum-type.
    end.
    assign
      bf_tt-allsum-line.fact-qnty              = bf_tt-allsum-line.fact-qnty            + bf_tt-allsum.fact-qnty
      bf_tt-allsum-line.cli-qnty               = bf_tt-allsum-line.cli-qnty             + bf_tt-allsum.cli-qnty
      bf_tt-allsum-line.sum-dsc-base-doc       = bf_tt-allsum-line.sum-dsc-base-doc     + bf_tt-allsum.sum-dsc-base-doc
      bf_tt-allsum-line.sum-dsc-rubl-doc       = bf_tt-allsum-line.sum-dsc-rubl-doc     + bf_tt-allsum.sum-dsc-rubl-doc
      bf_tt-allsum-line.dsc-base-doc           = bf_tt-allsum-line.dsc-base-doc         + bf_tt-allsum.dsc-base-doc
      bf_tt-allsum-line.dsc-rubl-doc           = bf_tt-allsum-line.dsc-rubl-doc         + bf_tt-allsum.dsc-rubl-doc
      bf_tt-allsum-line.vat-base-doc           = bf_tt-allsum-line.vat-base-doc         + bf_tt-allsum.vat-base-doc
      bf_tt-allsum-line.vat-rubl-doc           = bf_tt-allsum-line.vat-rubl-doc         + bf_tt-allsum.vat-rubl-doc
      bf_tt-allsum-line.vat-base-buyer-doc     = bf_tt-allsum-line.vat-base-buyer-doc   + bf_tt-allsum.vat-base-buyer-doc
      bf_tt-allsum-line.vat-rubl-buyer-doc     = bf_tt-allsum-line.vat-rubl-buyer-doc   + bf_tt-allsum.vat-rubl-buyer-doc
      bf_tt-allsum-line.slt-base-doc           = bf_tt-allsum-line.slt-base-doc         + bf_tt-allsum.slt-base-doc
      bf_tt-allsum-line.slt-rubl-doc           = bf_tt-allsum-line.slt-rubl-doc         + bf_tt-allsum.slt-rubl-doc
      bf_tt-allsum-line.road-tax-base-doc      = bf_tt-allsum-line.road-tax-base-doc    + bf_tt-allsum.road-tax-base-doc
      bf_tt-allsum-line.road-tax-rubl-doc      = bf_tt-allsum-line.road-tax-rubl-doc    + bf_tt-allsum.road-tax-rubl-doc
      bf_tt-allsum-line.excise-base-doc        = bf_tt-allsum-line.excise-base-doc      + bf_tt-allsum.excise-base-doc
      bf_tt-allsum-line.excise-rubl-doc        = bf_tt-allsum-line.excise-rubl-doc      + bf_tt-allsum.excise-rubl-doc
      bf_tt-allsum-line.sum-dsc-base-cur       = bf_tt-allsum-line.sum-dsc-base-cur     + bf_tt-allsum.sum-dsc-base-cur
      bf_tt-allsum-line.sum-dsc-rubl-cur       = bf_tt-allsum-line.sum-dsc-rubl-cur     + bf_tt-allsum.sum-dsc-rubl-cur
      bf_tt-allsum-line.dsc-base-cur           = bf_tt-allsum-line.dsc-base-cur         + bf_tt-allsum.dsc-base-cur
      bf_tt-allsum-line.dsc-rubl-cur           = bf_tt-allsum-line.dsc-rubl-cur         + bf_tt-allsum.dsc-rubl-cur
      bf_tt-allsum-line.vat-base-cur           = bf_tt-allsum-line.vat-base-cur         + bf_tt-allsum.vat-base-cur
      bf_tt-allsum-line.vat-rubl-cur           = bf_tt-allsum-line.vat-rubl-cur         + bf_tt-allsum.vat-rubl-cur
      bf_tt-allsum-line.vat-base-buyer-cur     = bf_tt-allsum-line.vat-base-buyer-cur   + bf_tt-allsum.vat-base-buyer-cur
      bf_tt-allsum-line.vat-rubl-buyer-cur     = bf_tt-allsum-line.vat-rubl-buyer-cur   + bf_tt-allsum.vat-rubl-buyer-cur
      bf_tt-allsum-line.slt-base-cur           = bf_tt-allsum-line.slt-base-cur         + bf_tt-allsum.slt-base-cur
      bf_tt-allsum-line.slt-rubl-cur           = bf_tt-allsum-line.slt-rubl-cur         + bf_tt-allsum.slt-rubl-cur
      bf_tt-allsum-line.road-tax-base-cur      = bf_tt-allsum-line.road-tax-base-cur    + bf_tt-allsum.road-tax-base-cur
      bf_tt-allsum-line.road-tax-rubl-cur      = bf_tt-allsum-line.road-tax-rubl-cur    + bf_tt-allsum.road-tax-rubl-cur
      bf_tt-allsum-line.excise-base-cur        = bf_tt-allsum-line.excise-base-cur      + bf_tt-allsum.excise-base-cur
      bf_tt-allsum-line.excise-rubl-cur        = bf_tt-allsum-line.excise-rubl-cur      + bf_tt-allsum.excise-rubl-cur
      bf_tt-allsum-line.sum-dsc-base-acc       = bf_tt-allsum-line.sum-dsc-base-acc     + bf_tt-allsum.sum-dsc-base-acc
      bf_tt-allsum-line.sum-dsc-rubl-acc       = bf_tt-allsum-line.sum-dsc-rubl-acc     + bf_tt-allsum.sum-dsc-rubl-acc
      bf_tt-allsum-line.sum-dsc-cli-acc        = bf_tt-allsum-line.sum-dsc-cli-acc      + bf_tt-allsum.sum-dsc-cli-acc
      bf_tt-allsum-line.dsc-base-acc           = bf_tt-allsum-line.dsc-base-acc         + bf_tt-allsum.dsc-base-acc
      bf_tt-allsum-line.dsc-rubl-acc           = bf_tt-allsum-line.dsc-rubl-acc         + bf_tt-allsum.dsc-rubl-acc
      bf_tt-allsum-line.dsc-cli-acc            = bf_tt-allsum-line.dsc-cli-acc          + bf_tt-allsum.dsc-cli-acc
      bf_tt-allsum-line.vat-base-acc           = bf_tt-allsum-line.vat-base-acc         + bf_tt-allsum.vat-base-acc
      bf_tt-allsum-line.vat-rubl-acc           = bf_tt-allsum-line.vat-rubl-acc         + bf_tt-allsum.vat-rubl-acc
      bf_tt-allsum-line.vat-cli-acc            = bf_tt-allsum-line.vat-cli-acc          + bf_tt-allsum.vat-cli-acc
      bf_tt-allsum-line.slt-base-acc           = bf_tt-allsum-line.slt-base-acc         + bf_tt-allsum.slt-base-acc
      bf_tt-allsum-line.slt-rubl-acc           = bf_tt-allsum-line.slt-rubl-acc         + bf_tt-allsum.slt-rubl-acc
      bf_tt-allsum-line.slt-cli-acc            = bf_tt-allsum-line.slt-cli-acc          + bf_tt-allsum.slt-cli-acc
      bf_tt-allsum-line.road-tax-base-acc      = bf_tt-allsum-line.road-tax-base-acc    + bf_tt-allsum.road-tax-base-acc
      bf_tt-allsum-line.road-tax-rubl-acc      = bf_tt-allsum-line.road-tax-rubl-acc    + bf_tt-allsum.road-tax-rubl-acc
      bf_tt-allsum-line.road-tax-cli-acc       = bf_tt-allsum-line.road-tax-cli-acc     + bf_tt-allsum.road-tax-cli-acc
      bf_tt-allsum-line.excise-base-acc        = bf_tt-allsum-line.excise-base-acc      + bf_tt-allsum.excise-base-acc
      bf_tt-allsum-line.excise-rubl-acc        = bf_tt-allsum-line.excise-rubl-acc      + bf_tt-allsum.excise-rubl-acc
      bf_tt-allsum-line.excise-cli-acc         = bf_tt-allsum-line.excise-cli-acc       + bf_tt-allsum.excise-cli-acc
      bf_tt-allsum-line.transport-base-acc     = bf_tt-allsum-line.transport-base-acc   + bf_tt-allsum.transport-base-acc
      bf_tt-allsum-line.transport-rubl-acc     = bf_tt-allsum-line.transport-rubl-acc   + bf_tt-allsum.transport-rubl-acc
      bf_tt-allsum-line.transport-cli-acc      = bf_tt-allsum-line.transport-cli-acc    + bf_tt-allsum.transport-cli-acc
      bf_tt-allsum-line.other-base-acc         = bf_tt-allsum-line.other-base-acc       + bf_tt-allsum.other-base-acc
      bf_tt-allsum-line.other-rubl-acc         = bf_tt-allsum-line.other-rubl-acc       + bf_tt-allsum.other-rubl-acc
      bf_tt-allsum-line.other-cli-acc          = bf_tt-allsum-line.other-cli-acc        + bf_tt-allsum.other-cli-acc
      .
  end.
end.
end.
end procedure.
define stream slog .
define variable ind                         as integer no-undo .
define variable start-time                  as integer   no-undo .
define variable current-time                as character no-undo .
define variable current-action              as character no-undo .
define variable v-ot-fact-order             like ub.ot-tot.fact-order  no-undo .
define variable v-stk-tot-fact-order        like ub.stk-tot.fact-order no-undo .
define variable v-stk-line-fact-order       like ub.stk-line.fact-order no-undo .
define variable v-shift-stk-tot-fact-order  like ub.stk-tot.fact-order no-undo .
define variable v-shift-stk-line-fact-order like ub.stk-line.fact-order no-undo .
define variable l-need-create-record        as logical no-undo .
define variable v-base-rate                 like ub.curr-accnt.exch-rate no-undo .
define variable v-base-scale                like ub.curr-accnt.exch-scale no-undo .
define variable v-shift-on                  as logical   no-undo .
define variable v-fact-order                as decimal   no-undo .
define variable v-shift-end-fact-order      as decimal   no-undo .
define variable v-day-end-fact-order        as decimal   no-undo .
define variable v-shift-cut-fact-order      as decimal   no-undo .
define variable v-day-cut-fact-order        as decimal   no-undo .
define variable ind-ext    as integer no-undo .
define variable v-cat-id   as character no-undo extent 4 .
define variable v-sum-type as character no-undo extent 4 .
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.
define temp-table temp-ot-tot no-undo like ub.ot-tot   field new-fact-qnty      like ub.ot-tot.fact-qnty            field new-sum-base       like ub.ot-tot.sum-base             field new-sum-rubl       like ub.ot-tot.sum-rubl             field new-vat-base       like ub.ot-tot.vat-base             field new-vat-rubl       like ub.ot-tot.vat-rubl             field new-slt-base       like ub.ot-tot.slt-base             field new-slt-rubl       like ub.ot-tot.slt-rubl             field new-road-tax-base  like ub.ot-tot.road-tax-base        field new-road-tax-rubl  like ub.ot-tot.road-tax-rubl        field new-excise-base    like ub.ot-tot.excise-base          field new-excise-rubl    like ub.ot-tot.excise-rubl          field new-transport-base like ub.ot-tot.transport-base       field new-transport-rubl like ub.ot-tot.transport-rubl       field new-other-base     like ub.ot-tot.other-base           field new-other-rubl     like ub.ot-tot.other-rubl         index pi is primary unique doc-code sum-type cat-id   index obj-ot             obj-type obj-code fact-order sum-type cat-id   index sum-type           sum-type cat-id .
define temp-table temp-ot-line no-undo like ub.ot-line   field new-fact-qnty      like ub.ot-line.fact-qnty            field new-sum-base       like ub.ot-line.sum-base             field new-sum-rubl       like ub.ot-line.sum-rubl             field new-vat-base       like ub.ot-line.vat-base             field new-vat-rubl       like ub.ot-line.vat-rubl             field new-slt-base       like ub.ot-line.slt-base             field new-slt-rubl       like ub.ot-line.slt-rubl             field new-road-tax-base  like ub.ot-line.road-tax-base        field new-road-tax-rubl  like ub.ot-line.road-tax-rubl        field new-excise-base    like ub.ot-line.excise-base          field new-excise-rubl    like ub.ot-line.excise-rubl          field new-transport-base like ub.ot-line.transport-base       field new-transport-rubl like ub.ot-line.transport-rubl       field new-other-base     like ub.ot-line.other-base           field new-other-rubl     like ub.ot-line.other-rubl         index pi is primary unique   doc-code artic prod-type prod-code sum-type cat-id   index art-ot             obj-type obj-code artic prod-type prod-code fact-order sum-type cat-id   index sum-type           sum-type cat-id .
define temp-table temp-stk-tot no-undo like ub.stk-tot   field new-fact-qnty      like ub.stk-tot.fact-qnty            field new-sum-base       like ub.stk-tot.sum-base             field new-sum-rubl       like ub.stk-tot.sum-rubl             field new-vat-base       like ub.stk-tot.vat-base             field new-vat-rubl       like ub.stk-tot.vat-rubl             field new-slt-base       like ub.stk-tot.slt-base             field new-slt-rubl       like ub.stk-tot.slt-rubl             field new-road-tax-base  like ub.stk-tot.road-tax-base        field new-road-tax-rubl  like ub.stk-tot.road-tax-rubl        field new-excise-base    like ub.stk-tot.excise-base          field new-excise-rubl    like ub.stk-tot.excise-rubl          field new-transport-base like ub.stk-tot.transport-base       field new-transport-rubl like ub.stk-tot.transport-rubl       field new-other-base     like ub.stk-tot.other-base           field new-other-rubl     like ub.stk-tot.other-rubl         index pi is primary unique  obj-type obj-code fact-order sum-type cat-id   index category          obj-type obj-code sum-type cat-id fact-order   index sum-type          sum-type cat-id .
define temp-table temp-stk-line no-undo like ub.stk-line   field new-fact-qnty      like ub.stk-line.fact-qnty            field new-sum-base       like ub.stk-line.sum-base             field new-sum-rubl       like ub.stk-line.sum-rubl             field new-vat-base       like ub.stk-line.vat-base             field new-vat-rubl       like ub.stk-line.vat-rubl             field new-slt-base       like ub.stk-line.slt-base             field new-slt-rubl       like ub.stk-line.slt-rubl             field new-road-tax-base  like ub.stk-line.road-tax-base        field new-road-tax-rubl  like ub.stk-line.road-tax-rubl        field new-excise-base    like ub.stk-line.excise-base          field new-excise-rubl    like ub.stk-line.excise-rubl          field new-transport-base like ub.stk-line.transport-base       field new-transport-rubl like ub.stk-line.transport-rubl       field new-other-base     like ub.stk-line.other-base           field new-other-rubl     like ub.stk-line.other-rubl         index pi is primary unique  obj-type obj-code artic prod-type prod-code fact-order sum-type cat-id   index category          obj-type obj-code artic prod-type prod-code sum-type cat-id fact-order   index sum-type          sum-type cat-id .
define temp-table temp-shift-stk-tot no-undo like ub.stk-tot   field new-fact-qnty      like ub.stk-tot.fact-qnty            field new-sum-base       like ub.stk-tot.sum-base             field new-sum-rubl       like ub.stk-tot.sum-rubl             field new-vat-base       like ub.stk-tot.vat-base             field new-vat-rubl       like ub.stk-tot.vat-rubl             field new-slt-base       like ub.stk-tot.slt-base             field new-slt-rubl       like ub.stk-tot.slt-rubl             field new-road-tax-base  like ub.stk-tot.road-tax-base        field new-road-tax-rubl  like ub.stk-tot.road-tax-rubl        field new-excise-base    like ub.stk-tot.excise-base          field new-excise-rubl    like ub.stk-tot.excise-rubl          field new-transport-base like ub.stk-tot.transport-base       field new-transport-rubl like ub.stk-tot.transport-rubl       field new-other-base     like ub.stk-tot.other-base           field new-other-rubl     like ub.stk-tot.other-rubl         index pi is primary unique  obj-type obj-code fact-order sum-type cat-id   index category          obj-type obj-code sum-type cat-id fact-order   index sum-type sum-type cat-id .
define temp-table temp-shift-stk-line no-undo like ub.stk-line   field new-fact-qnty      like ub.stk-line.fact-qnty            field new-sum-base       like ub.stk-line.sum-base             field new-sum-rubl       like ub.stk-line.sum-rubl             field new-vat-base       like ub.stk-line.vat-base             field new-vat-rubl       like ub.stk-line.vat-rubl             field new-slt-base       like ub.stk-line.slt-base             field new-slt-rubl       like ub.stk-line.slt-rubl             field new-road-tax-base  like ub.stk-line.road-tax-base        field new-road-tax-rubl  like ub.stk-line.road-tax-rubl        field new-excise-base    like ub.stk-line.excise-base          field new-excise-rubl    like ub.stk-line.excise-rubl          field new-transport-base like ub.stk-line.transport-base       field new-transport-rubl like ub.stk-line.transport-rubl       field new-other-base     like ub.stk-line.other-base           field new-other-rubl     like ub.stk-line.other-rubl         index pi is primary unique  obj-type obj-code artic prod-type prod-code fact-order sum-type cat-id   index category          obj-type obj-code artic prod-type prod-code sum-type cat-id fact-order   index sum-type          sum-type cat-id .
def var v-fact-qnty      like ub.ot-tot.fact-qnty       no-undo .     def var v-sum-base       like ub.ot-tot.sum-base        no-undo .     def var v-sum-rubl       like ub.ot-tot.sum-rubl        no-undo .     def var v-vat-base       like ub.ot-tot.vat-base        no-undo .     def var v-vat-rubl       like ub.ot-tot.vat-rubl        no-undo .     def var v-slt-base       like ub.ot-tot.slt-base        no-undo .     def var v-slt-rubl       like ub.ot-tot.slt-rubl        no-undo .     def var v-road-tax-base  like ub.ot-tot.road-tax-base   no-undo .     def var v-road-tax-rubl  like ub.ot-tot.road-tax-rubl   no-undo .     def var v-excise-base    like ub.ot-tot.excise-base     no-undo .     def var v-excise-rubl    like ub.ot-tot.excise-rubl     no-undo .     def var v-transport-base like ub.ot-tot.transport-base  no-undo .     def var v-transport-rubl like ub.ot-tot.transport-rubl  no-undo .     def var v-other-base     like ub.ot-tot.other-base      no-undo .     def var v-other-rubl     like ub.ot-tot.other-rubl      no-undo .
main-block :
do transaction
on error undo main-block, return error
:
  find first ub.trn-doc share-lock
    where ub.trn-doc.doc-code = p-doc-code
    no-error .
  if not available ub.trn-doc
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не найден документ" p-doc-code skip
      view-as alert-box error .
    undo main-block, return error .
  end.
  if ub.trn-doc.status_ <> 'факт':U
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Нельзя рассчитать складской архив по товарам для складского документа не закрытого до статуса" 'факт':U skip
      "Документ" p-doc-code skip
      view-as alert-box error .
    undo main-block, return error .
  end.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  ub.trn-doc.obj-type
  ,input  ub.trn-doc.obj-code
  ,input  'shift-on=request'
  ,output v-shift-on
  ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при запуске процедуры objat" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo main-block, return error .
  end.
  define variable v-curr-r-b as character no-undo .
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
  run factord in this-procedure
    (input  ub.trn-doc.fact-date
    ,input  ub.trn-doc.fact-time
    ,input  ub.trn-doc.fact-num
    ,input  ub.trn-doc.shift-date
    ,input  ub.trn-doc.shift-num
    ,input  v-shift-on
    ,output v-fact-order
    ,output v-shift-end-fact-order
    ,output v-day-end-fact-order
    ) no-error .
  if error-status :error
  or v-fact-order = ?
  or v-fact-order = 0
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении фактического номера складского документа" skip
      "doc-code"                ub.trn-doc.doc-code    skip
      "fact-date"               ub.trn-doc.fact-date   skip
      "fact-time"               ub.trn-doc.fact-time   skip
      "fact-num"                ub.trn-doc.fact-num    skip
      "shift-date"              ub.trn-doc.shift-date  skip
      "shift-num"               ub.trn-doc.shift-num   skip
      "v-fact-order"            v-fact-order           skip
      "v-shift-end-fact-order"  v-shift-end-fact-order skip
      "v-day-end-fact-order"    v-day-end-fact-order   skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.
  if p-cut-date = ?
  then do:
    run factord-max-fact-order in this-procedure
      (output v-shift-cut-fact-order
      ) .
    run factord-max-fact-order in this-procedure
      (output v-day-cut-fact-order
      ) .
  end.
  else do:
    if p-cut-date = ub.trn-doc.fact-date
    then do:
      assign
        v-day-end-fact-order = v-day-end-fact-order - 0.0000000001
      .
      if v-shift-on = true
      then do:
        define buffer buf_shift-obj for ub.shift-obj .
        find last buf_shift-obj
          where buf_shift-obj.obj-type    = ub.trn-doc.obj-type
            and buf_shift-obj.obj-code    = ub.trn-doc.obj-code
            and buf_shift-obj.shift-date <= p-cut-date
          use-index pi
          no-error .
        if not available buf_shift-obj
        or buf_shift-obj.status_ <> 'зкр':U
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при поиске последней смены" skip
            "Объект" ub.trn-doc.obj-type ub.trn-doc.obj-code skip
            "Дата" p-cut-date skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        if  ub.trn-doc.shift-date = buf_shift-obj.shift-date
        and ub.trn-doc.shift-num  = buf_shift-obj.shift-num
        then do:
          assign
            v-shift-end-fact-order = v-shift-end-fact-order - 0.0000000001
          .
        end.
      end.
    end.
    assign
      v-shift-cut-fact-order = v-shift-end-fact-order
      v-day-cut-fact-order   = v-day-end-fact-order
    .
  end.
  def frame inf
    ub.trn-doc.doc-code                      label "Документ" skip
    ub.trn-doc.obj-type                      label "Объект"
    ub.trn-doc.obj-code                      no-label skip
    ub.trn-doc.fact-date format "99/99/9999" label "Дата закрытия" skip
    current-action       format "x(40)"      no-label skip
    ind                  format ">>>>>>>9"   label "Обработано артикулов" skip
    ub.doc-line.artic                        label "Текущий артикул" skip
    current-time         format "x(8)"       label "Время расчета документа" skip
    with view-as dialog-box side-labels three-d
    title "Расчет складского архива по товарам"
    .
  define variable mFrameView      as logical   no-undo init yes.
  define variable mFramHandle as handle no-undo.
  mFramHandle = frame inf:handle.
  if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameArhError").
      log-manager:write-message("visible-frame-mod=" + string(mFramHandle:visible), "frameArhError").
  end.
  mFrameView = not session:batch-mode and mFramHandle:visible.
  run cur-time in this-procedure ( output v-today
                                 , output start-time
                                 ).
  if mFrameView
  then do:
     view frame inf .
     display
        ub.trn-doc.doc-code
        ub.trn-doc.obj-type
        ub.trn-doc.obj-code
        ub.trn-doc.fact-date
     with frame inf .
  end.
  run show-action in this-procedure
    (input "Обработка строк документа"
    ).
  assign
    v-ot-fact-order             = v-fact-order
    v-stk-tot-fact-order        = v-day-end-fact-order
    v-stk-line-fact-order       = v-day-end-fact-order
    v-shift-stk-tot-fact-order  = v-shift-end-fact-order
    v-shift-stk-line-fact-order = v-shift-end-fact-order
  .
  assign
    v-base-rate  = ub.trn-doc.base-rate
    v-base-scale = ub.trn-doc.base-scale
  .
  run init-temp-tables in this-procedure no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры init-temp-tables" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo main-block, return error .
  end.
  for each ub.doc-line no-lock
    where ub.doc-line.doc-code = ub.trn-doc.doc-code
  on error undo main-block, return error
  :
    run process-doc-line in this-procedure no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры process-doc-line" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo main-block, return error .
    end.
    assign
      ind  = ind + 1
    .
    if ind mod 10 = 0
    then do:
      run cur-time in this-procedure ( output v-today
                                     , output v-time
                                     ).
      assign
        current-time = string(v-time - start-time, "HH:MM:SS")
      .
      if mFrameView
      then display
        ind
        ub.doc-line.artic
        current-time
        with frame inf .
    end.
  end.
  run update-ot-tot in this-procedure no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры update-ot-tot" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo main-block, return error .
  end.
  run update-stk-table in this-procedure no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры update-stk-table" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo main-block, return error .
  end.
  run show-action in this-procedure
    (input "Сохранение складского архива по товарам в базу данных"
    ).
  run store-temp-table in this-procedure no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры store-temp-table" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo main-block, return error .
  end.
  if v-shift-on
  then do:
    run check-valid-archives in this-procedure
      no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при проверке целостности складского архива по товарам" skip
        "Дополнительная информация выведена в файл calc-arh.err" skip
        "Переоценка" ub.trn-doc.doc-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo main-block, return error .
    end.
  end.
  run show-action in this-procedure
    (input "Расчет документа закончен"
    ).
end.
procedure init-temp-tables :
  do
  on error undo, return error
  :
    define variable v-root-sum-type                  as character no-undo extent 8 .
    define variable v-line-sum-type                  as character no-undo extent 8 .
    define variable v-root-sum-type-ind-ext          as integer   no-undo .
    define variable v-prev-stk-tot-fact-order        like ub.stk-tot.fact-order     no-undo .
    define variable v-prev-stk-line-fact-order       like ub.stk-line.fact-order    no-undo .
    define variable v-prev-shift-stk-tot-fact-order  like ub.stk-tot.fact-order     no-undo .
    define variable v-prev-shift-stk-line-fact-order like ub.stk-line.fact-order    no-undo .
    define variable v-goods-vat-pc                   like ub.doc-line.vat-pc           no-undo.
    define variable v-goods-slt-pc                   like ub.doc-line.slt-pc           no-undo.
    define variable v-host-code                      like ub.sysconf.host-code         no-undo.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  ub.trn-doc.obj-type
  ,input  ub.trn-doc.obj-code
  ,output v-host-code
  )  .
    if ub.trn-doc.ext-doc-type = ""
    or ub.trn-doc.ext-doc-type = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не задан расширенный тип документа" skip
        "Документ" ub.trn-doc.doc-code skip
        "Тип документа" ub.trn-doc.ext-doc-type skip
        "doc-type" ub.trn-doc.doc-type skip
        "internal" ub.trn-doc.internal skip
        "discnt-type" ub.trn-doc.discnt-type skip
        "ret-supp" ub.trn-doc.ret-supp skip
        "pay-code" ub.trn-doc.pay-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    assign
      v-root-sum-type[1] = 'crsa':U
      v-root-sum-type[2] = 'cost':U
      v-root-sum-type[3] = 'sadt':U         + ub.trn-doc.ext-doc-type
      v-root-sum-type[4] = 'cgdt':U         + ub.trn-doc.ext-doc-type
      v-root-sum-type[5] = 'csdt':U         + ub.trn-doc.ext-doc-type
      v-root-sum-type[6] = 'adsr':U + ub.trn-doc.ext-doc-type
      v-root-sum-type[7] = 'gdsr':U + ub.trn-doc.ext-doc-type
      v-root-sum-type[8] = 'sdsr':U + ub.trn-doc.ext-doc-type
    .
    run show-action in this-procedure
      (input "Считывается оборот по документу"
      ).
    find first ub.ot-tot no-lock
      where ub.ot-tot.doc-code = ub.trn-doc.doc-code
        and ub.ot-tot.sum-type = 'crsa':U
        and ub.ot-tot.cat-id   = '##,##':U
      no-error .
    if available ub.ot-tot
    then do:
      do v-root-sum-type-ind-ext = 1 to extent(v-root-sum-type)
      :
        for each ub.ot-tot no-lock
          where ub.ot-tot.doc-code = ub.trn-doc.doc-code
            and ub.ot-tot.sum-type begins v-root-sum-type[v-root-sum-type-ind-ext]
        on error undo, return error
        :
          create temp-ot-tot .
                              assign
            temp-ot-tot.doc-code     = ub.ot-tot.doc-code       temp-ot-tot.sum-type     = ub.ot-tot.sum-type       temp-ot-tot.cat-id       = ub.ot-tot.cat-id         temp-ot-tot.ext-doc-type = ub.ot-tot.ext-doc-type   temp-ot-tot.obj-type     = ub.ot-tot.obj-type       temp-ot-tot.obj-code     = ub.ot-tot.obj-code       temp-ot-tot.fact-order   = ub.ot-tot.fact-order
          .
          assign
                                                                                    temp-ot-tot.fact-qnty      = ub.ot-tot.fact-qnty            temp-ot-tot.sum-base       = ub.ot-tot.sum-base             temp-ot-tot.sum-rubl       = ub.ot-tot.sum-rubl             temp-ot-tot.vat-base       = ub.ot-tot.vat-base             temp-ot-tot.vat-rubl       = ub.ot-tot.vat-rubl             temp-ot-tot.slt-base       = ub.ot-tot.slt-base             temp-ot-tot.slt-rubl       = ub.ot-tot.slt-rubl             temp-ot-tot.road-tax-base  = ub.ot-tot.road-tax-base        temp-ot-tot.road-tax-rubl  = ub.ot-tot.road-tax-rubl        temp-ot-tot.excise-base    = ub.ot-tot.excise-base          temp-ot-tot.excise-rubl    = ub.ot-tot.excise-rubl          temp-ot-tot.transport-base = ub.ot-tot.transport-base       temp-ot-tot.transport-rubl = ub.ot-tot.transport-rubl       temp-ot-tot.other-base     = ub.ot-tot.other-base           temp-ot-tot.other-rubl     = ub.ot-tot.other-rubl
          .
        end.
      end.
    end.
    else do:
      create temp-ot-tot .
      assign
        temp-ot-tot.doc-code     = ub.trn-doc.doc-code
        temp-ot-tot.sum-type     = 'crsa':U
        temp-ot-tot.cat-id       = '##,##':U
        temp-ot-tot.ext-doc-type = ub.trn-doc.ext-doc-type
        temp-ot-tot.obj-type     = ub.trn-doc.obj-type
        temp-ot-tot.obj-code     = ub.trn-doc.obj-code
        temp-ot-tot.fact-order   = v-ot-fact-order
      .
    end.
    run show-action in this-procedure
      (input "Считывается оборот по строкам документа"
      ).
    for each ub.doc-line
      where ub.doc-line.doc-code = ub.trn-doc.doc-code no-lock
    on error undo, return error
    :
      define buffer buf_goods for ub.goods .
      find first buf_goods no-lock
        where buf_goods.artic     = ub.doc-line.artic
          and buf_goods.prod-type = ub.doc-line.prod-type
          and buf_goods.prod-code = ub.doc-line.prod-code
        no-error .
      if not available buf_goods
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не найден товар" skip
          "Документ" ub.doc-line.doc-code skip
          "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
          view-as alert-box error .
        undo, return error .
      end.
      define variable v-doc-line-ot-sum-type as character no-undo extent 3 .
      define variable v-doc-line-ot-sum-type-ind-ext as integer   no-undo .
      define variable v-sum-type as character no-undo .
      if buf_goods.gds-type = 'т':U
      then do:
        assign
          v-sum-type = 'crsa':U
          v-doc-line-ot-sum-type[1] = 'sale':U
          v-doc-line-ot-sum-type[2] = 'crsa':U
          v-doc-line-ot-sum-type[3] = 'cost':U
        .
      end.
      else do:
        assign
          v-sum-type = 'cgsr':U
          v-doc-line-ot-sum-type[1] = 'sasr':U
          v-doc-line-ot-sum-type[2] = 'cgsr':U
          v-doc-line-ot-sum-type[3] = 'cssr':U
        .
      end.
      find first ub.ot-line no-lock
        where ub.ot-line.doc-code  = ub.doc-line.doc-code
          and ub.ot-line.artic     = ub.doc-line.artic
          and ub.ot-line.prod-type = ub.doc-line.prod-type
          and ub.ot-line.prod-code = ub.doc-line.prod-code
          and ub.ot-line.sum-type  = v-sum-type
        no-error .
      if available ub.ot-line
      then do:
        do v-doc-line-ot-sum-type-ind-ext = 1 to extent(v-doc-line-ot-sum-type)
        :
          for each ub.ot-line no-lock
            where ub.ot-line.doc-code  = ub.doc-line.doc-code
              and ub.ot-line.artic     = ub.doc-line.artic
              and ub.ot-line.prod-type = ub.doc-line.prod-type
              and ub.ot-line.prod-code = ub.doc-line.prod-code
              and ub.ot-line.sum-type  begins v-doc-line-ot-sum-type[v-doc-line-ot-sum-type-ind-ext]
          on error undo, return error
          :
            create temp-ot-line .
                                    assign
              temp-ot-line.doc-code     = ub.ot-line.doc-code       temp-ot-line.artic        = ub.ot-line.artic          temp-ot-line.prod-type    = ub.ot-line.prod-type      temp-ot-line.prod-code    = ub.ot-line.prod-code      temp-ot-line.sum-type     = ub.ot-line.sum-type       temp-ot-line.cat-id       = ub.ot-line.cat-id         temp-ot-line.ext-doc-type = ub.ot-line.ext-doc-type   temp-ot-line.obj-type     = ub.ot-line.obj-type       temp-ot-line.obj-code     = ub.ot-line.obj-code       temp-ot-line.fact-order   = ub.ot-line.fact-order
            .
            assign
                                                                                                  temp-ot-line.fact-qnty      = ub.ot-line.fact-qnty            temp-ot-line.sum-base       = ub.ot-line.sum-base             temp-ot-line.sum-rubl       = ub.ot-line.sum-rubl             temp-ot-line.vat-base       = ub.ot-line.vat-base             temp-ot-line.vat-rubl       = ub.ot-line.vat-rubl             temp-ot-line.slt-base       = ub.ot-line.slt-base             temp-ot-line.slt-rubl       = ub.ot-line.slt-rubl             temp-ot-line.road-tax-base  = ub.ot-line.road-tax-base        temp-ot-line.road-tax-rubl  = ub.ot-line.road-tax-rubl        temp-ot-line.excise-base    = ub.ot-line.excise-base          temp-ot-line.excise-rubl    = ub.ot-line.excise-rubl          temp-ot-line.transport-base = ub.ot-line.transport-base       temp-ot-line.transport-rubl = ub.ot-line.transport-rubl       temp-ot-line.other-base     = ub.ot-line.other-base           temp-ot-line.other-rubl     = ub.ot-line.other-rubl
            .
          end.
        end.
      end.
      else do:
        create temp-ot-line .
        assign
          temp-ot-line.doc-code  = ub.doc-line.doc-code
          temp-ot-line.artic     = ub.doc-line.artic
          temp-ot-line.prod-type = ub.doc-line.prod-type
          temp-ot-line.prod-code = ub.doc-line.prod-code
          temp-ot-line.sum-type  = v-sum-type
        .
        define variable v-gds-code   as integer   no-undo .
        define variable v-b-code     as integer   no-undo .
        define variable v-doc-num    as character no-undo .
        define variable v-price-sale as decimal   no-undo .
        define variable v-road-tax   as decimal   no-undo .
        define variable v-excise     as decimal   no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output v-b-code
  ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при поиске первичного бар-кода товара" skip
            "Документ" ub.doc-line.doc-code skip
            "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcprcex in g#library
  (input  ub.trn-doc.obj-type
  ,input  ub.trn-doc.obj-code
  ,input  v-b-code
  ,input  0
  ,input  ub.trn-doc.fact-order
  ,output v-doc-num
  ,output v-price-sale
  ,output v-road-tax
  ,output v-excise
  ,output v-goods-vat-pc
  ,output v-goods-slt-pc
  ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при поиске цены товара" skip
            "Документ" ub.doc-line.doc-code skip
            "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
            "Бар-код" v-b-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        if v-doc-num = ?
        then do:
          assign
            v-goods-vat-pc = 0
            v-goods-slt-pc = 0
          .
        end.
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf_goods.gds-code
  ,input  '1':U
  ,input  ub.trn-doc.fact-date
  ,input  ub.trn-doc.host-code
  ,input  ub.trn-doc.obj-type
  ,input  ub.trn-doc.obj-code
  ,output v-goods-vat-pc
  ) no-error .
        if v-goods-vat-pc = ?
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при поиске НДС для товара на дату" skip
            "Документ" ub.doc-line.doc-code skip
            "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
            "Переоценка" v-doc-num skip
            "Дата" ub.trn-doc.fact-date skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        if v-goods-slt-pc = ?
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при поиске НП для товара на дату" skip
            "Документ" ub.doc-line.doc-code skip
            "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
            "Переоценка" v-doc-num skip
            "Дата" ub.trn-doc.fact-date skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        assign
          temp-ot-line.cat-id    = trim(string(v-goods-vat-pc, ">99")) + ","
                                 + trim(string(v-goods-slt-pc, ">99"))
        .
        if temp-ot-line.cat-id = ?
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при расчете складского архива по товарам" skip
            "Не определены налоги товара" skip
            "Документ" ub.doc-line.doc-code skip
            "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
            "НДС" v-goods-vat-pc skip
            "НсП" v-goods-slt-pc skip
            view-as alert-box error .
          undo, return error .
        end.
        assign
          temp-ot-line.ext-doc-type = ub.trn-doc.ext-doc-type
          temp-ot-line.obj-type     = ub.trn-doc.obj-type
          temp-ot-line.obj-code     = ub.trn-doc.obj-code
          temp-ot-line.fact-order   = v-ot-fact-order
        .
      end.
    end.
    run show-action in this-procedure
      (input "Считывается остаток по объекту"
      ).
    do v-root-sum-type-ind-ext = 1 to extent(v-root-sum-type)
    :
      find last ub.stk-tot no-lock
        where ub.stk-tot.obj-type   = ub.trn-doc.obj-type
          and ub.stk-tot.obj-code   = ub.trn-doc.obj-code
          and ub.stk-tot.sum-type   = v-root-sum-type[v-root-sum-type-ind-ext]
          and ub.stk-tot.cat-id     = '##,##':U
          and ub.stk-tot.fact-order <= v-stk-tot-fact-order
          and ub.stk-tot.shift-date = ?
        use-index category
        no-error .
      if available ub.stk-tot
      then do:
        assign
          v-prev-stk-tot-fact-order = ub.stk-tot.fact-order
        .
        for each ub.stk-tot no-lock
          where ub.stk-tot.obj-type   = ub.trn-doc.obj-type
            and ub.stk-tot.obj-code   = ub.trn-doc.obj-code
            and ub.stk-tot.fact-order = v-prev-stk-tot-fact-order
            and ub.stk-tot.sum-type   begins v-root-sum-type[v-root-sum-type-ind-ext]
        on error undo, return error
        :
          create temp-stk-tot .
                              assign
            temp-stk-tot.obj-type     = ub.stk-tot.obj-type     temp-stk-tot.obj-code     = ub.stk-tot.obj-code     temp-stk-tot.fact-order   = ub.stk-tot.fact-order   temp-stk-tot.sum-type     = ub.stk-tot.sum-type     temp-stk-tot.cat-id       = ub.stk-tot.cat-id       temp-stk-tot.fact-date    = ub.stk-tot.fact-date    temp-stk-tot.shift-num    = ub.stk-tot.shift-num    temp-stk-tot.shift-date   = ub.stk-tot.shift-date
          .
          if v-stk-tot-fact-order = v-prev-stk-tot-fact-order
          then do:
            assign
                                                                                                  temp-stk-tot.fact-qnty      = ub.stk-tot.fact-qnty            temp-stk-tot.sum-base       = ub.stk-tot.sum-base             temp-stk-tot.sum-rubl       = ub.stk-tot.sum-rubl             temp-stk-tot.vat-base       = ub.stk-tot.vat-base             temp-stk-tot.vat-rubl       = ub.stk-tot.vat-rubl             temp-stk-tot.slt-base       = ub.stk-tot.slt-base             temp-stk-tot.slt-rubl       = ub.stk-tot.slt-rubl             temp-stk-tot.road-tax-base  = ub.stk-tot.road-tax-base        temp-stk-tot.road-tax-rubl  = ub.stk-tot.road-tax-rubl        temp-stk-tot.excise-base    = ub.stk-tot.excise-base          temp-stk-tot.excise-rubl    = ub.stk-tot.excise-rubl          temp-stk-tot.transport-base = ub.stk-tot.transport-base       temp-stk-tot.transport-rubl = ub.stk-tot.transport-rubl       temp-stk-tot.other-base     = ub.stk-tot.other-base           temp-stk-tot.other-rubl     = ub.stk-tot.other-rubl
            .
          end.
          assign
            temp-stk-tot.fact-order = v-stk-tot-fact-order
            temp-stk-tot.fact-date  = ub.trn-doc.fact-date
            temp-stk-tot.shift-num  = 0
            temp-stk-tot.shift-date = ?
                                                                                    temp-stk-tot.new-fact-qnty      = ub.stk-tot.fact-qnty            temp-stk-tot.new-sum-base       = ub.stk-tot.sum-base             temp-stk-tot.new-sum-rubl       = ub.stk-tot.sum-rubl             temp-stk-tot.new-vat-base       = ub.stk-tot.vat-base             temp-stk-tot.new-vat-rubl       = ub.stk-tot.vat-rubl             temp-stk-tot.new-slt-base       = ub.stk-tot.slt-base             temp-stk-tot.new-slt-rubl       = ub.stk-tot.slt-rubl             temp-stk-tot.new-road-tax-base  = ub.stk-tot.road-tax-base        temp-stk-tot.new-road-tax-rubl  = ub.stk-tot.road-tax-rubl        temp-stk-tot.new-excise-base    = ub.stk-tot.excise-base          temp-stk-tot.new-excise-rubl    = ub.stk-tot.excise-rubl          temp-stk-tot.new-transport-base = ub.stk-tot.transport-base       temp-stk-tot.new-transport-rubl = ub.stk-tot.transport-rubl       temp-stk-tot.new-other-base     = ub.stk-tot.other-base           temp-stk-tot.new-other-rubl     = ub.stk-tot.other-rubl
          .
        end.
      end.
      else do:
        create temp-stk-tot.
        assign
          temp-stk-tot.obj-type   = ub.trn-doc.obj-type
          temp-stk-tot.obj-code   = ub.trn-doc.obj-code
          temp-stk-tot.fact-order = v-stk-tot-fact-order
          temp-stk-tot.sum-type   = v-root-sum-type[v-root-sum-type-ind-ext]
          temp-stk-tot.cat-id     = '##,##':U
          temp-stk-tot.fact-date  = ub.trn-doc.fact-date
          temp-stk-tot.shift-num  = 0
          temp-stk-tot.shift-date = ?
        .
      end.
      for each ub.stk-tot no-lock
        where ub.stk-tot.obj-type   = ub.trn-doc.obj-type
          and ub.stk-tot.obj-code   = ub.trn-doc.obj-code
          and ub.stk-tot.fact-order > v-stk-tot-fact-order
          and ub.stk-tot.fact-order <= v-day-cut-fact-order
      on error undo, return error
      :
        if ub.stk-tot.sum-type   begins v-root-sum-type[v-root-sum-type-ind-ext]
        and ub.stk-tot.shift-date = ?
        then do:
          create temp-stk-tot .
                              assign
            temp-stk-tot.obj-type     = ub.stk-tot.obj-type     temp-stk-tot.obj-code     = ub.stk-tot.obj-code     temp-stk-tot.fact-order   = ub.stk-tot.fact-order   temp-stk-tot.sum-type     = ub.stk-tot.sum-type     temp-stk-tot.cat-id       = ub.stk-tot.cat-id       temp-stk-tot.fact-date    = ub.stk-tot.fact-date    temp-stk-tot.shift-num    = ub.stk-tot.shift-num    temp-stk-tot.shift-date   = ub.stk-tot.shift-date
          .
          assign
                                                                                    temp-stk-tot.fact-qnty      = ub.stk-tot.fact-qnty            temp-stk-tot.sum-base       = ub.stk-tot.sum-base             temp-stk-tot.sum-rubl       = ub.stk-tot.sum-rubl             temp-stk-tot.vat-base       = ub.stk-tot.vat-base             temp-stk-tot.vat-rubl       = ub.stk-tot.vat-rubl             temp-stk-tot.slt-base       = ub.stk-tot.slt-base             temp-stk-tot.slt-rubl       = ub.stk-tot.slt-rubl             temp-stk-tot.road-tax-base  = ub.stk-tot.road-tax-base        temp-stk-tot.road-tax-rubl  = ub.stk-tot.road-tax-rubl        temp-stk-tot.excise-base    = ub.stk-tot.excise-base          temp-stk-tot.excise-rubl    = ub.stk-tot.excise-rubl          temp-stk-tot.transport-base = ub.stk-tot.transport-base       temp-stk-tot.transport-rubl = ub.stk-tot.transport-rubl       temp-stk-tot.other-base     = ub.stk-tot.other-base           temp-stk-tot.other-rubl     = ub.stk-tot.other-rubl
                                                                                    temp-stk-tot.new-fact-qnty      = ub.stk-tot.fact-qnty            temp-stk-tot.new-sum-base       = ub.stk-tot.sum-base             temp-stk-tot.new-sum-rubl       = ub.stk-tot.sum-rubl             temp-stk-tot.new-vat-base       = ub.stk-tot.vat-base             temp-stk-tot.new-vat-rubl       = ub.stk-tot.vat-rubl             temp-stk-tot.new-slt-base       = ub.stk-tot.slt-base             temp-stk-tot.new-slt-rubl       = ub.stk-tot.slt-rubl             temp-stk-tot.new-road-tax-base  = ub.stk-tot.road-tax-base        temp-stk-tot.new-road-tax-rubl  = ub.stk-tot.road-tax-rubl        temp-stk-tot.new-excise-base    = ub.stk-tot.excise-base          temp-stk-tot.new-excise-rubl    = ub.stk-tot.excise-rubl          temp-stk-tot.new-transport-base = ub.stk-tot.transport-base       temp-stk-tot.new-transport-rubl = ub.stk-tot.transport-rubl       temp-stk-tot.new-other-base     = ub.stk-tot.other-base           temp-stk-tot.new-other-rubl     = ub.stk-tot.other-rubl
          .
        end.
      end.
      if v-shift-on
      then do:
        assign
          v-prev-shift-stk-tot-fact-order = 0
        .
        find last ub.stk-tot no-lock
          where ub.stk-tot.obj-type   = ub.trn-doc.obj-type
            and ub.stk-tot.obj-code   = ub.trn-doc.obj-code
            and ub.stk-tot.sum-type   = v-root-sum-type[v-root-sum-type-ind-ext]
            and ub.stk-tot.cat-id     = '##,##':U
            and ub.stk-tot.fact-order <= v-shift-stk-tot-fact-order
            and ub.stk-tot.shift-date <> ?
          use-index category
          no-error .
        if available ub.stk-tot
        then do:
          assign
            v-prev-shift-stk-tot-fact-order = ub.stk-tot.fact-order
          .
        end.
        if v-prev-shift-stk-tot-fact-order > 0
        then do:
          for each ub.stk-tot no-lock
            where ub.stk-tot.obj-type   = ub.trn-doc.obj-type
              and ub.stk-tot.obj-code   = ub.trn-doc.obj-code
              and ub.stk-tot.fact-order = v-prev-shift-stk-tot-fact-order
              and ub.stk-tot.sum-type   begins v-root-sum-type[v-root-sum-type-ind-ext]
          on error undo, return error
          :
            create temp-shift-stk-tot .
                                    assign
              temp-shift-stk-tot.obj-type     = ub.stk-tot.obj-type     temp-shift-stk-tot.obj-code     = ub.stk-tot.obj-code     temp-shift-stk-tot.fact-order   = ub.stk-tot.fact-order   temp-shift-stk-tot.sum-type     = ub.stk-tot.sum-type     temp-shift-stk-tot.cat-id       = ub.stk-tot.cat-id       temp-shift-stk-tot.fact-date    = ub.stk-tot.fact-date    temp-shift-stk-tot.shift-num    = ub.stk-tot.shift-num    temp-shift-stk-tot.shift-date   = ub.stk-tot.shift-date
            .
            if v-shift-stk-tot-fact-order = v-prev-shift-stk-tot-fact-order
            then do:
              assign
                                                                                                                temp-shift-stk-tot.fact-qnty      = ub.stk-tot.fact-qnty            temp-shift-stk-tot.sum-base       = ub.stk-tot.sum-base             temp-shift-stk-tot.sum-rubl       = ub.stk-tot.sum-rubl             temp-shift-stk-tot.vat-base       = ub.stk-tot.vat-base             temp-shift-stk-tot.vat-rubl       = ub.stk-tot.vat-rubl             temp-shift-stk-tot.slt-base       = ub.stk-tot.slt-base             temp-shift-stk-tot.slt-rubl       = ub.stk-tot.slt-rubl             temp-shift-stk-tot.road-tax-base  = ub.stk-tot.road-tax-base        temp-shift-stk-tot.road-tax-rubl  = ub.stk-tot.road-tax-rubl        temp-shift-stk-tot.excise-base    = ub.stk-tot.excise-base          temp-shift-stk-tot.excise-rubl    = ub.stk-tot.excise-rubl          temp-shift-stk-tot.transport-base = ub.stk-tot.transport-base       temp-shift-stk-tot.transport-rubl = ub.stk-tot.transport-rubl       temp-shift-stk-tot.other-base     = ub.stk-tot.other-base           temp-shift-stk-tot.other-rubl     = ub.stk-tot.other-rubl
              .
            end.
            assign
              temp-shift-stk-tot.fact-order = v-shift-stk-tot-fact-order
              temp-shift-stk-tot.fact-date  = ub.trn-doc.fact-date
              temp-shift-stk-tot.shift-date = ub.trn-doc.shift-date
              temp-shift-stk-tot.shift-num  = ub.trn-doc.shift-num
                                                                                                  temp-shift-stk-tot.new-fact-qnty      = ub.stk-tot.fact-qnty            temp-shift-stk-tot.new-sum-base       = ub.stk-tot.sum-base             temp-shift-stk-tot.new-sum-rubl       = ub.stk-tot.sum-rubl             temp-shift-stk-tot.new-vat-base       = ub.stk-tot.vat-base             temp-shift-stk-tot.new-vat-rubl       = ub.stk-tot.vat-rubl             temp-shift-stk-tot.new-slt-base       = ub.stk-tot.slt-base             temp-shift-stk-tot.new-slt-rubl       = ub.stk-tot.slt-rubl             temp-shift-stk-tot.new-road-tax-base  = ub.stk-tot.road-tax-base        temp-shift-stk-tot.new-road-tax-rubl  = ub.stk-tot.road-tax-rubl        temp-shift-stk-tot.new-excise-base    = ub.stk-tot.excise-base          temp-shift-stk-tot.new-excise-rubl    = ub.stk-tot.excise-rubl          temp-shift-stk-tot.new-transport-base = ub.stk-tot.transport-base       temp-shift-stk-tot.new-transport-rubl = ub.stk-tot.transport-rubl       temp-shift-stk-tot.new-other-base     = ub.stk-tot.other-base           temp-shift-stk-tot.new-other-rubl     = ub.stk-tot.other-rubl
            .
          end.
        end.
        else do:
          create temp-shift-stk-tot.
          assign
            temp-shift-stk-tot.obj-type   = ub.trn-doc.obj-type
            temp-shift-stk-tot.obj-code   = ub.trn-doc.obj-code
            temp-shift-stk-tot.fact-order = v-shift-stk-tot-fact-order
            temp-shift-stk-tot.sum-type   = v-root-sum-type[v-root-sum-type-ind-ext]
            temp-shift-stk-tot.cat-id     = '##,##':U
            temp-shift-stk-tot.fact-date  = ub.trn-doc.fact-date
            temp-shift-stk-tot.shift-date = ub.trn-doc.shift-date
            temp-shift-stk-tot.shift-num  = ub.trn-doc.shift-num
          .
        end.
        for each ub.stk-tot no-lock
          where ub.stk-tot.obj-type   = ub.trn-doc.obj-type
            and ub.stk-tot.obj-code   = ub.trn-doc.obj-code
            and ub.stk-tot.fact-order > v-shift-stk-tot-fact-order
            and ub.stk-tot.fact-order <= v-shift-cut-fact-order
        on error undo, return error
        :
          if ub.stk-tot.sum-type   begins v-root-sum-type[v-root-sum-type-ind-ext]
          and ub.stk-tot.shift-date <> ?
          then do:
            create temp-shift-stk-tot .
                                    assign
              temp-shift-stk-tot.obj-type     = ub.stk-tot.obj-type     temp-shift-stk-tot.obj-code     = ub.stk-tot.obj-code     temp-shift-stk-tot.fact-order   = ub.stk-tot.fact-order   temp-shift-stk-tot.sum-type     = ub.stk-tot.sum-type     temp-shift-stk-tot.cat-id       = ub.stk-tot.cat-id       temp-shift-stk-tot.fact-date    = ub.stk-tot.fact-date    temp-shift-stk-tot.shift-num    = ub.stk-tot.shift-num    temp-shift-stk-tot.shift-date   = ub.stk-tot.shift-date
            .
            assign
                                                                                                  temp-shift-stk-tot.fact-qnty      = ub.stk-tot.fact-qnty            temp-shift-stk-tot.sum-base       = ub.stk-tot.sum-base             temp-shift-stk-tot.sum-rubl       = ub.stk-tot.sum-rubl             temp-shift-stk-tot.vat-base       = ub.stk-tot.vat-base             temp-shift-stk-tot.vat-rubl       = ub.stk-tot.vat-rubl             temp-shift-stk-tot.slt-base       = ub.stk-tot.slt-base             temp-shift-stk-tot.slt-rubl       = ub.stk-tot.slt-rubl             temp-shift-stk-tot.road-tax-base  = ub.stk-tot.road-tax-base        temp-shift-stk-tot.road-tax-rubl  = ub.stk-tot.road-tax-rubl        temp-shift-stk-tot.excise-base    = ub.stk-tot.excise-base          temp-shift-stk-tot.excise-rubl    = ub.stk-tot.excise-rubl          temp-shift-stk-tot.transport-base = ub.stk-tot.transport-base       temp-shift-stk-tot.transport-rubl = ub.stk-tot.transport-rubl       temp-shift-stk-tot.other-base     = ub.stk-tot.other-base           temp-shift-stk-tot.other-rubl     = ub.stk-tot.other-rubl
                                                                                                  temp-shift-stk-tot.new-fact-qnty      = ub.stk-tot.fact-qnty            temp-shift-stk-tot.new-sum-base       = ub.stk-tot.sum-base             temp-shift-stk-tot.new-sum-rubl       = ub.stk-tot.sum-rubl             temp-shift-stk-tot.new-vat-base       = ub.stk-tot.vat-base             temp-shift-stk-tot.new-vat-rubl       = ub.stk-tot.vat-rubl             temp-shift-stk-tot.new-slt-base       = ub.stk-tot.slt-base             temp-shift-stk-tot.new-slt-rubl       = ub.stk-tot.slt-rubl             temp-shift-stk-tot.new-road-tax-base  = ub.stk-tot.road-tax-base        temp-shift-stk-tot.new-road-tax-rubl  = ub.stk-tot.road-tax-rubl        temp-shift-stk-tot.new-excise-base    = ub.stk-tot.excise-base          temp-shift-stk-tot.new-excise-rubl    = ub.stk-tot.excise-rubl          temp-shift-stk-tot.new-transport-base = ub.stk-tot.transport-base       temp-shift-stk-tot.new-transport-rubl = ub.stk-tot.transport-rubl       temp-shift-stk-tot.new-other-base     = ub.stk-tot.other-base           temp-shift-stk-tot.new-other-rubl     = ub.stk-tot.other-rubl
            .
          end.
        end.
      end.
    end.
    run show-action in this-procedure
      (input "Считывается остаток по товарам на объекте"
      ).
    define variable v-doc-line-root-sum-type as character no-undo extent 5 .
    define variable v-doc-line-root-sum-type-ind-ext as integer   no-undo .
    for each ub.doc-line
      where ub.doc-line.doc-code = ub.trn-doc.doc-code no-lock
    on error undo, return error
    :
      find first ub.goods no-lock
        where ub.goods.artic     = ub.doc-line.artic
          and ub.goods.prod-type = ub.doc-line.prod-type
          and ub.goods.prod-code = ub.doc-line.prod-code
        .
      if ub.goods.gds-type = 'т':U
      then do:
        assign
          v-doc-line-root-sum-type[1] = 'crsa':U
          v-doc-line-root-sum-type[2] = 'cost':U
          v-doc-line-root-sum-type[3] = 'sadt':U         + ub.trn-doc.ext-doc-type
          v-doc-line-root-sum-type[4] = 'cgdt':U         + ub.trn-doc.ext-doc-type
          v-doc-line-root-sum-type[5] = 'csdt':U         + ub.trn-doc.ext-doc-type
        .
      end.
      else do:
        assign
          v-doc-line-root-sum-type[1] = 'cgsr':U
          v-doc-line-root-sum-type[2] = 'cssr':U
          v-doc-line-root-sum-type[3] = 'adsr':U + ub.trn-doc.ext-doc-type
          v-doc-line-root-sum-type[4] = 'gdsr':U + ub.trn-doc.ext-doc-type
          v-doc-line-root-sum-type[5] = 'sdsr':U + ub.trn-doc.ext-doc-type
        .
      end.
      do v-doc-line-root-sum-type-ind-ext = 1 to extent(v-doc-line-root-sum-type)
      :
        find last ub.stk-line no-lock
          where ub.stk-line.obj-type   = ub.doc-line.obj-type
            and ub.stk-line.obj-code   = ub.doc-line.obj-code
            and ub.stk-line.artic      = ub.doc-line.artic
            and ub.stk-line.prod-type  = ub.doc-line.prod-type
            and ub.stk-line.prod-code  = ub.doc-line.prod-code
            and ub.stk-line.sum-type   = v-doc-line-root-sum-type[v-doc-line-root-sum-type-ind-ext]
            and ub.stk-line.fact-order <= v-stk-line-fact-order
            and ub.stk-line.shift-date = ?
          use-index category
          no-error .
        if available ub.stk-line
        then do:
          assign
            v-prev-stk-line-fact-order = ub.stk-line.fact-order
          .
          for each ub.stk-line no-lock
            where ub.stk-line.obj-type   = ub.doc-line.obj-type
              and ub.stk-line.obj-code   = ub.doc-line.obj-code
              and ub.stk-line.artic      = ub.doc-line.artic
              and ub.stk-line.prod-type  = ub.doc-line.prod-type
              and ub.stk-line.prod-code  = ub.doc-line.prod-code
              and ub.stk-line.fact-order = v-prev-stk-line-fact-order
              and ub.stk-line.sum-type   begins v-doc-line-root-sum-type[v-doc-line-root-sum-type-ind-ext]
          on error undo, return error
          :
            create temp-stk-line .
                                    assign
              temp-stk-line.obj-type     = ub.stk-line.obj-type     temp-stk-line.obj-code     = ub.stk-line.obj-code     temp-stk-line.artic        = ub.stk-line.artic        temp-stk-line.prod-type    = ub.stk-line.prod-type    temp-stk-line.prod-code    = ub.stk-line.prod-code    temp-stk-line.fact-order   = ub.stk-line.fact-order   temp-stk-line.sum-type     = ub.stk-line.sum-type     temp-stk-line.cat-id       = ub.stk-line.cat-id       temp-stk-line.fact-date    = ub.stk-line.fact-date    temp-stk-line.shift-num    = ub.stk-line.shift-num    temp-stk-line.shift-date   = ub.stk-line.shift-date
            .
            if v-stk-line-fact-order = v-prev-stk-line-fact-order
            then do:
              assign
                                                                                                                temp-stk-line.fact-qnty      = ub.stk-line.fact-qnty            temp-stk-line.sum-base       = ub.stk-line.sum-base             temp-stk-line.sum-rubl       = ub.stk-line.sum-rubl             temp-stk-line.vat-base       = ub.stk-line.vat-base             temp-stk-line.vat-rubl       = ub.stk-line.vat-rubl             temp-stk-line.slt-base       = ub.stk-line.slt-base             temp-stk-line.slt-rubl       = ub.stk-line.slt-rubl             temp-stk-line.road-tax-base  = ub.stk-line.road-tax-base        temp-stk-line.road-tax-rubl  = ub.stk-line.road-tax-rubl        temp-stk-line.excise-base    = ub.stk-line.excise-base          temp-stk-line.excise-rubl    = ub.stk-line.excise-rubl          temp-stk-line.transport-base = ub.stk-line.transport-base       temp-stk-line.transport-rubl = ub.stk-line.transport-rubl       temp-stk-line.other-base     = ub.stk-line.other-base           temp-stk-line.other-rubl     = ub.stk-line.other-rubl
              .
            end.
            assign
              temp-stk-line.fact-order = v-stk-line-fact-order
              temp-stk-line.fact-date  = ub.trn-doc.fact-date
              temp-stk-line.shift-num  = 0
              temp-stk-line.shift-date = ?
                                                                                                  temp-stk-line.new-fact-qnty      = ub.stk-line.fact-qnty            temp-stk-line.new-sum-base       = ub.stk-line.sum-base             temp-stk-line.new-sum-rubl       = ub.stk-line.sum-rubl             temp-stk-line.new-vat-base       = ub.stk-line.vat-base             temp-stk-line.new-vat-rubl       = ub.stk-line.vat-rubl             temp-stk-line.new-slt-base       = ub.stk-line.slt-base             temp-stk-line.new-slt-rubl       = ub.stk-line.slt-rubl             temp-stk-line.new-road-tax-base  = ub.stk-line.road-tax-base        temp-stk-line.new-road-tax-rubl  = ub.stk-line.road-tax-rubl        temp-stk-line.new-excise-base    = ub.stk-line.excise-base          temp-stk-line.new-excise-rubl    = ub.stk-line.excise-rubl          temp-stk-line.new-transport-base = ub.stk-line.transport-base       temp-stk-line.new-transport-rubl = ub.stk-line.transport-rubl       temp-stk-line.new-other-base     = ub.stk-line.other-base           temp-stk-line.new-other-rubl     = ub.stk-line.other-rubl
            .
          end.
        end.
        else do:
          create temp-stk-line.
          assign
            temp-stk-line.obj-type   = ub.doc-line.obj-type
            temp-stk-line.obj-code   = ub.doc-line.obj-code
            temp-stk-line.artic      = ub.doc-line.artic
            temp-stk-line.prod-type  = ub.doc-line.prod-type
            temp-stk-line.prod-code  = ub.doc-line.prod-code
            temp-stk-line.fact-order = v-stk-line-fact-order
            temp-stk-line.sum-type   = v-doc-line-root-sum-type[v-doc-line-root-sum-type-ind-ext]
            temp-stk-line.cat-id     = '##,##':U
            temp-stk-line.fact-date  = ub.trn-doc.fact-date
            temp-stk-line.shift-num  = 0
            temp-stk-line.shift-date = ?
          .
        end.
        for each ub.stk-line no-lock
          where ub.stk-line.obj-type   = ub.doc-line.obj-type
            and ub.stk-line.obj-code   = ub.doc-line.obj-code
            and ub.stk-line.artic      = ub.doc-line.artic
            and ub.stk-line.prod-type  = ub.doc-line.prod-type
            and ub.stk-line.prod-code  = ub.doc-line.prod-code
            and ub.stk-line.fact-order > v-stk-line-fact-order
            and ub.stk-line.fact-order <= v-day-cut-fact-order
        on error undo, return error
        :
          if ub.stk-line.sum-type   begins v-doc-line-root-sum-type[v-doc-line-root-sum-type-ind-ext]
          and ub.stk-line.shift-date = ?
          then do:
            create temp-stk-line .
                                    assign
              temp-stk-line.obj-type     = ub.stk-line.obj-type     temp-stk-line.obj-code     = ub.stk-line.obj-code     temp-stk-line.artic        = ub.stk-line.artic        temp-stk-line.prod-type    = ub.stk-line.prod-type    temp-stk-line.prod-code    = ub.stk-line.prod-code    temp-stk-line.fact-order   = ub.stk-line.fact-order   temp-stk-line.sum-type     = ub.stk-line.sum-type     temp-stk-line.cat-id       = ub.stk-line.cat-id       temp-stk-line.fact-date    = ub.stk-line.fact-date    temp-stk-line.shift-num    = ub.stk-line.shift-num    temp-stk-line.shift-date   = ub.stk-line.shift-date
            .
            assign
                                                                                                  temp-stk-line.fact-qnty      = ub.stk-line.fact-qnty            temp-stk-line.sum-base       = ub.stk-line.sum-base             temp-stk-line.sum-rubl       = ub.stk-line.sum-rubl             temp-stk-line.vat-base       = ub.stk-line.vat-base             temp-stk-line.vat-rubl       = ub.stk-line.vat-rubl             temp-stk-line.slt-base       = ub.stk-line.slt-base             temp-stk-line.slt-rubl       = ub.stk-line.slt-rubl             temp-stk-line.road-tax-base  = ub.stk-line.road-tax-base        temp-stk-line.road-tax-rubl  = ub.stk-line.road-tax-rubl        temp-stk-line.excise-base    = ub.stk-line.excise-base          temp-stk-line.excise-rubl    = ub.stk-line.excise-rubl          temp-stk-line.transport-base = ub.stk-line.transport-base       temp-stk-line.transport-rubl = ub.stk-line.transport-rubl       temp-stk-line.other-base     = ub.stk-line.other-base           temp-stk-line.other-rubl     = ub.stk-line.other-rubl
                                                                                                  temp-stk-line.new-fact-qnty      = ub.stk-line.fact-qnty            temp-stk-line.new-sum-base       = ub.stk-line.sum-base             temp-stk-line.new-sum-rubl       = ub.stk-line.sum-rubl             temp-stk-line.new-vat-base       = ub.stk-line.vat-base             temp-stk-line.new-vat-rubl       = ub.stk-line.vat-rubl             temp-stk-line.new-slt-base       = ub.stk-line.slt-base             temp-stk-line.new-slt-rubl       = ub.stk-line.slt-rubl             temp-stk-line.new-road-tax-base  = ub.stk-line.road-tax-base        temp-stk-line.new-road-tax-rubl  = ub.stk-line.road-tax-rubl        temp-stk-line.new-excise-base    = ub.stk-line.excise-base          temp-stk-line.new-excise-rubl    = ub.stk-line.excise-rubl          temp-stk-line.new-transport-base = ub.stk-line.transport-base       temp-stk-line.new-transport-rubl = ub.stk-line.transport-rubl       temp-stk-line.new-other-base     = ub.stk-line.other-base           temp-stk-line.new-other-rubl     = ub.stk-line.other-rubl
            .
          end.
        end.
        if v-shift-on
        then do:
          assign
            v-prev-shift-stk-line-fact-order = 0
          .
          find last ub.stk-line no-lock
            where ub.stk-line.obj-type   = ub.doc-line.obj-type
              and ub.stk-line.obj-code   = ub.doc-line.obj-code
              and ub.stk-line.artic      = ub.doc-line.artic
              and ub.stk-line.prod-type  = ub.doc-line.prod-type
              and ub.stk-line.prod-code  = ub.doc-line.prod-code
              and ub.stk-line.sum-type   = v-doc-line-root-sum-type[v-doc-line-root-sum-type-ind-ext]
              and ub.stk-line.fact-order <= v-shift-stk-line-fact-order
              and ub.stk-line.shift-date <> ?
            use-index category
            no-error .
          if available ub.stk-line
          then do:
            assign
              v-prev-shift-stk-line-fact-order = ub.stk-line.fact-order
            .
          end.
          if v-prev-shift-stk-line-fact-order > 0
          then do:
            for each ub.stk-line no-lock
              where ub.stk-line.obj-type   = ub.doc-line.obj-type
                and ub.stk-line.obj-code   = ub.doc-line.obj-code
                and ub.stk-line.artic      = ub.doc-line.artic
                and ub.stk-line.prod-type  = ub.doc-line.prod-type
                and ub.stk-line.prod-code  = ub.doc-line.prod-code
                and ub.stk-line.fact-order = v-prev-shift-stk-line-fact-order
                and ub.stk-line.sum-type   begins v-doc-line-root-sum-type[v-doc-line-root-sum-type-ind-ext]
            on error undo, return error
            :
              create temp-shift-stk-line .
                                          assign
                temp-shift-stk-line.obj-type     = ub.stk-line.obj-type     temp-shift-stk-line.obj-code     = ub.stk-line.obj-code     temp-shift-stk-line.artic        = ub.stk-line.artic        temp-shift-stk-line.prod-type    = ub.stk-line.prod-type    temp-shift-stk-line.prod-code    = ub.stk-line.prod-code    temp-shift-stk-line.fact-order   = ub.stk-line.fact-order   temp-shift-stk-line.sum-type     = ub.stk-line.sum-type     temp-shift-stk-line.cat-id       = ub.stk-line.cat-id       temp-shift-stk-line.fact-date    = ub.stk-line.fact-date    temp-shift-stk-line.shift-num    = ub.stk-line.shift-num    temp-shift-stk-line.shift-date   = ub.stk-line.shift-date
              .
              if v-shift-stk-line-fact-order = v-prev-shift-stk-line-fact-order
              then do:
                assign
                                                                                                                              temp-shift-stk-line.fact-qnty      = ub.stk-line.fact-qnty            temp-shift-stk-line.sum-base       = ub.stk-line.sum-base             temp-shift-stk-line.sum-rubl       = ub.stk-line.sum-rubl             temp-shift-stk-line.vat-base       = ub.stk-line.vat-base             temp-shift-stk-line.vat-rubl       = ub.stk-line.vat-rubl             temp-shift-stk-line.slt-base       = ub.stk-line.slt-base             temp-shift-stk-line.slt-rubl       = ub.stk-line.slt-rubl             temp-shift-stk-line.road-tax-base  = ub.stk-line.road-tax-base        temp-shift-stk-line.road-tax-rubl  = ub.stk-line.road-tax-rubl        temp-shift-stk-line.excise-base    = ub.stk-line.excise-base          temp-shift-stk-line.excise-rubl    = ub.stk-line.excise-rubl          temp-shift-stk-line.transport-base = ub.stk-line.transport-base       temp-shift-stk-line.transport-rubl = ub.stk-line.transport-rubl       temp-shift-stk-line.other-base     = ub.stk-line.other-base           temp-shift-stk-line.other-rubl     = ub.stk-line.other-rubl
                .
              end.
              assign
                temp-shift-stk-line.fact-order = v-shift-stk-line-fact-order
                temp-shift-stk-line.fact-date  = ub.trn-doc.fact-date
                temp-shift-stk-line.shift-date = ub.trn-doc.shift-date
                temp-shift-stk-line.shift-num  = ub.trn-doc.shift-num
                                                                                                                temp-shift-stk-line.new-fact-qnty      = ub.stk-line.fact-qnty            temp-shift-stk-line.new-sum-base       = ub.stk-line.sum-base             temp-shift-stk-line.new-sum-rubl       = ub.stk-line.sum-rubl             temp-shift-stk-line.new-vat-base       = ub.stk-line.vat-base             temp-shift-stk-line.new-vat-rubl       = ub.stk-line.vat-rubl             temp-shift-stk-line.new-slt-base       = ub.stk-line.slt-base             temp-shift-stk-line.new-slt-rubl       = ub.stk-line.slt-rubl             temp-shift-stk-line.new-road-tax-base  = ub.stk-line.road-tax-base        temp-shift-stk-line.new-road-tax-rubl  = ub.stk-line.road-tax-rubl        temp-shift-stk-line.new-excise-base    = ub.stk-line.excise-base          temp-shift-stk-line.new-excise-rubl    = ub.stk-line.excise-rubl          temp-shift-stk-line.new-transport-base = ub.stk-line.transport-base       temp-shift-stk-line.new-transport-rubl = ub.stk-line.transport-rubl       temp-shift-stk-line.new-other-base     = ub.stk-line.other-base           temp-shift-stk-line.new-other-rubl     = ub.stk-line.other-rubl
              .
            end.
          end.
          else do:
            create temp-shift-stk-line.
            assign
              temp-shift-stk-line.obj-type   = ub.doc-line.obj-type
              temp-shift-stk-line.obj-code   = ub.doc-line.obj-code
              temp-shift-stk-line.artic      = ub.doc-line.artic
              temp-shift-stk-line.prod-type  = ub.doc-line.prod-type
              temp-shift-stk-line.prod-code  = ub.doc-line.prod-code
              temp-shift-stk-line.fact-order = v-shift-stk-line-fact-order
              temp-shift-stk-line.sum-type   = v-doc-line-root-sum-type[v-doc-line-root-sum-type-ind-ext]
              temp-shift-stk-line.cat-id     = '##,##':U
              temp-shift-stk-line.fact-date  = ub.trn-doc.fact-date
              temp-shift-stk-line.shift-date = ub.trn-doc.shift-date
              temp-shift-stk-line.shift-num  = ub.trn-doc.shift-num
            .
          end.
          for each ub.stk-line no-lock
            where ub.stk-line.obj-type   = ub.doc-line.obj-type
              and ub.stk-line.obj-code   = ub.doc-line.obj-code
              and ub.stk-line.artic      = ub.doc-line.artic
              and ub.stk-line.prod-type  = ub.doc-line.prod-type
              and ub.stk-line.prod-code  = ub.doc-line.prod-code
              and ub.stk-line.fact-order > v-shift-stk-line-fact-order
              and ub.stk-line.fact-order <= v-shift-cut-fact-order
          on error undo, return error
          :
            if ub.stk-line.sum-type   begins v-doc-line-root-sum-type[v-doc-line-root-sum-type-ind-ext]
            and ub.stk-line.shift-date <> ?
            then do:
              create temp-shift-stk-line .
                                          assign
                temp-shift-stk-line.obj-type     = ub.stk-line.obj-type     temp-shift-stk-line.obj-code     = ub.stk-line.obj-code     temp-shift-stk-line.artic        = ub.stk-line.artic        temp-shift-stk-line.prod-type    = ub.stk-line.prod-type    temp-shift-stk-line.prod-code    = ub.stk-line.prod-code    temp-shift-stk-line.fact-order   = ub.stk-line.fact-order   temp-shift-stk-line.sum-type     = ub.stk-line.sum-type     temp-shift-stk-line.cat-id       = ub.stk-line.cat-id       temp-shift-stk-line.fact-date    = ub.stk-line.fact-date    temp-shift-stk-line.shift-num    = ub.stk-line.shift-num    temp-shift-stk-line.shift-date   = ub.stk-line.shift-date
              .
              assign
                                                                                                                temp-shift-stk-line.fact-qnty      = ub.stk-line.fact-qnty            temp-shift-stk-line.sum-base       = ub.stk-line.sum-base             temp-shift-stk-line.sum-rubl       = ub.stk-line.sum-rubl             temp-shift-stk-line.vat-base       = ub.stk-line.vat-base             temp-shift-stk-line.vat-rubl       = ub.stk-line.vat-rubl             temp-shift-stk-line.slt-base       = ub.stk-line.slt-base             temp-shift-stk-line.slt-rubl       = ub.stk-line.slt-rubl             temp-shift-stk-line.road-tax-base  = ub.stk-line.road-tax-base        temp-shift-stk-line.road-tax-rubl  = ub.stk-line.road-tax-rubl        temp-shift-stk-line.excise-base    = ub.stk-line.excise-base          temp-shift-stk-line.excise-rubl    = ub.stk-line.excise-rubl          temp-shift-stk-line.transport-base = ub.stk-line.transport-base       temp-shift-stk-line.transport-rubl = ub.stk-line.transport-rubl       temp-shift-stk-line.other-base     = ub.stk-line.other-base           temp-shift-stk-line.other-rubl     = ub.stk-line.other-rubl
                                                                                                                temp-shift-stk-line.new-fact-qnty      = ub.stk-line.fact-qnty            temp-shift-stk-line.new-sum-base       = ub.stk-line.sum-base             temp-shift-stk-line.new-sum-rubl       = ub.stk-line.sum-rubl             temp-shift-stk-line.new-vat-base       = ub.stk-line.vat-base             temp-shift-stk-line.new-vat-rubl       = ub.stk-line.vat-rubl             temp-shift-stk-line.new-slt-base       = ub.stk-line.slt-base             temp-shift-stk-line.new-slt-rubl       = ub.stk-line.slt-rubl             temp-shift-stk-line.new-road-tax-base  = ub.stk-line.road-tax-base        temp-shift-stk-line.new-road-tax-rubl  = ub.stk-line.road-tax-rubl        temp-shift-stk-line.new-excise-base    = ub.stk-line.excise-base          temp-shift-stk-line.new-excise-rubl    = ub.stk-line.excise-rubl          temp-shift-stk-line.new-transport-base = ub.stk-line.transport-base       temp-shift-stk-line.new-transport-rubl = ub.stk-line.transport-rubl       temp-shift-stk-line.new-other-base     = ub.stk-line.other-base           temp-shift-stk-line.new-other-rubl     = ub.stk-line.other-rubl
              .
            end.
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure process-doc-line :
  define variable v-host-code like ub.sysconf.host-code         no-undo.
  define variable v-cur-dn  as character no-undo .
  define variable v-price as decimal   no-undo .
  define variable v-cur-rt as decimal   no-undo .
  define variable v-cur-ex as decimal   no-undo .
  define variable v-b-pcode as integer   no-undo .
  define variable v-is-part-price as logical   no-undo .
  define buffer buf_tt-clcparts for tt-clcparts .
  define buffer buf_tt-allsum-line for tt-allsum-line .
  do
  on error undo, return error
  :
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  ub.doc-line.obj-type
  ,input  ub.doc-line.obj-code
  ,output v-host-code
  )  .
    find first ub.goods no-lock
      where ub.goods.artic     = ub.doc-line.artic
        and ub.goods.prod-type = ub.doc-line.prod-type
        and ub.goods.prod-code = ub.doc-line.prod-code
      no-error .
    if not available goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар" skip
        "Документ" ub.doc-line.doc-code skip
        "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    if ub.goods.gds-type = 'т':U
    then do:
      define variable v-doc-sign as integer   no-undo .
      if ub.trn-doc.doc-type = 'рас':U
      or ub.trn-doc.doc-type = 'спи':U
      then do:
        assign
          v-doc-sign = -1
        .
      end.
      else do:
        assign
          v-doc-sign = 1
        .
      end.
      for each ub.parts no-lock
        where ub.parts.out-code  = ub.trn-doc.doc-code
          and ub.parts.obj-type  = ub.trn-doc.obj-type
          and ub.parts.obj-code  = ub.trn-doc.obj-code
          and ub.parts.artic     = ub.doc-line.artic
          and ub.parts.prod-type = ub.doc-line.prod-type
          and ub.parts.prod-code = ub.doc-line.prod-code
      on error undo, return error
      :
        for each buf_tt-clcparts
        on error undo, return error return-value
        :
          delete buf_tt-clcparts .
        end.
        create buf_tt-clcparts .
        buffer-copy ub.parts to buf_tt-clcparts .
        v-is-part-price = false .
        if ub.doc-line.is-parts = true  then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run partbcod in g#library
  (buffer ub.parts
  ,output v-b-pcode
  ) no-error .
           if error-status :error or v-b-pcode = 0  or v-b-pcode = ? then do:
              v-is-part-price = false .
           end.
           else do:
             v-is-part-price = true  .
           end.
           if v-is-part-price = true  then do:
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  ub.parts.obj-type
  ,input  ub.parts.obj-code
  ,input  v-b-pcode
  ,input  0
  ,input  ub.trn-doc.fact-order
  ,output v-cur-dn
  ,output v-price
  ,output v-cur-rt
  ,output v-cur-ex
  ) no-error .
              if error-status :error then do:
                v-price = ? .
              end.
           end.
        end.
        run clcprtsl_calc-ttable in this-procedure
          (input false
          ,input (if v-is-part-price = true  then true else false)
          ,input ?
          ,input ?
          ,input ?
          ,input ?
          ,input ?
          ,input ?
          ,input ?
          ,input ?
          ,input (if v-is-part-price = true  then v-price else ? )
          ,input ?
          ,input ?
          ,input ?
          ,input ?
          ,input ?
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процедуры clcprtsl_calc-ttable" skip
            "Документ" ub.doc-line.doc-code skip
            "Артикул " ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
            "Партия  " ub.parts.part-code skip
            ub.parts.in-code   skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        define variable v-cost-vat-pc as decimal   no-undo .
        define variable v-cost-slt-pc as decimal   no-undo .
        assign
          v-cost-vat-pc = ub.parts.vat-pc
          v-cost-slt-pc = ub.parts.slt-pc
        .
        find first buf_tt-allsum-line
          where buf_tt-allsum-line.sum-type = 'основная_сумма_со_знаком':U
          no-error .
        if available buf_tt-allsum-line
        then do:
          assign
            v-fact-qnty      = - buf_tt-allsum-line.fact-qnty          * v-doc-sign
            v-sum-base       = - buf_tt-allsum-line.sum-dsc-base-acc   * v-doc-sign
            v-sum-rubl       = - buf_tt-allsum-line.sum-dsc-rubl-acc   * v-doc-sign
            v-vat-base       = - buf_tt-allsum-line.vat-base-acc       * v-doc-sign
            v-vat-rubl       = - buf_tt-allsum-line.vat-rubl-acc       * v-doc-sign
            v-slt-base       = - buf_tt-allsum-line.slt-base-acc       * v-doc-sign
            v-slt-rubl       = - buf_tt-allsum-line.slt-rubl-acc       * v-doc-sign
            v-road-tax-base  = - buf_tt-allsum-line.road-tax-base-acc  * v-doc-sign
            v-road-tax-rubl  = - buf_tt-allsum-line.road-tax-rubl-acc  * v-doc-sign
            v-excise-base    = - buf_tt-allsum-line.excise-base-acc    * v-doc-sign
            v-excise-rubl    = - buf_tt-allsum-line.excise-rubl-acc    * v-doc-sign
            v-transport-base = - buf_tt-allsum-line.transport-base-acc * v-doc-sign
            v-transport-rubl = - buf_tt-allsum-line.transport-rubl-acc * v-doc-sign
            v-other-base     = - buf_tt-allsum-line.other-base-acc     * v-doc-sign
            v-other-rubl     = - buf_tt-allsum-line.other-rubl-acc     * v-doc-sign
          .
        end.
        else do:
          assign
            v-fact-qnty      = 0
            v-sum-base       = 0
            v-sum-rubl       = 0
            v-vat-base       = 0
            v-vat-rubl       = 0
            v-slt-base       = 0
            v-slt-rubl       = 0
            v-road-tax-base  = 0
            v-road-tax-rubl  = 0
            v-excise-base    = 0
            v-excise-rubl    = 0
            v-transport-base = 0
            v-transport-rubl = 0
            v-other-base     = 0
            v-other-rubl     = 0
          .
        end.
        if
                                        v-fact-qnty      = ? or    v-sum-base       = ? or    v-sum-rubl       = ? or    v-vat-base       = ? or    v-vat-rubl       = ? or    v-slt-base       = ? or    v-slt-rubl       = ? or    v-road-tax-base  = ? or    v-road-tax-rubl  = ? or    v-excise-base    = ? or    v-excise-rubl    = ? or    v-transport-base = ? or    v-transport-rubl = ? or    v-other-base     = ? or    v-other-rubl     = ?
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Программа clcprtsl.i вернула неопределенные значения в учетных ценах по партиям" skip
            "Расчет складского архива по товарам невозможен" skip
            "Документ" ub.doc-line.doc-code skip
            "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
                                                                                    "v-fact-qnty"      v-fact-qnty        skip    "v-sum-base"       v-sum-base         skip    "v-sum-rubl"       v-sum-rubl         skip    "v-vat-base"       v-vat-base         skip    "v-vat-rubl"       v-vat-rubl         skip    "v-slt-base"       v-slt-base         skip    "v-slt-rubl"       v-slt-rubl         skip    "v-road-tax-base"  v-road-tax-base    skip    "v-road-tax-rubl"  v-road-tax-rubl    skip    "v-excise-base"    v-excise-base      skip    "v-excise-rubl"    v-excise-rubl      skip    "v-transport-base" v-transport-base   skip    "v-transport-rubl" v-transport-rubl   skip    "v-other-base"     v-other-base       skip    "v-other-rubl"     v-other-rubl
            view-as alert-box error .
          undo, return error .
        end.
        assign
          v-sum-type[1] = 'cost':U
          v-cat-id[1]   = '##':U + "," + '##':U
          v-sum-type[2] = 'cost':U + 'v':U
          v-cat-id[2]   = trim(string(v-cost-vat-pc, ">99")) + "," + '##':U
          v-sum-type[3] = 'cost':U + 's':U
          v-cat-id[3]   = '##':U + "," + trim(string(v-cost-slt-pc, ">99"))
          v-sum-type[4] = 'cost':U + 'x':U
          v-cat-id[4]   = trim(string(v-cost-vat-pc, ">99")) + "," + trim(string(v-cost-slt-pc, ">99"))
        .
        if v-cat-id[1] = ?
        or v-cat-id[2] = ?
        or v-cat-id[3] = ?
        or v-cat-id[4] = ?
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при расчете складского архива по товарам" skip
            "Не заданы налоги учетных цен" skip
            "Документ" ub.doc-line.doc-code skip
            "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
            "НДС" v-cost-vat-pc skip
            "НсП" v-cost-slt-pc skip
            view-as alert-box error .
          undo, return error .
        end.
        do ind-ext = 1 to 4
        :
          find first temp-ot-line
            where temp-ot-line.doc-code  = ub.doc-line.doc-code
              and temp-ot-line.artic     = ub.doc-line.artic
              and temp-ot-line.prod-type = ub.doc-line.prod-type
              and temp-ot-line.prod-code = ub.doc-line.prod-code
              and temp-ot-line.sum-type  = v-sum-type[ind-ext]
              and temp-ot-line.cat-id    = v-cat-id[ind-ext]
            no-error .
          if not available temp-ot-line
          then do:
            create temp-ot-line .
            assign
              temp-ot-line.doc-code     = ub.doc-line.doc-code
              temp-ot-line.artic        = ub.doc-line.artic
              temp-ot-line.prod-type    = ub.doc-line.prod-type
              temp-ot-line.prod-code    = ub.doc-line.prod-code
              temp-ot-line.sum-type     = v-sum-type[ind-ext]
              temp-ot-line.cat-id       = v-cat-id[ind-ext]
              temp-ot-line.ext-doc-type = ub.trn-doc.ext-doc-type
              temp-ot-line.obj-type     = ub.trn-doc.obj-type
              temp-ot-line.obj-code     = ub.trn-doc.obj-code
              temp-ot-line.fact-order   = v-ot-fact-order
            .
          end.
          assign
                                                                                                            temp-ot-line.new-fact-qnty      = temp-ot-line.new-fact-qnty      + v-fact-qnty           temp-ot-line.new-sum-base       = temp-ot-line.new-sum-base       + v-sum-base            temp-ot-line.new-sum-rubl       = temp-ot-line.new-sum-rubl       + v-sum-rubl            temp-ot-line.new-vat-base       = temp-ot-line.new-vat-base       + v-vat-base            temp-ot-line.new-vat-rubl       = temp-ot-line.new-vat-rubl       + v-vat-rubl            temp-ot-line.new-slt-base       = temp-ot-line.new-slt-base       + v-slt-base            temp-ot-line.new-slt-rubl       = temp-ot-line.new-slt-rubl       + v-slt-rubl            temp-ot-line.new-road-tax-base  = temp-ot-line.new-road-tax-base  + v-road-tax-base       temp-ot-line.new-road-tax-rubl  = temp-ot-line.new-road-tax-rubl  + v-road-tax-rubl       temp-ot-line.new-excise-base    = temp-ot-line.new-excise-base    + v-excise-base         temp-ot-line.new-excise-rubl    = temp-ot-line.new-excise-rubl    + v-excise-rubl         temp-ot-line.new-transport-base = temp-ot-line.new-transport-base + v-transport-base      temp-ot-line.new-transport-rubl = temp-ot-line.new-transport-rubl + v-transport-rubl      temp-ot-line.new-other-base     = temp-ot-line.new-other-base     + v-other-base          temp-ot-line.new-other-rubl     = temp-ot-line.new-other-rubl     + v-other-rubl
          .
        end.
      end.
    end.
    else do:
      assign
        v-cost-vat-pc              = ub.doc-line.vat-pc
        v-cost-slt-pc              = ub.doc-line.slt-pc
      .
      run clcprtsl_calc-line in this-procedure
        (input recid(ub.doc-line)
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при расчете сумм по документу" skip
          "Документ" ub.doc-line.doc-code skip
          "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      find first buf_tt-allsum-line
        where buf_tt-allsum-line.sum-type = 'основная_сумма_со_знаком':U
        no-error .
      if available buf_tt-allsum-line
      then do:
        assign
          v-fact-qnty      = buf_tt-allsum-line.fact-qnty
          v-sum-base       = buf_tt-allsum-line.sum-dsc-base-acc
          v-sum-rubl       = buf_tt-allsum-line.sum-dsc-rubl-acc
          v-vat-base       = buf_tt-allsum-line.vat-base-acc
          v-vat-rubl       = buf_tt-allsum-line.vat-rubl-acc
          v-slt-base       = buf_tt-allsum-line.slt-base-acc
          v-slt-rubl       = buf_tt-allsum-line.slt-rubl-acc
          v-road-tax-base  = buf_tt-allsum-line.road-tax-base-acc
          v-road-tax-rubl  = buf_tt-allsum-line.road-tax-rubl-acc
          v-excise-base    = buf_tt-allsum-line.excise-base-acc
          v-excise-rubl    = buf_tt-allsum-line.excise-rubl-acc
          v-transport-base = buf_tt-allsum-line.transport-base-acc
          v-transport-rubl = buf_tt-allsum-line.transport-rubl-acc
          v-other-base     = buf_tt-allsum-line.other-base-acc
          v-other-rubl     = buf_tt-allsum-line.other-rubl-acc
        .
      end.
      else do:
        assign
          v-fact-qnty      = 0
          v-sum-base       = 0
          v-sum-rubl       = 0
          v-vat-base       = 0
          v-vat-rubl       = 0
          v-slt-base       = 0
          v-slt-rubl       = 0
          v-road-tax-base  = 0
          v-road-tax-rubl  = 0
          v-excise-base    = 0
          v-excise-rubl    = 0
          v-transport-base = 0
          v-transport-rubl = 0
          v-other-base     = 0
          v-other-rubl     = 0
        .
      end.
      if
                              v-fact-qnty      = ? or    v-sum-base       = ? or    v-sum-rubl       = ? or    v-vat-base       = ? or    v-vat-rubl       = ? or    v-slt-base       = ? or    v-slt-rubl       = ? or    v-road-tax-base  = ? or    v-road-tax-rubl  = ? or    v-excise-base    = ? or    v-excise-rubl    = ? or    v-transport-base = ? or    v-transport-rubl = ? or    v-other-base     = ? or    v-other-rubl     = ?
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Программа clcprtsl.i вернула неопределенные значения в учетных ценах по строке" skip
          "Расчет складского архива по товарам невозможен" skip
          "Документ" ub.doc-line.doc-code skip
          "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
                                                                      "v-fact-qnty"      v-fact-qnty        skip    "v-sum-base"       v-sum-base         skip    "v-sum-rubl"       v-sum-rubl         skip    "v-vat-base"       v-vat-base         skip    "v-vat-rubl"       v-vat-rubl         skip    "v-slt-base"       v-slt-base         skip    "v-slt-rubl"       v-slt-rubl         skip    "v-road-tax-base"  v-road-tax-base    skip    "v-road-tax-rubl"  v-road-tax-rubl    skip    "v-excise-base"    v-excise-base      skip    "v-excise-rubl"    v-excise-rubl      skip    "v-transport-base" v-transport-base   skip    "v-transport-rubl" v-transport-rubl   skip    "v-other-base"     v-other-base       skip    "v-other-rubl"     v-other-rubl
          view-as alert-box error .
        undo, return error .
      end.
      assign
        v-sum-type[1] = 'cssr':U
        v-cat-id[1]   = trim(string(v-cost-VAT-pc, ">99")) + "," + trim(string(v-cost-SLT-pc, ">99"))
        ind-ext = 1
      .
      if v-cat-id[1] = ?
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при расчете складского архива по товарам" skip
          "Не заданы налоги для услуг" skip
          "Документ" ub.doc-line.doc-code skip
          "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
          "НДС" v-cost-VAT-pc skip
          "НсП" v-cost-SLT-pc skip
          view-as alert-box error .
        undo, return error .
      end.
      find first temp-ot-line
        where temp-ot-line.doc-code  = ub.doc-line.doc-code
          and temp-ot-line.artic     = ub.doc-line.artic
          and temp-ot-line.prod-type = ub.doc-line.prod-type
          and temp-ot-line.prod-code = ub.doc-line.prod-code
          and temp-ot-line.sum-type  = v-sum-type[ind-ext]
          and temp-ot-line.cat-id    = v-cat-id[ind-ext]
        no-error .
      if not available temp-ot-line
      then do:
        create temp-ot-line .
        assign
          temp-ot-line.doc-code     = ub.doc-line.doc-code
          temp-ot-line.artic        = ub.doc-line.artic
          temp-ot-line.prod-type    = ub.doc-line.prod-type
          temp-ot-line.prod-code    = ub.doc-line.prod-code
          temp-ot-line.sum-type     = v-sum-type[ind-ext]
          temp-ot-line.cat-id       = v-cat-id[ind-ext]
          temp-ot-line.ext-doc-type = ub.trn-doc.ext-doc-type
          temp-ot-line.obj-type     = ub.trn-doc.obj-type
          temp-ot-line.obj-code     = ub.trn-doc.obj-code
          temp-ot-line.fact-order   = v-ot-fact-order
        .
      end.
      assign
                                                                        temp-ot-line.new-fact-qnty      = temp-ot-line.new-fact-qnty      + v-fact-qnty           temp-ot-line.new-sum-base       = temp-ot-line.new-sum-base       + v-sum-base            temp-ot-line.new-sum-rubl       = temp-ot-line.new-sum-rubl       + v-sum-rubl            temp-ot-line.new-vat-base       = temp-ot-line.new-vat-base       + v-vat-base            temp-ot-line.new-vat-rubl       = temp-ot-line.new-vat-rubl       + v-vat-rubl            temp-ot-line.new-slt-base       = temp-ot-line.new-slt-base       + v-slt-base            temp-ot-line.new-slt-rubl       = temp-ot-line.new-slt-rubl       + v-slt-rubl            temp-ot-line.new-road-tax-base  = temp-ot-line.new-road-tax-base  + v-road-tax-base       temp-ot-line.new-road-tax-rubl  = temp-ot-line.new-road-tax-rubl  + v-road-tax-rubl       temp-ot-line.new-excise-base    = temp-ot-line.new-excise-base    + v-excise-base         temp-ot-line.new-excise-rubl    = temp-ot-line.new-excise-rubl    + v-excise-rubl         temp-ot-line.new-transport-base = temp-ot-line.new-transport-base + v-transport-base      temp-ot-line.new-transport-rubl = temp-ot-line.new-transport-rubl + v-transport-rubl      temp-ot-line.new-other-base     = temp-ot-line.new-other-base     + v-other-base          temp-ot-line.new-other-rubl     = temp-ot-line.new-other-rubl     + v-other-rubl
      .
    end.
    define variable v-sale-vat-pc as decimal   no-undo .
    define variable v-sale-slt-pc as decimal   no-undo .
    assign
      v-sale-vat-pc = ub.doc-line.vat-pc
      v-sale-slt-pc = ub.doc-line.slt-pc
    .
    run clcprtsl_calc-line in this-procedure
      (input recid(ub.doc-line)
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при расчете сумм по документу" skip
        "Документ" ub.doc-line.doc-code skip
        "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    find first buf_tt-allsum-line
      where buf_tt-allsum-line.sum-type = 'основная_сумма_со_знаком':U
      no-error .
    if available buf_tt-allsum-line
    then do:
      assign
        v-fact-qnty     = buf_tt-allsum-line.fact-qnty
        v-sum-base      = buf_tt-allsum-line.sum-dsc-base-doc
        v-sum-rubl      = buf_tt-allsum-line.sum-dsc-rubl-doc
        v-vat-base      = buf_tt-allsum-line.vat-base-doc
        v-vat-rubl      = buf_tt-allsum-line.vat-rubl-doc
        v-slt-base      = buf_tt-allsum-line.slt-base-doc
        v-slt-rubl      = buf_tt-allsum-line.slt-rubl-doc
        v-road-tax-base = buf_tt-allsum-line.road-tax-base-doc
        v-road-tax-rubl = buf_tt-allsum-line.road-tax-rubl-doc
        v-excise-base   = buf_tt-allsum-line.excise-base-doc
        v-excise-rubl   = buf_tt-allsum-line.excise-rubl-doc
        v-other-base    = buf_tt-allsum-line.dsc-base-doc
        v-other-rubl    = buf_tt-allsum-line.dsc-rubl-doc
      .
    end.
    else do:
      assign
        v-fact-qnty     = 0
        v-sum-base      = 0
        v-sum-rubl      = 0
        v-vat-base      = 0
        v-vat-rubl      = 0
        v-slt-base      = 0
        v-slt-rubl      = 0
        v-road-tax-base = 0
        v-road-tax-rubl = 0
        v-excise-base   = 0
        v-excise-rubl   = 0
        v-other-base    = 0
        v-other-rubl    = 0
      .
    end.
    if
                    v-fact-qnty      = ? or    v-sum-base       = ? or    v-sum-rubl       = ? or    v-vat-base       = ? or    v-vat-rubl       = ? or    v-slt-base       = ? or    v-slt-rubl       = ? or    v-road-tax-base  = ? or    v-road-tax-rubl  = ? or    v-excise-base    = ? or    v-excise-rubl    = ? or    v-transport-base = ? or    v-transport-rubl = ? or    v-other-base     = ? or    v-other-rubl     = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Программа clcprtsl.i вернула неопределенные значения в ценах по документу" skip
        "Расчет складского архива по товарам невозможен" skip
        "Документ" ub.doc-line.doc-code skip
        "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
                                                        "v-fact-qnty"      v-fact-qnty        skip    "v-sum-base"       v-sum-base         skip    "v-sum-rubl"       v-sum-rubl         skip    "v-vat-base"       v-vat-base         skip    "v-vat-rubl"       v-vat-rubl         skip    "v-slt-base"       v-slt-base         skip    "v-slt-rubl"       v-slt-rubl         skip    "v-road-tax-base"  v-road-tax-base    skip    "v-road-tax-rubl"  v-road-tax-rubl    skip    "v-excise-base"    v-excise-base      skip    "v-excise-rubl"    v-excise-rubl      skip    "v-transport-base" v-transport-base   skip    "v-transport-rubl" v-transport-rubl   skip    "v-other-base"     v-other-base       skip    "v-other-rubl"     v-other-rubl
        view-as alert-box error .
      undo, return error .
    end.
    if ub.goods.gds-type = 'т':U
    then do:
      assign
        v-sum-type[1] = 'sale':U
        v-cat-id[1]   = trim(string(v-sale-VAT-pc, ">99")) + "," + trim(string(v-sale-SLT-pc, ">99"))
        ind-ext = 1
      .
    end.
    else do:
      assign
        v-sum-type[1] = 'sasr':U
        v-cat-id[1]   = trim(string(v-sale-VAT-pc, ">99")) + "," + trim(string(v-sale-SLT-pc, ">99"))
        ind-ext = 1
      .
    end.
    if v-cat-id[1] = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при расчете складского архива по товарам" skip
        "Не заданы налоги в ценах документа" skip
        "Документ" ub.doc-line.doc-code skip
        "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
        "НДС" v-sale-VAT-pc skip
        "НсП" v-sale-SLT-pc skip
        view-as alert-box error .
      undo, return error .
    end.
    find first temp-ot-line
      where temp-ot-line.doc-code  = ub.doc-line.doc-code
        and temp-ot-line.artic     = ub.doc-line.artic
        and temp-ot-line.prod-type = ub.doc-line.prod-type
        and temp-ot-line.prod-code = ub.doc-line.prod-code
        and temp-ot-line.sum-type  = v-sum-type[ind-ext]
        and temp-ot-line.cat-id    = v-cat-id[ind-ext]
      no-error .
    if not available temp-ot-line
    then do:
      create temp-ot-line .
      assign
        temp-ot-line.doc-code     = ub.doc-line.doc-code
        temp-ot-line.artic        = ub.doc-line.artic
        temp-ot-line.prod-type    = ub.doc-line.prod-type
        temp-ot-line.prod-code    = ub.doc-line.prod-code
        temp-ot-line.sum-type     = v-sum-type[ind-ext]
        temp-ot-line.cat-id       = v-cat-id[ind-ext]
        temp-ot-line.ext-doc-type = ub.trn-doc.ext-doc-type
        temp-ot-line.obj-type     = ub.trn-doc.obj-type
        temp-ot-line.obj-code     = ub.trn-doc.obj-code
        temp-ot-line.fact-order   = v-ot-fact-order
      .
    end.
    assign
                                                      temp-ot-line.new-fact-qnty      = temp-ot-line.new-fact-qnty      + v-fact-qnty           temp-ot-line.new-sum-base       = temp-ot-line.new-sum-base       + v-sum-base            temp-ot-line.new-sum-rubl       = temp-ot-line.new-sum-rubl       + v-sum-rubl            temp-ot-line.new-vat-base       = temp-ot-line.new-vat-base       + v-vat-base            temp-ot-line.new-vat-rubl       = temp-ot-line.new-vat-rubl       + v-vat-rubl            temp-ot-line.new-slt-base       = temp-ot-line.new-slt-base       + v-slt-base            temp-ot-line.new-slt-rubl       = temp-ot-line.new-slt-rubl       + v-slt-rubl            temp-ot-line.new-road-tax-base  = temp-ot-line.new-road-tax-base  + v-road-tax-base       temp-ot-line.new-road-tax-rubl  = temp-ot-line.new-road-tax-rubl  + v-road-tax-rubl       temp-ot-line.new-excise-base    = temp-ot-line.new-excise-base    + v-excise-base         temp-ot-line.new-excise-rubl    = temp-ot-line.new-excise-rubl    + v-excise-rubl         temp-ot-line.new-transport-base = temp-ot-line.new-transport-base + v-transport-base      temp-ot-line.new-transport-rubl = temp-ot-line.new-transport-rubl + v-transport-rubl      temp-ot-line.new-other-base     = temp-ot-line.new-other-base     + v-other-base          temp-ot-line.new-other-rubl     = temp-ot-line.new-other-rubl     + v-other-rubl
    .
    define variable v-crsa-vat-pc as decimal   no-undo .
    define variable v-crsa-slt-pc as decimal   no-undo .
    define variable v-b-code     as integer   no-undo .
    define variable v-doc-num    as character no-undo .
    define variable v-price-sale as decimal   no-undo .
    define variable v-road-tax   as decimal   no-undo .
    define variable v-excise     as decimal   no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  ub.goods.gds-code
  ,input  ?
  ,output v-b-code
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при поиске первичного бар-кода товара" skip
        "Документ" ub.doc-line.doc-code skip
        "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcprcex in g#library
  (input  ub.trn-doc.obj-type
  ,input  ub.trn-doc.obj-code
  ,input  v-b-code
  ,input  0
  ,input  ub.trn-doc.fact-order
  ,output v-doc-num
  ,output v-price-sale
  ,output v-road-tax
  ,output v-excise
  ,output v-crsa-VAT-pc
  ,output v-crsa-SLT-pc
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при поиске цены товара" skip
        "Документ" ub.doc-line.doc-code skip
        "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
        "Бар-код" v-b-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if v-doc-num = ?
    then do:
      assign
        v-crsa-vat-pc = 0
        v-crsa-slt-pc = 0
      .
    end.
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  ub.goods.gds-code
  ,input  '1':U
  ,input  ub.trn-doc.fact-date
  ,input  ub.trn-doc.host-code
  ,input  ub.trn-doc.obj-type
  ,input  ub.trn-doc.obj-code
  ,output v-crsa-vat-pc
  ) no-error .
    if v-crsa-vat-pc = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при поиске НДС для товара на дату" skip
        "Документ" ub.trn-doc.doc-code skip
        "Код товара" ub.goods.gds-code skip
        "Артикул" ub.goods.artic ub.goods.prod-type ub.goods.prod-code skip
        "Переоценка" v-doc-num skip
        "Дата" ub.trn-doc.fact-date skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if v-crsa-slt-pc = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при поиске НП для товара на дату" skip
        "Документ" ub.trn-doc.doc-code skip
        "Код товара" ub.goods.gds-code skip
        "Артикул" ub.goods.artic ub.goods.prod-type ub.goods.prod-code skip
        "Переоценка" v-doc-num skip
        "Дата" ub.trn-doc.fact-date skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    find first buf_tt-allsum-line
      where buf_tt-allsum-line.sum-type = 'основная_сумма_со_знаком':U
      no-error .
    if available buf_tt-allsum-line
    then do:
      assign
        v-fact-qnty      = buf_tt-allsum-line.fact-qnty
        v-sum-base       = buf_tt-allsum-line.sum-dsc-base-cur
        v-sum-rubl       = buf_tt-allsum-line.sum-dsc-rubl-cur
        v-vat-base       = buf_tt-allsum-line.vat-base-cur
        v-vat-rubl       = buf_tt-allsum-line.vat-rubl-cur
        v-slt-base       = buf_tt-allsum-line.slt-base-cur
        v-slt-rubl       = buf_tt-allsum-line.slt-rubl-cur
        v-road-tax-base  = buf_tt-allsum-line.road-tax-base-cur
        v-road-tax-rubl  = buf_tt-allsum-line.road-tax-rubl-cur
        v-excise-base    = buf_tt-allsum-line.excise-base-cur
        v-excise-rubl    = buf_tt-allsum-line.excise-rubl-cur
        v-transport-base = 0
        v-transport-rubl = 0
        v-other-base     = 0
        v-other-rubl     = 0
      .
    end.
    else do:
      assign
        v-fact-qnty      = 0
        v-sum-base       = 0
        v-sum-rubl       = 0
        v-vat-base       = 0
        v-vat-rubl       = 0
        v-slt-base       = 0
        v-slt-rubl       = 0
        v-road-tax-base  = 0
        v-road-tax-rubl  = 0
        v-excise-base    = 0
        v-excise-rubl    = 0
        v-transport-base = 0
        v-transport-rubl = 0
        v-other-base     = 0
        v-other-rubl     = 0
      .
    end.
    if
                    v-fact-qnty      = ? or    v-sum-base       = ? or    v-sum-rubl       = ? or    v-vat-base       = ? or    v-vat-rubl       = ? or    v-slt-base       = ? or    v-slt-rubl       = ? or    v-road-tax-base  = ? or    v-road-tax-rubl  = ? or    v-excise-base    = ? or    v-excise-rubl    = ? or    v-transport-base = ? or    v-transport-rubl = ? or    v-other-base     = ? or    v-other-rubl     = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "При расчете складского архива по товарам в продажных ценах clcprtsl.i вернул неопределенные значения" skip
        "Расчет складского архива по товарам невозможен" skip
        "Документ" ub.doc-line.doc-code skip
        "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
                                                        "v-fact-qnty"      v-fact-qnty        skip    "v-sum-base"       v-sum-base         skip    "v-sum-rubl"       v-sum-rubl         skip    "v-vat-base"       v-vat-base         skip    "v-vat-rubl"       v-vat-rubl         skip    "v-slt-base"       v-slt-base         skip    "v-slt-rubl"       v-slt-rubl         skip    "v-road-tax-base"  v-road-tax-base    skip    "v-road-tax-rubl"  v-road-tax-rubl    skip    "v-excise-base"    v-excise-base      skip    "v-excise-rubl"    v-excise-rubl      skip    "v-transport-base" v-transport-base   skip    "v-transport-rubl" v-transport-rubl   skip    "v-other-base"     v-other-base       skip    "v-other-rubl"     v-other-rubl
        view-as alert-box error .
      undo, return error .
    end.
    if ub.goods.gds-type = 'т':U
    then do:
      assign
        v-sum-type[1] = 'crsa':U
        v-cat-id[1]   = trim(string(v-crsa-VAT-pc, ">99")) + "," + trim(string(v-crsa-SLT-pc, ">99"))
        ind-ext = 1
      .
    end.
    else do:
      assign
        v-sum-type[1] = 'cgsr':U
        v-cat-id[1]   = trim(string(v-crsa-VAT-pc, ">99")) + "," + trim(string(v-crsa-SLT-pc, ">99"))
        ind-ext = 1
      .
    end.
    if v-cat-id[1] = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при расчете складского архива по товарам" skip
        "Не заданы налоги в текущих продажных ценах" skip
        "Документ" ub.doc-line.doc-code skip
        "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
        "НДС" v-crsa-VAT-pc skip
        "НсП" v-crsa-SLT-pc skip
        view-as alert-box error .
      undo, return error .
    end.
    find first temp-ot-line
      where temp-ot-line.doc-code  = ub.doc-line.doc-code
        and temp-ot-line.artic     = ub.doc-line.artic
        and temp-ot-line.prod-type = ub.doc-line.prod-type
        and temp-ot-line.prod-code = ub.doc-line.prod-code
        and temp-ot-line.sum-type  = v-sum-type[ind-ext]
        and temp-ot-line.cat-id    = v-cat-id[ind-ext]
      no-error .
    if not available temp-ot-line
    then do:
      create temp-ot-line .
      assign
        temp-ot-line.doc-code     = ub.doc-line.doc-code
        temp-ot-line.artic        = ub.doc-line.artic
        temp-ot-line.prod-type    = ub.doc-line.prod-type
        temp-ot-line.prod-code    = ub.doc-line.prod-code
        temp-ot-line.sum-type     = v-sum-type[ind-ext]
        temp-ot-line.cat-id       = v-cat-id[ind-ext]
        temp-ot-line.ext-doc-type = ub.trn-doc.ext-doc-type
        temp-ot-line.obj-type     = ub.trn-doc.obj-type
        temp-ot-line.obj-code     = ub.trn-doc.obj-code
        temp-ot-line.fact-order   = v-ot-fact-order
      .
    end.
    assign
                                                      temp-ot-line.new-fact-qnty      = temp-ot-line.new-fact-qnty      + v-fact-qnty           temp-ot-line.new-sum-base       = temp-ot-line.new-sum-base       + v-sum-base            temp-ot-line.new-sum-rubl       = temp-ot-line.new-sum-rubl       + v-sum-rubl            temp-ot-line.new-vat-base       = temp-ot-line.new-vat-base       + v-vat-base            temp-ot-line.new-vat-rubl       = temp-ot-line.new-vat-rubl       + v-vat-rubl            temp-ot-line.new-slt-base       = temp-ot-line.new-slt-base       + v-slt-base            temp-ot-line.new-slt-rubl       = temp-ot-line.new-slt-rubl       + v-slt-rubl            temp-ot-line.new-road-tax-base  = temp-ot-line.new-road-tax-base  + v-road-tax-base       temp-ot-line.new-road-tax-rubl  = temp-ot-line.new-road-tax-rubl  + v-road-tax-rubl       temp-ot-line.new-excise-base    = temp-ot-line.new-excise-base    + v-excise-base         temp-ot-line.new-excise-rubl    = temp-ot-line.new-excise-rubl    + v-excise-rubl         temp-ot-line.new-transport-base = temp-ot-line.new-transport-base + v-transport-base      temp-ot-line.new-transport-rubl = temp-ot-line.new-transport-rubl + v-transport-rubl      temp-ot-line.new-other-base     = temp-ot-line.new-other-base     + v-other-base          temp-ot-line.new-other-rubl     = temp-ot-line.new-other-rubl     + v-other-rubl
    .
  end.
end procedure.
procedure update-ot-tot :
  do
  on error undo, return error
  :
    for each temp-ot-line
      where (
                                          temp-ot-line.fact-qnty      <> temp-ot-line.new-fact-qnty        or    temp-ot-line.sum-base       <> temp-ot-line.new-sum-base         or    temp-ot-line.sum-rubl       <> temp-ot-line.new-sum-rubl         or    temp-ot-line.vat-base       <> temp-ot-line.new-vat-base         or    temp-ot-line.vat-rubl       <> temp-ot-line.new-vat-rubl         or    temp-ot-line.slt-base       <> temp-ot-line.new-slt-base         or    temp-ot-line.slt-rubl       <> temp-ot-line.new-slt-rubl         or    temp-ot-line.road-tax-base  <> temp-ot-line.new-road-tax-base    or    temp-ot-line.road-tax-rubl  <> temp-ot-line.new-road-tax-rubl    or    temp-ot-line.excise-base    <> temp-ot-line.new-excise-base      or    temp-ot-line.excise-rubl    <> temp-ot-line.new-excise-rubl      or    temp-ot-line.transport-base <> temp-ot-line.new-transport-base   or    temp-ot-line.transport-rubl <> temp-ot-line.new-transport-rubl   or    temp-ot-line.other-base     <> temp-ot-line.new-other-base       or    temp-ot-line.other-rubl     <> temp-ot-line.new-other-rubl
            )
    on error undo, return error
    :
      if temp-ot-line.sum-type begins 'cost':U
      then do:
        find first temp-ot-tot
          where temp-ot-tot.doc-code = temp-ot-line.doc-code
            and temp-ot-tot.sum-type = temp-ot-line.sum-type
            and temp-ot-tot.cat-id   = temp-ot-line.cat-id
          no-error .
        if not available temp-ot-tot
        then do:
          create temp-ot-tot .
          assign
            temp-ot-tot.doc-code     = temp-ot-line.doc-code
            temp-ot-tot.sum-type     = temp-ot-line.sum-type
            temp-ot-tot.cat-id       = temp-ot-line.cat-id
            temp-ot-tot.ext-doc-type = ub.trn-doc.ext-doc-type
            temp-ot-tot.obj-type     = ub.trn-doc.obj-type
            temp-ot-tot.obj-code     = ub.trn-doc.obj-code
            temp-ot-tot.fact-order   = v-ot-fact-order
          .
        end.
        assign
                                                                                                              temp-ot-tot.new-fact-qnty      = temp-ot-tot.new-fact-qnty      + temp-ot-line.new-fact-qnty      - temp-ot-line.fact-qnty           temp-ot-tot.new-sum-base       = temp-ot-tot.new-sum-base       + temp-ot-line.new-sum-base       - temp-ot-line.sum-base            temp-ot-tot.new-sum-rubl       = temp-ot-tot.new-sum-rubl       + temp-ot-line.new-sum-rubl       - temp-ot-line.sum-rubl            temp-ot-tot.new-vat-base       = temp-ot-tot.new-vat-base       + temp-ot-line.new-vat-base       - temp-ot-line.vat-base            temp-ot-tot.new-vat-rubl       = temp-ot-tot.new-vat-rubl       + temp-ot-line.new-vat-rubl       - temp-ot-line.vat-rubl            temp-ot-tot.new-slt-base       = temp-ot-tot.new-slt-base       + temp-ot-line.new-slt-base       - temp-ot-line.slt-base            temp-ot-tot.new-slt-rubl       = temp-ot-tot.new-slt-rubl       + temp-ot-line.new-slt-rubl       - temp-ot-line.slt-rubl            temp-ot-tot.new-road-tax-base  = temp-ot-tot.new-road-tax-base  + temp-ot-line.new-road-tax-base  - temp-ot-line.road-tax-base       temp-ot-tot.new-road-tax-rubl  = temp-ot-tot.new-road-tax-rubl  + temp-ot-line.new-road-tax-rubl  - temp-ot-line.road-tax-rubl       temp-ot-tot.new-excise-base    = temp-ot-tot.new-excise-base    + temp-ot-line.new-excise-base    - temp-ot-line.excise-base         temp-ot-tot.new-excise-rubl    = temp-ot-tot.new-excise-rubl    + temp-ot-line.new-excise-rubl    - temp-ot-line.excise-rubl         temp-ot-tot.new-transport-base = temp-ot-tot.new-transport-base + temp-ot-line.new-transport-base - temp-ot-line.transport-base      temp-ot-tot.new-transport-rubl = temp-ot-tot.new-transport-rubl + temp-ot-line.new-transport-rubl - temp-ot-line.transport-rubl      temp-ot-tot.new-other-base     = temp-ot-tot.new-other-base     + temp-ot-line.new-other-base     - temp-ot-line.other-base          temp-ot-tot.new-other-rubl     = temp-ot-tot.new-other-rubl     + temp-ot-line.new-other-rubl     - temp-ot-line.other-rubl
        .
      end.
      if temp-ot-line.sum-type = 'crsa':U
      or temp-ot-line.sum-type = 'sale':U
      or temp-ot-line.sum-type = 'sasr':U
      or temp-ot-line.sum-type = 'cgsr':U
      or temp-ot-line.sum-type = 'cssr':U
      then do:
        assign
          v-sum-type[1] = temp-ot-line.sum-type
          v-cat-id[1]   = '##,##':U
          v-sum-type[2] = temp-ot-line.sum-type + 'v':U
          v-cat-id[2]   = entry(1, temp-ot-line.cat-id) + "," + '##':U
          v-sum-type[3] = temp-ot-line.sum-type + 's':U
          v-cat-id[3]   = '##':U + "," + entry(2, temp-ot-line.cat-id)
          v-sum-type[4] = temp-ot-line.sum-type + 'x':U
          v-cat-id[4]   = temp-ot-line.cat-id
        .
        do ind-ext = 1 to 4
        :
          find first temp-ot-tot
            where temp-ot-tot.doc-code = temp-ot-line.doc-code
              and temp-ot-tot.sum-type = v-sum-type[ind-ext]
              and temp-ot-tot.cat-id   = v-cat-id[ind-ext]
            no-error .
          if not available temp-ot-tot
          then do:
            create temp-ot-tot .
            assign
              temp-ot-tot.doc-code = temp-ot-line.doc-code
              temp-ot-tot.sum-type = v-sum-type[ind-ext]
              temp-ot-tot.cat-id   = v-cat-id[ind-ext]
              temp-ot-tot.ext-doc-type = ub.trn-doc.ext-doc-type
              temp-ot-tot.obj-type     = ub.trn-doc.obj-type
              temp-ot-tot.obj-code     = ub.trn-doc.obj-code
              temp-ot-tot.fact-order   = v-ot-fact-order
            .
          end.
          assign
                                                                                                                                    temp-ot-tot.new-fact-qnty      = temp-ot-tot.new-fact-qnty      + temp-ot-line.new-fact-qnty      - temp-ot-line.fact-qnty           temp-ot-tot.new-sum-base       = temp-ot-tot.new-sum-base       + temp-ot-line.new-sum-base       - temp-ot-line.sum-base            temp-ot-tot.new-sum-rubl       = temp-ot-tot.new-sum-rubl       + temp-ot-line.new-sum-rubl       - temp-ot-line.sum-rubl            temp-ot-tot.new-vat-base       = temp-ot-tot.new-vat-base       + temp-ot-line.new-vat-base       - temp-ot-line.vat-base            temp-ot-tot.new-vat-rubl       = temp-ot-tot.new-vat-rubl       + temp-ot-line.new-vat-rubl       - temp-ot-line.vat-rubl            temp-ot-tot.new-slt-base       = temp-ot-tot.new-slt-base       + temp-ot-line.new-slt-base       - temp-ot-line.slt-base            temp-ot-tot.new-slt-rubl       = temp-ot-tot.new-slt-rubl       + temp-ot-line.new-slt-rubl       - temp-ot-line.slt-rubl            temp-ot-tot.new-road-tax-base  = temp-ot-tot.new-road-tax-base  + temp-ot-line.new-road-tax-base  - temp-ot-line.road-tax-base       temp-ot-tot.new-road-tax-rubl  = temp-ot-tot.new-road-tax-rubl  + temp-ot-line.new-road-tax-rubl  - temp-ot-line.road-tax-rubl       temp-ot-tot.new-excise-base    = temp-ot-tot.new-excise-base    + temp-ot-line.new-excise-base    - temp-ot-line.excise-base         temp-ot-tot.new-excise-rubl    = temp-ot-tot.new-excise-rubl    + temp-ot-line.new-excise-rubl    - temp-ot-line.excise-rubl         temp-ot-tot.new-transport-base = temp-ot-tot.new-transport-base + temp-ot-line.new-transport-base - temp-ot-line.transport-base      temp-ot-tot.new-transport-rubl = temp-ot-tot.new-transport-rubl + temp-ot-line.new-transport-rubl - temp-ot-line.transport-rubl      temp-ot-tot.new-other-base     = temp-ot-tot.new-other-base     + temp-ot-line.new-other-base     - temp-ot-line.other-base          temp-ot-tot.new-other-rubl     = temp-ot-tot.new-other-rubl     + temp-ot-line.new-other-rubl     - temp-ot-line.other-rubl
          .
        end.
      end.
    end.
  end.
end procedure.
procedure update-stk-table :
  do
  on error undo, return error
  :
    define buffer root-temp-stk-tot  for temp-stk-tot  .
    define buffer root-temp-stk-line for temp-stk-line .
    define buffer root-temp-shift-stk-tot  for temp-shift-stk-tot  .
    define buffer root-temp-shift-stk-line for temp-shift-stk-line .
    for each temp-ot-tot
      where temp-ot-tot.sum-type begins 'crsa':U
        and (
                                          temp-ot-tot.fact-qnty      <> temp-ot-tot.new-fact-qnty        or    temp-ot-tot.sum-base       <> temp-ot-tot.new-sum-base         or    temp-ot-tot.sum-rubl       <> temp-ot-tot.new-sum-rubl         or    temp-ot-tot.vat-base       <> temp-ot-tot.new-vat-base         or    temp-ot-tot.vat-rubl       <> temp-ot-tot.new-vat-rubl         or    temp-ot-tot.slt-base       <> temp-ot-tot.new-slt-base         or    temp-ot-tot.slt-rubl       <> temp-ot-tot.new-slt-rubl         or    temp-ot-tot.road-tax-base  <> temp-ot-tot.new-road-tax-base    or    temp-ot-tot.road-tax-rubl  <> temp-ot-tot.new-road-tax-rubl    or    temp-ot-tot.excise-base    <> temp-ot-tot.new-excise-base      or    temp-ot-tot.excise-rubl    <> temp-ot-tot.new-excise-rubl      or    temp-ot-tot.transport-base <> temp-ot-tot.new-transport-base   or    temp-ot-tot.transport-rubl <> temp-ot-tot.new-transport-rubl   or    temp-ot-tot.other-base     <> temp-ot-tot.new-other-base       or    temp-ot-tot.other-rubl     <> temp-ot-tot.new-other-rubl
            )
    on error undo, return error
    :
      for each root-temp-stk-tot
        where root-temp-stk-tot.obj-type = temp-ot-tot.obj-type
          and root-temp-stk-tot.obj-code = temp-ot-tot.obj-code
          and root-temp-stk-tot.sum-type = 'crsa':U
          and root-temp-stk-tot.cat-id   = '##,##':U
      on error undo, return error
      :
        find first temp-stk-tot
          where temp-stk-tot.obj-type   = temp-ot-tot.obj-type
            and temp-stk-tot.obj-code   = temp-ot-tot.obj-code
            and temp-stk-tot.fact-order = root-temp-stk-tot.fact-order
            and temp-stk-tot.sum-type   = temp-ot-tot.sum-type
            and temp-stk-tot.cat-id     = temp-ot-tot.cat-id
          no-error .
        if not available temp-stk-tot
        then do:
          create temp-stk-tot .
          assign
            temp-stk-tot.obj-type   = temp-ot-tot.obj-type
            temp-stk-tot.obj-code   = temp-ot-tot.obj-code
            temp-stk-tot.fact-order = root-temp-stk-tot.fact-order
            temp-stk-tot.sum-type   = temp-ot-tot.sum-type
            temp-stk-tot.cat-id     = temp-ot-tot.cat-id
            temp-stk-tot.fact-date  = root-temp-stk-tot.fact-date
            temp-stk-tot.shift-num  = root-temp-stk-tot.shift-num
            temp-stk-tot.shift-date = root-temp-stk-tot.shift-date
          .
        end.
        assign
                                                                                                              temp-stk-tot.new-fact-qnty      = temp-stk-tot.new-fact-qnty      + temp-ot-tot.new-fact-qnty      - temp-ot-tot.fact-qnty           temp-stk-tot.new-sum-base       = temp-stk-tot.new-sum-base       + temp-ot-tot.new-sum-base       - temp-ot-tot.sum-base            temp-stk-tot.new-sum-rubl       = temp-stk-tot.new-sum-rubl       + temp-ot-tot.new-sum-rubl       - temp-ot-tot.sum-rubl            temp-stk-tot.new-vat-base       = temp-stk-tot.new-vat-base       + temp-ot-tot.new-vat-base       - temp-ot-tot.vat-base            temp-stk-tot.new-vat-rubl       = temp-stk-tot.new-vat-rubl       + temp-ot-tot.new-vat-rubl       - temp-ot-tot.vat-rubl            temp-stk-tot.new-slt-base       = temp-stk-tot.new-slt-base       + temp-ot-tot.new-slt-base       - temp-ot-tot.slt-base            temp-stk-tot.new-slt-rubl       = temp-stk-tot.new-slt-rubl       + temp-ot-tot.new-slt-rubl       - temp-ot-tot.slt-rubl            temp-stk-tot.new-road-tax-base  = temp-stk-tot.new-road-tax-base  + temp-ot-tot.new-road-tax-base  - temp-ot-tot.road-tax-base       temp-stk-tot.new-road-tax-rubl  = temp-stk-tot.new-road-tax-rubl  + temp-ot-tot.new-road-tax-rubl  - temp-ot-tot.road-tax-rubl       temp-stk-tot.new-excise-base    = temp-stk-tot.new-excise-base    + temp-ot-tot.new-excise-base    - temp-ot-tot.excise-base         temp-stk-tot.new-excise-rubl    = temp-stk-tot.new-excise-rubl    + temp-ot-tot.new-excise-rubl    - temp-ot-tot.excise-rubl         temp-stk-tot.new-transport-base = temp-stk-tot.new-transport-base + temp-ot-tot.new-transport-base - temp-ot-tot.transport-base      temp-stk-tot.new-transport-rubl = temp-stk-tot.new-transport-rubl + temp-ot-tot.new-transport-rubl - temp-ot-tot.transport-rubl      temp-stk-tot.new-other-base     = temp-stk-tot.new-other-base     + temp-ot-tot.new-other-base     - temp-ot-tot.other-base          temp-stk-tot.new-other-rubl     = temp-stk-tot.new-other-rubl     + temp-ot-tot.new-other-rubl     - temp-ot-tot.other-rubl
        .
      end.
      if v-shift-on
      then do:
        for each root-temp-shift-stk-tot
          where root-temp-shift-stk-tot.obj-type = temp-ot-tot.obj-type
            and root-temp-shift-stk-tot.obj-code = temp-ot-tot.obj-code
            and root-temp-shift-stk-tot.sum-type = 'crsa':U
            and root-temp-shift-stk-tot.cat-id   = '##,##':U
        on error undo, return error
        :
          find first temp-shift-stk-tot
            where temp-shift-stk-tot.obj-type   = temp-ot-tot.obj-type
              and temp-shift-stk-tot.obj-code   = temp-ot-tot.obj-code
              and temp-shift-stk-tot.fact-order = root-temp-shift-stk-tot.fact-order
              and temp-shift-stk-tot.sum-type   = temp-ot-tot.sum-type
              and temp-shift-stk-tot.cat-id     = temp-ot-tot.cat-id
            no-error .
          if not available temp-shift-stk-tot
          then do:
            create temp-shift-stk-tot .
            assign
              temp-shift-stk-tot.obj-type   = temp-ot-tot.obj-type
              temp-shift-stk-tot.obj-code   = temp-ot-tot.obj-code
              temp-shift-stk-tot.fact-order = root-temp-shift-stk-tot.fact-order
              temp-shift-stk-tot.sum-type   = temp-ot-tot.sum-type
              temp-shift-stk-tot.cat-id     = temp-ot-tot.cat-id
              temp-shift-stk-tot.fact-date  = root-temp-shift-stk-tot.fact-date
              temp-shift-stk-tot.shift-num  = root-temp-shift-stk-tot.shift-num
              temp-shift-stk-tot.shift-date = root-temp-shift-stk-tot.shift-date
            .
          end.
          assign
                                                                                                                                    temp-shift-stk-tot.new-fact-qnty      = temp-shift-stk-tot.new-fact-qnty      + temp-ot-tot.new-fact-qnty      - temp-ot-tot.fact-qnty           temp-shift-stk-tot.new-sum-base       = temp-shift-stk-tot.new-sum-base       + temp-ot-tot.new-sum-base       - temp-ot-tot.sum-base            temp-shift-stk-tot.new-sum-rubl       = temp-shift-stk-tot.new-sum-rubl       + temp-ot-tot.new-sum-rubl       - temp-ot-tot.sum-rubl            temp-shift-stk-tot.new-vat-base       = temp-shift-stk-tot.new-vat-base       + temp-ot-tot.new-vat-base       - temp-ot-tot.vat-base            temp-shift-stk-tot.new-vat-rubl       = temp-shift-stk-tot.new-vat-rubl       + temp-ot-tot.new-vat-rubl       - temp-ot-tot.vat-rubl            temp-shift-stk-tot.new-slt-base       = temp-shift-stk-tot.new-slt-base       + temp-ot-tot.new-slt-base       - temp-ot-tot.slt-base            temp-shift-stk-tot.new-slt-rubl       = temp-shift-stk-tot.new-slt-rubl       + temp-ot-tot.new-slt-rubl       - temp-ot-tot.slt-rubl            temp-shift-stk-tot.new-road-tax-base  = temp-shift-stk-tot.new-road-tax-base  + temp-ot-tot.new-road-tax-base  - temp-ot-tot.road-tax-base       temp-shift-stk-tot.new-road-tax-rubl  = temp-shift-stk-tot.new-road-tax-rubl  + temp-ot-tot.new-road-tax-rubl  - temp-ot-tot.road-tax-rubl       temp-shift-stk-tot.new-excise-base    = temp-shift-stk-tot.new-excise-base    + temp-ot-tot.new-excise-base    - temp-ot-tot.excise-base         temp-shift-stk-tot.new-excise-rubl    = temp-shift-stk-tot.new-excise-rubl    + temp-ot-tot.new-excise-rubl    - temp-ot-tot.excise-rubl         temp-shift-stk-tot.new-transport-base = temp-shift-stk-tot.new-transport-base + temp-ot-tot.new-transport-base - temp-ot-tot.transport-base      temp-shift-stk-tot.new-transport-rubl = temp-shift-stk-tot.new-transport-rubl + temp-ot-tot.new-transport-rubl - temp-ot-tot.transport-rubl      temp-shift-stk-tot.new-other-base     = temp-shift-stk-tot.new-other-base     + temp-ot-tot.new-other-base     - temp-ot-tot.other-base          temp-shift-stk-tot.new-other-rubl     = temp-shift-stk-tot.new-other-rubl     + temp-ot-tot.new-other-rubl     - temp-ot-tot.other-rubl
          .
        end.
      end.
    end.
    for each temp-ot-tot
      where temp-ot-tot.sum-type begins 'cost':U
        and (
                                          temp-ot-tot.fact-qnty      <> temp-ot-tot.new-fact-qnty        or    temp-ot-tot.sum-base       <> temp-ot-tot.new-sum-base         or    temp-ot-tot.sum-rubl       <> temp-ot-tot.new-sum-rubl         or    temp-ot-tot.vat-base       <> temp-ot-tot.new-vat-base         or    temp-ot-tot.vat-rubl       <> temp-ot-tot.new-vat-rubl         or    temp-ot-tot.slt-base       <> temp-ot-tot.new-slt-base         or    temp-ot-tot.slt-rubl       <> temp-ot-tot.new-slt-rubl         or    temp-ot-tot.road-tax-base  <> temp-ot-tot.new-road-tax-base    or    temp-ot-tot.road-tax-rubl  <> temp-ot-tot.new-road-tax-rubl    or    temp-ot-tot.excise-base    <> temp-ot-tot.new-excise-base      or    temp-ot-tot.excise-rubl    <> temp-ot-tot.new-excise-rubl      or    temp-ot-tot.transport-base <> temp-ot-tot.new-transport-base   or    temp-ot-tot.transport-rubl <> temp-ot-tot.new-transport-rubl   or    temp-ot-tot.other-base     <> temp-ot-tot.new-other-base       or    temp-ot-tot.other-rubl     <> temp-ot-tot.new-other-rubl
            )
    on error undo, return error
    :
      for each root-temp-stk-tot
        where root-temp-stk-tot.obj-type = temp-ot-tot.obj-type
          and root-temp-stk-tot.obj-code = temp-ot-tot.obj-code
          and root-temp-stk-tot.sum-type = 'cost':U
          and root-temp-stk-tot.cat-id   = '##,##':U
      on error undo, return error
      :
        find first temp-stk-tot
          where temp-stk-tot.obj-type   = temp-ot-tot.obj-type
            and temp-stk-tot.obj-code   = temp-ot-tot.obj-code
            and temp-stk-tot.fact-order = root-temp-stk-tot.fact-order
            and temp-stk-tot.sum-type   = temp-ot-tot.sum-type
            and temp-stk-tot.cat-id     = temp-ot-tot.cat-id
          no-error .
        if not available temp-stk-tot
        then do:
          create temp-stk-tot .
          assign
            temp-stk-tot.obj-type   = temp-ot-tot.obj-type
            temp-stk-tot.obj-code   = temp-ot-tot.obj-code
            temp-stk-tot.fact-order = root-temp-stk-tot.fact-order
            temp-stk-tot.sum-type   = temp-ot-tot.sum-type
            temp-stk-tot.cat-id     = temp-ot-tot.cat-id
            temp-stk-tot.fact-date  = root-temp-stk-tot.fact-date
            temp-stk-tot.shift-num  = root-temp-stk-tot.shift-num
            temp-stk-tot.shift-date = root-temp-stk-tot.shift-date
          .
        end.
        assign
                                                                                                              temp-stk-tot.new-fact-qnty      = temp-stk-tot.new-fact-qnty      + temp-ot-tot.new-fact-qnty      - temp-ot-tot.fact-qnty           temp-stk-tot.new-sum-base       = temp-stk-tot.new-sum-base       + temp-ot-tot.new-sum-base       - temp-ot-tot.sum-base            temp-stk-tot.new-sum-rubl       = temp-stk-tot.new-sum-rubl       + temp-ot-tot.new-sum-rubl       - temp-ot-tot.sum-rubl            temp-stk-tot.new-vat-base       = temp-stk-tot.new-vat-base       + temp-ot-tot.new-vat-base       - temp-ot-tot.vat-base            temp-stk-tot.new-vat-rubl       = temp-stk-tot.new-vat-rubl       + temp-ot-tot.new-vat-rubl       - temp-ot-tot.vat-rubl            temp-stk-tot.new-slt-base       = temp-stk-tot.new-slt-base       + temp-ot-tot.new-slt-base       - temp-ot-tot.slt-base            temp-stk-tot.new-slt-rubl       = temp-stk-tot.new-slt-rubl       + temp-ot-tot.new-slt-rubl       - temp-ot-tot.slt-rubl            temp-stk-tot.new-road-tax-base  = temp-stk-tot.new-road-tax-base  + temp-ot-tot.new-road-tax-base  - temp-ot-tot.road-tax-base       temp-stk-tot.new-road-tax-rubl  = temp-stk-tot.new-road-tax-rubl  + temp-ot-tot.new-road-tax-rubl  - temp-ot-tot.road-tax-rubl       temp-stk-tot.new-excise-base    = temp-stk-tot.new-excise-base    + temp-ot-tot.new-excise-base    - temp-ot-tot.excise-base         temp-stk-tot.new-excise-rubl    = temp-stk-tot.new-excise-rubl    + temp-ot-tot.new-excise-rubl    - temp-ot-tot.excise-rubl         temp-stk-tot.new-transport-base = temp-stk-tot.new-transport-base + temp-ot-tot.new-transport-base - temp-ot-tot.transport-base      temp-stk-tot.new-transport-rubl = temp-stk-tot.new-transport-rubl + temp-ot-tot.new-transport-rubl - temp-ot-tot.transport-rubl      temp-stk-tot.new-other-base     = temp-stk-tot.new-other-base     + temp-ot-tot.new-other-base     - temp-ot-tot.other-base          temp-stk-tot.new-other-rubl     = temp-stk-tot.new-other-rubl     + temp-ot-tot.new-other-rubl     - temp-ot-tot.other-rubl
        .
      end.
      if v-shift-on
      then do:
        for each root-temp-shift-stk-tot
          where root-temp-shift-stk-tot.obj-type = temp-ot-tot.obj-type
            and root-temp-shift-stk-tot.obj-code = temp-ot-tot.obj-code
            and root-temp-shift-stk-tot.sum-type = 'cost':U
            and root-temp-shift-stk-tot.cat-id   = '##,##':U
        on error undo, return error
        :
          find first temp-shift-stk-tot
            where temp-shift-stk-tot.obj-type   = temp-ot-tot.obj-type
              and temp-shift-stk-tot.obj-code   = temp-ot-tot.obj-code
              and temp-shift-stk-tot.fact-order = root-temp-shift-stk-tot.fact-order
              and temp-shift-stk-tot.sum-type   = temp-ot-tot.sum-type
              and temp-shift-stk-tot.cat-id     = temp-ot-tot.cat-id
            no-error .
          if not available temp-shift-stk-tot
          then do:
            create temp-shift-stk-tot .
            assign
              temp-shift-stk-tot.obj-type   = temp-ot-tot.obj-type
              temp-shift-stk-tot.obj-code   = temp-ot-tot.obj-code
              temp-shift-stk-tot.fact-order = root-temp-shift-stk-tot.fact-order
              temp-shift-stk-tot.sum-type   = temp-ot-tot.sum-type
              temp-shift-stk-tot.cat-id     = temp-ot-tot.cat-id
              temp-shift-stk-tot.fact-date  = root-temp-shift-stk-tot.fact-date
              temp-shift-stk-tot.shift-num  = root-temp-shift-stk-tot.shift-num
              temp-shift-stk-tot.shift-date = root-temp-shift-stk-tot.shift-date
            .
          end.
          assign
                                                                                                                                    temp-shift-stk-tot.new-fact-qnty      = temp-shift-stk-tot.new-fact-qnty      + temp-ot-tot.new-fact-qnty      - temp-ot-tot.fact-qnty           temp-shift-stk-tot.new-sum-base       = temp-shift-stk-tot.new-sum-base       + temp-ot-tot.new-sum-base       - temp-ot-tot.sum-base            temp-shift-stk-tot.new-sum-rubl       = temp-shift-stk-tot.new-sum-rubl       + temp-ot-tot.new-sum-rubl       - temp-ot-tot.sum-rubl            temp-shift-stk-tot.new-vat-base       = temp-shift-stk-tot.new-vat-base       + temp-ot-tot.new-vat-base       - temp-ot-tot.vat-base            temp-shift-stk-tot.new-vat-rubl       = temp-shift-stk-tot.new-vat-rubl       + temp-ot-tot.new-vat-rubl       - temp-ot-tot.vat-rubl            temp-shift-stk-tot.new-slt-base       = temp-shift-stk-tot.new-slt-base       + temp-ot-tot.new-slt-base       - temp-ot-tot.slt-base            temp-shift-stk-tot.new-slt-rubl       = temp-shift-stk-tot.new-slt-rubl       + temp-ot-tot.new-slt-rubl       - temp-ot-tot.slt-rubl            temp-shift-stk-tot.new-road-tax-base  = temp-shift-stk-tot.new-road-tax-base  + temp-ot-tot.new-road-tax-base  - temp-ot-tot.road-tax-base       temp-shift-stk-tot.new-road-tax-rubl  = temp-shift-stk-tot.new-road-tax-rubl  + temp-ot-tot.new-road-tax-rubl  - temp-ot-tot.road-tax-rubl       temp-shift-stk-tot.new-excise-base    = temp-shift-stk-tot.new-excise-base    + temp-ot-tot.new-excise-base    - temp-ot-tot.excise-base         temp-shift-stk-tot.new-excise-rubl    = temp-shift-stk-tot.new-excise-rubl    + temp-ot-tot.new-excise-rubl    - temp-ot-tot.excise-rubl         temp-shift-stk-tot.new-transport-base = temp-shift-stk-tot.new-transport-base + temp-ot-tot.new-transport-base - temp-ot-tot.transport-base      temp-shift-stk-tot.new-transport-rubl = temp-shift-stk-tot.new-transport-rubl + temp-ot-tot.new-transport-rubl - temp-ot-tot.transport-rubl      temp-shift-stk-tot.new-other-base     = temp-shift-stk-tot.new-other-base     + temp-ot-tot.new-other-base     - temp-ot-tot.other-base          temp-shift-stk-tot.new-other-rubl     = temp-shift-stk-tot.new-other-rubl     + temp-ot-tot.new-other-rubl     - temp-ot-tot.other-rubl
          .
        end.
      end.
    end.
    for each temp-ot-tot
      where temp-ot-tot.sum-type = 'sale':U
        and (
                                          temp-ot-tot.fact-qnty      <> temp-ot-tot.new-fact-qnty        or    temp-ot-tot.sum-base       <> temp-ot-tot.new-sum-base         or    temp-ot-tot.sum-rubl       <> temp-ot-tot.new-sum-rubl         or    temp-ot-tot.vat-base       <> temp-ot-tot.new-vat-base         or    temp-ot-tot.vat-rubl       <> temp-ot-tot.new-vat-rubl         or    temp-ot-tot.slt-base       <> temp-ot-tot.new-slt-base         or    temp-ot-tot.slt-rubl       <> temp-ot-tot.new-slt-rubl         or    temp-ot-tot.road-tax-base  <> temp-ot-tot.new-road-tax-base    or    temp-ot-tot.road-tax-rubl  <> temp-ot-tot.new-road-tax-rubl    or    temp-ot-tot.excise-base    <> temp-ot-tot.new-excise-base      or    temp-ot-tot.excise-rubl    <> temp-ot-tot.new-excise-rubl      or    temp-ot-tot.transport-base <> temp-ot-tot.new-transport-base   or    temp-ot-tot.transport-rubl <> temp-ot-tot.new-transport-rubl   or    temp-ot-tot.other-base     <> temp-ot-tot.new-other-base       or    temp-ot-tot.other-rubl     <> temp-ot-tot.new-other-rubl
            )
    on error undo, return error
    :
      for each root-temp-stk-tot
        where root-temp-stk-tot.obj-type = temp-ot-tot.obj-type
          and root-temp-stk-tot.obj-code = temp-ot-tot.obj-code
          and root-temp-stk-tot.sum-type = 'sadt':U + ub.trn-doc.ext-doc-type
          and root-temp-stk-tot.cat-id   = '##,##':U
      on error undo, return error
      :
        find first temp-stk-tot
          where temp-stk-tot.obj-type   = temp-ot-tot.obj-type
            and temp-stk-tot.obj-code   = temp-ot-tot.obj-code
            and temp-stk-tot.fact-order = root-temp-stk-tot.fact-order
            and temp-stk-tot.sum-type   = root-temp-stk-tot.sum-type
            and temp-stk-tot.cat-id     = '##,##':U
          no-error .
        if not available temp-stk-tot
        then do:
          create temp-stk-tot .
          assign
            temp-stk-tot.obj-type   = temp-ot-tot.obj-type
            temp-stk-tot.obj-code   = temp-ot-tot.obj-code
            temp-stk-tot.fact-order = root-temp-stk-tot.fact-order
            temp-stk-tot.sum-type   = root-temp-stk-tot.sum-type
            temp-stk-tot.cat-id     = '##,##':U
            temp-stk-tot.fact-date  = root-temp-stk-tot.fact-date
            temp-stk-tot.shift-num  = root-temp-stk-tot.shift-num
            temp-stk-tot.shift-date = root-temp-stk-tot.shift-date
          .
        end.
        assign
                                                                                                              temp-stk-tot.new-fact-qnty      = temp-stk-tot.new-fact-qnty      + temp-ot-tot.new-fact-qnty      - temp-ot-tot.fact-qnty           temp-stk-tot.new-sum-base       = temp-stk-tot.new-sum-base       + temp-ot-tot.new-sum-base       - temp-ot-tot.sum-base            temp-stk-tot.new-sum-rubl       = temp-stk-tot.new-sum-rubl       + temp-ot-tot.new-sum-rubl       - temp-ot-tot.sum-rubl            temp-stk-tot.new-vat-base       = temp-stk-tot.new-vat-base       + temp-ot-tot.new-vat-base       - temp-ot-tot.vat-base            temp-stk-tot.new-vat-rubl       = temp-stk-tot.new-vat-rubl       + temp-ot-tot.new-vat-rubl       - temp-ot-tot.vat-rubl            temp-stk-tot.new-slt-base       = temp-stk-tot.new-slt-base       + temp-ot-tot.new-slt-base       - temp-ot-tot.slt-base            temp-stk-tot.new-slt-rubl       = temp-stk-tot.new-slt-rubl       + temp-ot-tot.new-slt-rubl       - temp-ot-tot.slt-rubl            temp-stk-tot.new-road-tax-base  = temp-stk-tot.new-road-tax-base  + temp-ot-tot.new-road-tax-base  - temp-ot-tot.road-tax-base       temp-stk-tot.new-road-tax-rubl  = temp-stk-tot.new-road-tax-rubl  + temp-ot-tot.new-road-tax-rubl  - temp-ot-tot.road-tax-rubl       temp-stk-tot.new-excise-base    = temp-stk-tot.new-excise-base    + temp-ot-tot.new-excise-base    - temp-ot-tot.excise-base         temp-stk-tot.new-excise-rubl    = temp-stk-tot.new-excise-rubl    + temp-ot-tot.new-excise-rubl    - temp-ot-tot.excise-rubl         temp-stk-tot.new-transport-base = temp-stk-tot.new-transport-base + temp-ot-tot.new-transport-base - temp-ot-tot.transport-base      temp-stk-tot.new-transport-rubl = temp-stk-tot.new-transport-rubl + temp-ot-tot.new-transport-rubl - temp-ot-tot.transport-rubl      temp-stk-tot.new-other-base     = temp-stk-tot.new-other-base     + temp-ot-tot.new-other-base     - temp-ot-tot.other-base          temp-stk-tot.new-other-rubl     = temp-stk-tot.new-other-rubl     + temp-ot-tot.new-other-rubl     - temp-ot-tot.other-rubl
        .
      end.
      if v-shift-on
      then do:
        for each root-temp-shift-stk-tot
          where root-temp-shift-stk-tot.obj-type = temp-ot-tot.obj-type
            and root-temp-shift-stk-tot.obj-code = temp-ot-tot.obj-code
            and root-temp-shift-stk-tot.sum-type = 'sadt':U + ub.trn-doc.ext-doc-type
            and root-temp-shift-stk-tot.cat-id   = '##,##':U
        on error undo, return error
        :
          find first temp-shift-stk-tot
            where temp-shift-stk-tot.obj-type   = temp-ot-tot.obj-type
              and temp-shift-stk-tot.obj-code   = temp-ot-tot.obj-code
              and temp-shift-stk-tot.fact-order = root-temp-shift-stk-tot.fact-order
              and temp-shift-stk-tot.sum-type   = root-temp-shift-stk-tot.sum-type
              and temp-shift-stk-tot.cat-id     = '##,##':U
            no-error .
          if not available temp-shift-stk-tot
          then do:
            create temp-shift-stk-tot .
            assign
              temp-shift-stk-tot.obj-type   = temp-ot-tot.obj-type
              temp-shift-stk-tot.obj-code   = temp-ot-tot.obj-code
              temp-shift-stk-tot.fact-order = root-temp-shift-stk-tot.fact-order
              temp-shift-stk-tot.sum-type   = root-temp-shift-stk-tot.sum-type
              temp-shift-stk-tot.cat-id     = '##,##':U
              temp-shift-stk-tot.fact-date  = root-temp-shift-stk-tot.fact-date
              temp-shift-stk-tot.shift-num  = root-temp-shift-stk-tot.shift-num
              temp-shift-stk-tot.shift-date = root-temp-shift-stk-tot.shift-date
            .
          end.
          assign
                                                                                                                                    temp-shift-stk-tot.new-fact-qnty      = temp-shift-stk-tot.new-fact-qnty      + temp-ot-tot.new-fact-qnty      - temp-ot-tot.fact-qnty           temp-shift-stk-tot.new-sum-base       = temp-shift-stk-tot.new-sum-base       + temp-ot-tot.new-sum-base       - temp-ot-tot.sum-base            temp-shift-stk-tot.new-sum-rubl       = temp-shift-stk-tot.new-sum-rubl       + temp-ot-tot.new-sum-rubl       - temp-ot-tot.sum-rubl            temp-shift-stk-tot.new-vat-base       = temp-shift-stk-tot.new-vat-base       + temp-ot-tot.new-vat-base       - temp-ot-tot.vat-base            temp-shift-stk-tot.new-vat-rubl       = temp-shift-stk-tot.new-vat-rubl       + temp-ot-tot.new-vat-rubl       - temp-ot-tot.vat-rubl            temp-shift-stk-tot.new-slt-base       = temp-shift-stk-tot.new-slt-base       + temp-ot-tot.new-slt-base       - temp-ot-tot.slt-base            temp-shift-stk-tot.new-slt-rubl       = temp-shift-stk-tot.new-slt-rubl       + temp-ot-tot.new-slt-rubl       - temp-ot-tot.slt-rubl            temp-shift-stk-tot.new-road-tax-base  = temp-shift-stk-tot.new-road-tax-base  + temp-ot-tot.new-road-tax-base  - temp-ot-tot.road-tax-base       temp-shift-stk-tot.new-road-tax-rubl  = temp-shift-stk-tot.new-road-tax-rubl  + temp-ot-tot.new-road-tax-rubl  - temp-ot-tot.road-tax-rubl       temp-shift-stk-tot.new-excise-base    = temp-shift-stk-tot.new-excise-base    + temp-ot-tot.new-excise-base    - temp-ot-tot.excise-base         temp-shift-stk-tot.new-excise-rubl    = temp-shift-stk-tot.new-excise-rubl    + temp-ot-tot.new-excise-rubl    - temp-ot-tot.excise-rubl         temp-shift-stk-tot.new-transport-base = temp-shift-stk-tot.new-transport-base + temp-ot-tot.new-transport-base - temp-ot-tot.transport-base      temp-shift-stk-tot.new-transport-rubl = temp-shift-stk-tot.new-transport-rubl + temp-ot-tot.new-transport-rubl - temp-ot-tot.transport-rubl      temp-shift-stk-tot.new-other-base     = temp-shift-stk-tot.new-other-base     + temp-ot-tot.new-other-base     - temp-ot-tot.other-base          temp-shift-stk-tot.new-other-rubl     = temp-shift-stk-tot.new-other-rubl     + temp-ot-tot.new-other-rubl     - temp-ot-tot.other-rubl
          .
        end.
      end.
    end.
    for each temp-ot-tot
      where temp-ot-tot.sum-type = 'sasr':U
        and (
                                          temp-ot-tot.fact-qnty      <> temp-ot-tot.new-fact-qnty        or    temp-ot-tot.sum-base       <> temp-ot-tot.new-sum-base         or    temp-ot-tot.sum-rubl       <> temp-ot-tot.new-sum-rubl         or    temp-ot-tot.vat-base       <> temp-ot-tot.new-vat-base         or    temp-ot-tot.vat-rubl       <> temp-ot-tot.new-vat-rubl         or    temp-ot-tot.slt-base       <> temp-ot-tot.new-slt-base         or    temp-ot-tot.slt-rubl       <> temp-ot-tot.new-slt-rubl         or    temp-ot-tot.road-tax-base  <> temp-ot-tot.new-road-tax-base    or    temp-ot-tot.road-tax-rubl  <> temp-ot-tot.new-road-tax-rubl    or    temp-ot-tot.excise-base    <> temp-ot-tot.new-excise-base      or    temp-ot-tot.excise-rubl    <> temp-ot-tot.new-excise-rubl      or    temp-ot-tot.transport-base <> temp-ot-tot.new-transport-base   or    temp-ot-tot.transport-rubl <> temp-ot-tot.new-transport-rubl   or    temp-ot-tot.other-base     <> temp-ot-tot.new-other-base       or    temp-ot-tot.other-rubl     <> temp-ot-tot.new-other-rubl
            )
    on error undo, return error
    :
      for each root-temp-stk-tot
        where root-temp-stk-tot.obj-type = temp-ot-tot.obj-type
          and root-temp-stk-tot.obj-code = temp-ot-tot.obj-code
          and root-temp-stk-tot.sum-type = 'adsr':U + ub.trn-doc.ext-doc-type
          and root-temp-stk-tot.cat-id   = '##,##':U
      on error undo, return error
      :
        find first temp-stk-tot
          where temp-stk-tot.obj-type   = temp-ot-tot.obj-type
            and temp-stk-tot.obj-code   = temp-ot-tot.obj-code
            and temp-stk-tot.fact-order = root-temp-stk-tot.fact-order
            and temp-stk-tot.sum-type   = root-temp-stk-tot.sum-type
            and temp-stk-tot.cat-id     = '##,##':U
          no-error .
        if not available temp-stk-tot
        then do:
          create temp-stk-tot .
          assign
            temp-stk-tot.obj-type   = temp-ot-tot.obj-type
            temp-stk-tot.obj-code   = temp-ot-tot.obj-code
            temp-stk-tot.fact-order = root-temp-stk-tot.fact-order
            temp-stk-tot.sum-type   = root-temp-stk-tot.sum-type
            temp-stk-tot.cat-id     = '##,##':U
            temp-stk-tot.fact-date  = root-temp-stk-tot.fact-date
            temp-stk-tot.shift-num  = root-temp-stk-tot.shift-num
            temp-stk-tot.shift-date = root-temp-stk-tot.shift-date
          .
        end.
        assign
                                                                                                              temp-stk-tot.new-fact-qnty      = temp-stk-tot.new-fact-qnty      + temp-ot-tot.new-fact-qnty      - temp-ot-tot.fact-qnty           temp-stk-tot.new-sum-base       = temp-stk-tot.new-sum-base       + temp-ot-tot.new-sum-base       - temp-ot-tot.sum-base            temp-stk-tot.new-sum-rubl       = temp-stk-tot.new-sum-rubl       + temp-ot-tot.new-sum-rubl       - temp-ot-tot.sum-rubl            temp-stk-tot.new-vat-base       = temp-stk-tot.new-vat-base       + temp-ot-tot.new-vat-base       - temp-ot-tot.vat-base            temp-stk-tot.new-vat-rubl       = temp-stk-tot.new-vat-rubl       + temp-ot-tot.new-vat-rubl       - temp-ot-tot.vat-rubl            temp-stk-tot.new-slt-base       = temp-stk-tot.new-slt-base       + temp-ot-tot.new-slt-base       - temp-ot-tot.slt-base            temp-stk-tot.new-slt-rubl       = temp-stk-tot.new-slt-rubl       + temp-ot-tot.new-slt-rubl       - temp-ot-tot.slt-rubl            temp-stk-tot.new-road-tax-base  = temp-stk-tot.new-road-tax-base  + temp-ot-tot.new-road-tax-base  - temp-ot-tot.road-tax-base       temp-stk-tot.new-road-tax-rubl  = temp-stk-tot.new-road-tax-rubl  + temp-ot-tot.new-road-tax-rubl  - temp-ot-tot.road-tax-rubl       temp-stk-tot.new-excise-base    = temp-stk-tot.new-excise-base    + temp-ot-tot.new-excise-base    - temp-ot-tot.excise-base         temp-stk-tot.new-excise-rubl    = temp-stk-tot.new-excise-rubl    + temp-ot-tot.new-excise-rubl    - temp-ot-tot.excise-rubl         temp-stk-tot.new-transport-base = temp-stk-tot.new-transport-base + temp-ot-tot.new-transport-base - temp-ot-tot.transport-base      temp-stk-tot.new-transport-rubl = temp-stk-tot.new-transport-rubl + temp-ot-tot.new-transport-rubl - temp-ot-tot.transport-rubl      temp-stk-tot.new-other-base     = temp-stk-tot.new-other-base     + temp-ot-tot.new-other-base     - temp-ot-tot.other-base          temp-stk-tot.new-other-rubl     = temp-stk-tot.new-other-rubl     + temp-ot-tot.new-other-rubl     - temp-ot-tot.other-rubl
        .
      end.
      if v-shift-on
      then do:
        for each root-temp-shift-stk-tot
          where root-temp-shift-stk-tot.obj-type = temp-ot-tot.obj-type
            and root-temp-shift-stk-tot.obj-code = temp-ot-tot.obj-code
            and root-temp-shift-stk-tot.sum-type = 'adsr':U + ub.trn-doc.ext-doc-type
            and root-temp-shift-stk-tot.cat-id   = '##,##':U
        on error undo, return error
        :
          find first temp-shift-stk-tot
            where temp-shift-stk-tot.obj-type   = temp-ot-tot.obj-type
              and temp-shift-stk-tot.obj-code   = temp-ot-tot.obj-code
              and temp-shift-stk-tot.fact-order = root-temp-shift-stk-tot.fact-order
              and temp-shift-stk-tot.sum-type   = root-temp-shift-stk-tot.sum-type
              and temp-shift-stk-tot.cat-id     = '##,##':U
            no-error .
          if not available temp-shift-stk-tot
          then do:
            create temp-shift-stk-tot .
            assign
              temp-shift-stk-tot.obj-type   = temp-ot-tot.obj-type
              temp-shift-stk-tot.obj-code   = temp-ot-tot.obj-code
              temp-shift-stk-tot.fact-order = root-temp-shift-stk-tot.fact-order
              temp-shift-stk-tot.sum-type   = root-temp-shift-stk-tot.sum-type
              temp-shift-stk-tot.cat-id     = '##,##':U
              temp-shift-stk-tot.fact-date  = root-temp-shift-stk-tot.fact-date
              temp-shift-stk-tot.shift-num  = root-temp-shift-stk-tot.shift-num
              temp-shift-stk-tot.shift-date = root-temp-shift-stk-tot.shift-date
            .
          end.
          assign
                                                                                                                                    temp-shift-stk-tot.new-fact-qnty      = temp-shift-stk-tot.new-fact-qnty      + temp-ot-tot.new-fact-qnty      - temp-ot-tot.fact-qnty           temp-shift-stk-tot.new-sum-base       = temp-shift-stk-tot.new-sum-base       + temp-ot-tot.new-sum-base       - temp-ot-tot.sum-base            temp-shift-stk-tot.new-sum-rubl       = temp-shift-stk-tot.new-sum-rubl       + temp-ot-tot.new-sum-rubl       - temp-ot-tot.sum-rubl            temp-shift-stk-tot.new-vat-base       = temp-shift-stk-tot.new-vat-base       + temp-ot-tot.new-vat-base       - temp-ot-tot.vat-base            temp-shift-stk-tot.new-vat-rubl       = temp-shift-stk-tot.new-vat-rubl       + temp-ot-tot.new-vat-rubl       - temp-ot-tot.vat-rubl            temp-shift-stk-tot.new-slt-base       = temp-shift-stk-tot.new-slt-base       + temp-ot-tot.new-slt-base       - temp-ot-tot.slt-base            temp-shift-stk-tot.new-slt-rubl       = temp-shift-stk-tot.new-slt-rubl       + temp-ot-tot.new-slt-rubl       - temp-ot-tot.slt-rubl            temp-shift-stk-tot.new-road-tax-base  = temp-shift-stk-tot.new-road-tax-base  + temp-ot-tot.new-road-tax-base  - temp-ot-tot.road-tax-base       temp-shift-stk-tot.new-road-tax-rubl  = temp-shift-stk-tot.new-road-tax-rubl  + temp-ot-tot.new-road-tax-rubl  - temp-ot-tot.road-tax-rubl       temp-shift-stk-tot.new-excise-base    = temp-shift-stk-tot.new-excise-base    + temp-ot-tot.new-excise-base    - temp-ot-tot.excise-base         temp-shift-stk-tot.new-excise-rubl    = temp-shift-stk-tot.new-excise-rubl    + temp-ot-tot.new-excise-rubl    - temp-ot-tot.excise-rubl         temp-shift-stk-tot.new-transport-base = temp-shift-stk-tot.new-transport-base + temp-ot-tot.new-transport-base - temp-ot-tot.transport-base      temp-shift-stk-tot.new-transport-rubl = temp-shift-stk-tot.new-transport-rubl + temp-ot-tot.new-transport-rubl - temp-ot-tot.transport-rubl      temp-shift-stk-tot.new-other-base     = temp-shift-stk-tot.new-other-base     + temp-ot-tot.new-other-base     - temp-ot-tot.other-base          temp-shift-stk-tot.new-other-rubl     = temp-shift-stk-tot.new-other-rubl     + temp-ot-tot.new-other-rubl     - temp-ot-tot.other-rubl
          .
        end.
      end.
    end.
    for each temp-ot-tot
      where temp-ot-tot.sum-type = 'crsa':U
        and (
                                          temp-ot-tot.fact-qnty      <> temp-ot-tot.new-fact-qnty        or    temp-ot-tot.sum-base       <> temp-ot-tot.new-sum-base         or    temp-ot-tot.sum-rubl       <> temp-ot-tot.new-sum-rubl         or    temp-ot-tot.vat-base       <> temp-ot-tot.new-vat-base         or    temp-ot-tot.vat-rubl       <> temp-ot-tot.new-vat-rubl         or    temp-ot-tot.slt-base       <> temp-ot-tot.new-slt-base         or    temp-ot-tot.slt-rubl       <> temp-ot-tot.new-slt-rubl         or    temp-ot-tot.road-tax-base  <> temp-ot-tot.new-road-tax-base    or    temp-ot-tot.road-tax-rubl  <> temp-ot-tot.new-road-tax-rubl    or    temp-ot-tot.excise-base    <> temp-ot-tot.new-excise-base      or    temp-ot-tot.excise-rubl    <> temp-ot-tot.new-excise-rubl      or    temp-ot-tot.transport-base <> temp-ot-tot.new-transport-base   or    temp-ot-tot.transport-rubl <> temp-ot-tot.new-transport-rubl   or    temp-ot-tot.other-base     <> temp-ot-tot.new-other-base       or    temp-ot-tot.other-rubl     <> temp-ot-tot.new-other-rubl
            )
    on error undo, return error
    :
      for each root-temp-stk-tot
        where root-temp-stk-tot.obj-type = temp-ot-tot.obj-type
          and root-temp-stk-tot.obj-code = temp-ot-tot.obj-code
          and root-temp-stk-tot.sum-type = 'cgdt':U + ub.trn-doc.ext-doc-type
          and root-temp-stk-tot.cat-id   = '##,##':U
      on error undo, return error
      :
        find first temp-stk-tot
          where temp-stk-tot.obj-type   = temp-ot-tot.obj-type
            and temp-stk-tot.obj-code   = temp-ot-tot.obj-code
            and temp-stk-tot.fact-order = root-temp-stk-tot.fact-order
            and temp-stk-tot.sum-type   = root-temp-stk-tot.sum-type
            and temp-stk-tot.cat-id     = '##,##':U
          no-error .
        if not available temp-stk-tot
        then do:
          create temp-stk-tot .
          assign
            temp-stk-tot.obj-type   = temp-ot-tot.obj-type
            temp-stk-tot.obj-code   = temp-ot-tot.obj-code
            temp-stk-tot.fact-order = root-temp-stk-tot.fact-order
            temp-stk-tot.sum-type   = root-temp-stk-tot.sum-type
            temp-stk-tot.cat-id     = '##,##':U
            temp-stk-tot.fact-date  = root-temp-stk-tot.fact-date
            temp-stk-tot.shift-num  = root-temp-stk-tot.shift-num
            temp-stk-tot.shift-date = root-temp-stk-tot.shift-date
          .
        end.
        assign
                                                                                                              temp-stk-tot.new-fact-qnty      = temp-stk-tot.new-fact-qnty      + temp-ot-tot.new-fact-qnty      - temp-ot-tot.fact-qnty           temp-stk-tot.new-sum-base       = temp-stk-tot.new-sum-base       + temp-ot-tot.new-sum-base       - temp-ot-tot.sum-base            temp-stk-tot.new-sum-rubl       = temp-stk-tot.new-sum-rubl       + temp-ot-tot.new-sum-rubl       - temp-ot-tot.sum-rubl            temp-stk-tot.new-vat-base       = temp-stk-tot.new-vat-base       + temp-ot-tot.new-vat-base       - temp-ot-tot.vat-base            temp-stk-tot.new-vat-rubl       = temp-stk-tot.new-vat-rubl       + temp-ot-tot.new-vat-rubl       - temp-ot-tot.vat-rubl            temp-stk-tot.new-slt-base       = temp-stk-tot.new-slt-base       + temp-ot-tot.new-slt-base       - temp-ot-tot.slt-base            temp-stk-tot.new-slt-rubl       = temp-stk-tot.new-slt-rubl       + temp-ot-tot.new-slt-rubl       - temp-ot-tot.slt-rubl            temp-stk-tot.new-road-tax-base  = temp-stk-tot.new-road-tax-base  + temp-ot-tot.new-road-tax-base  - temp-ot-tot.road-tax-base       temp-stk-tot.new-road-tax-rubl  = temp-stk-tot.new-road-tax-rubl  + temp-ot-tot.new-road-tax-rubl  - temp-ot-tot.road-tax-rubl       temp-stk-tot.new-excise-base    = temp-stk-tot.new-excise-base    + temp-ot-tot.new-excise-base    - temp-ot-tot.excise-base         temp-stk-tot.new-excise-rubl    = temp-stk-tot.new-excise-rubl    + temp-ot-tot.new-excise-rubl    - temp-ot-tot.excise-rubl         temp-stk-tot.new-transport-base = temp-stk-tot.new-transport-base + temp-ot-tot.new-transport-base - temp-ot-tot.transport-base      temp-stk-tot.new-transport-rubl = temp-stk-tot.new-transport-rubl + temp-ot-tot.new-transport-rubl - temp-ot-tot.transport-rubl      temp-stk-tot.new-other-base     = temp-stk-tot.new-other-base     + temp-ot-tot.new-other-base     - temp-ot-tot.other-base          temp-stk-tot.new-other-rubl     = temp-stk-tot.new-other-rubl     + temp-ot-tot.new-other-rubl     - temp-ot-tot.other-rubl
        .
      end.
      if v-shift-on
      then do:
        for each root-temp-shift-stk-tot
          where root-temp-shift-stk-tot.obj-type = temp-ot-tot.obj-type
            and root-temp-shift-stk-tot.obj-code = temp-ot-tot.obj-code
            and root-temp-shift-stk-tot.sum-type = 'cgdt':U + ub.trn-doc.ext-doc-type
            and root-temp-shift-stk-tot.cat-id   = '##,##':U
        on error undo, return error
        :
          find first temp-shift-stk-tot
            where temp-shift-stk-tot.obj-type   = temp-ot-tot.obj-type
              and temp-shift-stk-tot.obj-code   = temp-ot-tot.obj-code
              and temp-shift-stk-tot.fact-order = root-temp-shift-stk-tot.fact-order
              and temp-shift-stk-tot.sum-type   = root-temp-shift-stk-tot.sum-type
              and temp-shift-stk-tot.cat-id     = '##,##':U
            no-error .
          if not available temp-shift-stk-tot
          then do:
            create temp-shift-stk-tot .
            assign
              temp-shift-stk-tot.obj-type   = temp-ot-tot.obj-type
              temp-shift-stk-tot.obj-code   = temp-ot-tot.obj-code
              temp-shift-stk-tot.fact-order = root-temp-shift-stk-tot.fact-order
              temp-shift-stk-tot.sum-type   = root-temp-shift-stk-tot.sum-type
              temp-shift-stk-tot.cat-id     = '##,##':U
              temp-shift-stk-tot.fact-date  = root-temp-shift-stk-tot.fact-date
              temp-shift-stk-tot.shift-num  = root-temp-shift-stk-tot.shift-num
              temp-shift-stk-tot.shift-date = root-temp-shift-stk-tot.shift-date
            .
          end.
          assign
                                                                                                                                    temp-shift-stk-tot.new-fact-qnty      = temp-shift-stk-tot.new-fact-qnty      + temp-ot-tot.new-fact-qnty      - temp-ot-tot.fact-qnty           temp-shift-stk-tot.new-sum-base       = temp-shift-stk-tot.new-sum-base       + temp-ot-tot.new-sum-base       - temp-ot-tot.sum-base            temp-shift-stk-tot.new-sum-rubl       = temp-shift-stk-tot.new-sum-rubl       + temp-ot-tot.new-sum-rubl       - temp-ot-tot.sum-rubl            temp-shift-stk-tot.new-vat-base       = temp-shift-stk-tot.new-vat-base       + temp-ot-tot.new-vat-base       - temp-ot-tot.vat-base            temp-shift-stk-tot.new-vat-rubl       = temp-shift-stk-tot.new-vat-rubl       + temp-ot-tot.new-vat-rubl       - temp-ot-tot.vat-rubl            temp-shift-stk-tot.new-slt-base       = temp-shift-stk-tot.new-slt-base       + temp-ot-tot.new-slt-base       - temp-ot-tot.slt-base            temp-shift-stk-tot.new-slt-rubl       = temp-shift-stk-tot.new-slt-rubl       + temp-ot-tot.new-slt-rubl       - temp-ot-tot.slt-rubl            temp-shift-stk-tot.new-road-tax-base  = temp-shift-stk-tot.new-road-tax-base  + temp-ot-tot.new-road-tax-base  - temp-ot-tot.road-tax-base       temp-shift-stk-tot.new-road-tax-rubl  = temp-shift-stk-tot.new-road-tax-rubl  + temp-ot-tot.new-road-tax-rubl  - temp-ot-tot.road-tax-rubl       temp-shift-stk-tot.new-excise-base    = temp-shift-stk-tot.new-excise-base    + temp-ot-tot.new-excise-base    - temp-ot-tot.excise-base         temp-shift-stk-tot.new-excise-rubl    = temp-shift-stk-tot.new-excise-rubl    + temp-ot-tot.new-excise-rubl    - temp-ot-tot.excise-rubl         temp-shift-stk-tot.new-transport-base = temp-shift-stk-tot.new-transport-base + temp-ot-tot.new-transport-base - temp-ot-tot.transport-base      temp-shift-stk-tot.new-transport-rubl = temp-shift-stk-tot.new-transport-rubl + temp-ot-tot.new-transport-rubl - temp-ot-tot.transport-rubl      temp-shift-stk-tot.new-other-base     = temp-shift-stk-tot.new-other-base     + temp-ot-tot.new-other-base     - temp-ot-tot.other-base          temp-shift-stk-tot.new-other-rubl     = temp-shift-stk-tot.new-other-rubl     + temp-ot-tot.new-other-rubl     - temp-ot-tot.other-rubl
          .
        end.
      end.
    end.
    for each temp-ot-tot
      where temp-ot-tot.sum-type = 'cgsr':U
        and (
                                          temp-ot-tot.fact-qnty      <> temp-ot-tot.new-fact-qnty        or    temp-ot-tot.sum-base       <> temp-ot-tot.new-sum-base         or    temp-ot-tot.sum-rubl       <> temp-ot-tot.new-sum-rubl         or    temp-ot-tot.vat-base       <> temp-ot-tot.new-vat-base         or    temp-ot-tot.vat-rubl       <> temp-ot-tot.new-vat-rubl         or    temp-ot-tot.slt-base       <> temp-ot-tot.new-slt-base         or    temp-ot-tot.slt-rubl       <> temp-ot-tot.new-slt-rubl         or    temp-ot-tot.road-tax-base  <> temp-ot-tot.new-road-tax-base    or    temp-ot-tot.road-tax-rubl  <> temp-ot-tot.new-road-tax-rubl    or    temp-ot-tot.excise-base    <> temp-ot-tot.new-excise-base      or    temp-ot-tot.excise-rubl    <> temp-ot-tot.new-excise-rubl      or    temp-ot-tot.transport-base <> temp-ot-tot.new-transport-base   or    temp-ot-tot.transport-rubl <> temp-ot-tot.new-transport-rubl   or    temp-ot-tot.other-base     <> temp-ot-tot.new-other-base       or    temp-ot-tot.other-rubl     <> temp-ot-tot.new-other-rubl
            )
    on error undo, return error
    :
      for each root-temp-stk-tot
        where root-temp-stk-tot.obj-type = temp-ot-tot.obj-type
          and root-temp-stk-tot.obj-code = temp-ot-tot.obj-code
          and root-temp-stk-tot.sum-type = 'gdsr':U + ub.trn-doc.ext-doc-type
          and root-temp-stk-tot.cat-id   = '##,##':U
      on error undo, return error
      :
        find first temp-stk-tot
          where temp-stk-tot.obj-type   = temp-ot-tot.obj-type
            and temp-stk-tot.obj-code   = temp-ot-tot.obj-code
            and temp-stk-tot.fact-order = root-temp-stk-tot.fact-order
            and temp-stk-tot.sum-type   = root-temp-stk-tot.sum-type
            and temp-stk-tot.cat-id     = '##,##':U
          no-error .
        if not available temp-stk-tot
        then do:
          create temp-stk-tot .
          assign
            temp-stk-tot.obj-type   = temp-ot-tot.obj-type
            temp-stk-tot.obj-code   = temp-ot-tot.obj-code
            temp-stk-tot.fact-order = root-temp-stk-tot.fact-order
            temp-stk-tot.sum-type   = root-temp-stk-tot.sum-type
            temp-stk-tot.cat-id     = '##,##':U
            temp-stk-tot.fact-date  = root-temp-stk-tot.fact-date
            temp-stk-tot.shift-num  = root-temp-stk-tot.shift-num
            temp-stk-tot.shift-date = root-temp-stk-tot.shift-date
          .
        end.
        assign
                                                                                                              temp-stk-tot.new-fact-qnty      = temp-stk-tot.new-fact-qnty      + temp-ot-tot.new-fact-qnty      - temp-ot-tot.fact-qnty           temp-stk-tot.new-sum-base       = temp-stk-tot.new-sum-base       + temp-ot-tot.new-sum-base       - temp-ot-tot.sum-base            temp-stk-tot.new-sum-rubl       = temp-stk-tot.new-sum-rubl       + temp-ot-tot.new-sum-rubl       - temp-ot-tot.sum-rubl            temp-stk-tot.new-vat-base       = temp-stk-tot.new-vat-base       + temp-ot-tot.new-vat-base       - temp-ot-tot.vat-base            temp-stk-tot.new-vat-rubl       = temp-stk-tot.new-vat-rubl       + temp-ot-tot.new-vat-rubl       - temp-ot-tot.vat-rubl            temp-stk-tot.new-slt-base       = temp-stk-tot.new-slt-base       + temp-ot-tot.new-slt-base       - temp-ot-tot.slt-base            temp-stk-tot.new-slt-rubl       = temp-stk-tot.new-slt-rubl       + temp-ot-tot.new-slt-rubl       - temp-ot-tot.slt-rubl            temp-stk-tot.new-road-tax-base  = temp-stk-tot.new-road-tax-base  + temp-ot-tot.new-road-tax-base  - temp-ot-tot.road-tax-base       temp-stk-tot.new-road-tax-rubl  = temp-stk-tot.new-road-tax-rubl  + temp-ot-tot.new-road-tax-rubl  - temp-ot-tot.road-tax-rubl       temp-stk-tot.new-excise-base    = temp-stk-tot.new-excise-base    + temp-ot-tot.new-excise-base    - temp-ot-tot.excise-base         temp-stk-tot.new-excise-rubl    = temp-stk-tot.new-excise-rubl    + temp-ot-tot.new-excise-rubl    - temp-ot-tot.excise-rubl         temp-stk-tot.new-transport-base = temp-stk-tot.new-transport-base + temp-ot-tot.new-transport-base - temp-ot-tot.transport-base      temp-stk-tot.new-transport-rubl = temp-stk-tot.new-transport-rubl + temp-ot-tot.new-transport-rubl - temp-ot-tot.transport-rubl      temp-stk-tot.new-other-base     = temp-stk-tot.new-other-base     + temp-ot-tot.new-other-base     - temp-ot-tot.other-base          temp-stk-tot.new-other-rubl     = temp-stk-tot.new-other-rubl     + temp-ot-tot.new-other-rubl     - temp-ot-tot.other-rubl
        .
      end.
      if v-shift-on
      then do:
        for each root-temp-shift-stk-tot
          where root-temp-shift-stk-tot.obj-type = temp-ot-tot.obj-type
            and root-temp-shift-stk-tot.obj-code = temp-ot-tot.obj-code
            and root-temp-shift-stk-tot.sum-type = 'gdsr':U + ub.trn-doc.ext-doc-type
            and root-temp-shift-stk-tot.cat-id   = '##,##':U
        on error undo, return error
        :
          find first temp-shift-stk-tot
            where temp-shift-stk-tot.obj-type   = temp-ot-tot.obj-type
              and temp-shift-stk-tot.obj-code   = temp-ot-tot.obj-code
              and temp-shift-stk-tot.fact-order = root-temp-shift-stk-tot.fact-order
              and temp-shift-stk-tot.sum-type   = root-temp-shift-stk-tot.sum-type
              and temp-shift-stk-tot.cat-id     = '##,##':U
            no-error .
          if not available temp-shift-stk-tot
          then do:
            create temp-shift-stk-tot .
            assign
              temp-shift-stk-tot.obj-type   = temp-ot-tot.obj-type
              temp-shift-stk-tot.obj-code   = temp-ot-tot.obj-code
              temp-shift-stk-tot.fact-order = root-temp-shift-stk-tot.fact-order
              temp-shift-stk-tot.sum-type   = root-temp-shift-stk-tot.sum-type
              temp-shift-stk-tot.cat-id     = '##,##':U
              temp-shift-stk-tot.fact-date  = root-temp-shift-stk-tot.fact-date
              temp-shift-stk-tot.shift-num  = root-temp-shift-stk-tot.shift-num
              temp-shift-stk-tot.shift-date = root-temp-shift-stk-tot.shift-date
            .
          end.
          assign
                                                                                                                                    temp-shift-stk-tot.new-fact-qnty      = temp-shift-stk-tot.new-fact-qnty      + temp-ot-tot.new-fact-qnty      - temp-ot-tot.fact-qnty           temp-shift-stk-tot.new-sum-base       = temp-shift-stk-tot.new-sum-base       + temp-ot-tot.new-sum-base       - temp-ot-tot.sum-base            temp-shift-stk-tot.new-sum-rubl       = temp-shift-stk-tot.new-sum-rubl       + temp-ot-tot.new-sum-rubl       - temp-ot-tot.sum-rubl            temp-shift-stk-tot.new-vat-base       = temp-shift-stk-tot.new-vat-base       + temp-ot-tot.new-vat-base       - temp-ot-tot.vat-base            temp-shift-stk-tot.new-vat-rubl       = temp-shift-stk-tot.new-vat-rubl       + temp-ot-tot.new-vat-rubl       - temp-ot-tot.vat-rubl            temp-shift-stk-tot.new-slt-base       = temp-shift-stk-tot.new-slt-base       + temp-ot-tot.new-slt-base       - temp-ot-tot.slt-base            temp-shift-stk-tot.new-slt-rubl       = temp-shift-stk-tot.new-slt-rubl       + temp-ot-tot.new-slt-rubl       - temp-ot-tot.slt-rubl            temp-shift-stk-tot.new-road-tax-base  = temp-shift-stk-tot.new-road-tax-base  + temp-ot-tot.new-road-tax-base  - temp-ot-tot.road-tax-base       temp-shift-stk-tot.new-road-tax-rubl  = temp-shift-stk-tot.new-road-tax-rubl  + temp-ot-tot.new-road-tax-rubl  - temp-ot-tot.road-tax-rubl       temp-shift-stk-tot.new-excise-base    = temp-shift-stk-tot.new-excise-base    + temp-ot-tot.new-excise-base    - temp-ot-tot.excise-base         temp-shift-stk-tot.new-excise-rubl    = temp-shift-stk-tot.new-excise-rubl    + temp-ot-tot.new-excise-rubl    - temp-ot-tot.excise-rubl         temp-shift-stk-tot.new-transport-base = temp-shift-stk-tot.new-transport-base + temp-ot-tot.new-transport-base - temp-ot-tot.transport-base      temp-shift-stk-tot.new-transport-rubl = temp-shift-stk-tot.new-transport-rubl + temp-ot-tot.new-transport-rubl - temp-ot-tot.transport-rubl      temp-shift-stk-tot.new-other-base     = temp-shift-stk-tot.new-other-base     + temp-ot-tot.new-other-base     - temp-ot-tot.other-base          temp-shift-stk-tot.new-other-rubl     = temp-shift-stk-tot.new-other-rubl     + temp-ot-tot.new-other-rubl     - temp-ot-tot.other-rubl
          .
        end.
      end.
    end.
    for each temp-ot-tot
      where temp-ot-tot.sum-type = 'cost':U
        and (
                                          temp-ot-tot.fact-qnty      <> temp-ot-tot.new-fact-qnty        or    temp-ot-tot.sum-base       <> temp-ot-tot.new-sum-base         or    temp-ot-tot.sum-rubl       <> temp-ot-tot.new-sum-rubl         or    temp-ot-tot.vat-base       <> temp-ot-tot.new-vat-base         or    temp-ot-tot.vat-rubl       <> temp-ot-tot.new-vat-rubl         or    temp-ot-tot.slt-base       <> temp-ot-tot.new-slt-base         or    temp-ot-tot.slt-rubl       <> temp-ot-tot.new-slt-rubl         or    temp-ot-tot.road-tax-base  <> temp-ot-tot.new-road-tax-base    or    temp-ot-tot.road-tax-rubl  <> temp-ot-tot.new-road-tax-rubl    or    temp-ot-tot.excise-base    <> temp-ot-tot.new-excise-base      or    temp-ot-tot.excise-rubl    <> temp-ot-tot.new-excise-rubl      or    temp-ot-tot.transport-base <> temp-ot-tot.new-transport-base   or    temp-ot-tot.transport-rubl <> temp-ot-tot.new-transport-rubl   or    temp-ot-tot.other-base     <> temp-ot-tot.new-other-base       or    temp-ot-tot.other-rubl     <> temp-ot-tot.new-other-rubl
            )
    on error undo, return error
    :
      for each root-temp-stk-tot
        where root-temp-stk-tot.obj-type = temp-ot-tot.obj-type
          and root-temp-stk-tot.obj-code = temp-ot-tot.obj-code
          and root-temp-stk-tot.sum-type = 'csdt':U + ub.trn-doc.ext-doc-type
          and root-temp-stk-tot.cat-id   = '##,##':U
      on error undo, return error
      :
        find first temp-stk-tot
          where temp-stk-tot.obj-type   = temp-ot-tot.obj-type
            and temp-stk-tot.obj-code   = temp-ot-tot.obj-code
            and temp-stk-tot.fact-order = root-temp-stk-tot.fact-order
            and temp-stk-tot.sum-type   = root-temp-stk-tot.sum-type
            and temp-stk-tot.cat-id     = '##,##':U
          no-error .
        if not available temp-stk-tot
        then do:
          create temp-stk-tot .
          assign
            temp-stk-tot.obj-type   = temp-ot-tot.obj-type
            temp-stk-tot.obj-code   = temp-ot-tot.obj-code
            temp-stk-tot.fact-order = root-temp-stk-tot.fact-order
            temp-stk-tot.sum-type   = root-temp-stk-tot.sum-type
            temp-stk-tot.cat-id     = '##,##':U
            temp-stk-tot.fact-date  = root-temp-stk-tot.fact-date
            temp-stk-tot.shift-num  = root-temp-stk-tot.shift-num
            temp-stk-tot.shift-date = root-temp-stk-tot.shift-date
          .
        end.
        assign
                                                                                                              temp-stk-tot.new-fact-qnty      = temp-stk-tot.new-fact-qnty      + temp-ot-tot.new-fact-qnty      - temp-ot-tot.fact-qnty           temp-stk-tot.new-sum-base       = temp-stk-tot.new-sum-base       + temp-ot-tot.new-sum-base       - temp-ot-tot.sum-base            temp-stk-tot.new-sum-rubl       = temp-stk-tot.new-sum-rubl       + temp-ot-tot.new-sum-rubl       - temp-ot-tot.sum-rubl            temp-stk-tot.new-vat-base       = temp-stk-tot.new-vat-base       + temp-ot-tot.new-vat-base       - temp-ot-tot.vat-base            temp-stk-tot.new-vat-rubl       = temp-stk-tot.new-vat-rubl       + temp-ot-tot.new-vat-rubl       - temp-ot-tot.vat-rubl            temp-stk-tot.new-slt-base       = temp-stk-tot.new-slt-base       + temp-ot-tot.new-slt-base       - temp-ot-tot.slt-base            temp-stk-tot.new-slt-rubl       = temp-stk-tot.new-slt-rubl       + temp-ot-tot.new-slt-rubl       - temp-ot-tot.slt-rubl            temp-stk-tot.new-road-tax-base  = temp-stk-tot.new-road-tax-base  + temp-ot-tot.new-road-tax-base  - temp-ot-tot.road-tax-base       temp-stk-tot.new-road-tax-rubl  = temp-stk-tot.new-road-tax-rubl  + temp-ot-tot.new-road-tax-rubl  - temp-ot-tot.road-tax-rubl       temp-stk-tot.new-excise-base    = temp-stk-tot.new-excise-base    + temp-ot-tot.new-excise-base    - temp-ot-tot.excise-base         temp-stk-tot.new-excise-rubl    = temp-stk-tot.new-excise-rubl    + temp-ot-tot.new-excise-rubl    - temp-ot-tot.excise-rubl         temp-stk-tot.new-transport-base = temp-stk-tot.new-transport-base + temp-ot-tot.new-transport-base - temp-ot-tot.transport-base      temp-stk-tot.new-transport-rubl = temp-stk-tot.new-transport-rubl + temp-ot-tot.new-transport-rubl - temp-ot-tot.transport-rubl      temp-stk-tot.new-other-base     = temp-stk-tot.new-other-base     + temp-ot-tot.new-other-base     - temp-ot-tot.other-base          temp-stk-tot.new-other-rubl     = temp-stk-tot.new-other-rubl     + temp-ot-tot.new-other-rubl     - temp-ot-tot.other-rubl
        .
      end.
      if v-shift-on
      then do:
        for each root-temp-shift-stk-tot
          where root-temp-shift-stk-tot.obj-type = temp-ot-tot.obj-type
            and root-temp-shift-stk-tot.obj-code = temp-ot-tot.obj-code
            and root-temp-shift-stk-tot.sum-type = 'csdt':U + ub.trn-doc.ext-doc-type
            and root-temp-shift-stk-tot.cat-id   = '##,##':U
        on error undo, return error
        :
          find first temp-shift-stk-tot
            where temp-shift-stk-tot.obj-type   = temp-ot-tot.obj-type
              and temp-shift-stk-tot.obj-code   = temp-ot-tot.obj-code
              and temp-shift-stk-tot.fact-order = root-temp-shift-stk-tot.fact-order
              and temp-shift-stk-tot.sum-type   = root-temp-shift-stk-tot.sum-type
              and temp-shift-stk-tot.cat-id     = '##,##':U
            no-error .
          if not available temp-shift-stk-tot
          then do:
            create temp-shift-stk-tot .
            assign
              temp-shift-stk-tot.obj-type   = temp-ot-tot.obj-type
              temp-shift-stk-tot.obj-code   = temp-ot-tot.obj-code
              temp-shift-stk-tot.fact-order = root-temp-shift-stk-tot.fact-order
              temp-shift-stk-tot.sum-type   = root-temp-shift-stk-tot.sum-type
              temp-shift-stk-tot.cat-id     = '##,##':U
              temp-shift-stk-tot.fact-date  = root-temp-shift-stk-tot.fact-date
              temp-shift-stk-tot.shift-num  = root-temp-shift-stk-tot.shift-num
              temp-shift-stk-tot.shift-date = root-temp-shift-stk-tot.shift-date
            .
          end.
          assign
                                                                                                                                    temp-shift-stk-tot.new-fact-qnty      = temp-shift-stk-tot.new-fact-qnty      + temp-ot-tot.new-fact-qnty      - temp-ot-tot.fact-qnty           temp-shift-stk-tot.new-sum-base       = temp-shift-stk-tot.new-sum-base       + temp-ot-tot.new-sum-base       - temp-ot-tot.sum-base            temp-shift-stk-tot.new-sum-rubl       = temp-shift-stk-tot.new-sum-rubl       + temp-ot-tot.new-sum-rubl       - temp-ot-tot.sum-rubl            temp-shift-stk-tot.new-vat-base       = temp-shift-stk-tot.new-vat-base       + temp-ot-tot.new-vat-base       - temp-ot-tot.vat-base            temp-shift-stk-tot.new-vat-rubl       = temp-shift-stk-tot.new-vat-rubl       + temp-ot-tot.new-vat-rubl       - temp-ot-tot.vat-rubl            temp-shift-stk-tot.new-slt-base       = temp-shift-stk-tot.new-slt-base       + temp-ot-tot.new-slt-base       - temp-ot-tot.slt-base            temp-shift-stk-tot.new-slt-rubl       = temp-shift-stk-tot.new-slt-rubl       + temp-ot-tot.new-slt-rubl       - temp-ot-tot.slt-rubl            temp-shift-stk-tot.new-road-tax-base  = temp-shift-stk-tot.new-road-tax-base  + temp-ot-tot.new-road-tax-base  - temp-ot-tot.road-tax-base       temp-shift-stk-tot.new-road-tax-rubl  = temp-shift-stk-tot.new-road-tax-rubl  + temp-ot-tot.new-road-tax-rubl  - temp-ot-tot.road-tax-rubl       temp-shift-stk-tot.new-excise-base    = temp-shift-stk-tot.new-excise-base    + temp-ot-tot.new-excise-base    - temp-ot-tot.excise-base         temp-shift-stk-tot.new-excise-rubl    = temp-shift-stk-tot.new-excise-rubl    + temp-ot-tot.new-excise-rubl    - temp-ot-tot.excise-rubl         temp-shift-stk-tot.new-transport-base = temp-shift-stk-tot.new-transport-base + temp-ot-tot.new-transport-base - temp-ot-tot.transport-base      temp-shift-stk-tot.new-transport-rubl = temp-shift-stk-tot.new-transport-rubl + temp-ot-tot.new-transport-rubl - temp-ot-tot.transport-rubl      temp-shift-stk-tot.new-other-base     = temp-shift-stk-tot.new-other-base     + temp-ot-tot.new-other-base     - temp-ot-tot.other-base          temp-shift-stk-tot.new-other-rubl     = temp-shift-stk-tot.new-other-rubl     + temp-ot-tot.new-other-rubl     - temp-ot-tot.other-rubl
          .
        end.
      end.
    end.
    for each temp-ot-tot
      where temp-ot-tot.sum-type = 'cssr':U
        and (
                                          temp-ot-tot.fact-qnty      <> temp-ot-tot.new-fact-qnty        or    temp-ot-tot.sum-base       <> temp-ot-tot.new-sum-base         or    temp-ot-tot.sum-rubl       <> temp-ot-tot.new-sum-rubl         or    temp-ot-tot.vat-base       <> temp-ot-tot.new-vat-base         or    temp-ot-tot.vat-rubl       <> temp-ot-tot.new-vat-rubl         or    temp-ot-tot.slt-base       <> temp-ot-tot.new-slt-base         or    temp-ot-tot.slt-rubl       <> temp-ot-tot.new-slt-rubl         or    temp-ot-tot.road-tax-base  <> temp-ot-tot.new-road-tax-base    or    temp-ot-tot.road-tax-rubl  <> temp-ot-tot.new-road-tax-rubl    or    temp-ot-tot.excise-base    <> temp-ot-tot.new-excise-base      or    temp-ot-tot.excise-rubl    <> temp-ot-tot.new-excise-rubl      or    temp-ot-tot.transport-base <> temp-ot-tot.new-transport-base   or    temp-ot-tot.transport-rubl <> temp-ot-tot.new-transport-rubl   or    temp-ot-tot.other-base     <> temp-ot-tot.new-other-base       or    temp-ot-tot.other-rubl     <> temp-ot-tot.new-other-rubl
            )
    on error undo, return error
    :
      for each root-temp-stk-tot
        where root-temp-stk-tot.obj-type = temp-ot-tot.obj-type
          and root-temp-stk-tot.obj-code = temp-ot-tot.obj-code
          and root-temp-stk-tot.sum-type = 'sdsr':U + ub.trn-doc.ext-doc-type
          and root-temp-stk-tot.cat-id   = '##,##':U
      on error undo, return error
      :
        find first temp-stk-tot
          where temp-stk-tot.obj-type   = temp-ot-tot.obj-type
            and temp-stk-tot.obj-code   = temp-ot-tot.obj-code
            and temp-stk-tot.fact-order = root-temp-stk-tot.fact-order
            and temp-stk-tot.sum-type   = root-temp-stk-tot.sum-type
            and temp-stk-tot.cat-id     = '##,##':U
          no-error .
        if not available temp-stk-tot
        then do:
          create temp-stk-tot .
          assign
            temp-stk-tot.obj-type   = temp-ot-tot.obj-type
            temp-stk-tot.obj-code   = temp-ot-tot.obj-code
            temp-stk-tot.fact-order = root-temp-stk-tot.fact-order
            temp-stk-tot.sum-type   = root-temp-stk-tot.sum-type
            temp-stk-tot.cat-id     = '##,##':U
            temp-stk-tot.fact-date  = root-temp-stk-tot.fact-date
            temp-stk-tot.shift-num  = root-temp-stk-tot.shift-num
            temp-stk-tot.shift-date = root-temp-stk-tot.shift-date
          .
        end.
        assign
                                                                                                              temp-stk-tot.new-fact-qnty      = temp-stk-tot.new-fact-qnty      + temp-ot-tot.new-fact-qnty      - temp-ot-tot.fact-qnty           temp-stk-tot.new-sum-base       = temp-stk-tot.new-sum-base       + temp-ot-tot.new-sum-base       - temp-ot-tot.sum-base            temp-stk-tot.new-sum-rubl       = temp-stk-tot.new-sum-rubl       + temp-ot-tot.new-sum-rubl       - temp-ot-tot.sum-rubl            temp-stk-tot.new-vat-base       = temp-stk-tot.new-vat-base       + temp-ot-tot.new-vat-base       - temp-ot-tot.vat-base            temp-stk-tot.new-vat-rubl       = temp-stk-tot.new-vat-rubl       + temp-ot-tot.new-vat-rubl       - temp-ot-tot.vat-rubl            temp-stk-tot.new-slt-base       = temp-stk-tot.new-slt-base       + temp-ot-tot.new-slt-base       - temp-ot-tot.slt-base            temp-stk-tot.new-slt-rubl       = temp-stk-tot.new-slt-rubl       + temp-ot-tot.new-slt-rubl       - temp-ot-tot.slt-rubl            temp-stk-tot.new-road-tax-base  = temp-stk-tot.new-road-tax-base  + temp-ot-tot.new-road-tax-base  - temp-ot-tot.road-tax-base       temp-stk-tot.new-road-tax-rubl  = temp-stk-tot.new-road-tax-rubl  + temp-ot-tot.new-road-tax-rubl  - temp-ot-tot.road-tax-rubl       temp-stk-tot.new-excise-base    = temp-stk-tot.new-excise-base    + temp-ot-tot.new-excise-base    - temp-ot-tot.excise-base         temp-stk-tot.new-excise-rubl    = temp-stk-tot.new-excise-rubl    + temp-ot-tot.new-excise-rubl    - temp-ot-tot.excise-rubl         temp-stk-tot.new-transport-base = temp-stk-tot.new-transport-base + temp-ot-tot.new-transport-base - temp-ot-tot.transport-base      temp-stk-tot.new-transport-rubl = temp-stk-tot.new-transport-rubl + temp-ot-tot.new-transport-rubl - temp-ot-tot.transport-rubl      temp-stk-tot.new-other-base     = temp-stk-tot.new-other-base     + temp-ot-tot.new-other-base     - temp-ot-tot.other-base          temp-stk-tot.new-other-rubl     = temp-stk-tot.new-other-rubl     + temp-ot-tot.new-other-rubl     - temp-ot-tot.other-rubl
        .
      end.
      if v-shift-on
      then do:
        for each root-temp-shift-stk-tot
          where root-temp-shift-stk-tot.obj-type = temp-ot-tot.obj-type
            and root-temp-shift-stk-tot.obj-code = temp-ot-tot.obj-code
            and root-temp-shift-stk-tot.sum-type = 'sdsr':U + ub.trn-doc.ext-doc-type
            and root-temp-shift-stk-tot.cat-id   = '##,##':U
        on error undo, return error
        :
          find first temp-shift-stk-tot
            where temp-shift-stk-tot.obj-type   = temp-ot-tot.obj-type
              and temp-shift-stk-tot.obj-code   = temp-ot-tot.obj-code
              and temp-shift-stk-tot.fact-order = root-temp-shift-stk-tot.fact-order
              and temp-shift-stk-tot.sum-type   = root-temp-shift-stk-tot.sum-type
              and temp-shift-stk-tot.cat-id     = '##,##':U
            no-error .
          if not available temp-shift-stk-tot
          then do:
            create temp-shift-stk-tot .
            assign
              temp-shift-stk-tot.obj-type   = temp-ot-tot.obj-type
              temp-shift-stk-tot.obj-code   = temp-ot-tot.obj-code
              temp-shift-stk-tot.fact-order = root-temp-shift-stk-tot.fact-order
              temp-shift-stk-tot.sum-type   = root-temp-shift-stk-tot.sum-type
              temp-shift-stk-tot.cat-id     = '##,##':U
              temp-shift-stk-tot.fact-date  = root-temp-shift-stk-tot.fact-date
              temp-shift-stk-tot.shift-num  = root-temp-shift-stk-tot.shift-num
              temp-shift-stk-tot.shift-date = root-temp-shift-stk-tot.shift-date
            .
          end.
          assign
                                                                                                                                    temp-shift-stk-tot.new-fact-qnty      = temp-shift-stk-tot.new-fact-qnty      + temp-ot-tot.new-fact-qnty      - temp-ot-tot.fact-qnty           temp-shift-stk-tot.new-sum-base       = temp-shift-stk-tot.new-sum-base       + temp-ot-tot.new-sum-base       - temp-ot-tot.sum-base            temp-shift-stk-tot.new-sum-rubl       = temp-shift-stk-tot.new-sum-rubl       + temp-ot-tot.new-sum-rubl       - temp-ot-tot.sum-rubl            temp-shift-stk-tot.new-vat-base       = temp-shift-stk-tot.new-vat-base       + temp-ot-tot.new-vat-base       - temp-ot-tot.vat-base            temp-shift-stk-tot.new-vat-rubl       = temp-shift-stk-tot.new-vat-rubl       + temp-ot-tot.new-vat-rubl       - temp-ot-tot.vat-rubl            temp-shift-stk-tot.new-slt-base       = temp-shift-stk-tot.new-slt-base       + temp-ot-tot.new-slt-base       - temp-ot-tot.slt-base            temp-shift-stk-tot.new-slt-rubl       = temp-shift-stk-tot.new-slt-rubl       + temp-ot-tot.new-slt-rubl       - temp-ot-tot.slt-rubl            temp-shift-stk-tot.new-road-tax-base  = temp-shift-stk-tot.new-road-tax-base  + temp-ot-tot.new-road-tax-base  - temp-ot-tot.road-tax-base       temp-shift-stk-tot.new-road-tax-rubl  = temp-shift-stk-tot.new-road-tax-rubl  + temp-ot-tot.new-road-tax-rubl  - temp-ot-tot.road-tax-rubl       temp-shift-stk-tot.new-excise-base    = temp-shift-stk-tot.new-excise-base    + temp-ot-tot.new-excise-base    - temp-ot-tot.excise-base         temp-shift-stk-tot.new-excise-rubl    = temp-shift-stk-tot.new-excise-rubl    + temp-ot-tot.new-excise-rubl    - temp-ot-tot.excise-rubl         temp-shift-stk-tot.new-transport-base = temp-shift-stk-tot.new-transport-base + temp-ot-tot.new-transport-base - temp-ot-tot.transport-base      temp-shift-stk-tot.new-transport-rubl = temp-shift-stk-tot.new-transport-rubl + temp-ot-tot.new-transport-rubl - temp-ot-tot.transport-rubl      temp-shift-stk-tot.new-other-base     = temp-shift-stk-tot.new-other-base     + temp-ot-tot.new-other-base     - temp-ot-tot.other-base          temp-shift-stk-tot.new-other-rubl     = temp-shift-stk-tot.new-other-rubl     + temp-ot-tot.new-other-rubl     - temp-ot-tot.other-rubl
          .
        end.
      end.
    end.
    for each temp-ot-line
      where temp-ot-line.sum-type = 'crsa':U
        and (
                                          temp-ot-line.fact-qnty      <> temp-ot-line.new-fact-qnty        or    temp-ot-line.sum-base       <> temp-ot-line.new-sum-base         or    temp-ot-line.sum-rubl       <> temp-ot-line.new-sum-rubl         or    temp-ot-line.vat-base       <> temp-ot-line.new-vat-base         or    temp-ot-line.vat-rubl       <> temp-ot-line.new-vat-rubl         or    temp-ot-line.slt-base       <> temp-ot-line.new-slt-base         or    temp-ot-line.slt-rubl       <> temp-ot-line.new-slt-rubl         or    temp-ot-line.road-tax-base  <> temp-ot-line.new-road-tax-base    or    temp-ot-line.road-tax-rubl  <> temp-ot-line.new-road-tax-rubl    or    temp-ot-line.excise-base    <> temp-ot-line.new-excise-base      or    temp-ot-line.excise-rubl    <> temp-ot-line.new-excise-rubl      or    temp-ot-line.transport-base <> temp-ot-line.new-transport-base   or    temp-ot-line.transport-rubl <> temp-ot-line.new-transport-rubl   or    temp-ot-line.other-base     <> temp-ot-line.new-other-base       or    temp-ot-line.other-rubl     <> temp-ot-line.new-other-rubl
            )
    on error undo, return error
    :
      for each root-temp-stk-line
        where root-temp-stk-line.obj-type  = temp-ot-line.obj-type
          and root-temp-stk-line.obj-code  = temp-ot-line.obj-code
          and root-temp-stk-line.artic     = temp-ot-line.artic
          and root-temp-stk-line.prod-type = temp-ot-line.prod-type
          and root-temp-stk-line.prod-code = temp-ot-line.prod-code
          and root-temp-stk-line.sum-type  = 'crsa':U
          and root-temp-stk-line.cat-id    = '##,##':U
      on error undo, return error
      :
        find first temp-stk-line
          where temp-stk-line.obj-type   = temp-ot-line.obj-type
            and temp-stk-line.obj-code   = temp-ot-line.obj-code
            and temp-stk-line.artic      = temp-ot-line.artic
            and temp-stk-line.prod-type  = temp-ot-line.prod-type
            and temp-stk-line.prod-code  = temp-ot-line.prod-code
            and temp-stk-line.fact-order = root-temp-stk-line.fact-order
            and temp-stk-line.sum-type   = root-temp-stk-line.sum-type
            and temp-stk-line.cat-id     = '##,##':U
          no-error .
        if not available temp-stk-line
        then do:
          create temp-stk-line .
          assign
            temp-stk-line.obj-type   = temp-ot-line.obj-type
            temp-stk-line.obj-code   = temp-ot-line.obj-code
            temp-stk-line.artic      = temp-ot-line.artic
            temp-stk-line.prod-type  = temp-ot-line.prod-type
            temp-stk-line.prod-code  = temp-ot-line.prod-code
            temp-stk-line.fact-order = root-temp-stk-line.fact-order
            temp-stk-line.sum-type   = root-temp-stk-line.sum-type
            temp-stk-line.cat-id     = '##,##':U
            temp-stk-line.fact-date  = root-temp-stk-line.fact-date
            temp-stk-line.shift-num  = root-temp-stk-line.shift-num
            temp-stk-line.shift-date = root-temp-stk-line.shift-date
          .
        end.
        assign
                                                                                                              temp-stk-line.new-fact-qnty      = temp-stk-line.new-fact-qnty      + temp-ot-line.new-fact-qnty      - temp-ot-line.fact-qnty           temp-stk-line.new-sum-base       = temp-stk-line.new-sum-base       + temp-ot-line.new-sum-base       - temp-ot-line.sum-base            temp-stk-line.new-sum-rubl       = temp-stk-line.new-sum-rubl       + temp-ot-line.new-sum-rubl       - temp-ot-line.sum-rubl            temp-stk-line.new-vat-base       = temp-stk-line.new-vat-base       + temp-ot-line.new-vat-base       - temp-ot-line.vat-base            temp-stk-line.new-vat-rubl       = temp-stk-line.new-vat-rubl       + temp-ot-line.new-vat-rubl       - temp-ot-line.vat-rubl            temp-stk-line.new-slt-base       = temp-stk-line.new-slt-base       + temp-ot-line.new-slt-base       - temp-ot-line.slt-base            temp-stk-line.new-slt-rubl       = temp-stk-line.new-slt-rubl       + temp-ot-line.new-slt-rubl       - temp-ot-line.slt-rubl            temp-stk-line.new-road-tax-base  = temp-stk-line.new-road-tax-base  + temp-ot-line.new-road-tax-base  - temp-ot-line.road-tax-base       temp-stk-line.new-road-tax-rubl  = temp-stk-line.new-road-tax-rubl  + temp-ot-line.new-road-tax-rubl  - temp-ot-line.road-tax-rubl       temp-stk-line.new-excise-base    = temp-stk-line.new-excise-base    + temp-ot-line.new-excise-base    - temp-ot-line.excise-base         temp-stk-line.new-excise-rubl    = temp-stk-line.new-excise-rubl    + temp-ot-line.new-excise-rubl    - temp-ot-line.excise-rubl         temp-stk-line.new-transport-base = temp-stk-line.new-transport-base + temp-ot-line.new-transport-base - temp-ot-line.transport-base      temp-stk-line.new-transport-rubl = temp-stk-line.new-transport-rubl + temp-ot-line.new-transport-rubl - temp-ot-line.transport-rubl      temp-stk-line.new-other-base     = temp-stk-line.new-other-base     + temp-ot-line.new-other-base     - temp-ot-line.other-base          temp-stk-line.new-other-rubl     = temp-stk-line.new-other-rubl     + temp-ot-line.new-other-rubl     - temp-ot-line.other-rubl
        .
      end.
      if v-shift-on
      then do:
        for each root-temp-shift-stk-line
          where root-temp-shift-stk-line.obj-type  = temp-ot-line.obj-type
            and root-temp-shift-stk-line.obj-code  = temp-ot-line.obj-code
            and root-temp-shift-stk-line.artic     = temp-ot-line.artic
            and root-temp-shift-stk-line.prod-type = temp-ot-line.prod-type
            and root-temp-shift-stk-line.prod-code = temp-ot-line.prod-code
            and root-temp-shift-stk-line.sum-type  = 'crsa':U
            and root-temp-shift-stk-line.cat-id    = '##,##':U
        on error undo, return error
        :
          find first temp-shift-stk-line
            where temp-shift-stk-line.obj-type   = temp-ot-line.obj-type
              and temp-shift-stk-line.obj-code   = temp-ot-line.obj-code
              and temp-shift-stk-line.artic      = temp-ot-line.artic
              and temp-shift-stk-line.prod-type  = temp-ot-line.prod-type
              and temp-shift-stk-line.prod-code  = temp-ot-line.prod-code
              and temp-shift-stk-line.fact-order = root-temp-shift-stk-line.fact-order
              and temp-shift-stk-line.sum-type   = root-temp-shift-stk-line.sum-type
              and temp-shift-stk-line.cat-id     = '##,##':U
            no-error .
          if not available temp-shift-stk-line
          then do:
            create temp-shift-stk-line .
            assign
              temp-shift-stk-line.obj-type   = temp-ot-line.obj-type
              temp-shift-stk-line.obj-code   = temp-ot-line.obj-code
              temp-shift-stk-line.artic      = temp-ot-line.artic
              temp-shift-stk-line.prod-type  = temp-ot-line.prod-type
              temp-shift-stk-line.prod-code  = temp-ot-line.prod-code
              temp-shift-stk-line.fact-order = root-temp-shift-stk-line.fact-order
              temp-shift-stk-line.sum-type   = root-temp-shift-stk-line.sum-type
              temp-shift-stk-line.cat-id     = '##,##':U
              temp-shift-stk-line.fact-date  = root-temp-shift-stk-line.fact-date
              temp-shift-stk-line.shift-num  = root-temp-shift-stk-line.shift-num
              temp-shift-stk-line.shift-date = root-temp-shift-stk-line.shift-date
            .
          end.
          assign
                                                                                                                                    temp-shift-stk-line.new-fact-qnty      = temp-shift-stk-line.new-fact-qnty      + temp-ot-line.new-fact-qnty      - temp-ot-line.fact-qnty           temp-shift-stk-line.new-sum-base       = temp-shift-stk-line.new-sum-base       + temp-ot-line.new-sum-base       - temp-ot-line.sum-base            temp-shift-stk-line.new-sum-rubl       = temp-shift-stk-line.new-sum-rubl       + temp-ot-line.new-sum-rubl       - temp-ot-line.sum-rubl            temp-shift-stk-line.new-vat-base       = temp-shift-stk-line.new-vat-base       + temp-ot-line.new-vat-base       - temp-ot-line.vat-base            temp-shift-stk-line.new-vat-rubl       = temp-shift-stk-line.new-vat-rubl       + temp-ot-line.new-vat-rubl       - temp-ot-line.vat-rubl            temp-shift-stk-line.new-slt-base       = temp-shift-stk-line.new-slt-base       + temp-ot-line.new-slt-base       - temp-ot-line.slt-base            temp-shift-stk-line.new-slt-rubl       = temp-shift-stk-line.new-slt-rubl       + temp-ot-line.new-slt-rubl       - temp-ot-line.slt-rubl            temp-shift-stk-line.new-road-tax-base  = temp-shift-stk-line.new-road-tax-base  + temp-ot-line.new-road-tax-base  - temp-ot-line.road-tax-base       temp-shift-stk-line.new-road-tax-rubl  = temp-shift-stk-line.new-road-tax-rubl  + temp-ot-line.new-road-tax-rubl  - temp-ot-line.road-tax-rubl       temp-shift-stk-line.new-excise-base    = temp-shift-stk-line.new-excise-base    + temp-ot-line.new-excise-base    - temp-ot-line.excise-base         temp-shift-stk-line.new-excise-rubl    = temp-shift-stk-line.new-excise-rubl    + temp-ot-line.new-excise-rubl    - temp-ot-line.excise-rubl         temp-shift-stk-line.new-transport-base = temp-shift-stk-line.new-transport-base + temp-ot-line.new-transport-base - temp-ot-line.transport-base      temp-shift-stk-line.new-transport-rubl = temp-shift-stk-line.new-transport-rubl + temp-ot-line.new-transport-rubl - temp-ot-line.transport-rubl      temp-shift-stk-line.new-other-base     = temp-shift-stk-line.new-other-base     + temp-ot-line.new-other-base     - temp-ot-line.other-base          temp-shift-stk-line.new-other-rubl     = temp-shift-stk-line.new-other-rubl     + temp-ot-line.new-other-rubl     - temp-ot-line.other-rubl
          .
        end.
      end.
    end.
    for each temp-ot-line
      where temp-ot-line.sum-type begins 'cost':U
        and (
                                          temp-ot-line.fact-qnty      <> temp-ot-line.new-fact-qnty        or    temp-ot-line.sum-base       <> temp-ot-line.new-sum-base         or    temp-ot-line.sum-rubl       <> temp-ot-line.new-sum-rubl         or    temp-ot-line.vat-base       <> temp-ot-line.new-vat-base         or    temp-ot-line.vat-rubl       <> temp-ot-line.new-vat-rubl         or    temp-ot-line.slt-base       <> temp-ot-line.new-slt-base         or    temp-ot-line.slt-rubl       <> temp-ot-line.new-slt-rubl         or    temp-ot-line.road-tax-base  <> temp-ot-line.new-road-tax-base    or    temp-ot-line.road-tax-rubl  <> temp-ot-line.new-road-tax-rubl    or    temp-ot-line.excise-base    <> temp-ot-line.new-excise-base      or    temp-ot-line.excise-rubl    <> temp-ot-line.new-excise-rubl      or    temp-ot-line.transport-base <> temp-ot-line.new-transport-base   or    temp-ot-line.transport-rubl <> temp-ot-line.new-transport-rubl   or    temp-ot-line.other-base     <> temp-ot-line.new-other-base       or    temp-ot-line.other-rubl     <> temp-ot-line.new-other-rubl
            )
    on error undo, return error
    :
      for each root-temp-stk-line
        where root-temp-stk-line.obj-type  = temp-ot-line.obj-type
          and root-temp-stk-line.obj-code  = temp-ot-line.obj-code
          and root-temp-stk-line.artic     = temp-ot-line.artic
          and root-temp-stk-line.prod-type = temp-ot-line.prod-type
          and root-temp-stk-line.prod-code = temp-ot-line.prod-code
          and root-temp-stk-line.sum-type  = 'cost':U
          and root-temp-stk-line.cat-id    = '##,##':U
      on error undo, return error
      :
        find first temp-stk-line
          where temp-stk-line.obj-type   = temp-ot-line.obj-type
            and temp-stk-line.obj-code   = temp-ot-line.obj-code
            and temp-stk-line.artic      = temp-ot-line.artic
            and temp-stk-line.prod-type  = temp-ot-line.prod-type
            and temp-stk-line.prod-code  = temp-ot-line.prod-code
            and temp-stk-line.fact-order = root-temp-stk-line.fact-order
            and temp-stk-line.sum-type   = temp-ot-line.sum-type
            and temp-stk-line.cat-id     = temp-ot-line.cat-id
          no-error .
        if not available temp-stk-line
        then do:
          create temp-stk-line .
          assign
            temp-stk-line.obj-type   = temp-ot-line.obj-type
            temp-stk-line.obj-code   = temp-ot-line.obj-code
            temp-stk-line.artic      = temp-ot-line.artic
            temp-stk-line.prod-type  = temp-ot-line.prod-type
            temp-stk-line.prod-code  = temp-ot-line.prod-code
            temp-stk-line.fact-order = root-temp-stk-line.fact-order
            temp-stk-line.sum-type   = temp-ot-line.sum-type
            temp-stk-line.cat-id     = temp-ot-line.cat-id
            temp-stk-line.fact-date  = root-temp-stk-line.fact-date
            temp-stk-line.shift-num  = root-temp-stk-line.shift-num
            temp-stk-line.shift-date = root-temp-stk-line.shift-date
          .
        end.
        assign
                                                                                                              temp-stk-line.new-fact-qnty      = temp-stk-line.new-fact-qnty      + temp-ot-line.new-fact-qnty      - temp-ot-line.fact-qnty           temp-stk-line.new-sum-base       = temp-stk-line.new-sum-base       + temp-ot-line.new-sum-base       - temp-ot-line.sum-base            temp-stk-line.new-sum-rubl       = temp-stk-line.new-sum-rubl       + temp-ot-line.new-sum-rubl       - temp-ot-line.sum-rubl            temp-stk-line.new-vat-base       = temp-stk-line.new-vat-base       + temp-ot-line.new-vat-base       - temp-ot-line.vat-base            temp-stk-line.new-vat-rubl       = temp-stk-line.new-vat-rubl       + temp-ot-line.new-vat-rubl       - temp-ot-line.vat-rubl            temp-stk-line.new-slt-base       = temp-stk-line.new-slt-base       + temp-ot-line.new-slt-base       - temp-ot-line.slt-base            temp-stk-line.new-slt-rubl       = temp-stk-line.new-slt-rubl       + temp-ot-line.new-slt-rubl       - temp-ot-line.slt-rubl            temp-stk-line.new-road-tax-base  = temp-stk-line.new-road-tax-base  + temp-ot-line.new-road-tax-base  - temp-ot-line.road-tax-base       temp-stk-line.new-road-tax-rubl  = temp-stk-line.new-road-tax-rubl  + temp-ot-line.new-road-tax-rubl  - temp-ot-line.road-tax-rubl       temp-stk-line.new-excise-base    = temp-stk-line.new-excise-base    + temp-ot-line.new-excise-base    - temp-ot-line.excise-base         temp-stk-line.new-excise-rubl    = temp-stk-line.new-excise-rubl    + temp-ot-line.new-excise-rubl    - temp-ot-line.excise-rubl         temp-stk-line.new-transport-base = temp-stk-line.new-transport-base + temp-ot-line.new-transport-base - temp-ot-line.transport-base      temp-stk-line.new-transport-rubl = temp-stk-line.new-transport-rubl + temp-ot-line.new-transport-rubl - temp-ot-line.transport-rubl      temp-stk-line.new-other-base     = temp-stk-line.new-other-base     + temp-ot-line.new-other-base     - temp-ot-line.other-base          temp-stk-line.new-other-rubl     = temp-stk-line.new-other-rubl     + temp-ot-line.new-other-rubl     - temp-ot-line.other-rubl
        .
      end.
      if v-shift-on
      then do:
        for each root-temp-shift-stk-line
          where root-temp-shift-stk-line.obj-type  = temp-ot-line.obj-type
            and root-temp-shift-stk-line.obj-code  = temp-ot-line.obj-code
            and root-temp-shift-stk-line.artic     = temp-ot-line.artic
            and root-temp-shift-stk-line.prod-type = temp-ot-line.prod-type
            and root-temp-shift-stk-line.prod-code = temp-ot-line.prod-code
            and root-temp-shift-stk-line.sum-type  = 'cost':U
            and root-temp-shift-stk-line.cat-id    = '##,##':U
        on error undo, return error
        :
          find first temp-shift-stk-line
            where temp-shift-stk-line.obj-type   = temp-ot-line.obj-type
              and temp-shift-stk-line.obj-code   = temp-ot-line.obj-code
              and temp-shift-stk-line.artic      = temp-ot-line.artic
              and temp-shift-stk-line.prod-type  = temp-ot-line.prod-type
              and temp-shift-stk-line.prod-code  = temp-ot-line.prod-code
              and temp-shift-stk-line.fact-order = root-temp-shift-stk-line.fact-order
              and temp-shift-stk-line.sum-type   = temp-ot-line.sum-type
              and temp-shift-stk-line.cat-id     = temp-ot-line.cat-id
            no-error .
          if not available temp-shift-stk-line
          then do:
            create temp-shift-stk-line .
            assign
              temp-shift-stk-line.obj-type   = temp-ot-line.obj-type
              temp-shift-stk-line.obj-code   = temp-ot-line.obj-code
              temp-shift-stk-line.artic      = temp-ot-line.artic
              temp-shift-stk-line.prod-type  = temp-ot-line.prod-type
              temp-shift-stk-line.prod-code  = temp-ot-line.prod-code
              temp-shift-stk-line.fact-order = root-temp-shift-stk-line.fact-order
              temp-shift-stk-line.sum-type   = temp-ot-line.sum-type
              temp-shift-stk-line.cat-id     = temp-ot-line.cat-id
              temp-shift-stk-line.fact-date  = root-temp-shift-stk-line.fact-date
              temp-shift-stk-line.shift-num  = root-temp-shift-stk-line.shift-num
              temp-shift-stk-line.shift-date = root-temp-shift-stk-line.shift-date
            .
          end.
          assign
                                                                                                                                    temp-shift-stk-line.new-fact-qnty      = temp-shift-stk-line.new-fact-qnty      + temp-ot-line.new-fact-qnty      - temp-ot-line.fact-qnty           temp-shift-stk-line.new-sum-base       = temp-shift-stk-line.new-sum-base       + temp-ot-line.new-sum-base       - temp-ot-line.sum-base            temp-shift-stk-line.new-sum-rubl       = temp-shift-stk-line.new-sum-rubl       + temp-ot-line.new-sum-rubl       - temp-ot-line.sum-rubl            temp-shift-stk-line.new-vat-base       = temp-shift-stk-line.new-vat-base       + temp-ot-line.new-vat-base       - temp-ot-line.vat-base            temp-shift-stk-line.new-vat-rubl       = temp-shift-stk-line.new-vat-rubl       + temp-ot-line.new-vat-rubl       - temp-ot-line.vat-rubl            temp-shift-stk-line.new-slt-base       = temp-shift-stk-line.new-slt-base       + temp-ot-line.new-slt-base       - temp-ot-line.slt-base            temp-shift-stk-line.new-slt-rubl       = temp-shift-stk-line.new-slt-rubl       + temp-ot-line.new-slt-rubl       - temp-ot-line.slt-rubl            temp-shift-stk-line.new-road-tax-base  = temp-shift-stk-line.new-road-tax-base  + temp-ot-line.new-road-tax-base  - temp-ot-line.road-tax-base       temp-shift-stk-line.new-road-tax-rubl  = temp-shift-stk-line.new-road-tax-rubl  + temp-ot-line.new-road-tax-rubl  - temp-ot-line.road-tax-rubl       temp-shift-stk-line.new-excise-base    = temp-shift-stk-line.new-excise-base    + temp-ot-line.new-excise-base    - temp-ot-line.excise-base         temp-shift-stk-line.new-excise-rubl    = temp-shift-stk-line.new-excise-rubl    + temp-ot-line.new-excise-rubl    - temp-ot-line.excise-rubl         temp-shift-stk-line.new-transport-base = temp-shift-stk-line.new-transport-base + temp-ot-line.new-transport-base - temp-ot-line.transport-base      temp-shift-stk-line.new-transport-rubl = temp-shift-stk-line.new-transport-rubl + temp-ot-line.new-transport-rubl - temp-ot-line.transport-rubl      temp-shift-stk-line.new-other-base     = temp-shift-stk-line.new-other-base     + temp-ot-line.new-other-base     - temp-ot-line.other-base          temp-shift-stk-line.new-other-rubl     = temp-shift-stk-line.new-other-rubl     + temp-ot-line.new-other-rubl     - temp-ot-line.other-rubl
          .
        end.
      end.
    end.
    for each temp-ot-line
      where temp-ot-line.sum-type = 'sale':U
        and (
                                          temp-ot-line.fact-qnty      <> temp-ot-line.new-fact-qnty        or    temp-ot-line.sum-base       <> temp-ot-line.new-sum-base         or    temp-ot-line.sum-rubl       <> temp-ot-line.new-sum-rubl         or    temp-ot-line.vat-base       <> temp-ot-line.new-vat-base         or    temp-ot-line.vat-rubl       <> temp-ot-line.new-vat-rubl         or    temp-ot-line.slt-base       <> temp-ot-line.new-slt-base         or    temp-ot-line.slt-rubl       <> temp-ot-line.new-slt-rubl         or    temp-ot-line.road-tax-base  <> temp-ot-line.new-road-tax-base    or    temp-ot-line.road-tax-rubl  <> temp-ot-line.new-road-tax-rubl    or    temp-ot-line.excise-base    <> temp-ot-line.new-excise-base      or    temp-ot-line.excise-rubl    <> temp-ot-line.new-excise-rubl      or    temp-ot-line.transport-base <> temp-ot-line.new-transport-base   or    temp-ot-line.transport-rubl <> temp-ot-line.new-transport-rubl   or    temp-ot-line.other-base     <> temp-ot-line.new-other-base       or    temp-ot-line.other-rubl     <> temp-ot-line.new-other-rubl
            )
    on error undo, return error
    :
      for each root-temp-stk-line
        where root-temp-stk-line.obj-type  = temp-ot-line.obj-type
          and root-temp-stk-line.obj-code  = temp-ot-line.obj-code
          and root-temp-stk-line.artic     = temp-ot-line.artic
          and root-temp-stk-line.prod-type = temp-ot-line.prod-type
          and root-temp-stk-line.prod-code = temp-ot-line.prod-code
          and root-temp-stk-line.sum-type  = 'sadt':U + ub.trn-doc.ext-doc-type
          and root-temp-stk-line.cat-id    = '##,##':U
      on error undo, return error
      :
        find first temp-stk-line
          where temp-stk-line.obj-type   = temp-ot-line.obj-type
            and temp-stk-line.obj-code   = temp-ot-line.obj-code
            and temp-stk-line.artic      = temp-ot-line.artic
            and temp-stk-line.prod-type  = temp-ot-line.prod-type
            and temp-stk-line.prod-code  = temp-ot-line.prod-code
            and temp-stk-line.fact-order = root-temp-stk-line.fact-order
            and temp-stk-line.sum-type   = root-temp-stk-line.sum-type
            and temp-stk-line.cat-id     = '##,##':U
          no-error .
        if not available temp-stk-line
        then do:
          create temp-stk-line .
          assign
            temp-stk-line.obj-type   = temp-ot-line.obj-type
            temp-stk-line.obj-code   = temp-ot-line.obj-code
            temp-stk-line.artic      = temp-ot-line.artic
            temp-stk-line.prod-type  = temp-ot-line.prod-type
            temp-stk-line.prod-code  = temp-ot-line.prod-code
            temp-stk-line.fact-order = root-temp-stk-line.fact-order
            temp-stk-line.sum-type   = root-temp-stk-line.sum-type
            temp-stk-line.cat-id     = '##,##':U
            temp-stk-line.fact-date  = root-temp-stk-line.fact-date
            temp-stk-line.shift-num  = root-temp-stk-line.shift-num
            temp-stk-line.shift-date = root-temp-stk-line.shift-date
          .
        end.
        assign
                                                                                                              temp-stk-line.new-fact-qnty      = temp-stk-line.new-fact-qnty      + temp-ot-line.new-fact-qnty      - temp-ot-line.fact-qnty           temp-stk-line.new-sum-base       = temp-stk-line.new-sum-base       + temp-ot-line.new-sum-base       - temp-ot-line.sum-base            temp-stk-line.new-sum-rubl       = temp-stk-line.new-sum-rubl       + temp-ot-line.new-sum-rubl       - temp-ot-line.sum-rubl            temp-stk-line.new-vat-base       = temp-stk-line.new-vat-base       + temp-ot-line.new-vat-base       - temp-ot-line.vat-base            temp-stk-line.new-vat-rubl       = temp-stk-line.new-vat-rubl       + temp-ot-line.new-vat-rubl       - temp-ot-line.vat-rubl            temp-stk-line.new-slt-base       = temp-stk-line.new-slt-base       + temp-ot-line.new-slt-base       - temp-ot-line.slt-base            temp-stk-line.new-slt-rubl       = temp-stk-line.new-slt-rubl       + temp-ot-line.new-slt-rubl       - temp-ot-line.slt-rubl            temp-stk-line.new-road-tax-base  = temp-stk-line.new-road-tax-base  + temp-ot-line.new-road-tax-base  - temp-ot-line.road-tax-base       temp-stk-line.new-road-tax-rubl  = temp-stk-line.new-road-tax-rubl  + temp-ot-line.new-road-tax-rubl  - temp-ot-line.road-tax-rubl       temp-stk-line.new-excise-base    = temp-stk-line.new-excise-base    + temp-ot-line.new-excise-base    - temp-ot-line.excise-base         temp-stk-line.new-excise-rubl    = temp-stk-line.new-excise-rubl    + temp-ot-line.new-excise-rubl    - temp-ot-line.excise-rubl         temp-stk-line.new-transport-base = temp-stk-line.new-transport-base + temp-ot-line.new-transport-base - temp-ot-line.transport-base      temp-stk-line.new-transport-rubl = temp-stk-line.new-transport-rubl + temp-ot-line.new-transport-rubl - temp-ot-line.transport-rubl      temp-stk-line.new-other-base     = temp-stk-line.new-other-base     + temp-ot-line.new-other-base     - temp-ot-line.other-base          temp-stk-line.new-other-rubl     = temp-stk-line.new-other-rubl     + temp-ot-line.new-other-rubl     - temp-ot-line.other-rubl
        .
      end.
      if v-shift-on
      then do:
        for each root-temp-shift-stk-line
          where root-temp-shift-stk-line.obj-type  = temp-ot-line.obj-type
            and root-temp-shift-stk-line.obj-code  = temp-ot-line.obj-code
            and root-temp-shift-stk-line.artic     = temp-ot-line.artic
            and root-temp-shift-stk-line.prod-type = temp-ot-line.prod-type
            and root-temp-shift-stk-line.prod-code = temp-ot-line.prod-code
            and root-temp-shift-stk-line.sum-type  = 'sadt':U + ub.trn-doc.ext-doc-type
            and root-temp-shift-stk-line.cat-id    = '##,##':U
        on error undo, return error
        :
          find first temp-shift-stk-line
            where temp-shift-stk-line.obj-type   = temp-ot-line.obj-type
              and temp-shift-stk-line.obj-code   = temp-ot-line.obj-code
              and temp-shift-stk-line.artic      = temp-ot-line.artic
              and temp-shift-stk-line.prod-type  = temp-ot-line.prod-type
              and temp-shift-stk-line.prod-code  = temp-ot-line.prod-code
              and temp-shift-stk-line.fact-order = root-temp-shift-stk-line.fact-order
              and temp-shift-stk-line.sum-type   = root-temp-shift-stk-line.sum-type
              and temp-shift-stk-line.cat-id     = '##,##':U
            no-error .
          if not available temp-shift-stk-line
          then do:
            create temp-shift-stk-line .
            assign
              temp-shift-stk-line.obj-type   = temp-ot-line.obj-type
              temp-shift-stk-line.obj-code   = temp-ot-line.obj-code
              temp-shift-stk-line.artic      = temp-ot-line.artic
              temp-shift-stk-line.prod-type  = temp-ot-line.prod-type
              temp-shift-stk-line.prod-code  = temp-ot-line.prod-code
              temp-shift-stk-line.fact-order = root-temp-shift-stk-line.fact-order
              temp-shift-stk-line.sum-type   = root-temp-shift-stk-line.sum-type
              temp-shift-stk-line.cat-id     = '##,##':U
              temp-shift-stk-line.fact-date  = root-temp-shift-stk-line.fact-date
              temp-shift-stk-line.shift-num  = root-temp-shift-stk-line.shift-num
              temp-shift-stk-line.shift-date = root-temp-shift-stk-line.shift-date
            .
          end.
          assign
                                                                                                                                    temp-shift-stk-line.new-fact-qnty      = temp-shift-stk-line.new-fact-qnty      + temp-ot-line.new-fact-qnty      - temp-ot-line.fact-qnty           temp-shift-stk-line.new-sum-base       = temp-shift-stk-line.new-sum-base       + temp-ot-line.new-sum-base       - temp-ot-line.sum-base            temp-shift-stk-line.new-sum-rubl       = temp-shift-stk-line.new-sum-rubl       + temp-ot-line.new-sum-rubl       - temp-ot-line.sum-rubl            temp-shift-stk-line.new-vat-base       = temp-shift-stk-line.new-vat-base       + temp-ot-line.new-vat-base       - temp-ot-line.vat-base            temp-shift-stk-line.new-vat-rubl       = temp-shift-stk-line.new-vat-rubl       + temp-ot-line.new-vat-rubl       - temp-ot-line.vat-rubl            temp-shift-stk-line.new-slt-base       = temp-shift-stk-line.new-slt-base       + temp-ot-line.new-slt-base       - temp-ot-line.slt-base            temp-shift-stk-line.new-slt-rubl       = temp-shift-stk-line.new-slt-rubl       + temp-ot-line.new-slt-rubl       - temp-ot-line.slt-rubl            temp-shift-stk-line.new-road-tax-base  = temp-shift-stk-line.new-road-tax-base  + temp-ot-line.new-road-tax-base  - temp-ot-line.road-tax-base       temp-shift-stk-line.new-road-tax-rubl  = temp-shift-stk-line.new-road-tax-rubl  + temp-ot-line.new-road-tax-rubl  - temp-ot-line.road-tax-rubl       temp-shift-stk-line.new-excise-base    = temp-shift-stk-line.new-excise-base    + temp-ot-line.new-excise-base    - temp-ot-line.excise-base         temp-shift-stk-line.new-excise-rubl    = temp-shift-stk-line.new-excise-rubl    + temp-ot-line.new-excise-rubl    - temp-ot-line.excise-rubl         temp-shift-stk-line.new-transport-base = temp-shift-stk-line.new-transport-base + temp-ot-line.new-transport-base - temp-ot-line.transport-base      temp-shift-stk-line.new-transport-rubl = temp-shift-stk-line.new-transport-rubl + temp-ot-line.new-transport-rubl - temp-ot-line.transport-rubl      temp-shift-stk-line.new-other-base     = temp-shift-stk-line.new-other-base     + temp-ot-line.new-other-base     - temp-ot-line.other-base          temp-shift-stk-line.new-other-rubl     = temp-shift-stk-line.new-other-rubl     + temp-ot-line.new-other-rubl     - temp-ot-line.other-rubl
          .
        end.
      end.
    end.
    for each temp-ot-line
      where temp-ot-line.sum-type = 'sasr':U
        and (
                                          temp-ot-line.fact-qnty      <> temp-ot-line.new-fact-qnty        or    temp-ot-line.sum-base       <> temp-ot-line.new-sum-base         or    temp-ot-line.sum-rubl       <> temp-ot-line.new-sum-rubl         or    temp-ot-line.vat-base       <> temp-ot-line.new-vat-base         or    temp-ot-line.vat-rubl       <> temp-ot-line.new-vat-rubl         or    temp-ot-line.slt-base       <> temp-ot-line.new-slt-base         or    temp-ot-line.slt-rubl       <> temp-ot-line.new-slt-rubl         or    temp-ot-line.road-tax-base  <> temp-ot-line.new-road-tax-base    or    temp-ot-line.road-tax-rubl  <> temp-ot-line.new-road-tax-rubl    or    temp-ot-line.excise-base    <> temp-ot-line.new-excise-base      or    temp-ot-line.excise-rubl    <> temp-ot-line.new-excise-rubl      or    temp-ot-line.transport-base <> temp-ot-line.new-transport-base   or    temp-ot-line.transport-rubl <> temp-ot-line.new-transport-rubl   or    temp-ot-line.other-base     <> temp-ot-line.new-other-base       or    temp-ot-line.other-rubl     <> temp-ot-line.new-other-rubl
            )
    on error undo, return error
    :
      for each root-temp-stk-line
        where root-temp-stk-line.obj-type  = temp-ot-line.obj-type
          and root-temp-stk-line.obj-code  = temp-ot-line.obj-code
          and root-temp-stk-line.artic     = temp-ot-line.artic
          and root-temp-stk-line.prod-type = temp-ot-line.prod-type
          and root-temp-stk-line.prod-code = temp-ot-line.prod-code
          and root-temp-stk-line.sum-type  = 'adsr':U + ub.trn-doc.ext-doc-type
          and root-temp-stk-line.cat-id    = '##,##':U
      on error undo, return error
      :
        find first temp-stk-line
          where temp-stk-line.obj-type   = temp-ot-line.obj-type
            and temp-stk-line.obj-code   = temp-ot-line.obj-code
            and temp-stk-line.artic      = temp-ot-line.artic
            and temp-stk-line.prod-type  = temp-ot-line.prod-type
            and temp-stk-line.prod-code  = temp-ot-line.prod-code
            and temp-stk-line.fact-order = root-temp-stk-line.fact-order
            and temp-stk-line.sum-type   = root-temp-stk-line.sum-type
            and temp-stk-line.cat-id     = '##,##':U
          no-error .
        if not available temp-stk-line
        then do:
          create temp-stk-line .
          assign
            temp-stk-line.obj-type   = temp-ot-line.obj-type
            temp-stk-line.obj-code   = temp-ot-line.obj-code
            temp-stk-line.artic      = temp-ot-line.artic
            temp-stk-line.prod-type  = temp-ot-line.prod-type
            temp-stk-line.prod-code  = temp-ot-line.prod-code
            temp-stk-line.fact-order = root-temp-stk-line.fact-order
            temp-stk-line.sum-type   = root-temp-stk-line.sum-type
            temp-stk-line.cat-id     = '##,##':U
            temp-stk-line.fact-date  = root-temp-stk-line.fact-date
            temp-stk-line.shift-num  = root-temp-stk-line.shift-num
            temp-stk-line.shift-date = root-temp-stk-line.shift-date
          .
        end.
        assign
                                                                                                              temp-stk-line.new-fact-qnty      = temp-stk-line.new-fact-qnty      + temp-ot-line.new-fact-qnty      - temp-ot-line.fact-qnty           temp-stk-line.new-sum-base       = temp-stk-line.new-sum-base       + temp-ot-line.new-sum-base       - temp-ot-line.sum-base            temp-stk-line.new-sum-rubl       = temp-stk-line.new-sum-rubl       + temp-ot-line.new-sum-rubl       - temp-ot-line.sum-rubl            temp-stk-line.new-vat-base       = temp-stk-line.new-vat-base       + temp-ot-line.new-vat-base       - temp-ot-line.vat-base            temp-stk-line.new-vat-rubl       = temp-stk-line.new-vat-rubl       + temp-ot-line.new-vat-rubl       - temp-ot-line.vat-rubl            temp-stk-line.new-slt-base       = temp-stk-line.new-slt-base       + temp-ot-line.new-slt-base       - temp-ot-line.slt-base            temp-stk-line.new-slt-rubl       = temp-stk-line.new-slt-rubl       + temp-ot-line.new-slt-rubl       - temp-ot-line.slt-rubl            temp-stk-line.new-road-tax-base  = temp-stk-line.new-road-tax-base  + temp-ot-line.new-road-tax-base  - temp-ot-line.road-tax-base       temp-stk-line.new-road-tax-rubl  = temp-stk-line.new-road-tax-rubl  + temp-ot-line.new-road-tax-rubl  - temp-ot-line.road-tax-rubl       temp-stk-line.new-excise-base    = temp-stk-line.new-excise-base    + temp-ot-line.new-excise-base    - temp-ot-line.excise-base         temp-stk-line.new-excise-rubl    = temp-stk-line.new-excise-rubl    + temp-ot-line.new-excise-rubl    - temp-ot-line.excise-rubl         temp-stk-line.new-transport-base = temp-stk-line.new-transport-base + temp-ot-line.new-transport-base - temp-ot-line.transport-base      temp-stk-line.new-transport-rubl = temp-stk-line.new-transport-rubl + temp-ot-line.new-transport-rubl - temp-ot-line.transport-rubl      temp-stk-line.new-other-base     = temp-stk-line.new-other-base     + temp-ot-line.new-other-base     - temp-ot-line.other-base          temp-stk-line.new-other-rubl     = temp-stk-line.new-other-rubl     + temp-ot-line.new-other-rubl     - temp-ot-line.other-rubl
        .
      end.
      if v-shift-on
      then do:
        for each root-temp-shift-stk-line
          where root-temp-shift-stk-line.obj-type  = temp-ot-line.obj-type
            and root-temp-shift-stk-line.obj-code  = temp-ot-line.obj-code
            and root-temp-shift-stk-line.artic     = temp-ot-line.artic
            and root-temp-shift-stk-line.prod-type = temp-ot-line.prod-type
            and root-temp-shift-stk-line.prod-code = temp-ot-line.prod-code
            and root-temp-shift-stk-line.sum-type  = 'adsr':U + ub.trn-doc.ext-doc-type
            and root-temp-shift-stk-line.cat-id    = '##,##':U
        on error undo, return error
        :
          find first temp-shift-stk-line
            where temp-shift-stk-line.obj-type   = temp-ot-line.obj-type
              and temp-shift-stk-line.obj-code   = temp-ot-line.obj-code
              and temp-shift-stk-line.artic      = temp-ot-line.artic
              and temp-shift-stk-line.prod-type  = temp-ot-line.prod-type
              and temp-shift-stk-line.prod-code  = temp-ot-line.prod-code
              and temp-shift-stk-line.fact-order = root-temp-shift-stk-line.fact-order
              and temp-shift-stk-line.sum-type   = root-temp-shift-stk-line.sum-type
              and temp-shift-stk-line.cat-id     = '##,##':U
            no-error .
          if not available temp-shift-stk-line
          then do:
            create temp-shift-stk-line .
            assign
              temp-shift-stk-line.obj-type   = temp-ot-line.obj-type
              temp-shift-stk-line.obj-code   = temp-ot-line.obj-code
              temp-shift-stk-line.artic      = temp-ot-line.artic
              temp-shift-stk-line.prod-type  = temp-ot-line.prod-type
              temp-shift-stk-line.prod-code  = temp-ot-line.prod-code
              temp-shift-stk-line.fact-order = root-temp-shift-stk-line.fact-order
              temp-shift-stk-line.sum-type   = root-temp-shift-stk-line.sum-type
              temp-shift-stk-line.cat-id     = '##,##':U
              temp-shift-stk-line.fact-date  = root-temp-shift-stk-line.fact-date
              temp-shift-stk-line.shift-num  = root-temp-shift-stk-line.shift-num
              temp-shift-stk-line.shift-date = root-temp-shift-stk-line.shift-date
            .
          end.
          assign
                                                                                                                                    temp-shift-stk-line.new-fact-qnty      = temp-shift-stk-line.new-fact-qnty      + temp-ot-line.new-fact-qnty      - temp-ot-line.fact-qnty           temp-shift-stk-line.new-sum-base       = temp-shift-stk-line.new-sum-base       + temp-ot-line.new-sum-base       - temp-ot-line.sum-base            temp-shift-stk-line.new-sum-rubl       = temp-shift-stk-line.new-sum-rubl       + temp-ot-line.new-sum-rubl       - temp-ot-line.sum-rubl            temp-shift-stk-line.new-vat-base       = temp-shift-stk-line.new-vat-base       + temp-ot-line.new-vat-base       - temp-ot-line.vat-base            temp-shift-stk-line.new-vat-rubl       = temp-shift-stk-line.new-vat-rubl       + temp-ot-line.new-vat-rubl       - temp-ot-line.vat-rubl            temp-shift-stk-line.new-slt-base       = temp-shift-stk-line.new-slt-base       + temp-ot-line.new-slt-base       - temp-ot-line.slt-base            temp-shift-stk-line.new-slt-rubl       = temp-shift-stk-line.new-slt-rubl       + temp-ot-line.new-slt-rubl       - temp-ot-line.slt-rubl            temp-shift-stk-line.new-road-tax-base  = temp-shift-stk-line.new-road-tax-base  + temp-ot-line.new-road-tax-base  - temp-ot-line.road-tax-base       temp-shift-stk-line.new-road-tax-rubl  = temp-shift-stk-line.new-road-tax-rubl  + temp-ot-line.new-road-tax-rubl  - temp-ot-line.road-tax-rubl       temp-shift-stk-line.new-excise-base    = temp-shift-stk-line.new-excise-base    + temp-ot-line.new-excise-base    - temp-ot-line.excise-base         temp-shift-stk-line.new-excise-rubl    = temp-shift-stk-line.new-excise-rubl    + temp-ot-line.new-excise-rubl    - temp-ot-line.excise-rubl         temp-shift-stk-line.new-transport-base = temp-shift-stk-line.new-transport-base + temp-ot-line.new-transport-base - temp-ot-line.transport-base      temp-shift-stk-line.new-transport-rubl = temp-shift-stk-line.new-transport-rubl + temp-ot-line.new-transport-rubl - temp-ot-line.transport-rubl      temp-shift-stk-line.new-other-base     = temp-shift-stk-line.new-other-base     + temp-ot-line.new-other-base     - temp-ot-line.other-base          temp-shift-stk-line.new-other-rubl     = temp-shift-stk-line.new-other-rubl     + temp-ot-line.new-other-rubl     - temp-ot-line.other-rubl
          .
        end.
      end.
    end.
    for each temp-ot-line
      where temp-ot-line.sum-type = 'crsa':U
        and (
                                          temp-ot-line.fact-qnty      <> temp-ot-line.new-fact-qnty        or    temp-ot-line.sum-base       <> temp-ot-line.new-sum-base         or    temp-ot-line.sum-rubl       <> temp-ot-line.new-sum-rubl         or    temp-ot-line.vat-base       <> temp-ot-line.new-vat-base         or    temp-ot-line.vat-rubl       <> temp-ot-line.new-vat-rubl         or    temp-ot-line.slt-base       <> temp-ot-line.new-slt-base         or    temp-ot-line.slt-rubl       <> temp-ot-line.new-slt-rubl         or    temp-ot-line.road-tax-base  <> temp-ot-line.new-road-tax-base    or    temp-ot-line.road-tax-rubl  <> temp-ot-line.new-road-tax-rubl    or    temp-ot-line.excise-base    <> temp-ot-line.new-excise-base      or    temp-ot-line.excise-rubl    <> temp-ot-line.new-excise-rubl      or    temp-ot-line.transport-base <> temp-ot-line.new-transport-base   or    temp-ot-line.transport-rubl <> temp-ot-line.new-transport-rubl   or    temp-ot-line.other-base     <> temp-ot-line.new-other-base       or    temp-ot-line.other-rubl     <> temp-ot-line.new-other-rubl
            )
    on error undo, return error
    :
      for each root-temp-stk-line
        where root-temp-stk-line.obj-type  = temp-ot-line.obj-type
          and root-temp-stk-line.obj-code  = temp-ot-line.obj-code
          and root-temp-stk-line.artic     = temp-ot-line.artic
          and root-temp-stk-line.prod-type = temp-ot-line.prod-type
          and root-temp-stk-line.prod-code = temp-ot-line.prod-code
          and root-temp-stk-line.sum-type  = 'cgdt':U + ub.trn-doc.ext-doc-type
          and root-temp-stk-line.cat-id    = '##,##':U
      on error undo, return error
      :
        find first temp-stk-line
          where temp-stk-line.obj-type   = temp-ot-line.obj-type
            and temp-stk-line.obj-code   = temp-ot-line.obj-code
            and temp-stk-line.artic      = temp-ot-line.artic
            and temp-stk-line.prod-type  = temp-ot-line.prod-type
            and temp-stk-line.prod-code  = temp-ot-line.prod-code
            and temp-stk-line.fact-order = root-temp-stk-line.fact-order
            and temp-stk-line.sum-type   = root-temp-stk-line.sum-type
            and temp-stk-line.cat-id     = '##,##':U
          no-error .
        if not available temp-stk-line
        then do:
          create temp-stk-line .
          assign
            temp-stk-line.obj-type   = temp-ot-line.obj-type
            temp-stk-line.obj-code   = temp-ot-line.obj-code
            temp-stk-line.artic      = temp-ot-line.artic
            temp-stk-line.prod-type  = temp-ot-line.prod-type
            temp-stk-line.prod-code  = temp-ot-line.prod-code
            temp-stk-line.fact-order = root-temp-stk-line.fact-order
            temp-stk-line.sum-type   = root-temp-stk-line.sum-type
            temp-stk-line.cat-id     = '##,##':U
            temp-stk-line.fact-date  = root-temp-stk-line.fact-date
            temp-stk-line.shift-num  = root-temp-stk-line.shift-num
            temp-stk-line.shift-date = root-temp-stk-line.shift-date
          .
        end.
        assign
                                                                                                              temp-stk-line.new-fact-qnty      = temp-stk-line.new-fact-qnty      + temp-ot-line.new-fact-qnty      - temp-ot-line.fact-qnty           temp-stk-line.new-sum-base       = temp-stk-line.new-sum-base       + temp-ot-line.new-sum-base       - temp-ot-line.sum-base            temp-stk-line.new-sum-rubl       = temp-stk-line.new-sum-rubl       + temp-ot-line.new-sum-rubl       - temp-ot-line.sum-rubl            temp-stk-line.new-vat-base       = temp-stk-line.new-vat-base       + temp-ot-line.new-vat-base       - temp-ot-line.vat-base            temp-stk-line.new-vat-rubl       = temp-stk-line.new-vat-rubl       + temp-ot-line.new-vat-rubl       - temp-ot-line.vat-rubl            temp-stk-line.new-slt-base       = temp-stk-line.new-slt-base       + temp-ot-line.new-slt-base       - temp-ot-line.slt-base            temp-stk-line.new-slt-rubl       = temp-stk-line.new-slt-rubl       + temp-ot-line.new-slt-rubl       - temp-ot-line.slt-rubl            temp-stk-line.new-road-tax-base  = temp-stk-line.new-road-tax-base  + temp-ot-line.new-road-tax-base  - temp-ot-line.road-tax-base       temp-stk-line.new-road-tax-rubl  = temp-stk-line.new-road-tax-rubl  + temp-ot-line.new-road-tax-rubl  - temp-ot-line.road-tax-rubl       temp-stk-line.new-excise-base    = temp-stk-line.new-excise-base    + temp-ot-line.new-excise-base    - temp-ot-line.excise-base         temp-stk-line.new-excise-rubl    = temp-stk-line.new-excise-rubl    + temp-ot-line.new-excise-rubl    - temp-ot-line.excise-rubl         temp-stk-line.new-transport-base = temp-stk-line.new-transport-base + temp-ot-line.new-transport-base - temp-ot-line.transport-base      temp-stk-line.new-transport-rubl = temp-stk-line.new-transport-rubl + temp-ot-line.new-transport-rubl - temp-ot-line.transport-rubl      temp-stk-line.new-other-base     = temp-stk-line.new-other-base     + temp-ot-line.new-other-base     - temp-ot-line.other-base          temp-stk-line.new-other-rubl     = temp-stk-line.new-other-rubl     + temp-ot-line.new-other-rubl     - temp-ot-line.other-rubl
        .
      end.
      if v-shift-on
      then do:
        for each root-temp-shift-stk-line
          where root-temp-shift-stk-line.obj-type  = temp-ot-line.obj-type
            and root-temp-shift-stk-line.obj-code  = temp-ot-line.obj-code
            and root-temp-shift-stk-line.artic     = temp-ot-line.artic
            and root-temp-shift-stk-line.prod-type = temp-ot-line.prod-type
            and root-temp-shift-stk-line.prod-code = temp-ot-line.prod-code
            and root-temp-shift-stk-line.sum-type  = 'cgdt':U + ub.trn-doc.ext-doc-type
            and root-temp-shift-stk-line.cat-id    = '##,##':U
        on error undo, return error
        :
          find first temp-shift-stk-line
            where temp-shift-stk-line.obj-type   = temp-ot-line.obj-type
              and temp-shift-stk-line.obj-code   = temp-ot-line.obj-code
              and temp-shift-stk-line.artic      = temp-ot-line.artic
              and temp-shift-stk-line.prod-type  = temp-ot-line.prod-type
              and temp-shift-stk-line.prod-code  = temp-ot-line.prod-code
              and temp-shift-stk-line.fact-order = root-temp-shift-stk-line.fact-order
              and temp-shift-stk-line.sum-type   = root-temp-shift-stk-line.sum-type
              and temp-shift-stk-line.cat-id     = '##,##':U
            no-error .
          if not available temp-shift-stk-line
          then do:
            create temp-shift-stk-line .
            assign
              temp-shift-stk-line.obj-type   = temp-ot-line.obj-type
              temp-shift-stk-line.obj-code   = temp-ot-line.obj-code
              temp-shift-stk-line.artic      = temp-ot-line.artic
              temp-shift-stk-line.prod-type  = temp-ot-line.prod-type
              temp-shift-stk-line.prod-code  = temp-ot-line.prod-code
              temp-shift-stk-line.fact-order = root-temp-shift-stk-line.fact-order
              temp-shift-stk-line.sum-type   = root-temp-shift-stk-line.sum-type
              temp-shift-stk-line.cat-id     = '##,##':U
              temp-shift-stk-line.fact-date  = root-temp-shift-stk-line.fact-date
              temp-shift-stk-line.shift-num  = root-temp-shift-stk-line.shift-num
              temp-shift-stk-line.shift-date = root-temp-shift-stk-line.shift-date
            .
          end.
          assign
                                                                                                                                    temp-shift-stk-line.new-fact-qnty      = temp-shift-stk-line.new-fact-qnty      + temp-ot-line.new-fact-qnty      - temp-ot-line.fact-qnty           temp-shift-stk-line.new-sum-base       = temp-shift-stk-line.new-sum-base       + temp-ot-line.new-sum-base       - temp-ot-line.sum-base            temp-shift-stk-line.new-sum-rubl       = temp-shift-stk-line.new-sum-rubl       + temp-ot-line.new-sum-rubl       - temp-ot-line.sum-rubl            temp-shift-stk-line.new-vat-base       = temp-shift-stk-line.new-vat-base       + temp-ot-line.new-vat-base       - temp-ot-line.vat-base            temp-shift-stk-line.new-vat-rubl       = temp-shift-stk-line.new-vat-rubl       + temp-ot-line.new-vat-rubl       - temp-ot-line.vat-rubl            temp-shift-stk-line.new-slt-base       = temp-shift-stk-line.new-slt-base       + temp-ot-line.new-slt-base       - temp-ot-line.slt-base            temp-shift-stk-line.new-slt-rubl       = temp-shift-stk-line.new-slt-rubl       + temp-ot-line.new-slt-rubl       - temp-ot-line.slt-rubl            temp-shift-stk-line.new-road-tax-base  = temp-shift-stk-line.new-road-tax-base  + temp-ot-line.new-road-tax-base  - temp-ot-line.road-tax-base       temp-shift-stk-line.new-road-tax-rubl  = temp-shift-stk-line.new-road-tax-rubl  + temp-ot-line.new-road-tax-rubl  - temp-ot-line.road-tax-rubl       temp-shift-stk-line.new-excise-base    = temp-shift-stk-line.new-excise-base    + temp-ot-line.new-excise-base    - temp-ot-line.excise-base         temp-shift-stk-line.new-excise-rubl    = temp-shift-stk-line.new-excise-rubl    + temp-ot-line.new-excise-rubl    - temp-ot-line.excise-rubl         temp-shift-stk-line.new-transport-base = temp-shift-stk-line.new-transport-base + temp-ot-line.new-transport-base - temp-ot-line.transport-base      temp-shift-stk-line.new-transport-rubl = temp-shift-stk-line.new-transport-rubl + temp-ot-line.new-transport-rubl - temp-ot-line.transport-rubl      temp-shift-stk-line.new-other-base     = temp-shift-stk-line.new-other-base     + temp-ot-line.new-other-base     - temp-ot-line.other-base          temp-shift-stk-line.new-other-rubl     = temp-shift-stk-line.new-other-rubl     + temp-ot-line.new-other-rubl     - temp-ot-line.other-rubl
          .
        end.
      end.
    end.
    for each temp-ot-line
      where temp-ot-line.sum-type = 'cgsr':U
        and (
                                          temp-ot-line.fact-qnty      <> temp-ot-line.new-fact-qnty        or    temp-ot-line.sum-base       <> temp-ot-line.new-sum-base         or    temp-ot-line.sum-rubl       <> temp-ot-line.new-sum-rubl         or    temp-ot-line.vat-base       <> temp-ot-line.new-vat-base         or    temp-ot-line.vat-rubl       <> temp-ot-line.new-vat-rubl         or    temp-ot-line.slt-base       <> temp-ot-line.new-slt-base         or    temp-ot-line.slt-rubl       <> temp-ot-line.new-slt-rubl         or    temp-ot-line.road-tax-base  <> temp-ot-line.new-road-tax-base    or    temp-ot-line.road-tax-rubl  <> temp-ot-line.new-road-tax-rubl    or    temp-ot-line.excise-base    <> temp-ot-line.new-excise-base      or    temp-ot-line.excise-rubl    <> temp-ot-line.new-excise-rubl      or    temp-ot-line.transport-base <> temp-ot-line.new-transport-base   or    temp-ot-line.transport-rubl <> temp-ot-line.new-transport-rubl   or    temp-ot-line.other-base     <> temp-ot-line.new-other-base       or    temp-ot-line.other-rubl     <> temp-ot-line.new-other-rubl
            )
    on error undo, return error
    :
      for each root-temp-stk-line
        where root-temp-stk-line.obj-type  = temp-ot-line.obj-type
          and root-temp-stk-line.obj-code  = temp-ot-line.obj-code
          and root-temp-stk-line.artic     = temp-ot-line.artic
          and root-temp-stk-line.prod-type = temp-ot-line.prod-type
          and root-temp-stk-line.prod-code = temp-ot-line.prod-code
          and root-temp-stk-line.sum-type  = 'gdsr':U + ub.trn-doc.ext-doc-type
          and root-temp-stk-line.cat-id    = '##,##':U
      on error undo, return error
      :
        find first temp-stk-line
          where temp-stk-line.obj-type   = temp-ot-line.obj-type
            and temp-stk-line.obj-code   = temp-ot-line.obj-code
            and temp-stk-line.artic      = temp-ot-line.artic
            and temp-stk-line.prod-type  = temp-ot-line.prod-type
            and temp-stk-line.prod-code  = temp-ot-line.prod-code
            and temp-stk-line.fact-order = root-temp-stk-line.fact-order
            and temp-stk-line.sum-type   = root-temp-stk-line.sum-type
            and temp-stk-line.cat-id     = '##,##':U
          no-error .
        if not available temp-stk-line
        then do:
          create temp-stk-line .
          assign
            temp-stk-line.obj-type   = temp-ot-line.obj-type
            temp-stk-line.obj-code   = temp-ot-line.obj-code
            temp-stk-line.artic      = temp-ot-line.artic
            temp-stk-line.prod-type  = temp-ot-line.prod-type
            temp-stk-line.prod-code  = temp-ot-line.prod-code
            temp-stk-line.fact-order = root-temp-stk-line.fact-order
            temp-stk-line.sum-type   = root-temp-stk-line.sum-type
            temp-stk-line.cat-id     = '##,##':U
            temp-stk-line.fact-date  = root-temp-stk-line.fact-date
            temp-stk-line.shift-num  = root-temp-stk-line.shift-num
            temp-stk-line.shift-date = root-temp-stk-line.shift-date
          .
        end.
        assign
                                                                                                              temp-stk-line.new-fact-qnty      = temp-stk-line.new-fact-qnty      + temp-ot-line.new-fact-qnty      - temp-ot-line.fact-qnty           temp-stk-line.new-sum-base       = temp-stk-line.new-sum-base       + temp-ot-line.new-sum-base       - temp-ot-line.sum-base            temp-stk-line.new-sum-rubl       = temp-stk-line.new-sum-rubl       + temp-ot-line.new-sum-rubl       - temp-ot-line.sum-rubl            temp-stk-line.new-vat-base       = temp-stk-line.new-vat-base       + temp-ot-line.new-vat-base       - temp-ot-line.vat-base            temp-stk-line.new-vat-rubl       = temp-stk-line.new-vat-rubl       + temp-ot-line.new-vat-rubl       - temp-ot-line.vat-rubl            temp-stk-line.new-slt-base       = temp-stk-line.new-slt-base       + temp-ot-line.new-slt-base       - temp-ot-line.slt-base            temp-stk-line.new-slt-rubl       = temp-stk-line.new-slt-rubl       + temp-ot-line.new-slt-rubl       - temp-ot-line.slt-rubl            temp-stk-line.new-road-tax-base  = temp-stk-line.new-road-tax-base  + temp-ot-line.new-road-tax-base  - temp-ot-line.road-tax-base       temp-stk-line.new-road-tax-rubl  = temp-stk-line.new-road-tax-rubl  + temp-ot-line.new-road-tax-rubl  - temp-ot-line.road-tax-rubl       temp-stk-line.new-excise-base    = temp-stk-line.new-excise-base    + temp-ot-line.new-excise-base    - temp-ot-line.excise-base         temp-stk-line.new-excise-rubl    = temp-stk-line.new-excise-rubl    + temp-ot-line.new-excise-rubl    - temp-ot-line.excise-rubl         temp-stk-line.new-transport-base = temp-stk-line.new-transport-base + temp-ot-line.new-transport-base - temp-ot-line.transport-base      temp-stk-line.new-transport-rubl = temp-stk-line.new-transport-rubl + temp-ot-line.new-transport-rubl - temp-ot-line.transport-rubl      temp-stk-line.new-other-base     = temp-stk-line.new-other-base     + temp-ot-line.new-other-base     - temp-ot-line.other-base          temp-stk-line.new-other-rubl     = temp-stk-line.new-other-rubl     + temp-ot-line.new-other-rubl     - temp-ot-line.other-rubl
        .
      end.
      if v-shift-on
      then do:
        for each root-temp-shift-stk-line
          where root-temp-shift-stk-line.obj-type  = temp-ot-line.obj-type
            and root-temp-shift-stk-line.obj-code  = temp-ot-line.obj-code
            and root-temp-shift-stk-line.artic     = temp-ot-line.artic
            and root-temp-shift-stk-line.prod-type = temp-ot-line.prod-type
            and root-temp-shift-stk-line.prod-code = temp-ot-line.prod-code
            and root-temp-shift-stk-line.sum-type  = 'gdsr':U + ub.trn-doc.ext-doc-type
            and root-temp-shift-stk-line.cat-id    = '##,##':U
        on error undo, return error
        :
          find first temp-shift-stk-line
            where temp-shift-stk-line.obj-type   = temp-ot-line.obj-type
              and temp-shift-stk-line.obj-code   = temp-ot-line.obj-code
              and temp-shift-stk-line.artic      = temp-ot-line.artic
              and temp-shift-stk-line.prod-type  = temp-ot-line.prod-type
              and temp-shift-stk-line.prod-code  = temp-ot-line.prod-code
              and temp-shift-stk-line.fact-order = root-temp-shift-stk-line.fact-order
              and temp-shift-stk-line.sum-type   = root-temp-shift-stk-line.sum-type
              and temp-shift-stk-line.cat-id     = '##,##':U
            no-error .
          if not available temp-shift-stk-line
          then do:
            create temp-shift-stk-line .
            assign
              temp-shift-stk-line.obj-type   = temp-ot-line.obj-type
              temp-shift-stk-line.obj-code   = temp-ot-line.obj-code
              temp-shift-stk-line.artic      = temp-ot-line.artic
              temp-shift-stk-line.prod-type  = temp-ot-line.prod-type
              temp-shift-stk-line.prod-code  = temp-ot-line.prod-code
              temp-shift-stk-line.fact-order = root-temp-shift-stk-line.fact-order
              temp-shift-stk-line.sum-type   = root-temp-shift-stk-line.sum-type
              temp-shift-stk-line.cat-id     = '##,##':U
              temp-shift-stk-line.fact-date  = root-temp-shift-stk-line.fact-date
              temp-shift-stk-line.shift-num  = root-temp-shift-stk-line.shift-num
              temp-shift-stk-line.shift-date = root-temp-shift-stk-line.shift-date
            .
          end.
          assign
                                                                                                                                    temp-shift-stk-line.new-fact-qnty      = temp-shift-stk-line.new-fact-qnty      + temp-ot-line.new-fact-qnty      - temp-ot-line.fact-qnty           temp-shift-stk-line.new-sum-base       = temp-shift-stk-line.new-sum-base       + temp-ot-line.new-sum-base       - temp-ot-line.sum-base            temp-shift-stk-line.new-sum-rubl       = temp-shift-stk-line.new-sum-rubl       + temp-ot-line.new-sum-rubl       - temp-ot-line.sum-rubl            temp-shift-stk-line.new-vat-base       = temp-shift-stk-line.new-vat-base       + temp-ot-line.new-vat-base       - temp-ot-line.vat-base            temp-shift-stk-line.new-vat-rubl       = temp-shift-stk-line.new-vat-rubl       + temp-ot-line.new-vat-rubl       - temp-ot-line.vat-rubl            temp-shift-stk-line.new-slt-base       = temp-shift-stk-line.new-slt-base       + temp-ot-line.new-slt-base       - temp-ot-line.slt-base            temp-shift-stk-line.new-slt-rubl       = temp-shift-stk-line.new-slt-rubl       + temp-ot-line.new-slt-rubl       - temp-ot-line.slt-rubl            temp-shift-stk-line.new-road-tax-base  = temp-shift-stk-line.new-road-tax-base  + temp-ot-line.new-road-tax-base  - temp-ot-line.road-tax-base       temp-shift-stk-line.new-road-tax-rubl  = temp-shift-stk-line.new-road-tax-rubl  + temp-ot-line.new-road-tax-rubl  - temp-ot-line.road-tax-rubl       temp-shift-stk-line.new-excise-base    = temp-shift-stk-line.new-excise-base    + temp-ot-line.new-excise-base    - temp-ot-line.excise-base         temp-shift-stk-line.new-excise-rubl    = temp-shift-stk-line.new-excise-rubl    + temp-ot-line.new-excise-rubl    - temp-ot-line.excise-rubl         temp-shift-stk-line.new-transport-base = temp-shift-stk-line.new-transport-base + temp-ot-line.new-transport-base - temp-ot-line.transport-base      temp-shift-stk-line.new-transport-rubl = temp-shift-stk-line.new-transport-rubl + temp-ot-line.new-transport-rubl - temp-ot-line.transport-rubl      temp-shift-stk-line.new-other-base     = temp-shift-stk-line.new-other-base     + temp-ot-line.new-other-base     - temp-ot-line.other-base          temp-shift-stk-line.new-other-rubl     = temp-shift-stk-line.new-other-rubl     + temp-ot-line.new-other-rubl     - temp-ot-line.other-rubl
          .
        end.
      end.
    end.
    for each temp-ot-line
      where temp-ot-line.sum-type = 'cost':U
        and (
                                          temp-ot-line.fact-qnty      <> temp-ot-line.new-fact-qnty        or    temp-ot-line.sum-base       <> temp-ot-line.new-sum-base         or    temp-ot-line.sum-rubl       <> temp-ot-line.new-sum-rubl         or    temp-ot-line.vat-base       <> temp-ot-line.new-vat-base         or    temp-ot-line.vat-rubl       <> temp-ot-line.new-vat-rubl         or    temp-ot-line.slt-base       <> temp-ot-line.new-slt-base         or    temp-ot-line.slt-rubl       <> temp-ot-line.new-slt-rubl         or    temp-ot-line.road-tax-base  <> temp-ot-line.new-road-tax-base    or    temp-ot-line.road-tax-rubl  <> temp-ot-line.new-road-tax-rubl    or    temp-ot-line.excise-base    <> temp-ot-line.new-excise-base      or    temp-ot-line.excise-rubl    <> temp-ot-line.new-excise-rubl      or    temp-ot-line.transport-base <> temp-ot-line.new-transport-base   or    temp-ot-line.transport-rubl <> temp-ot-line.new-transport-rubl   or    temp-ot-line.other-base     <> temp-ot-line.new-other-base       or    temp-ot-line.other-rubl     <> temp-ot-line.new-other-rubl
            )
    on error undo, return error
    :
      for each root-temp-stk-line
        where root-temp-stk-line.obj-type  = temp-ot-line.obj-type
          and root-temp-stk-line.obj-code  = temp-ot-line.obj-code
          and root-temp-stk-line.artic     = temp-ot-line.artic
          and root-temp-stk-line.prod-type = temp-ot-line.prod-type
          and root-temp-stk-line.prod-code = temp-ot-line.prod-code
          and root-temp-stk-line.sum-type  = 'csdt':U + ub.trn-doc.ext-doc-type
          and root-temp-stk-line.cat-id    = '##,##':U
      on error undo, return error
      :
        find first temp-stk-line
          where temp-stk-line.obj-type   = temp-ot-line.obj-type
            and temp-stk-line.obj-code   = temp-ot-line.obj-code
            and temp-stk-line.artic      = temp-ot-line.artic
            and temp-stk-line.prod-type  = temp-ot-line.prod-type
            and temp-stk-line.prod-code  = temp-ot-line.prod-code
            and temp-stk-line.fact-order = root-temp-stk-line.fact-order
            and temp-stk-line.sum-type   = root-temp-stk-line.sum-type
            and temp-stk-line.cat-id     = '##,##':U
          no-error .
        if not available temp-stk-line
        then do:
          create temp-stk-line .
          assign
            temp-stk-line.obj-type   = temp-ot-line.obj-type
            temp-stk-line.obj-code   = temp-ot-line.obj-code
            temp-stk-line.artic      = temp-ot-line.artic
            temp-stk-line.prod-type  = temp-ot-line.prod-type
            temp-stk-line.prod-code  = temp-ot-line.prod-code
            temp-stk-line.fact-order = root-temp-stk-line.fact-order
            temp-stk-line.sum-type   = root-temp-stk-line.sum-type
            temp-stk-line.cat-id     = '##,##':U
            temp-stk-line.fact-date  = root-temp-stk-line.fact-date
            temp-stk-line.shift-num  = root-temp-stk-line.shift-num
            temp-stk-line.shift-date = root-temp-stk-line.shift-date
          .
        end.
        assign
                                                                                                              temp-stk-line.new-fact-qnty      = temp-stk-line.new-fact-qnty      + temp-ot-line.new-fact-qnty      - temp-ot-line.fact-qnty           temp-stk-line.new-sum-base       = temp-stk-line.new-sum-base       + temp-ot-line.new-sum-base       - temp-ot-line.sum-base            temp-stk-line.new-sum-rubl       = temp-stk-line.new-sum-rubl       + temp-ot-line.new-sum-rubl       - temp-ot-line.sum-rubl            temp-stk-line.new-vat-base       = temp-stk-line.new-vat-base       + temp-ot-line.new-vat-base       - temp-ot-line.vat-base            temp-stk-line.new-vat-rubl       = temp-stk-line.new-vat-rubl       + temp-ot-line.new-vat-rubl       - temp-ot-line.vat-rubl            temp-stk-line.new-slt-base       = temp-stk-line.new-slt-base       + temp-ot-line.new-slt-base       - temp-ot-line.slt-base            temp-stk-line.new-slt-rubl       = temp-stk-line.new-slt-rubl       + temp-ot-line.new-slt-rubl       - temp-ot-line.slt-rubl            temp-stk-line.new-road-tax-base  = temp-stk-line.new-road-tax-base  + temp-ot-line.new-road-tax-base  - temp-ot-line.road-tax-base       temp-stk-line.new-road-tax-rubl  = temp-stk-line.new-road-tax-rubl  + temp-ot-line.new-road-tax-rubl  - temp-ot-line.road-tax-rubl       temp-stk-line.new-excise-base    = temp-stk-line.new-excise-base    + temp-ot-line.new-excise-base    - temp-ot-line.excise-base         temp-stk-line.new-excise-rubl    = temp-stk-line.new-excise-rubl    + temp-ot-line.new-excise-rubl    - temp-ot-line.excise-rubl         temp-stk-line.new-transport-base = temp-stk-line.new-transport-base + temp-ot-line.new-transport-base - temp-ot-line.transport-base      temp-stk-line.new-transport-rubl = temp-stk-line.new-transport-rubl + temp-ot-line.new-transport-rubl - temp-ot-line.transport-rubl      temp-stk-line.new-other-base     = temp-stk-line.new-other-base     + temp-ot-line.new-other-base     - temp-ot-line.other-base          temp-stk-line.new-other-rubl     = temp-stk-line.new-other-rubl     + temp-ot-line.new-other-rubl     - temp-ot-line.other-rubl
        .
      end.
      if v-shift-on
      then do:
        for each root-temp-shift-stk-line
          where root-temp-shift-stk-line.obj-type  = temp-ot-line.obj-type
            and root-temp-shift-stk-line.obj-code  = temp-ot-line.obj-code
            and root-temp-shift-stk-line.artic     = temp-ot-line.artic
            and root-temp-shift-stk-line.prod-type = temp-ot-line.prod-type
            and root-temp-shift-stk-line.prod-code = temp-ot-line.prod-code
            and root-temp-shift-stk-line.sum-type  = 'csdt':U + ub.trn-doc.ext-doc-type
            and root-temp-shift-stk-line.cat-id    = '##,##':U
        on error undo, return error
        :
          find first temp-shift-stk-line
            where temp-shift-stk-line.obj-type   = temp-ot-line.obj-type
              and temp-shift-stk-line.obj-code   = temp-ot-line.obj-code
              and temp-shift-stk-line.artic      = temp-ot-line.artic
              and temp-shift-stk-line.prod-type  = temp-ot-line.prod-type
              and temp-shift-stk-line.prod-code  = temp-ot-line.prod-code
              and temp-shift-stk-line.fact-order = root-temp-shift-stk-line.fact-order
              and temp-shift-stk-line.sum-type   = root-temp-shift-stk-line.sum-type
              and temp-shift-stk-line.cat-id     = '##,##':U
            no-error .
          if not available temp-shift-stk-line
          then do:
            create temp-shift-stk-line .
            assign
              temp-shift-stk-line.obj-type   = temp-ot-line.obj-type
              temp-shift-stk-line.obj-code   = temp-ot-line.obj-code
              temp-shift-stk-line.artic      = temp-ot-line.artic
              temp-shift-stk-line.prod-type  = temp-ot-line.prod-type
              temp-shift-stk-line.prod-code  = temp-ot-line.prod-code
              temp-shift-stk-line.fact-order = root-temp-shift-stk-line.fact-order
              temp-shift-stk-line.sum-type   = root-temp-shift-stk-line.sum-type
              temp-shift-stk-line.cat-id     = '##,##':U
              temp-shift-stk-line.fact-date  = root-temp-shift-stk-line.fact-date
              temp-shift-stk-line.shift-num  = root-temp-shift-stk-line.shift-num
              temp-shift-stk-line.shift-date = root-temp-shift-stk-line.shift-date
            .
          end.
          assign
                                                                                                                                    temp-shift-stk-line.new-fact-qnty      = temp-shift-stk-line.new-fact-qnty      + temp-ot-line.new-fact-qnty      - temp-ot-line.fact-qnty           temp-shift-stk-line.new-sum-base       = temp-shift-stk-line.new-sum-base       + temp-ot-line.new-sum-base       - temp-ot-line.sum-base            temp-shift-stk-line.new-sum-rubl       = temp-shift-stk-line.new-sum-rubl       + temp-ot-line.new-sum-rubl       - temp-ot-line.sum-rubl            temp-shift-stk-line.new-vat-base       = temp-shift-stk-line.new-vat-base       + temp-ot-line.new-vat-base       - temp-ot-line.vat-base            temp-shift-stk-line.new-vat-rubl       = temp-shift-stk-line.new-vat-rubl       + temp-ot-line.new-vat-rubl       - temp-ot-line.vat-rubl            temp-shift-stk-line.new-slt-base       = temp-shift-stk-line.new-slt-base       + temp-ot-line.new-slt-base       - temp-ot-line.slt-base            temp-shift-stk-line.new-slt-rubl       = temp-shift-stk-line.new-slt-rubl       + temp-ot-line.new-slt-rubl       - temp-ot-line.slt-rubl            temp-shift-stk-line.new-road-tax-base  = temp-shift-stk-line.new-road-tax-base  + temp-ot-line.new-road-tax-base  - temp-ot-line.road-tax-base       temp-shift-stk-line.new-road-tax-rubl  = temp-shift-stk-line.new-road-tax-rubl  + temp-ot-line.new-road-tax-rubl  - temp-ot-line.road-tax-rubl       temp-shift-stk-line.new-excise-base    = temp-shift-stk-line.new-excise-base    + temp-ot-line.new-excise-base    - temp-ot-line.excise-base         temp-shift-stk-line.new-excise-rubl    = temp-shift-stk-line.new-excise-rubl    + temp-ot-line.new-excise-rubl    - temp-ot-line.excise-rubl         temp-shift-stk-line.new-transport-base = temp-shift-stk-line.new-transport-base + temp-ot-line.new-transport-base - temp-ot-line.transport-base      temp-shift-stk-line.new-transport-rubl = temp-shift-stk-line.new-transport-rubl + temp-ot-line.new-transport-rubl - temp-ot-line.transport-rubl      temp-shift-stk-line.new-other-base     = temp-shift-stk-line.new-other-base     + temp-ot-line.new-other-base     - temp-ot-line.other-base          temp-shift-stk-line.new-other-rubl     = temp-shift-stk-line.new-other-rubl     + temp-ot-line.new-other-rubl     - temp-ot-line.other-rubl
          .
        end.
      end.
    end.
    for each temp-ot-line
      where temp-ot-line.sum-type = 'cssr':U
        and (
                                          temp-ot-line.fact-qnty      <> temp-ot-line.new-fact-qnty        or    temp-ot-line.sum-base       <> temp-ot-line.new-sum-base         or    temp-ot-line.sum-rubl       <> temp-ot-line.new-sum-rubl         or    temp-ot-line.vat-base       <> temp-ot-line.new-vat-base         or    temp-ot-line.vat-rubl       <> temp-ot-line.new-vat-rubl         or    temp-ot-line.slt-base       <> temp-ot-line.new-slt-base         or    temp-ot-line.slt-rubl       <> temp-ot-line.new-slt-rubl         or    temp-ot-line.road-tax-base  <> temp-ot-line.new-road-tax-base    or    temp-ot-line.road-tax-rubl  <> temp-ot-line.new-road-tax-rubl    or    temp-ot-line.excise-base    <> temp-ot-line.new-excise-base      or    temp-ot-line.excise-rubl    <> temp-ot-line.new-excise-rubl      or    temp-ot-line.transport-base <> temp-ot-line.new-transport-base   or    temp-ot-line.transport-rubl <> temp-ot-line.new-transport-rubl   or    temp-ot-line.other-base     <> temp-ot-line.new-other-base       or    temp-ot-line.other-rubl     <> temp-ot-line.new-other-rubl
            )
    on error undo, return error
    :
      for each root-temp-stk-line
        where root-temp-stk-line.obj-type  = temp-ot-line.obj-type
          and root-temp-stk-line.obj-code  = temp-ot-line.obj-code
          and root-temp-stk-line.artic     = temp-ot-line.artic
          and root-temp-stk-line.prod-type = temp-ot-line.prod-type
          and root-temp-stk-line.prod-code = temp-ot-line.prod-code
          and root-temp-stk-line.sum-type  = 'sdsr':U + ub.trn-doc.ext-doc-type
          and root-temp-stk-line.cat-id    = '##,##':U
      on error undo, return error
      :
        find first temp-stk-line
          where temp-stk-line.obj-type   = temp-ot-line.obj-type
            and temp-stk-line.obj-code   = temp-ot-line.obj-code
            and temp-stk-line.artic      = temp-ot-line.artic
            and temp-stk-line.prod-type  = temp-ot-line.prod-type
            and temp-stk-line.prod-code  = temp-ot-line.prod-code
            and temp-stk-line.fact-order = root-temp-stk-line.fact-order
            and temp-stk-line.sum-type   = root-temp-stk-line.sum-type
            and temp-stk-line.cat-id     = '##,##':U
          no-error .
        if not available temp-stk-line
        then do:
          create temp-stk-line .
          assign
            temp-stk-line.obj-type   = temp-ot-line.obj-type
            temp-stk-line.obj-code   = temp-ot-line.obj-code
            temp-stk-line.artic      = temp-ot-line.artic
            temp-stk-line.prod-type  = temp-ot-line.prod-type
            temp-stk-line.prod-code  = temp-ot-line.prod-code
            temp-stk-line.fact-order = root-temp-stk-line.fact-order
            temp-stk-line.sum-type   = root-temp-stk-line.sum-type
            temp-stk-line.cat-id     = '##,##':U
            temp-stk-line.fact-date  = root-temp-stk-line.fact-date
            temp-stk-line.shift-num  = root-temp-stk-line.shift-num
            temp-stk-line.shift-date = root-temp-stk-line.shift-date
          .
        end.
        assign
                                                                                                              temp-stk-line.new-fact-qnty      = temp-stk-line.new-fact-qnty      + temp-ot-line.new-fact-qnty      - temp-ot-line.fact-qnty           temp-stk-line.new-sum-base       = temp-stk-line.new-sum-base       + temp-ot-line.new-sum-base       - temp-ot-line.sum-base            temp-stk-line.new-sum-rubl       = temp-stk-line.new-sum-rubl       + temp-ot-line.new-sum-rubl       - temp-ot-line.sum-rubl            temp-stk-line.new-vat-base       = temp-stk-line.new-vat-base       + temp-ot-line.new-vat-base       - temp-ot-line.vat-base            temp-stk-line.new-vat-rubl       = temp-stk-line.new-vat-rubl       + temp-ot-line.new-vat-rubl       - temp-ot-line.vat-rubl            temp-stk-line.new-slt-base       = temp-stk-line.new-slt-base       + temp-ot-line.new-slt-base       - temp-ot-line.slt-base            temp-stk-line.new-slt-rubl       = temp-stk-line.new-slt-rubl       + temp-ot-line.new-slt-rubl       - temp-ot-line.slt-rubl            temp-stk-line.new-road-tax-base  = temp-stk-line.new-road-tax-base  + temp-ot-line.new-road-tax-base  - temp-ot-line.road-tax-base       temp-stk-line.new-road-tax-rubl  = temp-stk-line.new-road-tax-rubl  + temp-ot-line.new-road-tax-rubl  - temp-ot-line.road-tax-rubl       temp-stk-line.new-excise-base    = temp-stk-line.new-excise-base    + temp-ot-line.new-excise-base    - temp-ot-line.excise-base         temp-stk-line.new-excise-rubl    = temp-stk-line.new-excise-rubl    + temp-ot-line.new-excise-rubl    - temp-ot-line.excise-rubl         temp-stk-line.new-transport-base = temp-stk-line.new-transport-base + temp-ot-line.new-transport-base - temp-ot-line.transport-base      temp-stk-line.new-transport-rubl = temp-stk-line.new-transport-rubl + temp-ot-line.new-transport-rubl - temp-ot-line.transport-rubl      temp-stk-line.new-other-base     = temp-stk-line.new-other-base     + temp-ot-line.new-other-base     - temp-ot-line.other-base          temp-stk-line.new-other-rubl     = temp-stk-line.new-other-rubl     + temp-ot-line.new-other-rubl     - temp-ot-line.other-rubl
        .
      end.
      if v-shift-on
      then do:
        for each root-temp-shift-stk-line
          where root-temp-shift-stk-line.obj-type  = temp-ot-line.obj-type
            and root-temp-shift-stk-line.obj-code  = temp-ot-line.obj-code
            and root-temp-shift-stk-line.artic     = temp-ot-line.artic
            and root-temp-shift-stk-line.prod-type = temp-ot-line.prod-type
            and root-temp-shift-stk-line.prod-code = temp-ot-line.prod-code
            and root-temp-shift-stk-line.sum-type  = 'sdsr':U + ub.trn-doc.ext-doc-type
            and root-temp-shift-stk-line.cat-id    = '##,##':U
        on error undo, return error
        :
          find first temp-shift-stk-line
            where temp-shift-stk-line.obj-type   = temp-ot-line.obj-type
              and temp-shift-stk-line.obj-code   = temp-ot-line.obj-code
              and temp-shift-stk-line.artic      = temp-ot-line.artic
              and temp-shift-stk-line.prod-type  = temp-ot-line.prod-type
              and temp-shift-stk-line.prod-code  = temp-ot-line.prod-code
              and temp-shift-stk-line.fact-order = root-temp-shift-stk-line.fact-order
              and temp-shift-stk-line.sum-type   = root-temp-shift-stk-line.sum-type
              and temp-shift-stk-line.cat-id     = '##,##':U
            no-error .
          if not available temp-shift-stk-line
          then do:
            create temp-shift-stk-line .
            assign
              temp-shift-stk-line.obj-type   = temp-ot-line.obj-type
              temp-shift-stk-line.obj-code   = temp-ot-line.obj-code
              temp-shift-stk-line.artic      = temp-ot-line.artic
              temp-shift-stk-line.prod-type  = temp-ot-line.prod-type
              temp-shift-stk-line.prod-code  = temp-ot-line.prod-code
              temp-shift-stk-line.fact-order = root-temp-shift-stk-line.fact-order
              temp-shift-stk-line.sum-type   = root-temp-shift-stk-line.sum-type
              temp-shift-stk-line.cat-id     = '##,##':U
              temp-shift-stk-line.fact-date  = root-temp-shift-stk-line.fact-date
              temp-shift-stk-line.shift-num  = root-temp-shift-stk-line.shift-num
              temp-shift-stk-line.shift-date = root-temp-shift-stk-line.shift-date
            .
          end.
          assign
                                                                                                                                    temp-shift-stk-line.new-fact-qnty      = temp-shift-stk-line.new-fact-qnty      + temp-ot-line.new-fact-qnty      - temp-ot-line.fact-qnty           temp-shift-stk-line.new-sum-base       = temp-shift-stk-line.new-sum-base       + temp-ot-line.new-sum-base       - temp-ot-line.sum-base            temp-shift-stk-line.new-sum-rubl       = temp-shift-stk-line.new-sum-rubl       + temp-ot-line.new-sum-rubl       - temp-ot-line.sum-rubl            temp-shift-stk-line.new-vat-base       = temp-shift-stk-line.new-vat-base       + temp-ot-line.new-vat-base       - temp-ot-line.vat-base            temp-shift-stk-line.new-vat-rubl       = temp-shift-stk-line.new-vat-rubl       + temp-ot-line.new-vat-rubl       - temp-ot-line.vat-rubl            temp-shift-stk-line.new-slt-base       = temp-shift-stk-line.new-slt-base       + temp-ot-line.new-slt-base       - temp-ot-line.slt-base            temp-shift-stk-line.new-slt-rubl       = temp-shift-stk-line.new-slt-rubl       + temp-ot-line.new-slt-rubl       - temp-ot-line.slt-rubl            temp-shift-stk-line.new-road-tax-base  = temp-shift-stk-line.new-road-tax-base  + temp-ot-line.new-road-tax-base  - temp-ot-line.road-tax-base       temp-shift-stk-line.new-road-tax-rubl  = temp-shift-stk-line.new-road-tax-rubl  + temp-ot-line.new-road-tax-rubl  - temp-ot-line.road-tax-rubl       temp-shift-stk-line.new-excise-base    = temp-shift-stk-line.new-excise-base    + temp-ot-line.new-excise-base    - temp-ot-line.excise-base         temp-shift-stk-line.new-excise-rubl    = temp-shift-stk-line.new-excise-rubl    + temp-ot-line.new-excise-rubl    - temp-ot-line.excise-rubl         temp-shift-stk-line.new-transport-base = temp-shift-stk-line.new-transport-base + temp-ot-line.new-transport-base - temp-ot-line.transport-base      temp-shift-stk-line.new-transport-rubl = temp-shift-stk-line.new-transport-rubl + temp-ot-line.new-transport-rubl - temp-ot-line.transport-rubl      temp-shift-stk-line.new-other-base     = temp-shift-stk-line.new-other-base     + temp-ot-line.new-other-base     - temp-ot-line.other-base          temp-shift-stk-line.new-other-rubl     = temp-shift-stk-line.new-other-rubl     + temp-ot-line.new-other-rubl     - temp-ot-line.other-rubl
          .
        end.
      end.
    end.
  end.
end procedure.
procedure store-temp-table :
  do
  on error undo, return error
  :
    for each temp-ot-tot
    on error undo, return error
    :
      if
                              temp-ot-tot.new-fact-qnty      = ? or    temp-ot-tot.new-sum-base       = ? or    temp-ot-tot.new-sum-rubl       = ? or    temp-ot-tot.new-vat-base       = ? or    temp-ot-tot.new-vat-rubl       = ? or    temp-ot-tot.new-slt-base       = ? or    temp-ot-tot.new-slt-rubl       = ? or    temp-ot-tot.new-road-tax-base  = ? or    temp-ot-tot.new-road-tax-rubl  = ? or    temp-ot-tot.new-excise-base    = ? or    temp-ot-tot.new-excise-rubl    = ? or    temp-ot-tot.new-transport-base = ? or    temp-ot-tot.new-transport-rubl = ? or    temp-ot-tot.new-other-base     = ? or    temp-ot-tot.new-other-rubl     = ?
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "При расчете складского архива по товарам получено неопределенное значение" skip
          "Документ" p-doc-code skip
          "Дополнительная информация выведена в файл calc-arh.err" skip
          view-as alert-box error .
        output stream slog to calc-arh.err append .
        export stream slog "ot-tot" .
        export stream slog temp-ot-tot .
        output stream slog close .
        undo, return error .
      end.
      if
                                          temp-ot-tot.fact-qnty      <> temp-ot-tot.new-fact-qnty        or    temp-ot-tot.sum-base       <> temp-ot-tot.new-sum-base         or    temp-ot-tot.sum-rubl       <> temp-ot-tot.new-sum-rubl         or    temp-ot-tot.vat-base       <> temp-ot-tot.new-vat-base         or    temp-ot-tot.vat-rubl       <> temp-ot-tot.new-vat-rubl         or    temp-ot-tot.slt-base       <> temp-ot-tot.new-slt-base         or    temp-ot-tot.slt-rubl       <> temp-ot-tot.new-slt-rubl         or    temp-ot-tot.road-tax-base  <> temp-ot-tot.new-road-tax-base    or    temp-ot-tot.road-tax-rubl  <> temp-ot-tot.new-road-tax-rubl    or    temp-ot-tot.excise-base    <> temp-ot-tot.new-excise-base      or    temp-ot-tot.excise-rubl    <> temp-ot-tot.new-excise-rubl      or    temp-ot-tot.transport-base <> temp-ot-tot.new-transport-base   or    temp-ot-tot.transport-rubl <> temp-ot-tot.new-transport-rubl   or    temp-ot-tot.other-base     <> temp-ot-tot.new-other-base       or    temp-ot-tot.other-rubl     <> temp-ot-tot.new-other-rubl
      or ( temp-ot-tot.cat-id = '##,##':U )
      then do:
        assign
          l-need-create-record =
                                                                                                                                                                          temp-ot-tot.new-fact-qnty      <> 0 or    temp-ot-tot.new-sum-base       <> 0 or    temp-ot-tot.new-sum-rubl       <> 0 or    temp-ot-tot.new-vat-base       <> 0 or    temp-ot-tot.new-vat-rubl       <> 0 or    temp-ot-tot.new-slt-base       <> 0 or    temp-ot-tot.new-slt-rubl       <> 0 or    temp-ot-tot.new-road-tax-base  <> 0 or    temp-ot-tot.new-road-tax-rubl  <> 0 or    temp-ot-tot.new-excise-base    <> 0 or    temp-ot-tot.new-excise-rubl    <> 0 or    temp-ot-tot.new-transport-base <> 0 or    temp-ot-tot.new-transport-rubl <> 0 or    temp-ot-tot.new-other-base     <> 0 or    temp-ot-tot.new-other-rubl     <> 0
                              or ( temp-ot-tot.cat-id = '##,##':U )
        .
        find first ub.ot-tot exclusive-lock
          where ub.ot-tot.doc-code = temp-ot-tot.doc-code
            and ub.ot-tot.sum-type = temp-ot-tot.sum-type
            and ub.ot-tot.cat-id   = temp-ot-tot.cat-id
          no-error .
        if l-need-create-record
        then do:
          if not available ub.ot-tot
          then do:
            create ub.ot-tot .
          end.
                              assign
            ub.ot-tot.doc-code     = temp-ot-tot.doc-code       ub.ot-tot.sum-type     = temp-ot-tot.sum-type       ub.ot-tot.cat-id       = temp-ot-tot.cat-id         ub.ot-tot.ext-doc-type = temp-ot-tot.ext-doc-type   ub.ot-tot.obj-type     = temp-ot-tot.obj-type       ub.ot-tot.obj-code     = temp-ot-tot.obj-code       ub.ot-tot.fact-order   = temp-ot-tot.fact-order
          .
          assign
                                                                                    ub.ot-tot.fact-qnty      = temp-ot-tot.new-fact-qnty            ub.ot-tot.sum-base       = temp-ot-tot.new-sum-base             ub.ot-tot.sum-rubl       = temp-ot-tot.new-sum-rubl             ub.ot-tot.vat-base       = temp-ot-tot.new-vat-base             ub.ot-tot.vat-rubl       = temp-ot-tot.new-vat-rubl             ub.ot-tot.slt-base       = temp-ot-tot.new-slt-base             ub.ot-tot.slt-rubl       = temp-ot-tot.new-slt-rubl             ub.ot-tot.road-tax-base  = temp-ot-tot.new-road-tax-base        ub.ot-tot.road-tax-rubl  = temp-ot-tot.new-road-tax-rubl        ub.ot-tot.excise-base    = temp-ot-tot.new-excise-base          ub.ot-tot.excise-rubl    = temp-ot-tot.new-excise-rubl          ub.ot-tot.transport-base = temp-ot-tot.new-transport-base       ub.ot-tot.transport-rubl = temp-ot-tot.new-transport-rubl       ub.ot-tot.other-base     = temp-ot-tot.new-other-base           ub.ot-tot.other-rubl     = temp-ot-tot.new-other-rubl
          .
        end.
        else do:
          if available ub.ot-tot
          then do:
            delete ub.ot-tot .
          end.
        end.
      end.
    end.
    for each temp-ot-line
    on error undo, return error
    :
      if
                                          temp-ot-line.fact-qnty      <> temp-ot-line.new-fact-qnty        or    temp-ot-line.sum-base       <> temp-ot-line.new-sum-base         or    temp-ot-line.sum-rubl       <> temp-ot-line.new-sum-rubl         or    temp-ot-line.vat-base       <> temp-ot-line.new-vat-base         or    temp-ot-line.vat-rubl       <> temp-ot-line.new-vat-rubl         or    temp-ot-line.slt-base       <> temp-ot-line.new-slt-base         or    temp-ot-line.slt-rubl       <> temp-ot-line.new-slt-rubl         or    temp-ot-line.road-tax-base  <> temp-ot-line.new-road-tax-base    or    temp-ot-line.road-tax-rubl  <> temp-ot-line.new-road-tax-rubl    or    temp-ot-line.excise-base    <> temp-ot-line.new-excise-base      or    temp-ot-line.excise-rubl    <> temp-ot-line.new-excise-rubl      or    temp-ot-line.transport-base <> temp-ot-line.new-transport-base   or    temp-ot-line.transport-rubl <> temp-ot-line.new-transport-rubl   or    temp-ot-line.other-base     <> temp-ot-line.new-other-base       or    temp-ot-line.other-rubl     <> temp-ot-line.new-other-rubl
      or ( temp-ot-line.sum-type = 'crsa':U )
      then do:
        assign
          l-need-create-record =
                                                                                                                                                                          temp-ot-line.new-fact-qnty      <> 0 or    temp-ot-line.new-sum-base       <> 0 or    temp-ot-line.new-sum-rubl       <> 0 or    temp-ot-line.new-vat-base       <> 0 or    temp-ot-line.new-vat-rubl       <> 0 or    temp-ot-line.new-slt-base       <> 0 or    temp-ot-line.new-slt-rubl       <> 0 or    temp-ot-line.new-road-tax-base  <> 0 or    temp-ot-line.new-road-tax-rubl  <> 0 or    temp-ot-line.new-excise-base    <> 0 or    temp-ot-line.new-excise-rubl    <> 0 or    temp-ot-line.new-transport-base <> 0 or    temp-ot-line.new-transport-rubl <> 0 or    temp-ot-line.new-other-base     <> 0 or    temp-ot-line.new-other-rubl     <> 0
                              or ( temp-ot-line.sum-type = 'crsa':U )
        .
        find first ub.ot-line exclusive-lock
          where ub.ot-line.doc-code  = temp-ot-line.doc-code
            and ub.ot-line.artic     = temp-ot-line.artic
            and ub.ot-line.prod-type = temp-ot-line.prod-type
            and ub.ot-line.prod-code = temp-ot-line.prod-code
            and ub.ot-line.sum-type  = temp-ot-line.sum-type
            and ub.ot-line.cat-id    = temp-ot-line.cat-id
          no-error .
        if l-need-create-record
        then do:
          if not available ub.ot-line
          then do:
            create ub.ot-line .
          end.
                              assign
            ub.ot-line.doc-code     = temp-ot-line.doc-code       ub.ot-line.artic        = temp-ot-line.artic          ub.ot-line.prod-type    = temp-ot-line.prod-type      ub.ot-line.prod-code    = temp-ot-line.prod-code      ub.ot-line.sum-type     = temp-ot-line.sum-type       ub.ot-line.cat-id       = temp-ot-line.cat-id         ub.ot-line.ext-doc-type = temp-ot-line.ext-doc-type   ub.ot-line.obj-type     = temp-ot-line.obj-type       ub.ot-line.obj-code     = temp-ot-line.obj-code       ub.ot-line.fact-order   = temp-ot-line.fact-order
          .
          assign
                                                                                    ub.ot-line.fact-qnty      = temp-ot-line.new-fact-qnty            ub.ot-line.sum-base       = temp-ot-line.new-sum-base             ub.ot-line.sum-rubl       = temp-ot-line.new-sum-rubl             ub.ot-line.vat-base       = temp-ot-line.new-vat-base             ub.ot-line.vat-rubl       = temp-ot-line.new-vat-rubl             ub.ot-line.slt-base       = temp-ot-line.new-slt-base             ub.ot-line.slt-rubl       = temp-ot-line.new-slt-rubl             ub.ot-line.road-tax-base  = temp-ot-line.new-road-tax-base        ub.ot-line.road-tax-rubl  = temp-ot-line.new-road-tax-rubl        ub.ot-line.excise-base    = temp-ot-line.new-excise-base          ub.ot-line.excise-rubl    = temp-ot-line.new-excise-rubl          ub.ot-line.transport-base = temp-ot-line.new-transport-base       ub.ot-line.transport-rubl = temp-ot-line.new-transport-rubl       ub.ot-line.other-base     = temp-ot-line.new-other-base           ub.ot-line.other-rubl     = temp-ot-line.new-other-rubl
          .
        end.
        else do:
          if available ub.ot-line
          then do:
            delete ub.ot-line .
          end.
        end.
      end.
    end.
    for each temp-stk-tot
    on error undo, return error
    :
      if
                                          temp-stk-tot.fact-qnty      <> temp-stk-tot.new-fact-qnty        or    temp-stk-tot.sum-base       <> temp-stk-tot.new-sum-base         or    temp-stk-tot.sum-rubl       <> temp-stk-tot.new-sum-rubl         or    temp-stk-tot.vat-base       <> temp-stk-tot.new-vat-base         or    temp-stk-tot.vat-rubl       <> temp-stk-tot.new-vat-rubl         or    temp-stk-tot.slt-base       <> temp-stk-tot.new-slt-base         or    temp-stk-tot.slt-rubl       <> temp-stk-tot.new-slt-rubl         or    temp-stk-tot.road-tax-base  <> temp-stk-tot.new-road-tax-base    or    temp-stk-tot.road-tax-rubl  <> temp-stk-tot.new-road-tax-rubl    or    temp-stk-tot.excise-base    <> temp-stk-tot.new-excise-base      or    temp-stk-tot.excise-rubl    <> temp-stk-tot.new-excise-rubl      or    temp-stk-tot.transport-base <> temp-stk-tot.new-transport-base   or    temp-stk-tot.transport-rubl <> temp-stk-tot.new-transport-rubl   or    temp-stk-tot.other-base     <> temp-stk-tot.new-other-base       or    temp-stk-tot.other-rubl     <> temp-stk-tot.new-other-rubl
      or temp-stk-tot.cat-id = '##,##':U
      then do:
        assign
          l-need-create-record =
                                                                                                                                                                          temp-stk-tot.new-fact-qnty      <> 0 or    temp-stk-tot.new-sum-base       <> 0 or    temp-stk-tot.new-sum-rubl       <> 0 or    temp-stk-tot.new-vat-base       <> 0 or    temp-stk-tot.new-vat-rubl       <> 0 or    temp-stk-tot.new-slt-base       <> 0 or    temp-stk-tot.new-slt-rubl       <> 0 or    temp-stk-tot.new-road-tax-base  <> 0 or    temp-stk-tot.new-road-tax-rubl  <> 0 or    temp-stk-tot.new-excise-base    <> 0 or    temp-stk-tot.new-excise-rubl    <> 0 or    temp-stk-tot.new-transport-base <> 0 or    temp-stk-tot.new-transport-rubl <> 0 or    temp-stk-tot.new-other-base     <> 0 or    temp-stk-tot.new-other-rubl     <> 0
                              or ( temp-stk-tot.cat-id = '##,##':U )
        .
        find first ub.stk-tot exclusive-lock
          where ub.stk-tot.obj-type   = temp-stk-tot.obj-type
            and ub.stk-tot.obj-code   = temp-stk-tot.obj-code
            and ub.stk-tot.fact-order = temp-stk-tot.fact-order
            and ub.stk-tot.sum-type   = temp-stk-tot.sum-type
            and ub.stk-tot.cat-id     = temp-stk-tot.cat-id
          no-error .
        if l-need-create-record
        then do:
          if not available ub.stk-tot
          then do:
            create ub.stk-tot .
          end.
                              assign
            ub.stk-tot.obj-type     = temp-stk-tot.obj-type     ub.stk-tot.obj-code     = temp-stk-tot.obj-code     ub.stk-tot.fact-order   = temp-stk-tot.fact-order   ub.stk-tot.sum-type     = temp-stk-tot.sum-type     ub.stk-tot.cat-id       = temp-stk-tot.cat-id       ub.stk-tot.fact-date    = temp-stk-tot.fact-date    ub.stk-tot.shift-num    = temp-stk-tot.shift-num    ub.stk-tot.shift-date   = temp-stk-tot.shift-date
          .
          assign
                                                                                    ub.stk-tot.fact-qnty      = temp-stk-tot.new-fact-qnty            ub.stk-tot.sum-base       = temp-stk-tot.new-sum-base             ub.stk-tot.sum-rubl       = temp-stk-tot.new-sum-rubl             ub.stk-tot.vat-base       = temp-stk-tot.new-vat-base             ub.stk-tot.vat-rubl       = temp-stk-tot.new-vat-rubl             ub.stk-tot.slt-base       = temp-stk-tot.new-slt-base             ub.stk-tot.slt-rubl       = temp-stk-tot.new-slt-rubl             ub.stk-tot.road-tax-base  = temp-stk-tot.new-road-tax-base        ub.stk-tot.road-tax-rubl  = temp-stk-tot.new-road-tax-rubl        ub.stk-tot.excise-base    = temp-stk-tot.new-excise-base          ub.stk-tot.excise-rubl    = temp-stk-tot.new-excise-rubl          ub.stk-tot.transport-base = temp-stk-tot.new-transport-base       ub.stk-tot.transport-rubl = temp-stk-tot.new-transport-rubl       ub.stk-tot.other-base     = temp-stk-tot.new-other-base           ub.stk-tot.other-rubl     = temp-stk-tot.new-other-rubl
          .
        end.
        else do:
          if available ub.stk-tot
          then do:
            delete ub.stk-tot .
          end.
        end.
      end.
    end.
    for each temp-stk-line
    on error undo, return error
    :
      if
                                          temp-stk-line.fact-qnty      <> temp-stk-line.new-fact-qnty        or    temp-stk-line.sum-base       <> temp-stk-line.new-sum-base         or    temp-stk-line.sum-rubl       <> temp-stk-line.new-sum-rubl         or    temp-stk-line.vat-base       <> temp-stk-line.new-vat-base         or    temp-stk-line.vat-rubl       <> temp-stk-line.new-vat-rubl         or    temp-stk-line.slt-base       <> temp-stk-line.new-slt-base         or    temp-stk-line.slt-rubl       <> temp-stk-line.new-slt-rubl         or    temp-stk-line.road-tax-base  <> temp-stk-line.new-road-tax-base    or    temp-stk-line.road-tax-rubl  <> temp-stk-line.new-road-tax-rubl    or    temp-stk-line.excise-base    <> temp-stk-line.new-excise-base      or    temp-stk-line.excise-rubl    <> temp-stk-line.new-excise-rubl      or    temp-stk-line.transport-base <> temp-stk-line.new-transport-base   or    temp-stk-line.transport-rubl <> temp-stk-line.new-transport-rubl   or    temp-stk-line.other-base     <> temp-stk-line.new-other-base       or    temp-stk-line.other-rubl     <> temp-stk-line.new-other-rubl
      or temp-stk-line.cat-id = '##,##':U
      then do:
        assign
          l-need-create-record =
                                                                                                                                                                          temp-stk-line.new-fact-qnty      <> 0 or    temp-stk-line.new-sum-base       <> 0 or    temp-stk-line.new-sum-rubl       <> 0 or    temp-stk-line.new-vat-base       <> 0 or    temp-stk-line.new-vat-rubl       <> 0 or    temp-stk-line.new-slt-base       <> 0 or    temp-stk-line.new-slt-rubl       <> 0 or    temp-stk-line.new-road-tax-base  <> 0 or    temp-stk-line.new-road-tax-rubl  <> 0 or    temp-stk-line.new-excise-base    <> 0 or    temp-stk-line.new-excise-rubl    <> 0 or    temp-stk-line.new-transport-base <> 0 or    temp-stk-line.new-transport-rubl <> 0 or    temp-stk-line.new-other-base     <> 0 or    temp-stk-line.new-other-rubl     <> 0
                              or ( temp-stk-line.cat-id = '##,##':U )
        .
        find first ub.stk-line exclusive-lock
          where ub.stk-line.obj-type   = temp-stk-line.obj-type
            and ub.stk-line.obj-code   = temp-stk-line.obj-code
            and ub.stk-line.artic      = temp-stk-line.artic
            and ub.stk-line.prod-type  = temp-stk-line.prod-type
            and ub.stk-line.prod-code  = temp-stk-line.prod-code
            and ub.stk-line.fact-order = temp-stk-line.fact-order
            and ub.stk-line.sum-type   = temp-stk-line.sum-type
            and ub.stk-line.cat-id     = temp-stk-line.cat-id
          no-error .
        if l-need-create-record
        then do:
          if not available ub.stk-line
          then do:
            create ub.stk-line .
          end.
                              assign
            ub.stk-line.obj-type     = temp-stk-line.obj-type     ub.stk-line.obj-code     = temp-stk-line.obj-code     ub.stk-line.artic        = temp-stk-line.artic        ub.stk-line.prod-type    = temp-stk-line.prod-type    ub.stk-line.prod-code    = temp-stk-line.prod-code    ub.stk-line.fact-order   = temp-stk-line.fact-order   ub.stk-line.sum-type     = temp-stk-line.sum-type     ub.stk-line.cat-id       = temp-stk-line.cat-id       ub.stk-line.fact-date    = temp-stk-line.fact-date    ub.stk-line.shift-num    = temp-stk-line.shift-num    ub.stk-line.shift-date   = temp-stk-line.shift-date
          .
          assign
                                                                                    ub.stk-line.fact-qnty      = temp-stk-line.new-fact-qnty            ub.stk-line.sum-base       = temp-stk-line.new-sum-base             ub.stk-line.sum-rubl       = temp-stk-line.new-sum-rubl             ub.stk-line.vat-base       = temp-stk-line.new-vat-base             ub.stk-line.vat-rubl       = temp-stk-line.new-vat-rubl             ub.stk-line.slt-base       = temp-stk-line.new-slt-base             ub.stk-line.slt-rubl       = temp-stk-line.new-slt-rubl             ub.stk-line.road-tax-base  = temp-stk-line.new-road-tax-base        ub.stk-line.road-tax-rubl  = temp-stk-line.new-road-tax-rubl        ub.stk-line.excise-base    = temp-stk-line.new-excise-base          ub.stk-line.excise-rubl    = temp-stk-line.new-excise-rubl          ub.stk-line.transport-base = temp-stk-line.new-transport-base       ub.stk-line.transport-rubl = temp-stk-line.new-transport-rubl       ub.stk-line.other-base     = temp-stk-line.new-other-base           ub.stk-line.other-rubl     = temp-stk-line.new-other-rubl
          .
        end.
        else do:
          if available ub.stk-line
          then do:
            delete ub.stk-line .
          end.
        end.
      end.
    end.
    if v-shift-on
    then do:
      run store-shift-temp-table .
    end.
  end.
end procedure.
procedure store-shift-temp-table :
  define buffer buf_stk-tot  for ub.stk-tot .
  define buffer buf_stk-line for ub.stk-line .
  do
  on error undo, return error
  :
    for each temp-shift-stk-tot
    on error undo, return error
    :
      if
                                          temp-shift-stk-tot.fact-qnty      <> temp-shift-stk-tot.new-fact-qnty        or    temp-shift-stk-tot.sum-base       <> temp-shift-stk-tot.new-sum-base         or    temp-shift-stk-tot.sum-rubl       <> temp-shift-stk-tot.new-sum-rubl         or    temp-shift-stk-tot.vat-base       <> temp-shift-stk-tot.new-vat-base         or    temp-shift-stk-tot.vat-rubl       <> temp-shift-stk-tot.new-vat-rubl         or    temp-shift-stk-tot.slt-base       <> temp-shift-stk-tot.new-slt-base         or    temp-shift-stk-tot.slt-rubl       <> temp-shift-stk-tot.new-slt-rubl         or    temp-shift-stk-tot.road-tax-base  <> temp-shift-stk-tot.new-road-tax-base    or    temp-shift-stk-tot.road-tax-rubl  <> temp-shift-stk-tot.new-road-tax-rubl    or    temp-shift-stk-tot.excise-base    <> temp-shift-stk-tot.new-excise-base      or    temp-shift-stk-tot.excise-rubl    <> temp-shift-stk-tot.new-excise-rubl      or    temp-shift-stk-tot.transport-base <> temp-shift-stk-tot.new-transport-base   or    temp-shift-stk-tot.transport-rubl <> temp-shift-stk-tot.new-transport-rubl   or    temp-shift-stk-tot.other-base     <> temp-shift-stk-tot.new-other-base       or    temp-shift-stk-tot.other-rubl     <> temp-shift-stk-tot.new-other-rubl
      or temp-shift-stk-tot.cat-id = '##,##':U
      then do:
        assign
          l-need-create-record =
                                                                                                                                                                          temp-shift-stk-tot.new-fact-qnty      <> 0 or    temp-shift-stk-tot.new-sum-base       <> 0 or    temp-shift-stk-tot.new-sum-rubl       <> 0 or    temp-shift-stk-tot.new-vat-base       <> 0 or    temp-shift-stk-tot.new-vat-rubl       <> 0 or    temp-shift-stk-tot.new-slt-base       <> 0 or    temp-shift-stk-tot.new-slt-rubl       <> 0 or    temp-shift-stk-tot.new-road-tax-base  <> 0 or    temp-shift-stk-tot.new-road-tax-rubl  <> 0 or    temp-shift-stk-tot.new-excise-base    <> 0 or    temp-shift-stk-tot.new-excise-rubl    <> 0 or    temp-shift-stk-tot.new-transport-base <> 0 or    temp-shift-stk-tot.new-transport-rubl <> 0 or    temp-shift-stk-tot.new-other-base     <> 0 or    temp-shift-stk-tot.new-other-rubl     <> 0
                              or ( temp-shift-stk-tot.cat-id = '##,##':U )
        .
        find first buf_stk-tot exclusive-lock
          where buf_stk-tot.obj-type   = temp-shift-stk-tot.obj-type
            and buf_stk-tot.obj-code   = temp-shift-stk-tot.obj-code
            and buf_stk-tot.fact-order = temp-shift-stk-tot.fact-order
            and buf_stk-tot.sum-type   = temp-shift-stk-tot.sum-type
            and buf_stk-tot.cat-id     = temp-shift-stk-tot.cat-id
          no-error .
        if l-need-create-record
        then do:
          if not available buf_stk-tot
          then do:
            create buf_stk-tot .
          end.
                              assign
            buf_stk-tot.obj-type     = temp-shift-stk-tot.obj-type     buf_stk-tot.obj-code     = temp-shift-stk-tot.obj-code     buf_stk-tot.fact-order   = temp-shift-stk-tot.fact-order   buf_stk-tot.sum-type     = temp-shift-stk-tot.sum-type     buf_stk-tot.cat-id       = temp-shift-stk-tot.cat-id       buf_stk-tot.fact-date    = temp-shift-stk-tot.fact-date    buf_stk-tot.shift-num    = temp-shift-stk-tot.shift-num    buf_stk-tot.shift-date   = temp-shift-stk-tot.shift-date
          .
          assign
                                                                                    buf_stk-tot.fact-qnty      = temp-shift-stk-tot.new-fact-qnty            buf_stk-tot.sum-base       = temp-shift-stk-tot.new-sum-base             buf_stk-tot.sum-rubl       = temp-shift-stk-tot.new-sum-rubl             buf_stk-tot.vat-base       = temp-shift-stk-tot.new-vat-base             buf_stk-tot.vat-rubl       = temp-shift-stk-tot.new-vat-rubl             buf_stk-tot.slt-base       = temp-shift-stk-tot.new-slt-base             buf_stk-tot.slt-rubl       = temp-shift-stk-tot.new-slt-rubl             buf_stk-tot.road-tax-base  = temp-shift-stk-tot.new-road-tax-base        buf_stk-tot.road-tax-rubl  = temp-shift-stk-tot.new-road-tax-rubl        buf_stk-tot.excise-base    = temp-shift-stk-tot.new-excise-base          buf_stk-tot.excise-rubl    = temp-shift-stk-tot.new-excise-rubl          buf_stk-tot.transport-base = temp-shift-stk-tot.new-transport-base       buf_stk-tot.transport-rubl = temp-shift-stk-tot.new-transport-rubl       buf_stk-tot.other-base     = temp-shift-stk-tot.new-other-base           buf_stk-tot.other-rubl     = temp-shift-stk-tot.new-other-rubl
          .
        end.
        else do:
          if available buf_stk-tot
          then do:
            delete buf_stk-tot .
          end.
        end.
      end.
    end.
    for each temp-shift-stk-line
    on error undo, return error
    :
      if
                                          temp-shift-stk-line.fact-qnty      <> temp-shift-stk-line.new-fact-qnty        or    temp-shift-stk-line.sum-base       <> temp-shift-stk-line.new-sum-base         or    temp-shift-stk-line.sum-rubl       <> temp-shift-stk-line.new-sum-rubl         or    temp-shift-stk-line.vat-base       <> temp-shift-stk-line.new-vat-base         or    temp-shift-stk-line.vat-rubl       <> temp-shift-stk-line.new-vat-rubl         or    temp-shift-stk-line.slt-base       <> temp-shift-stk-line.new-slt-base         or    temp-shift-stk-line.slt-rubl       <> temp-shift-stk-line.new-slt-rubl         or    temp-shift-stk-line.road-tax-base  <> temp-shift-stk-line.new-road-tax-base    or    temp-shift-stk-line.road-tax-rubl  <> temp-shift-stk-line.new-road-tax-rubl    or    temp-shift-stk-line.excise-base    <> temp-shift-stk-line.new-excise-base      or    temp-shift-stk-line.excise-rubl    <> temp-shift-stk-line.new-excise-rubl      or    temp-shift-stk-line.transport-base <> temp-shift-stk-line.new-transport-base   or    temp-shift-stk-line.transport-rubl <> temp-shift-stk-line.new-transport-rubl   or    temp-shift-stk-line.other-base     <> temp-shift-stk-line.new-other-base       or    temp-shift-stk-line.other-rubl     <> temp-shift-stk-line.new-other-rubl
      or temp-shift-stk-line.cat-id = '##,##':U
      then do:
        assign
          l-need-create-record =
                                                                                                                                                                          temp-shift-stk-line.new-fact-qnty      <> 0 or    temp-shift-stk-line.new-sum-base       <> 0 or    temp-shift-stk-line.new-sum-rubl       <> 0 or    temp-shift-stk-line.new-vat-base       <> 0 or    temp-shift-stk-line.new-vat-rubl       <> 0 or    temp-shift-stk-line.new-slt-base       <> 0 or    temp-shift-stk-line.new-slt-rubl       <> 0 or    temp-shift-stk-line.new-road-tax-base  <> 0 or    temp-shift-stk-line.new-road-tax-rubl  <> 0 or    temp-shift-stk-line.new-excise-base    <> 0 or    temp-shift-stk-line.new-excise-rubl    <> 0 or    temp-shift-stk-line.new-transport-base <> 0 or    temp-shift-stk-line.new-transport-rubl <> 0 or    temp-shift-stk-line.new-other-base     <> 0 or    temp-shift-stk-line.new-other-rubl     <> 0
                              or ( temp-shift-stk-line.cat-id = '##,##':U )
        .
        find first buf_stk-line exclusive-lock
          where buf_stk-line.obj-type   = temp-shift-stk-line.obj-type
            and buf_stk-line.obj-code   = temp-shift-stk-line.obj-code
            and buf_stk-line.artic      = temp-shift-stk-line.artic
            and buf_stk-line.prod-type  = temp-shift-stk-line.prod-type
            and buf_stk-line.prod-code  = temp-shift-stk-line.prod-code
            and buf_stk-line.fact-order = temp-shift-stk-line.fact-order
            and buf_stk-line.sum-type   = temp-shift-stk-line.sum-type
            and buf_stk-line.cat-id     = temp-shift-stk-line.cat-id
          no-error .
        if l-need-create-record
        then do:
          if not available buf_stk-line
          then do:
            create buf_stk-line .
          end.
                              assign
            buf_stk-line.obj-type     = temp-shift-stk-line.obj-type     buf_stk-line.obj-code     = temp-shift-stk-line.obj-code     buf_stk-line.artic        = temp-shift-stk-line.artic        buf_stk-line.prod-type    = temp-shift-stk-line.prod-type    buf_stk-line.prod-code    = temp-shift-stk-line.prod-code    buf_stk-line.fact-order   = temp-shift-stk-line.fact-order   buf_stk-line.sum-type     = temp-shift-stk-line.sum-type     buf_stk-line.cat-id       = temp-shift-stk-line.cat-id       buf_stk-line.fact-date    = temp-shift-stk-line.fact-date    buf_stk-line.shift-num    = temp-shift-stk-line.shift-num    buf_stk-line.shift-date   = temp-shift-stk-line.shift-date
          .
          assign
                                                                                    buf_stk-line.fact-qnty      = temp-shift-stk-line.new-fact-qnty            buf_stk-line.sum-base       = temp-shift-stk-line.new-sum-base             buf_stk-line.sum-rubl       = temp-shift-stk-line.new-sum-rubl             buf_stk-line.vat-base       = temp-shift-stk-line.new-vat-base             buf_stk-line.vat-rubl       = temp-shift-stk-line.new-vat-rubl             buf_stk-line.slt-base       = temp-shift-stk-line.new-slt-base             buf_stk-line.slt-rubl       = temp-shift-stk-line.new-slt-rubl             buf_stk-line.road-tax-base  = temp-shift-stk-line.new-road-tax-base        buf_stk-line.road-tax-rubl  = temp-shift-stk-line.new-road-tax-rubl        buf_stk-line.excise-base    = temp-shift-stk-line.new-excise-base          buf_stk-line.excise-rubl    = temp-shift-stk-line.new-excise-rubl          buf_stk-line.transport-base = temp-shift-stk-line.new-transport-base       buf_stk-line.transport-rubl = temp-shift-stk-line.new-transport-rubl       buf_stk-line.other-base     = temp-shift-stk-line.new-other-base           buf_stk-line.other-rubl     = temp-shift-stk-line.new-other-rubl
          .
        end.
        else do:
          if available buf_stk-line
          then do:
            delete buf_stk-line .
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure check-valid-archives :
  define buffer day_stk-tot   for ub.stk-tot .
  define buffer shift_stk-tot for ub.stk-tot .
  define variable v-different-fields as character no-undo .
  do
  on error undo, return error
  :
    find last day_stk-tot no-lock
      where day_stk-tot.obj-type   = ub.trn-doc.obj-type
        and day_stk-tot.obj-code   = ub.trn-doc.obj-code
        and day_stk-tot.sum-type   = 'crsa':U
        and day_stk-tot.shift-date = ?
      .
    find last shift_stk-tot no-lock
      where shift_stk-tot.obj-type   = ub.trn-doc.obj-type
        and shift_stk-tot.obj-code   = ub.trn-doc.obj-code
        and shift_stk-tot.sum-type   = 'crsa':U
        and shift_stk-tot.shift-date <> ?
      .
    buffer-compare
      day_stk-tot
      except fact-order shift-date shift-num
      to shift_stk-tot
      case-sensitive
      save result in v-different-fields .
    if v-different-fields <> ""
    then do:
      output stream slog to calc-arh.err append .
      export stream slog v-different-fields .
      export stream slog "day_stk-tot" .
      export stream slog day_stk-tot .
      export stream slog "shift_stk-tot" .
      export stream slog shift_stk-tot .
      output stream slog close .
      message
        vss-workfile vss-revision vss-description skip
        "Внутренняя ошибка расчета складского архива по товарам" skip
        v-different-fields skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
procedure show-action :
  do
  on error undo, return error
  :
    define input parameter p-action as character no-undo .
    define variable v-today as date      no-undo.
    define variable v-time  as integer   no-undo.
    run cur-time in this-procedure ( output v-today
                                   , output v-time
                                   ).
    assign
      current-time = string(v-time - start-time, "HH:MM:SS")
      current-action = p-action
    .
    if mFrameView
    then display
      current-time
      current-action
      with frame inf.
  end.
end procedure.
