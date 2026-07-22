block-level on error undo, throw.

using ibs.th.bge.egais.*.
/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .


{ gbl/color.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/thbjattr.i }
{ibs/th/bge/egais/wb-egais.i}
{ str/trdcalib.i }
{ ref/extclass.i }

define variable egais               as class     EGAIS no-undo.


def var ii as int no-undo.
def var glog as  log no-undo.
  

define buffer buf_gds           for ub.goods.
define buffer buf_gds-attr      for ub.goods-attr.
define buffer buf_trn-doc       for ub.trn-doc.
define buffer buf_doc-attr      for ub.doc-attr.
define buffer buf_parts         for ub.parts.
define buffer buf_doc-line      for ub.doc-line.
define buffer buf_doc-line-attr for ub.doc-line-attr.
define buffer buf_clients       for ub.clients.
define buffer buf_clients-attr  for ub.clients-attr.
define buffer buf_firm          for ub.firm.
define buffer buf_shop          for ub.shop.
define buffer buf_store         for ub.store.
define buffer buf_ext-classif   for ub.ext-classif.
define buffer X_ext-classif     for ub.ext-classif.
define buffer buf_country       for ub.country.

define variable v-db-num            as integer   no-undo .
define variable v-user-id           as character no-undo .

define variable bh-wb-gds-EG-header as handle    no-undo.
define variable bh-wb-gds-EG        as handle    no-undo.

define variable v-value-character   as character no-undo .
define variable v-value-decimal     as decimal   no-undo .
define variable v-value-integer     as integer   no-undo .
define variable v-value-logical     as logical   no-undo .
define variable v-value-type        as character no-undo .
define variable v-value-date        as date      no-undo .
define variable v-ext-sys           as integer   no-undo .

define variable v-glog     as logical   no-undo .

