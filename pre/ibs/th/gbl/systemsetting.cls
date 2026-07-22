using Progress.Lang.*.
block-level on error undo, throw.
class ibs.th.gbl.systemsetting inherits   ibs.th.gbl.sys.objth :
   define override public property vss-revision    as character no-undo init "$Revision:$":U get .
   define override public property vss-author      as character no-undo init "$Author:$":U get.
   define override public property vss-date        as character no-undo init "$Date:$":U get.
   define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
   define override public property vss-archive     as character no-undo init "$Archive:$":U get.
   define override public property vss-description as character no-undo init "Настройки разработчиков" get.
define variable vss-include-info0 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_testXML-node no-undo
    field xmh-key       as integer
    field xmhNodName    as character
    index pi is primary unique
        xmh-key
    index nnm
        xmhNodName
.
define temp-table temp_testXML-entity no-undo
    field xme-key       as integer
    field xmh-key       as integer
    field xmeEntName    as character
    field xmeEntValue   as character
    index pi is primary unique
        xme-key
    index enm
        xmh-key
        xmeEntName
.
define temp-table temp_testXML-atribut no-undo
    field xme-key       as integer
    field xmeAtrName    as character
    field xmeAtrValue   as character
    index pi is primary unique
        xme-key
        xmeAtrName
.
define variable mRoot  as character no-undo init "Root".
define stream xmldom-out.
define variable mverfile_text as character   no-undo.
define variable mverfile      as integer  no-undo.
define variable v-xmldom-key       as integer      no-undo.
define public property mTransaction  as logical init yes no-undo
   get.
   private set.
method public void   xmldom-clear ():
    define buffer buf_temp_testXML-node         for temp_testXML-node.
    define buffer buf_temp_testXML-entity       for temp_testXML-entity.
    define buffer buf_temp_testXML-atribut      for temp_testXML-atribut.
do
for buf_temp_testXML-node
  , buf_temp_testXML-entity
  , buf_temp_testXML-atribut
on error undo, return error
:
    empty temp-table buf_temp_testXML-node   .
    empty temp-table buf_temp_testXML-entity .
    empty temp-table buf_temp_testXML-atribut.
    assign
        v-xmldom-key = 0
        mTransaction = yes
    .
end.
end .
method public void xmldom-add(p-node-name      as character,
                               p-entity-name    as character,
                               p-entity-value   as character):
    define buffer buf_temp_testXML-node         for temp_testXML-node.
    define buffer buf_temp_testXML-entity       for temp_testXML-entity.
do
for buf_temp_testXML-node
  , buf_temp_testXML-entity
on error undo, return error
:
    find last buf_temp_testXML-node
    use-index pi no-error.
    if not available buf_temp_testXML-node
    then do:
        assign
            v-xmldom-key = 0
        .
    end.
    else do:
        assign
            v-xmldom-key = buf_temp_testXML-node.xmh-key
        .
    end.
    find last buf_temp_testXML-entity
    use-index pi
    no-error.
    if available buf_temp_testXML-entity
    then do:
        assign
            v-xmldom-key = max(v-xmldom-key,buf_temp_testXML-entity.xme-key)
        .
    end.
    find first buf_temp_testXML-node
         where buf_temp_testXML-node.xmhNodName = p-node-name
    no-error.
    if not available buf_temp_testXML-node
    then do:
        assign
            v-xmldom-key = v-xmldom-key + 1
        .
        create buf_temp_testXML-node.
        assign
            buf_temp_testXML-node.xmh-key    = v-xmldom-key
            buf_temp_testXML-node.xmhNodName = p-node-name
        .
    end.
    assign
        v-xmldom-key = v-xmldom-key + 1
    .
    create buf_temp_testXML-entity.
    assign
        buf_temp_testXML-entity.xme-key      = v-xmldom-key
        buf_temp_testXML-entity.xmh-key      = buf_temp_testXML-node.xmh-key
        buf_temp_testXML-entity.xmeEntName   = p-entity-name
        buf_temp_testXML-entity.xmeEntValue  = p-entity-value
    .
