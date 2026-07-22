block-level on error undo, throw.
define input  parameter p-doc-code       as character no-undo .
define input  parameter p-cut-date       as date      no-undo .
define input  parameter p-check-only     as logical   no-undo .
define output parameter p-need-process   as logical   no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Создание складского архива по поставщикам".
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
      p-vss-parameters = substitute('&1|&2|&3':u,p-doc-code,p-cut-date,p-check-only)
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
define variable v-ind                            as integer   no-undo .
define variable start-time                       as integer   no-undo .
define variable current-time                     as character no-undo .
define variable current-action                   as character no-undo .
define variable v-ot-fact-order                  as decimal   no-undo .
define variable v-stk-supp-tot-fact-order        as decimal   no-undo .
define variable v-stk-supp-line-fact-order       as decimal   no-undo .
define variable v-shift-stk-supp-tot-fact-order  as decimal   no-undo .
define variable v-shift-stk-supp-line-fact-order as decimal   no-undo .
define variable v-shift-on                       as logical   no-undo .
define variable v-fact-order                     as decimal   no-undo .
define variable v-shift-end-fact-order           as decimal   no-undo .
define variable v-day-end-fact-order             as decimal   no-undo .
define variable v-shift-cut-fact-order           as decimal   no-undo .
define variable v-day-cut-fact-order             as decimal   no-undo .
define variable v-cons-pay                       as integer   no-undo .
define variable v-cons-type                      as character no-undo .
define variable v-today                          as date      no-undo .
define variable v-time                           as integer   no-undo .
define temp-table temp-stk-supp-tot no-undo like ub.stk-supp-tot   field new-fact-qnty      like ub.stk-supp-tot.fact-qnty      column-label 'new-fact-qnty'           field new-sum-base       like ub.stk-supp-tot.sum-base       column-label 'new-sum-base'            field new-sum-rubl       like ub.stk-supp-tot.sum-rubl       column-label 'new-sum-rubl'            field new-vat-base       like ub.stk-supp-tot.vat-base       column-label 'new-vat-base'            field new-vat-rubl       like ub.stk-supp-tot.vat-rubl       column-label 'new-vat-rubl'            field new-slt-base       like ub.stk-supp-tot.slt-base       column-label 'new-slt-base'            field new-slt-rubl       like ub.stk-supp-tot.slt-rubl       column-label 'new-slt-rubl'            field new-road-tax-base  like ub.stk-supp-tot.road-tax-base  column-label 'new-road-tax-base'       field new-road-tax-rubl  like ub.stk-supp-tot.road-tax-rubl  column-label 'new-road-tax-rubl'       field new-excise-base    like ub.stk-supp-tot.excise-base    column-label 'new-excise-base'         field new-excise-rubl    like ub.stk-supp-tot.excise-rubl    column-label 'new-excise-rubl'         field new-transport-base like ub.stk-supp-tot.transport-base column-label 'new-transport-base'      field new-transport-rubl like ub.stk-supp-tot.transport-rubl column-label 'new-transport-rubl'      field new-other-base     like ub.stk-supp-tot.other-base     column-label 'new-other-base'          field new-other-rubl     like ub.stk-supp-tot.other-rubl     column-label 'new-other-rubl'        index pi is primary unique  obj-type obj-code cli-type cli-code fact-order sum-type cat-id   index category              obj-type obj-code cli-type cli-code sum-type cat-id fact-order   index sum-type              sum-type cat-id .
define temp-table temp-shift-stk-supp-tot no-undo like ub.stk-supp-tot   field new-fact-qnty      like ub.stk-supp-tot.fact-qnty      column-label 'new-fact-qnty'           field new-sum-base       like ub.stk-supp-tot.sum-base       column-label 'new-sum-base'            field new-sum-rubl       like ub.stk-supp-tot.sum-rubl       column-label 'new-sum-rubl'            field new-vat-base       like ub.stk-supp-tot.vat-base       column-label 'new-vat-base'            field new-vat-rubl       like ub.stk-supp-tot.vat-rubl       column-label 'new-vat-rubl'            field new-slt-base       like ub.stk-supp-tot.slt-base       column-label 'new-slt-base'            field new-slt-rubl       like ub.stk-supp-tot.slt-rubl       column-label 'new-slt-rubl'            field new-road-tax-base  like ub.stk-supp-tot.road-tax-base  column-label 'new-road-tax-base'       field new-road-tax-rubl  like ub.stk-supp-tot.road-tax-rubl  column-label 'new-road-tax-rubl'       field new-excise-base    like ub.stk-supp-tot.excise-base    column-label 'new-excise-base'         field new-excise-rubl    like ub.stk-supp-tot.excise-rubl    column-label 'new-excise-rubl'         field new-transport-base like ub.stk-supp-tot.transport-base column-label 'new-transport-base'      field new-transport-rubl like ub.stk-supp-tot.transport-rubl column-label 'new-transport-rubl'      field new-other-base     like ub.stk-supp-tot.other-base     column-label 'new-other-base'          field new-other-rubl     like ub.stk-supp-tot.other-rubl     column-label 'new-other-rubl'        index pi is primary unique  obj-type obj-code cli-type cli-code fact-order sum-type cat-id   index category              obj-type obj-code cli-type cli-code sum-type cat-id fact-order   index sum-type              sum-type cat-id .
define temp-table temp-stk-supp-line no-undo like ub.stk-supp-line   field new-fact-qnty      like ub.stk-supp-line.fact-qnty      column-label 'new-fact-qnty'           field new-sum-base       like ub.stk-supp-line.sum-base       column-label 'new-sum-base'            field new-sum-rubl       like ub.stk-supp-line.sum-rubl       column-label 'new-sum-rubl'            field new-vat-base       like ub.stk-supp-line.vat-base       column-label 'new-vat-base'            field new-vat-rubl       like ub.stk-supp-line.vat-rubl       column-label 'new-vat-rubl'            field new-slt-base       like ub.stk-supp-line.slt-base       column-label 'new-slt-base'            field new-slt-rubl       like ub.stk-supp-line.slt-rubl       column-label 'new-slt-rubl'            field new-road-tax-base  like ub.stk-supp-line.road-tax-base  column-label 'new-road-tax-base'       field new-road-tax-rubl  like ub.stk-supp-line.road-tax-rubl  column-label 'new-road-tax-rubl'       field new-excise-base    like ub.stk-supp-line.excise-base    column-label 'new-excise-base'         field new-excise-rubl    like ub.stk-supp-line.excise-rubl    column-label 'new-excise-rubl'         field new-transport-base like ub.stk-supp-line.transport-base column-label 'new-transport-base'      field new-transport-rubl like ub.stk-supp-line.transport-rubl column-label 'new-transport-rubl'      field new-other-base     like ub.stk-supp-line.other-base     column-label 'new-other-base'          field new-other-rubl     like ub.stk-supp-line.other-rubl     column-label 'new-other-rubl'        index pi is primary unique obj-type obj-code cli-type cli-code artic prod-type prod-code fact-order sum-type cat-id   index category             obj-type obj-code cli-type cli-code artic prod-type prod-code sum-type cat-id fact-order   index sum-type             sum-type cat-id .
define temp-table temp-shift-stk-supp-line no-undo like ub.stk-supp-line   field new-fact-qnty      like ub.stk-supp-line.fact-qnty      column-label 'new-fact-qnty'           field new-sum-base       like ub.stk-supp-line.sum-base       column-label 'new-sum-base'            field new-sum-rubl       like ub.stk-supp-line.sum-rubl       column-label 'new-sum-rubl'            field new-vat-base       like ub.stk-supp-line.vat-base       column-label 'new-vat-base'            field new-vat-rubl       like ub.stk-supp-line.vat-rubl       column-label 'new-vat-rubl'            field new-slt-base       like ub.stk-supp-line.slt-base       column-label 'new-slt-base'            field new-slt-rubl       like ub.stk-supp-line.slt-rubl       column-label 'new-slt-rubl'            field new-road-tax-base  like ub.stk-supp-line.road-tax-base  column-label 'new-road-tax-base'       field new-road-tax-rubl  like ub.stk-supp-line.road-tax-rubl  column-label 'new-road-tax-rubl'       field new-excise-base    like ub.stk-supp-line.excise-base    column-label 'new-excise-base'         field new-excise-rubl    like ub.stk-supp-line.excise-rubl    column-label 'new-excise-rubl'         field new-transport-base like ub.stk-supp-line.transport-base column-label 'new-transport-base'      field new-transport-rubl like ub.stk-supp-line.transport-rubl column-label 'new-transport-rubl'      field new-other-base     like ub.stk-supp-line.other-base     column-label 'new-other-base'          field new-other-rubl     like ub.stk-supp-line.other-rubl     column-label 'new-other-rubl'        index pi is primary unique obj-type obj-code cli-type cli-code artic prod-type prod-code fact-order sum-type cat-id   index category             obj-type obj-code cli-type cli-code artic prod-type prod-code sum-type cat-id fact-order   index sum-type             sum-type cat-id .
define temp-table temp-ot-supp-tot no-undo like ub.ot-supp-tot   field new-fact-qnty      like ub.ot-supp-tot.fact-qnty      column-label 'new-fact-qnty'           field new-sum-base       like ub.ot-supp-tot.sum-base       column-label 'new-sum-base'            field new-sum-rubl       like ub.ot-supp-tot.sum-rubl       column-label 'new-sum-rubl'            field new-vat-base       like ub.ot-supp-tot.vat-base       column-label 'new-vat-base'            field new-vat-rubl       like ub.ot-supp-tot.vat-rubl       column-label 'new-vat-rubl'            field new-slt-base       like ub.ot-supp-tot.slt-base       column-label 'new-slt-base'            field new-slt-rubl       like ub.ot-supp-tot.slt-rubl       column-label 'new-slt-rubl'            field new-road-tax-base  like ub.ot-supp-tot.road-tax-base  column-label 'new-road-tax-base'       field new-road-tax-rubl  like ub.ot-supp-tot.road-tax-rubl  column-label 'new-road-tax-rubl'       field new-excise-base    like ub.ot-supp-tot.excise-base    column-label 'new-excise-base'         field new-excise-rubl    like ub.ot-supp-tot.excise-rubl    column-label 'new-excise-rubl'         field new-transport-base like ub.ot-supp-tot.transport-base column-label 'new-transport-base'      field new-transport-rubl like ub.ot-supp-tot.transport-rubl column-label 'new-transport-rubl'      field new-other-base     like ub.ot-supp-tot.other-base     column-label 'new-other-base'          field new-other-rubl     like ub.ot-supp-tot.other-rubl     column-label 'new-other-rubl'        index pi is primary unique doc-code cli-type cli-code sum-type cat-id   index obj-ot               obj-type obj-code cli-type cli-code fact-order sum-type cat-id   index sum-type             sum-type cat-id .
define temp-table temp-ot-supp-line no-undo like ub.ot-supp-line   field new-fact-qnty      like ub.ot-supp-line.fact-qnty      column-label 'new-fact-qnty'           field new-sum-base       like ub.ot-supp-line.sum-base       column-label 'new-sum-base'            field new-sum-rubl       like ub.ot-supp-line.sum-rubl       column-label 'new-sum-rubl'            field new-vat-base       like ub.ot-supp-line.vat-base       column-label 'new-vat-base'            field new-vat-rubl       like ub.ot-supp-line.vat-rubl       column-label 'new-vat-rubl'            field new-slt-base       like ub.ot-supp-line.slt-base       column-label 'new-slt-base'            field new-slt-rubl       like ub.ot-supp-line.slt-rubl       column-label 'new-slt-rubl'            field new-road-tax-base  like ub.ot-supp-line.road-tax-base  column-label 'new-road-tax-base'       field new-road-tax-rubl  like ub.ot-supp-line.road-tax-rubl  column-label 'new-road-tax-rubl'       field new-excise-base    like ub.ot-supp-line.excise-base    column-label 'new-excise-base'         field new-excise-rubl    like ub.ot-supp-line.excise-rubl    column-label 'new-excise-rubl'         field new-transport-base like ub.ot-supp-line.transport-base column-label 'new-transport-base'      field new-transport-rubl like ub.ot-supp-line.transport-rubl column-label 'new-transport-rubl'      field new-other-base     like ub.ot-supp-line.other-base     column-label 'new-other-base'          field new-other-rubl     like ub.ot-supp-line.other-rubl     column-label 'new-other-rubl'        index pi is primary unique  doc-code cli-type cli-code artic prod-type prod-code sum-type cat-id   index art-ot                obj-type obj-code cli-type cli-code artic prod-type prod-code fact-order sum-type cat-id   index sum-type              sum-type cat-id .
define temp-table temp-init-stk-supp-tot no-undo   field cli-type  like ub.stk-supp-tot.cli-type    field cli-code  like ub.stk-supp-tot.cli-code    index xpk is primary unique cli-type cli-code .
define temp-table temp-init-stk-supp-line no-undo   field cli-type  like ub.stk-supp-line.cli-type    field cli-code  like ub.stk-supp-line.cli-code    field artic     like ub.stk-supp-line.artic       field prod-type like ub.stk-supp-line.prod-type   field prod-code like ub.stk-supp-line.prod-code   index xpk is primary unique cli-type cli-code artic prod-type prod-code .
def var v-fact-qnty      like ub.ot-supp-tot.fact-qnty       no-undo .     def var v-sum-base       like ub.ot-supp-tot.sum-base        no-undo .     def var v-sum-rubl       like ub.ot-supp-tot.sum-rubl        no-undo .     def var v-vat-base       like ub.ot-supp-tot.vat-base        no-undo .     def var v-vat-rubl       like ub.ot-supp-tot.vat-rubl        no-undo .     def var v-slt-base       like ub.ot-supp-tot.slt-base        no-undo .     def var v-slt-rubl       like ub.ot-supp-tot.slt-rubl        no-undo .     def var v-road-tax-base  like ub.ot-supp-tot.road-tax-base   no-undo .     def var v-road-tax-rubl  like ub.ot-supp-tot.road-tax-rubl   no-undo .     def var v-excise-base    like ub.ot-supp-tot.excise-base     no-undo .     def var v-excise-rubl    like ub.ot-supp-tot.excise-rubl     no-undo .     def var v-transport-base like ub.ot-supp-tot.transport-base  no-undo .     def var v-transport-rubl like ub.ot-supp-tot.transport-rubl  no-undo .     def var v-other-base     like ub.ot-supp-tot.other-base      no-undo .     def var v-other-rubl     like ub.ot-supp-tot.other-rubl      no-undo .
def var v-sale-fact-qnty      like ub.ot-supp-tot.fact-qnty       no-undo .     def var v-sale-sum-base       like ub.ot-supp-tot.sum-base        no-undo .     def var v-sale-sum-rubl       like ub.ot-supp-tot.sum-rubl        no-undo .     def var v-sale-vat-base       like ub.ot-supp-tot.vat-base        no-undo .     def var v-sale-vat-rubl       like ub.ot-supp-tot.vat-rubl        no-undo .     def var v-sale-slt-base       like ub.ot-supp-tot.slt-base        no-undo .     def var v-sale-slt-rubl       like ub.ot-supp-tot.slt-rubl        no-undo .     def var v-sale-road-tax-base  like ub.ot-supp-tot.road-tax-base   no-undo .     def var v-sale-road-tax-rubl  like ub.ot-supp-tot.road-tax-rubl   no-undo .     def var v-sale-excise-base    like ub.ot-supp-tot.excise-base     no-undo .     def var v-sale-excise-rubl    like ub.ot-supp-tot.excise-rubl     no-undo .     def var v-sale-transport-base like ub.ot-supp-tot.transport-base  no-undo .     def var v-sale-transport-rubl like ub.ot-supp-tot.transport-rubl  no-undo .     def var v-sale-other-base     like ub.ot-supp-tot.other-base      no-undo .     def var v-sale-other-rubl     like ub.ot-supp-tot.other-rubl      no-undo .
define buffer buf_trn-doc for ub.trn-doc .
define buffer buf_doc-line for ub.doc-line .
main-block :
do transaction
on error undo main-block, return error
:
  find first buf_trn-doc share-lock
    where buf_trn-doc.doc-code = p-doc-code
    no-error .
  if not available buf_trn-doc
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не найден документ" p-doc-code skip
      view-as alert-box error .
    undo main-block, return error .
  end.
  if buf_trn-doc.status_ <> 'факт':U
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Нельзя рассчитать складской архив по поставщикам" skip
      "для складского документа не закрытого до статуса" 'факт':U skip
      "Документ" p-doc-code skip
      view-as alert-box error .
    undo main-block, return error .
  end.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  buf_trn-doc.obj-type
  ,input  buf_trn-doc.obj-code
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
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objatext in g#library
  (input  buf_trn-doc.obj-type
  ,input  buf_trn-doc.obj-code
  ,input  'cons-pay=request'
  ,output v-cons-pay
  ,output v-cons-type
  ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при запуске процедуры objatext" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo main-block, return error .
  end.
  run factord in this-procedure
    (input  buf_trn-doc.fact-date
    ,input  buf_trn-doc.fact-time
    ,input  buf_trn-doc.fact-num
    ,input  buf_trn-doc.shift-date
    ,input  buf_trn-doc.shift-num
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
      "doc-code"                buf_trn-doc.doc-code    skip
      "fact-date"               buf_trn-doc.fact-date   skip
      "fact-time"               buf_trn-doc.fact-time   skip
      "fact-num"                buf_trn-doc.fact-num    skip
      "shift-date"              buf_trn-doc.shift-date  skip
      "shift-num"               buf_trn-doc.shift-num   skip
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
    if p-cut-date = buf_trn-doc.fact-date
    then do:
      assign
        v-day-end-fact-order = v-day-end-fact-order - 0.0000000001
      .
      if v-shift-on = true
      then do:
        define buffer buf_shift-obj for ub.shift-obj .
        find last buf_shift-obj
          where buf_shift-obj.obj-type    = buf_trn-doc.obj-type
            and buf_shift-obj.obj-code    = buf_trn-doc.obj-code
            and buf_shift-obj.shift-date <= p-cut-date
          use-index pi
          no-error .
        if not available buf_shift-obj
        or buf_shift-obj.status_ <> 'зкр':U
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при поиске последней смены" skip
            "Объект" buf_trn-doc.obj-type buf_trn-doc.obj-code skip
            "Дата" p-cut-date skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        if  buf_trn-doc.shift-date = buf_shift-obj.shift-date
        and buf_trn-doc.shift-num  = buf_shift-obj.shift-num
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
  def frame infa
    ub.trn-doc.doc-code                      label "Документ" skip
    ub.trn-doc.obj-type                      label "Объект"
    ub.trn-doc.obj-code                      no-label skip
    ub.trn-doc.fact-date format "99/99/9999" label "Дата закрытия" skip
    current-action       format "x(40)"      no-label skip
    v-ind                format ">>>>>>>9"   label "Обработано артикулов" skip
    ub.doc-line.artic                        label "Текущий артикул" skip
    current-time         format "x(8)"       label "Время расчета документа" skip
    with view-as dialog-box side-labels three-d
    title "Расчет складского архива по поставщикам"
    .
  define variable mFrameView      as logical   no-undo init yes.
  define variable mFramHandle as handle no-undo.
  mFramHandle = frame infa:handle.
  if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameoxmError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameoxmError").
      log-manager:write-message("visible-frame-mod=" + string(mFramHandle:visible), "frameoxmError").
  end.
  mFrameView = not session:batch-mode and mFramHandle:visible.
  run cur-time in this-procedure ( output v-today
                                 , output start-time
                                 ).
  if mFrameView
  then do:
     view frame infa .
  display
    buf_trn-doc.doc-code @ ub.trn-doc.doc-code
    buf_trn-doc.obj-type @ ub.trn-doc.obj-type
    buf_trn-doc.obj-code @ ub.trn-doc.obj-code
    buf_trn-doc.fact-date @ ub.trn-doc.fact-date
    with frame infa .
  end.
  run show-action in this-procedure
    (input "Обработка строк документа"
    ).
  assign
    v-ot-fact-order                  = v-fact-order
    v-stk-supp-tot-fact-order        = v-day-end-fact-order
    v-stk-supp-line-fact-order       = v-day-end-fact-order
    v-shift-stk-supp-tot-fact-order  = v-shift-end-fact-order
    v-shift-stk-supp-line-fact-order = v-shift-end-fact-order
  .
  if p-check-only <> true
  then do:
    run init-ot-table in this-procedure no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры init-ot-table" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo main-block, return error .
    end.
  end.
  for each buf_doc-line no-lock
    where buf_doc-line.doc-code = buf_trn-doc.doc-code
  on error undo main-block, return error
  :
    run process-doc-line in this-procedure
      (input buf_doc-line.doc-code
      ,input buf_doc-line.obj-type
      ,input buf_doc-line.obj-code
      ,input buf_doc-line.artic
      ,input buf_doc-line.prod-type
      ,input buf_doc-line.prod-code
      ) no-error .
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
      v-ind = v-ind + 1
    .
    if v-ind modulo 10 = 0
    then do:
      run cur-time in this-procedure ( output v-today
                                     , output v-time
                                     ).
      assign
        current-time = string(v-time - start-time, "HH:MM:SS")
      .
      if mFrameView
      then do:
      display
        v-ind
        buf_doc-line.artic
        current-time
        with frame infa .
      end.
    end.
  end.
  if p-check-only <> true
  then do:
    run update-ot-supp-tot in this-procedure no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры update-ot-supp-tot" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo main-block, return error .
    end.
    run init-stk-table in this-procedure no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры init-stk-table" skip
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
      (input "Сохранение складского архива по поставщикам в базу данных"
      ).
    run store-ot-table in this-procedure no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры store-ot-table" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo main-block, return error .
    end.
    run store-stk-temp-table in this-procedure no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры store-stk-temp-table" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo main-block, return error .
    end.
    run show-action in this-procedure
      (input "Расчет документа закончен"
      ).
  end.
  else do:
    run check-need-process in this-procedure
      (output p-need-process
      ) .
  end.
end.
procedure init-ot-table :
  define buffer buf_ot-supp-tot for ub.ot-supp-tot .
  define buffer buf_ot-supp-line for ub.ot-supp-line .
  define buffer buf_temp-ot-supp-tot for temp-ot-supp-tot .
  define buffer buf_temp-ot-supp-line for temp-ot-supp-line .
  do
  on error undo, return error
  :
    for each buf_ot-supp-tot no-lock
      where buf_ot-supp-tot.doc-code = buf_trn-doc.doc-code
    on error undo, return error
    :
      create buf_temp-ot-supp-tot .
      buffer-copy buf_ot-supp-tot to buf_temp-ot-supp-tot
        .
    end.
    for each buf_ot-supp-line no-lock
      where buf_ot-supp-line.doc-code  = buf_trn-doc.doc-code
    on error undo, return error
    :
      create buf_temp-ot-supp-line .
      buffer-copy buf_ot-supp-line to buf_temp-ot-supp-line
        .
    end.
  end.
end procedure.
procedure process-doc-line :
  define input  parameter p-doc-code  as character no-undo .
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-artic     as character no-undo .
  define input  parameter p-prod-type as character no-undo .
  define input  parameter p-prod-code as integer   no-undo .
  define buffer buf_tt-clcparts for tt-clcparts .
  define buffer buf_parts for ub.parts .
  define buffer buf_doc-line for ub.doc-line .
  define buffer buf_tt-allsum-line for tt-allsum-line .
  define buffer buf_temp-ot-supp-line for temp-ot-supp-line .
  do
  on error undo, return error
  :
    define variable ind-ext    as integer no-undo .
    define variable v-cat-id   as character no-undo extent 2 .
    define variable v-sum-type as character no-undo extent 2 .
    define variable v-curr-r-b as character no-undo .
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
    define variable v-gds-goods as logical   no-undo .
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'gds-goods=request':u
  ,output v-gds-goods
  ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута товара" skip
        "Переоценка" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        'gds-goods=request':u
        view-as alert-box error .
      undo, return error .
    end.
    if v-gds-goods <> true
    then do:
      next .
    end.
    define variable v-doc-sign as integer   no-undo .
    if buf_trn-doc.doc-type = 'рас':U
    or buf_trn-doc.doc-type = 'спи':U
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
    for each buf_parts no-lock
      where buf_parts.out-code  = p-doc-code
        and buf_parts.obj-type  = p-obj-type
        and buf_parts.obj-code  = p-obj-code
        and buf_parts.artic     = p-artic
        and buf_parts.prod-type = p-prod-type
        and buf_parts.prod-code = p-prod-code
    on error undo, return error
    :
      for each buf_tt-clcparts
      on error undo, return error return-value
      :
        delete buf_tt-clcparts .
      end.
      create buf_tt-clcparts .
      buffer-copy buf_parts to buf_tt-clcparts .
      find first buf_doc-line no-lock
        where buf_doc-line.doc-code  = p-doc-code
          and buf_doc-line.artic     = p-artic
          and buf_doc-line.prod-type = p-prod-type
          and buf_doc-line.prod-code = p-prod-code
        no-error .
      if not available buf_doc-line
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не найдена строка документа" skip
          "Складской документ" p-doc-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      run clcprtsl_calc-ttable in this-procedure
        (input true
        ,input false
        ,input buf_doc-line.road-tax
        ,input buf_doc-line.excise
        ,input buf_doc-line.vat-pc
        ,input buf_doc-line.cons-vat-pc
        ,input buf_doc-line.slt-pc
        ,input buf_trn-doc.base-rate
        ,input buf_trn-doc.base-scale
        ,input v-curr-r-b
        ,input ?
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
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      define variable v-ahsp-type-ind        as integer   no-undo .
      define variable v-ahsp-type-list       as character extent 5 no-undo
        initial ['prch':U, 'cacc':U, 'benf':U, 'stor':U, 'cons':U] .
      define variable v-allsum-sum-type-list as character extent 5 no-undo
        initial ['сумма_по_выкупу_со_знаком':U, 'сумма_по_консигнации_закупка_со_знаком':U, 'сумма_по_консигнации_выгода_со_знаком':U, 'сумма_по_ответственному_хранению_со_знаком':U, 'сумма_по_старой_консигнации_со_знаком':U ] .
      define variable v-ahsp-type            as character no-undo .
      define variable v-allsum-sum-type      as character no-undo .
      do v-ahsp-type-ind = 1 to extent(v-ahsp-type-list)
      :
        assign
          v-ahsp-type       = v-ahsp-type-list[v-ahsp-type-ind]
          v-allsum-sum-type = v-allsum-sum-type-list[v-ahsp-type-ind]
        .
        find first buf_tt-allsum-line
          where buf_tt-allsum-line.sum-type = v-allsum-sum-type
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
          assign
            v-sale-fact-qnty      = buf_tt-allsum-line.fact-qnty
            v-sale-sum-base       = buf_tt-allsum-line.sum-dsc-base-doc
            v-sale-sum-rubl       = buf_tt-allsum-line.sum-dsc-rubl-doc
            v-sale-vat-base       = buf_tt-allsum-line.vat-base-doc
            v-sale-vat-rubl       = buf_tt-allsum-line.vat-rubl-doc
            v-sale-slt-base       = buf_tt-allsum-line.slt-base-doc
            v-sale-slt-rubl       = buf_tt-allsum-line.slt-rubl-doc
            v-sale-road-tax-base  = buf_tt-allsum-line.road-tax-base-doc
            v-sale-road-tax-rubl  = buf_tt-allsum-line.road-tax-rubl-doc
            v-sale-excise-base    = buf_tt-allsum-line.excise-base-doc
            v-sale-excise-rubl    = buf_tt-allsum-line.excise-rubl-doc
            v-sale-transport-base = buf_tt-allsum-line.transport-base-acc
            v-sale-transport-rubl = buf_tt-allsum-line.transport-rubl-acc
            v-sale-other-base     = buf_tt-allsum-line.dsc-base-doc
            v-sale-other-rubl     = buf_tt-allsum-line.dsc-rubl-doc
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
          assign
            v-sale-fact-qnty      = 0
            v-sale-sum-base       = 0
            v-sale-sum-rubl       = 0
            v-sale-vat-base       = 0
            v-sale-vat-rubl       = 0
            v-sale-slt-base       = 0
            v-sale-slt-rubl       = 0
            v-sale-road-tax-base  = 0
            v-sale-road-tax-rubl  = 0
            v-sale-excise-base    = 0
            v-sale-excise-rubl    = 0
            v-sale-transport-base = 0
            v-sale-transport-rubl = 0
            v-sale-other-base     = 0
            v-sale-other-rubl     = 0
          .
        end.
        if v-ahsp-type = 'benf':U
        then do:
          assign
            v-fact-qnty      = 0
            v-sale-fact-qnty = 0
          .
        end.
        if
                                        v-fact-qnty      = ? or    v-sum-base       = ? or    v-sum-rubl       = ? or    v-vat-base       = ? or    v-vat-rubl       = ? or    v-slt-base       = ? or    v-slt-rubl       = ? or    v-road-tax-base  = ? or    v-road-tax-rubl  = ? or    v-excise-base    = ? or    v-excise-rubl    = ? or    v-transport-base = ? or    v-transport-rubl = ? or    v-other-base     = ? or    v-other-rubl     = ?
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Программа clcprtsl.i вернула неопределенные значения" skip
            "Расчет складского архива по поставщикам невозможен" skip
            "Документ" p-doc-code skip
            "Артикул" p-artic p-prod-type p-prod-code skip
                                                                                    "v-fact-qnty"      v-fact-qnty        skip    "v-sum-base"       v-sum-base         skip    "v-sum-rubl"       v-sum-rubl         skip    "v-vat-base"       v-vat-base         skip    "v-vat-rubl"       v-vat-rubl         skip    "v-slt-base"       v-slt-base         skip    "v-slt-rubl"       v-slt-rubl         skip    "v-road-tax-base"  v-road-tax-base    skip    "v-road-tax-rubl"  v-road-tax-rubl    skip    "v-excise-base"    v-excise-base      skip    "v-excise-rubl"    v-excise-rubl      skip    "v-transport-base" v-transport-base   skip    "v-transport-rubl" v-transport-rubl   skip    "v-other-base"     v-other-base       skip    "v-other-rubl"     v-other-rubl
            view-as alert-box error .
          undo, return error .
        end.
        if
                                        v-sale-fact-qnty      = ? or    v-sale-sum-base       = ? or    v-sale-sum-rubl       = ? or    v-sale-vat-base       = ? or    v-sale-vat-rubl       = ? or    v-sale-slt-base       = ? or    v-sale-slt-rubl       = ? or    v-sale-road-tax-base  = ? or    v-sale-road-tax-rubl  = ? or    v-sale-excise-base    = ? or    v-sale-excise-rubl    = ? or    v-sale-transport-base = ? or    v-sale-transport-rubl = ? or    v-sale-other-base     = ? or    v-sale-other-rubl     = ?
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Программа clcprtsl.i вернула неопределенные значения" skip
            "Расчет складского архива по поставщикам невозможен" skip
            "Документ" p-doc-code skip
            "Артикул" p-artic p-prod-type p-prod-code skip
                                                                                    "v-sale-fact-qnty"      v-sale-fact-qnty        skip    "v-sale-sum-base"       v-sale-sum-base         skip    "v-sale-sum-rubl"       v-sale-sum-rubl         skip    "v-sale-vat-base"       v-sale-vat-base         skip    "v-sale-vat-rubl"       v-sale-vat-rubl         skip    "v-sale-slt-base"       v-sale-slt-base         skip    "v-sale-slt-rubl"       v-sale-slt-rubl         skip    "v-sale-road-tax-base"  v-sale-road-tax-base    skip    "v-sale-road-tax-rubl"  v-sale-road-tax-rubl    skip    "v-sale-excise-base"    v-sale-excise-base      skip    "v-sale-excise-rubl"    v-sale-excise-rubl      skip    "v-sale-transport-base" v-sale-transport-base   skip    "v-sale-transport-rubl" v-sale-transport-rubl   skip    "v-sale-other-base"     v-sale-other-base       skip    "v-sale-other-rubl"     v-sale-other-rubl
            view-as alert-box error .
          undo, return error .
        end.
        assign
          v-sum-type[1] = 'cost':U
          v-cat-id[1]   = '##':U
          v-sum-type[2] = 'cost':U + 'p':U
          v-cat-id[2]   = v-ahsp-type
        .
        do ind-ext = 1 to 2
        :
          find first buf_temp-ot-supp-line
            where buf_temp-ot-supp-line.doc-code  = p-doc-code
              and buf_temp-ot-supp-line.cli-type  = buf_parts.supp-type
              and buf_temp-ot-supp-line.cli-code  = buf_parts.supp-code
              and buf_temp-ot-supp-line.artic     = buf_parts.artic
              and buf_temp-ot-supp-line.prod-type = buf_parts.prod-type
              and buf_temp-ot-supp-line.prod-code = buf_parts.prod-code
              and buf_temp-ot-supp-line.sum-type  = v-sum-type[ind-ext]
              and buf_temp-ot-supp-line.cat-id    = v-cat-id[ind-ext]
            no-error .
          if not available buf_temp-ot-supp-line
          then do:
            create buf_temp-ot-supp-line .
            assign
              buf_temp-ot-supp-line.doc-code  = p-doc-code
              buf_temp-ot-supp-line.cli-type  = buf_parts.supp-type
              buf_temp-ot-supp-line.cli-code  = buf_parts.supp-code
              buf_temp-ot-supp-line.artic     = buf_parts.artic
              buf_temp-ot-supp-line.prod-type = buf_parts.prod-type
              buf_temp-ot-supp-line.prod-code = buf_parts.prod-code
              buf_temp-ot-supp-line.sum-type  = v-sum-type[ind-ext]
              buf_temp-ot-supp-line.cat-id    = v-cat-id[ind-ext]
              buf_temp-ot-supp-line.ext-doc-type = buf_trn-doc.ext-doc-type
              buf_temp-ot-supp-line.obj-type     = buf_trn-doc.obj-type
              buf_temp-ot-supp-line.obj-code     = buf_trn-doc.obj-code
              buf_temp-ot-supp-line.fact-order   = v-ot-fact-order
            .
          end.
          assign
                                                                                                            buf_temp-ot-supp-line.new-fact-qnty      = buf_temp-ot-supp-line.new-fact-qnty      + v-fact-qnty           buf_temp-ot-supp-line.new-sum-base       = buf_temp-ot-supp-line.new-sum-base       + v-sum-base            buf_temp-ot-supp-line.new-sum-rubl       = buf_temp-ot-supp-line.new-sum-rubl       + v-sum-rubl            buf_temp-ot-supp-line.new-vat-base       = buf_temp-ot-supp-line.new-vat-base       + v-vat-base            buf_temp-ot-supp-line.new-vat-rubl       = buf_temp-ot-supp-line.new-vat-rubl       + v-vat-rubl            buf_temp-ot-supp-line.new-slt-base       = buf_temp-ot-supp-line.new-slt-base       + v-slt-base            buf_temp-ot-supp-line.new-slt-rubl       = buf_temp-ot-supp-line.new-slt-rubl       + v-slt-rubl            buf_temp-ot-supp-line.new-road-tax-base  = buf_temp-ot-supp-line.new-road-tax-base  + v-road-tax-base       buf_temp-ot-supp-line.new-road-tax-rubl  = buf_temp-ot-supp-line.new-road-tax-rubl  + v-road-tax-rubl       buf_temp-ot-supp-line.new-excise-base    = buf_temp-ot-supp-line.new-excise-base    + v-excise-base         buf_temp-ot-supp-line.new-excise-rubl    = buf_temp-ot-supp-line.new-excise-rubl    + v-excise-rubl         buf_temp-ot-supp-line.new-transport-base = buf_temp-ot-supp-line.new-transport-base + v-transport-base      buf_temp-ot-supp-line.new-transport-rubl = buf_temp-ot-supp-line.new-transport-rubl + v-transport-rubl      buf_temp-ot-supp-line.new-other-base     = buf_temp-ot-supp-line.new-other-base     + v-other-base          buf_temp-ot-supp-line.new-other-rubl     = buf_temp-ot-supp-line.new-other-rubl     + v-other-rubl
          .
        end.
        find first buf_temp-ot-supp-line
          where buf_temp-ot-supp-line.doc-code  = p-doc-code
            and buf_temp-ot-supp-line.cli-type  = buf_parts.supp-type
            and buf_temp-ot-supp-line.cli-code  = buf_parts.supp-code
            and buf_temp-ot-supp-line.artic     = buf_parts.artic
            and buf_temp-ot-supp-line.prod-type = buf_parts.prod-type
            and buf_temp-ot-supp-line.prod-code = buf_parts.prod-code
            and buf_temp-ot-supp-line.sum-type  = 'sale':U
            and buf_temp-ot-supp-line.cat-id    = '##':U
          no-error .
        if not available buf_temp-ot-supp-line
        then do:
          create buf_temp-ot-supp-line .
          assign
            buf_temp-ot-supp-line.doc-code  = p-doc-code
            buf_temp-ot-supp-line.cli-type  = buf_parts.supp-type
            buf_temp-ot-supp-line.cli-code  = buf_parts.supp-code
            buf_temp-ot-supp-line.artic     = buf_parts.artic
            buf_temp-ot-supp-line.prod-type = buf_parts.prod-type
            buf_temp-ot-supp-line.prod-code = buf_parts.prod-code
            buf_temp-ot-supp-line.sum-type  = 'sale':U
            buf_temp-ot-supp-line.cat-id    = '##':U
            buf_temp-ot-supp-line.ext-doc-type = buf_trn-doc.ext-doc-type
            buf_temp-ot-supp-line.obj-type     = buf_trn-doc.obj-type
            buf_temp-ot-supp-line.obj-code     = buf_trn-doc.obj-code
            buf_temp-ot-supp-line.fact-order   = v-ot-fact-order
          .
        end.
        assign
                                                                                          buf_temp-ot-supp-line.new-fact-qnty      = buf_temp-ot-supp-line.new-fact-qnty      + v-sale-fact-qnty           buf_temp-ot-supp-line.new-sum-base       = buf_temp-ot-supp-line.new-sum-base       + v-sale-sum-base            buf_temp-ot-supp-line.new-sum-rubl       = buf_temp-ot-supp-line.new-sum-rubl       + v-sale-sum-rubl            buf_temp-ot-supp-line.new-vat-base       = buf_temp-ot-supp-line.new-vat-base       + v-sale-vat-base            buf_temp-ot-supp-line.new-vat-rubl       = buf_temp-ot-supp-line.new-vat-rubl       + v-sale-vat-rubl            buf_temp-ot-supp-line.new-slt-base       = buf_temp-ot-supp-line.new-slt-base       + v-sale-slt-base            buf_temp-ot-supp-line.new-slt-rubl       = buf_temp-ot-supp-line.new-slt-rubl       + v-sale-slt-rubl            buf_temp-ot-supp-line.new-road-tax-base  = buf_temp-ot-supp-line.new-road-tax-base  + v-sale-road-tax-base       buf_temp-ot-supp-line.new-road-tax-rubl  = buf_temp-ot-supp-line.new-road-tax-rubl  + v-sale-road-tax-rubl       buf_temp-ot-supp-line.new-excise-base    = buf_temp-ot-supp-line.new-excise-base    + v-sale-excise-base         buf_temp-ot-supp-line.new-excise-rubl    = buf_temp-ot-supp-line.new-excise-rubl    + v-sale-excise-rubl         buf_temp-ot-supp-line.new-transport-base = buf_temp-ot-supp-line.new-transport-base + v-sale-transport-base      buf_temp-ot-supp-line.new-transport-rubl = buf_temp-ot-supp-line.new-transport-rubl + v-sale-transport-rubl      buf_temp-ot-supp-line.new-other-base     = buf_temp-ot-supp-line.new-other-base     + v-sale-other-base          buf_temp-ot-supp-line.new-other-rubl     = buf_temp-ot-supp-line.new-other-rubl     + v-sale-other-rubl
        .
      end.
    end.
  end.
end procedure.
procedure update-ot-supp-tot :
  define buffer buf_temp-ot-supp-line for temp-ot-supp-line .
  define buffer buf_temp-ot-supp-tot  for temp-ot-supp-tot .
  do
  on error undo, return error
  :
    for each buf_temp-ot-supp-line
    on error undo, return error
    :
      find first buf_temp-ot-supp-tot
        where buf_temp-ot-supp-tot.doc-code = buf_temp-ot-supp-line.doc-code
          and buf_temp-ot-supp-tot.cli-type = buf_temp-ot-supp-line.cli-type
          and buf_temp-ot-supp-tot.cli-code = buf_temp-ot-supp-line.cli-code
          and buf_temp-ot-supp-tot.sum-type = buf_temp-ot-supp-line.sum-type
          and buf_temp-ot-supp-tot.cat-id   = buf_temp-ot-supp-line.cat-id
        no-error .
      if not available buf_temp-ot-supp-tot
      then do:
        create buf_temp-ot-supp-tot .
        assign
          buf_temp-ot-supp-tot.doc-code = buf_temp-ot-supp-line.doc-code
          buf_temp-ot-supp-tot.cli-type = buf_temp-ot-supp-line.cli-type
          buf_temp-ot-supp-tot.cli-code = buf_temp-ot-supp-line.cli-code
          buf_temp-ot-supp-tot.sum-type = buf_temp-ot-supp-line.sum-type
          buf_temp-ot-supp-tot.cat-id   = buf_temp-ot-supp-line.cat-id
          buf_temp-ot-supp-tot.ext-doc-type = buf_trn-doc.ext-doc-type
          buf_temp-ot-supp-tot.obj-type     = buf_trn-doc.obj-type
          buf_temp-ot-supp-tot.obj-code     = buf_trn-doc.obj-code
          buf_temp-ot-supp-tot.fact-order   = v-ot-fact-order
        .
      end.
      assign
                                                                        buf_temp-ot-supp-tot.new-fact-qnty      = buf_temp-ot-supp-tot.new-fact-qnty      + buf_temp-ot-supp-line.new-fact-qnty           buf_temp-ot-supp-tot.new-sum-base       = buf_temp-ot-supp-tot.new-sum-base       + buf_temp-ot-supp-line.new-sum-base            buf_temp-ot-supp-tot.new-sum-rubl       = buf_temp-ot-supp-tot.new-sum-rubl       + buf_temp-ot-supp-line.new-sum-rubl            buf_temp-ot-supp-tot.new-vat-base       = buf_temp-ot-supp-tot.new-vat-base       + buf_temp-ot-supp-line.new-vat-base            buf_temp-ot-supp-tot.new-vat-rubl       = buf_temp-ot-supp-tot.new-vat-rubl       + buf_temp-ot-supp-line.new-vat-rubl            buf_temp-ot-supp-tot.new-slt-base       = buf_temp-ot-supp-tot.new-slt-base       + buf_temp-ot-supp-line.new-slt-base            buf_temp-ot-supp-tot.new-slt-rubl       = buf_temp-ot-supp-tot.new-slt-rubl       + buf_temp-ot-supp-line.new-slt-rubl            buf_temp-ot-supp-tot.new-road-tax-base  = buf_temp-ot-supp-tot.new-road-tax-base  + buf_temp-ot-supp-line.new-road-tax-base       buf_temp-ot-supp-tot.new-road-tax-rubl  = buf_temp-ot-supp-tot.new-road-tax-rubl  + buf_temp-ot-supp-line.new-road-tax-rubl       buf_temp-ot-supp-tot.new-excise-base    = buf_temp-ot-supp-tot.new-excise-base    + buf_temp-ot-supp-line.new-excise-base         buf_temp-ot-supp-tot.new-excise-rubl    = buf_temp-ot-supp-tot.new-excise-rubl    + buf_temp-ot-supp-line.new-excise-rubl         buf_temp-ot-supp-tot.new-transport-base = buf_temp-ot-supp-tot.new-transport-base + buf_temp-ot-supp-line.new-transport-base      buf_temp-ot-supp-tot.new-transport-rubl = buf_temp-ot-supp-tot.new-transport-rubl + buf_temp-ot-supp-line.new-transport-rubl      buf_temp-ot-supp-tot.new-other-base     = buf_temp-ot-supp-tot.new-other-base     + buf_temp-ot-supp-line.new-other-base          buf_temp-ot-supp-tot.new-other-rubl     = buf_temp-ot-supp-tot.new-other-rubl     + buf_temp-ot-supp-line.new-other-rubl
      .
    end.
  end.
end procedure.
procedure init-stk-table :
  define buffer buf_temp-ot-supp-tot  for temp-ot-supp-tot .
  define buffer buf_temp-ot-supp-line for temp-ot-supp-line .
  do
  on error undo, return error
  :
    for each buf_temp-ot-supp-tot
    on error undo, return error
    :
      run init-stk-supp-tot-table in this-procedure
        (input buf_temp-ot-supp-tot.cli-type
        ,input buf_temp-ot-supp-tot.cli-code
        ) .
    end.
    for each buf_temp-ot-supp-line
    on error undo, return error
    :
      run init-stk-supp-line-table in this-procedure
        (input buf_temp-ot-supp-line.cli-type
        ,input buf_temp-ot-supp-line.cli-code
        ,input buf_temp-ot-supp-line.artic
        ,input buf_temp-ot-supp-line.prod-type
        ,input buf_temp-ot-supp-line.prod-code
        ) .
    end.
  end.
end procedure.
procedure init-stk-supp-tot-table :
  define input parameter p-cli-type as character no-undo .
  define input parameter p-cli-code as integer   no-undo .
  define buffer buf_temp-init-stk-supp-tot for temp-init-stk-supp-tot .
  define buffer buf_stk-supp-tot for ub.stk-supp-tot .
  define buffer buf_temp-stk-supp-tot for temp-stk-supp-tot .
  define buffer buf_temp-shift-stk-supp-tot for temp-shift-stk-supp-tot .
  do
  on error undo, return error
  :
    find first buf_temp-init-stk-supp-tot
      where buf_temp-init-stk-supp-tot.cli-type = p-cli-type
        and buf_temp-init-stk-supp-tot.cli-code = p-cli-code
      no-error .
    if not available buf_temp-init-stk-supp-tot
    then do:
      create buf_temp-init-stk-supp-tot .
      assign
        buf_temp-init-stk-supp-tot.cli-type = p-cli-type
        buf_temp-init-stk-supp-tot.cli-code = p-cli-code
      .
    end.
    else do:
      return .
    end.
    define variable v-root-sum-type                  as character no-undo extent 3 .
    define variable v-line-sum-type                  as character no-undo extent 3 .
    define variable v-root-sum-type-ind-ext          as integer   no-undo .
    define variable v-prev-stk-supp-tot-fact-order   as decimal   no-undo .
    define variable v-prev-stk-supp-line-fact-order  as decimal   no-undo .
    define variable v-prsh-stk-supp-tot-fact-order   as decimal   no-undo .
    define variable v-prsh-stk-supp-line-fact-order  as decimal   no-undo .
    assign
      v-root-sum-type[1] = 'cost':U
      v-root-sum-type[2] = 'csdt':U         + buf_trn-doc.ext-doc-type
      v-root-sum-type[3] = 'sadt':U         + buf_trn-doc.ext-doc-type
    .
    do v-root-sum-type-ind-ext = 1 to extent(v-root-sum-type)
    :
      find last buf_stk-supp-tot no-lock
        where buf_stk-supp-tot.obj-type   = buf_trn-doc.obj-type
          and buf_stk-supp-tot.obj-code   = buf_trn-doc.obj-code
          and buf_stk-supp-tot.cli-type   = p-cli-type
          and buf_stk-supp-tot.cli-code   = p-cli-code
          and buf_stk-supp-tot.sum-type   = v-root-sum-type[v-root-sum-type-ind-ext]
          and buf_stk-supp-tot.cat-id     = '##':U
          and buf_stk-supp-tot.fact-order <= v-stk-supp-tot-fact-order
          and buf_stk-supp-tot.shift-date = ?
        use-index category
        no-error .
      if available buf_stk-supp-tot
      then do:
        assign
          v-prev-stk-supp-tot-fact-order = buf_stk-supp-tot.fact-order
        .
        for each buf_stk-supp-tot no-lock
          where buf_stk-supp-tot.obj-type   = buf_trn-doc.obj-type
            and buf_stk-supp-tot.obj-code   = buf_trn-doc.obj-code
            and buf_stk-supp-tot.cli-type   = p-cli-type
            and buf_stk-supp-tot.cli-code   = p-cli-code
            and buf_stk-supp-tot.fact-order = v-prev-stk-supp-tot-fact-order
            and buf_stk-supp-tot.sum-type   begins v-root-sum-type[v-root-sum-type-ind-ext]
        on error undo, return error
        :
          create buf_temp-stk-supp-tot .
                              assign
            buf_temp-stk-supp-tot.obj-type     = buf_stk-supp-tot.obj-type     buf_temp-stk-supp-tot.obj-code     = buf_stk-supp-tot.obj-code     buf_temp-stk-supp-tot.cli-type     = buf_stk-supp-tot.cli-type     buf_temp-stk-supp-tot.cli-code     = buf_stk-supp-tot.cli-code     buf_temp-stk-supp-tot.fact-order   = buf_stk-supp-tot.fact-order   buf_temp-stk-supp-tot.sum-type     = buf_stk-supp-tot.sum-type     buf_temp-stk-supp-tot.cat-id       = buf_stk-supp-tot.cat-id       buf_temp-stk-supp-tot.fact-date    = buf_stk-supp-tot.fact-date    buf_temp-stk-supp-tot.shift-num    = buf_stk-supp-tot.shift-num    buf_temp-stk-supp-tot.shift-date   = buf_stk-supp-tot.shift-date
          .
          if v-stk-supp-tot-fact-order = v-prev-stk-supp-tot-fact-order
          then do:
            assign
                                                                                                  buf_temp-stk-supp-tot.fact-qnty      = buf_stk-supp-tot.fact-qnty            buf_temp-stk-supp-tot.sum-base       = buf_stk-supp-tot.sum-base             buf_temp-stk-supp-tot.sum-rubl       = buf_stk-supp-tot.sum-rubl             buf_temp-stk-supp-tot.vat-base       = buf_stk-supp-tot.vat-base             buf_temp-stk-supp-tot.vat-rubl       = buf_stk-supp-tot.vat-rubl             buf_temp-stk-supp-tot.slt-base       = buf_stk-supp-tot.slt-base             buf_temp-stk-supp-tot.slt-rubl       = buf_stk-supp-tot.slt-rubl             buf_temp-stk-supp-tot.road-tax-base  = buf_stk-supp-tot.road-tax-base        buf_temp-stk-supp-tot.road-tax-rubl  = buf_stk-supp-tot.road-tax-rubl        buf_temp-stk-supp-tot.excise-base    = buf_stk-supp-tot.excise-base          buf_temp-stk-supp-tot.excise-rubl    = buf_stk-supp-tot.excise-rubl          buf_temp-stk-supp-tot.transport-base = buf_stk-supp-tot.transport-base       buf_temp-stk-supp-tot.transport-rubl = buf_stk-supp-tot.transport-rubl       buf_temp-stk-supp-tot.other-base     = buf_stk-supp-tot.other-base           buf_temp-stk-supp-tot.other-rubl     = buf_stk-supp-tot.other-rubl
            .
          end.
          assign
            buf_temp-stk-supp-tot.fact-order = v-stk-supp-tot-fact-order
            buf_temp-stk-supp-tot.fact-date  = buf_trn-doc.fact-date
            buf_temp-stk-supp-tot.shift-num  = 0
            buf_temp-stk-supp-tot.shift-date = ?
          .
          assign
                                                                                    buf_temp-stk-supp-tot.new-fact-qnty      = buf_stk-supp-tot.fact-qnty            buf_temp-stk-supp-tot.new-sum-base       = buf_stk-supp-tot.sum-base             buf_temp-stk-supp-tot.new-sum-rubl       = buf_stk-supp-tot.sum-rubl             buf_temp-stk-supp-tot.new-vat-base       = buf_stk-supp-tot.vat-base             buf_temp-stk-supp-tot.new-vat-rubl       = buf_stk-supp-tot.vat-rubl             buf_temp-stk-supp-tot.new-slt-base       = buf_stk-supp-tot.slt-base             buf_temp-stk-supp-tot.new-slt-rubl       = buf_stk-supp-tot.slt-rubl             buf_temp-stk-supp-tot.new-road-tax-base  = buf_stk-supp-tot.road-tax-base        buf_temp-stk-supp-tot.new-road-tax-rubl  = buf_stk-supp-tot.road-tax-rubl        buf_temp-stk-supp-tot.new-excise-base    = buf_stk-supp-tot.excise-base          buf_temp-stk-supp-tot.new-excise-rubl    = buf_stk-supp-tot.excise-rubl          buf_temp-stk-supp-tot.new-transport-base = buf_stk-supp-tot.transport-base       buf_temp-stk-supp-tot.new-transport-rubl = buf_stk-supp-tot.transport-rubl       buf_temp-stk-supp-tot.new-other-base     = buf_stk-supp-tot.other-base           buf_temp-stk-supp-tot.new-other-rubl     = buf_stk-supp-tot.other-rubl
          .
        end.
      end.
      else do:
        create buf_temp-stk-supp-tot.
        assign
          buf_temp-stk-supp-tot.obj-type   = buf_trn-doc.obj-type
          buf_temp-stk-supp-tot.obj-code   = buf_trn-doc.obj-code
          buf_temp-stk-supp-tot.cli-type   = p-cli-type
          buf_temp-stk-supp-tot.cli-code   = p-cli-code
          buf_temp-stk-supp-tot.fact-order = v-stk-supp-tot-fact-order
          buf_temp-stk-supp-tot.sum-type   = v-root-sum-type[v-root-sum-type-ind-ext]
          buf_temp-stk-supp-tot.cat-id     = '##':U
          buf_temp-stk-supp-tot.fact-date  = buf_trn-doc.fact-date
          buf_temp-stk-supp-tot.shift-num  = 0
          buf_temp-stk-supp-tot.shift-date = ?
        .
      end.
      for each buf_stk-supp-tot no-lock
        where buf_stk-supp-tot.obj-type   = buf_trn-doc.obj-type
          and buf_stk-supp-tot.obj-code   = buf_trn-doc.obj-code
          and buf_stk-supp-tot.cli-type   = p-cli-type
          and buf_stk-supp-tot.cli-code   = p-cli-code
          and buf_stk-supp-tot.fact-order > v-stk-supp-tot-fact-order
          and buf_stk-supp-tot.fact-order <= v-day-cut-fact-order
      on error undo, return error
      :
        if buf_stk-supp-tot.sum-type   begins v-root-sum-type[v-root-sum-type-ind-ext]
        and buf_stk-supp-tot.shift-date = ?
        then do:
          create buf_temp-stk-supp-tot .
                              assign
            buf_temp-stk-supp-tot.obj-type     = buf_stk-supp-tot.obj-type     buf_temp-stk-supp-tot.obj-code     = buf_stk-supp-tot.obj-code     buf_temp-stk-supp-tot.cli-type     = buf_stk-supp-tot.cli-type     buf_temp-stk-supp-tot.cli-code     = buf_stk-supp-tot.cli-code     buf_temp-stk-supp-tot.fact-order   = buf_stk-supp-tot.fact-order   buf_temp-stk-supp-tot.sum-type     = buf_stk-supp-tot.sum-type     buf_temp-stk-supp-tot.cat-id       = buf_stk-supp-tot.cat-id       buf_temp-stk-supp-tot.fact-date    = buf_stk-supp-tot.fact-date    buf_temp-stk-supp-tot.shift-num    = buf_stk-supp-tot.shift-num    buf_temp-stk-supp-tot.shift-date   = buf_stk-supp-tot.shift-date
          .
          assign
                                                                                    buf_temp-stk-supp-tot.new-fact-qnty      = buf_stk-supp-tot.fact-qnty            buf_temp-stk-supp-tot.new-sum-base       = buf_stk-supp-tot.sum-base             buf_temp-stk-supp-tot.new-sum-rubl       = buf_stk-supp-tot.sum-rubl             buf_temp-stk-supp-tot.new-vat-base       = buf_stk-supp-tot.vat-base             buf_temp-stk-supp-tot.new-vat-rubl       = buf_stk-supp-tot.vat-rubl             buf_temp-stk-supp-tot.new-slt-base       = buf_stk-supp-tot.slt-base             buf_temp-stk-supp-tot.new-slt-rubl       = buf_stk-supp-tot.slt-rubl             buf_temp-stk-supp-tot.new-road-tax-base  = buf_stk-supp-tot.road-tax-base        buf_temp-stk-supp-tot.new-road-tax-rubl  = buf_stk-supp-tot.road-tax-rubl        buf_temp-stk-supp-tot.new-excise-base    = buf_stk-supp-tot.excise-base          buf_temp-stk-supp-tot.new-excise-rubl    = buf_stk-supp-tot.excise-rubl          buf_temp-stk-supp-tot.new-transport-base = buf_stk-supp-tot.transport-base       buf_temp-stk-supp-tot.new-transport-rubl = buf_stk-supp-tot.transport-rubl       buf_temp-stk-supp-tot.new-other-base     = buf_stk-supp-tot.other-base           buf_temp-stk-supp-tot.new-other-rubl     = buf_stk-supp-tot.other-rubl
                                                                                    buf_temp-stk-supp-tot.fact-qnty      = buf_stk-supp-tot.fact-qnty            buf_temp-stk-supp-tot.sum-base       = buf_stk-supp-tot.sum-base             buf_temp-stk-supp-tot.sum-rubl       = buf_stk-supp-tot.sum-rubl             buf_temp-stk-supp-tot.vat-base       = buf_stk-supp-tot.vat-base             buf_temp-stk-supp-tot.vat-rubl       = buf_stk-supp-tot.vat-rubl             buf_temp-stk-supp-tot.slt-base       = buf_stk-supp-tot.slt-base             buf_temp-stk-supp-tot.slt-rubl       = buf_stk-supp-tot.slt-rubl             buf_temp-stk-supp-tot.road-tax-base  = buf_stk-supp-tot.road-tax-base        buf_temp-stk-supp-tot.road-tax-rubl  = buf_stk-supp-tot.road-tax-rubl        buf_temp-stk-supp-tot.excise-base    = buf_stk-supp-tot.excise-base          buf_temp-stk-supp-tot.excise-rubl    = buf_stk-supp-tot.excise-rubl          buf_temp-stk-supp-tot.transport-base = buf_stk-supp-tot.transport-base       buf_temp-stk-supp-tot.transport-rubl = buf_stk-supp-tot.transport-rubl       buf_temp-stk-supp-tot.other-base     = buf_stk-supp-tot.other-base           buf_temp-stk-supp-tot.other-rubl     = buf_stk-supp-tot.other-rubl
          .
        end.
      end.
      if v-shift-on
      then do:
        assign
          v-prsh-stk-supp-tot-fact-order = 0
        .
        find last buf_stk-supp-tot no-lock
          where buf_stk-supp-tot.obj-type   = buf_trn-doc.obj-type
            and buf_stk-supp-tot.obj-code   = buf_trn-doc.obj-code
            and buf_stk-supp-tot.cli-type   = p-cli-type
            and buf_stk-supp-tot.cli-code   = p-cli-code
            and buf_stk-supp-tot.sum-type   = v-root-sum-type[v-root-sum-type-ind-ext]
            and buf_stk-supp-tot.cat-id     = '##':U
            and buf_stk-supp-tot.fact-order <= v-shift-stk-supp-tot-fact-order
            and buf_stk-supp-tot.shift-date <> ?
          use-index category
          no-error .
        if available buf_stk-supp-tot
        then do:
          assign
            v-prsh-stk-supp-tot-fact-order = buf_stk-supp-tot.fact-order
          .
        end.
        if v-prsh-stk-supp-tot-fact-order > 0
        then do:
          for each buf_stk-supp-tot no-lock
            where buf_stk-supp-tot.obj-type   = buf_trn-doc.obj-type
              and buf_stk-supp-tot.obj-code   = buf_trn-doc.obj-code
              and buf_stk-supp-tot.cli-type   = p-cli-type
              and buf_stk-supp-tot.cli-code   = p-cli-code
              and buf_stk-supp-tot.fact-order = v-prsh-stk-supp-tot-fact-order
              and buf_stk-supp-tot.sum-type   begins v-root-sum-type[v-root-sum-type-ind-ext]
          on error undo, return error
          :
            create buf_temp-shift-stk-supp-tot .
                                    assign
              buf_temp-shift-stk-supp-tot.obj-type     = buf_stk-supp-tot.obj-type     buf_temp-shift-stk-supp-tot.obj-code     = buf_stk-supp-tot.obj-code     buf_temp-shift-stk-supp-tot.cli-type     = buf_stk-supp-tot.cli-type     buf_temp-shift-stk-supp-tot.cli-code     = buf_stk-supp-tot.cli-code     buf_temp-shift-stk-supp-tot.fact-order   = buf_stk-supp-tot.fact-order   buf_temp-shift-stk-supp-tot.sum-type     = buf_stk-supp-tot.sum-type     buf_temp-shift-stk-supp-tot.cat-id       = buf_stk-supp-tot.cat-id       buf_temp-shift-stk-supp-tot.fact-date    = buf_stk-supp-tot.fact-date    buf_temp-shift-stk-supp-tot.shift-num    = buf_stk-supp-tot.shift-num    buf_temp-shift-stk-supp-tot.shift-date   = buf_stk-supp-tot.shift-date
            .
            if v-shift-stk-supp-tot-fact-order = v-prsh-stk-supp-tot-fact-order
            then do:
              assign
                                                                                                                buf_temp-shift-stk-supp-tot.fact-qnty      = buf_stk-supp-tot.fact-qnty            buf_temp-shift-stk-supp-tot.sum-base       = buf_stk-supp-tot.sum-base             buf_temp-shift-stk-supp-tot.sum-rubl       = buf_stk-supp-tot.sum-rubl             buf_temp-shift-stk-supp-tot.vat-base       = buf_stk-supp-tot.vat-base             buf_temp-shift-stk-supp-tot.vat-rubl       = buf_stk-supp-tot.vat-rubl             buf_temp-shift-stk-supp-tot.slt-base       = buf_stk-supp-tot.slt-base             buf_temp-shift-stk-supp-tot.slt-rubl       = buf_stk-supp-tot.slt-rubl             buf_temp-shift-stk-supp-tot.road-tax-base  = buf_stk-supp-tot.road-tax-base        buf_temp-shift-stk-supp-tot.road-tax-rubl  = buf_stk-supp-tot.road-tax-rubl        buf_temp-shift-stk-supp-tot.excise-base    = buf_stk-supp-tot.excise-base          buf_temp-shift-stk-supp-tot.excise-rubl    = buf_stk-supp-tot.excise-rubl          buf_temp-shift-stk-supp-tot.transport-base = buf_stk-supp-tot.transport-base       buf_temp-shift-stk-supp-tot.transport-rubl = buf_stk-supp-tot.transport-rubl       buf_temp-shift-stk-supp-tot.other-base     = buf_stk-supp-tot.other-base           buf_temp-shift-stk-supp-tot.other-rubl     = buf_stk-supp-tot.other-rubl
              .
            end.
            assign
              buf_temp-shift-stk-supp-tot.fact-order = v-shift-stk-supp-tot-fact-order
              buf_temp-shift-stk-supp-tot.fact-date  = buf_trn-doc.fact-date
              buf_temp-shift-stk-supp-tot.shift-date = buf_trn-doc.shift-date
              buf_temp-shift-stk-supp-tot.shift-num  = buf_trn-doc.shift-num
            .
            assign
                                                                                                  buf_temp-shift-stk-supp-tot.new-fact-qnty      = buf_stk-supp-tot.fact-qnty            buf_temp-shift-stk-supp-tot.new-sum-base       = buf_stk-supp-tot.sum-base             buf_temp-shift-stk-supp-tot.new-sum-rubl       = buf_stk-supp-tot.sum-rubl             buf_temp-shift-stk-supp-tot.new-vat-base       = buf_stk-supp-tot.vat-base             buf_temp-shift-stk-supp-tot.new-vat-rubl       = buf_stk-supp-tot.vat-rubl             buf_temp-shift-stk-supp-tot.new-slt-base       = buf_stk-supp-tot.slt-base             buf_temp-shift-stk-supp-tot.new-slt-rubl       = buf_stk-supp-tot.slt-rubl             buf_temp-shift-stk-supp-tot.new-road-tax-base  = buf_stk-supp-tot.road-tax-base        buf_temp-shift-stk-supp-tot.new-road-tax-rubl  = buf_stk-supp-tot.road-tax-rubl        buf_temp-shift-stk-supp-tot.new-excise-base    = buf_stk-supp-tot.excise-base          buf_temp-shift-stk-supp-tot.new-excise-rubl    = buf_stk-supp-tot.excise-rubl          buf_temp-shift-stk-supp-tot.new-transport-base = buf_stk-supp-tot.transport-base       buf_temp-shift-stk-supp-tot.new-transport-rubl = buf_stk-supp-tot.transport-rubl       buf_temp-shift-stk-supp-tot.new-other-base     = buf_stk-supp-tot.other-base           buf_temp-shift-stk-supp-tot.new-other-rubl     = buf_stk-supp-tot.other-rubl
            .
          end.
        end.
        else do:
          create buf_temp-shift-stk-supp-tot.
          assign
            buf_temp-shift-stk-supp-tot.obj-type   = buf_trn-doc.obj-type
            buf_temp-shift-stk-supp-tot.obj-code   = buf_trn-doc.obj-code
            buf_temp-shift-stk-supp-tot.cli-type   = p-cli-type
            buf_temp-shift-stk-supp-tot.cli-code   = p-cli-code
            buf_temp-shift-stk-supp-tot.fact-order = v-shift-stk-supp-tot-fact-order
            buf_temp-shift-stk-supp-tot.sum-type   = v-root-sum-type[v-root-sum-type-ind-ext]
            buf_temp-shift-stk-supp-tot.cat-id     = '##':U
            buf_temp-shift-stk-supp-tot.fact-date  = buf_trn-doc.fact-date
            buf_temp-shift-stk-supp-tot.shift-date = buf_trn-doc.shift-date
            buf_temp-shift-stk-supp-tot.shift-num  = buf_trn-doc.shift-num
          .
        end.
        for each buf_stk-supp-tot no-lock
          where buf_stk-supp-tot.obj-type   = buf_trn-doc.obj-type
            and buf_stk-supp-tot.obj-code   = buf_trn-doc.obj-code
            and buf_stk-supp-tot.cli-type   = p-cli-type
            and buf_stk-supp-tot.cli-code   = p-cli-code
            and buf_stk-supp-tot.fact-order > v-shift-stk-supp-tot-fact-order
            and buf_stk-supp-tot.fact-order <= v-shift-cut-fact-order
        on error undo, return error
        :
          if buf_stk-supp-tot.sum-type   begins v-root-sum-type[v-root-sum-type-ind-ext]
          and buf_stk-supp-tot.shift-date <> ?
          then do:
            create buf_temp-shift-stk-supp-tot .
                                    assign
              buf_temp-shift-stk-supp-tot.obj-type     = buf_stk-supp-tot.obj-type     buf_temp-shift-stk-supp-tot.obj-code     = buf_stk-supp-tot.obj-code     buf_temp-shift-stk-supp-tot.cli-type     = buf_stk-supp-tot.cli-type     buf_temp-shift-stk-supp-tot.cli-code     = buf_stk-supp-tot.cli-code     buf_temp-shift-stk-supp-tot.fact-order   = buf_stk-supp-tot.fact-order   buf_temp-shift-stk-supp-tot.sum-type     = buf_stk-supp-tot.sum-type     buf_temp-shift-stk-supp-tot.cat-id       = buf_stk-supp-tot.cat-id       buf_temp-shift-stk-supp-tot.fact-date    = buf_stk-supp-tot.fact-date    buf_temp-shift-stk-supp-tot.shift-num    = buf_stk-supp-tot.shift-num    buf_temp-shift-stk-supp-tot.shift-date   = buf_stk-supp-tot.shift-date
            .
            assign
                                                                                                  buf_temp-shift-stk-supp-tot.new-fact-qnty      = buf_stk-supp-tot.fact-qnty            buf_temp-shift-stk-supp-tot.new-sum-base       = buf_stk-supp-tot.sum-base             buf_temp-shift-stk-supp-tot.new-sum-rubl       = buf_stk-supp-tot.sum-rubl             buf_temp-shift-stk-supp-tot.new-vat-base       = buf_stk-supp-tot.vat-base             buf_temp-shift-stk-supp-tot.new-vat-rubl       = buf_stk-supp-tot.vat-rubl             buf_temp-shift-stk-supp-tot.new-slt-base       = buf_stk-supp-tot.slt-base             buf_temp-shift-stk-supp-tot.new-slt-rubl       = buf_stk-supp-tot.slt-rubl             buf_temp-shift-stk-supp-tot.new-road-tax-base  = buf_stk-supp-tot.road-tax-base        buf_temp-shift-stk-supp-tot.new-road-tax-rubl  = buf_stk-supp-tot.road-tax-rubl        buf_temp-shift-stk-supp-tot.new-excise-base    = buf_stk-supp-tot.excise-base          buf_temp-shift-stk-supp-tot.new-excise-rubl    = buf_stk-supp-tot.excise-rubl          buf_temp-shift-stk-supp-tot.new-transport-base = buf_stk-supp-tot.transport-base       buf_temp-shift-stk-supp-tot.new-transport-rubl = buf_stk-supp-tot.transport-rubl       buf_temp-shift-stk-supp-tot.new-other-base     = buf_stk-supp-tot.other-base           buf_temp-shift-stk-supp-tot.new-other-rubl     = buf_stk-supp-tot.other-rubl
                                                                                                  buf_temp-shift-stk-supp-tot.fact-qnty      = buf_stk-supp-tot.fact-qnty            buf_temp-shift-stk-supp-tot.sum-base       = buf_stk-supp-tot.sum-base             buf_temp-shift-stk-supp-tot.sum-rubl       = buf_stk-supp-tot.sum-rubl             buf_temp-shift-stk-supp-tot.vat-base       = buf_stk-supp-tot.vat-base             buf_temp-shift-stk-supp-tot.vat-rubl       = buf_stk-supp-tot.vat-rubl             buf_temp-shift-stk-supp-tot.slt-base       = buf_stk-supp-tot.slt-base             buf_temp-shift-stk-supp-tot.slt-rubl       = buf_stk-supp-tot.slt-rubl             buf_temp-shift-stk-supp-tot.road-tax-base  = buf_stk-supp-tot.road-tax-base        buf_temp-shift-stk-supp-tot.road-tax-rubl  = buf_stk-supp-tot.road-tax-rubl        buf_temp-shift-stk-supp-tot.excise-base    = buf_stk-supp-tot.excise-base          buf_temp-shift-stk-supp-tot.excise-rubl    = buf_stk-supp-tot.excise-rubl          buf_temp-shift-stk-supp-tot.transport-base = buf_stk-supp-tot.transport-base       buf_temp-shift-stk-supp-tot.transport-rubl = buf_stk-supp-tot.transport-rubl       buf_temp-shift-stk-supp-tot.other-base     = buf_stk-supp-tot.other-base           buf_temp-shift-stk-supp-tot.other-rubl     = buf_stk-supp-tot.other-rubl
            .
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure init-stk-supp-line-table :
  define input parameter p-cli-type  as character no-undo .
  define input parameter p-cli-code  as integer   no-undo .
  define input parameter p-artic     as character no-undo .
  define input parameter p-prod-type as character no-undo .
  define input parameter p-prod-code as integer   no-undo .
  define buffer buf_temp-stk-supp-line for temp-stk-supp-line .
  define buffer buf_temp-init-stk-supp-line for temp-init-stk-supp-line .
  define buffer buf_stk-supp-line for ub.stk-supp-line .
  define buffer buf_temp-shift-stk-supp-line for temp-shift-stk-supp-line .
  do
  on error undo, return error
  :
    find first buf_temp-init-stk-supp-line
      where buf_temp-init-stk-supp-line.cli-type  = p-cli-type
        and buf_temp-init-stk-supp-line.cli-code  = p-cli-code
        and buf_temp-init-stk-supp-line.artic     = p-artic
        and buf_temp-init-stk-supp-line.prod-type = p-prod-type
        and buf_temp-init-stk-supp-line.prod-code = p-prod-code
      no-error .
    if not available buf_temp-init-stk-supp-line
    then do:
      create buf_temp-init-stk-supp-line .
      assign
        buf_temp-init-stk-supp-line.cli-type = p-cli-type
        buf_temp-init-stk-supp-line.cli-code = p-cli-code
        buf_temp-init-stk-supp-line.artic     = p-artic
        buf_temp-init-stk-supp-line.prod-type = p-prod-type
        buf_temp-init-stk-supp-line.prod-code = p-prod-code
      .
    end.
    else do:
      return .
    end.
    define variable v-root-sum-type                  as character no-undo extent 3 .
    define variable v-line-sum-type                  as character no-undo extent 3 .
    define variable v-root-sum-type-ind-ext          as integer   no-undo .
    define variable v-prev-stk-supp-line-fact-order  as decimal   no-undo .
    define variable v-prsh-stk-supp-line-fact-order  as decimal   no-undo .
    assign
      v-root-sum-type[1] = 'cost':U
      v-root-sum-type[2] = 'csdt':U         + buf_trn-doc.ext-doc-type
      v-root-sum-type[3] = 'sadt':U         + buf_trn-doc.ext-doc-type
    .
    do v-root-sum-type-ind-ext = 1 to extent(v-root-sum-type)
    :
      find last buf_stk-supp-line no-lock
        where buf_stk-supp-line.obj-type   = buf_trn-doc.obj-type
          and buf_stk-supp-line.obj-code   = buf_trn-doc.obj-code
          and buf_stk-supp-line.cli-type   = p-cli-type
          and buf_stk-supp-line.cli-code   = p-cli-code
          and buf_stk-supp-line.artic      = p-artic
          and buf_stk-supp-line.prod-type  = p-prod-type
          and buf_stk-supp-line.prod-code  = p-prod-code
          and buf_stk-supp-line.sum-type   = v-root-sum-type[v-root-sum-type-ind-ext]
          and buf_stk-supp-line.cat-id     = '##':U
          and buf_stk-supp-line.fact-order <= v-stk-supp-line-fact-order
          and buf_stk-supp-line.shift-date = ?
        use-index category
        no-error .
      if available buf_stk-supp-line
      then do:
        assign
          v-prev-stk-supp-line-fact-order = buf_stk-supp-line.fact-order
        .
        for each buf_stk-supp-line no-lock
          where buf_stk-supp-line.obj-type   = buf_trn-doc.obj-type
            and buf_stk-supp-line.obj-code   = buf_trn-doc.obj-code
            and buf_stk-supp-line.cli-type   = p-cli-type
            and buf_stk-supp-line.cli-code   = p-cli-code
            and buf_stk-supp-line.artic      = p-artic
            and buf_stk-supp-line.prod-type  = p-prod-type
            and buf_stk-supp-line.prod-code  = p-prod-code
            and buf_stk-supp-line.fact-order = v-prev-stk-supp-line-fact-order
            and buf_stk-supp-line.sum-type   begins v-root-sum-type[v-root-sum-type-ind-ext]
        on error undo, return error
        :
          create buf_temp-stk-supp-line .
                              assign
            buf_temp-stk-supp-line.obj-type     = buf_stk-supp-line.obj-type     buf_temp-stk-supp-line.obj-code     = buf_stk-supp-line.obj-code     buf_temp-stk-supp-line.cli-type     = buf_stk-supp-line.cli-type     buf_temp-stk-supp-line.cli-code     = buf_stk-supp-line.cli-code     buf_temp-stk-supp-line.artic        = buf_stk-supp-line.artic        buf_temp-stk-supp-line.prod-type    = buf_stk-supp-line.prod-type    buf_temp-stk-supp-line.prod-code    = buf_stk-supp-line.prod-code    buf_temp-stk-supp-line.fact-order   = buf_stk-supp-line.fact-order   buf_temp-stk-supp-line.sum-type     = buf_stk-supp-line.sum-type     buf_temp-stk-supp-line.cat-id       = buf_stk-supp-line.cat-id       buf_temp-stk-supp-line.fact-date    = buf_stk-supp-line.fact-date    buf_temp-stk-supp-line.shift-num    = buf_stk-supp-line.shift-num    buf_temp-stk-supp-line.shift-date   = buf_stk-supp-line.shift-date
          .
          if v-stk-supp-line-fact-order = v-prev-stk-supp-line-fact-order
          then do:
            assign
                                                                                                  buf_temp-stk-supp-line.fact-qnty      = buf_stk-supp-line.fact-qnty            buf_temp-stk-supp-line.sum-base       = buf_stk-supp-line.sum-base             buf_temp-stk-supp-line.sum-rubl       = buf_stk-supp-line.sum-rubl             buf_temp-stk-supp-line.vat-base       = buf_stk-supp-line.vat-base             buf_temp-stk-supp-line.vat-rubl       = buf_stk-supp-line.vat-rubl             buf_temp-stk-supp-line.slt-base       = buf_stk-supp-line.slt-base             buf_temp-stk-supp-line.slt-rubl       = buf_stk-supp-line.slt-rubl             buf_temp-stk-supp-line.road-tax-base  = buf_stk-supp-line.road-tax-base        buf_temp-stk-supp-line.road-tax-rubl  = buf_stk-supp-line.road-tax-rubl        buf_temp-stk-supp-line.excise-base    = buf_stk-supp-line.excise-base          buf_temp-stk-supp-line.excise-rubl    = buf_stk-supp-line.excise-rubl          buf_temp-stk-supp-line.transport-base = buf_stk-supp-line.transport-base       buf_temp-stk-supp-line.transport-rubl = buf_stk-supp-line.transport-rubl       buf_temp-stk-supp-line.other-base     = buf_stk-supp-line.other-base           buf_temp-stk-supp-line.other-rubl     = buf_stk-supp-line.other-rubl
            .
          end.
          assign
            buf_temp-stk-supp-line.fact-order = v-stk-supp-line-fact-order
            buf_temp-stk-supp-line.fact-date  = buf_trn-doc.fact-date
            buf_temp-stk-supp-line.shift-num  = 0
            buf_temp-stk-supp-line.shift-date = ?
          .
          assign
                                                                                    buf_temp-stk-supp-line.new-fact-qnty      = buf_stk-supp-line.fact-qnty            buf_temp-stk-supp-line.new-sum-base       = buf_stk-supp-line.sum-base             buf_temp-stk-supp-line.new-sum-rubl       = buf_stk-supp-line.sum-rubl             buf_temp-stk-supp-line.new-vat-base       = buf_stk-supp-line.vat-base             buf_temp-stk-supp-line.new-vat-rubl       = buf_stk-supp-line.vat-rubl             buf_temp-stk-supp-line.new-slt-base       = buf_stk-supp-line.slt-base             buf_temp-stk-supp-line.new-slt-rubl       = buf_stk-supp-line.slt-rubl             buf_temp-stk-supp-line.new-road-tax-base  = buf_stk-supp-line.road-tax-base        buf_temp-stk-supp-line.new-road-tax-rubl  = buf_stk-supp-line.road-tax-rubl        buf_temp-stk-supp-line.new-excise-base    = buf_stk-supp-line.excise-base          buf_temp-stk-supp-line.new-excise-rubl    = buf_stk-supp-line.excise-rubl          buf_temp-stk-supp-line.new-transport-base = buf_stk-supp-line.transport-base       buf_temp-stk-supp-line.new-transport-rubl = buf_stk-supp-line.transport-rubl       buf_temp-stk-supp-line.new-other-base     = buf_stk-supp-line.other-base           buf_temp-stk-supp-line.new-other-rubl     = buf_stk-supp-line.other-rubl
          .
        end.
      end.
      else do:
        create buf_temp-stk-supp-line.
        assign
          buf_temp-stk-supp-line.obj-type   = buf_trn-doc.obj-type
          buf_temp-stk-supp-line.obj-code   = buf_trn-doc.obj-code
          buf_temp-stk-supp-line.cli-type   = p-cli-type
          buf_temp-stk-supp-line.cli-code   = p-cli-code
          buf_temp-stk-supp-line.artic      = p-artic
          buf_temp-stk-supp-line.prod-type  = p-prod-type
          buf_temp-stk-supp-line.prod-code  = p-prod-code
          buf_temp-stk-supp-line.fact-order = v-stk-supp-line-fact-order
          buf_temp-stk-supp-line.sum-type   = v-root-sum-type[v-root-sum-type-ind-ext]
          buf_temp-stk-supp-line.cat-id     = '##':U
          buf_temp-stk-supp-line.fact-date  = buf_trn-doc.fact-date
          buf_temp-stk-supp-line.shift-num  = 0
          buf_temp-stk-supp-line.shift-date = ?
        .
      end.
      for each buf_stk-supp-line no-lock
        where buf_stk-supp-line.obj-type   = buf_trn-doc.obj-type
          and buf_stk-supp-line.obj-code   = buf_trn-doc.obj-code
          and buf_stk-supp-line.cli-type   = p-cli-type
          and buf_stk-supp-line.cli-code   = p-cli-code
          and buf_stk-supp-line.artic      = p-artic
          and buf_stk-supp-line.prod-type  = p-prod-type
          and buf_stk-supp-line.prod-code  = p-prod-code
          and buf_stk-supp-line.fact-order > v-stk-supp-line-fact-order
          and buf_stk-supp-line.fact-order <= v-day-cut-fact-order
      on error undo, return error
      :
        if buf_stk-supp-line.sum-type   begins v-root-sum-type[v-root-sum-type-ind-ext]
        and buf_stk-supp-line.shift-date = ?
        then do:
          create buf_temp-stk-supp-line .
                              assign
            buf_temp-stk-supp-line.obj-type     = buf_stk-supp-line.obj-type     buf_temp-stk-supp-line.obj-code     = buf_stk-supp-line.obj-code     buf_temp-stk-supp-line.cli-type     = buf_stk-supp-line.cli-type     buf_temp-stk-supp-line.cli-code     = buf_stk-supp-line.cli-code     buf_temp-stk-supp-line.artic        = buf_stk-supp-line.artic        buf_temp-stk-supp-line.prod-type    = buf_stk-supp-line.prod-type    buf_temp-stk-supp-line.prod-code    = buf_stk-supp-line.prod-code    buf_temp-stk-supp-line.fact-order   = buf_stk-supp-line.fact-order   buf_temp-stk-supp-line.sum-type     = buf_stk-supp-line.sum-type     buf_temp-stk-supp-line.cat-id       = buf_stk-supp-line.cat-id       buf_temp-stk-supp-line.fact-date    = buf_stk-supp-line.fact-date    buf_temp-stk-supp-line.shift-num    = buf_stk-supp-line.shift-num    buf_temp-stk-supp-line.shift-date   = buf_stk-supp-line.shift-date
          .
          assign
                                                                                    buf_temp-stk-supp-line.new-fact-qnty      = buf_stk-supp-line.fact-qnty            buf_temp-stk-supp-line.new-sum-base       = buf_stk-supp-line.sum-base             buf_temp-stk-supp-line.new-sum-rubl       = buf_stk-supp-line.sum-rubl             buf_temp-stk-supp-line.new-vat-base       = buf_stk-supp-line.vat-base             buf_temp-stk-supp-line.new-vat-rubl       = buf_stk-supp-line.vat-rubl             buf_temp-stk-supp-line.new-slt-base       = buf_stk-supp-line.slt-base             buf_temp-stk-supp-line.new-slt-rubl       = buf_stk-supp-line.slt-rubl             buf_temp-stk-supp-line.new-road-tax-base  = buf_stk-supp-line.road-tax-base        buf_temp-stk-supp-line.new-road-tax-rubl  = buf_stk-supp-line.road-tax-rubl        buf_temp-stk-supp-line.new-excise-base    = buf_stk-supp-line.excise-base          buf_temp-stk-supp-line.new-excise-rubl    = buf_stk-supp-line.excise-rubl          buf_temp-stk-supp-line.new-transport-base = buf_stk-supp-line.transport-base       buf_temp-stk-supp-line.new-transport-rubl = buf_stk-supp-line.transport-rubl       buf_temp-stk-supp-line.new-other-base     = buf_stk-supp-line.other-base           buf_temp-stk-supp-line.new-other-rubl     = buf_stk-supp-line.other-rubl
                                                                                    buf_temp-stk-supp-line.fact-qnty      = buf_stk-supp-line.fact-qnty            buf_temp-stk-supp-line.sum-base       = buf_stk-supp-line.sum-base             buf_temp-stk-supp-line.sum-rubl       = buf_stk-supp-line.sum-rubl             buf_temp-stk-supp-line.vat-base       = buf_stk-supp-line.vat-base             buf_temp-stk-supp-line.vat-rubl       = buf_stk-supp-line.vat-rubl             buf_temp-stk-supp-line.slt-base       = buf_stk-supp-line.slt-base             buf_temp-stk-supp-line.slt-rubl       = buf_stk-supp-line.slt-rubl             buf_temp-stk-supp-line.road-tax-base  = buf_stk-supp-line.road-tax-base        buf_temp-stk-supp-line.road-tax-rubl  = buf_stk-supp-line.road-tax-rubl        buf_temp-stk-supp-line.excise-base    = buf_stk-supp-line.excise-base          buf_temp-stk-supp-line.excise-rubl    = buf_stk-supp-line.excise-rubl          buf_temp-stk-supp-line.transport-base = buf_stk-supp-line.transport-base       buf_temp-stk-supp-line.transport-rubl = buf_stk-supp-line.transport-rubl       buf_temp-stk-supp-line.other-base     = buf_stk-supp-line.other-base           buf_temp-stk-supp-line.other-rubl     = buf_stk-supp-line.other-rubl
          .
        end.
      end.
      if v-shift-on
      then do:
        assign
          v-prsh-stk-supp-line-fact-order = 0
        .
        find last buf_stk-supp-line no-lock
          where buf_stk-supp-line.obj-type   = buf_trn-doc.obj-type
            and buf_stk-supp-line.obj-code   = buf_trn-doc.obj-code
            and buf_stk-supp-line.cli-type   = p-cli-type
            and buf_stk-supp-line.cli-code   = p-cli-code
            and buf_stk-supp-line.artic      = p-artic
            and buf_stk-supp-line.prod-type  = p-prod-type
            and buf_stk-supp-line.prod-code  = p-prod-code
            and buf_stk-supp-line.sum-type   = v-root-sum-type[v-root-sum-type-ind-ext]
            and buf_stk-supp-line.cat-id     = '##':U
            and buf_stk-supp-line.fact-order <= v-shift-stk-supp-line-fact-order
            and buf_stk-supp-line.shift-date <> ?
          use-index category
          no-error .
        if available buf_stk-supp-line
        then do:
          assign
            v-prsh-stk-supp-line-fact-order = buf_stk-supp-line.fact-order
          .
        end.
        if v-prsh-stk-supp-line-fact-order > 0
        then do:
          for each buf_stk-supp-line no-lock
            where buf_stk-supp-line.obj-type   = buf_trn-doc.obj-type
              and buf_stk-supp-line.obj-code   = buf_trn-doc.obj-code
              and buf_stk-supp-line.cli-type   = p-cli-type
              and buf_stk-supp-line.cli-code   = p-cli-code
              and buf_stk-supp-line.artic      = p-artic
              and buf_stk-supp-line.prod-type  = p-prod-type
              and buf_stk-supp-line.prod-code  = p-prod-code
              and buf_stk-supp-line.fact-order = v-prsh-stk-supp-line-fact-order
              and buf_stk-supp-line.sum-type   begins v-root-sum-type[v-root-sum-type-ind-ext]
          on error undo, return error
          :
            create buf_temp-shift-stk-supp-line .
                                    assign
              buf_temp-shift-stk-supp-line.obj-type     = buf_stk-supp-line.obj-type     buf_temp-shift-stk-supp-line.obj-code     = buf_stk-supp-line.obj-code     buf_temp-shift-stk-supp-line.cli-type     = buf_stk-supp-line.cli-type     buf_temp-shift-stk-supp-line.cli-code     = buf_stk-supp-line.cli-code     buf_temp-shift-stk-supp-line.artic        = buf_stk-supp-line.artic        buf_temp-shift-stk-supp-line.prod-type    = buf_stk-supp-line.prod-type    buf_temp-shift-stk-supp-line.prod-code    = buf_stk-supp-line.prod-code    buf_temp-shift-stk-supp-line.fact-order   = buf_stk-supp-line.fact-order   buf_temp-shift-stk-supp-line.sum-type     = buf_stk-supp-line.sum-type     buf_temp-shift-stk-supp-line.cat-id       = buf_stk-supp-line.cat-id       buf_temp-shift-stk-supp-line.fact-date    = buf_stk-supp-line.fact-date    buf_temp-shift-stk-supp-line.shift-num    = buf_stk-supp-line.shift-num    buf_temp-shift-stk-supp-line.shift-date   = buf_stk-supp-line.shift-date
            .
            if v-shift-stk-supp-line-fact-order = v-prsh-stk-supp-line-fact-order
            then do:
              assign
                                                                                                                buf_temp-shift-stk-supp-line.fact-qnty      = buf_stk-supp-line.fact-qnty            buf_temp-shift-stk-supp-line.sum-base       = buf_stk-supp-line.sum-base             buf_temp-shift-stk-supp-line.sum-rubl       = buf_stk-supp-line.sum-rubl             buf_temp-shift-stk-supp-line.vat-base       = buf_stk-supp-line.vat-base             buf_temp-shift-stk-supp-line.vat-rubl       = buf_stk-supp-line.vat-rubl             buf_temp-shift-stk-supp-line.slt-base       = buf_stk-supp-line.slt-base             buf_temp-shift-stk-supp-line.slt-rubl       = buf_stk-supp-line.slt-rubl             buf_temp-shift-stk-supp-line.road-tax-base  = buf_stk-supp-line.road-tax-base        buf_temp-shift-stk-supp-line.road-tax-rubl  = buf_stk-supp-line.road-tax-rubl        buf_temp-shift-stk-supp-line.excise-base    = buf_stk-supp-line.excise-base          buf_temp-shift-stk-supp-line.excise-rubl    = buf_stk-supp-line.excise-rubl          buf_temp-shift-stk-supp-line.transport-base = buf_stk-supp-line.transport-base       buf_temp-shift-stk-supp-line.transport-rubl = buf_stk-supp-line.transport-rubl       buf_temp-shift-stk-supp-line.other-base     = buf_stk-supp-line.other-base           buf_temp-shift-stk-supp-line.other-rubl     = buf_stk-supp-line.other-rubl
              .
            end.
            assign
              buf_temp-shift-stk-supp-line.fact-order = v-shift-stk-supp-line-fact-order
              buf_temp-shift-stk-supp-line.fact-date  = buf_trn-doc.fact-date
              buf_temp-shift-stk-supp-line.shift-date = buf_trn-doc.shift-date
              buf_temp-shift-stk-supp-line.shift-num  = buf_trn-doc.shift-num
            .
            assign
                                                                                                  buf_temp-shift-stk-supp-line.new-fact-qnty      = buf_stk-supp-line.fact-qnty            buf_temp-shift-stk-supp-line.new-sum-base       = buf_stk-supp-line.sum-base             buf_temp-shift-stk-supp-line.new-sum-rubl       = buf_stk-supp-line.sum-rubl             buf_temp-shift-stk-supp-line.new-vat-base       = buf_stk-supp-line.vat-base             buf_temp-shift-stk-supp-line.new-vat-rubl       = buf_stk-supp-line.vat-rubl             buf_temp-shift-stk-supp-line.new-slt-base       = buf_stk-supp-line.slt-base             buf_temp-shift-stk-supp-line.new-slt-rubl       = buf_stk-supp-line.slt-rubl             buf_temp-shift-stk-supp-line.new-road-tax-base  = buf_stk-supp-line.road-tax-base        buf_temp-shift-stk-supp-line.new-road-tax-rubl  = buf_stk-supp-line.road-tax-rubl        buf_temp-shift-stk-supp-line.new-excise-base    = buf_stk-supp-line.excise-base          buf_temp-shift-stk-supp-line.new-excise-rubl    = buf_stk-supp-line.excise-rubl          buf_temp-shift-stk-supp-line.new-transport-base = buf_stk-supp-line.transport-base       buf_temp-shift-stk-supp-line.new-transport-rubl = buf_stk-supp-line.transport-rubl       buf_temp-shift-stk-supp-line.new-other-base     = buf_stk-supp-line.other-base           buf_temp-shift-stk-supp-line.new-other-rubl     = buf_stk-supp-line.other-rubl
            .
          end.
        end.
        else do:
          create buf_temp-shift-stk-supp-line.
          assign
            buf_temp-shift-stk-supp-line.obj-type   = buf_trn-doc.obj-type
            buf_temp-shift-stk-supp-line.obj-code   = buf_trn-doc.obj-code
            buf_temp-shift-stk-supp-line.cli-type   = p-cli-type
            buf_temp-shift-stk-supp-line.cli-code   = p-cli-code
            buf_temp-shift-stk-supp-line.artic      = p-artic
            buf_temp-shift-stk-supp-line.prod-type  = p-prod-type
            buf_temp-shift-stk-supp-line.prod-code  = p-prod-code
            buf_temp-shift-stk-supp-line.fact-order = v-shift-stk-supp-line-fact-order
            buf_temp-shift-stk-supp-line.sum-type   = v-root-sum-type[v-root-sum-type-ind-ext]
            buf_temp-shift-stk-supp-line.cat-id     = '##':U
            buf_temp-shift-stk-supp-line.fact-date  = buf_trn-doc.fact-date
            buf_temp-shift-stk-supp-line.shift-date = buf_trn-doc.shift-date
            buf_temp-shift-stk-supp-line.shift-num  = buf_trn-doc.shift-num
          .
        end.
        for each buf_stk-supp-line no-lock
          where buf_stk-supp-line.obj-type   = buf_trn-doc.obj-type
            and buf_stk-supp-line.obj-code   = buf_trn-doc.obj-code
            and buf_stk-supp-line.cli-type   = p-cli-type
            and buf_stk-supp-line.cli-code   = p-cli-code
            and buf_stk-supp-line.artic      = p-artic
            and buf_stk-supp-line.prod-type  = p-prod-type
            and buf_stk-supp-line.prod-code  = p-prod-code
            and buf_stk-supp-line.fact-order > v-shift-stk-supp-line-fact-order
            and buf_stk-supp-line.fact-order <= v-shift-cut-fact-order
        on error undo, return error
        :
          if buf_stk-supp-line.sum-type   begins v-root-sum-type[v-root-sum-type-ind-ext]
          and buf_stk-supp-line.shift-date <> ?
          then do:
            create buf_temp-shift-stk-supp-line .
                                    assign
              buf_temp-shift-stk-supp-line.obj-type     = buf_stk-supp-line.obj-type     buf_temp-shift-stk-supp-line.obj-code     = buf_stk-supp-line.obj-code     buf_temp-shift-stk-supp-line.cli-type     = buf_stk-supp-line.cli-type     buf_temp-shift-stk-supp-line.cli-code     = buf_stk-supp-line.cli-code     buf_temp-shift-stk-supp-line.artic        = buf_stk-supp-line.artic        buf_temp-shift-stk-supp-line.prod-type    = buf_stk-supp-line.prod-type    buf_temp-shift-stk-supp-line.prod-code    = buf_stk-supp-line.prod-code    buf_temp-shift-stk-supp-line.fact-order   = buf_stk-supp-line.fact-order   buf_temp-shift-stk-supp-line.sum-type     = buf_stk-supp-line.sum-type     buf_temp-shift-stk-supp-line.cat-id       = buf_stk-supp-line.cat-id       buf_temp-shift-stk-supp-line.fact-date    = buf_stk-supp-line.fact-date    buf_temp-shift-stk-supp-line.shift-num    = buf_stk-supp-line.shift-num    buf_temp-shift-stk-supp-line.shift-date   = buf_stk-supp-line.shift-date
            .
            assign
                                                                                                  buf_temp-shift-stk-supp-line.new-fact-qnty      = buf_stk-supp-line.fact-qnty            buf_temp-shift-stk-supp-line.new-sum-base       = buf_stk-supp-line.sum-base             buf_temp-shift-stk-supp-line.new-sum-rubl       = buf_stk-supp-line.sum-rubl             buf_temp-shift-stk-supp-line.new-vat-base       = buf_stk-supp-line.vat-base             buf_temp-shift-stk-supp-line.new-vat-rubl       = buf_stk-supp-line.vat-rubl             buf_temp-shift-stk-supp-line.new-slt-base       = buf_stk-supp-line.slt-base             buf_temp-shift-stk-supp-line.new-slt-rubl       = buf_stk-supp-line.slt-rubl             buf_temp-shift-stk-supp-line.new-road-tax-base  = buf_stk-supp-line.road-tax-base        buf_temp-shift-stk-supp-line.new-road-tax-rubl  = buf_stk-supp-line.road-tax-rubl        buf_temp-shift-stk-supp-line.new-excise-base    = buf_stk-supp-line.excise-base          buf_temp-shift-stk-supp-line.new-excise-rubl    = buf_stk-supp-line.excise-rubl          buf_temp-shift-stk-supp-line.new-transport-base = buf_stk-supp-line.transport-base       buf_temp-shift-stk-supp-line.new-transport-rubl = buf_stk-supp-line.transport-rubl       buf_temp-shift-stk-supp-line.new-other-base     = buf_stk-supp-line.other-base           buf_temp-shift-stk-supp-line.new-other-rubl     = buf_stk-supp-line.other-rubl
                                                                                                  buf_temp-shift-stk-supp-line.fact-qnty      = buf_stk-supp-line.fact-qnty            buf_temp-shift-stk-supp-line.sum-base       = buf_stk-supp-line.sum-base             buf_temp-shift-stk-supp-line.sum-rubl       = buf_stk-supp-line.sum-rubl             buf_temp-shift-stk-supp-line.vat-base       = buf_stk-supp-line.vat-base             buf_temp-shift-stk-supp-line.vat-rubl       = buf_stk-supp-line.vat-rubl             buf_temp-shift-stk-supp-line.slt-base       = buf_stk-supp-line.slt-base             buf_temp-shift-stk-supp-line.slt-rubl       = buf_stk-supp-line.slt-rubl             buf_temp-shift-stk-supp-line.road-tax-base  = buf_stk-supp-line.road-tax-base        buf_temp-shift-stk-supp-line.road-tax-rubl  = buf_stk-supp-line.road-tax-rubl        buf_temp-shift-stk-supp-line.excise-base    = buf_stk-supp-line.excise-base          buf_temp-shift-stk-supp-line.excise-rubl    = buf_stk-supp-line.excise-rubl          buf_temp-shift-stk-supp-line.transport-base = buf_stk-supp-line.transport-base       buf_temp-shift-stk-supp-line.transport-rubl = buf_stk-supp-line.transport-rubl       buf_temp-shift-stk-supp-line.other-base     = buf_stk-supp-line.other-base           buf_temp-shift-stk-supp-line.other-rubl     = buf_stk-supp-line.other-rubl
            .
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure update-stk-table :
  define buffer root_temp-stk-supp-tot  for temp-stk-supp-tot  .
  define buffer root_temp-stk-supp-line for temp-stk-supp-line .
  define buffer root_temp-shift-stk-supp-tot  for temp-shift-stk-supp-tot  .
  define buffer root_temp-shift-stk-supp-line for temp-shift-stk-supp-line .
  define buffer buf_temp-ot-supp-tot for temp-ot-supp-tot .
  define buffer buf_temp-stk-supp-tot for temp-stk-supp-tot .
  define buffer buf_temp-shift-stk-supp-tot for temp-shift-stk-supp-tot .
  define buffer buf_temp-ot-supp-line for temp-ot-supp-line .
  define buffer buf_temp-stk-supp-line for temp-stk-supp-line .
  define buffer buf_temp-shift-stk-supp-line for temp-shift-stk-supp-line .
  do
  on error undo, return error
  :
    for each buf_temp-ot-supp-tot
      where buf_temp-ot-supp-tot.sum-type begins 'cost':U
        and (
                                          buf_temp-ot-supp-tot.fact-qnty      <> buf_temp-ot-supp-tot.new-fact-qnty        or    buf_temp-ot-supp-tot.sum-base       <> buf_temp-ot-supp-tot.new-sum-base         or    buf_temp-ot-supp-tot.sum-rubl       <> buf_temp-ot-supp-tot.new-sum-rubl         or    buf_temp-ot-supp-tot.vat-base       <> buf_temp-ot-supp-tot.new-vat-base         or    buf_temp-ot-supp-tot.vat-rubl       <> buf_temp-ot-supp-tot.new-vat-rubl         or    buf_temp-ot-supp-tot.slt-base       <> buf_temp-ot-supp-tot.new-slt-base         or    buf_temp-ot-supp-tot.slt-rubl       <> buf_temp-ot-supp-tot.new-slt-rubl         or    buf_temp-ot-supp-tot.road-tax-base  <> buf_temp-ot-supp-tot.new-road-tax-base    or    buf_temp-ot-supp-tot.road-tax-rubl  <> buf_temp-ot-supp-tot.new-road-tax-rubl    or    buf_temp-ot-supp-tot.excise-base    <> buf_temp-ot-supp-tot.new-excise-base      or    buf_temp-ot-supp-tot.excise-rubl    <> buf_temp-ot-supp-tot.new-excise-rubl      or    buf_temp-ot-supp-tot.transport-base <> buf_temp-ot-supp-tot.new-transport-base   or    buf_temp-ot-supp-tot.transport-rubl <> buf_temp-ot-supp-tot.new-transport-rubl   or    buf_temp-ot-supp-tot.other-base     <> buf_temp-ot-supp-tot.new-other-base       or    buf_temp-ot-supp-tot.other-rubl     <> buf_temp-ot-supp-tot.new-other-rubl
            )
    on error undo, return error
    :
      for each root_temp-stk-supp-tot
        where root_temp-stk-supp-tot.obj-type = buf_temp-ot-supp-tot.obj-type
          and root_temp-stk-supp-tot.obj-code = buf_temp-ot-supp-tot.obj-code
          and root_temp-stk-supp-tot.cli-type = buf_temp-ot-supp-tot.cli-type
          and root_temp-stk-supp-tot.cli-code = buf_temp-ot-supp-tot.cli-code
          and root_temp-stk-supp-tot.sum-type = 'cost':U
          and root_temp-stk-supp-tot.cat-id   = '##':U
      on error undo, return error
      :
        find first buf_temp-stk-supp-tot
          where buf_temp-stk-supp-tot.obj-type   = buf_temp-ot-supp-tot.obj-type
            and buf_temp-stk-supp-tot.obj-code   = buf_temp-ot-supp-tot.obj-code
            and buf_temp-stk-supp-tot.cli-type   = buf_temp-ot-supp-tot.cli-type
            and buf_temp-stk-supp-tot.cli-code   = buf_temp-ot-supp-tot.cli-code
            and buf_temp-stk-supp-tot.fact-order = root_temp-stk-supp-tot.fact-order
            and buf_temp-stk-supp-tot.sum-type   = buf_temp-ot-supp-tot.sum-type
            and buf_temp-stk-supp-tot.cat-id     = buf_temp-ot-supp-tot.cat-id
          no-error .
        if not available buf_temp-stk-supp-tot
        then do:
          create buf_temp-stk-supp-tot .
          assign
            buf_temp-stk-supp-tot.obj-type   = buf_temp-ot-supp-tot.obj-type
            buf_temp-stk-supp-tot.obj-code   = buf_temp-ot-supp-tot.obj-code
            buf_temp-stk-supp-tot.cli-type   = buf_temp-ot-supp-tot.cli-type
            buf_temp-stk-supp-tot.cli-code   = buf_temp-ot-supp-tot.cli-code
            buf_temp-stk-supp-tot.fact-order = root_temp-stk-supp-tot.fact-order
            buf_temp-stk-supp-tot.sum-type   = buf_temp-ot-supp-tot.sum-type
            buf_temp-stk-supp-tot.cat-id     = buf_temp-ot-supp-tot.cat-id
            buf_temp-stk-supp-tot.fact-date  = root_temp-stk-supp-tot.fact-date
            buf_temp-stk-supp-tot.shift-num  = root_temp-stk-supp-tot.shift-num
            buf_temp-stk-supp-tot.shift-date = root_temp-stk-supp-tot.shift-date
          .
        end.
        assign
                                                                                                              buf_temp-stk-supp-tot.new-fact-qnty      = buf_temp-stk-supp-tot.new-fact-qnty      + buf_temp-ot-supp-tot.new-fact-qnty      - buf_temp-ot-supp-tot.fact-qnty           buf_temp-stk-supp-tot.new-sum-base       = buf_temp-stk-supp-tot.new-sum-base       + buf_temp-ot-supp-tot.new-sum-base       - buf_temp-ot-supp-tot.sum-base            buf_temp-stk-supp-tot.new-sum-rubl       = buf_temp-stk-supp-tot.new-sum-rubl       + buf_temp-ot-supp-tot.new-sum-rubl       - buf_temp-ot-supp-tot.sum-rubl            buf_temp-stk-supp-tot.new-vat-base       = buf_temp-stk-supp-tot.new-vat-base       + buf_temp-ot-supp-tot.new-vat-base       - buf_temp-ot-supp-tot.vat-base            buf_temp-stk-supp-tot.new-vat-rubl       = buf_temp-stk-supp-tot.new-vat-rubl       + buf_temp-ot-supp-tot.new-vat-rubl       - buf_temp-ot-supp-tot.vat-rubl            buf_temp-stk-supp-tot.new-slt-base       = buf_temp-stk-supp-tot.new-slt-base       + buf_temp-ot-supp-tot.new-slt-base       - buf_temp-ot-supp-tot.slt-base            buf_temp-stk-supp-tot.new-slt-rubl       = buf_temp-stk-supp-tot.new-slt-rubl       + buf_temp-ot-supp-tot.new-slt-rubl       - buf_temp-ot-supp-tot.slt-rubl            buf_temp-stk-supp-tot.new-road-tax-base  = buf_temp-stk-supp-tot.new-road-tax-base  + buf_temp-ot-supp-tot.new-road-tax-base  - buf_temp-ot-supp-tot.road-tax-base       buf_temp-stk-supp-tot.new-road-tax-rubl  = buf_temp-stk-supp-tot.new-road-tax-rubl  + buf_temp-ot-supp-tot.new-road-tax-rubl  - buf_temp-ot-supp-tot.road-tax-rubl       buf_temp-stk-supp-tot.new-excise-base    = buf_temp-stk-supp-tot.new-excise-base    + buf_temp-ot-supp-tot.new-excise-base    - buf_temp-ot-supp-tot.excise-base         buf_temp-stk-supp-tot.new-excise-rubl    = buf_temp-stk-supp-tot.new-excise-rubl    + buf_temp-ot-supp-tot.new-excise-rubl    - buf_temp-ot-supp-tot.excise-rubl         buf_temp-stk-supp-tot.new-transport-base = buf_temp-stk-supp-tot.new-transport-base + buf_temp-ot-supp-tot.new-transport-base - buf_temp-ot-supp-tot.transport-base      buf_temp-stk-supp-tot.new-transport-rubl = buf_temp-stk-supp-tot.new-transport-rubl + buf_temp-ot-supp-tot.new-transport-rubl - buf_temp-ot-supp-tot.transport-rubl      buf_temp-stk-supp-tot.new-other-base     = buf_temp-stk-supp-tot.new-other-base     + buf_temp-ot-supp-tot.new-other-base     - buf_temp-ot-supp-tot.other-base          buf_temp-stk-supp-tot.new-other-rubl     = buf_temp-stk-supp-tot.new-other-rubl     + buf_temp-ot-supp-tot.new-other-rubl     - buf_temp-ot-supp-tot.other-rubl
        .
      end.
      if v-shift-on
      then do:
        for each root_temp-shift-stk-supp-tot
          where root_temp-shift-stk-supp-tot.obj-type = buf_temp-ot-supp-tot.obj-type
            and root_temp-shift-stk-supp-tot.obj-code = buf_temp-ot-supp-tot.obj-code
            and root_temp-shift-stk-supp-tot.cli-type = buf_temp-ot-supp-tot.cli-type
            and root_temp-shift-stk-supp-tot.cli-code = buf_temp-ot-supp-tot.cli-code
            and root_temp-shift-stk-supp-tot.sum-type = 'cost':U
            and root_temp-shift-stk-supp-tot.cat-id   = '##':U
        on error undo, return error
        :
          find first buf_temp-shift-stk-supp-tot
            where buf_temp-shift-stk-supp-tot.obj-type   = buf_temp-ot-supp-tot.obj-type
              and buf_temp-shift-stk-supp-tot.obj-code   = buf_temp-ot-supp-tot.obj-code
              and buf_temp-shift-stk-supp-tot.cli-type   = buf_temp-ot-supp-tot.cli-type
              and buf_temp-shift-stk-supp-tot.cli-code   = buf_temp-ot-supp-tot.cli-code
              and buf_temp-shift-stk-supp-tot.fact-order = root_temp-shift-stk-supp-tot.fact-order
              and buf_temp-shift-stk-supp-tot.sum-type   = buf_temp-ot-supp-tot.sum-type
              and buf_temp-shift-stk-supp-tot.cat-id     = buf_temp-ot-supp-tot.cat-id
            no-error .
          if not available buf_temp-shift-stk-supp-tot
          then do:
            create buf_temp-shift-stk-supp-tot .
            assign
              buf_temp-shift-stk-supp-tot.obj-type   = buf_temp-ot-supp-tot.obj-type
              buf_temp-shift-stk-supp-tot.obj-code   = buf_temp-ot-supp-tot.obj-code
              buf_temp-shift-stk-supp-tot.cli-type   = buf_temp-ot-supp-tot.cli-type
              buf_temp-shift-stk-supp-tot.cli-code   = buf_temp-ot-supp-tot.cli-code
              buf_temp-shift-stk-supp-tot.fact-order = root_temp-shift-stk-supp-tot.fact-order
              buf_temp-shift-stk-supp-tot.sum-type   = buf_temp-ot-supp-tot.sum-type
              buf_temp-shift-stk-supp-tot.cat-id     = buf_temp-ot-supp-tot.cat-id
              buf_temp-shift-stk-supp-tot.fact-date  = root_temp-shift-stk-supp-tot.fact-date
              buf_temp-shift-stk-supp-tot.shift-num  = root_temp-shift-stk-supp-tot.shift-num
              buf_temp-shift-stk-supp-tot.shift-date = root_temp-shift-stk-supp-tot.shift-date
            .
          end.
          assign
                                                                                                                                    buf_temp-shift-stk-supp-tot.new-fact-qnty      = buf_temp-shift-stk-supp-tot.new-fact-qnty      + buf_temp-ot-supp-tot.new-fact-qnty      - buf_temp-ot-supp-tot.fact-qnty           buf_temp-shift-stk-supp-tot.new-sum-base       = buf_temp-shift-stk-supp-tot.new-sum-base       + buf_temp-ot-supp-tot.new-sum-base       - buf_temp-ot-supp-tot.sum-base            buf_temp-shift-stk-supp-tot.new-sum-rubl       = buf_temp-shift-stk-supp-tot.new-sum-rubl       + buf_temp-ot-supp-tot.new-sum-rubl       - buf_temp-ot-supp-tot.sum-rubl            buf_temp-shift-stk-supp-tot.new-vat-base       = buf_temp-shift-stk-supp-tot.new-vat-base       + buf_temp-ot-supp-tot.new-vat-base       - buf_temp-ot-supp-tot.vat-base            buf_temp-shift-stk-supp-tot.new-vat-rubl       = buf_temp-shift-stk-supp-tot.new-vat-rubl       + buf_temp-ot-supp-tot.new-vat-rubl       - buf_temp-ot-supp-tot.vat-rubl            buf_temp-shift-stk-supp-tot.new-slt-base       = buf_temp-shift-stk-supp-tot.new-slt-base       + buf_temp-ot-supp-tot.new-slt-base       - buf_temp-ot-supp-tot.slt-base            buf_temp-shift-stk-supp-tot.new-slt-rubl       = buf_temp-shift-stk-supp-tot.new-slt-rubl       + buf_temp-ot-supp-tot.new-slt-rubl       - buf_temp-ot-supp-tot.slt-rubl            buf_temp-shift-stk-supp-tot.new-road-tax-base  = buf_temp-shift-stk-supp-tot.new-road-tax-base  + buf_temp-ot-supp-tot.new-road-tax-base  - buf_temp-ot-supp-tot.road-tax-base       buf_temp-shift-stk-supp-tot.new-road-tax-rubl  = buf_temp-shift-stk-supp-tot.new-road-tax-rubl  + buf_temp-ot-supp-tot.new-road-tax-rubl  - buf_temp-ot-supp-tot.road-tax-rubl       buf_temp-shift-stk-supp-tot.new-excise-base    = buf_temp-shift-stk-supp-tot.new-excise-base    + buf_temp-ot-supp-tot.new-excise-base    - buf_temp-ot-supp-tot.excise-base         buf_temp-shift-stk-supp-tot.new-excise-rubl    = buf_temp-shift-stk-supp-tot.new-excise-rubl    + buf_temp-ot-supp-tot.new-excise-rubl    - buf_temp-ot-supp-tot.excise-rubl         buf_temp-shift-stk-supp-tot.new-transport-base = buf_temp-shift-stk-supp-tot.new-transport-base + buf_temp-ot-supp-tot.new-transport-base - buf_temp-ot-supp-tot.transport-base      buf_temp-shift-stk-supp-tot.new-transport-rubl = buf_temp-shift-stk-supp-tot.new-transport-rubl + buf_temp-ot-supp-tot.new-transport-rubl - buf_temp-ot-supp-tot.transport-rubl      buf_temp-shift-stk-supp-tot.new-other-base     = buf_temp-shift-stk-supp-tot.new-other-base     + buf_temp-ot-supp-tot.new-other-base     - buf_temp-ot-supp-tot.other-base          buf_temp-shift-stk-supp-tot.new-other-rubl     = buf_temp-shift-stk-supp-tot.new-other-rubl     + buf_temp-ot-supp-tot.new-other-rubl     - buf_temp-ot-supp-tot.other-rubl
          .
        end.
      end.
    end.
    for each buf_temp-ot-supp-tot
      where buf_temp-ot-supp-tot.sum-type = 'sale':U
        and (
                                          buf_temp-ot-supp-tot.fact-qnty      <> buf_temp-ot-supp-tot.new-fact-qnty        or    buf_temp-ot-supp-tot.sum-base       <> buf_temp-ot-supp-tot.new-sum-base         or    buf_temp-ot-supp-tot.sum-rubl       <> buf_temp-ot-supp-tot.new-sum-rubl         or    buf_temp-ot-supp-tot.vat-base       <> buf_temp-ot-supp-tot.new-vat-base         or    buf_temp-ot-supp-tot.vat-rubl       <> buf_temp-ot-supp-tot.new-vat-rubl         or    buf_temp-ot-supp-tot.slt-base       <> buf_temp-ot-supp-tot.new-slt-base         or    buf_temp-ot-supp-tot.slt-rubl       <> buf_temp-ot-supp-tot.new-slt-rubl         or    buf_temp-ot-supp-tot.road-tax-base  <> buf_temp-ot-supp-tot.new-road-tax-base    or    buf_temp-ot-supp-tot.road-tax-rubl  <> buf_temp-ot-supp-tot.new-road-tax-rubl    or    buf_temp-ot-supp-tot.excise-base    <> buf_temp-ot-supp-tot.new-excise-base      or    buf_temp-ot-supp-tot.excise-rubl    <> buf_temp-ot-supp-tot.new-excise-rubl      or    buf_temp-ot-supp-tot.transport-base <> buf_temp-ot-supp-tot.new-transport-base   or    buf_temp-ot-supp-tot.transport-rubl <> buf_temp-ot-supp-tot.new-transport-rubl   or    buf_temp-ot-supp-tot.other-base     <> buf_temp-ot-supp-tot.new-other-base       or    buf_temp-ot-supp-tot.other-rubl     <> buf_temp-ot-supp-tot.new-other-rubl
            )
    on error undo, return error
    :
      for each root_temp-stk-supp-tot
        where root_temp-stk-supp-tot.obj-type = buf_temp-ot-supp-tot.obj-type
          and root_temp-stk-supp-tot.obj-code = buf_temp-ot-supp-tot.obj-code
          and root_temp-stk-supp-tot.cli-type = buf_temp-ot-supp-tot.cli-type
          and root_temp-stk-supp-tot.cli-code = buf_temp-ot-supp-tot.cli-code
          and root_temp-stk-supp-tot.sum-type = 'sadt':U + buf_trn-doc.ext-doc-type
          and root_temp-stk-supp-tot.cat-id   = '##':U
      on error undo, return error
      :
        find first buf_temp-stk-supp-tot
          where buf_temp-stk-supp-tot.obj-type   = buf_temp-ot-supp-tot.obj-type
            and buf_temp-stk-supp-tot.obj-code   = buf_temp-ot-supp-tot.obj-code
            and buf_temp-stk-supp-tot.cli-type   = buf_temp-ot-supp-tot.cli-type
            and buf_temp-stk-supp-tot.cli-code   = buf_temp-ot-supp-tot.cli-code
            and buf_temp-stk-supp-tot.fact-order = root_temp-stk-supp-tot.fact-order
            and buf_temp-stk-supp-tot.sum-type   = root_temp-stk-supp-tot.sum-type
            and buf_temp-stk-supp-tot.cat-id     = '##':U
          no-error .
        if not available buf_temp-stk-supp-tot
        then do:
          create buf_temp-stk-supp-tot .
          assign
            buf_temp-stk-supp-tot.obj-type   = buf_temp-ot-supp-tot.obj-type
            buf_temp-stk-supp-tot.obj-code   = buf_temp-ot-supp-tot.obj-code
            buf_temp-stk-supp-tot.cli-type   = buf_temp-ot-supp-tot.cli-type
            buf_temp-stk-supp-tot.cli-code   = buf_temp-ot-supp-tot.cli-code
            buf_temp-stk-supp-tot.fact-order = root_temp-stk-supp-tot.fact-order
            buf_temp-stk-supp-tot.sum-type   = root_temp-stk-supp-tot.sum-type
            buf_temp-stk-supp-tot.cat-id     = '##':U
            buf_temp-stk-supp-tot.fact-date  = root_temp-stk-supp-tot.fact-date
            buf_temp-stk-supp-tot.shift-num  = root_temp-stk-supp-tot.shift-num
            buf_temp-stk-supp-tot.shift-date = root_temp-stk-supp-tot.shift-date
          .
        end.
        assign
                                                                                                              buf_temp-stk-supp-tot.new-fact-qnty      = buf_temp-stk-supp-tot.new-fact-qnty      + buf_temp-ot-supp-tot.new-fact-qnty      - buf_temp-ot-supp-tot.fact-qnty           buf_temp-stk-supp-tot.new-sum-base       = buf_temp-stk-supp-tot.new-sum-base       + buf_temp-ot-supp-tot.new-sum-base       - buf_temp-ot-supp-tot.sum-base            buf_temp-stk-supp-tot.new-sum-rubl       = buf_temp-stk-supp-tot.new-sum-rubl       + buf_temp-ot-supp-tot.new-sum-rubl       - buf_temp-ot-supp-tot.sum-rubl            buf_temp-stk-supp-tot.new-vat-base       = buf_temp-stk-supp-tot.new-vat-base       + buf_temp-ot-supp-tot.new-vat-base       - buf_temp-ot-supp-tot.vat-base            buf_temp-stk-supp-tot.new-vat-rubl       = buf_temp-stk-supp-tot.new-vat-rubl       + buf_temp-ot-supp-tot.new-vat-rubl       - buf_temp-ot-supp-tot.vat-rubl            buf_temp-stk-supp-tot.new-slt-base       = buf_temp-stk-supp-tot.new-slt-base       + buf_temp-ot-supp-tot.new-slt-base       - buf_temp-ot-supp-tot.slt-base            buf_temp-stk-supp-tot.new-slt-rubl       = buf_temp-stk-supp-tot.new-slt-rubl       + buf_temp-ot-supp-tot.new-slt-rubl       - buf_temp-ot-supp-tot.slt-rubl            buf_temp-stk-supp-tot.new-road-tax-base  = buf_temp-stk-supp-tot.new-road-tax-base  + buf_temp-ot-supp-tot.new-road-tax-base  - buf_temp-ot-supp-tot.road-tax-base       buf_temp-stk-supp-tot.new-road-tax-rubl  = buf_temp-stk-supp-tot.new-road-tax-rubl  + buf_temp-ot-supp-tot.new-road-tax-rubl  - buf_temp-ot-supp-tot.road-tax-rubl       buf_temp-stk-supp-tot.new-excise-base    = buf_temp-stk-supp-tot.new-excise-base    + buf_temp-ot-supp-tot.new-excise-base    - buf_temp-ot-supp-tot.excise-base         buf_temp-stk-supp-tot.new-excise-rubl    = buf_temp-stk-supp-tot.new-excise-rubl    + buf_temp-ot-supp-tot.new-excise-rubl    - buf_temp-ot-supp-tot.excise-rubl         buf_temp-stk-supp-tot.new-transport-base = buf_temp-stk-supp-tot.new-transport-base + buf_temp-ot-supp-tot.new-transport-base - buf_temp-ot-supp-tot.transport-base      buf_temp-stk-supp-tot.new-transport-rubl = buf_temp-stk-supp-tot.new-transport-rubl + buf_temp-ot-supp-tot.new-transport-rubl - buf_temp-ot-supp-tot.transport-rubl      buf_temp-stk-supp-tot.new-other-base     = buf_temp-stk-supp-tot.new-other-base     + buf_temp-ot-supp-tot.new-other-base     - buf_temp-ot-supp-tot.other-base          buf_temp-stk-supp-tot.new-other-rubl     = buf_temp-stk-supp-tot.new-other-rubl     + buf_temp-ot-supp-tot.new-other-rubl     - buf_temp-ot-supp-tot.other-rubl
        .
      end.
      if v-shift-on
      then do:
        for each root_temp-shift-stk-supp-tot
          where root_temp-shift-stk-supp-tot.obj-type = buf_temp-ot-supp-tot.obj-type
            and root_temp-shift-stk-supp-tot.obj-code = buf_temp-ot-supp-tot.obj-code
            and root_temp-shift-stk-supp-tot.cli-type = buf_temp-ot-supp-tot.cli-type
            and root_temp-shift-stk-supp-tot.cli-code = buf_temp-ot-supp-tot.cli-code
            and root_temp-shift-stk-supp-tot.sum-type = 'sadt':U + buf_trn-doc.ext-doc-type
            and root_temp-shift-stk-supp-tot.cat-id   = '##':U
        on error undo, return error
        :
          find first buf_temp-shift-stk-supp-tot
            where buf_temp-shift-stk-supp-tot.obj-type   = buf_temp-ot-supp-tot.obj-type
              and buf_temp-shift-stk-supp-tot.obj-code   = buf_temp-ot-supp-tot.obj-code
              and buf_temp-shift-stk-supp-tot.cli-type   = buf_temp-ot-supp-tot.cli-type
              and buf_temp-shift-stk-supp-tot.cli-code   = buf_temp-ot-supp-tot.cli-code
              and buf_temp-shift-stk-supp-tot.fact-order = root_temp-shift-stk-supp-tot.fact-order
              and buf_temp-shift-stk-supp-tot.sum-type   = root_temp-shift-stk-supp-tot.sum-type
              and buf_temp-shift-stk-supp-tot.cat-id     = '##':U
            no-error .
          if not available buf_temp-shift-stk-supp-tot
          then do:
            create buf_temp-shift-stk-supp-tot .
            assign
              buf_temp-shift-stk-supp-tot.obj-type   = buf_temp-ot-supp-tot.obj-type
              buf_temp-shift-stk-supp-tot.obj-code   = buf_temp-ot-supp-tot.obj-code
              buf_temp-shift-stk-supp-tot.cli-type   = buf_temp-ot-supp-tot.cli-type
              buf_temp-shift-stk-supp-tot.cli-code   = buf_temp-ot-supp-tot.cli-code
              buf_temp-shift-stk-supp-tot.fact-order = root_temp-shift-stk-supp-tot.fact-order
              buf_temp-shift-stk-supp-tot.sum-type   = root_temp-shift-stk-supp-tot.sum-type
              buf_temp-shift-stk-supp-tot.cat-id     = '##':U
              buf_temp-shift-stk-supp-tot.fact-date  = root_temp-shift-stk-supp-tot.fact-date
              buf_temp-shift-stk-supp-tot.shift-num  = root_temp-shift-stk-supp-tot.shift-num
              buf_temp-shift-stk-supp-tot.shift-date = root_temp-shift-stk-supp-tot.shift-date
            .
          end.
          assign
                                                                                                                                    buf_temp-shift-stk-supp-tot.new-fact-qnty      = buf_temp-shift-stk-supp-tot.new-fact-qnty      + buf_temp-ot-supp-tot.new-fact-qnty      - buf_temp-ot-supp-tot.fact-qnty           buf_temp-shift-stk-supp-tot.new-sum-base       = buf_temp-shift-stk-supp-tot.new-sum-base       + buf_temp-ot-supp-tot.new-sum-base       - buf_temp-ot-supp-tot.sum-base            buf_temp-shift-stk-supp-tot.new-sum-rubl       = buf_temp-shift-stk-supp-tot.new-sum-rubl       + buf_temp-ot-supp-tot.new-sum-rubl       - buf_temp-ot-supp-tot.sum-rubl            buf_temp-shift-stk-supp-tot.new-vat-base       = buf_temp-shift-stk-supp-tot.new-vat-base       + buf_temp-ot-supp-tot.new-vat-base       - buf_temp-ot-supp-tot.vat-base            buf_temp-shift-stk-supp-tot.new-vat-rubl       = buf_temp-shift-stk-supp-tot.new-vat-rubl       + buf_temp-ot-supp-tot.new-vat-rubl       - buf_temp-ot-supp-tot.vat-rubl            buf_temp-shift-stk-supp-tot.new-slt-base       = buf_temp-shift-stk-supp-tot.new-slt-base       + buf_temp-ot-supp-tot.new-slt-base       - buf_temp-ot-supp-tot.slt-base            buf_temp-shift-stk-supp-tot.new-slt-rubl       = buf_temp-shift-stk-supp-tot.new-slt-rubl       + buf_temp-ot-supp-tot.new-slt-rubl       - buf_temp-ot-supp-tot.slt-rubl            buf_temp-shift-stk-supp-tot.new-road-tax-base  = buf_temp-shift-stk-supp-tot.new-road-tax-base  + buf_temp-ot-supp-tot.new-road-tax-base  - buf_temp-ot-supp-tot.road-tax-base       buf_temp-shift-stk-supp-tot.new-road-tax-rubl  = buf_temp-shift-stk-supp-tot.new-road-tax-rubl  + buf_temp-ot-supp-tot.new-road-tax-rubl  - buf_temp-ot-supp-tot.road-tax-rubl       buf_temp-shift-stk-supp-tot.new-excise-base    = buf_temp-shift-stk-supp-tot.new-excise-base    + buf_temp-ot-supp-tot.new-excise-base    - buf_temp-ot-supp-tot.excise-base         buf_temp-shift-stk-supp-tot.new-excise-rubl    = buf_temp-shift-stk-supp-tot.new-excise-rubl    + buf_temp-ot-supp-tot.new-excise-rubl    - buf_temp-ot-supp-tot.excise-rubl         buf_temp-shift-stk-supp-tot.new-transport-base = buf_temp-shift-stk-supp-tot.new-transport-base + buf_temp-ot-supp-tot.new-transport-base - buf_temp-ot-supp-tot.transport-base      buf_temp-shift-stk-supp-tot.new-transport-rubl = buf_temp-shift-stk-supp-tot.new-transport-rubl + buf_temp-ot-supp-tot.new-transport-rubl - buf_temp-ot-supp-tot.transport-rubl      buf_temp-shift-stk-supp-tot.new-other-base     = buf_temp-shift-stk-supp-tot.new-other-base     + buf_temp-ot-supp-tot.new-other-base     - buf_temp-ot-supp-tot.other-base          buf_temp-shift-stk-supp-tot.new-other-rubl     = buf_temp-shift-stk-supp-tot.new-other-rubl     + buf_temp-ot-supp-tot.new-other-rubl     - buf_temp-ot-supp-tot.other-rubl
          .
        end.
      end.
    end.
    for each buf_temp-ot-supp-tot
      where buf_temp-ot-supp-tot.sum-type = 'cost':U
        and (
                                          buf_temp-ot-supp-tot.fact-qnty      <> buf_temp-ot-supp-tot.new-fact-qnty        or    buf_temp-ot-supp-tot.sum-base       <> buf_temp-ot-supp-tot.new-sum-base         or    buf_temp-ot-supp-tot.sum-rubl       <> buf_temp-ot-supp-tot.new-sum-rubl         or    buf_temp-ot-supp-tot.vat-base       <> buf_temp-ot-supp-tot.new-vat-base         or    buf_temp-ot-supp-tot.vat-rubl       <> buf_temp-ot-supp-tot.new-vat-rubl         or    buf_temp-ot-supp-tot.slt-base       <> buf_temp-ot-supp-tot.new-slt-base         or    buf_temp-ot-supp-tot.slt-rubl       <> buf_temp-ot-supp-tot.new-slt-rubl         or    buf_temp-ot-supp-tot.road-tax-base  <> buf_temp-ot-supp-tot.new-road-tax-base    or    buf_temp-ot-supp-tot.road-tax-rubl  <> buf_temp-ot-supp-tot.new-road-tax-rubl    or    buf_temp-ot-supp-tot.excise-base    <> buf_temp-ot-supp-tot.new-excise-base      or    buf_temp-ot-supp-tot.excise-rubl    <> buf_temp-ot-supp-tot.new-excise-rubl      or    buf_temp-ot-supp-tot.transport-base <> buf_temp-ot-supp-tot.new-transport-base   or    buf_temp-ot-supp-tot.transport-rubl <> buf_temp-ot-supp-tot.new-transport-rubl   or    buf_temp-ot-supp-tot.other-base     <> buf_temp-ot-supp-tot.new-other-base       or    buf_temp-ot-supp-tot.other-rubl     <> buf_temp-ot-supp-tot.new-other-rubl
            )
    on error undo, return error
    :
      for each root_temp-stk-supp-tot
        where root_temp-stk-supp-tot.obj-type = buf_temp-ot-supp-tot.obj-type
          and root_temp-stk-supp-tot.obj-code = buf_temp-ot-supp-tot.obj-code
          and root_temp-stk-supp-tot.cli-type = buf_temp-ot-supp-tot.cli-type
          and root_temp-stk-supp-tot.cli-code = buf_temp-ot-supp-tot.cli-code
          and root_temp-stk-supp-tot.sum-type = 'csdt':U + buf_trn-doc.ext-doc-type
          and root_temp-stk-supp-tot.cat-id   = '##':U
      on error undo, return error
      :
        find first buf_temp-stk-supp-tot
          where buf_temp-stk-supp-tot.obj-type   = buf_temp-ot-supp-tot.obj-type
            and buf_temp-stk-supp-tot.obj-code   = buf_temp-ot-supp-tot.obj-code
            and buf_temp-stk-supp-tot.cli-type   = buf_temp-ot-supp-tot.cli-type
            and buf_temp-stk-supp-tot.cli-code   = buf_temp-ot-supp-tot.cli-code
            and buf_temp-stk-supp-tot.fact-order = root_temp-stk-supp-tot.fact-order
            and buf_temp-stk-supp-tot.sum-type   = root_temp-stk-supp-tot.sum-type
            and buf_temp-stk-supp-tot.cat-id     = '##':U
          no-error .
        if not available buf_temp-stk-supp-tot
        then do:
          create buf_temp-stk-supp-tot .
          assign
            buf_temp-stk-supp-tot.obj-type   = buf_temp-ot-supp-tot.obj-type
            buf_temp-stk-supp-tot.obj-code   = buf_temp-ot-supp-tot.obj-code
            buf_temp-stk-supp-tot.cli-type   = buf_temp-ot-supp-tot.cli-type
            buf_temp-stk-supp-tot.cli-code   = buf_temp-ot-supp-tot.cli-code
            buf_temp-stk-supp-tot.fact-order = root_temp-stk-supp-tot.fact-order
            buf_temp-stk-supp-tot.sum-type   = root_temp-stk-supp-tot.sum-type
            buf_temp-stk-supp-tot.cat-id     = '##':U
            buf_temp-stk-supp-tot.fact-date  = root_temp-stk-supp-tot.fact-date
            buf_temp-stk-supp-tot.shift-num  = root_temp-stk-supp-tot.shift-num
            buf_temp-stk-supp-tot.shift-date = root_temp-stk-supp-tot.shift-date
          .
        end.
        assign
                                                                                                              buf_temp-stk-supp-tot.new-fact-qnty      = buf_temp-stk-supp-tot.new-fact-qnty      + buf_temp-ot-supp-tot.new-fact-qnty      - buf_temp-ot-supp-tot.fact-qnty           buf_temp-stk-supp-tot.new-sum-base       = buf_temp-stk-supp-tot.new-sum-base       + buf_temp-ot-supp-tot.new-sum-base       - buf_temp-ot-supp-tot.sum-base            buf_temp-stk-supp-tot.new-sum-rubl       = buf_temp-stk-supp-tot.new-sum-rubl       + buf_temp-ot-supp-tot.new-sum-rubl       - buf_temp-ot-supp-tot.sum-rubl            buf_temp-stk-supp-tot.new-vat-base       = buf_temp-stk-supp-tot.new-vat-base       + buf_temp-ot-supp-tot.new-vat-base       - buf_temp-ot-supp-tot.vat-base            buf_temp-stk-supp-tot.new-vat-rubl       = buf_temp-stk-supp-tot.new-vat-rubl       + buf_temp-ot-supp-tot.new-vat-rubl       - buf_temp-ot-supp-tot.vat-rubl            buf_temp-stk-supp-tot.new-slt-base       = buf_temp-stk-supp-tot.new-slt-base       + buf_temp-ot-supp-tot.new-slt-base       - buf_temp-ot-supp-tot.slt-base            buf_temp-stk-supp-tot.new-slt-rubl       = buf_temp-stk-supp-tot.new-slt-rubl       + buf_temp-ot-supp-tot.new-slt-rubl       - buf_temp-ot-supp-tot.slt-rubl            buf_temp-stk-supp-tot.new-road-tax-base  = buf_temp-stk-supp-tot.new-road-tax-base  + buf_temp-ot-supp-tot.new-road-tax-base  - buf_temp-ot-supp-tot.road-tax-base       buf_temp-stk-supp-tot.new-road-tax-rubl  = buf_temp-stk-supp-tot.new-road-tax-rubl  + buf_temp-ot-supp-tot.new-road-tax-rubl  - buf_temp-ot-supp-tot.road-tax-rubl       buf_temp-stk-supp-tot.new-excise-base    = buf_temp-stk-supp-tot.new-excise-base    + buf_temp-ot-supp-tot.new-excise-base    - buf_temp-ot-supp-tot.excise-base         buf_temp-stk-supp-tot.new-excise-rubl    = buf_temp-stk-supp-tot.new-excise-rubl    + buf_temp-ot-supp-tot.new-excise-rubl    - buf_temp-ot-supp-tot.excise-rubl         buf_temp-stk-supp-tot.new-transport-base = buf_temp-stk-supp-tot.new-transport-base + buf_temp-ot-supp-tot.new-transport-base - buf_temp-ot-supp-tot.transport-base      buf_temp-stk-supp-tot.new-transport-rubl = buf_temp-stk-supp-tot.new-transport-rubl + buf_temp-ot-supp-tot.new-transport-rubl - buf_temp-ot-supp-tot.transport-rubl      buf_temp-stk-supp-tot.new-other-base     = buf_temp-stk-supp-tot.new-other-base     + buf_temp-ot-supp-tot.new-other-base     - buf_temp-ot-supp-tot.other-base          buf_temp-stk-supp-tot.new-other-rubl     = buf_temp-stk-supp-tot.new-other-rubl     + buf_temp-ot-supp-tot.new-other-rubl     - buf_temp-ot-supp-tot.other-rubl
        .
      end.
      if v-shift-on
      then do:
        for each root_temp-shift-stk-supp-tot
          where root_temp-shift-stk-supp-tot.obj-type = buf_temp-ot-supp-tot.obj-type
            and root_temp-shift-stk-supp-tot.obj-code = buf_temp-ot-supp-tot.obj-code
            and root_temp-shift-stk-supp-tot.cli-type = buf_temp-ot-supp-tot.cli-type
            and root_temp-shift-stk-supp-tot.cli-code = buf_temp-ot-supp-tot.cli-code
            and root_temp-shift-stk-supp-tot.sum-type = 'csdt':U + buf_trn-doc.ext-doc-type
            and root_temp-shift-stk-supp-tot.cat-id   = '##':U
        on error undo, return error
        :
          find first buf_temp-shift-stk-supp-tot
            where buf_temp-shift-stk-supp-tot.obj-type   = buf_temp-ot-supp-tot.obj-type
              and buf_temp-shift-stk-supp-tot.obj-code   = buf_temp-ot-supp-tot.obj-code
              and buf_temp-shift-stk-supp-tot.cli-type   = buf_temp-ot-supp-tot.cli-type
              and buf_temp-shift-stk-supp-tot.cli-code   = buf_temp-ot-supp-tot.cli-code
              and buf_temp-shift-stk-supp-tot.fact-order = root_temp-shift-stk-supp-tot.fact-order
              and buf_temp-shift-stk-supp-tot.sum-type   = root_temp-shift-stk-supp-tot.sum-type
              and buf_temp-shift-stk-supp-tot.cat-id     = '##':U
            no-error .
          if not available buf_temp-shift-stk-supp-tot
          then do:
            create buf_temp-shift-stk-supp-tot .
            assign
              buf_temp-shift-stk-supp-tot.obj-type   = buf_temp-ot-supp-tot.obj-type
              buf_temp-shift-stk-supp-tot.obj-code   = buf_temp-ot-supp-tot.obj-code
              buf_temp-shift-stk-supp-tot.cli-type   = buf_temp-ot-supp-tot.cli-type
              buf_temp-shift-stk-supp-tot.cli-code   = buf_temp-ot-supp-tot.cli-code
              buf_temp-shift-stk-supp-tot.fact-order = root_temp-shift-stk-supp-tot.fact-order
              buf_temp-shift-stk-supp-tot.sum-type   = root_temp-shift-stk-supp-tot.sum-type
              buf_temp-shift-stk-supp-tot.cat-id     = '##':U
              buf_temp-shift-stk-supp-tot.fact-date  = root_temp-shift-stk-supp-tot.fact-date
              buf_temp-shift-stk-supp-tot.shift-num  = root_temp-shift-stk-supp-tot.shift-num
              buf_temp-shift-stk-supp-tot.shift-date = root_temp-shift-stk-supp-tot.shift-date
            .
          end.
          assign
                                                                                                                                    buf_temp-shift-stk-supp-tot.new-fact-qnty      = buf_temp-shift-stk-supp-tot.new-fact-qnty      + buf_temp-ot-supp-tot.new-fact-qnty      - buf_temp-ot-supp-tot.fact-qnty           buf_temp-shift-stk-supp-tot.new-sum-base       = buf_temp-shift-stk-supp-tot.new-sum-base       + buf_temp-ot-supp-tot.new-sum-base       - buf_temp-ot-supp-tot.sum-base            buf_temp-shift-stk-supp-tot.new-sum-rubl       = buf_temp-shift-stk-supp-tot.new-sum-rubl       + buf_temp-ot-supp-tot.new-sum-rubl       - buf_temp-ot-supp-tot.sum-rubl            buf_temp-shift-stk-supp-tot.new-vat-base       = buf_temp-shift-stk-supp-tot.new-vat-base       + buf_temp-ot-supp-tot.new-vat-base       - buf_temp-ot-supp-tot.vat-base            buf_temp-shift-stk-supp-tot.new-vat-rubl       = buf_temp-shift-stk-supp-tot.new-vat-rubl       + buf_temp-ot-supp-tot.new-vat-rubl       - buf_temp-ot-supp-tot.vat-rubl            buf_temp-shift-stk-supp-tot.new-slt-base       = buf_temp-shift-stk-supp-tot.new-slt-base       + buf_temp-ot-supp-tot.new-slt-base       - buf_temp-ot-supp-tot.slt-base            buf_temp-shift-stk-supp-tot.new-slt-rubl       = buf_temp-shift-stk-supp-tot.new-slt-rubl       + buf_temp-ot-supp-tot.new-slt-rubl       - buf_temp-ot-supp-tot.slt-rubl            buf_temp-shift-stk-supp-tot.new-road-tax-base  = buf_temp-shift-stk-supp-tot.new-road-tax-base  + buf_temp-ot-supp-tot.new-road-tax-base  - buf_temp-ot-supp-tot.road-tax-base       buf_temp-shift-stk-supp-tot.new-road-tax-rubl  = buf_temp-shift-stk-supp-tot.new-road-tax-rubl  + buf_temp-ot-supp-tot.new-road-tax-rubl  - buf_temp-ot-supp-tot.road-tax-rubl       buf_temp-shift-stk-supp-tot.new-excise-base    = buf_temp-shift-stk-supp-tot.new-excise-base    + buf_temp-ot-supp-tot.new-excise-base    - buf_temp-ot-supp-tot.excise-base         buf_temp-shift-stk-supp-tot.new-excise-rubl    = buf_temp-shift-stk-supp-tot.new-excise-rubl    + buf_temp-ot-supp-tot.new-excise-rubl    - buf_temp-ot-supp-tot.excise-rubl         buf_temp-shift-stk-supp-tot.new-transport-base = buf_temp-shift-stk-supp-tot.new-transport-base + buf_temp-ot-supp-tot.new-transport-base - buf_temp-ot-supp-tot.transport-base      buf_temp-shift-stk-supp-tot.new-transport-rubl = buf_temp-shift-stk-supp-tot.new-transport-rubl + buf_temp-ot-supp-tot.new-transport-rubl - buf_temp-ot-supp-tot.transport-rubl      buf_temp-shift-stk-supp-tot.new-other-base     = buf_temp-shift-stk-supp-tot.new-other-base     + buf_temp-ot-supp-tot.new-other-base     - buf_temp-ot-supp-tot.other-base          buf_temp-shift-stk-supp-tot.new-other-rubl     = buf_temp-shift-stk-supp-tot.new-other-rubl     + buf_temp-ot-supp-tot.new-other-rubl     - buf_temp-ot-supp-tot.other-rubl
          .
        end.
      end.
    end.
    for each buf_temp-ot-supp-line
      where buf_temp-ot-supp-line.sum-type begins 'cost':U
        and (
                                          buf_temp-ot-supp-line.fact-qnty      <> buf_temp-ot-supp-line.new-fact-qnty        or    buf_temp-ot-supp-line.sum-base       <> buf_temp-ot-supp-line.new-sum-base         or    buf_temp-ot-supp-line.sum-rubl       <> buf_temp-ot-supp-line.new-sum-rubl         or    buf_temp-ot-supp-line.vat-base       <> buf_temp-ot-supp-line.new-vat-base         or    buf_temp-ot-supp-line.vat-rubl       <> buf_temp-ot-supp-line.new-vat-rubl         or    buf_temp-ot-supp-line.slt-base       <> buf_temp-ot-supp-line.new-slt-base         or    buf_temp-ot-supp-line.slt-rubl       <> buf_temp-ot-supp-line.new-slt-rubl         or    buf_temp-ot-supp-line.road-tax-base  <> buf_temp-ot-supp-line.new-road-tax-base    or    buf_temp-ot-supp-line.road-tax-rubl  <> buf_temp-ot-supp-line.new-road-tax-rubl    or    buf_temp-ot-supp-line.excise-base    <> buf_temp-ot-supp-line.new-excise-base      or    buf_temp-ot-supp-line.excise-rubl    <> buf_temp-ot-supp-line.new-excise-rubl      or    buf_temp-ot-supp-line.transport-base <> buf_temp-ot-supp-line.new-transport-base   or    buf_temp-ot-supp-line.transport-rubl <> buf_temp-ot-supp-line.new-transport-rubl   or    buf_temp-ot-supp-line.other-base     <> buf_temp-ot-supp-line.new-other-base       or    buf_temp-ot-supp-line.other-rubl     <> buf_temp-ot-supp-line.new-other-rubl
            )
    on error undo, return error
    :
      for each root_temp-stk-supp-line
        where root_temp-stk-supp-line.obj-type  = buf_temp-ot-supp-line.obj-type
          and root_temp-stk-supp-line.obj-code  = buf_temp-ot-supp-line.obj-code
          and root_temp-stk-supp-line.cli-type  = buf_temp-ot-supp-line.cli-type
          and root_temp-stk-supp-line.cli-code  = buf_temp-ot-supp-line.cli-code
          and root_temp-stk-supp-line.artic     = buf_temp-ot-supp-line.artic
          and root_temp-stk-supp-line.prod-type = buf_temp-ot-supp-line.prod-type
          and root_temp-stk-supp-line.prod-code = buf_temp-ot-supp-line.prod-code
          and root_temp-stk-supp-line.sum-type  = 'cost':U
          and root_temp-stk-supp-line.cat-id    = '##':U
      on error undo, return error
      :
        find first buf_temp-stk-supp-line
          where buf_temp-stk-supp-line.obj-type   = buf_temp-ot-supp-line.obj-type
            and buf_temp-stk-supp-line.obj-code   = buf_temp-ot-supp-line.obj-code
            and buf_temp-stk-supp-line.cli-type   = buf_temp-ot-supp-line.cli-type
            and buf_temp-stk-supp-line.cli-code   = buf_temp-ot-supp-line.cli-code
            and buf_temp-stk-supp-line.artic      = buf_temp-ot-supp-line.artic
            and buf_temp-stk-supp-line.prod-type  = buf_temp-ot-supp-line.prod-type
            and buf_temp-stk-supp-line.prod-code  = buf_temp-ot-supp-line.prod-code
            and buf_temp-stk-supp-line.fact-order = root_temp-stk-supp-line.fact-order
            and buf_temp-stk-supp-line.sum-type   = buf_temp-ot-supp-line.sum-type
            and buf_temp-stk-supp-line.cat-id     = buf_temp-ot-supp-line.cat-id
          no-error .
        if not available buf_temp-stk-supp-line
        then do:
          create buf_temp-stk-supp-line .
          assign
            buf_temp-stk-supp-line.obj-type   = buf_temp-ot-supp-line.obj-type
            buf_temp-stk-supp-line.obj-code   = buf_temp-ot-supp-line.obj-code
            buf_temp-stk-supp-line.cli-type   = buf_temp-ot-supp-line.cli-type
            buf_temp-stk-supp-line.cli-code   = buf_temp-ot-supp-line.cli-code
            buf_temp-stk-supp-line.artic      = buf_temp-ot-supp-line.artic
            buf_temp-stk-supp-line.prod-type  = buf_temp-ot-supp-line.prod-type
            buf_temp-stk-supp-line.prod-code  = buf_temp-ot-supp-line.prod-code
            buf_temp-stk-supp-line.fact-order = root_temp-stk-supp-line.fact-order
            buf_temp-stk-supp-line.sum-type   = buf_temp-ot-supp-line.sum-type
            buf_temp-stk-supp-line.cat-id     = buf_temp-ot-supp-line.cat-id
            buf_temp-stk-supp-line.fact-date  = root_temp-stk-supp-line.fact-date
            buf_temp-stk-supp-line.shift-num  = root_temp-stk-supp-line.shift-num
            buf_temp-stk-supp-line.shift-date = root_temp-stk-supp-line.shift-date
          .
        end.
        assign
                                                                                                              buf_temp-stk-supp-line.new-fact-qnty      = buf_temp-stk-supp-line.new-fact-qnty      + buf_temp-ot-supp-line.new-fact-qnty      - buf_temp-ot-supp-line.fact-qnty           buf_temp-stk-supp-line.new-sum-base       = buf_temp-stk-supp-line.new-sum-base       + buf_temp-ot-supp-line.new-sum-base       - buf_temp-ot-supp-line.sum-base            buf_temp-stk-supp-line.new-sum-rubl       = buf_temp-stk-supp-line.new-sum-rubl       + buf_temp-ot-supp-line.new-sum-rubl       - buf_temp-ot-supp-line.sum-rubl            buf_temp-stk-supp-line.new-vat-base       = buf_temp-stk-supp-line.new-vat-base       + buf_temp-ot-supp-line.new-vat-base       - buf_temp-ot-supp-line.vat-base            buf_temp-stk-supp-line.new-vat-rubl       = buf_temp-stk-supp-line.new-vat-rubl       + buf_temp-ot-supp-line.new-vat-rubl       - buf_temp-ot-supp-line.vat-rubl            buf_temp-stk-supp-line.new-slt-base       = buf_temp-stk-supp-line.new-slt-base       + buf_temp-ot-supp-line.new-slt-base       - buf_temp-ot-supp-line.slt-base            buf_temp-stk-supp-line.new-slt-rubl       = buf_temp-stk-supp-line.new-slt-rubl       + buf_temp-ot-supp-line.new-slt-rubl       - buf_temp-ot-supp-line.slt-rubl            buf_temp-stk-supp-line.new-road-tax-base  = buf_temp-stk-supp-line.new-road-tax-base  + buf_temp-ot-supp-line.new-road-tax-base  - buf_temp-ot-supp-line.road-tax-base       buf_temp-stk-supp-line.new-road-tax-rubl  = buf_temp-stk-supp-line.new-road-tax-rubl  + buf_temp-ot-supp-line.new-road-tax-rubl  - buf_temp-ot-supp-line.road-tax-rubl       buf_temp-stk-supp-line.new-excise-base    = buf_temp-stk-supp-line.new-excise-base    + buf_temp-ot-supp-line.new-excise-base    - buf_temp-ot-supp-line.excise-base         buf_temp-stk-supp-line.new-excise-rubl    = buf_temp-stk-supp-line.new-excise-rubl    + buf_temp-ot-supp-line.new-excise-rubl    - buf_temp-ot-supp-line.excise-rubl         buf_temp-stk-supp-line.new-transport-base = buf_temp-stk-supp-line.new-transport-base + buf_temp-ot-supp-line.new-transport-base - buf_temp-ot-supp-line.transport-base      buf_temp-stk-supp-line.new-transport-rubl = buf_temp-stk-supp-line.new-transport-rubl + buf_temp-ot-supp-line.new-transport-rubl - buf_temp-ot-supp-line.transport-rubl      buf_temp-stk-supp-line.new-other-base     = buf_temp-stk-supp-line.new-other-base     + buf_temp-ot-supp-line.new-other-base     - buf_temp-ot-supp-line.other-base          buf_temp-stk-supp-line.new-other-rubl     = buf_temp-stk-supp-line.new-other-rubl     + buf_temp-ot-supp-line.new-other-rubl     - buf_temp-ot-supp-line.other-rubl
        .
      end.
      if v-shift-on
      then do:
        for each root_temp-shift-stk-supp-line
          where root_temp-shift-stk-supp-line.obj-type  = buf_temp-ot-supp-line.obj-type
            and root_temp-shift-stk-supp-line.obj-code  = buf_temp-ot-supp-line.obj-code
            and root_temp-shift-stk-supp-line.cli-type  = buf_temp-ot-supp-line.cli-type
            and root_temp-shift-stk-supp-line.cli-code  = buf_temp-ot-supp-line.cli-code
            and root_temp-shift-stk-supp-line.artic     = buf_temp-ot-supp-line.artic
            and root_temp-shift-stk-supp-line.prod-type = buf_temp-ot-supp-line.prod-type
            and root_temp-shift-stk-supp-line.prod-code = buf_temp-ot-supp-line.prod-code
            and root_temp-shift-stk-supp-line.sum-type  = 'cost':U
            and root_temp-shift-stk-supp-line.cat-id    = '##':U
        on error undo, return error
        :
          find first buf_temp-shift-stk-supp-line
            where buf_temp-shift-stk-supp-line.obj-type   = buf_temp-ot-supp-line.obj-type
              and buf_temp-shift-stk-supp-line.obj-code   = buf_temp-ot-supp-line.obj-code
              and buf_temp-shift-stk-supp-line.cli-type   = buf_temp-ot-supp-line.cli-type
              and buf_temp-shift-stk-supp-line.cli-code   = buf_temp-ot-supp-line.cli-code
              and buf_temp-shift-stk-supp-line.artic      = buf_temp-ot-supp-line.artic
              and buf_temp-shift-stk-supp-line.prod-type  = buf_temp-ot-supp-line.prod-type
              and buf_temp-shift-stk-supp-line.prod-code  = buf_temp-ot-supp-line.prod-code
              and buf_temp-shift-stk-supp-line.fact-order = root_temp-shift-stk-supp-line.fact-order
              and buf_temp-shift-stk-supp-line.sum-type   = buf_temp-ot-supp-line.sum-type
              and buf_temp-shift-stk-supp-line.cat-id     = buf_temp-ot-supp-line.cat-id
            no-error .
          if not available buf_temp-shift-stk-supp-line
          then do:
            create buf_temp-shift-stk-supp-line .
            assign
              buf_temp-shift-stk-supp-line.obj-type   = buf_temp-ot-supp-line.obj-type
              buf_temp-shift-stk-supp-line.obj-code   = buf_temp-ot-supp-line.obj-code
              buf_temp-shift-stk-supp-line.cli-type   = buf_temp-ot-supp-line.cli-type
              buf_temp-shift-stk-supp-line.cli-code   = buf_temp-ot-supp-line.cli-code
              buf_temp-shift-stk-supp-line.artic      = buf_temp-ot-supp-line.artic
              buf_temp-shift-stk-supp-line.prod-type  = buf_temp-ot-supp-line.prod-type
              buf_temp-shift-stk-supp-line.prod-code  = buf_temp-ot-supp-line.prod-code
              buf_temp-shift-stk-supp-line.fact-order = root_temp-shift-stk-supp-line.fact-order
              buf_temp-shift-stk-supp-line.sum-type   = buf_temp-ot-supp-line.sum-type
              buf_temp-shift-stk-supp-line.cat-id     = buf_temp-ot-supp-line.cat-id
              buf_temp-shift-stk-supp-line.fact-date  = root_temp-shift-stk-supp-line.fact-date
              buf_temp-shift-stk-supp-line.shift-num  = root_temp-shift-stk-supp-line.shift-num
              buf_temp-shift-stk-supp-line.shift-date = root_temp-shift-stk-supp-line.shift-date
            .
          end.
          assign
                                                                                                                                    buf_temp-shift-stk-supp-line.new-fact-qnty      = buf_temp-shift-stk-supp-line.new-fact-qnty      + buf_temp-ot-supp-line.new-fact-qnty      - buf_temp-ot-supp-line.fact-qnty           buf_temp-shift-stk-supp-line.new-sum-base       = buf_temp-shift-stk-supp-line.new-sum-base       + buf_temp-ot-supp-line.new-sum-base       - buf_temp-ot-supp-line.sum-base            buf_temp-shift-stk-supp-line.new-sum-rubl       = buf_temp-shift-stk-supp-line.new-sum-rubl       + buf_temp-ot-supp-line.new-sum-rubl       - buf_temp-ot-supp-line.sum-rubl            buf_temp-shift-stk-supp-line.new-vat-base       = buf_temp-shift-stk-supp-line.new-vat-base       + buf_temp-ot-supp-line.new-vat-base       - buf_temp-ot-supp-line.vat-base            buf_temp-shift-stk-supp-line.new-vat-rubl       = buf_temp-shift-stk-supp-line.new-vat-rubl       + buf_temp-ot-supp-line.new-vat-rubl       - buf_temp-ot-supp-line.vat-rubl            buf_temp-shift-stk-supp-line.new-slt-base       = buf_temp-shift-stk-supp-line.new-slt-base       + buf_temp-ot-supp-line.new-slt-base       - buf_temp-ot-supp-line.slt-base            buf_temp-shift-stk-supp-line.new-slt-rubl       = buf_temp-shift-stk-supp-line.new-slt-rubl       + buf_temp-ot-supp-line.new-slt-rubl       - buf_temp-ot-supp-line.slt-rubl            buf_temp-shift-stk-supp-line.new-road-tax-base  = buf_temp-shift-stk-supp-line.new-road-tax-base  + buf_temp-ot-supp-line.new-road-tax-base  - buf_temp-ot-supp-line.road-tax-base       buf_temp-shift-stk-supp-line.new-road-tax-rubl  = buf_temp-shift-stk-supp-line.new-road-tax-rubl  + buf_temp-ot-supp-line.new-road-tax-rubl  - buf_temp-ot-supp-line.road-tax-rubl       buf_temp-shift-stk-supp-line.new-excise-base    = buf_temp-shift-stk-supp-line.new-excise-base    + buf_temp-ot-supp-line.new-excise-base    - buf_temp-ot-supp-line.excise-base         buf_temp-shift-stk-supp-line.new-excise-rubl    = buf_temp-shift-stk-supp-line.new-excise-rubl    + buf_temp-ot-supp-line.new-excise-rubl    - buf_temp-ot-supp-line.excise-rubl         buf_temp-shift-stk-supp-line.new-transport-base = buf_temp-shift-stk-supp-line.new-transport-base + buf_temp-ot-supp-line.new-transport-base - buf_temp-ot-supp-line.transport-base      buf_temp-shift-stk-supp-line.new-transport-rubl = buf_temp-shift-stk-supp-line.new-transport-rubl + buf_temp-ot-supp-line.new-transport-rubl - buf_temp-ot-supp-line.transport-rubl      buf_temp-shift-stk-supp-line.new-other-base     = buf_temp-shift-stk-supp-line.new-other-base     + buf_temp-ot-supp-line.new-other-base     - buf_temp-ot-supp-line.other-base          buf_temp-shift-stk-supp-line.new-other-rubl     = buf_temp-shift-stk-supp-line.new-other-rubl     + buf_temp-ot-supp-line.new-other-rubl     - buf_temp-ot-supp-line.other-rubl
          .
        end.
      end.
    end.
    for each buf_temp-ot-supp-line
      where buf_temp-ot-supp-line.sum-type = 'sale':U
        and (
                                          buf_temp-ot-supp-line.fact-qnty      <> buf_temp-ot-supp-line.new-fact-qnty        or    buf_temp-ot-supp-line.sum-base       <> buf_temp-ot-supp-line.new-sum-base         or    buf_temp-ot-supp-line.sum-rubl       <> buf_temp-ot-supp-line.new-sum-rubl         or    buf_temp-ot-supp-line.vat-base       <> buf_temp-ot-supp-line.new-vat-base         or    buf_temp-ot-supp-line.vat-rubl       <> buf_temp-ot-supp-line.new-vat-rubl         or    buf_temp-ot-supp-line.slt-base       <> buf_temp-ot-supp-line.new-slt-base         or    buf_temp-ot-supp-line.slt-rubl       <> buf_temp-ot-supp-line.new-slt-rubl         or    buf_temp-ot-supp-line.road-tax-base  <> buf_temp-ot-supp-line.new-road-tax-base    or    buf_temp-ot-supp-line.road-tax-rubl  <> buf_temp-ot-supp-line.new-road-tax-rubl    or    buf_temp-ot-supp-line.excise-base    <> buf_temp-ot-supp-line.new-excise-base      or    buf_temp-ot-supp-line.excise-rubl    <> buf_temp-ot-supp-line.new-excise-rubl      or    buf_temp-ot-supp-line.transport-base <> buf_temp-ot-supp-line.new-transport-base   or    buf_temp-ot-supp-line.transport-rubl <> buf_temp-ot-supp-line.new-transport-rubl   or    buf_temp-ot-supp-line.other-base     <> buf_temp-ot-supp-line.new-other-base       or    buf_temp-ot-supp-line.other-rubl     <> buf_temp-ot-supp-line.new-other-rubl
            )
    on error undo, return error
    :
      for each root_temp-stk-supp-line
        where root_temp-stk-supp-line.obj-type  = buf_temp-ot-supp-line.obj-type
          and root_temp-stk-supp-line.obj-code  = buf_temp-ot-supp-line.obj-code
          and root_temp-stk-supp-line.cli-type  = buf_temp-ot-supp-line.cli-type
          and root_temp-stk-supp-line.cli-code  = buf_temp-ot-supp-line.cli-code
          and root_temp-stk-supp-line.artic     = buf_temp-ot-supp-line.artic
          and root_temp-stk-supp-line.prod-type = buf_temp-ot-supp-line.prod-type
          and root_temp-stk-supp-line.prod-code = buf_temp-ot-supp-line.prod-code
          and root_temp-stk-supp-line.sum-type  = 'sadt':U + buf_trn-doc.ext-doc-type
          and root_temp-stk-supp-line.cat-id    = '##':U
      on error undo, return error
      :
        find first buf_temp-stk-supp-line
          where buf_temp-stk-supp-line.obj-type   = buf_temp-ot-supp-line.obj-type
            and buf_temp-stk-supp-line.obj-code   = buf_temp-ot-supp-line.obj-code
            and buf_temp-stk-supp-line.cli-type   = buf_temp-ot-supp-line.cli-type
            and buf_temp-stk-supp-line.cli-code   = buf_temp-ot-supp-line.cli-code
            and buf_temp-stk-supp-line.artic      = buf_temp-ot-supp-line.artic
            and buf_temp-stk-supp-line.prod-type  = buf_temp-ot-supp-line.prod-type
            and buf_temp-stk-supp-line.prod-code  = buf_temp-ot-supp-line.prod-code
            and buf_temp-stk-supp-line.fact-order = root_temp-stk-supp-line.fact-order
            and buf_temp-stk-supp-line.sum-type   = root_temp-stk-supp-line.sum-type
            and buf_temp-stk-supp-line.cat-id     = '##':U
          no-error .
        if not available buf_temp-stk-supp-line
        then do:
          create buf_temp-stk-supp-line .
          assign
            buf_temp-stk-supp-line.obj-type   = buf_temp-ot-supp-line.obj-type
            buf_temp-stk-supp-line.obj-code   = buf_temp-ot-supp-line.obj-code
            buf_temp-stk-supp-line.cli-type   = buf_temp-ot-supp-line.cli-type
            buf_temp-stk-supp-line.cli-code   = buf_temp-ot-supp-line.cli-code
            buf_temp-stk-supp-line.artic      = buf_temp-ot-supp-line.artic
            buf_temp-stk-supp-line.prod-type  = buf_temp-ot-supp-line.prod-type
            buf_temp-stk-supp-line.prod-code  = buf_temp-ot-supp-line.prod-code
            buf_temp-stk-supp-line.fact-order = root_temp-stk-supp-line.fact-order
            buf_temp-stk-supp-line.sum-type   = root_temp-stk-supp-line.sum-type
            buf_temp-stk-supp-line.cat-id     = '##':U
            buf_temp-stk-supp-line.fact-date  = root_temp-stk-supp-line.fact-date
            buf_temp-stk-supp-line.shift-num  = root_temp-stk-supp-line.shift-num
            buf_temp-stk-supp-line.shift-date = root_temp-stk-supp-line.shift-date
          .
        end.
        assign
                                                                                                              buf_temp-stk-supp-line.new-fact-qnty      = buf_temp-stk-supp-line.new-fact-qnty      + buf_temp-ot-supp-line.new-fact-qnty      - buf_temp-ot-supp-line.fact-qnty           buf_temp-stk-supp-line.new-sum-base       = buf_temp-stk-supp-line.new-sum-base       + buf_temp-ot-supp-line.new-sum-base       - buf_temp-ot-supp-line.sum-base            buf_temp-stk-supp-line.new-sum-rubl       = buf_temp-stk-supp-line.new-sum-rubl       + buf_temp-ot-supp-line.new-sum-rubl       - buf_temp-ot-supp-line.sum-rubl            buf_temp-stk-supp-line.new-vat-base       = buf_temp-stk-supp-line.new-vat-base       + buf_temp-ot-supp-line.new-vat-base       - buf_temp-ot-supp-line.vat-base            buf_temp-stk-supp-line.new-vat-rubl       = buf_temp-stk-supp-line.new-vat-rubl       + buf_temp-ot-supp-line.new-vat-rubl       - buf_temp-ot-supp-line.vat-rubl            buf_temp-stk-supp-line.new-slt-base       = buf_temp-stk-supp-line.new-slt-base       + buf_temp-ot-supp-line.new-slt-base       - buf_temp-ot-supp-line.slt-base            buf_temp-stk-supp-line.new-slt-rubl       = buf_temp-stk-supp-line.new-slt-rubl       + buf_temp-ot-supp-line.new-slt-rubl       - buf_temp-ot-supp-line.slt-rubl            buf_temp-stk-supp-line.new-road-tax-base  = buf_temp-stk-supp-line.new-road-tax-base  + buf_temp-ot-supp-line.new-road-tax-base  - buf_temp-ot-supp-line.road-tax-base       buf_temp-stk-supp-line.new-road-tax-rubl  = buf_temp-stk-supp-line.new-road-tax-rubl  + buf_temp-ot-supp-line.new-road-tax-rubl  - buf_temp-ot-supp-line.road-tax-rubl       buf_temp-stk-supp-line.new-excise-base    = buf_temp-stk-supp-line.new-excise-base    + buf_temp-ot-supp-line.new-excise-base    - buf_temp-ot-supp-line.excise-base         buf_temp-stk-supp-line.new-excise-rubl    = buf_temp-stk-supp-line.new-excise-rubl    + buf_temp-ot-supp-line.new-excise-rubl    - buf_temp-ot-supp-line.excise-rubl         buf_temp-stk-supp-line.new-transport-base = buf_temp-stk-supp-line.new-transport-base + buf_temp-ot-supp-line.new-transport-base - buf_temp-ot-supp-line.transport-base      buf_temp-stk-supp-line.new-transport-rubl = buf_temp-stk-supp-line.new-transport-rubl + buf_temp-ot-supp-line.new-transport-rubl - buf_temp-ot-supp-line.transport-rubl      buf_temp-stk-supp-line.new-other-base     = buf_temp-stk-supp-line.new-other-base     + buf_temp-ot-supp-line.new-other-base     - buf_temp-ot-supp-line.other-base          buf_temp-stk-supp-line.new-other-rubl     = buf_temp-stk-supp-line.new-other-rubl     + buf_temp-ot-supp-line.new-other-rubl     - buf_temp-ot-supp-line.other-rubl
        .
      end.
      if v-shift-on
      then do:
        for each root_temp-shift-stk-supp-line
          where root_temp-shift-stk-supp-line.obj-type  = buf_temp-ot-supp-line.obj-type
            and root_temp-shift-stk-supp-line.obj-code  = buf_temp-ot-supp-line.obj-code
            and root_temp-shift-stk-supp-line.cli-type  = buf_temp-ot-supp-line.cli-type
            and root_temp-shift-stk-supp-line.cli-code  = buf_temp-ot-supp-line.cli-code
            and root_temp-shift-stk-supp-line.artic     = buf_temp-ot-supp-line.artic
            and root_temp-shift-stk-supp-line.prod-type = buf_temp-ot-supp-line.prod-type
            and root_temp-shift-stk-supp-line.prod-code = buf_temp-ot-supp-line.prod-code
            and root_temp-shift-stk-supp-line.sum-type  = 'sadt':U + buf_trn-doc.ext-doc-type
            and root_temp-shift-stk-supp-line.cat-id    = '##':U
        on error undo, return error
        :
          find first buf_temp-shift-stk-supp-line
            where buf_temp-shift-stk-supp-line.obj-type   = buf_temp-ot-supp-line.obj-type
              and buf_temp-shift-stk-supp-line.obj-code   = buf_temp-ot-supp-line.obj-code
              and buf_temp-shift-stk-supp-line.cli-type   = buf_temp-ot-supp-line.cli-type
              and buf_temp-shift-stk-supp-line.cli-code   = buf_temp-ot-supp-line.cli-code
              and buf_temp-shift-stk-supp-line.artic      = buf_temp-ot-supp-line.artic
              and buf_temp-shift-stk-supp-line.prod-type  = buf_temp-ot-supp-line.prod-type
              and buf_temp-shift-stk-supp-line.prod-code  = buf_temp-ot-supp-line.prod-code
              and buf_temp-shift-stk-supp-line.fact-order = root_temp-shift-stk-supp-line.fact-order
              and buf_temp-shift-stk-supp-line.sum-type   = root_temp-shift-stk-supp-line.sum-type
              and buf_temp-shift-stk-supp-line.cat-id     = '##':U
            no-error .
          if not available buf_temp-shift-stk-supp-line
          then do:
            create buf_temp-shift-stk-supp-line .
            assign
              buf_temp-shift-stk-supp-line.obj-type   = buf_temp-ot-supp-line.obj-type
              buf_temp-shift-stk-supp-line.obj-code   = buf_temp-ot-supp-line.obj-code
              buf_temp-shift-stk-supp-line.cli-type   = buf_temp-ot-supp-line.cli-type
              buf_temp-shift-stk-supp-line.cli-code   = buf_temp-ot-supp-line.cli-code
              buf_temp-shift-stk-supp-line.artic      = buf_temp-ot-supp-line.artic
              buf_temp-shift-stk-supp-line.prod-type  = buf_temp-ot-supp-line.prod-type
              buf_temp-shift-stk-supp-line.prod-code  = buf_temp-ot-supp-line.prod-code
              buf_temp-shift-stk-supp-line.fact-order = root_temp-shift-stk-supp-line.fact-order
              buf_temp-shift-stk-supp-line.sum-type   = root_temp-shift-stk-supp-line.sum-type
              buf_temp-shift-stk-supp-line.cat-id     = '##':U
              buf_temp-shift-stk-supp-line.fact-date  = root_temp-shift-stk-supp-line.fact-date
              buf_temp-shift-stk-supp-line.shift-num  = root_temp-shift-stk-supp-line.shift-num
              buf_temp-shift-stk-supp-line.shift-date = root_temp-shift-stk-supp-line.shift-date
            .
          end.
          assign
                                                                                                                                    buf_temp-shift-stk-supp-line.new-fact-qnty      = buf_temp-shift-stk-supp-line.new-fact-qnty      + buf_temp-ot-supp-line.new-fact-qnty      - buf_temp-ot-supp-line.fact-qnty           buf_temp-shift-stk-supp-line.new-sum-base       = buf_temp-shift-stk-supp-line.new-sum-base       + buf_temp-ot-supp-line.new-sum-base       - buf_temp-ot-supp-line.sum-base            buf_temp-shift-stk-supp-line.new-sum-rubl       = buf_temp-shift-stk-supp-line.new-sum-rubl       + buf_temp-ot-supp-line.new-sum-rubl       - buf_temp-ot-supp-line.sum-rubl            buf_temp-shift-stk-supp-line.new-vat-base       = buf_temp-shift-stk-supp-line.new-vat-base       + buf_temp-ot-supp-line.new-vat-base       - buf_temp-ot-supp-line.vat-base            buf_temp-shift-stk-supp-line.new-vat-rubl       = buf_temp-shift-stk-supp-line.new-vat-rubl       + buf_temp-ot-supp-line.new-vat-rubl       - buf_temp-ot-supp-line.vat-rubl            buf_temp-shift-stk-supp-line.new-slt-base       = buf_temp-shift-stk-supp-line.new-slt-base       + buf_temp-ot-supp-line.new-slt-base       - buf_temp-ot-supp-line.slt-base            buf_temp-shift-stk-supp-line.new-slt-rubl       = buf_temp-shift-stk-supp-line.new-slt-rubl       + buf_temp-ot-supp-line.new-slt-rubl       - buf_temp-ot-supp-line.slt-rubl            buf_temp-shift-stk-supp-line.new-road-tax-base  = buf_temp-shift-stk-supp-line.new-road-tax-base  + buf_temp-ot-supp-line.new-road-tax-base  - buf_temp-ot-supp-line.road-tax-base       buf_temp-shift-stk-supp-line.new-road-tax-rubl  = buf_temp-shift-stk-supp-line.new-road-tax-rubl  + buf_temp-ot-supp-line.new-road-tax-rubl  - buf_temp-ot-supp-line.road-tax-rubl       buf_temp-shift-stk-supp-line.new-excise-base    = buf_temp-shift-stk-supp-line.new-excise-base    + buf_temp-ot-supp-line.new-excise-base    - buf_temp-ot-supp-line.excise-base         buf_temp-shift-stk-supp-line.new-excise-rubl    = buf_temp-shift-stk-supp-line.new-excise-rubl    + buf_temp-ot-supp-line.new-excise-rubl    - buf_temp-ot-supp-line.excise-rubl         buf_temp-shift-stk-supp-line.new-transport-base = buf_temp-shift-stk-supp-line.new-transport-base + buf_temp-ot-supp-line.new-transport-base - buf_temp-ot-supp-line.transport-base      buf_temp-shift-stk-supp-line.new-transport-rubl = buf_temp-shift-stk-supp-line.new-transport-rubl + buf_temp-ot-supp-line.new-transport-rubl - buf_temp-ot-supp-line.transport-rubl      buf_temp-shift-stk-supp-line.new-other-base     = buf_temp-shift-stk-supp-line.new-other-base     + buf_temp-ot-supp-line.new-other-base     - buf_temp-ot-supp-line.other-base          buf_temp-shift-stk-supp-line.new-other-rubl     = buf_temp-shift-stk-supp-line.new-other-rubl     + buf_temp-ot-supp-line.new-other-rubl     - buf_temp-ot-supp-line.other-rubl
          .
        end.
      end.
    end.
    for each buf_temp-ot-supp-line
      where buf_temp-ot-supp-line.sum-type = 'cost':U
        and (
                                          buf_temp-ot-supp-line.fact-qnty      <> buf_temp-ot-supp-line.new-fact-qnty        or    buf_temp-ot-supp-line.sum-base       <> buf_temp-ot-supp-line.new-sum-base         or    buf_temp-ot-supp-line.sum-rubl       <> buf_temp-ot-supp-line.new-sum-rubl         or    buf_temp-ot-supp-line.vat-base       <> buf_temp-ot-supp-line.new-vat-base         or    buf_temp-ot-supp-line.vat-rubl       <> buf_temp-ot-supp-line.new-vat-rubl         or    buf_temp-ot-supp-line.slt-base       <> buf_temp-ot-supp-line.new-slt-base         or    buf_temp-ot-supp-line.slt-rubl       <> buf_temp-ot-supp-line.new-slt-rubl         or    buf_temp-ot-supp-line.road-tax-base  <> buf_temp-ot-supp-line.new-road-tax-base    or    buf_temp-ot-supp-line.road-tax-rubl  <> buf_temp-ot-supp-line.new-road-tax-rubl    or    buf_temp-ot-supp-line.excise-base    <> buf_temp-ot-supp-line.new-excise-base      or    buf_temp-ot-supp-line.excise-rubl    <> buf_temp-ot-supp-line.new-excise-rubl      or    buf_temp-ot-supp-line.transport-base <> buf_temp-ot-supp-line.new-transport-base   or    buf_temp-ot-supp-line.transport-rubl <> buf_temp-ot-supp-line.new-transport-rubl   or    buf_temp-ot-supp-line.other-base     <> buf_temp-ot-supp-line.new-other-base       or    buf_temp-ot-supp-line.other-rubl     <> buf_temp-ot-supp-line.new-other-rubl
            )
    on error undo, return error
    :
      for each root_temp-stk-supp-line
        where root_temp-stk-supp-line.obj-type  = buf_temp-ot-supp-line.obj-type
          and root_temp-stk-supp-line.obj-code  = buf_temp-ot-supp-line.obj-code
          and root_temp-stk-supp-line.cli-type  = buf_temp-ot-supp-line.cli-type
          and root_temp-stk-supp-line.cli-code  = buf_temp-ot-supp-line.cli-code
          and root_temp-stk-supp-line.artic     = buf_temp-ot-supp-line.artic
          and root_temp-stk-supp-line.prod-type = buf_temp-ot-supp-line.prod-type
          and root_temp-stk-supp-line.prod-code = buf_temp-ot-supp-line.prod-code
          and root_temp-stk-supp-line.sum-type  = 'csdt':U + buf_trn-doc.ext-doc-type
          and root_temp-stk-supp-line.cat-id    = '##':U
      on error undo, return error
      :
        find first buf_temp-stk-supp-line
          where buf_temp-stk-supp-line.obj-type   = buf_temp-ot-supp-line.obj-type
            and buf_temp-stk-supp-line.obj-code   = buf_temp-ot-supp-line.obj-code
            and buf_temp-stk-supp-line.cli-type   = buf_temp-ot-supp-line.cli-type
            and buf_temp-stk-supp-line.cli-code   = buf_temp-ot-supp-line.cli-code
            and buf_temp-stk-supp-line.artic      = buf_temp-ot-supp-line.artic
            and buf_temp-stk-supp-line.prod-type  = buf_temp-ot-supp-line.prod-type
            and buf_temp-stk-supp-line.prod-code  = buf_temp-ot-supp-line.prod-code
            and buf_temp-stk-supp-line.fact-order = root_temp-stk-supp-line.fact-order
            and buf_temp-stk-supp-line.sum-type   = root_temp-stk-supp-line.sum-type
            and buf_temp-stk-supp-line.cat-id     = '##':U
          no-error .
        if not available buf_temp-stk-supp-line
        then do:
          create buf_temp-stk-supp-line .
          assign
            buf_temp-stk-supp-line.obj-type   = buf_temp-ot-supp-line.obj-type
            buf_temp-stk-supp-line.obj-code   = buf_temp-ot-supp-line.obj-code
            buf_temp-stk-supp-line.cli-type   = buf_temp-ot-supp-line.cli-type
            buf_temp-stk-supp-line.cli-code   = buf_temp-ot-supp-line.cli-code
            buf_temp-stk-supp-line.artic      = buf_temp-ot-supp-line.artic
            buf_temp-stk-supp-line.prod-type  = buf_temp-ot-supp-line.prod-type
            buf_temp-stk-supp-line.prod-code  = buf_temp-ot-supp-line.prod-code
            buf_temp-stk-supp-line.fact-order = root_temp-stk-supp-line.fact-order
            buf_temp-stk-supp-line.sum-type   = root_temp-stk-supp-line.sum-type
            buf_temp-stk-supp-line.cat-id     = '##':U
            buf_temp-stk-supp-line.fact-date  = root_temp-stk-supp-line.fact-date
            buf_temp-stk-supp-line.shift-num  = root_temp-stk-supp-line.shift-num
            buf_temp-stk-supp-line.shift-date = root_temp-stk-supp-line.shift-date
          .
        end.
        assign
                                                                                                              buf_temp-stk-supp-line.new-fact-qnty      = buf_temp-stk-supp-line.new-fact-qnty      + buf_temp-ot-supp-line.new-fact-qnty      - buf_temp-ot-supp-line.fact-qnty           buf_temp-stk-supp-line.new-sum-base       = buf_temp-stk-supp-line.new-sum-base       + buf_temp-ot-supp-line.new-sum-base       - buf_temp-ot-supp-line.sum-base            buf_temp-stk-supp-line.new-sum-rubl       = buf_temp-stk-supp-line.new-sum-rubl       + buf_temp-ot-supp-line.new-sum-rubl       - buf_temp-ot-supp-line.sum-rubl            buf_temp-stk-supp-line.new-vat-base       = buf_temp-stk-supp-line.new-vat-base       + buf_temp-ot-supp-line.new-vat-base       - buf_temp-ot-supp-line.vat-base            buf_temp-stk-supp-line.new-vat-rubl       = buf_temp-stk-supp-line.new-vat-rubl       + buf_temp-ot-supp-line.new-vat-rubl       - buf_temp-ot-supp-line.vat-rubl            buf_temp-stk-supp-line.new-slt-base       = buf_temp-stk-supp-line.new-slt-base       + buf_temp-ot-supp-line.new-slt-base       - buf_temp-ot-supp-line.slt-base            buf_temp-stk-supp-line.new-slt-rubl       = buf_temp-stk-supp-line.new-slt-rubl       + buf_temp-ot-supp-line.new-slt-rubl       - buf_temp-ot-supp-line.slt-rubl            buf_temp-stk-supp-line.new-road-tax-base  = buf_temp-stk-supp-line.new-road-tax-base  + buf_temp-ot-supp-line.new-road-tax-base  - buf_temp-ot-supp-line.road-tax-base       buf_temp-stk-supp-line.new-road-tax-rubl  = buf_temp-stk-supp-line.new-road-tax-rubl  + buf_temp-ot-supp-line.new-road-tax-rubl  - buf_temp-ot-supp-line.road-tax-rubl       buf_temp-stk-supp-line.new-excise-base    = buf_temp-stk-supp-line.new-excise-base    + buf_temp-ot-supp-line.new-excise-base    - buf_temp-ot-supp-line.excise-base         buf_temp-stk-supp-line.new-excise-rubl    = buf_temp-stk-supp-line.new-excise-rubl    + buf_temp-ot-supp-line.new-excise-rubl    - buf_temp-ot-supp-line.excise-rubl         buf_temp-stk-supp-line.new-transport-base = buf_temp-stk-supp-line.new-transport-base + buf_temp-ot-supp-line.new-transport-base - buf_temp-ot-supp-line.transport-base      buf_temp-stk-supp-line.new-transport-rubl = buf_temp-stk-supp-line.new-transport-rubl + buf_temp-ot-supp-line.new-transport-rubl - buf_temp-ot-supp-line.transport-rubl      buf_temp-stk-supp-line.new-other-base     = buf_temp-stk-supp-line.new-other-base     + buf_temp-ot-supp-line.new-other-base     - buf_temp-ot-supp-line.other-base          buf_temp-stk-supp-line.new-other-rubl     = buf_temp-stk-supp-line.new-other-rubl     + buf_temp-ot-supp-line.new-other-rubl     - buf_temp-ot-supp-line.other-rubl
        .
      end.
      if v-shift-on
      then do:
        for each root_temp-shift-stk-supp-line
          where root_temp-shift-stk-supp-line.obj-type  = buf_temp-ot-supp-line.obj-type
            and root_temp-shift-stk-supp-line.obj-code  = buf_temp-ot-supp-line.obj-code
            and root_temp-shift-stk-supp-line.cli-type  = buf_temp-ot-supp-line.cli-type
            and root_temp-shift-stk-supp-line.cli-code  = buf_temp-ot-supp-line.cli-code
            and root_temp-shift-stk-supp-line.artic     = buf_temp-ot-supp-line.artic
            and root_temp-shift-stk-supp-line.prod-type = buf_temp-ot-supp-line.prod-type
            and root_temp-shift-stk-supp-line.prod-code = buf_temp-ot-supp-line.prod-code
            and root_temp-shift-stk-supp-line.sum-type  = 'csdt':U + buf_trn-doc.ext-doc-type
            and root_temp-shift-stk-supp-line.cat-id    = '##':U
        on error undo, return error
        :
          find first buf_temp-shift-stk-supp-line
            where buf_temp-shift-stk-supp-line.obj-type   = buf_temp-ot-supp-line.obj-type
              and buf_temp-shift-stk-supp-line.obj-code   = buf_temp-ot-supp-line.obj-code
              and buf_temp-shift-stk-supp-line.cli-type   = buf_temp-ot-supp-line.cli-type
              and buf_temp-shift-stk-supp-line.cli-code   = buf_temp-ot-supp-line.cli-code
              and buf_temp-shift-stk-supp-line.artic      = buf_temp-ot-supp-line.artic
              and buf_temp-shift-stk-supp-line.prod-type  = buf_temp-ot-supp-line.prod-type
              and buf_temp-shift-stk-supp-line.prod-code  = buf_temp-ot-supp-line.prod-code
              and buf_temp-shift-stk-supp-line.fact-order = root_temp-shift-stk-supp-line.fact-order
              and buf_temp-shift-stk-supp-line.sum-type   = root_temp-shift-stk-supp-line.sum-type
              and buf_temp-shift-stk-supp-line.cat-id     = '##':U
            no-error .
          if not available buf_temp-shift-stk-supp-line
          then do:
            create buf_temp-shift-stk-supp-line .
            assign
              buf_temp-shift-stk-supp-line.obj-type   = buf_temp-ot-supp-line.obj-type
              buf_temp-shift-stk-supp-line.obj-code   = buf_temp-ot-supp-line.obj-code
              buf_temp-shift-stk-supp-line.cli-type   = buf_temp-ot-supp-line.cli-type
              buf_temp-shift-stk-supp-line.cli-code   = buf_temp-ot-supp-line.cli-code
              buf_temp-shift-stk-supp-line.artic      = buf_temp-ot-supp-line.artic
              buf_temp-shift-stk-supp-line.prod-type  = buf_temp-ot-supp-line.prod-type
              buf_temp-shift-stk-supp-line.prod-code  = buf_temp-ot-supp-line.prod-code
              buf_temp-shift-stk-supp-line.fact-order = root_temp-shift-stk-supp-line.fact-order
              buf_temp-shift-stk-supp-line.sum-type   = root_temp-shift-stk-supp-line.sum-type
              buf_temp-shift-stk-supp-line.cat-id     = '##':U
              buf_temp-shift-stk-supp-line.fact-date  = root_temp-shift-stk-supp-line.fact-date
              buf_temp-shift-stk-supp-line.shift-num  = root_temp-shift-stk-supp-line.shift-num
              buf_temp-shift-stk-supp-line.shift-date = root_temp-shift-stk-supp-line.shift-date
            .
          end.
          assign
                                                                                                                                    buf_temp-shift-stk-supp-line.new-fact-qnty      = buf_temp-shift-stk-supp-line.new-fact-qnty      + buf_temp-ot-supp-line.new-fact-qnty      - buf_temp-ot-supp-line.fact-qnty           buf_temp-shift-stk-supp-line.new-sum-base       = buf_temp-shift-stk-supp-line.new-sum-base       + buf_temp-ot-supp-line.new-sum-base       - buf_temp-ot-supp-line.sum-base            buf_temp-shift-stk-supp-line.new-sum-rubl       = buf_temp-shift-stk-supp-line.new-sum-rubl       + buf_temp-ot-supp-line.new-sum-rubl       - buf_temp-ot-supp-line.sum-rubl            buf_temp-shift-stk-supp-line.new-vat-base       = buf_temp-shift-stk-supp-line.new-vat-base       + buf_temp-ot-supp-line.new-vat-base       - buf_temp-ot-supp-line.vat-base            buf_temp-shift-stk-supp-line.new-vat-rubl       = buf_temp-shift-stk-supp-line.new-vat-rubl       + buf_temp-ot-supp-line.new-vat-rubl       - buf_temp-ot-supp-line.vat-rubl            buf_temp-shift-stk-supp-line.new-slt-base       = buf_temp-shift-stk-supp-line.new-slt-base       + buf_temp-ot-supp-line.new-slt-base       - buf_temp-ot-supp-line.slt-base            buf_temp-shift-stk-supp-line.new-slt-rubl       = buf_temp-shift-stk-supp-line.new-slt-rubl       + buf_temp-ot-supp-line.new-slt-rubl       - buf_temp-ot-supp-line.slt-rubl            buf_temp-shift-stk-supp-line.new-road-tax-base  = buf_temp-shift-stk-supp-line.new-road-tax-base  + buf_temp-ot-supp-line.new-road-tax-base  - buf_temp-ot-supp-line.road-tax-base       buf_temp-shift-stk-supp-line.new-road-tax-rubl  = buf_temp-shift-stk-supp-line.new-road-tax-rubl  + buf_temp-ot-supp-line.new-road-tax-rubl  - buf_temp-ot-supp-line.road-tax-rubl       buf_temp-shift-stk-supp-line.new-excise-base    = buf_temp-shift-stk-supp-line.new-excise-base    + buf_temp-ot-supp-line.new-excise-base    - buf_temp-ot-supp-line.excise-base         buf_temp-shift-stk-supp-line.new-excise-rubl    = buf_temp-shift-stk-supp-line.new-excise-rubl    + buf_temp-ot-supp-line.new-excise-rubl    - buf_temp-ot-supp-line.excise-rubl         buf_temp-shift-stk-supp-line.new-transport-base = buf_temp-shift-stk-supp-line.new-transport-base + buf_temp-ot-supp-line.new-transport-base - buf_temp-ot-supp-line.transport-base      buf_temp-shift-stk-supp-line.new-transport-rubl = buf_temp-shift-stk-supp-line.new-transport-rubl + buf_temp-ot-supp-line.new-transport-rubl - buf_temp-ot-supp-line.transport-rubl      buf_temp-shift-stk-supp-line.new-other-base     = buf_temp-shift-stk-supp-line.new-other-base     + buf_temp-ot-supp-line.new-other-base     - buf_temp-ot-supp-line.other-base          buf_temp-shift-stk-supp-line.new-other-rubl     = buf_temp-shift-stk-supp-line.new-other-rubl     + buf_temp-ot-supp-line.new-other-rubl     - buf_temp-ot-supp-line.other-rubl
          .
        end.
      end.
    end.
  end.
end procedure.
procedure store-ot-table :
  define buffer buf_temp-ot-supp-tot for temp-ot-supp-tot .
  define buffer buf_ot-supp-tot for ub.ot-supp-tot .
  define buffer buf_temp-ot-supp-line for temp-ot-supp-line .
  define buffer buf_ot-supp-line for ub.ot-supp-line .
  do
  on error undo, return error
  :
    define variable l-need-create-record             as logical no-undo .
    for each buf_temp-ot-supp-tot
    on error undo, return error
    :
      if
                              buf_temp-ot-supp-tot.new-fact-qnty      = ? or    buf_temp-ot-supp-tot.new-sum-base       = ? or    buf_temp-ot-supp-tot.new-sum-rubl       = ? or    buf_temp-ot-supp-tot.new-vat-base       = ? or    buf_temp-ot-supp-tot.new-vat-rubl       = ? or    buf_temp-ot-supp-tot.new-slt-base       = ? or    buf_temp-ot-supp-tot.new-slt-rubl       = ? or    buf_temp-ot-supp-tot.new-road-tax-base  = ? or    buf_temp-ot-supp-tot.new-road-tax-rubl  = ? or    buf_temp-ot-supp-tot.new-excise-base    = ? or    buf_temp-ot-supp-tot.new-excise-rubl    = ? or    buf_temp-ot-supp-tot.new-transport-base = ? or    buf_temp-ot-supp-tot.new-transport-rubl = ? or    buf_temp-ot-supp-tot.new-other-base     = ? or    buf_temp-ot-supp-tot.new-other-rubl     = ?
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "При расчета складского архива по поставщикам получено неопределенное значение" skip
          "Документ" p-doc-code skip
          "Дополнительная информация выведена в файл ah-csptr.err" skip
          view-as alert-box error .
        output stream slog to ah-csptr.err append .
        export stream slog "ot-supp-tot" .
        export stream slog buf_temp-ot-supp-tot .
        output stream slog close .
        undo, return error .
      end.
      if
                                          buf_temp-ot-supp-tot.fact-qnty      <> buf_temp-ot-supp-tot.new-fact-qnty        or    buf_temp-ot-supp-tot.sum-base       <> buf_temp-ot-supp-tot.new-sum-base         or    buf_temp-ot-supp-tot.sum-rubl       <> buf_temp-ot-supp-tot.new-sum-rubl         or    buf_temp-ot-supp-tot.vat-base       <> buf_temp-ot-supp-tot.new-vat-base         or    buf_temp-ot-supp-tot.vat-rubl       <> buf_temp-ot-supp-tot.new-vat-rubl         or    buf_temp-ot-supp-tot.slt-base       <> buf_temp-ot-supp-tot.new-slt-base         or    buf_temp-ot-supp-tot.slt-rubl       <> buf_temp-ot-supp-tot.new-slt-rubl         or    buf_temp-ot-supp-tot.road-tax-base  <> buf_temp-ot-supp-tot.new-road-tax-base    or    buf_temp-ot-supp-tot.road-tax-rubl  <> buf_temp-ot-supp-tot.new-road-tax-rubl    or    buf_temp-ot-supp-tot.excise-base    <> buf_temp-ot-supp-tot.new-excise-base      or    buf_temp-ot-supp-tot.excise-rubl    <> buf_temp-ot-supp-tot.new-excise-rubl      or    buf_temp-ot-supp-tot.transport-base <> buf_temp-ot-supp-tot.new-transport-base   or    buf_temp-ot-supp-tot.transport-rubl <> buf_temp-ot-supp-tot.new-transport-rubl   or    buf_temp-ot-supp-tot.other-base     <> buf_temp-ot-supp-tot.new-other-base       or    buf_temp-ot-supp-tot.other-rubl     <> buf_temp-ot-supp-tot.new-other-rubl
      then do:
        assign
          l-need-create-record =
                                                                                                                                                                          buf_temp-ot-supp-tot.new-fact-qnty      <> 0 or    buf_temp-ot-supp-tot.new-sum-base       <> 0 or    buf_temp-ot-supp-tot.new-sum-rubl       <> 0 or    buf_temp-ot-supp-tot.new-vat-base       <> 0 or    buf_temp-ot-supp-tot.new-vat-rubl       <> 0 or    buf_temp-ot-supp-tot.new-slt-base       <> 0 or    buf_temp-ot-supp-tot.new-slt-rubl       <> 0 or    buf_temp-ot-supp-tot.new-road-tax-base  <> 0 or    buf_temp-ot-supp-tot.new-road-tax-rubl  <> 0 or    buf_temp-ot-supp-tot.new-excise-base    <> 0 or    buf_temp-ot-supp-tot.new-excise-rubl    <> 0 or    buf_temp-ot-supp-tot.new-transport-base <> 0 or    buf_temp-ot-supp-tot.new-transport-rubl <> 0 or    buf_temp-ot-supp-tot.new-other-base     <> 0 or    buf_temp-ot-supp-tot.new-other-rubl     <> 0
        .
        find first buf_ot-supp-tot exclusive-lock
          where buf_ot-supp-tot.doc-code = buf_temp-ot-supp-tot.doc-code
            and buf_ot-supp-tot.cli-type = buf_temp-ot-supp-tot.cli-type
            and buf_ot-supp-tot.cli-code = buf_temp-ot-supp-tot.cli-code
            and buf_ot-supp-tot.sum-type = buf_temp-ot-supp-tot.sum-type
            and buf_ot-supp-tot.cat-id   = buf_temp-ot-supp-tot.cat-id
          no-error .
        if l-need-create-record
        then do:
          if not available buf_ot-supp-tot
          then do:
            create buf_ot-supp-tot .
          end.
                              assign
            buf_ot-supp-tot.doc-code     = buf_temp-ot-supp-tot.doc-code       buf_ot-supp-tot.cli-type     = buf_temp-ot-supp-tot.cli-type       buf_ot-supp-tot.cli-code     = buf_temp-ot-supp-tot.cli-code       buf_ot-supp-tot.sum-type     = buf_temp-ot-supp-tot.sum-type       buf_ot-supp-tot.cat-id       = buf_temp-ot-supp-tot.cat-id         buf_ot-supp-tot.ext-doc-type = buf_temp-ot-supp-tot.ext-doc-type   buf_ot-supp-tot.obj-type     = buf_temp-ot-supp-tot.obj-type       buf_ot-supp-tot.obj-code     = buf_temp-ot-supp-tot.obj-code       buf_ot-supp-tot.fact-order   = buf_temp-ot-supp-tot.fact-order
          .
          assign
                                                                                    buf_ot-supp-tot.fact-qnty      = buf_temp-ot-supp-tot.new-fact-qnty            buf_ot-supp-tot.sum-base       = buf_temp-ot-supp-tot.new-sum-base             buf_ot-supp-tot.sum-rubl       = buf_temp-ot-supp-tot.new-sum-rubl             buf_ot-supp-tot.vat-base       = buf_temp-ot-supp-tot.new-vat-base             buf_ot-supp-tot.vat-rubl       = buf_temp-ot-supp-tot.new-vat-rubl             buf_ot-supp-tot.slt-base       = buf_temp-ot-supp-tot.new-slt-base             buf_ot-supp-tot.slt-rubl       = buf_temp-ot-supp-tot.new-slt-rubl             buf_ot-supp-tot.road-tax-base  = buf_temp-ot-supp-tot.new-road-tax-base        buf_ot-supp-tot.road-tax-rubl  = buf_temp-ot-supp-tot.new-road-tax-rubl        buf_ot-supp-tot.excise-base    = buf_temp-ot-supp-tot.new-excise-base          buf_ot-supp-tot.excise-rubl    = buf_temp-ot-supp-tot.new-excise-rubl          buf_ot-supp-tot.transport-base = buf_temp-ot-supp-tot.new-transport-base       buf_ot-supp-tot.transport-rubl = buf_temp-ot-supp-tot.new-transport-rubl       buf_ot-supp-tot.other-base     = buf_temp-ot-supp-tot.new-other-base           buf_ot-supp-tot.other-rubl     = buf_temp-ot-supp-tot.new-other-rubl
          .
        end.
        else do:
          if available buf_ot-supp-tot
          then do:
            delete buf_ot-supp-tot .
          end.
        end.
      end.
    end.
    for each buf_temp-ot-supp-line
    on error undo, return error
    :
      if
                                          buf_temp-ot-supp-line.fact-qnty      <> buf_temp-ot-supp-line.new-fact-qnty        or    buf_temp-ot-supp-line.sum-base       <> buf_temp-ot-supp-line.new-sum-base         or    buf_temp-ot-supp-line.sum-rubl       <> buf_temp-ot-supp-line.new-sum-rubl         or    buf_temp-ot-supp-line.vat-base       <> buf_temp-ot-supp-line.new-vat-base         or    buf_temp-ot-supp-line.vat-rubl       <> buf_temp-ot-supp-line.new-vat-rubl         or    buf_temp-ot-supp-line.slt-base       <> buf_temp-ot-supp-line.new-slt-base         or    buf_temp-ot-supp-line.slt-rubl       <> buf_temp-ot-supp-line.new-slt-rubl         or    buf_temp-ot-supp-line.road-tax-base  <> buf_temp-ot-supp-line.new-road-tax-base    or    buf_temp-ot-supp-line.road-tax-rubl  <> buf_temp-ot-supp-line.new-road-tax-rubl    or    buf_temp-ot-supp-line.excise-base    <> buf_temp-ot-supp-line.new-excise-base      or    buf_temp-ot-supp-line.excise-rubl    <> buf_temp-ot-supp-line.new-excise-rubl      or    buf_temp-ot-supp-line.transport-base <> buf_temp-ot-supp-line.new-transport-base   or    buf_temp-ot-supp-line.transport-rubl <> buf_temp-ot-supp-line.new-transport-rubl   or    buf_temp-ot-supp-line.other-base     <> buf_temp-ot-supp-line.new-other-base       or    buf_temp-ot-supp-line.other-rubl     <> buf_temp-ot-supp-line.new-other-rubl
      then do:
        assign
          l-need-create-record =
                                                                                                                                                                          buf_temp-ot-supp-line.new-fact-qnty      <> 0 or    buf_temp-ot-supp-line.new-sum-base       <> 0 or    buf_temp-ot-supp-line.new-sum-rubl       <> 0 or    buf_temp-ot-supp-line.new-vat-base       <> 0 or    buf_temp-ot-supp-line.new-vat-rubl       <> 0 or    buf_temp-ot-supp-line.new-slt-base       <> 0 or    buf_temp-ot-supp-line.new-slt-rubl       <> 0 or    buf_temp-ot-supp-line.new-road-tax-base  <> 0 or    buf_temp-ot-supp-line.new-road-tax-rubl  <> 0 or    buf_temp-ot-supp-line.new-excise-base    <> 0 or    buf_temp-ot-supp-line.new-excise-rubl    <> 0 or    buf_temp-ot-supp-line.new-transport-base <> 0 or    buf_temp-ot-supp-line.new-transport-rubl <> 0 or    buf_temp-ot-supp-line.new-other-base     <> 0 or    buf_temp-ot-supp-line.new-other-rubl     <> 0
        .
        find first buf_ot-supp-line exclusive-lock
          where buf_ot-supp-line.doc-code  = buf_temp-ot-supp-line.doc-code
            and buf_ot-supp-line.cli-type  = buf_temp-ot-supp-line.cli-type
            and buf_ot-supp-line.cli-code  = buf_temp-ot-supp-line.cli-code
            and buf_ot-supp-line.artic     = buf_temp-ot-supp-line.artic
            and buf_ot-supp-line.prod-type = buf_temp-ot-supp-line.prod-type
            and buf_ot-supp-line.prod-code = buf_temp-ot-supp-line.prod-code
            and buf_ot-supp-line.sum-type  = buf_temp-ot-supp-line.sum-type
            and buf_ot-supp-line.cat-id    = buf_temp-ot-supp-line.cat-id
          no-error .
        if l-need-create-record
        then do:
          if not available buf_ot-supp-line
          then do:
            create buf_ot-supp-line .
          end.
                              assign
            buf_ot-supp-line.doc-code     = buf_temp-ot-supp-line.doc-code       buf_ot-supp-line.cli-type     = buf_temp-ot-supp-line.cli-type       buf_ot-supp-line.cli-code     = buf_temp-ot-supp-line.cli-code       buf_ot-supp-line.artic        = buf_temp-ot-supp-line.artic          buf_ot-supp-line.prod-type    = buf_temp-ot-supp-line.prod-type      buf_ot-supp-line.prod-code    = buf_temp-ot-supp-line.prod-code      buf_ot-supp-line.sum-type     = buf_temp-ot-supp-line.sum-type       buf_ot-supp-line.cat-id       = buf_temp-ot-supp-line.cat-id         buf_ot-supp-line.ext-doc-type = buf_temp-ot-supp-line.ext-doc-type   buf_ot-supp-line.obj-type     = buf_temp-ot-supp-line.obj-type       buf_ot-supp-line.obj-code     = buf_temp-ot-supp-line.obj-code       buf_ot-supp-line.fact-order   = buf_temp-ot-supp-line.fact-order
          .
          assign
                                                                                    buf_ot-supp-line.fact-qnty      = buf_temp-ot-supp-line.new-fact-qnty            buf_ot-supp-line.sum-base       = buf_temp-ot-supp-line.new-sum-base             buf_ot-supp-line.sum-rubl       = buf_temp-ot-supp-line.new-sum-rubl             buf_ot-supp-line.vat-base       = buf_temp-ot-supp-line.new-vat-base             buf_ot-supp-line.vat-rubl       = buf_temp-ot-supp-line.new-vat-rubl             buf_ot-supp-line.slt-base       = buf_temp-ot-supp-line.new-slt-base             buf_ot-supp-line.slt-rubl       = buf_temp-ot-supp-line.new-slt-rubl             buf_ot-supp-line.road-tax-base  = buf_temp-ot-supp-line.new-road-tax-base        buf_ot-supp-line.road-tax-rubl  = buf_temp-ot-supp-line.new-road-tax-rubl        buf_ot-supp-line.excise-base    = buf_temp-ot-supp-line.new-excise-base          buf_ot-supp-line.excise-rubl    = buf_temp-ot-supp-line.new-excise-rubl          buf_ot-supp-line.transport-base = buf_temp-ot-supp-line.new-transport-base       buf_ot-supp-line.transport-rubl = buf_temp-ot-supp-line.new-transport-rubl       buf_ot-supp-line.other-base     = buf_temp-ot-supp-line.new-other-base           buf_ot-supp-line.other-rubl     = buf_temp-ot-supp-line.new-other-rubl
          .
        end.
        else do:
          if available buf_ot-supp-line
          then do:
            delete buf_ot-supp-line .
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure store-stk-temp-table :
  define buffer buf_temp-stk-supp-tot for temp-stk-supp-tot .
  define buffer buf_stk-supp-tot for ub.stk-supp-tot .
  define buffer buf_temp-stk-supp-line for temp-stk-supp-line .
  define buffer buf_stk-supp-line for ub.stk-supp-line .
  do
  on error undo, return error
  :
    define variable l-need-create-record             as logical no-undo .
    for each buf_temp-stk-supp-tot
    on error undo, return error
    :
      if
                                          buf_temp-stk-supp-tot.fact-qnty      <> buf_temp-stk-supp-tot.new-fact-qnty        or    buf_temp-stk-supp-tot.sum-base       <> buf_temp-stk-supp-tot.new-sum-base         or    buf_temp-stk-supp-tot.sum-rubl       <> buf_temp-stk-supp-tot.new-sum-rubl         or    buf_temp-stk-supp-tot.vat-base       <> buf_temp-stk-supp-tot.new-vat-base         or    buf_temp-stk-supp-tot.vat-rubl       <> buf_temp-stk-supp-tot.new-vat-rubl         or    buf_temp-stk-supp-tot.slt-base       <> buf_temp-stk-supp-tot.new-slt-base         or    buf_temp-stk-supp-tot.slt-rubl       <> buf_temp-stk-supp-tot.new-slt-rubl         or    buf_temp-stk-supp-tot.road-tax-base  <> buf_temp-stk-supp-tot.new-road-tax-base    or    buf_temp-stk-supp-tot.road-tax-rubl  <> buf_temp-stk-supp-tot.new-road-tax-rubl    or    buf_temp-stk-supp-tot.excise-base    <> buf_temp-stk-supp-tot.new-excise-base      or    buf_temp-stk-supp-tot.excise-rubl    <> buf_temp-stk-supp-tot.new-excise-rubl      or    buf_temp-stk-supp-tot.transport-base <> buf_temp-stk-supp-tot.new-transport-base   or    buf_temp-stk-supp-tot.transport-rubl <> buf_temp-stk-supp-tot.new-transport-rubl   or    buf_temp-stk-supp-tot.other-base     <> buf_temp-stk-supp-tot.new-other-base       or    buf_temp-stk-supp-tot.other-rubl     <> buf_temp-stk-supp-tot.new-other-rubl
      or ( lookup(buf_temp-stk-supp-tot.sum-type
                 ,'sale':U + "," + 'cost':U
                 ) > 0
           and buf_temp-stk-supp-tot.cat-id = '##':U
         )
      or ( buf_temp-stk-supp-tot.sum-type begins 'sadt':U )
      or ( buf_temp-stk-supp-tot.sum-type begins 'csdt':U )
      then do:
        assign
          l-need-create-record =
                                                                                                                                                                          buf_temp-stk-supp-tot.new-fact-qnty      <> 0 or    buf_temp-stk-supp-tot.new-sum-base       <> 0 or    buf_temp-stk-supp-tot.new-sum-rubl       <> 0 or    buf_temp-stk-supp-tot.new-vat-base       <> 0 or    buf_temp-stk-supp-tot.new-vat-rubl       <> 0 or    buf_temp-stk-supp-tot.new-slt-base       <> 0 or    buf_temp-stk-supp-tot.new-slt-rubl       <> 0 or    buf_temp-stk-supp-tot.new-road-tax-base  <> 0 or    buf_temp-stk-supp-tot.new-road-tax-rubl  <> 0 or    buf_temp-stk-supp-tot.new-excise-base    <> 0 or    buf_temp-stk-supp-tot.new-excise-rubl    <> 0 or    buf_temp-stk-supp-tot.new-transport-base <> 0 or    buf_temp-stk-supp-tot.new-transport-rubl <> 0 or    buf_temp-stk-supp-tot.new-other-base     <> 0 or    buf_temp-stk-supp-tot.new-other-rubl     <> 0
                              or ( buf_temp-stk-supp-tot.cat-id = '##':U )
        .
        find first buf_stk-supp-tot exclusive-lock
          where buf_stk-supp-tot.obj-type   = buf_temp-stk-supp-tot.obj-type
            and buf_stk-supp-tot.obj-code   = buf_temp-stk-supp-tot.obj-code
            and buf_stk-supp-tot.cli-type   = buf_temp-stk-supp-tot.cli-type
            and buf_stk-supp-tot.cli-code   = buf_temp-stk-supp-tot.cli-code
            and buf_stk-supp-tot.fact-order = buf_temp-stk-supp-tot.fact-order
            and buf_stk-supp-tot.sum-type   = buf_temp-stk-supp-tot.sum-type
            and buf_stk-supp-tot.cat-id     = buf_temp-stk-supp-tot.cat-id
          no-error .
        if l-need-create-record
        then do:
          if not available buf_stk-supp-tot
          then do:
            create buf_stk-supp-tot .
          end.
                              assign
            buf_stk-supp-tot.obj-type     = buf_temp-stk-supp-tot.obj-type     buf_stk-supp-tot.obj-code     = buf_temp-stk-supp-tot.obj-code     buf_stk-supp-tot.cli-type     = buf_temp-stk-supp-tot.cli-type     buf_stk-supp-tot.cli-code     = buf_temp-stk-supp-tot.cli-code     buf_stk-supp-tot.fact-order   = buf_temp-stk-supp-tot.fact-order   buf_stk-supp-tot.sum-type     = buf_temp-stk-supp-tot.sum-type     buf_stk-supp-tot.cat-id       = buf_temp-stk-supp-tot.cat-id       buf_stk-supp-tot.fact-date    = buf_temp-stk-supp-tot.fact-date    buf_stk-supp-tot.shift-num    = buf_temp-stk-supp-tot.shift-num    buf_stk-supp-tot.shift-date   = buf_temp-stk-supp-tot.shift-date
          .
          assign
                                                                                    buf_stk-supp-tot.fact-qnty      = buf_temp-stk-supp-tot.new-fact-qnty            buf_stk-supp-tot.sum-base       = buf_temp-stk-supp-tot.new-sum-base             buf_stk-supp-tot.sum-rubl       = buf_temp-stk-supp-tot.new-sum-rubl             buf_stk-supp-tot.vat-base       = buf_temp-stk-supp-tot.new-vat-base             buf_stk-supp-tot.vat-rubl       = buf_temp-stk-supp-tot.new-vat-rubl             buf_stk-supp-tot.slt-base       = buf_temp-stk-supp-tot.new-slt-base             buf_stk-supp-tot.slt-rubl       = buf_temp-stk-supp-tot.new-slt-rubl             buf_stk-supp-tot.road-tax-base  = buf_temp-stk-supp-tot.new-road-tax-base        buf_stk-supp-tot.road-tax-rubl  = buf_temp-stk-supp-tot.new-road-tax-rubl        buf_stk-supp-tot.excise-base    = buf_temp-stk-supp-tot.new-excise-base          buf_stk-supp-tot.excise-rubl    = buf_temp-stk-supp-tot.new-excise-rubl          buf_stk-supp-tot.transport-base = buf_temp-stk-supp-tot.new-transport-base       buf_stk-supp-tot.transport-rubl = buf_temp-stk-supp-tot.new-transport-rubl       buf_stk-supp-tot.other-base     = buf_temp-stk-supp-tot.new-other-base           buf_stk-supp-tot.other-rubl     = buf_temp-stk-supp-tot.new-other-rubl
          .
        end.
        else do:
          if available buf_stk-supp-tot
          then do:
            delete buf_stk-supp-tot .
          end.
        end.
      end.
    end.
    for each buf_temp-stk-supp-line
    on error undo, return error
    :
      if
                                          buf_temp-stk-supp-line.fact-qnty      <> buf_temp-stk-supp-line.new-fact-qnty        or    buf_temp-stk-supp-line.sum-base       <> buf_temp-stk-supp-line.new-sum-base         or    buf_temp-stk-supp-line.sum-rubl       <> buf_temp-stk-supp-line.new-sum-rubl         or    buf_temp-stk-supp-line.vat-base       <> buf_temp-stk-supp-line.new-vat-base         or    buf_temp-stk-supp-line.vat-rubl       <> buf_temp-stk-supp-line.new-vat-rubl         or    buf_temp-stk-supp-line.slt-base       <> buf_temp-stk-supp-line.new-slt-base         or    buf_temp-stk-supp-line.slt-rubl       <> buf_temp-stk-supp-line.new-slt-rubl         or    buf_temp-stk-supp-line.road-tax-base  <> buf_temp-stk-supp-line.new-road-tax-base    or    buf_temp-stk-supp-line.road-tax-rubl  <> buf_temp-stk-supp-line.new-road-tax-rubl    or    buf_temp-stk-supp-line.excise-base    <> buf_temp-stk-supp-line.new-excise-base      or    buf_temp-stk-supp-line.excise-rubl    <> buf_temp-stk-supp-line.new-excise-rubl      or    buf_temp-stk-supp-line.transport-base <> buf_temp-stk-supp-line.new-transport-base   or    buf_temp-stk-supp-line.transport-rubl <> buf_temp-stk-supp-line.new-transport-rubl   or    buf_temp-stk-supp-line.other-base     <> buf_temp-stk-supp-line.new-other-base       or    buf_temp-stk-supp-line.other-rubl     <> buf_temp-stk-supp-line.new-other-rubl
      or ( lookup(buf_temp-stk-supp-line.sum-type
                 ,'sale':U + "," + 'cost':U
                 ) > 0
           and buf_temp-stk-supp-line.cat-id = '##':U
         )
      or ( buf_temp-stk-supp-line.sum-type begins 'sadt':U )
      or ( buf_temp-stk-supp-line.sum-type begins 'csdt':U )
      then do:
        assign
          l-need-create-record =
                                                                                                                                                                          buf_temp-stk-supp-line.new-fact-qnty      <> 0 or    buf_temp-stk-supp-line.new-sum-base       <> 0 or    buf_temp-stk-supp-line.new-sum-rubl       <> 0 or    buf_temp-stk-supp-line.new-vat-base       <> 0 or    buf_temp-stk-supp-line.new-vat-rubl       <> 0 or    buf_temp-stk-supp-line.new-slt-base       <> 0 or    buf_temp-stk-supp-line.new-slt-rubl       <> 0 or    buf_temp-stk-supp-line.new-road-tax-base  <> 0 or    buf_temp-stk-supp-line.new-road-tax-rubl  <> 0 or    buf_temp-stk-supp-line.new-excise-base    <> 0 or    buf_temp-stk-supp-line.new-excise-rubl    <> 0 or    buf_temp-stk-supp-line.new-transport-base <> 0 or    buf_temp-stk-supp-line.new-transport-rubl <> 0 or    buf_temp-stk-supp-line.new-other-base     <> 0 or    buf_temp-stk-supp-line.new-other-rubl     <> 0
                              or ( buf_temp-stk-supp-line.cat-id = '##':U )
        .
        find first buf_stk-supp-line exclusive-lock
          where buf_stk-supp-line.obj-type   = buf_temp-stk-supp-line.obj-type
            and buf_stk-supp-line.obj-code   = buf_temp-stk-supp-line.obj-code
            and buf_stk-supp-line.cli-type   = buf_temp-stk-supp-line.cli-type
            and buf_stk-supp-line.cli-code   = buf_temp-stk-supp-line.cli-code
            and buf_stk-supp-line.artic      = buf_temp-stk-supp-line.artic
            and buf_stk-supp-line.prod-type  = buf_temp-stk-supp-line.prod-type
            and buf_stk-supp-line.prod-code  = buf_temp-stk-supp-line.prod-code
            and buf_stk-supp-line.fact-order = buf_temp-stk-supp-line.fact-order
            and buf_stk-supp-line.sum-type   = buf_temp-stk-supp-line.sum-type
            and buf_stk-supp-line.cat-id     = buf_temp-stk-supp-line.cat-id
          no-error .
        if l-need-create-record
        then do:
          if not available buf_stk-supp-line
          then do:
            create buf_stk-supp-line .
          end.
                              assign
            buf_stk-supp-line.obj-type     = buf_temp-stk-supp-line.obj-type     buf_stk-supp-line.obj-code     = buf_temp-stk-supp-line.obj-code     buf_stk-supp-line.cli-type     = buf_temp-stk-supp-line.cli-type     buf_stk-supp-line.cli-code     = buf_temp-stk-supp-line.cli-code     buf_stk-supp-line.artic        = buf_temp-stk-supp-line.artic        buf_stk-supp-line.prod-type    = buf_temp-stk-supp-line.prod-type    buf_stk-supp-line.prod-code    = buf_temp-stk-supp-line.prod-code    buf_stk-supp-line.fact-order   = buf_temp-stk-supp-line.fact-order   buf_stk-supp-line.sum-type     = buf_temp-stk-supp-line.sum-type     buf_stk-supp-line.cat-id       = buf_temp-stk-supp-line.cat-id       buf_stk-supp-line.fact-date    = buf_temp-stk-supp-line.fact-date    buf_stk-supp-line.shift-num    = buf_temp-stk-supp-line.shift-num    buf_stk-supp-line.shift-date   = buf_temp-stk-supp-line.shift-date
          .
          assign
                                                                                    buf_stk-supp-line.fact-qnty      = buf_temp-stk-supp-line.new-fact-qnty            buf_stk-supp-line.sum-base       = buf_temp-stk-supp-line.new-sum-base             buf_stk-supp-line.sum-rubl       = buf_temp-stk-supp-line.new-sum-rubl             buf_stk-supp-line.vat-base       = buf_temp-stk-supp-line.new-vat-base             buf_stk-supp-line.vat-rubl       = buf_temp-stk-supp-line.new-vat-rubl             buf_stk-supp-line.slt-base       = buf_temp-stk-supp-line.new-slt-base             buf_stk-supp-line.slt-rubl       = buf_temp-stk-supp-line.new-slt-rubl             buf_stk-supp-line.road-tax-base  = buf_temp-stk-supp-line.new-road-tax-base        buf_stk-supp-line.road-tax-rubl  = buf_temp-stk-supp-line.new-road-tax-rubl        buf_stk-supp-line.excise-base    = buf_temp-stk-supp-line.new-excise-base          buf_stk-supp-line.excise-rubl    = buf_temp-stk-supp-line.new-excise-rubl          buf_stk-supp-line.transport-base = buf_temp-stk-supp-line.new-transport-base       buf_stk-supp-line.transport-rubl = buf_temp-stk-supp-line.new-transport-rubl       buf_stk-supp-line.other-base     = buf_temp-stk-supp-line.new-other-base           buf_stk-supp-line.other-rubl     = buf_temp-stk-supp-line.new-other-rubl
          .
        end.
        else do:
          if available buf_stk-supp-line
          then do:
            delete buf_stk-supp-line .
          end.
        end.
      end.
    end.
    if v-shift-on
    then do:
      run store-stk-shift-temp-table in this-procedure .
    end.
  end.
end procedure.
procedure store-stk-shift-temp-table :
  define buffer buf_stk-supp-tot  for ub.stk-supp-tot .
  define buffer buf_stk-supp-line for ub.stk-supp-line .
  define buffer buf_temp-shift-stk-supp-tot for temp-shift-stk-supp-tot .
  define buffer buf_temp-shift-stk-supp-line for temp-shift-stk-supp-line .
  do
  on error undo, return error
  :
    define variable l-need-create-record             as logical no-undo .
    for each buf_temp-shift-stk-supp-tot
    on error undo, return error
    :
      if
                                          buf_temp-shift-stk-supp-tot.fact-qnty      <> buf_temp-shift-stk-supp-tot.new-fact-qnty        or    buf_temp-shift-stk-supp-tot.sum-base       <> buf_temp-shift-stk-supp-tot.new-sum-base         or    buf_temp-shift-stk-supp-tot.sum-rubl       <> buf_temp-shift-stk-supp-tot.new-sum-rubl         or    buf_temp-shift-stk-supp-tot.vat-base       <> buf_temp-shift-stk-supp-tot.new-vat-base         or    buf_temp-shift-stk-supp-tot.vat-rubl       <> buf_temp-shift-stk-supp-tot.new-vat-rubl         or    buf_temp-shift-stk-supp-tot.slt-base       <> buf_temp-shift-stk-supp-tot.new-slt-base         or    buf_temp-shift-stk-supp-tot.slt-rubl       <> buf_temp-shift-stk-supp-tot.new-slt-rubl         or    buf_temp-shift-stk-supp-tot.road-tax-base  <> buf_temp-shift-stk-supp-tot.new-road-tax-base    or    buf_temp-shift-stk-supp-tot.road-tax-rubl  <> buf_temp-shift-stk-supp-tot.new-road-tax-rubl    or    buf_temp-shift-stk-supp-tot.excise-base    <> buf_temp-shift-stk-supp-tot.new-excise-base      or    buf_temp-shift-stk-supp-tot.excise-rubl    <> buf_temp-shift-stk-supp-tot.new-excise-rubl      or    buf_temp-shift-stk-supp-tot.transport-base <> buf_temp-shift-stk-supp-tot.new-transport-base   or    buf_temp-shift-stk-supp-tot.transport-rubl <> buf_temp-shift-stk-supp-tot.new-transport-rubl   or    buf_temp-shift-stk-supp-tot.other-base     <> buf_temp-shift-stk-supp-tot.new-other-base       or    buf_temp-shift-stk-supp-tot.other-rubl     <> buf_temp-shift-stk-supp-tot.new-other-rubl
      or ( lookup(buf_temp-shift-stk-supp-tot.sum-type
                 ,'sale':U + "," + 'cost':U
                 ) > 0
           and buf_temp-shift-stk-supp-tot.cat-id = '##':U
         )
      or ( buf_temp-shift-stk-supp-tot.sum-type begins 'sadt':U )
      or ( buf_temp-shift-stk-supp-tot.sum-type begins 'csdt':U )
      then do:
        assign
          l-need-create-record =
                                                                                                                                                                          buf_temp-shift-stk-supp-tot.new-fact-qnty      <> 0 or    buf_temp-shift-stk-supp-tot.new-sum-base       <> 0 or    buf_temp-shift-stk-supp-tot.new-sum-rubl       <> 0 or    buf_temp-shift-stk-supp-tot.new-vat-base       <> 0 or    buf_temp-shift-stk-supp-tot.new-vat-rubl       <> 0 or    buf_temp-shift-stk-supp-tot.new-slt-base       <> 0 or    buf_temp-shift-stk-supp-tot.new-slt-rubl       <> 0 or    buf_temp-shift-stk-supp-tot.new-road-tax-base  <> 0 or    buf_temp-shift-stk-supp-tot.new-road-tax-rubl  <> 0 or    buf_temp-shift-stk-supp-tot.new-excise-base    <> 0 or    buf_temp-shift-stk-supp-tot.new-excise-rubl    <> 0 or    buf_temp-shift-stk-supp-tot.new-transport-base <> 0 or    buf_temp-shift-stk-supp-tot.new-transport-rubl <> 0 or    buf_temp-shift-stk-supp-tot.new-other-base     <> 0 or    buf_temp-shift-stk-supp-tot.new-other-rubl     <> 0
                              or ( buf_temp-shift-stk-supp-tot.cat-id = '##':U )
        .
        find first buf_stk-supp-tot exclusive-lock
          where buf_stk-supp-tot.obj-type   = buf_temp-shift-stk-supp-tot.obj-type
            and buf_stk-supp-tot.obj-code   = buf_temp-shift-stk-supp-tot.obj-code
            and buf_stk-supp-tot.cli-type   = buf_temp-shift-stk-supp-tot.cli-type
            and buf_stk-supp-tot.cli-code   = buf_temp-shift-stk-supp-tot.cli-code
            and buf_stk-supp-tot.fact-order = buf_temp-shift-stk-supp-tot.fact-order
            and buf_stk-supp-tot.sum-type   = buf_temp-shift-stk-supp-tot.sum-type
            and buf_stk-supp-tot.cat-id     = buf_temp-shift-stk-supp-tot.cat-id
          no-error .
        if l-need-create-record
        then do:
          if not available buf_stk-supp-tot
          then do:
            create buf_stk-supp-tot .
          end.
                              assign
            buf_stk-supp-tot.obj-type     = buf_temp-shift-stk-supp-tot.obj-type     buf_stk-supp-tot.obj-code     = buf_temp-shift-stk-supp-tot.obj-code     buf_stk-supp-tot.cli-type     = buf_temp-shift-stk-supp-tot.cli-type     buf_stk-supp-tot.cli-code     = buf_temp-shift-stk-supp-tot.cli-code     buf_stk-supp-tot.fact-order   = buf_temp-shift-stk-supp-tot.fact-order   buf_stk-supp-tot.sum-type     = buf_temp-shift-stk-supp-tot.sum-type     buf_stk-supp-tot.cat-id       = buf_temp-shift-stk-supp-tot.cat-id       buf_stk-supp-tot.fact-date    = buf_temp-shift-stk-supp-tot.fact-date    buf_stk-supp-tot.shift-num    = buf_temp-shift-stk-supp-tot.shift-num    buf_stk-supp-tot.shift-date   = buf_temp-shift-stk-supp-tot.shift-date
          .
          assign
                                                                                    buf_stk-supp-tot.fact-qnty      = buf_temp-shift-stk-supp-tot.new-fact-qnty            buf_stk-supp-tot.sum-base       = buf_temp-shift-stk-supp-tot.new-sum-base             buf_stk-supp-tot.sum-rubl       = buf_temp-shift-stk-supp-tot.new-sum-rubl             buf_stk-supp-tot.vat-base       = buf_temp-shift-stk-supp-tot.new-vat-base             buf_stk-supp-tot.vat-rubl       = buf_temp-shift-stk-supp-tot.new-vat-rubl             buf_stk-supp-tot.slt-base       = buf_temp-shift-stk-supp-tot.new-slt-base             buf_stk-supp-tot.slt-rubl       = buf_temp-shift-stk-supp-tot.new-slt-rubl             buf_stk-supp-tot.road-tax-base  = buf_temp-shift-stk-supp-tot.new-road-tax-base        buf_stk-supp-tot.road-tax-rubl  = buf_temp-shift-stk-supp-tot.new-road-tax-rubl        buf_stk-supp-tot.excise-base    = buf_temp-shift-stk-supp-tot.new-excise-base          buf_stk-supp-tot.excise-rubl    = buf_temp-shift-stk-supp-tot.new-excise-rubl          buf_stk-supp-tot.transport-base = buf_temp-shift-stk-supp-tot.new-transport-base       buf_stk-supp-tot.transport-rubl = buf_temp-shift-stk-supp-tot.new-transport-rubl       buf_stk-supp-tot.other-base     = buf_temp-shift-stk-supp-tot.new-other-base           buf_stk-supp-tot.other-rubl     = buf_temp-shift-stk-supp-tot.new-other-rubl
          .
        end.
        else do:
          if available buf_stk-supp-tot
          then do:
            delete buf_stk-supp-tot .
          end.
        end.
      end.
    end.
    for each buf_temp-shift-stk-supp-line
    on error undo, return error
    :
      if
                                          buf_temp-shift-stk-supp-line.fact-qnty      <> buf_temp-shift-stk-supp-line.new-fact-qnty        or    buf_temp-shift-stk-supp-line.sum-base       <> buf_temp-shift-stk-supp-line.new-sum-base         or    buf_temp-shift-stk-supp-line.sum-rubl       <> buf_temp-shift-stk-supp-line.new-sum-rubl         or    buf_temp-shift-stk-supp-line.vat-base       <> buf_temp-shift-stk-supp-line.new-vat-base         or    buf_temp-shift-stk-supp-line.vat-rubl       <> buf_temp-shift-stk-supp-line.new-vat-rubl         or    buf_temp-shift-stk-supp-line.slt-base       <> buf_temp-shift-stk-supp-line.new-slt-base         or    buf_temp-shift-stk-supp-line.slt-rubl       <> buf_temp-shift-stk-supp-line.new-slt-rubl         or    buf_temp-shift-stk-supp-line.road-tax-base  <> buf_temp-shift-stk-supp-line.new-road-tax-base    or    buf_temp-shift-stk-supp-line.road-tax-rubl  <> buf_temp-shift-stk-supp-line.new-road-tax-rubl    or    buf_temp-shift-stk-supp-line.excise-base    <> buf_temp-shift-stk-supp-line.new-excise-base      or    buf_temp-shift-stk-supp-line.excise-rubl    <> buf_temp-shift-stk-supp-line.new-excise-rubl      or    buf_temp-shift-stk-supp-line.transport-base <> buf_temp-shift-stk-supp-line.new-transport-base   or    buf_temp-shift-stk-supp-line.transport-rubl <> buf_temp-shift-stk-supp-line.new-transport-rubl   or    buf_temp-shift-stk-supp-line.other-base     <> buf_temp-shift-stk-supp-line.new-other-base       or    buf_temp-shift-stk-supp-line.other-rubl     <> buf_temp-shift-stk-supp-line.new-other-rubl
      or ( lookup(buf_temp-shift-stk-supp-line.sum-type
                 ,'sale':U + "," + 'cost':U
                 ) > 0
           and buf_temp-shift-stk-supp-line.cat-id = '##':U
         )
      or ( buf_temp-shift-stk-supp-line.sum-type begins 'sadt':U )
      or ( buf_temp-shift-stk-supp-line.sum-type begins 'csdt':U )
      then do:
        assign
          l-need-create-record =
                                                                                                                                                                          buf_temp-shift-stk-supp-line.new-fact-qnty      <> 0 or    buf_temp-shift-stk-supp-line.new-sum-base       <> 0 or    buf_temp-shift-stk-supp-line.new-sum-rubl       <> 0 or    buf_temp-shift-stk-supp-line.new-vat-base       <> 0 or    buf_temp-shift-stk-supp-line.new-vat-rubl       <> 0 or    buf_temp-shift-stk-supp-line.new-slt-base       <> 0 or    buf_temp-shift-stk-supp-line.new-slt-rubl       <> 0 or    buf_temp-shift-stk-supp-line.new-road-tax-base  <> 0 or    buf_temp-shift-stk-supp-line.new-road-tax-rubl  <> 0 or    buf_temp-shift-stk-supp-line.new-excise-base    <> 0 or    buf_temp-shift-stk-supp-line.new-excise-rubl    <> 0 or    buf_temp-shift-stk-supp-line.new-transport-base <> 0 or    buf_temp-shift-stk-supp-line.new-transport-rubl <> 0 or    buf_temp-shift-stk-supp-line.new-other-base     <> 0 or    buf_temp-shift-stk-supp-line.new-other-rubl     <> 0
                              or ( buf_temp-shift-stk-supp-line.cat-id = '##':U )
        .
        find first buf_stk-supp-line exclusive-lock
          where buf_stk-supp-line.obj-type   = buf_temp-shift-stk-supp-line.obj-type
            and buf_stk-supp-line.obj-code   = buf_temp-shift-stk-supp-line.obj-code
            and buf_stk-supp-line.cli-type   = buf_temp-shift-stk-supp-line.cli-type
            and buf_stk-supp-line.cli-code   = buf_temp-shift-stk-supp-line.cli-code
            and buf_stk-supp-line.artic      = buf_temp-shift-stk-supp-line.artic
            and buf_stk-supp-line.prod-type  = buf_temp-shift-stk-supp-line.prod-type
            and buf_stk-supp-line.prod-code  = buf_temp-shift-stk-supp-line.prod-code
            and buf_stk-supp-line.fact-order = buf_temp-shift-stk-supp-line.fact-order
            and buf_stk-supp-line.sum-type   = buf_temp-shift-stk-supp-line.sum-type
            and buf_stk-supp-line.cat-id     = buf_temp-shift-stk-supp-line.cat-id
          no-error .
        if l-need-create-record
        then do:
          if not available buf_stk-supp-line
          then do:
            create buf_stk-supp-line .
          end.
                              assign
            buf_stk-supp-line.obj-type     = buf_temp-shift-stk-supp-line.obj-type     buf_stk-supp-line.obj-code     = buf_temp-shift-stk-supp-line.obj-code     buf_stk-supp-line.cli-type     = buf_temp-shift-stk-supp-line.cli-type     buf_stk-supp-line.cli-code     = buf_temp-shift-stk-supp-line.cli-code     buf_stk-supp-line.artic        = buf_temp-shift-stk-supp-line.artic        buf_stk-supp-line.prod-type    = buf_temp-shift-stk-supp-line.prod-type    buf_stk-supp-line.prod-code    = buf_temp-shift-stk-supp-line.prod-code    buf_stk-supp-line.fact-order   = buf_temp-shift-stk-supp-line.fact-order   buf_stk-supp-line.sum-type     = buf_temp-shift-stk-supp-line.sum-type     buf_stk-supp-line.cat-id       = buf_temp-shift-stk-supp-line.cat-id       buf_stk-supp-line.fact-date    = buf_temp-shift-stk-supp-line.fact-date    buf_stk-supp-line.shift-num    = buf_temp-shift-stk-supp-line.shift-num    buf_stk-supp-line.shift-date   = buf_temp-shift-stk-supp-line.shift-date
          .
          assign
                                                                                    buf_stk-supp-line.fact-qnty      = buf_temp-shift-stk-supp-line.new-fact-qnty            buf_stk-supp-line.sum-base       = buf_temp-shift-stk-supp-line.new-sum-base             buf_stk-supp-line.sum-rubl       = buf_temp-shift-stk-supp-line.new-sum-rubl             buf_stk-supp-line.vat-base       = buf_temp-shift-stk-supp-line.new-vat-base             buf_stk-supp-line.vat-rubl       = buf_temp-shift-stk-supp-line.new-vat-rubl             buf_stk-supp-line.slt-base       = buf_temp-shift-stk-supp-line.new-slt-base             buf_stk-supp-line.slt-rubl       = buf_temp-shift-stk-supp-line.new-slt-rubl             buf_stk-supp-line.road-tax-base  = buf_temp-shift-stk-supp-line.new-road-tax-base        buf_stk-supp-line.road-tax-rubl  = buf_temp-shift-stk-supp-line.new-road-tax-rubl        buf_stk-supp-line.excise-base    = buf_temp-shift-stk-supp-line.new-excise-base          buf_stk-supp-line.excise-rubl    = buf_temp-shift-stk-supp-line.new-excise-rubl          buf_stk-supp-line.transport-base = buf_temp-shift-stk-supp-line.new-transport-base       buf_stk-supp-line.transport-rubl = buf_temp-shift-stk-supp-line.new-transport-rubl       buf_stk-supp-line.other-base     = buf_temp-shift-stk-supp-line.new-other-base           buf_stk-supp-line.other-rubl     = buf_temp-shift-stk-supp-line.new-other-rubl
          .
        end.
        else do:
          if available buf_stk-supp-line
          then do:
            delete buf_stk-supp-line .
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure check-need-process :
  define output parameter p-need-process as logical   no-undo .
  define buffer buf_temp-ot-supp-line for temp-ot-supp-line .
  do
  on error undo, return error return-value
  :
    if can-find (
     first buf_temp-ot-supp-line
      where
                                        buf_temp-ot-supp-line.new-fact-qnty      <> 0 or    buf_temp-ot-supp-line.new-sum-base       <> 0 or    buf_temp-ot-supp-line.new-sum-rubl       <> 0 or    buf_temp-ot-supp-line.new-vat-base       <> 0 or    buf_temp-ot-supp-line.new-vat-rubl       <> 0 or    buf_temp-ot-supp-line.new-slt-base       <> 0 or    buf_temp-ot-supp-line.new-slt-rubl       <> 0 or    buf_temp-ot-supp-line.new-road-tax-base  <> 0 or    buf_temp-ot-supp-line.new-road-tax-rubl  <> 0 or    buf_temp-ot-supp-line.new-excise-base    <> 0 or    buf_temp-ot-supp-line.new-excise-rubl    <> 0 or    buf_temp-ot-supp-line.new-transport-base <> 0 or    buf_temp-ot-supp-line.new-transport-rubl <> 0 or    buf_temp-ot-supp-line.new-other-base     <> 0 or    buf_temp-ot-supp-line.new-other-rubl     <> 0
      )
    then do:
      assign
        p-need-process = true
      .
    end.
    else do:
      assign
        p-need-process = false
      .
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
    then do:
    display
      current-time
      current-action
      with frame infa.
     end.
  end.
end procedure.
