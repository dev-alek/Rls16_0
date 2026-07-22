 
 /*------------------------------------------------------------------------
    File        : asyncproc
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : Daru
    Created     : Sat Sep 16 11:35:50 MSK 2023
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
block-level on error undo, throw.


class ibs.th.file.asyncproc: 
   { cmp/str-glbl.i class}
   { gbl/cur-time.i}
   define temp-table tt-Param no-undo
       field nameParam as character 
       field objParam  as Progress.Lang.Object
   index nameParam nameParam.
    
    
   define variable mWriteLogTime  as datetime-tz no-undo.
   define variable mWriteLogNum   as integer     no-undo.
   define variable mWriteLogMes   as logical     no-undo.
   define public variable WritelogInter as decimal no-undo init 0.
   define public variable mProcPublish as handle     no-undo.
   
   define public variable ErrorProc    as logical    no-undo.
   
   method public logical CheckStop ():
      NextLog().
      return not FileExists("stop.txt").
   end. 
   
   method public logical NextLog():
      nextLog(no).
   end.
   
   define stream sLogMes. 
   define stream sWriteFile.
   define variable vWritelog as logical no-undo.
   method public logical BegRec():
      output stream sLogMes to "meslogasync.log".
      vWritelog = yes.
   end.
   
   method public logical EndRec():
      vWritelog = no.
      output stream sLogMes close.
      mWriteLogNum = mWriteLogNum + 1.
      os-delete             value ("meslogasync.log" + string(mWriteLogNum)).
      define variable vfile as character no-undo.
      vfile = search ("meslogasync.log").
/*      os-command value (substitute ("rename &1 &1&2",vfile,  string(mWriteLogNum))).*/
      os-rename value(vfile) value ("meslogasync.log" + string(mWriteLogNum)).
      if     ErrorProc 
         and log-manager:logfile-name ne ?
      then do:
      
      mWriteLogNum = mWriteLogNum + 1.
      os-delete             value ("meslogasync.log" + string(mWriteLogNum)).
      vfile = search (log-manager:logfile-name).
/*      os-command value (substitute ("rename &1 &1&2",vfile,  string(mWriteLogNum))).*/
      os-command value (substitute ("copy &1 meslogasync.log&2 > copy.log &3 Exit",vFile,string(mWriteLogNum),{&ampersand}) ).
      end.
   end.
   method public logical NextLog(iFlagInter as logical):
      define variable vend    as datetime-tz no-undo.
      define variable vint as int64 no-undo.
      if     mWriteLogMes
         and (WritelogInter > 0 or iFlagInter)
      then do:
         vend   = getnow().
         vint = vend - mWriteLogTime.
         vint = WritelogInter - vint / 1000.
         if     vint < 0
             or iFlagInter
         then do:
            output stream sLogMes close.
            mWriteLogNum = mWriteLogNum + 1.
            os-delete             value ("meslogasync.log" + string(mWriteLogNum)).
            os-rename "meslogasync.log" value ("meslogasync.log" + string(mWriteLogNum)).
            output stream sLogMes to "meslogasync.log".
            assign
               mWriteLogTime = getnow()
               mWriteLogMes  = no
            .
            
         end.
      end.
   end.
   
   method public logical NextLog(iFile as char):
      NextLog(yes).
      mWriteLogNum = mWriteLogNum + 1.
      os-delete            value ("meslogasync.log" + string(mWriteLogNum)).
      os-command value(substitute ("copy &1 meslogasync.log&2 > copy.log &3 Exit",iFile,string(mWriteLogNum),{&ampersand}) ).
            
