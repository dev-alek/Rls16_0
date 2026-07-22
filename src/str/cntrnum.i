/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Начиная с версии 14 ссылка на таблицу договоров проставляется в самом документе.
До этого это было текстовое значение в атрибутах.

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич
Дата создания: 11/19/03


*/

procedure cntrnum :
  define  input parameter pardoc-code          like ub.trn-doc.doc-code no-undo.
  define output parameter parcontract-prn-code as   character           no-undo.
  define output parameter parcontract-date     as   date                no-undo.

  define buffer bf_trn-doc  for ub.trn-doc.
  define buffer bf_contract for ub.contract.

  define variable varattr-type          as character no-undo.
  define variable parcontract-date-char as character no-undo.

  do on error undo, return error return-value :
    find first bf_trn-doc no-lock where
               bf_trn-doc.doc-code = pardoc-code no-error.
    if not available bf_trn-doc then do:
      return error substitute( 'Не найден документ с номером "&1".', pardoc-code ).
    end.
    if bf_trn-doc.contract-code = ? or
       bf_trn-doc.contract-code = 0 then do:
      { str/tdat-val.i bf_trn-doc.doc-code {&trdcattr-ndog} parcontract-prn-code  varattr-type }
      { str/tdat-val.i bf_trn-doc.doc-code {&trdcattr-ddog} parcontract-date-char varattr-type }
      assign
        parcontract-date = date( parcontract-date-char ) no-error.
    end.
    else do:
      find first bf_contract no-lock where
                 bf_contract.host-code     = bf_trn-doc.host-code     and
                 bf_contract.contract-code = bf_trn-doc.contract-code no-error.
      if available bf_contract then do:
        assign
          parcontract-prn-code = bf_contract.contract-prn-code
          parcontract-date     = bf_contract.contract-date.
      end.
    end.
  end. /* on error */
end procedure. /* cntrnum */

/* $Workfile$   E n d */