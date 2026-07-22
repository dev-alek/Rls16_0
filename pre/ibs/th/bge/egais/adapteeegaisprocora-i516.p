using ibs.th.skt.*.
using ibs.th.skt.Adapters.*.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp_trn-doc no-undo
field line-num as integer
field doc-code as character
field doc-date as date
field ext-doc-type as character
field cli-type as character
field cli-code as integer
field obj-type as character
field obj-code as integer
field wrkr as integer
field agnt as integer
field boss as integer
field creid as character
field ps as character
field host-code as integer
field contract-code as integer
field pay-code   as integer
field reason-code   as integer
field exch-code  as integer
field exch-rate  as decimal
field exch-scale as integer
field vat-type as character
field price-type as character
field cargo-from as character
field stts as character
field hold-obj-type as character
field hold-obj-code as integer
field ship-num as character
field ship-date as date
index pi line-num doc-code .
define temp-table temp_doc-line no-undo
field line-num    as integer
field doc-code    as character
field gds-code    as integer
field artic       as character
field prod-type   as character
field prod-code   as integer
field cli-qnty    as decimal
field doc-qnty    as decimal
field fact-qnty   as decimal
field price-rubl  as decimal
field price-cli   as decimal
field vat-pc      as decimal
field cons-vat-pc as decimal
field refA        as character
field refB        as character
field beforRefB   as character
field alc-code    as character
field alc-type-code as character
field importer-th as character
field line-num-str as character
index pi
doc-code
line-num
gds-code
index qntyIndex
doc-code
gds-code
alc-code
doc-qnty
.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
procedure alc-type-attr-value :
  define input  parameter p-alc-type-inner-code as integer   no-undo .
  define input  parameter p-create-user-db-num  as integer   no-undo .
  define input  parameter p-code                as character no-undo .
  define output parameter p-value               as character no-undo .
  define output parameter p-status              as integer   no-undo .
  define output parameter p-corr-date           as date      no-undo .
  define output parameter p-corr-time           as integer   no-undo .
  define output parameter p-corr-user-name      as character no-undo .
  define output parameter p-create-date         as date      no-undo .
  define output parameter p-create-time         as integer   no-undo .
  define output parameter p-create-user         as character no-undo .
  define buffer buf_alc-type-attr for ub.alc-type-attr .
  do
  on error undo, return error
  :
       find first buf_alc-type-attr no-lock where
                  buf_alc-type-attr.alc-type-inner-code   = p-alc-type-inner-code
            and   buf_alc-type-attr.create-user-db-num    = p-create-user-db-num
            and   buf_alc-type-attr.attr-code             = p-code no-error .
      if not available buf_alc-type-attr then do:
        return error return-value
        .
      end.
      else do:
      assign
        p-value           = buf_alc-type-attr.attr-value
        p-status          = buf_alc-type-attr.attr-status
        p-corr-date       = buf_alc-type-attr.corr-date
        p-corr-time       = buf_alc-type-attr.corr-time
        p-corr-user-name  = buf_alc-type-attr.corr-user-name
        p-create-date     = buf_alc-type-attr.create-date
        p-create-time     = buf_alc-type-attr.create-time
        p-create-user     = buf_alc-type-attr.create-user
      .
      end.
  end.
end procedure.
procedure alc-type-attr-val :
  define input  parameter p-alc-type-inner-code as integer   no-undo .
  define input  parameter p-create-user-db-num  as integer   no-undo .
  define input  parameter p-code                as character no-undo .
  define output parameter p-value               as character no-undo .
  define buffer buf_alc-type-attr for ub.alc-type-attr .
  do
  on error undo, return error
  :
       find first buf_alc-type-attr no-lock where
                  buf_alc-type-attr.alc-type-inner-code   = p-alc-type-inner-code
            and   buf_alc-type-attr.create-user-db-num    = p-create-user-db-num
            and   buf_alc-type-attr.attr-code             = p-code no-error .
      if not available buf_alc-type-attr then do:
        return error return-value
        .
      end.
      else do:
      assign
        p-value           = buf_alc-type-attr.attr-value
      .
      end.
  end.
