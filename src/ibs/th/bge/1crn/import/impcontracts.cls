/*

$Revision: 03fdc2c69603, 3168, rls $
$Author: SSlivenko $
$Date: 2022/12/27 12:54:23 $
$Workfile: impcontracts.cls $
$Archive: ibs/th/bge/1crn/import/impcontracts.cls $

Класс ипорта данных impcontracts из 1С

Автор: Александр Морозов
Дата создания: 26/09/17
Author: Morozov Alexandr
Creation date: 26/09/17

*/

using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
USING ibs.th.gbl.*.
USING ibs.th.trg.newbcod from propath.
USING ibs.th.gbl.curdburt from propath.
block-level on error undo, throw.

class ibs.th.bge.1crn.import.impcontracts implements ibs.th.bge.1crn.import.iimpsubject: 
  
  { cmp/str-glbl.i class }
  { cmp/str-glbl.i }
  
  define variable newbcod1 as class newbcod  no-undo .   
  define variable curdburt as class curdburt no-undo .   
   
  define property Msg as character no-undo
    get. 
    set.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/

  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
	
    define variable ri     as recid   no-undo .
    define variable f-code as integer no-undo .	
    define buffer b_contract for ub.contract .
    define variable p-sys-date     as date      no-undo .
    define variable p-sys-time     as character no-undo .
    define variable p-sys-time-int as integer   no-undo .
    define variable v-cli-code     as integer   no-undo .
    define variable v-cli-name     as character no-undo .
    define variable v-status       as character no-undo .
    define variable v-curr-code    as integer   no-undo .
    define variable objContracts   as class     contracts no-undo.
    define variable v-user-db-num  as integer   no-undo .
    define variable v-user-name    as character no-undo .
    
    objContracts = cast (subjectObj, contracts).
        
    if objContracts:date-srt <> ? and objContracts:date-end <> ? and objContracts:date_ <> ? and objContracts:date-srt <> "0001-01-01" then 
    do:
      if objContracts:date_ > objContracts:date-srt then 
      do:
        Msg = "Договор с кодом " + objContracts:code_ + " . Дата контракта позже даты начала действия!" .
        return error.
      end.
      else 
      do:  
        if objContracts:date-srt > objContracts:date-end and objContracts:date-end <> "0001-01-01" then 
        do:
          Msg ="Договор с кодом " + objContracts:code_ +  " . Дата начала действия позже даты окончания действия!" .
          return error.
        end.
      end.
    end.
    if objContracts:contr-code = "" or objContracts:contr-code = ? then 
    do:
      Msg = "Договор с кодом " + objContracts:code_ + " . Не задан контрагент".
      return error.
    end.
    if objContracts:org-code = "" or objContracts:org-code = ? then 
    do:
      Msg = "Договор с кодом " + objContracts:code_ + " . Не задана организация" .
      return error Msg.
    end.  
    find first ub.clients no-lock where ub.clients.obj-code = integer(objContracts:org-code)
      and ub.clients.obj-type = {&cmp} no-error .
    if not AVAILABLE ub.clients then 
    do:
