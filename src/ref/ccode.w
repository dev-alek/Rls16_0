&glob param_1 iParent
define input  parameter {&Param_1} as character no-undo.
&glob param_2 iCode
define input  parameter {&Param_2} as character no-undo.
 


{ gbl/objsrv.i }
function fLabel returns character forward.

&glob buf_obj-hist c-code
&Glob VisibleKeyField yes
&glob myChangeAdd ParentPars
subscribe "getComboList" anywhere.
{ref/brwhist.i &lable = fLabel()}
unsubscribe "getComboList".
function getParentLabel returns character (
input itype as character, 
input iNum  as integer 
):
   return
   if itype ne "cash-param"
   then "Родитель " + string(inum)
   else if iNum = 1
   then "Справочник"
   else if iNum = 2
   then "Устройство"
   else if iNum = 3
   then "Источник"
   else if iNum = 4
   then "Группа параметров/функция"
   else if iNum = 5
   then "Параметр"
   else "Родитель " + string(inum).
   
end.

function getParentAll returns character (

):
   return
   if    iParent eq ""
      or iParent eq ?
   then icode
   else if icode eq ?
   then iParent
   else iParent + {&delim-par} + icode.
   
end.

function  getStsCashParam returns character (istatus as int ):
   
   &SCOPE sts-current "Обязательный"
   &SCOPE sts-del  "Необязательный"
  
   if istatus eq {&bef-deleted-status-int}
   then
      return {&sts-del}.
   else if istatus eq {&bef-current-status-int}
   then
      return {&sts-current}.
   else return "".
   
end.
&glob tt_name temp-changes
define variable mType      as character no-undo.
procedure ParentPars:
   define input  parameter iOldBuf as handle no-undo.
   define input  parameter iCurBuf as handle no-undo.
   define variable vparentOld as character no-undo.
   define variable vparentCur as character no-undo.
   vparentOld = if valid-handle(iOldBuf) and iOldBuf:available then iOldBuf::parent else "".
   vparentCur = if valid-handle(iCurBuf) and iCurBuf:available then iCurBuf::parent else "".
   mType = if    vparentOld begins "cash-param"
              or vparentCur begins "cash-param"
           then "cash-param"
           else ""
           .
    
   define variable vi as integer no-undo.
   do vi = 1 to max(num-entries (vparentOld,{&delim-par}),num-entries (vparentCur,{&delim-par})):
      create {&tt_name}.
      assign
        {&tt_name}.t_name = "code"
        {&tt_name}.f_name = "Parent_" + string(vi) 
      .
      {&tt_name}.l_name   = getParentLabel(mtype,vi).
      {&tt_name}.v_old    = entry(vi,vparentOld,{&delim-par}) no-error.
      {&tt_name}.v_new    = entry(vi,vparentCur,{&delim-par}) no-error.
      {&tt_name}.fNotChange = {&tt_name}.v_old eq {&tt_name}.v_new.
   end.
end.
function fLabel returns character :
   return "Записи справочника с родителем " +  if p-mode eq "one"  then  replace(iParent ,{&delim-par},"->") + " с кодом " + icode else replace(getParentAll() ,{&delim-par},"->").
end.