end.
end.
method public void  xmldom-save-next-level
   ( iKey         as integer,
   i-doc-handle as handle,
   i-row-handle as handle):
   define buffer buf_temp_testXML-entity       for temp_testXML-entity.
   define buffer temp_testXML-atribut          for temp_testXML-atribut.
   define variable v-field-handle  as handle           no-undo.
   define variable v-text-handle   as handle           no-undo.
   create x-noderef v-field-handle.
   create x-noderef v-text-handle.
   for each buf_temp_testXML-entity
      where buf_temp_testXML-entity.xmh-key = iKey
        and not buf_temp_testXML-entity.xmeEntName begins "#"
   on error undo, return error:
      i-doc-handle :create-node ( v-field-handle, buf_temp_testXML-entity.xmeEntName , "ELEMENT" ).
      for each temp_testXML-atribut where temp_testXML-atribut.xme-key eq buf_temp_testXML-entity.xme-key
      no-lock:
         v-field-handle:SET-ATTRIBUTE(temp_testXML-atribut.xmeatrName,temp_testXML-atribut.xmeAtrValue).
      end.
      i-row-handle :append-child ( v-field-handle ).
      i-doc-handle :create-node ( v-text-handle, buf_temp_testXML-entity.xmeEntValue, "TEXT" ).
      v-field-handle :append-child ( v-text-handle ).
      if buf_temp_testXML-entity.xmeEntValue eq ?  then buf_temp_testXML-entity.xmeEntValue = "unknown_value".
      v-text-handle :node-value = buf_temp_testXML-entity.xmeEntValue.
     xmldom-save-next-level(buf_temp_testXML-entity.xme-key, i-doc-handle,v-field-handle).
   end.
   delete object v-field-handle.
   delete object v-text-handle.
end.
method public void  xmldom-save(iType  as character):
   define variable result as memptr no-undo.
   xmldom-save(iType, output result).
end.
method public void  xmldom-save(iType  as character,
output result as memptr):
    define variable v-doc-handle    as handle           no-undo.
    define variable v-root-handle   as handle           no-undo.
    define variable v-row-handle    as handle           no-undo.
    define variable v-buf-handle    as handle           no-undo.
    define buffer buf_temp_testXML-node         for temp_testXML-node.
do
for buf_temp_testXML-node
on error undo, return error
:
    create x-document v-doc-handle.
    assign
        v-doc-handle :encoding = "windows-1251":U
    .
    create x-noderef v-root-handle.
    v-doc-handle :create-node ( v-root-handle, mRoot, "ELEMENT" ).
    v-doc-handle :append-child ( v-root-handle ).
    for each buf_temp_testXML-node where not buf_temp_testXML-node.xmhNodName begins "#"
    on error undo, return error
    :
        assign
            v-buf-handle = buffer buf_temp_testxml-node :handle
        .
        create x-noderef v-row-handle.
        v-doc-handle :create-node ( v-row-handle, buf_temp_testXML-node.xmhNodName, "ELEMENT" ).
        for each temp_testXML-atribut where temp_testXML-atribut.xme-key eq buf_temp_testXML-node.xmh-key
        no-lock:
           v-row-handle:SET-ATTRIBUTE(temp_testXML-atribut.xmeatrName,temp_testXML-atribut.xmeAtrValue).
        end.
        v-root-handle :append-child ( v-row-handle ).
        xmldom-save-next-level(buf_temp_testXML-node.xmh-key,v-doc-handle,v-row-handle).
        delete object v-row-handle.
    end.
    if    iType eq "file"
    then do:
       os-delete result.
       v-doc-handle :save ( iType, result ).
       output stream xmldom-out to value( result ) append.
       put stream xmldom-out unformatted chr(10).
       output stream xmldom-out close.
    end.
    else if iType eq "memptr"
    then
       v-doc-handle :save ( iType, result ).
    else
       v-doc-handle :save ( "file", iType ).
    delete object v-doc-handle.
    delete object v-root-handle.
end.
end .
method public logical  xmldom-load-atribut
   (IParent    as handle,
   iParentkey as integer
   ):
   def var vanames as char no-undo.
   def var vname as char no-undo.
   define buffer temp_testXML-atribut          for temp_testXML-atribut.
   def var vi      as integer  no-undo.
   vanames = IParent:ATTRIBUTE-NAMES.
   do vi = 1 TO NUM-ENTRIES(vanames):
      vname = ENTRY(vi, vanames).
      create temp_testXML-atribut.
      assign
         temp_testXML-atribut.xme-key     = iParentkey
         temp_testXML-atribut.xmeatrName  = vname
         temp_testXML-atribut.xmeAtrValue = IParent:GET-ATTRIBUTE(vname)
      .
   END.
