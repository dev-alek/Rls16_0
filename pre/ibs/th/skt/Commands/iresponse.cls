using ibs.th.gbl.collection.paramCol.
using ibs.th.skt.Commands.ICommandStatus.
block-level on error undo, throw.
class ibs.th.skt.Commands.IResponse abstract:
   define public variable STSlist as class ICommandStatus no-undo.
   define public property ParamWait as class paramCol no-undo
   get.
   set.
   constructor public IResponse (  ):
      super ().
      STSlist   = new ICommandStatus().
      ParamWait = new paramCol().
   end constructor.
   define public property condition as char no-undo
   get.
   set(arg as char):
      if STSlist:GetProp(arg) ne STSlist:Unknow
      then
         condition = arg.
   end.
   define public property Content-Type as character  no-undo init "text/html; charset=UTF-8"
   get.
   set.
   define public property content-disposition as character  no-undo
   get.
   set.
  define public property content-Md5 as character  no-undo
  get.
  set.
   define public property saveFile as character  no-undo
   set (arg as char):
      content-disposition = substitute ('attachment; filename="&1"',arg).
   end.
   define public property ContentLongChar as longchar no-undo
   get.
   private set .
   define public property ConvertPage as character  no-undo
   get.
   set(arg as char):
      ConvertPage = arg.
      if arg begins "windows-"
      then
         arg = substring (arg,9).
      FIX-CODEPAGE(ContentLongChar) = arg.
   end.
   define public property Content as memptr no-undo
   get.
   set(arg as memptr):
      Content = arg.
   end.
   define public property ContentLength as int64 no-undo
   get : return get-size(Content)
   .
   end.
   method public void setContent(arg as longchar ):
      setContent(arg, false).
   end.
   method public void setContent(arg as longchar, saveOrigin as logical ):
      set-size(Content) = 0.
      ContentLongChar = arg.
      set-size(Content) = 1.
      if ConvertPage eq ""
      then
         copy-lob
         from object arg
         to object Content.
      else do:
         define variable pagecode as character no-undo.
         if ConvertPage begins "windows-"
         then
            pagecode = substring (ConvertPage,9).
         else
            pagecode = ConvertPage.
         copy-lob
         from object ContentLongChar
         to object Content
         convert target codepage pagecode.
      end.
   end.
   method public void setContent(arg as char ):
      setContent(arg, false).
   end.
   method public void setFile(arg as char ):
      setFile(arg,"").
   end.
   method public void setFile(arg as char,iparam as char ):
      define variable vtype    as character no-undo.
      define variable vConType as character no-undo.
      define variable vRas     as character no-undo.
      file-information:file-name =  arg.
      vtype = file-information:file-type.
      if    file-information:file-name eq ""
         or vtype eq ?
         or index( vtype, "F") = 0
      then do:
         file-information:file-name = "cmp/" + arg.
         vtype = file-information:file-type.
         if    file-information:file-name eq ""
            or vtype eq ?
            or index( vtype, "F") = 0
         then
            file-information:file-name = "cmp/dontknow.jpg".
      end.
      vRas = entry(2,file-information:file-name,".").
      case vRas:
         when "icon" then vConType = "image/vnd.microsoft.icon".
         when "jpg"  then vConType = "image/jpeg".
         when "jpeg" then vConType = "image/jpeg".
         when "png"  then vConType = "image/png".
         when "txt"
      or when "xml"  then vConType = "text/xml".
         when "json" then vConType = "application/json".
         when "html" then vConType = "text/html".
         otherwise vConType = "raw".
      end.
      set-size(Content) = 0.
      run gbl/md5.p (
          input  file-information:full-pathname
         ,output content-Md5
         ) .
      set-size(Content) = file-information:file-size + 1.
      copy-lob from file file-information:full-pathname to Content.
      Content-Type = vConType.
      if iparam = "savefile"
      then do:
         define variable vSaveFile  as character no-undo.
         define variable vpos       as integer no-undo.
         vSaveFile = replace (file-information:file-name,"\","/").
         vpos = index(vSaveFile,"/").
         vSaveFile = substring (vSaveFile,vpos + 1).
         vSaveFile = replace (vSaveFile,"/","_").
         saveFile = vSaveFile.
      end.
   end.
        destructor public IResponse ( ):
           define variable vFiles as character no-undo.
           define variable vi     as integer no-undo.
           vFiles = paramWait:getParamValue("DeleteFile").
           if vFiles ne ?
           then do vi = 1 to num-entries(vFiles):
              os-delete value(entry(vi,vFiles)) recursive.
           end.
           delete object ParamWait.
           set-size(Content) = 0.
           delete object STSlist.
        end destructor.
end class.
