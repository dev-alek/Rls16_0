using ibs.th.bge.egais.*.
using Ibs.Th.Gbl.ProgressBar.
using Ibs.Th.ref.*.
block-level on error undo, throw.
class ibs.th.bge.egais.WayBill inherits EGAISUTM:
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
define temp-table tt-act-header
    field num           as character        label "№ акта"      format "X(30)"
    field date_         as date             label "Дата акта"
    field is-sent       as logical
    field answer_       as character        label "Ответ"       format "X(1500)"
    field RegID         as character        label "Рег. номер"  format "X(50)"
    index pi as primary unique
        num
.
define temp-table tt-gds-act
    field num           as character                label "№ акта"
    field position_     as integer                  label "№ пп"                    format ">>>9"
    field gds-code      like ub.goods.gds-code      label "Код товара   "
    field alc-code      as character                label "Алкогольный код"         format "X(21)"
    field gds-name      like ub.goods.gds-name      label "Наименование товара"     format "X(35)"
    field qnty          as decimal                  label "Количество"
    field inform-B      as character                label "Справка Б"               format "X(20)"
    index pi as primary unique
        position_
    index code
        gds-code
.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR BLACK_COLOR        AS INTEGER NO-UNDO INIT  0.
DEF VAR DARK_BLUE_COLOR    AS INTEGER NO-UNDO INIT  1.
DEF VAR DARK_GREEN_COLOR   AS INTEGER NO-UNDO INIT  2.
DEF VAR CYAN_COLOR         AS INTEGER NO-UNDO INIT  3.
DEF VAR BROWN_COLOR        AS INTEGER NO-UNDO INIT  4.
DEF VAR DARK_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR DARK_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR GRAY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR GREY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR BLUE_COLOR         AS INTEGER NO-UNDO INIT  9.
DEF VAR GREEN_COLOR        AS INTEGER NO-UNDO INIT 10.
DEF VAR RED_COLOR          AS INTEGER NO-UNDO INIT 12.
DEF VAR LIGHT_RED_COLOR    AS INTEGER NO-UNDO INIT 13.
DEF VAR YELLOW_COLOR       AS INTEGER NO-UNDO INIT 14.
DEF VAR WHITE_COLOR        AS INTEGER NO-UNDO INIT 15.
  define stream outstr.
  define stream str-formF1.
  define private buffer buf_clob-bind          for ub.clob-bind.
  define private buffer buf_clob-bind-wb-hndls for ub.clob-bind.
  define private buffer buf_clob-bind-temp     for ub.clob-bind.
  define private buffer buf_clob-data          for ub.clob-data.
  define private buffer buf_gds                for ub.goods.
  define private buffer buf_gds-attr           for ub.goods-attr.
  define private buffer buf_trn-doc            for ub.trn-doc.
  define private buffer buf_doc-attr           for ub.doc-attr.
  define private buffer buf_parts              for ub.parts.
  define private buffer buf_doc-line           for ub.doc-line.
  define private buffer buf_doc-line-attr      for ub.doc-line-attr.
  define private buffer buf_clients            for ub.clients.
  define private buffer buf_clients-attr       for ub.clients-attr.
  define private buffer buf_firm               for ub.firm.
  define private buffer buf_shop               for ub.shop.
  define private buffer buf_store              for ub.store.
  define private buffer buf_ext-classif        for ub.ext-classif.
  define private buffer buf_ext-classif-attr   for ub.ext-classif-attr.
  define private buffer X_ext-classif          for ub.ext-classif.
  define private buffer buf_country            for ub.country.
  define private buffer buf_tt-wb-gds-EG       for tt-wb-gds-EG.
  define private variable parameters     as character no-undo.
  define private variable inFileName     as character no-undo.
  define private variable inData         as character no-undo.
  define private variable outData        as character no-undo.
  define private variable cmd            as character no-undo.
  define private variable urlResp        as character no-undo.
  define private variable v-uniq-key-rec as character no-undo.
  define private variable nn             as integer   no-undo.
  define private variable nnList         as integer   no-undo.
  define private variable minPrice       as decimal   no-undo.
  define private variable isForceAccept  as logical   no-undo.
  define private variable verPrefXMLNS   as character no-undo.
  define private variable bh-act-tts-header  as handle    no-undo.
  define private variable extGdsObj      as class   ExtGds         no-undo.
  define private variable extGdsValueObj as class   ExtGdsValue    no-undo.
  define private variable prgObj         as class   ProgressBar    no-undo .
  define private variable prsXMLDocWB    as class   ParserXMLDocWB no-undo.
  define private variable alcTypeAttrObj as class   AlcTypeAttr    no-undo.
  define private variable egaisTTS       as class   TransferToShop no-undo.
  define variable v-FS-RAR   as character no-undo .
  define variable inDocFSRAR as character no-undo .
  define variable v-ext-sys  as integer   no-undo .
  define variable ObjType    as character no-undo .
  define variable ObjCode    as integer   no-undo .
  define variable VerWBXsd   as character no-undo.
  define property HndlHeader as handle no-undo
    get.
    private set.
  define property HndlLine as handle no-undo
    get.
    private set.
  define property HndlAnaliz as handle no-undo
    get.
    private set.
  define property ActnEGAISAdm as logical no-undo
    get.
    set.
  define property ActnEGAISSts as logical no-undo
    get.
    set.
  define property FastDwnl as logical no-undo
    get.
    set.
  define property SettingsTTList as character no-undo
    get.
    set.
  define temp-table tt-wb-hndls no-undo
    field num          as character label "№ накл." format "X(50)"
    field wb-date      as date      label "Дата"
    field obj          as character label "Объект"
    field shippregid   as character label "ID поставщика" format "x(21)"
    field cli          as character label "Контрагент" format "x(30)"
    field cliname      as character label "Название контрагента" format "x(30)"
    field wb-type      as character label "Тип" format "x(20)"
    field trn-doc-code as character label "№ накл. TH" format "x(20)"
    field status_      as character label "Статус" format "x(20)"
    field EGAISSts     as character label "Статус ЕГАИС" format "x(20)"
    field is-sent      as character label "Отправлена"
    field wbregid      as character label "WBREGID" format "X(18)"
    field tts          as character label "Акт передачи в торг. зал." format "X(30)"
    field tts-status_  as character label "Статус" format "x(10)"
    field Identity     as character format "X(50)"
    field uniq-key-rec as character format "X(50)"
    field DbNUm        as integer   label "БД"
    field isWB         as logical
    index pi
    Identity
    .
  define private buffer buf_tt-analiz for tt-analiz.
  define temp-table tt-wb-act-hndls no-undo
    field num          as character label "№ акта"
    field act-date     as date      label "Дата"
    field status_      as character label "Статус"
    field wbregid      as character label "ID накл. EGAIS" format "X(21)"
    index pi
    wbregid
    .
  constructor public WayBill (inObjType as char, inObjCode as int, inFSRAR as char, inExtSys as integer):
    super (inObjType, inObjCode).
    ObjCode = inObjCode.
    ObjType = inObjType.
    v-FS-RAR = inFSRAR.
    v-ext-sys = inExtSys.
    IsSent.
    extGdsObj = new ExtGds (yes).
    prsXMLDocWB = new ParserXMLDocWB(v-ext-sys).
    alcTypeAttrObj = new AlcTypeAttr ().
  end constructor.
  destructor WayBill ():
    if valid-object (extGdsObj)
      then delete object extGdsObj no-error.
    if valid-object (prgObj)
      then delete object prgObj.
    if valid-object (prsXMLDocWB)
      then delete object prsXMLDocWB.
    if valid-object (alcTypeAttrObj)
      then delete object alcTypeAttrObj.
  end.
  method public override handle GetHndlTable(inTableType as int, inWbIdentity as char) :
    define buffer buf_clob-bind-ref for ub.clob-bind.
    define buffer buf_clob-data-ref for ub.clob-data.
    define variable hDoc    as handle  no-undo.
    define variable hDocRef as handle  no-undo.
    define variable ii      as integer no-undo.
    assign
      StatusErr = false
      Msg       = ""
      .
    isForceAccept = false.
    case inTableType:
      when 1 or
      when 2 then
        do:
          if true
            then
          do:
            empty temp-table tt-wb-header.
            empty temp-table tt-wb-gds-EG.
            find first buf_clob-bind no-lock where buf_clob-bind.uniq-key-rec = inWbIdentity and buf_clob-bind.resource-type = 'egais-wb':U no-error.
            if not available (buf_clob-bind) then
            do:
              find first buf_clob-bind no-lock
                where num-entries (inWbIdentity, chr(6)) = 4 and
                  (buf_clob-bind.uniq-key-rec = entry (4, inWbIdentity, chr(6)) + chr(6) + entry (3, inWbIdentity, chr(6))
                  or buf_clob-bind.uniq-key-rec = entry (4, inWbIdentity, chr(6))) and
                  buf_clob-bind.resource-type = 'egais-wb':U
              no-error.
              if not available (buf_clob-bind) then
              do:
                Msg = "Не найдена накладная с идентификатором " + inWbIdentity.
                StatusErr = true.
                return ?.
              end.
            end.
            v-uniq-key-rec = buf_clob-bind.uniq-key-rec.
            find first buf_clob-data no-lock where buf_clob-data.db-num = buf_clob-bind.db-num and buf_clob-data.int64-id = buf_clob-bind.int64-id no-error.
            createhDoc(recid (buf_clob-data), "temp.xml", output hDoc).
            find first buf_clob-bind-ref no-lock where buf_clob-bind-ref.uniq-key-rec = v-uniq-key-rec and buf_clob-bind-ref.resource-type = 'egais-ref-b':U no-error.
            if available (buf_clob-bind-ref) then
            do:
              find first buf_clob-data-ref no-lock where buf_clob-data-ref.db-num = buf_clob-bind-ref.db-num and buf_clob-data-ref.int64-id = buf_clob-bind-ref.int64-id no-error.
              createhDoc(recid (buf_clob-data-ref), "refbtemp.xml", output hDocRef).
              prsXMLDocWB:ParseRec(hDoc, hDocRef, input-output table tt-wb-header, input-output table tt-wb-gds-EG, input-output table tt-wb-info-client).
            end.
            else do:
              prsXMLDocWB:ParseRec(hDoc, ?, input-output table tt-wb-header, input-output table tt-wb-gds-EG, input-output table tt-wb-info-client).
            end.
            find first tt-wb-header.
            if not available ( tt-wb-header )
            then do:
              message "Неудалось распарсить документ." view-as alert-box.
              return ?.
            end.
            tt-wb-header.TransIdList = buf_clob-bind.field-name_.
            find first buf_ext-classif no-lock where buf_ext-classif.classif-subject = 'clients':U
              and buf_ext-classif.classif-name = 'clients-esys':U
              and buf_ext-classif.db-num = 0
              and buf_ext-classif.key#_one = v-ext-sys
              and buf_ext-classif.CharKey_Three = tt-wb-header.regID-Ship no-error.
            if available (buf_ext-classif)
              then
            do:
              find first ub.clients no-lock where
                ub.clients.obj-type = entry(2, buf_ext-classif.uniq-key-rec, chr(3)) and
                ub.clients.obj-code = integer(entry(3, buf_ext-classif.uniq-key-rec, chr(3))).
              if available (ub.clients) then
              do:
                find first ub.clients-attr where ub.clients-attr.attr-code = 'main-accholder':U
                  and ub.clients-attr.obj-code = ub.clients.obj-code and ub.clients-attr.obj-type = ub.clients.obj-type no-error.
                if available (ub.clients-attr)
                then do:
                  assign
                    tt-wb-header.cli-type = entry (1, ub.clients-attr.attr-value, ",")
                    tt-wb-header.cli-code = integer (entry (2, ub.clients-attr.attr-value, ","))
                    tt-wb-header.client   = entry (1, ub.clients-attr.attr-value, ",") + entry (2, ub.clients-attr.attr-value, ",")
                    tt-wb-header.cargo-from = ub.clients.obj-type + string (ub.clients.obj-code)
                    .
                end.
                else do:
                  assign
                    tt-wb-header.cli-type = ub.clients.obj-type
                    tt-wb-header.cli-code = ub.clients.obj-code
                    tt-wb-header.client   = ub.clients.obj-type + string (ub.clients.obj-code)
                    .
                end.
              end.
            end.
            find first buf_ext-classif no-lock where buf_ext-classif.classif-subject = 'clients':U
              and buf_ext-classif.classif-name = 'clients-esys':U
              and buf_ext-classif.db-num = 0
              and buf_ext-classif.key#_one = v-ext-sys
              and buf_ext-classif.CharKey_Three = tt-wb-header.regID-Cons and buf_ext-classif.CharKey_Two = entry (9, buf_clob-bind.descr, chr(4)) no-error.
            if available (buf_ext-classif)
              then
            do:
              find first ub.clients no-lock where
                ub.clients.obj-type = entry(2, buf_ext-classif.uniq-key-rec, chr(3)) and
                ub.clients.obj-code = integer(entry(3, buf_ext-classif.uniq-key-rec, chr(3))).
              if available (ub.clients) then
              do:
                assign
                  tt-wb-header.obj-type   = ub.clients.obj-type
                  tt-wb-header.obj-code   = ub.clients.obj-code
                  tt-wb-header.clientCons = ub.clients.obj-type + string (ub.clients.obj-code)
                  .
              end.
            end.
            for each tt-wb-gds-EG:
              if tt-wb-gds-EG.alc-code = ? or tt-wb-gds-EG.alc-code = ""
              then do:
                message "Документ распарсен с ошибками." view-as alert-box.
                return ?.
              end.
              extGdsObj:OpenQueryExtGds(0, tt-wb-gds-EG.alc-code).
              if extGdsObj:NumBundles = 1
                then do:
                  tt-wb-gds-EG.gds-code = extGdsObj:GetExtGdsValue():GdsCode.
                  find first buf_tt-wb-gds-EG where buf_tt-wb-gds-EG.alc-code = tt-wb-gds-EG.alc-code and recid (buf_tt-wb-gds-EG) <> recid (tt-wb-gds-EG) no-error.
                  if available (buf_tt-wb-gds-EG)
                  then do:
                    buf_tt-wb-gds-EG.color-sts = DARK_GREY_COLOR.
                    tt-wb-gds-EG.color-sts = DARK_GREY_COLOR.
                  end.
                end.
                else do:
                  if extGdsObj:NumBundles > 1
                  then do:
                    assign tt-wb-gds-EG.gds-code = ?.
                    tt-wb-gds-EG.color-sts = DARK_GREY_COLOR.
                  end.
                  else assign tt-wb-gds-EG.gds-code = 0 tt-wb-gds-EG.color-sts = RED_COLOR.
                end.
            end.
            if available (buf_clob-bind-ref) then
            do:
              for each tt-wb-gds-EG where tt-wb-gds-EG.gds-code = ? :
                nnList = lookup ( tt-wb-gds-EG.refB, buf_clob-bind-ref.descr).
                if nnList > 0
                then do:
                  extGdsObj:OpenQueryExtGds (integer (entry (nnList - 1, buf_clob-bind-ref.descr)), tt-wb-gds-EG.alc-code).
                  if extGdsObj:NumBundles > 0
                  then do:
                    tt-wb-gds-EG.gds-code = integer (entry (nnList - 1, buf_clob-bind-ref.descr)).
                  end.
                  else do:
                    tt-wb-gds-EG.color-sts = RED_COLOR.
                  end.
                end.
                else do:
                  tt-wb-gds-EG.color-sts = DARK_GREY_COLOR.
                end.
              end.
            end.
          end.
          HndlHeader = buffer tt-wb-header:handle.
          HndlLine = buffer tt-wb-gds-EG:handle.
          if inTableType = 1 then
          do:
            return buffer tt-wb-header:handle.
          end.
          else
          do:
            return buffer tt-wb-gds-EG:handle.
          end.
        end.
      when 8 or
      when 9 then
        do:
          if true
            then
          do:
            if inTableType = 8
              then empty temp-table tt-wb-act-header.
              else empty temp-table tt-wb-act-gds-EG.
            find first buf_clob-bind exclusive-lock where buf_clob-bind.uniq-key-rec = inWbIdentity and buf_clob-bind.resource-type = 'egais-wb-act':U no-error.
            if not available (buf_clob-bind) then
            do:
              Msg = "Не найден акт с идентификатором " + inWbIdentity.
              StatusErr = true.
              return ?.
            end.
            find first buf_clob-data exclusive-lock where buf_clob-data.db-num = buf_clob-bind.db-num and buf_clob-data.int64-id = buf_clob-bind.int64-id no-error.
            createhDoc(recid (buf_clob-data), "temp.xml", output hDoc).
            prsXMLDocWB:ParseRec (hDoc, input-output table tt-wb-act-header, input-output table tt-wb-act-gds-EG).
            find first tt-wb-act-header.
            find first buf_doc-attr no-lock where buf_doc-attr.attr-code = 'negais':U and buf_doc-attr.attr-value begins tt-wb-act-header.wbregid no-error.
            if available (buf_doc-attr) then do:
              find first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_doc-attr.doc-code.
              for each tt-wb-act-gds-EG :
                find first buf_parts no-lock where
                 buf_parts.obj-type = buf_trn-doc.obj-type and
                 buf_parts.obj-code = buf_trn-doc.obj-code and
                 buf_parts.in-code = buf_trn-doc.doc-code and
                 buf_parts.out-code = buf_trn-doc.doc-code and
                 tt-wb-act-gds-EG.refB = entry (2, buf_parts.alc-ref-ab-path, ",") no-error.
                if available (buf_parts) then do:
                  find first buf_gds no-lock where buf_gds.artic = buf_parts.artic and buf_gds.prod-code = buf_parts.prod-code and buf_gds.prod-type = buf_parts.prod-type.
                  assign
                    tt-wb-act-gds-EG.doc-qnty = buf_parts.qnty / buf_parts.cli-base-rate
                    tt-wb-act-gds-EG.fact-qnty = buf_parts.fact-qnty / buf_parts.cli-base-rate
                    tt-wb-act-gds-EG.gds-code = buf_gds.gds-code
                  .
                end.
                else do:
                  assign
                    tt-wb-act-gds-EG.doc-qnty = ?
                    tt-wb-act-gds-EG.fact-qnty = ?
                    tt-wb-act-gds-EG.gds-code = ?
                  .
                end.
              end.
            end.
          end.
          HndlHeader = buffer tt-wb-header:handle.
          HndlLine = buffer tt-wb-gds-EG:handle.
          if inTableType = 8 then
          do:
            return buffer tt-wb-act-header:handle.
          end.
          else
          do:
            return buffer tt-wb-act-gds-EG:handle.
          end.
        end.
      when 3 then
        do:
          SettingsTTList = "20,yes;;;12,yes;9,yes;20,yes;10,yes;10,yes;6,yes;12,yes;;;30,yes;10,yes;;;;".
          egaisTTS = new TransferToShop (ObjType, ObjCode, v-FS-RAR, v-ext-sys).
          egaisTTS:DbNum =  DbNum.
          egaisTTS:User_Id = User_Id.
          bh-act-tts-header = egaisTTS:GetHndlTable(3, "").
          empty temp-table tt-wb-hndls.
          for each buf_clob-bind-wb-hndls no-lock where buf_clob-bind-wb-hndls.resource-type = 'egais-wb':U:
            if entry (9, buf_clob-bind-wb-hndls.descr, chr(4)) <> "" and entry (9, buf_clob-bind-wb-hndls.descr, chr(4)) <> "0" and entry (9, buf_clob-bind-wb-hndls.descr, chr(4)) <> ObjType + string (ObjCode)
              then next.
            create tt-wb-hndls.
            assign
              tt-wb-hndls.wb-date      = date (entry (1, buf_clob-bind-wb-hndls.descr, chr(4)))
              tt-wb-hndls.num          = (if buf_clob-bind-wb-hndls.uniq-key-rec matches '*отмена*' or buf_clob-bind-wb-hndls.uniq-key-rec matches '*old*' then "отмена: " else "") + entry (2, buf_clob-bind-wb-hndls.descr, chr(4))
              tt-wb-hndls.shippregid   = entry (3, buf_clob-bind-wb-hndls.descr, chr(4))
              tt-wb-hndls.Identity     = entry (4, buf_clob-bind-wb-hndls.descr, chr(4))
              tt-wb-hndls.trn-doc-code = entry (6, buf_clob-bind-wb-hndls.descr, chr(4))
              tt-wb-hndls.is-sent      = entry (7, buf_clob-bind-wb-hndls.descr, chr(4))
              tt-wb-hndls.wb-type      = "приход вн."
                when entry (8, buf_clob-bind-wb-hndls.descr, chr(4)) = 'ie':U
              tt-wb-hndls.wb-type      = "возврат вн."
                when entry (8, buf_clob-bind-wb-hndls.descr, chr(4)) = 're':U
              tt-wb-hndls.obj          = entry (9, buf_clob-bind-wb-hndls.descr, chr(4))
              tt-wb-hndls.EGAISSts     = entry (10, buf_clob-bind-wb-hndls.descr, chr(4)) when num-entries (buf_clob-bind-wb-hndls.descr, chr(4)) > 9
              tt-wb-hndls.uniq-key-rec = buf_clob-bind-wb-hndls.uniq-key-rec.
              tt-wb-hndls.DbNUm        = buf_clob-bind-wb-hndls.db-num.
            .
            bh-act-tts-header:find-first (substitute ("where tt-act-header.num matches '*&1*'", trn-doc-code), no-lock ) no-error.
            if bh-act-tts-header:available
            then do:
              tt-wb-hndls.tts = bh-act-tts-header:buffer-field ("num"):buffer-value ().
              if num-entries (bh-act-tts-header:buffer-field ("RegID"):buffer-value (), chr(5) ) < 2
              then do:
                if bh-act-tts-header:buffer-field ("is-sent"):buffer-value = true
                then do:
                  tt-wb-hndls.tts-status_ = 'Отправлен'.
                end.
                else do:
                  tt-wb-hndls.tts-status_ = 'Новый'.
                end.
              end.
              else do:
                case entry(2, bh-act-tts-header:buffer-field ("RegID"):buffer-value, chr(5)):
                when "R" then do:
                  tt-wb-hndls.tts-status_ = 'Отклонен'.
                end.
                when "A" then do:
                  tt-wb-hndls.tts-status_ = 'Принят'.
                end.
                end case.
              end.
            end.
            find first ub.ext-classif no-lock
              where ub.ext-classif.classif-subject = 'clients':U
                and ub.ext-classif.classif-name = 'clients-esys':U
                and ub.ext-classif.db-num = 0
                and ub.ext-classif.key#_one = v-ext-sys
                and ub.ext-classif.CharKey_Three = tt-wb-hndls.shippregid
                no-error.
            if available (ub.ext-classif) then do:
              find first buf_clients where buf_clients.obj-type = entry (2, ub.ext-classif.uniq-key-rec, chr(3)) and buf_clients.obj-code = integer (entry (3, ub.ext-classif.uniq-key-rec, chr(3))) no-error.
              if available (buf_clients)
                then do:
                  tt-wb-hndls.cli = buf_clients.obj-type + string (buf_clients.obj-code).
                  tt-wb-hndls.cliname = buf_clients.obj-name.
                end.
            end.
            assign
              tt-wb-hndls.wbregid = entry (5, buf_clob-bind-wb-hndls.descr, chr(4)) no-error.
            if tt-wb-hndls.wbregid = ""
            then do:
              if GetHndlTable(1, tt-wb-hndls.uniq-key-rec) <> ?
              then do:
                find first tt-wb-header no-error.
                find first buf_clob-bind-temp where recid (buf_clob-bind-temp) = recid (buf_clob-bind-wb-hndls) exclusive-lock.
                if available (tt-wb-header)
                  then
                    assign
                      tt-wb-hndls.wbregid = tt-wb-header.wbregid
                      entry (5, buf_clob-bind-temp.descr, chr(4)) = tt-wb-header.wbregid when available (buf_clob-bind-temp).
                    .
                release buf_clob-bind-temp.
              end.
            end.
            find first buf_trn-doc where buf_trn-doc.doc-code = tt-wb-hndls.trn-doc-code no-error.
            if available (buf_trn-doc)
              then
                assign
                tt-wb-hndls.status_ = buf_trn-doc.status_ + (if buf_trn-doc.flag_ then "+" else "-")
                tt-wb-hndls.isWB = true.
              else tt-wb-hndls.isWB = false.
          end.
          if valid-object (egaisTTS)
            then delete object egaisTTS.
          return buffer tt-wb-hndls:handle.
        end.
      when 7 then
        do:
          SettingsTTList = "10,yes;;;".
          empty temp-table tt-wb-act-hndls.
          for each buf_clob-bind where buf_clob-bind.resource-type = 'egais-wb-act':U:
            create tt-wb-act-hndls.
            assign
              tt-wb-act-hndls.wbregid  = entry (1, buf_clob-bind.descr, chr(4))
              tt-wb-act-hndls.act-date = date (entry (2, buf_clob-bind.descr, chr(4)))
              tt-wb-act-hndls.num      = entry (3, buf_clob-bind.descr, chr(4))
              tt-wb-act-hndls.status_  = entry (4, buf_clob-bind.descr, chr(4))
              .
          end.
          return buffer tt-wb-act-hndls:handle.
        end.
      when 12 then
        do:
          empty temp-table tt-ticket.
          ii = 0.
          find current tt-wb-hndls no-error.
          find first ub.clob-bind where (available (tt-wb-hndls) and ub.clob-bind.resource-type = 'egais-wb':U and ub.clob-bind.uniq-key-rec = tt-wb-hndls.uniq-key-rec) no-error.
          for each buf_clob-bind where (buf_clob-bind.resource-type = 'egais-ticket':U and buf_clob-bind.uniq-key-rec begins inWbIdentity)
                                      or (available (ub.clob-bind) and not buf_clob-bind.uniq-key-rec begins inWbIdentity and buf_clob-bind.resource-type = 'egais-ticket':U and lookup (buf_clob-bind.field-name_, ub.clob-bind.field-name_) > 0)
                                      or can-find (first buf_ext-classif where buf_ext-classif.classif-name = 'egais-transId':U
                                        and buf_ext-classif.db-num = 0
                                        and buf_ext-classif.key#_one = v-ext-sys
                                        and buf_ext-classif.CharKey_One = inWbIdentity
                                        and buf_ext-classif.CharKey_Two = buf_clob-bind.field-name_):
            ii = ii + 1.
            find first buf_clob-data where buf_clob-data.db-num = buf_clob-bind.db-num and buf_clob-data.int64-id = buf_clob-bind.int64-id no-error.
            createhDoc(recid (buf_clob-data), string (ii) + "temp.xml", output hDoc).
            prsXMLDocWB:IsToClearTable = false.
            prsXMLDocWB:ParseRec (hDoc, input-output table tt-ticket).
            prsXMLDocWB:IsToClearTable = true.
          end.
          for each buf_clob-bind where buf_clob-bind.resource-type = 'egais-wb-ticket':U and buf_clob-bind.uniq-key-rec begins inWbIdentity :
            ii = ii + 1.
            find first buf_clob-data where buf_clob-data.db-num = buf_clob-bind.db-num and buf_clob-data.int64-id = buf_clob-bind.int64-id no-error.
            createhDoc(recid (buf_clob-data), string (ii) + "temp.xml", output hDoc).
            prsXMLDocWB:IsToClearTable = false.
            prsXMLDocWB:ParseRec (hDoc, input-output table tt-ticket).
            prsXMLDocWB:IsToClearTable = true.
          end.
          return buffer tt-ticket:handle.
        end.
      when 13 then
        do:
          empty temp-table tt-ticket.
          for each buf_clob-bind where
            ((buf_clob-bind.resource-type = 'egais-ticket':U or buf_clob-bind.resource-type = 'egais-wb-ticket':U) and buf_clob-bind.uniq-key-rec matches "*" + inWbIdentity + "*")
            or (can-find (first buf_ext-classif where buf_ext-classif.classif-name = 'egais-transId':U
                  and buf_ext-classif.db-num = 0
                  and buf_ext-classif.key#_one = v-ext-sys
                  and buf_ext-classif.CharKey_One = inWbIdentity
                  and buf_ext-classif.CharKey_Two = buf_clob-bind.field-name_))
            :
            ii = ii + 1.
            find first buf_clob-data where buf_clob-data.db-num = buf_clob-bind.db-num and buf_clob-data.int64-id = buf_clob-bind.int64-id no-error.
            createhDoc(recid (buf_clob-data), string (ii) + "temp.xml", output hDoc).
            prsXMLDocWB:IsToClearTable = false.
            prsXMLDocWB:ParseRec (hDoc, input-output table tt-ticket).
            prsXMLDocWB:IsToClearTable = true.
          end.
          find first tt-ticket where tt-ticket.regid <> "" no-error.
          if available (tt-ticket) then do:
            find first buf_doc-attr no-lock where buf_doc-attr.attr-code = 'negais':U and buf_doc-attr.doc-code = inWbIdentity no-error.
            if not available (buf_doc-attr)
            then do:
              create buf_doc-attr.
              assign
                buf_doc-attr.doc-code = inWbIdentity
                buf_doc-attr.attr-value = tt-ticket.regid
                buf_doc-attr.attr-code = 'negais':U
              .
            end.
            for each buf_clob-bind where buf_clob-bind.resource-type = 'egais-wb-act':U and buf_clob-bind.uniq-key-rec matches "*" + buf_doc-attr.attr-value + "*" :
              find first buf_clob-data where buf_clob-data.db-num = buf_clob-bind.db-num and buf_clob-data.int64-id = buf_clob-bind.int64-id no-error.
              create tt-ticket.
              assign
                tt-ticket.regid = entry (1, buf_clob-bind.descr, chr(4))
                tt-ticket.ticket-date = string (iso-date (date (entry (2, buf_clob-bind.descr, chr(4)))))
                tt-ticket.doc = entry (3, buf_clob-bind.descr, chr(4))
                tt-ticket.status_ = entry (4, buf_clob-bind.descr, chr(4)).
              createhDoc(recid (buf_clob-data), "temp.xml", output hDoc).
              prsXMLDocWB:ParseRec (hDoc, input-output table tt-wb-act-header, input-output table tt-wb-act-gds-EG).
              find first tt-wb-act-header no-error.
              if available (tt-wb-act-header)
              then do:
                tt-ticket.comment = tt-wb-act-header.note.
                find first ub.doc-attr exclusive-lock where ub.doc-attr.doc-code = inWbIdentity and ub.doc-attr.attr-code = 'egais':U no-error.
                if not available (ub.doc-attr)
                then do:
                  create ub.doc-attr.
                  assign
                    ub.doc-attr.doc-code = buf_doc-attr.doc-code
                    ub.doc-attr.attr-code = 'egais':U
                  .
                end.
                ub.doc-attr.attr-value = tt-wb-act-header.status_.
                release ub.doc-attr.
                tt-wb-hndls.EGAISSts = tt-wb-act-header.status_.
              end.
            end.
          end.
          return buffer tt-ticket:handle.
        end.
      when 5 then
        do:
          SettingsTTList = "20,yes;;;12,yes;9,yes;20,yes;10,yes;;6,yes;12,yes;;;30,yes;10,yes;;;;".
          empty temp-table tt-wb-hndls.
          egaisTTS = new TransferToShop (ObjType, ObjCode, v-FS-RAR, v-ext-sys).
          egaisTTS:DbNum =  DbNum.
          egaisTTS:User_Id = User_Id.
          bh-act-tts-header = egaisTTS:GetHndlTable(3, "").
          for each buf_doc-attr no-lock where buf_doc-attr.attr-code = 'negais':U:
            for each buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_doc-attr.doc-code and buf_trn-doc.status_ = 'факт':U and lookup (buf_trn-doc.doc-type, 'при,возврат':U) > 0 :
              if ObjCode <> buf_trn-doc.obj-code or ObjType <> buf_trn-doc.obj-type
                then next.
              find first ub.doc-attr no-lock where ub.doc-attr.doc-code = buf_trn-doc.doc-code and ub.doc-attr.attr-code = 'egais':U no-error.
              find first buf_clients where buf_clients.obj-code = buf_trn-doc.cli-code and buf_clients.obj-type = buf_trn-doc.cli-type no-lock.
              find first ub.ext-classif no-lock
                where ub.ext-classif.classif-subject = 'clients':U
                  and ub.ext-classif.classif-name = 'clients-esys':U
                  and ub.ext-classif.db-num = 0
                  and ub.ext-classif.key#_one = v-ext-sys
                  and ub.ext-classif.uniq-key-rec = 'clients':U + chr(3) + buf_trn-doc.cli-type + chr(3) + string (buf_trn-doc.cli-code)
                  no-error.
              find first ub.doc-attr no-lock where ub.doc-attr.doc-code = buf_trn-doc.doc-code and ub.doc-attr.attr-code = 'egais':U no-error.
              create tt-wb-hndls.
              assign
                tt-wb-hndls.wb-date      = buf_trn-doc.doc-date
                tt-wb-hndls.num          = entry (2, buf_doc-attr.attr-value, chr(6))
                tt-wb-hndls.trn-doc-code = buf_trn-doc.doc-code
                tt-wb-hndls.cliname = buf_clients.obj-name
                tt-wb-hndls.obj = buf_trn-doc.obj-type + string (buf_trn-doc.obj-code)
                tt-wb-hndls.obj = buf_trn-doc.obj-type + string (buf_trn-doc.obj-code)
                tt-wb-hndls.cli   = buf_trn-doc.cli-type + string (buf_trn-doc.cli-code)
                tt-wb-hndls.uniq-key-rec = buf_doc-attr.attr-value
                tt-wb-hndls.status_      = buf_trn-doc.status_ + (if buf_trn-doc.flag_ then "+" else "-")
                tt-wb-hndls.EGAISSts     = if available (ub.doc-attr) and not ub.doc-attr.attr-value <> "" then ub.doc-attr.attr-value else ""
                tt-wb-hndls.wbregid      = entry (1, buf_doc-attr.attr-value, chr(6)) no-error.
                if tt-wb-hndls.EGAISSts <> "" and tt-wb-hndls.EGAISSts <> "Accepted"
                then do:
                  find first buf_clob-bind where buf_clob-bind.resource-type = 'egais-wb':U and buf_clob-bind.descr matches "*" + tt-wb-hndls.wbregid + "*" no-lock no-error.
                  if available (buf_clob-bind)
                  then do:
                    assign
                      tt-wb-hndls.EGAISSts = entry (10, buf_clob-bind.descr, chr(4)) when num-entries (buf_clob-bind.descr, chr(4)) > 9.
                    if not available (ub.doc-attr)
                    then do:
                      create ub.doc-attr.
                      assign
                        ub.doc-attr.doc-code = buf_trn-doc.doc-code
                        ub.doc-attr.attr-code = 'egais':U
                      .
                    end.
                    else do:
                      find current ub.doc-attr exclusive-lock.
                    end.
                    if tt-wb-hndls.EGAISSts <> ub.doc-attr.attr-value
                    then do:
                      assign
                        ub.doc-attr.attr-value = entry (10, buf_clob-bind.descr, chr(4)) when num-entries (buf_clob-bind.descr, chr(4)) > 9 and tt-wb-hndls.EGAISSts = "".
                    end.
                  end.
                  find current ub.doc-attr no-lock.
                end.
                if tt-wb-hndls.EGAISSts = ""
                then do:
                  find first buf_clob-bind where buf_clob-bind.resource-type = 'egais-wb':U and buf_clob-bind.descr matches "*" + tt-wb-hndls.wbregid + "*" no-lock no-error.
                  if available (buf_clob-bind)
                  then do:
                    assign
                      tt-wb-hndls.EGAISSts = entry (10, buf_clob-bind.descr, chr(4)) when num-entries (buf_clob-bind.descr, chr(4)) > 9.
                    if not available (ub.doc-attr)
                    then do:
                      create ub.doc-attr.
                      assign
                        ub.doc-attr.doc-code = buf_trn-doc.doc-code
                        ub.doc-attr.attr-code = 'egais':U
                      .
                    end.
                    else do:
                      find current ub.doc-attr exclusive-lock.
                    end.
                    assign
                      ub.doc-attr.attr-value = entry (10, buf_clob-bind.descr, chr(4)) when num-entries (buf_clob-bind.descr, chr(4)) > 9.
                    find current ub.doc-attr no-lock.
                  end.
                end.
                assign
                  tt-wb-hndls.wb-type      = 'приход внешний':U when buf_trn-doc.ext-doc-type = 'ie':U
                  tt-wb-hndls.wb-type      = 'возврат внешний':U when buf_trn-doc.ext-doc-type = 're':U
                  tt-wb-hndls.wb-type      = 'возврат внутренний':U when buf_trn-doc.ext-doc-type = 'rv':U
                  tt-wb-hndls.wb-type      = 'приход внутренний':U when buf_trn-doc.ext-doc-type = 'iv':U
                .
                bh-act-tts-header:find-first (substitute ("where tt-act-header.num matches '*&1*'", trn-doc-code), no-lock ) no-error.
                if bh-act-tts-header:available
                then do:
                  tt-wb-hndls.tts = bh-act-tts-header:buffer-field ("num"):buffer-value ().
                  if num-entries (bh-act-tts-header:buffer-field ("RegID"):buffer-value (), chr(5) ) < 2
                  then do:
                    if bh-act-tts-header:buffer-field ("is-sent"):buffer-value = true
                    then do:
                      tt-wb-hndls.tts-status_ = 'Отправлен'.
                    end.
                    else do:
                      tt-wb-hndls.tts-status_ = 'Новый'.
                    end.
                  end.
                  else do:
                    case entry(2, bh-act-tts-header:buffer-field ("RegID"):buffer-value, chr(5)):
                    when "R" then do:
                      tt-wb-hndls.tts-status_ = 'Отклонен'.
                    end.
                    when "A" then do:
                      tt-wb-hndls.tts-status_ = 'Принят'.
                    end.
                    end case.
                  end.
                end.
                tt-wb-hndls.is-sent = if available (ub.doc-attr) then "да" else "".
                entry (1, tt-wb-hndls.uniq-key-rec, chr(6)) = "".
                tt-wb-hndls.uniq-key-rec = left-trim (tt-wb-hndls.uniq-key-rec, chr(6)).
                if available (ub.ext-classif)
                  then tt-wb-hndls.shippregid = ub.ext-classif.CharKey_Three.
            end.
          end.
          if valid-object (egaisTTS)
            then delete object egaisTTS.
          return buffer tt-wb-hndls:handle.
        end.
      when 4 then
        do:
          SettingsTTList = "20,no;;;12,yes;9,yes;20,yes;17,yes;10,yes;6,yes;20,yes;;1,no;1,no;1,no;1,no;1,no;1,no;1,no".
          empty temp-table tt-wb-hndls.
            for each buf_trn-doc no-lock where buf_trn-doc.obj-code = ObjCode and buf_trn-doc.obj-type = ObjType
              and (buf_trn-doc.status_ = 'факт':U or buf_trn-doc.status_ = 'разрешен':U)
              and (buf_trn-doc.ext-doc-type = 'ep':U or buf_trn-doc.ext-doc-type = 'ev':U or buf_trn-doc.ext-doc-type = 'ee':U) :
              find first buf_ext-classif no-lock where buf_ext-classif.classif-subject = 'clients':U
                and buf_ext-classif.classif-name = 'clients-esys':U
                and buf_ext-classif.db-num = 0
                and buf_ext-classif.key#_one = v-ext-sys
                and buf_ext-classif.uniq-key-rec = 'clients':U + chr(3) + buf_trn-doc.cli-type + chr(3) + string (buf_trn-doc.cli-code)
                no-error.
              if not available (buf_ext-classif)
                then next.
              find first buf_doc-attr no-lock where buf_doc-attr.doc-code = buf_trn-doc.doc-code and buf_doc-attr.attr-code = 'egais':U  no-error.
              create tt-wb-hndls.
              assign
                tt-wb-hndls.wb-date      = buf_trn-doc.doc-date
                tt-wb-hndls.trn-doc-code = buf_trn-doc.doc-code
                tt-wb-hndls.obj          = buf_trn-doc.obj-type + string (buf_trn-doc.obj-code)
                tt-wb-hndls.cli          = buf_trn-doc.cli-type + string (buf_trn-doc.cli-code)
                tt-wb-hndls.cliname      = buf_trn-doc.cli-name
                tt-wb-hndls.shippregid   = buf_ext-classif.charkey_three when available (buf_ext-classif)
                tt-wb-hndls.wb-type      = 'возврат пост.':U when buf_trn-doc.ext-doc-type = 'ep':U
                tt-wb-hndls.wb-type      = 'расход внутренний':U when buf_trn-doc.ext-doc-type = 'ev':U
                tt-wb-hndls.wb-type      = 'расход внешний':U when buf_trn-doc.ext-doc-type = 'ee':U
                tt-wb-hndls.EGAISSts     = if available (buf_doc-attr) and not buf_doc-attr.attr-value = '1':U then buf_doc-attr.attr-value else ""
                tt-wb-hndls.EGAISSts     = 'Накладная отправлена':U when  available (buf_doc-attr) and buf_doc-attr.attr-value = '1':U
                tt-wb-hndls.EGAISSts     = "не отправлена" when not available (buf_doc-attr)
                tt-wb-hndls.wbregid      = buf_doc-attr.attr-value when available (buf_doc-attr)
                tt-wb-hndls.status_      = buf_trn-doc.status_ + (if buf_trn-doc.flag_ then "+" else "-")
              .
            end.
          return buffer tt-wb-hndls:handle.
        end.
      when 10 or
      when 11 then
        do:
          empty temp-table tt-wb-header.
          empty temp-table tt-wb-gds-EG.
          ii = 0.
          find first buf_trn-doc no-lock where buf_trn-doc.doc-code = inWbIdentity no-error.
          if not available (buf_trn-doc)
          then do:
            Msg = "Не найдена накладная" + inWbIdentity.
            StatusErr = true.
            return ?.
          end.
          if buf_trn-doc.fact-date = ?
          then do:
            Msg = "Неизвестная фактическая дата накладной: " + inWbIdentity + ". Установите фактическую дату в накладной.".
            StatusErr = true.
            return ?.
          end.
          create tt-wb-header.
          assign
            tt-wb-header.Identity = buf_trn-doc.doc-code
            tt-wb-header.wb-type = "WBReturnFromMe" when buf_trn-doc.ext-doc-type = 'ep':U
            tt-wb-header.wb-type = "WBInvoiceFromMe" when buf_trn-doc.ext-doc-type = 'ev':U or buf_trn-doc.ext-doc-type = 'ee':U
            tt-wb-header.wb-date = buf_trn-doc.fact-date
            tt-wb-header.cli-code = buf_trn-doc.cli-code
            tt-wb-header.cli-type = buf_trn-doc.cli-type
            tt-wb-header.obj-type = buf_trn-doc.obj-type
            tt-wb-header.obj-code = buf_trn-doc.obj-code
          .
          find first buf_ext-classif no-lock where buf_ext-classif.classif-subject = 'clients':U
            and buf_ext-classif.classif-name = 'clients-esys':U
            and buf_ext-classif.db-num = 0
            and buf_ext-classif.key#_one = v-ext-sys
            and buf_ext-classif.CharKey_Two = buf_trn-doc.obj-type + string (buf_trn-doc.obj-code) no-error.
          if not available (buf_ext-classif)
          then do:
            Msg = "Не найден клиент ЕГАИС для объекта " + buf_trn-doc.obj-type + string (buf_trn-doc.obj-code).
            StatusErr = true.
            return ?.
          end.
          tt-wb-header.regID-Ship = buf_ext-classif.CharKey_Three.
          find first buf_ext-classif no-lock where buf_ext-classif.classif-subject = 'clients':U
            and buf_ext-classif.classif-name = 'clients-esys':U
            and buf_ext-classif.db-num = 0
            and buf_ext-classif.key#_one = v-ext-sys
            and buf_ext-classif.uniq-key-rec = 'clients':U + chr(3) + buf_trn-doc.cli-type + chr(3) + string (buf_trn-doc.cli-code) no-error.
          if not available (buf_ext-classif)
          then do:
            Msg = "Не найден клиент ЕГАИС для контрагента " + buf_trn-doc.cli-type + string (buf_trn-doc.cli-code).
            StatusErr = true.
            return ?.
          end.
          tt-wb-header.regID-Cons = buf_ext-classif.CharKey_Three.
          for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code:
            for each buf_parts no-lock where
              buf_parts.obj-type = buf_trn-doc.obj-type and
              buf_parts.obj-code = buf_trn-doc.obj-code and
              buf_parts.artic = buf_doc-line.artic and
              buf_parts.prod-type = buf_doc-line.prod-type and
              buf_parts.prod-code = buf_doc-line.prod-code and
              buf_parts.out-code = buf_trn-doc.doc-code:
              ii = ii + 1.
              find first buf_gds no-lock where buf_gds.artic = buf_parts.artic and buf_gds.prod-code = buf_parts.prod-code and buf_gds.prod-type = buf_parts.prod-type.
              if num-entries (buf_parts.alc-ref-ab-path, ",") < 3
              then do:
                Msg = "В алкогольных атрибутах по партии отсутсвует алкогольный код и код группы для товара - " + string (buf_gds.gds-code) + ".".
                StatusErr = true.
                return ?.
              end.
              find first ub.gds-dtl where
                    ub.gds-dtl.doc-code = buf_doc-line.doc-code
                and ub.gds-dtl.artic = buf_parts.artic
                and ub.gds-dtl.prod-type = buf_parts.prod-type
                and ub.gds-dtl.prod-code = buf_parts.prod-code no-error.
              if not available (ub.gds-dtl)
              then do:
                Msg = "Отсутствует gds-dtl - " + string (buf_parts.artic) + ".".
                StatusErr = true.
                return ?.
              end.
              create tt-wb-gds-EG.
              assign
                tt-wb-gds-EG.Identity = string (ii)
                tt-wb-gds-EG.gds-code = buf_gds.gds-code
                tt-wb-gds-EG.qnty = buf_parts.fact-qnty / buf_parts.cli-base-rate
                tt-wb-gds-EG.price = buf_parts.price-cli when buf_trn-doc.ext-doc-type = 'ep':U
                tt-wb-gds-EG.price = ub.gds-dtl.price-rubl when buf_trn-doc.ext-doc-type = 'ev':U or buf_trn-doc.ext-doc-type = 'ee':U
                tt-wb-gds-EG.refA = entry (1, buf_parts.alc-ref-ab-path, ",")
                tt-wb-gds-EG.refB = entry (2, buf_parts.alc-ref-ab-path, ",")
                tt-wb-gds-EG.alc-code = entry (3, buf_parts.alc-ref-ab-path, ",")
                tt-wb-gds-EG.alc-type-code = entry (4, buf_parts.alc-ref-ab-path, ",")
              .
              if tt-wb-gds-EG.refA = "" or tt-wb-gds-EG.refB = "" or tt-wb-gds-EG.refA = ? or tt-wb-gds-EG.refB = ?
              then do:
                Msg = "Не найдена справка А или Б к партии - " + buf_parts.out-code + ". Товар - " + string (buf_gds.gds-code) + "  " + buf_gds.gds-name.
                StatusErr = true.
                return ?.
              end.
              find first ub.alc-type-gds
                   where ub.alc-type-gds.gds-code = buf_gds.gds-code
                     and ub.alc-type-gds.create-user-db-num = 0 no-lock no-error.
              if not available (ub.alc-type-gds)
              then do:
                Msg = "Не задана алкогольная группа у товара " + string (buf_gds.gds-code).
                StatusErr = true.
                return ?.
              end.
              find first ub.alc-type where ub.alc-type-gds.alc-type-inner-code = ub.alc-type.alc-type-inner-code no-lock no-error.
              if not available (ub.alc-type)
              then do:
                Msg = "Не найдена алкогольная группа у товара" + string (buf_gds.gds-code).
                StatusErr = true.
                return ?.
              end.
              alcTypeAttrObj:GetAlcTypeAttr ( input tt-wb-gds-EG.alc-type-code,
                                       input   "alc-min-price",
                                       output  minPrice
                                    ) no-error.
              if tt-wb-gds-EG.price < minPrice * buf_gds.cli-base-rate
              then do:
              Msg = Msg + (if Msg <> "" then chr(10) else '')
                + substitute ("Для товара &2/&1 &3 цена в накладной &4 меньше допустимой &5 по группе &6.", tt-wb-gds-EG.alc-code, buf_gds.gds-code, tt-wb-gds-EG.gds-name, tt-wb-gds-EG.price / buf_gds.cli-base-rate, minPrice, tt-wb-gds-EG.alc-type-code).
              end.
              assign
                tt-wb-gds-EG.ms-base = buf_gds.ms-base
                tt-wb-gds-EG.proof = buf_gds.proof
                tt-wb-gds-EG.alc-type-code = ub.alc-type.alc-type-code
              .
              if buf_doc-line.unit-cli <> buf_gds.unit-base and buf_doc-line.unit-cli > ""
              then do:
                tt-wb-gds-EG.UnitType = 'Unpacked'.
                if tt-wb-header.UnitType = '' or  tt-wb-header.UnitType = 'Packed' then tt-wb-header.UnitType = 'Unpacked'.
              end.
              else do:
                tt-wb-gds-EG.UnitType = 'Packed'.
                if tt-wb-header.UnitType <> 'Unpacked' then tt-wb-header.UnitType = 'Packed'.
              end.
            end.
          end.
        end.
    end case.
  end.
  method override public logical SendRequestUTM ():
    def var ii        as int    no-undo.
    def var xml-cont  as char   no-undo.
    def var verDocXsd as char   no-undo.
    def var respValue as handle no-undo.
    assign
      StatusErr = false
      Msg       = ""
      .
    output stream outstr close.
    if IsSent
      then
    do:
      Msg = "Запрос уже был отправлен".
      StatusErr = true.
      return no.
    end.
    do trans:
      os-delete "RespTTNAct.xml".
      os-delete value (search ("RespTTNAct.xml")).
      assign
        inFileName = "RespTTNAct.xml"
        .
      find first tt-wb-header.
      find first tt-wb-hndls where tt-wb-header.uniq-key-rec = tt-wb-hndls.uniq-key-rec no-error.
      if available (tt-wb-hndls)
        then
      do:
        if not (tt-wb-hndls.wb-type matches "*расход*" or (tt-wb-hndls.wb-type matches "*возврат*"
              and not tt-wb-hndls.wb-type matches "*возврат от покупателя*" and not tt-wb-hndls.wb-type matches "*возврат внешний*"
              and not tt-wb-hndls.wb-type matches "*возврат вн.*")) then
        do:
          output stream outstr to value ("TTNAct.xml") convert target "UTF-8".
          outData = GetXMLAct() no-error.
          if outData = ? or outData = ""
          then do:
            output stream outstr close.
            return false.
          end.
          put stream outstr unformatted outData.
          put stream outstr skip.
          output stream outstr close.
          case tt-wb-header.verXSD:
            when "WayBill"
              then cmd = substitute ("&1 --connect-timeout 1 -F xml_file=@&2 &3/opt/in/WayBillAct >&4", search ("exe/curl.exe"), search ("TTNAct.xml"), ConPar, inFileName).
            when "WayBill_v2"
              then cmd = substitute ("&1 --connect-timeout 1 -F xml_file=@&2 &3/opt/in/WayBillAct_v2 >&4", search ("exe/curl.exe"), search ("TTNAct.xml"), ConPar, inFileName).
          end case.
          os-command value (cmd).
          file-info:file-name = search (inFileName).
          if search (inFileName) <> ? and file-info:file-size > 0
            then
          do:
            respValue = ParseRequest (inFileName).
            if respValue = ?
              then
            do:
              assign
                StatusErr = true
                Msg       = "Не удалось разобрать данные от УТМ"
                .
              undo, return false.
            end.
            if not StatusErr
              then
              ReplyId = respValue:node-value.
            else
            do:
              assign
                StatusErr = true
                Msg       = respValue:node-value
                .
              undo, return false.
            end.
          end.
          else
          do:
            assign
              StatusErr = true
              Msg       = "Не удалось отправить акт на накладную в УТМ"
              .
            undo, return false.
          end.
          find current buf_clob-bind exclusive-lock.
          entry (7, buf_clob-bind.descr, chr(4)) = "да".
          buf_clob-bind.field-name_ = buf_clob-bind.field-name_ + ',' + ReplyId.
          find current buf_clob-bind no-lock.
          tt-wb-hndls.is-sent = "да".
        end.
        else
        do:
          inFileName = "TTN.xml".
          WriteXMLWB (inFileName).
          if StatusErr
          then
          do:
            return false.
          end.
          case tt-wb-header.verXSD:
          when 'WayBill' then do:
            cmd = substitute ("&1 --connect-timeout 1 -F xml_file=@&2 &3/opt/in/WayBill >&4", search ("exe/curl.exe"), search (inFileName), ConPar, "RespTTN.xml").
          end.
          when 'WayBill_v2' then do:
            cmd = substitute ("&1 --connect-timeout 1 -F xml_file=@&2 &3/opt/in/WayBill_v2 >&4", search ("exe/curl.exe"), search (inFileName), ConPar, "RespTTN.xml").
          end.
          end case.
          os-command value (cmd).
          file-info:file-name = search ("RespTTN.xml").
          if search ("RespTTN.xml") <> ? and file-info:file-size > 0
            then
          do:
            respValue = ParseRequest ("RespTTN.xml").
            if respValue = ?
              then
            do:
              assign
                StatusErr = true
                Msg       = "Не удалось разобрать данные от УТМ"
                .
              undo, return false.
            end.
            if not StatusErr
              then
              ReplyId = respValue:node-value.
            else
            do:
              assign
                StatusErr = true
                Msg       = respValue:node-value
                .
              undo, return false.
            end.
          end.
          else
          do:
            assign
              StatusErr = true
              Msg       = "Не удалось отправить накладную в УТМ"
              .
            undo, return false.
          end.
          find first buf_ext-classif no-lock where
                buf_ext-classif.classif-name = 'egais-transId':U
            and buf_ext-classif.db-num = 0
            and buf_ext-classif.key#_one = v-ext-sys
            and buf_ext-classif.CharKey_One = tt-wb-header.Identity
            and buf_ext-classif.CharKey_Two = ReplyId no-error.
          if not available (buf_ext-classif)
          then do:
            create buf_ext-classif.
            assign
              buf_ext-classif.classif-name = 'egais-transId':U
              buf_ext-classif.db-num = 0
              buf_ext-classif.key#_one = v-ext-sys
              buf_ext-classif.CharKey_One = tt-wb-header.Identity
              buf_ext-classif.CharKey_Two = ReplyId
            no-error.
          end.
        end.
      end.
      else do:
        assign
          StatusErr = true
          Msg       = "Не найдена clob-bind по ключу - " + tt-wb-header.uniq-key-rec
          .
        return false.
      end.
    end.
  end.
  method public logical SendWBActRejUTM (inWbRegId as char):
    def var VerXSDShip   as character no-undo.
    def var respValue as handle no-undo.
    os-delete "RespTTNAct.xml".
    os-delete value (search ("RespTTNAct.xml")).
    assign
      inFileName = "RespTTNAct.xml"
      .
    find first tt-wb-header.
    find first buf_ext-classif-attr no-lock where buf_ext-classif-attr.classif-subject = 'clients':U
      and buf_ext-classif-attr.classif-name = 'clients-esys':U
      and buf_ext-classif-attr.db-num = 0
      and buf_ext-classif-attr.key#_one = v-ext-sys
      and buf_ext-classif-attr.CharKey_Three = tt-wb-header.regID-Ship
      and buf_ext-classif-attr.attr-code = "egais-cli-info" no-error.
    if available (buf_ext-classif-attr)
    then
      assign
        VerXSDShip = entry (1, buf_ext-classif-attr.attr-value, chr(4))
      no-error.
    else VerXSDShip = 'WayBill'.
    output stream outstr close.
    output stream outstr to value ("TTNAct.xml") convert target "UTF-8".
    case tt-wb-header.verXSD:
    when "WayBill_v2"
    then
      outData = substitute ('<?xml version="1.0" encoding="UTF-8"?><ns:Documents Version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01" xmlns:oref="http://fsrar.ru/WEGAIS/ClientRef" xmlns:pref="http://fsrar.ru/WEGAIS/ProductRef" xmlns:wa="http://fsrar.ru/WEGAIS/ActTTNSingle_v2"><ns:Owner><ns:FSRAR_ID>&1</ns:FSRAR_ID></ns:Owner><ns:Document><ns:WayBillAct_v2><wa:Header><wa:IsAccept>&2</wa:IsAccept><wa:ACTNUMBER>&3</wa:ACTNUMBER><wa:ActDate>&4</wa:ActDate><wa:WBRegId>&5</wa:WBRegId><wa:Note>&6</wa:Note></wa:Header><wa:Content>', v-FS-RAR, 'Rejected', time, iso-date (date (now)), inWbRegId, "Отказ") + '</wa:Content></ns:WayBillAct_v2></ns:Document></ns:Documents>'.
    when "WayBill"
    then
      outData = substitute ('<?xml version="1.0" encoding="UTF-8"?><ns:Documents Version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01" xmlns:oref="http://fsrar.ru/WEGAIS/ClientRef" xmlns:pref="http://fsrar.ru/WEGAIS/ProductRef" xmlns:wa="http://fsrar.ru/WEGAIS/ActTTNSingle"><ns:Owner><ns:FSRAR_ID>&1</ns:FSRAR_ID></ns:Owner><ns:Document><ns:WayBillAct><wa:Header><wa:IsAccept>&2</wa:IsAccept><wa:ACTNUMBER>&3</wa:ACTNUMBER><wa:ActDate>&4</wa:ActDate><wa:WBRegId>&5</wa:WBRegId><wa:Note>&6</wa:Note></wa:Header><wa:Content>', v-FS-RAR, 'Rejected', time, iso-date (date (now)), inWbRegId, "Отказ") + '</wa:Content></ns:WayBillAct></ns:Document></ns:Documents>'.
    end case.
    if outData = ? or outData = ""
    then do:
      output stream outstr close.
      return false.
    end.
    put stream outstr unformatted outData.
    put stream outstr skip.
    output stream outstr close.
    case tt-wb-header.verXSD:
      when "WayBill"
        then cmd = substitute ("&1 --connect-timeout 1 -F xml_file=@&2 &3/opt/in/WayBillAct >&4", search ("exe/curl.exe"), search ("TTNAct.xml"), ConPar, inFileName).
      when "WayBill_v2"
        then cmd = substitute ("&1 --connect-timeout 1 -F xml_file=@&2 &3/opt/in/WayBillAct_v2 >&4", search ("exe/curl.exe"), search ("TTNAct.xml"), ConPar, inFileName).
    end case.
    os-command value (cmd).
    file-info:file-name = search (inFileName).
    if search (inFileName) <> ? and file-info:file-size > 0
      then
    do:
      respValue = ParseRequest (inFileName).
      if respValue = ?
        then
      do:
        assign
          StatusErr = true
          Msg       = "Не удалось разобрать данные от УТМ"
          .
        undo, return false.
      end.
      if not StatusErr
        then
        ReplyId = respValue:node-value.
      else
      do:
        assign
          StatusErr = true
          Msg       = respValue:node-value
          .
        undo, return false.
      end.
    end.
    else
    do:
      assign
        StatusErr = true
        Msg       = "Не удалось отправить отказ на накладную в УТМ"
        .
      undo, return false.
    end.
    find first buf_ext-classif no-lock where
          buf_ext-classif.classif-name = 'egais-transId':U
      and buf_ext-classif.db-num = 0
      and buf_ext-classif.key#_one = v-ext-sys
      and buf_ext-classif.CharKey_One = tt-wb-header.Identity
      and buf_ext-classif.CharKey_Two = ReplyId no-error.
    if not available (buf_ext-classif)
    then do:
      create buf_ext-classif.
      assign
        buf_ext-classif.classif-name = 'egais-transId':U
        buf_ext-classif.db-num = 0
        buf_ext-classif.key#_one = v-ext-sys
        buf_ext-classif.CharKey_One = tt-wb-header.Identity
        buf_ext-classif.CharKey_Two = ReplyId
      no-error.
    end.
  end.
  method public logical SendReqRepealWBUTM (inWbRegId as char):
    def var VerXSDShip   as character no-undo.
    def var respValue as handle no-undo.
    os-delete "RespRequestRepealWB.xml".
    os-delete value (search ("RespRequestRepealWB.xml")).
    assign
      inFileName = "RespRequestRepealWB.xml"
      .
    output stream outstr close.
    find first tt-wb-header.
    output stream outstr to value ("RequestRepealWB.xml") convert target "UTF-8".
    outData = substitute ('<?xml version="1.0" encoding="UTF-8"?><ns:Documents Version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01" xmlns:qp="http://fsrar.ru/WEGAIS/RequestRepealWB"><ns:Owner><ns:FSRAR_ID>&1</ns:FSRAR_ID></ns:Owner><ns:Document><ns:RequestRepealWB><qp:ClientId>&2</qp:ClientId><qp:RequestNumber>&3</qp:RequestNumber><qp:RequestDate>&4</qp:RequestDate><qp:WBRegId>&5</qp:WBRegId></ns:RequestRepealWB></ns:Document></ns:Documents>', v-FS-RAR, v-FS-RAR, tt-wb-header.num + "-" + string (time), iso-date (now), tt-wb-header.wbregid).
    if outData = ? or outData = ""
    then do:
      output stream outstr close.
      return false.
    end.
    put stream outstr unformatted outData.
    put stream outstr skip.
    output stream outstr close.
    cmd = substitute ("&1 --connect-timeout 1 -F xml_file=@&2 &3/opt/in/RequestRepealWB >&4", search ("exe/curl.exe"), search ("RequestRepealWB.xml"), ConPar, inFileName).
    os-command value (cmd).
    file-info:file-name = search (inFileName).
    if search (inFileName) <> ? and file-info:file-size > 0
      then
    do:
      respValue = ParseRequest (inFileName).
      if respValue = ?
        then
      do:
        assign
          StatusErr = true
          Msg       = "Не удалось разобрать данные от УТМ"
          .
        undo, return false.
      end.
      if not StatusErr
        then
        ReplyId = respValue:node-value.
      else
      do:
        assign
          StatusErr = true
          Msg       = respValue:node-value
          .
        undo, return false.
      end.
    end.
    else
    do:
      assign
        StatusErr = true
        Msg       = "Не удалось отправить запрос в УТМ на отмену проведения накладной"
        .
      undo, return false.
    end.
    find first buf_ext-classif no-lock where
          buf_ext-classif.classif-name = 'egais-transId':U
      and buf_ext-classif.db-num = 0
      and buf_ext-classif.key#_one = v-ext-sys
      and buf_ext-classif.CharKey_One = tt-wb-header.wbregid
      and buf_ext-classif.CharKey_Two = ReplyId no-error.
    if not available (buf_ext-classif)
    then do:
      create buf_ext-classif.
      assign
        buf_ext-classif.classif-name = 'egais-transId':U
        buf_ext-classif.db-num = 0
        buf_ext-classif.key#_one = v-ext-sys
        buf_ext-classif.CharKey_One = tt-wb-header.wbregid
        buf_ext-classif.CharKey_Two = ReplyId
      no-error.
    end.
  end.
  method public logical ConfirmRepealWB (inWbRegId as char, inIsConfirm as char):
    def var respValue as handle no-undo.
    os-delete "RespConfirmRepealWB.xml".
    os-delete value (search ("RespConfirmRepealWB.xml")).
    assign
      inFileName = "RespConfirmRepealWB.xml"
      .
    output stream outstr close.
    find first tt-wb-header.
    output stream outstr to value ("ConfirmRepealWB.xml") convert target "UTF-8".
    outData = substitute ('<?xml version="1.0" encoding="UTF-8"?><ns:Documents Version="1.0" xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01" xmlns:wt= "http://fsrar.ru/WEGAIS/ConfirmRepealWB"><ns:Owner><ns:FSRAR_ID>&1</ns:FSRAR_ID></ns:Owner><ns:Document><ns:ConfirmRepealWB><wt:Header><wt:IsConfirm>&2</wt:IsConfirm><wt:ConfirmNumber>&3</wt:ConfirmNumber><wt:ConfirmDate>&4</wt:ConfirmDate><wt:WBRegId>&5</wt:WBRegId><wt:Note></wt:Note></wt:Header></ns:ConfirmRepealWB></ns:Document></ns:Documents>', v-FS-RAR, inIsConfirm, tt-wb-header.num + "-" + string (time), iso-date (date(now)), inWbRegId).
    if outData = ? or outData = ""
    then do:
      output stream outstr close.
      return false.
    end.
    put stream outstr unformatted outData.
    put stream outstr skip.
    output stream outstr close.
    cmd = substitute ("&1 --connect-timeout 1 -F xml_file=@&2 &3/opt/in/ConfirmRepealWB >&4", search ("exe/curl.exe"), search ("ConfirmRepealWB.xml"), ConPar, inFileName).
    os-command value (cmd).
    file-info:file-name = search (inFileName).
    if search (inFileName) <> ? and file-info:file-size > 0
      then
    do:
      respValue = ParseRequest (inFileName).
      if respValue = ?
        then
      do:
        assign
          StatusErr = true
          Msg       = "Не удалось разобрать данные от УТМ"
          .
        undo, return false.
      end.
      if not StatusErr
        then
        ReplyId = respValue:node-value.
      else
      do:
        assign
          StatusErr = true
          Msg       = respValue:node-value
          .
        undo, return false.
      end.
    end.
    else
    do:
      assign
        StatusErr = true
        Msg       = "Не удалось отправить подт./отказ в УТМ на запрос распроведения накладной"
        .
      undo, return false.
    end.
    find first buf_ext-classif no-lock where
          buf_ext-classif.classif-name = 'egais-transId':U
      and buf_ext-classif.db-num = 0
      and buf_ext-classif.key#_one = v-ext-sys
      and buf_ext-classif.CharKey_One = tt-wb-header.wbregid
      and buf_ext-classif.CharKey_Two = ReplyId no-error.
    if not available (buf_ext-classif)
    then do:
      create buf_ext-classif.
      assign
        buf_ext-classif.classif-name = 'egais-transId':U
        buf_ext-classif.db-num = 0
        buf_ext-classif.key#_one = v-ext-sys
        buf_ext-classif.CharKey_One = tt-wb-header.wbregid
        buf_ext-classif.CharKey_Two = ReplyId
      no-error.
    end.
  end.
  method override protected logical GetIsSent ():
    def var repId as char no-undo.
    def var glog  as log  no-undo.
  end.
  method protected handle ParseRequest (inFileName as char):
    define variable hRoot as handle  no-undo.
    define variable hDoc  as handle  no-undo.
    define variable hRow  as handle  no-undo.
    define variable hText as handle  no-undo.
    define variable ii    as integer no-undo.
    create x-document hDoc.
    create x-noderef  hRoot.
    create x-noderef  hRow.
    create x-noderef htext .
    hDoc:load ("file", inFileName, false).
    hDoc:encoding = "UTF-8".
    hDoc:get-document-element(hRoot) .
    do ii = 1 to hRoot:num-children:
      hRoot:get-child(hRow,ii).
      case hRow:name:
        when "url" then
          do:
            hRow:get-child (hText, 1) no-error.
            return hText.
          end.
        when "error" then
          do:
            hRow:get-child (hText, 1) no-error.
            StatusErr = true.
            return hText.
          end.
        otherwise
        do:
          return ?.
        end.
      end case.
    end.
  end.
  method public void GetDocUTM ():
    output stream str-formF1 close.
    output stream str-formF1 to "loWBgFormF1.txt" append.
    GetDocUTMPrivat ().
    output stream str-formF1 close.
    if valid-object (prgObj)
      then do:
        prgObj:hide-bar().
        delete object prgObj.
      end.
  end.
  method private void GetDocUTMPrivat ():
    define variable hRoot         as handle    no-undo.
    define variable hDoc          as handle    no-undo.
    define variable hRow          as handle    no-undo.
    define variable hText         as handle    no-undo.
    define variable ii            as integer   no-undo.
    define variable jj            as integer   no-undo.
    define variable ListOfQuery   as longchar  no-undo.
    define variable v-part-num    as integer   no-undo.
    define variable v-clob-db-num as integer   no-undo.
    define variable v-int64-id    as int64     no-undo.
    define variable v-info        as character no-undo.
    define variable ticketUKR     as character no-undo.
    define variable urlStr        as character no-undo.
    define variable extFormF1Obj  as class     ExtFormF1 no-undo .
    define variable extFormF1ValueObj as class ExtFormF1Value no-undo .
    define variable egaisFormF1 as class FormF1 no-undo.
    create x-document hDoc.
    create x-noderef  hRoot.
    create x-noderef  hRow.
    create x-noderef  hText.
    empty temp-table tt-analiz.
    assign
      inFileName = "ReceiptListOfQuery.xml"
      .
    if search ("ReceiptListOfQuery.xml") <> ? then os-delete value (inFileName).
    if search (inFileName) <> ? then os-delete value (inFileName).
    if FastDwnl then do:
      if search ( v-FS-RAR + '_ReceiptListOfQuery.xml' ) <> ?
      then do:
        copy-lob
          from  file v-FS-RAR + '_ReceiptListOfQuery.xml'
          to  object ListOfQuery
          no-convert
          no-error .
      end.
    end.
    cmd = substitute ("&1 --connect-timeout &2 -X GET &3/opt/out?refresh=true >&4",search ("exe/curl.exe"), TimeOut, ConPar, inFileName).
    os-command value (cmd).
    file-info:file-name = search (inFileName).
    if search (inFileName) = ? or file-info:file-size = 0
      then
    do:
      assign
        StatusErr = true
        Msg       = "Не удалось получить данные от УТМ"
        .
      return.
    end.
    hDoc:load ("file", inFileName, false).
    hDoc:get-document-element(hRoot) .
    prgObj = new ProgressBar (1, integer (hRoot:num-children / 2)).
    prgObj:can-cancel = true.
    prgObj:show-bar().
    url_:
    do ii = 1 to hRoot:num-children:
      hRoot:get-child(hRow,ii).
      case hRow:name:
        when "url" then
          do:
            hRow:get-child (hText, 1) no-error.
            urlStr = hText:node-value.
            prgObj:increment( substring (urlStr, if length (urlStr) <= 50 then 1 else length (urlStr) - 50)).
            if prgObj:is-canceled
              then return.
            if FastDwnl then
            do:
              if ListOfQuery <> ? and ListOfQuery <> "" and index (ListOfQuery, urlStr) > 0
                then next url_.
            end.
            case true:
              when urlStr matches ("*opt/out/WayBill/*") or urlStr matches ("*opt/out/WayBill_v2/*") then
                do:
                  os-delete "WayBill.xml".
                  os-delete value (search ("WayBill.xml")).
                  assign
                    inFileName = "WayBill.xml"
                    .
                  CmdParseXml(urlStr).
                  if StatusErr
                  then do:
                    message "Ошибка приема файла накланой: " v-info skip urlStr skip Msg skip " Прием документов будет продолжен" view-as alert-box.
                    StatusErr = false.
                    Msg = "".
                    next url_.
                  end.
                  create tt-analiz.
                  assign
                    tt-analiz.url_ = urlStr
                    tt-analiz.num = tt-wb-header.num
                    tt-analiz.wb-date = tt-wb-header.wb-date
                    tt-analiz.Identity = tt-wb-header.Identity
                    tt-analiz.wb-type = "накл"
                    tt-analiz.uniq-key-rec = tt-wb-header.num + chr(6) + string (tt-wb-header.wb-date) + chr(6) + tt-wb-header.regID-Ship + chr(6) + tt-wb-header.Identity
                    tt-analiz.nnOrder = ii
                    tt-analiz.resource-type = 'egais-wb':U
                  .
                  find first buf_tt-analiz where recid (buf_tt-analiz) <> recid (tt-analiz)
                    and buf_tt-analiz.wb-type = tt-analiz.wb-type
                    and buf_tt-analiz.uniq-key-rec = tt-analiz.uniq-key-rec no-error.
                  if available (buf_tt-analiz)
                  then do:
                    buf_tt-analiz.isMany = true.
                    tt-analiz.isMany = true.
                  end.
                  find first tt-wb-header no-error.
                  if not available (tt-wb-header)
                  then do:
                    message "Ошибка приема файла накланой: " v-info skip urlStr skip Msg skip " Прием документов будет продолжен" view-as alert-box.
                    StatusErr = false.
                    Msg = "".
                    next url_.
                  end.
                  find first tt-wb-info-client where tt-wb-info-client.wb-type-client = "Consignee".
                  for each buf_ext-classif no-lock where
                        buf_ext-classif.classif-subject = 'clients':U
                    and buf_ext-classif.classif-name = 'clients-esys':U
                    and buf_ext-classif.db-num = 0
                    and buf_ext-classif.key#_one = v-ext-sys
                    and buf_ext-classif.CharKey_Three = tt-wb-info-client.regID:
                    if available (buf_ext-classif) then
                    do:
                      tt-wb-header.obj-type = entry(2, buf_ext-classif.uniq-key-rec, chr(3)).
                      tt-wb-header.obj-code = integer(entry(3, buf_ext-classif.uniq-key-rec, chr(3))).
                    end.
                    find first buf_clients no-lock where buf_clients.obj-type = tt-wb-header.obj-type and buf_clients.obj-code = tt-wb-header.obj-code and buf_clients.db-num = DbNum no-error.
                    if available (buf_clients)
                      then leave.
                  end.
                  if not available (buf_clients)
                    then
                      assign
                        tt-wb-header.obj-type = ""
                        tt-wb-header.obj-code = 0
                      .
                  find first tt-wb-info-client where tt-wb-info-client.wb-type-client = "Shipper".
                  v-info = string (tt-wb-header.wb-date) + chr(4) + tt-wb-header.num + chr(4) + tt-wb-info-client.regID + chr(4) + tt-wb-header.Identity + chr(4) + tt-wb-header.wbregid + chr(4) + "нет" + chr(4) + "нет" + chr(4) + tt-wb-header.wb-type + chr(4) + tt-wb-header.obj-type + if tt-wb-header.obj-code = 0 or tt-wb-header.obj-code = ? then "" else string (tt-wb-header.obj-code).
                  if tt-wb-header.uniq-key-rec = ?
                  then do:
                    message "Ошибка приема файла накладной: " v-info skip urlStr skip Msg skip " Прием документов будет продолжен" view-as alert-box.
                    StatusErr = false.
                    Msg = "".
                    next url_.
                  end.
                  v-clob-db-num = ?.
                  v-int64-id = 0.
                  if can-find (first buf_clob-bind where (buf_clob-bind.uniq-key-rec = tt-wb-header.uniq-key-rec or buf_clob-bind.uniq-key-rec = tt-wb-header.Identity + chr(6) + tt-wb-header.regID-Ship) and buf_clob-bind.resource-type =  'egais-wb':U)
                    then next url_.
                  run gbl/file2clb.p ( input 'ДОБАВЛЕНИЕ':U
                    ,input ",yes"
                    ,input ?
                    ,input tt-wb-header.uniq-key-rec
                    ,input 'egais-wb':U
                    ,input v-info
                    ,input-output v-part-num
                    ,input 'egais-wb':U
                    ,input-output v-clob-db-num
                    ,input-output v-int64-id
                    ,input search (inFileName)
                    ,input ''
                    ) no-error .
                  if error-status:error then
                  do:
                    Msg = error-status:get-message(1) + chr(10) + return-value.
                    StatusErr = false.
                    next url_.
                  end.
                  extFormF1Obj = new ExtFormF1 (true).
                  for each tt-wb-gds-EG no-lock where tt-wb-gds-EG.importer-list <> "" and tt-wb-gds-EG.importer-list <> chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5):
                    put stream str-formF1 "----" now "-----" chr(10).
                    export stream str-formF1 tt-wb-gds-EG.
                    ExtFormF1Obj:OpenQueryExtFormF1 (tt-wb-gds-EG.refA, tt-wb-gds-EG.alc-code).
                    if extFormF1Obj:NumBundles > 0
                    then do:
                      extFormF1ValueObj = extFormF1Obj:GetExtFormF1Value().
                      if extFormF1ValueObj:INNOrigCli <> ""
                        then next.
                    end.
                    else do:
                      ExtFormF1Obj:CreateExtFormF1(tt-wb-gds-EG.refA, tt-wb-gds-EG.alc-code).
                    end.
                    find first ub.esys-all-attr where ub.esys-all-attr.key2 = 7 and esys-all-attr.key3 = "no" and ub.esys-all-attr.attr-value matches substitute ("*&1*", tt-wb-gds-EG.refA) no-error.
                    if available (ub.esys-all-attr)
                      then next.
                    egaisFormF1 = new FormF1 (ObjType, ObjCode, v-fs-rar, tt-wb-gds-EG.refA).
                    egaisFormF1:DbNum = DbNum.
                    egaisFormF1:User_Id = User_Id.
                    egaisFormF1:SendRequestUTM() .
                    if egaisFormF1:StatusErr then do:
                        put stream str-formF1 unformatted egaisFormF1:Msg chr(10).
                    end.
                    delete object egaisFormF1.
                  end.
                end.
              when urlStr matches ("*opt/out/FORMBREGINFO/*") or urlStr matches ("*opt/out/FORM2REGINFO/*") then
                do:
                  os-delete "FORMBREGINFO.xml".
                  os-delete value (search ("FORMBREGINFO.xml")).
                  assign
                    inFileName = "FORMBREGINFO.xml"
                    .
                  CmdParseXml(urlStr).
                  if StatusErr
                  then do:
                    message "Ошибка приема файла справки Б: " tt-wb-header.wbregid skip urlStr skip Msg skip " Прием документов будет продолжен" view-as alert-box.
                    StatusErr = false.
                    Msg = "".
                    next url_.
                  end.
                  find first tt-wb-header no-error.
                  if not available (tt-wb-header)
                  then do:
                    message "Ошибка приема файла справки Б: " tt-wb-header.wbregid skip urlStr skip Msg skip " Прием документов будет продолжен" view-as alert-box.
                    StatusErr = false.
                    Msg = "".
                    next url_.
                  end.
                  v-clob-db-num = ?.
                  v-int64-id = 0.
                  create tt-analiz.
                  assign
                    tt-analiz.url_ = urlStr
                    tt-analiz.num = tt-wb-header.num
                    tt-analiz.wb-date = tt-wb-header.wb-date
                    tt-analiz.Identity = tt-wb-header.Identity
                    tt-analiz.wbregid = tt-wb-header.wbregid
                    tt-analiz.wb-type = "спр."
                    tt-analiz.uniq-key-rec = tt-wb-header.num + chr(6) + string (tt-wb-header.wb-date) + chr(6) + tt-wb-header.regID-Ship + chr(6) + tt-wb-header.Identity
                    tt-analiz.nnOrder = ii
                    tt-analiz.resource-type = 'egais-ref-b':U
                  .
                  find first buf_tt-analiz where recid (buf_tt-analiz) <> recid (tt-analiz)
                    and buf_tt-analiz.wb-type = tt-analiz.wb-type
                    and buf_tt-analiz.uniq-key-rec = tt-analiz.uniq-key-rec no-error.
                  if available (buf_tt-analiz)
                  then do:
                    buf_tt-analiz.isMany = true.
                    tt-analiz.isMany = true.
                  end.
                  find first ub.clob-bind no-lock where ub.clob-bind.resource-type = 'egais-wb':U and ub.clob-bind.uniq-key-rec = tt-wb-header.uniq-key-rec no-error.
                  if available (ub.clob-bind) and num-entries ( ub.clob-bind.descr, chr(4)) > 4
                  then do:
                    if entry (5, ub.clob-bind.descr, chr(4)) = ? or entry (5, ub.clob-bind.descr, chr(4)) = ""
                    then do:
                      if locked (ub.clob-bind)
                      then do:
                        message "Запись заблокирована - " ub.clob-bind.uniq-key-rec  " Пропускается. В следющий раз будет попытка опять загрузить" view-as alert-box.
                        next url_.
                      end.
                      else do:
                        find current ub.clob-bind exclusive-lock no-error.
                        if available (ub.clob-bind)
                        then do:
                          entry (5, ub.clob-bind.descr, chr(4)) = tt-wb-header.wbregid.
                        end.
                      end.
                      release ub.clob-bind.
                    end.
                    else do:
                      if entry (5, ub.clob-bind.descr, chr(4)) <> tt-wb-header.wbregid and not available (buf_tt-analiz)
                      then do:
                        jj_:
                        do jj = 1 to 100:
                          if not can-find (first buf_clob-bind where ub.clob-bind.uniq-key-rec = tt-wb-header.uniq-key-rec + "#" + string (jj) )
                            then leave jj_.
                        end.
                        if jj = 101 then do:
                          message "Ошибка приема файла справки Б: " tt-wb-header.wbregid skip urlStr skip Msg skip " Прием документов будет продолжен" view-as alert-box.
                          StatusErr = false.
                          Msg = "".
                        end.
                        else do:
                          for each ub.clob-bind exclusive-lock where ub.clob-bind.uniq-key-rec = tt-wb-header.uniq-key-rec:
                            ub.clob-bind.uniq-key-rec = ub.clob-bind.uniq-key-rec + "#" + string (jj).
                          end.
                        end.
                      end.
                    end.
                  end.
                  if can-find (first buf_clob-bind where (buf_clob-bind.uniq-key-rec = tt-wb-header.uniq-key-rec or buf_clob-bind.uniq-key-rec = tt-wb-header.Identity + chr(6) + tt-wb-header.regID-Ship) and buf_clob-bind.resource-type =  'egais-ref-b':U)
                    then next url_.
                  if tt-wb-header.uniq-key-rec = ?
                  then do:
                    message "Ошибка приема файла справки Б: " tt-wb-header.wbregid skip urlStr skip Msg skip " Прием документов будет продолжен" view-as alert-box.
                    StatusErr = false.
                    Msg = "".
                    next url_.
                  end.
                  run gbl/file2clb.p ( input 'ДОБАВЛЕНИЕ':U
                    ,input ",yes"
                    ,input ?
                    ,input tt-wb-header.uniq-key-rec
                    ,input 'egais-ref-b':U
                    ,input ''
                    ,input-output v-part-num
                    ,input 'egais-ref-b':U
                    ,input-output v-clob-db-num
                    ,input-output v-int64-id
                    ,input search (inFileName)
                    ,input ''
                    ) no-error .
                  if error-status:error then
                  do:
                    Msg = error-status:get-message(1) + chr(10) + return-value.
                    StatusErr = false.
                    next url_.
                  end.
                end.
              when urlStr matches ("*opt/out/WayBillAct/*") or urlStr matches ("*opt/out/WayBillAct_v2/*") then
                do:
                  os-delete "WayBillAct.xml".
                  os-delete value (search ("WayBillAct.xml")).
                  assign
                    inFileName = "WayBillAct.xml"
                    .
                  CmdParseXml(urlStr).
                  if StatusErr
                  then do:
                    message "Ошибка приема файла акта " skip urlStr skip Msg skip " Прием документов будет продолжен" view-as alert-box.
                    StatusErr = false.
                    Msg = "".
                    next url_.
                  end.
                  find first tt-wb-act-header.
                  v-clob-db-num = ?.
                  v-int64-id = 0.
                  v-info = tt-wb-act-header.wbregid + chr(4) + string (tt-wb-act-header.act-date) + chr(4) + tt-wb-act-header.num + chr(4) + tt-wb-act-header.status_ + chr(4) + prsXMLDocWB:FromFSRAR.
                  if can-find (first buf_clob-bind where buf_clob-bind.uniq-key-rec = tt-wb-act-header.wbregid and buf_clob-bind.resource-type =  'egais-wb-act':U)
                    then next url_.
                  if tt-wb-act-header.wbregid = ?
                  then do:
                    message "Ошибка приема файла акта " skip urlStr skip Msg skip " Прием документов будет продолжен" view-as alert-box.
                    StatusErr = false.
                    Msg = "".
                    next url_.
                  end.
                  run gbl/file2clb.p ( input 'ДОБАВЛЕНИЕ':U
                    ,input ",yes"
                    ,input ?
                    ,input tt-wb-act-header.wbregid
                    ,input 'egais-wb-act':U
                    ,input v-info
                    ,input-output v-part-num
                    ,input 'egais-wb-act':U
                    ,input-output v-clob-db-num
                    ,input-output v-int64-id
                    ,input search (inFileName)
                    ,input ''
                    ) no-error .
                  if error-status:error then
                  do:
                    Msg = error-status:get-message(1) + chr(10) + return-value.
                    StatusErr = false.
                    next url_.
                  end.
                  find first ub.doc-attr where ub.doc-attr.attr-code = 'negais':U and ub.doc-attr.attr-value = tt-wb-act-header.wbregid no-error.
                  if available (ub.doc-attr)
                  then do:
                    find first buf_doc-attr exclusive-lock where buf_doc-attr.doc-code = ub.doc-attr.doc-code and buf_doc-attr.attr-code = 'egais':U no-error.
                    if not available (buf_doc-attr)
                    then do:
                      create buf_doc-attr.
                      assign
                        buf_doc-attr.doc-code = ub.doc-attr.doc-code
                        buf_doc-attr.attr-code = 'egais':U
                      .
                    end.
                    assign
                      buf_doc-attr.attr-value = tt-wb-act-header.status_.
                    release buf_doc-attr.
                  end.
                end.
              when urlStr matches ("*opt/out/WayBillTicket/*") then
                do:
                  empty temp-table tt-ticket.
                  os-delete "WayBillTicket.xml".
                  os-delete value (search ("WayBillTicket.xml")).
                  assign
                    inFileName = "WayBillTicket.xml"
                    .
                  CmdParseXml(urlStr).
                  if StatusErr
                  then do:
                    message "Ошибка приема файла квитанции накладной" urlStr skip Msg skip " Прием документов будет продолжен" view-as alert-box.
                    StatusErr = false.
                    Msg = "".
                    next url_.
                  end.
                  find first tt-ticket no-error.
                  if not available (tt-ticket)
                  then do:
                    Msg = error-status:get-message(1) + chr(10) + return-value.
                    message "Ошибка приема файла квитанции накладной" urlStr skip Msg skip " Прием документов будет продолжен" view-as alert-box.
                    StatusErr = false.
                    next url_.
                  end.
                  if (tt-ticket.regid = "" or tt-ticket.regid = ?) or tt-ticket.doc <> 'ConfirmTicket' then do:
                    next url_.
                  end.
                  v-clob-db-num = ?.
                  v-int64-id = 0.
                  ticketUKR = tt-ticket.regid + chr(4) + tt-ticket.docId + chr(4) + tt-ticket.Identity +  chr(4) + tt-ticket.ticket-date.
                  if ticketUKR = ? or StatusErr
                  then do:
                    message "Ошибка приема файла квитанции накладной" ticketUKR skip urlStr skip Msg skip " Прием документов будет продолжен" view-as alert-box.
                    StatusErr = false.
                    Msg = "".
                    next url_.
                  end.
                  find first ub.clob-bind where ub.clob-bind.resource-type = 'egais-wb':U and ((tt-ticket.regid <> "" and entry (5, ub.clob-bind.descr, chr(4)) = tt-ticket.regid) or lookup (tt-ticket.TransId, ub.clob-bind.field-name_) > 0) no-error.
                  if available (ub.clob-bind)
                  then do:
                    if num-entries (ub.clob-bind.descr, chr(4)) < 10
                    then do:
                      ub.clob-bind.descr = ub.clob-bind.descr + chr(4).
                    end.
                    if entry (10, ub.clob-bind.descr, chr(4)) <> tt-ticket.status_
                    then do:
                      entry (10, ub.clob-bind.descr, chr(4))  = tt-ticket.status_.
                    end.
                  end.
                  find first ub.doc-attr where ub.doc-attr.attr-code = 'negais':U and ub.doc-attr.attr-value = tt-ticket.regid no-error.
                  if available (ub.doc-attr)
                  then do:
                    find first buf_doc-attr exclusive-lock where buf_doc-attr.doc-code = ub.doc-attr.doc-code and buf_doc-attr.attr-code = 'egais':U no-error.
                    if not available (buf_doc-attr)
                    then do:
                      create buf_doc-attr.
                      assign
                        buf_doc-attr.doc-code = ub.doc-attr.doc-code
                        buf_doc-attr.attr-code = 'egais':U
                      .
                    end.
                    assign
                      buf_doc-attr.attr-value = tt-ticket.status_.
                    release buf_doc-attr.
                  end.
                  if can-find (first buf_clob-bind where
                        (buf_clob-bind.uniq-key-rec = ticketUKR or (buf_clob-bind.uniq-key-rec = tt-ticket.regid + chr(4) + tt-ticket.docId and (tt-ticket.Identity = ? or tt-ticket.Identity = "")))
                    and buf_clob-bind.resource-type =  'egais-wb-ticket':U)
                    then next url_.
                  run gbl/file2clb.p ( input 'ДОБАВЛЕНИЕ':U
                    ,input ",yes"
                    ,input ?
                    ,input ticketUKR
                    ,input 'egais-wb-ticket':U
                    ,input ''
                    ,input-output v-part-num
                    ,input 'egais-wb-ticket':U
                    ,input-output v-clob-db-num
                    ,input-output v-int64-id
                    ,input search (inFileName)
                    ,input ''
                    ) no-error .
                  if error-status:error then
                  do:
                    Msg = error-status:get-message(1) + chr(10) + return-value.
                    StatusErr = false.
                    next url_.
                  end.
                end.
              when urlStr matches ("*opt/out/ConfirmRepealWB/*") then
                do:
                  empty temp-table tt-ticket.
                  os-delete "ConfirmRepealWB.xml".
                  os-delete value (search ("ConfirmRepealWB.xml")).
                  assign
                    inFileName = "ConfirmRepealWB.xml"
                    .
                  CmdParseXml(urlStr).
                  if StatusErr
                  then do:
                    message "Ошибка приема подтверждения распроведение накладной" urlStr skip Msg skip " Прием документов будет продолжен" view-as alert-box.
                    StatusErr = false.
                    Msg = "".
                    next url_.
                  end.
                  find first tt-ticket no-error.
                  if not available (tt-ticket)
                  then do:
                    Msg = error-status:get-message(1) + chr(10) + return-value.
                    message "Ошибка приема подтверждения распроведение накладной" urlStr skip Msg skip " Прием документов будет продолжен" view-as alert-box.
                    StatusErr = false.
                    next url_.
                  end.
                  if (tt-ticket.regid = "" or tt-ticket.regid = ?) or tt-ticket.doc <> 'ConfirmRepealWB' then do:
                    next url_.
                  end.
                  v-clob-db-num = ?.
                  v-int64-id = 0.
                  ticketUKR = tt-ticket.regid + chr(4) + tt-ticket.docId + chr(4) + tt-ticket.Identity +  chr(4) + tt-ticket.ticket-date.
                  if ticketUKR = ? or StatusErr
                  then do:
                    message "Ошибка приема подтверждения распроведение накладной" ticketUKR skip urlStr skip Msg skip " Прием документов будет продолжен" view-as alert-box.
                    StatusErr = false.
                    Msg = "".
                    next url_.
                  end.
                  find first ub.clob-bind where ub.clob-bind.resource-type = 'egais-wb':U and ((tt-ticket.regid <> "" and entry (5, ub.clob-bind.descr, chr(4)) = tt-ticket.regid) or lookup (tt-ticket.TransId, ub.clob-bind.field-name_) > 0) no-error.
                  if available (ub.clob-bind)
                  then do:
                    if num-entries (ub.clob-bind.descr, chr(4)) < 10
                    then do:
                      ub.clob-bind.descr = ub.clob-bind.descr + chr(4).
                    end.
                    if  num-entries (ub.clob-bind.descr, chr(4)) > 9
                    then do:
                      assign
                        entry (10, ub.clob-bind.descr, chr(4))  = "Распроведена" when tt-ticket.status_ = "Accepted"
                      .
                    end.
                  end.
                  find first ub.doc-attr where ub.doc-attr.attr-code = 'negais':U and ub.doc-attr.attr-value = tt-ticket.regid no-error.
                  if available (ub.doc-attr)
                  then do:
                    find first buf_doc-attr exclusive-lock where buf_doc-attr.doc-code = ub.doc-attr.doc-code and buf_doc-attr.attr-code = 'egais':U no-error.
                    if not available (buf_doc-attr)
                    then do:
                      create buf_doc-attr.
                      assign
                        buf_doc-attr.doc-code = ub.doc-attr.doc-code
                        buf_doc-attr.attr-code = 'egais':U
                      .
                    end.
                    assign
                      buf_doc-attr.attr-value = "Распроведена" when tt-ticket.status_ = "Accepted".
                    release buf_doc-attr.
                  end.
                  if can-find (first buf_clob-bind where
                        (buf_clob-bind.uniq-key-rec = ticketUKR or (buf_clob-bind.uniq-key-rec = tt-ticket.regid + chr(4) + tt-ticket.docId and (tt-ticket.Identity = ? or tt-ticket.Identity = "")))
                    and buf_clob-bind.resource-type =  'egais-ticket':U)
                    then next url_.
                  run gbl/file2clb.p ( input 'ДОБАВЛЕНИЕ':U
                    ,input ",yes"
                    ,input ?
                    ,input ticketUKR
                    ,input 'egais-wb-ticket':U
                    ,input ''
                    ,input-output v-part-num
                    ,input 'egais-wb-ticket':U
                    ,input-output v-clob-db-num
                    ,input-output v-int64-id
                    ,input search (inFileName)
                    ,input ''
                    ) no-error .
                  if error-status:error then
                  do:
                    Msg = error-status:get-message(1) + chr(10) + return-value.
                    StatusErr = false.
                    next url_.
                  end.
                end.
              when urlStr matches ("*opt/out/RequestRepealWB/*") then
                do:
                  empty temp-table tt-ticket.
                  os-delete "RequestRepealWB.xml".
                  os-delete value (search ("RequestRepealWB.xml")).
                  assign
                    inFileName = "ConfirmRepealWB.xml"
                    .
                  CmdParseXml(urlStr).
                  if StatusErr
                  then do:
                    message "Ошибка приема файла запроса на распроведение накладной" urlStr skip Msg skip " Прием документов будет продолжен" view-as alert-box.
                    StatusErr = false.
                    Msg = "".
                    next url_.
                  end.
                  find first tt-ticket no-error.
                  if not available (tt-ticket)
                  then do:
                    Msg = error-status:get-message(1) + chr(10) + return-value.
                    message "Ошибка приема файла запроса на распроведение накладной" urlStr skip Msg skip " Прием документов будет продолжен" view-as alert-box.
                    StatusErr = false.
                    next url_.
                  end.
                  if (tt-ticket.regid = "" or tt-ticket.regid = ?) or tt-ticket.doc <> 'RequestRepealWB' then do:
                    next url_.
                  end.
                  v-clob-db-num = ?.
                  v-int64-id = 0.
                  ticketUKR = tt-ticket.regid + chr(4) + tt-ticket.docId + chr(4) + tt-ticket.Identity +  chr(4) + tt-ticket.ticket-date.
                  if ticketUKR = ? or StatusErr
                  then do:
                    message "Ошибка приема файла запроса на распроведение накладной" ticketUKR skip urlStr skip Msg skip " Прием документов будет продолжен" view-as alert-box.
                    StatusErr = false.
                    Msg = "".
                    next url_.
                  end.
                  find first ub.doc-attr where ub.doc-attr.attr-code = 'negais':U and ub.doc-attr.attr-value = tt-ticket.regid no-error.
                  if available (ub.doc-attr)
                  then do:
                    find first buf_doc-attr exclusive-lock where buf_doc-attr.doc-code = ub.doc-attr.doc-code and buf_doc-attr.attr-code = 'egais':U no-error.
                    if not available (buf_doc-attr)
                    then do:
                      create buf_doc-attr.
                      assign
                        buf_doc-attr.doc-code = ub.doc-attr.doc-code
                        buf_doc-attr.attr-code = 'egais':U
                      .
                    end.
                    assign
                      buf_doc-attr.attr-value = "Распроведена" when tt-ticket.status_ = "Accepted".
                    release buf_doc-attr.
                  end.
                  if can-find (first buf_clob-bind where
                        (buf_clob-bind.uniq-key-rec = ticketUKR or (buf_clob-bind.uniq-key-rec = tt-ticket.regid + chr(4) + tt-ticket.docId and (tt-ticket.Identity = ? or tt-ticket.Identity = "")))
                    and buf_clob-bind.resource-type =  'egais-ticket':U)
                    then next url_.
                  run gbl/file2clb.p ( input 'ДОБАВЛЕНИЕ':U
                    ,input ",yes"
                    ,input ?
                    ,input ticketUKR
                    ,input 'egais-wb-ticket':U
                    ,input ''
                    ,input-output v-part-num
                    ,input 'egais-wb-ticket':U
                    ,input-output v-clob-db-num
                    ,input-output v-int64-id
                    ,input search (inFileName)
                    ,input ''
                    ) no-error .
                  if error-status:error then
                  do:
                    Msg = error-status:get-message(1) + chr(10) + return-value.
                    StatusErr = false.
                    next url_.
                  end.
                end.
              when urlStr matches ("*opt/out/Ticket/*") then
                do:
                  empty temp-table tt-ticket.
                  os-delete "Ticket.xml".
                  os-delete value (search ("Ticket.xml")).
                  assign
                    inFileName = "Ticket.xml"
                    .
                  CmdParseXml(urlStr).
                  if StatusErr
                  then do:
                    message "Ошибка приема файла квитанции " urlStr skip Msg skip " Прием документов будет продолжен" view-as alert-box.
                    StatusErr = false.
                    Msg = "".
                    next url_.
                  end.
                  find first tt-ticket no-error.
                  if not available (tt-ticket)
                  then do:
                    Msg = error-status:get-message(1) + chr(10) + return-value.
                    message "Ошибка приема файла квитанции накладной" urlStr skip Msg skip " Прием документов будет продолжен" view-as alert-box.
                    StatusErr = false.
                    next url_.
                  end.
                  v-clob-db-num = ?.
                  v-int64-id = 0.
                  ticketUKR = tt-ticket.regid + chr(4) + tt-ticket.docId + chr(4) + tt-ticket.Identity +  chr(4) + tt-ticket.ticket-date.
                  if ticketUKR = ? or StatusErr
                  then do:
                    message "Ошибка приема файла квитанции " ticketUKR skip urlStr skip Msg skip " Прием документов будет продолжен" view-as alert-box.
                    StatusErr = false.
                    Msg = "".
                    next url_.
                  end.
                  find first ub.clob-bind where
                        ub.clob-bind.resource-type = 'egais-wb':U
                    and ((tt-ticket.regid <> "" and entry (5, ub.clob-bind.descr, chr(4)) = tt-ticket.regid) or lookup (tt-ticket.TransId, ub.clob-bind.field-name_) > 0) no-error.
                  if available (ub.clob-bind)
                  then do:
                    if num-entries (ub.clob-bind.descr, chr(4)) < 10
                    then do:
                      ub.clob-bind.descr = ub.clob-bind.descr + chr(4).
                    end.
                    if entry (10, ub.clob-bind.descr, chr(4)) <> "Accepted"
                    then do:
                      entry (10, ub.clob-bind.descr, chr(4))  = tt-ticket.status_.
                    end.
                  end.
                  if not (can-find (first buf_clob-bind where buf_clob-bind.resource-type = 'egais-wb':U and lookup (tt-ticket.TransId, buf_clob-bind.field-name_) > 0)
                      or can-find (first buf_clob-bind where buf_clob-bind.field-name_ = tt-ticket.TransId)
                      or can-find (first buf_ext-classif where buf_ext-classif.classif-name = 'egais-transId':U
                          and buf_ext-classif.db-num = 0
                          and buf_ext-classif.key#_one = v-ext-sys
                          and buf_ext-classif.CharKey_Two = tt-ticket.TransId))
                  then do:
                    if (tt-ticket.regid = "" or tt-ticket.regid = ?) or (tt-ticket.doc <> 'WayBillAct' and tt-ticket.doc <> 'WAYBILL')  then do:
                      next url_.
                    end.
                  end.
                  if can-find (first buf_clob-bind where
                        ((buf_clob-bind.uniq-key-rec = ticketUKR or (buf_clob-bind.uniq-key-rec = tt-ticket.regid + chr(4) + tt-ticket.docId and (tt-ticket.Identity = ? or tt-ticket.Identity = "")))
                    and buf_clob-bind.resource-type =  'egais-ticket':U))
                    then next url_.
                  run gbl/file2clb.p ( input 'ДОБАВЛЕНИЕ':U
                    ,input ",yes"
                    ,input ?
                    ,input ticketUKR
                    ,input tt-ticket.TransId
                    ,input ''
                    ,input-output v-part-num
                    ,input 'egais-ticket':U
                    ,input-output v-clob-db-num
                    ,input-output v-int64-id
                    ,input search (inFileName)
                    ,input ''
                    ) no-error .
                  if error-status:error then
                  do:
                    Msg = error-status:get-message(1) + chr(10) + return-value.
                    StatusErr = false.
                    next url_.
                  end.
                  if tt-ticket.regid <> ""
                  then do:
                    find first buf_ext-classif where buf_ext-classif.classif-name = 'egais-transId':U
                            and buf_ext-classif.db-num = 0
                            and buf_ext-classif.key#_one = v-ext-sys
                            and buf_ext-classif.CharKey_Two = tt-ticket.TransId no-error.
                    if available (buf_ext-classif) then do:
                    find first buf_doc-attr no-lock where buf_doc-attr.attr-code = 'negais':U and buf_doc-attr.doc-code = buf_ext-classif.CharKey_One no-error.
                      if not available (buf_doc-attr)
                      then do:
                        create buf_doc-attr.
                        assign
                          buf_doc-attr.doc-code = buf_ext-classif.CharKey_One
                          buf_doc-attr.attr-value = tt-ticket.regid
                          buf_doc-attr.attr-code = 'negais':U
                        .
                      end.
                    end.
                  end.
                end.
            end case.
          end.
      end case.
    end.
    os-copy value (search ('ReceiptListOfQuery.xml')) value (v-FS-RAR + '_ReceiptListOfQuery.xml').
    HndlAnaliz = buffer tt-analiz:handle.
    empty temp-table tt-wb-info-client.
    empty temp-table tt-wb-hndls.
    empty temp-table tt-wb-act-hndls.
    empty temp-table tt-wb-header.
    empty temp-table tt-wb-gds-EG.
    empty temp-table tt-wb-act-header.
    empty temp-table tt-wb-act-gds-EG.
  end.
  method private void createhDoc (inRecCD as recid, inFileName as char, output outhDoc as handle ):
    define buffer buf_cd for ub.clob-data.
    find first buf_cd where recid (buf_cd) = inRecCD no-lock.
    copy-lob
      from  object buf_cd.cdata
      to  file inFileName
      no-convert
      no-error .
    create x-document outhDoc.
    outhDoc:encoding = 'utf-8'.
    outhDoc:load("file", search (inFileName), false).
    release buf_cd.
  end.
  method private void createhDoc (inFileName as char, output outhDoc as handle ):
    create x-document outhDoc.
    outhDoc:encoding = 'utf-8'.
    outhDoc:load("file", search (inFileName), false).
  end.
  method override public void SaveWB (inWbIdentity as char):
    def var trn-doc-code as char no-undo.
    find first buf_clob-bind no-lock where buf_clob-bind.uniq-key-rec = inWbIdentity and buf_clob-bind.resource-type = 'egais-wb':U no-error.
    if not available (buf_clob-bind) then
    do:
      Msg = "Не найдена накладная с идентификатором " + inWbIdentity.
      StatusErr = true.
      return.
    end.
    if can-find (first tt-wb-gds-EG where tt-wb-gds-EG.RefA = "" or tt-wb-gds-EG.RefB = "")
      then
    do:
      Msg = "Не для всех товаров есть сравка A или B ".
      StatusErr = true.
      return.
    end.
    do trans:
      run ibs/th/bge/egais/AdapteeEGAISProcOra-i516.p
        (
        input table tt-wb-header,
        input table tt-wb-gds-EG,
        input User_Id,
        input "",
        input-output trn-doc-code
        ) no-error.
      if error-status:error then
      do:
        Msg = return-value.
        StatusErr = true.
        return.
      end.
      Msg = return-value.
      if Msg <> ""
      then do:
        message Msg chr(10) "Сохранить?" view-as alert-box
          question buttons yes-no
          title "" update v-choise as logical.
        if not v-choise then do:
          Msg = "Отменено пользователем".
          StatusErr = true.
          return.
        end.
      end.
      find current buf_clob-bind exclusive-lock.
      entry (6, buf_clob-bind.descr, chr(4)) = trn-doc-code.
      find current buf_clob-bind no-lock.
    end.
    find first tt-wb-hndls where tt-wb-hndls.uniq-key-rec = buf_clob-bind.uniq-key-rec no-error.
    if not available (tt-wb-hndls)
    then do:
      Msg = "Непредвиденная ошибка." + buf_clob-bind.descr.
      StatusErr = true.
      return.
    end.
    release buf_clob-bind.
    find first buf_trn-doc where buf_trn-doc.doc-code = trn-doc-code no-error.
    tt-wb-hndls.trn-doc-code = trn-doc-code.
    if available (buf_trn-doc)
    then do:
      tt-wb-hndls.status_ = buf_trn-doc.status_ + if buf_trn-doc.flag_ then "+" else "-".
      tt-wb-hndls.isWB = true.
    end.
    release buf_trn-doc.
  end.
  method override public void RejectWB (inWbIdentity as char):
    do trans:
      find first buf_clob-bind exclusive-lock where buf_clob-bind.uniq-key-rec = inWbIdentity and buf_clob-bind.resource-type = 'egais-wb':U no-error.
      find current buf_clob-bind exclusive-lock.
      entry (6, buf_clob-bind.descr, chr(4)) = 'отказ'.
      find current buf_clob-bind no-lock.
      find first tt-wb-hndls where tt-wb-hndls.uniq-key-rec = buf_clob-bind.uniq-key-rec no-error.
      if not available (tt-wb-hndls)
      then do:
        Msg = "Непредвиденная ошибка. " + chr(10) + buf_clob-bind.descr.
        StatusErr = true.
        undo, return.
      end.
      if not available (buf_clob-bind) then
      do:
        Msg = "Не найдена накладная с идентификатором " + inWbIdentity.
        StatusErr = true.
        undo, return.
      end.
      if not SendRequestUTM()
      then do:
        Msg = "Не удалось отправить отказ - " + inWbIdentity + chr(10) + Msg.
        StatusErr = true.
        undo, return.
      end.
    end.
    tt-wb-hndls.trn-doc-code = 'отказ'.
  end.
  method override public void ConnWB (inWbIdentity as char, inTrnDoc as char):
    def buffer buf_tt-wb-gds-EG for tt-wb-gds-EG.
    def var isErr     as logical no-undo.
    def var isWarning as logical no-undo.
    def var ischoise  as logical no-undo.
    def var jj        as int     no-undo.
    def var ii        as int     no-undo.
    def var THSumm    as decimal no-undo.
    def var EGAISSumm as decimal no-undo.
    find first buf_clob-bind exclusive-lock where buf_clob-bind.uniq-key-rec = inWbIdentity and buf_clob-bind.resource-type = 'egais-wb':U no-error.
    if not available (buf_clob-bind) then
    do:
      Msg = "Не найдена накладная с идентификатором " + inWbIdentity.
      StatusErr = true.
      return.
    end.
    find first buf_trn-doc where buf_trn-doc.doc-code = entry (6, buf_clob-bind.descr, chr(4)) no-error.
    if entry (6, buf_clob-bind.descr, chr(4)) = 'отказ' or available (buf_trn-doc)
    then do:
      Msg = "Накладная уже связана или по ней был отказ.".
      message  Msg + " Вы уверены, что хотите связать накладную?" view-as alert-box question buttons yes-no
        title "" update isChoise.
      if not isChoise then do:
        StatusErr = true.
        return.
      end.
      if not ActnEGAISAdm
      then do:
        Msg = 'Для связывания нужно право "Администрирование запросов в ЕГАИС"'.
        StatusErr = true.
        return.
      end.
    end.
    find first buf_trn-doc no-lock where buf_trn-doc.doc-code = inTrnDoc no-error.
    if not available (buf_trn-doc)
    then do:
      Msg = "Не найдена накладная" + inTrnDoc.
      StatusErr = true.
      return.
    end.
    foreach1_:
    for each tt-wb-gds-EG break by gds-code:
      THSumm = 0.
      EGAISSumm = 0.
      ii = 0.
      jj = 0.
      if not first-of (gds-code) and last-of (gds-code)
        then next foreach1_.
      find first buf_gds no-lock where buf_gds.gds-code = tt-wb-gds-EG.gds-code no-error.
      if not available (buf_gds)
      then do:
        Msg = Msg + (if Msg <> "" then chr(10) else '') + substitute ("Товар &1 &2 не имеет связки.", tt-wb-gds-EG.alc-code, tt-wb-gds-EG.gds-name).
        isErr = true.
      end.
      else do:
        for each ub.parts no-lock
          where
                ub.parts.obj-code  = buf_trn-doc.obj-code
            and ub.parts.obj-type  = buf_trn-doc.obj-type
            and ub.parts.artic     = buf_gds.artic
            and ub.parts.prod-type = buf_gds.prod-type
            and ub.parts.prod-code = buf_gds.prod-code
            and ub.parts.out-code  = inTrnDoc:
          jj = jj + 1.
          THSumm = THSumm + ub.parts.fact-qnty / ub.parts.cli-base-rate.
          alcTypeAttrObj:GetAlcTypeAttr ( input tt-wb-gds-EG.alc-type-code,
                                   input   "alc-min-price",
                                   output  minPrice
                                ).
          if ub.parts.price-rubl < minPrice or tt-wb-gds-EG.price < minPrice * ub.parts.cli-base-rate
          then do:
          Msg = Msg + (if Msg <> "" then chr(10) else '')
            + substitute ("Для товара &5/&1 &2 цена в накладной ЕГАИС или TH меньше допустимой &6 (мин. доп. в ед. поставщика &8) по группе &7. В накладной ЕГАИС цена - &3 в накладной TH цена - &4.", tt-wb-gds-EG.alc-code, tt-wb-gds-EG.gds-name, tt-wb-gds-EG.price, ub.parts.price-rubl, buf_gds.gds-code, minPrice, tt-wb-gds-EG.alc-type-code, minPrice * ub.parts.cli-base-rate).
          end.
        end.
        for each buf_tt-wb-gds-EG where buf_tt-wb-gds-EG.gds-code = buf_gds.gds-code:
          ii = ii + 1.
          EGAISSumm = EGAISSumm + buf_tt-wb-gds-EG.qnty.
        end.
        if EGAISSumm <> THSumm
        then do:
          isWarning = true.
          Msg = Msg + (if Msg <> "" then chr(10) else '')
            + substitute ("Не совпадает документарное кол-во. Для товара &5/&1 &2 в накладной ЕГАИС кол-во по партиям - &3 в накладной TH кол-во по партиям - &4.", tt-wb-gds-EG.alc-code, tt-wb-gds-EG.gds-name, EGAISSumm, THSumm, buf_gds.gds-code).
        end.
        if ii <> jj
        then do:
          isWarning = true.
          Msg = Msg + (if Msg <> "" then chr(10) else '')
            + substitute ("Для товара &5/&1 &2 в накладной ЕГАИС партий - &3 в накладной TH партий - &4.", tt-wb-gds-EG.alc-code, tt-wb-gds-EG.gds-name, ii, jj, buf_gds.gds-code).
          if jj = 0
            then Msg = Msg + chr(10)
              + substitute ("Для товара &1/&2 &3 при отправке накладной в ЕГАИС акт будет с расхождение и кол-во 0.", buf_gds.gds-code, tt-wb-gds-EG.alc-code, tt-wb-gds-EG.gds-name).
        end.
      end.
    end.
    for each ub.parts no-lock
      where
            ub.parts.out-code = inTrnDoc
        and ub.parts.obj-code = buf_trn-doc.obj-code
        and ub.parts.obj-type = buf_trn-doc.obj-type
        :
      find first buf_gds no-lock where
                ub.parts.artic     = buf_gds.artic
            and ub.parts.prod-type = buf_gds.prod-type
            and ub.parts.prod-code = buf_gds.prod-code.
      find first tt-wb-gds-EG no-lock where tt-wb-gds-EG.gds-code = buf_gds.gds-code no-error.
      if not available ( tt-wb-gds-EG )
      then do:
        isWarning = true.
        Msg = Msg + (if Msg <> "" then chr(10) else '')
          + substitute ("Товара &1 &2 в накладной TH отсутствует в накладной ЕГАИС.", buf_gds.gds-code, buf_gds.gds-name).
      end.
    end.
    if isErr
    then do:
      StatusErr = true.
      return.
    end.
    output stream outstr close.
    output stream outstr to value ("warWBLog.txt").
    put stream outstr unformatted Msg.
    output stream outstr close.
    if isWarning
    then do:
      message  Msg + chr(10) + " Вы уверены, что хотите связать накладную?" view-as alert-box question buttons yes-no
        title "" update isChoise.
      if not isChoise then do:
        StatusErr = true.
        return.
      end.
      if not ActnEGAISAdm
      then do:
        Msg = 'Для связывания нужно право "Администрирование запросов в ЕГАИС"'.
        StatusErr = true.
        return.
      end.
    end.
    run ibs/th/bge/egais/AdapteeEGAISProcOra-i516.p
      (
      input table tt-wb-header,
      input table tt-wb-gds-EG,
      input User_Id,
      input "conn",
      input-output inTrnDoc
      ) no-error.
    if error-status:error then
    do:
      Msg = return-value.
      StatusErr = true.
      return.
    end.
    find current buf_clob-bind exclusive-lock.
    entry (6, buf_clob-bind.descr, chr(4)) = inTrnDoc.
    find current buf_clob-bind no-lock.
    find first tt-wb-hndls where tt-wb-hndls.uniq-key-rec = buf_clob-bind.uniq-key-rec no-error.
    if not available (tt-wb-hndls)
    then do:
      Msg = "Непредвиденная ошибка." + buf_clob-bind.descr.
      StatusErr = true.
      return.
    end.
    tt-wb-hndls.trn-doc-code = inTrnDoc.
  end.
  method public logical SendForceAccept ():
    isForceAccept = true.
    if not SendRequestUTM()
    then do:
      StatusErr = true.
      return false.
    end.
    isForceAccept = false.
    return true.
  end.
  method public logical ReleaseTable_ ():
    release buf_clob-bind.
    release buf_clob-bind-temp.
    release buf_clob-bind-wb-hndls.
    release buf_clob-data.
  end.
  method private longchar GetXMLAct ():
    def var ii           as integer   no-undo.
    def var xml-cont     as longchar  no-undo.
    def var is-diff      as logical   no-undo.
    def var docCodeList  as character no-undo.
    def var VerXSDShip   as character no-undo.
    find first tt-wb-header.
    find first buf_ext-classif-attr no-lock where buf_ext-classif-attr.classif-subject = 'clients':U
      and buf_ext-classif-attr.classif-name = 'clients-esys':U
      and buf_ext-classif-attr.db-num = 0
      and buf_ext-classif-attr.key#_one = v-ext-sys
      and buf_ext-classif-attr.CharKey_Three = tt-wb-header.regID-Ship
      and buf_ext-classif-attr.attr-code = "egais-cli-info" no-error.
    if available (buf_ext-classif-attr)
    then
      assign
        VerXSDShip = entry (1, buf_ext-classif-attr.attr-value, chr(4))
      no-error.
    else VerXSDShip = 'WayBill'.
    if not (available (buf_clob-bind) and entry (6, buf_clob-bind.descr, chr(4)) = 'отказ') and not isForceAccept then do:
      docCodeList = "".
      for each buf_doc-attr no-lock where buf_doc-attr.attr-code = 'negais':U and buf_doc-attr.attr-value begins (tt-wb-header.wbregid) :
        if can-find (first buf_trn-doc where buf_trn-doc.doc-code = buf_doc-attr.doc-code and
              not (buf_trn-doc.status_ = 'факт':U))
          then next.
        docCodeList = docCodeList + "," + buf_doc-attr.doc-code.
      end.
      docCodeList = left-trim (docCodeList, ',').
      if num-entries (docCodeList) > 1
      then do:
        Msg = substitute ("Несколько связанных накладных c одной накладной ЕГАИС wbregid - &1/&2. Для исправления пересвяжите накладную", tt-wb-header.wbregid, docCodeList) + chr(10).
        for each buf_doc-attr no-lock where buf_doc-attr.attr-code = 'negais':U and buf_doc-attr.attr-value begins (tt-wb-header.wbregid):
          Msg = Msg + "Накладаная - " + buf_doc-attr.doc-code + chr(10).
        end.
        StatusErr = true.
        return ?.
      end.
      if docCodeList <> ""
      then do:
        find first buf_doc-attr no-lock where buf_doc-attr.attr-code = 'negais':U and buf_doc-attr.doc-code = docCodeList no-error.
      end.
      if not available (buf_doc-attr)
      then do:
        Msg = substitute ("Не найден атрибут документа с номером ЕГАИС WBRegID - &1, пересвяжите накладную", tt-wb-header.wbregid).
        StatusErr = true.
        return ?.
      end.
      foreach_:
      for each tt-wb-gds-EG :
        release buf_parts.
        release buf_gds.
        release buf_doc-line.
        find first buf_gds no-lock where buf_gds.gds-code = tt-wb-gds-EG.gds-code no-error.
        if available (buf_gds) then do:
          find first buf_parts where
            buf_parts.obj-type = tt-wb-header.obj-type and
            buf_parts.obj-code = tt-wb-header.obj-code and
            buf_parts.artic = buf_gds.artic and
            buf_parts.prod-type = buf_gds.prod-type and
            buf_parts.prod-code = buf_gds.prod-code and
            buf_parts.out-code = buf_doc-attr.doc-code and
            buf_parts.alc-ref-ab-path = tt-wb-gds-EG.refA + "," + tt-wb-gds-EG.refB + "," + tt-wb-gds-EG.alc-code + "," + tt-wb-gds-EG.alc-type-code no-lock no-error.
        end.
        if not available (buf_parts) then do:
        find first buf_parts where
            buf_parts.out-code = buf_doc-attr.doc-code and
            buf_parts.obj-type = tt-wb-header.obj-type and
            buf_parts.obj-code = tt-wb-header.obj-code and
            buf_parts.alc-ref-ab-path = tt-wb-gds-EG.refA + "," + tt-wb-gds-EG.refB + "," + tt-wb-gds-EG.alc-code + "," + tt-wb-gds-EG.alc-type-code no-lock no-error.
        end.
        if not available (buf_parts) then do:
          find first buf_doc-line no-lock where available (buf_gds) and buf_doc-line.doc-code = buf_doc-attr.doc-code and
             buf_gds.artic = buf_doc-line.artic and buf_gds.prod-code = buf_doc-line.prod-code and buf_gds.prod-type = buf_doc-line.prod-type no-error.
          if not available (buf_doc-line) then do:
              message "Не найден товар в накладной, который есть в ЕГАИС - " + buf_doc-attr.doc-code + " товар - " + string (tt-wb-gds-EG.gds-code) + " Продолжить с отправкой для данного товара в акте кол-ва 0?" view-as alert-box
                question buttons yes-no
                title "" update v-choise as logical.
              if not v-choise then do:
                Msg = "Отменено пользователем".
                StatusErr = true.
                return ?.
              end.
              is-diff = true.
              xml-cont = xml-cont + substitute ('<wa:Position><wa:Identity>&1</wa:Identity><wa:InformBRegId>&2</wa:InformBRegId><wa:RealQuantity>&3</wa:RealQuantity></wa:Position>', string (tt-wb-gds-EG.Identity), tt-wb-gds-EG.refB, 0.0).
              next foreach_.
          end.
          else do:
              Msg = "Не найдена партия для товара " + string (tt-wb-gds-EG.gds-code) + "/" + tt-wb-gds-EG.alc-code + " справка А " + tt-wb-gds-EG.refA + " справка Б " + tt-wb-gds-EG.refB + ". Документ - " + buf_doc-attr.doc-code +  "/" + buf_doc-attr.attr-value.
              StatusErr = true.
              return ?.
          end.
        end.
        if tt-wb-gds-EG.qnty <> buf_parts.fact-qnty / buf_parts.cli-base-rate then
        do:
          is-diff = true.
        end.
        case tt-wb-header.verXSD:
        when "WayBill_v2"
        then
          xml-cont = xml-cont + substitute ('<wa:Position><wa:Identity>&1</wa:Identity><wa:InformF2RegId>&2</wa:InformF2RegId><wa:RealQuantity>&3</wa:RealQuantity></wa:Position>', string (tt-wb-gds-EG.Identity), tt-wb-gds-EG.refB, string ( buf_parts.fact-qnty / buf_parts.cli-base-rate)).
        when "WayBill"
        then
          xml-cont = xml-cont + substitute ('<wa:Position><wa:Identity>&1</wa:Identity><wa:InformBRegId>&2</wa:InformBRegId><wa:RealQuantity>&3</wa:RealQuantity></wa:Position>', string (tt-wb-gds-EG.Identity), tt-wb-gds-EG.refB, string ( buf_parts.fact-qnty / buf_parts.cli-base-rate)).
        end case.
      end .
      case tt-wb-header.verXSD:
      when "WayBill_v2"
      then
        return substitute ('<?xml version="1.0" encoding="UTF-8"?><ns:Documents Version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01" xmlns:oref="http://fsrar.ru/WEGAIS/ClientRef" xmlns:pref="http://fsrar.ru/WEGAIS/ProductRef" xmlns:wa="http://fsrar.ru/WEGAIS/ActTTNSingle_v2"><ns:Owner><ns:FSRAR_ID>&1</ns:FSRAR_ID></ns:Owner><ns:Document><ns:WayBillAct_v2><wa:Header><wa:IsAccept>&2</wa:IsAccept><wa:ACTNUMBER>&3</wa:ACTNUMBER><wa:ActDate>&4</wa:ActDate><wa:WBRegId>&5</wa:WBRegId><wa:Note>&6</wa:Note></wa:Header><wa:Content>', v-FS-RAR, (if is-diff then 'Differences' else 'Accepted'), buf_doc-attr.doc-code, iso-date (date (now)), tt-wb-header.wbregid, "Принимаем продукцию. " + (if is-diff then "Имеются расхождения." else "")) + (if is-diff then xml-cont else "") + '</wa:Content></ns:WayBillAct_v2></ns:Document></ns:Documents>'.
      when "WayBill"
      then
        return substitute ('<?xml version="1.0" encoding="UTF-8"?><ns:Documents Version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01" xmlns:oref="http://fsrar.ru/WEGAIS/ClientRef" xmlns:pref="http://fsrar.ru/WEGAIS/ProductRef" xmlns:wa="http://fsrar.ru/WEGAIS/ActTTNSingle"><ns:Owner><ns:FSRAR_ID>&1</ns:FSRAR_ID></ns:Owner><ns:Document><ns:WayBillAct><wa:Header><wa:IsAccept>&2</wa:IsAccept><wa:ACTNUMBER>&3</wa:ACTNUMBER><wa:ActDate>&4</wa:ActDate><wa:WBRegId>&5</wa:WBRegId><wa:Note>&6</wa:Note></wa:Header><wa:Content>', v-FS-RAR, 'Accepted', buf_doc-attr.doc-code, iso-date (date (now)), tt-wb-header.wbregid, "Принимаем продукцию. " + (if is-diff then "Имеются расхождения." else "")) + (if is-diff then xml-cont else "") + '</wa:Content></ns:WayBillAct></ns:Document></ns:Documents>'.
      end case.
    end.
    else do:
      if isForceAccept
      then do:
        find first buf_doc-attr no-lock where buf_doc-attr.attr-code = 'negais':U and buf_doc-attr.attr-value begins (tt-wb-header.wbregid) no-error.
        case tt-wb-header.verXSD:
        when "WayBill_v2"
        then
          xml-cont = substitute ('<?xml version="1.0" encoding="UTF-8"?><ns:Documents Version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01" xmlns:oref="http://fsrar.ru/WEGAIS/ClientRef" xmlns:pref="http://fsrar.ru/WEGAIS/ProductRef" xmlns:wa="http://fsrar.ru/WEGAIS/ActTTNSingle_v2"><ns:Owner><ns:FSRAR_ID>&1</ns:FSRAR_ID></ns:Owner><ns:Document><ns:WayBillAct_v2><wa:Header><wa:IsAccept>&2</wa:IsAccept><wa:ACTNUMBER>&3</wa:ACTNUMBER><wa:ActDate>&4</wa:ActDate><wa:WBRegId>&5</wa:WBRegId><wa:Note>&6</wa:Note></wa:Header><wa:Content>', v-FS-RAR, 'Accepted', (if available (buf_doc-attr) then buf_doc-attr.doc-code else string (time)), iso-date (date (now)), tt-wb-header.wbregid, "Принимаем продукцию") + '</wa:Content></ns:WayBillAct_v2></ns:Document></ns:Documents>'.
        when "WayBill"
        then
          xml-cont = substitute ('<?xml version="1.0" encoding="UTF-8"?><ns:Documents Version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01" xmlns:oref="http://fsrar.ru/WEGAIS/ClientRef" xmlns:pref="http://fsrar.ru/WEGAIS/ProductRef" xmlns:wa="http://fsrar.ru/WEGAIS/ActTTNSingle"><ns:Owner><ns:FSRAR_ID>&1</ns:FSRAR_ID></ns:Owner><ns:Document><ns:WayBillAct><wa:Header><wa:IsAccept>&2</wa:IsAccept><wa:ACTNUMBER>&3</wa:ACTNUMBER><wa:ActDate>&4</wa:ActDate><wa:WBRegId>&5</wa:WBRegId><wa:Note>&6</wa:Note></wa:Header><wa:Content>', v-FS-RAR, 'Accepted', (if available (buf_doc-attr) then buf_doc-attr.doc-code else string (time)), iso-date (date (now)), tt-wb-header.wbregid, "Принимаем продукцию") + '</wa:Content></ns:WayBillAct></ns:Document></ns:Documents>'.
        end case.
      end.
      else do:
        if tt-wb-header.verXSD = 'WayBill_v2'
        then
          xml-cont = substitute ('<?xml version="1.0" encoding="UTF-8"?><ns:Documents Version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01" xmlns:oref="http://fsrar.ru/WEGAIS/ClientRef" xmlns:pref="http://fsrar.ru/WEGAIS/ProductRef" xmlns:wa="http://fsrar.ru/WEGAIS/ActTTNSingle_v2"><ns:Owner><ns:FSRAR_ID>&1</ns:FSRAR_ID></ns:Owner><ns:Document><ns:WayBillAct_v2><wa:Header><wa:IsAccept>&2</wa:IsAccept><wa:ACTNUMBER>&3</wa:ACTNUMBER><wa:ActDate>&4</wa:ActDate><wa:WBRegId>&5</wa:WBRegId><wa:Note>&6</wa:Note></wa:Header><wa:Content>', v-FS-RAR, 'Rejected', time, iso-date (date (now)), tt-wb-header.wbregid, "Отказ") + '</wa:Content></ns:WayBillAct_v2></ns:Document></ns:Documents>'.
        else
          xml-cont = substitute ('<?xml version="1.0" encoding="UTF-8"?><ns:Documents Version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01" xmlns:oref="http://fsrar.ru/WEGAIS/ClientRef" xmlns:pref="http://fsrar.ru/WEGAIS/ProductRef" xmlns:wa="http://fsrar.ru/WEGAIS/ActTTNSingle"><ns:Owner><ns:FSRAR_ID>&1</ns:FSRAR_ID></ns:Owner><ns:Document><ns:WayBillAct><wa:Header><wa:IsAccept>&2</wa:IsAccept><wa:ACTNUMBER>&3</wa:ACTNUMBER><wa:ActDate>&4</wa:ActDate><wa:WBRegId>&5</wa:WBRegId><wa:Note>&6</wa:Note></wa:Header><wa:Content>', v-FS-RAR, 'Rejected', time, iso-date (date (now)), tt-wb-header.wbregid, "Отказ") + '</wa:Content></ns:WayBillAct></ns:Document></ns:Documents>'.
      end.
      return xml-cont.
    end.
  end.
  method private void CmdParseXml (inType as char):
    define variable hDoc as handle no-undo.
    cmd = substitute ("&1 --connect-timeout &2 -X GET &3 >&4", search ("exe/curl.exe"), TimeOut, inType, inFileName).
    os-command silent value (cmd).
    file-info:file-name = search (inFileName).
    if file-info:file-size = 0
    then do:
      Msg = substitute ('По адресу &1 получен пустой файл. Возможно нужно увеличить timeout в настройках INI файда секция EGAIS', inType).
      StatusErr = true.
      return.
    end.
    createhDoc(inFileName, output hDoc).
    prsXMLDocWB:ParseRec (hDoc, input-output table tt-wb-header, input-output table tt-wb-act-header, input-output table tt-ticket, input-output table tt-wb-info-client, input-output table tt-wb-gds-EG).
    find first tt-wb-header no-error.
    find first tt-wb-act-header no-error.
    find first tt-ticket no-error.
    if not prsXMLDocWB:glog then
    do:
      Msg = 'Ошибка обработки xml'.
      StatusErr = true.
      return.
    end.
  end.
  method private void WriteXMLWB (inFileName as char):
    def var sw               as handle    no-undo.
    def var VerXSDShip       as character no-undo.
    def var VerXSDCons       as character no-undo.
    def var CliEgaisTypeShip as character no-undo.
    def var CliEgaisTypeCons as character no-undo.
    def var ii               as integer   no-undo.
    find first buf_ext-classif-attr no-lock where buf_ext-classif-attr.classif-subject = 'clients':U
      and buf_ext-classif-attr.classif-name = 'clients-esys':U
      and buf_ext-classif-attr.db-num = 0
      and buf_ext-classif-attr.key#_one = v-ext-sys
      and buf_ext-classif-attr.CharKey_two = (tt-wb-header.obj-type + string(tt-wb-header.obj-code))
      and buf_ext-classif-attr.CharKey_Three = tt-wb-header.regID-Ship
      and buf_ext-classif-attr.attr-code = "egais-cli-info" no-error.
    if available (buf_ext-classif-attr)
    then
      assign
        VerXSDShip = entry (1, buf_ext-classif-attr.attr-value, chr(4))
        CliEgaisTypeShip = entry (2, buf_ext-classif-attr.attr-value, chr(4))
      no-error.
    else VerXSDShip = 'WayBill'.
    if VerXSDShip = ? or VerXSDShip = "" or VerXSDShip = "WayBill" or VerXSD = "1"
    then do:
      VerWBXsd = "WayBill".
      verPrefXMLNS = "".
    end.
    else do:
      VerWBXsd = "WayBill_v2".
      verPrefXMLNS = "2".
    end.
    if VerWBXsd = "WayBill_v2"
    then do:
      find first buf_ext-classif-attr no-lock where buf_ext-classif-attr.classif-subject = 'clients':U
        and buf_ext-classif-attr.classif-name = 'clients-esys':U
        and buf_ext-classif-attr.db-num = 0
        and buf_ext-classif-attr.key#_one = v-ext-sys
        and buf_ext-classif-attr.CharKey_two = (tt-wb-header.cli-type + string(tt-wb-header.cli-code))
        and buf_ext-classif-attr.CharKey_Three = tt-wb-header.regID-Cons
        and buf_ext-classif-attr.attr-code = "egais-cli-info" no-error.
      if available (buf_ext-classif-attr)
      then do:
        assign
          VerXSDCons = entry (1, buf_ext-classif-attr.attr-value, chr(4))
          CliEgaisTypeCons = entry (2, buf_ext-classif-attr.attr-value, chr(4))
        no-error.
        if VerXSDCons = ? or VerXSDCons = ""
        then do:
          VerWBXsd = "WayBill".
          verPrefXMLNS = "".
        end.
      end.
      else do:
        VerWBXsd = "WayBill".
        verPrefXMLNS = "".
      end.
    end.
    tt-wb-header.verXSD = VerWBXsd.
    create sax-writer sw .
    sw:formatted = true.
    sw:set-output-destination ("file", inFileName).
    sw:encoding = "UTF-8".
    sw:start-document () .
    sw:start-element ("ns:Documents") .
    sw:insert-attribute ("Version", "1.0") .
    case VerWBXsd:
      when "WayBill" then do:
        sw:insert-attribute ("xmlns:wb", "http://fsrar.ru/WEGAIS/TTNSingle").
        sw:insert-attribute ("xmlns:ns", "http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01").
        sw:insert-attribute ("xmlns:oref", "http://fsrar.ru/WEGAIS/ClientRef").
        sw:insert-attribute ("xmlns:pref", "http://fsrar.ru/WEGAIS/ProductRef").
      end.
      when "WayBill_v2" then do:
        sw:insert-attribute ("xmlns:wb2", "http://fsrar.ru/WEGAIS/TTNSingle_v2").
        sw:insert-attribute ("xmlns:ns", "http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01").
        sw:insert-attribute ("xmlns:oref2", "http://fsrar.ru/WEGAIS/ClientRef_v2").
        sw:insert-attribute ("xmlns:pref2", "http://fsrar.ru/WEGAIS/ProductRef_v2").
      end.
    end case.
    sw:start-element ("ns:Owner") .
        sw:write-data-element ("ns:FSRAR_ID", v-fs-rar) .
    sw:end-element ("ns:Owner") .
    sw:start-element ("ns:Document") .
      sw:start-element ("ns:" + VerWBXsd) .
        sw:write-data-element ("wb" + verPrefXMLNS + ":Identity", tt-wb-header.Identity) .
        sw:start-element ("wb" + verPrefXMLNS + ":Header") .
          sw:write-data-element ("wb" + verPrefXMLNS + ":NUMBER", tt-wb-header.Identity).
          sw:write-data-element ("wb" + verPrefXMLNS + ":Date", iso-date (tt-wb-header.wb-date)).
          sw:write-data-element ("wb" + verPrefXMLNS + ":Type", tt-wb-header.wb-type).
          if VerWBXsd = 'WayBill'
            then sw:write-data-element ("wb" + verPrefXMLNS + ":UnitType", tt-wb-header.UnitType).
          sw:write-data-element ("wb" + verPrefXMLNS + ":ShippingDate", iso-date (tt-wb-header.wb-date)).
          sw:start-element ("wb" + verPrefXMLNS + ":Shipper") .
            if VerWBXsd = 'WayBill_v2'
              then sw:start-element ("oref" + verPrefXMLNS + ":" + CliEgaisTypeShip) .
            AddClientXML(sw, tt-wb-header.obj-type, tt-wb-header.obj-code, tt-wb-header.regID-Ship, yes).
            if StatusErr
              then return.
            if VerWBXsd = 'WayBill_v2'
              then sw:end-element ("oref" + verPrefXMLNS + ":" + CliEgaisTypeShip) .
          sw:end-element ("wb" + verPrefXMLNS + ":Shipper") .
          sw:start-element ("wb" + verPrefXMLNS + ":Consignee") .
            if VerWBXsd = 'WayBill_v2'
              then sw:start-element ("oref" + verPrefXMLNS + ":" + CliEgaisTypeCons) .
            AddClientXML(sw, tt-wb-header.cli-type, tt-wb-header.cli-code, tt-wb-header.regID-Cons, no).
            if StatusErr
              then return.
            if VerWBXsd = 'WayBill_v2'
              then sw:end-element ("oref" + verPrefXMLNS + ":" + CliEgaisTypeCons) .
          sw:end-element ("wb" + verPrefXMLNS + ":Consignee") .
          sw:start-element ("wb" + verPrefXMLNS + ":Transport") .
          sw:end-element ("wb" + verPrefXMLNS + ":Transport") .
        sw:end-element ("wb" + verPrefXMLNS + ":Header") .
        sw:start-element ("wb" + verPrefXMLNS + ":Content") .
        ii = 0.
        for each tt-wb-gds-EG no-lock:
          ii = ii + 1.
          extGdsObj:OpenQueryExtGds (tt-wb-gds-EG.gds-code, tt-wb-gds-EG.alc-code).
          if extGdsObj:NumBundles = 0
          then do:
            Msg = substitute ("Не найдена связка &1/&2. &3",tt-wb-gds-EG.gds-code, tt-wb-gds-EG.alc-code, extGdsObj:ReturnMsg).
            extGdsObj:OpenQueryExtGds (tt-wb-gds-EG.alc-code).
            if extGdsObj:NumBundles = 0
            then do:
              StatusErr = true.
              return.
            end.
            else do:
              extGdsValueObj = extGdsObj:GetExtGdsValue().
              message substitute ("&1 Продолжить? (информация по алкокоду будет получена от &2/&3).", Msg + chr(10), string (extGdsValueObj:GdsCode), extGdsValueObj:AlcCode) view-as alert-box question buttons yes-no title "Вопрос..." update isChoise as logical.
              if isChoise
              then do:
                Msg = "".
              end.
              else do:
                StatusErr = true.
                return.
              end.
            end.
          end.
          extGdsValueObj = extGdsObj:GetExtGdsValue().
          sw:start-element ("wb" + verPrefXMLNS + ":Position") .
            sw:write-data-element ("wb" + verPrefXMLNS + ":Identity", tt-wb-gds-EG.Identity).
            sw:start-element ("wb" + verPrefXMLNS + ":Product") .
              sw:write-data-element ("pref" + verPrefXMLNS + ":FullName", extGdsValueObj:FullNameGds).
              sw:write-data-element ("pref" + verPrefXMLNS + ":AlcCode", tt-wb-gds-EG.alc-code).
              if VerWBXsd = 'WayBill_v2'
              then do:
                if tt-wb-gds-EG.UnitType = 'Packed' then sw:write-data-element ("pref" + verPrefXMLNS + ":Capacity", if extGdsValueObj:Capacity <> 0 and extGdsValueObj:Capacity <> ? then string (extGdsValueObj:Capacity) else string (tt-wb-gds-EG.ms-base)).
                sw:write-data-element ("pref" + verPrefXMLNS + ":UnitType", tt-wb-gds-EG.UnitType).
              end.
              else do:
                if tt-wb-header.UnitType = 'Packed' then sw:write-data-element ("pref" + verPrefXMLNS + ":Capacity", string (tt-wb-gds-EG.ms-base)).
              end.
              sw:write-data-element ("pref" + verPrefXMLNS + ":AlcVolume", string (tt-wb-gds-EG.proof)).
              sw:write-data-element ("pref" + verPrefXMLNS + ":ProductVCode", tt-wb-gds-EG.alc-type-code).
              if extGdsValueObj:FullNameProd = ""
              then do:
                StatusErr = true.
                Msg = extGdsObj:ReturnMsg + " У товара неизвестен производитель из ЕГАИС - " + string (tt-wb-gds-EG.gds-code) + ". Выполните синхронизацию товаров.".
                return.
              end.
              if VerWBXsd = 'WayBill_v2' and (extGdsValueObj:CliEgaisTypeProd = "")
              then do:
                StatusErr = true.
                Msg = Msg + extGdsObj:ReturnMsg + " У товара неизвестен тип производителя из ЕГАИС - " + string (tt-wb-gds-EG.gds-code) + ". Выполните синхронизацию товаров во второй схеме XSD." + chr(10).
              end.
              sw:start-element ("pref" + verPrefXMLNS + ":Producer") .
                if VerWBXsd = 'WayBill_v2' and not extGdsValueObj:CliEgaisTypeProd = ""
                  then sw:start-element ("oref" + verPrefXMLNS + ":" + extGdsValueObj:CliEgaisTypeProd) .
                if not ( extGdsValueObj:INNProd = "" or extGdsValueObj:KPPProd = "")
                then do:
                  sw:write-data-element ("oref" + verPrefXMLNS + ":INN",  extGdsValueObj:INNProd ).
                  sw:write-data-element ("oref" + verPrefXMLNS + ":KPP", extGdsValueObj:KPPProd ).
                end.
                sw:write-data-element ("oref" + verPrefXMLNS + ":ClientRegId", extGdsValueObj:CliRegIdProd ).
                sw:write-data-element ("oref" + verPrefXMLNS + ":FullName", extGdsValueObj:FullNameProd ).
                sw:start-element ("oref" + verPrefXMLNS + ":address").
                  sw:write-data-element ("oref" + verPrefXMLNS + ":Country", extGdsValueObj:CountryProd ).
                  if VerWBXsd = "WayBill_v2" and extGdsValueObj:RegionProd <> ""
                    then sw:write-data-element ("oref" + verPrefXMLNS + ":RegionCode", extGdsValueObj:RegionProd ).
                  sw:write-data-element ("oref" + verPrefXMLNS + ":description", extGdsValueObj:DescrProd ).
                sw:end-element ("oref" + verPrefXMLNS + ":address").
                if VerWBXsd = 'WayBill_v2' and not extGdsValueObj:CliEgaisTypeProd = ""
                  then sw:end-element ("oref" + verPrefXMLNS + ":" + extGdsValueObj:CliEgaisTypeProd) .
              sw:end-element ("pref" + verPrefXMLNS + ":Producer") .
              if not extGdsValueObj:FullNameImpor = "" and VerXSD <> '2' then do:
                sw:start-element ("pref" + verPrefXMLNS + ":Importer") .
                  if not ( extGdsValueObj:INNImpor = "" or extGdsValueObj:KPPImpor = "")
                  then do:
                    sw:write-data-element ("oref" + verPrefXMLNS + ":INN",  extGdsValueObj:INNImpor ).
                    sw:write-data-element ("oref" + verPrefXMLNS + ":KPP", extGdsValueObj:KPPImpor ).
                  end.
                  sw:write-data-element ("oref" + verPrefXMLNS + ":ClientRegId", extGdsValueObj:CliRegIdImpor ).
                  sw:write-data-element ("oref" + verPrefXMLNS + ":FullName", extGdsValueObj:FullNameImpor ).
                  sw:start-element ("oref" + verPrefXMLNS + ":address").
                    sw:write-data-element ("oref" + verPrefXMLNS + ":Country", extGdsValueObj:CountryImpor ).
                    sw:write-data-element ("oref" + verPrefXMLNS + ":description", extGdsValueObj:DescrImpor ).
                  sw:end-element ("oref" + verPrefXMLNS + ":address").
                sw:end-element ("pref" + verPrefXMLNS + ":Importer") .
              end.
            sw:end-element ("wb" + verPrefXMLNS + ":Product") .
            sw:write-data-element ("wb" + verPrefXMLNS + ":Quantity", string (tt-wb-gds-EG.qnty)).
            sw:write-data-element ("wb" + verPrefXMLNS + ":Price", string (tt-wb-gds-EG.price)).
            case VerWBXsd:
            when 'WayBill' then do:
              sw:start-element ("wb" + verPrefXMLNS + ":InformA") .
                sw:write-data-element ("pref" + verPrefXMLNS + ":RegId", tt-wb-gds-EG.refA).
              sw:end-element ("wb" + verPrefXMLNS + ":InformA") .
              sw:start-element ("wb" + verPrefXMLNS + ":InformB") .
                sw:start-element ("pref" + verPrefXMLNS + ":InformBItem") .
                  sw:write-data-element ("pref" + verPrefXMLNS + ":BRegId", tt-wb-gds-EG.refB).
                sw:end-element ("pref" + verPrefXMLNS + ":InformBItem") .
              sw:end-element ("wb" + verPrefXMLNS + ":InformB") .
            end.
            when 'WayBill_v2' then do:
              sw:start-element ("wb" + verPrefXMLNS + ":InformF1") .
                sw:write-data-element ("pref" + verPrefXMLNS + ":RegId", tt-wb-gds-EG.refA).
              sw:end-element ("wb" + verPrefXMLNS + ":InformF1") .
              sw:start-element ("wb" + verPrefXMLNS + ":InformF2") .
                sw:start-element ("pref" + verPrefXMLNS + ":InformF2Item") .
                  sw:write-data-element ("pref" + verPrefXMLNS + ":F2RegId", tt-wb-gds-EG.refB).
                sw:end-element ("pref" + verPrefXMLNS + ":InformF2Item") .
              sw:end-element ("wb" + verPrefXMLNS + ":InformF2") .
            end.
            end case.
          sw:end-element ("wb" + verPrefXMLNS + ":Position") .
        end.
        if StatusErr
        then do:
          return.
        end.
        sw:end-element ("wb" + verPrefXMLNS + ":Content") .
      sw:end-element ("ns:" + VerWBXsd) .
    sw:end-element ("ns:Document") .
    sw:end-element ("ns:Documents") .
    delete object sw.
  end.
  method private void AddClientXML (inSW as handle, inObjType as char, inObjCode as int, inRegID as char, inShipper as log):
    find first buf_clients no-lock where buf_clients.obj-type = inObjType and buf_clients.obj-code = inObjCode no-error.
    if available (buf_clients)
    then do:
      if buf_clients.obj-type = 'орг':U
      then do:
        find first buf_firm no-lock where buf_firm.firm-code = buf_clients.obj-code no-error.
      end.
      else do:
        find first buf_firm no-lock where buf_firm.firm-code = buf_clients.host-code no-error.
      end.
      find first buf_clients-attr no-lock where buf_clients-attr.obj-type = inObjType and buf_clients-attr.obj-code = inObjCode
        and buf_clients-attr.attr-code = 'kpp':U no-error.
    end.
    else do:
      Msg = "Не найден клиент " + inObjType + string (inObjCode).
      StatusErr = true.
      return.
    end.
    if available (buf_firm) then do:
      inSW:write-data-element ("oref" + verPrefXMLNS + ":INN", if INNObj = "" or INNObj = ? or not inShipper then buf_firm.inn else INNObj).
      if buf_firm.kpp <> "" and (not buf_clients.obj-type = 'маг':U and not buf_clients.obj-type = 'скл':U) and not available (buf_clients-attr)
        then inSW:write-data-element ("oref" + verPrefXMLNS + ":KPP", buf_firm.kpp).
      if available (buf_clients-attr) and buf_clients-attr.attr-value <> ""
        then inSW:write-data-element ("oref" + verPrefXMLNS + ":KPP", buf_clients-attr.attr-value).
    end.
    else do:
      Msg = "Не найден ИНН организации или объекта " + inObjType + string (inObjCode).
      StatusErr = true.
      return.
    end.
    find first buf_clients-attr no-lock where buf_clients-attr.obj-type = inObjType and buf_clients-attr.obj-code = inObjCode
      and buf_clients-attr.attr-code = 'requisite-alc-decl':U no-error.
    inSW:write-data-element ("oref" + verPrefXMLNS + ":ClientRegId", inRegID).
    if available (buf_clients-attr) and num-entries (buf_clients-attr.attr-value, "|") >= 20
    then do:
      inSW:write-data-element ("oref" + verPrefXMLNS + ":FullName", entry (1, attr-value, "|")).
    end.
    else do:
      Msg = "Не заполнены/неполные атрибуты для алкогольной декларации. Заполните и синхронизируйте с ЕГАИС. Клиент - " + inObjType + string (inObjCode).
      StatusErr = true.
      return.
    end.
    inSW:start-element ("oref" + verPrefXMLNS + ":address").
      if available (buf_clients-attr)
      then do:
        def var descr as char no-undo.
        inSW:write-data-element ("oref" + verPrefXMLNS + ":Country", entry (3, buf_clients-attr.attr-value, "|")).
        if VerWBXsd = "WayBill_v2"
          then inSW:write-data-element ("oref" + verPrefXMLNS + ":RegionCode", entry (5, buf_clients-attr.attr-value, "|") ).
        find first buf_country where buf_country.num-code = integer (entry (3, buf_clients-attr.attr-value, "|")) no-error.
        descr = entry (20, buf_clients-attr.attr-value, "|") no-error.
        descr = replace (descr, chr(5), "|").
        if descr = ? or descr = ""
        then do:
          Msg = "Отсутствует андрес ЕГАИС организации " + inObjType + string (inObjCode) + ' ' + buf_clients.obj-name + ". Обновите данные ЕГАИС по организации.".
          StatusErr = true.
          return.
        end.
        inSW:write-data-element ("oref" + verPrefXMLNS + ":description", descr).
      end.
    inSW:end-element ("oref" + verPrefXMLNS + ":address").
  end.
  method private void GetVerXsd (output outVerDocXsd as char):
    define variable CliEgaisTypeShip as character no-undo.
    define variable CliEgaisTypeCons as character no-undo.
    define variable VerXSDShip       as character no-undo.
    find first tt-wb-header no-error.
    if not available (tt-wb-header)
    then do:
      Msg = "Ошибка определения версии XSD схемы документа".
      StatusErr = true.
      return.
    end.
    find first buf_ext-classif-attr no-lock where buf_ext-classif-attr.classif-subject = 'clients':U
      and buf_ext-classif-attr.classif-name = 'clients-esys':U
      and buf_ext-classif-attr.db-num = 0
      and buf_ext-classif-attr.key#_one = v-ext-sys
      and buf_ext-classif-attr.CharKey_Three = tt-wb-header.regID-Ship
      and buf_ext-classif-attr.attr-code = "egais-cli-info" no-error.
    if available (buf_ext-classif-attr)
    then
      assign
        VerXSDShip = entry (1, buf_ext-classif-attr.attr-value, chr(4))
        CliEgaisTypeShip = entry (2, buf_ext-classif-attr.attr-value, chr(4))
      no-error.
    else VerXSDShip = 'WayBill'.
    if VerXSDShip = ? or VerXSDShip = "" or VerXSDShip = "WayBill" or VerXSD = "1"
    then do:
      outVerDocXsd = "WayBill".
      verPrefXMLNS = "".
    end.
    else do:
      outVerDocXsd = "WayBill_v2".
      verPrefXMLNS = "2".
    end.
    if outVerDocXsd = "WayBill_v2"
    then do:
      find first buf_ext-classif-attr no-lock where buf_ext-classif-attr.classif-subject = 'clients':U
        and buf_ext-classif-attr.classif-name = 'clients-esys':U
        and buf_ext-classif-attr.db-num = 0
        and buf_ext-classif-attr.key#_one = v-ext-sys
        and buf_ext-classif-attr.CharKey_Three = tt-wb-header.regID-Cons
        and buf_ext-classif-attr.attr-code = "egais-cli-info" no-error.
      if available (buf_ext-classif-attr)
      then do:
        assign
          CliEgaisTypeCons = entry (2, buf_ext-classif-attr.attr-value, chr(4))
        no-error.
        if CliEgaisTypeCons = ? or CliEgaisTypeCons = ""
        then do:
          outVerDocXsd = "WayBill".
          verPrefXMLNS = "".
        end.
      end.
      else do:
        outVerDocXsd = "WayBill".
        verPrefXMLNS = "".
      end.
    end.
  end.
end class.
