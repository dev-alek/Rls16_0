block-level on error undo, throw.
define input  parameter parparentproc as handle no-undo.
define input  parameter iMask         as character no-undo.
define input  parameter iFile-name    as character no-undo.
define input  parameter iKey          as character no-undo.
define output parameter oValue        as character no-undo.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
function ApplyFormatDec returns character ( input iValue as decimal, input iFormat as character ):
   define variable oValue as character no-undo.
   if iFormat eq ""
   then
      oValue = string(iValue).
   else do:
      oValue = string(iValue,iformat) no-error.
      if    error-status:error
         or oValue eq ?
         or oValue eq "?"
      then do:
         oValue = string(iValue).
         message "Ошибка приведения значения тега " iVAlue " к формату " iformat skip
                      error-status:get-message (1) skip "Формат проигнорирован."
              view-as alert-box.
      end.
   end.
   return oValue.
end.
function ApplyFormatChar returns character ( input iValue as character , input iFormat as character ):
   define variable oValue as character no-undo.
   if iFormat eq ""
   then
      oValue = iValue.
   else do:
      oValue = string(iValue,iformat) no-error.
      if error-status:error
      then do:
         oValue = iValue.
         message "Ошибка приведения значения тега " iVAlue " к формату " iformat skip
                      error-status:get-message (1) skip "Формат проигнорирован."
              view-as alert-box.
      end.
   end.
   return oValue.
end.
procedure getTegValue :
   define input  parameter iteg as character no-undo.
   define input  parameter iParam as character no-undo.
   define input  parameter iformat as character no-undo.
   define output parameter oValueRet as character no-undo.
   define variable vValueInt as integer no-undo.
   define variable vLength as integer no-undo.
   define variable vFileName as character no-undo.
   define variable vKey      as character no-undo.
   if iTeg eq "obj-code"
   then oValueRet =  ApplyFormatDec(v-cntxt-obj-code,iformat).
   else if iTeg eq "obj-type"
   then oValueRet = ApplyFormatChar(v-cntxt-obj-type,iformat).
   else if iTeg eq "obj-altcode" then
      do:
         find first ub.clients-attr no-lock where ub.clients-attr.attr-code = "alter-code" and
                                                  ub.clients-attr.obj-code = v-cntxt-obj-code and
                                                  ub.clients-attr.obj-type = v-cntxt-obj-type no-error .
         if available (ub.clients-attr) then oValueRet = ub.clients-attr.attr-value .
      end.
   else if iTeg eq "obj-altcode or obj-code" then
      do:
         find first ub.clients-attr no-lock where ub.clients-attr.attr-code = "alter-code" and
                                                  ub.clients-attr.obj-code = v-cntxt-obj-code and
                                                  ub.clients-attr.obj-type = v-cntxt-obj-type no-error .
         if available (ub.clients-attr) then oValueRet = ub.clients-attr.attr-value .
         else oValueRet =  ApplyFormatDec(v-cntxt-obj-code,iformat).
      end.
   else if iTeg eq "obj-name"
   then do:
      find first ub.clients where ub.clients.obj-type = v-cntxt-obj-type
                              and ub.clients.obj-code = v-cntxt-obj-code
      no-lock no-error.
      if available ub.clients
      then
         oValueRet = ApplyFormatChar(ub.clients.obj-name,iformat).
   end.
   else if iTeg eq "firm-code"
   then do:
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output oValueRet
  )  .
      oValueRet = ApplyFormatChar(oValueRet,iFormat).
   end.
   else if     length (iTeg) > 0
           and trim(caps(iTeg),"N") eq ""
   then do:
        if num-entries (iparam,";") > 2
        then
           assign
              vFilename  = entry(1,iParam,";")
              vKey       = entry(2,iParam,";")
              iParam     = entry(3,iParam,";")
           .
        else if num-entries (iparam,";") > 1
        then do:
           if caps(entry(1,iParam,";")) eq "CURRENT"
           then
              assign
                 vFilename  = iFile-name
                 vKey       = iKey
           iParam     = entry(2,iParam,";").
        end.
        vValueInt = ?.
        publish "getCounter" (vFilename,vKey,iparam,output vValueInt).
        if vValueInt = ?
        then
           run utl/getnextcount.p (vFilename,vKey,if iparam ne "" and iparam ne ? then iparam else "counter", "" ,output vValueInt).
        if iformat ne ""
        then
           oValueRet = ApplyFormatDec (vValueInt,iFormat).
        else do:
           vLength = length (iTeg).
           oValueRet = string (vValueInt).
           if vLength > 1
           then do:
              oValueRet = string (vValueInt,fill("9",vLength)) no-error.
              if error-status:error
              then
                 message "Ошибка приведения тега " iteg " c Параметрами " iParam " к формату " fill("9",vLength) skip
                      error-status:get-message (1) "Формат проигнорирован."
                    view-as alert-box.
           end.
        end.
   end.