end procedure.
procedure alc-type-attr-write :
  define input  parameter p-alc-type-inner-code as integer   no-undo .
  define input  parameter p-create-user-db-num  as integer   no-undo .
  define input  parameter p-code                as character no-undo .
  define input parameter p-value                as character no-undo .
  define input parameter p-status               as integer   no-undo .
  define input parameter p-corr-date            as date      no-undo .
  define input parameter p-corr-time            as integer   no-undo .
  define input parameter p-corr-user-name       as character no-undo .
  define input parameter p-create-date          as date      no-undo .
  define input parameter p-create-time          as integer   no-undo .
  define input parameter p-create-user          as character no-undo .
  define buffer buf_alc-type-attr for ub.alc-type-attr .
  do
  on error undo, return error
  :
       find first buf_alc-type-attr no-lock where
                  buf_alc-type-attr.alc-type-inner-code   = p-alc-type-inner-code
            and   buf_alc-type-attr.create-user-db-num    = p-create-user-db-num
            and   buf_alc-type-attr.attr-code             = p-code no-error .
      if not available buf_alc-type-attr then do:
        create buf_alc-type-attr .
        assign
          buf_alc-type-attr.alc-type-inner-code = p-alc-type-inner-code
          buf_alc-type-attr.create-user-db-num  = p-create-user-db-num
          buf_alc-type-attr.attr-code           = p-code
          buf_alc-type-attr.attr-value          = p-value
          buf_alc-type-attr.attr-status         = p-status
          buf_alc-type-attr.corr-date           = p-corr-date
          buf_alc-type-attr.corr-time           = p-corr-time
          buf_alc-type-attr.corr-user-name      = p-corr-user-name
          buf_alc-type-attr.create-date         = p-create-date
          buf_alc-type-attr.create-time         = p-create-time
          buf_alc-type-attr.create-user         = p-create-user
        .
      end.
      else do:
      assign
          buf_alc-type-attr.attr-value          = p-value
          buf_alc-type-attr.attr-status         = p-status
          buf_alc-type-attr.corr-date           = p-corr-date
          buf_alc-type-attr.corr-time           = p-corr-time
          buf_alc-type-attr.corr-user-name      = p-corr-user-name
          buf_alc-type-attr.create-date         = p-create-date
          buf_alc-type-attr.create-time         = p-create-time
          buf_alc-type-attr.create-user         = p-create-user
      .
      end.
  end.
end procedure.
procedure alc-type-attr-delete :
  define input  parameter p-alc-type-inner-code as integer   no-undo .
  define input  parameter p-create-user-db-num  as integer   no-undo .
  define input  parameter p-code                as character no-undo .
  define buffer buf_alc-type-attr for ub.alc-type-attr .
  do
  on error undo, return error
  :
       find first buf_alc-type-attr exclusive-lock where
                  buf_alc-type-attr.alc-type-inner-code   = p-alc-type-inner-code
            and   buf_alc-type-attr.create-user-db-num    = p-create-user-db-num
            and   buf_alc-type-attr.attr-code             = p-code no-error .
      if not available buf_alc-type-attr then do:
        return error return-value
        .
      end.
      else do:
        delete buf_alc-type-attr .
      end.
  end.
