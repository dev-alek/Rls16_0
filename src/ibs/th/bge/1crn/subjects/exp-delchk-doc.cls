/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Выгрузка удаленных чеков в 1с

Автор: Шкляр Елена
Дата создания: 03/11/17
Author: Shklyar Elena
Creation date: 03/11/17

*/

using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
using ibs.th.bge.1crn.export.send1cerpsub.
block-level on error undo, throw.

class ibs.th.bge.1crn.subjects.exp-delChk-doc inherits send1cerpsub:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Выгрузка удаленных чеков в 1с" get.
 
  { cmp/str-glbl.i class }
  { utl/gtin.i class}

  &scop tag-interface 'Checks-del':U
  &scop tag-check-del   'Check-del':U     
  &scop tag-checks   'Checks':U
  &scop tag-check   'Check':U

define override public property InitSecTag as character no-undo init {&tag-interface}
  get.

define override public property sendTableName  as character no-undo init "c-chk-doc"
  get.
   

method override public void CheckParam(  ):
      
  return.

end method.  

/*------------------------------------------------------------------------------
 Purpose: выгружает несколько чеков со всеми потрохами в контекст контейнера SAX-writer
 Notes:   обязательный метод
 Param:   insw = create sax-writer
------------------------------------------------------------------------------*/
method override public void CrContentToSW (insw as handle):
&global-define OFFICE_CODE_LIST "1,2,3,4,5,6,7,8,9,10,0,11,11,12,13,14"
&global-define OFFICE_NAME_LIST "Сум-ош,Карт-ош,Сер-ош,При-ош,Смн-ош,Опл-ош,Скидка-ош,Тов-ош,Кол-ош,Прт-ош,0,?, ,Перс-ош,Т,У"
  define variable ii as integer no-undo .
  define variable jj as integer no-undo .
  define variable office as character no-undo .
  define variable shift-date-deletion as character no-undo .
  
  find last c-chk-doc where c-chk-doc.doc-code eq string(oldbh:buffer-field( "doc-code":U  ):buffer-value) and c-chk-doc.is-del
    no-lock no-error.
  if available c-chk-doc
    then 
  do:
    sendOldRowid  = rowid(c-chk-doc).

    do ii = 1 to num-entries(c-chk-doc.office):
    if ENTRY(ii,c-chk-doc.office) <> "" then office = office + "," + ENTRY(ii,c-chk-doc.office)  .
    end.
    office = trim(office,",") .
    insw:start-element ({&tag-check-del}) .
    insw:start-element ({&tag-checks}) .
    insw:start-element ({&tag-check}) .
    insw:write-data-element (  "cb-num":U,     string(c-chk-doc.pay-desk)   ).
    insw:write-data-element (  "shift-num":U,        if c-chk-doc.shift-num eq ? then "" else string(c-chk-doc.shift-num)  ).
    insw:write-data-element (  "shift-date":U,        if c-chk-doc.src-shift-date eq ? then "" else iso-date(c-chk-doc.src-shift-date)   ).
    insw:write-data-element (  "chk-type":U,       string(c-chk-doc.chk-type)).
    insw:start-element ("condition-check":U) .
    do ii = 1 to num-entries(office):
    insw:write-data-element (  "condition-type":U,   ENTRY(LOOKUP(entry(ii,office), {&OFFICE_NAME_LIST}),{&OFFICE_CODE_LIST})  ).
    end.
    insw:end-element ("condition-check":U) .
    insw:write-data-element (  "chk-num":U,       string(c-chk-doc.chk-num)   ).
    insw:write-data-element (  "chk-id":U,       string(c-chk-doc.doc-code)   ).
    insw:write-data-element (  "dry-chk-th":U,   if c-chk-doc.is-add then "1" else "0"  ).
    insw:write-data-element (  "chk-date":U,        iso-date(c-chk-doc.chk-date)   ).
    insw:write-data-element (  "chk-time":U,       string(c-chk-doc.chk-time,"HH:MM:SS")).
    insw:write-data-element (  "date-deletion":U,     iso-date(c-chk-doc.corr-date)  ).
    insw:write-data-element (  "time-deletion":U,      string(c-chk-doc.corr-time,"HH:MM:SS")   ).
    for each ub.shift-obj no-lock where ub.shift-obj.obj-code = c-chk-doc.obj-code and ub.shift-obj.obj-type = c-chk-doc.obj-type and 
      (ub.shift-obj.open-date < c-chk-doc.corr-date or ub.shift-obj.open-date = c-chk-doc.corr-date) and
      ub.shift-obj.status_ <> {&sht-expected} and
      if ub.shift-obj.close-date <> ? then (ub.shift-obj.close-date > c-chk-doc.corr-date or ub.shift-obj.close-date = c-chk-doc.corr-date or  ub.shift-obj.status_ = {&sht-current}) else ub.shift-obj.close-date = ?:
      if ub.shift-obj.status_ <> {&sht-current} then do:
      if ub.shift-obj.open-date = c-chk-doc.corr-date and ub.shift-obj.open-time > c-chk-doc.corr-time then next .
      if ub.shift-obj.close-date = c-chk-doc.corr-date and ub.shift-obj.close-time < c-chk-doc.corr-time then next .
      end.
       insw:write-data-element (  "shift-date-deletion":U, string(ub.shift-obj.shift-date,"99.99.9999") + " " + string(ub.shift-obj.shift-name) ).   
      .
      jj = 1 .
      leave .
    end.
    if jj = 0 then
      insw:write-data-element (  "shift-date-deletion":U, "0" ).



    insw:write-data-element (  "user-code":U,        usrfulnf(c-chk-doc.corr-user-name)   ).

    find first c-chk-gds no-lock where c-chk-gds.doc-code = c-chk-doc.doc-code and c-chk-gds.chip-num = 1 no-error . 
    if available (c-chk-gds) then do: 
    insw:start-element ("chk-gds") .
    for each c-chk-gds no-lock where c-chk-gds.doc-code = c-chk-doc.doc-code and c-chk-gds.chip-num = 1:
      find first ub.bar-code no-lock where ub.bar-code.b-code = c-chk-gds.b-code no-error .
      if available (ub.bar-code) then 
      do:
        insw:start-element ("chk-gd") .
        insw:write-data-element (  "gd-code":U,    string(ub.bar-code.gds-code)   ).
        insw:write-data-element (  "qnty":U,       string(c-chk-gds.doc-qnty)   ).
        insw:write-data-element (  "price":U,       string(c-chk-gds.price-base)   ).
        insw:write-data-element (  "sum":U,       string(c-chk-gds.doc-qnty * c-chk-gds.price-base)   ).
        insw:end-element ("chk-gd") .
      end.
    end.

    insw:end-element ("chk-gds") .
     end.

    insw:write-data-element (  "netto":U,       string (c-chk-doc.tot-doc)   ).

    find first c-chk-pay no-lock where c-chk-pay.doc-code = c-chk-doc.doc-code and c-chk-pay.chip-num = 1  no-error .
    if available (c-chk-pay) then 
      do:
      insw:start-element ("chk-pays") .
        for each c-chk-pay no-lock where c-chk-pay.doc-code = c-chk-doc.doc-code and c-chk-pay.chip-num = 1:
          insw:start-element ("chk-pay") .
          insw:write-data-element (  "pay-code":U,       string(c-chk-pay.pay-code)   ).
            find first chk-pay-attr no-lock  where chk-pay-attr.doc-code = c-chk-pay.doc-code and chk-pay-attr.attr-code = "QRPay" no-error.
            if available chk-pay-attr then insw:write-data-element ("qrpay", chk-pay-attr.attr-value ).

          insw:end-element ("chk-pay") .

        end.
      insw:end-element ("chk-pays") .
    end.

    insw:end-element ({&tag-check}) .       
    insw:end-element ({&tag-checks}) .
    insw:end-element ({&tag-check-del}) .


  end.
