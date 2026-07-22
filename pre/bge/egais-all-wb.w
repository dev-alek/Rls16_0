using ibs.th.bge.egais.*.
define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Журнал запросов ЕГАИС".
define variable th-wb-egais         as handle    no-undo.
define variable bh-wb-egais         as handle    no-undo.
define variable qh-wb-egais         as handle    no-undo.
define variable browse-hdl-wb-egais as handle    no-undo.
define variable bcol                as handle    extent no-undo.
define variable egais               as class     EGAIS   no-undo.
define variable egaisWBAdv          as class     WayBill no-undo.
define variable v-db-num            as integer   no-undo .
define variable v-user-id           as character no-undo .
define variable qh-wb-gds-EG-header as handle    no-undo.
define variable qh-wb-gds-EG        as handle    no-undo.
define variable bh-wb-gds-EG-header as handle    no-undo.
define variable bh-wb-gds-EG        as handle    no-undo.
define variable bh-analiz           as handle    no-undo.
define variable bh-act-header       as handle    no-undo.
define variable nn                  as integer   no-undo.
define variable ii                  as integer   no-undo.
define variable v-value-character   as character no-undo .
define variable v-value-decimal     as decimal   no-undo .
define variable v-value-integer     as integer   no-undo .
define variable v-value-logical     as logical   no-undo .
define variable v-value-type        as character no-undo .
define variable v-value-date        as date      no-undo .
define variable v-ext-sys           as integer   no-undo .
define variable glog                as logical   no-undo.
define variable actnEGAISAdm        as logical   no-undo.
define variable actnEGAISSts        as logical   no-undo.
define variable v-uniq-key-rec      as character no-undo.
define variable v-trn-doc           as character no-undo.
define variable v-width             as decimal   no-undo.
define variable v-height            as decimal   no-undo.
define variable v-windth            as integer no-undo.
define variable v-isDisp            as character no-undo.
define variable par-alcohol         as character no-undo .
define variable par-type            as character no-undo .
define variable v-gds-uniq-key-rec  as character no-undo .
define stream strlog.
define stream str-FormF1.
define buffer buf_goods          for ub.goods.
define buffer buf_parts          for ub.parts .
define buffer buf_trn-doc        for ub.trn-doc .
define buffer buf_doc-line       for ub.doc-line .
define buffer x_ext-classif      for ub.ext-classif .
define buffer x_ext-classif-attr for ub.ext-classif-attr .
define buffer buf_clob-bind      for ub.clob-bind .
define buffer buf_clob-data      for ub.clob-data .
define variable v-fs-rar as character no-undo view-as text format "X(15)" label "Код ФС РАР (FSRAR ID)" .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
procedure thbjattr_code :
   define input  parameter p-upper-code     as character no-undo .
   define input  parameter p-code           as character no-undo .
   define output parameter p-label          as character no-undo .
   define output parameter p-user-can-edit  as logical   no-undo .
   define output parameter p-output-display as logical   no-undo .
   define output parameter p-other          as character no-undo .
   define output parameter p-prop-list      as character no-undo .
   define output parameter p-prop-type-list as character no-undo .
   define output parameter p-prop-label-list as character no-undo .
   define output parameter p-global          as logical no-undo .
   define output parameter p-host           as logical no-undo .
   define output parameter p-shop           as logical no-undo .
   define output parameter p-store          as logical no-undo .
   define output parameter p-db             as logical no-undo .
   define variable p-region as logical no-undo.
   run thbjattr_code_reg in this-procedure (
                                            p-upper-code,
                                            p-code,
                                            output p-label,
                                            output p-user-can-edit,
                                            output p-output-display,
                                            output p-other,
                                            output p-prop-list,
                                            output p-prop-type-list,
                                            output p-prop-label-list,
                                            output p-global,
                                            output p-host,
                                            output p-shop,
                                            output p-store,
                                            output p-db,
                                            output p-region
                                            ).
end procedure.
procedure thbjattr_code_reg :
define input  parameter p-upper-code     as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-label          as character no-undo .
define output parameter p-user-can-edit  as logical   no-undo .
define output parameter p-output-display as logical   no-undo .
define output parameter p-other          as character no-undo .
define output parameter p-prop-list      as character no-undo .
define output parameter p-prop-type-list as character no-undo .
define output parameter p-prop-label-list as character no-undo .
define output parameter p-global          as logical no-undo .
define output parameter p-host           as logical no-undo .
define output parameter p-shop           as logical no-undo .
define output parameter p-store          as logical no-undo .
define output parameter p-db             as logical no-undo .
define output parameter p-region         as logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_code in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-label
    ,output p-user-can-edit
    ,output p-output-display
    ,output p-other
    ,output p-prop-list
    ,output p-prop-type-list
    ,output p-prop-label-list
    ,output p-global
    ,output p-host
    ,output p-shop
    ,output p-store
    ,output p-db
    ,output p-region
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info3, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_tooltip :
define input  parameter p-upper-code  as character no-undo .
define input  parameter p-code      as character no-undo .
define output parameter p-tooltip   as character no-undo .
define output parameter p-label     as character no-undo .
define output parameter p-tooltip-code as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_tooltip in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-tooltip
    ,output p-label
    ,output p-tooltip-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_legacy :
define input  parameter p-upper-code     as character no-undo .
define output parameter p-level-way      as character no-undo .
define output parameter p-up-way         as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_legacy in g#attr-lib
    (input  p-upper-code
    ,output p-level-way
    ,output p-up-way
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info3, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_value :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define output parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define output parameter p-value-date    like ub.thbj-attr.property-value-date no-undo .
define output parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define output parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define output parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
define output parameter p-type     as character no-undo .
define output parameter p-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_value in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-value-character
    ,output p-value-date
    ,output p-value-decimal
    ,output p-value-integer
    ,output p-value-logical
    ,output p-type
    ,output p-found
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_get-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-param-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-mode as character no-undo .
define input-output parameter table-handle p-tth.
define output parameter p-all-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_get-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-param-code
    ,input  p-mode
    ,input-output table-handle p-tth
    ,output p-all-found
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_write :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define input  parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define input  parameter p-value-date like ub.thbj-attr.property-value-date no-undo .
define input  parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define input  parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define input  parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_write in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,input  p-value-character
    ,input  p-value-date
    ,input  p-value-decimal
    ,input  p-value-integer
    ,input  p-value-logical
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_set-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter table-handle p-tth.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_set-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  table-handle p-tth
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_delete :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code       like ub.thbj-attr.prop-code  no-undo .
define output parameter p-deleted  as logical no-undo.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-deleted
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_delete-section :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_manual-edit :
define input  parameter p-ucode          as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-section-num    as integer no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_manual-edit in g#attr-lib
    (input  p-ucode
    ,input  p-code
    ,output  p-section-num
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-waitfram-action01         as character   no-undo .
define variable v-waitfram-action02         as character   no-undo .
define variable v-waitfram-action03         as character   no-undo .
define variable mWaitFramTextBeg            as character   no-undo.
define variable mWaitFramTextEnd            as character   no-undo.
define variable mWaitFramView               as logical     no-undo.
define variable mWaitProcEvent              as logical     no-undo init yes.
define variable mWaitFramInterval           as integer     no-undo init 1 .
define variable mWaitFramStop               as logical     no-undo.
define variable mWaitFramStopUser           as logical     no-undo.
define variable mWaitFramStopTimeOut        as logical     no-undo.
define variable mWaitFramStartProc          as datetime-tz no-undo.
define variable mWaitFramTimeOut            as decimal     no-undo init ?.
define button B-WaitFramStop auto-end-key
     label "Стоп"
     size 10 by 1 tooltip "Остоновить процесс".
define button B-viewProcInfo
     label "Информация"
     size 15 by 1 tooltip "Информация о процесс".
define frame waitfram
  v-waitfram-action01 format "x(72)" no-label skip
  v-waitfram-action02 format "x(72)" no-label skip
  v-waitfram-action03 format "x(72)" no-label skip
  B-viewProcInfo
  B-WaitFramStop at row 4 col 30
  with view-as dialog-box side-labels three-d cancel-button B-WaitFramStop
  .
define new global shared variable mBatchMode as logical no-undo init ?.
define variable mFramBachModHandle as handle no-undo.
mFramBachModHandle = frame waitfram:handle.
define variable mFameOldVis as logical no-undo.
define variable mVisCUrentVin as logical no-undo.
if session:batch-mode
then
   mBatchMode = yes.
if mBatchMode = ? then do:
  mVisCUrentVin = current-window:visible.
  mFameOldVis = mFramBachModHandle:visible.
  mFramBachModHandle:visible  = yes.
  mBatchMode = mFramBachModHandle:visible ne yes.
  mFramBachModHandle:visible = mFameOldVis.
  current-window:visible = mVisCUrentVin.
end.
 if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramBachModHandle:visible), "frameRepError").
  end.
on choose of B-WaitFramStop in frame waitfram
do:
  mWaitFramStop = yes.
  mWaitFramStopUser = yes.
end.
function waitfram-check-timeout returns logical():
   define variable vtime as int64 no-undo.
   if mWaitFramStopTimeOut
   then
      return yes.
   vtime = ( now - mWaitFramStartProc ) / 1000 .
   if     mWaitFramTimeOut ne ?
      and mWaitFramTimeOut ne 0
      and mWaitFramTimeOut lt vtime
   then do:
      mWaitFramStopTimeOut = yes.
   end.
   return mWaitFramStopTimeOut.
end.
procedure waitfram-hide :
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    pause 0 before-hide .
    if not mBatchMode then
      hide frame waitfram .
  if     not mWaitFramView
     and mWaitProcEvent
  then
    process events .
  end.