end procedure.
  define temp-table tt-wb-header no-undo
    field wb-type-full as character label "Тип" format "X(10)"
    field num          as character label "№ пост."
    field wb-date      as date label "Дата"
    field shippingdate as date label "Дата поставки"
    field regID-Ship   as character format "X(21)" label "RegId контр."
    field NameShip     as character format "X(150)" label "Контрагент EGAIS"
    field regID-Cons   as character format "X(21)" label "Получатель EGAIS"
    field client       as character label "Контр. TH"
    field clientCons   as character label "Получ. TH"
    field cli-type     as character label "Тип клиента TH"
    field cli-code     as integer label "Код клиента TH"
    field obj-type     as character label "Тип клиента TH"
    field obj-code     as integer label "Код клиента TH"
    field ps           as character label "Примечание"
    field wbregid      as character format "X(21)" label "WBRegId"
    field Identity     as character label "ID EGAIS"
    field wb-type      as character label "Тип"
    field cargo-from   as character label  "Грузоотправитель"
    field uniq-key-rec as character
    field INNShip      as character label "ИНН контрагента"
    field KPPShip      as character label "КПП контрагента"
    field TransIdList  as character
    field UnitType     as character label "Тип единицы измерения"
    field verXSD       as character label "Версия XSD"
    index pi
    Identity
    .
  define temp-table tt-wb-gds-EG no-undo
    field gds-code       like ub.goods.gds-code label "Код товара в TH"
    field gds-name       like ub.goods.gds-name label "Полное наименование" format "X(150)"
    field alc-code       as character label "Алкогольный код" format "X(21)"
    field ms-base        like ub.goods.ms-base label "Объем" format ">>9.9<<"
    field alc-type-code  like ub.alc-type.alc-type-code label "Код АП"
    field proof          like ub.goods.proof label "Крепость" format ">9.9"
    field regID-i-p      as character format "X(21)" label "Импортер/Производитель"
    field i-p-name       as character label "Импортер/Производитель назв." format "X(150)"
    field i-p-th         as character label "Импортер/Производитель TH"
    field qnty           like ub.doc-line.doc-qnty label "Кол-во"
    field price          like ub.doc-line.price-rubl label "Цена"
    field refA           as character label "Справка A" format "X(25)"
    field refB           as character label "Справка B" format "X(25)"
    field beforRefB      as character label "Пред. справка B" format "X(25)"
    field Identity       as character label "ID EGAIS"
    field regID-Importer as character format "X(21)" label "Импортер"
    field importer-th    as character label "Импортер TH"
    field regID-Producer as character format "X(21)" label "Производитель"
    field Producer-th    as character label "Производитель TH"
    field nn             as integer label "№"
    field prod-list      as character format "x(1)"
    field importer-list  as character format "x(1)"
    field color-sts      as integer   format "99" init ?
    field UnitType       as character format "x(1)"
    index pi nn ascending
    index qntyIndex
    gds-code
    alc-code
    qnty
    .
  define temp-table tt-wb-act-header no-undo
    field num          as character label "№ пост."
    field wbregid      as character label "WBRegId" format "X(21)"
    field act-date     as date label "Дата"
    field status_      as character label "Статус"
    field note         as character label "Примечание" format "X(150)"
    index pi
    wbregid
    .
  define temp-table tt-wb-act-gds-EG no-undo
    field gds-code      as integer label "Код товара в TH"
    field gds-name      as character label "Полное наименование" format "X(150)"
    field doc-qnty      as decimal label "Кол-во по док."
    field fact-qnty     as decimal label "Кол-во факт."
    field RealQuantity  as decimal label "Кол-во акт"
    field refB          as character label "Справка B" format "X(25)"
    index pi as primary
    gds-code
    index name_
    gds-name
    .
  define temp-table tt-wb-info-client no-undo
    field obj-type        like ub.clients.obj-type
    field obj-code        like ub.clients.obj-code
    field obj-name-th     as character
    field obj-name-egais  as character
    field wb-type-client  as character
    field regID           as character format "X(21)"
    field inn             as character
    field kpp             as character
    field country         as character
    field regionCode      as character
    field district        as character
    field city            as character
    field settlement      as character
    field street          as character
    field house-number    as character
    field house-case      as character
    field house-apartment as character
    field house-litera    as character
    field postIndex       as character
    field description_    as character format "X(100)"
    index pi
    inn kpp
    .
  define temp-table tt-ticket no-undo
    field regid        as character label "RegId документа" format "X(21)"
    field doc          as character label "Документ" format "X(30)"
    field docType      as character label "Документ" format "X(30)"
    field ticket-date  as character label "Дата" format "X(29)"
    field status_      as character label "Статус"
    field comment      as character label "Коментарий" format "X(150)"
    field docId        as character label "DocId" format "X(40)"
    field TransId      as character label "TransId" format "X(40)"
    field Identity     as character label "Identity" format "X(21)"
    index pi
    regid
    .
  define temp-table tt-analiz no-undo
    field num           as character label "№ накл." format "X(50)"
    field wb-type       as character label "Тип" format "X(4)"
    field wb-date       as date      label "Дата"
    field wbregid       as character label "WBREGID" format "X(18)"
    field Identity      as character format "X(50)"
    field uniq-key-rec  as character format "X(50)"
    field url_          as character format "X(50)"
    field isMany        as logical   format "yes/no"
    field nnOrder       as integer
    field resource-type as character format "X(12)"
    index pi
    url_
    .
  define temp-table tt-alldoc no-undo
    field mark          as character format "X(1)" label "*"
    field url_          as character format "X(256)" label "URL"
    field typeDoc       as character format "X(14)" label "Тип"
    field typeDirection as character format "X(3)" label ""
    field date_         as date      label "Дата"
    field nnOrder       as integer   label "Порядковый №"
    field transId_      as date      label ""
    index pi
    nnOrder
    .