end method . /* end_of CrContentToSW */

method character usrfulnf ( input p-user-id as character):
define variable v-user-name as character no-undo .
v-user-name = usrfulnm(p-user-id) no-error .
if error-status:error
or v-user-name = ""
then do:
  return p-user-id.
end.
else do:
  return v-user-name.
end.

end method.

method character usrfulnm (p-user-id   as character):
  define variable p-user-name as character no-undo .
  
  define buffer buf_user-account        for ub.user-account .
  define buffer buf_parent_user-account for ub.user-account .

  do
  on error undo, return error return-value
  :
    find first buf_user-account no-lock
      where buf_user-account.user-id = p-user-id
      no-error .
    if not available buf_user-account
    then do:
      assign
        p-user-name = p-user-id
      .
    end.
    else do:
      if buf_user-account.check-parent = true
      then do:
        find first buf_parent_user-account no-lock
          where buf_parent_user-account.user-id = buf_user-account.parent-user-id
          no-error .
        if not available buf_parent_user-account
        then do:
          assign
            p-user-name = p-user-id
          .
        end.
        else do:
          assign
            p-user-name = buf_user-account.nik
          .
        end.
      end.
      else do:
        assign
          p-user-name = buf_user-account.nik
        .
      end.
    end.
    return p-user-name .
  end.

end method. /* usrfulnm */
end class.