end procedure.
procedure waitfram-show :
  define input  parameter p-message as character no-undo .
  define variable v-left-margin as integer   no-undo .
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    if length(p-message) <= 70 then do:
      assign
        v-left-margin = integer((70 - length(p-message)) / 2)
      .
      assign
        v-left-margin = max(0, v-left-margin - (v-left-margin mod 5))
      .
      assign
        v-waitfram-action01 = " "
        v-waitfram-action02 = " "
                                 + fill(" ", v-left-margin)
                                 + p-message
        v-waitfram-action03 = " "
      .
    end.
    else do:
      define variable vRindex1 as integer no-undo.
      define variable vRindex2 as integer no-undo.
      vRindex1 = r-index(p-message," ",70).
      if vRindex1 = 0
      then
         vRindex1 = 70.
      if length(p-message)  <= vRindex1 + 70 then do:
        assign
          v-waitfram-action01 = " "
          v-waitfram-action02 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action03 = " " + substring(p-message,  vRindex1 + 1, 70      )
        .
      end.
      else do:
        vRindex2 = r-index(p-message," ",vRindex1 + 70).
        if vRindex2 <= vRindex1
        then
           vRindex2 = vRindex1 + 70.
        assign
          v-waitfram-action01 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action02 = " " + substring(p-message,  vRindex1 + 1, vRindex2 - vRindex1 )
          v-waitfram-action03 = " " + substring(p-message,  vRindex2 + 1, 70)
        .
      end.
    end.
    B-viewProcInfo:visible   in frame waitfram = no.
    B-viewProcInfo:sensitive in frame waitfram = no.
    B-WaitFramStop:visible   in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    B-WaitFramStop:sensitive in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    if  (   mWaitFramView
       or  mWaitProcEvent)
       and not mBatchMode
    then
       display
          v-waitfram-action01 skip
          v-waitfram-action02 skip
          v-waitfram-action03 skip
       with frame waitfram .
    if     mWaitFramView
       then do:
          if     mWaitFramInterval ne ?
             and not mBatchMode
          then
             wait-for go of frame waitfram pause mWaitFramInterval.
       end.
       else
          if     mWaitProcEvent
             and not mBatchMode
          then
             process events .
  end.
end procedure.
   procedure waitfram-show-this:
      define input  parameter iInterval as int64 no-undo.
      define variable vtime as int64 no-undo.
      vtime = ( now - mWaitFramStartProc  ) / 1000 .
      mWaitFramInterval = iInterval.
      run waitfram-show (substitute("&1&2 &3&4" ,
                                    mWaitFramTextBeg ,
                                    if vtime eq ? then "" else substitute (" Прошло: &1 сек" , string( vtime)),
                                    if mWaitFramTimeOut ne 0 and mWaitFramTimeOut ne ? then " из " + string(mWaitFramTimeOut) + " сек. " else "",
                                    mWaitFramTextEnd
                                   )
                        ).
   end.
   procedure WaitFramRunPause:
      define input  parameter iInterval as dec no-undo.
      define variable vStart  as datetime-tz no-undo.
      define variable vend    as datetime-tz no-undo.
      define variable vint as int64 no-undo.
      define variable vOk as logical no-undo.
      vStart = now.
      vend   = vStart.
      publish "WaitFramPause" (iInterval,output vOk).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and (   vint > 0
              or (    not vOk
                  and iInterval eq ?
                  )
              )
      then
         run waitfram-show-this (iInterval).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and vint > 0
      then do:
         run gbl/pause.p (vint * 1000).
      end.
      if iInterval ne ?
      then
         publish "WaitFramStop".
      waitfram-check-timeout().
   end.
   procedure WaitFramWaitFor:
      define input  parameter iInterval as dec no-undo.
      assign
         mWaitFramStartProc   = now
         mWaitFramStopUser    = no
         mWaitFramStopTimeOut = no
      .
      block-wait:
      do while not mWaitFramStop:
         run WaitFramRunPause (iInterval).
         if  waitfram-check-timeout()
         then do:
            leave block-wait.
         end.
      end.
      run waitfram-hide.
   end.
procedure waitfram-join :
  define input  parameter p-line-1  as character no-undo .
  define input  parameter p-line-2  as character no-undo .
  define input  parameter p-line-3  as character no-undo .
  define output parameter p-message as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-message = substring(p-line-1 + fill(' ', 70), 1, 70)
                + substring(p-line-2 + fill(' ', 70), 1, 70)
                + substring(p-line-3 + fill(' ', 70), 1, 70)
    .
  end.
end procedure.
function waitfram-join-function returns character
  (input p-line-1 as character
  ,input p-line-2 as character
  ,input p-line-3 as character
  ).
  define variable v-message as character no-undo .
  run waitfram-join in this-procedure
    (input  p-line-1
    ,input  p-line-2
    ,input  p-line-3
    ,output v-message
    ) .
  return v-message .
end function .
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
define variable sw as handle no-undo .
define variable v-file              as character no-undo initial "TransferToShop1.xml".
DEFINE VARIABLE hDoc AS HANDLE NO-UNDO.
DEFINE VARIABLE hRoot AS HANDLE NO-UNDO.
DEFINE VARIABLE good AS LOGICAL NO-UNDO.
procedure makeXML :
    create sax-writer sw .
    sw:formatted = true.
    sw:set-output-destination ("file", v-file).
    sw:encoding = "UTF-8".
    sw:start-document () .
    sw:start-element ("ns:Documents") .
    sw:insert-attribute ("Version", "1.0") .
    sw:insert-attribute ("xmlns:ns", "http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01") .
    sw:insert-attribute ("xmlns:xs", "http://www.w3.org/2001/XMLSchema") .
    sw:insert-attribute ("xmlns:c", "http://fsrar.ru/WEGAIS/Common") .
    sw:insert-attribute ("xmlns:pref", "http://fsrar.ru/WEGAIS/ProductRef_v2") .
    sw:insert-attribute ("xmlns:tts", "http://fsrar.ru/WEGAIS/TransferToShop") .
        sw:start-element ("ns:Owner") .
            sw:write-data-element ("ns:FSRAR_ID", v-fs-rar) .
        sw:end-element ("ns:Owner") .
        sw:start-element ("ns:Document") .
            sw:start-element ("ns:TransferToShop") .
                sw:write-data-element ("tts:Identity", tt-act-header.num) no-error .
                sw:start-element ("tts:Header") .
                    sw:write-data-element ("tts:TransferNumber", tt-act-header.num) no-error .
                    sw:write-data-element ("tts:TransferDate", string(iso-date(tt-act-header.date_))) no-error .
                sw:end-element ("tts:Header") .
                sw:start-element ("tts:Content") .
    for each tt-gds-act no-lock where tt-gds-act.num = tt-act-header.num :
                    sw:start-element ("tts:Position") .
                        sw:write-data-element ("tts:Identity", string(tt-gds-act.position_)) no-error .
                        sw:write-data-element ("tts:Quantity", string(tt-gds-act.qnty)) no-error .
                        sw:write-data-element ("gds-code", string(tt-gds-act.gds-code)) no-error .
                        sw:write-data-element ("gds-name", tt-gds-act.gds-name) no-error .
                        sw:write-data-element ("alc-code", tt-gds-act.alc-code) no-error .
                        sw:start-element ("tts:InformB") .
                            sw:write-data-element ("pref:BRegId", tt-gds-act.inform-B) no-error .
                        sw:end-element ("tts:InformB") .
                    sw:end-element ("tts:Position") .
    end.
                sw:end-element ("tts:Content") .
            sw:end-element ("ns:TransferToShop") .
        sw:end-element ("ns:Document") .
    sw:end-element ("ns:Documents") .
    sw:end-document () .
    delete object sw.
end procedure .
procedure makeXMLegais_v2 :
    create sax-writer sw .
    sw:formatted = true.
    sw:set-output-destination ("file", v-file).
    sw:encoding = "UTF-8".
    sw:start-document () .
    sw:start-element ("ns:Documents") .
    sw:insert-attribute ("Version", "1.0") .
    sw:insert-attribute ("xmlns:ns", "http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01") .
    sw:insert-attribute ("xmlns:xs", "http://www.w3.org/2001/XMLSchema") .
    sw:insert-attribute ("xmlns:c", "http://fsrar.ru/WEGAIS/Common") .
    sw:insert-attribute ("xmlns:pref", "http://fsrar.ru/WEGAIS/ProductRef_v2") .
    sw:insert-attribute ("xmlns:tts", "http://fsrar.ru/WEGAIS/TransferToShop") .
        sw:start-element ("ns:Owner") .
            sw:write-data-element ("ns:FSRAR_ID", v-fs-rar) .
        sw:end-element ("ns:Owner") .
        sw:start-element ("ns:Document") .
            sw:start-element ("ns:TransferToShop") .
                sw:write-data-element ("tts:Identity", tt-act-header.num) .
                sw:start-element ("tts:Header") .
                    sw:write-data-element ("tts:TransferNumber", tt-act-header.num) .
                    sw:write-data-element ("tts:TransferDate", string(iso-date(tt-act-header.date_))) no-error .
                sw:end-element ("tts:Header") .
                sw:start-element ("tts:Content") .
    for each tt-gds-act no-lock where tt-gds-act.num = tt-act-header.num :
        if tt-gds-act.qnty <= 0 or trim(tt-gds-act.inform-B) = "" or tt-gds-act.inform-B = ? then next.
                    sw:start-element ("tts:Position") .
                        sw:write-data-element ("tts:Identity", string(tt-gds-act.position_)) .
                        sw:write-data-element ("tts:ProductCode", tt-gds-act.alc-code) no-error .
                        sw:write-data-element ("tts:Quantity", string(tt-gds-act.qnty)) .
                        sw:start-element ("tts:InformF2") .
                          sw:write-data-element ("pref:F2RegId", tt-gds-act.inform-B) .
                        sw:end-element ("tts:InformF2") .
                    sw:end-element ("tts:Position") .
    end.
                sw:end-element ("tts:Content") .
            sw:end-element ("ns:TransferToShop") .
        sw:end-element ("ns:Document") .
    sw:end-element ("ns:Documents") .
    sw:end-document () .
    delete object sw.
