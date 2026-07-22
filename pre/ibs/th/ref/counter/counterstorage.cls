using Progress.Lang.*.
block-level on error undo, throw.
class ibs.th.ref.counter.counterstorage final:
   define temp-table tt-counter like ub.counter
   field oldname       as character
   field oldCountValue as int64
   field oldRule       as character
   field frecid        as int64 .
   define variable mQuery as handle no-undo.
   constructor public counterstorage (  ):
      super ().
      find first sys-ctrl no-lock .
   end constructor.
   destructor public counterstorage ( ):
   end destructor.
   method public handle getquery():
      empty temp-table tt-counter.
      if valid-handle(mQuery) then delete object mQuery.
      for each counter no-lock:
         create tt-counter.
         buffer-copy counter to tt-counter.
         assign
            tt-counter.oldCountValue = tt-counter.CountValue
            tt-counter.oldname       = tt-counter.name
            tt-counter.oldRule       = tt-counter.Rule
            tt-counter.frecid        = recid(counter)
         .
      end.
      create query mQuery.
      mQuery:set-buffers(buffer tt-counter:HANDLE).
      mQuery:query-prepare("FOR EACH tt-counter").
      mQuery:query-open ().
      return mQuery.
   end method.
   method public void saveChange():
      for each tt-counter where tt-counter.oldCountValue <> tt-counter.CountValue
                             or tt-counter.oldname       <> tt-counter.name
                             or tt-counter.oldRule       <> tt-counter.Rule
      no-lock:
         find first counter where recid(counter) eq tt-counter.frecid
            no-lock no-error.
         if     available counter
            and tt-counter.oldCountValue = counter.CountValue
            and tt-counter.oldname       = counter.name
            and tt-counter.oldRule       = counter.Rule
         then do:
            find current counter
               exclusive-lock no-error.
            if available counter
            then
               assign
                  counter.CountValue = tt-counter.CountValue
                  counter.name       = tt-counter.name
                  counter.Rule       = tt-counter.Rule
               .
         end.
         else
            message substitute("Запись '&1' кто-то уже изменил.",tt-counter.oldname)
            view-as alert-box.
      end.
   end method.
   define stream sReadfile.
