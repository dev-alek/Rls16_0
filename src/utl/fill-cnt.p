block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: fill-cnt.p $
$Archive: utl/fill-cnt.p $

утилита  Привязка партий и складских документов к договору поставщика на удаленке

Автор: Кочетков Михаил Юрьевич
Дата создания: 03/27/06
Author: Michael Kochetkov
Creation date: 03/27/06

*/

/* ***************************  Definitions  ************************** */
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":u .
define variable vss-author      as character no-undo init "$Author: expertek $":u .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: fill-cnt.p $":u .
define variable vss-archive     as character no-undo init "$Archive: utl/fill-cnt.p $":u .
define variable vss-description as character no-undo init "утилита  Привязка партий и складских документов к договору поставщика на удаленке" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i  }
{ str/libtfarh.i }
{ gbl/clntattr.i }


define input  parameter p-contract-code as integer   no-undo .
define input  parameter doc-list as character no-undo .
define variable v-str  as CHAR  no-undo .
define variable par-type  as CHAR  no-undo .

 define variable ii as integer   no-undo .
 define variable doc-num as character no-undo .
 define variable Counter1 as integer   no-undo .

define buffer buf_trn-doc for trn-doc .
define buffer buf_parts for parts.
define buffer buf_parts-attr for parts-attr.

DEFINE temp-table temp-doc no-undo
  field   id             as character
  field fact-order like ub.trn-doc.fact-order
  INDEX pi  IS PRIMARY   id
  index fact-order fact-order
.

do:
define variable num-db as integer   no-undo .
{ gbl/curdbnum.i num-db }

  { rep/repfrm.i def } /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 5 } /* Показать окно информации о текущем процессе */

  on write of ub.trn-doc override do:  end.
  do transaction :
    do ii = 1 to num-entries(doc-list):
      assign doc-num = entry(ii, doc-list) .
      find first buf_trn-doc exclusive-lock where buf_trn-doc.doc-code = doc-num no-error .
      if available buf_trn-doc then do:
        run AddDoc (doc-num) .
        assign buf_trn-doc.contract-code = p-contract-code .
      end.
      for each buf_parts-attr exclusive-lock where buf_parts-attr.in-code = doc-num :
        find first ub.goods no-lock where ub.goods.gds-code = buf_parts-attr.gds-code .
        assign buf_parts-attr.contract-code = p-contract-code .
        for each clients no-lock where clients.db-num = num-db :
          for each parts exclusive-lock
            where parts.obj-type  =  clients.obj-type
              and parts.obj-code  =  clients.obj-code
              and parts.artic     =  ub.goods.artic
              and parts.prod-type =  ub.goods.prod-type
              and parts.prod-code =  ub.goods.prod-code
              and parts.in-code   =  buf_parts-attr.in-code
              and parts.part-code =  buf_parts-attr.part-code
            :
            run AddDoc (parts.out-code) .
            assign parts.contract-code = p-contract-code .
            assign Counter1 = Counter1 + 1.
            { rep/repfrm.i disp Counter1 }
          end.
        end.
      end.
      for each buf_parts exclusive-lock where buf_parts.out-code = doc-num :
        assign buf_parts.contract-code = p-contract-code .
        assign Counter1 = Counter1 + 1.
        { rep/repfrm.i disp Counter1 }
      end.
    end.
    run CalcArh in this-procedure .
  end.
  { rep/repfrm.i off } /* Показать окно информации о текущем процессе */
end.


procedure AddDoc :
  define input  parameter p-num as character no-undo .
  do on error undo, return error return-value :
    find first temp-doc where temp-doc.id = p-num no-error .
    if not available temp-doc then do:
      create temp-doc .
      assign temp-doc.id = p-num .
      find first trn-doc no-lock where trn-doc.doc-code = p-num no-error  .
      if available trn-doc then do:
        run clntattr-value in this-procedure  (input trn-doc.obj-type,input trn-doc.obj-code,
                input  {&attr-arh-trn-doc-contract}, output v-str, output par-type) no-error .
        if error-status:error or logical(v-str) = no then do:
          run clntattr-write in this-procedure ( input trn-doc.obj-type,input trn-doc.obj-code, input {&attr-arh-trn-doc-contract}, input "yes":u).
        end.
/*        { str/datrncnt.i p-num no-error }*/
/*        if error-status:error then return error.*/
      end.
    end.
  end.
end procedure. /* AddDoc */


PROCEDURE CalcArh :
  do on error undo, return error return-value :
    for each temp-doc use-index fact-order :
      find first trn-doc no-lock where trn-doc.doc-code = temp-doc.id no-error  .
      if available trn-doc then do:
/*        { str/latrncnt.i temp-doc.id no-error }*/
/*         if error-status :error then return error.*/
/*        { str/catrncnt.i temp-doc.id no-error }*/
/*         if error-status :error then return error.*/
        { str/st-fo.i temp-doc.id no-error }
        if error-status:error then return error.
      end.
    end.
  end.
end procedure. /* CalcArh */