/*      assign                            */
/*        v-cli-code = ub.clients.obj-code*/
/*        v-cli-name = ub.clients.obj-name*/
/*        .                               */
/*    end.                                */
/*    else                                */
/*    do:                                 */
      Msg = "Договор с кодом " + objContracts:code_ + " . Нет такой организации - " + objContracts:org-code .
      return error Msg.
    end.  
    find first ub.clients no-lock where ub.clients.obj-code = integer(objContracts:contr-code)
      and ub.clients.obj-type = {&cmp} no-error .
    if AVAILABLE ub.clients then 
    do:
      assign
        v-cli-code = ub.clients.obj-code
        v-cli-name = ub.clients.obj-name
        .
    end.
    else 
    do:
      /*Создаем нового клиента?*/
      Msg = "Договор с кодом " + objContracts:code_ + " . Нет такого контрагента - " + objContracts:contr-code .
      return error Msg.
    end.  
      
        
    find first ub.contract EXCLUSIVE-LOCK
      where ub.contract.contract-code = integer(objContracts:code_)
      and ub.contract.host-code         = integer(objContracts:org-code)
      and ub.contract.contract-type     = {&contr-buy-sale} /*заглушка*/ 
      no-error .
    if AVAILABLE ub.contract then 
    do:
      assign

        /*          v-status    = if objContracts:del-l = 0 then {&current-contr} else {&close-contr}*/
        v-cli-code  = ub.contract.cli-code
        v-cli-name  = ub.contract.cli-name
        v-curr-code = ub.contract.curr-code
        
        .
    end.
    else 
    do:
      /*        newbcod1 = new newbcod () .                           */
      /*        newbcod1:GenBCod(input {&gbl-ct-code},                */
      /*          output f-code) no-error.                            */
      /*        if error-status:error then                            */
      /*        do:                                                   */
      /*          Msg = "Ошибка при генерации внутреннего № договора".*/
      /*          return error.                                       */
      /*        end.                                                  */
      /*combo-usl-opl = {&contr-pay-nodef} .*/
      /*combo-type-contr = "Купли-продажи". */
      create ub.contract .
      assign
        ub.contract.host-code         = integer(objContracts:org-code)
        ub.contract.contract-type     = {&contr-buy-sale} /*заглушка*/ 
        ub.contract.db-num            = gbl-var:g#db-num
        ub.contract.user-db-num       = gbl-var:g#db-num
        ub.contract.usl-opl           = {&contr-pay-nodef}
        ub.contract.contract-code     = integer(objContracts:code_)
        .
      find first ub.sysconf no-lock where ub.sysconf.host-code = integer(objContracts:org-code) no-error.
      if AVAILABLE ub.sysconf then 
      do:
        v-curr-code = ub.sysconf.base-code .
      end.
      else 
      do:
        Msg = "Договор с кодом " + objContracts:code_ + " . Не найдены системные настройки для фирмы с кодом: " + objContracts:org-code .
        find first ub.currency no-lock no-error.
        if AVAILABLE ub.currency then 
        do:
          v-curr-code = ub.currency.curr-code .
        end.  
        else 
        do:
          Msg = "Договор с кодом " + objContracts:code_ + " . Не найден справочник видов оплат".
          return error .
        end.  
      end.     
    end.
    assign
      ub.contract.contract-prn-code = objContracts:number
      ub.contract.doc-type          = {&income}
      ub.contract.status_           = if objContracts:status_ = 1 then {&current-contr} else {&close-contr}
      /*        ub.contract.status_           = if objContracts:del-l = 0 then {&current-contr} else {&close-contr}*/
      ub.contract.curr-code         = v-curr-code /*какую брать валюту*/
      ub.contract.own-name          = {&company} /*Откуда брать?*/
      ub.contract.cli-type          = {&cmp}
      ub.contract.cli-code          = v-cli-code 
      ub.contract.cli-name          = v-cli-name
      
      ub.contract.contract-date     = if objContracts:date_ = "0001-01-01" then today else date(date-1C(objContracts:date_))
      ub.contract.contract-date-beg = if objContracts:date-srt = "0001-01-01" then ? else date(date-1C(objContracts:date-srt))
      ub.contract.contract-date-end = if objContracts:date-end = "0001-01-01" then ? else date(date-1C(objContracts:date-end))
      
      ub.contract.spec-check = if objContracts:return-code = ? then 0 else objContracts:return-code
    .
    
    find first ub.contract-attr exclusive-lock where ub.contract-attr.host-code = ub.contract.host-code and 
      ub.contract-attr.contract-code = ub.contract.contract-code and
      ub.contract-attr.attr-code = "contract-edi"  no-error .
    if not available (ub.contract-attr) then 
    do:
      create ub.contract-attr .
      assign
        ub.contract-attr.host-code     = ub.contract.host-code
        ub.contract-attr.contract-code = ub.contract.contract-code
        ub.contract-attr.attr-code     = "contract-edi"
        .
    end.
    ub.contract-attr.attr-value = string(if objContracts:edi_ = 1 then "yes" else "no") . 
     
    find first ub.contract-attr exclusive-lock where ub.contract-attr.host-code = ub.contract.host-code and 
      ub.contract-attr.contract-code = ub.contract.contract-code and
      ub.contract-attr.attr-code = "contract-diadoc"  no-error .
    if not available (ub.contract-attr) then 
    do:
      create ub.contract-attr .
      assign
        ub.contract-attr.host-code     = ub.contract.host-code
        ub.contract-attr.contract-code = ub.contract.contract-code
        ub.contract-attr.attr-code     = "contract-diadoc"
        .
    end.
    ub.contract-attr.attr-value = string(if objContracts:edi_ = 2 then "yes" else "no") . 

    find first ub.contract-attr exclusive-lock where ub.contract-attr.host-code = ub.contract.host-code and 
      ub.contract-attr.contract-code = ub.contract.contract-code and
      ub.contract-attr.attr-code = "contract-edi_orders"  no-error .
    if not available (ub.contract-attr) then 
    do:
      create ub.contract-attr .
      assign
        ub.contract-attr.host-code     = ub.contract.host-code
        ub.contract-attr.contract-code = ub.contract.contract-code
        ub.contract-attr.attr-code     = "contract-edi_orders"
        .
    end.
    ub.contract-attr.attr-value = string(if objContracts:edi-orders = 1 then "yes" else "no") . 

  end method.
  method private character date-1C (inValue as character):
    
    def var v-str as character no-undo.
    if inValue = "0001-01-01" then v-str = ? .
    else v-str = entry (3, string(inValue), "-") + "/" + entry (2, string(inValue), "-") + "/" + entry (1, string(inValue), "-") .

    return v-str.
    
  end.
end class.