block-level on error undo, throw.
.session:debug-alert = yes.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define variable mAsyncProc as class ibs.th.file.AsyncProc.
run ibs\th\file\getasyncproc.p (output mAsyncProc).
define variable mstopAsunc as logical no-undo.
function StopCheck returns logical:
   define variable oFlag as logical no-undo.
   run StopCheckAsync (output oFlag).
   return oFlag.
end.
procedure StopCheckAsync:
    define output  parameter oFlag as logical no-undo.
    if mstopAsunc
    then
       oFlag = mstopAsunc.
    else do:
       oFlag = mAsyncProc:CheckStop().
       mstopAsunc = oFlag.
    end.
end.
function GetParamAsunc returns character
(input iNumPar as integer  ):
   return mAsyncProc:GetPARAM(iNumPar).
end.
function GetParamAsuncStr returns ibs.th.file.asyncparam
(input iParamName as character ):
   return mAsyncProc:GetPARAM(iParamName).
end.
procedure PutMesAsunc:
    define input  parameter Itext as character no-undo.
    define variable vflag as logical no-undo.
    Publish "WriteLogAsunc" (Itext, yes)  .
end.
procedure PutMesAsuncNoTime:
    define input  parameter Itext as character no-undo.
    define variable vflag as logical no-undo.
    Publish "WriteLogAsunc" (Itext,no)  .
end.
procedure PutStatAsunc:
    define input  parameter Itext as character no-undo.
    Publish "PutStatAsunc" (Itext,no) .
     run
    PutMesAsunc (itext).
end.
procedure PutStatAsuncNoTime:
    define input  parameter Itext as character no-undo.
    Publish "PutStatAsunc" (Itext,no)  .
     run
    PutMesAsuncNoTime (itext).
end.
procedure PutStatAsuncAdd:
    define input  parameter Itext as character no-undo.
    Publish "PutStatAsunc" (Itext,yes)  .
end.
procedure PutFileLogAsunc:
    define input  parameter IFile as character no-undo.
    Publish "PutFileLogAsunc" (ifile)  .
end.
       mAsyncProc:mProcPublish = this-procedure.
if        StopCheck()
then do:
   run PutstatAsunc(substitute("error   Получение проверка была преврвана пользователем или по TimeOut.") ).
   return.
end.
if userid("ub") ne ""
then do:
    run PutstatAsunc(substitute("error   Не правильное подключение к Базе. ") ).
return.
end.
define variable v-num-parameters as integer no-undo.
define variable mProc-name as character no-undo.
define variable mparparentproc as logical   no-undo.
define variable mKey as integer  no-undo.
define variable MChekSum as character no-undo.
define variable m-parameter1 as character no-undo.
define variable m-parameter2 as character no-undo.
define variable m-parameter3 as character no-undo.
mProc-name        =          GetPARAMAsunc(1).
v-num-parameters  = integer (GetPARAMAsunc(2)).
mparparentproc    = logical (GetPARAMAsunc(3)).
mkey              = integer (GetPARAMAsunc(4)).
m-parameter1      =          GetPARAMAsunc(5).
m-parameter2      =          GetPARAMAsunc(6).
m-parameter3      =          GetPARAMAsunc(7).
if     v-num-parameters ne ?
   and mparparentproc   ne ?
   and mkey     ne ?
then do:
   case v-num-parameters :
      when 0
      then do:
         if mparparentproc
         then do:
            run value (mProc-name)
                   (input  mkey,
                    output MChekSum,
                    input ?
                   ) no-error.
         end.
         else do:
            run value (mProc-name)
                   (input  mkey,
                    output MChekSum
                    )no-error.
         end.
      end.
      when 1
      then do:
         if mparparentproc
         then do:
              run value (mproc-name)
                (input  mkey,
                 output MChekSum,
                 input  ?
                ,input  m-parameter1
                )no-error.
         end.
         else do:
            run value (mproc-name)
                (input  mkey,
                 output MChekSum,
                 input m-parameter1
                )no-error.
         end.
      end.
      when 2
      then do:
         if mparparentproc
         then do:
            run value (mproc-name)
                (input  mkey
                ,output MChekSum
                ,input ?
                ,input m-parameter1
                ,input m-parameter2
                )no-error.
         end.
         else do:
            run value (mproc-name)
                (input  mkey
                ,output MChekSum
                ,input m-parameter1
                ,input m-parameter2
                )no-error.
         end.
      end.
      when 3
      then do:
         if mparparentproc
         then do:
            run value (mproc-name)
                (input  mkey
                ,output MChekSum
                ,input ?
                ,input m-parameter1
                ,input m-parameter2
                ,input m-parameter3
                )no-error.
         end.
         else do:
            run value (mproc-name)
                (input  mkey
                ,output MChekSum
                ,input m-parameter1
                ,input m-parameter2
                ,input m-parameter3
                )no-error.
         end.
      end.
   end case.
   def var v-counter as int no-undo.
   if error-status:error
   then do v-counter = 1 to error-status :num-messages
       :
        run PutstatAsunc(substitute("error  &1",error-status:get-message (v-counter)) ).
   end.
   else
   run PutMesAsuncNoTime ( string(MChekSum) ).
end.
