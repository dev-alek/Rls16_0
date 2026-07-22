block-level on error undo, throw.
/*

$Revision: 5918d4369f7a, 3506, rls $
$Author: VSpiridonov $
$Date: 2023/10/16 15:13:37 $
$Workfile: send-all.p $
$Archive: str/send-all.p $

Отсылка схемы интеграции ККТ

Автор: Шкляр Елена
Дата создания: 02/14/14
Author: Elena Shklyar
Creation date: 02/14/14

Input:

Output:

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .


define variable vss-revision    as character no-undo init "$Revision: 5918d4369f7a, 3506, rls $":U .
define variable vss-author      as character no-undo init "$Author: VSpiridonov $":U .
define variable vss-date        as character no-undo init "$Date: 2023/10/16 15:13:37 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: send-all.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/send-all.p $":U .
define variable vss-description as character no-undo init "Отсылка схемы интеграции ККТ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
/* i-value = "cash-send=all,....." - отправка на все кассы*/
/*str/send-all-work-" + i-type ".p           процедура persistent                     */
/*get-cash-types (output character )   типы касс по умолчанию {&cd-type-ibm-xml}*/
/*get-roor-teg   (output character )   туг обертка по умолчанию data            */
/*putc ( input hSAXWriter              дозаполнение xml при отправки на кассу   */
/*      ,input cash-desk.pos-type                                               */
/*      ,input cash-desk.version                                                */
/*      ,input cash-desk.cash-os                                                */
/*      ,input cash-desk.cash-num                                               */
/*      ,input i-action                                                         */
/*      ,input i-value)                                                         */
/*parse-result ( input parparentproc   Разбор ответа с кассы                    */
/*              ,input p-log-handle                                             */
/*              ,input {&shop}                                                  */
/*              ,input for-cash-desk.obj-code                                   */
/*              ,input ub.shop.host-code                                        */
/*              ,input for-cash-desk.pos-type                                   */
/*              ,input for-cash-desk.cash-num                                   */
/*              ,input mWebRespMptr                                             */
/*              ,input-output v-view-log )                                      */
define variable v-view-log as logical no-undo.
define variable log-file-name as character no-undo.
define variable out as character no-undo.
define variable v-xml-file-name as character no-undo.
define variable v-xml-file-name-path as character no-undo.
define variable v-log-file-name as character no-undo init "send-cd.txt".
define variable v-locked as logical no-undo.
{ str/cd-xml-file.i }
{ bge/socet.i}
run get-view-log in p-log-handle(output v-view-log)  no-error.

define variable i-obj-type as character no-undo .
define variable i-obj-code as integer   no-undo .
define variable i-action   as character no-undo init 'U':U.
define variable i-type     as character no-undo .
define variable i-title     as character no-undo .
define variable i-value    as character no-undo .

/*define stream str-log .*/
/*output stream  str-log to value("shema-KKT.log") append.*/
if num-entries (p-parameter,{&delim-par}) < 4
then do:
   run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!'Send-all' Список параметров должен состоять минимум из 4 элементов "
                        )
                        ).
   run set-view-log in p-log-handle(yes)  no-error.                     
   return.
end.
else do:
   define variable vi as integer no-undo.
   i-Type    = entry(4, p-parameter, {&delim-par}).
   vi = num-entries (i-Type).
   if vi eq 0
   then do:
      run write-log-and-file in p-log-handle (
           input 1
         , input log-file-name
         , input 1
         , input substitute( "!!!'Send-all' В список параметров 4 элемент не может быть пустым "
                           )
                                 ).
      run set-view-log in p-log-handle(yes)  no-error.
      
      return.
   end.
   else if vi > 1
   then do:
      do vi = 1 to num-entries (i-type):
         entry(4, p-parameter, {&delim-par}) = entry(vi,i-type).
         run str/send-all.p(parparentproc,
                            p-parent-handle,
                            p-log-handle,
                            p-parameter
         ).
      end.
      return.
   end.

end.    
assign
i-obj-type = entry(1, p-parameter, {&delim-par})
i-obj-code = integer(entry(2, p-parameter, {&delim-par}))
i-action     = entry(3, p-parameter, {&delim-par})
i-Type    = entry(4, p-parameter, {&delim-par})
i-Title    = entry(5, p-parameter, {&delim-par})
i-value    = entry(6, p-parameter, {&delim-par})
no-error
.
if i-Type eq "?"
then
   return error "Не задан тип для send-all.p".
define variable mValue   as character no-undo.
define variable mNumPar  as integer no-undo.
define variable mSendAll as logical no-undo.
define variable mCashNum as integer no-undo init ?.
define variable mCashAll as logical no-undo.
define variable mNumCashAll as integer no-undo.
mValue = replace(i-value,",","=").
mNumPar = lookup("cash-send",mValue,"=").


if mNumPar > 0
then do:
   mSendAll = entry(mNumPar + 1,mValue,"=") eq "all" no-error.
   mCashNum = int(entry(mNumPar + 1,mValue,"=")) no-error.
   if mCashNum <> ? and not mSendAll then do:
      /* проверяем параметр, надо ли посылать на указанный номер кассы, даже если она 
      ** выключена в справочнике касс */
      mNumCashAll = lookup("cash-all",mValue,"="). 
      if mNumCashAll > 0 then do: 
          mCashAll = entry(mNumCashAll + 1,mValue,"=") eq "all" no-error.
          if mCashNum <> ? and mCashNum <> 0 and mCashAll 
          then mSendAll = yes.
      end.
   end.   
end.
mNumPar = lookup("SocetLog",mValue,"=").
if mNumPar > 0
then
   mFileLogSocet = entry(mNumPar + 1,mValue,"=") no-error.    

/*PROCEDURE for-cash-cycle*/
/*пройдем цикл по всем кассам одного типа*/
{ str/send-all-cycle.i }

/*PROCEDURE SENDING.*/
{ str/send-all-sending.i }

RUN SENDING no-error.

if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!Ошибки при отсылке '&3' на кассы &1&2"
                         , i-obj-type, i-obj-code, i-Title
                        )
                                        ).
   v-view-log = yes.
end.
run set-view-log in p-log-handle(v-view-log) no-error.