define input  parameter table for  tt-wb-header.
define input  parameter table for  tt-wb-gds-EG.
define input  parameter userId_ as character no-undo.
define input  parameter Mode as character no-undo.
define input-output parameter p-doc-code as character no-undo.
define stream outstr.
define variable iDbNum as integer no-undo.
define variable MsgLog as character no-undo.
define buffer buf_goods for ub.goods.
define buffer buf_doc-attr for ub.doc-attr.
MAIN-BLOCK:
do trans:
  define variable num-rec-ok as logical no-undo.
  define variable ii         as integer no-undo.
  define variable jj         as integer no-undo.
  define variable minPrice   as decimal no-undo.
  define variable logWrite   as class   LogWrite no-undo.
  find first tt-wb-header no-lock.
define variable vss-include-info3 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run getcurus in g#library2
  (output iDbNum
  ,output userId_
  ) no-error .
  create temp_trn-doc.
  assign
    temp_trn-doc.line-num      = ii
    temp_trn-doc.doc-date      = tt-wb-header.wb-date
    temp_trn-doc.ps            = tt-wb-header.ps
    temp_trn-doc.doc-code      = tt-wb-header.wbregid + chr(6) + tt-wb-header.uniq-key-rec
    temp_trn-doc.ext-doc-type  = tt-wb-header.wb-type
    temp_trn-doc.cli-type      = tt-wb-header.cli-type
    temp_trn-doc.cli-code      = tt-wb-header.cli-code
    temp_trn-doc.obj-type      = tt-wb-header.obj-type
    temp_trn-doc.obj-code      = tt-wb-header.obj-code
    temp_trn-doc.cargo-from    = tt-wb-header.cargo-from
    temp_trn-doc.exch-code     = 0
    temp_trn-doc.exch-rate     = 1
    temp_trn-doc.exch-scale    = 1
    temp_trn-doc.contract-code = ?
    temp_trn-doc.price-type    = if tt-wb-header.wb-type = 'ee':U then "TSFTSD" else ""
    .
  jj = 0.
  for each tt-wb-gds-EG no-lock:
    find first buf_goods no-lock where buf_goods.gds-code = tt-wb-gds-EG.gds-code no-error.
    if not available (buf_goods)
    then do:
      return error ("Не найден товар с кодом - " + string (tt-wb-gds-EG.gds-code)).
    end.
    jj = jj + 1.
    create temp_doc-line.
    assign
      temp_doc-line.line-num   = jj
      temp_doc-line.gds-code   = tt-wb-gds-EG.gds-code
      temp_doc-line.price-cli  = tt-wb-gds-EG.price
      temp_doc-line.doc-code   = temp_trn-doc.doc-code
      temp_doc-line.RefA = tt-wb-gds-EG.RefA
      temp_doc-line.RefB = tt-wb-gds-EG.RefB
      temp_doc-line.alc-code = tt-wb-gds-EG.alc-code
      temp_doc-line.alc-type-code = tt-wb-gds-EG.alc-type-code
      temp_doc-line.importer-th = tt-wb-gds-EG.importer-th
      temp_doc-line.line-num-str = tt-wb-gds-EG.Identity
    .
    find first ub.alc-type where ub.alc-type.alc-type-code = tt-wb-gds-EG.alc-type-code no-error.
    if available (ub.alc-type)
    then do:
      run alc-type-attr-val (  input   ub.alc-type.alc-type-inner-code,
                               input   ub.alc-type.create-user-db-num,
                               input   "alc-min-price",
                               output  minPrice
                            )  no-error.
    end.
    if tt-wb-gds-EG.price < minPrice * buf_goods.cli-base-rate
    then do:
      MsgLog = MsgLog + chr(10) + substitute ("Для товара &2/&1 &3 цена в накладной ЕГАИС - &4 меньше допустимой - &5 по группе &6", tt-wb-gds-EG.alc-code, buf_goods.gds-code, tt-wb-gds-EG.gds-name, tt-wb-gds-EG.price * buf_goods.cli-base-rate, minPrice, tt-wb-gds-EG.alc-type-code).
    end.
    if tt-wb-header.UnitType <> ''
    then do:
      if true
      then
        assign
          temp_doc-line.fact-qnty  = buf_goods.cli-base-rate * tt-wb-gds-EG.qnty
          temp_doc-line.doc-qnty   = buf_goods.cli-base-rate * tt-wb-gds-EG.qnty
          temp_doc-line.cli-qnty   = tt-wb-gds-EG.qnty
          temp_doc-line.price-cli = tt-wb-gds-EG.price
        .
      else
        assign
          temp_doc-line.fact-qnty  = tt-wb-gds-EG.qnty
          temp_doc-line.doc-qnty   = tt-wb-gds-EG.qnty
          temp_doc-line.cli-qnty   = tt-wb-gds-EG.qnty
          temp_doc-line.price-cli = tt-wb-gds-EG.price
        .
    end.
    else do:
      if tt-wb-gds-EG.UnitType = 'UnPacked'
      then
        assign
          temp_doc-line.fact-qnty  = buf_goods.cli-base-rate * tt-wb-gds-EG.qnty
          temp_doc-line.doc-qnty   = buf_goods.cli-base-rate * tt-wb-gds-EG.qnty
          temp_doc-line.cli-qnty   = tt-wb-gds-EG.qnty
          temp_doc-line.price-cli = tt-wb-gds-EG.price
        .
      else
        assign
          temp_doc-line.fact-qnty  = tt-wb-gds-EG.qnty
          temp_doc-line.doc-qnty   = tt-wb-gds-EG.qnty
          temp_doc-line.cli-qnty   = tt-wb-gds-EG.qnty
          temp_doc-line.price-cli = tt-wb-gds-EG.price
        .
    end.
  end.
  if MsgLog <> ""
  then do:
    output stream outstr to value ("warWBLog.txt").
    put stream outstr unformatted MsgLog.
    output stream outstr close.
    message substitute ("&2&1 Продолжить?", MsgLog, chr(10)) view-as alert-box question buttons yes-no title "Вопрос..." update isChoise as logical.
    if isChoise
    then do:
      MsgLog = "".
    end.
    else do:
      return error "Отменено пользователем." .
    end.
  end.
  case Mode:
    when "set-refAB"
    then do:
      run set-refAB no-error.
      if error-status:error
      then do:
        return error return-value .
      end.
    end.
    when "conn" then do:
      run set-refAB no-error.
      if error-status:error
      then do:
        return error return-value .
      end.
      def var temp-str as char no-undo.
      for each buf_doc-attr exclusive-lock where buf_doc-attr.attr-code = 'negais':U and buf_doc-attr.attr-value begins (tt-wb-header.wbregid):
        delete buf_doc-attr.
      end.
      temp-str = string(tt-wb-header.wbregid + chr(6) + tt-wb-header.uniq-key-rec).
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input p-doc-code ,
                       input 'negais':U ,
                       input temp-str ) no-error .
      if error-status:error
      then do:
        return error MsgLog + chr(10) + return-value.
      end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input p-doc-code ,
                       input 'nids':U ,
                       input entry(1,tt-wb-header.uniq-key-rec,chr(6)) ) no-error .
      if error-status:error
      then do:
        return error MsgLog + chr(10) + return-value.
      end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input p-doc-code ,
                       input 'dids':U ,
                       input entry(2,tt-wb-header.uniq-key-rec,chr(6)) ) no-error .
      if error-status:error
      then do:
        return error MsgLog + chr(10) + return-value.
      end.
    end.
    otherwise do:
      run utl/ora-i516.p (
        input this-procedure ,
        input this-procedure ,
        input table temp_trn-doc ,
        input table temp_doc-line ,
        output num-rec-ok
        ) no-error .
      if error-status:error
      then do:
        return error MsgLog + chr(10) + return-value.
      end.
    end.
  end case.