/*      os-copy value() value ("meslogasync.log" + ).*/
   
   end.
   
   method public void putStatus (itext as character ):
      putStatus (itext,no).
   end.
   
   define variable putStatusText as character no-undo.
   
   method public void putStatus (itext as character, iAdd as logical ):
      define variable vText as character no-undo.
      if iAdd 
      then
         vText = putStatusText + " " + iText.
      else assign
         putStatusText = iText
         vtext         = iText
      .
      os-delete VALUE ("procstatus.txt").
      Writefile("procstatus.txt", vtext + {&new-line}).
      NextLog().
   end.
   
   method public datetime-tz getnow():
      return datetime-tz(cur-time-string-sec()).
   end.
    
   method public datetime-tz getnowday():
      return datetime-tz(today).
   end.
   
   method public void  creatProcInfo (input iAllobj as integer,iProcnum as integer,iAllproc as integer   ):
       define variable vMyPid as int64 no-undo.
      run utl/getpid.p (output vMyPid) no-error.
      Writefile("procinfo.txt", substitute("&1~001&2~001&3~001&4&5",vMyPID ,iAllobj,iProcnum,iAllproc,{&new-line})).
      mWriteLogTime = getnow().
   end method.
   
   method public logical myProcInfo():
      
      return FileExists("procinfo.txt").
   end.
        
   method public logical PutMes 
     (input Itext as character  ):
      PutMes(Itext,yes).
   end.

   method public logical PutMes 
     (input Itext as character ,
      input IFlagtime as logical):
      if Itext begins "error"
      then
         ErrorProc = yes.
      if IFlagtime
      then do:
         put stream sLogMes unformatted substitute ("&1 &2",cur-time-string-sec(), Itext) skip .
         if Itext begins "error"
         then
            put stream sLogMes unformatted "ERROR Произошла ошибка во время выполнения." skip.
      end.
      else
         put stream sLogMes unformatted Itext skip .
      mWriteLogMes = yes.
      NextLog().
   end.
   
   &glob errstoptext #### Error Read ClientLog #### :
   method public character  SetGblError (input itext as character ):
      putmes (itext).
      
      if  log-manager:logfile-name ne ?
      then
         put unformatted (substitute ("{&errstoptext}&1",searchfile (log-manager:logfile-name)))  skip.
   end.
   
   method public logical CheckParam ():
      return FileExists("param.txt").
   end.
   
   &GLOBAL-DEFINE PARAM-BEG-TAG SUBSTITUTE("<PARAM name='&1'>", iName)
   &GLOBAL-DEFINE PARAM-END-TAG SUBSTITUTE("</PARAM name='&1'>", iName)
   define variable mxmlParam as longchar no-undo init "".
   method public  void SavePARAM ( input iName as char, input iValue as char ):
      if iName eq ?
      then
         mxmlParam = "".
      else
         mxmlParam = mxmlParam + substitute ("&1&2&3&4&5",
                                            {&PARAM-BEG-TAG},
                                            iValue,
                                            {&PARAM-END-TAG},
                                            {&carriage-return}, 
                                            {&new-line}
         ). 
   end method.
   
   method public  void  SavefilePARAM (ifile as character ):
      define variable vLob as longchar no-undo.
      run utl\filecrypchar.p(mxmlParam,
                            "sysadmasync",
                            yes,
                            output vLob
                            ).
      copy-lob vLob to file ifile no-error.
         
   end.
   
   method public ibs.th.file.asyncparam GetPARAM (  input iName as char ):
      return GetPARAM("param.txt",iName).
   end.
   
   method public char GetPARAM (  input iNum as integer ):
      define variable vresult as ibs.th.file.asyncparam no-undo.
      vresult = GetPARAM("param.txt","ParamProc_" + string(iNum)).
      return vresult:valueParam.
   end.
   
   method public ibs.th.file.asyncparam GetPARAM ( input iFile as char, input iName as char ):
      def var vLob  as longchar no-undo.
      def var vFrom as int64    no-undo.
      def var vTo   as int64    no-undo.
      def var vParInt as integer no-undo.
      define variable paramObj as ibs.th.file.asyncparam no-undo. 
      vParInt = int(iname) no-error.
      if not error-status:error
      then
         iname = "ParamProc_" + string(vParInt).
      paramObj = getParamObj(iname).
      if paramObj:valueParam eq ? and mxmlParam eq ""
      then do:
         if not FileExists (iFile) then return ?.
         copy-lob file iFile to vLob no-error.
         run utl\filecrypchar.p(vLob,
                            "sysadmasync",
                            no,
                            output mxmlParam
                            ).
      end.
      vFrom = index(mxmlParam, {&PARAM-BEG-TAG}).
      if vFrom <= 0 then return paramObj.
      assign
         vTo = index(mxmlParam, {&PARAM-END-TAG})
         vFrom = vFrom + LENGTH({&PARAM-BEG-TAG}). 
      if vTo < vFrom then return paramObj.
      paramObj:valueParam = string(substring(mxmlParam, vFrom, vTo - vFrom)).
      return paramObj.
   end method.
   
   method ibs.th.file.asyncparam getParamObj (iName as character ):
        find first tt-Param where tt-Param.nameParam eq iName no-lock no-error.
        if not available tt-Param
        then do:
            create tt-Param.
            assign 
               tt-Param.nameParam = iName
            .
            tt-Param.objParam  = new ibs.th.file.asyncparam(iName).
        end.
        return cast (tt-Param.objParam,ibs.th.file.asyncparam).
   end. 
      
   constructor public asyncproc (  ):
      super ().
      
   end constructor.

   destructor public asyncproc ( ):
      for each tt-Param:
          delete object tt-Param.objParam.
      end.
      empty temp-table tt-Param.
      
   end destructor.
   
   {utl/search.i class} 
   method public logical FolderExists  (input  ifolder as character ):
      return objExists(ifolder,"D") ne ?.
   end. 
   method public logical FileExists  (input  ifolder as character ):
      return objExists(ifolder,"F") ne ?.
   end.
   method public logical  objExists  (input  ifile as character):
      return    (objExists(ifile,"D") ne ?) or ( objExists(ifile,"F") ne ?) .                                  
   end.
   
   method public char Writefile (ifile as character ,itext as character):
      define variable vFile       as character no-undo. 
      define variable vNameFolder as character no-undo.
      define variable vFileName   as character no-undo.
      define variable vNum        as integer   no-undo.
 
      if itext eq ""
      then do:
        if ifile <> ? then 
          /* проверяем, что есть такой каталог */
         if num-entries(ifile,"\") > 1 or 
            num-entries(ifile,"/") > 1 
         then do:
           vFile = replace(ifile,"/","\").  
           vFileName = entry(num-entries(vFile,"\"),vFile,"\").
           vNum = index(vFile,vFileName) - 1.   
           vNameFolder = substring(vFile, 1, vNum). 
           if not FolderExists(vNameFolder) then do:                
               if vWritelog
               then
                  putmes (substitute ("Не удалось записать файл &1 : Не найден рабочий каталог &2 ",ifile,vNameFolder)).
               else
                  return substitute ("Не удалось записать файл &1 : Не найден рабочий каталог &2 ",ifile,vNameFolder).
           end.    
         end. 
         output stream sWriteFile to value(ifile).
         output stream sWriteFile close.
      end.
      else do:
      run gbl/fileapnd.p (
          input ifile
        , input itext
        , input 3
    ) no-error.
    if error-status :error
    then do:
       if vWritelog
       then
          putmes (substitute ("Не удалось записать файл &1 : &2 ",ifile,return-value)).
       else
          return substitute ("Не удалось записать файл &1 : &2 ",ifile,return-value).
    end.
    end.
    return "".
   end.   
end class.