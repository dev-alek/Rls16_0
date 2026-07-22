/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Рубан Дмитрий Андреевич 
Дата создания: 3 авг. 2019 г.
Author:  Ruban Dmitriy Andreevich
Creation date: 3 авг. 2019 г.

*/



using Progress.Lang.*.

block-level on error undo, throw.

class ibs.th.bge.xmlimpexp final: 
   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   define variable vss-revision    as character no-undo init "$Revision:$":U .
   define variable vss-author      as character no-undo init "$Author:$":U .
   define variable vss-date        as character no-undo init "$Date:$":U .
   define variable vss-workfile    as character no-undo init "$Workfile:$":U .
   define variable vss-archive     as character no-undo init "$Archive:$":U .
   define variable vss-description as character no-undo init "".
   {cmp/str-glbl.i class }  
   {GBL/xmldom.i class }
   define variable objKeyRec as ibs.th.gbl.keyrec no-undo.
   define variable iAll as logical no-undo.
   define variable iDopInfo as logical no-undo.
   constructor public xmlimpexp (  ):
      super ().
      objKeyRec = new ibs.th.gbl.keyrec().
     
   /*   .savecode().
      .xmldom-save  ( "c:\11\111.xml" ).
      
      .xmldom-clear().
      .xmldom-load ( "c:\11\111.xml" ).
     .updatetablefordb(). */
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

&glob RunProc          "After-Imp-Run"   
&glob RunProcProcedure "After-Imp-Run-Procedure"   
&glob RunProcParam     "After-Imp-Run-Param"   

&glob prefix-table "table-"
&glob record-table "record-"
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
         vNodeName = {&prefix-table} + VTAbleName.
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
         vNodeName = {&record-table} + VTAbleName.
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
           /* if not valid-handle(hField) then next FND.*/
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
      
      /*delete object ihquery.*/
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
      for each buf_XML-node where buf_xml-node.xmhNodName begins {&prefix-table}
      no-lock:
         VTablename  = substring(buf_xml-node.xmhNodName,length({&prefix-table}) + 1).
         define variable mglobnwsdis as character no-undo.
         mglobnwsdis = GetAtrXml (buf_xml-node.xmh-key,"NwsNotSend").
         create temp-table VTemp_table-h.
         VTemp_table-h:create-like( substitute('ub.&1',VTablename )) no-error.
         if error-status:error then do:
            vtexterr = substitute( "&1. Ошибка при создании temp-table &2 &3&4&5", vss-workfile,VTablename , return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ).
            put-log(vtexterr).
            undo, return  error vtexterr.

         end.
         VTemp_table-h:temp-table-prepare( "tt-" + vtablename ) .
         
         VTemp_buffer-h = VTemp_table-h:default-buffer-handle.
         create buffer Vbuffer-h for table substitute('ub.&1', VTablename).
        
         for each buf_XML-entity where buf_XML-entity.xmh-key      = buf_XML-node.xmh-key
                                   and buf_XML-entity.xmeEntName   = {&record-table} + VTablename
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
               vtexterr = substitute( "&1. Ошибка при создании записи в temp-table &2 &3&4&5", VTablename , vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ).
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
                              ,{&new-line}
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
                             ,{&new-line}
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
                        vtexterr = substitute( "&1. Ошибка при удаление записи &2 с ключем &3 в БД  &4&5&6", vss-workfile, VTablename,Vkey-rec,  return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ).
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
                     vtexterr = substitute( "&1. Ошибка при создание/изменение записи &2 с ключем &3 в БД  &3&4&5", vss-workfile, VTablename, Vkey-rec, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ).
                     put-log(vtexterr).
                     undo, return  error vtexterr.

                  end.

                  Vbuffer-h:buffer-release no-error .
                  if error-status:error then do:
                     vtexterr = substitute( "&1. Ошибка при копировании записи &2 с ключем &3 в БД  &3&4&5", vss-workfile, VTablename, Vkey-rec, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ).
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
      for each buf_XML-node where buf_xml-node.xmhNodName eq {&RunProc}
      no-lock:
         define variable vproc  as character no-undo.
         define variable vparam as character no-undo.
         define variable vOk as logical no-undo.
         vproc = GetAtrXml (buf_XML-node.xmh-key,{&RunProcProcedure}).
         if vproc ne ""
         then do:
            vparam = "".
            for each buf_XML-entity where buf_XML-entity.xmh-key      = buf_XML-node.xmh-key
/*                                      and buf_XML-entity.xmeEntName   = {&RunProcParametr} */
            no-lock:
               vparam = vparam + {&delim-par} +  buf_XML-entity.xmeEntName + {&delim-par} + buf_XML-entity.xmeEntValue.
            end.
            vparam = trim( vparam, {&delim-par}).
            if ipublicHahdel ne ?
            then do:
               publish "RunProcXmlImp" from ipublicHahdel (vproc, vparam, output vok).
               if vOk ne true
               then do:
                  vtexterr = substitute( "&1. Ошибка при Выполнение &2 спараметром &6.&3&4&3&5"
                             ,vss-workfile
                             ,vproc
                             ,{&new-line}
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
&glob RunProc          "After-Imp-Run"   
&glob RunProcProcedure "After-Imp-Run-Procedure"   
&glob RunProcParam     "After-Imp-Run-Param"   
   
end class.