end.
procedure pcall-log-file:
  define input parameter msg as character no-undo.
  if msg begins "n-d" then do:
    p-doc-code = entry (2, msg, "=").
  end.
  else do:
  assign
    MsgLog = msg + chr(10)
    .
  end.
end.
procedure get-db-num:
  define output parameter pDbNum as integer no-undo.
  pDbNum = iDbNum.
end.
procedure get-userid:
  define output parameter pUserId as character no-undo.
  assign
    pUserId = userId_ + ",egais"
    .
end.
procedure mainmenu_getcntxt :
define output parameter p-cntxt-db-num                as integer   no-undo .
define output parameter p-cntxt-userid                as character no-undo .
define output parameter p-cntxt-level                 as character no-undo .
define output parameter p-cntxt-host-code-obj         as integer   no-undo .
define output parameter p-cntxt-obj-type              as character no-undo .
define output parameter p-cntxt-obj-code              as integer   no-undo .
define output parameter p-cntxt-db-num-obj            as integer   no-undo .
define output parameter p-cntxt-is-admin              as logical   no-undo .
  do
  on error undo, return error return-value
  :
  define variable vt-host-code as integer   no-undo .
  find first temp_trn-doc no-error.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  temp_trn-doc.obj-type
  ,input  temp_trn-doc.obj-code
  ,output p-cntxt-db-num-obj
  )  .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  temp_trn-doc.obj-type
  ,input  temp_trn-doc.obj-code
  ,output vt-host-code
  )  .
  assign
    p-cntxt-db-num          =  p-cntxt-db-num-obj
    p-cntxt-userid          =  userId_
    p-cntxt-level           =  v-cntxt-level
    p-cntxt-host-code-obj   =  vt-host-code
    p-cntxt-obj-type        =  temp_trn-doc.obj-type
    p-cntxt-obj-code        =  temp_trn-doc.obj-code
    p-cntxt-is-admin        =  v-cntxt-is-admin
  .
  end.