function get-subject returns character
  ( p-subject as character ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
&scop hn-obj-hist-code p-subject
  return p-subject.   /* Function return value. */

end function.
 
procedure local-view-cange:
   define output parameter odescription as character no-undo.
   define buffer current_c-code for ub.c-code  .
define variable v-mess as character no-undo.

do
on error undo, return error return-value
:
  find first current_c-code no-lock where
             current_c-code.parent = X_c-obj-hist.parent
         and current_c-code.code   = X_c-obj-hist.code
         and current_c-code.chip-num = X_c-obj-hist.chip-num
         and current_c-code.corr-user-db-num = X_c-obj-hist.corr-user-db-num no-error .
  if not avail current_c-code then do:
      v-mess = "Неверная ссылка на c-utd в таблице c-utd-head".
     
      return error  v-mess .
  end.
  &scop fields-name-list "code,Codevalue,codeName,export_,nwsgbd,nwsubd,procdel,procedit,procview,status_"
  define variable vProcSts as character no-undo.
  if X_c-obj-hist.parent begins "cash-param"
  then
     vProcSts = "getStsCashParam".
  define variable v-label-param as character no-undo .
  define variable vi as integer no-undo.
  v-label-param =
        "code"       + {&delim-par} + "Код"                                   + {&delim-par} + "" + {&delim-flf}
      + "Codevalue"  + {&delim-par} + "Значение"                              + {&delim-par} + "" + {&delim-flf}
      + "codeName"   + {&delim-par} + "Наименоваание"                         + {&delim-par} + "" + {&delim-flf}
      + "export_"    + {&delim-par} + "Выгружается"                           + {&delim-par} + "" + {&delim-flf}
      + "nwsgbd"     + {&delim-par} + "Ходит из ГБД в УБД"                    + {&delim-par} + "" + {&delim-flf}
      + "nwsubd"     + {&delim-par} + "Ходит из УБД в ГБД"                    + {&delim-par} + "" + {&delim-flf}
      + "procdel"    + {&delim-par} + "Процедура удаеления"                   + {&delim-par} + "" + {&delim-flf}
      + "procedit"   + {&delim-par} + "Процедура редактирования"              + {&delim-par} + "" + {&delim-flf}
      + "procview"   + {&delim-par} + "Процедура просмотра дочерних записей"  + {&delim-par} + "" + {&delim-flf}.
  do vi = 1 to 10: 
      v-label-param = v-label-param + "misc" + string(vi)      + {&delim-par} + "Доп поле " + string(vi)    + {&delim-par} + "" + {&delim-flf}.
  end.   
  v-label-param = v-label-param + "status_"        + {&delim-par} + "Статус"  + {&delim-par} + vProcSts .

  run proc-full-temp-changes in this-procedure (
                                               input current_c-code.action = integer({&hn-create})
                                              ,input current_c-code.action = integer({&hn-delete})
                                              ,input  buffer current_c-code:handle
                                              ,input  {&table_code}
                                              ,input  {&fields-name-list}
                                              ,input  v-label-param).

end. /*doe*/
   
end procedure.
  
function local-open-br returns logical 
(  p-open-query     as logical    ,
  p-find-next       as logical    ,
  p-find-condition as character ):
     define variable sort-column-phrase as character no-undo .
     define variable l-query-was-opened as logical no-undo .
   if p-mode eq "one"
   then do:
      if p-chip-num eq ?
      then do:
         { gbl/fltopend.i
           &where-cond = " X_c-obj-hist.Parent = iParent
                      and X_c-obj-hist.code   = iCode
                      and X_c-obj-hist.corr-user-db-num = v-corr-user-db-num "


           &dyn_where-cond = " substitute('X_c-obj-hist.Parent = &1&2&1  
                      and X_c-obj-hist.code   = &1&3&1
                      and X_c-obj-hist.corr-user-db-num = &4',~{&double-quote~},iParent,iCode, v-corr-user-db-num) "
          &by         = " by X_c-obj-hist.chip-num  " }
      end.
      else do:
         { gbl/fltopend.i
          &where-cond = " X_c-obj-hist.Parent = iParent  
                      and X_c-obj-hist.code   = iCode
                      and X_c-obj-hist.corr-user-db-num   eq v-corr-user-db-num
                      and X_c-obj-hist.chip-num           eq p-chip-num "
          &dyn_where-cond = " substitute('X_c-obj-hist.Parent = &1&2&1   
                      and X_c-obj-hist.code   = &1&3&1
                      and X_c-obj-hist.corr-user-db-num   eq &4
                      and X_c-obj-hist.chip-num           eq &5',~{&double-quote~},iParent,iCode, v-corr-user-db-num, p-chip-num) "
          &by         = " by X_c-obj-hist.chip-num  " }
      end.
   end.
   else if p-mode eq "parentBeg"
   then do:
      define variable vParent as character no-undo.
      vParent = getParentAll().
      
       
      if p-chip-num eq ?
      then do:
         { gbl/fltopend.i
          &where-cond = " X_c-obj-hist.Parent begins vParent  
                      and X_c-obj-hist.corr-user-db-num = v-corr-user-db-num "
          &dyn_where-cond = " substitute('X_c-obj-hist.Parent begins &1&2&1  
                                      and X_c-obj-hist.corr-user-db-num = &3', ~{&double-quote~}, vParent,v-corr-user-db-num) "
          &by         = " by X_c-obj-hist.chip-num  " }
      end.
      else do:
         { gbl/fltopend.i
          &where-cond = " X_c-obj-hist.Parent begins vParent  
                      and X_c-obj-hist.corr-user-db-num   eq v-corr-user-db-num
                      and X_c-obj-hist.chip-num           eq p-chip-num "
          &dyn_where-cond = " substitute('X_c-obj-hist.Parent begins &1&2&1
                                      and X_c-obj-hist.corr-user-db-num   eq &3
                                      and X_c-obj-hist.chip-num           eq &4
                                      ',~{&double-quote~},vParent, v-corr-user-db-num, p-chip-num) "

          &by         = " by X_c-obj-hist.chip-num  " }
      end.
   end.
  return true.
end.

procedure getComboList:
   define input  parameter ispr        as character no-undo.
   define output parameter oListVal    as character no-undo.
   define output parameter oListValRet as character no-undo.
   if ispr eq "hist-action"
   then assign
      oListVal    = "{&bef-hn-delete-full},{&bef-hn-create-full},{&bef-hn-update-full}"
      oListValRet = "{&bef-hn-delete},{&bef-hn-create},{&bef-hn-update}"
   .
end.