end.
define variable m-xme-key       as integer      no-undo.
method public logical  xmldom-load-next-level
   (IParent    as handle,
   iParentkey as integer ,
   ifilever as int):
   define variable v-field-handle  as handle           no-undo.
   define variable v-text-handle   as handle           no-undo.
   define variable v-field-counter as integer          no-undo.
   define variable v-field-amount  as integer          no-undo.
   define variable vDateActive as date no-undo.
   define buffer buf_temp_testXML-entity       for temp_testXML-entity.
   create x-noderef v-field-handle.
   create x-noderef v-text-handle.
   assign
      v-field-amount = IParent :num-children
   .
   repeat v-field-counter = 1 to v-field-amount:
      IParent :get-child ( v-field-handle, v-field-counter ).
      if v-field-handle :num-children < 1
      then do:
         next.
      end.
      create buf_temp_testXML-entity.
      assign
         m-xme-key = m-xme-key + 1
         buf_temp_testXML-entity.xme-key     = m-xme-key
         buf_temp_testXML-entity.xmh-key     = iParentkey
      .
      v-field-handle :get-child ( v-text-handle, 1 ).
      if     IParent:name         eq "file-info"
         and v-field-handle :name eq "version"
      then do:
         mverfile = int(v-text-handle :node-value)no-error.
         if     ifilever ne ?
         then do:
            if  mverfile  eq ifilever
            then do:
               for each buf_temp_testXML-entity:
                  delete buf_temp_testXML-entity.
               end.
               return yes.
            end.
         end.
      end.
      else if     IParent:name         eq "file-info"
              and v-field-handle :name eq "DateActive"
      then do:
         vDateActive = date(v-text-handle :node-value)no-error.
         if     vDateActive ne ?
         then do:
            if  vDateActive  lt today
            then do:
               for each buf_temp_testXML-entity:
                  delete buf_temp_testXML-entity.
               end.
               return yes.
            end.
         end.
      end.
      else if     IParent:name         eq "file-info"
              and v-field-handle :name eq "NoTransaction"
      then do:
        mTransaction = no.
      end.
      assign
         buf_temp_testXML-entity.xmeEntName   = v-field-handle :name
         buf_temp_testXML-entity.xmeEntValue  = v-text-handle :node-value
      .
      if buf_temp_testXML-entity.xmeEntValue eq "unknown_value"  then buf_temp_testXML-entity.xmeEntValue = ?.
      xmldom-load-atribut(v-field-handle,buf_temp_testXML-entity.xme-key).
      xmldom-load-next-level (v-field-handle,buf_temp_testXML-entity.xme-key, ifilever ).
   end.
   delete object v-text-handle.
   delete object v-field-handle.
end.
method public character   xmldom-load-ver
 (i-full-filename    as character ,
   ifilever as integer ):
   define variable v-doc-handle    as handle           no-undo.
   define variable v-root-handle   as handle           no-undo.
   define variable v-table-handle  as handle           no-undo.
   define variable v-table-counter as integer      no-undo.
   define variable v-table-amount  as integer      no-undo.
   define buffer buf_temp_testXML-node         for temp_testXML-node.
   mverfile = ?.
   mverfile_text = ?.
   do
   for buf_temp_testXML-node
   on error undo, return error
   :
      assign
         i-full-filename = search( i-full-filename )
      .
      if i-full-filename = ?
      then do:
         undo, return "Загружаемый файл не найден.".
      end.
      create x-document v-doc-handle.
      v-doc-handle :encoding = "windows-1251":U.
      create x-noderef v-root-handle.
      create x-noderef v-table-handle.
      v-doc-handle :load ( "file", i-full-filename, true ) no-error.
      if    error-status :error
         or not valid-handle ( v-doc-handle )
         or v-doc-handle = ?
      then do:
         undo, return error vss-description + substitute( "Ошибка загрузки XML-файла &1", i-full-filename ).
      end.
      v-doc-handle :get-document-element ( v-root-handle ) no-error.
      if    error-status :error
         or not valid-handle ( v-root-handle )
         or v-root-handle = ?
      then do:
         undo, return error vss-description + substitute( "Ошибка чтения корневого тэга XML-файла &1", i-full-filename ).
      end.
      assign
         v-table-amount = v-root-handle :num-children
      no-error.
      if    error-status :error
         or v-table-amount = ?
      then do:
         undo, return error vss-description + substitute( ".&1Неверная структура XML-файла &2", chr(10), i-full-filename ).
      end.
      m-xme-key = v-table-amount +  1.
        repeat v-table-counter = 1 to v-table-amount:
         v-root-handle :get-child ( v-table-handle, v-table-counter ).
         create buf_temp_testXML-node.
         assign
            buf_temp_testXML-node.xmh-key       = v-table-counter
            buf_temp_testXML-node.xmhNodName    = v-table-handle :name
         .
         xmldom-load-atribut(v-table-handle,buf_temp_testXML-node.xmh-key).
         if xmldom-load-next-level (v-table-handle,buf_temp_testXML-node.xmh-key,ifilever)
         then do:
            for each buf_temp_testXML-node:
               delete buf_temp_testXML-node.
            end.
            undo, return "Данные уже загружены.".
         end.
      end.
      delete object v-root-handle.
      delete object v-doc-handle.
      return mverfile_text.
   end.