end procedure .
procedure parseXML :
    define input parameter inFile as character no-undo .
    empty temp-table tt-act-header .
    empty temp-table tt-gds-act .
    CREATE X-DOCUMENT hDoc.
    CREATE X-NODEREF hRoot.
    hDoc:encoding = 'utf-8'.
    hDoc:LOAD("file", search(inFile),FALSE).
    hDoc:GET-DOCUMENT-ELEMENT(hRoot).
    RUN GetChildren(hRoot, 1).
    DELETE OBJECT hDoc.
    DELETE OBJECT hRoot.
end procedure .
procedure GetChildren :
    DEFINE INPUT PARAMETER hParent AS HANDLE NO-UNDO.
    DEFINE INPUT PARAMETER level AS INTEGER NO-UNDO.
    DEFINE VARIABLE i AS INTEGER NO-UNDO.
    DEFINE VARIABLE hNoderef AS HANDLE NO-UNDO.
    DEFINE VARIABLE hText AS HANDLE NO-UNDO.
    CREATE X-NODEREF hNoderef.
    CREATE X-NODEREF hText .
    REPEAT i = 1 TO hParent:NUM-CHILDREN:
        good = hParent:GET-CHILD(hNoderef,i).
        IF NOT good THEN
            LEAVE.
        IF hNoderef:SUBTYPE <> "element" THEN
            NEXT.
        hNoderef:GET-CHILD(hText, 1) no-error .
        IF hNoderef:NAME = "tts:Header" THEN do :
            create tt-act-header .
            assign tt-act-header.is-sent = bh-act-header:buffer-field("is-sent"):buffer-value no-error.
        end .
        .
        IF hNoderef:NAME = "tts:TransferNumber" THEN assign tt-act-header.num    = hText:node-value no-error .
        IF hNoderef:NAME = "tts:TransferDate" THEN
            assign tt-act-header.date_ = date(substring(hText:node-value, 9, 2) + "/" + substring(hText:node-value, 6, 2) + "/" + substring(hText:node-value, 1, 4)) no-error .
        IF hNoderef:NAME = "tts:Position" THEN do :
            assign ii = 0 .
            create tt-gds-act .
            assign tt-gds-act.num = tt-act-header.num .
        end.
        IF hNoderef:NAME = "tts:Identity" THEN assign tt-gds-act.position_ = integer(hText:node-value) no-error .
        IF hNoderef:NAME = "tts:Quantity" THEN assign tt-gds-act.qnty = decimal(hText:node-value) no-error .
        IF hNoderef:NAME = "pref:BRegId"
        OR hNoderef:NAME = "pref:F2RegId" THEN assign tt-gds-act.inform-B = (hText:node-value) no-error .
        IF hNoderef:NAME = "gds-code"     THEN do :
            assign tt-gds-act.gds-code = integer(hText:node-value) no-error .
            find first buf_goods no-lock where buf_goods.gds-code = tt-gds-act.gds-code no-error .
            if available buf_goods then assign tt-gds-act.gds-name = buf_goods.gds-name .
        end.
        if hNoderef:NAME = "gds-name" and trim(tt-gds-act.gds-name) = "" then assign tt-gds-act.gds-name = (hText:node-value) no-error .
        IF hNoderef:NAME = "alc-code"
        OR hNoderef:NAME = "tts:ProductCode"    THEN assign tt-gds-act.alc-code = (hText:node-value) no-error .
        run GetChildren (hNoderef, (level + 1)).
    END.
    DELETE OBJECT hNoderef.
    DELETE OBJECT hText.
