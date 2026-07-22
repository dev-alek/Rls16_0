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

define input parameter p-Cashiers as class cashiers no-undo.



define variable vss-revision    as character no-undo init "$Revision: 07968b41871b, 1804, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Tue Mar 05 16:32:36 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: imp-cashiers-1c-RN.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/imp-cashiers-1c-RN.p $":U .
define variable vss-description as character no-undo init "Загрузка переоценки из ERP 1C RN".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/cur-time.i }

DEFINE TEMP-TABLE tt-clients NO-UNDO LIKE ub.clients.
DEFINE TEMP-TABLE tt-person NO-UNDO LIKE ub.person.
DEFINE TEMP-TABLE tt-staff NO-UNDO LIKE ub.staff.

{ trg/person1s.i tt-staff }

define variable v-rec       as recid   no-undo .
define variable v-rid       as recid   no-undo .
define variable v-curr-code as integer no-undo .
define buffer buf_clients for ub.clients .
define buffer bf_clients  for ub.clients .
define buffer buf_staff   for ub.staff .
define buffer buf_person  for ub.person .
define buffer buf_cli-grp for ub.cli-grp .
    
define variable v-mode       as character no-undo .
define variable p-mode       as character no-undo .
define variable v-clients-ok as logical   no-undo .
define variable v-role       as character no-undo .
    
/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
    
define variable v-today      as date      no-undo.  
define variable v-time       as integer   no-undo.    
run cur-time in this-procedure (output v-today, output v-time) no-error.
if ERROR-STATUS:error then 
do:
  undo, return error "Ошибка при определении текущей даты!" .
end.  

if p-Cashiers:del-f = 1 then 
do:
  /*удаление персонала*/
  /*нужна проверка, что нигде не участвует как кассир*/        
  find first buf_clients EXCLUSIVE-LOCK where buf_clients.obj-code = integer(p-Cashiers:code_)
    and buf_clients.obj-type = {&prs} and buf_clients.grp-code = 4 no-error .
  if AVAILABLE buf_clients then 
  do:
    for first buf_person exclusive-lock where buf_person.psn-code = buf_clients.obj-code:
      for first buf_staff EXCLUSIVE-LOCK where buf_staff.psn-code = buf_person.psn-code and buf_staff.staff-code = integer(p-Cashiers:code_):
        assign
          buf_staff.date-end = v-today 
          buf_clients.stts   = p-Cashiers:del-f
          . 
      end.  
      
    end.  
  end.
  else 
  do:
    undo, return error "Клиент не найден с кодом:" + p-Cashiers:code_ .
  end.                    
end.  
else 
do:
  find first buf_cli-grp no-lock where buf_cli-grp.node-code = 4 no-error .
  if not AVAILABLE buf_cli-grp then 
  do:
    undo, return error "Нет группы клиентов с кодом: 4".
  end. /*if not AVAILABLE buf_cli-grp then*/
  else 
  do:  

    find first buf_clients EXCLUSIVE-LOCK where buf_clients.obj-code = integer(p-Cashiers:code_) 
      and buf_clients.obj-type = {&prs} no-error .
    if not AVAILABLE buf_clients then 
    do:
      create tt-clients.
      assign
        v-mode = {&add-def} 
        v-rec  = ?
        .
    end.
    else 
    do:
      create tt-clients.             
      buffer-copy buf_clients to tt-clients.
      assign
        v-mode = {&update} 
        v-rec  = recid(buf_clients)
        .
    end.  
    assign
      tt-clients.obj-code = integer(p-Cashiers:code_)
      tt-clients.obj-type = {&prs}
      tt-clients.db-num   = ?
      tt-clients.grp-code = buf_cli-grp.node-code
      tt-clients.grp-name = buf_cli-grp.node-name
      tt-clients.obj-name = p-Cashiers:name_
      tt-clients.stts     = p-Cashiers:del-f 
      .
    
    find first buf_person EXCLUSIVE-LOCK where buf_person.psn-code = integer(p-Cashiers:code_) no-error .
    if not AVAILABLE buf_person then 
    do:
      create tt-person .
      assign
        tt-person.psn-code = integer(p-Cashiers:code_)
        .
    end.
    else 
    do:
      create tt-person .
      BUFFER-COPY buf_person to tt-person . 
    end.  

      
    if p-Cashiers:role-code = 2 then v-role = {&role-cashier} . 
    else v-role = "cli-all" . 
        
    /*сделать р для вызова этой процедуры*/
    run ref/person1.p (
      input this-procedure
      ,input this-procedure:handle
      ,input-output v-rec
      ,input v-mode
      ,input v-role
      ,input yes /*p-silent*/
      ,input tt-person.psn-code
      ,input tt-clients.stts
      ,input tt-clients.obj-name
      ,input tt-clients.lim-kr
      ,input tt-clients.PS
      ,input tt-clients.grp-code
      ,input tt-person.address
      ,input tt-person.city
      ,input tt-person.date-birth
      ,input tt-person.e-mail
      ,input tt-person.fax
      ,input tt-person.firm-code
      ,input tt-person.firm-name
      ,input tt-person.gender
      ,input tt-person.given-by
      ,input tt-person.ind
      ,input tt-person.inn
      ,input yes
      ,input tt-person.is-pboul
      ,input tt-person.kpp
      ,input tt-person.name1
      ,input tt-person.name2
      ,input tt-person.okonh
      ,input tt-person.okpo
      ,input tt-person.passp-num
      ,input tt-person.passp-ser
      ,input tt-person.phone1
      ,input tt-person.phone1-note
      ,input tt-person.position
      ,input tt-person.post-box
      ,input tt-person.post-address
      ,input tt-person.post-city
      ,input tt-person.post-ind
      ,input tt-clients.reg-code
      ,input tt-clients.turnover-buyer
      ,input tt-clients.turnover-buyer-gds
      ) no-error .
    if error-status:error then 
    do:
      return error RETURN-VALUE .
    end.
    if p-Cashiers:role-code = 2 then 
    do:
      find first bf_clients EXCLUSIVE-LOCK where bf_clients.obj-code = integer(p-Cashiers:code_) 
        and bf_clients.obj-type = {&prs} no-error .
      
      find first buf_staff EXCLUSIVE-LOCK where buf_staff.psn-code = integer(p-Cashiers:code_)
        and buf_staff.role       = {&role-cashier}
        /*        and buf_staff.date-end > TODAY*/
        no-error .
      if not AVAILABLE buf_staff then
      do:
        create buf_staff .
        assign
          buf_staff.psn-code   = integer(p-Cashiers:code_)
          buf_staff.password   = string(p-Cashiers:code_)
          buf_staff.date-start = v-today
          buf_staff.db-num     = g#db-num
          buf_staff.role       = {&role-cashier}
          buf_staff.role-level = {&role-level-db}
          buf_staff.staff-code = integer(p-Cashiers:code_)
          buf_staff.work-place = string(g#db-num, '99999')
          .

      end.
      if p-Cashiers:del-l = 1 then buf_staff.date-end = v-today. 
      else buf_staff.date-end = date("31/12/9999")  .
      
      if p-Cashiers:del-f = 0 then bf_clients.stts = 0 .
      
    end.
  end.  
  
end.   /*if AVAILABLE buf_cli-grp then*/           
