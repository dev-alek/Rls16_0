using ibs.th.bge.egais.*.
define input parameter parparentproc as widget-handle no-undo .
define input parameter egais as class EGAIS no-undo.
define input parameter bh-wb-egais as handle no-undo.
define variable qh-ticket-egais         as handle  no-undo.
define variable qh-ticket-egais-last    as handle  no-undo.
define variable browse-hdl-ticket-egais as handle  no-undo.
define variable bh-ticket-egais         as handle  no-undo.
define variable isRepealWB              as logical no-undo.
define variable wbregIdRepeal           as character no-undo.
define variable bcol                    as handle extent no-undo.
define variable egaisWBAdv              as class WayBill no-undo.
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
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define buffer buf_doc-attr for ub.doc-attr.
DEFINE BUTTON btn_accRepeal
     LABEL "Подт. расп."
     SIZE 15 BY 1.13.
DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "Выход"
     SIZE 15 BY 1.13
     BGCOLOR 8 .
DEFINE BUTTON btn_rejRepeal
     LABEL "Отказ расп."
     SIZE 15 BY 1.13.
DEFINE VARIABLE cb_status AS CHARACTER FORMAT "X(256)":U
     LABEL "Статус"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Accepted","Rejected","Распроведена","Отсутствует"
     DROP-DOWN-LIST
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 119.25 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FILL-IN-2 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 119.25 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FILL-IN-3 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 119.25 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FILL-IN-4 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 119.25 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FILL-IN-5 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 119.25 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1.25 COL 1.5
     btn_accRepeal AT ROW 1.25 COL 17.13 WIDGET-ID 12
     btn_rejRepeal AT ROW 1.25 COL 32.88 WIDGET-ID 14
     cb_status AT ROW 1.25 COL 55.5 COLON-ALIGNED WIDGET-ID 16
     FILL-IN-1 AT ROW 14.71 COL 1.75 NO-LABEL WIDGET-ID 2
     FILL-IN-3 AT ROW 15.71 COL 1.75 NO-LABEL WIDGET-ID 6
     FILL-IN-2 AT ROW 16.71 COL 1.75 NO-LABEL WIDGET-ID 4
     FILL-IN-4 AT ROW 17.71 COL 1.75 NO-LABEL WIDGET-ID 8
     FILL-IN-5 AT ROW 18.71 COL 1.75 NO-LABEL WIDGET-ID 10
     SPACE(0.37) SKIP(0.11)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Квитанция по накладной"
         DEFAULT-BUTTON Btn_OK WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF btn_accRepeal IN FRAME Dialog-Frame
DO:
  egaisWBAdv:ConfirmRepealWB(wbregIdRepeal, "Accepted").
  if egaisWBAdv:StatusErr
  then do:
    message egaisWBAdv:Msg view-as alert-box error.
    return no-apply.
  end.
END.
ON CHOOSE OF btn_rejRepeal IN FRAME Dialog-Frame
DO:
  egaisWBAdv:ConfirmRepealWB(wbregIdRepeal, "Rejected").
  if egaisWBAdv:StatusErr
  then do:
    message egaisWBAdv:Msg view-as alert-box error.
    return no-apply.
  end.
