{ cmp/str-glbl.i }
&if "{1}" eq "beg_proc" or "{1}" eq "proc_def"
&then
define variable mAsyncProc as class ibs.th.file.AsyncProc. 
run ibs\th\file\getasyncproc.p (output mAsyncProc).

define variable mstopAsunc as logical no-undo.
{&CommentStartNoClass}
method private logical StopCheck ():
define variable oFlag as logical no-undo. 
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}

function StopCheck returns logical:
   define variable oFlag as logical no-undo.
   run StopCheckAsync (output oFlag).
   return oFlag.
end.

procedure StopCheckAsync:
    define output  parameter oFlag as logical no-undo.
{utl\comment.i} */
    if mstopAsunc
    then 
       oFlag = mstopAsunc.
    else do:
       oFlag = mAsyncProc:CheckStop().
       mstopAsunc = oFlag.
    end.
{&CommentStartNoClass}
   return oFlag.
{utl\comment.i} */
end.



{&CommentStartNoClass}
method private character  GetParamAsunc 
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function GetParamAsunc returns character 
{utl\comment.i} */
(input iNumPar as integer  ):
   return mAsyncProc:GetPARAM(iNumPar).
end.

{&CommentStartNoClass}
method private ibs.th.file.asyncparam GetParamAsuncStr 
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function GetParamAsuncStr returns ibs.th.file.asyncparam 
{utl\comment.i} */
(input iParamName as character ):
   return mAsyncProc:GetPARAM(iParamName).
end.

&endif
&if defined(ProcASyncLogDef) eq 0 
   and ("{1}" eq "beg_proc" or "{1}" eq "proc_def" or "{1}" eq "beg_class" or "{1}" eq "proc_log")
&then
&glob ProcASyncLogDef = yes
{&CommentStartNoClass}
method private logical PutMesAsunc (input Itext as character ):
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
procedure PutMesAsunc:
    define input  parameter Itext as character no-undo.
    define variable vflag as logical no-undo.
{utl\comment.i} */
    Publish "WriteLogAsunc" &if "{2}" ne "" &then from {2} &endif (Itext, yes)  .
end.

{&CommentStartNoClass}
method private logical PutMesAsuncNoTime (input Itext as character ):
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
procedure PutMesAsuncNoTime:
    define input  parameter Itext as character no-undo.
    define variable vflag as logical no-undo.
{utl\comment.i} */
    Publish "WriteLogAsunc" &if "{2}" ne "" &then from {2} &endif (Itext,no)  .
end.


{&CommentStartNoClass}
method private logical PutStatAsunc (input Itext as character ):
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
procedure PutStatAsunc:
    define input  parameter Itext as character no-undo.
{utl\comment.i} */
    Publish "PutStatAsunc" &if "{2}" ne "" &then from {2} &endif (Itext,no) .
    {&CommentStartClass} run {utl\comment.i} */
    PutMesAsunc (itext).
end.

{&CommentStartNoClass}
method private logical PutStatAsuncNoTime (input Itext as character ):
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
procedure PutStatAsuncNoTime:
    define input  parameter Itext as character no-undo.
{utl\comment.i} */
    Publish "PutStatAsunc" &if "{2}" ne "" &then from {2} &endif (Itext,no)  .
    {&CommentStartClass} run {utl\comment.i} */
    PutMesAsuncNoTime (itext).
end.

{&CommentStartNoClass}
method private logical PutStatAsuncAdd (input Itext as character ):
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
procedure PutStatAsuncAdd:
    define input  parameter Itext as character no-undo.
{utl\comment.i} */
    
    Publish "PutStatAsunc" &if "{2}" ne "" &then from {2} &endif (Itext,yes)  .
end.

{&CommentStartNoClass}
method private logical PutFileLogAsunc (input IFile as character ):
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
procedure PutFileLogAsunc:
    define input  parameter IFile as character no-undo.
{utl\comment.i} */
    Publish "PutFileLogAsunc" &if "{2}" ne "" &then from {2} &endif (ifile)  .
end.

&endif

&if "{1}" eq "beg_proc" or "{1}" eq "proc_def" or "{1}" eq "class_init"
&then
   &if "{2}" ne "" 
   &then  
       mAsyncProc:mProcPublish = {2}.
   &elseif "{1}" eq "beg_proc" or "{1}" eq "proc_def"
   &then
       mAsyncProc:mProcPublish = this-procedure.
    
   &endif
&endif

&if "{1}" eq "beg_proc"
&then
define variable mAsuncStopUser as logical no-undo.
procedure WriteLogAsunc:
    define input  parameter Itext as character no-undo.
    define input  parameter IFlag as logical   no-undo.
    
    define variable vflag as logical no-undo.
    mAsyncProc:PutMes(input Itext, input IFlag).
    run StopCheckAsync(output vflag).
    if vflag
    then do:
       mAsuncStopUser = yes.
       stop.
    end.
end.

procedure SetGblError:
   define input  parameter Itext as character no-undo.
   define variable vtext as character no-undo.
   if mAsuncStopUser
   then do:
      vtext = "Error Операция прервана пользователем.".
      mAsyncProc:PutMes(vtext).
   end.
   else do:
      if Itext eq ?
      then
         vtext = "Error Ошибка при выполнениее асинхроного процесса".
      else
         vtext = "Error " + vtext.
      mAsyncProc:SetGblError(input Itext).
   end.
end.

{ utl/search.i }
{&CommentStartNoClass}
method private logical writeFileLogAsunc (input IFile as character ):
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
procedure writeFileLogAsunc:
    define input  parameter IFile as character no-undo.
{utl\comment.i} */
    ifile = searchfile(ifile).
    if ifile ne ?
    then
       mAsyncProc:Nextlog(ifile).
end.

{&CommentStartNoClass}
method private logical WriteStatAsunc (input IText as character, input IFlagAdd as logical ):
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
procedure WriteStatAsunc:
    define input  parameter IText    as character no-undo.
    define input  parameter IFlagAdd as logical no-undo.
{utl\comment.i} */
   mAsyncProc:putStatus (Itext,IFlagAdd).    
end.

procedure IsAsyncProc:
   define output parameter oIsAsync as logical no-undo.
   oIsAsync = yes.
end.


define variable mnum   as integer no-undo.
define variable mCount as integer no-undo.
subscribe "StopProc"           anywhere run-procedure "StopCheckAsync".
subscribe "WriteLogAsunc"      anywhere.      
subscribe "PutStatAsunc"       anywhere run-procedure "WriteStatAsunc".      
subscribe "PutFileLogAsunc"    anywhere run-procedure "writeFileLogAsunc" .    
subscribe "IsAsyncProc"        anywhere .  

output to "errorasync.log".
mAsyncProc:BegRec () .
mNum   = int(mAsyncProc:GetPARAM("numSession"):valueparam).
mCount = int(mAsyncProc:GetPARAM("countSession"):valueparam).
mAsyncProc:creatProcInfo(1,mNum,mCount).
mAsyncProc:WritelogInter = decimal (mAsyncProc:GetPARAM("WritelogInter"):valueparam).

&endif

&if "{1}" eq "end_proc"
&then

finally:
   mAsyncProc:EndRec ()  .
   unsubscribe "StopProc".
   unsubscribe "WriteLogAsunc".
   unsubscribe "PutStatAsunc".      
   unsubscribe "PutFileLogAsunc".      
   unsubscribe "IsAsyncProc".
   delete object mAsyncProc.
   output close.
   output to "endproc.txt".
   output close.
   quit. 
end.
&endif