end procedure.
procedure set-refAB:
  find first ub.trn-doc where ub.trn-doc.doc-code = p-doc-code no-lock.
    foreach_:
    for each ub.parts exclusive-lock
      where
            ub.parts.out-code  = p-doc-code
        and ub.parts.obj-code  = ub.trn-doc.obj-code
        and ub.parts.obj-type  = ub.trn-doc.obj-type
        by ub.parts.artic by ub.parts.prod-type by ub.parts.prod-code by ub.parts.qnty
      :
      find first buf_goods where buf_goods.artic = ub.parts.artic and buf_goods.prod-type = ub.parts.prod-type and buf_goods.prod-code = ub.parts.prod-code no-error.
      if not available (buf_goods)
        then return error error-status:get-message (1).
      find next tt-wb-gds-EG where tt-wb-gds-EG.gds-code = buf_goods.gds-code and tt-wb-gds-EG.qnty =  ub.parts.qnty use-index qntyIndex no-lock no-error.
      if not available (tt-wb-gds-EG) then do:
        find first tt-wb-gds-EG where  tt-wb-gds-EG.gds-code = buf_goods.gds-code and tt-wb-gds-EG.qnty =  ub.parts.qnty use-index qntyIndex no-lock no-error.
        if not available (tt-wb-gds-EG)
          then find first tt-wb-gds-EG where  tt-wb-gds-EG.gds-code = buf_goods.gds-code use-index qntyIndex no-lock no-error.
        if not available (tt-wb-gds-EG)
          then next foreach_.
      end.
      run trg/partps.p ( input buf_goods.gds-code
                       , input ub.parts.in-code
                       , ?
                       , input ub.parts.part-code
                       , input ub.parts.mark-db-num
                       , input ub.parts.mark-code
                       , input ub.parts.alc-bottling-date
                       , input tt-wb-gds-EG.refA + ',' + tt-wb-gds-EG.refB + ',' + tt-wb-gds-EG.alc-code + ',' + tt-wb-gds-EG.alc-type-code
                       , input ub.parts.alc-quality-certif-path
                       , input ub.parts.alc-certif-path
                       , if tt-wb-gds-EG.importer-th <> "" then substring (tt-wb-gds-EG.importer-th, 1, 3) else ""
                       , if tt-wb-gds-EG.importer-th <> "" then substring (tt-wb-gds-EG.importer-th, 4) else ""
                       ) no-error .
      if error-status :error
      then do:
        undo, return error "Ошибка при вызове процедуры partps.p" +
                            chr(10) +
                            error-status :get-message(1) +
                            chr(10) + return-value + chr(10).
      end.
    end.
end procedure.
