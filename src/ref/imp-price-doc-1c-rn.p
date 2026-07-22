block-level on error undo, throw.

/*------------------------------------------------------------------------
    File        : imp-price-doc-1c-RN.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : 
    Created     : Fri Nov 03 16:02:08 AST 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.

define input parameter p-Price-Doc as class price-doc-imp.

define variable vt-obj-code as integer   no-undo .
define variable v-host-code as integer   no-undo .
define variable v-grp-full-name as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: f669785c8aa5, 1477, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Wed Jul 25 17:54:04 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: imp-price-doc-1c-RN.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/imp-price-doc-1c-RN.p $":U .
define variable vss-description as character no-undo init "Загрузка переоценки из ERP 1C RN".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ rul/garbcoll.i }
{ gbl/cur-time.i }
{ nws/lib-nws.i }
&glob cmd-proc-handle p-cmd-proc-handle
&glob cmd-code p-cmd-code

{ nws/temp-cmd.i "SHARED" }
{ rul/cl-hist.i "shared" }
{ rul/library-cls.i "non-class-part" }
{ gbl/key-rec.i }
{ rul/tempcxml.i "shared" }
{ gbl/gate-clb.i }
{ utl/tt301.i    }
{ gbl/getcntxa.i }


define variable num-rec-ok2 as integer no-undo .
define variable ii as integer no-undo .
define variable v-Gds-Sale as class price-doc_gds-sale.
define variable v-Price-list as class subjects.
define variable v-doc-date as character no-undo .

define buffer buf_price-doc for ub.price-doc .

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
  
  empty temp-table temp-price-doc .
  empty temp-table temp-price-list .
  
  v-Price-list = p-Price-Doc:gds-sale .
  
  find first ub.clients no-lock where ub.clients.db-num = g#db-num
                                  and ub.clients.obj-type = {&shop}
                                  and ub.clients.stts = 0 .
  v-doc-date = p-Price-Doc:doc-date .
  v-doc-date = entry(1, v-doc-date, "T") no-error .
  create temp-price-doc.
  assign
    temp-price-doc.doc-date = date(integer(entry(2, v-doc-date, '-')), integer(entry(3, v-doc-date, '-')), integer(entry(1, v-doc-date, '-'))) 
    temp-price-doc.doc-num  = 1
    temp-price-doc.line-num = 1
    temp-price-doc.obj-code = ub.clients.obj-code
    temp-price-doc.obj-type = {&shop}
    temp-price-doc.doc-num-ES = p-Price-Doc:doc-num-ES
    temp-price-doc.doc-id   = p-Price-Doc:doc-id
    temp-price-doc.cmnt     = p-Price-Doc:cmnt
  .
  
  if valid-object (v-Price-list)
  then
  do ii = 1 to v-Price-list:Get(ii):
    v-Gds-Sale = cast (v-Price-list:SubjectObjCurr, price-doc_gds-sale).  
    create temp-price-list.
    assign
      temp-price-list.doc-num = 1
      temp-price-list.line-num = 1
      temp-price-list.gds-code = integer(v-Gds-Sale:gds-code)
      temp-price-list.price-sale = decimal(v-Gds-Sale:price-sale)
    .
  end.    
  
  if integer(p-Price-Doc:doc-status) = 1
  then do :
    if p-Price-Doc:doc-num <> ? and p-Price-Doc:doc-num <> ""
    then do :  
      find first buf_price-doc exclusive-lock where buf_price-doc.doc-num = p-Price-Doc:doc-num no-error.
    end.
    if not available buf_price-doc
    then do :
      find first buf_price-doc exclusive-lock where buf_price-doc.uid-es = p-Price-Doc:doc-id no-error.  
    end.
    if not available buf_price-doc
    then do :
      undo, return error "Не найдена переоценка для отмены" .  
    end.
    if buf_price-doc.status_ = {&act-overvalue} 
    then do :
        return "Переоценка в статусе АКТ и не может быть отменена." .
    end.    
    if buf_price-doc.status_ = {&order} 
    then do :
        delete buf_price-doc no-error.
        if error-status:error
        then do :
          undo, return error return-value.  
        end.  
    end.  
  end.
  else do :    
    if p-Price-Doc:doc-num <> ? and p-Price-Doc:doc-num <> ""
    then do :  
      find first buf_price-doc exclusive-lock where buf_price-doc.doc-num = p-Price-Doc:doc-num no-error.
    end.
    if not available buf_price-doc
    then do :
      find first buf_price-doc exclusive-lock where buf_price-doc.uid-es = p-Price-Doc:doc-id no-error.  
    end.
    if not available buf_price-doc
    then do :
      run utl/ora-i301.p (
        input this-procedure ,
        input this-procedure ,
        input table temp-price-doc ,
        input table temp-price-list ,
        output num-rec-ok2
        ) no-error .
      if error-status:error
      then do :
        undo, return error return-value.
      end. 
    end. 
  end.    
      
procedure pcall-log-file :
define input  parameter p-message as character no-undo .
  do
  on error undo, return error return-value
  :
    

  end.

end procedure. /* pcall-log-file */