END.
ON VALUE-CHANGED OF cb_status IN FRAME Dialog-Frame
DO:
  message  substitute ("Вы уверены, что хотите изменить статус накладной с &1 на &2?", bh-wb-egais:buffer-field ("EGAISSts"):buffer-value, cb_status:screen-value) view-as alert-box question buttons yes-no
    title "" update isChoise as logical.
  if isChoise
  then do:
    if egaisWBAdv:ActnEGAISAdm
    then do:
      if bh-wb-egais:buffer-field ("wb-type"):buffer-value begins "расход" or bh-wb-egais:buffer-field ("wb-type"):buffer-value begins "возврат"
      then do:
        find first ub.doc-attr exclusive-lock
          where ub.doc-attr.doc-code = bh-wb-egais:buffer-field ("trn-doc-code"):buffer-value and ub.doc-attr.attr-code = 'egais':U no-error.
        if available (ub.doc-attr)
          then
        do:
          ub.doc-attr.attr-value = if cb_status:screen-value = "Отсутствует" then "" else cb_status:screen-value.
        end.
        release ub.doc-attr.
      end.
      else do:
        for each ub.clob-bind where ub.clob-bind.resource-type = 'egais-wb':U and ub.clob-bind.uniq-key-rec = bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value:
          if num-entries (ub.clob-bind.descr, chr(4)) = 9
          then do:
            ub.clob-bind.descr = ub.clob-bind.descr + chr(4).
          end.
          if num-entries (ub.clob-bind.descr, chr(4)) > 9
          then
            assign
              entry (10, ub.clob-bind.descr, chr(4)) = if cb_status:screen-value = "Отсутствует" then "" else cb_status:screen-value
            .
        end.
        for each buf_doc-attr no-lock
          where buf_doc-attr.doc-code = bh-wb-egais:buffer-field ("wbregid"):buffer-value and buf_doc-attr.attr-code = 'negais':U:
          find first ub.doc-attr exclusive-lock where ub.doc-attr.doc-code = buf_doc-attr.doc-code and ub.doc-attr.attr-code = 'egais':U no-error.
          if available (ub.doc-attr)
            then ub.doc-attr.attr-value = if cb_status:screen-value = "Отсутствует" then "" else cb_status:screen-value.
          release ub.doc-attr.
        end.
      end.
      bh-wb-egais:buffer-field ("EGAISSts"):buffer-value = cb_status:screen-value .
      return.
    end.
    else do:
      message 'Для изменения статуса остутсвует необходимое право "Администрирование запросов в ЕГАИС"' view-as alert-box error title "".
    end.
  end.
  cb_status:screen-value = bh-wb-egais:buffer-field ("EGAISSts"):buffer-value.
  return no-apply.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  def var ii as int no-undo.
  egaisWBAdv = cast (egais:EGAISImpl, ibs.th.bge.egais.WayBill).
  create query qh-ticket-egais.
  create browse browse-hdl-ticket-egais
    assign
      title     = 'Связанные документы ЕГАИС'
      frame     = frame Dialog-Frame:handle
      query     = qh-ticket-egais
      x         = 6
      y         = 38
      width     = 119
      height    = 12
      visible   = true
      read-only = true
      sensitive = true
      separators = true
      column-resizable = true
      column-scrolling = true
      triggers:
        on value-changed persistent run local-value-changed.
      end triggers
  .
  if bh-wb-egais = ? then return.
  if bh-wb-egais:buffer-field ("wb-type"):buffer-value begins "расход" or bh-wb-egais:buffer-field ("wb-type"):buffer-value begins "возврат"
  then do:
    bh-ticket-egais = egais:GetHndlTable(13, bh-wb-egais:buffer-field ("trn-doc-code"):buffer-value).
  end.
  else do:
    bh-ticket-egais = egais:GetHndlTable(12, bh-wb-egais:buffer-field ("wbregid"):buffer-value).
  end.
  if egais:StatusErr
  then do:
    message egais:Msg view-as alert-box error.
    return.
  end.
  qh-ticket-egais:set-buffers (bh-ticket-egais).
  qh-ticket-egais:query-prepare ("for each tt-ticket").
  qh-ticket-egais:query-open.
  if not bh-ticket-egais = ?
  then do:
    extent (bcol) = bh-ticket-egais:num-fields.
    do ii = 1 to bh-ticket-egais:num-fields:
      bcol[ii] = browse-hdl-ticket-egais:add-like-column('tt-ticket' + '.' + bh-ticket-egais:buffer-field (ii):name, 0, 'FILL-IN').
      if ii = 6 then bcol[ii]:width = 80.
      if ii = 2 then bcol[ii]:width = 15.
      if ii = 3 then bcol[ii]:width = 15.
    end.
  end.
  isRepealWB = bh-ticket-egais:find-last ("where docType = 'RequestRepealWB'", no-lock) no-error.
  if isRepealWB
    then wbregIdRepeal = bh-ticket-egais:buffer-field ("regid"):buffer-value.
  if lookup (bh-wb-egais:buffer-field ("EGAISSts"):buffer-value, cb_status:list-items ) = 0 and (bh-wb-egais:buffer-field ("EGAISSts"):buffer-value <> ? and bh-wb-egais:buffer-field ("EGAISSts"):buffer-value <> "")
    then cb_status:list-items = cb_status:list-items + "," + bh-wb-egais:buffer-field ("EGAISSts"):buffer-value.
  cb_status = if bh-wb-egais:buffer-field ("EGAISSts"):buffer-value = "" or bh-wb-egais:buffer-field ("EGAISSts"):buffer-value = ? then "Отсутствует" else bh-wb-egais:buffer-field ("EGAISSts"):buffer-value.
  RUN enable_UI.
  run hide-disp.
  bh-ticket-egais:find-first ("") no-error.
  run local-value-changed.
  if not egaisWBAdv:ActnEGAISSts
    then cb_status:sensitive = false.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY cb_status FILL-IN-1 FILL-IN-3 FILL-IN-2 FILL-IN-4 FILL-IN-5
      WITH FRAME Dialog-Frame.
  ENABLE Btn_OK btn_accRepeal btn_rejRepeal cb_status
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE hide-disp :
do with frame Dialog-Frame:
    if isRepealWB
    then do:
      btn_accRepeal:hidden = false.
      btn_rejRepeal:hidden = false.
    end.
    else do:
      btn_accRepeal:hidden = true.
      btn_rejRepeal:hidden = true.
    end.
  end.
end.
PROCEDURE local-value-changed :
define variable v-str1 as character no-undo.
  define variable v-str2 as character no-undo.
  define variable v-str3 as character no-undo.
  define variable v-str4 as character no-undo.
  define variable v-str5 as character no-undo.
  if not bh-ticket-egais:available
    then return no-apply.
  v-str1 = substring (bh-ticket-egais:buffer-field ("comment"):buffer-value, 1, 115).
  v-str2 = substring (bh-ticket-egais:buffer-field ("comment"):buffer-value, 116, 115).
  v-str3 = substring (bh-ticket-egais:buffer-field ("comment"):buffer-value, 231, 115).
  v-str4 = substring (bh-ticket-egais:buffer-field ("comment"):buffer-value, 346, 115).
  v-str5 = substring (bh-ticket-egais:buffer-field ("comment"):buffer-value, 461, 115).
  display v-str1 @ fill-in-1 with frame Dialog-Frame.
  display v-str2 @ fill-in-3 with frame Dialog-Frame.
  display v-str3 @ fill-in-2 with frame Dialog-Frame.
  display v-str4 @ fill-in-4 with frame Dialog-Frame.
  display v-str5 @ fill-in-5 with frame Dialog-Frame.
end.
