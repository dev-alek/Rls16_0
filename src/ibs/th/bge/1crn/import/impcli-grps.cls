/*

$Revision: 2bd1eb1a030d, 1125, rls $
$Author: SMMolotkov $
$Date: Thu Dec 14 02:13:54 2017 +0300 $
$Workfile: impcli-grps.cls $
$Archive: ibs/th/bge/1crn/import/impcli-grps.cls $

Класс ипорта данных cli-grps (группы контрагентов) из 1С

Автор: Молотков Сергей
Дата создания: 02/10/17
Author: Molotkov Sergey
Creation date: 02/10/17

*/

using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
block-level on error undo, throw.

class ibs.th.bge.1crn.import.impcli-grps implements ibs.th.bge.1crn.import.iimpsubject: 
  
  { cmp/str-glbl.i class }
  
  
  define property Msg as character no-undo
    get. 
    set.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
    define variable objImp       as class cli-grps no-undo.
    define variable v-mode       as character no-undo. /* create/update */
    define variable v-doc-rec    as recid no-undo.
    define variable v-node-code  as integer no-undo . /* like ub.cli-grp.node-code */
    define variable v-upper-code as integer no-undo . /* like ub.cli-grp.upper-code */
    define variable v-retfl      as logical no-undo .
    define buffer buf_cli-grp for ub.cli-grp .

    objImp = cast (subjectObj, cli-grps).

    assign
      v-node-code  = integer(objImp:code_)
      v-upper-code = integer(objImp:upper-code)
      Msg = ""
    .
    
    if objImp:del-f > 0 then do:
      /* удаление групп клиентов определено только для ГБД */
      /* физическое удаление записи
          если внешней процедуры удаления ещё нет - можно реализовать методом;
          если в методе придётся использовать инклюдник с procedure - нужно реализовывать внешней процедурой
      */
      run ref/cligrp03.p ( input v-node-code ) .
      v-retfl = true .
    end .
    else if objImp:del-l > 0 then do:
      /* По справочникам ..., Группы клиентов, ... при логическом удалении записей на стороне ТН никаких действий не производится,
         а при передаче из 1С к названию добавляется фраза «УДАЛЕНО» (или аналог). */
      run ref/cligrp01.p
      (input {&update}
      ,input true /* p-silent */
      ,input true /* p-get-node-code: cli-grp.node-code = if true then p-node-code else next-value s-cli-grp */
      ,input-output v-node-code  /* p-node-code */
      ,input-output v-upper-code /* p-upper-code */
      ,input "УДАЛЕНО " + objImp:name_ /* УДАЛЕНО + p-node-name */
      ,output v-doc-rec
      ) .
      v-retfl = true .
    end.
    else do:
      assign
         v-mode   = if can-find (first buf_cli-grp where buf_cli-grp.node-code = v-node-code) then {&update} else {&add-def}
      .
      run ref/cligrp01.p
      (input v-mode
      ,input true /* p-silent */
      ,input true /* p-get-node-code: cli-grp.node-code = if true then p-node-code else next-value s-cli-grp */
      ,input-output v-node-code  /* p-node-code */
      ,input-output v-upper-code /* p-upper-code */
      ,input objImp:name_        /* p-node-name */
      ,output v-doc-rec
      ) .
      v-retfl = true .
    end .
    
    catch exAppErrors as class Progress.Lang.AppError :
      Msg = exAppErrors:ReturnValue .
      if Msg > "" then . else do :
        Msg = exAppErrors:GetMessage(1) .
        if Msg > "" then . else Msg = "AppError в группах клиентов" .
      end .
      v-retfl = false .
      undo, throw exAppErrors .
    end catch .
    catch exProErrors as class Progress.Lang.ProError :
      Msg = exProErrors:GetMessage(1) . 
      if Msg > "" then . else Msg = "ProError в группах клиентов" .
      v-retfl = false .
      undo, throw exProErrors .
    end catch .
    catch exAnyErrors as class Progress.Lang.Error:
      Msg = "Unexpected error в группах клиентов" .
      v-retfl = false .
      undo, throw exAnyErrors .
    end catch .
    finally :
      return v-retfl .
    end finally .
  end method. /* end_of Excute */

end class.