END procedure.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gds-attr-name :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-name in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-value :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define output parameter p-value    as character no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-write :
  define input parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define input parameter p-value    like ub.goods-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-write in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-exist :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-delete :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy-to :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy-to in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-ptrl-divis :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-ptrl-divis in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-glob-sum-grps :
  define input  parameter p-mode        as character no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
  define input-output parameter p-value as integer no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-glob-sum-grps in g#attr-lib
      (input p-mode
      ,input p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-ptrl-densities :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-ptrl-densities in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-CommodityCode :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-CommodityCode in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-office-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-office-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-mark-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-mark-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-emrc-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-emrc-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-group-np :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-group-np in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-item-matter-mark :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-item-matter-mark in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-type-method-calc :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-type-method-calc in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-is-loyalty-payment :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-is-loyalty-payment in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-15x80 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-15x80 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-8x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-8x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-6x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-6x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-manual-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-batch-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-energy-value :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-energy-value in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-set-dt-seasons :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-can-set  as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-set-dt-seasons in g#attr-lib
      (input  p-gds-code
      ,output p-can-set
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isExemplarGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isExemplarGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isVolumArticGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isVolumArticGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
DEFINE BUTTON Btn_accept
     LABEL "Подтв."
     SIZE 10 BY 1.21.
DEFINE BUTTON Btn_conn
     LABEL "Связать"
     SIZE 10 BY 1.21.
DEFINE BUTTON Btn_Del
     LABEL "Отказ"
     SIZE 10 BY 1.21.
DEFINE BUTTON Btn_delclob
     LABEL "Удалить"
     SIZE 10 BY 1.21 TOOLTIP "Удаляет из базы TH. Если данные в УТМ остались, то будет загружено повторно.".
DEFINE BUTTON Btn_dnlw
     LABEL "Загрузить"
     SIZE 10 BY 1.21.
DEFINE BUTTON Btn_OK
     LABEL "Выход"
     SIZE 10 BY 1.21
     BGCOLOR 8 .
DEFINE BUTTON Btn_Save
     LABEL "Сохранить"
     SIZE 10 BY 1.21
     BGCOLOR 8 .
DEFINE BUTTON Btn_Sel
     LABEL "Изменить"
     SIZE 10 BY 1.21
     BGCOLOR 8 .
DEFINE BUTTON btn_ticket
     LABEL "Просмотр"
     SIZE 10 BY 1.21.
DEFINE VARIABLE cb-1 AS INTEGER FORMAT "->,>>>,>>9" INITIAL 1
     VIEW-AS COMBO-BOX
     LIST-ITEM-PAIRS "Полученные",1,
                     "Закрытые на факт",2,
                     "Акты",3,
                     "Расход",4
     DROP-DOWN-LIST
     SIZE 19.88 BY 1 NO-UNDO.
DEFINE VARIABLE f-type AS CHARACTER FORMAT "X(256)":U INITIAL "Все"
     LABEL "Тип"
     VIEW-AS COMBO-BOX
     LIST-ITEMS "Все","приход вн.","возврат пост.","расход внутренний","расход внешний"
     DROP-DOWN-LIST
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-cli-code AS INTEGER FORMAT "->>>>>>9":U INITIAL 0
     LABEL "Код"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-cli-name AS CHARACTER FORMAT "x(256)":U
     LABEL "Контрагент"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-date AS DATE FORMAT "99/99/99":U
     LABEL "Дата с"
     VIEW-AS FILL-IN
     SIZE 9.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-date-2 AS DATE FORMAT "99/99/99":U
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 9.5 BY 1 NO-UNDO.
DEFINE VARIABLE TOGGLE_NotConn AS LOGICAL INITIAL no
     LABEL "Не связ."
     VIEW-AS TOGGLE-BOX
     SIZE 11.13 BY 1 NO-UNDO.
DEFINE MENU popup-menu-reject
       MENU-ITEM m_reject LABEL "Отправить акт отказа" ACCELERATOR "ALT-1"
       MENU-ITEM m_reqRepealWB LABEL "Отправить запрос на отмену проведения накладной" ACCELERATOR "ALT-2"
.
DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1.21 COL 2.63
     Btn_Sel AT ROW 1.21 COL 13.25 WIDGET-ID 6
     Btn_Save AT ROW 1.21 COL 24 WIDGET-ID 10
     Btn_dnlw AT ROW 1.21 COL 34.63 WIDGET-ID 12
     Btn_conn AT ROW 1.21 COL 45 WIDGET-ID 16
     Btn_Del AT ROW 1.21 COL 55.63 WIDGET-ID 14
     btn_ticket AT ROW 1.21 COL 66 WIDGET-ID 36
     Btn_accept AT ROW 1.21 COL 76.63 WIDGET-ID 32
     Btn_delclob AT ROW 1.21 COL 86.88 WIDGET-ID 38
     cb-1 AT ROW 1.21 COL 98.5 COLON-ALIGNED NO-LABEL WIDGET-ID 2
     f-date AT ROW 2.5 COL 8.63 COLON-ALIGNED WIDGET-ID 22
     f-date-2 AT ROW 2.5 COL 22.75 COLON-ALIGNED WIDGET-ID 26
     f-cli-name AT ROW 2.5 COL 45.25 COLON-ALIGNED WIDGET-ID 24
     f-cli-code AT ROW 2.5 COL 65.25 COLON-ALIGNED WIDGET-ID 30
     f-type AT ROW 2.5 COL 85 COLON-ALIGNED WIDGET-ID 28
     TOGGLE_NotConn AT ROW 2.5 COL 101.75 WIDGET-ID 34
     SPACE(8.74) SKIP(25.23)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Накладные/акты ЕГАИС" WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON window-close OF FRAME Dialog-Frame
do:
  apply "END-ERROR":U to self.
end.
ON CHOOSE OF Btn_accept IN FRAME Dialog-Frame
DO:
  if not bh-wb-egais:available
    then return no-apply.
  if actnEGAISAdm then do:
define variable vss-include-info9 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_egais-accept':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
    if not glog then  return .
    message  substitute ("Вы уверены, что хотите подтвердить накладную &1/&2 без проверок?", bh-wb-egais:buffer-field ("trn-doc-code"):buffer-value, entry (1, bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value, chr(6)) ) view-as alert-box question buttons yes-no
      title "" update isChoise as logical.
    if not isChoise
      then return no-apply.
    bh-wb-gds-EG = ?.
    bh-wb-gds-EG-header = ?.
    bh-wb-gds-EG-header = egais:GetHndlTable(1, bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value).
    v-uniq-key-rec = bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value.
    if egais:StatusErr
    then do:
      message egais:Msg view-as alert-box error.
      return no-apply.
    end.
    egaisWBAdv:SendForceAccept().
    if egaisWBAdv:StatusErr
      then message egaisWBAdv:Msg view-as alert-box error.
      else do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input bh-wb-egais:buffer-field('trn-doc-code'):buffer-value ,
                       input 'egais':U ,
                       input '0':U ) no-error .
        message "Отправлен акт на накладную" view-as alert-box.
      end.
    run f-query.
  end.
  else do:
    message "Отсутсвуют права для данной операции." view-as alert-box.
  end.
END.
ON choose OF Btn_conn IN FRAME Dialog-Frame
do:
  def var loc-ref-list as character no-undo.
  def var v-negais     as character no-undo.
  def var v-date       as character no-undo.
  define variable v-part-num    as integer   no-undo.
  define variable v-clob-db-num as integer   no-undo.
  define variable v-int64-id    as int64     no-undo.
  define variable v-info        as character no-undo.
  if not bh-wb-egais:available
    then return no-apply.
  v-uniq-key-rec = bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value.
  case cb-1:
  when 1 then do:
    bh-wb-gds-EG = ?.
    bh-wb-gds-EG-header = ?.
    bh-wb-gds-EG-header = egais:GetHndlTable(1, bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value).
    if egais:StatusErr
    then do:
      message egais:Msg view-as alert-box error.
      return no-apply.
    end.
    run str/all-docs.w
      (  input parparentproc,
          input v-cntxt-host-code-obj ,
          input v-cntxt-obj-type ,
          input v-cntxt-obj-code ,
          input 'выбор':U,
          input ?,
          input 'при':U,
          input ?,
          input ?,
          input "b-sel":U,
          input 'ie':U,
          input no,
          input ?,
          output loc-ref-list ).
    find first ub.trn-doc no-lock where recid (ub.trn-doc) = integer (loc-ref-list) no-error.
    if not available (ub.trn-doc)
      then return.
    bh-wb-gds-EG = ?.
    bh-wb-gds-EG-header = ?.
    bh-wb-gds-EG-header = egais:GetHndlTable(1, bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value).
    bh-wb-gds-EG = egais:GetHndlTable(2, bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value).
    find first ub.clients
      where ub.clients.obj-type = bh-wb-gds-EG-header:buffer-field ("cli-type"):buffer-value
        and ub.clients.obj-code = integer (bh-wb-gds-EG-header:buffer-field ("cli-code"):buffer-value) no-error.
    if not available (ub.clients)
    then do:
      message "Не найден клиент TH для EGAIS контрагентa regID: " + bh-wb-gds-EG-header:buffer-field ('regId-Ship'):buffer-value view-as alert-box.
      return no-apply.
    end.
    find first ub.clients
      where ub.clients.obj-type = bh-wb-gds-EG-header:buffer-field ("obj-type"):buffer-value
        and ub.clients.obj-code = integer (bh-wb-gds-EG-header:buffer-field ("obj-code"):buffer-value) no-error.
    if not available (ub.clients)
    then do:
      message "Не найден объект TH для EGAIS получателя regID: " + bh-wb-gds-EG-header:buffer-field ('regId-Cons'):buffer-value view-as alert-box.
      return no-apply.
    end.
    bh-wb-gds-EG:find-first ("where tt-wb-gds-EG.gds-code = ?", no-lock) no-error.
    if bh-wb-gds-EG:available then do:
      message "Не найден товар TH для EGAIS товара AlcCode: " + bh-wb-gds-EG:buffer-field ('alc-code'):buffer-value view-as alert-box.
      return no-apply.
    end.
    egais:ConnWB(bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value, ub.trn-doc.doc-code).
    if egais:StatusErr
      then message egais:Msg view-as alert-box error.
    else do:
      message "Накладная связана" view-as alert-box.
    end.
    output stream strlog to value ("egaislog.txt") append.
    export stream strlog egais:Msg.
    output stream strlog close.
  end.
  when 2 then do:
    if bh-wb-egais:buffer-field ("EGAISSts"):buffer-value () <> "Accepted"
    then do:
      message 'Aкт передачи в торговый зал возможно сформировать только для накладной в статусе "Accepted"!' view-as alert-box information title "Информация".
      undo, return.
    end.
    find first buf_trn-doc no-lock where buf_trn-doc.doc-code = bh-wb-egais:buffer-field ("trn-doc-code"):buffer-value no-error .
    if error-status :error then return .
    v-date = substitute ("&1&2&3", string (day (now), "99"), string (month (now), "99"),substring (string(year (now)), 3,2)).
    create tt-act-header .
    assign
        tt-act-header.num = "TTS-" + v-date + '-' + substring(v-cntxt-obj-type,1,1) + string(v-cntxt-obj-code) + '-' + buf_trn-doc.doc-code
        tt-act-header.date_ = TODAY
        tt-act-header.is-sent = no
    .
    for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code :
        find first buf_goods no-lock where buf_goods.artic      = buf_doc-line.artic
                                       and buf_goods.prod-type  = buf_doc-line.prod-type
                                       and buf_goods.prod-code  = buf_doc-line.prod-code .
        run gds-attr-value(
          buf_goods.gds-code,
          'alcohol-prod':U,
          output par-alcohol,
          output par-type
        ).
        if par-alcohol = "" or par-alcohol = "no" then next .
        for each buf_parts no-lock where buf_parts.artic        = buf_doc-line.artic
                                     and buf_parts.prod-type    = buf_doc-line.prod-type
                                     and buf_parts.prod-code    = buf_doc-line.prod-code
                                     and buf_parts.obj-type     = buf_doc-line.obj-type
                                     and buf_parts.obj-code     = buf_doc-line.obj-code
                                     and buf_parts.out-code     = buf_doc-line.doc-code :
             assign nn = nn + 1 .
             create tt-gds-act .
             assign
                tt-gds-act.num          = tt-act-header.num
                tt-gds-act.gds-code     = buf_goods.gds-code
                tt-gds-act.gds-name     = buf_goods.gds-name
                tt-gds-act.position_    = nn
                tt-gds-act.qnty         = buf_parts.fact-qnty / buf_parts.cli-base-rate
             .
             if num-entries(buf_parts.alc-ref-ab-path) = 4 and entry(3, buf_parts.alc-ref-ab-path) <> "" then do :
                 tt-gds-act.alc-code = entry(3, buf_parts.alc-ref-ab-path) .
             end.
             else do :
                 run gen-key-rec IN THIS-PROCEDURE ( input 'goods':U
                                                    ,input (buffer buf_goods:handle)
                                                    ,output v-gds-uniq-key-rec).
                 find first X_ext-classif no-lock where X_ext-classif.classif-subject = 'goods':U
                                                   and X_ext-classif.classif-name = 'exp-esys-gds-code':U
                                                   AND X_ext-classif.db-num = 0
                                                   and X_ext-classif.key#_one = buf_goods.gds-code
                                                   and X_ext-classif.key#_two = v-ext-sys
                                                   and X_ext-classif.key#_three = 0
                                                   and X_eXt-classif.uniq-key-rec = v-gds-uniq-key-rec
                                                   and X_eXt-classif.charkey_two = ""
                                                   and X_eXt-classif.charkey_three = ""
                                                   and X_eXt-classif.nonunique = 0
                                                   no-error .
                 if available X_ext-classif then tt-gds-act.alc-code = X_eXt-classif.charkey_one .
             end.
             if num-entries(buf_parts.alc-ref-ab-path) = 4 and entry(2, buf_parts.alc-ref-ab-path) <> "" then do :
                 tt-gds-act.inform-B = trim(entry(2, buf_parts.alc-ref-ab-path)) .
             end.
        end .
    end .
    find first tt-gds-act no-error .
    if not available tt-gds-act then do :
        message "В акте нет строк. Сохранение невозможно" view-as alert-box .
        return no-apply.
    end.
    if can-find(tt-gds-act where tt-gds-act.qnty < 1)
    or can-find(tt-gds-act where trim(tt-gds-act.inform-B) = "")
    then do :
        message "Строки, в которых не указана справка Б, и строки, в которых количество меньше 1, не будут учтены при отправке в ЕГАИС!" skip "Продолжить?"
        view-as alert-box question buttons yes-no update glog .
        if not glog then return no-apply.
    end.
    run makeXML in this-procedure no-error.
    if error-status:error then return return-value .
    assign
        v-clob-db-num = ?
        v-int64-id = 0
        v-info = tt-act-header.num + chr(4) + string(tt-act-header.date_) + chr(4) + string(tt-act-header.is-sent) + chr(4) + tt-act-header.answer_
    .
    find first buf_clob-bind exclusive-lock where buf_clob-bind.field-name_  = 'egais-tts':U
      and buf_clob-bind.uniq-key-rec matches substitute ("*&1*", buf_trn-doc.doc-code) no-error .
    if available buf_clob-bind
    then do :
      message "Акт с таким номером уже существует!" view-as alert-box information
        title "Информация".
        release buf_clob-bind.
        return no-apply .
    end.
    run gbl/file2clb.p ( input 'ДОБАВЛЕНИЕ':U
              ,input ",yes"
              ,input ?
              ,input tt-act-header.num
              ,input 'egais-tts':U
              ,input v-info
              ,input-output v-part-num
              ,input 'egais-tts':U
              ,input-output v-clob-db-num
              ,input-output v-int64-id
              ,input search (v-file)
              ,input ''
              ) no-error .
    if error-status:error then message return-value view-as alert-box.
    bh-wb-egais:buffer-field ("tts"):buffer-value () = tt-act-header.num.
    bh-wb-egais:buffer-field ("tts-status_"):buffer-value () = "Новый".
    message substitute ("Создан акт № &1 перемещения в торговый зал", buf_trn-doc.doc-code) view-as alert-box title "Сообщение".
    release buf_clob-bind.
    empty temp-table tt-act-header.
    empty temp-table tt-gds-act.
  end.
  end case.
  run f-query.
end.
ON choose OF Btn_Del IN FRAME Dialog-Frame
do:
  run rejectWB.
end.
ON choose of menu-item m_reject IN menu popup-menu-reject
do:
  run rejectWB.
end.
ON choose of menu-item m_reqRepealWB IN menu popup-menu-reject
do:
  run ReqRepealWB.
end.
ON CHOOSE OF Btn_delclob IN FRAME Dialog-Frame
DO:
  if not bh-wb-egais:available
    then return no-apply.
define variable vss-include-info10 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_egais-adm':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output glog
    )  .
