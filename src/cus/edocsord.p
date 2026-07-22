block-level on error undo, throw.
/*

$Revision: e470dcf1e011, 295, rls $
$Author: SSlivenko $
$Date: Tue Dec 01 19:11:38 2015 +0300 $
$Workfile: edocsord.p $
$Archive: cus/edocsord.p $

Отсылка Заказа по EDOC-NN

Автор: Чернова Светлана Александровна
Дата создания: 10/02/08
Author: Svetlana Chernova
Creation date: 10/02/08

*/

define input  parameter parparentproc as widget-handle no-undo .
define input  parameter p-recid as recid no-undo . /* recid ord-doc */
define input  parameter p-table-name as character no-undo .
define input  parameter p-auto-go as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: e470dcf1e011, 295, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Tue Dec 01 19:11:38 2015 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: edocsord.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/edocsord.p $":U .
define variable vss-description as character no-undo init "Отсылка Заказа по EDOC-NN".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ gbl/key-rec.i  }
{ ref/extclass.i }
{ cus/str-edi.i }
{ rul/ruleset_.i }

define variable v-edoc-nn-doc as logical no-undo .
define variable v-edi-doc as logical no-undo .
define variable v-profile-id as integer no-undo .
define variable v-mess as character no-undo .
define buffer buf_ord-doc     for ub.ord-doc  .
define buffer buf_trn-doc     for ub.trn-doc  .
define buffer buf_ord-chain for ub.ord-chain .
define buffer buf_ord-doc-rcv for ub.ord-doc-rcv.
define buffer buf_clients for ub.clients.
define buffer buf_ext-classif for ub.ext-classif.


{ cus/edocsrun.i }

do
on error undo, return error return-value
:
define variable par-edoc-nn                   as   character                   no-undo .
define variable par-type                      as   character                   no-undo .
define variable par-edi                       as   character                   no-undo .
define variable is-edoc-nn                    as logical no-undo .
define variable is-edi                        as logical no-undo .
define variable v-dm-edi                      as integer   no-undo .

{ gbl/conf-rd.i "'edoc-nn'" 0 "''" 0 "''" "''" "''" no par-edoc-nn par-type no-error }

{ gbl/conf-rd.i "'is-edi'" 0 "''" 0 "''" "''" "''" no par-edi par-type no-error }
if par-edoc-nn <> "yes"
and par-edi <> "yes"
then return.
assign
is-edi = (par-edi = "yes")
is-edoc-nn = (par-edoc-nn = "yes")
.
  /* проверки */
  do transaction:
  if p-table-name = {&table_trn-doc} then do:
    find first buf_trn-doc exclusive-lock where
            recid (buf_trn-doc) = p-recid no-error .
    if not available buf_trn-doc then do:
      undo, return error substitute("Не найдена накладная с recid &1", p-recid).
    end.
    assign
    v-edoc-nn-doc = status-is-edoc-nn ( input is-edoc-nn
                                      , input buf_trn-doc.cli-type
                                      , input buf_trn-doc.cli-code
                                      , input buf_trn-doc.obj-type
                                      , input buf_trn-doc.obj-code
                                      ) .

    assign
    v-edi-doc = status-is-edi ( input is-edi
                                  , input buf_trn-doc.cli-type
                                  , input buf_trn-doc.cli-code
                                  , input buf_trn-doc.obj-type
                                  , input buf_trn-doc.obj-code
                                  , output v-dm-edi
                                  ) .
end.
else do:
    find first buf_ord-doc exclusive-lock where
        recid (buf_ord-doc) = p-recid no-error .
    if not available buf_ord-doc then do:
      undo, return error substitute("Не найден заказ с recid &1", p-recid).
end.
    assign
    v-edoc-nn-doc = status-is-edoc-nn ( input is-edoc-nn
                                      , input buf_ord-doc.cli-type
                                      , input buf_ord-doc.cli-code
                                      , input buf_ord-doc.obj-type
                                      , input buf_ord-doc.obj-code
                                      ) .
    assign
    v-edi-doc = status-is-edi ( input is-edi
                                  , input buf_ord-doc.cli-type
                                  , input buf_ord-doc.cli-code
                                  , input buf_ord-doc.obj-type
                                  , input buf_ord-doc.obj-code
                                  , output v-dm-edi
                                  ) .
end.
end.
if not (v-edoc-nn-doc or v-edi-doc) then return ''.

if p-table-name = {&table_ord-doc} then do:
  if v-edoc-nn-doc then do:
    v-profile-id = 37.
    v-mess = 'Отсылка Заказа по EDOC'.
  end.
  if v-edi-doc then do:
      if v-dm-edi = integer({&esys-dm-exite-edi}) then v-profile-id = 77.
      if v-dm-edi = integer({&esys-dm-contour-edi}) then v-profile-id = 91.
      v-mess = 'Отсылка Заказа по EDI'.
  end.
  if available  buf_ord-doc then do:
    /* Экспорт в oxml */
    run str/diallog.w ( input parparentproc
                , input this-procedure
                , input ('oxml-routing-order':U + {&delim-par} +
                        "1" + {&delim-par} +
                        "0" + {&delim-par} +
                        "1" + {&delim-par} +
                        "1" + {&delim-par} +
                        "yes")
                , input ''
                , input p-auto-go /*p-auto-go*/
                , input 'Прервать'
                , input v-mess) no-error .
  end.
  else do:
     message
     substitute("Не найден заказ &1 c recid &1", string(p-recid))
     view-as alert-box error .
  end.
end.
if p-table-name = {&table_trn-doc} then do:
  if v-edoc-nn-doc then do:
    v-profile-id = 37.
    v-mess = 'Отсылка Накладной по EDOC'.
  end.
  if v-edi-doc then do:
    if v-dm-edi = integer({&esys-dm-exite-edi}) then v-profile-id = 77.
    if v-dm-edi = integer({&esys-dm-contour-edi}) then v-profile-id = 91.
    v-mess = 'Отсылка Накладной по EDI'.
  end.
  if available  buf_trn-doc then do:
    find first buf_ord-chain   no-lock where
      buf_ord-chain.rel-doc-code = buf_trn-doc.doc-code and
      buf_ord-chain.rel-doc-type = "trn" and
      buf_ord-chain.doc-type = "rcv" no-error .
      if error-status :error then return .

    find first buf_ord-doc-rcv no-lock where
              buf_ord-doc-rcv.rcv-code = buf_ord-chain.doc-code no-error .
    if error-status :error then return .
    find first buf_ord-doc no-lock where
              buf_ord-doc.doc-code = buf_ord-doc-rcv.doc-code no-error .
    if error-status :error then return .

    /* Экспорт в oxml */
    run str/diallog.w ( input parparentproc
                , input this-procedure
                , input ('oxml-routing-rcv':U + {&delim-par} +
                        "1" + {&delim-par} +
                        "0" + {&delim-par} +
                        "1" + {&delim-par} +
                        "1" + {&delim-par} +
                        "yes")
                , input ''
                , input p-auto-go
                , input 'Прервать'
                , input v-mess) no-error .
  end.
  else do:
     message
     substitute("Не найдена ПН &1 c recid &1", string(p-recid))
     view-as alert-box error .
  end.
end.
 END.