define variable v-fs-rar as character no-undo view-as text format "X(15)" label "Код ФС РАР (FSRAR ID)" .
  
  
  { gbl/getcurus.i
    v-db-num
    v-user-id
    no-error
  }
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_egais-doc':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    glog
  }
  
  if not glog then  return .

  empty temp-table thbjattr_thbj-attr .
  run adm/shattri.p (
       input "get":U
      ,input v-cntxt-obj-type
      ,input v-cntxt-obj-code
      ,input {&attr-egais-host}
      ,input {&attr-egais-host_egais-fsrar}
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-value-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
  assign 
    v-fs-rar = v-value-character 
  .
  
  run adm/shattri.p (
       input "get":U
      ,input '':U
      ,input 0
      ,input {&attr-egais-host}
      ,input {&attr-egais-host_egais-exsys}
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-value-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
  assign v-ext-sys = v-value-integer .  
  
  egais = new EGAIS(v-db-num, v-user-id).
  
  egais:EGAISImpl = new WayBill (v-cntxt-obj-type, v-cntxt-obj-code, v-fs-rar, v-ext-sys).
  
  /*message "Сохранить реквизиты поставщика и импортера в сравочик вн. классификатора по товарам из накладной? Данную информацию также можно получить и сохранить при синохрониации товаров. " view-as alert-box
    question buttons yes-no title "Вопрос" update v-glog.*/
  
  for each ub.clob-bind where ub.clob-bind.field-name_ = {&lob-egais-wb} no-lock:
    
    
    bh-wb-gds-EG-header = egais:GetHndlTable(1, ub.clob-bind.uniq-key-rec).
    bh-wb-gds-EG = egais:GetHndlTable(2, ub.clob-bind.uniq-key-rec).
    
    
    def var refA as char no-undo.
    def var refB as char no-undo.
    def var alc-code as char no-undo.
    def var alc-type-code as char no-undo.
    
    
    find first buf_trn-doc where buf_trn-doc.doc-code = entry (6, ub.clob-bind.descr, {&delim-par}) no-error. 
    
    if not available (buf_trn-doc) then next.
    
    for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code: 
      for each buf_parts no-lock where
        buf_parts.obj-type = buf_trn-doc.obj-type and 
        buf_parts.obj-code = buf_trn-doc.obj-code and 
        buf_parts.artic = buf_doc-line.artic and
        buf_parts.prod-type = buf_doc-line.prod-type and
        buf_parts.prod-code = buf_doc-line.prod-code and
        buf_parts.out-code = buf_trn-doc.doc-code and
        buf_parts.in-code = buf_trn-doc.doc-code and
        not buf_trn-doc.doc-code matches "*=*": 
        ii = ii + 1.
      find first buf_gds no-lock where buf_gds.artic = buf_parts.artic and buf_gds.prod-code = buf_parts.prod-code and buf_gds.prod-type = buf_parts.prod-type.

      bh-wb-gds-EG:find-first ('where tt-wb-gds-EG.gds-code = ' + string ( buf_gds.gds-code) + ' and tt-wb-gds-EG.qnty = ' + string (buf_parts.qnty), no-lock) no-error.
      
      if not bh-wb-gds-EG:available 
        then next.
      
      /*find first buf_ext-classif no-lock where buf_ext-classif.classif-subject = {&table_goods} 
                                         and buf_ext-classif.classif-name = {&extclass_goods_esys} 
                                         and buf_ext-classif.db-num = 0  
                                         and buf_ext-classif.key#_one = buf_gds.gds-code
                                         and buf_ext-classif.key#_two = v-ext-sys 
                                         no-error. 
      
      if v-glog /*num-entries (buf_ext-classif.CharKey_Two, chr (4)) < 3*/
      then do:
        for each X_ext-classif where X_ext-classif.classif-subject = {&table_goods} 
                                           and X_ext-classif.classif-name = {&extclass_goods_esys} 
                                           and X_ext-classif.db-num = 0  
                                           and X_ext-classif.key#_one = buf_gds.gds-code
                                           and X_ext-classif.key#_two = v-ext-sys 
                                           and rowid (X_ext-classif) <> rowid (buf_ext-classif).
          delete X_ext-classif.
        end.
        find current buf_ext-classif exclusive-lock.
        buf_ext-classif.CharKey_Two = bh-wb-gds-EG:buffer-field ("prod-list"):buffer-value + chr (4) + bh-wb-gds-EG:buffer-field ("importer-list"):buffer-value + chr (4) + bh-wb-gds-EG:buffer-field ("gds-name"):buffer-value.
        release buf_ext-classif.
      end.*/

      refA = bh-wb-gds-EG:buffer-field ("refA"):buffer-value.
      refB = bh-wb-gds-EG:buffer-field ("refB"):buffer-value.
      alc-code = bh-wb-gds-EG:buffer-field ("alc-code"):buffer-value.
      alc-type-code = bh-wb-gds-EG:buffer-field ("alc-type-code"):buffer-value.
      
      if (refA + ',' + refB + ',' + alc-code  + ',' + alc-type-code) = "" or (refA + ',' + refB + ',' + alc-code  + ',' + alc-type-code) = ? 
      or buf_parts.alc-ref-ab-path = "" or buf_parts.alc-ref-ab-path = ? 
        then .
        else next. 
      
      if true /*num-entries (buf_parts.alc-ref-ab-path) < 3*/ then
        run trg/partps.p ( input buf_gds.gds-code
                       , input buf_parts.in-code
                       , input ?
                       , input buf_parts.part-code
                       , input buf_parts.mark-db-num
                       , input buf_parts.mark-code
                       , input buf_parts.alc-bottling-date
                       , input refA + ',' + refB + ',' + alc-code  + ',' + alc-type-code
                       , input buf_parts.alc-quality-certif-path
                       , input buf_parts.alc-certif-path
                       , input buf_parts.alc-imp-type
                       , input buf_parts.alc-imp-code
                       ) no-error .

      end.
    end.
  end.

delete object egais.

message "Завершено" view-as alert-box.
  
  
  
  