end.
  if not glog then return no-apply.
  if bh-wb-egais:buffer-field ('DbNum'):buffer-value () <>  v-cntxt-db-num
  then do:
    message "Нельзя удалять накладную полученную в другой БД " + bh-wb-egais:buffer-field ('DbNum'):buffer-value ().
    return no-apply.
  end.
  message "Вы уверены что хотите удалить накладную - " bh-wb-egais:buffer-field ('num'):buffer-value () "?" view-as alert-box buttons yes-no update isChoise as logical.
  if not isChoise then return no-apply.
  do trans:
    for each ub.clob-bind exclusive-lock where ub.clob-bind.uniq-key-rec = bh-wb-egais:buffer-field ('uniq-key-rec'):buffer-value () and ub.clob-bind.db-num = bh-wb-egais:buffer-field ('DbNum'):buffer-value ():
      delete ub.clob-bind.
    end.
  end.
  run reopen-browse.
END.
ON choose OF Btn_dnlw IN FRAME Dialog-Frame
do:
  if not search ( v-FS-RAR + '_ReceiptListOfQuery.xml' ) = ?
  then do:
    message "Выполнить полную загрузка (переодически рекомендуется выполнять полную загрузку)?" view-as alert-box question buttons yes-no update isChoise as logical.
    if isChoise
      then egaisWBAdv:FastDwnl = false.
      else egaisWBAdv:FastDwnl = true.
  end.
  egaisWBAdv:GetDocUTM().
  if egaisWBAdv:StatusErr
  then do:
    message "Ошибка: " egaisWBAdv:Msg view-as alert-box error.
  end.
  bh-analiz = egaisWBAdv:HndlAnaliz.
  if bh-analiz <> ?
  then do:
    bh-analiz:find-first ("where isMany") no-error.
    if bh-analiz:available
    then do:
      message "Имеются накладные с одинаковыми номерами. Посмотреть?" view-as alert-box question buttons yes-no update isChoise.
      if isChoise
        then run bge/egais-analiz.w (input parparentproc, input egaisWBAdv).
    end.
  end.
  def var egaisJournal        as class  Journal        no-undo.
  def var ExtFormF1ValueObj      as class  ExtFormF1Value no-undo.
  def var ExtFormF1ValueObjDB    as class  ExtFormF1Value no-undo.
  define variable ExtFormF1Obj           as class     ExtFormF1 no-undo .
  def var egaisFormF1        as class  FormF1         no-undo.
  def var bh-journal-egais    as handle no-undo.
  def var qh-journal-egais    as handle no-undo.
  def var bh-gds-egais-gotten as handle no-undo.
  def var msg                 as character no-undo.
  def var ii                  as integer   no-undo.
  def var jj                  as integer   no-undo.
  output stream str-FormF1 to "logWBDnlFormF1.txt" append.
  egaisJournal = new Journal ().
  ExtFormF1Obj = new ExtFormF1 (yes).
  bh-journal-egais = egaisJournal:GetHndlTable().
  create query qh-journal-egais.
  qh-journal-egais:set-buffers (bh-journal-egais) .
  qh-journal-egais:query-prepare ( substitute ("for each tt_journal-egais where jou-subject = '&1' and jou-status = 'Запрос отправлен' ", 'Справочник справок 1')).
  qh-journal-egais:query-open.
  run waitfram-show in this-procedure ("Ждите... Идет загрузка справок 1.") .
  journal_:
  do while qh-journal-egais:get-next ():
    egaisFormF1 = new FormF1 (v-cntxt-obj-type, v-cntxt-obj-code, v-fs-rar, entry (2, bh-journal-egais:buffer-field ("jou-param"):buffer-value, '|')).
    egaisFormF1:DbNum = v-db-num.
    egaisFormF1:User_Id = v-user-id.
    glog = egaisFormF1:StatusErr .
    if glog then do :
        msg = msg + chr(10) + egaisFormF1:Msg.
    end.
    else do:
      bh-gds-egais-gotten = egaisFormF1:GetHndlTable() .
      if egaisFormF1:Msg = 'Не удалось получить данные от UTM'
      then do:
        message egaisFormF1:Msg + ". Проверьте соединение с УТМ." view-as alert-box error.
        run waitfram-hide in this-procedure.
        output stream str-FormF1 close.
        if valid-object (ExtFormF1Obj)
          then delete object ExtFormF1Obj.
        if valid-handle (qh-journal-egais)
          then delete object qh-journal-egais.
        if valid-object (egaisJournal)
          then delete object egaisJournal.
        run reopen-browse.
        return.
      end.
      if bh-gds-egais-gotten = ? or not bh-gds-egais-gotten:find-first ()
      then do:
        put stream str-FormF1 unformatted chr(10) + egaisFormF1:Msg.
        delete object egaisFormF1.
        next journal_.
      end.
      ExtFormF1ValueObj = cast (bh-gds-egais-gotten:buffer-field("extFormF1ValueObj"):buffer-value, ibs.th.bge.egais.ExtFormF1Value).
      ExtFormF1Obj:OpenQueryExtFormF1 (bh-gds-egais-gotten:buffer-field("formF1code"):buffer-value).
      do ii = 1 to ExtFormF1Obj:NumBundles:
        ExtFormF1ValueObjDB = ExtFormF1Obj:GetExtFormF1Value(ii).
        assign
          ExtFormF1ValueObjDB:CliRegIdOrigCli = ExtFormF1ValueObj:CliRegIdOrigCli
          ExtFormF1ValueObjDB:CliEgaisTypeOrigCli = ExtFormF1ValueObj:CliEgaisTypeOrigCli
          ExtFormF1ValueObjDB:INNOrigCli = ExtFormF1ValueObj:INNOrigCli
          ExtFormF1ValueObjDB:KPPOrigCli = ExtFormF1ValueObj:KPPOrigCli
          ExtFormF1ValueObjDB:FullNameOrigCli = ExtFormF1ValueObj:FullNameOrigCli
          ExtFormF1ValueObjDB:CountryOrigCli = ExtFormF1ValueObj:CountryOrigCli
          ExtFormF1ValueObjDB:RegionOrigCli = ExtFormF1ValueObj:RegionOrigCli
          ExtFormF1ValueObjDB:DescrOrigCli = ExtFormF1ValueObj:DescrOrigCli
        .
        ExtFormF1Obj:SaveEGAISInfo(ExtFormF1ValueObjDB).
        put stream str-FormF1 unformatted chr(10) substitute ('Запись &1/&2 обновлена', ExtFormF1ValueObjDB:AlcCode, ExtFormF1ValueObj:FormF1Code ).
        jj = jj + 1.
      end.
    end.
    delete object egaisFormF1.
  end.
  run waitfram-hide in this-procedure.
  output stream str-FormF1 close.
  if valid-object (ExtFormF1Obj)
    then delete object ExtFormF1Obj.
  if valid-handle (qh-journal-egais)
    then delete object qh-journal-egais.
  if valid-object (egaisJournal)
    then delete object egaisJournal.
  run reopen-browse.
end.
ON choose OF Btn_OK IN FRAME Dialog-Frame
do:
  if valid-object (egais)
    then delete object egais.
  if valid-object (egaisWBAdv)
    then delete object egaisWBAdv.
  apply "go" to frame Dialog-Frame.
end.
ON choose OF Btn_Save IN FRAME Dialog-Frame
do:
  def var v-doc-code as character no-undo.
  if not bh-wb-egais:available
    then return no-apply.
  case cb-1:
  when 1 then do:
    if can-find (first ub.trn-doc where ub.trn-doc.doc-code = bh-wb-egais:buffer-field ("trn-doc-code"):buffer-value)
    then do:
      message substitute ( "Накладная с № &1 уже сформирована", bh-wb-egais:buffer-field ("trn-doc-code"):buffer-value)
      view-as alert-box.
      return no-apply.
    end.
    if bh-wb-egais:buffer-field ("trn-doc-code"):buffer-value = 'отказ'
    then do:
      message "Накладная в статусе отказ. Нельзя сохранить."
      view-as alert-box.
      return no-apply.
    end.
    bh-wb-gds-EG = ?.
    bh-wb-gds-EG-header = ?.
    bh-wb-gds-EG-header = egais:GetHndlTable(1, bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value).
    bh-wb-gds-EG = egais:GetHndlTable(2, bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value).
    v-uniq-key-rec = bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value.
    find first ub.clients no-lock
      where ub.clients.obj-type = bh-wb-gds-EG-header:buffer-field ("cli-type"):buffer-value
        and ub.clients.obj-code = integer (bh-wb-gds-EG-header:buffer-field ("cli-code"):buffer-value) no-error.
    if not available (ub.clients)
    then do:
      message "Не найден клиент TH для EGAIS контрагентa regID: " + bh-wb-gds-EG-header:buffer-field ('regId-Ship'):buffer-value view-as alert-box.
      return no-apply.
    end.
    find first ub.clients no-lock
      where ub.clients.obj-type = bh-wb-gds-EG-header:buffer-field ("obj-type"):buffer-value
        and ub.clients.obj-code = integer (bh-wb-gds-EG-header:buffer-field ("obj-code"):buffer-value) no-error.
    if not available (ub.clients)
    then do:
      message "Не найден объект TH для EGAIS получателя regID: " + bh-wb-gds-EG-header:buffer-field ('regId-Cons'):buffer-value view-as alert-box.
      return no-apply.
    end.
    bh-wb-gds-EG:find-first ("where tt-wb-gds-EG.gds-code = ? or tt-wb-gds-EG.gds-code = 0", no-lock) no-error.
    if bh-wb-gds-EG:available then do:
      message "Не найден товар TH для EGAIS товара AlcCode: " + bh-wb-gds-EG:buffer-field ('alc-code'):buffer-value view-as alert-box.
      return no-apply.
    end.
    egais:SaveWB(bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value).
    if egais:StatusErr
      then message egais:Msg view-as alert-box error.
      else message "Создание накладной завершено" view-as alert-box.
    run f-query.
    run proc-row-disp.
  end.
  when 2 then do:
