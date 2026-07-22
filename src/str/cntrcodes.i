/*

$Revision: 2176712e0986, 2157, rls $
$Author: SSlivenko $
$Date: Wed Dec 25 15:23:56 2019 +0300 $
$Workfile: cntrcode.i $
$Archive: str/cntrcode.i $

Интерфейсная обработка нескольких договоров

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create1: Суслов Алексей Юрьевич

*/
procedure check-contract-code :
  define input  parameter parmode           as   character                     no-undo.
  define input  parameter parhost-code      like ub.trn-doc.host-code          no-undo.
  define input  parameter parcli-type       like ub.trn-doc.cli-type           no-undo.
  define input  parameter parcli-code       like ub.trn-doc.cli-code           no-undo.
  define input  parameter parframe-value    as   character                     no-undo.
  define input  parameter parmenu-handle    as   handle                        no-undo.
  define input  parameter parobj-date       as   date                          no-undo.
  define input  parameter partype-contract  as   character                     no-undo .
  define output parameter parcontract-code  as   character                     no-undo.

  define buffer bf_contract     for ub.contract.
  define buffer bf-oth_contract for ub.contract.
  define variable varrid-list      as character no-undo.
  define variable varrecid         as recid     no-undo.
  define variable varlog           as logical   no-undo.
  define variable var-args         as char      no-undo.
  define variable var-ext-doc-type as char      no-undo.
  define variable jj               as integer   no-undo .
  
  do on error undo, return error return-value :

    /* вырезаем из parmode строчки дополнительных аргументов, то есть все что после первой запятой */
    var-args = parmode.
    parmode = entry(1, parmode).

    /* тип накладной */
    run cntrcode-get-arg-val(var-args, "doc-type", output var-ext-doc-type).

    if partype-contract = "" or partype-contract = ? then
      partype-contract = {&income} .
    assign
      parcontract-code = ""
      .
    if parmode = "input":u
      then 
    do:
      if parframe-value = ""
        then 
      do:
        assign
          parcontract-code = ""
          .
      end.
      else 
      do:
        find first bf_contract no-lock
          where bf_contract.host-code         = parhost-code
          and bf_contract.cli-type          = parcli-type
          and bf_contract.cli-code          = parcli-code
          and bf_contract.contract-prn-code = parframe-value
          no-error.
        if available bf_contract
          then 
        do:
          find first bf-oth_contract no-lock
            where bf-oth_contract.host-code          = parhost-code
            and bf-oth_contract.contract-prn-code  = parframe-value
            and bf-oth_contract.cli-type           = parcli-type
            and bf-oth_contract.cli-code           = parcli-code
            and rowid(bf_contract)                 <> rowid(bf-oth_contract)
            no-error .
          if available bf-oth_contract
            then 
          do:
            message
              "На фирме " parhost-code skip
              "у контрагента" parcli-type parcli-code skip
              "имеются два контракта с номером" parframe-value skip
              view-as alert-box .
          end.
          else 
          do:
            assign
              parcontract-code = string(bf_contract.contract-code)
              .
          end.
        end.
      end.
    end.
    if parmode <> "input":u
      or parcontract-code = ""
      then 
    do:
      run str/cont-all.w (input parmenu-handle,
        input parhost-code,
        input "b-sel,b-mark",
        input "firm-curr" ,
        input parcli-type,
        input parcli-code,
        input ?,
        input ?,
        input "current":u,
        input partype-contract,
        input-output varrid-list ) no-error.
      if error-status:error then 
      do:
        message "Ошибка при вызове справочника договоров." skip
          return-value                skip
          error-status:get-message(1) skip
          error-status:get-message(2)
          view-as alert-box error.
        return error.
      end.
      do jj = 1 to num-entries (varrid-list):
        assign
          varrecid = integer(entry(jj, varrid-list)).
        find first bf_contract where recid(bf_contract) = varrecid no-lock no-error.
        if available bf_contract then 
        do:
          assign
            parcontract-code = parcontract-code + "," + string(bf_contract.contract-code).
        end.
      end.
    end.
  end.
end procedure.

