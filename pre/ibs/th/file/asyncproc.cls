using Progress.Lang.*.
block-level on error undo, throw.
class ibs.th.file.asyncproc:
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
method private logical cur-time (output p-today as date,
                                 output p-time  as integer ):
  do
  on error undo, return error
  :
    define variable v-date1 as date      no-undo .
    define variable v-date2 as date      no-undo .
    define variable v-time  as integer   no-undo .
    assign
      v-date1 = today
      v-time  = time
      v-date2 = today
    .
    if v-date1 <> v-date2
    then do:
      assign
        v-date1 = today
        v-time  = v-time
      .
    end.
    assign
      p-today = v-date1
      p-time  = v-time
    .
  end.
end.
method private character  cur-time-date ()
:
  return string(today, '99/99/9999':U) .
end.
method private decimal cur-time-mjd ()
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  cur-time
    (output v-date
    ,output v-time
    ) .
  return integer(v-date) - 2400002 + (v-time / 86400) .
end.
method private integer cur-time-get-ending-index
(input p-number as integer
)
:
  if p-number < 0
  or p-number = ?
  then do:
    return 1 .
  end.
  define variable v-rest as integer   no-undo .
  assign
    p-number = p-number modulo 100
  .
  if p-number < 20
  then do:
    assign
      v-rest = p-number
    .
  end.
  else do:
    assign
      v-rest = p-number modulo 10
    .
  end.
  case v-rest :
    when 1
    then do:
      return 2 .
    end.
    when 2 or
    when 3 or
    when 4
    then do:
      return 3 .
    end.
    otherwise do:
      return 1 .
    end.
  end case .
end.
method private character cur-time-mjd-to-date(
  input  i-mjd-diff as decimal
,output  o-Date     as date
,output  o-Time     as integer):
   define variable v-day-number as integer   no-undo .
   if    i-mjd-diff < 0
      or i-mjd-diff = ?
   then do:
      return "?" .
   end.
   assign
      v-day-number = truncate(i-mjd-diff,0).
      o-Date = date(v-day-number + 2400002).
      o-Time = truncate((i-mjd-diff - v-day-number) * 86400, 0)
  .