end.
define variable mi      as integer   no-undo.
define variable mPosBeg as integer   no-undo.
define variable mPosEnd as integer   no-undo.
define variable mLenBeg as integer   no-undo.
define variable mLenEnd as integer   no-undo.
define variable mTeg    as character no-undo.
define variable mValue  as character no-undo.
assign
   mLenBeg = length("[")
   mLenEnd = length("]")
.
   run gettegbegend in this-procedure (iMask, output mPosBeg, output mPosEnd).
block-teg:
do while mPosBeg > 0 or mPosEnd > 0:
   mi = mi + 1 .
   if mi > 20  then leave.
   if mPosBeg eq 0 or mPosEnd eq 0 or mPosBeg >= mPosEnd
   then do:
      message "Тег раньше закрыт чем открыт"
         view-as alert-box.
      leave block-teg.
   end.
   if mPosBeg eq 0 then leave block-teg.
   if mPosEnd - mPosBeg - mLenBeg > 0
   then do:
      mTeg = substring(iMask, mPosBeg + mLenBeg , mPosEnd - mPosBeg - mLenBeg  ).
      run ParsTeg in this-procedure (mTeg,output mValue).
   end.
   else
      assign
         mTeg = ""
         mValue  = ""
      .
   iMask = replace (iMask,"[" + mteg + "]",mValue).
   run gettegbegend in this-procedure (iMask, output mPosBeg, output mPosEnd).
end.
procedure gettegbegend:
   define input  parameter iMask    as character no-undo.
   define output parameter iTegBeg  as integer   no-undo.
   define output parameter iTegEnd  as integer   no-undo.
   define variable vttt as character no-undo.
   assign
      iTegBeg = index (iMask,"[")
      iTegEnd = index (iMask,"]")
   .
   vttt = substring(imask, iTegEnd - 2,2) no-error.
   if     iTegEnd > 2
      and substring(imask, iTegEnd - 2,2) eq "|" + '"'
   then
      iTegEnd = index (iMask,'"' + "]",iTegEnd) + 1.
end.
define variable ii as integer no-undo.
procedure parsTeg:
   define input  parameter iTeg   as character no-undo.
   define output parameter oValue as character no-undo.
   define variable vFormat  as character no-undo.
   define variable vParam   as character no-undo.
   define variable vTeg     as character no-undo.
   define variable vPosForm as integer   no-undo.
   define variable vValue   as character no-undo.
   vPosForm = num-entries(iTeg,"|").
   if vPosForm > 2
   then
      assign
         vformat = trim(entry(vPosForm,iTeg,"|"),'"')
         vParam  =      entry(2,iTeg,"|")
         vTeg    =      entry(1,iTeg,"|")
      .
   else if vPosForm > 1
   then
      assign
         vParam  =      entry(2,iTeg,"|")
         vTeg    =      entry(1,iTeg,"|")
      .
   else
      vTeg    = entry(vPosForm,iTeg,"|").
   run getTegValue (vTeg,vParam,vformat, output ovalue).
   if oValue eq ?
   then
      oValue = "?".
   else
      oValue = trim(oValue).
end.
oValue =  imask.