procedure check-contract-code-attr :
  define input  parameter parmode           as   character                     no-undo.
  define input  parameter parhost-code      like ub.trn-doc.host-code          no-undo.
  define input  parameter parcli-type       like ub.trn-doc.cli-type           no-undo.
  define input  parameter parcli-code       like ub.trn-doc.cli-code           no-undo.
  define input  parameter parframe-value    as   character                     no-undo.
  define input  parameter parmenu-handle    as   handle                        no-undo.
  define input  parameter parobj-date       as   date                          no-undo.
  define input  parameter partype-contract  as   character                     no-undo .
  define input  parameter parattr-code      as   character                     no-undo .
  define output parameter parcontract-code  as   character                     no-undo.

  define buffer bf_contract     for ub.contract.
  define buffer bf-oth_contract for ub.contract.
  define variable varrid-list      as character no-undo.
  define variable varrecid         as recid     no-undo.
  define variable varlog           as logical   no-undo.
  define variable var-args         as char      no-undo.
  define variable var-ext-doc-type as char      no-undo.
  define variable jj               as integer   no-undo .
  
  do on error undo, return error return-value :

    /* вырезаем из parmode строчки дополнительных аргументов, то есть все что после первой запятой */
    var-args = parmode.
    parmode = entry(1, parmode).

    /* тип накладной */
    run cntrcode-get-arg-val(var-args, "doc-type", output var-ext-doc-type).

    if partype-contract = "" or partype-contract = ? then
      partype-contract = {&income} .
    assign
      parcontract-code = ""
      .
    if parmode = "input":u
      then 
    do:
      if parframe-value = ""
        then 
      do:
        assign
          parcontract-code = ""
          .
      end.
      else 
      do:
        find first bf_contract no-lock
          where bf_contract.host-code         = parhost-code
          and bf_contract.cli-type          = parcli-type
          and bf_contract.cli-code          = parcli-code
          and bf_contract.contract-prn-code = parframe-value
          no-error.
        if available bf_contract
          then 
        do:
          find first bf-oth_contract no-lock
            where bf-oth_contract.host-code          = parhost-code
            and bf-oth_contract.contract-prn-code  = parframe-value
            and bf-oth_contract.cli-type           = parcli-type
            and bf-oth_contract.cli-code           = parcli-code
            and rowid(bf_contract)                 <> rowid(bf-oth_contract)
            no-error .
          if available bf-oth_contract
            then 
          do:
            message
              "На фирме " parhost-code skip
              "у контрагента" parcli-type parcli-code skip
              "имеются два контракта с номером" parframe-value skip
              view-as alert-box .
          end.
          else 
          do:
            assign
              parcontract-code = string(bf_contract.contract-code)
              .
          end.
        end.
      end.
    end.
    if parmode <> "input":u
      or parcontract-code = ""
      then 
    do:
      run str/cont-all-attr.w (input parmenu-handle,
        input parhost-code,
        input "b-sel,b-mark",
        input "firm-curr" ,
        input parcli-type,
        input parcli-code,
        input ?,
        input ?,
        input "current":u,
        input partype-contract,
        input parattr-code,
        input-output varrid-list ) no-error.
      if error-status:error then 
      do:
        message "Ошибка при вызове справочника договоров." skip
          return-value                skip
          error-status:get-message(1) skip
          error-status:get-message(2)
          view-as alert-box error.
        return error.
      end.
      do jj = 1 to num-entries (varrid-list):
        assign
          varrecid = integer(entry(jj, varrid-list)).
        find first bf_contract where recid(bf_contract) = varrecid no-lock no-error.
        if available bf_contract then 
        do:
          assign
            parcontract-code = parcontract-code + "," + string(bf_contract.contract-code).
        end.
      end.
    end.
  end.
end procedure.


/* получение значения параметров из parmode */
procedure cntrcode-get-arg-val:
  def input param p-args as char no-undo.
  def input param p-key as char no-undo.
  def output param p-val as char no-undo.

  def var i       as int  no-undo.
  def var nums    as int  no-undo.
  def var key-val as char no-undo.
    
  nums = num-entries(p-args).
  do i = 1 to nums:
    key-val = entry(i, p-args).
    if key-val begins (p-key + "=") then 
    do:
      p-val = entry(2, key-val, "=").
      return.
    end.
  end.
    
  p-val = "".
end.    