define variable vss-include-info11 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_egais-accept':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
    if not glog then  return .
    bh-wb-gds-EG = ?.
    bh-wb-gds-EG-header = ?.
    bh-wb-gds-EG-header = egais:GetHndlTable(1, bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value).
    v-uniq-key-rec = bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value.
    if egais:StatusErr
    then do:
      message egais:Msg view-as alert-box error.
      return no-apply.
    end.
    egais:SendRequestUTM().
    if egais:StatusErr
      then message egais:Msg view-as alert-box error.
      else do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input bh-wb-egais:buffer-field('trn-doc-code'):buffer-value ,
                       input 'egais':U ,
                       input '0':U ) no-error .
        message "Отправлен акт на накладную" view-as alert-box.
      end.
  end.
  when 4 then do:
define variable vss-include-info12 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_egais-send-doc':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
    if not glog then  return .
    if bh-wb-egais:buffer-field ("status_"):buffer-value begins 'факт':U
    then do:
define variable vss-include-info13 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_egais-adm':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
      if not glog then  return .
    end.
    bh-wb-gds-EG = ?.
    bh-wb-gds-EG-header = ?.
    v-doc-code = bh-wb-egais:buffer-field ("trn-doc-code"):buffer-value.
    bh-wb-gds-EG-header = egais:GetHndlTable(10, bh-wb-egais:buffer-field ("trn-doc-code"):buffer-value).
    v-uniq-key-rec = bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value.
    if egais:StatusErr
    then do:
      message egais:Msg view-as alert-box error.
      return no-apply.
    end.
    egais:SendRequestUTM().
    if egais:StatusErr
      then message egais:Msg view-as alert-box error.
      else do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input v-doc-code ,
                       input 'egais':U ,
                       input '1':U ) no-error .
        message "Накладная отправлена" view-as alert-box.
      end.
  end.
  end case.
  run f-query.
end.
ON choose OF Btn_Sel IN FRAME Dialog-Frame
do:
  if not bh-wb-egais:available
    then return no-apply.
  case cb-1:
    when 1 then do:
      run bge/egais-wb.w (parparentproc, egais, bh-wb-egais:handle).
      v-uniq-key-rec = bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value.
    end.
    when 2 then do:
      run bge/egais-ticket.w (parparentproc, egais, bh-wb-egais:handle).
      v-uniq-key-rec = bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value.
    end.
    when 3 then do:
      run bge/egais-wb-act.w (parparentproc, egais, bh-wb-egais:handle).
    end.
    when 4 then do:
      run bge/egais-ticket.w (parparentproc, egais, bh-wb-egais:handle).
      v-trn-doc = bh-wb-egais:buffer-field ("trn-doc-code"):buffer-value.
    end.
  end case.
  run proc-row-disp.
  run f-query.
end.
ON CHOOSE OF btn_ticket IN FRAME Dialog-Frame
DO:
  if not bh-wb-egais:available
    then return no-apply.
  run bge/egais-ticket.w (parparentproc, egais, bh-wb-egais).
  v-uniq-key-rec = bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value.
  run proc-row-disp.
  run f-query.
END.
ON value-changed OF cb-1 IN FRAME Dialog-Frame
do:
  assign cb-1 .
  run proc-hide-disp.
  run reopen-browse.
end.
ON return OF f-cli-code IN FRAME Dialog-Frame
do:
  run f-query.
end.
ON leave OF f-cli-name IN FRAME Dialog-Frame
do:
  run f-query.
end.
ON return OF f-cli-name IN FRAME Dialog-Frame
do:
  run f-query.
end.
ON leave OF f-date IN FRAME Dialog-Frame
do:
  run f-query.
end.
ON return OF f-date IN FRAME Dialog-Frame
do:
  run f-query.
end.
ON leave OF f-date-2 IN FRAME Dialog-Frame
do:
  run f-query.
end.
ON return OF f-date-2 IN FRAME Dialog-Frame
do:
  run f-query.
end.
ON leave OF f-type IN FRAME Dialog-Frame
do:
  run f-query.
end.
ON return OF f-type IN FRAME Dialog-Frame
do:
  run f-query.
end.
ON value-changed OF f-type IN FRAME Dialog-Frame
do:
  run f-query.
end.
ON VALUE-CHANGED OF TOGGLE_NotConn IN FRAME Dialog-Frame
DO:
  run f-query.
END.
if valid-handle(active-window) and frame Dialog-Frame:PARENT eq ?
then frame Dialog-Frame:PARENT = active-window.
MAIN-BLOCK:
do on error   undo MAIN-BLOCK, leave MAIN-BLOCK
   on end-key undo MAIN-BLOCK, leave MAIN-BLOCK:
define variable vss-include-info14 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run getcurus in g#library2
  (output v-db-num
  ,output v-user-id
  ) no-error .
define variable vss-include-info15 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_egais-doc':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
  if not glog then  return .
define variable vss-include-info16 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_egais-adm':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output glog
    )  .
end.
  actnEGAISAdm = if glog then true else false.
define variable vss-include-info17 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_egais-chg-sts-doc':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output glog
    )  .
end.
  actnEGAISSts = if glog then true else false.
  empty temp-table thbjattr_thbj-attr .
  run adm/shattri.p (
       input "get":U
      ,input v-cntxt-obj-type
      ,input v-cntxt-obj-code
      ,input 'egais':U
      ,input 'egais-fsrar':U
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-value-type
      ,input-output TABLE thbjattr_thbj-attr
      ) no-error .
  assign
    v-fs-rar = v-value-character
  .
  run adm/shattri.p (
       input "get":U
      ,input '':U
      ,input 0
      ,input 'egais':U
      ,input 'egais-exsys':U
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-value-type
      ,input-output TABLE thbjattr_thbj-attr
      ) no-error .
  assign v-ext-sys = v-value-integer .
  egais = new EGAIS(v-db-num, v-user-id).
  egais:EGAISImpl = new WayBill (v-cntxt-obj-type, v-cntxt-obj-code, v-fs-rar, v-ext-sys).
  egaisWBAdv = cast (egais:EGAISImpl, ibs.th.bge.egais.WayBill).
  egaisWBAdv:ActnEGAISAdm = actnEGAISAdm.
  egaisWBAdv:ActnEGAISSts = actnEGAISSts.
  create query qh-wb-egais.
  create browse browse-hdl-wb-egais
    assign
      title     = 'Накладные ЕГАИС'
      frame     = frame Dialog-Frame:handle
      query     = qh-wb-egais
      x         = 10
      y         = 70
      width     = 119
      height    = 24
      visible   = true
      read-only = true
      sensitive = true
      separators = true
      column-resizable = true
      column-scrolling = true
      triggers:
        on mouse-move-dblclick persistent run msdblcl.
        on row-display persistent run proc-row-disp.
      end triggers
  .
  bh-wb-egais = egais:GetHndlTable(3, "").
  qh-wb-egais:set-buffers (bh-wb-egais).
  qh-wb-egais:query-prepare ("for each tt-wb-hndls by tt-wb-hndls.wb-date descending").
  qh-wb-egais:query-open.
  if not bh-wb-egais = ?
  then do:
    extent (bcol) = bh-wb-egais:num-fields.
    do ii = 1 to bh-wb-egais:num-fields:
      bcol[ii] = browse-hdl-wb-egais:add-like-column('tt-wb-hndls' + '.' + bh-wb-egais:buffer-field (ii):name, 0, 'FILL-IN').
      if entry (ii, egaisWBAdv:SettingsTTList, ';') <> ""
      then do:
        v-windth = integer (entry (1, entry (ii, egaisWBAdv:SettingsTTList, ';'))).
        v-isDisp = entry (2, entry (ii, egaisWBAdv:SettingsTTList, ';')).
        assign
          bcol[ii]:width = v-windth when v-windth > 0
          bcol[ii]:visible = false when v-isDisp = "no"
        .
      end.
    end.
  end.
  f-date = date (now) - 31.
  f-date-2 = ?.
  run f-query.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dialog-Frame :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dialog-Frame :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame Dialog-Frame :height
      v-frame-virtual-height = frame Dialog-Frame :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame Dialog-Frame :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame Dialog-Frame :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dialog-Frame :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dialog-Frame :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame Dialog-Frame :width
      v-frame-virtual-width = frame Dialog-Frame :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dialog-Frame :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame Dialog-Frame :width = frame Dialog-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame Dialog-Frame :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame Dialog-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dialog-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dialog-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dialog-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dialog-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dialog-Frame :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame Dialog-Frame
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame Dialog-Frame :height
      v-col-delta = v-new-col - frame Dialog-Frame :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame Dialog-Frame :width
      v-diasize-current-frame-height = frame Dialog-Frame :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      assign
        v-diasize-orig-frame-height = frame Dialog-Frame :height
        v-diasize-orig-frame-width  = frame Dialog-Frame :width
        v-diasize-browse-handle     = browse-hdl-wb-egais
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dialog-Frame :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
  run diasize_init in this-procedure .
  run enable_UI.
  run proc-hide-disp.
  wait-for go of frame Dialog-Frame.
