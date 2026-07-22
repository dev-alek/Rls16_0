define variable mDebug as logical no-undo.
mDebug = session:debug-alert.

/* https://1c-docs.diadoc.ru/ru/latest/ */
&scoped-define vssseq {&sequence}
def var vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define variable mDiadocApi as component-handle no-undo.
define variable mDiadocConnection as component-handle no-undo.
define variable m-sys-key as character no-undo.
define variable marpar-type as character no-undo.
define variable mPublishHand as handle  no-undo.
define variable mFlaftest as logical no-undo.
/*define variable mdiadoc as logical no-undo.*/

   create "Diadoc.DiadocClient":U mDiadocApi no-error.
/*   mdiadoc = yes.*/
{gbl\objsrv.i}
define variable mySeqUtd as int64 no-undo init ?.
if mDiadocApi eq ?
then do:
   if  log-manager:logfile-name ne ?
   then
      log-manager:write-message("Нет библиотеки Diadoc или не удалось создать объект Diadoc.DiadocClient", "EDOError"). 
end. 
else do:
   if  log-manager:logfile-name ne ?
   then
      log-manager:write-message(substitute ("Версия библиотеки Diadoc &1" , mDiadocApi:GetFullVersion()) , "EDOError"). 
end.

&if "{1}" = "class"
&then
&else
{ gbl/key-rec.i }
    
&endif
{ cmp/str-glbl.i {1}}
{ str/utd-attr.i {1} }
{ str/utd-err.i {1} &*}
{ str/utd.i {1}}
{ gbl/attr-lib.i {1}}
{ cmp/library.i {1}}
{ str/ucd.i {1}}
{ str/edo-sysext.i}
define stream File-stream.
{ str/edo-log.i }
{ str/edo-auxiliary.i }
{ str/edo-conect.i }
{ str/edo-doc.i }
{ str/edo-auto.i }
&if "{1}" ne "nosend"
&then
{ str/edo-send.i }
&endif
{ str/edo-load.i }
{ str/edo-newdoc.i }
procedure MySeqForUtd:
   define input  parameter iTable       as character no-undo.
   define input  parameter iseqnamehist as character no-undo.
   define input  parameter idb-name     as character no-undo.
   define output parameter Oseq         as int64 no-undo.
   if iTable begins "utd"
   then do:
      if myseqUtd eq ?
      then 
         myseqUtd = dynamic-next-value(iseqnamehist,idb-name).
      Oseq = myseqUtd.
   end.
   else
      Oseq = ?. 
   return.
end.