end.
method private character cur-time-mjd-to-string
(input p-mjd-diff as decimal
)
:
  define variable v-day-number as integer   no-undo .
  define variable v-seconds    as integer   no-undo .
  define variable v-hour       as integer   no-undo .
  define variable v-min        as integer   no-undo .
  define variable v-day-name    as character no-undo extent 3 initial [   "дней",    "день",     "дня" ] .
  define variable v-hour-name   as character no-undo extent 3 initial [  "часов",     "час",    "часа" ] .
  define variable v-min-name    as character no-undo extent 3 initial [  "минут",  "минута",  "минуты" ] .
  define variable v-second-name as character no-undo extent 3 initial [ "секунд", "секунда", "секунды" ] .
  if p-mjd-diff < 0
  or p-mjd-diff = ?
  then do:
    return "?" .
  end.
  assign
    v-day-number = integer(truncate(p-mjd-diff,0))
    v-seconds    = truncate((p-mjd-diff - v-day-number) * 86400, 0)
  .
  if v-seconds > 86400
  then do:
    assign
      v-seconds = 86400 - 1
    .
  end.
  if v-seconds < 0
  then do:
    assign
      v-seconds = 0
    .
  end.
  assign
    v-hour = truncate(v-seconds / 3600, 0)
  .
  assign
    v-seconds = v-seconds modulo 3600
  .
  assign
    v-min = truncate(v-seconds / 60, 0)
  .
  assign
    v-seconds = v-seconds modulo 60
  .
  return
      (if v-day-number <> 0
        then string(v-day-number) + " " + v-day-name[cur-time-get-ending-index(v-day-number)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0
        then string(v-hour) + " " + v-hour-name[cur-time-get-ending-index(v-hour)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0 or v-min <> 0
        then string(v-min) + " " + v-min-name[cur-time-get-ending-index(v-min)] + " "
        else ""
      )
    + string(v-seconds) + " " + v-second-name[cur-time-get-ending-index(v-seconds)]
    .
end.
method private character cur-time-string ()
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  cur-time
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM':U) .
end.
method private character cur-time-string-sec ()
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  cur-time
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM:SS':U) .
end.
method private character cur-time-custom
(input p-prefix as character
,input p-date-format as character
,input p-delimiter as character
,input p-time-format as character
,input p-suffix as character
)
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  cur-time
    (output v-date
    ,output v-time
    ) .
  return
    p-prefix
    + string(v-date, p-date-format)
    + p-delimiter
    + string(v-time, p-time-format)
    + p-suffix
    .
end.
method private character cur-time-print ()
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  cur-time
    (output v-date
    ,output v-time
    ) .
  return "Дата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
end.
method private datetime cur-time-datetime ()
:
  define variable v-char as character no-undo .
  define variable v-datetime as datetime no-undo .
  v-char = cur-time-string().
  v-datetime = datetime(v-char).
  return  v-datetime.
end.
method private character cur-time-string-msec ()
:
  define variable v-date as datetime  no-undo .
  v-date = now.
  return string(v-date) .
end.
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
      os-rename value(vfile) value ("meslogasync.log" + string(mWriteLogNum)).
      if     ErrorProc
         and log-manager:logfile-name ne ?
      then do:
      mWriteLogNum = mWriteLogNum + 1.
      os-delete             value ("meslogasync.log" + string(mWriteLogNum)).
      vfile = search (log-manager:logfile-name).
      os-command value (substitute ("copy &1 meslogasync.log&2 > copy.log &3 Exit",vFile,string(mWriteLogNum),chr(38)) ).
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
      os-command value(substitute ("copy &1 meslogasync.log&2 > copy.log &3 Exit",iFile,string(mWriteLogNum),chr(38)) ).
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
      Writefile("procstatus.txt", vtext + chr(10)).
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
      Writefile("procinfo.txt", substitute("&1~001&2~001&3~001&4&5",vMyPID ,iAllobj,iProcnum,iAllproc,chr(10))).
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
      method public character  SetGblError (input itext as character ):
      putmes (itext).
      if  log-manager:logfile-name ne ?
      then
         put unformatted (substitute ("#### Error Read ClientLog #### :&1",searchfile (log-manager:logfile-name)))  skip.
   end.
   method public logical CheckParam ():
      return FileExists("param.txt").
   end.
         define variable mxmlParam as longchar no-undo init "".
   method public  void SavePARAM ( input iName as char, input iValue as char ):
      if iName eq ?
      then
         mxmlParam = "".
      else
         mxmlParam = mxmlParam + substitute ("&1&2&3&4&5",
                                            SUBSTITUTE("<PARAM name='&1'>", iName),
                                            iValue,
                                            SUBSTITUTE("</PARAM name='&1'>", iName),
                                            chr(13),
                                            chr(10)
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
      vFrom = index(mxmlParam, SUBSTITUTE("<PARAM name='&1'>", iName)).
      if vFrom <= 0 then return paramObj.
      assign
         vTo = index(mxmlParam, SUBSTITUTE("</PARAM name='&1'>", iName))
         vFrom = vFrom + LENGTH(SUBSTITUTE("<PARAM name='&1'>", iName)).
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
method public character objExists
(input  ifolder as character,
 input  iType   as character  ):
    define variable vFileType as character no-undo init "D,F".
    define variable vi        as integer no-undo.
    define variable vtype as character no-undo.
    if iType ne ?
    then
       vFileType = iType.
    do vi = 1 to num-entries(vFileType):
       file-information:file-name = ".\" + right-trim(replace(ifolder,"/","\"),"\").
       vtype = file-information:file-type.
       if entry(num-entries(file-information:file-name, "\"), file-information:file-name, "\")
          = entry(num-entries(file-information:full-pathname, "\"), file-information:full-pathname ,"\") and
          index(vtype , entry(vi,vFileType )) > 0
       then return file-information:full-pathname .
       file-information:file-name = right-trim(replace(ifolder,"/","\"),"\").
       vtype = file-information:file-type.
       if file-information:file-name <> "" and
          entry(num-entries(file-information:file-name, "\"), file-information:file-name, "\")
          = entry(num-entries(file-information:full-pathname, "\"), file-information:full-pathname ,"\") and
          index( vtype, entry(vi,vFileType )) > 0
       then return file-information:full-pathname .
    end.
    return ? .
end.
method public character SearchFile
(input  ifile as character):
   return objExists(ifile,?).
end.
method public character SearchPFile
(input inFile as char):
     define variable oFile       as character no-undo.
     define variable vFileSearch as character no-undo.
     define variable vNumEntry   as integer no-undo.
     if inFile = "" then return ?.
     vNumEntry = num-entries(inFile,".").
     vFileSearch = inFile.
     if    vNumEntry > 0
        and (   entry(vNumEntry,inFile,".") eq "p"
             or entry(vNumEntry,inFile,".") eq "w")
     then do:
        entry(vNumEntry,vFileSearch, ".") = "r".
        oFile = search(vFileSearch ).
        if oFile eq ?
        then
           oFile = search(inFile).
     end.
     else
        oFile = search(vFileSearch).
     return oFile.
  end.
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