end.
run disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY cb-1 f-date f-date-2 f-cli-name f-cli-code f-type TOGGLE_NotConn
      WITH FRAME Dialog-Frame.
  ENABLE Btn_OK Btn_Sel Btn_Save Btn_dnlw Btn_conn Btn_Del btn_ticket
         Btn_accept Btn_delclob cb-1 f-date f-date-2 f-cli-name f-cli-code
         f-type TOGGLE_NotConn
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE f-query :
  def var v-proposition  as char no-undo.
  def var v-proposition1 as char no-undo.
  def var v-rowid as rowid no-undo.
  assign input frame Dialog-Frame
    f-cli-name
    f-cli-code
    f-date
    f-date-2
    f-type
    TOGGLE_NotConn
  .
  v-proposition =
    (if f-date <> ? then "tt-wb-hndls.wb-date >= " + string (f-date) else "") +
    (if f-date-2 <> ? then " and tt-wb-hndls.wb-date <= " + string (f-date-2) else "") +
    (if f-cli-name <> "" then " and tt-wb-hndls.cliname matches '*" + string (f-cli-name) + "*'" else "") +
    (if f-type <> "" and f-type <> "Все" then " and tt-wb-hndls.wb-type matches '" + string (f-type) + "'" else "") +
    (if f-cli-code <> 0 and f-cli-code <> ? then " and tt-wb-hndls.cli matches '*" + string (f-cli-code) + "*'" else "") +
    (if logical (TOGGLE_NotConn) then " and not tt-wb-hndls.isWB" else  "")
    .
  v-proposition = left-trim (v-proposition, " and").
  v-proposition1 = v-proposition.
  v-proposition = "where " + v-proposition.
  case cb-1 :
    when 1 then
    do:
      qh-wb-egais:query-close.
      qh-wb-egais:query-prepare ( substitute ("for each tt-wb-hndls &1 by tt-wb-hndls.wb-date descending", v-proposition) ).
      qh-wb-egais:query-open.
      bh-wb-egais:find-first ( "where (" + v-proposition1 + ")" + "and tt-wb-hndls.uniq-key-rec = " + "'" + v-uniq-key-rec + "'") no-error.
    end.
    when 2 then
    do:
      qh-wb-egais:query-close.
      qh-wb-egais:query-prepare ( substitute ("for each tt-wb-hndls &1 by tt-wb-hndls.wb-date descending", v-proposition) ).
      qh-wb-egais:query-open.
      bh-wb-egais:find-first ( "where (" + v-proposition1 + ")" + "and tt-wb-hndls.uniq-key-rec = " + "'" + v-uniq-key-rec + "'") no-error.
    end.
    when 3 then
    do:
      qh-wb-egais:query-close.
      qh-wb-egais:query-prepare ("for each tt-wb-act-hndls").
      qh-wb-egais:query-open.
    end.
    when 4 then
    do:
      qh-wb-egais:query-close.
      qh-wb-egais:query-prepare ( substitute ("for each tt-wb-hndls &1 by tt-wb-hndls.wb-date descending", v-proposition) ).
      qh-wb-egais:query-open.
      bh-wb-egais:find-first ( "where (" + v-proposition1 + ")" + "and tt-wb-hndls.trn-doc-code = " + "'" + v-trn-doc + "'") no-error.
    end.
  end case.
  if bh-wb-egais:available
    then qh-wb-egais:reposition-to-rowid ( bh-wb-egais:rowid ).
  egaisWBAdv:ReleaseTable_().
end.
PROCEDURE msdblcl :
if cb-1 <> 1 and cb-1 <> 3 and cb-1 <> 2 and cb-1 <> 4
    then apply "choose" to Btn_Save in frame Dialog-Frame .
    else apply "choose" to Btn_Sel in frame Dialog-Frame .
end.
PROCEDURE proc-row-disp :
def var ii as int no-undo.
  if cb-1 = 1 or cb-1 = 2 then do:
    do ii = 1 to extent (bcol).
      if valid-handle (bcol[ii])
        then do:
        assign
          bcol[ii]:bgcolor = DARK_GRAY_COLOR when not bh-wb-egais:buffer-field ("isWb"):buffer-value and not cb-1 = 2
          bcol[ii]:bgcolor = WHITE_COLOR when bh-wb-egais:buffer-field ("isWb"):buffer-value and not cb-1 = 2
          bcol[ii]:bgcolor = RED_COLOR when bh-wb-egais:buffer-field ("EGAISSts"):buffer-value = 'Rejected' or bh-wb-egais:buffer-field ("EGAISSts"):buffer-value = 'Распроведена'
          bcol[ii]:bgcolor = CYAN_COLOR when bh-wb-egais:buffer-field ("trn-doc-code"):buffer-value = 'отказ'
        .
        if bh-wb-egais:buffer-field (ii) = bh-wb-egais:buffer-field ("tts-status_")
        then do:
          assign
            bcol[ii]:bgcolor = GREEN_COLOR when bh-wb-egais:buffer-field ("tts-status_"):buffer-value = "Принят"
            bcol[ii]:bgcolor = RED_COLOR when bh-wb-egais:buffer-field ("tts-status_"):buffer-value = "Отклонен"
          .
        end.
      end.
    end.
  end.
end.
PROCEDURE reopen-browse :
  if bh-wb-egais = ?
      then return .
  if valid-handle (browse-hdl-wb-egais) then do:
    v-width  = browse-hdl-wb-egais:width-chars.
    v-height = browse-hdl-wb-egais:height-chars.
  end.
  case cb-1 :
    when 1 then
    do:
      delete object browse-hdl-wb-egais.
      create browse browse-hdl-wb-egais
        assign
          title     = 'Накладные ЕГАИС'
          frame     = frame Dialog-Frame:handle
          query     = qh-wb-egais
          x         = 10
          y         = 70
          width     = if v-width <> 0 then v-width else 119
          height    = if v-height <> 0 then v-height else 24
          visible   = true
          read-only = true
          sensitive = true
          separators = true
          column-resizable = true
          column-scrolling = true
          triggers:
            on mouse-move-dblclick persistent run msdblcl.
            on row-display persistent run proc-row-disp.
          end triggers
      .
      bh-wb-egais = egais:GetHndlTable(3, "").
      qh-wb-egais:set-buffers (bh-wb-egais).
      qh-wb-egais:query-prepare ("for each tt-wb-hndls by tt-wb-hndls.wb-date descending").
      qh-wb-egais:query-open.
      if not bh-wb-egais = ?
      then do:
        do ii = 1 to bh-wb-egais:num-fields:
          bcol[ii] = browse-hdl-wb-egais:add-like-column('tt-wb-hndls' + '.' + bh-wb-egais:buffer-field (ii):name, 0, 'FILL-IN').
          if entry (ii, egaisWBAdv:SettingsTTList, ';') <> ""
          then do:
            v-windth = integer (entry (1, entry (ii, egaisWBAdv:SettingsTTList, ';'))).
            v-isDisp = entry (2, entry (ii, egaisWBAdv:SettingsTTList, ';')).
            assign
              bcol[ii]:width = v-windth when v-windth > 0
              bcol[ii]:visible = false when v-isDisp = "no"
            .
          end.
        end.
      end.
      Btn_Sel:label = "Изменить".
      enable Btn_Sel with frame Dialog-Frame.
      v-diasize-browse-handle = browse-hdl-wb-egais.
    end.
    when 2  then
    do:
      delete object browse-hdl-wb-egais.
      create browse browse-hdl-wb-egais
        assign
          title     = 'Накладные TH'
          frame     = frame Dialog-Frame:handle
          query     = qh-wb-egais
          x         = 10
          y         = 70
          width     = if v-width <> 0 then v-width else 119
          height    = if v-height <> 0 then v-height else 24
          visible   = true
          read-only = true
          sensitive = true
          separators = true
          column-resizable = true
          column-scrolling = true
          triggers:
            on row-display persistent run proc-row-disp.
            on mouse-move-dblclick persistent run msdblcl.
          end triggers
      .
      bh-wb-egais = egais:GetHndlTable(5, "").
      qh-wb-egais:set-buffers (bh-wb-egais).
      qh-wb-egais:query-prepare ("for each tt-wb-hndls by tt-wb-hndls.wb-date descending").
      qh-wb-egais:query-open.
      if not bh-wb-egais = ?
      then do:
        do ii = 1 to bh-wb-egais:num-fields:
          bcol[ii] = browse-hdl-wb-egais:add-like-column('tt-wb-hndls' + '.' + bh-wb-egais:buffer-field (ii):name, 0, 'FILL-IN').
          if entry (ii, egaisWBAdv:SettingsTTList, ';') <> ""
          then do:
            v-windth = integer (entry (1, entry (ii, egaisWBAdv:SettingsTTList, ';'))).
            v-isDisp = entry (2, entry (ii, egaisWBAdv:SettingsTTList, ';')).
            assign
              bcol[ii]:width = v-windth when v-windth > 0
              bcol[ii]:visible = false when v-isDisp = "no"
            .
          end.
        end.
      end.
      Btn_Sel:label = "Просмотр".
      v-diasize-browse-handle = browse-hdl-wb-egais.
    end.
    when 3  then
    do:
      delete object browse-hdl-wb-egais.
      create browse browse-hdl-wb-egais
        assign
          title     = 'Акты ЕГАИС'
          frame     = frame Dialog-Frame:handle
          query     = qh-wb-egais
          x         = 10
          y         = 70
          width     = if v-width <> 0 then v-width else 119
          height    = if v-height <> 0 then v-height else 24
          visible   = true
          read-only = true
          sensitive = true
          separators = true
          column-resizable = true
          column-scrolling = true
          triggers:
            on mouse-move-dblclick persistent run msdblcl.
          end triggers
      .
      bh-wb-egais = egais:GetHndlTable(7, "").
      qh-wb-egais:set-buffers (bh-wb-egais).
      qh-wb-egais:query-prepare ("for each tt-wb-act-hndls").
      qh-wb-egais:query-open.
      if not bh-wb-egais = ?
      then do:
        do ii = 1 to bh-wb-egais:num-fields:
          bcol[ii] = browse-hdl-wb-egais:add-like-column('tt-wb-act-hndls' + '.' + bh-wb-egais:buffer-field (ii):name, 0, 'FILL-IN').
          if entry (ii, egaisWBAdv:SettingsTTList, ';') <> ""
          then do:
            v-windth = integer (entry (1, entry (ii, egaisWBAdv:SettingsTTList, ';'))).
            v-isDisp = entry (2, entry (ii, egaisWBAdv:SettingsTTList, ';')).
            assign
              bcol[ii]:width = v-windth when v-windth > 0
              bcol[ii]:visible = false when v-isDisp = "no"
            .
          end.
        end.
      end.
      Btn_Sel:label = "Просмотр".
      enable Btn_Sel with frame Dialog-Frame.
      v-diasize-browse-handle = browse-hdl-wb-egais.
    end.
    when 4  then
    do:
      delete object browse-hdl-wb-egais.
      create browse browse-hdl-wb-egais
        assign
          title     = 'Расходные накладные'
          frame     = frame Dialog-Frame:handle
          query     = qh-wb-egais
          x         = 10
          y         = 70
          width     = if v-width <> 0 then v-width else 119
          height    = if v-height <> 0 then v-height else 24
          visible   = true
          read-only = true
          sensitive = true
          separators = true
          column-resizable = true
          column-scrolling = true
          triggers:
            on mouse-move-dblclick persistent run msdblcl.
          end triggers
      .
      bh-wb-egais = egais:GetHndlTable(4, "").
      qh-wb-egais:set-buffers (bh-wb-egais).
      qh-wb-egais:query-prepare ("for each tt-wb-hndls by tt-wb-hndls.wb-date descending").
      qh-wb-egais:query-open.
      if not bh-wb-egais = ?
      then do:
        do ii = 1 to bh-wb-egais:num-fields:
          bcol[ii] = browse-hdl-wb-egais:add-like-column('tt-wb-hndls' + '.' + bh-wb-egais:buffer-field (ii):name, 0, 'FILL-IN').
          if entry (ii, egaisWBAdv:SettingsTTList, ';') <> ""
          then do:
            v-windth = integer (entry (1, entry (ii, egaisWBAdv:SettingsTTList, ';'))).
            v-isDisp = entry (2, entry (ii, egaisWBAdv:SettingsTTList, ';')).
            assign
              bcol[ii]:width = v-windth when v-windth > 0
              bcol[ii]:visible = false when v-isDisp = "no"
            .
          end.
        end.
      end.
      Btn_Sel:label = "Просмотр".
      enable Btn_Sel with frame Dialog-Frame.
      v-diasize-browse-handle = browse-hdl-wb-egais.
    end.
  end.
  if f-date-2 <> ? or f-date <> ? or f-cli-name <> "" or f-type <> ""
    then run f-query.