end .
method public void  xmldom-load (p-full-filename as character ):
 xmldom-load-ver(p-full-filename,?) .
end.
method public void  getEnties
(input  i-parkey      as integer ,
                                         input i-entity-name    as character ,
                                         output o-entity-value  as character,
                                         output o-found         as logical ):
    define variable v-entity-name       as character no-undo.
    define variable v-entity-name-next  as character no-undo.
    define buffer buf_temp_testXML-entity    for temp_testXML-entity.
    v-entity-name     = entry(1,i-entity-name).
    if num-entries(i-entity-name) > 1
    then
       assign
          v-entity-name-next =  substring (i-entity-name,length(v-entity-name) + 2)
       .
    find first buf_temp_testXML-entity
             where buf_temp_testXML-entity.xmh-key      = i-parkey
               and buf_temp_testXML-entity.xmeEntName   = v-entity-name
        no-error.
    if available buf_temp_testXML-entity
    then do:
       if v-entity-name-next eq ""
       then assign
          o-entity-value = buf_temp_testXML-entity.xmeEntValue
          o-found        = yes
       .
       else do :
           getEnties(buf_temp_testXML-entity.xme-key,v-entity-name-next,output o-entity-value,output o-found).
       end.
    end.
end .
method public void  xmldom-read-unique (input  i-node-name      as character,
                                         input i-entity-name    as character ,
                                         output o-entity-value  as character,
                                         output o-found         as logical ):
define variable v-entity-l1-name  as character no-undo.
define variable v-entity-l2-name  as character no-undo.
    define buffer buf_temp_testXML-node         for temp_testXML-node.
do
for buf_temp_testXML-node
on error undo, return error
:
    assign
        o-found = no
    .
    search-all-nodes:
    for each buf_temp_testXML-node
       where buf_temp_testXML-node.xmhNodName = i-node-name
    :
        getEnties(buf_temp_testXML-node.xmh-key,i-entity-name,output o-entity-value,output o-found).
   end.
end.
end .
   define public property PumpTxtRead as logical no-undo
   get.
   private set.
   define public property GetCashCurl as logical no-undo
   get.
   private set.
   define public property DeveloperMode as logical no-undo
   get.
   private set.
   define public property CrLogin as character no-undo
   get.
   private set.
   define public property CrPswd as character no-undo
   get.
   private set.
   define public property SystemKey as character no-undo
   get.
   private set.
   define public property PumpFile as character no-undo
   get.
   private set.
   define public property AsiFile as character no-undo
   get.
   private set.
   constructor public systemsetting (input ikey as character ):
      define variable vFilesetting as character no-undo.
      define variable vFound as logical no-undo.
      define variable vText as character no-undo.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile:currsysk.i $ $Revision: $".
run currsysk in ibs.th.gbl.gbl-hndllib:g#library
  (output SystemKey
  ) no-error .
      vFilesetting = SearchFile("ibs/th/gbl/systemsetting.xml").
      if      vFileSetting ne ?
          and (   ikey + "FpailVaZHdjRkjkM"
  eq "notpasword"
               or SystemKey eq 'ExpertekIBS':U)
      then do:
         xmldom-load(vFileSetting).
         xmldom-read-unique("settings","PumpTxtRead",output vText, output vFound).
         PumpTxtRead = logical(vText)no-error.
         xmldom-read-unique("settings","GetCashCurl",output vText, output vFound).
         GetCashCurl = logical(vText)no-error.
         xmldom-read-unique("settings","DeveloperMode",output vText, output vFound).
         DeveloperMode = logical(vText)no-error.
         xmldom-read-unique("settings","CrLogin",output CrLogin, output vFound).
         xmldom-read-unique("settings","CrPswd" ,output CrPswd , output vFound).
         xmldom-read-unique("settings","PumpFile" ,output PumpFile , output vFound).
         xmldom-read-unique("settings","AsiFile" ,output AsiFile , output vFound).
      end.
   end constructor.
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
end class.
