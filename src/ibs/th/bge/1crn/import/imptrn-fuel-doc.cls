/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Класс ипорта данных country из 1С

Автор: Александр Морозов
Дата создания: 26/09/17
Author: Morozov Alexandr
Creation date: 26/09/17

*/

using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
using ibs.th.bge.1crn.import.*.
using ibs.th.skt.Adapters.AdapterOra-i516-1c from propath.

block-level on error undo, throw.

class ibs.th.bge.1crn.import.imptrn-fuel-doc implements ibs.th.bge.1crn.import.iimpsubject: 
  
  { cmp/str-glbl.i class }
  
  {ibs/th/skt/ControlledClients/TSDTT-1c.i}
  
  define buffer buf_clients for ub.clients.
  
  define property Msg as character no-undo
    get. 
    set.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/

  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
		
    define variable v-doc-rec as recid     no-undo.
    define variable result    as logical   no-undo.
    define variable glog      as logical   no-undo.
    define variable mode      as character no-undo.
    define variable ii        as integer   no-undo.
    define variable objTrnDoc  as class     trn-fuel-doc-in no-undo.
    define variable objGd      as class     trn-gd-fuel     no-undo.
    define variable adapObj    as class     AdapterOra-i516-1c no-undo.
    define variable objGds     as class     subjects        no-undo.
    
    objTrnDoc = cast (subjectObj, trn-fuel-doc-in).
    
    adapObj = new AdapterOra-i516-1c ().
    
    find first ub.sys-ctrl.
    
    empty temp-table TempTrnDoc.
    empty temp-table TempDocLine.
    empty temp-table TempDocMark.
    
    find first buf_clients where buf_clients.db-num = ub.sys-ctrl.db-num.
    create TempTrnDoc.
    assign
      TempTrnDoc.obj-type = buf_clients.obj-type
      TempTrnDoc.obj-code = buf_clients.obj-code
      TempTrnDoc.cli-code = integer (objTrnDoc:fuel-st-code)
      TempTrnDoc.cli-type = "маг"
      TempTrnDoc.doc-date = objTrnDoc:doc-date
      TempTrnDoc.ext-doc-code = replace (objTrnDoc:doc-code, "-", "=").
      TempTrnDoc.doc-id = objTrnDoc:doc-id
    .

    case trim (objTrnDoc:doc-type, '0'):
      when '4' then do:
        TempTrnDoc.ext-doc-type = {&TDEDT_Pri_Vnesh} .
      end.
      otherwise do:
        Msg = "Не поддерживаемый тип документа на загрузку: " + objTrnDoc:doc-type.
        return false.
      end.
    end case.
    
    objGds = objTrnDoc:GDS.
    do ii = 1 to objGds:Get(ii):
      objGd = cast (objGds:SubjectObjCurr, trn-gd-fuel).
      create TempDocLine.
      assign
        TempDocLine.gds-code = objGd:gd-code
        TempDocLine.fact-qnty = objGd:cap-fact
        TempDocLine.doc-qnty = objGd:cap-fact
        TempDocLine.price-rubl = round (objGd:sum / objGd:cap-fact, 2)
        TempDocLine.fact-dnsty = objGd:dnsty-fact
        TempDocLine.cli-qnty = objGd:wght-fact
      .
    end.
    
    adapObj:SetTempTable(table TempTrnDoc, table TempDocLine, table TempDocPart, table TempDocMark, "").
    adapObj:WriteDB(output glog).
    
    
    if error-status:error then 
    do:
      Msg = return-value.
      result = false.
    end.
    else do:
      result = true.
    end.
		
    return result.

  end method.
	

end class.