end.
PROCEDURE rejectWB :
  def var v-doc-code as character no-undo.
  def var ticketRasObj as class WayBill no-undo.
  def var bh-TicketHndl as handle no-undo.
  def var qh-TicketHndl as handle no-undo.
define variable vss-include-info19 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_egais-reject':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
  if not glog then  return .
  if not bh-wb-egais:available
    then return no-apply.
  case cb-1:
  when 1
  then do:
    bh-wb-gds-EG-header = egais:GetHndlTable(1, bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value).
    if egais:StatusErr
    then do:
      message egais:Msg view-as alert-box error.
      return no-apply.
    end.
    if can-find (first ub.trn-doc where ub.trn-doc.doc-code = bh-wb-egais:buffer-field ("trn-doc-code"):buffer-value)
    then do:
      message substitute ( "Накладная с № &1 уже сформирована, все равно отправить отказ", bh-wb-egais:buffer-field ("trn-doc-code"):buffer-value)
      view-as alert-box question buttons yes-no update isChoise as logical.
      if not isChoise
        then return no-apply.
    end.
    else do:
      message "Отправить отказ?" view-as alert-box question buttons yes-no update isChoise.
      if not isChoise
        then return no-apply.
    end.
    egais:RejectWB(bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value).
    if egais:StatusErr
    then do:
      message egais:Msg view-as alert-box error.
      return no-apply.
    end.
    else run f-query.
  end.
  when 4
  then do:
    ticketRasObj = new WayBill (v-cntxt-obj-type, v-cntxt-obj-code, v-fs-rar, v-ext-sys).
    bh-wb-gds-EG = ?.
    bh-wb-gds-EG-header = ?.
    v-doc-code = bh-wb-egais:buffer-field ("trn-doc-code"):buffer-value.
    bh-TicketHndl = ticketRasObj:GetHndlTable(13, bh-wb-egais:buffer-field ("trn-doc-code"):buffer-value).
    create query qh-TicketHndl.
    qh-TicketHndl:set-buffers (bh-TicketHndl).
    qh-TicketHndl:query-close ().
    qh-TicketHndl:query-prepare ("for each tt-ticket where tt-ticket.regid <> '' and tt-ticket.doc = 'WayBill' by tt-ticket.regid descending").
    qh-TicketHndl:query-open ().
    if not qh-TicketHndl:is-open or not qh-TicketHndl:get-first ()
    then do:
      message "Не найдена накладная ЕГАИС, на которую можно послать отказ.".
      delete object ticketRasObj.
      return.
    end.
    bh-wb-gds-EG-header = egais:GetHndlTable(10, bh-wb-egais:buffer-field ("trn-doc-code"):buffer-value).
    v-uniq-key-rec = bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value.
    egaisWBAdv:SendWBActRejUTM(bh-TicketHndl:buffer-field ("regid"):buffer-value).
    message "Отправлен отказ на накладную ЕГАИС - " + bh-TicketHndl:buffer-field ("regid"):buffer-value view-as alert-box information title "Информация".
    delete object ticketRasObj.
  end.
  end case.
end procedure.
PROCEDURE ReqRepealWB :
  def var v-doc-code as character no-undo.
  def var ticketRasObj as class WayBill no-undo.
  def var bh-TicketHndl as handle no-undo.
  def var qh-TicketHndl as handle no-undo.
define variable vss-include-info20 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_egais-reject':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
  if not glog then  return .
  if not bh-wb-egais:available
    then return no-apply.
  case cb-1:
  when 1
  then do:
    bh-wb-gds-EG-header = egais:GetHndlTable(1, bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value).
    if egais:StatusErr
    then do:
      message egais:Msg view-as alert-box error.
      return no-apply.
    end.
    if can-find (first ub.trn-doc where ub.trn-doc.doc-code = bh-wb-egais:buffer-field ("trn-doc-code"):buffer-value)
    then do:
      message substitute ( "Накладная с № &1 уже сформирована, все равно отправить запрос на отмену проведения накладной.", bh-wb-egais:buffer-field ("trn-doc-code"):buffer-value)
      view-as alert-box question buttons yes-no update isChoise as logical.
      if not isChoise
        then return no-apply.
    end.
    else do:
      message "Отправить запрос на отмену проведения накладной?" view-as alert-box question buttons yes-no update isChoise.
      if not isChoise
        then return no-apply.
    end.
    egaisWBAdv:SendReqRepealWBUTM(bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value).
    if egaisWBAdv:StatusErr
    then do:
      message egaisWBAdv:Msg view-as alert-box error.
      return no-apply.
    end.
    else run f-query.
  end.
  end case.
end procedure.
procedure proc-hide-disp:
  if (cb-1:screen-value in frame Dialog-Frame = "2" or cb-1:screen-value  in frame Dialog-Frame = "1") and actnEGAISAdm
    then Btn_accept:hidden in frame Dialog-Frame = false.
    else Btn_accept:hidden in frame Dialog-Frame = true.
  case cb-1:
  when 1
  then do:
    enable Btn_Save with frame Dialog-Frame.
    Btn_Save:label = "Сохранить".
    Btn_Del:hidden = false.
    Btn_conn:label = "Связать".
    Btn_conn:tooltip = 'Связать накладную ЕГАИС с накладной TH'.
    Btn_conn:hidden = false.
    btn_ticket:hidden = false.
    Btn_delclob:hidden = false.
    Btn_Del:popup-menu in frame Dialog-Frame = menu popup-menu-reject:handle.
    Btn_Del:menu-mouse = 1.
  end.
  when 2 then do:
    enable Btn_Save with frame Dialog-Frame.
    Btn_Save:label = "Отправить".
    Btn_Del:hidden = true.
    Btn_conn:label = "Акт торг.".
    Btn_conn:tooltip = 'Передача продукции в торговый зал ЕГАИС'.
    Btn_conn:hidden = false.
    btn_ticket:hidden = true.
    Btn_delclob:hidden = true.
  end.
  when 3
  then do:
    disable Btn_Save with frame Dialog-Frame.
    Btn_Save:label = "Отправить".
    Btn_Del:hidden = true.
    Btn_conn:hidden = true.
    btn_ticket:hidden = true.
    Btn_delclob:hidden = true.
  end.
  when 4
  then do:
    enable Btn_Save with frame Dialog-Frame.
    Btn_Save:label = "Отправить".
    Btn_Del:hidden = false.
    Btn_conn:hidden = true.
    btn_ticket:hidden = true.
    Btn_delclob:hidden = true.
    Btn_Del:popup-menu in frame Dialog-Frame = ?.
    Btn_Del:menu-mouse = ?.
  end.
  end case.
end.
ON leave OF f-cli-code IN FRAME Dialog-Frame
do:
  run f-query.
end.