method public int64 GetAsuncNextcount (iFileName as character , iKey as character,icode as character, iParam as character   ):
define variable oCount   as int64 no-undo init ?.
      define variable vAsyncHelper as class ibs.th.file.AsyncHelperth no-undo.
      define variable vText as character no-undo.
      define variable vlogfile as character no-undo.
      define variable vError as logical no-undo.
      if trans
      then do:
         vAsyncHelper = new ibs.th.file.AsyncHelperth().
         vAsyncHelper:setCurrentUserPasswd().
         vAsyncHelper:myTimeOut = 300.
         vAsyncHelper:AsyncProc("utl/proc-getnextcount", substitute("&1":U  +  chr(4)  + "&2":U + chr(4) + "&3":U , iFileName ,ikey, icode ),1).
         run ibs\th\file\waithelper.p (vAsyncHelper,"proc-getnextcount", 1,"Получаем значение счетчика.").
         vlogfile = vAsyncHelper:getlog(?).
         if vAsyncHelper:FileExists(vlogfile)
         then do:
            input stream sReadfile FROM  VALUE(vlogfile).
            repeat:
               import stream sReadfile unformatted vText.
               if vtext begins "error" then vError = yes.
               else do:
                  Ocount = int64(vText) no-error.
                  if error-status:error
                  then
                     vError = yes.
               end.
            end.
            input stream sReadfile close  .
            os-delete value(vlogfile).
          end.
          else
             vError = yes.
          vAsyncHelper:delworkdir().
          delete object vAsyncHelper.
       end.
       else
          vError = yes.
       if    vError
          or Ocount eq ?
          then do:
             define variable vCounterStor as class ibs.th.ref.counter.counterstorage.
             vCounterStor = new ibs.th.ref.counter.counterstorage().
             Ocount = vCounterStor:GetNextcount(iFileName , iKey,icode, iparam ).
             delete object vCounterStor.
          end.
     return Ocount.
   end.
   method public int64 GetNextcount(iFileName as character , iKey as character,icode as character, iParam as character   ):
      return GetNextcount(sys-ctrl.db-num,iFileName , iKey ,icode,iParam   ).
   end.
   method public int64 GetNextcount(idb as integer,iFileName as character , iKey as character,icode as character,iParam as character  ):
      define variable vValue     as character no-undo.
      define variable vNumPar    as integer   no-undo.
      define variable vInt       as integer   no-undo init ?.
      define variable vNextCount as integer   no-undo.
      define variable vYear      as integer   no-undo init ?.
      find first counter where counter.db        eq idb
                           and counter.file-name eq iFileName
                           and counter.key       eq iKey
                           and counter.code      eq iCode
         no-lock no-error.
      if available counter
      then do:
         if can-do(counter.Rule,"year")
         then do:
            vNumPar = lookup("year",counter.sysInfo).
            if vNumPar ne 0
            then do:
               assign
                  vValue = entry(vNumPar + 1,counter.sysInfo)
                  vInt = int(vValue)
               no-error.
               vNumPar = lookup("year",iParam).
               if vNumPar ne 0
               then do:
                  assign
                     vValue = entry(vNumPar + 1,counter.sysInfo)
                     vYear = int(vValue)
                  no-error.
               end.
               if vYear eq ?
               then
                  vYear = year(today).
               if     vint ne ?
                  and vint ne vYear
               then
                  vNextCount = 1.
               else
                  vNextCount = counter.CountValue + 1.
            end.
            else
               vNextCount = counter.CountValue + 1.
         end.
         else
            vNextCount = counter.CountValue + 1.
         find current counter exclusive-lock no-error no-wait.
         if not available counter
         then return ?.
      end.
      else do:
         create counter.
         assign
            vNextCount = 1
            counter.db        = idb
            counter.file-name = ifilename
            counter.key       = ikey
            counter.code      = icode
            counter.name = substitute("Счетчик для '&1' с ключем '&2' и кодом '&3'",ifilename,ikey,icode).
         .
         if ifilename eq "cashbookrule"
         then
            assign
               counter.Rule = "year".
      end.
      assign
         counter.CountValue = vNextCount
         counter.sysInfo    = substitute("year,&1",string(year(today)))
      .
      return counter.CountValue.
   end method.
   method public int64 GetCountValue(idb as integer , iFileName as character , iKey as character,icode as character  ):
      find first counter where counter.db        = idb
                           and counter.file-name eq iFileName
                           and counter.key       eq iKey
                           and counter.code      eq iCode
         no-lock no-error.
      return if available counter then counter.CountValue else 0 .
   end.
   method public int64 SetCountValue(iFileName as character , iKey as character,icode as character, iValue as int64  ):
      SetCountValue(sys-ctrl.db-num, iFileName , iKey ,icode , iValue ).
   end.
   method public void SetCountValue(iDB as integer, iFileName as character , iKey as character,icode as character, iValue as int64  ):
      find first counter where counter.db        = idb
                           and counter.file-name eq iFileName
                           and counter.key       eq iKey
                           and counter.code      eq iCode
         exclusive-lock no-error.
      if not available counter
      then do:
         create counter.
         assign
            counter.db        = idb
            counter.file-name = ifilename
            counter.key       = ikey
            counter.code      = icode
            counter.name = substitute("Счетчик для '&1' с ключем '&2' и кодом '&3'",ifilename,ikey,icode).
         .
         if ifilename eq "cashbookrule"
         then
            assign
               counter.Rule = "year".
      end.
      assign
      counter.CountValue = iValue
      counter.sysInfo    = substitute("year,&1",string(year(today))).
   end.
end class.
