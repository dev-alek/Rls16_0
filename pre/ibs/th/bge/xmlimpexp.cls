using Progress.Lang.*.
block-level on error undo, throw.
class ibs.th.bge.xmlimpexp final:
   define variable vss-revision    as character no-undo init "$Revision:$":U .
   define variable vss-author      as character no-undo init "$Author:$":U .
   define variable vss-date        as character no-undo init "$Date:$":U .
   define variable vss-workfile    as character no-undo init "$Workfile:$":U .
   define variable vss-archive     as character no-undo init "$Archive:$":U .
   define variable vss-description as character no-undo init "".
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
   define variable objKeyRec as ibs.th.gbl.keyrec no-undo.
   define variable iAll as logical no-undo.
   define variable iDopInfo as logical no-undo.
   constructor public xmlimpexp (  ):
      super ().
      objKeyRec = new ibs.th.gbl.keyrec().
   end constructor.
   destructor public xmlimpexp ( ):
       delete object objKeyRec.
   end destructor.
   method public void  savecode():
      define variable hQuery   as handle  no-undo .
      define buffer Buf_code for code.
      create query hQuery.
      hQuery:set-buffers(buffer Buf_code :HANDLE).
      hQuery:query-prepare("FOR EACH Buf_code ").
      hQuery:query-open ().
      updatetableforxml(hQuery).
      delete object hQuery.
   end.
   method public void repspecTableforXml (ilog as logical):
      define buffer buf_XML-entity for temp_testXML-entity.
      if ilog
      then
      for each buf_XML-entity:
         buf_XML-entity.xmeEntName= replace (buf_XML-entity.xmeEntName,"#","CHRgriidCHR").
      end.
      else
         for each buf_XML-entity:
            buf_XML-entity.xmeEntName= replace (buf_XML-entity.xmeEntName,"CHRgriidCHR","#").
         end.
   end.
   method public void updatetableforxml(ihandle as handle):
      define variable vBuffer as handle no-undo.
      define variable hField  as handle no-undo.
      define variable VTableName as character no-undo.
      define variable vNodeName as character no-undo.
      define variable vItem as integer no-undo.
      define buffer buf_XML-node   for temp_testXML-node.
      define buffer buf_XML-entity for temp_testXML-entity.
      define buffer buf_XML-field for temp_testXML-entity.
      define buffer buf_XML-atribut for temp_testXML-atribut.
      if iDopInfo
      then do:
      vNodeName = "File-info".
      find first buf_XML-node
          where buf_XML-node.xmhNodName = vNodeName
      no-error.
      if not available buf_XML-node
      then do:
         assign
            v-xmldom-key = v-xmldom-key + 1
         .
         create buf_XML-node.
         assign
            buf_XML-node.xmh-key    = v-xmldom-key
            buf_XML-node.xmhNodName = vNodeName
         .
         assign
            v-xmldom-key = v-xmldom-key + 1
            vNodeName = "version"
         .
         create buf_XML-entity.
         assign
            buf_XML-entity.xme-key      = v-xmldom-key
            buf_XML-entity.xmh-key      = buf_XML-node.xmh-key
            buf_XML-entity.xmeEntName   = vNodeName
            buf_XML-entity.xmeEntValue  = "000"
         .
         assign
            v-xmldom-key = v-xmldom-key + 1
            vNodeName = "DateActive"
         .
         create buf_XML-entity.
         assign
            buf_XML-entity.xme-key      = v-xmldom-key
            buf_XML-entity.xmh-key      = buf_XML-node.xmh-key
            buf_XML-entity.xmeEntName   = vNodeName
            buf_XML-entity.xmeEntValue  = "01.01.2100"
         .
      end.
      end.
      define variable vHQry as handle no-undo.
      if ihandle:type eq "temp-table"
      then do:
         vBuffer = ihandle:default-buffer-handle.
         create query  vHQry.
         vhQry:set-buffers (vBuffer).
         vHQry:query-prepare ("FOR EACH " + vBuffer:name + "  NO-LOCK").
         vHQry:query-open ().
         vHQry:get-first().
         VTAbleName = vBuffer:serialize-name.
      end.
      else if ihandle:type eq "query"
      then do:
         vHQry = ihandle.
         vHQry:get-first().
         vBuffer = ihandle:get-buffer-handle ().
         VTAbleName = vBuffer:table.
      end.
      else
         return error "Данный тип handle не поддерживается поддерживается только temp-table и query".
      if not vHQry:query-off-end
      then do:
         vNodeName = "table-" + VTAbleName.
         find first buf_XML-node
              where buf_XML-node.xmhNodName = vNodeName
         no-error.
         if not available buf_XML-node
         then do:
            assign
               v-xmldom-key = v-xmldom-key + 1
            .
            create buf_XML-node.
            assign
               buf_XML-node.xmh-key    = v-xmldom-key
               buf_XML-node.xmhNodName = vNodeName
            .
            if iDopInfo
            then do:
            create buf_XML-atribut.
            assign
               buf_XML-atribut.xme-key      = v-xmldom-key
               buf_XML-atribut.xmeAtrName   = "NwsNotSend"
               buf_XML-atribut.xmeAtrValue  = "TableList"
            .
            end.
         end.
         vNodeName = "record-" + VTAbleName.
      end.
      do while not vHQry:query-off-end:
         assign
            v-xmldom-key = v-xmldom-key + 1
         .
         create buf_XML-entity.
         assign
            buf_XML-entity.xme-key      = v-xmldom-key
            buf_XML-entity.xmh-key      = buf_XML-node.xmh-key
            buf_XML-entity.xmeEntName   = vNodeName
            buf_XML-entity.xmeEntValue  = ""
         .
         if iDopInfo
         then do:
         create buf_XML-atribut.
            assign
            buf_XML-atribut.xme-key      = v-xmldom-key
            buf_XML-atribut.xmeAtrName   = "record-delete"
            buf_XML-atribut.xmeAtrValue  = "no"
         .
         end.
         block-field:
         do vItem = 1 to vBuffer:num-fields:
            assign hField = vBuffer:buffer-field(vItem) .
           if not iAll and hField:buffer-value eq hField:initial then next block-field.
            v-xmldom-key = v-xmldom-key + 1.
            create buf_XML-field.
               assign
               buf_XML-field.xme-key      = v-xmldom-key
               buf_XML-field.xmh-key      = buf_XML-entity.xme-key
               buf_XML-field.xmeEntName   = hField:name
               buf_XML-field.xmeEntValue  = hField:buffer-value
            .
         end.
         vHQry:get-next().
      end.
      vHQry:query-close().
      repspecTableforXml(yes).
   end.
   define variable mfirst as logical no-undo init yes.
   method private void put-log (itext as character ):
      output to "xmlimpexp.log" append.
      if mfirst
      then do:
         put unformatted now skip.
         mfirst = no.
      end.
      put unformatted itext skip.
      output close.
   end.
   method public char GetAtrXml(ikey as int64, iAttrCode as character ):
      define buffer buf_XML-atribut for temp_testXML-atribut.
      find first buf_XML-atribut where buf_XML-atribut.xme-key    eq ikey
                                   and buf_XML-atribut.xmeAtrName eq iattrCode
      no-lock no-error.
      return if available buf_XML-atribut then buf_XML-atribut.xmeAtrValue else ?.
   end.
   method public void updatetablefordb():
      updatetablefordb (?).
   end.
   method public void updatetablefordb(ipublicHahdel as handle):
      define buffer buf_XML-node    for temp_testXML-node.
      define buffer buf_XML-entity  for temp_testXML-entity.
      define buffer buf_XML-field   for temp_testXML-entity.
      define buffer buf_XML-atribut for temp_testXML-atribut.
      define variable VTablename as character no-undo.
      define variable Vkey-rec   as character no-undo.
      define variable VTemp_table-h as handle no-undo.
      define variable VTemp_buffer-h as handle no-undo.
      define variable Vbuffer-h as handle no-undo.
      define variable VTemp_field-h as handle no-undo.
      define variable v-tbl-row as rowid no-undo .
      define variable v-tbl-name as character no-undo .
      define variable vtexterr as character no-undo.
      define variable vi as integer no-undo.
      repspecTableforXml(no).
      for each buf_XML-node where buf_xml-node.xmhNodName begins "table-"
      no-lock:
         VTablename  = substring(buf_xml-node.xmhNodName,length("table-") + 1).
         define variable mglobnwsdis as character no-undo.
         mglobnwsdis = GetAtrXml (buf_xml-node.xmh-key,"NwsNotSend").
         create temp-table VTemp_table-h.
         VTemp_table-h:create-like( substitute('ub.&1',VTablename )) no-error.
         if error-status:error then do:
            vtexterr = substitute( "&1. Ошибка при создании temp-table &2 &3&4&5", vss-workfile,VTablename , return-value, chr(10), error-status :get-message ( error-status :num-messages ) ).
            put-log(vtexterr).
            undo, return  error vtexterr.
         end.
         VTemp_table-h:temp-table-prepare( "tt-" + vtablename ) .
         VTemp_buffer-h = VTemp_table-h:default-buffer-handle.
         create buffer Vbuffer-h for table substitute('ub.&1', VTablename).
         for each buf_XML-entity where buf_XML-entity.xmh-key      = buf_XML-node.xmh-key
                                   and buf_XML-entity.xmeEntName   = "record-" + VTablename
         no-lock:
            define variable mlocalnwsdis as character no-undo.
            if ipublicHahdel ne ?
            then do:
               mlocalnwsdis = GetAtrXml (buf_XML-entity.xme-key,"NwsNotSend").
               if mlocalnwsdis ne ?
               then
                  publish "DisableNwsTable" from ipublicHahdel (mlocalnwsdis).
               else
                  publish "DisableNwsTable" from ipublicHahdel (mglobnwsdis).
            end.
            VTemp_buffer-h:buffer-create() no-error.
            if error-status:error then do:
               vtexterr = substitute( "&1. Ошибка при создании записи в temp-table &2 &3&4&5", VTablename , vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ).
               put-log(vtexterr).
               undo, return  error vtexterr.
            end.
            do vi = 1 to VTemp_buffer-h:num-fields:
               VTemp_field-h = VTemp_buffer-h:buffer-field(vi).
               find first buf_XML-field where buf_XML-field.xmh-key      = buf_XML-entity.xme-key
                                          and buf_XML-field.xmeEntName   = VTemp_field-h:name
               no-lock no-error.
               if available buf_XML-field
               then
                  VTemp_field-h:buffer-value = buf_XML-field.xmeEntValue .
            end.
            objKeyRec:GenKeyRec
              ( input  VTablename
               ,input VTemp_buffer-h
               ,output Vkey-rec
               ) no-error .
            if error-status :error then do:
                vtexterr = substitute( "&1. Ошибка при генерации пропущенного уникального ключа для таблицы &2.&3&4&3&5"
                              ,vss-workfile
                              ,VTablename
                              ,chr(10)
                              ,return-value
                              ,error-status :get-message ( error-status :num-messages )
                            ).
                put-log(vtexterr).
                undo, return  error vtexterr.
            end.
            objKeyRec:genrowkeyr
               ( input  Vkey-rec
                 ,input ?
                 ,input "ub"
                 ,input ?
                 ,input share-lock
                 ,output v-tbl-row
                 ,output v-tbl-name
               ) no-error .
           if error-status :error then do:
              vtexterr = substitute( "&1. Ошибка при поиске записи по уникальному ключу &2.&3&4&3&5"
                             ,vss-workfile
                             ,Vkey-rec
                             ,chr(10)
                             ,return-value
                             ,error-status :get-message ( error-status :num-messages )
                           ).
              put-log(vtexterr).
              undo, return  error vtexterr.
            end.
            if v-tbl-name <> VTablename then do:
               vtexterr = substitute( "&1. Уникальный ключ &2 не соответствует принимаемой записи &3"
                             ,vss-workfile
                             ,Vkey-rec
                             ,VTablename
                           ).
               put-log(vtexterr).
               undo, return  error vtexterr.
            end.
            define variable  Vrecord-delete as logical no-undo.
            find first buf_XML-atribut where buf_XML-atribut.xme-key      = buf_XML-entity.xme-key
                                         and buf_XML-atribut.xmeAtrName   = "record-delete"
            no-lock no-error.
            if avail buf_XML-atribut
            then do:
               assign
                  vrecord-delete = no
                  vrecord-delete = logical(buf_XML-field.xmeEntValue)
               no-error.
            end.
            else do:
               find first buf_XML-field where buf_XML-field.xmh-key      = buf_XML-entity.xme-key
                                          and buf_XML-field.xmeEntName   = "record-delete"
               no-lock no-error.
               assign
                  vrecord-delete = no
                  vrecord-delete = logical(buf_XML-field.xmeEntValue)
               no-error.
            end.
            do trans:
               Vbuffer-h:find-by-rowid( v-tbl-row, exclusive-lock ) no-error.
               if vrecord-delete
               then do:
                  if v-tbl-row ne ?
                  then do:
                     Vbuffer-h:buffer-delete() no-error.
                     if error-status:error then do:
                        vtexterr = substitute( "&1. Ошибка при удаление записи &2 с ключем &3 в БД  &4&5&6", vss-workfile, VTablename,Vkey-rec,  return-value, chr(10), error-status :get-message ( error-status :num-messages ) ).
                        put-log(vtexterr).
                        undo, return  error vtexterr.
                     end.
                     put-log(substitute( "Запись с ключем &1 успешна удалена.",Vkey-rec)).
                  end.
                  else do:
                     put-log(substitute( "Запись с ключем &1 не существует в бд и не может быть удалена.",Vkey-rec)).
                  end.
               end.
               else do:
                  Vbuffer-h:buffer-copy(VTemp_buffer-h) no-error .
                  if error-status:error then do:
                     vtexterr = substitute( "&1. Ошибка при создание/изменение записи &2 с ключем &3 в БД  &3&4&5", vss-workfile, VTablename, Vkey-rec, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ).
                     put-log(vtexterr).
                     undo, return  error vtexterr.
                  end.
                  Vbuffer-h:buffer-release no-error .
                  if error-status:error then do:
                     vtexterr = substitute( "&1. Ошибка при копировании записи &2 с ключем &3 в БД  &3&4&5", vss-workfile, VTablename, Vkey-rec, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ).
                     put-log(vtexterr).
                     undo, return  error vtexterr.
                  end.
                  put-log(substitute( "Запись с ключем &1 успешна обновлена.", Vkey-rec)).
               end.
            end.
            VTemp_buffer-h:buffer-delete() no-error.
         end.
         if ipublicHahdel ne ?
         then
            publish "DisableNwsTable" from ipublicHahdel (?).
         delete object VTemp_table-h.
         delete object Vbuffer-h.
      end.
      for each buf_XML-node where buf_xml-node.xmhNodName eq "After-Imp-Run"
      no-lock:
         define variable vproc  as character no-undo.
         define variable vparam as character no-undo.
         define variable vOk as logical no-undo.
         vproc = GetAtrXml (buf_XML-node.xmh-key,"After-Imp-Run-Procedure").
         if vproc ne ""
         then do:
            vparam = "".
            for each buf_XML-entity where buf_XML-entity.xmh-key      = buf_XML-node.xmh-key
            no-lock:
               vparam = vparam + chr(4) +  buf_XML-entity.xmeEntName + chr(4) + buf_XML-entity.xmeEntValue.
            end.
            vparam = trim( vparam, chr(4)).
            if ipublicHahdel ne ?
            then do:
               publish "RunProcXmlImp" from ipublicHahdel (vproc, vparam, output vok).
               if vOk ne true
               then do:
                  vtexterr = substitute( "&1. Ошибка при Выполнение &2 спараметром &6.&3&4&3&5"
                             ,vss-workfile
                             ,vproc
                             ,chr(10)
                             ,return-value
                             ,error-status :get-message ( error-status :num-messages )
                             ,vparam
                           ).
                 put-log(vtexterr).
                 undo, return  error vtexterr.
               end.
            end.
         end.
      end.
   end.
end class.
